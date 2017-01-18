module Chat exposing (..)

import Html exposing ( Html, div, span, text, input, button, ol, li )
import Html.Events exposing (..)
import Html.Attributes as A exposing ( class, id )
import WebRTC exposing (..)
import Json.Encode as E exposing ( encode, object )
import Json.Decode as D exposing ( decodeString, map2, field )

-- MODEL
type alias Model = 
    { message : Message
    , messages : List Message
    , debugCount : Int
    }

type alias Message = 
    { user : String
    , text : String
    }

init : Model
init = Model (Message "" "") [] 0

encodeMessage : Message -> String
encodeMessage msg = 
    encode 0 <| object
        [ ("user", E.string msg.user)
        , ("text", E.string msg.text)
        ]

decodeMessage : String -> Result String Message
decodeMessage =
    decodeString <| map2 Message (field "user" D.string) (field "text" D.string)


-- UPDATE
type Config msg = Config
    { modifyMsg : (Msg -> msg)
    }
type Msg 
    = Ignore
    | Input String 
    | SendDebug
    | Send Message 
    | Receive Message

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
subscriptions : Config msg -> Model -> Sub msg
subscriptions (Config { modifyMsg }) model =
    Sub.map modifyMsg <| WebRTC.listenOn "chat" decodeMessage Receive Ignore


-- VIEW
view : Config msg -> Model -> Html msg
view (Config { modifyMsg }) model =
    div [ class "Chat" ]
        [ ol [ class "Messages" ] (List.map viewMessage <| List.reverse <| List.take 10 model.messages)
        , input  [ A.placeholder "Message", A.value model.message.text, onInput (\i -> modifyMsg <| Input i) ] []
        , button 
            [ id "chat-send"
            , A.autofocus True
            , A.disabled (String.isEmpty model.message.text)
            , onClick <| modifyMsg <| Send model.message
            ] [ text "Send" ]
        , button 
            [ id "chat-send"
            , onClick <| modifyMsg SendDebug
            ] [ text ("Send " ++ toString model.debugCount) ]
        ]

viewMessage : Message -> Html msg
viewMessage msg =
    li  [ class "Message" ] 
        [ span [ class "User" ] [ text msg.user ]
        , span [ class "Text" ] [ text msg.text ]
        ]
