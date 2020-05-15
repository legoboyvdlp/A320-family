# A3XX Fuel System
# Joshua Davidson (Octal450)

# Copyright (c) 2020 Josh Davidson (Octal450)

var FUEL = {
	offset1: 0,
	offset2: 0,
	timeEngStart: 0,
	cmdCtrOn: props.globals.getNode("systems/fuel/ctr-pump-cmd-on-eng-start"),
	refuelling: props.globals.getNode("systems/fuel/refuel/refuelling"),
	
	Fail: {
	},
	Switches: {
		centerTkMode: props.globals.getNode("controls/fuel/switches/center-mode"),
		crossfeed: props.globals.getNode("controls/fuel/switches/crossfeed"),
		pumpLeft1: props.globals.getNode("controls/fuel/switches/pump-left-1"),
		pumpLeft2: props.globals.getNode("controls/fuel/switches/pump-left-2"),
		pumpCenter1: props.globals.getNode("controls/fuel/switches/pump-center-1"),
		pumpCenter2: props.globals.getNode("controls/fuel/switches/pump-center-2"),
		pumpRight1: props.globals.getNode("controls/fuel/switches/pump-right-1"),
		pumpRight2: props.globals.getNode("controls/fuel/switches/pump-right-2"),
	},
	Pumps: {
		apu: props.globals.getNode("systems/fuel/pumps/apu-operate"),
		allOff: props.globals.getNode("systems/fuel/pumps/all-eng-pump-off"),
	},
	Valves: {
		apu: props.globals.getNode("systems/fuel/valves/apu-lp-valve"),
		crossfeed: props.globals.getNode("systems/fuel/valves/crossfeed-valve"),
		lpValve1: props.globals.getNode("systems/fuel/valves/engine-1-lp-valve"),
		lpValve2: props.globals.getNode("systems/fuel/valves/engine-2-lp-valve"),
		transfer1: props.globals.getNode("systems/fuel/valves/outer-inner-transfer-valve-1"),
		transfer2: props.globals.getNode("systems/fuel/valves/outer-inner-transfer-valve-2"),
		refuelLeft: props.globals.getNode("systems/fuel/refuel/left-valve"),
		refuelCenter: props.globals.getNode("systems/fuel/refuel/center-valve"),
		refuelRight: props.globals.getNode("systems/fuel/refuel/right-valve"),
	},
	Quantity: {
		leftOuter: props.globals.getNode("consumables/fuel/tank[0]/level-lbs"),
		leftOuterPct: props.globals.getNode("consumables/fuel/tank[0]/level-norm"),
		leftInner: props.globals.getNode("consumables/fuel/tank[1]/level-lbs"),
		leftInnerPct: props.globals.getNode("consumables/fuel/tank[1]/level-norm"),
		center: props.globals.getNode("consumables/fuel/tank[2]/level-lbs"),
		centerPct: props.globals.getNode("consumables/fuel/tank[2]/level-norm"),
		rightInner: props.globals.getNode("consumables/fuel/tank[3]/level-lbs"),
		rightInnerPct: props.globals.getNode("consumables/fuel/tank[3]/level-norm"),
		rightOuter: props.globals.getNode("consumables/fuel/tank[4]/level-lbs"),
		rightOuterPct: props.globals.getNode("consumables/fuel/tank[4]/level-norm"),
		usedLeft: props.globals.getNode("systems/fuel/fuel-used-1"),
		usedRight: props.globals.getNode("systems/fuel/fuel-used-2"),
	},
	resetFail: func() {
	
	},
	init: func() {
	
	},
	loop: func() {
		systems.FUEL.Quantity.usedLeft.setValue(pts.Fdm.JSBsim.Propulsion.Engine.fuelUsed[0].getValue() + me.offset1);
		systems.FUEL.Quantity.usedRight.setValue(pts.Fdm.JSBsim.Propulsion.Engine.fuelUsed[1].getValue() + me.offset2);
	},
	setOffset: func() {
		me.offset1 = me.offset1 -(pts.Fdm.JSBsim.Propulsion.Engine.fuelUsed[0].getValue());
		me.offset2 = me.offset2 -(pts.Fdm.JSBsim.Propulsion.Engine.fuelUsed[1].getValue());
	}
};

