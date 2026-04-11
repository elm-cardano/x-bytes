module Hex.V2 exposing (toString, fromString)

{-| V2: Uses Decode.loop instead of andThen chain for toString.
Uses String.foldl for fromString.
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
    in
    Decode.decode (decodeLoop width) bytes
        |> Maybe.withDefault ""


decodeLoop : Int -> Decoder String
decodeLoop width =
    Decode.loop ( width, [] ) loopStep


loopStep : ( Int, List String ) -> Decoder (Decode.Step ( Int, List String ) String)
loopStep ( remaining, acc ) =
    if remaining <= 0 then
        Decode.succeed (Decode.Done (String.concat (List.reverse acc)))

    else
        Decode.unsignedInt8
            |> Decode.map
                (\byte ->
                    Decode.Loop ( remaining - 1, byteToHex byte :: acc )
                )


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


type alias FoldState =
    { pendingNibble : Int
    , hasPending : Bool
    , encoders : List Encode.Encoder
    , valid : Bool
    }


fromString : String -> Maybe Bytes
fromString hex =
    let
        len =
            String.length hex
    in
    if modBy 2 len /= 0 then
        Nothing

    else
        let
            result =
                String.foldl foldChar (FoldState 0 False [] True) hex
        in
        if result.valid && not result.hasPending then
            Just (Encode.encode (Encode.sequence (List.reverse result.encoders)))

        else
            Nothing


foldChar : Char -> FoldState -> FoldState
foldChar c state =
    if not state.valid then
        state

    else
        case hexCharToInt c of
            Nothing ->
                { state | valid = False }

            Just nibble ->
                if state.hasPending then
                    { pendingNibble = 0
                    , hasPending = False
                    , encoders =
                        Encode.unsignedInt8
                            (Bitwise.or (Bitwise.shiftLeftBy 4 state.pendingNibble) nibble)
                            :: state.encoders
                    , valid = True
                    }

                else
                    { state | pendingNibble = nibble, hasPending = True }


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
