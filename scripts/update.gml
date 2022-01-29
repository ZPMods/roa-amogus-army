// INIT
if (!init_done) {
    init_done = true;

    for (i=0; i<base_amogus; i++) {
        new_random_amogus(i, owner.x+rand(i, -50, 50, false), owner.y, 0.0, 0.0, base_hp, false);
    }
}

// UPDATE
// Army behavior
for (var army_item_i=0; army_item_i<array_length(army); army_item_i++) {
    var amogus = army[army_item_i];

    if (amogus == noone) {
        continue;
    }

    // ANIM STUFF -----------
    // Take care of everything about frame timer in update
    // So that it stops when in pause
    var anim_speed = get_state_properties(amogus.state).speed;
    var frame_timer_max = 60 / anim_speed;

    // Pause anims during hitpause
    if (amogus.hitpause_timer <= 0) {
        amogus.frame_timer ++;
    }

    if (amogus.frame_timer >= frame_timer_max) {
        amogus.cur_anim_frame++;
        
        if (amogus.cur_anim_frame >= get_state_properties(amogus.state).frameCount) {
            amogus.cur_anim_frame = 0;
        }

        amogus.frame_timer = 0;
    }

    // IA STUFF -----------
    // HITPAUSE
    if (amogus.hitpause_timer > 0) {
        amogus.hitpause_timer --;
        continue;
    }

    // Friction
    amogus.momentum_x *= amogus.on_ground ? ground_friction : air_friction;

    // Focused timer
    if (amogus.focused_timer <= 0 && amogus.focused) {
        try_to_lose_focus(amogus);
        if (amogus.focused) {
            amogus.focused_timer = rand(army_item_i, min_focused_time, max_focused_time, true);
        }
    }

    // UNFOCUSED
    if (amogus.unfocused_timer > 0) {
        // Walk
        if (amogus.walk_timer > 0) {
            if (should_walk(amogus)) {
                if (!amogus.is_walking) {
                    amogus.is_walking = true;
                }

                walk(amogus);
            }
        }
        else {
            // On stop
            if (amogus.is_walking) {
                amogus.is_walking = false;

                amogus.wait_timer = rand(army_item_i, min_unfocused_wait_time, max_unfocused_wait_time, true);
            }
        }

        if (amogus.wait_timer <= 0 && amogus.walk_timer <= 0 && amogus.land_timer <= 0 && amogus.on_ground) {
            randomize_dir(amogus);
            amogus.walk_timer = rand(army_item_i, min_unfocused_walk_time, max_unfocused_walk_time, true);
        }
    } 
    //FOCUSED
    else { 
        // On focus change
        if (!amogus.focused) {
            amogus.focused = true;
            randomize_walk_values(amogus);
        }

        // Look at player
        if (amogus.dir != dir_to_owner(amogus) && amogus.on_ground && amogus.land_timer <= 0) {
            amogus.dir = dir_to_owner(amogus);
        }

        // Far from player
        if (abs(amogus.x - owner.x) > amogus.x_stop_dist) {
            // Walk towards player
            if (should_walk(amogus)) {
                if (!amogus.is_walking) {
                    amogus.is_walking = true;
                }

                walk(amogus);
            }
        }
        // Stopped at player
        else {
            // On stop
            if (amogus.is_walking) {
                amogus.is_walking = false;
                
                // Lose focus
                try_to_lose_focus(amogus);
            }
            
            amogus.wait_timer += 2;
            if (amogus.wait_timer > amogus.reaction_time) {
                amogus.wait_timer = amogus.reaction_time;
            }
        }

        // Right next to player (on x and y)
        if (abs(amogus.x - owner.x) < amogus.x_stop_dist && amogus.y - owner.y < y_jump_dist) {
            if (!amogus.next_to_owner) {
                amogus.next_to_owner = true;
            }
        }
        else {
            if (amogus.next_to_owner) {
                amogus.next_to_owner = false;
            }
        }
    }

    // COLLISION CHECKS
    // Ground
    if (collision_at_point(amogus.x, amogus.y+1) && amogus.momentum_y >= 0) {
        if (!amogus.on_ground && !amogus.dead) {
            // On land
            var landlag_mult = 1;
            if (amogus.tumble == true) {
                amogus.tumble = false;
                amogus.heavy_land = true;
                landlag_mult = 2;

                // Deal damage
                deal_damage(amogus);
            }

            amogus.land_timer = max(amogus.land_timer, amogus.fall_time * landlag_mult);

            amogus.fall_time = 0;

            amogus.on_ground = true;

            if (amogus.is_jumping) {
                amogus.is_jumping = false;
            }
        }

        if (collision_at_point(amogus.x, amogus.y) && !amogus.dead) {
            amogus.y = upper_ground_y(amogus);
        }

        // Jump
        if (amogus.no_jump_timer <= 0 && amogus.focused) {
            jump(amogus);
            amogus.no_jump_timer = rand(army_item_i, min_nojump_time, max_nojump_time, true);
        } 
    }
    // Air start
    else {
        if (amogus.on_ground) {
            amogus.on_ground = false;

            if (amogus.heavy_land == true) {
                amogus.heavy_land = false;
            }
        }
    }

    // In air
    if (!amogus.on_ground) {
        if (amogus.momentum_y > 0) {
            amogus.fall_time++;
        }

        amogus.momentum_y += gravity;

        if (amogus.momentum_y > fall_speed && !amogus.tumble) {
            amogus.momentum_y = fall_speed;
        }
    }
    else if (amogus.momentum_y > 0) {
        amogus.momentum_y = 0;
    }

    // Walls
    if (abs(amogus.momentum_x) > 0 && collision_point(amogus.x + 16 * dir_from_momentum(amogus), amogus.y - 20, asset_get("par_block"), false, true) && !amogus.dead) {
        if (amogus.tumble) {
            amogus.momentum_x *= -1;
        }
        else {
            amogus.momentum_x = 0;
        }
    }

    // GAME INTERACTIONS
    // Respawn on bottom blastzone
    if (amogus.y >= get_stage_data(SD_Y_POS) + get_stage_data(SD_BOTTOM_BLASTZONE) && amogus.momentum_y > 0) {
        if (amogus.dead) {
            army[army_item_i] = noone;
            continue;
        }
        else {
            amogus.x = room_width / 2 + rand(army_item_i, -150, 150, true);
            amogus.y = 0;
            amogus.tumble = true;
        }
    }

    // APPLY
    // Apply values
    amogus.x += amogus.momentum_x;
    amogus.y += amogus.momentum_y;

    // Anim states
    if (amogus.on_ground) {
        if (should_walk(amogus) && abs(amogus.momentum_x) > 0.2) {
            set_state(amogus, "run");
        }
        else {
            // Land
            if (amogus.land_timer > 0) {
                // Heavy land
                if (amogus.heavy_land) {
                    set_state(amogus, "heavyland");
                }
                else {
                    set_state(amogus, "land");
                }
            } else {
                set_state(amogus, "idle");
            }
        }
    }
    else {
        // Tumble
        if (amogus.dead == true) {
            set_state(amogus, "dead");
        }
        else if (amogus.tumble == true) {
            set_state(amogus, "tumble");
        }
        else {
            if (amogus.momentum_y > 0) {
                set_state(amogus, "fall");
            }
            else {
                set_state(amogus, "rise");
            }
        }
    }

    // Timers
    if (amogus.land_timer > 0 && !amogus.dead) {
        amogus.land_timer--;
    }

    if (amogus.wait_timer > 0 && !amogus.dead) {
        amogus.wait_timer--;
    }
    
    if (amogus.focused_timer > 0 && !amogus.dead) {
        amogus.unfocused_timer--;
    } 

    if (amogus.unfocused_timer > 0 && !amogus.dead) {
        amogus.unfocused_timer--;
    } 

    if (amogus.walk_timer > 0 && !amogus.dead) {
        amogus.walk_timer--;
    } 

    if (amogus.hit_recently_timer > 0 && !amogus.dead) {
        amogus.hit_recently_timer--;
    } 
    
    if (amogus.no_jump_timer > 0 && !amogus.is_jumping && amogus.land_timer <= 0 && !amogus.next_to_owner && amogus.focused && amogus.y - owner.y > y_jump_dist && !amogus.dead) {
        amogus.no_jump_timer--;
    } 
}

