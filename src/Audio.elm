module Audio exposing (decodeChapterAudio)

import Models exposing (Audio)
import Json.Decode as Decode

decodeChapterAudio : Decode.Decoder (Maybe Audio)
decodeChapterAudio =
  Decode.list Decode.string
  |> Decode.andThen (\list -> if List.isEmpty list then Decode.succeed Nothing else Decode.succeed <| Just (Audio list "" ""))
