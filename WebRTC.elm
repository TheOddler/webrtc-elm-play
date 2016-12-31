port module WebRTC exposing (..)

type alias WebRTCData = String

-- Send data to js
port send : WebRTCData -> Cmd msg

-- Listens to data send from JS to Elm
port listen : (WebRTCData -> msg) -> Sub msg

