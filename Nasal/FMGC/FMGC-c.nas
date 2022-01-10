# A3XX FMGC/Autoflight
# Copyright (c) 2021 Josh Davidson (Octal450) and Jonathan Redpath (legoboyvdlp)

var at = nil;
var athr = nil;
var elapsedtime = nil;
var engout = nil;
var engstate1 = nil;
var engstate2 = nil;
var flx = nil;
var gs_defl = nil;
var latText = nil;
var nav_defl = nil;
var newfd = nil;
var newarm = nil;
var newap = nil;
var newlat = nil;
var newvert = nil;
var newvert2arm = nil;
var newvertarm = nil;
var newthr = nil;
var state1 = nil;
var state2 = nil;
var thr = nil;
var trk = nil;
var vert = nil;
var vertText = nil;


var Modes = {
	FCU: {
		hdgTime: props.globals.initNode("/modes/fcu/hdg-time", -45, "DOUBLE")
	},
	PFD: {
		FMA: {
			athr: props.globals.initNode("/modes/pfd/fma/athr-armed", 0, "BOOL"),
			athrBox: props.globals.initNode("/modes/pfd/fma/athr-armed-box", 0, "BOOL"),
			athrMode: props.globals.initNode("/modes/pfd/fma/at-mode", " ", "STRING"),
			athrModeBox: props.globals.initNode("/modes/pfd/fma/athr-mode-box", 0, "BOOL"),
			apMode: props.globals.initNode("/modes/pfd/fma/ap-mode", " ", "STRING"),
			apModeBox: props.globals.initNode("/modes/pfd/fma/ap-mode-box", 0, "BOOL"),
			apModeTime: props.globals.initNode("/modes/pfd/fma/ap-mode-time", 0, "DOUBLE"),
			athrModeTime: props.globals.initNode("/modes/pfd/fma/athr-mode-time", 0, "DOUBLE"),
			fdMode: props.globals.initNode("/modes/pfd/fma/fd-mode", " ", "STRING"),
			fdModeBox: props.globals.initNode("/modes/pfd/fma/fd-mode-box", 0, "BOOL"),
			fdModeTime: props.globals.initNode("/modes/pfd/fma/fd-mode-time", 0, "DOUBLE"),
			rollMode: props.globals.initNode("/modes/pfd/fma/roll-mode", " ", "STRING"),
			rollModeBox: props.globals.initNode("/modes/pfd/fma/roll-mode-box", 0, "BOOL"),
			rollModeArmed: props.globals.initNode("/modes/pfd/fma/roll-mode-armed", " ", "STRING"),
			rollModeArmedBox: props.globals.initNode("/modes/pfd/fma/roll-mode-armed-box", 0, "BOOL"),
			rollModeTime: props.globals.initNode("/modes/pfd/fma/roll-mode-time", 0, "DOUBLE"),
			rollModeArmedTime: props.globals.initNode("/modes/pfd/fma/roll-mode-armed-time", 0, "DOUBLE"),
			pitchMode: props.globals.initNode("/modes/pfd/fma/pitch-mode", " ", "STRING"),
			pitchModeBox: props.globals.initNode("/modes/pfd/fma/pitch-mode-box", 0, "BOOL"),
			pitchModeArmed: props.globals.initNode("/modes/pfd/fma/pitch-mode-armed", " ", "STRING"),
			pitchModeArmedBox: props.globals.initNode("/modes/pfd/fma/pitch-mode-armed-box", 0, "BOOL"),
			pitchMode2Armed: props.globals.initNode("/modes/pfd/fma/pitch-mode2-armed", " ", "STRING"),
			pitchModeTime: props.globals.initNode("/modes/pfd/fma/pitch-mode-time", 0, "DOUBLE"),
			pitchModeArmedTime: props.globals.initNode("/modes/pfd/fma/pitch-mode-armed-time", 0, "DOUBLE"),
			pitchMode2ArmedTime: props.globals.initNode("/modes/pfd/fma/pitch-mode2-armed-time", 0, "DOUBLE"),
			pitchMode2ArmedBox: props.globals.initNode("/modes/pfd/fma/pitch-mode2-armed-box", 0, "BOOL"),
			throttle: props.globals.initNode("/modes/pfd/fma/throttle-mode", " ", "STRING"),
			throttleModeBox: props.globals.initNode("/modes/pfd/fma/throttle-mode-box", 0, "BOOL"),
			throttleModeTime: props.globals.initNode("/modes/pfd/fma/throttle-mode-time", 0, "DOUBLE"),
		},
	},
};

