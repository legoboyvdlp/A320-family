# A3XX Display System
# Jonathan Redpath (legoboyvdlp)

# Copyright (c) 2019 Jonathan Redpath (legoboyvdlp)

var DMC = {
	_set: 0,
	_setNil: 0,
	
	activeADIRS: -9,
	
	airspeeds: [props.globals.getNode("/systems/navigation/adr/output/cas-1", 1), props.globals.getNode("/systems/navigation/adr/output/cas-2", 1), props.globals.getNode("/systems/navigation/adr/output/cas-3", 1)],
	machs: [props.globals.getNode("/systems/navigation/adr/output/mach-1", 1), props.globals.getNode("/systems/navigation/adr/output/mach-2", 1), props.globals.getNode("/systems/navigation/adr/output/mach-3", 1)],
	
	outputs: [nil, nil, nil], # airspeed, altitude, mach
	
	new: func(num) {
		var d = { parents:[DMC] };
		d.activeADIRS = num;
		d.outputs = [nil, nil, nil];
		return d;
	},
	changeActiveADIRS: func(newADIRS) {
		me.activeADIRS = newADIRS;
		me._set = 0;
	},
	setOutputs: func(ADIRS) {
		me.outputs[0] = me.airspeeds[ADIRS];
		me.outputs[2] = me.machs[ADIRS];
	},
	setOutputsNil: func() {
		me.outputs[0] = nil;
		me.outputs[1] = nil;
		me.outputs[2] = nil;
	},
	update: func() {
		if (systems.ADIRSnew.ADIRunits[me.activeADIRS].operative and systems.ADIRSnew.ADIRunits[me.activeADIRS].outputOn) {
			if (me._set != 1) {
				me._setNil = 0;
				me.setOutputs(me.activeADIRS);
				me._setADIRS = me.activeADIRS;
				me._set = 1;
			}
		} else {
			if (me._setNil != 1) {
				me._set = 0;
				me.setOutputsNil();
				me._setNil = 1;
			}
		}
	},
};

var DMController = {
	_init: 0,
	i: nil, # to make sure scope remains local use me.i
	DMCs: [nil, nil, nil],
	
	init: func() {
		if (!me._init) {
			me.DMCs = [DMC.new(0), DMC.new(1), DMC.new(2)];
			me._init = 1;
		}
	},
	loop: func() {
		for (me.i = 0; me.i < 3; me.i = me.i + 1) {
			me.DMCs[me.i].update();
		}
	},
};