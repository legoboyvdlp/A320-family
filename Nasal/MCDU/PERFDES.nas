# A3XX mCDU by Joshua Davidson (Octal450), Jonathan Redpath, and Matthew Maring (hayden2000)

# Copyright (c) 2020 Matthew Maring (hayden2000)

var perfDESInput = func(key, i) {
	var scratchpad = getprop("MCDU[" ~ i ~ "]/scratchpad");
	if (key == "L2") {
		if (scratchpad == "CLR") {
			setprop("FMGC/internal/cost-index", 0);
			setprop("FMGC/internal/cost-index-set", 0);
			setprop("MCDU[" ~ i ~ "]/scratchpad-msg", 0);
			setprop("MCDU[" ~ i ~ "]/scratchpad", "");
		} else {
			var ci = int(scratchpad);
			var cis = size(scratchpad);
			if (cis >= 1 and cis <= 3) {
				if (ci != nil and ci >= 0 and ci <= 999) {
					setprop("FMGC/internal/cost-index", ci);
					setprop("FMGC/internal/cost-index-set", 1);
					setprop("MCDU[" ~ i ~ "]/scratchpad", "");
				} else {
					notAllowed(i);
				}
			} else {
				notAllowed(i);
			}
		}
	} else if (key == "L6") {
		setprop("MCDU[" ~ i ~ "]/page", "CRZ");
	} else if (key == "R6") {
		setprop("MCDU[" ~ i ~ "]/page", "APPR");
	}
}
