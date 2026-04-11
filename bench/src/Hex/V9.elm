module Hex.V9 exposing (toString, fromString)

{-| V9: Bytes-as-intermediate to bypass all String/Char APIs.

toString: Decode input bytes, convert nibbles to ASCII codes via arithmetic,
encode as intermediate Bytes, then Decode.string in one kernel call.
No Array lookup, no String.append, no String.concat.

fromString: Encode hex string to Bytes via Encode.string (fast kernel UTF-8).
Then decode char codes as unsignedInt32 — pure integer arithmetic, zero
String.slice/uncons/_Utils_chr overhead.
-}

import Bitwise
import Bytes exposing (Bytes, Endianness(..))
import Bytes.Decode as Decode exposing (Decoder)
import Bytes.Encode as Encode



-- toString: input Bytes → intermediate hex Bytes → String


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
    case Decode.decode (toStringLoop fullWords remainder) bytes of
        Just encoders ->
            let
                hexBytes =
                    Encode.encode (Encode.sequence encoders)
            in
            Decode.decode (Decode.string (Bytes.width hexBytes)) hexBytes
                |> Maybe.withDefault ""

        Nothing ->
            ""


type alias ToState =
    { words : Int, rem : Int, acc : List Encode.Encoder }


toStringLoop : Int -> Int -> Decoder (List Encode.Encoder)
toStringLoop fullWords remainder =
    Decode.loop (ToState fullWords remainder []) toStep


toStep : ToState -> Decoder (Decode.Step ToState (List Encode.Encoder))
toStep state =
    if state.words >= 2 then
        Decode.map2
            (\w1 w2 ->
                Decode.Loop
                    (ToState (state.words - 2)
                        state.rem
                        (word32ToHexEncoders w2 (word32ToHexEncoders w1 state.acc))
                    )
            )
            (Decode.unsignedInt32 BE)
            (Decode.unsignedInt32 BE)

    else if state.words == 1 then
        Decode.unsignedInt32 BE
            |> Decode.map
                (\word ->
                    Decode.Loop
                        (ToState 0 state.rem (word32ToHexEncoders word state.acc))
                )

    else if state.rem > 0 then
        Decode.unsignedInt8
            |> Decode.map
                (\byte ->
                    Decode.Loop
                        (ToState 0 (state.rem - 1) (byteToHexEncoder byte :: state.acc))
                )

    else
        Decode.succeed (Decode.Done (List.reverse state.acc))


{-| Convert a 32-bit word to 2 encoder values (8 hex char ASCII codes packed as 2 Int32s).
Prepends them to the accumulator (in correct order: hi word first).
-}
word32ToHexEncoders : Int -> List Encode.Encoder -> List Encode.Encoder
word32ToHexEncoders word acc =
    let
        b0 =
            Bitwise.and 0xFF (Bitwise.shiftRightZfBy 24 word)

        b1 =
            Bitwise.and 0xFF (Bitwise.shiftRightZfBy 16 word)

        b2 =
            Bitwise.and 0xFF (Bitwise.shiftRightZfBy 8 word)

        b3 =
            Bitwise.and 0xFF word

        -- Pack 2 bytes' hex codes into one Int32: [hi0, lo0, hi1, lo1]
        upper =
            Bitwise.or
                (Bitwise.shiftLeftBy 16 (byteToHexPair b0))
                (byteToHexPair b1)

        lower =
            Bitwise.or
                (Bitwise.shiftLeftBy 16 (byteToHexPair b2))
                (byteToHexPair b3)
    in
    Encode.unsignedInt32 BE lower :: Encode.unsignedInt32 BE upper :: acc


{-| Convert a byte (0-255) to a 16-bit value containing 2 ASCII hex char codes.
E.g. 0xAB → 0x6162 ('a' << 8 | 'b')
-}
byteToHexPair : Int -> Int
byteToHexPair byte =
    Bitwise.or
        (Bitwise.shiftLeftBy 8 (nibbleToCode (Bitwise.shiftRightZfBy 4 byte)))
        (nibbleToCode (Bitwise.and 0x0F byte))


byteToHexEncoder : Int -> Encode.Encoder
byteToHexEncoder byte =
    Encode.unsignedInt16 BE (byteToHexPair byte)


