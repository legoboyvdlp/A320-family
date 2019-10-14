# A3XX EFIS controller by Joshua Davidson (Octal450).

# Copyright (c) 2019 Joshua Davidson (Octal450)

setlistener("sim/signals/fdm-initialized", func {
	setprop("/instrumentation/efis[0]/nd/display-mode", "NAV");
	setprop("/instrumentation/efis[0]/mfd/pnl_mode-num", 2);
	setprop("/instrumentation/efis[0]/inputs/range-nm", 20);
	setprop("/instrumentation/efis[0]/inputs/tfc", 0);
	setprop("/instrumentation/efis[0]/inputs/CSTR", 0);
	setprop("/instrumentation/efis[0]/inputs/wpt", 0);
	setprop("/instrumentation/efis[0]/inputs/VORD", 0);
	setprop("/instrumentation/efis[0]/inputs/DME", 0);
	setprop("/instrumentation/efis[0]/inputs/NDB", 0);
	setprop("/instrumentation/efis[0]/inputs/arpt", 0);
	setprop("/instrumentation/efis[1]/nd/display-mode", "NAV");
	setprop("/instrumentation/efis[1]/mfd/pnl_mode-num", 2);
	setprop("/instrumentation/efis[1]/inputs/range-nm", 20);
	setprop("/instrumentation/efis[1]/inputs/tfc", 0);
	setprop("/instrumentation/efis[1]/inputs/CSTR", 0);
	setprop("/instrumentation/efis[1]/inputs/wpt", 0);
	setprop("/instrumentation/efis[1]/inputs/VORD", 0);
	setprop("/instrumentation/efis[1]/inputs/DME", 0);
	setprop("/instrumentation/efis[1]/inputs/NDB", 0);
	setprop("/instrumentation/efis[1]/inputs/arpt", 0);
});

var setCptND = func(d) {
	var mode = getprop("/instrumentation/efis[0]/nd/display-mode");
	
	if (d == 1) {
		if (mode == "ILS") {
			setprop("/instrumentation/efis[0]/nd/display-mode", "VOR");
			setprop("/instrumentation/efis[0]/mfd/pnl_mode-num", 1);
		} else if (mode == "VOR") {
			setprop("/instrumentation/efis[0]/nd/display-mode", "NAV");
			setprop("/instrumentation/efis[0]/mfd/pnl_mode-num", 2);
		} else if (mode == "NAV") {
			setprop("/instrumentation/efis[0]/nd/display-mode", "ARC");
			setprop("/instrumentation/efis[0]/mfd/pnl_mode-num", 3);
		} else if (mode == "ARC") {
			setprop("/instrumentation/efis[0]/nd/display-mode", "PLAN");
			setprop("/instrumentation/efis[0]/mfd/pnl_mode-num", 4);
		}
	} else if (d == -1) {
		if (mode == "PLAN") {
			setprop("/instrumentation/efis[0]/nd/display-mode", "ARC");
			setprop("/instrumentation/efis[0]/mfd/pnl_mode-num", 3);
		} else if (mode == "ARC") {
			setprop("/instrumentation/efis[0]/nd/display-mode", "NAV");
			setprop("/instrumentation/efis[0]/mfd/pnl_mode-num", 2);
		} else if (mode == "NAV") {
			setprop("/instrumentation/efis[0]/nd/display-mode", "VOR");
			setprop("/instrumentation/efis[0]/mfd/pnl_mode-num", 1);
		} else if (mode == "VOR") {
			setprop("/instrumentation/efis[0]/nd/display-mode", "ILS");
			setprop("/instrumentation/efis[0]/mfd/pnl_mode-num", 0);
		}
	}
}

