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
	FMGCInternal.takeoffState = 0;
	FMGCInternal.minspeed = 0;
	FMGCInternal.maxspeed = 338;
	FMGCInternal.phase = 0; # 0 is Preflight 1 is Takeoff 2 is Climb 3 is Cruise 4 is Descent 5 is Decel/Approach 6 is Go Around 7 is Done
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
	vsw: 0,
	vls_min: 0,
	clean: 0,
	vs1g_clean: 0,
	vs1g_conf_1: 0,
	vs1g_conf_1f: 0,
	vs1g_conf_2: 0,
	vs1g_conf_3: 0,
	vs1g_conf_full: 0,
	slat: 0,
	flap2: 0,
	flap3: 0,
	vls: 0,
	vapp: 0,
	clean_to: 0,
	vs1g_clean_to: 0,
	vs1g_conf_2_to: 0,
	vs1g_conf_3_to: 0,
	vs1g_conf_full_to: 0,
	slat_to: 0,
	flap2_to: 0,
	clean_appr: 0,
	vs1g_clean_appr: 0,
	vs1g_conf_2_appr: 0,
	vs1g_conf_3_appr: 0,
	vs1g_conf_full_appr: 0,
	slat_appr: 0,
	flap2_appr: 0,
	vls_appr: 0,
	vapp_appr: 0,
	
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
	
	# INIT B
	zfw: 0,
	zfwSet: 0,
	zfwcg: 25.0,
	zfwcgSet: 0,
	block: 0.0,
	blockSet: 0,
	taxiFuel: 0.4,
	taxiFuelSet: 0,
	tripFuel: 0,
	tripTime: "0000",
	rteRsv: 0,
	rteRsvSet: 0,
	rtePercent: 5.0,
	rtePercentSet: 0,
	altFuel: 0,
	altFuelSet: 0,
	altTime: "0000",
	finalFuel: 0,
	finalFuelSet: 0,
	finalTime: "0030",
	finalTimeSet: 0,
	minDestFob: 0,
	minDestFobSet: 0,
	tow: 0,
	lw: 0,
	tripWind: "HD000",
	tripWindValue: 0,
	fffqSensor: "FF+FQ",
	extraFuel: 0,
	extraTime: "0000",
	
	# FUELPRED
	priUtc: "0000",
	altUtc: "0000",
	priEfob: 0,
	altEfob: 0,
	fob: 0,
	fuelPredGw: 0,
	cg: 0,
	
	# NAV
	clbFuel: 0,
	clbTime: 0,
	clbDist: 0,
	clbSet: 0,
	
	desFuel: 0,
	desTime: 0,
	desDist: 0,
	desSet: 0,
};

var postInit = func() {
	# Some properties had setlistener -- so to make sure all is o.k., we call function immediately like so:
	altvert();
	updateRouteManagerAlt();
	mcdu.updateCrzLvlCallback();
}

var FMGCNodes = {
	costIndex: props.globals.initNode("/FMGC/internal/cost-index", 0, "DOUBLE"),
	flexSet: props.globals.initNode("/FMGC/internal/flex-set", 0, "BOOL"),
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
	if (pts.Gear.wow[0].getBoolValue() and !FMGCInternal.takeoffState and (flaps >= 5 or (flaps >= 4 and getprop("/instrumentation/mk-viii/inputs/discretes/momentary-flap3-override") == 1))) {
		interpolate("/controls/flight/elevator-trim", 0.0, 1.5);
	}
}

###############
# MCDU Inputs #
###############

var updateARPT = func {
	setprop("autopilot/route-manager/departure/airport", FMGCInternal.depApt);
	setprop("autopilot/route-manager/destination/airport", FMGCInternal.arrApt);
	setprop("autopilot/route-manager/alternate/airport", FMGCInternal.altAirport);
	if (getprop("/autopilot/route-manager/active") != 1) {
		fgcommand("activate-flightplan", props.Node.new({"activate": 1}));
	}
}

