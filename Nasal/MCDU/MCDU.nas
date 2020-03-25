# A3XX mCDU by Joshua Davidson (Octal450), Jonathan Redpath, and Matthew Maring (hayden2000)

# Copyright (c) 2019 Joshua Davidson (Octal450)
# Copyright (c) 2020 Matthew Maring (hayden2000)

var MCDU_init = func(i) {
	MCDU_reset(i); # Reset MCDU, clears data
}

var MCDU_reset = func(i) {
	setprop("MCDU[" ~ i ~ "]/active", 0);
	setprop("it-autoflight/settings/togaspd", 157);
	setprop("MCDU[" ~ i ~ "]/last-scratchpad", "");
	setprop("MCDU[" ~ i ~ "]/last-page", "NONE");
	setprop("MCDU[" ~ i ~ "]/last-fmgc-page", "STATUS");
	setprop("MCDU[" ~ i ~ "]/page", "MCDU");
	setprop("MCDU[" ~ i ~ "]/scratchpad", "SELECT DESIRED SYSTEM");
	setprop("MCDU[" ~ i ~ "]/scratchpad-msg", 0);
	setprop("MCDUC/flight-num", "");
	setprop("MCDUC/thracc-set", 0);
	setprop("MCDUC/reducacc-set", 0);
	setprop("MCDUC/flight-num-set", 0);
	setprop("FMGC/internal/flex", 0);
	setprop("FMGC/internal/dep-arpt", "");
	setprop("FMGC/internal/arr-arpt", "");
	setprop("FMGC/internal/cruise-ft", 10000);
	setprop("FMGC/internal/cruise-fl", 100);
	setprop("FMGC/internal/cost-index", "0");
	setprop("FMGC/internal/trans-alt", 18000);
	setprop("FMGC/internal/reduc-agl-ft", "1500"); #eventually set to 1500 above runway
	setprop("FMGC/internal/eng-out-reduc", "1500");
	setprop("FMGC/internal/v1", 0);
	setprop("FMGC/internal/vr", 0);
	setprop("FMGC/internal/v2", 0);
	setprop("FMGC/internal/f-speed", 0);
	setprop("FMGC/internal/s-speed", 0);
	setprop("FMGC/internal/o-speed", 0);
	setprop("FMGC/internal/minspeed", 0);
	#setprop("FMGC/internal/vapp-speed", 0);
	setprop("FMGC/internal/vr", 0);
	setprop("FMGC/internal/v2", 0);
	
	# IRSINIT variables
    setprop("FMGC/internal/align-set", 0);

    # ROUTE SELECTION variables
    setprop("FMGC/internal/alt-selected", 0);

	# INT-B
	setprop("FMGC/internal/block", 0.0);
	setprop("FMGC/internal/block-set", 0);
	setprop("FMGC/internal/zfw", 0);
	setprop("FMGC/internal/zfw-set", 0);
	setprop("FMGC/internal/zfwcg", 55.1);
	setprop("FMGC/internal/zfwcg-set", 0);
	setprop("FMGC/internal/taxi-fuel", 0.4);
	setprop("FMGC/internal/trip-fuel", 0);
	setprop("FMGC/internal/trip-time", "0000");
	setprop("FMGC/internal/rte-rsv", 0);
	setprop("FMGC/internal/rte-percent", 5.0);
	setprop("FMGC/internal/alt-fuel", 0);
	setprop("FMGC/internal/alt-time", "0000");
	setprop("FMGC/internal/final-fuel", 0);
	setprop("FMGC/internal/final-time", "0000");
	setprop("FMGC/internal/min-dest-fob", 0);
	setprop("FMGC/internal/tow", 0);
	setprop("FMGC/internal/lw", 0);
	setprop("FMGC/internal/trip-wind", "HD000");
	setprop("FMGC/internal/extra-fuel", 0);
	setprop("FMGC/internal/extra-time", "0000");
	
	#FUELPRED
	setprop("FMGC/internal/alt-airport", "");
    setprop("FMGC/internal/pri-utc", "0000");
    setprop("FMGC/internal/alt-utc", "0000");
    setprop("FMGC/internal/pri-efob", 0);
    setprop("FMGC/internal/alt-efob", 0);
    setprop("FMGC/internal/fob", 0);
    setprop("FMGC/internal/gw", 0);
    setprop("FMGC/internal/cg", 0);
    
    #PERF TO
    setprop("FMGC/internal/v1-set", 0);
	setprop("FMGC/internal/vr-set", 0);
	setprop("FMGC/internal/v2-set", 0);
	setprop("FMGC/internal/to-flap", 0);
	setprop("FMGC/internal/to-ths", "0.0");
	setprop("FMGC/internal/tofrom-set", 0);
	setprop("FMGC/internal/cost-index-set", 0);
	setprop("FMGC/internal/cruise-lvl-set", 0);
	setprop("FMGC/internal/flap-ths-set", 0);
	setprop("FMGC/internal/flex-set", 0);
	setprop("FMGC/internal/tropo", 36090);
	setprop("FMGC/internal/tropo-set", 0);
	
    #PERF APPR
    setprop("FMGC/internal/dest-qnh", -1);
    setprop("FMGC/internal/dest-temp", -999);
    setprop("FMGC/internal/dest-mag", -1);
    setprop("FMGC/internal/dest-wind", -1);
    setprop("FMGC/internal/vapp-speed", -1);
    setprop("FMGC/internal/vapp-speed-set", 0);
    setprop("FMGC/internal/f-speed-appr", -1);
    setprop("FMGC/internal/s-speed-appr", -1);
    setprop("FMGC/internal/o-speed-appr", -1);
    setprop("FMGC/internal/vls-speed-appr", -1);
    setprop("FMGC/internal/final", "");
    setprop("FMGC/internal/mda", -1);
    setprop("FMGC/internal/dh", -1);
    setprop("FMGC/internal/ldg-config-3-set", 0);
    setprop("FMGC/internal/ldg-config-f-set", 1);
	
	setprop("FMGC/internal/ils1freq-set", 0);
	setprop("FMGC/internal/ils1crs-set", 0);
	setprop("FMGC/internal/vor1freq-set", 0);
	setprop("FMGC/internal/vor1crs-set", 0);
	setprop("FMGC/internal/vor2freq-set", 0);
	setprop("FMGC/internal/vor2crs-set", 0);
	setprop("FMGC/internal/adf1freq-set", 0);
	setprop("FMGC/internal/adf2freq-set", 0);
	setprop("FMGC/internal/navdatabase", "01JAN-28JAN");
	setprop("FMGC/internal/navdatabase2", "29JAN-26FEB");
	setprop("FMGC/internal/navdatabasecode", "AB20170101");
	setprop("FMGC/internal/navdatabasecode2", "AB20170102");
	setprop("FMGC/print/mcdu/page1/L1auto", 0);
	setprop("FMGC/print/mcdu/page1/L2auto", 0);
	setprop("FMGC/print/mcdu/page1/L3auto", 0);
	setprop("FMGC/print/mcdu/page1/R1req", 0);
	setprop("FMGC/print/mcdu/page1/R2req", 0);
	setprop("FMGC/print/mcdu/page1/R3req", 0);
	setprop("FMGC/print/mcdu/page2/L1auto", 0);
	setprop("FMGC/print/mcdu/page2/L2auto", 0);
	setprop("FMGC/print/mcdu/page2/L3auto", 0);
	setprop("FMGC/print/mcdu/page2/L4auto", 0);
	setprop("FMGC/print/mcdu/page2/R1req", 0);
	setprop("FMGC/print/mcdu/page2/R2req", 0);
	setprop("FMGC/print/mcdu/page2/R3req", 0);
	setprop("FMGC/print/mcdu/page2/R4req", 0);
}

