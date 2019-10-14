# A3XX FMGC/Autoflight
# Joshua Davidson (Octal450) and Jonathan Redpath (legoboyvdlp)

# Copyright (c) 2019 Joshua Davidson (Octal450)

##################
# Init Functions #
##################

var database1 = 0;
var database2 = 0;
var code1 = 0;
var code2 = 0;
var gear0 = 0;
var state1 = 0;
var state2 = 0;
var flaps = 0;
var dep = "";
var arr = "";
var n1_left = 0;
var n1_right = 0;
var flaps = 0;
var modelat = 0;
var mode = 0;
var modeI = 0;
var gs = 0;
var alt = 0;
var aglalt = 0;
var cruiseft = 0;
var cruiseft_b = 0;
var newcruise = 0;
var phase = 0;
var state1 = 0;
var state2 = 0;
var wowl = 0;
var wowr = 0;
var targetalt = 0;
var targetvs = 0;
var targetfpa = 0;
var reduc_agl_ft = 0;
var locarm = 0;
var apprarm = 0;
var gear0 = 0;
var fd1 = 0;
var fd2 = 0;
var spd = 0;
var hdg = 0;
var alt = 0;
var altitude = 0;
var flap = 0;
var freqnav0uf = 0;
var freqnav0 = 0;
var namenav0 = "XX";
var freqnav1uf = 0;
var freqnav1 = 0;
var namenav1 = "XX";
var freqnav2uf = 0;
var freqnav2 = 0;
var namenav2 = "XX";
var freqnav3uf = 0;
var freqnav3 = 0;
var namenav3 = "XX";
var freqadf0uf = 0;
var freqadf0 = 0;
var nameadf0 = "XX";
var freqadf1uf = 0;
var freqadf1 = 0;
var nameadf1 = "XX";
var ias = 0;
var mach = 0;
var ktsmach = 0;
var mngktsmach = 0;
var mng_spd = 0;
var mng_spd_cmd = 0;
var kts_sel = 0;
var mach_sel = 0;
var srsSPD = 0;
var maxspeed = 0;
var minspeed = 0;
var mach_switchover = 0;
var decel = 0;
var mng_alt_spd_cmd = 0;
var mng_alt_spd = 0;
var mng_alt_mach_cmd = 0;
var mng_alt_mach = 0;
var mng_spd_cmd = 0;
var mng_spd = 0;
var ap1 = 0;
var ap2 = 0;
var flx = 0;
var lat = 0;
var newlat = 0;
var vert = 0;
var newvert = 0;
var newvertarm = 0;
var thr1 = 0;
var thr2 = 0;
setprop("/FMGC/internal/maxspeed", 0);
setprop("/FMGC/internal/minspeed", 0);
setprop("/position/gear-agl-ft", 0);
setprop("/FMGC/internal/mng-spd", 157);
setprop("/FMGC/internal/mng-spd-cmd", 157);
setprop("/FMGC/internal/mng-kts-mach", 0);
setprop("/FMGC/internal/mach-switchover", 0);
setprop("/it-autoflight/settings/reduc-agl-ft", 3000);
setprop("/it-autoflight/internal/vert-speed-fpm", 0);
setprop("/it-autoflight/output/fma-pwr", 0);
setprop("/instrumentation/nav[0]/nav-id", "XXX");
setprop("/instrumentation/nav[1]/nav-id", "XXX");
setprop("/FMGC/internal/ils1-mcdu", "XXX/999.99");
setprop("/FMGC/internal/ils2-mcdu", "XXX/999.99");
setprop("/FMGC/internal/vor1-mcdu", "XXX/999.99");
setprop("/FMGC/internal/vor2-mcdu", "999.99/XXX");
setprop("/FMGC/internal/adf1-mcdu", "XXX/999.99");
setprop("/FMGC/internal/adf2-mcdu", "999.99/XXX");
setprop("/gear/gear[0]/wow-fmgc", 1);

