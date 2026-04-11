module XBytes.V2 exposing (concat, fromHex)

{-| Baseline copy of XBytes optimized functions for benchmarking.

Kept identical to src/XBytes.elm so future changes can be compared
against this snapshot.

-}

import Hex.Internal
import XBytes exposing (XBytes)


fromHex : String -> Maybe XBytes
fromHex str =
    if modBy 2 (String.length str) /= 0 then
        Nothing

    else if Hex.Internal.isValidHex str then
        Just (XBytes.fromHexUnchecked (String.toLower str))

    else
        Nothing


concat : List XBytes -> XBytes
concat list =
    XBytes.fromHexUnchecked (List.foldl (\xb acc -> acc ++ XBytes.toHex xb) "" list)
