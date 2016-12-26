import Html exposing (..)
import Html.Events exposing (..)
import WebRTC exposing (..)

main = Html.program
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }

-- MODEL
type alias Model = 
    { receivedMessages : List String
    }

init : (Model, Cmd Msg)
init = (Model [], Cmd.none)

-- UPDATE
type Msg = Send String | Received String

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        Send message -> (model, WebRTC.send message)
        Received message -> ({ model | receivedMessages = message :: model.receivedMessages}, Cmd.none)

-- SUBSCRIPTIONS
subscriptions : Model -> Sub Msg
subscriptions model = WebRTC.listen Received

-- VIEW 
view : Model -> Html Msg
view model =
    div []
        [ button [ onClick (Send "Hey") ] [ text "Send" ]
        , div [] (List.map viewMessage model.receivedMessages)
        ]

viewMessage msg =
    div [] [ text msg ]