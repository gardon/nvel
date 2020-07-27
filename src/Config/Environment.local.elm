module Config.Environment exposing (backend)

import Models exposing (..)


backend : BackendConfig
backend =
    { backendURL = "http://nvel-server.docksal/"
    }
