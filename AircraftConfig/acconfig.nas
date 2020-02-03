# Aircraft Config Center
# Joshua Davidson (Octal450)

# Copyright (c) 2019 Joshua Davidson (Octal450)

var spinning = maketimer(0.05, func {
	var spinning = getprop("/systems/acconfig/spinning");
	if (spinning == 0) {
		setprop("/systems/acconfig/spin", "\\");
		setprop("/systems/acconfig/spinning", 1);
	} else if (spinning == 1) {
		setprop("/systems/acconfig/spin", "|");
		setprop("/systems/acconfig/spinning", 2);
	} else if (spinning == 2) {
		setprop("/systems/acconfig/spin", "/");
		setprop("/systems/acconfig/spinning", 3);
	} else if (spinning == 3) {
		setprop("/systems/acconfig/spin", "-");
		setprop("/systems/acconfig/spinning", 0);
	}
});

var failReset = func {
	# Put IntegratedSystems Fail Reset Functions here
}

var failResetOld = func {
	setprop("/systems/failures/elac1", 0);
	setprop("/systems/failures/elac2", 0);
	setprop("/systems/failures/sec1", 0);
	setprop("/systems/failures/sec2", 0);
	setprop("/systems/failures/sec3", 0);
	setprop("/systems/failures/fac1", 0);
	setprop("/systems/failures/fac2", 0);
	setprop("/systems/failures/aileron-left", 0);
	setprop("/systems/failures/aileron-right", 0);
	setprop("/systems/failures/elevator-left", 0);
	setprop("/systems/failures/elevator-right", 0);
	setprop("/systems/failures/rudder", 0);
	setprop("/systems/failures/spoiler-l1", 0);
	setprop("/systems/failures/spoiler-l2", 0);
	setprop("/systems/failures/spoiler-l3", 0);
	setprop("/systems/failures/spoiler-l4", 0);
	setprop("/systems/failures/spoiler-l5", 0);
	setprop("/systems/failures/spoiler-r1", 0);
	setprop("/systems/failures/spoiler-r2", 0);
	setprop("/systems/failures/spoiler-r3", 0);
	setprop("/systems/failures/spoiler-r4", 0);
	setprop("/systems/failures/spoiler-r5", 0);
	setprop("/systems/failures/elec-ac-ess", 0);
	setprop("/systems/failures/elec-batt1", 0);
	setprop("/systems/failures/elec-batt2", 0);
	setprop("/systems/failures/elec-galley", 0);
	setprop("/systems/failures/elec-genapu", 0);
	setprop("/systems/failures/elec-gen1", 0);
	setprop("/systems/failures/elec-gen2", 0);
	setprop("/systems/failures/bleed-apu", 0);
	setprop("/systems/failures/bleed-ext", 0);
	setprop("/systems/failures/bleed-eng1", 0);
	setprop("/systems/failures/bleed-eng2", 0);
	setprop("/systems/failures/pack1", 0);
	setprop("/systems/failures/pack2", 0);
	setprop("/systems/failures/hyd-blue", 0);
	setprop("/systems/failures/hyd-green", 0);
	setprop("/systems/failures/hyd-yellow", 0);
	setprop("/systems/failures/ptu", 0);
	setprop("/systems/failures/pump-blue", 0);
	setprop("/systems/failures/pump-green", 0);
	setprop("/systems/failures/pump-yellow-eng", 0);
	setprop("/systems/failures/pump-yellow-elec", 0);
	setprop("/systems/failures/tank0pump1", 0);
	setprop("/systems/failures/tank0pump2", 0);
	setprop("/systems/failures/tank1pump1", 0);
	setprop("/systems/failures/tank1pump2", 0);
	setprop("/systems/failures/tank2pump1", 0);
	setprop("/systems/failures/tank2pump2", 0);
	setprop("/systems/failures/fuelmode", 0);
	setprop("/systems/failures/cargo-aft-fire", 0);
	setprop("/systems/failures/cargo-fwd-fire", 0);
	setprop("/systems/failures/engine-left-fire", 0);
	setprop("/systems/failures/engine-right-fire", 0);
}

