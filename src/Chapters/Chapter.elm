module Chapters.Chapter exposing (replaceChapter, view, viewChapter, viewChapterContent, viewSection, sectionId)

import Dict exposing (Dict)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.Lazy exposing (..)
import Html.Keyed
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
    List.append [ ("chapter_title", h1 [ class "chapter-title hidden" ] [ text chapter.title ]) ] (viewChapterContent chapter.content)
        |> Html.Keyed.node "div" []


viewChapterContent : List Section -> List (String, Html Msg)
viewChapterContent model =
    List.map viewSection model


viewSection : Section -> (String, Html Msg)
viewSection model =
    let  section_id = sectionId model.chapter model.id in
    case model.sectionType of
        SingleImage ->
            let
                classes =
                    [ ( "section-single-image", True )
                    , ( "zoomed", model.zoomed )
                    , ( "not-loaded", not model.image.load )
                    ]
            in
            (section_id, lazy2 skeletonRow [ classList classes, id section_id ]
                [ viewImage
                    [ class "u-full-width"
                    , sizes [ "100w" ]
                    , onClickZoom (Msgs.ToggleZoomedImage model.chapter model.id)
                    ]
                    model.image
                ]
            )

        FullWidthSingleImage ->
            let
                classes =
                    [ ( "section-full-width-image", True )
                    , ( "zoomed", model.zoomed )
                    , ( "not-loaded", not model.image.load )
                    ]
            in
            (section_id, lazy2 skeletonRowFullWidth [ classList classes, id section_id ]
                [ viewImage
                    [ class "u-full-width"
                    , sizes [ "100w" ]
                    , onClickZoom (Msgs.ToggleZoomedImage model.chapter model.id)
                    ]
                    model.image
                ]
            )
        FoldedImage ->
            let
                classes =
                    [ ( "section-folded-image", True )
                    , ( "zoomed", model.zoomed )
                    , ( "not-loaded", not model.image.load )
                    ]
            in
            (section_id, lazy2 skeletonRowFullWidth [ classList classes, id section_id ]
                [ viewImage
                    [ class "u-full-width"
                    , sizes [ "100w" ]
                    , onClickZoom (Msgs.ToggleZoomedImage model.chapter model.id)
                    ]
                    model.image
                ]
            )

        Spacer ->
            (section_id, skeletonRowFullWidth [ class "section-spacer" ] [])

        TitlePanel features ->
            let
                classes =
                    [ ( "section-title", True )
                    , ( "not-loaded", not model.image.load )
                    ]
            in
            (section_id, lazy2 skeletonRow [ classList classes, id section_id ]
                [ viewImage [] model.image
                , h2 [ class "chapter-title" ] [ text features.title ]
                , h3 [ class "author" ] [ text features.author ]
                , Markdown.toHtmlWith markdownOptions [ class "extra" ] features.extra
                , div [ class "copyright" ] [ text features.copyright ]
                ]
            )

        Text text ->
            (section_id, skeletonRow [ class "section-text" ]
                [ Markdown.toHtmlWith markdownOptions [ class "text-content" ] text
                ]
            )

sectionId : String -> Int -> String
sectionId chapter section =
    "section:" ++ chapter ++ ":" ++ String.fromInt section
