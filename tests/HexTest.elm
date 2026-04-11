module HexTest exposing (suite)

import Bytes exposing (Bytes)
import Bytes.Decode as Decode
import Bytes.Encode as Encode
import Expect
import Hex
import Test exposing (..)


suite : Test
suite =
    describe "Hex"
        [ toStringTests
        , fromStringTests
        , fromStringUncheckedTests
        , roundTripTests
        ]



-- toString


toStringTests : Test
toStringTests =
    describe "toString"
        [ test "empty bytes" <|
            \_ ->
                Hex.toString (Encode.encode (Encode.sequence []))
                    |> Expect.equal ""
        , test "single byte 0x00" <|
            \_ ->
                Hex.toString (Encode.encode (Encode.unsignedInt8 0))
                    |> Expect.equal "00"
        , test "single byte 0xff" <|
            \_ ->
                Hex.toString (Encode.encode (Encode.unsignedInt8 255))
                    |> Expect.equal "ff"
        , test "single byte 0x0a" <|
            \_ ->
                Hex.toString (Encode.encode (Encode.unsignedInt8 10))
                    |> Expect.equal "0a"
        , test "two bytes" <|
            \_ ->
                Hex.toString (Encode.encode (Encode.sequence [ Encode.unsignedInt8 0xDE, Encode.unsignedInt8 0xAD ]))
                    |> Expect.equal "dead"
        , test "four bytes (one word)" <|
            \_ ->
                Hex.toString (Encode.encode (Encode.unsignedInt32 Bytes.BE 0xDEADBEEF))
                    |> Expect.equal "deadbeef"
        , test "output is lowercase" <|
            \_ ->
                Hex.toString (Encode.encode (Encode.unsignedInt32 Bytes.BE 0xABCDEF01))
                    |> Expect.equal "abcdef01"
        , test "all byte values 0-255" <|
            \_ ->
                let
                    bytes =
                        Encode.encode (Encode.sequence (List.map (\i -> Encode.unsignedInt8 i) (List.range 0 255)))

                    result =
                        Hex.toString bytes

                    expected =
                        String.join "" (List.map byteToHex (List.range 0 255))
                in
                Expect.equal expected result
        , test "5 bytes (remainder after word)" <|
            \_ ->
                Hex.toString (Encode.encode (Encode.sequence (List.map Encode.unsignedInt8 [ 0x01, 0x02, 0x03, 0x04, 0x05 ])))
                    |> Expect.equal "0102030405"
        , test "large input (1024 bytes)" <|
            \_ ->
                let
                    bytes =
                        makeBytes 1024

                    result =
                        Hex.toString bytes
                in
                Expect.equal (1024 * 2) (String.length result)
        ]



-- fromString


fromStringTests : Test
fromStringTests =
    describe "fromString"
        [ test "empty string" <|
            \_ ->
                Hex.fromString ""
                    |> Maybe.map Bytes.width
                    |> Expect.equal (Just 0)
        , test "lowercase ff" <|
            \_ ->
                Hex.fromString "ff"
                    |> Maybe.map Hex.toString
                    |> Expect.equal (Just "ff")
        , test "uppercase FF" <|
            \_ ->
                Hex.fromString "FF"
                    |> Maybe.map Hex.toString
                    |> Expect.equal (Just "ff")
        , test "mixed case DeAdBeEf" <|
            \_ ->
                Hex.fromString "DeAdBeEf"
                    |> Maybe.map Hex.toString
                    |> Expect.equal (Just "deadbeef")
        , test "all digits 0-9" <|
            \_ ->
                Hex.fromString "0123456789"
                    |> Maybe.map Hex.toString
                    |> Expect.equal (Just "0123456789")
        , test "all hex letters a-f" <|
            \_ ->
                Hex.fromString "aabbccddeeff"
                    |> Maybe.map Hex.toString
                    |> Expect.equal (Just "aabbccddeeff")
        , test "all hex letters A-F" <|
            \_ ->
                Hex.fromString "AABBCCDDEEFF"
                    |> Maybe.map Hex.toString
                    |> Expect.equal (Just "aabbccddeeff")
        , test "odd length returns Nothing" <|
            \_ ->
                Hex.fromString "abc"
                    |> Expect.equal Nothing
        , test "invalid char 'g' returns Nothing" <|
            \_ ->
                Hex.fromString "0g"
                    |> Expect.equal Nothing
        , test "invalid char 'z' returns Nothing" <|
            \_ ->
                Hex.fromString "zz"
                    |> Expect.equal Nothing
        , test "space returns Nothing" <|
            \_ ->
                Hex.fromString "0 "
                    |> Expect.equal Nothing
        , test "@ returns Nothing" <|
            \_ ->
                Hex.fromString "@0"
                    |> Expect.equal Nothing
        , test "backtick returns Nothing" <|
            \_ ->
                Hex.fromString "`0"
                    |> Expect.equal Nothing
        , test "G returns Nothing" <|
            \_ ->
                Hex.fromString "GG"
                    |> Expect.equal Nothing
        , test "single byte 00" <|
            \_ ->
                Hex.fromString "00"
                    |> Maybe.map Hex.toString
                    |> Expect.equal (Just "00")
        , test "large input round-trips" <|
            \_ ->
                let
                    hex =
                        Hex.toString (makeBytes 512)
                in
                Hex.fromString hex
                    |> Maybe.map Hex.toString
                    |> Expect.equal (Just hex)
        ]



