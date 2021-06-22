# A3XX FWC Phases

# Copyright (c) 2019 Jonathan Redpath (legoboyvdlp)

var currentPhase = nil;
var eng = nil;
var eng1epr = nil;
var eng2epr = nil;
var eng1n1 = nil;
var eng2n1 = nil;
var master1 = nil;
var master2 = nil;
var gear_agl_cur = nil;

var FWC = {
	Btn: {
		clr: props.globals.initNode("/ECAM/buttons/clear-btn", 0, "BOOL"),
		recall: props.globals.initNode("/ECAM/buttons/recall-btn", 0, "BOOL"),
		recallStsNormal: props.globals.initNode("/ECAM/buttons/recall-status-normal", 0, "BOOL"),
		recallStsNormalOutput: props.globals.initNode("/ECAM/buttons/recall-status-normal-output", 0, "BOOL"),
	},
	Monostable: {
		phase1: props.globals.initNode("/ECAM/phases/monostable/phase-1-300", 0, "BOOL"),
		phase5: props.globals.initNode("/ECAM/phases/monostable/phase-5", 0, "BOOL"),
		phase5Temp: 0,
		phase7: props.globals.initNode("/ECAM/phases/monostable/phase-7", 0, "BOOL"),
		phase7Temp: 0,
		phase9: props.globals.initNode("/ECAM/phases/monostable/phase-9", 0, "BOOL"),
		phase1Output: props.globals.initNode("/ECAM/phases/monostable/phase-1-300-output"),
		phase1OutputTemp: 0,
		phase5Output: props.globals.initNode("/ECAM/phases/monostable/phase-5-output"),
		phase5OutputTemp: 0,
		phase7Output: props.globals.initNode("/ECAM/phases/monostable/phase-7-output"),
		phase7OutputTemp: 0,
		phase9Output: props.globals.initNode("/ECAM/phases/monostable/phase-9-output"),
		toPowerOutput: props.globals.getNode("/ECAM/phases/monostable/to-power-set-output"),
		m80kt: props.globals.getNode("/ECAM/phases/monostable-80kt"),
		altAlert1: props.globals.initNode("/ECAM/altitude-alert-monostable-set", 0, "BOOL"),
		altAlert1Output: props.globals.initNode("/ECAM/altitude-alert-monostable-output"),
		altAlert2: props.globals.initNode("/ECAM/flipflop/altitude-alert-rs-set", 0, "BOOL"),
	},
	Flipflop: {
		phase2Set: props.globals.initNode("/ECAM/phases/flipflop/phase-2-set", 0, "BOOL"),
		phase2Reset: props.globals.initNode("/ECAM/phases/flipflop/phase-2-reset", 0, "BOOL"),
		phase2Output: props.globals.initNode("/ECAM/phases/flipflop/phase-2-output", 0, "BOOL"),
		phase2OutputTemp: 0,
		phase10Set: props.globals.initNode("/ECAM/phases/flipflop/phase-10-set", 0, "BOOL"),
		phase10Reset: props.globals.initNode("/ECAM/phases/flipflop/phase-10-reset", 0, "BOOL"),
		phase10Output: props.globals.initNode("/ECAM/phases/flipflop/phase-10-output", 0, "BOOL"),
		recallSet: props.globals.initNode("/ECAM/flipflop/recall-set", 0, "BOOL"),
		recallReset: props.globals.initNode("/ECAM/flipflop/recall-reset", 0, "BOOL"),
		recallOutput: props.globals.initNode("/ECAM/flipflop/recall-output", 0, "BOOL"),
		recallOutputTemp: 0,
	},
	Logic: {
		gnd: props.globals.getNode("/ECAM/logic/ground-calc-immediate"),
		IRSinAlign: props.globals.initNode("/ECAM/irs-in-align", 0, "BOOL"),
		feet1500: props.globals.getNode("/ECAM/phases/phase-calculation/altitude-ge-1500"),
		feet800: props.globals.getNode("/ECAM/phases/phase-calculation/altitude-ge-800"),
	},
	Timer: {
		eng1idle: props.globals.getNode("/ECAM/phases/timer/eng1idle"),
		eng2idle: props.globals.getNode("/ECAM/phases/timer/eng2idle"),
		eng1or2: props.globals.getNode("/ECAM/phases/phase-calculation/one-engine-running"),
		toInhibit: props.globals.initNode("/ECAM/phases/timer/to-inhibit", 0, "INT"),
		ldgInhibit: props.globals.initNode("/ECAM/phases/timer/ldg-inhibit", 0, "INT"),
		eng1idleOutput: props.globals.getNode("/ECAM/phases/timer/eng1idle-output"),
		eng2idleOutput: props.globals.getNode("/ECAM/phases/timer/eng2idle-output"),
		eng1and2Off: props.globals.getNode("/ECAM/phases/phase-calculation/engines-1-2-not-running"),
		eng1and2OffTemp: 0,
		eng1or2Output: props.globals.getNode("/ECAM/phases/phase-calculation/engine-1-or-2-running"),
		eng1or2OutputTemp: 0,
		toInhibitOutput: props.globals.getNode("/ECAM/phases/timer/to-inhibit-output"),
		ldgInhibitOutput: props.globals.getNode("/ECAM/phases/timer/ldg-inhibit-output"),
		gnd: props.globals.getNode("/ECAM/timer/ground-calc"), # ZGND
		gnd2Sec: props.globals.getNode("/ECAM/phases/monostable/gnd-output"),
		gnd2SecHalf: props.globals.getNode("/ECAM/phases/monostable/gnd-output-2"), # hack to prevent getting confused between phase 5 / 6
	},
	speed80: props.globals.initNode("/ECAM/phases/speed-gt-80", 0, "BOOL"),
	speed80Temp: 0,
	toPower: props.globals.getNode("/ECAM/phases/phase-calculation/takeoff-power"),
	toPowerTemp: 0,
	altChg: props.globals.getNode("/it-autoflight/input/alt-is-changing", 1),
};

