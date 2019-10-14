# A3XX mCDU by Joshua Davidson (Octal450) and Jonathan Redpath

# Copyright (c) 2019 Joshua Davidson (Octal450)

var radnavInput = func(key, i) {
	var scratchpad = getprop("/MCDU[" ~ i ~ "]/scratchpad");
	if (key == "L1") {
		if (scratchpad == "CLR") {
			setprop("/FMGC/internal/vor1freq-set", 0);
			setprop("/MCDU[" ~ i ~ "]/scratchpad-msg", 0);
			setprop("/MCDU[" ~ i ~ "]/scratchpad", "");
		} else {
			var tfs = size(scratchpad);
			if (tfs == 3 or tfs == 5 or tfs == 6) {
				if (scratchpad >= 108.00 and scratchpad <= 111.95) {
					if (scratchpad == 108.10 or scratchpad == 108.15 or scratchpad == 108.30 or scratchpad == 108.35 or scratchpad == 108.50 or scratchpad == 108.55 or scratchpad == 108.70 or scratchpad == 108.75 or scratchpad == 108.90 or scratchpad == 108.95 
					or scratchpad == 109.10 or scratchpad == 109.15 or scratchpad == 109.30 or scratchpad == 109.35 or scratchpad == 109.50 or scratchpad == 109.55 or scratchpad == 109.70 or scratchpad == 109.75 or scratchpad == 109.90 or scratchpad == 109.95 
					or scratchpad == 110.10 or scratchpad == 110.15 or scratchpad == 110.30 or scratchpad == 110.35 or scratchpad == 110.50 or scratchpad == 110.55 or scratchpad == 110.70 or scratchpad == 110.75 or scratchpad == 110.90 or scratchpad == 110.95 
					or scratchpad == 111.10 or scratchpad == 111.15 or scratchpad == 111.30 or scratchpad == 111.35 or scratchpad == 111.50 or scratchpad == 111.55 or scratchpad == 111.70 or scratchpad == 111.75 or scratchpad == 111.90 or scratchpad == 111.95) {
						notAllowed(i);
					} else {
						setprop("/instrumentation/nav[2]/frequencies/selected-mhz", scratchpad);
						setprop("/FMGC/internal/vor1freq-set", 1);
						setprop("/MCDU[" ~ i ~ "]/scratchpad", "");
					}
				} else if (scratchpad >= 112.00 and scratchpad <= 117.95) {
					setprop("/instrumentation/nav[2]/frequencies/selected-mhz", scratchpad);
					setprop("/FMGC/internal/vor1freq-set", 1);
					setprop("/MCDU[" ~ i ~ "]/scratchpad", "");
				} else {
					notAllowed(i);
				}
			} else {
				notAllowed(i);
			}
		}
	} else if (key == "L2") {
		if (scratchpad == "CLR") {
			setprop("/FMGC/internal/vor1crs-set", 0);
			setprop("/MCDU[" ~ i ~ "]/scratchpad-msg", 0);
			setprop("/MCDU[" ~ i ~ "]/scratchpad", "");
		} else {
			var tfs = size(scratchpad);
			if (tfs >= 1 and tfs <= 3) {
				if (scratchpad >= 0 and scratchpad <= 360) {
					setprop("/instrumentation/nav[2]/radials/selected-deg", scratchpad);
					setprop("/FMGC/internal/vor1crs-set", 1);
					setprop("/MCDU[" ~ i ~ "]/scratchpad", "");
				} else {
					notAllowed(i);
				}
			} else {
				notAllowed(i);
			}
		}
	} else if (key == "L3") {
		if (scratchpad == "CLR") {
			setprop("/FMGC/internal/ils1freq-set", 0);
			setprop("/MCDU[" ~ i ~ "]/scratchpad-msg", 0);
			setprop("/MCDU[" ~ i ~ "]/scratchpad", "");
		} else {
			var tfs = size(scratchpad);
			if (tfs == 3 or tfs == 5 or tfs == 6) {
				if (scratchpad >= 108.00 and scratchpad <= 111.95) {
					if (scratchpad == 108.10 or scratchpad == 108.15 or scratchpad == 108.30 or scratchpad == 108.35 or scratchpad == 108.50 or scratchpad == 108.55 or scratchpad == 108.70 or scratchpad == 108.75 or scratchpad == 108.90 or scratchpad == 108.95 
					or scratchpad == 109.10 or scratchpad == 109.15 or scratchpad == 109.30 or scratchpad == 109.35 or scratchpad == 109.50 or scratchpad == 109.55 or scratchpad == 109.70 or scratchpad == 109.75 or scratchpad == 109.90 or scratchpad == 109.95 
					or scratchpad == 110.10 or scratchpad == 110.15 or scratchpad == 110.30 or scratchpad == 110.35 or scratchpad == 110.50 or scratchpad == 110.55 or scratchpad == 110.70 or scratchpad == 110.75 or scratchpad == 110.90 or scratchpad == 110.95 
					or scratchpad == 111.10 or scratchpad == 111.15 or scratchpad == 111.30 or scratchpad == 111.35 or scratchpad == 111.50 or scratchpad == 111.55 or scratchpad == 111.70 or scratchpad == 111.75 or scratchpad == 111.90 or scratchpad == 111.95) {
						setprop("/instrumentation/nav[0]/frequencies/selected-mhz", scratchpad);
						setprop("/FMGC/internal/ils1freq-set", 1);
						setprop("/MCDU[" ~ i ~ "]/scratchpad", "");
					} else {
						notAllowed(i);
					}
				} else {
					notAllowed(i);
				}
			} else {
				notAllowed(i);
			}
		}
	} else if (key == "L4") {
		if (scratchpad == "CLR") {
			setprop("/FMGC/internal/ils1crs-set", 0);
			setprop("/MCDU[" ~ i ~ "]/scratchpad-msg", 0);
			setprop("/MCDU[" ~ i ~ "]/scratchpad", "");
		} else {
			var tfs = size(scratchpad);
			if (tfs >= 1 and tfs <= 3) {
				if (scratchpad >= 0 and scratchpad <= 360) {
					setprop("/instrumentation/nav[0]/radials/selected-deg", scratchpad);
					setprop("/FMGC/internal/ils1crs-set", 1);
					setprop("/MCDU[" ~ i ~ "]/scratchpad", "");
				} else {
					notAllowed(i);
				}
			} else {
				notAllowed(i);
			}
		}
	} else if (key == "L5") {
		if (scratchpad == "CLR") {
			setprop("/FMGC/internal/adf1freq-set", 0);
			setprop("/MCDU[" ~ i ~ "]/scratchpad-msg", 0);
			setprop("/MCDU[" ~ i ~ "]/scratchpad", "");
		} else {
			var tfs = size(scratchpad);
			if (tfs == 3 or tfs == 4) {
				if (scratchpad >= 190 and scratchpad <= 1750) {
					setprop("/instrumentation/adf[0]/frequencies/selected-khz", scratchpad);
					setprop("/FMGC/internal/adf1freq-set", 1);
					setprop("/MCDU[" ~ i ~ "]/scratchpad", "");
				} else {
					notAllowed(i);
				}
			} else {
				notAllowed(i);
			}
		}
	} else if (key == "R1") {
		if (scratchpad == "CLR") {
			setprop("/FMGC/internal/vor2freq-set", 0);
			setprop("/MCDU[" ~ i ~ "]/scratchpad-msg", 0);
			setprop("/MCDU[" ~ i ~ "]/scratchpad", "");
		} else {
			var tfs = size(scratchpad);
			if (tfs == 3 or tfs == 5 or tfs == 6) {
				if (scratchpad >= 108.10 and scratchpad <= 111.95) {
					if (scratchpad == 108.10 or scratchpad == 108.15 or scratchpad == 108.30 or scratchpad == 108.35 or scratchpad == 108.50 or scratchpad == 108.55 or scratchpad == 108.70 or scratchpad == 108.75 or scratchpad == 108.90 or scratchpad == 108.95 
					or scratchpad == 109.10 or scratchpad == 109.15 or scratchpad == 109.30 or scratchpad == 109.35 or scratchpad == 109.50 or scratchpad == 109.55 or scratchpad == 109.70 or scratchpad == 109.75 or scratchpad == 109.90 or scratchpad == 109.95 
					or scratchpad == 110.10 or scratchpad == 110.15 or scratchpad == 110.30 or scratchpad == 110.35 or scratchpad == 110.50 or scratchpad == 110.55 or scratchpad == 110.70 or scratchpad == 110.75 or scratchpad == 110.90 or scratchpad == 110.95 
					or scratchpad == 111.10 or scratchpad == 111.15 or scratchpad == 111.30 or scratchpad == 111.35 or scratchpad == 111.50 or scratchpad == 111.55 or scratchpad == 111.70 or scratchpad == 111.75 or scratchpad == 111.90 or scratchpad == 111.95) {
						notAllowed(i);
					} else {
						setprop("/instrumentation/nav[3]/frequencies/selected-mhz", scratchpad);
						setprop("/FMGC/internal/vor2freq-set", 1);
						setprop("/MCDU[" ~ i ~ "]/scratchpad", "");
					}
				} else if (scratchpad >= 112.00 and scratchpad <= 117.95) {
					setprop("/instrumentation/nav[3]/frequencies/selected-mhz", scratchpad);
					setprop("/FMGC/internal/vor2freq-set", 1);
					setprop("/MCDU[" ~ i ~ "]/scratchpad", "");
				} else {
					notAllowed(i);
				}
			} else {
				notAllowed(i);
			}
		}
	} else if (key == "R2") {
		if (scratchpad == "CLR") {
			setprop("/FMGC/internal/vor2crs-set", 0);
			setprop("/MCDU[" ~ i ~ "]/scratchpad-msg", 0);
			setprop("/MCDU[" ~ i ~ "]/scratchpad", "");
		} else {
			var tfs = size(scratchpad);
			if (tfs >= 1 and tfs <= 3) {
				if (scratchpad >= 0 and scratchpad <= 360) {
					setprop("/instrumentation/nav[3]/radials/selected-deg", scratchpad);
					setprop("/FMGC/internal/vor2crs-set", 1);
					setprop("/MCDU[" ~ i ~ "]/scratchpad", "");
				} else {
					notAllowed(i);
				}
			} else {
				notAllowed(i);
			}
		}
	} else if (key == "R5") {
		if (scratchpad == "CLR") {
			setprop("/FMGC/internal/adf2freq-set", 0);
			setprop("/MCDU[" ~ i ~ "]/scratchpad-msg", 0);
			setprop("/MCDU[" ~ i ~ "]/scratchpad", "");
		} else {
			var tfs = size(scratchpad);
			if (tfs == 3 or tfs == 4) {
				if (scratchpad >= 190 and scratchpad <= 1750) {
					setprop("/instrumentation/adf[1]/frequencies/selected-khz", scratchpad);
					setprop("/FMGC/internal/adf2freq-set", 1);
					setprop("/MCDU[" ~ i ~ "]/scratchpad", "");
				} else {
					notAllowed(i);
				}
			} else {
				notAllowed(i);
			}
		}
	}
}
