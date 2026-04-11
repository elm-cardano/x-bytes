module XBytes exposing
    ( XBytes
    , fromHex, fromHexUnchecked, toHex
    , fromBytes, toBytes
    , fromText, toText
    , empty, isEmpty, width
    , reverse, append, concat, join
    , slice, left, right, dropLeft, dropRight
    , decoder, encode
    , jsonEncode, jsonDecoder
    )

{-| Comparable byte sequences backed by a hex string.

`XBytes` is an opaque type that wraps a lowercase hex `String`.
Unlike `Bytes`, two `XBytes` values can be compared with `==`.


# Hex conversion

@docs XBytes
@docs fromHex, fromHexUnchecked, toHex


# Bytes conversion

@docs fromBytes, toBytes


# Text conversion

@docs fromText, toText


# Common operations

@docs empty, isEmpty, width
@docs reverse, append, concat, join
@docs slice, left, right, dropLeft, dropRight


# Bytes.Decode / Bytes.Encode interop

@docs decoder, encode


# JSON

@docs jsonEncode, jsonDecoder

-}

import Bytes exposing (Bytes)
import Bytes.Decode as Decode
import Bytes.Encode as Encode
import Hex
import Json.Decode as JD
import Json.Encode as JE



-- TYPE


{-| An opaque byte sequence backed by a lowercase hex string.
Supports structural equality via `==`.
-}
type XBytes
    = XBytes String



-- HEX CONVERSION


{-| Create `XBytes` from a hex string, validating the input.
Returns `Nothing` if the string has odd length or contains non-hex characters.

    fromHex "deadbeef"
        == Just
        ... fromHex "nope"
        == Nothing

-}
fromHex : String -> Maybe XBytes
fromHex str =
    Hex.toBytes str
        |> Maybe.map (\_ -> XBytes (String.toLower str))


{-| Create `XBytes` from a lowercase hex string without validation.
The caller must ensure the input is a valid, even-length, lowercase hex string.
-}
fromHexUnchecked : String -> XBytes
fromHexUnchecked str =
    XBytes str


{-| Extract the lowercase hex string from `XBytes`.

    toHex (fromHexUnchecked "deadbeef") == "deadbeef"

-}
toHex : XBytes -> String
toHex (XBytes hex) =
    hex



-- BYTES CONVERSION


{-| Convert `Bytes` to `XBytes`.
-}
fromBytes : Bytes -> XBytes
fromBytes bytes =
    XBytes (Hex.fromBytes bytes)


{-| Convert `XBytes` to `Bytes`.
-}
toBytes : XBytes -> Bytes
toBytes (XBytes hex) =
    Hex.toBytesUnchecked hex



-- TEXT CONVERSION


{-| Encode a UTF-8 `String` as `XBytes`.

    toHex (fromText "A") == "41"

-}
fromText : String -> XBytes
fromText str =
    XBytes (Hex.fromBytes (Encode.encode (Encode.string str)))


{-| Decode `XBytes` as a UTF-8 `String`.
Returns `Nothing` if the bytes are not valid UTF-8.

    toText (fromHexUnchecked "41") == Just "A"

-}
toText : XBytes -> Maybe String
toText xb =
    let
        bytes : Bytes
        bytes =
            toBytes xb
    in
    Decode.decode (Decode.string (Bytes.width bytes)) bytes



-- COMMON OPERATIONS


{-| An empty byte sequence.

    toHex empty == ""

-}
empty : XBytes
empty =
    XBytes ""


{-| Check if the byte sequence is empty.

    isEmpty empty == True

-}
isEmpty : XBytes -> Bool
isEmpty (XBytes hex) =
    String.isEmpty hex


{-| The number of bytes.

    width (fromHexUnchecked "deadbeef") == 2

-}
width : XBytes -> Int
width (XBytes hex) =
    String.length hex // 2


{-| Reverse the byte order.

    toHex (reverse (fromHexUnchecked "0102")) == "0201"

-}
reverse : XBytes -> XBytes
reverse (XBytes hex) =
    XBytes (reverseHexPairs hex (String.length hex) "")


