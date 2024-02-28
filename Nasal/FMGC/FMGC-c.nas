# A3XX FMGC/Autoflight
# Copyright (c) 2024 Josh Davidson (Octal450) and Jonathan Redpath (legoboyvdlp)

var at = nil;
var athr = nil;
var elapsedtime = nil;
var engout = nil;
var engstate1 = nil;
var engstate2 = nil;
var flx = nil;
var latText = nil;
var state1 = nil;
var state2 = nil;
var thr = nil;
var trk = nil;
var vert = nil;
var vertText = nil;


var Modes = {
	FCU: {
		hdgTime: -45,
	},
	PFD: {
		FMA: {
			apMode: " ",
			apModeBox: 0,
			apModeTime: 0,
			athrArmed: 0,
			athrMode: " ",
			athrModeBox: 0,
			athrModeTime: 0,
			fdMode: " ",
			fdModeBox: 0,
			fdModeTime: 0,
			rollMode: " ",
			rollModeBox: 0,
			rollModeArmed: " ",
			rollModeArmedBox: 0,
			rollModeTime: 0,
			rollModeArmedTime: 0,
			pitchMode: " ",
			pitchModeBox: 0,
			pitchModeArmed: " ",
			pitchModeArmedBox: 0,
			pitchMode2Armed: " ",
			pitchModeTime: 0,
			pitchModeArmedTime: 0,
			pitchMode2ArmedTime: 0,
			pitchMode2ArmedBox: 0,
			throttleMode: " ",
			throttleModeBox: 0,
			throttleModeTime: 0,
		},
	},
};

var setFmaText = func(node, value, callback, timerNode) {
	if (Modes.PFD.FMA[node] == value) { return; }
	Modes.PFD.FMA[node] = value;
   if (node == "pitchMode") { 
      fmgc.FMGCNodes.pitchMode.setValue(value);
   }
	call(callback, [node, timerNode]);
};

var genericCallback = func(modeNode, timerNode) {
	if (Modes.PFD.FMA[modeNode] != " ") {
		Modes.PFD.FMA[timerNode] = pts.Sim.Time.elapsedSec.getValue();
	}
}

var athrCallback = func(modeNode, timerNode) {
	if (Modes.PFD.FMA[modeNode] != " ") {
		elapsedtime = pts.Sim.Time.elapsedSec.getValue();
		Modes.PFD.FMA[timerNode] = elapsedtime;
		Modes.PFD.FMA.throttleModeTime = elapsedtime;
	}
}

var setAthrArmed = func(value) {
	if (Modes.PFD.FMA.athrArmed == value) { return; }
	Modes.PFD.FMA.athrArmed = value;
	if (Modes.PFD.FMA.athrMode != " ") {
		Modes.PFD.FMA.athrModeTime = pts.Sim.Time.elapsedSec.getValue();
	}
}

var throttleModeCallback = func(modeNode, timerNode) {
	state1 = systems.FADEC.detentText[0].getValue();
	state2 = systems.FADEC.detentText[1].getValue();
	athr = Output.athr.getValue();
	if (athr == 1 and state1 != "MCT" and state2 != "MCT" and state1 != "MAN THR" and state2 != "MAN THR" and state1 != "TOGA" and state2 != "TOGA" and state1 != "IDLE" and state2 != "IDLE" and 
	!systems.FADEC.engOut.getValue()) {
		Modes.PFD.FMA[timerNode] = pts.Sim.Time.elapsedSec.getValue();
	} else if (athr == 1 and state1 != "TOGA" and state2 != "TOGA" and state1 != "IDLE" and state2 != "IDLE" and systems.FADEC.engOut.getValue()) {
		if (systems.FADEC.detent[0].getValue() <= 4 and systems.FADEC.detent[1].getValue() <= 4) {
			Modes.PFD.FMA[timerNode] = pts.Sim.Time.elapsedSec.getValue();
		}
	}
}

