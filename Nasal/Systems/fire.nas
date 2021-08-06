# A3XX Fire System
# Jonathan Redpath

# Copyright (c) 2020 Josh Davidson (Octal450)

var elapsedTime = props.globals.getNode("/sim/time/elapsed-sec");
var apuTestBtn = props.globals.getNode("/controls/fire/apu-test-btn", 1);
var testBtn = props.globals.getNode("/controls/fire/test-btn-1", 1);
var testBtn2 = props.globals.getNode("/controls/fire/test-btn-2", 1);
var dischTest = props.globals.initNode("/systems/fire/cargo/disch-test", 0, "BOOL");
var cargoTestBtn = props.globals.initNode("/controls/fire/cargo/test", 0, "BOOL");
var cargoTestTime = props.globals.initNode("/controls/fire/cargo/test-time", 0, "DOUBLE");
var cargoTestTime2 = props.globals.initNode("/controls/fire/cargo/test-time2", 0, "DOUBLE");
var cargoTestTime3 = props.globals.initNode("/controls/fire/cargo/test-time3", 0, "DOUBLE");
var cargoTestTime4 = props.globals.initNode("/controls/fire/cargo/test-time4", 0, "DOUBLE");
var cargoTestBtnOff = props.globals.initNode("/controls/fire/cargo/test-off", 0, "BOOL");
var eng1FireWarn = props.globals.initNode("/systems/fire/engine1/warning-active", 0, "BOOL");
var eng2FireWarn = props.globals.initNode("/systems/fire/engine2/warning-active", 0, "BOOL");
var apuFireWarn = props.globals.initNode("/systems/fire/apu/warning-active", 0, "BOOL");
var lavatoryFireWarn = props.globals.getNode("/systems/fire/lavatory/warning", 1);
var eng1Inop = props.globals.initNode("/systems/fire/engine1/det-inop", 0, "BOOL");
var eng2Inop = props.globals.initNode("/systems/fire/engine2/det-inop", 0, "BOOL");
var apuInop = props.globals.initNode("/systems/fire/apu/det-inop", 0, "BOOL");
var aftCargoFireWarn = props.globals.initNode("/systems/fire/cargo/aft/warning-active", 0, "BOOL");
var fwdCargoFireWarn = props.globals.initNode("/systems/fire/cargo/fwd/warning-active", 0, "BOOL");
var eng1AgentTimer = props.globals.initNode("/systems/fire/engine1/agent1-timer", 99, "INT");
var eng2AgentTimer = props.globals.initNode("/systems/fire/engine2/agent1-timer", 99, "INT");
var eng1Agent2Timer = props.globals.initNode("/systems/fire/engine1/agent2-timer", 99, "INT");
var eng2Agent2Timer = props.globals.initNode("/systems/fire/engine2/agent2-timer", 99, "INT");
var apuAgentTimer = props.globals.initNode("/systems/fire/apu/agent-timer", 99, "INT");
var eng1AgentTimerTime = props.globals.initNode("/systems/fire/engine1/agent1-timer-time", 0, "INT");
var eng2AgentTimerTime = props.globals.initNode("/systems/fire/engine2/agent1-timer-time", 0, "INT");
var eng1Agent2TimerTime = props.globals.initNode("/systems/fire/engine1/agent2-timer-time", 0, "INT");
var eng2Agent2TimerTime = props.globals.initNode("/systems/fire/engine2/agent2-timer-time", 0, "INT");
var apuAgentTimerTime = props.globals.initNode("/systems/fire/apu/agent-timer-time", 0, "INT");

var fireButtons = [props.globals.getNode("/controls/engines/engine[0]/fire-btn"),props.globals.getNode("/controls/engines/engine[1]/fire-btn"),props.globals.getNode("/controls/apu/fire-btn")];

var fire_init = func {
	setprop("/controls/OH/protectors/fwddisch", 0);
	setprop("/controls/OH/protectors/aftdisch", 0);
	setprop("/controls/fire/cargo/fwddisch", 0);
	setprop("/controls/fire/cargo/aftdisch", 0);
	setprop("/systems/failures/fire/cargo-fwd-fire", 0);
	setprop("/systems/failures/fire/cargo-aft-fire", 0);
	setprop("/controls/fire/cargo/test", 0);
	fire_timer.start();
}

