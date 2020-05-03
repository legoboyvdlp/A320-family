# A320 Property Tree Setup
# Copyright (c) 2020 Josh Davidson (Octal450) and Jonathan Redpath
# Nodes organized like property tree, except when lots of identical (example: Gear wow), where vectors are used to make it easier
# Anything that says Temp is set by another file to avoid multiple getValue calls
# Usage Example: pts.Class.SubClass.node.getValue()

var APU = {
	masterSw: props.globals.getNode("/controls/apu/master"),
	rpm: props.globals.getNode("/engines/engine[2]/n1"),
};

var Consumables = {
	Fuel: {
		totalFuelLbs: props.globals.getNode("/consumables/fuel/total-fuel-lbs"),
	},
};

var Controls = {
	Engines: {
		startSw: props.globals.getNode("/controls/engines/engine-start-switch"),
		Engine: {
			cutoffSw: [props.globals.getNode("/controls/engines/engine[0]/cutoff-switch"), props.globals.getNode("/controls/engines/engine[1]/cutoff-switch")],
			firePb: [props.globals.getNode("/controls/engines/engine[0]/fire-btn"), props.globals.getNode("/controls/engines/engine[1]/fire-btn")],
			throttle: [props.globals.getNode("/controls/engines/engine[0]/throttle"), props.globals.getNode("/controls/engines/engine[1]/throttle")],
		},
	},
	Flight: {
		aileron: props.globals.getNode("/controls/flight/aileron"),
	},
	Gear: {
		gearDown: props.globals.getNode("/controls/gear/gear-down"),
		parkingBrake: props.globals.getNode("/controls/gear/brake-parking"),
	},
};

var ECAM = {
	fwcWarningPhase: props.globals.initNode("/ECAM/warning-phase", 1, "INT"),
};

var Engines = {
	Engine: {
		eprActual: [props.globals.getNode("/engines/engine[0]/epr-actual"), props.globals.getNode("/engines/engine[1]/epr-actual")],
		n1Actual: [props.globals.getNode("/engines/engine[0]/n1-actual"), props.globals.getNode("/engines/engine[1]/n1-actual")],
		n2Actual: [props.globals.getNode("/engines/engine[0]/n2-actual"), props.globals.getNode("/engines/engine[1]/n2-actual")],
		state: [props.globals.getNode("/engines/engine[0]/state"), props.globals.getNode("/engines/engine[1]/state")],
	},
};

var Environment = {
	magVar: props.globals.getNode("/environment/magnetic-variation-deg"),
};

var Fdm = {
	JSBsim: {
		Fcs: {
			flapDeg: props.globals.getNode("/fdm/jsbsim/fcs/flap-pos-deg"),
			slatDeg: props.globals.getNode("/fdm/jsbsim/fcs/slat-pos-deg"),
		},
		Fbw: {
			aileron: props.globals.getNode("/fdm/jsbsim/fbw/aileron-sidestick"),
			elevator: props.globals.getNode("/fdm/jsbsim/fbw/elevator-sidestick"),
		},
		Propulsion: {
			Engine: {
				fuelUsed: [props.globals.getNode("/fdm/jsbsim/propulsion/engine[0]/fuel-used-lbs"), props.globals.getNode("/fdm/jsbsim/propulsion/engine[1]/fuel-used-lbs")],
			},
		},
	},
};

var FMGC = {
	CasCompare: {
		casRejectAll: props.globals.getNode("/systems/fmgc/cas-compare/cas-reject-all"),
	},
};

var Gear = {
	compression: [props.globals.getNode("/gear/gear[0]/compression-norm"), props.globals.getNode("/gear/gear[1]/compression-norm"), props.globals.getNode("/gear/gear[2]/compression-norm")],
	wow: [props.globals.getNode("/gear/gear[0]/wow"), props.globals.getNode("/gear/gear[1]/wow"), props.globals.getNode("/gear/gear[2]/wow")],
	position: [props.globals.getNode("/gear/gear[0]/position-norm"), props.globals.getNode("/gear/gear[1]/position-norm"), props.globals.getNode("/gear/gear[2]/position-norm")],
	rollspeed: [props.globals.getNode("/gear/gear[0]/rollspeed-ms"), props.globals.getNode("/gear/gear[1]/rollspeed-ms"), props.globals.getNode("/gear/gear[2]/rollspeed-ms")],
};

