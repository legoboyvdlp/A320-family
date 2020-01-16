# A3XX FMGC Flightplan Driver
# Copyright (c) 2019 Jonathan Redpath (2019)

var magTrueError = 0;

var wpDep = nil;
var wpArr = nil;
var pos = nil;
var geoPosPrev = geo.Coord.new();
var currentLegCourseDist = nil;
var courseDistanceFrom = nil;
var courseDistanceFromPrev = nil;
var sizeWP = nil;
var magTrueError = 0;

# Props.getNode
var magHDG = props.globals.getNode("/orientation/heading-magnetic-deg", 1);
var trueHDG = props.globals.getNode("/orientation/heading-deg", 1);
var FMGCdep = props.globals.getNode("/FMGC/internal/dep-arpt", 1);
var FMGCarr = props.globals.getNode("/FMGC/internal/arr-arpt", 1);
var toFromSet = props.globals.getNode("/FMGC/internal/tofrom-set", 1);

# Props.initNode
var wpID = [[props.globals.initNode("/FMGC/flightplan[0]/wp[0]/id", "", "STRING")], [props.globals.initNode("/FMGC/flightplan[1]/wp[0]/id", "", "STRING")], [props.globals.initNode("/FMGC/flightplan[2]/wp[0]/id", "", "STRING")]];
var wpLat = [[props.globals.initNode("/FMGC/flightplan[0]/wp[0]/lat", 0, "DOUBLE")], [props.globals.initNode("/FMGC/flightplan[1]/wp[0]/lat", 0, "DOUBLE")], [props.globals.initNode("/FMGC/flightplan[2]/wp[0]/lat", 0, "DOUBLE")]];
var wpLon = [[props.globals.initNode("/FMGC/flightplan[0]/wp[0]/lon", 0, "DOUBLE")], [props.globals.initNode("/FMGC/flightplan[1]/wp[0]/lon", 0, "DOUBLE")], [props.globals.initNode("/FMGC/flightplan[2]/wp[0]/lon", 0, "DOUBLE")]];
var wpCourse = [[props.globals.initNode("/FMGC/flightplan[0]/wp[0]/course", 0, "DOUBLE")], [props.globals.initNode("/FMGC/flightplan[1]/wp[0]/course", 0, "DOUBLE")], [props.globals.initNode("/FMGC/flightplan[2]/wp[0]/course", 0, "DOUBLE")]];
var wpDistance = [[props.globals.initNode("/FMGC/flightplan[0]/wp[0]/distance", 0, "DOUBLE")], [props.globals.initNode("/FMGC/flightplan[1]/wp[0]/distance", 0, "DOUBLE")], [props.globals.initNode("/FMGC/flightplan[2]/wp[0]/distance", 0, "DOUBLE")]];
var wpCoursePrev = [[props.globals.initNode("/FMGC/flightplan[0]/wp[0]/course-from-prev", 0, "DOUBLE")], [props.globals.initNode("/FMGC/flightplan[1]/wp[0]/course-from-prev", 0, "DOUBLE")], [props.globals.initNode("/FMGC/flightplan[2]/wp[0]/course-from-prev", 0, "DOUBLE")]];
var wpDistancePrev = [[props.globals.initNode("/FMGC/flightplan[0]/wp[0]/distance-from-prev", 0, "DOUBLE")], [props.globals.initNode("/FMGC/flightplan[1]/wp[0]/distance-from-prev", 0, "DOUBLE")], [props.globals.initNode("/FMGC/flightplan[2]/wp[0]/distance-from-prev", 0, "DOUBLE")]];

