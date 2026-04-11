module Bench exposing
    ( v1_fromStr_1024
    , v1_fromStr_256
    , v1_fromStr_32
    , v1_fromStr_8
    , v1_fromStrU_1024
    , v1_fromStrU_256
    , v1_fromStrU_32
    , v1_toStr_1024
    , v1_toStr_256
    , v1_toStr_32
    , v1_toStr_4096
    , v1_toStr_8
    , v2_fromStr_1024
    , v2_fromStr_256
    , v2_fromStr_32
    , v2_fromStrU_1024
    , v2_fromStrU_256
    , v2_fromStrU_32
    , v2_toStr_1024
    , v2_toStr_256
    , v2_toStr_32
    , v3_toStr_1024
    , v3_toStr_256
    , v3_toStr_32
    , v3_toStr_4096
    , v3_toStr_8
    , v4_toStr_1024
    , v4_toStr_256
    , v4_toStr_32
    , v5_fromStr_1024
    , v5_fromStr_256
    , v5_fromStr_32
    , v5_fromStr_8
    , v6_fromStr_1024
    , v6_fromStr_256
    , v6_fromStr_32
    , v6_fromStrU_1024
    , v6_fromStrU_256
    , v6_fromStrU_32
    )

{-| Benchmark functions for Hex encoding/decoding.

V1 calls the main `src/Hex.elm` module (final optimized implementation).
V2 is a copy of V1 (baseline for comparison).
V3: Int case switch table for toString (replaces Array.get lookup).
V4: Branchless nibble→char computation for toString.
V5: Branchless or-0x20 validation for fromString.
V6: Backward iteration (no List.reverse) for fromString/fromStringUnchecked.


## toString benchmarks

    elm-bench -f Bench.v1_toStr_1024 -f Bench.v3_toStr_1024 "()"
    elm-bench -f Bench.v1_toStr_1024 -f Bench.v4_toStr_1024 "()"


## fromString benchmarks

    elm-bench -f Bench.v1_fromStr_1024 -f Bench.v5_fromStr_1024 "()"
    elm-bench -f Bench.v1_fromStr_1024 -f Bench.v6_fromStr_1024 "()"


## fromStringUnchecked benchmarks

    elm-bench -f Bench.v1_fromStrU_1024 -f Bench.v6_fromStrU_1024 "()"

-}

import Bytes exposing (Bytes)
import Bytes.Encode as Encode
import Hex
import Hex.V2
import Hex.V3
import Hex.V4
import Hex.V5
import Hex.V6



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



-- V1 benchmarks (final optimized)


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



-- V3 benchmarks (Int case switch for toString)


v3_toStr_8 : () -> String
v3_toStr_8 () =
    Hex.V3.toString bytes8


v3_toStr_32 : () -> String
v3_toStr_32 () =
    Hex.V3.toString bytes32


v3_toStr_256 : () -> String
v3_toStr_256 () =
    Hex.V3.toString bytes256


v3_toStr_1024 : () -> String
v3_toStr_1024 () =
    Hex.V3.toString bytes1024


v3_toStr_4096 : () -> String
v3_toStr_4096 () =
    Hex.V3.toString bytes4096



-- V4 benchmarks (branchless nibble for toString)


v4_toStr_32 : () -> String
v4_toStr_32 () =
    Hex.V4.toString bytes32


v4_toStr_256 : () -> String
v4_toStr_256 () =
    Hex.V4.toString bytes256


v4_toStr_1024 : () -> String
v4_toStr_1024 () =
    Hex.V4.toString bytes1024



-- V5 benchmarks (branchless or-0x20 for fromString)


v5_fromStr_8 : () -> Maybe Bytes
v5_fromStr_8 () =
    Hex.V5.fromString hex8


v5_fromStr_32 : () -> Maybe Bytes
v5_fromStr_32 () =
    Hex.V5.fromString hex32


v5_fromStr_256 : () -> Maybe Bytes
v5_fromStr_256 () =
    Hex.V5.fromString hex256


v5_fromStr_1024 : () -> Maybe Bytes
v5_fromStr_1024 () =
    Hex.V5.fromString hex1024




-- V6 benchmarks (backward iteration for fromString/fromStringUnchecked)


v6_fromStr_32 : () -> Maybe Bytes
v6_fromStr_32 () =
    Hex.V6.fromString hex32


v6_fromStr_256 : () -> Maybe Bytes
v6_fromStr_256 () =
    Hex.V6.fromString hex256


v6_fromStr_1024 : () -> Maybe Bytes
v6_fromStr_1024 () =
    Hex.V6.fromString hex1024


v6_fromStrU_32 : () -> Bytes
v6_fromStrU_32 () =
    Hex.V6.fromStringUnchecked hex32


v6_fromStrU_256 : () -> Bytes
v6_fromStrU_256 () =
    Hex.V6.fromStringUnchecked hex256


v6_fromStrU_1024 : () -> Bytes
v6_fromStrU_1024 () =
    Hex.V6.fromStringUnchecked hex1024