var fma_init = func() {
	Internal.alt.setValue(10000);
	setFmaText("apMode", " ", genericCallback, "apModeTime");
	setFmaText("athrMode", " ", athrCallback, "athrModeTime");
	setFmaText("fdMode", " ", genericCallback, "fdModeTime");
	setFmaText("pitchMode", " ", genericCallback, "pitchModeTime");
	setFmaText("pitchModeArmed", " ", genericCallback, "pitchModeArmedTime");
	setFmaText("pitchMode2Armed", " ", genericCallback, "pitchMode2ArmedTime");
	setFmaText("rollMode", " ", genericCallback, "rollModeTime");
	setFmaText("rollModeArmed", " ", genericCallback, "rollModeArmedTime");
	setFmaText("throttleMode", " ", throttleModeCallback, "throttleModeTime");
	setAthrArmed(0);
	
	Modes.PFD.FMA.apModeBox = 0;
	Modes.PFD.FMA.athrModeBox = 0;
	Modes.PFD.FMA.fdModeBox = 0;
	Modes.PFD.FMA.pitchModeBox = 0;
	Modes.PFD.FMA.pitchModeArmedBox = 0;
	Modes.PFD.FMA.pitchMode2ArmedBox = 0;
	Modes.PFD.FMA.rollModeBox = 0;
	Modes.PFD.FMA.rollModeArmedBox = 0;
	Modes.PFD.FMA.throttleModeBox = 0;
	
	Modes.PFD.FMA.apModeTime = 0;
	Modes.PFD.FMA.athrModeTime = 0;
	Modes.PFD.FMA.fdModeTime = 0;
	Modes.PFD.FMA.pitchModeTime = 0;
	Modes.PFD.FMA.pitchModeArmedTime = 0;
	Modes.PFD.FMA.pitchMode2ArmedTime = 0;
	Modes.PFD.FMA.rollModeTime = 0;
	Modes.PFD.FMA.rollModeArmedTime = 0;
	Modes.PFD.FMA.throttleModeTime = 0;
	loopFMA.start();
};

