#define amogus_entity_variables {
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
}

#define amogus_new {
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
}

// UPDATE

#define amogus_update {
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

    // COLLISION BEHAVIORS

    // On ground
    if (this.is_on_ground) {
        amogus_on_ground_update(this)
    }
    // In air
    else {
        amogus_in_air_update(this);
    }

    // GAME INTERACTIONS
    // Respawn on bottom blastzone
    if (this.y >= get_stage_data(SD_Y_POS) + get_stage_data(SD_BOTTOM_BLASTZONE) && this.momentum_y > 0) {
        var dead = amogus_on_touch_bottom_blastzone(this);
        if (dead) {
            return;
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

        if (this.no_jump_timer > 0 && amogus_can_jump(this) && !this.next_to_owner && this.focused && this.y - owner.y > y_jump_dist) {
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

            amogus_on_taunt_start(this);
        }
    }
    else if (this.taunt_detected_done) {
        this.taunt_detected_done = false;
    }

}

#define amogus_anim_update {
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
                on_forced_state_end(this);
            }
            else {
                this.cur_anim_frame = 0;
            }
        }

        this.frame_timer = 0;
    }

}

#define amogus_halted_update {
    var this = argument[0];

    if (this.hitpause_timer > 0) {
        return;
    }
    
    amogus_check_ground_collision(this);
    amogus_check_walls_collision(this);
}

// RANDOMIZERS

#define amogus_randomize_color {
    var this = argument[0];

    var color = rand_in_array(this.index, colors_properties);
    this.mainCol = color.mainCol;
    this.secondCol = color.secondCol;
}

#define amogus_randomize_hat {
    var this = argument[0];

    var hat_properties = rand_in_array(this.index, hats_properties);
    this.hat = hat_properties.hat;
    this.hat_properties = hat_properties;
}

#define amogus_randomize_role {
    var this = argument[0];

    var role_properties = rand_in_array(this.index, roles_properties);
    this.role = role_properties.role;
    this.possible_taunts = role_properties.possibleTaunts;
}

#define amogus_randomize_gameplay_values {
    var this = argument[0];

    this.walk_speed    = rand_float(this.index, min_walk_speed, max_walk_speed) / divider;
    this.x_stop_dist   = rand_int(this.index, min_x_stop_dist, max_x_stop_dist);
    this.acceleration  = rand_float(this.index, min_acceleration, max_acceleration) / divider;
    this.reaction_time = rand_int(this.index, min_reaction_time, max_reaction_time);
    this.no_jump_timer = rand_int(this.index, min_nojump_time, max_nojump_time);
}

#define amogus_randomize_unfocused_walk_values {
    var this = argument[0];

    amogus_randomize_gameplay_values(this);
    this.walk_speed -= 1.5;
    this.reaction_time *= 1.5;
}

#define amogus_randomize_dir {
    var this = argument[0];

    this.dir = pct(0, 0.5) ? 1 : -1;
}

// DIRECTION

#define amogus_dir_to_owner {
    var this = argument[0];

    if (owner.x > this.x) {
        return 1;
    }

    return -1;
}

#define amogus_dir_from_momentum {
    var this = argument[0];

    if (this.momentum_x > 0) {
        return 1;
    }

    return -1;
}

#define amogus_can_turn_around {
    var this = argument[0];

    return this.land_timer <= 0 && this.jumpsquat_timer <= 0 && this.is_on_ground && !this.is_taunting;
}

// STATES

#define amogus_set_state {
    var this = argument[0];

    if (this.state != argument[1]) {
        this.cur_anim_frame = 0;
        this.frame_timer = 0;
        this.state = argument[1];
        this.state_properties = get_state_properties(argument[1]);
    }
}

#define amogus_force_state {
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
}

#define amogus_is_in_taunt_state {
    var this = argument[0];
    switch (this.state) {
        case states.tauntPenguinDance :
        case states.tauntScan :
            return true
        break;
        
        default:
            return false;
        break;
    }
}

#define on_forced_state_end {
    var this = argument[0];

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

// COLLISION

#define amogus_check_ground_collision {
    var this = argument[0];

    if (this.dead) {
        this.is_on_ground = false;
        return;
    }

    if (collision_at_point(this.x, this.y+1) && this.momentum_y >= 0) {
        if (!this.is_on_ground) {
            this.is_on_ground = true;
            amogus_on_land(this);
        }
    }
    else {
        if (this.is_on_ground) {
            this.is_on_ground = false;
            amogus_on_air_start(this);
        }
    }
}

