# A3XX IAE V2500 Engine
# Joshua Davidson (Octal450)

# Copyright (c) 2020 Josh Davidson (Octal450)

#####################
# Initializing Vars #
#####################

var engines = props.globals.getNode("engines").getChildren("engine");
var egt_min = 434;
var egt_start = 587;
var egt_max = 712;
var start_time = 10;
var egt_lightup_time = 4;
var egt_lightdn_time = 10;
var shutdown_time = 20;
var egt_shutdown_time = 20;

var eng_init = func {
	eng_common_init();
}

# Trigger Startups and Stops
setlistener("/controls/engines/engine[0]/cutoff-switch", func {
	if (!pts.Controls.Engines.Engine.cutoffSw[0].getValue()) {
		if (pts.Acconfig.running.getValue()) {
			fast_start_one();
		} else {
			if (!manStart[0].getValue()) {
				start_one_check();
			} else {
				eng_one_man_start.start();
			}
		}
	} else if (pts.Controls.Engines.Engine.cutoffSw[0].getValue()) {
		cutoff_one();
	}
}, 0, 0);

var cutoff_one = func {
	eng_one_auto_start.stop();
	eng_one_man_start.stop();
	eng_one_n2_check.stop();
	igniterA[0].setValue(0);
	igniterB[0].setValue(0);
	manStart[0].setValue(0);
	systems.PNEU.Valves.starter1.setValue(0);
	pts.Controls.Engines.Engine.starter[0].setValue(0);
	pts.Controls.Engines.Engine.cutoff[0].setValue(1);
	pts.Engines.Engine.state[0].setValue(0);
	interpolate(engines[0].getNode("egt-actual"), 0, egt_shutdown_time);
	eng_one_n2_check.stop();
}

var fast_start_one = func {
	pts.Controls.Engines.Engine.cutoff[0].setValue(0);
	setprop("/engines/engine[0]/out-of-fuel", 0);
	setprop("/engines/engine[0]/run", 1);

	setprop("/engines/engine[0]/cutoff", 0);
	setprop("/engines/engine[0]/starter", 0);

	setprop("/fdm/jsbsim/propulsion/set-running", 0);
	
	pts.Engines.Engine.state[0].setValue(3);
	systems.PNEU.Valves.starter1.setValue(0);
}

setlistener("/controls/engines/engine[0]/man-start", func {
	start_one_mancheck();
}, 0, 0);

var start_one_mancheck = func {
	if (manStart[0].getValue()) {
		if (pts.Controls.Engines.startSw.getValue() == 2 and (pts.Controls.Engines.Engine.cutoffSw[0].getValue() == 1)) {
			systems.PNEU.Valves.starter1.setValue(1);
			settimer(start_one_mancheck_b, 0.5);
		}
	} else {
		if (pts.Engines.Engine.state[0].getValue() == 1 or pts.Engines.Engine.state[0].getValue() == 2) {
			systems.PNEU.Valves.starter1.setValue(0);
			pts.Engines.Engine.state[0].setValue(0);
			pts.Controls.Engines.Engine.starter[0].setValue(0);
		}
	}
}

var start_one_mancheck_b = func {
	if (systems.PNEU.Psi.engine1.getValue() >= 25) {
		pts.Engines.Engine.state[0].setValue(1);
		pts.Controls.Engines.Engine.starter[0].setValue(1);
	}
}

var start_one_check = func {
	if (pts.Controls.Engines.startSw.getValue() == 2 and pts.Controls.Engines.Engine.cutoffSw[0].getValue() == 0) {
		systems.PNEU.Valves.starter1.setValue(1);
		settimer(start_one_check_b, 0.5);
	}
}

var start_one_check_b = func {
	if (pts.Controls.Engines.startSw.getValue() == 2 and systems.PNEU.Psi.engine1.getValue() >= 25and !pts.Controls.Engines.Engine.cutoffSw[0].getValue()) {
		auto_start_one();
	}
}