var Instrumentation = {
	AirspeedIndicator: {
		indicatedSpdKt: props.globals.getNode("/instrumentation/airspeed-indicator/indicated-speed-kt"),
	},
	Altimeter: {
		indicatedFt: props.globals.getNode("/instrumentation/altimeter[0]/indicated-altitude-ft"),
		oldQnh: props.globals.getNode("/instrumentation/altimeter[0]/oldqnh"),
		settingInhg: props.globals.getNode("/instrumentation/altimeter[0]/setting-inhg"),
		std: props.globals.getNode("/instrumentation/altimeter[0]/std"),
	},
	Efis: {
		Inputs: {
			arpt: [props.globals.initNode("/instrumentation/efis[0]/inputs/arpt", 0, "BOOL"), props.globals.initNode("/instrumentation/efis[1]/inputs/arpt", 0, "BOOL")],
			cstr: [props.globals.initNode("/instrumentation/efis[0]/inputs/CSTR", 0, "BOOL"), props.globals.initNode("/instrumentation/efis[1]/inputs/CSTR", 0, "BOOL")],
			dme: [props.globals.initNode("/instrumentation/efis[0]/inputs/DME", 0, "BOOL"), props.globals.initNode("/instrumentation/efis[1]/inputs/DME", 0, "BOOL")],
			ndb: [props.globals.initNode("/instrumentation/efis[0]/inputs/NDB", 0, "BOOL"), props.globals.initNode("/instrumentation/efis[1]/inputs/NDB", 0, "BOOL")],
			rangeNm: [props.globals.initNode("/instrumentation/efis[0]/inputs/range-nm", 20, "INT"), props.globals.initNode("/instrumentation/efis[1]/inputs/range-nm", 20, "INT")],
			tfc: [props.globals.initNode("/instrumentation/efis[0]/inputs/tfc", 0, "BOOL"), props.globals.initNode("/instrumentation/efis[1]/inputs/tfc", 0, "BOOL")],
			vord: [props.globals.initNode("/instrumentation/efis[0]/inputs/VORD", 0, "BOOL"), props.globals.initNode("/instrumentation/efis[1]/inputs/VORD", 0, "BOOL")],
			wpt: [props.globals.initNode("/instrumentation/efis[0]/inputs/wpt", 0, "BOOL"), props.globals.initNode("/instrumentation/efis[1]/inputs/wpt", 0, "BOOL")],
		},
		Nd: {
			displayMode: [props.globals.initNode("/instrumentation/efis[0]/nd/display-mode", "NAV", "STRING"), props.globals.initNode("/instrumentation/efis[1]/nd/display-mode", "NAV", "STRING")],
		},
		Mfd: {
			pnlModeNum: [props.globals.initNode("/instrumentation/efis[0]/mfd/pnl_mode-num", 2, "INT"), props.globals.initNode("/instrumentation/efis[1]/mfd/pnl_mode-num", 2, "INT")],
		},
	},
	TCAS: {
		Inputs: {
			mode: props.globals.getNode("/instrumentation/tcas/inputs/mode"),
		},
	},
};

var Options = {
	eng: props.globals.getNode("/options/eng"),
};

var Orientation = {
	pitch: props.globals.getNode("/orientation/pitch-deg"),
	roll: props.globals.getNode("/orientation/roll-deg"),
	yaw: props.globals.getNode("/orientation/yaw-deg"),
};

var Position = {
	gearAglFt: props.globals.getNode("/position/gear-agl-ft"),
	latitude: props.globals.getNode("/position/latitude-deg"),
	longitude: props.globals.getNode("/position/longitude-deg"),
};

var Sim = {
	aero: props.globals.getNode("/sim/aero"),
	Replay: {
		replayActive: props.globals.getNode("/sim/replay/replay-state"),
	},
	Time: {
		elapsedSec: props.globals.getNode("/sim/time/elapsed-sec"),
	},
};

var Velocities = {
	groundspeed: props.globals.getNode("/velocities/groundspeed-kt"),
};

setprop("/systems/acconfig/property-tree-setup-loaded", 1);
