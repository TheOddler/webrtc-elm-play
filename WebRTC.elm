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

for : String -> (String -> Result String d) -> (d -> msg) -> msg -> Message -> msg
for channel decoder good bad webrtcMessage =
    if 
        webrtcMessage.channel == channel
    then
        let
            decoded = decoder webrtcMessage.data
        in
            case decoded of
                Ok data -> good data
                Err error -> Debug.log ("Failed decoding message on " ++ channel ++ "channel \"" ++ toString webrtcMessage.data ++ "\" with error \"" ++ error ++ "\"") bad
    else
        bad
