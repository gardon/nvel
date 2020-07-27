module Chapters exposing (chapterDecoder, decodeChapterContent, decodeChapters, getChapterContent, getChapters, loadImage, loadImageSection, zoomImage, zoomImageSection, chapterAudios)

import Dict exposing (Dict)
import Http
import Json.Decode as Decode
import Json.Decode.Pipeline exposing (optional, required)
import Models exposing (..)
import Msgs exposing (..)
import Resources exposing (..)
import Language exposing (..)
import Audio exposing (decodeChapterAudio)


-- Http


getChapters : Model -> Cmd Msg
getChapters model =
    let
        url =
            model.backendConfig.backendURL ++ Language.toString model.language ++ "/" ++ chapterListEndpoint
    in
        Http.get
            { url = url
            , expect = Http.expectJson ChaptersLoad decodeChapters
            }


getChapterContent : Model -> Chapter -> Cmd Msg
getChapterContent model chapter =
    let
        url =
            model.backendConfig.backendURL ++ chapterContentEndpoint ++ "/" ++ chapter.nid ++ "?_format=json"
    in
      Http.get
          { url = url
          , expect = Http.expectJson ChapterContentLoad chapterDecoder
          }


decodeChapterContent : Decode.Decoder (List Section)
decodeChapterContent =
    Decode.list sectionDecoder


chapterDecoder : Decode.Decoder Chapter
chapterDecoder =
    Decode.succeed Chapter
        |> required "title" Decode.string
        |> required "field_description" Decode.string
        |> required "nid" Decode.string
        |> required "content" decodeChapterContent
        |> required "index" Decode.int
        |> required "thumbnail" imageDecoder
        |> required "authors" (Decode.list Decode.string)
        |> required "publication_date_unix" dateDecoder
        |> required "featured_image" imageDecoder
        |> required "path" Decode.string
        |> optional "audios" decodeChapterAudio Nothing


decodeChapters : Decode.Decoder (Dict String Chapter)
decodeChapters =
    Decode.dict chapterDecoder


zoomImage : Model -> String -> Int -> Model
zoomImage model chapter section =
    case model.chapters of
        Nothing ->
            model

        Just chapters ->
            { model | chapters = Dict.update chapter (zoomImageSection section) chapters |> Just }


zoomImageSection : Int -> Maybe Chapter -> Maybe Chapter
zoomImageSection index maybeChapter =
    case maybeChapter of
        Nothing ->
            Nothing

        Just chapter ->
            let
                content =
                    chapter.content

                maybeSection =
                    List.drop (index - 1) content
                        |> List.head
            in
            case maybeSection of
                Nothing ->
                    Just chapter

                Just section ->
                    let
                        newsection =
                            if section.zoomed == True then
                                { section | zoomed = False }

                            else
                                { section | zoomed = True }
                    in
                    { chapter | content = List.concat [ List.take (index - 1) content, [ newsection ], List.drop index content ] } |> Just


loadImage : Model -> String -> Int -> Model
loadImage model chapter section =
    case model.chapters of
        Nothing ->
            model

        Just chapters ->
            { model | chapters = Dict.update chapter (loadImageSection section) chapters |> Just }


loadImageSection : Int -> Maybe Chapter -> Maybe Chapter
loadImageSection index maybeChapter =
    case maybeChapter of
        Nothing ->
            Nothing

        Just chapter ->
            let
                content =
                    chapter.content

                maybeSection =
                    List.drop (index - 1) content
                        |> List.head
            in
            case maybeSection of
                Nothing ->
                    Just chapter

                Just section ->
                    let
                        image =
                            section.image

                        newimage =
                            { image | load = True }

                        newsection =
                            { section | image = newimage }
                    in
                    { chapter | content = List.concat [ List.take (index - 1) content, [ newsection ], List.drop index content ] } |> Just


chapterAudios : Chapter -> List Audio
chapterAudios chapter =
  case chapter.audios of
    Just audio -> [audio]
    Nothing -> []
