# A3XX FMGC Flightplan Driver

# Copyright (c) 2019 Joshua Davidson (Octal450)
# This thing replaces the Route Manager, it's far from finished though

# 0 = TEMP FP Captain MCDU
# 1 = TEMP FP First Officer MCDU
# 2 = ACTIVE FP
var fp = [createFlightplan(), createFlightplan(), createFlightplan()];
var wpDep = nil;
var wpArr = nil;
var pos = nil;
var geoPos = nil;
var geoPosPrev = geo.Coord.new();
var currentLegCourseDist = nil;
var courseDistanceFrom = nil;
var courseDistanceFromPrev = nil;
var sizeWP = nil;
var magTrueError = 0;
var arrivalAirportI = [0, 0, 0];

# Vars for MultiFlightplan
var currentWP = [nil, nil, 0];
var currentLeg = [nil, nil, ""];

# Create/Fetch props.nas for MultiFlightplan
var altFeet = props.globals.getNode("/instrumentation/altimeter/indicated-altitude-ft", 1);
var active_out = [nil, nil, props.globals.initNode("/FMGC/flightplan[2]/active", 0, "BOOL")];
var currentWP_out = [nil, nil, props.globals.initNode("/FMGC/flightplan[2]/current-wp", 0, "INT")];
var currentLeg_out = [nil, nil, props.globals.initNode("/FMGC/flightplan[2]/current-leg", "", "STRING")];
var currentLegCourse_out = [nil, nil, props.globals.initNode("/FMGC/flightplan[2]/current-leg-course", 0, "DOUBLE")];
var currentLegDist_out = [nil, nil, props.globals.initNode("/FMGC/flightplan[2]/current-leg-dist", 0, "DOUBLE")];
var currentLegCourseMag_out = [nil, nil, props.globals.initNode("/FMGC/flightplan[2]/current-leg-course-mag", 0, "DOUBLE")];
var arrivalLegDist_out = [props.globals.initNode("/FMGC/flightplan[0]/arrival-leg-dist", 0, "DOUBLE"), props.globals.initNode("/FMGC/flightplan[1]/arrival-leg-dist", 0, "DOUBLE"), props.globals.initNode("/FMGC/flightplan[2]/arrival-leg-dist", 0, "DOUBLE")];
var num_out = [props.globals.initNode("/FMGC/flightplan[0]/num", 0, "INT"), props.globals.initNode("/FMGC/flightplan[1]/num", 0, "INT"), props.globals.initNode("/FMGC/flightplan[2]/num", 0, "INT")];
var toFromSet = props.globals.initNode("/FMGC/internal/tofrom-set", 0, "BOOL");
var magHDG = props.globals.getNode("/orientation/heading-magnetic-deg", 1);
var trueHDG = props.globals.getNode("/orientation/heading-deg", 1);
var FMGCdep = props.globals.getNode("/FMGC/internal/dep-arpt", 1);
var FMGCarr = props.globals.getNode("/FMGC/internal/arr-arpt", 1);
var TMPYActive = [props.globals.initNode("/FMGC/internal/tmpy-active[0]", 0, "BOOL"), props.globals.initNode("/FMGC/internal/tmpy-active[1]", 0, "BOOL")];

