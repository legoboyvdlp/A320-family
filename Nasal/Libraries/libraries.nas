# A320 Main Libraries
# Joshua Davidson (Octal450)

# Copyright (c) 2020 Josh Davidson (Octal450)

print("------------------------------------------------");
print("Copyright (c) 2016-2020 Josh Davidson (Octal450)");
print("------------------------------------------------");

setprop("/sim/replay/was-active", 0);

setprop("/sim/menubar/default/menu[0]/item[0]/enabled", 0);
setprop("/sim/menubar/default/menu[2]/item[0]/enabled", 0);
setprop("/sim/menubar/default/menu[2]/item[2]/enabled", 0);
setprop("/sim/menubar/default/menu[3]/enabled", 0);
setprop("/sim/menubar/default/menu[5]/item[9]/enabled", 0);
setprop("/sim/menubar/default/menu[5]/item[10]/enabled", 0);
setprop("/sim/menubar/default/menu[5]/item[11]/enabled", 0);

# Dimmers
setprop("/controls/lighting/ndl-norm", 1);
setprop("/controls/lighting/ndr-norm", 1);
setprop("/controls/lighting/upper-norm", 1);

# Lights
setprop("/sim/model/lights/nose-lights", 0);
setprop("/sim/model/lights/turnoffsw", 0);
setprop("/controls/lighting/turnoff-light-switch", 0);
setprop("/controls/lighting/leftturnoff", 0);
setprop("/controls/lighting/rightturnoff", 0);

# Oil Qty
var qty1 = math.round((rand() * 5 ) + 20, 0.1);
var qty2 = math.round((rand() * 5 ) + 20, 0.1);
setprop("/engines/engine[0]/oil-qt-actual", qty1);
setprop("/engines/engine[1]/oil-qt-actual", qty2);

##########
# Lights #
##########

var beacon_switch = props.globals.getNode("controls/switches/beacon", 1);
var beacon_ctl = props.globals.getNode("controls/lighting/beacon", 1);
var beacon = aircraft.light.new("/sim/model/lights/beacon", [0.1, 1], "/controls/lighting/beacon");
var strobe_switch = props.globals.getNode("controls/switches/strobe", 1);
var strobe_light = props.globals.getNode("controls/lighting/strobe", 1);
var strobe = aircraft.light.new("/sim/model/lights/strobe", [0.05, 0.06, 0.05, 1], "/controls/lighting/strobe");
var tail_strobe = aircraft.light.new("/sim/model/lights/tailstrobe", [0.1, 1], "/controls/lighting/strobe");
var logo_lights = getprop("/sim/model/lights/logo-lights");
var nav_lights = props.globals.getNode("sim/model/lights/nav-lights");
var wing_switch = props.globals.getNode("controls/switches/wing-lights", 1);
var wing_ctl = props.globals.getNode("controls/lighting/wing-lights", 1);
var dome_light = props.globals.initNode("/sim/model/lights/dome-light", 0.0, "DOUBLE");
var wow = getprop("/gear/gear[2]/wow");
var slats = getprop("/controls/flight/slats");
var gear = getprop("/gear/gear[0]/position-norm");
var nose_lights = getprop("/sim/model/lights/nose-lights");
var left_turnoff_light = props.globals.getNode("controls/lighting/leftturnoff");
var right_turnoff_light = props.globals.getNode("controls/lighting/rightturnoff");
var settingT = getprop("/controls/lighting/taxi-light-switch");
var settingTurnoff = getprop("/controls/lighting/turnoff-light-switch");
var setting = getprop("/controls/lighting/nav-lights-switch");
var domeSetting = getprop("/controls/lighting/dome-norm");
var landL = props.globals.getNode("controls/lighting/landing-lights[1]", 1);
var landR = props.globals.getNode("controls/lighting/landing-lights[2]", 1);
var landlSw = props.globals.getNode("controls/switches/landing-lights-l", 1);
var landrSw = props.globals.getNode("controls/switches/landing-lights-r", 1);

###################
# Tire Smoke/Rain #
###################

