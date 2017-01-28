module Chess.Game exposing (..)

import Html exposing ( Html, div, span, text, input, button, table, tr, td, ul, li )
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
type MoveState 
    = Nothing
    | Selected Position
    | PreviewMove Position Position
type alias Model = 
    { board : Board
    , dead : List Piece
    , move : MoveState
    }

pawnRow : Color -> List Square
pawnRow color = repeat 8 <| Contains <| Piece color Pawn

emptyRow : List Square
emptyRow = repeat 8 <| Empty

figureRow : Color -> List Square
figureRow color = map (Contains << Piece color) [ Rook, Knight, Bishop, Queen, King, Bishop, Knight, Rook ]

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
init = Model initBoard [] Nothing


-- UPDATE
type Msg 
    = Ignore
    | Click Position
    | FinalizeMove Position Position

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        Ignore -> (model, Cmd.none)
        
        Click pos -> 
            case model.move of
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
                
        FinalizeMove from to -> 
            ({ board = model.board
            , dead = model.dead
            , move = Nothing
            }, Cmd.none)



-- SUBSCRIPTIONS
subscriptions : Model -> Sub Msg
subscriptions model = Sub.none
    --WebRTC.listenOn "game" decodeMessage Receive Ignore


-- VIEW
view : Model -> Html Msg
view model =
    div [ class "Game" ] 
        [ viewBoard model.move model.board
        , viewDead model.dead
        ]


viewBoard : MoveState -> Board -> Html Msg
viewBoard move board = 
    table [ class "Board" ]
        <| List.indexedMap (viewBoardRow move) board

viewBoardRow : MoveState -> Int -> List Square -> Html Msg
viewBoardRow move rowIndex squares =
    tr [ class "Row" ] 
        <| List.indexedMap (viewBoardSquare move rowIndex) squares

viewBoardSquare : MoveState -> Int -> Int -> Square -> Html Msg
viewBoardSquare move rowIndex colIndex sq =
    let 
        c = if (rowIndex + colIndex) % 2 == 1 then "Dark" else "Light"
        m =
            case move of
                Nothing -> ""
                Selected pos -> if pos.row == rowIndex && pos.col == colIndex then " Selected" else ""
                PreviewMove from to ->
                    if from.row == rowIndex && from.col == colIndex then " Selected Move From"
                    else if to.row == rowIndex && to.col == colIndex then " Move To"
                    else ""
        attr = [ class <| c ++ m ++ " Cell", onClick <| Click <| Position rowIndex colIndex ]
    in
        case sq of
            Empty -> td attr []
            Contains piece -> td attr [ Piece.toDiv piece ]


viewDead : List Piece -> Html Msg
viewDead dead =
    ul  [ class " Dead" ]
        <| List.map (\p -> li [] [ text <| Piece.toText p ] ) dead