###################
# Fire System     #
###################
var engFireDetectorUnit = {
	sys: 0,
	active: 0,
	loopOne: 0,
	loopTwo: 0,
	condition: 100,
	fireProp: "",
	new: func(sys, fireProp, testProp) {
		var eF = {parents:[engFireDetectorUnit]};
		eF.sys = sys;
		eF.active = 0;
		eF.loopOne = 0;
		eF.loopTwo = 0;
		eF.fireProp = props.globals.getNode(fireProp, 1);
		eF.testProp = props.globals.getNode(testProp, 1);
		eF.condition = 100;
		return eF;
	},
	update: func() {
		if (me.condition == 0) { return; }
		foreach(var detector; engDetectorLoops.vector) {
			detector.updateTemp(detector.sys, detector.type);
		}
		
		if (me.fireProp.getValue() == 0 and me.testProp.getValue() == 0 and (me.loopOne != 9 and me.loopOne != 8) and (me.loopTwo != 9 and me.loopTwo != 8)) {
			me.loopOne = 0;
			me.loopTwo = 0;
			me.reset(me.sys);
			return;
		}
		
		if ((me.loopOne == 1 and me.loopTwo == 1) or ((me.loopOne == 9 or me.loopOne == 8) and me.loopTwo == 1) or (me.loopOne == 1 and (me.loopTwo == 9 or me.loopTwo == 8))) {
			me.TriggerWarning(me.sys);
		}
	},
	receiveSignal: func(type) {
		if (type == 1 and me.loopOne != 9 and me.loopOne != 8 and me.condition != 0) {
			me.loopOne = 1;
		} elsif (type == 2 and me.loopTwo != 9 and me.loopTwo != 8 and me.condition != 0) {
			me.loopTwo = 1;
		}
	},
	failUnit: func() {
		me.condition = 0;
	},
	recoverUnit: func() {
		me.condition = 100;
	},
	fail: func(loop) {
		if (loop != 1 and loop != 2) { return; }
		
		if (loop == 1) { me.loopOne = 9; }
		else { me.loopTwo = 9; }
		
		me.startFailTimer(loop);
	},
	restore: func(loop) {
		if (loop != 1 and loop != 2) { return; }
		if (loop == 1) { me.loopOne = 0; }
		else { me.loopTwo = 0; }
		
		
		if (me.sys == 0) {
			eng1Inop.setBoolValue(0);
			checkTwoInop1Timer.stop();
		} elsif (me.sys == 1) {
			eng2Inop.setBoolValue(0);
			checkTwoInop2Timer.stop();
		} elsif (me.sys == 2) {
			apuInop.setBoolValue(0);
			checkTwoInop3Timer.stop();
		}
	},
	noElec: func(loop) {
		if (loop != 1 and loop != 2) { return; }
	
		if (loop == 1) { me.loopOne = 8; }
		else { me.loopTwo = 8; }
	},
	restoreElec: func(loop) {
		if (loop != 1 and loop != 2) { return; }
		
		if (loop == 1 and me.loopOne != 9) { me.loopOne = 0; }
		elsif (loop == 2 and me.loopTwo != 9) { me.loopTwo = 0; }
	},
	startFailTimer: func(loop) {
		if (loop == 1 and me.loopTwo == 9) { return; }
		if (loop == 2 and me.loopOne == 9) { return; }
		
		if (me.sys != 2) {
			if (loop == 1) {
				propsNasFireTime.vector[me.sys].setValue(elapsedTime.getValue());
			} elsif (loop == 2) {
				propsNasFireTime.vector[me.sys + 1].setValue(elapsedTime.getValue());
			}
			
			if (me.sys == 0) {
				if (!fireTimer1.isRunning) {
					fireTimer1.start();
				}
			} elsif (me.sys == 1) {
				if (!fireTimer2.isRunning) {
					fireTimer2.start();
				}
			}
		} else {
			if (loop == 1) {
				propsNasFireTime.vector[4].setValue(elapsedTime.getValue());
			} elsif (loop == 2) {
				propsNasFireTime.vector[5].setValue(elapsedTime.getValue());
			}
			
			if (!fireTimer3.isRunning) {
				fireTimer3.start();
			}
		}
	},
	TriggerWarning: func(system) {
		if (system == 0) {
			eng1FireWarn.setBoolValue(1);
		} elsif (system == 1) {
			eng2FireWarn.setBoolValue(1);
		} elsif (system == 2) {
			apuFireWarn.setBoolValue(1);
			if (pts.Fdm.JSBsim.Position.wow.getValue() == 1) {
				systems.APUController.APU.emergencyStop();
				settimer(func() { # 3 sec delay - source TTM ATA 26 FIRE PROTECTION p102
					extinguisherBottles.vector[4].discharge();
				}, 3);
			}
		}
	},
	reset: func(system) {
		if (system == 0) {
			eng1FireWarn.setBoolValue(0);
		} elsif (system == 1) {
			eng2FireWarn.setBoolValue(0);
		} elsif (system == 2) {
			apuFireWarn.setBoolValue(0);
		}
	}
};

