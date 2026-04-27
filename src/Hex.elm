module Hex exposing (fromBytes, fromWord32, toBytes, toBytesUnchecked)

{-| Convert between `Bytes` and hexadecimal strings.

  - [`fromBytes`](#fromBytes) encodes `Bytes` into a lowercase hex `String`.
  - [`fromWord32`](#fromWord32) encodes a 32-bit `Int` into a lowercase 2-char hex `String`.
  - [`toBytes`](#toBytes) decodes a hex `String` (mixed-case) into `Bytes`, with validation.
  - [`toBytesUnchecked`](#toBytesUnchecked) decodes a lowercase hex `String` into `Bytes`, without validation.

@docs fromBytes, fromWord32, toBytes, toBytesUnchecked

-}

import Bitwise
import Bytes exposing (Bytes, Endianness(..))
import Bytes.Decode as Decode exposing (Decoder)
import Bytes.Encode as Encode
import Hex.Internal exposing (hexPairAt, lookupByte)



-- FROM BYTES
--
-- Strategy: decode the input Bytes using a loop that reads Int32 words
-- via Decode.map5 (5 words = 20 bytes per iteration) to minimize loop
-- overhead. Each word is split into 4 bytes, each mapped to a 2-char
-- hex string via a 256-branch `case` on Int. Results are accumulated
-- into a single String via (++), which V8 implements as O(1) ConsString
-- rope nodes, flattened in O(n) on first read.


{-| Convert `Bytes` to a lowercase hex string.

    import Bytes.Encode as Encode

    Encode.encode (Encode.unsignedInt8 255)
        |> fromBytes
    --> "ff"

-}
fromBytes : Bytes -> String
fromBytes bytes =
    let
        width : Int
        width =
            Bytes.width bytes

        fullWords : Int
        fullWords =
            width // 4

        remainder : Int
        remainder =
            modBy 4 width
    in
    Decode.decode (fromBytesLoop fullWords remainder) bytes
        |> Maybe.withDefault ""


{-| Loop state for fromBytes. Uses a record (not a tuple) because JS engines
optimize fixed-shape objects via hidden classes, giving ~5-10% speedup.
The `acc` field is a String accumulator grown with (++).
-}
type alias EncState =
    { words : Int, rem : Int, acc : String }


fromBytesLoop : Int -> Int -> Decoder String
fromBytesLoop fullWords remainder =
    Decode.loop { words = fullWords, rem = remainder, acc = "" } encStep


{-| Each Decode.loop iteration has overhead (record alloc, Loop wrapper, function
call). Decode.map5 reads 5 Int32s (20 bytes) per iteration, amortizing that cost.
Falls back to map2 then map for the tail. Single-word loops are 17% slower.
-}
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
                            ++ fromWord32 w1
                            ++ fromWord32 w2
                            ++ fromWord32 w3
                            ++ fromWord32 w4
                            ++ fromWord32 w5
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
                    , acc = state.acc ++ fromWord32 w1 ++ fromWord32 w2
                    }
            )
            (Decode.unsignedInt32 BE)
            (Decode.unsignedInt32 BE)

    else if state.words == 1 then
        Decode.unsignedInt32 BE
            |> Decode.map
                (\word ->
                    Decode.Loop { words = 0, rem = state.rem, acc = state.acc ++ fromWord32 word }
                )

    else if state.rem > 0 then
        Decode.unsignedInt8
            |> Decode.map
                (\byte ->
                    Decode.Loop { words = 0, rem = state.rem - 1, acc = state.acc ++ lookupByte byte }
                )

    else
        Decode.succeed (Decode.Done state.acc)


{-| Join 4 byte lookups into one 8-char string inline. This keeps the
accumulator list 4x shorter than pushing individual 2-char strings,
which matters because List.reverse + String.concat scale with list length.
-}
fromWord32 : Int -> String
fromWord32 word =
    lookupByte (Bitwise.and 0xFF (Bitwise.shiftRightZfBy 24 word))
        ++ lookupByte (Bitwise.and 0xFF (Bitwise.shiftRightZfBy 16 word))
        ++ lookupByte (Bitwise.and 0xFF (Bitwise.shiftRightZfBy 8 word))
        ++ lookupByte (Bitwise.and 0xFF word)



-- TO BYTES
--
-- Strategy: iterate the hex string 8 chars at a time via String.slice,
-- parsing each pair of hex digits into a byte value with a sentinel (-1)
-- for invalid characters. Four bytes are packed into a single
-- Encode.unsignedInt32, reducing the encoder list to 1/4 the length
-- (fewer list cons cells, faster Encode.sequence traversal). Remaining
-- bytes (0-3) are encoded individually as unsignedInt8.


{-| Parse a hex string into `Bytes`. Returns `Nothing` if the string has
odd length or contains non-hex characters. Accepts both uppercase and
lowercase hex digits.

    toBytes "ff"
    --> Just <1 byte>

    toBytes "zz"
    --> Nothing

-}
toBytes : String -> Maybe Bytes
toBytes hex =
    let
        len : Int
        len =
            String.length hex
    in
    if modBy 2 len /= 0 then
        Nothing

    else
        let
            byteCount : Int
            byteCount =
                len // 2

            fullWords : Int
            fullWords =
                byteCount // 4
        in
        decodeWords hex 0 fullWords []
            |> Maybe.andThen
                (\( offset, acc ) ->
                    let
                        remainder : Int
                        remainder =
                            modBy 4 byteCount
                    in
                    decodeRemainder hex offset remainder acc
                )
            |> Maybe.map
                (\encoders ->
                    Encode.encode (Encode.sequence (List.reverse encoders))
                )


decodeWords : String -> Int -> Int -> List Encode.Encoder -> Maybe ( Int, List Encode.Encoder )
decodeWords hex offset remaining acc =
    if remaining > 0 then
        let
            b0 : Int
            b0 =
                hexPairAt hex offset

            b1 : Int
            b1 =
                hexPairAt hex (offset + 2)

            b2 : Int
            b2 =
                hexPairAt hex (offset + 4)

            b3 : Int
            b3 =
                hexPairAt hex (offset + 6)
        in
        if b0 < 0 || b1 < 0 || b2 < 0 || b3 < 0 then
            Nothing

        else
            let
                word : Int
                word =
                    Bitwise.or
                        (Bitwise.or (Bitwise.shiftLeftBy 24 b0) (Bitwise.shiftLeftBy 16 b1))
                        (Bitwise.or (Bitwise.shiftLeftBy 8 b2) b3)
            in
            decodeWords hex (offset + 8) (remaining - 1) (Encode.unsignedInt32 BE word :: acc)

    else
        Just ( offset, acc )


decodeRemainder : String -> Int -> Int -> List Encode.Encoder -> Maybe (List Encode.Encoder)
decodeRemainder hex offset remaining acc =
    if remaining > 0 then
        let
            byte : Int
            byte =
                hexPairAt hex offset
        in
        if byte < 0 then
            Nothing

        else
            decodeRemainder hex (offset + 2) (remaining - 1) (Encode.unsignedInt8 byte :: acc)

    else
        Just acc



-- TO BYTES (UNCHECKED)
--
-- Same Int32-batched strategy as toBytes, but skips all validation:
-- no Maybe wrapping, no sentinel checks, and a branchless nibble
-- conversion formula. ~20% faster than toBytes.


{-| Parse a lowercase hex string into `Bytes`. Does not validate the input:
assumes even length and only lowercase hex characters (0-9, a-f).
About 20% faster than [`toBytes`](#toBytes).

    toBytesUnchecked "ff"
    --> <1 byte>

-}
toBytesUnchecked : String -> Bytes
toBytesUnchecked hex =
    let
        len : Int
        len =
            String.length hex

        byteCount : Int
        byteCount =
            len // 2

        fullWords : Int
        fullWords =
            byteCount // 4

        remainder : Int
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
            b0 : Int
            b0 =
                uncheckedPairAt hex offset

            b1 : Int
            b1 =
                uncheckedPairAt hex (offset + 2)

            b2 : Int
            b2 =
                uncheckedPairAt hex (offset + 4)

            b3 : Int
            b3 =
                uncheckedPairAt hex (offset + 6)

            word : Int
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


{-| Branchless nibble conversion for lowercase hex only.
`code - 48` maps '0'-'9' to 0-9 and 'a'-'f' to 49-54.
`Bitwise.shiftRightZfBy 6 code` is 1 for letters (codes 97-102) and 0 for
digits (codes 48-57), so `39 * (code >>> 6)` subtracts 39 from letters only,
mapping 'a'-'f' to 10-15. Replaces a 3-branch if-else chain.
-}
uncheckedNibble : String -> Int
uncheckedNibble s =
    case String.uncons s of
        Just ( c, _ ) ->
            let
                code : Int
                code =
                    Char.toCode c
            in
            code - 48 - 39 * Bitwise.shiftRightZfBy 6 code

        Nothing ->
            0
