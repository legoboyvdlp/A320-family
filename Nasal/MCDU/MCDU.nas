# A3XX mCDU by Joshua Davidson (Octal450), Jonathan Redpath, and Matthew Maring (mattmaring)

# Copyright (c) 2020 Josh Davidson (Octal450)
# Copyright (c) 2020 Matthew Maring (mattmaring)

var pageNode = [props.globals.getNode("/MCDU[0]/page"), props.globals.getNode("/MCDU[1]/page")];
var page = nil;
var msg = nil;

var scratchpadNode = [nil, nil];
var MCDU_init = func(i) {
	MCDU_reset(i);
}

var MCDU_reset = func(i) {
	setprop("/MCDU[" ~ i ~ "]/active", 0);
	setprop("/MCDU[" ~ i ~ "]/atsu-active", 0);
	setprop("it-autoflight/settings/togaspd", 157); #aka v2 clone
	setprop("/MCDU[" ~ i ~ "]/last-fmgc-page", "STATUS");
	setprop("/MCDU[" ~ i ~ "]/last-atsu-page", "ATSUDLINK");
	setprop("/MCDU[" ~ i ~ "]/active-system","");
	pageNode[i].setValue("MCDU");
	
	setprop("/FMGC/keyboard-left", 0);
	setprop("/FMGC/keyboard-right", 0);
	
	#ACCONFIG
	setprop("/FMGC/internal/navdatabase", "01JAN-28JAN");
	setprop("/FMGC/internal/navdatabase2", "29JAN-26FEB");
	setprop("/FMGC/internal/navdatabasecode", "AB20170101");
	setprop("/FMGC/internal/navdatabasecode2", "AB20170102");
	setprop("/FMGC/print/mcdu/page1/L1auto", 0);
	setprop("/FMGC/print/mcdu/page1/L2auto", 0);
	setprop("/FMGC/print/mcdu/page1/L3auto", 0);
	setprop("/FMGC/print/mcdu/page1/R1req", 0);
	setprop("/FMGC/print/mcdu/page1/R2req", 0);
	setprop("/FMGC/print/mcdu/page1/R3req", 0);
	setprop("/FMGC/print/mcdu/page2/L1auto", 0);
	setprop("/FMGC/print/mcdu/page2/L2auto", 0);
	setprop("/FMGC/print/mcdu/page2/L3auto", 0);
	setprop("/FMGC/print/mcdu/page2/L4auto", 0);
	setprop("/FMGC/print/mcdu/page2/R1req", 0);
	setprop("/FMGC/print/mcdu/page2/R2req", 0);
	setprop("/FMGC/print/mcdu/page2/R3req", 0);
	setprop("/FMGC/print/mcdu/page2/R4req", 0);
	
	#RADNAV
	setprop("/FMGC/internal/ils1freq-set", 0);
	setprop("/FMGC/internal/ils1crs-set", 0);
	setprop("/FMGC/internal/ils1freq-calculated", 0);
	setprop("/FMGC/internal/vor1freq-set", 0);
	setprop("/FMGC/internal/vor1crs-set", 0);
	setprop("/FMGC/internal/vor2freq-set", 0);
	setprop("/FMGC/internal/vor2crs-set", 0);
	setprop("/FMGC/internal/adf1freq-set", 0);
	setprop("/FMGC/internal/adf2freq-set", 0);
	
	# INT-A
	fmgc.FMGCInternal.altAirport = "";
	fmgc.FMGCInternal.altAirportSet = 0;
	fmgc.FMGCInternal.arrApt = "";
	fmgc.FMGCInternal.costIndex = 0;
	fmgc.FMGCInternal.costIndexSet = 0;
	fmgc.FMGCInternal.crzFt = 10000;
	fmgc.altvert();
	fmgc.updateRouteManagerAlt();
	fmgc.FMGCInternal.crzFl = 100;
	fmgc.FMGCInternal.crzSet = 0;
	updateCrzLvlCallback();
	fmgc.FMGCInternal.crzTemp = 15;
	fmgc.FMGCInternal.crzTempSet = 0;
	fmgc.FMGCInternal.depApt = "";
	fmgc.FMGCInternal.flightNum = "";
	fmgc.FMGCInternal.flightNumSet = 0;
	fmgc.FMGCInternal.gndTemp = -99;
	fmgc.FMGCInternal.gndTempSet = 0;
	fmgc.FMGCInternal.toFromSet = 0;
	fmgc.FMGCNodes.toFromSet.setValue(0);
	fmgc.FMGCInternal.coRoute = "";
	fmgc.FMGCInternal.coRouteSet = 0;
	fmgc.FMGCInternal.tropo = 36090;
	fmgc.FMGCInternal.tropoSet = 0;
	
	# IRSINIT
	setprop("/FMGC/internal/align-set", 0);
	setprop("/FMGC/internal/align-ref-lat-degrees", 0);
	setprop("/FMGC/internal/align-ref-lat-minutes", 0);
	setprop("/FMGC/internal/align-ref-lat-sign", "");
	setprop("/FMGC/internal/align-ref-long-degrees", 0);
	setprop("/FMGC/internal/align-ref-long-minutes", 0);
	setprop("/FMGC/internal/align-ref-long-sign", "");
	setprop("/FMGC/internal/align-ref-lat-edit", 0);
	setprop("/FMGC/internal/align-ref-long-edit", 0);
	setprop("/FMGC/internal/align1-done", 0);
	setprop("/FMGC/internal/align2-done", 0);
	setprop("/FMGC/internal/align3-done", 0);

	# ROUTE SELECTION
	fmgc.FMGCInternal.altSelected = 0;

	# INT-B
	fmgc.FMGCInternal.zfw = 0;
	fmgc.FMGCInternal.zfwSet = 0;
	fmgc.FMGCInternal.zfwcg = 25.0;
	fmgc.FMGCInternal.zfwcgSet = 0;
	fmgc.FMGCInternal.block = 0.0;
	fmgc.FMGCInternal.blockSet = 0;
	fmgc.FMGCInternal.taxiFuel = 0.4;
	fmgc.FMGCInternal.taxiFuelSet = 0;
	fmgc.FMGCInternal.tripFuel = 0;
	fmgc.FMGCInternal.tripTime = "0000";
	fmgc.FMGCInternal.rteRsv = 0;
	fmgc.FMGCInternal.rteRsvSet = 0;
	fmgc.FMGCInternal.rtePercent = 5.0;
	fmgc.FMGCInternal.rtePercentSet = 0;
	fmgc.FMGCInternal.altFuel = 0;
	fmgc.FMGCInternal.altFuelSet = 0;
	fmgc.FMGCInternal.altTime = "0000";
	fmgc.FMGCInternal.finalFuel = 0;
	fmgc.FMGCInternal.finalFuelSet = 0;
	fmgc.FMGCInternal.finalTime = "0030";
	fmgc.FMGCInternal.finalTimeSet = 0;
	fmgc.FMGCInternal.minDestFob = 0;
	fmgc.FMGCInternal.minDestFobSet = 0;
	fmgc.FMGCInternal.tow = 0;
	fmgc.FMGCInternal.lw = 0;
	fmgc.FMGCInternal.tripWind = "HD000";
	fmgc.FMGCInternal.tripWindValue = 0;
	fmgc.FMGCInternal.fffqSensor = "FF+FQ";
	fmgc.FMGCInternal.extraFuel = 0;
	fmgc.FMGCInternal.extraTime = "0000";
	fmgc.FMGCInternal.fuelRequest = 0;
	fmgc.FMGCInternal.blockCalculating = 0;
	fmgc.blockCalculating.setValue(0);
	fmgc.FMGCInternal.blockConfirmed = 0;
	fmgc.FMGCInternal.fuelCalculating = 0;
	fmgc.fuelCalculating.setValue(0);
	
	# FUELPRED
	fmgc.FMGCInternal.priUtc = "0000";
	fmgc.FMGCInternal.altUtc = "0000";
	fmgc.FMGCInternal.priEfob = 0;
	fmgc.FMGCInternal.altEfob = 0;
	fmgc.FMGCInternal.fob = 0;
	fmgc.FMGCInternal.fuelPredGw = 0;
	fmgc.FMGCInternal.cg = 0;
	
	# PROG
	fmgc.FMGCInternal.crzProg = 100;
	
	# PERF
	
	#PERF TO
	fmgc.FMGCInternal.v1 = 0;
	fmgc.FMGCInternal.v1set = 0;
	fmgc.FMGCInternal.vr = 0;
	fmgc.FMGCInternal.vrset = 0;
	fmgc.FMGCInternal.v2 = 0;
	fmgc.FMGCInternal.v2set = 0;
	
	setprop("/FMGC/internal/accel-agl-ft", 1500); #eventually set to 1500 above runway
	setprop("/MCDUC/thracc-set", 0);
	setprop("/FMGC/internal/to-flap", 0);
	setprop("/FMGC/internal/to-ths", "0.0");
	setprop("/FMGC/internal/flap-ths-set", 0);
	setprop("/FMGC/internal/flex", 0);
	setprop("/FMGC/internal/flex-set", 0);
	setprop("/FMGC/internal/eng-out-reduc", "1500");
	setprop("/MCDUC/reducacc-set", 0);
	fmgc.FMGCInternal.transAlt = 18000;
	
	# CLB PERF
	setprop("/FMGC/internal/activate-once", 0);
	setprop("/FMGC/internal/activate-twice", 0);

	# CRZ PERF

	# DES PERF

	# APPR PERF
	setprop("/FMGC/internal/dest-qnh", -1);
	setprop("/FMGC/internal/dest-temp", -999);
	fmgc.FMGCInternal.destMag = 0;
	fmgc.FMGCInternal.destMagSet = 0;
	fmgc.FMGCInternal.destWind = 0;
	fmgc.FMGCInternal.destWindSet = 0;
	fmgc.FMGCInternal.vappSpeedSet = 0;
	setprop("/FMGC/internal/final", "");
	setprop("/FMGC/internal/baro", 99999);
	setprop("/FMGC/internal/radio", 99999);
	fmgc.FMGCInternal.radioNo = 0;
	setprop("/FMGC/internal/ldg-elev", 0);
	fmgc.FMGCInternal.ldgConfig3 = 0;
	fmgc.FMGCInternal.ldgConfigFull = 1;
	
	# GA PERF
}

