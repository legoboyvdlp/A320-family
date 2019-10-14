# A3XX Buttons
# Joshua Davidson (Octal450)

# Copyright (c) 2019 Joshua Davidson (Octal450)

# Resets buttons to the default values
var variousReset = func {
	setprop("/modes/cpt-du-xfr", 0);
	setprop("/modes/fo-du-xfr", 0);
	setprop("/controls/fadec/n1mode1", 0);
	setprop("/controls/fadec/n1mode2", 0);
	setprop("/instrumentation/mk-viii/serviceable", 1);
	setprop("/instrumentation/mk-viii/inputs/discretes/terr-inhibit", 0);
	setprop("/instrumentation/mk-viii/inputs/discretes/gpws-inhibit", 0);
	setprop("/instrumentation/mk-viii/inputs/discretes/glideslope-cancel", 0);
	setprop("/instrumentation/mk-viii/inputs/discretes/momentary-flap-all-override", 0);
	setprop("/instrumentation/mk-viii/inputs/discretes/momentary-flap-3-override", 0);
	setprop("/controls/switches/cabinCall", 0);
	setprop("/controls/switches/mechCall", 0);
	setprop("/controls/switches/emer-lights", 0.5);
	# cockpit voice recorder stuff
	setprop("/controls/CVR/power", 0);
	setprop("/controls/CVR/test", 0);
	setprop("/controls/CVR/tone", 0);
	setprop("/controls/CVR/gndctl", 0);
	setprop("/controls/CVR/erase", 0);
	setprop("/controls/switches/cabinfan", 1);
	setprop("/controls/oxygen/crewOxyPB", 1); # 0 = OFF 1 = AUTO
	setprop("/controls/switches/emerCallLtO", 0); # ON light, flashes white for 10s
	setprop("/controls/switches/emerCallLtC", 0); # CALL light, flashes amber for 10s
	setprop("/controls/switches/emerCall", 0);
	setprop("/controls/switches/LrainRpt", 0);
	setprop("/controls/switches/RrainRpt", 0);
	setprop("/controls/switches/wiperLspd", 0); # -1 = INTM 0 = OFF 1 = LO 2 = HI
	setprop("/controls/switches/wiperRspd", 0); # -1 = INTM 0 = OFF 1 = LO 2 = HI
	setprop("/controls/lighting/strobe", 0);
	setprop("/controls/lighting/beacon", 0);
	setprop("/controls/switches/beacon", 0);
	setprop("/controls/switches/wing-lights", 0);
	setprop("/controls/switches/landing-lights-l", 0);
	setprop("/controls/switches/landing-lights-r", 0);
	setprop("/controls/lighting/wing-lights", 0);
	setprop("/controls/lighting/nav-lights-switch", 0);
	setprop("/controls/lighting/landing-lights[1]", 0);
	setprop("/controls/lighting/landing-lights[2]", 0);
	setprop("/controls/lighting/taxi-light-switch", 0);
	setprop("/controls/lighting/DU/du1", 1);
	setprop("/controls/lighting/DU/du2", 1);
	setprop("/controls/lighting/DU/du3", 1);
	setprop("/controls/lighting/DU/du4", 1);
	setprop("/controls/lighting/DU/du5", 1);
	setprop("/controls/lighting/DU/du6", 1);
	setprop("/controls/lighting/DU/mcdu1", 1);
	setprop("/controls/lighting/DU/mcdu2", 1);
	setprop("/modes/fcu/hdg-time", -45);
	setprop("/controls/switching/ATTHDG", 0);
	setprop("/controls/switching/AIRDATA", 0);
	setprop("/controls/switches/no-smoking-sign", 1);
	setprop("/controls/switches/seatbelt-sign", 1);
}

var BUTTONS = {
	init: func() {
		var stateL = getprop("/engines/engine[0]/state");
		var stateR = getprop("/engines/engine[1]/state");
		var Lrain = getprop("/controls/switches/LrainRpt");
		var Rrain = getprop("/controls/switches/RrainRpt");
		var OnLt = getprop("/controls/switches/emerCallLtO");
		var CallLt = getprop("/controls/switches/emerCallLtC");
		var EmerCall = getprop("/controls/switches/emerCall");
		var wow = getprop("/gear/gear[1]/wow");
		var wowr = getprop("/gear/gear[2]/wow");
		var gndCtl = getprop("/systems/CVR/gndctl");
		var acPwr = getprop("/systems/electrical/bus/ac-ess");
	},
	update: func() {
		rainRepel();
		CVR_master();
		if (getprop("/controls/switches/emerCall")) {
			EmerCallOnLight();
			EmerCallLight();
		}
	},
};

