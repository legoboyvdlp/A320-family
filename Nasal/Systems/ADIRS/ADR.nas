# A3XX ADIRS System
# Jonathan Redpath (legoboyvdlp)

# Copyright (c) 2019 Jonathan Redpath (legoboyvdlp)

var _NUMADIRU = 3;

var _selfTestTime = nil;

var ADIRSnodesND = [props.globals.getNode("/instrumentation/efis[0]/nd/ir-1", 1),props.globals.getNode("/instrumentation/efis[1]/nd/ir-2", 1),props.globals.getNode("/instrumentation/efis[0]/nd/ir-3", 1)];

var ADIRU = {
	# methods
    new: func(n) {
		var adiru = { parents:[ADIRU] };
		adiru.num = n;
		adiru._alignTime =  0;
		adiru._pfdTime =  0;
		adiru._voltageMain =  0;
		adiru._voltageBackup =  0;
		adiru._voltageLimitedTime =  0;
		adiru._noPowerTime =  0;
		adiru._timeVar =  0;
		adiru._roll =  0;
		adiru._pitch =  0;
		adiru._gs =  0;
		
		adiru.aligned =  0;
		adiru.operating =  0; # ir operating - used for PFD + fbw failure
		adiru.inAlign =  0;
		adiru.outputOn =  1; # 0 = disc; 1 = normal
		adiru.mode =  0; # 0 = off; 1 = nav; 2 = att
		adiru.energised =  0; # 0 = off; 1 = on
		adiru.operative =  0; # 0 = off;
		adiru.alignTimer =  nil;
		adiru.input =  [];
		adiru.output =  [];
		adiru.alignTimer = maketimer(0.1, adiru, me.alignLoop);
		
		return adiru;
    },
	setOperative: func(newOperative) { 
		if (newOperative != me.operative) {
			me.operative = newOperative;
			if (newOperative) {
				me.selfTest();
			}
		}
	},
	# Power and state
	updateEnergised: func(mode) {
		me.energised = mode != 0 ? 1 : 0;
	},
	updatePower: func(elec) {
		me._voltageMain = elec.getValue() or 0;
		return me._voltageMain;
	},
	updateBackupPower: func(elec, isLimited) {
		me._voltageBackup = elec.getValue() or 0;
		me._voltageLimitedTime = isLimited;
		return me._voltageBackup;
	},
	# BITE
	selfTest: func() {
		ADIRS._selfTest = 1;
		_selfTestTime = pts.Sim.Time.elapsedSec.getValue();
		
		ADIRS.Lights.adrOff[me.num].setValue(1);
		ADIRS.Lights.adrFault[me.num].setValue(1);
		settimer(func() {
			ADIRS.Lights.adrOff[me.num].setValue(0);
			ADIRS.Lights.adrFault[me.num].setValue(0);
		}, 0.1);
		settimer(func() {
			ADIRS.Lights.adrOff[me.num].setValue(1);
			ADIRS.Lights.adrFault[me.num].setValue(1);
			ADIRS.Lights.irFault[me.num].setValue(1);
			ADIRS.Lights.irOff[me.num].setValue(1);
		}, 1.0);
		settimer(func() {
			ADIRS.Lights.adrOff[me.num].setValue(!ADIRS.Switches.adrSw[me.num].getValue());
			ADIRS.Lights.adrFault[me.num].setValue(0);
			ADIRS.Lights.irFault[me.num].setValue(0);
			ADIRS.Lights.irOff[me.num].setValue(0);
		}, 1.1);
		
		ADIRS.selfTest();
	},
	# Alignment
	align: func(time) {
		ADIRS.Lights.irFault[me.num].setBoolValue(0);
		if (!ADIRS.skip.getValue()) {
			if (time > 0 and me.aligned == 0 and me.inAlign == 0 and me.operative == 1) {
				me._alignTime = pts.Sim.Time.elapsedSec.getValue() + time;
				me._pfdTime = pts.Sim.Time.elapsedSec.getValue() + 20 + (rand() * 5);
				me.inAlign = 1;
				if (me.alignTimer != nil) {
					me.alignTimer.start();
				}
			}
		} else {
			if (me.aligned == 0 and me.inAlign == 0 and me.operative == 1) {
				me._alignTime = pts.Sim.Time.elapsedSec.getValue() + 5;
				me._pfdTime = pts.Sim.Time.elapsedSec.getValue() + 1;
				me.inAlign = 1;
				if (me.alignTimer != nil) {
					me.alignTimer.start();
				}
			}
		}
	},
	stopAlignNoAlign: func() {
		print("Stopping alignment or setting unaligned state");
		me.inAlign = 0;
		me.aligned = 0;
		ADIRSnodesND[me.num].setValue(0);
		ADIRS.Operating.aligned[me.num].setValue(0);
		me.operating = 0;
		if (me.alignTimer != nil) {
			me.alignTimer.stop();
		}
		foreach (var predicate; keys(canvas_nd.ND_1.NDCpt.predicates)) {
			call(canvas_nd.ND_1.NDCpt.predicates[predicate]);
		}
		foreach (var predicate; keys(canvas_nd.ND_2.NDFo.predicates)) {
			call(canvas_nd.ND_2.NDFo.predicates[predicate]);
		}
	},
	irOperating: func() {
		me.operating = 1;
	},
	stopAlignAligned: func() {
		me.inAlign = 0;
		me.aligned = 1;
		ADIRSnodesND[me.num].setValue(1);
		ADIRS.Operating.aligned[me.num].setValue(1);
		if (me.alignTimer != nil) {
			me.alignTimer.stop();
		}
		foreach (var predicate; keys(canvas_nd.ND_1.NDCpt.predicates)) {
			call(canvas_nd.ND_1.NDCpt.predicates[predicate]);
		}
		foreach (var predicate; keys(canvas_nd.ND_2.NDFo.predicates)) {
			call(canvas_nd.ND_2.NDFo.predicates[predicate]);
		}
	},
	alignLoop: func() {
		me._roll = pts.Orientation.roll.getValue();
		me._pitch = pts.Orientation.pitch.getValue();
		me._gs = pts.Velocities.groundspeed.getValue();
		
		# todo use IR values
		if (me._gs > 5 or abs(me._pitch) > 5 or abs(me._roll) > 10) {
			me.stopAlignNoAlign();
			print("Excessive motion, restarting");
			me.update(); # update operative
			me.align(calcAlignTime(pts.Position.latitude.getValue()));
		} elsif (me.operative == 0) {
			me.stopAlignNoAlign();
		} elsif (pts.Sim.Time.elapsedSec.getValue() >= me._alignTime) {
			me.stopAlignAligned();
		}
		
		if (!me.operating and pts.Sim.Time.elapsedSec.getValue() >= me._pfdTime) {
			me.irOperating();
		}
	},
	instAlign: func() {
		me.stopAlignAligned();
		me.irOperating();
	},
	# Update loop
	update: func() {
		me._timeVar = pts.Sim.Time.elapsedSec.getValue();
		if (me.energised and !me._voltageMain and me._voltageLimitedTime and me._noPowerTime == 0) {
			me._noPowerTime = me._timeVar;
		}
		
		if (me.energised and me.mode) {
			if (me._voltageMain) {
				me._noPowerTime = 0;
				me.setOperative(1);
				if (!ADIRS._selfTest) {
					ADIRS.Lights.onBat.setBoolValue(0);
				}
			} elsif (((me._timeVar < me._noPowerTime + 300 and me._voltageLimitedTime) or !me._voltageLimitedTime) and me._voltageBackup) {
				me.setOperative(1);
				if (!ADIRS._selfTest) {
					ADIRS.Lights.onBat.setBoolValue(1);
				}
			} else {
				me._noPowerTime = 0;
				me.setOperative(0);
				if (!ADIRS._selfTest) {
					ADIRS.Lights.onBat.setBoolValue(0);
				}
			}
		} else {
			me._noPowerTime = 0;
			me.setOperative(0);
			if (!ADIRS._selfTest) {
				ADIRS.Lights.onBat.setBoolValue(0);
			}
		}
	},
};

