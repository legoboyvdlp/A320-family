# A3XX Fuel System
# Joshua Davidson (Octal450)

# Copyright (c) 2020 Josh Davidson (Octal450)

var FUEL = {
	offset1: 0,
	offset2: 0,
	timeEngStart: 0,
	cmdCtrOn: props.globals.getNode("/systems/fuel/ctr-pump-cmd-on-eng-start"),
	refuelling: props.globals.getNode("/systems/fuel/refuel/refuelling"),
	
	Fail: {
		pumpLeft1: props.globals.getNode("/systems/failures/fuel/left-tank-pump-1"),
		pumpLeft2: props.globals.getNode("/systems/failures/fuel/left-tank-pump-2"),
		pumpCenter1: props.globals.getNode("/systems/failures/fuel/center-tank-pump-1"),
		pumpCenter2: props.globals.getNode("/systems/failures/fuel/center-tank-pump-2"),
		pumpRight1: props.globals.getNode("/systems/failures/fuel/right-tank-pump-1"),
		pumpRight2: props.globals.getNode("/systems/failures/fuel/right-tank-pump-2"),
	},
	Switches: {
		centerTkMode: props.globals.getNode("/controls/fuel/switches/center-mode"),
		crossfeed: props.globals.getNode("/controls/fuel/switches/crossfeed"),
		pumpLeft1: props.globals.getNode("/controls/fuel/switches/pump-left-1"),
		pumpLeft2: props.globals.getNode("/controls/fuel/switches/pump-left-2"),
		pumpCenter1: props.globals.getNode("/controls/fuel/switches/pump-center-1"),
		pumpCenter2: props.globals.getNode("/controls/fuel/switches/pump-center-2"),
		pumpRight1: props.globals.getNode("/controls/fuel/switches/pump-right-1"),
		pumpRight2: props.globals.getNode("/controls/fuel/switches/pump-right-2"),
	},
	Pumps: {
		apu: props.globals.getNode("/systems/fuel/pumps/apu-operate"),
		allOff: props.globals.getNode("/systems/fuel/pumps/all-eng-pump-off"),
	},
	Valves: {
		apu: props.globals.getNode("/systems/fuel/valves/apu-lp-valve"),
		crossfeed: props.globals.getNode("/systems/fuel/valves/crossfeed-valve"),
		lpValve1: props.globals.getNode("/systems/fuel/valves/engine-1-lp-valve"),
		lpValve2: props.globals.getNode("/systems/fuel/valves/engine-2-lp-valve"),
		transfer1: props.globals.getNode("/systems/fuel/valves/outer-inner-transfer-valve-1"),
		transfer2: props.globals.getNode("/systems/fuel/valves/outer-inner-transfer-valve-2"),
		refuelLeft: props.globals.getNode("/systems/fuel/refuel/left-valve"),
		refuelCenter: props.globals.getNode("/systems/fuel/refuel/center-valve"),
		refuelRight: props.globals.getNode("/systems/fuel/refuel/right-valve"),
	},
	Quantity: {
		leftOuter: props.globals.getNode("/consumables/fuel/tank[0]/level-lbs"),
		leftOuterPct: props.globals.getNode("/consumables/fuel/tank[0]/level-norm"),
		leftInner: props.globals.getNode("/consumables/fuel/tank[1]/level-lbs"),
		leftInnerPct: props.globals.getNode("/consumables/fuel/tank[1]/level-norm"),
		center: props.globals.getNode("/consumables/fuel/tank[2]/level-lbs"),
		centerPct: props.globals.getNode("/consumables/fuel/tank[2]/level-norm"),
		rightInner: props.globals.getNode("/consumables/fuel/tank[3]/level-lbs"),
		rightInnerPct: props.globals.getNode("/consumables/fuel/tank[3]/level-norm"),
		rightOuter: props.globals.getNode("/consumables/fuel/tank[4]/level-lbs"),
		rightOuterPct: props.globals.getNode("/consumables/fuel/tank[4]/level-norm"),
		offsetLeft: props.globals.getNode("/systems/fuel/offset-left"),
		offsetRight: props.globals.getNode("/systems/fuel/offset-right"),
	},
	resetFail: func() {
		me.Fail.pumpLeft1.setValue(0);
		me.Fail.pumpLeft2.setValue(0);
		me.Fail.pumpCenter1.setValue(0);
		me.Fail.pumpCenter1.setValue(0);
		me.Fail.pumpRight1.setValue(0);
		me.Fail.pumpRight2.setValue(0);
	},
	init: func() {
		me.resetFail();
	},
	setOffsetLeft: func() {
		me.Quantity.offsetLeft.setValue(me.Quantity.offsetLeft.getValue() - pts.Fdm.JSBsim.Propulsion.Engine.fuelUsed[0].getValue());
	},
	setOffsetRight: func() {
		me.Quantity.offsetRight.setValue(me.Quantity.offsetRight.getValue() - pts.Fdm.JSBsim.Propulsion.Engine.fuelUsed[1].getValue());
	}
};

setlistener("/engines/engine[0]/state", func() {
	if (pts.Engines.Engine.state[0].getValue() == 3) {
		FUEL.timeEngStart = pts.Sim.Time.elapsedSec.getValue();
		FUEL.cmdCtrOn.setValue(1);
		ctrTkTimer.start();
	} elsif (pts.Engines.Engine.state[0].getValue() == 2) {
		FUEL.setOffsetLeft();
	}
}, 0, 0);

setlistener("/engines/engine[1]/state", func() {
	if (pts.Engines.Engine.state[1].getValue() == 3) {
		FUEL.timeEngStart = pts.Sim.Time.elapsedSec.getValue();
		FUEL.cmdCtrOn.setValue(1);
		ctrTkTimer.start();
	} elsif (pts.Engines.Engine.state[1].getValue() == 2) {
		FUEL.setOffsetRight();
	}
}, 0, 0);

var ctrTkTimer = maketimer(0.5, func() {
	if (pts.Sim.Time.elapsedSec.getValue() > (FUEL.timeEngStart + 120)) {
		FUEL.cmdCtrOn.setValue(0);
		ctrTkTimer.stop()
	}
});