var CIDSchannel = {
	elecProp: "",
	condition: 100,
	new: func(elecProp) {
		var cC = {parents:[CIDSchannel]};
		cC.elecProp = props.globals.getNode(elecProp, 1);
		return cC;
	},
	update: func() {
		if (me.condition == 0 or me.elecProp.getValue() < 25) { return; }
		
		if ((cargoSmokeDetectorUnits.vector[0].loopOne == 1 and cargoSmokeDetectorUnits.vector[0].loopTwo == 1) or (cargoSmokeDetectorUnits.vector[0].loopOne == 1 and cargoSmokeDetectorUnits.vector[0].loopTwo == 9) or (cargoSmokeDetectorUnits.vector[0].loopOne == 9 and cargoSmokeDetectorUnits.vector[0].loopTwo == 1) or (cargoSmokeDetectorUnits.vector[1].loopOne == 1 and cargoSmokeDetectorUnits.vector[1].loopTwo == 1) or (cargoSmokeDetectorUnits.vector[1].loopOne == 1 and cargoSmokeDetectorUnits.vector[1].loopTwo == 9) or (cargoSmokeDetectorUnits.vector[1].loopOne == 9 and cargoSmokeDetectorUnits.vector[1].loopTwo == 1)) {
			aftCargoFireWarn.setBoolValue(1);
		}
		
		if ((cargoSmokeDetectorUnits.vector[2].loopOne == 1 and cargoSmokeDetectorUnits.vector[2].loopTwo == 1) or (cargoSmokeDetectorUnits.vector[2].loopOne == 1 and cargoSmokeDetectorUnits.vector[2].loopTwo == 9) or (cargoSmokeDetectorUnits.vector[2].loopOne == 9 and cargoSmokeDetectorUnits.vector[2].loopTwo == 1)) {
			fwdCargoFireWarn.setBoolValue(1);
		}
	}
};

var cargoSmokeDetectorUnit = {
	sys: 0,
	active: 0,
	loopOne: 0,
	loopTwo: 0,
	condition: 100,
	new: func(sys) {
		var cF = {parents:[cargoSmokeDetectorUnit]};
		cF.sys = sys;
		cF.active = 0;
		cF.loopOne = 0;
		cF.loopTwo = 0;
		cF.condition = 100;
		return cF;
	},
	receiveSignal: func(type) {
		if (type == 1 and me.loopOne != 9 and me.condition != 0) {
			me.loopOne = 1;
		} elsif (type == 2 and me.loopTwo != 9 and me.condition != 0) {
			me.loopTwo = 1;
		}
	},
	failUnit: func() {
		me.condition = 0;
	},
	recoverUnit: func() {
		me.condition = 100;
	},
	failLoop: func(loop) {
		if (loop != 1 and loop != 2) { return; }
		
		if (loop == 1) { me.loopOne = 9; }
		else { me.loopTwo = 9; }
	},
};

var detectorLoop = {
	sys: 9,
	type: 0,
	temperature: "",
	elecProp: "",
	fireProp: "",
	new: func(sys, type, temperature, elecProp, fireProp) {
		var dL = {parents:[detectorLoop]};
		dL.sys = sys;
		dL.type = type;
		dL.temperature = props.globals.getNode(temperature, 1);
		dL.elecProp = props.globals.getNode(elecProp, 1);
		dL.fireProp = props.globals.getNode(fireProp, 1);
		return dL;
	},
	updateTemp: func(system, typeLoop) {
		if ((me.temperature.getValue() > 250 and me.fireProp.getBoolValue()) and me.elecProp.getValue() >= 25) {
			if (rand() >= 0.98) { # flame damage may possibly fail the loop
				engFireDetectorUnits.vector[system].fail(1);
				engFireDetectorUnits.vector[system].fail(2);
			}
			me.sendSignal(system, typeLoop);
		} elsif (me.elecProp.getValue() >= 25) {
			engFireDetectorUnits.vector[system].restoreElec(typeLoop);
		} else {
			engFireDetectorUnits.vector[system].noElec(typeLoop);
		}
	},
	sendSignal: func(system, typeLoop) {
		if (system == 0 and !getprop("/systems/failures/fire/engine-left-fire")) { return; }
		elsif (system == 1 and !getprop("/systems/failures/fire/engine-right-fire")) { return; }
		elsif (system == 2 and !getprop("/systems/failures/fire/apu-fire")) { return; }
		engFireDetectorUnits.vector[system].receiveSignal(typeLoop);
	}
};

var cargoDetectorLoop = {
	sys: 9,
	type: 0,
	temperature: "",
	fireProp: "",
	new: func(sys, type, temperature, fireProp) {
		var cdL = {parents:[cargoDetectorLoop]};
		cdL.sys = sys;
		cdL.type = type;
		cdL.temperature = props.globals.getNode(temperature, 1);
		cdL.fireProp = props.globals.getNode(fireProp, 1);
		return cdL;
	},
	updateTemp: func(system, typeLoop) {
		
		if (me.temperature.getValue() > 250 and me.fireProp.getBoolValue()) {
			me.sendSignal(system, typeLoop);
		}
	},
	sendSignal: func(system, typeLoop) {
		if ((system == 0 or system == 1) and !getprop("/systems/failures/fire/cargo-aft-fire")) { return; }
		elsif (system == 2 and !getprop("/systems/failures/fire/cargo-fwd-fire")) { return; }
		
		cargoSmokeDetectorUnits.vector[system].receiveSignal(typeLoop);
	}
};

