# A3XX FMGC/Autoflight
# Copyright (c) 2024 Josh Davidson (Octal450), Jonathan Redpath (legoboyvdlp), and Matthew Maring (mattmaring)

##################
# Init Functions #
##################
var gear0 = 0;
var state1 = 0;
var state2 = 0;
var dep = "";
var arr = "";
var n1_left = 0;
var n1_right = 0;
var gs = 0;
var accel_agl_ft = 0;
var fd1 = 0;
var fd2 = 0;
var spd = 0;
var hdg = 0;
var alt = 0;
var altitude = 0;
var flap = 0;
var flaps = 0;
var ktsmach = 0;
var mng_alt_spd = 0;
var mng_alt_mach = 0;
var altsel = 0;
var crzFl = 0;
var xtrkError = 0;
var courseDistanceDecel = 0;
var windHdg = 0;
var windSpeed = 0;
var windsDidChange = 0;
var tempOverspeed = nil;
var pinOptionGaAccelAlt = 1500;
if (getprop("/options/company-options/default-ga-accel-agl") != nil) {
	pinOptionGaAccelAlt = getprop("/options/company-options/default-ga-accel-agl");
}
var pinOptionGaThrRedAlt = 400;
if (getprop("/options/company-options/default-ga-thrRed-agl") != nil) {
	pinOptionGaThrRedAlt = getprop("/options/company-options/default-ga-thrRed-agl");
}
# min Value for ThrRed and AccelAlt are the company pin option defaults
var minAccelAlt = getprop("/options/company-options/default-accel-agl");
var minThrRed = getprop("/options/company-options/default-thrRed-agl");

setprop("/position/gear-agl-ft", 0);

# 1500 ft is a default value not shown anywhere. It may not exist.
# In case it does not exist, a takeoff with no departure airport and no accel set would never go from TO PHASE to CLB PHASE
# unless manually set.
setprop("/it-autoflight/settings/accel-ft", 1500);
setprop("/it-autoflight/internal/vert-speed-fpm", 0);
setprop("/instrumentation/nav[0]/nav-id", "XXX");
setprop("/instrumentation/nav[1]/nav-id", "XXX");

var FMGCAlignDone = [props.globals.initNode("/FMGC/internal/align1-done", 0, "BOOL"), props.globals.initNode("/FMGC/internal/align2-done", 0, "BOOL"), props.globals.initNode("/FMGC/internal/align3-done", 0, "BOOL")];
var FMGCAlignTime = [props.globals.initNode("/FMGC/internal/align1-time", 0, "DOUBLE"), props.globals.initNode("/FMGC/internal/align2-time", 0, "DOUBLE"), props.globals.initNode("/FMGC/internal/align3-time", 0, "DOUBLE")];
var adirsSkip = props.globals.getNode("/systems/acconfig/options/adirs-skip");
var blockCalculating = props.globals.initNode("/FMGC/internal/block-calculating", 0, "BOOL");
var fuelCalculating = props.globals.initNode("/FMGC/internal/fuel-calculating", 0, "BOOL");

var FMGCinit = func {
	FMGCInternal.maxspeed = 338;
	FMGCNodes.vmax.setValue(338);
	FMGCInternal.phase = 0; # 0 is Preflight 1 is Takeoff 2 is Climb 3 is Cruise 4 is Descent 5 is Decel/Approach 6 is Go Around 7 is Done
	FMGCNodes.phase.setValue(0);
	FMGCNodes.mngSpdActive.setBoolValue(nil);
	FMGCInternal.mngSpd = 157;
	FMGCInternal.mngSpdCmd = 157;
	FMGCInternal.mngKtsMach = 0;
	FMGCInternal.machSwitchover = 0;
	setprop("/FMGC/internal/optalt", 0);
	FMGCInternal.landingTime = -99;
	FMGCInternal.blockFuelTime = -99;
	FMGCInternal.fuelPredTime = -99;
	FMGCAlignTime[0].setValue(-99);
	FMGCAlignTime[1].setValue(-99);
	FMGCAlignTime[2].setValue(-99);
	masterFMGC.start();
	radios.start();
}

var FMGCInternal = {
	# phase logic
	phase: 0,
	decel: 0,
	maxspeed: 0,
	clbSpdLim: 250,
	desSpdLim: 250,
	clbSpdLimAlt: 10000,
	desSpdLimAlt: 10000,
	clbSpdLimSet: 0,
	desSpdLimSet: 0,
	
	# speeds
	vmo_mmo: props.globals.getNode("/FMGC/internal/vmo-mmo"),
	vsw: 0,
	vls_min: 0,
	clean: 0,
	vs1g_conf_0: 0,
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
	vs1g_conf_0_to: 0,
	vs1g_conf_2_to: 0,
	vs1g_conf_3_to: 0,
	vs1g_conf_full_to: 0,
	slat_to: 0,
	flap2_to: 0,
	clean_appr: 0,
	vs1g_conf_0_appr: 0,
	vs1g_conf_2_appr: 0,
	vs1g_conf_3_appr: 0,
	vs1g_conf_full_appr: 0,
	slat_appr: 0,
	flap2_appr: 0,
	minspeed: 0,
	vls_appr: 0,
	vapp_appr: 0,
	vappSpeedSet: 0,
	
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
	toFlap: 0,
	toThs: 0,
	toFlapThsSet: 0,
	accelAlt: 0,
	accelAltSet: 0,
	thrRedAlt: 0,
	thrRedAltSet: 0,
	
	# PERF APPR
	destMag: 0,
	destMagSet: 0,
	destWind: 0,
	destWindSet: 0,
	radioNo: 0,
	ldgConfig3: 0,
	ldgConfigFull: 0,
	
	# PERF GA
	gaAccelAlt: 0,
	gaAccelAltSet: 0,
	gaThrRedAlt: 0,
	gaThrRedAltSet: 0,
	
	# INIT A
	altAirport: "",
	altAirportSet: 0,
	altSelected: 0,
	arrApt: "",
	destAptElev: 0,
	coRoute: "",
	coRouteSet: 0,
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
	depAptElev: 0,
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
	blockCalculating: 0,
	blockConfirmed: 0,
	fuelCalculating: 0,
	fuelRequest: 0,
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
	
	# VAPP
	approachSpeed: 0,
	currentWindComponent: 0,
	destWindComponent: 0,
	gsMini: 0,
	headwindComponent: 0,
	tailwindComponent: 0,
	
	# Managed Speed
	machSwitchover: 0,
	mngKtsMach: 0,
	mngSpd: 0,
	mngSpdCmd: 0,
	
	# This can't be init to -98, because we don't want it to run until WOW has gone to false and back to true
	landingTime: -98, 
	blockFuelTime: -99,
	fuelPredTime: -99,
	
	# RADNAV
	ADF1: {
		freqSet: 0,
		mcdu: "XXX/999.99"
	},
	ADF2: {
		freqSet: 0,
		mcdu: "999.99/XXX"
	},
	ILS: {
		crsSet: 0,
		freqCalculated: 0,
		freqSet: 0,
		mcdu: "XXX/999.99"
	},
	VOR1: {
		crsSet: 0,
		freqSet: 0,
		mcdu: "XXX/999.99"
	},
	VOR2: {
		crsSet: 0,
		freqSet: 0,
		mcdu: "999.99/XXX"
	},
};

var postInit = func() {
	# Some properties had setlistener -- so to make sure all is o.k., we call function immediately like so:
	altvert();
	updateRouteManagerAlt();
	mcdu.updateCrzLvlCallback();
}