failResetOld();
setprop("/systems/acconfig/autoconfig-running", 0);
setprop("/systems/acconfig/spinning", 0);
setprop("/systems/acconfig/spin", "-");
setprop("/systems/acconfig/options/revision", 0);
setprop("/systems/acconfig/new-revision", 0);
setprop("/systems/acconfig/out-of-date", 0);
setprop("/systems/acconfig/mismatch-code", "0x000");
setprop("/systems/acconfig/mismatch-reason", "XX");
setprop("/systems/acconfig/options/keyboard-mode", 0);
# TODO Revert default weight-kgs to 1, when fully implemented
setprop("/systems/acconfig/options/weight-kgs", 0);
setprop("/systems/acconfig/options/adirs-skip", 0);
setprop("/systems/acconfig/options/welcome-skip", 0);
setprop("/systems/acconfig/options/no-rendering-warn", 0);
setprop("/systems/acconfig/options/pfd-rate", 1);
setprop("/systems/acconfig/options/nd-rate", 1);
setprop("/systems/acconfig/options/uecam-rate", 1);
setprop("/systems/acconfig/options/lecam-rate", 1);
setprop("/systems/acconfig/options/iesi-rate", 1);
setprop("/systems/acconfig/options/autopush/show-route", 1);
setprop("/systems/acconfig/options/autopush/show-wingtip", 1);
var main_dlg = gui.Dialog.new("sim/gui/dialogs/acconfig/main/dialog", "Aircraft/A320-family/AircraftConfig/main.xml");
var welcome_dlg = gui.Dialog.new("sim/gui/dialogs/acconfig/welcome/dialog", "Aircraft/A320-family/AircraftConfig/welcome.xml");
var ps_load_dlg = gui.Dialog.new("sim/gui/dialogs/acconfig/psload/dialog", "Aircraft/A320-family/AircraftConfig/psload.xml");
var ps_loaded_dlg = gui.Dialog.new("sim/gui/dialogs/acconfig/psloaded/dialog", "Aircraft/A320-family/AircraftConfig/psloaded.xml");
var init_dlg = gui.Dialog.new("sim/gui/dialogs/acconfig/init/dialog", "Aircraft/A320-family/AircraftConfig/ac_init.xml");
var help_dlg = gui.Dialog.new("sim/gui/dialogs/acconfig/help/dialog", "Aircraft/A320-family/AircraftConfig/help.xml");
var fbw_dlg = gui.Dialog.new("sim/gui/dialogs/acconfig/fbw/dialog", "Aircraft/A320-family/AircraftConfig/fbw.xml");
var fail_dlg = gui.Dialog.new("sim/gui/dialogs/acconfig/fail/dialog", "Aircraft/A320-family/AircraftConfig/fail.xml");
var about_dlg = gui.Dialog.new("sim/gui/dialogs/acconfig/about/dialog", "Aircraft/A320-family/AircraftConfig/about.xml");
var update_dlg = gui.Dialog.new("sim/gui/dialogs/acconfig/update/dialog", "Aircraft/A320-family/AircraftConfig/update.xml");
var updated_dlg = gui.Dialog.new("sim/gui/dialogs/acconfig/updated/dialog", "Aircraft/A320-family/AircraftConfig/updated.xml");
var error_mismatch = gui.Dialog.new("sim/gui/dialogs/acconfig/error/mismatch/dialog", "Aircraft/A320-family/AircraftConfig/error-mismatch.xml");
var fuel_dlg = gui.Dialog.new("sim/gui/dialogs/acconfig/fuel/dialog", "Aircraft/A320-family/AircraftConfig/fuel.xml");
var groundservices_dlg = gui.Dialog.new("sim/gui/dialogs/acconfig/groundsrvc/dialog", "Aircraft/A320-family/AircraftConfig/groundservices.xml");
var du_quality = gui.Dialog.new("sim/gui/dialogs/acconfig/du-quality/dialog", "Aircraft/A320-family/AircraftConfig/du-quality.xml");
var rendering_dlg = gui.Dialog.new("sim/gui/dialogs/rendering/dialog", "Aircraft/A320-family/AircraftConfig/rendering.xml");
spinning.start();
init_dlg.open();
http.load("https://raw.githubusercontent.com/legoboyvdlp/A320-family/201912/revision.txt").done(func(r) setprop("/systems/acconfig/new-revision", r.response));
var revisionFile = (getprop("/sim/aircraft-dir") ~ "/revision.txt");
var current_revision = io.readfile(revisionFile);
print("A320-family Revision: " ~ current_revision);
setprop("/systems/acconfig/revision", current_revision);

