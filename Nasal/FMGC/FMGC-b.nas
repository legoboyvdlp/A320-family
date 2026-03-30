var idleDescent = 0;

# A3XX FMGC Autopilot
# Based off IT Autoflight System Controller V4.1.X
# Copyright (c) 2026 Josh Davidson (Octal450)
# This file DOES NOT integrate with Property Tree Setup
# That way, we can update it from IT Autoflight Core easily

# Initialize all used variables and property nodes
# Sim
var Controls = {
	aileron: props.globals.getNode("/controls/flight/aileron", 1),
	aileron2: props.globals.getNode("/controls/flight/aileron[1]", 1),
	elevator: props.globals.getNode("/controls/flight/elevator", 1),
	elevator2: props.globals.getNode("/controls/flight/elevator[1]", 1),
	rudder: props.globals.getNode("/controls/flight/rudder", 1),
	rudder2: props.globals.getNode("/controls/flight/rudder[1]", 1),
};


var FPLN = {
	active: props.globals.getNode("/autopilot/route-manager/active", 1),
	activeTemp: 0,
	currentCourse: 0,
	currentWP: props.globals.getNode("/autopilot/route-manager/current-wp", 1),
	currentWPTemp: 0,
	deltaAngle: 0,
	deltaAngleRad: 0,
	distCoeff: 0,
	maxBank: 0,
	maxBankLimit: 0,
	nextCourse: 0,
	radius: 0,
	R: 0,
	turnDist: 0,
	wp0Dist: props.globals.getNode("/autopilot/route-manager/wp[0]/dist", 1),
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
	airborne5Secs: props.globals.getNode("/systems/fmgc/airborne-5-secs"),
	gearAglFtTemp: 0,
	gearAglFt: props.globals.getNode("/position/gear-agl-ft", 1),
	indicatedAltitudeFt: props.globals.getNode("/instrumentation/altimeter/indicated-altitude-ft", 1),
	indicatedAltitudeFtTemp: 0,
};