var extinguisherBottle = {
	quantity: 100,
	squib: 0,
	number: 0,
	lightProp: "",
	elecProp: "",
	failProp: "",
	warningProp: "",
	hack: 0,
	new: func(number, lightProp, elecProp, failProp, warningProp, quantity = 100, hack = 0) {
		var eB = {parents:[extinguisherBottle]};
		eB.quantity = quantity;
		eB.squib = 0;
		eB.number = number;
		eB.lightProp = props.globals.getNode(lightProp, 1);
		eB.elecProp = props.globals.getNode(elecProp, 1);
		eB.failProp = props.globals.getNode(failProp, 1);
		eB.warningProp = props.globals.getNode(warningProp, 1);
		eB.hack = hack;
		return eB;
	},
	emptyBottle: func() {
		# reduce quantity
		me.quantity -= 10;
		
		# quick hack for cargo bottles
		if (me.number == 7) {
			cargoExtinguisherBottles.vector[0].quantity -= 10;
		} elsif (me.number == 8) {
			cargoExtinguisherBottles.vector[1].quantity -= 10;
		}
		
		if (me.quantity > 0) { 
			settimer(func() {
				me.emptyBottle()
			}, 0.05); 
		} elsif (me.hack == 0) {
			me.lightProp.setValue(1);
			# make things interesting. If your fire won't go out you should play the lottery
			if (me.number == 0) {
				if (rand() < 0.90) { 
					settimer(func() {
						me.failProp.setValue(0);
						me.warningProp.setValue(0);
					}, rand() * 3);
				}
			} elsif (me.number == 1) {
				if (rand() < 0.999) {
					settimer(func() {
						me.failProp.setValue(0);
						me.warningProp.setValue(0);
					}, rand() * 3);
				}
			} elsif (me.number == 7) {
				if (rand() <= 0.95) {
					settimer(func() {
						me.failProp.setValue(0);
						if (rand() <= 0.20) {
							me.warningProp.setValue(0); # extinguishing agent detected as smoke, so warning likely to stay on
						}
					}, rand() * 3);
					cargoExtinguisherBottles.vector[0].hack == 1;
				}
			} elsif (me.number == 8) {
				if (rand() <= 0.95) {
					settimer(func() {
						me.failProp.setValue(0);
						if (rand() <= 0.20) {
							me.warningProp.setValue(0);
						}
					}, rand() * 3);
					cargoExtinguisherBottles.vector[1].hack == 1;
				}
			} elsif (me.number == 9) {
				if (rand() <= 0.999) {
					settimer(func() {
						me.failProp.setValue(0);
						me.warningProp.setValue(0);
					}, rand() * 3);
				}
			}
		}
	},
	discharge: func() {
		if (me.elecProp.getValue() < 25) { return; }
		me.squib = 1;
		me.emptyBottle();
	}
};

# If two loops fail within five seconds then assume there is a fire

var propsNasFireTime = std.Vector.new([
props.globals.initNode("/systems/fire/engine1/loop1-failtime", 0, "DOUBLE"), props.globals.initNode("/systems/fire/engine1/loop2-failtime", 0, "DOUBLE"),
props.globals.initNode("/systems/fire/engine2/loop1-failtime", 0, "DOUBLE"), props.globals.initNode("/systems/fire/engine2/loop2-failtime", 0, "DOUBLE"),
props.globals.initNode("/systems/fire/apu/loop1-failtime", 0, "DOUBLE"),     props.globals.initNode("/systems/fire/apu/loop2-failtime", 0, "DOUBLE")
]);

var checkTimeFire1 = func() {
	et = elapsedTime.getValue();
	var loop1 = propsNasFireTime.vector[0].getValue();
	var loop2 = propsNasFireTime.vector[1].getValue();
	
	if ((loop1 != 0 and et > loop1 + 5) or (loop2 != 0 and et > loop2 + 5))  {
		fireTimer1.stop();
		checkTwoInop1Timer.start();
	}
	
	if (engFireDetectorUnits.vector[0].loopOne == 9 and engFireDetectorUnits.vector[0].loopTwo == 9) {
		fireTimer1.stop();
		engFireDetectorUnits.vector[0].TriggerWarning(engFireDetectorUnits.vector[0].sys);
	}
}

var checkTwoInop1 = func() {
	if (engFireDetectorUnits.vector[0].loopOne == 9 and engFireDetectorUnits.vector[0].loopTwo == 9) {
		eng1Inop.setBoolValue(1);
		checkTwoInop1Timer.stop();
	}
}

