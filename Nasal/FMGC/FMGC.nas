# A3XX FMGC/Autoflight
# Copyright (c) 2020 Josh Davidson (Octal450), Jonathan Redpath (legoboyvdlp), and Matthew Maring (mattmaring)

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
var accel_agl_ft = 0;
var locarm = 0;
var apprarm = 0;
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
var altsel = 0;
var crzFl = 0;
setprop("position/gear-agl-ft", 0);
setprop("/FMGC/internal/mng-spd", 157);
setprop("/FMGC/internal/mng-spd-cmd", 157);
setprop("/FMGC/internal/mng-kts-mach", 0);
setprop("/FMGC/internal/mach-switchover", 0);
setprop("/it-autoflight/settings/accel-agl-ft", 1500); #eventually set to 1500 above runway
setprop("/it-autoflight/internal/vert-speed-fpm", 0);
setprop("/it-autoflight/output/fma-pwr", 0);
setprop("instrumentation/nav[0]/nav-id", "XXX");
setprop("instrumentation/nav[1]/nav-id", "XXX");
setprop("/FMGC/internal/ils1-mcdu", "XXX/999.99");
setprop("/FMGC/internal/ils2-mcdu", "XXX/999.99");
setprop("/FMGC/internal/vor1-mcdu", "XXX/999.99");
setprop("/FMGC/internal/vor2-mcdu", "999.99/XXX");
setprop("/FMGC/internal/adf1-mcdu", "XXX/999.99");
setprop("/FMGC/internal/adf2-mcdu", "999.99/XXX");

var FMGCinit = func {
	fmgc.FMGCInternal.takeoffState = 0;
	fmgc.FMGCInternal.minspeed = 0;
	fmgc.FMGCInternal.maxspeed = 338;
	fmgc.FMGCInternal.phase = 0; # 0 is Preflight 1 is Takeoff 2 is Climb 3 is Cruise 4 is Descent 5 is Decel/Approach 6 is Go Around 7 is Done
	setprop("/FMGC/internal/mng-spd", 157);
	setprop("/FMGC/internal/mng-spd-cmd", 157);
	setprop("/FMGC/internal/mng-kts-mach", 0);
	setprop("/FMGC/internal/mach-switchover", 0);
	setprop("/FMGC/internal/loc-source", "NAV0");
	setprop("/FMGC/internal/optalt", 0);
	setprop("/FMGC/internal/landing-time", -99);
	setprop("/FMGC/internal/align1-time", -99);
	setprop("/FMGC/internal/align2-time", -99);
	setprop("/FMGC/internal/align3-time", -99);
	setprop("/FMGC/internal/block-fuel-time", -99);
	setprop("/FMGC/internal/fuel-pred-time", -99); 
	masterFMGC.start();
	radios.start();
}

var FMGCInternal = {
	# phase logic
	phase: 0,
	minspeed: 0,
	maxspeed: 0,
	takeoffState: 0,
	
	# speeds
	alpha_prot: 0,
	alpha_max: 0,
	vmo_mmo: 0,
	
	# PERF
	transAlt: 18000,
	transAltSet: 0,
	
	# PERF TO
	v1: 0,
	v1set: 0,
	vr: 0,
	vrset: 0,
	v2: 0,
	v2set: 0,
	
	# PERF APPR
	destMag: 0,
	destMagSet: 0,
	destWind: 0,
	destWindSet: 0,
	
	# INIT A
	altAirport: "",
	altAirportSet: 0,
	altSelected: 0,
	arrApt: "",
	costIndex: 0,
	costIndexSet: 0,
	crzFt: 10000,
	crzFl: 0,
	crzSet: 0,
	crzTemp: 15,
	crzTempSet: 0,
	flightNum: "",
	flightNumSet: 0,
	gndTemp: 15,
	gndTempSet: 0,
	depApt: "",
	tropo: 36090,
	tropoSet: 0,
	toFromSet: 0,
};

var postInit = func() {
	# Some properties had setlistener -- so to make sure all is o.k., we call function immediately like so:
	altvert();
	updateRouteManagerAlt();
	mcdu.updateCrzLvlCallback();
}

var FMGCNodes = {
	costIndex: props.globals.initNode("/FMGC/internal/cost-index", 0, "DOUBLE"),
	toFromSet: props.globals.initNode("/FMGC/internal/tofrom-set", 0, "BOOL"),
	v1: props.globals.initNode("/FMGC/internal/v1", 0, "DOUBLE"),
	v1set: props.globals.initNode("/FMGC/internal/v1-set", 0, "BOOL"),
	toState: props.globals.initNode("/FMGC/internal/to-state", 0, "BOOL"),
};

############
# FBW Trim #
############

setlistener("/gear/gear[0]/wow", func {
	trimReset();
}, 0, 0);

var trimReset = func {
	flaps = getprop("/controls/flight/flaps-pos");
	if (pts.Gear.wow[0].getBoolValue() and !fmgc.FMGCInternal.takeoffState and (flaps >= 5 or (flaps >= 4 and getprop("/instrumentation/mk-viii/inputs/discretes/momentary-flap3-override") == 1))) {
		interpolate("/controls/flight/elevator-trim", 0.0, 1.5);
	}
}

###############
# MCDU Inputs #
###############

var updateARPT = func {
	setprop("autopilot/route-manager/departure/airport", fmgc.FMGCInternal.depApt);
	setprop("autopilot/route-manager/destination/airport", fmgc.FMGCInternal.arrApt);
	setprop("autopilot/route-manager/alternate/airport", fmgc.FMGCInternal.altAirport);
	if (getprop("/autopilot/route-manager/active") != 1) {
		fgcommand("activate-flightplan", props.Node.new({"activate": 1}));
	}
}

updateRouteManagerAlt = func() {
	setprop("autopilot/route-manager/cruise/altitude-ft", FMGCInternal.crzFt);
};

########
# FUEL #
########
# Calculations maintained at https://github.com/mattmaring/A320-family-fuel-model
# Copyright (c) 2020 Matthew Maring (mattmaring)
#

