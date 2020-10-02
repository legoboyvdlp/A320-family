# A3XX FMGC Autopilot
# Based off IT-AUTOFLIGHT System Controller V4.0.X
# Copyright (c) 2020 Josh Davidson (Octal450)

# Initialize all used variables and property nodes
# Sim
var Controls = {
	aileron: props.globals.getNode("/controls/flight/aileron", 1),
	elevator: props.globals.getNode("/controls/flight/elevator", 1),
	rudder: props.globals.getNode("/controls/flight/rudder", 1),
};

var FPLN = {
	active: props.globals.getNode("/FMGC/flightplan[2]/active", 1),
	activeTemp: 0,
	currentCourse: 0,
	currentWp: props.globals.getNode("/FMGC/flightplan[2]/current-wp", 1),
	currentWpTemp: 0,
	deltaAngle: 0,
	deltaAngleRad: 0,
	distCoeff: 0,
	maxBank: 0,
	maxBankLimit: 0,
	nextCourse: 0,
	R: 0,
	radius: 0,
	turnDist: 0,
	wp0Dist: props.globals.getNode("/FMGC/flightplan[2]/current-leg-dist", 1),
	wpFlyFrom: 0,
	wpFlyTo: 0,
};

var Gear = {
	wow0: props.globals.getNode("/gear/gear[0]/wow", 1),
	wow1: props.globals.getNode("/gear/gear[1]/wow", 1),
	wow1Temp: 1,
	wow2: props.globals.getNode("/gear/gear[2]/wow", 1),
	wow2Temp: 1,
};

var Misc = {
	elapsedSec: props.globals.getNode("/sim/time/elapsed-sec", 1),
	fbwLaw: props.globals.getNode("/it-fbw/law", 1),
	flapNorm: props.globals.getNode("/surface-positions/flap-pos-norm", 1),
	pfdHeadingScale: props.globals.getNode("/instrumentation/pfd/heading-scale", 1),
};

var Position = {
	gearAglFtTemp: 0,
	gearAglFt: props.globals.getNode("/position/gear-agl-ft", 1),
	indicatedAltitudeFt: props.globals.getNode("/instrumentation/altimeter/indicated-altitude-ft", 1),
	indicatedAltitudeFtTemp: 0,
};

var Radio = {
	gsDefl: [props.globals.getNode("/instrumentation/nav[0]/gs-needle-deflection-norm", 1), props.globals.getNode("instrumentation/nav[1]/gs-needle-deflection-norm", 1)],
	gsDeflTemp: 0,
	inRange: [props.globals.getNode("/instrumentation/nav[0]/in-range", 1), props.globals.getNode("instrumentation/nav[1]/in-range", 1)],
	inRangeTemp: 0,
	locDefl: [props.globals.getNode("/instrumentation/nav[0]/heading-needle-deflection-norm", 1), props.globals.getNode("instrumentation/nav[1]/heading-needle-deflection-norm", 1)],
	locDeflTemp: 0,
	radioSel: 0,
	signalQuality: [props.globals.getNode("/instrumentation/nav[0]/signal-quality-norm", 1), props.globals.getNode("instrumentation/nav[1]/signal-quality-norm", 1)],
	signalQualityTemp: 0,
};

var Velocities = {
	airspeedKt: props.globals.getNode("/velocities/airspeed-kt", 1), # Only used for gain scheduling
	groundspeedKt: props.globals.getNode("/velocities/groundspeed-kt", 1),
	groundspeedMps: 0,
	indicatedAirspeedKt: props.globals.getNode("/instrumentation/airspeed-indicator/indicated-speed-kt", 1),
	indicatedMach: props.globals.getNode("/instrumentation/airspeed-indicator/indicated-mach", 1),
	trueAirspeedKt: props.globals.getNode("/instrumentation/airspeed-indicator/true-speed-kt", 1),
	trueAirspeedKtTemp: 0,
};

# IT-AUTOFLIGHT
var Input = {
	alt: props.globals.initNode("/it-autoflight/input/alt", 10000, "INT"),
	ap1: props.globals.initNode("/it-autoflight/input/ap1", 0, "BOOL"),
	ap2: props.globals.initNode("/it-autoflight/input/ap2", 0, "BOOL"),
	athr: props.globals.initNode("/it-autoflight/input/athr", 0, "BOOL"),
	altDiff: 0,
	bankLimitSW: props.globals.initNode("/it-autoflight/input/bank-limit-sw", 0, "INT"),
	bankLimitSWTemp: 0,
	fd1: props.globals.initNode("/it-autoflight/input/fd1", 1, "BOOL"),
	fd2: props.globals.initNode("/it-autoflight/input/fd2", 1, "BOOL"),
	fpa: props.globals.initNode("/it-autoflight/input/fpa", 0, "DOUBLE"),
	fpaAbs: props.globals.initNode("/it-autoflight/input/fpa-abs", 0, "DOUBLE"), # Set by property rule
	hdg: props.globals.initNode("/it-autoflight/input/hdg", 0, "INT"),
	hdgCalc: 0,
	kts: props.globals.initNode("/it-autoflight/input/kts", 100, "INT"),
	ktsMach: props.globals.initNode("/it-autoflight/input/kts-mach", 0, "BOOL"),
	lat: props.globals.initNode("/it-autoflight/input/lat", 5, "INT"),
	latTemp: 5,
	mach: props.globals.initNode("/it-autoflight/input/mach", 0.5, "DOUBLE"),
	toga: props.globals.initNode("/it-autoflight/input/toga", 0, "BOOL"),
	trk: props.globals.initNode("/it-autoflight/input/trk", 0, "BOOL"),
	trueCourse: props.globals.initNode("/it-autoflight/input/true-course", 0, "BOOL"),
	vs: props.globals.initNode("/it-autoflight/input/vs", 0, "INT"),
	vsAbs: props.globals.initNode("/it-autoflight/input/vs-abs", 0, "INT"), # Set by property rule
	vert: props.globals.initNode("/it-autoflight/input/vert", 7, "INT"),
	vertTemp: 7,
};