# Create props.nas for flightplan
# Vectors inside vectors, so we can use as many flightplans or waypoints as we want
var wpID = [[props.globals.initNode("/FMGC/flightplan[0]/wp[0]/id", "", "STRING")], [props.globals.initNode("/FMGC/flightplan[1]/wp[0]/id", "", "STRING")], [props.globals.initNode("/FMGC/flightplan[2]/wp[0]/id", "", "STRING")]];
var wpLat = [[props.globals.initNode("/FMGC/flightplan[0]/wp[0]/lat", 0, "DOUBLE")], [props.globals.initNode("/FMGC/flightplan[1]/wp[0]/lat", 0, "DOUBLE")], [props.globals.initNode("/FMGC/flightplan[2]/wp[0]/lat", 0, "DOUBLE")]];
var wpLon = [[props.globals.initNode("/FMGC/flightplan[0]/wp[0]/lon", 0, "DOUBLE")], [props.globals.initNode("/FMGC/flightplan[1]/wp[0]/lon", 0, "DOUBLE")], [props.globals.initNode("/FMGC/flightplan[2]/wp[0]/lon", 0, "DOUBLE")]];
var wpCourse = [[props.globals.initNode("/FMGC/flightplan[0]/wp[0]/course", 0, "DOUBLE")], [props.globals.initNode("/FMGC/flightplan[1]/wp[0]/course", 0, "DOUBLE")], [props.globals.initNode("/FMGC/flightplan[2]/wp[0]/course", 0, "DOUBLE")]];
var wpDistance = [[props.globals.initNode("/FMGC/flightplan[0]/wp[0]/distance", 0, "DOUBLE")], [props.globals.initNode("/FMGC/flightplan[1]/wp[0]/distance", 0, "DOUBLE")], [props.globals.initNode("/FMGC/flightplan[2]/wp[0]/distance", 0, "DOUBLE")]];
var wpCoursePrev = [[props.globals.initNode("/FMGC/flightplan[0]/wp[0]/course-from-prev", 0, "DOUBLE")], [props.globals.initNode("/FMGC/flightplan[1]/wp[0]/course-from-prev", 0, "DOUBLE")], [props.globals.initNode("/FMGC/flightplan[2]/wp[0]/course-from-prev", 0, "DOUBLE")]];
var wpDistancePrev = [[props.globals.initNode("/FMGC/flightplan[0]/wp[0]/distance-from-prev", 0, "DOUBLE")], [props.globals.initNode("/FMGC/flightplan[1]/wp[0]/distance-from-prev", 0, "DOUBLE")], [props.globals.initNode("/FMGC/flightplan[2]/wp[0]/distance-from-prev", 0, "DOUBLE")]];

