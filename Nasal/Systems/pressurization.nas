# A3XX Pressurization System
# Copyright (c) 2020 Jonathan Redpath (legoboyvdlp)

var CabinPressureController = {
	new: func(elecNode) {
		var cpc = { parents:[CabinPressureController] };
		cpc.elecSupply = props.globals.getNode(elecNode, 1);
		cpc.condition = 100;
		cpc.failed = 0;
		return cpc;
	},
	
	update: func() {
		if (me.elecSupply.getValue() < 25 or me.condition == 0) {
			me.failed = 1;
		} else {
			me.failed = 0;
		}
	},
	
	setFail: func() {
		me.condition = 0;
	},
	recover: func() {
		me.condition = 100;
	},
};

# ADIRS:
# Sys 1 prio 1 --> 2 --> 3
# Sys 2 prio 2 --> 1 --> 3

var CPCController = {
	CPCS: [nil, nil],
	mode: props.globals.getNode("/systems/pressurization/active-mode", 1), # 0 = auto, 1 = semi-auto, 2 = manual
	phase: props.globals.getNode("/systems/pressurization/active-phase", 1), # 0 = GN 1 = TO 2 = CI 3 = AB 4 = CR 5 = DI
	activeCPC: props.globals.getNode("/systems/pressurization/active-cpc", 1),
	bothCPCOff: props.globals.getNode("/systems/pressurization/both-cpcs-off", 1),
	takeoffAltSet: 0,
	takeoffAlt: props.globals.getNode("/systems/pressurization/logic/takeoff-altitude-ft", 1),
	takeoffPsiSet: 0,
	takeoffPsi: props.globals.getNode("/systems/pressurization/logic/takeoff-psi", 1),
	targetVS: props.globals.getNode("/systems/pressurization/man-target-vs", 1),
	cabinPsi: props.globals.getNode("/systems/pressurization/cabin-pressure-psi", 1),
	cabinPsiMemo: props.globals.getNode("/systems/pressurization/logic/cruise/cabinpsi-memo-cruise", 1),
	init: func() {
		me.activeCPC.setValue(rand() >= 0.5 ? 1 : 0);
		me.CPCS = [CabinPressureController.new("/systems/electrical/bus/dc-ess"),CabinPressureController.new("/systems/electrical/bus/dc-2")];
	},
	resetFail: func() {
		if (me.CPCS[0] != nil and me.CPCS[1] != nil) {
			me.CPCS[0].recover();
			me.CPCS[1].recover();
		}
	},
	switchActive: func() {
		me.activeCPC.setValue(!me.activeCPC.getValue());
	},
	setManVs: func(d) {
		if (me.mode.getValue() != 2) { return; }
		me.targetVS.setValue(me.targetVS.getValue() + -d*50);
	},
	setMode: func(mode) {
		if (mode >= 0 and mode <= 2) {
			me.mode.setValue(mode);
			if (mode == 0) {
				me.switchActive();
			}
		}
	},
	loop: func() {
		if (me.CPCS[0] != nil and me.CPCS[1] != nil) {
			me.CPCS[0].update();
			me.CPCS[1].update();
		}
		
		if (me.CPCS[0].failed and me.CPCS[1].failed) {
			me.bothCPCOff.setValue(1);
		}
		
		if (me.activeCPC.getValue() == 0 and me.CPCS[0].failed and me.CPCS[1].failed != 0) {
			me.switchActive();
		} elsif (me.activeCPC.getValue() == 1 and me.CPCS[1].failed and !me.CPCS[0].failed) {
			me.switchActive();
		}
	}
};