setlistener("/engines/engine[0]/state", func() {
	if (pts.Engines.Engine.state[0].getValue() == 3) {
		FUEL.timeEngStart = pts.Sim.Time.elapsedSec.getValue();
		FUEL.cmdCtrOn.setValue(1);
		ctrTkTimer.start();
	}
}, 0, 0);

setlistener("/engines/engine[1]/state", func() {
	if (pts.Engines.Engine.state[1].getValue() == 3) {
		FUEL.timeEngStart = pts.Sim.Time.elapsedSec.getValue();
		FUEL.cmdCtrOn.setValue(1);
		ctrTkTimer.start();
	}
}, 0, 0);

var FUELx = {
	init: func() {
		setprop("systems/fuel/gravityfeedL", 0);
		setprop("systems/fuel/gravityfeedR", 0);
		setprop("systems/fuel/gravityfeedL-output", 0);
		setprop("systems/fuel/gravityfeedR-output", 0);
		setprop("controls/fuel/x-feed", 0);
		setprop("controls/fuel/tank0pump1", 0);
		setprop("controls/fuel/tank0pump2", 0);
		setprop("controls/fuel/tank1pump1", 0);
		setprop("controls/fuel/tank1pump2", 0);
		setprop("controls/fuel/tank2pump1", 0);
		setprop("controls/fuel/tank2pump2", 0);
		setprop("controls/fuel/mode", 1);
		setprop("systems/fuel/valves/crossfeed-valve", 0);
		setprop("systems/fuel/tank[0]/feed", 0);
		setprop("systems/fuel/tank[1]/feed", 0);
		setprop("systems/fuel/tank[2]/feed", 0);
		setprop("systems/fuel/only-use-ctr-tank", 0);
		setprop("systems/fuel/tank0pump1-fault", 0);
		setprop("systems/fuel/tank0pump2-fault", 0);
		setprop("systems/fuel/tank1pump1-fault", 0);
		setprop("systems/fuel/tank1pump2-fault", 0);
		setprop("systems/fuel/tank2pump1-fault", 0);
		setprop("systems/fuel/tank2pump2-fault", 0);
		setprop("systems/fuel/mode-fault", 0);
	},
	loop: func() {
		xfeed_sw = getprop("controls/fuel/x-feed");
		tank0pump1_sw = getprop("controls/fuel/tank0pump1");
		tank0pump2_sw = getprop("controls/fuel/tank0pump2");
		tank1pump1_sw = getprop("controls/fuel/tank1pump1");
		tank1pump2_sw = getprop("controls/fuel/tank1pump2");
		tank2pump1_sw = getprop("controls/fuel/tank2pump1");
		tank2pump2_sw = getprop("controls/fuel/tank2pump2");
		mode_sw = getprop("controls/fuel/mode");
		xfeed = getprop("systems/fuel/valves/crossfeed-valve");
		ac1 = getprop("systems/electrical/bus/ac-1");
		ac2 = getprop("systems/electrical/bus/ac-2");
		gravityfeedL = getprop("systems/fuel/gravityfeedL");
		gravityfeedR = getprop("systems/fuel/gravityfeedR");
		gload = getprop("accelerations/pilot-gdamped");
		tank0pump1_fail = getprop("systems/failures/tank0pump1");
		tank0pump2_fail = getprop("systems/failures/tank0pump2");
		tank1pump1_fail = getprop("systems/failures/tank1pump1");
		tank1pump2_fail = getprop("systems/failures/tank1pump2");
		tank2pump1_fail = getprop("systems/failures/tank2pump1");
		tank2pump2_fail = getprop("systems/failures/tank2pump2");
		
		if (gload >= 0.7 and gravityfeedL) {
			setprop("systems/fuel/gravityfeedL-output", 1);
		} else {
			setprop("systems/fuel/gravityfeedL-output", 0);
		}
		
		if (gload >= 0.7 and gravityfeedR) {
			setprop("systems/fuel/gravityfeedR-output", 1);
		} else {
			setprop("systems/fuel/gravityfeedR-output", 0);
		}
		
		gravityfeedL_output = getprop("systems/fuel/gravityfeedL-output");
		gravityfeedR_output = getprop("systems/fuel/gravityfeedR-output");
		
		if ((ac1 >= 110 or ac2 >= 110) and tank0pump1_sw and !tank0pump1_fail) {
			setprop("systems/fuel/tank[0]/feed", 1);
		} else if ((ac1 >= 110 or ac2 >= 110) and tank0pump2_sw and !tank0pump2_fail) {
			setprop("systems/fuel/tank[0]/feed", 1);
		} else if (gravityfeedL_output) {
			setprop("systems/fuel/tank[0]/feed", 1);
		} else {
			setprop("systems/fuel/tank[0]/feed", 0);
		}
		
		if ((ac1 >= 110 or ac2 >= 110) and tank1pump1_sw and !tank1pump1_fail) {
			setprop("systems/fuel/tank[1]/feed", 1);
		} else if ((ac1 >= 110 or ac2 >= 110) and tank1pump2_sw and !tank1pump2_fail) {
			setprop("systems/fuel/tank[1]/feed", 1);
		} else {
			setprop("systems/fuel/tank[1]/feed", 0);
		}
		
		if ((ac1 >= 110 or ac2 >= 110) and tank2pump1_sw and !tank2pump1_fail) {
			setprop("systems/fuel/tank[2]/feed", 1);
		} else if ((ac1 >= 110 or ac2 >= 110) and tank2pump2_sw and !tank2pump2_fail) {
			setprop("systems/fuel/tank[2]/feed", 1);
		} else if (gravityfeedR_output) {
			setprop("systems/fuel/tank[2]/feed", 1);
		} else {
			setprop("systems/fuel/tank[2]/feed", 0);
		}
		
		if ((ac1 >= 110 or ac2 >= 110) and xfeed_sw) {
			setprop("systems/fuel/valves/crossfeed-valve", 1);
		} else {
			setprop("systems/fuel/valves/crossfeed-valve", 0);
		}
		
		tank0 = getprop("systems/fuel/tank[0]/feed");
		tank1 = getprop("systems/fuel/tank[1]/feed");
		tank2 = getprop("systems/fuel/tank[2]/feed");
		
		if ((ac1 >= 110 or ac2 >= 110) and (tank0pump1_sw or tank0pump2_sw)) {
			setprop("systems/fuel/gravityfeedL", 0);
		} else {
			setprop("systems/fuel/gravityfeedL", 1);
		}
		
		if ((ac1 >= 110 or ac2 >= 110) and (tank2pump1_sw or tank2pump2_sw)) {
			setprop("systems/fuel/gravityfeedR", 0);
		} else {
			setprop("systems/fuel/gravityfeedR", 1);
		}
		
		gravityfeedL = getprop("systems/fuel/gravityfeedL");
		gravityfeedR = getprop("systems/fuel/gravityfeedR");
		
		if ((getprop("fdm/jsbsim/propulsion/tank[1]/contents-lbs") >= 50) and (tank1pump1_sw or tank1pump2_sw) and !gravityfeedL and !gravityfeedR) {
			setprop("systems/fuel/only-use-ctr-tank", 1);
		} else {
			setprop("systems/fuel/only-use-ctr-tank", 0);
		}
		
		# Fault lights
		if (tank0pump1_sw and tank0pump1_fail) {
			setprop("systems/fuel/tank0pump1-fault", 1);
		} else {
			setprop("systems/fuel/tank0pump1-fault", 0);
		}
		
		if (tank0pump2_sw and tank0pump2_fail) {
			setprop("systems/fuel/tank0pump2-fault", 1);
		} else {
			setprop("systems/fuel/tank0pump2-fault", 0);
		}
		
		if (tank1pump1_sw and tank1pump1_fail) {
			setprop("systems/fuel/tank1pump1-fault", 1);
		} else {
			setprop("systems/fuel/tank1pump1-fault", 0);
		}
		
		if (tank1pump2_sw and tank1pump2_fail) {
			setprop("systems/fuel/tank1pump2-fault", 1);
		} else {
			setprop("systems/fuel/tank1pump2-fault", 0);
		}
		
		if (tank2pump1_sw and tank2pump1_fail) {
			setprop("systems/fuel/tank2pump1-fault", 1);
		} else {
			setprop("systems/fuel/tank2pump1-fault", 0);
		}
		
		if (tank2pump2_sw and tank2pump2_fail) {
			setprop("systems/fuel/tank2pump2-fault", 1);
		} else {
			setprop("systems/fuel/tank2pump2-fault", 0);
		}
	},
};

var ctrTkTimer = maketimer(0.5, func() {
	if (pts.Sim.Time.elapsedSec.getValue() > (FUEL.timeEngStart + 120)) {
		FUEL.cmdCtrOn.setValue(0);
		ctrTkTimer.stop()
	}
});