var init = func() {
	Internal.alt.setValue(10000);
	Modes.PFD.FMA.throttle.setValue(" ");
	Modes.PFD.FMA.pitchMode.setValue(" ");
	Modes.PFD.FMA.pitchModeArmed.setValue(" ");
	Modes.PFD.FMA.pitchMode2Armed.setValue(" ");
	Modes.PFD.FMA.rollMode.setValue(" ");
	Modes.PFD.FMA.rollModeArmed.setValue(" ");
	Modes.PFD.FMA.apMode.setValue(" ");
	Modes.PFD.FMA.fdMode.setValue(" ");
	Modes.PFD.FMA.athrMode.setValue(" ");
	Modes.PFD.FMA.athr.setValue(0);
	Modes.PFD.FMA.throttleModeBox.setValue(0);
	Modes.PFD.FMA.pitchModeBox.setValue(0);
	Modes.PFD.FMA.pitchModeArmedBox.setValue(0);
	Modes.PFD.FMA.pitchMode2ArmedBox.setValue(0);
	Modes.PFD.FMA.rollModeBox.setValue(0);
	Modes.PFD.FMA.rollModeArmedBox.setValue(0);
	Modes.PFD.FMA.apModeBox.setValue(0);
	Modes.PFD.FMA.fdModeBox.setValue(0);
	Modes.PFD.FMA.athrModeBox.setValue(0);
	Modes.PFD.FMA.throttleModeTime.setValue(0);
	Modes.PFD.FMA.pitchModeTime.setValue(0);
	Modes.PFD.FMA.pitchModeArmedTime.setValue(0);
	Modes.PFD.FMA.pitchMode2ArmedTime.setValue(0);
	Modes.PFD.FMA.rollModeTime.setValue(0);
	Modes.PFD.FMA.rollModeArmedTime.setValue(0);
	Modes.PFD.FMA.apModeTime.setValue(0);
	Modes.PFD.FMA.fdModeTime.setValue(0);
	Modes.PFD.FMA.athrModeTime.setValue(0);
	loopFMA.start();
};

