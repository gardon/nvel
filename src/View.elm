module View exposing
  ( linkButton
  , linkButtonBig
  , linkButtonPrimary
  , loading
  , markdownOptions
  , sortChapterList
  , templateChapter
  , templateHome
  , templatePages
  , viewAbout
  , viewChapterFeatured
  , viewChapterFeaturedCurrent
  , viewChapterFeaturedNext
  , viewChapterList
  , viewChapterListItem
  , viewChapterNavItem
  , viewChapterNavbar
  , viewChapterNavigation
  , viewDeviantArtLink
  , viewFacebookPageLink
  , viewHome
  , viewImage
  , viewIndexIcon
  , viewInstagramLink
  , viewMenu
  , viewMenuItem
  , viewSocialIcon
  , viewSocialLinks
  , viewTitle )

import Time
import Dict exposing (Dict)
import Html exposing (Html, div, a, h1, h2, h3, text, span, small, Attribute, img, nav, ul, li, button)
import Html.Attributes exposing (class, style, href, src, target, width, height, alt, title, hreflang)
import Html.Events exposing (onClick)
import Image exposing (Image)
import Language exposing (translate, translateMonth, localizePath, removeLanguage)
import Markdown
import Models exposing (Model, Phrase(..), Chapter, Language, MenuItem, SocialIconType(..), MaybeAsset(..))
import Msgs exposing (Msg(..))
import Skeleton exposing (skeletonRow, skeletonRowFullWidth, skeletonGridSize, GridSize(..), skeletonColumn)
import Svg exposing (path, svg)
import Svg.Attributes exposing (d, viewBox, xmlSpace)
import View.Attributes exposing (srcset)
import View.Mailchimp exposing (mailchimpBlock)
import Audio exposing (audioIconOn, audioIconOff)

viewHome : Model -> List (Html Msg)
viewHome model =
    case model.chapters of
        Nothing ->
            [ loading (translate model.language Loading) ]

        Just _ ->
            let

                firstrow =
                      skeletonRow [] [ viewPreface model ]

                secondrow =
                    div [] <| viewChapterList model

                thirdrow =
                    skeletonRowFullWidth [ class "inverted" ]
                        [ mailchimpBlock model
                        -- ADD NEWS
                        ]
            in
            [ div []
                [ firstrow
                , secondrow
                , thirdrow
                ]
            ]

viewChapterList : Model -> List (Html Msg)
viewChapterList model =
    case model.chapters of
        Nothing ->
            [ loading "Loading chapters..." ]

        Just chapters ->
            let
                list = h2 [] [ text <| translate model.language MenuArchive ] ::
                    List.map (viewChapterListItem model.language) (sortChapterList chapters)

                firstcol = skeletonColumn TenColumns [ class "offset-by-one" ] list
            in
              skeletonRow [] [ firstcol ] |> List.singleton


sortChapterList : Dict String Chapter -> List Chapter
sortChapterList chapters =
    List.sortBy .index (Dict.values chapters)


viewChapterFeatured : Language -> Phrase -> String -> Chapter -> Html Msg
viewChapterFeatured lang caption_phrase featured_class chapter =
    let
        chapterPath =
            "/chapters/" ++ chapter.path
            |> localizePath lang

        chapterNumber =
            "#" ++ String.fromInt chapter.index ++ " "

        caption =
            translate lang caption_phrase

        date =
          if Time.posixToMillis chapter.date < Time.posixToMillis chapter.updated then
            chapter.updated
          else
            chapter.date
    in
    div ( [ class ("chapter-featured " ++ featured_class), style "background-image" ("url(" ++ chapter.featured_image.uri ++ ");") ] ++ skeletonGridSize SixColumns )
        [ a [ href chapterPath ]
            [ h2 [] [ text caption ]
            , h3 [] [ span [] [ text chapterNumber ], text chapter.title, small [] [ text (viewFeaturedDate lang date) ] ]
            ]
        ]