setlistener("/systems/acconfig/new-revision", func {
	if (getprop("/systems/acconfig/new-revision") > current_revision) {
		setprop("/systems/acconfig/out-of-date", 1);
	} else {
		setprop("/systems/acconfig/out-of-date", 0);
	}
});

var mismatch_chk = func {
	if (num(string.replace(getprop("/sim/version/flightgear"),".","")) < 201912) {
		setprop("/systems/acconfig/mismatch-code", "0x121");
		setprop("/systems/acconfig/mismatch-reason", "FGFS version is too old! Please update FlightGear to at least 2019.1.2.");
		if (getprop("/systems/acconfig/out-of-date") != 1) {
			error_mismatch.open();
		}
		libraries.systemsLoop.stop();
		print("Mismatch: 0x121");
		welcome_dlg.close();
	} else if (getprop("/gear/gear[0]/wow") == 0 or getprop("/position/altitude-ft") >= 15000) {
		setprop("/systems/acconfig/mismatch-code", "0x223");
		setprop("/systems/acconfig/mismatch-reason", "Preposterous configuration detected for initialization. Check your position or scenery.");
		if (getprop("/systems/acconfig/out-of-date") != 1) {
			error_mismatch.open();
		}
		libraries.systemsLoop.stop();
		print("Mismatch: 0x223");
		welcome_dlg.close();
	} else if (getprop("/systems/acconfig/libraries-loaded") != 1) {
		setprop("/systems/acconfig/mismatch-code", "0x247");
		setprop("/systems/acconfig/mismatch-reason", "System files are missing or damaged. Please download a new copy of the aircraft.");
		if (getprop("/systems/acconfig/out-of-date") != 1) {
			error_mismatch.open();
		}
		libraries.systemsLoop.stop();
		print("Mismatch: 0x247");
		welcome_dlg.close();
	}
}

setlistener("/sim/signals/fdm-initialized", func {
	init_dlg.close();
	if (getprop("/systems/acconfig/out-of-date") == 1) {
		update_dlg.open();
		print("System: The A320-family is out of date!");
	} 
	mismatch_chk();
	readSettings();
	if (getprop("/systems/acconfig/out-of-date") != 1 and getprop("/systems/acconfig/options/revision") < current_revision and getprop("/systems/acconfig/mismatch-code") == "0x000") {
		updated_dlg.open();
		if (getprop("/systems/acconfig/options/no-rendering-warn") != 1) {
			renderingSettings.check();
		}
	} else if (getprop("/systems/acconfig/out-of-date") != 1 and getprop("/systems/acconfig/mismatch-code") == "0x000" and getprop("/systems/acconfig/options/welcome-skip") != 1) {
		welcome_dlg.open();
		if (getprop("/systems/acconfig/options/no-rendering-warn") != 1) {
			renderingSettings.check();
		}
	}
	setprop("/systems/acconfig/options/revision", current_revision);
	writeSettings();
	spinning.stop();
});

var renderingSettings = {
	check: func() {
		var rembrandt = getprop("/sim/rendering/rembrandt/enabled");
		var ALS = getprop("/sim/rendering/shaders/skydome");
		var customSettings = getprop("/sim/rendering/shaders/custom-settings") == 1;
		var landmass = getprop("/sim/rendering/shaders/landmass") >= 4;
		var model = getprop("/sim/rendering/shaders/model") >= 2;
		if (!rembrandt and (!ALS or !customSettings or !landmass or !model)) {
			rendering_dlg.open();
		}
	},
	fixAll: func() {
		me.fixCore();
		var landmass = getprop("/sim/rendering/shaders/landmass") >= 4;
		var model = getprop("/sim/rendering/shaders/model") >= 2;
		if (!landmass) {
			setprop("/sim/rendering/shaders/landmass", 4);
		}
		if (!model) {
			setprop("/sim/rendering/shaders/model", 2);
		}
	},
	fixCore: func() {
		setprop("/sim/rendering/shaders/skydome", 1); # ALS on
		setprop("/sim/rendering/shaders/custom-settings", 1);
		gui.popupTip("Rendering Settings updated!");
	},
};

