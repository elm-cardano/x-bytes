# bench/

Benchmarking infrastructure for Hex encoding/decoding implementations.

## Implementations

- **V1** (`Hex` / `../src/Hex.elm`): Final optimized version. `toString`: `Decode.map5` + Int32 batching + Array lookup table + String accumulator via `++`. `fromString`: Int32 encoder batching + sentinel -1 + `String.slice`/`uncons`.
- **V2** (`Hex.V2`): Copy of V1 to modify and experiment with.

## Running benchmarks

Using [elm-bench](https://github.com/miniBill/elm-bench):

```sh
cd bench

# Compare toString (1024 bytes)
elm-bench -f Bench.v1_toStr_1024 -f Bench.v2_toStr_1024 "()"

# Compare fromString (1024 bytes)
elm-bench -f Bench.v1_fromStr_1024 -f Bench.v2_fromStr_1024 "()"

# Compare at different sizes
elm-bench -f Bench.v1_toStr_32 -f Bench.v2_toStr_32 "()"
elm-bench -f Bench.v1_toStr_256 -f Bench.v2_toStr_256 "()"
```

See `docs/optimization-report.md` for the full optimization journey.
