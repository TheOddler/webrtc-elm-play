port module WebRTC exposing (..)

type alias Message = 
    { channel : String
    , data : String
    }

-- Send data to js
port send : Message -> Cmd msg

-- Listens to data send from JS to Elm
port listen : (Message -> msg) -> Sub msg

