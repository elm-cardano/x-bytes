module XBytesTest exposing (suite)

import Bytes
import Bytes.Decode as Decode
import Bytes.Encode as Encode
import Expect
import Json.Decode as JD
import Json.Encode as JE
import Test exposing (Test, describe, test)
import XBytes exposing (XBytes)


suite : Test
suite =
    describe "XBytes"
        [ hexConversionTests
        , bytesConversionTests
        , textConversionTests
        , emptyAndWidthTests
        , reverseTests
        , appendConcatJoinTests
        , slicingTests
        , decodeEncodeTests
        , jsonTests
        , equalityTests
        ]



-- HEX CONVERSION


hexConversionTests : Test
hexConversionTests =
    describe "Hex conversion"
        [ test "fromHex valid lowercase" <|
            \_ ->
                XBytes.fromHex "deadbeef"
                    |> Maybe.map XBytes.toHex
                    |> Expect.equal (Just "deadbeef")
        , test "fromHex valid uppercase normalizes to lowercase" <|
            \_ ->
                XBytes.fromHex "DEADBEEF"
                    |> Maybe.map XBytes.toHex
                    |> Expect.equal (Just "deadbeef")
        , test "fromHex mixed case normalizes" <|
            \_ ->
                XBytes.fromHex "DeAdBeEf"
                    |> Maybe.map XBytes.toHex
                    |> Expect.equal (Just "deadbeef")
        , test "fromHex empty string" <|
            \_ ->
                XBytes.fromHex ""
                    |> Maybe.map XBytes.toHex
                    |> Expect.equal (Just "")
        , test "fromHex odd length returns Nothing" <|
            \_ ->
                XBytes.fromHex "abc"
                    |> Expect.equal Nothing
        , test "fromHex invalid chars returns Nothing" <|
            \_ ->
                XBytes.fromHex "ghij"
                    |> Expect.equal Nothing
        , test "fromHexUnchecked round-trips" <|
            \_ ->
                XBytes.fromHexUnchecked "deadbeef"
                    |> XBytes.toHex
                    |> Expect.equal "deadbeef"
        ]



-- BYTES CONVERSION


bytesConversionTests : Test
bytesConversionTests =
    describe "Bytes conversion"
        [ test "fromBytes >> toHex" <|
            \_ ->
                let
                    bytes : Bytes.Bytes
                    bytes =
                        Encode.encode
                            (Encode.sequence
                                [ Encode.unsignedInt8 0xDE
                                , Encode.unsignedInt8 0xAD
                                ]
                            )
                in
                XBytes.fromBytes bytes
                    |> XBytes.toHex
                    |> Expect.equal "dead"
        , test "toBytes produces correct width" <|
            \_ ->
                XBytes.fromHexUnchecked "deadbeef"
                    |> XBytes.toBytes
                    |> Bytes.width
                    |> Expect.equal 4
        , test "fromBytes >> toBytes round-trip preserves width" <|
            \_ ->
                let
                    bytes : Bytes.Bytes
                    bytes =
                        Encode.encode
                            (Encode.sequence
                                (List.map Encode.unsignedInt8 (List.range 0 255))
                            )

                    result : Bytes.Bytes
                    result =
                        XBytes.fromBytes bytes |> XBytes.toBytes
                in
                Expect.equal (Bytes.width bytes) (Bytes.width result)
        ]



-- TEXT CONVERSION


textConversionTests : Test
textConversionTests =
    describe "Text conversion"
        [ test "fromText ASCII" <|
            \_ ->
                XBytes.fromText "A"
                    |> XBytes.toHex
                    |> Expect.equal "41"
        , test "fromText Hello" <|
            \_ ->
                XBytes.fromText "Hello"
                    |> XBytes.toHex
                    |> Expect.equal "48656c6c6f"
        , test "fromText empty" <|
            \_ ->
                XBytes.fromText ""
                    |> XBytes.toHex
                    |> Expect.equal ""
        , test "toText ASCII" <|
            \_ ->
                XBytes.fromHexUnchecked "41"
                    |> XBytes.toText
                    |> Expect.equal (Just "A")
        , test "fromText >> toText round-trip" <|
            \_ ->
                XBytes.fromText "Hello, World!"
                    |> XBytes.toText
                    |> Expect.equal (Just "Hello, World!")
        , test "fromText multibyte UTF-8" <|
            \_ ->
                let
                    text : String
                    text =
                        "é"
                in
                XBytes.fromText text
                    |> XBytes.toText
                    |> Expect.equal (Just text)
        ]