var checkTimeFire2 = func() {
	et = elapsedTime.getValue();
	var loop3 = propsNasFireTime.vector[2].getValue();
	var loop4 = propsNasFireTime.vector[3].getValue();
	
	if ((loop3 != 0 and et > loop3 + 5) or (loop4 != 0 and et > loop4 + 5))  {
		fireTimer2.stop();
		checkTwoInop2Timer.start();
	}
	
	if (engFireDetectorUnits.vector[1].loopOne == 9 and engFireDetectorUnits.vector[1].loopTwo == 9) {
		fireTimer2.stop();
		engFireDetectorUnits.vector[1].TriggerWarning(engFireDetectorUnits.vector[1].sys);
	}
}

var checkTwoInop2 = func() {
	if (engFireDetectorUnits.vector[1].loopOne == 9 and engFireDetectorUnits.vector[1].loopTwo == 9) {
		eng2Inop.setBoolValue(1);
		checkTwoInop2Timer.stop();
	}
}

var checkTimeFire3 = func() {
	et = elapsedTime.getValue();
	var loop5 = propsNasFireTime.vector[4].getValue();
	var loop6 = propsNasFireTime.vector[5].getValue();
	
	if ((loop5 != 0 and et > loop6 + 5) or (loop6 != 0 and et > loop6 + 5)) {
		fireTimer3.stop();
		checkTwoInop3Timer.start();
	}
	
	if (engFireDetectorUnits.vector[2].loopOne == 9 and engFireDetectorUnits.vector[2].loopTwo == 9) {
		fireTimer3.stop();
		engFireDetectorUnits.vector[2].TriggerWarning(engFireDetectorUnits.vector[2].sys);
	}
}

var checkTwoInop3 = func() {
	if (engFireDetectorUnits.vector[2].loopOne == 9 and engFireDetectorUnits.vector[2].loopTwo == 9) {
		apuInop.setBoolValue(1);
		checkTwoInop3Timer.stop();
	}
}

var fireTimer1 = maketimer(0.1, checkTimeFire1);
fireTimer1.simulatedTime = 1;
var fireTimer2 = maketimer(0.1, checkTimeFire2);
fireTimer2.simulatedTime = 1;
var fireTimer3 = maketimer(0.1, checkTimeFire3);
fireTimer3.simulatedTime = 1;
var checkTwoInop1Timer = maketimer(0.1, checkTwoInop1);
var checkTwoInop2Timer = maketimer(0.1, checkTwoInop2);
var checkTwoInop3Timer = maketimer(0.1, checkTwoInop3);

# Create fire systems
var engFireDetectorUnits = std.Vector.new([ engFireDetectorUnit.new(0, "/systems/failures/fire/engine-left-fire", "/controls/fire/test-btn-1"), engFireDetectorUnit.new(1, "/systems/failures/fire/engine-right-fire", "/controls/fire/test-btn-2"), engFireDetectorUnit.new(2, "/systems/failures/fire/apu-fire", "/controls/fire/apu-test-btn") ]);
var cargoSmokeDetectorUnits = std.Vector.new([cargoSmokeDetectorUnit.new(0, "/systems/failures/fire/cargo-aft-fire"), cargoSmokeDetectorUnit.new(1, "/systems/failures/fire/cargo-aft-fire"), cargoSmokeDetectorUnit.new(1, "/systems/failures/fire/cargo-fwd-fire")]);

# Create detector loops
var engDetectorLoops = std.Vector.new([ 
detectorLoop.new(0, 1, "/systems/fire/engine1/temperature", "/systems/electrical/bus/dc-ess", "/systems/failures/fire/engine-left-fire"),  detectorLoop.new(0, 2, "/systems/fire/engine1/temperature", "/systems/electrical/bus/dc-2", "/systems/failures/fire/engine-left-fire"),
detectorLoop.new(1, 1, "/systems/fire/engine2/temperature", "/systems/electrical/bus/dc-2", "/systems/failures/fire/engine-right-fire"),    detectorLoop.new(1, 2, "/systems/fire/engine2/temperature", "/systems/electrical/bus/dc-ess", "/systems/failures/fire/engine-right-fire"),
detectorLoop.new(2, 1, "/systems/fire/apu/temperature", "/systems/electrical/bus/dc-bat", "/systems/failures/fire/apu-fire"),               detectorLoop.new(2, 2, "/systems/fire/apu/temperature", "/systems/electrical/bus/dc-bat", "/systems/failures/fire/apu-fire") 
]);

var cargoDetectorLoops = std.Vector.new([ 
cargoDetectorLoop.new(0, 1, "/systems/fire/cargo/aft/temperature", "/systems/failures/fire/cargo-aft-fire"), cargoDetectorLoop.new(0, 2, "/systems/fire/cargo/aft/temperature", "/systems/failures/fire/cargo-aft-fire"),
cargoDetectorLoop.new(1, 1, "/systems/fire/cargo/aft/temperature", "/systems/failures/fire/cargo-aft-fire"), cargoDetectorLoop.new(1, 2, "/systems/fire/cargo/aft/temperature", "/systems/failures/fire/cargo-aft-fire"),
cargoDetectorLoop.new(2, 1, "/systems/fire/cargo/fwd/temperature", "/systems/failures/fire/cargo-fwd-fire"), cargoDetectorLoop.new(2, 2, "/systems/fire/cargo/fwd/temperature", "/systems/failures/fire/cargo-fwd-fire")
]);