var Internal = {
	alt: props.globals.initNode("/it-autoflight/internal/alt", 10000, "INT"),
	altCaptureActive: 0,
	altDiff: 0,
	altTemp: 0,
	altPredicted: props.globals.initNode("/it-autoflight/internal/altitude-predicted", 0, "DOUBLE"),
	bankLimit: props.globals.initNode("/it-autoflight/internal/bank-limit", 30, "INT"),
	bankLimitAuto: 30,
	captVs: 0,
	driftAngle: props.globals.initNode("/it-autoflight/internal/drift-angle-deg", 0, "DOUBLE"),
	flchActive: 0,
	fpa: props.globals.initNode("/it-autoflight/internal/fpa", 0, "DOUBLE"),
	hdgErrorDeg: props.globals.initNode("/it-autoflight/internal/heading-error-deg", 0, "DOUBLE"),
	hdgPredicted: props.globals.initNode("/it-autoflight/internal/heading-predicted", 0, "DOUBLE"),
	lnavAdvanceNm: props.globals.initNode("/it-autoflight/internal/lnav-advance-nm", 0, "DOUBLE"),
	minVs: props.globals.initNode("/it-autoflight/internal/min-vs", -500, "INT"),
	maxVs: props.globals.initNode("/it-autoflight/internal/max-vs", 500, "INT"),
	vs: props.globals.initNode("/it-autoflight/internal/vert-speed-fpm", 0, "DOUBLE"),
	vsTemp: 0,
};

var Output = {
	ap1: props.globals.initNode("/it-autoflight/output/ap1", 0, "BOOL"),
	ap1Temp: 0,
	ap2: props.globals.initNode("/it-autoflight/output/ap2", 0, "BOOL"),
	ap2Temp: 0,
	apprArm: props.globals.initNode("/it-autoflight/output/appr-armed", 0, "BOOL"),
	athr: props.globals.initNode("/it-autoflight/output/athr", 0, "BOOL"),
	athrTemp: 0,
	fd1: props.globals.initNode("/it-autoflight/output/fd1", 1, "BOOL"),
	fd1Temp: 0,
	fd2: props.globals.initNode("/it-autoflight/output/fd2", 1, "BOOL"),
	fd2Temp: 0,
	lat: props.globals.initNode("/it-autoflight/output/lat", 5, "INT"),
	latTemp: 5,
	lnavArm: props.globals.initNode("/it-autoflight/output/lnav-armed", 0, "BOOL"),
	locArm: props.globals.initNode("/it-autoflight/output/loc-armed", 0, "BOOL"),
	thrMode: props.globals.initNode("/it-autoflight/output/thr-mode", 2, "INT"),
	vert: props.globals.initNode("/it-autoflight/output/vert", 7, "INT"),
	vertTemp: 7,
};

var Text = {
	arm: props.globals.initNode("/it-autoflight/mode/arm", " ", "STRING"),
	lat: props.globals.initNode("/it-autoflight/mode/lat", "T/O", "STRING"),
	thr: props.globals.initNode("/it-autoflight/mode/thr", "PITCH", "STRING"),
	vert: props.globals.initNode("/it-autoflight/mode/vert", "T/O CLB", "STRING"),
	vertTemp: "T/O CLB",
};

var Setting = {
	reducAglFt: props.globals.initNode("/it-autoflight/settings/accel-agl-ft", 1500, "INT"), # Changable from MCDU, eventually set to 1500 above runway
};

var Sound = {
	apOff: props.globals.initNode("/it-autoflight/sound/apoffsound", 0, "BOOL"),
	enableApOff: 0,
};

# A3XX Custom
var Custom = {
	apFdOn: 0,
	hdgTime: props.globals.getNode("/modes/fcu/hdg-time", 1),
	ndTrkSel: [props.globals.getNode("/instrumentation/efis[0]/trk-selected", 1), props.globals.getNode("/instrumentation/efis[1]/trk-selected", 1)],
	showHdg: props.globals.initNode("/it-autoflight/custom/show-hdg", 1, "BOOL"),
	trkFpa: props.globals.initNode("/it-autoflight/custom/trk-fpa", 0, "BOOL"),
	Input: {
		spdManaged: props.globals.getNode("/it-autoflight/input/spd-managed", 1),
	},
	Output: {
		fmaPower: props.globals.initNode("/it-autoflight/output/fma-pwr", 0, "BOOL"),
	},
	Sound: {
		athrOff: props.globals.initNode("/it-autoflight/sound/athrsound", 0, "BOOL"),
		enableAthrOff: 0,
	},
	ThrLock: props.globals.getNode("/systems/thrust/thr-locked", 1)
};

