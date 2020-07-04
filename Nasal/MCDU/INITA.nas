# A3XX mCDU by Joshua Davidson (Octal450), Jonathan Redpath, and Matthew Maring (mattmaring)

# Copyright (c) 2020 Josh Davidson (Octal450)
# Copyright (c) 2020 Matthew Maring (mattmaring)

var initInputA = func(key, i) {
	var scratchpad = mcdu_scratchpad.scratchpads[i].scratchpad;
	if (key == "L2") {
		if (scratchpad == "CLR") {
			setprop("/FMGC/internal/alt-airport", "");
			setprop("/FMGC/internal/alt-set", 0);
			fmgc.windController.updatePlans();
			if (getprop("/FMGC/internal/block-confirmed")) {
				setprop("/FMGC/internal/fuel-calculating", 0);
				setprop("/FMGC/internal/fuel-calculating", 1);
			}
			mcdu_scratchpad.scratchpads[i].empty();
			fmgc.updateARPT();
		#} else if (scratchpad == "") {
			#setprop("/FMGC/internal/alt-selected", 1);
			#setprop("MCDU[" ~ i ~ "]/page", "ROUTESELECTION");
		} else if (getprop("/FMGC/internal/tofrom-set") == 1) {
			if (!fmgc.flightPlanController.temporaryFlag[i]) {
				var tfs = size(scratchpad);
				if (tfs == 4) {
					setprop("/FMGC/internal/alt-airport", scratchpad);
					setprop("/FMGC/internal/alt-set", 1);
					fmgc.windController.updatePlans();
					if (getprop("/FMGC/internal/block-confirmed")) {
						setprop("/FMGC/internal/fuel-calculating", 0);
						setprop("/FMGC/internal/fuel-calculating", 1);
					}
					mcdu_scratchpad.scratchpads[i].empty();
					fmgc.updateARPT();
					#setprop("/FMGC/internal/alt-selected", 1);
					#setprop("MCDU[" ~ i ~ "]/page", "ROUTESELECTION");
				} else {
					mcdu_message(i, "NOT ALLOWED");
				}
			} else {
				mcdu_message(i, "TMPY F-PLN EXISTS");
			}
		} else {
			mcdu_message(i, "NOT ALLOWED");
		}
	} else if (key == "L3") {
		if (scratchpad == "CLR") {
			setprop("MCDUC/flight-num", "");
			setprop("MCDUC/flight-num-set", 0);
			mcdu_scratchpad.scratchpads[i].empty();
		} else {
			var flts = size(scratchpad);
			if (flts >= 1 and flts <= 8) {
				setprop("MCDUC/flight-num", scratchpad);
				setprop("MCDUC/flight-num-set", 1);
				mcdu_scratchpad.scratchpads[i].empty();
			} else {
				mcdu_message(i, "NOT ALLOWED");
			}
		}
	} else if (key == "L5") {
		if (scratchpad == "CLR") {
			setprop("/FMGC/internal/cost-index", 0);
			setprop("/FMGC/internal/cost-index-set", 0);
			mcdu_scratchpad.scratchpads[i].empty();
		} else {
			var ci = int(scratchpad);
			var cis = size(scratchpad);
			if (cis >= 1 and cis <= 3) {
				if (ci != nil and ci >= 0 and ci <= 999) {
					setprop("/FMGC/internal/cost-index", ci);
					setprop("/FMGC/internal/cost-index-set", 1);
					mcdu_scratchpad.scratchpads[i].empty();
				} else {
					mcdu_message(i, "NOT ALLOWED");
				}
			} else {
				mcdu_message(i, "NOT ALLOWED");
			}
		}
	} else if (key == "L6") {
		if (scratchpad == "CLR") {
			setprop("/FMGC/internal/cruise-ft", 10000);
			setprop("/FMGC/internal/cruise-fl", 100);
			setprop("/FMGC/internal/cruise-lvl-set", 0);
			setprop("/FMGC/internal/cruise-temp", 15);
			setprop("/FMGC/internal/cruise-temp-set", 0);
			if (getprop("/FMGC/internal/block-confirmed")) {
				setprop("/FMGC/internal/fuel-calculating", 0);
				setprop("/FMGC/internal/fuel-calculating", 1);
			}
			mcdu_scratchpad.scratchpads[i].empty();	
		} else if (find("/", scratchpad) != -1) {
			var crztemp = split("/", scratchpad);
			if (find("FL", crztemp[0]) != -1) {
				var crz = int(substr(crztemp[0], 2));
				var crzs = size(substr(crztemp[0], 2));
			} else {
				var crz = int(crztemp[0]);
				var crzs = size(crztemp[0]);
			}
			var temp = int(crztemp[1]);
			var temps = size(crztemp[1]);
			if (crzs == 0 and temps >= 1 and temps <= 3 and temp != nil and getprop("/FMGC/internal/cruise-lvl-set")) {
				if (temp >= -99 and temp <= 99) {
					setprop("/FMGC/internal/cruise-temp", temp);
					if (getprop("/FMGC/internal/block-confirmed")) {
						setprop("/FMGC/internal/fuel-calculating", 0);
						setprop("/FMGC/internal/fuel-calculating", 1);
					}
					mcdu_scratchpad.scratchpads[i].empty();
				} else {
					mcdu_message(i, "NOT ALLOWED");
				}
			} else if (crzs >= 1 and crzs <= 3 and crz != nil and temps >= 1 and temps <= 3 and temp != nil) {
				if (crz > 0 and crz <= 390 and temp >= -99 and temp <= 99) {
					setprop("/FMGC/internal/cruise-ft", crz * 100);
					setprop("/FMGC/internal/cruise-fl", crz);
					setprop("/FMGC/internal/cruise-fl-prog", crz);
					setprop("/FMGC/internal/cruise-lvl-set", 1);
					setprop("/FMGC/internal/cruise-temp", temp);
					setprop("/FMGC/internal/cruise-temp-set", 1);
					if (getprop("/FMGC/internal/block-confirmed")) {
						setprop("/FMGC/internal/fuel-calculating", 0);
						setprop("/FMGC/internal/fuel-calculating", 1);
					}
					mcdu_scratchpad.scratchpads[i].empty();
				} else {
					mcdu_message(i, "NOT ALLOWED");
				}
			} else {
				mcdu_message(i, "NOT ALLOWED");
			}
		} else {
			if (find("FL", scratchpad) != -1) {
				var crz = int(substr(scratchpad, 2));
				var crzs = size(substr(scratchpad, 2));
			} else {
				var crz = int(scratchpad);
				var crzs = size(scratchpad);
			}
			if (crzs >= 1 and crzs <= 3 and crz != nil) {
				if (crz > 0 and crz <= 390) {
					setprop("/FMGC/internal/cruise-ft", crz * 100);
					setprop("/FMGC/internal/cruise-fl", crz);
					setprop("/FMGC/internal/cruise-fl-prog", crz);
					setprop("/FMGC/internal/cruise-lvl-set", 1);
					if (getprop("/FMGC/internal/block-confirmed")) {
						setprop("/FMGC/internal/fuel-calculating", 0);
						setprop("/FMGC/internal/fuel-calculating", 1);
					}
					mcdu_scratchpad.scratchpads[i].empty();
				} else {
					mcdu_message(i, "NOT ALLOWED");
				}
			} else {
				mcdu_message(i, "NOT ALLOWED");
			}
		}
	} else if (key == "R1") {
		if (scratchpad == "CLR") {
			setprop("/FMGC/internal/dep-arpt", "");
			setprop("/FMGC/internal/arr-arpt", "");
			setprop("/FMGC/internal/tofrom-set", 0);
			setprop("/FMGC/internal/align-ref-lat", 0);
			setprop("/FMGC/internal/align-ref-long", 0);
			setprop("/FMGC/internal/align-ref-lat-edit", 0);
			setprop("/FMGC/internal/align-ref-long-edit", 0);
			if (getprop("/FMGC/internal/block-confirmed")) {
				setprop("/FMGC/internal/fuel-calculating", 0);
				setprop("/FMGC/internal/fuel-calculating", 1);
			}
			fmgc.flightPlanController.reset(2);
			fmgc.windController.reset(2);
			fmgc.flightPlanController.init();
			fmgc.windController.init();
			mcdu_scratchpad.scratchpads[i].empty();
		#} else if (scratchpad == "") {
			#setprop("/FMGC/internal/alt-selected", 0);
			#setprop("MCDU[" ~ i ~ "]/page", "ROUTESELECTION");
		} else {
			if (!fmgc.flightPlanController.temporaryFlag[i]) {
				var tfs = size(scratchpad);
				if (tfs == 9 and find("/", scratchpad) != -1) {
					var fromto = split("/", scratchpad);
					var froms = size(fromto[0]);
					var tos = size(fromto[1]);
					if (froms == 4 and tos == 4) {
						#route
						setprop("/FMGC/internal/dep-arpt", fromto[0]);
						setprop("/FMGC/internal/arr-arpt", fromto[1]);
						setprop("/FMGC/internal/tofrom-set", 1);
						#scratchpad
						mcdu_scratchpad.scratchpads[i].empty();
						fmgc.flightPlanController.updateAirports(fromto[0], fromto[1], 2);
						setprop("/FMGC/internal/alt-selected", 0);
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
						#setprop("MCDU[" ~ i ~ "]/page", "ROUTESELECTION");
					} else {
						mcdu_message(i, "NOT ALLOWED");
					}
				} else {
					mcdu_message(i, "NOT ALLOWED");
				}
			} else {
				mcdu_message(i, "TMPY F-PLN EXISTS");
			}
		}
	} else if (key == "R3") {
		setprop("MCDU[" ~ i ~ "]/page", "IRSINIT");
	} else if (key == "R4") {
		if (canvas_mcdu.myCLBWIND[i] == nil) {
			canvas_mcdu.myCLBWIND[i] = windCLBPage.new(i);
		} else {
			canvas_mcdu.myCLBWIND[i].reload();
		}
		fmgc.windController.accessPage[i] = "INITA";
		setprop("MCDU[" ~ i ~ "]/page", "WINDCLB");
	} else if (key == "R5") {
		if (scratchpad == "CLR") {
			setprop("/FMGC/internal/tropo", 36090);
			setprop("/FMGC/internal/tropo-set", 0);
			mcdu_scratchpad.scratchpads[i].empty();
		} else {
			var tropo = size(scratchpad);
			if (tropo == 5 and scratchpad <= 99990) {
				setprop("FMGC/internal/tropo-set", 1);
				setprop("FMGC/internal/tropo", scratchpad);
				mcdu_scratchpad.scratchpads[i].empty();
			} else {
				mcdu_message(i, "NOT ALLOWED");
			}
		}
	} else if (key == "R6") {
		if (scratchpad == "CLR") {
			setprop("/FMGC/internal/gndtemp-set", 0);
			mcdu_scratchpad.scratchpads[i].empty();
		} else if (int(scratchpad) != nil and getprop("/FMGC/status/phase") == 0 and size(scratchpad) >= 1 and size(scratchpad) <= 3 and scratchpad >= -99 and scratchpad <= 99) {
			setprop("/FMGC/internal/gndtemp", scratchpad);
			setprop("/FMGC/internal/gndtemp-set", 1);
			mcdu_scratchpad.scratchpads[i].empty();
		} else {
			mcdu_message(i, "NOT ALLOWED");
		}
	}
}