var lskbutton = func(btn, i) {
	if (btn == "1") {
		if (getprop("MCDU[" ~ i ~ "]/page") == "MCDU") {
			if (getprop("MCDU[" ~ i ~ "]/active") != 2) {
				setprop("MCDU[" ~ i ~ "]/scratchpad-msg", 1);
				setprop("MCDU[" ~ i ~ "]/scratchpad", "WAIT FOR SYSTEM RESPONSE");
				setprop("MCDU[" ~ i ~ "]/active", 1);
				settimer(func(){
					setprop("MCDU[" ~ i ~ "]/page", getprop("MCDU[" ~ i ~ "]/last-fmgc-page"));
					setprop("MCDU[" ~ i ~ "]/scratchpad", "");
					setprop("MCDU[" ~ i ~ "]/scratchpad-msg", 0);
					setprop("MCDU[" ~ i ~ "]/active", 2);
				}, 2);
			} else {
				setprop("MCDU[" ~ i ~ "]/page", getprop("MCDU[" ~ i ~ "]/last-fmgc-page"));
				setprop("MCDU[" ~ i ~ "]/scratchpad", "");
				setprop("MCDU[" ~ i ~ "]/scratchpad-msg", 0);
			}
		} else if (getprop("MCDU[" ~ i ~ "]/page") == "INITB") {
			initInputB("L1",i);
		} else if (getprop("MCDU[" ~ i ~ "]/page") == "TO") {
			perfTOInput("L1",i);
		} else if (getprop("MCDU[" ~ i ~ "]/page") == "APPR") {
			perfAPPRInput("L1",i);
		} else if (getprop("MCDU[" ~ i ~ "]/page") == "RADNAV") {
			radnavInput("L1",i);
		} else if (getprop("MCDU[" ~ i ~ "]/page") == "DATA") {
			dataInput("L1",i);
		} else if (getprop("MCDU[" ~ i ~ "]/page") == "PRINTFUNC") {
			printInput("L1",i);
		} else if (getprop("MCDU[" ~ i ~ "]/page") == "PRINTFUNC2") {
			printInput2("L1",i);
		} else {
			notAllowed(i);
		}
	} else if (btn == "2") {
		if (getprop("MCDU[" ~ i ~ "]/page") == "INITA") {
			initInputA("L2",i);
		} else if (getprop("MCDU[" ~ i ~ "]/page") == "INITB") {
			initInputB("L2",i);
		} else if (getprop("MCDU[" ~ i ~ "]/page") == "TO") {
			perfTOInput("L2",i);
		} else if (getprop("MCDU[" ~ i ~ "]/page") == "APPR") {
			perfAPPRInput("L2",i);
		} else if (getprop("MCDU[" ~ i ~ "]/page") == "RADNAV") {
			radnavInput("L2",i);
		} else if (getprop("MCDU[" ~ i ~ "]/page") == "CLB") {
			perfCLBInput("L2",i);
		} else if (getprop("MCDU[" ~ i ~ "]/page") == "CRZ") {
			perfCRZInput("L2",i); 
		} else if (getprop("MCDU[" ~ i ~ "]/page") == "DES") {
			perfDESInput("L2",i); 
		} else if (getprop("MCDU[" ~ i ~ "]/page") == "DATA") {
			dataInput("L2",i);
		} else if (getprop("MCDU[" ~ i ~ "]/page") == "PRINTFUNC") {
			printInput("L2",i);
		} else if (getprop("MCDU[" ~ i ~ "]/page") == "PRINTFUNC2") {
			printInput2("L2",i);
		} else {
			notAllowed(i);
		}
	} else if (btn == "3") {
		if (getprop("MCDU[" ~ i ~ "]/page") == "INITA") {
			initInputA("L3",i);
		} else if (getprop("MCDU[" ~ i ~ "]/page") == "INITB") {
			initInputB("L3",i);
		} else if (getprop("MCDU[" ~ i ~ "]/page") == "FUELPRED") {
			fuelPredInput("L3",i);
		} else if (getprop("MCDU[" ~ i ~ "]/page") == "TO") {
			perfTOInput("L3",i);
		} else if (getprop("MCDU[" ~ i ~ "]/page") == "APPR") {
			perfAPPRInput("L3",i);
		} else if (getprop("MCDU[" ~ i ~ "]/page") == "STATUS") {
			statusInput("L3",i);
		} else if (getprop("MCDU[" ~ i ~ "]/page") == "RADNAV") {
			radnavInput("L3",i);
		} else if (getprop("MCDU[" ~ i ~ "]/page") == "PRINTFUNC") {
			printInput("L3",i);
		} else if (getprop("MCDU[" ~ i ~ "]/page") == "PRINTFUNC2") {
			printInput2("L3",i);
		} else {
			notAllowed(i);
		}
	} else if (btn == "4") {
		if (getprop("MCDU[" ~ i ~ "]/page") == "DATA") {
			setprop("MCDU[" ~ i ~ "]/page", "STATUS");
		} else if (getprop("MCDU[" ~ i ~ "]/page") == "INITB") {
			initInputB("L4",i);
		} else if (getprop("MCDU[" ~ i ~ "]/page") == "FUELPRED") {
			fuelPredInput("L4",i);
		} else if (getprop("MCDU[" ~ i ~ "]/page") == "TO") {
			perfTOInput("L4",i);
		} else if (getprop("MCDU[" ~ i ~ "]/page") == "APPR") {
			perfAPPRInput("L4",i);
		} else if (getprop("MCDU[" ~ i ~ "]/page") == "RADNAV") {
			radnavInput("L4",i);
		} else if (getprop("MCDU[" ~ i ~ "]/page") == "PRINTFUNC2") {
			printInput2("L4",i);
		} else {
			notAllowed(i);
		}
	} else if (btn == "5") {
		if (getprop("MCDU[" ~ i ~ "]/page") == "INITA") {
			initInputA("L5",i);
		} else if (getprop("MCDU[" ~ i ~ "]/page") == "INITB") {
			initInputB("L5",i);
		} else if (getprop("MCDU[" ~ i ~ "]/page") == "FUELPRED") {
			fuelPredInput("L5",i);
		} else if (getprop("MCDU[" ~ i ~ "]/page") == "TO") {
			perfTOInput("L5",i);
		} else if (getprop("MCDU[" ~ i ~ "]/page") == "CLB") {
			perfCLBInput("L5",i);
		} else if (getprop("MCDU[" ~ i ~ "]/page") == "CRZ") {
			perfCRZInput("L5",i);
		} else if (getprop("MCDU[" ~ i ~ "]/page") == "DES") {
			perfDESInput("L5",i);
		} else if (getprop("MCDU[" ~ i ~ "]/page") == "APPR") {
			perfAPPRInput("L5",i);
		} else if (getprop("MCDU[" ~ i ~ "]/page") == "GA") {
			perfGAInput("L5",i);
		} else if (getprop("MCDU[" ~ i ~ "]/page") == "RADNAV") {
			radnavInput("L5",i);
		} else if (getprop("MCDU[" ~ i ~ "]/page") == "PRINTFUNC") {
			printInput("L5",i);
		} else if (getprop("MCDU[" ~ i ~ "]/page") == "PRINTFUNC2") {
			printInput2("L5",i);
		} else {
			notAllowed(i);
		}
	} else if (btn == "6") {
		if (getprop("MCDU[" ~ i ~ "]/page") == "INITA") {
			initInputA("L6",i);
		} else if (getprop("MCDU[" ~ i ~ "]/page") == "IRSINIT") {
			initInputIRS("L6",i);
		} else if (getprop("MCDU[" ~ i ~ "]/page") == "ROUTESELECTION") {
			initInputROUTESEL("L6",i);
		} else if (getprop("MCDU[" ~ i ~ "]/page") == "CLB") {
			perfCLBInput("L6",i);
		} else if (getprop("MCDU[" ~ i ~ "]/page") == "CRZ") {
			perfCRZInput("L6",i);
		} else if (getprop("MCDU[" ~ i ~ "]/page") == "DES") {
			perfDESInput("L6",i);
		} else if (getprop("MCDU[" ~ i ~ "]/page") == "APPR") {
			perfAPPRInput("L6",i);
		} else if (getprop("MCDU[" ~ i ~ "]/page") == "GA") {
			perfGAInput("L6",i);
		} else if (getprop("MCDU[" ~ i ~ "]/page") == "PRINTFUNC2") {
			printInput2("L6",i);
		} else {
			notAllowed(i);
		}
	}
}

