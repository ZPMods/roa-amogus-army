#define new_random_amogus {
    // Init amogus
    var new_amogus = { x: 0, y: 0, state: "idle", cur_anim_frame: 0, frame_timer: 0, dir: 1, mainCol: c_white, secondCol: c_white, hat:"post_it" };
    
    // Set colors
    var color = amogus_colors[random_func(0, array_length(amogus_colors), true)];
    new_amogus.mainCol = color.mainCol;
    new_amogus.secondCol = color.secondCol;

    // Set hat
    var hat = hat_names[random_func(1, array_length(hat_names), true)];
    new_amogus.hat = hat;
    
    // Put in array

    array_push(army, new_amogus);
}

#define get_colors {
    for (var amogus_color_i=0; amogus_color_i<array_length(amogus_colors); amogus_color_i++) {
        var amogus_color = amogus_colors[amogus_color_i]

            if (amogus_color.name == argument[0]) {
            return amogus_color;
        }
    }
}