-- EMPTY, ISEMPTY, WIDTH


emptyAndWidthTests : Test
emptyAndWidthTests =
    describe "empty, isEmpty, width"
        [ test "empty toHex" <|
            \_ ->
                XBytes.toHex XBytes.empty
                    |> Expect.equal ""
        , test "empty isEmpty" <|
            \_ ->
                XBytes.isEmpty XBytes.empty
                    |> Expect.equal True
        , test "non-empty isEmpty" <|
            \_ ->
                XBytes.isEmpty (XBytes.fromHexUnchecked "ff")
                    |> Expect.equal False
        , test "empty width" <|
            \_ ->
                XBytes.width XBytes.empty
                    |> Expect.equal 0
        , test "width 4 bytes" <|
            \_ ->
                XBytes.width (XBytes.fromHexUnchecked "deadbeef")
                    |> Expect.equal 4
        , test "width 1 byte" <|
            \_ ->
                XBytes.width (XBytes.fromHexUnchecked "ff")
                    |> Expect.equal 1
        ]



-- REVERSE


reverseTests : Test
reverseTests =
    describe "reverse"
        [ test "reverse empty" <|
            \_ ->
                XBytes.reverse XBytes.empty
                    |> XBytes.toHex
                    |> Expect.equal ""
        , test "reverse single byte" <|
            \_ ->
                XBytes.reverse (XBytes.fromHexUnchecked "ff")
                    |> XBytes.toHex
                    |> Expect.equal "ff"
        , test "reverse two bytes" <|
            \_ ->
                XBytes.reverse (XBytes.fromHexUnchecked "0102")
                    |> XBytes.toHex
                    |> Expect.equal "0201"
        , test "reverse four bytes" <|
            \_ ->
                XBytes.reverse (XBytes.fromHexUnchecked "deadbeef")
                    |> XBytes.toHex
                    |> Expect.equal "efbeadde"
        , test "reverse is self-inverse" <|
            \_ ->
                let
                    xb : XBytes
                    xb =
                        XBytes.fromHexUnchecked "0102030405"
                in
                XBytes.reverse (XBytes.reverse xb)
                    |> XBytes.toHex
                    |> Expect.equal (XBytes.toHex xb)
        ]



-- APPEND, CONCAT, JOIN


appendConcatJoinTests : Test
appendConcatJoinTests =
    describe "append, concat, join"
        [ test "append two" <|
            \_ ->
                XBytes.append
                    (XBytes.fromHexUnchecked "dead")
                    (XBytes.fromHexUnchecked "beef")
                    |> XBytes.toHex
                    |> Expect.equal "deadbeef"
        , test "append with empty" <|
            \_ ->
                XBytes.append XBytes.empty (XBytes.fromHexUnchecked "ff")
                    |> XBytes.toHex
                    |> Expect.equal "ff"
        , test "concat empty list" <|
            \_ ->
                XBytes.concat []
                    |> XBytes.toHex
                    |> Expect.equal ""
        , test "concat multiple" <|
            \_ ->
                XBytes.concat
                    [ XBytes.fromHexUnchecked "de"
                    , XBytes.fromHexUnchecked "ad"
                    , XBytes.fromHexUnchecked "beef"
                    ]
                    |> XBytes.toHex
                    |> Expect.equal "deadbeef"
        , test "join with separator" <|
            \_ ->
                XBytes.join (XBytes.fromHexUnchecked "00")
                    [ XBytes.fromHexUnchecked "aa"
                    , XBytes.fromHexUnchecked "bb"
                    , XBytes.fromHexUnchecked "cc"
                    ]
                    |> XBytes.toHex
                    |> Expect.equal "aa00bb00cc"
        , test "join empty list" <|
            \_ ->
                XBytes.join (XBytes.fromHexUnchecked "00") []
                    |> XBytes.toHex
                    |> Expect.equal ""
        , test "join single element" <|
            \_ ->
                XBytes.join (XBytes.fromHexUnchecked "00")
                    [ XBytes.fromHexUnchecked "ff" ]
                    |> XBytes.toHex
                    |> Expect.equal "ff"
        ]



