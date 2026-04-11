module Hex.V2 exposing (toString, fromString, fromStringUnchecked)

{-| Convert between `Bytes` and hexadecimal strings.

@docs toString, fromString, fromStringUnchecked

-}

import Array exposing (Array)
import Bitwise
import Bytes exposing (Bytes, Endianness(..))
import Bytes.Decode as Decode exposing (Decoder)
import Bytes.Encode as Encode



-- ENCODE


{-| Convert `Bytes` to a lowercase hex string.

    import Bytes.Encode as Encode

    Encode.encode (Encode.unsignedInt8 255)
        |> toString
    --> "ff"

-}
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
    Decode.decode (toStringLoop fullWords remainder) bytes
        |> Maybe.withDefault ""


type alias EncState =
    { words : Int, rem : Int, acc : String }


toStringLoop : Int -> Int -> Decoder String
toStringLoop fullWords remainder =
    Decode.loop { words = fullWords, rem = remainder, acc = "" } encStep


encStep : EncState -> Decoder (Decode.Step EncState String)
encStep state =
    if state.words >= 5 then
        Decode.map5
            (\w1 w2 w3 w4 w5 ->
                Decode.Loop
                    { words = state.words - 5
                    , rem = state.rem
                    , acc =
                        state.acc
                            ++ word32ToHex w1
                            ++ word32ToHex w2
                            ++ word32ToHex w3
                            ++ word32ToHex w4
                            ++ word32ToHex w5
                    }
            )
            (Decode.unsignedInt32 BE)
            (Decode.unsignedInt32 BE)
            (Decode.unsignedInt32 BE)
            (Decode.unsignedInt32 BE)
            (Decode.unsignedInt32 BE)

    else if state.words >= 2 then
        Decode.map2
            (\w1 w2 ->
                Decode.Loop
                    { words = state.words - 2
                    , rem = state.rem
                    , acc = state.acc ++ word32ToHex w1 ++ word32ToHex w2
                    }
            )
            (Decode.unsignedInt32 BE)
            (Decode.unsignedInt32 BE)

    else if state.words == 1 then
        Decode.unsignedInt32 BE
            |> Decode.map
                (\word ->
                    Decode.Loop { words = 0, rem = state.rem, acc = state.acc ++ word32ToHex word }
                )

    else if state.rem > 0 then
        Decode.unsignedInt8
            |> Decode.map
                (\byte ->
                    Decode.Loop { words = 0, rem = state.rem - 1, acc = state.acc ++ lookupByte byte }
                )

    else
        Decode.succeed (Decode.Done state.acc)


word32ToHex : Int -> String
word32ToHex word =
    lookupByte (Bitwise.and 0xFF (Bitwise.shiftRightZfBy 24 word))
        ++ lookupByte (Bitwise.and 0xFF (Bitwise.shiftRightZfBy 16 word))
        ++ lookupByte (Bitwise.and 0xFF (Bitwise.shiftRightZfBy 8 word))
        ++ lookupByte (Bitwise.and 0xFF word)


lookupByte : Int -> String
lookupByte byte =
    case Array.get byte hexTable of
        Just s ->
            s

        Nothing ->
            "00"


