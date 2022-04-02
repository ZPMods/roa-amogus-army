// INIT
if (!init_done) {
    init_done = true;

    init_enums();
    
    for (i=0; i<base_amogus; i++) {
        amogus_new(owner.x+rand_int(i, -50, 50), owner.y, 0.0, 0.0, base_hp, false);
    }
}

// UPDATE
// Army behavior
for (var army_item_i=0; army_item_i<array_length(army); army_item_i++) {
    var amogus = army[army_item_i];

    if (amogus == noone) {
        continue;
    }

    amogus_update(amogus);
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
                if (amogus.is_on_ground && force_y > 0) {
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
if (owner.hit_player_obj > 0 && owner.hit_player_obj != noone && owner.hit_player_obj.hitpause && owner.hit_player_obj.state_cat == SC_HITSTUN) {
    if (!hit_enemy_detected_done && last_hit_enemy != owner.hit_player_obj) {
        // On hit enemy
        hit_enemy_detected_done = true
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
        
        if (army_count() < max_amogus) {
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
                if (army_count() >= max_amogus) {
                    continue;
                } 

                var momentum_x = momentum_to_point(i, respawn_x, target_x) * 0.5;
                var momentum_y = momentum_to_point(i+10, respawn_y, target_y);

                new_amogus = amogus_new(respawn_x+rand(i, -30, 30, false), respawn_y);
                new_amogus.momentum_x = momentum_x;
                new_amogus.momentum_y = momentum_y;
                new_amogus.hp = base_hp+1;
                new_amogus.tumble = true;
            }
        }
    }
}
else if (dead_enemy_detected_done) {
    dead_enemy_detected_done = false;
}

// #region vvv LIBRARY DEFINES AND MACROS vvv
// DANGER File below this point will be overwritten! Generated defines and macros below.
// Write NO-INJECT in a comment above this area to disable injection.
#define amogus_new // Version 0
    var this = amogus_entity_variables();

    var i = array_add(army, this);
    this.index = i;

    var posX = argument[0]; // Int
    var posY = argument[1]; // Int

    this.x = posX;
    this.y = posY;

    // VISUAL RANDOM
    amogus_randomize_color(this);
    amogus_randomize_hat(this);
    amogus_randomize_role(this);

    // GAMEPLAY RANDOM
    amogus_randomize_gameplay_values(this);
    return this;

#define amogus_entity_variables // Version 0
    var a = {
        // Meta
        index : 0,

        // Position
        x               : 0,
        y               : 0,

        momentum_x      : 0.,
        momentum_y      : 0.,

        dir             : 1,

        next_to_owner   : false,

        // Visual
        mainCol         : make_colour_rgb(197, 17, 17), // Red
        secondCol       : make_colour_rgb(122, 8, 56),  // Red

        hat             : hats.none,
        hat_properties  : get_hat_properties(hats.none),

        // Animation
        state                       : states.idle,
        state_properties            : get_state_properties(states.idle),

        cur_anim_frame              : 0,
        frame_timer                 : 0,

        forced_state_timer          : 0,
        stop_forced_state_on_end    : false,

        // Walking
        walk_speed      : 27.5,
        acceleration    : 2.5,
        x_stop_dist     : 60,

        walk_timer      : 0,
        is_walking      : false,

        // Air
        is_on_ground    : true,
        is_jumping      : false,

        fall_time       : 0,
        no_jump_timer   : 0,

        land_timer      : 0,
        jumpsquat_timer : -1,


        // Hit
        hp                  : base_hp,

        tumble              : false,
        heavy_land          : true,

        hit_recently_timer  : 0,
        hitpause_timer      : 0,

        dead                : false,
        dead_x              : 0,

        // Waiting
        focused         : true,
        reaction_time   : 0,
        sitting         : false,

        focused_timer   : 0,
        unfocused_timer : 0,
        wait_timer      : 0,

        // Taunt
        role                : roles.crewmate,
        possible_taunts     : get_role_properties(roles.crewmate).possibleTaunts,
        taunt_detected_done : false,
        is_taunting         : false,
        taunt_timer         : -1
    };

    return a;

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

#define amogus_randomize_color // Version 0
    var this = argument[0];

    var color = rand_in_array(this.index, colors_properties);
    this.mainCol = color.mainCol;
    this.secondCol = color.secondCol;

#define rand_in_array // Version 0
    var index   = argument[0]; // Int
    var array   = argument[1]; // Array

    return array[random_func(argument[0], array_length(array), true)];

#define amogus_randomize_hat // Version 0
    var this = argument[0];

    var hat_properties = rand_in_array(this.index, hats_properties);
    this.hat = hat_properties.hat;
    this.hat_properties = hat_properties;

#define amogus_randomize_role // Version 0
    var this = argument[0];

    var role_properties = rand_in_array(this.index, roles_properties);
    this.role = role_properties.role;
    this.possible_taunts = role_properties.possibleTaunts;

#define amogus_randomize_gameplay_values // Version 0
    var this = argument[0];

    this.walk_speed    = rand_float(this.index, min_walk_speed, max_walk_speed) / divider;
    this.x_stop_dist   = rand_int(this.index, min_x_stop_dist, max_x_stop_dist);
    this.acceleration  = rand_float(this.index, min_acceleration, max_acceleration) / divider;
    this.reaction_time = rand_int(this.index, min_reaction_time, max_reaction_time);
    this.no_jump_timer = rand_int(this.index, min_nojump_time, max_nojump_time);

#define rand_int // Version 0
    return rand(argument[0], argument[1], argument[2], true);

#define rand // Version 0
    // Returns a random value between low_value and high_value
    var index      = argument[0]; // Int
    var low_value  = argument[1]; // Float
    var high_value = argument[2]; // Float
    var floored    = argument[3]; // Bool

    return low_value + random_func(index, high_value - low_value, floored);

#define rand_float // Version 0
    return rand(argument[0], argument[1], argument[2], false);

#define array_add // Version 0
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

#define amogus_update // Version 0
    var this = argument[0];

    amogus_anim_update(this);

    // IA STUFF -----------
    // HITPAUSE
    if (this.hitpause_timer > 0) {
        this.hitpause_timer --;
        amogus_set_state(this, states.hurt);
        return;
    }

    // Friction
    this.momentum_x *= this.is_on_ground ? ground_friction : this.tumble ? 1 : air_friction;

    // Try to lose focus
    if (this.focused_timer <= 0 && this.focused) {
        amogus_try_to_lose_focus(this);
    }

    // UNFOCUSED
    if (!amogus_is_focused(this)) {
        amogus_unfocused_update(this);
    }
    //FOCUSED
    else {
        amogus_focused_update(this);
    }

    // COLLISION CHECKS
    // Ground
    if (collision_at_point(this.x, this.y+1) && this.momentum_y >= 0) {
        if (!this.is_on_ground && !this.dead) {
            // On land
            var landlag_mult = 1;
            if (this.tumble == true) {
                this.tumble = false;
                this.heavy_land = true;
                landlag_mult = 1;

                // Deal damage
                amogus_take_damage(this);
            }

            this.land_timer = max(this.land_timer, this.fall_time * landlag_mult);

            this.fall_time = 0;

            this.is_on_ground = true;

            if (this.is_jumping) {
                this.is_jumping = false;
            }
        }

        if (collision_at_point(this.x, this.y) && !this.dead) {
            this.y = amogus_closest_ground_above(this);
        }

        // Jump
        if (this.no_jump_timer <= 0 && this.focused) {
            if (pct(this.index, chance_to_jump)) {
                this.jumpsquat_timer = jumpsquat_time;
                amogus_force_state(this, states.jumpsquat, jumpsquat_time);
                this.no_jump_timer = rand_int(this.index, min_nojump_time, max_nojump_time);
            }
            else {
                this.no_jump_timer = rand_int(this.index, min_nojump_time, max_nojump_time);
                this.no_jump_timer /= 3;
            }

        }
    }
    // Air start
    else {
        if (this.is_on_ground) {
            this.is_on_ground = false;

            if (this.heavy_land == true) {
                this.heavy_land = false;
            }
        }
    }

    // In air
    if (!this.is_on_ground) {
        if (this.momentum_y > 0 || this.tumble) {
            this.fall_time++;
        }

        this.momentum_y += gravity;

        if (this.momentum_y > fall_speed && !this.tumble) {
            this.momentum_y = fall_speed;
        }
    }
    else if (this.momentum_y > 0) {
        this.momentum_y = 0;
    }

    // Walls
    if (abs(this.momentum_x) > 0 && collision_point(this.x + 16 * amogus_dir_from_momentum(this), this.y - 20, asset_get("par_block"), false, true) && !this.dead) {
        if (this.tumble) {
            this.momentum_x *= -1;
        }
        else {
            this.momentum_x = 0;
        }
    }

    // OTHER AMOGUSES
    if (this.momentum_x <= stopped_threshold && this.is_on_ground && !this.is_walking) {
        for (var other_army_item_i=0; other_army_item_i<array_length(army); other_army_item_i++) {
            var other_amogus = army[other_army_item_i];

            if (other_amogus == noone || other_amogus == -4 || this.index == other_amogus.index || !other_amogus.is_on_ground || abs(other_amogus.y - this.y) > 2 || other_amogus.momentum_x > stopped_threshold || other_amogus.is_walking) {
                continue;
            }

            var dist = other_amogus.x - this.x;

            if (abs(dist) <= push_dist_threshold) {
                var dir = -sign(dist);
                if (dir == 0) dir = 1;

                this.momentum_x = push_force * dir;
            }
        }
    }

    // GAME INTERACTIONS
    // Respawn on bottom blastzone
    if (this.y >= get_stage_data(SD_Y_POS) + get_stage_data(SD_BOTTOM_BLASTZONE) && this.momentum_y > 0) {
        if (this.dead) {
            army[this.index] = noone;
            return;
        }
        else {
            this.x = room_width / 2 + rand_int(this.index, -150, 150);
            this.y = 0;
            this.tumble = true;

            this.momentum_x *= 0.75;
        }
    }

    // APPLY
    // Apply values
    this.x += this.momentum_x;
    this.y += this.momentum_y;

    // Anim states
    if (this.forced_state_timer <= 0) {
        if (this.is_on_ground) {
            if (amogus_can_walk(this) && this.is_walking && abs(this.momentum_x) > 0.2) {
                amogus_set_state(this, states.run);
            }
            else {
                // Land
                if (this.land_timer > 0) {
                    // Heavy land
                    if (this.heavy_land) {
                        amogus_set_state(this, states.heavyland);
                    }
                    else {
                        amogus_set_state(this, states.land);
                    }
                } else {
                    if (this.sitting) {
                        amogus_set_state(this, states.sit);
                    }
                    else {
                        amogus_set_state(this, states.idle);
                    }
                }
            }
        }
        else {
            // Tumble
            if (this.dead == true) {
                amogus_set_state(this, states.dead);
            }
            else if (this.tumble == true) {
                amogus_set_state(this, states.tumble);
            }
            else {
                if (this.momentum_y > 0) {
                    amogus_set_state(this, states.fall);
                }
                else {
                    amogus_set_state(this, states.rise);
                }
            }
        }
    }

    // Timers
    if (!this.dead) {
        if (this.land_timer > 0) {
            this.land_timer--;
        }

        if (this.jumpsquat_timer > 0) {
            this.jumpsquat_timer--;
        }
        else if (this.jumpsquat_timer > -1) {
            amogus_jump(this);
            this.jumpsquat_timer = -1;
        }

        if (this.wait_timer > 0) {
            this.wait_timer--;
        }

        if (this.focused_timer > 0) {
            this.unfocused_timer--;
        }

        if (this.unfocused_timer > 0) {
            this.unfocused_timer--;
        }

        if (this.walk_timer > 0) {
            this.walk_timer--;
        }

        if (this.hit_recently_timer > 0) {
            this.hit_recently_timer--;
        }

        if (this.forced_state_timer > 0) {
            this.forced_state_timer--;
        }

        if (this.no_jump_timer > 0 && !this.is_jumping && this.land_timer <= 0 && !this.next_to_owner && this.focused && this.y - owner.y > y_jump_dist && !this.is_taunting) {
            this.no_jump_timer--;
        }

        if (this.taunt_timer > 0) {
            this.taunt_timer--;
        }
        else if (this.taunt_timer > -1) {
            amogus_taunt(this);
            this.taunt_timer = -1;
        }
    }

    // TAUNT
    if (state == "taunt") {
        if (!this.taunt_detected_done) {
            this.taunt_detected_done = true;

            if (!this.sitting && this.is_on_ground && this.land_timer <= 0 && this.jumpsquat_timer < 0 && !this.is_taunting) {
                if (pct(this.index, this.focused_timer > 0 ? focused_chance_to_taunt : unfocused_chance_to_taunt)) {
                    this.taunt_timer = rand_int(this.index, min_taunt_wait_time, max_taunt_wait_time);
                    this.wait_timer += this.taunt_timer;
                }
            }
        }
    }
    else if (this.taunt_detected_done) {
        this.taunt_detected_done = false;
    }

#define amogus_anim_update // Version 0
    this = argument[0];

    // Take care of everything about frame timer in update
    // So that it stops when in pause
    var anim_speed = this.state_properties.speed;
    var frame_timer_max = 60 / anim_speed;

    // Pause anims during hitpause
    if (this.hitpause_timer <= 0) {
        this.frame_timer ++;
    }

    if (this.frame_timer >= frame_timer_max) {
        this.cur_anim_frame++;

        if (this.cur_anim_frame >= this.state_properties.frameCount) {
            if (this.stop_forced_state_on_end && this.forced_state_timer > 0) {
                this.forced_state_timer = 0;

                if (this.is_taunting) {
                    this.is_taunting = false;

                    // Special taunt interactions
                    switch (this.state) {
                        case states.tauntVentIn :
                            amogus_force_state(this, states.tauntVentOut, 0);

                            amogus_vent(this);

                            this.is_taunting = true;
                        break;

                        case states.tauntShapeshift :
                            amogus_force_state(this, states.tauntShapeshiftEnd, 0);

                            amogus_randomize_color(this);
                            amogus_randomize_hat(this);

                            this.is_taunting = true;
                        break;
                    }
                }
            }
            else {
                this.cur_anim_frame = 0;
            }
        }

        this.frame_timer = 0;
    }

#define amogus_force_state // Version 0
    var this = argument[0];
    var state = argument[1];
    var time = argument[2];

    if (time <= 0) {
        this.forced_state_timer = 999;
        this.stop_forced_state_on_end = true;
    }
    else {
        this.forced_state_timer = time;
    }

    amogus_set_state(this, state);

#define amogus_set_state // Version 0
    var this = argument[0];

    if (this.state != argument[1]) {
        this.cur_anim_frame = 0;
        this.frame_timer = 0;
        this.state = argument[1];
        this.state_properties = get_state_properties(argument[1]);
    }

#define amogus_vent // Version 0
    var this = argument[0];

    this.y -= 200;
    this.x = random_point_above_stage(this.index);

    this.y = amogus_closest_ground_below(this);

#define amogus_closest_ground_below // Version 0
    var this = argument[0];

    for (i=0; i <= 999; i++) {
        if (collision_at_point(this.x, round(this.y)+i)) {
            return this.y+i;
        }
    }

    return this.y;

#define collision_at_point // Version 0
    if (collision_point(argument[0], argument[1], asset_get("par_block"), false, true) || collision_point(argument[0], argument[1], asset_get("par_jumpthrough"), false, true)) {
        return true;
    }

    return false;

#define random_point_above_stage // Version 0
    var x_offset = random_func(argument[0], get_stage_data(SD_WIDTH), true) - get_stage_data(SD_WIDTH)/2;
    return stage_center_x + x_offset;

#define amogus_dir_from_momentum // Version 0
    var this = argument[0];

    if (this.momentum_x > 0) {
        return 1;
    }

    return -1;

#define amogus_closest_ground_above // Version 0
    var this = argument[0];

    for (i=0; i <= 999; i++) {
        if (!collision_at_point(this.x, round(this.y)-i)) {
            return this.y-i+1;
        }
    }

    return this.y;

#define amogus_can_walk // Version 0
    var this = argument[0];

    if (this.is_on_ground && this.land_timer <= 0 && this.jumpsquat_timer <= 0 && this.wait_timer <= 0 && !this.dead && !this.tumble && !this.is_taunting) {

        if ((this.x <= get_stage_data(SD_X_POS) + this.x_stop_dist && this.dir == -1) || (this.x >= get_stage_data(SD_X_POS) + get_stage_data(SD_WIDTH) - this.x_stop_dist && this.dir == 1)) {
            return false;
        }

        return true;
    }

    return false;

#define amogus_jump // Version 0
    var this = argument[0];

    var lerp_val = (this.y - owner.y - 100)/100;
    lerp_val = clamp(lerp_val, 0, 1);

    var base_jump_force = lerp(min_jump_height, max_jump_height, lerp_val);
    var jump_force = base_jump_force + rand(0, -1.0, 1.0, false)

    lerp_val = abs(this.x - owner.x)/100;
    lerp_val = clamp(lerp_val, 0, 1);

    var jump_forward = lerp(0, rand(0, min_walk_speed, max_walk_speed, false) / divider, lerp_val);

    this.momentum_y = -jump_force;
    this.momentum_x = jump_forward * amogus_dir_to_owner(this);
    this.is_jumping = true;

#define amogus_dir_to_owner // Version 0
    var this = argument[0];

    if (owner.x > this.x) {
        return 1;
    }

    return -1;

#define amogus_focused_update // Version 0
    var this = argument[0];

    prints(this.index, "focused update");

    // Look at player
    if (this.dir != amogus_dir_to_owner(this) && amogus_can_turn_around(this)) {
        this.dir = amogus_dir_to_owner(this);
    }

    // Far from player
    if (abs(this.x - owner.x) > this.x_stop_dist) {
        prints(this.index, "far from player");
        // Walk towards player
        this.walk_timer = 999999;
        amogus_try_to_walk(this);
        return;
    }

    // Stopped at player
    amogus_stop(this);

    this.wait_timer += 2;
    if (this.wait_timer > this.reaction_time) {
        this.wait_timer = this.reaction_time;
    }

    // Right next to player (on x and y)
    this.next_to_owner = (abs(this.x - owner.x) < this.x_stop_dist) && (this.y - owner.y < y_jump_dist);

#define prints // Version 0
    // Prints each parameter to console, separated by spaces.
    var _out_string = string(argument[0])
    for (var i=1; i<argument_count; i++) {
        _out_string += " "
        _out_string += string(argument[i])
    }
    print(_out_string)

#define amogus_can_turn_around // Version 0
    var this = argument[0];

    return this.land_timer <= 0 && this.jumpsquat_timer <= 0 && this.is_on_ground && !this.is_taunting;

#define amogus_try_to_walk // Version 0
    var this = argument[0];

    if (this.walk_timer <= 0) {
        if (this.is_walking) {
            amogus_stop(this);
        }

        return;
    }

    if (amogus_can_walk(this)) {
        amogus_walk(this);
    }

#define amogus_walk // Version 0
    var this = argument[0];

    if (!this.is_walking) {
        this.is_walking = true;
    }

    this.momentum_x += this.acceleration * this.dir;

    if (abs(this.momentum_x) > this.walk_speed) {
        this.momentum_x = this.walk_speed * this.dir;
    }

#define amogus_stop // Version 0
    var this = argument[0];

    if (!this.is_walking) {
        return;
    }

    this.walk_timer = 0;
    this.is_walking = false;

    if (!amogus_is_focused(this)) {
        amogus_unfocused_on_stop(this);
        return;
    }

    amogus_focused_on_stop(this);

#define amogus_is_focused // Version 0
    var this = argument[0];

    return this.unfocused_timer <= 0 || this.focused == true;

#define amogus_focused_on_stop // Version 0
    var this = argument[0];

    amogus_try_to_lose_focus(this);

#define amogus_try_to_lose_focus // Version 0
    var this = argument[0];

    if (pct(0, chance_to_lose_focus)) {
        amogus_lose_focus(this);
        return;
    }

    amogus_gain_focus(this);

#define amogus_lose_focus // Version 0
    var this = argument[0];

    amogus_randomize_unfocused_walk_values(this);

    this.unfocused_timer = rand_int(0, min_unfocused_time, max_unfocused_time);
    this.walk_timer = rand_int(0, min_unfocused_walk_time, max_unfocused_walk_time);
    this.wait_timer = this.reaction_time;

    this.focused = false;

#define amogus_randomize_unfocused_walk_values // Version 0
    var this = argument[0];

    amogus_randomize_gameplay_values(this);
    this.walk_speed -= 1.5;
    this.reaction_time *= 1.5;

#define amogus_gain_focus // Version 0
    var this = argument[0];

    if (!this.focused) {
        this.focused = true;
        amogus_randomize_gameplay_values(this);
    }

    this.sitting = false;
    this.focused_timer = rand_int(this.index, min_focused_time, max_focused_time);

#define pct // Version 0
    // Rolls a % chance between 0 and 1
    var index   = argument[0]; // Int
    var chance  = argument[1]; // Float

    return random_func(argument[0], 1.00, false) <= argument[1];

#define amogus_unfocused_on_stop // Version 0
    var this = argument[0];

    if (pct(this.index, chance_to_sit) && !this.is_taunting) {
        if (!this.sitting) {
            amogus_force_state(this, states.idleToSit, 0);
        }
        this.sitting = true;
    }
    else {
        this.sitting = false;
    }

    this.wait_timer = rand_int(this.index, min_unfocused_wait_time, max_unfocused_wait_time);
    this.wait_timer *= this.sitting ? 10 : 1;
    this.unfocused_timer += this.wait_timer;

#define amogus_unfocused_update // Version 0
    var this = argument[0];

    amogus_try_to_walk(this);

    if (this.wait_timer <= 0 && this.walk_timer <= 0 && amogus_can_turn_around(this)) {
        amogus_randomize_dir(this);
        this.walk_timer = rand_int(this.index, min_unfocused_walk_time, max_unfocused_walk_time);
    }

#define amogus_randomize_dir // Version 0
    var this = argument[0];

    this.dir = pct(0, 0.5) ? 1 : -1;

#define amogus_take_damage // Version 0
    var this = argument[0];

    if (this.hit_recently_timer <= 0) {
        this.hp--;
        if (this.hp <= 0) {
            this.tumble = true;
            this.dead = true;
            this.dead_x = argument[0].x;

            var isGuardianAngel = this.role == roles.guardian_angel;
            ghost_new(this.x, this.y, this.dir, this.mainCol, this.secondCol, isGuardianAngel);
        }

        if (this.dead) {
            this.momentum_x = rand(0, -2.5, 2.5, false);
            this.momentum_y = -rand(1, 2.0, 5.0, false);
        }
    }

    argument[0].hit_recently_timer = hit_resistance_time;

#define ghost_new // Version 0
    var this           = ghost_entity_variables();
    var posX           = argument[0]; // Int
    var posY           = argument[1]; // Int
    var dir            = argument[2]; // Int
    var mainCol        = argument[3]; // Color
    var secondCol      = argument[4]; // Color
    var guardian_angel = argument[5]; // Bool

    this.x = posX;
    this.y = posY;
    this.dir = dir;
    this.mainCol = mainCol;
    this.secondCol = secondCol;
    this.guardian_angel = guardian_angel;

    // Put in array
    array_add(ghosts, this);

#define ghost_entity_variables // Version 0
    var a = {
        // Position
        x: 0,
        y: 0,
        dir: 1,

        // Visual
        mainCol: make_colour_rgb(197, 17, 17), // Red
        secondCol: make_colour_rgb(122, 8, 56),  // Red

        // Animation
        opacity: 0.5,
        cur_anim_frame: 0,
        frame_timer: 0,
        guardian_angel: false,

        // Movement
        speed: 2.5
    };

    return a;

#define amogus_taunt // Version 0
    var this = argument[0];

    var taunt;

    if (this.hat == hats.none && pct(this.index, 0.05)) {
        taunt = states.tauntPenguinDance;
    }
    else {
        taunt = rand_in_array(this.index, this.possible_taunts);
    }

    amogus_force_state(this, taunt, 0);
    this.is_taunting = true;

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
        guardianAngel,
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
        heart,
        policeman,
        crown,
        halo,
        cheese,
        top_hat
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
        lime,
        maroon,
        rose,
        banana,
        gray,
        tan_,
        coral
    }

#define army_count // Version 0
    var count = 0;

    for (var army_item_i=0; army_item_i<array_length(army); army_item_i++) {
        var army_item = army[army_item_i];

        if (army_item != noone) {
            count++;
        }
    }

    return count;

#define momentum_to_point // Version 0
    var dist = argument[1] - argument[2];
    var momentum = dist/30 + rand(i, -1.0, 1.0, false);
    return -momentum;
// DANGER: Write your code ABOVE the LIBRARY DEFINES AND MACROS header or it will be overwritten!
// #endregion