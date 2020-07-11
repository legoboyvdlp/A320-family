# A3XX mCDU by Joshua Davidson (Octal450), Jonathan Redpath, and Matthew Maring (mattmaring)

# Copyright (c) 2020 Matthew Maring (mattmaring)

var perfCRZInput = func(key, i) {
	var scratchpad = mcdu_scratchpad.scratchpads[i].scratchpad;
	if (key == "L2") {
		if (scratchpad == "CLR") {
			fmgc.FMGCInternal.costIndex = 0;
			fmgc.FMGCInternal.costIndexSet = 0;
			fmgc.FMGCNodes.costIndex.setValue(0);
			mcdu_scratchpad.scratchpads[i].empty();
		} else {
			var ci = int(scratchpad);
			var cis = size(scratchpad);
			if (cis >= 1 and cis <= 3) {
				if (ci != nil and ci >= 0 and ci <= 999) {
					fmgc.FMGCInternal.costIndex = ci;
					fmgc.FMGCInternal.costIndexSet = 1;
					fmgc.FMGCNodes.costIndex.setValue(fmgc.FMGCInternal.costIndex);
					mcdu_scratchpad.scratchpads[i].empty();
				} else {
					mcdu_message(i, "NOT ALLOWED");
				}
			} else {
				mcdu_message(i, "NOT ALLOWED");
			}
		}
	} else if (key == "L6") {
		if (fmgc.FMGCInternal.phase == 3) {
			if (getprop("/FMGC/internal/activate-once") == 1) {
				if (getprop("/FMGC/internal/activate-twice") == 0) {
					setprop("/FMGC/internal/activate-twice", 1);
					fmgc.FMGCInternal.phase = 5;
					setprop("/FMGC/internal/decel", 1);
					setprop("MCDU[" ~ i ~ "]/page", "PERFAPPR");
				} else {
					mcdu_message(i, "NOT ALLOWED");
				}
			} else {
				setprop("/FMGC/internal/activate-once", 1);
			}
		} else {
			setprop("MCDU[" ~ i ~ "]/page", "PERFCLB");
		}
	} else if (key == "R6") {
		setprop("MCDU[" ~ i ~ "]/page", "PERFDES");
	}
}
