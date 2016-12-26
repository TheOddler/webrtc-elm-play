port module WebRTC exposing (..)

-- Send a string to JS
port send : String -> Cmd msg

-- Basically listens to Strings send from JS to Elm
port listen : (String -> msg) -> Sub msg