var ITAF = {
	init: func() {
		Custom.ndTrkSel[0].setBoolValue(0);
		Custom.ndTrkSel[1].setBoolValue(0);
		Custom.trkFpa.setBoolValue(0);
		Input.ktsMach.setBoolValue(0);
		Input.ap1.setBoolValue(0);
		Input.ap2.setBoolValue(0);
		Input.athr.setBoolValue(0);
		Input.fd1.setBoolValue(1);
		Input.fd2.setBoolValue(1);
		Input.hdg.setValue(360);
		Input.alt.setValue(10000);
		Input.vs.setValue(0);
		Input.fpa.setValue(0);
		Input.lat.setValue(9);
		Input.vert.setValue(9);
		Input.trk.setBoolValue(0);
		Input.trueCourse.setBoolValue(0);
		Input.toga.setBoolValue(0);
		Custom.Input.spdManaged.setBoolValue(0);
		Output.ap1.setBoolValue(0);
		Output.ap2.setBoolValue(0);
		Output.athr.setBoolValue(0);
		Output.fd1.setBoolValue(1);
		Output.fd2.setBoolValue(1);
		Output.lnavArm.setBoolValue(0);
		Output.locArm.setBoolValue(0);
		Output.apprArm.setBoolValue(0);
		Output.thrMode.setValue(0);
		Output.lat.setValue(9);
		Output.vert.setValue(9);
		Internal.minVs.setValue(-500);
		Internal.maxVs.setValue(500);
		Internal.bankLimit.setValue(30);
		Internal.bankLimitAuto = 30;
		Internal.alt.setValue(10000);
		Internal.altCaptureActive = 0;
		Input.kts.setValue(100);
		Input.mach.setValue(0.5);
		Text.thr.setValue("THRUST");
		Text.arm.setValue(" ");
		Text.lat.setValue(" ");
		Text.vert.setValue(" ");
		Custom.showHdg.setBoolValue(1);
		Custom.Output.fmaPower.setBoolValue(1);
		ManagedSPD.stop();
		loopTimer.start();
		slowLoopTimer.start();
	},
	loop: func() {
		Output.latTemp = Output.lat.getValue();
		Output.vertTemp = Output.vert.getValue();
		
		# VOR/ILS Revision
		if (Output.latTemp == 2 or Output.vertTemp == 2 or Output.vertTemp == 6) {
			me.checkRadioRevision(Output.latTemp, Output.vertTemp);
		}
		
		Gear.wow1Temp = Gear.wow1.getBoolValue();
		Gear.wow2Temp = Gear.wow2.getBoolValue();
		Output.ap1Temp = Output.ap1.getBoolValue();
		Output.ap2Temp = Output.ap2.getBoolValue();
		Output.latTemp = Output.lat.getValue();
		Output.vertTemp = Output.vert.getValue();
		Text.vertTemp = Text.vert.getValue();
		Position.gearAglFtTemp = Position.gearAglFt.getValue();
		Internal.vsTemp = Internal.vs.getValue();
		Position.indicatedAltitudeFtTemp = Position.indicatedAltitudeFt.getValue();
		
		# LNAV Engagement
		if (Output.lnavArm.getBoolValue()) {
			me.checkLNAV(1);
		}
		
		# VOR/LOC or ILS/LOC Capture
		if (Output.locArm.getBoolValue()) {
			me.checkLOC(1, 0);
		}
		
		# G/S Capture
		if (Output.apprArm.getBoolValue()) {
			me.checkAPPR(1);
		}
		
		# Autoland Logic
		if (Output.latTemp == 2) {
			if (Position.gearAglFtTemp <= 50) { # ALIGN
				me.setLatMode(4);
			}
		}
		if (Output.vertTemp == 2) {
			if (Position.gearAglFtTemp <= 400 and Position.gearAglFtTemp >= 5) {
				Text.vert.setValue("LAND");

				if (Position.gearAglFtTemp <= 100) { # switch to internal flare logic at 100 feet -- but on FMA at 50!
					me.setVertMode(6);
				}
			}
		} else if (Output.vertTemp == 6) {
			if (Position.gearAglFtTemp <= 50 and Position.gearAglFtTemp >= 5) {
				Text.vert.setValue("FLARE");
			}
			if (Gear.wow1Temp and Gear.wow2Temp) {
				Text.lat.setValue("RLOU");
				Text.vert.setValue("ROLLOUT");
			}
		}
		
		# FLCH Engagement
		if (Text.vertTemp == "T/O CLB") {
			me.checkFLCH(Setting.reducAglFt.getValue());
		}
		
		# Altitude Capture/Sync Logic
		if (Output.vertTemp != 0) {
			Internal.alt.setValue(Input.alt.getValue());
		}
		Internal.altTemp = Internal.alt.getValue();
		Internal.altDiff = Internal.altTemp - Position.indicatedAltitudeFtTemp;
		
		if (Output.vertTemp != 0 and Output.vertTemp != 2 and Output.vertTemp != 6 and Output.vertTemp != 9) {
			Internal.captVs = math.clamp(math.round(abs(Internal.vs.getValue()) / 5, 100), 50, 2500); # Capture limits
			Custom.apFdOn = Output.ap1Temp or Output.ap2Temp or Output.fd1.getBoolValue() or Output.fd2.getBoolValue();
			if (abs(Internal.altDiff) <= Internal.captVs and !Gear.wow1Temp and !Gear.wow2Temp and Custom.apFdOn) {
				if (Internal.altTemp >= Position.indicatedAltitudeFtTemp and Internal.vsTemp >= -25) { # Don't capture if we are going the wrong way
					me.setVertMode(3);
				} else if (Internal.altTemp < Position.indicatedAltitudeFtTemp and Internal.vsTemp <= 25) { # Don't capture if we are going the wrong way
					me.setVertMode(3);
				}
			}
		}
		
		# Altitude Hold Min/Max Reset
		if (Internal.altCaptureActive) {
			if (abs(Internal.altDiff) <= 20) {
				me.resetClimbRateLim();
				Text.vert.setValue("ALT HLD");
			}
		}
		
		# Thrust Mode Selector
		if (Output.athr.getBoolValue() and Output.vertTemp != 7 and (Output.ap1Temp or Output.ap2Temp) and Position.gearAglFt.getValue() <= 30 and (Output.vertTemp == 2 or Output.vertTemp == 6)) {
			# Manual says 40 feet -- but video reference shows 30!
			Output.thrMode.setValue(1);
			Text.thr.setValue("RETARD");
		} else if (Output.vertTemp == 4) {
			if (Internal.altTemp >= Position.indicatedAltitudeFtTemp) {
				Output.thrMode.setValue(2);
				Text.thr.setValue("PITCH");
				if (Internal.flchActive) { # Set before mode change to prevent it from overwriting by mistake
					Text.vert.setValue("SPD CLB");
				}
			} else {
				Output.thrMode.setValue(1);
				Text.thr.setValue("PITCH");
				if (Internal.flchActive) { # Set before mode change to prevent it from overwriting by mistake
					Text.vert.setValue("SPD DES");
				}
			}
		} else if (Output.vertTemp == 7) {
			Output.thrMode.setValue(2);
			Text.thr.setValue("PITCH");
		} else {
			Output.thrMode.setValue(0);
			Text.thr.setValue("THRUST");
		}
		
		# Custom Stuff Below
		# Heading Sync
		if (!Custom.showHdg.getBoolValue()) {
			Input.hdg.setValue(Misc.pfdHeadingScale.getValue());
		}
		
		# Preselect Heading
		if (Output.latTemp != 0 and Output.latTemp != 9) { # Modes that always show HDG
			if (Custom.hdgTime.getValue() + 45 >= Misc.elapsedSec.getValue()) {
				setprop("it-autoflight/custom/show-hdg", 1);
			} else {
				setprop("it-autoflight/custom/show-hdg", 0);
			}
		}
		
		# Misc
		if (Output.ap1Temp == 1 or Output.ap2Temp == 1) { # Trip AP off
			if (abs(Controls.aileron.getValue()) >= 0.2 or abs(Controls.elevator.getValue()) >= 0.2 or abs(Controls.rudder.getValue()) >= 0.2) {
				fcu.apOff("hard", 0);
			}
		}
	},
	slowLoop: func() {
		Velocities.trueAirspeedKtTemp = Velocities.trueAirspeedKt.getValue();
		FPLN.activeTemp = FPLN.active.getValue();
		FPLN.currentWpTemp = FPLN.currentWp.getValue();
		
		# Bank Limit
		if (Velocities.trueAirspeedKtTemp >= 420) {
			Internal.bankLimitAuto = 15;
		} else if (Velocities.trueAirspeedKtTemp >= 340) {
			Internal.bankLimitAuto = 20;
		} else {
			Internal.bankLimitAuto = 30;
		}
		
		Internal.bankLimit.setValue(Internal.bankLimitAuto);
		
		# If in LNAV mode and route is not longer active, switch to HDG HLD
		if (Output.lat.getValue() == 1) { # Only evaulate the rest of the condition if we are in LNAV mode
			if (flightPlanController.num[2].getValue() == 0 or !FPLN.active.getBoolValue()) {
				me.setLatMode(3);
			}
		}
		
		# Waypoint Advance Logic
		if (flightPlanController.num[2].getValue() > 0 and FPLN.activeTemp == 1) {
			if ((FPLN.currentWpTemp + 1) < flightPlanController.num[2].getValue()) {
				Velocities.groundspeedMps = Velocities.groundspeedKt.getValue() * 0.5144444444444;
				FPLN.wpFlyFrom = FPLN.currentWpTemp;
				if (FPLN.wpFlyFrom < 0) {
					FPLN.wpFlyFrom = 0;
				}
				FPLN.currentCourse = fmgc.wpCourse[2][FPLN.wpFlyFrom].getValue();
				FPLN.wpFlyTo = FPLN.currentWpTemp + 1;
				FPLN.nextCourse = fmgc.wpCourse[2][FPLN.wpFlyTo].getValue();
				FPLN.maxBankLimit = Internal.bankLimit.getValue();

				FPLN.deltaAngle = math.abs(geo.normdeg180(FPLN.currentCourse - FPLN.nextCourse));
				FPLN.maxBank = FPLN.deltaAngle * 1.5;
				if (FPLN.maxBank > FPLN.maxBankLimit) {
					FPLN.maxBank = FPLN.maxBankLimit;
				}
				FPLN.radius = (Velocities.groundspeedMps * Velocities.groundspeedMps) / (9.81 * math.tan(FPLN.maxBank / 57.2957795131));
				FPLN.deltaAngleRad = (180 - FPLN.deltaAngle) / 114.5915590262;
				FPLN.R = FPLN.radius / math.sin(FPLN.deltaAngleRad);
				FPLN.distCoeff = FPLN.deltaAngle * -0.011111 + 2;
				if (FPLN.distCoeff < 1) {
					FPLN.distCoeff = 1;
				}
				FPLN.turnDist = math.cos(FPLN.deltaAngleRad) * FPLN.R * FPLN.distCoeff / 1852;
				if (Gear.wow0.getBoolValue() and FPLN.turnDist < 1) {
					FPLN.turnDist = 1;
				}
				Internal.lnavAdvanceNm.setValue(FPLN.turnDist);
				
				# Advance logic done by flightplan controller
				if (FPLN.wp0Dist.getValue() <= FPLN.turnDist and !Gear.wow1.getBoolValue()) {
					flightPlanController.autoSequencing();
				}
				
				#if (FPLN.wp0Dist.getValue() <= FPLN.turnDist and !Gear.wow1.getBoolValue() and fmgc.flightPlanController.flightplans[2].getWP(FPLN.currentWpTemp).fly_type == "flyBy") {
				#	flightPlanController.autoSequencing();
				#} elsif (FPLN.wp0Dist.getValue() <= 0.1) {
				#	flightPlanController.autoSequencing();
				#}
			}
		}
	},
	ap1Master: func(s) {
		if (s == 1) {
			if (Output.vert.getValue() != 6 and !Gear.wow1.getBoolValue() and !Gear.wow2.getBoolValue() and systems.ELEC.Bus.acEss.getValue() >= 110 and Misc.fbwLaw.getValue() == 0 and Position.gearAglFt.getValue() >= 100) {
				me.revertBasicMode();
				Output.ap1.setBoolValue(1);
				Output.latTemp = Output.lat.getValue();
				if (Output.ap2.getBoolValue() and !Output.apprArm.getBoolValue() and Output.latTemp != 2 and Output.latTemp != 4) {
					me.ap2Master(0);
				}
				Sound.enableApOff = 1;
				Sound.apOff.setBoolValue(0);
			}
		} else {
			Output.ap1.setBoolValue(0);
			me.apOffFunction();
		}
		Output.ap1Temp = Output.ap1.getBoolValue();
		if (Input.ap1.getBoolValue() != Output.ap1Temp) {
			Input.ap1.setBoolValue(Output.ap1Temp);
		}
	},
	ap2Master: func(s) {
		if (s == 1) {
			if (Output.vert.getValue() != 6 and !Gear.wow1.getBoolValue() and !Gear.wow2.getBoolValue() and systems.ELEC.Bus.acEss.getValue() >= 110 and Misc.fbwLaw.getValue() == 0 and Position.gearAglFt.getValue() >= 100) {
				me.revertBasicMode();
				Output.ap2.setBoolValue(1);
				Output.latTemp = Output.lat.getValue();
				if (Output.ap1.getBoolValue() and !Output.apprArm.getBoolValue() and Output.latTemp != 2 and Output.latTemp != 4) {
					me.ap1Master(0);
				}
				Sound.enableApOff = 1;
				Sound.apOff.setBoolValue(0);
			}
		} else {
			Output.ap2.setBoolValue(0);
			me.apOffFunction();
		}
		Output.ap2Temp = Output.ap2.getBoolValue();
		if (Input.ap2.getBoolValue() != Output.ap2Temp) {
			Input.ap2.setBoolValue(Output.ap2Temp);
		}
	},
	apOffFunction: func() {
		if (!Output.ap1.getBoolValue() and !Output.ap2.getBoolValue()) { # Only do if both APs are off
			me.updateFma();
			if (Sound.enableApOff) {
				Sound.apOff.setBoolValue(1);
				Sound.enableApOff = 0;
			}
		}
	},
	athrMaster: func(s) {
		if (s == 1) {
			if (systems.ELEC.Bus.acEss.getValue() >= 110) {
				Output.athr.setBoolValue(1);
				Custom.ThrLock.setValue(0);
				Custom.Sound.enableAthrOff = 1;
				Custom.Sound.athrOff.setBoolValue(0);
			}
		} else {
			Output.athr.setBoolValue(0);
			if (Custom.Sound.enableAthrOff) {
				Custom.Sound.athrOff.setBoolValue(1);
				Custom.Sound.enableAthrOff = 0;
			}
		}
		Output.athrTemp = Output.athr.getBoolValue();
		if (Input.athr.getBoolValue() != Output.athrTemp) {
			Input.athr.setBoolValue(Output.athrTemp);
		}
	},
	fd1Master: func(s) {
		if (s == 1) {
			Output.fd1.setBoolValue(1);
			me.updateFma();
		} else {
			Output.fd1.setBoolValue(0);
			if (!Output.fd2.getBoolValue()) {
				me.updateFma();
			}
		}
		Output.fd1Temp = Output.fd1.getBoolValue();
		if (Input.fd1.getBoolValue() != Output.fd1Temp) {
			Input.fd1.setBoolValue(Output.fd1Temp);
		}
	},
	fd2Master: func(s) {
		if (s == 1) {
			Output.fd2.setBoolValue(1);
			me.updateFma();
		} else {
			Output.fd2.setBoolValue(0);
			if (!Output.fd1.getBoolValue()) {
				me.updateFma();
			}
		}
		Output.fd2Temp = Output.fd2.getBoolValue();
		if (Input.fd2.getBoolValue() != Output.fd2Temp) {
			Input.fd2.setBoolValue(Output.fd2Temp);
		}
	},
	setLatMode: func(n) {
		Output.vertTemp = Output.vert.getValue();
		if (n == 0) { # HDG SEL
			Output.lnavArm.setBoolValue(0);
			Output.locArm.setBoolValue(0);
			Output.apprArm.setBoolValue(0);
			Output.lat.setValue(0);
			Custom.showHdg.setBoolValue(1);
			Text.lat.setValue("HDG");
			if (Output.vertTemp == 2 or Output.vertTemp == 6) { # Also cancel G/S or FLARE if active
				me.setVertMode(1);
			} else {
				me.armTextCheck();
			}
		} else if (n == 1) { # LNAV
			me.checkLNAV(0);
		} else if (n == 2) { # VOR/LOC
			Output.lnavArm.setBoolValue(0);
			me.armTextCheck();
			me.checkLOC(0, 0);
		} else if (n == 3) { # HDG HLD
			Output.lnavArm.setBoolValue(0);
			Output.locArm.setBoolValue(0);
			Output.apprArm.setBoolValue(0);
			me.syncHdg();
			Output.lat.setValue(0);
			Custom.showHdg.setBoolValue(1);
			Text.lat.setValue("HDG");
			if (Output.vertTemp == 2 or Output.vertTemp == 6) { # Also cancel G/S or FLARE if active
				me.setVertMode(1);
			} else {
				me.armTextCheck();
			}
		} else if (n == 4) { # ALIGN
			Output.lnavArm.setBoolValue(0);
			Output.locArm.setBoolValue(0);
			Output.apprArm.setBoolValue(0);
			Output.lat.setValue(4);
			Custom.showHdg.setBoolValue(0);
			Text.lat.setValue("ALGN");
			me.armTextCheck();
		} else if (n == 5) { # RWY
			Output.lnavArm.setBoolValue(0);
			Output.locArm.setBoolValue(0);
			Output.apprArm.setBoolValue(0);
			Output.lat.setValue(5);
			Custom.showHdg.setBoolValue(0);
			Text.lat.setValue("T/O");
			me.armTextCheck();
		} else if (n == 9) { # NONE
			Output.locArm.setBoolValue(0);
			Output.lat.setValue(9);
			Custom.showHdg.setBoolValue(1);
			Text.lat.setValue(" ");
			me.armTextCheck();
		}
	},
	setLatArm: func(n) {
		if (n == 0) {
			Output.lnavArm.setBoolValue(0);
			Custom.showHdg.setBoolValue(1);
			me.armTextCheck();
		} else if (n == 1) {
			if (flightPlanController.num[2].getValue() > 0 and FPLN.active.getBoolValue()) {
				Output.lnavArm.setBoolValue(1);
				Custom.showHdg.setBoolValue(0);
				me.armTextCheck();
			}
		} else if (n == 3) {
			me.syncHdg();
			Output.lnavArm.setBoolValue(0);
			Custom.showHdg.setBoolValue(1);
			me.armTextCheck();
		} 
	},
	setVertMode: func(n) {
		Input.altDiff = Input.alt.getValue() - Position.indicatedAltitudeFt.getValue();
		if (n == 0) { # ALT HLD
			Internal.flchActive = 0;
			Internal.altCaptureActive = 0;
			Output.apprArm.setBoolValue(0);
			Output.vert.setValue(0);
			me.resetClimbRateLim();
			Text.vert.setValue("ALT HLD");
			me.syncAlt();
			me.armTextCheck();
		} else if (n == 1) { # V/S
			if (abs(Input.altDiff) >= 25) {
				Internal.flchActive = 0;
				Internal.altCaptureActive = 0;
				Output.apprArm.setBoolValue(0);
				Output.vert.setValue(1);
				Text.vert.setValue("V/S");
				me.syncVs();
				me.armTextCheck();
			} else {
				Output.apprArm.setBoolValue(0);
				me.armTextCheck();
			}
		} else if (n == 2) { # G/S
			me.checkLOC(0, 1);
			me.checkAPPR(0);
		} else if (n == 3) { # ALT CAP
			Internal.flchActive = 0;
			Output.vert.setValue(0);
			me.setClimbRateLim();
			Internal.altCaptureActive = 1;
			Text.vert.setValue("ALT CAP");
		} else if (n == 4) { # FLCH
			Output.apprArm.setBoolValue(0);
			Output.vert.setValue(1);
			Internal.alt.setValue(Input.alt.getValue());
			Internal.altDiff = Internal.alt.getValue() - Position.indicatedAltitudeFt.getValue();
			if (abs(Internal.altDiff) >= 250) { # SPD CLB or SPD DES
				if (Input.alt.getValue() >= Position.indicatedAltitudeFt.getValue()) { # Usually set Thrust Mode Selector, but we do it now due to timer lag
					Text.vert.setValue("SPD CLB");
				} else {
					Text.vert.setValue("SPD DES");
				}
				Internal.altCaptureActive = 0;
				Output.vert.setValue(4);
				Internal.flchActive = 1;
			} else { # ALT CAP
				Internal.flchActive = 0;
				Internal.alt.setValue(Input.alt.getValue());
				Internal.altCaptureActive = 1;
				Output.vert.setValue(0);
				Text.vert.setValue("ALT CAP");
			}
			me.armTextCheck();
		} else if (n == 5) { # FPA
			if (abs(Input.altDiff) >= 25) {
				Internal.flchActive = 0;
				Internal.altCaptureActive = 0;
				Output.apprArm.setBoolValue(0);
				Output.vert.setValue(5);
				Text.vert.setValue("FPA");
				me.syncFpa();
				me.armTextCheck();
			} else {
				Output.apprArm.setBoolValue(0);
				me.armTextCheck();
			}
		} else if (n == 6) { # FLARE/ROLLOUT
			Internal.flchActive = 0;
			Internal.altCaptureActive = 0;
			Output.apprArm.setBoolValue(0);
			Output.vert.setValue(6);
			me.armTextCheck();
		} else if (n == 7) { # T/O CLB or G/A CLB, text is set by TOGA selector
			Internal.flchActive = 0;
			Internal.altCaptureActive = 0;
			Output.apprArm.setBoolValue(0);
			Output.vert.setValue(7);
			me.armTextCheck();
		} else if (n == 9) { # NONE
			Internal.flchActive = 0;
			Internal.altCaptureActive = 0;
			Output.apprArm.setBoolValue(0);
			Output.vert.setValue(9);
			Text.vert.setValue(" ");
			me.armTextCheck();
		}
	},
	activateLNAV: func() {
		if (Output.lat.getValue() != 1) {
			Output.lnavArm.setBoolValue(0);
			Output.locArm.setBoolValue(0);
			Output.apprArm.setBoolValue(0);
			Output.lat.setValue(1);
			Custom.showHdg.setBoolValue(0);
			Text.lat.setValue("LNAV");
			if (Output.vertTemp == 2 or Output.vertTemp == 6) { # Also cancel G/S or FLARE if active
				me.setVertMode(1);
			} else {
				me.armTextCheck();
			}
		}
	},
	activateLOC: func() {
		if (Output.lat.getValue() != 2) {
			Output.lnavArm.setBoolValue(0);
			Output.locArm.setBoolValue(0);
			Output.lat.setValue(2);
			Custom.showHdg.setBoolValue(0);
			Text.lat.setValue("LOC");
			me.armTextCheck();
		}
	},
	activateGS: func() {
		if (Output.vert.getValue() != 2) {
			Internal.flchActive = 0;
			Internal.altCaptureActive = 0;
			Output.apprArm.setBoolValue(0);
			Output.vert.setValue(2);
			Text.vert.setValue("G/S");
			me.armTextCheck();
		}
	},
	checkLNAV: func(t) {
		if (flightPlanController.num[2].getValue() > 0 and FPLN.active.getBoolValue() and Position.gearAglFt.getValue() >= 30) {
			me.activateLNAV();
		} else if (FPLN.active.getBoolValue() and Output.lat.getValue() != 1 and t != 1) {
			Output.lnavArm.setBoolValue(1);
			me.armTextCheck();
		}
	},
	checkFLCH: func(a) {
		if (Position.indicatedAltitudeFt.getValue() >= a and a != 0 and !Gear.wow1.getBoolValue() and !Gear.wow2.getBoolValue()) {
			me.setVertMode(4);
		}
	},
	checkLOC: func(t, a) {
		if (Radio.inRange[Radio.radioSel].getBoolValue()) { #  # Only evaulate the rest of the condition unless we are in range
			Radio.locDeflTemp = Radio.locDefl[Radio.radioSel].getValue();
			Radio.signalQualityTemp = Radio.signalQuality[Radio.radioSel].getValue();
			if (abs(Radio.locDeflTemp) <= 0.95 and Radio.locDeflTemp != 0 and Radio.signalQualityTemp >= 0.99) {
				me.activateLOC();
			} else if (t != 1) { # Do not do this if loop calls it
				if (Output.lat.getValue() != 2) {
					Output.lnavArm.setBoolValue(0);
					Output.locArm.setBoolValue(1);
					if (a != 1) { # Don't call this if arming with G/S
						me.armTextCheck();
					}
				}
			}
		} else { # Prevent bad behavior due to FG not updating it when not in range
			Radio.signalQuality[Radio.radioSel].setValue(0);
		}
	},
	checkAPPR: func(t) {
		if (Radio.inRange[Radio.radioSel].getBoolValue()) { #  # Only evaulate the rest of the condition unless we are in range
			Radio.gsDeflTemp = Radio.gsDefl[Radio.radioSel].getValue();
			if (abs(Radio.gsDeflTemp) <= 0.2 and Radio.gsDeflTemp != 0 and Output.lat.getValue()  == 2) { # Only capture if LOC is active
				me.activateGS();
			} else if (t != 1) { # Do not do this if loop calls it
				if (Output.vert.getValue() != 2) {
					Output.apprArm.setBoolValue(1);
				}
				me.armTextCheck();
			}
		} else { # Prevent bad behavior due to FG not updating it when not in range
			Radio.signalQuality[Radio.radioSel].setValue(0);
		}
	},
	checkRadioRevision: func(l, v) { # Revert mode if signal lost
		Radio.inRangeTemp = Radio.inRange[Radio.radioSel].getBoolValue();
		if (!Radio.inRangeTemp) {
			if (l == 4 or v == 6) {
				me.ap1Master(0);
				me.ap2Master(0);
				me.setLatMode(3);
				me.setVertMode(1);
			} else {
				me.setLatMode(3); # Also cancels G/S if active
			}
		}
	},
	setClimbRateLim: func() {
		Internal.vsTemp = Internal.vs.getValue();
		if (Internal.alt.getValue() >= Position.indicatedAltitudeFt.getValue()) {
			Internal.maxVs.setValue(math.round(Internal.vsTemp));
			Internal.minVs.setValue(-500);
		} else {
			Internal.maxVs.setValue(500);
			Internal.minVs.setValue(math.round(Internal.vsTemp));
		}
	},
	resetClimbRateLim: func() {
		Internal.minVs.setValue(-500);
		Internal.maxVs.setValue(500);
	},
	takeoffGoAround: func() {
		Output.vertTemp = Output.vert.getValue();
		if ((Output.vertTemp == 2 or Output.vertTemp == 6) and Velocities.indicatedAirspeedKt.getValue() >= 80) {
			me.setLatMode(3);
			me.setVertMode(7); # Must be before kicking AP off
			Text.vert.setValue("G/A CLB");
			Input.ktsMach.setBoolValue(0);
			me.syncKtsGa();
			if (Gear.wow1.getBoolValue() or Gear.wow2.getBoolValue()) {
				me.ap1Master(0);
				me.ap2Master(0);
			}
		} else if (Gear.wow1Temp or Gear.wow2Temp) {
			me.athrMaster(1);
			if (Output.lat.getValue() != 5) { # Don't accidently disarm LNAV
				me.setLatMode(5);
			}
			me.setVertMode(7);
			Text.vert.setValue("T/O CLB");
		}
	},
	armTextCheck: func() {
		if (Output.apprArm.getBoolValue()) {
			Text.arm.setValue("ILS");
		} else if (Output.locArm.getBoolValue()) {
			Text.arm.setValue("LOC");
		} else if (Output.lnavArm.getBoolValue()) {
			Text.arm.setValue("LNV");
		} else {
			Text.arm.setValue(" ");
		}
	},
	syncKts: func() {
		Input.kts.setValue(math.clamp(math.round(Velocities.indicatedAirspeedKt.getValue()), 100, 350));
	},
	syncKtsGa: func() { # Same as syncKts, except doesn't go below V2
		Input.kts.setValue(math.clamp(math.round(Velocities.indicatedAirspeedKt.getValue()), FMGCInternal.v2, 350));
	},
	syncMach: func() {
		Input.mach.setValue(math.clamp(math.round(Velocities.indicatedMach.getValue(), 0.001), 0.5, 0.82));
	},
	syncHdg: func() {
		Input.hdg.setValue(math.round(Internal.hdgPredicted.getValue())); # Switches to track automatically
	},
	syncAlt: func() {
		Input.alt.setValue(math.clamp(math.round(Internal.altPredicted.getValue(), 100), 0, 50000));
		Internal.alt.setValue(math.clamp(math.round(Internal.altPredicted.getValue(), 100), 0, 50000));
	},
	syncVs: func() {
		Input.vs.setValue(math.clamp(math.round(Internal.vs.getValue(), 100), -6000, 6000));
	},
	syncFpa: func() {
		Input.fpa.setValue(math.clamp(math.round(Internal.fpa.getValue(), 0.1), -9.9, 9.9));
	},
	# Custom Stuff Below
	updateFma: func() {
		if (!Output.ap1.getBoolValue() and !Output.ap2.getBoolValue() and !Output.fd1.getBoolValue() and !Output.fd2.getBoolValue()) {
			me.setLatMode(9);
			me.setVertMode(9);
			me.setLatArm(0);
			Custom.Output.fmaPower.setBoolValue(0);
		} else {
			Custom.Output.fmaPower.setBoolValue(1);
			me.revertBasicMode();
		}
	},
	revertBasicMode: func() {
		if (!Gear.wow1.getBoolValue() and !Gear.wow2.getBoolValue()) { # Don't do this on ground
			if (Output.lat.getValue() == 9) {
				me.setLatMode(3);
			}
			if (Output.vert.getValue() == 9) {
				if (Custom.trkFpa.getBoolValue()) {
					me.setVertMode(5);
				} else {
					me.setVertMode(1);
				}
			}
		}
	},
	disarmLOC: func() {
		Output.locArm.setBoolValue(0);
		ITAF.armTextCheck();
	},
	disarmGS: func() {
		Output.apprArm.setBoolValue(0);
		ITAF.armTextCheck();
	},
	toggleTrkFpa: func() {
		if (Custom.trkFpa.getBoolValue()) {
			me.trkFpaOff();
		} else {
			me.trkFpaOn();
		}
	},
	trkFpaOn: func() {
		Custom.trkFpa.setBoolValue(1);
		if (Output.vert.getValue() == 1) {
			Input.vert.setValue(5); # This way we only do this if all conditions are true
		}
		Input.trk.setBoolValue(1);
		Custom.ndTrkSel[0].setBoolValue(1);
		Custom.ndTrkSel[1].setBoolValue(1);
		Input.hdgCalc = Input.hdg.getValue() + math.round(Internal.driftAngle.getValue());
		if (Input.hdgCalc > 360) { # It's rounded, so this is ok. Otherwise do >= 360.5
			Input.hdgCalc = Input.hdgCalc - 360;
		} else if (Input.hdgCalc < 1) { # It's rounded, so this is ok. Otherwise do < 0.5
			Input.hdgCalc = Input.hdgCalc + 360;
		}
		Input.hdg.setValue(Input.hdgCalc);
	},
	trkFpaOff: func() {
		Custom.trkFpa.setBoolValue(0);
		if (Output.vert.getValue() == 5) {
			Input.vert.setValue(1); # This way we only do this if all conditions are true
		}
		Input.trk.setBoolValue(0);
		Custom.ndTrkSel[0].setBoolValue(0);
		Custom.ndTrkSel[1].setBoolValue(0);
		Input.hdgCalc = Input.hdg.getValue() - math.round(Internal.driftAngle.getValue());
		if (Input.hdgCalc > 360) { # It's rounded, so this is ok. Otherwise do >= 360.5
			Input.hdgCalc = Input.hdgCalc - 360;
		} else if (Input.hdgCalc < 1) { # It's rounded, so this is ok. Otherwise do < 0.5
			Input.hdgCalc = Input.hdgCalc + 360;
		}
		Input.hdg.setValue(Input.hdgCalc);
	},
};