var lskbutton_b = func(btn, i) {
	# Special Middle Click Functions
}

var rskbutton = func(btn, i) {
	if (btn == "1") {
		if (getprop("MCDU[" ~ i ~ "]/page") == "INITA") {
			initInputA("R1",i);
		} else if (getprop("MCDU[" ~ i ~ "]/page") == "INITB") {
			initInputB("R1",i);
		} else if (getprop("MCDU[" ~ i ~ "]/page") == "RADNAV") {
			radnavInput("R1",i);
		} else if (getprop("MCDU[" ~ i ~ "]/page") == "PRINTFUNC") {
			printInput("R1",i);
		} else if (getprop("MCDU[" ~ i ~ "]/page") == "PRINTFUNC2") {
			printInput2("R1",i);
		} else {
			notAllowed(i);
		}
	} else if (btn == "2") {
		if (getprop("MCDU[" ~ i ~ "]/page") == "INITB") {
			initInputB("R2",i);
		} else if (getprop("MCDU[" ~ i ~ "]/page") == "APPR") {
			perfAPPRInput("R2",i);
		} else if (getprop("MCDU[" ~ i ~ "]/page") == "RADNAV") {
			radnavInput("R2",i);
		} else if (getprop("MCDU[" ~ i ~ "]/page") == "PRINTFUNC") {
			printInput("R2",i);
		} else if (getprop("MCDU[" ~ i ~ "]/page") == "PRINTFUNC2") {
			printInput2("R2",i);
		} else {
			notAllowed(i);
		}
	} else if (btn == "3") {
		if (getprop("MCDU[" ~ i ~ "]/page") == "INITA") {
			initInputA("R3",i);
		} else if (getprop("MCDU[" ~ i ~ "]/page") == "INITB") {
			initInputB("R3",i);
		} else if (getprop("MCDU[" ~ i ~ "]/page") == "FUELPRED") {
			fuelPredInput("R3",i);
		} else if (getprop("MCDU[" ~ i ~ "]/page") == "TO") {
			perfTOInput("R3",i);
		} else if (getprop("MCDU[" ~ i ~ "]/page") == "APPR") {
			perfAPPRInput("R3",i);
		} else if (getprop("MCDU[" ~ i ~ "]/page") == "PRINTFUNC") {
			printInput("R3",i);
		} else if (getprop("MCDU[" ~ i ~ "]/page") == "PRINTFUNC2") {
			printInput2("R3",i);
		} else {
			notAllowed(i);
		}
	} else if (btn == "4") {
		if (getprop("MCDU[" ~ i ~ "]/page") == "TO") {
			perfTOInput("R4",i);
		} else if (getprop("MCDU[" ~ i ~ "]/page") == "APPR") {
			perfAPPRInput("R4",i);
		} else if (getprop("MCDU[" ~ i ~ "]/page") == "RADNAV") {
			radnavInput("R4",i);
		} else if (getprop("MCDU[" ~ i ~ "]/page") == "PRINTFUNC2") {
			printInput2("R4",i);
		} else {
			notAllowed(i);
		}
	} else if (btn == "5") {
		if (getprop("MCDU[" ~ i ~ "]/page") == "INITB") {
			initInputB("R5",i);
		} else if (getprop("MCDU[" ~ i ~ "]/page") == "TO") {
			perfTOInput("R5",i);
		} else if (getprop("MCDU[" ~ i ~ "]/page") == "APPR") {
			perfAPPRInput("R5",i);
		} else if (getprop("MCDU[" ~ i ~ "]/page") == "GA") {
			perfGAInput("R5",i);
		} else if (getprop("MCDU[" ~ i ~ "]/page") == "RADNAV") {
			radnavInput("R5",i);
		} else if (getprop("MCDU[" ~ i ~ "]/page") == "DATA") {
			dataInput("R5",i);
		} else {
			notAllowed(i);
		}
	} else if (btn == "6") {
		if (getprop("MCDU[" ~ i ~ "]/page") == "MCDU") {
			if (getprop("MCDU[" ~ i ~ "]/last-page") != "NONE") {
				setprop("MCDU[" ~ i ~ "]/page", getprop("MCDU[" ~ i ~ "]/last-page"));
				setprop("MCDU[" ~ i ~ "]/scratchpad", "");
				setprop("MCDU[" ~ i ~ "]/scratchpad-msg", 0);
			} else {
				notAllowed(i);
			}
		} else if (getprop("MCDU[" ~ i ~ "]/page") == "IRSINIT") {
			initInputIRS("R6",i);
		} else if (getprop("MCDU[" ~ i ~ "]/page") == "TO") {
			perfTOInput("R6",i);
		} else if (getprop("MCDU[" ~ i ~ "]/page") == "CLB") {
			perfCLBInput("R6",i);
		} else if (getprop("MCDU[" ~ i ~ "]/page") == "CRZ") {
			perfCRZInput("R6",i);
		} else if (getprop("MCDU[" ~ i ~ "]/page") == "DES") {
			perfDESInput("R6",i);
		} else if (getprop("MCDU[" ~ i ~ "]/page") == "APPR") {
			perfAPPRInput("R6",i);
		} else if ((getprop("MCDU[" ~ i ~ "]/page") == "DATA") or (getprop("MCDU[" ~ i ~ "]/page") == "PRINTFUNC") or (getprop("MCDU[" ~ i ~ "]/page") == "PRINTFUNC2")) {
			if (getprop("MCDU[" ~ i ~ "]/scratchpad") != "AOC DISABLED") {
				if (getprop("MCDU[" ~ i ~ "]/scratchpad-msg") == 1) {
					setprop("MCDU[" ~ i ~ "]/last-scratchpad", "");
				} else {
					setprop("MCDU[" ~ i ~ "]/last-scratchpad", getprop("MCDU[" ~ i ~ "]/scratchpad"));
				}
			}
			setprop("MCDU[" ~ i ~ "]/scratchpad-msg", 1);
			setprop("MCDU[" ~ i ~ "]/scratchpad", "AOC DISABLED");
		} else if (getprop("MCDU[" ~ i ~ "]/page") == "INITA") {
			initInputA("R6",i);
		} else {
			notAllowed(i);
		}
	}
}

