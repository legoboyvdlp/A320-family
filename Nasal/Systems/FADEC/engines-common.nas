# A3XX Engine Control
# Joshua Davidson (Octal450)

# Copyright (c) 2019 Joshua Davidson (Octal450)

if (getprop("/options/eng") == "IAE") {
	io.include("engines-iae.nas");
} else {
	io.include("engines-cfm.nas");
}

var spinup_time = 49;
var apu_max = 100;
var apu_egt_min = 352;
var apu_egt_max = 704;
setprop("/systems/apu/rpm", 0);
setprop("/systems/apu/egt", 42);
setprop("/systems/apu/bleed-used", 0);
setprop("/systems/apu/bleed-counting", 0);
setprop("/systems/apu/bleed-time", 0);

var eng_common_init = func {
	setprop("/systems/apu/bleed-used", 0);
}

# Start APU
setlistener("/controls/APU/start", func {
	if (getprop("/controls/APU/master") == 1 and getprop("/controls/APU/start") == 1) {
		apuBleedChk.stop();
		setprop("/systems/apu/bleed-counting", 0);
		if (getprop("/systems/acconfig/autoconfig-running") == 0) {
			interpolate("/systems/apu/rpm", apu_max, spinup_time);
			apu_egt_check.start();
		} else if (getprop("/systems/acconfig/autoconfig-running") == 1) {
			interpolate("/systems/apu/rpm", apu_max, 5);
			interpolate("/systems/apu/egt", apu_egt_min, 5);
		}
	} else if (getprop("/controls/APU/master") == 0) {
		apu_egt_check.stop();
		apu_stop();
	}
});

var apu_egt_check = maketimer(0.5, func {
	if (getprop("/systems/apu/rpm") >= 28) {
		apu_egt_check.stop();
		interpolate("/systems/apu/egt", apu_egt_max, 5);
		apu_egt2_check.start();
	}
});

var apu_egt2_check = maketimer(0.5, func {
	if (getprop("/systems/apu/egt") >= 701) {
		apu_egt2_check.stop();
		interpolate("/systems/apu/egt", apu_egt_min, 30);
	}
});

# Stop APU
setlistener("/controls/APU/master", func {
	if (getprop("/controls/APU/master") == 0) {
		setprop("/controls/APU/start", 0);
		apu_egt_check.stop();
		apu_egt2_check.stop();
		apu_stop();
	} else if (getprop("/controls/APU/master") == 1) {
		apuBleedChk.stop();
		setprop("/systems/apu/bleed-counting", 0);
		setprop("/systems/apu/bleed-used", 0);
	}
});

var apu_stop = func {
	if (getprop("/systems/apu/bleed-used") == 1 and getprop("/systems/apu/bleed-counting") != 1 and getprop("/systems/acconfig/autoconfig-running") != 1) {
		setprop("/systems/apu/bleed-counting", 1);
		setprop("/systems/apu/bleed-time", getprop("/sim/time/elapsed-sec"));
	}
	if (getprop("/systems/apu/bleed-used") == 1 and getprop("/systems/apu/bleed-counting") == 1 and getprop("/systems/acconfig/autoconfig-running") != 1) {
		apuBleedChk.start();
	} else {
		apuBleedChk.stop();
		interpolate("/systems/apu/rpm", 0, 30);
		interpolate("/systems/apu/egt", 42, 40);
		setprop("/systems/apu/bleed-counting", 0);
		setprop("/systems/apu/bleed-used", 0);
	}
}

var apuBleedChk = maketimer(0.1, func {
	if (getprop("/systems/apu/bleed-used") == 1 and getprop("/systems/apu/bleed-counting") == 1) {
		if (getprop("/systems/apu/bleed-time") + 60 <= getprop("/sim/time/elapsed-sec")) {
			apuBleedChk.stop();
			interpolate("/systems/apu/rpm", 0, 30);
			interpolate("/systems/apu/egt", 42, 40);
			setprop("/systems/apu/bleed-counting", 0);
			setprop("/systems/apu/bleed-used", 0);
		}
	}
});

# Various Other Stuff
var doIdleThrust = func {
	setprop("/controls/engines/engine[0]/throttle", 0.0);
	setprop("/controls/engines/engine[1]/throttle", 0.0);
}

var doCLThrust = func {
	setprop("/controls/engines/engine[0]/throttle", 0.63);
	setprop("/controls/engines/engine[1]/throttle", 0.63);
}

var doMCTThrust = func {
	setprop("/controls/engines/engine[0]/throttle", 0.8);
	setprop("/controls/engines/engine[1]/throttle", 0.8);
}

var doTOGAThrust = func {
	setprop("/controls/engines/engine[0]/throttle", 1.0);
	setprop("/controls/engines/engine[1]/throttle", 1.0);
}

