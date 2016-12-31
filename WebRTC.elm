port module WebRTC exposing (..)

type alias ChannelId = String
type alias Data = String
type alias Message = 
    { channel : ChannelId
    , data : Data
    }

-- Send data to js
port send : Message -> Cmd msg

-- Listens to data send from JS to Elm
port listen : (Message -> msg) -> Sub msg
