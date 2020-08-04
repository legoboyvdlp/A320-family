# A3XX Simbrief Parser
# Copyright (c) 2020 Jonathan Redpath (legoboyvdlp)

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
			.fail(func mcdu.mcdu_message(i, "SIMBRIEF FAILED"))
			.done(func me.read(getprop('/sim/fg-home') ~ "/Export/A320-family-simbrief.xml", i));
	},
	read: func(xml, i) {
		var data = io.readxml(xml);
		if (data != nil) {
			if (data.getChild("OFP") == nil) {
				print("XML file " ~ xml ~ " not a valid Simbrief file");
			} else {
				me.node = data;
				me.parseOFP();
				mcdu.mcdu_message(i, "AOC ACT F-PLN UPLINK");
			}
		} else {
			print("Error reading " ~ xml);
		}
	},
	parseOFP: func() {
		me.OFP = me.node.getChild("OFP");
		me.store1 = nil;
		me.store2 = nil;
		
		me.store1 = me.OFP.getChild("general");
		me.store2 = me.OFP.getChild("alternate");
		fmgc.FMGCInternal.flightNum = me.store1.getChild("icao_airline").getValue() ~ me.store1.getChild("flight_number").getValue();
		fmgc.FMGCInternal.flightNumSet = 1;
		fmgc.FMGCInternal.costIndex = me.store1.getChild("costindex").getValue();
		fmgc.FMGCInternal.costIndexSet = 1;
		fmgc.FMGCNodes.costIndex.setValue(fmgc.FMGCInternal.costIndex);
		fmgc.FMGCInternal.tropo = me.store1.getChild("avg_tropopause").getValue();
		fmgc.FMGCInternal.tropoSet = 1;
		fmgc.FMGCInternal.crzFt = me.store1.getChild("initial_altitude").getValue();
		fmgc.FMGCInternal.crzFl = me.store1.getChild("initial_altitude").getValue() / 100;
		fmgc.altvert();
		fmgc.FMGCInternal.crzSet = 1;
		mcdu.updateCrzLvlCallback();
		fmgc.FMGCInternal.crzTemp = (((me.store1.getChild("initial_altitude").getValue() / 1000) * -2) + 15) + me.store1.getChild("avg_temp_dev").getValue();
		fmgc.FMGCInternal.crzTempSet = 1;
		fmgc.FMGCInternal.crzProg = me.store1.getChild("initial_altitude").getValue() / 100;
		if (me.store1.getChild("avg_wind_comp").getValue() >= 0) {
			fmgc.FMGCInternal.tripWind = "TL" ~ me.store1.getChild("avg_wind_comp").getValue();
		} else {
			fmgc.FMGCInternal.tripWind = "HD" ~ me.store1.getChild("avg_wind_comp").getValue();
		}
		fmgc.FMGCInternal.tripWindValue = me.store1.getChild("avg_wind_comp").getValue();
		
		fmgc.FMGCInternal.altAirport = me.store2.getChild("icao_code").getValue();
		fmgc.FMGCInternal.altAirportSet = 1;
		
		# Flightplan stuff
		fmgc.flightPlanController.flightplans[3] = createFlightplan();
		
		# INITA
		me.store1 = me.OFP.getChild("origin");
		me.store2 = me.OFP.getChild("destination");
		
		fmgc.FMGCInternal.depApt = me.store1.getChild("icao_code").getValue();
		fmgc.FMGCInternal.arrApt = me.store2.getChild("icao_code").getValue();
		fmgc.FMGCInternal.toFromSet = 1;
		fmgc.FMGCNodes.toFromSet.setValue(1);
		fmgc.flightPlanController.flightplans[3].departure = airportinfo(fmgc.FMGCInternal.depApt);
		fmgc.flightPlanController.flightplans[3].destination = airportinfo(fmgc.FMGCInternal.arrApt);
		fmgc.FMGCInternal.altSelected = 0;
		fmgc.updateArptLatLon();
		fmgc.updateARPT();
		call(func() {
			fmgc.flightPlanController.flightplans[3].departure_runway = airportinfo(fmgc.FMGCInternal.depApt).runways[me.store1.getChild("plan_rwy").getValue()];
			fmgc.flightPlanController.flightplans[3].destination_runway = airportinfo(fmgc.FMGCInternal.arrApt).runways[me.store2.getChild("plan_rwy").getValue()];
		});
		
		me.store1 = me.OFP.getChild("navlog").getChildren();
		var firstIsSID = 0;
		var SIDID = "";
		if (me.store1[0].getChild("is_sid_star").getValue() == 1) {
			if (fmgc.flightPlanController.flightplans[3].departure.getSid(me.store1[0].getChild("via_airway").getValue()) != nil) {
				firstIsSID = 1;
				SIDID = me.store1[0].getChild("via_airway").getValue();
			}
		}
		var lastIsSTAR = 0;
		var STARID = "";
		if (me.store1[-1].getChild("is_sid_star").getValue() == 1) {
			if (fmgc.flightPlanController.flightplans[3].destination.getStar(me.store1[-1].getChild("via_airway").getValue()) != nil) {
				lastIsSTAR = 1;
				STARID = me.store1[-1].getChild("via_airway").getValue();
			}
		}
		
		var lastSIDIndex = -999;
		var firstSTARIndex = -999;
		var TOCinSIDflag = 0;
		var TODinSTARflag = 0;
		for (var i = 0; i < size(me.store1); i = i + 1) {
			if (firstIsSID) {
				if (me.store1[i].getChild("is_sid_star").getValue() == 0 or me.store1[i].getChild("via_airway").getValue() != SIDID) {
					lastSIDIndex = i - 1;
					break;
				}
			}
		}
			
		for (var i = lastSIDIndex == -999 ? 0 : lastSIDIndex; i < size(me.store1); i = i + 1) {
			if (STARID != "") {
				if (me.store1[i].getChild("is_sid_star").getValue() == 1 and me.store1[i].getChild("via_airway").getValue() == STARID) {
					firstSTARIndex = i;
					break;
				}
			}
		}
		
		var max = firstSTARIndex == -999 ? size(me.store1) - 1 : firstSTARIndex - 1;
		for (var i = lastSIDIndex == -999 ? 0 : lastSIDIndex + 2; i < max; i = i + 1) {
			if (me.store1[i].getChild("ident").getValue() == "TOC" or me.store1[i].getChild("ident").getValue() == "TOD") { continue; }
			var coord = geo.Coord.new();
			coord.set_latlon(me.store1[i].getChild("pos_lat").getValue(), me.store1[i].getChild("pos_long").getValue());
			var WP = createWP(coord, me.store1[i].getChild("ident").getValue());
			fmgc.flightPlanController.flightplans[3].appendWP(WP);
		}
		fmgc.flightPlanController.flightplans[3].sid = fmgc.flightPlanController.flightplans[3].departure.getSid(SIDID);
		fmgc.flightPlanController.flightplans[3].star = fmgc.flightPlanController.flightplans[3].destination.getStar(STARID);
		fmgc.flightPlanController.destroyTemporaryFlightPlan(3, 1);
		
		fmgc.windController.updatePlans();
		fmgc.updateRouteManagerAlt();
		
		
		# INITB
		me.store1 = me.OFP.getChild("fuel");
		me.store2 = me.OFP.getChild("weights");
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
		setprop("/FMGC/internal/fuel-request-set", 1);
		setprop("/FMGC/internal/fuel-calculating", 1);
		setprop("/FMGC/internal/block-calculating", 0);
		setprop("/FMGC/internal/block-confirmed", 1);
		
	},
};