var ADIRSControlPanel = {
	adrSw: func(n) { 
		if (n < 0 or n > _NUMADIRU) { return; }
		ADIRS._adrSwitchState = ADIRS.Switches.adrSw[n].getValue();
		ADIRS.Switches.adrSw[n].setValue(!ADIRS._adrSwitchState);
		if (ADIRS.ADIRunits[n] != nil) { 
			ADIRS.ADIRunits[n].outputOn = !ADIRS._adrSwitchState;
		}
		ADIRS.Lights.adrOff[n].setValue(ADIRS._adrSwitchState);
	},
	irSw: func(n) { 
		if (n < 0 or n > _NUMADIRU) { return; }
		ADIRS._irSwitchState = ADIRS.Switches.irSw[n].getValue();
		ADIRS.Switches.irSw[n].setValue(!ADIRS._irSwitchState);
		if (ADIRS.IRunits[n] != nil) { 
			ADIRS.IRunits[n].outputOn = !ADIRS._irSwitchState;
		}
		ADIRS.Lights.irOff[n].setValue(ADIRS._adrSwitchState);
	},
	irModeSw: func(n, mode) {
		if (n < 0 or n > _NUMADIRU) { return; }
		if (mode < 0 or mode > 2) { return; }
		me._irModeSwitchState = ADIRS.Switches.irModeSw[n].getValue();
		if (ADIRS.ADIRunits[n] != nil) { 
			ADIRS.ADIRunits[n].mode = mode;
			ADIRS.ADIRunits[n].updateEnergised(mode);
			ADIRS.Switches.irModeSw[n].setValue(mode);
			if (mode == 0) {
				ADIRS.Lights.irFault[n].setBoolValue(0);
				ADIRS.ADIRunits[n].stopAlignNoAlign();
			} elsif (ADIRS.ADIRunits[n].aligned == 0) {
				ADIRS.ADIRunits[n].update(); # update early so operative is set properly
				ADIRS.ADIRunits[n].align(calcAlignTime(pts.Position.latitude.getValue())); # when you set NAV, it first acquires GPS position then acquires GPS. You then use IRS INIT > to set PPOS to align if you wish
			}
		}
	}
};