# Create extinguisher bottles
var extinguisherBottles = std.Vector.new([extinguisherBottle.new(0, "/systems/fire/engine1/disch1", "/systems/electrical/bus/dc-hot-1", "/systems/failures/fire/engine-left-fire", "/systems/fire/engine1/warning-active"), extinguisherBottle.new(1, "/systems/fire/engine1/disch2", "/systems/electrical/bus/dc-2", "/systems/failures/fire/engine-left-fire", "/systems/fire/engine1/warning-active"),
extinguisherBottle.new(0, "/systems/fire/engine2/disch1", "/systems/electrical/bus/dc-hot-2", "/systems/failures/fire/engine-right-fire", "/systems/fire/engine2/warning-active"), extinguisherBottle.new(1, "/systems/fire/engine2/disch2", "/systems/electrical/bus/dc-2", "/systems/failures/fire/engine-right-fire", "/systems/fire/engine2/warning-active"), 
extinguisherBottle.new(9, "/systems/fire/apu/disch", "/systems/electrical/bus/dc-bat", "/systems/failures/fire/apu-fire", "/systems/fire/apu/warning-active") ]);

# There is only one bottle but the system will think there are two, so other parts work
var cargoExtinguisherBottles = std.Vector.new([extinguisherBottle.new(8, "/systems/fire/cargo/disch", "/systems/electrical/bus/dc-bat", "/systems/failures/fire/cargo-aft-fire", "/systems/fire/cargo/aft/warning-active", 250), extinguisherBottle.new(7, "/systems/fire/cargo/disch", "/systems/electrical/bus/dc-bat", "/systems/failures/fire/cargo-fwd-fire", "/systems/fire/cargo/fwd/warning-active", 250)]);

# Create CIDS channels
var CIDSchannels = std.Vector.new([CIDSchannel.new("/systems/electrical/bus/dc-ess"), CIDSchannel.new("/systems/electrical/bus/dc-2")]);

# Setlistener helper
var createFireBottleListener = func(prop, fireBtnProp, index) {
	if (index >= extinguisherBottles.size()) {
		print("Error - calling listener on non-existent fire extinguisher bottle, index: " ~ index); 
		return;
	}
	
	setlistener(prop, func() {
		if (getprop(prop) == 1 and getprop(fireBtnProp) == 1) {
			extinguisherBottles.vector[index].discharge();
		}
	}, 0, 0);
}

var createCargoFireBottleListener = func(prop, index) {
	if (index >= extinguisherBottles.size()) {
		print("Error - calling listener on non-existent fire extinguisher bottle, index: " ~ index); 
		return;
	}
	
	setlistener(prop, func() {
		if (getprop(prop) == 1) {
			cargoExtinguisherBottles.vector[index].discharge();
		}
	}, 0, 0);
}

# Listeners 
setlistener("/controls/engines/engine[0]/fire-btn", func() { 
	if (systems.fireButtons[0].getValue() == 1) { 
		ecam.shutUpYou();
		eng1AgentTimerMakeTimer.stop();
		eng1AgentTimer.setValue(10);
		eng1AgentTimerTime.setValue(elapsedTime.getValue() + 11);
		eng1AgentTimerMakeTimer.start();
	}
}, 0, 0);

setlistener("/systems/fire/engine1/disch1", func() {
	if (getprop("/systems/fire/engine1/disch1") == 1) {
		eng1Agent2TimerMakeTimer.stop();
		eng1Agent2Timer.setValue(30);
		eng1Agent2TimerTime.setValue(elapsedTime.getValue() + 31);
		eng1Agent2TimerMakeTimer.start();
	}
}, 0, 0);

eng1AgentTimerMakeTimerFunc = func() {
	if (eng1AgentTimer.getValue() > 0) {
		var eng1Time = eng1AgentTimerTime.getValue();
		var etEng1 = elapsedTime.getValue();
		var timeToSetEng1 = eng1Time - etEng1;
		eng1AgentTimer.setValue(timeToSetEng1);
	} else {
		eng1AgentTimer.setValue(99);
		eng1AgentTimerMakeTimer.stop();
	}
}

eng1Agent2TimerMakeTimerFunc = func() {
	if (eng1Agent2Timer.getValue() > 0) {
		var eng1Time2 = eng1Agent2TimerTime.getValue();
		var etEng12 = elapsedTime.getValue();
		var timeToSetEng12 = eng1Time2 - etEng12;
		eng1Agent2Timer.setValue(timeToSetEng12);
	} else {
		eng1Agent2Timer.setValue(99);
		eng1Agent2TimerMakeTimer.stop();
	}
}

