# Copyright (c) 2020 Matthew Maring (mattmaring)

var initInputIRS = func(key, i) {
	if (key == "up") {
		if (getprop("FMGC/internal/align-ref-lat-edit")) {
			if (num(getprop("FMGC/internal/align-ref-lat-minutes")) == 180) {
				if (getprop("FMGC/internal/align-ref-lat-sign") == "N") {
					setprop("FMGC/internal/align-ref-lat-sign", "S");
				} else {
					setprop("FMGC/internal/align-ref-lat-sign", "N");
				}
			} else if (num(getprop("FMGC/internal/align-ref-lat-minutes")) == 59.9) {
				setprop("FMGC/internal/align-ref-lat-degrees", getprop("FMGC/internal/align-ref-lat-degrees") + 1);
				setprop("FMGC/internal/align-ref-lat-minutes", 0.0);
			} else {
				setprop("FMGC/internal/align-ref-lat-minutes", getprop("FMGC/internal/align-ref-lat-minutes") + 0.1);
			}
		} else if (getprop("FMGC/internal/align-ref-long-edit")) {
			if (num(getprop("FMGC/internal/align-ref-long-minutes")) == 180) {
				if (getprop("FMGC/internal/align-ref-long-sign") == "W") {
					setprop("FMGC/internal/align-ref-long-sign", "E");
				} else {
					setprop("FMGC/internal/align-ref-long-sign", "W");
				}
			} else if (num(getprop("FMGC/internal/align-ref-long-minutes")) == 59.9) {
				setprop("FMGC/internal/align-ref-long-degrees", getprop("FMGC/internal/align-ref-long-degrees") + 1);
				setprop("FMGC/internal/align-ref-long-minutes", 0.0);
			} else {
				setprop("FMGC/internal/align-ref-long-minutes", getprop("FMGC/internal/align-ref-long-minutes") + 0.1);
			}
		} else {
			mcdu_message(i, "NOT ALLOWED");
		}
	} else if (key == "down") {
		if (getprop("FMGC/internal/align-ref-lat-edit")) {
			if (num(getprop("FMGC/internal/align-ref-lat-minutes")) == 0) {
				if (getprop("FMGC/internal/align-ref-lat-sign") == "N") {
					setprop("FMGC/internal/align-ref-lat-sign", "S");
				} else {
					setprop("FMGC/internal/align-ref-lat-sign", "N");
				}
			} else if (num(getprop("FMGC/internal/align-ref-lat-minutes")) == 0) {
				setprop("FMGC/internal/align-ref-lat-degrees", getprop("FMGC/internal/align-ref-lat-degrees") - 1);
				setprop("FMGC/internal/align-ref-lat-minutes", 59.9);
			} else {
				setprop("FMGC/internal/align-ref-lat-minutes", getprop("FMGC/internal/align-ref-lat-minutes") - 0.1);
			}
		} else if (getprop("FMGC/internal/align-ref-long-edit")) {
			if (num(getprop("FMGC/internal/align-ref-long-minutes")) == 0) {
				if (getprop("FMGC/internal/align-ref-long-sign") == "W") {
					setprop("FMGC/internal/align-ref-long-sign", "E");
				} else {
					setprop("FMGC/internal/align-ref-long-sign", "W");
				}
			} else if (num(getprop("FMGC/internal/align-ref-long-minutes")) == 0) {
				setprop("FMGC/internal/align-ref-long-degrees", getprop("FMGC/internal/align-ref-long-degrees") - 1);
				setprop("FMGC/internal/align-ref-long-minutes", 59.9);
			} else {
				setprop("FMGC/internal/align-ref-long-minutes", getprop("FMGC/internal/align-ref-long-minutes") - 0.1);
			}
		} else {
			mcdu_message(i, "NOT ALLOWED");
		}
	} else if (key == "L1") {
		if (fmgc.FMGCInternal.toFromSet) {
			setprop("FMGC/internal/align-ref-lat-edit", 1);
			setprop("FMGC/internal/align-ref-long-edit", 0);
		} else {
			mcdu_message(i, "NOT ALLOWED");
		}
	} else if (key == "L6") {
		setprop("FMGC/internal/align-ref-lat-edit", 0);
		setprop("FMGC/internal/align-ref-long-edit", 0);
		setprop("MCDU[" ~ i ~ "]/page", "INITA");
	} else if (key == "R1") {
		if (fmgc.FMGCInternal.toFromSet) {
			setprop("FMGC/internal/align-ref-lat-edit", 0);
			setprop("FMGC/internal/align-ref-long-edit", 1);
		} else {
			mcdu_message(i, "NOT ALLOWED");
		}
	} else if (key == "R6") {
		setprop("FMGC/internal/align-ref-lat-edit", 0);
		setprop("FMGC/internal/align-ref-long-edit", 0);
		if (fmgc.FMGCInternal.toFromSet and getprop("/systems/navigation/adr/any-adr-on") == 1) {
			if (getprop("FMGC/internal/align-set") == 0) {
				setprop("FMGC/internal/align-set", 1);
			} else {
				setprop("/controls/adirs/mcducbtn", 1);
				setprop("FMGC/internal/align-set", 0);
				setprop("MCDU[" ~ i ~ "]/page", "INITA");
			}
		} else if (!fmgc.FMGCInternal.toFromSet) {
			# setprop("MCDU[" ~ i ~ "]/scratchpad", "SELECT REFERENCE");
		} else if (getprop("/systems/navigation/adr/any-adr-on") == 0) {
			# setprop("MCDU[" ~ i ~ "]/scratchpad", "IRS NOT ALIGNED");
		} else {
			mcdu_message(i, "NOT ALLOWED");
		}
	}
}
