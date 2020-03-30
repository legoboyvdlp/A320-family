# A3XX mCDU by Joshua Davidson (Octal450), Jonathan Redpath, and Matthew Maring (hayden2000)

# Copyright (c) 2019 Joshua Davidson (Octal450)
# Copyright (c) 2020 Matthew Maring (hayden2000)

var perfTOInput = func(key, i) {
	var scratchpad = getprop("MCDU[" ~ i ~ "]/scratchpad");
	if (key == "L1") {
		if (scratchpad == "CLR") {
			setprop("FMGC/internal/v1", 0);
			setprop("FMGC/internal/v1-set", 0);
			setprop("MCDU[" ~ i ~ "]/scratchpad-msg", 0);
			setprop("MCDU[" ~ i ~ "]/scratchpad", "");
		} else {
			var tfs = size(scratchpad);
			if (tfs == 3) {
				if (int(scratchpad) != nil and scratchpad >= 100 and scratchpad <= 200) {
					setprop("FMGC/internal/v1", scratchpad);
					setprop("FMGC/internal/v1-set", 1);
					setprop("MCDU[" ~ i ~ "]/scratchpad", "");
				} else {
					notAllowed(i);
				}
			} else {
				notAllowed(i);
			}
		}
	} else if (key == "L2") {
		if (scratchpad == "CLR") {
			setprop("FMGC/internal/vr", 0);
			setprop("FMGC/internal/vr-set", 0);
			setprop("MCDU[" ~ i ~ "]/scratchpad-msg", 0);
			setprop("MCDU[" ~ i ~ "]/scratchpad", "");
		} else {
			var tfs = size(scratchpad);
			if (tfs == 3) {
				if (int(scratchpad) != nil and scratchpad >= 100 and scratchpad <= 200) {
					setprop("FMGC/internal/vr", scratchpad);
					setprop("FMGC/internal/vr-set", 1);
					setprop("MCDU[" ~ i ~ "]/scratchpad", "");
				} else {
					notAllowed(i);
				}
			} else {
				notAllowed(i);
			}
		}
	} else if (key == "L3") {
		if (scratchpad == "CLR") {
			setprop("FMGC/internal/v2", 0);
			setprop("FMGC/internal/v2-set", 0);
			setprop("it-autoflight/settings/togaspd", 157);
			setprop("MCDU[" ~ i ~ "]/scratchpad-msg", 0);
			setprop("MCDU[" ~ i ~ "]/scratchpad", "");
		} else {
			var tfs = size(scratchpad);
			if (tfs == 3) {
				if (int(scratchpad) != nil and scratchpad >= 100 and scratchpad <= 200) {
					setprop("FMGC/internal/v2", scratchpad);
					setprop("FMGC/internal/v2-set", 1);
					setprop("it-autoflight/settings/togaspd", scratchpad);
					setprop("MCDU[" ~ i ~ "]/scratchpad", "");
				} else {
					notAllowed(i);
				}
			} else {
				notAllowed(i);
			}
		}
	} else if (key == "L4") {
		if (scratchpad == "CLR") {
			setprop("FMGC/internal/trans-alt", 18000);
			setprop("MCDU[" ~ i ~ "]/scratchpad", "");
		} else {
			var tfs = size(scratchpad);
			if (tfs == 4 or tfs == 5) {
				if (int(scratchpad) != nil and scratchpad >= 1000 and scratchpad <= 18000) {
					setprop("FMGC/internal/trans-alt", scratchpad);
					setprop("MCDU[" ~ i ~ "]/scratchpad", "");
				} else {
					notAllowed(i);
				}
			} else {
				notAllowed(i);
			}
		}
	} else if (key == "L5") {
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
				if (int(thrred) != nil and int(acc) != nil and (thrred >= 3 and thrred <= 5) and (acc >= 3 and acc <= 5)) {
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
	} else if (key == "R3") {
		if (scratchpad == "CLR") {
			setprop("FMGC/internal/to-flap", 0);
			setprop("FMGC/internal/to-ths", "0.0");
			setprop("FMGC/internal/flap-ths-set", 0);
			setprop("MCDU[" ~ i ~ "]/scratchpad-msg", 0);
			setprop("MCDU[" ~ i ~ "]/scratchpad", "");
		} else {
			var tfs = size(scratchpad);
			if (tfs == 7 and find("/UP", scratchpad) != -1) {
				var flapths = split("/UP", scratchpad);
				var flap = int(flapths[0]);
				var trim = num(flapths[1]);
				if (flap != nil and trim != nil and (flap >= 1 and flap <= 4) and (trim >= 0.0 and trim <= 2.5)) {
					setprop("FMGC/internal/to-flap", flap);
					setprop("FMGC/internal/to-ths", trim);
					setprop("FMGC/internal/flap-ths-set", 1);
					setprop("MCDU[" ~ i ~ "]/scratchpad", "");
				} else {
					notAllowed(i);
				}
			} else if (tfs == 7 and find("/DN", scratchpad) != -1) {
				var flapths = split("/DN", scratchpad);
				var flap = int(flapths[0]);
				var trim = num(flapths[1]);
				if (flap != nil and trim != nil and (flap >= 1 and flap <= 4) and (trim > 0 and trim <= 2.5)) {
					setprop("FMGC/internal/to-flap", flap);
					setprop("FMGC/internal/to-ths", -1 * trim);
					setprop("FMGC/internal/flap-ths-set", 1);
					setprop("MCDU[" ~ i ~ "]/scratchpad", "");
				} else {
					notAllowed(i);
				}
			} else if (tfs == 1) {
				if (int(scratchpad) != nil and scratchpad >= 1 and scratchpad <= 4) {
					setprop("FMGC/internal/to-flap", scratchpad);
					setprop("FMGC/internal/flap-ths-set", 1);
					setprop("MCDU[" ~ i ~ "]/scratchpad", "");
				} else {
					notAllowed(i);
				}
			} else {
				notAllowed(i);
			}
		}
	} else if (key == "R4") {
		if (scratchpad == "CLR") {
			setprop("FMGC/internal/flex", 0);
			setprop("FMGC/internal/flex-set", 0);
			setprop("MCDU[" ~ i ~ "]/scratchpad-msg", 0);
			setprop("MCDU[" ~ i ~ "]/scratchpad", "");
		} else {
			var tfs = size(scratchpad);
			if (tfs == 1 or tfs == 2) {
				if (int(scratchpad) != nil and scratchpad >= 0 and scratchpad <= 70) {
					setprop("FMGC/internal/flex", scratchpad);
					setprop("FMGC/internal/flex-set", 1);
					var flex_calc = getprop("FMGC/internal/flex") - getprop("environment/temperature-degc");
					setprop("FMGC/internal/flex-cmd", flex_calc);
					setprop("MCDU[" ~ i ~ "]/scratchpad", "");
				} else {
					notAllowed(i);
				}
			} else {
				notAllowed(i);
			}
		}
	} else if (key == "R5") {
		if (scratchpad == "CLR") {
			setprop("FMGC/internal/eng-out-reduc", "1500");
			setprop("MCDUC/reducacc-set", 0);
			setprop("MCDU[" ~ i ~ "]/scratchpad-msg", 0);
			setprop("MCDU[" ~ i ~ "]/scratchpad", "");
		} else {
			var tfs = size(scratchpad);
			if (int(scratchpad) != nil and tfs >= 3 and tfs <= 5) {
				setprop("FMGC/internal/eng-out-reduc", scratchpad);
				setprop("MCDUC/reducacc-set", 1);
				setprop("MCDU[" ~ i ~ "]/scratchpad", "");
			} else {
				notAllowed(i);
			}
		}
	} else if (key == "R6") {
		setprop("MCDU[" ~ i ~ "]/page", "CLB");
	} 
}