var phaseSignal = {
	new: func(nodePath, phaseStart, phaseEnd) {
		var signal = { parents: [phaseSignal] };
		signal.phaseStart = phaseStart;
		signal.phaseEnd = phaseEnd;
		signal.node = props.globals.getNode(nodePath, 1);
		signal.runningTimer = 0;
		signal.listener = setlistener(signal.node, func() { signal.phaseFunc(); }, 0, 0);
	},
	del: func() {
		removelistener(me.listener);
	},
	checkPhase: func(phase) {
		me.runningTimer = 0;
		if (CPCController.phase.getValue() == phase) {
			return 1;
		}
		return 0;
	},
	phaseFunc: func() {
		if (CPCController.phase.getValue() != me.phaseStart) { return; }
		if (me.node.getValue() == 1) {
			CPCController.phase.setValue(me.phaseEnd);
			if (me.phaseEnd == 0 and me.runningTimer == 0) {
				CPCController.takeoffAltSet = 0;
				CPCController.takeoffAlt.setValue(-9999);
				CPCController.takeoffPsiSet = 0;
				CPCController.takeoffPsi.setValue(-9999);
				me.runningTimer = 1;
				settimer(func() {
					if (me.checkPhase(0) == 1) {
						CPCController.switchActive();
					}
				}, 70);
			}
			if (me.phaseEnd == 4) {
				CPCController.cabinPsiMemo.setValue(CPCController.cabinPsi.getValue());
			}
		}
	},
};

setlistener("/gear/gear[1]/wow", func() {
	if (!pts.Gear.wow[1].getBoolValue()) {
		if (!CPCController.takeoffAltSet) {
			CPCController.takeoffAlt.setValue(getprop("/systems/navigation/adr/computation/baro-alt-corrected-1-capt"));
			CPCController.takeoffAltSet = 1;
		}
		if (!CPCController.takeoffPsiSet) {
			CPCController.takeoffPsi.setValue(getprop("/environment/pressure-inhg") * 0.491154);
			CPCController.takeoffPsiSet = 1;
		}
	}
}, 1, 0);

setlistener("/controls/pressurization/ldg-elev", func() {
	if (PRESS.Switches.ldgElev.getValue() == 0) {
		if (CPCController.mode.getValue() == 1) {
			CPCController.setMode(0);
		}
	} else {
		if (CPCController.mode.getValue() == 0) {
			CPCController.setMode(1);
		}
	}
}, 0, 0);

var listenersRegistered = 0;

var PRESS = {
	Switches: {
		manVsCtl: props.globals.getNode("/controls/pressurization/man-vs-ctl"),
		modeSel: props.globals.getNode("/controls/pressurization/mode-sel"),
		ldgElev: props.globals.getNode("/controls/pressurization/ldg-elev"),
		ditching: props.globals.getNode("/controls/pressurization/ditching"),
	},
	init: func() {
		CPCController.init();
		if (!listenersRegistered) {
			phaseSignal.new("/systems/pressurization/logic/gnd-to-takeoff", 0, 1);
			phaseSignal.new("/systems/pressurization/logic/takeoff-to-climb", 0, 2);
			phaseSignal.new("/systems/pressurization/logic/takeoff-to-climb", 1, 2);
			phaseSignal.new("/systems/pressurization/logic/climb-to-abort", 2, 3);
			phaseSignal.new("/systems/pressurization/logic/abort-to-gnd", 3, 0); 
			phaseSignal.new("/systems/pressurization/logic/takeoff-to-gnd", 1, 0); 
			phaseSignal.new("/systems/pressurization/logic/climb-to-cruise", 2, 4);
			phaseSignal.new("/systems/pressurization/logic/cruise-to-climb", 4, 2);
			phaseSignal.new("/systems/pressurization/logic/cruise-to-descent", 4, 5);
			phaseSignal.new("/systems/pressurization/logic/descent-to-climb", 5, 2);
			phaseSignal.new("/systems/pressurization/logic/descent-to-gnd", 5, 0);
			phaseSignal.new("/systems/pressurization/logic/abort-to-climb", 3, 2);
			phaseSignal.new("/systems/pressurization/logic/climb-to-descent", 2, 5);
			listenersRegistered = 1;
		}
	},
	loop: func() {
		CPCController.loop();
	},
};

var calc_mass_on_init = func() {
	var x = getprop("/environment/pressure-inhg") * 3386.38815789475 * 330;
	var y = 287.058 * getprop("/systems/air-conditioning/temperatures/cabin-overall-temp-kelvin");
	return (x / y);
};

setprop("/systems/pressurization/calculations/cabin-mass-init", calc_mass_on_init());