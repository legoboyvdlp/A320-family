# A3XX mCDU by Joshua Davidson (Octal450), Jonathan Redpath, and Matthew Maring (mattmaring)

# Copyright (c) 2020 Josh Davidson (Octal450)
# Copyright (c) 2020 Matthew Maring (mattmaring)

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
	setprop("/MCDU[" ~ i ~ "]/page", "MCDU");
	
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
	setprop("/FMGC/internal/zfw", 0);
	setprop("/FMGC/internal/zfw-set", 0);
	setprop("/FMGC/internal/zfwcg", 25.0);
	setprop("/FMGC/internal/zfwcg-set", 0);
	setprop("/FMGC/internal/block", 0.0);
	setprop("/FMGC/internal/block-set", 0);
	setprop("/FMGC/internal/taxi-fuel", 0.4);
	setprop("/FMGC/internal/taxi-fuel-set", 0);
	setprop("/FMGC/internal/trip-fuel", 0);
	setprop("/FMGC/internal/trip-time", "0000");
	setprop("/FMGC/internal/rte-rsv", 0);
	setprop("/FMGC/internal/rte-rsv-set", 0);
	setprop("/FMGC/internal/rte-percent", 5.0);
	setprop("/FMGC/internal/rte-percent-set", 0);
	setprop("/FMGC/internal/alt-fuel", 0);
	setprop("/FMGC/internal/alt-fuel-set", 0);
	setprop("/FMGC/internal/alt-time", "0000");
	setprop("/FMGC/internal/final-fuel", 0);
	setprop("/FMGC/internal/final-fuel-set", 0);
	setprop("/FMGC/internal/final-time", "0030");
	setprop("/FMGC/internal/final-time-set", 0);
	setprop("/FMGC/internal/min-dest-fob", 0);
	setprop("/FMGC/internal/min-dest-fob-set", 0);
	setprop("/FMGC/internal/tow", 0);
	setprop("/FMGC/internal/lw", 0);
	setprop("/FMGC/internal/trip-wind", "HD000");
	setprop("/FMGC/internal/trip-wind-value", 0);
	setprop("/FMGC/internal/fffq-sensor", "FF+FQ");
	setprop("/FMGC/internal/extra-fuel", 0);
	setprop("/FMGC/internal/extra-time", "0000");
	setprop("/FMGC/internal/fuel-request-set", 0);
	setprop("/FMGC/internal/block-calculating", 0);
	setprop("/FMGC/internal/block-confirmed", 0);
	setprop("/FMGC/internal/fuel-calculating", 0);
	
	# FUELPRED
	setprop("/FMGC/internal/alt-airport", "");
	setprop("/FMGC/internal/pri-utc", "0000");
	setprop("/FMGC/internal/alt-utc", "0000");
	setprop("/FMGC/internal/pri-efob", 0);
	setprop("/FMGC/internal/alt-efob", 0);
	setprop("/FMGC/internal/fob", 0);
	setprop("/FMGC/internal/fuel-pred-gw", 0);
	setprop("/FMGC/internal/cg", 0);
	
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
	
	setprop("FMGC/internal/accel-agl-ft", "1500"); #eventually set to 1500 above runway
	setprop("/MCDUC/thracc-set", 0);
	setprop("FMGC/internal/to-flap", 0);
	setprop("FMGC/internal/to-ths", "0.0");
	setprop("FMGC/internal/flap-ths-set", 0);
	setprop("FMGC/internal/flex", 0);
	setprop("FMGC/internal/flex-set", 0);
	setprop("FMGC/internal/eng-out-reduc", "1500");
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
	setprop("/FMGC/internal/vapp-speed-set", 0);
	setprop("/FMGC/internal/final", "");
	setprop("/FMGC/internal/baro", 99999);
	setprop("/FMGC/internal/radio", 99999);
	setprop("/FMGC/internal/radio-no", 0);
	setprop("/FMGC/internal/ldg-elev", 0);
	setprop("/FMGC/internal/ldg-config-3-set", 0);
	setprop("/FMGC/internal/ldg-config-f-set", 1);
	
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
	if (btn == "1") {
		if (getprop("/MCDU[" ~ i ~ "]/page") == "MCDU") {
			if (getprop("/MCDU[" ~ i ~ "]/atsu-active") == 1) {
				mcdu_message(i, "NOT ALLOWED");
			} else {
				if (getprop("/MCDU[" ~ i ~ "]/active") != 2) {
					mcdu_message(i, "WAIT FOR SYSTEM RESPONSE");
					setprop("/MCDU[" ~ i ~ "]/active", 1);
					settimer(func(){
						setprop("/MCDU[" ~ i ~ "]/page", getprop("/MCDU[" ~ i ~ "]/last-fmgc-page"));
						mcdu_scratchpad.scratchpads[i].empty();
						setprop("/MCDU[" ~ i ~ "]/active", 2);
					}, 2);
				} else {
					setprop("/MCDU[" ~ i ~ "]/page", getprop("/MCDU[" ~ i ~ "]/last-fmgc-page"));
					mcdu_scratchpad.scratchpads[i].empty();
				}
			}
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "IRSINIT") {
			initInputIRS("L1",i);
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "INITB") {
			initInputB("L1",i);
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "WINDCLB") {
			canvas_mcdu.myCLBWIND[i].pushButtonLeft(1);
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "WINDCRZ") {
			canvas_mcdu.myCRZWIND[i].pushButtonLeft(1);
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "WINDDES") {
			canvas_mcdu.myDESWIND[i].pushButtonLeft(1);
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "PROGTO") {
			progTOInput("L1",i);
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "PROGCLB") {
			progCLBInput("L1",i);
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "PROGCRZ") {
			progCRZInput("L1",i);
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "PROGDES") {
			progDESInput("L1",i);
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "PERFTO") {
			perfTOInput("L1",i);
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "PERFAPPR") {
			perfAPPRInput("L1",i);
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "RADNAV") {
			radnavInput("L1",i);
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "DATA") {
			dataInput("L1",i);
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "PRINTFUNC") {
			printInput("L1",i);
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "PRINTFUNC2") {
			printInput2("L1",i);
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "LATREV") {
			if (canvas_mcdu.myLatRev[i].type == 0) {
				if (canvas_mcdu.myDeparture[i] != nil) {
					canvas_mcdu.myDeparture[i].del();
				}
				canvas_mcdu.myDeparture[i] = nil;
				canvas_mcdu.myDeparture[i] = departurePage.new(canvas_mcdu.myLatRev[i].title[2], i);
				setprop("/MCDU[" ~ i ~ "]/page", "DEPARTURE");
			} else {
				mcdu_message(i, "NOT ALLOWED");
			}
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "F-PLNA" or getprop("/MCDU[" ~ i ~ "]/page") == "F-PLNB") {
			canvas_mcdu.myFpln[i].pushButtonLeft(1);
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "DIRTO") {
			canvas_mcdu.myDirTo[i].fieldL1(mcdu_scratchpad.scratchpads[i].scratchpad);
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "DUPLICATENAMES") {
			canvas_mcdu.myDuplicate[i].pushButtonLeft(1);
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "ATSUDLINK") {
			setprop("/MCDU[" ~ i ~ "]/page", "ATCMENU");
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "COMMMENU") {
			setprop("/MCDU[" ~ i ~ "]/page", "COMMINIT");
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "COMPANYCALL") {
			if (atsu.CompanyCall.frequency != 999.99) {
				atsu.CompanyCall.tune();
			} else {
				mcdu_message(i, "NOT ALLOWED");
			}
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "WEATHERREQ") {
			setprop("/MCDU[" ~ i ~ "]/page", "WEATHERTYPE");
		}  else if (getprop("/MCDU[" ~ i ~ "]/page") == "WEATHERTYPE") {
			atsu.AOC.selectedType = "HOURLY WX";
			setprop("/MCDU[" ~ i ~ "]/page", "WEATHERREQ");
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "RECEIVEDMSGS") {
			canvas_mcdu.myReceivedMessages[i].leftKey(1);
		} else {
			mcdu_message(i, "NOT ALLOWED");
		}
	} else if (btn == "2") {
		if (getprop("/MCDU[" ~ i ~ "]/page") == "MCDU") {
			if (getprop("/MCDU[" ~ i ~ "]/active") == 1) {
				mcdu_message(i, "NOT ALLOWED");
			} else {
				if (getprop("/MCDU[" ~ i ~ "]/atsu-active") != 2) {
					mcdu_message(i, "WAIT FOR SYSTEM RESPONSE");
					setprop("/MCDU[" ~ i ~ "]/atsu-active", 1);
					settimer(func(){
						setprop("/MCDU[" ~ i ~ "]/page", getprop("/MCDU[" ~ i ~ "]/last-atsu-page"));
						mcdu_scratchpad.scratchpads[i].empty();
						setprop("/MCDU[" ~ i ~ "]/atsu-active", 2);
					}, 2);
				} else {
					setprop("/MCDU[" ~ i ~ "]/page", getprop("/MCDU[" ~ i ~ "]/last-atsu-page"));
					mcdu_scratchpad.scratchpads[i].empty();
				}
			}
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "INITA") {
			initInputA("L2",i);
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "WINDCLB") {
			canvas_mcdu.myCLBWIND[i].pushButtonLeft(2);
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "WINDCRZ") {
			canvas_mcdu.myCRZWIND[i].pushButtonLeft(2);
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "WINDDES") {
			canvas_mcdu.myDESWIND[i].pushButtonLeft(2);
		} else if (getprop("MCDU[" ~ i ~ "]/page") == "PERFTO") {
			perfTOInput("L2",i);
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "PERFAPPR") {
			perfAPPRInput("L2",i);
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "RADNAV") {
			radnavInput("L2",i);
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "PERFCLB") {
			perfCLBInput("L2",i);
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "PERFCRZ") {
			perfCRZInput("L2",i); 
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "PERFDES") {
			perfDESInput("L2",i); 
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "DATA") {
			dataInput("L2",i);
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "PRINTFUNC") {
			printInput("L2",i);
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "PRINTFUNC2") {
			printInput2("L2",i);
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "F-PLNA" or getprop("/MCDU[" ~ i ~ "]/page") == "F-PLNB") {
			canvas_mcdu.myFpln[i].pushButtonLeft(2);
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "DEPARTURE") {
			canvas_mcdu.myDeparture[i].depPushbuttonLeft(2);
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "ARRIVAL") {
			canvas_mcdu.myArrival[i].arrPushbuttonLeft(2);
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "DIRTO") {
			canvas_mcdu.myDirTo[i].leftFieldBtn(2);
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "DUPLICATENAMES") {
			canvas_mcdu.myDuplicate[i].pushButtonLeft(2);
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "NOTIFICATION") {
			var result = atsu.notificationSystem.inputAirport(mcdu_scratchpad.scratchpads[i].scratchpad);
			if (result == 1) {
				mcdu_message(i, "NOT ALLOWED");
			} elsif (result == 2) {
				mcdu_message(i, "NOT IN DATA BASE");
			} else {
				mcdu_scratchpad.scratchpads[i].empty();
			}
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "COMMMENU") {
			setprop("/MCDU[" ~ i ~ "]/page", "DATAMODE");
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "RECEIVEDMSGS") {
			canvas_mcdu.myReceivedMessages[i].leftKey(2);
		} else {
			mcdu_message(i, "NOT ALLOWED");
		}
	} else if (btn == "3") {
		if (getprop("/MCDU[" ~ i ~ "]/page") == "INITA") {
			initInputA("L3",i);
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "INITB") {
			initInputB("L3",i);
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "FUELPRED") {
			fuelPredInput("L3",i);
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "WINDCLB") {
			canvas_mcdu.myCLBWIND[i].pushButtonLeft(3);
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "WINDCRZ") {
			canvas_mcdu.myCRZWIND[i].pushButtonLeft(3);
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "WINDDES") {
			canvas_mcdu.myDESWIND[i].pushButtonLeft(3);
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "PERFTO") {
			perfTOInput("L3",i);
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "PERFAPPR") {
			perfAPPRInput("L3",i);
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "STATUS") {
			statusInput("L3",i);
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "RADNAV") {
			radnavInput("L3",i);
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "PRINTFUNC") {
			printInput("L3",i);
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "PRINTFUNC2") {
			printInput2("L3",i);
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "F-PLNA" or getprop("/MCDU[" ~ i ~ "]/page") == "F-PLNB") {
			canvas_mcdu.myFpln[i].pushButtonLeft(3);
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "DEPARTURE") {
			canvas_mcdu.myDeparture[i].depPushbuttonLeft(3);
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "ARRIVAL") {
			canvas_mcdu.myArrival[i].arrPushbuttonLeft(3);
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "DIRTO") {
			canvas_mcdu.myDirTo[i].leftFieldBtn(3);
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "LATREV") {
			if (canvas_mcdu.myLatRev[i].type != 0 and canvas_mcdu.myLatRev[i].type != 1) {
				if (canvas_mcdu.myHold[i] != nil) {
					canvas_mcdu.myHold[i].del();
				}
				canvas_mcdu.myHold[i] = nil;
				canvas_mcdu.myHold[i] = holdPage.new(i, canvas_mcdu.myLatRev[i].wpt);
				setprop("/MCDU[" ~ i ~ "]/page", "HOLD");
			} else {
				mcdu_message(i, "NOT ALLOWED");
			}
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "DUPLICATENAMES") {
			canvas_mcdu.myDuplicate[i].pushButtonLeft(3);
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "COMMMENU") {
			setprop("/MCDU[" ~ i ~ "]/page", "VOICEDIRECTORY");
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "RECEIVEDMSGS") {
			canvas_mcdu.myReceivedMessages[i].leftKey(3);
		} else {
			mcdu_message(i, "NOT ALLOWED");
		}
	} else if (btn == "4") {
		if (getprop("/MCDU[" ~ i ~ "]/page") == "DATA") {
			setprop("/MCDU[" ~ i ~ "]/page", "STATUS");
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "INITB") {
			initInputB("L4",i);
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "FUELPRED") {
			fuelPredInput("L4",i);
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "WINDCLB") {
			canvas_mcdu.myCLBWIND[i].pushButtonLeft(4);
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "WINDCRZ") {
			canvas_mcdu.myCRZWIND[i].pushButtonLeft(4);
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "WINDDES") {
			canvas_mcdu.myDESWIND[i].pushButtonLeft(4);
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "PERFTO") {
			perfTOInput("L4",i);
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "PERFAPPR") {
			perfAPPRInput("L4",i);
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "RADNAV") {
			radnavInput("L4",i);
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "PRINTFUNC2") {
			printInput2("L4",i);
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "F-PLNA" or getprop("/MCDU[" ~ i ~ "]/page") == "F-PLNB") {
			canvas_mcdu.myFpln[i].pushButtonLeft(4);
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "DEPARTURE") {
			canvas_mcdu.myDeparture[i].depPushbuttonLeft(4);
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "ARRIVAL") {
			canvas_mcdu.myArrival[i].arrPushbuttonLeft(4);
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "DIRTO") {
			canvas_mcdu.myDirTo[i].leftFieldBtn(4);
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "DUPLICATENAMES") {
			canvas_mcdu.myDuplicate[i].pushButtonLeft(4);
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "CONNECTSTATUS") {
			if (atsu.ADS.state != 0) {
				atsu.ADS.setState(0);
			} else {
				atsu.ADS.setState(1);
			}
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "VOICEDIRECTORY") {
			if (atsu.CompanyCall.frequency != 999.99) { 
				atsu.CompanyCall.tune(); 
			} else {
				mcdu_message(i, "NOT ALLOWED");
			}
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "RECEIVEDMSGS") {
			canvas_mcdu.myReceivedMessages[i].leftKey(4);
		} else {
			mcdu_message(i, "NOT ALLOWED");
		}
	} else if (btn == "5") {
		if (getprop("/MCDU[" ~ i ~ "]/page") == "INITA") {
			initInputA("L5",i);
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "INITB") {
			initInputB("L5",i);
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "FUELPRED") {
			fuelPredInput("L5",i);
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "WINDCLB") {
			canvas_mcdu.myCLBWIND[i].pushButtonLeft(5);
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "WINDCRZ") {
			canvas_mcdu.myCRZWIND[i].pushButtonLeft(5);
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "WINDDES") {
			canvas_mcdu.myDESWIND[i].pushButtonLeft(5);
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "PERFTO") {
			perfTOInput("L5",i);
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "PERFCLB") {
			perfCLBInput("L5",i);
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "PERFCRZ") {
			perfCRZInput("L5",i);
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "PERFDES") {
			perfDESInput("L5",i);
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "PERFAPPR") {
			perfAPPRInput("L5",i);
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "PERFGA") {
			perfGAInput("L5",i);
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "RADNAV") {
			radnavInput("L5",i);
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "PRINTFUNC") {
			printInput("L5",i);
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "PRINTFUNC2") {
			printInput2("L5",i);
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "DATA") {
			dataInput("L5",i);
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "DATA2") {
			data2Input("L5",i);
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "F-PLNA" or getprop("/MCDU[" ~ i ~ "]/page") == "F-PLNB") {
			canvas_mcdu.myFpln[i].pushButtonLeft(5);
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "DEPARTURE") {
			canvas_mcdu.myDeparture[i].depPushbuttonLeft(5);
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "ARRIVAL") {
			canvas_mcdu.myArrival[i].arrPushbuttonLeft(5);
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "VERTREV") {
			canvas_mcdu.myVertRev[i].pushButtonLeft(5);
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "DIRTO") {
			canvas_mcdu.myDirTo[i].leftFieldBtn(5);
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "DUPLICATENAMES") {
			canvas_mcdu.myDuplicate[i].pushButtonLeft(5);
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "CLOSESTAIRPORT") {
			canvas_mcdu.myClosestAirport[i].manAirportCall(mcdu_scratchpad.scratchpads[i].scratchpad);
			mcdu_scratchpad.scratchpads[i].empty();
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "ATCMENU") {
			setprop("/MCDU[" ~ i ~ "]/page", "NOTIFICATION");
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "RECEIVEDMSGS") {
			canvas_mcdu.myReceivedMessages[i].leftKey(5);
		} else {
			mcdu_message(i, "NOT ALLOWED");
		}
	} else if (btn == "6") {
		if (getprop("/MCDU[" ~ i ~ "]/page") == "INITA") {
			initInputA("L6",i);
		} else if (getprop("MCDU[" ~ i ~ "]/page") == "INITB") {
			initInputB("L6",i);
		} else if (getprop("MCDU[" ~ i ~ "]/page") == "FUELPRED") {
			fuelPredInput("L6",i);
		} else if (getprop("MCDU[" ~ i ~ "]/page") == "IRSINIT") {
			initInputIRS("L6",i);
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "WINDCLB") {
			canvas_mcdu.myCLBWIND[i].pushButtonLeft(6);
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "WINDCRZ") {
			canvas_mcdu.myCRZWIND[i].pushButtonLeft(6);
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "WINDDES") {
			canvas_mcdu.myDESWIND[i].pushButtonLeft(6);
		#} else if (getprop("/MCDU[" ~ i ~ "]/page") == "WINDHIST") {
		#	canvas_mcdu.myHISTWIND[i].pushButtonRight(6);
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "WINDHIST") {
			if (canvas_mcdu.myCLBWIND[i] == nil) {
				canvas_mcdu.myCLBWIND[i] = windCLBPage.new(i);
			} else {
				canvas_mcdu.myCLBWIND[i].reload();
			}
			setprop("MCDU[" ~ i ~ "]/page", "WINDCLB");
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "ROUTESELECTION") {
			initInputROUTESEL("L6",i);
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "PERFCLB") {
			perfCLBInput("L6",i);
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "PERFCRZ") {
			perfCRZInput("L6",i);
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "PERFDES") {
			perfDESInput("L6",i);
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "PERFAPPR") {
			perfAPPRInput("L6",i);
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "PERFGA") {
			perfGAInput("L6",i);
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "PRINTFUNC2") {
			printInput2("L6",i);
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "F-PLNA" or getprop("/MCDU[" ~ i ~ "]/page") == "F-PLNB") {
			canvas_mcdu.myFpln[i].pushButtonLeft(6);
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "LATREV" or getprop("/MCDU[" ~ i ~ "]/page") == "VERTREV" or getprop("/MCDU[" ~ i ~ "]/page") == "DUPLICATENAMES") {
			setprop("/MCDU[" ~ i ~ "]/page", "F-PLNA");
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "ARRIVAL") {
			canvas_mcdu.myArrival[i].arrPushbuttonLeft(6);
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "DEPARTURE" or getprop("/MCDU[" ~ i ~ "]/page") == "HOLD" or getprop("/MCDU[" ~ i ~ "]/page") == "AIRWAYS") {
			if (fmgc.flightPlanController.temporaryFlag[i]) {
				setprop("/MCDU[" ~ i ~ "]/page", "F-PLNA");
			} else {
				setprop("/MCDU[" ~ i ~ "]/page", "LATREV");
			}
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "DIRTO") {
			canvas_mcdu.myDirTo[i].fieldL6();
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "CLOSESTAIRPORT") {
			canvas_mcdu.myClosestAirport[i].freeze();
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "AOCMENU" or getprop("/MCDU[" ~ i ~ "]/page") == "ATCMENU" or getprop("/MCDU[" ~ i ~ "]/page") == "ATCMENU2") {
			setprop("/MCDU[" ~ i ~ "]/page", "ATSUDLINK");
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "NOTIFICATION" or getprop("/MCDU[" ~ i ~ "]/page") == "CONNECTSTATUS") {
			setprop("/MCDU[" ~ i ~ "]/page", "ATCMENU");
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "WEATHERREQ" or getprop("/MCDU[" ~ i ~ "]/page") == "RECEIVEDMSGS") {
			setprop("/MCDU[" ~ i ~ "]/page", "AOCMENU");
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "RECEIVEDMSG") {
			setprop("/MCDU[" ~ i ~ "]/page", "RECEIVEDMSGS");
			canvas_mcdu.myReceivedMessages[i].update();
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "COMMMENU") {
			setprop("/MCDU[" ~ i ~ "]/page", "ATSUDLINK");
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "COMMINIT" or getprop("/MCDU[" ~ i ~ "]/page") == "VOICEDIRECTORY" or getprop("/MCDU[" ~ i ~ "]/page") == "DATAMODE"  or getprop("/MCDU[" ~ i ~ "]/page") == "COMMSTATUS" or getprop("/MCDU[" ~ i ~ "]/page") == "COMPANYCALL") {
			setprop("/MCDU[" ~ i ~ "]/page", "COMMMENU");
		} else {
			mcdu_message(i, "NOT ALLOWED");
		}
	}
}