var FMGCNodes = {
	costIndex: props.globals.initNode("/FMGC/internal/cost-index", 0, "DOUBLE"),
	clean: props.globals.getNode("/FMGC/internal/clean"),
	flap2: props.globals.getNode("/FMGC/internal/flap-2"),
	flap3: props.globals.getNode("/FMGC/internal/flap-3"),
	ktsToMachFactor: props.globals.getNode("/FMGC/internal/kts-to-mach-factor"),
	lw: props.globals.getNode("/FMGC/internal/lw"),
	lwClean: props.globals.getNode("/FMGC/internal/lw-clean"),
	lwVs1gConf0: props.globals.getNode("/FMGC/internal/lw-vs1g-conf-0"),
	lwVs1gConf1f: props.globals.getNode("/FMGC/internal/lw-vs1g-conf-1f"),
	lwVs1gConf2: props.globals.getNode("/FMGC/internal/lw-vs1g-conf-2"),
	lwVs1gConf3: props.globals.getNode("/FMGC/internal/lw-vs1g-conf-3"),
	lwVs1gConfFull: props.globals.getNode("/FMGC/internal/lw-vs1g-conf-full"),
	mngSpdAlt: props.globals.getNode("/FMGC/internal/mng-alt-spd"),
	machToKtsFactor: props.globals.getNode("/FMGC/internal/mach-to-kts-factor"),
	minspeed: props.globals.getNode("/FMGC/internal/minspeed"),
	mngMachAlt: props.globals.getNode("/FMGC/internal/mng-alt-mach"),
	mngSpdActive: props.globals.initNode("/FMGC/internal/mng-spd-active", 0, "BOOL"),
	pitchMode: props.globals.initNode("/FMGC/internal/pitch-mode", " " , "STRING"),
	Power: {
		FMGC1Powered: props.globals.getNode("systems/fmgc/power/power-1-on"),
		FMGC2Powered: props.globals.getNode("systems/fmgc/power/power-2-on"),
	},
	selSpdEnable: props.globals.initNode("/FMGC/internal/sel-spd-enable", 1, "BOOL"),
	slat: props.globals.getNode("/FMGC/internal/slat"),
	toFromSet: props.globals.initNode("/FMGC/internal/tofrom-set", 0, "BOOL"),
	togaSpd: props.globals.getNode("/it-autoflight/settings/toga-spd", 1),
	toState: props.globals.initNode("/FMGC/internal/to-state", 0, "BOOL"),
	tow: props.globals.getNode("/FMGC/internal/tow"),
	towClean: props.globals.getNode("/FMGC/internal/tow-clean"),
	towFlap2: props.globals.getNode("/FMGC/internal/flap-2-tow"),
	towSlat: props.globals.getNode("/FMGC/internal/slat-tow"),
	towVs1gConf0: props.globals.getNode("/FMGC/internal/tow-vs1g-conf-0"),
	towVs1gConf1f: props.globals.getNode("/FMGC/internal/tow-vs1g-conf-1f"),
	towVs1gConf2: props.globals.getNode("/FMGC/internal/tow-vs1g-conf-2"),
	towVs1gConf3: props.globals.getNode("/FMGC/internal/tow-vs1g-conf-3"),
	towVs1gConfFull: props.globals.getNode("/FMGC/internal/lw-vs1g-conf-full"),
	v1: props.globals.initNode("/FMGC/internal/v1", 0, "DOUBLE"),
	v1set: props.globals.initNode("/FMGC/internal/v1-set", 0, "BOOL"),
	v2: props.globals.initNode("/FMGC/internal/v2", 0, "DOUBLE"),
	v2set: props.globals.initNode("/FMGC/internal/v2-set", 0, "BOOL"),
	phase: props.globals.initNode("/FMGC/internal/phase", 0, "INT"),
	valphaMax: props.globals.getNode("/FMGC/internal/valpha-max"),
	valphaProt: props.globals.getNode("/FMGC/internal/valpha-prot"),
	vapp: props.globals.initNode("/FMGC/internal/vapp", 0, "DOUBLE"),
	vapp_appr: props.globals.initNode("/FMGC/internal/vapp-predicted", 0, "DOUBLE"),
	vappSet: props.globals.initNode("/FMGC/internal/vapp-set", 0, "DOUBLE"),
	vls: props.globals.getNode("/FMGC/internal/vls"),
	vmax: props.globals.getNode("/FMGC/internal/vmax"),
	vs1g: props.globals.getNode("/FMGC/internal/vs1g"),
	vs1gConf0: props.globals.getNode("/FMGC/internal/vs1g-conf-0"),
	vs1gConf1: props.globals.getNode("/FMGC/internal/vs1g-conf-1"),
	vs1gConf1f: props.globals.getNode("/FMGC/internal/vs1g-conf-1f"),
	vs1gConf2: props.globals.getNode("/FMGC/internal/vs1g-conf-2"),
	vs1gConf3: props.globals.getNode("/FMGC/internal/vs1g-conf-3"),
	vs1gConfFull: props.globals.getNode("/FMGC/internal/vs1g-conf-full"),
	vsw: props.globals.getNode("/FMGC/internal/vsw"),
};

############
# FBW Trim #
############

# Reset PITCH TRIM after landing
setlistener("/gear/gear[0]/wow", func {
   # TODO set a new listener for pitch less than 2.5 deg for 5sec
	timer5trimReset.singleShot = 1;
	timer5trimReset.simulatedTime = 1;
	timer5trimReset.start();
}, 0, 0);

var trimReset = func {
	flaps = pts.Controls.Flight.flapsPos.getValue();
	if (pts.Gear.wow[0].getBoolValue() and !FMGCNodes.toState.getValue() and (flaps >= 5 or (flaps >= 4 and pts.Instrumentation.MKVII.Inputs.Discretes.flap3Override.getValue() == 1))) {
		interpolate("/controls/flight/elevator-trim", 0.0, 1.5);
	}
}

###############
# MCDU Inputs #
###############

var updateARPT = func {
	setprop("/autopilot/route-manager/departure/airport", FMGCInternal.depApt);
	setprop("/autopilot/route-manager/destination/airport", FMGCInternal.arrApt);
	setprop("/autopilot/route-manager/alternate/airport", FMGCInternal.altAirport);
	if (getprop("/autopilot/route-manager/active") != 1) {
		fgcommand("activate-flightplan", props.Node.new({"activate": 1}));
	}
}

