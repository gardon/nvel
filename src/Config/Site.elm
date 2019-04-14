module Config.Site exposing (aboutData, chaptersListData, homeData, language, notFoundData, siteInformation)

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
    }


homeData : Language -> PageData
homeData language =
    { title = ""
    , lang = Language.toString language
    }


chaptersListData : Language -> PageData
chaptersListData language =
    { title = translate language MenuArchive
    , lang = Language.toString language
    }


aboutData : Language -> PageData
aboutData language =
    { title = translate language MenuAbout
    , lang = Language.toString language
    }


notFoundData : Language -> PageData
notFoundData language =
    { title = "Oops, there was a problem!"
    , lang = Language.toString language
    }


language : Language
language =
    Pt_Br