var readSettings = func {
	io.read_properties(getprop("/sim/fg-home") ~ "/Export/A320-family-config.xml", "/systems/acconfig/options");
	setprop("/options/system/keyboard-mode", getprop("/systems/acconfig/options/keyboard-mode"));
	setprop("/options/system/weight-kgs", getprop("/systems/acconfig/options/weight-kgs"));
	setprop("/controls/adirs/skip", getprop("/systems/acconfig/options/adirs-skip"));
	setprop("/sim/model/autopush/route/show", getprop("/systems/acconfig/options/autopush/show-route"));
	setprop("/sim/model/autopush/route/show-wingtip", getprop("/systems/acconfig/options/autopush/show-wingtip"));
	
}

var writeSettings = func {
	setprop("/systems/acconfig/options/keyboard-mode", getprop("/options/system/keyboard-mode"));
	setprop("/systems/acconfig/options/weight-kgs", getprop("/options/system/weight-kgs"));
	setprop("/systems/acconfig/options/adirs-skip", getprop("/controls/adirs/skip"));
	setprop("/systems/acconfig/options/autopush/show-route", getprop("/sim/model/autopush/route/show"));
	setprop("/systems/acconfig/options/autopush/show-wingtip", getprop("/sim/model/autopush/route/show-wingtip"));
	io.write_properties(getprop("/sim/fg-home") ~ "/Export/A320-family-config.xml", "/systems/acconfig/options");
}

################
# Panel States #
################

# Cold and Dark
var colddark = func {
	if (getprop("/systems/acconfig/mismatch-code") == "0x000") {
		spinning.start();
		ps_loaded_dlg.close();
		ps_load_dlg.open();
		setprop("/systems/acconfig/autoconfig-running", 1);
		setprop("/controls/gear/brake-left", 1);
		setprop("/controls/gear/brake-right", 1);
		# Initial shutdown, and reinitialization.
		setprop("/controls/engines/engine-start-switch", 1);
		setprop("/controls/engines/engine[0]/cutoff-switch", 1);
		setprop("/controls/engines/engine[1]/cutoff-switch", 1);
		setprop("/controls/flight/slats", 0.000);
		setprop("/controls/flight/flaps", 0.000);
		setprop("/controls/flight/flap-lever", 0);
		setprop("/controls/flight/flap-pos", 0);
		setprop("/controls/flight/flap-txt", " ");
		libraries.flaptimer.stop();
		setprop("/controls/flight/speedbrake-arm", 0);
		setprop("/controls/flight/speedbrake", 0);
		setprop("/controls/gear/gear-down", 1);
		setprop("/controls/flight/elevator-trim", 0);
		setprop("/controls/switches/beacon", 0);
		setprop("/controls/switches/strobe", 0.0);
		setprop("/controls/switches/wing-lights", 0);
		setprop("/controls/lighting/nav-lights-switch", 0);
		setprop("/controls/lighting/turnoff-light-switch", 0);
		setprop("/controls/lighting/taxi-light-switch", 0.0);
		setprop("/controls/switches/landing-lights-l", 0.0);
		setprop("/controls/switches/landing-lights-r", 0.0);
		setprop("/controls/atc/mode-knob", 0);
		setprop("/controls/lighting/fcu-panel-knb", 0);
		setprop("/controls/lighting/main-panel-knb", 0);
		setprop("/controls/lighting/overhead-panel-knb", 0);
		atc.transponderPanel.modeSwitch(1);
		libraries.systemsInit();
		failResetOld();
		if (getprop("/engines/engine[1]/n2-actual") < 2) {
			colddark_b();
		} else {
			var colddark_eng_off = setlistener("/engines/engine[1]/n2-actual", func {
				if (getprop("/engines/engine[1]/n2-actual") < 2) {
					removelistener(colddark_eng_off);
					colddark_b();
				}
			});
		}
	}
}
var colddark_b = func {
	# Continues the Cold and Dark script, after engines fully shutdown.
	setprop("/controls/APU/master", 0);
	setprop("/controls/APU/start", 0);
	settimer(func {
		setprop("/controls/gear/brake-left", 0);
		setprop("/controls/gear/brake-right", 0);
		setprop("/systems/acconfig/autoconfig-running", 0);
		ps_load_dlg.close();
		ps_loaded_dlg.open();
		spinning.stop();
	}, 2);
}

