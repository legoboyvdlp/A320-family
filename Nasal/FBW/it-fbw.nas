# Airbus A3XX FBW/Flight Control Computer System
# Joshua Davidson (Octal450)

# Copyright (c) 2020 Josh Davidson (Octal450)

var mmoIAS = 0;
var cas = 0;

var elac1 = 0;
var elac2 = 0;
var sec1 = 0;
var sec2 = 0;
var sec3 = 0;
var fac1 = 0;
var fac2 = 0;
var dualELACFault = 0;
var tripleSECFault = 0;
var dualFACFault = 0;
var adr1 = 0;
var adr2 = 0;
var adr3 = 0;
var tripleADRFail = 0;
var doubleADRFail = 0;
var ir1 = 0;
var ir2 = 0;
var ir3 = 0;
var tripleIRFail = 0;
var doubleIRFail = 0;
var blue = 0;
var green = 0;
var yellow = 0;
var blueGreenFail = 0;
var greenYellowFail = 0;
var ail = 0;
var roll = 0;
var rollback = 0;
var law = 0;
var lawyaw = 0;

var FBW = {
	apOff: 0,
	degradeLaw: props.globals.getNode("/it-fbw/degrade-law"),
	degradeYawLaw: props.globals.getNode("/it-fbw/degrade-yaw-law"),
	activeLaw: props.globals.getNode("/it-fbw/law"),
	activeYawLaw: props.globals.getNode("/it-fbw/yaw-law"),
	override: props.globals.getNode("/it-fbw/override"),
	rollBack: props.globals.getNode("/it-fbw/roll-back"),
	rollLim: props.globals.getNode("/it-fbw/roll-lim"),
	yawdamper: props.globals.getNode("/systems/fctl/yawdamper-active"),
	Computers: {
		elac1: props.globals.getNode("/systems/fctl/elac1"),
		elac2: props.globals.getNode("/systems/fctl/elac2"),
		sec1: props.globals.getNode("/systems/fctl/sec1"),
		sec2: props.globals.getNode("/systems/fctl/sec2"),
		sec3: props.globals.getNode("/systems/fctl/sec3"),
		fac1: props.globals.getNode("/systems/fctl/fac1-healthy-signal"),
		fac2: props.globals.getNode("/systems/fctl/fac2-healthy-signal"),
	},
	Failures: {
		elac1: props.globals.getNode("/systems/failures/fctl/elac1"),
		elac2: props.globals.getNode("/systems/failures/fctl/elac2"),
		sec1: props.globals.getNode("/systems/failures/fctl/sec1"),
		sec2: props.globals.getNode("/systems/failures/fctl/sec2"),
		sec3: props.globals.getNode("/systems/failures/fctl/sec3"),
		fac1: props.globals.getNode("/systems/failures/fctl/fac1"),
		fac2: props.globals.getNode("/systems/failures/fctl/fac2"),
		ths: props.globals.getNode("/systems/failures/fctl/ths-jam"),
		spoilerl1: props.globals.getNode("/systems/failures/spoilers/spoiler-l1"),
		spoilerl2: props.globals.getNode("/systems/failures/spoilers/spoiler-l2"),
		spoilerl3: props.globals.getNode("/systems/failures/spoilers/spoiler-l3"),
		spoilerl4: props.globals.getNode("/systems/failures/spoilers/spoiler-l4"),
		spoilerl5: props.globals.getNode("/systems/failures/spoilers/spoiler-l5"),
		spoilerr1: props.globals.getNode("/systems/failures/spoilers/spoiler-r1"),
		spoilerr2: props.globals.getNode("/systems/failures/spoilers/spoiler-r2"),
		spoilerr3: props.globals.getNode("/systems/failures/spoilers/spoiler-r3"),
		spoilerr4: props.globals.getNode("/systems/failures/spoilers/spoiler-r4"),
		spoilerr5: props.globals.getNode("/systems/failures/spoilers/spoiler-r5"),
		yawDamper1: props.globals.getNode("/systems/failures/fctl/yaw-damper-1"),
		yawDamper2: props.globals.getNode("/systems/failures/fctl/yaw-damper-2"),
	},
	Lights: {
		elac1: props.globals.getNode("/systems/fctl/lights/elac1-fault"),
		elac2: props.globals.getNode("/systems/fctl/lights/elac2-fault"),
		sec1: props.globals.getNode("/systems/fctl/lights/sec1-fault"),
		sec2: props.globals.getNode("/systems/fctl/lights/sec2-fault"),
		sec2: props.globals.getNode("/systems/fctl/lights/sec3-fault"),
		fac1: props.globals.getNode("/systems/fctl/lights/fac1-fault"),
		fac2: props.globals.getNode("/systems/fctl/lights/fac2-fault"),
	},
	Protections: {
		overspeedRoll: props.globals.getNode("/it-fbw/protections/overspeed-roll-back"),
		overspeed: props.globals.getNode("/it-fbw/protections/overspeed"),
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
		me.apOff = 0;
		
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
		me.Failures.ths.setBoolValue(0);
		me.Failures.spoilerl1.setBoolValue(0);
		me.Failures.spoilerl2.setBoolValue(0);
		me.Failures.spoilerl3.setBoolValue(0);
		me.Failures.spoilerl4.setBoolValue(0);
		me.Failures.spoilerl5.setBoolValue(0);
		me.Failures.spoilerr1.setBoolValue(0);
		me.Failures.spoilerr2.setBoolValue(0);
		me.Failures.spoilerr3.setBoolValue(0);
		me.Failures.spoilerr4.setBoolValue(0);
		me.Failures.spoilerr5.setBoolValue(0);
		me.Failures.yawDamper1.setBoolValue(0);
		me.Failures.yawDamper2.setBoolValue(0);
	},
};

