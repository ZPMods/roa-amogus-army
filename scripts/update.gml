// INIT
if (!init_done) {
    init_done = true;

    init_enums();
    
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
    var anim_speed = amogus.state_properties.speed;
    var frame_timer_max = 60 / anim_speed;

    // Pause anims during hitpause
    if (amogus.hitpause_timer <= 0) {
        amogus.frame_timer ++;
    }

    if (amogus.frame_timer >= frame_timer_max) {
        amogus.cur_anim_frame++;
        
        if (amogus.cur_anim_frame >= amogus.state_properties.frameCount) {
            if (amogus.stop_forced_on_end && amogus.forced_timer > 0) {
                amogus.forced_timer = 0;

                if (amogus.is_taunting) {
                    amogus.is_taunting = false;

                    // Special taunt interactions
                    switch (amogus.state) {
                        case states.tauntVentIn :
                            force_state(amogus, states.tauntVentOut, 0);
                            
                            vent(army_item_i, amogus);

                            amogus.is_taunting = true;
                        break;

                        case states.tauntShapeshift :
                            force_state(amogus, states.tauntShapeshiftEnd, 0);

                            random_color(army_item_i, amogus);
                            random_hat(army_item_i, amogus);

                            amogus.is_taunting = true;
                        break;
                    }
                }
            }
            else {
                amogus.cur_anim_frame = 0;
            }
        }

        amogus.frame_timer = 0;
    }

    // IA STUFF -----------
    // HITPAUSE
    if (amogus.hitpause_timer > 0) {
        amogus.hitpause_timer --;
        set_state(amogus, states.hurt);
        continue;
    }

    // Friction
    amogus.momentum_x *= amogus.on_ground ? ground_friction : amogus.tumble ? 1 : air_friction;

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

                if (pct(army_item_i, chance_to_sit) && !amogus.is_taunting) {
                    if (!amogus.sitting) {
                        force_state(amogus, states.idleToSit, 0);
                    }
                    amogus.sitting = true;
                }
                else {
                    amogus.sitting = false;
                }

                amogus.wait_timer = rand(army_item_i, min_unfocused_wait_time, max_unfocused_wait_time, true);
                amogus.wait_timer *= amogus.sitting ? 10 : 1;
                amogus.unfocused_timer += amogus.wait_timer;
            }
        }

        if (amogus.wait_timer <= 0 && amogus.walk_timer <= 0 && amogus.land_timer <= 0 && amogus.jumpsquat_timer <= 0 && amogus.on_ground && !amogus.is_taunting) {
            randomize_dir(amogus);
            amogus.walk_timer = rand(army_item_i, min_unfocused_walk_time, max_unfocused_walk_time, true);
        }
    } 
    //FOCUSED
    else { 
        // On focus change
        if (!amogus.focused) {
            amogus.focused = true;
            amogus.sitting = false;
            randomize_walk_values(amogus);
        }

        // Look at player
        if (amogus.dir != dir_to_owner(amogus) && amogus.on_ground && amogus.land_timer <= 0 && amogus.jumpsquat_timer <= 0 && !amogus.is_taunting) {
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
                landlag_mult = 1;

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
            if (pct(army_item_i, chance_to_jump)) {
                amogus.jumpsquat_timer = jumpsquat_time;
                force_state(amogus, states.jumpsquat, jumpsquat_time);
                amogus.no_jump_timer = rand(army_item_i, min_nojump_time, max_nojump_time, true);
            }
            else {
                amogus.no_jump_timer = rand(army_item_i, min_nojump_time, max_nojump_time, true);
                amogus.no_jump_timer /= 3;
            }
            
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
        if (amogus.momentum_y > 0 || amogus.tumble) {
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

    // OTHER AMOGUSES
    if (amogus.momentum_x <= stopped_threshold && amogus.on_ground && !amogus.is_walking) {
        for (var other_army_item_i=0; other_army_item_i<array_length(army); other_army_item_i++) {
            var other_amogus = army[other_army_item_i];

            if (army_item_i == other_army_item_i || !other_amogus.on_ground || abs(other_amogus.y - amogus.y) > 2 || other_amogus.momentum_x > stopped_threshold || other_amogus.is_walking) {
                continue;
            }
            
            var dist = other_amogus.x - amogus.x;

            if (abs(dist) <= push_dist_threshold) {
                var dir = -sign(dist);
                if (dir == 0) dir = 1;
                
                amogus.momentum_x = push_force * dir;
            }
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

            amogus.momentum_x *= 0.75;
        }
    }

    // APPLY
    // Apply values
    amogus.x += amogus.momentum_x;
    amogus.y += amogus.momentum_y;

    // Anim states
    if (amogus.forced_timer <= 0) {
        if (amogus.on_ground) {
            if (should_walk(amogus) && amogus.is_walking && abs(amogus.momentum_x) > 0.2) {
                set_state(amogus, states.run);
            }
            else {
                // Land
                if (amogus.land_timer > 0) {
                    // Heavy land
                    if (amogus.heavy_land) {
                        set_state(amogus, states.heavyland);
                    }
                    else {
                        set_state(amogus, states.land);
                    }
                } else {
                    if (amogus.sitting) {
                        set_state(amogus, states.sit);
                    }
                    else {
                        set_state(amogus, states.idle);
                    }
                }
            }
        }
        else {
            // Tumble
            if (amogus.dead == true) {
                set_state(amogus, states.dead);
            }
            else if (amogus.tumble == true) {
                set_state(amogus, states.tumble);
            }
            else {
                if (amogus.momentum_y > 0) {
                    set_state(amogus, states.fall);
                }
                else {
                    set_state(amogus, states.rise);
                }
            }
        }
    }

    // Timers
    if (!amogus.dead) {
        if (amogus.land_timer > 0) {
            amogus.land_timer--;
        }

        if (amogus.jumpsquat_timer > 0) {
            amogus.jumpsquat_timer--;
        }
        else if (amogus.jumpsquat_timer > -1) {
            jump(amogus);
            amogus.jumpsquat_timer = -1;
        }

        if (amogus.wait_timer > 0) {
            amogus.wait_timer--;
        }
        
        if (amogus.focused_timer > 0) {
            amogus.unfocused_timer--;
        } 

        if (amogus.unfocused_timer > 0) {
            amogus.unfocused_timer--;
        } 

        if (amogus.walk_timer > 0) {
            amogus.walk_timer--;
        } 

        if (amogus.hit_recently_timer > 0) {
            amogus.hit_recently_timer--;
        } 
        
        if (amogus.forced_timer > 0) {
            amogus.forced_timer--;
        }

        if (amogus.no_jump_timer > 0 && !amogus.is_jumping && amogus.land_timer <= 0 && !amogus.next_to_owner && amogus.focused && amogus.y - owner.y > y_jump_dist && !amogus.is_taunting) {
            amogus.no_jump_timer--;
        } 

        if (amogus.taunt_timer > 0) {
            amogus.taunt_timer--;
        }
        else if (amogus.taunt_timer > -1) {
            taunt(army_item_i, amogus);
            amogus.taunt_timer = -1;
        }
    }

    // TAUNT
    if (state == "taunt") {
        if (!amogus.taunt_detected_done) {
            amogus.taunt_detected_done = true;

            if (!amogus.sitting && amogus.on_ground && amogus.land_timer <= 0 && amogus.jumpsquat_timer < 0 && !amogus.is_taunting) {
                if (pct(army_item_i, amogus.focused_timer > 0 ? focused_chance_to_taunt : unfocused_chance_to_taunt)) {
                    amogus.taunt_timer = rand(army_item_i, min_taunt_wait_time, max_taunt_wait_time, true);
                    amogus.wait_timer += amogus.taunt_timer;
                }
            }
        }
    }
    else if (amogus.taunt_detected_done) {
        amogus.taunt_detected_done = false;
    }
}

// GHOSTS
for (var ghost_i=0; ghost_i<array_length(ghosts); ghost_i++) {
    var ghost = ghosts[ghost_i];

    // ANIM STUFF -----------
    // Take care of everything about frame timer in update
    // So that it stops when in pause
    var anim_speed = get_state_properties(states.ghost).speed;
    var frame_timer_max = 60 / anim_speed;

    ghost.frame_timer ++;

    if (ghost.frame_timer >= frame_timer_max) {
        ghost.cur_anim_frame++;
        
        if (ghost.cur_anim_frame >= get_state_properties(states.ghost).frameCount) {
            ghost.cur_anim_frame = 0;
        }

        ghost.frame_timer = 0;
    }

    ghost.y -= ghost.speed;
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
    }
}
else if (hit_enemy_detected_done) {
    hit_enemy_detected_done = false;
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
        
        var spawn_side = respawn_x < stage_center_x ? -1 : 1;
        var above_stage = false;

        if (respawn_x > stage_center_x - get_stage_data(SD_WIDTH)/2 && respawn_x < stage_center_x + get_stage_data(SD_WIDTH)/2) {
            above_stage = true;
        }

        var target_x = stage_center_x + get_stage_data(SD_WIDTH)/2 * spawn_side;
        if (above_stage) {
            target_x = respawn_x;
        }

        var target_y = stage_center_y;
        if (respawn_y < stage_center_y) {
            target_y = respawn_y;

            if (!above_stage) {
                target_x = stage_center_x;
            }
        }

        // On kill
        for (i=0; i<amogus_on_kill; i++) {
            var momentum_x = momentum_to_point(i, respawn_x, target_x) * 0.5;
            var momentum_y = momentum_to_point(i+10, respawn_y, target_y);
            new_random_amogus(i, respawn_x+rand(i, -30, 30, false), respawn_y, momentum_x, momentum_y, base_hp+1, true);
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
                        state: states.idle, state_properties:get_state_properties(states.idle), cur_anim_frame: 0, frame_timer: 0, // Animation
                        mainCol: c_white, secondCol: c_white, hat:hats.post_it, hat_properties:get_hat_properties(hats.post_it), forced_timer: 0, stop_forced_on_end: false, // Visual
                        dir: 1, walk_speed: 0.0, acceleration: 0.0, x_stop_dist: 0, walk_timer: 0, is_walking: false, // Walking
                        on_ground: true, fall_time: 0, land_timer: 0, is_jumping: false, no_jump_timer: 0, jumpsquat_timer: -1, //Air
                        hp: argument[5], tumble: argument[6], heavy_land: true, hit_recently_timer: 0, hitpause_timer: 0, dead: false, dead_x:0, // Hit
                        focused: true, focused_timer:0, unfocused_timer:0, reaction_time: 0, wait_timer: 20 * argument[0], sitting: false, // Other
                        role: roles.impostor, possible_taunts: get_role_properties(roles.impostor).possibleTaunts, taunt_detected_done: false, is_taunting: false, taunt_timer:-1 }; // Taunt

    // VISUAL
    // Set colors
    random_color(argument[0], new_amogus);

    // Set hat
    random_hat(argument[0], new_amogus);

    // Set role
    random_role(argument[0], new_amogus);

    // GAMEPLAY
    randomize_walk_values(new_amogus);
    new_amogus.no_jump_timer = rand(argument[0], min_nojump_time, max_nojump_time, true);

    // Put in array
    add_to_army_array(new_amogus, army);

#define random_color // Version 0
    var amogus = argument[1];

    var color = colors_properties[random_func(argument[0], array_length(colors_properties), true)];
    amogus.mainCol = color.mainCol;
    amogus.secondCol = color.secondCol;

#define random_hat // Version 0
    var amogus = argument[1];

    var hat_properties = hats_properties[random_func(argument[0], array_length(hats_properties), true)];
    amogus.hat = hat_properties.hat;
    amogus.hat_properties = hat_properties;

#define random_role // Version 0
    var amogus = argument[1];

    var role_properties = roles_properties[random_func(argument[0], array_length(roles_properties), true)];
    amogus.role = role_properties.role;
    amogus.possible_taunts = role_properties.possibleTaunts;

#define add_to_army_array // Version 0
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

#define get_state_properties // Version 0
    for (var state_property_i=0; state_property_i<array_length(states_properties); state_property_i++) {
        var state_property = states_properties[state_property_i];

        if (state_property.state == argument[0]) {
            return state_property;
        }
    }

#define get_hat_properties // Version 0
    for (var hat_property_i=0; hat_property_i<array_length(hats_properties); hat_property_i++) {
        var hat_property = hats_properties[hat_property_i];

        if (hat_property.hat == argument[0]) {
            return hat_property;
        }
    }

#define get_role_properties // Version 0
    for (var role_property_i=0; role_property_i<array_length(roles_properties); role_property_i++) {
        var role_property = roles_properties[role_property_i];

        if (role_property.role == argument[0]) {
            return role_property;
        }
    }

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

#define set_state // Version 0
    if (argument[0].state != argument[1]) {
        argument[0].cur_anim_frame = 0;
        argument[0].frame_timer = 0;
        argument[0].state = argument[1];
        argument[0].state_properties = get_state_properties(argument[1]);
    }

#define force_state // Version 0
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

    for (i=0; i <= 999; i++) {
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

    if (argument[0].on_ground && argument[0].land_timer <= 0 && argument[0].jumpsquat_timer <= 0 && argument[0].wait_timer <= 0 && !argument[0].dead && !argument[0].tumble && !argument[0].is_taunting) {

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
            new_ghost(argument[0].x, argument[0].y, argument[0].dir, argument[0].mainCol, argument[0].secondCol);
        }

        if (argument[0].dead) {
            argument[0].momentum_x = rand(0, -2.5, 2.5, false);
            argument[0].momentum_y = -rand(1, 2.0, 5.0, false);
        }
    }

    argument[0].hit_recently_timer = hit_resistance_time;

#define new_ghost // Version 0
    var new_ghost = {  x: argument[0], y: argument[1], dir: argument[2], mainCol: argument[3], secondCol: argument[4], speed: 2.5, opacity: 0.5, cur_anim_frame: 0, frame_timer: 0 };

    // Put in array
    add_to_ghost_array(new_ghost, ghosts);

#define add_to_ghost_array // Version 0
    for (var ghost_i=0; ghost_i<array_length(ghosts); ghost_i++) {
        var ghost = ghosts[ghost_i];

        if (ghost == noone) {
            ghosts[ghost_i] = argument[0];
            return;
        }
    }

    array_push(ghosts, argument[0]);

#define taunt // Version 0
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

#define vent // Version 0
    var amogus = argument[1];

    amogus.y -= 200;
    amogus.x = random_point_above_stage(argument[0]);

    amogus.y = lower_ground_y(amogus);

#define lower_ground_y // Version 0
    var amogus = argument[0];

    for (i=0; i <= 999; i++) {
        if (collision_at_point(amogus.x, round(amogus.y)+i)) {
            return amogus.y+i;
        }
    }

    return amogus.y;

#define random_point_above_stage // Version 0
    var x_offset = random_func(argument[0], get_stage_data(SD_WIDTH), true) - get_stage_data(SD_WIDTH)/2;
    return stage_center_x + x_offset;

#define momentum_to_point // Version 0
    var dist = argument[1] - argument[2];
    var momentum = dist/30 + rand(i, -1.0, 1.0, false);
    return -momentum;

#define init_enums // Version 0
    // Roles
    enum roles
    {
        crewmate,
        impostor,
        shapeshifter,
        engineer,
        doctor,
        guardian_angel
    }

    // States
    enum states
    {
        idle,
        idleToSit,
        sit,
        run,
        rise,
        fall,
        land,
        jumpsquat,
        tumble,
        heavyland,
        hurt,
        dead,
        ghost,
        tauntPenguinDance,
        tauntScan,
        tauntTongue,
        tauntShapeshift,
        tauntShapeshiftEnd,
        tauntVentIn,
        tauntVentOut,
        tauntDoctor
    }

    // Hats
    enum hats
    {
        none,
        post_it,
        bear_ears,
        young_sprout,
        knight_horns,
        headslug,
        imp,
        frog_hat,
        bakugo_mask,
        tree,
        jinx_hair,
        egg,
        heart
    }

    // Colors
    enum colors
    {
        red,
        blue,
        green,
        pink,
        orange,
        yellow,
        black,
        white,
        purple,
        brown,
        cyan,
        lime
    }
// DANGER: Write your code ABOVE the LIBRARY DEFINES AND MACROS header or it will be overwritten!
// #endregion