import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (..)
import WebRTC exposing (..)
import Game exposing (..)

main = Html.program
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }

-- MODEL
type alias Model = 
    { input : String
    , messages : List String
    }
    
init : (Model, Cmd Msg)
init = (Model "Hey!" [], Cmd.none)

-- UPDATE
type Msg = Input String | Send | Received WebRTC.Message

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        Input message -> ({ model | input = message}, Cmd.none)
        Send -> (model, WebRTC.send <| WebRTC.Message "chat" model.input)
        Received message -> 
            case message.channel of
                "chat" -> ({ model | messages = message.data :: model.messages}, Cmd.none)
                channel -> (Debug.log ("Received message from unknown channel \"" ++ channel ++ "\"") model, Cmd.none)

-- SUBSCRIPTIONS
subscriptions : Model -> Sub Msg
subscriptions model = WebRTC.listen Received

-- VIEW 
view : Model -> Html Msg
view model =
    div []
        [ input [placeholder "Message (default: Hey!)", onInput Input] []
        , button [ onClick Send ] [ text "Send" ]
        , div [] (List.map viewMessage model.messages)
        ]

viewMessage msg =
    div [] [ text msg ]