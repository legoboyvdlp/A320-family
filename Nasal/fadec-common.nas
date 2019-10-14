# A3XX FADEC/Throttle Control System

# Copyright (c) 2019 Joshua Davidson (Octal450)

if (getprop("/options/eng") == "IAE") {
	io.include("fadec-iae.nas");
} else {
	io.include("fadec-cfm.nas");
}

var thr1 = 0;
var thr2 = 0;
var state1 = 0;
var state2 = 0;
var engstate1 = 0;
var engstate2 = 0;
var eprtoga = 0;
var eprmct = 0;
var eprflx = 0;
var eprclb = 0;
var n1toga = 0;
var n1mct = 0;
var n1flx = 0;
var n1clb = 0;
var alpha = 0;
var flaps = 0;
var alphaProt = 0;
var togaLock = 0;
var gs = 0;
setprop("/systems/thrust/alpha-floor", 0);
setprop("/systems/thrust/toga-lk", 0);
setprop("/systems/thrust/epr/toga-lim", 0.0);
setprop("/systems/thrust/epr/mct-lim", 0.0);
setprop("/systems/thrust/epr/flx-lim", 0.0);
setprop("/systems/thrust/epr/clb-lim", 0.0);
setprop("/systems/thrust/n1/toga-lim", 0.0);
setprop("/systems/thrust/n1/mct-lim", 0.0);
setprop("/systems/thrust/n1/flx-lim", 0.0);
setprop("/systems/thrust/n1/clb-lim", 0.0);
setprop("/engines/flx-thr", 0.0);
setprop("/controls/engines/thrust-limit", "TOGA");
setprop("/controls/engines/epr-limit", 0.0);
setprop("/controls/engines/n1-limit", 0.0);
setprop("/systems/thrust/state1", "IDLE");
setprop("/systems/thrust/state2", "IDLE");
setprop("/systems/thrust/lvrclb", 0);
setprop("/systems/thrust/clbreduc-ft", "1500");
setprop("/systems/thrust/toga-lim", 0.0);
setprop("/systems/thrust/mct-lim", 0.0);
setprop("/systems/thrust/clb-lim", 0.0);
setprop("/systems/thrust/lim-flex", 0);
setprop("/engines/flex-derate", 0);
setprop("/systems/thrust/eng-out", 0);
setprop("/systems/thrust/thr-locked", 0);
setprop("/systems/thrust/thr-locked-alert", 0);
setprop("/systems/thrust/thr-locked-flash", 0);
setprop("/systems/thrust/thr-lock-time", 0);
setprop("/systems/thrust/thr-lock-cmd[0]", 0);
setprop("/systems/thrust/thr-lock-cmd[1]", 0);

setlistener("/sim/signals/fdm-initialized", func {
	thrust_loop.start();
	thrust_flash.start();
});

