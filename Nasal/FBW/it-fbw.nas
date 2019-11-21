# Airbus A3XX FBW/Flight Control Computer System
# Joshua Davidson (Octal450)

# Copyright (c) 2019 Joshua Davidson (Octal450)

# If All ELACs Fail, Alternate Law

setprop("/it-fbw/roll-back", 0);
setprop("/it-fbw/spd-hold", 0);
setprop("/it-fbw/protections/overspeed", 0);
setprop("/it-fbw/protections/overspeed-roll-back", 0);
setprop("/it-fbw/speeds/vmo-mmo", 350);
var mmoIAS = 0;

var fctlInit = func {
	setprop("/controls/fctl/elac1", 1);
	setprop("/controls/fctl/elac2", 1);
	setprop("/controls/fctl/sec1", 1);
	setprop("/controls/fctl/sec2", 1);
	setprop("/controls/fctl/sec3", 1);
	setprop("/controls/fctl/fac1", 1);
	setprop("/controls/fctl/fac2", 1);
	setprop("/systems/fctl/elac1", 0);
	setprop("/systems/fctl/elac2", 0);
	setprop("/systems/fctl/sec1", 0);
	setprop("/systems/fctl/sec2", 0);
	setprop("/systems/fctl/sec3", 0);
	setprop("/systems/fctl/fac1", 0);
	setprop("/systems/fctl/fac2", 0);
	setprop("/it-fbw/degrade-law", 0);
	setprop("/it-fbw/override", 0);
	setprop("/it-fbw/law", 0);
	updatet.start();
	fbwt.start();
}

