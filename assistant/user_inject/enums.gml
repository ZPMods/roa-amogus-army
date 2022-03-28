#define init_enums {
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
        halo
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
}