module Chess.Game exposing (..)

import Html exposing ( Html, div, span, text, input, button, table, tr, td )
import Html.Events exposing (..)
import Html.Attributes as A exposing ( class, id )
import WebRTC exposing (..)
import List exposing (..)

import Chess.Piece as Piece exposing (..)

-- MODEL
type Square = Empty | Contains Piece

type alias Board = List (List Square)
type alias Position =
    { row : Int
    , col : Int
    }
type alias Model = 
    { board : Board
    , selection : Position
    , dead : List Piece
    }

pawnRow : Color -> List Square
pawnRow color = repeat 8 <| Contains <| Piece color Pawn

emptyRow : List Square
emptyRow = repeat 8 <| Empty

figureRow : Color -> List Square
figureRow color =
    let pieces = [ Rook, Knight, Bishop, Queen, King, Bishop, Knight, Rook ]
    in map (\p -> Contains <| Piece color p) pieces

initBoard : Board
initBoard = 
    [ figureRow Black
    , pawnRow Black
    , emptyRow
    , emptyRow
    , emptyRow
    , emptyRow
    , pawnRow White
    , figureRow White
    ]

init : Model
init = Model initBoard (Position -1 -1) []


-- UPDATE
type Msg 
    = Ignore
    | Click Position

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        Ignore -> (model, Cmd.none)
        
        Click pos -> ({ model | selection = pos}, Cmd.none)


-- SUBSCRIPTIONS
subscriptions : Model -> Sub Msg
subscriptions model = Sub.none
    --WebRTC.listenOn "game" decodeMessage Receive Ignore

-- VIEW
view : Model -> Html Msg
view model =
    div [ class "Game" ] [ viewBoard model.selection model.board ]

viewBoard : Position -> Board -> Html Msg
viewBoard selection board = 
    table [ class "Board" ]
        <| List.indexedMap (viewBoardRow selection) board

viewBoardRow : Position -> Int -> List Square -> Html Msg
viewBoardRow selection rowIndex squares =
    tr [ class "row" ] 
        <| List.indexedMap (viewBoardSquare selection rowIndex) squares

viewBoardSquare : Position -> Int -> Int -> Square -> Html Msg
viewBoardSquare selection rowIndex colIndex sq =
    let 
        c = if (rowIndex + colIndex) % 2 == 1 then "dark" else "light"
        s = if selection.row == rowIndex && selection.col == colIndex then " selected" else ""
        attr = [ class <| c ++ s ++ " cell", onClick <| Click <| Position rowIndex colIndex ]
    in
        case sq of
            Empty -> td attr []
            Contains piece -> td attr [ Piece.view piece ]