viewDate : Language -> Time.Posix -> String
viewDate lang time =
  let
    year = Time.toYear Time.utc time |> String.fromInt
    month = Time.toMonth Time.utc time |> translateMonth lang
    day = Time.toDay Time.utc time |> String.fromInt
  in
    year ++ " " ++ month ++ " " ++ day

viewFeaturedDate : Language -> Time.Posix -> String
viewFeaturedDate lang time =
  let
    month = Time.toMonth Time.utc time |> translateMonth lang
    day = Time.toDay Time.utc time |> String.fromInt
  in
    month ++ " " ++ day

viewChapterFeaturedCurrent : Language -> Chapter -> Html Msg
viewChapterFeaturedCurrent lang chapter =
    viewChapterFeatured lang CurrentChapter "current-chapter" chapter



viewChapterFeaturedNext : Language -> Chapter -> Html Msg
viewChapterFeaturedNext lang chapter =
    viewChapterFeatured lang NextChapter "next-chapter offset-by-three" chapter


linkButtonPrimary : String -> String -> Html Msg
linkButtonPrimary path title =
    linkButton [ class "button-primary" ] path title


linkButton : List (Attribute Msg) -> String -> String -> Html Msg
linkButton attr path title =
    a ([ href path, class "button" ] ++ attr) [ text title ]


linkButtonBig : String -> String -> Html Msg
linkButtonBig path title =
    linkButton [ class "big" ] path title


viewChapterListItem : Language -> Chapter -> Html Msg
viewChapterListItem lang chapter =
    let
        chapterPath =
            "/chapters/" ++ chapter.path
            |> localizePath lang

        chapterNumber =
            "#" ++ String.fromInt chapter.index
    in
    a [ href chapterPath, class "chapter-list-item" ]
        [ viewImage [] chapter.thumbnail
        , div [ class "description" ]
          [ h3 [] [ span [ class "chapter-number" ] [ text chapterNumber ], text " ", text chapter.title ]
          , text chapter.field_description
          , div [ class "date" ] [ text (viewDate lang chapter.date) ]
          ]
        ]


viewImage : List (Attribute msg) -> Image -> Html msg
viewImage attributes image =
    if image == Image.emptyImage then
        text ""

    else
        let
            newattributes = attributes ++ [ src image.uri ]
        in
        img
            (newattributes
                ++ [ width image.width
                   , height image.height
                   , alt image.alt
                   , title image.title
                   , srcset image.derivatives
                   ]
            )
            []


viewMenu : Model -> List MenuItem -> Html Msg
viewMenu model menu =
    nav [ class "navbar" ]
        [ ul [ class "navbar-list" ] (List.map (viewMenuItem model) menu)
        ]


viewMenuItem : Model -> MenuItem -> Html Msg
viewMenuItem model item =
    let
        activeclass =
            if model.route == item.route then
                "active"

            else
                ""
        itemPath = localizePath model.language item.path
    in
    li [ class "navbar-item bubble", class activeclass ]
        [ a [ href itemPath, class "navbar-link" ] [ text (translate model.language item.title) ]
        ]


viewSocialLinks : Model -> Html Msg
viewSocialLinks model =
    ul [ class "social-links" ]
        [ if model.siteInformation.facebook_page == "" then
            text ""

          else
            li [ class "social-links-item facebook" ] [ viewFacebookPageLink model.siteInformation.facebook_page ]
        , if model.siteInformation.instagram_handle == "" then
            text ""

          else
            li [ class "social-links-item instagram" ] [ viewInstagramLink model.siteInformation.instagram_handle ]
        , if model.siteInformation.deviantart_profile == "" then
            text ""

          else
            li [ class "social-links-item deviantart" ] [ viewDeviantArtLink model.siteInformation.deviantart_profile ]
        ]


viewFacebookPageLink : String -> Html msg
viewFacebookPageLink handle =
    a [ href ("http://www.facebook.com/" ++ handle), class "social-link facebook external-link", target "_blank" ]
        [ viewSocialIcon FacebookIcon
        , text "Facebook"
        ]


