module Bench exposing
    ( toStr_v1_32, toStr_v1_256, toStr_v1_1024
    , toStr_v2_32, toStr_v2_256, toStr_v2_1024
    , toStr_v3_32, toStr_v3_256, toStr_v3_1024
    , toStr_v4_32, toStr_v4_256, toStr_v4_1024
    , toStr_v5_32, toStr_v5_256, toStr_v5_1024
    , fromStr_v1_32, fromStr_v1_256, fromStr_v1_1024
    , fromStr_v2_32, fromStr_v2_256, fromStr_v2_1024
    , fromStr_v3_32, fromStr_v3_256, fromStr_v3_1024
    , fromStr_v4_32, fromStr_v4_256, fromStr_v4_1024
    , fromStr_v5_32, fromStr_v5_256, fromStr_v5_1024
    , toStr_v6_32, toStr_v6_256, toStr_v6_1024
    , toStr_v7_32, toStr_v7_256, toStr_v7_1024
    , fromStr_v6_32, fromStr_v6_256, fromStr_v6_1024
    , fromStr_v7_32, fromStr_v7_256, fromStr_v7_1024
    , toStr_v8_32, toStr_v8_256, toStr_v8_1024
    , fromStr_v8_32, fromStr_v8_256, fromStr_v8_1024
    , toStr_v9_32, toStr_v9_256, toStr_v9_1024
    , fromStr_v9_32, fromStr_v9_256, fromStr_v9_1024
    , toStr_v10_32, toStr_v10_256, toStr_v10_1024
    )

{-| Benchmark functions for Hex encoding/decoding.

## toString benchmarks

    elm-bench -f Bench.toStr_v3_256 -f Bench.toStr_v4_256 -f Bench.toStr_v5_256 "()"
    elm-bench -f Bench.toStr_v3_1024 -f Bench.toStr_v4_1024 -f Bench.toStr_v5_1024 "()"

## fromString benchmarks

    elm-bench -f Bench.fromStr_v1_256 -f Bench.fromStr_v4_256 -f Bench.fromStr_v5_256 "()"
    elm-bench -f Bench.fromStr_v1_1024 -f Bench.fromStr_v4_1024 -f Bench.fromStr_v5_1024 "()"

-}

import Bytes exposing (Bytes)
import Bytes.Encode as Encode
import Hex
import Hex.V2
import Hex.V3
import Hex.V4
import Hex.V5
import Hex.V6
import Hex.V7
import Hex.V8
import Hex.V9
import Hex.V10



-- Test data


makeBytes : Int -> Bytes
makeBytes n =
    Encode.encode
        (Encode.sequence
            (List.map (\i -> Encode.unsignedInt8 (modBy 256 i)) (List.range 0 (n - 1)))
        )


bytes32 : Bytes
bytes32 =
    makeBytes 32


bytes256 : Bytes
bytes256 =
    makeBytes 256


bytes1024 : Bytes
bytes1024 =
    makeBytes 1024


hex32 : String
hex32 =
    Hex.toString bytes32


hex256 : String
hex256 =
    Hex.toString bytes256


hex1024 : String
hex1024 =
    Hex.toString bytes1024



-- toString benchmarks


{-| V1 toString on 32 bytes.
-}
toStr_v1_32 : () -> String
toStr_v1_32 () =
    Hex.toString bytes32


{-| V1 toString on 256 bytes.
-}
toStr_v1_256 : () -> String
toStr_v1_256 () =
    Hex.toString bytes256


{-| V1 toString on 1024 bytes.
-}
toStr_v1_1024 : () -> String
toStr_v1_1024 () =
    Hex.toString bytes1024


{-| V2 toString on 32 bytes.
-}
toStr_v2_32 : () -> String
toStr_v2_32 () =
    Hex.V2.toString bytes32


{-| V2 toString on 256 bytes.
-}
toStr_v2_256 : () -> String
toStr_v2_256 () =
    Hex.V2.toString bytes256


{-| V2 toString on 1024 bytes.
-}
toStr_v2_1024 : () -> String
toStr_v2_1024 () =
    Hex.V2.toString bytes1024


{-| V3 toString on 32 bytes.
-}
toStr_v3_32 : () -> String
toStr_v3_32 () =
    Hex.V3.toString bytes32


{-| V3 toString on 256 bytes.
-}
toStr_v3_256 : () -> String
toStr_v3_256 () =
    Hex.V3.toString bytes256


