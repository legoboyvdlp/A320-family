# Copyright (c) 2020 Matthew Maring (mattmaring)

var progCRZInput = func(key, i) {
	var scratchpad = mcdu_scratchpad.scratchpads[i].scratchpad;
	if (key == "L1") {
		if (scratchpad == "CLR") {
			fmgc.FMGCInternal.crzProg = fmgc.FMGCInternal.crzFl;
			if (fmgc.FMGCInternal.phase == 5) {
				fmgc.FMGCInternal.phase = 3;
				setprop("/FMGC/internal/activate-once", 0);
				setprop("/FMGC/internal/activate-twice", 0);
				setprop("/FMGC/internal/decel", 0);
			}
			mcdu_scratchpad.scratchpads[i].empty();
		} else if (int(scratchpad) != nil) {
			var crzs = size(scratchpad);
			if (crzs >= 1 and crzs <= 3 and scratchpad > 0 and scratchpad <= 430 and fmgc.FMGCInternal.crzSet <= scratchpad * 100) {
				fmgc.FMGCInternal.crzProg = scratchpad;
				mcdu_scratchpad.scratchpads[i].empty();
				if (fmgc.FMGCInternal.phase == 5) {
					fmgc.FMGCInternal.phase = 3;
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
