#define get_state_properties {
    for (var state_property_i=0; state_property_i<array_length(state_properties); state_property_i++) {
        var state_property = state_properties[state_property_i];

        if (state_property.state == argument[0]) {
            return state_property;
        }
    }
}