setlistener("/it-autoflight/input/ap1", func {
	Input.ap1Temp = Input.ap1.getBoolValue();
	if (Input.ap1Temp != Output.ap1.getBoolValue()) {
		ITAF.ap1Master(Input.ap1Temp);
	}
});

setlistener("/it-autoflight/input/ap2", func {
	Input.ap2Temp = Input.ap2.getBoolValue();
	if (Input.ap2Temp != Output.ap2.getBoolValue()) {
		ITAF.ap2Master(Input.ap2Temp);
	}
});

setlistener("/it-autoflight/input/athr", func {
	Input.athrTemp = Input.athr.getBoolValue();
	if (Input.athrTemp != Output.athr.getBoolValue()) {
		ITAF.athrMaster(Input.athrTemp);
	}
});

setlistener("/it-autoflight/input/fd1", func {
	Input.fd1Temp = Input.fd1.getBoolValue();
	if (Input.fd1Temp != Output.fd1.getBoolValue()) {
		ITAF.fd1Master(Input.fd1Temp);
	}
});

setlistener("/it-autoflight/input/fd2", func {
	Input.fd2Temp = Input.fd2.getBoolValue();
	if (Input.fd2Temp != Output.fd2.getBoolValue()) {
		ITAF.fd2Master(Input.fd2Temp);
	}
});

