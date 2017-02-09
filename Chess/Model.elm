module Chess.Model exposing (..)

import List exposing (repeat, map, indexedMap)
import Dict exposing (Dict, fromList)
import Json.Encode as E exposing ( encode, object )
import Json.Decode as D exposing ( decodeString, map2, field )

import Chess.Piece as Piece exposing (..)

-- MODEL
type alias Position = (Int, Int) --Row, Column

type GameState 
    = Waiting
    | PieceSelected Position
    | PreviewMove Position Position

type alias Model = 
    { pieces : Dict Position Piece
    , graveyard : List Piece
    , state : GameState
    }

type alias Message = 
    { user : String
    , text : String
    }

initPieces : Dict Position Piece
initPieces = 
    let
        pawns color = repeat 8 <| Piece color Pawn
        pieces color = map (Piece color) [ Rook, Knight, Bishop, Queen, King, Bishop, Knight, Rook ]
        makeRow row = indexedMap (\col p -> ((row, col), p))
        whitePieces = makeRow 0 <| pieces White
        whitePawns = makeRow 1 <| pawns White
        blackPawns = makeRow 6 <| pawns Black
        blackPieces = makeRow 7 <| pieces Black
    in 
        fromList <| whitePieces ++ whitePawns ++ blackPawns ++ blackPieces

init : Model
init = Model initPieces [] Waiting
