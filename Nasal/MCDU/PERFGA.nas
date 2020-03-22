# Copyright (c) 2020 Matthew Maring (hayden2000)

# uses universal values, will implement separately once FPLN is finished

var perfGAInput = func(key, i) {
	if (key == "L5") {
		if (scratchpad == "CLR") {
			setprop("systems/thrust/clbreduc-ft", "1500");
			setprop("FMGC/internal/reduc-agl-ft", "1500");
			setprop("MCDUC/thracc-set", 0);
			setprop("MCDU[" ~ i ~ "]/scratchpad-msg", 0);
			setprop("MCDU[" ~ i ~ "]/scratchpad", "");
		} else {
			var tfs = size(scratchpad);
			if (tfs >= 7 and tfs <= 9 and find("/", scratchpad) != -1) {
				var thracc = split("/", scratchpad);
				var thrred = size(thracc[0]);
				var acc = size(thracc[1]);
				if ((thrred >= 3 and thrred <= 5) and (acc >= 3 and acc <= 5)) {
					setprop("systems/thrust/clbreduc-ft", thracc[0]);
					setprop("FMGC/internal/reduc-agl-ft", thracc[1]);
					setprop("MCDUC/thracc-set", 1);
					setprop("MCDU[" ~ i ~ "]/scratchpad", "");
				} else {
					notAllowed(i);
				}
			} else {
				notAllowed(i);
			}
		}
	} else if (key == "L6") {
		setprop("MCDU[" ~ i ~ "]/page", "APPR");
	} else if (key == "R5") {
		if (scratchpad == "CLR") {
			setprop("FMGC/internal/eng-out-reduc", "1500");
			setprop("MCDUC/reducacc-set", 0);
			setprop("MCDU[" ~ i ~ "]/scratchpad-msg", 0);
			setprop("MCDU[" ~ i ~ "]/scratchpad", "");
		} else {
			var tfs = size(scratchpad);
			if (tfs >= 3 and tfs <= 5) {
				setprop("FMGC/internal/eng-out-reduc", scratchpad);
				setprop("MCDUC/reducacc-set", 1);
				setprop("MCDU[" ~ i ~ "]/scratchpad", "");
			} else {
				notAllowed(i);
			}
		}
	}
}