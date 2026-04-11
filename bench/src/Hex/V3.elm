module Hex.V3 exposing (toString, fromString)

{-| V3: Decodes 4 bytes at a time (unsignedInt32) for toString.
Uses direct charCodeAt-style indexing for fromString.
-}

import Bitwise
import Bytes exposing (Bytes, Endianness(..))
import Bytes.Decode as Decode exposing (Decoder)
import Bytes.Encode as Encode


toString : Bytes -> String
toString bytes =
    let
        width =
            Bytes.width bytes

        fullWords =
            width // 4

        remainder =
            modBy 4 width
    in
    Decode.decode (decodeLoop fullWords remainder) bytes
        |> Maybe.withDefault ""


decodeLoop : Int -> Int -> Decoder String
decodeLoop fullWords remainder =
    Decode.loop ( fullWords, remainder, [] ) loopStep


loopStep : ( Int, Int, List String ) -> Decoder (Decode.Step ( Int, Int, List String ) String)
loopStep ( words, rem, acc ) =
    if words > 0 then
        Decode.unsignedInt32 BE
            |> Decode.map
                (\word ->
                    Decode.Loop ( words - 1, rem, word32ToHex word :: acc )
                )

    else if rem > 0 then
        Decode.unsignedInt8
            |> Decode.map
                (\byte ->
                    Decode.Loop ( 0, rem - 1, byteToHex byte :: acc )
                )

    else
        Decode.succeed (Decode.Done (String.concat (List.reverse acc)))


word32ToHex : Int -> String
word32ToHex word =
    let
        b0 =
            Bitwise.and 0xFF (Bitwise.shiftRightZfBy 24 word)

        b1 =
            Bitwise.and 0xFF (Bitwise.shiftRightZfBy 16 word)

        b2 =
            Bitwise.and 0xFF (Bitwise.shiftRightZfBy 8 word)

        b3 =
            Bitwise.and 0xFF word
    in
    String.fromList
        [ nibbleToChar (Bitwise.shiftRightZfBy 4 b0)
        , nibbleToChar (Bitwise.and 0x0F b0)
        , nibbleToChar (Bitwise.shiftRightZfBy 4 b1)
        , nibbleToChar (Bitwise.and 0x0F b1)
        , nibbleToChar (Bitwise.shiftRightZfBy 4 b2)
        , nibbleToChar (Bitwise.and 0x0F b2)
        , nibbleToChar (Bitwise.shiftRightZfBy 4 b3)
        , nibbleToChar (Bitwise.and 0x0F b3)
        ]


byteToHex : Int -> String
byteToHex byte =
    let
        hi =
            Bitwise.shiftRightZfBy 4 byte

        lo =
            Bitwise.and 0x0F byte
    in
    String.cons (nibbleToChar hi) (String.fromChar (nibbleToChar lo))


nibbleToChar : Int -> Char
nibbleToChar n =
    if n < 10 then
        Char.fromCode (n + 0x30)

    else
        Char.fromCode (n + 0x57)


fromString : String -> Maybe Bytes
fromString hex =
    let
        len =
            String.length hex
    in
    if modBy 2 len /= 0 then
        Nothing

    else
        fromStringLoop hex 0 len []
            |> Maybe.map
                (\encoders ->
                    Encode.encode (Encode.sequence (List.reverse encoders))
                )


fromStringLoop : String -> Int -> Int -> List Encode.Encoder -> Maybe (List Encode.Encoder)
fromStringLoop hex offset len acc =
    if offset >= len then
        Just acc

    else
        let
            pair =
                String.slice offset (offset + 2) hex
        in
        case hexPairDirect pair of
            Nothing ->
                Nothing

            Just byte ->
                fromStringLoop hex (offset + 2) len (Encode.unsignedInt8 byte :: acc)


hexPairDirect : String -> Maybe Int
hexPairDirect pair =
    case String.toList pair of
        [ hi, lo ] ->
            Maybe.map2
                (\h l -> Bitwise.or (Bitwise.shiftLeftBy 4 h) l)
                (hexCharToInt hi)
                (hexCharToInt lo)

        _ ->
            Nothing


hexCharToInt : Char -> Maybe Int
hexCharToInt c =
    let
        code =
            Char.toCode c
    in
    if 0x30 <= code && code <= 0x39 then
        Just (code - 0x30)

    else if 0x41 <= code && code <= 0x46 then
        Just (code - 0x37)

    else if 0x61 <= code && code <= 0x66 then
        Just (code - 0x57)

    else
        Nothing