var rskbutton = func(btn, i) {
	if (btn == "1") {
		if (getprop("/MCDU[" ~ i ~ "]/page") == "INITA") {
			initInputA("R1",i);
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "IRSINIT") {
			initInputIRS("R1",i);
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "INITB") {
			initInputB("R1",i);
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "WINDCLB") {
			if (canvas_mcdu.myHISTWIND[i] == nil) {
				canvas_mcdu.myHISTWIND[i] = windHISTPage.new(i);
			} else {
				canvas_mcdu.myHISTWIND[i].reload();
			}
			setprop("MCDU[" ~ i ~ "]/page", "WINDHIST");
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "WINDDES") {
			canvas_mcdu.myDESWIND[i].pushButtonRight(1);
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "RADNAV") {
			radnavInput("R1",i);
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "PRINTFUNC") {
			printInput("R1",i);
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "PRINTFUNC2") {
			printInput2("R1",i);
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "LATREV") {
			if (canvas_mcdu.myLatRev[i].type == 1) {
				if (canvas_mcdu.myArrival[i] != nil) {
					canvas_mcdu.myArrival[i].del();
				}
				canvas_mcdu.myArrival[i] = nil;
				canvas_mcdu.myArrival[i] = arrivalPage.new(canvas_mcdu.myLatRev[i].title[2], i);
				canvas_mcdu.myArrival[i]._setupPageWithData();
				setprop("/MCDU[" ~ i ~ "]/page", "ARRIVAL");
			} else {
				mcdu_message(i, "NOT ALLOWED");
			}
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "F-PLNA" or getprop("/MCDU[" ~ i ~ "]/page") == "F-PLNB") {
			canvas_mcdu.myFpln[i].pushButtonRight(1);
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "DATA2") {
			if (fmgc.WaypointDatabase.getCount() > 0) {
				if (canvas_mcdu.myPilotWP[i] != nil) {
					canvas_mcdu.myPilotWP[i].del();
				}
				canvas_mcdu.myPilotWP[i] = nil;
				canvas_mcdu.myPilotWP[i] = pilotWaypointPage.new(i);
				setprop("/MCDU[" ~ i ~ "]/page", "PILOTWP");
			} else {
				mcdu_message(i, "NOT ALLOWED"); # todo spawn new waypoints page
			}
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "COMMMENU") {
			setprop("/MCDU[" ~ i ~ "]/page", "COMMSTATUS");
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "COMPANYCALL") {
			if (atsu.CompanyCall.frequency != 999.99) {
				atsu.CompanyCall.ack();
			} else {
				mcdu_message(i, "NOT ALLOWED");
			}
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "ATSUDLINK") {
			setprop("/MCDU[" ~ i ~ "]/page", "AOCMENU");
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "WEATHERREQ") {
			var result = atsu.AOC.newStation(mcdu_scratchpad.scratchpads[i].scratchpad, i);
			if (result == 1) {
				mcdu_message(i, "NOT ALLOWED");
			} elsif (result == 2) {
				mcdu_message(i, "NOT IN DATA BASE");
			} else {
				mcdu_scratchpad.scratchpads[i].empty();
			}
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "WEATHERTYPE") {
			atsu.AOC.selectedType = "TERM FCST";
			setprop("/MCDU[" ~ i ~ "]/page", "WEATHERREQ");
		} else {
			mcdu_message(i, "NOT ALLOWED");
		}
	} else if (btn == "2") {
		if (getprop("/MCDU[" ~ i ~ "]/page") == "INITB") {
			initInputB("R2",i);
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "PERFAPPR") {
			perfAPPRInput("R2",i);
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "RADNAV") {
			radnavInput("R2",i);
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "PRINTFUNC") {
			printInput("R2",i);
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "PRINTFUNC2") {
			printInput2("R2",i);
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "DEPARTURE") {
			canvas_mcdu.myDeparture[i].depPushbuttonRight(2);
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "ARRIVAL") {
			canvas_mcdu.myArrival[i].arrPushbuttonRight(2);
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "F-PLNA" or getprop("/MCDU[" ~ i ~ "]/page") == "F-PLNB") {
			canvas_mcdu.myFpln[i].pushButtonRight(2);
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "NOTIFICATION") {
			var result = atsu.notificationSystem.notify();
			if (result == 1) {
				mcdu_message(i, "NOT ALLOWED");
			}
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "COMMMENU") {
			setprop("/MCDU[" ~ i ~ "]/page", "COMPANYCALL");
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "AOCMENU") {
			setprop("/MCDU[" ~ i ~ "]/page", "WEATHERREQ");
		} else {
			mcdu_message(i, "NOT ALLOWED");
		}
	} else if (btn == "3") {
		if (getprop("/MCDU[" ~ i ~ "]/page") == "INITA") {
			initInputA("R3",i);
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "INITB") {
			initInputB("R3",i);
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "FUELPRED") {
			fuelPredInput("R3",i);
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "PERFTO") {
			perfTOInput("R3",i);
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "PERFAPPR") {
			perfAPPRInput("R3",i);
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "PRINTFUNC") {
			printInput("R3",i);
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "PRINTFUNC2") {
			printInput2("R3",i);
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "DEPARTURE") {
			canvas_mcdu.myDeparture[i].depPushbuttonRight(3);
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "ARRIVAL") {
			canvas_mcdu.myArrival[i].arrPushbuttonRight(3);
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "LATREV") {
			if (canvas_mcdu.myLatRev[i].type != 2) {
				canvas_mcdu.myLatRev[i].nextWpt();
			} else {
				mcdu_message(i, "NOT ALLOWED");
			}
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "F-PLNA" or getprop("/MCDU[" ~ i ~ "]/page") == "F-PLNB") {
			canvas_mcdu.myFpln[i].pushButtonRight(3);
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "AOCMENU") {
			if (canvas_mcdu.myReceivedMessages[i] != nil) {
				canvas_mcdu.myReceivedMessages[i].del();
			}
			canvas_mcdu.myReceivedMessages[i] = nil;
			canvas_mcdu.myReceivedMessages[i] = receivedMessagesPage.new(i);
			setprop("/MCDU[" ~ i ~ "]/page", "RECEIVEDMSGS");
		} else {
			mcdu_message(i, "NOT ALLOWED");
		}
	} else if (btn == "4") {
		if (getprop("/MCDU[" ~ i ~ "]/page") == "INITA") {
			initInputA("R4",i);
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "FUELPRED") {
			fuelPredInput("R4",i);
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "WINDCRZ") {
			if (canvas_mcdu.myCLBWIND[i] == nil) {
				canvas_mcdu.myCLBWIND[i] = windCLBPage.new(i);
			} else {
				canvas_mcdu.myCLBWIND[i].reload();
			}
			setprop("MCDU[" ~ i ~ "]/page", "WINDCLB");
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "WINDDES") {
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
			setprop("MCDU[" ~ i ~ "]/page", "WINDCRZ");
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "PERFTO") {
			perfTOInput("R4",i);
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "PERFAPPR") {
			perfAPPRInput("R4",i);
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "RADNAV") {
			radnavInput("R4",i);
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "PRINTFUNC2") {
			printInput2("R4",i);
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "DEPARTURE") {
			canvas_mcdu.myDeparture[i].depPushbuttonRight(4);
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "ARRIVAL") {
			canvas_mcdu.myArrival[i].arrPushbuttonRight(4);
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "F-PLNA" or getprop("/MCDU[" ~ i ~ "]/page") == "F-PLNB") {
			canvas_mcdu.myFpln[i].pushButtonRight(4);
		} else {
			mcdu_message(i, "NOT ALLOWED");
		}
	} else if (btn == "5") {
		if (getprop("/MCDU[" ~ i ~ "]/page") == "INITA") {
			initInputA("R5",i);
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "INITB") {
			initInputB("R5",i);
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "WINDCLB") {
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
			setprop("MCDU[" ~ i ~ "]/page", "WINDCRZ");
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "WINDCRZ") {
			if (canvas_mcdu.myDESWIND[i] == nil) {
				canvas_mcdu.myDESWIND[i] = windDESPage.new(i, "");
			} else {
				canvas_mcdu.myDESWIND[i].reload();
			}
			setprop("MCDU[" ~ i ~ "]/page", "WINDDES");
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "STATUS") {
			statusInput("R5",i);
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "PERFTO") {
			perfTOInput("R5",i);
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "PERFAPPR") {
			perfAPPRInput("R5",i);
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "PERFGA") {
			perfGAInput("R5",i);
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "RADNAV") {
			radnavInput("R5",i);
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "DATA") {
			dataInput("R5",i);
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "DEPARTURE") {
			canvas_mcdu.myDeparture[i].depPushbuttonRight(5);
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "ARRIVAL") {
			canvas_mcdu.myArrival[i].arrPushbuttonRight(5);
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "F-PLNA" or getprop("/MCDU[" ~ i ~ "]/page") == "F-PLNB") {
			canvas_mcdu.myFpln[i].pushButtonRight(5);
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "LATREV") {
			if (canvas_mcdu.myLatRev[i].type == 3) {
				if (canvas_mcdu.myAirways[i] != nil) {
					canvas_mcdu.myAirways[i].del();
				}
				canvas_mcdu.myAirways[i] = nil;
				canvas_mcdu.myAirways[i] = airwaysPage.new(i, canvas_mcdu.myLatRev[i].wpt);
				setprop("/MCDU[" ~ i ~ "]/page", "AIRWAYS");	
			} else {
				mcdu_message(i, "NOT ALLOWED");
			}
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "ATCMENU") {
			setprop("/MCDU[" ~ i ~ "]/page", "CONNECTSTATUS");
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "WEATHERREQ") {
			var result = atsu.AOC.sendReq(i);
			if (result == 1) {
				mcdu_message(i, "NOT ALLOWED");
			} else {
				mcdu_scratchpad.scratchpads[i].empty();
			}
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "VOICEDIRECTORY") {
			for (var i = 0; i < 3; i = i + 1) {
				if (getprop("/systems/radio/rmp[" ~ i ~ "]/sel_chan") == "vhf3") {
					rmp.transfer(i + 1);
				}
			}
		} else {
			mcdu_message(i, "NOT ALLOWED");
		}
	} else if (btn == "6") {
		if (getprop("/MCDU[" ~ i ~ "]/page") == "INITA") {
			initInputA("R6",i);
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "IRSINIT") {
			initInputIRS("R6",i);
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "WINDCLB") {
			canvas_mcdu.myCLBWIND[i].pushButtonRight(6);
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "WINDCRZ") {
			canvas_mcdu.myCRZWIND[i].pushButtonRight(6);
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "WINDDES") {
			canvas_mcdu.myDESWIND[i].pushButtonRight(6);
		#} else if (getprop("/MCDU[" ~ i ~ "]/page") == "WINDHIST") {
		#	canvas_mcdu.myHISTWIND[i].pushButtonRight(6);
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "PERFTO") {
			perfTOInput("R6",i);
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "PERFCLB") {
			perfCLBInput("R6",i);
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "PERFCRZ") {
			perfCRZInput("R6",i);
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "PERFDES") {
			perfDESInput("R6",i);
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "PERFAPPR") {
			perfAPPRInput("R6",i);
		} else if ((getprop("/MCDU[" ~ i ~ "]/page") == "DATA") or (getprop("/MCDU[" ~ i ~ "]/page") == "PRINTFUNC") or (getprop("/MCDU[" ~ i ~ "]/page") == "PRINTFUNC2")) {
			mcdu_message(i, "AOC DISABLED");
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "INITA") {
			initInputA("R6",i);
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "F-PLNA" or getprop("/MCDU[" ~ i ~ "]/page") == "F-PLNB") {
			canvas_mcdu.myFpln[i].pushButtonRight(6);
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "VERTREV") {
			setprop("/MCDU[" ~ i ~ "]/page", "F-PLNA");
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "DIRTO") {
			canvas_mcdu.myDirTo[i].fieldR6();
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "PILOTWP") {
			if (canvas_mcdu.myPilotWP[i] != nil) {
				if (fmgc.WaypointDatabase.confirm[i]) {
					fmgc.WaypointDatabase.confirm[i] = 0;
					canvas_mcdu.myPilotWP[i].deleteCmd();
				} else {
					fmgc.WaypointDatabase.confirm[i] = 1;
					canvas_mcdu.myPilotWP[i].deleteCmd();
				}
			}
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "NOTIFICATION") {
			setprop("/MCDU[" ~ i ~ "]/page", "CONNECTSTATUS");
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "ATSUDLINK") {
			setprop("/MCDU[" ~ i ~ "]/page", "COMMMENU");
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "CONNECTSTATUS") {
			setprop("/MCDU[" ~ i ~ "]/page", "NOTIFICATION");
		} else {
			mcdu_message(i, "NOT ALLOWED");
		}
	}
}

