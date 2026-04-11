module Bench exposing
    ( fromStr_v1_1024
    , fromStr_v1_256
    , fromStr_v1_32
    , fromStr_v2_1024
    , fromStr_v2_256
    , fromStr_v2_32
    , fromStr_v3_1024
    , fromStr_v3_256
    , fromStr_v3_32
    , fromStr_v4_1024
    , fromStr_v4_256
    , fromStr_v4_32
    , fromStr_v5_1024
    , fromStr_v5_256
    , fromStr_v5_32
    , fromStr_v6_1024
    , fromStr_v6_256
    , fromStr_v6_32
    , fromStr_v7_1024
    , fromStr_v7_256
    , fromStr_v7_32
    , fromStr_v8_1024
    , fromStr_v8_256
    , fromStr_v8_32
    , fromStr_v9_1024
    , fromStr_v9_256
    , fromStr_v9_32
    , fromStr_v11_1024
    , fromStr_v11_256
    , fromStr_v11_32
    , fromStr_v12_1024
    , fromStr_v12_256
    , fromStr_v12_32
    , fromStr_v13_1024
    , fromStr_v13_256
    , fromStr_v13_32
    , fromStr_v14_1024
    , fromStr_v14_256
    , fromStr_v14_32
    , fromStr_v15_1024
    , fromStr_v15_256
    , fromStr_v15_32
    , fromStr_v16_1024
    , fromStr_v16_256
    , fromStr_v16_32
    , fromStr_v17_1024
    , fromStr_v17_256
    , fromStr_v17_32
    , fromStr_v18_1024
    , fromStr_v18_256
    , fromStr_v18_32
    , fromStr_v19_1024
    , fromStr_v19_256
    , fromStr_v19_32
    , toStr_v10_1024
    , toStr_v10_256
    , toStr_v10_32
    , toStr_v1_1024
    , toStr_v1_256
    , toStr_v1_32
    , toStr_v2_1024
    , toStr_v2_256
    , toStr_v2_32
    , toStr_v3_1024
    , toStr_v3_256
    , toStr_v3_32
    , toStr_v4_1024
    , toStr_v4_256
    , toStr_v4_32
    , toStr_v5_1024
    , toStr_v5_256
    , toStr_v5_32
    , toStr_v6_1024
    , toStr_v6_256
    , toStr_v6_32
    , toStr_v7_1024
    , toStr_v7_256
    , toStr_v7_32
    , toStr_v8_1024
    , toStr_v8_256
    , toStr_v8_32
    , toStr_v9_1024
    , toStr_v9_256
    , toStr_v9_32
    , toStr_v20_1024
    , toStr_v20_256
    , toStr_v20_32
    , toStr_v21_1024
    , toStr_v21_256
    , toStr_v21_32
    , toStr_v22_1024
    , toStr_v22_256
    , toStr_v22_32
    , toStr_v23_1024
    , toStr_v23_256
    , toStr_v23_32
    , toStr_v24_1024
    , toStr_v24_256
    , toStr_v24_32
    , toStr_v25_1024
    , toStr_v25_256
    , toStr_v25_32
    )

{-| Benchmark functions for Hex encoding/decoding.


## toString benchmarks

    elm - bench -f Bench.toStr_v3_256 -f Bench.toStr_v4_256 -f Bench.toStr_v5_256 "()"

    elm - bench -f Bench.toStr_v3_1024 -f Bench.toStr_v4_1024 -f Bench.toStr_v5_1024 "()"


## fromString benchmarks

    elm - bench -f Bench.fromStr_v1_256 -f Bench.fromStr_v4_256 -f Bench.fromStr_v5_256 "()"

    elm - bench -f Bench.fromStr_v1_1024 -f Bench.fromStr_v4_1024 -f Bench.fromStr_v5_1024 "()"

-}

import Bytes exposing (Bytes)
import Bytes.Encode as Encode
import Hex
import Hex.V10
import Hex.V2
import Hex.V3
import Hex.V4
import Hex.V5
import Hex.V6
import Hex.V7
import Hex.V8
import Hex.V11
import Hex.V15
import Hex.V16
import Hex.V17
import Hex.V18
import Hex.V19
import Hex.V12
import Hex.V13
import Hex.V14
import Hex.V20
import Hex.V21
import Hex.V22
import Hex.V23
import Hex.V24
import Hex.V25
import Hex.V9



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


