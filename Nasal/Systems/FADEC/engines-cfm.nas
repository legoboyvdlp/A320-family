# A3XX IAE V2500 Engine
# Joshua Davidson (Octal450)

# Copyright (c) 2019 Joshua Davidson (Octal450)

#####################
# Initializing Vars #
#####################

var engines = props.globals.getNode("/engines").getChildren("engine");
var egt_min = 434;
var egt_start = 587;
var egt_max = 712;
var start_time = 10;
var egt_lightup_time = 4;
var egt_lightdn_time = 10;
var shutdown_time = 20;
var egt_shutdown_time = 20;

setprop("/controls/engines/engine[0]/reverser", 0);
setprop("/controls/engines/engine[1]/reverser", 0);
setprop("/controls/engines/engine[0]/igniter-a", 0);
setprop("/controls/engines/engine[1]/igniter-a", 0);
setprop("/controls/engines/engine[0]/igniter-b", 0);
setprop("/controls/engines/engine[1]/igniter-b", 0);
setprop("/controls/engines/engine[0]/last-igniter", "B");
setprop("/controls/engines/engine[1]/last-igniter", "B");

var eng_init = func {
	setprop("/controls/engines/engine[0]/man-start", 0);
	setprop("/controls/engines/engine[1]/man-start", 0);
	eng_common_init();
}

# Trigger Startups and Stops
setlistener("/controls/engines/engine[0]/cutoff-switch", func {
	if (getprop("/controls/engines/engine[0]/cutoff-switch") == 0) {
		if (getprop("/systems/acconfig/autoconfig-running") == 1) {
			fast_start_one();
		} else {
			if (getprop("/controls/engines/engine[0]/man-start") == 0) {
				start_one_check();
			} else if (getprop("/controls/engines/engine[0]/man-start") == 1) {
				eng_one_man_start.start();
			}
		}
	} else if (getprop("/controls/engines/engine[0]/cutoff-switch") == 1) {
		cutoff_one();
	}
});

var cutoff_one = func {
	eng_one_auto_start.stop();
	eng_one_man_start.stop();
	eng_one_n2_check.stop();
	setprop("/controls/engines/engine[0]/igniter-a", 0);
	setprop("/controls/engines/engine[0]/igniter-b", 0);
	setprop("/controls/engines/engine[0]/man-start", 0);
	setprop("/systems/pneumatic/eng1-starter", 0);
	setprop("/controls/engines/engine[0]/starter", 0);
	setprop("/controls/engines/engine[0]/cutoff", 1);
	setprop("/engines/engine[0]/state", 0);
	interpolate(engines[0].getNode("egt-actual"), 0, egt_shutdown_time);
	eng_one_n2_check.stop();
}

var fast_start_one = func {
	setprop("/controls/engines/engine[0]/cutoff", 0);
	setprop("/engines/engine[0]/out-of-fuel", 0);
	setprop("/engines/engine[0]/run", 1);

	setprop("/engines/engine[0]/cutoff", 0);
	setprop("/engines/engine[0]/starter", 0);

	setprop("/fdm/jsbsim/propulsion/set-running", 0);
	
	setprop("/engines/engine[0]/state", 3);
	setprop("/systems/pneumatic/eng1-starter", 0);
}

setlistener("/controls/engines/engine[0]/man-start", func {
	start_one_mancheck();
});

var start_one_mancheck = func {
	if (getprop("/controls/engines/engine[0]/man-start") == 1) {
		if (getprop("/controls/engines/engine-start-switch") == 2 and (getprop("/controls/engines/engine[0]/cutoff-switch") == 1)) {
			setprop("/systems/pneumatic/eng1-starter", 1);
			settimer(start_one_mancheck_b, 0.5);
		}
	} else {
		if (getprop("/engines/engine[0]/state") == 1 or getprop("/engines/engine[0]/state") == 2) {
			setprop("/systems/pneumatic/eng1-starter", 0);
			setprop("/engines/engine[0]/state", 0);
			setprop("/controls/engines/engine[0]/starter", 0);
		}
	}
}

