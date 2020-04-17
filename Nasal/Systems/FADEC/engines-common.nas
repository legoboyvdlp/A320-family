# A3XX Engine Control
# Joshua Davidson (Octal450)

# Copyright (c) 2019 Joshua Davidson (Octal450)

if (getprop("options/eng") == "IAE") {
	io.include("engines-iae.nas");
} else {
	io.include("engines-cfm.nas");
}

var eng_common_init = func {
	# nada
}

# Various Other Stuff
var doIdleThrust = func {
	# Idle does not respect selected engines, because it is used to respond
	# to "Retard" and both engines must be idle for spoilers to deploy
	setprop("controls/engines/engine[0]/throttle", 0.0);
	setprop("controls/engines/engine[1]/throttle", 0.0);
}

var doCLThrust = func {
	if (getprop("sim/input/selected/engine[0]") == 1) {
		setprop("controls/engines/engine[0]/throttle", 0.63);
	}
	if (getprop("sim/input/selected/engine[1]") == 1) {
		setprop("controls/engines/engine[1]/throttle", 0.63);
	}
}

var doMCTThrust = func {
	if (getprop("sim/input/selected/engine[0]") == 1) {
		setprop("controls/engines/engine[0]/throttle", 0.8);
	}
	if (getprop("sim/input/selected/engine[1]") == 1) {
		setprop("controls/engines/engine[1]/throttle", 0.8);
	}
}

var doTOGAThrust = func {
	if (getprop("sim/input/selected/engine[0]") == 1) {
		setprop("controls/engines/engine[0]/throttle", 1.0);
	}
	if (getprop("sim/input/selected/engine[1]") == 1) {
		setprop("controls/engines/engine[1]/throttle", 1.0);
	}
}

# Reverse Thrust System
var toggleFastRevThrust = func {
	var state1 = getprop("systems/thrust/state1");
	var state2 = getprop("systems/thrust/state2");
	if (state1 == "IDLE" and state2 == "IDLE" and getprop("controls/engines/engine[0]/reverser") == "0" and getprop("controls/engines/engine[1]/reverser") == "0" and getprop("gear/gear[1]/wow") == 1 and getprop("gear/gear[2]/wow") == 1) {
		if (getprop("sim/input/selected/engine[0]") == 1) {
			interpolate("/engines/engine[0]/reverser-pos-norm", 1, 1.4);
			setprop("controls/engines/engine[0]/reverser", 1);
			setprop("controls/engines/engine[0]/throttle-rev", 0.65);
			setprop("fdm/jsbsim/propulsion/engine[0]/reverser-angle-rad", 3.14);
		}
		if (getprop("sim/input/selected/engine[1]") == 1) {
			interpolate("/engines/engine[1]/reverser-pos-norm", 1, 1.4);
			setprop("controls/engines/engine[1]/reverser", 1);
			setprop("controls/engines/engine[1]/throttle-rev", 0.65);
			setprop("fdm/jsbsim/propulsion/engine[1]/reverser-angle-rad", 3.14);
		}
	} else if ((getprop("controls/engines/engine[0]/reverser") == "1") or (getprop("controls/engines/engine[1]/reverser") == "1")) {
		setprop("controls/engines/engine[0]/throttle-rev", 0);
		setprop("controls/engines/engine[1]/throttle-rev", 0);
		interpolate("/engines/engine[0]/reverser-pos-norm", 0, 1.0);
		interpolate("/engines/engine[1]/reverser-pos-norm", 0, 1.0);
		setprop("fdm/jsbsim/propulsion/engine[0]/reverser-angle-rad", 0);
		setprop("fdm/jsbsim/propulsion/engine[1]/reverser-angle-rad", 0);
		setprop("controls/engines/engine[0]/reverser", 0);
		setprop("controls/engines/engine[1]/reverser", 0);
	}
}

var doRevThrust = func {
	if (getprop("gear/gear[1]/wow") != 1 and getprop("gear/gear[2]/wow") != 1) {
		# Can't select reverse if not on the ground
		return;
	}
	if (getprop("sim/input/selected/engine[0]") == 1 and getprop("controls/engines/engine[0]/reverser") == "1") {
		var pos = getprop("controls/engines/engine[0]/throttle-rev");
		if (pos < 0.649) {
			setprop("controls/engines/engine[0]/throttle-rev", pos + 0.15);
		}
	}
	if (getprop("sim/input/selected/engine[1]") == 1 and getprop("controls/engines/engine[1]/reverser") == "1") {
		var pos = getprop("controls/engines/engine[1]/throttle-rev");
		if (pos < 0.649) {
			setprop("controls/engines/engine[1]/throttle-rev", pos + 0.15);
		}
	}
	var state1 = getprop("systems/thrust/state1");
	var state2 = getprop("systems/thrust/state2");
	if (getprop("sim/input/selected/engine[0]") == 1 and state1 == "IDLE" and getprop("controls/engines/engine[0]/reverser") == "0") {
		setprop("controls/engines/engine[0]/throttle-rev", 0.05);
		interpolate("/engines/engine[0]/reverser-pos-norm", 1, 1.4);
		setprop("controls/engines/engine[0]/reverser", 1);
		setprop("fdm/jsbsim/propulsion/engine[0]/reverser-angle-rad", 3.14);
	}
	if (getprop("sim/input/selected/engine[1]") == 1 and state2 == "IDLE" and getprop("controls/engines/engine[1]/reverser") == "0") {
		setprop("controls/engines/engine[1]/throttle-rev", 0.05);
		interpolate("/engines/engine[1]/reverser-pos-norm", 1, 1.4);
		setprop("controls/engines/engine[1]/reverser", 1);
		setprop("fdm/jsbsim/propulsion/engine[1]/reverser-angle-rad", 3.14);
	}
}

var unRevThrust = func {
	if (getprop("sim/input/selected/engine[0]") == 1 and getprop("controls/engines/engine[0]/reverser") == "1") {
		var pos = getprop("controls/engines/engine[0]/throttle-rev");
		if (pos > 0.051) {
			setprop("controls/engines/engine[0]/throttle-rev", pos - 0.15);
		} else {
			setprop("controls/engines/engine[0]/throttle-rev", 0);
			interpolate("/engines/engine[0]/reverser-pos-norm", 0, 1.0);
			setprop("fdm/jsbsim/propulsion/engine[0]/reverser-angle-rad", 0);
			setprop("controls/engines/engine[0]/reverser", 0);
		}
	}
	if (getprop("sim/input/selected/engine[1]") == 1 and getprop("controls/engines/engine[1]/reverser") == "1") {
		var pos = getprop("controls/engines/engine[1]/throttle-rev");
		if (pos > 0.051) {
			setprop("controls/engines/engine[1]/throttle-rev", pos - 0.15);
		} else {
			setprop("controls/engines/engine[1]/throttle-rev", 0);
			interpolate("/engines/engine[1]/reverser-pos-norm", 0, 1.0);
			setprop("fdm/jsbsim/propulsion/engine[1]/reverser-angle-rad", 0);
			setprop("controls/engines/engine[1]/reverser", 0);
		}
	}
}
