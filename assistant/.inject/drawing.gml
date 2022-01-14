#define lib_draw_sprite {   
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
}