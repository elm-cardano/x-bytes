module Bench exposing
    ( jxx_fromBytes_1024
    , jxx_fromBytes_256
    , jxx_fromBytes_32
    , jxx_toBytes_1024
    , jxx_toBytes_256
    , jxx_toBytes_32
    , v1_fromBytes_1024
    , v1_fromBytes_256
    , v1_fromBytes_32
    , v1_fromBytes_4096
    , v1_fromBytes_8
    , v1_toBytesU_1024
    , v1_toBytesU_256
    , v1_toBytesU_32
    , v1_toBytes_1024
    , v1_toBytes_256
    , v1_toBytes_32
    , v1_toBytes_8
    , v1_xb_concat_100
    , v1_xb_fromHex_1024
    , v1_xb_fromHex_256
    , v1_xb_fromHex_32
    , v2_fromBytes_1024
    , v2_fromBytes_256
    , v2_fromBytes_32
    , v2_toBytesU_1024
    , v2_toBytesU_256
    , v2_toBytesU_32
    , v2_toBytes_1024
    , v2_toBytes_256
    , v2_toBytes_32
    , v2_xb_concat_100
    , v2_xb_fromHex_1024
    , v2_xb_fromHex_256
    , v2_xb_fromHex_32
    )

{-| Benchmark functions for Hex encoding/decoding.

V1 calls the main `src/Hex.elm` module (current implementation).
V2 is a copy of V1 (baseline for comparison).


## fromBytes benchmarks

```sh
elm-bench -f Bench.v1_fromBytes_1024 -f Bench.v2_fromBytes_1024 "()"
```


## toBytes benchmarks

```sh
elm-bench -f Bench.v1_toBytes_1024 -f Bench.v2_toBytes_1024 "()"
```


## toBytesUnchecked benchmarks

```sh
elm-bench -f Bench.v1_toBytesU_1024 -f Bench.v2_toBytesU_1024 "()"
```

-}

import Bytes exposing (Bytes)
import Bytes.Encode as Encode
import Hex
import Hex.Convert
import Hex.V2
import XBytes exposing (XBytes)
import XBytes.V2



-- Test data


makeBytes : Int -> Bytes
makeBytes n =
    Encode.encode
        (Encode.sequence
            (List.map (\i -> Encode.unsignedInt8 (modBy 256 i)) (List.range 0 (n - 1)))
        )


bytes8 : Bytes
bytes8 =
    makeBytes 8


bytes32 : Bytes
bytes32 =
    makeBytes 32


bytes256 : Bytes
bytes256 =
    makeBytes 256


bytes1024 : Bytes
bytes1024 =
    makeBytes 1024


bytes4096 : Bytes
bytes4096 =
    makeBytes 4096


hex8 : String
hex8 =
    Hex.fromBytes bytes8


hex32 : String
hex32 =
    Hex.fromBytes bytes32


hex256 : String
hex256 =
    Hex.fromBytes bytes256


hex1024 : String
hex1024 =
    Hex.fromBytes bytes1024


{-| Uppercase hex strings for jxxcarlson/hex (which produces uppercase output).
-}
hexUpper32 : String
hexUpper32 =
    Hex.Convert.toString bytes32


hexUpper256 : String
hexUpper256 =
    Hex.Convert.toString bytes256


hexUpper1024 : String
hexUpper1024 =
    Hex.Convert.toString bytes1024



-- V1 benchmarks (current implementation)


v1_fromBytes_8 : () -> String
v1_fromBytes_8 () =
    Hex.fromBytes bytes8


v1_fromBytes_32 : () -> String
v1_fromBytes_32 () =
    Hex.fromBytes bytes32


v1_fromBytes_256 : () -> String
v1_fromBytes_256 () =
    Hex.fromBytes bytes256


v1_fromBytes_1024 : () -> String
v1_fromBytes_1024 () =
    Hex.fromBytes bytes1024


v1_fromBytes_4096 : () -> String
v1_fromBytes_4096 () =
    Hex.fromBytes bytes4096


v1_toBytes_8 : () -> Maybe Bytes
v1_toBytes_8 () =
    Hex.toBytes hex8


v1_toBytes_32 : () -> Maybe Bytes
v1_toBytes_32 () =
    Hex.toBytes hex32


