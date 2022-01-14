// UPDATE ALL AMOGUS ANIMATIONS
for (var army_item_i=0; army_item_i<array_length(army); army_item_i++) {
    var amogus = army[army_item_i];

	amogus.x = owner.x+100;
	amogus.y = owner.y;
    amogus.dir = owner.spr_dir;

    var speed = get_state_properties(amogus.state).speed;
    var frame_timer_max = 60 / speed;

    amogus.frame_timer ++;
    if (amogus.frame_timer >= frame_timer_max) {
        amogus.cur_anim_frame++;
        
        if (amogus.cur_anim_frame >= get_state_properties(amogus.state).frameCount) {
            amogus.cur_anim_frame = 0;
        }

        amogus.frame_timer = 0;
    }

    // Render an amogus
    lib_draw_sprite("amogus_mainColor_" + amogus.state, amogus.cur_anim_frame, amogus.x, amogus.y, {xscale: amogus.dir, col: amogus.mainCol});
    lib_draw_sprite("amogus_secondColor_" + amogus.state, amogus.cur_anim_frame, amogus.x, amogus.y, {xscale: amogus.dir, col: amogus.secondCol});
    lib_draw_sprite("amogus_outline_" + amogus.state, amogus.cur_anim_frame, amogus.x, amogus.y, {xscale: amogus.dir});

    // Render the hat
    lib_draw_sprite(amogus.hat+ "_" + amogus.state, amogus.cur_anim_frame, amogus.x, amogus.y, {xscale: amogus.dir});
}

// #region vvv LIBRARY DEFINES AND MACROS vvv
// DANGER File below this point will be overwritten! Generated defines and macros below.
// Write NO-INJECT in a comment above this area to disable injection.
#define lib_draw_sprite // Version 0
    // sprite, subimg, x, y, ?{rot=0, col=c_white, alpha=1}
    var sprite = argument[0]
    if is_string(sprite) {
        sprite = sprite_get(sprite)
    }

    var subimg = argument[1]
    var x = argument[2]
    var y = argument[3]
    var params = {}
    if argument_count == 5 {
        params = argument[4]
    }
    if argument_count > 5 {
        print("draw_sprite called with too many arguments. Use a parameter struct instead. `lib_draw_sprite(_sprite, _subimg, _x, _y, {alpha:0.5})`") // Todo, improve this with instructions.
        var die = 1/0
    }

    var xscale = 1
    if 'xscale' in params {
        xscale = params.xscale
    }
    var yscale = 1
    if 'yscale' in params {
        yscale = params.yscale
    }
    var rot = 0
    if 'rot' in params {
        rot = params.rot
    }
    var col = c_white
    if 'col' in params {
        col = params.col
    }
    var alpha = 1
    if 'alpha' in params {
        alpha = params.alpha
    }
    draw_sprite_ext(sprite, subimg, x, y, xscale, yscale, rot, col, alpha)

#define get_state_properties // Version 0
    for (var state_property_i=0; state_property_i<array_length(state_properties); state_property_i++) {
        var state_property = state_properties[state_property_i];

        if (state_property.state == argument[0]) {
            return state_property;
        }
    }
// DANGER: Write your code ABOVE the LIBRARY DEFINES AND MACROS header or it will be overwritten!
// #endregion