var update_loop = func {
	var elac1_sw = getprop("/controls/fctl/elac1");
	var elac2_sw = getprop("/controls/fctl/elac2");
	var sec1_sw = getprop("/controls/fctl/sec1");
	var sec2_sw = getprop("/controls/fctl/sec2");
	var sec3_sw = getprop("/controls/fctl/sec3");
	var fac1_sw = getprop("/controls/fctl/fac1");
	var fac2_sw = getprop("/controls/fctl/fac2");
	
	var elac1_fail = getprop("/systems/failures/elac1");
	var elac2_fail = getprop("/systems/failures/elac2");
	var sec1_fail = getprop("/systems/failures/sec1");
	var sec2_fail = getprop("/systems/failures/sec2");
	var sec3_fail = getprop("/systems/failures/sec3");
	var fac1_fail = getprop("/systems/failures/fac1");
	var fac2_fail = getprop("/systems/failures/fac2");
	
	var ac_ess = props.globals.getNode("/systems/electrical/bus/ac-ess").getValue();
	var dc_ess = props.globals.getNode("/systems/electrical/bus/dc-ess").getValue();
	var dc_ess_shed = props.globals.getNode("/systems/electrical/bus/dc-ess-shed").getValue();
	var ac1 = props.globals.getNode("/systems/electrical/bus/ac-1").getValue();
	var ac2 = props.globals.getNode("/systems/electrical/bus/ac-2").getValue();
	var dc1 = props.globals.getNode("/systems/electrical/bus/dc-1").getValue();
	var dc2 = props.globals.getNode("/systems/electrical/bus/dc-2").getValue();
	var battery1_sw = props.globals.getNode("/controls/electrical/switches/bat-1").getValue();
	var battery2_sw = props.globals.getNode("/controls/electrical/switches/bat-2").getValue();
	var elac1_test = getprop("/systems/electrical/elac1-test");
	var elac2_test = getprop("/systems/electrical/elac2-test");
	
	if (elac1_sw and !elac1_fail and (dc_ess >= 25 or battery1_sw) and !elac1_test) {
		setprop("/systems/fctl/elac1", 1);
		setprop("/systems/failures/elac1-fault", 0);
	} else if (elac1_sw and (elac1_fail or (dc_ess < 25 and !battery1_sw)) and !elac1_test) {
		setprop("/systems/failures/elac1-fault", 1);
		setprop("/systems/fctl/elac1", 0);
	} else if (!elac1_test) {
		setprop("/systems/failures/elac1-fault", 0);
		setprop("/systems/fctl/elac1", 1);
	}
	
	if (elac2_sw and !elac2_fail and (dc2 >= 25 or battery2_sw) and !elac2_test) {
		setprop("/systems/fctl/elac2", 1);
		setprop("/systems/failures/elac2-fault", 0);
	} else if (elac2_sw and (elac2_fail or (dc2 < 25 and !battery2_sw)) and !elac2_test) {
		setprop("/systems/failures/elac2-fault", 1);
		setprop("/systems/fctl/elac2", 0);
	} else if (!elac2_test) {
		setprop("/systems/failures/elac2-fault", 0);
		setprop("/systems/fctl/elac2", 1);
	}
	
	if (sec1_sw and !sec1_fail and ac_ess >= 110) {
		setprop("/systems/fctl/sec1", 1);
		setprop("/systems/failures/spoiler-l3", 0);
		setprop("/systems/failures/spoiler-r3", 0);
		setprop("/systems/failures/spoiler-l4", 0);
		setprop("/systems/failures/spoiler-r4", 0);
	} else {
		setprop("/systems/fctl/sec1", 0);
		setprop("/systems/failures/spoiler-l3", 1);
		setprop("/systems/failures/spoiler-r3", 1);
		setprop("/systems/failures/spoiler-l4", 1);
		setprop("/systems/failures/spoiler-r4", 1);
	}
	
	if (sec2_sw and !sec2_fail and ac_ess >= 110) {
		setprop("/systems/fctl/sec2", 1);
		setprop("/systems/failures/spoiler-l5", 0);
		setprop("/systems/failures/spoiler-r5", 0);
	} else {
		setprop("/systems/fctl/sec2", 0);
		setprop("/systems/failures/spoiler-l5", 1);
		setprop("/systems/failures/spoiler-r5", 1);
	}
	
	if (sec3_sw and !sec3_fail and ac_ess >= 110) {
		setprop("/systems/fctl/sec3", 1);
		setprop("/systems/failures/spoiler-l1", 0);
		setprop("/systems/failures/spoiler-r1", 0);
		setprop("/systems/failures/spoiler-l2", 0);
		setprop("/systems/failures/spoiler-r2", 0);
	} else {
		setprop("/systems/fctl/sec3", 0);
		setprop("/systems/failures/spoiler-l1", 1);
		setprop("/systems/failures/spoiler-r1", 1);
		setprop("/systems/failures/spoiler-l2", 1);
		setprop("/systems/failures/spoiler-r2", 1);
	}
	
	if (fac1_sw and !fac1_fail and (ac_ess >= 110 or dc_ess_shed >= 25)) {
		setprop("/systems/fctl/fac1", 1);
		setprop("/systems/failures/rudder", 0);
		setprop("/systems/failures/fac1-fault", 0);
	} else if (fac1_sw and (battery1_sw or battery2_sw) and (fac1_fail or ac_ess < 110 or dc_ess_shed < 25)) {
		setprop("/systems/failures/fac1-fault", 1);
		setprop("/systems/fctl/fac1", 0);
		if (!fac2_sw or fac2_fail) {
			setprop("/systems/failures/rudder", 1);
		}
	} else {
		setprop("/systems/failures/fac1-fault", 0);
		setprop("/systems/fctl/fac1", 0);
		if (!fac2_sw or fac2_fail) {
			setprop("/systems/failures/rudder", 1);
		}
	}
	
	if (fac2_sw and !fac2_fail and (ac2 >= 110 or dc2 >= 25)) {
		setprop("/systems/fctl/fac2", 1);
		setprop("/systems/failures/fac2-fault", 0);
	} else if (fac2_sw and (fac2_fail or ac2 < 110 or dc2 < 25)) {
		setprop("/systems/failures/fac2-fault", 1);
		setprop("/systems/fctl/fac2", 0);
		if (!fac1_sw or fac1_fail) {
			setprop("/systems/failures/rudder", 1);
		}
	} else {
		setprop("/systems/fctl/fac2", 0);
		setprop("/systems/failures/fac2-fault", 0);
		if (!fac1_sw or fac1_fail) {
			setprop("/systems/failures/rudder", 1);
		}
	}
	
	var elac1 = getprop("/systems/fctl/elac1");
	var elac2 = getprop("/systems/fctl/elac2");
	var sec1 = getprop("/systems/fctl/sec1");
	var sec2 = getprop("/systems/fctl/sec2");
	var sec3 = getprop("/systems/fctl/sec3");
	var fac1 = getprop("/systems/fctl/fac1");
	var fac2 = getprop("/systems/fctl/fac2");
	var law = getprop("/it-fbw/law");
	
	# Degrade logic, all failures which degrade FBW need to go here. -JD
	if (getprop("/gear/gear[1]/wow") == 0 and getprop("/gear/gear[2]/wow") == 0) {
		if (!elac1 and !elac2) {
			if (law == 0) {
				setprop("/it-fbw/degrade-law", 1);
			}
		}
		if (ac_ess >= 110 and getprop("/systems/hydraulic/blue-psi") >= 1500 and getprop("/systems/hydraulic/green-psi") < 1500 and getprop("/systems/hydraulic/yellow-psi") < 1500) {
			if (law == 0 or law == 1) {
				setprop("/it-fbw/degrade-law", 2);
			}
		}
		if (ac_ess < 110 or (getprop("/systems/hydraulic/blue-psi") < 1500 and getprop("/systems/hydraulic/green-psi") < 1500 and getprop("/systems/hydraulic/yellow-psi") < 1500)) {
			setprop("/it-fbw/degrade-law", 3);
		}
	}
	
	if (getprop("/controls/gear/gear-down") == 1 and getprop("/it-autoflight/output/ap1") == 0 and getprop("/it-autoflight/output/ap2") == 0) {
		if (law == 1) {
			setprop("/it-fbw/degrade-law", 2);
		}
	}
	
	# degrade loop runs faster; reset this variable
	var law = getprop("/it-fbw/law");
	
	# Mech Backup can always return to direct, if it can.
	if (law == 3 and ac_ess >= 110 and (getprop("/systems/hydraulic/green-psi") >= 1500 or getprop("/systems/hydraulic/blue-psi") >= 1500 or getprop("/systems/hydraulic/yellow-psi") >= 1500)) {
		setprop("/it-fbw/degrade-law", 2);
	}
	
	mmoIAS = (getprop("/instrumentation/airspeed-indicator/indicated-speed-kt") / getprop("/instrumentation/airspeed-indicator/indicated-mach")) * 0.82;
	if (mmoIAS < 350) {
		setprop("/it-fbw/speeds/vmo-mmo", mmoIAS);
	} else {
		setprop("/it-fbw/speeds/vmo-mmo", 350);
	}
	
	if (getprop("/instrumentation/airspeed-indicator/indicated-speed-kt") > getprop("/it-fbw/speeds/vmo-mmo") + 6 and (law == 0 or law == 1)) {
		if (getprop("/it-autoflight/input/ap1") == 1 or getprop("/it-autoflight/input/ap2") == 1) {
			fcu.apOff("hard", 0);
		}
		if (getprop("/it-fbw/protections/overspeed") != 1) {
			setprop("/it-fbw/protections/overspeed", 1);
		}
	} else {
		if (getprop("/it-fbw/protections/overspeed") != 0) {
			setprop("/it-fbw/protections/overspeed", 0);
		}
	}
}
	
