# A3XX FMGC/Autoflight
# Joshua Davidson (Octal450) and Jonathan Redpath (legoboyvdlp)

# Copyright (c) 2020 Josh Davidson (Octal450)

var at = nil;
var athr = nil;
var ap1 = nil;
var ap2 = nil;
var elapsedtime = nil;
var engout = nil;
var engstate1 = nil;
var engstate2 = nil;
var fd1 = nil;
var fd2 = nil;
var flx = nil;
var gear1 = nil;
var gear2 = nil;
var gs_defl = nil;
var latText = nil;
var MCPalt = nil;
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
var thr1 = nil;
var thr2 = nil;
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
var loopFMA = maketimer(0.05, func {
	state1 = pts.Systems.Thrust.state[0].getValue();
	state2 = pts.Systems.Thrust.state[1].getValue();
	thr1 = pts.Controls.Engines.Engine.throttlePos[0].getValue();
	thr2 = pts.Controls.Engines.Engine.throttlePos[1].getValue();
	newthr = Modes.PFD.FMA.throttle.getValue();
	engout = pts.Systems.Thrust.engOut.getValue();
	
	if (state1 == "TOGA" or state2 == "TOGA") {
		if (newthr != "   ") {
			Modes.PFD.FMA.throttle.setValue("   ");
		}
	} else if ((state1 == "MAN THR" and thr1 >= 0.83) or (state2 == "MAN THR" and thr2 >= 0.83)) {
		if (newthr != "   ") {
			Modes.PFD.FMA.throttle.setValue("   ");
		}
	} else if ((state1 == "MCT" or state2 == "MCT") and !engout) {
		if (newthr != "  ") {
			Modes.PFD.FMA.throttle.setValue("  ");
		}
	} else if (((state1 == "MAN THR" and thr1 < 0.83) or (state2 == "MAN THR" and thr2 < 0.83)) and !engout) {
		if (newthr != " ") {
			Modes.PFD.FMA.throttle.setValue(" ");
		}
	} else {
		vert = Output.vert.getValue();
		if (vert == 4 or vert >= 6 or vert <= 8) {
			if (Output.ap1.getBoolValue() or Output.ap2.getBoolValue() or Output.fd1.getBoolValue() or Output.fd2.getBoolValue()) {
				thr = Output.thrMode.getValue();
				if (thr == 0) {
					loopFMA_b();
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
				loopFMA_b();
			}
		} else {
			loopFMA_b();
		}
	}
	
	# A/THR Armed/Active
	athr = Output.athr.getValue();
	
	if (athr and (state1 == "MAN THR" or state2 == "MAN THR" or state1 == "MCT" or state2 == "MCT" or state1 == "TOGA" or state2 == "TOGA") and engout != 1) {
		if (!Modes.PFD.FMA.athr.getValue()) {
			Modes.PFD.FMA.athr.setValue(1);
		}
	} else if (athr and ((state1 == "MAN THR" and thr1 >= 0.83) or (state2 == "MAN THR" and thr2 >= 0.83) or (fadec.Thrust.thrustLimit.getValue() == "FLX" and (state1 == "MCT" or state2 == "MCT")) 
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
	flx = fadec.Thrust.limFlex.getValue();
	newlat = Modes.PFD.FMA.rollMode.getValue();
	engstate1 = pts.Engines.Engine.state[0].getValue();
	engstate2 = pts.Engines.Engine.state[1].getValue();
	if (((state1 == "TOGA" or state2 == "TOGA") or (flx == 1 and (state1 == "MCT" or state2 == "MCT")) or (flx == 1 and ((state1 == "MAN THR" and thr1 >= 0.83) or (state2 == "MAN THR" and thr2 >= 0.83)))) and (engstate1 == 3 or engstate2 == 3)) {
		# RWY Engagement would go here, but automatic ILS selection is not simulated yet.
		gear1 = pts.Gear.wow[0].getValue();
		if (gear1 and FMGCInternal.v2set and Output.vert.getValue() != 7) {
			ITAF.setVertMode(7);
			Text.vert.setValue("T/O CLB");
		}
	} else {
		gear1 = pts.Gear.wow[0].getValue();
		gear2 = pts.Gear.wow[2].getValue();
		if (Input.lat.getValue() == 5 and (gear1 or gear2)) {
			ITAF.setLatMode(9);
		}
		if (Input.vert.getValue() == 7 and (gear1 or gear2)) {
			ITAF.setVertMode(9);
		}
	}
	
	trk = Custom.trkFpa.getValue();
	latText = Text.lat.getValue();
	if (latText == "HDG" and trk == 0) {
		if (newlat != "HDG") {
			Modes.PFD.FMA.rollMode.setValue("HDG");
		}
	} else if (latText == "HDG" and trk == 1) {
		if (newlat != "TRACK") {
			Modes.PFD.FMA.rollMode.setValue("TRACK");
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

var loopFMA_b = func {
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

# Master Lateral
setlistener("/it-autoflight/mode/lat", func {
	latText = Text.lat.getValue();
	newlat = Modes.PFD.FMA.rollMode.getValue();
	if (latText == "LNAV") {
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
	} else if (latText == " ") {
		if (newlat != " ") {
			Modes.PFD.FMA.rollMode.setValue(" ");
		}
	}
});

var locupdate = maketimer(0.5, func {
	latText = Text.lat.getValue();
	newlat = Modes.PFD.FMA.rollMode.getValue();
	nav_defl = pts.Instrumentation.Nav.locDeflection.getValue();
	if (latText == "LOC") {
		if (nav_defl > -0.06 and nav_defl < 0.06) {
			locupdate.stop();
			if (newlat != "LOC") {
				Modes.PFD.FMA.rollMode.setValue("LOC");
			}
		}
	}
});

# Master Vertical
setlistener("/it-autoflight/mode/vert", func {
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
	} else if (vertText == " ") {
		if (newvert != " ") {
			Modes.PFD.FMA.pitchMode.setValue(" ");
		}
		updatePitchArm2();
	}
	altvert();
});

var updatePitchArm2 = func {
	newvertarm = Modes.PFD.FMA.pitchMode2Armed.getValue();
	if (newvertarm != "CLB" and FMGCInternal.v2set) {
		Modes.PFD.FMA.pitchMode2Armed.setValue("CLB");
	} else if (newvertarm != " " and !FMGCInternal.v2set) {
		Modes.PFD.FMA.pitchMode2Armed.setValue(" ");
	}
}

var gsupdate = maketimer(0.5, func {
	vertText = Text.vert.getValue();
	newvert = Modes.PFD.FMA.pitchMode.getValue();
	gs_defl = pts.Instrumentation.Nav.gsDeflection.getValue();
	if (vertText == "G/S") {
		if (gs_defl > -0.06 and gs_defl < 0.06) {
			gsupdate.stop();
			if (newvert != "G/S") {
				Modes.PFD.FMA.pitchMode.setValue("G/S");
			}
		}
	}
});

var altvert = func {
	MCPalt = Internal.alt.getValue();
	vertText = Text.vert.getValue();
	newvert = Modes.PFD.FMA.pitchMode.getValue();
	
	if (abs(fmgc.FMGCInternal.crzFt - MCPalt) <= 20) {
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

# Arm HDG or NAV
setlistener("/it-autoflight/mode/arm", func {
	arm = Text.arm.getValue();
	newarm = Modes.PFD.FMA.rollModeArmed.getValue();
	if (arm == "HDG") {
		if (newarm != "HDG") {
			Modes.PFD.FMA.rollModeArmed.setValue(" ");
		}
	} else if (arm == "LNV") {
		if (newarm != "NAV") {
			Modes.PFD.FMA.rollModeArmed.setValue("NAV");
		}
	} else if (arm == " ") {
		if (newarm != " ") {
			Modes.PFD.FMA.rollModeArmed.setValue(" ");
		}
	}
});

# Arm LOC
setlistener("/it-autoflight/output/loc-armed", func {
	newarm = Modes.PFD.FMA.rollModeArmed.getValue();
	if (Output.locArm.getValue()) {
		if (newarm != "LOC") {
			Modes.PFD.FMA.rollModeArmed.setValue("LOC");
		}
	} else {
		if (newarm != " ") {
			Modes.PFD.FMA.rollModeArmed.setValue(" ");
		}
	}
});

# Arm G/S
setlistener("/it-autoflight/output/appr-armed", func {
	newvert2arm = Modes.PFD.FMA.pitchModeArmed.getValue();
	if (Output.apprArm.getValue()) {
		if (newvert2arm != "G/S") {
			Modes.PFD.FMA.pitchModeArmed.setValue("G/S");
		}
	} else {
		if (newvert2arm != " ") {
			Modes.PFD.FMA.pitchModeArmed.setValue(" ");
		}
	}
});

# AP
var ap = func {
	ap1 = Output.ap1.getValue();
	ap2 = Output.ap2.getValue();
	newap = Modes.PFD.FMA.apMode.getValue();
	if (ap1 and ap2 and newap != "AP1+2") {
		Modes.PFD.FMA.apMode.setValue("AP 1+2");
	} else if (ap1 and !ap2 and newap != "AP 1") {
		Modes.PFD.FMA.apMode.setValue("AP 1");
	} else if (ap2 and !ap1 and newap != "AP 2") {
		Modes.PFD.FMA.apMode.setValue("AP 2");
	} else if (!ap1 and !ap2) {
		Modes.PFD.FMA.apMode.setValue(" ");
	}
}

# FD
var fd = func {
	fd1 = Output.fd1.getValue();
	fd2 = Output.fd2.getValue();
	newfd = Modes.PFD.FMA.fdMode.getValue();
	if (fd1 and fd2 and newfd != "1FD2") {
		Modes.PFD.FMA.fdMode.setValue("1 FD 2");
	} else if (fd1 and !fd2 and newfd != "1 FD -") {
		Modes.PFD.FMA.fdMode.setValue("1 FD -");
	} else if (fd2 and !fd1 and newfd != "- FD 2") {
		Modes.PFD.FMA.fdMode.setValue("- FD 2");
	} else if (!fd1 and !fd2) {
		Modes.PFD.FMA.fdMode.setValue(" ");
	}
}

# AT
var atMode = func {
	at = Output.athr.getValue();
	if (at and Modes.PFD.FMA.athrMode.getValue() != "A/THR") {
		Modes.PFD.FMA.athrMode.setValue("A/THR");
	} else if (!at) {
		Modes.PFD.FMA.athrMode.setValue(" ");
	}
}

var boxchk = func {
	if ((Output.ap1.getValue() or Output.ap2.getValue() or Output.fd1.getValue() or Output.fd2.getValue()) and !Custom.Output.fmaPower.getValue()) {
		Input.lat.setValue(3);
		boxchk_b();
	}
}

var boxchk_b = func {
	if (Modes.PFD.FMA.rollMode.getValue() != " ") {
		Modes.PFD.FMA.rollModeTime.setValue(pts.Sim.Time.elapsedSec.getValue());
	}
	if (Modes.PFD.FMA.pitchMode.getValue() != " ") {
		Modes.PFD.FMA.pitchModeTime.setValue(pts.Sim.Time.elapsedSec.getValue());
	}
	if (Modes.PFD.FMA.rollModeArmed.getValue() != " ") {
		Modes.PFD.FMA.rollModeArmedTime.setValue(pts.Sim.Time.elapsedSec.getValue());
	}
	if (Modes.PFD.FMA.pitchModeArmed.getValue() != " ") {
		Modes.PFD.FMA.pitchModeArmedTime.setValue(pts.Sim.Time.elapsedSec.getValue());
	}
	if (Modes.PFD.FMA.pitchMode2Armed.getValue() != " ") {
		Modes.PFD.FMA.pitchMode2ArmedTime.setValue(pts.Sim.Time.elapsedSec.getValue());
	}
}

# Update AP FD ATHR
setlistener("/it-autoflight/output/ap1", func {
	ap();
	boxchk();
});
setlistener("/it-autoflight/output/ap2", func {
	ap();
	boxchk();
});
setlistener("/it-autoflight/output/fd1", func {
	fd();
	boxchk();
});
setlistener("/it-autoflight/output/fd2", func {
	fd();
	boxchk();
});
setlistener("/it-autoflight/output/athr", func {
	atMode();
});

# Boxes
setlistener("/modes/pfd/fma/ap-mode", func {
	if (Modes.PFD.FMA.apMode.getValue() != " ") {
		Modes.PFD.FMA.apModeTime.setValue(pts.Sim.Time.elapsedSec.getValue());
	}
});

setlistener("/modes/pfd/fma/fd-mode", func {
	if (Modes.PFD.FMA.fdMode.getValue() != " ") {
		Modes.PFD.FMA.fdModeTime.setValue(pts.Sim.Time.elapsedSec.getValue());
	}
});

setlistener("/modes/pfd/fma/at-mode", func {
	if (Modes.PFD.FMA.athrMode.getValue() != " ") {
		Modes.PFD.FMA.throttleModeTime.setValue(pts.Sim.Time.elapsedSec.getValue());
		Modes.PFD.FMA.athrModeTime.setValue(pts.Sim.Time.elapsedSec.getValue());
	}
});

setlistener("/modes/pfd/fma/athr-armed", func {
	if (Modes.PFD.FMA.athrMode.getValue() != " ") {
		Modes.PFD.FMA.athrModeTime.setValue(pts.Sim.Time.elapsedSec.getValue());
	}
});

setlistener("/modes/pfd/fma/throttle-mode", func {
	state1 = pts.Systems.Thrust.state[0].getValue();
	state2 = pts.Systems.Thrust.state[1].getValue();
	athr = Output.athr.getValue();
	if (athr == 1 and state1 != "MCT" and state2 != "MCT" and state1 != "MAN THR" and state2 != "MAN THR" and state1 != "TOGA" and state2 != "TOGA" and state1 != "IDLE" and state2 != "IDLE" and 
	!pts.Systems.Thrust.engOut.getValue()) {
		Modes.PFD.FMA.throttleModeTime.setValue(pts.Sim.Time.elapsedSec.getValue());
	} else 	if (athr == 1 and state1 != "TOGA" and state2 != "TOGA" and state1 != "IDLE" and state2 != "IDLE" and pts.Systems.Thrust.engOut.getValue()) {
		if (pts.Controls.Engines.Engine.throttlePos[0].getValue() < 0.83 and pts.Controls.Engines.Engine.throttlePos[1].getValue() < 0.83) {
			Modes.PFD.FMA.throttleModeTime.setValue(pts.Sim.Time.elapsedSec.getValue());
		}
	}
});

setlistener("/modes/pfd/fma/roll-mode", func {
	if (Modes.PFD.FMA.rollMode.getValue() != " ") {
		Modes.PFD.FMA.rollModeTime.setValue(pts.Sim.Time.elapsedSec.getValue());
	}
});

setlistener("/modes/pfd/fma/pitch-mode", func {
	if (Modes.PFD.FMA.pitchMode.getValue() != " ") {
		Modes.PFD.FMA.pitchModeTime.setValue(pts.Sim.Time.elapsedSec.getValue());
	}
});

setlistener("/modes/pfd/fma/roll-mode-armed", func {
	if (Modes.PFD.FMA.rollModeArmed.getValue() != " ") {
		Modes.PFD.FMA.rollModeArmedTime.setValue(pts.Sim.Time.elapsedSec.getValue());
	}
});

setlistener("/modes/pfd/fma/pitch-mode-armed", func {
	if (Modes.PFD.FMA.pitchModeArmed.getValue() != " ") {
		Modes.PFD.FMA.pitchModeArmedTime.setValue(pts.Sim.Time.elapsedSec.getValue());
	}
});

setlistener("/modes/pfd/fma/pitch-mode2-armed", func {
	if (Modes.PFD.FMA.pitchMode2Armed != " ") {
		Modes.PFD.FMA.pitchMode2ArmedTime.setValue(pts.Sim.Time.elapsedSec.getValue());
	}
});

setlistener("sim/signals/fdm-initialized", func {
	init();
});