var start_one_mancheck_b = func {
	if (getprop("/systems/pneumatic/total-psi") >= 28) {
		setprop("/engines/engine[0]/state", 1);
		setprop("/controls/engines/engine[0]/starter", 1);
	}
}

var start_one_check = func {
	if (getprop("/controls/engines/engine-start-switch") == 2 and getprop("/controls/engines/engine[0]/cutoff-switch") == 0) {
		setprop("/systems/pneumatic/eng1-starter", 1);
		settimer(start_one_check_b, 0.5);
	}
}

var start_one_check_b = func {
	if ((getprop("/controls/engines/engine-start-switch") == 2) and (getprop("/systems/pneumatic/total-psi") >= 28) and (getprop("/controls/engines/engine[0]/cutoff-switch") == 0)) {
		auto_start_one();
	}
}

setlistener("/controls/engines/engine[1]/cutoff-switch", func {
	if (getprop("/controls/engines/engine[1]/cutoff-switch") == 0) {
		if (getprop("/systems/acconfig/autoconfig-running") == 1) {
			fast_start_two();
		} else {
			if (getprop("/controls/engines/engine[1]/man-start") == 0) {
				start_two_check();
			} else if (getprop("/controls/engines/engine[1]/man-start") == 1) {
				eng_two_man_start.start();
			}
		}
	} else if (getprop("/controls/engines/engine[1]/cutoff-switch") == 1) {
		cutoff_two();
	}
});

var cutoff_two = func {
	eng_two_auto_start.stop();
	eng_two_man_start.stop();
	eng_two_n2_check.stop();
	setprop("/controls/engines/engine[1]/igniter-a", 0);
	setprop("/controls/engines/engine[1]/igniter-b", 0);
	setprop("/controls/engines/engine[1]/man-start", 0);
	setprop("/systems/pneumatic/eng2-starter", 0);
	setprop("/controls/engines/engine[1]/starter", 0);
	setprop("/controls/engines/engine[1]/cutoff", 1);
	setprop("/engines/engine[1]/state", 0);
	interpolate(engines[1].getNode("egt-actual"), 0, egt_shutdown_time);
}

var fast_start_two = func {
	setprop("/controls/engines/engine[1]/cutoff", 0);
	setprop("/engines/engine[1]/out-of-fuel", 0);
	setprop("/engines/engine[1]/run", 1);

	setprop("/engines/engine[1]/cutoff", 0);
	setprop("/engines/engine[1]/starter", 0);

	setprop("/fdm/jsbsim/propulsion/set-running", 1);
	
	setprop("/engines/engine[1]/state", 3);
	setprop("/systems/pneumatic/eng2-starter", 0);
}

setlistener("/controls/engines/engine[1]/man-start", func {
	start_two_mancheck();
});

var start_two_mancheck = func {
	if (getprop("/controls/engines/engine[1]/man-start") == 1) {
		if (getprop("/controls/engines/engine-start-switch") == 2 and (getprop("/controls/engines/engine[1]/cutoff-switch") == 1)) {
			setprop("/systems/pneumatic/eng2-starter", 1);
			settimer(start_two_mancheck_b, 0.5);
		}
	} else {
		if (getprop("/engines/engine[1]/state") == 1 or getprop("/engines/engine[1]/state") == 2) {
			setprop("/systems/pneumatic/eng2-starter", 0);
			setprop("/engines/engine[1]/state", 0);
			setprop("/controls/engines/engine[1]/starter", 0);
		}
	}
}

var start_two_mancheck_b = func {
	if (getprop("/systems/pneumatic/total-psi") >= 28) {
		setprop("/engines/engine[1]/state", 1);
		setprop("/controls/engines/engine[1]/starter", 1);
	}
}

var start_two_check = func {
	if (getprop("/controls/engines/engine-start-switch") == 2 and getprop("/controls/engines/engine[1]/cutoff-switch") == 0) {
		setprop("/systems/pneumatic/eng2-starter", 1);
		settimer(start_two_check_b, 0.5);
	}
}

var start_two_check_b = func {
	if ((getprop("/controls/engines/engine-start-switch") == 2) and (getprop("/systems/pneumatic/total-psi") >= 28) and (getprop("/controls/engines/engine[1]/cutoff-switch") == 0)) {
		auto_start_two();
	}
}