var setMode = func(will) {
	setprop("/MCDU/keyboard-entry", will);
	if (will == 0) {
		gui.popupTip("MCDU keyboard entry disabled");
	} else {
		gui.popupTip("MCDU keyboard entry enabled");
	}
}

var lskbutton = func(btn, i) {
	page = pageNode[i].getValue();
	if (btn == "1") {
		if (page == "MCDU") {
			if (getprop("/MCDU[" ~ i ~ "]/atsu-active") == 1) {
				mcdu_message(i, "NOT ALLOWED");
			} else {
				if (getprop("/MCDU[" ~ i ~ "]/active") != 2) {
					mcdu_message(i, "WAIT FOR SYSTEM RESPONSE");
					setprop("/MCDU[" ~ i ~ "]/active", 1);
					settimer(func(){
						pageNode[i].setValue(getprop("/MCDU[" ~ i ~ "]/last-fmgc-page"));
						mcdu_scratchpad.scratchpads[i].empty();
						setprop("/MCDU[" ~ i ~ "]/active", 2);
						setprop("/MCDU[" ~ i ~ "]/active-system","fmgc");
					}, 2);
				} else {					
					pageNode[i].setValue(getprop("/MCDU[" ~ i ~ "]/last-fmgc-page"));
					setprop("/MCDU[" ~ i ~ "]/active-system","fmgc");
					mcdu_scratchpad.scratchpads[i].empty();
				}
			}
		} else if (page == "IRSINIT") {
			initInputIRS("L1",i);
		} else if (page == "INITB") {
			initInputB("L1",i);
		} else if (page == "WINDCLB") {
			canvas_mcdu.myCLBWIND[i].pushButtonLeft(1);
		} else if (page == "WINDCRZ") {
			canvas_mcdu.myCRZWIND[i].pushButtonLeft(1);
		} else if (page == "WINDDES") {
			canvas_mcdu.myDESWIND[i].pushButtonLeft(1);
		} else if (page == "PROGPREF") {
			progTOInput("L1",i); # same fn as TO
		} else if (page == "PROGTO") {
			progTOInput("L1",i);
		} else if (page == "PROGCLB" or page == "PROGAPPR") {  # APPR restore to CLB
			progCLBInput("L1",i);
		} else if (page == "PROGCRZ") {
			progCRZInput("L1",i);
		} else if (page == "PROGDES") {
			progDESInput("L1",i);
		} else if (page == "PERFTO") {
			perfTOInput("L1",i);
		} else if (page == "PERFAPPR") {
			perfAPPRInput("L1",i);
		} else if (page == "RADNAV") {
			radnavInput("L1",i);
		} else if (page == "DATA") {
			dataInput("L1",i);
		} else if (page == "PRINTFUNC") {
			printInput("L1",i);
		} else if (page == "PRINTFUNC2") {
			printInput2("L1",i);
		} else if (page == "LATREV") {
			if (canvas_mcdu.myLatRev[i].type == 0) {
				if (canvas_mcdu.myDeparture[i] != nil) {
					canvas_mcdu.myDeparture[i].del();
				}
				canvas_mcdu.myDeparture[i] = nil;
				canvas_mcdu.myDeparture[i] = departurePage.new(canvas_mcdu.myLatRev[i].title[2], i);
				pageNode[i].setValue("DEPARTURE");
			} else {
				mcdu_message(i, "NOT ALLOWED");
			}
		} else if (page == "F-PLNA" or page == "F-PLNB") {
			canvas_mcdu.myFpln[i].pushButtonLeft(1);
		} else if (page == "DIRTO") {
			canvas_mcdu.myDirTo[i].fieldL1(mcdu_scratchpad.scratchpads[i].scratchpad);
		} else if (page == "DUPLICATENAMES") {
			canvas_mcdu.myDuplicate[i].pushButtonLeft(1);
		} else if (page == "ATSUDLINK") {
			pageNode[i].setValue("ATCMENU");
		} else if (page == "COMMMENU") {
			pageNode[i].setValue("COMMINIT");
		} else if (page == "COMPANYCALL") {
			if (atsu.CompanyCall.frequency != 999.99) {
				atsu.CompanyCall.tune();
			} else {
				mcdu_message(i, "NOT ALLOWED");
			}
		} else if (page == "WEATHERREQ") {
			pageNode[i].setValue("WEATHERTYPE");
		}  else if (page == "WEATHERTYPE") {
			atsu.AOC.selectedType = "HOURLY WX";
			pageNode[i].setValue("WEATHERREQ");
		} else if (page == "RECEIVEDMSGS") {
			canvas_mcdu.myReceivedMessages[i].leftKey(1);
		} else if (page == "ATIS") {
			var scratchpad = mcdu_scratchpad.scratchpads[i].scratchpad;
			if (scratchpad == "CLR") {
				if (atsu.ATISInstances[0].sent != 1) {
					if (fmgc.FMGCInternal.depApt != "") {
						atsu.ATISInstances[0].newStation(fmgc.FMGCInternal.depApt);
					} else {
						atsu.ATISInstances[0].station = nil;
					}
					mcdu_scratchpad.scratchpads[i].empty();
				} else {
					mcdu_message(i, "NOT ALLOWED");
				}
			} elsif (size(scratchpad) == 0) {
				if (atsu.ATISInstances[0].received) {
					canvas_mcdu.myAtis[i] = atisPage.new(i, 0);
					pageNode[i].setValue("ATISDETAIL");
				} else {
					mcdu_message(i, "NOT ALLOWED");
				}
			} elsif (find("/", scratchpad) != -1) {
				var str = split("/", scratchpad);
				if (size(str[0]) > 0 and size(str[1]) == 0) {
					var result = atsu.ATISInstances[0].newStation(str[0]);
					if (result == 2) {
						mcdu_message(i, "NOT IN DATA BASE");
					} elsif (result == 1) {
						mcdu_message(i, "NOT ALLOWED");
					} elsif (result == 0) {
						mcdu_scratchpad.scratchpads[i].empty();
					}
				} elsif (size(str[0]) == 0 and size(str[1]) > 0) {
					if (str[1] == "DEP") {
						atsu.ATISInstances[0].type = 1;
					} elsif (str[1] == "ARR") {
						atsu.ATISInstances[0].type = 0;
					} else {
						mcdu_message(i, "NOT ALLOWED");
					}
					mcdu_scratchpad.scratchpads[i].empty();
				} elsif (size(str[0]) > 0 and size(str[1]) > 0) {
					var result = atsu.ATISInstances[0].newStation(str[0]);
					if (result == 2) {
						mcdu_message(i, "NOT IN DATA BASE");
					} elsif (result == 1) {
						mcdu_message(i, "NOT ALLOWED");
					}
					if (str[1] == "DEP") {
						atsu.ATISInstances[0].type = 1;
					} elsif (str[1] == "ARR") {
						atsu.ATISInstances[0].type = 0;
					} else {
						mcdu_message(i, "NOT ALLOWED");
					}
					mcdu_scratchpad.scratchpads[i].empty();
				} else {
					mcdu_message(i, "NOT ALLOWED");
				}
			} else {
				var result = atsu.ATISInstances[0].newStation(scratchpad);
				if (result == 2) {
					mcdu_message(i, "NOT IN DATA BASE");
				} elsif (result == 1) {
					mcdu_message(i, "NOT ALLOWED");
				} elsif (result == 0) {
					mcdu_scratchpad.scratchpads[i].empty();
				}
			}
		} else if (page == "MCDUTEXT") {
			atsu.freeTexts[i].selection = 0;
			atsu.freeTexts[i].changed = 1;
		} else {
			mcdu_message(i, "NOT ALLOWED");
		}
	} else if (btn == "2") {
		if (page == "MCDU") {
			if (getprop("/MCDU[" ~ i ~ "]/active") == 1) {
				mcdu_message(i, "NOT ALLOWED");
			} else {
				if (getprop("/MCDU[" ~ i ~ "]/atsu-active") != 2) {
					mcdu_message(i, "WAIT FOR SYSTEM RESPONSE");
					setprop("/MCDU[" ~ i ~ "]/atsu-active", 1);
					settimer(func(){
						pageNode[i].setValue(getprop("/MCDU[" ~ i ~ "]/last-atsu-page"));
						mcdu_scratchpad.scratchpads[i].empty();
						setprop("/MCDU[" ~ i ~ "]/atsu-active", 2);
						setprop("/MCDU[" ~ i ~ "]/active-system","atsu");
					}, 2);
				} else {
					pageNode[i].setValue(getprop("/MCDU[" ~ i ~ "]/last-atsu-page"));
					setprop("/MCDU[" ~ i ~ "]/active-system","atsu");
					mcdu_scratchpad.scratchpads[i].empty();
				}
			}
		} else if (page == "INITA") {
			initInputA("L2",i);
		} else if (page == "WINDCLB") {
			canvas_mcdu.myCLBWIND[i].pushButtonLeft(2);
		} else if (page == "WINDCRZ") {
			canvas_mcdu.myCRZWIND[i].pushButtonLeft(2);
		} else if (page == "WINDDES") {
			canvas_mcdu.myDESWIND[i].pushButtonLeft(2);
		} else if (page == "PERFTO") {
			perfTOInput("L2",i);
		} else if (page == "PERFAPPR") {
			perfAPPRInput("L2",i);
		} else if (page == "RADNAV") {
			radnavInput("L2",i);
		} else if (page == "PERFCLB") {
			perfCLBInput("L2",i);
		} else if (page == "PERFCRZ") {
			perfCRZInput("L2",i); 
		} else if (page == "PERFDES") {
			perfDESInput("L2",i); 
		} else if (page == "DATA") {
			dataInput("L2",i);
		} else if (page == "PRINTFUNC") {
			printInput("L2",i);
		} else if (page == "PRINTFUNC2") {
			printInput2("L2",i);
		} else if (page == "F-PLNA" or page == "F-PLNB") {
			canvas_mcdu.myFpln[i].pushButtonLeft(2);
		} else if (page == "DEPARTURE") {
			canvas_mcdu.myDeparture[i].depPushbuttonLeft(2);
		} else if (page == "ARRIVAL") {
			canvas_mcdu.myArrival[i].arrPushbuttonLeft(2);
		} else if (page == "DIRTO") {
			canvas_mcdu.myDirTo[i].leftFieldBtn(2);
		} else if (page == "DUPLICATENAMES") {
			canvas_mcdu.myDuplicate[i].pushButtonLeft(2);
		} else if (page == "NOTIFICATION") {
			var result = atsu.notificationSystem.inputAirport(mcdu_scratchpad.scratchpads[i].scratchpad);
			if (result == 1) {
				mcdu_message(i, "NOT ALLOWED");
			} elsif (result == 2) {
				mcdu_message(i, "NOT IN DATA BASE");
			} else {
				mcdu_scratchpad.scratchpads[i].empty();
			}
		} else if (page == "COMMMENU") {
			pageNode[i].setValue("DATAMODE");
		} else if (page == "RECEIVEDMSGS") {
			canvas_mcdu.myReceivedMessages[i].leftKey(2);
		} else if (page == "DATAMODE") {
			atsu.ATIS.serverSel.setValue("faa");
			acconfig.writeSettings();
		} else if (page == "ATIS") {
			var scratchpad = mcdu_scratchpad.scratchpads[i].scratchpad;
			if (scratchpad == "CLR") {
				if (atsu.ATISInstances[1].sent != 1) {
					if (fmgc.FMGCInternal.arrApt != "") {
						atsu.ATISInstances[1].newStation(fmgc.FMGCInternal.arrApt);
					} else {
						atsu.ATISInstances[1].station = nil;
					}
					mcdu_scratchpad.scratchpads[i].empty();
				} else {
					mcdu_message(i, "NOT ALLOWED");
				}
			} elsif (size(scratchpad) == 0) {
				if (atsu.ATISInstances[1].received) {
					canvas_mcdu.myAtis[i] = atisPage.new(i, 1);
					pageNode[i].setValue("ATISDETAIL");
				} else {
					mcdu_message(i, "NOT ALLOWED");
				}
			}  elsif (find("/", scratchpad) != -1) {
				var str = split("/", scratchpad);
				if (size(str[0]) > 0 and size(str[1]) == 0) {
					var result = atsu.ATISInstances[1].newStation(str[0]);
					if (result == 2) {
						mcdu_message(i, "NOT IN DATA BASE");
					} elsif (result == 1) {
						mcdu_message(i, "NOT ALLOWED");
					} elsif (result == 0) {
						mcdu_scratchpad.scratchpads[i].empty();
					}
				} elsif (size(str[0]) == 0 and size(str[1]) > 0) {
					if (str[1] == "DEP") {
						atsu.ATISInstances[1].type = 1;
					} elsif (str[1] == "ARR") {
						atsu.ATISInstances[1].type = 0;
					} else {
						mcdu_message(i, "NOT ALLOWED");
					}
					mcdu_scratchpad.scratchpads[i].empty();
				} elsif (size(str[0]) > 0 and size(str[1]) > 0) {
					var result = atsu.ATISInstances[1].newStation(str[0]);
					if (result == 2) {
						mcdu_message(i, "NOT IN DATA BASE");
					} elsif (result == 1) {
						mcdu_message(i, "NOT ALLOWED");
					}
					if (str[1] == "DEP") {
						atsu.ATISInstances[1].type = 1;
					} elsif (str[1] == "ARR") {
						atsu.ATISInstances[1].type = 0;
					} else {
						mcdu_message(i, "NOT ALLOWED");
					}
					mcdu_scratchpad.scratchpads[i].empty();
				} else {
					mcdu_message(i, "NOT ALLOWED");
				}
			} else {
				var result = atsu.ATISInstances[1].newStation(scratchpad);
				if (result == 2) {
					mcdu_message(i, "NOT IN DATA BASE");
				} elsif (result == 1) {
					mcdu_message(i, "NOT ALLOWED");
				} elsif (result == 0) {
					mcdu_scratchpad.scratchpads[i].empty();
				}
			}
		} else if (page == "MCDUTEXT") {
			atsu.freeTexts[i].selection = 1;
			atsu.freeTexts[i].changed = 1;
		} else {
			mcdu_message(i, "NOT ALLOWED");
		}
	} else if (btn == "3") {
		if (page == "INITA") {
			initInputA("L3",i);
		} else if (page == "INITB") {
			initInputB("L3",i);
		} else if (page == "FUELPRED") {
			fuelPredInput("L3",i);
		} else if (page == "WINDCLB") {
			canvas_mcdu.myCLBWIND[i].pushButtonLeft(3);
		} else if (page == "WINDCRZ") {
			canvas_mcdu.myCRZWIND[i].pushButtonLeft(3);
		} else if (page == "WINDDES") {
			canvas_mcdu.myDESWIND[i].pushButtonLeft(3);
		} else if (page == "PERFTO") {
			perfTOInput("L3",i);
		} else if (page == "PERFAPPR") {
			perfAPPRInput("L3",i);
		} else if (page == "STATUS") {
			statusInput("L3",i);
		} else if (page == "RADNAV") {
			radnavInput("L3",i);
		} else if (page == "DATA") {
			dataInput("L3",i);
		} else if (page == "PRINTFUNC") {
			printInput("L3",i);
		} else if (page == "PRINTFUNC2") {
			printInput2("L3",i);
		} else if (page == "F-PLNA" or page == "F-PLNB") {
			canvas_mcdu.myFpln[i].pushButtonLeft(3);
		} else if (page == "DEPARTURE") {
			canvas_mcdu.myDeparture[i].depPushbuttonLeft(3);
		} else if (page == "ARRIVAL") {
			canvas_mcdu.myArrival[i].arrPushbuttonLeft(3);
		} else if (page == "DIRTO") {
			canvas_mcdu.myDirTo[i].leftFieldBtn(3);
		} else if (page == "LATREV") {
			if (canvas_mcdu.myLatRev[i].type != 0 and canvas_mcdu.myLatRev[i].type != 1) {
				if (canvas_mcdu.myHold[i] != nil) {
					canvas_mcdu.myHold[i].del();
				}
				canvas_mcdu.myHold[i] = nil;
				canvas_mcdu.myHold[i] = holdPage.new(i, canvas_mcdu.myLatRev[i].wpt);
				pageNode[i].setValue("HOLD");
			} else {
				mcdu_message(i, "NOT ALLOWED");
			}
		} else if (page == "DUPLICATENAMES") {
			canvas_mcdu.myDuplicate[i].pushButtonLeft(3);
		} else if (page == "COMMMENU") {
			pageNode[i].setValue("VOICEDIRECTORY");
		} else if (page == "RECEIVEDMSGS") {
			canvas_mcdu.myReceivedMessages[i].leftKey(3);
		} else if (page == "DATAMODE") {
			atsu.ATIS.serverSel.setValue("vatsim");
			acconfig.writeSettings();
		} else if (page == "ATIS") {
			var scratchpad = mcdu_scratchpad.scratchpads[i].scratchpad;
			if (scratchpad == "CLR") {
				if (atsu.ATISInstances[2].sent != 1) {
					if (fmgc.FMGCInternal.altAirportSet) {
						atsu.ATISInstances[2].newStation(fmgc.FMGCInternal.altAirport);
					} else {
						atsu.ATISInstances[2].station = nil;
					}
					mcdu_scratchpad.scratchpads[i].empty();
				} else {
					mcdu_message(i, "NOT ALLOWED");
				}
			} elsif (size(scratchpad) == 0) {
				if (atsu.ATISInstances[2].received) {
					canvas_mcdu.myAtis[i] = atisPage.new(i, 2);
					pageNode[i].setValue("ATISDETAIL");
				} else {
					mcdu_message(i, "NOT ALLOWED");
				}
			} elsif (find("/", scratchpad) != -1) {
				var str = split("/", scratchpad);
				if (size(str[0]) > 0 and size(str[1]) == 0) {
					var result = atsu.ATISInstances[2].newStation(str[0]);
					if (result == 2) {
						mcdu_message(i, "NOT IN DATA BASE");
					} elsif (result == 1) {
						mcdu_message(i, "NOT ALLOWED");
					} elsif (result == 0) {
						mcdu_scratchpad.scratchpads[i].empty();
					}
				} elsif (size(str[0]) == 0 and size(str[1]) > 0) {
					if (str[1] == "DEP") {
						atsu.ATISInstances[2].type = 1;
					} elsif (str[1] == "ARR") {
						atsu.ATISInstances[2].type = 0;
					} else {
						mcdu_message(i, "NOT ALLOWED");
					}
					mcdu_scratchpad.scratchpads[i].empty();
				} elsif (size(str[0]) > 0 and size(str[1]) > 0) {
					var result = atsu.ATISInstances[2].newStation(str[0]);
					if (result == 2) {
						mcdu_message(i, "NOT IN DATA BASE");
					} elsif (result == 1) {
						mcdu_message(i, "NOT ALLOWED");
					}
					if (str[1] == "DEP") {
						atsu.ATISInstances[2].type = 1;
					} elsif (str[1] == "ARR") {
						atsu.ATISInstances[2].type = 0;
					} else {
						mcdu_message(i, "NOT ALLOWED");
					}
					mcdu_scratchpad.scratchpads[i].empty();
				} else {
					mcdu_message(i, "NOT ALLOWED");
				}
			} else {
				var result = atsu.ATISInstances[2].newStation(scratchpad);
				if (result == 2) {
					mcdu_message(i, "NOT IN DATA BASE");
				} elsif (result == 1) {
					mcdu_message(i, "NOT ALLOWED");
				} elsif (result == 0) {
					mcdu_scratchpad.scratchpads[i].empty();
				}
			}
		} else if (page == "MCDUTEXT") {
			atsu.freeTexts[i].selection = 2;
			atsu.freeTexts[i].changed = 1;
		} else {
			mcdu_message(i, "NOT ALLOWED");
		}
	} else if (btn == "4") {
		if (page == "DATA") {
			pageNode[i].setValue("STATUS");
		} else if (page == "INITB") {
			initInputB("L4",i);
		} else if (page == "FUELPRED") {
			fuelPredInput("L4",i);
		} else if (page == "WINDCLB") {
			canvas_mcdu.myCLBWIND[i].pushButtonLeft(4);
		} else if (page == "WINDCRZ") {
			canvas_mcdu.myCRZWIND[i].pushButtonLeft(4);
		} else if (page == "WINDDES") {
			canvas_mcdu.myDESWIND[i].pushButtonLeft(4);
		} else if (page == "PERFTO") {
			perfTOInput("L4",i);
		} else if (page == "PERFAPPR") {
			perfAPPRInput("L4",i);
		} else if (page == "RADNAV") {
			radnavInput("L4",i);
		} else if (page == "PRINTFUNC2") {
			printInput2("L4",i);
		} else if (page == "F-PLNA" or page == "F-PLNB") {
			canvas_mcdu.myFpln[i].pushButtonLeft(4);
		} else if (page == "DEPARTURE") {
			canvas_mcdu.myDeparture[i].depPushbuttonLeft(4);
		} else if (page == "ARRIVAL") {
			canvas_mcdu.myArrival[i].arrPushbuttonLeft(4);
		} else if (page == "DIRTO") {
			canvas_mcdu.myDirTo[i].leftFieldBtn(4);
		} else if (page == "DUPLICATENAMES") {
			canvas_mcdu.myDuplicate[i].pushButtonLeft(4);
		} else if (page == "CONNECTSTATUS") {
			if (atsu.ADS.state != 0) {
				atsu.ADS.setState(0);
			} else {
				atsu.ADS.setState(1);
			}
		} else if (page == "VOICEDIRECTORY") {
			if (atsu.CompanyCall.frequency != 999.99) { 
				atsu.CompanyCall.tune(); 
			} else {
				mcdu_message(i, "NOT ALLOWED");
			}
		} else if (page == "RECEIVEDMSGS") {
			canvas_mcdu.myReceivedMessages[i].leftKey(4);
		} else if (page == "ATIS") {
			var scratchpad = mcdu_scratchpad.scratchpads[i].scratchpad;
			if (scratchpad == "CLR") {
				if (atsu.ATISInstances[3].sent != 1) {
					atsu.ATISInstances[3].station = nil;
					mcdu_scratchpad.scratchpads[i].empty();
				} else {
					mcdu_message(i, "NOT ALLOWED");
				}
			} elsif (size(scratchpad) == 0) {
				if (atsu.ATISInstances[3].received) {
					canvas_mcdu.myAtis[i] = atisPage.new(i, 3);
					pageNode[i].setValue("ATISDETAIL");
				} else {
					mcdu_message(i, "NOT ALLOWED");
				}
			} elsif (find("/", scratchpad) != -1) {
				var str = split("/", scratchpad);
				if (size(str[0]) > 0 and size(str[1]) == 0) {
					var result = atsu.ATISInstances[3].newStation(str[0]);
					if (result == 2) {
						mcdu_message(i, "NOT IN DATA BASE");
					} elsif (result == 1) {
						mcdu_message(i, "NOT ALLOWED");
					} elsif (result == 0) {
						mcdu_scratchpad.scratchpads[i].empty();
					}
				} elsif (size(str[0]) == 0 and size(str[1]) > 0) {
					if (str[1] == "DEP") {
						atsu.ATISInstances[3].type = 1;
					} elsif (str[1] == "ARR") {
						atsu.ATISInstances[3].type = 0;
					} else {
						mcdu_message(i, "NOT ALLOWED");
					}
					mcdu_scratchpad.scratchpads[i].empty();
				} elsif (size(str[0]) > 0 and size(str[1]) > 0) {
					var result = atsu.ATISInstances[3].newStation(str[0]);
					if (result == 2) {
						mcdu_message(i, "NOT IN DATA BASE");
					} elsif (result == 1) {
						mcdu_message(i, "NOT ALLOWED");
					}
					if (str[1] == "DEP") {
						atsu.ATISInstances[3].type = 1;
					} elsif (str[1] == "ARR") {
						atsu.ATISInstances[3].type = 0;
					} else {
						mcdu_message(i, "NOT ALLOWED");
					}
					mcdu_scratchpad.scratchpads[i].empty();
				} else {
					mcdu_message(i, "NOT ALLOWED");
				}
			} else {
				var result = atsu.ATISInstances[3].newStation(scratchpad);
				if (result == 2) {
					mcdu_message(i, "NOT IN DATA BASE");
				} elsif (result == 1) {
					mcdu_message(i, "NOT ALLOWED");
				} elsif (result == 0) {
					mcdu_scratchpad.scratchpads[i].empty();
				}
			}
		} else {
			mcdu_message(i, "NOT ALLOWED");
		}
	} else if (btn == "5") {
		if (page == "INITA") {
			initInputA("L5",i);
		} else if (page == "INITB") {
			initInputB("L5",i);
		} else if (page == "FUELPRED") {
			fuelPredInput("L5",i);
		} else if (page == "WINDCLB") {
			canvas_mcdu.myCLBWIND[i].pushButtonLeft(5);
		} else if (page == "WINDCRZ") {
			canvas_mcdu.myCRZWIND[i].pushButtonLeft(5);
		} else if (page == "WINDDES") {
			canvas_mcdu.myDESWIND[i].pushButtonLeft(5);
		} else if (page == "PERFTO") {
			perfTOInput("L5",i);
		} else if (page == "PERFCLB") {
			perfCLBInput("L5",i);
		} else if (page == "PERFCRZ") {
			perfCRZInput("L5",i);
		} else if (page == "PERFDES") {
			perfDESInput("L5",i);
		} else if (page == "PERFAPPR") {
			perfAPPRInput("L5",i);
		} else if (page == "PERFGA") {
			perfGAInput("L5",i);
		} else if (page == "RADNAV") {
			radnavInput("L5",i);
		} else if (page == "PRINTFUNC") {
			printInput("L5",i);
		} else if (page == "PRINTFUNC2") {
			printInput2("L5",i);
		} else if (page == "DATA") {
			dataInput("L5",i);
		} else if (page == "DATA2") {
			data2Input("L5",i);
		} else if (page == "F-PLNA" or page == "F-PLNB") {
			canvas_mcdu.myFpln[i].pushButtonLeft(5);
		} else if (page == "DEPARTURE") {
			canvas_mcdu.myDeparture[i].depPushbuttonLeft(5);
		} else if (page == "ARRIVAL") {
			canvas_mcdu.myArrival[i].arrPushbuttonLeft(5);
		} else if (page == "VERTREV") {
			canvas_mcdu.myVertRev[i].pushButtonLeft(5);
		} else if (page == "DIRTO") {
			canvas_mcdu.myDirTo[i].leftFieldBtn(5);
		} else if (page == "DUPLICATENAMES") {
			canvas_mcdu.myDuplicate[i].pushButtonLeft(5);
		} else if (page == "CLOSESTAIRPORT") {
			canvas_mcdu.myClosestAirport[i].manAirportCall(mcdu_scratchpad.scratchpads[i].scratchpad);
			mcdu_scratchpad.scratchpads[i].empty();
		} else if (page == "ATCMENU") {
			pageNode[i].setValue("NOTIFICATION");
		} else if (page == "FLTLOG") {
			mcdu_message(i, "NOT ALLOWED");
		} else if (page == "MCDUTEXT") {
			atsu.freeTexts[i].selection = 9;
			atsu.freeTexts[i].changed = 1;
		} else if (page == "RECEIVEDMSGS") {
			canvas_mcdu.myReceivedMessages[i].leftKey(5);
		} else {
			mcdu_message(i, "NOT ALLOWED");
		}
	} else if (btn == "6") {
		if (page == "INITA") {
			initInputA("L6",i);
		} else if (page == "INITB") {
			initInputB("L6",i);
		} else if (page == "FUELPRED") {
			fuelPredInput("L6",i);
		} else if (page == "IRSINIT") {
			initInputIRS("L6",i);
		} else if (page == "WINDCLB") {
			canvas_mcdu.myCLBWIND[i].pushButtonLeft(6);
		} else if (page == "WINDCRZ") {
			canvas_mcdu.myCRZWIND[i].pushButtonLeft(6);
		} else if (page == "WINDDES") {
			canvas_mcdu.myDESWIND[i].pushButtonLeft(6);
		} else if (page == "WINDHIST") {
			if (canvas_mcdu.myCLBWIND[i] == nil) {
				canvas_mcdu.myCLBWIND[i] = windCLBPage.new(i);
			} else {
				canvas_mcdu.myCLBWIND[i].reload();
			}
			pageNode[i].setValue("WINDCLB");
		} else if (page == "ROUTESELECTION") {
			initInputROUTESEL("L6",i);
		} else if (page == "PERFCLB") {
			perfCLBInput("L6",i);
		} else if (page == "PERFCRZ") {
			perfCRZInput("L6",i);
		} else if (page == "PERFDES") {
			perfDESInput("L6",i);
		} else if (page == "PERFAPPR") {
			perfAPPRInput("L6",i);
		} else if (page == "PERFGA") {
			perfGAInput("L6",i);
		} else if (page == "PRINTFUNC2") {
			printInput2("L6",i);
		} else if (page == "F-PLNA" or page == "F-PLNB") {
			canvas_mcdu.myFpln[i].pushButtonLeft(6);
		} else if (page == "LATREV" or page == "VERTREV" or page == "DUPLICATENAMES") {
			if (page != "DUPLICATENAMES") {
				pageNode[i].setValue("F-PLNA");
			} else {
				 if (canvas_mcdu.myDuplicate[i] != nil and canvas_mcdu.myDuplicate[i].flagPROG) {
					pagebutton("prog",i);
				 }
			}
		} else if (page == "ARRIVAL") {
			canvas_mcdu.myArrival[i].arrPushbuttonLeft(6);
		} else if (page == "DEPARTURE" or page == "HOLD" or page == "AIRWAYS") {
			if (fmgc.flightPlanController.temporaryFlag[i]) {
				pageNode[i].setValue("F-PLNA");
			} else {
				pageNode[i].setValue("LATREV");
			}
		} else if (page == "DIRTO") {
			canvas_mcdu.myDirTo[i].fieldL6();
		} else if (page == "CLOSESTAIRPORT") {
			canvas_mcdu.myClosestAirport[i].freeze();
		} else if (page == "AOCMENU" or page == "ATCMENU" or page == "ATCMENU2") {
			pageNode[i].setValue("ATSUDLINK");
		} else if (page == "SENSORS") {
			pageNode[i].setValue("FLTLOG");
		} else if (page == "NOTIFICATION" or page == "CONNECTSTATUS" or page == "MCDUTEXT") {
			pageNode[i].setValue("ATCMENU");
		} else if (page == "WEATHERREQ" or page == "RECEIVEDMSGS") {
			pageNode[i].setValue("AOCMENU");
		} else if (page == "RECEIVEDMSG") {
			pageNode[i].setValue("RECEIVEDMSGS");
			canvas_mcdu.myReceivedMessages[i].update();
		} else if (page == "COMMMENU") {
			pageNode[i].setValue("ATSUDLINK");
		} else if (page == "COMMINIT" or page == "VOICEDIRECTORY" or page == "DATAMODE"  or page == "COMMSTATUS" or page == "COMPANYCALL") {
			pageNode[i].setValue("COMMMENU");
		} else if (page == "ATIS") {
			pageNode[i].setValue("ATCMENU2");
		} else if (page == "ATISDETAIL") {
			pageNode[i].setValue("ATIS");
		} else if (page == "AOCCONFIG") {
			pageNode[i].setValue("AOCMENU");
		} else if (page == "POSMON") {
			canvas_mcdu.togglePageFreeze(i);
		} else {
			mcdu_message(i, "NOT ALLOWED");
		}
	}
}