setlistener("/controls/engines/engine[1]/cutoff-switch", func {
	if (!pts.Controls.Engines.Engine.cutoffSw[1].getValue()) {
		if (pts.Acconfig.running.getValue()) {
			fast_start_two();
		} else {
			if (!manStart[1].getValue()) {
				start_two_check();
			} else {
				eng_two_man_start.start();
			}
		}
	} else if (pts.Controls.Engines.Engine.cutoffSw[1].getValue()) {
		cutoff_two();
	}
}, 0, 0);

var cutoff_two = func {
	eng_two_auto_start.stop();
	eng_two_man_start.stop();
	eng_two_n2_check.stop();
	igniterA[1].setValue(0);
	igniterB[1].setValue(0);
	manStart[1].setValue(0);
	systems.PNEU.Valves.starter2.setValue(0);
	pts.Controls.Engines.Engine.starter[1].setValue(0);
	pts.Controls.Engines.Engine.cutoff[1].setValue(1);
	pts.Engines.Engine.state[1].setValue(0);
	interpolate(engines[1].getNode("egt-actual"), 0, egt_shutdown_time);
}

var fast_start_two = func {
	pts.Controls.Engines.Engine.cutoff[1].setValue(0);
	setprop("/engines/engine[1]/out-of-fuel", 0);
	setprop("/engines/engine[1]/run", 1);

	setprop("/engines/engine[1]/cutoff", 0);
	setprop("/engines/engine[1]/starter", 0);

	setprop("/fdm/jsbsim/propulsion/set-running", 1);
	
	pts.Engines.Engine.state[1].setValue(3);
	systems.PNEU.Valves.starter2.setValue(0);
}

setlistener("/controls/engines/engine[1]/man-start", func {
	start_two_mancheck();
}, 0, 0);

var start_two_mancheck = func {
	if (manStart[1].getValue() == 1) {
		if (pts.Controls.Engines.startSw.getValue() == 2 and (pts.Controls.Engines.Engine.cutoffSw[1].getValue() == 1)) {
			systems.PNEU.Valves.starter2.setValue(1);
			settimer(start_two_mancheck_b, 0.5);
		}
	} else {
		if (pts.Engines.Engine.state[1].getValue() == 1 or pts.Engines.Engine.state[1].getValue() == 2) {
			systems.PNEU.Valves.starter2.setValue(0);
			pts.Engines.Engine.state[1].setValue(0);
			pts.Controls.Engines.Engine.starter[1].setValue(0);
		}
	}
}

var start_two_mancheck_b = func {
	if (systems.PNEU.Psi.engine2.getValue() >= 25) {
		pts.Engines.Engine.state[1].setValue(1);
		pts.Controls.Engines.Engine.starter[1].setValue(1);
	}
}

var start_two_check = func {
	if (pts.Controls.Engines.startSw.getValue() == 2 and pts.Controls.Engines.Engine.cutoffSw[1].getValue() == 0) {
		systems.PNEU.Valves.starter2.setValue(1);
		settimer(start_two_check_b, 0.5);
	}
}

var start_two_check_b = func {
	if (pts.Controls.Engines.startSw.getValue() == 2 and systems.PNEU.Psi.engine2.getValue() >= 25 and !pts.Controls.Engines.Engine.cutoffSw[1].getValue()) {
		auto_start_two();
	}
}

# Start Engine One
var auto_start_one = func {
	pts.Engines.Engine.state[0].setValue(1);
	pts.Controls.Engines.Engine.starter[0].setValue(1);
	eng_one_auto_start.start();
}

