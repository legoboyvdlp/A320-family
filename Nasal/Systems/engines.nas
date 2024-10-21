# A3XX Engine Control
# Copyright (c) 2024 Josh Davidson (Octal450)

var ENGINES = {
	cutoffSwitch: [props.globals.getNode("/controls/engines/engine[0]/cutoff-switch"), props.globals.getNode("/controls/engines/engine[1]/cutoff-switch")],
	manStart: [props.globals.getNode("/controls/engines/engine[0]/start-switch"), props.globals.getNode("/controls/engines/engine[1]/start-switch")],
	throttle: [props.globals.getNode("/controls/engines/engine[0]/throttle"), props.globals.getNode("/controls/engines/engine[1]/throttle")],
	throttleTemp: [0, 0],
	init: func() {
		me.manStart[0].setBoolValue(0);
		me.manStart[1].setBoolValue(0);
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
		ENGINES.cutoffSwitch[n].setBoolValue(0);
		pts.Fdm.JSBSim.Propulsion.setRunning.setValue(n);
	},
	fastStop: func(n) {
		ENGINES.cutoffSwitch[n].setBoolValue(1);
		settimer(func() { # Required delay
			pts.Fdm.JSBSim.Propulsion.Engine.n1[n].setValue(0.1);
			pts.Fdm.JSBSim.Propulsion.Engine.n2[n].setValue(0.1);
		}, 0.1);
	},
	updateIgniterSelect: func(n) {
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
		IGNITION.updateIgniterSelect(0);
	}
}, 0, 0);

setlistener("/engines/engine[1]/state", func() {
	if (pts.Engines.Engine.state[1].getValue() == 1) {
		IGNITION.updateIgniterSelect(1);
	}
}, 0, 0);


# Engine Sim Control Stuff
var doIdleThrust = func {
	# Idle does not respect selected engines, because it is used to respond
	# to "Retard" and both engines must be idle for spoilers to deploy
	ENGINES.throttle[0].setValue(0);
	ENGINES.throttle[1].setValue(0);
}

var doClThrust = func {
	if (pts.Sim.Input.Selected.engine[0].getBoolValue()) {
		ENGINES.throttle[0].setValue(0.63);
	}
	if (pts.Sim.Input.Selected.engine[1].getBoolValue()) {
		ENGINES.throttle[1].setValue(0.63);
	}
}

var doMctThrust = func {
	if (pts.Sim.Input.Selected.engine[0].getBoolValue()) {
		ENGINES.throttle[0].setValue(0.8);
	}
	if (pts.Sim.Input.Selected.engine[1].getBoolValue()) {
		ENGINES.throttle[1].setValue(0.8);
	}
}

var doTogaThrust = func {
	if (pts.Sim.Input.Selected.engine[0].getBoolValue()) {
		ENGINES.throttle[0].setValue(1);
	}
	if (pts.Sim.Input.Selected.engine[1].getBoolValue()) {
		ENGINES.throttle[1].setValue(1);
	}
}

# Base off Engine 1
var doRevThrust = func() {
	if ((pts.Gear.wow[1].getBoolValue() or pts.Gear.wow[2].getBoolValue()) and systems.FADEC.maxDetent.getValue() == 0) {
		ENGINES.throttleTemp[0] = ENGINES.throttle[0].getValue();
		if (!FADEC.reverseEngage[0].getBoolValue() or !FADEC.reverseEngage[1].getBoolValue()) {
			FADEC.reverseEngage[0].setBoolValue(1);
			FADEC.reverseEngage[1].setBoolValue(1);
			ENGINES.throttle[0].setValue(0);
			ENGINES.throttle[1].setValue(0);
		} else if (ENGINES.throttleTemp[0] < 0.4) {
			ENGINES.throttle[0].setValue(0.4);
			ENGINES.throttle[1].setValue(0.4);
		} else if (ENGINES.throttleTemp[0] < 0.7) {
			ENGINES.throttle[0].setValue(0.7);
			ENGINES.throttle[1].setValue(0.7);
		} else if (ENGINES.throttleTemp[0] < 1) {
			ENGINES.throttle[0].setValue(1);
			ENGINES.throttle[1].setValue(1);
		}
	} else {
		ENGINES.throttle[0].setValue(0);
		ENGINES.throttle[1].setValue(0);
		FADEC.reverseEngage[0].setBoolValue(0);
		FADEC.reverseEngage[1].setBoolValue(0);
	}
}

var unRevThrust = func() {
	if ((pts.Gear.wow[1].getBoolValue() or pts.Gear.wow[2].getBoolValue()) and systems.FADEC.maxDetent.getValue() == 0) {
		if (FADEC.reverseEngage[0].getBoolValue() or FADEC.reverseEngage[1].getBoolValue()) {
			ENGINES.throttleTemp[0] = ENGINES.throttle[0].getValue();
			if (ENGINES.throttleTemp[0] > 0.7) {
				ENGINES.throttle[0].setValue(0.7);
				ENGINES.throttle[1].setValue(0.7);
			} else if (ENGINES.throttleTemp[0] > 0.4) {
				ENGINES.throttle[0].setValue(0.4);
				ENGINES.throttle[1].setValue(0.4);
			} else if (ENGINES.throttleTemp[0] > 0.05) {
				ENGINES.throttle[0].setValue(0);
				ENGINES.throttle[1].setValue(0);
			} else {
				ENGINES.throttle[0].setValue(0);
				ENGINES.throttle[1].setValue(0);
				FADEC.reverseEngage[0].setBoolValue(0);
				FADEC.reverseEngage[1].setBoolValue(0);
			}
		}
	} else {
		ENGINES.throttle[0].setValue(0);
		ENGINES.throttle[1].setValue(0);
		FADEC.reverseEngage[0].setBoolValue(0);
		FADEC.reverseEngage[1].setBoolValue(0);
	}
}

var toggleRevThrust = func() {
	if ((pts.Gear.wow[1].getBoolValue() or pts.Gear.wow[2].getBoolValue()) and systems.FADEC.maxDetent.getValue() == 0) {
		if (FADEC.reverseEngage[0].getBoolValue() or FADEC.reverseEngage[1].getBoolValue()) {
			ENGINES.throttle[0].setValue(0);
			ENGINES.throttle[1].setValue(0);
			FADEC.reverseEngage[0].setBoolValue(0);
			FADEC.reverseEngage[1].setBoolValue(0);
		} else {
			FADEC.reverseEngage[0].setBoolValue(1);
			FADEC.reverseEngage[1].setBoolValue(1);
		}
	} else {
		ENGINES.throttle[0].setValue(0);
		ENGINES.throttle[1].setValue(0);
		FADEC.reverseEngage[0].setBoolValue(0);
		FADEC.reverseEngage[1].setBoolValue(0);
	}
}