var gnd = nil;
var gndTimer = nil;

var phaseLoop = func() {
	if ((systems.ELEC.Bus.acEss.getValue() < 110 and systems.ELEC.Bus.ac2.getValue() < 110) or pts.Acconfig.running.getBoolValue()) { return; }
	if (pts.Sim.Replay.replayActive.getBoolValue()) { return; }
	
	currentPhase = pts.ECAM.fwcWarningPhase.getValue();
	gnd = FWC.Logic.gnd.getBoolValue();
	gndTimer = FWC.Timer.gnd.getValue();
	
	if (FWC.Flipflop.recallReset.getValue() != 0) {
		FWC.Flipflop.recallReset.setValue(0);
	}
		
	gear_agl_cur = pts.Position.gearAglFt.getValue();
	FWC.toPowerTemp = FWC.toPower.getBoolValue();
	FWC.Timer.eng1and2OffTemp = FWC.Timer.eng1and2Off.getValue();
	FWC.Timer.eng1or2OutputTemp = FWC.Timer.eng1or2Output.getBoolValue();
	FWC.speed80Temp = FWC.speed80.getBoolValue();
	
	FWC.Monostable.phase1OutputTemp = FWC.Monostable.phase1Output.getBoolValue();
	FWC.Flipflop.phase2OutputTemp = FWC.Flipflop.phase2Output.getBoolValue();
	FWC.Monostable.phase5Temp = FWC.Monostable.phase5.getBoolValue();
	FWC.Monostable.phase5OutputTemp = FWC.Monostable.phase5Output.getBoolValue();
	FWC.Monostable.phase7Temp = FWC.Monostable.phase7.getBoolValue();
	FWC.Monostable.phase7OutputTemp = FWC.Monostable.phase7Output.getBoolValue();
	
	# Set Phases
	if ((gnd and FWC.Timer.eng1and2OffTemp and currentPhase != 9) and !FWC.Monostable.phase1OutputTemp) {
		setPhase(1);
	}
	
	if (FWC.Timer.eng1or2OutputTemp and (gnd and !FWC.toPowerTemp and !FWC.speed80Temp) and !FWC.Flipflop.phase2OutputTemp) {
		setPhase(2);
	}
	
	if (FWC.Timer.eng1or2OutputTemp and (gndTimer == 1 and FWC.toPowerTemp) and !FWC.speed80Temp) {
		setPhase(3);
	}
	
	if ((gndTimer == 1 and FWC.toPowerTemp) and FWC.speed80Temp) {
		setPhase(4);
	}
	
	if (FWC.Monostable.phase5Temp and FWC.Monostable.phase5OutputTemp) {
		setPhase(5);
	}
	
	if (!gnd and FWC.Timer.gnd2SecHalf.getValue() != 1 and (!FWC.Monostable.phase5Temp or !FWC.Monostable.phase5OutputTemp) and (!FWC.Monostable.phase7Temp or !FWC.Monostable.phase7OutputTemp)) {
		setPhase(6);
	}
	
	if ((FWC.Monostable.phase7Temp and FWC.Monostable.phase7OutputTemp) and currentPhase != 8) {
		setPhase(7);
	}
	
	if (!FWC.toPowerTemp and FWC.speed80Temp and (gnd or FWC.Timer.gnd2Sec.getValue() == 1)) {
		setPhase(8);
	}
	
	if (FWC.Flipflop.phase2OutputTemp and (gnd and !FWC.toPowerTemp and !FWC.speed80Temp) and FWC.Timer.eng1or2.getBoolValue()) {
		setPhase(9);
	}
	
	if ((gnd and FWC.Timer.eng1and2OffTemp and currentPhase == 9) and FWC.Monostable.phase1OutputTemp) {
		setPhase(10);
	}
	
	# FWC Inhibiting
	currentPhase = pts.ECAM.fwcWarningPhase.getValue();
	FWC.Flipflop.recallOutputTemp = FWC.Flipflop.recallOutput.getValue();
	if (currentPhase >= 3 and currentPhase <= 5 and !FWC.Flipflop.recallOutputTemp) {
		FWC.Timer.toInhibit.setValue(1);
	} else {
		FWC.Timer.toInhibit.setValue(0);
	}
	
	if (currentPhase == 7 or currentPhase == 8 and !FWC.Flipflop.recallOutputTemp) {
		FWC.Timer.ldgInhibit.setValue(1);
	} else {
		FWC.Timer.ldgInhibit.setValue(0);
	}
}

var _lastPhase = nil;
var setPhase = func(newPhase) {
	if (newPhase >= 1 and newPhase <= 10 and _lastPhase != newPhase) {
		pts.ECAM.fwcWarningPhase.setValue(newPhase);
		FWC.Flipflop.recallReset.setValue(1);
		_lastPhase = newPhase;
	}
}

setlistener("/ECAM/buttons/recall-btn", func() {
	FWC.Flipflop.recallSet.setValue(FWC.Btn.recall.getBoolValue());
}, 0, 0);

var clrBtn = func(btn) {
	FWC.Btn.clr.setValue(btn);
}
