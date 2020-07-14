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
		me.condition = 1;
	},
};

var CPCController = {
	CPCS: [nil, nil],
	activeCPC: nil,
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
};

var PRESS = {
	Switches: {
		manVsCtl: props.globals.getNode("/controls/pressurization/man-vs-ctl"),
		modeSel: props.globals.getNode("/controls/pressurization/mode-sel"),
		ldgElev: props.globals.getNode("/controls/pressurization/ldg-elev"),
		ditching: props.globals.getNode("/controls/pressurization/ditching"),
	},
	init: func() {
		CPCController.init();
	},
	loop: func() {
		if (CPCController.CPCS[0] != nil and CPCController.CPCS[1] != nil) {
			CPCController.CPCS[0].update();
			CPCController.CPCS[1].update();
		}
	},
};