var updateFuel = func {
	# Check engine status
	if (num(getprop("/engines/engine[0]/n1-actual")) > 0 or num(getprop("/engines/engine[1]/n1-actual")) > 0) {
		setprop("/FMGC/internal/block", sprintf("%3.1f", math.round(getprop("/consumables/fuel/total-fuel-lbs") / 1000, 0.1)));
	}

	# Calculate (final) holding fuel
	if (getprop("/FMGC/internal/final-fuel-set")) {
		final_fuel = 1000 * getprop("/FMGC/internal/final-fuel");
		zfw = 1000 * getprop("/FMGC/internal/zfw");
		final_time = final_fuel / (2.0 * ((zfw*zfw*-2e-10) + (zfw*0.0003) + 2.8903)); # x2 for 2 engines
		if (final_time < 0) {
			final_time = 0;
		} else if (final_time > 480) {
			final_time = 480;
		}
		if (num(final_time) >= 60) {
			final_min = int(math.mod(final_time, 60));
			final_hour = int((final_time - final_min) / 60);
			setprop("/FMGC/internal/final-time", sprintf("%02d", final_hour) ~ sprintf("%02d", final_min));
		} else {
			setprop("/FMGC/internal/final-time", sprintf("%04d", final_time));
		}	
	} else {
		if (!getprop("/FMGC/internal/final-time-set")) {
			setprop("/FMGC/internal/final-time", "0030");
		}
		final_time = int(getprop("/FMGC/internal/final-time"));
		if (final_time >= 100) {
			final_time = final_time - 100 + 60; # can't be set above 90 (0130)
		}
		zfw = 1000 * getprop("/FMGC/internal/zfw");
		final_fuel = final_time * 2.0 * ((zfw*zfw*-2e-10) + (zfw*0.0003) + 2.8903); # x2 for 2 engines
		if (final_fuel < 0) {
			final_fuel = 0;
		} else if (final_fuel > 80000) {
			final_fuel = 80000;
		}
		setprop("/FMGC/internal/final-fuel", final_fuel / 1000);
	}
	
	# Calculate alternate fuel
	if (!getprop("/FMGC/internal/alt-fuel-set") and fmgc.FMGCInternal.altAirportSet) {
		#calc
	} else if (getprop("/FMGC/internal/alt-fuel-set") and fmgc.FMGCInternal.altAirportSet) {
		#dummy calc for now
		alt_fuel = 1000 * num(getprop("/FMGC/internal/alt-fuel"));
		zfw = 1000 * getprop("/FMGC/internal/zfw");
		alt_time = alt_fuel / (2.0 * ((zfw*zfw*-2e-10) + (zfw*0.0003) + 2.8903)); # x2 for 2 engines
		if (alt_time < 0) {
			alt_time = 0;
		} else if (alt_time > 480) {
			alt_time = 480;
		}
		if (num(alt_time) >= 60) {
			alt_min = int(math.mod(alt_time, 60));
			alt_hour = int((alt_time - alt_min) / 60);
			setprop("/FMGC/internal/alt-time", sprintf("%02d", alt_hour) ~ sprintf("%02d", alt_min));
		} else {
			setprop("/FMGC/internal/alt-time", sprintf("%04d", alt_time));
		}
	} else if (!getprop("/FMGC/internal/alt-fuel-set")) {
		setprop("/FMGC/internal/alt-fuel", 0.0);
		setprop("/FMGC/internal/alt-time", "0000");
	}
	
	# Calculate min dest fob (final + alternate)
	if (!getprop("/FMGC/internal/min-dest-fob-set")) {
		setprop("/FMGC/internal/min-dest-fob", num(getprop("/FMGC/internal/alt-fuel") + getprop("/FMGC/internal/final-fuel")));
	}
	
	if (getprop("/FMGC/internal/zfw-set")) {
		setprop("/FMGC/internal/lw", num(getprop("/FMGC/internal/zfw") + getprop("/FMGC/internal/alt-fuel") + getprop("/FMGC/internal/final-fuel")));
	}
	
	# Calculate trip fuel
	if (FMGCInternal.toFromSet and FMGCInternal.crzSet and FMGCInternal.crzTempSet and getprop("/FMGC/internal/zfw-set")) {
		crz = FMGCInternal.crzFl;
		temp = FMGCInternal.crzTemp;
		dist = flightPlanController.arrivalDist;
		
		trpWind = getprop("/FMGC/internal/trip-wind");
		wind_value = getprop("/FMGC/internal/trip-wind-value");
		if (find("HD", trpWind) != -1 or find("-", trpWind) != -1 or find("H", trpWind) != -1) {
			wind_value = wind_value * -1;
		}
		dist = dist - (dist * wind_value * 0.002);

		#trip_fuel = 4.003e+02 + (dist * -5.399e+01) + (dist * dist * -7.322e-02) + (dist * dist * dist * 1.091e-05) + (dist * dist * dist * dist * 2.962e-10) + (dist * dist * dist * dist * dist * -1.178e-13) + (dist * dist * dist * dist * dist * dist * 6.322e-18) + (crz * 5.387e+01) + (dist * crz * 1.583e+00) + (dist * dist * crz * 7.695e-04) + (dist * dist * dist * crz * -1.057e-07) + (dist * dist * dist * dist * crz * 1.138e-12) + (dist * dist * dist * dist * dist * crz * 1.736e-16) + (crz * crz * -1.171e+00) + (dist * crz * crz * -1.219e-02) + (dist * dist * crz * crz * -2.879e-06) + (dist * dist * dist * crz * crz * 3.115e-10) + (dist * dist * dist * dist * crz * crz * -4.093e-15) + (crz * crz * crz * 9.160e-03) + (dist * crz * crz * crz * 4.311e-05) + (dist * dist * crz * crz * crz * 4.532e-09) + (dist * dist * dist * crz * crz * crz * -2.879e-13) + (crz * crz * crz * crz * -3.338e-05) + (dist * crz * crz * crz * crz * -7.340e-08) + (dist * dist * crz * crz * crz * crz * -2.494e-12) + (crz * crz * crz * crz * crz * 5.849e-08) + (dist * crz * crz * crz * crz * crz * 4.898e-11) + (crz * crz * crz * crz * crz * crz * -3.999e-11);
		trip_fuel = 4.018e+02 + (dist*3.575e+01) + (dist*dist*-4.260e-02) + (dist*dist*dist*-1.446e-05) + (dist*dist*dist*dist*4.101e-09) + (dist*dist*dist*dist*dist*-6.753e-13) + (dist*dist*dist*dist*dist*dist*5.074e-17) + (crz*-2.573e+01) + (dist*crz*-1.583e-01) + (dist*dist*crz*8.147e-04) + (dist*dist*dist*crz*4.485e-08) + (dist*dist*dist*dist*crz*-7.656e-12) + (dist*dist*dist*dist*dist*crz*4.503e-16) + (crz*crz*4.427e-01) + (dist*crz*crz*-1.137e-03) + (dist*dist*crz*crz*-4.409e-06) + (dist*dist*dist*crz*crz*-3.345e-11) + (dist*dist*dist*dist*crz*crz*4.985e-15) + (crz*crz*crz*-2.471e-03) + (dist*crz*crz*crz*1.223e-05) + (dist*dist*crz*crz*crz*9.660e-09) + (dist*dist*dist*crz*crz*crz*-2.127e-14) + (crz*crz*crz*crz*5.714e-06) + (dist*crz*crz*crz*crz*-3.546e-08) + (dist*dist*crz*crz*crz*crz*-7.536e-12) + (crz*crz*crz*crz*crz*-4.061e-09) + (dist*crz*crz*crz*crz*crz*3.355e-11) + (crz*crz*crz*crz*crz*crz*-1.451e-12);
		if (trip_fuel < 400) {
			trip_fuel = 400;
		} else if (trip_fuel > 80000) {
			trip_fuel = 80000;
		}
		
		# cruize temp correction
		trip_fuel = trip_fuel + (0.033 * (temp - 15 + (2 * crz / 10)) * flightPlanController.arrivalDist);
		
		trip_time = 9.095e-02 + (dist*-3.968e-02) + (dist*dist*4.302e-04) + (dist*dist*dist*2.005e-07) + (dist*dist*dist*dist*-6.876e-11) + (dist*dist*dist*dist*dist*1.432e-14) + (dist*dist*dist*dist*dist*dist*-1.177e-18) + (crz*7.348e-01) + (dist*crz*3.310e-03) + (dist*dist*crz*-8.700e-06) + (dist*dist*dist*crz*-4.214e-10) + (dist*dist*dist*dist*crz*5.652e-14) + (dist*dist*dist*dist*dist*crz*-6.379e-18) + (crz*crz*-1.449e-02) + (dist*crz*crz*-7.508e-06) + (dist*dist*crz*crz*4.529e-08) + (dist*dist*dist*crz*crz*3.699e-13) + (dist*dist*dist*dist*crz*crz*8.466e-18) + (crz*crz*crz*1.108e-04) + (dist*crz*crz*crz*-4.126e-08) + (dist*dist*crz*crz*crz*-9.645e-11) + (dist*dist*dist*crz*crz*crz*-1.544e-16) + (crz*crz*crz*crz*-4.123e-07) + (dist*crz*crz*crz*crz*1.831e-10) + (dist*dist*crz*crz*crz*crz*7.438e-14) + (crz*crz*crz*crz*crz*7.546e-10) + (dist*crz*crz*crz*crz*crz*-1.921e-13) + (crz*crz*crz*crz*crz*crz*-5.453e-13);
		if (trip_time < 10) {
			trip_time = 10;
		} else if (trip_time > 480) {
			trip_time = 480;
		}
		# if (low air conditioning) {
		#	trip_fuel = trip_fuel * 0.995;
		#}
		# if (total anti-ice) {
		#	trip_fuel = trip_fuel * 1.045;
		#} else if (engine anti-ice) {
		#	trip_fuel = trip_fuel * 1.02;
		#}
		
		zfw = getprop("/FMGC/internal/zfw");
		landing_weight_correction = 9.951e+00 + (dist*-2.064e+00) + (dist*dist*2.030e-03) + (dist*dist*dist*8.179e-08) + (dist*dist*dist*dist*-3.941e-11) + (dist*dist*dist*dist*dist*2.443e-15) + (crz*2.771e+00) + (dist*crz*3.067e-02) + (dist*dist*crz*-1.861e-05) + (dist*dist*dist*crz*2.516e-10) + (dist*dist*dist*dist*crz*5.452e-14) + (crz*crz*-4.483e-02) + (dist*crz*crz*-1.645e-04) + (dist*dist*crz*crz*5.212e-08) + (dist*dist*dist*crz*crz*-8.721e-13) + (crz*crz*crz*2.609e-04) + (dist*crz*crz*crz*3.898e-07) + (dist*dist*crz*crz*crz*-4.617e-11) + (crz*crz*crz*crz*-6.488e-07) + (dist*crz*crz*crz*crz*-3.390e-10) + (crz*crz*crz*crz*crz*5.835e-10);
		trip_fuel = trip_fuel + (landing_weight_correction * (getprop("/FMGC/internal/lw") * 1000 - 121254.24421) / 2204.622622);
		if (trip_fuel < 400) {
			trip_fuel = 400;
		} else if (trip_fuel > 80000) {
			trip_fuel = 80000;
		}

		setprop("/FMGC/internal/trip-fuel", trip_fuel / 1000);
		if (num(trip_time) >= 60) {
			trip_min = int(math.mod(trip_time, 60));
			trip_hour = int((trip_time - trip_min) / 60);
			setprop("/FMGC/internal/trip-time", sprintf("%02d", trip_hour) ~ sprintf("%02d", trip_min));
		} else {
			setprop("/FMGC/internal/trip-time", sprintf("%04d", trip_time));
		}
	} else {
		setprop("/FMGC/internal/trip-fuel", 0.0);
		setprop("/FMGC/internal/trip-time", "0000");
	}
	
	# Calculate reserve fuel
	if (getprop("/FMGC/internal/rte-rsv-set")) {
		if (num(getprop("/FMGC/internal/trip-fuel")) == 0.0) {
			setprop("/FMGC/internal/rte-percent", 0.0);
		} else {
			if (num(getprop("/FMGC/internal/rte-rsv") / getprop("/FMGC/internal/trip-fuel") * 100.0) <= 15.0) {
				setprop("/FMGC/internal/rte-percent", num(getprop("/FMGC/internal/rte-rsv") / getprop("/FMGC/internal/trip-fuel") * 100.0));
			} else {
				setprop("/FMGC/internal/rte-percent", 15.0); # need reasearch on this value
			}
		}
	} else if (getprop("/FMGC/internal/rte-percent-set")) {
		setprop("/FMGC/internal/rte-rsv", num(getprop("/FMGC/internal/trip-fuel") * getprop("/FMGC/internal/rte-percent") / 100.0));
	} else {
		if (num(getprop("/FMGC/internal/trip-fuel")) == 0.0) {
			setprop("/FMGC/internal/rte-percent", 5.0);
		} else {
			setprop("/FMGC/internal/rte-rsv", num(getprop("/FMGC/internal/trip-fuel") * getprop("/FMGC/internal/rte-percent") / 100.0));
		}
	}
	
	# Calcualte extra fuel
	if (getprop("/FMGC/internal/block-set")) {
		extra_fuel = 1000 * num(getprop("/FMGC/internal/block") - getprop("/FMGC/internal/trip-fuel") - getprop("/FMGC/internal/min-dest-fob") - getprop("/FMGC/internal/taxi-fuel") - getprop("/FMGC/internal/rte-rsv"));
		setprop("/FMGC/internal/extra-fuel", extra_fuel / 1000);
		lw = 1000 * getprop("/FMGC/internal/lw");
		extra_time = extra_fuel / (2.0 * ((lw*lw*-2e-10) + (lw*0.0003) + 2.8903)); # x2 for 2 engines
		if (extra_time < 0) {
			extra_time = 0;
		} else if (extra_time > 480) {
			extra_time = 480;
		}
		if (num(extra_time) >= 60) {
			extra_min = int(math.mod(extra_time, 60));
			extra_hour = int((extra_time - extra_min) / 60);
			setprop("/FMGC/internal/extra-time", sprintf("%02d", extra_hour) ~ sprintf("%02d", extra_min));
		} else {
			setprop("/FMGC/internal/extra-time", sprintf("%04d", extra_time));
		}
		if (getprop("/FMGC/internal/extra-fuel") > -0.1 and getprop("/FMGC/internal/extra-fuel") < 0.1) {
			setprop("/FMGC/internal/extra-fuel", 0.0);
		}
	} else {
		setprop("/FMGC/internal/block", num(getprop("/FMGC/internal/alt-fuel") + getprop("/FMGC/internal/final-fuel") + getprop("/FMGC/internal/trip-fuel") + getprop("/FMGC/internal/rte-rsv") + getprop("/FMGC/internal/taxi-fuel")));
		setprop("/FMGC/internal/block-set", 1);
	}
	
	setprop("/FMGC/internal/tow", num(getprop("/FMGC/internal/zfw") + getprop("/FMGC/internal/block") - getprop("/FMGC/internal/taxi-fuel")));
}