v1_toBytes_256 : () -> Maybe Bytes
v1_toBytes_256 () =
    Hex.toBytes hex256


v1_toBytes_1024 : () -> Maybe Bytes
v1_toBytes_1024 () =
    Hex.toBytes hex1024


v1_toBytesU_32 : () -> Bytes
v1_toBytesU_32 () =
    Hex.toBytesUnchecked hex32


v1_toBytesU_256 : () -> Bytes
v1_toBytesU_256 () =
    Hex.toBytesUnchecked hex256


v1_toBytesU_1024 : () -> Bytes
v1_toBytesU_1024 () =
    Hex.toBytesUnchecked hex1024



-- V2 benchmarks (baseline copy)


v2_fromBytes_32 : () -> String
v2_fromBytes_32 () =
    Hex.V2.fromBytes bytes32


v2_fromBytes_256 : () -> String
v2_fromBytes_256 () =
    Hex.V2.fromBytes bytes256


v2_fromBytes_1024 : () -> String
v2_fromBytes_1024 () =
    Hex.V2.fromBytes bytes1024


v2_toBytes_32 : () -> Maybe Bytes
v2_toBytes_32 () =
    Hex.V2.toBytes hex32


v2_toBytes_256 : () -> Maybe Bytes
v2_toBytes_256 () =
    Hex.V2.toBytes hex256


v2_toBytes_1024 : () -> Maybe Bytes
v2_toBytes_1024 () =
    Hex.V2.toBytes hex1024


v2_toBytesU_32 : () -> Bytes
v2_toBytesU_32 () =
    Hex.V2.toBytesUnchecked hex32


v2_toBytesU_256 : () -> Bytes
v2_toBytesU_256 () =
    Hex.V2.toBytesUnchecked hex256


v2_toBytesU_1024 : () -> Bytes
v2_toBytesU_1024 () =
    Hex.V2.toBytesUnchecked hex1024



-- XBytes test data


xbList100 : List XBytes
xbList100 =
    List.repeat 100 (XBytes.fromBytes bytes32)



-- V1 XBytes benchmarks (current implementation)


v1_xb_fromHex_32 : () -> Maybe XBytes
v1_xb_fromHex_32 () =
    XBytes.fromHex hex32


v1_xb_fromHex_256 : () -> Maybe XBytes
v1_xb_fromHex_256 () =
    XBytes.fromHex hex256


v1_xb_fromHex_1024 : () -> Maybe XBytes
v1_xb_fromHex_1024 () =
    XBytes.fromHex hex1024


v1_xb_concat_100 : () -> XBytes
v1_xb_concat_100 () =
    XBytes.concat xbList100



-- V2 XBytes benchmarks (optimized candidates)


v2_xb_fromHex_32 : () -> Maybe XBytes
v2_xb_fromHex_32 () =
    XBytes.V2.fromHex hex32


v2_xb_fromHex_256 : () -> Maybe XBytes
v2_xb_fromHex_256 () =
    XBytes.V2.fromHex hex256


v2_xb_fromHex_1024 : () -> Maybe XBytes
v2_xb_fromHex_1024 () =
    XBytes.V2.fromHex hex1024


v2_xb_concat_100 : () -> XBytes
v2_xb_concat_100 () =
    XBytes.V2.concat xbList100



-- jxxcarlson/hex benchmarks


jxx_fromBytes_32 : () -> String
jxx_fromBytes_32 () =
    Hex.Convert.toString bytes32


jxx_fromBytes_256 : () -> String
jxx_fromBytes_256 () =
    Hex.Convert.toString bytes256


jxx_fromBytes_1024 : () -> String
jxx_fromBytes_1024 () =
    Hex.Convert.toString bytes1024


jxx_toBytes_32 : () -> Maybe Bytes
jxx_toBytes_32 () =
    Hex.Convert.toBytes hexUpper32


jxx_toBytes_256 : () -> Maybe Bytes
jxx_toBytes_256 () =
    Hex.Convert.toBytes hexUpper256


jxx_toBytes_1024 : () -> Maybe Bytes
jxx_toBytes_1024 () =
    Hex.Convert.toBytes hexUpper1024