var FMGCinit = func {
	setprop("/FMGC/status/to-state", 0);
	setprop("/FMGC/status/phase", "0"); # 0 is Preflight 1 is Takeoff 2 is Climb 3 is Cruise 4 is Descent 5 is Decel/Approach 6 is Go Around 7 is Done
	setprop("/FMGC/internal/maxspeed", 338);
	setprop("/FMGC/internal/mng-spd", 157);
	setprop("/FMGC/internal/mng-spd-cmd", 157);
	setprop("/FMGC/internal/mng-kts-mach", 0);
	setprop("/FMGC/internal/mach-switchover", 0);
	setprop("/it-autoflight/settings/reduc-agl-ft", 3000);
	setprop("/FMGC/internal/decel", 0);
	setprop("/FMGC/internal/loc-source", "NAV0");
	setprop("/FMGC/internal/optalt", 0);
	masterFMGC.start();
	various.start();
	various2.start();
}

############
# FBW Trim #
############

setlistener("/gear/gear[0]/wow-fmgc", func {
	trimReset();
});

var trimReset = func {
	gear0 = getprop("/gear/gear[0]/wow");
	flaps = getprop("/controls/flight/flap-pos");
	if (gear0 == 1 and getprop("/FMGC/status/to-state") == 0 and (flaps >= 5 or (flaps >= 4 and getprop("/instrumentation/mk-viii/inputs/discretes/momentary-flap3-override") == 1))) {
		interpolate("/controls/flight/elevator-trim", 0.0, 1.5);
	}
}

###############
# MCDU Inputs #
###############

var updateARPT = func {
	dep = getprop("/FMGC/internal/dep-arpt");
	arr = getprop("/FMGC/internal/arr-arpt");
	setprop("/autopilot/route-manager/departure/airport", dep);
	setprop("/autopilot/route-manager/destination/airport", arr);
	if (getprop("/autopilot/route-manager/active") != 1) {
		fgcommand("activate-flightplan", props.Node.new({"activate": 1}));
	}
}

setlistener("/FMGC/internal/cruise-ft", func {
	setprop("/autopilot/route-manager/cruise/altitude-ft", getprop("/FMGC/internal/cruise-ft"));
});

############################
# Flight Phase and Various #
############################