############################
# Flight Phase and Various #
############################

var nav0 = func {
	var freqnav0uf = getprop("/instrumentation/nav[0]/frequencies/selected-mhz");
	var freqnav0 = sprintf("%.2f", freqnav0uf);
	var namenav0 = getprop("/instrumentation/nav[0]/nav-id") or "";
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
	var namenav1 = getprop("/instrumentation/nav[1]/nav-id") or "";
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
	var namenav2 = getprop("/instrumentation/nav[2]/nav-id") or "";
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
	var namenav3 = getprop("/instrumentation/nav[3]/nav-id") or "";
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
	var nameadf0 = getprop("/instrumentation/adf[0]/ident") or "";
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
	var nameadf1 = getprop("/instrumentation/adf[1]/ident") or "";
	if (freqadf1 >= 190 and freqadf1 <= 1750) {
		if (nameadf1 != "") {
			setprop("/FMGC/internal/adf2-mcdu", freqadf1 ~ "/" ~ nameadf1);
		} else {
			setprop("/FMGC/internal/adf2-mcdu", freqadf1);
		}
	}
}

var radios = maketimer(1, func() {
	nav0();
	nav1();
	nav2();
	nav3();
	adf0();
	adf1();
});

var masterFMGC = maketimer(0.2, func {
	n1_left = getprop("/engines/engine[0]/n1-actual");
	n1_right = getprop("/engines/engine[1]/n1-actual");
	flaps = getprop("/controls/flight/flaps-pos");
	modelat = getprop("/modes/pfd/fma/roll-mode");
	mode = getprop("/modes/pfd/fma/pitch-mode");
	modeI = getprop("/it-autoflight/mode/vert");
	gs = getprop("/velocities/groundspeed-kt");
	alt = getprop("/instrumentation/altimeter/indicated-altitude-ft");
	aglalt = pts.Position.gearAglFt.getValue();
	# cruiseft = FMGCInternal.crzFt;
	# cruiseft_b = FMGCInternal.crzFt - 200;
	newcruise = getprop("/it-autoflight/internal/alt");
	phase = fmgc.FMGCInternal.phase;
	state1 = getprop("/systems/thrust/state1");
	state2 = getprop("/systems/thrust/state2");
	wowl = getprop("/gear/gear[1]/wow");
	wowr = getprop("/gear/gear[2]/wow");
	targetalt = getprop("/it-autoflight/internal/alt");
	targetvs = getprop("/it-autoflight/input/vs");
	targetfpa = getprop("/it-autoflight/input/fpa");
	accel_agl_ft = getprop("/it-autoflight/settings/accel-agl-ft");
	locarm = getprop("/it-autopilot/output/loc-armed");
	apprarm = getprop("/it-autopilot/output/appr-armed");
	gear0 = pts.Gear.wow[0].getBoolValue();
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
	altSel = getprop("/it-autoflight/input/alt");
	
	if ((n1_left < 85 or n1_right < 85) and gs < 90 and mode == " " and gear0 and FMGCInternal.phase == 1) { # rejected takeoff
		FMGCInternal.phase = 0;
		setprop("systems/pressurization/mode", "GN");
	}
	
	if (gear0 and FMGCInternal.phase == 0 and ((n1_left >= 85 and n1_right >= 85 and mode == "SRS") or gs >= 90)) {
		FMGCInternal.phase = 1;
		setprop("systems/pressurization/mode", "TO");
	}
	
	if (FMGCInternal.phase == 1 and ((mode != "SRS" and mode != " ") or alt >= accel_agl_ft)) {
		FMGCInternal.phase = 2;
		setprop("systems/pressurization/mode", "TO");
	}
	
	if (FMGCInternal.phase == 2 and (mode == "ALT CRZ" or mode == "ALT CRZ*")) {
		FMGCInternal.phase = 3;
		setprop("systems/pressurization/mode", "CR");
	}
	
	if (FMGCInternal.crzFl >= 200) {
		if (FMGCInternal.phase == 3 and (flightPlanController.arrivalDist <= 200 or altSel < 20000)) {
			FMGCInternal.phase = 4;
			setprop("systems/pressurization/mode", "DE");
		}
	} else {
		if (FMGCInternal.phase == 3 and (flightPlanController.arrivalDist <= 200 or altSel < (FMGCInternal.crzFl * 100))) { # todo - not sure about crzFl condition, investigate what happens!
			FMGCInternal.phase = 4;
			setprop("systems/pressurization/mode", "DE");
		}
	}
	
	if (FMGCInternal.phase == 4 and getprop("/FMGC/internal/decel")) {
		FMGCInternal.phase = 5;
	}

	if (flightPlanController.num[2].getValue() > 0 and getprop("/FMGC/flightplan[2]/active") == 1 and flightPlanController.arrivalDist <= 15 and (modelat == "NAV" or modelat == "LOC" or modelat == "LOC*") and aglalt < 9500) { #todo decel pseudo waypoint
		setprop("/FMGC/internal/decel", 1);
	} else if (getprop("/FMGC/internal/decel") == 1 and (FMGCInternal.phase == 0 or FMGCInternal.phase == 6)) {
		setprop("/FMGC/internal/decel", 0);
	}
	
	if ((FMGCInternal.phase == 5) and state1 == "TOGA" and state2 == "TOGA") {
		FMGCInternal.phase = 6;
		setprop("systems/pressurization/mode", "TO");
		setprop("/it-autoflight/input/toga", 1);
	}
	
	if (FMGCInternal.phase == 6 and alt >= accel_agl_ft) { # todo when insert altn or new dest
		FMGCInternal.phase = 2;
	}
	
	if (getprop("/systems/navigation/adr/computation/overspeed-vfe-spd") != 1024) {
		fmgc.FMGCInternal.maxspeed = getprop("/systems/navigation/adr/computation/overspeed-vfe-spd") - 4;
	} elsif (pts.Gear.position[0].getValue() != 0 or pts.Gear.position[1].getValue() != 0 or pts.Gear.position[2].getValue() != 0) {
		fmgc.FMGCInternal.maxspeed = 284;
	} else {
		fmgc.FMGCInternal.maxspeed = getprop("/it-fbw/speeds/vmo-mmo");
	}
	
	############################
	# calculate speeds
	############################
	flap = getprop("/controls/flight/flaps-pos");
	weight_lbs = getprop("/fdm/jsbsim/inertia/weight-lbs") / 1000;
	tow = getprop("/FMGC/internal/tow") or 0;
	lw = getprop("/FMGC/internal/lw") or 0;
	altitude = getprop("/instrumentation/altimeter/indicated-altitude-ft");
	
	# current speeds
	clean = 2 * weight_lbs * 0.45359237 + 85;
	if (altitude > 20000) {
		clean += (altitude - 20000) / 1000;
	}
	setprop("/FMGC/internal/computed-speeds/clean", clean);
	setprop("/FMGC/internal/computed-speeds/vs1g_clean", 0.0024 * weight_lbs * weight_lbs + 0.124 * weight_lbs + 88.942);
	setprop("/FMGC/internal/computed-speeds/vs1g_conf_1", -0.0007 * weight_lbs * weight_lbs + 0.6795 * weight_lbs + 44.673);
	setprop("/FMGC/internal/computed-speeds/vs1g_conf_1f", -0.0001 * weight_lbs * weight_lbs + 0.5211 * weight_lbs + 49.027);
	setprop("/FMGC/internal/computed-speeds/vs1g_conf_2", -0.0005 * weight_lbs * weight_lbs + 0.5488 * weight_lbs + 44.279);
	setprop("/FMGC/internal/computed-speeds/vs1g_conf_3", -0.0005 * weight_lbs * weight_lbs + 0.5488 * weight_lbs + 43.279);
	setprop("/FMGC/internal/computed-speeds/vs1g_conf_full", -0.0007 * weight_lbs * weight_lbs + 0.6002 * weight_lbs + 38.479);
	setprop("/FMGC/internal/computed-speeds/slat", num(getprop("/FMGC/internal/computed-speeds/vs1g_clean")) * 1.23);
	setprop("/FMGC/internal/computed-speeds/flap2", num(getprop("/FMGC/internal/computed-speeds/vs1g_conf_2")) * 1.47);
	setprop("/FMGC/internal/computed-speeds/flap3", num(getprop("/FMGC/internal/computed-speeds/vs1g_conf_3")) * 1.36);
	if (getprop("/FMGC/internal/ldg-config-3-set")) {
		vls = num(getprop("/FMGC/internal/computed-speeds/vs1g_conf_3")) * 1.23;
	} else {
		vls = num(getprop("/FMGC/internal/computed-speeds/vs1g_conf_full")) * 1.23
	}
	if (vls < 113) {
		vls = 113;
	}
	setprop("/FMGC/internal/computed-speeds/vls", vls);
	if (!getprop("/FMGC/internal/vapp-speed-set")) {
		if (fmgc.FMGCInternal.destWind < 5) {
			vapp = vls + 5;
		} else if (fmgc.FMGCInternal.destWind > 15) {
			vapp = vls + 15;
		} else {
			vapp = vls + fmgc.FMGCInternal.destWind;
		}
		setprop("/FMGC/internal/computed-speeds/vapp", vapp);
	}
	
	# predicted takeoff speeds
	if (FMGCInternal.phase == 1) {
		setprop("/FMGC/internal/computed-speeds/clean_to", getprop("/FMGC/internal/computed-speeds/clean"));
		setprop("/FMGC/internal/computed-speeds/vs1g_clean_to", getprop("/FMGC/internal/computed-speeds/vs1g_clean"));
		setprop("/FMGC/internal/computed-speeds/vs1g_conf_2_to", getprop("/FMGC/internal/computed-speeds/vs1g_conf_2"));
		setprop("/FMGC/internal/computed-speeds/vs1g_conf_3_to", getprop("/FMGC/internal/computed-speeds/vs1g_conf_3"));
		setprop("/FMGC/internal/computed-speeds/vs1g_conf_full_to", getprop("/FMGC/internal/computed-speeds/vs1g_conf_full"));
		setprop("/FMGC/internal/computed-speeds/slat_to", getprop("/FMGC/internal/computed-speeds/slat"));
		setprop("/FMGC/internal/computed-speeds/flap2_to", getprop("/FMGC/internal/computed-speeds/flap2"));
	} else {
		clean_to = 2 * tow * 0.45359237 + 85;
		if (altitude > 20000) {
			clean_to += (altitude - 20000) / 1000;
		}
		setprop("/FMGC/internal/computed-speeds/clean_to", clean_to);
		setprop("/FMGC/internal/computed-speeds/vs1g_clean_to", 0.0024 * tow * tow + 0.124 * tow + 88.942);
		setprop("/FMGC/internal/computed-speeds/vs1g_conf_2_to", -0.0005 * tow * tow + 0.5488 * tow + 44.279);
		setprop("/FMGC/internal/computed-speeds/vs1g_conf_3_to", -0.0005 * tow * tow + 0.5488 * tow + 43.279);
		setprop("/FMGC/internal/computed-speeds/vs1g_conf_full_to", -0.0007 * tow * tow + 0.6002 * tow + 38.479);
		setprop("/FMGC/internal/computed-speeds/slat_to", num(getprop("/FMGC/internal/computed-speeds/vs1g_clean_to")) * 1.23);
		setprop("/FMGC/internal/computed-speeds/flap2_to", num(getprop("/FMGC/internal/computed-speeds/vs1g_conf_2_to")) * 1.47);
	}
	
	# predicted approach (temp go-around) speeds
	if (FMGCInternal.phase == 5 or FMGCInternal.phase == 6) {
		setprop("/FMGC/internal/computed-speeds/clean_appr", getprop("/FMGC/internal/computed-speeds/clean"));
		setprop("/FMGC/internal/computed-speeds/vs1g_clean_appr", getprop("/FMGC/internal/computed-speeds/vs1g_clean"));
		setprop("/FMGC/internal/computed-speeds/vs1g_conf_2_appr", getprop("/FMGC/internal/computed-speeds/vs1g_conf_2"));
		setprop("/FMGC/internal/computed-speeds/vs1g_conf_3_appr", getprop("/FMGC/internal/computed-speeds/vs1g_conf_3"));
		setprop("/FMGC/internal/computed-speeds/vs1g_conf_full_appr", getprop("/FMGC/internal/computed-speeds/vs1g_conf_full"));
		setprop("/FMGC/internal/computed-speeds/slat_appr", getprop("/FMGC/internal/computed-speeds/slat"));
		setprop("/FMGC/internal/computed-speeds/flap2_appr", getprop("/FMGC/internal/computed-speeds/flap2"));
		setprop("/FMGC/internal/computed-speeds/vls_appr", getprop("/FMGC/internal/computed-speeds/vls"));
		if (!getprop("/FMGC/internal/vapp-speed-set")) {
			setprop("/FMGC/internal/computed-speeds/vapp_appr", getprop("/FMGC/internal/computed-speeds/vapp"));
		}
	} else {
		clean_appr = 2 * lw * 0.45359237 + 85;
		if (altitude > 20000) {
			clean_appr += (altitude - 20000) / 1000;
		}
		setprop("/FMGC/internal/computed-speeds/clean_appr", clean_appr);
		setprop("/FMGC/internal/computed-speeds/vs1g_clean_appr", 0.0024 * lw * lw + 0.124 * lw + 88.942);
		setprop("/FMGC/internal/computed-speeds/vs1g_conf_2_appr", -0.0005 * lw * lw + 0.5488 * lw + 44.279);
		setprop("/FMGC/internal/computed-speeds/vs1g_conf_3_appr", -0.0005 * lw * lw + 0.5488 * lw + 43.279);
		setprop("/FMGC/internal/computed-speeds/vs1g_conf_full_appr", -0.0007 * lw * lw + 0.6002 * lw + 38.479);
		setprop("/FMGC/internal/computed-speeds/slat_appr", num(getprop("/FMGC/internal/computed-speeds/vs1g_clean_appr")) * 1.23);
		setprop("/FMGC/internal/computed-speeds/flap2_appr", num(getprop("/FMGC/internal/computed-speeds/vs1g_conf_2_appr")) * 1.47);
		if (getprop("/FMGC/internal/ldg-config-3-set")) {
			vls_appr = num(getprop("/FMGC/internal/computed-speeds/vs1g_conf_3_appr")) * 1.23;
		} else {
			vls_appr = num(getprop("/FMGC/internal/computed-speeds/vs1g_conf_full_appr")) * 1.23
		}
		if (vls_appr < 113) {
			vls_appr = 113;
		}
		setprop("/FMGC/internal/computed-speeds/vls_appr", vls_appr);
		if (!getprop("/FMGC/internal/vapp-speed-set")) {
			if (fmgc.FMGCInternal.destWind < 5) {
				vapp_appr = vls_appr + 5;
			} else if (fmgc.FMGCInternal.destWind > 15) {
				vapp_appr = vls_appr + 15;
			} else {
				vapp_appr = vls_appr + fmgc.FMGCInternal.destWind;
			}
			setprop("/FMGC/internal/computed-speeds/vapp_appr", vapp_appr);
		}
	}
	
	# Need info on these, also correct for height at altitude...
	# https://www.pprune.org/archive/index.php/t-587639.html
	aoa_prot = 15;
	aoa_max = 17.5;
	aoa_0 = -5;
	aoa = getprop("/systems/navigation/adr/output/aoa-1");
	cas = getprop("/systems/navigation/adr/output/cas-1");
	if (aoa > -5) {
		fmgc.FMGCInternal.alpha_prot = cas * math.sqrt((aoa - aoa_0)/(aoa_prot - aoa_0));
		fmgc.FMGCInternal.alpha_max = cas * math.sqrt((aoa - aoa_0)/(aoa_max - aoa_0));
	} else {
		fmgc.FMGCInternal.alpha_prot = 0;
		fmgc.FMGCInternal.alpha_max = 0;
	}
	
	setprop("/FMGC/internal/computed-speeds/vs1g_conf_2_appr", getprop("/FMGC/internal/computed-speeds/vs1g_conf_2"));
	setprop("/FMGC/internal/computed-speeds/vs1g_conf_3_appr", getprop("/FMGC/internal/computed-speeds/vs1g_conf_3"));
	setprop("/FMGC/internal/computed-speeds/vs1g_conf_full_appr", getprop("/FMGC/internal/computed-speeds/vs1g_conf_full"));
	
	if (flap == 0) { # 0
		setprop("/FMGC/internal/computed-speeds/vsw", getprop("/FMGC/internal/computed-speeds/vs1g_clean"));
		fmgc.FMGCInternal.minspeed = getprop("/FMGC/internal/computed-speeds/clean");
		
		if (fmgc.FMGCInternal.takeoffState) {
			setprop("/FMGC/internal/computed-speeds/vls_min", num(getprop("/FMGC/internal/computed-speeds/vs1g_clean")) * 1.28);
		} else {
			setprop("/FMGC/internal/computed-speeds/vls_min", num(getprop("/FMGC/internal/computed-speeds/vs1g_clean")) * 1.23);
		}
	} else if (flap == 1) { # 1
		setprop("/FMGC/internal/computed-speeds/vsw", getprop("/FMGC/internal/computed-speeds/vs1g_conf_2")); 
		fmgc.FMGCInternal.minspeed = getprop("/FMGC/internal/computed-speeds/slat");
		
		if (fmgc.FMGCInternal.takeoffState) {
			setprop("/FMGC/internal/computed-speeds/vls_min", num(getprop("/FMGC/internal/computed-speeds/vs1g_conf_1")) * 1.28);
		} else {
			setprop("/FMGC/internal/computed-speeds/vls_min", num(getprop("/FMGC/internal/computed-speeds/vs1g_conf_1")) * 1.23);
		}
	} else if (flap == 2) { # 1+F
		setprop("/FMGC/internal/computed-speeds/vsw", getprop("/FMGC/internal/computed-speeds/vs1g_conf_1f"));
		fmgc.FMGCInternal.minspeed = getprop("/FMGC/internal/computed-speeds/slat");
		
		if (fmgc.FMGCInternal.takeoffState) {
			setprop("/FMGC/internal/computed-speeds/vls_min", num(getprop("/FMGC/internal/computed-speeds/vs1g_clean")) * 1.13);
		} else {
			setprop("/FMGC/internal/computed-speeds/vls_min", num(getprop("/FMGC/internal/computed-speeds/vs1g_conf_1f")) * 1.23);
		}
	} else if (flap == 3) { # 2
		setprop("/FMGC/internal/computed-speeds/vsw", getprop("/FMGC/internal/computed-speeds/vs1g_conf_2"));
		fmgc.FMGCInternal.minspeed = getprop("/FMGC/internal/computed-speeds/flap2");
		
		if (fmgc.FMGCInternal.takeoffState) {
			setprop("/FMGC/internal/computed-speeds/vls_min", num(getprop("/FMGC/internal/computed-speeds/vs1g_clean")) * 1.13);
		} else {
			setprop("/FMGC/internal/computed-speeds/vls_min", num(getprop("/FMGC/internal/computed-speeds/vs1g_conf_2")) * 1.23);
		}
	} else if (flap == 4) { # 3
		setprop("/FMGC/internal/computed-speeds/vsw", getprop("/FMGC/internal/computed-speeds/vs1g_conf_3"));
		fmgc.FMGCInternal.minspeed = getprop("/FMGC/internal/computed-speeds/flap3");
		
		if (fmgc.FMGCInternal.takeoffState) {
			setprop("/FMGC/internal/computed-speeds/vls_min", num(getprop("/FMGC/internal/computed-speeds/vs1g_clean")) * 1.13);
		} else {
			setprop("/FMGC/internal/computed-speeds/vls_min", num(getprop("/FMGC/internal/computed-speeds/vs1g_conf_3")) * 1.23);
		}
	} else if (flap == 5) { # FULL
		setprop("/FMGC/internal/computed-speeds/vsw", getprop("/FMGC/internal/computed-speeds/vs1g_conf_full"));
		fmgc.FMGCInternal.minspeed = getprop("/FMGC/internal/computed-speeds/vapp");
		
		if (fmgc.FMGCInternal.takeoffState) {
			setprop("/FMGC/internal/computed-speeds/vls_min", num(getprop("/FMGC/internal/computed-speeds/vs1g_clean")) * 1.13);
		} else {
			setprop("/FMGC/internal/computed-speeds/vls_min", num(getprop("/FMGC/internal/computed-speeds/vs1g_conf_full")) * 1.23);
		}
	}
	
	if (gear0 and flaps < 5 and (state1 == "MCT" or state1 == "MAN THR" or state1 == "TOGA") and (state2 == "MCT" or state2 == "MAN THR" or state2 == "TOGA")) {
		if (!fmgc.FMGCInternal.takeoffState) {
			fmgc.FMGCNodes.toState.setValue(1);
		}
		fmgc.FMGCInternal.takeoffState = 1;
	} elsif (pts.Position.gearAglFt.getValue() >= 55) {
		if (fmgc.FMGCInternal.takeoffState) {
			fmgc.FMGCNodes.toState.setValue(0);
		}
		fmgc.FMGCInternal.takeoffState = 0;
	}
	
	############################
	#handle radios, runways, v1/vr/v2
	############################
	
	departure_rwy = fmgc.flightPlanController.flightplans[2].departure_runway;
	destination_rwy = fmgc.flightPlanController.flightplans[2].destination_runway;
	if (destination_rwy != nil and phase >= 2) {
		var airport = airportinfo(fmgc.FMGCInternal.arrApt);
		setprop("/FMGC/internal/ldg-elev", airport.elevation * M2FT); # eventually should be runway elevation
		magnetic_hdg = geo.normdeg(destination_rwy.heading - getprop("/environment/magnetic-variation-deg"));
		runway_ils = destination_rwy.ils_frequency_mhz;
		if (runway_ils != nil and !getprop("/FMGC/internal/ils1freq-set") and !getprop("/FMGC/internal/ils1crs-set")) {
			setprop("/FMGC/internal/ils1freq-calculated", runway_ils);
			setprop("instrumentation/nav[0]/frequencies/selected-mhz", runway_ils);
			setprop("instrumentation/nav[0]/radials/selected-deg", magnetic_hdg);
		} else if (runway_ils != nil and !getprop("/FMGC/internal/ils1freq-set")) {
			setprop("/FMGC/internal/ils1freq-calculated", runway_ils);
			setprop("instrumentation/nav[0]/frequencies/selected-mhz", runway_ils);
		} else if (!getprop("/FMGC/internal/ils1crs-set")) {
			setprop("instrumentation/nav[0]/radials/selected-deg", magnetic_hdg);
		}
	} else if (departure_rwy != nil and phase <= 1) {
		magnetic_hdg = geo.normdeg(departure_rwy.heading - getprop("/environment/magnetic-variation-deg"));
		runway_ils = departure_rwy.ils_frequency_mhz;
		if (runway_ils != nil and !getprop("/FMGC/internal/ils1freq-set") and !getprop("/FMGC/internal/ils1crs-set")) {
			setprop("/FMGC/internal/ils1freq-calculated", runway_ils);
			setprop("instrumentation/nav[0]/frequencies/selected-mhz", runway_ils);
			setprop("instrumentation/nav[0]/radials/selected-deg", magnetic_hdg);
		} else if (runway_ils != nil and !getprop("/FMGC/internal/ils1freq-set")) {
			setprop("/FMGC/internal/ils1freq-calculated", runway_ils);
			setprop("instrumentation/nav[0]/frequencies/selected-mhz", runway_ils);
		} else if (!getprop("/FMGC/internal/ils1crs-set")) {
			setprop("instrumentation/nav[0]/radials/selected-deg", magnetic_hdg);
		}
	}
});

