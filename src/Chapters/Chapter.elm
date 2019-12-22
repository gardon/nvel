module Chapters.Chapter exposing (replaceChapter, view, viewChapter, viewChapterContent, viewSection)

import Dict exposing (Dict)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.Lazy exposing (..)
import Markdown
import Models exposing (..)
import Msgs exposing (Msg)
import Skeleton exposing (..)
import View exposing (..)
import View.Attributes exposing (..)


view : MaybeAsset Chapter -> Html Msg
view model =
    case model of
        AssetLoading ->
            div []
                [ h1 [] [ loading "Loading" ]
                ]

        AssetNotFound ->
            div [ class "container" ]
                [ h1 [] [ text "Chapter not Found" ]
                ]

        Asset chapter ->
            viewChapter chapter


replaceChapter : Model -> Chapter -> Model
replaceChapter model newchapter =
    case model.chapters of
        Nothing ->
            { model | chapters = Just (Dict.singleton newchapter.path newchapter) }

        Just chapters ->
            { model | chapters = Just (Dict.insert newchapter.path newchapter chapters) }


viewChapter : Chapter -> Html Msg
viewChapter chapter =
    List.append [ h1 [ class "chapter-title hidden" ] [ text chapter.title ] ] (viewChapterContent chapter.content)
        |> div []


viewChapterContent : List Section -> List (Html Msg)
viewChapterContent model =
    List.map viewSection model


viewSection : Section -> Html Msg
viewSection model =
    case model.sectionType of
        SingleImage ->
            let
                classes =
                    [ ( "section-single-image", True )
                    , ( "zoomed", model.zoomed )
                    , ( "not-loaded", not model.image.load )
                    ]
            in
            lazy2 skeletonRow [ classList classes, "section:" ++ model.chapter ++ ":" ++ String.fromInt model.id |> id ]
                [ viewImage
                    [ class "u-full-width"
                    , sizes [ "100w" ]
                    , onClickZoom (Msgs.ToggleZoomedImage model.chapter model.id)
                    ]
                    model.image
                ]

        FullWidthSingleImage ->
            let
                classes =
                    [ ( "section-full-width-image", True )
                    , ( "zoomed", model.zoomed )
                    , ( "not-loaded", not model.image.load )
                    ]
            in
            lazy2 skeletonRowFullWidth [ classList classes, "section:" ++ model.chapter ++ ":" ++ String.fromInt model.id |> id ]
                [ viewImage
                    [ class "u-full-width"
                    , sizes [ "100w" ]
                    , onClickZoom (Msgs.ToggleZoomedImage model.chapter model.id)
                    ]
                    model.image
                ]

        FoldedImage ->
            let
                classes =
                    [ ( "section-folded-image", True )
                    , ( "zoomed", model.zoomed )
                    , ( "not-loaded", not model.image.load )
                    ]
            in
            lazy2 skeletonRowFullWidth [ classList classes, "section:" ++ model.chapter ++ ":" ++ String.fromInt model.id |> id ]
                [ viewImage
                    [ class "u-full-width"
                    , sizes [ "100w" ]
                    , onClickZoom (Msgs.ToggleZoomedImage model.chapter model.id)
                    ]
                    model.image
                ]

        Spacer ->
            skeletonRowFullWidth [ class "section-spacer" ] []

        TitlePanel features ->
            let
                classes =
                    [ ( "section-title", True )
                    , ( "not-loaded", not model.image.load )
                    ]

                elementid =
                    "section:" ++ model.chapter ++ ":" ++ String.fromInt model.id
            in
            lazy2 skeletonRow [ classList classes, id elementid ]
                [ viewImage [] model.image
                , h2 [ class "chapter-title" ] [ text features.title ]
                , h3 [ class "author" ] [ text features.author ]
                , Markdown.toHtmlWith markdownOptions [ class "extra" ] features.extra
                , div [ class "copyright" ] [ text features.copyright ]
                ]

        Text text ->
            skeletonRow [ class "section-text" ]
                [ Markdown.toHtmlWith markdownOptions [ class "text-content" ] text
                ]
