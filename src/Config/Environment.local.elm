module Config.Environment exposing (backend)

import Models exposing (..)


backend : BackendConfig
backend =
    { backendURL = "https://server.abismos.com/"
    }