// OWNER GOT HIT
if (owner.state_cat == SC_HITSTUN && owner.state_timer == 0 && owner.hitpause) {
    if (!got_hit_detected_done) {
        // On hit
        got_hit_detected_done = true;

        for (var army_item_i=0; army_item_i<array_length(army); army_item_i++) {
            var amogus = army[army_item_i];

            if (amogus == noone) {
                continue;
            }

            // Affect close amoguses
            if (point_distance(owner.x, owner.y, amogus.x, amogus.y) < hit_transfer_radius && !amogus.dead) {

                amogus.hitpause_timer = owner.hitstop_full;
                amogus.tumble = true;

                // Hitbox
                var hitbox = owner.enemy_hitboxID;

                var ang = get_hitbox_angle(hitbox);
                ang += rand(army_item_i, -hit_ang_var, hit_ang_var, true);

                var force = hitbox.kb_value + hitbox.kb_scale * 0.05 * get_player_damage(owner.player); 
                force += rand(army_item_i, -hit_force_var, hit_force_var, true);

                var force_x = lengthdir_x( force, ang );
                var force_y = lengthdir_y( force, ang );

                // Bounce on ground
                if (amogus.on_ground && force_y > 0) {
                    force_y *= -0.5;
                }

                amogus.momentum_x = force_x;
                amogus.momentum_y = force_y;
            }
        }
    }
}
else if (got_hit_detected_done) {
    got_hit_detected_done = false;
}

