module Chat.Update exposing (..)

import Chat.Model exposing (..)
import Chat.View exposing (..)
import WebRTC

-- UPDATE
type Msg 
    = Ignore
    | Input String 
    | SendDebug
    | Send Message 
    | Receive Message

createConfig : (Msg -> msg) -> Config msg
createConfig wrap = Config
    { input = wrap << Input
    , sendDebug = wrap <| SendDebug
    , send = wrap << Send
    }

update : Msg -> Model -> (Model, Cmd msg)
update msg model =
    case msg of
        Ignore -> (model, Cmd.none)
        Input input -> 
            let message = model.message
                newMessage = {message | text = input}
            in 
                ( {model | message = newMessage}
                , Cmd.none
                )
        
        SendDebug ->
            ( {model | debugCount = model.debugCount + 1}
            , WebRTC.sendOn "chat" encodeMessage <| Message "Debug" (toString model.debugCount)
            )

        Send msg -> 
            if
                String.isEmpty model.message.text
            then
                (model, Cmd.none)
            else
                let message = model.message
                    newMessage = {message | text = ""}
                in 
                    ( {model | message = newMessage}
                    , WebRTC.sendOn "chat" encodeMessage message
                    )

        Receive msg -> 
            ( {model | messages = msg :: model.messages}
            , Cmd.none
            )


-- SUBSCRIPTIONS
subscriptions : (Msg -> msg) -> Model -> Sub msg
subscriptions callback model =
    Sub.map callback <| WebRTC.listenOn "chat" decodeMessage Receive Ignore
