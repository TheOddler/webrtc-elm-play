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
type alias Selection =
    { row : Int
    , col : Int
    }
type alias Model = 
    { board : Board
    , selected : Selection
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
init = Model initBoard (Selection -1 -1) []


-- UPDATE
type Msg 
    = Ignore
    | Select Selection

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        Ignore -> (model, Cmd.none)
        
        Select sel -> ({ model | selected = sel}, Cmd.none)


-- SUBSCRIPTIONS
subscriptions : Model -> Sub Msg
subscriptions model = Sub.none
    --WebRTC.listenOn "game" decodeMessage Receive Ignore

-- VIEW
view : Model -> Html Msg
view model =
    div [ class "Game" ] [ viewBoard model.selected model.board ]

viewBoard : Selection -> Board -> Html Msg
viewBoard sel board = 
    table [ class "Board" ]
        <| List.indexedMap (viewBoardRow sel) board

viewBoardRow : Selection -> Int -> List Square -> Html Msg
viewBoardRow sel rowIndex squares =
    tr [ class "row" ] 
        <| List.indexedMap (viewBoardSquare sel rowIndex) squares

viewBoardSquare : Selection -> Int -> Int -> Square -> Html Msg
viewBoardSquare sel rowIndex colIndex sq =
    let 
        a = if (rowIndex + colIndex) % 2 == 1 then "dark" else "light"
        s = if sel.row == rowIndex && sel.col == colIndex then " selected" else ""
        c = a ++ s ++ " cell"
    in
        case sq of
            Empty -> td [ class c ] []
            Contains piece -> td [ class c, onClick <| Select <| Selection rowIndex colIndex ] [ Piece.view piece ]