{-| V11 fromString on 32 bytes (64 hex chars). No validation, branchless, String.slice.
-}
fromStr_v11_32 : () -> Maybe Bytes
fromStr_v11_32 () =
    Just (Hex.V11.fromString hex32)


{-| V11 fromString on 256 bytes (512 hex chars).
-}
fromStr_v11_256 : () -> Maybe Bytes
fromStr_v11_256 () =
    Just (Hex.V11.fromString hex256)


{-| V11 fromString on 1024 bytes (2048 hex chars).
-}
fromStr_v11_1024 : () -> Maybe Bytes
fromStr_v11_1024 () =
    Just (Hex.V11.fromString hex1024)


{-| V12 fromString on 32 bytes (64 hex chars). No validation, branchless, String.toList.
-}
fromStr_v12_32 : () -> Maybe Bytes
fromStr_v12_32 () =
    Just (Hex.V12.fromString hex32)


{-| V12 fromString on 256 bytes (512 hex chars).
-}
fromStr_v12_256 : () -> Maybe Bytes
fromStr_v12_256 () =
    Just (Hex.V12.fromString hex256)


{-| V12 fromString on 1024 bytes (2048 hex chars).
-}
fromStr_v12_1024 : () -> Maybe Bytes
fromStr_v12_1024 () =
    Just (Hex.V12.fromString hex1024)


{-| V13 fromString on 32 bytes (64 hex chars). Bytes intermediate, map5, Int16 output.
-}
fromStr_v13_32 : () -> Maybe Bytes
fromStr_v13_32 () =
    Just (Hex.V13.fromString hex32)


{-| V13 fromString on 256 bytes (512 hex chars).
-}
fromStr_v13_256 : () -> Maybe Bytes
fromStr_v13_256 () =
    Just (Hex.V13.fromString hex256)


{-| V13 fromString on 1024 bytes (2048 hex chars).
-}
fromStr_v13_1024 : () -> Maybe Bytes
fromStr_v13_1024 () =
    Just (Hex.V13.fromString hex1024)


{-| V14 fromString on 32 bytes (64 hex chars). Bytes intermediate, map5-of-map2, Int32 output.
-}
fromStr_v14_32 : () -> Maybe Bytes
fromStr_v14_32 () =
    Just (Hex.V14.fromString hex32)


{-| V14 fromString on 256 bytes (512 hex chars).
-}
fromStr_v14_256 : () -> Maybe Bytes
fromStr_v14_256 () =
    Just (Hex.V14.fromString hex256)


{-| V14 fromString on 1024 bytes (2048 hex chars).
-}
fromStr_v14_1024 : () -> Maybe Bytes
fromStr_v14_1024 () =
    Just (Hex.V14.fromString hex1024)


{-| V15 fromString on 32 bytes (64 hex chars). Direct pattern match on hex pairs.
-}
fromStr_v15_32 : () -> Maybe Bytes
fromStr_v15_32 () =
    Just (Hex.V15.fromString hex32)


{-| V15 fromString on 256 bytes (512 hex chars).
-}
fromStr_v15_256 : () -> Maybe Bytes
fromStr_v15_256 () =
    Just (Hex.V15.fromString hex256)


{-| V15 fromString on 1024 bytes (2048 hex chars).
-}
fromStr_v15_1024 : () -> Maybe Bytes
fromStr_v15_1024 () =
    Just (Hex.V15.fromString hex1024)


{-| V16 fromString on 32 bytes. Slice pair + double uncons.
-}
fromStr_v16_32 : () -> Maybe Bytes
fromStr_v16_32 () =
    Just (Hex.V16.fromString hex32)


{-| V16 fromString on 256 bytes.
-}
fromStr_v16_256 : () -> Maybe Bytes
fromStr_v16_256 () =
    Just (Hex.V16.fromString hex256)


{-| V16 fromString on 1024 bytes.
-}
fromStr_v16_1024 : () -> Maybe Bytes
fromStr_v16_1024 () =
    Just (Hex.V16.fromString hex1024)


{-| V17 fromString on 32 bytes. Dict lookup.
-}
fromStr_v17_32 : () -> Maybe Bytes
fromStr_v17_32 () =
    Just (Hex.V17.fromString hex32)


{-| V17 fromString on 256 bytes.
-}
fromStr_v17_256 : () -> Maybe Bytes
fromStr_v17_256 () =
    Just (Hex.V17.fromString hex256)