var rskbutton = func(btn, i) {
	page = pageNode[i].getValue();
	if (btn == "1") {
		if (page == "INITA") {
			initInputA("R1",i);
		} else if (page == "IRSINIT") {
			initInputIRS("R1",i);
		} else if (page == "INITB") {
			initInputB("R1",i);
		} else if (page == "WINDCLB") {
			if (fmgc.FMGCInternal.phase == 0) {
				if (canvas_mcdu.myHISTWIND[i] == nil) {
					canvas_mcdu.myHISTWIND[i] = windHISTPage.new(i);
				} else {
					canvas_mcdu.myHISTWIND[i].reload();
				}
				pageNode[i].setValue("WINDHIST");
			} else {
				mcdu_message(i, "NOT ALLOWED");
			}
		} else if (page == "WINDDES") {
			canvas_mcdu.myDESWIND[i].pushButtonRight(1);
		} else if (page == "RADNAV") {
			radnavInput("R1",i);
		} else if (page == "PRINTFUNC") {
			printInput("R1",i);
		} else if (page == "PRINTFUNC2") {
			printInput2("R1",i);
		} else if (page == "LATREV") {
			if (canvas_mcdu.myLatRev[i].type == 1) {
				if (canvas_mcdu.myArrival[i] != nil) {
					canvas_mcdu.myArrival[i].del();
				}
				canvas_mcdu.myArrival[i] = nil;
				canvas_mcdu.myArrival[i] = arrivalPage.new(canvas_mcdu.myLatRev[i].title[2], i);
				canvas_mcdu.myArrival[i]._setupPageWithData();
				pageNode[i].setValue("ARRIVAL");
			} else {
				mcdu_message(i, "NOT ALLOWED");
			}
		} else if (page == "F-PLNA" or page == "F-PLNB") {
			canvas_mcdu.myFpln[i].pushButtonRight(1);
		} else if (page == "DATA2") {
			if (fmgc.WaypointDatabase.getCount() > 0) {
				if (canvas_mcdu.myPilotWP[i] != nil) {
					canvas_mcdu.myPilotWP[i].del();
				}
				canvas_mcdu.myPilotWP[i] = nil;
				canvas_mcdu.myPilotWP[i] = pilotWaypointPage.new(i);
				pageNode[i].setValue("PILOTWP");
			} else {
				mcdu_message(i, "NOT ALLOWED"); # todo spawn new waypoints page
			}
		} else if (page == "COMMMENU") {
			pageNode[i].setValue("COMMSTATUS");
		} else if (page == "COMPANYCALL") {
			if (atsu.CompanyCall.frequency != 999.99) {
				atsu.CompanyCall.ack();
			} else {
				mcdu_message(i, "NOT ALLOWED");
			}
		} else if (page == "ATSUDLINK") {
			pageNode[i].setValue("AOCMENU");
		} else if (page == "AOCMENU") {
			pageNode[i].setValue("FLTLOG");
		} else if (page == "WEATHERREQ") {
			var result = atsu.AOC.newStation(mcdu_scratchpad.scratchpads[i].scratchpad, i);
			if (result == 1) {
				mcdu_message(i, "NOT ALLOWED");
			} elsif (result == 2) {
				mcdu_message(i, "NOT IN DATA BASE");
			} else {
				mcdu_scratchpad.scratchpads[i].empty();
			}
		} else if (page == "WEATHERTYPE") {
			atsu.AOC.selectedType = "TERM FCST";
			pageNode[i].setValue("WEATHERREQ");
		} else if (page == "ATCMENU2") {
			pageNode[i].setValue("ATIS");
		} else if (page == "ATIS") {
			if (atsu.ATISInstances[0].station != nil and atsu.ATISInstances[0].sent != 1) {
				atsu.ATISInstances[0].sendReq(i);
			} else {
				mcdu_message(i, "NOT ALLOWED");
			}
		} else if (page == "MCDUTEXT") {
			atsu.freeTexts[i].selection = 3;
			atsu.freeTexts[i].changed = 1;
		} else {
			mcdu_message(i, "NOT ALLOWED");
		}
	} else if (btn == "2") {
		if (page == "INITA") {
			initInputA("R2",i);
		} else if (page == "INITB") {
			initInputB("R2",i);
		} else if (page == "PERFAPPR") {
			perfAPPRInput("R2",i);
		} else if (page == "RADNAV") {
			radnavInput("R2",i);
		} else if (page == "PRINTFUNC") {
			printInput("R2",i);
		} else if (page == "PRINTFUNC2") {
			printInput2("R2",i);
		} else if (page == "DEPARTURE") {
			canvas_mcdu.myDeparture[i].depPushbuttonRight(2);
		} else if (page == "ARRIVAL") {
			canvas_mcdu.myArrival[i].arrPushbuttonRight(2);
		} else if (page == "F-PLNA" or page == "F-PLNB") {
			canvas_mcdu.myFpln[i].pushButtonRight(2);
		} else if (page == "NOTIFICATION") {
			var result = atsu.notificationSystem.notify();
			if (result == 1) {
				mcdu_message(i, "NOT ALLOWED");
			}
		} else if (page == "COMMMENU") {
			pageNode[i].setValue("COMPANYCALL");
		} else if (page == "AOCMENU") {
			pageNode[i].setValue("WEATHERREQ");
		} else if (page == "DATAMODE") {
			atsu.AOC.server.setValue("noaa");
			acconfig.writeSettings();
		} else if (page == "ATIS") {
			if (atsu.ATISInstances[1].station != nil and atsu.ATISInstances[1].sent != 1) {
				atsu.ATISInstances[1].sendReq(i);
			} else {
				mcdu_message(i, "NOT ALLOWED");
			}
		} else if (page == "MCDUTEXT") {
			atsu.freeTexts[i].selection = 4;
			atsu.freeTexts[i].changed = 1;
		}  else {
			mcdu_message(i, "NOT ALLOWED");
		}
	} else if (btn == "3") {
		if (page == "INITA") {
			initInputA("R3",i);
		} else if (page == "INITB") {
			initInputB("R3",i);
		} else if (page == "FUELPRED") {
			fuelPredInput("R3",i);
		} else if (page == "PERFTO") {
			perfTOInput("R3",i);
		} else if (page == "PERFAPPR") {
			perfAPPRInput("R3",i);
		} else if (page == "PRINTFUNC") {
			printInput("R3",i);
		} else if (page == "PRINTFUNC2") {
			printInput2("R3",i);
		} else if (page == "DEPARTURE") {
			canvas_mcdu.myDeparture[i].depPushbuttonRight(3);
		} else if (page == "ARRIVAL") {
			canvas_mcdu.myArrival[i].arrPushbuttonRight(3);
		} else if (page == "LATREV") {
			if (canvas_mcdu.myLatRev[i].type != 2) {
				canvas_mcdu.myLatRev[i].nextWpt();
			} else {
				mcdu_message(i, "NOT ALLOWED");
			}
		} else if (page == "F-PLNA" or page == "F-PLNB") {
			canvas_mcdu.myFpln[i].pushButtonRight(3);
		} else if (page == "AOCMENU") {
			if (canvas_mcdu.myReceivedMessages[i] != nil) {
				canvas_mcdu.myReceivedMessages[i].del();
			}
			canvas_mcdu.myReceivedMessages[i] = nil;
			canvas_mcdu.myReceivedMessages[i] = receivedMessagesPage.new(i);
			pageNode[i].setValue("RECEIVEDMSGS");
		} else if (page == "DATAMODE") {
			atsu.AOC.server.setValue("vatsim");
			acconfig.writeSettings();
		} else if (page == "ATIS") {
			if (atsu.ATISInstances[2].station != nil and atsu.ATISInstances[2].sent != 1) {
				atsu.ATISInstances[2].sendReq(i);
			} else {
				mcdu_message(i, "NOT ALLOWED");
			}
		} else if (page == "MCDUTEXT") {
			atsu.freeTexts[i].selection = 5;
			atsu.freeTexts[i].changed = 1;
		} else if (page == "ATCMENU") {
			pageNode[i].setValue("MCDUTEXT");
		} else {
			mcdu_message(i, "NOT ALLOWED");
		}
	} else if (btn == "4") {
		if (page == "INITA") {
			initInputA("R4",i);
		} else if (page == "FUELPRED") {
			fuelPredInput("R4",i);
		} else if (page == "WINDCRZ") {
			if (canvas_mcdu.myCLBWIND[i] == nil) {
				canvas_mcdu.myCLBWIND[i] = windCLBPage.new(i);
			} else {
				canvas_mcdu.myCLBWIND[i].reload();
			}
			pageNode[i].setValue("WINDCLB");
		} else if (page == "WINDDES") {
			if (fmgc.flightPlanController.temporaryFlag[i]) {
				if (fmgc.FMGCInternal.toFromSet and size(fmgc.windController.nav_indicies[i]) > 0) {
					if (canvas_mcdu.myCRZWIND[i] != nil) {
						canvas_mcdu.myCRZWIND[i].del();
					}
					canvas_mcdu.myCRZWIND[i] = nil;
					canvas_mcdu.myCRZWIND[i] = windCRZPage.new(i, fmgc.flightPlanController.flightplans[i].getWP(fmgc.windController.nav_indicies[i][0]), 0);
				} else {
					if (canvas_mcdu.myCRZWIND[i] == nil) {
						canvas_mcdu.myCRZWIND[i] = windCRZPage.new(i, nil, nil);
					} else {
						canvas_mcdu.myCRZWIND[i].reload();
					}
				}
			} else {
				if (fmgc.FMGCInternal.toFromSet and size(fmgc.windController.nav_indicies[2]) > 0) {
					if (canvas_mcdu.myCRZWIND[i] != nil) {
						canvas_mcdu.myCRZWIND[i].del();
					}
					canvas_mcdu.myCRZWIND[i] = nil;
					canvas_mcdu.myCRZWIND[i] = windCRZPage.new(i, fmgc.flightPlanController.flightplans[2].getWP(fmgc.windController.nav_indicies[2][0]), 0);
				} else {
					if (canvas_mcdu.myCRZWIND[i] == nil) {
						canvas_mcdu.myCRZWIND[i] = windCRZPage.new(i, nil, nil);
					} else {
						canvas_mcdu.myCRZWIND[i].reload();
					}
				}
			}
			pageNode[i].setValue("WINDCRZ");
		} else if (find("PROG",page) != -1) {
			progGENInput("R4",i);
		} else if (page == "PERFTO") {
			perfTOInput("R4",i);
		} else if (page == "PERFAPPR") {
			perfAPPRInput("R4",i);
		} else if (page == "RADNAV") {
			radnavInput("R4",i);
		} else if (page == "PRINTFUNC2") {
			printInput2("R4",i);
		} else if (page == "DEPARTURE") {
			canvas_mcdu.myDeparture[i].depPushbuttonRight(4);
		} else if (page == "ARRIVAL") {
			canvas_mcdu.myArrival[i].arrPushbuttonRight(4);
		} else if (page == "F-PLNA" or page == "F-PLNB") {
			canvas_mcdu.myFpln[i].pushButtonRight(4);
		} else if (page == "ATIS") {
			if (atsu.ATISInstances[3].station != nil and atsu.ATISInstances[3].sent != 1) {
				atsu.ATISInstances[3].sendReq(i);
			} else {
				mcdu_message(i, "NOT ALLOWED");
			}
		} else {
			mcdu_message(i, "NOT ALLOWED");
		}
	} else if (btn == "5") {
		if (page == "INITA") {
			initInputA("R5",i);
		} else if (page == "INITB") {
			initInputB("R5",i);
		} else if (page == "WINDCLB") {
			if (fmgc.flightPlanController.temporaryFlag[i]) {
				if (fmgc.FMGCInternal.toFromSet and size(fmgc.windController.nav_indicies[i]) > 0) {
					if (canvas_mcdu.myCRZWIND[i] != nil) {
						canvas_mcdu.myCRZWIND[i].del();
					}
					canvas_mcdu.myCRZWIND[i] = nil;
					canvas_mcdu.myCRZWIND[i] = windCRZPage.new(i, fmgc.flightPlanController.flightplans[i].getWP(fmgc.windController.nav_indicies[i][0]), 0);
				} else {
					if (canvas_mcdu.myCRZWIND[i] == nil) {
						canvas_mcdu.myCRZWIND[i] = windCRZPage.new(i, nil, nil);
					} else {
						canvas_mcdu.myCRZWIND[i].reload();
					}
				}
			} else {
				if (fmgc.FMGCInternal.toFromSet and size(fmgc.windController.nav_indicies[2]) > 0) {
					if (canvas_mcdu.myCRZWIND[i] != nil) {
						canvas_mcdu.myCRZWIND[i].del();
					}
					canvas_mcdu.myCRZWIND[i] = nil;
					canvas_mcdu.myCRZWIND[i] = windCRZPage.new(i, fmgc.flightPlanController.flightplans[2].getWP(fmgc.windController.nav_indicies[2][0]), 0);
				} else {
					if (canvas_mcdu.myCRZWIND[i] == nil) {
						canvas_mcdu.myCRZWIND[i] = windCRZPage.new(i, nil, nil);
					} else {
						canvas_mcdu.myCRZWIND[i].reload();
					}
				}
			}
			pageNode[i].setValue("WINDCRZ");
		} else if (page == "WINDCRZ") {
			if (canvas_mcdu.myDESWIND[i] == nil) {
				canvas_mcdu.myDESWIND[i] = windDESPage.new(i, "");
			} else {
				canvas_mcdu.myDESWIND[i].reload();
			}
			pageNode[i].setValue("WINDDES");
		} else if (page == "STATUS") {
			statusInput("R5",i);
		} else if (page == "PERFTO") {
			perfTOInput("R5",i);
		} else if (page == "PERFAPPR") {
			perfAPPRInput("R5",i);
		} else if (page == "PERFGA") {
			perfGAInput("R5",i);
		} else if (page == "RADNAV") {
			radnavInput("R5",i);
		} else if (page == "DATA") {
			dataInput("R5",i);
		} else if (page == "DEPARTURE") {
			canvas_mcdu.myDeparture[i].depPushbuttonRight(5);
		} else if (page == "ARRIVAL") {
			canvas_mcdu.myArrival[i].arrPushbuttonRight(5);
		} else if (page == "F-PLNA" or page == "F-PLNB") {
			canvas_mcdu.myFpln[i].pushButtonRight(5);
		} else if (page == "LATREV") {
			if (canvas_mcdu.myLatRev[i].type == 3) {
				if (canvas_mcdu.myAirways[i] != nil) {
					canvas_mcdu.myAirways[i].del();
				}
				canvas_mcdu.myAirways[i] = nil;
				canvas_mcdu.myAirways[i] = airwaysPage.new(i, canvas_mcdu.myLatRev[i].wpt);
				pageNode[i].setValue("AIRWAYS");	
			} else {
				mcdu_message(i, "NOT ALLOWED");
			}
		} else if (page == "ATCMENU") {
			pageNode[i].setValue("CONNECTSTATUS");
		} else if (page == "FLTLOG") {
			pageNode[i].setValue("SENSORS");
		} else if (page == "WEATHERREQ") {
			var result = atsu.AOC.sendReq(i);
			if (result == 1) {
				mcdu_message(i, "NOT ALLOWED");
			} elsif (result == 3) {
				mcdu.mcdu_message(i, "VHF3 VOICE MSG NOT GEN");
			} elsif (result == 4) {
				mcdu.mcdu_message(i, "NO COMM MSG NOT GEN");
			}  else {
				pageNode[i].setValue("AOCMENU");
			}
		} else if (page == "VOICEDIRECTORY") {
			for (var i = 0; i < 3; i = i + 1) {
				if (getprop("/systems/radio/rmp[" ~ i ~ "]/sel_chan") == "vhf3") {
					rmp.transfer(i + 1);
				}
			}
		} else if (page == "AOCMENU") {
			pageNode[i].setValue("AOCCONFIG");
		} else {
			mcdu_message(i, "NOT ALLOWED");
		}
	} else if (btn == "6") {
		if (page == "INITA") {
			initInputA("R6",i);
		} else if (page == "IRSINIT") {
			initInputIRS("R6",i);
		} else if (page == "WINDCLB") {
			canvas_mcdu.myCLBWIND[i].pushButtonRight(6);
		} else if (page == "WINDCRZ") {
			canvas_mcdu.myCRZWIND[i].pushButtonRight(6);
		} else if (page == "WINDDES") {
			canvas_mcdu.myDESWIND[i].pushButtonRight(6);
		} else if (page == "WINDHIST") {
			canvas_mcdu.myHISTWIND[i].pushButtonRight(6);
		} else if (page == "PERFTO") {
			perfTOInput("R6",i);
		} else if (page == "PERFCLB") {
			perfCLBInput("R6",i);
		} else if (page == "PERFCRZ") {
			perfCRZInput("R6",i);
		} else if (page == "PERFDES") {
			perfDESInput("R6",i);
		} else if (page == "PERFAPPR") {
			perfAPPRInput("R6",i);
		} else if ((page == "DATA") or (page == "PRINTFUNC") or (page == "PRINTFUNC2")) {
			mcdu_message(i, "AOC DISABLED");
		} else if (page == "INITA") {
			initInputA("R6",i);
		} else if (page == "F-PLNA" or page == "F-PLNB") {
			canvas_mcdu.myFpln[i].pushButtonRight(6);
		} else if (page == "VERTREV") {
			pageNode[i].setValue("F-PLNA");
		} else if (page == "DIRTO") {
			canvas_mcdu.myDirTo[i].fieldR6();
		} else if (page == "PILOTWP") {
			if (canvas_mcdu.myPilotWP[i] != nil) {
				if (fmgc.WaypointDatabase.confirm[i]) {
					fmgc.WaypointDatabase.confirm[i] = 0;
					canvas_mcdu.myPilotWP[i].deleteCmd();
				} else {
					fmgc.WaypointDatabase.confirm[i] = 1;
					canvas_mcdu.myPilotWP[i].deleteCmd();
				}
			}
		} else if (page == "NOTIFICATION") {
			pageNode[i].setValue("CONNECTSTATUS");
		} else if (page == "MCDUTEXT") {
			# todo transfer to DCDU
			pageNode[i].setValue("ATCMENU");
		} else if (page == "ATSUDLINK") {
			pageNode[i].setValue("COMMMENU");
		} else if (page == "CONNECTSTATUS") {
			pageNode[i].setValue("NOTIFICATION");
		} else if (page == "AOCMENU") {
			msg = mcdu.ReceivedMessagesDatabase.firstUnviewed();
			if (msg != -99) {
				canvas_mcdu.myReceivedMessages[i] = receivedMessagesPage.new(i);
				canvas_mcdu.myReceivedMessage[i] = receivedMessagePage.new(i, msg);
				pageNode[i].setValue("RECEIVEDMSG");
			}
		} else {
			mcdu_message(i, "NOT ALLOWED");
		}
	}
}

