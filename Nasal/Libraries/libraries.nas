# A320 Main Libraries
# Joshua Davidson (Octal450)

# Copyright (c) 2020 Josh Davidson (Octal450)

print("------------------------------------------------");
print("Copyright (c) 2016-2020 Josh Davidson (Octal450)");
print("------------------------------------------------");


setprop("/sim/menubar/default/menu[0]/item[0]/enabled", 0);
setprop("/sim/menubar/default/menu[2]/item[0]/enabled", 0);
setprop("/sim/menubar/default/menu[2]/item[2]/enabled", 0);
setprop("/sim/menubar/default/menu[3]/enabled", 0);
setprop("/sim/menubar/default/menu[5]/item[9]/enabled", 0);
setprop("/sim/menubar/default/menu[5]/item[10]/enabled", 0);
setprop("/sim/menubar/default/menu[5]/item[11]/enabled", 0);

# Oil Qty
var qty1 = math.round((rand() * 5 ) + 20, 0.1);
var qty2 = math.round((rand() * 5 ) + 20, 0.1);
setprop("/engines/engine[0]/oil-qt-actual", qty1);
setprop("/engines/engine[1]/oil-qt-actual", qty2);

##########
# Lights #
##########
var beacon = aircraft.light.new("/sim/model/lights/beacon", [0.1, 1], "/controls/lighting/beacon");
var strobe = aircraft.light.new("/sim/model/lights/strobe", [0.05, 0.06, 0.05, 1], "/controls/lighting/strobe");
var tail_strobe = aircraft.light.new("/sim/model/lights/tailstrobe", [0.1, 1], "/controls/lighting/strobe");

var stateL = 0;
var stateR = 0;

###########
# Effects #
###########

var tiresmoke_system = aircraft.tyresmoke_system.new(0, 1, 2);
aircraft.rain.init();

aircraft.livery.init(getprop("/sim/model/livery-dir"));

##########
# Sounds #
##########

setlistener("/sim/sounde/btn1", func {
	if (!getprop("/sim/sounde/btn1")) {
		return;
	}
	settimer(func {
		props.globals.getNode("sim/sounde/btn1").setBoolValue(0);
	}, 0.05);
});

setlistener("/sim/sounde/oh-btn", func {
	if (!getprop("/sim/sounde/oh-btn")) {
		return;
	}
	settimer(func {
		props.globals.getNode("sim/sounde/oh-btn").setBoolValue(0);
	}, 0.05);
});

setlistener("/sim/sounde/btn3", func {
	if (!getprop("/sim/sounde/btn3")) {
		return;
	}
	settimer(func {
		props.globals.getNode("sim/sounde/btn3").setBoolValue(0);
	}, 0.05);
});

setlistener("/sim/sounde/knb1", func {
	if (!getprop("/sim/sounde/knb1")) {
		return;
	}
	settimer(func {
		props.globals.getNode("sim/sounde/knb1").setBoolValue(0);
	}, 0.05);
});

setlistener("/sim/sounde/switch1", func {
	if (!getprop("/sim/sounde/switch1")) {
		return;
	}
	settimer(func {
		props.globals.getNode("sim/sounde/switch1").setBoolValue(0);
	}, 0.05);
});

setlistener("/controls/lighting/seatbelt-sign", func {
	props.globals.getNode("sim/sounde/seatbelt-sign").setBoolValue(1);
	settimer(func {
		props.globals.getNode("sim/sounde/seatbelt-sign").setBoolValue(0);
	}, 2);
}, 0, 0);

setlistener("/controls/lighting/no-smoking-sign", func {
	props.globals.getNode("sim/sounde/no-smoking-sign").setBoolValue(1);
	settimer(func {
		props.globals.getNode("sim/sounde/no-smoking-sign").setBoolValue(0);
	}, 1);
}, 0, 0);

var flaps_click = props.globals.getNode("/sim/sounde/flaps-click");

setlistener("/controls/flight/flaps-input", func {
	flaps_click.setBoolValue(1);
}, 0, 0);

setlistener("/sim/sounde/flaps-click", func {
	if (!flaps_click.getValue()) {
		return;
	}
	settimer(func {
		flaps_click.setBoolValue(0);
	}, 0.4);
});

