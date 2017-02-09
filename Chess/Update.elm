module Chess.Update exposing (..)

import Chess.Model exposing (..)
import Chess.View exposing (..)
import WebRTC

-- UPDATE
type Msg 
    = Ignore
    | Click Position
    | FinalizeMove Position Position


createConfig : (Msg -> msg) -> Config msg
createConfig wrap = Config
    { click = wrap << Click
    , finalizeMove = (\from to -> wrap <| FinalizeMove from to)
    }

update : Msg -> Model -> (Model, Cmd msg)
update msg model =
    case msg of
        Ignore -> (model, Cmd.none)
        
        Click pos -> (model, Cmd.none)
            {-case model.move of
                Nothing -> ({ model | move = Selected pos}, Cmd.none)

                Selected sel -> 
                    if sel == pos
                    then ({ model | move = Nothing}, Cmd.none)
                    else ({ model | move = PreviewMove sel pos}, Cmd.none)

                PreviewMove from to ->
                    if from == pos then ({ model | move = Nothing}, Cmd.none)
                    else if to == pos then 
                        let (newModel, newCmd) = update (FinalizeMove from to) model
                            -- TODO Also do the webrtc send
                        in (newModel, newCmd)
                    else ({ model | move = PreviewMove from pos}, Cmd.none)
                -}
        FinalizeMove from to -> (model, Cmd.none)



-- SUBSCRIPTIONS
subscriptions : (Msg -> msg) -> Model -> Sub msg
subscriptions callback model = Sub.none
    --WebRTC.listenOn "game" decodeMessage Receive Ignore