reverseHexPairs : String -> Int -> String -> String
reverseHexPairs hex remaining acc =
    if remaining <= 0 then
        acc

    else
        reverseHexPairs hex
            (remaining - 2)
            (acc ++ String.slice (remaining - 2) remaining hex)


{-| Append two byte sequences.

    toHex (append (fromHexUnchecked "dead") (fromHexUnchecked "beef"))
        == "deadbeef"

-}
append : XBytes -> XBytes -> XBytes
append (XBytes a) (XBytes b) =
    XBytes (a ++ b)


{-| Concatenate a list of byte sequences.

    toHex (concat [ fromHexUnchecked "de", fromHexUnchecked "ad" ])
        == "dead"

-}
concat : List XBytes -> XBytes
concat list =
    XBytes (String.concat (List.map toHex list))


{-| Join a list of byte sequences with a separator.

    toHex (join (fromHexUnchecked "00") [ fromHexUnchecked "aa", fromHexUnchecked "bb" ])
        == "aa00bb"

-}
join : XBytes -> List XBytes -> XBytes
join (XBytes sep) list =
    XBytes (String.join sep (List.map toHex list))


{-| Slice bytes from index `start` (inclusive) to `end` (exclusive).
Indices are byte offsets, following the same semantics as `String.slice`.

    toHex (slice 1 3 (fromHexUnchecked "deadbeef")) == "adbe"

-}
slice : Int -> Int -> XBytes -> XBytes
slice start end (XBytes hex) =
    XBytes (String.slice (start * 2) (end * 2) hex)


{-| Take the first `n` bytes.

    toHex (left 2 (fromHexUnchecked "deadbeef")) == "dead"

-}
left : Int -> XBytes -> XBytes
left n (XBytes hex) =
    XBytes (String.left (n * 2) hex)


{-| Take the last `n` bytes.

    toHex (right 2 (fromHexUnchecked "deadbeef")) == "beef"

-}
right : Int -> XBytes -> XBytes
right n (XBytes hex) =
    XBytes (String.right (n * 2) hex)


{-| Drop the first `n` bytes.

    toHex (dropLeft 1 (fromHexUnchecked "deadbeef")) == "adbeef"

-}
dropLeft : Int -> XBytes -> XBytes
dropLeft n (XBytes hex) =
    XBytes (String.dropLeft (n * 2) hex)


{-| Drop the last `n` bytes.

    toHex (dropRight 1 (fromHexUnchecked "deadbeef")) == "deadbe"

-}
dropRight : Int -> XBytes -> XBytes
dropRight n (XBytes hex) =
    XBytes (String.dropRight (n * 2) hex)



-- BYTES.DECODE / BYTES.ENCODE INTEROP


{-| Run a `Bytes.Decode.Decoder` on the underlying bytes.

    decode Bytes.Decode.unsignedInt8 (fromHexUnchecked "ff") == Just 255

-}
decoder : Decode.Decoder a -> XBytes -> Maybe a
decoder dec xb =
    Decode.decode dec (toBytes xb)


{-| Run a `Bytes.Encode.Encoder` and wrap the result as `XBytes`.

    toHex (encode (Bytes.Encode.unsignedInt8 255)) == "ff"

-}
encode : Encode.Encoder -> XBytes
encode encoder =
    fromBytes (Encode.encode encoder)



-- JSON


{-| Encode `XBytes` as a JSON string (lowercase hex).
-}
jsonEncode : XBytes -> JE.Value
jsonEncode (XBytes hex) =
    JE.string hex


{-| Decode a JSON string as `XBytes`, validating hex content.
Fails if the string is not valid hex.
-}
jsonDecoder : JD.Decoder XBytes
jsonDecoder =
    JD.string
        |> JD.andThen
            (\str ->
                case fromHex str of
                    Just xb ->
                        JD.succeed xb

                    Nothing ->
                        JD.fail ("Invalid hex string: \"" ++ str ++ "\"")
            )