var apt = nil;
var dms = nil;
var degrees = nil;
var minutes = nil;
var sign = nil;
var updateArptLatLon = func() {
	#ref lat
	apt = airportinfo(FMGCInternal.depApt);
	dms = apt.lat;
	degrees = int(dms);
	minutes = sprintf("%.1f",abs((dms - degrees) * 60));
	sign = degrees >= 0 ? "N" : "S";
	setprop("/FMGC/internal/align-ref-lat-degrees", degrees);
	setprop("/FMGC/internal/align-ref-lat-minutes", minutes);
	setprop("/FMGC/internal/align-ref-lat-sign", sign);
	#ref long
	dms = apt.lon;
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
	setprop("/autopilot/route-manager/cruise/altitude-ft", FMGCInternal.crzFt);
	# TODO - update FMGCInternal.phase when DES to re-enter in CLIMB/CRUIZE
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
		final_time = math.clamp(final_time, 0, 480);
		
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
		final_fuel = math.clamp(final_fuel, 0, 80000);
		
		FMGCInternal.finalFuel = final_fuel / 1000;
	}
	
	# Calculate alternate fuel
	if (!FMGCInternal.altFuelSet and FMGCInternal.altAirportSet) {
		#calc
	} elsif (FMGCInternal.altFuelSet and FMGCInternal.altAirportSet) {
		#dummy calc for now
		alt_fuel = 1000 * num(FMGCInternal.altFuel);
		zfw = 1000 * FMGCInternal.zfw;
		alt_time = alt_fuel / (2.0 * ((zfw*zfw*-2e-10) + (zfw*0.0003) + 2.8903)); # x2 for 2 engines
		alt_time = math.clamp(alt_time, 0, 480);
		
		if (num(alt_time) >= 60) {
			alt_min = int(math.mod(alt_time, 60));
			alt_hour = int((alt_time - alt_min) / 60);
			FMGCInternal.altTime = sprintf("%02d", alt_hour) ~ sprintf("%02d", alt_min);
		} else {
			FMGCInternal.altTime = sprintf("%04d", alt_time);
		}
	} elsif (!FMGCInternal.altFuelSet) {
		FMGCInternal.altFuel = 0.0;
		FMGCInternal.altTime = "0000";
	}
	
	# Calculate min dest fob (final + alternate)
	if (!FMGCInternal.minDestFobSet) {
		FMGCInternal.minDestFob = num(FMGCInternal.altFuel + FMGCInternal.finalFuel);
	}
	
	if (FMGCInternal.zfwSet) {
		FMGCInternal.lw = num(FMGCInternal.zfw + FMGCInternal.altFuel + FMGCInternal.finalFuel);
		FMGCNodes.lw.setValue(FMGCInternal.lw * LB2KG * 1000);
	}
	
	# Calculate trip fuel
	if (FMGCInternal.toFromSet and FMGCInternal.crzSet and FMGCInternal.crzTempSet and FMGCInternal.zfwSet) {
		crz = FMGCInternal.crzFl;
		temp = FMGCInternal.crzTemp;
		dist = flightPlanController.arrivalDist.getValue();
		
		trpWind = FMGCInternal.tripWind;
		wind_value = FMGCInternal.tripWindValue;
		if (find("HD", trpWind) != -1 or find("-", trpWind) != -1 or find("H", trpWind) != -1) {
			wind_value = wind_value * -1;
		}
		dist = dist - (dist * wind_value * 0.002);

		#trip_fuel = 4.003e+02 + (dist * -5.399e+01) + (dist * dist * -7.322e-02) + (dist * dist * dist * 1.091e-05) + (dist * dist * dist * dist * 2.962e-10) + (dist * dist * dist * dist * dist * -1.178e-13) + (dist * dist * dist * dist * dist * dist * 6.322e-18) + (crz * 5.387e+01) + (dist * crz * 1.583e+00) + (dist * dist * crz * 7.695e-04) + (dist * dist * dist * crz * -1.057e-07) + (dist * dist * dist * dist * crz * 1.138e-12) + (dist * dist * dist * dist * dist * crz * 1.736e-16) + (crz * crz * -1.171e+00) + (dist * crz * crz * -1.219e-02) + (dist * dist * crz * crz * -2.879e-06) + (dist * dist * dist * crz * crz * 3.115e-10) + (dist * dist * dist * dist * crz * crz * -4.093e-15) + (crz * crz * crz * 9.160e-03) + (dist * crz * crz * crz * 4.311e-05) + (dist * dist * crz * crz * crz * 4.532e-09) + (dist * dist * dist * crz * crz * crz * -2.879e-13) + (crz * crz * crz * crz * -3.338e-05) + (dist * crz * crz * crz * crz * -7.340e-08) + (dist * dist * crz * crz * crz * crz * -2.494e-12) + (crz * crz * crz * crz * crz * 5.849e-08) + (dist * crz * crz * crz * crz * crz * 4.898e-11) + (crz * crz * crz * crz * crz * crz * -3.999e-11);
		trip_fuel = 4.018e+02 + (dist*3.575e+01) + (dist*dist*-4.260e-02) + (dist*dist*dist*-1.446e-05) + (dist*dist*dist*dist*4.101e-09) + (dist*dist*dist*dist*dist*-6.753e-13) + (dist*dist*dist*dist*dist*dist*5.074e-17) + (crz*-2.573e+01) + (dist*crz*-1.583e-01) + (dist*dist*crz*8.147e-04) + (dist*dist*dist*crz*4.485e-08) + (dist*dist*dist*dist*crz*-7.656e-12) + (dist*dist*dist*dist*dist*crz*4.503e-16) + (crz*crz*4.427e-01) + (dist*crz*crz*-1.137e-03) + (dist*dist*crz*crz*-4.409e-06) + (dist*dist*dist*crz*crz*-3.345e-11) + (dist*dist*dist*dist*crz*crz*4.985e-15) + (crz*crz*crz*-2.471e-03) + (dist*crz*crz*crz*1.223e-05) + (dist*dist*crz*crz*crz*9.660e-09) + (dist*dist*dist*crz*crz*crz*-2.127e-14) + (crz*crz*crz*crz*5.714e-06) + (dist*crz*crz*crz*crz*-3.546e-08) + (dist*dist*crz*crz*crz*crz*-7.536e-12) + (crz*crz*crz*crz*crz*-4.061e-09) + (dist*crz*crz*crz*crz*crz*3.355e-11) + (crz*crz*crz*crz*crz*crz*-1.451e-12);
		trip_fuel = math.clamp(trip_fuel, 400, 80000);
		
		# cruize temp correction
		trip_fuel = trip_fuel + (0.033 * (temp - 15 + (2 * crz / 10)) * flightPlanController.arrivalDist.getValue());
		
		trip_time = 9.095e-02 + (dist*-3.968e-02) + (dist*dist*4.302e-04) + (dist*dist*dist*2.005e-07) + (dist*dist*dist*dist*-6.876e-11) + (dist*dist*dist*dist*dist*1.432e-14) + (dist*dist*dist*dist*dist*dist*-1.177e-18) + (crz*7.348e-01) + (dist*crz*3.310e-03) + (dist*dist*crz*-8.700e-06) + (dist*dist*dist*crz*-4.214e-10) + (dist*dist*dist*dist*crz*5.652e-14) + (dist*dist*dist*dist*dist*crz*-6.379e-18) + (crz*crz*-1.449e-02) + (dist*crz*crz*-7.508e-06) + (dist*dist*crz*crz*4.529e-08) + (dist*dist*dist*crz*crz*3.699e-13) + (dist*dist*dist*dist*crz*crz*8.466e-18) + (crz*crz*crz*1.108e-04) + (dist*crz*crz*crz*-4.126e-08) + (dist*dist*crz*crz*crz*-9.645e-11) + (dist*dist*dist*crz*crz*crz*-1.544e-16) + (crz*crz*crz*crz*-4.123e-07) + (dist*crz*crz*crz*crz*1.831e-10) + (dist*dist*crz*crz*crz*crz*7.438e-14) + (crz*crz*crz*crz*crz*7.546e-10) + (dist*crz*crz*crz*crz*crz*-1.921e-13) + (crz*crz*crz*crz*crz*crz*-5.453e-13);
		trip_time = math.clamp(trip_time, 10, 480);
		
		# if (low air conditioning) {
		#	trip_fuel = trip_fuel * 0.995;
		#}
		# if (total anti-ice) {
		#	trip_fuel = trip_fuel * 1.045;
		#} elsif (engine anti-ice) {
		#	trip_fuel = trip_fuel * 1.02;
		#}
		
		zfw = FMGCInternal.zfw;
		landing_weight_correction = 9.951e+00 + (dist*-2.064e+00) + (dist*dist*2.030e-03) + (dist*dist*dist*8.179e-08) + (dist*dist*dist*dist*-3.941e-11) + (dist*dist*dist*dist*dist*2.443e-15) + (crz*2.771e+00) + (dist*crz*3.067e-02) + (dist*dist*crz*-1.861e-05) + (dist*dist*dist*crz*2.516e-10) + (dist*dist*dist*dist*crz*5.452e-14) + (crz*crz*-4.483e-02) + (dist*crz*crz*-1.645e-04) + (dist*dist*crz*crz*5.212e-08) + (dist*dist*dist*crz*crz*-8.721e-13) + (crz*crz*crz*2.609e-04) + (dist*crz*crz*crz*3.898e-07) + (dist*dist*crz*crz*crz*-4.617e-11) + (crz*crz*crz*crz*-6.488e-07) + (dist*crz*crz*crz*crz*-3.390e-10) + (crz*crz*crz*crz*crz*5.835e-10);
		trip_fuel = trip_fuel + (landing_weight_correction * (FMGCInternal.lw * 1000 - 121254.24421) / 2204.622622);
		trip_fuel = math.clamp(trip_fuel, 400, 80000);

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
	} elsif (FMGCInternal.rtePercentSet) {
		FMGCInternal.rteRsv = num(FMGCInternal.tripFuel * FMGCInternal.rtePercent / 100.0);
	} else {
		if (num(FMGCInternal.tripFuel) <= 0.0) {
			FMGCInternal.rtePercent = 5.0;
		} else {
			FMGCInternal.rteRsv = num(FMGCInternal.tripFuel * FMGCInternal.rtePercent / 100.0);
		}
	}
	
	# Misc fuel claclulations
	if (fmgc.FMGCInternal.blockCalculating) {
		FMGCInternal.block = num(FMGCInternal.altFuel + FMGCInternal.finalFuel + FMGCInternal.tripFuel + FMGCInternal.rteRsv + FMGCInternal.taxiFuel);
		FMGCInternal.blockSet = 1;
	}
	fmgc.FMGCInternal.fob = num(pts.Consumables.Fuel.totalFuelLbs.getValue() / 1000);
	fmgc.FMGCInternal.fuelPredGw = num(pts.Fdm.JSBSim.Inertia.weightLbs.getValue() / 1000);
	fmgc.FMGCInternal.cg = fmgc.FMGCInternal.zfwcg;
	
	# Calcualte extra fuel
	if (num(pts.Engines.Engine.n1Actual[0].getValue()) > 0 or num(pts.Engines.Engine.n1Actual[1].getValue()) > 0) {
		extra_fuel = 1000 * num(FMGCInternal.fob - FMGCInternal.tripFuel - FMGCInternal.minDestFob - FMGCInternal.taxiFuel - FMGCInternal.rteRsv);
	} else {
		extra_fuel = 1000 * num(FMGCInternal.block - FMGCInternal.tripFuel - FMGCInternal.minDestFob - FMGCInternal.taxiFuel - FMGCInternal.rteRsv);
	}
	FMGCInternal.extraFuel = extra_fuel / 1000;
	lw = 1000 * FMGCInternal.lw;
	extra_time = extra_fuel / (2.0 * ((lw*lw*-2e-10) + (lw*0.0003) + 2.8903)); # x2 for 2 engines
	extra_time = math.clamp(extra_time, 0, 480);
	
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
	FMGCNodes.tow.setValue(FMGCInternal.tow * LB2KG * 1000);
}