var update_loop = func {
	elac1 = FBW.Computers.elac1.getBoolValue();
	elac2 = FBW.Computers.elac2.getBoolValue();
	sec1 = FBW.Computers.sec1.getBoolValue();
	sec2 = FBW.Computers.sec2.getBoolValue();
	sec3 = FBW.Computers.sec3.getBoolValue();
	fac1 = FBW.Computers.fac1.getBoolValue();
	fac2 = FBW.Computers.fac2.getBoolValue();
	law = FBW.activeLaw.getValue();
	lawyaw = FBW.activeYawLaw.getValue();
	adr1 = systems.ADIRS.Operating.adr[0].getValue();
	adr2 = systems.ADIRS.Operating.adr[1].getValue();
	adr3 = systems.ADIRS.Operating.adr[2].getValue();
	ir1 = systems.ADIRS.ADIRunits[0].operating;
	ir2 = systems.ADIRS.ADIRunits[1].operating;
	ir3 = systems.ADIRS.ADIRunits[2].operating;
	
	# Degrade logic, all failures which degrade FBW need to go here. -JD
	blue = systems.HYD.Psi.blue.getValue();
	green = systems.HYD.Psi.green.getValue();
	yellow = systems.HYD.Psi.yellow.getValue();
	
	dualELACFault = !elac1 and !elac2;
	tripleSECFault = !sec1 and !sec2 and !sec3;
	dualFACFault = !fac1 and !fac2;
	
	blueGreenFail = blue < 1500 and green < 1500 and yellow >= 1500;
	greenYellowFail = blue >= 1500 and green < 1500 and yellow < 1500;
	tripleADRFail = !adr1 and !adr2 and !adr3;
	doubleADRFail = (!adr1 and !adr2 and adr3) or (adr1 and !adr2 and !adr3) or (!adr1 and adr2 and !adr3);
	tripleIRFail = !ir1 and !ir2 and !ir3;
	doubleIRFail = (!ir1 and !ir2 and ir3) or (ir1 and !ir2 and !ir3) or (!ir1 and ir2 and !ir3);
	
	if (dualELACFault and !sec1 and !sec2) {
		FBW.degradeLaw.setValue(3);
		FBW.apOff = 1;
	} elsif (tripleADRFail or doubleADRFail or doubleIRFail or tripleIRFail or dualFACFault or !FBW.yawdamper.getValue() or greenYellowFail or blueGreenFail or dualELACFault or (!elac1 and elac2 and ((green < 1500 and yellow >= 1500) or (green >= 1500 and yellow < 1500))) or (!elac2 and elac1 and blue < 1500) or tripleSECFault or systems.ELEC.EmerElec.getBoolValue()) {
		if (dualFACFault or !FBW.yawdamper.getValue() or greenYellowFail or (systems.ELEC.EmerElec.getBoolValue() and !fac1) or tripleIRFail) {
			if (lawyaw == 0 or lawyaw == 1) {
				FBW.degradeYawLaw.setValue(2);
			}
		} elsif (fac1 and lawyaw == 2 and systems.ELEC.EmerElec.getBoolValue()) {
			FBW.degradeYawLaw.setValue(1);
		} elsif (lawyaw == 0) {
			FBW.degradeYawLaw.setValue(1);
		}
		
		if (law == 0 and !tripleIRFail) {
			FBW.degradeLaw.setValue(1);
			if (!tripleSECFault) {
				FBW.apOff = 1;
			}
		} elsif (tripleIRFail and (law == 0 or law == 1)) {
			FBW.degradeLaw.setValue(2);
			FBW.apOff = 1;
		}
	} else {
		FBW.degradeYawLaw.setValue(0);
		FBW.degradeLaw.setValue(0);
		FBW.apOff = 0;
	}
		
	# degrade loop runs faster; reset this variable
	law = FBW.activeLaw.getValue();
	
	if (!pts.Gear.wow[1].getBoolValue() and !pts.Gear.wow[2].getBoolValue()) {
		if (pts.Controls.Gear.gearDown.getBoolValue()) {
			if (law == 1) {
				FBW.degradeLaw.setValue(2); # todo 3 sec timer
			}
		} else {
			if (law == 2 and !tripleIRFail) {
				FBW.degradeLaw.setValue(1); # todo 3 sec timer
			}
		}
	}
	
	
	cas = pts.Instrumentation.AirspeedIndicator.indicatedSpdKt.getValue();
	mmoIAS = (cas / pts.Instrumentation.AirspeedIndicator.indicatedMach.getValue()) * 0.82;
	if (mmoIAS < 350) {
		fmgc.FMGCInternal.vmo_mmo = mmoIAS;
	} else {
		fmgc.FMGCInternal.vmo_mmo = 350;
	}
	
	if (cas > (fmgc.FMGCInternal.vmo_mmo + 6) and (law == 0 or law == 1)) {
		if (fmgc.Input.ap1.getBoolValue() or fmgc.Input.ap2.getBoolValue()) {
			fcu.apOff("hard", 0);
		}
		if (!FBW.Protections.overspeed.getBoolValue()) {
			FBW.Protections.overspeed.setBoolValue(1);
		}
	} else {
		if (FBW.Protections.overspeed.getBoolValue()) {
			FBW.Protections.overspeed.setBoolValue(0);
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

	if (!FBW.override.getBoolValue()) {
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
		
		active = FBW.activeYawLaw.getValue();
		degrade = FBW.degradeYawLaw.getValue();
		if (degrade == 0) {
			if (active != 0) {
				FBW.activeYawLaw.setValue(0);
			}
		} else if (degrade == 1) {
			if (active != 1) {
				FBW.activeYawLaw.setValue(1);
			}
		} else if (degrade == 2) {
			if (active != 2) {
				FBW.activeYawLaw.setValue(2);
			}
		}
	}
	
	if (FBW.apOff) {
		if (fmgc.Input.ap1.getBoolValue() or fmgc.Input.ap2.getBoolValue()) {
			fcu.apOff("hard", 0);
			fcu.athrOff("hard");
		}
	}
}

setlistener("systems/fctl/sec1", func() {
	if (FBW.Computers.sec1.getBoolValue()) {
		FBW.Failures.spoilerl3.setBoolValue(0);
		FBW.Failures.spoilerr3.setBoolValue(0);
		FBW.Failures.spoilerl4.setBoolValue(0);
		FBW.Failures.spoilerr4.setBoolValue(0);
	} else {
		FBW.Failures.spoilerl3.setBoolValue(1);
		FBW.Failures.spoilerr3.setBoolValue(1);
		FBW.Failures.spoilerl4.setBoolValue(1);
		FBW.Failures.spoilerr4.setBoolValue(1);
	}
}, 0, 0);

setlistener("systems/fctl/sec2", func() {
	if (FBW.Computers.sec2.getBoolValue()) {
		FBW.Failures.spoilerl5.setBoolValue(0);
		FBW.Failures.spoilerr5.setBoolValue(0);
	} else {
		FBW.Failures.spoilerl5.setBoolValue(1);
		FBW.Failures.spoilerr5.setBoolValue(1);
	}
}, 0, 0);

setlistener("systems/fctl/sec3", func() {
	if (FBW.Computers.sec3.getBoolValue()) {
		FBW.Failures.spoilerl1.setBoolValue(0);
		FBW.Failures.spoilerr1.setBoolValue(0);
		FBW.Failures.spoilerl2.setBoolValue(0);
		FBW.Failures.spoilerr2.setBoolValue(0);
	} else {
		FBW.Failures.spoilerl1.setBoolValue(1);
		FBW.Failures.spoilerr1.setBoolValue(1);
		FBW.Failures.spoilerl2.setBoolValue(1);
		FBW.Failures.spoilerr2.setBoolValue(1);
	}
}, 0, 0);

var updatet = maketimer(0.1, update_loop);
var fbwt = maketimer(0.03, fbw_loop);