{-| V3 toString on 1024 bytes.
-}
toStr_v3_1024 : () -> String
toStr_v3_1024 () =
    Hex.V3.toString bytes1024


{-| V4 toString on 32 bytes.
-}
toStr_v4_32 : () -> String
toStr_v4_32 () =
    Hex.V4.toString bytes32


{-| V4 toString on 256 bytes.
-}
toStr_v4_256 : () -> String
toStr_v4_256 () =
    Hex.V4.toString bytes256


{-| V4 toString on 1024 bytes.
-}
toStr_v4_1024 : () -> String
toStr_v4_1024 () =
    Hex.V4.toString bytes1024


{-| V5 toString on 32 bytes.
-}
toStr_v5_32 : () -> String
toStr_v5_32 () =
    Hex.V5.toString bytes32


{-| V5 toString on 256 bytes.
-}
toStr_v5_256 : () -> String
toStr_v5_256 () =
    Hex.V5.toString bytes256


{-| V5 toString on 1024 bytes.
-}
toStr_v5_1024 : () -> String
toStr_v5_1024 () =
    Hex.V5.toString bytes1024



{-| V6 toString on 32 bytes.
-}
toStr_v6_32 : () -> String
toStr_v6_32 () =
    Hex.V6.toString bytes32


{-| V6 toString on 256 bytes.
-}
toStr_v6_256 : () -> String
toStr_v6_256 () =
    Hex.V6.toString bytes256


{-| V6 toString on 1024 bytes.
-}
toStr_v6_1024 : () -> String
toStr_v6_1024 () =
    Hex.V6.toString bytes1024


{-| V7 toString on 32 bytes.
-}
toStr_v7_32 : () -> String
toStr_v7_32 () =
    Hex.V7.toString bytes32


{-| V7 toString on 256 bytes.
-}
toStr_v7_256 : () -> String
toStr_v7_256 () =
    Hex.V7.toString bytes256


{-| V7 toString on 1024 bytes.
-}
toStr_v7_1024 : () -> String
toStr_v7_1024 () =
    Hex.V7.toString bytes1024



{-| V8 toString on 32 bytes.
-}
toStr_v8_32 : () -> String
toStr_v8_32 () =
    Hex.V8.toString bytes32


{-| V8 toString on 256 bytes.
-}
toStr_v8_256 : () -> String
toStr_v8_256 () =
    Hex.V8.toString bytes256


{-| V8 toString on 1024 bytes.
-}
toStr_v8_1024 : () -> String
toStr_v8_1024 () =
    Hex.V8.toString bytes1024



{-| V9 toString on 32 bytes.
-}
toStr_v9_32 : () -> String
toStr_v9_32 () =
    Hex.V9.toString bytes32


{-| V9 toString on 256 bytes.
-}
toStr_v9_256 : () -> String
toStr_v9_256 () =
    Hex.V9.toString bytes256


{-| V9 toString on 1024 bytes.
-}
toStr_v9_1024 : () -> String
toStr_v9_1024 () =
    Hex.V9.toString bytes1024


{-| V10 toString on 32 bytes.
-}
toStr_v10_32 : () -> String
toStr_v10_32 () =
    Hex.V10.toString bytes32


{-| V10 toString on 256 bytes.
-}
toStr_v10_256 : () -> String
toStr_v10_256 () =
    Hex.V10.toString bytes256


{-| V10 toString on 1024 bytes.
-}
toStr_v10_1024 : () -> String
toStr_v10_1024 () =
    Hex.V10.toString bytes1024



-- fromString benchmarks


{-| V1 fromString on 32 bytes (64 hex chars).
-}
fromStr_v1_32 : () -> Maybe Bytes
fromStr_v1_32 () =
    Hex.fromString hex32


{-| V1 fromString on 256 bytes (512 hex chars).
-}
fromStr_v1_256 : () -> Maybe Bytes
fromStr_v1_256 () =
    Hex.fromString hex256


{-| V1 fromString on 1024 bytes (2048 hex chars).
-}
fromStr_v1_1024 : () -> Maybe Bytes
fromStr_v1_1024 () =
    Hex.fromString hex1024


{-| V2 fromString on 32 bytes (64 hex chars).
-}
fromStr_v2_32 : () -> Maybe Bytes
fromStr_v2_32 () =
    Hex.V2.fromString hex32


{-| V2 fromString on 256 bytes (512 hex chars).
-}
fromStr_v2_256 : () -> Maybe Bytes
fromStr_v2_256 () =
    Hex.V2.fromString hex256


