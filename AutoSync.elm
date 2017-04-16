module AutoSync exposing (addOne, autoSync)

-- imports are weird for Native modules
-- You import them as you would normal modules
-- but you can't alias them nor expose stuff from them
import Native.AutoSync 

-- this will be our function which returns a number plus one
addOne : Int -> Int
addOne = Native.AutoSync.addOne

autoSync : model -> model
autoSync = Native.AutoSync.autoSync