var masterFMGC = maketimer(0.2, func {
	n1_left = getprop("/engines/engine[0]/n1-actual");
	n1_right = getprop("/engines/engine[1]/n1-actual");
	flaps = getprop("/controls/flight/flap-pos");
	modelat = getprop("/modes/pfd/fma/roll-mode");
	mode = getprop("/modes/pfd/fma/pitch-mode");
	modeI = getprop("/it-autoflight/mode/vert");
	gs = getprop("/velocities/groundspeed-kt");
	alt = getprop("/instrumentation/altimeter/indicated-altitude-ft");
	aglalt = getprop("/position/gear-agl-ft");
	cruiseft = getprop("/FMGC/internal/cruise-ft");
	cruiseft_b = getprop("/FMGC/internal/cruise-ft") - 200;
	newcruise = getprop("/it-autoflight/internal/alt");
	phase = getprop("/FMGC/status/phase");
	state1 = getprop("/systems/thrust/state1");
	state2 = getprop("/systems/thrust/state2");
	wowl = getprop("/gear/gear[1]/wow");
	wowr = getprop("/gear/gear[2]/wow");
	targetalt = getprop("/it-autoflight/internal/alt");
	targetvs = getprop("/it-autoflight/input/vs");
	targetfpa = getprop("/it-autoflight/input/fpa");
	reduc_agl_ft = getprop("/it-autoflight/settings/reduc-agl-ft");
	locarm = getprop("/it-autopilot/output/loc-armed");
	apprarm = getprop("/it-autopilot/output/appr-armed");
	gear0 = getprop("/gear/gear[0]/wow");
	ap1 = getprop("/it-autoflight/output/ap1");
	ap2 = getprop("/it-autoflight/output/ap2");
	flx = getprop("/systems/thrust/lim-flex");
	lat = getprop("/it-autoflight/mode/lat");
	newlat = getprop("/modes/pfd/fma/roll-mode");
	vert = getprop("/it-autoflight/mode/vert");
	newvert = getprop("/modes/pfd/fma/pitch-mode");
	newvertarm = getprop("/modes/pfd/fma/pitch-mode2-armed");
	thr1 = getprop("/controls/engines/engine[0]/throttle-pos");
	thr2 = getprop("/controls/engines/engine[1]/throttle-pos");
	gear0 = getprop("/gear/gear[0]/wow");
	state1 = getprop("/systems/thrust/state1");
	state2 = getprop("/systems/thrust/state2");
	
	if (getprop("/gear/gear[0]/wow") != getprop("/gear/gear[0]/wow-fmgc")) {
		setprop("/gear/gear[0]/wow-fmgc", getprop("/gear/gear[0]/wow"));
	}
	
	if ((n1_left < 70 or n1_right < 70) and gs < 90 and mode == " " and gear0 == 1 and phase == 1) {
		setprop("/FMGC/status/phase", "0");
		setprop("/systems/pressurization/mode", "GN");
	}
	
	if (gear0 == 1 and phase == 0 and ((n1_left >= 70 and n1_right >= 70) or gs >= 90) and (state1 == "TOGA" or state2 == "TOGA") or (flx == 1 and (state1 == "MCT" or state2 == "MCT")) or (flx == 1 and ((state1 == "MAN THR" and thr1 >= 0.83) or 
	(state2 == "MAN THR" and thr2 >= 0.83)))) {
		setprop("/FMGC/status/phase", "1");
		setprop("/systems/pressurization/mode", "TO");
	}
	
	if (phase == 1 and mode != "SRS" and mode != " ") {
		setprop("/FMGC/status/phase", "2");
		setprop("/systems/pressurization/mode", "TO");
	}
	
	if ((phase == 3 or phase == 4 or phase == 5 or phase == 6) and (mode == "OP CLB" or mode == "CLB" or (modeI == "V/S" and getprop("/it-autoflight/input/vs") >= 100) or (modeI == "FPA" and getprop("/it-autoflight/input/fpa") >= 0.1))) {
		setprop("/FMGC/status/phase", "2");
		setprop("/systems/pressurization/mode", "TO");
	}
	
	if ((phase == 2 or phase == 4 or phase == 5) and (mode == "ALT" or mode == "ALT CRZ" or mode == "ALT CST")) {
		setprop("/FMGC/status/phase", "3");
		setprop("/systems/pressurization/mode", "CR");
	}
	
	if ((phase == 2 or phase == 3) and (mode == "OP DES" or mode == "DES" or (modeI == "V/S" and getprop("/it-autoflight/input/vs") <= -100) or (modeI == "FPA" and getprop("/it-autoflight/input/fpa") <= -0.1))) {
		setprop("/FMGC/status/phase", "4");
		setprop("/systems/pressurization/mode", "DE");
	}
	
	if (getprop("/FMGC/status/to-state") == 0 and flaps >= 3 and (phase == "4" or mode == "G/S" or mode == "LAND" or mode == "FLARE")) {
		setprop("/FMGC/status/phase", "5");
	}
	
	if (getprop("/autopilot/route-manager/route/num") > 0 and getprop("/autopilot/route-manager/active") == 1 and getprop("/autopilot/route-manager/distance-remaining-nm") <= 15) {
		setprop("/FMGC/internal/decel", 1);
	} else if (getprop("/FMGC/internal/decel") == 1 and (phase == 0 or phase == 6)) {
		setprop("/FMGC/internal/decel", 0);
	}
	
	if (phase == "5" and state1 == "TOGA" and state2 == "TOGA") {
		setprop("/FMGC/status/phase", "6");
		setprop("/systems/pressurization/mode", "TO");
		setprop("/it-autoflight/input/toga", 1);
	}
	
	if (wowl and wowr and gs <= 40 and (phase == "2" or phase == "3" or phase == "4" or phase == "5" or phase == "6") and ap1 == 0 and ap2 == 0) {
		reset_FMGC();
	}
	
	flap = getprop("/controls/flight/flap-pos");
	if (flap == 0) { # 0
		setprop("/FMGC/internal/maxspeed", getprop("/it-fbw/speeds/vmo-mmo"));
		setprop("/FMGC/internal/minspeed", 202);
	} else if (flap == 1) { # 1
		setprop("/FMGC/internal/maxspeed", 230);
		setprop("/FMGC/internal/minspeed", 184);
	} else if (flap == 2) { # 1+F
		setprop("/FMGC/internal/maxspeed", 215);
		setprop("/FMGC/internal/minspeed", 171);
	} else if (flap == 3) { # 2
		setprop("/FMGC/internal/maxspeed", 200);
		setprop("/FMGC/internal/minspeed", 156);
	} else if (flap == 4) { # 3
		setprop("/FMGC/internal/maxspeed", 185);
		setprop("/FMGC/internal/minspeed", 147);
	} else if (flap == 5) { # FULL
		setprop("/FMGC/internal/maxspeed", 177);
		setprop("/FMGC/internal/minspeed", 131);
	}
	
	if (gear0 == 1 and (state1 == "MCT" or state1 == "MAN THR" or state1 == "TOGA") and (state2 == "MCT" or state2 == "MAN THR" or state2 == "TOGA") and flaps < 5) {
		setprop("/FMGC/status/to-state", 1);
	}
	if (getprop("/position/gear-agl-ft") >= 55) {
		setprop("/FMGC/status/to-state", 0);
	}
});

