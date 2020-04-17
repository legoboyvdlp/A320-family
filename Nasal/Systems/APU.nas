# A3XX Auxilliary Power Unit
# Jonathan Redpath (legoboyvdlp)

# Copyright (c) 2019 Jonathan Redpath (legoboyvdlp)

var APUNodes = {
	Controls: {
		master: props.globals.getNode("controls/apu/master"),
		bleed: props.globals.getNode("controls/pneumatic/switches/bleedapu"),
	},
	Oil: {
		level: props.globals.getNode("systems/apu/oil/level-l"),
	},
	masterElecThreeMin: props.globals.getNode("systems/apu/dc-bat-three-minutes"),
};

var APU = {
	state: 0, # off, power up, watch, starting preparation, starting, run, cooldown, shutdown
	inletFlap: aircraft.door.new("controls/apu/inlet-flap", 12),
	fuelValveCmd: props.globals.getNode("/systems/fuel/valves/apu-lp-valve-cmd"),
	fuelValvePos: props.globals.getNode("/systems/fuel/valves/apu-lp-valve"),
	inletFlapPos: props.globals.getNode("controls/apu/inlet-flap/position-norm"),
	oilLevel: props.globals.getNode("systems/apu/oil/level-l"),
	listenSignals: 0,
	listenStopSignal: 0,
	bleedTime: 0,
	cooldownEndTime: 0,
	warnings: {
		lowOilLevel: 0,
	},
	GenericControls: {
		starter: props.globals.getNode("controls/engines/engine[2]/starter"),
		cutoff: props.globals.getNode("controls/engines/engine[2]/cutoff"),
		throttle: props.globals.getNode("controls/engines/engine[2]/throttle"),
	},
	signals: {
		startInProgress: props.globals.getNode("systems/apu/start"),
		oilTestComplete: 0,
		available: props.globals.getNode("systems/apu/available"),
		bleedWasUsed: 0,
		fault: 0,
		autoshutdown: 0,
	},
	setState: func(num) {
		me.state = num;
	},
	resetStuff: func() {
		me.setState(0);
		me.warnings.lowOilLevel = 0;
		me.listenSignals = 0;
		me.listenStopSignal = 0;
		me.bleedTime = 0;
		me.cooldownEndTime = 0;
		me.signals.oilTestComplete = 0;
		me.signals.bleedWasUsed = 0;
		me.signals.fault = 0;
		me.signals.autoshutdown = 0;
	},
	new: func() {
		var a = { parents:[APU] };
		return a;
		me.GenericControls.throttle.setValue(1);
	},
	# Tests
	checkOil: func() {
		if (me.oilLevel.getValue() < 3.69) {
			me.warnings.lowOilLevel = 1;
		} else {
			me.warnings.lowOilLevel = 0;
		}
		me.signals.oilTestComplete = 1;
	},
	
	# Routines to do with state
	powerOn: func() {
		# apu able to receive emergency stop or start signals
		me.setState(1);
		me.fuelValveCmd.setValue(1);
		me.inletFlap.open();
		me.checkOil();
		me.listenSignals = 1;
		settimer(func() { me.setState(2)}, 3);
		settimer(func() { me.checkOil }, 8);
	},
	startCommand: func() {
		if (me.listenSignals and (me.state == 1 or me.state == 2)) {
			me.signals.startInProgress.setValue(1);
			me.setState(3);
			checkApuStartTimer.start();
		}
	},
	checkApuStart: func() {
		if (pts.APU.rpm.getValue() < 7 and me.fuelValvePos.getValue() and me.inletFlapPos.getValue() == 1 and me.signals.oilTestComplete and !me.warnings.lowOilLevel) {
			me.setState(4);
			me.listenStopSignal = 1;
			checkApuStartTimer.stop();
			me.startSequence();
		}
	},
	startSequence: func() {
		me.GenericControls.starter.setValue(1);
		apuStartTimer.start();
	},
	waitStart: func() {
		if (pts.APU.rpm.getValue() >= 4.9) {
			me.GenericControls.cutoff.setValue(0);
			apuStartTimer.stop();
			apuStartTimer2.start();
		}
	},
	waitStart2: func() {
		if (pts.APU.rpm.getValue() >= 99.9) {
			me.GenericControls.starter.setValue(0);
			me.signals.startInProgress.setValue(0);
			me.signals.available.setValue(1);
			me.setState(5);
			apuStartTimer2.stop();
		}
	},
	cooldown: func() {
		if (APUNodes.Controls.master.getValue()) {
			cooldownTimer.stop();
			me.setState(5);
			return;
		}
		if (pts.Sim.Time.elapsedSec.getValue() >= me.cooldownEndTime) {
			cooldownTimer.stop();
			me.stopAPU();
			me.setState(7);
			shutdownTimer.start();
		}
	},
	shutdown: func() {
		if (!me.signals.autoshutdown and APUNodes.Controls.master.getValue()) {
			me.powerOn();
			return;
		}
		
		me.GenericControls.cutoff.setValue(1);
		me.GenericControls.starter.setValue(0);
		
		if (!me.signals.autoshutdown and pts.APU.rpm.getValue() < 95 and me.signals.available.getValue()) {
			me.signals.available.setValue(0);
		}
		if (me.signals.autoshutdown and (me.signals.available.getValue() or !me.signals.fault)) {
			me.signals.available.setValue(0);
			me.signals.fault = 1;
		}
		
		if (pts.APU.rpm.getValue() < 7) {
			me.inletFlap.close();
			me.fuelValveCmd.setValue(0);
			if (!APUNodes.Controls.master.getValue()) {
				me.setState(0);
				me.resetStuff();
				shutdownTimer.stop();
			}
		}
	},
	
	# Signal generators / receivers
	stop: func() {
		if (me.listenStopSignal and me.state == 4) {
			me.signals.startInProgress.setValue(0);
			me.stopAPU();
			me.setState(7);
			shutdownTimer.start();
		} else {
			if (me.signals.bleedWasUsed) {
				if (120 - (pts.Sim.Time.elapsedSec.getValue() - me.bleedTime) > 0) {
					me.cooldownEndTime = me.bleedTime + 120;
					me.setState(6);
					cooldownTimer.start();
				} else {
					me.stopAPU();
					me.setState(7);
					shutdownTimer.start();
				}
			} else {
				me.stopAPU();
				me.setState(7);
				shutdownTimer.start();
			}
		}
	},
	autoStop: func() {
		if (me.state >= 4) {
			checkApuStartTimer.stop();
			apuStartTimer.stop();
			apuStartTimer2.stop();
			apuStartTimer3.stop();
			cooldownTimer.stop();
			me.stopAPU();
			me.setState(7);
			shutdownTimer.start();
		}
	},
	emergencyStop: func() {
		if (me.listenSignals and (me.state < 4)) {
			checkApuStartTimer.stop();
			me.inletFlap.close();
			me.fuelValveCmd.setValue(0);
			me.signals.fault = 1;
			me.setState(0);
		} elsif (me.state >= 4) {
			me.autoStop();
		}
	},
	
	# Functions
	stopAPU: func() {
		me.GenericControls.cutoff.setValue(1);
	},
	shutBleed: func() {
		APUNodes.Controls.bleed.setValue(0);
		me.bleedTime.setValue(pts.Sim.Time.elapsedSec.getValue());
	},
};

