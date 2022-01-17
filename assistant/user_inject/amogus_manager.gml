#define new_random_amogus {
    if (amogus_count() >= max_amogus) {
        return;
    }

    // Init amogus
    var new_amogus = {  x: owner.x-100, y: 496, momentum_x: 0.0, momentum_y: 0.0, next_to_owner: false, // Position
                        state: "idle", cur_anim_frame: 0, frame_timer: 0, mainCol: c_white, secondCol: c_white, hat:"post_it", // Visual
                        dir: 1, walk_speed: 0.0, acceleration: 0.0, x_stop_dist: 0, walk_timer: 0, is_walking: false, // Walking
                        on_ground: true, fall_time: 0, land_timer: 0, is_jumping: false, no_jump_timer: 0, //Air
                        hp: 1, tumble: true, heavy_land: true, hit_recently_timer: 0, hitpause_timer: 0, dead: false, dead_x:0, // Hit
                        focused: true, focused_timer:0, unfocused_timer:0, reaction_time: 0, wait_timer: 0 }; // Other
    
    // VISUAL
    // Set colors
    var color = amogus_colors[random_func(0, array_length(amogus_colors), true)];
    new_amogus.mainCol = color.mainCol;
    new_amogus.secondCol = color.secondCol;

    // Set hat
    var hat = hat_names[random_func(1, array_length(hat_names), true)];
    new_amogus.hat = hat;
    
    // GAMEPLAY
    randomize_walk_values(new_amogus);
    new_amogus.no_jump_timer = rand(0, min_nojump_time, max_nojump_time, true);

    // Put in array
    add_to_array(new_amogus);

    jump(new_amogus);
}

#define add_to_array {
    for (var army_item_i=0; army_item_i<array_length(army); army_item_i++) {
        var army_item = army[army_item_i];

        if (army_item == noone) {
            print("found empty");
            army[army_item_i] = argument[0];
            return;
        }
    }

    array_push(army, argument[0]);
}

#define amogus_count {
    var count = 0;
    
    for (var army_item_i=0; army_item_i<array_length(army); army_item_i++) {
        var army_item = army[army_item_i];

        if (army_item != noone) {
            count++;
        }
    }

    return count;
}

#define randomize_walk_values {
    // Walk speed
    argument[0].walk_speed = rand(2, min_walk_speed, max_walk_speed, false) / divider;

    // Walk stop
    argument[0].x_stop_dist = rand(3, x_min_stop_dist, x_max_stop_dist, true)

    // Acceleration
    argument[0].acceleration = rand(4, min_acceleration, max_acceleration, false) / divider;

    // Reaction time
    argument[0].reaction_time = rand(5, min_reaction_time, max_reaction_time, true);
}

#define randomize_unfocused_walk_values {
    randomize_walk_values(argument[0]);
    argument[0].walk_speed -= 1.5;
    argument[0].reaction_time *= 1.5;
}

#define try_to_lose_focus {
    if (pct(0, chance_to_lose_focus)) {
        randomize_unfocused_walk_values(argument[0]);

        argument[0].unfocused_timer = rand(0, min_unfocused_time, max_unfocused_time, true);
        argument[0].walk_timer = rand(0, min_unfocused_walk_time, max_unfocused_walk_time, true);
        argument[0].wait_timer = argument[0].reaction_time;
        
        argument[0].focused = false;
    }
}
#define get_colors {
    for (var amogus_color_i=0; amogus_color_i<array_length(amogus_colors); amogus_color_i++) {
        var amogus_color = amogus_colors[amogus_color_i]

            if (amogus_color.name == argument[0]) {
            return amogus_color;
        }
    }
}

#define collision_at_point {
    if (collision_point(argument[0], argument[1], asset_get("par_block"), false, true) ||
    collision_point(argument[0], argument[1], asset_get("par_jumpthrough"), false, true)) {
        return true;
    }
    else {
        return false;
    }
}

#define upper_ground_y {
    var amogus = argument[0];

    for (i=0; i <= 999999; i++) { 
        if (!collision_at_point(amogus.x, round(amogus.y)-i)) {
            return amogus.y-i+1;
        }
    }

    return amogus.y;
}

#define dir_to_owner {
    if (owner.x > argument[0].x) {
        return 1;
    }
    else {
        return -1;
    }
}

#define randomize_dir {
    argument[0].dir = pct(0, 0.5) ? 1 : -1;
}

#define dir_from_momentum {
    if (argument[0].momentum_x > 0) {
        return 1;
    }
    else {
        return -1;
    }
}

#define should_walk {
    return (argument[0].on_ground && argument[0].land_timer <= 0 && argument[0].wait_timer <= 0 && !argument[0].dead);
}

#define walk {
    argument[0].momentum_x += argument[0].acceleration * argument[0].dir;
    
    if (abs(argument[0].momentum_x) > argument[0].walk_speed) {
        argument[0].momentum_x = argument[0].walk_speed * argument[0].dir;
    }
}

#define jump {
    var lerp_val = (argument[0].y - owner.y - 100)/100;
    lerp_val = clamp(lerp_val, 0, 1);

    var base_jump_force = lerp(min_jump_height, max_jump_height, lerp_val);
    var jump_force = base_jump_force + rand(0, -1.0, 1.0, false)

    lerp_val = abs(argument[0].x - owner.x)/100;
    lerp_val = clamp(lerp_val, 0, 1);

    var jump_forward = lerp(0, rand(0, min_walk_speed, max_walk_speed, false) / divider, lerp_val);

    argument[0].momentum_y = -jump_force;
    argument[0].momentum_x = jump_forward * dir_to_owner(argument[0]);
    argument[0].is_jumping = true;
}

#define rand {
    return argument[1] + random_func(argument[0], argument[2] - argument[1], argument[3]);
}

#define pct {
    return random_func(argument[0], 1.00, false) <= argument[1];
}