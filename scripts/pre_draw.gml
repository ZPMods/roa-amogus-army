if (!init_done) {
    init_enums();
}

// UPDATE ALL AMOGUS ANIMATIONS
for (var army_item_i=0; army_item_i<array_length(army); army_item_i++) {
    var amogus = army[army_item_i];

    if (amogus == noone) {
        continue;
    }

    // Render an amogus
    lib_draw_sprite("amogus_mainColor_" + amogus.state_properties.name, amogus.cur_anim_frame, amogus.x, amogus.y, {xscale: amogus.dir, col: amogus.mainCol});
    lib_draw_sprite("amogus_secondColor_" + amogus.state_properties.name, amogus.cur_anim_frame, amogus.x, amogus.y, {xscale: amogus.dir, col: amogus.secondCol});
    lib_draw_sprite("amogus_outline_" + amogus.state_properties.name, amogus.cur_anim_frame, amogus.x, amogus.y, {xscale: amogus.dir});

    // Render the hat
    if (amogus.hat != hats.none) {
        var hat_x = amogus.x;

        if (amogus.dead) {
            var offset = amogus.x - amogus.dead_x;
            hat_x = amogus.x - offset*2;
        }

        lib_draw_sprite(amogus.hat_properties.name+ "_" + amogus.state_properties.name, amogus.cur_anim_frame, hat_x, amogus.y, {xscale: amogus.dir});
    }
}

for (var ghost_i=0; ghost_i<array_length(ghosts); ghost_i++) {
    var ghost = ghosts[ghost_i];

    var state_to_draw = "ghost";
    if (ghost.guardian_angel) {
        state_to_draw = "guardianAngel";
    }

    lib_draw_sprite("amogus_mainColor_" + state_to_draw, ghost.cur_anim_frame, ghost.x, ghost.y, {xscale: ghost.dir, col: ghost.mainCol, alpha: ghost.opacity});
    lib_draw_sprite("amogus_secondColor_" + state_to_draw, ghost.cur_anim_frame, ghost.x, ghost.y, {xscale: ghost.dir, col: ghost.secondCol, alpha: ghost.opacity});
    lib_draw_sprite("amogus_outline_" + state_to_draw, ghost.cur_anim_frame, ghost.x, ghost.y, {xscale: ghost.dir, alpha: ghost.opacity});
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
        cheese
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
// DANGER: Write your code ABOVE the LIBRARY DEFINES AND MACROS header or it will be overwritten!
// #endregion