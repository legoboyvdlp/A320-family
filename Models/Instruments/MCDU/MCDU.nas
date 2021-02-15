# A3XX mCDU by Joshua Davidson (Octal450), Jonathan Redpath, and Matthew Maring (mattmaring)

# Copyright (c) 2020 Josh Davidson (Octal450)
# Copyright (c) 2020 Matthew Maring (mattmaring)

var MCDU_1 = nil;
var MCDU_2 = nil;
var MCDU1_display = nil;
var MCDU2_display = nil;
var myLatRev = [nil, nil];
var myVertRev = [nil, nil];
var myDeparture = [nil, nil];
var myArrival = [nil, nil];
var myFpln = [nil, nil];
var myDirTo = [nil, nil];
var myHold = [nil, nil];
var myAirways = [nil, nil];
var myDuplicate = [nil, nil];
var myClosestAirport = [nil, nil];
var myReceivedMessage = [nil, nil];
var myReceivedMessages = [nil, nil];
var myPilotWP = [nil, nil];
var myWind = [nil, nil];
var myCLBWIND = [nil, nil];
var myCRZWIND = [nil, nil];
var myDESWIND = [nil, nil];
var myHISTWIND = [nil, nil];
var myAtis = [nil, nil];
var default = "BoeingCDU-Large.ttf";
#var symbol = "helvetica_medium.txf";
var symbol = "LiberationMonoCustom.ttf";
var normal = 70;
var small = 56;
var page = "";
var fplnLineSize = 0;
var fplnl1 = "";
var fplnl1s = "";
var fplnl2 = "";
var fplnl2s = "";
var fplnl3 = "";
var fplnl3s = "";
var fplnl4 = "";
var fplnl4s = "";
var fplnl5 = "";
var fplnl5s = "";
var fplnl6 = "";
var fplnl6s = "";
setprop("/MCDUC/colors/wht/r", 1);
setprop("/MCDUC/colors/wht/g", 1);
setprop("/MCDUC/colors/wht/b", 1);
setprop("/MCDUC/colors/grn/r", 0.0509);
setprop("/MCDUC/colors/grn/g", 0.7529);
setprop("/MCDUC/colors/grn/b", 0.2941);
setprop("/MCDUC/colors/blu/r", 0.0901);
setprop("/MCDUC/colors/blu/g", 0.6039);
setprop("/MCDUC/colors/blu/b", 0.7176);
setprop("/MCDUC/colors/amb/r", 0.7333);
setprop("/MCDUC/colors/amb/g", 0.3803);
setprop("/MCDUC/colors/amb/b", 0.0000);
setprop("/MCDUC/colors/yel/r", 0.9333);
setprop("/MCDUC/colors/yel/g", 0.9333);
setprop("/MCDUC/colors/yel/b", 0.0000);
setprop("/MCDUC/colors/mag/r", 0.6902);
setprop("/MCDUC/colors/mag/g", 0.3333);
setprop("/MCDUC/colors/mag/b", 0.7541);
var WHITE = [1.0000,1.0000,1.0000];
var GREEN = [0.0509,0.7529,0.2941];
var BLUE = [0.0901,0.6039,0.7176];
var AMBER = [0.7333,0.3803,0.0000];
var YELLOW = [0.9333,0.9333,0.0000];
var MAGENTA = [0.6902,0.3333,0.7541];

# Fetch nodes:
var mcdu_keyboard_left = props.globals.getNode("/FMGC/keyboard-left", 0);
var mcdu_keyboard_right = props.globals.getNode("/FMGC/keyboard-right", 0);
var acconfig_weight_kgs = props.globals.getNode("/systems/acconfig/options/weight-kgs", 1);
var engRdy = props.globals.getNode("/engines/ready");

#ACCONFIG
var mcdu1_lgt = props.globals.getNode("/controls/lighting/DU/mcdu1", 1);
var mcdu2_lgt = props.globals.getNode("/controls/lighting/DU/mcdu2", 1);
var acType = props.globals.getNode("/MCDUC/type", 1);
var engType = props.globals.getNode("/MCDUC/eng", 1);
var database1 = props.globals.getNode("/FMGC/internal/navdatabase", 1);
var database2 = props.globals.getNode("/FMGC/internal/navdatabase2", 1);
var databaseCode = props.globals.getNode("/FMGC/internal/navdatabasecode", 1);

# RADNAV
var vor1 = props.globals.getNode("/FMGC/internal/vor1-mcdu", 1);
var vor2 = props.globals.getNode("/FMGC/internal/vor2-mcdu", 1);
var ils1 = props.globals.getNode("/FMGC/internal/ils1-mcdu", 1);
var adf1 = props.globals.getNode("/FMGC/internal/adf1-mcdu", 1);
var adf2 = props.globals.getNode("/FMGC/internal/adf2-mcdu", 1);
var vor1FreqSet = props.globals.getNode("/FMGC/internal/vor1freq-set", 1);
var vor1CRSSet = props.globals.getNode("/FMGC/internal/vor1crs-set", 1);
var vor2FreqSet = props.globals.getNode("/FMGC/internal/vor2freq-set", 1);
var vor2CRSSet = props.globals.getNode("/FMGC/internal/vor2crs-set", 1);
var ils1FreqSet = props.globals.getNode("/FMGC/internal/ils1freq-set", 1);
var ils1CRSSet = props.globals.getNode("/FMGC/internal/ils1crs-set", 1);
var adf1FreqSet = props.globals.getNode("/FMGC/internal/adf1freq-set", 1);
var adf2FreqSet = props.globals.getNode("/FMGC/internal/adf2freq-set", 1);
var ils1CRS = props.globals.getNode("/instrumentation/nav[0]/radials/selected-deg", 1);
var vor1CRS = props.globals.getNode("/instrumentation/nav[2]/radials/selected-deg", 1);
var vor2CRS = props.globals.getNode("/instrumentation/nav[3]/radials/selected-deg", 1);

# INT-A
var ADIRSMCDUBTN = props.globals.getNode("/controls/adirs/mcducbtn", 1);

# IRSINIT variables
var align_set = props.globals.getNode("/FMGC/internal/align-set", 1);

# ROUTE SELECTION

# INT-B

# FUELPRED
var state1 = props.globals.getNode("/engines/engine[0]/state", 1);
var state2 = props.globals.getNode("/engines/engine[1]/state", 1);

# PERF
var altitude = props.globals.getNode("/instrumentation/altimeter/indicated-altitude-ft", 1);

# TO PERF
var clbReducFt = props.globals.getNode("/systems/thrust/clbreduc-ft", 1);
var reducFt = props.globals.getNode("/FMGC/internal/accel-agl-ft", 1); # It's not AGL anymore
var thrAccSet = props.globals.getNode("/MCDUC/thracc-set", 1);
var flapTO = props.globals.getNode("/FMGC/internal/to-flap", 1);
var THSTO = props.globals.getNode("/FMGC/internal/to-ths", 1);
var flapTHSSet = props.globals.getNode("/FMGC/internal/flap-ths-set", 1);
var flex = props.globals.getNode("/FMGC/internal/flex", 1);
var flexSet = props.globals.getNode("/FMGC/internal/flex-set", 1);
var engOutAcc = props.globals.getNode("/FMGC/internal/eng-out-reduc", 1);
var engOutAccSet = props.globals.getNode("/MCDUC/reducacc-set", 1);
var managedSpeed = props.globals.getNode("/it-autoflight/input/spd-managed", 1);

# CLB PERF
var activate_once = props.globals.getNode("/FMGC/internal/activate-once", 1);
var activate_twice = props.globals.getNode("/FMGC/internal/activate-twice", 1);

# CRZ PERF

# DES PERF

# APPR PERF
var dest_qnh = props.globals.getNode("/FMGC/internal/dest-qnh", 1);
var dest_temp = props.globals.getNode("/FMGC/internal/dest-temp", 1);
var final = props.globals.getNode("/FMGC/internal/final", 1);
var radio = props.globals.getNode("/FMGC/internal/radio", 1);
var baro = props.globals.getNode("/FMGC/internal/baro", 1);

# GA PERF

# AOC - SENSORS
var parking_brake = props.globals.getNode("/controls/gear/brake-parking", 1);
var gear0_wow = props.globals.getNode("/gear/gear[0]/wow", 1);
var doorL1_pos = props.globals.getNode("/sim/model/door-positions/doorl1/position-norm", 1); #FWD door
var doorR1_pos = props.globals.getNode("/sim/model/door-positions/doorr1/position-norm", 1); #FWD door
var doorL4_pos = props.globals.getNode("/sim/model/door-positions/doorl4/position-norm", 1); #AFT door
var doorR4_pos = props.globals.getNode("/sim/model/door-positions/doorr4/position-norm", 1); #AFT door

# Fetch nodes into vectors
var pageProp = [props.globals.getNode("/MCDU[0]/page", 1), props.globals.getNode("/MCDU[1]/page", 1)];
var active = [props.globals.getNode("/MCDU[0]/active", 1), props.globals.getNode("/MCDU[1]/active", 1)];
var activeAtsu = [props.globals.getNode("/MCDU[0]/atsu-active", 1), props.globals.getNode("/MCDU[1]/atsu-active", 1)];
props.globals.initNode("/MCDU[0]/active-system", "", "STRING");
props.globals.initNode("/MCDU[1]/active-system", "", "STRING");


# Conversion factor pounds to kilogram
var LBS2KGS = 0.4535924;


# Create Nodes:
var pageSwitch = [props.globals.initNode("/MCDU[0]/internal/switch", 0, "BOOL"), props.globals.initNode("/MCDU[1]/internal/switch", 0, "BOOL")];

# Page freeze on POSMON
var pageFreezed = [nil,nil];
var togglePageFreeze = func(i) {
	if (pageFreezed[i] == nil) {
		pageFreezed[i] = sprintf("%02d%02d", getprop("/sim/time/utc/hour"), getprop("/sim/time/utc/minute"));
	} else {
		pageFreezed[i] = nil;
	}
}


var canvas_MCDU_base = {
	init: func(canvas_group, file) {
		var font_mapper = func(family, weight) {
			return "BoeingCDU-Large.ttf";
		};

		canvas.parsesvg(canvas_group, file, {"font-mapper": font_mapper});

		var svg_keys = me.getKeys();
		foreach(var key; svg_keys) {
			me[key] = canvas_group.getElementById(key);
			var svg_keys = me.getKeys();

			foreach (var key; svg_keys) {
				me[key] = canvas_group.getElementById(key);

				var clip_el = canvas_group.getElementById(key ~ "_clip");
				if (clip_el != nil) {
					clip_el.setVisible(0);
					var tran_rect = clip_el.getTransformedBounds();

					var clip_rect = sprintf("rect(%d,%d, %d,%d)", 
					tran_rect[1], # 0 ys
					tran_rect[2], # 1 xe
					tran_rect[3], # 2 ye
					tran_rect[0]); #3 xs
					#	coordinates are top,right,bottom,left (ys, xe, ye, xs) ref: l621 of simgear/canvas/CanvasElement.cxx
					me[key].set("clip", clip_rect);
					me[key].set("clip-frame", canvas.Element.PARENT);
				}
			}
		}
		
		me["PERFTO_FE"].setFont(symbol);
		me["PERFTO_SE"].setFont(symbol);
		me["PERFTO_OE"].setFont(symbol);
		me["PERFTO_FE"].setColor(BLUE);
		me["PERFTO_SE"].setColor(BLUE);
		me["PERFTO_OE"].setColor(BLUE);
		
		me["PERFAPPR_FE"].setFont(symbol);
		me["PERFAPPR_SE"].setFont(symbol);
		me["PERFAPPR_OE"].setFont(symbol);
		me["PERFAPPR_FE"].setColor(BLUE);
		me["PERFAPPR_SE"].setColor(BLUE);
		me["PERFAPPR_OE"].setColor(BLUE);
		
		me["PERFGA_FE"].setFont(symbol);
		me["PERFGA_SE"].setFont(symbol);
		me["PERFGA_OE"].setFont(symbol);
		me["PERFGA_FE"].setColor(BLUE);
		me["PERFGA_SE"].setColor(BLUE);
		me["PERFGA_OE"].setColor(BLUE);
		
		me.page = canvas_group;

		me.updateretard = 0; # skip a few page update to save CPU
		
		return me;
	},
	getKeys: func() {
		return ["Simple","Simple_Center","Scratchpad","Simple_Title","Simple_Title2","Simple_PageNum","ArrowLeft","ArrowRight","Simple_L1","Simple_L2","Simple_L3","Simple_L4",
	"Simple_L5","Simple_L6","Simple_L0S","Simple_L1S","Simple_L2S","Simple_L3S","Simple_L4S","Simple_L5S","Simple_L6S","Simple_L1_Arrow",
	"Simple_L2_Arrow","Simple_L3_Arrow","Simple_L4_Arrow","Simple_L5_Arrow","Simple_L6_Arrow","Simple_R1","Simple_R2","Simple_R3","Simple_R4","Simple_R5",
	"Simple_R6","Simple_R1S","Simple_R2S","Simple_R3S","Simple_R4S","Simple_R5S","Simple_R6S","Simple_R1_Arrow","Simple_R2_Arrow","Simple_R3_Arrow",
	"Simple_R4_Arrow","Simple_R5_Arrow","Simple_R6_Arrow","Simple_C1","Simple_C2","Simple_C3","Simple_C3B","Simple_C4","Simple_C4B","Simple_C5","Simple_C6","Simple_C1S",
	"Simple_C2S","Simple_C3S","Simple_C4S","Simple_C5S","Simple_C6S","INITA","INITA_CoRoute","INITA_FltNbr","INITA_CostIndex","INITA_CruiseFLTemp",
	"INITA_FromTo","INITA_InitRequest","INITA_AlignIRS","INITB","INITB_ZFWCG","INITB_ZFW","INITB_ZFWCG_S","INITB_Block","FUELPRED","FUELPRED_ZFW",
	"FUELPRED_ZFWCG","FUELPRED_ZFWCG_S","PROG","PROG_UPDATE","PERFTO","PERFTO_V1","PERFTO_VR","PERFTO_V2","PERFTO_FE","PERFTO_SE","PERFTO_OE","PERFAPPR",
	"PERFAPPR_FE","PERFAPPR_SE","PERFAPPR_OE","PERFAPPR_LDG_3","PERFAPPR_LDG_F","PERFGA","PERFGA_FE","PERFGA_SE","PERFGA_OE","FPLN","FPLN_From",
	"FPLN_TMPY_group","FPLN_FROM","FPLN_Callsign","departureTMPY", "arrowsDepArr","arrow1L","arrow2L","arrow3L","arrow4L","arrow5L","arrow1R","arrow2R",
	"arrow3R","arrow4R","arrow5R","DIRTO_TMPY_group","IRSINIT","IRSINIT_1","IRSINIT_2","IRSINIT_star","NOTIFY","NOTIFY_FLTNBR","NOTIFY_AIRPORT","WEATHERREQSEND",
	"WIND","WIND_CANCEL","WIND_INSERT_star","WIND_UPDOWN","MODEVHF3","PRINTPAGE","COMM-ADS","COCALL","COCALLTUNE","ATISSend1","ATISSend2","ATISSend3","ATISSend4",
	"ATISArrows"];
	},
	update: func() {
		if (systems.ELEC.Bus.ac1.getValue() >= 110 and mcdu1_lgt.getValue() > 0.01) {
			MCDU_1.update();
			MCDU_1.page.show();
		} else {
			MCDU_1.page.hide();
		}
		if (systems.ELEC.Bus.ac2.getValue() >= 110 and mcdu2_lgt.getValue() > 0.01) {
			MCDU_2.update();
			MCDU_2.page.show();
		} else {
			MCDU_2.page.hide();
		}
	},
	defaultHide: func() {
		me["Simple"].show();
		me["Simple_Center"].hide();
		me["Simple_Title2"].hide();
		me["FPLN"].hide();
		me["DIRTO_TMPY_group"].hide();
		me["INITA"].hide();
		me["IRSINIT"].hide();
		me["INITB"].hide();
		me["FUELPRED"].hide();
		me["WIND"].hide();
		me["PROG"].hide();
		me["PERFTO"].hide();
		me["arrowsDepArr"].hide();
		me["PERFAPPR"].hide();
		me["PERFGA"].hide();
		me["Simple_Title"].show();
	},
	defaultHideWithCenter: func() {
		me["Simple"].show();
		me["Simple_Center"].show();
		me["Simple_Title2"].hide();
		me["FPLN"].hide();
		me["DIRTO_TMPY_group"].hide();
		me["INITA"].hide();
		me["IRSINIT"].hide();
		me["INITB"].hide();
		me["FUELPRED"].hide();
		me["WIND"].hide();
		me["PROG"].hide();
		me["PERFTO"].hide();
	},
	defaultPageNumbers: func() {
		me["Simple_Title"].setColor(WHITE);
		me["Simple_PageNum"].setText("X/X");
		me["Simple_PageNum"].hide();
		me["ArrowLeft"].hide();
		me["ArrowRight"].hide();
	},
	showPageNumbers: func(pagno=0,pagcnt=0) {
		if (pagno == 0) return me.defaultPageNumbers();		
		me["Simple_PageNum"].show();		
		me["Simple_PageNum"].setText((pagcnt>0) ? pagno ~ "/" ~ pagcnt : pagno);
		me["ArrowLeft"].show();
		me["ArrowRight"].show();		
	},
	showPageNumbersOnly: func(pagno,pagcnt) {
		me["Simple_PageNum"].show();		
		me["Simple_PageNum"].setText(sprintf("%9s",pagno  ~ "/"  ~ pagcnt));
		me["ArrowLeft"].hide();
		me["ArrowRight"].hide();		
	},
	hideAllArrows: func() {
		me["Simple_L1_Arrow"].hide();
		me["Simple_L2_Arrow"].hide();
		me["Simple_L3_Arrow"].hide();
		me["Simple_L4_Arrow"].hide();
		me["Simple_L5_Arrow"].hide();
		me["Simple_L6_Arrow"].hide();
		me["Simple_R1_Arrow"].hide();
		me["Simple_R2_Arrow"].hide();
		me["Simple_R3_Arrow"].hide();
		me["Simple_R4_Arrow"].hide();
		me["Simple_R5_Arrow"].hide();
		me["Simple_R6_Arrow"].hide();
	},
	hideAllArrowsButL6: func() {
		me["Simple_L1_Arrow"].hide();
		me["Simple_L2_Arrow"].hide();
		me["Simple_L3_Arrow"].hide();
		me["Simple_L4_Arrow"].hide();
		me["Simple_L5_Arrow"].hide();
		me["Simple_L6_Arrow"].show();
		me["Simple_R1_Arrow"].hide();
		me["Simple_R2_Arrow"].hide();
		me["Simple_R3_Arrow"].hide();
		me["Simple_R4_Arrow"].hide();
		me["Simple_R5_Arrow"].hide();
		me["Simple_R6_Arrow"].hide();
	},
	standardFontSize: func() {
		me.fontLeft(default, default, default, default, default, default);
		me.fontLeftS(default, default, default, default, default, default);
		me.fontRight(default, default, default, default, default, default);
		me.fontRightS(default, default, default, default, default, default);
		me.fontSizeLeft(normal, normal, normal, normal, normal, normal);
		me.fontSizeLeftS(small, small, small, small, small, small);
		me.fontSizeRight(normal, normal, normal, normal, normal, normal);
		me.fontSizeRightS(small, small, small, small, small, small);
		me.fontCenter(default, default, default, default, default, default);
		me.fontCenterS(default, default, default, default, default, default);
		me.fontSizeCenter(normal, normal, normal, normal, normal, normal);
		me.fontSizeCenterS(small, small, small, small, small, small);
	},
	standardFontColour: func() {
		me.colorLeft("wht", "wht", "wht", "wht", "wht", "wht");
		me.colorLeftS("wht", "wht", "wht", "wht", "wht", "wht");
		me.colorLeftArrow("wht", "wht", "wht", "wht", "wht", "wht");
		me.colorRight("wht", "wht", "wht", "wht", "wht", "wht");
		me.colorRightS("wht", "wht", "wht", "wht", "wht", "wht");
		me.colorRightArrow("wht", "wht", "wht", "wht", "wht", "wht");
	},
	getLatLogFormatted: func(rootpropname) {
		var dms = getprop(rootpropname ~ "latitude-deg");
		var degrees = int(dms);
		var	minutes = sprintf("%.1f",abs((dms - degrees) * 60));
		var	sign = degrees >= 0 ? "N" : "S";
		var dms2 = getprop(rootpropname ~ "longitude-deg");
		var	degrees2 = int(dms2);
		var	minutes2 = sprintf("%.1f",abs((dms2 - degrees2) * 60));
		var	sign2 = degrees2 >= 0 ? "E" : "W";
		return sprintf("%d%.1f%s/%07s%s",abs(degrees),minutes,sign,abs(degrees2)  ~ minutes2,sign2);
	},
	getLatLogFormatted2: func(rootpropname) {
		var dms = getprop(rootpropname ~ "latitude-deg");
		var degrees = int(dms);
		var	minutes = sprintf("%.1f",abs((dms - degrees) * 60));
		var	sign = degrees >= 0 ? "N" : "S";
		var dms2 = getprop(rootpropname ~ "longitude-deg");
		var	degrees2 = int(dms2);
		var	minutes2 = sprintf("%.1f",abs((dms2 - degrees2) * 60));
		var	sign2 = degrees2 >= 0 ? "E" : "W";
		return sprintf("%d %.1f%s/%03s %.1f%s",abs(degrees),minutes,sign,abs(degrees2),minutes2,sign2);
	},
	getIRSStatus: func(a,b = 0) {
		var irsstatus = "INVAL";
		if (systems.ADIRS.ADIRunits[a].operative) {
			if (systems.ADIRS.Operating.aligned[a].getValue()) {
				irsstatus = (systems.ADIRS.ADIRunits[a].mode == 2) ? "ATT" : "NAV";
			} else {
				if (b) {
					irsstatus = "ALIGN TTN" ~ sprintf("%2d",math.round(systems.ADIRS.ADIRunits[a]._alignTime) / 60);
				} else {
					irsstatus = "ALIGN";
				}
			}
		}
		return irsstatus;
	},
	updateCommon: func(i) {
		page = pageProp[i].getValue();
		if (page != "NOTIFICATION") {
			me["NOTIFY"].hide();
			me["NOTIFY_FLTNBR"].hide();
			me["NOTIFY_AIRPORT"].hide();
		}
		if (page != "COMPANYCALL") {
			me["COCALL"].hide();
			me["COCALLTUNE"].hide();
		}
		if (page != "CONNECTSTATUS") {
			me["COMM-ADS"].hide();
		} else {
			me["COMM-ADS"].show();
		}
		if (page != "VOICEDIRECTORY") {
			me["MODEVHF3"].hide();
		} else {
			me["MODEVHF3"].show();
		}
		if (page != "WEATHERREQ") {
			me["WEATHERREQSEND"].hide();
		}
		if (page != "COMMINIT" and page != "COMPANYCALL" and page != "VOICEDIRECTORY" and page != "DATAMODE" and page != "COMMSTATUS") {
			me["PRINTPAGE"].hide();
		} else {
			me["PRINTPAGE"].show();
			if (page == "DATAMODE" or page == "COMMINIT") {
				me["PRINTPAGE"].setColor(BLUE);
			} else {
				me["PRINTPAGE"].setColor(WHITE);
			}
		}

		if (!pageSwitch[i].getBoolValue()) me.defaultHide();

		if (page != "ATIS") {
			me["ATISSend1"].hide();
			me["ATISSend2"].hide();
			me["ATISSend3"].hide();
			me["ATISSend4"].hide();
		}
		if (page != "ATISDETAIL") {
			me["ATISArrows"].hide();
		}
		if (page == "F-PLNA" or page == "F-PLNB") {
			if (!pageSwitch[i].getBoolValue()) {
				me["Simple"].show();
				me["Simple_Center"].show();
				me["FPLN"].show();
				me["DIRTO_TMPY_group"].hide();
				me["INITA"].hide();
				me["IRSINIT"].hide();
				me["INITB"].hide();
				me["FUELPRED"].hide();
				me["WIND"].hide();
				me["PROG"].hide();
				me["PERFTO"].hide();
				me["PERFAPPR"].hide();
				me["PERFGA"].hide();
				me["Simple_Title"].hide();
				me["Simple_PageNum"].hide();
				me["ArrowLeft"].show();
				me["ArrowRight"].show();
				me["arrowsDepArr"].hide();
				
				me["Simple_L0S"].hide();
				me["Simple_C3B"].hide();
				me["Simple_C4B"].hide();
				
				me.hideAllArrows();
				
				me.fontLeft(default, default, default, default, default, default);
				me.fontLeftS(default, default, default, default, default, default);
				me.fontRight(default, default, default, default, default, default);
				me.fontRightS(default, default, default, default, default, default);
				
				me.fontSizeLeft(normal, normal, normal, normal, normal, normal);
				me.fontSizeCenter(normal, normal, normal, normal, normal, normal);
				me.fontSizeRight(normal, normal, normal, normal, normal, normal);
				pageSwitch[i].setBoolValue(1);
			}
			
			if (myFpln[i] != nil) {
				
				if (fmgc.FMGCInternal.flightNumSet) {
					me["FPLN_Callsign"].setText(fmgc.FMGCInternal.flightNum);
					me["FPLN_Callsign"].show();
				} else {
					me["FPLN_Callsign"].hide();
				}

				me.dynamicPageFunc(myFpln[i].L1, "Simple_L1");
				me.dynamicPageFunc(myFpln[i].L2, "Simple_L2");
				me.dynamicPageFunc(myFpln[i].L3, "Simple_L3");
				me.dynamicPageFunc(myFpln[i].L4, "Simple_L4");
				me.dynamicPageFunc(myFpln[i].L5, "Simple_L5");
				
				me.colorLeft(myFpln[i].L1[2],myFpln[i].L2[2],myFpln[i].L3[2],myFpln[i].L4[2],myFpln[i].L5[2],myFpln[i].L6[2]);
				
				me.dynamicPageFunc(myFpln[i].C1, "Simple_C1");
				me.dynamicPageFunc(myFpln[i].C2, "Simple_C2");
				me.dynamicPageFunc(myFpln[i].C3, "Simple_C3");
				me.dynamicPageFunc(myFpln[i].C4, "Simple_C4");
				me.dynamicPageFunc(myFpln[i].C5, "Simple_C5");
				
				me.colorCenter(myFpln[i].C1[2],myFpln[i].C2[2],myFpln[i].C3[2],myFpln[i].C4[2],myFpln[i].C5[2],myFpln[i].C6[2]);
					
				me.dynamicPageFunc(myFpln[i].R1, "Simple_R1");
				me.dynamicPageFunc(myFpln[i].R2, "Simple_R2");
				me.dynamicPageFunc(myFpln[i].R3, "Simple_R3");
				me.dynamicPageFunc(myFpln[i].R4, "Simple_R4");
				me.dynamicPageFunc(myFpln[i].R5, "Simple_R5");
				
				me.colorRight(myFpln[i].R1[2],myFpln[i].R2[2],myFpln[i].R3[2],myFpln[i].R4[2],myFpln[i].R5[2],myFpln[i].R6[2]);
				
				me.colorLeftS("wht", "wht", "wht", "wht", "wht", "wht");
				me.colorLeftArrow("wht", "wht", "wht", "wht", "wht", "wht");
				me.colorRightS("wht", "wht", "wht", "wht", "wht", "wht");
				me.colorRightArrow("wht", "wht", "wht", "wht", "wht", "wht");
				
				if (myFpln[i].scroll == 0) {
					me["FPLN_FROM"].show();
				} else {
					me["FPLN_FROM"].hide();
				}
				
				if (fmgc.flightPlanController.temporaryFlag[i]) {
					me["Simple_L6"].hide();
					me["Simple_C6"].hide();
					me["Simple_R6"].hide();
					me["Simple_L6S"].hide();
					me["Simple_C6S"].hide();
					me["Simple_R6S"].hide();
					if (!mcdu.dirToFlag) {
						me["FPLN_TMPY_group"].show();
						me["DIRTO_TMPY_group"].hide();
					} else {
						me["DIRTO_TMPY_group"].show();
						me["FPLN_TMPY_group"].hide();
					}
				} else {
					me["FPLN_TMPY_group"].hide();
					me["DIRTO_TMPY_group"].hide();
					me.dynamicPageFunc(myFpln[i].L6, "Simple_L6");
					me.dynamicPageFunc(myFpln[i].C6, "Simple_C6");
					me.dynamicPageFunc(myFpln[i].R6, "Simple_R6");
				}
			}
		} else if (page == "MCDU") {
			if (!pageSwitch[i].getBoolValue()) {
				me.defaultHide();
				me["Simple_Title"].setText("MCDU MENU");
				me.defaultPageNumbers();
				
				me.showLeft(1, 1, 1, 1, -1, -1);
				me["Simple_L0S"].hide();
				me.showLeftS(-1, -1, -1, -1, -1, -1);
				me.showLeftArrow(1, 1, 1, 1, -1, -1);
				me.showRight(-1, -1, -1, -1, -1, -1);
				me.showRightS(-1, -1, -1, -1, -1, -1);
				me.showRightArrow(-1, -1, -1, -1, -1, -1);
				me["Simple_C3B"].hide();
				me["Simple_C4B"].hide();
				
				me.standardFontSize();
				me.standardFontColour();
				me["Simple_L3"].setText(" AIDS");
				me["Simple_L4"].setText(" CFDS");

				pageSwitch[i].setBoolValue(1);
			}
			
			if (active[i].getValue() == 0) {
				me["Simple_L1"].setText(" FMGC");
				me["Simple_L1"].setColor(WHITE);  
				me["Simple_L1_Arrow"].setColor(WHITE);	
			} else if (active[i].getValue() == 1) {
				me["Simple_L1"].setText(" FMGC (SEL)");
				me["Simple_L1"].setColor(BLUE);
				me["Simple_L1_Arrow"].setColor(BLUE);
			} else if (active[i].getValue() == 2) {
				me["Simple_L1"].setText(" FMGC");
				me["Simple_L1"].setColor(GREEN);
				me["Simple_L1_Arrow"].setColor(GREEN);
			}
			
			if (activeAtsu[i].getValue() == 0) {
				me["Simple_L2"].setText(" ATSU");
				me["Simple_L2"].setColor(WHITE);
				me["Simple_L2_Arrow"].setColor(WHITE);
			} else if (activeAtsu[i].getValue() == 1) {
				me["Simple_L2"].setText(" ATSU (SEL)");
				me["Simple_L2"].setColor(BLUE);
				me["Simple_L2_Arrow"].setColor(BLUE);
			} else if (activeAtsu[i].getValue() == 2) {
				me["Simple_L2"].setText(" ATSU");
				me["Simple_L2"].setColor(GREEN);
				me["Simple_L2_Arrow"].setColor(GREEN);
			}
		} else if (page == "ATSUDLINK") {
			if (!pageSwitch[i].getBoolValue()) {
				me.defaultHide();
				me["Simple_Title"].setText("ATSU DATALINK");
				me.defaultPageNumbers();
				
				me.showLeft(1, -1, -1, -1, -1, -1);
				me["Simple_L0S"].hide();
				me.showLeftS(-1, -1, -1, -1, -1, -1);
				me.showLeftArrow(1, -1, -1, -1, -1, -1);
				me.showRight(1, -1, -1, -1, -1, 1);
				me.showRightS(-1, -1, -1, -1, -1, -1);
				me.showRightArrow(1, -1, -1, -1, -1, 1);
				me["Simple_C3B"].hide();
				me["Simple_C4B"].hide();
				
				me.standardFontSize();
				me.standardFontColour();
				me["Simple_L1"].setText(" ATC MENU");
				me["Simple_R1"].setText("AOC MENU ");
				me["Simple_R6"].setText("COMM MENU ");
				pageSwitch[i].setBoolValue(1);
			}
		} else if (page == "AOCMENU") {
			if (!pageSwitch[i].getBoolValue()) {
				me.defaultHide();
				me["Simple_Title"].setText("AOC MENU");
				me.defaultPageNumbers();
				
				me.showLeft(1, 1, 1, -1, 1, 1);
				me["Simple_L0S"].hide();
				me.showLeftS(-1, -1, -1, -1, -1, 1);
				me.showLeftArrow(1, 1, 1, -1, 1, 1);
				me.showRight(1, 1, 1, 1, 1, -1);
				me.showRightS(-1, -1, -1, -1, -1, -1);
				me.showRightArrow(1, 1, 1, 1, 1, 1);
				me["Simple_C3B"].hide();
				me["Simple_C4B"].hide();
				
				me.standardFontSize();
				me.standardFontColour();
				me["Simple_R6"].setColor(BLUE);
				me["Simple_R6_Arrow"].setColor(BLUE);
				
				me["Simple_L1"].setText(" PREFLIGHT");
				me["Simple_L2"].setText(" ENROUTE");
				me["Simple_L3"].setText(" POSTFLIGHT");
				me["Simple_L5"].setText(" SNAG");
				me["Simple_L6S"].setText(" ATSU DLK");
				me["Simple_L6"].setText(" RETURN");
				
				me["Simple_R1"].setText("FLT LOG ");
				me["Simple_R2"].setText("WEATHER REQ ");
				me["Simple_R3"].setText("RCVD MSGS ");
				me["Simple_R4"].setText("REPORTS ");
				me["Simple_R5"].setText("CONFIG ");
				me["Simple_R6"].setText("MESSAGE ");
				pageSwitch[i].setBoolValue(1);
			}
			
			if (mcdu.ReceivedMessagesDatabase.firstUnviewed() != -99) {
				me["Simple_R6"].show();
				me["Simple_R6_Arrow"].show();
			} else {
				me["Simple_R6"].hide();
				me["Simple_R6_Arrow"].hide();
			}
		} else if (page == "FLTLOG") {
			if (!pageSwitch[i].getBoolValue()) {
				me.defaultHideWithCenter();

				me["Simple_L0S"].hide();
				me["ArrowLeft"].hide();
				me["ArrowRight"].hide();				

				me.showLeft(1, 1, 1, 1, 1, -1);								
				me.showLeftS(1, -1, 1, 1, 1, -1);
				me.showLeftArrow(-1, -1, -1, -1, -1, -1);
				me.showCenter(-1, 1, 1, 1, 1, -1);
				me.showCenterS(-1, 1, 1, 1, 1, -1);
				me.showRight(1, 1, 1, 1, 1, -1);
				me.showRightS(1, 1, 1, 1, 1, -1);
				me.showRightArrow(-1, -1, -1, -1, 1, -1);
				me["Simple_C3B"].hide();
				me["Simple_C4B"].hide();				
				
				me.standardFontSize();
				me.standardFontColour();
				me.colorCenterS("wht", "wht", "wht", "wht", "wht", "wht");
				me.colorCenter("wht", "wht", "wht", "wht", "wht", "wht");

				#me["PRINTPAGE"] - TODO missing asterisk at 5L - only useful when printing available

				me["Simple_L1S"].setText(" FLT NUM-DATE");				
				me["Simple_R1S"].setText("ORIG-DEST ");
				me["Simple_L1"].setFontSize(small);				
				me["Simple_R1"].setFontSize(small);
				me["Simple_L2"].setFontSize(small);
				me["Simple_C2"].setFontSize(small);
				me["Simple_R2"].setFontSize(small);
				me["Simple_L3"].setFontSize(small);
				me["Simple_C3"].setFontSize(small);
				me["Simple_R3"].setFontSize(small);

				me["Simple_L5"].setText(" PRINT");
				me["Simple_L5"].setColor(BLUE);

				me["Simple_R5"].setText("SENSORS ");
				me["Simple_R5"].setColor(WHITE);

				me["Simple_L4"].setFontSize(small);
				me["Simple_L4"].setText(" FLIGHT");
				me["Simple_C4"].setFontSize(small);
				me["Simple_C4"].setText("--TIMES--");
				me["Simple_R4"].setFontSize(small);
				me["Simple_R4"].setText("BLOCK ");

				me["Simple_C2S"].setText("TIME");
				me["Simple_R2S"].setText("FOB ");

				me["Simple_L2"].setText( "   OUT   -");
				me["Simple_L3S"].setText("   OFF   -");
				me["Simple_L3"].setText( "    ON   -");
				me["Simple_L4S"].setText("    IN   -");
				
				me["Simple_C5"].setFontSize(small);

				pageSwitch[i].setBoolValue(1);
			}

			var logid = 1; #mcdu.FlightLogDatabase.getPageSize(); - one page only - TODO:  multi pages
			if (logid == 0) logid = 1;

			me.showPageNumbersOnly(1,1);
			me["Simple_Title"].setText(sprintf("FLT LOG.%04d",logid));

			me["Simple_C2"].setText( "--.--"); #TODO - missing ":" char on fontset
			me["Simple_C3S"].setText("--.--");
			me["Simple_C3"].setText( "--.--");
			me["Simple_C4S"].setText("--.--");
			me["Simple_R2"].setText( "---.- ");
			me["Simple_R3S"].setText("---.- ");
			me["Simple_R3"].setText( "---.- ");
			me["Simple_R4S"].setText("---.- ");
			me.colorCenter("wht", "grn", "grn", "wht", "wht", "wht");
			me.colorRight("wht", "grn", "grn", "wht", "wht", "wht");
			me.colorLeftS("wht", "wht", "wht", "wht", "grn", "wht");
			me.colorCenterS("wht", "wht", "grn", "grn", "grn", "wht");
			me.colorRightS("wht", "wht", "grn", "grn", "grn", "wht");

			var rowsC = ["Simple_C2","Simple_C3S","Simple_C3","Simple_C4S"];
			var rowsR = ["Simple_R2","Simple_R3S","Simple_R3","Simple_R4S"];
			var logs = mcdu.FlightLogDatabase.getLogByPage(logid);
			var len = size(logs);
			var flgtime = 0;
			var blktime = 0;
			for ( var i = 0; i < len; i = i + 1 ) {
				if (logs[i] != nil) { # only valid reports
					var p = logs[i].state;
					if (p == 4) p = 3; # RETURN-IN
					me[rowsC[p]].setText(logs[i].time);
					me[rowsR[p]].setText(sprintf("%3.1f ",logs[i].fob));
				}
			}

			var logpage = mcdu.FlightLogDatabase.getPage(logid);

			me["Simple_L1"].setText(sprintf("%8s- ",logpage.fltnum) ~ logpage.date);
			me["Simple_R1"].setText(logpage.tofrom ~ " ");

			me["Simple_L5S"].setText( " " ~ logpage.flttime );
			me["Simple_C5S"].setText(sprintf("%02.0f", getprop("/sim/time/utc/hour")) ~ "." ~ sprintf("%02.0f", getprop("/sim/time/utc/minute")) ~ "." ~ sprintf("%02.0f", getprop("/sim/time/utc/second")));
			me["Simple_R5S"].setText( logpage.blktime ~ " " );

			var fltstate = logpage.fltstate;
			if (fltstate == "") {
			  fltstate = (fmgc.FMGCInternal.toFromSet) ? "BEGIN" : "RESET";  #CHECKME - my best guess, only ready when plan inserted
			  #TODO Pushback detection -> WPUSH state???
			}   
			me["Simple_C5"].setText(fltstate); 

		} else if (page == "SENSORS") {
			if (!pageSwitch[i].getBoolValue()) {
				me.defaultHide();
				me.standardFontSize();
				me["Simple_Title"].setText("SENSORS       ");
				me.defaultPageNumbers();
				me["Simple_L0S"].hide();

				me.showLeft(1, 1, 1, 1, 1, 1);
				me.showLeftS(1, 1, 1, 1, -1, -1);
				me.showLeftArrow(-1, -1, -1, -1, -1, 1);
				me.colorLeftArrow("wht", "wht", "wht", "wht", "wht", "wht");
				me.showRight(1, 1, 1, 1, -1, -1);
				me.showRightS(1, 1, 1, 1, -1, -1);
				me.showRightArrow(-1, -1, -1, -1, -1, -1);
				
				#me["PRINTPAGE"] - TODO missing asterisk at 5L - only useful when printing available

				me.standardFontSize();
				me.standardFontColour();

				me["Simple_L1"].setFontSize(small);				
				me["Simple_R1"].setFontSize(small);
				me["Simple_L2"].setFontSize(small);
				me["Simple_R2"].setFontSize(small);
				me["Simple_L3"].setFontSize(small);
				me["Simple_R3"].setFontSize(small);
				me["Simple_L4"].setFontSize(small);
				me["Simple_R4"].setFontSize(small);
				
				me.colorRight("grn", "grn", "grn", "grn", "grn", "grn");
				me.colorRightS("grn", "grn", "grn", "grn", "grn", "grn");

				me["Simple_L1S"].setText("  PARK BRAKE");
				me["Simple_L1"].setText( "  NOSE STRUT");
				me["Simple_L2S"].setText( "  L FWD DOOR");
				me["Simple_L2"].setText( "  R FWD DOOR");
				me["Simple_L3S"].setText( "  L AFT DOOR");
				me["Simple_L3"].setText( "  R AFT DOOR");
				me["Simple_L4S"].setText( "  GND SPEED");
				me["Simple_L4"].setText( "  FOB");

				me["Simple_L5"].setText(" PRINT");
				me["Simple_L5"].setColor(BLUE);

				me["Simple_L6"].setText(" RETURN");

				pageSwitch[i].setBoolValue(1);
			}

			me["Simple_R1S"].setText(sprintf("%-10s",(parking_brake.getValue() == 1) ? "SET" : "RELEASED"));
			me["Simple_R1"].setText(sprintf("%-10s",(gear0_wow.getValue() == 1) ? "GROUND" : "FLIGHT"));
			me["Simple_R2S"].setText(sprintf("%-10s",(doorL1_pos.getValue() > 0.1) ? "OPEN" : "CLOSED"));
			me["Simple_R2"].setText(sprintf("%-10s",(doorR1_pos.getValue() > 0.1) ? "OPEN" : "CLOSED"));
			me["Simple_R3S"].setText(sprintf("%-10s",(doorL4_pos.getValue() > 0.1) ? "OPEN" : "CLOSED"));
			me["Simple_R3"].setText(sprintf("%-10s",(doorR4_pos.getValue() > 0.1) ? "OPEN" : "CLOSED"));
			me["Simple_R4S"].setText(sprintf("%-10s",sprintf("%03.3f",pts.Velocities.groundspeed.getValue())));
			me["Simple_R4"].setText(sprintf("%-10s",sprintf("%03.1f",fmgc.FMGCInternal.fob)));

		} else if (page == "AOCCONFIG") {
			if (!pageSwitch[i].getBoolValue()) {
				me.defaultHideWithCenter();
				me["Simple_Title"].setText("AOC CONFIGURATION");
				me.defaultPageNumbers();
				
				me.showLeft(1, -1, -1, -1, -1, 1);
				me["Simple_L0S"].hide();
				me.showLeftS(1, -1, -1, -1, -1, 1);
				me.showLeftArrow(-1, -1, -1, -1, -1, 1);
				me.showCenter(1, 1, 1, 1, 1, -1);
				me.showCenterS(1, -1, 1, -1, 1, -1);
				me.showRight(1, -1, -1, -1, -1, 1);
				me.showRightS(1, -1, -1, -1, -1, -1);
				me.showRightArrow(-1, -1, -1, -1, -1, -1);
				me["Simple_C3B"].hide();
				me["Simple_C4B"].hide();
				
				me.standardFontSize();
				me.standardFontColour();
				
				me["Simple_L1S"].setText("A/C REG");
				me["Simple_L1"].setFontSize(small);
				me["Simple_L1"].setColor(GREEN);
				me["Simple_C1S"].setColor(GREEN);
				me["Simple_R1"].setFontSize(small);
				me["Simple_R1"].setColor(GREEN);
				me["Simple_R1S"].setText("TYPE");
				me["Simple_L6S"].setText(" RETURN TO");
				me["Simple_L6"].setText(" AOC MENU");
				me["Simple_C2"].setText("ATSU SW AND DB PN");
				me["Simple_C3S"].setText("998.2459.501");
				me["Simple_C3S"].setFontSize(small);
				me["Simple_C3S"].setColor(GREEN);
				me["Simple_C3"].setText("998.2460.501");
				me["Simple_C3"].setFontSize(small);
				me["Simple_C3"].setColor(GREEN);
				me["Simple_C4"].setText("ATSU AOC ID");
				me["Simple_C5S"].setText("AS2TOC1015010F1");
				me["Simple_C5S"].setFontSize(small);
				me["Simple_C5S"].setColor(GREEN);
				me["Simple_C5"].setText("AS2TOC1012001F2");
				me["Simple_C5"].setFontSize(small);
				me["Simple_C5"].setColor(GREEN);
				me["Simple_R6"].setText("PRINT ");
				me["Simple_R6"].setColor(BLUE);
				me["Simple_C1"].setFontSize(small);
				me["Simple_C1"].setColor(GREEN);
				pageSwitch[i].setBoolValue(1);
			}
			me["Simple_L1"].setText(getprop("/options/model-options/registration"));
			me["Simple_C1S"].setText(sprintf("%02.0f", getprop("/sim/time/utc/hour")) ~ sprintf("%02.0f", getprop("/sim/time/utc/minute")));
			me["Simple_C1"].setText(sprintf("%02.0f", getprop("/sim/time/utc/day")) ~ "/" ~ sprintf("%02.0f", getprop("/sim/time/utc/month")) ~ "/" ~ right(sprintf(getprop("/sim/time/utc/year")), 2));
			me["Simple_R1S"].setText("TYPE");
			me["Simple_R1"].setText(getprop("/MCDUC/type"));
		} else if (page == "WEATHERREQ") {
			if (!pageSwitch[i].getBoolValue()) {
				me.defaultHide();
				me["Simple_Title"].setText("WEATHER REQ");
				me.defaultPageNumbers();
				
				me.showLeft(1, -1, -1, -1, -1, 1);
				me["Simple_L0S"].hide();
				me.showLeftS(1, -1, -1, -1, -1, -1);
				me.showLeftArrow(1, -1, -1, -1, -1, 1);
				me.showRight(1, 1, 1, -1, 1, -1);
				me.showRightS(1, 1, 1, -1, -1, -1);
				me.showRightArrow(-1, -1, -1, -1, -1, -1);
				me["Simple_C3B"].hide();
				me["Simple_C4B"].hide();
				
				me.fontLeft(default, default, default, default, default, default);
				me.fontLeftS(default, default, default, default, default, default);
				me.fontRight(symbol, symbol, symbol, default, default, default);
				me.fontRightS(default, default, default, default, default, default);
				me.fontSizeLeft(normal, normal, normal, normal, normal, normal);
				me.fontSizeRight(normal, normal, normal, normal, normal, normal);
				me.colorLeft("wht", "wht", "wht", "wht", "wht", "wht");
				me.colorLeftS("wht", "wht", "wht", "wht", "wht", "wht");
				me.colorLeftArrow("wht", "wht", "wht", "wht", "wht", "wht");
				me.colorRight("blu", "blu", "blu", "wht", "blu", "wht");
				me.colorRightS("wht", "wht", "wht", "wht", "wht", "wht");
				me.colorRightArrow("wht", "wht", "wht", "wht", "wht", "wht");
				
				me["Simple_L1"].setText(" WEATHER TYPE");
				me["Simple_L1S"].setText(" " ~ atsu.AOC.selectedType);
				me["Simple_R1S"].setText("STA 1 ");
				me["Simple_R2"].setText("[    ]");
				me["Simple_R2S"].setText("STA 2 ");
				me["Simple_R3"].setText("[    ]");
				me["Simple_R3S"].setText("STA 3 ");
				pageSwitch[i].setBoolValue(1);
			}
			
			if (atsu.AOC.station != nil) {
				me["Simple_R1"].setFont(default);
				me["Simple_R1"].setText(atsu.AOC.station);
				if (atsu.AOC.sent and !atsu.AOC.received) {
					me["WEATHERREQSEND"].hide();
				} else {
					me["WEATHERREQSEND"].show();
				}
				
				if (atsu.AOC.sent) {
					me["Simple_R5"].setText(atsu.AOC.sentTime ~ " SEND ");
				} else {
					me["Simple_R5"].setText("SEND ");
				}
			} else {
				me["Simple_R5"].setText("SEND ");
				me["Simple_R1"].setFont(symbol);
				me["Simple_R1"].setText("[    ]");
				me["WEATHERREQSEND"].hide();
			}
			
			me._receivedTime = left(getprop("/sim/time/gmt-string"), 5);
			me.receivedTime = split(":", me._receivedTime)[0] ~ "." ~ split(":", me._receivedTime)[1] ~ "Z";
			me["Simple_L6"].setText(" RETURN " ~ me.receivedTime);
		} else if (page == "WEATHERTYPE") {
			if (!pageSwitch[i].getBoolValue()) {
				me.defaultHide();
				me["Simple_Title"].setText("WEATHER TYPE");
				me.defaultPageNumbers();
				
				me.showLeft(1, 1, 1, -1, -1, -1);
				me["Simple_L0S"].hide();
				me.showLeftS(-1, -1, -1, -1, -1, -1);
				me.showLeftArrow(1, 1, 1, -1, -1, -1);
				me.showRight(1, 1, 1, -1, -1, -1);
				me.showRightS(-1, -1, -1, -1, -1, -1);
				me.showRightArrow(1, 1, 1, -1, -1, -1);
				me["Simple_C3B"].hide();
				me["Simple_C4B"].hide();
				
				me.standardFontSize();
				me.standardFontColour();
				
				me["Simple_L1"].setText(" HOURLY WX");
				me["Simple_L2"].setText(" AREA FCST");
				me["Simple_L3"].setText(" FLD CONDX");
				me["Simple_R1"].setText("TERM FCST ");
				me["Simple_R2"].setText("NOTAMS ");
				me["Simple_R3"].setText("SEVERE WX ");
				pageSwitch[i].setBoolValue(1);
			}
		} else if (page == "RECEIVEDMSGS") {
			if (!pageSwitch[i].getBoolValue()) {
				me.defaultHide();
				me["Simple_Title"].show();
				me["arrowsDepArr"].hide();
				me.hideAllArrowsButL6();
				
				me["Simple_L0S"].hide();
				me["Simple_L6S"].hide();
				me["Simple_C3B"].hide();
				me["Simple_C4B"].hide();
				
				me.fontLeft(default, default, default, default, default, default);
				me.fontLeftS(default, default, default, default, default, default);
				me.fontRight(default, default, default, default, default, default);
				me.fontRightS(default, default, default, default, default, default);
				
				me.fontSizeLeft(normal, normal, normal, normal, normal, normal);
				me.fontSizeCenter(normal, normal, normal, normal, normal, normal);
				me.fontSizeRight(normal, normal, normal, normal, normal, normal);
				
				me.colorLeftS("wht", "wht", "wht", "wht", "wht", "wht");
				me.colorRightS("wht", "wht", "wht", "wht", "wht", "wht");
				
				me.showRight(-1, -1, -1, -1, -1, -1);
				me.showRightS(-1, -1, -1, -1, -1, -1);
				me.showRightArrow(-1, -1, -1, -1, -1, -1);
				
				if (myReceivedMessages[i] != nil) {
					me["Simple_Title"].setText(sprintf("%s", myReceivedMessages[i].title));
				
					me["Simple_L6_Arrow"].setColor(getprop("/MCDUC/colors/" ~ myReceivedMessages[i].arrowsColour[0][5] ~ "/r"), getprop("/MCDUC/colors/" ~ myReceivedMessages[i].arrowsColour[0][5] ~ "/g"), getprop("/MCDUC/colors/" ~ myReceivedMessages[i].arrowsColour[0][5] ~ "/b"));
					
					if (mcdu.ReceivedMessagesDatabase.getCountPages() > 1) {
						me["Simple_PageNum"].show();
						me["Simple_PageNum"].setText(myReceivedMessages[i].getPageNumStr());
						me["ArrowLeft"].show();
						me["ArrowRight"].show();
					} else {
						me["Simple_PageNum"].hide();
						me["ArrowLeft"].hide();
						me["ArrowRight"].hide();
					}
					
					me.dynamicPageFontFunc(myReceivedMessages[i]);
					me.dynamicPageArrowFunc(myReceivedMessages[i]);
					
					me.dynamicPageFunc(myReceivedMessages[i].L1, "Simple_L1");
					me.dynamicPageFunc(myReceivedMessages[i].L2, "Simple_L2");
					me.dynamicPageFunc(myReceivedMessages[i].L3, "Simple_L3");
					me.dynamicPageFunc(myReceivedMessages[i].L4, "Simple_L4");
					me.dynamicPageFunc(myReceivedMessages[i].L5, "Simple_L5");
					me.colorLeft(myReceivedMessages[i].L1[2],myReceivedMessages[i].L2[2],myReceivedMessages[i].L3[2],myReceivedMessages[i].L4[2],myReceivedMessages[i].L5[2],myReceivedMessages[i].L6[2]);
					me["Simple_L6"].setColor(WHITE);
				}
				pageSwitch[i].setBoolValue(1);
			}
				
			if (myReceivedMessages[i] != nil) {
				me._receivedTime = left(getprop("/sim/time/gmt-string"), 5);
				me.receivedTime = split(":", me._receivedTime)[0] ~ "." ~ split(":", me._receivedTime)[1] ~ "Z";
				me["Simple_L6"].setText(" RETURN " ~ me.receivedTime);
			}
		} else if (page == "RECEIVEDMSG") {
			if (!pageSwitch[i].getBoolValue()) {
				me.defaultHideWithCenter();
				me["Simple_Title"].show();
				me["arrowsDepArr"].hide();
				me.hideAllArrowsButL6();
				me["Simple_PageNum"].hide();
				me["ArrowLeft"].hide();
				me["ArrowRight"].hide();
				
				me["Simple_L0S"].hide();
				me["Simple_L6S"].hide();
				me["Simple_C3B"].hide();
				me["Simple_C4B"].hide();
				
				me.fontLeft(default, default, default, default, default, default);
				me.fontLeftS(default, default, default, default, default, default);
				me.fontRight(default, default, default, default, default, default);
				me.fontRightS(default, default, default, default, default, default);
				
				me.fontSizeLeft(small, small, small, small, small, normal);
				me.fontSizeCenter(normal, normal, normal, normal, normal, normal);
				me.fontSizeRight(normal, normal, normal, normal, normal, normal);
				
				me.colorLeftS("grn", "wht", "wht", "wht", "wht", "wht");
				me.colorCenterS("grn", "wht", "wht", "wht", "wht", "wht");
				me.colorRightS("wht", "wht", "wht", "wht", "wht", "wht");
				
				me.showCenter(-1, -1, -1, -1, -1, -1);
				me.showCenterS(1, -1, -1, -1, -1, -1);
				me.showRight(-1, -1, -1, -1, -1, -1);
				me.showRightS(1, -1, -1, -1, -1, -1);
				me.showRightArrow(-1, -1, -1, -1, -1, -1);
				
				
				if (myReceivedMessage[i] != nil) {
					me["Simple_Title"].setText(sprintf("%s", myReceivedMessage[i].title));
				
					me["Simple_L6_Arrow"].setColor(getprop("/MCDUC/colors/" ~ myReceivedMessage[i].arrowsColour[0][5] ~ "/r"), getprop("/MCDUC/colors/" ~ myReceivedMessage[i].arrowsColour[0][5] ~ "/g"), getprop("/MCDUC/colors/" ~ myReceivedMessage[i].arrowsColour[0][5] ~ "/b"));
					
					forindex (var matrixFont; myReceivedMessages[i].fontMatrix) {
						if (matrixFont == 0) { 
							var sign = "L"; 
						} else { 
							var sign = "R"; 
						}
						forindex (var item; myReceivedMessages[i].fontMatrix[matrixFont]) {
							if (myReceivedMessages[i].fontMatrix[matrixFont][item] == 1) {
								me["Simple_" ~ sign ~ (item + 1)].setFont(symbol);
							} else {
								me["Simple_" ~ sign ~ (item + 1)].setFont(default);
							}
						}
					}
					
					me.dynamicPageArrowFunc(myReceivedMessage[i]);
					
					if (myReceivedMessage[i].L1[0] != nil) {
						me["Simple_L1"].setText(myReceivedMessage[i].L1[0]);
						me["Simple_L1"].show();
					} else { me["Simple_L1"].hide(); }
					if (myReceivedMessage[i].L1[1] != nil) {
						me["Simple_L1S"].setText(myReceivedMessage[i].L1[1]);
						me["Simple_L1S"].show();
					} else { me["Simple_L1S"].hide(); }
					if (myReceivedMessage[i].L2[0] != nil) {
						me["Simple_L2"].setText(myReceivedMessage[i].L2[0]);
						me["Simple_L2"].show();
					} else { me["Simple_L2"].hide(); }
					if (myReceivedMessage[i].L2[1] != nil) {
						me["Simple_L2S"].setText(myReceivedMessage[i].L2[1]);
						me["Simple_L2S"].show();
					} else { me["Simple_L2S"].hide(); }
					if (myReceivedMessage[i].L3[0] != nil) {
						me["Simple_L3"].setText(myReceivedMessage[i].L3[0]);
						me["Simple_L3"].show();
					} else { me["Simple_L3"].hide(); }
					if (myReceivedMessage[i].L3[1] != nil) {
						me["Simple_L3S"].setText(myReceivedMessage[i].L3[1]);
						me["Simple_L3S"].show();
					} else { me["Simple_L3S"].hide(); }
					if (myReceivedMessage[i].L4[0] != nil) {
						me["Simple_L4"].setText(myReceivedMessage[i].L4[0]);
						me["Simple_L4"].show();
					} else { me["Simple_L4"].hide(); }
					if (myReceivedMessage[i].L4[1] != nil) {
						me["Simple_L4S"].setText(myReceivedMessage[i].L4[1]);
						me["Simple_L4S"].show();
					} else { me["Simple_L4S"].hide(); }
					if (myReceivedMessage[i].L5[0] != nil) {
						me["Simple_L5"].setText(myReceivedMessage[i].L5[0]);
						me["Simple_L5"].show();
					} else { me["Simple_L5"].hide(); }
					if (myReceivedMessage[i].L5[1] != nil) {
						me["Simple_L5S"].setText(myReceivedMessage[i].L5[1]);
						me["Simple_L5S"].show();
					} else { me["Simple_L5S"].hide(); }
					
					me["Simple_C1S"].setText(myReceivedMessage[i].C1[1]);
					me["Simple_R1S"].setText(myReceivedMessage[i].R1[1]);
					me.colorLeft(myReceivedMessage[i].L1[2],myReceivedMessage[i].L2[2],myReceivedMessage[i].L3[2],myReceivedMessage[i].L4[2],myReceivedMessage[i].L5[2],myReceivedMessage[i].L6[2]);
					me["Simple_L6"].setColor(WHITE);
					me["Simple_C1S"].setColor(GREEN);
				}
				pageSwitch[i].setBoolValue(1);
			}
				
			if (myReceivedMessage[i] != nil) {
				me._receivedTime = left(getprop("/sim/time/gmt-string"), 5);
				me.receivedTime = split(":", me._receivedTime)[0] ~ "." ~ split(":", me._receivedTime)[1] ~ "Z";
				me["Simple_L6"].setText(" RETURN " ~ me.receivedTime);
			}
		} else if (page == "ATCMENU") {
			if (!pageSwitch[i].getBoolValue()) {
				me.defaultHide();
				me["Simple_Title"].setText("ATC MENU");
				me["Simple_Title"].setColor(WHITE);
				me["Simple_PageNum"].setText("1/2");
				me["Simple_PageNum"].show();
				me["ArrowLeft"].show();
				me["ArrowRight"].show();
				
				me.showLeft(1, 1, -1, 1, 1, 1);
				me["Simple_L0S"].hide();
				me.showLeftS(-1, -1, -1, -1, -1, 1);
				me.showLeftArrow(1, 1, -1, 1, 1, 1);
				me.showRight(1, 1, 1, 1, 1, 1);
				me.showRightS(-1, -1, -1, -1, 1, -1);
				me.showRightArrow(1, 1, 1, 1, 1, 1);
				me["Simple_C3B"].hide();
				me["Simple_C4B"].hide();
				
				me.standardFontSize();
				
				me.colorLeft("wht", "wht", "wht", "wht", "wht", "wht");
				me.colorLeftS("wht", "wht", "wht", "wht", "wht", "wht");
				me.colorLeftArrow("wht", "wht", "wht", "wht", "wht", "wht");
				me.colorRight("wht", "wht", "wht", "wht", "wht", "amb");
				me.colorRightS("wht", "wht", "wht", "wht", "wht", "wht");
				me.colorRightArrow("wht", "wht", "wht", "wht", "wht", "amb");
				
			
				me["Simple_L1"].setText(" LAT REQ");
				me["Simple_L2"].setText(" WHEN CAN WE");
				me["Simple_L4"].setText(" MSG RECORD");
				me["Simple_L5"].setText(" NOTIFICATION");
				me["Simple_L6S"].setText(" ATSU DLK");
				me["Simple_L6"].setText(" RETURN");
				
				me["Simple_R1"].setText("VERT REQ ");
				me["Simple_R2"].setText("OTHER ");
				me["Simple_R3"].setText("TEXT ");
				me["Simple_R4"].setText("REPORTS ");
				me["Simple_R5"].setText("STATUS ");
				me["Simple_R5S"].setText("CONNECTION ");
				me["Simple_R6"].setText("EMERGENCY ");
				pageSwitch[i].setBoolValue(1);
			}
		} else if (page == "MCDUTEXT") {
			if (!pageSwitch[i].getBoolValue()) {
				me.defaultHideWithCenter();
				me["Simple_Title"].setText("TEXT");
				me["Simple_Title"].setColor(WHITE);
				me["Simple_PageNum"].setText("1/2");
				me["Simple_PageNum"].show();
				me["ArrowLeft"].show();
				me["ArrowRight"].show();
				
				me.showLeft(1, 1, 1, 1, 1, 1);
				me["Simple_L0S"].hide();
				me.showLeftS(1, 1, 1, -1, 1, 1);
				me.showLeftArrow(1, 1, 1, -1, 1, 1);
				me.showCenter(-1, -1, -1, -1, -1, -1);
				me.showCenterS(-1, -1, -1, 1, -1, -1);
				me.showRightS(1, 1, 1, -1, -1, 1);
				me.showRight(1, 1, 1, -1, -1, 1);
				me.showRightS(1, 1, 1, -1, -1, 1);
				me.showRightArrow(1, 1, 1, -1, -1, 1);
				me["Simple_C3B"].hide();
				me["Simple_C4B"].hide();
				
				me.standardFontSize();
				me["Simple_L4"].setFont(symbol);
				
				me.colorLeft("wht", "wht", "wht", "blu", "wht", "wht");
				me.colorLeftS("wht", "wht", "wht", "wht", "wht", "wht");
				me.colorLeftArrow("blu", "blu", "blu", "wht", "wht", "wht");
				me.colorRight("wht", "wht", "wht", "wht", "wht", "blu");
				me.colorRightS("wht", "wht", "wht", "wht", "wht", "blu");
				me.colorRightArrow("blu", "blu", "blu", "wht", "wht", "blu");
				
			
				me["Simple_L1"].setText(" A/C PERFORM.");
				me["Simple_L1S"].setText(" DUE TO");
				me["Simple_L2"].setText(" WEATHER");
				me["Simple_L2S"].setText(" DUE TO");
				me["Simple_L3"].setText(" TURBULENCE");
				me["Simple_L3S"].setText(" DUE TO");
				me["Simple_R1"].setText("MEDICAL ");
				me["Simple_R1S"].setText("DUE TO ");
				me["Simple_R2"].setText("TECHNICAL ");
				me["Simple_R2S"].setText("DUE TO" );
				me["Simple_R3"].setText("DISCRETION ");
				me["Simple_R3S"].setText("AT PILOTS ");
				me["Simple_C4S"].setText("-------- FREE TEXT --------");
				me["Simple_L4"].setText("[                      ]");
				me["Simple_L5"].setText(" ERASE");
				me["Simple_L5S"].setText(" ALL FIELDS");
				me["Simple_L6S"].setText(" ATC MENU");
				me["Simple_L6"].setText(" RETURN");
				me["Simple_R6S"].setText("ATC ");
				me["Simple_R6"].setText("TEXT DISPL ");
				pageSwitch[i].setBoolValue(1);
			}
			
			if (atsu.freeTexts[i].selection == 0) {
				pageSwitch[i].setBoolValue(0);
				me["Simple_L1_Arrow"].hide();
				me["Simple_L1"].setColor(BLUE);
				me["Simple_L1S"].setColor(BLUE);
			} elsif (atsu.freeTexts[i].selection == 1) {
				pageSwitch[i].setBoolValue(0);
				me["Simple_L2_Arrow"].hide();
				me["Simple_L2"].setColor(BLUE);
				me["Simple_L2S"].setColor(BLUE);
			} elsif (atsu.freeTexts[i].selection == 2) {
				pageSwitch[i].setBoolValue(0);
				me["Simple_L3_Arrow"].hide();
				me["Simple_L3"].setColor(BLUE);
				me["Simple_L3S"].setColor(BLUE);
			} elsif (atsu.freeTexts[i].selection == 3) {
				pageSwitch[i].setBoolValue(0);
				me["Simple_R1_Arrow"].hide();
				me["Simple_R1"].setColor(BLUE);
				me["Simple_R1S"].setColor(BLUE);
			} elsif (atsu.freeTexts[i].selection == 4) {
				pageSwitch[i].setBoolValue(0);
				me["Simple_R2_Arrow"].hide();
				me["Simple_R2"].setColor(BLUE);
				me["Simple_R2S"].setColor(BLUE);
			} elsif (atsu.freeTexts[i].selection == 5) {
				pageSwitch[i].setBoolValue(0);
				me["Simple_R3_Arrow"].hide();
				me["Simple_R3"].setColor(BLUE);
				me["Simple_R3S"].setColor(BLUE);
			} elsif (atsu.freeTexts[i].selection == 9) {
				pageSwitch[i].setBoolValue(0);
				me["Simple_L5_Arrow"].hide();
			}
		} else if (page == "ATCMENU2") {
			if (!pageSwitch[i].getBoolValue()) {
				me.defaultHideWithCenter();
				me["Simple_Title"].setText("ATC MENU");
				me["Simple_Title"].setColor(WHITE);
				me["Simple_PageNum"].setText("2/2");
				me["Simple_PageNum"].show();
				me["ArrowLeft"].show();
				me["ArrowRight"].show();
				
				me.showLeft(1, 1, -1, -1, -1, 1);
				me["Simple_L0S"].hide();
				me.showLeftS(-1, -1, -1, -1, -1, 1);
				me.showLeftArrow(1, 1, -1, -1, -1, 1);
				me.showCenter(-1, -1, -1, -1, -1, -1);
				me.showCenterS(1, -1, -1, -1, -1, -1);
				me.showRight(1, -1, -1, -1, -1, -1);
				me.showRightS(-1, -1, -1, -1, -1, -1);
				me.showRightArrow(1, -1, -1, -1, -1, -1);
				me["Simple_C3B"].hide();
				me["Simple_C4B"].hide();
				
				me.standardFontSize();
				me.fontSizeCenter(normal, normal, normal, normal, normal, normal);
				me.standardFontColour();
				me.colorCenterS("wht", "wht", "wht", "wht", "wht", "wht");
			
				me["Simple_L1"].setText(" DEPART REQ");
				me["Simple_L2"].setText(" OCEANIC REQ");
				me["Simple_C1S"].setText(" -------- ATS623 PAGE -------- ");
				me["Simple_L6S"].setText(" ATSU DLK");
				me["Simple_L6"].setText(" RETURN");
				
				me["Simple_R1"].setText("ATIS ");
				pageSwitch[i].setBoolValue(1);
			}
		} else if (page == "ATISDETAIL") {
			if (!pageSwitch[i].getBoolValue()) {
				me.defaultHide();
				me["Simple_PageNum"].hide();
				me["ArrowLeft"].hide();
				me["ArrowRight"].hide();
				
				me["Simple_L0S"].hide();
				me["Simple_C3B"].hide();
				me["Simple_C4B"].hide();
				
				me.fontLeft(default, default, default, default, default, default);
				me.fontLeftS(default, default, default, default, default, default);
				me.fontRight(default, default, default, default, default, default);
				me.fontRightS(default, default, default, default, default, default);
				
				me.fontSizeLeft(small, small, small, small, normal, normal);
				me.fontSizeCenter(normal, normal, normal, normal, normal, normal);
				me.fontSizeRight(normal, normal, normal, normal, normal, normal);
				
				me.colorLeftS("grn", "wht", "wht", "wht", "wht", "wht");
				me.colorRightS("grn", "wht", "wht", "wht", "wht", "wht");
				
				
				if (myAtis[i] != nil) {
					me["Simple_Title"].setText(sprintf("%s", myAtis[i].title));
					
					me.dynamicPageArrowFunc(myAtis[i]);
					me.colorLeftArrow(myAtis[i].arrowsColour[0][0],myAtis[i].arrowsColour[0][1],myAtis[i].arrowsColour[0][2],myAtis[i].arrowsColour[0][3],myAtis[i].arrowsColour[0][4],myAtis[i].arrowsColour[0][5]);
					me.colorRightArrow(myAtis[i].arrowsColour[1][0],myAtis[i].arrowsColour[1][1],myAtis[i].arrowsColour[1][2],myAtis[i].arrowsColour[1][3],myAtis[i].arrowsColour[1][4],myAtis[i].arrowsColour[1][5]);
					
					me.dynamicPageFunc(myAtis[i].L1, "Simple_L1");
					me.dynamicPageFunc(myAtis[i].L2, "Simple_L2");
					me.dynamicPageFunc(myAtis[i].L3, "Simple_L3");
					me.dynamicPageFunc(myAtis[i].L4, "Simple_L4");
					me.dynamicPageFunc(myAtis[i].L5, "Simple_L5");
					me.dynamicPageFunc(myAtis[i].L6, "Simple_L6");
					
					me.colorLeft(myAtis[i].L1[2],myAtis[i].L2[2],myAtis[i].L3[2],myAtis[i].L4[2],myAtis[i].L5[2],myAtis[i].L6[2]);
					
					me.dynamicPageFunc(myAtis[i].R1, "Simple_R1");
					me.dynamicPageFunc(myAtis[i].R2, "Simple_R2");
					me.dynamicPageFunc(myAtis[i].R3, "Simple_R3");
					me.dynamicPageFunc(myAtis[i].R4, "Simple_R4");
					me.dynamicPageFunc(myAtis[i].R5, "Simple_R5");
					me.dynamicPageFunc(myAtis[i].R6, "Simple_R6");
					
					me.colorRight(myAtis[i].R1[2],myAtis[i].R2[2],myAtis[i].R3[2],myAtis[i].R4[2],myAtis[i].R5[2],myAtis[i].R6[2]);
				}
				
				if (myAtis[i].getNumPages() > 1) {
					me["Simple_PageNum"].show();
					me["ATISArrows"].show();
					me["Simple_PageNum"].setText(myAtis[i].page ~ "/" ~ myAtis[i].getNumPages());
				} else {
					me["Simple_PageNum"].hide();
					me["ATISArrows"].hide();
				}
				
				pageSwitch[i].setBoolValue(1);
			}
		} else if (page == "ATIS") {
			if (!pageSwitch[i].getBoolValue()) {
				me.defaultHideWithCenter();
				me["Simple_Title"].setText("ATS623 ATIS MENU");
				me["Simple_Title"].setColor(WHITE);
				me["Simple_PageNum"].hide();
				me["ArrowLeft"].hide();
				me["ArrowRight"].hide();
				
				me.showLeft(1, 1, 1, 1, -1, 1);
				me["Simple_L0S"].hide();
				me.showLeftS(1, -1, -1, -1, -1, 1);
				me.showLeftArrow(1, 1, 1, -1, -1, 1);
				me.showCenter(-1, -1, -1, -1, -1, -1);
				me.showCenterS(-1, -1, -1, -1, -1, -1);
				me.showRight(1, 1, 1, 1, 1, 1);
				me.showRightS(1, 1, 1, 1, 1, 1);
				me.showRightArrow(-1, -1, -1, -1, 1, -1);
				me["Simple_C3B"].hide();
				me["Simple_C4B"].hide();
				
				me.standardFontSize();
				
				me.colorLeft("blu", "blu", "blu", "blu", "wht", "wht");
				me.colorLeftS("wht", "wht", "wht", "wht", "wht", "wht");
				me.colorLeftArrow("wht", "wht", "wht", "wht", "wht", "wht");
				me.colorCenter("grn", "grn", "grn", "grn", "wht", "wht");
				me.colorCenterS("wht", "wht", "wht", "wht", "wht", "wht");
				me.colorRight("wht", "wht", "wht", "wht", "wht", "wht");
				me.colorRightS("wht", "wht", "wht", "wht", "wht", "wht");
				me.colorRightArrow("wht", "wht", "wht", "wht", "wht", "wht");
				
			
				me["Simple_L1S"].setText(" ARPT/TYPE");
				me["Simple_L6S"].setText(" ATC MENU");
				me["Simple_L4"].setText(" [  ]/[  ]");
				me["Simple_L4"].setFont(symbol);
				me["Simple_L6"].setText(" RETURN");
				
				me["Simple_C1"].setFontSize(small);
				me["Simple_C2"].setFontSize(small);
				me["Simple_C3"].setFontSize(small);
				me["Simple_C4"].setFontSize(small);
				
				me["Simple_R1S"].setText("REQ ");
				me["Simple_R1"].setText("SEND ");
				me["Simple_R2S"].setText("REQ ");
				me["Simple_R2"].setText("SEND ");
				me["Simple_R3S"].setText("REQ ");
				me["Simple_R3"].setText("SEND ");
				me["Simple_R4S"].setText("REQ ");
				me["Simple_R4"].setText("SEND ");
				me["Simple_R5S"].setText("AUTO ");
				me["Simple_R5"].setText("UPDATE ");
				me["Simple_R6S"].setText("PRINT MANUAL ");
				me["Simple_R6"].setText("SET AUTO ");
				pageSwitch[i].setBoolValue(1);
			}
			
			if (atsu.ATISInstances[0].station != nil) {	
				me["Simple_L1"].setText(" " ~ atsu.ATISInstances[0].station ~ "/" ~ (atsu.ATISInstances[0].type == 0 ? "ARR" : "DEP"));
				me["Simple_L1"].setFont(default);
				me["Simple_L1_Arrow"].show();
			} else {
				me["Simple_L1"].setText(" [  ]/[  ]");
				me["Simple_L1"].setFont(symbol);
				me["Simple_L1_Arrow"].hide();
			}
			
			if (atsu.ATISInstances[0].received) {
				me["Simple_C1"].setText(" " ~ atsu.ATISInstances[0].receivedCode ~ " " ~ atsu.ATISInstances[0].receivedTime);
				me["Simple_C1"].show();
			} else {
				me["Simple_C1"].hide();
			}
			
			if (atsu.ATISInstances[1].station != nil) {
				me["Simple_L2"].setText(" " ~ atsu.ATISInstances[1].station ~ "/" ~ (atsu.ATISInstances[1].type == 0 ? "ARR" : "DEP"));
				me["Simple_L2"].setFont(default);
				me["Simple_L2_Arrow"].show();
			} else {
				me["Simple_L2"].setText(" [  ]/[  ]");
				me["Simple_L2"].setFont(symbol);
				me["Simple_L2_Arrow"].hide();
			}
			
			if (atsu.ATISInstances[1].received) {
				me["Simple_C2"].setText(" " ~ atsu.ATISInstances[1].receivedCode ~ " " ~ atsu.ATISInstances[1].receivedTime);
				me["Simple_C2"].show();
			} else {
				me["Simple_C2"].hide();
			}
			
			if (atsu.ATISInstances[2].station != nil) {
				me["Simple_L3"].setText(" " ~ atsu.ATISInstances[2].station ~ "/" ~ (atsu.ATISInstances[2].type == 0 ? "ARR" : "DEP"));
				me["Simple_L3"].setFont(default);
				me["Simple_L3_Arrow"].show();
			} else {
				me["Simple_L3"].setText(" [  ]/[  ]");
				me["Simple_L3"].setFont(symbol);
				me["Simple_L3_Arrow"].hide();
			}
			
			if (atsu.ATISInstances[2].received) {
				me["Simple_C3"].setText(" " ~ atsu.ATISInstances[2].receivedCode ~ " " ~ atsu.ATISInstances[2].receivedTime);
				me["Simple_C3"].show();
			} else {
				me["Simple_C3"].hide();
			}
			
			if (atsu.ATISInstances[3].station != nil) {
				me["Simple_L4"].setText(" " ~ atsu.ATISInstances[3].station ~ "/" ~ (atsu.ATISInstances[3].type == 0 ? "ARR" : "DEP"));
				me["Simple_L4"].setFont(default);
				me["Simple_L4_Arrow"].show();
			} else {
				me["Simple_L4"].setText(" [  ]/[  ]");
				me["Simple_L4"].setFont(symbol);
				me["Simple_L4_Arrow"].hide();
			}
			
			if (atsu.ATISInstances[3].received) {
				me["Simple_C4"].setText(" " ~ atsu.ATISInstances[3].receivedCode ~ " " ~ atsu.ATISInstances[3].receivedTime);
				me["Simple_C4"].show();
			} else {
				me["Simple_C4"].hide();
			}
			
			if (atsu.ATISInstances[0].sent) {
				me["ATISSend1"].hide();
			} else {
				me["ATISSend1"].show();
			}
			
			if (atsu.ATISInstances[1].sent) {
				me["ATISSend2"].hide();
			} else {
				me["ATISSend2"].show();
			}
			
			if (atsu.ATISInstances[2].sent) {
				me["ATISSend3"].hide();
			} else {
				me["ATISSend3"].show();
			}
			
			if (atsu.ATISInstances[3].sent) {
				me["ATISSend4"].hide();
			} else {
				me["ATISSend4"].show();
			}
		} else if (page == "NOTIFICATION") {
			if (!pageSwitch[i].getBoolValue()) {
				me.defaultHideWithCenter();
				me["arrowsDepArr"].hide();
				me["PERFAPPR"].hide();
				me["PERFGA"].hide();
				me["Simple_Title"].show();
				me["Simple_Title"].setText("NOTIFICATION");
				me.defaultPageNumbers();
				
				me.showLeft(1, 1, -1, -1, -1, 1);
				me["Simple_L0S"].hide();
				me.showLeftS(1, 1, -1, -1, -1, 1);
				me.showLeftArrow(-1, -1, -1, -1, -1, 1);
				me.showCenter(-1, 1, -1, -1, -1, -1);
				me.showCenterS(-1, -1, -1, -1, -1, -1);
				me.showRight(-1, 1, -1, -1, -1, 1);
				me.showRightS(-1, -1, -1, -1, -1, 1);
				me.showRightArrow(-1, -1, -1, -1, -1, 1);
				me["Simple_C3B"].hide();
				me["Simple_C4B"].hide();
				
				me.fontLeft(default, default, default, default, default, default);
				me.fontLeftS(default, default, default, default, default, default);
				me.fontRight(default, default, default, default, default, default);
				me.fontRightS(default, default, default, default, default, default);
				
				me.fontSizeLeft(small, normal, normal, normal, normal, normal);
				me.fontSizeCenter(normal, normal, normal, normal, small, normal);
				me.fontSizeRight(normal, normal, normal, normal, normal, normal);
				
				me.colorLeft("grn", "blu", "grn", "wht", "wht", "wht");
				me.colorLeftS("wht", "wht", "wht", "wht", "wht", "wht");
				me.colorLeftArrow("wht", "wht", "wht", "wht", "wht", "wht");
				me.colorCenter("wht", "wht", "wht", "wht", "amb", "wht");
				me.colorRight("wht", "blu", "wht", "wht", "wht", "wht");
				me.colorRightS("wht", "wht", "wht", "wht", "wht", "wht");
				me.colorRightArrow("wht", "wht", "wht", "wht", "wht", "wht");
				
				me["Simple_L1S"].setText(" ATC FLT NBR");
				me["Simple_L2S"].setText(" ATC CENTER");
				me["Simple_C2"].setText("------------   ");
				me["Simple_R2"].setText("NOTIFY ");
				me["Simple_C5"].setText("NOTIFICATION UNAVAILABLE");
				
				me["Simple_L6S"].setText(" ATC MENU");
				me["Simple_L6"].setText(" RETURN");
				me["Simple_R6"].setText("STATUS ");
				me["Simple_R6S"].setText("CONNECTION ");
				
			
				if (fmgc.FMGCInternal.flightNumSet) {
					me["NOTIFY_FLTNBR"].hide();
					me["Simple_L1"].setText(fmgc.FMGCInternal.flightNum);
					me["Simple_L1"].show();
					me["Simple_C5"].hide();
				} else {
					me["Simple_L1"].hide();
					me["NOTIFY_FLTNBR"].show();
					me["Simple_C5"].show();
				}
				pageSwitch[i].setBoolValue(1);
			}
			
			if (atsu.notificationSystem.notifyAirport != nil) {
				if (!atsu.notificationSystem.hasNotified) {
					me["Simple_L2"].setText(atsu.notificationSystem.notifyAirport);
					me["Simple_L2"].show();	
					me["NOTIFY_AIRPORT"].hide();
				} else {
					me["Simple_L2"].hide();
					me["NOTIFY_AIRPORT"].show();
				}
			} else {
				me["Simple_L2"].hide();
				me["NOTIFY_AIRPORT"].show();
			}
			
			if (atsu.notificationSystem.hasNotified) {
				me["NOTIFY"].hide();
				me["Simple_L3"].setText(atsu.notificationSystem.notifyAirport);
				me["Simple_L3"].show();	
				me["Simple_L3S"].setText(" ATC NOTIFIED");
				me["Simple_L3S"].show();	
			} else {
				me["NOTIFY"].show();
				me["Simple_L3"].hide();	
				me["Simple_L3S"].hide();	
			}
		} else if (page == "CONNECTSTATUS") {
			if (!pageSwitch[i].getBoolValue()) {
				me.defaultHideWithCenter();
				me["arrowsDepArr"].hide();
				me["PERFAPPR"].hide();
				me["PERFGA"].hide();
				me["Simple_Title"].show();
				me["Simple_Title"].setText("CONNECTION STATUS");
				me.defaultPageNumbers();
				
				me.showLeft(1, 1, -1, 1, -1, 1);
				me["Simple_L0S"].hide();
				me.showLeftS(1, 1, -1, -1, -1, 1);
				me.showLeftArrow(-1, -1, -1, -1, -1, 1);
				me.showCenter(1, -1, -1, -1, -1, -1);
				me.showCenterS(-1, -1, -1, 1, -1, -1);
				me.showRight(1, -1, 1, -1, 1, 1);
				me.showRightS(-1, -1, 1, -1, -1, -1);
				me.showRightArrow(-1, -1, -1, -1, -1, 1);
				me["Simple_C3B"].hide();
				me["Simple_C4B"].hide();
				
				me.fontLeft(default, default, default, default, default, default);
				me.fontLeftS(default, default, default, default, default, default);
				me.fontRight(default, default, default, default, default, default);
				me.fontRightS(default, default, default, default, default, default);
				
				me.fontSizeLeft(normal, normal, normal, normal, normal, normal);
				me.fontSizeCenter(small, normal, small, normal, normal, normal);
				me.fontSizeRight(normal, normal, normal, normal, small, normal);
				
				me.colorLeft("grn", "wht", "wht", "blu", "wht", "wht");
				me.colorLeftS("wht", "wht", "wht", "wht", "wht", "wht");
				me.colorLeftArrow("wht", "wht", "wht", "wht", "wht", "wht");
				me.colorCenter("wht", "wht", "wht", "wht", "wht", "wht");
				me.colorRight("blu", "blu", "blu", "wht", "wht", "wht");
				me.colorRightS("wht", "wht", "wht", "wht", "wht", "wht");
				me.colorRightArrow("wht", "wht", "wht", "wht", "wht", "wht");
				
				me["Simple_L1S"].setText("ACTIVE ATC");
				me["Simple_L2S"].setText("NEXT ATC");
				me["Simple_L2"].setText("----");
				me["Simple_C1"].setText("-------------     ");
				me["Simple_R1"].setText("NOTIFIED ");
				me["Simple_R3S"].setText("MAX UPLINK DELAY");
				me["Simple_R3"].setText("NONE");
				
				me["Simple_R5"].setText("ADS DETAIL");
				me["Simple_L6S"].setText(" ATC MENU");
				me["Simple_L6"].setText(" RETURN");
				me["Simple_R6"].setText("NOTIFICATION ");
				
				pageSwitch[i].setBoolValue(1);
			}
			
			if (atsu.notificationSystem.notifyAirport != nil) {
				if (atsu.notificationSystem.hasNotified) {
					me["Simple_L1"].setText(atsu.notificationSystem.notifyAirport);
				} else {
					me["Simple_L1"].setText("----");
					me["Simple_C1"].hide();
					me["Simple_R1"].hide();
				}
			} else {
				me["Simple_L1"].setText("----");
				me["Simple_C1"].hide();
				me["Simple_R1"].hide();
			}
			
			if (atsu.ADS.state == 0) {
				me["Simple_C4S"].setText("--------------ADS - OFF--------");
				me["Simple_L4"].setText(" SET ARMED");
			} elsif (atsu.ADS.state == 1) {
				me["Simple_C4S"].setText("-------------ADS - ARMED-------");
				me["Simple_L4"].setText(" SET OFF");
			} elsif (atsu.ADS.state == 2) {
				me["Simple_C4S"].setText("-----------ADS - CONNECTED-----");
				me["Simple_L4"].setText(" SET OFF");
			}
		} else if (page == "COMMMENU") {
			if (!pageSwitch[i].getBoolValue()) {
				me.defaultHide();
				me["Simple_Title"].setText("COMM MENU");
				me.defaultPageNumbers();
				
				me.showLeft(1, 1, 1, -1, -1, 1);
				me["Simple_L0S"].hide();
				me.showLeftS(1, 1, 1, -1, -1, 1);
				me.showLeftArrow(1, 1, 1, -1, -1, 1);
				me.showRight(1, 1, -1, 1, -1, -1);
				me.showRightS(1, 1, -1, -1, -1, -1);
				me.showRightArrow(1, 1, -1, 1, -1, -1);
				me["Simple_C3B"].hide();
				me["Simple_C4B"].hide();
				
				me.fontLeft(default, default, default, default, default, default);
				me.fontLeftS(default, default, default, default, default, default);
				me.fontRight(default, default, default, default, default, default);
				me.fontRightS(default, default, default, default, default, default);
				
				me.fontSizeLeft(normal, normal, normal, normal, normal, normal);
				me.fontSizeRight(normal, normal, normal, normal, small, normal);
				me.standardFontColour();
				me["Simple_L1S"].setText(" COMM");
				me["Simple_L1"].setText(" INIT");
				me["Simple_L2S"].setText(" VHF3");
				me["Simple_L2"].setText(" DATA MODE");
				me["Simple_L3S"].setText(" VHF3 VOICE");
				me["Simple_L3"].setText(" DIRECTORY");
				me["Simple_L6S"].setText(" RETURN TO");
				me["Simple_L6"].setText(" ATSU DLK");
				me["Simple_R1S"].setText("COMM ");
				me["Simple_R1"].setText("STATUS ");
				me["Simple_R2S"].setText("COMPANY ");
				me["Simple_R2"].setText("CALL ");
				me["Simple_R4"].setText("MAINTENANCE ");
				
				pageSwitch[i].setBoolValue(1);
			}
		} else if (page == "VOICEDIRECTORY") {
			if (!pageSwitch[i].getBoolValue()) {
				me.defaultHideWithCenter();
				me["arrowsDepArr"].hide();
				me["PERFAPPR"].hide();
				me["PERFGA"].hide();
				me["Simple_Title"].show();
				me["Simple_Title"].setText("VHF3 VOICE DIRECTORY");
				me.defaultPageNumbers();
				
				me.showLeft(1, -1, -1, 1, -1, 1);
				me["Simple_L0S"].hide();
				me.showLeftS(1, -1, -1, 1, -1, -1);
				me.showLeftArrow(-1, -1, -1, -1, -1, 1);
				me.showCenter(-1, -1, -1, -1, -1, -1);
				me.showCenterS(1, -1, -1, -1, -1, -1);
				me.showRight(1, -1, -1, -1, 1, 1);
				me.showRightS(1, -1, -1, -1, 1, 1);
				me.showRightArrow(-1, -1, -1, -1, -1, -1);
				me["Simple_C3B"].hide();
				me["Simple_C4B"].hide();
				
				me.standardFontSize();
				
				me.colorLeft("blu", "wht", "wht", "wht", "wht", "wht");
				me.colorLeftS("wht", "wht", "wht", "wht", "wht", "wht");
				me.colorLeftArrow("wht", "wht", "wht", "wht", "wht", "wht");
				me.colorCenterS("grn", "wht", "wht", "wht", "wht", "wht");
				me.colorRight("blu", "wht", "wht", "wht", "wht", "wht");
				me.colorRightS("wht", "wht", "wht", "wht", "wht", "wht");
				me.colorRightArrow("wht", "wht", "wht", "wht", "wht", "wht");
				
				me["Simple_L1S"].setText(" OPS");
				me["Simple_L1"].setText(" 132.225");
				me["Simple_L4S"].setText(" CO CALL");
				me["Simple_L6S"].setText(" RETURN TO");
				me["Simple_L6"].setText(" COMM MENU");
				me["Simple_R1S"].setText("MAINT ");
				me["Simple_R1"].setText("132.400 ");
				me["Simple_R5S"].setText("MODE ");
				me["Simple_R6S"].setText("PAGE ");
				me["Simple_R6"].setText("PRINT ");
				me["Simple_C1S"].setFontSize(normal);
				
				pageSwitch[i].setBoolValue(1);
			}
			if (ecam.vhf3_voice.active) {
				me["Simple_C1S"].setText("VOICE");
				me["Simple_R5"].setText("DATA ");
			} else {
				me["Simple_C1S"].setText("DATA");
				me["Simple_R5"].setText("VOICE ");
			}
			if (atsu.CompanyCall.frequency != 999.99) {
				me["Simple_L4"].setText(" " ~ sprintf("%5.2f", atsu.CompanyCall.frequency));
			} else {
				me["Simple_L4"].setText(" ---.--");
			}
		} else if (page == "DATAMODE") {
			if (!pageSwitch[i].getBoolValue()) {
				me.defaultHideWithCenter();
				me["arrowsDepArr"].hide();
				me["PERFAPPR"].hide();
				me["PERFGA"].hide();
				me["Simple_Title"].show();
				me["Simple_Title"].setText("VHF3 DATA MODE");
				me.defaultPageNumbers();
				
				me.showLeft(1, 1, 1, -1, -1, 1);
				me["Simple_L0S"].hide();
				me.showLeftS(1, -1, -1, -1, -1, -1);
				me.showLeftArrow(-1, 1, 1, -1, -1, 1);
				me.showCenter(-1, -1, -1, -1, -1, -1);
				me.showCenterS(1, -1, -1, -1, -1, -1);
				me.showRight(1, 1, 1, -1, -1, 1);
				me.showRightS(1, -1, -1, -1, -1, 1);
				me.showRightArrow(-1, 1, 1, -1, -1, -1);
				me["Simple_C3B"].hide();
				me["Simple_C4B"].hide();
				
				me.standardFontSize();
				
				me.colorLeft("grn", "blu", "blu", "blu", "wht", "wht");
				me.colorLeftS("wht", "blu", "blu", "blu", "wht", "wht");
				me.colorLeftArrow("wht", "blu", "blu", "blu", "wht", "wht");
				me.colorCenterS("grn", "wht", "wht", "wht", "wht", "wht");
				me.colorRight("grn", "blu", "blu", "wht", "wht", "blu");
				me.colorRightS("wht", "blu", "blu", "wht", "wht", "blu");
				me.colorRightArrow("wht", "blu", "blu", "wht", "wht", "wht");
				
				me["Simple_L1S"].setText(" ATIS");
				me["Simple_C1S"].setText("ACTIVE SERVERS");
				me["Simple_L2"].setText(" FAA");
				me["Simple_L3"].setText(" VATSIM");
				me["Simple_R1S"].setText("METAR ");
				me["Simple_R2"].setText("NOAA ");
				me["Simple_R3"].setText("VATSIM ");
				me["Simple_L6S"].setText(" RETURN TO");
				me["Simple_L6"].setText(" COMM MENU");
				me["Simple_R6S"].setText("PAGE ");
				me["Simple_R6"].setText("PRINT ");
				
				pageSwitch[i].setBoolValue(1);
			}
			if (atsu.AOC.server.getValue() == "vatsim") {
				me["Simple_R1"].setText("VATSIM ");
				me["Simple_R2_Arrow"].show();
				me["Simple_R3_Arrow"].hide();
			} elsif (atsu.AOC.server.getValue() == "noaa") {
				me["Simple_R1"].setText("NOAA ");
				me["Simple_R2_Arrow"].hide();
				me["Simple_R3_Arrow"].show();
			}
			
			if (atsu.ATIS.serverSel.getValue() == "vatsim") {
				me["Simple_L1"].setText(" VATSIM");
				me["Simple_L2_Arrow"].show();
				me["Simple_L3_Arrow"].hide();
			} elsif (atsu.ATIS.serverSel.getValue() == "faa") {
				me["Simple_L1"].setText(" FAA");
				me["Simple_L2_Arrow"].hide();
				me["Simple_L3_Arrow"].show();
			}
		} else if (page == "COMMINIT") {
			if (!pageSwitch[i].getBoolValue()) {
				me.defaultHide();
				me["Simple_Title"].setText("COMM INIT");
				me.defaultPageNumbers();
				
				me.showLeft(-1, 1, 1, 1, -1, 1);
				me["Simple_L0S"].hide();
				me.showLeftS(-1, 1, 1, 1, -1, -1);
				me.showLeftArrow(-1, -1, -1, -1, -1, 1);
				me.showRight(-1, -1, 1, -1, -1, 1);
				me.showRightS(-1, -1, 1, -1, -1, 1);
				me.showRightArrow(-1, -1, 1, -1, -1, -1);
				me["Simple_C3B"].hide();
				me["Simple_C4B"].hide();
				
				me.fontLeft(default, default, default, default, default, default);
				me.fontLeftS(default, default, default, default, default, default);
				me.fontRight(default, default, default, default, default, default);
				me.fontRightS(default, default, default, default, default, default);
				
				me.fontSizeLeft(normal, normal, normal, normal, normal, normal);
				me.fontSizeRight(normal, normal, normal, normal, small, normal);
				
				me.colorLeft("wht", "blu", "blu", "blu", "wht", "wht");
				me.colorLeftS("wht", "wht", "wht", "wht", "wht", "wht");
				me.colorLeftArrow("wht", "wht", "wht", "wht", "wht", "wht");
				me.colorRight("wht", "wht", "wht", "wht", "wht", "blu");
				me.colorRightS("wht", "wht", "wht", "wht", "wht", "blu");
				me.colorRightArrow("wht", "wht", "wht", "wht", "wht", "wht");
				
				me["Simple_L2S"].setText(" A/C REGISTR");
				me["Simple_L2"].setText(getprop("/options/model-options/registration"));
				me["Simple_L3S"].setText(" ACARS A/L ID");
				me["Simple_L3"].setText(getprop("/options/model-options/two-letter"));
				me["Simple_L4S"].setText(" STANDARD A/L ID");
				me["Simple_L4"].setText(getprop("/options/model-options/three-letter"));
				me["Simple_L6"].setText(" RETURN");
				me["Simple_R3S"].setText("VHF3 ");
				me["Simple_R3"].setText("SCAN SEL ");
				me["Simple_R6S"].setText("PAGE ");
				me["Simple_R6"].setText("PRINT ");
				
				pageSwitch[i].setBoolValue(1);
			}
		} else if (page == "COMMSTATUS") {
			if (!pageSwitch[i].getBoolValue()) {
				me.defaultHide();
				me["Simple_Title"].setText("COMM STATUS");
				me.defaultPageNumbers();
				
				me.showLeft(1, 1, -1, 1, 1, 1);
				me["Simple_L0S"].hide();
				me.showLeftS(-1, 1, 1, -1, 1, 1);
				me.showLeftArrow(-1, -1, -1, -1, -1, 1);
				me.showRight(1, 1, -1, 1, 1, 1);
				me.showRightS(-1, 1, 1, 1, 1, 1);
				me.showRightArrow(-1, -1, -1, -1, -1, -1);
				me["Simple_C3B"].hide();
				me["Simple_C4B"].hide();
				
				me.fontLeft(default, default, default, default, default, default);
				me.fontLeftS(default, default, default, default, default, default);
				me.fontRight(default, default, default, default, default, default);
				me.fontRightS(default, default, default, default, default, default);
				
				me.fontSizeLeft(normal, small, normal, normal, small, normal);
				me.fontSizeRight(normal, small, normal, small, small, normal);
				
				me.colorLeft("wht", "grn", "grn", "wht", "grn", "wht");
				me.colorLeftS("wht", "grn", "grn", "wht", "grn", "wht");
				me.colorLeftArrow("wht", "wht", "wht", "wht", "wht", "wht");
				me.colorRight("wht", "grn", "wht", "grn", "grn", "wht");
				me.colorRightS("wht", "grn", "grn", "wht", "grn", "wht");
				me.colorRightArrow("wht", "wht", "wht", "wht", "wht", "wht");
				
				me["Simple_L1"].setText(" VHF3");
				me["Simple_L2S"].setText(" OP");
				me["Simple_L2"].setText(" COMM");
				me["Simple_L4"].setText(" SATCOM");
				me["Simple_L5"].setText(" COMM");
				me["Simple_L6S"].setText(" RETURN TO");
				me["Simple_L6"].setText(" COMM MENU");
				me["Simple_R1"].setText("HF1 ");
				me["Simple_R2S"].setText("OP ");
				me["Simple_R2"].setText("COMM ");
				me["Simple_R3S"].setText("VOICE ");
				me["Simple_R4S"].setText("HF2 ");
				me["Simple_R4S"].setFontSize(normal);
				me["Simple_R4"].setText("OP ");
				me["Simple_R5S"].setText("COMM ");
				me["Simple_R5"].setText("VOICE ");
				me["Simple_R6S"].setText("PAGE ");
				me["Simple_R6"].setText("PRINT ");
				
				pageSwitch[i].setBoolValue(1);
			}
			me["Simple_L3S"].setText(ecam.vhf3_voice.active == 1 ? " VOICE " : " DATA");
			me["Simple_L5S"].setText(getprop("/options/model-options/wifi-aft") ? " OP" : " NOT INST");
			me["Simple_L5"].setText(getprop("/options/model-options/wifi-aft") ? " COMM" : " DLK INOP");
		} else if (page == "COMPANYCALL") {
			if (!pageSwitch[i].getBoolValue()) {
				me.defaultHide();
				me["Simple_Title"].setText("COMPANY CALL");
				me.defaultPageNumbers();
				
				me.showLeft(1, 1, -1, -1, -1, 1);
				me["Simple_L0S"].hide();
				me.showLeftS(1, 1, -1, -1, -1, 1);
				me.showLeftArrow(-1, -1, -1, -1, -1, 1);
				me.showRight(1, -1, -1, -1, -1, 1);
				me.showRightS(1, -1, -1, -1, -1, 1);
				me.showRightArrow(-1, -1, -1, -1, -1, -1);
				me["Simple_C3B"].hide();
				me["Simple_C4B"].hide();
				
				me.fontLeft(default, default, default, default, default, default);
				me.fontLeftS(default, default, default, default, default, default);
				me.fontRight(default, default, default, default, default, default);
				me.fontRightS(default, default, default, default, default, default);
				
				me.fontSizeLeft(normal, small, normal, normal, small, normal);
				me.fontSizeRight(normal, small, normal, small, small, normal);
				
				me.colorLeft("wht", "wht", "wht", "wht", "wht", "wht");
				me.colorLeftS("wht", "wht", "wht", "wht", "wht", "wht");
				me.colorLeftArrow("wht", "wht", "wht", "wht", "wht", "wht");
				me.colorRight("blu", "wht", "wht", "wht", "wht", "wht");
				me.colorRightS("wht", "wht", "wht", "wht", "wht", "wht");
				me.colorRightArrow("wht", "wht", "wht", "wht", "wht", "wht");
				
				me["Simple_L1S"].setText(" VHF3 TUNE");
				me["Simple_L2S"].setText(" TEXT");
				me["Simple_L6S"].setText(" RETURN TO");
				me["Simple_L6"].setText(" COMM MENU");
				me["Simple_R1S"].setText("CO CALL ");
				me["Simple_R1"].setText("CLEAR ");
				me["Simple_R6S"].setText("CALL ");
				me["Simple_R6"].setText("PRINT ");
				
				pageSwitch[i].setBoolValue(1);
			}
			
			if (atsu.CompanyCall.received) {
				me["COCALL"].hide();
			} else {
				me["COCALL"].show();
			}
			
			if (atsu.CompanyCall.frequency != 999.99) {
				if (atsu.CompanyCall.tuned) {
					me["COCALLTUNE"].hide();
				} else {
					me["COCALLTUNE"].show();
				}
			} else {
				me["COCALLTUNE"].hide();
			}
			
			if (atsu.CompanyCall.activeMsg != "") {
				me["Simple_L2"].setText(sprintf("%s", atsu.CompanyCall.activeMsg));
				me["Simple_L2"].show();
			} else {
				me["Simple_L2"].hide();
			}
			
			if (atsu.CompanyCall.frequency != 999.99) {
				me["Simple_L1"].setText(" " ~ sprintf("%5.2f", atsu.CompanyCall.frequency));
			} else {
				me["Simple_L1"].setText(" ---.--");
			}
		} else if (page == "STATUS") {
			if (!pageSwitch[i].getBoolValue()) {
				me["Simple"].show();
				me["Simple_Center"].hide();
				me["FPLN"].hide();
				me["DIRTO_TMPY_group"].hide();
				me["INITA"].hide();
				me["IRSINIT"].hide();
				me["INITB"].hide();
				me["FUELPRED"].hide();
				me["WIND"].hide();
				me["PROG"].hide();
				me["PERFTO"].hide();
				me["arrowsDepArr"].show();
				me["arrow1L"].hide();
				me["arrow2L"].hide();
				me["arrow3L"].hide();
				me["arrow4L"].hide();
				me["arrow5L"].hide();
				me["arrow1R"].hide();
				me["arrow2R"].hide();
				me["arrow3R"].hide();
				me["arrow4R"].hide();
				me["arrow5R"].show();
				me["arrow5R"].setColor(getprop("/MCDUC/colors/blu/r"),getprop("/MCDUC/colors/blu/g"),getprop("/MCDUC/colors/blu/b"));
				me["PERFAPPR"].hide();
				me["PERFGA"].hide();
				me["Simple_Title"].show();
				me["Simple_Title"].setText(sprintf("%s", "    " ~ acType.getValue()));
				me.defaultPageNumbers();
				
				me.showLeft(1, 1, 1, -1, -1, 1);
				me["Simple_L0S"].hide();
				me.showLeftS(1, 1, 1, -1, -1, 1);
				me.showLeftArrow(-1, -1, 1, -1, -1, -1);
				me.showRight(-1, 1, -1, 1, 1, 1);
				me.showRightS(-1, -1, -1, 1, 1, 1);
				me.showRightArrow(-1, -1, -1, -1, -1, 1);
				me["Simple_C3B"].hide();
				me["Simple_C4B"].hide();
				
				me.fontLeft(default, default, default, default, symbol, default);
				me.fontLeftS(default, default, default, default, default, default);
				me.fontRight(default, default, default, default, default, default);
				me.fontRightS(default, default, default, default, default, default);
				
				me.fontSizeLeft(normal, normal, normal, normal, small, normal);
				me.fontSizeRight(normal, normal, normal, small, normal, normal);
				
				me.colorLeft("grn", "blu", "blu", "wht", "blu", "grn");
				me.colorLeftS("wht", "wht", "wht", "wht", "wht", "wht");
				me.colorLeftArrow("wht", "blu", "blu", "wht", "wht", "wht");
				me.colorRight("wht", "grn", "wht", "grn", "blu", "wht");
				me.colorRightS("wht", "wht", "wht", "wht", "grn", "wht");
				me.colorRightArrow("wht", "wht", "wht", "wht", "wht", "wht");
				
				if (fmgc.FMGCInternal.phase == 0 or fmgc.FMGCInternal.phase == 7) {  # only on preflight and done phases
					me["Simple_L5S"].setText("CHG CODE");
					me["Simple_L5S"].show();
					me["Simple_L5"].setText("[   ]");
					me["Simple_L5"].show();
				}

				me["Simple_L6"].setText("+0.0/+1.0");
				me["Simple_L1S"].setText(" ENG");
				me["Simple_L2S"].setText(" ACTIVE NAV DATA BASE");
				me["Simple_L3S"].setText(" SECOND NAV DATA BASE");				
				me["Simple_L6S"].setText("IDLE/PERF");
				me["Simple_R6"].setText("STATUS/XLOAD ");
				me["Simple_R6S"].setText("SOFTWARE ");
				me["Simple_R4S"].setText("PILOT STORED  ");
				me["Simple_R4"].setText("00RTES 00RWYS ");
			
				pageSwitch[i].setBoolValue(1);
			}
			
			me["Simple_L1"].setText(sprintf("%s", engType.getValue()));
			me["Simple_L2"].setText(sprintf("%s", " " ~ database1.getValue()));
			me["Simple_L3"].setText(sprintf("%s", " " ~ database2.getValue()));
			me["Simple_R2"].setText(sprintf("%s", databaseCode.getValue() ~ " "));
			
			if (fmgc.WaypointDatabase.getCount() >= 1) {
				me["Simple_R4"].show();
				me["Simple_R5"].show();
				me["Simple_R4S"].show();
				me["Simple_R5S"].show();
				me["arrow5R"].show();
				me["Simple_R5S"].setText(sprintf("%02.0f", fmgc.WaypointDatabase.getCount()) ~ "WPTS 00NAVS ");
			} else {
				me["Simple_R4"].hide();
				me["Simple_R5"].hide();
				me["Simple_R4S"].hide();
				me["Simple_R5S"].hide();
				me["arrow5R"].hide();
			}
			
			if (fmgc.WaypointDatabase.confirm[i]) {
				me["Simple_R5"].setText("CONFIRM DELETE ALL ");
				me["Simple_R5"].setColor(getprop("/MCDUC/colors/amb/r"),getprop("/MCDUC/colors/amb/g"),getprop("/MCDUC/colors/amb/b"));
				me["arrow5R"].setColor(getprop("/MCDUC/colors/amb/r"),getprop("/MCDUC/colors/amb/g"),getprop("/MCDUC/colors/amb/b"));
			} else {
				me["Simple_R5"].setText("DELETE ALL ");
				me["Simple_R5"].setColor(getprop("/MCDUC/colors/blu/r"),getprop("/MCDUC/colors/blu/g"),getprop("/MCDUC/colors/blu/b"));
				me["arrow5R"].setColor(getprop("/MCDUC/colors/blu/r"),getprop("/MCDUC/colors/blu/g"),getprop("/MCDUC/colors/blu/b"));
			}
			
			if (fmgc.FMGCInternal.phase == 0 or fmgc.FMGCInternal.phase == 7) {
				me["Simple_L5"].show();
				me["Simple_L5S"].show();
			} else {
				me["Simple_L5"].hide();
				me["Simple_L5S"].hide();
			}
		} else if (page == "DATA") {
			if (!pageSwitch[i].getBoolValue()) {
				me.defaultHide();
				me["Simple_Title"].setText("DATA INDEX");
				me["Simple_Title"].setColor(WHITE);
				me["Simple_PageNum"].setText("1/2");
				me["Simple_PageNum"].show();
				me["ArrowLeft"].show();
				me["ArrowRight"].show();
				
				me.showLeft(1, 1, 1, 1, -1, -1);
				me["Simple_L0S"].hide();
				me.showLeftS(1, 1, 1, -1, 1, -1);
				me.showLeftArrow(1, 1, 1, 1, 1, -1);
				me.showRight(-1, -1, -1, -1, 1, 1);
				me.showRightS(-1, -1, -1, -1, 1, 1);
				me.showRightArrow(-1, -1, -1, -1, 1, 1);
				me["Simple_C3B"].hide();
				me["Simple_C4B"].hide();
				
				me.standardFontSize();
				me.standardFontColour();
				# why is this needed?
				me["Simple_L5"].show();
				
				me["Simple_L1"].setText(" MONITOR");
				me["Simple_L2"].setText(" MONITOR");
				me["Simple_L3"].setText(" MONITOR");
				me["Simple_L4"].setText(" A/C STATUS");
				me["Simple_L5"].setText(" AIRPORTS");
				me["Simple_L1S"].setText(" POSITION");
				me["Simple_L2S"].setText(" IRS");
				me["Simple_L3S"].setText(" GPS");
				me["Simple_L5S"].setText(" CLOSEST");
				me["Simple_R5"].setText("FUNCTION ");
				me["Simple_R6"].setText("FUNCTION ");
				me["Simple_R5S"].setText("PRINT ");
				me["Simple_R6S"].setText("AOC ");
				pageSwitch[i].setBoolValue(1);
			}
		} else if (page == "DATA2") {
			if (!pageSwitch[i].getBoolValue()) {
				me.defaultHide();
				me["Simple_Title"].setText("DATA INDEX");
				me["Simple_Title"].setColor(WHITE);
				me["Simple_PageNum"].setText("2/2");
				me["Simple_PageNum"].show();
				me["ArrowLeft"].show();
				me["ArrowRight"].show();
				
				me.showLeft(1, 1, 1, 1, 1, 1);
				me["Simple_L0S"].hide();
				me.showLeftS(-1, -1, -1, -1, 1, 1);
				me.showLeftArrow(1, 1, 1, 1, 1, 1);
				me.showRight(1, 1, 1, 1, -1, -1);
				me.showRightS(1, 1, 1, 1, -1, -1);
				me.showRightArrow(1, 1, 1, 1, -1, -1);
				me["Simple_C3B"].hide();
				me["Simple_C4B"].hide();
				
				me.standardFontSize();
				me.standardFontColour();
				pageSwitch[i].setBoolValue(1);
			}
			
			me["Simple_L1"].setText(" WAYPOINTS");
			me["Simple_L2"].setText(" NAVAIDS");
			me["Simple_L3"].setText(" RUNWAYS");
			me["Simple_L4"].setText(" ROUTES");
			me["Simple_L5"].setText(" WINDS");
			me["Simple_L6"].setText(" WINDS");
			me["Simple_L5S"].setText(" ACTIVE F-PLN");
			me["Simple_L6S"].setText(" SEC F-PLN");
			me["Simple_R1"].setText("WAYPOINTS ");
			me["Simple_R2"].setText("NAVAIDS ");
			me["Simple_R3"].setText("RUNWAYS ");
			me["Simple_R4"].setText("ROUTES ");
			me["Simple_R1S"].setText("PILOTS ");
			me["Simple_R2S"].setText("PILOTS ");
			me["Simple_R3S"].setText("PILOTS ");
			me["Simple_R4S"].setText("PILOTS ");
		} else if (page == "PILOTWP") {
			if (!pageSwitch[i].getBoolValue()) {
				me.defaultHide();
				me["Simple_PageNum"].show();
				me["ArrowLeft"].show();
				me["ArrowRight"].show();
				
				me["Simple_L0S"].hide();
				me["Simple_C3B"].hide();
				me["Simple_C4B"].hide();
				
				me.standardFontSize();
				
				me.colorLeftS("wht", "wht", "wht", "wht", "wht", "wht");
				me.colorRightS("wht", "wht", "wht", "wht", "wht", "wht");
				
				
				if (myPilotWP[i] != nil) {
					me["Simple_PageNum"].setText(fmgc.WaypointDatabase.getNoOfIndex(myPilotWP[i].scroll) ~ "/" ~ (fmgc.WaypointDatabase.getCount()));
					
					me["Simple_Title"].setText(sprintf("%s", myPilotWP[i].title ~ "       "));
					
					me.dynamicPageArrowFunc(myPilotWP[i]);
					me.colorLeftArrow(myPilotWP[i].arrowsColour[0][0],myPilotWP[i].arrowsColour[0][1],myPilotWP[i].arrowsColour[0][2],myPilotWP[i].arrowsColour[0][3],myPilotWP[i].arrowsColour[0][4],myPilotWP[i].arrowsColour[0][5]);
					me.colorRightArrow(myPilotWP[i].arrowsColour[1][0],myPilotWP[i].arrowsColour[1][1],myPilotWP[i].arrowsColour[1][2],myPilotWP[i].arrowsColour[1][3],myPilotWP[i].arrowsColour[1][4],myPilotWP[i].arrowsColour[1][5]);
					
					me.dynamicPageFontFunc(myPilotWP[i]);
					
					me.dynamicPageFunc(myPilotWP[i].L1, "Simple_L1");
					me.dynamicPageFunc(myPilotWP[i].L2, "Simple_L2");
					me.dynamicPageFunc(myPilotWP[i].L3, "Simple_L3");
					me.dynamicPageFunc(myPilotWP[i].L4, "Simple_L4");
					me.dynamicPageFunc(myPilotWP[i].L5, "Simple_L5");
					me.dynamicPageFunc(myPilotWP[i].L6, "Simple_L6");
					
					me.colorLeft(myPilotWP[i].L1[2],myPilotWP[i].L2[2],myPilotWP[i].L3[2],myPilotWP[i].L4[2],myPilotWP[i].L5[2],myPilotWP[i].L6[2]);
					
					me.dynamicPageFunc(myPilotWP[i].R1, "Simple_R1");
					me.dynamicPageFunc(myPilotWP[i].R2, "Simple_R2");
					me.dynamicPageFunc(myPilotWP[i].R3, "Simple_R3");
					me.dynamicPageFunc(myPilotWP[i].R4, "Simple_R4");
					me.dynamicPageFunc(myPilotWP[i].R5, "Simple_R5");
					me.dynamicPageFunc(myPilotWP[i].R6, "Simple_R6");
					
					me.colorRight(myPilotWP[i].R1[2],myPilotWP[i].R2[2],myPilotWP[i].R3[2],myPilotWP[i].R4[2],myPilotWP[i].R5[2],myPilotWP[i].R6[2]);
				}
				pageSwitch[i].setBoolValue(1);
			}
		} else if (page == "POSMON") {
			if (!pageSwitch[i].getBoolValue()) {
				me.defaultHideWithCenter();
				me["arrowsDepArr"].hide();
				me["PERFAPPR"].hide();
				me["PERFGA"].hide();
				me["Simple_Title"].show();
				me["Simple_Title2"].setColor(GREEN);
				me.defaultPageNumbers();
				
				me.showLeft(1, 1, 1, 1, 1, 1);
				me["Simple_L0S"].hide();
				me.showLeftS(-1, 1, 1, -1, 1, -1);
				me.showLeftArrow(-1, -1, -1, -1, -1, 1);
				me.showCenter(-1, -1, -1, -1, 1, -1);
				me["Simple_C3B"].hide();
				me["Simple_C4B"].hide();
				me.showCenterS(-1, -1, -1, -1, 1, -1);
				me.showRight(1, 1, 1, 1, 1, 1);
				me.showRightS(-1, -1, -1, -1, 1, 1);
				me.showRightArrow(-1, -1, -1, -1, -1, 1);
				
				me.standardFontSize();
				
				me.colorLeft("wht", "wht", "wht", "wht", "grn", "blu");
				me.colorLeftS("wht", "wht", "wht", "wht", "wht", "wht");
				me.colorLeftArrow("wht", "wht", "wht", "wht", "wht", "blu");
				me.colorRight("grn", "grn", "grn", "grn", "grn", "wht");
				me.colorRightS("wht", "wht", "wht", "wht", "wht", "wht");
				me.colorRightArrow("wht", "wht", "wht", "wht", "wht", "wht");
				me["Simple_C5"].setColor(GREEN);
				me["Simple_L5"].setFontSize(small);
				me["Simple_C5"].setFontSize(small);
				me["Simple_R5"].setFontSize(small);

				pageFreezed[i] = nil;

				me.updateretard = 0;
				
				pageSwitch[i].setBoolValue(1);
			}

            if (me.updateretard <= 0) {
				if (pageFreezed[i] == nil) {

					me["Simple_Title"].setText("POSITION MONITOR");
					me["Simple_Title2"].hide();
					me["Simple_L6"].setText(" FREEZE");
				
					me["Simple_L1"].setText("FMGC1");
					me["Simple_L2"].setText("FMGC2");
					me["Simple_L3"].setText("GPIRS");
					me["Simple_L4"].setText("MIX IRS");							
					me["Simple_L5S"].setText("  IRS1");
					me["Simple_R5S"].setText("IRS3  ");
					me["Simple_R6S"].setText("SEL ");
					me["Simple_R6"].setText("NAVAIDS ");
					me["Simple_C5S"].setText("IRS2");

					var latlog = me.getLatLogFormatted("/position/"); # current sim lat/log (formatted) cached for fast excecution
					#TODO - IRS emulation

					if (systems.ADIRS.Operating.aligned[0].getValue()) { # TODO real FMGC1 GPS data
						me["Simple_R1"].setText(latlog);
						me["Simple_R1"].setColor(GREEN);
						me["Simple_L2S"].setText(sprintf("%16s","3IRS/GPS"));
					} else {
						me["Simple_R1"].setText("----.--/-----.--");
						me["Simple_R1"].setColor(WHITE);
						me["Simple_L2S"].setText("");	
					}

					if (systems.ADIRS.Operating.aligned[1].getValue()) { # TODO real FMGC2 GPS data
						me["Simple_R2"].setText(latlog);
						me["Simple_R2"].setColor(GREEN);
						me["Simple_L3S"].setText(sprintf("%16s","3IRS/GPS"));
					} else {
						me["Simple_R2"].setText("----.--/-----.--");
						me["Simple_R2"].setColor(WHITE);
						me["Simple_L3S"].setText("");
					}

					if (systems.ADIRS.Operating.aligned[0].getValue() or systems.ADIRS.Operating.aligned[1].getValue() or systems.ADIRS.Operating.aligned[2].getValue()) {
						me["Simple_R3"].setText(latlog); # GPIRS
						me["Simple_R3"].setColor(GREEN);
						me["Simple_R4"].setText(latlog); # MIXIRS
						me["Simple_R4"].setColor(GREEN);
					} else {
						me["Simple_R3"].setText("----.--/-----.--"); # GPIRS not available
						me["Simple_R3"].setColor(WHITE);
						me["Simple_R4"].setText("----.--/-----.--"); # MIXIRS not available
						me["Simple_R4"].setColor(WHITE);
					}

					var Simple_row5 = ["Simple_L5","Simple_C5","Simple_R5"];

					for ( var a=0; a<3; a+=1 ) {
						if (systems.ADIRS.Operating.aligned[a].getValue()) {
							me[Simple_row5[a]].setText(sprintf("%-8s",(systems.ADIRS.ADIRunits[a].mode == 2) ? "ATT" : "NAV 0.0"));
						} else {
							me[Simple_row5[a]].setText(sprintf("%-8s",me.getIRSStatus(a)));
						}
					}			

				} else {

					me["Simple_Title"].setText("POSITION FROZEN AT      ");
					me["Simple_Title2"].setText(sprintf("%23s ",pageFreezed[i]));
					me["Simple_Title2"].show();
					me["Simple_L6"].setText(" UNFREEZE");

				}

			}

			if (me.updateretard < 0) me.updateretard = 2;
			else me.updateretard -= 1;

		} else if (page == "IRSMON") {
			if (!pageSwitch[i].getBoolValue()) {
				
				me.defaultHideWithCenter();
				me.standardFontSize();

				me.defaultPageNumbers();

				me.showLeft(1, 1, 1, -1, -1, -1);
				me.showLeftS(-1, 1, 1, 1, -1, -1);
				me.showLeftArrow(1, 1, 1, -1, -1, -1);
				me.showCenter(-1, -1, -1, -1, -1, -1);
				me.showCenterS(-1, -1, -1, -1, -1, -1);
				me.showRight(-1, -1, -1, -1, -1, -1);
				me.showRightS(1, 1, 1, 1, -1, -1);
				me.showRightArrow(-1, -1, -1, -1, -1, -1);

				me["arrowsDepArr"].hide();
				me["PERFAPPR"].hide();
				me["PERFGA"].hide();				
				me["Simple_L0S"].hide();
				me["Simple_Title"].show();
				
				me.colorLeft("wht", "wht", "wht", "ack", "ack", "ack");
				me.colorLeftS("ack", "grn", "grn", "grn", "ack", "ack");
				me.colorCenter("wht", "grn", "grn", "grn", "ack", "ack");
				me.colorRightS("amb", "grn", "grn", "grn", "ack", "ack");
				me.colorLeftArrow("wht", "wht", "wht", "ack", "ack", "ack");
				
				me["Simple_Title"].setText("IRS MONITOR");

				me["Simple_L1"].setText(" IRS1");
				me["Simple_L2"].setText(" IRS2");
				me["Simple_L3"].setText(" IRS3");
				me["Simple_C1"].setText("EXCESS MOTION");
				me["Simple_C2"].setText("EXCESS MOTION");
				me["Simple_C3"].setText("EXCESS MOTION");
				me["Simple_C1"].setFontSize(small);
				me["Simple_C2"].setFontSize(small);
				me["Simple_C3"].setFontSize(small);
				me["Simple_R1S"].setText("");

				#TODO - Missing SET HDG on degraded operations

				pageSwitch[i].setBoolValue(1);
			}
			
			var rows = ["Simple_L2S","Simple_L3S","Simple_L4S"];
			var center = ["Simple_C1","Simple_C2","Simple_C3"];
			for (var a = 0; a<3; a+=1) {
				me[rows[a]].setText("  " ~ me.getIRSStatus(a,1));
				if (systems.ADIRS.ADIRunits[a]._excessMotion) {
					me[center[a]].show();
				} else {
					me[center[a]].hide();
				}
			}				
			
			if (fmgc.FMGCInternal.phase == 7) { # DONE phase
				if (fmgc.FMGCInternal.arrApt != nil and fmgc.flightPlanController.flightplans[2].departure_runway != nil) {
					me["Simple_R1S"].setText(sprintf("DRIFT AT %7s     ",fmgc.FMGCInternal.arrApt ~ fmgc.flightPlanController.flightplans[2].departure_runway.id));
				}
				me["Simple_R2S"].setText(sprintf("DRIFT %2.1fNM/H       ",0));
				me["Simple_R3S"].setText(sprintf("DRIFT %2.1fNM/H       ",0));
				me["Simple_R4S"].setText(sprintf("DRIFT %2.1fNM/H       ",0));
			} else {
				me["Simple_R1S"].setText("");
				me["Simple_R2S"].setText("");
				me["Simple_R3S"].setText("");
				me["Simple_R4S"].setText("");
			}
		} else if (page == "GPSMON") {
			if (!pageSwitch[i].getBoolValue()) {
				
				me.defaultHideWithCenter();
				me.standardFontSize();

				me.defaultPageNumbers();

				me.showLeft(1, 1, 1, 1, 1, 1);
				me.showLeftS(1, 1, 1, 1, 1, 1);
				me.showLeftArrow(-1, -1, -1, -1, -1, -1);
				me.showCenter(-1, 1, 1, -1, 1, 1);
				me.showCenterS(-1, 1, 1, -1, 1, 1);
				me.showRight(-1, 1, 1, -1, 1, 1);
				me.showRightS(-1, 1, 1, -1, 1, 1);
				me.showRightArrow(-1, -1, -1, -1, -1, -1);

				me["arrowsDepArr"].hide();
				me["PERFAPPR"].hide();
				me["PERFGA"].hide();				
				me["Simple_L0S"].hide();
				me["Simple_Title"].show();
				
				me.colorLeft("grn", "grn", "grn", "grn", "grn", "grn");
				me.colorLeftS("wht", "wht", "wht", "wht", "wht", "wht");
				me.colorCenter("grn", "grn", "grn", "grn", "grn", "grn");
				me.colorCenterS("wht", "wht", "wht", "wht", "wht", "wht");
				me.colorRight("grn", "grn", "grn", "grn", "grn", "grn");
				me.colorRightS("wht", "wht", "wht", "wht", "wht", "wht");
				
				me["Simple_Title"].setText("GPS MONITOR");

				me["Simple_L1S"].setText("GPS1 POSITION");
				me["Simple_L2S"].setText("TTRK");
				me["Simple_L3S"].setText("MERIT");
				me["Simple_L3"].setText(sprintf("%3d",((rand() * 50) - 25) + 50) ~ "M");
				me["Simple_L4S"].setText("GPS2 POSITION");
				me["Simple_L5S"].setText("TTRK");
				me["Simple_L6S"].setText("MERIT");
				me["Simple_L6"].setText(sprintf("%3d",((rand() * 50) - 25) + 50) ~ "M");
				me["Simple_C2S"].setText("UTC");
				me["Simple_C3S"].setText("GPS ALT");
				me["Simple_C5S"].setText("UTC");
				me["Simple_C6S"].setText("GPS ALT");
				me["Simple_R2S"].setText("GS");
				me["Simple_R3S"].setText("MODE/SAT");
				me["Simple_R3"].setText("NAV/" ~ sprintf("%s",int((rand() * 2) - 1) + 6) ~ "  ");
				me["Simple_R5S"].setText("GS");
				me["Simple_R6S"].setText("MODE/SAT");
				me["Simple_R6"].setText("NAV/" ~ sprintf("%s",int((rand() * 2) - 1) + 6) ~ "  ");
				pageSwitch[i].setBoolValue(1);
			}
			me["Simple_L1"].setText(me.getLatLogFormatted2("/position/"));
			me["Simple_L2"].setText(sprintf("%-5.1f",pts.Instrumentation.GPS.trackMag.getValue() + magvar()));
			me["Simple_L4"].setText(me.getLatLogFormatted2("/position/"));
			me["Simple_L5"].setText(sprintf("%-5.1f",pts.Instrumentation.GPS.trackMag.getValue() + magvar()));
			var gmt = string.replace(pts.Sim.Time.gmtString.getValue(),":",".");
			me["Simple_C2"].setText(gmt);
			me["Simple_C5"].setText(gmt);
			me["Simple_C3"].setText(sprintf("%5.0f",pts.Instrumentation.GPS.altitude.getValue()));
			me["Simple_C6"].setText(sprintf("%5.0f",pts.Instrumentation.GPS.altitude.getValue()));
			me["Simple_R2"].setText(sprintf("%3.0f",pts.Instrumentation.GPS.gs.getValue()));
			me["Simple_R5"].setText(sprintf("%3.0f",pts.Instrumentation.GPS.gs.getValue()));
		} else if (page == "RADNAV") {
			if (!pageSwitch[i].getBoolValue()) {
				me.defaultHide();
				me["Simple_Title"].setText("RADIO NAV");
				me.defaultPageNumbers();
				
				me.showLeft(1, 1, 1, 1, 1, -1);
				me["Simple_L0S"].hide();
				me.showLeftS(1, 1, 1, 1, 1, -1);
				me.showLeftArrow(-1, -1, -1, -1, -1, -1);
				me.showRight(1, 1, 1, 1, 1, -1);
				me.showRightS(1, 1, 1, 1, 1, -1);
				me.showRightArrow(-1, -1, -1, -1, -1, -1);
				me["Simple_C3B"].hide();
				me["Simple_C4B"].hide();
				
				me.fontLeft(default, default, default, default, 0, default);
				me.fontLeftS(default, default, default, default, default, default);
				me.fontRight(default, default, symbol, symbol, 0, default);
				me.fontRightS(default, default, default, default, default, default);
				
				me.fontSizeLeft(0, 0, 0, 0, 0, normal);
				me.fontSizeRight(0, 0, small, small, 0, normal);
				
				me.colorLeft("blu", "blu", "blu", "blu", "blu", "blu");
				me.colorLeftS("wht", "wht", "wht", "wht", "wht", "wht");
				me.colorLeftArrow("wht", "wht", "wht", "wht", "wht", "wht");
				me.colorCenter("wht", "wht", "wht", "wht", "wht", "grn");
				me.colorCenterS("wht", "wht", "wht", "wht", "wht", "wht");
				me.colorRight("blu", "blu", "blu", "blu", "blu", "blu");
				me.colorRightS("wht", "wht", "wht", "wht", "wht", "wht");
				me.colorRightArrow("wht", "wht", "wht", "wht", "wht", "wht");
				
				pageSwitch[i].setBoolValue(1);
			}
			
			if (vor1FreqSet.getValue() == 1) {
				me["Simple_L1"].setFontSize(normal); 
			} else {
				me["Simple_L1"].setFontSize(small); 
			}
			if (vor1CRSSet.getValue() == 1) {
				me["Simple_L2"].setFontSize(normal); 
			} else {
				me["Simple_L2"].setFontSize(small); 
			}
			if (ils1FreqSet.getValue() == 1) {
				me["Simple_L3"].setFontSize(normal); 
			} else {
				me["Simple_L3"].setFontSize(small); 
			}
			if (ils1CRSSet.getValue() == 1) {
				me["Simple_L4"].setFontSize(normal); 
			} else {
				me["Simple_L4"].setFontSize(small); 
			}
			if (adf1FreqSet.getValue() == 1) {
				me["Simple_L5"].setFont(default); 
				me["Simple_L5"].setFontSize(normal); 
				me["Simple_L5"].setText(sprintf("%s", adf1.getValue()));
			} else {
				me["Simple_L5"].setFont(symbol); 
				me["Simple_L5"].setFontSize(small); 
				me["Simple_L5"].setText("[   ]/[     ]");
			}
			
			if (vor2FreqSet.getValue() == 1) {
				me["Simple_R1"].setFontSize(normal); 
			} else {
				me["Simple_R1"].setFontSize(small); 
			}
			if (vor2CRSSet.getValue() == 1) {
				me["Simple_R2"].setFontSize(normal); 
			} else {
				me["Simple_R2"].setFontSize(small); 
			}
			if (adf2FreqSet.getValue() == 1) {
				me["Simple_R5"].setFont(default); 
				me["Simple_R5"].setFontSize(normal); 
				me["Simple_R5"].setText(sprintf("%s", adf2.getValue()));
			} else {
				me["Simple_R5"].setFont(symbol); 
				me["Simple_R5"].setFontSize(small); 
				me["Simple_R5"].setText("[     ]/[   ]");
			}
			
			me["Simple_L1"].setText(" " ~ vor1.getValue());
			me["Simple_L2"].setText(sprintf("%3.0f", vor1CRS.getValue()));
			me["Simple_L3"].setText(" " ~ ils1.getValue());
			me["Simple_L4"].setText(sprintf("%3.0f", ils1CRS.getValue()));
			me["Simple_L1S"].setText("VOR1/FREQ");
			me["Simple_L2S"].setText("CRS");
			me["Simple_L3S"].setText("ILS /FREQ");
			me["Simple_L4S"].setText("CRS");
			me["Simple_L5S"].setText("ADF1/FREQ");
			me["Simple_R1"].setText(" " ~ vor2.getValue());
			me["Simple_R2"].setText(sprintf("%3.0f", vor2CRS.getValue()));
			me["Simple_R3"].setText("[  ]/[   ]");
			me["Simple_R4"].setText("-.-   [   ]");
			me["Simple_R1S"].setText("FREQ/VOR2");
			me["Simple_R2S"].setText("CRS");
			me["Simple_R3S"].setText("CHAN/ MLS");
			me["Simple_R4S"].setText("SLOPE   CRS");
			me["Simple_R5S"].setText("FREQ/ADF2");
			
			if (getprop("systems/radio/rmp[0]/nav") or getprop("systems/radio/rmp[1]/nav")) {
				me["Simple_L1"].hide();
				me["Simple_L2"].hide();
				me["Simple_L3"].hide();
				me["Simple_L4"].hide();
				me["Simple_L5"].hide();
				me["Simple_R1"].hide();
				me["Simple_R2"].hide();
				me["Simple_R3"].hide();
				me["Simple_R4"].hide();
				me["Simple_R5"].hide();
			} else {
				me["Simple_L1"].show();
				me["Simple_L2"].show();
				me["Simple_L3"].show();
				me["Simple_L4"].show();
				me["Simple_L5"].show();
				me["Simple_R1"].show();
				me["Simple_R2"].show();
				me["Simple_R3"].show();
				me["Simple_R4"].show();
				me["Simple_R5"].show();
			}
		} else if (page == "INITA") {
			if (!pageSwitch[i].getBoolValue()) {
				me["Simple"].show();
				me["Simple_Center"].hide();
				me["FPLN"].hide();
				me["DIRTO_TMPY_group"].hide();
				me["INITA"].show();
				me["IRSINIT"].hide();
				me["INITB"].hide();
				me["FUELPRED"].hide();
				me["WIND"].hide();
				me["PROG"].hide();
				me["PERFTO"].hide();
				me["arrowsDepArr"].hide();
				me["PERFAPPR"].hide();
				me["PERFGA"].hide();
				me["Simple_Title"].show();
				me["Simple_Title"].setText("INIT");
				me["Simple_Title"].setColor(WHITE);
				me["Simple_PageNum"].setText("X/X");
				me["Simple_PageNum"].hide();
				me["ArrowLeft"].show();
				me["ArrowRight"].show();
				
				me.showLeft(0, 1, 0, -1, 0, 1);
				me["Simple_L0S"].hide();
				me.showLeftS(1, 1, 1, -1, 1, 1);
				me.showLeftArrow(-1, -1, -1, -1, -1, -1);
				me.showRight(0, 0, 1, 1, 1, 1);
				me.showRightS(1, 0, -1, -1, 1, 1);
				me.showRightArrow(-1, -1, -1, 1, -1, -1);
				me["Simple_C3B"].hide();
				me["Simple_C4B"].hide();
				
				me.fontLeft(default, default, default, default, default, default);
				me.fontLeftS(default, default, default, default, default, default);
				me.fontRight(default, default, default, default, default, default);
				me.fontRightS(default, default, default, default, default, default);
				
				me.fontSizeLeft(normal, normal, normal, normal, normal, normal);
				me.fontSizeRight(normal, normal, normal, normal, normal, 0);
				
				me.colorLeft("blu", "wht", "blu", "blu", "ack", "ack");
				me.colorLeftS("wht", "wht", "wht", "wht", "wht", "wht");
				me.colorLeftArrow("wht", "wht", "wht", "wht", "wht", "wht");
				me.colorRight("blu", "amb", "amb", "wht", "blu", "blu");
				me.colorRightS("wht", "amb", "wht", "wht", "wht", "wht");
				me.colorRightArrow("wht", "wht", "wht", "wht", "wht", "wht");
				
				pageSwitch[i].setBoolValue(1);
			}
			
			if (fmgc.FMGCInternal.flightNumSet) {
				me["INITA_FltNbr"].hide();
				me["Simple_L3"].show();
			} else {
				me["INITA_FltNbr"].show();
				me["Simple_L3"].hide();
			}
			
			if (!fmgc.FMGCInternal.toFromSet and !fmgc.FMGCInternal.costIndexSet) {
				me["INITA_CostIndex"].hide();
				me["Simple_L5"].setColor(WHITE);
				me["Simple_L5"].show();
				me["Simple_L5"].setText("---");
			} else if (fmgc.FMGCInternal.costIndexSet) {
				me["INITA_CostIndex"].hide();
				me["Simple_L5"].setColor(BLUE);
				me["Simple_L5"].show();
				me["Simple_L5"].setText(sprintf("%s", fmgc.FMGCInternal.costIndex));
			} else {
				me["INITA_CostIndex"].show();
				me["Simple_L5"].hide();
			}
			if (!fmgc.FMGCInternal.toFromSet and !fmgc.FMGCInternal.crzSet) {
				me["INITA_CruiseFLTemp"].hide();
				me["Simple_L6"].setColor(WHITE);
				me["Simple_L6"].setText("-----/---g");
			} else if (fmgc.FMGCInternal.crzSet and fmgc.FMGCInternal.crzTempSet) {
				me["INITA_CruiseFLTemp"].hide();
				me["Simple_L6"].setColor(BLUE);
				me["Simple_L6"].setText(sprintf("%s", "FL" ~ fmgc.FMGCInternal.crzFl) ~ sprintf("/%sg", fmgc.FMGCInternal.crzTemp));
			} else if (fmgc.FMGCInternal.crzSet) {
				me["INITA_CruiseFLTemp"].hide();
				me["Simple_L6"].setColor(BLUE);
				fmgc.FMGCInternal.crzTemp = 15 - (2 * fmgc.FMGCInternal.crzFl / 10);
				fmgc.FMGCInternal.crzTempSet = 1;
				me["Simple_L6"].setText(sprintf("%s", "FL" ~ fmgc.FMGCInternal.crzFl) ~ sprintf("/%sg", fmgc.FMGCInternal.crzTemp));
			} else {
				me["INITA_CruiseFLTemp"].show();
				me["Simple_L6"].setColor(AMBER);
				me["Simple_L6"].setText("         g");
			}

			if (fmgc.FMGCInternal.coRouteSet) { # show coRoute when valid
				me["INITA_CoRoute"].hide();
				me["Simple_L1"].setText(fmgc.FMGCInternal.coRoute);
				me["Simple_L1"].setColor(BLUE);
				me["Simple_L1"].show();
			} else {
				me["Simple_L1"].hide();
				me["INITA_CoRoute"].show();				
				me["Simple_L1"].setText("NONE");
			}

			if (fmgc.FMGCInternal.toFromSet) {
				me["INITA_CoRoute"].hide();
				me["INITA_FromTo"].hide();
				me["Simple_L1"].show();
				me["Simple_L2"].setColor(BLUE);
				if (fmgc.FMGCInternal.altAirportSet) {
					me["Simple_L2"].setText(fmgc.FMGCInternal.altAirport);
				} else {
					me["Simple_L2"].setText("NONE");
				}
				me.showRight(1, -1, 0, 0, 0, 0);
				me["Simple_R2S"].hide();
				me["INITA_InitRequest"].hide();
			} else {
				me["INITA_CoRoute"].show();
				me["INITA_FromTo"].show();
				me["Simple_L1"].hide();
				me["Simple_L2"].setColor(WHITE);
				me["Simple_L2"].setText("----/----------");
				me.showRight(-1, 1, 0, 0, 0, 0);
				me["Simple_R2S"].show();
				if (!Simbrief.SimbriefParser.inhibit) {
					me["INITA_InitRequest"].show();
				} else {
					me["INITA_InitRequest"].hide();
				}
			}
			if (ADIRSMCDUBTN.getValue() != 1) {
				me["INITA_AlignIRS"].show();
				me["Simple_R3"].setColor(AMBER);
				me.showRightArrow(0, 0, -1, 0, 0, 0);
			} else {
				me["INITA_AlignIRS"].hide();
				me["Simple_R3"].setColor(WHITE);
				me.showRightArrow(0, 0, 1, 0, 0, 0);
			}
			if (fmgc.FMGCInternal.tropoSet) {
				me["Simple_R5"].setFontSize(normal); 
			} else {
				me["Simple_R5"].setFontSize(small); 
			}
			
			me["Simple_R6S"].setText("GND TEMP");
			if (fmgc.FMGCInternal.phase == 0 and !fmgc.FMGCInternal.gndTempSet) {
				fmgc.FMGCInternal.gndTemp = 15 - (2 * getprop("/position/gear-agl-ft") / 1000);
				me["Simple_R6"].setText(sprintf("%.0fg", fmgc.FMGCInternal.gndTemp));
				me["Simple_R6"].setFontSize(small); 
			} else {
				if (fmgc.FMGCInternal.gndTempSet) {
					me["Simple_R6"].setFontSize(normal); 
				} else {
					me["Simple_R6"].setFontSize(small); 
				}
				me["Simple_R6"].setText(sprintf("%.0fg", fmgc.FMGCInternal.gndTemp));
			}
			
			me["Simple_L1S"].setText(" CO RTE");
			me["Simple_L2S"].setText("ALTN/CO RTE");
			me["Simple_L3S"].setText("FLT NBR");
			me["Simple_L5S"].setText("COST INDEX");
			me["Simple_L6S"].setText("CRZ FL/TEMP");
			#me["Simple_L1"].setText("NONE");  # manage before (coRoute)
			me["Simple_L3"].setText(sprintf("%s", fmgc.FMGCInternal.flightNum));
			me["Simple_R1S"].setText("FROM/TO   ");
			me["Simple_R2S"].setText("INIT ");
			me["Simple_R5S"].setText("TROPO");
			
			me["Simple_R1"].setText(sprintf("%s", fmgc.FMGCInternal.depApt ~ "/" ~ fmgc.FMGCInternal.arrApt));
			me["Simple_R2"].setText("REQUEST ");
			me["Simple_R3"].setText("IRS INIT ");
			me["Simple_R4"].setText("WIND ");
			me["Simple_R5"].setText(sprintf("%5.0f", fmgc.FMGCInternal.tropo));
		} else if (page == "IRSINIT") {
			if (!pageSwitch[i].getBoolValue()) {
				me["Simple"].show();
				me["Simple_Center"].show();
				me["FPLN"].hide();
				me["DIRTO_TMPY_group"].hide();
				me["INITA"].hide();
				me["IRSINIT"].show();
				me["INITB"].hide();
				me["FUELPRED"].hide();
				me["WIND"].hide();
				me["PROG"].hide();
				me["PERFTO"].hide();
				me["arrowsDepArr"].hide();
				me["PERFAPPR"].hide();
				me["PERFGA"].hide();
				me["Simple_Title"].show();
				me["Simple_Title"].setText("IRS INIT");
				me.defaultPageNumbers();
				
				me.showLeft(1, 1, -1, -1, -1, 1);
				me["Simple_L0S"].hide();
				me.showLeftS(1, 1, -1, -1, -1, -1);
				me.showLeftArrow(-1, -1, -1, -1, -1, 1);
				me.showRight(1, 1, -1, -1, -1, 1);
				me.showRightS(1, 1, -1, -1, -1, -1);
				me.showRightArrow(-1, -1, -1, -1, -1, 1);
				me.showCenter(1, -1, 1, 1, 1, -1);
				me["Simple_C3B"].hide();
				me["Simple_C4B"].hide();
				me.showCenterS(1, 1, 1, 1, 1, -1);
				
				me.fontLeft(default, default, 0, 0, 0, default);
				me.fontLeftS(default, default, 0, 0, 0, 0);
				me.fontRight(default, default, 0, 0, 0, default);
				me.fontRightS(default, default, 0, 0, 0, 0);
				
				me.fontSizeLeft(small, small, 0, 0, 0, small);
				me.fontSizeRight(small, small, 0, 0, 0, normal);
				me.fontSizeCenter(normal, small, small, small, small, 0);
				
				me.colorLeft("blu", "blu", "ack", "ack", "ack", "wht");
				me.colorLeftS("wht", "wht", "ack", "ack", "ack", "ack");
				me.colorLeftArrow("wht", "wht", "wht", "wht", "wht", "wht");
				me.colorRight("blu", "blu", "ack", "ack", "ack", "blu");
				me.colorRightS("wht", "wht", "ack", "ack", "ack", "ack");
				me.colorRightArrow("wht", "wht", "wht", "wht", "wht", "blu");
				me.colorCenter("grn", "ack", "grn", "grn", "grn", "grn");
				me.colorCenterS("wht", "wht", "wht", "wht", "wht", "wht");
				
				pageSwitch[i].setBoolValue(1);
			}
			
			me["Simple_L1S"].setText("LAT");
				me["Simple_R1S"].setText("LONG");
			if (getprop("/FMGC/internal/align-ref-lat-edit")) {
				me["IRSINIT_1"].show();
				me["IRSINIT_2"].hide();
			} else if (getprop("/FMGC/internal/align-ref-long-edit")) {
				me["IRSINIT_1"].hide();
				me["IRSINIT_2"].show();
			} else {
				me["IRSINIT_1"].hide();
				me["IRSINIT_2"].hide();
			}
			
			if (fmgc.FMGCInternal.toFromSet) {
				degrees = getprop("/FMGC/internal/align-ref-lat-degrees");
				minutes = getprop("/FMGC/internal/align-ref-lat-minutes");
				sign = getprop("/FMGC/internal/align-ref-lat-sign");
				dms_lat = getprop("/FMGC/flightplan[2]/wp[0]/lat");
				degrees_lat = int(dms_lat);
				minutes_lat = sprintf("%.1f",abs((dms_lat - degrees_lat) * 60));
				sign_lat = degrees_lat >= 0 ? "N" : "S";
				lat_same = degrees_lat == degrees and minutes_lat == minutes and sign_lat == sign;
				me["Simple_L1"].setText(abs(sprintf("%.0f", degrees)) ~ "g" ~ sprintf("%.1f", minutes) ~ " " ~ sign);
				
				degrees = getprop("/FMGC/internal/align-ref-long-degrees");
				minutes = getprop("/FMGC/internal/align-ref-long-minutes");
				sign = getprop("/FMGC/internal/align-ref-long-sign");
				dms_long = getprop("/FMGC/flightplan[2]/wp[0]/lon");
				degrees_long = int(dms_long);
				minutes_long = sprintf("%.1f",abs((dms_long - degrees_long) * 60));
				sign_long = degrees_long >= 0 ? "E" : "W";
				long_same = degrees_long == degrees and minutes_long == minutes and sign_long == sign;
				me["Simple_R1"].setText(abs(sprintf("%.0f", degrees)) ~ "g" ~ sprintf("%.1f", minutes) ~ " " ~ sign);
				
				if (lat_same and long_same) {
					me["Simple_C1"].setText(getprop("/FMGC/flightplan[2]/wp[0]/id"));
					me["Simple_C1"].setColor(GREEN);
				} else {
					me["Simple_C1"].setText("----");
					me["Simple_C1"].setColor(WHITE);
				}
			} else {
				me["Simple_L1"].setText("-----.--");
				me["Simple_R1"].setText("------.--");
				me["Simple_C1"].setText("----");
				me["Simple_C1"].setColor(WHITE);
			}
			
			dms = getprop("/position/latitude-deg");
			degrees = int(dms);
			minutes = sprintf("%.1f",abs((dms - degrees) * 60));
			sign = degrees >= 0 ? "N" : "S";
			me["Simple_L2"].setText(abs(degrees) ~ "g" ~ minutes ~ " " ~ sign);
			dms2 = getprop("/position/longitude-deg");
			degrees2 = int(dms2);
			minutes2 = sprintf("%.1f",abs((dms2 - degrees2) * 60));
			sign2 = degrees2 >= 0 ? "E" : "W";
			me["Simple_R2"].setText(abs(degrees2) ~ "g" ~ minutes2 ~ " " ~ sign2);
			if (systems.ADIRS.ADIRunits[0].operative and getprop("/FMGC/internal/align1-done")) {
				me["Simple_C3"].setText(abs(degrees) ~ "g" ~ minutes ~ " " ~ sign ~ "/" ~ abs(degrees2) ~ "g" ~ minutes2 ~ " " ~ sign2);
			} else {
				me["Simple_C3"].setText("-----.--/-----.--");
			}
			if (systems.ADIRS.ADIRunits[1].operative and getprop("/FMGC/internal/align2-done")) {
				me["Simple_C4"].setText(abs(degrees) ~ "g" ~ minutes ~ " " ~ sign ~ "/" ~ abs(degrees2) ~ "g" ~ minutes2 ~ " " ~ sign2);
			} else {
				me["Simple_C4"].setText("-----.--/-----.--");
			}
			if (systems.ADIRS.ADIRunits[2].operative and getprop("/FMGC/internal/align3-done")) {
				me["Simple_C5"].setText(abs(degrees) ~ "g" ~ minutes ~ " " ~ sign ~ "/" ~ abs(degrees2) ~ "g" ~ minutes2 ~ " " ~ sign2);
			} else {
				me["Simple_C5"].setText("-----.--/-----.--");
			}
			
			if (align_set.getValue() == 1) {
				me["Simple_R6"].setText("CONFIRM ALIGN ");
				me.colorRight("ack", "ack", "ack", "ack", "ack", "amb");
				me["IRSINIT_star"].show();
				me.showRightArrow(0, 0, 0, 0, 0, -1);
			} else {
				me["Simple_R6"].setText("ALIGN ON REF ");
				me["IRSINIT_star"].hide();
				me.showRightArrow(0, 0, 0, 0, 0, 1);
			}
			
			if (systems.ADIRS.Operating.aligned[0].getValue()) {
				if (systems.ADIRS.ADIRunits[0].mode == 2) {
					me["Simple_C3S"].setText("IRS1 IN ATT");
				} else {
					me["Simple_C3S"].setText("IRS1 ALIGNED ON GPS");
				}
			} else {
				me["Simple_C3S"].setText("IRS1 ALIGNING ON GPS");
			}
			
			if (systems.ADIRS.Operating.aligned[1].getValue()) {
				if (systems.ADIRS.ADIRunits[1].mode == 2) {
					me["Simple_C4S"].setText("IRS2 IN ATT");
				} else {
					me["Simple_C4S"].setText("IRS2 ALIGNED ON GPS");
				}
			} else {
				me["Simple_C4S"].setText("IRS2 ALIGNING ON GPS");
			}
			
			if (systems.ADIRS.Operating.aligned[2].getValue()) {
				if (systems.ADIRS.ADIRunits[2].mode == 2) {
					me["Simple_C5S"].setText("IRS3 IN ATT");
				} else {
					me["Simple_C5S"].setText("IRS3 ALIGNED ON GPS");
				}
			} else {
				me["Simple_C5S"].setText("IRS3 ALIGNING ON GPS");
			}
			
			me["Simple_L2S"].setText("LAT");
			me["Simple_L6"].setText(" RETURN");
			me["Simple_R2S"].setText("LONG");
			me["Simple_C1S"].setText("REFERENCE");
			me["Simple_C2S"].setText("GPS POSITION");

		} else if (page == "ROUTESELECTION") {
			if (!pageSwitch[i].getBoolValue()) {
				me.defaultHide();
				me.standardFontSize();
				me["arrowsDepArr"].hide();
				me["PERFAPPR"].hide();
				me["PERFGA"].hide();
				me["Simple_Title"].show();
				me["Simple_Title"].setText("ROUTE SELECTION");
				me.showPageNumbers(1,1);
				
				me.showLeft(1, 1, 1, 1, 1, 1);
				me["Simple_L0S"].hide();
				me.showLeftS(-1, 1, 1, 1, 1, -1);
				me.showLeftArrow(-1, -1, -1, -1, -1, 1);
				me.showRight(-1, 1, 1, 1, 1, 1);
				me.showRightS(-1, 1, 1, 1, 1, -1);
				me.showRightArrow(-1, -1, -1, -1, -1, -1);
				me.fontSizeLeftS(normal, normal, normal, normal, normal, normal);
				me.fontSizeRight(0, small, small, small, small, normal);
				me.fontSizeRightS(0, small, small, small, small, normal);
				
				me.colorLeft("grn", "grn", "grn", "grn", "grn", "wht");
				me.colorLeftS("grn", "grn", "grn", "grn", "grn", "wht");
				me.colorRight("ack", "wht", "wht", "wht", "wht", "amb");
				me.colorRightS("ack", "wht", "wht", "wht", "wht", "wht");

				me["Simple_L1"].setText("NONE");
				me["Simple_L6"].setText(" RETURN");
				me["Simple_R6"].setText("INSERT ");
				me["PRINTPAGE"].show();
				me["PRINTPAGE"].setColor(AMBER);

				var rows = ["2S","2","3S","3","4S","4","5S","5"];

				me["Simple_L1"].setText("DUBLHR1");

				var r = 0;
				#for ( ; r < 8; r +=  1) {   # Example how formats rows with 4 cols
				#	me["Simple_L" ~ rows[r]].setText(sprintf("%11s %11s","SELKA","NUGRA"));
				#	me["Simple_R" ~ rows[r]].setText(sprintf("%-13s  %-13s","UL975","UL975"));
				#}
				while (r<8) {
					me["Simple_L" ~ rows[r]].setText("");
					me["Simple_R" ~ rows[r]].setText("");
					r+=1;
				}

				if (fmgc.FMGCInternal.toFromSet and !fmgc.FMGCInternal.altSelected) {
					me["Simple_Title"].setText(sprintf("%s", fmgc.FMGCInternal.depApt ~ "/" ~ fmgc.FMGCInternal.arrApt));
				} else if (!fmgc.FMGCInternal.toFromSet and fmgc.FMGCInternal.altAirport != "" and fmgc.FMGCInternal.altSelected) {
					me["Simple_Title"].setText(sprintf("%s", fmgc.FMGCInternal.altAirport));
				} else if (fmgc.FMGCInternal.toFromSet and fmgc.FMGCInternal.altAirport != "" and fmgc.FMGCInternal.altSelected) {
					me["Simple_Title"].setText(sprintf("%s", fmgc.FMGCInternal.arrApt ~ "/" ~ fmgc.FMGCInternal.altAirport));
				} else {
					me["Simple_Title"].setText("ROUTE SELECTION");
				}

				pageSwitch[i].setBoolValue(1);	# update on request only (left/right arrows)
			}
			
		} else if (page == "INITB") {
			if (!pageSwitch[i].getBoolValue()) {
				me["Simple"].show();
				me["Simple_Center"].show();
				me["FPLN"].hide();
				me["DIRTO_TMPY_group"].hide();
				me["INITA"].hide();
				me["IRSINIT"].hide();
				me["INITB"].show();
				me["FUELPRED"].hide();
				me["WIND"].hide();
				me["PROG"].hide();
				me["PERFTO"].hide();
				me["arrowsDepArr"].hide();
				me["PERFAPPR"].hide();
				me["PERFGA"].hide();
				me["Simple_Title"].show();
				me["Simple_PageNum"].setText("X/X");
				me["Simple_PageNum"].hide();
				me["ArrowLeft"].show();
				me["ArrowRight"].show();
				
				me.showLeft(1, 1, 1, 1, 1, 1);
				me["Simple_L0S"].hide();
				me.showLeftS(1, 1, 1, 1, 1, 1);
				me.showLeftArrow(-1, -1, -1, -1, -1, -1);
				me.showCenter(1, -1, 1, 1, 1, -1);
				me["Simple_C3B"].hide();
				me["Simple_C4B"].hide();
				me.showCenterS(-1, -1, -1, -1, -1, -1);
				me.showRight(-1, 1, 1, 1, 1, 1);
				me.showRightS(1, 1, 1, 1, 1, 1);
				me.showRightArrow(-1, -1, 1, -1, -1, -1);
				
				me.fontLeft(default, default, default, default, default, default);
				me.fontLeftS(default, default, default, default, default, default);
				me.fontRight(default, default, default, default, default, default);
				me.fontRightS(default, default, default, default, default, default);
				
				me.fontSizeLeft(small, small, small, small, small, small);
				me.fontSizeCenter(normal, small, small, small, small, small);
				me.fontSizeRight(normal, normal, normal, small, small, small);
				me["Simple_C4B"].setFontSize(small);
				
				me.colorLeft("blu", "wht", "wht", "wht", "wht", "wht");
				me.colorLeftS("wht", "wht", "wht", "wht", "wht", "wht");
				me.colorLeftArrow("wht", "wht", "wht", "wht", "wht", "wht");
				me.colorCenter("blu", "wht", "blu", "grn", "blu", "wht");
				me["Simple_C4B"].setColor(GREEN);
				me.colorRight("blu", "blu", "amb", "wht", "blu", "wht");
				me.colorRightS("wht", "wht", "amb", "wht", "wht", "wht");
				me.colorRightArrow("wht", "wht", "amb", "wht", "wht", "wht");
				
				pageSwitch[i].setBoolValue(1);
			}
					
			me["Simple_L1S"].setText("TAXI");
			if (acconfig_weight_kgs.getValue() == 1) {
				me["Simple_L1"].setText(sprintf("%2.1f", fmgc.FMGCInternal.taxiFuel * LBS2KGS));
			} else {
				me["Simple_L1"].setText(sprintf("%2.1f", fmgc.FMGCInternal.taxiFuel));
			}
			me["Simple_L2S"].setText("TRIP/TIME");
			me["Simple_L3S"].setText("RTE RSV/PCT");
			me["Simple_L4S"].setText("ALTN/TIME");
			me["Simple_L5S"].setText("FINAL/TIME");
			me["Simple_L6S"].setText("MIN DEST FOB");
			me["Simple_R2S"].setText("BLOCK");
			me["Simple_R4S"].setText("TOW/   LW");
			me["Simple_R5S"].setText("TRIP WIND");
			me["Simple_R5"].setText(fmgc.FMGCInternal.tripWind);
			me["Simple_R6S"].setText("EXTRA/TIME");
			
			me["Simple_Title"].setColor(WHITE);
			
			if (!fmgc.FMGCInternal.fuelRequest) {
				me["Simple_L2"].setText("---.-/----");
				me["Simple_L3"].setText("---.-");
				me["Simple_C3"].setText(sprintf("/%.1f                ", fmgc.FMGCInternal.rtePercent));
				me["Simple_L4"].setText("---.-/----");
				me["Simple_C4"].hide();
				me["Simple_L5"].setText("---.-");
				me["Simple_C5"].setText(sprintf("/%s               ", fmgc.FMGCInternal.finalTime));
				me["Simple_L6"].setText("---.-");
				if (fmgc.FMGCInternal.blockSet) {
					me["Simple_R2"].show(); 
					me["INITB_Block"].hide();
					if (acconfig_weight_kgs.getValue() == 1) {
						me["Simple_R2"].setText(sprintf("%3.1f", fmgc.FMGCInternal.block * LBS2KGS));
					} else {
						me["Simple_R2"].setText(sprintf("%3.1f", fmgc.FMGCInternal.block));
					}
				} else {
					me["Simple_R2"].hide(); 
					me["INITB_Block"].show();
				}
				if (fmgc.FMGCInternal.zfwSet) {
					me["Simple_R3S"].show();
					me["Simple_R3"].show(); 
					me["Simple_R3S"].setText("FUEL");
					me["Simple_R3"].setText("PLANNING ");
					me["Simple_R3_Arrow"].show();
					me["Simple_R3_Arrow"].setColor(AMBER);
				} else {
					me["Simple_R3S"].hide();
					me["Simple_R3"].hide(); 
					me["Simple_R3_Arrow"].hide();
				}
				me["Simple_C4B"].hide();
				me["Simple_R4"].setText("---.-/---.-");
				me["Simple_R6"].setText("---.-/----");
				
				me["Simple_Title"].setText("INIT");
				me["Simple_Title"].setColor(WHITE);
				
				me.colorLeft("ack", "wht", "wht", "wht", "wht", "wht");
				me.colorRight("ack", "blu", "amb", "wht", "ack", "wht");
				me["Simple_R3S"].setColor(AMBER);
			} else {
			
				me["Simple_Title"].setText("INIT FUEL PREDICTION ");
				
				if (fmgc.FMGCInternal.blockCalculating) {
					me["Simple_L2"].setText("---.-/----");
					me["Simple_L3"].setText("---.-");
					me["Simple_C3"].setText(sprintf("/%.1f                ", fmgc.FMGCInternal.rtePercent));
					me["Simple_L4"].setText("---.-/----");
					me["Simple_C4"].hide();
					me["Simple_L5"].setText("---.-");
					me["Simple_C5"].setText(sprintf("/%s               ", fmgc.FMGCInternal.finalTime));
					me["Simple_L6"].setText("---.-");
					me["Simple_R2"].show();
					me["Simple_R2"].setText("---.-");
					me["INITB_Block"].hide();
					me["Simple_R3S"].show();
					me["Simple_R3"].show(); 
					me["Simple_R3S"].setText("FUEL");
					me["Simple_R3"].setText("PLANNING ");
					me["Simple_R3_Arrow"].show();
					me["Simple_R3_Arrow"].setColor(GREEN);
					me["Simple_C4B"].hide();
					me["Simple_R4"].setText("---.-/---.-");
					me["Simple_R6"].setText("---.-/----");
				
					me.colorLeft("ack", "wht", "wht", "wht", "wht", "wht");
					me.colorRight("ack", "wht", "grn", "wht", "ack", "wht");
					me["Simple_R3S"].setColor(GREEN);
				} else {
					if (!fmgc.FMGCInternal.blockConfirmed) {
						me["Simple_L2"].setText("---.-/----");
						me["Simple_L3"].setText("---.-");
						me["Simple_C3"].setText(sprintf("/%.1f                ", fmgc.FMGCInternal.rtePercent));
						me["Simple_L4"].setText("---.-/----");
						me["Simple_C4"].hide();
						me["Simple_L5"].setText("---.-");
						me["Simple_C5"].setText(sprintf("/%s               ", fmgc.FMGCInternal.finalTime));
						me["Simple_L6"].setText("---.-");
						me["Simple_R2"].show(); 
						me["INITB_Block"].hide();
						if (acconfig_weight_kgs.getValue() == 1) {
							me["Simple_R2"].setText(sprintf("%3.1f", fmgc.FMGCInternal.block * LBS2KGS));
						} else {
							me["Simple_R2"].setText(sprintf("%3.1f", fmgc.FMGCInternal.block));
						}
						me["Simple_R3S"].show();
						me["Simple_R3"].show(); 
						me["Simple_R3S"].setText("BLOCK");
						me["Simple_R3"].setText("CONFIRM ");
						me["Simple_R3_Arrow"].show();
						me["Simple_R3_Arrow"].setColor(AMBER);
						me["Simple_C4B"].show();
						if (num(fmgc.FMGCInternal.tow) >= 100.0) {
							if (acconfig_weight_kgs.getValue() == 1) {
								me["Simple_C4B"].setText(sprintf("              %4.1f/", fmgc.FMGCInternal.tow * LBS2KGS));
							} else {
								me["Simple_C4B"].setText(sprintf("              %4.1f/", fmgc.FMGCInternal.tow));
							}
						} else {
							if (acconfig_weight_kgs.getValue() == 1) {
								me["Simple_C4B"].setText(sprintf("               %4.1f/", fmgc.FMGCInternal.tow * LBS2KGS));
							} else {
								me["Simple_C4B"].setText(sprintf("               %4.1f/", fmgc.FMGCInternal.tow));
							}
						}
						me["Simple_R4"].setText("---.-");
						me["Simple_R6"].setText("---.-/----");
			
						me.colorLeft("ack", "wht", "wht", "wht", "wht", "wht");
						me.colorRight("ack", "blu", "amb", "wht", "ack", "wht");
						me["Simple_R3S"].setColor(AMBER);
					} else {
						if (fmgc.FMGCInternal.fuelCalculating) {
							me["Simple_L2"].setText("---.-/----");
							me["Simple_L3"].setText("---.-");
							if (fmgc.FMGCInternal.rteRsvSet) {
								me["Simple_C3"].setText(sprintf("/%.1f             ", fmgc.FMGCInternal.rtePercent));
							} else if (fmgc.FMGCInternal.rtePercentSet) {
								me["Simple_C3"].setText(sprintf("/%.1f            ", fmgc.FMGCInternal.rtePercent));
							} else {
								me["Simple_C3"].setText(sprintf("/%.1f                ", fmgc.FMGCInternal.rtePercent));
							}
							me["Simple_L4"].setText("---.-/----");
							me["Simple_C4"].hide();
							me["Simple_L5"].setText("---.-");
							if (fmgc.FMGCInternal.finalFuelSet and fmgc.FMGCInternal.finalTimeSet) {
								me["Simple_C5"].setText(sprintf("/%s         ", fmgc.FMGCInternal.finalTime));
							} else if (fmgc.FMGCInternal.finalFuelSet) {
								me["Simple_C5"].setText(sprintf("/%s             ", fmgc.FMGCInternal.finalTime));
							} else if (fmgc.FMGCInternal.finalTimeSet) {
								me["Simple_C5"].setText(sprintf("/%s           ", fmgc.FMGCInternal.finalTime));
							} else {
								me["Simple_C5"].setText(sprintf("/%s               ", fmgc.FMGCInternal.finalTime));
							}
							me["Simple_L6"].setText("---.-");
							me["Simple_R2"].show(); 
							me["INITB_Block"].hide();
							if (acconfig_weight_kgs.getValue() == 1) {
								me["Simple_R2"].setText(sprintf("%3.1f", fmgc.FMGCInternal.block * LBS2KGS));
							} else {
								me["Simple_R2"].setText(sprintf("%3.1f", fmgc.FMGCInternal.block));
							}
							me["Simple_R3S"].hide();
							me["Simple_R3"].hide(); 
							me["Simple_R3_Arrow"].hide();
							me["Simple_C4B"].show();
							if (num(fmgc.FMGCInternal.tow) >= 100.0) {
								if (acconfig_weight_kgs.getValue() == 1) {
									me["Simple_C4B"].setText(sprintf("              %4.1f/", fmgc.FMGCInternal.tow * LBS2KGS));
								} else {
									me["Simple_C4B"].setText(sprintf("              %4.1f/", fmgc.FMGCInternal.tow));
								}
							} else {
								if (acconfig_weight_kgs.getValue() == 1) {
									me["Simple_C4B"].setText(sprintf("               %4.1f/", fmgc.FMGCInternal.tow * LBS2KGS));
								} else {
									me["Simple_C4B"].setText(sprintf("               %4.1f/", fmgc.FMGCInternal.tow));
								}
							}
							me["Simple_R4"].setText("---.-");
							me["Simple_R6"].setText("---.-/----");
				
							me.colorLeft("ack", "wht", "wht", "wht", "wht", "wht");
							me.colorRight("ack", "blu", "ack", "wht", "ack", "wht");
						} else {
							if (acconfig_weight_kgs.getValue() == 1) {
								me["Simple_L2"].setText(sprintf("%.1f/" ~ fmgc.FMGCInternal.tripTime, fmgc.FMGCInternal.tripFuel * LBS2KGS));
							} else {
								me["Simple_L2"].setText(sprintf("%.1f/" ~ fmgc.FMGCInternal.tripTime, fmgc.FMGCInternal.tripFuel));
							}
							if (acconfig_weight_kgs.getValue() == 1) {
								me["Simple_L3"].setText(sprintf("%.1f", fmgc.FMGCInternal.rteRsv * LBS2KGS));
							} else {
								me["Simple_L3"].setText(sprintf("%.1f", fmgc.FMGCInternal.rteRsv));
							}
							if (fmgc.FMGCInternal.rteRsvSet) {
								if (num(fmgc.FMGCInternal.rteRsv) > 9.9 and num(fmgc.FMGCInternal.rtePercent) > 9.9) {
									me["Simple_C3"].setText(sprintf("/%.1f               ", fmgc.FMGCInternal.rtePercent));
								} else if (num(fmgc.FMGCInternal.rteRsv) > 9.9) {
									me["Simple_C3"].setText(sprintf("/%.1f                ", fmgc.FMGCInternal.rtePercent));
								} else if (num(fmgc.FMGCInternal.rtePercent) > 9.9) {
									me["Simple_C3"].setText(sprintf("/%.1f                 ", fmgc.FMGCInternal.rtePercent));
								} else {
									me["Simple_C3"].setText(sprintf("/%.1f                  ", fmgc.FMGCInternal.rtePercent));
								}
							} else if (fmgc.FMGCInternal.rtePercentSet) {
								if (num(fmgc.FMGCInternal.rteRsv) > 9.9 and num(fmgc.FMGCInternal.rtePercent) > 9.9) {
									me["Simple_C3"].setText(sprintf("/%.1f            ", fmgc.FMGCInternal.rtePercent));
								} else if (num(fmgc.FMGCInternal.rteRsv) > 9.9) {
									me["Simple_C3"].setText(sprintf("/%.1f             ", fmgc.FMGCInternal.rtePercent));
								} else if (num(fmgc.FMGCInternal.rtePercent) > 9.9) {
									me["Simple_C3"].setText(sprintf("/%.1f              ", fmgc.FMGCInternal.rtePercent));
								} else {
									me["Simple_C3"].setText(sprintf("/%.1f               ", fmgc.FMGCInternal.rtePercent));
								}
							} else {
								if (num(fmgc.FMGCInternal.rteRsv) > 9.9 and num(fmgc.FMGCInternal.rtePercent) > 9.9) {
									me["Simple_C3"].setText(sprintf("/%.1f                 ", fmgc.FMGCInternal.rtePercent));
								} else if (num(fmgc.FMGCInternal.rteRsv) > 9.9) {
									me["Simple_C3"].setText(sprintf("/%.1f                  ", fmgc.FMGCInternal.rtePercent));
								} else if (num(fmgc.FMGCInternal.rtePercent) > 9.9) {
									me["Simple_C3"].setText(sprintf("/%.1f                   ", fmgc.FMGCInternal.rtePercent));
								} else {
									me["Simple_C3"].setText(sprintf("/%.1f                    ", fmgc.FMGCInternal.rtePercent));
								}
							}
							if (fmgc.FMGCInternal.altAirportSet) {
								if (acconfig_weight_kgs.getValue() == 1) {
									me["Simple_L4"].setText(sprintf("%.1f", fmgc.FMGCInternal.altFuel * LBS2KGS));
								} else {
									me["Simple_L4"].setText(sprintf("%.1f", fmgc.FMGCInternal.altFuel));
								}
								me["Simple_L4"].setColor(BLUE);
								me["Simple_C4"].show();
								if (fmgc.FMGCInternal.altFuelSet) {
									if (num(fmgc.FMGCInternal.altFuel) > 9.9) {
										me["Simple_C4"].setText(sprintf("/%s               ", fmgc.FMGCInternal.altTime));
									} else {
										me["Simple_C4"].setText(sprintf("/%s                 ", fmgc.FMGCInternal.altTime));
									}
								} else {
									if (num(fmgc.FMGCInternal.altFuel) > 9.9) {
										me["Simple_C4"].setText(sprintf("/%s                 ", fmgc.FMGCInternal.altTime));
									} else {
										me["Simple_C4"].setText(sprintf("/%s                   ", fmgc.FMGCInternal.altTime));
									}
								}
							} else {
								me["Simple_L4"].setText("---.-/----");
								me["Simple_L4"].setColor(WHITE);
								me["Simple_C4"].hide();
							}
							if (acconfig_weight_kgs.getValue() == 1) {
								me["Simple_L5"].setText(sprintf("%.1f", fmgc.FMGCInternal.finalFuel * LBS2KGS));
							} else {
								me["Simple_L5"].setText(sprintf("%.1f", fmgc.FMGCInternal.finalFuel));
							}
							if (fmgc.FMGCInternal.finalTimeSet and fmgc.FMGCInternal.finalFuelSet) {
								if (num(fmgc.FMGCInternal.finalFuel) > 9.9) {
									me["Simple_C5"].setText(sprintf("/%s           ", fmgc.FMGCInternal.finalTime));
								} else {
									me["Simple_C5"].setText(sprintf("/%s             ", fmgc.FMGCInternal.finalTime));
								}
							} else if (fmgc.FMGCInternal.finalTimeSet) {
								if (num(fmgc.FMGCInternal.finalFuel) > 9.9) {
									me["Simple_C5"].setText(sprintf("/%s            ", fmgc.FMGCInternal.finalTime));
								} else {
									me["Simple_C5"].setText(sprintf("/%s              ", fmgc.FMGCInternal.finalTime));
								}
							} else if (fmgc.FMGCInternal.finalFuelSet) {
								if (num(fmgc.FMGCInternal.finalFuel) > 9.9) {
									me["Simple_C5"].setText(sprintf("/%s               ", fmgc.FMGCInternal.finalTime));
								} else {
									me["Simple_C5"].setText(sprintf("/%s                  ", fmgc.FMGCInternal.finalTime));
								}
							} else {
								if (num(fmgc.FMGCInternal.finalFuel) > 9.9) {
									me["Simple_C5"].setText(sprintf("/%s                 ", fmgc.FMGCInternal.finalTime));
								} else {
									me["Simple_C5"].setText(sprintf("/%s                   ", fmgc.FMGCInternal.finalTime));
								}
							}
							if (acconfig_weight_kgs.getValue() == 1) {
								me["Simple_L6"].setText(sprintf("%.1f", fmgc.FMGCInternal.minDestFob * LBS2KGS));
							} else {
								me["Simple_L6"].setText(sprintf("%.1f", fmgc.FMGCInternal.minDestFob));
							}
							me["Simple_R2"].show(); 
							me["INITB_Block"].hide();
							if (acconfig_weight_kgs.getValue() == 1) {
								me["Simple_R2"].setText(sprintf("%3.1f", fmgc.FMGCInternal.block * LBS2KGS));
							} else {
								me["Simple_R2"].setText(sprintf("%3.1f", fmgc.FMGCInternal.block));
							}
							me["Simple_R3S"].hide();
							me["Simple_R3"].hide(); 
							me["Simple_R3_Arrow"].hide();
							me["Simple_C4B"].hide();
							
							if (acconfig_weight_kgs.getValue() == 1) {
								me["Simple_R4"].setText(sprintf("%4.1f/", fmgc.FMGCInternal.tow * LBS2KGS) ~ sprintf("%4.1f", fmgc.FMGCInternal.lw * LBS2KGS));
								me["Simple_R6"].setText(sprintf("%.1f/" ~ fmgc.FMGCInternal.extraTime, fmgc.FMGCInternal.extraFuel * LBS2KGS));
							} else {
								me["Simple_R4"].setText(sprintf("%4.1f/", fmgc.FMGCInternal.tow) ~ sprintf("%4.1f", fmgc.FMGCInternal.lw));
								me["Simple_R6"].setText(sprintf("%.1f/" ~ fmgc.FMGCInternal.extraTime, fmgc.FMGCInternal.extraFuel));
							}
				
							me.colorLeft("ack", "grn", "blu", "ack", "blu", "blu");
							me.colorRight("ack", "blu", "ack", "grn", "ack", "grn");
						}
					}
				}
			}
			
			me["Simple_R1S"].setText("ZFW/ZFWCG");
			me["Simple_R1"].setText(sprintf("%3.1f", fmgc.FMGCInternal.zfwcg));
			me["INITB_ZFWCG"].hide();
			me["INITB_ZFWCG_S"].show();
			me["Simple_R1"].show();
			if (fmgc.FMGCInternal.zfwcgSet) {
				me["Simple_R1"].setFontSize(normal);
			} else {
				me["Simple_R1"].setFontSize(small);
			}
			
			if (fmgc.FMGCInternal.zfwSet) {
				if (fmgc.FMGCInternal.zfw < 100) {
					if (acconfig_weight_kgs.getValue() == 1) {
						me["Simple_C1"].setText("          " ~ sprintf("%3.1f", fmgc.FMGCInternal.zfw * LBS2KGS));
					} else {
						me["Simple_C1"].setText("          " ~ sprintf("%3.1f", fmgc.FMGCInternal.zfw));
					}
				} else {
					if (acconfig_weight_kgs.getValue() == 1) {
						me["Simple_C1"].setText("         " ~ sprintf("%3.1f", fmgc.FMGCInternal.zfw * LBS2KGS));
					} else {
						me["Simple_C1"].setText("         " ~ sprintf("%3.1f", fmgc.FMGCInternal.zfw));
					}
				}
				me["Simple_C1"].show();
				me["INITB_ZFW"].hide();
			} else {
				me["Simple_C1"].hide();
				me["INITB_ZFW"].show();
			}

			if (fmgc.FMGCInternal.taxiFuelSet) {
				me["Simple_L1"].setFontSize(normal);
			} else {
				me["Simple_L1"].setFontSize(small);
			}
			
			if (fmgc.FMGCInternal.rteRsvSet) {
				me["Simple_L3"].setFontSize(normal);
				me["Simple_C3"].setFontSize(small);
			} else if (fmgc.FMGCInternal.rtePercentSet) {
				me["Simple_L3"].setFontSize(small);
				me["Simple_C3"].setFontSize(normal);
			} else {
				me["Simple_L3"].setFontSize(small);
				me["Simple_C3"].setFontSize(small);
			}
			
			if (fmgc.FMGCInternal.altFuelSet and fmgc.FMGCInternal.crzSet) {
				me["Simple_L4"].setFontSize(normal);
			} else {
				me["Simple_L4"].setFontSize(small);
			}
			
			if (fmgc.FMGCInternal.finalFuelSet and fmgc.FMGCInternal.finalTimeSet) {
				me["Simple_L5"].setFontSize(normal);
				me["Simple_C5"].setFontSize(normal);
			} else if (fmgc.FMGCInternal.finalFuelSet) {
				me["Simple_L5"].setFontSize(normal);
				me["Simple_C5"].setFontSize(small);
			} else if (fmgc.FMGCInternal.finalTimeSet) {
				me["Simple_L5"].setFontSize(small);
				me["Simple_C5"].setFontSize(normal);
			} else {
				me["Simple_L5"].setFontSize(small);
				me["Simple_C5"].setFontSize(small);
			}
			
			if (fmgc.FMGCInternal.minDestFobSet) {
				me["Simple_L6"].setFontSize(normal);
			} else {
				me["Simple_L6"].setFontSize(small);
			}
			
		} else if (page == "FUELPRED") {
			if (!pageSwitch[i].getBoolValue()) {
				me["Simple"].show();
				me["Simple_Center"].show();
				me["FPLN"].hide();
				me["DIRTO_TMPY_group"].hide();
				me["INITA"].hide();
				me["IRSINIT"].hide();
				me["INITB"].hide();
				me["FUELPRED"].show();
				me["WIND"].hide();
				me["PROG"].hide();
				me["PERFTO"].hide();
				me["arrowsDepArr"].hide();
				me["PERFAPPR"].hide();
				me["PERFGA"].hide();
				me["Simple_Title"].show();
				me["Simple_Title"].setText("FUEL PRED");
				me["Simple_Title"].setColor(WHITE);
				me["Simple_PageNum"].setText("X/X");
				me["Simple_PageNum"].hide();
				me["ArrowLeft"].show();
				me["ArrowRight"].show();
				
				me.showLeft(1, 1, 1, 1, 1, 1);
				me["Simple_L0S"].hide();
				me.showLeftS(1, -1, 1, 1, 1, 1);
				me.showLeftArrow(-1, -1, -1, -1, -1, -1);
				me.showCenter(1, 1, 1, -1, 1, -1);
				me["Simple_C3B"].show();
				me["Simple_C4B"].hide();
				me.showCenterS(1, -1, -1, -1, -1, -1);
				me.showRight(1, 1, -1, 1, 1, 1);
				me.showRightS(1, -1, 1, 1, 1, 1);
				me.showRightArrow(-1, -1, -1, -1, -1, -1);
				
				me.fontLeft(default, default, default, default, default, default);
				me.fontLeftS(default, default, default, default, default, default);
				me.fontRight(default, default, default, default, default, default);
				me.fontRightS(default, default, default, default, default, default);
				
				me.fontSizeLeft(normal, normal, small, small, small, small);
				me.fontSizeCenter(small, small, normal, small, small, small);
				me.fontSizeRight(small, small, normal, small, small, small);
				me["Simple_C3B"].setFontSize(small);
				
				me.colorLeft("grn", "grn", "wht", "wht", "wht", "wht");
				me.colorLeftS("wht", "wht", "wht", "wht", "wht", "wht");
				me.colorLeftArrow("wht", "wht", "wht", "wht", "wht", "wht");
				me.colorCenter("wht", "wht", "blu", "grn", "blu", "wht");
				me["Simple_C3B"].setColor(BLUE);
				me.colorCenterS("wht", "wht", "wht", "wht", "wht", "wht");
				me.colorRight("wht", "wht", "blu", "wht", "wht", "wht");
				me.colorRightS("wht", "wht", "wht", "wht", "wht", "wht");
				me.colorRightArrow("wht", "wht", "wht", "wht", "wht", "wht");
				
				pageSwitch[i].setBoolValue(1);
			}
			
			if (!engRdy.getBoolValue() or !fmgc.FMGCInternal.toFromSet) {
				me["Simple_L1"].setText("NONE");
			} else {
				me["Simple_L1"].setText(fmgc.FMGCInternal.arrApt);
			}
			if (!engRdy.getBoolValue() or !fmgc.FMGCInternal.altAirportSet) {
				me["Simple_L2"].setText("NONE");
			} else {
				me["Simple_L2"].setText(fmgc.FMGCInternal.altAirport);
			}
			
			me["Simple_L1S"].setText("AT");
			me["Simple_L2S"].setText("X");
			me["Simple_L3S"].setText("RTE RSV/PCT");
			me["Simple_L4S"].setText("ALTN /TIME");
			me["Simple_L5S"].setText("FINAL/TIME");
			me["Simple_L6S"].setText("MIN DEST FOB");
			
			me["Simple_C1S"].setText("UTC");
			me["Simple_C1"].setText("----");
			me["Simple_C2"].setText("----");
			
			me["Simple_R1"].setText("---.-");
			me["Simple_R2"].setText("---.-");
			me["Simple_R1S"].setText("EFOB");
			me["Simple_R2S"].setText("X");
			me["Simple_R4S"].setText("FOB      ");
			me["Simple_R5S"].setText("   GW/   CG");
			me["Simple_R6S"].setText("EXTRA/TIME");
			
			if (!fmgc.FMGCInternal.fuelRequest or !fmgc.FMGCInternal.blockConfirmed or fmgc.FMGCInternal.fuelCalculating) {
				me["Simple_L3"].setText("---.-");
				if (fmgc.FMGCInternal.rteRsvSet) {
					me["Simple_C3B"].setText(sprintf("/%.1f             ", fmgc.FMGCInternal.rtePercent));
				} else if (fmgc.FMGCInternal.rtePercentSet) {
					me["Simple_C3B"].setText(sprintf("/%.1f            ", fmgc.FMGCInternal.rtePercent));
				} else {
					me["Simple_C3B"].setText(sprintf("/%.1f                ", fmgc.FMGCInternal.rtePercent));
				}
				me["Simple_L4"].setText("---.-/----");
				me["Simple_C4"].hide();
				me["Simple_L5"].setText("---.-");
				if (fmgc.FMGCInternal.finalFuelSet or fmgc.FMGCInternal.finalTimeSet) {
					me["Simple_C5"].setText(sprintf("/%s             ", fmgc.FMGCInternal.finalTime));
				} else {
					me["Simple_C5"].setText(sprintf("/%s               ", fmgc.FMGCInternal.finalTime));
				}
				me["Simple_L6"].setText("---.-");
				
				me["Simple_R4"].setText("---.-/FF+FQ");
				me["Simple_R5"].setText("---.-/ --.-");
				me["Simple_R6"].setText("---.-/----");
	
				me.colorLeft("ack", "ack", "wht", "wht", "wht", "wht");
				me.colorRight("ack", "ack", "ack", "wht", "wht", "wht");
			} else {
				if (acconfig_weight_kgs.getValue() == 1) {
					me["Simple_L3"].setText(sprintf("%.1f", fmgc.FMGCInternal.rteRsv * LBS2KGS));
				} else {
					me["Simple_L3"].setText(sprintf("%.1f", fmgc.FMGCInternal.rteRsv));
				}
				if (fmgc.FMGCInternal.rteRsvSet) {
					if (num(fmgc.FMGCInternal.rteRsv) > 9.9 and num(fmgc.FMGCInternal.rtePercent) > 9.9) {
						me["Simple_C3B"].setText(sprintf("/%.1f               ", fmgc.FMGCInternal.rtePercent));
					} else if (num(fmgc.FMGCInternal.rteRsv) > 9.9) {
						me["Simple_C3B"].setText(sprintf("/%.1f                ", fmgc.FMGCInternal.rtePercent));
					} else if (num(fmgc.FMGCInternal.rtePercent) > 9.9) {
						me["Simple_C3B"].setText(sprintf("/%.1f                 ", fmgc.FMGCInternal.rtePercent));
					} else {
						me["Simple_C3B"].setText(sprintf("/%.1f                  ", fmgc.FMGCInternal.rtePercent));
					}
				} else if (fmgc.FMGCInternal.rtePercentSet) {
					if (num(fmgc.FMGCInternal.rteRsv) > 9.9 and num(fmgc.FMGCInternal.rtePercent) > 9.9) {
						me["Simple_C3B"].setText(sprintf("/%.1f            ", fmgc.FMGCInternal.rtePercent));
					} else if (num(fmgc.FMGCInternal.rteRsv) > 9.9) {
						me["Simple_C3B"].setText(sprintf("/%.1f             ", fmgc.FMGCInternal.rtePercent));
					} else if (num(fmgc.FMGCInternal.rtePercent) > 9.9) {
						me["Simple_C3B"].setText(sprintf("/%.1f              ", fmgc.FMGCInternal.rtePercent));
					} else {
						me["Simple_C3B"].setText(sprintf("/%.1f               ", fmgc.FMGCInternal.rtePercent));
					}
				} else {
					if (num(fmgc.FMGCInternal.rteRsv) > 9.9 and num(fmgc.FMGCInternal.rtePercent) > 9.9) {
						me["Simple_C3B"].setText(sprintf("/%.1f                 ", fmgc.FMGCInternal.rtePercent));
					} else if (num(fmgc.FMGCInternal.rteRsv) > 9.9) {
						me["Simple_C3B"].setText(sprintf("/%.1f                  ", fmgc.FMGCInternal.rtePercent));
					} else if (num(fmgc.FMGCInternal.rtePercent) > 9.9) {
						me["Simple_C3B"].setText(sprintf("/%.1f                   ", fmgc.FMGCInternal.rtePercent));
					} else {
						me["Simple_C3B"].setText(sprintf("/%.1f                    ", fmgc.FMGCInternal.rtePercent));
					}
				}
				if (fmgc.FMGCInternal.altAirportSet) {
					if (acconfig_weight_kgs.getValue() == 1) {
						me["Simple_L4"].setText(sprintf("%.1f", fmgc.FMGCInternal.altFuel * LBS2KGS));
					} else {
						me["Simple_L4"].setText(sprintf("%.1f", fmgc.FMGCInternal.altFuel));
					}
					me["Simple_L4"].setColor(BLUE);
					me["Simple_C4"].show();
					if (fmgc.FMGCInternal.altFuelSet) {
						if (num(fmgc.FMGCInternal.altFuel) > 9.9) {
							me["Simple_C4"].setText(sprintf("/%s               ", fmgc.FMGCInternal.altTime));
						} else {
							me["Simple_C4"].setText(sprintf("/%s                 ", fmgc.FMGCInternal.altTime));
						}
					} else {
						if (num(fmgc.FMGCInternal.altFuel) > 9.9) {
							me["Simple_C4"].setText(sprintf("/%s                 ", fmgc.FMGCInternal.altTime));
						} else {
							me["Simple_C4"].setText(sprintf("/%s                   ", fmgc.FMGCInternal.altTime));
						}
					}
				} else {
					me["Simple_L4"].setText("---.-/----");
					me["Simple_L4"].setColor(WHITE);
					me["Simple_C4"].hide();
				}
				if (acconfig_weight_kgs.getValue() == 1) {
					me["Simple_L5"].setText(sprintf("%.1f", fmgc.FMGCInternal.finalFuel * LBS2KGS));
				} else {
					me["Simple_L5"].setText(sprintf("%.1f", fmgc.FMGCInternal.finalFuel));
				}
				if (fmgc.FMGCInternal.finalTimeSet and fmgc.FMGCInternal.finalFuelSet) {
					if (num(fmgc.FMGCInternal.finalFuel) > 9.9) {
						me["Simple_C5"].setText(sprintf("/%s           ", fmgc.FMGCInternal.finalTime));
					} else {
						me["Simple_C5"].setText(sprintf("/%s             ", fmgc.FMGCInternal.finalTime));
					}
				} else if (fmgc.FMGCInternal.finalTimeSet) {
					if (num(fmgc.FMGCInternal.finalFuel) > 9.9) {
						me["Simple_C5"].setText(sprintf("/%s            ", fmgc.FMGCInternal.finalTime));
					} else {
						me["Simple_C5"].setText(sprintf("/%s              ", fmgc.FMGCInternal.finalTime));
					}
				} else if (fmgc.FMGCInternal.finalFuelSet) {
					if (num(fmgc.FMGCInternal.finalFuel) > 9.9) {
						me["Simple_C5"].setText(sprintf("/%s               ", fmgc.FMGCInternal.finalTime));
					} else {
						me["Simple_C5"].setText(sprintf("/%s                  ", fmgc.FMGCInternal.finalTime));
					}
				} else {
					if (num(fmgc.FMGCInternal.finalFuel) > 9.9) {
						me["Simple_C5"].setText(sprintf("/%s                 ", fmgc.FMGCInternal.finalTime));
					} else {
						me["Simple_C5"].setText(sprintf("/%s                   ", fmgc.FMGCInternal.finalTime));
					}
				}
				if (acconfig_weight_kgs.getValue() == 1) {
					me["Simple_L6"].setText(sprintf("%.1f", fmgc.FMGCInternal.minDestFob * LBS2KGS));
					me["Simple_R4"].setText(sprintf("%4.1f/" ~ fmgc.FMGCInternal.fffqSensor, fmgc.FMGCInternal.fob * LBS2KGS));
					me["Simple_R5"].setText(sprintf("%4.1f/", fmgc.FMGCInternal.fuelPredGw * LBS2KGS) ~ sprintf("%4.1f", fmgc.FMGCInternal.cg));
					me["Simple_R6"].setText(sprintf("%4.1f/" ~ fmgc.FMGCInternal.extraTime, fmgc.FMGCInternal.extraFuel * LBS2KGS));
				} else {
					me["Simple_L6"].setText(sprintf("%.1f", fmgc.FMGCInternal.minDestFob));
					me["Simple_R4"].setText(sprintf("%4.1f/" ~ fmgc.FMGCInternal.fffqSensor, fmgc.FMGCInternal.fob));
					me["Simple_R5"].setText(sprintf("%4.1f/", fmgc.FMGCInternal.fuelPredGw) ~ sprintf("%4.1f", fmgc.FMGCInternal.cg));
					me["Simple_R6"].setText(sprintf("%4.1f/" ~ fmgc.FMGCInternal.extraTime, fmgc.FMGCInternal.extraFuel));
				}
				
				me.colorLeft("ack", "ack", "blu", "ack", "blu", "blu");
				me.colorRight("ack", "ack", "blu", "grn", "grn", "grn");
			}
			
			me["Simple_R3S"].setText("ZFW/ZFWCG");
			me["Simple_R3"].setText(sprintf("%3.1f", fmgc.FMGCInternal.zfwcg));
			me["Simple_R3"].show();
			me["FUELPRED_ZFWCG"].hide();
			me["FUELPRED_ZFWCG_S"].show();
			if (fmgc.FMGCInternal.zfwcgSet) {
				me["Simple_R3"].setFontSize(normal);
			} else {
				me["Simple_R3"].setFontSize(small);
			}
			
			if (fmgc.FMGCInternal.zfwSet) {
				if (fmgc.FMGCInternal.zfw < 100) {
					if (acconfig_weight_kgs.getValue() == 1) {
						me["Simple_C3"].setText("          " ~ sprintf("%3.1f", fmgc.FMGCInternal.zfw * LBS2KGS));
					} else {
						me["Simple_C3"].setText("          " ~ sprintf("%3.1f", fmgc.FMGCInternal.zfw));
					}
				} else {
					if (acconfig_weight_kgs.getValue() == 1) {
						me["Simple_C3"].setText("         " ~ sprintf("%3.1f", fmgc.FMGCInternal.zfw * LBS2KGS));
					} else {
						me["Simple_C3"].setText("         " ~ sprintf("%3.1f", fmgc.FMGCInternal.zfw));
					}
				}
				me["Simple_C3"].show();
				me["FUELPRED_ZFW"].hide();
			} else {
				me["Simple_C3"].hide();
				me["FUELPRED_ZFW"].show();
			}
			
			if (fmgc.FMGCInternal.rteRsvSet) {
				me["Simple_L3"].setFontSize(normal);
				me["Simple_C3B"].setFontSize(small);
			} else if (fmgc.FMGCInternal.rtePercentSet) {
				me["Simple_L3"].setFontSize(small);
				me["Simple_C3B"].setFontSize(normal);
			} else {
				me["Simple_L3"].setFontSize(small);
				me["Simple_C3B"].setFontSize(small);
			}
			
			if (fmgc.FMGCInternal.altFuelSet and fmgc.FMGCInternal.crzSet == 1) {
				me["Simple_L4"].setFontSize(normal);
			} else {
				me["Simple_L4"].setFontSize(small);
			}
			
			if (fmgc.FMGCInternal.finalFuelSet and fmgc.FMGCInternal.finalTimeSet) {
				me["Simple_L5"].setFontSize(normal);
				me["Simple_C5"].setFontSize(normal);
			} else if (fmgc.FMGCInternal.finalFuelSet) {
				me["Simple_L5"].setFontSize(normal);
				me["Simple_C5"].setFontSize(small);
			} else if (fmgc.FMGCInternal.finalTimeSet) {
				me["Simple_L5"].setFontSize(small);
				me["Simple_C5"].setFontSize(normal);
			} else {
				me["Simple_L5"].setFontSize(small);
				me["Simple_C5"].setFontSize(small);
			}
			
			if (fmgc.FMGCInternal.minDestFobSet) {
				me["Simple_L6"].setFontSize(normal);
			} else {
				me["Simple_L6"].setFontSize(small);
			}
			
		} else if (page == "PROGPREF" or page == "PROGTO" or page == "PROGCLB" or page == "PROGCRZ" or page == "PROGDES" or page == "PROGAPPR" or page == "PROGDONE") {

			if (fmgc.FMGCInternal.phase == 0) {
				setprop("/MCDU[" ~ i ~ "]/page", "PROGPREF");
				page = "PROGPREF";
			} else if (fmgc.FMGCInternal.phase == 1) {
				setprop("/MCDU[" ~ i ~ "]/page", "PROGTO");
				page = "PROGTO";
			} else if (fmgc.FMGCInternal.phase == 2) {
				setprop("/MCDU[" ~ i ~ "]/page", "PROGCLB");
				page = "PROGCLB";
			} else if (fmgc.FMGCInternal.phase == 3) {
				setprop("/MCDU[" ~ i ~ "]/page", "PROGCRZ");
				page = "PROGCRZ";
			} else if (fmgc.FMGCInternal.phase == 4) {
				setprop("/MCDU[" ~ i ~ "]/page", "PROGDES");
				page = "PROGDES";
			} else if (fmgc.FMGCInternal.phase == 5 or fmgc.FMGCInternal.phase == 6) {
				setprop("/MCDU[" ~ i ~ "]/page", "PROGAPPR");
				page = "PROGAPPR";
			} else if (fmgc.FMGCInternal.phase == 7) {
				setprop("/MCDU[" ~ i ~ "]/page", "PROGDONE");
				page = "PROGDONE";
			}			
			
			if (!pageSwitch[i].getBoolValue()) {
				me["Simple"].show();
				me["Simple_Center"].show();
				me["FPLN"].hide();
				me["DIRTO_TMPY_group"].hide();
				me["INITA"].hide();
				me["IRSINIT"].hide();
				me["INITB"].hide();
				me["FUELPRED"].hide();
				me["WIND"].hide();
				me["PROG"].show();
				me["PERFTO"].hide();
				me["arrowsDepArr"].hide();
				me["PERFAPPR"].hide();
				me["PERFGA"].hide();
				
                var colortext = ["",""];

				if (page == "PROGPREF") {
					colortext[0] = "PREFLIGHT";
				} else if (page == "PROGTO") {
					colortext[0] = "TAKE OFF";
				} else if (page == "PROGCLB") {
					colortext[0] = "CLIMB";
				} else if (page == "PROGCRZ") {
					colortext[0] = "CRUISE";
				} else if (page == "PROGDES") {
					colortext[0] = "DESCENT";
				} else if (page == "PROGAPPR") {
					colortext[0] = "APPROACH";
				} else if (page == "PROGDONE") {
					colortext[0] = "DONE";
				}

				colortext[1] = (fmgc.FMGCInternal.flightNumSet and page != "PROGDONE") ? fmgc.FMGCInternal.flightNum : "";  #CHECKME - condition useful?

				me["Simple_Title"].setText(sprintf("   %-21s",colortext[0]));
				me["Simple_Title2"].setText(sprintf("%12s %-11s","",colortext[1]));
				
				me["Simple_Title"].show();
				me["Simple_Title"].setColor((page != "PROGDONE") ? GREEN : WHITE);
				me["Simple_Title2"].show();
				me["Simple_Title2"].setColor(WHITE);
				#me["Simple_PageNum"].setText("X/X");
				me["Simple_PageNum"].hide();
				me["ArrowLeft"].hide();
				me["ArrowRight"].hide();
				
				me.showLeft(1, 1, 1, 1, 1, 1);
				me["Simple_L0S"].hide();
				me.showLeftS(1, -1, 1, 1, 1, 1);
				me.showLeftArrow(-1, 1, -1, -1, 1, -1);
				me.showRight(1, -1, -1, 1, 1, 1);
				me.showRightS(1, -1, -1, -1, -1, 1);
				me.showRightArrow(-1, -1, -1, -1, -1, -1);
				me.showCenter(1, -1, -1, 1, -1, 1);
				me["Simple_C3B"].hide();
				me["Simple_C4B"].hide();
				me.showCenterS(1, -1, -1, -1, -1, 1);
				
				me.fontLeft(default, default, symbol, default, default, default);
				me.fontLeftS(default, default, default, default, default, default);
				me.fontRight(default, symbol, symbol, symbol, default, default);
				me.fontRightS(default, default, default, default, default, default);

				me.fontSizeLeft(normal, normal, small, small, normal, small);
				me.fontSizeLeftS(small, small, small, small, small, small);
				me.fontSizeRight(normal, small, small, small, normal, small);
				me.fontSizeRightS(small, small, small, small, small, small);
				me.fontSizeCenter(small, normal, small, small, small, normal);
				me.fontSizeCenterS(normal, small, small, small, small, small);				
				
				me["Simple_C1S"].setFontSize(small);

				me.colorLeft("blu", "wht", "blu", "wht", "wht", "blu");
				me.colorLeftS("wht", "wht", "wht", "wht", "wht", "wht");
				me.colorLeftArrow("wht", "wht", "wht", "wht", "wht", "wht");
				me.colorRight("mag", "wht", "blu", "blu", "grn", "grn");
				me.colorRightS("wht", "wht", "wht", "wht", "wht", "wht");
				me.colorRightArrow("wht", "wht", "wht", "wht", "wht", "wht");
				me.colorCenter("grn", "grn", "wht", "wht", "wht", "grn");
				me.colorCenterS("wht", "wht", "wht", "wht", "wht", "wht");

				if (page == "PROGCRZ") {
					me.showLeftS(0, 0, -1, 0, 0, 0);
					me.showCenterS(0, 0, 1, 0, 0, 0);
					#me.showRight(0, 0, 1, 0, 0, 0); #Add when implement cruise phase
					me.fontLeft(0, 0, default, 0, 0, 0);
				} else if (page == "PROGDES" or page == "PROGAPPR") {
					me.showCenter(0, 1, 0, 0, 0, 0);
					me.showRight(0, 1, 0, 0, 0, 0);		
					#me["Simple_C2"].setFontSize(normal);			
					#me["Simple_R2"].setFontSize(normal);			
				} 
				#else if (page == "PROGAPPR") {  # A/C without GPS
				#	me["Simple_L5S"].setFontSize(small);
				#	me["Simple_L5S"].setColor(GREEN);					
				#	me["Simple_L5"].setFontSize(small);
				#	me["Simple_L5"].setColor(GREEN);
				#	me["Simple_R5S"].setFontSize(small);
				#	me["Simple_R5S"].setColor(WHITE);					
				#	me["Simple_R5S"].show();
				#	me["Simple_R5"].setFontSize(small);
				#	me["Simple_R5"].setColor(WHITE);	
				#	me.showLeftArrow(-1, 1, -1, -1, -1, -1);				
				#}
				
				pageSwitch[i].setBoolValue(1);
			}
			
			if (fmgc.FMGCInternal.crzSet and page != "PROGDES") {
				if (getprop("/it-autoflight/input/alt") > fmgc.FMGCInternal.crzProg * 100) {
					me["Simple_L1"].setText(sprintf("%s", "FL" ~ getprop("/it-autoflight/input/alt") / 100));
				} else {
					me["Simple_L1"].setText(sprintf("%s", "FL" ~ fmgc.FMGCInternal.crzProg));
				}
			} else {
				me["Simple_L1"].setText("-----");
			}
			me["Simple_L2"].setText(" REPORT");
			if (page == "PROGCRZ") {
				me["Simple_L3"].setText(" -----.--/-----.--");
				#me["Simple_R3"].setText("AGN *"); #Add when implement cruise phase
				me["PROG_UPDATE"].hide();
			} else {
				me["PROG_UPDATE"].show();
				me["Simple_L3"].setText("  [    ]");
			}
			me["Simple_L5"].setText(" GPS");
			me["Simple_L6"].setText("----");
			me["Simple_L1S"].setText(" CRZ");
			me["Simple_L3S"].setText(" UPDATE AT");
			me["Simple_L4S"].setText("  BRG /DIST");
			me["Simple_L5S"].setText(" PREDICTIVE");
			me["Simple_L6S"].setText("REQUIRED");

			if (page != "PROGDONE") {			
				me["Simple_R1"].setText("FL398 ");
			} else {
				me["Simple_L1"].setText("_____");
				me["Simple_R1"].setText("----- ");				
				me["Simple_L1"].setColor(AMBER);
				me["Simple_C1"].setColor(WHITE);
				me["Simple_R1"].setColor(WHITE);
				me["Simple_R5"].hide();
			}

			if (page == "PROGDES" or page == "PROGAPPR") {			
				var vdev = 750; #CHECKME i dunno the meaning, but I found this value in the source
				var vdev_sign = (vdev>=0) ? "+" : "-";			
				me["Simple_C2"].setText(sprintf("%17s%4d   ",vdev_sign,abs(vdev)));
				me["Simple_R2"].setText(sprintf("%30s","VDEV=       FT "));
			}
			
			if (mcdu.bearingDistances[i].displayID != nil) {
				me["Simple_R4"].setFont(default);
				me["Simple_R4"].setFontSize(normal);
				me["Simple_R4"].setText(mcdu.bearingDistances[i].displayID);
			} else {
				me["Simple_R4"].setFont(symbol);
				me["Simple_R4"].setFontSize(small);
				me["Simple_R4"].setText("[    ]");
			}
			
			if (mcdu.bearingDistances[i].selectedPoint != nil) {
				me["Simple_L4"].setColor(GREEN);
				me["Simple_L4"].setText(sprintf("%3.0fg /%4.1f",mcdu.bearingDistances[i].bearing,mcdu.bearingDistances[i].distance));
			} else {
				me["Simple_L4"].setColor(WHITE);
				me["Simple_L4"].setText(" ---g /----.-");
			}
			
			me["Simple_R5"].setText("GPS PRIMARY");
			me["Simple_R6"].setText("----");
			me["Simple_R1S"].setText("REC MAX ");
			me["Simple_R6S"].setText("ESTIMATED");
			me["Simple_C1"].setText("-----");
			me["Simple_C1S"].setText("OPT");
			me["Simple_C3S"].setText("CONFIRM UPDATE AT");
			me["Simple_C4"].setText("      TO");
			me["Simple_C6S"].setText("ACCUR");
			if (systems.ADIRS.Operating.aligned[0].getValue() or systems.ADIRS.Operating.aligned[1].getValue()) me["Simple_C6"].setText("HIGH");
			else  me["Simple_C6"].setText("LOW");

			#if (page == "PROGAPPR") {  # A/C without GPS
			#	me["Simple_L5"].setText(sprintf(" DIR  DIST  TO  DEST=%6d",0));
			#	me["Simple_L5S"].setText(sprintf("REQD  DIST  TO  LAND=%6d",0));
			#	me["Simple_R5"].setText("MN");
			#	me["Simple_R5S"].setText("MN");
			#}
			
		} else if (page == "PERFTO") {
			if (!pageSwitch[i].getBoolValue()) {
				me["Simple"].show();
				me["Simple_Center"].show();
				me["FPLN"].hide();
				me["DIRTO_TMPY_group"].hide();
				me["INITA"].hide();
				me["IRSINIT"].hide();
				me["INITB"].hide();
				me["FUELPRED"].hide();
				me["WIND"].hide();
				me["PROG"].hide();
				me["PERFTO"].show();
				me["arrowsDepArr"].hide();
				me["PERFAPPR"].hide();
				me["PERFGA"].hide();
				me["Simple_Title"].show();
				me["Simple_Title"].setText("TAKE OFF");
				me["Simple_PageNum"].setText("X/X");
				me["Simple_PageNum"].hide();
				me["ArrowLeft"].hide();
				me["ArrowRight"].hide();
				
				me.showLeft(1, 1, 1, 1, 1, 1);
				me["Simple_L0S"].hide();
				me.showLeftS(1, 1, 1, 1, 1, 1);
				me.showLeftArrow(-1, -1, -1, -1, -1, 1);
				me.showRight(-1, 1, 1, 1, 1, 1);
				me.showRightS(1, 1, 1, 1, 1, 1);
				me.showRightArrow(-1, -1, -1, -1, -1, 1);
				me.showCenter(1, 1, 1, -1, -1, -1);
				me["Simple_C3B"].hide();
				me["Simple_C4B"].hide();
				me.showCenterS(1, 1, 1, -1, -1, -1);
				
				me.fontLeft(default, default, default, default, default, default);
				me.fontLeftS(default, default, default, default, default, default);
				me.fontRight(default, symbol, 0, 0, default, default);
				me.fontRightS(default, default, default, default, default, default);
				
				me.fontSizeLeft(normal, normal, normal, normal, 0, normal);
				me.fontSizeRight(normal, small, 0, 0, 0, normal);
				me.fontSizeCenter(small, small, small, 0, 0, 0);
				
				me.colorLeft("blu", "blu", "blu", "blu", "blu", "wht");
				me.colorLeftS("wht", "wht", "wht", "wht", "wht", "wht");
				me.colorLeftArrow("wht", "wht", "wht", "wht", "wht", "wht");
				me.colorRight("grn", "blu", "blu", "blu", "blu", "wht");
				me.colorRightS("wht", "wht", "wht", "wht", "wht", "wht");
				me.colorRightArrow("wht", "wht", "wht", "wht", "wht", "wht");
				me.colorCenter("grn", "grn", "grn", "wht", "wht", "wht");
				me.colorCenterS("wht", "wht", "wht", "wht", "wht", "wht");

				me["Simple_Title"].setText("TAKE OFF");
				
				pageSwitch[i].setBoolValue(1);
			}
			
			me["Simple_L4"].setText(sprintf("%3.0f", fmgc.FMGCInternal.transAlt));
			me["Simple_L5"].setText(sprintf("%3.0f", clbReducFt.getValue()) ~ sprintf("/%3.0f", reducFt.getValue()));
			me["Simple_L6"].setText(" TO DATA");
			me["Simple_L1S"].setText(" V1");
			me["Simple_L2S"].setText(" VR");
			me["Simple_L3S"].setText(" V2");
			me["Simple_L4S"].setText("TRANS ALT");
			me["Simple_L5S"].setText("THR RED/ACC");
			me["Simple_L6S"].setText(" UPLINK");
			me["Simple_R2"].setText("[   ]  ");
			me["Simple_R5"].setText(sprintf("%3.0f", engOutAcc.getValue()));
			me["Simple_R6"].setText("PHASE ");
			me["Simple_R1S"].setText("RWY ");
			me["Simple_R2S"].setText("TO SHIFT ");
			me["Simple_R3S"].setText("FLAPS/THS");
			me["Simple_R4S"].setText("FLEX TO TEMP");
			me["Simple_R5S"].setText("ENG OUT ACC");
			me["Simple_R6S"].setText("NEXT ");
			
			if (fmgc.FMGCInternal.transAltSet) {
				me["Simple_L4"].setFontSize(normal);
			} else {
				me["Simple_L4"].setFontSize(small);
			}
			
			if (fmgc.FMGCInternal.phase == 0 or fmgc.FMGCInternal.phase == 7) {
				me["Simple_L6_Arrow"].show(); 
				me["Simple_L6"].show();
				me["Simple_L6S"].show();
			} else {
				me["Simple_L6_Arrow"].hide(); 
				me["Simple_L6"].hide();
				me["Simple_L6S"].hide();
			}

			if (fmgc.FMGCInternal.phase == 1) {  # GREEN title and not modifiable on TO phase
				me["Simple_Title"].setColor(GREEN);
				me.colorLeft("grn", "grn", "grn", "blu", "grn", "wht");
				me.colorRight("grn", "blu", "grn", "grn", "grn", "wht");
			} else {				
				me["Simple_Title"].setColor(WHITE);
				me.colorLeft("blu", "blu", "blu", "blu", "blu", "wht");
				me.colorRight("grn", "blu", "blu", "blu", "blu", "wht");
			}
			
			if (fmgc.flightPlanController.flightplans[2].departure_runway != nil) {
				me["Simple_R1"].setText(fmgc.flightPlanController.flightplans[2].departure_runway.id ~ " ");
				me["Simple_R1"].show();
			} else {
				me["Simple_R1"].hide();
			}

			
			
			if (fmgc.FMGCInternal.v1set) {
				me["PERFTO_V1"].hide();
				me["Simple_L1"].setText(sprintf("%3.0f", fmgc.FMGCInternal.v1));
				me["Simple_L1"].show();
			} else {
				me["PERFTO_V1"].show();
				me["Simple_L1"].hide();
			}
			
			if (fmgc.FMGCInternal.vrset) {
				me["PERFTO_VR"].hide();
				me["Simple_L2"].setText(sprintf("%3.0f", fmgc.FMGCInternal.vr));
				me["Simple_L2"].show();
			} else {
				me["PERFTO_VR"].show();
				me["Simple_L2"].hide();
			}
			
			if (fmgc.FMGCInternal.v2set) {
				me["PERFTO_V2"].hide();
				me["Simple_L3"].setText(sprintf("%3.0f", fmgc.FMGCInternal.v2));
				me["Simple_L3"].show();
			} else {
				me["PERFTO_V2"].show();
				me["Simple_L3"].hide();
			}
			
			if (thrAccSet.getValue() == 1) {
				me["Simple_L5"].setFontSize(normal);
			} else {
				me["Simple_L5"].setFontSize(small);
			}
			
			if (flapTHSSet.getValue() == 1) {
				me["Simple_R3"].setFont(default); 
				me["Simple_R3"].setFontSize(normal);
				if (THSTO.getValue() >= 0) {
					me["Simple_R3"].setText(sprintf("%s", flapTO.getValue()) ~ sprintf("/UP%2.1f", THSTO.getValue()));
				} else {
					me["Simple_R3"].setText(sprintf("%s", flapTO.getValue()) ~ sprintf("/DN%2.1f", -1 * THSTO.getValue()));
				}
			} else {
				me["Simple_R3"].setFont(symbol); 
				me["Simple_R3"].setFontSize(small); 
				me["Simple_R3"].setText("[  ]/[    ]");
			}
			if (flexSet.getValue() == 1) {
				me["Simple_R4"].setFont(default); 
				me["Simple_R4"].setFontSize(normal); 
				me["Simple_R4"].setText(sprintf("%3.0f", flex.getValue()));
			} else {
				me["Simple_R4"].setFont(symbol); 
				me["Simple_R4"].setFontSize(small); 
				me["Simple_R4"].setText("[   ]");
			}
			if (engOutAccSet.getValue() == 1) {
				me["Simple_R5"].setFontSize(normal);
			} else {
				me["Simple_R5"].setFontSize(small);
			}
			
			if ((fmgc.FMGCInternal.zfwSet and fmgc.FMGCInternal.blockSet) or fmgc.FMGCInternal.phase == 1) {
				me["Simple_C1"].setText(sprintf("%3.0f", fmgc.FMGCInternal.flap2_to));
				me["Simple_C2"].setText(sprintf("%3.0f", fmgc.FMGCInternal.slat_to));
				me["Simple_C3"].setText(sprintf("%3.0f", fmgc.FMGCInternal.clean_to));
			} else {
				me["Simple_C1"].setText(" ---");
				me["Simple_C2"].setText(" ---");
				me["Simple_C3"].setText(" ---");
			}
			
			me["Simple_C1S"].setText("FLP RETR");
			me["Simple_C2S"].setText("SLT RETR");
			me["Simple_C3S"].setText("CLEAN  ");

		} else if (page == "PERFCLB") {
			if (!pageSwitch[i].getBoolValue()) {
				me.defaultHideWithCenter();
				me["arrowsDepArr"].hide();
				me["PERFAPPR"].hide();
				me["PERFGA"].hide();
				me["Simple_Title"].show();
				me["Simple_Title"].setText("CLB");
				me.defaultPageNumbers();
				
				me.showLeft(1, 1, 1, 1, 1, 1);
				me["Simple_L0S"].hide();
				me.showLeftS(1, 1, 1, 1, 1, 1);
				me.showLeftArrow(-1, -1, -1, -1, 1, 1);
				me.showRight(-1, 1, 1, 1, -1, 1);
				me.showRightS(-1, -1, 1, -1, 1, 1);
				me.showRightArrow(-1, -1, -1, -1, -1, 1);
				me.showCenter(-1, 1, 1, 1, -1, -1);
				me["Simple_C3B"].hide();
				me["Simple_C4B"].hide();
				me.showCenterS(-1, -1, 1, -1, 1, -1);
				
				me.fontLeft(default, default, default, symbol, default, default);
				me.fontLeftS(default, default, default, default, default, default);
				me.fontRight(default, default, default, default, default, default);
				me.fontRightS(default, default, default, default, default, default);
				
				me.fontSizeLeft(normal, normal, small, small, normal, normal);
				me.fontSizeLeftS(0, 0, 0, 0, small, 0);
				me.fontSizeRight(normal, normal, normal, normal, normal, normal);
				me.fontSizeCenterS(small, small, small, small, small, small);
				me.fontSizeCenter(normal, small, normal, normal, small, normal);
				
				me.colorLeft("grn", "blu", "grn", "blu", "wht", "blu");
				me.colorLeftS("wht", "wht", "wht", "wht", "grn", "blu");
				me.colorLeftArrow("wht", "wht", "wht", "wht", "wht", "wht");
				me.colorRight("wht", "blu", "grn", "grn", "wht", "wht");
				me.colorRightS("wht", "wht", "wht", "wht", "grn", "wht");
				me.colorRightArrow("wht", "wht", "wht", "wht", "wht", "wht");
				me.colorCenter("wht", "wht", "grn", "grn", "wht", "wht");
				me.colorCenterS("wht", "wht", "wht", "wht", "grn", "wht");
				
				pageSwitch[i].setBoolValue(1);
			}
			
			if (fmgc.FMGCInternal.phase == 2) {
				me["Simple_Title"].setColor(GREEN);
				me.showLeft(0, 0, 0, 0, 1, 0);
				me.showLeftS(0, 0, 0, 0, 1, 0);
				me.showLeftArrow(0, 0, 0, 0, 1, 1);
				me.showRight(0, 0, 0, 1, 0, 0);
				me.showRightS(0, 0, 0, 0, 1, 0);
				me.showCenterS(0, 0, 0, 0, 1, 0);
				
				if (managedSpeed.getValue() == 1) {
					me.showLeft(0, 0, 0, -1, 0, 0);
					me.showLeftS(0, 0, 0, -1, 0, 0);
				} else {
					me["Simple_L4S"].setText(" SELECTED");
					me.showLeft(0, 0, 0, 1, 0, 0);
					me.showLeftS(0, 0, 0, 1, 0, 0);
				}
				
				if (activate_once.getValue() == 0 and activate_twice.getValue() == 0) {
					me["Simple_L6S"].setText(" ACTIVATE");
					me["Simple_L6"].setText(" APPR PHASE");
					me.colorLeft("ack", "ack", "ack", "ack", "ack", "blu");
					me.colorLeftS("ack", "ack", "ack", "ack", "ack", "blu");
					me.colorLeftArrow("ack", "ack", "ack", "ack", "ack", "blu");
				} else if (activate_once.getValue() == 1 and activate_twice.getValue() == 0) {
					me["Simple_L6S"].setText(" CONFIRM");
					me["Simple_L6"].setText(" APPR PHASE");
					me.colorLeft("ack", "ack", "ack", "ack", "ack", "amb");
					me.colorLeftS("ack", "ack", "ack", "ack", "ack", "amb");
					me.colorLeftArrow("ack", "ack", "ack", "ack", "ack", "amb");
				} else if (fmgc.FMGCInternal.phase == 5) {
					me["Simple_L6S"].setText("");
					me["Simple_L6"].setText("");
					me.colorLeft("ack", "ack", "ack", "ack", "ack", "blu");
					me.colorLeftS("ack", "ack", "ack", "ack", "ack", "blu");
					me.colorLeftArrow("ack", "ack", "ack", "ack", "ack", "blu");
					me.showLeftArrow(0, 0, 0, 0, 0, -1);
				} else {
					setprop("/FMGC/internal/activate-once", 0);
					setprop("/FMGC/internal/activate-twice", 0);
				}
			} else {
				me["Simple_Title"].setColor(WHITE);
				me.showLeft(0, 0, 0, 0, -1, 0);
				me.showLeftS(0, 0, 0, 0, -1, 0);
				me.showLeftArrow(0, 0, 0, 0, -1, 0);
				me.showRight(0, 0, 0, -1, 0, 0);
				me.showRightS(0, 0, 0, 0, -1, 0);
				me.showCenterS(0, 0, 0, 0, -1, 0);
				
				me.colorLeft("ack", "ack", "ack", "ack", "ack", "wht");
				me.colorLeftS("ack", "ack", "ack", "ack", "ack", "wht");
				me.colorLeftArrow("ack", "ack", "ack", "ack", "ack", "wht");
				
				me["Simple_L4S"].setText(" PRESEL");
				me["Simple_L6S"].setText(" PREV");
				me["Simple_L6"].setText(" PHASE");	
			}
			
			me["Simple_L1S"].setText("ACT MODE");
			if (managedSpeed.getValue() == 1) {
				me["Simple_L1"].setText("MANAGED");
				me["Simple_L4"].setText(" [    ]");
				me.fontLeft(0, 0, 0, symbol, 0, 0);
			} else {
				me["Simple_L1"].setText("SELECTED");
				if (fmgc.Input.ktsMach.getValue()) {
					me["Simple_L4"].setText(sprintf(" %3.3f", getprop("/it-autoflight/input/mach")));
				} else {
					me["Simple_L4"].setText(sprintf(" %s", int(getprop("/it-autoflight/input/kts"))));
				}
				me.fontLeft(0, 0, 0, default, 0, 0);
			}		
			
			me["Simple_L2S"].setText(" CI");
			if (fmgc.FMGCInternal.costIndexSet) {
				me["Simple_L2"].setColor(BLUE);
				me["Simple_L2"].setText(sprintf(" %s", fmgc.FMGCInternal.costIndex));
			} else {
				me["Simple_L2"].setColor(WHITE);
				me["Simple_L2"].setText(" ---");
			}
			
			me["Simple_L3S"].setText(" MANAGED");
			if (fmgc.Input.ktsMach.getValue()) {
				me["Simple_L3"].setText(sprintf(" %3.3f", fmgc.FMGCInternal.mngSpd));
			} else {
				me["Simple_L3"].setText(sprintf(" %s", int(fmgc.FMGCInternal.mngSpd)));
			}
			
			me["Simple_L5S"].setText(" EXPEDITE");
			me["Simple_L5"].setText(" T/O PHASE");
			
			me["Simple_C2"].setText("         PRED TO");
			me["Simple_R2"].setText(sprintf("FL%s", getprop("/it-autoflight/input/alt") / 100));
			
			me["Simple_R3S"].setText("DIST");
			me["Simple_R3"].setText("---");
			
			me["Simple_R4"].setText("---");
			me["Simple_R5S"].setText("---");
			
			me["Simple_C3S"].setText("UTC");
			me["Simple_C3"].setText("----");
			me["Simple_C4"].setText("----");
			me["Simple_C5S"].setText("----");

			me["Simple_R6S"].setText("NEXT ");
			me["Simple_R6"].setText("PHASE ");

		} else if (page == "PERFCRZ") {
			if (!pageSwitch[i].getBoolValue()) {
				me.defaultHideWithCenter();
				me["arrowsDepArr"].hide();
				me["PERFAPPR"].hide();
				me["PERFGA"].hide();
				me["Simple_Title"].show();
				me["Simple_Title"].setText("CRZ");
				me.defaultPageNumbers();
				
				me.showLeft(1, 1, 1, 1, -1, 1);
				me["Simple_L0S"].hide();
				me.showLeftS(1, 1, 1, 1, -1, 1);
				me.showLeftArrow(-1, -1, -1, -1, -1, 1);
				me.showRight(1, -1, -1, -1, 1, 1);
				me.showRightS(1, -1, -1, -1, 1, 1);
				me.showRightArrow(-1, -1, -1, -1, -1, 1);
				me.showCenter(1, -1, -1, -1, 1, -1);
				me["Simple_C3B"].hide();
				me["Simple_C4B"].hide();
				me.showCenterS(1, -1, -1, -1, -1, -1);
				
				me.fontLeft(default, default, default, symbol, default, default);
				me.fontLeftS(default, default, default, default, default, default);
				me.fontRight(default, default, default, default, default, default);
				me.fontRightS(default, default, default, default, default, default);
				
				me.fontSizeLeft(normal, normal, small, small, normal, normal);
				me.fontSizeRight(normal, normal, normal, normal, small, normal);
				me.fontSizeCenterS(small, small, small, small, small, small);
				me.fontSizeCenter(normal, small, normal, normal, small, normal);
				
				me.colorLeft("grn", "blu", "grn", "blu", "wht", "blu");
				me.colorLeftS("wht", "wht", "wht", "wht", "grn", "blu");
				me.colorLeftArrow("wht", "wht", "wht", "wht", "wht", "wht");
				me.colorRight("wht", "blu", "grn", "grn", "wht", "wht");
				me.colorRightS("wht", "wht", "wht", "wht", "wht", "wht");
				me.colorRightArrow("wht", "wht", "wht", "wht", "wht", "wht");
				me.colorCenter("wht", "wht", "grn", "grn", "blu", "wht");
				me.colorCenterS("wht", "wht", "wht", "wht", "grn", "wht");
				
				pageSwitch[i].setBoolValue(1);
			}
			
			if (fmgc.FMGCInternal.phase == 3) {
				me["Simple_Title"].setColor(GREEN);

				if (managedSpeed.getValue() == 1) {
					me.showLeft(0, 0, 0, -1, 0, 0);
					me.showLeftS(0, 0, 0, -1, 0, 0);
				} else {
					me["Simple_L4S"].setText(" SELECTED");
					me.showLeft(0, 0, 0, 1, 0, 0);
					me.showLeftS(0, 0, 0, 1, 0, 0);
				}
				
				if (activate_once.getValue() == 0 and activate_twice.getValue() == 0) {
					me["Simple_L6S"].setText(" ACTIVATE");
					me["Simple_L6"].setText(" APPR PHASE");
					me.colorLeft("ack", "ack", "ack", "ack", "ack", "blu");
					me.colorLeftS("ack", "ack", "ack", "ack", "ack", "blu");
					me.colorLeftArrow("ack", "ack", "ack", "ack", "ack", "blu");
				} else if (activate_once.getValue() == 1 and activate_twice.getValue() == 0) {
					me["Simple_L6S"].setText(" CONFIRM");
					me["Simple_L6"].setText(" APPR PHASE");
					me.colorLeft("ack", "ack", "ack", "ack", "ack", "amb");
					me.colorLeftS("ack", "ack", "ack", "ack", "ack", "amb");
					me.colorLeftArrow("ack", "ack", "ack", "ack", "ack", "amb");
				} else if (fmgc.FMGCInternal.phase == 5) {
					me["Simple_L6S"].setText("");
					me["Simple_L6"].setText("");
					me.colorLeft("ack", "ack", "ack", "ack", "ack", "blu");
					me.colorLeftS("ack", "ack", "ack", "ack", "ack", "blu");
					me.colorLeftArrow("ack", "ack", "ack", "ack", "ack", "blu");
					me.showLeftArrow(0, 0, 0, 0, 0, -1);
				} else {
					setprop("/FMGC/internal/activate-once", 0);
					setprop("/FMGC/internal/activate-twice", 0);
				}
			} else {
				me["Simple_Title"].setColor(WHITE);
				
				me.colorLeft("ack", "ack", "ack", "ack", "ack", "wht");
				me.colorLeftS("ack", "ack", "ack", "ack", "ack", "wht");
				me.colorLeftArrow("ack", "ack", "ack", "ack", "ack", "wht");
				
				me["Simple_L4S"].setText(" PRESEL");
				me["Simple_L6S"].setText(" PREV");
				me["Simple_L6"].setText(" PHASE");	
			}
			
			me["Simple_L1S"].setText("ACT MODE");
			if (managedSpeed.getValue() == 1) {
				me["Simple_L1"].setText("MANAGED");
				me["Simple_L4"].setText(" [    ]");
				me.fontLeft(0, 0, 0, symbol, 0, 0);
			} else {
				me["Simple_L1"].setText("SELECTED");
				if (fmgc.Input.ktsMach.getValue()) {
					me["Simple_L4"].setText(sprintf(" %3.3f", getprop("/it-autoflight/input/mach")));
				} else {
					me["Simple_L4"].setText(sprintf(" %s", int(getprop("/it-autoflight/input/kts"))));
				}
				me.fontLeft(0, 0, 0, default, 0, 0);
			}
			
			if (fmgc.FMGCInternal.costIndexSet) {
				me["Simple_L2"].setColor(BLUE);
				me["Simple_L2"].setText(sprintf(" %s", fmgc.FMGCInternal.costIndex));
			} else {
				me["Simple_L2"].setColor(WHITE);
				me["Simple_L2"].setText(" ---");
			}
			
			me["Simple_L1S"].setText("ACT MODE");
			me["Simple_L2S"].setText(" CI");
			
			me["Simple_L3S"].setText(" MANAGED");
			if (fmgc.Input.ktsMach.getValue()) {
				me["Simple_L3"].setText(sprintf(" %3.3f", fmgc.FMGCInternal.mngSpd));
			} else {
				me["Simple_L3"].setText(sprintf(" %s", int(fmgc.FMGCInternal.mngSpd)));
			}
			
			me["Simple_R1S"].setText("DEST EFOB");
			me["Simple_R1"].setText("---");
			
			me["Simple_R5S"].setText("DES CABIN RATE");
			me["Simple_C5"].setText("             -350");
			me["Simple_R5"].setText("FT/MIN");
			
			me["Simple_C1S"].setText("UTC");
			me["Simple_C1"].setText("---");
			
			me["Simple_R6S"].setText("NEXT ");
			me["Simple_R6"].setText("PHASE ");
			
		} else if (page == "PERFDES") {
			if (!pageSwitch[i].getBoolValue()) {
				me.defaultHideWithCenter();
				me["arrowsDepArr"].hide();
				me["PERFAPPR"].hide();
				me["PERFGA"].hide();
				me["Simple_Title"].show();
				me["Simple_Title"].setText("DES");
				me.defaultPageNumbers();
				
				me.showLeft(1, 1, 1, 1, 1, 1);
				me["Simple_L0S"].hide();
				me.showLeftS(1, 1, 1, 1, -1, 1);
				me.showLeftArrow(-1, -1, -1, -1, -1, 1);
				me.showRight(1, 1, -1, 1, -1, 1);
				me.showRightS(1, -1, 1, -1, -1, 1);
				me.showRightArrow(-1, -1, -1, -1, -1, 1);
				me.showCenter(1, 1, -1, 1, 1, -1);
				me["Simple_C3B"].hide();
				me["Simple_C4B"].hide();
				me.showCenterS(1, -1, 1, -1, -1, -1);
				
				me.fontLeft(default, default, default, symbol, default, default);
				me.fontLeftS(default, default, default, default, default, default);
				me.fontRight(default, default, default, default, default, default);
				me.fontRightS(default, default, default, default, default, default);
				
				me.fontSizeLeft(normal, normal, small, small, small, normal);
				me.fontSizeLeftS(0, 0, 0, 0, small, 0);
				me.fontSizeRight(normal, normal, normal, normal, normal, normal);
				me.fontSizeCenterS(small, small, small, small, small, small);
				me.fontSizeCenter(normal, small, normal, normal, small, normal);
				
				me.colorLeft("grn", "blu", "grn", "blu", "grn", "blu");
				me.colorLeftS("wht", "wht", "wht", "wht", "grn", "blu");
				me.colorLeftArrow("wht", "wht", "wht", "wht", "wht", "wht");
				me.colorRight("wht", "blu", "grn", "grn", "wht", "wht");
				me.colorRightS("wht", "wht", "wht", "wht", "grn", "wht");
				me.colorRightArrow("wht", "wht", "wht", "wht", "wht", "wht");
				me.colorCenter("wht", "wht", "grn", "grn", "grn", "wht");
				me.colorCenterS("wht", "wht", "wht", "wht", "grn", "wht");
				
				pageSwitch[i].setBoolValue(1);
			}
			
			if (fmgc.FMGCInternal.phase == 4) {
				me["Simple_Title"].setColor(GREEN);
				me.showLeft(0, 0, 0, 0, 1, 0);
				me.showRight(0, 1, 0, 1, 0, 0);
				me.showRightS(0, 0, 1, 0, 0, 0);
				me.showCenter(0, 1, 0, 1, 1, 0);
				me.showCenterS(0, 0, 1, 0, 0, 0);

				if (managedSpeed.getValue() == 1) {
					me.showLeft(0, 0, 0, -1, 0, 0);
					me.showLeftS(0, 0, 0, -1, 0, 0);
				} else {
					me["Simple_L4S"].setText(" SELECTED");
					me.showLeft(0, 0, 0, 1, 0, 0);
					me.showLeftS(0, 0, 0, 1, 0, 0);
				}
				
				if (activate_once.getValue() == 0 and activate_twice.getValue() == 0) {
					me["Simple_L6S"].setText(" ACTIVATE");
					me["Simple_L6"].setText(" APPR PHASE");
					me.colorLeft("ack", "ack", "ack", "ack", "ack", "blu");
					me.colorLeftS("ack", "ack", "ack", "ack", "ack", "blu");
					me.colorLeftArrow("ack", "ack", "ack", "ack", "ack", "blu");
				} else if (activate_once.getValue() == 1 and activate_twice.getValue() == 0) {
					me["Simple_L6S"].setText(" CONFIRM");
					me["Simple_L6"].setText(" APPR PHASE");
					me.colorLeft("ack", "ack", "ack", "ack", "ack", "amb");
					me.colorLeftS("ack", "ack", "ack", "ack", "ack", "amb");
					me.colorLeftArrow("ack", "ack", "ack", "ack", "ack", "amb");
				} else if (fmgc.FMGCInternal.phase == 5) {
					me["Simple_L6S"].setText("");
					me["Simple_L6"].setText("");
					me.colorLeft("ack", "ack", "ack", "ack", "ack", "blu");
					me.colorLeftS("ack", "ack", "ack", "ack", "ack", "blu");
					me.colorLeftArrow("ack", "ack", "ack", "ack", "ack", "blu");
					me.showLeftArrow(0, 0, 0, 0, 0, -1);
				} else {
					setprop("/FMGC/internal/activate-once", 0);
					setprop("/FMGC/internal/activate-twice", 0);
				}
			} else {
				me["Simple_Title"].setColor(WHITE);
				me.showLeft(0, 0, 0, 0, -1, 0);
				me.showRight(0, -1, 0, -1, 0, 0);
				me.showRightS(0, 0, -1, 0, 0, 0);
				me.showCenter(0, -1, 0, -1, -1, 0);
				me.showCenterS(0, 0, -1, 0, 0, 0);
				
				me.colorLeft("ack", "ack", "ack", "ack", "ack", "wht");
				me.colorLeftS("ack", "ack", "ack", "ack", "ack", "wht");
				me.colorLeftArrow("ack", "ack", "ack", "ack", "ack", "wht");
				
				me["Simple_L4S"].setText(" PRESEL");
				me["Simple_L6S"].setText(" PREV");
				me["Simple_L6"].setText(" PHASE");	
			}
			
			me["Simple_L1S"].setText("ACT MODE");
			if (managedSpeed.getValue() == 1) {
				me["Simple_L1"].setText("MANAGED");
				me["Simple_L4"].setText(" [    ]");
				me.fontLeft(0, 0, 0, symbol, 0, 0);
			} else {
				me["Simple_L1"].setText("SELECTED");
				if (fmgc.Input.ktsMach.getValue()) {
					me["Simple_L4"].setText(sprintf(" %3.3f", getprop("/it-autoflight/input/mach")));
				} else {
					me["Simple_L4"].setText(sprintf(" %3.0f", getprop("/it-autoflight/input/kts")));
				}
				me.fontLeft(0, 0, 0, default, 0, 0);
			}
			
			if (fmgc.FMGCInternal.costIndexSet) {
				me["Simple_L2"].setColor(BLUE);
				me["Simple_L2"].setText(sprintf(" %2.0f", fmgc.FMGCInternal.costIndex));
			} else {
				me["Simple_L2"].setColor(WHITE);
				me["Simple_L2"].setText(" ---");
			}
			
			me["Simple_L1S"].setText("ACT MODE");
			me["Simple_L2S"].setText(" CI");
			
			me["Simple_L3S"].setText(" MANAGED");
			if (fmgc.Input.ktsMach.getValue()) {
				me["Simple_L3"].setText(sprintf(" %3.3f", fmgc.FMGCInternal.mngSpd));
			} else {
				me["Simple_L3"].setText(sprintf(" %3.0f", fmgc.FMGCInternal.mngSpd));
			}
			
			me["Simple_L5"].setText(" EXPEDITE");
			
			me["Simple_R1S"].setText("DEST EFOB");
			me["Simple_R1"].setText("---");
			
			me["Simple_C2"].setText("         PRED TO");
			me["Simple_R2"].setText(sprintf("FL%3.0f", getprop("/it-autoflight/input/alt") / 100));
			
			me["Simple_R3S"].setText("DIST");
			me["Simple_R3"].setText("---");
			
			me["Simple_R4"].setText("---");
			me["Simple_R5S"].setText("---");
			
			me["Simple_C1S"].setText("UTC");
			me["Simple_C1"].setText("---");
			me["Simple_C3S"].setText("UTC");
			me["Simple_C3"].setText("----");
			me["Simple_C4"].setText("----");
			me["Simple_C5"].setText("----");

			me["Simple_R6S"].setText("NEXT ");
			me["Simple_R6"].setText("PHASE ");

		} else if (page == "PERFAPPR") {
			if (!pageSwitch[i].getBoolValue()) {
				me.defaultHideWithCenter();
				me["arrowsDepArr"].hide();
				me["PERFAPPR"].show();
				me["PERFGA"].hide();
				me["Simple_Title"].show();
				me["Simple_Title"].setText("APPR");
				me.defaultPageNumbers();
				
				me.showLeft(1, 1, 1, 1, 1, 1);
				me["Simple_L0S"].show();
				me.showLeftS(1, 1, 1, 1, 1, 1);
				me.showLeftArrow(-1, -1, -1, -1, -1, 1);
				me.showRight(1, 1, 1, 1, 1, 1);
				me.showRightS(1, 1, 1, 1, -1, 1);
				me.showRightArrow(-1, -1, -1, -1, -1, 1);
				me.showCenter(1, 1, 1, -1, 1, -1);
				me["Simple_C3B"].hide();
				me["Simple_C4B"].hide();
				me.showCenterS(1, 1, 1, -1, 1, -1);
				
				me.fontLeft(symbol, default, default, default, symbol, default);
				me.fontLeftS(default, default, default, default, default, default);
				me.fontRight(default, symbol, symbol, default, default, default);
				me.fontRightS(default, default, default, default, default, default);
				
				me.fontSizeLeft(small, small, small, small, small, normal);
				me.fontSizeRight(normal, small, small, small, normal, normal);
				me.fontSizeCenter(small, small, small, 0, small, 0);
				
				me.colorLeft("blu", "blu", "blu", "blu", "blu", "wht");
				me.colorLeftS("wht", "wht", "wht", "wht", "wht", "wht");
				me.colorLeftArrow("wht", "wht", "wht", "wht", "wht", "wht");
				me.colorRight("wht", "blu", "blu", "blu", "blu", "wht");
				me.colorRightS("wht", "wht", "wht", "wht", "wht", "wht");
				me.colorRightArrow("wht", "wht", "wht", "wht", "wht", "wht");
				me.colorCenter("grn", "grn", "grn", "wht", "grn", "wht");
				me.colorCenterS("wht", "wht", "wht", "wht", "wht", "wht");
				
				pageSwitch[i].setBoolValue(1);
			}
			
			if (fmgc.FMGCInternal.phase == 5) {
				me["Simple_Title"].setColor(GREEN);
			} else {
				me["Simple_Title"].setColor(WHITE);
			}
			
			me["Simple_L0S"].setText("DEST");
			me["Simple_L1S"].setText("QNH");
			if (dest_qnh.getValue() != -1) {
				if (dest_qnh.getValue() < 100) {
					me["Simple_L1"].setText(sprintf("%4.2f", dest_qnh.getValue()));
				} else {
					me["Simple_L1"].setText(sprintf("%4.0f", dest_qnh.getValue()));
				}
				me.fontLeft(default, 0, 0, 0, 0, 0);
			} else {
				me["Simple_L1"].setText("[    ]  ");
				me.fontLeft(symbol, 0, 0, 0, 0, 0);
			}
			
			me["Simple_L2S"].setText("TEMP");
			if (dest_temp.getValue() != -999) {
				me["Simple_L2"].setText(sprintf("%3.0fg", dest_temp.getValue()));
			} else {
				me["Simple_L2"].setText("---g");
			}
			
			me["Simple_L3S"].setText("MAG WIND");
			if (fmgc.FMGCInternal.destMagSet and fmgc.FMGCInternal.destWindSet) {
				me["Simple_L3"].setText(sprintf("%03.0fg", fmgc.FMGCInternal.destMag) ~ sprintf("/%.0f", fmgc.FMGCInternal.destWind));
				me["Simple_L3"].setFontSize(normal);
			} else {
				me["Simple_L3"].setFontSize(small);
				if (myDESWIND[i] != nil and myDESWIND[i].returnGRND() != nil) {
					var result = myDESWIND[i].returnGRND();
					me["Simple_L3"].setText(sprintf("%03.0fg", result[0]) ~ sprintf("/%.0f", result[1]));
				} else if (myDESWIND[math.abs(i-1)] != nil and myDESWIND[math.abs(i-1)].returnGRND() != nil) {
					var result = myDESWIND[math.abs(i-1)].returnGRND();
					me["Simple_L3"].setText(sprintf("%03.0fg", result[0]) ~ sprintf("/%.0f", result[1]));
				} else {
					me["Simple_L3"].setText("---g/---");
				}
			}
			
			me["Simple_L4S"].setText("TRANS FL");
			me["Simple_L4"].setText("FL" ~ sprintf("%2.0f", (fmgc.FMGCInternal.transAlt / 100)));
			
			if (fmgc.FMGCInternal.transAltSet) {
				me["Simple_L4"].setFontSize(normal);
			} else {
				me["Simple_L4"].setFontSize(small);
			}
			
			me["Simple_R1S"].setText("FINAL");
			if (fmgc.flightPlanController.flightplans[2].destination_runway != nil) {
				me["Simple_R1"].setText(sprintf("%s",fmgc.flightPlanController.flightplans[2].destination_runway.id));
				me["Simple_R1"].setColor(GREEN);
			} else {
				me["Simple_R1"].setText("--- ");
				me["Simple_R1"].setColor(WHITE);
			}
			
			me["Simple_R2S"].setText("BARO");
			if (getprop("/FMGC/internal/baro") != 99999) {
				me["Simple_R2"].setText(sprintf("%.0f", getprop("/FMGC/internal/baro")));
				me.fontRight(0, default, 0, 0, 0, 0);
				me.fontSizeRight(0, normal, 0, 0, 0, 0);
			} else {
				me["Simple_R2"].setText(" [    ]");
				me.fontRight(0, symbol, 0, 0, 0, 0);
				me.fontSizeRight(0, small, 0, 0, 0, 0);
			}
			
			me["Simple_R3S"].setText("RADIO");
			if (getprop("/FMGC/internal/radio") != 99999) {
				me["Simple_R3"].setText(sprintf("%.0f", getprop("/FMGC/internal/radio")));
				me.fontRight(0, 0, default, 0, 0, 0);
				me.fontSizeRight(0, 0, normal, 0, 0, 0);
			} else if (fmgc.FMGCInternal.radioNo) {
				me["Simple_R3"].setText("NO");
				me.fontRight(0, 0, default, 0, 0, 0);
				me.fontSizeRight(0, 0, normal, 0, 0, 0);
			} else {
				me["Simple_R3"].setText(" [    ]");
				me.fontRight(0, 0, symbol, 0, 0, 0);
				me.fontSizeRight(0, 0, small, 0, 0, 0);
			}
			
			me["Simple_R4S"].setText("LDG CONF  ");
			me["Simple_R4"].setText("CONF3  ");
			me["Simple_R5"].setText("FULL  ");
			if (fmgc.FMGCInternal.ldgConfig3 == 1 and fmgc.FMGCInternal.ldgConfigFull == 0) {
				me["PERFAPPR_LDG_3"].hide();
				me["PERFAPPR_LDG_F"].show();
				me.fontSizeRight(0, 0, 0, normal, small, 0);
			} else {
				me["PERFAPPR_LDG_3"].show();
				me["PERFAPPR_LDG_F"].hide();
				me.fontSizeRight(0, 0, 0, small, normal, 0);
			}

			me["Simple_L6S"].setText(" PREV");
			me["Simple_L6"].setText(" PHASE");
			
			me["Simple_R6S"].setText("NEXT ");
			me["Simple_R6"].setText("PHASE ");
			
			me["Simple_L5S"].setText(" VAPP");
			if ((fmgc.FMGCInternal.zfwSet and fmgc.FMGCInternal.blockSet) or fmgc.FMGCInternal.phase == 5) {
				me["Simple_C1"].setText(sprintf("%3.0f", fmgc.FMGCInternal.flap2_appr));
				me["Simple_C2"].setText(sprintf("%3.0f", fmgc.FMGCInternal.slat_appr));
				me["Simple_C3"].setText(sprintf("%3.0f", fmgc.FMGCInternal.clean_appr));
				me["Simple_C5"].setText(sprintf("%3.0f", fmgc.FMGCInternal.vls_appr));
				me["Simple_L5"].setText(sprintf("%3.0f", fmgc.FMGCInternal.vapp_appr));
				me.fontLeft(0, 0, 0, 0, default, 0);
				if (fmgc.FMGCInternal.vappSpeedSet) {
					me.fontSizeLeft(0, 0, 0, 0, normal, 0);
				} else {
					me.fontSizeLeft(0, 0, 0, 0, small, 0);
				}
			} else {
				me["Simple_C1"].setText(" ---");
				me["Simple_C2"].setText(" ---");
				me["Simple_C3"].setText(" ---");
				me["Simple_C5"].setText(" ---");
				if (fmgc.FMGCInternal.vappSpeedSet) {
					me["Simple_L5"].setText(sprintf("%3.0f", fmgc.FMGCInternal.vapp_appr));
					me.fontLeft(0, 0, 0, 0, default, 0);
					me.fontSizeLeft(0, 0, 0, 0, normal, 0);
				} else {
					me["Simple_L5"].setText("[    ]  ");
					me.fontLeft(0, 0, 0, 0, symbol, 0);
					me.fontSizeLeft(0, 0, 0, 0, small, 0);
				}
			}
			
			me["Simple_C1S"].setText("FLP RETR");
			me["Simple_C2S"].setText("SLT RETR");
			me["Simple_C3S"].setText("CLEAN  ");
			me["Simple_C5S"].setText("VLS   ");

		} else if (page == "PERFGA") {
			if (!pageSwitch[i].getBoolValue()) {
				me.defaultHideWithCenter();
				me["arrowsDepArr"].hide();
				me["PERFAPPR"].hide();
				me["PERFGA"].show();
				me["Simple_Title"].show();
				me["Simple_Title"].setText("GO AROUND");
				me.defaultPageNumbers();
				
				me.showLeft(-1, -1, -1, -1, 1, 1);
				me["Simple_L0S"].hide();
				me.showLeftS(-1, -1, -1, -1, 1, 1);
				me.showLeftArrow(-1, -1, -1, -1, -1, 1);
				me.showRight(-1, -1, -1, -1, 1, -1);
				me.showRightS(-1, -1, -1, -1, 1, -1);
				me.showRightArrow(-1, -1, -1, -1, -1, -1);
				me.showCenter(1, 1, 1, -1, -1, -1);
				me["Simple_C3B"].hide();
				me["Simple_C4B"].hide();
				me.showCenterS(1, 1, 1, -1, -1, -1);
				
				me.fontLeft(default, default, default, default, default, default);
				me.fontLeftS(default, default, default, default, default, default);
				me.fontRight(default, symbol, 0, 0, default, default);
				me.fontRightS(default, default, default, default, default, default);
				
				me.fontSizeLeft(normal, normal, normal, normal, 0, normal);
				me.fontSizeRight(normal, small, 0, 0, 0, normal);
				me.fontSizeCenter(small, small, small, 0, 0, 0);
				
				me.colorLeft("blu", "blu", "blu", "blu", "blu", "wht");
				me.colorLeftS("wht", "wht", "wht", "wht", "wht", "wht");
				me.colorLeftArrow("wht", "wht", "wht", "wht", "wht", "wht");
				me.colorRight("wht", "blu", "blu", "blu", "blu", "wht");
				me.colorRightS("wht", "wht", "wht", "wht", "wht", "wht");
				me.colorRightArrow("wht", "wht", "wht", "wht", "wht", "wht");
				me.colorCenter("grn", "grn", "grn", "wht", "wht", "wht");
				me.colorCenterS("wht", "wht", "wht", "wht", "wht", "wht");
				
				pageSwitch[i].setBoolValue(1);
			}
			
			if (fmgc.FMGCInternal.phase == 6) {
				me["Simple_Title"].setColor(GREEN);
			} else {
				me["Simple_Title"].setColor(WHITE);
			}
			
			if (thrAccSet.getValue() == 1) {
				me["Simple_L5"].setFontSize(normal);
			} else {
				me["Simple_L5"].setFontSize(small);
			}
			if (engOutAccSet.getValue() == 1) {
				me["Simple_R5"].setFontSize(normal);
			} else {
				me["Simple_R5"].setFontSize(small);
			}
			
			me["Simple_L5"].setText(sprintf("%3.0f", clbReducFt.getValue()) ~ sprintf("/%3.0f", reducFt.getValue()));
			me["Simple_L6"].setText(" PHASE");
			me["Simple_L5S"].setText("THR RED/ACC");
			me["Simple_L6S"].setText(" PREV");
			me["Simple_R5"].setText(sprintf("%3.0f", engOutAcc.getValue()));
			me["Simple_R5S"].setText("ENG OUT ACC");
			
			if ((fmgc.FMGCInternal.zfwSet and fmgc.FMGCInternal.blockSet) or fmgc.FMGCInternal.phase == 6) {
				me["Simple_C1"].setText(sprintf("%3.0f", fmgc.FMGCInternal.flap2_appr));
				me["Simple_C2"].setText(sprintf("%3.0f", fmgc.FMGCInternal.slat_appr));
				me["Simple_C3"].setText(sprintf("%3.0f", fmgc.FMGCInternal.clean_appr));
			} else {
				me["Simple_C1"].setText(" ---");
				me["Simple_C2"].setText(" ---");
				me["Simple_C3"].setText(" ---");
			}
			
			me["Simple_C1S"].setText("FLP RETR");
			me["Simple_C2S"].setText("SLT RETR");
			me["Simple_C3S"].setText("CLEAN  ");
		} else if (page == "WINDCLB" or page == "WINDCRZ" or page == "WINDDES" or page == "WINDHIST") {
			if (!pageSwitch[i].getBoolValue()) {
				me.defaultHideWithCenter();
				me["Simple_PageNum"].setText("X/X");
				me["Simple_PageNum"].hide();
				me["Simple_Title"].show();
				me["WIND"].show();
				me["ArrowLeft"].hide();
				me["ArrowRight"].hide();
				
				me["Simple_L0S"].hide();
				me["Simple_C3B"].hide();
				me["Simple_C4B"].hide();
				
				me.fontLeft(default, default, default, default, default, default);
				me.fontLeftS(default, default, default, default, default, default);
				me.fontRight(default, default, default, default, default, default);
				me.fontRightS(default, default, default, default, default, default);
				
				me.fontSizeLeft(normal, normal, normal, normal, normal, normal);
				
				me.colorLeftArrow("wht", "wht", "wht", "wht", "wht", "wht");
				me.colorRightArrow("wht", "wht", "wht", "wht", "wht", "wht");
				
				if (page == "WINDCLB") {
					myWind = myCLBWIND;
					me.colorLeftS("wht", "wht", "wht", "wht", "wht", "amb");
					me.colorRightS("wht", "wht", "amb", "wht", "wht", "amb");
					me.fontSizeCenter(normal, normal, normal, normal, normal, normal);
				} else if (page == "WINDCRZ") {
					myWind = myCRZWIND;
					me.colorLeftS("wht", "wht", "wht", "wht", "wht", "amb");
					me.colorRightS("wht", "amb", "wht", "wht", "wht", "amb");
					me.fontSizeCenter(normal, normal, normal, normal, normal, normal);
				} else if (page == "WINDDES") {
					myWind = myDESWIND;
					me.colorLeftS("wht", "wht", "wht", "wht", "wht", "amb");
					me.colorRightS("wht", "wht", "amb", "wht", "wht", "amb");
					me.fontSizeCenter(normal, normal, normal, normal, normal, normal);
				} else if (page == "WINDHIST") {
					myWind = myHISTWIND;
					me.colorLeftS("wht", "wht", "wht", "wht", "wht", "wht");
					me.colorRightS("wht", "wht", "wht", "wht", "wht", "wht");
					me.fontSizeCenter(small, small, small, small, small, normal);
				}
				
				if (page == "WINDHIST") {
					if (fmgc.windController.hist_winds.wind1.set) {
						me["WIND_INSERT_star"].show();
					} else {
						me["WIND_INSERT_star"].hide();
					}
					me["WIND_CANCEL"].hide();
				} else {
					if (fmgc.flightPlanController.temporaryFlag[i]) {
						me["WIND_CANCEL"].show();
						me["WIND_INSERT_star"].show();
					} else {
						me["WIND_CANCEL"].hide();
						me["WIND_INSERT_star"].hide();
					}
				}
				
				if (myWind[i] != nil) {
					if (page == "WINDCRZ") {
						me["Simple_Title"].setText(sprintf("%s", myWind[i].title[0] ~ myWind[i].title[1] ~ myWind[i].title[2]));
						if (fmgc.flightPlanController.temporaryFlag[i]) {
							if (size(fmgc.windController.nav_indicies[i]) > 1) {
								me["WIND_UPDOWN"].show();
							} else {
								me["WIND_UPDOWN"].hide();
							}
						} else {
							if (size(fmgc.windController.nav_indicies[2]) > 1) {
								me["WIND_UPDOWN"].show();
							} else {
								me["WIND_UPDOWN"].hide();
							}
						}
					} else {
						me["Simple_Title"].setText(sprintf("%s", myWind[i].title));
						me["WIND_UPDOWN"].hide();
					}
					
					me["Simple_Title"].setColor(getprop("/MCDUC/colors/" ~ myWind[i].titleColour ~ "/r"), getprop("/MCDUC/colors/" ~ myWind[i].titleColour ~ "/g"), getprop("/MCDUC/colors/" ~ myWind[i].titleColour ~ "/b"));
					
					me.dynamicPageArrowFunc(myWind[i]);
					me.colorLeftArrow(myWind[i].arrowsColour[0][0],myWind[i].arrowsColour[0][1],myWind[i].arrowsColour[0][2],myWind[i].arrowsColour[0][3],myWind[i].arrowsColour[0][4],myWind[i].arrowsColour[0][5]);
					
					me.dynamicPageFontFunc(myWind[i]);
					
					me.dynamicPageFunc(myWind[i].L1, "Simple_L1");
					me.dynamicPageFunc(myWind[i].L2, "Simple_L2");
					me.dynamicPageFunc(myWind[i].L3, "Simple_L3");
					me.dynamicPageFunc(myWind[i].L4, "Simple_L4");
					me.dynamicPageFunc(myWind[i].L5, "Simple_L5");
					me.dynamicPageFunc(myWind[i].L6, "Simple_L6");
					
					me.colorLeft(myWind[i].L1[2],myWind[i].L2[2],myWind[i].L3[2],myWind[i].L4[2],myWind[i].L5[2],myWind[i].L6[2]);
					
					me.dynamicPageFunc(myWind[i].C1, "Simple_C1");
					me.dynamicPageFunc(myWind[i].C2, "Simple_C2");
					me.dynamicPageFunc(myWind[i].C3, "Simple_C3");
					me.dynamicPageFunc(myWind[i].C4, "Simple_C4");
					me.dynamicPageFunc(myWind[i].C5, "Simple_C5");
					me.dynamicPageFunc(myWind[i].C6, "Simple_C6");
					
					me.colorCenter(myWind[i].C1[2],myWind[i].C2[2],myWind[i].C3[2],myWind[i].C4[2],myWind[i].C5[2],myWind[i].C6[2]);
					
					me.dynamicPageFunc(myWind[i].R1, "Simple_R1");
					me.dynamicPageFunc(myWind[i].R2, "Simple_R2");
					me.dynamicPageFunc(myWind[i].R3, "Simple_R3");
					me.dynamicPageFunc(myWind[i].R4, "Simple_R4");
					me.dynamicPageFunc(myWind[i].R5, "Simple_R5");
					me.dynamicPageFunc(myWind[i].R6, "Simple_R6");
					
					me.colorRight(myWind[i].R1[2],myWind[i].R2[2],myWind[i].R3[2],myWind[i].R4[2],myWind[i].R5[2],myWind[i].R6[2]);
				}
				pageSwitch[i].setBoolValue(1);
			}
		} else if (page == "LATREV") {
			if (!pageSwitch[i].getBoolValue()) {
				me.defaultHideWithCenter();
				me["arrowsDepArr"].hide();
				me["Simple_PageNum"].setText("X/X");
				me["Simple_PageNum"].hide();
				me["Simple_Title"].show();
				me["ArrowLeft"].hide();
				me["ArrowRight"].hide();
				
				me["Simple_L0S"].hide();
				me["Simple_C3B"].hide();
				me["Simple_C4B"].hide();
				
				me.standardFontSize();
				
				me.colorLeftS("wht", "wht", "wht", "wht", "wht", "wht");
				me.colorLeftArrow("wht", "wht", "wht", "wht", "wht", "wht");
				me.colorRightS("wht", "wht", "wht", "wht", "wht", "wht");
				me.colorRightArrow("wht", "wht", "wht", "wht", "wht", "wht");
				
				
				if (myLatRev[i] != nil) {
					me["Simple_Title"].setText(sprintf("%s", myLatRev[i].title[0] ~ myLatRev[i].title[1] ~ myLatRev[i].title[2]));
					me["Simple_Title"].setColor(getprop("/MCDUC/colors/" ~ myLatRev[i].titleColour ~ "/r"), getprop("/MCDUC/colors/" ~ myLatRev[i].titleColour ~ "/g"), getprop("/MCDUC/colors/" ~ myLatRev[i].titleColour ~ "/b"));
					
					
					if (myLatRev[i].subtitle[0] != nil) {
						me["Simple_Center"].show();
						me["Simple_C1S"].setText(sprintf("%s", myLatRev[i].subtitle[0] ~ "/" ~ myLatRev[i].subtitle[1]));
						me["Simple_C1S"].show();
						me["Simple_C1"].hide();
						me["Simple_C2"].hide();
						me["Simple_C3"].hide();
						me["Simple_C4"].hide();
						me["Simple_C5"].hide();
						me["Simple_C6"].hide();
						me["Simple_C2S"].hide();
						me["Simple_C3S"].hide();
						me["Simple_C4S"].hide();
						me["Simple_C5S"].hide();
						me["Simple_C6S"].hide();
					} else {
						me["Simple_Center"].hide();
					}
					
					me.dynamicPageArrowFunc(myLatRev[i]);
					me.colorLeftArrow(myLatRev[i].arrowsColour[0][0],myLatRev[i].arrowsColour[0][1],myLatRev[i].arrowsColour[0][2],myLatRev[i].arrowsColour[0][3],myLatRev[i].arrowsColour[0][4],myLatRev[i].arrowsColour[0][5]);
					
					me.dynamicPageFontFunc(myLatRev[i]);
					
					me.dynamicPageFunc(myLatRev[i].L1, "Simple_L1");
					me.dynamicPageFunc(myLatRev[i].L2, "Simple_L2");
					me.dynamicPageFunc(myLatRev[i].L3, "Simple_L3");
					me.dynamicPageFunc(myLatRev[i].L4, "Simple_L4");
					me.dynamicPageFunc(myLatRev[i].L5, "Simple_L5");
					me.dynamicPageFunc(myLatRev[i].L6, "Simple_L6");
					
					me.colorLeft(myLatRev[i].L1[2],myLatRev[i].L2[2],myLatRev[i].L3[2],myLatRev[i].L4[2],myLatRev[i].L5[2],myLatRev[i].L6[2]);
						
					me.dynamicPageFunc(myLatRev[i].R1, "Simple_R1");
					me.dynamicPageFunc(myLatRev[i].R2, "Simple_R2");
					me.dynamicPageFunc(myLatRev[i].R3, "Simple_R3");
					me.dynamicPageFunc(myLatRev[i].R4, "Simple_R4");
					me.dynamicPageFunc(myLatRev[i].R5, "Simple_R5");
					me.dynamicPageFunc(myLatRev[i].R6, "Simple_R6");
					
					me.colorRight(myLatRev[i].R1[2],myLatRev[i].R2[2],myLatRev[i].R3[2],myLatRev[i].R4[2],myLatRev[i].R5[2],myLatRev[i].R6[2]);
				}
				pageSwitch[i].setBoolValue(1);
			}
		} else if (page == "VERTREV") {
			if (!pageSwitch[i].getBoolValue()) {
				me.defaultHideWithCenter();
				me["arrowsDepArr"].hide();
				me["Simple_PageNum"].setText("X/X");
				me["Simple_PageNum"].hide();
				me["Simple_Title"].show();
				me["ArrowLeft"].hide();
				me["ArrowRight"].hide();
				
				me["Simple_L0S"].hide();
				me["Simple_C3B"].hide();
				me["Simple_C4B"].hide();
				
				me.standardFontSize();
				
				me.colorLeftS("wht", "wht", "wht", "wht", "wht", "wht");
				me.colorLeftArrow("wht", "wht", "wht", "wht", "wht", "wht");
				me.colorRightS("wht", "wht", "wht", "wht", "wht", "wht");
				me.colorRightArrow("wht", "wht", "wht", "wht", "wht", "wht");
				
				
				if (myVertRev[i] != nil) {
					me["Simple_Title"].setText(sprintf("%s", myVertRev[i].title[0] ~ myVertRev[i].title[1] ~ myVertRev[i].title[2]));
					
					if (myVertRev[i].subtitle[0] != nil) {
						me["Simple_Center"].show();
						me["Simple_C1S"].setText(sprintf("%s", myVertRev[i].subtitle[0] ~ "/" ~ myVertRev[i].subtitle[1]));
						me["Simple_C1S"].show();
						me["Simple_C1"].hide();
						me["Simple_C2"].hide();
						me["Simple_C3"].hide();
						me["Simple_C4"].hide();
						me["Simple_C5"].hide();
						me["Simple_C6"].hide();
						me["Simple_C2S"].hide();
						me["Simple_C3S"].hide();
						me["Simple_C4S"].hide();
						me["Simple_C5S"].hide();
						me["Simple_C6S"].hide();
					} else {
						me["Simple_Center"].hide();
					}
					
					me.dynamicPageArrowFunc(myVertRev[i]);
					me.colorLeftArrow(myVertRev[i].arrowsColour[0][0],myVertRev[i].arrowsColour[0][1],myVertRev[i].arrowsColour[0][2],myVertRev[i].arrowsColour[0][3],myVertRev[i].arrowsColour[0][4],myVertRev[i].arrowsColour[0][5]);
					
					me.dynamicPageFontFunc(myVertRev[i]);
					
					me.dynamicPageFunc(myVertRev[i].L1, "Simple_L1");
					me.dynamicPageFunc(myVertRev[i].L2, "Simple_L2");
					me.dynamicPageFunc(myVertRev[i].L3, "Simple_L3");
					me.dynamicPageFunc(myVertRev[i].L4, "Simple_L4");
					me.dynamicPageFunc(myVertRev[i].L5, "Simple_L5");
					me.dynamicPageFunc(myVertRev[i].L6, "Simple_L6");
					
					me.colorLeft(myVertRev[i].L1[2],myVertRev[i].L2[2],myVertRev[i].L3[2],myVertRev[i].L4[2],myVertRev[i].L5[2],myVertRev[i].L6[2]);
						
					me.dynamicPageFunc(myVertRev[i].R1, "Simple_R1");
					me.dynamicPageFunc(myVertRev[i].R2, "Simple_R2");
					me.dynamicPageFunc(myVertRev[i].R3, "Simple_R3");
					me.dynamicPageFunc(myVertRev[i].R4, "Simple_R4");
					me.dynamicPageFunc(myVertRev[i].R5, "Simple_R5");
					me.dynamicPageFunc(myVertRev[i].R6, "Simple_R6");
					
					me.colorRight(myVertRev[i].R1[2],myVertRev[i].R2[2],myVertRev[i].R3[2],myVertRev[i].R4[2],myVertRev[i].R5[2],myVertRev[i].R6[2]);
				}
				pageSwitch[i].setBoolValue(1);
			}
		} else if (page == "DEPARTURE") {
			if (!pageSwitch[i].getBoolValue()) {
				me.defaultHideWithCenter();
				me["Simple_PageNum"].setText("X/X");
				me["Simple_PageNum"].hide();
				me["Simple_Title"].show();
				me["ArrowLeft"].show();
				me["ArrowRight"].show();
				me["arrowsDepArr"].show();
				me.hideAllArrowsButL6();
				
				me["Simple_L0S"].hide();
				me["Simple_C3B"].hide();
				me["Simple_C4B"].hide();
				
				me.standardFontSize();
				
				me.colorLeftS("wht", "wht", "wht", "wht", "wht", "wht");
				me.colorRightS("wht", "wht", "wht", "wht", "wht", "wht");
				
				
				if (myDeparture[i] != nil) {
					me["Simple_Title"].setText(sprintf("%s", myDeparture[i].title[0] ~ myDeparture[i].title[1] ~ myDeparture[i].title[2]));
					
					me.dynamicPageArrowFuncDepArr(myDeparture[i]);
					me.dynamicPageFontFunc(myDeparture[i]);
					
					me.dynamicPageFunc(myDeparture[i].L1, "Simple_L1");
					me.dynamicPageFunc(myDeparture[i].L2, "Simple_L2");
					me.dynamicPageFunc(myDeparture[i].L3, "Simple_L3");
					me.dynamicPageFunc(myDeparture[i].L4, "Simple_L4");
					me.dynamicPageFunc(myDeparture[i].L5, "Simple_L5");
					me.dynamicPageFunc(myDeparture[i].L6, "Simple_L6");
					
					me.colorLeft(myDeparture[i].L1[2],myDeparture[i].L2[2],myDeparture[i].L3[2],myDeparture[i].L4[2],myDeparture[i].L5[2],myDeparture[i].L6[2]);
					
					me.dynamicPageFunc(myDeparture[i].C1, "Simple_C1");
					me.dynamicPageFunc(myDeparture[i].C2, "Simple_C2");
					me.dynamicPageFunc(myDeparture[i].C3, "Simple_C3");
					me.dynamicPageFunc(myDeparture[i].C4, "Simple_C4");
					me.dynamicPageFunc(myDeparture[i].C5, "Simple_C5");
					
					me.colorCenter(myDeparture[i].C1[2],myDeparture[i].C2[2],myDeparture[i].C3[2],myDeparture[i].C4[2],myDeparture[i].C5[2],myDeparture[i].C6[2]);
					
					me["Simple_C6"].hide();
					me["Simple_C6S"].hide();
						
					me.dynamicPageFunc(myDeparture[i].R1, "Simple_R1");
					me.dynamicPageFunc(myDeparture[i].R2, "Simple_R2");
					me.dynamicPageFunc(myDeparture[i].R3, "Simple_R3");
					me.dynamicPageFunc(myDeparture[i].R4, "Simple_R4");
					me.dynamicPageFunc(myDeparture[i].R5, "Simple_R5");
					me.dynamicPageFunc(myDeparture[i].R6, "Simple_R6");
					
					me.colorRight(myDeparture[i].R1[2],myDeparture[i].R2[2],myDeparture[i].R3[2],myDeparture[i].R4[2],myDeparture[i].R5[2],myDeparture[i].R6[2]);
				}
				pageSwitch[i].setBoolValue(1);
			}
		} else if (page == "DUPLICATENAMES") {
			if (!pageSwitch[i].getBoolValue()) {
				me.defaultHideWithCenter();
				me["arrowsDepArr"].hide();
				me["Simple_PageNum"].setText("X/X");
				me["Simple_PageNum"].hide();
				me["Simple_Title"].show();
				me["ArrowLeft"].hide();
				me["ArrowRight"].hide();
				
				me["Simple_L0S"].hide();
				me["Simple_C3B"].hide();
				me["Simple_C4B"].hide();
				
				me.standardFontSize();
				
				me.colorLeftS("wht", "wht", "wht", "wht", "wht", "wht");
				me.colorLeftArrow("wht", "wht", "wht", "wht", "wht", "wht");
				me.colorRightS("wht", "wht", "wht", "wht", "wht", "wht");
				me.colorRightArrow("wht", "wht", "wht", "wht", "wht", "wht");
				
				
				if (myDuplicate[i] != nil) {
					me["Simple_Title"].setText(sprintf("%s", myDuplicate[i].title));
					
					me.dynamicPageArrowFunc(myDuplicate[i]);
					me.colorLeftArrow(myDuplicate[i].arrowsColour[0][0],myDuplicate[i].arrowsColour[0][1],myDuplicate[i].arrowsColour[0][2],myDuplicate[i].arrowsColour[0][3],myDuplicate[i].arrowsColour[0][4],myDuplicate[i].arrowsColour[0][5]);
					
					me.dynamicPageFontFunc(myDuplicate[i]);
					
					me.dynamicPageFunc(myDuplicate[i].L1, "Simple_L1");
					me.dynamicPageFunc(myDuplicate[i].L2, "Simple_L2");
					me.dynamicPageFunc(myDuplicate[i].L3, "Simple_L3");
					me.dynamicPageFunc(myDuplicate[i].L4, "Simple_L4");
					me.dynamicPageFunc(myDuplicate[i].L5, "Simple_L5");
					me.dynamicPageFunc(myDuplicate[i].L6, "Simple_L6");
					
					me.colorLeft(myDuplicate[i].L1[2],myDuplicate[i].L2[2],myDuplicate[i].L3[2],myDuplicate[i].L4[2],myDuplicate[i].L5[2],myDuplicate[i].L6[2]);
					
					me.dynamicPageFunc(myDuplicate[i].C1, "Simple_C1");
					me.dynamicPageFunc(myDuplicate[i].C2, "Simple_C2");
					me.dynamicPageFunc(myDuplicate[i].C3, "Simple_C3");
					me.dynamicPageFunc(myDuplicate[i].C4, "Simple_C4");
					me.dynamicPageFunc(myDuplicate[i].C5, "Simple_C5");
					
					me.colorCenter(myDuplicate[i].C1[2],myDuplicate[i].C2[2],myDuplicate[i].C3[2],myDuplicate[i].C4[2],myDuplicate[i].C5[2],myDuplicate[i].C6[2]);
					
					me["Simple_C6"].hide();
					me["Simple_C6S"].hide();
						
					me.dynamicPageFunc(myDuplicate[i].R1, "Simple_R1");
					me.dynamicPageFunc(myDuplicate[i].R2, "Simple_R2");
					me.dynamicPageFunc(myDuplicate[i].R3, "Simple_R3");
					me.dynamicPageFunc(myDuplicate[i].R4, "Simple_R4");
					me.dynamicPageFunc(myDuplicate[i].R5, "Simple_R5");
					me.dynamicPageFunc(myDuplicate[i].R6, "Simple_R6");
					
					me.colorRight(myDuplicate[i].R1[2],myDuplicate[i].R2[2],myDuplicate[i].R3[2],myDuplicate[i].R4[2],myDuplicate[i].R5[2],myDuplicate[i].R6[2]);
				}
				pageSwitch[i].setBoolValue(1);
			}
		} else if (page == "ARRIVAL") {
			if (!pageSwitch[i].getBoolValue()) {
				me.defaultHideWithCenter();
				me["Simple_PageNum"].setText("X/X");
				me["Simple_PageNum"].hide();
				me["Simple_Title"].show();
				me["ArrowLeft"].show();
				me["ArrowRight"].show();
				me["arrowsDepArr"].show();
				me.hideAllArrowsButL6();
				me["arrow2L"].hide();
				me["arrow2R"].hide();
				me["Simple_L0S"].hide();
				me["Simple_C3B"].hide();
				me["Simple_C4B"].hide();
				
				me.standardFontSize();
				
				me.colorLeftS("wht", "wht", "wht", "wht", "wht", "wht");
				me.colorRightS("wht", "wht", "wht", "wht", "wht", "wht");
				
				if (myArrival[i].arrowsMatrix[0][1]) {
					me["Simple_L2_Arrow"].setColor(getprop("/MCDUC/colors/" ~ myArrival[i].arrowsColour[0][1] ~ "/r"), getprop("/MCDUC/colors/" ~ myArrival[i].arrowsColour[0][1] ~ "/g"), getprop("/MCDUC/colors/" ~ myArrival[i].arrowsColour[0][1] ~ "/b"));
					me["Simple_L2_Arrow"].show();
				} else {
					me["Simple_L2_Arrow"].hide();
				}
				
				if (myArrival[i] != nil) {
					me["Simple_Title"].setText(sprintf("%s", myArrival[i].title[0] ~ myArrival[i].title[1] ~ myArrival[i].title[2]));
					
					me.dynamicPageArrowFuncDepArr(myArrival[i]);
					me.dynamicPageFontFunc(myArrival[i]);
					
					me.dynamicPageFunc(myArrival[i].L1, "Simple_L1");
					me.dynamicPageFunc(myArrival[i].L2, "Simple_L2");
					me.dynamicPageFunc(myArrival[i].L3, "Simple_L3");
					me.dynamicPageFunc(myArrival[i].L4, "Simple_L4");
					me.dynamicPageFunc(myArrival[i].L5, "Simple_L5");
					me.dynamicPageFunc(myArrival[i].L6, "Simple_L6");
					
					me.colorLeft(myArrival[i].L1[2],myArrival[i].L2[2],myArrival[i].L3[2],myArrival[i].L4[2],myArrival[i].L5[2],myArrival[i].L6[2]);
					
					me.dynamicPageFunc(myArrival[i].C1, "Simple_C1");
					me.dynamicPageFunc(myArrival[i].C2, "Simple_C2");
					me.dynamicPageFunc(myArrival[i].C3, "Simple_C3");
					me.dynamicPageFunc(myArrival[i].C4, "Simple_C4");
					me.dynamicPageFunc(myArrival[i].C5, "Simple_C5");
					
					me.colorCenter(myArrival[i].C1[2],myArrival[i].C2[2],myArrival[i].C3[2],myArrival[i].C4[2],myArrival[i].C5[2],myArrival[i].C6[2]);
					
					me["Simple_C6"].hide();
					me["Simple_C6S"].hide();
						
					me.dynamicPageFunc(myArrival[i].R1, "Simple_R1");
					me.dynamicPageFunc(myArrival[i].R2, "Simple_R2");
					me.dynamicPageFunc(myArrival[i].R3, "Simple_R3");
					me.dynamicPageFunc(myArrival[i].R4, "Simple_R4");
					me.dynamicPageFunc(myArrival[i].R5, "Simple_R5");
					me.dynamicPageFunc(myArrival[i].R6, "Simple_R6");
					
					me.colorRight(myArrival[i].R1[2],myArrival[i].R2[2],myArrival[i].R3[2],myArrival[i].R4[2],myArrival[i].R5[2],myArrival[i].R6[2]);
				}
				pageSwitch[i].setBoolValue(1);
			}
		} else if (page == "HOLD") {
			if (!pageSwitch[i].getBoolValue()) {
				me.defaultHideWithCenter();
				me["Simple_PageNum"].setText("X/X");
				me["Simple_PageNum"].hide();
				me["Simple_Title"].show();
				me["ArrowLeft"].hide();
				me["ArrowRight"].hide();
				me["arrowsDepArr"].show();
				me.hideAllArrowsButL6();
				
				me["Simple_L0S"].hide();
				me["Simple_C3B"].hide();
				me["Simple_C4B"].hide();
				
				me.fontLeft(default, default, default, default, default, default);
				me.fontLeftS(default, default, default, default, default, default);
				me.fontRight(default, default, default, default, default, default);
				me.fontRightS(default, default, default, default, default, default);
				
				me.fontSizeLeft(normal, normal, normal, normal, normal, normal);
				me.fontSizeCenter(normal, normal, normal, small, normal, normal); # if updating watch out - this is needed
				me.fontSizeRight(normal, normal, normal, normal, normal, normal);
				
				me.colorLeftS("wht", "wht", "wht", "wht", "wht", "wht");
				me.colorRightS("wht", "wht", "wht", "wht", "wht", "wht");
				
				
				if (myHold[i] != nil) {
					me["Simple_Title"].setText(sprintf("%s", myHold[i].title[0] ~ myHold[i].title[1] ~ myHold[i].title[2]));
					me["Simple_Title"].setColor(getprop("/MCDUC/colors/" ~ myHold[i].titleColour ~ "/r"), getprop("/MCDUC/colors/" ~ myHold[i].titleColour ~ "/g"), getprop("/MCDUC/colors/" ~ myHold[i].titleColour ~ "/b"));
					
					me.dynamicPageArrowFuncDepArr(myHold[i]);
					me.dynamicPageFontFunc(myHold[i]);
					
					me.dynamicPageFunc(myHold[i].L1, "Simple_L1");
					me.dynamicPageFunc(myHold[i].L2, "Simple_L2");
					me.dynamicPageFunc(myHold[i].L3, "Simple_L3");
					me.dynamicPageFunc(myHold[i].L4, "Simple_L4");
					me.dynamicPageFunc(myHold[i].L5, "Simple_L5");
					me.dynamicPageFunc(myHold[i].L6, "Simple_L6");
					
					me.colorLeft(myHold[i].L1[2],myHold[i].L2[2],myHold[i].L3[2],myHold[i].L4[2],myHold[i].L5[2],myHold[i].L6[2]);
					
					me.dynamicPageFunc(myHold[i].C1, "Simple_C1");
					me.dynamicPageFunc(myHold[i].C2, "Simple_C2");
					me.dynamicPageFunc(myHold[i].C3, "Simple_C3");
					me.dynamicPageFunc(myHold[i].C4, "Simple_C4");
					me.dynamicPageFunc(myHold[i].C5, "Simple_C5");
					
					me.colorCenter(myHold[i].C1[2],myHold[i].C2[2],myHold[i].C3[2],myHold[i].C4[2],myHold[i].C5[2],myHold[i].C6[2]);
					
					me["Simple_C6"].hide();
					me["Simple_C6S"].hide();
						
					me.dynamicPageFunc(myHold[i].R1, "Simple_R1");
					me.dynamicPageFunc(myHold[i].R2, "Simple_R2");
					me.dynamicPageFunc(myHold[i].R3, "Simple_R3");
					me.dynamicPageFunc(myHold[i].R4, "Simple_R4");
					me.dynamicPageFunc(myHold[i].R5, "Simple_R5");
					me.dynamicPageFunc(myHold[i].R6, "Simple_R6");
					
					me.colorRight(myHold[i].R1[2],myHold[i].R2[2],myHold[i].R3[2],myHold[i].R4[2],myHold[i].R5[2],myHold[i].R6[2]);
				}
				pageSwitch[i].setBoolValue(1);
			}
		} else if (page == "AIRWAYS") {
			if (!pageSwitch[i].getBoolValue()) {
				me.defaultHideWithCenter();
				me["Simple_PageNum"].setText("X/X");
				me["Simple_PageNum"].hide();
				me["Simple_Title"].show();
				me["ArrowLeft"].hide();
				me["ArrowRight"].hide();
				me["arrowsDepArr"].show();
				me.hideAllArrowsButL6();
				
				me["Simple_L0S"].hide();
				me["Simple_C3B"].hide();
				me["Simple_C4B"].hide();
				
				me.fontLeft(default, default, default, default, default, default);
				me.fontLeftS(default, default, default, default, default, default);
				me.fontRight(default, default, default, default, default, default);
				me.fontRightS(default, default, default, default, default, default);
				
				me.fontSizeLeft(normal, normal, normal, normal, normal, normal);
				me.fontSizeCenter(normal, normal, normal, small, normal, normal); # if updating watch out - this is needed
				me.fontSizeRight(normal, normal, normal, normal, normal, normal);
				
				me.colorLeftS("wht", "wht", "wht", "wht", "wht", "wht");
				me.colorRightS("wht", "wht", "wht", "wht", "wht", "wht");
				
				
				if (myAirways[i] != nil) {
					me["Simple_Title"].setText(sprintf("%s", myAirways[i].title[0] ~ myAirways[i].title[1] ~ myAirways[i].title[2]));
					me["Simple_Title"].setColor(getprop("/MCDUC/colors/" ~ myAirways[i].titleColour ~ "/r"), getprop("/MCDUC/colors/" ~ myAirways[i].titleColour ~ "/g"), getprop("/MCDUC/colors/" ~ myAirways[i].titleColour ~ "/b"));
					
					me.dynamicPageArrowFuncDepArr(myAirways[i]);
					me.dynamicPageFontFunc(myAirways[i]);
					
					me.dynamicPageFunc(myAirways[i].L1, "Simple_L1");
					me.dynamicPageFunc(myAirways[i].L2, "Simple_L2");
					me.dynamicPageFunc(myAirways[i].L3, "Simple_L3");
					me.dynamicPageFunc(myAirways[i].L4, "Simple_L4");
					me.dynamicPageFunc(myAirways[i].L5, "Simple_L5");
					me.dynamicPageFunc(myAirways[i].L6, "Simple_L6");
					
					me.colorLeft(myAirways[i].L1[2],myAirways[i].L2[2],myAirways[i].L3[2],myAirways[i].L4[2],myAirways[i].L5[2],myAirways[i].L6[2]);
					
					me.dynamicPageFunc(myAirways[i].C1, "Simple_C1");
					me.dynamicPageFunc(myAirways[i].C2, "Simple_C2");
					me.dynamicPageFunc(myAirways[i].C3, "Simple_C3");
					me.dynamicPageFunc(myAirways[i].C4, "Simple_C4");
					me.dynamicPageFunc(myAirways[i].C5, "Simple_C5");
					
					me.colorCenter(myAirways[i].C1[2],myAirways[i].C2[2],myAirways[i].C3[2],myAirways[i].C4[2],myAirways[i].C5[2],myAirways[i].C6[2]);
					
					me["Simple_C6"].hide();
					me["Simple_C6S"].hide();
						
					me.dynamicPageFunc(myAirways[i].R1, "Simple_R1");
					me.dynamicPageFunc(myAirways[i].R2, "Simple_R2");
					me.dynamicPageFunc(myAirways[i].R3, "Simple_R3");
					me.dynamicPageFunc(myAirways[i].R4, "Simple_R4");
					me.dynamicPageFunc(myAirways[i].R5, "Simple_R5");
					me.dynamicPageFunc(myAirways[i].R6, "Simple_R6");
					
					me.colorRight(myAirways[i].R1[2],myAirways[i].R2[2],myAirways[i].R3[2],myAirways[i].R4[2],myAirways[i].R5[2],myAirways[i].R6[2]);
				}
				pageSwitch[i].setBoolValue(1);
			}
		} else if (page == "CLOSESTAIRPORT") {
			if (!pageSwitch[i].getBoolValue()) {
				me.defaultHideWithCenter();
				me["Simple_PageNum"].setText("X/X");
				me["Simple_PageNum"].hide();
				me["Simple_Title"].show();
				me["ArrowLeft"].hide();
				me["ArrowRight"].hide();
				me["arrowsDepArr"].hide();
				me["Simple_L1_Arrow"].hide();
				me["Simple_L2_Arrow"].hide();
				me["Simple_L3_Arrow"].hide();
				me["Simple_L4_Arrow"].hide();
				me["Simple_L5_Arrow"].hide();
				me["Simple_L6_Arrow"].show();
				me["Simple_R1_Arrow"].hide();
				me["Simple_R2_Arrow"].hide();
				me["Simple_R3_Arrow"].hide();
				me["Simple_R4_Arrow"].hide();
				me["Simple_R5_Arrow"].hide();
				me["Simple_R6_Arrow"].show();
				
				me["Simple_L0S"].hide();
				me["Simple_C3B"].hide();
				me["Simple_C4B"].hide();
				
				me.fontLeft(default, default, default, default, default, default);
				me.fontLeftS(default, default, default, default, default, default);
				me.fontRight(default, default, default, default, default, default);
				me.fontRightS(default, default, default, default, default, default);
				
				me.fontSizeLeft(normal, normal, normal, normal, normal, normal);
				me.fontSizeCenter(normal, normal, normal, normal, normal, normal);
				me.fontSizeRight(normal, normal, normal, normal, normal, normal);
				
				me.colorLeftS("wht", "wht", "wht", "wht", "wht", "wht");
				me.colorRightS("wht", "wht", "wht", "wht", "wht", "wht");
				
				if (myClosestAirport[i] != nil) {
					me["Simple_Title"].setText(sprintf("%s", myClosestAirport[i].title));
				
					me["Simple_L6_Arrow"].setColor(getprop("/MCDUC/colors/" ~ myClosestAirport[i].arrowsColour[0][5] ~ "/r"), getprop("/MCDUC/colors/" ~ myClosestAirport[i].arrowsColour[0][5] ~ "/g"), getprop("/MCDUC/colors/" ~ myClosestAirport[i].arrowsColour[0][5] ~ "/b"));
					me["Simple_R6_Arrow"].setColor(getprop("/MCDUC/colors/" ~ myClosestAirport[i].arrowsColour[1][5] ~ "/r"), getprop("/MCDUC/colors/" ~ myClosestAirport[i].arrowsColour[1][5] ~ "/g"), getprop("/MCDUC/colors/" ~ myClosestAirport[i].arrowsColour[1][5] ~ "/b"));
					
					
					me.dynamicPageFontFunc(myClosestAirport[i]);
					
					me.dynamicPageFunc(myClosestAirport[i].L1, "Simple_L1");
					me.dynamicPageFunc(myClosestAirport[i].L2, "Simple_L2");
					me.dynamicPageFunc(myClosestAirport[i].L3, "Simple_L3");
					me.dynamicPageFunc(myClosestAirport[i].L4, "Simple_L4");
					me.dynamicPageFunc(myClosestAirport[i].L5, "Simple_L5");
					me.dynamicPageFunc(myClosestAirport[i].L6, "Simple_L6");
					
					me.colorLeft(myClosestAirport[i].L1[2],myClosestAirport[i].L2[2],myClosestAirport[i].L3[2],myClosestAirport[i].L4[2],myClosestAirport[i].L5[2],myClosestAirport[i].L6[2]);
					
					me.dynamicPageFunc(myClosestAirport[i].C1, "Simple_C1");
					me.dynamicPageFunc(myClosestAirport[i].C2, "Simple_C2");
					me.dynamicPageFunc(myClosestAirport[i].C3, "Simple_C3");
					me.dynamicPageFunc(myClosestAirport[i].C4, "Simple_C4");
					me.dynamicPageFunc(myClosestAirport[i].C5, "Simple_C5");
					
					me.colorCenter(myClosestAirport[i].C1[2],myClosestAirport[i].C2[2],myClosestAirport[i].C3[2],myClosestAirport[i].C4[2],myClosestAirport[i].C5[2],myClosestAirport[i].C6[2]);
					
					me["Simple_C6"].hide();
					me["Simple_C6S"].hide();
						
					me.dynamicPageFunc(myClosestAirport[i].R1, "Simple_R1");
					me.dynamicPageFunc(myClosestAirport[i].R2, "Simple_R2");
					me.dynamicPageFunc(myClosestAirport[i].R3, "Simple_R3");
					me.dynamicPageFunc(myClosestAirport[i].R4, "Simple_R4");
					me.dynamicPageFunc(myClosestAirport[i].R5, "Simple_R5");
					me.dynamicPageFunc(myClosestAirport[i].R6, "Simple_R6");
					
					me.colorRight(myClosestAirport[i].R1[2],myClosestAirport[i].R2[2],myClosestAirport[i].R3[2],myClosestAirport[i].R4[2],myClosestAirport[i].R5[2],myClosestAirport[i].R6[2]);
				}
				pageSwitch[i].setBoolValue(1);
			}
		} else if (page == "DIRTO") {
			if (!pageSwitch[i].getBoolValue()) {
				me["Simple"].show();
				me["Simple_Center"].hide();
				me["FPLN"].hide();
				me["DIRTO_TMPY_group"].show();
				me["INITA"].hide();
				me["IRSINIT"].hide();
				me["INITB"].hide();
				me["FUELPRED"].hide();
				me["WIND"].hide();
				me["PROG"].hide();
				me["PERFTO"].hide();
				me["arrowsDepArr"].show();
				me["PERFAPPR"].hide();
				me["PERFGA"].hide();
				me["Simple_PageNum"].setText("X/X");
				me["Simple_PageNum"].hide();
				me["Simple_Title"].show();
				me["ArrowLeft"].hide();
				me["ArrowRight"].hide();
				me.hideAllArrows();
				
				me["Simple_L0S"].hide();
				me["Simple_C3B"].hide();
				me["Simple_C4B"].hide();
				
				me.standardFontSize();
				
				me.colorLeftS("wht", "wht", "wht", "wht", "wht", "wht");
				me.colorRightS("wht", "wht", "wht", "wht", "wht", "wht");
				me.colorLeftArrow("wht", "wht", "wht", "wht", "wht", "wht");
				me.colorRightArrow("wht", "wht", "wht", "wht", "wht", "wht");
				
				if (myDirTo[i] != nil) {
					me["Simple_Title"].setText(sprintf("%s", myDirTo[i].title[0]));
					me["Simple_Title"].setColor(getprop("/MCDUC/colors/" ~ myDirTo[i].titleColour ~ "/r"), getprop("/MCDUC/colors/" ~ myDirTo[i].titleColour ~ "/g"), getprop("/MCDUC/colors/" ~ myDirTo[i].titleColour ~ "/b"));
					
					me.dynamicPageArrowFuncDepArr(myDirTo[i]);
					me.dynamicPageFontFunc(myDirTo[i]);
					
					if (fmgc.flightPlanController.temporaryFlag[i] and mcdu.dirToFlag) {
						me["DIRTO_TMPY_group"].show();
					} else {
						me["DIRTO_TMPY_group"].hide();
					}
					
					me.dynamicPageFunc(myDirTo[i].L1, "Simple_L1");
					me.dynamicPageFunc(myDirTo[i].L2, "Simple_L2");
					me.dynamicPageFunc(myDirTo[i].L3, "Simple_L3");
					me.dynamicPageFunc(myDirTo[i].L4, "Simple_L4");
					me.dynamicPageFunc(myDirTo[i].L5, "Simple_L5");
					me.dynamicPageFunc(myDirTo[i].L6, "Simple_L6");
					
					me.colorLeft(myDirTo[i].L1[2],myDirTo[i].L2[2],myDirTo[i].L3[2],myDirTo[i].L4[2],myDirTo[i].L5[2],myDirTo[i].L6[2]);
					
					me.dynamicPageFunc(myDirTo[i].R1, "Simple_R1");
					me.dynamicPageFunc(myDirTo[i].R2, "Simple_R2");
					me.dynamicPageFunc(myDirTo[i].R3, "Simple_R3");
					me.dynamicPageFunc(myDirTo[i].R4, "Simple_R4");
					me.dynamicPageFunc(myDirTo[i].R5, "Simple_R5");
					me.dynamicPageFunc(myDirTo[i].R6, "Simple_R6");
					
					me.colorRight(myDirTo[i].R1[2],myDirTo[i].R2[2],myDirTo[i].R3[2],myDirTo[i].R4[2],myDirTo[i].R5[2],myDirTo[i].R6[2]);
				}
				pageSwitch[i].setBoolValue(1);
			}
		} else {
			if (!pageSwitch[i].getBoolValue()) {
				me["Simple"].hide();
				me["FPLN"].hide();
				me["DIRTO_TMPY_group"].hide();
				me["INITA"].hide();
				me["IRSINIT"].hide();
				me["INITB"].hide();
				me["FUELPRED"].hide();
				me["WIND"].hide();
				me["PROG"].hide();
				me["PERFTO"].hide();
				me["arrowsDepArr"].hide();
				me["PERFAPPR"].hide();
				me["PERFGA"].hide();
				me["ArrowLeft"].hide();
				me["ArrowRight"].hide();
				
				pageSwitch[i].setBoolValue(1);
			}
		}
	},
	# ack = ignore, wht = white, grn = green, blu = blue, amb = amber, yel = yellow, mag = magenta
	colorLeft: func(a, b, c, d, e, f) {
		if (a != "ack") {
			me["Simple_L1"].setColor(getprop("/MCDUC/colors/" ~ a ~ "/r"), getprop("/MCDUC/colors/" ~ a ~ "/g"), getprop("/MCDUC/colors/" ~ a ~ "/b"));
		}
		if (b != "ack") {
			me["Simple_L2"].setColor(getprop("/MCDUC/colors/" ~ b ~ "/r"), getprop("/MCDUC/colors/" ~ b ~ "/g"), getprop("/MCDUC/colors/" ~ b ~ "/b"));
		}
		if (c != "ack") {
			me["Simple_L3"].setColor(getprop("/MCDUC/colors/" ~ c ~ "/r"), getprop("/MCDUC/colors/" ~ c ~ "/g"), getprop("/MCDUC/colors/" ~ c ~ "/b"));
		}
		if (d != "ack") {
			me["Simple_L4"].setColor(getprop("/MCDUC/colors/" ~ d ~ "/r"), getprop("/MCDUC/colors/" ~ d ~ "/g"), getprop("/MCDUC/colors/" ~ d ~ "/b"));
		}
		if (e != "ack") {
			me["Simple_L5"].setColor(getprop("/MCDUC/colors/" ~ e ~ "/r"), getprop("/MCDUC/colors/" ~ e ~ "/g"), getprop("/MCDUC/colors/" ~ e ~ "/b"));
		}
		if (f != "ack") {
			me["Simple_L6"].setColor(getprop("/MCDUC/colors/" ~ f ~ "/r"), getprop("/MCDUC/colors/" ~ f ~ "/g"), getprop("/MCDUC/colors/" ~ f ~ "/b"));
		}
	},
	colorLeftS: func(a, b, c, d, e, f) {
		if (a != "ack") {
			me["Simple_L1S"].setColor(getprop("/MCDUC/colors/" ~ a ~ "/r"), getprop("/MCDUC/colors/" ~ a ~ "/g"), getprop("/MCDUC/colors/" ~ a ~ "/b"));
		}
		if (b != "ack") {
			me["Simple_L2S"].setColor(getprop("/MCDUC/colors/" ~ b ~ "/r"), getprop("/MCDUC/colors/" ~ b ~ "/g"), getprop("/MCDUC/colors/" ~ b ~ "/b"));
		}
		if (c != "ack") {
			me["Simple_L3S"].setColor(getprop("/MCDUC/colors/" ~ c ~ "/r"), getprop("/MCDUC/colors/" ~ c ~ "/g"), getprop("/MCDUC/colors/" ~ c ~ "/b"));
		}
		if (d != "ack") {
			me["Simple_L4S"].setColor(getprop("/MCDUC/colors/" ~ d ~ "/r"), getprop("/MCDUC/colors/" ~ d ~ "/g"), getprop("/MCDUC/colors/" ~ d ~ "/b"));
		}
		if (e != "ack") {
			me["Simple_L5S"].setColor(getprop("/MCDUC/colors/" ~ e ~ "/r"), getprop("/MCDUC/colors/" ~ e ~ "/g"), getprop("/MCDUC/colors/" ~ e ~ "/b"));
		}
		if (f != "ack") {
			me["Simple_L6S"].setColor(getprop("/MCDUC/colors/" ~ f ~ "/r"), getprop("/MCDUC/colors/" ~ f ~ "/g"), getprop("/MCDUC/colors/" ~ f ~ "/b"));
		}
	},
	colorLeftArrow: func(a, b, c, d, e, f) {
		if (a != "ack") {
			me["Simple_L1_Arrow"].setColor(getprop("/MCDUC/colors/" ~ a ~ "/r"), getprop("/MCDUC/colors/" ~ a ~ "/g"), getprop("/MCDUC/colors/" ~ a ~ "/b"));
		}
		if (b != "ack") {
			me["Simple_L2_Arrow"].setColor(getprop("/MCDUC/colors/" ~ b ~ "/r"), getprop("/MCDUC/colors/" ~ b ~ "/g"), getprop("/MCDUC/colors/" ~ b ~ "/b"));
		}
		if (c != "ack") {
			me["Simple_L3_Arrow"].setColor(getprop("/MCDUC/colors/" ~ c ~ "/r"), getprop("/MCDUC/colors/" ~ c ~ "/g"), getprop("/MCDUC/colors/" ~ c ~ "/b"));
		}
		if (d != "ack") {
			me["Simple_L4_Arrow"].setColor(getprop("/MCDUC/colors/" ~ d ~ "/r"), getprop("/MCDUC/colors/" ~ d ~ "/g"), getprop("/MCDUC/colors/" ~ d ~ "/b"));
		}
		if (e != "ack") {
			me["Simple_L5_Arrow"].setColor(getprop("/MCDUC/colors/" ~ e ~ "/r"), getprop("/MCDUC/colors/" ~ e ~ "/g"), getprop("/MCDUC/colors/" ~ e ~ "/b"));
		}
		if (f != "ack") {
			me["Simple_L6_Arrow"].setColor(getprop("/MCDUC/colors/" ~ f ~ "/r"), getprop("/MCDUC/colors/" ~ f ~ "/g"), getprop("/MCDUC/colors/" ~ f ~ "/b"));
		}
	},
	colorRight: func(a, b, c, d, e, f) {
		if (a != "ack") {
			me["Simple_R1"].setColor(getprop("/MCDUC/colors/" ~ a ~ "/r"), getprop("/MCDUC/colors/" ~ a ~ "/g"), getprop("/MCDUC/colors/" ~ a ~ "/b"));
		}
		if (b != "ack") {
			me["Simple_R2"].setColor(getprop("/MCDUC/colors/" ~ b ~ "/r"), getprop("/MCDUC/colors/" ~ b ~ "/g"), getprop("/MCDUC/colors/" ~ b ~ "/b"));
		}
		if (c != "ack") {
			me["Simple_R3"].setColor(getprop("/MCDUC/colors/" ~ c ~ "/r"), getprop("/MCDUC/colors/" ~ c ~ "/g"), getprop("/MCDUC/colors/" ~ c ~ "/b"));
		}
		if (d != "ack") {
			me["Simple_R4"].setColor(getprop("/MCDUC/colors/" ~ d ~ "/r"), getprop("/MCDUC/colors/" ~ d ~ "/g"), getprop("/MCDUC/colors/" ~ d ~ "/b"));
		}
		if (e != "ack") {
			me["Simple_R5"].setColor(getprop("/MCDUC/colors/" ~ e ~ "/r"), getprop("/MCDUC/colors/" ~ e ~ "/g"), getprop("/MCDUC/colors/" ~ e ~ "/b"));
		}
		if (f != "ack") {
			me["Simple_R6"].setColor(getprop("/MCDUC/colors/" ~ f ~ "/r"), getprop("/MCDUC/colors/" ~ f ~ "/g"), getprop("/MCDUC/colors/" ~ f ~ "/b"));
		}
	},
	colorRightS: func(a, b, c, d, e, f) {
		if (a != "ack") {
			me["Simple_R1S"].setColor(getprop("/MCDUC/colors/" ~ a ~ "/r"), getprop("/MCDUC/colors/" ~ a ~ "/g"), getprop("/MCDUC/colors/" ~ a ~ "/b"));
		}
		if (b != "ack") {
			me["Simple_R2S"].setColor(getprop("/MCDUC/colors/" ~ b ~ "/r"), getprop("/MCDUC/colors/" ~ b ~ "/g"), getprop("/MCDUC/colors/" ~ b ~ "/b"));
		}
		if (c != "ack") {
			me["Simple_R3S"].setColor(getprop("/MCDUC/colors/" ~ c ~ "/r"), getprop("/MCDUC/colors/" ~ c ~ "/g"), getprop("/MCDUC/colors/" ~ c ~ "/b"));
		}
		if (d != "ack") {
			me["Simple_R4S"].setColor(getprop("/MCDUC/colors/" ~ d ~ "/r"), getprop("/MCDUC/colors/" ~ d ~ "/g"), getprop("/MCDUC/colors/" ~ d ~ "/b"));
		}
		if (e != "ack") {
			me["Simple_R5S"].setColor(getprop("/MCDUC/colors/" ~ e ~ "/r"), getprop("/MCDUC/colors/" ~ e ~ "/g"), getprop("/MCDUC/colors/" ~ e ~ "/b"));
		}
		if (f != "ack") {
			me["Simple_R6S"].setColor(getprop("/MCDUC/colors/" ~ f ~ "/r"), getprop("/MCDUC/colors/" ~ f ~ "/g"), getprop("/MCDUC/colors/" ~ f ~ "/b"));
		}
	},
	colorRightArrow: func(a, b, c, d, e, f) {
		if (a != "ack") {
			me["Simple_R1_Arrow"].setColor(getprop("/MCDUC/colors/" ~ a ~ "/r"), getprop("/MCDUC/colors/" ~ a ~ "/g"), getprop("/MCDUC/colors/" ~ a ~ "/b"));
		}
		if (b != "ack") {
			me["Simple_R2_Arrow"].setColor(getprop("/MCDUC/colors/" ~ b ~ "/r"), getprop("/MCDUC/colors/" ~ b ~ "/g"), getprop("/MCDUC/colors/" ~ b ~ "/b"));
		}
		if (c != "ack") {
			me["Simple_R3_Arrow"].setColor(getprop("/MCDUC/colors/" ~ c ~ "/r"), getprop("/MCDUC/colors/" ~ c ~ "/g"), getprop("/MCDUC/colors/" ~ c ~ "/b"));
		}
		if (d != "ack") {
			me["Simple_R4_Arrow"].setColor(getprop("/MCDUC/colors/" ~ d ~ "/r"), getprop("/MCDUC/colors/" ~ d ~ "/g"), getprop("/MCDUC/colors/" ~ d ~ "/b"));
		}
		if (e != "ack") {
			me["Simple_R5_Arrow"].setColor(getprop("/MCDUC/colors/" ~ e ~ "/r"), getprop("/MCDUC/colors/" ~ e ~ "/g"), getprop("/MCDUC/colors/" ~ e ~ "/b"));
		}
		if (f != "ack") {
			me["Simple_R6_Arrow"].setColor(getprop("/MCDUC/colors/" ~ f ~ "/r"), getprop("/MCDUC/colors/" ~ f ~ "/g"), getprop("/MCDUC/colors/" ~ f ~ "/b"));
		}
	},
	colorCenter: func(a, b, c, d, e, f) {
		if (a != "ack") {
			me["Simple_C1"].setColor(getprop("/MCDUC/colors/" ~ a ~ "/r"), getprop("/MCDUC/colors/" ~ a ~ "/g"), getprop("/MCDUC/colors/" ~ a ~ "/b"));
		}
		if (b != "ack") {
			me["Simple_C2"].setColor(getprop("/MCDUC/colors/" ~ b ~ "/r"), getprop("/MCDUC/colors/" ~ b ~ "/g"), getprop("/MCDUC/colors/" ~ b ~ "/b"));
		}
		if (c != "ack") {
			me["Simple_C3"].setColor(getprop("/MCDUC/colors/" ~ c ~ "/r"), getprop("/MCDUC/colors/" ~ c ~ "/g"), getprop("/MCDUC/colors/" ~ c ~ "/b"));
		}
		if (d != "ack") {
			me["Simple_C4"].setColor(getprop("/MCDUC/colors/" ~ d ~ "/r"), getprop("/MCDUC/colors/" ~ d ~ "/g"), getprop("/MCDUC/colors/" ~ d ~ "/b"));
		}
		if (e != "ack") {
			me["Simple_C5"].setColor(getprop("/MCDUC/colors/" ~ e ~ "/r"), getprop("/MCDUC/colors/" ~ e ~ "/g"), getprop("/MCDUC/colors/" ~ e ~ "/b"));
		}
		if (f != "ack") {
			me["Simple_C6"].setColor(getprop("/MCDUC/colors/" ~ f ~ "/r"), getprop("/MCDUC/colors/" ~ f ~ "/g"), getprop("/MCDUC/colors/" ~ f ~ "/b"));
		}
	},
	colorCenterS: func(a, b, c, d, e, f) {
		if (a != "ack") {
			me["Simple_C1S"].setColor(getprop("/MCDUC/colors/" ~ a ~ "/r"), getprop("/MCDUC/colors/" ~ a ~ "/g"), getprop("/MCDUC/colors/" ~ a ~ "/b"));
		}
		if (b != "ack") {
			me["Simple_C2S"].setColor(getprop("/MCDUC/colors/" ~ b ~ "/r"), getprop("/MCDUC/colors/" ~ b ~ "/g"), getprop("/MCDUC/colors/" ~ b ~ "/b"));
		}
		if (c != "ack") {
			me["Simple_C3S"].setColor(getprop("/MCDUC/colors/" ~ c ~ "/r"), getprop("/MCDUC/colors/" ~ c ~ "/g"), getprop("/MCDUC/colors/" ~ c ~ "/b"));
		}
		if (d != "ack") {
			me["Simple_C4S"].setColor(getprop("/MCDUC/colors/" ~ d ~ "/r"), getprop("/MCDUC/colors/" ~ d ~ "/g"), getprop("/MCDUC/colors/" ~ d ~ "/b"));
		}
		if (e != "ack") {
			me["Simple_C5S"].setColor(getprop("/MCDUC/colors/" ~ e ~ "/r"), getprop("/MCDUC/colors/" ~ e ~ "/g"), getprop("/MCDUC/colors/" ~ e ~ "/b"));
		}
		if (f != "ack") {
			me["Simple_C6S"].setColor(getprop("/MCDUC/colors/" ~ f ~ "/r"), getprop("/MCDUC/colors/" ~ f ~ "/g"), getprop("/MCDUC/colors/" ~ f ~ "/b"));
		}
	},
	# -1 = hide, 0 = ignore, 1 = show
	showLeft: func (a, b, c, d, e, f) {
		if (a != 0) {
			if (a >= 1) {
				me["Simple_L1"].show(); 
			} else {
				me["Simple_L1"].hide(); 
			}
		}
		if (b != 0) {
			if (b >= 1) {
				me["Simple_L2"].show(); 
			} else {
				me["Simple_L2"].hide(); 
			}
		}
		if (c != 0) {
			if (c >= 1) {
				me["Simple_L3"].show(); 
			} else {
				me["Simple_L3"].hide(); 
			}
		}
		if (d != 0) {
			if (d >= 1) {
				me["Simple_L4"].show(); 
			} else {
				me["Simple_L4"].hide(); 
			}
		}
		if (e != 0) {
			if (e >= 1) {
				me["Simple_L5"].show(); 
			} else {
				me["Simple_L5"].hide(); 
			}
		}
		if (f != 0) {
			if (f >= 1) {
				me["Simple_L6"].show(); 
			} else {
				me["Simple_L6"].hide(); 
			}
		}
	},
	showLeftS: func (a, b, c, d, e, f) {
		if (a != 0) {
			if (a >= 1) {
				me["Simple_L1S"].show(); 
			} else {
				me["Simple_L1S"].hide(); 
			}
		}
		if (b != 0) {
			if (b >= 1) {
				me["Simple_L2S"].show(); 
			} else {
				me["Simple_L2S"].hide(); 
			}
		}
		if (c != 0) {
			if (c >= 1) {
				me["Simple_L3S"].show(); 
			} else {
				me["Simple_L3S"].hide(); 
			}
		}
		if (d != 0) {
			if (d >= 1) {
				me["Simple_L4S"].show(); 
			} else {
				me["Simple_L4S"].hide(); 
			}
		}
		if (e != 0) {
			if (e >= 1) {
				me["Simple_L5S"].show(); 
			} else {
				me["Simple_L5S"].hide(); 
			}
		}
		if (f != 0) {
			if (f >= 1) {
				me["Simple_L6S"].show(); 
			} else {
				me["Simple_L6S"].hide(); 
			}
		}
	},
	showLeftArrow: func (a, b, c, d, e, f) {
		if (a != 0) {
			if (a >= 1) {
				me["Simple_L1_Arrow"].show(); 
			} else {
				me["Simple_L1_Arrow"].hide(); 
			}
		}
		if (b != 0) {
			if (b >= 1) {
				me["Simple_L2_Arrow"].show(); 
			} else {
				me["Simple_L2_Arrow"].hide(); 
			}
		}
		if (c != 0) {
			if (c >= 1) {
				me["Simple_L3_Arrow"].show(); 
			} else {
				me["Simple_L3_Arrow"].hide(); 
			}
		}
		if (d != 0) {
			if (d >= 1) {
				me["Simple_L4_Arrow"].show(); 
			} else {
				me["Simple_L4_Arrow"].hide(); 
			}
		}
		if (e != 0) {
			if (e >= 1) {
				me["Simple_L5_Arrow"].show(); 
			} else {
				me["Simple_L5_Arrow"].hide(); 
			}
		}
		if (f != 0) {
			if (f >= 1) {
				me["Simple_L6_Arrow"].show(); 
			} else {
				me["Simple_L6_Arrow"].hide(); 
			}
		}
	},
	showRight: func (a, b, c, d, e, f) {
		if (a != 0) {
			if (a >= 1) {
				me["Simple_R1"].show(); 
			} else {
				me["Simple_R1"].hide(); 
			}
		}
		if (b != 0) {
			if (b >= 1) {
				me["Simple_R2"].show(); 
			} else {
				me["Simple_R2"].hide(); 
			}
		}
		if (c != 0) {
			if (c >= 1) {
				me["Simple_R3"].show(); 
			} else {
				me["Simple_R3"].hide(); 
			}
		}
		if (d != 0) {
			if (d >= 1) {
				me["Simple_R4"].show(); 
			} else {
				me["Simple_R4"].hide(); 
			}
		}
		if (e != 0) {
			if (e >= 1) {
				me["Simple_R5"].show(); 
			} else {
				me["Simple_R5"].hide(); 
			}
		}
		if (f != 0) {
			if (f >= 1) {
				me["Simple_R6"].show(); 
			} else {
				me["Simple_R6"].hide(); 
			}
		}
	},
	showRightS: func (a, b, c, d, e, f) {
		if (a != 0) {
			if (a >= 1) {
				me["Simple_R1S"].show(); 
			} else {
				me["Simple_R1S"].hide(); 
			}
		}
		if (b != 0) {
			if (b >= 1) {
				me["Simple_R2S"].show(); 
			} else {
				me["Simple_R2S"].hide(); 
			}
		}
		if (c != 0) {
			if (c >= 1) {
				me["Simple_R3S"].show(); 
			} else {
				me["Simple_R3S"].hide(); 
			}
		}
		if (d != 0) {
			if (d >= 1) {
				me["Simple_R4S"].show(); 
			} else {
				me["Simple_R4S"].hide(); 
			}
		}
		if (e != 0) {
			if (e >= 1) {
				me["Simple_R5S"].show(); 
			} else {
				me["Simple_R5S"].hide(); 
			}
		}
		if (f != 0) {
			if (f >= 1) {
				me["Simple_R6S"].show(); 
			} else {
				me["Simple_R6S"].hide(); 
			}
		}
	},
	showRightArrow: func (a, b, c, d, e, f) {
		if (a != 0) {
			if (a >= 1) {
				me["Simple_R1_Arrow"].show(); 
			} else {
				me["Simple_R1_Arrow"].hide(); 
			}
		}
		if (b != 0) {
			if (b >= 1) {
				me["Simple_R2_Arrow"].show(); 
			} else {
				me["Simple_R2_Arrow"].hide(); 
			}
		}
		if (c != 0) {
			if (c >= 1) {
				me["Simple_R3_Arrow"].show(); 
			} else {
				me["Simple_R3_Arrow"].hide(); 
			}
		}
		if (d != 0) {
			if (d >= 1) {
				me["Simple_R4_Arrow"].show(); 
			} else {
				me["Simple_R4_Arrow"].hide(); 
			}
		}
		if (e != 0) {
			if (e >= 1) {
				me["Simple_R5_Arrow"].show(); 
			} else {
				me["Simple_R5_Arrow"].hide(); 
			}
		}
		if (f != 0) {
			if (f >= 1) {
				me["Simple_R6_Arrow"].show(); 
			} else {
				me["Simple_R6_Arrow"].hide(); 
			}
		}
	},
	showCenter: func (a, b, c, d, e, f) {
		if (a != 0) {
			if (a >= 1) {
				me["Simple_C1"].show(); 
			} else {
				me["Simple_C1"].hide(); 
			}
		}
		if (b != 0) {
			if (b >= 1) {
				me["Simple_C2"].show(); 
			} else {
				me["Simple_C2"].hide(); 
			}
		}
		if (c != 0) {
			if (c >= 1) {
				me["Simple_C3"].show(); 
			} else {
				me["Simple_C3"].hide(); 
			}
		}
		if (d != 0) {
			if (d >= 1) {
				me["Simple_C4"].show(); 
			} else {
				me["Simple_C4"].hide(); 
			}
		}
		if (e != 0) {
			if (e >= 1) {
				me["Simple_C5"].show(); 
			} else {
				me["Simple_C5"].hide(); 
			}
		}
		if (f != 0) {
			if (f >= 1) {
				me["Simple_C6"].show(); 
			} else {
				me["Simple_C6"].hide(); 
			}
		}
	},
	showCenterS: func (a, b, c, d, e, f) {
		if (a != 0) {
			if (a >= 1) {
				me["Simple_C1S"].show(); 
			} else {
				me["Simple_C1S"].hide(); 
			}
		}
		if (b != 0) {
			if (b >= 1) {
				me["Simple_C2S"].show(); 
			} else {
				me["Simple_C2S"].hide(); 
			}
		}
		if (c != 0) {
			if (c >= 1) {
				me["Simple_C3S"].show(); 
			} else {
				me["Simple_C3S"].hide(); 
			}
		}
		if (d != 0) {
			if (d >= 1) {
				me["Simple_C4S"].show(); 
			} else {
				me["Simple_C4S"].hide(); 
			}
		}
		if (e != 0) {
			if (e >= 1) {
				me["Simple_C5S"].show(); 
			} else {
				me["Simple_C5S"].hide(); 
			}
		}
		if (f != 0) {
			if (f >= 1) {
				me["Simple_C6S"].show(); 
			} else {
				me["Simple_C6S"].hide(); 
			}
		}
	},
	# 0 = ignore
	fontLeft: func (a, b, c, d, e, f) {
		if (a != 0) {
			me["Simple_L1"].setFont(a); 
		}
		if (b != 0) {
			me["Simple_L2"].setFont(b); 
		}
		if (c != 0) {
			me["Simple_L3"].setFont(c); 
		}
		if (d != 0) {
			me["Simple_L4"].setFont(d); 
		}
		if (e != 0) {
			me["Simple_L5"].setFont(e); 
		}
		if (f != 0) {
			me["Simple_L6"].setFont(f); 
		}
	},
	fontLeftS: func (a, b, c, d, e, f) {
		if (a != 0) {
			me["Simple_L1S"].setFont(a); 
		}
		if (b != 0) {
			me["Simple_L2S"].setFont(b); 
		}
		if (c != 0) {
			me["Simple_L3S"].setFont(c); 
		}
		if (d != 0) {
			me["Simple_L4S"].setFont(d); 
		}
		if (e != 0) {
			me["Simple_L5S"].setFont(e); 
		}
		if (f != 0) {
			me["Simple_L6S"].setFont(f); 
		}
	},
	fontCenter: func (a, b, c, d, e, f) {
		if (a != 0) {
			me["Simple_C1"].setFont(a); 
		}
		if (b != 0) {
			me["Simple_C2"].setFont(b); 
		}
		if (c != 0) {
			me["Simple_C3"].setFont(c); 
		}
		if (d != 0) {
			me["Simple_C4"].setFont(d); 
		}
		if (e != 0) {
			me["Simple_C5"].setFont(e); 
		}
		if (f != 0) {
			me["Simple_C6"].setFont(f); 
		}
	},
	fontCenterS: func (a, b, c, d, e, f) {
		if (a != 0) {
			me["Simple_C1S"].setFont(a); 
		}
		if (b != 0) {
			me["Simple_C2S"].setFont(b); 
		}
		if (c != 0) {
			me["Simple_C3S"].setFont(c); 
		}
		if (d != 0) {
			me["Simple_C4S"].setFont(d); 
		}
		if (e != 0) {
			me["Simple_C5S"].setFont(e); 
		}
		if (f != 0) {
			me["Simple_C6S"].setFont(f); 
		}
	},
	fontRight: func (a, b, c, d, e, f) {
		if (a != 0) {
			me["Simple_R1"].setFont(a); 
		}
		if (b != 0) {
			me["Simple_R2"].setFont(b); 
		}
		if (c != 0) {
			me["Simple_R3"].setFont(c); 
		}
		if (d != 0) {
			me["Simple_R4"].setFont(d); 
		}
		if (e != 0) {
			me["Simple_R5"].setFont(e); 
		}
		if (f != 0) {
			me["Simple_R6"].setFont(f); 
		}
	},
	fontRightS: func (a, b, c, d, e, f) {
		if (a != 0) {
			me["Simple_R1S"].setFont(a); 
		}
		if (b != 0) {
			me["Simple_R2S"].setFont(b); 
		}
		if (c != 0) {
			me["Simple_R3S"].setFont(c); 
		}
		if (d != 0) {
			me["Simple_R4S"].setFont(d); 
		}
		if (e != 0) {
			me["Simple_R5S"].setFont(e); 
		}
		if (f != 0) {
			me["Simple_R6S"].setFont(f); 
		}
	},
	fontSizeLeft: func (a, b, c, d, e, f) {
		if (a != 0) {
			me["Simple_L1"].setFontSize(a); 
		}
		if (b != 0) {
			me["Simple_L2"].setFontSize(b); 
		}
		if (c != 0) {
			me["Simple_L3"].setFontSize(c); 
		}
		if (d != 0) {
			me["Simple_L4"].setFontSize(d); 
		}
		if (e != 0) {
			me["Simple_L5"].setFontSize(e); 
		}
		if (f != 0) {
			me["Simple_L6"].setFontSize(f); 
		}
	},
	fontSizeLeftS: func (a, b, c, d, e, f) {
		if (a != 0) {
			me["Simple_L1S"].setFontSize(a); 
		}
		if (b != 0) {
			me["Simple_L2S"].setFontSize(b); 
		}
		if (c != 0) {
			me["Simple_L3S"].setFontSize(c); 
		}
		if (d != 0) {
			me["Simple_L4S"].setFontSize(d); 
		}
		if (e != 0) {
			me["Simple_L5S"].setFontSize(e); 
		}
		if (f != 0) {
			me["Simple_L6S"].setFontSize(f); 
		}
	},
	fontSizeRight: func (a, b, c, d, e, f) {
		if (a != 0) {
			me["Simple_R1"].setFontSize(a); 
		}
		if (b != 0) {
			me["Simple_R2"].setFontSize(b); 
		}
		if (c != 0) {
			me["Simple_R3"].setFontSize(c); 
		}
		if (d != 0) {
			me["Simple_R4"].setFontSize(d); 
		}
		if (e != 0) {
			me["Simple_R5"].setFontSize(e); 
		}
		if (f != 0) {
			me["Simple_R6"].setFontSize(f); 
		}
	},
	fontSizeRightS: func (a, b, c, d, e, f) {
		if (a != 0) {
			me["Simple_R1S"].setFontSize(a); 
		}
		if (b != 0) {
			me["Simple_R2S"].setFontSize(b); 
		}
		if (c != 0) {
			me["Simple_R3S"].setFontSize(c); 
		}
		if (d != 0) {
			me["Simple_R4S"].setFontSize(d); 
		}
		if (e != 0) {
			me["Simple_R5S"].setFontSize(e); 
		}
		if (f != 0) {
			me["Simple_R6S"].setFontSize(f); 
		}
	},
	fontSizeCenter: func (a, b, c, d, e, f) {
		if (a != 0) {
			me["Simple_C1"].setFontSize(a); 
		}
		if (b != 0) {
			me["Simple_C2"].setFontSize(b); 
		}
		if (c != 0) {
			me["Simple_C3"].setFontSize(c); 
		}
		if (d != 0) {
			me["Simple_C4"].setFontSize(d); 
		}
		if (e != 0) {
			me["Simple_C5"].setFontSize(e); 
		}
		if (f != 0) {
			me["Simple_C6"].setFontSize(f); 
		}
	},
	fontSizeCenterS: func (a, b, c, d, e, f) {
		if (a != 0) {
			me["Simple_C1S"].setFontSize(a); 
		}
		if (b != 0) {
			me["Simple_C2S"].setFontSize(b); 
		}
		if (c != 0) {
			me["Simple_C3S"].setFontSize(c); 
		}
		if (d != 0) {
			me["Simple_C4S"].setFontSize(d); 
		}
		if (e != 0) {
			me["Simple_C5S"].setFontSize(e); 
		}
		if (f != 0) {
			me["Simple_C6S"].setFontSize(f); 
		}
	},
	dynamicPageFunc: func (dynamic, string) {
		if (dynamic[0] == nil) {
			me[string].hide();
			me[string ~ "S"].hide();
		} else {
			me[string].show();
			me[string].setText(dynamic[0]);
			if (dynamic[1] != nil) {
				me[string ~ "S"].show();
				me[string ~ "S"].setText(dynamic[1]);
			} else {
				me[string ~ "S"].hide();
			}
		}
	},
	dynamicPageArrowFunc: func (dynamic) {
		forindex (var matrixArrow; dynamic.arrowsMatrix) {
			if (matrixArrow == 0) { 
				var sign = "L"; 
			} else { 
				var sign = "R"; 
			}
			forindex (var item; dynamic.arrowsMatrix[matrixArrow]) {
				if (dynamic.arrowsMatrix[matrixArrow][item] == 1) {
					me["Simple_" ~ sign ~ (item + 1) ~ "_Arrow"].show();
				} else {
					me["Simple_" ~ sign ~ (item + 1) ~ "_Arrow"].hide();
				}
			}
		}
	},
	dynamicPageArrowFuncDepArr: func (dynamic) {
		forindex (var matrixArrow; dynamic.arrowsMatrix) {
			if (matrixArrow == 0) { 
				var sign = "L"; 
			} else { 
				var sign = "R"; 
			}
			forindex (var item; dynamic.arrowsMatrix[matrixArrow]) {
				if (item == 5) { continue; }
				if (dynamic.arrowsMatrix[matrixArrow][item] == 1) {
					me["arrow" ~ (item + 1) ~ sign].show();
					me["arrow" ~ (item + 1) ~ sign].setColor(getprop("/MCDUC/colors/" ~ dynamic.arrowsColour[matrixArrow][item] ~ "/r"), getprop("/MCDUC/colors/" ~ dynamic.arrowsColour[matrixArrow][item] ~ "/g"), getprop("/MCDUC/colors/" ~ dynamic.arrowsColour[matrixArrow][item] ~ "/b"));
				} else {
					me["arrow" ~ (item + 1) ~ sign].hide();
				}
			}
		}
	},
	dynamicPageFontFunc: func (dynamic) {
		forindex (var matrixFont; dynamic.fontMatrix) {
			if (matrixFont == 0) { 
				var sign = "L"; 
			} else { 
				var sign = "R"; 
			}
			forindex (var item; dynamic.fontMatrix[matrixFont]) {
				if (dynamic.fontMatrix[matrixFont][item] == 1) {
					me["Simple_" ~ sign ~ (item + 1)].setFont(symbol);
					me["Simple_" ~ sign ~ (item + 1)].setFontSize(small);
				} else {
					me["Simple_" ~ sign ~ (item + 1)].setFont(default);
					me["Simple_" ~ sign ~ (item + 1)].setFontSize(normal);
				}
			}
		}
	},
	
	updateScratchpad: func(i) {
		me["Scratchpad"].setText(sprintf("%s", mcdu_scratchpad.scratchpads[i].scratchpad));
		var color_selected = mcdu_scratchpad.scratchpads[i].scratchpadColour;
		if (color_selected == "grn") {
			me["Scratchpad"].setColor(GREEN);
		} else if (color_selected == "blu") {
			me["Scratchpad"].setColor(BLUE);
		} else if (color_selected == "amb") {
			me["Scratchpad"].setColor(AMBER);
		} else if (color_selected == "yel") {
			me["Scratchpad"].setColor(YELLOW);
		} else if (color_selected == "mag") {
			me["Scratchpad"].setColor(MAGENTA);
		} else {
			me["Scratchpad"].setColor(WHITE);
		}
	},
};
		
var canvas_MCDU_1 = {
	new: func(canvas_group, file) {
		var m = {parents: [canvas_MCDU_1, canvas_MCDU_base]};
		m.init(canvas_group, file);

		return m;
	},
	update: func() {
		me.updateCommon(0);
	},
	updateScratchpadCall: func() {
		me.updateScratchpad(0);
	},
};

var canvas_MCDU_2 = {
	new: func(canvas_group, file) {
		var m = {parents: [canvas_MCDU_2, canvas_MCDU_base]};
		m.init(canvas_group, file);

		return m;
	},
	update: func() {
		me.updateCommon(1);
	},
	updateScratchpadCall: func() {
		me.updateScratchpad(1);
	},
};

setlistener("sim/signals/fdm-initialized", func {
	MCDU1_display = canvas.new({
		"name": "MCDU1",
		"size": [1024, 864],
		"view": [1024, 864],
		"mipmapping": 1
	});
	MCDU2_display = canvas.new({
		"name": "MCDU2",
		"size": [1024, 864],
		"view": [1024, 864],
		"mipmapping": 1
	});
	MCDU1_display.addPlacement({"node": "mcdu1.screen"});
	MCDU2_display.addPlacement({"node": "mcdu2.screen"});
	var group_MCDU1 = MCDU1_display.createGroup();
	var group_MCDU2 = MCDU2_display.createGroup();

	MCDU_1 = canvas_MCDU_1.new(group_MCDU1, "Aircraft/A320-family/Models/Instruments/MCDU/res/mcdu.svg");
	MCDU_2 = canvas_MCDU_2.new(group_MCDU2, "Aircraft/A320-family/Models/Instruments/MCDU/res/mcdu.svg");
	MCDU_1.updateScratchpadCall();
	MCDU_2.updateScratchpadCall();
	
	mcdu.mcdu_message(0, "SELECT DESIRED SYSTEM");
	mcdu.mcdu_message(1, "SELECT DESIRED SYSTEM");
	
	MCDU_update.start();
});

var MCDU_update = maketimer(0.125, func {
	canvas_MCDU_base.update();
});
	
var showMCDU1 = func {
	gui.showDialog("mcdu1");
}

var showMCDU2 = func {
	gui.showDialog("mcdu2");
}

setlistener("/MCDU[0]/page", func {
	pageSwitch[0].setBoolValue(0);
}, 0, 0);

setlistener("/MCDU[1]/page", func {
	pageSwitch[1].setBoolValue(0);
}, 0, 0);
