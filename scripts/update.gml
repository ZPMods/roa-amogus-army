// INIT
if (!init_done) {
    init_done = true;

    new_random_amogus();
    //array_delete(army, 0, 1);
}

// UPDATE

// #region vvv LIBRARY DEFINES AND MACROS vvv
// DANGER File below this point will be overwritten! Generated defines and macros below.
// Write NO-INJECT in a comment above this area to disable injection.
#define new_random_amogus // Version 0
    // Init amogus
    var new_amogus = { x: 0, y: 0, state: "idle", cur_anim_frame: 0, frame_timer: 0, dir: 1, mainCol: c_white, secondCol: c_white, hat:"post_it" };

    // Set colors
    var color = amogus_colors[random_func(0, array_length(amogus_colors), true)];
    new_amogus.mainCol = color.mainCol;
    new_amogus.secondCol = color.secondCol;

    // Set hat
    var hat = hat_names[random_func(1, array_length(hat_names), true)];
    new_amogus.hat = hat;

    // Put in array

    array_push(army, new_amogus);
// DANGER: Write your code ABOVE the LIBRARY DEFINES AND MACROS header or it will be overwritten!
// #endregion