import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (..)
import WebRTC exposing (..)
import Chat exposing (..)
import Game exposing (..)

main = Html.program
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }


-- MODEL
type alias Model = 
    { chat : Chat.Model
    , game : Game.Model
    }
    
init : (Model, Cmd Msg)
init = (Model Chat.init Game.init, Cmd.none)


-- UPDATE
type Msg 
    = Test 
    | Received WebRTC.Message 
    | ForChat Chat.Msg 
    | ForGame Game.Msg

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        Test -> (model, Cmd.none)
        Received message -> 
            let 
                _ = Debug.log ("Received message on \"" ++ message.channel ++ "\": " ++ message.data)
            in
                ( model
                , Cmd.none
                )
        ForChat msg ->
            let 
                (chatModel, chatCmd) = Chat.update msg model.chat
            in  
                ({ model | chat = chatModel}, Cmd.map ForChat chatCmd)
        ForGame msg ->
            let 
                (gameModel, gameCmd) = Game.update msg model.game
            in  
                ({ model | game = gameModel}, Cmd.map ForGame gameCmd)
        

-- SUBSCRIPTIONS
subscriptions : Model -> Sub Msg
subscriptions model = 
    Sub.batch 
        [ WebRTC.listen Received
        , Sub.map ForChat <| Chat.subscriptions model.chat
        , Sub.map ForGame <| Game.subscriptions model.game
        ]


-- VIEW 
view : Model -> Html Msg
view model =
    div []
        [ Html.map ForChat (Chat.view model.chat)
        , Html.map ForGame (Game.view model.game)
        ]