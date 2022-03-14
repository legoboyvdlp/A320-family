# A3XX Engine Control
# Copyright (c) 2022 Josh Davidson (Octal450)

var ENGINE = {
	cutoffSwitch: [props.globals.getNode("/controls/engines/engine[0]/cutoff-switch"), props.globals.getNode("/controls/engines/engine[1]/cutoff-switch")],
	manStart: [props.globals.getNode("/controls/engines/engine[0]/start-switch"), props.globals.getNode("/controls/engines/engine[1]/start-switch")],
	reverseLever: [props.globals.getNode("/controls/engines/engine[0]/reverse-lever"), props.globals.getNode("/controls/engines/engine[1]/reverse-lever")],
	reverseLeverTemp: [0, 0],
	throttle: [props.globals.getNode("/controls/engines/engine[0]/throttle"), props.globals.getNode("/controls/engines/engine[1]/throttle")],
	init: func() {
		me.manStart[0].setBoolValue(0);
		me.manStart[1].setBoolValue(0);
		me.reverseLever[0].setBoolValue(0);
		me.reverseLever[1].setBoolValue(0);
	},
};

var IGNITION = {
	autoStart: [props.globals.getNode("/systems/ignition/auto-start-1"), props.globals.getNode("/systems/ignition/auto-start-2")],
	igniterSelectTemp: [0, 0],
	startSw: props.globals.getNode("/controls/ignition/start-sw"),
	init: func() {
		me.startSw.setValue(1);
	},
	fastStart: func(n) {
		ENGINE.cutoffSwitch[n].setBoolValue(0);
		pts.Fdm.JSBsim.Propulsion.setRunning.setValue(n);
	},
	updateigniterSelect: func(n) {
		if (me.autoStart[n].getBoolValue()) {
			me.igniterSelectTemp[n] = pts.Systems.Acconfig.Options.igniterSelect[n].getValue();
			if (me.igniterSelectTemp[n] == 1) {
				pts.Systems.Acconfig.Options.igniterSelect[n].setValue(0);
			} else {
				pts.Systems.Acconfig.Options.igniterSelect[n].setValue(me.igniterSelectTemp[n] + 1);
			}
			acconfig.writeSettings();
		}
	},
};

setlistener("/engines/engine[0]/state", func() {
	if (pts.Engines.Engine.state[0].getValue() == 1) {
		IGNITION.updateigniterSelect(0);
	}
}, 0, 0);

setlistener("/engines/engine[1]/state", func() {
	if (pts.Engines.Engine.state[1].getValue() == 1) {
		IGNITION.updateigniterSelect(1);
	}
}, 0, 0);


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
