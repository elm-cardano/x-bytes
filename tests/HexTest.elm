module HexTest exposing (suite)

import Bytes exposing (Bytes)
import Bytes.Encode as Encode
import Expect
import Hex
import Test exposing (Test, describe, test)


suite : Test
suite =
    describe "Hex"
        [ fromBytesTests
        , toBytesTests
        , toBytesUncheckedTests
        , roundTripTests
        ]



-- toString


fromBytesTests : Test
fromBytesTests =
    describe "fromBytes"
        [ test "empty bytes" <|
            \_ ->
                Hex.fromBytes (Encode.encode (Encode.sequence []))
                    |> Expect.equal ""
        , test "single byte 0x00" <|
            \_ ->
                Hex.fromBytes (Encode.encode (Encode.unsignedInt8 0))
                    |> Expect.equal "00"
        , test "single byte 0xff" <|
            \_ ->
                Hex.fromBytes (Encode.encode (Encode.unsignedInt8 255))
                    |> Expect.equal "ff"
        , test "single byte 0x0a" <|
            \_ ->
                Hex.fromBytes (Encode.encode (Encode.unsignedInt8 10))
                    |> Expect.equal "0a"
        , test "two bytes" <|
            \_ ->
                Hex.fromBytes (Encode.encode (Encode.sequence [ Encode.unsignedInt8 0xDE, Encode.unsignedInt8 0xAD ]))
                    |> Expect.equal "dead"
        , test "four bytes (one word)" <|
            \_ ->
                Hex.fromBytes (Encode.encode (Encode.unsignedInt32 Bytes.BE 0xDEADBEEF))
                    |> Expect.equal "deadbeef"
        , test "output is lowercase" <|
            \_ ->
                Hex.fromBytes (Encode.encode (Encode.unsignedInt32 Bytes.BE 0xABCDEF01))
                    |> Expect.equal "abcdef01"
        , test "all byte values 0-255" <|
            \_ ->
                let
                    bytes : Bytes
                    bytes =
                        Encode.encode (Encode.sequence (List.map (\i -> Encode.unsignedInt8 i) (List.range 0 255)))

                    result : String
                    result =
                        Hex.fromBytes bytes

                    expected : String
                    expected =
                        String.concat (List.map byteToHex (List.range 0 255))
                in
                Expect.equal expected result
        , test "5 bytes (remainder after word)" <|
            \_ ->
                Hex.fromBytes (Encode.encode (Encode.sequence (List.map Encode.unsignedInt8 [ 0x01, 0x02, 0x03, 0x04, 0x05 ])))
                    |> Expect.equal "0102030405"
        , test "large input (1024 bytes)" <|
            \_ ->
                let
                    bytes : Bytes
                    bytes =
                        makeBytes 1024

                    result : String
                    result =
                        Hex.fromBytes bytes
                in
                Expect.equal (1024 * 2) (String.length result)
        ]



-- fromString