var rainRepel = func() {
	Lrain = getprop("/controls/switches/LrainRpt");
	Rrain = getprop("/controls/switches/RrainRpt");
	wow = getprop("/gear/gear[1]/wow");
	stateL = getprop("/engines/engine[0]/state");
	stateR = getprop("/engines/engine[1]/state");
	if (Lrain and (stateL != 3 and stateR != 3 and wow)) {	
		setprop("/controls/switches/LrainRpt", 0);
	}
	if (Rrain and (stateL != 3 and stateR != 3 and wow)) { 
		setprop("/controls/switches/RrainRpt", 0);
	}
}

var EmerCallOnLight = func() {
	OnLt = getprop("/controls/switches/emerCallLtO");
	EmerCall = getprop("/controls/switches/emerCall");
	if ((OnLt and EmerCall) or !EmerCall) { 
		setprop("/controls/switches/emerCallLtO", 0);
	} else if (!OnLt and EmerCall) { 
		setprop("/controls/switches/emerCallLtO", 1);
	}
}

var EmerCallLight = func() {
	CallLt = getprop("/controls/switches/emerCallLtC");
	EmerCall = getprop("/controls/switches/emerCall");
	if ((CallLt and EmerCall) or !EmerCall) { 
		setprop("/controls/switches/emerCallLtC", 0);
	} else if (!CallLt and EmerCall) { 
		setprop("/controls/switches/emerCallLtC", 1);
	}
}

var CVR_master = func() {
	stateL = getprop("/engines/engine[0]/state");
	stateR = getprop("/engines/engine[1]/state");
	wow = getprop("/gear/gear[1]/wow");
	wowr = getprop("/gear/gear[2]/wow");
	gndCtl = getprop("/systems/CVR/gndctl");
	acPwr = getprop("/systems/electrical/bus/ac-ess");
	if (acPwr > 0 and wow and wowr and (gndCtl or (stateL == 3 or stateR == 3))) {
		setprop("/controls/CVR/power", 1);
	} else if (!wow and !wowr and acPwr > 0) {
		setprop("/controls/CVR/power", 1);
	} else {
		setprop("/controls/CVR/power", 0);
	}
}

var EmerCall = func {
	setprop("/controls/switches/emerCall", 1);
	settimer(func() {
		setprop("/controls/switches/emerCall", 0);
	}, 10);
}

var CabinCall = func {
	setprop("/controls/switches/cabinCall", 0);
	settimer(func() {
		setprop("/controls/switches/cabinCall", 0);
	}, 15);
}
		
var MechCall = func {
	setprop("/controls/switches/mechCall", 1);
	settimer(func() {
		setprop("/controls/switches/mechCall", 0);
	}, 15);
}

var CVR_test = func {
	var parkBrake = getprop("/controls/gear/brake-parking");
	if (parkBrake) {
		setprop("controls/CVR/tone", 1);
		settimer(func() {
			setprop("controls/CVR/tone", 0);
		}, 15);
	}
}

