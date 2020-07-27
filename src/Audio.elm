module Audio exposing (decodeChapterAudio)

import Models exposing (Audio)
import Json.Decode as Decode

decodeChapterAudio : Decode.Decoder (Maybe Audio)
decodeChapterAudio =
  Decode.list Decode.string
  |> Decode.andThen (\list -> Decode.succeed <| Just (Audio list "" ""))
