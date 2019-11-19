module Msgs exposing (Msg(..))

import Dict exposing (Dict)
import Http exposing (Error)
import Image exposing (Image)
import Models exposing (..)
import Browser
import Url


type Msg
    = ChaptersLoad (Result Error (Dict String Chapter))
    | ChapterContentLoad (Result Error Chapter)
    | UpdateSiteInfo (Result Error SiteInformation)
    | OnLocationChange Url.Url
    | ChangeLocation Browser.UrlRequest
    | Navbar NavbarAction
    | ToggleZoomedImage String Int
    --| ScrollTop (Result Dom.Error ())
    | LoadImage String Int
    | NoOp