# Master Thrust
var loopFMA = maketimer(0.05, func() {
	state1 = systems.FADEC.detentText[0].getValue();
	state2 = systems.FADEC.detentText[1].getValue();
	engout = systems.FADEC.engOut.getValue();
	
	if (state1 == "TOGA" or state2 == "TOGA") {
		setFmaText("throttleMode", "   ", throttleModeCallback, "throttleModeTime");
	} else if ((state1 == "MAN THR" and systems.FADEC.manThrAboveMct[0]) or (state2 == "MAN THR" and systems.FADEC.manThrAboveMct[1])) {
		setFmaText("throttleMode", "   ", throttleModeCallback, "throttleModeTime");
	} else if ((state1 == "MCT" or state2 == "MCT") and !engout) {
		setFmaText("throttleMode", "  ", throttleModeCallback, "throttleModeTime");
	} else if (((state1 == "MAN THR" and !systems.FADEC.manThrAboveMct[0]) or (state2 == "MAN THR" and !systems.FADEC.manThrAboveMct[1])) and !engout) {
		setFmaText("throttleMode", " ", throttleModeCallback, "throttleModeTime");
	} else {
		vert = Output.vert.getValue();
		if (vert == 4 or vert >= 6 or vert <= 8) {
			if (Output.ap1.getBoolValue() or Output.ap2.getBoolValue() or Output.fd1.getBoolValue() or Output.fd2.getBoolValue()) {
				thr = Output.thrMode.getValue();
				if (thr == 0) {
					setFmaText("throttleMode", Input.ktsMach.getValue() ? "MACH" : "SPEED", throttleModeCallback, "throttleModeTime");
				} else if (thr == 1) {
					setFmaText("throttleMode", "THR IDLE", throttleModeCallback, "throttleModeTime");
				} else if (thr == 2) {
					if (state1 == "MCT" or state2 == "MCT" and engout) {
						setFmaText("throttleMode", "THR MCT", throttleModeCallback, "throttleModeTime");
					} else if (state1 == "CL" or state2 == "CL") {
						setFmaText("throttleMode", "THR CLB", throttleModeCallback, "throttleModeTime");
					} else {
						setFmaText("throttleMode", "THR LVR", throttleModeCallback, "throttleModeTime");
					}
				}
			} else {
				setFmaText("throttleMode", Input.ktsMach.getValue() ? "MACH" : "SPEED", throttleModeCallback, "throttleModeTime");
			}
		} else {
			setFmaText("throttleMode", Input.ktsMach.getValue() ? "MACH" : "SPEED", throttleModeCallback, "throttleModeTime");
		}
	}
	
	# A/THR Armed/Active
	athr = Output.athr.getValue();
	if (athr and (state1 == "MAN THR" or state2 == "MAN THR" or state1 == "MCT" or state2 == "MCT" or state1 == "TOGA" or state2 == "TOGA") and engout != 1) {
		setAthrArmed(1);
	} else if (athr and ((state1 == "MAN THR" and systems.FADEC.manThrAboveMct[0]) or (state2 == "MAN THR" and systems.FADEC.manThrAboveMct[1]) or (systems.FADEC.Limit.activeMode.getValue() == "FLX" and (state1 == "MCT" or state2 == "MCT")) 
	or state1 == "TOGA" or state2 == "TOGA") and engout) {
		setAthrArmed(1);
	} else {
		setAthrArmed(0);
	}
	
	# SRS RWY Engagement
	if (pts.Gear.wow[1].getValue() or pts.Gear.wow[2].getValue()) {
		flx = systems.FADEC.Limit.flexActive.getBoolValue();
		engstate1 = pts.Engines.Engine.state[0].getValue();
		engstate2 = pts.Engines.Engine.state[1].getValue();
		if (((state1 == "TOGA" or state2 == "TOGA") or (flx == 1 and (state1 == "MCT" or state2 == "MCT")) or (flx == 1 and ((state1 == "MAN THR" and systems.FADEC.manThrAboveMct[0]) or (state2 == "MAN THR" and systems.FADEC.manThrAboveMct[1])))) and (engstate1 == 3 or engstate2 == 3)) {
			# RWY Engagement would go here, but automatic ILS selection is not simulated yet.
			if (FMGCInternal.v2set and Output.vert.getValue() != 7) {
				ITAF.setVertMode(7);
				ITAF.updateVertText("T/O CLB");
			}
		} else {
			if (Input.lat.getValue() == 5) {
				ITAF.setLatMode(9);
			}
			if (Input.vert.getValue() == 7) {
				ITAF.setVertMode(9);
			}
		}
	}
	
	# Boxes
	elapsedtime = pts.Sim.Time.elapsedSec.getValue();
	if (Modes.PFD.FMA.apModeTime + 10 >= elapsedtime) {
		Modes.PFD.FMA.apModeBox = 1;
	} else {
		Modes.PFD.FMA.apModeBox = 0;
	}
	if (Modes.PFD.FMA.fdModeTime + 10 >= elapsedtime) {
		Modes.PFD.FMA.fdModeBox = 1;
	} else {
		Modes.PFD.FMA.fdModeBox = 0;
	}
	if (Modes.PFD.FMA.athrModeTime + 10 >= elapsedtime) {
		Modes.PFD.FMA.athrModeBox = 1;
	} else {
		Modes.PFD.FMA.athrModeBox = 0;
	}
	if (Modes.PFD.FMA.throttleModeTime + 10 >= elapsedtime) {
		Modes.PFD.FMA.throttleModeBox = 1;
	} else {
		Modes.PFD.FMA.throttleModeBox = 0;
	}
	if (Modes.PFD.FMA.rollModeTime + 10 >= elapsedtime) {
		Modes.PFD.FMA.rollModeBox = 1;
	} else {
		Modes.PFD.FMA.rollModeBox = 0;
	}
	if (Modes.PFD.FMA.pitchModeTime + 10 >= elapsedtime) {
		Modes.PFD.FMA.pitchModeBox = 1;
	} else {
		Modes.PFD.FMA.pitchModeBox = 0;
	}
	if (Modes.PFD.FMA.rollModeArmedTime + 10 >= elapsedtime) {
		Modes.PFD.FMA.rollModeArmedBox = 1;
	} else {
		Modes.PFD.FMA.rollModeArmedBox = 0;
	}
	if (Modes.PFD.FMA.pitchModeArmedTime + 10 >= elapsedtime) {
		Modes.PFD.FMA.pitchModeArmedBox = 1;
	} else {
		Modes.PFD.FMA.pitchModeArmedBox = 0;
	}
	if (Modes.PFD.FMA.pitchMode2ArmedTime + 10 >= elapsedtime) {
		Modes.PFD.FMA.pitchMode2ArmedBox = 1;
	} else {
		Modes.PFD.FMA.pitchMode2ArmedBox = 0;
	}
});

