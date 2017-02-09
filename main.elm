import Html exposing (..)
import WebRTC exposing (..)

import Chat.Model exposing (..)
import Chat.View exposing (..)
import Chat.Update exposing (..)

import Chess.Model exposing (..)
import Chess.View exposing (..)
import Chess.Update exposing (..)


main = Html.program
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }


-- MODEL
type alias Model = 
    { chat : Chat.Model.Model
    , game : Chess.Model.Model
    }
    
init : (Model, Cmd Msg)
init = (Model Chat.Model.init Chess.Model.init, Cmd.none)

chatConfig : Chat.View.Config Msg
chatConfig = Chat.Update.createConfig ForChat

chessConfig : Chess.View.Config Msg
chessConfig = Chess.Update.createConfig ForGame


-- UPDATE
type Msg 
    = Test 
    | Received WebRTC.Message 
    | ForChat Chat.Update.Msg 
    | ForGame Chess.Update.Msg

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
                (chatModel, chatCmd) = Chat.Update.update msg model.chat
            in  
                ({ model | chat = chatModel}, chatCmd)
        ForGame msg ->
            let 
                (gameModel, gameCmd) = Chess.Update.update msg model.game
            in  
                ({ model | game = gameModel}, gameCmd)


-- SUBSCRIPTIONS
subscriptions : Model -> Sub Msg
subscriptions model = 
    Sub.batch 
        [ WebRTC.listen Received
        , Chat.Update.subscriptions ForChat model.chat
        , Chess.Update.subscriptions ForGame model.game
        ]


-- VIEW 
view : Model -> Html Msg
view model =
    div []
        [ Chat.View.view chatConfig model.chat
        , Chess.View.view chessConfig model.game
        ]