# Master Thrust
var loopFMA = maketimer(0.05, func() {
	state1 = systems.FADEC.detentText[0].getValue();
	state2 = systems.FADEC.detentText[1].getValue();
	newthr = Modes.PFD.FMA.throttle.getValue();
	engout = systems.FADEC.engOut.getValue();
	
	if (state1 == "TOGA" or state2 == "TOGA") {
		if (newthr != "   ") {
			Modes.PFD.FMA.throttle.setValue("   ");
		}
	} else if ((state1 == "MAN THR" and systems.FADEC.manThrAboveMct[0]) or (state2 == "MAN THR" and systems.FADEC.manThrAboveMct[1])) {
		if (newthr != "   ") {
			Modes.PFD.FMA.throttle.setValue("   ");
		}
	} else if ((state1 == "MCT" or state2 == "MCT") and !engout) {
		if (newthr != "  ") {
			Modes.PFD.FMA.throttle.setValue("  ");
		}
	} else if (((state1 == "MAN THR" and !systems.FADEC.manThrAboveMct[0]) or (state2 == "MAN THR" and !systems.FADEC.manThrAboveMct[1])) and !engout) {
		if (newthr != " ") {
			Modes.PFD.FMA.throttle.setValue(" ");
		}
	} else {
		vert = Output.vert.getValue();
		if (vert == 4 or vert >= 6 or vert <= 8) {
			if (Output.ap1.getBoolValue() or Output.ap2.getBoolValue() or Output.fd1.getBoolValue() or Output.fd2.getBoolValue()) {
				thr = Output.thrMode.getValue();
				if (thr == 0) {
					updateFMAThrottleMode();
				} else if (thr == 1) {
					if (newthr != "THR IDLE") {
						Modes.PFD.FMA.throttle.setValue("THR IDLE");
					}
				} else if (thr == 2) {
					if (state1 == "MCT" or state2 == "MCT" and engout) {
						if (newthr != "THR MCT") {
							Modes.PFD.FMA.throttle.setValue("THR MCT");
						}
					} else if (state1 == "CL" or state2 == "CL") {
						if (newthr != "THR CLB") {
							Modes.PFD.FMA.throttle.setValue("THR CLB");
						}
					} else {
						if (newthr != "THR LVR") {
							Modes.PFD.FMA.throttle.setValue("THR LVR");
						}
					}
				}
			} else {
				updateFMAThrottleMode();
			}
		} else {
			updateFMAThrottleMode();
		}
	}
	
	# A/THR Armed/Active
	athr = Output.athr.getValue();
	
	if (athr and (state1 == "MAN THR" or state2 == "MAN THR" or state1 == "MCT" or state2 == "MCT" or state1 == "TOGA" or state2 == "TOGA") and engout != 1) {
		if (!Modes.PFD.FMA.athr.getValue()) {
			Modes.PFD.FMA.athr.setValue(1);
		}
	} else if (athr and ((state1 == "MAN THR" and systems.FADEC.manThrAboveMct[0]) or (state2 == "MAN THR" and systems.FADEC.manThrAboveMct[1]) or (systems.FADEC.Limit.activeMode.getValue() == "FLX" and (state1 == "MCT" or state2 == "MCT")) 
	or state1 == "TOGA" or state2 == "TOGA") and engout) {
		if (!Modes.PFD.FMA.athr.getValue()) {
			Modes.PFD.FMA.athr.setValue(1);
		}
	} else {
		if (Modes.PFD.FMA.athr.getValue()) {
			Modes.PFD.FMA.athr.setValue(0);
		}
	}
	
	# SRS RWY Engagement
	if (pts.Gear.wow[1].getValue() or pts.Gear.wow[2].getValue()) {
		flx = systems.FADEC.Limit.flexActive.getBoolValue();
		newlat = Modes.PFD.FMA.rollMode.getValue();
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
	if (Modes.PFD.FMA.apModeTime.getValue() + 10 >= elapsedtime) {
		Modes.PFD.FMA.apModeBox.setValue(1);
	} else {
		Modes.PFD.FMA.apModeBox.setValue(0);
	}
	if (Modes.PFD.FMA.fdModeTime.getValue() + 10 >= elapsedtime) {
		Modes.PFD.FMA.fdModeBox.setValue(1);
	} else {
		Modes.PFD.FMA.fdModeBox.setValue(0);
	}
	if (Modes.PFD.FMA.athrModeTime.getValue() + 10 >= elapsedtime) {
		Modes.PFD.FMA.athrModeBox.setValue(1);
	} else {
		Modes.PFD.FMA.athrModeBox.setValue(0);
	}
	if (Modes.PFD.FMA.throttleModeTime.getValue() + 10 >= elapsedtime) {
		Modes.PFD.FMA.throttleModeBox.setValue(1);
	} else {
		Modes.PFD.FMA.throttleModeBox.setValue(0);
	}
	if (Modes.PFD.FMA.rollModeTime.getValue() + 10 >= elapsedtime) {
		Modes.PFD.FMA.rollModeBox.setValue(1);
	} else {
		Modes.PFD.FMA.rollModeBox.setValue(0);
	}
	if (Modes.PFD.FMA.pitchModeTime.getValue() + 10 >= elapsedtime) {
		Modes.PFD.FMA.pitchModeBox.setValue(1);
	} else {
		Modes.PFD.FMA.pitchModeBox.setValue(0);
	}
	if (Modes.PFD.FMA.rollModeArmedTime.getValue() + 10 >= elapsedtime) {
		Modes.PFD.FMA.rollModeArmedBox.setValue(1);
	} else {
		Modes.PFD.FMA.rollModeArmedBox.setValue(0);
	}
	if (Modes.PFD.FMA.pitchModeArmedTime.getValue() + 10 >= elapsedtime) {
		Modes.PFD.FMA.pitchModeArmedBox.setValue(1);
	} else {
		Modes.PFD.FMA.pitchModeArmedBox.setValue(0);
	}
	if (Modes.PFD.FMA.pitchMode2ArmedTime.getValue() + 10 >= elapsedtime) {
		Modes.PFD.FMA.pitchMode2ArmedBox.setValue(1);
	} else {
		Modes.PFD.FMA.pitchMode2ArmedBox.setValue(0);
	}
});

var updateFMAThrottleMode = func() {
	newthr = Modes.PFD.FMA.throttle.getValue();
	if (!Input.ktsMach.getValue()) {
		if (newthr != "SPEED") {
			Modes.PFD.FMA.throttle.setValue("SPEED");
		}
	} else {
		if (newthr != "MACH") {
			Modes.PFD.FMA.throttle.setValue("MACH");
		}
	}
}

# Master FMA
var updateFma = {
	lat: func() {
		latText = Text.lat.getValue();
		newlat = Modes.PFD.FMA.rollMode.getValue();
		if (latText == "HDG") {
			if (Custom.trkFpa.getValue()) {
				if (newlat != "TRACK") {
					Modes.PFD.FMA.rollMode.setValue("TRACK");
				}
			} else {
				if (newlat != "HDG") {
					Modes.PFD.FMA.rollMode.setValue("HDG");
				}
			}
		} else if (latText == "LNAV") {
			if (newlat != "NAV") {
				Modes.PFD.FMA.rollMode.setValue("NAV");
			}
		} else if (latText == "LOC") {
			if (newlat != "LOC*" and newlat != "LOC") {
				Modes.PFD.FMA.rollMode.setValue("LOC*");
				locupdate.start();
			}
		} else if (latText == "ALGN") {
			if (newlat != " ") {
				Modes.PFD.FMA.rollMode.setValue(" ");
			}
		} else if (latText == "RLOU") {
			if (newlat != " ") {
				Modes.PFD.FMA.rollMode.setValue(" ");
			}
		} else if (latText == "T/O") {
			if (newlat != "RWY") {
				Modes.PFD.FMA.rollMode.setValue("RWY");
			}
		} else if (latText == "") {
			if (newlat != " ") {
				Modes.PFD.FMA.rollMode.setValue(" ");
			}
		}
	},
	vert: func() {
		vertText = Text.vert.getValue();
		newvert = Modes.PFD.FMA.pitchMode.getValue();
		newvertarm = Modes.PFD.FMA.pitchMode2Armed.getValue();
		if (vertText == "ALT HLD") {
			altvert();
			if (newvertarm != " ") {
				Modes.PFD.FMA.pitchMode2Armed.setValue(" ");
			}
		} else if (vertText == "ALT CAP") {
			altvert();
			if (newvertarm != " ") {
				Modes.PFD.FMA.pitchMode2Armed.setValue(" ");
			}
		} else if (vertText == "V/S") {
			if (newvert != "V/S") {
				Modes.PFD.FMA.pitchMode.setValue("V/S");
			}
			if (newvertarm != "ALT") {
				Modes.PFD.FMA.pitchMode2Armed.setValue("ALT");
			}
		} else if (vertText == "G/S") {
			if (newvert != "G/S*" and newvert != "G/S") {
				Modes.PFD.FMA.pitchMode.setValue("G/S*");
				gsupdate.start();
			}
			if (newvertarm != " ") {
				Modes.PFD.FMA.pitchMode2Armed.setValue(" ");
			}
		} else if (vertText == "SPD CLB") {
			if (newvert != "OP CLB") {
				Modes.PFD.FMA.pitchMode.setValue("OP CLB");
			}
			if (newvertarm != "ALT") {
				Modes.PFD.FMA.pitchMode2Armed.setValue("ALT");
			}
		} else if (vertText == "SPD DES") {
			if (newvert != "OP DES") {
				Modes.PFD.FMA.pitchMode.setValue("OP DES");
			}
			if (newvertarm != "ALT") {
				Modes.PFD.FMA.pitchMode2Armed.setValue("ALT");
			}
		} else if (vertText == "FPA") {
			if (newvert != "FPA") {
				Modes.PFD.FMA.pitchMode.setValue("FPA");
			}
			if (newvertarm != "ALT") {
				Modes.PFD.FMA.pitchMode2Armed.setValue("ALT");
			}
		} else if (vertText == "LAND") {
			if (newvert != "LAND") {
				Modes.PFD.FMA.pitchMode.setValue("LAND");
			}
		} else if (vertText == "FLARE") {
			if (newvert != "FLARE") {
				Modes.PFD.FMA.pitchMode.setValue("FLARE");
			}
		} else if (vertText == "ROLLOUT") {
			if (newvert != "ROLL OUT") {
				Modes.PFD.FMA.pitchMode.setValue("ROLL OUT");
			}
		} else if (vertText == "T/O CLB") {
			if (newvert != "SRS") {
				Modes.PFD.FMA.pitchMode.setValue("SRS");
			}
			updatePitchArm2();
		} else if (vertText == "G/A CLB") {
			if (newvert != "SRS") {
				Modes.PFD.FMA.pitchMode.setValue("SRS");
			}
			if (newvertarm != "ALT") {
				Modes.PFD.FMA.pitchMode2Armed.setValue("ALT");
			}
		} else if (vertText == "") {
			if (newvert != " ") {
				Modes.PFD.FMA.pitchMode.setValue(" ");
			}
			updatePitchArm2();
		}
		altvert();
	},
	arm: func() {
		if (Output.locArm.getBoolValue()) {
			Modes.PFD.FMA.rollModeArmed.setValue("LOC");
		} else if (Output.lnavArm.getBoolValue()) {
			Modes.PFD.FMA.rollModeArmed.setValue("NAV");
		} else {
			Modes.PFD.FMA.rollModeArmed.setValue(" ");
		}
		if (Output.apprArm.getBoolValue()) {
			Modes.PFD.FMA.pitchModeArmed.setValue("G/S");
		} else {
			Modes.PFD.FMA.pitchModeArmed.setValue(" ");
		}
	},
};

# Update localizer and glideslope
var locupdate = maketimer(0.5, func() {
	nav_defl = pts.Instrumentation.Nav.locDeflection.getValue();
	if (Text.lat.getValue() == "LOC") {
		if (nav_defl > -0.06 and nav_defl < 0.06) {
			locupdate.stop();
			if (Modes.PFD.FMA.rollMode.getValue() != "LOC") {
				Modes.PFD.FMA.rollMode.setValue("LOC");
			}
		}
	}
});

var gsupdate = maketimer(0.5, func() {
	gs_defl = pts.Instrumentation.Nav.gsDeflection.getValue();
	if (Text.vert.getValue() == "G/S") {
		if (gs_defl > -0.06 and gs_defl < 0.06) {
			gsupdate.stop();
			if (Modes.PFD.FMA.pitchMode.getValue() != "G/S") {
				Modes.PFD.FMA.pitchMode.setValue("G/S");
			}
		}
	}
});

# Vertical Special
var updatePitchArm2 = func() {
	newvertarm = Modes.PFD.FMA.pitchMode2Armed.getValue();
	if (newvertarm != "CLB" and FMGCInternal.v2set) {
		Modes.PFD.FMA.pitchMode2Armed.setValue("CLB");
	} else if (newvertarm != " " and !FMGCInternal.v2set) {
		Modes.PFD.FMA.pitchMode2Armed.setValue(" ");
	}
}


var altvert = func() {
	vertText = Text.vert.getValue();
	newvert = Modes.PFD.FMA.pitchMode.getValue();
	
	if (abs(fmgc.FMGCInternal.crzFt - Internal.alt.getValue()) <= 20) {
		if (vertText == "ALT HLD") {
			if (newvert != "ALT CRZ") {
				Modes.PFD.FMA.pitchMode.setValue("ALT CRZ");
			}
		} else if (vertText == "ALT CAP") {
			if (newvert != "ALT CRZ*") {
				Modes.PFD.FMA.pitchMode.setValue("ALT CRZ*");
			}
		}
	} else {
		if (vertText == "ALT HLD") {
			if (newvert != "ALT") {
				Modes.PFD.FMA.pitchMode.setValue("ALT");
			}
		} else if (vertText == "ALT CAP") {
			if (newvert != "ALT*") {
				Modes.PFD.FMA.pitchMode.setValue("ALT*");
			}
		}
	}
}

# AP
var ap1 = nil;
var ap2 = nil;
var apTextVector = [nil, nil, nil, nil];
var fmaAp = func() {
	ap1 = Output.ap1.getValue();
	ap2 = Output.ap2.getValue();
	
	apTextVector[0] = (ap1 or ap2) ? "AP " : " ";
	apTextVector[1] = ap1 ? "1" : "";
	apTextVector[2] = (ap1 and ap2) ? "+" : "";
	apTextVector[3] = ap2 ? "2" : "";
	Modes.PFD.FMA.apMode.setValue(apTextVector[0] ~ apTextVector[1] ~ apTextVector[2] ~ apTextVector[3]);
}

# FD
var fd1 = nil;
var fd2 = nil;
var fdTextVector = [nil, nil, nil];
var fmaFd = func() {
	fd1 = Output.fd1.getValue();
	fd2 = Output.fd2.getValue();
	
	fdTextVector[0] = fd1 ? "1" : (fd2 ? "-" : "");
	fdTextVector[1] = (fd1 or fd2) ? " FD " : " ";
	fdTextVector[2] = fd2 ? "2" : (fd1 ? "-" : "");
	Modes.PFD.FMA.fdMode.setValue(fdTextVector[0] ~ fdTextVector[1] ~ fdTextVector[2]);
}

# A/THR
var fmaAthr = func() {
	Modes.PFD.FMA.athrMode.setValue( Output.athr.getValue() ? "A/THR" : " ");
}

var showAllBoxes = func() {
	elapsedtime = pts.Sim.Time.elapsedSec.getValue();
	if (Modes.PFD.FMA.rollMode.getValue() != " ") {
		Modes.PFD.FMA.rollModeTime.setValue(elapsedtime);
	}
	if (Modes.PFD.FMA.pitchMode.getValue() != " ") {
		Modes.PFD.FMA.pitchModeTime.setValue(elapsedtime);
	}
	if (Modes.PFD.FMA.rollModeArmed.getValue() != " ") {
		Modes.PFD.FMA.rollModeArmedTime.setValue(elapsedtime);
	}
	if (Modes.PFD.FMA.pitchModeArmed.getValue() != " ") {
		Modes.PFD.FMA.pitchModeArmedTime.setValue(elapsedtime);
	}
	if (Modes.PFD.FMA.pitchMode2Armed.getValue() != " ") {
		Modes.PFD.FMA.pitchMode2ArmedTime.setValue(elapsedtime);
	}
}

# Boxes
setlistener("/modes/pfd/fma/ap-mode", func() {
	if (Modes.PFD.FMA.apMode.getValue() != " ") {
		Modes.PFD.FMA.apModeTime.setValue(pts.Sim.Time.elapsedSec.getValue());
	}
}, 0, 0);

setlistener("/modes/pfd/fma/fd-mode", func() {
	if (Modes.PFD.FMA.fdMode.getValue() != " ") {
		Modes.PFD.FMA.fdModeTime.setValue(pts.Sim.Time.elapsedSec.getValue());
	}
}, 0, 0);

setlistener("/modes/pfd/fma/at-mode", func() {
	if (Modes.PFD.FMA.athrMode.getValue() != " ") {
		elapsedtime = pts.Sim.Time.elapsedSec.getValue();
		Modes.PFD.FMA.throttleModeTime.setValue(elapsedtime);
		Modes.PFD.FMA.athrModeTime.setValue(elapsedtime);
	}
}, 0, 0);

setlistener("/modes/pfd/fma/athr-armed", func() {
	if (Modes.PFD.FMA.athrMode.getValue() != " ") {
		Modes.PFD.FMA.athrModeTime.setValue(pts.Sim.Time.elapsedSec.getValue());
	}
}, 0, 0);

setlistener("/modes/pfd/fma/throttle-mode", func() {
	state1 = systems.FADEC.detentText[0].getValue();
	state2 = systems.FADEC.detentText[1].getValue();
	athr = Output.athr.getValue();
	if (athr == 1 and state1 != "MCT" and state2 != "MCT" and state1 != "MAN THR" and state2 != "MAN THR" and state1 != "TOGA" and state2 != "TOGA" and state1 != "IDLE" and state2 != "IDLE" and 
	!systems.FADEC.engOut.getValue()) {
		Modes.PFD.FMA.throttleModeTime.setValue(pts.Sim.Time.elapsedSec.getValue());
	} else if (athr == 1 and state1 != "TOGA" and state2 != "TOGA" and state1 != "IDLE" and state2 != "IDLE" and systems.FADEC.engOut.getValue()) {
		if (systems.FADEC.detent[0].getValue() <= 4 and systems.FADEC.detent[1].getValue() <= 4) {
			Modes.PFD.FMA.throttleModeTime.setValue(pts.Sim.Time.elapsedSec.getValue());
		}
	}
}, 0, 0);

setlistener("/modes/pfd/fma/roll-mode", func() {
	if (Modes.PFD.FMA.rollMode.getValue() != " ") {
		Modes.PFD.FMA.rollModeTime.setValue(pts.Sim.Time.elapsedSec.getValue());
	}
}, 0, 0);

setlistener("/modes/pfd/fma/pitch-mode", func() {
	if (Modes.PFD.FMA.pitchMode.getValue() != " ") {
		Modes.PFD.FMA.pitchModeTime.setValue(pts.Sim.Time.elapsedSec.getValue());
	}
}, 0, 0);

setlistener("/modes/pfd/fma/roll-mode-armed", func() {
	if (Modes.PFD.FMA.rollModeArmed.getValue() != " ") {
		Modes.PFD.FMA.rollModeArmedTime.setValue(pts.Sim.Time.elapsedSec.getValue());
	}
}, 0, 0);

setlistener("/modes/pfd/fma/pitch-mode-armed", func() {
	if (Modes.PFD.FMA.pitchModeArmed.getValue() != " ") {
		Modes.PFD.FMA.pitchModeArmedTime.setValue(pts.Sim.Time.elapsedSec.getValue());
	}
}, 0, 0);

setlistener("/modes/pfd/fma/pitch-mode2-armed", func() {
	if (Modes.PFD.FMA.pitchMode2Armed.getValue() != " ") {
		Modes.PFD.FMA.pitchMode2ArmedTime.setValue(pts.Sim.Time.elapsedSec.getValue());
	}
}, 0, 0);

setlistener("/sim/signals/fdm-initialized", func() {
	init();
});