var setFoND = func(d) {
	var mode = getprop("/instrumentation/efis[1]/nd/display-mode");
	
	if (d == 1) {
		if (mode == "ILS") {
			setprop("/instrumentation/efis[1]/nd/display-mode", "VOR");
			setprop("/instrumentation/efis[1]/mfd/pnl_mode-num", 1);
		} else if (mode == "VOR") {
			setprop("/instrumentation/efis[1]/nd/display-mode", "NAV");
			setprop("/instrumentation/efis[1]/mfd/pnl_mode-num", 2);
		} else if (mode == "NAV") {
			setprop("/instrumentation/efis[1]/nd/display-mode", "ARC");
			setprop("/instrumentation/efis[1]/mfd/pnl_mode-num", 3);
		} else if (mode == "ARC") {
			setprop("/instrumentation/efis[1]/nd/display-mode", "PLAN");
			setprop("/instrumentation/efis[1]/mfd/pnl_mode-num", 4);
		}
	} else if (d == -1) {
		if (mode == "PLAN") {
			setprop("/instrumentation/efis[1]/nd/display-mode", "ARC");
			setprop("/instrumentation/efis[1]/mfd/pnl_mode-num", 3);
		} else if (mode == "ARC") {
			setprop("/instrumentation/efis[1]/nd/display-mode", "NAV");
			setprop("/instrumentation/efis[1]/mfd/pnl_mode-num", 2);
		} else if (mode == "NAV") {
			setprop("/instrumentation/efis[1]/nd/display-mode", "VOR");
			setprop("/instrumentation/efis[1]/mfd/pnl_mode-num", 1);
		} else if (mode == "VOR") {
			setprop("/instrumentation/efis[1]/nd/display-mode", "ILS");
			setprop("/instrumentation/efis[1]/mfd/pnl_mode-num", 0);
		}
	}
}

var setNDRange = func(n, d) {
	var rng = getprop("/instrumentation/efis[" ~ n ~ "]/inputs/range-nm");
	if (d == 1) {
		rng = rng * 2;
		if (rng > 320) {
			rng = 320;
		}
	} else if (d == -1){
		rng = rng / 2;
		if (rng < 10) {
			rng = 10;
		}
	}
	setprop("/instrumentation/efis[" ~ n ~ "]/inputs/range-nm", rng);
}

var cpt_efis_btns = func(i) {
	if (i == "cstr") {
		setprop("/instrumentation/efis[0]/inputs/CSTR", 1);
		setprop("/instrumentation/efis[0]/inputs/wpt", 0);
		setprop("/instrumentation/efis[0]/inputs/VORD", 0);
		setprop("/instrumentation/efis[0]/inputs/DME", 0);
		setprop("/instrumentation/efis[0]/inputs/NDB", 0);
		setprop("/instrumentation/efis[0]/inputs/arpt", 0);
	} else if (i == "wpt") {
		setprop("/instrumentation/efis[0]/inputs/CSTR", 0);
		setprop("/instrumentation/efis[0]/inputs/wpt", 1);
		setprop("/instrumentation/efis[0]/inputs/VORD", 0);
		setprop("/instrumentation/efis[0]/inputs/DME", 0);
		setprop("/instrumentation/efis[0]/inputs/NDB", 0);
		setprop("/instrumentation/efis[0]/inputs/arpt", 0);
	} else if (i == "vord") {
		setprop("/instrumentation/efis[0]/inputs/CSTR", 0);
		setprop("/instrumentation/efis[0]/inputs/wpt", 0);
		setprop("/instrumentation/efis[0]/inputs/VORD", 1);
		setprop("/instrumentation/efis[0]/inputs/DME", 1);
		setprop("/instrumentation/efis[0]/inputs/NDB", 0);
		setprop("/instrumentation/efis[0]/inputs/arpt", 0);
	} else if (i == "ndb") {
		setprop("/instrumentation/efis[0]/inputs/CSTR", 0);
		setprop("/instrumentation/efis[0]/inputs/wpt", 0);
		setprop("/instrumentation/efis[0]/inputs/VORD", 0);
		setprop("/instrumentation/efis[0]/inputs/DME", 0);
		setprop("/instrumentation/efis[0]/inputs/NDB", 1);
		setprop("/instrumentation/efis[0]/inputs/arpt", 0);
	} else if (i == "arpt") {
		setprop("/instrumentation/efis[0]/inputs/CSTR", 0);
		setprop("/instrumentation/efis[0]/inputs/wpt", 0);
		setprop("/instrumentation/efis[0]/inputs/VORD", 0);
		setprop("/instrumentation/efis[0]/inputs/DME", 0);
		setprop("/instrumentation/efis[0]/inputs/NDB", 0);
		setprop("/instrumentation/efis[0]/inputs/arpt", 1);
	} else if (i == "off") {
		setprop("/instrumentation/efis[0]/inputs/CSTR", 0);
		setprop("/instrumentation/efis[0]/inputs/wpt", 0);
		setprop("/instrumentation/efis[0]/inputs/VORD", 0);
		setprop("/instrumentation/efis[0]/inputs/DME", 0);
		setprop("/instrumentation/efis[0]/inputs/NDB", 0);
		setprop("/instrumentation/efis[0]/inputs/arpt", 0);
	}
}

