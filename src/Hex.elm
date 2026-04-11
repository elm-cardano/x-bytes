module Hex exposing (toString, fromString, fromStringUnchecked)

{-| Convert between `Bytes` and hexadecimal strings.

@docs toString, fromString, fromStringUnchecked

-}

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
    case byte of
        0 ->
            "00"

        1 ->
            "01"

        2 ->
            "02"

        3 ->
            "03"

        4 ->
            "04"

        5 ->
            "05"

        6 ->
            "06"

        7 ->
            "07"

        8 ->
            "08"

        9 ->
            "09"

        10 ->
            "0a"

        11 ->
            "0b"

        12 ->
            "0c"

        13 ->
            "0d"

        14 ->
            "0e"

        15 ->
            "0f"

        16 ->
            "10"

        17 ->
            "11"

        18 ->
            "12"

        19 ->
            "13"

        20 ->
            "14"

        21 ->
            "15"

        22 ->
            "16"

        23 ->
            "17"

        24 ->
            "18"

        25 ->
            "19"

        26 ->
            "1a"

        27 ->
            "1b"

        28 ->
            "1c"

        29 ->
            "1d"

        30 ->
            "1e"

        31 ->
            "1f"

        32 ->
            "20"

        33 ->
            "21"

        34 ->
            "22"

        35 ->
            "23"

        36 ->
            "24"

        37 ->
            "25"

        38 ->
            "26"

        39 ->
            "27"

        40 ->
            "28"

        41 ->
            "29"

        42 ->
            "2a"

        43 ->
            "2b"

        44 ->
            "2c"

        45 ->
            "2d"

        46 ->
            "2e"

        47 ->
            "2f"

        48 ->
            "30"

        49 ->
            "31"

        50 ->
            "32"

        51 ->
            "33"

        52 ->
            "34"

        53 ->
            "35"

        54 ->
            "36"

        55 ->
            "37"

        56 ->
            "38"

        57 ->
            "39"

        58 ->
            "3a"

        59 ->
            "3b"

        60 ->
            "3c"

        61 ->
            "3d"

        62 ->
            "3e"

        63 ->
            "3f"

        64 ->
            "40"

        65 ->
            "41"

        66 ->
            "42"

        67 ->
            "43"

        68 ->
            "44"

        69 ->
            "45"

        70 ->
            "46"

        71 ->
            "47"

        72 ->
            "48"

        73 ->
            "49"

        74 ->
            "4a"

        75 ->
            "4b"

        76 ->
            "4c"

        77 ->
            "4d"

        78 ->
            "4e"

        79 ->
            "4f"

        80 ->
            "50"

        81 ->
            "51"

        82 ->
            "52"

        83 ->
            "53"

        84 ->
            "54"

        85 ->
            "55"

        86 ->
            "56"

        87 ->
            "57"

        88 ->
            "58"

        89 ->
            "59"

        90 ->
            "5a"

        91 ->
            "5b"

        92 ->
            "5c"

        93 ->
            "5d"

        94 ->
            "5e"

        95 ->
            "5f"

        96 ->
            "60"

        97 ->
            "61"

        98 ->
            "62"

        99 ->
            "63"

        100 ->
            "64"

        101 ->
            "65"

        102 ->
            "66"

        103 ->
            "67"

        104 ->
            "68"

        105 ->
            "69"

        106 ->
            "6a"

        107 ->
            "6b"

        108 ->
            "6c"

        109 ->
            "6d"

        110 ->
            "6e"

        111 ->
            "6f"

        112 ->
            "70"

        113 ->
            "71"

        114 ->
            "72"

        115 ->
            "73"

        116 ->
            "74"

        117 ->
            "75"

        118 ->
            "76"

        119 ->
            "77"

        120 ->
            "78"

        121 ->
            "79"

        122 ->
            "7a"

        123 ->
            "7b"

        124 ->
            "7c"

        125 ->
            "7d"

        126 ->
            "7e"

        127 ->
            "7f"

        128 ->
            "80"

        129 ->
            "81"

        130 ->
            "82"

        131 ->
            "83"

        132 ->
            "84"

        133 ->
            "85"

        134 ->
            "86"

        135 ->
            "87"

        136 ->
            "88"

        137 ->
            "89"

        138 ->
            "8a"

        139 ->
            "8b"

        140 ->
            "8c"

        141 ->
            "8d"

        142 ->
            "8e"

        143 ->
            "8f"

        144 ->
            "90"

        145 ->
            "91"

        146 ->
            "92"

        147 ->
            "93"

        148 ->
            "94"

        149 ->
            "95"

        150 ->
            "96"

        151 ->
            "97"

        152 ->
            "98"

        153 ->
            "99"

        154 ->
            "9a"

        155 ->
            "9b"

        156 ->
            "9c"

        157 ->
            "9d"

        158 ->
            "9e"

        159 ->
            "9f"

        160 ->
            "a0"

        161 ->
            "a1"

        162 ->
            "a2"

        163 ->
            "a3"

        164 ->
            "a4"

        165 ->
            "a5"

        166 ->
            "a6"

        167 ->
            "a7"

        168 ->
            "a8"

        169 ->
            "a9"

        170 ->
            "aa"

        171 ->
            "ab"

        172 ->
            "ac"

        173 ->
            "ad"

        174 ->
            "ae"

        175 ->
            "af"

        176 ->
            "b0"

        177 ->
            "b1"

        178 ->
            "b2"

        179 ->
            "b3"

        180 ->
            "b4"

        181 ->
            "b5"

        182 ->
            "b6"

        183 ->
            "b7"

        184 ->
            "b8"

        185 ->
            "b9"

        186 ->
            "ba"

        187 ->
            "bb"

        188 ->
            "bc"

        189 ->
            "bd"

        190 ->
            "be"

        191 ->
            "bf"

        192 ->
            "c0"

        193 ->
            "c1"

        194 ->
            "c2"

        195 ->
            "c3"

        196 ->
            "c4"

        197 ->
            "c5"

        198 ->
            "c6"

        199 ->
            "c7"

        200 ->
            "c8"

        201 ->
            "c9"

        202 ->
            "ca"

        203 ->
            "cb"

        204 ->
            "cc"

        205 ->
            "cd"

        206 ->
            "ce"

        207 ->
            "cf"

        208 ->
            "d0"

        209 ->
            "d1"

        210 ->
            "d2"

        211 ->
            "d3"

        212 ->
            "d4"

        213 ->
            "d5"

        214 ->
            "d6"

        215 ->
            "d7"

        216 ->
            "d8"

        217 ->
            "d9"

        218 ->
            "da"

        219 ->
            "db"

        220 ->
            "dc"

        221 ->
            "dd"

        222 ->
            "de"

        223 ->
            "df"

        224 ->
            "e0"

        225 ->
            "e1"

        226 ->
            "e2"

        227 ->
            "e3"

        228 ->
            "e4"

        229 ->
            "e5"

        230 ->
            "e6"

        231 ->
            "e7"

        232 ->
            "e8"

        233 ->
            "e9"

        234 ->
            "ea"

        235 ->
            "eb"

        236 ->
            "ec"

        237 ->
            "ed"

        238 ->
            "ee"

        239 ->
            "ef"

        240 ->
            "f0"

        241 ->
            "f1"

        242 ->
            "f2"

        243 ->
            "f3"

        244 ->
            "f4"

        245 ->
            "f5"

        246 ->
            "f6"

        247 ->
            "f7"

        248 ->
            "f8"

        249 ->
            "f9"

        250 ->
            "fa"

        251 ->
            "fb"

        252 ->
            "fc"

        253 ->
            "fd"

        254 ->
            "fe"

        255 ->
            "ff"

        _ ->
            "00"



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
