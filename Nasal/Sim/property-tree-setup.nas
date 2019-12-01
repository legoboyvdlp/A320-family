# A320 Property Tree Setup
# Copyright (c) 2019 Joshua Davidson (Octal450)
# Modified by Jonathan Redpath for A320
# Nodes organized like property tree, except when lots of identical (example: Gear wow), where vectors are used to make it easier
# Anything that says Temp is set by another file to avoid multiple getValue calls
# Usage Example: pts.Class.SubClass.node.getValue()

var APU = {
	masterSw: props.globals.getNode("/controls/APU/master"),
	rpm: props.globals.getNode("/systems/apu/rpm"),
};

var Consumables = {
	Fuel: {
		totalFuelLbs: props.globals.getNode("/consumables/fuel/total-fuel-lbs"),
	},
};

var Controls = {
	Engines: {
		startSw: props.globals.getNode("/controls/engines/engine-start-switch"),
		Engine1: {
			cutoffSw: props.globals.getNode("/controls/engines/engine[0]/cutoff-switch"),
			firePb: props.globals.getNode("/controls/engines/engine[0]/fire-btn"),
			throttle: props.globals.getNode("/controls/engines/engine[0]/throttle"),
		},
		Engine2: {
			cutoffSw: props.globals.getNode("/controls/engines/engine[1]/cutoff-switch"),
			firePb: props.globals.getNode("/controls/engines/engine[1]/fire-btn"),
			throttle: props.globals.getNode("/controls/engines/engine[1]/throttle"),
		},
	},
	Flight: {
		aileron: props.globals.getNode("/controls/flight/aileron"),
	},
	Gear: {
		gearDown: props.globals.getNode("/controls/gear/gear-down"),
	},
};

var ECAM = {
	fwcWarningPhase: props.globals.initNode("/ECAM/warning-phase", 1, "INT"),
};

var Engines = {
	Engine1: {
		epractual: props.globals.getNode("/engines/engine[0]/epr-actual"),
		n1actual: props.globals.getNode("/engines/engine[0]/n1-actual"),
		n2actual: props.globals.getNode("/engines/engine[0]/n2-actual"),
		state: props.globals.getNode("/engines/engine[0]/state"),
	},
	Engine2: {
		epractual: props.globals.getNode("/engines/engine[1]/epr-actual"),
		n1actual: props.globals.getNode("/engines/engine[1]/n1-actual"),
		n2actual: props.globals.getNode("/engines/engine[1]/n2-actual"),
		state: props.globals.getNode("/engines/engine[1]/state"),
	},
};

var FMGC = {
	CasCompare: {
		rejectAll: props.globals.getNode("/systems/fmgc/cas-compare/cas-reject-all"),
	},
};

var Gear = {
	compression: [props.globals.getNode("/gear/gear[0]/compression-norm"),props.globals.getNode("/gear/gear[1]/compression-norm"),props.globals.getNode("/gear/gear[2]/compression-norm")],
	wow: [props.globals.getNode("/gear/gear[0]/wow"),props.globals.getNode("/gear/gear[1]/wow"),props.globals.getNode("/gear/gear[2]/wow")],
};

var Instrumentation = {
	AirspeedIndicator: {
		indicatedSpdKt: props.globals.getNode("/instrumentation/airspeed-indicator/indicated-speed-kt"),
	},
	TCAS: {
		Inputs: {
			mode: props.globals.getNode("/instrumentation/tcas/inputs/mode"),
		},
	},
};

var JSBSIM = {
	FCS: {
		flapDeg: props.globals.getNode("/fdm/jsbsim/fcs/flap-pos-deg"),
		slatDeg: props.globals.getNode("/fdm/jsbsim/fcs/slat-pos-deg"),
	},
};

var JSBSim = {
	FBW: {
		aileron: props.globals.getNode("/fdm/jsbsim/fbw/aileron-sidestick"),
		elevator: props.globals.getNode("/fdm/jsbsim/fbw/elevator-sidestick"),
	},
	Propulsion: {
		Engine1: {
			fuelUsed: props.globals.getNode("/fdm/jsbsim/propulsion/engine[0]/fuel-used-lbs"),
		},
		Engine2: {
			fuelUsed: props.globals.getNode("/fdm/jsbsim/propulsion/engine[1]/fuel-used-lbs"),
		},
	},
};

var Options = {
	eng: props.globals.getNode("/options/eng"),
};

var Position = {
	gearAglFt: props.globals.getNode("/position/gear-agl-ft"),
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

var Orientation = {
	pitch: props.globals.getNode("/orientation/pitch-deg"),
	roll: props.globals.getNode("/orientation/roll-deg"),
	yaw: props.globals.getNode("/orientation/yaw-deg"),
};

var PTSSystems = {
	Thrust: {
		flex: props.globals.getNode("/systems/thrust/lim-flex"),
	},
};

setprop("/systems/acconfig/property-tree-setup-loaded", 1);