setlistener("/it-autoflight/input/kts-mach", func {
	if (Input.ktsMach.getBoolValue()) {
		ITAF.syncMach();
	} else {
		ITAF.syncKts();
	}
}, 0, 0);

setlistener("/it-autoflight/input/toga", func {
	if (Input.toga.getBoolValue()) {
		ITAF.takeoffGoAround();
		Input.toga.setBoolValue(0);
	}
});

setlistener("/it-autoflight/input/lat", func {
	Input.latTemp = Input.lat.getValue();
	Output.ap1Temp = Output.ap1.getBoolValue();
	Output.ap2Temp = Output.ap2.getBoolValue();
	Output.fd1Temp = Output.fd1.getBoolValue();
	Output.fd2Temp = Output.fd2.getBoolValue();
	if (!Gear.wow1.getBoolValue() and !Gear.wow2.getBoolValue()) {
		if (Output.ap1Temp or Output.ap2Temp or Output.fd1Temp or Output.fd2Temp) {
			ITAF.setLatMode(Input.latTemp);
		} else {
			ITAF.setLatMode(9);
		}
	} else {
		if (Output.ap1Temp or Output.ap2Temp or Output.fd1Temp or Output.fd2Temp) {
			ITAF.setLatArm(Input.latTemp);
		} else {
			ITAF.setLatArm(0);
		}
	}
});

setlistener("/it-autoflight/input/vert", func {
	if (!Gear.wow1.getBoolValue() and !Gear.wow2.getBoolValue() and (Output.ap1.getBoolValue() or Output.ap2.getBoolValue() or Output.fd1.getBoolValue() or Output.fd2.getBoolValue())) {
		ITAF.setVertMode(Input.vert.getValue());
	} else {
		ITAF.setVertMode(9);
	}
});

setlistener("/sim/signals/fdm-initialized", func {
	ITAF.init();
});

# For Canvas Nav Display.
setlistener("/it-autoflight/input/hdg", func {
	setprop("/autopilot/settings/heading-bug-deg", Input.hdg.getValue());
}, 0, 0);

setlistener("/it-autoflight/internal/alt", func {
	setprop("/autopilot/settings/target-altitude-ft", Internal.alt.getValue());
}, 0, 0);

var loopTimer = maketimer(0.1, ITAF, ITAF.loop);
var slowLoopTimer = maketimer(1, ITAF, ITAF.slowLoop);