############################
# Flight Phase and Various #
############################
# TODO - if no ID is found, should trigger a NOT IN DATA BASE message
var freqnav0 = nil;
var nav0 = func {
	freqnav0 = sprintf("%.2f", pts.Instrumentation.Nav.Frequencies.selectedMhz[0].getValue());
	if (freqnav0 >= 108.10 and freqnav0 <= 111.95) {
		var namenav0 = getprop("/instrumentation/nav[0]/nav-id") or "   ";
		fmgc.FMGCInternal.ILS.mcdu = namenav0 ~ "/" ~ freqnav0;
	}
}

var freqnav2 = nil;
var nav2 = func {
	freqnav2 = sprintf("%.2f", pts.Instrumentation.Nav.Frequencies.selectedMhz[2].getValue());
	if (freqnav2 >= 108.00 and freqnav2 <= 117.95) {
		var namenav2 = getprop("/instrumentation/nav[2]/nav-id") or "   ";
		fmgc.FMGCInternal.VOR1.mcdu = namenav2 ~ "/" ~ freqnav2;
	}
}

var freqnav3 = nil;
var nav3 = func {
	freqnav3 = sprintf("%.2f", pts.Instrumentation.Nav.Frequencies.selectedMhz[3].getValue());
	if (freqnav3 >= 108.00 and freqnav3 <= 117.95) {
		var namenav3 = getprop("/instrumentation/nav[3]/nav-id") or "   ";
		fmgc.FMGCInternal.VOR2.mcdu = freqnav3 ~ "/" ~ namenav3;
	}
}

var freqadf0 = nil;
var adf0 = func {
	freqadf0 = sprintf("%.1f", pts.Instrumentation.Adf.Frequencies.selectedKhz[0].getValue());
	if (freqadf0 >= 190 and freqadf0 <= 1799) {
		var nameadf0 = pts.Instrumentation.Adf.ident[0].getValue() or "   ";
		fmgc.FMGCInternal.ADF1.mcdu =  nameadf0 ~ "/" ~ freqadf0;
	}
}

var freqadf1 = nil;
var adf1 = func {
	freqadf1 = sprintf("%.1f", pts.Instrumentation.Adf.Frequencies.selectedKhz[1].getValue());
	if (freqadf1 >= 190 and freqadf1 <= 1799) {
		var nameadf1 = pts.Instrumentation.Adf.ident[1].getValue() or "   ";
		fmgc.FMGCInternal.ADF2.mcdu = freqadf1 ~ "/" ~ nameadf1;
	}
}

var radios = maketimer(1, func() {
	nav0();
	nav2();
	nav3();
	adf0();
	adf1();
});

var newphase = nil;
var windAngleDelta = nil;

