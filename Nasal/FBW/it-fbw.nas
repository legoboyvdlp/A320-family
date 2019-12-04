# Airbus A3XX FBW/Flight Control Computer System
# Joshua Davidson (Octal450)

# Copyright (c) 2019 Joshua Davidson (Octal450)

# If All ELACs Fail, Alternate Law

var mmoIAS = 0;

var elac1_sw = 0;
var elac2_sw = 0;
var sec1_sw = 0;
var sec2_sw = 0;
var sec3_sw = 0;
var fac1_sw = 0;
var fac2_sw = 0;
	
var elac1_fail = 0;
var elac2_fail = 0;
var sec1_fail = 0;
var sec2_fail = 0;
var sec3_fail = 0;
var fac1_fail = 0;
var fac2_fail = 0;

var ac_ess = 0;
var dc_ess = 0;
var dc_ess_shed = 0;
var ac1 = 0;
var ac2 = 0;
var dc1 = 0;
var dc2 = 0;
var dcHot1 = 0;
var dcHot2 = 0;
var blue = 0;
var green = 0;
var yellow = 0;
var ail = 0;
var roll = 0;
var rollback = 0;
var battery1_sw = 0;
var battery2_sw = 0;

var law = 0;

var FBW = {
	degradeLaw: props.globals.getNode("/it-fbw/degrade-law"),
	activeLaw: props.globals.getNode("/it-fbw/law"),
	override: props.globals.getNode("/it-fbw/override"),
	rollBack: props.globals.getNode("/it-fbw/roll-back"),
	rollLim: props.globals.getNode("/it-fbw/roll-lim"),
	Computers: {
		elac1: props.globals.getNode("/systems/fctl/elac1"),
		elac2: props.globals.getNode("/systems/fctl/elac2"),
		sec1: props.globals.getNode("/systems/fctl/sec1"),
		sec2: props.globals.getNode("/systems/fctl/sec2"),
		sec3: props.globals.getNode("/systems/fctl/sec3"),
		fac1: props.globals.getNode("/systems/fctl/fac1"),
		fac2: props.globals.getNode("/systems/fctl/fac2"),
	},
	Failures: {
		elac1: props.globals.getNode("/systems/failures/fctl/elac1"),
		elac2: props.globals.getNode("/systems/failures/fctl/elac2"),
		sec1: props.globals.getNode("/systems/failures/fctl/sec1"),
		sec2: props.globals.getNode("/systems/failures/fctl/sec2"),
		sec3: props.globals.getNode("/systems/failures/fctl/sec3"),
		fac1: props.globals.getNode("/systems/failures/fctl/fac1"),
		fac2: props.globals.getNode("/systems/failures/fctl/fac2"),
	},
	Lights: {
		elac1: props.globals.getNode("/controls/fctl/lights/elac1-fault"),
		elac2: props.globals.getNode("/controls/fctl/lights/elac2-fault"),
		sec1: props.globals.getNode("/controls/fctl/lights/sec1-fault"),
		sec2: props.globals.getNode("/controls/fctl/lights/sec2-fault"),
		sec2: props.globals.getNode("/controls/fctl/lights/sec3-fault"),
		fac1: props.globals.getNode("/controls/fctl/lights/fac1-fault"),
		fac2: props.globals.getNode("/controls/fctl/lights/fac2-fault"),
	},
	Protections: {
		overspeedRoll: props.globals.getNode("/it-fbw/protections/overspeed-roll-back"),
	},
	Switches: {
		elac1Sw: props.globals.getNode("/controls/fctl/switches/elac1"),
		elac2Sw: props.globals.getNode("/controls/fctl/switches/elac2"),
		sec1Sw: props.globals.getNode("/controls/fctl/switches/sec1"),
		sec2Sw: props.globals.getNode("/controls/fctl/switches/sec2"),
		sec3Sw: props.globals.getNode("/controls/fctl/switches/sec3"),
		fac1Sw: props.globals.getNode("/controls/fctl/switches/fac1"),
		fac2Sw: props.globals.getNode("/controls/fctl/switches/fac2"),
	},
	init: func() {
		if (updatet.isRunning) {
			updatet.stop();
		}
		if (fbwt.isRunning) {
			fbwt.stop();
		}
		
		me.resetFail();
		
		me.Switches.elac1Sw.setBoolValue(1);
		me.Switches.elac2Sw.setBoolValue(1);
		me.Switches.sec1Sw.setBoolValue(1);
		me.Switches.sec2Sw.setBoolValue(1);
		me.Switches.sec3Sw.setBoolValue(1);
		me.Switches.fac1Sw.setBoolValue(1);
		me.Switches.fac2Sw.setBoolValue(1);
		me.Computers.elac1.setBoolValue(0);
		me.Computers.elac2.setBoolValue(0);
		me.Computers.sec1.setBoolValue(0);
		me.Computers.sec2.setBoolValue(0);
		me.Computers.sec3.setBoolValue(0);
		me.Computers.fac1.setBoolValue(0);
		me.Computers.fac2.setBoolValue(0);
		me.degradeLaw.setValue(0);
		me.activeLaw.setValue(0);
		me.override.setValue(0);
		
		if (!updatet.isRunning) {
			updatet.start();
		}
		if (!fbwt.isRunning) {
			fbwt.start();
		}
	},
	resetFail: func() {
		me.Failures.elac1.setBoolValue(0);
		me.Failures.elac2.setBoolValue(0);
		me.Failures.sec1.setBoolValue(0);
		me.Failures.sec2.setBoolValue(0);
		me.Failures.sec3.setBoolValue(0);
		me.Failures.fac1.setBoolValue(0);
		me.Failures.fac2.setBoolValue(0);
	},
};