#define amogus_on_ground_update {
    var this = argument[0];

    if (this.dead) {
        return;
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

#define amogus_in_air_update {
    var this = argument[0];

    if (this.momentum_y > 0 || this.tumble) {
        this.fall_time++;
    }

    this.momentum_y += gravity;

    if (this.momentum_y > fall_speed && !this.tumble) {
        this.momentum_y = fall_speed;
    }
}

#define amogus_on_land {
    var this = argument[0];

    if (this.dead) {
        return;
    }

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

    this.y = amogus_closest_ground_above(this);

    if (this.momentum_y > 0) {
        this.momentum_y = 0;
    }
}

#define amogus_on_air_start {
    var this = argument[0];

    this.is_on_ground = false;

    if (this.heavy_land) {
        this.heavy_land = false;
    }
}

#define amogus_check_walls_collision {
    var this = argument[0];

    if (this.dead) {
        return;
    }

    if (abs(this.momentum_x) > 0 && collision_point(this.x + 16 * amogus_dir_from_momentum(this), this.y - 20, asset_get("par_block"), false, true) && !this.dead) {
        amogus_on_touch_wall(this);
    }
}

#define amogus_on_touch_wall {
    var this = argument[0];

    this.momentum_x *= this.tumble ? -1 : 0;
}

#define amogus_closest_ground_above {
    var this = argument[0];

    for (i=0; i <= 999; i++) { 
        if (!collision_at_point(this.x, round(this.y)-i)) {
            return this.y-i+1;
        }
    }

    return this.y;
}

#define amogus_closest_ground_below {
    var this = argument[0];

    for (i=0; i <= 999; i++) { 
        if (collision_at_point(this.x, round(this.y)+i)) {
            return this.y+i;
        }
    }

    return this.y;
}

// WALK

#define amogus_try_to_walk {
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
}

#define amogus_can_walk {   
    var this = argument[0];

    if (this.is_on_ground && this.land_timer <= 0 && this.jumpsquat_timer <= 0 && this.wait_timer <= 0 && !this.dead && !this.tumble && !this.is_taunting) {

        if ((this.x <= get_stage_data(SD_X_POS) + this.x_stop_dist && this.dir == -1) || (this.x >= get_stage_data(SD_X_POS) + get_stage_data(SD_WIDTH) - this.x_stop_dist && this.dir == 1)) {
            return false;
        }

        return true;
    }

    return false;
}

#define amogus_walk {
    var this = argument[0];

    if (!this.is_walking) {
        this.is_walking = true;
    }

    this.momentum_x += this.acceleration * this.dir;
    
    if (abs(this.momentum_x) > this.walk_speed) {
        this.momentum_x = this.walk_speed * this.dir;
    }
}

#define amogus_stop {
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
}

// JUMP

#define amogus_jump {
    var this = argument[0];

    var lerp_val = (this.y - owner.y - 100)/100;
    lerp_val = clamp(lerp_val, 0, 1);

    var base_jump_force = lerp(min_jump_height, max_jump_height, lerp_val);
    var jump_force = base_jump_force + rand_float(0, -1.0, 1.0)

    lerp_val = abs(this.x - owner.x)/100;
    lerp_val = clamp(lerp_val, 0, 1);

    var jump_forward = lerp(0, rand_float(0, min_walk_speed, max_walk_speed) / divider, lerp_val);

    this.momentum_y = -jump_force;
    this.momentum_x = jump_forward * amogus_dir_to_owner(this);
    this.is_jumping = true;
}

#define amogus_can_jump {
    var this = argument[0];

    return this.is_on_ground && !this.is_jumping && this.land_timer <= 0 && !this.is_taunting
}

// FOCUS

#define amogus_focused_update {
    var this = argument[0];

    // Look at player
    if (this.dir != amogus_dir_to_owner(this) && amogus_can_turn_around(this)) {
        this.dir = amogus_dir_to_owner(this);
    }

    // Far from player
    if (abs(this.x - owner.x) > this.x_stop_dist) {
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
}

#define amogus_unfocused_update {
    var this = argument[0];

    amogus_try_to_walk(this);

    if (this.wait_timer <= 0 && this.walk_timer <= 0 && amogus_can_turn_around(this)) {
        amogus_randomize_dir(this);
        this.walk_timer = rand_int(this.index, min_unfocused_walk_time, max_unfocused_walk_time);
    }
}

