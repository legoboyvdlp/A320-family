# A3XX Fuel System
# Joshua Davidson (Octal450)

# Copyright (c) 2019 Joshua Davidson (Octal450)

var xfeed_sw = getprop("/controls/fuel/x-feed");
var tank0pump1_sw = 0;
var tank0pump2_sw = 0;
var tank1pump1_sw = 0;
var tank1pump2_sw = 0;
var tank2pump1_sw = 0;
var tank2pump2_sw = 0;
var mode_sw = 0;
var xfeed = 0;
var ac1 = 0;
var ac2 = 0;
var gravityfeedL = 0;
var gravityfeedR = 0;
var gload = 0;
var gravityfeedL_output = 0;
var gravityfeedR_output = 0;
var tank0 = 0;
var tank1 = 0;
var tank2 = 0;
var gravityfeedL = 0;
var gravityfeedR = 0;
var tank0pump1_fail = 0;
var tank0pump2_fail = 0;
var tank1pump1_fail = 0;
var tank1pump2_fail = 0;
var tank2pump1_fail = 0;
var tank2pump2_fail = 0;

var FUEL = {
	init: func() {
		setprop("/systems/fuel/gravityfeedL", 0);
		setprop("/systems/fuel/gravityfeedR", 0);
		setprop("/systems/fuel/gravityfeedL-output", 0);
		setprop("/systems/fuel/gravityfeedR-output", 0);
		setprop("/controls/fuel/x-feed", 0);
		setprop("/controls/fuel/tank0pump1", 0);
		setprop("/controls/fuel/tank0pump2", 0);
		setprop("/controls/fuel/tank1pump1", 0);
		setprop("/controls/fuel/tank1pump2", 0);
		setprop("/controls/fuel/tank2pump1", 0);
		setprop("/controls/fuel/tank2pump2", 0);
		setprop("/controls/fuel/mode", 1);
		setprop("/systems/fuel/x-feed", 0);
		setprop("/systems/fuel/tank[0]/feed", 0);
		setprop("/systems/fuel/tank[1]/feed", 0);
		setprop("/systems/fuel/tank[2]/feed", 0);
		setprop("/systems/fuel/only-use-ctr-tank", 0);
		setprop("/systems/fuel/tank0pump1-fault", 0);
		setprop("/systems/fuel/tank0pump2-fault", 0);
		setprop("/systems/fuel/tank1pump1-fault", 0);
		setprop("/systems/fuel/tank1pump2-fault", 0);
		setprop("/systems/fuel/tank2pump1-fault", 0);
		setprop("/systems/fuel/tank2pump2-fault", 0);
		setprop("/systems/fuel/mode-fault", 0);
	},
	loop: func() {
		xfeed_sw = getprop("/controls/fuel/x-feed");
		tank0pump1_sw = getprop("/controls/fuel/tank0pump1");
		tank0pump2_sw = getprop("/controls/fuel/tank0pump2");
		tank1pump1_sw = getprop("/controls/fuel/tank1pump1");
		tank1pump2_sw = getprop("/controls/fuel/tank1pump2");
		tank2pump1_sw = getprop("/controls/fuel/tank2pump1");
		tank2pump2_sw = getprop("/controls/fuel/tank2pump2");
		mode_sw = getprop("/controls/fuel/mode");
		xfeed = getprop("/systems/fuel/x-feed");
		ac1 = getprop("/systems/electrical/bus/ac-1");
		ac2 = getprop("/systems/electrical/bus/ac-2");
		gravityfeedL = getprop("/systems/fuel/gravityfeedL");
		gravityfeedR = getprop("/systems/fuel/gravityfeedR");
		gload = getprop("/accelerations/pilot-gdamped");
		tank0pump1_fail = getprop("/systems/failures/tank0pump1");
		tank0pump2_fail = getprop("/systems/failures/tank0pump2");
		tank1pump1_fail = getprop("/systems/failures/tank1pump1");
		tank1pump2_fail = getprop("/systems/failures/tank1pump2");
		tank2pump1_fail = getprop("/systems/failures/tank2pump1");
		tank2pump2_fail = getprop("/systems/failures/tank2pump2");
		
		if (gload >= 0.7 and gravityfeedL) {
			setprop("/systems/fuel/gravityfeedL-output", 1);
		} else {
			setprop("/systems/fuel/gravityfeedL-output", 0);
		}
		
		if (gload >= 0.7 and gravityfeedR) {
			setprop("/systems/fuel/gravityfeedR-output", 1);
		} else {
			setprop("/systems/fuel/gravityfeedR-output", 0);
		}
		
		gravityfeedL_output = getprop("/systems/fuel/gravityfeedL-output");
		gravityfeedR_output = getprop("/systems/fuel/gravityfeedR-output");
		
		if ((ac1 >= 110 or ac2 >= 110) and tank0pump1_sw and !tank0pump1_fail) {
			setprop("/systems/fuel/tank[0]/feed", 1);
		} else if ((ac1 >= 110 or ac2 >= 110) and tank0pump2_sw and !tank0pump2_fail) {
			setprop("/systems/fuel/tank[0]/feed", 1);
		} else if (gravityfeedL_output) {
			setprop("/systems/fuel/tank[0]/feed", 1);
		} else {
			setprop("/systems/fuel/tank[0]/feed", 0);
		}
		
		if ((ac1 >= 110 or ac2 >= 110) and tank1pump1_sw and !tank1pump1_fail) {
			setprop("/systems/fuel/tank[1]/feed", 1);
		} else if ((ac1 >= 110 or ac2 >= 110) and tank1pump2_sw and !tank1pump2_fail) {
			setprop("/systems/fuel/tank[1]/feed", 1);
		} else {
			setprop("/systems/fuel/tank[1]/feed", 0);
		}
		
		if ((ac1 >= 110 or ac2 >= 110) and tank2pump1_sw and !tank2pump1_fail) {
			setprop("/systems/fuel/tank[2]/feed", 1);
		} else if ((ac1 >= 110 or ac2 >= 110) and tank2pump2_sw and !tank2pump2_fail) {
			setprop("/systems/fuel/tank[2]/feed", 1);
		} else if (gravityfeedR_output) {
			setprop("/systems/fuel/tank[2]/feed", 1);
		} else {
			setprop("/systems/fuel/tank[2]/feed", 0);
		}
		
		if ((ac1 >= 110 or ac2 >= 110) and xfeed_sw) {
			setprop("/systems/fuel/x-feed", 1);
		} else {
			setprop("/systems/fuel/x-feed", 0);
		}
		
		tank0 = getprop("/systems/fuel/tank[0]/feed");
		tank1 = getprop("/systems/fuel/tank[1]/feed");
		tank2 = getprop("/systems/fuel/tank[2]/feed");
		
		if ((ac1 >= 110 or ac2 >= 110) and (tank0pump1_sw or tank0pump2_sw)) {
			setprop("/systems/fuel/gravityfeedL", 0);
		} else {
			setprop("/systems/fuel/gravityfeedL", 1);
		}
		
		if ((ac1 >= 110 or ac2 >= 110) and (tank2pump1_sw or tank2pump2_sw)) {
			setprop("/systems/fuel/gravityfeedR", 0);
		} else {
			setprop("/systems/fuel/gravityfeedR", 1);
		}
		
		gravityfeedL = getprop("/systems/fuel/gravityfeedL");
		gravityfeedR = getprop("/systems/fuel/gravityfeedR");
		
		if ((getprop("/fdm/jsbsim/propulsion/tank[1]/contents-lbs") >= 50) and (tank1pump1_sw or tank1pump2_sw) and !gravityfeedL and !gravityfeedR) {
			setprop("/systems/fuel/only-use-ctr-tank", 1);
		} else {
			setprop("/systems/fuel/only-use-ctr-tank", 0);
		}
		
		# Fault lights
		if (tank0pump1_sw and tank0pump1_fail) {
			setprop("/systems/fuel/tank0pump1-fault", 1);
		} else {
			setprop("/systems/fuel/tank0pump1-fault", 0);
		}
		
		if (tank0pump2_sw and tank0pump2_fail) {
			setprop("/systems/fuel/tank0pump2-fault", 1);
		} else {
			setprop("/systems/fuel/tank0pump2-fault", 0);
		}
		
		if (tank1pump1_sw and tank1pump1_fail) {
			setprop("/systems/fuel/tank1pump1-fault", 1);
		} else {
			setprop("/systems/fuel/tank1pump1-fault", 0);
		}
		
		if (tank1pump2_sw and tank1pump2_fail) {
			setprop("/systems/fuel/tank1pump2-fault", 1);
		} else {
			setprop("/systems/fuel/tank1pump2-fault", 0);
		}
		
		if (tank2pump1_sw and tank2pump1_fail) {
			setprop("/systems/fuel/tank2pump1-fault", 1);
		} else {
			setprop("/systems/fuel/tank2pump1-fault", 0);
		}
		
		if (tank2pump2_sw and tank2pump2_fail) {
			setprop("/systems/fuel/tank2pump2-fault", 1);
		} else {
			setprop("/systems/fuel/tank2pump2-fault", 0);
		}
	},
};