var rskbutton_b = func(btn, i) {
	# Special Middle Click Functions
}

var arrowbutton = func(btn, i) {
	if (btn == "left") {
		if (getprop("MCDU[" ~ i ~ "]/page") == "DATA") {
			setprop("MCDU[" ~ i ~ "]/page", "DATA2");
		} else if (getprop("MCDU[" ~ i ~ "]/page") == "DATA2") {
			setprop("MCDU[" ~ i ~ "]/page", "DATA");
		}
		if (getprop("MCDU[" ~ i ~ "]/page") == "INITA") {
			if (getprop("engines/engine[0]/state") != 3 and getprop("engines/engine[1]/state") != 3) {
				setprop("MCDU[" ~ i ~ "]/page", "INITB");
			} else {
			    setprop("MCDU[" ~ i ~ "]/page", "FUELPRED");
			}
		} else if (getprop("MCDU[" ~ i ~ "]/page") == "INITB" or getprop("MCDU[" ~ i ~ "]/page") == "FUELPRED") {
			setprop("MCDU[" ~ i ~ "]/page", "INITA");
		}
		if (getprop("MCDU[" ~ i ~ "]/page") == "PRINTFUNC") {
			setprop("MCDU[" ~ i ~ "]/page", "PRINTFUNC2");
		} else if (getprop("MCDU[" ~ i ~ "]/page") == "PRINTFUNC2") {
			setprop("MCDU[" ~ i ~ "]/page", "PRINTFUNC");
		}
	} else if (btn == "right") {
		if (getprop("MCDU[" ~ i ~ "]/page") == "DATA") {
			setprop("MCDU[" ~ i ~ "]/page", "DATA2");
		} else if (getprop("MCDU[" ~ i ~ "]/page") == "DATA2") {
			setprop("MCDU[" ~ i ~ "]/page", "DATA");
		}
		if (getprop("MCDU[" ~ i ~ "]/page") == "INITA") {
			if (getprop("engines/engine[0]/state") != 3 and getprop("engines/engine[1]/state") != 3) {
				setprop("MCDU[" ~ i ~ "]/page", "INITB");
			} else {
			    setprop("MCDU[" ~ i ~ "]/page", "FUELPRED");
			}
		} else if (getprop("MCDU[" ~ i ~ "]/page") == "INITB" or getprop("MCDU[" ~ i ~ "]/page") == "FUELPRED") {
			setprop("MCDU[" ~ i ~ "]/page", "INITA");
		}
		if (getprop("MCDU[" ~ i ~ "]/page") == "PRINTFUNC") {
			setprop("MCDU[" ~ i ~ "]/page", "PRINTFUNC2");
		} else if (getprop("MCDU[" ~ i ~ "]/page") == "PRINTFUNC2") {
			setprop("MCDU[" ~ i ~ "]/page", "PRINTFUNC");
		}
	} else if (btn == "up") {
		# Nothing for now
	} else if (btn == "down") {
		# Nothing for now
	}
}