var reset_FMGC = func {
	setprop("/FMGC/status/phase", "7");
	fd1 = getprop("/it-autoflight/input/fd1");
	fd2 = getprop("/it-autoflight/input/fd2");
	spd = getprop("/it-autoflight/input/spd-kts");
	hdg = getprop("/it-autoflight/input/hdg");
	alt = getprop("/it-autoflight/input/alt");
	ITAF.init();
	FMGCinit();
	mcdu.MCDU_reset(0);
	mcdu.MCDU_reset(1);
	setprop("/it-autoflight/input/fd1", fd1);
	setprop("/it-autoflight/input/fd2", fd2);
	setprop("/it-autoflight/input/spd-kts", spd);
	setprop("/it-autoflight/input/hdg", hdg);
	setprop("/it-autoflight/input/alt", alt);
	setprop("/systems/pressurization/mode", "GN");
	setprop("/systems/pressurization/vs", "0");
	setprop("/systems/pressurization/targetvs", "0");
	setprop("/systems/pressurization/vs-norm", "0");
	setprop("/systems/pressurization/auto", 1);
	setprop("/systems/pressurization/deltap", "0");
	setprop("/systems/pressurization/outflowpos", "0");
	setprop("/systems/pressurization/deltap-norm", "0");
	setprop("/systems/pressurization/outflowpos-norm", "0");
	altitude = getprop("/instrumentation/altimeter/indicated-altitude-ft");
	setprop("/systems/pressurization/cabinalt", altitude);
	setprop("/systems/pressurization/targetalt", altitude); 
	setprop("/systems/pressurization/diff-to-target", "0");
	setprop("/systems/pressurization/ditchingpb", 0);
	setprop("/systems/pressurization/targetvs", "0");
	setprop("/systems/ventilation/cabin/fans", 0); # aircon fans
	setprop("/systems/ventilation/avionics/fan", 0);
	setprop("/systems/ventilation/avionics/extractvalve", "0");
	setprop("/systems/ventilation/avionics/inletvalve", "0");
	setprop("/systems/ventilation/lavatory/extractfan", 0);
	setprop("/systems/ventilation/lavatory/extractvalve", "0");
	setprop("/systems/pressurization/ambientpsi", "0");
	setprop("/systems/pressurization/cabinpsi", "0");
}

