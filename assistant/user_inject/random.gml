#define rand { // Returns a random value between low_value and high_value
    var index      = seeded_index(argument[0]); // Int
    var low_value  = argument[1]; // Float
    var high_value = argument[2]; // Float
    var floored    = argument[3]; // Bool
    
    return low_value + random_func_2(index, high_value - low_value, floored);
}

#define rand_int {
    return rand(argument[0], argument[1], argument[2], true);
}

#define rand_float {
    return rand(argument[0], argument[1], argument[2], false);
}

#define rand_in_list {
    var index   = seeded_index(argument[0]); // Int
    var list    = argument[1]; // List
    
    return list[random_func_2(index, ds_list_size(list), true)];
}

#define rand_in_array {
    var index   = seeded_index(argument[0]); // Int
    var array   = argument[1]; // Array

    return array[random_func_2(index, array_length(array), true)];
}

#define pct { // Rolls a % chance between 0 and 1
    var index   = seeded_index(argument[0]); // Int
    var chance  = argument[1]; // Float

    return random_func_2(index, 1.00, false) <= argument[1];
}

#define seeded_index {
    var index = argument[0]; // Int

    index += seed;
    return (index % 199);
}