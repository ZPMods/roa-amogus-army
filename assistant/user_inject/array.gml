#define array_add {
    var array = argument[0];
    var to_add = argument[1];

    for (var i=0; i<array_length(array); i++) {
        var entry = array[i];

        if (entry == noone) {
            array[i] = to_add;
            return i;
        }
    }

    array_push(array, to_add);
    return array_length(array) - 1;
}