var various = maketimer(1, func {
	if (getprop("/engines/engine[0]/state") == 3 and getprop("/engines/engine[1]/state") != 3) {
		setprop("/it-autoflight/settings/reduc-agl-ft", getprop("/FMGC/internal/eng-out-reduc"));
	} else if (getprop("/engines/engine[0]/state") != 3 and getprop("/engines/engine[1]/state") == 3) {
		setprop("/it-autoflight/settings/reduc-agl-ft", getprop("/FMGC/internal/eng-out-reduc"));
	} else {
		setprop("/it-autoflight/settings/reduc-agl-ft", getprop("/FMGC/internal/reduc-agl-ft"));
	}
	
	setprop("/FMGC/internal/gw", math.round(getprop("/fdm/jsbsim/inertia/weight-lbs"), 100));
});

var various2 = maketimer(0.5, func {
	nav0();
	nav1();
	nav2();
	nav3();
	adf0();
	adf1();
});

var nav0 = func {
	var freqnav0uf = getprop("/instrumentation/nav[0]/frequencies/selected-mhz");
	var freqnav0 = sprintf("%.2f", freqnav0uf);
	var namenav0 = getprop("/instrumentation/nav[0]/nav-id");
	if (freqnav0 >= 108.10 and freqnav0 <= 111.95) {
		if (namenav0 != "") {
			setprop("/FMGC/internal/ils1-mcdu", namenav0 ~ "/" ~ freqnav0);
		} else {
			setprop("/FMGC/internal/ils1-mcdu", freqnav0);
		}
	}
}

var nav1 = func {
	var freqnav1uf = getprop("/instrumentation/nav[1]/frequencies/selected-mhz");
	var freqnav1 = sprintf("%.2f", freqnav1uf);
	var namenav1 = getprop("/instrumentation/nav[1]/nav-id");
	if (freqnav1 >= 108.10 and freqnav1 <= 111.95) {
		if (namenav1 != "") {
			setprop("/FMGC/internal/ils2-mcdu", freqnav1 ~ "/" ~ namenav1);
		} else {
			setprop("/FMGC/internal/ils2-mcdu", freqnav1);
		}
	}
}

var nav2 = func {
	var freqnav2uf = getprop("/instrumentation/nav[2]/frequencies/selected-mhz");
	var freqnav2 = sprintf("%.2f", freqnav2uf);
	var namenav2 = getprop("/instrumentation/nav[2]/nav-id");
	if (freqnav2 >= 108.00 and freqnav2 <= 117.95) {
		if (namenav2 != "") {
			setprop("/FMGC/internal/vor1-mcdu", namenav2 ~ "/" ~ freqnav2);
		} else {
			setprop("/FMGC/internal/vor1-mcdu", freqnav2);
		}
	}
}

var nav3 = func {
	var freqnav3uf = getprop("/instrumentation/nav[3]/frequencies/selected-mhz");
	var freqnav3 = sprintf("%.2f", freqnav3uf);
	var namenav3 = getprop("/instrumentation/nav[3]/nav-id");
	if (freqnav3 >= 108.00 and freqnav3 <= 117.95) {
		if (namenav3 != "") {
			setprop("/FMGC/internal/vor2-mcdu", freqnav3 ~ "/" ~ namenav3);
		} else {
			setprop("/FMGC/internal/vor2-mcdu", freqnav3);
		}
	}
}

var adf0 = func {
	var freqadf0uf = getprop("/instrumentation/adf[0]/frequencies/selected-khz");
	var freqadf0 = sprintf("%.2f", freqadf0uf);
	var nameadf0 = getprop("/instrumentation/adf[0]/ident");
	if (freqadf0 >= 190 and freqadf0 <= 1750) {
		if (nameadf0 != "") {
			setprop("/FMGC/internal/adf1-mcdu", nameadf0 ~ "/" ~ freqadf0);
		} else {
			setprop("/FMGC/internal/adf1-mcdu", freqadf0);
		}
	}
}

