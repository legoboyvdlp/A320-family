# A3XX ADIRS System
# Jonathan Redpath (legoboyvdlp)

# Copyright (c) 2019 Jonathan Redpath (legoboyvdlp)

var _NUMADIRU = 3;

var _selfTestTime = nil;

var ADIRU = {
	# local vars
	_alignTime: 0,
	_voltageMain: 0,
	_voltageBackup: 0,
	_voltageLimitedTime: 0,
	_noPowerTime: 0,
	_timeVar: 0,
	_roll: 0,
	_pitch: 0,
	_gs: 0,
	
	num: 0,
	aligned: 0,
	inAlign: 0,
	outputOn: 0, # 0 = disc, 1 = normal
	mode: 0, # 0 = off, 1 = nav, 2 = att
	energised: 0, # 0 = off, 1 = on
	operative: 0, # 0 = off,
	alignTimer: nil,
	input: [],
	output: [],
	
	# methods
    new: func(n) {
		var adiru = { parents:[ADIRU] };
		adiru.num = n;
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
		ADIRSnew._selfTest = 1;
		_selfTestTime = pts.Sim.Time.elapsedSec.getValue();
		
		ADIRSnew.Lights.adrOff[me.num].setValue(1);
		ADIRSnew.Lights.adrFault[me.num].setValue(1);
		settimer(func() {
			ADIRSnew.Lights.adrOff[me.num].setValue(0);
			ADIRSnew.Lights.adrFault[me.num].setValue(0);
		}, 0.1);
		settimer(func() {
			ADIRSnew.Lights.adrOff[me.num].setValue(1);
			ADIRSnew.Lights.adrFault[me.num].setValue(1);
			ADIRSnew.Lights.irFault[me.num].setValue(1);
			ADIRSnew.Lights.irOff[me.num].setValue(1);
		}, 1.0);
		settimer(func() {
			ADIRSnew.Lights.adrOff[me.num].setValue(0);
			ADIRSnew.Lights.adrFault[me.num].setValue(0);
			ADIRSnew.Lights.irFault[me.num].setValue(0);
			ADIRSnew.Lights.irOff[me.num].setValue(0);
		}, 1.1);
		
		ADIRSnew.selfTest();
	},
	# Alignment
	align: func(time) {
		ADIRSnew.Lights.irFault[me.num].setBoolValue(0);
		if (!ADIRSnew.skip.getValue()) {
			if (time > 0 and me.aligned == 0 and me.inAlign == 0 and me.operative == 1) {
				me._alignTime = pts.Sim.Time.elapsedSec.getValue() + time;
				me.inAlign = 1;
				if (me.alignTimer != nil) {
					me.alignTimer.start();
				}
			}
		} else {
			if (me.aligned == 0 and me.inAlign == 0 and me.operative == 1) {
				me._alignTime = pts.Sim.Time.elapsedSec.getValue() + 5;
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
		setprop("systems/navigation/aligned-" ~ (me.num + 1), 0);
		if (me.alignTimer != nil) {
			me.alignTimer.stop();
		}
	},
	stopAlignAligned: func() {
		me.inAlign = 0;
		me.aligned = 1;
		setprop("systems/navigation/aligned-" ~ (me.num + 1), 1);
		if (me.alignTimer != nil) {
			me.alignTimer.stop();
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
			print("ADIRU " ~ me.num ~ " off");
			me.stopAlignNoAlign();
		} elsif (pts.Sim.Time.elapsedSec.getValue() >= me._alignTime) {
			me.stopAlignAligned();
		}
	},
	instAlign: func() {
		me.stopAlignAligned();
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
				if (!ADIRSnew._selfTest) {
					ADIRSnew.Lights.onBat.setBoolValue(0);
				}
			} elsif (((me._timeVar < me._noPowerTime + 300 and me._voltageLimitedTime) or !me._voltageLimitedTime) and me._voltageBackup) {
				me.setOperative(1);
				if (!ADIRSnew._selfTest) {
					ADIRSnew.Lights.onBat.setBoolValue(1);
				}
			} else {
				me._noPowerTime = 0;
				me.setOperative(0);
				if (!ADIRSnew._selfTest) {
					ADIRSnew.Lights.onBat.setBoolValue(0);
				}
			}
		} else {
			me._noPowerTime = 0;
			me.setOperative(0);
			if (!ADIRSnew._selfTest) {
				ADIRSnew.Lights.onBat.setBoolValue(0);
			}
		}
	},
};