var arrowbutton = func(btn, i) {
	if (btn == "left") {
		if (getprop("/MCDU[" ~ i ~ "]/page") == "DATA") {
			setprop("/MCDU[" ~ i ~ "]/page", "DATA2");
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "DATA2") {
			setprop("/MCDU[" ~ i ~ "]/page", "DATA");
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "INITA") {
			if (getprop("engines/engine[0]/state") != 3 and getprop("engines/engine[1]/state") != 3) {
				setprop("/MCDU[" ~ i ~ "]/page", "INITB");
			} else {
				setprop("/MCDU[" ~ i ~ "]/page", "FUELPRED");
			}
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "INITB" or getprop("/MCDU[" ~ i ~ "]/page") == "FUELPRED") {
			setprop("/MCDU[" ~ i ~ "]/page", "INITA");
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "PRINTFUNC") {
			setprop("/MCDU[" ~ i ~ "]/page", "PRINTFUNC2");
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "PRINTFUNC2") {
			setprop("/MCDU[" ~ i ~ "]/page", "PRINTFUNC");
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "DEPARTURE") {
			canvas_mcdu.myDeparture[i].scrollLeft();
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "ARRIVAL") {
			canvas_mcdu.myArrival[i].scrollLeft();
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "PILOTWP") {
			canvas_mcdu.myPilotWP[i].scrollLeft();
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "RECEIVEDMSGS") {
			canvas_mcdu.myReceivedMessages[i].scrollLeft();
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "RECEIVEDMSG") {
			canvas_mcdu.myReceivedMessage[i].scrollLeft();
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "ATCMENU") {
			setprop("/MCDU[" ~ i ~ "]/page", "ATCMENU2");
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "ATCMENU2") {
			setprop("/MCDU[" ~ i ~ "]/page", "ATCMENU");
		}
	} else if (btn == "right") {
		if (getprop("/MCDU[" ~ i ~ "]/page") == "DATA") {
			setprop("/MCDU[" ~ i ~ "]/page", "DATA2");
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "DATA2") {
			setprop("/MCDU[" ~ i ~ "]/page", "DATA");
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "INITA") {
			if (getprop("engines/engine[0]/state") != 3 and getprop("engines/engine[1]/state") != 3) {
				setprop("/MCDU[" ~ i ~ "]/page", "INITB");
			} else {
				setprop("/MCDU[" ~ i ~ "]/page", "FUELPRED");
			}
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "INITB" or getprop("/MCDU[" ~ i ~ "]/page") == "FUELPRED") {
			setprop("/MCDU[" ~ i ~ "]/page", "INITA");
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "PRINTFUNC") {
			setprop("/MCDU[" ~ i ~ "]/page", "PRINTFUNC2");
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "PRINTFUNC2") {
			setprop("/MCDU[" ~ i ~ "]/page", "PRINTFUNC");
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "DEPARTURE") {
			canvas_mcdu.myDeparture[i].scrollRight();
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "ARRIVAL") {
			canvas_mcdu.myArrival[i].scrollRight();
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "PILOTWP") {
			canvas_mcdu.myPilotWP[i].scrollRight();
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "RECEIVEDMSGS") {
			canvas_mcdu.myReceivedMessages[i].scrollRight();
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "RECEIVEDMSG") {
			canvas_mcdu.myReceivedMessage[i].scrollRight();
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "ATCMENU") {
			setprop("/MCDU[" ~ i ~ "]/page", "ATCMENU2");
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "ATCMENU2") {
			setprop("/MCDU[" ~ i ~ "]/page", "ATCMENU");
		}
	} else if (btn == "up") {
		if (getprop("/MCDU[" ~ i ~ "]/page") == "F-PLNA" or getprop("/MCDU[" ~ i ~ "]/page") == "F-PLNB") {
			canvas_mcdu.myFpln[i].scrollUp();
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "DEPARTURE") {
			canvas_mcdu.myDeparture[i].scrollUp();
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "ARRIVAL") {
			canvas_mcdu.myArrival[i].scrollUp();
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "DIRTO") {
			canvas_mcdu.myDirTo[i].scrollUp();
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "IRSINIT") {
			initInputIRS("up",i);
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "WINDCRZ") {
			canvas_mcdu.myCRZWIND[i].pushButtonUp();
		}
	} else if (btn == "down") {
		if (getprop("/MCDU[" ~ i ~ "]/page") == "F-PLNA" or getprop("/MCDU[" ~ i ~ "]/page") == "F-PLNB") {
			canvas_mcdu.myFpln[i].scrollDn();
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "DEPARTURE") {
			canvas_mcdu.myDeparture[i].scrollDn();
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "ARRIVAL") {
			canvas_mcdu.myArrival[i].scrollDn();
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "DIRTO") {
			canvas_mcdu.myDirTo[i].scrollDn();
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "IRSINIT") {
			initInputIRS("down",i);
		} else if (getprop("/MCDU[" ~ i ~ "]/page") == "WINDCRZ") {
			canvas_mcdu.myCRZWIND[i].pushButtonDown();
		}
	}
}

