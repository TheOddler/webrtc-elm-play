module Chess.Update exposing (..)

import Dict exposing (get, remove, insert)
import List exposing (length, head, drop)
import Json.Encode as E exposing ( encode )
import Json.Decode as D exposing ( decodeString )

import Chess.Model exposing (..)
import Chess.View exposing (..)
import WebRTC

-- UPDATE
type Msg 
    = Ignore
    | Click Position
    | DoMove (Position, Position)


encodeMove : (Position, Position) -> String
encodeMove ((fr, fc), (tr, tc)) =
    encode 0 <| E.list [E.int fr, E.int fc, E.int tr, E.int tc]

decodeMove : String -> Result String (Position, Position)
decodeMove encoded =
    let 
        decoded = decodeString (D.list D.int) encoded
    in
        case decoded of
            Ok list -> 
                if length list == 4
                then
                    let 
                        fr = Maybe.withDefault -1 <| head list
                        fc = Maybe.withDefault -1 <| head <| drop 1 list
                        tr = Maybe.withDefault -1 <| head <| drop 2 list
                        tc = Maybe.withDefault -1 <| head <| drop 3 list
                    in 
                        Ok ((fr, fc), (tr, tc))
                else Err <| "Failed parsing list " ++ toString (length list) ++ " to move."
            Err err -> Err err

createConfig : (Msg -> msg) -> Config msg
createConfig wrap = Config
    { click = wrap << Click
    , finalizeMove = (\from to -> wrap <| DoMove (from, to))
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
                            (newModel, _) = update (DoMove (from, to)) model
                            -- TODO Also do the webrtc send
                            webrtcCmd = WebRTC.sendOn "chess" encodeMove (from, to)
                        in 
                            (newModel, webrtcCmd)
                    else ({ model | state = Waiting}, Cmd.none)
        
        DoMove (from, to) -> 
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
subscriptions callback model = 
    Sub.map callback <| WebRTC.listenOn "chess" decodeMove DoMove Ignore