# Ready to Start Eng
var beforestart = func {
	if (getprop("/systems/acconfig/mismatch-code") == "0x000") {
		spinning.start();
		ps_loaded_dlg.close();
		ps_load_dlg.open();
		setprop("/systems/acconfig/autoconfig-running", 1);
		setprop("/controls/gear/brake-left", 1);
		setprop("/controls/gear/brake-right", 1);
		# First, we set everything to cold and dark.
		setprop("/controls/engines/engine-start-switch", 1);
		setprop("/controls/engines/engine[0]/cutoff-switch", 1);
		setprop("/controls/engines/engine[1]/cutoff-switch", 1);
		setprop("/controls/flight/slats", 0.000);
		setprop("/controls/flight/flaps", 0.000);
		setprop("/controls/flight/flap-lever", 0);
		setprop("/controls/flight/flap-pos", 0);
		setprop("/controls/flight/flap-txt", " ");
		libraries.flaptimer.stop();
		setprop("/controls/flight/speedbrake-arm", 0);
		setprop("/controls/flight/speedbrake", 0);
		setprop("/controls/gear/gear-down", 1);
		setprop("/controls/flight/elevator-trim", 0);
		libraries.systemsInit();
		failResetOld();
		setprop("/controls/APU/master", 0);
		setprop("/controls/APU/start", 0);
		
		# Now the Startup!
		props.globals.getNode("/controls/electrical/switches/bat-1").setValue(1);
		props.globals.getNode("/controls/electrical/switches/bat-2").setValue(1);
		setprop("/controls/APU/master", 1);
		setprop("/controls/APU/start", 1);
		var apu_rpm_chk = setlistener("/systems/apu/rpm", func {
			if (getprop("/systems/apu/rpm") >= 98) {
				removelistener(apu_rpm_chk);
				beforestart_b();
			}
		});
	}
}
var beforestart_b = func {
	# Continue with engine start prep.
	systems.FUEL.Switches.pumpLeft1.setValue(1);
	systems.FUEL.Switches.pumpLeft2.setValue(1);
	systems.FUEL.Switches.pumpCenter1.setValue(1);
	systems.FUEL.Switches.pumpCenter2.setValue(1);
	systems.FUEL.Switches.pumpRight1.setValue(1);
	systems.FUEL.Switches.pumpRight2.setValue(1);
	setprop("/controls/lighting/fcu-panel-knb", 1);
	setprop("/controls/lighting/main-panel-knb", 1);
	setprop("/controls/lighting/overhead-panel-knb", 1);
	setprop("/controls/electrical/switches/apu", 1);
	setprop("/controls/electrical/switches/galley", 1);
	setprop("/controls/electrical/switches/gen-1", 1);
	setprop("/controls/electrical/switches/gen-2", 1);
	setprop("/controls/pneumatic/switches/bleedapu", 1);
	setprop("/controls/pneumatic/switches/bleed1", 1);
	setprop("/controls/pneumatic/switches/bleed2", 1);
	setprop("/controls/pneumatic/switches/pack1", 1);
	setprop("/controls/pneumatic/switches/pack2", 1);
	setprop("/controls/adirs/ir[0]/knob","1");
	setprop("/controls/adirs/ir[1]/knob","1");
	setprop("/controls/adirs/ir[2]/knob","1");
	if (systems.ADIRSnew.Switches.adrSw[0].getValue() != 1) { systems.ADIRSControlPanel.adrSw(0); }
	if (systems.ADIRSnew.Switches.adrSw[1].getValue() != 1) { systems.ADIRSControlPanel.adrSw(1); }
	if (systems.ADIRSnew.Switches.adrSw[2].getValue() != 1) { systems.ADIRSControlPanel.adrSw(2); }
	systems.ADIRSControlPanel.irModeSw(0, 1);
	systems.ADIRSControlPanel.irModeSw(1, 1);
	systems.ADIRSControlPanel.irModeSw(2, 1);
	systems.ADIRSnew.ADIRunits[0].instAlign();
	systems.ADIRSnew.ADIRunits[1].instAlign();
	systems.ADIRSnew.ADIRunits[2].instAlign();
	setprop("/controls/adirs/mcducbtn", 1);
	setprop("/controls/switches/beacon", 1);
	setprop("/controls/lighting/nav-lights-switch", 1);
	setprop("/controls/radio/rmp[0]/on", 1);
	setprop("/controls/radio/rmp[1]/on", 1);
	setprop("/controls/radio/rmp[2]/on", 1);
	setprop("/systems/fadec/power-avail", 1);
	setprop("/systems/fadec/powered-time", -310);
	settimer(func {
		setprop("/controls/gear/brake-left", 0);
		setprop("/controls/gear/brake-right", 0);
		setprop("/systems/acconfig/autoconfig-running", 0);
		ps_load_dlg.close();
		ps_loaded_dlg.open();
		spinning.stop();
	}, 2);
}

