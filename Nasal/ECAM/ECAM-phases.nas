# A3XX FWC Phases
# Copyright (c) 2021 Jonathan Redpath (legoboyvdlp)

var currentPhase = nil;

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
