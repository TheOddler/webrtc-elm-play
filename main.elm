import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (..)
import WebRTC exposing (..)
import Chat exposing (..)

main = Html.program
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }


-- MODEL
type alias Model = 
    { chat : Chat.Model
    }
    
init : (Model, Cmd Msg)
init = (Model Chat.init, Cmd.none)


-- UPDATE
type Msg = Test | Received WebRTC.Message | ForChat Chat.Msg

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        Test -> (model, Cmd.none)
        Received message -> 
            case message.channel of
                "chat" -> 
                    let 
                        (chatModel, chatCmd) = Chat.update (Chat.Receive message.data) model.chat
                    in 
                        ({ model | chat = chatModel}, Cmd.map ForChat chatCmd)
                _ -> (Debug.log ("Received message from unknown channel \"" ++ message.channel ++ "\"") model, Cmd.none)
        ForChat msg ->
            let 
                (chatModel, chatCmd) = Chat.update msg model.chat
            in  
                ({ model | chat = chatModel}, Cmd.map ForChat chatCmd)
        

-- SUBSCRIPTIONS
subscriptions : Model -> Sub Msg
subscriptions model = WebRTC.listen Received


-- VIEW 
view : Model -> Html Msg
view model =
    div []
        [ Html.map ForChat (Chat.view model.chat)
        ]