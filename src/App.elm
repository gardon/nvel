-- Read more about this program in the official Elm guide:
-- https://guide.elm-lang.org/architecture/effects/http.html


port module Main exposing (init, lazyImage, lazyLoad, main, navBar, pageChange, renderSocialMedia, subscriptions, toggleNavbar, update, updatePageData, view)

import Chapters exposing (..)
import Chapters.Chapter
import Config exposing (..)
import Debug exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http exposing (Header)
import Image
import Json.Decode as Decode
import Language exposing (..)
import List exposing (head)
import Menu exposing (..)
import Models exposing (..)
import Msgs exposing (..)
import Browser
import Browser.Navigation as Nav
import Routing exposing (parseLocation, routeContent)
import Skeleton exposing (..)
import Task
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
            Config.getLanguage

        pageData =
            { title = translate lang Loading, lang = Language.toString lang }

        menu =
            Menu.menu

        route =
            parseLocation location

        model =
            Model chapters siteInformation pageData backendConfig menu route key lang True location
    in
    ( model, getSiteInformation model )


port updatePageData : PageData -> Cmd msg


port renderSocialMedia : String -> Cmd msg


port navBar : (Bool -> msg) -> Sub msg


port lazyLoad : ({ chapter : String, section : Int } -> msg) -> Sub msg


port pageChange : () -> Cmd msg


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
            ( updatedModel, updatePageData updatedModel.pageData )

        ChaptersLoad (Err error) ->
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
                  ( model, Nav.pushUrl model.key (Url.toString url) )

                Browser.External href ->
                  ( model, Nav.load href )

        -- ScrollTop (Ok x) ->
        --     ( model, Cmd.none )
        --
        -- ScrollTop (Err x) ->
        --     ( model, Cmd.none )

        OnLocationChange location ->
            let
                newRoute =
                    parseLocation location

                newmodel =
                    { model | route = newRoute, location = location }

                updatedModel =
                    { newmodel | pageData = pageData newmodel }
            in
            ( updatedModel, Cmd.batch [ updatePageData updatedModel.pageData, pageChange () ] )

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

        ToggleZoomedImage chapter section ->
            ( zoomImage model chapter section, Cmd.none )

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


toggleNavbar : Bool -> Msg
toggleNavbar flag =
    if flag == True then
        Navbar Show

    else
        Navbar Hide


lazyImage : { chapter : String, section : Int } -> Msg
lazyImage record =
    LoadImage record.chapter record.section



-- HTTP
