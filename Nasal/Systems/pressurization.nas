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

var CPCController = {
	CPCS: [nil, nil],
	activeCPC: nil,
	mode: 0, # 0 = auto, 1 = semi-auto, 2 = manual
	phase: 0, # 0 = GN 1 = TO 2 = CI 3 = AB 4 = CR 5 = DI
	takeoffAltSet: 0,
	takeoffAlt: props.globals.getNode("/systems/pressurization/logic/takeoff-altitude-ft", 1),
	init: func() {
		me.activeCPC = rand() >= 0.5 ? 1 : 0;
		me.CPCS = [CabinPressureController.new("/systems/electrical/bus/dc-ess"),CabinPressureController.new("/systems/electrical/bus/dc-2")];
	},
	resetFail: func() {
		if (me.CPCS[0] != nil and me.CPCS[1] != nil) {
			me.CPCS[0].recover();
			me.CPCS[1].recover();
		}
	},
	switchActive: func() {
		me.activeCPC = !me.activeCPC;
	},
	setMode: func(mode) {
		if (mode >= 0 and mode <= 2) {
			me.mode = mode;
			if (me.mode == 0) {
				me.switchActive();
			}
		}
	},
	loop: func() {
		if (me.CPCS[0] != nil and me.CPCS[1] != nil) {
			me.CPCS[0].update();
			me.CPCS[1].update();
		}
		
		if (me.activeCPC == 0 and me.CPCS[0].failed and me.CPCS[1].failed != 0) {
			me.switchActive();
		} elsif (me.activeCPC == 1 and me.CPCS[1].failed and !me.CPCS[0].failed) {
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
		print("Registering listener for " ~ nodePath);
		signal.listener = setlistener(signal.node, func() { signal.phaseFunc(); }, 0, 0);
	},
	del: func() {
		removelistener(me.listener);
	},
	phaseFunc: func() {
		if (CPCController.phase != me.phaseStart) { return; }
		if (me.node.getValue() == 1) {
			print("Condition true, switching to phase " ~ me.phaseEnd);
			CPCController.phase = me.phaseEnd;
		}
	},
};

setlistener("/gear/gear[1]/wow", func() {
	if (!pts.Gear.wow[1].getBoolValue()) {
		if (!CPCController.takeoffAltSet) {
			CPCController.takeoffAlt.setValue(getprop("/systems/navigation/adr/computation/baro-alt-corrected-1-capt"));
			CPCController.takeoffAltSet = 1;
		}
	}
}, 0, 0);

setlistener("/controls/pressurization/ldg-elev", func() {
	if (PRESS.Switches.ldgElev.getValue() == 0) {
		if (CPCController.mode == 1) {
			CPCController.setMode(0);
		}
	} else {
		if (CPCController.mode == 0) {
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
			phaseSignal.new("/systems/pressurization/logic/descent-to-ground", 5, 0);
			phaseSignal.new("/systems/pressurization/logic/abort-to-climb", 3, 2);
			phaseSignal.new("/systems/pressurization/logic/climb-to-descent", 2, 5);
			listenersRegistered = 1;
		}
	},
	loop: func() {
		CPCController.loop();
	},
};