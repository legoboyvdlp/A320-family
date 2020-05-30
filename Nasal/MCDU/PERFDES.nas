# A3XX mCDU by Joshua Davidson (Octal450), Jonathan Redpath, and Matthew Maring (mattmaring)

# Copyright (c) 2020 Matthew Maring (mattmaring)

var perfDESInput = func(key, i) {
	var scratchpad = mcdu_scratchpad.scratchpads[i].scratchpad;
	if (key == "L2") {
		if (scratchpad == "CLR") {
			setprop("/FMGC/internal/cost-index", 0);
			setprop("/FMGC/internal/cost-index-set", 0);
			mcdu_scratchpad.scratchpads[i].empty();
		} else {
			var ci = int(scratchpad);
			var cis = size(scratchpad);
			if (cis >= 1 and cis <= 3) {
				if (ci != nil and ci >= 0 and ci <= 999) {
					setprop("/FMGC/internal/cost-index", ci);
					setprop("/FMGC/internal/cost-index-set", 1);
					mcdu_scratchpad.scratchpads[i].empty();
				} else {
					mcdu_message(i, "NOT ALLOWED");
				}
			} else {
				mcdu_message(i, "NOT ALLOWED");
			}
		}
	} else if (key == "L6") {
		if (getprop("/FMGC/status/phase") == 4) {
			if (getprop("/FMGC/internal/activate-once") == 1) {
				if (getprop("/FMGC/internal/activate-twice") == 0) {
					setprop("/FMGC/internal/activate-twice", 1);
					setprop("/FMGC/status/phase", 5);
					setprop("/FMGC/internal/decel", 1);
					setprop("MCDU[" ~ i ~ "]/page", "PERFAPPR");
				} else {
					mcdu_message(i, "NOT ALLOWED");
				}
			} else {
				setprop("/FMGC/internal/activate-once", 1);
			}
		} else {
			setprop("MCDU[" ~ i ~ "]/page", "PERFCRZ");
		}
	} else if (key == "R6") {
		setprop("MCDU[" ~ i ~ "]/page", "PERFAPPR");
	}
}
