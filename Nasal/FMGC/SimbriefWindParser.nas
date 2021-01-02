# A3XX Simbrief Wind Parser
# Copyright (c) 2020 Matthew Maring (2020) and Jonathan Redpath (legoboyvdlp)

var LBS2KGS = 0.4535924;

var SimbriefWindParser = {
	node: nil,
	OFP: nil,
	store1: nil,
	store2: nil,
	inhibit: 0,
	computer: 2,
	fetch: func(username, i) {
		me.computer = i;
		var stamp = systime();
		http.save("https://www.simbrief.com/api/xml.fetcher.php?username=" ~ username, getprop('/sim/fg-home') ~ "/Export/A320-family-simbrief.xml")
			.fail(func me.failure(i))
			.done(func {
				var errs = [];
				call(me.read, [(getprop('/sim/fg-home') ~ "/Export/A320-family-simbrief.xml"),i], SimbriefWindParser, {}, errs);
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
					mcdu.mcdu_message(i, "WIND DATA UPLINK");
				}
			}
		} else {
			print("Error reading " ~ xml);
			me.failure(i);
		}
	},
	parseOFP: func() {
		me.OFP = me.node.getChild("OFP");
		var opfGeneral = me.OFP.getNode("general");
		var ofpNavlog = me.OFP.getNode("navlog");
		var ofpFixes = ofpNavlog.getChildren("fix");
		var _plan = me.computer;
		if (pts.Engines.Engine.state[0].getValue() != 3 and pts.Engines.Engine.state[1].getValue() != 3) {
			_plan = 2
		}
		foreach (var ofpFix; ofpFixes) {
			var ident = ofpFix.getNode("ident").getValue();
			var alt = ofpFix.getNode("altitude_feet").getValue();
			
			# standardization of names
			if (ident == "TOC") {
				ident = "(T/C)";
			} else if (ident == "TOD") {
				ident = "(T/D)";
			}
			ident = string.trim(ident, 0, func(c) c == `-`);
			
			# add wind data for each waypoint
			var wp_index = fmgc.flightPlanController.getIndexOf(_plan, ident);
			if (wp_index != -99) {
				fmgc.windController.winds[_plan][wp_index].wind1.heading = ofpFix.getNode("wind_dir").getValue();
				fmgc.windController.winds[_plan][wp_index].wind1.magnitude = ofpFix.getNode("wind_spd").getValue();
				fmgc.windController.winds[_plan][wp_index].wind1.altitude = "FL" ~ (ofpFix.getNode("altitude_feet").getValue() / 100);
				fmgc.windController.winds[_plan][wp_index].wind1.set = 1;
			}
			
			# to-do: calculate actual wind for each segment
			if (ident == "(T/C)" and fmgc.FMGCInternal.phase < 2) {
				fmgc.windController.clb_winds[_plan].wind1.heading = ofpFix.getNode("wind_dir").getValue();
				fmgc.windController.clb_winds[_plan].wind1.magnitude = ofpFix.getNode("wind_spd").getValue();
				fmgc.windController.clb_winds[_plan].wind1.altitude = "FL" ~ (alt / 100);
				fmgc.windController.clb_winds[_plan].wind1.set = 1;
			} else if (ident == "(T/D)" and fmgc.FMGCInternal.phase < 4) {
				fmgc.windController.des_winds[_plan].wind1.heading = ofpFix.getNode("wind_dir").getValue();
				fmgc.windController.des_winds[_plan].wind1.magnitude = ofpFix.getNode("wind_spd").getValue();
				fmgc.windController.des_winds[_plan].wind1.altitude = "FL" ~ (alt / 100);
				fmgc.windController.des_winds[_plan].wind1.set = 1;
			} else if (size(fmgc.windController.nav_indicies[_plan]) == 0 and fmgc.FMGCInternal.phase < 3) {
				fmgc.windController.crz_winds[_plan].wind1.heading = opfGeneral.getNode("avg_wind_dir").getValue();
				fmgc.windController.crz_winds[_plan].wind1.magnitude = opfGeneral.getNode("avg_wind_spd").getValue();
				fmgc.windController.crz_winds[_plan].wind1.altitude = "FL" ~ (opfGeneral.getNode("initial_altitude").getValue() / 100);
				fmgc.windController.crz_winds[_plan].wind1.set = 1;
			}
		}
		
		# to do: propogate winds
		# var _wind = nil;
# 		foreach (var wind; fmgc.windController.winds[_plan]) {
# 			if (_wind != nil and wind == nil) {
# 				wind.wind1.heading = _wind.wind1.heading;
# 				wind.wind1.magnitude = _wind.wind1.magnitude;
# 				wind.wind1.altitude = _wind.wind1.altitude;
# 				wind.wind1.set = _wind.wind1.set;
# 			}
# 			_wind = wind;
# 		}
		
		me.inhibit = 0;
		fmgc.windController.updatePlans();
		
		# push update to fuel
		if (fmgc.FMGCInternal.blockConfirmed) {
			fmgc.FMGCInternal.fuelCalculating = 0;
			fmgc.fuelCalculating.setValue(0);
			fmgc.FMGCInternal.fuelCalculating = 1;
			fmgc.fuelCalculating.setValue(1);
		}
		
		return 1;
	},
};