port module Image exposing (..)

type alias Image =
    { uri : String
    , width : Int
    , height : Int
    , alt : String
    , title : String
    , derivatives : List Derivative
    , load: Bool
    }

emptyImage = Image "" 0 0 "" "" [] False

type alias Derivative =
    { uri : String
    , size : String
    }
