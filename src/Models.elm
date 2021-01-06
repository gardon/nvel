module Models exposing (BackendConfig, Chapter, ChapterId, Environment(..), Language(..), MaybeAsset(..), MenuItem, Model, NavbarAction(..), PageData, Phrase(..), Route(..), Section, SectionType(..), SiteInformation, SocialIconType(..), TitlePanelFeatures, Audio, chapterContentEndpoint, chapterListEndpoint, siteInformationEndpoint)

import Time
import Dict exposing (Dict)
import Image exposing (Image)
import Url exposing (Url)
import Browser.Navigation exposing (Key)


type alias Model =
    { chapters : Maybe (Dict String Chapter)
    , siteInformation : SiteInformation
    , pageData : PageData
    , backendConfig : BackendConfig
    , menu : List MenuItem
    , route : Route
    , key: Key
    , language : Language
    , languages : List Language
    , navbar : Bool
    , location : Url
    , audio: Bool
    }


type alias MenuItem =
    { title : Phrase
    , path : String
    , route : Route
    }


type alias Chapter =
    { title : String
    , field_description : String
    , nid : String
    , content : List Section
    , index : Int
    , thumbnail : Image
    , authors : List String
    , date : Time.Posix
    , featured_image : Image
    , path : String
    , audios : Maybe Audio
    , language_paths : Dict String String
    , updated : Time.Posix
    , disqus_id : String
    }


type MaybeAsset a
    = AssetNotFound
    | AssetLoading
    | Asset a


type SectionType
    = SingleImage
    | FullWidthSingleImage
    | FoldedImage
    | TitlePanel TitlePanelFeatures
    | Spacer
    | Text String
    | AudioSection Audio Int


type alias Section =
    { sectionType : SectionType
    , image : Image
    , chapter : String
    , id : Int
    , zoomed : Bool
    , preview : Bool
    , date : Time.Posix
    }


type alias TitlePanelFeatures =
    { title : String
    , author : String
    , copyright : String
    , extra : String
    }


type alias BackendConfig =
    { backendURL : String }


type alias SiteInformation =
    { title : String
    , description : String
    , facebook_page : String
    , instagram_handle : String
    , deviantart_profile : String
    , aboutContent : String
    , disqusDomain : String
    , preface : String
    }


type alias PageData =
    { title : String
    , lang : String
    , audios : List Audio
    , disqus : { domain : String, id : String }
    }

type alias Audio =
  { source : List String
  , start : String
  , stop : String
  , crossfade : Int
  }

type Environment
    = Local


type alias ChapterId =
    String

type alias Target =
  Maybe String


type Route
    = HomeRoute
    | ChaptersRoute
    | ChapterRoute ChapterId Target
    | AboutRoute
    | NotFoundRoute


type SocialIconType
    = FacebookIcon
    | InstagramIcon
    | DeviantArtIcon


type Language
    = En
    | Pt_Br


type Phrase
    = MenuHome
    | MenuArchive
    | MenuAbout
    | CurrentChapter
    | StartFromBeginning
    | ReadIt
    | ListAllChapters
    | MailchimpText
    | MailchimpSmall
    | MailchimpButton
    | Loading
    | NotFound
    | NextChapter
    | Next
    | Previous
    | ZoomInstructions
    | UpdateSchedule


type NavbarAction
    = Show
    | Hide

siteInformationEndpoint : String
siteInformationEndpoint =
    "nvel_base?_format=json"

chapterListEndpoint : String
chapterListEndpoint =
    "chapters?_format=json"

chapterContentEndpoint : String
chapterContentEndpoint =
    "chapters"
