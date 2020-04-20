# Copyright (c) 2020 Matthew Maring (hayden2000)

var altSet = props.globals.getNode("it-autoflight/input/alt", 1);

var progTOInput = func(key, i) {
	var scratchpad = getprop("MCDU[" ~ i ~ "]/scratchpad");
	if (key == "L1") {
		if (scratchpad == "CLR") {
			setprop("FMGC/internal/cruise-fl-prog", getprop("FMGC/internal/cruise-fl"));
			setprop("MCDU[" ~ i ~ "]/scratchpad-msg", 0);
			setprop("MCDU[" ~ i ~ "]/scratchpad", "");
		} else if (int(scratchpad) != nil) {
			var crzs = size(scratchpad);
			if (crzs >= 1 and crzs <= 3 and scratchpad > 0 and scratchpad <= 430 and altSet.getValue() <= scratchpad * 100 and getprop("FMGC/internal/cruise-lvl-set")) {
				setprop("FMGC/internal/cruise-fl-prog", scratchpad);
				setprop("MCDU[" ~ i ~ "]/scratchpad", "");
			} else {
				notAllowed(i);
			}
		} else {
			notAllowed(i);
		}
	}
}