var fbw_loop = func {
	var ail = getprop("/controls/flight/aileron");
	
	if (ail > 0.4 and getprop("/orientation/roll-deg") >= -33.5) {
		setprop("/it-fbw/roll-lim", "67");
		if (getprop("/it-fbw/roll-back") == 1 and getprop("/orientation/roll-deg") <= 33.5 and getprop("/orientation/roll-deg") >= -33.5) {
			setprop("/it-fbw/roll-back", 0);
		}
		if (getprop("/it-fbw/roll-back") == 0 and (getprop("/orientation/roll-deg") > 33.5 or getprop("/orientation/roll-deg") < -33.5)) {
			setprop("/it-fbw/roll-back", 1);
		}
	} else if (ail < -0.4 and getprop("/orientation/roll-deg") <= 33.5) {
		setprop("/it-fbw/roll-lim", "67");
		if (getprop("/it-fbw/roll-back") == 1 and getprop("/orientation/roll-deg") <= 33.5 and getprop("/orientation/roll-deg") >= -33.5) {
			setprop("/it-fbw/roll-back", 0);
		}
		if (getprop("/it-fbw/roll-back") == 0 and (getprop("/orientation/roll-deg") > 33.5 or getprop("/orientation/roll-deg") < -33.5)) {
			setprop("/it-fbw/roll-back", 1);
		}
	} else if (ail < 0.04 and ail > -0.04) {
		setprop("/it-fbw/roll-lim", "33");
		if (getprop("/it-fbw/roll-back") == 1 and getprop("/orientation/roll-deg") <= 33.5 and getprop("/orientation/roll-deg") >= -33.5) {
			setprop("/it-fbw/roll-back", 0);
		}
	}
	
	if (ail > 0.04 or ail < -0.04) {
		setprop("/it-fbw/protections/overspeed-roll-back", 0);
	} else if (ail < 0.04 and ail > -0.04) {
		setprop("/it-fbw/protections/overspeed-roll-back", 1);
	}

	if (getprop("/it-fbw/override") == 0) {
		var degrade = getprop("/it-fbw/degrade-law");
		if (degrade == 0) {
			if (getprop("/it-fbw/law") != 0) {
				setprop("/it-fbw/law", 0);
			}
		} else if (degrade == 1) {
			if (getprop("/it-fbw/law") != 1) {
				setprop("/it-fbw/law", 1);
			}
		} else if (degrade == 2) {
			if (getprop("/it-fbw/law") != 2) {
				setprop("/it-fbw/law", 2);
			}
		} else if (degrade == 3) {
			if (getprop("/it-fbw/law") != 3) {
				setprop("/it-fbw/law", 3);
			}
		}
	}
	
	if (getprop("/it-fbw/law") != 0) {
		if (getprop("/it-autoflight/output/ap1") == 1 or getprop("/it-autoflight/output/ap2") == 1) {
			fcu.apOff("hard", 0);
		}
	}
}

var updatet = maketimer(0.1, update_loop);
var fbwt = maketimer(0.03, fbw_loop);