setlistener("/controls/engines/engine[0]/throttle-pos", func {
	engstate1 = getprop("/engines/engine[0]/state");
	engstate2 = getprop("/engines/engine[1]/state");
	thr1 = getprop("/controls/engines/engine[0]/throttle-pos");
	if (getprop("/systems/thrust/alpha-floor") == 0 and getprop("/systems/thrust/toga-lk") == 0) {
		if (thr1 < 0.01) {
			setprop("/systems/thrust/state1", "IDLE");
			unflex();
			atoff_request();
		} else if (thr1 >= 0.01 and thr1 < 0.60) {
			setprop("/systems/thrust/state1", "MAN");
			unflex();
		} else if (thr1 >= 0.60 and thr1 < 0.65) {
			setprop("/systems/thrust/state1", "CL");
			unflex();
		} else if (thr1 >= 0.65 and thr1 < 0.78) {
			setprop("/systems/thrust/state1", "MAN THR");
			unflex();
		} else if (thr1 >= 0.78 and thr1 < 0.83) {
			if (getprop("/systems/thrust/eng-out") != 1) {
				if (getprop("/controls/engines/thrust-limit") == "FLX") {
					if (getprop("/gear/gear[0]/wow") == 1 and (engstate1 == 3 or engstate2 == 3)) {
						setprop("/it-autoflight/input/athr", 1);
					}
					setprop("/controls/engines/engine[0]/throttle-fdm", 0.99);
				} else {
					setprop("/controls/engines/engine[0]/throttle-fdm", 0.95);
				}
			}
			setprop("/systems/thrust/state1", "MCT");
		} else if (thr1 >= 0.83 and thr1 < 0.95) {
			setprop("/systems/thrust/state1", "MAN THR");
			unflex();
		} else if (thr1 >= 0.95) {
			if (getprop("/gear/gear[0]/wow") == 1 and (engstate1 == 3 or engstate2 == 3)) {
				setprop("/it-autoflight/input/athr", 1);
			}
			setprop("/controls/engines/engine[0]/throttle-fdm", 0.99);
			setprop("/systems/thrust/state1", "TOGA");
			unflex();
		}
	} else {
		if (thr1 < 0.01) {
			setprop("/systems/thrust/state1", "IDLE");
		} else if (thr1 >= 0.01 and thr1 < 0.60) {
			setprop("/systems/thrust/state1", "MAN");
		} else if (thr1 >= 0.60 and thr1 < 0.65) {
			setprop("/systems/thrust/state1", "CL");
		} else if (thr1 >= 0.65 and thr1 < 0.78) {
			setprop("/systems/thrust/state1", "MAN THR");
		} else if (thr1 >= 0.78 and thr1 < 0.83) {
			setprop("/systems/thrust/state1", "MCT");
		} else if (thr1 >= 0.83 and thr1 < 0.95) {
			setprop("/systems/thrust/state1", "MAN THR");
		} else if (thr1 >= 0.95) {
			setprop("/systems/thrust/state1", "TOGA");
		}
		setprop("/controls/engines/engine[0]/throttle-fdm", 0.99);
	}
}, 0, 0);

setlistener("/controls/engines/engine[1]/throttle-pos", func {
	engstate1 = getprop("/engines/engine[0]/state");
	engstate2 = getprop("/engines/engine[1]/state");
	thr2 = getprop("/controls/engines/engine[1]/throttle-pos");
	if (getprop("/systems/thrust/alpha-floor") == 0 and getprop("/systems/thrust/toga-lk") == 0) {
		if (thr2 < 0.01) {
			setprop("/systems/thrust/state2", "IDLE");
			unflex();
			atoff_request();
		} else if (thr2 >= 0.01 and thr2 < 0.60) {
			setprop("/systems/thrust/state2", "MAN");
			unflex();
		} else if (thr2 >= 0.60 and thr2 < 0.65) {
			setprop("/systems/thrust/state2", "CL");
			unflex();
		} else if (thr2 >= 0.65 and thr2 < 0.78) {
			setprop("/systems/thrust/state2", "MAN THR");
			unflex();
		} else if (thr2 >= 0.78 and thr2 < 0.83) {
			if (getprop("/systems/thrust/eng-out") != 1) {
				if (getprop("/controls/engines/thrust-limit") == "FLX") {
					if (getprop("/gear/gear[0]/wow") == 1 and (engstate1 == 3 or engstate2 == 3)) {
						setprop("/it-autoflight/input/athr", 1);
					}
					setprop("/controls/engines/engine[1]/throttle-fdm", 0.99);
				} else {
					setprop("/controls/engines/engine[1]/throttle-fdm", 0.95);
				}
			}
			setprop("/systems/thrust/state2", "MCT");
		} else if (thr2 >= 0.83 and thr2 < 0.95) {
			setprop("/systems/thrust/state2", "MAN THR");
			unflex();
		} else if (thr2 >= 0.95) {
			if (getprop("/gear/gear[0]/wow") == 1 and (engstate1 == 3 or engstate2 == 3)) {
				setprop("/it-autoflight/input/athr", 1);
			}
			setprop("/controls/engines/engine[1]/throttle-fdm", 0.99);
			setprop("/systems/thrust/state2", "TOGA");
			unflex();
		}
	} else {
		if (thr2 < 0.01) {
			setprop("/systems/thrust/state2", "IDLE");
		} else if (thr2 >= 0.01 and thr2 < 0.60) {
			setprop("/systems/thrust/state2", "MAN");
		} else if (thr2 >= 0.60 and thr2 < 0.65) {
			setprop("/systems/thrust/state2", "CL");
		} else if (thr2 >= 0.65 and thr2 < 0.78) {
			setprop("/systems/thrust/state2", "MAN THR");
		} else if (thr2 >= 0.78 and thr2 < 0.83) {
			setprop("/systems/thrust/state2", "MCT");
		} else if (thr2 >= 0.83 and thr2 < 0.95) {
			setprop("/systems/thrust/state2", "MAN THR");
		} else if (thr2 >= 0.95) {
			setprop("/systems/thrust/state2", "TOGA");
		}
		setprop("/controls/engines/engine[1]/throttle-fdm", 0.99);
	}
}, 0, 0);