setlistener("/controls/engines/engine[1]/fire-btn", func() { 
	if (systems.fireButtons[1].getValue() == 1) { 
		ecam.shutUpYou(); 
		eng2AgentTimerMakeTimer.stop();
		eng2AgentTimer.setValue(10);
		eng2AgentTimerTime.setValue(elapsedTime.getValue() + 11);
		eng2AgentTimerMakeTimer.start();
	}
}, 0, 0);

setlistener("/systems/fire/engine2/disch1", func() {
	if (getprop("/systems/fire/engine2/disch1") == 1) {
		eng2Agent2TimerMakeTimer.stop();
		eng2Agent2Timer.setValue(30);
		eng2Agent2TimerTime.setValue(elapsedTime.getValue() + 31);
		eng2Agent2TimerMakeTimer.start();
	}
}, 0, 0);

eng2AgentTimerMakeTimerFunc = func() {
	if (eng2AgentTimer.getValue() > 0) {
		var eng2Time = eng2AgentTimerTime.getValue();
		var etEng2 = elapsedTime.getValue();
		var timeToSetEng2 = eng2Time - etEng2;
		eng2AgentTimer.setValue(timeToSetEng2);
	} else {
		eng2AgentTimer.setValue(99);
		eng2AgentTimerMakeTimer.stop();
	}
}

eng2Agent2TimerMakeTimerFunc = func() {
	if (eng2Agent2Timer.getValue() > 0) {
		var eng2Time2 = eng2Agent2TimerTime.getValue();
		var etEng22 = elapsedTime.getValue();
		var timeToSetEng22 = eng2Time2 - etEng22;
		eng2Agent2Timer.setValue(timeToSetEng22);
	} else {
		eng2Agent2Timer.setValue(99);
		eng2Agent2TimerMakeTimer.stop();
	}
}

setlistener("/controls/apu/fire-btn", func() { 
	if (systems.APUNodes.Controls.fire.getValue() == 1) { 
		ecam.shutUpYou(); 
		systems.APUController.APU.emergencyStop();
		apuAgentTimerMakeTimer.stop();
		apuAgentTimer.setValue(10);
		apuAgentTimerTime.setValue(elapsedTime.getValue() + 11);
		apuAgentTimerMakeTimer.start();
	}
}, 0, 0);

apuAgentTimerMakeTimerFunc = func() {
	if (apuAgentTimer.getValue() > 0) {
		var apuTime = apuAgentTimerTime.getValue();
		var etApu = elapsedTime.getValue();
		var timeToSetApu = apuTime - etApu;
		apuAgentTimer.setValue(timeToSetApu);
	} else {
		apuAgentTimerMakeTimer.stop();
	}
}

setlistener("/controls/fire/test-btn-1", func() {
	if (getprop("/systems/failures/fire/engine-left-fire")) { return; }
	
	if (testBtn.getValue() == 1) {
		if (systems.ELEC.Bus.dcBat.getValue() > 25 or systems.ELEC.Bus.dcEss.getValue() > 25) {
			eng1FireWarn.setBoolValue(1);
		}
	} else {
		eng1FireWarn.setBoolValue(0);
		ecam.shutUpYou();
	}
}, 0, 0);

setlistener("/controls/fire/test-btn-2", func() {
	if (getprop("/systems/failures/fire/engine-right-fire")) { return; }
	if (testBtn2.getValue() == 1) {
		if (systems.ELEC.Bus.dcBat.getValue() > 25 or systems.ELEC.Bus.dcEss.getValue() > 25) {
			eng2FireWarn.setBoolValue(1);
		}
	} else {
		eng2FireWarn.setBoolValue(0);
		ecam.shutUpYou();
	}
}, 0, 0);

setlistener("/controls/fire/apu-test-btn", func() {
	if (getprop("/systems/failures/fire/apu-fire")) { return; }
	if (apuTestBtn.getValue() == 1) {
		if (systems.ELEC.Bus.dcBat.getValue() > 25 or systems.ELEC.Bus.dcEss.getValue() > 25) {
			apuFireWarn.setBoolValue(1);
		}
	} else {
		apuFireWarn.setBoolValue(0);
		ecam.shutUpYou();
	}
}, 0, 0);

setlistener("/controls/fire/cargo/test", func() {
	if (getprop("/systems/failures/fire/aft-cargo-fire") or getprop("/systems/failures/fire/fwd-cargo-fire") or systems.ELEC.Bus.dcBat.getValue() < 25 or systems.ELEC.Bus.dcEss.getValue() < 25) { return; }
	if (cargoTestBtn.getBoolValue()) {
		cargoTestTime.setValue(elapsedTime.getValue());
		cargoTestChecker.start();
	} else {
		aftCargoFireWarn.setBoolValue(0);
		fwdCargoFireWarn.setBoolValue(0);
		dischTest.setBoolValue(0);
		ecam.shutUpYou();
		cargoTestBtnOff.setBoolValue(1);
	}
}, 0, 0);