var update_loop = func {
	elac1_sw = FBW.Switches.elac1Sw.getValue();
	elac2_sw = FBW.Switches.elac2Sw.getValue();
	sec1_sw = FBW.Switches.sec1Sw.getValue();
	sec2_sw = FBW.Switches.sec2Sw.getValue();
	sec3_sw = FBW.Switches.sec3Sw.getValue();
	fac1_sw = FBW.Switches.fac1Sw.getValue();
	fac2_sw = FBW.Switches.fac2Sw.getValue();
	
	elac1_fail = FBW.Failures.elac1.getValue();
	elac2_fail = FBW.Failures.elac2.getValue();
	sec1_fail = FBW.Failures.sec1.getValue();
	sec2_fail = FBW.Failures.sec2.getValue();
	sec3_fail = FBW.Failures.sec3.getValue();
	fac1_fail = FBW.Failures.fac1.getValue();
	fac2_fail = FBW.Failures.fac2.getValue();
	
	ac_ess = systems.ELEC.Bus.acEss.getValue();
	dc_ess = systems.ELEC.Bus.dcEss.getValue();
	dc_ess_shed = systems.ELEC.Bus.dcEssShed.getValue();
	ac1 = systems.ELEC.Bus.ac1.getValue();
	ac2 = systems.ELEC.Bus.ac2.getValue();
	dc1 = systems.ELEC.Bus.dc1.getValue();
	dc2 = systems.ELEC.Bus.dc2.getValue();
	dcHot1 = systems.ELEC.Bus.dcHot1.getValue();
	dcHot2 = systems.ELEC.Bus.dcHot2.getValue();
	battery1_sw = systems.ELEC.Switch.bat1.getValue();
	battery2_sw = systems.ELEC.Switch.bat2.getValue();
	
	if (elac1_sw and !elac1_fail and (dc_ess >= 25 or dcHot1 >= 25)) {
		FBW.Computers.elac1.setValue(1);
		FBW.Lights.elac1.setValue(0);
	} else if (elac1_sw and (elac1_fail or (dc_ess < 25 and dcHot1 < 25))) {
		FBW.Computers.elac1.setValue(0);
		FBW.Lights.elac1.setValue(1);
	}
	
	if (elac2_sw and !elac2_fail and (dc2 >= 25 or dcHot2 >= 25)) {
		FBW.Computers.elac2.setValue(1);
		FBW.Lights.elac2.setValue(0);
	} else if (elac1_sw and (elac2_fail or (dc2 < 25 and dcHot2 < 25))) {
		FBW.Computers.elac2.setValue(0);
		FBW.Lights.elac2.setValue(1);
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
	law = FBW.activeLaw.getValue();
	
	# Degrade logic, all failures which degrade FBW need to go here. -JD
	blue = systems.HYD.Psi.blue.getValue();
	green = systems.HYD.Psi.green.getValue();
	yellow = systems.HYD.Psi.yellow.getValue();
	if (getprop("/gear/gear[1]/wow") == 0 and getprop("/gear/gear[2]/wow") == 0) {
		if (!elac1 and !elac2) {
			if (law == 0) {
				FBW.degradeLaw.setValue(1);
			}
		}
		if (ac_ess >= 110 and blue >= 1500 and green < 1500 and yellow < 1500) {
			if (law == 0 or law == 1) {
				FBW.degradeLaw.setValue(2);
			}
		}
		if (ac_ess < 110 or (blue < 1500 and green < 1500 and yellow < 1500)) {
			FBW.degradeLaw.setValue(3);
		}
	}
	
	if (getprop("/controls/gear/gear-down") == 1 and getprop("/it-autoflight/output/ap1") == 0 and getprop("/it-autoflight/output/ap2") == 0) {
		if (law == 1) {
			FBW.degradeLaw.setValue(2);
		}
	}
	
	# degrade loop runs faster; reset this variable
	law = FBW.activeLaw.getValue();
	
	# Mech Backup can always return to direct, if it can.
	if (law == 3 and ac_ess >= 110 and (green >= 1500 or blue >= 1500 or yellow >= 1500)) {
		FBW.degradeLaw.setValue(2);
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
	ail = pts.Controls.Flight.aileron.getValue();
	roll = pts.Orientation.roll.getValue();
	rollback = FBW.rollBack.getValue();
	
	if (ail > 0.4 and roll >= -33.5) {
		FBW.rollLim.setValue("67");
		if (rollback == 1 and roll <= 33.5 and roll >= -33.5) {
			FBW.rollBack.setValue(0);
		} elsif (rollback == 0 and (roll > 33.5 or roll < -33.5)) {
			FBW.rollBack.setValue(1);
		}
	} else if (ail < -0.4 and roll <= 33.5) {
		FBW.rollLim.setValue("67");
		if (rollback == 1 and roll <= 33.5 and roll >= -33.5) {
			FBW.rollBack.setValue(0);
		} elsif (rollback == 0 and (roll > 33.5 or roll < -33.5)) {
			FBW.rollBack.setValue(1);
		}
	} else if (ail < 0.04 and ail > -0.04) {
		FBW.rollLim.setValue("33");
		if (rollback == 1 and roll <= 33.5 and roll >= -33.5) {
			FBW.rollBack.setValue(0);
		}
	}
	
	if (ail > 0.04 or ail < -0.04) {
		FBW.Protections.overspeedRoll.setValue(0);
	} else if (ail < 0.04 and ail > -0.04) {
		FBW.Protections.overspeedRoll.setValue(1);
	}

	if (getprop("/it-fbw/override") == 0) {
		var active = FBW.activeLaw.getValue();
		var degrade = FBW.degradeLaw.getValue();
		if (degrade == 0) {
			if (active != 0) {
				FBW.activeLaw.setValue(0);
			}
		} else if (degrade == 1) {
			if (active != 1) {
				FBW.activeLaw.setValue(1);
			}
		} else if (degrade == 2) {
			if (active != 2) {
				FBW.activeLaw.setValue(2);
			}
		} else if (degrade == 3) {
			if (active != 3) {
				FBW.activeLaw.setValue(3);
			}
		}
	}
	
	if (FBW.activeLaw.getValue() != 0) {
		if (getprop("/it-autoflight/output/ap1") == 1 or getprop("/it-autoflight/output/ap2") == 1) {
			fcu.apOff("hard", 0);
		}
	}
}

var updatet = maketimer(0.1, update_loop);
var fbwt = maketimer(0.03, fbw_loop);