# Ready to Taxi
var taxi = func {
	if (getprop("/systems/acconfig/mismatch-code") == "0x000") {
		spinning.start();
		ps_loaded_dlg.close();
		ps_load_dlg.open();
		setprop("/systems/acconfig/autoconfig-running", 1);
		setprop("/controls/gear/brake-left", 1);
		setprop("/controls/gear/brake-right", 1);
		# First, we set everything to cold and dark.
		setprop("/controls/engines/engine-start-switch", 1);
		setprop("/controls/engines/engine[0]/cutoff-switch", 1);
		setprop("/controls/engines/engine[1]/cutoff-switch", 1);
		setprop("/controls/flight/slats", 0.000);
		setprop("/controls/flight/flaps", 0.000);
		setprop("/controls/flight/flap-lever", 0);
		setprop("/controls/flight/flap-pos", 0);
		setprop("/controls/flight/flap-txt", " ");
		libraries.flaptimer.stop();
		setprop("/controls/flight/speedbrake-arm", 0);
		setprop("/controls/flight/speedbrake", 0);
		setprop("/controls/gear/gear-down", 1);
		setprop("/controls/flight/elevator-trim", 0);
		libraries.systemsInit();
		failResetOld();
		setprop("/controls/APU/master", 0);
		setprop("/controls/APU/start", 0);
		
		# Now the Startup!
		props.globals.getNode("/controls/electrical/switches/bat-1").setValue(1);
		props.globals.getNode("/controls/electrical/switches/bat-2").setValue(1);
		setprop("/controls/APU/master", 1);
		setprop("/controls/APU/start", 1);
		var apu_rpm_chk = setlistener("/systems/apu/rpm", func {
			if (getprop("/systems/apu/rpm") >= 98) {
				removelistener(apu_rpm_chk);
				taxi_b();
			}
		});
	}
}
var taxi_b = func {
	# Continue with engine start prep, and start engines.
	systems.FUEL.Switches.pumpLeft1.setValue(1);
	systems.FUEL.Switches.pumpLeft2.setValue(1);
	systems.FUEL.Switches.pumpCenter1.setValue(1);
	systems.FUEL.Switches.pumpCenter2.setValue(1);
	systems.FUEL.Switches.pumpRight1.setValue(1);
	systems.FUEL.Switches.pumpRight2.setValue(1);
	setprop("/controls/lighting/fcu-panel-knb", 1);
	setprop("/controls/lighting/main-panel-knb", 1);
	setprop("/controls/lighting/overhead-panel-knb", 1);
	setprop("/controls/electrical/switches/apu", 1);
	setprop("/controls/electrical/switches/galley", 1);
	setprop("/controls/electrical/switches/gen-1", 1);
	setprop("/controls/electrical/switches/gen-2", 1);
	setprop("/controls/pneumatic/switches/bleedapu", 1);
	setprop("/controls/pneumatic/switches/bleed1", 1);
	setprop("/controls/pneumatic/switches/bleed2", 1);
	setprop("/controls/pneumatic/switches/pack1", 1);
	setprop("/controls/pneumatic/switches/pack2", 1);
	setprop("/controls/adirs/ir[0]/knob","1");
	setprop("/controls/adirs/ir[1]/knob","1");
	setprop("/controls/adirs/ir[2]/knob","1");
	if (systems.ADIRSnew.Switches.adrSw[0].getValue() != 1) { systems.ADIRSControlPanel.adrSw(0); }
	if (systems.ADIRSnew.Switches.adrSw[1].getValue() != 1) { systems.ADIRSControlPanel.adrSw(1); }
	if (systems.ADIRSnew.Switches.adrSw[2].getValue() != 1) { systems.ADIRSControlPanel.adrSw(2); }
	systems.ADIRSControlPanel.irModeSw(0, 1);
	systems.ADIRSControlPanel.irModeSw(1, 1);
	systems.ADIRSControlPanel.irModeSw(2, 1);
	systems.ADIRSnew.ADIRunits[0].instAlign();
	systems.ADIRSnew.ADIRunits[1].instAlign();
	systems.ADIRSnew.ADIRunits[2].instAlign();
	setprop("/controls/adirs/mcducbtn", 1);
	setprop("/controls/switches/beacon", 1);
	setprop("/controls/switches/wing-lights", 1);
	setprop("/controls/lighting/nav-lights-switch", 1);
	setprop("/controls/radio/rmp[0]/on", 1);
	setprop("/controls/radio/rmp[1]/on", 1);
	setprop("/controls/radio/rmp[2]/on", 1);
	setprop("/controls/atc/mode-knob", 2);
	atc.transponderPanel.modeSwitch(3);
	setprop("/systems/fadec/power-avail", 1);
	setprop("/systems/fadec/powered-time", -310);
	setprop("/controls/lighting/turnoff-light-switch", 1);
	setprop("/controls/lighting/taxi-light-switch", 0.5);
	setprop("/controls/switches/landing-lights-l", 0.5);
	setprop("/controls/switches/landing-lights-r", 0.5);
	settimer(taxi_c, 2);
}
var taxi_c = func {
	setprop("/controls/engines/engine-start-switch", 2);
	setprop("/controls/engines/engine[0]/cutoff-switch", 0);
	setprop("/controls/engines/engine[1]/cutoff-switch", 0);
	settimer(func {
		taxi_d();
	}, 10);
}
var taxi_d = func {
	# After Start items.
	setprop("/controls/engines/engine-start-switch", 1);
	setprop("/controls/APU/master", 0);
	setprop("/controls/APU/start", 0);
	setprop("/controls/pneumatic/switches/bleedapu", 0);
	setprop("/controls/gear/brake-left", 0);
	setprop("/controls/gear/brake-right", 0);
	setprop("/systems/acconfig/autoconfig-running", 0);
	ps_load_dlg.close();
	ps_loaded_dlg.open();
	spinning.stop();
}