# Master FMA
var updateFma = {
	lat: func() {
		latText = Text.lat.getValue();
		if (latText == "HDG") {
			setFmaText("rollMode", Custom.trkFpa.getValue() ? "TRACK" : "HDG", genericCallback, "rollModeTime");
		} else if (latText == "LNAV") {
			setFmaText("rollMode", "NAV", genericCallback, "rollModeTime");
		} else if (latText == "LOC") {
			if (Modes.PFD.FMA.rollMode != "LOC*" and Modes.PFD.FMA.rollMode != "LOC") {
				setFmaText("rollMode", "LOC*", genericCallback, "rollModeTime");
				locupdate.start();
			}
		} else if (latText == "T/O") {
			setFmaText("rollMode", "RWY", genericCallback, "rollModeTime");
		} else if (latText == "ALGN" or latText == "RLOU" or latText == "") {
			setFmaText("rollMode", " ", genericCallback, "rollModeTime");
		}
	},
	vert: func() {
		vertText = Text.vert.getValue();
		if (vertText == "ALT HLD" or vertText == "ALT CAP") {
			# altvert() call deals with this case
			setFmaText("pitchMode2Armed", " ", genericCallback, "pitchMode2ArmedTime");
		} else if (vertText == "V/S") {
			setFmaText("pitchMode", "V/S", genericCallback, "pitchModeTime");
			setFmaText("pitchMode2Armed", "ALT", genericCallback, "pitchMode2ArmedTime");
		} else if (vertText == "G/S") {
			if (Modes.PFD.FMA.pitchMode != "G/S*" and Modes.PFD.FMA.pitchMode != "G/S") {
				setFmaText("pitchMode", "G/S*", genericCallback, "pitchModeTime");
				gsupdate.start();
			}
			setFmaText("pitchMode2Armed", " ", genericCallback, "pitchMode2ArmedTime");
		} else if (vertText == "SPD CLB") {
			setFmaText("pitchMode", "OP CLB", genericCallback, "pitchModeTime");
			setFmaText("pitchMode2Armed", "ALT", genericCallback, "pitchMode2ArmedTime");
		} else if (vertText == "SPD DES") {
			setFmaText("pitchMode", "OP DES", genericCallback, "pitchModeTime");
			setFmaText("pitchMode2Armed", "ALT", genericCallback, "pitchMode2ArmedTime");
		} else if (vertText == "FPA") {
			setFmaText("pitchMode", "FPA", genericCallback, "pitchModeTime");
			setFmaText("pitchMode2Armed", "ALT", genericCallback, "pitchMode2ArmedTime");
		} else if (vertText == "LAND") {
			setFmaText("pitchMode", "LAND", genericCallback, "pitchModeTime");
		} else if (vertText == "FLARE") {
			setFmaText("pitchMode", "FLARE", genericCallback, "pitchModeTime");
		} else if (vertText == "ROLLOUT") {
			setFmaText("pitchMode", "ROLL OUT", genericCallback, "pitchModeTime");
		} else if (vertText == "T/O CLB") {
			if (Modes.PFD.FMA.pitchMode != "SRS") {
				setFmaText("pitchMode", "SRS", genericCallback, "pitchModeTime");
				setFmaText("pitchMode2Armed", FMGCInternal.v2set ? "CLB" : " ", genericCallback, "pitchMode2ArmedTime");
			}
		} else if (vertText == "G/A CLB") {
			setFmaText("pitchMode", "SRS", genericCallback, "pitchModeTime");
			setFmaText("pitchMode2Armed", "ALT", genericCallback, "pitchMode2ArmedTime");
		} else if (vertText == "") {
			if (Modes.PFD.FMA.pitchMode != " ") {
				setFmaText("pitchMode", " ", genericCallback, "pitchModeTime");
				setFmaText("pitchMode2Armed", FMGCInternal.v2set ? "CLB" : " ", genericCallback, "pitchMode2ArmedTime");
			}
		}
		altvert();
	},
	arm: func() {
		if (Output.locArm.getBoolValue()) {
			setFmaText("rollModeArmed", "LOC", genericCallback, "rollModeArmedTime");
		} else if (Output.lnavArm.getBoolValue()) {
			setFmaText("rollModeArmed", "NAV", genericCallback, "rollModeArmedTime");
		} else {
			setFmaText("rollModeArmed", " ", genericCallback, "rollModeArmedTime");
		}
		if (Output.apprArm.getBoolValue()) {
			setFmaText("pitchModeArmed", "G/S", genericCallback, "pitchModeArmedTime");
		} else {
			setFmaText("pitchModeArmed", " ", genericCallback, "pitchModeArmedTime");
		}
	},
};