hexTable : Array String
hexTable =
    Array.fromList
        [ "00"
        , "01"
        , "02"
        , "03"
        , "04"
        , "05"
        , "06"
        , "07"
        , "08"
        , "09"
        , "0a"
        , "0b"
        , "0c"
        , "0d"
        , "0e"
        , "0f"
        , "10"
        , "11"
        , "12"
        , "13"
        , "14"
        , "15"
        , "16"
        , "17"
        , "18"
        , "19"
        , "1a"
        , "1b"
        , "1c"
        , "1d"
        , "1e"
        , "1f"
        , "20"
        , "21"
        , "22"
        , "23"
        , "24"
        , "25"
        , "26"
        , "27"
        , "28"
        , "29"
        , "2a"
        , "2b"
        , "2c"
        , "2d"
        , "2e"
        , "2f"
        , "30"
        , "31"
        , "32"
        , "33"
        , "34"
        , "35"
        , "36"
        , "37"
        , "38"
        , "39"
        , "3a"
        , "3b"
        , "3c"
        , "3d"
        , "3e"
        , "3f"
        , "40"
        , "41"
        , "42"
        , "43"
        , "44"
        , "45"
        , "46"
        , "47"
        , "48"
        , "49"
        , "4a"
        , "4b"
        , "4c"
        , "4d"
        , "4e"
        , "4f"
        , "50"
        , "51"
        , "52"
        , "53"
        , "54"
        , "55"
        , "56"
        , "57"
        , "58"
        , "59"
        , "5a"
        , "5b"
        , "5c"
        , "5d"
        , "5e"
        , "5f"
        , "60"
        , "61"
        , "62"
        , "63"
        , "64"
        , "65"
        , "66"
        , "67"
        , "68"
        , "69"
        , "6a"
        , "6b"
        , "6c"
        , "6d"
        , "6e"
        , "6f"
        , "70"
        , "71"
        , "72"
        , "73"
        , "74"
        , "75"
        , "76"
        , "77"
        , "78"
        , "79"
        , "7a"
        , "7b"
        , "7c"
        , "7d"
        , "7e"
        , "7f"
        , "80"
        , "81"
        , "82"
        , "83"
        , "84"
        , "85"
        , "86"
        , "87"
        , "88"
        , "89"
        , "8a"
        , "8b"
        , "8c"
        , "8d"
        , "8e"
        , "8f"
        , "90"
        , "91"
        , "92"
        , "93"
        , "94"
        , "95"
        , "96"
        , "97"
        , "98"
        , "99"
        , "9a"
        , "9b"
        , "9c"
        , "9d"
        , "9e"
        , "9f"
        , "a0"
        , "a1"
        , "a2"
        , "a3"
        , "a4"
        , "a5"
        , "a6"
        , "a7"
        , "a8"
        , "a9"
        , "aa"
        , "ab"
        , "ac"
        , "ad"
        , "ae"
        , "af"
        , "b0"
        , "b1"
        , "b2"
        , "b3"
        , "b4"
        , "b5"
        , "b6"
        , "b7"
        , "b8"
        , "b9"
        , "ba"
        , "bb"
        , "bc"
        , "bd"
        , "be"
        , "bf"
        , "c0"
        , "c1"
        , "c2"
        , "c3"
        , "c4"
        , "c5"
        , "c6"
        , "c7"
        , "c8"
        , "c9"
        , "ca"
        , "cb"
        , "cc"
        , "cd"
        , "ce"
        , "cf"
        , "d0"
        , "d1"
        , "d2"
        , "d3"
        , "d4"
        , "d5"
        , "d6"
        , "d7"
        , "d8"
        , "d9"
        , "da"
        , "db"
        , "dc"
        , "dd"
        , "de"
        , "df"
        , "e0"
        , "e1"
        , "e2"
        , "e3"
        , "e4"
        , "e5"
        , "e6"
        , "e7"
        , "e8"
        , "e9"
        , "ea"
        , "eb"
        , "ec"
        , "ed"
        , "ee"
        , "ef"
        , "f0"
        , "f1"
        , "f2"
        , "f3"
        , "f4"
        , "f5"
        , "f6"
        , "f7"
        , "f8"
        , "f9"
        , "fa"
        , "fb"
        , "fc"
        , "fd"
        , "fe"
        , "ff"
        ]



-- DECODE


{-| Parse a hex string into `Bytes`. Returns `Nothing` if the string has
odd length or contains non-hex characters. Accepts both uppercase and
lowercase hex digits.

    fromString "ff"
    --> Just <1 byte>

    fromString "zz"
    --> Nothing

-}
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
            byteCount =
                len // 2

            fullWords =
                byteCount // 4

            remainder =
                modBy 4 byteCount
        in
        decodeWords hex 0 fullWords []
            |> Maybe.andThen
                (\( offset, acc ) ->
                    decodeRemainder hex offset remainder acc
                )
            |> Maybe.map
                (\encoders ->
                    Encode.encode (Encode.sequence (List.reverse encoders))
                )


