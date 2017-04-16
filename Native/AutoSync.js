// https://elmseeds.thaterikperson.com/native-modules

var _user$project$Native_AutoSync = function() {

    // Native functions
    function addOne(a) {
        return a + 1;
    };

    function autoSync(model) {
        console.log(model);
        return model;
    }

    return {
        //setItem: F2(setItem)
        addOne: addOne,
        autoSync: autoSync
    }

}();