var ktsMach = props.globals.getNode("/it-autoflight/input/kts-mach", 1);
var iasSet = props.globals.getNode("/it-autoflight/input/spd-kts", 1);
var machSet = props.globals.getNode("/it-autoflight/input/spd-mach", 1);
var hdgSet = props.globals.getNode("/it-autoflight/input/hdg", 1);
var altSet = props.globals.getNode("/it-autoflight/input/alt", 1);
var altSetMode = props.globals.getNode("/it-autoflight/config/altitude-dial-mode", 1);
var vsSet = props.globals.getNode("/it-autoflight/input/vs", 1);
var fpaSet = props.globals.getNode("/it-autoflight/input/fpa", 1);
var iasNow = props.globals.getNode("/instrumentation/airspeed-indicator/indicated-speed-kt", 1);
var machNow = props.globals.getNode("/instrumentation/airspeed-indicator/indicated-mach", 1);
var spdManaged = props.globals.getNode("/it-autoflight/input/spd-managed", 1);
var showHDG = props.globals.getNode("/it-autoflight/custom/show-hdg", 1);
var trkFpaSW = props.globals.getNode("/it-autoflight/custom/trk-fpa", 1);
var latMode = props.globals.getNode("/it-autoflight/output/lat", 1);
var vertMode = props.globals.getNode("/it-autoflight/output/vert", 1);
var locArm = props.globals.getNode("/it-autoflight/output/loc-armed", 1);
var apprArm = props.globals.getNode("/it-autoflight/output/appr-armed", 1);
var dcEss = props.globals.getNode("/systems/electrical/bus/dc-ess", 1);
var fd1 = props.globals.getNode("/it-autoflight/output/fd1", 1);
var fd2 = props.globals.getNode("/it-autoflight/output/fd2", 1);
var ap1 = props.globals.getNode("/it-autoflight/output/ap1", 1);
var ap2 = props.globals.getNode("/it-autoflight/output/ap2", 1);
var athr = props.globals.getNode("/it-autoflight/output/athr", 1);

