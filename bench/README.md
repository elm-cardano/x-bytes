# bench/

Benchmarking infrastructure for Hex encoding/decoding implementations.

## Implementations

- **V1** (`Hex` / `../src/Hex.elm`): Final optimized version. `toString`: `Decode.map5` + Int32 batching + Int case switch table + String accumulator via `++`. `fromString`: Int32 encoder batching + sentinel -1 + `String.slice`/`uncons`.
- **V2** (`Hex.V2`): Copy of V1 before switch table optimization (uses Array lookup).
- **V3** (`Hex.V3`): Int case switch table for `toString` (replaces Array.get lookup). Now the default in V1.
- **V4** (`Hex.V4`): Branchless nibble-to-char computation for `toString`. Same speed as Array.get.
- **V5** (`Hex.V5`): Branchless or-0x20 validation for `fromString`. 27% slower after correctness fix.
- **V6** (`Hex.V6`): Backward iteration (no List.reverse) for `fromString`/`fromStringUnchecked`. 9% slower.

## Running benchmarks

Using [elm-bench](https://github.com/miniBill/elm-bench):

```sh
cd bench

# Compare toString (1024 bytes)
elm-bench -f Bench.v1_toStr_1024 -f Bench.v2_toStr_1024 "()"

# Compare toString variants
elm-bench -f Bench.v1_toStr_1024 -f Bench.v3_toStr_1024 -f Bench.v4_toStr_1024 "()"

# Compare fromString variants
elm-bench -f Bench.v1_fromStr_1024 -f Bench.v5_fromStr_1024 "()"
elm-bench -f Bench.v1_fromStr_1024 -f Bench.v6_fromStr_1024 "()"

# Compare at different sizes
elm-bench -f Bench.v1_toStr_8 -f Bench.v3_toStr_8 "()"
elm-bench -f Bench.v1_toStr_4096 -f Bench.v3_toStr_4096 "()"
```

## Correctness checks

```sh
cd bench
elm-test
```

See `docs/optimization-report.md` for the full optimization journey.