-- SLICING


slicingTests : Test
slicingTests =
    let
        xb : XBytes
        xb =
            XBytes.fromHexUnchecked "deadbeef01020304"
    in
    describe "slice, left, right, dropLeft, dropRight"
        [ test "slice 1 3" <|
            \_ ->
                XBytes.slice 1 3 xb
                    |> XBytes.toHex
                    |> Expect.equal "adbe"
        , test "slice 0 0 is empty" <|
            \_ ->
                XBytes.slice 0 0 xb
                    |> XBytes.toHex
                    |> Expect.equal ""
        , test "slice full range" <|
            \_ ->
                XBytes.slice 0 8 xb
                    |> XBytes.toHex
                    |> Expect.equal "deadbeef01020304"
        , test "slice negative end" <|
            \_ ->
                XBytes.slice 0 -1 xb
                    |> XBytes.toHex
                    |> Expect.equal "deadbeef010203"
        , test "left 2" <|
            \_ ->
                XBytes.left 2 xb
                    |> XBytes.toHex
                    |> Expect.equal "dead"
        , test "left 0" <|
            \_ ->
                XBytes.left 0 xb
                    |> XBytes.toHex
                    |> Expect.equal ""
        , test "right 2" <|
            \_ ->
                XBytes.right 2 xb
                    |> XBytes.toHex
                    |> Expect.equal "0304"
        , test "right 0" <|
            \_ ->
                XBytes.right 0 xb
                    |> XBytes.toHex
                    |> Expect.equal ""
        , test "dropLeft 1" <|
            \_ ->
                XBytes.dropLeft 1 xb
                    |> XBytes.toHex
                    |> Expect.equal "adbeef01020304"
        , test "dropLeft 0 is identity" <|
            \_ ->
                XBytes.dropLeft 0 xb
                    |> XBytes.toHex
                    |> Expect.equal "deadbeef01020304"
        , test "dropRight 1" <|
            \_ ->
                XBytes.dropRight 1 xb
                    |> XBytes.toHex
                    |> Expect.equal "deadbeef010203"
        , test "left n ++ dropLeft n == original" <|
            \_ ->
                let
                    n : Int
                    n =
                        3
                in
                XBytes.append (XBytes.left n xb) (XBytes.dropLeft n xb)
                    |> XBytes.toHex
                    |> Expect.equal (XBytes.toHex xb)
        , test "dropRight n ++ right n == original" <|
            \_ ->
                let
                    n : Int
                    n =
                        3
                in
                XBytes.append (XBytes.dropRight n xb) (XBytes.right n xb)
                    |> XBytes.toHex
                    |> Expect.equal (XBytes.toHex xb)
        ]



-- DECODE / ENCODE INTEROP