var APPanel = {
	AP1: func() {
		if (dcEss.getValue() >= 25) {
			if (!ap1.getBoolValue()) {
				setprop("it-autoflight/input/ap1", 1);
			} else {
				libraries.apOff("hard", 1);
			}
		}
	},
	AP2: func() {
		if (dcEss.getValue() >= 25) {
			if (!ap2.getBoolValue()) {
				setprop("it-autoflight/input/ap2", 1);
			} else {
				libraries.apOff("hard", 2);
			}
		}
	},
	ATHR: func() {
		if (dcEss.getValue() >= 25) {
			if (!athr.getBoolValue()) {
				setprop("it-autoflight/input/athr", 1);
			} else {
				libraries.athrOff("hard");
			}
		}
	},
	FD1: func() {
		if (dcEss.getValue() >= 25) {
			if (!fd1.getBoolValue()) {
				setprop("it-autoflight/input/fd1", 1);
			} else {
				setprop("it-autoflight/input/fd1", 0);
			}
		}
	},
	FD2: func() {
		if (dcEss.getValue() >= 25) {
			if (!fd2.getBoolValue()) {
				setprop("it-autoflight/input/fd2", 1);
			} else {
				setprop("it-autoflight/input/fd2", 0);
			}
		}
	},
	APDisc: func() {
		if (dcEss.getValue() >= 25) {
			if (ap1.getBoolValue() or ap2.getBoolValue()) {
				libraries.apOff("soft", 0);
			} else {
				if (getprop("/it-autoflight/sound/apoffsound") == 1 or getprop("/it-autoflight/sound/apoffsound2") == 1) {
					setprop("/it-autoflight/sound/apoffsound", 0);
					setprop("/it-autoflight/sound/apoffsound2", 0);
				}
				setprop("/it-autoflight/output/ap-warning", 0);
				setprop("/ECAM/warnings/master-warning-light", 0);
			}
		}
	},
	ATDisc: func() {
		if (dcEss.getValue() >= 25) {
			if (athr.getBoolValue()) {
				libraries.athrOff("soft");
				setprop("/ECAM/warnings/master-caution-light", 1);
			} else {
				if (getprop("/it-autoflight/output/athr-warning") == 1) {
					setprop("/it-autoflight/output/athr-warning", 0);
					setprop("/ECAM/warnings/master-caution-light", 0);
				}
			}
		}
	},
	IASMach: func() {
		if (dcEss.getValue() >= 25) {
			if (ktsMach.getBoolValue()) {
				ktsMach.setBoolValue(0);
			} else {
				ktsMach.setBoolValue(1);
			}
		}
	},
	SPDPush: func() {
		if (dcEss.getValue() >= 25) {
			if (getprop("/FMGC/internal/cruise-lvl-set") == 1 and getprop("/FMGC/internal/cost-index-set") == 1) {
				spdManaged.setBoolValue(1);
				fmgc.ManagedSPD.start();
			}
		}
	},
	SPDPull: func() {
		if (dcEss.getValue() >= 25) {
			spdManaged.setBoolValue(0);
			fmgc.ManagedSPD.stop();
			var ias = iasNow.getValue();
			var mach = machNow.getValue();
			if (!ktsMach.getBoolValue()) {
				if (ias >= 100 and ias <= 350) {
					iasSet.setValue(math.round(ias));
				} else if (ias < 100) {
					iasSet.setValue(100);
				} else if (ias > 350) {
					iasSet.setValue(350);
				}
			} else if (ktsMach.getBoolValue()) {
				if (mach >= 0.50 and mach <= 0.82) {
					machSet.setValue(math.round(mach, 0.001));
				} else if (mach < 0.50) {
					machSet.setValue(0.50);
				} else if (mach > 0.82) {
					machSet.setValue(0.82);
				}
			}
		}
	},
	SPDAdjust: func(d) {
		if (dcEss.getValue() >= 25) {
			if (!spdManaged.getBoolValue()) {
				if (ktsMach.getBoolValue()) {
					var machTemp = machSet.getValue();
					if (d == 1) {
						machTemp = math.round(machTemp + 0.001, 0.001); # Kill floating point error
					} else if (d == -1) {
						machTemp = math.round(machTemp - 0.001, 0.001); # Kill floating point error
					} else if (d == 10) {
						machTemp = math.round(machTemp + 0.01, 0.01); # Kill floating point error
					} else if (d == -10) {
						machTemp = math.round(machTemp - 0.01, 0.01); # Kill floating point error
					}
					if (machTemp < 0.50) {
						machSet.setValue(0.50);
					} else if (machTemp > 0.82) {
						machSet.setValue(0.82);
					} else {
						machSet.setValue(machTemp);
					}
				} else {
					var iasTemp = iasSet.getValue();
					if (d == 1) {
						iasTemp = iasTemp + 1;
					} else if (d == -1) {
						iasTemp = iasTemp - 1;
					} else if (d == 10) {
						iasTemp = iasTemp + 10;
					} else if (d == -10) {
						iasTemp = iasTemp - 10;
					}
					if (iasTemp < 100) {
						iasSet.setValue(100);
					} else if (iasTemp > 350) {
						iasSet.setValue(350);
					} else {
						iasSet.setValue(iasTemp);
					}
				}
			}
		}
	},
	HDGPush: func() {
		if (dcEss.getValue() >= 25) {
			if (fd1.getBoolValue() or fd2.getBoolValue() or ap1.getBoolValue() or ap2.getBoolValue()) {
				setprop("/it-autoflight/input/lat", 1);
			}
		}
	},
	HDGPull: func() {
		if (dcEss.getValue() >= 25) {
			if (fd1.getBoolValue() or fd2.getBoolValue() or ap1.getBoolValue() or ap2.getBoolValue()) {
				if (latMode.getValue() == 0 or !showHDG.getBoolValue()) {
					setprop("/it-autoflight/input/lat", 3);
				} else {
					setprop("/it-autoflight/input/lat", 0);
				}
			}
		}
	},
	HDGAdjust: func(d) {
		if (dcEss.getValue() >= 25) {
			if (latMode.getValue() != 0) {
				hdgInput();
			}
			if (showHDG.getBoolValue()) {
				var hdgTemp = hdgSet.getValue();
				if (d == 1) {
					hdgTemp = hdgTemp + 1;
				} else if (d == -1) {
					hdgTemp = hdgTemp - 1;
				} else if (d == 10) {
					hdgTemp = hdgTemp + 10;
				} else if (d == -10) {
					hdgTemp = hdgTemp - 10;
				}
				if (hdgTemp < 0.5) {
					hdgSet.setValue(hdgTemp + 360);
				} else if (hdgTemp >= 360.5) {
					hdgSet.setValue(hdgTemp - 360);
				} else {
					hdgSet.setValue(hdgTemp);
				}
			}
		}
	},
	LOCButton: func() {
		if (dcEss.getValue() >= 25) {
			var vertTemp = vertMode.getValue();
			if ((locArm.getBoolValue() or latMode.getValue() == 2) and !apprArm.getBoolValue() and vertTemp != 2 and vertTemp != 6) {
				if (latMode.getValue() == 2) {
					setprop("/it-autoflight/input/lat", 0);
				} else {
					fmgc.ITAF.disarmLOC();
				}
				if (vertTemp == 2 or vertTemp == 6) {
					me.VSPull();
				} else {
					fmgc.ITAF.disarmGS();
				}
			} else {
				setprop("/it-autoflight/input/lat", 2);
				if (vertTemp == 2 or vertTemp == 6) {
					me.VSPull();
				} else {
					fmgc.ITAF.disarmGS();
				}
			}
		}
	},
	TRKFPA: func() {
		if (dcEss.getValue() >= 25) {
			fmgc.ITAF.toggleTrkFpa();
		}
	},
	ALTPush: func() {
		if (dcEss.getValue() >= 25) {
#			setprop("/it-autoflight/input/vert", 8); # He don't work yet m8
		}
	},
	ALTPull: func() {
		if (dcEss.getValue() >= 25) {
			setprop("/it-autoflight/input/vert", 4);
		}
	},
	ALTAdjust: func(d) {
		if (dcEss.getValue() >= 25) {
			var altTemp = altSet.getValue();
			if (d == 1) {
				if (altSetMode.getBoolValue()) {
					altTemp = altTemp + 1000;
				} else {
					altTemp = altTemp + 100;
				}
			} else if (d == -1) {
				if (altSetMode.getBoolValue()) {
					altTemp = altTemp - 1000;
				} else {
					altTemp = altTemp - 100;
				}
			} else if (d == 2) {
				altTemp = altTemp + 100;
			} else if (d == -2) {
				altTemp = altTemp - 100;
			} else if (d == 10) {
				altTemp = altTemp + 1000;
			} else if (d == -10) {
				altTemp = altTemp - 1000;
			}
			if (altTemp < 0) {
				altSet.setValue(0);
			} else if (altTemp > 50000) {
				altSet.setValue(50000);
			} else {
				altSet.setValue(altTemp);
			}
		}
	},
	VSPush: func() {
		if (dcEss.getValue() >= 25) {
			if (trkFpaSW.getBoolValue()) {
				setprop("/it-autoflight/input/vert", 5);
				setprop("/it-autoflight/input/fpa", 0);
			} else {
				setprop("/it-autoflight/input/vert", 1);
				setprop("/it-autoflight/input/vs", 0);
			}
		}
	},
	VSPull: func() {
		if (dcEss.getValue() >= 25) {
			if (trkFpaSW.getBoolValue()) {
				setprop("/it-autoflight/input/vert", 5);
			} else {
				setprop("/it-autoflight/input/vert", 1);
			}
		}
	},
	VSAdjust: func(d) {
		if (dcEss.getValue() >= 25) {
			if (vertMode.getValue() == 1) {
				var vsTemp = vsSet.getValue();
				if (d == 1) {
					vsTemp = vsTemp + 100;
				} else if (d == -1) {
					vsTemp = vsTemp - 100;
				} else if (d == 10) {
					vsTemp = vsTemp + 1000;
				} else if (d == -10) {
					vsTemp = vsTemp - 1000;
				}
				if (vsTemp < -6000) {
					vsSet.setValue(-6000);
				} else if (vsTemp > 6000) {
					vsSet.setValue(6000);
				} else {
					vsSet.setValue(vsTemp);
				}
			} else if (vertMode.getValue() == 5) {
				var fpaTemp = fpaSet.getValue();
				if (d == 1) {
					fpaTemp = math.round(fpaTemp + 0.1, 0.1);
				} else if (d == -1) {
					fpaTemp = math.round(fpaTemp - 0.1, 0.1);
				} else if (d == 10) {
					fpaTemp = fpaTemp + 1;
				} else if (d == -10) {
					fpaTemp = fpaTemp - 1;
				}
				if (fpaTemp < -9.9) {
					fpaSet.setValue(-9.9);
				} else if (fpaTemp > 9.9) {
					fpaSet.setValue(9.9);
				} else {
					fpaSet.setValue(fpaTemp);
				}
			}
			if ((vertMode.getValue() != 1 and !trkFpaSW.getBoolValue()) or (vertMode.getValue() != 5 and trkFpaSW.getBoolValue())) {
				me.VSPull();
			}
		}
	},
	APPRButton: func() {
		if (dcEss.getValue() >= 25) {
			var vertTemp = vertMode.getValue();
			if ((locArm.getBoolValue() or latMode.getValue() == 2) and (apprArm.getBoolValue() or vertTemp == 2 or vertTemp == 6)) {
				if (latMode.getValue() == 2) {
					setprop("/it-autoflight/input/lat", 0);
				} else {
					fmgc.ITAF.disarmLOC();
				}
				if (vertTemp == 2 or vertTemp == 6) {
					me.VSPull();
				} else {
					fmgc.ITAF.disarmGS();
				}
			} else {
				setprop("/it-autoflight/input/vert", 2);
			}
		}
	},
};

