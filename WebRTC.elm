port module WebRTC exposing ( Message, sendOn, sendRawOn, listenOn, listenRawOn )

type alias ChannelId = String
type alias Data = String
type alias Message = 
    { channel : ChannelId
    , data : Data
    }

-- Send data to js
port sendPort : Message -> Cmd msg

sendRawOn : ChannelId -> Data -> Cmd msg
sendRawOn channel message =
    sendPort <| Message channel <| message

sendOn : ChannelId -> (e -> Data) -> e -> Cmd msg
sendOn channel encoder message =
    sendRawOn channel (encoder message)

-- Listens to data send from JS to Elm
port listen : (Message -> msg) -> Sub msg

listenOn : ChannelId -> (Data -> Result String d) -> (d -> msg) -> msg -> Sub msg
listenOn channel decoder good bad =
    listen <| decodeAndListen_ channel decoder good bad

listenRawOn : ChannelId -> (Data -> msg) -> msg -> Sub msg
listenRawOn channel good bad =
    listen <| basicListen_ channel good bad

decodeAndListen_ : ChannelId -> (Data -> Result String d) -> (d -> msg) -> msg -> Message -> msg
decodeAndListen_ channel decoder good bad webrtcMessage =
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

basicListen_ : ChannelId -> (Data -> msg) -> msg -> Message -> msg
basicListen_ channel good bad webrtcMessage =
    if 
        webrtcMessage.channel == channel
    then
        good webrtcMessage.data
    else
        bad