var tiresmoke_system = aircraft.tyresmoke_system.new(0, 1, 2);
aircraft.rain.init();

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

setlistener("/controls/flight/flaps-input", func {
	props.globals.getNode("sim/sounde/flaps-click").setBoolValue(1);
}, 0, 0);

setlistener("/sim/sounde/flaps-click", func {
	if (!getprop("/sim/sounde/flaps-click")) {
		return;
	}
	settimer(func {
		props.globals.getNode("sim/sounde/flaps-click").setBoolValue(0);
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

#######################
# Various Other Stuff #
#######################

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
	systems.autobrake_init();
	systems.fire_init();
	systems.icingInit();
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
}

setlistener("/sim/signals/fdm-initialized", func {
	systemsInit();
	fmgc.flightPlanTimer.start();
	fmgc.WaypointDatabase.read();
});

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
	
	if ((getprop("/controls/pneumatic/switches/groundair") or getprop("/controls/electrical/ground-cart")) and ((getprop("/velocities/groundspeed-kt") > 2) or (getprop("/controls/gear/brake-parking") == 0 and getprop("/services/chocks/enable") == 0))) {
		setprop("/controls/electrical/ground-cart", 0);
		setprop("/controls/pneumatic/switches/groundair", 0);
	}
	
	if (getprop("/velocities/groundspeed-kt") > 15) {
		setprop("/systems/shake/effect", 1);
	} else {
		setprop("/systems/shake/effect", 0);
	}
	
	if (getprop("/instrumentation/mk-viii/inputs/discretes/momentary-flap-all-override") == 1 or (getprop("/instrumentation/mk-viii/inputs/discretes/momentary-flap-3-override") == 1 and getprop("/controls/flight/flaps-pos") >= 4)) {
		setprop("/instrumentation/mk-viii/inputs/discretes/momentary-flap-override", 1);
	} else {
		setprop("/instrumentation/mk-viii/inputs/discretes/momentary-flap-override", 0);
	}
	
	if (getprop("/instrumentation/mk-viii/inputs/discretes/gpws-inhibit") == 1) {
		setprop("/instrumentation/mk-viii/speaker/volume", 0);
	} else {
		setprop("/instrumentation/mk-viii/speaker/volume", 2);
	}
	
	if (getprop("/engines/engine[0]/state") == 3 and getprop("/engines/engine[1]/state") == 3) {
		setprop("/engines/ready", 1);
	} else {
		setprop("/engines/ready", 0);
	}
	
	if ((getprop("/engines/engine[0]/state") == 2 or getprop("/engines/engine[0]/state") == 3) and getprop("/fdm/jsbsim/propulsion/tank[5]/contents-lbs") < 1) {
		systems.cutoff_one();
	}
	if ((getprop("/engines/engine[1]/state") == 2 or getprop("/engines/engine[1]/state") == 3) and getprop("/fdm/jsbsim/propulsion/tank[6]/contents-lbs") < 1) {
		systems.cutoff_two();
	}
	
	if (getprop("/sim/replay/replay-state") == 1) {
		setprop("/sim/replay/was-active", 1);
	} else if (getprop("/sim/replay/replay-state") == 0 and getprop("/sim/replay/was-active") == 1) {
		setprop("/sim/replay/was-active", 0);
		acconfig.colddark();
		gui.popupTip("Replay Ended: Setting Cold and Dark state...");
	}
});

setlistener("/options/steep-ils", func {
	if (getprop("/options/steep-ils") == 1) {
		setprop("/instrumentation/mk-viii/inputs/discretes/steep-approach", 1);
	} else {
		setprop("/instrumentation/mk-viii/inputs/discretes/steep-approach", 0);
	}
});

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

controls.stepSpoilers = func(step) {
	setprop("/controls/flight/speedbrake-arm", 0);
	if (step == 1) {
		deploySpeedbrake();
	} else if (step == -1) {
		retractSpeedbrake();
	}
}

var deploySpeedbrake = func {
	if (getprop("/gear/gear[1]/wow") == 1 or getprop("/gear/gear[2]/wow") == 1) {
		if (getprop("/controls/flight/speedbrake") < 1.0) {
			setprop("/controls/flight/speedbrake", 1.0);
		}
	} else {
		if (getprop("/controls/flight/speedbrake") < 0.5) {
			setprop("/controls/flight/speedbrake", 0.5);
		} else if (getprop("/controls/flight/speedbrake") < 1.0) {
			setprop("/controls/flight/speedbrake", 1.0);
		}
	}
}

var retractSpeedbrake = func {
	if (getprop("/gear/gear[1]/wow") == 1 or getprop("/gear/gear[2]/wow") == 1) {
		if (getprop("/controls/flight/speedbrake") > 0.0) {
			setprop("/controls/flight/speedbrake", 0.0);
		}
	} else {
		if (getprop("/controls/flight/speedbrake") > 0.5) {
			setprop("/controls/flight/speedbrake", 0.5);
		} else if (getprop("/controls/flight/speedbrake") > 0.0) {
			setprop("/controls/flight/speedbrake", 0.0);
		}
	}
}

var slewProp = func(prop, delta) {
	delta *= getprop("/sim/time/delta-realtime-sec");
	setprop(prop, getprop(prop) + delta);
	return getprop(prop);
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


controls.elevatorTrim = func(speed) {
	if (getprop("/systems/hydraulic/green-psi") >= 1500) {
		slewprop("/controls/flight/elevator-trim", speed * 0.0185);  # Rate in JSB normalized (0.25 / 13.5)
	} else {
		slewprop("/controls/flight/elevator-trim", speed * 0.0092);  # Rate in JSB normalized (0.125 / 13.5)
	}
}

setlistener("/controls/flight/elevator-trim", func {
	if (getprop("/controls/flight/elevator-trim") > 0.296296) {
		setprop("/controls/flight/elevator-trim", 0.296296);
	}
});

var lightsLoop = maketimer(0.2, func {
	gear = getprop("/gear/gear[0]/position-norm");
	nose_lights = getprop("/sim/model/lights/nose-lights");
	settingT = getprop("/controls/lighting/taxi-light-switch");
	domeSetting = getprop("/controls/lighting/dome-norm");
	
	# nose lights
	
	if (settingT == 0.5 and gear > 0.9 and (getprop("/systems/electrical/bus/ac-1") > 0 or getprop("/systems/electrical/bus/ac-2") > 0)) {
		setprop("/sim/model/lights/nose-lights", 0.85);
	} else if (settingT == 1 and gear > 0.9 and (getprop("/systems/electrical/bus/ac-1") > 0 or getprop("/systems/electrical/bus/ac-2") > 0)) {
		setprop("/sim/model/lights/nose-lights", 1);
	} else {
		setprop("/sim/model/lights/nose-lights", 0);
	}
	
	# turnoff lights
	settingTurnoff = getprop("/controls/lighting/turnoff-light-switch");
	left_turnoff_light = props.globals.getNode("controls/lighting/leftturnoff");
	right_turnoff_light = props.globals.getNode("controls/lighting/rightturnoff");
	
	if (settingTurnoff == 1 and gear > 0.9 and getprop("/systems/electrical/bus/ac-1") > 0) {
		left_turnoff_light.setBoolValue(1);
	} else {
		left_turnoff_light.setBoolValue(0);
	}
	
	if (settingTurnoff == 1 and gear > 0.9 and getprop("/systems/electrical/bus/ac-2") > 0) {
		right_turnoff_light.setBoolValue(1);
	} else {
		right_turnoff_light.setBoolValue(0);
	}
	
	# logo and navigation lights
	setting = getprop("/controls/lighting/nav-lights-switch");
	nav_lights = props.globals.getNode("sim/model/lights/nav-lights");
	logo_lights = props.globals.getNode("sim/model/lights/logo-lights");
	wow = getprop("/gear/gear[2]/wow");
	slats = getprop("/controls/flight/slats");
	
	if (getprop("/systems/electrical/bus/ac-1") > 0 or getprop("/systems/electrical/bus/ac-2") > 0  or getprop("/systems/electrical/bus/dc-1") > 0 or getprop("/systems/electrical/bus/dc-2") > 0) {
		setprop("/systems/electrical/nav-lights-power", 1);
	} else { 
		setprop("/systems/electrical/nav-lights-power", 0);
	}
	
	if (setting == 0 and logo_lights == 1) {
		 logo_lights.setBoolValue(0);
	} else if (setting == 1 or setting == 2 and (getprop("/systems/electrical/bus/ac-1") > 0 or getprop("/systems/electrical/bus/ac-2") > 0)) {
		if ((wow) or (!wow and slats > 0)) {
			logo_lights.setBoolValue(1);
		} else {
			logo_lights.setBoolValue(0);
		}
	} else {
		logo_lights.setBoolValue(0);
	}

	if (setting == 1 or setting == 2 and (getprop("/systems/electrical/bus/ac-1") > 0 or getprop("/systems/electrical/bus/ac-2") > 0 or getprop("/systems/electrical/bus/dc-1") > 0 or getprop("/systems/electrical/bus/dc-2") > 0)) {
		nav_lights.setBoolValue(1);
	} else {
		nav_lights.setBoolValue(0);
	}
	
	if (domeSetting == 0.5 and getprop("/systems/electrical/bus/dc-ess") > 0) {
		dome_light.setValue(0.5);
	} elsif (domeSetting == 1 and getprop("/systems/electrical/bus/dc-ess") > 0) {
		dome_light.setValue(1);
	} else {
		dome_light.setValue(0);
	}
	
	# strobe
	strobe_sw = strobe_switch.getValue();
	
	if (strobe_sw == 1 and getprop("/systems/electrical/bus/ac-2") > 0) {
		strobe_light.setValue(1);
	} elsif (strobe_sw == 0.5 and getprop("/gear/gear[1]/wow") == 0 and getprop("/gear/gear[2]/wow") == 0 and getprop("/systems/electrical/bus/ac-2") > 0) {
		# todo: use lgciu output 5
		strobe_light.setValue(1);
	} else {
		strobe_light.setValue(0);
	}
	
	# beacon
	
	if (beacon_switch.getValue() == 1 and (getprop("/systems/electrical/bus/ac-1") > 0 or getprop("/systems/electrical/bus/ac-2") > 0)) {
		beacon_ctl.setValue(1);
	} else {
		beacon_ctl.setValue(0);
	}
	
	# wing
	
	if (wing_switch.getValue() == 1 and (getprop("/systems/electrical/bus/ac-1") > 0 or getprop("/systems/electrical/bus/ac-2") > 0)) {
		wing_ctl.setValue(1);
	} else {
		wing_ctl.setValue(0);
	}
	
	# landL
	
	if (landlSw.getValue() == 1 and getprop("/systems/electrical/bus/ac-1") > 0) {
		landL.setValue(1);
	} else {
		landL.setValue(0);
	}
	
	if (landrSw.getValue() == 1 and getprop("/systems/electrical/bus/ac-2") > 0) {
		landR.setValue(1);
	} else {
		landR.setValue(0);
	}
	
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
	
	if (getprop("/controls/lighting/landing-lights[1]") >= 0.5) {
		setprop("/fdm/jsbsim/rubbish/landL", 1);
	} else {
		setprop("/fdm/jsbsim/rubbish/landL", 0);
	}
	
	if (getprop("/controls/lighting/landing-lights[2]") >= 0.5) {
		setprop("/fdm/jsbsim/rubbish/landR", 1);
	} else {
		setprop("/fdm/jsbsim/rubbish/landR", 0);
	}
});

var lTray = func {
	var lTrayCMD = getprop("/controls/tray/lefttrayext");
	if (lTrayCMD < 0.5) {
		interpolate("/controls/tray/lefttrayext", 0.5, 0.5);
	} else if (lTrayCMD == 0.5) {
		interpolate("/controls/tray/lefttrayext", 1.0, 0.5);
	} else {
		interpolate("/controls/tray/lefttrayext", 0.0, 1.0);
	}
}

var rTray = func {
	var rTrayCMD = getprop("/controls/tray/righttrayext");
	if (rTrayCMD < 0.5) {
		interpolate("/controls/tray/righttrayext", 0.5, 0.5);
	} else if (rTrayCMD == 0.5) {
		interpolate("/controls/tray/righttrayext", 1.0, 0.5);
	} else {
		interpolate("/controls/tray/righttrayext", 0.0, 1.0);
	}
}

var l1Pedal = func {
	var lPedalCMD = getprop("/controls/footrest-cpt[0]");
	if (lPedalCMD < 1.0) {
		interpolate("/controls/footrest-cpt[0]", 1.0, 0.5);
	} else {
		interpolate("/controls/footrest-cpt[0]", 0.0, 0.5);
	}
}

var l2Pedal = func {
	var l2PedalCMD = getprop("/controls/footrest-cpt[1]");
	if (l2PedalCMD < 1.0) {
		interpolate("/controls/footrest-cpt[1]", 1.0, 0.5);
	} else {
		interpolate("/controls/footrest-cpt[1]", 0.0, 0.5);
	}
}

var r1Pedal = func {
	var rPedalCMD = getprop("/controls/footrest-fo[0]");
	if (rPedalCMD < 1.0) {
		interpolate("/controls/footrest-fo[0]", 1.0, 0.5);
	} else {
		interpolate("/controls/footrest-fo[0]", 0.0, 0.5);
	}
}

var r2Pedal = func {
	var r2PedalCMD = getprop("/controls/footrest-fo[1]");
	if (r2PedalCMD < 1.0) {
		interpolate("/controls/footrest-fo[1]", 1.0, 0.5);
	} else {
		interpolate("/controls/footrest-fo[1]", 0.0, 0.5);
	}
}

if (getprop("/controls/flight/auto-coordination") == 1) {
	setprop("/controls/flight/auto-coordination", 0);
	print("System: Auto Coordination has been turned off as it is not compatible with the fly-by-wire of this aircraft.");
	screen.log.write("Auto Coordination has been disabled as it is not compatible with the fly-by-wire of this aircraft", 1, 0, 0);
} 

setprop("/controls/flight/aileron-drives-tiller", 0);

var APPanel = {
	APDisc: func() {
		fcu.FCUController.APDisc();
	},
	ATDisc: func() {
		fcu.FCUController.ATDisc();
	},
};

var resetView = func() {
	if (getprop("/sim/current-view/view-number") == 0) {
		if (getprop("/sim/rendering/headshake/enabled")) {
			var _shakeFlag = 1;
			setprop("/sim/rendering/headshake/enabled", 0);
		} else {
			var _shakeFlag = 0;
		}
		
		var hd = getprop("/sim/current-view/heading-offset-deg");
		var hd_t = 360;
		if (hd < 180) {
		  hd_t = hd_t - 360;
		}
		
		interpolate("sim/current-view/field-of-view", 63, 0.66);
		interpolate("sim/current-view/heading-offset-deg", hd_t, 0.66);
		interpolate("sim/current-view/pitch-offset-deg", -14.6, 0.66);
		interpolate("sim/current-view/roll-offset-deg", 0, 0.66);
		interpolate("sim/current-view/x-offset-m", -0.45, 0.66); 
		interpolate("sim/current-view/y-offset-m", 2.34, 0.66); 
		interpolate("sim/current-view/z-offset-m", -13.75, 0.66);
		
		if (_shakeFlag) {
			setprop("/sim/rendering/headshake/enabled", 1);
		}
	} 
}

var autopilotView = func() {
	if (getprop("/sim/current-view/view-number") == 0) {
		if (getprop("/sim/rendering/headshake/enabled")) {
			var _shakeFlag = 1;
			setprop("/sim/rendering/headshake/enabled", 0);
		} else {
			var _shakeFlag = 0;
		}
		
		var hd = getprop("/sim/current-view/heading-offset-deg");
		var hd_t = 341.7;
		if (hd < 180) {
		  hd_t = hd_t - 360;
		}
		
		interpolate("sim/current-view/field-of-view", 63, 0.66);
		interpolate("sim/current-view/heading-offset-deg", hd_t, 0.66);
		interpolate("sim/current-view/pitch-offset-deg", -16.4, 0.66);
		interpolate("sim/current-view/roll-offset-deg", 0, 0.66);
		interpolate("sim/current-view/x-offset-m", -0.45, 0.66); 
		interpolate("sim/current-view/y-offset-m", 2.34, 0.66); 
		interpolate("sim/current-view/z-offset-m", -13.75, 0.66);
		
		if (_shakeFlag) {
			setprop("/sim/rendering/headshake/enabled", 1);
		}
	} 
}

var overheadView = func() {
	if (getprop("/sim/current-view/view-number") == 0) {
		if (getprop("/sim/rendering/headshake/enabled")) {
			var _shakeFlag = 1;
			setprop("/sim/rendering/headshake/enabled", 0);
		} else {
			var _shakeFlag = 0;
		}
		
		var hd = getprop("/sim/current-view/heading-offset-deg");
		var hd_t = 348;
		if (hd < 180) {
		  hd_t = hd_t - 360;
		}
		
		interpolate("sim/current-view/field-of-view", 105.8, 0.66);
		interpolate("sim/current-view/heading-offset-deg", hd_t, 0.66);
		interpolate("sim/current-view/pitch-offset-deg", 65.25, 0.66);
		interpolate("sim/current-view/roll-offset-deg", 0,0.66);
		interpolate("sim/current-view/x-offset-m", -0.12, 0.66); 
		interpolate("sim/current-view/y-offset-m", 2.34, 0.66); 
		interpolate("sim/current-view/z-offset-m", -13.75, 0.66);
		
		if (_shakeFlag) {
			setprop("/sim/rendering/headshake/enabled", 1);
		}
	} 
}

var pedestalView = func() {
	if (getprop("/sim/current-view/view-number") == 0) {
		if (getprop("/sim/rendering/headshake/enabled")) {
			var _shakeFlag = 1;
			setprop("/sim/rendering/headshake/enabled", 0);
		} else {
			var _shakeFlag = 0;
		}
		
		var hd = getprop("/sim/current-view/heading-offset-deg");
		var hd_t = 315;
		if (hd < 180) {
		  hd_t = hd_t - 360;
		}
		
		interpolate("sim/current-view/field-of-view", 63, 0.66);
		interpolate("sim/current-view/heading-offset-deg", hd_t, 0.66);
		interpolate("sim/current-view/pitch-offset-deg", -46.3, 0.66);
		interpolate("sim/current-view/roll-offset-deg", 0, 0.66);
		interpolate("sim/current-view/x-offset-m", -0.45, 0.66); 
		interpolate("sim/current-view/y-offset-m", 2.34, 0.66); 
		interpolate("sim/current-view/z-offset-m", -13.75, 0.66);
		
		if (_shakeFlag) {
			setprop("/sim/rendering/headshake/enabled", 1);
		}
	} 
}

var lightsView = func() {
	if (getprop("/sim/current-view/view-number") == 0) {
		if (getprop("/sim/rendering/headshake/enabled")) {
			var _shakeFlag = 1;
			setprop("/sim/rendering/headshake/enabled", 0);
		} else {
			var _shakeFlag = 0;
		}
		
		var hd = getprop("/sim/current-view/heading-offset-deg");
		var hd_t = 329;
		if (hd < 180) {
		  hd_t = hd_t - 360;
		}
		
		interpolate("sim/current-view/field-of-view", 63, 0.66);
		interpolate("sim/current-view/heading-offset-deg", hd_t, 0.66);
		interpolate("sim/current-view/pitch-offset-deg", 17.533, 0.66);
		interpolate("sim/current-view/roll-offset-deg", 0, 0.66);
		interpolate("sim/current-view/x-offset-m", -0.45, 0.66); 
		interpolate("sim/current-view/y-offset-m", 2.34, 0.66); 
		interpolate("sim/current-view/z-offset-m", -13.75, 0.66);
		
		if (_shakeFlag) {
			setprop("/sim/rendering/headshake/enabled", 1);
		}
	} 
}

setprop("/systems/acconfig/libraries-loaded", 1);
