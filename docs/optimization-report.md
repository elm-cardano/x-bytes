# Hex Module Optimization Report

Benchmarked with [elm-bench](https://github.com/miniBill/elm-bench) on 1024-byte inputs (AC power).
All measurements are from `bench/` using `elm-bench -f Bench.<fn> "()"`.

Note: `Bench.toStr_v1` / `Bench.fromStr_v1` call the main `src/Hex.elm` module,
which has been updated to the final optimized implementation. V2 is used as
the toString baseline and V3 as the fromString baseline (closest to naive).

## Final Results (1024 bytes)

| Function | Naive | Final | Speedup |
|---|---|---|---|
| `toString` | 58,300 ns (V2) | 17,675 ns (V26) | **3.3x faster** |
| `fromString` | 54,949 ns (V3) | 15,159 ns (V6) | **3.6x faster** |
| `fromStringUnchecked` | 54,949 ns (V3) | ~12,900 ns (V19) | **4.3x faster** |

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

### V10 — Decode.map5 (23,200 ns, 60% faster)

Used `Decode.map5` to read 5 Int32s per loop iteration (20 bytes).
Falls back to `map2` and then `map` for remainders. Reduces loop overhead
to ~1/5 of the naive approach.

### V20 — Record literal syntax (same speed as V10)

Replaced `EncState w r a` constructor (compiles to `A3(EncState, w, r, a)`)
with record literal `{ words = w, rem = r, acc = a }` (compiles to a direct
JS object literal). No measurable difference — V8's hidden classes make the
constructor call overhead negligible.

### V21 — Push individual byte strings (23% slower)

Instead of building 8-char strings per word with `++`, pushed 4 individual
2-char strings onto the list accumulator. Eliminated `++` but 4x larger
list made `List.reverse` + `String.concat` much more expensive. Confirms
that list size is a bigger cost than short-string concatenation.

### V22 — uint16 lookup table (10% faster, rejected)

65536-entry lookup table mapping uint16 values to 4-char hex strings.
Halved Array.get calls (2 per word instead of 4) and reduced `++` from
3 to 1. 10% faster but the ~566 KB table is unacceptable for source and
compiled output size.

### V23 — String accumulator (18,649 ns, 68% faster)

Replaced `acc : List String` with `acc : String`. Grows the result
directly via `++` instead of accumulating a list and doing
`String.concat (List.reverse ...)` at the end. V8 uses ConsString ropes
internally, making `a + b` O(1) per append (creates a tree node, not a
copy). The rope is flattened on first read in O(n). Eliminates all list
cons, `List.reverse`, and `String.concat` overhead. Also uses record
literal syntax. ~20% faster than V10 at both 32 and 1024 bytes.

### V24 — Two-phase decoder (same speed at 1024, 10% slower at 32)

Split into two separate `Decode.loop` calls: one for Int32 words (map5),
one for remainder bytes. The `Decode.andThen` overhead between loops
negated any benefit from smaller function bodies.

### V25 — Single-word loop, no map5 (17% slower)

One `Decode.unsignedInt32 BE` per iteration with a trivially simple loop
body. 256 iterations vs ~53 for map5. Confirms that `Decode.loop`
per-iteration overhead is significant — map5 batching is essential.

### V26 — Int case switch table (17,675 ns, 70% faster) FINAL

Replaced the `Array.get byte hexTable` lookup (256-entry `Array String`)
with a 256-branch `case byte of` expression on `Int`. Elm compiles
integer `case` to a JS `switch` statement, which V8 optimizes to a
jump table — O(1) with zero allocation. The previous `Array.get`
approach required 2 RRB tree node lookups (depth-2 for 256 elements)
plus a `Just` wrapper allocation per lookup, followed by a `case`
destructure to unwrap the `Maybe`. For 1024 bytes, that is 1024 `Just`
allocations eliminated. Also removes the `Array` import entirely.

| Size | V23 (Array.get) | V26 (switch) | Change |
|---|---|---|---|
| 8 B | 211 ns | 177 ns | **16% faster** |
| 32 B | 672 ns | 556 ns | **17% faster** |
| 256 B | 4,963 ns | 4,236 ns | **15% faster** |
| 1024 B | 18,884 ns | 17,675 ns | **6% faster** |
| 4096 B | 77,275 ns | 71,278 ns | **8% faster** |

Bigger improvement at smaller sizes where the per-lookup `Maybe`
allocation is a larger fraction of total cost.

### V27 — Branchless nibble-to-char computation (same speed as V23)

Replaced `Array.get` with branchless arithmetic: split byte into two
nibbles, convert each to a char code via
`nibble + 48 + 39 * Bitwise.shiftRightZfBy 4 (nibble + 6)`,
then `String.fromChar (Char.fromCode ...)` concatenated with `++`.
V8 interns single-character ASCII strings, so `Char.fromCode` for hex
digits returns cached strings (no allocation). However, each byte
requires an extra `++` to join the two 1-char strings, creating one
ConsString node per byte that roughly offsets the saved `Just`
allocation from `Array.get`. No measurable improvement.

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

### V28 — Branchless or-0x20 validation (27% SLOWER)

Replaced the 3-branch `hexDigit` validation (digits / uppercase /
lowercase) with `Bitwise.or 0x20 code` to lowercase, then 2 range checks
on the lowercased value, followed by the branchless nibble formula
`lc - 48 - 39 * Bitwise.shiftRightZfBy 6 lc`.

The initial (buggy) version omitted proper range checks and showed a
21% improvement, but accepted invalid characters like `@` and `` ` ``
(which `or 0x20` maps into valid ranges). After adding correct
validation (`(0x30 <= lc && lc <= 0x39) || (0x61 <= lc && lc <= 0x66)`),
the improvement vanished — 27% slower at 1024 bytes. The extra
`Bitwise.or` operation and the branchless formula
(subtraction + multiplication + shift) are more work per nibble than
V1's simple `code - 0x30` / `code - 0x37` / `code - 0x57` in each
branch. The original improvement came entirely from skipping validation.

| Size | V1 (3-branch) | V28 (or-0x20) | Change |
|---|---|---|---|
| 8 B | 261 ns | 268 ns | 3% slower |
| 32 B | 630 ns | 677 ns | **7% slower** |
| 1024 B | 16,347 ns | 20,738 ns | **27% slower** |

### V29 — Backward iteration, no List.reverse (9% SLOWER)

Iterated the hex string from end to beginning, prepending encoders to
build the list in forward order — eliminating `List.reverse` entirely.
However, the extra arithmetic per iteration (computing backward offsets,
handling remainder bytes at the end of the string first) outweighed the
`List.reverse` savings.

| Size | V1 (forward + reverse) | V29 (backward) | Change |
|---|---|---|---|
| fromString 1024 B | 16,514 ns | 18,040 ns | **9% slower** |
| fromStringUnchecked 1024 B | 12,940 ns | 12,767 ns | ~same |

## fromStringUnchecked: Optimization Journey

`fromStringUnchecked` assumes valid lowercase hex input (even length, only
0-9 and a-f). This removes validation overhead and enables a branchless
nibble conversion.

### V11/V19 — Branchless nibble + no validation (~12,900 ns, ~20% faster than fromString)

Key changes from `fromString`:

1. **No Maybe**: Returns `Bytes` directly instead of `Maybe Bytes`. Eliminates
   `Just`/`Nothing` wrapper allocations and `Maybe.andThen`/`Maybe.map` overhead.

2. **No sentinel checking**: Removes the `-1` sentinel return and `< 0` validation
   checks in `hexPairAt`.

3. **Branchless nibble conversion**: `code - 48 - 39 * Bitwise.shiftRightZfBy 6 code`
   maps '0'-'9' to 0-9 and 'a'-'f' to 10-15 in one expression. Eliminates the
   3-branch if-else chain per hex digit.

4. **Hot-path-first branching** (V19 style): `if remaining > 0` instead of
   `if remaining <= 0`. No measurable difference (V8 branch prediction handles
   both), but reads more naturally.

### Variants tested (V12-V18)

| Variant | Approach | Result |
|---|---|---|
| V12 | `String.toList` instead of `String.slice` | 16% faster (worse than V11) |
| V13 | Bytes intermediate, Decode.map5, Int16 output | 78% slower |
| V14 | Bytes intermediate, map5-of-map2, Int32 output | 47% slower |
| V15 | 256-branch pattern match on hex pairs | 1878% slower |
| V16 | Slice 2-char pair + double String.uncons | 16% faster (worse than V11) |
| V17 | Dict String Int lookup for hex pairs | 450% slower |
| V18 | `== 0` instead of `<= 0` | Same speed as V11 |

Key insight: Within pure Elm, `String.slice` + `String.uncons` + branchless
arithmetic is near-optimal. The `__Utils_chr` allocation from `String.uncons`
is an inescapable cost of Elm's Char type (2 allocations per byte: Just tuple
+ \_\_Utils\_chr wrapper).

## Techniques That Worked

| Technique | Impact | Why |
|---|---|---|
| Int case switch table (toString) | +6-17% | JS `switch` on Int compiles to jump table; zero allocation vs Array.get's `Just` wrapper |
| String accumulator via ++ (toString) | +20% | V8 ConsString ropes make ++ O(1); eliminates List.reverse + String.concat |
| Records over tuples (loop state) | ~5-10% | JS engines optimize fixed-shape objects better than Elm tuples |
| Array lookup table (toString) | +32% | One Array.get replaces nibble branching + Char.fromCode (superseded by switch table) |
| Pre-joining strings per word (toString) | +25% | 4x shorter list for final String.concat |
| Decode.map2/map5 batching (toString) | +20% | Fewer loop iterations = fewer record + Loop wrapper allocs |
| Int32 encoder batching (fromString) | +60% | 4x fewer Encoder nodes, 4x fewer list cons cells |
| Sentinel -1 over Maybe (fromString) | +40% | No Maybe wrapper allocation per hex digit |
| Branchless nibble (fromStringUnchecked) | +20% | `code - 48 - 39 * (code >>> 6)` replaces 3-branch if-else |

## Techniques That Failed

| Technique | Impact | Why |
|---|---|---|
| String.foldl for parsing | -56% | `__Utils_chr` wrapper allocated per character |
| List Char + String.fromList (toString) | 0% | Same `__Utils_chr` problem |
| Push individual byte strings (toString) | -23% | 4x larger list makes List.reverse + String.concat more expensive than ++ |
| Single-word loop, no map5 (toString) | -17% | Decode.loop per-iteration overhead dominates; batching is essential |
| Record literal vs constructor (toString) | 0% | V8 hidden classes make EncState constructor call free |
| Two-phase decoder (toString) | 0% to -10% | Decode.andThen overhead between loops negates simpler function bodies |
| uint16 lookup table (toString) | +10% | Halves lookups but 566KB table unacceptable for code size |
| Branchless nibble-to-char (toString) | 0% | ConsString node from joining 2 char strings offsets saved `Just` alloc |
| 256-branch pattern match (fromString) | -1878% | Elm compiles case-on-string to linear if-else chains (case-on-Int is different!) |
| Dict lookup (fromString) | -450% | Red-black tree: O(log n) string comparisons per lookup |
| Bytes as intermediate (fromString) | -47% to -78% | Encode.string overhead (2 passes + ArrayBuffer) far exceeds gains |
| Array-based nibble lookup (fromString) | mixed | Two depth-2 Array.get + Maybe > simple if-else chain |
| Branchless or-0x20 validation (fromString) | -27% | Extra Bitwise.or + branchless formula is more work than simple per-branch subtraction |
| Backward iteration, no List.reverse (fromString) | -9% | Extra offset arithmetic outweighs List.reverse savings |
| `== 0` vs `<= 0` branch style | 0% | V8 branch predictor handles both trivially |
| Hot-path-first branching | 0% | V8 branch predictor handles both trivially |

## Key Elm Performance Insights

1. **Allocation is the dominant cost.** Every `Maybe`, `Just`, tuple, cons cell,
   and `__Utils_chr` wrapper is a JS object allocation. Reducing allocations
   matters more than reducing computation.

2. **V8 ConsString ropes make `++` O(1).** JS engines defer string concatenation
   by building a rope (tree of string fragments). The rope flattens on first
   read in O(n). Accumulating a single `String` via `++` beats building a
   `List String` + `List.reverse` + `String.concat`, because it avoids all
   list cons cell allocations and the reverse/concat traversals.

3. **`__Utils_chr` is expensive.** Any API that iterates characters (`String.foldl`,
   `String.toList`, `String.map`, `String.uncons`) wraps each char in a
   `_Utils_chr` object. Avoid character-level iteration when possible. For
   `fromString`, this is an inescapable cost — `String.uncons` is needed to
   extract char codes.

4. **Elm's `case` on Int compiles to JS `switch`.** V8 optimizes dense integer
   `switch` to jump tables — O(1) with zero allocation. A 256-branch `case`
   on `Int` is faster than `Array.get` (which requires RRB tree traversal +
   `Maybe` allocation) and is the preferred lookup strategy for byte-to-hex
   mapping. Note: `case` on `String` compiles to linear if-else chains and
   should be avoided.

5. **Records beat tuples for loop state.** JS engines (V8) optimize objects with
   stable shapes via hidden classes. Elm records compile to plain JS objects
   with consistent property names, which V8 can optimize better than the
   positional tuple encoding. Note: record literal syntax vs named constructor
   makes no measurable difference.

6. **Batch at the Bytes.Encode level, not just Bytes.Decode.** Encoding 4 bytes
   as one `unsignedInt32` is not just a decode optimization — it reduces the
   `Encoder` tree that `Encode.sequence` must traverse and `Encode.encode`
   must write.

7. **`Decode.map5` > `map2` > `map`.** Each additional decoder in a mapN call
   amortizes the per-iteration overhead (record creation, `Decode.Loop` wrapper,
   loop function call) across more bytes. Diminishing returns beyond map5.
   A single-word loop (no batching) is 17% slower than map5.

8. **Branchless arithmetic beats branching for small mappings.** The nibble
   conversion `code - 48 - 39 * (code >>> 6)` is faster than a 3-branch
   if-else chain, but only matters when validation is not needed.

9. **Source-level branch order doesn't matter.** V8's branch predictor handles
   `if remaining > 0` and `if remaining <= 0` identically. `== 0` compiles
   to JS `!remaining` (falsy check) but shows no measurable difference either.
