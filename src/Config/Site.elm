module Config.Site exposing (aboutData, chaptersListData, homeData, language, languages, notFoundData, siteInformation)

import Language exposing (..)
import Models exposing (..)



-- TODO: make this file repleceable as well.


siteInformation : SiteInformation
siteInformation =
    { title = ""
    , description = ""
    , facebook_page = ""
    , instagram_handle = ""
    , deviantart_profile = ""
    , aboutContent = ""
    , disqusDomain = ""
    , preface = ""
    }


homeData : Language -> PageData
homeData lang =
    { title = ""
    , lang = Language.toString lang
    , audios = []
    , disqus = { domain = "", id = ""}
    }


chaptersListData : Language -> PageData
chaptersListData lang =
    { title = translate language MenuArchive
    , lang = Language.toString lang
    , audios = []
    , disqus = { domain = "", id = ""}
    }


aboutData : Language -> PageData
aboutData lang =
    { title = translate language MenuAbout
    , lang = Language.toString lang
    , audios = []
    , disqus = { domain = "", id = ""}
    }


notFoundData : Language -> PageData
notFoundData lang =
    { title = "Oops, there was a problem!"
    , lang = Language.toString lang
    , audios = []
    , disqus = { domain = "", id = ""}
    }


language : Language
language =
    Pt_Br

languages : List Language
languages =
    [ Pt_Br, En ]
