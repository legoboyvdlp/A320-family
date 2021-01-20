# A3XX mCDU by Joshua Davidson (Octal450), Jonathan Redpath, and Matthew Maring (mattmaring)

# Copyright (c) 2020 Josh Davidson (Octal450)
# Copyright (c) 2020 Matthew Maring (mattmaring)

var initInputA = func(key, i) {
	var scratchpad = mcdu_scratchpad.scratchpads[i].scratchpad;
	if (key == "L1") { #clear coRoute if set
		if (scratchpad == "CLR") {
			if (fmgc.FMGCInternal.coRouteSet == 1) {
				fmgc.FMGCInternal.coRouteSet = 0;
				fmgc.FMGCInternal.coRoute = "";
				fmgc.FMGCInternal.depApt = "";
				fmgc.FMGCInternal.arrApt = "";
				fmgc.FMGCInternal.toFromSet = 0;
				fmgc.FMGCNodes.toFromSet.setValue(0);
				fmgc.windController.resetDesWinds();
				setprop("/FMGC/internal/align-ref-lat", 0);
				setprop("/FMGC/internal/align-ref-long", 0);
				setprop("/FMGC/internal/align-ref-lat-edit", 0);
				setprop("/FMGC/internal/align-ref-long-edit", 0);
				if (fmgc.FMGCInternal.blockConfirmed) {
					fmgc.FMGCInternal.fuelCalculating = 0;
					fmgc.fuelCalculating.setValue(0);
					fmgc.FMGCInternal.fuelCalculating = 1;
					fmgc.fuelCalculating.setValue(1);
				}
				fmgc.flightPlanController.reset(2);
				fmgc.flightPlanController.init();
				Simbrief.SimbriefParser.inhibit = 0;				
			}
			mcdu_scratchpad.scratchpads[i].empty();
		} else {
			var len = size(scratchpad);
			if (fmgc.FMGCInternal.coRouteSet == 1 or len != 10) {
				mcdu_message(i, "NOT ALLOWED");
			} else {
				mcdu_message(i, "NOT IN DATA BASE");  # fake message - TODO flightplan loader
			}
		}
	} else if (key == "L2") {
		if (scratchpad == "CLR") {
			fmgc.FMGCInternal.altAirport = "";
			fmgc.FMGCInternal.altAirportSet = 0;
			fmgc.windController.updatePlans();
			if (fmgc.FMGCInternal.blockConfirmed) {
				fmgc.FMGCInternal.fuelCalculating = 0;
				fmgc.fuelCalculating.setValue(0);
				fmgc.FMGCInternal.fuelCalculating = 1;
				fmgc.fuelCalculating.setValue(1);
			}
			mcdu_scratchpad.scratchpads[i].empty();
			fmgc.updateARPT();
		#} else if (scratchpad == "") {
			#fmgc.FMGCInternal.altSelected = 1;
			#setprop("MCDU[" ~ i ~ "]/page", "ROUTESELECTION");
		} else if (fmgc.FMGCInternal.toFromSet) {
			if (!fmgc.flightPlanController.temporaryFlag[i]) {
				var tfs = size(scratchpad);
				if (tfs == 4) {
					fmgc.FMGCInternal.altAirport = scratchpad;
					fmgc.FMGCInternal.altAirportSet = 1;
					atsu.ATISInstances[2].newStation(scratchpad);
					fmgc.windController.updatePlans();
					if (fmgc.FMGCInternal.blockConfirmed) {
						fmgc.FMGCInternal.fuelCalculating = 0;
						fmgc.fuelCalculating.setValue(0);
						fmgc.FMGCInternal.fuelCalculating = 1;
						fmgc.fuelCalculating.setValue(1);
					}
					mcdu_scratchpad.scratchpads[i].empty();
					fmgc.updateARPT();
					#fmgc.FMGCInternal.altSelected = 1;
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
			fmgc.FMGCInternal.flightNum = "";
			fmgc.FMGCInternal.flightNumSet = 0;
			mcdu_scratchpad.scratchpads[i].empty();
		} else {
			var flts = size(scratchpad);
			if (flts >= 1 and flts <= 8) {
				fmgc.FMGCInternal.flightNum = scratchpad;
				fmgc.FMGCInternal.flightNumSet = 1;
				mcdu_scratchpad.scratchpads[i].empty();
			} else {
				mcdu_message(i, "NOT ALLOWED");
			}
		}
	} else if (key == "L5") {
		if (scratchpad == "CLR") {
			fmgc.FMGCInternal.costIndex = 0;
			fmgc.FMGCInternal.costIndexSet = 0;
			fmgc.FMGCNodes.costIndex.setValue(0);
			mcdu_scratchpad.scratchpads[i].empty();
		} else {
			var ci = int(scratchpad);
			var cis = size(scratchpad);
			if (cis >= 1 and cis <= 3) {
				if (ci != nil and ci >= 0 and ci <= 999) {
					fmgc.FMGCInternal.costIndex = ci;
					fmgc.FMGCInternal.costIndexSet = 1;
					fmgc.FMGCNodes.costIndex.setValue(fmgc.FMGCInternal.costIndex);
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
			fmgc.FMGCInternal.crzFt = 10000;
			fmgc.FMGCInternal.crzFl = 100;
			fmgc.altvert();
			fmgc.updateRouteManagerAlt();
			fmgc.FMGCInternal.crzSet = 0;
			updateCrzLvlCallback();
			fmgc.FMGCInternal.crzTemp = 15;
			fmgc.FMGCInternal.crzTempSet = 0;
			if (fmgc.FMGCInternal.blockConfirmed) {
				fmgc.FMGCInternal.fuelCalculating = 0;
				fmgc.fuelCalculating.setValue(0);
				fmgc.FMGCInternal.fuelCalculating = 1;
				fmgc.fuelCalculating.setValue(1);
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
			if (crzs == 0 and temps >= 1 and temps <= 3 and temp != nil and fmgc.FMGCInternal.crzSet) {
				if (temp >= -99 and temp <= 99) {
					fmgc.FMGCInternal.crzTemp = temp;
					fmgc.FMGCInternal.crzTempSet = 1;
					if (fmgc.FMGCInternal.blockConfirmed) {
						fmgc.FMGCInternal.fuelCalculating = 0;
						fmgc.fuelCalculating.setValue(0);
						fmgc.FMGCInternal.fuelCalculating = 1;
						fmgc.fuelCalculating.setValue(1);
					}
					mcdu_scratchpad.scratchpads[i].empty();
				} else {
					mcdu_message(i, "NOT ALLOWED");
				}
			} else if (crzs >= 1 and crzs <= 3 and crz != nil and temps >= 1 and temps <= 3 and temp != nil) {
				if (crz > 0 and crz <= 390 and temp >= -99 and temp <= 99) {
					fmgc.FMGCInternal.crzFt = crz * 100;
					fmgc.FMGCInternal.crzFl = crz;
					fmgc.altvert();
					fmgc.updateRouteManagerAlt();
					fmgc.FMGCInternal.crzSet = 1;
					updateCrzLvlCallback();
					fmgc.FMGCInternal.crzTemp = temp;
					fmgc.FMGCInternal.crzTempSet = 1;
					fmgc.FMGCInternal.crzProg = crz;
					if (fmgc.FMGCInternal.blockConfirmed) {
						fmgc.FMGCInternal.fuelCalculating = 0;
						fmgc.fuelCalculating.setValue(0);
						fmgc.FMGCInternal.fuelCalculating = 1;
						fmgc.fuelCalculating.setValue(1);
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
					fmgc.FMGCInternal.crzFt = crz * 100;
					fmgc.FMGCInternal.crzFl = crz;
					fmgc.altvert();
					fmgc.updateRouteManagerAlt();
					fmgc.FMGCInternal.crzSet = 1;
					updateCrzLvlCallback();
					fmgc.FMGCInternal.crzProg = crz;
					if (fmgc.FMGCInternal.blockConfirmed) {
						fmgc.FMGCInternal.fuelCalculating = 0;
						fmgc.fuelCalculating.setValue(0);
						fmgc.FMGCInternal.fuelCalculating = 1;
						fmgc.fuelCalculating.setValue(1);
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
		if (fmgc.FMGCInternal.coRouteSet == 1) {
			mcdu_message(i, "NOT ALLOWED");
		}
		else if (scratchpad == "CLR") {
			fmgc.FMGCInternal.depApt = "";
			fmgc.FMGCInternal.arrApt = "";
			fmgc.FMGCInternal.toFromSet = 0;
			fmgc.FMGCNodes.toFromSet.setValue(0);
			fmgc.windController.resetDesWinds();
			setprop("/FMGC/internal/align-ref-lat", 0);
			setprop("/FMGC/internal/align-ref-long", 0);
			setprop("/FMGC/internal/align-ref-lat-edit", 0);
			setprop("/FMGC/internal/align-ref-long-edit", 0);
			if (fmgc.FMGCInternal.blockConfirmed) {
				fmgc.FMGCInternal.fuelCalculating = 0;
				fmgc.fuelCalculating.setValue(0);
				fmgc.FMGCInternal.fuelCalculating = 1;
				fmgc.fuelCalculating.setValue(1);
			}
			fmgc.flightPlanController.reset(2);
			fmgc.flightPlanController.init();
			Simbrief.SimbriefParser.inhibit = 0;
			mcdu_scratchpad.scratchpads[i].empty();
		#} else if (scratchpad == "") {
			#fmgc.FMGCInternal.altSelected = 0;
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
						if (fmgc.FMGCInternal.toFromSet == 1 and fmgc.FMGCInternal.arrApt != fromto[1]) {
							fmgc.windController.resetDesWinds();
						}
						fmgc.FMGCInternal.depApt = fromto[0];
						fmgc.FMGCInternal.arrApt = fromto[1];
						atsu.ATISInstances[0].newStation(fromto[0]);
						atsu.ATISInstances[1].newStation(fromto[1]);
						fmgc.FMGCInternal.toFromSet = 1;
						fmgc.FMGCNodes.toFromSet.setValue(1);
						#scratchpad
						mcdu_scratchpad.scratchpads[i].empty();
						fmgc.flightPlanController.updateAirports(fromto[0], fromto[1], 2);
						fmgc.FMGCInternal.altSelected = 0;
						fmgc.updateArptLatLon();
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
	} else if (key == "R2") {
		if (pts.Engines.Engine.state[0].getValue() != 3 and pts.Engines.Engine.state[1].getValue() != 3) {
			if (!ecam.vhf3_voice.active) {
				if (atsu.ATSU.working) {
					if (getprop("/FMGC/simbrief-username") == "") {
						mcdu.mcdu_message(i, "MISSING USERNAME")
					} elsif (!Simbrief.SimbriefParser.inhibit) {
						Simbrief.SimbriefParser.fetch(getprop("/FMGC/simbrief-username"), i);
					} else {
						mcdu_message(i, "NOT ALLOWED");
					}
				} else {
					mcdu_message(i, "NO COMM MSG NOT GEN");
				}
			} else {
				mcdu_message(i, "VHF3 VOICE MSG NOT GEN");
			}
		} else {
			mcdu_message(i, "NOT ALLOWED");
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
			fmgc.FMGCInternal.tropo = 36090;
			fmgc.FMGCInternal.tropoSet = 0;
			mcdu_scratchpad.scratchpads[i].empty();
		} else {
			var tropo = size(scratchpad);
			if (tropo == 5 and scratchpad <= 99990) {
				fmgc.FMGCInternal.tropo = scratchpad;
				fmgc.FMGCInternal.tropoSet = 1;
				mcdu_scratchpad.scratchpads[i].empty();
			} else {
				mcdu_message(i, "NOT ALLOWED");
			}
		}
	} else if (key == "R6") {
		if (scratchpad == "CLR") {
			fmgc.FMGCInternal.gndTempSet = 0;
			mcdu_scratchpad.scratchpads[i].empty();
		} else if (int(scratchpad) != nil and fmgc.FMGCInternal.phase == 0 and size(scratchpad) >= 1 and size(scratchpad) <= 3 and scratchpad >= -99 and scratchpad <= 99) {
			fmgc.FMGCInternal.gndTemp = scratchpad;
			fmgc.FMGCInternal.gndTempSet = 1;
			mcdu_scratchpad.scratchpads[i].empty();
		} else {
			mcdu_message(i, "NOT ALLOWED");
		}
	}
}
