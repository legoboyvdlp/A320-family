# Copyright (c) 2020 Matthew Maring (mattmaring)

# uses universal values, will implement separately once FPLN is finished

var perfGAInput = func(key, i) {
	var scratchpad = mcdu_scratchpad.scratchpads[i].scratchpad;
	if (key == "L5") {
		if (scratchpad == "CLR") {
			setprop("/systems/thrust/clbreduc-ft", 1500);
			setprop("/FMGC/internal/accel-agl-ft", 1500);
			setprop("MCDUC/thracc-set", 0);
			mcdu_scratchpad.scratchpads[i].empty();
		} else {
			var tfs = size(scratchpad);
			if (tfs >= 7 and tfs <= 9 and find("/", scratchpad) != -1) {
				var thracc = split("/", scratchpad);
				var thrred = size(thracc[0]);
				var acc = size(thracc[1]);
				if (int(thrred) != nil and int(acc) != nil and (thrred >= 3 and thrred <= 5) and (acc >= 3 and acc <= 5)) {
					setprop("/systems/thrust/clbreduc-ft", thracc[0]);
					setprop("/FMGC/internal/accel-agl-ft", thracc[1]);
					setprop("MCDUC/thracc-set", 1);
					mcdu_scratchpad.scratchpads[i].empty();
				} else {
					mcdu_message(i, "NOT ALLOWED");
				}
			} else {
				mcdu_message(i, "NOT ALLOWED");
			}
		}
	} else if (key == "L6") {
		setprop("MCDU[" ~ i ~ "]/page", "PERFAPPR");
	} else if (key == "R5") {
		if (scratchpad == "CLR") {
			setprop("/FMGC/internal/eng-out-reduc", "1500");
			setprop("MCDUC/reducacc-set", 0);
			mcdu_scratchpad.scratchpads[i].empty();
		} else {
			var tfs = size(scratchpad);
			if (int(scratchpad) != nil and tfs >= 3 and tfs <= 5) {
				setprop("/FMGC/internal/eng-out-reduc", scratchpad);
				setprop("MCDUC/reducacc-set", 1);
				mcdu_scratchpad.scratchpads[i].empty();
			} else {
				mcdu_message(i, "NOT ALLOWED");
			}
		}
	}
}