var hdgInput = func {
	if (latMode.getValue() != 0) {
		showHDG.setBoolValue(1);
		var hdgnow = getprop("/it-autoflight/input/hdg");
		setprop("/modes/fcu/hdg-time", getprop("/sim/time/elapsed-sec"));
	}
}

var toggleSTD = func {
	var Std = getprop("/modes/altimeter/std");
	if (Std == 1) {
		var oldqnh = getprop("/modes/altimeter/oldqnh");
		setprop("/instrumentation/altimeter/setting-inhg", oldqnh);
		setprop("/modes/altimeter/std", 0);
	} else if (Std == 0) {
		var qnh = getprop("/instrumentation/altimeter/setting-inhg");
		setprop("/modes/altimeter/oldqnh", qnh);
		setprop("/instrumentation/altimeter/setting-inhg", 29.92);
		setprop("/modes/altimeter/std", 1);
	}
}

var increaseManVS = func {
	var manvs = getprop("/systems/pressurization/outflowpos-man");
	var auto = getprop("/systems/pressurization/auto");
	if (manvs <= 1 and manvs >= 0 and !auto) {
		setprop("/systems/pressurization/outflowpos-man", manvs + 0.001);
	}
}

var decreaseManVS = func {
	var manvs = getprop("/systems/pressurization/outflowpos-man");
	var auto = getprop("/systems/pressurization/auto");
	if (manvs <= 1 and manvs >= 0 and !auto) {
		setprop("/systems/pressurization/outflowpos-man", manvs - 0.001);
	}
}

