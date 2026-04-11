# elm-cardano/x-bytes

Fast hex encoding/decoding and comparable byte sequences for Elm.

## Modules

### Hex

Convert between `Bytes` and hexadecimal strings.

```elm
import Hex

Hex.fromBytes bytes       -- Bytes -> String
Hex.toBytes "deadbeef"    -- String -> Maybe Bytes
Hex.toBytesUnchecked hex  -- String -> Bytes (no validation)
```

### XBytes

Comparable byte sequences backed by a lowercase hex string. Unlike `Bytes`, two `XBytes` values can be compared with `==`.

```elm
import XBytes

XBytes.fromHex "DeadBeef"  -- Maybe XBytes (validates + lowercases)
XBytes.toHex xb            -- String
XBytes.fromBytes bytes     -- XBytes
XBytes.toBytes xb          -- Bytes
```

Plus common operations: `append`, `concat`, `slice`, `reverse`, `left`, `right`, `dropLeft`, `dropRight`, `join`, `width`, and JSON / `Bytes.Encode` / `Bytes.Decode` interop. See the [module docs](https://package.elm-lang.org/packages/elm-cardano/x-bytes/1.0.0/) for the full API.

## Install

```sh
elm install elm-cardano/x-bytes
```

## Performance

Performance is a first-class concern for this package. Every function has been benchmarked and optimized, with multiple implementation strategies tested and compared. Here are the key techniques:

- **Batched decoding**: `Hex.fromBytes` reads 20 bytes per loop iteration (via `Decode.map5` over `Int32`) and maps each byte through a 256-entry `case` jump table (compiled to a V8 O(1) switch). `Hex.toBytes` parses 8 hex characters at a time, packing 4 bytes into `Int32` words to reduce encoder list length by 4x.
- **Allocation-free validation**: `XBytes.fromHex` validates hex characters without allocating intermediate `Bytes` or `Encoder` nodes, then applies a single native `String.toLower` call. Benchmarked 25-43% faster than routing through `Hex.toBytes`.
- **ConsString-aware accumulation**: String concatenation with `(++)` is O(1) in V8 (creates a rope node), which we exploit throughout. `XBytes.concat` uses `List.foldl` with `(++)` instead of building an intermediate list, benchmarked 63% faster.
- **Sentinel-based error signaling**: Hex digit parsing returns `-1` instead of `Nothing`, eliminating one `Just` allocation per hex pair (2048 saved for 1024 bytes).

As a reference point, here is how our `Hex` module compares to [`jxxcarlson/hex`](https://package.elm-lang.org/packages/jxxcarlson/hex/latest/) (the most popular Elm hex package):

| Function | Size | elm-cardano/x-bytes | jxxcarlson/hex | Speedup |
|----------|------|--------------------:|---------------:|--------:|
| `fromBytes` | 32 B | 518 ns | 2,345 ns | **4.5x** |
| `fromBytes` | 256 B | 4,146 ns | 18,321 ns | **4.4x** |
| `fromBytes` | 1024 B | 17,880 ns | 77,491 ns | **4.3x** |
| `toBytes` | 32 B | 635 ns | 1,171 ns | **1.8x** |
| `toBytes` | 256 B | 4,232 ns | 8,162 ns | **1.9x** |
| `toBytes` | 1024 B | 16,191 ns | 34,398 ns | **2.1x** |

See [`bench/`](https://github.com/elm-cardano/x-bytes/tree/main/bench) for the full benchmarking setup and methodology.
See [`optimization-report.md`](https://github.com/elm-cardano/x-bytes/tree/main/docs/optimization-report.md) for the history of attempted optimizations.

## Development

```sh
pnpm install
pnpm test           # run tests
pnpm review         # elm-review
pnpm format:check   # check formatting
pnpm bench:build    # build benchmarks
pnpm bench:test     # run benchmark correctness checks
```
