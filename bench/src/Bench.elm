module Bench exposing
    ( v1_fromStrU_1024
    , v1_fromStrU_256
    , v1_fromStrU_32
    , v1_fromStr_1024
    , v1_fromStr_256
    , v1_fromStr_32
    , v1_fromStr_8
    , v1_toStr_1024
    , v1_toStr_256
    , v1_toStr_32
    , v1_toStr_4096
    , v1_toStr_8
    , v2_fromStrU_1024
    , v2_fromStrU_256
    , v2_fromStrU_32
    , v2_fromStr_1024
    , v2_fromStr_256
    , v2_fromStr_32
    , v2_toStr_1024
    , v2_toStr_256
    , v2_toStr_32
    )

{-| Benchmark functions for Hex encoding/decoding.

V1 calls the main `src/Hex.elm` module (current implementation).
V2 is a copy of V1 (baseline for comparison).


## toString benchmarks

    elm - bench -f Bench.v1_toStr_1024 -f Bench.v2_toStr_1024 "()"


## fromString benchmarks

    elm - bench -f Bench.v1_fromStr_1024 -f Bench.v2_fromStr_1024 "()"


## fromStringUnchecked benchmarks

    elm - bench -f Bench.v1_fromStrU_1024 -f Bench.v2_fromStrU_1024 "()"

-}

import Bytes exposing (Bytes)
import Bytes.Encode as Encode
import Hex
import Hex.V2



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
    Hex.toString bytes8


hex32 : String
hex32 =
    Hex.toString bytes32


hex256 : String
hex256 =
    Hex.toString bytes256


hex1024 : String
hex1024 =
    Hex.toString bytes1024



-- V1 benchmarks (current implementation)


v1_toStr_8 : () -> String
v1_toStr_8 () =
    Hex.toString bytes8


v1_toStr_32 : () -> String
v1_toStr_32 () =
    Hex.toString bytes32


v1_toStr_256 : () -> String
v1_toStr_256 () =
    Hex.toString bytes256


v1_toStr_1024 : () -> String
v1_toStr_1024 () =
    Hex.toString bytes1024


v1_toStr_4096 : () -> String
v1_toStr_4096 () =
    Hex.toString bytes4096


v1_fromStr_8 : () -> Maybe Bytes
v1_fromStr_8 () =
    Hex.fromString hex8


v1_fromStr_32 : () -> Maybe Bytes
v1_fromStr_32 () =
    Hex.fromString hex32


v1_fromStr_256 : () -> Maybe Bytes
v1_fromStr_256 () =
    Hex.fromString hex256


v1_fromStr_1024 : () -> Maybe Bytes
v1_fromStr_1024 () =
    Hex.fromString hex1024


v1_fromStrU_32 : () -> Bytes
v1_fromStrU_32 () =
    Hex.fromStringUnchecked hex32


v1_fromStrU_256 : () -> Bytes
v1_fromStrU_256 () =
    Hex.fromStringUnchecked hex256


v1_fromStrU_1024 : () -> Bytes
v1_fromStrU_1024 () =
    Hex.fromStringUnchecked hex1024



-- V2 benchmarks (baseline copy)


v2_toStr_32 : () -> String
v2_toStr_32 () =
    Hex.V2.toString bytes32


v2_toStr_256 : () -> String
v2_toStr_256 () =
    Hex.V2.toString bytes256


v2_toStr_1024 : () -> String
v2_toStr_1024 () =
    Hex.V2.toString bytes1024


v2_fromStr_32 : () -> Maybe Bytes
v2_fromStr_32 () =
    Hex.V2.fromString hex32


v2_fromStr_256 : () -> Maybe Bytes
v2_fromStr_256 () =
    Hex.V2.fromString hex256


v2_fromStr_1024 : () -> Maybe Bytes
v2_fromStr_1024 () =
    Hex.V2.fromString hex1024


v2_fromStrU_32 : () -> Bytes
v2_fromStrU_32 () =
    Hex.V2.fromStringUnchecked hex32


v2_fromStrU_256 : () -> Bytes
v2_fromStrU_256 () =
    Hex.V2.fromStringUnchecked hex256


v2_fromStrU_1024 : () -> Bytes
v2_fromStrU_1024 () =
    Hex.V2.fromStringUnchecked hex1024
