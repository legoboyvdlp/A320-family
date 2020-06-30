# A3XX FMGC Flightplan Driver
# Copyright (c) 2020 Josh Davidson (Octal450) and Jonathan Redpath (legoboyvdlp)

var wpDep = nil;
var wpArr = nil;
var pos = nil;
var geoPosPrev = geo.Coord.new();
var currentLegCourseDist = nil;
var courseDistanceFrom = nil;
var sizeWP = nil;
var magTrueError = 0;
var storeCourse = nil;

var DEBUG_DISCONT = 0;

# Props.getNode
var magHDG = props.globals.getNode("/orientation/heading-magnetic-deg", 1);
var trueHDG = props.globals.getNode("/orientation/heading-deg", 1);
var FMGCdep = props.globals.getNode("/FMGC/internal/dep-arpt", 1);
var FMGCarr = props.globals.getNode("/FMGC/internal/arr-arpt", 1);
var toFromSet = props.globals.getNode("/FMGC/internal/tofrom-set", 1);

var flightPlanController = {
	flightplans: [createFlightplan(), createFlightplan(), createFlightplan(), nil],
	temporaryFlag: [0, 0],
	
	# These flags are only for the main flgiht-plan
	active: props.globals.initNode("/autopilot/route-manager/active", 0, "BOOL"),
	
	currentToWpt: nil, # container for the current TO waypoint ghost
	currentToWptIndex: props.globals.initNode("/autopilot/route-manager/current-wp", 1, "INT"),
	currentToWptIndexTemp: 0,
	currentToWptID: props.globals.initNode("/autopilot/route-manager/wp[0]/id", "", "STRING"),
	courseToWpt: props.globals.initNode("/autopilot/route-manager/wp[0]/true-bearing-deg", 0, "DOUBLE"),
	courseMagToWpt: props.globals.initNode("/autopilot/route-manager/wp[0]/bearing-deg", 0, "DOUBLE"),
	distToWpt: props.globals.initNode("/autopilot/route-manager/wp[0]/dist", 0, "DOUBLE"),
	wptType: nil,
	wptTypeNoAdvanceDelete: 0,
	
	num: [props.globals.initNode("/FMGC/flightplan[0]/num", 0, "INT"), props.globals.initNode("/FMGC/flightplan[1]/num", 0, "INT"), props.globals.initNode("/autopilot/route-manager/route/num", 0, "INT")],
	arrivalIndex: [0, 0, 0],
	arrivalDist: props.globals.getNode("/autopilot/route-manager/distance-remaining-nm"),
	fromWptTime: nil,
	fromWptAlt: nil,
	_timeTemp: nil,
	_altTemp: nil,
	decelPoint: nil,
	
	init: func() {
		me.resetFlightplan(2);
		me.insertPPOS(2);
		me.addDiscontinuity(1, 2, 1);
		me.flightPlanChanged(2);
		me.flightplans[2].activate();
	},
	
	reset: func() {
		me.temporaryFlag[0] = 0;
		me.temporaryFlag[1] = 0;
		me.resetFlightplan(0);
		me.resetFlightplan(1);
		me.resetFlightplan(2);
		me.flightplans[2].activate();
	},
	
	resetFlightplan: func(n) {
		me.flightplans[n].cleanPlan();
		me.flightplans[n].departure = nil;
		me.flightplans[n].destination = nil;
		mcdu.isNoTransArr[n] = 0;
		mcdu.isNoTransDep[n] = 0;
		mcdu.isNoSid[n] = 0;
		mcdu.isNoStar[n] = 0;
		mcdu.isNoVia[n] = 0;
		me.arrivalIndex[n] = 0; # reset arrival index calculations
	},
	
	createTemporaryFlightPlan: func(n) {
		me.resetFlightplan(n);
		me.flightplans[n] = me.flightplans[2].clone();
		me.temporaryFlag[n] = 1;
		if (canvas_mcdu.myDirTo[n] != nil) {
			canvas_mcdu.myDirTo[n].updateTmpy();
		}
		if (canvas_mcdu.myHold[n] != nil) {
			canvas_mcdu.myHold[n].updateTmpy();
		}
		if (canvas_mcdu.myAirways[n] != nil) {
			canvas_mcdu.myAirways[n].updateTmpy();
		}
		fmgc.windController.createTemporaryWinds(n);
		me.flightPlanChanged(n);
	},
	
	loadFlightPlan: func(path) {
		call(func {me.flightplans[3] = createFlightplan(path);}, nil, var err = []);	
		if (size(err) or me.flightplans[3] == nil) {
			print(err[0]);
			print("Load failed.");
		}
		me.destroyTemporaryFlightPlan(3, 1);
	},
	
	destroyTemporaryFlightPlan: func(n, a) { # a = 1 activate, a = 0 erase, s = 0 don't call flightplan changed
		if (a == 1) {
			flightPlanTimer.stop();
			me.resetFlightplan(2);
			me.flightplans[2] = me.flightplans[n].clone();
			me.flightplans[2].activate();
			
			if (n != 3) {
				if (mcdu.isNoSid[n] == 1) {
					mcdu.isNoSid[2] = 1;
				} else {
					mcdu.isNoSid[2] = 0;
				}
				
				if (mcdu.isNoStar[n] == 1) {
					mcdu.isNoStar[2] = 1;
				} else {
					mcdu.isNoStar[2] = 0;
				}
				
				if (mcdu.isNoVia[n] == 1) {
					mcdu.isNoVia[2] = 1;
				} else {
					mcdu.isNoVia[2] = 0;
				}
				
				if (mcdu.isNoTransDep[n] == 1) {
					mcdu.isNoTransDep[2] = 1;
				} else {
					mcdu.isNoTransDep[2] = 0;
				}
				
				if (mcdu.isNoTransArr[n] == 1) {
					mcdu.isNoTransArr[2] = 1;
				} else {
					mcdu.isNoTransArr[2] = 0;
				}
			}
			me.flightPlanChanged(2);
			flightPlanTimer.start();
		}
		if (n == 3) {  
			me.flightPlanChanged(n);
			return; 
		}
		me.resetFlightplan(n);
		me.temporaryFlag[n] = 0;
		if (canvas_mcdu.myDirTo[n] != nil) {
			canvas_mcdu.myDirTo[n].updateTmpy();
		}
		fmgc.windController.destroyTemporaryWinds(n, a);
		me.flightPlanChanged(n);
	},
	
	updateAirports: func(dep, arr, plan) {
		me.resetFlightplan(plan);
		me.flightplans[plan].departure = airportinfo(dep);
		me.flightplans[plan].destination = airportinfo(arr);
		if (plan == 2) {
			me.destroyTemporaryFlightPlan(0, 0);
			me.destroyTemporaryFlightPlan(1, 0);
			me.currentToWptIndex.setValue(0);
			me.arrivalIndex = [0, 0, 0]; # reset arrival index calculations
		}
		
		me.addDiscontinuity(1, plan);
		# reset mcdu if it exists
		if (canvas_mcdu.myFpln[0] != nil) { canvas_mcdu.myFpln[0].scroll = 0; }
		if (canvas_mcdu.myFpln[1] != nil) { canvas_mcdu.myFpln[1].scroll = 0; }
		if (canvas_mcdu.myArrival[0] != nil) { canvas_mcdu.myArrival[0].reset(); }
		if (canvas_mcdu.myArrival[1] != nil) { canvas_mcdu.myArrival[1].reset(); }
		if (canvas_mcdu.myDeparture[0] != nil) { canvas_mcdu.myDeparture[0].reset(); }
		if (canvas_mcdu.myDeparture[1] != nil) { canvas_mcdu.myDeparture[1].reset(); }
		#todo if plan = 2, kill any tmpy flightplan
		me.flightPlanChanged(plan);
	},
	
	calculateTimeAltitudeOnSequence: func() {
		me._timeTemp = math.round(getprop("/sim/time/utc/minute") + (getprop("/sim/time/utc/second") / 60));
		if (me._timeTemp < 10) {
			me._timeTemp = "0" ~ me._timeTemp;
		}
		me.fromWptTime = getprop("/sim/time/utc/hour") ~ me._timeTemp;
		me._altTemp = getprop("/systems/navigation/adr/output/baro-alt-corrected-1-capt");
		
		if (me._altTemp > fmgc.FMGCInternal.transAlt) {
			me.fromWptAlt = "FL" ~ math.round(me._altTemp / 100);
		} else {
			if (me._altTemp > 0) {
				me.fromWptAlt = math.round(me._altTemp);
			} else {
				me.fromWptAlt = "M" ~ math.round(me._altTemp);
			}
		}
	},
	
	autoSequencing: func() {
		me.calculateTimeAltitudeOnSequence();
		
		# todo setlistener on sim/time/warp to recompute predictions
		
		# Advancing logic
		me.currentToWptIndexTemp = me.currentToWptIndex.getValue();
		if (me.currentToWptIndexTemp < 1) {
			me.currentToWptIndex.setValue(1);
		} else if (me.num[2].getValue() > 2) {
			for (var i = 0; i <= 2; i += 1) {
				if (i == 2) {
					me.flightplans[i].getWP(me.currentToWptIndexTemp - 1).hidden = 1;
				} elsif (me.temporaryFlag[i]) {
					me.flightplans[i].getWP(me.currentToWptIndexTemp - 1).hidden = 1;
				}
			}
		}
	},
	
	# for these two remember to call flightPlanChanged. We are assuming this is called from a function which will all flightPlanChanged itself.
	
	# addDiscontinuity - insert discontinuity at passed index
	# args: index, plan
	#	 index: index to add at
	#	 plan: plan to add to
	# Check if a discontinuity already exists either immediately before or at that index
	# If it does, don't add another one
	# Optional flag DEBUG_DISCONT to disable discontinuities totally
	addDiscontinuity: func(index, plan, force = 0) {
		if (DEBUG_DISCONT) { return; }
		if (force) {
			me.flightplans[plan].insertWP(createDiscontinuity(), index);
		}
		
		if (me.flightplans[plan].getWP(index) != nil) { # index is not nil
			if (me.flightplans[plan].getWP(index - 1) != nil) { # index -1 is also not nil
				if (me.flightplans[plan].getWP(index).wp_name != "DISCONTINUITY" and me.flightplans[plan].getWP(index - 1).wp_name != "DISCONTINUITY") {
					me.flightplans[plan].insertWP(createDiscontinuity(), index);
				}
			} else { # -1 is nil
				if (me.flightplans[plan].getWP(index).wp_name != "DISCONTINUITY") {
					me.flightplans[plan].insertWP(createDiscontinuity(), index);
				}
			}
		} elsif (me.flightplans[plan].getWP(index - 1) != nil) { # index is nil, -1 is not
			if (me.flightplans[plan].getWP(index - 1).wp_name != "DISCONTINUITY") {
				me.flightplans[plan].insertWP(createDiscontinuity(), index);
			}
		} else { # both are nil??
			print("Possible error in discontinuities!");
			me.flightplans[plan].insertWP(createDiscontinuity(), index);
		}
	},
	
	# insertTP - insert PPOS waypoint denoted "T-P" at specified index
	# args: n, index
	#	 n: flightplan to which the PPOS waypoint will be inserted
	#	 index: optional argument, defaults to 1, index which the waypoint will be at. 
	# Default to one, as direct to will insert TP, then create leg to DIRTO waypoint, then delete waypoint[0]
	
	insertTP: func(n, index = 1) {
		me.flightplans[n].insertWP(createWP(geo.aircraft_position(), "T-P"), index);
		fmgc.windController.insertWind(n, index, 0, "T-P");
	},
	
	insertPPOS: func(n, index = 0) {
		me.flightplans[n].insertWP(createWP(geo.aircraft_position(), "PPOS"), index);
		fmgc.windController.insertWind(n, index, 0, "PPOS");
	},
	
	insertDecel: func(n, pos, index) {
		me.flightplans[n].insertWP(createWP(pos, "(DECEL)"), index);
		me.flightplans[n].getWP(index).hidden = 1;
		fmgc.windController.insertWind(n, index, 0, "(DECEL)");
	},
	
	# childWPBearingDistance - return waypoint at bearing and distance from specified waypoint ghost
	# args: wpt, bearing, dist, name, typeStr
	#	 wpt: waypoint ghost
	#	 bearing: bearing of waypoint to be created from specified waypoint
	#	 distance: distance of waypoint to be created from specified waypoint, nautical miles
	#	 name: name of waypoint to be created
	#	 typeStr: optional argument to be passed to createWP, must be one of "sid", "star" "approach" "missed" or "pseudo"
	
	childWPBearingDistance: func(wpt, bearing, dist) {
		var coordinates = greatCircleMove(wpt.lat, wpt.lon, num(bearing), num(dist));
		return coordinates;
	},
	
	# insertNOSID - create default SID and add to flightplan
	# args: n: plan on which the SID will be created
	# The default SID is a leg from departure runway to a point 2.5 miles on the runway extended centreline
	# if NO SID has already been inserted, we will not insert another one.
	
	insertNOSID: func(n) {
		var wptStore = me.flightplans[n].getWP(0);
		if (wptStore.wp_type == "runway") {
			if (me.flightplans[n].getWP(1).id == "1500") { # check if we have NO SID already loaded
				me.deleteWP(1, n, 1);
			}
			
			# fudge the altitude since we cannot create a hdgtoAlt from nasal. Assume 600 feet per mile - 2.5 miles 
			me.flightplans[n].insertWP(createWP(me.childWPBearingDistance(wptStore, me.flightplans[n].departure_runway.heading, 2.5), "1500", "sid"), 1);
			fmgc.windController.insertWind(n, 1, 0, "1500");
		}
		me.flightPlanChanged(n);
	},
	
	# insertNOSTAR - create default STAR and add to flightplan
	# args: n: plan on which the STAR will be created
	# The default STAR is a leg from departure runway to a point 5 miles on the runway extended centreline
	# if NO STAR has already been inserted, we will not insert another one.
	
	insertNOSTAR: func(n) {
		var wptStore = me.flightplans[n].getWP(me.arrivalIndex[n]);
		if (wptStore.wp_type == "runway") {
			if (me.flightplans[n].getWP(me.arrivalIndex[n] - 1).id == "CF") { # check if we have NO STAR already loaded
				me.deleteWP(me.arrivalIndex[n] - 1, n, 1);
			}
			var hdg = me.flightplans[n].destination_runway.heading + 180;
			if (hdg > 360) {
				hdg = hdg - 360;
			}
			me.flightplans[n].insertWP(createWP(me.childWPBearingDistance(wptStore, hdg, 5), "CF", "star"), me.arrivalIndex[n]);
			fmgc.windController.insertWind(n, me.arrivalIndex[n], 0, "CF");
		}
		me.flightPlanChanged(n);
	},
	
	# directTo - create leg direct from present position to a specified waypoint
	# args: waypointGhost, plan
	#	 waypointGost: waypoint ghost of the waypoint
	#	 plan: plan on which the direct to leg will be created
	# We first insert a PPOS waypoint at index 1
	# We check if the flightplan already contains the waypoint passed to the function
	# If it exists, we delete intermediate waypoints
	# If it does not, we insert the waypoint at index 2 and add a discontinuity at index 3
	# In either case, we delete the current FROM waypoint, index 0, and call flightPlanChanged to recalculate
	# We attempt to get the distance from the aircraft current position to the chosen waypoint and update mcdu with it
	
	directTo: func(waypointGhost, plan) {
		if (me.flightplans[plan].indexOfWP(waypointGhost) == -1) {
			me.insertTP(plan, 1);
			
			# use createWP here as createWPFrom doesn't accept waypoints
			# createWPFrom worked before... but be sure!
			me.flightplans[plan].insertWP(createWP(waypointGhost, waypointGhost.id), 2);
			fmgc.windController.insertWind(plan, 2, 0, waypointGhost.id);
			me.addDiscontinuity(3, plan);
		} else {
			# we want to delete the intermediate waypoints up to but not including the waypoint. Leave index 0, we delete it later. 
			# example - waypoint dirto is index 5, we want to delete indexes 1 -> 4. 5 - 1 = 4.
			# so four individual deletions. Delete index 1 four times. 
			
			var timesToDelete = me.flightplans[plan].indexOfWP(waypointGhost);
			while (timesToDelete > 1) {
				me.deleteWP(1, plan, 1);
				timesToDelete -= 1; 
			}
			# Add TP afterwards, this is essential
			me.insertTP(plan, 1);
		}
		var curAircraftPosDirTo = geo.aircraft_position();
		canvas_mcdu.myDirTo[plan].updateDist(me.flightplans[plan].getWP(2).courseAndDistanceFrom(curAircraftPosDirTo)[1]);
		me.deleteWP(0, plan);
		me.flightPlanChanged(plan);
	},
	
	deleteWP: func(index, n, a = 0, s = 0) { # a = 1, means adding a waypoint via deleting intermediate. s = 1, means autosequencing
		var wp = me.flightplans[n].getWP(index);
		if (((s == 0 and left(wp.wp_name, 4) != FMGCdep.getValue() and left(wp.wp_name, 4) != FMGCarr.getValue()) or (s == 1)) and me.flightplans[n].getPlanSize() > 2) {
			if (me.flightplans[n].getWP(index).id != "DISCONTINUITY" and a == 0) { # if it is a discont, don't make a new one
				me.flightplans[n].deleteWP(index);
				fmgc.windController.deleteWind(n, index);
				if (me.flightplans[n].getWP(index) != nil and s == 0) {
					if (me.flightplans[n].getWP(index).id != "DISCONTINUITY") { # else, if the next one isn't a discont, add one
						me.addDiscontinuity(index, n);
					}
				}
			} else {
				me.flightplans[n].deleteWP(index);
				fmgc.windController.deleteWind(n, index);
			}
			me.flightPlanChanged(n);
			canvas_nd.A3XXRouteDriver.triggerSignal("fp-removed");
			return 2;
		} else {
			return 1;
		}
	},
	
	# deleteTillIndex - helper that deletes waypoints up to a passed waypoint already in flightplan
	# uses a while loop to delete a certain number of waypoints between passed index and 
	# index of waypoint alredy in flightplan
	deleteTillIndex: func(wpGhost, index, plan) {
		var numToDel = me.flightplans[plan].indexOfWP(wpGhost) - index;
		while (numToDel > 0) {
			me.deleteWP(index, plan, 1);
			numToDel -= 1;
		}
		return 2;
	},
	
	# createDuplicateNames - helper to spawn DUPLICATENAMES page
	# args: ghostContainer, index, flag, plan
	#	 ghostContainer: vector of fgPositioned ghosts
	#	 index: index
	#	 flag: is it a navaids DUPLICATENAMES page or not?
	#	 plan: plan
	#	 flagPBD: do we return back to PBD handler or to default waypoint handler?
	
	createDuplicateNames: func(ghostContainer, index, flag, plan, flagPBD = 0, bearing = -999, distance = -99) {
		if (canvas_mcdu.myDuplicate[plan] != nil) {
			canvas_mcdu.myDuplicate[plan].del();
		}
		canvas_mcdu.myDuplicate[plan] = nil;
		canvas_mcdu.myDuplicate[plan] = mcdu.duplicateNamesPage.new(ghostContainer, index, flag, plan, flagPBD, bearing, distance);
		setprop("MCDU[" ~ plan ~ "]/page", "DUPLICATENAMES");
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
			var indexToInsert = -1;
			if (override) {
				indexToInsert = overrideIndex;
			} else {
				indexToInsert = 0;
			}
			
			var indexPresent = me.flightplans[plan].indexOfWP(airport[indexToInsert]);
			if (me.flightplans[plan].indexOfWP(airport[indexToInsert]) == -1) {
				me.flightplans[plan].insertWP(createWPFrom(airport[indexToInsert]), index);
				fmgc.windController.insertWind(plan, index, 0, text);
				me.addDiscontinuity(index + 1, plan);
				me.flightPlanChanged(plan);
				return 2;
			} else {
				return me.deleteTillIndex(airport[indexToInsert], index, plan);
			}
		} elsif (size(airport) >= 1) {
			me.createDuplicateNames(airport, index, 0, plan);
			return 2;
		}
	},
	
	insertFix: func(text, index, plan, override = 0, overrideIndex = -1) {
		if (index == 0) {
			return 1;
		}
		
		var fix = findFixesByID(text);
		if (size(fix) == 0) {
			return 0;
		}
		
		if (size(fix) == 1 or override) {
			var indexToInsert = -1;
			if (override) {
				indexToInsert = overrideIndex;
			} else {
				indexToInsert = 0;
			}
			
			var indexPresent = me.flightplans[plan].indexOfWP(fix[indexToInsert]);
			if (me.flightplans[plan].indexOfWP(fix[indexToInsert]) == -1) {
				me.flightplans[plan].insertWP(createWPFrom(fix[indexToInsert]), index);
				fmgc.windController.insertWind(plan, index, 1, text);
				me.addDiscontinuity(index + 1, plan);
				me.flightPlanChanged(plan);
				return 2;
			} else {
				return me.deleteTillIndex(fix[indexToInsert], index, plan);
			}
		} elsif (size(fix) >= 1) {
			me.createDuplicateNames(fix, index, 0, plan);
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
			var indexToInsert = -1;
			if (override) {
				indexToInsert = overrideIndex;
			} else {
				indexToInsert = 0;
			}
			
			var indexPresent = me.flightplans[plan].indexOfWP(navaid[indexToInsert]);
			if (me.flightplans[plan].indexOfWP(navaid[indexToInsert]) == -1) {
				me.flightplans[plan].insertWP(createWPFrom(navaid[indexToInsert]), index);
				fmgc.windController.insertWind(plan, index, 1, text);
				me.addDiscontinuity(index + 1, plan);
				me.flightPlanChanged(plan);
				return 2;
			} else {
				return me.deleteTillIndex(navaid[indexToInsert], index, plan);
			}
		} elsif (size(navaid) >= 1) {
			me.createDuplicateNames(navaid, index, 1, plan);
			return 2;
		}
	},
	
	insertDBWP: func(wpGhost, index, plan) {
		if (index == 0 or wpGhost == nil) {
			return 1;
		}
		
		if (me.flightplans[plan].indexOfWP(wpGhost) == -1) {
			# use createWP here as createWPFrom doesn't accept waypoints
			me.flightplans[plan].insertWP(createWP(wpGhost, wpGhost.wp_name), index);
			fmgc.windController.insertWind(plan, index, 1, wpGhost.wp_name);
			me.addDiscontinuity(index + 1, plan);
			me.flightPlanChanged(plan);
			return 2;
		} else {
			return me.deleteTillIndex(wpGhost, index, plan);
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
		
		var waypoint = pilotWaypoint.new({lat: latDecimal, lon: lonDecimal}, "LL");
		var addDb = WaypointDatabase.addWP(waypoint);
		if (addDb != 2) {
			return addDb;
		}
		
		me.flightplans[plan].insertWP(waypoint.wpGhost, index);
		fmgc.windController.insertWind(plan, index, 1, "LL");
		me.addDiscontinuity(index + 1, plan);
		me.flightPlanChanged(plan);
		return 2;
	},
	
	# getWPforPBD - parse scratchpad text to find waypoint ghost for PBD
	# args: text, index, plan
	#	 text: scratchpad text
	#	 index: index at which waypoint will be inserted
	#	 plan: plan to which waypoint will be inserted
	# return: 
	#	 0: not in database
	#	 1: notAllowed
	#	 2: o.k.
	
	getWPforPBD: func(text, index, plan, override = 0, overrideIndex = -1) {
		if (index == 0) {
			return 1;
		}
		
		var textSplit = split("/", text);
		
		if (size(split(".", textSplit[2])) != 1 or size(textSplit[1]) < 2 or size(textSplit[1]) > 3) {
			return 1;
		}
		
		var wpGhost = nil;
		var wpGhostContainer = nil;
		var type = nil;
		
		if (size(textSplit[0]) == 5) {
			wpGhostContainer = findFixesByID(textSplit[0]);
			if (size(wpGhostContainer) == 0) {
				return 0;
			}
			type = "fix";
		} elsif (size(textSplit[0]) == 4) {
			wpGhostContainer = findAirportsByICAO(textSplit[0]);
			if (size(wpGhostContainer) == 0) {
				return 0;
			}
			type = "airport";
		} elsif (size(textSplit[0]) == 3 or size(textSplit[0]) == 2) {
			wpGhostContainer = findNavaidsByID(textSplit[0]);
			if (size(wpGhostContainer) == 0) {
				return 0;
			}
			type = "navaid";
		} else {
			return 1;
		}
		
		if (size(wpGhostContainer) == 1 or override) {
			if (!override) {
				wpGhost = wpGhostContainer[0];
			} else {
				wpGhost = wpGhostContainer[overrideIndex];
			}
		} else {
			if (type == "navaid") {
				me.createDuplicateNames(wpGhostContainer, index, 1, plan, 1, num(textSplit[1]), num(textSplit[2]));
			} else {
				me.createDuplicateNames(wpGhostContainer, index, 0, plan, 1, num(textSplit[1]), num(textSplit[2]));
			}
			return 2;
		}
		
		var localMagvar = magvar(wpGhost.lat, wpGhost.lon);
		return me.insertPlaceBearingDistance(wpGhost, textSplit[1] + localMagvar, textSplit[2], index, plan); # magnetic to true? I don't know. But this works!
	},
	
	getNavCount: func(plan) {
		var count = 0;
		for (var wpt = 0; wpt < me.flightplans[plan].getPlanSize(); wpt += 1) {
			if (me.flightplans[plan].getWP(wpt).wp_type == "navaid") {
				count += 1;
			}
		}
		return count;
	},
	
	getDepartureCount: func(plan) {
		var count = 0;
		for (var wpt = 0; wpt < me.flightplans[plan].getPlanSize(); wpt += 1) {
			if (me.flightplans[plan].getWP(wpt).wp_role == "sid") {
				count += 1;
			}
		}
		return count;
	},
	
	getArrivalCount: func(plan) {
		var count = 0;
		for (var wpt = 0; wpt < me.flightplans[plan].getPlanSize(); wpt += 1) {
			if (me.flightplans[plan].getWP(wpt).wp_role == "star" or me.flightplans[plan].getWP(wpt).wp_role == "approach" or me.flightplans[plan].getWP(wpt).wp_role == "missed") {
				count += 1;
			}
		}
		return count;
	},
	
	getPlanSizeNoDiscont: func(plan) {
		var count = 0;
		for (var wpt = 0; wpt < me.flightplans[plan].getPlanSize(); wpt += 1) {
			if (me.flightplans[plan].getWP(wpt).wp_name != "DISCONTINUITY") {
				count += 1;
			}
		}
		return count;
	},
	
	getIndexOfFirstDecel: func(plan) {
		for (var wpt = 0; wpt < me.flightplans[plan].getPlanSize(); wpt += 1) {
			if (me.flightplans[plan].getWP(wpt).wp_name == "(DECEL)") {
				return wpt;
			}
		}
		return -99;
	},
	
	calculateDecelPoint: func(n) {
		if (me.getPlanSizeNoDiscont(n) <= 1 or fmgc.FMGCInternal.decel) { 
			setprop("/instrumentation/nd/symbols/decel/show", 0); 
			return;			
		}
		
		me.indexDecel = me.getIndexOfFirstDecel(n);
		if (me.indexDecel != -99) {
			me.flightplans[n].deleteWP(me.indexDecel);
			fmgc.windController.deleteWind(n, me.indexDecel);
			me.flightPlanChanged(n,0);
		}
		
		me.indexDecel = 0;
		
		for (var wpt = 0; wpt < me.flightplans[n].getPlanSize(); wpt += 1) {
			if (me.flightplans[n].getWP(wpt).wp_role == "approach") {
				me.indexDecel = wpt;
				break;
			}
			if (wpt == me.flightplans[n].getPlanSize()) {
				me.indexDecel = me.arrivalIndex - 2;
				break;
			}
		}
		
		me.dist = (me.flightplans[n].getWP(me.arrivalIndex[n]).distance_along_route - me.flightplans[n].getWP(me.indexDecel).distance_along_route) + 7;
		
		me.decelPoint = me.flightplans[n].pathGeod(me.arrivalIndex[n], -me.dist);
		if (n == 2) {
			setprop("/instrumentation/nd/symbols/decel/latitude-deg", me.decelPoint.lat); 
			setprop("/instrumentation/nd/symbols/decel/longitude-deg", me.decelPoint.lon);
			setprop("/instrumentation/nd/symbols/decel/show", 1);
		}
		
		me.indexTemp = me.indexDecel;
		me.distTemp = 7;
		
		if (me.flightplans[n].getWP(me.indexTemp).leg_distance < 7) {
			while (me.distTemp > 0 and me.indexTemp > 0) {
				me.distTemp -= me.flightplans[n].getWP(me.indexTemp).leg_distance;
				me.indexTemp -= 1;
			}
			me.indexTemp += 1; 
		}

		# todo create waypoint, insert to flightplan, as non-sequence one (gets skipped in sequencing code
		#me.insertDecel(n,{lat: me.decelPoint.lat, lon: me.decelPoint.lon}, me.indexTemp);
		#me.flightPlanChanged(n,0);
	},
	
	# insertPlaceBearingDistance - insert PBD waypoint at specified index,
	# at some specified bearing, distance from a specified location
	# args: wp, index, plan
	#	 wpt: waypoint ghost
	#	 index: index to insert at in plan
	#	 plan: plan to insert to
	
	insertPlaceBearingDistance: func(wp, bearing, distance, index, plan) {
		var waypoint = pilotWaypoint.new(me.childWPBearingDistance(wp, bearing, distance), "PBD");
		var addDb = WaypointDatabase.addWP(waypoint);
		if (addDb != 2) {
			return addDb;
		}
		
		me.flightplans[plan].insertWP(waypoint.wpGhost, index);
		fmgc.windController.insertWind(plan, index, 0, "PBD");
		me.addDiscontinuity(index + 1, plan);
		me.flightPlanChanged(plan);
		return 2;
	},
	
	scratchpad: func(text, index, plan) { # return 0 not in database, 1 not allowed, 2 success, 3 = not allowed due to dir to, 4 = database full
		if (mcdu.dirToFlag) {
			return 3;
		}
		
		if (!me.temporaryFlag[plan]) {
			if (text == "CLR" and me.flightplans[2].getWP(index).wp_name == "DISCONTINUITY") {
				var thePlan = 2;
			} else {
				fmgc.flightPlanController.createTemporaryFlightPlan(plan);
				var thePlan = plan;
			}
		} else {
			var thePlan = plan;
		}
		
		# check waypoints database here
		var wpFromDB = WaypointDatabase.getWP(text);
		if (wpFromDB != nil) { 
			return me.insertDBWP(wpFromDB, index, thePlan);
		}
		
		if (size(split("/", text)) == 3) {
			return me.getWPforPBD(text, index, thePlan);
		} elsif (text == "CLR") {
			return me.deleteWP(index, thePlan, 0);
		} elsif (size(text) > 12) {
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
	
	flightPlanChanged: func(n, callDecel = 1) {
		me.updatePlans(1, callDecel);
		fmgc.windController.updatePlans();
		
		# push update to fuel
		if (getprop("/FMGC/internal/block-confirmed")) {
			setprop("/FMGC/internal/fuel-calculating", 0);
			setprop("/FMGC/internal/fuel-calculating", 1);
		}
		canvas_nd.A3XXRouteDriver.triggerSignal("fp-added");
	},
	
	updatePlans: func(runDecel = 0, callDecel = 1) {
		me.updateCurrentWaypoint();
		for (var n = 0; n <= 2; n += 1) {
			for (var wpt = 0; wpt < me.flightplans[n].getPlanSize(); wpt += 1) { # Iterate through the waypoints and update their data
				var waypointHashStore = me.flightplans[n].getWP(wpt);
				
				if (left(waypointHashStore.wp_name, 4) == FMGCarr.getValue() and wpt != 0) {
					if (me.arrivalIndex[n] != wpt) {
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
			me.updateMCDUDriver(n);
		
			if (runDecel and callDecel) {
				me.calculateDecelPoint(n);
			}
		}
	},
	
	updateCurrentWaypoint: func() {
		if (toFromSet.getBoolValue() and me.flightplans[2].departure != nil and me.flightplans[2].destination != nil) { # check if flightplan exists
			if (!me.active.getBoolValue()) {
				me.active.setValue(1);
			}
			
			if (me.currentToWptIndex.getValue() == -1) { return; }
			if (me.currentToWptIndex.getValue() < 1) { 
				me.currentToWptIndex.setValue(1); 
			} elsif (me.currentToWptIndex.getValue() > me.flightplans[2].getPlanSize()) {
				me.currentToWptIndex.setValue(me.flightplans[2].getPlanSize());
			}
		} else {
			if (me.active.getBoolValue()) {
				me.active.setValue(0);
			}
		}
	},
	
	updateMCDUDriver: func() {
		for (var i = 0; i <= 1; i += 1) {
			if (canvas_mcdu.myFpln[i] != nil) {
				canvas_mcdu.myFpln[i].updatePlan();
			}
			if (canvas_mcdu.myDirTo[i] != nil) {
				canvas_mcdu.myDirTo[i].updateFromFpln();
			}
		}
	},
};

var flightPlanTimer = maketimer(0.1, flightPlanController, flightPlanController.updatePlans);
