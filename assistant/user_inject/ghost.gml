#define ghost_entity_variables {
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
}

#define ghost_new {
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
}