# bench/

Benchmarking infrastructure for Hex encoding/decoding implementations.

## Implementations

- **V1** (`Hex` / `../src/Hex.elm`): Current implementation under development.
- **V2** (`Hex.V2`): Copy of V1 (baseline for comparison).

## Running benchmarks

Using [elm-bench](https://github.com/miniBill/elm-bench):

```sh
cd bench

# Compare toString
elm-bench -f Bench.v1_toStr_1024 -f Bench.v2_toStr_1024 "()"

# Compare fromString
elm-bench -f Bench.v1_fromStr_1024 -f Bench.v2_fromStr_1024 "()"

# Compare fromStringUnchecked
elm-bench -f Bench.v1_fromStrU_1024 -f Bench.v2_fromStrU_1024 "()"
```

## Correctness checks

```sh
cd bench
elm-test
```

See `docs/optimization-report.md` for the full optimization journey.