var pagebutton = func(btn, i) {
	if (getprop("MCDU[" ~ i ~ "]/page") != "MCDU") {
		if (btn == "radnav") {
			setprop("MCDU[" ~ i ~ "]/page", "RADNAV");
		} else if (btn == "perf") {
			if (getprop("FMGC/status/phase") == 0 or getprop("FMGC/status/phase") == 1) {
				setprop("MCDU[" ~ i ~ "]/page", "TO");
			} else if (getprop("FMGC/status/phase") == 2) {
				setprop("MCDU[" ~ i ~ "]/page", "CLB");
			} else if (getprop("FMGC/status/phase") == 3) {
				setprop("MCDU[" ~ i ~ "]/page", "CRZ");
			} else if (getprop("FMGC/status/phase") == 4) {
				setprop("MCDU[" ~ i ~ "]/page", "DES");
			} else if (getprop("FMGC/status/phase") == 5) {
				setprop("MCDU[" ~ i ~ "]/page", "APPR");
			} else if (getprop("FMGC/status/phase") == 6) {
				setprop("MCDU[" ~ i ~ "]/page", "GA");
			}
		} else if (btn == "init") {
			setprop("MCDU[" ~ i ~ "]/page", "INITA");
		} else if (btn == "data") {
			setprop("MCDU[" ~ i ~ "]/page", "DATA");
		} else if (btn == "mcdu") {
			setprop("MCDU[" ~ i ~ "]/last-page", getprop("MCDU[" ~ i ~ "]/page"));
			setprop("MCDU[" ~ i ~ "]/last-fmgc-page", getprop("MCDU[" ~ i ~ "]/page"));
			setprop("MCDU[" ~ i ~ "]/scratchpad", "SELECT DESIRED SYSTEM");
			setprop("MCDU[" ~ i ~ "]/page", "MCDU");
		} else if (btn == "f-pln") {
			setprop("MCDU[" ~ i ~ "]/page", "F-PLNA");
		} else if (btn == "fuel-pred") {
			setprop("MCDU[" ~ i ~ "]/page", "FUELPRED");
		}
	}
}