var reset_FMGC = func {
	fmgc.FMGCInternal.phase = 0;
	fd1 = getprop("/it-autoflight/input/fd1");
	fd2 = getprop("/it-autoflight/input/fd2");
	spd = getprop("/it-autoflight/input/kts");
	hdg = getprop("/it-autoflight/input/hdg");
	alt = getprop("/it-autoflight/input/alt");
	ITAF.init();
	FMGCinit();
	flightPlanController.reset();
	windController.reset();
	windController.init();
	
	mcdu.MCDU_reset(0);
	mcdu.MCDU_reset(1);
	setprop("it-autoflight/input/fd1", fd1);
	setprop("it-autoflight/input/fd2", fd2);
	setprop("it-autoflight/input/kts", spd);
	setprop("it-autoflight/input/hdg", hdg);
	setprop("it-autoflight/input/alt", alt);
	setprop("systems/pressurization/mode", "GN");
	setprop("systems/pressurization/vs", "0");
	setprop("systems/pressurization/targetvs", "0");
	setprop("systems/pressurization/vs-norm", "0");
	setprop("systems/pressurization/auto", 1);
	setprop("systems/pressurization/deltap", "0");
	setprop("systems/pressurization/outflowpos", "0");
	setprop("systems/pressurization/deltap-norm", "0");
	setprop("systems/pressurization/outflowpos-norm", "0");
	altitude = getprop("/instrumentation/altimeter/indicated-altitude-ft");
	setprop("systems/pressurization/cabinalt", altitude);
	setprop("systems/pressurization/targetalt", altitude); 
	setprop("systems/pressurization/diff-to-target", "0");
	setprop("systems/pressurization/ditchingpb", 0);
	setprop("systems/pressurization/targetvs", "0");
	setprop("systems/ventilation/cabin/fans", 0); # aircon fans
	setprop("systems/ventilation/avionics/fan", 0);
	setprop("systems/ventilation/avionics/extractvalve", "0");
	setprop("systems/ventilation/avionics/inletvalve", "0");
	setprop("systems/ventilation/lavatory/extractfan", 0);
	setprop("systems/ventilation/lavatory/extractvalve", "0");
	setprop("systems/pressurization/ambientpsi", "0");
	setprop("systems/pressurization/cabinpsi", "0");
	
	mcdu.ReceivedMessagesDatabase.clearDatabase();
}