// OWNER HITS ENEMY
if (owner.hit_player_obj > 0 && owner.hit_player_obj.hitpause && owner.hit_player_obj.state_cat == SC_HITSTUN) {
    if (!hit_enemy_detected_done && last_hit_enemy != owner.hit_player_obj) {
        // On hit enemy
        hit_enemy_detected_done = true;
        last_hit_enemy = owner.hit_player_obj;
        print(last_hit_enemy);
    }
}
else if (hit_enemy_detected_done) {
    hit_enemy_detected_done = false;
    print("clean");
}

// TRACK LAST HIT ENEMIES POS
if (last_hit_enemy > 0 && last_hit_enemy.state != PS_RESPAWN) {
    respawn_x = last_hit_enemy.x;
    respawn_y = last_hit_enemy.y;
}

// LAST HIT ENEMY DIES
if (last_hit_enemy > 0 && last_hit_enemy.state == PS_RESPAWN) {
    if (!dead_enemy_detected_done) {
        dead_enemy_detected_done = true;
        
        // On kill
        for (i=0; i<base_amogus; i++) {
            var spawn_side = respawn_x < stage_center_x ? -1 : 1;
            momentum_to_point(respawn_x, stage_center_x + get_stage_data(SD_WIDTH)/2 * spawn_side);
            momentum_to_point(respawn_y, stage_center_y);
            new_random_amogus(i, respawn_x+rand(i, -50, 50, false), respawn_y, rand(i, -1.0, 1.0, false), rand(i, -15.0, -20.0, false), base_hp+1, true);
        }

    }
}
else if (dead_enemy_detected_done) {
    dead_enemy_detected_done = false;
}

// #region vvv LIBRARY DEFINES AND MACROS vvv
// DANGER File below this point will be overwritten! Generated defines and macros below.
// Write NO-INJECT in a comment above this area to disable injection.
#define new_random_amogus // Version 0
    if (amogus_count() >= max_amogus) {
        return;
    }

    // Init amogus
    var new_amogus = {  x: argument[1], y: argument[2], momentum_x: argument[3], momentum_y: argument[4], next_to_owner: false, // Position
                        state: "idle", cur_anim_frame: 0, frame_timer: 0, mainCol: c_white, secondCol: c_white, hat:"post_it", // Visual
                        dir: 1, walk_speed: 0.0, acceleration: 0.0, x_stop_dist: 0, walk_timer: 0, is_walking: false, // Walking
                        on_ground: true, fall_time: 0, land_timer: 0, is_jumping: false, no_jump_timer: 0, //Air
                        hp: argument[5], tumble: argument[6], heavy_land: true, hit_recently_timer: 0, hitpause_timer: 0, dead: false, dead_x:0, // Hit
                        focused: true, focused_timer:0, unfocused_timer:0, reaction_time: 0, wait_timer: 0 }; // Other

    // VISUAL
    // Set colors
    var color = amogus_colors[random_func(argument[0], array_length(amogus_colors), true)];
    new_amogus.mainCol = color.mainCol;
    new_amogus.secondCol = color.secondCol;

    // Set hat
    var hat = hat_names[random_func(argument[0], array_length(hat_names), true)];
    new_amogus.hat = hat;

    // GAMEPLAY
    randomize_walk_values(new_amogus);
    new_amogus.no_jump_timer = rand(argument[0], min_nojump_time, max_nojump_time, true);

    // Put in array
    add_to_array(new_amogus);

#define add_to_array // Version 0
    for (var army_item_i=0; army_item_i<array_length(army); army_item_i++) {
        var army_item = army[army_item_i];

        if (army_item == noone) {
            army[army_item_i] = argument[0];
            return;
        }
    }

    array_push(army, argument[0]);

