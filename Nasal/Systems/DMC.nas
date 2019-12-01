# A3XX Display System
# Jonathan Redpath (legoboyvdlp)

# Copyright (c) 2019 Jonathan Redpath (legoboyvdlp)

var DMC = {
	_set: 0,
	_setNil: 0,
	
	activeADIRS: -9,
	
	airspeeds: [props.globals.getNode("/systems/navigation/adr/output/cas-1", 1), props.globals.getNode("/systems/navigation/adr/output/cas-2", 1), props.globals.getNode("/systems/navigation/adr/output/cas-3", 1)],
	altitudes: [props.globals.getNode("/systems/navigation/adr/output/baro-alt-corrected-1-capt", 1), props.globals.getNode("/systems/navigation/adr/output/baro-alt-corrected-2-capt", 1), props.globals.getNode("/systems/navigation/adr/output/baro-alt-corrected-3-capt", 1)],
	machs: [props.globals.getNode("/systems/navigation/adr/output/mach-1", 1), props.globals.getNode("/systems/navigation/adr/output/mach-2", 1), props.globals.getNode("/systems/navigation/adr/output/mach-3", 1)],
	altitudesPfd: [props.globals.getNode("/instrumentation/altimeter[0]/indicated-altitude-ft-pfd", 1), props.globals.getNode("/instrumentation/altimeter[1]/indicated-altitude-ft-pfd", 1), props.globals.getNode("/instrumentation/altimeter[2]/indicated-altitude-ft-pfd", 1)],
	sats: [props.globals.getNode("/systems/navigation/adr/output/sat-1", 1), props.globals.getNode("/systems/navigation/adr/output/sat-2", 1), props.globals.getNode("/systems/navigation/adr/output/sat-3", 1)],
	tats: [props.globals.getNode("/systems/navigation/adr/output/tat-1", 1), props.globals.getNode("/systems/navigation/adr/output/tat-2", 1), props.globals.getNode("/systems/navigation/adr/output/tat-3", 1)],
	outputs: [nil, nil, nil, nil, nil, nil], # airspeed, altitude, mach, pfd altitude, sat, tat
	
	new: func(num) {
		var d = { parents:[DMC] };
		d.activeADIRS = num;
		d.outputs = [nil, nil, nil, nil, nil, nil];
		return d;
	},
	changeActiveADIRS: func(newADIRS) {
		me.activeADIRS = newADIRS;
		me._set = 0;
	},
	setOutputs: func(ADIRS) {
		me.outputs[0] = me.airspeeds[ADIRS];
		me.outputs[1] = me.altitudes[ADIRS];
		me.outputs[2] = me.machs[ADIRS];
		me.outputs[3] = me.altitudesPfd[ADIRS];
		me.outputs[4] = me.sats[ADIRS];
		me.outputs[5] = me.tats[ADIRS];
	},
	setOutputsNil: func() {
		me.outputs[0] = nil;
		me.outputs[1] = nil;
		me.outputs[2] = nil;
		me.outputs[3] = nil;
		me.outputs[4] = nil;
		me.outputs[5] = nil;
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
			
			# update DMC2 to correct properties for first officer PFD
			me.DMCs[1].altitudes = [props.globals.getNode("/systems/navigation/adr/output/baro-alt-corrected-1-fo", 1), props.globals.getNode("/systems/navigation/adr/output/baro-alt-corrected-2-fo", 1), props.globals.getNode("/systems/navigation/adr/output/baro-alt-corrected-3-fo", 1)];
			me.DMCs[1].altitudesPfd = [props.globals.getNode("/instrumentation/altimeter[3]/indicated-altitude-ft-pfd", 1), props.globals.getNode("/instrumentation/altimeter[4]/indicated-altitude-ft-pfd", 1), props.globals.getNode("/instrumentation/altimeter[5]/indicated-altitude-ft-pfd", 1)];
	 
			me._init = 1;
		}
	},
	loop: func() {
		for (me.i = 0; me.i < 3; me.i = me.i + 1) {
			me.DMCs[me.i].update();
		}
	},
};