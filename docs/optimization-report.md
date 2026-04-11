# Hex Module Optimization Report

Benchmarked with [elm-bench](https://github.com/miniBill/elm-bench) on 1024-byte inputs (AC power).
All measurements are from `bench/` using `elm-bench -f Bench.<fn> "()"`.

Note: `Bench.toStr_v1` / `Bench.fromStr_v1` call the main `src/Hex.elm` module,
which has been updated to the final optimized implementation. V2 is used as
the toString baseline and V3 as the fromString baseline (closest to naive).

## Final Results (1024 bytes)

| Function | Naive | Final | Speedup |
|---|---|---|---|
| `toString` | 58,300 ns (V2) | 23,200 ns (V10) | **2.5x faster** |
| `fromString` | 54,949 ns (V3) | 15,159 ns (V6) | **3.6x faster** |

## toString: Optimization Journey

### V2 — Naive baseline (58,300 ns)

`Decode.loop` reading one `unsignedInt8` per iteration.
Each byte converted to a 2-char hex string via nibble arithmetic
(`Char.fromCode`). Accumulated into `List String`, reversed, concatenated.

### V3 — Int32 batching (52,131 ns, 11% faster)

Read 4 bytes at a time via `Decode.unsignedInt32 BE`, reducing decoder
calls by 4x. Each 32-bit word is split into 4 bytes, each converted
to hex via nibble arithmetic and assembled with `String.fromList`.

### V5 — List Char + String.fromList (58,785 ns, same as baseline)

Used `List Char` accumulator and `String.fromList` for final assembly.
No improvement because `__Utils_chr` wrapper allocation per character
negates any benefit.

### V4 — Array lookup table (39,598 ns, 32% faster)

Pre-computed all 256 byte-to-hex-pair mappings in an `Array String`.
Eliminated nibble arithmetic, `Char.fromCode`, and `String.cons` per byte.
One `Array.get` per byte replaces 4 function calls. Also switched from
tuples to records for the loop state (records with stable shape are
faster than tuples in Elm's JS output).

### V6 — Pre-joined 8-char strings (28,666 ns, 51% faster)

Instead of consing 4 separate 2-char strings per Int32 word, joined them
inline with `++` into a single 8-char string. Reduced the final list
length by 4x (from N to N/4 elements), making `List.reverse` and
`String.concat` proportionally cheaper.

### V7 — Decode.map2 (26,841 ns, 54% faster)

Used `Decode.map2` to read 2 Int32s per loop iteration (8 bytes),
halving the number of loop iterations and thus the number of record
allocations and `Decode.Loop` wrappers.

### V8 — Best-of combo (25,910 ns, 56% faster)

V7 toString + V6 fromString combined.

### V9 — Bytes as intermediate (25,212 ns, 57% faster)

Encoded via Bytes as intermediate representation. Similar speed to V7/V8,
confirming that `Decode.string` (byte-by-byte `+=`) is roughly equivalent
to `String.concat` (`Array.join`).

### V10 — Decode.map5 (23,200 ns, 60% faster) FINAL

Used `Decode.map5` to read 5 Int32s per loop iteration (20 bytes).
Falls back to `map2` and then `map` for remainders. Reduces loop overhead
to ~1/5 of the naive approach.

## fromString: Optimization Journey

### V3 — Naive baseline (54,949 ns)

Iterates hex string 2 characters at a time via `String.slice` +
`String.uncons`. Each pair parsed to a byte using `Maybe`-returning
`hexCharToInt`. Each byte encoded as `Encode.unsignedInt8`.

### V2 — String.foldl (85,974 ns, 56% SLOWER)

Used `String.foldl` with a state machine processing chars in pairs.
Dramatically slower because `String.foldl` wraps every character in
`__Utils_chr` (Elm's Char wrapper), allocating one JS object per char.

### V7 — Array nibble lookup (36,427 ns, 34% faster)

Used `Array.get` for nibble-to-int lookup instead of an if-else chain.
Some improvement but the two depth-2 `Array.get` + `Maybe` unwraps
per hex digit add overhead.

### V9 — Bytes as intermediate (39,012 ns, 29% faster)

Encoded the hex string to Bytes via `Encode.string` (kernel UTF-8
encoding), then decoded char codes as `unsignedInt32` to avoid all
String/Char APIs. The `Encode.string` overhead (UTF-8 width calculation
pass + write pass + ArrayBuffer allocation) limited the gains.

### V5 — Sentinel only (25,743 ns, 53% faster)

`hexCharToInt` returns `Int` (-1 for invalid) instead of `Maybe Int`.
Eliminates `Maybe` wrapper allocation per hex digit (2048 `Just`
wrappers avoided for a 1024-byte input).

### V4 — Int32 encoding + sentinel (19,504 ns, 65% faster)

Two key changes:

1. **Int32 encoding**: Parse 8 hex chars into a single `Encode.unsignedInt32 BE`
   instead of 4 separate `unsignedInt8` calls. This reduces the encoder list
   to 1/4 the length, meaning 4x fewer list cons cells, and `Encode.sequence`
   processes 4x fewer nodes.

2. **Sentinel -1 instead of Maybe**: Same sentinel trick as V5.

### V1/Final — Same as V4 (16,497 ns, 70% faster)

The main `src/Hex.elm` uses V4's fromString approach. Slightly faster than
the bench V4 module due to Elm compiler optimizations (single-module
inlining).

### V6 — String.toList upfront (15,159 ns, 72% faster, inconsistent) BEST

Converts the entire hex string to `List Char` in one kernel call, then
pattern-matches `c0 :: c1 :: ... :: c7 :: rest` to process 8 chars at
a time. Eliminates all `String.slice` and `String.uncons` calls. However,
`String.toList` still allocates one `__Utils_chr` wrapper per character,
so the improvement over V4 is inconsistent (0-12% depending on run).

## Techniques That Worked

| Technique | Impact | Why |
|---|---|---|
| Records over tuples (loop state) | ~5-10% | JS engines optimize fixed-shape objects better than Elm tuples |
| Array lookup table (toString) | +32% | One Array.get replaces nibble branching + Char.fromCode |
| Pre-joining strings per word (toString) | +25% | 4x shorter list for final String.concat |
| Decode.map2/map5 batching (toString) | +20% | Fewer loop iterations = fewer record + Loop wrapper allocs |
| Int32 encoder batching (fromString) | +60% | 4x fewer Encoder nodes, 4x fewer list cons cells |
| Sentinel -1 over Maybe (fromString) | +40% | No Maybe wrapper allocation per hex digit |

## Techniques That Failed

| Technique | Impact | Why |
|---|---|---|
| String.foldl for parsing | -56% | `__Utils_chr` wrapper allocated per character |
| List Char + String.fromList (toString) | 0% | Same `__Utils_chr` problem |
| Array-based nibble lookup (fromString) | mixed | Two depth-2 Array.get + Maybe > simple if-else chain |
| Bytes as intermediate (fromString) | +29% | Encode.string overhead (2 passes + ArrayBuffer) limits gains |
| Bytes as intermediate (toString) | +57% | Similar to map2 batching, no clear advantage over map5 |

## Key Elm Performance Insights

1. **Allocation is the dominant cost.** Every `Maybe`, `Just`, tuple, cons cell,
   and `__Utils_chr` wrapper is a JS object allocation. Reducing allocations
   matters more than reducing computation.

2. **`__Utils_chr` is expensive.** Any API that iterates characters (`String.foldl`,
   `String.toList`, `String.map`) wraps each char in a `_Utils_chr` object.
   Avoid character-level iteration when possible.

3. **Elm's `Array` is an RRB tree.** `Array.get` on a 256-element array does
   2 node lookups (32-wide branching, depth = ceil(log32(256)) = 2). Still
   faster than computed alternatives because it avoids per-element allocation.

4. **Records beat tuples for loop state.** JS engines (V8) optimize objects with
   stable shapes via hidden classes. Elm records compile to plain JS objects
   with consistent property names, which V8 can optimize better than the
   positional tuple encoding.

5. **Batch at the Bytes.Encode level, not just Bytes.Decode.** Encoding 4 bytes
   as one `unsignedInt32` is not just a decode optimization — it reduces the
   `Encoder` tree that `Encode.sequence` must traverse and `Encode.encode`
   must write.

6. **`Decode.map5` > `map2` > `map`.** Each additional decoder in a mapN call
   amortizes the per-iteration overhead (record creation, `Decode.Loop` wrapper,
   loop function call) across more bytes. Diminishing returns beyond map5.
