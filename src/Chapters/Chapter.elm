module Chapters.Chapter exposing (replaceChapter, view, viewChapter, viewChapterContent, viewSection)

import Dict
import Html exposing (Html, div, h1, h2, h3, text)
import Html.Attributes exposing (class, classList, id)
import Html.Lazy exposing (lazy2)
import Html.Keyed
import Markdown
import Models exposing (Chapter, MaybeAsset(..), Model, Section, SectionType(..), Language(..), Phrase(..))
import Msgs exposing (Msg)
import Skeleton exposing (skeletonRow, skeletonRowFullWidth)
import View exposing (loading, viewImage, markdownOptions)
import View.Attributes exposing (onClickZoom, sizes)
import Language exposing (translate, translateMonth)
import Time
import Chapters.View exposing (sectionId)


view : Language -> MaybeAsset Chapter -> Html Msg
view lang model =
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
            viewChapter lang chapter


replaceChapter : Model -> Chapter -> Model
replaceChapter model newchapter =
    case model.chapters of
        Nothing ->
            { model | chapters = Just (Dict.singleton newchapter.path newchapter) }

        Just chapters ->
            { model | chapters = Just (Dict.insert newchapter.path newchapter chapters) }


viewChapter : Language -> Chapter -> Html Msg
viewChapter lang chapter =
    List.append [ ("chapter_title", h1 [ class "chapter-title hidden" ] [ text chapter.title ]) ] (viewChapterContent lang chapter.content)
        |> Html.Keyed.node "div" []


viewChapterContent : Language -> List Section -> List (String, Html Msg)
viewChapterContent lang model =
    List.map (viewSection lang) model

viewSection : Language -> Section -> (String, Html Msg)
viewSection lang section =
  if section.preview then viewSectionPreview lang section else viewSectionFull section

viewSectionPreview : Language -> Section -> (String, Html Msg)
viewSectionPreview lang section =
  let
    content = skeletonRow [ class "section-preview" ]
      [ h2 []
        [ text (translate lang UpdateSchedule)
        , text (viewDate lang section.date)
        ]
      ]
  in (sectionId section.chapter section.id, content)

viewDate : Language -> Time.Posix -> String
viewDate lang time =
  let
    month = Time.toMonth Time.utc time |> translateMonth lang
    day = Time.toDay Time.utc time |> String.fromInt
  in
    case lang of
      Pt_Br -> day ++ " de " ++ month
      En    -> month ++ " " ++ day

viewSectionFull : Section -> (String, Html Msg)
viewSectionFull model =
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
            (section_id, skeletonRow [ class "section-text", id section_id ]
                [ Markdown.toHtmlWith markdownOptions [ class "text-content" ] text
                ]
            )

        AudioSection _ _ ->
          (section_id, skeletonRow [ class "section-audio", id section_id ] [])