decodeWords : String -> Int -> Int -> List Encode.Encoder -> Maybe ( Int, List Encode.Encoder )
decodeWords hex offset remaining acc =
    if remaining <= 0 then
        Just ( offset, acc )

    else
        let
            b0 =
                hexPairAt hex offset

            b1 =
                hexPairAt hex (offset + 2)

            b2 =
                hexPairAt hex (offset + 4)

            b3 =
                hexPairAt hex (offset + 6)
        in
        if b0 < 0 || b1 < 0 || b2 < 0 || b3 < 0 then
            Nothing

        else
            let
                word =
                    Bitwise.or
                        (Bitwise.or (Bitwise.shiftLeftBy 24 b0) (Bitwise.shiftLeftBy 16 b1))
                        (Bitwise.or (Bitwise.shiftLeftBy 8 b2) b3)
            in
            decodeWords hex (offset + 8) (remaining - 1) (Encode.unsignedInt32 BE word :: acc)


decodeRemainder : String -> Int -> Int -> List Encode.Encoder -> Maybe (List Encode.Encoder)
decodeRemainder hex offset remaining acc =
    if remaining <= 0 then
        Just acc

    else
        let
            byte =
                hexPairAt hex offset
        in
        if byte < 0 then
            Nothing

        else
            decodeRemainder hex (offset + 2) (remaining - 1) (Encode.unsignedInt8 byte :: acc)


hexPairAt : String -> Int -> Int
hexPairAt hex offset =
    let
        hi =
            hexDigit (String.slice offset (offset + 1) hex)

        lo =
            hexDigit (String.slice (offset + 1) (offset + 2) hex)
    in
    if hi < 0 || lo < 0 then
        -1

    else
        Bitwise.or (Bitwise.shiftLeftBy 4 hi) lo


hexDigit : String -> Int
hexDigit s =
    case String.uncons s of
        Just ( c, _ ) ->
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

        Nothing ->
            -1



-- DECODE (UNCHECKED)


{-| Parse a lowercase hex string into `Bytes`. Does not validate the input:
assumes even length and only lowercase hex characters (0-9, a-f).
About 20% faster than `fromString`.

    fromStringUnchecked "ff"
    --> <1 byte>

-}
fromStringUnchecked : String -> Bytes
fromStringUnchecked hex =
    let
        len =
            String.length hex

        byteCount =
            len // 2

        fullWords =
            byteCount // 4

        remainder =
            modBy 4 byteCount

        ( offset, acc ) =
            uncheckedWords hex 0 fullWords []
    in
    Encode.encode (Encode.sequence (List.reverse (uncheckedRemainder hex offset remainder acc)))


uncheckedWords : String -> Int -> Int -> List Encode.Encoder -> ( Int, List Encode.Encoder )
uncheckedWords hex offset remaining acc =
    if remaining > 0 then
        let
            b0 =
                uncheckedPairAt hex offset

            b1 =
                uncheckedPairAt hex (offset + 2)

            b2 =
                uncheckedPairAt hex (offset + 4)

            b3 =
                uncheckedPairAt hex (offset + 6)

            word =
                Bitwise.or
                    (Bitwise.or (Bitwise.shiftLeftBy 24 b0) (Bitwise.shiftLeftBy 16 b1))
                    (Bitwise.or (Bitwise.shiftLeftBy 8 b2) b3)
        in
        uncheckedWords hex (offset + 8) (remaining - 1) (Encode.unsignedInt32 BE word :: acc)

    else
        ( offset, acc )


uncheckedRemainder : String -> Int -> Int -> List Encode.Encoder -> List Encode.Encoder
uncheckedRemainder hex offset remaining acc =
    if remaining > 0 then
        uncheckedRemainder hex (offset + 2) (remaining - 1) (Encode.unsignedInt8 (uncheckedPairAt hex offset) :: acc)

    else
        acc


uncheckedPairAt : String -> Int -> Int
uncheckedPairAt hex offset =
    Bitwise.or
        (Bitwise.shiftLeftBy 4 (uncheckedNibble (String.slice offset (offset + 1) hex)))
        (uncheckedNibble (String.slice (offset + 1) (offset + 2) hex))


uncheckedNibble : String -> Int
uncheckedNibble s =
    case String.uncons s of
        Just ( c, _ ) ->
            let
                code =
                    Char.toCode c
            in
            code - 48 - 39 * Bitwise.shiftRightZfBy 6 code

        Nothing ->
            0
