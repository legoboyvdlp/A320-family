# A3XX FWC Phases

# Copyright (c) 2019 Jonathan Redpath (legoboyvdlp)

var myPhase = nil;
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
		phase7: props.globals.initNode("/ECAM/phases/monostable/phase-7", 0, "BOOL"),
		phase9: props.globals.initNode("/ECAM/phases/monostable/phase-9", 0, "BOOL"),
		phase1Output: props.globals.initNode("/ECAM/phases/monostable/phase-1-300-output"),
		phase5Output: props.globals.initNode("/ECAM/phases/monostable/phase-5-output"),
		phase7Output: props.globals.initNode("/ECAM/phases/monostable/phase-7-output"),
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
		phase10Set: props.globals.initNode("/ECAM/phases/flipflop/phase-10-set", 0, "BOOL"),
		phase10Reset: props.globals.initNode("/ECAM/phases/flipflop/phase-10-reset", 0, "BOOL"),
		phase10Output: props.globals.initNode("/ECAM/phases/flipflop/phase-10-output", 0, "BOOL"),
		recallSet: props.globals.initNode("/ECAM/flipflop/recall-set", 0, "BOOL"),
		recallReset: props.globals.initNode("/ECAM/flipflop/recall-reset", 0, "BOOL"),
		recallOutput: props.globals.initNode("/ECAM/flipflop/recall-output", 0, "BOOL"),
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
		eng1or2Output: props.globals.getNode("/ECAM/phases/phase-calculation/engine-1-or-2-running"),
		toInhibitOutput: props.globals.getNode("/ECAM/phases/timer/to-inhibit-output"),
		ldgInhibitOutput: props.globals.getNode("/ECAM/phases/timer/ldg-inhibit-output"),
		gnd: props.globals.getNode("/ECAM/timer/ground-calc"), # ZGND
		gnd2Sec: props.globals.getNode("/ECAM/phases/monostable/gnd-output"),
		gnd2SecHalf: props.globals.getNode("/ECAM/phases/monostable/gnd-output-2"), # hack to prevent getting confused between phase 5 / 6
	},
	speed80: props.globals.initNode("/ECAM/phases/speed-gt-80", 0, "BOOL"),
	toPower: props.globals.getNode("/ECAM/phases/phase-calculation/takeoff-power"),
	altChg: props.globals.getNode("/it-autoflight/input/alt-is-changing", 1),
};

var gnd = nil;
var gndTimer = nil;

