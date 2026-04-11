# bench/

Benchmarking infrastructure for Hex encoding/decoding implementations.

## Implementations

- **V1** (`Hex` / `../src/Hex.elm`): Current implementation under development.
- **V2** (`Hex.V2`): Copy of V1 (baseline for comparison).

## Running benchmarks

Using [elm-bench](https://github.com/miniBill/elm-bench):

```sh
cd bench

# Compare fromBytes
elm-bench -f Bench.v1_fromBytes_1024 -f Bench.v2_fromBytes_1024 "()"

# Compare toBytes
elm-bench -f Bench.v1_toBytes_1024 -f Bench.v2_toBytes_1024 "()"

# Compare toBytesUnchecked
elm-bench -f Bench.v1_toBytesU_1024 -f Bench.v2_toBytesU_1024 "()"
```

## Correctness checks

```sh
cd bench
elm-test
```

See `docs/optimization-report.md` for the full optimization journey.