var arrowbutton = func(btn, i) {
	page = pageNode[i].getValue();
	if (btn == "left") {
		if (page == "DATA") {
			pageNode[i].setValue("DATA2");
		} else if (page == "DATA2") {
			pageNode[i].setValue("DATA");
		} else if (page == "INITA") {
			if (pts.Engines.Engine.state[0].getValue() != 3 and pts.Engines.Engine.state[1].getValue() != 3) {
				pageNode[i].setValue("INITB");
			} else {
				pageNode[i].setValue("FUELPRED");
			}
		} else if (page == "INITB" or page == "FUELPRED") {
			pageNode[i].setValue("INITA");
		} else if (page == "PRINTFUNC") {
			pageNode[i].setValue("PRINTFUNC2");
		} else if (page == "PRINTFUNC2") {
			pageNode[i].setValue("PRINTFUNC");
		} else if (page == "DEPARTURE") {
			canvas_mcdu.myDeparture[i].scrollLeft();
		} else if (page == "ARRIVAL") {
			canvas_mcdu.myArrival[i].scrollLeft();
		} else if (page == "PILOTWP") {
			canvas_mcdu.myPilotWP[i].scrollLeft();
		} else if (page == "RECEIVEDMSGS") {
			canvas_mcdu.myReceivedMessages[i].scrollLeft();
		} else if (page == "RECEIVEDMSG") {
			canvas_mcdu.myReceivedMessage[i].scrollLeft();
		} else if (page == "ATCMENU") {
			pageNode[i].setValue("ATCMENU2");
		} else if (page == "ATCMENU2") {
			pageNode[i].setValue("ATCMENU");
		}
	} else if (btn == "right") {
		if (page == "DATA") {
			pageNode[i].setValue("DATA2");
		} else if (page == "DATA2") {
			pageNode[i].setValue("DATA");
		} else if (page == "INITA") {
			if (pts.Engines.Engine.state[0].getValue() != 3 and pts.Engines.Engine.state[1].getValue() != 3) {
				pageNode[i].setValue("INITB");
			} else {
				pageNode[i].setValue("FUELPRED");
			}
		} else if (page == "INITB" or page == "FUELPRED") {
			pageNode[i].setValue("INITA");
		} else if (page == "PRINTFUNC") {
			pageNode[i].setValue("PRINTFUNC2");
		} else if (page == "PRINTFUNC2") {
			pageNode[i].setValue("PRINTFUNC");
		} else if (page == "DEPARTURE") {
			canvas_mcdu.myDeparture[i].scrollRight();
		} else if (page == "ARRIVAL") {
			canvas_mcdu.myArrival[i].scrollRight();
		} else if (page == "PILOTWP") {
			canvas_mcdu.myPilotWP[i].scrollRight();
		} else if (page == "RECEIVEDMSGS") {
			canvas_mcdu.myReceivedMessages[i].scrollRight();
		} else if (page == "RECEIVEDMSG") {
			canvas_mcdu.myReceivedMessage[i].scrollRight();
		} else if (page == "ATCMENU") {
			pageNode[i].setValue("ATCMENU2");
		} else if (page == "ATCMENU2") {
			pageNode[i].setValue("ATCMENU");
		}
	} else if (btn == "up") {
		if (page == "F-PLNA" or page == "F-PLNB") {
			canvas_mcdu.myFpln[i].scrollUp();
		} else if (page == "DEPARTURE") {
			canvas_mcdu.myDeparture[i].scrollUp();
		} else if (page == "ARRIVAL") {
			canvas_mcdu.myArrival[i].scrollUp();
		} else if (page == "DIRTO") {
			canvas_mcdu.myDirTo[i].scrollUp();
		} else if (page == "IRSINIT") {
			initInputIRS("up",i);
		} else if (page == "WINDCRZ") {
			canvas_mcdu.myCRZWIND[i].pushButtonUp();
		} else if (page == "ATISDETAIL") {
			canvas_mcdu.myAtis[i].scrollUp();
		}
	} else if (btn == "down") {
		if (page == "F-PLNA" or page == "F-PLNB") {
			canvas_mcdu.myFpln[i].scrollDn();
		} else if (page == "DEPARTURE") {
			canvas_mcdu.myDeparture[i].scrollDn();
		} else if (page == "ARRIVAL") {
			canvas_mcdu.myArrival[i].scrollDn();
		} else if (page == "DIRTO") {
			canvas_mcdu.myDirTo[i].scrollDn();
		} else if (page == "IRSINIT") {
			initInputIRS("down",i);
		} else if (page == "WINDCRZ") {
			canvas_mcdu.myCRZWIND[i].pushButtonDown();
		} else if (page == "ATISDETAIL") {
			canvas_mcdu.myAtis[i].scrollDown();
		}
	}
}

