module Chat.Model exposing (..)

import Json.Encode as E exposing ( encode, object )
import Json.Decode as D exposing ( decodeString, map2, field )

-- MODEL
type alias Model = 
    { message : Message
    , messages : List Message
    , debugCount : Int
    }

type alias Message = 
    { user : String
    , text : String
    }

init : Model
init = Model (Message "" "") [] 0



encodeMessage : Message -> String
encodeMessage msg = 
    encode 0 <| object
        [ ("user", E.string msg.user)
        , ("text", E.string msg.text)
        ]

decodeMessage : String -> Result String Message
decodeMessage =
    decodeString <| map2 Message (field "user" D.string) (field "text" D.string)