var masterFMGC = maketimer(0.2, func {
	n1_left = pts.Engines.Engine.n1Actual[0].getValue();
	n1_right = pts.Engines.Engine.n1Actual[1].getValue();
	gs = pts.Velocities.groundspeedKt.getValue();
	alt = pts.Instrumentation.Altimeter.indicatedFt.getValue();
	# cruiseft = FMGCInternal.crzFt;
	# cruiseft_b = FMGCInternal.crzFt - 200;
	state1 = systems.FADEC.detentText[0].getValue();
	state2 = systems.FADEC.detentText[1].getValue();
	accel_agl_ft = Settings.accelFt.getValue();
	gear0 = pts.Gear.wow[0].getBoolValue();
	altSel = Input.alt.getValue();
	
   # Phase: 0 is Preflight 1 is Takeoff 2 is Climb 3 is Cruise 4 is Descent 5 is Decel/Approach 6 is Go Around 7 is Done
	newphase = FMGCInternal.phase;

	if (FMGCInternal.phase == 0) {
		if (gear0 and ((n1_left >= 85 and n1_right >= 85 and Modes.PFD.FMA.pitchMode == "SRS") or gs >= 90)) {
			newphase = 1;
			systems.PNEU.pressMode.setValue("TO");
		}
	} elsif (FMGCInternal.phase == 1) {
		if (gear0) {
			if ((n1_left < 85 or n1_right < 85) and gs < 90 and Modes.PFD.FMA.pitchMode == " ") { # rejected takeoff
				newphase = 0;
				systems.PNEU.pressMode.setValue("GN");
			}
		} elsif (((Modes.PFD.FMA.pitchMode != "SRS" and Modes.PFD.FMA.pitchMode != " ") or alt >= accel_agl_ft)) {
			newphase = 2;
			systems.PNEU.pressMode.setValue("TO");
		}
	} elsif (FMGCInternal.phase == 2) {
		if ((Modes.PFD.FMA.pitchMode == "ALT CRZ" or Modes.PFD.FMA.pitchMode == "ALT CRZ*")) {
			newphase = 3;
			systems.PNEU.pressMode.setValue("CR");
		}
	} elsif (FMGCInternal.phase == 3) {
		if (FMGCInternal.crzFl >= 200) {
			if ((flightPlanController.arrivalDist.getValue() <= 200 or altSel < 20000)) {
				newphase = 4;
				systems.PNEU.pressMode.setValue("DE");
			}
		} else {
			if ((flightPlanController.arrivalDist.getValue() <= 200 or altSel < (FMGCInternal.crzFl * 100))) { # todo - not sure about crzFl condition, investigate what happens!
				newphase = 4;
				systems.PNEU.pressMode.setValue("DE");
			}
		}
	} elsif (FMGCInternal.phase == 4) {
		if (FMGCInternal.decel) {
			newphase = 5;
		}
	} elsif (FMGCInternal.phase == 5) {
		if (state1 == "TOGA" and state2 == "TOGA") {
			newphase = 6;
			systems.PNEU.pressMode.setValue("TO");
			Input.toga.setValue(1);
		}
	} elsif (FMGCInternal.phase == 6) {
		# change FADEC thrReduction from T/O-thrRedAlt to G/A-thrRedAlt
		systems.FADEC.clbReduc = systems.FADEC.gaClbReduc;

		if (alt >= getprop("/FMGC/internal/ga-accel-agl-ft")) { # todo when insert altn or new dest
			newphase = 2;
		}
	}
	
	xtrkError = getprop("/instrumentation/gps/wp/wp[1]/course-error-nm");

	if (flightPlanController.decelPoint != nil) {
		courseDistanceDecel = courseAndDistance(flightPlanController.decelPoint.lat, flightPlanController.decelPoint.lon);
		if (flightPlanController.num[2].getValue() > 0 and fmgc.flightPlanController.active.getBoolValue() and 
            flightPlanController.decelPoint != nil and 
            (courseDistanceDecel[1] <= 5 and 
            (math.abs(courseDistanceDecel[0] - pts.Orientation.heading.getValue()) >= 90 and 
            xtrkError <= 5) or courseDistanceDecel[1] <= 0.1) and 
            (Modes.PFD.FMA.rollMode == "NAV" or Modes.PFD.FMA.rollMode == "LOC" or Modes.PFD.FMA.rollMode == "LOC*") and 
            pts.Position.gearAglFt.getValue() < 9500) {
			FMGCInternal.decel = 1;
			setprop("/instrumentation/nd/symbols/decel/show", 0); 
		} elsif (FMGCInternal.decel and (FMGCInternal.phase == 0 or FMGCInternal.phase == 6)) {
			FMGCInternal.decel = 0;
		}
	} else {
		FMGCInternal.decel = 0;
	}
	
	tempOverspeed = systems.ADIRS.overspeedVFE.getValue();
	if (tempOverspeed != 1024) {
		FMGCInternal.maxspeed = tempOverspeed - 4;
	} elsif (pts.Gear.position[0].getValue() != 0 or pts.Gear.position[1].getValue() != 0 or pts.Gear.position[2].getValue() != 0) {
		FMGCInternal.maxspeed = 284;
	} else {
		FMGCInternal.maxspeed = fmgc.FMGCInternal.vmo_mmo.getValue();
	}
	FMGCNodes.vmax.setValue(FMGCInternal.maxspeed);
	
	if (newphase != FMGCInternal.phase) {  # phase changed
		FMGCInternal.phase = newphase;
		FMGCNodes.phase.setValue(newphase);
	}
	
	############################
	# fuel
	############################
	updateFuel();
	
	############################
	# wind
	############################
	windHdg = pts.Environment.windFromHdg.getValue();
	windSpeed = pts.Environment.windSpeedKt.getValue();
	if (FMGCInternal.phase == 3 or FMGCInternal.phase == 4 or FMGCInternal.phase == 6) {
		windsDidChange = 0;
		if (FMGCInternal.crzFt > 5000 and alt > 4980 and alt < 5020) {
			if (sprintf("%03d", windHdg) != fmgc.windController.fl50_wind[0] or sprintf("%03d", windSpeed) != fmgc.windController.fl50_wind[1]) {
				fmgc.windController.fl50_wind[0] = sprintf("%03d", windHdg);
				fmgc.windController.fl50_wind[1] = sprintf("%03d", windSpeed);
				fmgc.windController.fl50_wind[2] = "FL50";
				windsDidChange = 1;
			}
		}
		if (FMGCInternal.crzFt > 15000 and alt > 14980 and alt < 15020) {
			if (sprintf("%03d", windHdg) != fmgc.windController.fl150_wind[0] or sprintf("%03d", windSpeed) != fmgc.windController.fl150_wind[1]) {
				fmgc.windController.fl150_wind[0] = sprintf("%03d", windHdg);
				fmgc.windController.fl150_wind[1] = sprintf("%03d", windSpeed);
				fmgc.windController.fl150_wind[2] = "FL150";
				windsDidChange = 1;
			}
		}
		if (FMGCInternal.crzFt > 25000 and alt > 24980 and alt < 25020) {
			if (sprintf("%03d", windHdg) != fmgc.windController.fl250_wind[0] or sprintf("%03d", windSpeed) != fmgc.windController.fl250_wind[1]) {
				fmgc.windController.fl250_wind[0] = sprintf("%03d", windHdg);
				fmgc.windController.fl250_wind[1] = sprintf("%03d", windSpeed);
				fmgc.windController.fl250_wind[2] = "FL250";
				windsDidChange = 1;
			}
		}
		if (FMGCInternal.crzSet and alt > FMGCInternal.crzFt - 20 and alt < FMGCInternal.crzFt + 20) {
			if (sprintf("%03d", windHdg) != fmgc.windController.flcrz_wind[0] or sprintf("%03d", windSpeed) != fmgc.windController.flcrz_wind[1]) {
				fmgc.windController.flcrz_wind[0] = sprintf("%03d", windHdg);
				fmgc.windController.flcrz_wind[1] = sprintf("%03d", windSpeed);
				fmgc.windController.flcrz_wind[2] = "FL" ~ FMGCInternal.crzFl;
				windsDidChange = 1;
			}
		}
		if (windsDidChange) {
			fmgc.windController.write();
		}
	}
	
	# Pull speeds from JSBSim
	FMGCInternal.vsw = FMGCNodes.vsw.getValue();
	FMGCInternal.vls = FMGCNodes.vls.getValue();
	FMGCInternal.vs1g_conf_0 = FMGCNodes.vs1gConf0.getValue();
	FMGCInternal.vs1g_conf_1 = FMGCNodes.vs1gConf1.getValue();
	FMGCInternal.vs1g_conf_1f = FMGCNodes.vs1gConf1f.getValue();
	FMGCInternal.vs1g_conf_2 = FMGCNodes.vs1gConf2.getValue();
	FMGCInternal.vs1g_conf_3 = FMGCNodes.vs1gConf3.getValue();
	FMGCInternal.vs1g_conf_full = FMGCNodes.vs1gConfFull.getValue();
	FMGCInternal.slat = FMGCNodes.slat.getValue();
	FMGCInternal.flap2 = FMGCNodes.flap2.getValue();
	FMGCInternal.flap3 = FMGCNodes.flap3.getValue();
	FMGCInternal.clean = FMGCNodes.clean.getValue();
	FMGCInternal.clean_to = FMGCNodes.towClean.getValue();
	FMGCInternal.clean_appr = FMGCNodes.lwClean.getValue();
	
	############################
	# calculate speeds
	############################
	flap = pts.Controls.Flight.flapsPos.getValue();
	weight_lbs = pts.Fdm.JSBSim.Inertia.weightLbs.getValue() / 1000;
	altitude = pts.Instrumentation.Altimeter.indicatedFt.getValue();
	
	if (FMGCInternal.destWindSet and flightPlanController.flightplans[2].destination_runway != nil) {
		windAngleDelta = geo.normdeg180(FMGCInternal.destMag - flightPlanController.flightplans[2].destination_runway.heading - magvar(fmgc.flightPlanController.flightplans[2].destination_runway));
		FMGCInternal.destWindComponent = FMGCInternal.destWind * math.cos(abs(windAngleDelta) * D2R);
		
		FMGCInternal.headwindComponent = math.clamp(FMGCInternal.destWindComponent / 3, 0, 15);
		FMGCInternal.tailwindComponent = math.clamp(-FMGCInternal.destWindComponent, 0, 15);
	} else {
		FMGCInternal.headwindComponent = 0;
		FMGCInternal.tailwindComponent = 0;
		FMGCInternal.destWindComponent = 0;
	}
	
	if (!fmgc.FMGCInternal.vappSpeedSet) {
		FMGCInternal.vapp = FMGCInternal.vls + math.max(5, FMGCInternal.headwindComponent);
	}
	
	# predicted takeoff speeds
	if (FMGCInternal.phase == 1) {
		FMGCInternal.vs1g_conf_0_to = FMGCInternal.vs1g_conf_0;
		FMGCInternal.vs1g_conf_2_to = FMGCInternal.vs1g_conf_2;
		FMGCInternal.vs1g_conf_3_to = FMGCInternal.vs1g_conf_3;
		FMGCInternal.vs1g_conf_full_to = FMGCInternal.vs1g_conf_full;
		FMGCInternal.slat_to = FMGCInternal.slat;
		FMGCInternal.flap2_to = FMGCInternal.flap2;
	} else {
		FMGCInternal.vs1g_conf_0_to = FMGCNodes.towVs1gConf0.getValue();
		FMGCInternal.vs1g_conf_2_to = FMGCNodes.towVs1gConf2.getValue();
		FMGCInternal.vs1g_conf_3_to = FMGCNodes.towVs1gConf3.getValue();
		FMGCInternal.vs1g_conf_full_to = FMGCNodes.towVs1gConfFull.getValue();
		FMGCInternal.slat_to = FMGCNodes.towSlat.getValue();
		FMGCInternal.flap2_to = FMGCNodes.towFlap2.getValue();
	}
	
	# predicted approach (temp go-around) speeds
	if (FMGCInternal.phase == 5 or FMGCInternal.phase == 6) {
		FMGCInternal.vs1g_conf_0_appr = FMGCInternal.vs1g_conf_0;
		FMGCInternal.vs1g_conf_2_appr = FMGCInternal.vs1g_conf_2;
		FMGCInternal.vs1g_conf_3_appr = FMGCInternal.vs1g_conf_3;
		FMGCInternal.vs1g_conf_full_appr = FMGCInternal.vs1g_conf_full;
		FMGCInternal.slat_appr = FMGCInternal.slat;
		FMGCInternal.flap2_appr = FMGCInternal.flap2;
		FMGCInternal.vls_appr = FMGCInternal.vls;
		if (!fmgc.FMGCInternal.vappSpeedSet) {
			FMGCInternal.vapp_appr = FMGCInternal.vapp;
		}
	} else {
		FMGCInternal.vs1g_conf_0_appr = FMGCNodes.lwVs1gConf0.getValue();
		FMGCInternal.vs1g_conf_2_appr = FMGCNodes.lwVs1gConf2.getValue();
		FMGCInternal.vs1g_conf_3_appr = FMGCNodes.lwVs1gConf3.getValue();
		FMGCInternal.vs1g_conf_full_appr = FMGCNodes.lwVs1gConfFull.getValue();
		FMGCInternal.slat_appr = FMGCNodes.lwVs1gConf0.getValue() * 1.27;
		FMGCInternal.flap2_appr = FMGCNodes.lwVs1gConf1f.getValue() * 1.22;
		if (FMGCInternal.ldgConfig3) {
			FMGCInternal.vls_appr = FMGCInternal.vs1g_conf_3_appr * 1.23;
		} else {
			FMGCInternal.vls_appr = FMGCInternal.vs1g_conf_full_appr * 1.23;
		}
		if (FMGCInternal.vls_appr < 113) {
			FMGCInternal.vls_appr = 113;
		}
		if (!fmgc.FMGCInternal.vappSpeedSet) {
			FMGCInternal.vapp_appr = FMGCInternal.vls_appr + math.max(5, FMGCInternal.headwindComponent);
		}
	}
	
	windAngleDelta = geo.normdeg180(pts.Orientation.heading.getValue() - (pts.Instrumentation.PFD.windDirection.getValue() or 0));
	FMGCInternal.currentWindComponent = pts.Instrumentation.PFD.windSpeed.getValue() or 0 * math.cos(abs(windAngleDelta) * D2R);
	
	FMGCInternal.gsMini = FMGCInternal.vapp_appr - math.max(10, (FMGCInternal.headwindComponent * 3)); # because the headwind component nasal node is actually a third
	FMGCInternal.approachSpeed = math.max(FMGCInternal.vapp_appr, FMGCInternal.gsMini + FMGCInternal.currentWindComponent);
	
	FMGCNodes.vapp.setValue(FMGCInternal.vapp);
	FMGCNodes.vapp_appr.setValue(FMGCInternal.vapp_appr);
	FMGCNodes.vappSet.setValue(FMGCInternal.vappSpeedSet);
	
	if (flap == 5) {
		FMGCInternal.minspeed = FMGCInternal.approachSpeed;
	} else {
		FMGCInternal.minspeed = FMGCNodes.minspeed.getValue();
	}
	
	if (fmgc.FMGCInternal.v2set) {
		FMGCNodes.togaSpd.setValue(FMGCInternal.v2 + 10);
	} else { # This should never happen, but lets add a fallback just in case
		FMGCNodes.togaSpd.setValue(FMGCNodes.vls.getValue() + 15);
	}
});

