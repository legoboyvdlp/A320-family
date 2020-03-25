# A3XX mCDU by Joshua Davidson (Octal450), Jonathan Redpath, and Matthew Maring (hayden2000)

# Copyright (c) 2019 Joshua Davidson (Octal450)
# Copyright (c) 2020 Matthew Maring (hayden2000)

var initInputA = func(key, i) {
	var scratchpad = getprop("MCDU[" ~ i ~ "]/scratchpad");
	if (key == "L2") {
	    if (scratchpad == "CLR") {
	        setprop("FMGC/internal/alt-airport", "");
			setprop("MCDU[" ~ i ~ "]/scratchpad-msg", 0);
			setprop("MCDU[" ~ i ~ "]/scratchpad", "");
			fmgc.updateARPT();
	    } else if (scratchpad == "") {
	        setprop("FMGC/internal/alt-selected", 1);
	        setprop("MCDU[" ~ i ~ "]/page", "ROUTESELECTION");
	    } else if (getprop("FMGC/internal/tofrom-set") == 1) {
	        var tfs = size(scratchpad);
			if (tfs == 4) {
				setprop("FMGC/internal/alt-airport", scratchpad);
				setprop("MCDU[" ~ i ~ "]/scratchpad", "");
				fmgc.updateARPT();
				setprop("FMGC/internal/alt-selected", 1);
				setprop("MCDU[" ~ i ~ "]/page", "ROUTESELECTION");
			} else {
                notAllowed(i);
            }
	    } else {
	        notAllowed(i);
	    }
	} else if (key == "L3") {
		if (scratchpad == "CLR") {
			setprop("MCDUC/flight-num", "");
			setprop("MCDUC/flight-num-set", 0);
			setprop("MCDU[" ~ i ~ "]/scratchpad-msg", 0);
			setprop("MCDU[" ~ i ~ "]/scratchpad", "");
		} else {
			var flts = size(scratchpad);
			if (flts >= 1 and flts <= 8) {
				setprop("MCDUC/flight-num", scratchpad);
				setprop("MCDUC/flight-num-set", 1);
				setprop("MCDU[" ~ i ~ "]/scratchpad", "");
			} else {
				notAllowed(i);
			}
		}
	} else if (key == "L5") {
		if (scratchpad == "CLR") {
			setprop("FMGC/internal/cost-index", 0);
			setprop("FMGC/internal/cost-index-set", 0);
			setprop("MCDU[" ~ i ~ "]/scratchpad-msg", 0);
			setprop("MCDU[" ~ i ~ "]/scratchpad", "");
		} else {
			var ci = int(scratchpad);
			var cis = size(scratchpad);
			if (cis >= 1 and cis <= 3) {
				if (ci == nil) {
					notAllowed(i);
				} else if (ci >= 0 and ci <= 999) {
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
		if (scratchpad == "CLR") {
			setprop("FMGC/internal/cruise-ft", 10000);
			setprop("FMGC/internal/cruise-fl", 100);
			setprop("FMGC/internal/cruise-lvl-set", 0);
			setprop("MCDU[" ~ i ~ "]/scratchpad-msg", 0);
			setprop("MCDU[" ~ i ~ "]/scratchpad", "");
		} else {
			var crz = int(scratchpad);
			var crzs = size(scratchpad);
			if (crzs >= 1 and crzs <= 3) {
				if (crz == nil) {
					notAllowed(i);
				} else if (crz > 0 and crz <= 430) {
					setprop("FMGC/internal/cruise-ft", crz * 100);
					setprop("FMGC/internal/cruise-fl", crz);
					setprop("FMGC/internal/cruise-lvl-set", 1);
					setprop("MCDU[" ~ i ~ "]/scratchpad", "");
				} else {
					notAllowed(i);
				}
			} else {
				notAllowed(i);
			}
		}
	} else if (key == "R1") {
		if (scratchpad == "CLR") {
			setprop("FMGC/internal/dep-arpt", "");
			setprop("FMGC/internal/arr-arpt", "");
			setprop("FMGC/internal/tofrom-set", 0);
			fmgc.updateARPT();
			setprop("MCDU[" ~ i ~ "]/scratchpad-msg", 0);
			setprop("MCDU[" ~ i ~ "]/scratchpad", "");
		} else if (scratchpad == "") {
		    setprop("FMGC/internal/alt-selected", 0);
		    setprop("MCDU[" ~ i ~ "]/page", "ROUTESELECTION");
		} else {
			var tfs = size(scratchpad);
			if (tfs == 9 and find("/", scratchpad) != -1) {
				var fromto = split("/", scratchpad);
				var froms = size(fromto[0]);
				var tos = size(fromto[1]);
				if (froms == 4 and tos == 4) {
					setprop("FMGC/internal/dep-arpt", fromto[0]);
					setprop("FMGC/internal/arr-arpt", fromto[1]);
					setprop("FMGC/internal/tofrom-set", 1);
					setprop("MCDU[" ~ i ~ "]/scratchpad", "");
					fmgc.updateARPT();
					setprop("FMGC/internal/alt-selected", 0);
					setprop("MCDU[" ~ i ~ "]/page", "ROUTESELECTION");
				} else {
					notAllowed(i);
				}
			} else {
				notAllowed(i);
			}
		}
	} else if (key == "R3") {
		setprop("MCDU[" ~ i ~ "]/page", "IRSINIT");
	} else if (key == "R6") {
		if (scratchpad == "CLR") {
			setprop("FMGC/internal/tropo", 36090);
			setprop("FMGC/internal/tropo-set", 0);
			setprop("MCDU[" ~ i ~ "]/scratchpad-msg", 0);
			setprop("MCDU[" ~ i ~ "]/scratchpad", "");
		} else {
			var tropo = size(scratchpad);
			if (tropo == 5 and scratchpad <= 99990) {
				setprop("FMGC/internal/tropo-set", 1);
				setprop("FMGC/internal/tropo", scratchpad);
				setprop("MCDU[" ~ i ~ "]/scratchpad", "");
			} else {
				notAllowed(i);
			}
		}
	}
}