decodeEncodeTests : Test
decodeEncodeTests =
    describe "decoder, encode"
        [ test "encode unsignedInt8" <|
            \_ ->
                XBytes.encode (Encode.unsignedInt8 255)
                    |> XBytes.toHex
                    |> Expect.equal "ff"
        , test "encode unsignedInt32 BE" <|
            \_ ->
                XBytes.encode (Encode.unsignedInt32 Bytes.BE 0xDEADBEEF)
                    |> XBytes.toHex
                    |> Expect.equal "deadbeef"
        , test "encode sequence" <|
            \_ ->
                XBytes.encode
                    (Encode.sequence
                        [ Encode.unsignedInt8 1
                        , Encode.unsignedInt8 2
                        ]
                    )
                    |> XBytes.toHex
                    |> Expect.equal "0102"
        , test "decoder unsignedInt8" <|
            \_ ->
                XBytes.decoder Decode.unsignedInt8 (XBytes.fromHexUnchecked "ff")
                    |> Expect.equal (Just 255)
        , test "decoder unsignedInt32 BE" <|
            \_ ->
                XBytes.decoder
                    (Decode.unsignedInt32 Bytes.BE)
                    (XBytes.fromHexUnchecked "deadbeef")
                    |> Expect.equal (Just 0xDEADBEEF)
        , test "decoder fails on too-short input" <|
            \_ ->
                XBytes.decoder
                    (Decode.unsignedInt32 Bytes.BE)
                    (XBytes.fromHexUnchecked "ff")
                    |> Expect.equal Nothing
        ]



-- JSON


jsonTests : Test
jsonTests =
    describe "JSON"
        [ test "jsonEncode produces hex string" <|
            \_ ->
                XBytes.jsonEncode (XBytes.fromHexUnchecked "deadbeef")
                    |> JE.encode 0
                    |> Expect.equal "\"deadbeef\""
        , test "jsonEncode empty" <|
            \_ ->
                XBytes.jsonEncode XBytes.empty
                    |> JE.encode 0
                    |> Expect.equal "\"\""
        , test "jsonDecoder valid hex" <|
            \_ ->
                JD.decodeString XBytes.jsonDecoder "\"deadbeef\""
                    |> Result.map XBytes.toHex
                    |> Expect.equal (Ok "deadbeef")
        , test "jsonDecoder normalizes case" <|
            \_ ->
                JD.decodeString XBytes.jsonDecoder "\"DEADBEEF\""
                    |> Result.map XBytes.toHex
                    |> Expect.equal (Ok "deadbeef")
        , test "jsonDecoder rejects invalid hex" <|
            \_ ->
                JD.decodeString XBytes.jsonDecoder "\"nope\""
                    |> Result.toMaybe
                    |> Expect.equal Nothing
        , test "jsonDecoder rejects odd length" <|
            \_ ->
                JD.decodeString XBytes.jsonDecoder "\"abc\""
                    |> Result.toMaybe
                    |> Expect.equal Nothing
        , test "jsonEncode >> jsonDecoder round-trip" <|
            \_ ->
                let
                    xb : XBytes
                    xb =
                        XBytes.fromHexUnchecked "deadbeef0123456789abcdef"

                    json : String
                    json =
                        JE.encode 0 (XBytes.jsonEncode xb)
                in
                JD.decodeString XBytes.jsonDecoder json
                    |> Result.map XBytes.toHex
                    |> Expect.equal (Ok (XBytes.toHex xb))
        ]



-- EQUALITY


equalityTests : Test
equalityTests =
    describe "equality"
        [ test "same hex values are equal" <|
            \_ ->
                Expect.equal
                    (XBytes.fromHexUnchecked "deadbeef")
                    (XBytes.fromHexUnchecked "deadbeef")
        , test "different hex values are not equal" <|
            \_ ->
                XBytes.fromHexUnchecked "dead"
                    |> Expect.notEqual (XBytes.fromHexUnchecked "beef")
        , test "fromHex and fromHexUnchecked produce equal values" <|
            \_ ->
                let
                    a : Maybe XBytes
                    a =
                        XBytes.fromHex "deadbeef"

                    b : XBytes
                    b =
                        XBytes.fromHexUnchecked "deadbeef"
                in
                Expect.equal a (Just b)
        , test "fromBytes produces equal value to fromHex" <|
            \_ ->
                let
                    bytes : Bytes.Bytes
                    bytes =
                        Encode.encode (Encode.unsignedInt32 Bytes.BE 0xDEADBEEF)

                    a : XBytes
                    a =
                        XBytes.fromBytes bytes

                    b : XBytes
                    b =
                        XBytes.fromHexUnchecked "deadbeef"
                in
                Expect.equal a b
        ]
