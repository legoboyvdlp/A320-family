# Copyright (c) 2020 Matthew Maring (mattmaring)

var altSet = props.globals.getNode("it-autoflight/input/alt", 1);

var progTOInput = func(key, i) {
	var scratchpad = mcdu_scratchpad.scratchpads[i].scratchpad;
	if (key == "L1") {
		if (scratchpad == "CLR") {
			fmgc.FMGCInternal.crzProg = fmgc.FMGCInternal.crzFl;
			mcdu_scratchpad.scratchpads[i].empty();
		} else if (int(scratchpad) != nil) {
			var crzs = size(scratchpad);
			if (crzs >= 1 and crzs <= 3 and scratchpad > 0 and scratchpad <= 430 and fmgc.FMGCInternal.crzSet <= scratchpad * 100 and fmgc.FMGCInternal.crzSet) {
				fmgc.FMGCInternal.crzProg = scratchpad;
				mcdu_scratchpad.scratchpads[i].empty();
			} else {
				mcdu_message(i, "NOT ALLOWED");
			}
		} else {
			mcdu_message(i, "NOT ALLOWED");
		}
	}
}
