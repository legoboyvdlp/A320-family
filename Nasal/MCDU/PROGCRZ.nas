# Copyright (c) 2020 Matthew Maring (hayden2000)

var progCRZInput = func(key, i) {
	var scratchpad = getprop("MCDU[" ~ i ~ "]/scratchpad");
	if (key == "L1") {
		if (scratchpad == "CLR") {
			setprop("FMGC/internal/cruise-fl-prog", getprop("FMGC/internal/cruise-fl"));
		} else if (int(scratchpad) != nil) {
			var crzs = size(scratchpad);
			if (crzs >= 1 and crzs <= 3 and scratchpad > 0 and scratchpad <= 430 and altSet.getValue() <= scratchpad * 100) {
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