# Update localizer and glideslope
var locupdate = maketimer(0.5, func() {
	if (Text.lat.getValue() == "LOC") {
		if (abs(pts.Instrumentation.Nav.locDeflection.getValue()) < 0.06) {
			locupdate.stop();
			setFmaText("rollMode", "LOC", genericCallback, "rollModeTime");
		}
	}
});

var gsupdate = maketimer(0.5, func() {
	if (Text.vert.getValue() == "G/S") {
		if (abs(pts.Instrumentation.Nav.gsDeflection.getValue()) < 0.06) {
			gsupdate.stop();
			setFmaText("pitchMode", "G/S", genericCallback, "pitchModeTime");
		}
	}
});

var altvert = func() {
	vertText = Text.vert.getValue();
	
	if (abs(fmgc.FMGCInternal.crzFt - Internal.alt.getValue()) <= 20) {
		if (vertText == "ALT HLD") {
			setFmaText("pitchMode", "ALT CRZ", genericCallback, "pitchModeTime");
		} else if (vertText == "ALT CAP") {
			setFmaText("pitchMode", "ALT CRZ*", genericCallback, "pitchModeTime");
		}
	} else {
		if (vertText == "ALT HLD") {
			setFmaText("pitchMode", "ALT", genericCallback, "pitchModeTime");
		} else if (vertText == "ALT CAP") {
			setFmaText("pitchMode", "ALT*", genericCallback, "pitchModeTime");
		}
	}
}

# AP
var ap1 = nil;
var ap2 = nil;
var apTextVector = [nil, nil, nil, nil];
var newApText = nil;
var fmaAp = func() {
	ap1 = Output.ap1.getValue();
	ap2 = Output.ap2.getValue();
	
	apTextVector[0] = (ap1 or ap2) ? "AP " : " ";
	apTextVector[1] = ap1 ? "1" : "";
	apTextVector[2] = (ap1 and ap2) ? "+" : "";
	apTextVector[3] = ap2 ? "2" : "";
	newApText = (apTextVector[0] ~ apTextVector[1] ~ apTextVector[2] ~ apTextVector[3]);
	setFmaText("apMode", newApText, genericCallback, "apModeTime");
}

# FD
var fd1 = nil;
var fd2 = nil;
var fdTextVector = [nil, nil, nil];
var newFdText = nil;
var fmaFd = func() {
	fd1 = Output.fd1.getValue();
	fd2 = Output.fd2.getValue();
	
	fdTextVector[0] = fd1 ? "1" : (fd2 ? "-" : "");
	fdTextVector[1] = (fd1 or fd2) ? " FD " : " ";
	fdTextVector[2] = fd2 ? "2" : (fd1 ? "-" : "");
	newFdText = (fdTextVector[0] ~ fdTextVector[1] ~ fdTextVector[2]);
	setFmaText("fdMode", newFdText, genericCallback, "fdModeTime");
}

# A/THR
var fmaAthr = func() {
	setFmaText("athrMode", (Output.athr.getValue() ? "A/THR" : " "), athrCallback, "athrModeTime");
}

var showAllBoxes = func() {
	elapsedtime = pts.Sim.Time.elapsedSec.getValue();
	if (Modes.PFD.FMA.rollMode != " ") {
		Modes.PFD.FMA.rollModeTime = elapsedtime;
	}
	if (Modes.PFD.FMA.pitchMode != " ") {
		Modes.PFD.FMA.pitchModeTime = elapsedtime;
	}
	if (Modes.PFD.FMA.rollModeArmed != " ") {
		Modes.PFD.FMA.rollModeArmedTime = elapsedtime;
	}
	if (Modes.PFD.FMA.pitchModeArmed != " ") {
		Modes.PFD.FMA.pitchModeArmedTime = elapsedtime;
	}
	if (Modes.PFD.FMA.pitchMode2Armed != " ") {
		Modes.PFD.FMA.pitchMode2ArmedTime = elapsedtime;
	}
}

setlistener("/sim/signals/fdm-initialized", func() {
	fma_init();
});