var Radio = {
	gsDefl: props.globals.getNode("/instrumentation/nav[0]/gs-needle-deflection-norm", 1),
	gsDeflTemp: 0,
	inRange: props.globals.getNode("/instrumentation/nav[0]/in-range", 1),
	locDefl: props.globals.getNode("/instrumentation/nav[0]/heading-needle-deflection-norm", 1),
	locDeflTemp: 0,
	signalQuality: props.globals.getNode("/instrumentation/nav[0]/signal-quality-norm", 1),
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
var Fd = {
	pitchBar: props.globals.initNode("/it-autoflight/fd/pitch-bar", 0, "DOUBLE"),
	rollBar: props.globals.initNode("/it-autoflight/fd/roll-bar", 0, "DOUBLE"),
};

var Input = {
	alt: props.globals.initNode("/it-autoflight/input/alt", 10000, "INT"),
	altDiff: 0,
	ap1: props.globals.initNode("/it-autoflight/input/ap1", 0, "BOOL"),
	ap1Temp: 0,
	ap2: props.globals.initNode("/it-autoflight/input/ap2", 0, "BOOL"),
	ap2Temp: 0,
	athr: props.globals.initNode("/it-autoflight/input/athr", 0, "BOOL"),
	athrTemp: 0,
	bankLimitSw: props.globals.initNode("/it-autoflight/input/bank-limit-sw", 0, "INT"),
	bankLimitSwTemp: 0,
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
	vert: props.globals.initNode("/it-autoflight/input/vert", 7, "INT"),
	vertTemp: 7,
	vs: props.globals.initNode("/it-autoflight/input/vs", 0, "INT"),
	vsAbs: props.globals.initNode("/it-autoflight/input/vs-abs", 0, "INT"), # Set by property rule
};

var Internal = {
	
	altManaged: props.globals.initNode("/it-autoflight/internal/mng-alt", 0, "BOOL"),
	alt: props.globals.initNode("/it-autoflight/internal/alt", 10000, "INT"),
	managedModeOn: props.globals.initNode("/it-autoflight/internal/managed-mode-on", 0, "BOOL"),
	altCaptureActive: 0,
	altDiff: 0,
	altTemp: 0,
	altPredicted: props.globals.initNode("/it-autoflight/internal/altitude-predicted", 0, "DOUBLE"),
	bankLimit: props.globals.initNode("/it-autoflight/internal/bank-limit", 0, "DOUBLE"),
	captVs: 0,
	driftAngle: props.globals.initNode("/it-autoflight/internal/drift-angle-deg", 0, "DOUBLE"),
	driftAngleTemp: 0,
	flchActive: 0,
	fpa: props.globals.initNode("/it-autoflight/internal/fpa", 0, "DOUBLE"),
	hdgErrorDeg: props.globals.initNode("/it-autoflight/internal/heading-error-deg", 0, "DOUBLE"),
	hdgPredicted: props.globals.initNode("/it-autoflight/internal/heading-predicted", 0, "DOUBLE"),
	hdgTrk: props.globals.initNode("/it-autoflight/internal/heading", 0, "DOUBLE"),
	lnavAdvanceNm: props.globals.initNode("/it-autoflight/internal/lnav-advance-nm", 0, "DOUBLE"),
	minVs: props.globals.initNode("/it-autoflight/internal/min-vs", -500, "INT"),
	maxVs: props.globals.initNode("/it-autoflight/internal/max-vs", 500, "INT"),
	navHeadingErrorDeg: props.globals.initNode("/it-autoflight/internal/nav-heading-error-deg", 0, "DOUBLE"),
	navHeadingErrorDegTemp: 0,
	vdevDot: props.globals.initNode("/it-autoflight/internal/vdev-dot", 0, "DOUBLE"),
	vs: props.globals.initNode("/it-autoflight/internal/vert-speed-fpm", 0, "DOUBLE"),
	vsTemp: 0,
	targetFpmFlch: props.globals.getNode("/it-autoflight/internal/target-fpm-flch", 0, "DOUBLE"),
};

var Output = {
	ap1: props.globals.initNode("/it-autoflight/output/ap1", 0, "BOOL"),
	ap1Temp: 0,
	ap2: props.globals.initNode("/it-autoflight/output/ap2", 0, "BOOL"),
	ap2Temp: 0,
	athr: props.globals.initNode("/it-autoflight/output/athr", 0, "BOOL"),
	athrTemp: 0,
	fd1: props.globals.initNode("/it-autoflight/output/fd1", 1, "BOOL"),
	fd1Temp: 0,
	fd2: props.globals.initNode("/it-autoflight/output/fd2", 1, "BOOL"),
	fd2Temp: 0,
	gsArm: props.globals.initNode("/it-autoflight/output/gs-arm", 0, "BOOL"),
	lat: props.globals.initNode("/it-autoflight/output/lat", 5, "INT"),
	latTemp: 5,
	lnavArm: props.globals.initNode("/it-autoflight/output/lnav-arm", 0, "BOOL"),
	locArm: props.globals.initNode("/it-autoflight/output/loc-arm", 0, "BOOL"),
	thrMode: props.globals.initNode("/it-autoflight/output/thr-mode", 2, "INT"),
	vert: props.globals.initNode("/it-autoflight/output/vert", 7, "INT"),
	
	vertTemp: 7,
};

var Text = {
	lat: props.globals.initNode("/it-autoflight/text/lat", "T/O", "STRING"),
	spd: props.globals.initNode("/it-autoflight/text/spd", "PITCH", "STRING"),
	vert: props.globals.initNode("/it-autoflight/text/vert", "T/O CLB", "STRING"),
	vertTemp: "T/O CLB",
};

var Settings = {
	accelFt: props.globals.initNode("/it-autoflight/settings/accel-ft", 1500, "INT"), # Changable from MCDU, eventually set to 1500 above runway
};

var Sound = {
	apOff: props.globals.initNode("/it-autoflight/sound/apoffsound", 0, "BOOL"), # Is this still needed??? -JD
	enableApOff: 0,
};

# A3XX Custom
var Custom = {
	apFdOn: 0,
	hdgTime: -45,
	ndTrkSel: [props.globals.getNode("/instrumentation/efis[0]/trk-selected", 1), props.globals.getNode("/instrumentation/efis[1]/trk-selected", 1)],
	showHdg: props.globals.initNode("/it-autoflight/custom/show-hdg", 1, "BOOL"),
	trkFpa: props.globals.initNode("/it-autoflight/custom/trk-fpa", 0, "BOOL"),
	Input: {
		spdManaged: props.globals.getNode("/it-autoflight/input/spd-managed", 1),
	},
	Output: {
		fmaPower: 0,
		vsFCU: props.globals.initNode("/it-autoflight/output/vs-fcu-display", "", "STRING"),
	},
	Sound: {
		athrOff: props.globals.initNode("/it-autoflight/sound/athrsound", 0, "BOOL"),
		enableAthrOff: 0,
	},
	ThrLock: props.globals.getNode("/systems/fadec/thr-locked", 1)
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
		Input.vsAbs.setValue(0);
		Custom.Output.vsFCU.setValue(left(sprintf("%+05.0f",0),3));
		Input.fpa.setValue(0);
		Input.fpaAbs.setValue(0);
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
		Output.gsArm.setBoolValue(0);
		Output.thrMode.setValue(0);
		Output.lat.setValue(9);
		Output.vert.setValue(9);
		Internal.minVs.setValue(-500);
		Internal.maxVs.setValue(500);
		Internal.bankLimit.setValue(30);
		Internal.alt.setValue(10000);
		Internal.altCaptureActive = 0;
		Input.kts.setValue(100);
		Input.mach.setValue(0.5);
		Text.spd.setValue("THRUST");
		UpdateFma.arm();
		me.updateLatText("");
		me.updateVertText("");
		Custom.showHdg.setBoolValue(1);
		Custom.Output.fmaPower = 1;
		
		# Sync FMA
		fmaAp();
		fmaAthr();
		fmaFd();
		
		ManagedSPD.stop();
		loopTimer.start();
		slowLoopTimer.start();
	},
	loop: func() {
		Gear.wow1Temp = Gear.wow1.getBoolValue();
		Gear.wow2Temp = Gear.wow2.getBoolValue();
		Output.latTemp = Output.lat.getValue();
		Output.vertTemp = Output.vert.getValue();
		# print(canvas_pfd.canvas_pfd.ASItrendIsShown);
		# Trip system off
		if (Output.ap1Temp or Output.ap2Temp) { # Trip AP off
			if (abs(Controls.aileron.getValue()) >= 0.2 or abs(Controls.elevator.getValue()) >= 0.2 or abs(Controls.rudder.getValue()) >= 0.2 or abs(Controls.aileron2.getValue()) >= 0.2 or abs(Controls.elevator2.getValue()) >= 0.2 or abs(Controls.rudder2.getValue()) >= 0.2) {
				fcu.apOff("hard", 0);
			}
		}
		
		if ((systems.FADEC.n1Mode[0].getValue() > 0 or systems.FADEC.n1Mode[1].getValue() > 0) and Output.athr.getBoolValue()) {
			fcu.athrOff("hard");
		}
		
		# LNAV Reversion
		if (Output.lat.getValue() == 1) { # Only evaulate the rest of the condition if we are in LNAV mode
			if (flightPlanController.num[2].getValue() == 0 or !FPLN.active.getValue()) {
				me.setLatMode(3);
			}
		}
		
		# VOR/ILS Reversion
		if (Output.latTemp == 2 or Output.vertTemp == 2 or Output.vertTemp == 6) {
			me.checkRadioReversion(Output.latTemp, Output.vertTemp);
		}
		
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
			me.checkLnav(1);
		}
		
		# VOR/LOC or ILS/LOC Capture
		if (Output.locArm.getBoolValue()) {
			me.checkLoc(1);
		}
		
		# G/S Capture
		if (Output.gsArm.getBoolValue()) {
			me.checkGs(1);
		}
		
		# Autoland Logic
		if (Output.ap1Temp or Output.ap2Temp) { # Lateral ALIGN/ROLLOUT requires AP to function
			if (Output.latTemp == 2) {
				if (Position.gearAglFtTemp <= 50) {
					me.setLatMode(4);
				}
			}
		} else {
			if (Output.latTemp == 4) {
				me.activateLoc();
			}
		}
		if (Output.vertTemp == 2) {
			if (Position.gearAglFtTemp <= 400 and Position.gearAglFtTemp >= 5) {
				me.updateVertText("LAND");

				if (Position.gearAglFtTemp <= 50) {
					me.setVertMode(6);
				}
			}
		} else if (Output.vertTemp == 6) {
			if (Gear.wow1Temp and Gear.wow2Temp) {
				if (Text.vert.getValue() != "ROLLOUT") {
					me.updateLatText("ROLLOUT");
					me.updateVertText("ROLLOUT");
				}
			} else if (Text.vert.getValue() != "FLARE") {
				me.updateLatText("ALIGN");
				me.updateVertText("FLARE");
			}
		}
		
		# FLCH Engagement
		if (Text.vertTemp == "T/O CLB") {
			me.checkClbMode(Settings.accelFt.getValue());
		}
		
		# Altitude Capture/Sync Logic
		if (Output.vertTemp != 0 and Internal.managedModeOn.getValue() == 0) {
			Internal.alt.setValue(Input.alt.getValue());
		}

		Internal.altTemp = Internal.alt.getValue();
		Internal.altDiff = Internal.altTemp - Position.indicatedAltitudeFtTemp;
		
		if (Output.vertTemp != 0 and Output.vertTemp != 2 and Output.vertTemp != 6 and Output.vertTemp != 9) {
			Internal.captVs = math.clamp(math.round(abs(Internal.vs.getValue()) / 5, 100), 50, 2500); # Capture limits
			Custom.apFdOn = Output.ap1Temp or Output.ap2Temp or Output.fd1.getBoolValue() or Output.fd2.getBoolValue();
			if (abs(Internal.altDiff) <= Internal.captVs and !Gear.wow1Temp and !Gear.wow2Temp and Custom.apFdOn) {
				if (Internal.altTemp >= Position.indicatedAltitudeFtTemp and Internal.vsTemp >= -25) { # Don't capture if we are going the wrong way
					vertTemp = Output.vertTemp;
					me.setVertMode(3);
					if (vertTemp == 8 and Internal.altManaged.getBoolValue()) { # If we are in V/S and managed alt, switch to ALT CAP
						armDes();
					} elsif (vertTemp == 4 and Internal.altManaged.getBoolValue()) {
						armClb();
					}
					
				} else if (Internal.altTemp < Position.indicatedAltitudeFtTemp and Internal.vsTemp <= 25) { # Don't capture if we are going the wrong way
					vertTemp = Output.vertTemp;
					me.setVertMode(3);
					if (vertTemp == 8 and Internal.altManaged.getBoolValue()) { # If we are in V/S and managed alt, switch to ALT CAP
						armDes();
					} elsif (vertTemp == 4 and Internal.altManaged.getBoolValue()) {
						armClb();
					}
				}
			}
		}
		
		# Altitude Hold Min/Max Reset
		if (Internal.altCaptureActive) {
			if (abs(Internal.altDiff) <= 20 and Text.vert.getValue() != "ALT HLD") {
				me.resetClimbRateLim();
				me.updateVertText("ALT HLD");
			}
		}
		
		# Thrust Mode Selector
		me.updateThrustMode();
		
		# Custom Stuff Below
		# Heading Sync
		if (!Custom.showHdg.getBoolValue()) {
			Input.hdg.setValue(Misc.pfdHeadingScale.getValue());
		}
		
		# Preselect Heading
		if (Output.latTemp != 0 and Output.latTemp != 9) { # Modes that always show HDG
			if (Custom.hdgTime + 45 >= Misc.elapsedSec.getValue()) {
				Custom.showHdg.setBoolValue(1);
			} else {
				Custom.showHdg.setBoolValue(0);
			}
		}
		if (FMGCInternal.phase == 4 or FMGCInternal.phase == 5) {
			Internal.vdevDot.setValue(me.calculateVdev());
		}
	},
	slowLoop: func() {
		Velocities.trueAirspeedKtTemp = Velocities.trueAirspeedKt.getValue();
		FPLN.activeTemp = FPLN.active.getValue();
		FPLN.currentWPTemp = FPLN.currentWP.getValue();
		
		# Waypoint Advance Logic
		if (flightPlanController.num[2].getValue() > 0 and FPLN.activeTemp == 1 and FPLN.currentWPTemp != -1) {
			if ((FPLN.currentWPTemp + 1) < flightPlanController.num[2].getValue()) {
				Velocities.groundspeedMps = pts.Velocities.groundspeedKt.getValue() * 0.5144444444444;
				FPLN.currentCourse = getprop("/autopilot/route-manager/route/wp[" ~ FPLN.currentWPTemp ~ "]/leg-bearing-true-deg");
				FPLN.nextCourse = getprop("/autopilot/route-manager/route/wp[" ~ (FPLN.currentWPTemp + 1) ~ "]/leg-bearing-true-deg");
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
				
				# This is removed because sequencing is done by the flightplan controller
				# Internal.lnavAdvanceNm.setValue(FPLN.turnDist);
				
				# TODO - if the waypoint is the DEST waypoint, crosstrack error must be less than 0.5nm and course error less than 30 deg
				# TODO - if in HDG mode, if no distance, then crosstrack error must be less than 5nm
				# TODO - if in nav, no distance condition applies, but DEST course error must be less than 30 (CONFIRM)
				
				if (abs(FPLN.deltaAngle) < 120 and FPLN.wp0Dist.getValue() <= FPLN.turnDist and !Gear.wow1.getBoolValue() and fmgc.flightPlanController.flightplans[2].getWP(FPLN.currentWPTemp).fly_type == "flyBy") {
					flightPlanController.autoSequencing();
				} elsif (FPLN.wp0Dist.getValue() <= 0.15 and !Gear.wow1.getBoolValue()) {
					flightPlanController.autoSequencing();
				}
			}
		}
	},
	ap1Master: func(s) {
		if (s == 1) {
			if (Output.vert.getValue() != 6 and !Gear.wow1.getBoolValue() and !Gear.wow2.getBoolValue() and FMGCNodes.Power.FMGC1Powered.getBoolValue() and fbw.FBW.apOff == 0 and Position.gearAglFt.getValue() >= 100 and Position.airborne5Secs.getBoolValue()) {
				Output.ap1.setBoolValue(1);
				me.updateFmaAp();
				Output.latTemp = Output.lat.getValue();
				if (Output.ap2.getBoolValue() and !Output.gsArm.getBoolValue() and Output.latTemp != 2 and Output.latTemp != 4) {
					me.ap2Master(0);
				}
				Sound.enableApOff = 1;
				Sound.apOff.setBoolValue(0);
			}
		} else {
			Output.ap1.setBoolValue(0);
			me.apOffFunction();
		}
		fmaAp();
		
		Output.ap1Temp = Output.ap1.getBoolValue();
		if (Input.ap1.getBoolValue() != Output.ap1Temp) {
			Input.ap1.setBoolValue(Output.ap1Temp);
		}
	},
	ap2Master: func(s) {
		if (s == 1) {
			if (Output.vert.getValue() != 6 and !Gear.wow1.getBoolValue() and !Gear.wow2.getBoolValue() and FMGCNodes.Power.FMGC2Powered.getBoolValue() and fbw.FBW.apOff == 0 and Position.gearAglFt.getValue() >= 100 and Position.airborne5Secs.getBoolValue()) {
				Output.ap2.setBoolValue(1);
				me.updateFmaAp();
				Output.latTemp = Output.lat.getValue();
				if (Output.ap1.getBoolValue() and !Output.gsArm.getBoolValue() and Output.latTemp != 2 and Output.latTemp != 4) {
					me.ap1Master(0);
				}
				Sound.enableApOff = 1;
				Sound.apOff.setBoolValue(0);
			}
		} else {
			Output.ap2.setBoolValue(0);
			me.apOffFunction();
		}
		fmaAp();
		
		Output.ap2Temp = Output.ap2.getBoolValue();
		if (Input.ap2.getBoolValue() != Output.ap2Temp) {
			Input.ap2.setBoolValue(Output.ap2Temp);
		}
	},
	apOffFunction: func() {
		if (!Output.ap1.getBoolValue() and !Output.ap2.getBoolValue()) { # Only do if both APs are off
			me.updateFmaAp();
			
			if (Sound.enableApOff) {
				Sound.apOff.setBoolValue(1);
				Sound.enableApOff = 0;
			}
		}
	},
	athrMaster: func(s) {
		if (s == 1) {
			if ((FMGCNodes.Power.FMGC1Powered.getBoolValue() or FMGCNodes.Power.FMGC2Powered.getBoolValue()) and !pts.FMGC.CasCompare.casRejectAll.getBoolValue() and fbw.FBW.apOff == 0 and systems.FADEC.n1Mode[0].getValue() == 0 and systems.FADEC.n1Mode[1].getValue() == 0) {

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
		fmaAthr();
		
		Output.athrTemp = Output.athr.getBoolValue();
		if (Input.athr.getBoolValue() != Output.athrTemp) {
			Input.athr.setBoolValue(Output.athrTemp);
		}
	},
	fd1Master: func(s) {
		if (s == 1) {
			Output.fd1.setBoolValue(1);
			me.updateFmaAp();
		} else {
			Output.fd1.setBoolValue(0);
			if (!Output.fd2.getBoolValue()) {
				me.updateFmaAp();
			}
		}
		fmaFd();
		
		Output.fd1Temp = Output.fd1.getBoolValue();
		if (Input.fd1.getBoolValue() != Output.fd1Temp) {
			Input.fd1.setBoolValue(Output.fd1Temp);
		}
	},
	fd2Master: func(s) {
		if (s == 1) {
			Output.fd2.setBoolValue(1);
			me.updateFmaAp();
		} else {
			Output.fd2.setBoolValue(0);
			if (!Output.fd1.getBoolValue()) {
				me.updateFmaAp();
			}
		}
		fmaFd();
		
		Output.fd2Temp = Output.fd2.getBoolValue();
		if (Input.fd2.getBoolValue() != Output.fd2Temp) {
			Input.fd2.setBoolValue(Output.fd2Temp);
		}
	},
	setLatMode: func(n) {
		Output.vertTemp = Output.vert.getValue();
		Input.altDiff = Input.alt.getValue() - Position.indicatedAltitudeFt.getValue();
		if (n == 0) { # HDG SEL
			me.updateLnavArm(0);
			me.updateLocArm(0);
			me.updateGsArm(0);
			Output.lat.setValue(0);
			Custom.showHdg.setBoolValue(1);
			me.updateLatText("HDG");
			if (Output.vertTemp == 2 or Output.vertTemp == 6) { # Also cancel G/S or FLARE if active
				me.setVertMode(1);
			}
		} else if (n == 1) { # LNAV
			me.updateLocArm(0);
			me.updateGsArm(0);
			me.checkLnav(0);
		} else if (n == 2) { # VOR/LOC
			me.updateLnavArm(0);
			me.checkLoc(0);
		} else if (n == 3) { # HDG HLD
			me.updateLnavArm(0);
			me.updateLocArm(0);
			me.updateGsArm(0);
			me.syncHdg();
			Output.lat.setValue(0);
			Custom.showHdg.setBoolValue(1);
			me.updateLatText("HDG");
			if (Output.vertTemp == 2 or Output.vertTemp == 6) { # Also cancel G/S or FLARE if active
				me.setVertMode(1);
			}
		} else if (n == 4) { # ALIGN
			me.updateLnavArm(0);
			me.updateLocArm(0);
			me.updateGsArm(0);
			Output.lat.setValue(4);
			Custom.showHdg.setBoolValue(0);
			me.updateLatText("ALIGN");
		} else if (n == 5) { # RWY
			me.updateLnavArm(0);
			me.updateLocArm(0);
			me.updateGsArm(0);
			Output.lat.setValue(5);
			Custom.showHdg.setBoolValue(0);
			me.updateLatText("T/O");
		} else if (n == 9) { # NONE
			me.updateLnavArm(0);
			me.updateLocArm(0);
			me.updateGsArm(0);
			Output.lat.setValue(9);
			Custom.showHdg.setBoolValue(1);
			me.updateLatText("");
		}
	},
	setLatArm: func(n) {
		if (n == 0) {
			me.updateLnavArm(0);
			Custom.showHdg.setBoolValue(1);
		} else if (n == 1) {
			if (flightPlanController.num[2].getValue() > 0 and FPLN.active.getBoolValue()) {
				me.updateLnavArm(1);
				Custom.showHdg.setBoolValue(0);
			}
		} else if (n == 3) {
			me.syncHdg();
			me.updateLnavArm(0);
			Custom.showHdg.setBoolValue(1);
		} 
	},


	calculateVdev: func() {
		var output = fmgc.flightPlanController.getDesAltConst();
		var nextManagedAlt = output[0];
		var distance = output[1];
		var isGeo = output[2];
		var wptIndex = output[4];
		if (isGeo) {
			var idealSlope = fmgc.flightPlanController.getIdealSlope(nextManagedAlt,distance,wptIndex);
			var deltaAlt = Position.indicatedAltitudeFt.getValue() - nextManagedAlt;
			var properDeltaAlt = distance * idealSlope;
			var difference = deltaAlt - properDeltaAlt;
			print("proper delta alt is " ~ properDeltaAlt ~ "and idealSlope is " ~ idealSlope);
			return difference;
		} else {
			if (distance < 0) {
				distance = 0;
			}
			var deltaAlt = Position.indicatedAltitudeFt.getValue() - nextManagedAlt;
			# var properDeltaAlt = distance * 318;
			var properDeltaAlt =  distance * fmgc.flightPlanController.getCurrentDescentCoefficient();
			var difference = deltaAlt - properDeltaAlt;
			# if (output[2] == 1 and difference < 0) {
			# 	difference = 0;
			# }
			return difference;
		}
	},

	getVs: func(distance, deltaAlt, isGeo) {
		print("getVs called");
		if (Velocities.indicatedAirspeedKt.getValue() - Input.kts.getValue() >= 10) {
			var vs = Internal.targetFpmFlch.getValue();
			# idleDescent = 1;
			print("vs down indicated airspeed is " ~ Velocities.indicatedAirspeedKt.getValue() ~ "input kts is " ~ Input.kts.getValue());
		} elsif (isGeo) {
			var gs = Velocities.groundspeedKt.getValue();
			var vs = -(deltaAlt * gs) / (distance * 60);
			print("GEO VS: " ~ vs ~ "and gs*5: " ~ -1*gs*5);
			var currentSpd = Velocities.indicatedAirspeedKt.getValue();
			var targetSpd = Input.kts.getValue();
			if (targetSpd - currentSpd <= 10) {
				vs = math.max(vs, -1*gs*5);
			}
			idleDescent = 0;
		} else {
			# var properDeltaAlt = distance * 318;
			var properDeltaAlt = distance * fmgc.flightPlanController.getCurrentDescentCoefficient();
			properDeltaAlt = math.max(properDeltaAlt, 0);
			var vs = Internal.targetFpmFlch.getValue();
			if (deltaAlt < properDeltaAlt) {
				idleDescent = 0;
				vs = -1000;
			} else {
				idleDescent = 1;
			}
		}
		vs = math.min(vs, 0);
		return vs;
	},

	setVs: func(vs) {
		print("setting vs to ");
		print(vs);
		Internal.vsTemp = vs;
		Input.vs.setValue(vs);
		Input.vsAbs.setValue(abs(vs));
	},

	setVertMode: func(n) {
		Input.altDiff = Input.alt.getValue() - Position.indicatedAltitudeFt.getValue();
		if (n == 0) { # ALT HLD
			Internal.managedModeOn.setBoolValue(0);
			Internal.flchActive = 0;
			Internal.altCaptureActive = 0;
			# me.updateGsArm(0);
			Output.vert.setValue(0);
			me.resetClimbRateLim();
			me.updateVertText("ALT HLD");
			me.syncAlt();
			me.updateThrustMode();
		} else if (n == 1) { # V/S
			Internal.managedModeOn.setBoolValue(0);
			if (abs(Input.altDiff) >= 25) {
				Internal.flchActive = 0;
				Internal.altCaptureActive = 0;
				me.updateGsArm(0);
				Output.vert.setValue(1);
				me.updateVertText("V/S");
				me.syncVs();
				me.updateThrustMode();
			} else {
				me.updateGsArm(0);
			}
		} else if (n == 2) { # G/S
			me.updateLnavArm(0);
			me.checkLoc(0);
			me.checkGs(0);
		} else if (n == 3) { # ALT CAP
			Internal.managedModeOn.setBoolValue(0);
			Internal.flchActive = 0;
			Output.vert.setValue(0);
			me.setClimbRateLim();
			Internal.altCaptureActive = 1;
			idleDescent = 0;
			print("idle descent false");
			me.updateVertText("ALT CAP");
			me.updateThrustMode();
			
		} else if (n == 4) { # FLCH
			Internal.managedModeOn.setBoolValue(0);
			me.updateGsArm(0);
			Output.vert.setValue(1);
			Internal.alt.setValue(Input.alt.getValue());
			Internal.altDiff = Internal.alt.getValue() - Position.indicatedAltitudeFt.getValue();
			Internal.altManaged.setValue(0);
			if (abs(Internal.altDiff) >= 250) { # SPD CLB or SPD DES
				Internal.altCaptureActive = 0;
				Output.vert.setValue(4);
				printValues();
				Internal.flchActive = 1;
				Internal.alt.setValue(Input.alt.getValue());
				me.updateThrustMode();
			} else { # ALT CAP
				Internal.flchActive = 0;
				Internal.alt.setValue(Input.alt.getValue());
				Internal.altCaptureActive = 1;
				Output.vert.setValue(0);
				me.updateVertText("ALT CAP");
				me.updateThrustMode();
			}
		} else if (n == 5) { # FPA
			Internal.managedModeOn.setBoolValue(0);
			if (abs(Input.altDiff) >= 25) {
				Internal.flchActive = 0;
				Internal.altCaptureActive = 0;
				me.updateGsArm(0);
				Output.vert.setValue(5);
				me.updateVertText("FPA");
				me.syncFpa();
				me.updateThrustMode();
			} else {
				me.updateGsArm(0);
			}
		} else if (n == 6) { # FLARE/ROLLOUT
			Internal.managedModeOn.setBoolValue(0);
			Internal.flchActive = 0;
			Internal.altCaptureActive = 0;
			me.updateGsArm(0);
			Output.vert.setValue(6);
			me.updateVertText("FLARE");
			me.updateThrustMode();
		} else if (n == 7) { # T/O CLB or G/A CLB, text is set by TOGA selector
			Internal.managedModeOn.setBoolValue(0);
			Internal.flchActive = 0;
			Internal.altCaptureActive = 0;
			me.updateGsArm(0);
			Output.vert.setValue(7);
			me.updateThrustMode();
		} else if (n == 8) { # CLB/DES
			
			if (abs(Input.altDiff) >= 250) {
				Internal.altCaptureActive = 0;
				if (Input.altDiff >= 0) {
					Internal.managedModeOn.setBoolValue(1);
					managedClb();
				} else {
					Internal.managedModeOn.setBoolValue(1);
					ITAF.updateVertText("DES");
					managedDes();
				}
			} else { # ALT CAP
				Internal.flchActive = 0;
				Internal.alt.setValue(Input.alt.getValue());
				Internal.altCaptureActive = 1;
				idleDescent = 0;
				print("idle descent false");
				Output.vert.setValue(0);
				me.updateVertText("ALT CAP");
				me.updateThrustMode();
			}
		} else if (n == 9) { # NONE
			Internal.flchActive = 0;
			Internal.altCaptureActive = 0;
			me.updateGsArm(0);
			Output.vert.setValue(9);
			me.updateVertText("");
			me.updateThrustMode();
		}
	},
	updateThrustMode: func() {
		Output.vertTemp = Output.vert.getValue();
		if (Output.athr.getBoolValue() and Output.vertTemp != 7 and (Output.ap1.getBoolValue() or Output.ap2.getBoolValue()) and Position.gearAglFt.getValue() <= 30 and (Output.vertTemp == 2 or Output.vertTemp == 6)) {
			# Manual says 40 feet - but video reference shows 30!
			Output.thrMode.setValue(1);
			Text.spd.setValue("RETARD");
		} else if (Output.vertTemp == 4) {
			if (Internal.alt.getValue() >= Position.indicatedAltitudeFt.getValue()) {
				Output.thrMode.setValue(2);
				Text.spd.setValue("PITCH");
				if (Internal.flchActive and Text.vert.getValue() != "SPD CLB" and Internal.managedModeOn.getValue() == 0) {
					me.updateVertText("SPD CLB");
				}
			} else {
				if (Internal.managedModeOn.getValue() == 0) {
					Output.thrMode.setValue(1);
					Text.spd.setValue("PITCH");
				}
				if (Internal.flchActive and Text.vert.getValue() != "SPD DES" and Internal.managedModeOn.getValue() == 0) {
					me.updateVertText("SPD DES");
				}
			}
		} else if (Output.vertTemp == 7) {
			Output.thrMode.setValue(2);
			Text.spd.setValue("PITCH");
		} else if (Output.vertTemp == 8 and idleDescent == 1) {
			Output.thrMode.setValue(1);
			Text.spd.setValue("PITCH");
		} else {
			Output.thrMode.setValue(0);
			Text.spd.setValue("THRUST");
		}
	},
	activateLnav: func() {
		if (Output.lat.getValue() != 1) {
			me.updateLnavArm(0);
			me.updateLocArm(0);
			me.updateGsArm(0);
			Output.lat.setValue(1);
			Custom.showHdg.setBoolValue(0);
			me.updateLatText("LNAV");
			if (Output.vertTemp == 2 or Output.vertTemp == 6) { # Also cancel G/S or FLARE if active
				me.setVertMode(1);
			}
		}
	},
	activateLoc: func() {
		if (Output.lat.getValue() != 2) {
			me.updateLnavArm(0);
			me.updateLocArm(0);
			Output.lat.setValue(2);
			Custom.showHdg.setBoolValue(0);
			me.updateLatText("LOC");
		}
	},
	activateGs: func() {
		if (Output.vert.getValue() != 2) {
			Internal.flchActive = 0;
			Internal.altCaptureActive = 0;
			Internal.altManaged.setValue(0);
			Internal.managedModeOn.setBoolValue(0);
			me.updateGsArm(0);
			Output.vert.setValue(2);
			me.updateVertText("G/S");
			me.updateThrustMode();
		}
	},
	checkLnav: func(t) {
		FPLN.activeTemp = FPLN.active.getBoolValue();
		if (flightPlanController.num[2].getValue() > 0 and FPLN.activeTemp and Position.gearAglFt.getValue() >= 30) {
			me.activateLnav();
		} else if (FPLN.activeTemp and Output.lat.getValue() != 1 and t != 1) {
			me.updateLnavArm(1);
		}
	},
	checkClbMode: func(a) {
		if (!Gear.wow1.getBoolValue() and !Gear.wow2.getBoolValue() and Position.indicatedAltitudeFt.getValue() >= a and a != 0) {
			me.setVertMode(8);
		}
	},
	checkLoc: func(t) {
		if (Radio.inRange.getBoolValue()) { #  # Only evaulate the rest of the condition unless we are in range
			Internal.navHeadingErrorDegTemp = Internal.navHeadingErrorDeg.getValue();
			Radio.locDeflTemp = Radio.locDefl.getValue();
			Radio.signalQualityTemp = Radio.signalQuality.getValue();
			if (abs(Radio.locDeflTemp) <= 0.95 and Radio.locDeflTemp != 0 and Radio.signalQualityTemp >= 0.99) {
				if (abs(Radio.locDeflTemp) <= 0.25) {
					me.activateLoc();
				} else if (Radio.locDeflTemp >= 0 and Internal.navHeadingErrorDegTemp <= 0) {
					me.activateLoc();
				} else if (Radio.locDeflTemp < 0 and Internal.navHeadingErrorDegTemp >= 0) {
					me.activateLoc();
				} else if (t != 1) { # Do not do this if loop calls it
					if (Output.lat.getValue() != 2) {
						me.updateLnavArm(0);
						me.updateLocArm(1);
					}
				}
			} else if (t != 1) { # Do not do this if loop calls it
				if (Output.lat.getValue() != 2) {
					me.updateLnavArm(0);
					me.updateLocArm(1);
				}
			}
		} else {
			Radio.signalQuality.setValue(0); # Prevent bad behavior due to FG not updating it when not in range
			me.updateLocArm(0);
		}
	},
	checkGs: func(t) {
		if (Radio.inRange.getBoolValue()) { #  # Only evaulate the rest of the condition unless we are in range
			Radio.gsDeflTemp = Radio.gsDefl.getValue();
			if (abs(Radio.gsDeflTemp) <= 0.2 and Radio.gsDeflTemp != 0 and Output.lat.getValue() == 2) { # Only capture if LOC is active
				me.activateGs();
			} else if (t != 1) { # Do not do this if loop calls it
				if (Output.vert.getValue() != 2) {
					me.updateGsArm(1);
				}
			}
		} else {
			Radio.signalQuality.setValue(0); # Prevent bad behavior due to FG not updating it when not in range
			me.updateGsArm(0);
		}
	},
	checkRadioReversion: func(l, v) { # Revert mode if signal lost
		if (!Radio.inRange.getBoolValue()) {
			if (l == 4 or v == 6) {
				me.ap1Master(0);
				me.ap2Master(0);
				me.setLatMode(3); # Also cancels G/S and land modes if active
			} else {
				me.setLatMode(3); # Also cancels G/S and land modes if active
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
			me.updateVertText("G/A CLB");
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
			me.updateVertText("T/O CLB");
		}
	},
	syncKts: func() {
		Input.kts.setValue(math.clamp(math.round(Velocities.indicatedAirspeedKt.getValue()), 100, 399));
	},
	syncKtsGa: func() { # Same as syncKts, except doesn't go below V2
		Input.kts.setValue(math.clamp(math.round(Velocities.indicatedAirspeedKt.getValue()), FMGCInternal.v2, 399));
	},
	syncMach: func() {
		Input.mach.setValue(math.clamp(math.round(Velocities.indicatedMach.getValue(), 0.001), 0.1, 0.99));
	},
	syncHdg: func() {
		Input.hdg.setValue(math.round(Internal.hdgPredicted.getValue())); # Switches to track automatically
	},
	syncAlt: func() {
		Input.alt.setValue(math.clamp(math.round(Internal.altPredicted.getValue(), 100), 0, 50000));
		Internal.alt.setValue(math.clamp(math.round(Internal.altPredicted.getValue(), 100), 0, 50000));
	},
	syncVs: func() {
		Internal.vsTemp = math.clamp(math.round(Internal.vs.getValue(), 100), -6000, 6000);
		Input.vs.setValue(Internal.vsTemp);	
		Input.vsAbs.setValue(abs(Internal.vsTemp));
		fmgc.Custom.Output.vsFCU.setValue(left(sprintf("%+05.0f", Internal.vsTemp), 3));
	},
	syncFpa: func() {
		Internal.fpaTemp = Internal.fpa.getValue();
		Input.fpa.setValue(math.clamp(math.round(Internal.fpaTemp, 0.1), -9.9, 9.9));
		Input.fpaAbs.setValue(abs(math.clamp(math.round(Internal.fpaTemp, 0.1), -9.9, 9.9)));
	},
	# Custom Stuff Below
	updateFmaAp: func() {
		if (!Output.ap1.getBoolValue() and !Output.ap2.getBoolValue() and !Output.fd1.getBoolValue() and !Output.fd2.getBoolValue()) {
			me.setLatMode(9);
			me.setVertMode(9);
			me.setLatArm(0);
			Custom.Output.fmaPower = 0;
		} else {
			if (!Custom.Output.fmaPower) showAllBoxes();
			Custom.Output.fmaPower = 1;
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
	disarmLoc: func() {
		me.updateLocArm(0);
	},
	disarmAppr: func() {
		me.updateGsArm(0);
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
		# Forces HDG UP even in TRK/FPA.
		Custom.ndTrkSel[0].setBoolValue(0);
		Custom.ndTrkSel[1].setBoolValue(0);
		Input.hdgCalc = Input.hdg.getValue() + math.round(Internal.driftAngle.getValue());
		if (Input.hdgCalc > 360) { # It's rounded, so this is ok. Otherwise do >= 360.5
			Input.hdgCalc = Input.hdgCalc - 360;
		} else if (Input.hdgCalc < 1) { # It's rounded, so this is ok. Otherwise do < 0.5
			Input.hdgCalc = Input.hdgCalc + 360;
		}
		UpdateFma.lat();
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
		UpdateFma.lat();
		Input.hdg.setValue(Input.hdgCalc);
	},
	updateLatText: func(t) {
		Text.lat.setValue(t);
		UpdateFma.lat();
	},
	updateVertText: func(t) {
		Text.vert.setValue(t);
		UpdateFma.vert();
	},
	updateLnavArm: func(n) {
		Output.lnavArm.setBoolValue(n);
		UpdateFma.arm();
	},
	updateLocArm: func(n) {
		Output.locArm.setBoolValue(n);
		UpdateFma.arm();
	},
	updateGsArm: func(n) {
		Output.gsArm.setBoolValue(n);
		UpdateFma.arm();
	},
};


var managedDes = func {
	var output = fmgc.flightPlanController.getDesAltConst();
	var realNextManagedAlt = output[0];
	var showNextManagedAlt = fmgc.flightPlanController.calculateManagedLvlOffAltitude();
	var distance = output[1];
	var isGeo = output[2];

	var nextSelectedAlt = Input.alt.getValue();
	var alt = 0;

	if (showNextManagedAlt > nextSelectedAlt) {
		alt = showNextManagedAlt;
		Internal.altManaged.setValue(1);
	} else {
		alt = nextSelectedAlt;
		Internal.altManaged.setValue(0);
	}
	var managedDeltaAlt = Position.indicatedAltitudeFt.getValue() - realNextManagedAlt;
	var realDeltaAlt = Position.indicatedAltitudeFt.getValue() - alt;
	if (realDeltaAlt >= 300 and Text.vert.getValue() == "DES") {
		Internal.alt.setValue(alt);
		print("managed des called");
		
		ITAF.setVs(ITAF.getVs(distance, managedDeltaAlt, isGeo, realNextManagedAlt));
		Output.vert.setValue(8);
		ITAF.updateThrustMode();
		settimer(managedDes, 2);
	} elsif (Text.vert.getValue() == "DES") {
		ITAF.setVertMode(3);
		armDes();
	}
};
#To be called when engages into CLB mode, uses the same mechanisism as OP CLB,
# only changing the target altitude and the mode shown on the FMA
var managedClb = func {
	var nextManagedAlt = fmgc.flightPlanController.getClbAltConst()[0];
	var nextSelectedAlt = Input.alt.getValue();
	var alt = 0;
	# print("next managed alt is " ~ nextManagedAlt ~ "next selected alt is " ~ nextSelectedAlt);
	if (nextManagedAlt < nextSelectedAlt) {
		var alt = nextManagedAlt;
		Internal.altManaged.setValue(1);
	} else {
		var alt = nextSelectedAlt;
		Internal.altManaged.setValue(0);
	}
	Internal.alt.setValue(alt);
	Output.vert.setValue(4);
	Internal.flchActive = 1;
	ITAF.updateVertText("CLB");
};
# To be called when in altitude acquire mode, 
# when the aircraft passes that waypoint, the CLB mode should resume
var armClb = func {
	if (fmgc.flightPlanController.getClbAltConst() == nil or abs(fmgc.flightPlanController.getClbAltConst()[0] - Position.indicatedAltitudeFt.getValue()) > 300) {
		ITAF.updateVertText("CLB");
		ITAF.setVertMode(8); # CLB mode
	} else if (Text.vert.getValue() == "ALT HLD" or Text.vert.getValue() == "ALT CAP") {
		settimer(armClb, 2);
	}
};

# To be called when in altitude acquire mode,
# when the aircraft passes that waypoint the DES mode should resume
var armDes = func {
	# print("arming des " ~ Text.vert.getValue());
	if (fmgc.flightPlanController.getDesAltConst() == nil or (abs(fmgc.flightPlanController.getDesAltConst()[0] - Position.indicatedAltitudeFt.getValue()) > 300)) {
		ITAF.setVertMode(8); # DES mode
	} else if (Text.vert.getValue() == "ALT HLD" or Text.vert.getValue() == "ALT CAP") {
		# print(fmgc.flightPlanController.getDesAltConst()[0] - Position.indicatedAltitudeFt.getValue());
		settimer(armDes, 2);
	}
};

var printValues = func {
	altitude = Position.indicatedAltitudeFt.getValue();
	distance = fmgc.flightPlanController.distToWpt.getValue();
	IAS = Velocities.indicatedAirspeedKt.getValue();
	print("Values: " ~ altitude ~ "," ~ distance ~ "," ~ IAS);
	settimer(printValues, 2);
};

setlistener(Gear.wow1, func(val) {
	if (!val.getBoolValue() and FPLN.currentWP.getValue() == 0) {
		flightPlanController.autoSequencing();
	}
});
	
setlistener("/it-autoflight/input/ap1", func() {
	Input.ap1Temp = Input.ap1.getBoolValue();
	if (Input.ap1Temp != Output.ap1.getBoolValue()) {
		ITAF.ap1Master(Input.ap1Temp);
	}
});

setlistener("/it-autoflight/input/ap2", func() {
	Input.ap2Temp = Input.ap2.getBoolValue();
	if (Input.ap2Temp != Output.ap2.getBoolValue()) {
		ITAF.ap2Master(Input.ap2Temp);
	}
});

setlistener("/it-autoflight/input/athr", func() {
	Input.athrTemp = Input.athr.getBoolValue();
	if (Input.athrTemp != Output.athr.getBoolValue()) {
		ITAF.athrMaster(Input.athrTemp);
	}
});

setlistener("/it-autoflight/input/fd1", func() {
	Input.fd1Temp = Input.fd1.getBoolValue();
	if (Input.fd1Temp != Output.fd1.getBoolValue()) {
		ITAF.fd1Master(Input.fd1Temp);
	}
});

setlistener("/it-autoflight/input/fd2", func() {
	Input.fd2Temp = Input.fd2.getBoolValue();
	if (Input.fd2Temp != Output.fd2.getBoolValue()) {
		ITAF.fd2Master(Input.fd2Temp);
	}
});

	
setlistener("/it-autoflight/input/kts-mach", func() {
	if (Output.vert.getValue() == 7) { # Mach is not allowed in Mode 7, and don't sync
		if (Input.ktsMach.getBoolValue()) {
			Input.ktsMach.setBoolValue(0);
		}
	} else {
		if (Input.ktsMach.getBoolValue()) {
			ITAF.syncMach();
		} else {
			ITAF.syncKts();
		}
	}
}, 0, 0);

setlistener("/it-autoflight/input/toga", func() {
	if (Input.toga.getBoolValue()) {
		ITAF.takeoffGoAround();
		Input.toga.setBoolValue(0);
	}
});

setlistener("/it-autoflight/input/lat", func() {
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

setlistener("/it-autoflight/input/vert", func() {
	if (!Gear.wow1.getBoolValue() and !Gear.wow2.getBoolValue() and (Output.ap1.getBoolValue() or Output.ap2.getBoolValue() or Output.fd1.getBoolValue() or Output.fd2.getBoolValue())) {
		ITAF.setVertMode(Input.vert.getValue());
	} else {
		ITAF.setVertMode(9);
	}
});

# Mode Reversions
setlistener(pts.Systems.Navigation.ADR.Output.overspeed, func(v) {
	if (v.getBoolValue() and !Output.ap1.getBoolValue() and !Output.ap2.getBoolValue() and Output.athr.getBoolValue() and Modes.PFD.FMA.pitchMode == "OP CLB" and Modes.PFD.FMA.throttleMode == "THR CLB") {
		Input.fd1.setValue(0);
		Input.fd2.setValue(0);
		ecam.aural[5].setBoolValue(0);
		settimer(func() {
			ecam.aural[5].setBoolValue(1);
		}, 0.15);
	}
}, 0, 0);

setlistener(pts.Systems.Navigation.ADR.Output.underspeed, func(v) {
	if (v.getBoolValue() and !Output.ap1.getBoolValue() and !Output.ap2.getBoolValue() and Output.athr.getBoolValue() and Modes.PFD.FMA.pitchMode == "OP DES" and Modes.PFD.FMA.throttleMode == "THR IDLE") {
		Input.fd1.setValue(0);
		Input.fd2.setValue(0);
		ecam.aural[5].setBoolValue(0);
		settimer(func() {
			ecam.aural[5].setBoolValue(1);
		}, 0.15);
	}
}, 0, 0);

setlistener("/sim/signals/fdm-initialized", func {
	ITAF.init();
});

# For Canvas Nav Display.
setlistener("/it-autoflight/input/hdg", func() {
	pts.Autopilot.Settings.headingBugDeg.setValue(Input.hdg.getValue());
}, 0, 0);

setlistener("/it-autoflight/internal/alt", func() {
	pts.Autopilot.Settings.targetAltitudeFt.setValue(Internal.alt.getValue());
}, 0, 0);

var loopTimer = maketimer(0.1, ITAF, ITAF.loop);
var slowLoopTimer = maketimer(1, ITAF, ITAF.slowLoop);

# var data = [
#     [39000, 0.3272079632952649, 0.30173467257691877, -2.932768357525391, 1.0985039724052816, -0.06667176768856217, 0.2038828272393203],
#     [38000, 4.579269492551761, 4.361255069995993, 4.153665359089664, 4.131660793198441, 3.873375224417694, 4.1790691916217675],
#     [37000, 7.832427989765811, 8.354026291981649, 8.035664264706773, 8.251978897422063, 7.770296298706542, 8.415075746157195],
#     [36000, 11.340984746389259, 12.035048848345166, 11.652957127864372, 11.86922774216502, 11.47784316018343, 12.084219429151752],
#     [35000, 15.596051531937867, 16.020558207141004, 15.464221929033648, 15.701492332756345, 15.381912352892513, 16.053029352894278],
#     [34000, 19.786185006420368, 19.830230321781972, 19.226594069143164, 19.274472154262313, 19.044740275679207, 19.782171449889212],
#     [33000, 23.719184887627918, 23.488094164772956, 22.811950678928163, 22.76519900074531, 22.526196031703904, 23.309106133998643],
#     [32000, 27.787647399859104, 27.50606086005269, 26.62746512164848, 26.376600198300522, 26.160039730163646, 27.034047897417235],
#     [31000, 31.73392679255722, 31.201025389759113, 30.293944676743674, 29.74941690974956, 29.644371148059, 30.573732288731865],
#     [30000, 35.44902505322697, 34.74403888907485, 33.76555304740528, 33.057361105750644, 32.93516861642798, 33.94643028303156],
#     [29000, 39.108866279278075, 38.32100461948355, 37.266605075686854, 36.31516883161863, 36.28738029903964, 37.357707233876866],
#     [28000, 42.93147652300029, 41.888983050782365, 40.77790595120431, 39.6853195341015, 39.56316861261404, 40.72009297506155],
#     [27000, 46.44926743342256, 45.34821013722886, 44.14986049827883, 42.89737041786297, 42.635786819524505, 44.0128802449941],
#     [26000, 50.0492314628516, 48.82114403034023, 47.427778214228525, 46.030387811890236, 45.528792276175466, 47.21152534418679],
#     [25000, 53.67068576272728, 52.674293863950936, 51.28311056318175, 49.23787968442161, 48.76002322939798, 50.50145869277693],
#     [24000, 57.014137527863525, 56.33508353360363, 54.83934515334654, 52.291040263814935, 51.78334530034459, 53.630515346199815],
#     [23000, 60.19898363508056, 59.74254431838598, 58.20426050914031, 55.1938960457518, 54.7102444497007, 56.61497765031486],
#     [22000, 63.57704818398341, 63.35526050357918, 61.73326440158525, 58.23300708215455, 57.75860422982677, 59.758393751788034],
#     [21000, 66.80553242017238, 66.76382643045756, 65.07340656953721, 61.053005830754486, 60.677032171171376, 62.72431596087875],
#     [20000, 69.94803311379331, 70.02049842372892, 68.25946334134471, 63.78142603151934, 63.578967967227946, 65.42483117309442],
#     [19000, 73.06430202385101, 73.33219011110148, 71.51415100176818, 66.32952675914004, 66.1472419600599, 68.09785941794529],
#     [18000, 76.17283883581615, 76.64515179609701, 74.73263021951992, 68.53854733428597, 68.36279141445529, 70.4103754673977],
#     [17000, 79.35483035612947, 79.92816738518475, 77.99593768305832, 70.86202116902969, 70.59075278889964, 72.75691262813531],
#     [16000, 82.45108196530754, 83.15166286151887, 81.17230430573147, 73.76576999289337, 73.58189588866215, 75.82984967982644],
#     [15000, 85.43569936971889, 86.42622017858301, 84.29833095281163, 76.45631694376053, 76.3690908210414, 78.61515729988423],
#     [14000, 88.45481194983215, 89.60168260606866, 87.42842652655813, 79.14935856942344, 79.06966355385735, 81.38889404089213],
#     [13000, 91.44645147684663, 92.63892260567445, 90.44969862295284, 81.75725606744837, 81.68903816160443, 84.09421256535974],
#     [12000, 94.34756678714554, 95.70915341935817, 93.46282106948084, 84.36026459775827, 84.30443038412216, 86.788914672832],
#     [11000, 97.15501497895254, 98.73717343707035, 96.39673762892869, 86.92444738507305, 86.87368458716286, 89.42421074576013],
#     [10000, 99.80235341542993, 101.65693404279494, 99.24977104787422, 89.47564339518117, 89.35421800940912, 92.02313451282933],
#     [9000, 99.80235341542993, 104.6626909754127, 102.0292325577586, 92.00725909171246, 89.35421800940912, 94.59999280671724],
#     [8000, 99.80235341542993, 107.66844790803046, 104.80869406764299, 94.53887478824376, 89.35421800940912, 97.17685110060515],
#     [7000, 99.80235341542993, 110.67420484064822, 107.58815557752737, 97.07049048477505, 89.35421800940912, 99.75370939449304],
#     [6000, 99.80235341542993, 113.67996177326597, 110.36761708741176, 99.60210618130634, 89.35421800940912, 102.33056768838095],
#     [5000, 99.80235341542993, 116.68571870588373, 113.14707859729614, 102.13372187783764, 89.35421800940912, 104.90742598226885],
#     [4000, 99.80235341542993, 119.69147563850149, 115.92654010718053, 104.66533757436893, 89.35421800940912, 107.48428427615676],
#     [3000, 99.80235341542993, 122.69723257111924, 118.70600161706491, 107.19695327090022, 89.35421800940912, 110.06114257004467],
#     [2000, 99.80235341542993, 125.702989503737, 121.4854631269493, 109.72856896743153, 89.35421800940912, 112.63800086393258],
#     [1000, 99.80235341542993, 128.70874643635477, 124.26492463683368, 112.26018466396282, 89.35421800940912, 115.21485915782047],
# ];

# var lerp = func(x0, y0, x1, y1, x) {
#     if(x1 == x0) return y0;
#     return y0 + (y1 - y0) * (x - x0) / (x1 - x0);
# };

# var build_distance_profile = func(cost_index, wind) {
#     var profile = [];

#     print("=== BUILDING PROFILE ===");
#     print("cost_index=" ~ cost_index ~ " wind=" ~ wind);

#     for(var i = 0; i < size(data); i = i + 1) {
#         var alt = data[i][0];

#         # CI 0
#         var dist_ci0 = 0;
#         if(wind < 0)
#             dist_ci0 = lerp(-10, data[i][2], 0, data[i][3], wind);
#         else
#             dist_ci0 = lerp(0, data[i][3], 10, data[i][1], wind);

#         # CI 999
#         var dist_ci999 = 0;
#         if(wind < 0)
#             dist_ci999 = lerp(-10, data[i][6], 0, data[i][4], wind);
#         else
#             dist_ci999 = lerp(0, data[i][4], 10, data[i][5], wind);

#         # interpolate CI
#         var dist = lerp(0, dist_ci0, 999, dist_ci999, cost_index);

#         profile = append(profile, [alt, dist]);

#         print("alt=" ~ alt ~ " dist=" ~ dist);
#     }

#     print("=== PROFILE READY ===");
#     return profile;
# };

# var get_altitude_from_distance = func(target_distance, starting_altitude) {

#     var cost_index = fmgc.FMGCNodes.costIndex.getValue();
#     var wind = Velocities.trueAirspeedKt.getValue() - Velocities.groundspeedKt.getValue();
#     wind = math.clamp(wind, -10, 10);

#     print("=== INPUT ===");
#     print("starting_altitude=" ~ starting_altitude ~ " target_distance=" ~ target_distance);
#     print("cost_index=" ~ cost_index ~ " wind=" ~ wind);

#     if(starting_altitude < 1000) starting_altitude = 1000;
#     if(starting_altitude > 39000) starting_altitude = 39000;

#     var profile = build_distance_profile(cost_index, wind);

#     # --- Step 1: get distance at starting altitude ---
#     var distance_at_start = 0;
#     for(var i = 0; i < size(profile) - 1; i = i + 1) {
#         var alt1 = profile[i][0];
#         var alt2 = profile[i+1][0];
#         if((alt1 - starting_altitude) * (alt2 - starting_altitude) <= 0) {
#             distance_at_start = lerp(alt1, profile[i][1], alt2, profile[i+1][1], starting_altitude);
#             break;
#         }
#     }

#     print("distance_at_start=" ~ distance_at_start);

#     # --- Step 2: compute target distance in profile ---
#     var distance_target = distance_at_start - target_distance;
#     print("distance_target=" ~ distance_target);

#     if(distance_target < 0) {
#         print("distance_target < 0 → returning 39000");
#         return 39000;  # can't reach
#     }

#     # --- Step 3: search upward from next higher altitude ---
#     for(var i = 0; i < size(profile) - 1; i = i + 1) {
#         var alt1 = profile[i][0];
#         var alt2 = profile[i+1][0];

#         if(alt2 < starting_altitude) continue;  # only look above starting altitude

#         var d1 = profile[i][1];
#         var d2 = profile[i+1][1];

#         print("checking bracket: alt1=" ~ alt1 ~ " alt2=" ~ alt2 ~ " d1=" ~ d1 ~ " d2=" ~ d2);

#         if((d1 - distance_target) * (d2 - distance_target) <= 0) {
#             var result = lerp(d1, alt1, d2, alt2, distance_target);
#             print("FOUND BRACKET → returning alt=" ~ result);
#             return result;
#         }
#     }

#     print("no bracket found → returning 39000");
#     return 39000;  # if we reach the top
# };