var apOff = func(type, side) {
	if (side == 0) {
		setprop("/it-autoflight/input/ap1", 0);
		setprop("/it-autoflight/input/ap2", 0);
	} elsif (side == 1) {
		setprop("/it-autoflight/input/ap1", 0);
	} elsif (side == 2) {
		setprop("/it-autoflight/input/ap2", 0);
	}
	apWarn(type);
}

var apWarn = func(type) {
	if (type == "none") {
		return;
	} elsif (type == "soft") {
		setprop("/ECAM/ap-off-time", getprop("/sim/time/elapsed-sec"));
		setprop("/it-autoflight/output/ap-warning", 1);
		setprop("/ECAM/warnings/master-warning-light", 1);
	} else {
		setprop("/it-autoflight/output/ap-warning", 2);
		# master warning handled by warning system in this case
		libraries.LowerECAM.clrLight();
	}
}

var athrOff = func(type) {
	if (type == "hard") {
		lockThr();
	}
	
	setprop("/it-autoflight/input/athr", 0);
	
	athrWarn(type);
}

var athrWarn = func(type) {
	if (type == "none") { 
		return; 
	} elsif (type == "soft") {
		setprop("/ECAM/athr-off-time", getprop("/sim/time/elapsed-sec"));
		setprop("/it-autoflight/output/athr-warning", 1);
	} else {
		libraries.LowerECAM.clrLight();
		setprop("/it-autoflight/output/athr-warning", 2);
	}
	setprop("/ECAM/warnings/master-caution-light", 1);
}

var lockThr = func() {
	state1 = getprop("/systems/thrust/state1");
	state2 = getprop("/systems/thrust/state2");
	if ((state1 == "CL" and state2 == "CL" and getprop("/systems/thrust/eng-out") == 0) or (state1 == "MCT" and state2 == "MCT" and getprop("/systems/thrust/eng-out") == 1)) {
		setprop("/systems/thrust/thr-lock-time", getprop("/sim/time/elapsed-sec"));
		setprop("/systems/thrust/thr-locked", 1);
		lockTimer.start();
	}
}

