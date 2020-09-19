module Language exposing (toString, toLang, translate, translateMonth, localizePath, parseLanguage, removeLanguage)

import Models exposing (Phrase(..), Language(..))
import Time exposing (Month(..))
import Url exposing (Url)

type alias Translator =
    Phrase -> String

type alias MonthTranslator =
    Month -> String

toString : Language -> String
toString lang =
    case lang of
        En ->
            "en"

        Pt_Br ->
            "pt-br"

toLang : String -> Maybe Language
toLang langcode =
    if langcode == "en" then
        Just En
    else if langcode == "pt-br" then
        Just Pt_Br
    else
        Nothing

translate : Language -> Translator
translate lang =
    case lang of
        En ->
            translateEn

        Pt_Br ->
            translatePtBr

translateMonth : Language -> MonthTranslator
translateMonth lang =
    case lang of
        En ->
            translateMonthEn

        Pt_Br ->
            translateMonthPtBr

translatePtBr : Translator
translatePtBr phrase =
    case phrase of
        MenuHome ->
            "Capa"

        MenuArchive ->
            "Índice"

        MenuAbout ->
            "Prefácio"

        CurrentChapter ->
            "Ler a última atualização »"

        StartFromBeginning ->
            "Começo da história"

        ReadIt ->
            "Ler agora"

        ListAllChapters ->
            "Lista de capítulos"

        MailchimpText ->
            "Assine a lista para saber de novos capítulos!"

        MailchimpSmall ->
            "(A lista só é usada para avisar de conteúdo novo)"

        MailchimpButton ->
            "Assinar"

        Loading ->
            "Carregando..."

        NotFound ->
            "Não encontrado"

        NextChapter ->
            "Continue lendo..."

        Next ->
            "Próximo"

        Previous ->
            "Anterior"

        ZoomInstructions ->
            "Toque nas imagens para aproximar"

        UpdateSchedule ->
            "Nova atualização agendada para: "

translateMonthPtBr : MonthTranslator
translateMonthPtBr month =
    case month of
      Jan -> "Jan"
      Feb -> "Fev"
      Mar -> "Mar"
      Apr -> "Abr"
      May -> "Mai"
      Jun -> "Jun"
      Jul -> "Jul"
      Aug -> "Ago"
      Sep -> "Set"
      Oct -> "Out"
      Nov -> "Nov"
      Dec -> "Dez"

translateEn : Translator
translateEn phrase =
    case phrase of
        MenuHome ->
            "Home"

        MenuArchive ->
            "Index"

        MenuAbout ->
            "About"

        CurrentChapter ->
            "Read latest update »"

        StartFromBeginning ->
            "Start from beginning"

        ReadIt ->
            "Read it"

        ListAllChapters ->
            "List all chapters"

        MailchimpText ->
            "Don't miss an update, sign-up to get notified!"

        MailchimpSmall ->
            "(It's really only used when there are updates)"

        MailchimpButton ->
            "Subscribe"

        Loading ->
            "Loading..."

        NotFound ->
            "Not Found"

        NextChapter ->
            "Keep Reading"

        Next ->
            "Next"

        Previous ->
            "Previous"

        ZoomInstructions ->
            "Touch the images to zoom"

        UpdateSchedule ->
            "New update scheduled for: "


translateMonthEn : MonthTranslator
translateMonthEn month =
    case month of
      Jan -> "Jan"
      Feb -> "Feb"
      Mar -> "Mar"
      Apr -> "Apr"
      May -> "May"
      Jun -> "Jun"
      Jul -> "Jul"
      Aug -> "Aug"
      Sep -> "Sep"
      Oct -> "Oct"
      Nov -> "Nov"
      Dec -> "Dec"

localizePath : Language -> String -> String
localizePath lang path = "/" ++ toString lang ++ path


parseLanguage : Url -> Maybe Language
parseLanguage location =
    let parts = List.drop 1 <| String.split "/" location.path
    in
      List.head parts
      |> Maybe.andThen toLang


removeLanguage : Url -> Url
removeLanguage location =
    case parseLanguage location of
      Just _ ->
        { location | path = "/" ++ (String.join "/" <| List.drop 2 <| String.split "/" location.path) }
      Nothing ->
        location