var pagebutton = func(btn, i) {
	setprop("/MCDU[" ~ i ~ "]/scratchpad-color", "wht");
	if (getprop("/MCDU[" ~ i ~ "]/page") != "MCDU") {
		if (btn == "radnav") {
			setprop("/MCDU[" ~ i ~ "]/page", "RADNAV");
		} else if (btn == "prog") {
			if (fmgc.FMGCInternal.phase == 0 or fmgc.FMGCInternal.phase == 1) {
				setprop("MCDU[" ~ i ~ "]/page", "PROGTO");
			} else if (fmgc.FMGCInternal.phase == 2) {
				setprop("MCDU[" ~ i ~ "]/page", "PROGCLB");
			} else if (fmgc.FMGCInternal.phase == 3) {
				setprop("MCDU[" ~ i ~ "]/page", "PROGCRZ");
			} else if (fmgc.FMGCInternal.phase == 4 or fmgc.FMGCInternal.phase == 5 or fmgc.FMGCInternal.phase == 6) {
				setprop("MCDU[" ~ i ~ "]/page", "PROGDES");
			}
		} else if (btn == "perf") {
			if (fmgc.FMGCInternal.phase == 0 or fmgc.FMGCInternal.phase == 1) {
				setprop("MCDU[" ~ i ~ "]/page", "PERFTO");
			} else if (fmgc.FMGCInternal.phase == 2) {
				setprop("MCDU[" ~ i ~ "]/page", "PERFCLB");
			} else if (fmgc.FMGCInternal.phase == 3) {
				setprop("MCDU[" ~ i ~ "]/page", "PERFCRZ");
			} else if (fmgc.FMGCInternal.phase == 4) {
				setprop("MCDU[" ~ i ~ "]/page", "PERFDES");
			} else if (fmgc.FMGCInternal.phase == 5) {
				setprop("MCDU[" ~ i ~ "]/page", "PERFAPPR");
			} else if (fmgc.FMGCInternal.phase == 6) {
				setprop("MCDU[" ~ i ~ "]/page", "PERFGA");
			} else if (fmgc.FMGCInternal.phase == 7) {
				fmgc.reset_FMGC();
			}
		} else if (btn == "init") {
			if (fmgc.FMGCInternal.phase == 7) {
				fmgc.reset_FMGC();
			}
			setprop("/MCDU[" ~ i ~ "]/page", "INITA");
		} else if (btn == "data") {
			setprop("/MCDU[" ~ i ~ "]/page", "DATA");
		} else if (btn == "mcdu") {
			var page = getprop("/MCDU[" ~ i ~ "]/page");
			if (page != "ATSUDLINK" and page != "AOCMENU" and page != "WEATHERREQ" and page != "WEATHERTYPE" and page != "RECEIVEDMSGS" and page != "ATCMENU" and page != "ATCMENU2" and page != "NOTIFICATION" and page != "CONNECTSTATUS" and page != "COMPANYCALL" and page != "VOICEDIRECTORY" and page != "DATAMODE" and page != "COMMMENU" and page != "COMMSTATUS" and page != "COMMINIT") {
				setprop("/MCDU[" ~ i ~ "]/last-fmgc-page", getprop("/MCDU[" ~ i ~ "]/page"));
			} else {
				setprop("/MCDU[" ~ i ~ "]/last-atsu-page", getprop("/MCDU[" ~ i ~ "]/page"));
			}
			mcdu_message(i, "SELECT DESIRED SYSTEM");
			setprop("/MCDU[" ~ i ~ "]/page", "MCDU");
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
			setprop("/MCDU[" ~ i ~ "]/page", "F-PLNA");
			
		} else if (btn == "fuel-pred") {
			setprop("/MCDU[" ~ i ~ "]/page", "FUELPRED");
		} else if (btn == "dirto") {
			if (fmgc.flightPlanController.temporaryFlag[i] and !dirToFlag) {
				mcdu_message(i, "INSERT/ERASE TMPY FIRST");
				return;
			} elsif (canvas_mcdu.myDirTo[i] == nil) {
				canvas_mcdu.myDirTo[i] = dirTo.new(i);
			}
			setprop("/MCDU[" ~ i ~ "]/page", "DIRTO");
		} else if (btn == "atc") {
			if (getprop("/MCDU[" ~ i ~ "]/atsu-active") != 2) {
				mcdu_message(i, "WAIT FOR SYSTEM RESPONSE");
				setprop("/MCDU[" ~ i ~ "]/atsu-active", 1);
				settimer(func(){
					setprop("/MCDU[" ~ i ~ "]/page", "ATCMENU");
					mcdu_scratchpad.scratchpads[i].empty();
					setprop("/MCDU[" ~ i ~ "]/atsu-active", 2);
				}, 2);
			} else {
				setprop("/MCDU[" ~ i ~ "]/page", "ATCMENU");
			}
		}
	}
}

var button = func(btn, i) {
	if (getprop("/MCDU[" ~ i ~ "]/page") != "MCDU") {
		var scratchpad = mcdu_scratchpad.scratchpads[i].scratchpad;
		if (btn == "SLASH") {
			mcdu_scratchpad.scratchpads[i].addChar("/");
		} else if (btn == "SP") {
			mcdu_scratchpad.scratchpads[i].addChar(" ");
		} else if (btn == "CLR") {
			var scratchpad = mcdu_scratchpad.scratchpads[i].scratchpad;
			if (size(scratchpad) == 0) {
				mcdu_scratchpad.scratchpads[i].addChar("CLR");
			} else {
				mcdu_scratchpad.scratchpads[i].clear();
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

var screenFlash = func(time, i) {
	var page = getprop("/MCDU[" ~ i ~ "]/page");
	setprop("/MCDU[" ~ i ~ "]/page", "NONE");
	settimer(func {
		setprop("/MCDU[" ~ i ~ "]/page", page);
	}, time);
}