pet_w = 0;
run_speed = 0;
max_run_dist = 999999999;
init_done = false;

// VARIABLES

// Army
army = [];

// Colors
amogus_colors = [
    { name: "red", mainCol: make_colour_rgb(197, 17, 17), secondCol: make_colour_rgb(122, 8, 56) },
    { name: "blue", mainCol: make_colour_rgb(19, 46, 209), secondCol: make_colour_rgb(9, 21, 142) },
    { name: "green", mainCol: make_colour_rgb(17, 127, 45), secondCol: make_colour_rgb(10, 77, 46) },
    { name: "pink", mainCol: make_colour_rgb(237, 84, 186), secondCol: make_colour_rgb(171, 43, 173) },
    { name: "orange", mainCol: make_colour_rgb(237, 125, 13), secondCol: make_colour_rgb(179, 62, 21) },
    { name: "yellow", mainCol: make_colour_rgb(245, 245, 87), secondCol: make_colour_rgb(194, 135, 34) },
    { name: "black", mainCol: make_colour_rgb(63, 71, 78), secondCol: make_colour_rgb(30, 31, 38) },
    { name: "white", mainCol: make_colour_rgb(214, 224, 240), secondCol: make_colour_rgb(131, 148, 191) },
    { name: "purple", mainCol: make_colour_rgb(107, 47, 187), secondCol: make_colour_rgb(59, 23, 124) },
    { name: "brown", mainCol: make_colour_rgb(113, 73, 30), secondCol: make_colour_rgb(94, 38, 21) },
    { name: "cyan", mainCol: make_colour_rgb(56, 222, 220), secondCol: make_colour_rgb(36, 168, 190) },
    { name: "lime", mainCol: make_colour_rgb(80, 239, 57), secondCol: make_colour_rgb(21, 167, 66) }
];

// States setup
state_properties = [
    { state: "idle", speed: 6, frameCount: 2 },
    { state: "run", speed: 15, frameCount: 4 },
    { state: "rise", speed: 15, frameCount: 2 },
    { state: "fall", speed: 15, frameCount: 2 },
    { state: "land", speed: 12, frameCount: 1 },
    { state: "tumble", speed: 20, frameCount: 4 },
    { state: "heavyland", speed: 12, frameCount: 1 },
    { state: "dead", speed: 12, frameCount: 1 }
];

// Spritesheets setup
amogus_parts = [
    "amogus_mainColor",
    "amogus_secondColor",
    "amogus_outline"
];

// Hats
hat_names = [
    "post_it",
    "bear_ears",
    "mini_crewmate"
]

// All sprites
sprite_names = amogus_parts
for(var i = 0; i < array_length(hat_names); i++) {
	array_push(sprite_names, hat_names[i]);
}

// foreach sprite
for (var sprite_name_i=0; sprite_name_i<array_length(sprite_names); sprite_name_i++) {
    var sprite_name = sprite_names[sprite_name_i];
    
    for (var state_property_i=0; state_property_i<array_length(state_properties); state_property_i++) {
        var state_property = state_properties[state_property_i];

        sprite_change_offset(sprite_name + "_" + state_property.state, 17, 23);
    }
}