var flightplan = {
	reset: func() {
		TMPYActive[0].setBoolValue(0);
		TMPYActive[1].setBoolValue(0);
		me.reset0();
		me.reset1();
		me.reset2();
	},
	reset0: func() {
		fp[0].cleanPlan();
		fp[0].departure = nil;
		fp[0].destination = nil;
	},
	reset1: func() {
		fp[1].cleanPlan();
		fp[1].departure = nil;
		fp[1].destination = nil;
	},
	reset2: func() {
		fp[2].cleanPlan();
		fp[2].departure = nil;
		fp[2].destination = nil;
		currentWP[2] = 0;
		currentLeg[2] = "";
	},
	initTempFP: func(f, n) { # f is temp, n is active
		fp[f] = fp[n].clone();
		TMPYActive[f].setBoolValue(1);
		me.checkWPOutputs(f);
	},
	eraseTempFP: func(f, n) { # f is temp, n is active
		TMPYActive[f].setBoolValue(0);
		if (f == 0) {
			me.reset0();
		} else if (f == 1) {
			me.reset1();
		}
		me.checkWPOutputs(n);
	},
	executeTempFP: func(f, n) { # f is temp, n is active
		fp[n] = fp[f].clone();
		TMPYActive[f].setBoolValue(0);
		if (f == 0) {
			me.reset0();
		} else if (f == 1) {
			me.reset1();
		}
		me.checkWPOutputs(n);
	},
	advanceDelete: func(n) {
		if (num_out[n].getValue() > 2) {
			if (TMPYActive[0].getBoolValue() and wpID[0][0] == wpID[n][0]) {
				me.deleteWP(0, 0);
			}
			if (TMPYActive[1].getBoolValue() and wpID[1][0] == wpID[n][0]) {
				me.deleteWP(0, 1);
			}
			me.deleteWP(0, n, 1);
		}
	},
	updateARPT: func(dep, arr, n) {
		if (n == 2) { # Which flightplan?
			me.reset2();
			
			# Set Departure ARPT
			if (dep != nil) {
				fp[2].departure = airportinfo(dep);
			} else {
				fp[2].departure = nil;
			}
			
			# Set Arrival ARPT
			if (arr != nil) {
				fp[2].destination = airportinfo(arr);
			} else {
				fp[2].destination = nil;
			}
			
			currentWP[2] = 0;
		}
		
		me.checkWPOutputs(n);
	},
	# return 1 will cause NOT IN DATABASE, return 2 will cause NOT ALLOWED
	insertFix: func(wp, i, n) {
		var pos = findFixesByID(wp);
		if (i == 0) {
			return 2;
		} else if (pos != nil and size(pos) > 0) {
			fp[n].insertWP(createWPFrom(pos[0]), i);
			me.checkWPOutputs(n);
			return 0;
		} else {
			return 1;
		}
	},
	insertArpt: func(wp, i, n) {
		var pos = findAirportsByICAO(wp);
		if (i == 0) {
			return 2;
		} else if (pos != nil and size(pos) > 0) {
			fp[n].insertWP(createWPFrom(pos[0]), i);
			me.checkWPOutputs(n);
			return 0;
		} else {
			return 1;
		}
	},
	insertNavaid: func(nav, i, n) {
		var pos = findNavaidsByID(nav);
		if (i == 0) {
			return 2;
		} else if (pos != nil and size(pos) > 0) {
			fp[n].insertWP(createWPFrom(pos[0]), i);
			me.checkWPOutputs(n);
			return 0;
		} else {
			return 1;
		}
	},
	insertPPOS: func(n) {
		fp[n].insertWP(createWP(geo.aircraft_position(), "PPOS"), 0);
		me.checkWPOutputs(n);
	},
	insertTP: func(n) {
		fp[n].insertWP(createWP(geo.aircraft_position(), "T/P"), 0);
		me.checkWPOutputs(n);
	},
	deleteWP: func(i, n, t) {
		var wp = wpID[n][i].getValue();
		if (t == 1) {
			fp[n].deleteWP(i);
			me.outputProps(); # Make sure everything is updated before we update the MCDUs.
			me.updateMCDUDriver(n);
			canvas_nd.A3XXRouteDriver.triggerSignal("fp-removed");
			return 0;
		} else {
			if (i == 0) {
				return 2;
			} else if (fp[n].getPlanSize() > 2 and wp != FMGCdep.getValue() and wp != FMGCarr.getValue() and wp != "T/P" and wp != "PPOS") {
				fp[n].deleteWP(i);
				me.outputProps(); # Make sure everything is updated before we update the MCDUs.
				me.updateMCDUDriver(n);
				canvas_nd.A3XXRouteDriver.triggerSignal("fp-removed");
				return 0;
			} else {
				return 2;
			}
		}
	},
	checkWPOutputs: func(n) {
		sizeWP = size(wpID[n]);
		for (var counter = sizeWP; counter < fp[n].getPlanSize(); counter += 1) {
			append(wpID[n], props.globals.initNode("/FMGC/flightplan[" ~ n ~ "]/wp[" ~ counter ~ "]/id", "", "STRING"));
			append(wpLat[n], props.globals.initNode("/FMGC/flightplan[" ~ n ~ "]/wp[" ~ counter ~ "]/lat", 0, "DOUBLE"));
			append(wpLon[n], props.globals.initNode("/FMGC/flightplan[" ~ n ~ "]/wp[" ~ counter ~ "]/lon", 0, "DOUBLE"));
			append(wpCourse[n], props.globals.initNode("/FMGC/flightplan[" ~ n ~ "]/wp[" ~ counter ~ "]/course", 0, "DOUBLE"));
			append(wpDistance[n], props.globals.initNode("/FMGC/flightplan[" ~ n ~ "]/wp[" ~ counter ~ "]/distance", 0, "DOUBLE"));
			append(wpCoursePrev[n], props.globals.initNode("/FMGC/flightplan[" ~ n ~ "]/wp[" ~ counter ~ "]/course-from-prev", 0, "DOUBLE"));
			append(wpDistancePrev[n], props.globals.initNode("/FMGC/flightplan[" ~ n ~ "]/wp[" ~ counter ~ "]/distance-from-prev", 0, "DOUBLE"));
		}
		me.outputProps(); # Make sure everything is updated before we update the MCDUs.
		me.updateMCDUDriver(n);
		canvas_nd.A3XXRouteDriver.triggerSignal("fp-added"); # Update the NDs
	},
	updateMCDUDriver: func(n) {
		for (var i = 0; i < 2; i += 1) { # Update the 2 MCDUs
			if (TMPYActive[i].getBoolValue()) {
				mcdu.FPLNLines[i].replacePlan(i, mcdu.TMPY, mcdu.FPLNLines[i].index);
			} else {
				mcdu.FPLNLines[i].replacePlan(2, mcdu.MAIN, mcdu.FPLNLines[i].index);
			}
		}
	},
	outputProps: func() {
		geoPos = geo.aircraft_position();
		
		for (var n = 0; n < 3; n += 1) { # Note: Some things don't get done for TMPY (0) hence all the if (n > 1) {}
			if (((n == 0 and TMPYActive[0].getBoolValue()) or (n == 1 and TMPYActive[1].getBoolValue()) or n > 1) and toFromSet.getBoolValue() and fp[n].departure != nil and fp[n].destination != nil) {
				if (n > 1) {
					if (currentWP[n] > fp[n].getPlanSize()) {
						currentWP[n] = fp[n].getPlanSize();
					}
					
					if (active_out[n].getBoolValue() != 1) {
						active_out[n].setBoolValue(1);
					}
					
					currentLeg[n] = fp[n].getWP(currentWP[n]).wp_name;
					
					if (currentLeg_out[n].getValue() != currentLeg[n]) {
						currentLeg_out[n].setValue(currentLeg[n]);
					}
					
					currentLegCourseDist = fp[n].getWP(currentWP[n]).courseAndDistanceFrom(geoPos);
					currentLegCourse_out[n].setValue(currentLegCourseDist[0]);
					currentLegDist_out[n].setValue(currentLegCourseDist[1]);
					
					magTrueError = magHDG.getValue() - trueHDG.getValue();
					currentLegCourseMag_out[n].setValue(currentLegCourseDist[0] + magTrueError); # Convert to Magnetic
				}
				
				if (num_out[n].getValue() != fp[n].getPlanSize()) {
					num_out[n].setValue(fp[n].getPlanSize());
				}
				
				for (var i = 0; i < fp[n].getPlanSize(); i += 1) {
					wpID[n][i].setValue(fp[n].getWP(i).wp_name);
					wpLat[n][i].setValue(fp[n].getWP(i).wp_lat);
					wpLon[n][i].setValue(fp[n].getWP(i).wp_lon);
					courseDistanceFrom = fp[n].getWP(i).courseAndDistanceFrom(geoPos);
					wpCourse[n][i].setValue(courseDistanceFrom[0]);
					wpDistance[n][i].setValue(courseDistanceFrom[1]);
					
					if (i > 0) { # Impossible to do from the first WP
						geoPosPrev.set_latlon(fp[n].getWP(i - 1).lat, fp[n].getWP(i - 1).lon, altFeet.getValue() * 0.3048);
						courseDistanceFromPrev = fp[n].getWP(i).courseAndDistanceFrom(geoPosPrev);
						wpCoursePrev[n][i].setValue(courseDistanceFromPrev[0]);
						wpDistancePrev[n][i].setValue(courseDistanceFromPrev[1]);
					} else { # So if its the first WP, we just use current position instead
						wpCoursePrev[n][i].setValue(courseDistanceFrom[0]);
						wpDistancePrev[n][i].setValue(courseDistanceFrom[1]);
					}
					
					if (wpID[n][i].getValue() == FMGCarr.getValue()) {
						arrivalAirportI[n] = i;
					}
				}
				
				arrivalLegDist_out[n].setValue(wpDistance[n][arrivalAirportI[n]].getValue());
			} else {
				if (n > 1) {
					if (active_out[n].getBoolValue() != 0) {
						active_out[n].setBoolValue(0);
					}
					
					if (currentLeg_out[n].getValue() != "") {
						currentLeg_out[n].setValue("");
					}
				}
				
				if (num_out[n].getValue() != 0) {
					num_out[n].setValue(0);
				}
			}
			
			if (n > 1) {
				if (currentWP[n] != nil) {
					if (currentWP_out[n].getValue() != currentWP[n]) {
						currentWP_out[n].setValue(currentWP[n]);
					}
				} else {
					if (currentWP_out[n].getValue() != 0) {
						currentWP_out[n].setValue(0);
					}
				}
			}
		}
	},
};

var outputPropsTimer = maketimer(0.1, flightplan.outputProps);
