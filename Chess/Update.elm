module Chess.Update exposing (..)

import Dict exposing (get, remove, insert)

import Chess.Model exposing (..)
import Chess.View exposing (..)
import WebRTC

-- UPDATE
type Msg 
    = Ignore
    | Click Position
    | DoMove Position Position


createConfig : (Msg -> msg) -> Config msg
createConfig wrap = Config
    { click = wrap << Click
    , finalizeMove = (\from to -> wrap <| DoMove from to)
    }

update : Msg -> Model -> (Model, Cmd msg)
update msg model =
    case msg of
        Ignore -> (model, Cmd.none)
        
        Click pos ->
            case model.state of
                Waiting -> ({ model | state = PieceSelected pos}, Cmd.none)

                PieceSelected sel -> 
                    if sel == pos
                    then ({ model | state = Waiting}, Cmd.none)
                    else ({ model | state = PreviewMove sel pos}, Cmd.none)

                PreviewMove from to ->
                    if from == pos then ({ model | state = Waiting}, Cmd.none)
                    else if to == pos then 
                        let 
                            (newModel, newCmd) = update (DoMove from to) model
                            -- TODO Also do the webrtc send
                        in 
                            (newModel, newCmd)
                    else ({ model | state = Waiting}, Cmd.none)
        
        DoMove from to -> 
            let
                curPieces = model.pieces
                taken = get to curPieces
                moved = get from curPieces
                newPieces = 
                    case moved of
                        Just m  -> insert to m (remove from curPieces)
                        Nothing -> curPieces
                newGraveyard =
                    case taken of
                        Just t -> t :: model.graveyard
                        Nothing -> model.graveyard
            in
               ({model | pieces = newPieces, graveyard = newGraveyard, state = Waiting }, Cmd.none)



-- SUBSCRIPTIONS
subscriptions : (Msg -> msg) -> Model -> Sub msg
subscriptions callback model = Sub.none
    --WebRTC.listenOn "game" decodeMessage Receive Ignore