var pagebutton = func(btn, i) {
	page = pageNode[i].getValue();
	setprop("/MCDU[" ~ i ~ "]/scratchpad-color", "wht");
	if (page != "MCDU") {

		# A more flexible system/page tracking for future system expansion
		if (getprop("/MCDU[" ~ i ~ "]/active-system") == "fmgc") setprop("/MCDU[" ~ i ~ "]/last-fmgc-page", page);
		else if (getprop("/MCDU[" ~ i ~ "]/active-system") == "atsu") setprop("/MCDU[" ~ i ~ "]/last-atsu-page", page);
		if (btn == "atc") setprop("/MCDU[" ~ i ~ "]/active-system","atsu");
		else setprop("/MCDU[" ~ i ~ "]/active-system","fmgc");

		if (btn == "radnav") {
			pageNode[i].setValue("RADNAV");			
		} else if (btn == "prog") {
			if (fmgc.FMGCInternal.phase == 0) {
				pageNode[i].setValue("PROGPREF");
			} else if (fmgc.FMGCInternal.phase == 1) {
				pageNode[i].setValue("PROGTO");
			} else if (fmgc.FMGCInternal.phase == 2) {
				pageNode[i].setValue("PROGCLB");
			} else if (fmgc.FMGCInternal.phase == 3) {
				pageNode[i].setValue("PROGCRZ");
			} else if (fmgc.FMGCInternal.phase == 4) {
				pageNode[i].setValue("PROGDES");
			} else if (fmgc.FMGCInternal.phase == 5 or fmgc.FMGCInternal.phase == 6) {
				pageNode[i].setValue("PROGAPPR");
			} else if (fmgc.FMGCInternal.phase == 7) {
				pageNode[i].setValue("PROGDONE");
			}
		} else if (btn == "perf") {
			if (fmgc.FMGCInternal.phase == 0 or fmgc.FMGCInternal.phase == 1) {
				pageNode[i].setValue("PERFTO");
			} else if (fmgc.FMGCInternal.phase == 2) {
				pageNode[i].setValue("PERFCLB");
			} else if (fmgc.FMGCInternal.phase == 3) {
				pageNode[i].setValue("PERFCRZ");
			} else if (fmgc.FMGCInternal.phase == 4) {
				pageNode[i].setValue("PERFDES");
			} else if (fmgc.FMGCInternal.phase == 5) {
				pageNode[i].setValue("PERFAPPR");
			} else if (fmgc.FMGCInternal.phase == 6) {
				pageNode[i].setValue("PERFGA");
			} else if (fmgc.FMGCInternal.phase == 7) {
				fmgc.reset_FMGC();
			}
		} else if (btn == "init") {
			if (fmgc.FMGCInternal.phase == 7) {
				fmgc.reset_FMGC();
			}
			pageNode[i].setValue("INITA");
		} else if (btn == "data") {
			pageNode[i].setValue("DATA");
		} else if (btn == "mcdu") {
			#var page = page;
			#if (page != "ATSUDLINK" and page != "AOCMENU" and page != "AOCCONFIG" and page != "WEATHERREQ" and page != "WEATHERTYPE" and page != "RECEIVEDMSGS" and page != "RECEIVEDMSG" and page != "ATCMENU" and page != "ATCMENU2" and page != "MCDUTEXT" and page != "NOTIFICATION" and page != "CONNECTSTATUS" and page != "COMPANYCALL" and page != "VOICEDIRECTORY" and page != "DATAMODE" and page != "COMMMENU" and page != "COMMSTATUS" and page != "COMMINIT" and page != "ATIS" and page != "ATISDETAIL") {
			#if (getprop("/MCDU[0]/active-system") == "fmgc") {
			#	setprop("/MCDU[" ~ i ~ "]/last-fmgc-page", page);
			#} else {
			#	#setprop("/MCDU[" ~ i ~ "]/last-atsu-page", page);
			#}
			mcdu_message(i, "SELECT DESIRED SYSTEM");
			pageNode[i].setValue("MCDU");
		} else if (btn == "f-pln" or btn == "airport") {
			if (canvas_mcdu.myFpln[i] == nil) {
				canvas_mcdu.myFpln[i] = fplnPage.new(2, i);
			}
			if (btn == "airport") {
				if (fmgc.FMGCInternal.phase == 0 or fmgc.FMGCInternal.phase == 1) {
					canvas_mcdu.myFpln[i].scroll = 0;
				} else {
					if (fmgc.flightPlanController.temporaryFlag[i]) {
						canvas_mcdu.myFpln[i].scroll = fmgc.flightPlanController.arrivalIndex[i];
					} else {
						canvas_mcdu.myFpln[i].scroll = fmgc.flightPlanController.arrivalIndex[2];
					}
				}
			} else {
				canvas_mcdu.myFpln[i].scroll = 0;
			}
			pageNode[i].setValue("F-PLNA");
			
		} else if (btn == "fuel-pred") {
			pageNode[i].setValue("FUELPRED");
		} else if (btn == "dirto") {
			if (fmgc.flightPlanController.temporaryFlag[i] and !dirToFlag) {
				mcdu_message(i, "INSERT/ERASE TMPY FIRST");
				return;
			} elsif (canvas_mcdu.myDirTo[i] == nil) {
				canvas_mcdu.myDirTo[i] = dirTo.new(i);
			}
			pageNode[i].setValue("DIRTO");
		} else if (btn == "atc") {
			if (getprop("/MCDU[" ~ i ~ "]/atsu-active") != 2) {
				mcdu_message(i, "WAIT FOR SYSTEM RESPONSE");
				setprop("/MCDU[" ~ i ~ "]/atsu-active", 1);
				settimer(func(){
					pageNode[i].setValue("ATCMENU");
					mcdu_scratchpad.scratchpads[i].empty();
					setprop("/MCDU[" ~ i ~ "]/atsu-active", 2);					
				}, 2);
			} else {
				pageNode[i].setValue("ATCMENU");				
			}
		}
	}
}