var spdbrk_click = props.globals.getNode("/sim/sounde/spdbrk-click");

setlistener("/controls/flight/speedbrake", func {
	spdbrk_click.setBoolValue(1);
}, 0, 0);

setlistener("/sim/sounde/spdbrk-click", func {
	if (!spdbrk_click.getValue()) {
		return;
	}
	settimer(func {
		spdbrk_click.setBoolValue(0);
	}, 0.4);
});

#########
# Doors #
#########

# Front doors
var doorl1 = aircraft.door.new("/sim/model/door-positions/doorl1", 4);
var doorr1 = aircraft.door.new("/sim/model/door-positions/doorr1", 4);

# Middle doors (A321 only)
var doorl2 = aircraft.door.new("/sim/model/door-positions/doorl2", 4);
var doorr2 = aircraft.door.new("/sim/model/door-positions/doorr2", 4);
var doorl3 = aircraft.door.new("/sim/model/door-positions/doorl3", 4);
var doorr3 = aircraft.door.new("/sim/model/door-positions/doorr3", 4);

# Rear doors
var doorl4 = aircraft.door.new("/sim/model/door-positions/doorl4", 4);
var doorr4 = aircraft.door.new("/sim/model/door-positions/doorr4", 4);

# Cargo holds
var cargobulk = aircraft.door.new("/sim/model/door-positions/cargobulk", 3);
var cargoaft = aircraft.door.new("/sim/model/door-positions/cargoaft", 10);
var cargofwd = aircraft.door.new("/sim/model/door-positions/cargofwd", 10);

# Seat armrests in the flight deck (unused)
var armrests = aircraft.door.new("/sim/model/door-positions/armrests", 2);

# door opener/closer
var triggerDoor = func(door, doorName, doorDesc) {
	if (getprop("/sim/model/door-positions/" ~ doorName ~ "/position-norm") > 0) {
		gui.popupTip("Closing " ~ doorDesc ~ " door");
		door.toggle();
	} else {
		if (getprop("/velocities/groundspeed-kt") > 5) {
			gui.popupTip("You cannot open the doors while the aircraft is moving!");
		} else {
			gui.popupTip("Opening " ~ doorDesc ~ " door");
			door.toggle();
		}
	}
};

###########
# Systems #
###########
var systemsInit = func {
	fbw.FBW.init();
	effects.light_manager.init();
	systems.ELEC.init();
	systems.PNEU.init();
	systems.HYD.init();
	systems.FUEL.init();
	systems.ADIRS.init();
	systems.eng_init();
	systems.APUController.init();
	systems.Autobrake.init();
	systems.fire_init();
	fmgc.flightPlanController.reset();
	fmgc.windController.reset();
	fadec.FADEC.init();
	fmgc.ITAF.init();
	fmgc.FMGCinit();
	mcdu.MCDU_init(0);
	mcdu.MCDU_init(1);
	mcdu_scratchpad.mcduMsgtimer1.start();
	mcdu_scratchpad.mcduMsgtimer2.start();
	systemsLoop.start();
	effects.icingInit();
	lightsLoop.start();
	ecam.ECAM.init();
	libraries.variousReset();
	rmp.init();
	acp.init();
	ecam.ECAM_controller.init();
	atc.init();
	fcu.FCUController.init();
	dmc.DMController.init();
	fmgc.flightPlanController.init();
	fmgc.windController.init();
	atsu.CompanyCall.init();
}

setlistener("/sim/signals/fdm-initialized", func {
	systemsInit();
	fmgc.postInit();
	fmgc.flightPlanTimer.start();
	fmgc.WaypointDatabase.read();
});

var collectorTankL = props.globals.getNode("/fdm/jsbsim/propulsion/tank[5]/contents-lbs");
var collectorTankR = props.globals.getNode("/fdm/jsbsim/propulsion/tank[6]/contents-lbs");
var groundAir = props.globals.getNode("/controls/pneumatics/switches/groundair");
var groundCart = props.globals.getNode("/controls/electrical/ground-cart");
var chocks = props.globals.getNode("/services/chocks/enable");
var engRdy = props.globals.getNode("/engines/ready");
var groundspeed = 0;

