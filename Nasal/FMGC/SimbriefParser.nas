# A3XX Simbrief Parser
# Copyright (c) 2020 Jonathan Redpath (legoboyvdlp)

var LBS2KGS = 0.4535924;

var SimbriefParser = {
	node: nil,
	OFP: nil,
	store1: nil,
	store2: nil,
	inhibit: 0,
	fetch: func(username, i) {
		me.inhibit = 1;
		var stamp = systime();
		http.save("https://www.simbrief.com/api/xml.fetcher.php?username=" ~ username, getprop('/sim/fg-home') ~ "/Export/A320-family-simbrief.xml")
			.fail(func me.failure(i))
			.done(func {
				var errs = [];
				call(me.read, [(getprop('/sim/fg-home') ~ "/Export/A320-family-simbrief.xml"),i], SimbriefParser, {}, errs);
				if (size(errs) > 0) {
					debug.printerror(errs);
					me.failure(i);
				}
			});
	},
	failure: func(i) {
		mcdu.mcdu_message(i, "SIMBRIEF DOWNLOAD FAILED");
		me.inhibit = 0;
	},
	read: func(xml, i) {
		var data = io.readxml(xml);
		if (data != nil) {
			if (data.getChild("OFP") == nil) {
				print("XML file " ~ xml ~ " not a valid Simbrief file");
				me.failure(i);
				return;
			} else {
				me.node = data;
				if (me.parseOFP() == nil) {
					print("Failure to parse Simbrief OFP");
					me.failure(i);
				} else {
					mcdu.mcdu_message(i, "AOC ACT F-PLN UPLINK");
				}
			}
		} else {
			print("Error reading " ~ xml);
			me.failure(i);
		}
	},
	tryFindByCoord: func(coords, id, type) {
		var result = nil;
		if (type == "nav") {
			result = findNavaidsByID(id);
		} elsif (type == "fix") {
			result = findFixesByID(id);
		} else {
			return nil;
		}
		
		if (size(result) == 0) { return nil; }
		foreach (var test; result) {
			if (math.abs(test.lat - coords.lat()) < 0.01666666666 and math.abs(test.lon - coords.lon()) < 0.01666666666) {
				return test;
			}
		}
		return nil;
	},
	buildFlightplan: func() {
		# Flightplan stuff
		fmgc.flightPlanController.flightplans[3] = createFlightplan();
		fmgc.flightPlanController.flightplans[3].cleanPlan();
		
		# INITA
		var departureID = me.OFP.getNode("origin/icao_code").getValue();
		var departures = findAirportsByICAO(departureID);
		var destinationID = me.OFP.getNode("destination/icao_code").getValue();
		var destinations = findAirportsByICAO(destinationID);
		
		if (departures != nil and size(departures) != 0 and destinations != nil and size(destinations) != 0) {
			fmgc.flightPlanController.flightplans[3].departure = departures[0];
			fmgc.flightPlanController.flightplans[3].destination = destinations[0];
			fmgc.FMGCInternal.depApt = departureID;
			fmgc.FMGCInternal.arrApt = destinationID;
			
			atsu.ATISInstances[0].newStation(departureID);
			atsu.ATISInstances[1].newStation(destinationID);
			
			fmgc.FMGCInternal.toFromSet = 1;
			fmgc.FMGCNodes.toFromSet.setValue(1);
			
			fmgc.updateArptLatLon();
			fmgc.updateARPT();
		} else {
			me.cleanupInvalid();
			return nil;
		}
		
		var runwayStore = departures[0].runways[me.OFP.getNode("origin/plan_rwy").getValue()];
		if (runwayStore != nil) {
			fmgc.flightPlanController.flightplans[3].departure_runway = runwayStore;
		}
		
		runwayStore = destinations[0].runways[me.OFP.getNode("destination/plan_rwy").getValue()];
		if (runwayStore != nil) {
			fmgc.flightPlanController.flightplans[3].destination_runway = runwayStore;
		}
		
		var alternateID = me.OFP.getNode("alternate/icao_code").getValue();
		var alternates = findAirportsByICAO(alternateID);
		if (alternates != nil and size(alternates) != 0) {
			fmgc.FMGCInternal.altAirport = alternateID;
			atsu.ATISInstances[2].newStation(alternateID);
			fmgc.FMGCInternal.altAirportSet = 1;
		}
		
		var wps = [];
		var ofpNavlog = me.OFP.getNode("navlog");
		var ofpFixes = ofpNavlog.getChildren("fix");
		var ident = "";
		var coords = nil;
		var wp = nil;
		var _foundSID = 0;
		var _foundSTAR = 0;
		var _foundTOC = 0;
		var _foundTOD = 0;
		var _sid = nil;
		var _star = nil;
		
		foreach (var ofpFix; ofpFixes) {
			if (ofpFix.getNode("is_sid_star").getBoolValue()) {
				if (!_foundSID) {
					_sid = fmgc.flightPlanController.flightplans[3].departure.getSid(ofpFix.getNode("via_airway").getValue());
					if (_sid != nil) {
						_foundSID = 1;
					}
				}
			}
			
			if (ofpFix.getNode("is_sid_star").getBoolValue()) {
				if (!_foundSTAR) {
					_star = fmgc.flightPlanController.flightplans[3].destination.getStar(ofpFix.getNode("via_airway").getValue());
					if (_star != nil) {
						_foundSTAR = 1;
					}
				}
			}
			
			if (ofpFix.getNode("is_sid_star").getBoolValue() and _foundSID and _foundSTAR) {
				continue;
			} # todo what happens if you don't find one but find the other
			
			ident = ofpFix.getNode("ident").getValue();
			if (find(departureID, ident) != -1 or find(destinationID, ident) != -1) {
				continue;
			}
			
			if (ident == "TOC") {
				_foundTOC = 1;
				continue;
			}
			
			if (ident == "TOD") {
				_foundTOD = 1;
				continue;
			}
			
			coords = geo.Coord.new();
			coords.set_latlon(
				ofpFix.getNode("pos_lat").getValue(),
				ofpFix.getNode("pos_long").getValue());
				
			wp = me.tryFindByCoord(coords,ident,"fix");
			wp = me.tryFindByCoord(coords,ident,"nav");
			if (wp == nil) {
				wp = createWP(coords, ident);
			}
			
			append(wps, wp);
		}
		
		fmgc.flightPlanController.flightplans[3].insertWaypoints(wps, 1);
		if (_sid != nil) {
			fmgc.flightPlanController.flightplans[3].sid = _sid;
		}
		if (_star != nil) {
			fmgc.flightPlanController.flightplans[3].star = _star;
		}
		fmgc.flightPlanController.destroyTemporaryFlightPlan(3, 1);
		fmgc.windController.updatePlans();
		fmgc.updateRouteManagerAlt();
		
		return 1;
	},
	parseOFP: func() {
		me.OFP = me.node.getChild("OFP");
		if (me.buildFlightplan() == nil) {
			return nil;
		}
		fmgc.FMGCInternal.flightNum = (me.OFP.getNode("general/icao_airline").getValue() or "") ~ (me.OFP.getNode("general/flight_number").getValue() or "");
		fmgc.FMGCInternal.flightNumSet = 1;
		fmgc.FMGCInternal.costIndex = me.OFP.getNode("general/costindex").getValue();
		fmgc.FMGCInternal.costIndexSet = 1;
		fmgc.FMGCNodes.costIndex.setValue(fmgc.FMGCInternal.costIndex);
		fmgc.FMGCInternal.tropo = me.OFP.getNode("general/avg_tropopause").getValue();
		fmgc.FMGCInternal.tropoSet = 1;
		
		# Set cruise altitude
		fmgc.FMGCInternal.crzFt = me.OFP.getNode("general/initial_altitude").getValue();
		fmgc.FMGCInternal.crzFl = fmgc.FMGCInternal.crzFt / 100;
		fmgc.FMGCInternal.crzTemp = (((fmgc.FMGCInternal.crzFt / 1000) * -2) + 15) + me.OFP.getNode("general/avg_temp_dev").getValue();
		fmgc.FMGCInternal.crzProg = fmgc.FMGCInternal.crzFt / 100;
		mcdu.updateCrzLvlCallback();
		fmgc.FMGCInternal.crzTempSet = 1;
		fmgc.FMGCInternal.crzSet = 1;
		fmgc.altvert();
		
		var windComp = me.OFP.getNode("general/avg_wind_comp").getValue();
		if (num(windComp) >= 0) {
			fmgc.FMGCInternal.tripWind = "TL" ~ abs(windComp);
		} else {
			fmgc.FMGCInternal.tripWind = "HD" ~ abs(windComp);
		}
		fmgc.FMGCInternal.tripWindValue = abs(windComp);
		
		
		# INITB
		me.store1 = me.OFP.getChild("fuel");
		me.store2 = me.OFP.getChild("weights");
		if (me.OFP.getNode("params/units").getValue() == "lbs") {
			fmgc.FMGCInternal.taxiFuel = me.store1.getChild("taxi").getValue() / 1000;
			fmgc.FMGCInternal.taxiFuelSet = 1;
			fmgc.FMGCInternal.altFuel = me.store1.getChild("alternate_burn").getValue() / 1000;
			fmgc.FMGCInternal.altFuelSet = 1;
			fmgc.FMGCInternal.finalFuel = me.store1.getChild("reserve").getValue() / 1000;
			fmgc.FMGCInternal.finalFuelSet = 1;
			fmgc.FMGCInternal.rteRsv = me.store1.getChild("contingency").getValue() / 1000;
			fmgc.FMGCInternal.rteRsvSet = 1;
			if ((me.store1.getChild("contingency").getValue() / 1000) / num(fmgc.FMGCInternal.tripFuel) * 100 <= 15.0) {
				fmgc.FMGCInternal.rtePercent = (me.store1.getChild("contingency").getValue() / 1000) / num(fmgc.FMGCInternal.tripFuel) * 100;
			} else {
				fmgc.FMGCInternal.rtePercent = 15.0
			}
			fmgc.FMGCInternal.rtePercentSet = 0;
			fmgc.FMGCInternal.block = me.store1.getChild("plan_ramp").getValue() / 1000;
			fmgc.FMGCInternal.blockSet = 1;
			fmgc.FMGCInternal.zfw = me.store2.getChild("est_zfw").getValue() / 1000;
			fmgc.FMGCInternal.zfwSet = 1;
			fmgc.FMGCInternal.tow = fmgc.FMGCInternal.zfw + fmgc.FMGCInternal.block - fmgc.FMGCInternal.taxiFuel;
		} else {
			fmgc.FMGCInternal.taxiFuel = (me.store1.getChild("taxi").getValue() / LBS2KGS) / 1000;
			fmgc.FMGCInternal.taxiFuelSet = 1;
			fmgc.FMGCInternal.altFuel = (me.store1.getChild("alternate_burn").getValue() / LBS2KGS) / 1000;
			fmgc.FMGCInternal.altFuelSet = 1;
			fmgc.FMGCInternal.finalFuel = (me.store1.getChild("reserve").getValue() / LBS2KGS) / 1000;
			fmgc.FMGCInternal.finalFuelSet = 1;
			fmgc.FMGCInternal.rteRsv = (me.store1.getChild("contingency").getValue() / LBS2KGS) / 1000;
			fmgc.FMGCInternal.rteRsvSet = 1;
			if (((me.store1.getChild("contingency").getValue() / LBS2KGS) / 1000) / num(fmgc.FMGCInternal.tripFuel) * 100 <= 15.0) {
				fmgc.FMGCInternal.rtePercent = ((me.store1.getChild("contingency").getValue() / LBS2KGS) / 1000) / num(fmgc.FMGCInternal.tripFuel) * 100;
			} else {
				fmgc.FMGCInternal.rtePercent = 15.0
			}
			fmgc.FMGCInternal.rtePercentSet = 0;
			fmgc.FMGCInternal.block = (me.store1.getChild("plan_ramp").getValue() / LBS2KGS) / 1000;
			fmgc.FMGCInternal.blockSet = 1;
			fmgc.FMGCInternal.zfw = (me.store2.getChild("est_zfw").getValue() / LBS2KGS) / 1000;
			fmgc.FMGCInternal.zfwSet = 1;
			fmgc.FMGCInternal.tow = fmgc.FMGCInternal.zfw + fmgc.FMGCInternal.block - fmgc.FMGCInternal.taxiFuel;
		}
		fmgc.FMGCInternal.fuelRequest = 1;
		fmgc.FMGCInternal.fuelCalculating = 1;
		fmgc.fuelCalculating.setValue(1);
		fmgc.FMGCInternal.blockCalculating = 0;
		fmgc.blockCalculating.setValue(0);
		fmgc.FMGCInternal.blockConfirmed = 1;
		
		return 1;
	},
};