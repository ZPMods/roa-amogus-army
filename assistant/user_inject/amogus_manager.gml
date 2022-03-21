#define new_random_amogus {
    if (amogus_count() >= max_amogus) {
        return;
    }

    // Init amogus
    var new_amogus = {  x: argument[1], y: argument[2], momentum_x: argument[3], momentum_y: argument[4], next_to_owner: false, // Position
                        state: states.idle, state_properties:get_state_properties(states.idle), cur_anim_frame: 0, frame_timer: 0, // Animation
                        mainCol: c_white, secondCol: c_white, hat:hats.post_it, hat_properties:get_hat_properties(hats.post_it), forced_timer: 0, stop_forced_on_end: false, // Visual
                        dir: 1, walk_speed: 0.0, acceleration: 0.0, x_stop_dist: 0, walk_timer: 0, is_walking: false, // Walking
                        on_ground: true, fall_time: 0, land_timer: 0, is_jumping: false, no_jump_timer: 0, jumpsquat_timer: -1, //Air
                        hp: argument[5], tumble: argument[6], heavy_land: true, hit_recently_timer: 0, hitpause_timer: 0, dead: false, dead_x:0, // Hit
                        focused: true, focused_timer:0, unfocused_timer:0, reaction_time: 0, wait_timer: 20 * argument[0], sitting: false, // Other
                        role: roles.doctor, possible_taunts: get_role_properties(roles.doctor).possibleTaunts, taunt_detected_done: false, is_taunting: false, taunt_timer:-1 }; // Taunt
    
    // VISUAL
    // Set colors
    random_color(argument[0], new_amogus);

    // Set hat
    random_hat(argument[0], new_amogus);
    
    // Set role
    //random_role(argument[0], new_amogus);

    // GAMEPLAY
    randomize_walk_values(new_amogus);
    new_amogus.no_jump_timer = rand(argument[0], min_nojump_time, max_nojump_time, true);

    // Put in array
    add_to_army_array(new_amogus, army);
}

#define new_ghost {
    var new_ghost = {  x: argument[0], y: argument[1], dir: argument[2], mainCol: argument[3], secondCol: argument[4], speed: 2.5, opacity: 0.5, cur_anim_frame: 0, frame_timer: 0 };

    // Put in array
    add_to_ghost_array(new_ghost, ghosts);
}

#define random_color {
    var amogus = argument[1];

    var color = colors_properties[random_func(argument[0], array_length(colors_properties), true)];
    amogus.mainCol = color.mainCol;
    amogus.secondCol = color.secondCol;
}

#define random_hat {
    var amogus = argument[1];

    var hat_properties = hats_properties[random_func(argument[0], array_length(hats_properties), true)];
    amogus.hat = hat_properties.hat;
    amogus.hat_properties = hat_properties;
}

#define random_role {
    var amogus = argument[1];

    var role_properties = roles_properties[random_func(argument[0], array_length(roles_properties), true)];
    amogus.role = role_properties.role;
    amogus.possible_taunts = role_properties.possibleTaunts;
}

#define add_to_army_array {
    for (var army_item_i=0; army_item_i<array_length(army); army_item_i++) {
        var army_item = army[army_item_i];

        if (army_item == noone) {
            army[army_item_i] = argument[0];
            return;
        }
    }

    array_push(army, argument[0]);
}

#define add_to_ghost_array {
    for (var ghost_i=0; ghost_i<array_length(ghosts); ghost_i++) {
        var ghost = ghosts[ghost_i];

        if (ghost == noone) {
            ghosts[ghost_i] = argument[0];
            return;
        }
    }

    array_push(ghosts, argument[0]);
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

#define get_state_properties {
    for (var state_property_i=0; state_property_i<array_length(states_properties); state_property_i++) {
        var state_property = states_properties[state_property_i];

        if (state_property.state == argument[0]) {
            return state_property;
        }
    }
}

#define get_hat_properties {
    for (var hat_property_i=0; hat_property_i<array_length(hats_properties); hat_property_i++) {
        var hat_property = hats_properties[hat_property_i];

        if (hat_property.hat == argument[0]) {
            return hat_property;
        }
    }
}

#define get_role_properties {
    for (var role_property_i=0; role_property_i<array_length(roles_properties); role_property_i++) {
        var role_property = roles_properties[role_property_i];

        if (role_property.role == argument[0]) {
            return role_property;
        }
    }
}

