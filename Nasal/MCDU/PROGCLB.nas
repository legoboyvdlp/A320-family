# Copyright (c) 2020 Matthew Maring (mattmaring)

var progCLBInput = func(key, i) {
	var scratchpad = mcdu_scratchpad.scratchpads[i].scratchpad;
	if (key == "L1") {
		if (scratchpad == "CLR") {
			setprop("/FMGC/internal/cruise-fl-prog", getprop("/FMGC/internal/cruise-fl"));
			if (getprop("/FMGC/status/phase") == 5) {
				setprop("/FMGC/status/phase", 3);
				setprop("/FMGC/internal/activate-once", 0);
				setprop("/FMGC/internal/activate-twice", 0);
				setprop("/FMGC/internal/decel", 0);
			}
			mcdu_scratchpad.scratchpads[i].empty();
		} else if (int(scratchpad) != nil) {
			var crzs = size(scratchpad);
			if (crzs >= 1 and crzs <= 3 and scratchpad > 0 and scratchpad <= 430 and altSet.getValue() <= scratchpad * 100) {
				setprop("/FMGC/internal/cruise-fl-prog", scratchpad);
				mcdu_scratchpad.scratchpads[i].empty();
				if (getprop("/FMGC/status/phase") == 5) {
					setprop("/FMGC/status/phase", 3);
					setprop("/FMGC/internal/activate-once", 0);
					setprop("/FMGC/internal/activate-twice", 0);
					setprop("/FMGC/internal/decel", 0);
				}
			} else {
				mcdu_message(i, "NOT ALLOWED");
			}
		} else {
			mcdu_message(i, "NOT ALLOWED");
		}
	}
}