{-| V2 fromString on 1024 bytes (2048 hex chars).
-}
fromStr_v2_1024 : () -> Maybe Bytes
fromStr_v2_1024 () =
    Hex.V2.fromString hex1024


{-| V3 fromString on 32 bytes (64 hex chars).
-}
fromStr_v3_32 : () -> Maybe Bytes
fromStr_v3_32 () =
    Hex.V3.fromString hex32


{-| V3 fromString on 256 bytes (512 hex chars).
-}
fromStr_v3_256 : () -> Maybe Bytes
fromStr_v3_256 () =
    Hex.V3.fromString hex256


{-| V3 fromString on 1024 bytes (2048 hex chars).
-}
fromStr_v3_1024 : () -> Maybe Bytes
fromStr_v3_1024 () =
    Hex.V3.fromString hex1024


{-| V4 fromString on 32 bytes (64 hex chars).
-}
fromStr_v4_32 : () -> Maybe Bytes
fromStr_v4_32 () =
    Hex.V4.fromString hex32


{-| V4 fromString on 256 bytes (512 hex chars).
-}
fromStr_v4_256 : () -> Maybe Bytes
fromStr_v4_256 () =
    Hex.V4.fromString hex256


{-| V4 fromString on 1024 bytes (2048 hex chars).
-}
fromStr_v4_1024 : () -> Maybe Bytes
fromStr_v4_1024 () =
    Hex.V4.fromString hex1024


{-| V5 fromString on 32 bytes (64 hex chars).
-}
fromStr_v5_32 : () -> Maybe Bytes
fromStr_v5_32 () =
    Hex.V5.fromString hex32


{-| V5 fromString on 256 bytes (512 hex chars).
-}
fromStr_v5_256 : () -> Maybe Bytes
fromStr_v5_256 () =
    Hex.V5.fromString hex256


{-| V5 fromString on 1024 bytes (2048 hex chars).
-}
fromStr_v5_1024 : () -> Maybe Bytes
fromStr_v5_1024 () =
    Hex.V5.fromString hex1024


{-| V6 fromString on 32 bytes (64 hex chars).
-}
fromStr_v6_32 : () -> Maybe Bytes
fromStr_v6_32 () =
    Hex.V6.fromString hex32


{-| V6 fromString on 256 bytes (512 hex chars).
-}
fromStr_v6_256 : () -> Maybe Bytes
fromStr_v6_256 () =
    Hex.V6.fromString hex256


{-| V6 fromString on 1024 bytes (2048 hex chars).
-}
fromStr_v6_1024 : () -> Maybe Bytes
fromStr_v6_1024 () =
    Hex.V6.fromString hex1024


{-| V7 fromString on 32 bytes (64 hex chars).
-}
fromStr_v7_32 : () -> Maybe Bytes
fromStr_v7_32 () =
    Hex.V7.fromString hex32


{-| V7 fromString on 256 bytes (512 hex chars).
-}
fromStr_v7_256 : () -> Maybe Bytes
fromStr_v7_256 () =
    Hex.V7.fromString hex256


{-| V7 fromString on 1024 bytes (2048 hex chars).
-}
fromStr_v7_1024 : () -> Maybe Bytes
fromStr_v7_1024 () =
    Hex.V7.fromString hex1024


{-| V8 fromString on 32 bytes (64 hex chars).
-}
fromStr_v8_32 : () -> Maybe Bytes
fromStr_v8_32 () =
    Hex.V8.fromString hex32


{-| V8 fromString on 256 bytes (512 hex chars).
-}
fromStr_v8_256 : () -> Maybe Bytes
fromStr_v8_256 () =
    Hex.V8.fromString hex256


{-| V8 fromString on 1024 bytes (2048 hex chars).
-}
fromStr_v8_1024 : () -> Maybe Bytes
fromStr_v8_1024 () =
    Hex.V8.fromString hex1024


{-| V9 fromString on 32 bytes (64 hex chars).
-}
fromStr_v9_32 : () -> Maybe Bytes
fromStr_v9_32 () =
    Hex.V9.fromString hex32


{-| V9 fromString on 256 bytes (512 hex chars).
-}
fromStr_v9_256 : () -> Maybe Bytes
fromStr_v9_256 () =
    Hex.V9.fromString hex256


{-| V9 fromString on 1024 bytes (2048 hex chars).
-}
fromStr_v9_1024 : () -> Maybe Bytes
fromStr_v9_1024 () =
    Hex.V9.fromString hex1024
