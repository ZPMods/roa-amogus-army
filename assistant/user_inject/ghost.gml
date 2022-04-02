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

#define ghost_update {
    var this = argument[0];
    var ghost_i = argument[1];

    // ANIM STUFF -----------
    // Take care of everything about frame timer in update
    // So that it stops when in pause
    var anim_speed = get_state_properties(states.ghost).speed;
    var frame_timer_max = 60 / anim_speed;

    this.frame_timer ++;

    if (this.frame_timer >= frame_timer_max) {
        this.cur_anim_frame++;
        
        if (this.cur_anim_frame >= get_state_properties(states.ghost).frameCount) {
            this.cur_anim_frame = 0;
        }

        this.frame_timer = 0;
    }

    this.y -= this.speed;

    if (this.y < 0) {
        ghosts[ghost_i] = noone;
    }
}