############################
#handle radios, runways, v1/vr/v2
############################
var updateAirportRadios = func {
	departure_rwy = fmgc.flightPlanController.flightplans[2].departure_runway;
	destination_rwy = fmgc.flightPlanController.flightplans[2].destination_runway;
	
	if (FMGCInternal.phase >= 2 and destination_rwy != nil) {
		var airport = airportinfo(FMGCInternal.arrApt);
		setprop("/FMGC/internal/ldg-elev", airport.elevation * M2FT); # eventually should be runway elevation
		magnetic_hdg = geo.normdeg(destination_rwy.heading - pts.Environment.magVar.getValue());
		runway_ils = destination_rwy.ils_frequency_mhz;
		
		if (runway_ils != nil and !fmgc.FMGCInternal.ILS.freqSet and !fmgc.FMGCInternal.ILS.crsSet) {
			fmgc.FMGCInternal.ILS.freqCalculated = runway_ils;
			pts.Instrumentation.Nav.Frequencies.selectedMhz[0].setValue(runway_ils);
			pts.Instrumentation.Nav.Radials.selectedDeg[0].setValue(magnetic_hdg);
		} elsif (runway_ils != nil and !fmgc.FMGCInternal.ILS.freqSet) {
			fmgc.FMGCInternal.ILS.freqCalculated = runway_ils;
			pts.Instrumentation.Nav.Frequencies.selectedMhz[0].setValue(runway_ils);
		} elsif (!fmgc.FMGCInternal.ILS.crsSet) {
			pts.Instrumentation.Nav.Radials.selectedDeg[0].setValue(magnetic_hdg);
		}
	} elsif (FMGCInternal.phase <= 1 and departure_rwy != nil) {
		magnetic_hdg = geo.normdeg(departure_rwy.heading - pts.Environment.magVar.getValue());
		runway_ils = departure_rwy.ils_frequency_mhz;
		
		if (runway_ils != nil and !fmgc.FMGCInternal.ILS.freqSet and !fmgc.FMGCInternal.ILS.crsSet) {
			fmgc.FMGCInternal.ILS.freqCalculated = runway_ils;
			pts.Instrumentation.Nav.Frequencies.selectedMhz[0].setValue(runway_ils);
			pts.Instrumentation.Nav.Radials.selectedDeg[0].setValue(magnetic_hdg);
		} elsif (runway_ils != nil and !fmgc.FMGCInternal.ILS.freqSet) {
			fmgc.FMGCInternal.ILS.freqCalculated = runway_ils;
			pts.Instrumentation.Nav.Frequencies.selectedMhz[0].setValue(runway_ils);
		} elsif (!fmgc.FMGCInternal.ILS.crsSet) {
			pts.Instrumentation.Nav.Radials.selectedDeg[0].setValue(magnetic_hdg);
		}
	}

};

setlistener(FMGCNodes.phase, updateAirportRadios, 0, 0);
setlistener(flightPlanController.changed, updateAirportRadios, 0, 0);

var reset_FMGC = func {
	FMGCInternal.phase = 0;
	FMGCNodes.phase.setValue(0);
	fd1 = Input.fd1.getValue();
	fd2 = Input.fd2.getValue();
	spd = Input.kts.getValue();
	hdg = Input.hdg.getValue();
	alt = Input.alt.getValue();
	
	ITAF.init();
	FMGCinit();
	flightPlanController.reset();
	windController.reset();
	windController.init();
	mcdu.MCDU_reset(0);
	mcdu.MCDU_reset(1);
	Simbrief.SimbriefParser.inhibit = 0;
	mcdu.ReceivedMessagesDatabase.clearDatabase();
	mcdu.FlightLogDatabase.reset(); # track reset events without loosing recorded data
	
	Input.fd1.setValue(fd1);
	Input.fd2.setValue(fd2);
	Input.kts.setValue(spd);
	Input.hdg.setValue(hdg);
	Input.alt.setValue(alt);
	
	systems.PNEU.pressMode.setValue("GN");
	setprop("/systems/pressurization/vs", "0");
	setprop("/systems/pressurization/targetvs", "0");
	setprop("/systems/pressurization/vs-norm", "0");
	setprop("/systems/pressurization/auto", 1);
	setprop("/systems/pressurization/deltap", "0");
	setprop("/systems/pressurization/outflowpos", "0");
	setprop("/systems/pressurization/deltap-norm", "0");
	setprop("/systems/pressurization/outflowpos-norm", "0");
	altitude = pts.Instrumentation.Altimeter.indicatedFt.getValue();
	setprop("/systems/pressurization/cabinalt", altitude);
	setprop("/systems/pressurization/targetalt", altitude); 
	setprop("/systems/pressurization/diff-to-target", "0");
	setprop("/systems/pressurization/ditchingpb", 0);
	setprop("/systems/pressurization/targetvs", "0");
	setprop("/systems/pressurization/ambientpsi", "0");
	setprop("/systems/pressurization/cabinpsi", "0");
	
}

#################
# Managed Speed #
#################
var ktToMach = func(val) { return val * FMGCNodes.ktsToMachFactor.getValue(); }
var machToKt = func(val) { return val * FMGCNodes.machToKtsFactor.getValue(); }
			