var systemsLoop = maketimer(0.1, func {
	systems.ELEC.loop();
	systems.PNEU.loop();
	systems.HYD.loop();
	systems.FUEL.loop();
	systems.ADIRS.loop();
	ecam.ECAM.loop();
	libraries.BUTTONS.update();
	fadec.FADEC.loop();
	rmp.rmpUpdate();
	fcu.FCUController.loop();
	dmc.DMController.loop();
	systems.APUController.loop();
	systems.HFLoop();
	atsu.ATSU.loop();
	
	groundspeed = pts.Velocities.groundspeed.getValue();
	if ((groundAir.getBoolValue() or groundCart.getBoolValue()) and ((groundspeed > 2) or (!pts.Controls.Gear.parkingBrake.getBoolValue() and !chocks.getBoolValue()))) {
		groundAir.setBoolValue(0);
		groundCart.setBoolValue(0);
	}
	
	if (groundspeed > 15) {
		shakeEffectA3XX.setBoolValue(1);
	} else {
		shakeEffectA3XX.setBoolValue(0);
	}
	
	stateL = pts.Engines.Engine.state[0].getValue();
	stateR = pts.Engines.Engine.state[1].getValue();
	
	if (stateL == 3 and stateR == 3) {
		engRdy.setBoolValue(1);
	} else {
		engRdy.setBoolValue(0);
	}
	
	if ((stateL == 2 or stateL == 3) and collectorTankL.getValue() < 1) {
		systems.cutoff_one();
	}
	if ((stateR == 2 or stateR == 3) and collectorTankR.getValue() < 1) {
		systems.cutoff_two();
	}
});

# GPWS
var GPWS = {
	inhibitNode: props.globals.getNode("/instrumentation/mk-viii/inputs/discretes/gpws-inhibit"),
	volume: props.globals.getNode("/instrumentation/mk-viii/speaker/volume"),
	flapAllOverride: props.globals.getNode("/instrumentation/mk-viii/inputs/discretes/momentary-flap-all-override"),
	flap3Override: props.globals.getNode("/instrumentation/mk-viii/inputs/discretes/momentary-flap-3-override"),
	flapOverride: props.globals.getNode("/instrumentation/mk-viii/inputs/discretes/momentary-flap-override"),
};

setlistener("/instrumentation/mk-viii/inputs/discretes/gpws-inhibit", func() {
	if (GPWS.inhibitNode.getBoolValue()) {
		GPWS.volume.setValue(2);
	} else {
		GPWS.volume.setValue(0);
	}
}, 0, 0);

var updateGPWSFlap = func() {
	if (GPWS.flapAllOverride.getBoolValue() or (GPWS.flap3Override.getBoolValue() and pts.Controls.Flight.flapsPos.getValue() >= 4)) {
		GPWS.flapOverride.setBoolValue(1);
	} else {
		GPWS.flapOverride.setBoolValue(0);
	}
}

setlistener("/instrumentation/mk-viii/inputs/discretes/momentary-flap-all-override", func() {
	updateGPWSFlap();
}, 0, 0);

setlistener("/instrumentation/mk-viii/inputs/discretes/momentary-flap-3-override", func() {
	updateGPWSFlap();
}, 0, 0);

# Replay
var replayState = props.globals.getNode("/sim/replay/replay-state");
setlistener("/sim/replay/replay-state", func() {
	if (replayState.getBoolValue()) {
	} else {
		acconfig.colddark();
		gui.popupTip("Replay Ended: Setting Cold and Dark state...");
	}
}, 0, 0);

# Steep ILS
setlistener("/options/steep-ils", func {
	if (getprop("/options/steep-ils") == 1) {
		setprop("/instrumentation/mk-viii/inputs/discretes/steep-approach", 1);
	} else {
		setprop("/instrumentation/mk-viii/inputs/discretes/steep-approach", 0);
	}
}, 0, 0);