var ADIRS = {
	# local vars
	_adrSwitchState: 0,
	_irSwitchState: 0,
	_irModeSwitchState: 0,
	_hasPower: 0,
	_cacheOperative: [0, 0, 0],
	_cacheOutputOn: [1, 1, 1],
	_flapPos: nil,
	_slatPos: nil,
	_selfTest: 0,
	_init: 0,
	
	# ADIRS Units
	ADIRunits: [nil, nil, nil],
	
	# Electrical
	mainSupply: [systems.ELEC.Bus.acEss, systems.ELEC.Bus.ac2, systems.ELEC.Bus.ac1],
	backupSupply: [[systems.ELEC.Source.Bat2.volt, 0], [systems.ELEC.Source.Bat2.volt, 1], [systems.ELEC.Source.Bat1.volt, 1]], 
	# ADIRS power directly from a separate bus connected to battery (no c.b. unlike main hot bus), as they are so critical
	
	# PTS
	Lights: {
		adrFault: [props.globals.getNode("/controls/navigation/adirscp/lights/adr-1-fault"), props.globals.getNode("/controls/navigation/adirscp/lights/adr-2-fault"), props.globals.getNode("/controls/navigation/adirscp/lights/adr-3-fault")],
		adrOff: [props.globals.getNode("/controls/navigation/adirscp/lights/adr-1-off"), props.globals.getNode("/controls/navigation/adirscp/lights/adr-2-off"), props.globals.getNode("/controls/navigation/adirscp/lights/adr-3-off")],
		irFault: [props.globals.getNode("/controls/navigation/adirscp/lights/ir-1-fault"), props.globals.getNode("/controls/navigation/adirscp/lights/ir-2-fault"), props.globals.getNode("/controls/navigation/adirscp/lights/ir-3-fault")],
		irOff: [props.globals.getNode("/controls/navigation/adirscp/lights/ir-1-off"), props.globals.getNode("/controls/navigation/adirscp/lights/ir-2-off"), props.globals.getNode("/controls/navigation/adirscp/lights/ir-3-off")],
		onBat: props.globals.getNode("/controls/navigation/adirscp/lights/on-bat"),
	},
	Switches: {
		adrSw: [props.globals.getNode("/controls/navigation/adirscp/switches/adr-1"), props.globals.getNode("/controls/navigation/adirscp/switches/adr-2"), props.globals.getNode("/controls/navigation/adirscp/switches/adr-3")],
		irModeSw: [props.globals.getNode("/controls/navigation/adirscp/switches/ir-1-mode"), props.globals.getNode("/controls/navigation/adirscp/switches/ir-2-mode"), props.globals.getNode("/controls/navigation/adirscp/switches/ir-3-mode")],
		irSw: [props.globals.getNode("/controls/navigation/adirscp/switches/ir-1"), props.globals.getNode("/controls/navigation/adirscp/switches/ir-2"), props.globals.getNode("/controls/navigation/adirscp/switches/ir-3")],
	},
	Operating: {
		adr: [props.globals.getNode("/systems/navigation/adr/operating-1"), props.globals.getNode("/systems/navigation/adr/operating-2"), props.globals.getNode("/systems/navigation/adr/operating-3")],
		aligned: [props.globals.getNode("/systems/navigation/aligned-1"), props.globals.getNode("/systems/navigation/aligned-2"), props.globals.getNode("/systems/navigation/aligned-3")],
	},
	
	# Nodes
	overspeedVFE: props.globals.initNode("/systems/navigation/adr/computation/overspeed-vfe-spd", 0, "INT"),
	skip: props.globals.initNode("/controls/adirs/skip", 0, "BOOL"),
	mcduControl: props.globals.initNode("/controls/adirs/mcducbtn", 0, "BOOL"),
	
	# System
	init: func() {
		if (!me._init) {
			for (i = 0; i < _NUMADIRU; i = i + 1) {
				me.ADIRunits[i] = ADIRU.new(i);
				me._init = 1;
			}
		}
	}, 
	update_items: [
		props.UpdateManager.FromPropertyHashList(["/fdm/jsbsim/fcs/flap-pos-deg","/fdm/jsbsim/fcs/slat-pos-deg"], 0.1, func(notification)
			{
				me._flapPos = pts.Fdm.JSBsim.Fcs.flapDeg.getValue();
				me._slatPos = pts.Fdm.JSBsim.Fcs.slatDeg.getValue();
				
				if (me._flapPos >= 23 and me._slatPos >= 25) {
					ADIRS.overspeedVFE.setValue(181);
				} elsif (me._flapPos >= 18) {
					ADIRS.overspeedVFE.setValue(189);
				} elsif (me._flapPos >= 13 or me._slatPos > 20) {
					ADIRS.overspeedVFE.setValue(204);
				} elsif (me._slatPos <= 20 and me._flapPos > 2) {
					ADIRS.overspeedVFE.setValue(219);
				} elsif (me._slatPos >= 2 and me._slatPos <= 20) {
					ADIRS.overspeedVFE.setValue(234);
				} else {
					ADIRS.overspeedVFE.setValue(1024);
				}
			}
		),
	],
	loop: func() {
		if (me._init) {
			for (i = 0; i < _NUMADIRU; i = i + 1) {
				# update ADR units power
				me._hasPower = me.ADIRunits[i].updatePower(me.mainSupply[i]);
				if (me._hasPower == 0) {
					 me.ADIRunits[i].updateBackupPower(me.backupSupply[i][0],me.backupSupply[i][1])
				}
				
				# Update ADR units
				me.ADIRunits[i].update();
				
				if (me.ADIRunits[i].operative != me._cacheOperative[i] or me.ADIRunits[i].outputOn != me._cacheOutputOn[i]) {
					me._cacheOperative[i] = me.ADIRunits[i].operative;
					me._cacheOutputOn[i] = me.ADIRunits[i].outputOn;
					if (me.ADIRunits[i].outputOn) {
						me.Operating.adr[i].setValue(me.ADIRunits[i].operative);
					} else {
						me.Operating.adr[i].setValue(0);
					}
				}
			}
			
			# Update VFE
			notification = nil;
			foreach (var update_item; me.update_items) {
				update_item.update(notification);
			}
		}
	},
	selfTest: func() {
		ADIRS.Lights.onBat.setBoolValue(1);
		selfTestLoop.start();
	},
	
};

var calcAlignTime = func(latitude) {
	return ((0.002 * (latitude * latitude)) + 5) * 60;
};

setlistener("/systems/fmgc/cas-compare/cas-reject-all", func() {
	if (pts.FMGC.CasCompare.casRejectAll.getBoolValue()) {
		fcu.athrOff("hard");
	}
}, 0, 0);

setlistener("/controls/adirs/skip", func() {
	if (ADIRS.skip.getBoolValue()) {
		for (i = 0; i < 3; i = i + 1) {
			if (ADIRS.ADIRunits[i].inAlign == 1) {
				ADIRS.ADIRunits[i].stopAlignAligned();
			}
		}
	}
}, 0, 0);

selfTestLoop = maketimer(0.2, func() {
	if (pts.Sim.Time.elapsedSec.getValue() > _selfTestTime + 5) {
		ADIRS.Lights.onBat.setBoolValue(0);
		selfTestLoop.stop();
		ADIRS._selfTest = 0;
	}
});