var flightPlanController = {
	flightplans: [createFlightplan(), createFlightplan(), createFlightplan()],
	temporaryFlag: [0, 0],
	
	# These flags are only for the main flgiht-plan
	active: props.globals.initNode("/FMGC/flightplan[2]/active", 0, "BOOL"),
	
	currentToWpt: nil, # container for the current TO waypoint ghost
	currentToWptIndex: props.globals.initNode("/FMGC/flightplan[2]/current-wp", 0, "INT"),
	currentToWptID: "",
	courseToWpt: 0,
	courseMagToWpt: 0,
	distToWpt: 0,
	
	distanceToDest: [0, 0, 0],
	num: [0, 0, 0],
	arrivalIndex: [0, 0, 0],
	arrivalDist: 0,
	_arrivalDist: 0,
	
	reset: func() {
		me.temporaryFlag[0] = 0;
		me.temporaryFlag[1] = 0;
		me.resetFlightplan(0);
		me.resetFlightplan(1);
		me.resetFlightplan(2);
	},
	
	resetFlightplan: func(n) {
		me.flightplans[n].cleanPlan();
		me.flightplans[n].departure = nil;
		me.flightplans[n].destination = nil;
	},
	
	createTemporaryFlightPlan: func(n) {
		me.resetFlightplan(n);
		me.flightplans[n] = me.flightplans[2].clone();
		me.temporaryFlag[n] = 1;
		me.flightPlanChanged(n);
	},
	
	destroyTemporaryFlightPlan: func(n, a) { # a = 1 activate, a = 0 erase
		if (a == 1) {
			flightPlanTimer.stop();
			me.resetFlightplan(2);
			me.flightplans[2] = me.flightplans[n].clone();
			me.flightPlanChanged(2);
			flightPlanTimer.start();
		}
		me.resetFlightplan(n);
		me.temporaryFlag[n] = 0;
	},
	
	updateAirports: func(dep, arr, plan) {
		me.resetFlightplan(plan);
		me.flightplans[plan].departure = airportinfo(dep);
		me.flightplans[plan].destination = airportinfo(arr);
		if (plan == 2) {
			me.currentToWptIndex.setValue(0);
		}
		
		me.addDiscontinuity(1, plan);
		#todo if plan = 2, kill any tmpy flightplan
		me.flightPlanChanged(plan);
	},
	
	autoSequencing: func() {
		if (me.num[2] > 2) {
			if (me.temporaryFlag[0] == 1 and wpID[0][0] == wpID[2][0]) {
				me.deleteWP(0, 0);
			}
			
			if (me.temporaryFlag[1] == 1 and wpID[1][0] == wpID[2][0]) {
				me.deleteWP(0, 1);
			}
			
			me.deleteWP(0, 2);
		}
	},
	
	# for these two remember to call flightPlanChanged
	addDiscontinuity: func(index, plan) {
		me.flightplans[plan].insertWP(createDiscontinuity(), index);
	},
	
	insertPPOS: func(n) {
		me.flightplans[n].insertWP(createWP(geo.aircraft_position(), "PPOS"), 0);
	},
	
	deleteWP: func(index, n, a = 0) { # a = 1, means adding a waypoint via deleting intermediate
		var wp = wpID[n][index].getValue();
		if (wp != FMGCdep.getValue() and wp != FMGCarr.getValue() and me.flightplans[n].getPlanSize() > 2) {
			if (me.flightplans[n].getWP(index).id != "DISCONTINUITY" and a == 0) { # if it is a discont, don't make a new one
				me.flightplans[n].deleteWP(index);
				if (me.flightplans[n].getWP(index).id != "DISCONTINUITY") { # else, if the next one isn't a discont, add one
					me.addDiscontinuity(index, n);
				}
			} else {
				me.flightplans[n].deleteWP(index);
			}
			me.flightPlanChanged(n);
			canvas_nd.A3XXRouteDriver.triggerSignal("fp-removed");
			return 2;
		} else {
			return 1;
		}
	},
	
	insertAirport: func(text, index, plan, override = 0, overrideIndex = -1) {
		if (index == 0) {
			return 1;
		}
		
		var airport = findAirportsByICAO(text);
		if (size(airport) == 0) {
			return 0;
		}
		
		if (size(airport) == 1 or override) {
			if (!override) {
				if (me.flightplans[plan].indexOfWP(airport[0]) == -1) {
					me.flightplans[plan].insertWP(createWPFrom(airport[0]), index);
					me.flightPlanChanged(plan);
					return 2;
				} else {
					var numToDel = me.flightplans[plan].indexOfWP(airport[0]) - index;
					while (numToDel > 0) {
						me.deleteWP(index + 1, plan, 1);
						numToDel -= 1;
					}
					return 2;
				}
			} else {
				if (me.flightplans[plan].indexOfWP(airport[overrideIndex]) == -1) {
					me.flightplans[plan].insertWP(createWPFrom(airport[overrideIndex]), index);
					me.flightPlanChanged(plan);
					return 2;
				} else {
					var numToDel = me.flightplans[plan].indexOfWP(airport[overrideIndex]) - index;
					while (numToDel > 0) {
						me.deleteWP(index + 1, plan, 1);
						numToDel -= 1;
					}
					return 2;
				}
			}
		} elsif (size(airport) >= 1) {
			if (canvas_mcdu.myDeparture[plan] != nil) {
				canvas_mcdu.myDeparture[plan].del();
			}
			canvas_mcdu.myDeparture[plan] = nil;
			canvas_mcdu.myDuplicate[plan] = mcdu.duplicateNamesPage.new(airport, index, 0, plan);
			setprop("/MCDU[" ~ plan ~ "]/page", "DUPLICATENAMES");
			return 2;
		}
	},
	
	insertFix: func(text, index, plan, override = 0, overrideIndex = -1) { # override - means always choose [0]
		if (index == 0) {
			return 1;
		}
		
		var fix = findFixesByID(text);
		if (size(fix) == 0) {
			return 0;
		}
		
		if (size(fix) == 1 or override) {
			if (!override) {
				if (me.flightplans[plan].indexOfWP(fix[0]) == -1) {
					me.flightplans[plan].insertWP(createWPFrom(fix[0]), index);
					me.flightPlanChanged(plan);
					return 2;
				} else {
					var numToDel = me.flightplans[plan].indexOfWP(fix[0]) - index;
					while (numToDel > 0) {
						me.deleteWP(index + 1, plan, 1);
						numToDel -= 1;
					}
					return 2;
				}
			} else {
				if (me.flightplans[plan].indexOfWP(fix[overrideIndex]) == -1) {
					me.flightplans[plan].insertWP(createWPFrom(fix[overrideIndex]), index);
					me.flightPlanChanged(plan);
					return 2;
				} else {
					var numToDel = me.flightplans[plan].indexOfWP(fix[overrideIndex]) - index;
					while (numToDel > 0) {
						me.deleteWP(index + 1, plan, 1);
						numToDel -= 1;
					}
					return 2;
				}
			}
		} elsif (size(fix) >= 1) {
			if (canvas_mcdu.myDeparture[plan] != nil) {
				canvas_mcdu.myDeparture[plan].del();
			}
			canvas_mcdu.myDeparture[plan] = nil;
			canvas_mcdu.myDuplicate[plan] = mcdu.duplicateNamesPage.new(fix, index, 0, plan);
			setprop("/MCDU[" ~ plan ~ "]/page", "DUPLICATENAMES");
			return 2;
		}
	},
	
	insertLatLonFix: func(text, index, plan) {
		if (index == 0) {
			return 1;
		}
		
		var lat = split("/", text)[0];
		var lon = split("/", text)[1];
		var latDecimal = mcdu.stringToDegrees(lat, "lat");
		var lonDecimal = mcdu.stringToDegrees(lon, "lon");
		
		if (latDecimal > 90 or latDecimal < -90 or lonDecimal > 180 or lonDecimal < -180) {
			return 1;
		}
		
		var myWpLatLon = createWP(latDecimal, lonDecimal, "LL" ~ index);
		if (me.flightplans[plan].indexOfWP(myWpLatLon) == -1) {
			me.flightplans[plan].insertWP(myWpLatLon, index);
			me.flightPlanChanged(plan);
			return 2;
		} else {
			var numToDel = me.flightplans[plan].indexOfWP(myWpLatLon) - index;
			while (numToDel > 0) {
				me.deleteWP(index + 1, plan, 1);
				numToDel -= 1;
			}
			return 2;
		}
	},
	
	insertNavaid: func(text, index, plan, override = 0, overrideIndex = -1) {
		if (index == 0) {
			return 1;
		}
		
		var navaid = findNavaidsByID(text);
		if (size(navaid) == 0) {
			return 0;
		}
		
		if (size(navaid) == 1 or override) {
			if (!override) {
				if (me.flightplans[plan].indexOfWP(navaid[0]) == -1) {
					me.flightplans[plan].insertWP(createWPFrom(navaid[0]), index);
					me.flightPlanChanged(plan);
					return 2;
				} else {
					var numToDel = me.flightplans[plan].indexOfWP(navaid[0]) - index;
					while (numToDel > 0) {
						me.deleteWP(index + 1, plan, 1);
						numToDel -= 1;
					}
					return 2;
				}
			} else {
				if (me.flightplans[plan].indexOfWP(navaid[overrideIndex]) == -1) {
					me.flightplans[plan].insertWP(createWPFrom(navaid[overrideIndex]), index);
					me.flightPlanChanged(plan);
					return 2;
				} else {
					var numToDel = me.flightplans[plan].indexOfWP(navaid[overrideIndex]) - index;
					while (numToDel > 0) {
						me.deleteWP(index + 1, plan, 1);
						numToDel -= 1;
					}
					return 2;
				}
			}
		} elsif (size(navaid) >= 1) {
			if (canvas_mcdu.myDeparture[plan] != nil) {
				canvas_mcdu.myDeparture[plan].del();
			}
			canvas_mcdu.myDeparture[plan] = nil;
			canvas_mcdu.myDuplicate[plan] = mcdu.duplicateNamesPage.new(navaid, index, 1, plan);
			setprop("/MCDU[" ~ plan ~ "]/page", "DUPLICATENAMES");
			return 2;
		}
	},
	
	scratchpad: func(text, index, plan) { # return 0 not in database, 1 not allowed, 2 success
		if (!fmgc.flightPlanController.temporaryFlag[plan]) {
			if (text == "CLR" and me.flightplans[2].getWP(index).wp_name == "DISCONTINUITY") {
				var thePlan = 2;
			} else {
				fmgc.flightPlanController.createTemporaryFlightPlan(plan);
				var thePlan = plan;
			}
		} else {
			var thePlan = plan;
		}
		
		if (text == "CLR") {
			return me.deleteWP(index, thePlan, 0);
		} elsif (size(text) == 16) {
			return me.insertLatLonFix(text, index, thePlan);
		} elsif (size(text) == 5) {
			return me.insertFix(text, index, thePlan);
		} elsif (size(text) == 4) {
			return me.insertAirport(text, index, thePlan);
		} elsif (size(text) == 3 or size(text) == 2) {
			return me.insertNavaid(text, index, thePlan);
		} else {
			return 1;
		}
	},
	
	flightPlanChanged: func(n) {
		sizeWP = size(wpID[n]);
		for (var counter = sizeWP; counter < me.flightplans[n].getPlanSize(); counter += 1) { # create new properties if they are required
			append(wpID[n], props.globals.initNode("/FMGC/flightplan[" ~ n ~ "]/wp[" ~ counter ~ "]/text", "", "STRING"));
			append(wpLat[n], props.globals.initNode("/FMGC/flightplan[" ~ n ~ "]/wp[" ~ counter ~ "]/lat", 0, "DOUBLE"));
			append(wpLon[n], props.globals.initNode("/FMGC/flightplan[" ~ n ~ "]/wp[" ~ counter ~ "]/lon", 0, "DOUBLE"));
			append(wpCourse[n], props.globals.initNode("/FMGC/flightplan[" ~ n ~ "]/wp[" ~ counter ~ "]/course", 0, "DOUBLE"));
			append(wpDistance[n], props.globals.initNode("/FMGC/flightplan[" ~ n ~ "]/wp[" ~ counter ~ "]/distance", 0, "DOUBLE"));
			append(wpCoursePrev[n], props.globals.initNode("/FMGC/flightplan[" ~ n ~ "]/wp[" ~ counter ~ "]/course-from-prev", 0, "DOUBLE"));
			append(wpDistancePrev[n], props.globals.initNode("/FMGC/flightplan[" ~ n ~ "]/wp[" ~ counter ~ "]/distance-from-prev", 0, "DOUBLE"));
		}
		me.updatePlans();
		canvas_nd.A3XXRouteDriver.triggerSignal("fp-added");
	},
	
	updatePlans: func() {
		me.updateCurrentWaypoint();
		me._arrivalDist = 0;
		for (var n = 0; n <= 2; n += 1) {
			for (var wpt = 0; wpt < me.flightplans[n].getPlanSize(); wpt += 1) { # Iterate through the waypoints and update their data
				var curAircraftPos = geo.aircraft_position(); # don't want to get this corrupted so make sure it is a local variable
				var waypointHashStore = me.flightplans[n].getWP(wpt);
				
				courseDistanceFrom = waypointHashStore.courseAndDistanceFrom(curAircraftPos);
				wpID[n][wpt].setValue(waypointHashStore.wp_name);
				wpLat[n][wpt].setValue(waypointHashStore.wp_lat);
				wpLon[n][wpt].setValue(waypointHashStore.wp_lon);
				
				wpCourse[n][wpt].setValue(waypointHashStore.courseAndDistanceFrom(curAircraftPos)[0]);
				wpDistance[n][wpt].setValue(waypointHashStore.courseAndDistanceFrom(curAircraftPos)[1]);
				
				if (wpt > 0) {
					if (me.flightplans[n].getWP(wpt).id == "DISCONTINUITY") {
					wpCoursePrev[n][wpt].setValue(0);
					wpDistancePrev[n][wpt].setValue(0);
					continue; 
					}
					
					if (me.flightplans[n].getWP(wpt - 1).id == "DISCONTINUITY") {
						geoPosPrev.set_latlon(me.flightplans[n].getWP(wpt - 2).lat, me.flightplans[n].getWP(wpt - 2).lon);
					} else {
						geoPosPrev.set_latlon(me.flightplans[n].getWP(wpt - 1).lat, me.flightplans[n].getWP(wpt - 1).lon);
					}
					
					courseDistanceFromPrev = waypointHashStore.courseAndDistanceFrom(geoPosPrev);
					wpCoursePrev[n][wpt].setValue(courseDistanceFromPrev[0]);
					wpDistancePrev[n][wpt].setValue(courseDistanceFromPrev[1]);
					me._arrivalDist += courseDistanceFromPrev[1];
				} else {
					# use PPOS for the first waypoint
					wpCoursePrev[n][wpt].setValue(courseDistanceFrom[0]);
					wpDistancePrev[n][wpt].setValue(courseDistanceFrom[1]);
				}
				
				if (left(wpID[n][wpt].getValue(), 4) == FMGCarr.getValue()) {
					if (me.arrivalIndex[n] != wpt) { # don't merge line 397 and 398 if statements
						me.arrivalIndex[n] = wpt;
						if (canvas_mcdu.myFpln[0] != nil) {
							canvas_mcdu.myFpln[0].destInfo();
						}
						if (canvas_mcdu.myFpln[1] != nil) {
							canvas_mcdu.myFpln[1].destInfo();
						}
					}
				}
			}
		}
		me.arrivalDist = me._arrivalDist;
		me.updateMCDUDriver(n);
	},
	
	updateCurrentWaypoint: func() {
		for (var i = 0; i <= 2; i += 1) {
			if (toFromSet.getBoolValue() and me.flightplans[i].departure != nil and me.flightplans[i].destination != nil) { # check if flightplan exists
				var curAircraftPos = geo.aircraft_position(); # don't want to get this corrupted so make sure it is a local variable
	
				if (i == 2) { # main plan
					if (!me.active.getBoolValue()) {
						me.active.setValue(1);
					}
					
					if (me.currentToWptIndex.getValue() > me.flightplans[i].getPlanSize()) {
						me.currentToWptIndex.setValue(me.flightplans[i].getPlanSize());
					}
					
					me.currentToWpt = me.flightplans[i].getWP(me.currentToWptIndex.getValue());
					
					me.currentToWptId = me.currentToWpt.wp_name;
					me.courseToWpt = me.currentToWpt.courseAndDistanceFrom(curAircraftPos)[0];
					me.distToWpt = me.currentToWpt.courseAndDistanceFrom(curAircraftPos)[1];
					
					magTrueError = magHDG.getValue() - trueHDG.getValue();
					me.courseMagToWpt = me.courseToWpt + magTrueError;
					
					return;
				}
				
				me.num[i] = me.flightplans[i].getPlanSize();
			} else {
				if (i == 2) {
					if (me.active.getBoolValue()) {
						me.active.setValue(0);
					}
					me.currentToWptID = "";
				}
				me.num[i] = 0;
			}
		}
	},
	
	updateMCDUDriver: func() {
		for (var i = 0; i <= 1; i += 1) {
			if (canvas_mcdu.myFpln[i] != nil) {
				canvas_mcdu.myFpln[i].updatePlan();
			}
		}
	},
};

var flightPlanTimer = maketimer(0.1, flightPlanController, flightPlanController.updatePlans);