#define amogus_try_to_lose_focus {
    var this = argument[0];

    if (pct(0, chance_to_lose_focus)) {
        amogus_lose_focus(this);
        return;
    }

    amogus_gain_focus(this);
}

#define amogus_lose_focus {
    var this = argument[0];

    amogus_randomize_unfocused_walk_values(this);

    this.unfocused_timer = rand_int(0, min_unfocused_time, max_unfocused_time);
    this.walk_timer = rand_int(0, min_unfocused_walk_time, max_unfocused_walk_time);
    this.wait_timer = this.reaction_time;
    
    this.focused = false;
}

#define amogus_gain_focus {
    var this = argument[0];

    if (!this.focused) {
        this.focused = true;
        amogus_randomize_gameplay_values(this);
    }

    this.sitting = false;
    this.focused_timer = rand_int(this.index, min_focused_time, max_focused_time);
}

#define amogus_is_focused {
    var this = argument[0];

    return this.unfocused_timer <= 0 || this.focused == true;
}

#define amogus_focused_on_stop {
    var this = argument[0];

    amogus_try_to_lose_focus(this);
}

#define amogus_unfocused_on_stop {
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
}

// DAMAGE

#define amogus_owner_hit_close {
    var this = argument[0];

    // Hitbox
    if (owner.enemy_hitboxID == noone || owner.enemy_hitboxID <= 0) {
        return;
    }

    print(owner.enemy_hitboxID);

    this.hitpause_timer = owner.hitstop_full;
    this.tumble = true;

    var hitbox = owner.enemy_hitboxID;

    var ang = get_hitbox_angle(hitbox);
    ang += rand_int(this.index, -hit_ang_var, hit_ang_var);

    var force = hitbox.kb_value + hitbox.kb_scale * 0.05 * get_player_damage(owner.player); 
    force += rand_int(this.index, -hit_force_var, hit_force_var);

    var force_x = lengthdir_x( force, ang );
    var force_y = lengthdir_y( force, ang );

    // Bounce on ground
    if (this.is_on_ground && force_y > 0) {
        force_y *= -0.5;
    }

    this.momentum_x = force_x;
    this.momentum_y = force_y;
} 

#define amogus_take_damage {
    var this = argument[0];

    if (this.hit_recently_timer <= 0) {
        this.hp--;
        if (this.hp <= 0) {
            amogus_die(this);
        }

        if (this.dead) {
            this.momentum_x = rand_float(this.index, -2.5, 2.5);
            this.momentum_y = -rand_float(this.index, 2.0, 5.0);
        }
    }
    
    argument[0].hit_recently_timer = hit_resistance_time;
}

#define amogus_die {
    var this = argument[0];

    this.tumble = true;
    this.dead = true;
    this.dead_x = argument[0].x;

    var isGuardianAngel = this.role == roles.guardian_angel;
    ghost_new(this.x, this.y, this.dir, this.mainCol, this.secondCol, isGuardianAngel);

    this.momentum_x = rand_float(this.index, -2.5, 2.5);
    this.momentum_y = -rand_float(this.index, 2.0, 5.0);
}

#define amogus_on_touch_bottom_blastzone {
    var this = argument[0];
    
    if (this.dead) {
        army[this.index] = noone;
        return true;
    }
    
    this.x = room_width / 2 + rand_int(this.index, -150, 150);
    this.y = 0;
    this.tumble = true;

    this.momentum_x *= 0.75;
    return false;
}

// TAUNT

#define amogus_on_taunt_start {
    var this = argument[0];

    if (!this.sitting && this.is_on_ground && this.land_timer <= 0 && this.jumpsquat_timer < 0 && !this.is_taunting) {
        if (pct(this.index, this.focused_timer > 0 ? focused_chance_to_taunt : unfocused_chance_to_taunt)) {
            this.taunt_timer = rand_int(this.index, min_taunt_wait_time, max_taunt_wait_time);
            this.wait_timer += this.taunt_timer;
        }
    }
}

#define amogus_taunt {
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
}


#define amogus_vent {
    var this = argument[0];

    this.y -= 200;
    this.x = random_point_above_stage(this.index);

    this.y = amogus_closest_ground_below(this);
}