var phaseLoop = func() {
	if ((systems.ELEC.Bus.acEss.getValue() < 110 and systems.ELEC.Bus.ac2.getValue() < 110) or pts.Acconfig.running.getBoolValue()) { return; }
	if (pts.Sim.Replay.replayActive.getBoolValue()) { return; }
	
	myPhase = pts.ECAM.fwcWarningPhase.getValue();
	eng = pts.Options.eng.getValue();
	eng1epr = pts.Engines.Engine.eprActual[0].getValue();
	eng2epr = pts.Engines.Engine.eprActual[1].getValue();
	eng1n1 = pts.Engines.Engine.n1Actual[0].getValue();
	eng2n1 = pts.Engines.Engine.n1Actual[1].getValue();
	master1 = pts.Controls.Engines.Engine.cutoffSw[0].getBoolValue();
	master2 = pts.Controls.Engines.Engine.cutoffSw[1].getBoolValue();
	gnd = FWC.Logic.gnd.getBoolValue();
	gndTimer = FWC.Timer.gnd.getValue();
	FWC.Flipflop.recallReset.setValue(0);
		
	# Various things
	
	if (myPhase == 9) {
		FWC.Monostable.phase9.setBoolValue(1);
	} else {
		FWC.Monostable.phase9.setBoolValue(0);
	}
	
	# Phase 1 / 10 flipflop
	if (myPhase == 9) {
		FWC.Flipflop.phase10Set.setBoolValue(1);
	} else {
		FWC.Flipflop.phase10Set.setBoolValue(0);
	}
	
	if (gndTimer == 1 and pts.Controls.Engines.Engine.firePb[0].getBoolValue()) {
		FWC.Flipflop.phase10Reset.setBoolValue(1);
	} else {
		FWC.Flipflop.phase10Reset.setBoolValue(0);
	}
	
	if ((gnd and FWC.Timer.eng1and2Off.getValue() and myPhase == 9) and FWC.Flipflop.phase10Output.getBoolValue()) {
		FWC.Monostable.phase1.setBoolValue(1); # true for 300 sec then false
	}	else {
		FWC.Monostable.phase1.setBoolValue(0);
	}
	
	# Phase 2 flipflop
	if (myPhase == 3 or myPhase == 8) {
		FWC.Flipflop.phase2Set.setBoolValue(1);
	} else {
		FWC.Flipflop.phase2Set.setBoolValue(0);
	}
	
	if (!FWC.Monostable.m80kt.getBoolValue() and myPhase != 9 and ((!FWC.Monostable.phase9Output.getBoolValue() and gndTimer == 1) or (!FWC.Monostable.toPowerOutput.getBoolValue() and gndTimer == 1))) {
		FWC.Flipflop.phase2Reset.setBoolValue(1);
	} else {
		FWC.Flipflop.phase2Reset.setBoolValue(0);
	}
	
	gear_agl_cur = pts.Position.gearAglFt.getValue();
	
	# Phase 5 monostable
	if (FWC.toPower.getBoolValue() and (!FWC.Logic.feet1500.getBoolValue() and !gnd and FWC.Timer.gnd2Sec.getValue() != 1)) {
		FWC.Monostable.phase5.setBoolValue(1);
	} else {
		FWC.Monostable.phase5.setBoolValue(0);
	}
	
	# Phase 7 monostable
	if (!FWC.toPower.getBoolValue() and !FWC.Logic.feet1500.getBoolValue() and !FWC.Logic.feet800.getBoolValue() and !gnd and FWC.Timer.gnd2Sec.getValue() != 1) {
		FWC.Monostable.phase7.setBoolValue(1);
	} else {
		FWC.Monostable.phase7.setBoolValue(0);
	}
	
	# Actual Phases
	if ((gnd and FWC.Timer.eng1and2Off.getValue() and myPhase != 9) and !FWC.Monostable.phase1Output.getBoolValue()) {
		setPhase(1);
	}
	
	if (FWC.Timer.eng1or2Output.getBoolValue() and (gnd and !FWC.toPower.getBoolValue() and !FWC.speed80.getBoolValue()) and !FWC.Flipflop.phase2Output.getBoolValue()) {
		setPhase(2);
	}
	
	if (FWC.Timer.eng1or2Output.getBoolValue() and (gndTimer == 1 and FWC.toPower.getBoolValue()) and !FWC.speed80.getBoolValue()) {
		setPhase(3);
	}
	
	if ((gndTimer == 1 and FWC.toPower.getBoolValue()) and FWC.speed80.getBoolValue()) {
		setPhase(4);
	}
	
	if (FWC.Monostable.phase5.getBoolValue() and FWC.Monostable.phase5Output.getBoolValue()) {
		setPhase(5);
	}
	
	if (!gnd and FWC.Timer.gnd2SecHalf.getValue() != 1 and (!FWC.Monostable.phase5.getBoolValue() or !FWC.Monostable.phase5Output.getBoolValue()) and (!FWC.Monostable.phase7.getBoolValue() or !FWC.Monostable.phase7Output.getBoolValue())) {
		setPhase(6);
	}
	
	if ((FWC.Monostable.phase7.getBoolValue() and FWC.Monostable.phase7Output.getBoolValue()) and myPhase != 8) {
		setPhase(7);
	}
	
	if (!FWC.toPower.getBoolValue() and FWC.speed80.getBoolValue() and (gnd or FWC.Timer.gnd2Sec.getValue == 1)) {
		setPhase(8);
	}
	
	if (FWC.Flipflop.phase2Output.getBoolValue() and (gnd and !FWC.toPower.getBoolValue() and !FWC.speed80.getBoolValue()) and FWC.Timer.eng1or2.getBoolValue()) {
		setPhase(9);
	}
	
	if ((gnd and FWC.Timer.eng1and2Off.getValue() and myPhase == 9) and FWC.Monostable.phase1Output.getBoolValue()) {
		setPhase(10);
	}
	
	# FWC Inhibiting
	myPhase = pts.ECAM.fwcWarningPhase.getValue();
	if (myPhase >= 3 and myPhase <= 5 and !FWC.Flipflop.recallOutput.getValue()) {
		FWC.Timer.toInhibit.setValue(1);
	} else {
		FWC.Timer.toInhibit.setValue(0);
	}
	
	if (myPhase == 7 or myPhase == 8 and !FWC.Flipflop.recallOutput.getValue()) {
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