# hackCanvas
canvas.Text._lastText = canvas.Text["_lastText"];
canvas.Text.setText = func(text) {
	if (text == me._lastText and text != nil and size(text) == size(me._lastText)) {return me;}
	me._lastText = text;
	me.set("text", typeof(text) == 'scalar' ? text : "");
};
canvas.Element._lastVisible = nil;
canvas.Element.show = func {
	if (1 == me._lastVisible) {return me;}
	me._lastVisible = 1;
	me.setBool("visible", 1);
};
canvas.Element.hide = func {
	if (0 == me._lastVisible) {return me;}
	me._lastVisible = 0;
	me.setBool("visible", 0);
};
canvas.Element.setVisible = func(vis) {
	if (vis == me._lastVisible) {return me;}
	me._lastVisible = vis;
	me.setBool("visible", vis);
};

############
# Controls #
############

controls.stepSpoilers = func(step) {
	pts.Controls.Flight.speedbrakeArm.setValue(0);
	if (step == 1) {
		deploySpeedbrake();
	} else if (step == -1) {
		retractSpeedbrake();
	}
}

var deploySpeedbrake = func {
	if (pts.Gear.Wow[1].getBoolValue() or pts.Gear.Wow[2].getBoolValue()) {
		if (pts.Controls.Flight.speedbrake.getValue() < 1.0) {
			pts.Controls.Flight.speedbrake.setValue(1.0);
		}
	} else {
		if (pts.Controls.Flight.speedbrake.getValue() < 0.5) {
			pts.Controls.Flight.speedbrake.setValue(0.5);
		} else if (pts.Controls.Flight.speedbrake.getValue() < 1.0) {
			pts.Controls.Flight.speedbrake.setValue(1.0);
		}
	}
}

var retractSpeedbrake = func {
	if (pts.Gear.Wow[1].getBoolValue() or pts.Gear.Wow[2].getBoolValue()) {
		if (pts.Controls.Flight.speedbrake.getValue() > 0.0) {
			pts.Controls.Flight.speedbrake.setValue(0.0);
		}
	} else {
		if (pts.Controls.Flight.speedbrake.getValue() > 0.5) {
			pts.Controls.Flight.speedbrake.setValue(0.5);
		} else if (pts.Controls.Flight.speedbrake.getValue() > 0.0) {
			pts.Controls.Flight.speedbrake.setValue(0.0);
		}
	}
}

var delta = 0;
var output = 0;
var slewProp = func(prop, delta) {
    delta *= pts.Sim.Time.deltaRealtimeSec.getValue();
    output = props.globals.getNode(prop).getValue() + delta;
    props.globals.getNode(prop).setValue(output);
    return output;
}

controls.flapsDown = func(step) {
	pts.Controls.Flight.flapsTemp = pts.Controls.Flight.flaps.getValue();
	if (step == 1) {
		if (pts.Controls.Flight.flapsTemp < 0.2) {
			pts.Controls.Flight.flaps.setValue(0.2);
		} else if (pts.Controls.Flight.flapsTemp < 0.4) {
			pts.Controls.Flight.flaps.setValue(0.4);
		} else if (pts.Controls.Flight.flapsTemp < 0.6) {
			pts.Controls.Flight.flaps.setValue(0.6);
		} else if (pts.Controls.Flight.flapsTemp < 0.8) {
			pts.Controls.Flight.flaps.setValue(0.8);
		}
	} else if (step == -1) {
		if (pts.Controls.Flight.flapsTemp > 0.6) {
			pts.Controls.Flight.flaps.setValue(0.6);
		} else if (pts.Controls.Flight.flapsTemp > 0.4) {
			pts.Controls.Flight.flaps.setValue(0.4);
		} else if (pts.Controls.Flight.flapsTemp > 0.2) {
			pts.Controls.Flight.flaps.setValue(0.2);
		} else if (pts.Controls.Flight.flapsTemp > 0) {
			pts.Controls.Flight.flaps.setValue(0);
		}
	}
}

controls.elevatorTrim = func(d) {
    if (systems.HYD.Psi.green.getValue() >= 1500) {
        slewProp("/controls/flight/elevator-trim", d * 0.0185); # Rate in JSB normalized (0.125 / 13.5)
    } else {
		 slewProp("/controls/flight/elevator-trim", d * 0.0092) # Rate in JSB normalized (0.125 / 13.5)
	}
}