viewInstagramLink : String -> Html msg
viewInstagramLink handle =
    a [ href ("http://instagram.com/" ++ handle), class "social-link instagram external-link", target "_blank" ]
        [ viewSocialIcon InstagramIcon
        , text "Instagram"
        ]


viewDeviantArtLink : String -> Html msg
viewDeviantArtLink handle =
    a [ href ("http://" ++ handle ++ ".deviantart.com/"), class "social-link deviantart external-link", target "_blank" ]
        [ viewSocialIcon DeviantArtIcon
        , text "DeviantArt"
        ]


viewSocialIcon : SocialIconType -> Html msg
viewSocialIcon social =
    let
        svgpath =
            case social of
                FacebookIcon ->
                    "M22.675 0h-21.35c-.732 0-1.325.593-1.325 1.325v21.351c0 .731.593 1.324 1.325 1.324h11.495v-9.294h-3.128v-3.622h3.128v-2.671c0-3.1 1.893-4.788 4.659-4.788 1.325 0 2.463.099 2.795.143v3.24l-1.918.001c-1.504 0-1.795.715-1.795 1.763v2.313h3.587l-.467 3.622h-3.12v9.293h6.116c.73 0 1.323-.593 1.323-1.325v-21.35c0-.732-.593-1.325-1.325-1.325z"

                InstagramIcon ->
                    "M12 2.163c3.204 0 3.584.012 4.85.07 3.252.148 4.771 1.691 4.919 4.919.058 1.265.069 1.645.069 4.849 0 3.205-.012 3.584-.069 4.849-.149 3.225-1.664 4.771-4.919 4.919-1.266.058-1.644.07-4.85.07-3.204 0-3.584-.012-4.849-.07-3.26-.149-4.771-1.699-4.919-4.92-.058-1.265-.07-1.644-.07-4.849 0-3.204.013-3.583.07-4.849.149-3.227 1.664-4.771 4.919-4.919 1.266-.057 1.645-.069 4.849-.069zm0-2.163c-3.259 0-3.667.014-4.947.072-4.358.2-6.78 2.618-6.98 6.98-.059 1.281-.073 1.689-.073 4.948 0 3.259.014 3.668.072 4.948.2 4.358 2.618 6.78 6.98 6.98 1.281.058 1.689.072 4.948.072 3.259 0 3.668-.014 4.948-.072 4.354-.2 6.782-2.618 6.979-6.98.059-1.28.073-1.689.073-4.948 0-3.259-.014-3.667-.072-4.947-.196-4.354-2.617-6.78-6.979-6.98-1.281-.059-1.69-.073-4.949-.073zm0 5.838c-3.403 0-6.162 2.759-6.162 6.162s2.759 6.163 6.162 6.163 6.162-2.759 6.162-6.163c0-3.403-2.759-6.162-6.162-6.162zm0 10.162c-2.209 0-4-1.79-4-4 0-2.209 1.791-4 4-4s4 1.791 4 4c0 2.21-1.791 4-4 4zm6.406-11.845c-.796 0-1.441.645-1.441 1.44s.645 1.44 1.441 1.44c.795 0 1.439-.645 1.439-1.44s-.644-1.44-1.439-1.44z"

                DeviantArtIcon ->
                    "M20 4.364v-4.364h-4.364l-.435.439-2.179 4.124-.647.437h-7.375v6h4.103l.359.404-4.462 8.232v4.364h4.509l.435-.439 2.174-4.124.648-.437h7.234v-6h-3.938l-.359-.438z"
    in
    svg
        [ xmlSpace "http://www.w3.org/2000/svg"
        , Svg.Attributes.width "18"
        , Svg.Attributes.height "18"
        , viewBox "0 0 24 24"
        ]
        [ path
            [ d svgpath ]
            []
        ]


