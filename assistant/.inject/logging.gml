#define prints()
    // Prints each parameter to console, separated by spaces.
    var _out_string = string(argument[0])
    for (var i=1; i<argument_count; i++) {
        _out_string += " "
        _out_string += string(argument[i])
    }
    print(_out_string)

#define export_string_unsafe(text, description) {
    // Warning: This can softlock your game when called very frequently, such as in an update script.
    // Prefer `export_string`.
    // Displays the given text in a popup window that the user can copy to their clipboard.
    get_string(description, text)
}

#define export_string {
    // text, ?description
    // Displays the given text in a popup window that the user can copy to their clipboard.
    // To prevent softlocks, this will only run once every 5 seconds.
    var should_run = true;
    if "_last_export_string_frame" in self && get_gameplay_time() - _last_export_string_frame <= 60*5 {
        print("SAFETY: Not running export string")
        should_run = false;
    }
    
    if should_run {
        _last_export_string_frame = get_gameplay_time()
        var text = argument[0];
        if argument_count >= 2 {
            var description = argument[1];
        } else {
            var description = "Text export:"
        }
        export_string_unsafe(text, description)
    }
}