var eng_one_auto_start = maketimer(0.5, func {
	if (pts.Engines.Engine.n2Actual[0].getValue() >= 22) {
		eng_one_auto_start.stop();
		pts.Engines.Engine.state[0].setValue(2);
		pts.Controls.Engines.Engine.cutoff[0].setValue(0);
		if (lastIgniter[0].getValue() == "B") {
			igniterA[0].setValue(1);
			igniterB[0].setValue(0);
			lastIgniter[0].setValue("A");
		} else if (lastIgniter[0].getValue() == "A") {
			igniterA[0].setValue(0);
			igniterB[0].setValue(1);
			lastIgniter[0].setValue("B");
		}
		interpolate(engines[0].getNode("egt-actual"), egt_start, egt_lightup_time);
		eng_one_egt_check.start();
		eng_one_n2_check.start();
	}
});

var eng_one_man_start = maketimer(0.5, func {
	if (pts.Engines.Engine.n2Actual[0].getValue() >= 16.7) {
		eng_one_man_start.stop();
		pts.Engines.Engine.state[0].setValue(2);
		pts.Controls.Engines.Engine.cutoff[0].setValue(0);
		igniterA[0].setValue(1);
		igniterB[0].setValue(1);
		interpolate(engines[0].getNode("egt-actual"), egt_start, egt_lightup_time);
		eng_one_egt_check.start();
		eng_one_n2_check.start();
	}
});

var eng_one_egt_check = maketimer(0.5, func {
	if (pts.Engines.Engine.egtActual[0].getValue() >= egt_start) {
		eng_one_egt_check.stop();
		interpolate(engines[0].getNode("egt-actual"), egt_min, egt_lightdn_time);
	}
}); 

var eng_one_n2_check = maketimer(0.5, func {
	if (pts.Engines.Engine.n2Actual[0].getValue() >= 43.0) {
		if (igniterA[0].getValue() != 0) {
			igniterA[0].setValue(0);
		}
		if (igniterB[0].getValue() != 0) {
			igniterB[0].setValue(0);
		}
	}
	if (pts.Engines.Engine.n2Actual[0].getValue() >= 57.0) {
		eng_one_n2_check.stop();
		systems.PNEU.Valves.starter1.setValue(0);
		pts.Engines.Engine.state[0].setValue(3);
	}
});

# Start Engine Two
var auto_start_two = func {
	pts.Engines.Engine.state[1].setValue(1);
	pts.Controls.Engines.Engine.starter[1].setValue(1);
	eng_two_auto_start.start();
}

var eng_two_auto_start = maketimer(0.5, func {
	if (pts.Engines.Engine.n2Actual[1].getValue() >= 22) {
		eng_two_auto_start.stop();
		pts.Engines.Engine.state[1].setValue(2);
		pts.Controls.Engines.Engine.cutoff[1].setValue(0);
		if (lastIgniter[1].getValue() == "B") {
			igniterA[1].setValue(1);
			igniterB[1].setValue(0);
			lastIgniter[1].setValue("A");
		} else if (lastIgniter[1].getValue() == "A") {
			igniterA[1].setValue(0);
			igniterB[1].setValue(1);
			lastIgniter[1].setValue("B");
		}
		interpolate(engines[1].getNode("egt-actual"), egt_start, egt_lightup_time);
		eng_two_egt_check.start();
		eng_two_n2_check.start();
	}
});

var eng_two_man_start = maketimer(0.5, func {
	if (pts.Engines.Engine.n2Actual[1].getValue() >= 16.7) {
		eng_two_man_start.stop();
		pts.Engines.Engine.state[1].setValue(2);
		pts.Controls.Engines.Engine.cutoff[1].setValue(0);
		igniterA[1].setValue(1);
		igniterB[1].setValue(1);
		interpolate(engines[1].getNode("egt-actual"), egt_start, egt_lightup_time);
		eng_two_egt_check.start();
		eng_two_n2_check.start();
	}
});

var eng_two_egt_check = maketimer(0.5, func {
	if (pts.Engines.Engine.egtActual[1].getValue() >= egt_start) {
		eng_two_egt_check.stop();
		interpolate(engines[1].getNode("egt-actual"), egt_min, egt_lightdn_time);
	}
});