toBytesTests : Test
toBytesTests =
    describe "toBytes"
        [ test "empty string" <|
            \_ ->
                Hex.toBytes ""
                    |> Maybe.map Bytes.width
                    |> Expect.equal (Just 0)
        , test "lowercase ff" <|
            \_ ->
                Hex.toBytes "ff"
                    |> Maybe.map Hex.fromBytes
                    |> Expect.equal (Just "ff")
        , test "uppercase FF" <|
            \_ ->
                Hex.toBytes "FF"
                    |> Maybe.map Hex.fromBytes
                    |> Expect.equal (Just "ff")
        , test "mixed case DeAdBeEf" <|
            \_ ->
                Hex.toBytes "DeAdBeEf"
                    |> Maybe.map Hex.fromBytes
                    |> Expect.equal (Just "deadbeef")
        , test "all digits 0-9" <|
            \_ ->
                Hex.toBytes "0123456789"
                    |> Maybe.map Hex.fromBytes
                    |> Expect.equal (Just "0123456789")
        , test "all hex letters a-f" <|
            \_ ->
                Hex.toBytes "aabbccddeeff"
                    |> Maybe.map Hex.fromBytes
                    |> Expect.equal (Just "aabbccddeeff")
        , test "all hex letters A-F" <|
            \_ ->
                Hex.toBytes "AABBCCDDEEFF"
                    |> Maybe.map Hex.fromBytes
                    |> Expect.equal (Just "aabbccddeeff")
        , test "odd length returns Nothing" <|
            \_ ->
                Hex.toBytes "abc"
                    |> Expect.equal Nothing
        , test "invalid char 'g' returns Nothing" <|
            \_ ->
                Hex.toBytes "0g"
                    |> Expect.equal Nothing
        , test "invalid char 'z' returns Nothing" <|
            \_ ->
                Hex.toBytes "zz"
                    |> Expect.equal Nothing
        , test "space returns Nothing" <|
            \_ ->
                Hex.toBytes "0 "
                    |> Expect.equal Nothing
        , test "@ returns Nothing" <|
            \_ ->
                Hex.toBytes "@0"
                    |> Expect.equal Nothing
        , test "backtick returns Nothing" <|
            \_ ->
                Hex.toBytes "`0"
                    |> Expect.equal Nothing
        , test "G returns Nothing" <|
            \_ ->
                Hex.toBytes "GG"
                    |> Expect.equal Nothing
        , test "single byte 00" <|
            \_ ->
                Hex.toBytes "00"
                    |> Maybe.map Hex.fromBytes
                    |> Expect.equal (Just "00")
        , test "large input round-trips" <|
            \_ ->
                let
                    hex : String
                    hex =
                        Hex.fromBytes (makeBytes 512)
                in
                Hex.toBytes hex
                    |> Maybe.map Hex.fromBytes
                    |> Expect.equal (Just hex)
        ]



-- fromStringUnchecked


toBytesUncheckedTests : Test
toBytesUncheckedTests =
    describe "toBytesUnchecked"
        [ test "empty string" <|
            \_ ->
                Hex.toBytesUnchecked ""
                    |> Bytes.width
                    |> Expect.equal 0
        , test "lowercase ff" <|
            \_ ->
                Hex.toBytesUnchecked "ff"
                    |> Hex.fromBytes
                    |> Expect.equal "ff"
        , test "deadbeef" <|
            \_ ->
                Hex.toBytesUnchecked "deadbeef"
                    |> Hex.fromBytes
                    |> Expect.equal "deadbeef"
        , test "all zeros" <|
            \_ ->
                Hex.toBytesUnchecked "0000000000"
                    |> Hex.fromBytes
                    |> Expect.equal "0000000000"
        , test "large input round-trips" <|
            \_ ->
                let
                    hex : String
                    hex =
                        Hex.fromBytes (makeBytes 512)
                in
                Hex.toBytesUnchecked hex
                    |> Hex.fromBytes
                    |> Expect.equal hex
        ]



-- Round-trip tests


roundTripTests : Test
roundTripTests =
    describe "round-trip"
        [ test "fromBytes >> toBytes for various sizes" <|
            \_ ->
                let
                    sizes : List Int
                    sizes =
                        [ 0, 1, 2, 3, 4, 5, 7, 8, 15, 16, 31, 32, 63, 64, 128, 256, 512, 1024 ]

                    allPass : Bool
                    allPass =
                        List.all
                            (\n ->
                                let
                                    bytes : Bytes
                                    bytes =
                                        makeBytes n

                                    hex : String
                                    hex =
                                        Hex.fromBytes bytes
                                in
                                Hex.toBytes hex
                                    |> Maybe.map Hex.fromBytes
                                    |> (==) (Just hex)
                            )
                            sizes
                in
                Expect.equal True allPass
        , test "toBytes >> fromBytes >> toBytes is stable" <|
            \_ ->
                let
                    hex : String
                    hex =
                        "deadbeef0123456789abcdef"

                    result : Maybe String
                    result =
                        Hex.toBytes hex
                            |> Maybe.map Hex.fromBytes
                            |> Maybe.andThen Hex.toBytes
                            |> Maybe.map Hex.fromBytes
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
        hi : Int
        hi =
            n // 16

        lo : Int
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