var ManagedSPD = maketimer(0.25, func {

   # for managed speed:
   # AP or FD or apporach phase, and one of:
   # - on ground v2
   # - SRS TO or SRS GA
   # - SPD/MACH knob pressed an managed target avail
   # - EXP CLB or EXP DES
   # - AP/FD TCAS engaged
   # not yet all implemented

   if (fcu.FCUController.FCUworking) {
      if (fd1 or fd2 or ap1 or ap2 or FMGCInternal.phase == 5) {
         # speed controlled by FCU?
         if (fmgc.FMGCInternal.v2set) {
            # Managed Speed
            # speed controlled by FMGC
            altitude = pts.Instrumentation.Altimeter.indicatedFt.getValue();
            ktsmach = Input.ktsMach.getValue();
            
            mng_alt_spd = math.round(FMGCNodes.mngSpdAlt.getValue(), 1);
            mng_alt_mach = math.round(FMGCNodes.mngMachAlt.getValue(), 0.001);
            
            # Phase: 0 is Preflight 1 is Takeoff 2 is Climb 3 is Cruise 4 is Descent 5 is Decel/Approach 6 is Go Around 7 is Done
            if (pts.Instrumentation.AirspeedIndicator.indicatedMach.getValue() > mng_alt_mach and (FMGCInternal.phase == 2 or FMGCInternal.phase == 3)) {
               FMGCInternal.machSwitchover = 1;
            } elsif (pts.Instrumentation.AirspeedIndicator.indicatedSpdKt.getValue() > mng_alt_spd and (FMGCInternal.phase == 4 or FMGCInternal.phase == 5)) {
               FMGCInternal.machSwitchover = 0;
            }
            
            var waypoint = flightPlanController.flightplans[2].getWP(FPLN.currentWP.getValue());
            var constraintSpeed = nil;
         
            if (waypoint != nil) {
               constraintSpeed = flightPlanController.flightplans[2].getWP(FPLN.currentWP.getValue()).speed_cstr;

               if ((FMGCInternal.phase == 2 or FMGCInternal.phase == 3) and flightPlanController.flightplans[2].getWP(FPLN.currentWP.getValue()).wp_role == "sid") {
                  i = FPLN.currentWP.getValue();
                  while (flightPlanController.flightplans[2].getWP(i).wp_role == "sid") {
                     if (flightPlanController.flightplans[2].getWP(i).speed_cstr != nil and flightPlanController.flightplans[2].getWP(i).speed_cstr > 100) {
                        constraintSpeed = flightPlanController.flightplans[2].getWP(i).speed_cstr;
                        break;
                     }
                     i = i + 1;
                  }
               }
            }
            
            if ((Modes.PFD.FMA.pitchMode == " " or Modes.PFD.FMA.pitchMode == "SRS") and (FMGCInternal.phase == 0 or FMGCInternal.phase == 1)) {
               FMGCInternal.mngKtsMach = 0;
               FMGCInternal.mngSpdCmd = FMGCInternal.v2;
            } elsif ((FMGCInternal.phase == 2 or FMGCInternal.phase == 3) and altitude <= FMGCInternal.clbSpdLimAlt) {
               # Speed is maximum of greendot / climb speed limit
               FMGCInternal.mngKtsMach = 0;
               
               if (constraintSpeed != nil and constraintSpeed != 0) {
                  FMGCInternal.mngSpdCmd = FMGCInternal.decel ? FMGCInternal.minspeed : math.clamp(math.min(FMGCInternal.clbSpdLim, constraintSpeed), FMGCInternal.clean, 999);
               } else {
                  FMGCInternal.mngSpdCmd = FMGCInternal.decel ? FMGCInternal.minspeed : math.clamp(FMGCInternal.clbSpdLim, FMGCInternal.clean, 999);
               }
            } elsif ((FMGCInternal.phase == 2 or FMGCInternal.phase == 3) and altitude > (FMGCInternal.clbSpdLimAlt + 20)) {
               FMGCInternal.mngKtsMach = FMGCInternal.machSwitchover ? 1 : 0;
               
               if (constraintSpeed != nil and constraintSpeed != 0) {
                  FMGCInternal.mngSpdCmd = FMGCInternal.machSwitchover ? math.min(mng_alt_mach, ktsToMach(constraintSpeed)) : math.min(mng_alt_spd, constraintSpeed);
               } else {
                  FMGCInternal.mngSpdCmd = FMGCInternal.machSwitchover ? mng_alt_mach : mng_alt_spd;
               }
            } elsif ((FMGCInternal.phase >= 4  and FMGCInternal.phase <= 6) and altitude > (FMGCInternal.desSpdLimAlt + 20)) {
               if (FMGCInternal.decel) {
                  FMGCInternal.mngKtsMach = 0;
                  FMGCInternal.mngSpdCmd = FMGCInternal.minspeed;
               } else {
                  FMGCInternal.mngKtsMach = FMGCInternal.machSwitchover ? 1 : 0;
                  if (constraintSpeed != nil and constraintSpeed != 0) {
                     FMGCInternal.mngSpdCmd = FMGCInternal.machSwitchover ? math.min(mng_alt_mach, ktsToMach(constraintSpeed)) : math.min(mng_alt_spd, constraintSpeed);
                  } else {
                     FMGCInternal.mngSpdCmd = FMGCInternal.machSwitchover ? mng_alt_mach : mng_alt_spd;
                  }
               }
            } elsif ((FMGCInternal.phase >= 4 and FMGCInternal.phase <= 6) and altitude <= FMGCInternal.desSpdLimAlt) {
               # Speed is maximum of greendot / descent speed limit
               FMGCInternal.mngKtsMach = 0;
               
               if (constraintSpeed != nil and constraintSpeed != 0) {
                  FMGCInternal.mngSpdCmd = FMGCInternal.decel ? FMGCInternal.minspeed : math.clamp(math.min(FMGCInternal.desSpdLim, constraintSpeed), FMGCInternal.clean, 999);
               } else {
                  FMGCInternal.mngSpdCmd = FMGCInternal.decel ? FMGCInternal.minspeed : math.clamp(FMGCInternal.desSpdLim, FMGCInternal.clean, 999);
               }
            } elsif (FMGCInternal.phase == 7){
               # done phase. v2 is reset
               fmgc.FMGCInternal.v2 = 0;
               fmgc.FMGCInternal.v2set = 0;
               fmgc.FMGCNodes.v2set.setBoolValue(nil);
               fmgc.FMGCNodes.v2.setValue(0);
            }
            
            # Clamp to maneouvering speed of current configuration and maxspeed
            # Use minspeed node rather than variable, because we don't want to take GS MINI into account
            if (FMGCInternal.phase >= 2) {
               if (!FMGCInternal.mngKtsMach) {
                  FMGCInternal.mngSpd = math.clamp(FMGCInternal.mngSpdCmd, FMGCNodes.minspeed.getValue(), FMGCInternal.maxspeed);
               } else {
                  FMGCInternal.mngSpd = math.clamp(FMGCInternal.mngSpdCmd, ktToMach(FMGCNodes.minspeed.getValue()), ktToMach(FMGCInternal.maxspeed));
               }
            } else {
               FMGCInternal.mngSpd = FMGCInternal.mngSpdCmd;
            }
            
            # Update value of ktsMach
            if (ktsmach and !FMGCInternal.mngKtsMach) {
               Input.ktsMach.setValue(0);
            } elsif (!ktsmach and FMGCInternal.mngKtsMach) {
               Input.ktsMach.setValue(1);
            }
            
            if (Input.kts.getValue() != FMGCInternal.mngSpd and !ktsmach ) {
               Input.kts.setValue(FMGCInternal.mngSpd);
            } elsif (Input.mach.getValue() != FMGCInternal.mngSpd and ktsmach) {
               Input.mach.setValue(FMGCInternal.mngSpd);
            }

            # valid managed speed
            FMGCNodes.mngSpdActive.setBoolValue(1);
            if (!fcu.input.spdPreselect.getBoolValue()) {
               fcu.FCUController.spdWindowOpen.setBoolValue(nil);
            }
         } else {
            # v2 not initialized 
            FMGCNodes.mngSpdActive.setBoolValue(nil);
            if (!fcu.input.spdPreselect.getBoolValue() and
               (systems.ADIRS.Operating.aligned[0].getBoolValue() or  
               systems.ADIRS.Operating.aligned[1].getBoolValue() or  
               systems.ADIRS.Operating.aligned[2].getBoolValue())) 
            {
                  fcu.FCUController.spdWindowOpen.setBoolValue(nil);
            } else {
                  fcu.FCUController.spdWindowOpen.setBoolValue(1);
            }
         }
      } else {
         # conditions for active managed speed not met
         fmgc.ManagedSPD.stop();
         fmgc.FMGCNodes.mngSpdActive.setBoolValue(nil);
         if (fcu.input.spdPreselect.getBoolValue()){
            fcu.input.spdPreselect.setBoolValue(nil);
            fcu.spdSelectTimer.stop();
            if (fmgc.Input.ktsMach.getBoolValue()){
               fmgc.Input.mach.setValue(fcu.input.mach.getValue());
            } else {
               fmgc.Input.kts.setValue(fcu.input.kts.getValue());
            }
         } else {
            if (fmgc.Input.ktsMach.getBoolValue()){
               fcu.FCUController.mach = math.clamp(math.round(fmgc.Velocities.indicatedMach.getValue(), 0.01), 0.01, 0.99);
               fmgc.Input.mach.setValue(fcu.FCUController.mach);
               fcu.input.mach.setValue(fcu.FCUController.mach);
            } else {
               fcu.FCUController.ias = math.clamp(math.round(fmgc.Velocities.indicatedAirspeedKt.getValue()), 100, 399);
               fmgc.Input.kts.setValue(fcu.FCUController.ias);
               fcu.input.kts.setValue(fcu.FCUController.ias);
            }
         }
         fcu.FCUController.spdWindowOpen.setBoolValue(1);
      }
	} else {
      # no FCU: speed cannot be controlled
      # no commands to FCU
      fmgc.ManagedSPD.stop();
      fmgc.FMGCNodes.mngSpdActive.setBoolValue(nil);
      if (fcu.input.spdPreselect.getBoolValue()){
         fcu.input.spdPreselect.setBoolValue(nil);
         fcu.spdSelectTimer.stop();
         if (fmgc.Input.ktsMach.getBoolValue()){
            fmgc.Input.mach.setValue(fcu.input.mach.getValue());
         } else {
            fmgc.Input.kts.setValue(fcu.input.kts.getValue());
         }
      } else {
         if (fmgc.Input.ktsMach.getBoolValue()){
            fcu.FCUController.mach = math.clamp(math.round(fmgc.Velocities.indicatedMach.getValue(), 0.01), 0.01, 0.99);
            fmgc.Input.mach.setValue(fcu.FCUController.mach);
            fcu.input.mach.setValue(fcu.FCUController.mach);
         } else {
            fcu.FCUController.ias = math.clamp(math.round(fmgc.Velocities.indicatedAirspeedKt.getValue()), 100, 399);
            fmgc.Input.kts.setValue(fcu.FCUController.ias);
            fcu.input.kts.setValue(fcu.FCUController.ias);
         }
      }
      fcu.FCUController.spdWindowOpen.setBoolValue(1);
   }
});

# Nav Database
var navDataBase = {
	currentCode: "AB20170101",
	currentDate: "01JAN-28JAN",
	standbyCode: "AB20170102",
	standbyDate: "29JAN-26FEB",
};