-- fromStringUnchecked


fromStringUncheckedTests : Test
fromStringUncheckedTests =
    describe "fromStringUnchecked"
        [ test "empty string" <|
            \_ ->
                Hex.fromStringUnchecked ""
                    |> Bytes.width
                    |> Expect.equal 0
        , test "lowercase ff" <|
            \_ ->
                Hex.fromStringUnchecked "ff"
                    |> Hex.toString
                    |> Expect.equal "ff"
        , test "deadbeef" <|
            \_ ->
                Hex.fromStringUnchecked "deadbeef"
                    |> Hex.toString
                    |> Expect.equal "deadbeef"
        , test "all zeros" <|
            \_ ->
                Hex.fromStringUnchecked "0000000000"
                    |> Hex.toString
                    |> Expect.equal "0000000000"
        , test "large input round-trips" <|
            \_ ->
                let
                    hex =
                        Hex.toString (makeBytes 512)
                in
                Hex.fromStringUnchecked hex
                    |> Hex.toString
                    |> Expect.equal hex
        ]



-- Round-trip tests


roundTripTests : Test
roundTripTests =
    describe "round-trip"
        [ test "toString >> fromString for various sizes" <|
            \_ ->
                let
                    sizes =
                        [ 0, 1, 2, 3, 4, 5, 7, 8, 15, 16, 31, 32, 63, 64, 128, 256, 512, 1024 ]

                    allPass =
                        List.all
                            (\n ->
                                let
                                    bytes =
                                        makeBytes n

                                    hex =
                                        Hex.toString bytes
                                in
                                Hex.fromString hex
                                    |> Maybe.map Hex.toString
                                    |> (==) (Just hex)
                            )
                            sizes
                in
                Expect.equal True allPass
        , test "fromString >> toString >> fromString is stable" <|
            \_ ->
                let
                    hex =
                        "deadbeef0123456789abcdef"

                    result =
                        Hex.fromString hex
                            |> Maybe.map Hex.toString
                            |> Maybe.andThen Hex.fromString
                            |> Maybe.map Hex.toString
                in
                Expect.equal (Just hex) result
        ]



-- Helpers


makeBytes : Int -> Bytes
makeBytes n =
    Encode.encode
        (Encode.sequence
            (List.map (\i -> Encode.unsignedInt8 (modBy 256 i)) (List.range 0 (n - 1)))
        )


byteToHex : Int -> String
byteToHex n =
    let
        hi =
            n // 16

        lo =
            modBy 16 n
    in
    String.fromChar (nibbleToChar hi) ++ String.fromChar (nibbleToChar lo)


nibbleToChar : Int -> Char
nibbleToChar n =
    if n < 10 then
        Char.fromCode (n + 0x30)

    else
        Char.fromCode (n + 0x57)
