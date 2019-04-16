module Routing exposing (matchers, parseLocation, routeContent)

import Chapters.Chapter exposing (view)
import Dict exposing (Dict)
import Html exposing (Html, text)
import Models exposing (ChapterId, MaybeAsset(..), Model, Route(..))
import Msgs exposing (Msg)
import Navigation exposing (Location)
import Url.Parser exposing (..)
import Url
import View exposing (templateChapter, templateHome, templatePages, viewAbout, viewChapterList, viewHome)


matchers : Parser (Route -> a) a
matchers =
    oneOf
        [ map HomeRoute     top
        , map ChaptersRoute (s "chapters" </> top)
        , map ChapterRoute  (s "chapters" </> string)
        , map ChaptersRoute (s "chapters")
        , map AboutRoute    (s "about")
        ]


parseLocation : Url -> Route
parseLocation location =
    case parsePath matchers location of
        Just route ->
            route

        Nothing ->
            NotFoundRoute


routeContent : Model -> List (Html Msg)
routeContent model =
    case model.route of
        HomeRoute ->
            let
                content =
                    viewHome model
            in
            templateHome model content

        ChaptersRoute ->
            let
                content =
                    viewChapterList model
            in
            templatePages model content

        ChapterRoute id ->
            let
                chapter =
                    case model.chapters of
                        Nothing ->
                            AssetLoading

                        Just chapters ->
                            let
                                c =
                                    Dict.get id chapters
                            in
                            case c of
                                Nothing ->
                                    AssetNotFound

                                Just chapter ->
                                    Asset chapter

                content =
                    [ Chapters.Chapter.view chapter ]
            in
            templateChapter model chapter content

        AboutRoute ->
            let
                content =
                    [ viewAbout model ]
            in
            templatePages model content

        NotFoundRoute ->
            let
                content =
                    [ text "Not Found" ]
            in
            templatePages model content
