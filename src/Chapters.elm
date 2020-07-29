module Chapters exposing (chapterDecoder, decodeChapterContent, decodeChapters, getChapterContent, getChapters, loadImage, loadImageSection, zoomImage, zoomImageSection, chapterAudios)

import Dict exposing (Dict)
import Http
import Json.Decode as Decode
import Json.Decode.Pipeline exposing (optional, required)
import Models exposing (Model, chapterListEndpoint, Chapter, chapterContentEndpoint, Section, Audio, SectionType(..))
import Msgs exposing (Msg(..))
import Resources exposing (sectionDecoder, imageDecoder, dateDecoder)
import Language
import Audio exposing (decodeChapterAudio)
import Chapters.Chapter exposing (sectionId)


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
        |> optional "language_paths" (Decode.dict Decode.string) Dict.empty


decodeChapters : Decode.Decoder (Dict String Chapter)
decodeChapters =
    Decode.dict chapterDecoder


zoomImage : Model -> String -> Int -> Model
zoomImage model chapter section =
    case model.chapters of
        Nothing ->
            model

        Just chapters ->
            { model | chapters = Dict.update chapter (Maybe.map <| zoomImageSection section) chapters |> Just }


zoomImageSection : Int -> Chapter -> Chapter
zoomImageSection index chapter =
  let
      content =
          chapter.content

      maybeSection =
          List.drop (index - 1) content
              |> List.head
  in
  case maybeSection of
      Nothing ->
          chapter

      Just section ->
          let
              newsection =
                  if section.zoomed == True then
                      { section | zoomed = False }

                  else
                      { section | zoomed = True }
          in
          { chapter | content = List.concat [ List.take (index - 1) content, [ newsection ], List.drop index content ] }


loadImage : Model -> String -> Int -> Model
loadImage model chapter section =
    case model.chapters of
        Nothing ->
            model

        Just chapters ->
            { model | chapters = Dict.update chapter (Maybe.map <| loadImageSection section) chapters |> Just }


loadImageSection : Int -> Chapter -> Chapter
loadImageSection index chapter =
  let
      content =
          chapter.content

      maybeSection =
          List.drop (index - 1) content
              |> List.head
  in
  case maybeSection of
      Nothing ->
          chapter

      Just section ->
          let
              image =
                  section.image

              newimage =
                  { image | load = True }

              newsection =
                  { section | image = newimage }
          in
          { chapter | content = List.concat [ List.take (index - 1) content, [ newsection ], List.drop index content ] }


chapterAudios : Chapter -> List Audio
chapterAudios chapter =
  (case chapter.audios of
    Just audio -> [audio]
    Nothing -> []) ++
  List.filterMap (\section ->
    case section.sectionType of
      AudioSection audio crossfade -> Just { audio | start = sectionId section.chapter section.id, crossfade = crossfade }
      _ -> Nothing ) chapter.content

