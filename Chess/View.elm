module Chess.View exposing (..)

import Chess.Model exposing (..)
import Html exposing ( Html )
import Svg exposing (..)
import Svg.Attributes exposing (..)

-- VIEW
type Config msg = Config
    { click : Position -> msg 
    , finalizeMove : Position -> Position -> msg
    }

view : Config msg -> Model -> Html msg
view (Config config) model =
    svg
      [ class "chess", width "256", height "256", viewBox "0 0 256 256" ]
      [ viewBoard 256 ]

viewBoard : Int -> Svg msg
viewBoard size =
    let 
        vdc = viewDarkCell (toFloat size / 8)
    in 
        node "svg" [class "board"]
            [ rect [ class "back", x "0", y "0", width <| toString size, height <| toString size ] []
            , vdc 7 1, vdc 7 3, vdc 7 5, vdc 7 7 --dark cells
            , vdc 6 0, vdc 6 2, vdc 6 4, vdc 6 6
            , vdc 5 1, vdc 5 3, vdc 5 5, vdc 5 7
            , vdc 4 0, vdc 4 2, vdc 4 4, vdc 4 6
            , vdc 3 1, vdc 3 3, vdc 3 5, vdc 3 7
            , vdc 2 0, vdc 2 2, vdc 2 4, vdc 2 6
            , vdc 1 1, vdc 1 3, vdc 1 5, vdc 1 7
            , vdc 0 0, vdc 0 2, vdc 0 4, vdc 0 6
            ]

viewDarkCell : Float -> Int -> Int -> Svg msg
viewDarkCell size row col =
    let
        (xPos, yPos) = toCoordinates size row col
    in
        rect 
            [ class "dark"
            , x <| toString xPos, y <| toString yPos
            , width <| toString size, height <| toString size 
            ] []

toCoordinates : Float -> Int -> Int -> (Float, Float)
toCoordinates size row col = (toFloat col * size, 7 * size - toFloat row * size)