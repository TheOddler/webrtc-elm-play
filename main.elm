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
    { input : String
    , messages : List String
    }

init : (Model, Cmd Msg)
init = (Model "Hey!" [], Cmd.none)

-- UPDATE
type Msg = Input String | Send | Received String

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        Input message -> ({ model | input = message}, Cmd.none)
        Send -> (model, WebRTC.send model.input)
        Received message -> ({ model | messages = message :: model.messages}, Cmd.none)

-- SUBSCRIPTIONS
subscriptions : Model -> Sub Msg
subscriptions model = WebRTC.listen Received

-- VIEW 
view : Model -> Html Msg
view model =
    div []
        [ input [onInput Input] []
        , button [ onClick Send ] [ text "Send" ]
        , div [] (List.map viewMessage model.messages)
        ]

viewMessage msg =
    div [] [ text msg ]