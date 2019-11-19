module View.Attributes exposing (dataAttr, onLinkClick, sizes, srcset)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Image exposing (Derivative)
import Json.Decode as Decode



-- Needs a recursive elaboration


srcset : List Derivative -> Attribute msg
srcset derivatives =
    derivatives
        |> List.map (\derivative -> derivative.uri ++ " " ++ derivative.size)
        |> List.intersperse ", "
        |> String.concat
        |> attribute "srcset"


sizes : List String -> Attribute msg
sizes sizesList =
    sizesList
        |> List.intersperse ", "
        |> String.concat
        |> attribute "sizes"


dataAttr : String -> String -> Attribute msg
dataAttr attr value =
    attribute ("data-" ++ attr) value


onLinkClick : msg -> Attribute msg
onLinkClick message =
    let
        options =
            { stopPropagation = False
            , preventDefault = True
            }
    in
    onClick message
