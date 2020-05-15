# A3XX mCDU by Joshua Davidson (Octal450), Jonathan Redpath, and Matthew Maring (mattmaring)

# Copyright (c) 2020 Josh Davidson (Octal450)
# Copyright (c) 2020 Matthew Maring (mattmaring)

var perfTOInput = func(key, i) {
	var scratchpad = getprop("MCDU[" ~ i ~ "]/scratchpad");
	if (key == "L1") {
		if (getprop("FMGC/status/phase") != 1) {
			if (scratchpad == "CLR") {
				setprop("FMGC/internal/v1", 0);
				setprop("FMGC/internal/v1-set", 0);
				setprop("MCDU[" ~ i ~ "]/scratchpad-msg", 0);
				setprop("MCDU[" ~ i ~ "]/scratchpad", "");
			} else {
				var tfs = size(scratchpad);
				if (tfs == 3) {
					if (int(scratchpad) != nil and scratchpad >= 100 and scratchpad <= 350) {
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
		} else {
			notAllowed(i);
		}
	} else if (key == "L2") {
		if (getprop("FMGC/status/phase") != 1) {
			if (scratchpad == "CLR") {
				setprop("FMGC/internal/vr", 0);
				setprop("FMGC/internal/vr-set", 0);
				setprop("MCDU[" ~ i ~ "]/scratchpad-msg", 0);
				setprop("MCDU[" ~ i ~ "]/scratchpad", "");
			} else {
				var tfs = size(scratchpad);
				if (tfs == 3) {
					if (int(scratchpad) != nil and scratchpad >= 100 and scratchpad <= 350) {
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
		} else {
			notAllowed(i);
		}
	} else if (key == "L3") {
		if (getprop("FMGC/status/phase") != 1) {
			if (scratchpad == "CLR") {
				setprop("FMGC/internal/v2", 0);
				setprop("FMGC/internal/v2-set", 0);
				setprop("it-autoflight/settings/togaspd", 157);
				setprop("MCDU[" ~ i ~ "]/scratchpad-msg", 0);
				setprop("MCDU[" ~ i ~ "]/scratchpad", "");
			} else {
				var tfs = size(scratchpad);
				if (tfs == 3) {
					if (int(scratchpad) != nil and scratchpad >= 100 and scratchpad <= 350) {
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
		} else {
		notAllowed(i);
		}
	} else if (key == "L4") {
		if (scratchpad == "CLR") {
			setprop("FMGC/internal/trans-alt", 18000);
			setprop("MCDU[" ~ i ~ "]/scratchpad-msg", 0);
			setprop("MCDU[" ~ i ~ "]/scratchpad", "");
		} else {
			var tfs = size(scratchpad);
			if (int(scratchpad) != nil and (tfs == 4 or tfs <= 5) and scratchpad >= 1000 and scratchpad <= 39000) {
				setprop("FMGC/internal/trans-alt", int(scratchpad / 10) * 10);
				setprop("MCDU[" ~ i ~ "]/scratchpad", "");
			} else {
				notAllowed(i);
			}
		}
	} else if (key == "L5") {
		if (scratchpad == "CLR") {
			setprop("systems/thrust/clbreduc-ft", "1500");
			setprop("FMGC/internal/accel-agl-ft", "1500");
			setprop("MCDUC/thracc-set", 0);
			setprop("MCDU[" ~ i ~ "]/scratchpad-msg", 0);
			setprop("MCDU[" ~ i ~ "]/scratchpad", "");
		} else {
			var tfs = size(scratchpad);
			if (find("/", scratchpad) != -1) {
				var thracc = split("/", scratchpad);
				var thrred = thracc[0];
				var thrreds = size(thrred);
				var acc = thracc[1];
				var accs = size(acc);
				if (int(thrred) != nil and (thrreds >= 3 and thrreds <= 5) and thrred >= 400 and thrred <= 39000 and int(acc) != nil and (accs == 3 or accs == 4 or accs == 5) and acc >= 400 and acc <= 39000) {
					setprop("systems/thrust/clbreduc-ft", int(thrred / 10) * 10);
					setprop("FMGC/internal/accel-agl-ft", int(acc / 10) * 10);
					setprop("MCDUC/thracc-set", 1);
					setprop("MCDU[" ~ i ~ "]/scratchpad", "");
				} else if (thrreds == 0 and int(acc) != nil and (accs >= 3 and accs <= 5) and acc >= 400 and acc <= 39000) {
					setprop("FMGC/internal/accel-agl-ft", int(acc / 10) * 10);
					setprop("MCDU[" ~ i ~ "]/scratchpad", "");
				} else {
					notAllowed(i);
				}
			} else if (num(scratchpad) != nil and (tfs >= 3 and tfs <= 5) and scratchpad >= 400 and scratchpad <= 39000) {
				setprop("systems/thrust/clbreduc-ft", int(scratchpad / 10) * 10);
				setprop("MCDU[" ~ i ~ "]/scratchpad", "");
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
			if (find("/", scratchpad) != -1) {
				var flapths = split("/", scratchpad);
				var flap = flapths[0];
				var flaps = size(flap);
				var trim = flapths[1];
				var trims = size(trim);
				var trima = substr(trim, 2);
				var trimb = substr(trim, 0, 3);
				var validtrima = num(trima) != nil and num(trima) >= 0 and num(trima) <= 7.0;
				var validtrimb = num(trimb) != nil and num(trimb) >= 0 and num(trimb) <= 7.0;
				if (flaps == 0 and getprop("FMGC/internal/flap-ths-set")) {
					if (trims == 5 and find("DN", trim) != -1 and validtrima) {
						setprop("FMGC/internal/to-ths", -1 * trima);
						setprop("MCDU[" ~ i ~ "]/scratchpad", "");
					} else if (trims == 5 and find("DN", trim) != -1 and validtrimb) {
						setprop("FMGC/internal/to-ths", -1 * trimb);
						setprop("MCDU[" ~ i ~ "]/scratchpad", "");
					} else if (trims == 5 and find("UP", trim) != -1 and validtrima) {
						setprop("FMGC/internal/to-ths", trima);
						setprop("MCDU[" ~ i ~ "]/scratchpad", "");
					} else if (trims == 5 and find("UP", trim) != -1 and validtrimb) {
						setprop("FMGC/internal/to-ths", trimb);
						setprop("MCDU[" ~ i ~ "]/scratchpad", "");
					} else {
						notAllowed(i);
					}
				} else if (flaps == 1 and num(flap) != nil and flap >= 0 and flap <= 3) {
					if (trims == 5 and find("DN", trim) != -1 and validtrima) {
						setprop("FMGC/internal/to-flap", flap);
						setprop("FMGC/internal/to-ths", -1 * trima);
						setprop("FMGC/internal/flap-ths-set", 1);
						setprop("MCDU[" ~ i ~ "]/scratchpad", "");
					} else if (trims == 5 and find("DN", trim) != -1 and validtrimb) {
						setprop("FMGC/internal/to-flap", flap);
						setprop("FMGC/internal/to-ths", -1 * trimb);
						setprop("FMGC/internal/flap-ths-set", 1);
						setprop("MCDU[" ~ i ~ "]/scratchpad", "");
					} else if (trims == 5 and find("UP", trim) != -1 and validtrima) {
						setprop("FMGC/internal/to-flap", flap);
						setprop("FMGC/internal/to-ths", trima);
						setprop("FMGC/internal/flap-ths-set", 1);
						setprop("MCDU[" ~ i ~ "]/scratchpad", "");
					} else if (trims == 5 and find("UP", trim) != -1 and validtrimb) {
						setprop("FMGC/internal/to-flap", flap);
						setprop("FMGC/internal/to-ths", trimb);
						setprop("FMGC/internal/flap-ths-set", 1);
						setprop("MCDU[" ~ i ~ "]/scratchpad", "");
					} else {
						notAllowed(i);
					}
				} else {
					notAllowed(i);
				}
			} else if (size(scratchpad) == 1 and num(scratchpad) != nil and scratchpad >= 0 and scratchpad <= 3) {
				setprop("FMGC/internal/to-flap", scratchpad);
				if (!getprop("FMGC/internal/flap-ths-set")) {
					setprop("FMGC/internal/flap-ths-set", 1);
				}
				setprop("MCDU[" ~ i ~ "]/scratchpad", "");
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
				if (int(scratchpad) != nil and scratchpad >= 0 and scratchpad <= 99) {
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
			if (int(scratchpad) != nil and (tfs == 4 or tfs == 5) and scratchpad >= 1000 and scratchpad <= 39000) {
				setprop("FMGC/internal/eng-out-reduc", scratchpad);
				setprop("MCDUC/reducacc-set", 1);
				setprop("MCDU[" ~ i ~ "]/scratchpad", "");
			} else {
				notAllowed(i);
			}
		}
	} else if (key == "R6") {
		setprop("MCDU[" ~ i ~ "]/page", "PERFCLB");
	} 
}
