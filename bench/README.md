# bench/

Benchmarking infrastructure for Hex encoding/decoding implementations.

## Implementations

- **V1** (`Hex` / `../src/Hex.elm`): Final optimized version. `toString`: `Decode.map5` + Int32 batching + Array lookup table + pre-joined 8-char strings. `fromString`: Int32 encoder batching + sentinel -1 + `String.slice`/`uncons`.
- **V2** (`Hex.V2`): `Decode.loop` + `String.foldl` fromString.
- **V3** (`Hex.V3`): Int32 decode batching + nibble arithmetic.
- **V4** (`Hex.V4`): Array lookup table + Int32 encoder batching.
- **V5** (`Hex.V5`): `List Char` + `String.fromList` toString. Sentinel fromString.
- **V6** (`Hex.V6`): Pre-joined word strings + `String.toList` fromString.
- **V7** (`Hex.V7`): `Decode.map2` + Array nibble lookup fromString.
- **V8** (`Hex.V8`): Best-of combo (V7 toString + V6 fromString).
- **V9** (`Hex.V9`): Bytes-as-intermediate for both directions.
- **V10** (`Hex.V10`): `Decode.map5` toString + V4 fromString.

## Running benchmarks

Using [elm-bench](https://github.com/miniBill/elm-bench):

```sh
cd bench

# Compare toString across variants (1024 bytes)
elm-bench -f Bench.toStr_v1_1024 -f Bench.toStr_v10_1024 "()"

# Compare fromString across variants (1024 bytes)
elm-bench -f Bench.fromStr_v1_1024 -f Bench.fromStr_v4_1024 "()"

# Full suite at different sizes
elm-bench -f Bench.toStr_v1_256 -f Bench.toStr_v4_256 -f Bench.toStr_v8_256 -f Bench.toStr_v10_256 "()"
elm-bench -f Bench.fromStr_v1_256 -f Bench.fromStr_v4_256 -f Bench.fromStr_v6_256 "()"
```

See `docs/optimization-report.md` for the full optimization journey.
