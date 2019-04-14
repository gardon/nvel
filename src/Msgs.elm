module Msgs exposing (Msg(..))

import Dict exposing (Dict)
import Dom
import Http exposing (Error)
import Image exposing (Image)
import Models exposing (..)
import Navigation exposing (Location)


type Msg
    = ChaptersLoad (Result Error (Dict String Chapter))
    | ChapterContentLoad (Result Error Chapter)
    | UpdateSiteInfo (Result Error SiteInformation)
    | OnLocationChange Location
    | ChangeLocation String
    | Navbar NavbarAction
    | ToggleZoomedImage String Int
    | ScrollTop (Result Dom.Error ())
    | LoadImage String Int
    | NoOp