# Start Engine One
var auto_start_one = func {
	setprop("/engines/engine[0]/state", 1);
	setprop("/controls/engines/engine[0]/starter", 1);
	eng_one_auto_start.start();
}

var eng_one_auto_start = maketimer(0.5, func {
	if (getprop("/engines/engine[0]/n2-actual") >= 22) {
		eng_one_auto_start.stop();
		setprop("/engines/engine[0]/state", 2);
		setprop("/controls/engines/engine[0]/cutoff", 0);
		if (getprop("/controls/engines/engine[0]/last-igniter") == "B") {
			setprop("/controls/engines/engine[0]/igniter-a", 1);
			setprop("/controls/engines/engine[0]/igniter-b", 0);
			setprop("/controls/engines/engine[0]/last-igniter", "A");
		} else if (getprop("/controls/engines/engine[0]/last-igniter") == "A") {
			setprop("/controls/engines/engine[0]/igniter-a", 0);
			setprop("/controls/engines/engine[0]/igniter-b", 1);
			setprop("/controls/engines/engine[0]/last-igniter", "B");
		}
		interpolate(engines[0].getNode("egt-actual"), egt_start, egt_lightup_time);
		eng_one_egt_check.start();
		eng_one_n2_check.start();
	}
});

var eng_one_man_start = maketimer(0.5, func {
	if (getprop("/engines/engine[0]/n2-actual") >= 16.7) {
		eng_one_man_start.stop();
		setprop("/engines/engine[0]/state", 2);
		setprop("/controls/engines/engine[0]/cutoff", 0);
		setprop("/controls/engines/engine[0]/igniter-a", 1);
		setprop("/controls/engines/engine[0]/igniter-b", 1);
		interpolate(engines[0].getNode("egt-actual"), egt_start, egt_lightup_time);
		eng_one_egt_check.start();
		eng_one_n2_check.start();
	}
});

var eng_one_egt_check = maketimer(0.5, func {
	if (getprop("/engines/engine[0]/egt-actual") >= egt_start) {
		eng_one_egt_check.stop();
		interpolate(engines[0].getNode("egt-actual"), egt_min, egt_lightdn_time);
	}
}); 

var eng_one_n2_check = maketimer(0.5, func {
	if (getprop("/engines/engine[0]/n2-actual") >= 43.0) {
		if (getprop("/controls/engines/engine[0]/igniter-a") != 0) {
			setprop("/controls/engines/engine[0]/igniter-a", 0);
		}
		if (getprop("/controls/engines/engine[0]/igniter-b") != 0) {
			setprop("/controls/engines/engine[0]/igniter-b", 0);
		}
	}
	if (getprop("/engines/engine[0]/n2-actual") >= 57.0) {
		eng_one_n2_check.stop();
		setprop("/systems/pneumatic/eng1-starter", 0);
		setprop("/engines/engine[0]/state", 3);
	}
});

# Start Engine Two
var auto_start_two = func {
	setprop("/engines/engine[1]/state", 1);
	setprop("/controls/engines/engine[1]/starter", 1);
	eng_two_auto_start.start();
}

var eng_two_auto_start = maketimer(0.5, func {
	if (getprop("/engines/engine[1]/n2-actual") >= 22) {
		eng_two_auto_start.stop();
		setprop("/engines/engine[1]/state", 2);
		setprop("/controls/engines/engine[1]/cutoff", 0);
		if (getprop("/controls/engines/engine[1]/last-igniter") == "B") {
			setprop("/controls/engines/engine[1]/igniter-a", 1);
			setprop("/controls/engines/engine[1]/igniter-b", 0);
			setprop("/controls/engines/engine[1]/last-igniter", "A");
		} else if (getprop("/controls/engines/engine[1]/last-igniter") == "A") {
			setprop("/controls/engines/engine[1]/igniter-a", 0);
			setprop("/controls/engines/engine[1]/igniter-b", 1);
			setprop("/controls/engines/engine[1]/last-igniter", "B");
		}
		interpolate(engines[1].getNode("egt-actual"), egt_start, egt_lightup_time);
		eng_two_egt_check.start();
		eng_two_n2_check.start();
	}
});

