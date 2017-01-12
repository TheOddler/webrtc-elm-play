module Game exposing (..)

import Html exposing ( Html, div, span, text, input, button, table, tr, td )
import Html.Events exposing (..)
import Html.Attributes as A exposing ( class, id )
import WebRTC exposing (..)
import List exposing (..)

-- MODEL
type PieceType = King | Queen | Rook | Bishop | Knight | Pawn
type Color = Black | White
type alias Piece = 
    { color : Color
    , figure : PieceType
    }

type Square = Empty | Contains Piece

type alias Board = List (List Square)

type alias Model = 
    { board : Board
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
init = Model initBoard []


-- UPDATE
type Msg 
    = Ignore

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        Ignore -> (model, Cmd.none)


-- SUBSCRIPTIONS
subscriptions : Model -> Sub Msg
subscriptions model = Sub.none
    --WebRTC.listenOn "game" decodeMessage Receive Ignore

-- VIEW
view : Model -> Html Msg
view model =
    div [ class "Game" ] [ viewBoard model.board ]

viewBoard : Board -> Html Msg
viewBoard board = 
    table [ class "Board" ]
        <| List.indexedMap viewBoardRow board

viewBoardRow : Int -> List Square -> Html Msg
viewBoardRow rowIndex squares =
    tr [ class "row" ] 
        <| List.indexedMap (viewBoardSquare rowIndex) squares

viewBoardSquare : Int -> Int -> Square -> Html Msg
viewBoardSquare rowIndex colIndex sq =
    let 
        c = if (rowIndex + colIndex) % 2 == 1 then "dark cell" else "light cell"
    in
        case sq of
            Empty -> td [ class c ] []
            Contains piece -> td [ class c ] [ viewPiece piece ]

viewPiece : Piece -> Html Msg
viewPiece piece =
    div [ class "piece" ] [ text <| pieceToText piece ]

pieceToText : Piece -> String
pieceToText piece =
    case piece.color of
        Black -> 
            case piece.figure of
                King -> "♚"
                Queen -> "♛"
                Rook -> "♜"
                Bishop -> "♝"
                Knight -> "♞"
                Pawn -> "♟"
        White ->
            case piece.figure of
                King -> "♔"
                Queen -> "♕"
                Rook -> "♖"
                Bishop -> "♗"
                Knight -> "♘"
                Pawn -> "♙"