var updateArptLatLon = func {
	#ref lat
	dms = getprop("/FMGC/flightplan[2]/wp[0]/lat");
	degrees = int(dms);
	minutes = sprintf("%.1f",abs((dms - degrees) * 60));
	sign = degrees >= 0 ? "N" : "S";
	setprop("/FMGC/internal/align-ref-lat-degrees", degrees);
	setprop("/FMGC/internal/align-ref-lat-minutes", minutes);
	setprop("/FMGC/internal/align-ref-lat-sign", sign);
	#ref long
	dms = getprop("/FMGC/flightplan[2]/wp[0]/lon");
	degrees = int(dms);
	minutes = sprintf("%.1f",abs((dms - degrees) * 60));
	sign = degrees >= 0 ? "E" : "W";
	setprop("/FMGC/internal/align-ref-long-degrees", degrees);
	setprop("/FMGC/internal/align-ref-long-minutes", minutes);
	setprop("/FMGC/internal/align-ref-long-sign", sign);
	#ref edit
	setprop("/FMGC/internal/align-ref-lat-edit", 0);
	setprop("/FMGC/internal/align-ref-long-edit", 0);
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
	# Calculate (final) holding fuel
	if (FMGCInternal.finalFuelSet) {
		final_fuel = 1000 * FMGCInternal.finalFuel;
		zfw = 1000 * FMGCInternal.zfw;
		final_time = final_fuel / (2.0 * ((zfw*zfw*-2e-10) + (zfw*0.0003) + 2.8903)); # x2 for 2 engines
		if (final_time < 0) {
			final_time = 0;
		} else if (final_time > 480) {
			final_time = 480;
		}
		if (num(final_time) >= 60) {
			final_min = int(math.mod(final_time, 60));
			final_hour = int((final_time - final_min) / 60);
			FMGCInternal.finalTime = sprintf("%02d", final_hour) ~ sprintf("%02d", final_min);
		} else {
			FMGCInternal.finalTime = sprintf("%04d", final_time);
		}	
	} else {
		if (!FMGCInternal.finalTimeSet) {
			FMGCInternal.finalTime = "0030";
		}
		final_time = int(FMGCInternal.finalTime);
		if (final_time >= 100) {
			final_time = final_time - 100 + 60; # can't be set above 90 (0130)
		}
		zfw = 1000 * FMGCInternal.zfw;
		final_fuel = final_time * 2.0 * ((zfw*zfw*-2e-10) + (zfw*0.0003) + 2.8903); # x2 for 2 engines
		if (final_fuel < 0) {
			final_fuel = 0;
		} else if (final_fuel > 80000) {
			final_fuel = 80000;
		}
		FMGCInternal.finalFuel = final_fuel / 1000;
	}
	
	# Calculate alternate fuel
	if (!FMGCInternal.altFuelSet and FMGCInternal.altAirportSet) {
		#calc
	} else if (FMGCInternal.altFuelSet and FMGCInternal.altAirportSet) {
		#dummy calc for now
		alt_fuel = 1000 * num(FMGCInternal.altFuel);
		zfw = 1000 * FMGCInternal.zfw;
		alt_time = alt_fuel / (2.0 * ((zfw*zfw*-2e-10) + (zfw*0.0003) + 2.8903)); # x2 for 2 engines
		if (alt_time < 0) {
			alt_time = 0;
		} else if (alt_time > 480) {
			alt_time = 480;
		}
		if (num(alt_time) >= 60) {
			alt_min = int(math.mod(alt_time, 60));
			alt_hour = int((alt_time - alt_min) / 60);
			FMGCInternal.altTime = sprintf("%02d", alt_hour) ~ sprintf("%02d", alt_min);
		} else {
			FMGCInternal.altTime = sprintf("%04d", alt_time);
		}
	} else if (!FMGCInternal.altFuelSet) {
		FMGCInternal.altFuel = 0.0;
		FMGCInternal.altTime = "0000";
	}
	
	# Calculate min dest fob (final + alternate)
	if (!FMGCInternal.minDestFobSet) {
		FMGCInternal.minDestFob = num(FMGCInternal.altFuel + FMGCInternal.finalFuel);
	}
	
	if (FMGCInternal.zfwSet) {
		FMGCInternal.lw = num(FMGCInternal.zfw + FMGCInternal.altFuel + FMGCInternal.finalFuel);
	}
	
	# Calculate trip fuel
	if (FMGCInternal.toFromSet and FMGCInternal.crzSet and FMGCInternal.crzTempSet and FMGCInternal.zfwSet) {
		crz = FMGCInternal.crzFl;
		temp = FMGCInternal.crzTemp;
		dist = flightPlanController.arrivalDist;
		
		trpWind = FMGCInternal.tripWind;
		wind_value = FMGCInternal.tripWindValue;
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
		
		zfw = FMGCInternal.zfw;
		landing_weight_correction = 9.951e+00 + (dist*-2.064e+00) + (dist*dist*2.030e-03) + (dist*dist*dist*8.179e-08) + (dist*dist*dist*dist*-3.941e-11) + (dist*dist*dist*dist*dist*2.443e-15) + (crz*2.771e+00) + (dist*crz*3.067e-02) + (dist*dist*crz*-1.861e-05) + (dist*dist*dist*crz*2.516e-10) + (dist*dist*dist*dist*crz*5.452e-14) + (crz*crz*-4.483e-02) + (dist*crz*crz*-1.645e-04) + (dist*dist*crz*crz*5.212e-08) + (dist*dist*dist*crz*crz*-8.721e-13) + (crz*crz*crz*2.609e-04) + (dist*crz*crz*crz*3.898e-07) + (dist*dist*crz*crz*crz*-4.617e-11) + (crz*crz*crz*crz*-6.488e-07) + (dist*crz*crz*crz*crz*-3.390e-10) + (crz*crz*crz*crz*crz*5.835e-10);
		trip_fuel = trip_fuel + (landing_weight_correction * (FMGCInternal.lw * 1000 - 121254.24421) / 2204.622622);
		if (trip_fuel < 400) {
			trip_fuel = 400;
		} else if (trip_fuel > 80000) {
			trip_fuel = 80000;
		}

		FMGCInternal.tripFuel = trip_fuel / 1000;
		if (num(trip_time) >= 60) {
			trip_min = int(math.mod(trip_time, 60));
			trip_hour = int((trip_time - trip_min) / 60);
			FMGCInternal.tripTime = sprintf("%02d", trip_hour) ~ sprintf("%02d", trip_min);
		} else {
			FMGCInternal.tripTime = sprintf("%04d", trip_time);
		}
	} else {
		FMGCInternal.tripFuel = 0.0;
		FMGCInternal.tripTime = "0000";
	}
	
	# Calculate reserve fuel
	if (FMGCInternal.rteRsvSet) {
		if (num(FMGCInternal.tripFuel) <= 0.0) {
			FMGCInternal.rtePercent = 0.0;
		} else {
			if (num(FMGCInternal.rteRsv / FMGCInternal.tripFuel * 100.0) <= 15.0) {
				FMGCInternal.rtePercent = num(FMGCInternal.rteRsv / FMGCInternal.tripFuel * 100.0);
			} else {
				FMGCInternal.rtePercent = 15.0; # need reasearch on this value
			}
		}
	} else if (FMGCInternal.rtePercentSet) {
		FMGCInternal.rteRsv = num(FMGCInternal.tripFuel * FMGCInternal.rtePercent / 100.0);
	} else {
		if (num(FMGCInternal.tripFuel) <= 0.0) {
			FMGCInternal.rtePercent = 5.0;
		} else {
			FMGCInternal.rteRsv = num(FMGCInternal.tripFuel * FMGCInternal.rtePercent / 100.0);
		}
	}
	
	# Misc fuel claclulations
	if (getprop("/FMGC/internal/block-calculating")) {
		FMGCInternal.block = num(FMGCInternal.altFuel + FMGCInternal.finalFuel + FMGCInternal.tripFuel + FMGCInternal.rteRsv + FMGCInternal.taxiFuel);
		FMGCInternal.blockSet = 1;
	}
	fmgc.FMGCInternal.fob = num(getprop("/consumables/fuel/total-fuel-lbs") / 1000);
	fmgc.FMGCInternal.fuelPredGw = num(getprop("/fdm/jsbsim/inertia/weight-lbs") / 1000);
	fmgc.FMGCInternal.cg = fmgc.FMGCInternal.zfwcg;
	
	# Calculate extra fuel
	if (num(getprop("/engines/engine[0]/n1-actual")) > 0 or num(getprop("/engines/engine[1]/n1-actual")) > 0) {
		extra_fuel = 1000 * num(FMGCInternal.fob - FMGCInternal.tripFuel - FMGCInternal.minDestFob - FMGCInternal.taxiFuel - FMGCInternal.rteRsv);
	} else {
		extra_fuel = 1000 * num(FMGCInternal.block - FMGCInternal.tripFuel - FMGCInternal.minDestFob - FMGCInternal.taxiFuel - FMGCInternal.rteRsv);
	}
	FMGCInternal.extraFuel = extra_fuel / 1000;
	lw = 1000 * FMGCInternal.lw;
	extra_time = extra_fuel / (2.0 * ((lw*lw*-2e-10) + (lw*0.0003) + 2.8903)); # x2 for 2 engines
	if (extra_time < 0) {
		extra_time = 0;
	} else if (extra_time > 480) {
		extra_time = 480;
	}
	if (num(extra_time) >= 60) {
		extra_min = int(math.mod(extra_time, 60));
		extra_hour = int((extra_time - extra_min) / 60);
		FMGCInternal.extraTime = sprintf("%02d", extra_hour) ~ sprintf("%02d", extra_min);
	} else {
		FMGCInternal.extraTime = sprintf("%04d", extra_time);
	}
	if (FMGCInternal.extraFuel > -0.1 and FMGCInternal.extraFuel < 0.1) {
		FMGCInternal.extraFuel = 0.0;
	}
	
	FMGCInternal.tow = num(FMGCInternal.zfw + FMGCInternal.block - FMGCInternal.taxiFuel);
	
	# Calculate climb fuel
	if (FMGCInternal.toFromSet and FMGCInternal.crzSet and FMGCInternal.crzTempSet and FMGCInternal.zfwSet) {
		crz = FMGCInternal.crzFl;
		temp = FMGCInternal.crzTemp - 15 + (2 * crz / 10); # crz temp minus ISA
		tow = FMGCInternal.tow;
		
		FMGCInternal.clbFuel = 1.421139e-02 + (crz*3.236393e+03) + (crz*crz*1.120007e+00) + (crz*crz*crz*-2.722871e-03) + (crz*crz*crz*crz*7.256755e-06) + (crz*crz*crz*crz*crz*-1.612218e-08) + (crz*crz*crz*crz*crz*crz*1.326596e-11) + (tow*-2.096727e+03) + (crz*tow*-1.174940e+02) + (crz*crz*tow*-2.446904e-02) + (crz*crz*crz*tow*2.697128e-05) + (crz*crz*crz*crz*tow*2.964427e-10) + (crz*crz*crz*crz*crz*tow*5.392939e-13) + (tow*tow*7.508311e+01) + (crz*tow*tow*1.691499e+00) + (crz*crz*tow*tow*2.260348e-04) + (crz*crz*crz*tow*tow*-2.122250e-07) + (crz*crz*crz*crz*tow*tow*9.535209e-12) + (tow*tow*tow*-1.068184e+00) + (crz*tow*tow*tow*-1.208297e-02) + (crz*crz*tow*tow*tow*-8.634399e-07) + (crz*crz*crz*tow*tow*tow*5.221886e-10) + (tow*tow*tow*tow*7.556674e-03) + (crz*tow*tow*tow*tow*4.283091e-05) + (crz*crz*tow*tow*tow*tow*1.127184e-09) + (tow*tow*tow*tow*tow*-2.658266e-05) + (crz*tow*tow*tow*tow*tow*-6.025789e-08) + (tow*tow*tow*tow*tow*tow*3.720043e-08) + (temp*-2.910550e+04) + (crz*temp*1.285581e+01) + (crz*crz*temp*-1.272942e-02) + (crz*crz*crz*temp*-3.925488e-06) + (crz*crz*crz*crz*temp*4.165313e-08) + (crz*crz*crz*crz*crz*temp*-1.131495e-11) + (tow*temp*1.039383e+03) + (crz*tow*temp*-3.514567e-01) + (crz*crz*tow*temp*3.116650e-04) + (crz*crz*crz*tow*temp*-2.045133e-07) + (crz*crz*crz*crz*tow*temp*-2.171672e-10) + (tow*tow*temp*-1.474017e+01) + (crz*tow*tow*temp*3.469855e-03) + (crz*crz*tow*tow*temp*-2.021211e-06) + (crz*crz*crz*tow*tow*temp*1.475405e-09) + (tow*tow*tow*temp*1.038394e-01) + (crz*tow*tow*tow*temp*-1.486194e-05) + (crz*crz*tow*tow*tow*temp*3.292894e-09) + (tow*tow*tow*tow*temp*-3.635322e-04) + (crz*tow*tow*tow*tow*temp*2.370644e-08) + (tow*tow*tow*tow*tow*temp*5.061256e-07) + (temp*temp*-6.049159e+00) + (crz*temp*temp*9.271569e-03) + (crz*crz*temp*temp*-4.787863e-05) + (crz*crz*crz*temp*temp*1.544306e-07) + (crz*crz*crz*crz*temp*temp*-1.189408e-10) + (tow*temp*temp*1.618150e-01) + (crz*tow*temp*temp*-1.244027e-04) + (crz*crz*tow*temp*temp*1.847018e-07) + (crz*crz*crz*tow*temp*temp*-5.084243e-10) + (tow*tow*temp*temp*-1.634968e-03) + (crz*tow*tow*temp*temp*7.582337e-07) + (crz*crz*tow*tow*temp*temp*2.039694e-10) + (tow*tow*tow*temp*temp*7.357701e-06) + (crz*tow*tow*tow*temp*temp*-1.997496e-09) + (tow*tow*tow*tow*temp*temp*-1.238556e-08) + (temp*temp*temp*-1.556897e+00) + (crz*temp*temp*temp*3.820685e-03) + (crz*crz*temp*temp*temp*-1.536057e-06) + (crz*crz*crz*temp*temp*temp*4.479777e-10) + (tow*temp*temp*temp*2.904938e-02) + (crz*tow*temp*temp*temp*-4.732752e-05) + (crz*crz*tow*temp*temp*temp*1.881360e-08) + (tow*tow*temp*temp*temp*-1.862818e-04) + (crz*tow*tow*temp*temp*temp*1.615777e-07) + (tow*tow*tow*temp*temp*temp*4.064634e-07) + (temp*temp*temp*temp*7.111483e-04) + (crz*temp*temp*temp*temp*4.605684e-07) + (crz*crz*temp*temp*temp*temp*-2.085822e-09) + (tow*temp*temp*temp*temp*-1.033525e-05) + (crz*tow*temp*temp*temp*temp*1.427061e-09) + (tow*tow*temp*temp*temp*temp*3.527457e-08) + (temp*temp*temp*temp*temp*2.890019e-04) + (crz*temp*temp*temp*temp*temp*-9.768280e-07) + (tow*temp*temp*temp*temp*temp*-1.589498e-06) + (temp*temp*temp*temp*temp*temp*-2.382194e-09);
		FMGCInternal.clbTime = 8.546574e-05 + (crz*-1.218477e+00) + (crz*crz*-7.124805e-03) + (crz*crz*crz*-6.089542e-06) + (crz*crz*crz*crz*6.577291e-08) + (crz*crz*crz*crz*crz*-1.518018e-10) + (crz*crz*crz*crz*crz*crz*1.197574e-13) + (tow*1.424043e+01) + (crz*tow*5.830025e-02) + (crz*crz*tow*1.989222e-04) + (crz*crz*crz*tow*-1.371607e-07) + (crz*crz*crz*crz*tow*5.306187e-12) + (crz*crz*crz*crz*crz*tow*8.582371e-14) + (tow*tow*-5.053610e-01) + (crz*tow*tow*-9.894229e-04) + (crz*crz*tow*tow*-1.722098e-06) + (crz*crz*crz*tow*tow*7.331638e-10) + (crz*crz*crz*crz*tow*tow*-1.696028e-13) + (tow*tow*tow*7.100580e-03) + (crz*tow*tow*tow*7.726864e-06) + (crz*crz*tow*tow*tow*6.781362e-09) + (crz*crz*crz*tow*tow*tow*-1.012461e-12) + (tow*tow*tow*tow*-4.937929e-05) + (crz*tow*tow*tow*tow*-2.876036e-08) + (crz*crz*tow*tow*tow*tow*-1.054797e-11) + (tow*tow*tow*tow*tow*1.701731e-07) + (crz*tow*tow*tow*tow*tow*4.180070e-11) + (tow*tow*tow*tow*tow*tow*-2.327957e-10) + (temp*-1.487934e+02) + (crz*temp*1.635853e-01) + (crz*crz*temp*-6.533805e-05) + (crz*crz*crz*temp*-8.593744e-08) + (crz*crz*crz*crz*temp*1.929578e-10) + (crz*crz*crz*crz*crz*temp*-9.294195e-14) + (tow*temp*5.055150e+00) + (crz*tow*temp*-4.650570e-03) + (crz*crz*tow*temp*2.197799e-06) + (crz*crz*crz*tow*temp*-1.790411e-10) + (crz*crz*crz*crz*tow*temp*-6.980202e-13) + (tow*tow*temp*-6.816110e-02) + (crz*tow*tow*temp*4.759886e-05) + (crz*crz*tow*tow*temp*-1.775598e-08) + (crz*crz*crz*tow*tow*temp*3.773141e-12) + (tow*tow*tow*temp*4.566271e-04) + (crz*tow*tow*tow*temp*-2.104527e-07) + (crz*crz*tow*tow*tow*temp*4.057553e-11) + (tow*tow*tow*tow*temp*-1.521686e-06) + (crz*tow*tow*tow*tow*temp*3.424056e-10) + (tow*tow*tow*tow*tow*temp*2.019730e-09) + (temp*temp*-4.691397e-02) + (crz*temp*temp*-4.589895e-05) + (crz*crz*temp*temp*-3.063260e-08) + (crz*crz*crz*temp*temp*7.825434e-10) + (crz*crz*crz*crz*temp*temp*-7.469565e-13) + (tow*temp*temp*1.369177e-03) + (crz*tow*temp*temp*7.097826e-07) + (crz*crz*tow*temp*temp*-2.011447e-09) + (crz*crz*crz*tow*temp*temp*-1.785053e-12) + (tow*tow*temp*temp*-1.444385e-05) + (crz*tow*tow*temp*temp*-2.111174e-09) + (crz*crz*tow*tow*temp*temp*1.004928e-11) + (tow*tow*tow*temp*temp*6.632896e-08) + (crz*tow*tow*tow*temp*temp*-2.408713e-12) + (tow*tow*tow*tow*temp*temp*-1.129910e-10) + (temp*temp*temp*-1.581872e-04) + (crz*temp*temp*temp*2.438163e-05) + (crz*crz*temp*temp*temp*-5.665674e-08) + (crz*crz*crz*temp*temp*temp*3.737388e-11) + (tow*temp*temp*temp*-1.353915e-05) + (crz*tow*temp*temp*temp*-2.243763e-07) + (crz*crz*tow*temp*temp*temp*3.526936e-10) + (tow*tow*temp*temp*temp*1.368333e-07) + (crz*tow*tow*temp*temp*temp*5.825907e-10) + (tow*tow*tow*temp*temp*temp*-3.081415e-10) + (temp*temp*temp*temp*-6.442379e-07) + (crz*temp*temp*temp*temp*3.243133e-08) + (crz*crz*temp*temp*temp*temp*-2.379161e-11) + (tow*temp*temp*temp*temp*-2.815596e-08) + (crz*tow*temp*temp*temp*temp*-1.459261e-10) + (tow*tow*temp*temp*temp*temp*2.232566e-10) + (temp*temp*temp*temp*temp*1.805413e-06) + (crz*temp*temp*temp*temp*temp*-6.375023e-09) + (tow*temp*temp*temp*temp*temp*-9.569016e-09) + (temp*temp*temp*temp*temp*temp*-2.201936e-09);
		FMGCInternal.clbDist = 2.733214e-04 + (crz*3.303628e+00) + (crz*crz*-1.942714e-02) + (crz*crz*crz*3.719504e-05) + (crz*crz*crz*crz*-4.153478e-08) + (crz*crz*crz*crz*crz*2.118945e-11) + (tow*-1.277802e+00) + (crz*tow*-6.338520e-02) + (crz*crz*tow*3.244369e-04) + (crz*crz*crz*tow*-3.700204e-07) + (crz*crz*crz*crz*tow*1.697370e-10) + (tow*tow*2.890675e-02) + (crz*tow*tow*4.198539e-04) + (crz*crz*tow*tow*-1.821915e-06) + (crz*crz*crz*tow*tow*1.095987e-09) + (tow*tow*tow*-2.314586e-04) + (crz*tow*tow*tow*-9.470935e-07) + (crz*crz*tow*tow*tow*3.354832e-09) + (tow*tow*tow*tow*7.589140e-07) + (crz*tow*tow*tow*tow*2.129195e-10) + (tow*tow*tow*tow*tow*-8.001809e-10) + (temp*-1.096860e+01) + (crz*temp*-3.051487e-02) + (crz*crz*temp*2.127747e-04) + (crz*crz*crz*temp*-2.752134e-07) + (crz*crz*crz*crz*temp*8.427234e-12) + (tow*temp*2.462013e-01) + (crz*tow*temp*7.342185e-04) + (crz*crz*tow*temp*-3.056328e-06) + (crz*crz*crz*tow*temp*2.538470e-09) + (tow*tow*temp*-2.454924e-03) + (crz*tow*tow*temp*-3.906183e-06) + (crz*crz*tow*tow*temp*8.289368e-09) + (tow*tow*tow*temp*1.162654e-05) + (crz*tow*tow*tow*temp*4.965479e-09) + (tow*tow*tow*tow*temp*-2.073121e-08) + (temp*temp*8.503371e-02) + (crz*temp*temp*-6.834545e-06) + (crz*crz*temp*temp*7.685558e-07) + (crz*crz*crz*temp*temp*-9.135024e-10) + (tow*temp*temp*-1.854582e-03) + (crz*tow*temp*temp*-1.463171e-06) + (crz*crz*tow*temp*temp*-2.181700e-09) + (tow*tow*temp*temp*1.398180e-05) + (crz*tow*tow*temp*temp*7.379637e-09) + (tow*tow*tow*temp*temp*-3.535769e-08) + (temp*temp*temp*1.778024e-02) + (crz*temp*temp*temp*-8.594420e-05) + (crz*crz*temp*temp*temp*1.157695e-07) + (tow*temp*temp*temp*-1.399377e-04) + (crz*tow*temp*temp*temp*4.666109e-07) + (tow*tow*temp*temp*temp*3.167345e-07) + (temp*temp*temp*temp*-5.172935e-06) + (crz*temp*temp*temp*temp*6.003772e-09) + (tow*temp*temp*temp*temp*2.994848e-08) + (temp*temp*temp*temp*temp*-6.608905e-06);
		FMGCInternal.clbSet = 1;

		#print("Fuel: ", FMGCInternal.clbFuel);
		#print("Time: ", FMGCInternal.clbTime);
		#print("Dist: ", FMGCInternal.clbDist);
	}
	
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
	phase = FMGCInternal.phase;
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
		FMGCInternal.maxspeed = getprop("/systems/navigation/adr/computation/overspeed-vfe-spd") - 4;
	} elsif (pts.Gear.position[0].getValue() != 0 or pts.Gear.position[1].getValue() != 0 or pts.Gear.position[2].getValue() != 0) {
		FMGCInternal.maxspeed = 284;
	} else {
		FMGCInternal.maxspeed = getprop("/it-fbw/speeds/vmo-mmo");
	}
	
	############################
	# fuel
	############################
	updateFuel();
	
	############################
	# wind
	############################
	if (FMGCInternal.phase == 3 or FMGCInternal.phase == 4 or FMGCInternal.phase == 6) {
		var windsDidChange = 0;
		if (FMGCInternal.crzFt > 5000 and alt > 4980 and alt < 5020) {
			if (sprintf("%03d", getprop("/environment/wind-from-heading-deg/")) != fmgc.windController.fl50_wind[0] or sprintf("%03d", getprop("/environment/wind-speed-kt/")) != fmgc.windController.fl50_wind[1]) {
				fmgc.windController.fl50_wind[0] = sprintf("%03d", getprop("/environment/wind-from-heading-deg/"));
				fmgc.windController.fl50_wind[1] = sprintf("%03d", getprop("/environment/wind-speed-kt/"));
				fmgc.windController.fl50_wind[2] = "FL50";
				windsDidChange = 1;
			}
		}
		if (FMGCInternal.crzFt > 15000 and alt > 14980 and alt < 15020) {
			if (sprintf("%03d", getprop("/environment/wind-from-heading-deg/")) != fmgc.windController.fl150_wind[0] or sprintf("%03d", getprop("/environment/wind-speed-kt/")) != fmgc.windController.fl150_wind[1]) {
				fmgc.windController.fl150_wind[0] = sprintf("%03d", getprop("/environment/wind-from-heading-deg/"));
				fmgc.windController.fl150_wind[1] = sprintf("%03d", getprop("/environment/wind-speed-kt/"));
				fmgc.windController.fl150_wind[2] = "FL150";
				windsDidChange = 1;
			}
		}
		if (FMGCInternal.crzFt > 25000 and alt > 24980 and alt < 25020) {
			if (sprintf("%03d", getprop("/environment/wind-from-heading-deg/")) != fmgc.windController.fl250_wind[0] or sprintf("%03d", getprop("/environment/wind-speed-kt/")) != fmgc.windController.fl250_wind[1]) {
				fmgc.windController.fl250_wind[0] = sprintf("%03d", getprop("/environment/wind-from-heading-deg/"));
				fmgc.windController.fl250_wind[1] = sprintf("%03d", getprop("/environment/wind-speed-kt/"));
				fmgc.windController.fl250_wind[2] = "FL250";
				windsDidChange = 1;
			}
		}
		if (FMGCInternal.crzSet and alt > FMGCInternal.crzFt - 20 and alt < FMGCInternal.crzFt + 20) {
			if (sprintf("%03d", getprop("/environment/wind-from-heading-deg/")) != fmgc.windController.flcrz_wind[0] or sprintf("%03d", getprop("/environment/wind-speed-kt/")) != fmgc.windController.flcrz_wind[1]) {
				fmgc.windController.flcrz_wind[0] = sprintf("%03d", getprop("/environment/wind-from-heading-deg/"));
				fmgc.windController.flcrz_wind[1] = sprintf("%03d", getprop("/environment/wind-speed-kt/"));
				fmgc.windController.flcrz_wind[2] = "FL" ~ FMGCInternal.crzFl;
				windsDidChange = 1;
			}
		}
		if (windsDidChange) {
			fmgc.windController.write();
		}
	}
	
	############################
	# calculate speeds
	############################
	flap = getprop("/controls/flight/flaps-pos");
	weight_lbs = getprop("/fdm/jsbsim/inertia/weight-lbs") / 1000;
	altitude = getprop("/instrumentation/altimeter/indicated-altitude-ft");
	
	# current speeds
	FMGCInternal.clean = 2 * weight_lbs * 0.45359237 + 85;
	if (altitude > 20000) {
		FMGCInternal.clean += (altitude - 20000) / 1000;
	}
	FMGCInternal.vs1g_clean = 0.0024 * weight_lbs * weight_lbs + 0.124 * weight_lbs + 88.942;
	FMGCInternal.vs1g_conf_1 = -0.0007 * weight_lbs * weight_lbs + 0.6795 * weight_lbs + 44.673;
	FMGCInternal.vs1g_conf_1f = -0.0001 * weight_lbs * weight_lbs + 0.5211 * weight_lbs + 49.027;
	FMGCInternal.vs1g_conf_2 = -0.0005 * weight_lbs * weight_lbs + 0.5488 * weight_lbs + 44.279;
	FMGCInternal.vs1g_conf_3 = -0.0005 * weight_lbs * weight_lbs + 0.5488 * weight_lbs + 43.279;
	FMGCInternal.vs1g_conf_full = -0.0007 * weight_lbs * weight_lbs + 0.6002 * weight_lbs + 38.479;
	FMGCInternal.slat = FMGCInternal.vs1g_clean * 1.23;
	FMGCInternal.flap2 = FMGCInternal.vs1g_conf_2 * 1.47;
	FMGCInternal.flap3 = FMGCInternal.vs1g_conf_3 * 1.36;
	if (getprop("/FMGC/internal/ldg-config-3-set")) {
		FMGCInternal.vls = FMGCInternal.vs1g_conf_3 * 1.23;
	} else {
		FMGCInternal.vls = FMGCInternal.vs1g_conf_full * 1.23
	}
	if (FMGCInternal.vls < 113) {
		FMGCInternal.vls = 113;
	}
	if (!getprop("/FMGC/internal/vapp-speed-set")) {
		if (FMGCInternal.destWind < 5) {
			FMGCInternal.vapp = FMGCInternal.vls + 5;
		} else if (FMGCInternal.destWind > 15) {
			FMGCInternal.vapp = FMGCInternal.vls + 15;
		} else {
			FMGCInternal.vapp = FMGCInternal.vls + FMGCInternal.destWind;
		}
	}
	
	# predicted takeoff speeds
	if (FMGCInternal.phase == 1) {
		FMGCInternal.clean_to = FMGCInternal.clean;
		FMGCInternal.vs1g_clean_to = FMGCInternal.vs1g_clean;
		FMGCInternal.vs1g_conf_2_to = FMGCInternal.vs1g_conf_2;
		FMGCInternal.vs1g_conf_3_to = FMGCInternal.vs1g_conf_3;
		FMGCInternal.vs1g_conf_full_to = FMGCInternal.vs1g_conf_full;
		FMGCInternal.slat_to = FMGCInternal.slat;
		FMGCInternal.flap2_to = FMGCInternal.flap2;
	} else {
		FMGCInternal.clean_to = 2 * FMGCInternal.tow * 0.45359237 + 85;
		if (altitude > 20000) {
			FMGCInternal.clean_to += (altitude - 20000) / 1000;
		}
		FMGCInternal.vs1g_clean_to = 0.0024 * FMGCInternal.tow * FMGCInternal.tow + 0.124 * FMGCInternal.tow + 88.942;
		FMGCInternal.vs1g_conf_2_to = -0.0005 * FMGCInternal.tow * FMGCInternal.tow + 0.5488 * FMGCInternal.tow + 44.279;
		FMGCInternal.vs1g_conf_3_to = -0.0005 * FMGCInternal.tow * FMGCInternal.tow + 0.5488 * FMGCInternal.tow + 43.279;
		FMGCInternal.vs1g_conf_full_to = -0.0007 * FMGCInternal.tow * FMGCInternal.tow + 0.6002 * FMGCInternal.tow + 38.479;
		FMGCInternal.slat_to = FMGCInternal.vs1g_clean_to * 1.23;
		FMGCInternal.flap2_to = FMGCInternal.vs1g_conf_2_to * 1.47;
	}
	
	# predicted approach (temp go-around) speeds
	if (FMGCInternal.phase == 5 or FMGCInternal.phase == 6) {
		FMGCInternal.clean_appr = FMGCInternal.clean;
		FMGCInternal.vs1g_clean_appr = FMGCInternal.vs1g_clean;
		FMGCInternal.vs1g_conf_2_appr = FMGCInternal.vs1g_conf_2;
		FMGCInternal.vs1g_conf_3_appr = FMGCInternal.vs1g_conf_3;
		FMGCInternal.vs1g_conf_full_appr = FMGCInternal.vs1g_conf_full;
		FMGCInternal.slat_appr = FMGCInternal.slat;
		FMGCInternal.flap2_appr = FMGCInternal.flap2;
		FMGCInternal.vls_appr = FMGCInternal.vls;
		if (!getprop("/FMGC/internal/vapp-speed-set")) {
			FMGCInternal.vapp_appr = FMGCInternal.vapp;
		}
	} else {
		FMGCInternal.clean_appr = 2 * FMGCInternal.lw * 0.45359237 + 85;
		if (altitude > 20000) {
			FMGCInternal.clean_appr += (altitude - 20000) / 1000;
		}
		FMGCInternal.vs1g_clean_appr = 0.0024 * FMGCInternal.lw * FMGCInternal.lw + 0.124 * FMGCInternal.lw + 88.942;
		FMGCInternal.vs1g_conf_2_appr = -0.0005 * FMGCInternal.lw * FMGCInternal.lw + 0.5488 * FMGCInternal.lw + 44.279;
		FMGCInternal.vs1g_conf_3_appr = -0.0005 * FMGCInternal.lw * FMGCInternal.lw + 0.5488 * FMGCInternal.lw + 43.279;
		FMGCInternal.vs1g_conf_full_appr = -0.0007 * FMGCInternal.lw * FMGCInternal.lw + 0.6002 * FMGCInternal.lw + 38.479;
		FMGCInternal.slat_appr = FMGCInternal.vs1g_clean_appr * 1.23;
		FMGCInternal.flap2_appr = FMGCInternal.vs1g_conf_2_appr * 1.47;
		if (getprop("/FMGC/internal/ldg-config-3-set")) {
			FMGCInternal.vls_appr = FMGCInternal.vs1g_conf_3_appr * 1.23;
		} else {
			FMGCInternal.vls_appr = FMGCInternal.vs1g_conf_full_appr * 1.23
		}
		if (FMGCInternal.vls_appr < 113) {
			FMGCInternal.vls_appr = 113;
		}
		if (!getprop("/FMGC/internal/vapp-speed-set")) {
			if (FMGCInternal.destWind < 5) {
				FMGCInternal.vapp_appr = FMGCInternal.vls_appr + 5;
			} else if (FMGCInternal.destWind > 15) {
				FMGCInternal.vapp_appr = FMGCInternal.vls_appr + 15;
			} else {
				FMGCInternal.vapp_appr = FMGCInternal.vls_appr + FMGCInternal.destWind;
			}
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
		FMGCInternal.alpha_prot = cas * math.sqrt((aoa - aoa_0)/(aoa_prot - aoa_0));
		FMGCInternal.alpha_max = cas * math.sqrt((aoa - aoa_0)/(aoa_max - aoa_0));
	} else {
		FMGCInternal.alpha_prot = 0;
		FMGCInternal.alpha_max = 0;
	}
	
	#FMGCInternal.vs1g_conf_2_appr = FMGCInternal.vs1g_conf_2;
	#FMGCInternal.vs1g_conf_3_appr = FMGCInternal.vs1g_conf_3;
	#FMGCInternal.vs1g_conf_full_appr = FMGCInternal.vs1g_conf_full;
	
	if (flap == 0) { # 0
		FMGCInternal.vsw = FMGCInternal.vs1g_clean;
		FMGCInternal.minspeed = FMGCInternal.clean;
		
		if (FMGCInternal.takeoffState) {
			FMGCInternal.vls_min = FMGCInternal.vs1g_clean * 1.28;
		} else {
			FMGCInternal.vls_min = FMGCInternal.vs1g_clean * 1.23;
		}
	} else if (flap == 1) { # 1
		FMGCInternal.vsw = FMGCInternal.vs1g_conf_2; 
		FMGCInternal.minspeed = FMGCInternal.slat;
		
		if (FMGCInternal.takeoffState) {
			FMGCInternal.vls_min = FMGCInternal.vs1g_conf_1 * 1.28;
		} else {
			FMGCInternal.vls_min = FMGCInternal.vs1g_conf_1 * 1.23;
		}
	} else if (flap == 2) { # 1+F
		FMGCInternal.vsw = FMGCInternal.vs1g_conf_1f;
		FMGCInternal.minspeed = FMGCInternal.slat;
		
		if (FMGCInternal.takeoffState) {
			FMGCInternal.vls_min = FMGCInternal.vs1g_clean * 1.13;
		} else {
			FMGCInternal.vls_min = FMGCInternal.vs1g_conf_1f * 1.23;
		}
	} else if (flap == 3) { # 2
		FMGCInternal.vsw = FMGCInternal.vs1g_conf_2;
		FMGCInternal.minspeed = FMGCInternal.flap2;
		
		if (FMGCInternal.takeoffState) {
			FMGCInternal.vls_min = FMGCInternal.vs1g_clean * 1.13;
		} else {
			FMGCInternal.vls_min = FMGCInternal.vs1g_conf_2 * 1.23;
		}
	} else if (flap == 4) { # 3
		FMGCInternal.vsw = FMGCInternal.vs1g_conf_3;
		FMGCInternal.minspeed = FMGCInternal.flap3;
		
		if (FMGCInternal.takeoffState) {
			FMGCInternal.vls_min = FMGCInternal.vs1g_clean * 1.13;
		} else {
			FMGCInternal.vls_min = FMGCInternal.vs1g_conf_3 * 1.23;
		}
	} else if (flap == 5) { # FULL
		FMGCInternal.vsw = FMGCInternal.vs1g_conf_full;
		FMGCInternal.minspeed = FMGCInternal.vapp;
		
		if (FMGCInternal.takeoffState) {
			FMGCInternal.vls_min = FMGCInternal.vs1g_clean * 1.13;
		} else {
			FMGCInternal.vls_min = FMGCInternal.vs1g_conf_full * 1.23;
		}
	}
	
	if (gear0 and flaps < 5 and (state1 == "MCT" or state1 == "MAN THR" or state1 == "TOGA") and (state2 == "MCT" or state2 == "MAN THR" or state2 == "TOGA")) {
		if (!FMGCInternal.takeoffState) {
			fmgc.FMGCNodes.toState.setValue(1);
		}
		FMGCInternal.takeoffState = 1;
	} elsif (pts.Position.gearAglFt.getValue() >= 55) {
		if (FMGCInternal.takeoffState) {
			fmgc.FMGCNodes.toState.setValue(0);
		}
		FMGCInternal.takeoffState = 0;
	}
	
	############################
	#handle radios, runways, v1/vr/v2
	############################
	
	departure_rwy = fmgc.flightPlanController.flightplans[2].departure_runway;
	destination_rwy = fmgc.flightPlanController.flightplans[2].destination_runway;
	if (destination_rwy != nil and phase >= 2) {
		var airport = airportinfo(FMGCInternal.arrApt);
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
	FMGCInternal.phase = 0;
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
	setprop("systems/pressurization/ambientpsi", "0");
	setprop("systems/pressurization/cabinpsi", "0");
	
	mcdu.ReceivedMessagesDatabase.clearDatabase();
}

#################
# Managed Speed #
#################

var ManagedSPD = maketimer(0.25, func {
	if (FMGCInternal.crzSet and FMGCInternal.costIndexSet) {
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
			phase = FMGCInternal.phase; # 0 is Preflight 1 is Takeoff 2 is Climb 3 is Cruise 4 is Descent 5 is Decel/Approach 6 is Go Around 7 is Done
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
				} else if (mng_spd_cmd != FMGCInternal.minspeed and decel) {
					setprop("/FMGC/internal/mng-spd-cmd", FMGCInternal.minspeed);
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
				} else if (mng_spd_cmd != FMGCInternal.minspeed and decel) {
					setprop("/FMGC/internal/mng-spd-cmd", FMGCInternal.minspeed);
				}
			} else if ((FMGCInternal.phase == 4 or FMGCInternal.phase == 5 or FMGCInternal.phase == 6) and altitude <= 10980) {
				if (mngktsmach) {
					setprop("/FMGC/internal/mng-kts-mach", 0);
				}
				if (mng_spd_cmd != 250 and !decel) {
					setprop("/FMGC/internal/mng-spd-cmd", 250);
				} else if (mng_spd_cmd != FMGCInternal.minspeed and decel) {
					setprop("/FMGC/internal/mng-spd-cmd", FMGCInternal.minspeed);
				}
			}
			
			mng_spd_cmd = getprop("/FMGC/internal/mng-spd-cmd");
			
			if (mng_spd_cmd > FMGCInternal.maxspeed - 5) {
				setprop("/FMGC/internal/mng-spd", FMGCInternal.maxspeed - 5);
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
		FMGCInternal.phase = 7;
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
		#updateFuel();
		setprop("/FMGC/internal/block-calculating", 0);
		setprop("/FMGC/internal/block-fuel-time", -99); 
		timer3blockFuel.stop();
	}
});

var timer5fuelPred = maketimer(1, func() {
	if (pts.Sim.Time.elapsedSec.getValue() > getprop("/FMGC/internal/fuel-pred-time") + 5) {
		#updateFuel();
		setprop("/FMGC/internal/fuel-calculating", 0);
		setprop("/FMGC/internal/fuel-pred-time", -99); 
		timer5fuelPred.stop();
	}
});