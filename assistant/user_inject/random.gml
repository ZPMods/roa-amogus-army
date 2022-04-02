#define rand { // Returns a random value between low_value and high_value
    var index      = argument[0]; // Int
    var low_value  = argument[1]; // Float
    var high_value = argument[2]; // Float
    var floored    = argument[3]; // Bool
    
    return low_value + random_func(index, high_value - low_value, floored);
}

#define rand_int {
    return rand(argument[0], argument[1], argument[2], true);
}

#define rand_float {
    return rand(argument[0], argument[1], argument[2], false);
}

#define rand_in_list {
    var index   = argument[0]; // Int
    var list    = argument[1]; // List
    
    return list[random_func(argument[0], ds_list_size(list), true)];
}

#define rand_in_array {
    var index   = argument[0]; // Int
    var array   = argument[1]; // Array

    return array[random_func(argument[0], array_length(array), true)];
}

#define pct { // Rolls a % chance between 0 and 1
    var index   = argument[0]; // Int
    var chance  = argument[1]; // Float

    return random_func(argument[0], 1.00, false) <= argument[1];
}