# Alpha Floor and Toga Lock
setlistener("/it-autoflight/input/athr", func {
	if (getprop("/systems/thrust/alpha-floor") == 1) {
		setprop("/it-autoflight/input/athr", 1);
	} else {
		setprop("/systems/thrust/toga-lk", 0);
	}
});

# Checks if all throttles are in the IDLE position, before tuning off the A/THR.
var atoff_request = func {
	state1 = getprop("/systems/thrust/state1");
	state2 = getprop("/systems/thrust/state2");
	if ((state1 == "IDLE") and (state2 == "IDLE") and (getprop("/systems/thrust/alpha-floor") == 0) and (getprop("/systems/thrust/toga-lk") == 0)) {
		if (getprop("/it-autoflight/input/athr") == 1 and getprop("/position/gear-agl-ft") > 50) {
			libraries.athrOff("soft");
		} elsif (getprop("/position/gear-agl-ft") < 50) {
			libraries.athrOff("none");
		}
	}
}

var thrust_loop = maketimer(0.04, func {
	state1 = getprop("/systems/thrust/state1");
	state2 = getprop("/systems/thrust/state2");
	engstate1 = getprop("/engines/engine[0]/state");
	engstate2 = getprop("/engines/engine[1]/state");
	thr1 = getprop("/controls/engines/engine[0]/throttle-pos");
	thr2 = getprop("/controls/engines/engine[1]/throttle-pos");
	eprtoga = getprop("/systems/thrust/epr/toga-lim");
	eprmct = getprop("/systems/thrust/epr/mct-lim");
	eprflx = getprop("/systems/thrust/epr/flx-lim");
	eprclb = getprop("/systems/thrust/epr/clb-lim");
	n1toga = getprop("/systems/thrust/n1/toga-lim");
	n1mct = getprop("/systems/thrust/n1/mct-lim");
	n1flx = getprop("/systems/thrust/n1/flx-lim");
	n1clb = getprop("/systems/thrust/n1/clb-lim");
	gs = getprop("/velocities/groundspeed-kt");
	if (getprop("/FMGC/internal/flex-set") == 1 and getprop("/systems/fadec/n1mode1") == 0 and getprop("/systems/fadec/n1mode2") == 0 and getprop("/gear/gear[1]/wow") == 1 and getprop("/gear/gear[2]/wow") == 1 and gs < 40) {
		setprop("/systems/thrust/lim-flex", 1);
	} else if (getprop("/FMGC/internal/flex-set") == 0 or engstate1 != 3 or engstate2 != 3) {
		setprop("/systems/thrust/lim-flex", 0);
	}
	if (getprop("/controls/engines/engine[0]/reverser") == "1" or getprop("/controls/engines/engine[1]/reverser") == "1") {
		setprop("/controls/engines/thrust-limit", "MREV");
		setprop("/controls/engines/epr-limit", 1.000);
		setprop("/controls/engines/n1-limit", 0.0);
	} else if (getprop("/gear/gear[1]/wow") == 0 or getprop("/gear/gear[2]/wow") == 0 or (engstate1 != 3 and engstate2 != 3)) {
		if ((state1 == "TOGA" or state2 == "TOGA" or (state1 == "MAN THR" and thr1 >= 0.83) or (state2 == "MAN THR" and thr2 >= 0.83)) or getprop("/systems/thrust/alpha-floor") == 1 or getprop("/systems/thrust/toga-lk") == 1) {
			setprop("/controls/engines/thrust-limit", "TOGA");
			setprop("/controls/engines/epr-limit", eprtoga);
			setprop("/controls/engines/n1-limit", n1toga);
		} else if ((state1 == "MCT" or state2 == "MCT" or (state1 == "MAN THR" and thr1 < 0.83) or (state2 == "MAN THR" and thr2 < 0.83)) and getprop("/systems/thrust/lim-flex") == 0) {
			setprop("/controls/engines/thrust-limit", "MCT");
			setprop("/controls/engines/epr-limit", eprmct);
			setprop("/controls/engines/n1-limit", n1mct);
		} else if ((state1 == "MCT" or state2 == "MCT" or (state1 == "MAN THR" and thr1 < 0.83) or (state2 == "MAN THR" and thr2 < 0.83)) and getprop("/systems/thrust/lim-flex") == 1) {
			setprop("/controls/engines/thrust-limit", "FLX");
			setprop("/controls/engines/epr-limit", eprflx);
			setprop("/controls/engines/n1-limit", n1flx);
		} else if (state1 == "CL" or state2 == "CL" or state1 == "MAN" or state2 == "MAN" or state1 == "IDLE" or state2 == "IDLE") {
			setprop("/controls/engines/thrust-limit", "CLB");
			setprop("/controls/engines/epr-limit", eprclb);
			setprop("/controls/engines/n1-limit", n1clb);
		}
	} else if (getprop("/FMGC/internal/flex-set") == 1 and getprop("/systems/fadec/n1mode1") == 0 and getprop("/systems/fadec/n1mode2") == 0) {
		if ((state1 == "TOGA" or state2 == "TOGA" or (state1 == "MAN THR" and thr1 >= 0.83) or (state2 == "MAN THR" and thr2 >= 0.83)) or getprop("/systems/thrust/alpha-floor") == 1 or getprop("/systems/thrust/toga-lk") == 1) {
			setprop("/controls/engines/thrust-limit", "TOGA");
			setprop("/controls/engines/epr-limit", eprtoga);
			setprop("/controls/engines/n1-limit", n1toga);
		} else {
			setprop("/controls/engines/thrust-limit", "FLX");
			setprop("/controls/engines/epr-limit", eprflx);
			setprop("/controls/engines/n1-limit", n1flx);
		}
	} else {
		setprop("/controls/engines/thrust-limit", "TOGA");
		setprop("/controls/engines/epr-limit", eprtoga);
		setprop("/controls/engines/n1-limit", n1toga);
	}
	
	alpha = getprop("/fdm/jsbsim/aero/alpha-deg");
	flaps = getprop("/controls/flight/flap-pos");
	if (flaps == 0) {
		alphaProt = 9.5;
	} else if (flaps == 1 or flaps == 2 or flaps == 3) {
		alphaProt = 15.0;
	} else if (flaps == 4) {
		alphaProt = 14.0;
	} else if (flaps == 5) {
		alphaProt = 13.0;
	}
	togaLock = alphaProt - 1;
	if (getprop("/gear/gear[1]/wow") == 0 and getprop("/gear/gear[2]/wow") == 0 and getprop("/it-fbw/law") == 0 and (getprop("/systems/thrust/eng-out") == 0 or (getprop("/systems/thrust/eng-out") == 1 and flaps == 0)) and getprop("/systems/fadec/n1mode1") == 0 
	and getprop("/systems/fadec/n1mode2") == 0) {
		if (alpha > alphaProt and getprop("/position/gear-agl-ft") >= 100) {
			setprop("/systems/thrust/alpha-floor", 1);
			setprop("/systems/thrust/toga-lk", 0);
			setprop("/it-autoflight/input/athr", 1);
			setprop("/controls/engines/engine[0]/throttle-fdm", 0.99);
			setprop("/controls/engines/engine[1]/throttle-fdm", 0.99);
		} else if (getprop("/systems/thrust/alpha-floor") == 1 and alpha < togaLock) {
			setprop("/systems/thrust/alpha-floor", 0);
			setprop("/it-autoflight/input/athr", 1);
			setprop("/systems/thrust/toga-lk", 1);
			setprop("/controls/engines/engine[0]/throttle-fdm", 0.99);
			setprop("/controls/engines/engine[1]/throttle-fdm", 0.99);
		}
	} else {
		setprop("/systems/thrust/alpha-floor", 0);
		setprop("/systems/thrust/toga-lk", 0);
	}
});