var button = func(btn, i) {
	if (getprop("MCDU[" ~ i ~ "]/scratchpad-msg") == 0 and getprop("MCDU[" ~ i ~ "]/page") != "MCDU") {
		var scratchpad = getprop("MCDU[" ~ i ~ "]/scratchpad");
		if (btn == "A") {
			setprop("MCDU[" ~ i ~ "]/scratchpad", scratchpad ~ "A");
			setprop("MCDU[" ~ i ~ "]/scratchpad-msg", 0);
		} else if (btn == "B") {
			setprop("MCDU[" ~ i ~ "]/scratchpad", scratchpad ~ "B");
			setprop("MCDU[" ~ i ~ "]/scratchpad-msg", 0);
		} else if (btn == "C") {
			setprop("MCDU[" ~ i ~ "]/scratchpad", scratchpad ~ "C");
			setprop("MCDU[" ~ i ~ "]/scratchpad-msg", 0);
		} else if (btn == "D") {
			setprop("MCDU[" ~ i ~ "]/scratchpad", scratchpad ~ "D");
			setprop("MCDU[" ~ i ~ "]/scratchpad-msg", 0);
		} else if (btn == "E") {
			setprop("MCDU[" ~ i ~ "]/scratchpad", scratchpad ~ "E");
			setprop("MCDU[" ~ i ~ "]/scratchpad-msg", 0);
		} else if (btn == "F") {
			setprop("MCDU[" ~ i ~ "]/scratchpad", scratchpad ~ "F");
			setprop("MCDU[" ~ i ~ "]/scratchpad-msg", 0);
		} else if (btn == "G") {
			setprop("MCDU[" ~ i ~ "]/scratchpad", scratchpad ~ "G");
			setprop("MCDU[" ~ i ~ "]/scratchpad-msg", 0);
		} else if (btn == "H") {
			setprop("MCDU[" ~ i ~ "]/scratchpad", scratchpad ~ "H");
			setprop("MCDU[" ~ i ~ "]/scratchpad-msg", 0);
		} else if (btn == "I") {
			setprop("MCDU[" ~ i ~ "]/scratchpad", scratchpad ~ "I");
			setprop("MCDU[" ~ i ~ "]/scratchpad-msg", 0);
		} else if (btn == "J") {
			setprop("MCDU[" ~ i ~ "]/scratchpad", scratchpad ~ "J");
			setprop("MCDU[" ~ i ~ "]/scratchpad-msg", 0);
		} else if (btn == "K") {
			setprop("MCDU[" ~ i ~ "]/scratchpad", scratchpad ~ "K");
			setprop("MCDU[" ~ i ~ "]/scratchpad-msg", 0);
		} else if (btn == "L") {
			setprop("MCDU[" ~ i ~ "]/scratchpad", scratchpad ~ "L");
			setprop("MCDU[" ~ i ~ "]/scratchpad-msg", 0);
		} else if (btn == "M") {
			setprop("MCDU[" ~ i ~ "]/scratchpad", scratchpad ~ "M");
			setprop("MCDU[" ~ i ~ "]/scratchpad-msg", 0);
		} else if (btn == "N") {
			setprop("MCDU[" ~ i ~ "]/scratchpad", scratchpad ~ "N");
			setprop("MCDU[" ~ i ~ "]/scratchpad-msg", 0);
		} else if (btn == "O") {
			setprop("MCDU[" ~ i ~ "]/scratchpad", scratchpad ~ "O");
			setprop("MCDU[" ~ i ~ "]/scratchpad-msg", 0);
		} else if (btn == "P") {
			setprop("MCDU[" ~ i ~ "]/scratchpad", scratchpad ~ "P");
			setprop("MCDU[" ~ i ~ "]/scratchpad-msg", 0);
		} else if (btn == "Q") {
			setprop("MCDU[" ~ i ~ "]/scratchpad", scratchpad ~ "Q");
			setprop("MCDU[" ~ i ~ "]/scratchpad-msg", 0);
		} else if (btn == "R") {
			setprop("MCDU[" ~ i ~ "]/scratchpad", scratchpad ~ "R");
			setprop("MCDU[" ~ i ~ "]/scratchpad-msg", 0);
		} else if (btn == "S") {
			setprop("MCDU[" ~ i ~ "]/scratchpad", scratchpad ~ "S");
			setprop("MCDU[" ~ i ~ "]/scratchpad-msg", 0);
		} else if (btn == "T") {
			setprop("MCDU[" ~ i ~ "]/scratchpad", scratchpad ~ "T");
			setprop("MCDU[" ~ i ~ "]/scratchpad-msg", 0);
		} else if (btn == "U") {
			setprop("MCDU[" ~ i ~ "]/scratchpad", scratchpad ~ "U");
			setprop("MCDU[" ~ i ~ "]/scratchpad-msg", 0);
		} else if (btn == "V") {
			setprop("MCDU[" ~ i ~ "]/scratchpad", scratchpad ~ "V");
			setprop("MCDU[" ~ i ~ "]/scratchpad-msg", 0);
		} else if (btn == "W") {
			setprop("MCDU[" ~ i ~ "]/scratchpad", scratchpad ~ "W");
			setprop("MCDU[" ~ i ~ "]/scratchpad-msg", 0);
		} else if (btn == "X") {
			setprop("MCDU[" ~ i ~ "]/scratchpad", scratchpad ~ "X");
			setprop("MCDU[" ~ i ~ "]/scratchpad-msg", 0);
		} else if (btn == "Y") {
			setprop("MCDU[" ~ i ~ "]/scratchpad", scratchpad ~ "Y");
			setprop("MCDU[" ~ i ~ "]/scratchpad-msg", 0);
		} else if (btn == "Z") {
			setprop("MCDU[" ~ i ~ "]/scratchpad", scratchpad ~ "Z");
			setprop("MCDU[" ~ i ~ "]/scratchpad-msg", 0);
		} else if (btn == "SLASH") {
			setprop("MCDU[" ~ i ~ "]/scratchpad", scratchpad ~ "/");
			setprop("MCDU[" ~ i ~ "]/scratchpad-msg", 0);
		} else if (btn == "SP") {
			setprop("MCDU[" ~ i ~ "]/scratchpad", scratchpad ~ " ");
			setprop("MCDU[" ~ i ~ "]/scratchpad-msg", 0);
		} else if (btn == "CLR") {
			var scratchpad = getprop("MCDU[" ~ i ~ "]/scratchpad");
			if (size(scratchpad) == 0) {
				setprop("MCDU[" ~ i ~ "]/scratchpad-msg", 1);
				setprop("MCDU[" ~ i ~ "]/scratchpad", "CLR");
			} else if (getprop("MCDU[" ~ i ~ "]/scratchpad-msg") == 1) {
				setprop("MCDU[" ~ i ~ "]/scratchpad", "");
				setprop("MCDU[" ~ i ~ "]/scratchpad-msg", 0);
			} else if (size(scratchpad) > 0) {
				setprop("MCDU[" ~ i ~ "]/last-scratchpad", "");
				setprop("MCDU[" ~ i ~ "]/scratchpad", left(scratchpad, size(scratchpad) - 1));
				setprop("MCDU[" ~ i ~ "]/scratchpad-msg", 0);
			}
		} else if (btn == "0") {
			setprop("MCDU[" ~ i ~ "]/scratchpad", scratchpad ~ "0");
			setprop("MCDU[" ~ i ~ "]/scratchpad-msg", 0);
		} else if (btn == "1") {
			setprop("MCDU[" ~ i ~ "]/scratchpad", scratchpad ~ "1");
			setprop("MCDU[" ~ i ~ "]/scratchpad-msg", 0);
		} else if (btn == "2") {
			setprop("MCDU[" ~ i ~ "]/scratchpad", scratchpad ~ "2");
			setprop("MCDU[" ~ i ~ "]/scratchpad-msg", 0);
		} else if (btn == "3") {
			setprop("MCDU[" ~ i ~ "]/scratchpad", scratchpad ~ "3");
			setprop("MCDU[" ~ i ~ "]/scratchpad-msg", 0);
		} else if (btn == "4") {
			setprop("MCDU[" ~ i ~ "]/scratchpad", scratchpad ~ "4");
			setprop("MCDU[" ~ i ~ "]/scratchpad-msg", 0);
		} else if (btn == "5") {
			setprop("MCDU[" ~ i ~ "]/scratchpad", scratchpad ~ "5");
			setprop("MCDU[" ~ i ~ "]/scratchpad-msg", 0);
		} else if (btn == "6") {
			setprop("MCDU[" ~ i ~ "]/scratchpad", scratchpad ~ "6");
			setprop("MCDU[" ~ i ~ "]/scratchpad-msg", 0);
		} else if (btn == "7") {
			setprop("MCDU[" ~ i ~ "]/scratchpad", scratchpad ~ "7");
			setprop("MCDU[" ~ i ~ "]/scratchpad-msg", 0);
		} else if (btn == "8") {
			setprop("MCDU[" ~ i ~ "]/scratchpad", scratchpad ~ "8");
			setprop("MCDU[" ~ i ~ "]/scratchpad-msg", 0);
		} else if (btn == "9") {
			setprop("MCDU[" ~ i ~ "]/scratchpad", scratchpad ~ "9");
			setprop("MCDU[" ~ i ~ "]/scratchpad-msg", 0);
		} else if (btn == "DOT") {
			setprop("MCDU[" ~ i ~ "]/scratchpad", scratchpad ~ ".");
			setprop("MCDU[" ~ i ~ "]/scratchpad-msg", 0);
		} else if (btn == "PLUSMINUS") {
			setprop("MCDU[" ~ i ~ "]/scratchpad", scratchpad ~ "-");
			setprop("MCDU[" ~ i ~ "]/scratchpad-msg", 0);
		}
	} else {
		if (btn == "CLR") {
			var scratchpad = getprop("MCDU[" ~ i ~ "]/scratchpad");
			if (size(scratchpad) == 0) {
				setprop("MCDU[" ~ i ~ "]/scratchpad-msg", 1);
				setprop("MCDU[" ~ i ~ "]/scratchpad", "CLR");
			} else if (getprop("MCDU[" ~ i ~ "]/scratchpad-msg") == 1) {
				setprop("MCDU[" ~ i ~ "]/scratchpad", getprop("MCDU[" ~ i ~ "]/last-scratchpad"));
				setprop("MCDU[" ~ i ~ "]/last-scratchpad", "");
				setprop("MCDU[" ~ i ~ "]/scratchpad-msg", 0);
			}
		}
	}
}

var notAllowed = func(i) {
	if (getprop("MCDU[" ~ i ~ "]/scratchpad") != "NOT ALLOWED") {
		if (getprop("MCDU[" ~ i ~ "]/scratchpad-msg") == 1) {
			setprop("MCDU[" ~ i ~ "]/last-scratchpad", "");
		} else {
			setprop("MCDU[" ~ i ~ "]/last-scratchpad", getprop("MCDU[" ~ i ~ "]/scratchpad"));
		}
	}
	setprop("MCDU[" ~ i ~ "]/scratchpad-msg", 1);
	setprop("MCDU[" ~ i ~ "]/scratchpad", "NOT ALLOWED");
}

var screenFlash = func(time, i) {
	var page = getprop("MCDU[" ~ i ~ "]/page");
	setprop("MCDU[" ~ i ~ "]/page", "NONE");
	settimer(func {
		setprop("MCDU[" ~ i ~ "]/page", page);
	}, time);
}
