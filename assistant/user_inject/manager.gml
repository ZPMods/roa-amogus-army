#define army_count {
    return array_count(army);
}

#define ghosts_count {
    return array_count(ghosts);
}

#define get_state_properties {
    for (var state_property_i=0; state_property_i<array_length(states_properties); state_property_i++) {
        var state_property = states_properties[state_property_i];

        if (state_property.state == argument[0]) {
            return state_property;
        }
    }
}

#define get_hat_properties {
    for (var hat_property_i=0; hat_property_i<array_length(hats_properties); hat_property_i++) {
        var hat_property = hats_properties[hat_property_i];

        if (hat_property.hat == argument[0]) {
            return hat_property;
        }
    }
}

#define get_role_properties {
    for (var role_property_i=0; role_property_i<array_length(roles_properties); role_property_i++) {
        var role_property = roles_properties[role_property_i];

        if (role_property.role == argument[0]) {
            return role_property;
        }
    }
}

#define get_colors {
    for (var amogus_color_i=0; amogus_color_i<array_length(colors_properties); amogus_color_i++) {
        var amogus_color = colors_properties[amogus_color_i]

            if (amogus_color.name == argument[0]) {
            return amogus_color;
        }
    }
}

#define collision_at_point {
    if (collision_point(argument[0], argument[1], asset_get("par_block"), false, true) || collision_point(argument[0], argument[1], asset_get("par_jumpthrough"), false, true)) {
        return true;
    }

    return false;
}

#define collision_down_line { // (x, y, down_offset)
    if (collision_line(argument[0], argument[1], argument[0], argument[1]+argument[2], asset_get("par_block"), false, true) || collision_line(argument[0], argument[1], argument[0], argument[1]+argument[2], asset_get("par_jumpthrough"), false, true)) {
        return true;
    }

    return false;
}

#define random_point_above_stage {
    var x_offset = random_func_2(argument[0], get_stage_data(SD_WIDTH), true) - get_stage_data(SD_WIDTH)/2;
    return stage_center_x + x_offset;
}

#define momentum_to_point {
    var dist = argument[1] - argument[2];
    var momentum = dist/30 + rand(i, -1.0, 1.0, false);
    return -momentum;
}