#define set_state {
    if (argument[0].state != argument[1]) {
        argument[0].cur_anim_frame = 0;
        argument[0].frame_timer = 0;
        argument[0].state = argument[1];
        argument[0].state_properties = get_state_properties(argument[1]);
    }
}

#define force_state {
    var amogus = argument[0];
    var state = argument[1];
    var time = argument[2];

    if (time <= 0) {
        amogus.forced_timer = 999;
        amogus.stop_forced_on_end = true;
    }
    else {
        amogus.forced_timer = time;
    }

    set_state(amogus, state);
}

#define is_in_taunt_state {
    var amogus = argument[0];
    switch (amogus.state) {
        case states.tauntPenguinDance :
        case states.tauntScan :
            return true
        break;
        
        default:
            return false;
        break;
    }
}

#define get_colors {
    for (var amogus_color_i=0; amogus_color_i<array_length(colors_properties); amogus_color_i++) {
        var amogus_color = colors_properties[amogus_color_i]

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

#define collision_down_line { // (x, y, down_offset)
    if (collision_line(argument[0], argument[1], argument[0], argument[1]+argument[2], asset_get("par_block"), false, true) ||
    collision_line(argument[0], argument[1], argument[0], argument[1]+argument[2], asset_get("par_jumpthrough"), false, true)) {
        return true;
    }
    else {
        return false;
    }
}

#define upper_ground_y {
    var amogus = argument[0];

    for (i=0; i <= 999; i++) { 
        if (!collision_at_point(amogus.x, round(amogus.y)-i)) {
            return amogus.y-i+1;
        }
    }

    return amogus.y;
}

#define lower_ground_y {
    var amogus = argument[0];

    for (i=0; i <= 999; i++) { 
        if (collision_at_point(amogus.x, round(amogus.y)+i)) {
            return amogus.y+i;
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
    var bool = false;
    
    if (argument[0].on_ground && argument[0].land_timer <= 0 && argument[0].jumpsquat_timer <= 0 && argument[0].wait_timer <= 0 && !argument[0].dead && !argument[0].tumble && !argument[0].is_taunting) {

        if ((argument[0].x <= get_stage_data(SD_X_POS) + argument[0].x_stop_dist && argument[0].dir == -1) || (argument[0].x >= get_stage_data(SD_X_POS) + get_stage_data(SD_WIDTH) - argument[0].x_stop_dist && argument[0].dir == 1)) {
            bool = false;
        }
        else {
            bool = true;
        }
    }

    return bool;
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

#define deal_damage {
    if (argument[0].hit_recently_timer <= 0) {
        argument[0].hp--;
        if (argument[0].hp <= 0) {
            argument[0].tumble = true;
            argument[0].dead = true;
            argument[0].dead_x = argument[0].x;
            new_ghost(argument[0].x, argument[0].y, argument[0].dir, argument[0].mainCol, argument[0].secondCol);
        }

        if (argument[0].dead) {
            argument[0].momentum_x = rand(0, -2.5, 2.5, false);
            argument[0].momentum_y = -rand(1, 2.0, 5.0, false);
        }
    }
    
    argument[0].hit_recently_timer = hit_resistance_time;
}

#define taunt {
    var amogus = argument[1];

    var taunt;

    if (amogus.hat == hats.none && pct(argument[0], 0.05)) {
        taunt = states.tauntPenguinDance;
    }
    else {
        taunt = amogus.possible_taunts[random_func(argument[0], array_length(amogus.possible_taunts), true)];
    }
    
    force_state(amogus, taunt, 0);
    amogus.is_taunting = true;
}

#define vent {
    var amogus = argument[1];

    amogus.y -= 200;
    amogus.x = random_point_above_stage(argument[0]);

    amogus.y = lower_ground_y(amogus);
}

#define random_point_above_stage {
    var x_offset = random_func(argument[0], get_stage_data(SD_WIDTH), true) - get_stage_data(SD_WIDTH)/2;
    return stage_center_x + x_offset;
}

#define momentum_to_point {
    var dist = argument[1] - argument[2];
    var momentum = dist/30 + rand(i, -1.0, 1.0, false);
    return -momentum;
}

#define rand {
    return argument[1] + random_func(argument[0], argument[2] - argument[1], argument[3]);
}

#define pct {
    return random_func(argument[0], 1.00, false) <= argument[1];
}