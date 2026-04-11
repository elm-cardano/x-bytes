module Hex.V5 exposing (toString, fromString)

{-| V5: Build a flat List Char for toString, then String.fromList once.
Avoid Maybe per hex char in fromString using sentinel -1.
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


loopStep : ( Int, Int, List Char ) -> Decoder (Decode.Step ( Int, Int, List Char ) String)
loopStep ( words, rem, acc ) =
    if words > 0 then
        Decode.unsignedInt32 BE
            |> Decode.map
                (\word ->
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
                    Decode.Loop
                        ( words - 1
                        , rem
                        , nibbleToChar (Bitwise.and 0x0F b3)
                            :: nibbleToChar (Bitwise.shiftRightZfBy 4 b3)
                            :: nibbleToChar (Bitwise.and 0x0F b2)
                            :: nibbleToChar (Bitwise.shiftRightZfBy 4 b2)
                            :: nibbleToChar (Bitwise.and 0x0F b1)
                            :: nibbleToChar (Bitwise.shiftRightZfBy 4 b1)
                            :: nibbleToChar (Bitwise.and 0x0F b0)
                            :: nibbleToChar (Bitwise.shiftRightZfBy 4 b0)
                            :: acc
                        )
                )

    else if rem > 0 then
        Decode.unsignedInt8
            |> Decode.map
                (\byte ->
                    Decode.Loop
                        ( 0
                        , rem - 1
                        , nibbleToChar (Bitwise.and 0x0F byte)
                            :: nibbleToChar (Bitwise.shiftRightZfBy 4 byte)
                            :: acc
                        )
                )

    else
        Decode.succeed (Decode.Done (String.fromList (List.reverse acc)))


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
        fromStringHelp hex 0 len []
            |> Maybe.map
                (\encoders ->
                    Encode.encode (Encode.sequence (List.reverse encoders))
                )


fromStringHelp : String -> Int -> Int -> List Encode.Encoder -> Maybe (List Encode.Encoder)
fromStringHelp hex offset len acc =
    if offset >= len then
        Just acc

    else
        let
            byte =
                hexPairAt hex offset
        in
        if byte < 0 then
            Nothing

        else
            fromStringHelp hex (offset + 2) len (Encode.unsignedInt8 byte :: acc)


hexPairAt : String -> Int -> Int
hexPairAt hex offset =
    case String.uncons (String.slice offset (offset + 2) hex) of
        Just ( hi, rest ) ->
            case String.uncons rest of
                Just ( lo, _ ) ->
                    let
                        h =
                            hexVal hi

                        l =
                            hexVal lo
                    in
                    if h < 0 || l < 0 then
                        -1

                    else
                        Bitwise.or (Bitwise.shiftLeftBy 4 h) l

                Nothing ->
                    -1

        Nothing ->
            -1


hexVal : Char -> Int
hexVal c =
    let
        code =
            Char.toCode c
    in
    if 0x30 <= code && code <= 0x39 then
        code - 0x30

    else if 0x41 <= code && code <= 0x46 then
        code - 0x37

    else if 0x61 <= code && code <= 0x66 then
        code - 0x57

    else
        -1