nibbleToCode : Int -> Int
nibbleToCode n =
    if n < 10 then
        n + 0x30

    else
        n + 0x57



-- fromString: hex String → Bytes (via intermediate UTF-8 Bytes)


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
            hexBytes =
                Encode.encode (Encode.string hex)
        in
        -- Non-ASCII chars produce multi-byte UTF-8, making width > len
        if Bytes.width hexBytes /= len then
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
            Decode.decode (fromStringLoop fullWords remainder) hexBytes
                |> Maybe.andThen identity


type alias FromState =
    { words : Int, rem : Int, valid : Bool, acc : List Encode.Encoder }


fromStringLoop : Int -> Int -> Decoder (Maybe Bytes)
fromStringLoop fullWords remainder =
    Decode.loop (FromState fullWords remainder True []) fromStep


fromStep : FromState -> Decoder (Decode.Step FromState (Maybe Bytes))
fromStep state =
    if not state.valid then
        Decode.succeed (Decode.Done Nothing)

    else if state.words > 0 then
        -- Read 8 hex char codes as 2 Int32s
        Decode.map2
            (\hexW1 hexW2 ->
                let
                    b0 =
                        decodeHexPairFromCodes
                            (Bitwise.and 0xFF (Bitwise.shiftRightZfBy 24 hexW1))
                            (Bitwise.and 0xFF (Bitwise.shiftRightZfBy 16 hexW1))

                    b1 =
                        decodeHexPairFromCodes
                            (Bitwise.and 0xFF (Bitwise.shiftRightZfBy 8 hexW1))
                            (Bitwise.and 0xFF hexW1)

                    b2 =
                        decodeHexPairFromCodes
                            (Bitwise.and 0xFF (Bitwise.shiftRightZfBy 24 hexW2))
                            (Bitwise.and 0xFF (Bitwise.shiftRightZfBy 16 hexW2))

                    b3 =
                        decodeHexPairFromCodes
                            (Bitwise.and 0xFF (Bitwise.shiftRightZfBy 8 hexW2))
                            (Bitwise.and 0xFF hexW2)
                in
                if b0 < 0 || b1 < 0 || b2 < 0 || b3 < 0 then
                    Decode.Loop (FromState 0 0 False [])

                else
                    let
                        word =
                            Bitwise.or
                                (Bitwise.or (Bitwise.shiftLeftBy 24 b0) (Bitwise.shiftLeftBy 16 b1))
                                (Bitwise.or (Bitwise.shiftLeftBy 8 b2) b3)
                    in
                    Decode.Loop
                        (FromState (state.words - 1) state.rem True (Encode.unsignedInt32 BE word :: state.acc))
            )
            (Decode.unsignedInt32 BE)
            (Decode.unsignedInt32 BE)

    else if state.rem > 0 then
        Decode.unsignedInt16 BE
            |> Decode.map
                (\hexPair ->
                    let
                        byte =
                            decodeHexPairFromCodes
                                (Bitwise.and 0xFF (Bitwise.shiftRightZfBy 8 hexPair))
                                (Bitwise.and 0xFF hexPair)
                    in
                    if byte < 0 then
                        Decode.Loop (FromState 0 0 False [])

                    else
                        Decode.Loop
                            (FromState 0 (state.rem - 1) True (Encode.unsignedInt8 byte :: state.acc))
                )

    else
        Decode.succeed
            (Decode.Done
                (Just (Encode.encode (Encode.sequence (List.reverse state.acc))))
            )


{-| Convert two ASCII char codes to a byte value. Returns -1 if invalid.
-}
decodeHexPairFromCodes : Int -> Int -> Int
decodeHexPairFromCodes hiCode loCode =
    let
        h =
            codeToNibble hiCode

        l =
            codeToNibble loCode
    in
    if h < 0 || l < 0 then
        -1

    else
        Bitwise.or (Bitwise.shiftLeftBy 4 h) l


codeToNibble : Int -> Int
codeToNibble code =
    if 0x30 <= code && code <= 0x39 then
        code - 0x30

    else if 0x61 <= code && code <= 0x66 then
        code - 0x57

    else if 0x41 <= code && code <= 0x46 then
        code - 0x37

    else
        -1
