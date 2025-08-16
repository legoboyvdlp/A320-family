# A3XX FMGC Flightplan Driver
# Copyright (c) 2025 Josh Davidson (Octal450) and Jonathan Redpath (legoboyvdlp)

var wpDep = nil;
var wpArr = nil;
var pos = nil;
var geoPosPrev = geo.Coord.new();
var currentLegCourseDist = nil;
var courseDistanceFrom = nil;
var sizeWP = nil;
var magTrueError = 0;
var storeCourse = nil;
var lastCstrFlown = 0;
var lastCstrCalculated = 0;
var lastIdealVsSave = 0;
var DEBUG_DISCONT = 0;
var geoWpt = nil;
var lastCstrWptIndexCalculated = 0;
var lastCstrWptIndexFlown = 0;

# Props.getNode
var magHDG = props.globals.getNode("/orientation/heading-magnetic-deg", 1);
var trueHDG = props.globals.getNode("/orientation/heading-deg", 1);

var flightPlanController = {
	flightplans: [createFlightplan(), createFlightplan(), createFlightplan(), nil],
	temporaryFlag: [0, 0],
	
	# These flags are only for the main flgiht-plan
	active: props.globals.initNode("/autopilot/route-manager/active", 0, "BOOL"),
	changed: props.globals.initNode("/autopilot/route-manager/flightplan-changed", 0, "BOOL"),
	
	currentToWpt: nil, # container for the current TO waypoint ghost
	currentToWptIndex: props.globals.initNode("/autopilot/route-manager/current-wp", 1, "INT"),
	currentToWptIndexTemp: 0,
	currentToWptIndexTemp2: 0,
	currentToWptID: props.globals.initNode("/autopilot/route-manager/wp[0]/id", "", "STRING"),
	courseToWpt: props.globals.initNode("/autopilot/route-manager/wp[0]/true-bearing-deg", 0, "DOUBLE"),
	courseMagToWpt: props.globals.initNode("/autopilot/route-manager/wp[0]/bearing-deg", 0, "DOUBLE"),
	distToWpt: props.globals.initNode("/autopilot/route-manager/wp[0]/dist", 0, "DOUBLE"),
	wptType: nil,
	wptTypeNoAdvanceDelete: 0,
	
	# Temporary flightplan will use flightplan[0] and flightplan[1]
	num: [props.globals.initNode("/FMGC/flightplan[0]/num", 0, "INT"), props.globals.initNode("/FMGC/flightplan[1]/num", 0, "INT"), props.globals.initNode("/autopilot/route-manager/route/num", 0, "INT")],
	arrivalIndex: [0, 0, 0],
	arrivalDist: props.globals.getNode("/autopilot/route-manager/distance-remaining-nm"),
	fromWptTime: nil,
	fromWptAlt: nil,
	_timeTemp: nil,
	_altTemp: nil,
	decelPoint: nil,
	lvlOffPoint: nil,
	
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
		
		me.decelPoint = nil;
		setprop("/instrumentation/nd/symbols/decel/show", 0);
		
		me.lvlOffPoint = nil;
		setprop("/autopilot/route-manager/vnav/ec/latitude-deg", 0); # necessary to prevent canvas glitching out because properties don't exist
		setprop("/autopilot/route-manager/vnav/ed/latitude-deg", 0); 
		setprop("/autopilot/route-manager/vnav/spdchng/latitude-deg", 0);
		setprop("/autopilot/route-manager/vnav/ip/latitude-deg", 0);
		setprop("/autopilot/route-manager/vnav/ec/longitude-deg", 0); 
		setprop("/autopilot/route-manager/vnav/ed/longitude-deg", 0);
		setprop("/autopilot/route-manager/vnav/spdchng/longitude-deg", 0);
		setprop("/autopilot/route-manager/vnav/ip/longitude-deg", 0);  
		setprop("/autopilot/route-manager/vnav/ec/show", 0); 
		setprop("/autopilot/route-manager/vnav/ed/show", 0); 
		setprop("/autopilot/route-manager/vnav/spdchng/show", 0); 
		setprop("/autopilot/route-manager/vnav/ip/show", 0); 
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
	
	oldCurrentWp: 0,
	lastSequencedCurrentWP: 0,
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
		
		me.oldCurrentWp = FPLN.currentWP.getValue();
		
		me.flightPlanChanged(n);
	},
	
	loadFlightPlan: func(path) {
		call(func {
			me.flightplans[3] = createFlightplan(path);
		}, nil, var err = []);	
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
		me.temporaryFlag[n] = 0;
		me.flightPlanChanged(2);
		me.resetFlightplan(n);
		if (canvas_mcdu.myDirTo[n] != nil) {
			canvas_mcdu.myDirTo[n].updateTmpy();
		}
		if (me.DirToIndex != nil) {
			me.currentToWptIndex.setValue(me.DirToIndex);
			me.DirToIndex = nil;
		}
		
		fmgc.windController.destroyTemporaryWinds(n, a);
		
		if (FPLN.currentWP.getValue() != me.oldCurrentWp) {
			FPLN.currentWP.setValue(me.oldCurrentWp);
		}
		
		me.flightPlanChanged(n);
	},
	
	updateAirports: func(dep, arr, plan) {
		me.resetFlightplan(plan);
		me.flightplans[plan].departure = airportinfo(dep);
		me.flightplans[plan].destination = airportinfo(arr);
		if (plan == 2) {
			if (me.temporaryFlag[0]) {	 me.destroyTemporaryFlightPlan(0, 0); }
			if (me.temporaryFlag[1]) {	 me.destroyTemporaryFlightPlan(1, 0); }
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
		if (!me.active.getBoolValue()) { return; }
		if (pts.Sim.pause.getBoolValue()) { return; }
		
		me.calculateTimeAltitudeOnSequence();
		
		# Advancing logic
		me.currentToWptIndexTemp = me.currentToWptIndex.getValue();
		# TODO - after sequencing discontinuity, FPLN should show PPOS then DISCONTINUITY
		# Clearing that discontinuity is not allowed, you must exit using DIRTO, or else using NAV ARM and overfly
		# TODO - triple click - confirm, is it only with DES disengage, or also with the NAV loss?
		# TODO - I think that it only goes to VS when in DES mode
		
		if (me.flightplans[2].getWP(me.currentToWptIndexTemp + 1).wp_type == "discontinuity" or me.flightplans[2].getWP(me.currentToWptIndexTemp + 1).wp_type == "vectors") {
			if (fmgc.Output.lat.getValue() == 1) {
				fmgc.Input.lat.setValue(3);
			}
			me.currentToWptIndex.setValue(me.currentToWptIndexTemp + 2);
			me.lastSequencedCurrentWP = me.currentToWptIndexTemp + 2;
		} else {
			me.currentToWptIndex.setValue(me.currentToWptIndexTemp + 1);
			me.lastSequencedCurrentWP = me.currentToWptIndexTemp + 1;
			
			if (me.num[2].getValue() > 2 and me.currentToWptIndexTemp >= 1) {
				for (var i = 0; i <= 2; i += 1) {
					if (i == 2 or me.temporaryFlag[i]) {
						me.flightplans[i].getWP(me.currentToWptIndexTemp - 1).hidden = 1;
					}
				}
			}
		}
	},
	
	# changeOverflyType - toggle flyby type of passed waypoint
	# args: index, plan, computer
	#   index: index to toggle
	#   plan: plan on which operation is performed
	# If the passed waypoint exists, toggle its flyover attribute
	changeOverFlyType: func(index, plan) {
		wp = me.flightplans[plan].getWP(index);
		if (wp == nil or wp.wp_name == "DISCONTINUITY" or wp.wp_name == "VECTORS") { return 1; };
		
		wp.fly_type = (wp.fly_type == "flyBy") ? "flyOver" : "flyBy";
		return 2;
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
			return;
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
			debug.dump("Error in discontinuities; won't try to add one");
		}
	},
	
	# insertTP - insert PPOS waypoint denoted "T-P" at specified index
	# args: n, index
	#	 n: flightplan to which the PPOS waypoint will be inserted
	#	 index: index which the waypoint will be at. 
	insertTP: func(n, index) {
		me.flightplans[n].insertWP(createWP(geo.aircraft_position(), "T-P"), index);
		fmgc.windController.insertWind(n, index, 0, "T-P");
	},
	
	insertPPOS: func(n, index = 0) {
		me.flightplans[n].insertWP(createWP(geo.aircraft_position(), "PPOS"), index);
		fmgc.windController.insertWind(n, index, 0, "PPOS");
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
			me.flightplans[n].insertWP(createWP(me.childWPBearingDistance(wptStore, me.flightplans[n].departure_runway.heading, 2.5 + (me.flightplans[n].departure_runway.length * M2NM)), "1500", "sid"), 1);
			me.flightplans[n].getWP(1).fly_type = "flyOver";
			me.flightplans[n].getWP(1).setAltitude(1500, "at");
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
			me.flightplans[n].getWP(me.arrivalIndex[n]).fly_type = "flyOver";
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
	
	DirToIndex: nil,
	directTo: func(waypointGhost, plan) {
		if (me.flightplans[plan].indexOfWP(waypointGhost) == -1) {
			me.insertTP(plan, me.currentToWptIndex.getValue());
			
			# use createWP here as createWPFrom doesn't accept waypoints
			# createWPFrom worked before... but be sure!
			me.flightplans[plan].insertWP(createWP(waypointGhost, waypointGhost.id), me.currentToWptIndex.getValue() + 1);
			fmgc.windController.insertWind(plan, me.currentToWptIndex.getValue() + 1, 0, waypointGhost.id);
			me.addDiscontinuity(me.currentToWptIndex.getValue() + 2, plan);
			me.DirToIndex = me.currentToWptIndex.getValue() + 1;
		} else {
			var indexWP = me.flightplans[plan].indexOfWP(waypointGhost);
			me.insertTP(plan, indexWP);
			me.deleteTillIndex(waypointGhost, me.currentToWptIndex.getValue(), plan, 1);
			
			indexWP = me.flightplans[plan].indexOfWP(waypointGhost);
			me.hideTillIndex(indexWP - 2, plan);
			me.DirToIndex = indexWP;
		}
		var curAircraftPosDirTo = geo.aircraft_position();
		canvas_mcdu.myDirTo[plan].updateDist(me.flightplans[plan].getWP(me.currentToWptIndex.getValue() + 1).courseAndDistanceFrom(curAircraftPosDirTo)[1]);
	},
	
	deleteWP: func(index, n, a = 0) { # a = 1, means adding a waypoint via deleting intermediate
		var wp = me.flightplans[n].getWP(index);
		if ((left(wp.wp_name, 4) != FMGCInternal.depApt and left(wp.wp_name, 4) != FMGCInternal.arrApt) and me.flightplans[n].getPlanSize() > 2) {
			if (wp.id != "DISCONTINUITY" and a == 0) { # if it is a discont, don't make a new one
				me.flightplans[n].deleteWP(index);
				fmgc.windController.deleteWind(n, index);
				if (me.flightplans[n].getWP(index) != nil) { # This refers to the next one after the one we deleted
					if (me.flightplans[n].getWP(index).id != "DISCONTINUITY") { # else, if the next one isn't a discont, add one
						me.addDiscontinuity(index, n);
					}
				}
			} else {
				if (wp.id == "DISCONTINUITY" and index > 0 and (me.flightplans[n].getWP(index - 1).id == "PPOS" or find("VECTORS", me.flightplans[n].getWP(index - 1).id) != -1)) {
					return 1;
				} else {
					me.flightplans[n].deleteWP(index);
					fmgc.windController.deleteWind(n, index);
				}
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
	deleteTillIndex: func(wpGhost, index, plan, offset = 0) {
		var numToDel = me.flightplans[plan].indexOfWP(wpGhost) - index - offset;
		while (numToDel > 0) {
			me.deleteWP(index, plan, 1);
			numToDel -= 1;
		}
		return 2;
	},
	
	hideTillIndex: func(index, plan) {
		var numToDel = index;
		while (numToDel >= 0) {
			me.flightplans[plan].getWP(index - numToDel).hidden = 1;
			numToDel -= 1;
		}
		return 2;
	},
	
	# createDuplicateNames - helper to spawn DUPLICATENAMES page
	# args: ghostContainer, index, flag, plan
	#    ghostContainer: vector of fgPositioned ghosts
	#    index: index
	#    flag: is it a navaids DUPLICATENAMES page or not?
	#    plan: plan
	#    flagPBD: do we return back to PBD handler or to default waypoint handler?
	#    flagPROG: do we return back to PROG handler or to default waypoint handler (only if flagPBD false)
	
	createDuplicateNames: func(ghostContainer, index, flag, plan, flagPBD = 0, bearing = -999, distance = -99, flagPROG = 0) {
		if (canvas_mcdu.myDuplicate[plan] != nil) {
			canvas_mcdu.myDuplicate[plan].del();
		}
		canvas_mcdu.myDuplicate[plan] = nil;
		canvas_mcdu.myDuplicate[plan] = mcdu.duplicateNamesPage.new(ghostContainer, index, flag, plan, flagPBD, bearing, distance, flagPROG);
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
			if (indexPresent == -1 or indexPresent > me.arrivalIndex[plan]) {
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
			if (indexPresent == -1 or indexPresent > me.arrivalIndex[plan]) {
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
			if (indexPresent == -1 or indexPresent > me.arrivalIndex[plan]) {
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
		
		var indexCurr = me.flightplans[plan].indexOfWP(wpGhost);
		if (indexCurr == -1 or indexCurr > me.arrivalIndex[plan]) {
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
				me.createDuplicateNames(wpGhostContainer, index, 1, plan, 1, num(textSplit[1]), num(textSplit[2]), 0);
			} else {
				me.createDuplicateNames(wpGhostContainer, index, 0, plan, 1, num(textSplit[1]), num(textSplit[2]), 0);
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
	
	calculateDecelPoint: func() {
		if (me.getPlanSizeNoDiscont(2) <= 1 or fmgc.FMGCInternal.decel) { 
			setprop("/instrumentation/nd/symbols/decel/show", 0); 
			return;			
		}
		
		me.indexDecel = 0;
		for (var wpt = 0; wpt < me.flightplans[2].getPlanSize(); wpt += 1) {
			if (me.flightplans[2].getWP(wpt).wp_role == "approach") {
				me.indexDecel = wpt;
				break;
			}
			if (wpt == me.flightplans[2].getPlanSize()) {
				me.indexDecel = me.arrivalIndex - 2;
				break;
			}
		}
		
		me.dist = me.flightplans[2].getWP(me.indexDecel).leg_distance - 7;
		if (me.dist < 0) {
			me.dist = 0.1;
		}
		me.decelPoint = me.flightplans[2].pathGeod(me.indexDecel - 1, me.dist);
		
		setprop("/instrumentation/nd/symbols/decel/latitude-deg", me.decelPoint.lat); 
		setprop("/instrumentation/nd/symbols/decel/longitude-deg", me.decelPoint.lon);
		setprop("/instrumentation/nd/symbols/decel/show", 1);
		
		me.indexTemp = me.indexDecel;
		me.distTemp = 7;
		
		if (me.flightplans[2].getWP(me.indexTemp).leg_distance < 7) {
			while (me.distTemp > 0 and me.indexTemp > 0) {
				me.distTemp -= me.flightplans[2].getWP(me.indexTemp).leg_distance;
				me.indexTemp -= 1;
			}
			me.indexTemp += 1; 
		}

		setprop("/instrumentation/nd/symbols/decel/index", me.indexTemp);
	},
	# Get the altitude additive to ten thousand to slow down
	getTenThousandSlowDownAlt: func() {
		spd = me.getExtrapolatedSpd(10000) + 20;
		result = ((100*spd/3)-(25000/3));
		if (result < 0) {
			result = 0;
		}
		return result;
	},
	# Get the next altitude constraint that is either at, or at or below
	getClbAltConst: func() {
		if (me.currentToWptIndex.getValue() < 0) {
			return;
		}
		for (var i = me.currentToWptIndex.getValue(); i < me.flightplans[2].getPlanSize(); i += 1) {
			if (me.flightplans[2].getWP(i).alt_cstr_type != "above" and me.flightplans[2].getWP(i).alt_cstr != nil and me.flightplans[2].getWP(i).alt_cstr != 0 and me.flightplans[2].getWP(i).wp_role == "sid") {
				# print("clb alt const is " ~ int(me.flightplans[2].getWP(i).alt_cstr));
				return [me.flightplans[2].getWP(i).alt_cstr,i];
			}
		}
		return [1000000000000000,0];
	},
	# Get the next altitude constraint that matters during DES mode
	getDesAltConst: func() {
		if (geoWpt != nil and int(me.getWptIndex(geoWpt)) < me.currentToWptIndex.getValue() and (me.flightplans[2].getWP(me.currentToWptIndex.getValue()).wp_role == "star" or me.flightplans[2].getWP(me.currentToWptIndex.getValue()).wp_role == "approach")) {
			return me.getGEOAltConst();
		} else {
			return me.getFirstAltConst();
		}
	},
	# Get wpt index by name
	getWptIndex: func(wp) {
		if (wp == nil) {
			return -1;
		}
		for (var i = me.currentToWptIndex.getValue(); i < me.flightplans[2].getPlanSize(); i += 1) {
			if (me.flightplans[2].getWP(i).id == wp.id) {
				return i;
			} else {
			# 	print("current id " ~ me.flightplans[2].getWP(i).id ~ " compared to " ~ wp.id);
			}
		}
		return -1;
	},
	# Get the first altitude const that the aircraft would descend 3 deg to
	getFirstAltConst: func() {
		if (me.currentToWptIndex.getValue() < 0 or fmgc.FMGCInternal.phase <= 2) {
			return [0, 0, 0, 0, 0];
		}
		# first loop is to find the first (at) or (at or below) altitude constraint
		altCstr = 0;
		spdCstr = nil;
		distanceToCstr = 0;
		cstrWptIndex = 0;
		spdDistance = 0;
		for (var i = me.currentToWptIndex.getValue(); i < me.flightplans[2].getPlanSize(); i += 1) {
			cstrType = me.flightplans[2].getWP(i).alt_cstr_type;
			if (i == me.currentToWptIndex.getValue()) {
				distanceToCstr += me.distToWpt.getValue();
			} else {
				distanceToCstr += me.flightplans[2].getWP(i).leg_distance;
			}
			if (cstrType == "above" or cstrType == "below") {
				continue;
			} elsif (me.flightplans[2].getWP(i).alt_cstr != nil and me.flightplans[2].getWP(i).alt_cstr != 0) {
				altCstr = me.flightplans[2].getWP(i).alt_cstr;
				geoWpt = me.flightplans[2].getWP(i);
				cstrWptIndex = i;
				if (me.flightplans[2].getWP(i).speed_cstr != 0 and me.flightplans[2].getWP(i).speed_cstr != nil) {
					spdCstr = me.flightplans[2].getWP(i).speed_cstr;
					spdDistance = abs(me.getDecelerationDistance(spdCstr,altCstr));
				}
				break;
			} elsif (me.flightplans[2].getWP(i).wp_type == "runway") {
				altCstr = geodinfo(me.flightplans[2].getWP(i).lat, me.flightplans[2].getWP(i).lon)[0] * 3.28084;
				print("runway elevation is " ~ altCstr);
				cstrWptIndex = i;
				geoWpt = me.flightplans[2].getWP(i);
				break;
			}
		}
		# second loop is to check all the above alt const before the one found by the first loop to see
		# if they would be violated by the 3 deg profile, if they are then that would be the new alt const
		# also set the abvaltconst to be displayed on the pfd just in case
		distanceToCstr2 = 0;
		distanceToDecelerate = 0;
		for (var i = me.currentToWptIndex.getValue(); i <= cstrWptIndex; i += 1) {
			if (i == me.currentToWptIndex.getValue()) {
				distanceToCstr2 += me.distToWpt.getValue();
			} else {
				distanceToCstr2 += me.flightplans[2].getWP(i).leg_distance;
			}
			extrapolatedAltCstr = me.getExtrapolatedThreeDegAltCstr(altCstr, (distanceToCstr - spdDistance - distanceToCstr2));
			print("first extrapolated alt cstr, extrapolated alt const" ~ extrapolatedAltCstr ~ "distance " ~ (distanceToCstr - spdDistance - distanceToCstr2));
			if (me.flightplans[2].getWP(i).alt_cstr_type == "above") {
				print("above and extrapolated alt const is " ~ extrapolatedAltCstr);
				if (me.flightplans[2].getWP(i).alt_cstr != 0 and me.flightplans[2].getWP(i).alt_cstr != nil) {
				} if (me.flightplans[2].getWP(i).alt_cstr > extrapolatedAltCstr) {
					altCstr = me.flightplans[2].getWP(i).alt_cstr;
					cstrWptIndex = int(i);
					geoWpt = me.flightplans[2].getWP(i);
					if (me.flightplans[2].getWP(i).speed_cstr != 0 and me.flightplans[2].getWP(i).speed_cstr != nil) {
						spdCstr = me.flightplans[2].getWP(i).speed_cstr;
						spdDistance = abs(me.getDecelerationDistance(spdCstr,altCstr));
					} else {
						spdDistance = 0;
					}
					break;
				} elsif (me.flightplans[2].getWP(i).speed_cstr != 0 and me.flightplans[2].getWP(i).speed_cstr != nil and distanceToDecelerate == 0 and me.flightplans[2].getWP(i).speed_cstr != lastConstraintSpeed) {
					spdCstr = me.flightplans[2].getWP(i).speed_cstr;
					distanceToDecelerate = distanceToCstr2 - (me.getDecelerationDistance(spdCstr, extrapolatedAltCstr)) * 3;
					print("distance to decel is " ~ distanceToDecelerate);
				}
			} elsif (me.flightplans[2].getWP(i).alt_cstr_type == "below") {
				print("below and extrapolated alt const is " ~ extrapolatedAltCstr);
				if (me.flightplans[2].getWP(i).alt_cstr < extrapolatedAltCstr) {
					altCstr = me.flightplans[2].getWP(i).alt_cstr;
					cstrWptIndex = int(i);
					geoWpt = me.flightplans[2].getWP(i);
					if (me.flightplans[2].getWP(i).speed_cstr != 0 and me.flightplans[2].getWP(i).speed_cstr != nil) {
						spdCstr = me.flightplans[2].getWP(i).speed_cstr;
						spdDistance = abs(me.getDecelerationDistance(spdCstr,altCstr));
					} else {
						spdDistance = 0;
					}
					break;
				} elsif (me.flightplans[2].getWP(i).speed_cstr != 0 and me.flightplans[2].getWP(i).speed_cstr != nil and distanceToDecelerate == 0 and me.flightplans[2].getWP(i).speed_cstr != lastConstraintSpeed) {
					spdCstr = me.flightplans[2].getWP(i).speed_cstr;
					distanceToDecelerate = distanceToCstr2 - (me.getDecelerationDistance(spdCstr, extrapolatedAltCstr)) * 3;
					print("distance to decel is " ~ distanceToDecelerate);
				}
			}
		}
		if (distanceToCstr > distanceToCstr2) {
			resultDistanceToCstr = distanceToCstr2;
		} else {
			resultDistanceToCstr = distanceToCstr;
		}
		lastCstrFlown = altCstr;
		lastCstrCalculated = altCstr;
		lastCstrWptIndexFlown = cstrWptIndex;
		lastCstrWptIndexCalculated = cstrWptIndex;
		resultDistanceToCstr -= spdDistance;
		resultDistanceToCstr -= fmgc.FPLN.turnDist;
		if (altCstr < 10000 and fmgc.Position.indicatedAltitudeFt.getValue() > 10000 and Velocities.indicatedAirspeedKt.getValue() > 250) {
			resultDistanceToCstr -= (Velocities.indicatedAirspeedKt.getValue() - 250) * 0.1
		}
		print("distance to decel is " ~ distanceToDecelerate);
		if (resultDistanceToCstr < 0.1) {
			resultDistanceToCstr = 0.1;
		}
		#in order: altcstr, distance to cstr, is GEO, idealvs, spddistance, decelerate,lastCstrFlown
		return [altCstr, resultDistanceToCstr, 0, 0, spdDistance, distanceToDecelerate, lastCstrFlown];
	},
	# Get the distance that it takes to slow down to the constraint speed on 3 deg profile
	getDecelerationDistance: func(speedCstr,altCstr) {
		speed = me.getExtrapolatedSpd(altCstr);
		if (speedCstr == nil or speedCstr == 0 or speedCstr >= speed) {
			return 0;
		}
		return ((speed - speedCstr)*0.1);
	},
	# Get the speed the aircraft would be at (in managed speed) at the alt cstr altitude
	getExtrapolatedSpd: func(altCstr) {
		CI = fmgc.FMGCNodes.costIndex.getValue();
		if (FMGCInternal.machSwitchover) {
			extrapolatedMach = 0.60625 + (0.000416875 * CI) + (0.00000795 * (altCstr - 20000)) + (0.00000000545 * (altCstr - 20000) * CI);
			extrapolatedSpd = fmgc.machToKts(extrapolatedMach);
			print("extrapolated speed is " ~ extrapolatedSpd);
			if (extrapolatedSpd < 250) {
				extrapolatedSpd = 250;
			} elsif (extrapolatedSpd > 345) {
				extrapolatedSpd = 345;
			} if (lastConstraintSpeed < extrapolatedSpd) {
				extrapolatedSpd = lastConstraintSpeed;
			}
			return extrapolatedSpd;
		} elsif (altCstr < 10000) {
			if (lastConstraintSpeed < 250) {
				return lastConstraintSpeed;
			}
			return 250;
		} else {
			extrapolatedSpd = (1.00 + (0.00158 * CI))*266;
			if (extrapolatedSpd < 250) {
				extrapolatedSpd = 250;
			} elsif (extrapolatedSpd > 345) {
				extrapolatedSpd = 345;
			} if (lastConstraintSpeed < extrapolatedSpd) {
				extrapolatedSpd = lastConstraintSpeed;
			}
			return extrapolatedSpd;
		}
	},

	# Get altitude constraint when in geometric desent path (after passing the initial constraint wpt and still in the STAR)
	getGEOAltConst: func() {
		#to find what is the last altitude const that the aircraft can descend to at a constant vs
		if (me.currentToWptIndex.getValue() < 0 or fmgc.FMGCInternal.phase <= 2) {
			return [0, 0, 0, 0, 0];
		}
		# first loop is to find the first (at) or (at or below) altitude constraint
		altCstr = 0;
		spdCstr = nil;
		distanceToCstr = 0;
		cstrWptIndex = 0;
		spdDistance = 0;
		distanceToCstr2 = 0;
		realDistanceToCstr = 0;
		realDistanceToDecelerate = 0;
		print("lastcstrwptindexflown + 1 is " ~ (lastCstrWptIndexFlown + 1) ~ " and currenttowptindex is " ~ me.currentToWptIndex.getValue());
		for (var i = (lastCstrWptIndexFlown+1); i < me.currentToWptIndex.getValue(); i += 1) {
			distanceToCstr += me.flightplans[2].getWP(i).leg_distance;
			distanceToCstr2 += me.flightplans[2].getWP(i).leg_distance;
			realDistanceToCstr -= me.flightplans[2].getWP(i).leg_distance;
			realDistanceToDecelerate -= me.flightplans[2].getWP(i).leg_distance;
		}
		print("first distancetocstr is " ~ distanceToCstr ~ " and distance to cstr2 is " ~ distanceToCstr2);
		for (var i = me.currentToWptIndex.getValue(); i < me.flightplans[2].getPlanSize(); i += 1) {
			cstrType = me.flightplans[2].getWP(i).alt_cstr_type;
			distanceToCstr += me.flightplans[2].getWP(i).leg_distance;
			if (cstrType == "above" or cstrType == "below") {
				continue;
			} elsif (me.flightplans[2].getWP(i).alt_cstr != nil and me.flightplans[2].getWP(i).alt_cstr != 0) {
				altCstr = me.flightplans[2].getWP(i).alt_cstr;
				cstrWpt = me.flightplans[2].getWP(i);
				cstrWptIndex = i;
				if (me.flightplans[2].getWP(i).speed_cstr != 0 and me.flightplans[2].getWP(i).speed_cstr != nil) {
					spdCstr = me.flightplans[2].getWP(i).speed_cstr;
					spdDistance = abs(me.getDecelerationDistance(spdCstr,altCstr));
				}
				break;
			} elsif (me.flightplans[2].getWP(i).wp_type == "runway") {
				altCstr = geodinfo(me.flightplans[2].getWP(i).lat, me.flightplans[2].getWP(i).lon)[0] * 3.28084;
				print("runway elevation is " ~ altCstr);
				cstrWptIndex = i;
				break;
			}
		}

		
		distanceToDecelerate = 0;
		for (var i = me.currentToWptIndex.getValue(); i <= cstrWptIndex; i += 1) {
			cstrType = me.flightplans[2].getWP(i).alt_cstr_type;
			distanceToCstr2 += me.flightplans[2].getWP(i).leg_distance;
			extrapolatedAltCstr = me.getExtrapolatedGEOAltCstr(altCstr, distanceToCstr2, (distanceToCstr - spdDistance));
			print("at extrapolated alt cstr is " ~ extrapolatedAltCstr ~ "altcstr is " ~ altCstr ~ " distance tocstr2 is " ~ distanceToCstr2 ~ "distance - spddistance is " ~ (distanceToCstr - spdDistance));
			if (cstrType == "above") {
				if (extrapolatedAltCstr < me.flightplans[2].getWP(i).alt_cstr) {
					altCstr = me.flightplans[2].getWP(i).alt_cstr;
					cstrWptIndex = int(i);
					if (me.flightplans[2].getWP(i).speed_cstr != 0 and me.flightplans[2].getWP(i).speed_cstr != nil) {
						spdCstr = me.flightplans[2].getWP(i).speed_cstr;
						spdDistance = abs(me.getDecelerationDistance(spdCstr,altCstr));
					} else {
						spdDistance = 0;
					}
					break;
				} elsif (me.flightplans[2].getWP(i).alt_cstr != 0 and me.flightplans[2].getWP(i).alt_cstr != nil and distanceToDecelerate == 0 and me.flightplans[2].getWP(i).speed_cstr != lastConstraintSpeed) {
					spdCstr = me.flightplans[2].getWP(i).speed_cstr;
					distanceToDecelerate = distanceToCstr2 - (me.getDecelerationDistance(spdCstr, extrapolatedAltCstr))*2;
					print("distance to decel is " ~ distanceToDecelerate);
					# break;
				}
			} elsif (cstrType == "below") {
				print("below extrapolated alt cstr is " ~ extrapolatedAltCstr ~ " and alt cstr is " ~ me.flightplans[2].getWP(i).alt_cstr);
				if (extrapolatedAltCstr > me.flightplans[2].getWP(i).alt_cstr) {
					altCstr = me.flightplans[2].getWP(i).alt_cstr;
					cstrWptIndex = int(i);
					if (me.flightplans[2].getWP(i).speed_cstr != 0 and me.flightplans[2].getWP(i).speed_cstr != nil) {
						spdCstr = me.flightplans[2].getWP(i).speed_cstr;
						spdDistance = abs(me.getDecelerationDistance(spdCstr,altCstr));
					} else {
						spdDistance = 0;
					}
					break;
				} elsif (me.flightplans[2].getWP(i).speed_cstr != 0 and me.flightplans[2].getWP(i).speed_cstr != nil and distanceToDecelerate == 0 and me.flightplans[2].getWP(i).speed_cstr != lastConstraintSpeed) {
					spdCstr = me.flightplans[2].getWP(i).speed_cstr;
					distanceToDecelerate = distanceToCstr2 - (me.getDecelerationDistance(spdCstr, extrapolatedAltCstr))*3;
					print("distance to decel is " ~ distanceToDecelerate);
					# break;
				}
			} elsif (me.flightplans[2].getWP(i).speed_cstr != 0 and me.flightplans[2].getWP(i).speed_cstr != nil and distanceToDecelerate == 0 and me.flightplans[2].getWP(i).speed_cstr != lastConstraintSpeed) {
				print("free spd point");
				spdCstr = me.flightplans[2].getWP(i).speed_cstr;
				distanceToDecelerate = distanceToCstr2 - (me.getDecelerationDistance(spdCstr, extrapolatedAltCstr))*3;
				print("distance to decel is " ~ distanceToDecelerate ~ "distance to cstr2 is " ~ distanceToCstr2);
				# break;
			}
		}
		if (distanceToCstr > distanceToCstr2) {
			resultDistanceToCstr = distanceToCstr2;
		} else {
			resultDistanceToCstr = distanceToCstr;
		}
		
		# minus the deceleration
		resultDistanceToCstr -= spdDistance;
		resultDistanceToCstr -= fmgc.FPLN.turnDist;
		if (altCstr < 10000 and fmgc.Position.indicatedAltitudeFt.getValue() > 10000 and Velocities.indicatedAirspeedKt.getValue() > 250) {
			resultDistanceToCstr -= (Velocities.indicatedAirspeedKt.getValue() - 250) * 0.1
		}
		realDistanceToCstr += resultDistanceToCstr - me.flightplans[2].getWP(me.currentToWptIndex.getValue()).leg_distance + me.distToWpt.getValue(); # for extrapolated and vdev info
		if (realDistanceToCstr < 0.1) {
			realDistanceToCstr = 0.1; # for extrapolated and vdev info
		}
		print("real distance to cstr is " ~ realDistanceToCstr);
		if (resultDistanceToCstr < 0.1) {
			resultDistanceToCstr = 0.1; # for extrapolated and vdev info
		}
		if (lastCstrWptIndexCalculated < cstrWptIndex) {
			print("updating idealvs and altcstr is " ~ altCstr ~ " and lastCstrCalculated is" ~ lastCstrCalculated ~ " and lastCstrFlown is " ~ lastCstrFlown);
			idealVs = me.getIdealVs(altCstr, resultDistanceToCstr);
			lastCstrFlown = lastCstrCalculated;
			lastCstrCalculated = altCstr;
			lastCstrWptIndexFlown = lastCstrWptIndexCalculated;
			lastCstrWptIndexCalculated = cstrWptIndex;
			print("lastcstrflown is " ~ lastCstrFlown ~ " and lastCstrCalculated is " ~ lastCstrCalculated);
			print("lastCstrWptIndexFlown is " ~ lastCstrWptIndexFlown ~ " and lastCstrWptIndexCalculated is " ~ lastCstrWptIndexCalculated);
		} else {
			idealVs = lastIdealVsSave;
		}
		realDistanceToDecelerate += distanceToDecelerate +  me.distToWpt.getValue() - me.flightplans[2].getWP(me.currentToWptIndex.getValue()).leg_distance;
		print("real distancetodecel is " ~ realDistanceToDecelerate);
		# print("distance to cstr is " ~ resultDistanceToCstr);
		lastIdealVsSave = idealVs; # for extrapolated and vdev info
		
		lastRealDistanceToCstr = realDistanceToCstr; # for extrapolated and vdev info
		return [altCstr, realDistanceToCstr, 1, idealVs, spdDistance, realDistanceToDecelerate, lastCstrFlown];
	},
	# Get the altitude that the aircraft would be at if it flies a 3 deg descent profile from the last altitude constraint wpt
	getExtrapolatedThreeDegAltCstr: func(lastAltCstr, distanceToCstr) {
		gs = pts.Velocities.groundspeedKt.getValue();
		extrapolatedAltCstr = (distanceToCstr)*318 + lastAltCstr;
		return extrapolatedAltCstr;
	},
	# Get the altitude that the aircraft would be at if it flies at the current vs and gs from the last altitude constraint wpt
	getExtrapolatedGEOAltCstr: func(lastAltCstr, distanceToCstr, totalDistanceToCstr) {
		# currentAlt = fmgc.Position.indicatedAltitudeFt.getValue();
		print("from extrapolated geo alt cstr lastcstr flown is " ~ lastCstrFlown);
		currentAlt = lastCstrFlown;
		return (currentAlt - ((currentAlt - lastAltCstr) * distanceToCstr / totalDistanceToCstr));
	},
	getIdealVs: func(altCstr, distanceToCstr) {
		gs = pts.Velocities.groundspeedKt.getValue();
		alt = lastCstrFlown;
		return (((alt - altCstr) * gs) / (distanceToCstr * 60));
	},
	# Get the next spd const that the aircraft would maintain until that point
	getNextClbSpdConst: func() {
		for (var i = me.currentToWptIndex.getValue(); i < me.flightplans[2].getPlanSize(); i += 1) {
			spdCstr = me.flightplans[2].getWP(i).speed_cstr;
			if (spdCstr != 0 and spdCstr != nil and me.flightplans[2].getWP(i).wp_role == "sid") {
				return [spdCstr,i];
			}
		}
		return [1000000000000000000,0];
	},
	# Calculate the TOD point, if not geometric descent path then it's a 3 deg descent path, if it is then it's the ideal vs
	# calculated from the getDesAltConst method.
	calculateTopOfDescent: func(isMng) {
		if (me.currentToWptIndex.getValue() < 0 or fmgc.FMGCInternal.phase <= 2) {
			return;
		}
		output = me.getDesAltConst();
		alt_cstr = output[0];
		distanceToCstr = output[1];
		is_geo = output[2];
		idealVs = output[3];
		deltaAltitude = alt_cstr - pts.Instrumentation.Altimeter.indicatedFt.getValue();
		if (is_geo == 0) {
			distLvl = abs(deltaAltitude / 318); # 318 is for 3 deg descent prof, so we get feet per NM
		} else {
			distLvl = abs((deltaAltitude * pts.Velocities.groundspeedKt.getValue()) / (idealVs * 60));
		}
		distToTOD = distanceToCstr - distLvl;
		print("in TOD calculations, alt_cstr is " ~ alt_cstr ~ "and distance to cstr is " ~ distanceToCstr ~ "distLvl is " ~ distLvl ~ "distToTOD is " ~ distToTOD);
		if (me.active.getBoolValue() and fmgc.Output.lat.getValue() == 1 and distToTOD >= 0 and deltaAltitude < 0) { # NAV
			me.TODPoint = me.flightplans[2].pathGeod(me.currentToWptIndex.getValue() - 1, me.flightplans[2].getWP(me.currentToWptIndex.getValue()).leg_distance - me.distToWpt.getValue() + distToTOD);
			
		} elsif (fmgc.Output.lat.getValue() == 0 and distToTOD >= 0) { # HDG TRK
			me._TODcoord = geo.aircraft_position();
			me._TODcoord.apply_course_distance(getprop("/orientation/track-magnetic-deg"), distToTOD * NM2M);
			me.TODPoint = {lat: me._TODcoord.lat(), lon: me._TODcoord.lon()};
		} else {
			if (getprop("/autopilot/route-manager/vnav/sd/show") == 1) {
				setprop("/autopilot/route-manager/vnav/sd/show", 0); 
			}
			if (distToTOD < 0) {
				fmgc.Internal.passTOD.setBoolValue(1);
			} else {
				fmgc.Internal.passTOD.setBoolValue(0);
			}
			me.TODPoint = nil;
		}
		
		if (deltaAltitude <= -100 and me.TODPoint != nil) {
			if (isMng) {
				setprop("/autopilot/route-manager/vnav/sd/vnav-armed", 1);
			} else {
				setprop("/autopilot/route-manager/vnav/sd/vnav-armed", 0);
			}
			setprop("/autopilot/route-manager/vnav/sd/latitude-deg", me.TODPoint.lat); 
			setprop("/autopilot/route-manager/vnav/sd/longitude-deg", me.TODPoint.lon);
			setprop("/autopilot/route-manager/vnav/sd/show", 1); 
		}

	},
	
	calculateLvlOffPoint: func(deltaAltitude, isMng) {
		me._verticalSpeedVal = fmgc.Internal.vs.getValue();
		if (me._verticalSpeedVal != 0) {
			me.distLvl = (deltaAltitude * pts.Velocities.groundspeedKt.getValue()) / (fmgc.Internal.vs.getValue() * 60);
		} else {
			me.distLvl = 999;
		}
		
		if (me.active.getBoolValue() and fmgc.Output.lat.getValue() == 1 and me.distLvl >= 0) { # NAV
			me.lvlOffPoint = me.flightplans[2].pathGeod(me.currentToWptIndex.getValue() - 1, me.flightplans[2].getWP(me.currentToWptIndex.getValue()).leg_distance - me.distToWpt.getValue() + me.distLvl);
		} elsif (fmgc.Output.lat.getValue() == 0 and me.distLvl >= 0) { # HDG TRK
			me._lvlOffCoord = geo.aircraft_position();
			me._lvlOffCoord.apply_course_distance(getprop("/orientation/track-magnetic-deg"), me.distLvl * NM2M);
			me.lvlOffPoint = {lat: me._lvlOffCoord.lat(), lon: me._lvlOffCoord.lon()};
		} else {
			setprop("/autopilot/route-manager/vnav/ec/show", 0); 
			setprop("/autopilot/route-manager/vnav/ed/show", 0); 
			me.lvlOffPoint = nil;
		}
		
		if (deltaAltitude >= 100 and me.lvlOffPoint != nil) {
			if (isMng) {
				setprop("/autopilot/route-manager/vnav/ec/alt-cstr", 1);
			} else {
				setprop("/autopilot/route-manager/vnav/ec/alt-cstr", 0);
			}
			setprop("/autopilot/route-manager/vnav/ec/latitude-deg", me.lvlOffPoint.lat); 
			setprop("/autopilot/route-manager/vnav/ec/longitude-deg", me.lvlOffPoint.lon);
			setprop("/autopilot/route-manager/vnav/ec/show", 1); 
			setprop("/autopilot/route-manager/vnav/ed/show", 0); 
		} elsif (deltaAltitude <= -100 and me.lvlOffPoint != nil) {
			if (isMng) {
				setprop("/autopilot/route-manager/vnav/ed/alt-cstr", 1);
			} else {
				setprop("/autopilot/route-manager/vnav/ed/alt-cstr", 0);
			}
			setprop("/autopilot/route-manager/vnav/ec/show", 0); 
			setprop("/autopilot/route-manager/vnav/ed/latitude-deg", me.lvlOffPoint.lat); 
			setprop("/autopilot/route-manager/vnav/ed/longitude-deg", me.lvlOffPoint.lon);
			setprop("/autopilot/route-manager/vnav/ed/show", 1);
		}
	},
	# Calculate the point where the aircraft would decelerate, if it's not geometric path then it's the same point as the ED,
	# if it is then it's the waypoint before.
	calculateSpdChangePoint: func() {
		if (Custom.Input.spdManaged.getBoolValue()) {
			if (fmgc.FMGCInternal.phase >= 3 and fmgc.FMGCInternal.phase != 6) {
				result = me.getDesAltConst();
				distanceToCstr = result[1];
				is_GEO = result[2];
				spdChangeDistance = result[4];
				distanceToDecelerate = result[5];
				if (distanceToDecelerate != result) {
					spdChangePoint = me.flightplans[2].pathGeod(me.currentToWptIndex.getValue() - 1, me.flightplans[2].getWP(me.currentToWptIndex.getValue()).leg_distance - me.distToWpt.getValue() + distanceToDecelerate);
					setprop("/autopilot/route-manager/vnav/spdchng/latitude-deg", spdChangePoint.lat); 
					setprop("/autopilot/route-manager/vnav/spdchng/longitude-deg",spdChangePoint.lon);
					setprop("/autopilot/route-manager/vnav/spdchng/show", 1);
				} elsif (spdChangeDistance != 0) {
					distanceToCstr = result[1];
					spdChangePoint = me.flightplans[2].pathGeod(me.currentToWptIndex.getValue() - 1, me.flightplans[2].getWP(me.currentToWptIndex.getValue()).leg_distance - me.distToWpt.getValue() + distanceToCstr);
					setprop("/autopilot/route-manager/vnav/spdchng/latitude-deg", spdChangePoint.lat); 
					setprop("/autopilot/route-manager/vnav/spdchng/longitude-deg",spdChangePoint.lon);
					setprop("/autopilot/route-manager/vnav/spdchng/show", 1);
				}
			} else {
				nextClbAltConstWptIndex = me.getNextClbSpdConst()[1];
				if (me.flightplans[2].getWP(nextClbAltConstWptIndex).speed_cstr != 0 and me.flightplans[2].getWP(nextClbAltConstWptIndex).speed_cstr != nil) {
					spdChangePoint = me.flightplans[2].pathGeod(nextClbAltConstWptIndex, 0); 
					setprop("/autopilot/route-manager/vnav/spdchng/latitude-deg", spdChangePoint.lat); 
					setprop("/autopilot/route-manager/vnav/spdchng/longitude-deg",spdChangePoint.lon);
					setprop("/autopilot/route-manager/vnav/spdchng/show", 1);
				}
			}
		}
		
	},
	# Calculate the point that at the current vertical speed would intercept the 3 deg descent profile. If it's on GEO descent path then don't display
	calculateDescentPathInterceptPoint: func() {
		if (me.currentToWptIndex.getValue() < 0 or fmgc.FMGCInternal.phase <= 2) {
			return;
		}
		result = me.getDesAltConst();
		if (result[2] == 1) {
			setprop("/autopilot/route-manager/vnav/ip/show", 0);
			return;
		}
		initialAlt = fmgc.Position.indicatedAltitudeFt.getValue();
		altCstr = result[0];
		distanceToCstr = result[1];
		gs = pts.Velocities.groundspeedKt.getValue();
		vs = -1*fmgc.Internal.vs.getValue();
		if (vs < 0) {
			vs = 0;
		}
		if (vs > -1100) {
			vs = 0;
		}
		distanceToIntercept = (gs*(altCstr - initialAlt) + (318*gs*distanceToCstr))/((318*gs) - (vs*60));
		DescentPathInterceptPoint = me.flightplans[2].pathGeod(me.currentToWptIndex.getValue() - 1, me.flightplans[2].getWP(me.currentToWptIndex.getValue()).leg_distance - me.distToWpt.getValue() + distanceToIntercept);
		setprop("/autopilot/route-manager/vnav/ip/latitude-deg", DescentPathInterceptPoint.lat); 
		setprop("/autopilot/route-manager/vnav/ip/longitude-deg",DescentPathInterceptPoint.lon);
		setprop("/autopilot/route-manager/vnav/ip/show", 1);
	},

	# Calculate the point of the SC symbol to be placed on the ND
	calculateClbPoint: func(isMng) {
		if (me.currentToWptIndex.getValue() < 0 or (fmgc.FMGCInternal.phase > 3 and fmgc.FMGCInternal.phase != 6)) {
			return;
		}
		wptIndex = me.getClbAltConst()[1];
		clbPoint = me.flightplans[2].pathGeod(wptIndex,0);
		if (isMng) {
			setprop("/autopilot/route-manager/vnav/sc/vnav-armed", 1);
		} else {
			setprop("/autopilot/route-manager/vnav/sc/vnav-armed", 0);
		}
		setprop("/autopilot/route-manager/vnav/sc/latitude-deg", clbPoint.lat); 
		setprop("/autopilot/route-manager/vnav/sc/longitude-deg",clbPoint.lon);
		setprop("/autopilot/route-manager/vnav/sc/show", 1);
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
		
		if (index == me.currentToWptIndex.getValue()) {
			return 1;
			# TODO - implement the PPOS - DISCONT feature
			# me.insertPPOS(thePlan, index - 1);
			# me.addDiscontinuity(index - 1, thePlan, 1);
		}
		
		if (!me.temporaryFlag[plan]) {
			if (text == "CLR" and me.flightplans[2].getWP(index).wp_name == "DISCONTINUITY") {
				if (me.flightplans[2].getPlanSize() == 3 and me.flightplans[2].departure_runway == nil and me.flightplans[2].destination_runway == nil and index == 1) {
					return 1;
				}
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
		} elsif (text == "@") {
			return me.changeOverFlyType(index, thePlan);
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
	
	flightPlanChanged: func(n) {
		me.updatePlans(1);
		fmgc.windController.updatePlans();
		
		# push update to fuel
		if (fmgc.FMGCInternal.blockConfirmed) {
			fmgc.FMGCInternal.fuelCalculating = 0;
			fmgc.fuelCalculating.setValue(0);
			fmgc.FMGCInternal.fuelCalculating = 1;
			fmgc.fuelCalculating.setValue(1);
		}

		if (n == 2) flightPlanController.changed.setBoolValue(1);

		canvas_nd.A3XXRouteDriver.triggerSignal("fp-added");
	},
	
	# runDecel - used to ensure that only flightplanchanged will update the decel point
	updatePlans: func(runDecel = 0) {
		if (fmgc.FMGCInternal.toFromSet and me.flightplans[2].departure != nil and me.flightplans[2].destination != nil) { # check if flightplan exists
			if (!me.active.getBoolValue()) {
				if (me.currentToWptIndex.getValue() < 1) {
					var errs = [];
					call(func {
						if (me.flightplans[2].getWP(1).id != "DISCONTINUITY") {
							me.currentToWptIndex.setValue(1);
						}
					}, nil, nil, nil, errs);
					if (size(errs) != 0) { debug.printerror(errs); }
				}
				me.active.setValue(1);
			}
		} elsif (me.active.getBoolValue()) {
			me.active.setValue(0);
		}
		
		if (me.active.getBoolValue() and me.currentToWptIndex.getValue() == -1) {
			me.currentToWptIndex.setValue(me.lastSequencedCurrentWP);
		}
		
		for (var n = 0; n <= 2; n += 1) {
			for (var wpt = 0; wpt < me.flightplans[n].getPlanSize(); wpt += 1) { # Iterate through the waypoints and update their data
				var waypointHashStore = me.flightplans[n].getWP(wpt);
				
				if (left(waypointHashStore.wp_name, 4) == fmgc.FMGCInternal.arrApt and wpt != 0) {
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
		}
			
		if (runDecel) {
			me.calculateDecelPoint();
		}
		isMng = Internal.altManaged.getBoolValue();
		me.calculateTopOfDescent(isMng);
		me.calculateSpdChangePoint();
		me.calculateDescentPathInterceptPoint();
		
		me.calculateClbPoint(isMng);
		var deltaAltitude = fmgc.Internal.alt.getValue() - pts.Instrumentation.Altimeter.indicatedFt.getValue();
		if (abs(deltaAltitude) >= 100) {
			me.calculateLvlOffPoint(deltaAltitude, isMng);
			
		} else {
			setprop("/autopilot/route-manager/vnav/ec/show", 0); 
			setprop("/autopilot/route-manager/vnav/ed/show", 0); 
		}
		
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