module Chapters.View exposing (sectionId)

sectionId : String -> Int -> String
sectionId chapter section =
    "section:" ++ chapter ++ ":" ++ String.fromInt section
