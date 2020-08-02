module Routing exposing (matchers, parseLocation, routeContent)

import Chapters.Chapter exposing (view)
import Dict
import Html exposing (Html, text)
import Models exposing (MaybeAsset(..), Model, Route(..), Language(..))
import Msgs exposing (Msg)
import Url.Parser exposing (Parser, oneOf, map, top, s, string, (</>), parse)
import Url exposing (Url)
import View exposing (templateChapter, templateHome, templatePages, viewAbout, viewChapterList, viewHome)
import Language exposing (removeLanguage)


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
parseLocation lang_location =
    let location = removeLanguage lang_location
    in
        case parse matchers location of
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
                maybeChapter =
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
                    [ Chapters.Chapter.view model.language maybeChapter ]
            in
            templateChapter model maybeChapter content

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
