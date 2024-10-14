# A3XX mCDU by Joshua Davidson (Octal450), Jonathan Redpath, and Matthew Maring (mattmaring)

# Copyright (c) 2024 Josh Davidson (Octal450)
# Copyright (c) 2020 Matthew Maring (mattmaring)

var resetFlightplan = func(i) {
	fmgc.FMGCInternal.depApt = "";
	fmgc.FMGCInternal.arrApt = "";
	fmgc.FMGCInternal.toFromSet = 0;
	fmgc.FMGCInternal.depAptElev = 0;
	fmgc.FMGCInternal.destAptElev = 0;
	fmgc.FMGCNodes.toFromSet.setValue(0);
	fmgc.windController.resetDesWinds();

	# clbreduc-ft and accel-agl-ft are set to arbitrary values they may not exist.
	# In case they do not exist, a takeoff with no departure airport and no accel set would never go from TO PHASE to CLB PHASE
	# unless manually changed.
	setprop("/FMGC/internal/accel-agl-ft", 1500);
	setprop("/fdm/jsbsim/fadec/clbreduc-ft", 1500);
	setprop("MCDUC/thracc-set", 0);
	setprop("MCDUC/acc-set-manual", 0);
	setprop("MCDUC/thrRed-set-manual", 0);

	setprop("/FMGC/internal/ga-accel-agl-ft", 1500);
	setprop("/fdm/jsbsim/fadec/ga-clbreduc-ft", 1500);
	setprop("MCDUC/ga-acc-set-manual", 0);
	setprop("MCDUC/ga-thrRed-set-manual", 0);

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
	fmgc.updateARPT();
	mcdu_scratchpad.scratchpads[i].empty();
}

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
				if (size(scratchpad) == 4) {
					if (size(findAirportsByICAO(scratchpad)) > 0) {
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
					} else {
						mcdu_message(i, "NOT IN DATA BASE");
					}
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
				var crz = substr(crztemp[0], 2);
				var crzs = size(substr(crztemp[0], 2));
			} else {
				var crz = crztemp[0];
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
			} else if (find(".", crz) == -1 and crzs >= 1 and crzs <= 3 and crz != nil and temps >= 1 and temps <= 3 and temp != nil) {
				if (crz > 0 and crz <= 390 and temp >= -99 and temp <= 99) {
					fmgc.FMGCInternal.crzFt = int(crz) * 100;
					fmgc.FMGCInternal.crzFl = int(crz);
					fmgc.altvert();
					fmgc.updateRouteManagerAlt();
					fmgc.FMGCInternal.crzSet = 1;
					updateCrzLvlCallback();
					fmgc.FMGCInternal.crzTemp = temp;
					fmgc.FMGCInternal.crzTempSet = 1;
					fmgc.FMGCInternal.crzProg = int(crz);
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
				var crz = substr(scratchpad, 2);
				var crzs = size(substr(scratchpad, 2));
			} else {
				var crz = scratchpad;
				var crzs = size(scratchpad);
			}
			if (find(".", crz) == -1 and crzs >= 1 and crzs <= 3 and crz != nil) {
				if (crz > 0 and crz <= 390) {
					fmgc.FMGCInternal.crzFt = int(crz) * 100;
					fmgc.FMGCInternal.crzFl = int(crz);
					fmgc.altvert();
					fmgc.updateRouteManagerAlt();
					fmgc.FMGCInternal.crzSet = 1;
					updateCrzLvlCallback();
					fmgc.FMGCInternal.crzProg = int(crz);
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
			resetFlightplan(i);
		#} else if (scratchpad == "") {
			#fmgc.FMGCInternal.altSelected = 0;
			#setprop("MCDU[" ~ i ~ "]/page", "ROUTESELECTION");
		} else {			
			if (!fmgc.flightPlanController.temporaryFlag[i]) {
				if (size(scratchpad) == 9 and find("/", scratchpad) != -1) {
					var fromto = split("/", scratchpad);
					if (size(fromto[0]) == 4 and size(fromto[1]) == 4) {
						if (size(findAirportsByICAO(fromto[0])) > 0 and size(findAirportsByICAO(fromto[1])) > 0) {
							resetFlightplan(i);
							fmgc.FMGCInternal.depApt = fromto[0];
							fmgc.FMGCInternal.arrApt = fromto[1];
							atsu.ATISInstances[0].newStation(fromto[0]);
							atsu.ATISInstances[1].newStation(fromto[1]);
							fmgc.FMGCInternal.toFromSet = 1;
							fmgc.FMGCNodes.toFromSet.setValue(1);
							mcdu_scratchpad.scratchpads[i].empty();
							fmgc.FMGCInternal.depAptElev = math.round(airportinfo(fromto[0]).elevation * M2FT, 10);
							fmgc.FMGCInternal.destAptElev = math.round(airportinfo(fromto[1]).elevation * M2FT, 10);

							if (getprop("/options/company-options/default-thrRed-agl")) {
								fmgc.FMGCInternal.thrRedAlt = getprop("/options/company-options/default-thrRed-agl") + fmgc.FMGCInternal.depAptElev;
								fmgc.FMGCInternal.gaThrRedAlt = getprop("/options/company-options/default-ga-thrRed-agl") + fmgc.FMGCInternal.destAptElev;
							} else {
								fmgc.FMGCInternal.thrRedAlt = 400 + fmgc.FMGCInternal.depAptElev; # todo: minimum thrRed agl if no company option
								fmgc.FMGCInternal.gaThrRedAlt = 1500 + fmgc.FMGCInternal.destAptElev; # as per FCOM 12-22_20-50-10-MCDU - Page Description - FMS2 Thales - PERF Page
							}

							if (getprop("/options/company-options/default-accel-agl")) {
								fmgc.FMGCInternal.accelAlt = getprop("/options/company-options/default-accel-agl") + fmgc.FMGCInternal.depAptElev;
								fmgc.FMGCInternal.gaAccelAlt = getprop("/options/company-options/default-ga-accel-agl") + fmgc.FMGCInternal.destAptElev;
								if (fmgc.FMGCInternal.gaAccelAlt < fmgc.FMGCInternal.gaThrRedAlt){
									fmgc.FMGCInternal.gaThrRedAlt =  fmgc.FMGCInternal.gaAccelAlt;
								}
							} else {
								fmgc.FMGCInternal.accelAlt = 400 + fmgc.FMGCInternal.depAptElev; # todo: minimum accel agl if no company option
								fmgc.FMGCInternal.gaAccelAlt = 1500 + fmgc.FMGCInternal.destAptElev; # as per FCOM 12-22_20-50-10-MCDU - Page Description - FMS2 Thales - PERF Page
							}

							setprop("/FMGC/internal/accel-agl-ft", fmgc.FMGCInternal.accelAlt);
							setprop("/fdm/jsbsim/fadec/clbreduc-ft", fmgc.FMGCInternal.thrRedAlt);
							setprop("MCDUC/thracc-set", 0);
							setprop("MCDUC/acc-set-manual", 0);
							setprop("MCDUC/thrRed-set-manual", 0);

							setprop("/FMGC/internal/ga-accel-agl-ft", fmgc.FMGCInternal.gaAccelAlt);
							setprop("/fdm/jsbsim/fadec/ga-clbreduc-ft", fmgc.FMGCInternal.gaThrRedAlt);
							setprop("MCDUC/ga-acc-set-manual", 0);
							setprop("MCDUC/ga-thrRed-set-manual", 0);

							fmgc.flightPlanController.updateAirports(fromto[0], fromto[1], 2);
							fmgc.FMGCInternal.altSelected = 0;
							fmgc.updateARPT();
							fmgc.updateArptLatLon();
						} else {
							mcdu_message(i, "NOT IN DATA BASE");
						}
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
		if (pts.Engines.Engine.state[0].getValue() != 3 and pts.Engines.Engine.state[1].getValue() != 3 and fmgc.FMGCInternal.toFromSet == 0) {
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
			if (fmgc.FMGCInternal.tropoSet) {
				fmgc.FMGCInternal.tropo = 36090;
				fmgc.FMGCInternal.tropoSet = 0;
				mcdu_scratchpad.scratchpads[i].empty();
			} else {
				mcdu_message(i, "NOT ALLOWED");
			}
		} else {
			if (num(scratchpad) == nil) {
				if (find("FL", scratchpad) != -1) {
					var tropos = size(split("FL", scratchpad)[1]);
					var tropon = num(split("FL", scratchpad)[1]);
					if (tropon != nil) {
						if ((tropos == 2 or tropos == 3) and tropon >= 10 and tropon <= 999) {
							fmgc.FMGCInternal.tropo = tropon * 100;
							fmgc.FMGCInternal.tropoSet = 1;
							mcdu_scratchpad.scratchpads[i].empty();
						} else {
							mcdu_message(i, "ENTRY OUT OF RANGE");
						}
					} else {
						mcdu_message(i, "NOT ALLOWED");
					}
				} else {
					mcdu_message(i, "NOT ALLOWED");
				}
			} else {
				var tropos = size(scratchpad);
				var tropon = num(scratchpad);
				if ((tropos == 4 or tropos == 5) and tropon >= 1000 and tropon <= 99990) {
					fmgc.FMGCInternal.tropo = math.round(tropon, 10);
					fmgc.FMGCInternal.tropoSet = 1;
					mcdu_scratchpad.scratchpads[i].empty();
				} else if ((tropos == 2 or tropos == 3) and tropon >= 10 and tropon <= 999) {
					fmgc.FMGCInternal.tropo = num(scratchpad) * 100;
					fmgc.FMGCInternal.tropoSet = 1;
					mcdu_scratchpad.scratchpads[i].empty();
				} else {
					mcdu_message(i, "ENTRY OUT OF RANGE");
				}
			}
		}
	} else if (key == "R6") {
		if (scratchpad == "CLR") {
			if (fmgc.FMGCInternal.gndTempSet) {
				fmgc.FMGCInternal.gndTempSet = 0;
				fmgc.FMGCInternal.gndTemp = 15;
				mcdu_scratchpad.scratchpads[i].empty();
			} else {
				mcdu_message(i, "NOT ALLOWED");
			}
		} else if (isnum(scratchpad) and fmgc.FMGCInternal.phase == 0) {
			if (size(scratchpad) >= 1 and size(scratchpad) <= 3 and scratchpad >= -99 and scratchpad <= 99) {
				fmgc.FMGCInternal.gndTemp = scratchpad;
				fmgc.FMGCInternal.gndTempSet = 1;
				mcdu_scratchpad.scratchpads[i].empty();
			} else {
				mcdu_message(i, "ENTRY OUT OF RANGE");
			}
		} else {
			mcdu_message(i, "NOT ALLOWED");
		}
	}
}