var checkLockThr = func() {
	if (getprop("/systems/thrust/thr-lock-time") + 5 > getprop("/sim/time/elapsed-sec")) { return; }
	
	if (fmgc.Output.athr.getBoolValue()) {
		lockTimer.stop();
		setprop("/systems/thrust/thr-locked", 0);
		setprop("/systems/thrust/thr-locked-alert", 0);
		setprop("/systems/thrust/thr-lock-time", 0);
		setprop("/systems/thrust/thr-locked-flash", 0);
		return;
	}
	
	if (getprop("/systems/thrust/thr-locked") == 0) {
		lockTimer.stop();
		setprop("/systems/thrust/thr-locked", 0);
		setprop("/systems/thrust/thr-locked-alert", 0);
		setprop("/systems/thrust/thr-lock-time", 0);
		setprop("/systems/thrust/thr-locked-flash", 0);
		return;
	}
	
	state1 = getprop("/systems/thrust/state1");
	state2 = getprop("/systems/thrust/state2");
	
	if ((state1 != "CL" and state2 != "CL" and getprop("/systems/thrust/eng-out") == 0) or (state1 != "MCT" and state2 != "MCT" and getprop("/systems/thrust/eng-out") == 1)) {
		lockTimer.stop();
		setprop("/systems/thrust/thr-locked", 0);
		setprop("/systems/thrust/thr-locked-alert", 0);
		setprop("/systems/thrust/thr-lock-time", 0);
		setprop("/systems/thrust/thr-locked-flash", 0);
	} elsif ((state1 == "CL" and state2 == "CL" and getprop("/systems/thrust/eng-out") == 0) or (state1 == "MCT" and state2 == "MCT" and getprop("/systems/thrust/eng-out") == 1)) {
		setprop("/systems/thrust/thr-locked-alert", 1);
		setprop("/systems/thrust/thr-lock-time", getprop("/sim/time/elapsed-sec"));
		setprop("/systems/thrust/thr-locked-flash", 1);
		lockTimer.stop();
		lockTimer2.start();
	}
}

var checkLockThr2 = func() {
	if (fmgc.Output.athr.getBoolValue()) {
		lockTimer2.stop();
		setprop("/systems/thrust/thr-locked", 0);
		setprop("/systems/thrust/thr-locked-alert", 0);
		setprop("/systems/thrust/thr-lock-time", 0);
		setprop("/systems/thrust/thr-locked-flash", 0);
		return;
	}
	
	if (getprop("/systems/thrust/thr-locked") == 0) {
		lockTimer2.stop();
		setprop("/systems/thrust/thr-locked", 0);
		setprop("/systems/thrust/thr-locked-alert", 0);
		setprop("/systems/thrust/thr-lock-time", 0);
		setprop("/systems/thrust/thr-locked-flash", 0);
		return;
	}
	
	if (getprop("/systems/thrust/thr-lock-time") + 5 < getprop("/sim/time/elapsed-sec")) { 
		setprop("/systems/thrust/thr-locked-flash", 0);
		settimer(func() {
			setprop("/systems/thrust/thr-locked-flash", 1);
			setprop("/systems/thrust/thr-lock-time", getprop("/sim/time/elapsed-sec"));
			ecam.athr_lock.noRepeat = 0;
			ecam.athr_lock.noRepeat2 = 0;
		}, 0.2);
	}
	
	state1 = getprop("/systems/thrust/state1");
	state2 = getprop("/systems/thrust/state2");
	
	
	if ((state1 != "CL" and state2 != "CL" and getprop("/systems/thrust/eng-out") == 0) or (state1 != "MCT" and state2 != "MCT" and getprop("/systems/thrust/eng-out") == 1)) {
		lockTimer2.stop();
		setprop("/systems/thrust/thr-locked", 0);
		setprop("/systems/thrust/thr-locked-alert", 0);
		setprop("/systems/thrust/thr-lock-time", 0);
		setprop("/systems/thrust/thr-locked-flash", 0);
	}
}

setlistener("/controls/APU/master", func() {
	if (!getprop("/controls/APU/master") and systems.apuEmerShutdown.getBoolValue()) {
		systems.apuEmerShutdown.setBoolValue(0);
	}
}, 0, 0);

var lockTimer = maketimer(0.1, checkLockThr);
var lockTimer2 = maketimer(0.1, checkLockThr2);