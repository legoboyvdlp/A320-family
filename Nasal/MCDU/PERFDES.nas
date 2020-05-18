# A3XX mCDU by Joshua Davidson (Octal450), Jonathan Redpath, and Matthew Maring (mattmaring)

# Copyright (c) 2020 Matthew Maring (mattmaring)

var perfDESInput = func(key, i) {
	var scratchpad = getprop("MCDU[" ~ i ~ "]/scratchpad");
	if (key == "L2") {
		if (scratchpad == "CLR") {
			setprop("/FMGC/internal/cost-index", 0);
			setprop("/FMGC/internal/cost-index-set", 0);
			setprop("MCDU[" ~ i ~ "]/scratchpad-msg", 0);
			mcdu.clearScratchpad(i);
		} else {
			var ci = int(scratchpad);
			var cis = size(scratchpad);
			if (cis >= 1 and cis <= 3) {
				if (ci != nil and ci >= 0 and ci <= 999) {
					setprop("/FMGC/internal/cost-index", ci);
					setprop("/FMGC/internal/cost-index-set", 1);
					mcdu.clearScratchpad(i);
				} else {
					notAllowed(i);
				}
			} else {
				notAllowed(i);
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
					notAllowed(i);
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