#define amogus_count // Version 0
    var count = 0;

    for (var army_item_i=0; army_item_i<array_length(army); army_item_i++) {
        var army_item = army[army_item_i];

        if (army_item != noone) {
            count++;
        }
    }

    return count;

#define randomize_walk_values // Version 0
    // Walk speed
    argument[0].walk_speed = rand(2, min_walk_speed, max_walk_speed, false) / divider;

    // Walk stop
    argument[0].x_stop_dist = rand(3, x_min_stop_dist, x_max_stop_dist, true)

    // Acceleration
    argument[0].acceleration = rand(4, min_acceleration, max_acceleration, false) / divider;

    // Reaction time
    argument[0].reaction_time = rand(5, min_reaction_time, max_reaction_time, true);

#define rand // Version 0
    return argument[1] + random_func(argument[0], argument[2] - argument[1], argument[3]);

#define try_to_lose_focus // Version 0
    if (pct(0, chance_to_lose_focus)) {
        randomize_unfocused_walk_values(argument[0]);

        argument[0].unfocused_timer = rand(0, min_unfocused_time, max_unfocused_time, true);
        argument[0].walk_timer = rand(0, min_unfocused_walk_time, max_unfocused_walk_time, true);
        argument[0].wait_timer = argument[0].reaction_time;

        argument[0].focused = false;
    }

#define randomize_unfocused_walk_values // Version 0
    randomize_walk_values(argument[0]);
    argument[0].walk_speed -= 1.5;
    argument[0].reaction_time *= 1.5;

#define pct // Version 0
    return random_func(argument[0], 1.00, false) <= argument[1];

#define collision_at_point // Version 0
    if (collision_point(argument[0], argument[1], asset_get("par_block"), false, true) ||
    collision_point(argument[0], argument[1], asset_get("par_jumpthrough"), false, true)) {
        return true;
    }
    else {
        return false;
    }

#define upper_ground_y // Version 0
    var amogus = argument[0];

    for (i=0; i <= 999999; i++) {
        if (!collision_at_point(amogus.x, round(amogus.y)-i)) {
            return amogus.y-i+1;
        }
    }

    return amogus.y;

#define dir_to_owner // Version 0
    if (owner.x > argument[0].x) {
        return 1;
    }
    else {
        return -1;
    }

#define randomize_dir // Version 0
    argument[0].dir = pct(0, 0.5) ? 1 : -1;

#define dir_from_momentum // Version 0
    if (argument[0].momentum_x > 0) {
        return 1;
    }
    else {
        return -1;
    }

#define should_walk // Version 0
    var bool = false;

    if (argument[0].on_ground && argument[0].land_timer <= 0 && argument[0].wait_timer <= 0 && !argument[0].dead) {

        if ((argument[0].x <= get_stage_data(SD_X_POS) + argument[0].x_stop_dist && argument[0].dir == -1) || (argument[0].x >= get_stage_data(SD_X_POS) + get_stage_data(SD_WIDTH) - argument[0].x_stop_dist && argument[0].dir == 1)) {
            bool = false;
        }
        else {
            bool = true;
        }
    }

    return bool;

#define walk // Version 0
    argument[0].momentum_x += argument[0].acceleration * argument[0].dir;

    if (abs(argument[0].momentum_x) > argument[0].walk_speed) {
        argument[0].momentum_x = argument[0].walk_speed * argument[0].dir;
    }

#define jump // Version 0
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

#define deal_damage // Version 0
    if (argument[0].hit_recently_timer <= 0) {
        argument[0].hp--;
        if (argument[0].hp <= 0) {
            argument[0].tumble = true;
            argument[0].dead = true;
            argument[0].dead_x = argument[0].x;
        }

        if (argument[0].dead) {
            argument[0].momentum_x = rand(0, -2.5, 2.5, false);
            argument[0].momentum_y = -rand(1, 2.0, 5.0, false);
        }
    }

    argument[0].hit_recently_timer = hit_resistance_time;

#define momentum_to_point // Version 0
    var dist = argument[0] - argument[1];
    print(dist);

#define get_state_properties // Version 0
    for (var state_property_i=0; state_property_i<array_length(state_properties); state_property_i++) {
        var state_property = state_properties[state_property_i];

        if (state_property.state == argument[0]) {
            return state_property;
        }
    }

#define set_state // Version 0
    if (argument[0].state != argument[1]) {
        argument[0].state = argument[1];
    }
// DANGER: Write your code ABOVE the LIBRARY DEFINES AND MACROS header or it will be overwritten!
// #endregion