# A3XX Autobrake
# Joshua Davidson (Octal450)

# Copyright (c) 2019 Joshua Davidson (Octal450)

var thr1 = 0;
var thr2 = 0;
var wow0 = 0;
var gnd_speed = 0;
setprop("/controls/autobrake/active", 0);
setprop("/controls/autobrake/mode", 0);
setprop("/controls/autobrake/decel-rate", 0);

var autobrake_init = func {
	setprop("/controls/autobrake/active", 0);
	setprop("/controls/autobrake/mode", 0);
}

# Override FG's generic brake
controls.applyBrakes = func(v, which = 0) {
	if (getprop("/systems/acconfig/autoconfig-running") != 1) {
		if (which <= 0) {
			interpolate("/controls/gear/brake-left", v, 0.5);
		}
		if (which >= 0) {
			interpolate("/controls/gear/brake-right", v, 0.5);
		}
	}
}

# Set autobrake mode
var arm_autobrake = func(mode) {
	wow0 = getprop("/gear/gear[0]/wow");
	gnd_speed = getprop("/velocities/groundspeed-kt");
	if (mode == 0) { # OFF
		absChk.stop();
		if (getprop("/controls/autobrake/active") == 1) {
			setprop("/controls/autobrake/active", 0);
			setprop("/controls/gear/brake-left", 0);
			setprop("/controls/gear/brake-right", 0);
		}
		setprop("/controls/autobrake/decel-rate", 0);
		setprop("/controls/autobrake/mode", 0);
	} else if (mode == 1 and wow0 != 1) { # LO
		setprop("/controls/autobrake/decel-rate", 1.7);
		setprop("/controls/autobrake/mode", 1);
		absChk.start();
	} else if (mode == 2 and wow0 != 1) { # MED
		setprop("/controls/autobrake/decel-rate", 3);
		setprop("/controls/autobrake/mode", 2);
		absChk.start();
	} else if (mode == 3 and wow0 == 1 and gnd_speed < 40) { # MAX
		setprop("/controls/autobrake/decel-rate", 6);
		setprop("/controls/autobrake/mode", 3);
		absChk.start();
	}
}

# Autobrake loop
var absChk = maketimer(0.2, func {
	thr1 = getprop("/controls/engines/engine[0]/throttle");
	thr2 = getprop("/controls/engines/engine[1]/throttle");
	wow0 = getprop("/gear/gear[0]/wow");
	gnd_speed = getprop("/velocities/groundspeed-kt");
	if (gnd_speed > 72) {
		if (getprop("/controls/autobrake/mode") != 0 and thr1 < 0.15 and thr2 < 0.15 and wow0 == 1) {
			setprop("/controls/autobrake/active", 1);
		} else {
			setprop("/controls/autobrake/active", 0);
			setprop("/controls/gear/brake-left", 0);
			setprop("/controls/gear/brake-right", 0);
		}
	}
	if (getprop("/controls/autobrake/mode") == 3 and getprop("/controls/gear/gear-down") == 0) {
		arm_autobrake(0);
	}
	if (getprop("/controls/autobrake/mode") != 0 and wow0 == 1 and getprop("/controls/autobrake/active") == 1 and (getprop("/controls/gear/brake-left") > 0.05 or getprop("/controls/gear/brake-right") > 0.05)) {
		arm_autobrake(0);
	}
});
