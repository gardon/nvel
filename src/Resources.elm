module Resources exposing (dateDecoder, decodeDerivative, decodeFullWidthSingleImageSection, decodeSection, decodeSingleImageSection, decodeSiteInformation, decodeSpacer, decodeText, decodeTextSection, decodeTitlePanel, decodeTitlePanelFeatures, decodeTitlePanelSection, imageDecoder, sectionDecoder)

import Time
import Image exposing (Image)
import Json.Decode as Decode
import Json.Decode.Pipeline exposing (hardcoded, optional, required)
import Models exposing (Section, SectionType(..), TitlePanelFeatures, Audio, SiteInformation)
import Audio exposing (decodeAudio)



--import Markdown



dateDecoder : Decode.Decoder Time.Posix
dateDecoder =
    Decode.int
        |> Decode.andThen
            (\val ->
                Decode.succeed <| Time.millisToPosix (val * 1000)
            )


imageDecoder : Decode.Decoder Image
imageDecoder =
    Decode.succeed Image
        |> required "uri" Decode.string
        |> required "width" Decode.int
        |> required "height" Decode.int
        |> optional "alt" Decode.string ""
        |> optional "title" Decode.string ""
        |> optional "derivatives" (Decode.list decodeDerivative) []
        |> hardcoded False


decodeDerivative : Decode.Decoder Image.Derivative
decodeDerivative =
    Decode.succeed Image.Derivative
        |> required "uri" Decode.string
        |> required "size" Decode.string


sectionDecoder : Decode.Decoder Section
sectionDecoder =
    Decode.field "type" Decode.string
        |> Decode.andThen decodeSection


decodeSection : String -> Decode.Decoder Section
decodeSection sectionType =
    case sectionType of
        "full_width_single_panel" ->
            decodeFullWidthSingleImageSection

        "single_panel" ->
            decodeSingleImageSection

        "folded_image" ->
            decodeFoldedImageSection

        "spacer" ->
            decodeSpacer

        "title_panel" ->
            decodeTitlePanel

        "text" ->
            decodeText

        "audio" ->
            decodeAudioSection

        _ ->
            Decode.fail <| "Unknown section type: " ++ sectionType


decodeFullWidthSingleImageSection : Decode.Decoder Section
decodeFullWidthSingleImageSection =
    Decode.succeed Section
        |> hardcoded FullWidthSingleImage
        |> required "image" imageDecoder
        |> required "chapter" Decode.string
        |> required "id" Decode.int
        |> hardcoded False
        |> optional "preview" Decode.bool False
        |> required "publication_date_unix" dateDecoder



decodeSingleImageSection : Decode.Decoder Section
decodeSingleImageSection =
    Decode.succeed Section
        |> hardcoded SingleImage
        |> required "image" imageDecoder
        |> required "chapter" Decode.string
        |> required "id" Decode.int
        |> hardcoded False
        |> optional "preview" Decode.bool False
        |> required "publication_date_unix" dateDecoder



decodeFoldedImageSection : Decode.Decoder Section
decodeFoldedImageSection =
    Decode.succeed Section
        |> hardcoded FoldedImage
        |> required "image" imageDecoder
        |> required "chapter" Decode.string
        |> required "id" Decode.int
        |> hardcoded False
        |> optional "preview" Decode.bool False
        |> required "publication_date_unix" dateDecoder


decodeSpacer : Decode.Decoder Section
decodeSpacer =
    Decode.succeed Section
        |> hardcoded Spacer
        |> hardcoded Image.emptyImage
        |> required "chapter" Decode.string
        |> required "id" Decode.int
        |> hardcoded False
        |> optional "preview" Decode.bool False
        |> required "publication_date_unix" dateDecoder



decodeTitlePanel : Decode.Decoder Section
decodeTitlePanel =
    Decode.field "features" decodeTitlePanelFeatures
        |> Decode.andThen decodeTitlePanelSection


decodeTitlePanelSection : TitlePanelFeatures -> Decode.Decoder Section
decodeTitlePanelSection features =
    Decode.succeed Section
        |> hardcoded (TitlePanel features)
        |> optional "image" imageDecoder Image.emptyImage
        |> required "chapter" Decode.string
        |> required "id" Decode.int
        |> hardcoded False
        |> optional "preview" Decode.bool False
        |> required "publication_date_unix" dateDecoder



decodeTitlePanelFeatures : Decode.Decoder TitlePanelFeatures
decodeTitlePanelFeatures =
    Decode.succeed TitlePanelFeatures
        |> required "title" Decode.string
        |> required "author" Decode.string
        |> required "copyright" Decode.string
        |> required "extra" Decode.string


decodeText : Decode.Decoder Section
decodeText =
    Decode.field "text" Decode.string
        |> Decode.andThen decodeTextSection


decodeTextSection : String -> Decode.Decoder Section
decodeTextSection text =
    Decode.succeed Section
        |> hardcoded (Text text)
        |> hardcoded Image.emptyImage
        |> required "chapter" Decode.string
        |> required "id" Decode.int
        |> hardcoded False
        |> optional "preview" Decode.bool False
        |> required "publication_date_unix" dateDecoder


decodeAudioSection : Decode.Decoder Section
decodeAudioSection =
  Decode.field "audios" decodeAudio
    |> Decode.andThen decodeAudioSectionBase

decodeAudioSectionBase : Audio -> Decode.Decoder Section
decodeAudioSectionBase audio =
  Decode.field "crossfade" Decode.int
    |> Decode.andThen (\crossfade ->
      Decode.succeed Section
        |> hardcoded (AudioSection audio crossfade)
        |> hardcoded Image.emptyImage
        |> required "chapter" Decode.string
        |> required "id" Decode.int
        |> hardcoded False
        |> optional "preview" Decode.bool False
        |> required "publication_date_unix" dateDecoder

    )



--markdownDecoder : Decode.Decoder (Html msg)
--markdownDecoder =
--  Decode.string
--      |> Decode.andThen Markdown.toHtml []


decodeSiteInformation : Decode.Decoder SiteInformation
decodeSiteInformation =
    Decode.succeed SiteInformation
        |> required "title" Decode.string
        |> required "description" Decode.string
        |> optional "facebook_page" Decode.string ""
        |> optional "instagram_handle" Decode.string ""
        |> optional "deviantart_profile" Decode.string ""
        |> optional "about" Decode.string "# About"
        |> optional "preface" Decode.string "&nbsp"