{-| V17 fromString on 1024 bytes.
-}
fromStr_v17_1024 : () -> Maybe Bytes
fromStr_v17_1024 () =
    Just (Hex.V17.fromString hex1024)


{-| V18 fromString on 32 bytes. == 0 instead of <= 0.
-}
fromStr_v18_32 : () -> Maybe Bytes
fromStr_v18_32 () =
    Just (Hex.V18.fromString hex32)


{-| V18 fromString on 256 bytes.
-}
fromStr_v18_256 : () -> Maybe Bytes
fromStr_v18_256 () =
    Just (Hex.V18.fromString hex256)


{-| V18 fromString on 1024 bytes.
-}
fromStr_v18_1024 : () -> Maybe Bytes
fromStr_v18_1024 () =
    Just (Hex.V18.fromString hex1024)


fromStr_v19_32 : () -> Maybe Bytes
fromStr_v19_32 () =
    Just (Hex.V19.fromString hex32)


fromStr_v19_256 : () -> Maybe Bytes
fromStr_v19_256 () =
    Just (Hex.V19.fromString hex256)


fromStr_v19_1024 : () -> Maybe Bytes
fromStr_v19_1024 () =
    Just (Hex.V19.fromString hex1024)



-- toString V20-V22 benchmarks


{-| V20 toString on 32 bytes. Record literal instead of EncState constructor.
-}
toStr_v20_32 : () -> String
toStr_v20_32 () =
    Hex.V20.toString bytes32


{-| V20 toString on 256 bytes.
-}
toStr_v20_256 : () -> String
toStr_v20_256 () =
    Hex.V20.toString bytes256


{-| V20 toString on 1024 bytes.
-}
toStr_v20_1024 : () -> String
toStr_v20_1024 () =
    Hex.V20.toString bytes1024


{-| V21 toString on 32 bytes. Push individual byte strings, no ++ per word.
-}
toStr_v21_32 : () -> String
toStr_v21_32 () =
    Hex.V21.toString bytes32


{-| V21 toString on 256 bytes.
-}
toStr_v21_256 : () -> String
toStr_v21_256 () =
    Hex.V21.toString bytes256


{-| V21 toString on 1024 bytes.
-}
toStr_v21_1024 : () -> String
toStr_v21_1024 () =
    Hex.V21.toString bytes1024


{-| V22 toString on 32 bytes. uint16 lookup table (65536 entries).
-}
toStr_v22_32 : () -> String
toStr_v22_32 () =
    Hex.V22.toString bytes32


{-| V22 toString on 256 bytes.
-}
toStr_v22_256 : () -> String
toStr_v22_256 () =
    Hex.V22.toString bytes256


{-| V22 toString on 1024 bytes.
-}
toStr_v22_1024 : () -> String
toStr_v22_1024 () =
    Hex.V22.toString bytes1024


{-| V23 toString on 32 bytes. String accumulator, no List.reverse/String.concat.
-}
toStr_v23_32 : () -> String
toStr_v23_32 () =
    Hex.V23.toString bytes32


{-| V23 toString on 256 bytes.
-}
toStr_v23_256 : () -> String
toStr_v23_256 () =
    Hex.V23.toString bytes256


{-| V23 toString on 1024 bytes.
-}
toStr_v23_1024 : () -> String
toStr_v23_1024 () =
    Hex.V23.toString bytes1024


{-| V24 toString on 32 bytes. Two-phase: map5 word loop + separate byte loop.
-}
toStr_v24_32 : () -> String
toStr_v24_32 () =
    Hex.V24.toString bytes32


{-| V24 toString on 256 bytes.
-}
toStr_v24_256 : () -> String
toStr_v24_256 () =
    Hex.V24.toString bytes256


{-| V24 toString on 1024 bytes.
-}
toStr_v24_1024 : () -> String
toStr_v24_1024 () =
    Hex.V24.toString bytes1024


{-| V25 toString on 32 bytes. Single-word loop, no map5.
-}
toStr_v25_32 : () -> String
toStr_v25_32 () =
    Hex.V25.toString bytes32


{-| V25 toString on 256 bytes.
-}
toStr_v25_256 : () -> String
toStr_v25_256 () =
    Hex.V25.toString bytes256


{-| V25 toString on 1024 bytes.
-}
toStr_v25_1024 : () -> String
toStr_v25_1024 () =
    Hex.V25.toString bytes1024