var fo_efis_btns = func(i) {
	if (i == "cstr") {
		setprop("/instrumentation/efis[1]/inputs/CSTR", 1);
		setprop("/instrumentation/efis[1]/inputs/wpt", 0);
		setprop("/instrumentation/efis[1]/inputs/VORD", 0);
		setprop("/instrumentation/efis[1]/inputs/DME", 0);
		setprop("/instrumentation/efis[1]/inputs/NDB", 0);
		setprop("/instrumentation/efis[1]/inputs/arpt", 0);
	} else if (i == "wpt") {
		setprop("/instrumentation/efis[1]/inputs/CSTR", 0);
		setprop("/instrumentation/efis[1]/inputs/wpt", 1);
		setprop("/instrumentation/efis[1]/inputs/VORD", 0);
		setprop("/instrumentation/efis[1]/inputs/DME", 0);
		setprop("/instrumentation/efis[1]/inputs/NDB", 0);
		setprop("/instrumentation/efis[1]/inputs/arpt", 0);
	} else if (i == "vord") {
		setprop("/instrumentation/efis[1]/inputs/CSTR", 0);
		setprop("/instrumentation/efis[1]/inputs/wpt", 0);
		setprop("/instrumentation/efis[1]/inputs/VORD", 1);
		setprop("/instrumentation/efis[1]/inputs/DME", 1);
		setprop("/instrumentation/efis[1]/inputs/NDB", 0);
		setprop("/instrumentation/efis[1]/inputs/arpt", 0);
	} else if (i == "ndb") {
		setprop("/instrumentation/efis[1]/inputs/CSTR", 0);
		setprop("/instrumentation/efis[1]/inputs/wpt", 0);
		setprop("/instrumentation/efis[1]/inputs/VORD", 0);
		setprop("/instrumentation/efis[1]/inputs/DME", 0);
		setprop("/instrumentation/efis[1]/inputs/NDB", 1);
		setprop("/instrumentation/efis[1]/inputs/arpt", 0);
	} else if (i == "arpt") {
		setprop("/instrumentation/efis[1]/inputs/CSTR", 0);
		setprop("/instrumentation/efis[1]/inputs/wpt", 0);
		setprop("/instrumentation/efis[1]/inputs/VORD", 0);
		setprop("/instrumentation/efis[1]/inputs/DME", 0);
		setprop("/instrumentation/efis[1]/inputs/NDB", 0);
		setprop("/instrumentation/efis[1]/inputs/arpt", 1);
	} else if (i == "off") {
		setprop("/instrumentation/efis[1]/inputs/CSTR", 0);
		setprop("/instrumentation/efis[1]/inputs/wpt", 0);
		setprop("/instrumentation/efis[1]/inputs/VORD", 0);
		setprop("/instrumentation/efis[1]/inputs/DME", 0);
		setprop("/instrumentation/efis[1]/inputs/NDB", 0);
		setprop("/instrumentation/efis[1]/inputs/arpt", 0);
	}
}