viewChapterNavbar : Model -> Chapter -> List (Html Msg)
viewChapterNavbar model chapter =
    let
        lang =
            model.language

        chapterNavigation =
            case model.chapters of
                Nothing ->
                    ul [] []

                Just chapters ->
                    let
                        list =
                            sortChapterList chapters

                        index =
                            chapter.index

                        previous =
                            List.take (index - 1) list
                                |> List.reverse
                                |> List.head

                        next =
                            List.drop index list
                                |> List.head

                    in
                    viewChapterNavigation lang previous chapter next
    in
    [ div [ class "index-icon" ]
        [ a [ href <| localizePath lang "/" ] [ text <| translate model.language MenuHome ]
        ]
    , chapterNavigation
    , viewAudioSwitch model.audio (chapter.audios /= Nothing)
    , viewChapterLanguageSwitcher model chapter
    ]

viewAudioSwitch : Bool -> Bool -> Html Msg
viewAudioSwitch enabled hasAudio =
  if hasAudio then
    div [ class "audio-switcher" ] [button [ onClick ToggleAudio ] <|
      if enabled then
        [ audioIconOn, span [] [ text "Music ON"]]
      else
        [ audioIconOff, span [] [ text "Music OFF" ]]
    ]
  else
    text ""

viewChapterLanguageSwitcher : Model -> Chapter -> Html Msg
viewChapterLanguageSwitcher model chapter =
  List.map (viewChapterLanguageSwitcherLink model chapter) model.languages
  |> ul [ class "language-switcher" ]

viewChapterLanguageSwitcherLink : Model -> Chapter -> Language -> Html Msg
viewChapterLanguageSwitcherLink model chapter lang =
    let
        langcode = Language.toString lang
        maybePath = Dict.get langcode chapter.language_paths
    in
        if model.language == lang then
            text ""
        else
          case maybePath of
            Nothing   -> text ""
            Just path -> li [ hreflang langcode ] [ a [ href (localizePath lang ("/chapters/" ++ path)), hreflang langcode ] [ text langcode ] ]

viewLanguageSwitcher : Model -> Html Msg
viewLanguageSwitcher model =
  List.map (viewLanguageSwitcherLink model) model.languages
  |> ul [ class "language-switcher" ]

viewLanguageSwitcherLink : Model -> Language -> Html Msg
viewLanguageSwitcherLink model lang =
    let originalLocation = removeLanguage model.location
        langcode = Language.toString lang
    in
        if model.language == lang then
            text ""
        else
            li [ hreflang langcode, class "bubble"  ] [ a [ href (localizePath lang originalLocation.path), hreflang langcode ] [ text langcode ] ]


viewChapterNavigation : Language -> Maybe Chapter -> Chapter -> Maybe Chapter -> Html Msg
viewChapterNavigation lang previous current next =
    div [ class "chapter-navigation" ]
        [ ul [ class "previous" ]
            (case previous of
                Just previousChapter ->
                    [ viewChapterNavItem lang previousChapter "«" <| translate lang Previous ]
                Nothing ->
                    []
            )
        , ul [ class "current" ] [ viewChapterNavItem lang current ("#" ++ String.fromInt current.index) current.title]
        , ul [ class "next" ]
            (case next of
                Just nextChapter ->
                    [ viewChapterNavItem lang nextChapter "»" <| translate lang Next ]
                Nothing ->
                    []
            )
        ]


viewChapterNavItem : Language -> Chapter -> String -> String -> Html Msg
viewChapterNavItem lang chapter linkText title =
    let
        chapterPath =
            "/chapters/" ++ chapter.path
            |> localizePath lang

    in
    li []
        [ a [ href chapterPath ]
            [ text linkText
            , span [ class "chapter-title" ] [ text (": " ++ title) ]
            ]
        ]


viewIndexIcon : Html msg
viewIndexIcon =
    let
        svgpath =
            "M4 22h-4v-4h4v4zm0-12h-4v4h4v-4zm0-8h-4v4h4v-4zm3 0v4h17v-4h-17zm0 12h17v-4h-17v4zm0 8h17v-4h-17v4z"
    in
    svg
        [ xmlSpace "http://www.w3.org/2000/svg"
        , Svg.Attributes.width "30"
        , Svg.Attributes.height "30"
        , viewBox "0 0 24 24"
        ]
        [ path
            [ d svgpath ]
            []
        ]


