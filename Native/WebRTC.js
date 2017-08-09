var _user$project$Native_WebRTC = function() {

    // Native functions
    function addOne(a) {
        return a + 1;
    };

    function send(message)
    {
        return _elm_lang$core$Native_Scheduler.nativeBinding(function(callback)
        {
            /*var result =
                socket.readyState === WebSocket.OPEN
                    ? _elm_lang$core$Maybe$Nothing
                    : _elm_lang$core$Maybe$Just({ ctor: 'NotOpen' });*/
            var result = _elm_lang$core$Maybe$Nothing // bad connection always nothing for now

            // Do the actual sending
            try
            {
                connection.send(message)
            }
            catch(err)
            {
                result = _elm_lang$core$Maybe$Just({ ctor: 'BadMessage' });
            }

            callback(_elm_lang$core$Native_Scheduler.succeed(result));
        });
    }

    return {
        //setItem: F2(setItem)
        addOne: addOne,
        send: send
    }

}();