var tempStoreCode = nil;
var tempStoreDate = nil;
var switchDatabase = func {
	tempStoreCode = navDataBase.currentCode;
	tempStoreDate = navDataBase.currentDate;
	navDataBase.currentCode = navDataBase.standbyCode;
	navDataBase.currentDate = navDataBase.standbyDate;
	navDataBase.standbyCode = tempStoreCode;
	navDataBase.standbyDate = tempStoreDate;
}

##################################
# setlisteners for managed speed #
##################################
# set managed speed on ground if v2 entered 
setlistener("/FMGC/internal/v2-set", func() {
	if (FMGCInternal.phase == 0 or (getprop("/gear/gear[1]/wow") and getprop("/gear/gear[2]/wow"))) {
      fmgc.ManagedSPD.start();
	} else {
      me.removelistener();       
   }
}, 0, 0);

# set managed speed if SRS, EXP CLB, EXP DES or TCAS
setlistener("/FMGC/internal/pitch-mode", func() {
	if (FMGCNodes.pitchMode.getValue() == "SRS" or FMGCNodes.pitchMode.getValue() == "EXP CLB" 
         or FMGCNodes.pitchMode.getValue() == "EXP DES" or FMGCNodes.pitchMode.getValue() == "TCAS" ) {
      fmgc.ManagedSPD.start();
	}
}, 0, 0);

# enable managed speed if FMS has a valid position when on ground
setlistener("/systems/navigation/aligned-1", func(val) {
   if ((getprop("/gear/gear[1]/wow") and getprop("/gear/gear[2]/wow"))){
      fmgc.ManagedSPD.start();
   }
}, 0, 0);

setlistener("/systems/navigation/aligned-2", func(val) {
   if ((getprop("/gear/gear[1]/wow") and getprop("/gear/gear[2]/wow"))){
      fmgc.ManagedSPD.start();
   }
}, 0, 0);

setlistener("/systems/navigation/aligned-3", func(val) {
   if ((getprop("/gear/gear[1]/wow") and getprop("/gear/gear[2]/wow"))){
      fmgc.ManagedSPD.start();
   }
}, 0, 0);

setlistener("/it-autoflight/output/fd1", func(val) {
   if (val.getBoolValue() and getprop("/gear/gear[1]/wow") and getprop("/gear/gear[2]/wow") and !fmgc.Output.fd2.getBoolValue()){
      fmgc.ManagedSPD.start();
   }
}, 0, 0);

setlistener("/it-autoflight/output/fd2", func(val) {
   if (val.getBoolValue() and getprop("/gear/gear[1]/wow") and getprop("/gear/gear[2]/wow") and !fmgc.Output.fd1.getBoolValue()){
      fmgc.ManagedSPD.start();
   }
}, 0, 0);

###################################
# setlisteners for selected speed #
###################################
setlistener("/ECAM/logic/ground-calc-immediate", func(val) {
      if (val.getBoolValue()) {
         # on gnd
         if (FMGCInternal.landingTime == -99) {
            timer30secLanding.start();
            FMGCInternal.landingTime = pts.Sim.Time.elapsedSec.getValue();

            FMGCNodes.selSpdEnable.setBoolValue(1);
            bothMainWowAfterLanding();
         }
      } else {
         # in air
         # enable selected speed after 5 sec
	      FMGCNodes.selSpdEnable.setBoolValue(0);
         timer5selSpdEnable.start();

         if(timer30secLanding.isRunning) {
            timer30secLanding.stop();
            FMGCInternal.landingTime = -99;

         }
      }
}, 0, 0);

setlistener("/ECAM/phases/phase-calculation/one-engine-running", func(val) {
      if (val.getBoolValue() and ecam.FWC.Logic.gnd.getBoolValue()){
         fmgc.FMGCNodes.selSpdEnable.setBoolValue(0);
         fmgc.ManagedSPD.start();
      } else {
         fmgc.FMGCNodes.selSpdEnable.setBoolValue(1);
      }
}, 0, 0);

# Align IRS 1
setlistener("/systems/navigation/adr/operating-1", func() {
	if (timer48gpsAlign1.isRunning) {
		timer48gpsAlign1.stop();
	}
	
	if (FMGCAlignTime[0].getValue() == -99) {
		timer48gpsAlign1.start();
		FMGCAlignTime[0].setValue(pts.Sim.Time.elapsedSec.getValue());
	}
}, 0, 0);

# Align IRS 2
setlistener("/systems/navigation/adr/operating-2", func() {
	if (timer48gpsAlign2.isRunning) {
		timer48gpsAlign2.stop();
	}
	
	if (FMGCAlignTime[1].getValue() == -99) {
		timer48gpsAlign2.start();
		FMGCAlignTime[1].setValue(pts.Sim.Time.elapsedSec.getValue());
	}
}, 0, 0);

# Align IRS 3
setlistener("/systems/navigation/adr/operating-3", func() {
	if (timer48gpsAlign3.isRunning) {
		timer48gpsAlign3.stop();
	}
	
	if (FMGCAlignTime[2].getValue() == -99) {
		timer48gpsAlign3.start();
		FMGCAlignTime[2].setValue(pts.Sim.Time.elapsedSec.getValue());
	}
}, 0, 0);

###################################

# Calculate Block Fuel
setlistener("/FMGC/internal/block-calculating", func() {
	if (timer3blockFuel.isRunning) {
		FMGCInternal.blockFuelTime = -99;
		timer3blockFuel.stop();
	}
	
	if (FMGCInternal.blockFuelTime == -99) {
		timer3blockFuel.start();
		FMGCInternal.blockFuelTime = pts.Sim.Time.elapsedSec.getValue();
	}
}, 0, 0);

# Calculate Fuel Prediction
setlistener("/FMGC/internal/fuel-calculating", func() {
	if (timer5fuelPred.isRunning) {
		FMGCInternal.fuelPredTime = -99;
		timer5fuelPred.stop();
	}
	
	if (FMGCInternal.fuelPredTime == -99) {
		timer5fuelPred.start();
		FMGCInternal.fuelPredTime = pts.Sim.Time.elapsedSec.getValue();
	}
}, 0, 0);

# Maketimers
var timer30secLanding = maketimer(1, func() {
	if (pts.Sim.Time.elapsedSec.getValue() > (FMGCInternal.landingTime + 30)) {
		FMGCInternal.phase = 7;
		FMGCNodes.phase.setValue(7);
		
		if (FMGCInternal.costIndexSet) {
			setprop("/FMGC/internal/last-cost-index", FMGCInternal.costIndex);
		} else {
			setprop("/FMGC/internal/last-cost-index", 0);
		}
		FMGCInternal.landingTime = -99;
		timer30secLanding.stop();
	}
});

var timer48gpsAlign1 = maketimer(1, func() {
	if (pts.Sim.Time.elapsedSec.getValue() > (FMGCAlignTime[0].getValue() + 48) or adirsSkip.getValue()) {
		FMGCAlignDone[0].setValue(1);
		FMGCAlignTime[0].setValue(-99);
		timer48gpsAlign1.stop();
	}
});

var timer48gpsAlign2 = maketimer(1, func() {
	if (pts.Sim.Time.elapsedSec.getValue() > (FMGCAlignTime[1].getValue() + 48) or adirsSkip.getValue()) {
		FMGCAlignDone[1].setValue(1);
		FMGCAlignTime[1].setValue(-99);
		timer48gpsAlign2.stop();
	}
});

var timer48gpsAlign3 = maketimer(1, func() {
	if (pts.Sim.Time.elapsedSec.getValue() > (FMGCAlignTime[2].getValue() + 48) or adirsSkip.getValue()) {
		FMGCAlignDone[2].setValue(1);
		FMGCAlignTime[2].setValue(-99);
		timer48gpsAlign3.stop();
	}
});

var timer3blockFuel = maketimer(1, func() {
	if (pts.Sim.Time.elapsedSec.getValue() > FMGCInternal.blockFuelTime + 3) {
		#updateFuel();
		fmgc.FMGCInternal.blockCalculating = 0;
		fmgc.blockCalculating.setValue(0);
		FMGCInternal.blockFuelTime = -99;
		timer3blockFuel.stop();
	}
});

var timer5fuelPred = maketimer(1, func() {
	if (pts.Sim.Time.elapsedSec.getValue() > FMGCInternal.fuelPredTime + 5) {
		#updateFuel();
		fmgc.FMGCInternal.fuelCalculating = 0;
		fmgc.fuelCalculating.setValue(0);
		FMGCInternal.fuelPredTime = -99;
		timer5fuelPred.stop();
	}
});

var timer5trimReset = maketimer(5, func() {
	trimReset();
});
var timer5selSpdEnable = maketimer(5, func() {
	fmgc.FMGCNodes.selSpdEnable.setBoolValue(1);
});