var APUController = {
	_init: 0,
	APU: nil,
	init: func() {
		if (!me._init) {
			me.APU = APU.new();
		}
	},
};

var _masterTime = 0;
setlistener("controls/apu/master", func() {
	if (APUNodes.Controls.master.getValue() and APUController.APU.state == 0) {
		APUNodes.masterElecThreeMin.setValue(1);
		checkMasterThreeMinTimer.start();
		_masterTime = pts.Sim.Time.elapsedSec.getValue();
		APUController.APU.powerOn();
	} elsif (!APUNodes.Controls.master.getValue()) {
		APUController.APU.stop();
	}
}, 0, 0);

setlistener("controls/pneumatic/switches/bleedapu", func() {
	APUController.APU.signals.bleedWasUsed = 1;
}, 0, 0);

var checkMasterThreeMinTimer = maketimer(0.1, func() {
	if (!APUNodes.Controls.master.getValue()) {
		APUNodes.masterElecThreeMin.setValue(0);
		checkMasterThreeMinTimer.stop();
		return;
	}
	
	if (pts.Sim.Time.elapsedSec.getValue() >= _masterTime + 180) {
		APUNodes.masterElecThreeMin.setValue(0);
		checkMasterThreeMinTimer.stop();
	}
});
var checkApuStartTimer = maketimer(0.1, func() {
	APUController.APU.checkApuStart();
});
var apuStartTimer = maketimer(0.1, func() {
	APUController.APU.waitStart();
});
var apuStartTimer2 = maketimer(0.1, func() {
	APUController.APU.waitStart2();
});
var cooldownTimer = maketimer(0.1, func() {
	APUController.APU.cooldown();
});
var shutdownTimer = maketimer(0.1, func() {
	APUController.APU.shutdown();
});