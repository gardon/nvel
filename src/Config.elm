module Config exposing (chapterData, getChapterFromId, getLanguage, getLanguages, getSiteInformation, pageData, siteInformation, switchBackend)

import Config.Environment exposing (..)
import Config.Site exposing (..)
import Dict exposing (Dict)
import Http exposing (Header)
import Json.Decode as Decode
import Language exposing (..)
import Models exposing (..)
import Msgs exposing (..)
import Resources exposing (..)
import Chapters exposing (chapterAudios)


switchBackend : BackendConfig
switchBackend =
    backend


getLanguage : Maybe Language -> Language
getLanguage maybeLanguage =
    case maybeLanguage of
        Just lang ->
            lang
        Nothing ->
            language

getLanguages : List Language
getLanguages =
    Config.Site.languages


siteInformation : SiteInformation
siteInformation =
    Config.Site.siteInformation


getChapterFromId : Maybe (Dict String Chapter) -> String -> Maybe Chapter
getChapterFromId maybeChapters id =
  Maybe.andThen (Dict.get id) maybeChapters


chapterData : Model -> String -> PageData
chapterData model id =
    let
        maybeChapter =
            getChapterFromId model.chapters id

        (title, audios, disqus_id) =
            case maybeChapter of
                Nothing ->
                    (translate model.language NotFound, [], "")

                Just chapter ->
                    (chapter.title, chapterAudios chapter, chapter.disqus_id)
    in
    { title = title
    , lang = Language.toString model.language
    , audios = audios
    , disqus = { domain = model.siteInformation.disqusDomain, id = disqus_id }
    }


pageData : Model -> PageData
pageData model =
    let
        data =
            case model.route of
                HomeRoute ->
                    homeData model.language

                ChaptersRoute ->
                    chaptersListData model.language

                ChapterRoute id _ ->
                    chapterData model id

                AboutRoute ->
                    aboutData model.language

                NotFoundRoute ->
                    notFoundData model.language

        title =
            if data.title == "" then
                model.siteInformation.title

            else
                data.title ++ " | " ++ model.siteInformation.title
    in
    { data | title = title }


getSiteInformation : Model -> Cmd Msg
getSiteInformation model =
    let
        url =
            model.backendConfig.backendURL ++ Language.toString model.language ++ "/" ++ siteInformationEndpoint
    in
        Http.get
            { url = url
            , expect = Http.expectJson UpdateSiteInfo decodeSiteInformation
            }