var unflex = func {
	state1 = getprop("/systems/thrust/state1");
	state2 = getprop("/systems/thrust/state2");
	if (state1 != "MCT" and state2 != "MCT" and getprop("/gear/gear[1]/wow") == 0 and getprop("/gear/gear[2]/wow") == 0) {
		setprop("/systems/thrust/lim-flex", 0);
	}
}

var thrust_flash = maketimer(0.5, func {
	state1 = getprop("/systems/thrust/state1");
	state2 = getprop("/systems/thrust/state2");
	
	if (getprop("/gear/gear[1]/wow") == 0 and getprop("/gear/gear[2]/wow") == 0 and (getprop("/engines/engine[0]/state") != 3 or getprop("/engines/engine[1]/state") != 3)) {
		setprop("/systems/thrust/eng-out", 1);
	} else {
		setprop("/systems/thrust/eng-out", 0);
	}
	
	if (state1 == "CL" and state2 == "CL" and getprop("/systems/thrust/eng-out") != 1) {
		setprop("/systems/thrust/lvrclb", 0);
	} else if (state1 == "MCT" and state2 == "MCT" and getprop("/systems/thrust/lim-flex") != 1 and getprop("/systems/thrust/eng-out") == 1) {
		setprop("/systems/thrust/lvrclb", 0);
	} else {
		var status = getprop("/systems/thrust/lvrclb");
		if (status == 0) {
			if (getprop("/gear/gear[0]/wow") == 0) {
				if (getprop("/systems/thrust/state1") == "MAN" or getprop("/systems/thrust/state2") == "MAN") {
					setprop("/systems/thrust/lvrclb", 1);
				} else {
					if (getprop("/instrumentation/altimeter/indicated-altitude-ft") >= getprop("/systems/thrust/clbreduc-ft") and getprop("/gear/gear[1]/wow") == 0 and getprop("/gear/gear[2]/wow") == 0) {
						setprop("/systems/thrust/lvrclb", 1);
					} else if ((state1 == "CL" and state2 != "CL") or (state1 != "CL" and state2 == "CL") and getprop("/systems/thrust/eng-out") != 1) {
						setprop("/systems/thrust/lvrclb", 1);
					} else {
						setprop("/systems/thrust/lvrclb", 0);
					}
				}
			}
		} else if (status == 1) {
			setprop("/systems/thrust/lvrclb", 0);
		}
	}
});

setlistener("/systems/thrust/thr-locked", func {
	if (getprop("/systems/thrust/thr-locked") == 1) {
		setprop("/systems/thrust/thr-lock-cmd[0]", getprop("/controls/engines/engine[0]/throttle-output"));
		setprop("/systems/thrust/thr-lock-cmd[1]", getprop("/controls/engines/engine[1]/throttle-output"));
	}
}, 0, 0);