# Reverse Thrust System
var toggleFastRevThrust = func {
	var state1 = getprop("/systems/thrust/state1");
	var state2 = getprop("/systems/thrust/state2");
	if (state1 == "IDLE" and state2 == "IDLE" and getprop("/controls/engines/engine[0]/reverser") == "0" and getprop("/controls/engines/engine[1]/reverser") == "0" and getprop("/gear/gear[1]/wow") == 1 and getprop("/gear/gear[2]/wow") == 1) {
		interpolate("/engines/engine[0]/reverser-pos-norm", 1, 1.4);
		interpolate("/engines/engine[1]/reverser-pos-norm", 1, 1.4);
		setprop("/controls/engines/engine[0]/reverser", 1);
		setprop("/controls/engines/engine[1]/reverser", 1);
		setprop("/controls/engines/engine[0]/throttle-rev", 0.65);
		setprop("/controls/engines/engine[1]/throttle-rev", 0.65);
		setprop("/fdm/jsbsim/propulsion/engine[0]/reverser-angle-rad", 3.14);
		setprop("/fdm/jsbsim/propulsion/engine[1]/reverser-angle-rad", 3.14);
	} else if ((getprop("/controls/engines/engine[0]/reverser") == "1") or (getprop("/controls/engines/engine[1]/reverser") == "1") and (getprop("/gear/gear[1]/wow") == 1) and (getprop("/gear/gear[2]/wow") == 1)) {
		setprop("/controls/engines/engine[0]/throttle-rev", 0);
		setprop("/controls/engines/engine[1]/throttle-rev", 0);
		interpolate("/engines/engine[0]/reverser-pos-norm", 0, 1.0);
		interpolate("/engines/engine[1]/reverser-pos-norm", 0, 1.0);
		setprop("/fdm/jsbsim/propulsion/engine[0]/reverser-angle-rad", 0);
		setprop("/fdm/jsbsim/propulsion/engine[1]/reverser-angle-rad", 0);
		setprop("/controls/engines/engine[0]/reverser", 0);
		setprop("/controls/engines/engine[1]/reverser", 0);
	}
}

var doRevThrust = func {
	if (getprop("/controls/engines/engine[0]/reverser") == "1" and getprop("/controls/engines/engine[1]/reverser") == "1" and getprop("/gear/gear[1]/wow") == 1 and getprop("/gear/gear[2]/wow") == 1) {
		var pos1 = getprop("/controls/engines/engine[0]/throttle-rev");
		var pos2 = getprop("/controls/engines/engine[1]/throttle-rev");
		if (pos1 < 0.649) {
			setprop("/controls/engines/engine[0]/throttle-rev", pos1 + 0.15);
		}
		if (pos2 < 0.649) {
			setprop("/controls/engines/engine[1]/throttle-rev", pos2 + 0.15);
		}
	}
	var state1 = getprop("/systems/thrust/state1");
	var state2 = getprop("/systems/thrust/state2");
	if (state1 == "IDLE" and state2 == "IDLE" and getprop("/controls/engines/engine[0]/reverser") == "0" and getprop("/controls/engines/engine[1]/reverser") == "0" and getprop("/gear/gear[1]/wow") == 1 and getprop("/gear/gear[2]/wow") == 1) {
		setprop("/controls/engines/engine[0]/throttle-rev", 0.05);
		setprop("/controls/engines/engine[1]/throttle-rev", 0.05);
		interpolate("/engines/engine[0]/reverser-pos-norm", 1, 1.4);
		interpolate("/engines/engine[1]/reverser-pos-norm", 1, 1.4);
		setprop("/controls/engines/engine[0]/reverser", 1);
		setprop("/controls/engines/engine[1]/reverser", 1);
		setprop("/fdm/jsbsim/propulsion/engine[0]/reverser-angle-rad", 3.14);
		setprop("/fdm/jsbsim/propulsion/engine[1]/reverser-angle-rad", 3.14);
	}
}

var unRevThrust = func {
	if (getprop("/controls/engines/engine[0]/reverser") == "1" or getprop("/controls/engines/engine[1]/reverser") == "1") {
		var pos1 = getprop("/controls/engines/engine[0]/throttle-rev");
		var pos2 = getprop("/controls/engines/engine[1]/throttle-rev");
		if (pos1 > 0.051) {
			setprop("/controls/engines/engine[0]/throttle-rev", pos1 - 0.15);
		} else {
			unRevThrust_b();
		}
		if (pos2 > 0.051) {
			setprop("/controls/engines/engine[1]/throttle-rev", pos2 - 0.15);
		} else {
			unRevThrust_b();
		}
	}
}

var unRevThrust_b = func {
	setprop("/controls/engines/engine[0]/throttle-rev", 0);
	setprop("/controls/engines/engine[1]/throttle-rev", 0);
	interpolate("/engines/engine[0]/reverser-pos-norm", 0, 1.0);
	interpolate("/engines/engine[1]/reverser-pos-norm", 0, 1.0);
	setprop("/fdm/jsbsim/propulsion/engine[0]/reverser-angle-rad", 0);
	setprop("/fdm/jsbsim/propulsion/engine[1]/reverser-angle-rad", 0);
	setprop("/controls/engines/engine[0]/reverser", 0);
	setprop("/controls/engines/engine[1]/reverser", 0);
}