var ADIRSControlPanel = {
	adrSw: func(n) { 
		if (n < 0 or n > _NUMADIRU) { return; }
		ADIRSnew._adrSwitchState = ADIRSnew.Switches.adrSw[n].getValue();
		ADIRSnew.Switches.adrSw[n].setValue(!ADIRSnew._adrSwitchState);
		if (ADIRSnew.ADIRunits[n] != nil) { 
			ADIRSnew.ADIRunits[n].outputOn = !ADIRSnew._adrSwitchState;
		}
		ADIRSnew.Lights.adrOff[n].setValue(ADIRSnew._adrSwitchState);
	},
	irSw: func(n) { 
		if (n < 0 or n > _NUMADIRU) { return; }
		ADIRSnew._irSwitchState = ADIRSnew.Switches.irSw[n].getValue();
		ADIRSnew.Switches.irSw[n].setValue(!ADIRSnew._irSwitchState);
		if (ADIRSnew.IRunits[n] != nil) { 
			ADIRSnew.IRunits[n].outputOn = !ADIRSnew._irSwitchState;
		}
		ADIRSnew.Lights.irOff[n].setValue(ADIRSnew._adrSwitchState);
	},
	irModeSw: func(n, mode) {
		if (n < 0 or n > _NUMADIRU) { return; }
		if (mode < 0 or mode > 2) { return; }
		me._irModeSwitchState = ADIRSnew.Switches.irModeSw[n].getValue();
		if (ADIRSnew.ADIRunits[n] != nil) { 
			ADIRSnew.ADIRunits[n].mode = mode;
			ADIRSnew.ADIRunits[n].updateEnergised(mode);
			ADIRSnew.Switches.irModeSw[n].setValue(mode);
			if (mode == 0) {
				ADIRSnew.Lights.irFault[n].setBoolValue(0);
				ADIRSnew.ADIRunits[n].stopAlignNoAlign();
			} elsif (ADIRSnew.ADIRunits[n].aligned == 0) {
				ADIRSnew.ADIRunits[n].update(); # update early so operative is set properly
				ADIRSnew.ADIRunits[n].align(calcAlignTime(pts.Position.latitude.getValue())); # when you set NAV, it first acquires GPS position then acquires GPS. You then use IRS INIT > to set PPOS to align if you wish
			}
		}
	}
};

