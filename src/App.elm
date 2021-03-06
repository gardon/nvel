-- Read more about this program in the official Elm guide:
-- https://guide.elm-lang.org/architecture/effects/http.html


port module App exposing (init, lazyImage, lazyLoad, main, navBar, pageChange, renderSocialMedia, subscriptions, toggleNavbar, update, updatePageData, view)

import Chapters exposing (..)
import Chapters.View exposing (sectionId)
import Chapters.Chapter
import Config exposing (..)
import Debug exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Language exposing (..)
import Menu exposing (..)
import Models exposing (..)
import Msgs exposing (..)
import Browser
import Browser.Navigation as Nav
import Routing exposing (parseLocation, routeContent)
import Skeleton exposing (..)
import Task
import Browser.Dom as Dom
import Result exposing (Result)
import Url
import View exposing (..)


main : Program () Model Msg
main =
  Browser.application
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    , onUrlChange = OnLocationChange
    , onUrlRequest = ChangeLocation
    }

-- UPDATE

init : () -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init flags location key =
    let
        chapters =
            Nothing

        siteInformation =
            Config.siteInformation

        backendConfig =
            switchBackend

        lang =
            Config.getLanguage <| parseLanguage location

        langs =
            Config.getLanguages

        pageData =
            { title = translate lang Loading, lang = Language.toString lang, audios = [], disqus = { domain = "", id = ""} }

        menu =
            Menu.menu

        route =
            parseLocation location

        model =
            Model chapters siteInformation pageData backendConfig menu route key lang langs True location True
    in
    ( model, getSiteInformation model )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ChaptersLoad (Ok chapters) ->
            let
                newmodel =
                    { model | chapters = Just chapters }

                updatedModel =
                    { newmodel | pageData = pageData newmodel }
            in
            ( updatedModel, Cmd.batch [ updatePageData updatedModel.pageData, scrollToTarget model ] )

        ChaptersLoad (Err _) ->
            ( model, pageChange () )

        ChapterContentLoad (Ok chapter) ->
            ( Chapters.Chapter.replaceChapter model chapter, Cmd.none )

        ChapterContentLoad (Err _) ->
            ( model, Cmd.none )

        UpdateSiteInfo (Ok siteInformation) ->
            ( { model | siteInformation = siteInformation }, getChapters model )

        UpdateSiteInfo (Err _) ->
            ( model, Cmd.none )

        ChangeLocation urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                  -- ( model, Cmd.batch [ Task.attempt ScrollTop (Dom.Scroll.toTop "scroll-top"), Nav.pushUrl model.key (Url.toString url) ] )
                  ( model
                  , Cmd.batch
                    [ Nav.pushUrl model.key (Url.toString url)
                    , Task.attempt scrollZoomedImage (Dom.setViewport 0 0 )
                    ]
                  )

                Browser.External href ->
                  ( model, Nav.load href )

        -- ScrollTop (Ok x) ->
        --     ( model, Cmd.none )
        --
        -- ScrollTop (Err x) ->
        --     ( model, Cmd.none )

        OnLocationChange newlocation ->
            let
                newRoute =
                    parseLocation newlocation

                newlang =
                    Config.getLanguage <| parseLanguage newlocation

                cmd =
                    if newlang == model.language then
                        updatePageData updatedModel.pageData
                    else
                        getSiteInformation updatedModel

                chapters =  if newlang == model.language then model.chapters else Nothing

                newmodel =
                    { model | chapters = chapters, route = newRoute, language = newlang, location = newlocation }

                updatedModel =
                    { newmodel | pageData = pageData newmodel }
            in
                ( updatedModel
                , Cmd.batch
                    [ cmd
                    , pageChange ()
                    , scrollToTarget newmodel
                    ]
                )

        Navbar action ->
            let
                navbar =
                    case action of
                        Show ->
                            True

                        Hide ->
                            False
            in
            ( { model | navbar = navbar }, Cmd.none )

        ToggleZoomedImage chapter section x ->
            ( zoomImage model chapter section, Task.attempt scrollZoomedImage (Dom.setViewportOf (sectionId chapter section) (toFloat x) 0 ) )

        ToggleAudio ->
          ( { model | audio = not model.audio }, toggleSound <| not model.audio )

        NoOp ->
            ( model, Cmd.none )

        LoadImage chapter section ->
            ( loadImage model chapter section, Cmd.none )



-- VIEW


view : Model -> Browser.Document Msg
view model =
    let
       title =
            model.pageData.title
       content =
            routeContent model
    in
       Browser.Document title content



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ navBar toggleNavbar
        , lazyLoad lazyImage
        ]


port updatePageData : PageData -> Cmd msg
port renderSocialMedia : String -> Cmd msg
port navBar : (Bool -> msg) -> Sub msg
port lazyLoad : ({ chapter : String, section : Int } -> msg) -> Sub msg
port pageChange : () -> Cmd msg
port toggleSound : Bool -> Cmd msg

toggleNavbar : Bool -> Msg
toggleNavbar flag =
    if flag == True then
        Navbar Show

    else
        Navbar Hide

lazyImage : { chapter : String, section : Int } -> Msg
lazyImage record =
    LoadImage record.chapter record.section

scrollZoomedImage : Result a b -> Msg
scrollZoomedImage result =
    NoOp

scrollToTarget : Model -> Cmd Msg
scrollToTarget model =
  case model.route of
    ChapterRoute _ frag ->
      case frag of
        -- attempt to scroll to fragment without reporting on failures.
        Just target -> Task.attempt (\_ -> NoOp)
          (Dom.getElement target
            |> Task.andThen (\info -> Dom.setViewport 0 info.element.y)
          )
        Nothing -> Cmd.none
    _ -> Cmd.none

-- HTTP
