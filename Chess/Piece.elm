module Chess.Piece exposing (..)

type PieceType = King | Queen | Rook | Bishop | Knight | Pawn
type Color = Black | White
type alias Piece = 
    { color : Color
    , figure : PieceType
    }

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