var adf1 = func {
	var freqadf1uf = getprop("/instrumentation/adf[1]/frequencies/selected-khz");
	var freqadf1 = sprintf("%.2f", freqadf1uf);
	var nameadf1 = getprop("/instrumentation/adf[1]/ident");
	if (freqadf1 >= 190 and freqadf1 <= 1750) {
		if (nameadf1 != "") {
			setprop("/FMGC/internal/adf2-mcdu", freqadf1 ~ "/" ~ nameadf1);
		} else {
			setprop("/FMGC/internal/adf2-mcdu", freqadf1);
		}
	}
}

#################
# Managed Speed #
#################

var ManagedSPD = maketimer(0.25, func {
	if (getprop("/FMGC/internal/cruise-lvl-set") == 1 and getprop("/FMGC/internal/cost-index-set") == 1) {
		if (getprop("/it-autoflight/input/spd-managed") == 1) {
			altitude = getprop("/instrumentation/altimeter/indicated-altitude-ft");
			mode = getprop("/modes/pfd/fma/pitch-mode");
			ias = getprop("/instrumentation/airspeed-indicator/indicated-speed-kt");
			mach = getprop("/instrumentation/airspeed-indicator/indicated-mach");
			ktsmach = getprop("/it-autoflight/input/kts-mach");
			mngktsmach = getprop("/FMGC/internal/mng-kts-mach");
			mng_spd = getprop("/FMGC/internal/mng-spd");
			mng_spd_cmd = getprop("/FMGC/internal/mng-spd-cmd");
			kts_sel = getprop("/it-autoflight/input/spd-kts");
			mach_sel = getprop("/it-autoflight/input/spd-mach");
			srsSPD = getprop("/it-autoflight/settings/togaspd");
			phase = getprop("/FMGC/status/phase"); # 0 is Preflight 1 is Takeoff 2 is Climb 3 is Cruise 4 is Descent 5 is Decel/Approach 6 is Go Around 7 is Done
			flap = getprop("/controls/flight/flap-pos");
			maxspeed = getprop("/FMGC/internal/maxspeed");
			minspeed = getprop("/FMGC/internal/minspeed");
			mach_switchover = getprop("/FMGC/internal/mach-switchover");
			decel = getprop("/FMGC/internal/decel");
			
			mng_alt_spd_cmd = getprop("/FMGC/internal/mng-alt-spd");
			mng_alt_spd = math.round(mng_alt_spd_cmd, 1);
			
			mng_alt_mach_cmd = getprop("/FMGC/internal/mng-alt-mach");
			mng_alt_mach = math.round(mng_alt_mach_cmd, 0.001);
			
			if (mach > mng_alt_mach and (phase == 2 or phase == 3)) {
				setprop("/FMGC/internal/mach-switchover", 1);
			}
			
			if (ias > mng_alt_spd and (phase == 4 or phase == 5)) {
				setprop("/FMGC/internal/mach-switchover", 0);
			}
			
			if ((mode == " " or mode == "SRS") and (phase == 0 or phase == 1)) {
				if (mngktsmach) {
					setprop("/FMGC/internal/mng-kts-mach", 0);
				}
				if (mng_spd_cmd != srsSPD) {
					setprop("/FMGC/internal/mng-spd-cmd", srsSPD);
				}
			} else if ((phase == 2 or phase == 3) and altitude <= 10050) {
				if (mngktsmach) {
					setprop("/FMGC/internal/mng-kts-mach", 0);
				}
				if (mng_spd_cmd != 250 and !decel) {
					setprop("/FMGC/internal/mng-spd-cmd", 250);
				} else if (mng_spd_cmd != minspeed and decel) {
					setprop("/FMGC/internal/mng-spd-cmd", minspeed);
				}
			} else if ((phase == 2 or phase == 3) and altitude > 10070 and !mach_switchover) {
				if (mngktsmach) {
					setprop("/FMGC/internal/mng-kts-mach", 0);
				}
				if (mng_spd_cmd != mng_alt_spd) {
					setprop("/FMGC/internal/mng-spd-cmd", mng_alt_spd);
				}
			} else if ((phase == 2 or phase == 3) and altitude > 10070 and mach_switchover) {
				if (!mngktsmach) {
					setprop("/FMGC/internal/mng-kts-mach", 1);
				}
				if (mng_spd_cmd != mng_alt_mach) {
					setprop("/FMGC/internal/mng-spd-cmd", mng_alt_mach);
				}
			} else if (phase == 4 and altitude > 11000 and !mach_switchover) {
				if (mngktsmach) {
					setprop("/FMGC/internal/mng-kts-mach", 0);
				}
				if (mng_spd_cmd != mng_alt_spd) {
					setprop("/FMGC/internal/mng-spd-cmd", mng_alt_spd);
				}
			} else if (phase == 4 and altitude > 11000 and mach_switchover) {
				if (!mngktsmach) {
					setprop("/FMGC/internal/mng-kts-mach", 1);
				}
				if (mng_spd_cmd != mng_alt_mach) {
					setprop("/FMGC/internal/mng-spd-cmd", mng_alt_mach);
				}
			} else if ((phase == 4 or phase == 5 or phase == 6) and altitude > 11000 and !mach_switchover) {
				if (mngktsmach) {
					setprop("/FMGC/internal/mng-kts-mach", 0);
				}
				if (mng_spd_cmd != mng_alt_spd and !decel) {
					setprop("/FMGC/internal/mng-spd-cmd", mng_alt_spd);
				} else if (mng_spd_cmd != minspeed and decel) {
					setprop("/FMGC/internal/mng-spd-cmd", minspeed);
				}
			} else if ((phase == 4 or phase == 5 or phase == 6) and altitude <= 10980) {
				if (mngktsmach) {
					setprop("/FMGC/internal/mng-kts-mach", 0);
				}
				if (mng_spd_cmd != 250 and !decel) {
					setprop("/FMGC/internal/mng-spd-cmd", 250);
				} else if (mng_spd_cmd != minspeed and decel) {
					setprop("/FMGC/internal/mng-spd-cmd", minspeed);
				}
			}
			
			mng_spd_cmd = getprop("/FMGC/internal/mng-spd-cmd");
			
			if (mng_spd_cmd > maxspeed -5) {
				setprop("/FMGC/internal/mng-spd", maxspeed -5);
			} else {
				setprop("/FMGC/internal/mng-spd", mng_spd_cmd);
			}
			
			if (ktsmach and !mngktsmach) {
				setprop("/it-autoflight/input/kts-mach", 0);
			} else if (!ktsmach and mngktsmach) {
				setprop("/it-autoflight/input/kts-mach", 1);
			}
			
			mng_spd = getprop("/FMGC/internal/mng-spd");
			
			if (kts_sel != mng_spd and !ktsmach) {
				setprop("/it-autoflight/input/spd-kts", mng_spd);
			} else if (mach_sel != mng_spd and ktsmach) {
				setprop("/it-autoflight/input/spd-mach", mng_spd);
			}
		} else {
			ManagedSPD.stop();
		}
	} else {
		ManagedSPD.stop();
		libraries.mcpSPDKnbPull();
	}
});

var switchDatabase = func {
	database1 = getprop("/FMGC/internal/navdatabase");
	database2 = getprop("/FMGC/internal/navdatabase2");
	code1 = getprop("/FMGC/internal/navdatabasecode");
	code2 = getprop("/FMGC/internal/navdatabasecode2");
	setprop("/FMGC/internal/navdatabase", database2);
	setprop("/FMGC/internal/navdatabase2", database1);
	setprop("/FMGC/internal/navdatabasecode", code2);
	setprop("/FMGC/internal/navdatabasecode2", code1);
}