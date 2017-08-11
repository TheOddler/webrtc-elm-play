module Chess.View exposing (..)

import Html exposing ( Html, div, ul, li )
import Dict exposing (Dict, toList)
import Svg exposing (..)
import Svg.Attributes exposing (..)
import Svg.Events exposing (..)

import Chess.Model exposing (..)
import Chess.Piece as Piece exposing (..)

-- VIEW
type Config msg = Config
    { click : Position -> msg 
    , finalizeMove : Position -> Position -> msg
    }

view : Config msg -> Model -> Html msg
view config model =
    let 
        size = 300
        sizeText = toString size
    in
        div [class "chess"]
            [ svg
                [ width sizeText, height sizeText, viewBox <| "0 0 " ++ sizeText ++ " " ++ sizeText ]
                [ viewBoard config size model.state
                , viewPieces config size model.pieces model.state
                , text "Your browser doesn't support svg :("
                ]
            , viewGraveyard size model.graveyard
            ]

viewPieces : Config msg -> Int -> Dict Position Piece -> GameState -> Svg msg
viewPieces config size pieces state =
    node "svg" [class "pieces"] 
        <| List.map (viewPiece config (toFloat size / 8) state) <| Dict.toList pieces

viewPiece : Config msg -> Float -> GameState -> (Position, Piece) -> Svg msg
viewPiece (Config cnfg) size state ((row, col), piece) = 
    let
        (baseX, baseY) = toCoordinates size row col
        xPos = toString <| baseX + size / 2
        yPos = toString <| baseY + size - size / 10
        s = toString size
        isSel = case state of
            Waiting -> False
            PieceSelected pos -> pos == (row, col)
            PreviewMove from _ -> from == (row, col)
    in 
        text_ 
            [ class <| String.append "piece" (if isSel then " selected" else "")
            , onClick <| cnfg.click (row, col)
            , x xPos, y yPos
            , fontSize s
            , textAnchor "middle" 
            ] 
            [ text <| Piece.toText piece 
            ]

viewBoard : Config msg -> Int -> GameState -> Svg msg
viewBoard config size state =
    let 
        vc = viewCell config (toFloat size / 8)
        even = (\row col -> vc (if col % 2 == 0 then "dark cell" else "light cell") state row col)
        odd = (\row col -> vc (if col % 2 == 1 then "dark cell" else "light cell") state row col)
        cols = List.range 0 7
        s = toString size
    in 
        node "svg" [class "board"]
            <| [ rect [ class "back", x "0", y "0", width s, height s ] [] ]
            ++ (List.map (even 0) cols)
            ++ (List.map (odd  1) cols)
            ++ (List.map (even 2) cols)
            ++ (List.map (odd  3) cols)
            ++ (List.map (even 4) cols)
            ++ (List.map (odd  5) cols)
            ++ (List.map (even 6) cols)
            ++ (List.map (odd  7) cols)

viewCell : Config msg -> Float -> String -> GameState -> Int -> Int -> Svg msg
viewCell (Config cnfg) size class_ state row col =
    let
        (xPos, yPos) = toCoordinates size row col
        isPrev = case state of
            Waiting -> False
            PieceSelected pos -> False
            PreviewMove _ to -> to == (row, col)
    in
        rect [ class <| String.append class_ (if isPrev then " preview" else "")
             , onClick <| cnfg.click (row, col)
             , x <| toString xPos, y <| toString yPos
             , width <| toString size, height <| toString size 
             ] []

viewGraveyard : Float -> List Piece -> Html msg
viewGraveyard size graveyard =
    ul  [ class "graveyard" ]
        <| List.map (\p -> li [] [ text <| Piece.toText p ] ) graveyard

toCoordinates : Float -> Int -> Int -> (Float, Float)
toCoordinates size row col = (toFloat col * size, 7 * size - toFloat row * size)
