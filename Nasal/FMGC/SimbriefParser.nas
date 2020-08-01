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
		http.save("https://www.simbrief.com/api/xml.fetcher.php?username=" ~ username, getprop('/sim/fg-home') ~ "/Export/simbrief" ~ stamp ~ ".xml")
			.fail(func mcdu.mcdu_message(i, "SIMBRIEF FAILED"))
			.done(func me.read(getprop('/sim/fg-home') ~ "/Export/simbrief" ~ stamp ~ ".xml", i));
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
		
		
		fmgc.flightPlanController.destroyTemporaryFlightPlan(3, 1);
		
		fmgc.windController.updatePlans();
		fmgc.updateRouteManagerAlt();
		if (getprop("/FMGC/internal/block-confirmed")) {
			setprop("/FMGC/internal/fuel-calculating", 0);
			setprop("/FMGC/internal/fuel-calculating", 1);
		}
		
	},
};