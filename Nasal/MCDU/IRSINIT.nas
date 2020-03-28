# Copyright (c) 2020 Matthew Maring (hayden2000)

var initInputIRS = func(key, i) {
	if (key == "L6") {
		setprop("MCDU[" ~ i ~ "]/page", "INITA");
	} else if (key == "R6") {
		if (getprop("FMGC/internal/tofrom-set") == 1 and getprop("systems/navigation/adr/any-adr-on") == 1) {
			if (getprop("FMGC/internal/align-set") == 0) {
				setprop("FMGC/internal/align-set", 1);
			} else {
				setprop("controls/adirs/mcducbtn", 1);
				setprop("MCDU[" ~ i ~ "]/page", "INITA");
			}
		} else if (getprop("FMGC/internal/tofrom-set") == 0) {
			if (getprop("MCDU[" ~ i ~ "]/scratchpad") != "SELECT REFERENCE") {
				if (getprop("MCDU[" ~ i ~ "]/scratchpad-msg") == 1) {
					setprop("MCDU[" ~ i ~ "]/last-scratchpad", "");
				} else {
					setprop("MCDU[" ~ i ~ "]/last-scratchpad", getprop("MCDU[" ~ i ~ "]/scratchpad"));
				}
			}
			setprop("MCDU[" ~ i ~ "]/scratchpad-msg", 1);
			setprop("MCDU[" ~ i ~ "]/scratchpad", "SELECT REFERENCE");
		} else if (getprop("systems/navigation/adr/any-adr-on") == 0) {
			if (getprop("MCDU[" ~ i ~ "]/scratchpad") != "IRS NOT ALIGNED") {
				if (getprop("MCDU[" ~ i ~ "]/scratchpad-msg") == 1) {
					setprop("MCDU[" ~ i ~ "]/last-scratchpad", "");
				} else {
					setprop("MCDU[" ~ i ~ "]/last-scratchpad", getprop("MCDU[" ~ i ~ "]/scratchpad"));
				}
			}
			setprop("MCDU[" ~ i ~ "]/scratchpad-msg", 1);
			setprop("MCDU[" ~ i ~ "]/scratchpad", "IRS NOT ALIGNED");
		} else {
			notAllowed(i);
		}
	}
}