viewTitle : Model -> Html Msg
viewTitle model =
    h1 [ class "site-title" ] [ text model.siteInformation.title ]


loading : String -> Html msg
loading message =
    span [ class "loading-icon" ] [ text message ]


markdownOptions : Markdown.Options
markdownOptions =
    let
        default =
            Markdown.defaultOptions
    in
    { default | githubFlavored = Just { tables = False, breaks = True } }


viewAbout : Model -> Html msg
viewAbout model =
    let
        content =
            model.siteInformation.aboutContent
    in
    if content == "" then
        loading ""

    else
        Markdown.toHtmlWith markdownOptions [ class "container about-container" ] content

viewPreface : Model -> Html msg
viewPreface model =
  if model.siteInformation.preface == "" then
    text ""
  else
    Markdown.toHtmlWith markdownOptions [ class "container preface-container" ] model.siteInformation.preface


viewNavbar : List (Attribute Msg) -> Model -> Html Msg
viewNavbar attributes model =
  div ( class "navbar-container" :: attributes )
    [ div [ class "container" ]
      [ viewMenu model model.menu
      , viewLanguageSwitcher model
      ]
    ]

templateHome : Model -> List (Html Msg) -> List (Html Msg)
templateHome model content =
  [ viewNavbar [ class "home" ] model
  , viewTitleContainer model "title-container"
  , viewTitleContainer model "title-container-mobile"
  ]
    ++ content
    ++ [ div [ class "container footer-container" ]
            [ viewSocialLinks model
            ]
        ]

viewTitleContainer : Model -> String -> Html Msg
viewTitleContainer model class_ =
  let
    list = model.chapters
      |> Maybe.map sortChapterList
      |> Maybe.map List.reverse
      |> Maybe.withDefault []
  in
    div [ class class_, class "home-title", class <| Language.toString model.language ]
    [ viewTitle model
    , case list of
        current :: _ ->
          skeletonRow [ class "home-featured" ] [ viewChapterFeaturedCurrent model.language current ]
        [] ->
          skeletonRow [] []
    ]

templatePages : Model -> List (Html Msg) -> List (Html Msg)
templatePages model content =
    [ viewNavbar [] model
    , div [ class "container title-container" ]
        [ viewTitle model
        ]
    ]
        ++ content
        ++ [ div [ class "container footer-container" ]
                [ viewSocialLinks model
                ]
           ]

templateChapter : Model -> MaybeAsset Chapter -> List (Html Msg) -> List (Html Msg)
templateChapter model chapter content =
    let
        sticky_class =
            if model.navbar then
              "sticky show"
            else
              "sticky"

        navbar =
            case chapter of
                AssetNotFound ->
                    []

                AssetLoading ->
                    []

                Asset current ->
                    viewChapterNavbar model current

        nextchapter =
            case chapter of
                AssetNotFound ->
                    text ""

                AssetLoading ->
                    text ""

                Asset current ->
                    case model.chapters of
                        Nothing ->
                            text ""

                        Just chapters ->
                            let
                                list =
                                    sortChapterList chapters

                                next =
                                    List.drop current.index list
                                        |> List.head
                            in
                            case next of
                                Nothing ->
                                    skeletonRowFullWidth [ class "nextchapter inverted" ] [ mailchimpBlock model ]

                                Just nchapter ->
                                    skeletonRow [ class "nextchapter" ] [ viewChapterFeaturedNext model.language nchapter ]
    in
    [ div [ class ("navbar-container inverted chapternav " ++ sticky_class) ]
        [ div [ class "container" ] navbar
        ]
    , div [ class "navbar-container inverted chapternav" ]
        [ div [ class "container" ] navbar
        ]
    ]
        ++ content
        ++ [ nextchapter
           , div [ class "container footer-container" ]
                [ viewSocialLinks model
                ]
           , div [ class "mobile-tips" ]
                [ text <| translate model.language ZoomInstructions
                ]
           ]