var buttonCLRDown = [0,0]; # counter for down event

var button = func(btn, i, event = "") {
	page = pageNode[i].getValue();
	if (page != "MCDU") {
		var scratchpad = mcdu_scratchpad.scratchpads[i].scratchpad;
		if (btn == "SLASH") {
			mcdu_scratchpad.scratchpads[i].addChar("/");
		} else if (btn == "SP") {
			mcdu_scratchpad.scratchpads[i].addChar(" ");
		} else if (btn == "CLR") {
			if (event == "down") {
				if (size(scratchpad) > 0) {
					if (buttonCLRDown[i] > 4) {
						mcdu_scratchpad.scratchpads[i].empty();
					}
					buttonCLRDown[i] = buttonCLRDown[i] + 1;
				}
			}
			else if (event == "" or buttonCLRDown[i]<=4) {
				buttonCLRDown[i] = 0;
				#var scratchpad = mcdu_scratchpad.scratchpads[i].scratchpad;  <- useless??
				if (size(scratchpad) == 0) {
					mcdu_scratchpad.scratchpads[i].addChar("CLR");
				} else {
					mcdu_scratchpad.scratchpads[i].clear();
				}
			} else {  # up with buttonCLRDown[i]>4
				buttonCLRDown[i] = 0;
			}
		} else if (btn == "DOT") {
			mcdu_scratchpad.scratchpads[i].addChar(".");
		} else if (btn == "PLUSMINUS") {
			mcdu_scratchpad.scratchpads[i].addChar("-");
		} else {
			mcdu_scratchpad.scratchpads[i].addChar(btn);
		}
	}
}

var mcdu_message = func(i, string, overrideStr = "") {
	mcdu_scratchpad.scratchpads[i].showTypeI(mcdu_scratchpad.MessageController.getTypeIMsgByText(string));
	mcdu_scratchpad.scratchpads[i].override(overrideStr);
}

# Messagge Type II - TODO 5 messages queue  - remove only on resolve
var mcdu_messageTypeII = func(i, string, overrideStr = "") {
	mcdu_scratchpad.scratchpads[i].showTypeII(mcdu_scratchpad.MessageController.getTypeIIMsgByText(string));
	mcdu_scratchpad.scratchpads[i].override(overrideStr);
}

var screenFlash = func(time, i) {
	page = pageNode[i].getValue();
	pageNode[i].setValue("NONE");
	settimer(func {
		pageNode[i].setValue(page);
	}, time);
}