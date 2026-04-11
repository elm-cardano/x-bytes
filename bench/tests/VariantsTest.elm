module VariantsTest exposing (suite)

{-| Verify that V2 produces the same output as V1 (Hex).
-}

import Bytes exposing (Bytes)
import Bytes.Encode as Encode
import Expect
import Hex
import Hex.V2
import Test exposing (..)


suite : Test
suite =
    describe "V2 equivalence with V1"
        [ describe "fromBytes"
            (List.map
                (\n ->
                    test (String.fromInt n ++ "B") <|
                        \_ ->
                            Hex.V2.fromBytes (makeBytes n)
                                |> Expect.equal (Hex.fromBytes (makeBytes n))
                )
                testSizes
            )
        , describe "toBytes"
            (List.map
                (\hex ->
                    test (labelFor hex) <|
                        \_ ->
                            Maybe.map Hex.fromBytes (Hex.V2.toBytes hex)
                                |> Expect.equal (Maybe.map Hex.fromBytes (Hex.toBytes hex))
                )
                testHexStrings
            )
        , describe "toBytesUnchecked"
            (List.map
                (\hex ->
                    test (labelFor hex) <|
                        \_ ->
                            Hex.V2.toBytesUnchecked hex
                                |> Hex.fromBytes
                                |> Expect.equal (Hex.fromBytes (Hex.toBytesUnchecked hex))
                )
                lowercaseHexStrings
            )
        ]



-- Test data


testSizes : List Int
testSizes =
    [ 0, 1, 2, 3, 4, 5, 7, 8, 16, 32, 64, 128, 256, 512, 1024 ]


testHexStrings : List String
testHexStrings =
    [ ""
    , "00"
    , "ff"
    , "FF"
    , "deadbeef"
    , "DEADBEEF"
    , "DeAdBeEf"
    , "CaFe"
    , "0123456789abcdef"
    , "0123456789ABCDEF"
    , Hex.fromBytes (makeBytes 8)
    , Hex.fromBytes (makeBytes 32)
    , Hex.fromBytes (makeBytes 256)
    , Hex.fromBytes (makeBytes 1024)
    , String.toUpper (Hex.fromBytes (makeBytes 32))

    -- Invalid inputs (should all return Nothing)
    , "abc"
    , "zz"
    , "0g"
    , "0 "
    , "@0"
    , "`0"
    , "GG"
    , "x"
    ]


lowercaseHexStrings : List String
lowercaseHexStrings =
    [ ""
    , "00"
    , "ff"
    , "deadbeef"
    , "0123456789abcdef"
    , Hex.fromBytes (makeBytes 8)
    , Hex.fromBytes (makeBytes 32)
    , Hex.fromBytes (makeBytes 256)
    , Hex.fromBytes (makeBytes 1024)
    ]


makeBytes : Int -> Bytes
makeBytes n =
    Encode.encode
        (Encode.sequence
            (List.map (\i -> Encode.unsignedInt8 (modBy 256 i)) (List.range 0 (n - 1)))
        )


labelFor : String -> String
labelFor hex =
    let
        len =
            String.length hex
    in
    if len <= 20 then
        "\"" ++ hex ++ "\""

    else
        "\"" ++ String.left 8 hex ++ "..." ++ String.right 4 hex ++ "\" (" ++ String.fromInt (len // 2) ++ " bytes)"
