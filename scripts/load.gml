pet_w = 0;
run_speed = 0;
max_run_dist = 999999999;

// ENUMS
init_enums();

// Roles properties
roles_properties = [
    { role: roles.crewmate,                 possibleTaunts: [states.tauntScan]                              },
    { role: roles.impostor,                 possibleTaunts: [states.tauntTongue, states.tauntVentIn]          },
    { role: roles.shapeshifter,             possibleTaunts: [states.tauntTongue, states.tauntShapeshift]    },
    { role: roles.engineer,                 possibleTaunts: [states.tauntScan, states.tauntVentIn]            },
    { role: roles.doctor,                   possibleTaunts: [states.tauntScan, states.tauntDoctor]          },
    { role: roles.guardian_angel,           possibleTaunts: [states.tauntScan]                              }
];

// States properties
states_properties = [
    { state: states.idle,                  name: "idle",                   speed: 3,            frameCount: 2   },
    { state: states.idleToSit,             name: "idleToSit",              speed: 8,            frameCount: 3   },
    { state: states.sit,                   name: "sit",                    speed: 1,            frameCount: 1   },
    { state: states.run,                   name: "run",                    speed: 12,           frameCount: 6   },
    { state: states.rise,                  name: "rise",                   speed: 15,           frameCount: 2   },
    { state: states.fall,                  name: "fall",                   speed: 15,           frameCount: 2   },
    { state: states.land,                  name: "land",                   speed: 1,            frameCount: 1   },
    { state: states.jumpsquat,             name: "jumpsquat",              speed: 1,            frameCount: 1   },
    { state: states.tumble,                name: "tumble",                 speed: 20,           frameCount: 4   },
    { state: states.heavyland,             name: "heavyland",              speed: 1,            frameCount: 1   },
    { state: states.hurt,                  name: "hurt",                   speed: 1,            frameCount: 1   },
    { state: states.dead,                  name: "dead",                   speed: 16,           frameCount: 4   },
    { state: states.ghost,                 name: "ghost",                  speed: 12,           frameCount: 14  },
    { state: states.tauntPenguinDance,     name: "tauntPenguinDance",      speed: 10,           frameCount: 69  },
    { state: states.tauntScan,             name: "tauntScan",              speed: 9,            frameCount: 15  },
    { state: states.tauntTongue,           name: "tauntTongue",            speed: 1,            frameCount: 1   },
    { state: states.tauntShapeshift,       name: "tauntShapeshift",        speed: 1,            frameCount: 1   },
    { state: states.tauntShapeshiftEnd,    name: "tauntShapeshiftEnd",     speed: 1,            frameCount: 1   },
    { state: states.tauntVentIn,           name: "tauntVentIn",            speed: 1,            frameCount: 1   },
    { state: states.tauntVentOut,          name: "tauntVentOut",           speed: 1,            frameCount: 1   },
    { state: states.tauntDoctor,           name: "tauntDoctor",            speed: 1,            frameCount: 1   }
];

// Hats properties
hats_properties = [
    { hat: hats.none,              name: "none"         },
    { hat: hats.post_it,           name: "post_it"      },
    { hat: hats.bear_ears,         name: "bear_ears"    },
    { hat: hats.young_sprout,      name: "young_sprout" },
    { hat: hats.knight_horns,      name: "knight_horns" },
    { hat: hats.headslug,          name: "headslug"     },
    { hat: hats.imp,               name: "imp"          },
    { hat: hats.frog_hat,          name: "frog_hat"     },
    { hat: hats.bakugo_mask,       name: "bakugo_mask"  },
    { hat: hats.tree,              name: "tree"         },
    { hat: hats.jinx_hair,         name: "jinx_hair"    },
    { hat: hats.egg,               name: "egg"          },
    { hat: hats.heart,             name: "heart"        }
];