# Ready to Takeoff
var takeoff = func {
	if (getprop("/systems/acconfig/mismatch-code") == "0x000") {
		# The same as taxi, except we set some things afterwards.
		taxi();
		var eng_one_chk_c = setlistener("/engines/engine[0]/state", func {
			if (getprop("/engines/engine[0]/state") == 3) {
				removelistener(eng_one_chk_c);
				setprop("/controls/switches/strobe", 1.0);
				setprop("/controls/lighting/taxi-light-switch", 1);
				setprop("/controls/switches/landing-lights-l", 1);
				setprop("/controls/switches/landing-lights-r", 1);
				setprop("/controls/flight/speedbrake-arm", 1);
				setprop("/controls/flight/flaps", 0.290);
				setprop("/controls/flight/slats", 0.666);
				setprop("/controls/flight/flap-lever", 1);
				setprop("/controls/flight/flap-pos", 2);
				setprop("/controls/flight/flap-txt", "1+F");
				setprop("/controls/atc/mode-knob", 4);
				atc.transponderPanel.modeSwitch(5);
				libraries.flaptimer.start();
				setprop("/controls/flight/elevator-trim", -0.07);
				systems.arm_autobrake(3);
				setprop("/ECAM/to-config-test", 1);
				settimer(func {
					setprop("/ECAM/to-config-test", 0);
				}, 1);
			}
		});
	}
}
