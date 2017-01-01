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
type Msg 
    = Ignore
    | Input String 
    | SendDebug
    | Send Message 
    | Receive Message

update : Msg -> Model -> (Model, Cmd Msg)
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
            , WebRTC.send <| WebRTC.Message "chat" <| encodeMessage <| Message "Debug" (toString model.debugCount)
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
                    , WebRTC.send <| WebRTC.Message "chat" <| encodeMessage message
                    )

        Receive msg -> 
            ( {model | messages = msg :: model.messages}
            , Cmd.none
            )


-- SUBSCRIPTIONS
subscriptions : Model -> Sub Msg
subscriptions model =
    WebRTC.listenFor "chat" decodeMessage Receive Ignore


-- VIEW
view : Model -> Html Msg
view model =
    div [ class "Chat" ]
        [ ol [ class "Messages" ] (List.map viewMessage <| List.reverse <| List.take 10 model.messages)
        , input  [ A.placeholder "Message", A.value model.message.text, onInput Input ] []
        , button 
            [ id "chat-send"
            , A.autofocus True
            , A.disabled (String.isEmpty model.message.text)
            , onClick <| Send model.message ] [ text "Send" ]
        , button 
            [ id "chat-send"
            , onClick <| SendDebug ] [ text ("Send " ++ toString model.debugCount) ]
        ]

viewMessage : Message -> Html Msg
viewMessage msg =
    li  [ class "Message" ] 
        [ span [ class "User" ] [ text msg.user ]
        , span [ class "Text" ] [ text msg.text ]
        ]