var eng_two_n2_check = maketimer(0.5, func {
	if (pts.Engines.Engine.n2Actual[1].getValue() >= 50.0) {
		if (igniterA[1].getValue() != 0) {
			igniterA[1].setValue(0);
		}
		if (igniterB[1].getValue() != 0) {
			igniterB[1].setValue(0);
		}
	}
	if (pts.Engines.Engine.n2Actual[1].getValue() >= 57.0) {
		eng_two_n2_check.stop();
		systems.PNEU.Valves.starter2.setValue(0);
		pts.Engines.Engine.state[1].setValue(3);
	}
});

# Various Other Stuff
setlistener("/controls/engines/engine-start-switch", func {
	if (pts.Engines.Engine.state[0].getValue() == 0) {
		start_one_check();
		start_one_mancheck();
	}
	if (pts.Engines.Engine.state[1].getValue() == 0) {
		start_two_check();
		start_two_mancheck();
	}
	if ((pts.Controls.Engines.startSw.getValue() == 0) or (pts.Controls.Engines.startSw.getValue() == 1)) {
		if (pts.Engines.Engine.state[0].getValue() == 1 or pts.Engines.Engine.state[0].getValue() == 2) {
			pts.Controls.Engines.Engine.starter[0].setValue(0);
			pts.Controls.Engines.Engine.cutoff[0].setValue(1);
			systems.PNEU.Valves.starter1.setValue(0);
			pts.Engines.Engine.state[0].setValue(0);
			interpolate(engines[0].getNode("egt-actual"), 0, egt_shutdown_time);
		}
		if (pts.Engines.Engine.state[1].getValue() == 1 or pts.Engines.Engine.state[1].getValue() == 2) {
			pts.Controls.Engines.Engine.starter[1].setValue(0);
			pts.Controls.Engines.Engine.cutoff[1].setValue(1);
			systems.PNEU.Valves.starter2.setValue(0);
			pts.Engines.Engine.state[1].setValue(0);
			interpolate(engines[1].getNode("egt-actual"), 0, egt_shutdown_time);
		}
	}
}, 0, 0);

setlistener("/systems/pneumatics/psi/engine-1-psi", func {
	if (systems.PNEU.Psi.engine1.getValue() < 24.5) {
		if (pts.Engines.Engine.state[0].getValue() == 1 or pts.Engines.Engine.state[0].getValue() == 2) {
			pts.Controls.Engines.Engine.starter[0].setValue(0);
			pts.Controls.Engines.Engine.cutoff[0].setValue(1);
			systems.PNEU.Valves.starter1.setValue(0);
			pts.Engines.Engine.state[0].setValue(0);
			interpolate(engines[0].getNode("egt-actual"), 0, egt_shutdown_time);
		}
	}
}, 0, 0);

setlistener("/systems/pneumatics/psi/engine-2-psi", func {
	if (systems.PNEU.Psi.engine2.getValue() < 24.5) {
		if (pts.Engines.Engine.state[1].getValue() == 1 or pts.Engines.Engine.state[1].getValue() == 2) {
			pts.Controls.Engines.Engine.starter[1].setValue(0);
			pts.Controls.Engines.Engine.cutoff[1].setValue(1);
			systems.PNEU.Valves.starter2.setValue(0);
			pts.Engines.Engine.state[1].setValue(0);
			interpolate(engines[1].getNode("egt-actual"), 0, egt_shutdown_time);
		}
	}
}, 0, 0);

setlistener("/engines/engine[0]/state", func() {
	setprop("/sim/sound/shutdown[0]", pts.Engines.Engine.state[0].getValue());
}, 0, 0);


setlistener("/engines/engine[1]/state", func() {
	setprop("/sim/sound/shutdown[1]", pts.Engines.Engine.state[1].getValue());
}, 0, 0);