var eng_two_man_start = maketimer(0.5, func {
	if (getprop("/engines/engine[1]/n2-actual") >= 16.7) {
		eng_two_man_start.stop();
		setprop("/engines/engine[1]/state", 2);
		setprop("/controls/engines/engine[1]/cutoff", 0);
		setprop("/controls/engines/engine[1]/igniter-a", 1);
		setprop("/controls/engines/engine[1]/igniter-b", 1);
		interpolate(engines[1].getNode("egt-actual"), egt_start, egt_lightup_time);
		eng_two_egt_check.start();
		eng_two_n2_check.start();
	}
});

var eng_two_egt_check = maketimer(0.5, func {
	if (getprop("/engines/engine[1]/egt-actual") >= egt_start) {
		eng_two_egt_check.stop();
		interpolate(engines[1].getNode("egt-actual"), egt_min, egt_lightdn_time);
	}
});

var eng_two_n2_check = maketimer(0.5, func {
	if (getprop("/engines/engine[1]/n2-actual") >= 50.0) {
		if (getprop("/controls/engines/engine[1]/igniter-a") != 0) {
			setprop("/controls/engines/engine[1]/igniter-a", 0);
		}
		if (getprop("/controls/engines/engine[1]/igniter-b") != 0) {
			setprop("/controls/engines/engine[1]/igniter-b", 0);
		}
	}
	if (getprop("/engines/engine[1]/n2-actual") >= 57.0) {
		eng_two_n2_check.stop();
		setprop("/systems/pneumatic/eng2-starter", 0);
		setprop("/engines/engine[1]/state", 3);
	}
});

# Various Other Stuff
setlistener("/controls/engines/engine-start-switch", func {
	if (getprop("/engines/engine[0]/state") == 0) {
		start_one_check();
		start_one_mancheck();
	}
	if (getprop("/engines/engine[1]/state") == 0) {
		start_two_check();
		start_two_mancheck();
	}
	if ((getprop("/controls/engines/engine-start-switch") == 0) or (getprop("/controls/engines/engine-start-switch") == 1)) {
		if (getprop("/engines/engine[0]/state") == 1 or getprop("/engines/engine[0]/state") == 2) {
			setprop("/controls/engines/engine[0]/starter", 0);
			setprop("/controls/engines/engine[0]/cutoff", 1);
			setprop("/systems/pneumatic/eng1-starter", 0);
			setprop("/engines/engine[0]/state", 0);
			interpolate(engines[0].getNode("egt-actual"), 0, egt_shutdown_time);
		}
		if (getprop("/engines/engine[1]/state") == 1 or getprop("/engines/engine[1]/state") == 2) {
			setprop("/controls/engines/engine[1]/starter", 0);
			setprop("/controls/engines/engine[1]/cutoff", 1);
			setprop("/systems/pneumatic/eng2-starter", 0);
			setprop("/engines/engine[1]/state", 0);
			interpolate(engines[1].getNode("egt-actual"), 0, egt_shutdown_time);
		}
	}
});

setlistener("/systems/pneumatic/start-psi", func {
	if (getprop("/systems/pneumatic/total-psi") < 12) {
		if (getprop("/engines/engine[0]/state") == 1 or getprop("/engines/engine[0]/state") == 2) {
			setprop("/controls/engines/engine[0]/starter", 0);
			setprop("/controls/engines/engine[0]/cutoff", 1);
			setprop("/systems/pneumatic/eng1-starter", 0);
			setprop("/engines/engine[0]/state", 0);
			interpolate(engines[0].getNode("egt-actual"), 0, egt_shutdown_time);
		}
		if (getprop("/engines/engine[1]/state") == 1 or getprop("/engines/engine[1]/state") == 2) {
			setprop("/controls/engines/engine[1]/starter", 0);
			setprop("/controls/engines/engine[1]/cutoff", 1);
			setprop("/systems/pneumatic/eng2-starter", 0);
			setprop("/engines/engine[1]/state", 0);
			interpolate(engines[1].getNode("egt-actual"), 0, egt_shutdown_time);
		}
	}
});
