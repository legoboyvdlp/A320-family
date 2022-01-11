# A3XX Engine Control
# Copyright (c) 2022 Josh Davidson (Octal450)

var manStart = [props.globals.initNode("/controls/engines/engine[0]/man-start", 0, "BOOL"),props.globals.initNode("/controls/engines/engine[1]/man-start", 0, "BOOL")];
var lastIgniter = [props.globals.getNode("/controls/engines/engine[0]/last-igniter"),props.globals.initNode("/controls/engines/engine[1]/last-igniter")];
var igniterA = [props.globals.initNode("/controls/engines/engine[0]/igniter-a", 0, "BOOL"),props.globals.initNode("/controls/engines/engine[1]/igniter-a", 0, "BOOL")];
var igniterB = [props.globals.initNode("/controls/engines/engine[0]/igniter-b", 0, "BOOL"),props.globals.initNode("/controls/engines/engine[1]/igniter-b", 0, "BOOL")];

if (pts.Options.eng.getValue() == "IAE") {
	io.include("engines-iae.nas");
} else {
	io.include("engines-cfm.nas");
}

var eng_common_init = func {
	manStart[0].setValue(0);
	manStart[1].setValue(0);
}

var ENGINE = {
	reverseLever: [props.globals.getNode("/controls/engines/engine[0]/reverse-lever"), props.globals.getNode("/controls/engines/engine[1]/reverse-lever")],
	reverseLeverTemp: [0, 0],
	throttle: [props.globals.getNode("/controls/engines/engine[0]/throttle"), props.globals.getNode("/controls/engines/engine[1]/throttle")],
	init: func() {
		me.reverseLever[0].setBoolValue(0);
		me.reverseLever[1].setBoolValue(0);
	},
};

# Engine Sim Control Stuff
var doIdleThrust = func {
	# Idle does not respect selected engines, because it is used to respond
	# to "Retard" and both engines must be idle for spoilers to deploy
	ENGINE.throttle[0].setValue(0);
	ENGINE.throttle[1].setValue(0);
}

var doClThrust = func {
	if (pts.Sim.Input.Selected.engine[0].getBoolValue()) {
		ENGINE.throttle[0].setValue(0.63);
	}
	if (pts.Sim.Input.Selected.engine[1].getBoolValue()) {
		ENGINE.throttle[1].setValue(0.63);
	}
}

var doMctThrust = func {
	if (pts.Sim.Input.Selected.engine[0].getBoolValue()) {
		ENGINE.throttle[0].setValue(0.8);
	}
	if (pts.Sim.Input.Selected.engine[1].getBoolValue()) {
		ENGINE.throttle[1].setValue(0.8);
	}
}

var doTogaThrust = func {
	if (pts.Sim.Input.Selected.engine[0].getBoolValue()) {
		ENGINE.throttle[0].setValue(1);
	}
	if (pts.Sim.Input.Selected.engine[1].getBoolValue()) {
		ENGINE.throttle[1].setValue(1);
	}
}

# Intentionally not using + or -, floating point error would be BAD
# We just based it off Engine 1
var doRevThrust = func() {
	ENGINE.reverseLeverTemp[0] = ENGINE.reverseLever[0].getValue();
	if ((pts.Gear.wow[1].getBoolValue() or pts.Gear.wow[2].getBoolValue()) and systems.FADEC.maxDetent.getValue() == 0) {
		if (ENGINE.reverseLeverTemp[0] < 0.25) {
			ENGINE.reverseLever[0].setValue(0.25);
			ENGINE.reverseLever[1].setValue(0.25);
		} else if (ENGINE.reverseLeverTemp[0] < 0.5) {
			ENGINE.reverseLever[0].setValue(0.5);
			ENGINE.reverseLever[1].setValue(0.5);
		} else if (ENGINE.reverseLeverTemp[0] < 0.75) {
			ENGINE.reverseLever[0].setValue(0.75);
			ENGINE.reverseLever[1].setValue(0.75);
		} else if (ENGINE.reverseLeverTemp[0] < 1.0) {
			ENGINE.reverseLever[0].setValue(1.0);
			ENGINE.reverseLever[1].setValue(1.0);
		}
		ENGINE.throttle[0].setValue(0);
		ENGINE.throttle[1].setValue(0);
	} else {
		ENGINE.reverseLever[0].setValue(0);
		ENGINE.reverseLever[1].setValue(0);
	}
}

var unRevThrust = func() {
	ENGINE.reverseLeverTemp[0] = ENGINE.reverseLever[0].getValue();
	if ((pts.Gear.wow[1].getBoolValue() or pts.Gear.wow[2].getBoolValue()) and systems.FADEC.maxDetent.getValue() == 0) {
		if (ENGINE.reverseLeverTemp[0] > 0.75) {
			ENGINE.reverseLever[0].setValue(0.75);
			ENGINE.reverseLever[1].setValue(0.75);
		} else if (ENGINE.reverseLeverTemp[0] > 0.5) {
			ENGINE.reverseLever[0].setValue(0.5);
			ENGINE.reverseLever[1].setValue(0.5);
		} else if (ENGINE.reverseLeverTemp[0] > 0.25) {
			ENGINE.reverseLever[0].setValue(0.25);
			ENGINE.reverseLever[1].setValue(0.25);
		} else if (ENGINE.reverseLeverTemp[0] > 0) {
			ENGINE.reverseLever[0].setValue(0);
			ENGINE.reverseLever[1].setValue(0);
		}
		ENGINE.throttle[0].setValue(0);
		ENGINE.throttle[1].setValue(0);
	} else {
		ENGINE.reverseLever[0].setValue(0);
		ENGINE.reverseLever[1].setValue(0);
	}
}

var toggleFastRevThrust = func() {
	if ((pts.Gear.wow[1].getBoolValue() or pts.Gear.wow[2].getBoolValue()) and systems.FADEC.maxDetent.getValue() == 0) {
		if (ENGINE.reverseLever[0].getValue() != 0) { # NOT a bool, this way it always closes even if partially open
			ENGINE.reverseLever[0].setValue(0);
			ENGINE.reverseLever[1].setValue(0);
		} else {
			ENGINE.reverseLever[0].setValue(1);
			ENGINE.reverseLever[1].setValue(1);
		}
		ENGINE.throttle[0].setValue(0);
		ENGINE.throttle[1].setValue(0);
	} else {
		ENGINE.reverseLever[0].setValue(0);
		ENGINE.reverseLever[1].setValue(0);
	}
}