// Colors properties
colors_properties = [
    { color: colors.red,       mainCol: make_colour_rgb(197, 17, 17),      secondCol: make_colour_rgb(122, 8, 56)      },       
    { color: colors.blue,      mainCol: make_colour_rgb(19, 46, 209),      secondCol: make_colour_rgb(9, 21, 142)      },      
    { color: colors.green,     mainCol: make_colour_rgb(17, 127, 45),      secondCol: make_colour_rgb(10, 77, 46)      },         
    { color: colors.pink,      mainCol: make_colour_rgb(237, 84, 186),     secondCol: make_colour_rgb(171, 43, 173)    },      
    { color: colors.orange,    mainCol: make_colour_rgb(237, 125, 13),     secondCol: make_colour_rgb(179, 62, 21)     },        
    { color: colors.yellow,    mainCol: make_colour_rgb(245, 245, 87),     secondCol: make_colour_rgb(194, 135, 34)    },        
    { color: colors.black,     mainCol: make_colour_rgb(63, 71, 78),       secondCol: make_colour_rgb(30, 31, 38)      },         
    { color: colors.white,     mainCol: make_colour_rgb(214, 224, 240),    secondCol: make_colour_rgb(131, 148, 191)   },         
    { color: colors.purple,    mainCol: make_colour_rgb(107, 47, 187),     secondCol: make_colour_rgb(59, 23, 124)     },        
    { color: colors.brown,     mainCol: make_colour_rgb(113, 73, 30),      secondCol: make_colour_rgb(94, 38, 21)      },         
    { color: colors.cyan,      mainCol: make_colour_rgb(56, 222, 220),     secondCol: make_colour_rgb(36, 168, 190)    },      
    { color: colors.lime,      mainCol: make_colour_rgb(80, 239, 57),      secondCol: make_colour_rgb(21, 167, 66)     }      
];

// VARIABLES
init_done = false;

stage_center_x = get_stage_data(SD_X_POS) + get_stage_data(SD_WIDTH)/2;
stage_center_y = get_stage_data(SD_Y_POS);

got_hit_detected_done = false;
hit_enemy_detected_done = false;
dead_enemy_detected_done = false;
last_hit_enemy = noone;

focused_chance_to_taunt = 0.75;
unfocused_chance_to_taunt = 0.5;

base_hp = 3;

respawn_x = 0;
respawn_y = 0;

hit_transfer_radius = 50;
hit_resistance_time = 300;
hit_ang_var = 7.5;
hit_force_var = 1;

dead_rot_speed = 12;

base_amogus = 3;
amogus_on_kill = 3;
max_amogus = 15;

divider = 10

// Affected by divider
min_acceleration = 2.0;
max_acceleration = 3.0;
min_walk_speed = 25.0;
max_walk_speed = 30.0;

// Not affected by divider
min_jump_height = 6.0;
max_jump_height = 9.0;

min_nojump_time = 60;
max_nojump_time = 120;

chance_to_jump = 0.5;

jumpsquat_time = 10;

x_min_stop_dist = 40;
x_max_stop_dist = 100;

y_jump_dist = 60;

min_reaction_time = 5;
max_reaction_time = 20;

min_focused_time = 600;
max_focused_time = 900;

min_unfocused_time = 300;
max_unfocused_time = 1200;

min_unfocused_walk_time = 20;
max_unfocused_walk_time = 60;

min_unfocused_wait_time = 60;
max_unfocused_wait_time = 120;

chance_to_lose_focus = 0.33;
chance_to_sit = 0.25;

ground_friction = 0.9;
air_friction = 0.99;
gravity = 0.2;
fall_speed = 9.81;

push_force = 0.75;
push_dist_threshold = 20;
stopped_threshold = 0.5;

// Army
army = [];
ghosts = [];

// Spritesheets setup
amogus_parts = [
    "amogus_mainColor",
    "amogus_secondColor",
    "amogus_outline"
];

// All sprites
sprite_names = amogus_parts
for(var i = 0; i < array_length(hats_properties); i++) {
	array_push(sprite_names, hats_properties[i].name);
}

// foreach sprite
for (var sprite_name_i=0; sprite_name_i<array_length(sprite_names); sprite_name_i++) {
    var sprite_name = sprite_names[sprite_name_i];
    if (sprite_name == "none") {
        continue;
    }

    for (var state_property_i=0; state_property_i<array_length(states_properties); state_property_i++) {
        var state_property = states_properties[state_property_i];

        sprite_change_offset(sprite_name + "_" + state_property.name, 32, 78);
    }
}

// #region vvv LIBRARY DEFINES AND MACROS vvv
// DANGER File below this point will be overwritten! Generated defines and macros below.
// Write NO-INJECT in a comment above this area to disable injection.
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