var doCargoTest = func() {
	if (systems.ELEC.Bus.dcBat.getValue() > 25 or systems.ELEC.Bus.dcEss.getValue() > 25) {
		aftCargoFireWarn.setBoolValue(1);
		fwdCargoFireWarn.setBoolValue(1);
		cargoTestTime2.setValue(elapsedTime.getValue());
		cargoTestChecker2.start();
	}
}

var doCargoTest2 = func() {
	aftCargoFireWarn.setBoolValue(0);
	fwdCargoFireWarn.setBoolValue(0);
	ecam.shutUpYou();
	cargoTestTime3.setValue(elapsedTime.getValue());
	dischTest.setBoolValue(1);
	cargoTestChecker3.start();
}

var doCargoTest3 = func() {
	dischTest.setBoolValue(0);
	if (systems.ELEC.Bus.dcBat.getValue() > 25 or systems.ELEC.Bus.dcEss.getValue() > 25) {
		aftCargoFireWarn.setBoolValue(1);
		fwdCargoFireWarn.setBoolValue(1);
		cargoTestTime4.setValue(elapsedTime.getValue());
		cargoTestChecker4.start();
	}
}

var doCargoTest4 = func() {
	aftCargoFireWarn.setBoolValue(0);
	fwdCargoFireWarn.setBoolValue(0);
}

var cargoTestCheckerFunc = func() {
	if (!cargoTestBtn.getBoolValue()) {
		cargoTestChecker.stop();
	} elsif  (elapsedTime.getValue() > (cargoTestTime.getValue() + 3)) {
		doCargoTest();
		cargoTestChecker.stop();
	}
}

var cargoTestCheckerFunc2 = func() {
	if (!cargoTestBtn.getBoolValue()) {
		cargoTestChecker2.stop();
	} elsif  (elapsedTime.getValue() > (cargoTestTime2.getValue() + 3)) {
		doCargoTest2();
		cargoTestChecker2.stop();
	}
}

var cargoTestCheckerFunc3 = func() {
	if (!cargoTestBtn.getBoolValue()) {
		cargoTestChecker3.stop();
	} elsif  (elapsedTime.getValue() > (cargoTestTime3.getValue() + 3)) {
		doCargoTest3();
		cargoTestChecker3.stop();
	}
}

var cargoTestCheckerFunc4 = func() {
	if (!cargoTestBtn.getBoolValue()) {
		cargoTestChecker4.stop();
	} elsif  (elapsedTime.getValue() > (cargoTestTime4.getValue() + 3)) {
		doCargoTest4();
		cargoTestChecker4.stop();
	}
}

createFireBottleListener("/controls/engines/engine[0]/agent1-btn", "/controls/engines/engine[0]/fire-btn", 0);
createFireBottleListener("/controls/engines/engine[0]/agent2-btn", "/controls/engines/engine[0]/fire-btn", 1);
createFireBottleListener("/controls/engines/engine[1]/agent1-btn", "/controls/engines/engine[1]/fire-btn", 2);
createFireBottleListener("/controls/engines/engine[1]/agent2-btn", "/controls/engines/engine[1]/fire-btn", 3);
createFireBottleListener("/controls/apu/agent-btn", "/controls/apu/fire-btn", 4);
createCargoFireBottleListener("/controls/fire/cargo/aftdisch", 0);
createCargoFireBottleListener("/controls/fire/cargo/fwddisch", 1);

var updateUnitsAndChannels = func() {
	foreach (var units; engFireDetectorUnits.vector) {
		units.update();
	}
	
	foreach(var CargoDetector; cargoDetectorLoops.vector) {
		CargoDetector.updateTemp(CargoDetector.sys, CargoDetector.type);
	}
	
	foreach (var channels; CIDSchannels.vector) {
		channels.update();
	}
}

###################
# Update Function #
###################

var fire_timer = maketimer(0.25, updateUnitsAndChannels);
var eng1AgentTimerMakeTimer = maketimer(0.1, eng1AgentTimerMakeTimerFunc);
var eng2AgentTimerMakeTimer = maketimer(0.1, eng2AgentTimerMakeTimerFunc);
var eng1Agent2TimerMakeTimer = maketimer(0.1, eng1Agent2TimerMakeTimerFunc);
var eng2Agent2TimerMakeTimer = maketimer(0.1, eng2Agent2TimerMakeTimerFunc);
var apuAgentTimerMakeTimer = maketimer(0.1, apuAgentTimerMakeTimerFunc);
var cargoTestChecker = maketimer(0.1, cargoTestCheckerFunc);
var cargoTestChecker2 = maketimer(0.2, cargoTestCheckerFunc2);
var cargoTestChecker3 = maketimer(0.2, cargoTestCheckerFunc3);
var cargoTestChecker4 = maketimer(0.2, cargoTestCheckerFunc4);