setlistener("/controls/flight/elevator-trim", func {
    if (pts.Controls.Flight.elevatorTrim.getValue() > 0.296296) {
        pts.Controls.Flight.elevatorTrim.setValue(0.296296);
    }
}, 0, 0);

##########
# Lights #
##########

var lightsLoop = maketimer(0.2, func {
	# signs
	
	if (getprop("/systems/pressurization/cabinalt-norm") > 11300) {
		setprop("/controls/lighting/seatbelt-sign", 1);
		setprop("/controls/lighting/no-smoking-sign", 1);
	} else {
		if (getprop("/controls/switches/seatbelt-sign") == 1) {
			 if (getprop("/controls/lighting/seatbelt-sign") == 0) {
				setprop("/controls/lighting/seatbelt-sign", 1);
			}
		} elsif (getprop("/controls/switches/seatbelt-sign") == 0) {
			 if (getprop("/controls/lighting/seatbelt-sign") == 1) {
				setprop("/controls/lighting/seatbelt-sign", 0);
			}
		}
		
		if (getprop("/controls/switches/no-smoking-sign") == 1) {
			if (getprop("/controls/lighting/no-smoking-sign") == 0) {
				setprop("/controls/lighting/no-smoking-sign", 1);
			}
		} elsif (getprop("/controls/switches/no-smoking-sign") == 0.5 and getprop("/gear/gear[0]/position-norm") != 0) { # todo: should be when uplocks not engaged
			if (getprop("/controls/lighting/no-smoking-sign") == 0) {
				setprop("/controls/lighting/no-smoking-sign", 1);
			}
		} else {
			setprop("/controls/lighting/no-smoking-sign", 0); # sign stays on in cabin but sound still occurs
		}
	}
});

var pilotComfortTwoPos = func(prop) {
	var item = getprop(prop);
	if (item < 0.5) {
		interpolate(prop, 0.5, 0.5);
	} elsif (item == 0.5) {
		interpolate(prop, 1.0, 0.5);
	} else {
		interpolate(prop, 0.0, 1.0);
	}
}

var pilotComfortOnePos = func(prop) {
	var item = getprop(prop);
	if (item < 1.0) {
		interpolate(prop, 1.0, 1.0);
	} else {
		interpolate(prop, 0.0, 1.0);
	}
}

var lTray = func {
	pilotComfortTwoPos("/controls/tray/lefttrayext");
}
var rTray = func {
	pilotComfortTwoPos("/controls/tray/righttrayext");
}

var l1Pedal = func {
	pilotComfortOnePos("/controls/footrest-cpt[0]");
}
var l2Pedal = func {
	pilotComfortOnePos("/controls/footrest-cpt[1]");
}

var r1Pedal = func {
	pilotComfortOnePos("/controls/footrest-fo[0]");
}
var r2Pedal = func {
	var r2PedalCMD = getprop("/controls/footrest-fo[1]");
	pilotComfortOnePos("/controls/footrest-fo[1]");
}

#####################
# Auto-coordination #
#####################

if (pts.Controls.Flight.autoCoordination.getBoolValue()) {
    pts.Controls.Flight.autoCoordination.setBoolValue(0);
    pts.Controls.Flight.aileronDrivesTiller.setBoolValue(1);
} else {
    pts.Controls.Flight.aileronDrivesTiller.setBoolValue(0);
}

setlistener("/controls/flight/auto-coordination", func {
    pts.Controls.Flight.autoCoordination.setBoolValue(0);
	print("System: Auto Coordination has been turned off as it is not compatible with the fly-by-wire of this aircraft.");
	screen.log.write("Auto Coordination has been disabled as it is not compatible with the fly-by-wire of this aircraft", 1, 0, 0);
}, 0, 0);

##############
# Legacy FCU #
##############
var APPanel = {
	APDisc: func() {
		fcu.FCUController.APDisc();
	},
	ATDisc: func() {
		fcu.FCUController.ATDisc();
	},
};

setprop("/systems/acconfig/libraries-loaded", 1);
