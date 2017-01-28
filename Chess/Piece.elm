module Chess.Piece exposing (..)

import Html exposing ( Html, div, span, text, input, button, table, tr, td )
import Html.Attributes as A exposing ( class, id )


type PieceType = King | Queen | Rook | Bishop | Knight | Pawn
type Color = Black | White
type alias Piece = 
    { color : Color
    , figure : PieceType
    }

toDiv : Piece -> Html msg
toDiv piece =
    div [ class "piece" ] [ text <| toText piece ]

toText : Piece -> String
toText piece =
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