#################
# Managed Speed #
#################

var ManagedSPD = maketimer(0.25, func {
	if (FMGCInternal.crzSet and FMGCInternal.costIndex) {
		if (getprop("/it-autoflight/input/spd-managed") == 1) {
			altitude = getprop("/instrumentation/altimeter/indicated-altitude-ft");
			mode = getprop("/modes/pfd/fma/pitch-mode");
			ias = getprop("/instrumentation/airspeed-indicator/indicated-speed-kt");
			mach = getprop("/instrumentation/airspeed-indicator/indicated-mach");
			ktsmach = getprop("/it-autoflight/input/kts-mach");
			mngktsmach = getprop("/FMGC/internal/mng-kts-mach");
			mng_spd = getprop("/FMGC/internal/mng-spd");
			mng_spd_cmd = getprop("/FMGC/internal/mng-spd-cmd");
			kts_sel = getprop("/it-autoflight/input/kts");
			mach_sel = getprop("/it-autoflight/input/mach");
			srsSPD = getprop("/it-autoflight/settings/togaspd");
			phase = fmgc.FMGCInternal.phase; # 0 is Preflight 1 is Takeoff 2 is Climb 3 is Cruise 4 is Descent 5 is Decel/Approach 6 is Go Around 7 is Done
			flap = getprop("/controls/flight/flaps-pos");
			mach_switchover = getprop("/FMGC/internal/mach-switchover");
			decel = getprop("/FMGC/internal/decel");
			
			mng_alt_spd_cmd = getprop("/FMGC/internal/mng-alt-spd");
			mng_alt_spd = math.round(mng_alt_spd_cmd, 1);
			
			mng_alt_mach_cmd = getprop("/FMGC/internal/mng-alt-mach");
			mng_alt_mach = math.round(mng_alt_mach_cmd, 0.001);
			
			if (mach > mng_alt_mach and (FMGCInternal.phase == 2 or FMGCInternal.phase == 3)) {
				setprop("/FMGC/internal/mach-switchover", 1);
			}
			
			if (ias > mng_alt_spd and (FMGCInternal.phase == 4 or FMGCInternal.phase == 5)) {
				setprop("/FMGC/internal/mach-switchover", 0);
			}
			
			if ((mode == " " or mode == "SRS") and (FMGCInternal.phase == 0 or FMGCInternal.phase == 1)) {
				if (mngktsmach) {
					setprop("/FMGC/internal/mng-kts-mach", 0);
				}
				if (mng_spd_cmd != srsSPD) {
					setprop("/FMGC/internal/mng-spd-cmd", srsSPD);
				}
			} else if ((FMGCInternal.phase == 2 or FMGCInternal.phase == 3) and altitude <= 10050) {
				if (mngktsmach) {
					setprop("/FMGC/internal/mng-kts-mach", 0);
				}
				if (mng_spd_cmd != 250 and !decel) {
					setprop("/FMGC/internal/mng-spd-cmd", 250);
				} else if (mng_spd_cmd != fmgc.FMGCInternal.minspeed and decel) {
					setprop("/FMGC/internal/mng-spd-cmd", fmgc.FMGCInternal.minspeed);
				}
			} else if ((FMGCInternal.phase == 2 or FMGCInternal.phase == 3) and altitude > 10070 and !mach_switchover) {
				if (mngktsmach) {
					setprop("/FMGC/internal/mng-kts-mach", 0);
				}
				if (mng_spd_cmd != mng_alt_spd) {
					setprop("/FMGC/internal/mng-spd-cmd", mng_alt_spd);
				}
			} else if ((FMGCInternal.phase == 2 or FMGCInternal.phase == 3) and altitude > 10070 and mach_switchover) {
				if (!mngktsmach) {
					setprop("/FMGC/internal/mng-kts-mach", 1);
				}
				if (mng_spd_cmd != mng_alt_mach) {
					setprop("/FMGC/internal/mng-spd-cmd", mng_alt_mach);
				}
			} else if (FMGCInternal.phase == 4 and altitude > 11000 and !mach_switchover) {
				if (mngktsmach) {
					setprop("/FMGC/internal/mng-kts-mach", 0);
				}
				if (mng_spd_cmd != mng_alt_spd) {
					setprop("/FMGC/internal/mng-spd-cmd", mng_alt_spd);
				}
			} else if (FMGCInternal.phase == 4 and altitude > 11000 and mach_switchover) {
				if (!mngktsmach) {
					setprop("/FMGC/internal/mng-kts-mach", 1);
				}
				if (mng_spd_cmd != mng_alt_mach) {
					setprop("/FMGC/internal/mng-spd-cmd", mng_alt_mach);
				}
			} else if ((FMGCInternal.phase == 4 or FMGCInternal.phase == 5 or FMGCInternal.phase == 6) and altitude > 11000 and !mach_switchover) {
				if (mngktsmach) {
					setprop("/FMGC/internal/mng-kts-mach", 0);
				}
				if (mng_spd_cmd != mng_alt_spd and !decel) {
					setprop("/FMGC/internal/mng-spd-cmd", mng_alt_spd);
				} else if (mng_spd_cmd != fmgc.FMGCInternal.minspeed and decel) {
					setprop("/FMGC/internal/mng-spd-cmd", fmgc.FMGCInternal.minspeed);
				}
			} else if ((FMGCInternal.phase == 4 or FMGCInternal.phase == 5 or FMGCInternal.phase == 6) and altitude <= 10980) {
				if (mngktsmach) {
					setprop("/FMGC/internal/mng-kts-mach", 0);
				}
				if (mng_spd_cmd != 250 and !decel) {
					setprop("/FMGC/internal/mng-spd-cmd", 250);
				} else if (mng_spd_cmd != fmgc.FMGCInternal.minspeed and decel) {
					setprop("/FMGC/internal/mng-spd-cmd", fmgc.FMGCInternal.minspeed);
				}
			}
			
			mng_spd_cmd = getprop("/FMGC/internal/mng-spd-cmd");
			
			if (mng_spd_cmd > fmgc.FMGCInternal.maxspeed - 5) {
				setprop("/FMGC/internal/mng-spd", fmgc.FMGCInternal.maxspeed - 5);
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
				setprop("/it-autoflight/input/kts", mng_spd);
			} else if (mach_sel != mng_spd and ktsmach) {
				setprop("/it-autoflight/input/mach", mng_spd);
			}
		} else {
			ManagedSPD.stop();
		}
	} else {
		ManagedSPD.stop();
		fcu.FCUController.SPDPull();
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

# Landing to phase 7
setlistener("/gear/gear[1]/wow", func() {
	if (getprop("/gear/gear[1]/wow") == 0 and timer30secLanding.isRunning) {
		timer30secLanding.stop();
		setprop("/FMGC/internal/landing-time", -99);
	}
	
	if (getprop("/gear/gear[1]/wow") == 1 and getprop("/FMGC/internal/landing-time") == -99) {
		timer30secLanding.start();
		setprop("/FMGC/internal/landing-time", pts.Sim.Time.elapsedSec.getValue());
	}
}, 0, 0);

# Align IRS 1
setlistener("/systems/navigation/adr/operating-1", func() {
	if (timer48gpsAlign1.isRunning) {
		timer48gpsAlign1.stop();
	}
	
	if (getprop("/FMGC/internal/align1-time") == -99) {
		timer48gpsAlign1.start();
		setprop("/FMGC/internal/align1-time", pts.Sim.Time.elapsedSec.getValue());
	}
}, 0, 0);

# Align IRS 2
setlistener("/systems/navigation/adr/operating-2", func() {
	if (timer48gpsAlign2.isRunning) {
		timer48gpsAlign2.stop();
	}
	
	if (getprop("/FMGC/internal/align2-time") == -99) {
		timer48gpsAlign2.start();
		setprop("/FMGC/internal/align2-time", pts.Sim.Time.elapsedSec.getValue());
	}
}, 0, 0);

# Align IRS 3
setlistener("/systems/navigation/adr/operating-3", func() {
	if (timer48gpsAlign3.isRunning) {
		timer48gpsAlign3.stop();
	}
	
	if (getprop("/FMGC/internal/align3-time") == -99) {
		timer48gpsAlign3.start();
		setprop("/FMGC/internal/align3-time", pts.Sim.Time.elapsedSec.getValue());
	}
}, 0, 0);

# Calculate Block Fuel
setlistener("/FMGC/internal/block-calculating", func() {
	if (timer3blockFuel.isRunning) {
		setprop("/FMGC/internal/block-fuel-time", -99);
		timer3blockFuel.start();
		setprop("/FMGC/internal/block-fuel-time", pts.Sim.Time.elapsedSec.getValue());
	}
	
	if (getprop("/FMGC/internal/block-fuel-time") == -99) {
		timer3blockFuel.start();
		setprop("/FMGC/internal/block-fuel-time", pts.Sim.Time.elapsedSec.getValue());
	}
}, 0, 0);

# Calculate Fuel Prediction
setlistener("/FMGC/internal/fuel-calculating", func() {
	if (timer5fuelPred.isRunning) {
		setprop("/FMGC/internal/fuel-pred-time", -99);
		timer5fuelPred.start();
		setprop("/FMGC/internal/fuel-pred-time", pts.Sim.Time.elapsedSec.getValue());
	}
	
	if (getprop("/FMGC/internal/fuel-pred-time") == -99) {
		timer5fuelPred.start();
		setprop("/FMGC/internal/fuel-pred-time", pts.Sim.Time.elapsedSec.getValue());
	}
}, 0, 0);

# Maketimers
var timer30secLanding = maketimer(1, func() {
	if (pts.Sim.Time.elapsedSec.getValue() > getprop("/FMGC/internal/landing-time") + 30) {
		fmgc.FMGCInternal.phase = 7;
		if (FMGCInternal.costIndexSet) {
			setprop("/FMGC/internal/last-cost-index", FMGCInternal.costIndex);
		} else {
			setprop("/FMGC/internal/last-cost-index", 0);
		}
		setprop("/FMGC/internal/landing-time", -99);
		timer30secLanding.stop();
	}
});

var timer48gpsAlign1 = maketimer(1, func() {
	if (pts.Sim.Time.elapsedSec.getValue() > getprop("/FMGC/internal/align1-time") + 48 or getprop("/systems/acconfig/options/adirs-skip")) {
		setprop("/FMGC/internal/align1-done", 1);
		setprop("/FMGC/internal/align1-time", -99);
		timer48gpsAlign1.stop();
	}
});

var timer48gpsAlign2 = maketimer(1, func() {
	if (pts.Sim.Time.elapsedSec.getValue() > getprop("/FMGC/internal/align2-time") + 48 or getprop("/systems/acconfig/options/adirs-skip")) {
		setprop("/FMGC/internal/align2-done", 1);
		setprop("/FMGC/internal/align2-time", -99);
		timer48gpsAlign2.stop();
	}
});

var timer48gpsAlign3 = maketimer(1, func() {
	if (pts.Sim.Time.elapsedSec.getValue() > getprop("/FMGC/internal/align3-time") + 48 or getprop("/systems/acconfig/options/adirs-skip")) {
		setprop("/FMGC/internal/align3-done", 1);
		setprop("/FMGC/internal/align3-time", -99);
		timer48gpsAlign3.stop();
	}
});

var timer3blockFuel = maketimer(1, func() {
	if (pts.Sim.Time.elapsedSec.getValue() > getprop("/FMGC/internal/block-fuel-time") + 3) {
		updateFuel();
		setprop("/FMGC/internal/block-calculating", 0);
		setprop("/FMGC/internal/block-fuel-time", -99); 
		timer3blockFuel.stop();
	}
});

var timer5fuelPred = maketimer(1, func() {
	if (pts.Sim.Time.elapsedSec.getValue() > getprop("/FMGC/internal/fuel-pred-time") + 5) {
		updateFuel();
		setprop("/FMGC/internal/fuel-calculating", 0);
		setprop("/FMGC/internal/fuel-pred-time", -99); 
		timer5fuelPred.stop();
	}
});