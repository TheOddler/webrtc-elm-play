module Chat.View exposing (..)

import Chat.Model exposing (..)
import Html exposing ( Html, div, span, text, input, button, ol, li )
import Html.Events exposing (..)
import Html.Attributes as A exposing ( class, id )

-- VIEW
type Config msg = Config
    { input : String -> msg 
    , sendDebug : msg
    , send : Message -> msg
    }

view : Config msg -> Model -> Html msg
view (Config config) model =
    div [ class "Chat" ]
        [ ol [ class "Messages" ] (List.map viewMessage <| List.reverse <| List.take 10 model.messages)
        , input 
            [ A.placeholder "Message"
            , A.value model.message.text
            , onInput <| config.input 
            ] []
        , button 
            [ id "chat-send"
            , A.autofocus True
            , A.disabled (String.isEmpty model.message.text)
            , onClick <| config.send model.message
            ] [ text "Send" ]
        , button 
            [ id "chat-send"
            , onClick <| config.sendDebug
            ] [ text ("Send " ++ toString model.debugCount) ]
        ]

viewMessage : Message -> Html msg
viewMessage msg =
    li  [ class "Message" ] 
        [ span [ class "User" ] [ text msg.user ]
        , span [ class "Text" ] [ text msg.text ]
        ]