var ADIRSnew = {
	# local vars
	_adrSwitchState: 0,
	_irSwitchState: 0,
	_irModeSwitchState: 0,
	_hasPower: 0,
	_cacheOperative: [0, 0, 0],
	_cacheOutputOn: [0, 0, 0],
	_flapPos: nil,
	_slatPos: nil,
	_selfTest: 0,
	_init: 0,
	
	# ADIRS Units
	ADIRunits: [nil, nil, nil],
	
	# Electrical
	mainSupply: [systems.ELEC.Bus.acEss, systems.ELEC.Bus.ac2, systems.ELEC.Bus.ac1],
	backupSupply: [[systems.ELEC.Bus.dcHot2, 0], [systems.ELEC.Bus.dcHot2, 1], [systems.ELEC.Bus.dcHot1, 1]],
	
	# PTS
	Lights: {
		adrFault: [props.globals.getNode("controls/navigation/adirscp/lights/adr-1-fault"), props.globals.getNode("controls/navigation/adirscp/lights/adr-2-fault"), props.globals.getNode("controls/navigation/adirscp/lights/adr-3-fault")],
		adrOff: [props.globals.getNode("controls/navigation/adirscp/lights/adr-1-off"), props.globals.getNode("controls/navigation/adirscp/lights/adr-2-off"), props.globals.getNode("controls/navigation/adirscp/lights/adr-3-off")],
		irFault: [props.globals.getNode("controls/navigation/adirscp/lights/ir-1-fault"), props.globals.getNode("controls/navigation/adirscp/lights/ir-2-fault"), props.globals.getNode("controls/navigation/adirscp/lights/ir-3-fault")],
		irOff: [props.globals.getNode("controls/navigation/adirscp/lights/ir-1-off"), props.globals.getNode("controls/navigation/adirscp/lights/ir-2-off"), props.globals.getNode("controls/navigation/adirscp/lights/ir-3-off")],
		onBat: props.globals.getNode("controls/navigation/adirscp/lights/on-bat"),
	},
	Switches: {
		adrSw: [props.globals.getNode("controls/navigation/adirscp/switches/adr-1"), props.globals.getNode("controls/navigation/adirscp/switches/adr-2"), props.globals.getNode("controls/navigation/adirscp/switches/adr-3")],
		irModeSw: [props.globals.getNode("controls/navigation/adirscp/switches/ir-1-mode"), props.globals.getNode("controls/navigation/adirscp/switches/ir-2-mode"), props.globals.getNode("controls/navigation/adirscp/switches/ir-3-mode")],
		irSw: [props.globals.getNode("controls/navigation/adirscp/switches/ir-1"), props.globals.getNode("controls/navigation/adirscp/switches/ir-2"), props.globals.getNode("controls/navigation/adirscp/switches/ir-3")],
	},
	Operating: {
		adr: [props.globals.getNode("systems/navigation/adr/operating-1"), props.globals.getNode("systems/navigation/adr/operating-2"), props.globals.getNode("systems/navigation/adr/operating-3")],
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
				me._flapPos = pts.JSBSIM.FCS.flapDeg.getValue();
				me._slatPos = pts.JSBSIM.FCS.slatDeg.getValue();
				
				if (me._flapPos >= 23 and me._slatPos >= 25) {
					ADIRSnew.overspeedVFE.setValue(181);
				} elsif (me._flapPos >= 18) {
					ADIRSnew.overspeedVFE.setValue(189);
				} elsif (me._flapPos >= 13 or me._slatPos > 20) {
					ADIRSnew.overspeedVFE.setValue(204);
				} elsif (me._slatPos <= 20 and me._flapPos > 2) {
					ADIRSnew.overspeedVFE.setValue(219);
				} elsif (me._slatPos >= 2 and me._slatPos <= 20) {
					ADIRSnew.overspeedVFE.setValue(234);
				} else {
					ADIRSnew.overspeedVFE.setValue(1024);
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
		ADIRSnew.Lights.onBat.setBoolValue(1);
		selfTestLoop.start();
	},
	
};

var calcAlignTime = func(latitude) {
	return ((0.002 * (latitude * latitude)) + 5) * 60;
};

setlistener("/systems/fmgc/cas-compare/cas-reject-all", func() {
	if (pts.FMGC.CasCompare.rejectAll.getBoolValue()) {
		fcu.athrOff("hard");
	}
}, 0, 0);

setlistener("/controls/adirs/skip", func() {
	if (ADIRSnew.skip.getBoolValue()) {
		for (i = 0; i < 3; i = i + 1) {
			if (ADIRSnew.ADIRunits[i].inAlign == 1) {
				ADIRSnew.ADIRunits[i].stopAlignAligned();
			}
		}
	}
}, 0, 0);

selfTestLoop = maketimer(0.2, func() {
	if (pts.Sim.Time.elapsedSec.getValue() > _selfTestTime + 5) {
		ADIRSnew.Lights.onBat.setBoolValue(0);
		selfTestLoop.stop();
		ADIRSnew._selfTest = 0;
	}
});