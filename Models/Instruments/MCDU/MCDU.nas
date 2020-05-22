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
var myPilotWP = [nil, nil];
var default = "BoeingCDU-Large.ttf";
var symbol = "helvetica_medium.txf";
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

#ACCONFIG
var ac1 = props.globals.getNode("/systems/electrical/bus/ac-1", 1);
var ac2 = props.globals.getNode("/systems/electrical/bus/ac-2", 1);
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
var flightNum = props.globals.getNode("/MCDUC/flight-num", 1);
var flightNumSet = props.globals.getNode("/MCDUC/flight-num-set", 1);
var depArpt = props.globals.getNode("/FMGC/internal/dep-arpt", 1);
var arrArpt = props.globals.getNode("/FMGC/internal/arr-arpt", 1);
var toFromSet = props.globals.getNode("/FMGC/internal/tofrom-set", 1);
var alt_airport = props.globals.getNode("/FMGC/internal/alt-airport", 1);
var altSet = props.globals.getNode("/FMGC/internal/alt-set", 1);
var costIndex = props.globals.getNode("/FMGC/internal/cost-index", 1);
var costIndexSet = props.globals.getNode("/FMGC/internal/cost-index-set", 1);
var cruiseFL = props.globals.getNode("/FMGC/internal/cruise-fl", 1);
var cruiseSet = props.globals.getNode("/FMGC/internal/cruise-lvl-set", 1);
var cruiseTemp = props.globals.getNode("/FMGC/internal/cruise-temp", 1);
var cruiseTempSet = props.globals.getNode("/FMGC/internal/cruise-temp-set", 1);
var tropo = props.globals.getNode("/FMGC/internal/tropo", 1);
var tropoSet = props.globals.getNode("/FMGC/internal/tropo-set", 1);
var gndtemp = props.globals.getNode("/FMGC/internal/gndtemp", 1);
var gndtempSet = props.globals.getNode("/FMGC/internal/gndtemp-set", 1);
var ADIRSMCDUBTN = props.globals.getNode("/controls/adirs/mcducbtn", 1);

# IRSINIT variables
var align_set = props.globals.getNode("/FMGC/internal/align-set", 1);

# ROUTE SELECTION
var alt_selected = props.globals.getNode("/FMGC/internal/alt-selected", 1);

# INT-B
var zfwcg = props.globals.getNode("/FMGC/internal/zfwcg", 1);
var zfwcgSet = props.globals.getNode("/FMGC/internal/zfwcg-set", 1);
var zfw = props.globals.getNode("/FMGC/internal/zfw", 1);
var zfwSet = props.globals.getNode("/FMGC/internal/zfw-set", 1);
var block = props.globals.getNode("/FMGC/internal/block", 1);
var blockSet = props.globals.getNode("/FMGC/internal/block-set", 1);
var taxi_fuel = props.globals.getNode("/FMGC/internal/taxi-fuel", 1);
var trip_fuel = props.globals.getNode("/FMGC/internal/trip-fuel", 1);
var trip_time = props.globals.getNode("/FMGC/internal/trip-time", 1);
var rte_rsv = props.globals.getNode("/FMGC/internal/rte-rsv", 1);
var rte_rsv_set = props.globals.getNode("/FMGC/internal/rte-rsv-set", 1);
var rte_percent = props.globals.getNode("/FMGC/internal/rte-percent", 1);
var rte_percent_set = props.globals.getNode("/FMGC/internal/rte-percent-set", 1);
var alt_fuel = props.globals.getNode("/FMGC/internal/alt-fuel", 1);
var alt_time = props.globals.getNode("/FMGC/internal/alt-time", 1);
var final_fuel = props.globals.getNode("/FMGC/internal/final-fuel", 1);
var final_time = props.globals.getNode("/FMGC/internal/final-time", 1);
var min_dest_fob = props.globals.getNode("/FMGC/internal/min-dest-fob", 1);
var tow = props.globals.getNode("/FMGC/internal/tow", 1);
var lw = props.globals.getNode("/FMGC/internal/lw", 1);
var trip_wind = props.globals.getNode("/FMGC/internal/trip-wind", 1);
var trip_wind_value = props.globals.getNode("/FMGC/internal/trip-wind-value", 1);
var extra_fuel = props.globals.getNode("/FMGC/internal/extra-fuel", 1);
var extra_time = props.globals.getNode("/FMGC/internal/extra-time", 1);
var taxi_fuel_set = props.globals.getNode("/FMGC/internal/taxi-fuel-set", 1);
var rte_set = props.globals.getNode("/FMGC/internal/rte-set", 1);
var alt_fuel_set = props.globals.getNode("/FMGC/internal/alt-fuel-set", 1);
var final_fuel_set = props.globals.getNode("/FMGC/internal/final-fuel-set", 1);
var final_time_set = props.globals.getNode("/FMGC/internal/final-time-set", 1);
var min_dest_fob_set = props.globals.getNode("/FMGC/internal/min-dest-fob-set", 1);

# FUELPRED
var state1 = props.globals.getNode("/engines/engine[0]/state", 1);
var state2 = props.globals.getNode("/engines/engine[1]/state", 1);
var engrdy = props.globals.getNode("/engines/ready", 1);
var pri_utc = props.globals.getNode("/FMGC/internal/pri-utc", 1);
var alt_utc = props.globals.getNode("/FMGC/internal/alt-utc", 1);
var pri_efob = props.globals.getNode("/FMGC/internal/pri-efob", 1);
var alt_efob = props.globals.getNode("/FMGC/internal/alt-efob", 1);
var fob = props.globals.getNode("/FMGC/internal/fob", 1);
var fffq_sensor = props.globals.getNode("/FMGC/internal/fffq-sensor", 1);
var gw = props.globals.getNode("/FMGC/internal/fuel-pred-gw", 1);
var cg = props.globals.getNode("/FMGC/internal/cg", 1);

# PROG
var cruiseFL_prog = props.globals.getNode("/FMGC/internal/cruise-fl-prog", 1);

# PERF
var altitude = props.globals.getNode("/instrumentation/altimeter/indicated-altitude-ft", 1);

# TO PERF
var v1 = props.globals.getNode("/FMGC/internal/v1", 1);
var v1Set = props.globals.getNode("/FMGC/internal/v1-set", 1);
var vr = props.globals.getNode("/FMGC/internal/vr", 1);
var vrSet = props.globals.getNode("/FMGC/internal/vr-set", 1);
var v2 = props.globals.getNode("/FMGC/internal/v2", 1);
var v2Set = props.globals.getNode("/FMGC/internal/v2-set", 1);

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
var dest_mag = props.globals.getNode("/FMGC/internal/dest-mag", 1);
var dest_wind = props.globals.getNode("/FMGC/internal/dest-wind", 1);
var vapp_speed_set = props.globals.getNode("/FMGC/internal/vapp-speed-set", 1);
var final = props.globals.getNode("/FMGC/internal/final", 1);
var radio = props.globals.getNode("/FMGC/internal/radio", 1);
var baro = props.globals.getNode("/FMGC/internal/baro", 1);
var radio_no = props.globals.getNode("/FMGC/internal/radio-no", 1);
var ldg_config_3_set = props.globals.getNode("/FMGC/internal/ldg-config-3-set", 1);
var ldg_config_f_set = props.globals.getNode("/FMGC/internal/ldg-config-f-set", 1);

# GA PERF

# Fetch nodes into vectors
var pageProp = [props.globals.getNode("/MCDU[0]/page", 1), props.globals.getNode("/MCDU[1]/page", 1)];
var active = [props.globals.getNode("/MCDU[0]/active", 1), props.globals.getNode("/MCDU[1]/active", 1)];
var scratchpad = [props.globals.getNode("/MCDU[0]/scratchpad", 1), props.globals.getNode("/MCDU[1]/scratchpad", 1)];

# Create Nodes:
var pageSwitch = [props.globals.initNode("/MCDU[0]/internal/switch", 0, "BOOL"), props.globals.initNode("/MCDU[1]/internal/switch", 0, "BOOL")];

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
		me["PERFTO_FE"].setColor(0.8078,0.8039,0.8078);
		me["PERFTO_SE"].setColor(0.8078,0.8039,0.8078);
		me["PERFTO_OE"].setColor(0.8078,0.8039,0.8078);
		
		me["PERFAPPR_FE"].setFont(symbol);
		me["PERFAPPR_SE"].setFont(symbol);
		me["PERFAPPR_OE"].setFont(symbol);
		me["PERFAPPR_FE"].setColor(0.8078,0.8039,0.8078);
		me["PERFAPPR_SE"].setColor(0.8078,0.8039,0.8078);
		me["PERFAPPR_OE"].setColor(0.8078,0.8039,0.8078);
		
		me["PERFGA_FE"].setFont(symbol);
		me["PERFGA_SE"].setFont(symbol);
		me["PERFGA_OE"].setFont(symbol);
		me["PERFGA_FE"].setColor(0.8078,0.8039,0.8078);
		me["PERFGA_SE"].setColor(0.8078,0.8039,0.8078);
		me["PERFGA_OE"].setColor(0.8078,0.8039,0.8078);
		
		me.page = canvas_group;
		
		return me;
	},
	getKeys: func() {
		return ["Simple","Simple_Center","Scratchpad","Simple_Title","Simple_PageNum","ArrowLeft","ArrowRight","Simple_L1","Simple_L2","Simple_L3","Simple_L4",
	"Simple_L5","Simple_L6","Simple_L0S","Simple_L1S","Simple_L2S","Simple_L3S","Simple_L4S","Simple_L5S","Simple_L6S","Simple_L1_Arrow",
	"Simple_L2_Arrow","Simple_L3_Arrow","Simple_L4_Arrow","Simple_L5_Arrow","Simple_L6_Arrow","Simple_R1","Simple_R2","Simple_R3","Simple_R4","Simple_R5",
	"Simple_R6","Simple_R1S","Simple_R2S","Simple_R3S","Simple_R4S","Simple_R5S","Simple_R6S","Simple_R1_Arrow","Simple_R2_Arrow","Simple_R3_Arrow",
	"Simple_R4_Arrow","Simple_R5_Arrow","Simple_R6_Arrow","Simple_C1","Simple_C2","Simple_C3","Simple_C3B","Simple_C4","Simple_C4B","Simple_C5","Simple_C6","Simple_C1S",
	"Simple_C2S","Simple_C3S","Simple_C4S","Simple_C5S","Simple_C6S","INITA","INITA_CoRoute","INITA_FltNbr","INITA_CostIndex","INITA_CruiseFLTemp",
	"INITA_FromTo","INITA_InitRequest","INITA_AlignIRS","INITB","INITB_ZFWCG","INITB_ZFW","INITB_ZFW_S","INITB_Block","FUELPRED","FUELPRED_ZFW",
	"FUELPRED_ZFWCG","FUELPRED_ZFW_S","PROG","PROG_UPDATE","PERFTO","PERFTO_V1","PERFTO_VR","PERFTO_V2","PERFTO_FE","PERFTO_SE","PERFTO_OE","PERFAPPR",
	"PERFAPPR_FE","PERFAPPR_SE","PERFAPPR_OE","PERFAPPR_LDG_3","PERFAPPR_LDG_F","PERFGA","PERFGA_FE","PERFGA_SE","PERFGA_OE","FPLN","FPLN_From",
	"FPLN_TMPY_group","FPLN_FROM","FPLN_Callsign","departureTMPY", "arrowsDepArr","arrow1L","arrow2L","arrow3L","arrow4L","arrow5L","arrow1R","arrow2R",
	"arrow3R","arrow4R","arrow5R","DIRTO_TMPY_group","IRSINIT","IRSINIT_1","IRSINIT_2","IRSINIT_star"];
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
	updateCommon: func(i) {
		page = pageProp[i].getValue();
		if (getprop("/MCDU[" ~ i ~ "]/scratchpad-msg") == 1) {
			color_selected = getprop("/MCDU[" ~ i ~ "]/scratchpad-color");
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
		} else {
			me["Scratchpad"].setColor(WHITE);
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
				
				if (flightNumSet.getValue()) {
					me["FPLN_Callsign"].setText(flightNum.getValue());
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
						me["FPLN_TMPY_groupS"].show();
						me["DIRTO_TMPY_groupS"].hide();
					} else {
						me["DIRTO_TMPY_groupS"].show();
						me["FPLN_TMPY_groupS"].hide();
					}
				} else {
					me["FPLN_TMPY_groupS"].hide();
					me["DIRTO_TMPY_groupS"].hide();
					me.dynamicPageFunc(myFpln[i].L6, "Simple_L6");
					me.dynamicPageFunc(myFpln[i].C6, "Simple_C6");
					me.dynamicPageFunc(myFpln[i].R6, "Simple_R6");
				}
			}
		} else if (page == "MCDU") {
			if (!pageSwitch[i].getBoolValue()) {
				me["SimpleS"].show();
				me["Simple_CenterS"].hide();
				me["FPLNS"].hide();
				me["DIRTO_TMPY_groupS"].hide();
				me["INITAS"].hide();
				me["IRSINITS"].hide();
				me["INITBS"].hide();
				me["FUELPREDS"].hide();
				me["PROGS"].hide();
				me["PERFTOS"].hide();
				me["arrowsDepArrS"].hide();
				me["PERFAPPRS"].hide();
				me["PERFGAS"].hide();
				me["Simple_TitleS"].show();
				me["Simple_TitleS"].setText("MCDU MENU");
				me["Simple_TitleS"].setColor(1, 1, 1);
				me["Simple_PageNumS"].setText("X/X");
				me["Simple_PageNumS"].hide();
				me["ArrowLeftS"].hide();
				me["ArrowRightS"].hide();
				
				me.showLeft(1, 1, 1, 1, -1, -1);
				me["Simple_L0SS"].hide();
				me.showLeftS(-1, -1, -1, -1, -1, -1);
				me.showLeftArrow(1, 1, 1, 1, -1, -1);
				me.showRight(-1, -1, -1, -1, -1, 1);
				me.showRightS(-1, -1, -1, -1, -1, -1);
				me.showRightArrow(-1, -1, -1, -1, -1, 1);
				me["Simple_C3BS"].hide();
				me["Simple_C4BS"].hide();
				
				me.fontLeft(default, default, default, default, default, default);
				me.fontLeftS(default, default, default, default, default, default);
				me.fontRight(default, default, default, default, default, default);
				me.fontRightS(default, default, default, default, default, default);
				
				me.fontSizeLeft(normal, normal, normal, normal, normal, normal);
				me.fontSizeRight(normal, normal, normal, normal, normal, normal);
				
				me.colorLeft("ack", "wht", "wht", "wht", "wht", "wht");
				me.colorLeftS("wht", "wht", "wht", "wht", "wht", "wht");
				me.colorLeftArrow("wht", "wht", "wht", "wht", "wht", "wht");
				me.colorRight("wht", "wht", "wht", "wht", "wht", "wht");
				me.colorRightS("wht", "wht", "wht", "wht", "wht", "wht");
				me.colorRightArrow("wht", "wht", "wht", "wht", "wht", "wht");
				
				pageSwitch[i].setBoolValue(1);
			}
			
			if (active[i].getValue() == 0) {
				me["Simple_L1S"].setText(" FMGC");
				me["Simple_L1S"].setColor(1,1,1);
			} else if (active[i].getValue() == 1) {
				me["Simple_L1S"].setText(" FMGC(SEL)");
				me["Simple_L1S"].setColor(0.0901,0.6039,0.7176);
			} else if (active[i].getValue() == 2) {
				me["Simple_L1S"].setText(" FMGC");
				me["Simple_L1S"].setColor(0.0509,0.7529,0.2941);
			}
			me["Simple_L2S"].setText(" ACARS");
			me["Simple_L3S"].setText(" AIDS");
			me["Simple_L4S"].setText(" CFDS");
			me["Simple_R6S"].setText("RETURN ");
		} else if (page == "STATUS") {
			if (!pageSwitch[i].getBoolValue()) {
				me["SimpleS"].show();
				me["Simple_CenterS"].hide();
				me["FPLNS"].hide();
				me["DIRTO_TMPY_groupS"].hide();
				me["INITAS"].hide();
				me["IRSINITS"].hide();
				me["INITBS"].hide();
				me["FUELPREDS"].hide();
				me["PROGS"].hide();
				me["PERFTOS"].hide();
				me["arrowsDepArrS"].show();
				me["arrow1LS"].hide();
				me["arrow2LS"].hide();
				me["arrow3LS"].hide();
				me["arrow4LS"].hide();
				me["arrow5LS"].hide();
				me["arrow1RS"].hide();
				me["arrow2RS"].hide();
				me["arrow3RS"].hide();
				me["arrow4RS"].hide();
				me["arrow5RS"].show();
				me["arrow5RS"].setColor(getprop("/MCDUC/colors/blu/r"),getprop("/MCDUC/colors/blu/g"),getprop("/MCDUC/colors/blu/b"));
				me["PERFAPPRS"].hide();
				me["PERFGAS"].hide();
				me["Simple_TitleS"].show();
				me["Simple_TitleS"].setText(sprintf("%s", "    " ~ acType.getValue()));
				me["Simple_TitleS"].setColor(1, 1, 1);
				me["Simple_PageNumS"].setText("X/X");
				me["Simple_PageNumS"].hide();
				me["ArrowLeftS"].hide();
				me["ArrowRightS"].hide();
				
				me.showLeft(1, 1, 1, -1, 1, 1);
				me["Simple_L0SS"].hide();
				me.showLeftS(1, 1, 1, -1, 1, 1);
				me.showLeftArrow(-1, -1, 1, -1, -1, -1);
				me.showRight(-1, 1, -1, 1, 1, 1);
				me.showRightS(-1, -1, -1, 1, 1, 1);
				me.showRightArrow(-1, -1, -1, -1, -1, 1);
				me["Simple_C3BS"].hide();
				me["Simple_C4BS"].hide();
				
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
				
				
				me["Simple_L5S"].setText("[   ]");
				me["Simple_L6S"].setText("+4.0/+0.0");
				me["Simple_L1SS"].setText(" ENG");
				me["Simple_L2SS"].setText(" ACTIVE NAV DATA BASE");
				me["Simple_L3SS"].setText(" SECOND NAV DATA BASE");
				me["Simple_L5SS"].setText("CHG CODE");
				me["Simple_L6SS"].setText("IDLE/PERF");
				me["Simple_R6S"].setText("STATUS/XLOAD ");
				me["Simple_R6SS"].setText("SOFTWARE ");
				me["Simple_R4SS"].setText("PILOT STORED  ");
				me["Simple_R4S"].setText("00RTES 00RWYS ");
			
				pageSwitch[i].setBoolValue(1);
			}
			
			me["Simple_L1S"].setText(sprintf("%s", engType.getValue()));
			me["Simple_L2S"].setText(sprintf("%s", " " ~ database1.getValue()));
			me["Simple_L3S"].setText(sprintf("%s", " " ~ database2.getValue()));
			me["Simple_R2S"].setText(sprintf("%s", databaseCode.getValue() ~ " "));
			
			if (fmgc.WaypointDatabase.getCount() >= 1) {
				me["Simple_R4S"].show();
				me["Simple_R5S"].show();
				me["Simple_R4SS"].show();
				me["Simple_R5SS"].show();
				me["arrow5RS"].show();
				me["Simple_R5SS"].setText(sprintf("%02.0f", fmgc.WaypointDatabase.getCount()) ~ "WPTS 00NAVS ");
			} else {
				me["Simple_R4S"].hide();
				me["Simple_R5S"].hide();
				me["Simple_R4SS"].hide();
				me["Simple_R5SS"].hide();
				me["arrow5RS"].hide();
			}
			
			if (fmgc.WaypointDatabase.confirm[i]) {
				me["Simple_R5S"].setText("CONFIRM DELETE ALL ");
				me["Simple_R5S"].setColor(getprop("/MCDUC/colors/amb/r"),getprop("/MCDUC/colors/amb/g"),getprop("/MCDUC/colors/amb/b"));
				me["arrow5RS"].setColor(getprop("/MCDUC/colors/amb/r"),getprop("/MCDUC/colors/amb/g"),getprop("/MCDUC/colors/amb/b"));
			} else {
				me["Simple_R5S"].setText("DELETE ALL ");
				me["Simple_R5S"].setColor(getprop("/MCDUC/colors/blu/r"),getprop("/MCDUC/colors/blu/g"),getprop("/MCDUC/colors/blu/b"));
				me["arrow5RS"].setColor(getprop("/MCDUC/colors/blu/r"),getprop("/MCDUC/colors/blu/g"),getprop("/MCDUC/colors/blu/b"));
			}
			
			if (getprop("/FMGC/status/phase") == 0 or getprop("/FMGC/status/phase") == 7) {
				me["Simple_L5S"].show();
				me["Simple_L5SS"].show();
			} else {
				me["Simple_L5S"].hide();
				me["Simple_L5SS"].hide();
			}
		} else if (page == "DATA") {
			if (!pageSwitch[i].getBoolValue()) {
				me["SimpleS"].show();
				me["Simple_CenterS"].hide();
				me["FPLNS"].hide();
				me["DIRTO_TMPY_groupS"].hide();
				me["INITAS"].hide();
				me["IRSINITS"].hide();
				me["INITBS"].hide();
				me["FUELPREDS"].hide();
				me["PROGS"].hide();
				me["PERFTOS"].hide();
				me["arrowsDepArrS"].hide();
				me["PERFAPPRS"].hide();
				me["PERFGAS"].hide();
				me["Simple_TitleS"].show();
				me["Simple_TitleS"].setText("DATA INDEX");
				me["Simple_TitleS"].setColor(1, 1, 1);
				me["Simple_PageNumS"].setText("1/2");
				me["Simple_PageNumS"].show();
				me["ArrowLeftS"].show();
				me["ArrowRightS"].show();
				
				me.showLeft(1, 1, 1, 1, -1, -1);
				me["Simple_L0SS"].hide();
				me.showLeftS(1, 1, 1, -1, 1, -1);
				me.showLeftArrow(1, 1, 1, 1, 1, -1);
				me.showRight(-1, -1, -1, -1, 1, 1);
				me.showRightS(-1, -1, -1, -1, 1, 1);
				me.showRightArrow(-1, -1, -1, -1, 1, 1);
				me["Simple_C3BS"].hide();
				me["Simple_C4BS"].hide();
				
				me.fontLeft(default, default, default, default, default, default);
				me.fontLeftS(default, default, default, default, default, default);
				me.fontRight(default, default, default, default, default, default);
				me.fontRightS(default, default, default, default, default, default);
				
				me.fontSizeLeft(normal, normal, normal, normal, normal, normal);
				me.fontSizeRight(normal, normal, normal, normal, normal, normal);
				
				me.colorLeft("wht", "wht", "wht", "wht", "wht", "wht");
				me.colorLeftS("wht", "wht", "wht", "wht", "wht", "wht");
				me.colorLeftArrow("wht", "wht", "wht", "wht", "wht", "wht");
				me.colorRight("wht", "wht", "wht", "wht", "wht", "wht");
				me.colorRightS("wht", "wht", "wht", "wht", "wht", "wht");
				me.colorRightArrow("wht", "wht", "wht", "wht", "wht", "wht");
				
				# why is this needed?
				me["Simple_L5S"].show();
				
				me["Simple_L1S"].setText(" MONITOR");
				me["Simple_L2S"].setText(" MONITOR");
				me["Simple_L3S"].setText(" MONITOR");
				me["Simple_L4S"].setText(" A/C STATUS");
				me["Simple_L5S"].setText(" AIRPORTS");
				me["Simple_L1SS"].setText(" POSITION");
				me["Simple_L2SS"].setText(" IRS");
				me["Simple_L3SS"].setText(" GPS");
				me["Simple_L5SS"].setText(" CLOSEST");
				me["Simple_R5S"].setText("FUNCTION ");
				me["Simple_R6S"].setText("FUNCTION ");
				me["Simple_R5SS"].setText("PRINT ");
				me["Simple_R6SS"].setText("AOC ");
				pageSwitch[i].setBoolValue(1);
			}
		} else if (page == "DATA2") {
			if (!pageSwitch[i].getBoolValue()) {
				me["SimpleS"].show();
				me["Simple_CenterS"].hide();
				me["FPLNS"].hide();
				me["DIRTO_TMPY_groupS"].hide();
				me["INITAS"].hide();
				me["IRSINITS"].hide();
				me["INITBS"].hide();
				me["FUELPREDS"].hide();
				me["PROGS"].hide();
				me["PERFTOS"].hide();
				me["arrowsDepArrS"].hide();
				me["PERFAPPRS"].hide();
				me["PERFGAS"].hide();
				me["Simple_TitleS"].show();
				me["Simple_TitleS"].setText("DATA INDEX");
				me["Simple_TitleS"].setColor(1, 1, 1);
				me["Simple_PageNumS"].setText("2/2");
				me["Simple_PageNumS"].show();
				me["ArrowLeftS"].show();
				me["ArrowRightS"].show();
				
				me.showLeft(1, 1, 1, 1, 1, 1);
				me["Simple_L0SS"].hide();
				me.showLeftS(-1, -1, -1, -1, 1, 1);
				me.showLeftArrow(1, 1, 1, 1, 1, 1);
				me.showRight(1, 1, 1, 1, -1, -1);
				me.showRightS(1, 1, 1, 1, -1, -1);
				me.showRightArrow(1, 1, 1, 1, -1, -1);
				me["Simple_C3BS"].hide();
				me["Simple_C4BS"].hide();
				
				me.fontLeft(default, default, default, default, default, default);
				me.fontLeftS(default, default, default, default, default, default);
				me.fontRight(default, default, default, default, default, default);
				me.fontRightS(default, default, default, default, default, default);
				
				me.fontSizeLeft(normal, normal, normal, normal, normal, normal);
				me.fontSizeRight(normal, normal, normal, normal, normal, normal);
				
				me.colorLeft("wht", "wht", "wht", "wht", "wht", "wht");
				me.colorLeftS("wht", "wht", "wht", "wht", "wht", "wht");
				me.colorLeftArrow("wht", "wht", "wht", "wht", "wht", "wht");
				me.colorRight("wht", "wht", "wht", "wht", "wht", "wht");
				me.colorRightS("wht", "wht", "wht", "wht", "wht", "wht");
				me.colorRightArrow("wht", "wht", "wht", "wht", "wht", "wht");
				
				pageSwitch[i].setBoolValue(1);
			}
			
			me["Simple_L1S"].setText(" WAYPOINTS");
			me["Simple_L2S"].setText(" NAVAIDS");
			me["Simple_L3S"].setText(" RUNWAYS");
			me["Simple_L4S"].setText(" ROUTES");
			me["Simple_L5S"].setText(" WINDS");
			me["Simple_L6S"].setText(" WINDS");
			me["Simple_L5SS"].setText(" ACTIVE F-PLN");
			me["Simple_L6SS"].setText(" SEC F-PLN");
			me["Simple_R1S"].setText("WAYPOINTS ");
			me["Simple_R2S"].setText("NAVAIDS ");
			me["Simple_R3S"].setText("RUNWAYS ");
			me["Simple_R4S"].setText("ROUTES ");
			me["Simple_R1SS"].setText("PILOTS ");
			me["Simple_R2SS"].setText("PILOTS ");
			me["Simple_R3SS"].setText("PILOTS ");
			me["Simple_R4SS"].setText("PILOTS ");
		} else if (page == "PILOTWP") {
			if (!pageSwitch[i].getBoolValue()) {
				me["SimpleS"].show();
				me["Simple_CenterS"].hide();
				me["FPLNS"].hide();
				me["DIRTO_TMPY_groupS"].hide();
				me["INITAS"].hide();
				me["IRSINITS"].hide();
				me["INITBS"].hide();
				me["FUELPREDS"].hide();
				me["PROGS"].hide();
				me["PERFTOS"].hide();
				me["arrowsDepArrS"].hide();
				me["PERFAPPRS"].hide();
				me["PERFGAS"].hide();
				me["Simple_TitleS"].show();
				me["Simple_PageNumS"].show();
				me["ArrowLeftS"].show();
				me["ArrowRightS"].show();
				
				me["Simple_L0SS"].hide();
				me["Simple_C3BS"].hide();
				me["Simple_C4BS"].hide();
				
				me.fontLeft(default, default, default, default, default, default);
				me.fontLeftS(default, default, default, default, default, default);
				me.fontRight(default, default, default, default, default, default);
				me.fontRightS(default, default, default, default, default, default);
				
				me.fontSizeLeft(normal, normal, normal, normal, normal, normal);
				me.fontSizeRight(normal, normal, normal, normal, normal, normal);
				
				me.colorLeftS("wht", "wht", "wht", "wht", "wht", "wht");
				me.colorRightS("wht", "wht", "wht", "wht", "wht", "wht");
				
				
				if (myPilotWP[i] != nil) {
					me["Simple_PageNumS"].setText(fmgc.WaypointDatabase.getNoOfIndex(myPilotWP[i].scroll) ~ "/" ~ (fmgc.WaypointDatabase.getCount()));
					
					me["Simple_TitleS"].setText(sprintf("%s", myPilotWP[i].title ~ "       "));
					
					forindex (var matrixArrow; myPilotWP[i].arrowsMatrix) {
						if (matrixArrow == 0) { 
							var sign = "L"; 
						} else { 
							var sign = "R"; 
						}
						forindex (var item; myPilotWP[i].arrowsMatrix[matrixArrow]) {
							if (myPilotWP[i].arrowsMatrix[matrixArrow][item] == 1) {
								me["Simple_" ~ sign ~ (item + 1) ~ "_ArrowS"].show();
							} else {
								me["Simple_" ~ sign ~ (item + 1) ~ "_ArrowS"].hide();
							}
						}
					}
					me.colorLeftArrow(myPilotWP[i].arrowsColour[0][0],myPilotWP[i].arrowsColour[0][1],myPilotWP[i].arrowsColour[0][2],myPilotWP[i].arrowsColour[0][3],myPilotWP[i].arrowsColour[0][4],myPilotWP[i].arrowsColour[0][5]);
					me.colorRightArrow(myPilotWP[i].arrowsColour[1][0],myPilotWP[i].arrowsColour[1][1],myPilotWP[i].arrowsColour[1][2],myPilotWP[i].arrowsColour[1][3],myPilotWP[i].arrowsColour[1][4],myPilotWP[i].arrowsColour[1][5]);
					
					
					forindex (var matrixFont; myPilotWP[i].fontMatrix) {
						if (matrixFont == 0) { 
							var sign = "L"; 
						} else { 
							var sign = "R"; 
						}
						forindex (var item; myPilotWP[i].fontMatrix[matrixFont]) {
							if (myPilotWP[i].fontMatrix[matrixFont][item] == 1) {
								me["Simple_" ~ sign ~ (item + 1)].setFont(symbol);
								me["Simple_" ~ sign ~ (item + 1)].setFontSize(small);
							} else {
								me["Simple_" ~ sign ~ (item + 1)].setFont(default);
								me["Simple_" ~ sign ~ (item + 1)].setFontSize(normal);
							}
						}
					}
					
					
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
				me["SimpleS"].show();
				me["Simple_CenterS"].show();
				me["FPLNS"].hide();
				me["DIRTO_TMPY_groupS"].hide();
				me["INITAS"].hide();
				me["IRSINITS"].hide();
				me["INITBS"].hide();
				me["FUELPREDS"].hide();
				me["PROGS"].hide();
				me["PERFTOS"].hide();
				me["arrowsDepArrS"].hide();
				me["PERFAPPRS"].hide();
				me["PERFGAS"].hide();
				me["Simple_TitleS"].show();
				me["Simple_TitleS"].setText("POSITION MONITOR");
				me["Simple_TitleS"].setColor(1, 1, 1);
				me["Simple_PageNumS"].setText("X/X");
				me["Simple_PageNumS"].hide();
				me["ArrowLeftS"].hide();
				me["ArrowRightS"].hide();
				
				me.showLeft(1, 1, 1, 1, 1, 1);
				me["Simple_L0SS"].hide();
				me.showLeftS(-1, -1, -1, -1, 1, -1);
				me.showLeftArrow(-1, -1, -1, -1, -1, 1);
				me.showCenter(-1, -1, -1, -1, 1, -1);
				me["Simple_C3BS"].hide();
				me["Simple_C4BS"].hide();
				me.showCenterS(-1, -1, -1, -1, 1, -1);
				me.showRight(1, 1, 1, 1, 1, 1);
				me.showRightS(-1, -1, -1, -1, 1, 1);
				me.showRightArrow(-1, -1, -1, -1, -1, 1);
				
				me.fontLeft(default, default, default, default, default, default);
				me.fontLeftS(default, default, default, default, default, default);
				me.fontRight(default, default, default, default, default, default);
				me.fontRightS(default, default, default, default, default, default);
				
				me.fontSizeLeft(normal, normal, normal, normal, normal, normal);
				me.fontSizeRight(normal, normal, normal, normal, normal, normal);
				
				me.colorLeft("wht", "wht", "wht", "wht", "grn", "blu");
				me.colorLeftS("wht", "wht", "wht", "wht", "wht", "wht");
				me.colorLeftArrow("wht", "wht", "wht", "wht", "wht", "blu");
				me.colorRight("grn", "grn", "grn", "grn", "grn", "wht");
				me.colorRightS("wht", "wht", "wht", "wht", "wht", "wht");
				me.colorRightArrow("wht", "wht", "wht", "wht", "wht", "wht");
				
				pageSwitch[i].setBoolValue(1);
			}
			
			me["Simple_L1S"].setText("FMGC1");
			me["Simple_L2S"].setText("FMGC2");
			me["Simple_L3S"].setText("GPIRS");
			me["Simple_L4S"].setText("MIX IRS");
			me["Simple_L5S"].setText("NAV -.-");
			me["Simple_L6S"].setText(" FREEZE");
			me["Simple_L5SS"].setText("   IRS1");
			me["Simple_R1S"].setText("----.-X/-----.-X");
			me["Simple_R2S"].setText("----.-X/-----.-X");
			me["Simple_R3S"].setText("----.-X/-----.-X");
			me["Simple_R4S"].setText("----.-X/-----.-X");
			me["Simple_R5S"].setText("NAV -.-");
			me["Simple_R5SS"].setText("IRS3	 ");
			me["Simple_R6SS"].setText("SEL ");
			me["Simple_C5S"].setText("NAV -.-");
			me["Simple_C5SS"].setText("IRS2");
		} else if (page == "RADNAV") {
			if (!pageSwitch[i].getBoolValue()) {
				me["SimpleS"].show();
				me["Simple_CenterS"].hide();
				me["FPLNS"].hide();
				me["DIRTO_TMPY_groupS"].hide();
				me["INITAS"].hide();
				me["IRSINITS"].hide();
				me["INITBS"].hide();
				me["FUELPREDS"].hide();
				me["PROGS"].hide();
				me["PERFTOS"].hide();
				me["arrowsDepArrS"].hide();
				me["PERFAPPRS"].hide();
				me["PERFGAS"].hide();
				me["Simple_TitleS"].show();
				me["Simple_TitleS"].setText("RADIO NAV");
				me["Simple_TitleS"].setColor(1, 1, 1);
				me["Simple_PageNumS"].setText("X/X");
				me["Simple_PageNumS"].hide();
				me["ArrowLeftS"].hide();
				me["ArrowRightS"].hide();
				
				me.showLeft(1, 1, 1, 1, 1, -1);
				me["Simple_L0SS"].hide();
				me.showLeftS(1, 1, 1, 1, 1, -1);
				me.showLeftArrow(-1, -1, -1, -1, -1, -1);
				me.showRight(1, 1, 1, 1, 1, -1);
				me.showRightS(1, 1, 1, 1, 1, -1);
				me.showRightArrow(-1, -1, -1, -1, -1, -1);
				me["Simple_C3BS"].hide();
				me["Simple_C4BS"].hide();
				
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
				me["Simple_L1S"].setFontSize(normal); 
			} else {
				me["Simple_L1S"].setFontSize(small); 
			}
			if (vor1CRSSet.getValue() == 1) {
				me["Simple_L2S"].setFontSize(normal); 
			} else {
				me["Simple_L2S"].setFontSize(small); 
			}
			if (ils1FreqSet.getValue() == 1) {
				me["Simple_L3S"].setFontSize(normal); 
			} else {
				me["Simple_L3S"].setFontSize(small); 
			}
			if (ils1CRSSet.getValue() == 1) {
				me["Simple_L4S"].setFontSize(normal); 
			} else {
				me["Simple_L4S"].setFontSize(small); 
			}
			if (adf1FreqSet.getValue() == 1) {
				me["Simple_L5S"].setFont(default); 
				me["Simple_L5S"].setFontSize(normal); 
				me["Simple_L5S"].setText(sprintf("%s", adf1.getValue()));
			} else {
				me["Simple_L5S"].setFont(symbol); 
				me["Simple_L5S"].setFontSize(small); 
				me["Simple_L5S"].setText("[    ]/[     . ]");
			}
			
			if (vor2FreqSet.getValue() == 1) {
				me["Simple_R1S"].setFontSize(normal); 
			} else {
				me["Simple_R1S"].setFontSize(small); 
			}
			if (vor2CRSSet.getValue() == 1) {
				me["Simple_R2S"].setFontSize(normal); 
			} else {
				me["Simple_R2S"].setFontSize(small); 
			}
			if (adf2FreqSet.getValue() == 1) {
				me["Simple_R5S"].setFont(default); 
				me["Simple_R5S"].setFontSize(normal); 
				me["Simple_R5S"].setText(sprintf("%s", adf2.getValue()));
			} else {
				me["Simple_R5S"].setFont(symbol); 
				me["Simple_R5S"].setFontSize(small); 
				me["Simple_R5S"].setText("[     . ]/[    ]");
			}
			
			me["Simple_L1S"].setText(" " ~ vor1.getValue());
			me["Simple_L2S"].setText(sprintf("%3.0f", vor1CRS.getValue()));
			me["Simple_L3S"].setText(" " ~ ils1.getValue());
			me["Simple_L4S"].setText(sprintf("%3.0f", ils1CRS.getValue()));
			me["Simple_L1SS"].setText("VOR1/FREQ");
			me["Simple_L2SS"].setText("CRS");
			me["Simple_L3SS"].setText("ILS /FREQ");
			me["Simple_L4SS"].setText("CRS");
			me["Simple_L5SS"].setText("ADF1/FREQ");
			me["Simple_R1S"].setText(" " ~ vor2.getValue());
			me["Simple_R2S"].setText(sprintf("%3.0f", vor2CRS.getValue()));
			me["Simple_R3S"].setText("[   ]/[    ]");
			me["Simple_R4S"].setText("-.-   [   ]");
			me["Simple_R1SS"].setText("FREQ/VOR2");
			me["Simple_R2SS"].setText("CRS");
			me["Simple_R3SS"].setText("CHAN/ MLS");
			me["Simple_R4SS"].setText("SLOPE   CRS");
			me["Simple_R5SS"].setText("FREQ/ADF2");
		} else if (page == "INITA") {
			if (!pageSwitch[i].getBoolValue()) {
				me["SimpleS"].show();
				me["Simple_CenterS"].hide();
				me["FPLNS"].hide();
				me["DIRTO_TMPY_groupS"].hide();
				me["INITAS"].show();
				me["IRSINITS"].hide();
				me["INITBS"].hide();
				me["FUELPREDS"].hide();
				me["PROGS"].hide();
				me["PERFTOS"].hide();
				me["arrowsDepArrS"].hide();
				me["PERFAPPRS"].hide();
				me["PERFGAS"].hide();
				me["Simple_TitleS"].show();
				me["Simple_TitleS"].setText("INIT");
				me["Simple_TitleS"].setColor(1, 1, 1);
				me["Simple_PageNumS"].setText("X/X");
				me["Simple_PageNumS"].hide();
				me["ArrowLeftS"].show();
				me["ArrowRightS"].show();
				
				me.showLeft(0, 1, 0, -1, 0, 1);
				me["Simple_L0SS"].hide();
				me.showLeftS(1, 1, 1, -1, 1, 1);
				me.showLeftArrow(-1, -1, -1, -1, -1, -1);
				me.showRight(0, 0, 1, 1, 1, 1);
				me.showRightS(1, 0, -1, -1, 1, 1);
				me.showRightArrow(-1, -1, -1, 1, -1, -1);
				me["Simple_C3BS"].hide();
				me["Simple_C4BS"].hide();
				
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
			
			if (flightNumSet.getValue() == 1) {
				me["INITA_FltNbrS"].hide();
				me["Simple_L3S"].show();
			} else {
				me["INITA_FltNbrS"].show();
				me["Simple_L3S"].hide();
			}
			if (toFromSet.getValue() != 1 and costIndexSet.getValue() != 1) {
				me["INITA_CostIndexS"].hide();
				me["Simple_L5S"].setColor(1,1,1);
				me["Simple_L5S"].show();
				me["Simple_L5S"].setText("---");
			} else if (costIndexSet.getValue() == 1) {
				me["INITA_CostIndexS"].hide();
				me["Simple_L5S"].setColor(0.0901,0.6039,0.7176);
				me["Simple_L5S"].show();
				me["Simple_L5S"].setText(sprintf("%s", costIndex.getValue()));
			} else {
				me["INITA_CostIndexS"].show();
				me["Simple_L5S"].hide();
			}
			if (toFromSet.getValue() != 1 and cruiseSet.getValue() != 1) {
				me["INITA_CruiseFLTempS"].hide();
				me["Simple_L6S"].setColor(1,1,1);
				me["Simple_L6S"].setText("-----/---g");
			} else if (cruiseSet.getValue() == 1 and cruiseTempSet.getValue() == 1) {
				me["INITA_CruiseFLTempS"].hide();
				me["Simple_L6S"].setColor(0.0901,0.6039,0.7176);
				me["Simple_L6S"].setText(sprintf("%s", "FL" ~ cruiseFL.getValue()) ~ sprintf("/%sg", cruiseTemp.getValue()));
			} else if (cruiseSet.getValue() == 1) {
				me["INITA_CruiseFLTempS"].hide();
				me["Simple_L6S"].setColor(0.0901,0.6039,0.7176);
				setprop("/FMGC/internal/cruise-temp", 15 - (2 * cruiseFL.getValue() / 10));
				setprop("/FMGC/internal/cruise-temp-set", 1);
				me["Simple_L6S"].setText(sprintf("%s", "FL" ~ cruiseFL.getValue()) ~ sprintf("/%sg", cruiseTemp.getValue()));
			} else {
				me["INITA_CruiseFLTempS"].show();
				me["Simple_L6S"].setColor(0.7333,0.3803,0);
				me["Simple_L6S"].setText("         g");
			}
			if (toFromSet.getValue() == 1) {
				me["INITA_CoRouteS"].hide();
				me["INITA_FromToS"].hide();
				me["Simple_L1S"].show();
				me["Simple_L2S"].setColor(0.0901,0.6039,0.7176);
				if (altSet.getValue() == 1) {
					me["Simple_L2S"].setText(alt_airport.getValue());
				} else {
					me["Simple_L2S"].setText("NONE");
				}
				me.showRight(1, -1, 0, 0, 0, 0);
				me["Simple_R2SS"].hide();
				me["INITA_InitRequestS"].hide();
			} else {
				me["INITA_CoRouteS"].show();
				me["INITA_FromToS"].show();
				me["Simple_L1S"].hide();
				me["Simple_L2S"].setColor(1,1,1);
				me["Simple_L2S"].setText("----/----------");
				me.showRight(-1, 1, 0, 0, 0, 0);
				me["Simple_R2SS"].show();
				me["INITA_InitRequestS"].show();
			}
			if (ADIRSMCDUBTN.getValue() != 1) {
				me["INITA_AlignIRSS"].show();
				me["Simple_R3S"].setColor(AMBER);
				me.showRightArrow(0, 0, -1, 0, 0, 0);
			} else {
				me["INITA_AlignIRSS"].hide();
				me["Simple_R3S"].setColor(WHITE);
				me.showRightArrow(0, 0, 1, 0, 0, 0);
			}
			if (tropoSet.getValue() == 1) {
				me["Simple_R5S"].setFontSize(normal); 
			} else {
				me["Simple_R5S"].setFontSize(small); 
			}
			
			me["Simple_R6SS"].setText("GND TEMP");
			if (getprop("/FMGC/status/phase") == 0 and !getprop("/FMGC/internal/gndtemp-set")) {
				setprop("/FMGC/internal/gndtemp", 15 - (2 * getprop("/position/gear-agl-ft") / 1000));
				me["Simple_R6S"].setText(sprintf("%.0fg", gndtemp.getValue()));
				me["Simple_R6S"].setFontSize(small); 
			} else {
				if (getprop("/FMGC/internal/gndtemp-set")) {
					me["Simple_R6S"].setFontSize(normal); 
				} else {
					me["Simple_R6S"].setFontSize(small); 
				}
				me["Simple_R6S"].setText(sprintf("%.0fg", gndtemp.getValue()));
			}
			
			me["Simple_L1SS"].setText(" CO RTE");
			me["Simple_L2SS"].setText("ALTN/CO RTE");
			me["Simple_L3SS"].setText("FLT NBR");
			me["Simple_L5SS"].setText("COST INDEX");
			me["Simple_L6SS"].setText("CRZ FL/TEMP");
			me["Simple_L1S"].setText("NONE");
			me["Simple_L3S"].setText(sprintf("%s", flightNum.getValue()));
			me["Simple_R1SS"].setText("FROM/TO   ");
			me["Simple_R2SS"].setText("INIT ");
			me["Simple_R5SS"].setText("TROPO");
			
			me["Simple_R1S"].setText(sprintf("%s", depArpt.getValue() ~ "/" ~ arrArpt.getValue()));
			me["Simple_R2S"].setText("REQUEST ");
			me["Simple_R3S"].setText("IRS INIT ");
			me["Simple_R4S"].setText("WIND ");
			me["Simple_R5S"].setText(sprintf("%5.0f", tropo.getValue()));
		} else if (page == "IRSINIT") {
			if (!pageSwitch[i].getBoolValue()) {
				me["SimpleS"].show();
				me["Simple_CenterS"].show();
				me["FPLNS"].hide();
				me["DIRTO_TMPY_groupS"].hide();
				me["INITAS"].hide();
				me["IRSINITS"].show();
				me["INITBS"].hide();
				me["FUELPREDS"].hide();
				me["PROGS"].hide();
				me["PERFTOS"].hide();
				me["arrowsDepArrS"].hide();
				me["PERFAPPRS"].hide();
				me["PERFGAS"].hide();
				me["Simple_TitleS"].show();
				me["Simple_TitleS"].setText("IRS INIT");
				me["Simple_TitleS"].setColor(1, 1, 1);
				me["Simple_PageNumS"].setText("X/X");
				me["Simple_PageNumS"].hide();
				me["ArrowLeftS"].hide();
				me["ArrowRightS"].hide();
				
				me.showLeft(1, 1, -1, -1, -1, 1);
				me["Simple_L0SS"].hide();
				me.showLeftS(1, 1, -1, -1, -1, -1);
				me.showLeftArrow(-1, -1, -1, -1, -1, 1);
				me.showRight(1, 1, -1, -1, -1, 1);
				me.showRightS(1, 1, -1, -1, -1, -1);
				me.showRightArrow(-1, -1, -1, -1, -1, 1);
				me.showCenter(1, -1, 1, 1, 1, -1);
				me["Simple_C3BS"].hide();
				me["Simple_C4BS"].hide();
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
			
			me["Simple_L1SS"].setText("LAT");
				me["Simple_R1SS"].setText("LONG");
			if (getprop("/FMGC/internal/align-ref-lat-edit")) {
				me["IRSINIT_1S"].show();
				me["IRSINIT_2S"].hide();
			} else if (getprop("/FMGC/internal/align-ref-long-edit")) {
				me["IRSINIT_1S"].hide();
				me["IRSINIT_2S"].show();
			} else {
				me["IRSINIT_1S"].hide();
				me["IRSINIT_2S"].hide();
			}
			
			if (toFromSet.getValue() == 1) {
				degrees = getprop("/FMGC/internal/align-ref-lat-degrees");
				minutes = getprop("/FMGC/internal/align-ref-lat-minutes");
				sign = getprop("/FMGC/internal/align-ref-lat-sign");
				dms_lat = getprop("/FMGC/flightplan[2]/wp[0]/lat");
				degrees_lat = int(dms_lat);
				minutes_lat = sprintf("%.1f",abs((dms_lat - degrees_lat) * 60));
				sign_lat = degrees_lat >= 0 ? "N" : "S";
				lat_same = degrees_lat == degrees and minutes_lat == minutes and sign_lat == sign;
				me["Simple_L1S"].setText(abs(sprintf("%.0f", degrees)) ~ "g" ~ sprintf("%.1f", minutes) ~ " " ~ sign);
				
				degrees = getprop("/FMGC/internal/align-ref-long-degrees");
				minutes = getprop("/FMGC/internal/align-ref-long-minutes");
				sign = getprop("/FMGC/internal/align-ref-long-sign");
				dms_long = getprop("/FMGC/flightplan[2]/wp[0]/lon");
				degrees_long = int(dms_long);
				minutes_long = sprintf("%.1f",abs((dms_long - degrees_long) * 60));
				sign_long = degrees_long >= 0 ? "E" : "W";
				long_same = degrees_long == degrees and minutes_long == minutes and sign_long == sign;
				me["Simple_R1S"].setText(abs(sprintf("%.0f", degrees)) ~ "g" ~ sprintf("%.1f", minutes) ~ " " ~ sign);
				
				if (lat_same and long_same) {
					me["Simple_C1S"].setText(getprop("/FMGC/flightplan[2]/wp[0]/id"));
					me["Simple_C1S"].setColor(GREEN);
				} else {
					me["Simple_C1S"].setText("----");
					me["Simple_C1S"].setColor(WHITE);
				}
			} else {
				me["Simple_L1S"].setText("-----.--");
				me["Simple_R1S"].setText("------.--");
				me["Simple_C1S"].setText("----");
				me["Simple_C1S"].setColor(WHITE);
			}
			
			dms = getprop("/position/latitude-deg");
			degrees = int(dms);
			minutes = sprintf("%.1f",abs((dms - degrees) * 60));
			sign = degrees >= 0 ? "N" : "S";
			me["Simple_L2S"].setText(abs(degrees) ~ "g" ~ minutes ~ " " ~ sign);
			dms2 = getprop("/position/longitude-deg");
			degrees2 = int(dms2);
			minutes2 = sprintf("%.1f",abs((dms2 - degrees2) * 60));
			sign2 = degrees2 >= 0 ? "E" : "W";
			me["Simple_R2S"].setText(abs(degrees2) ~ "g" ~ minutes2 ~ " " ~ sign2);
			if (systems.ADIRS.ADIRunits[0].operative and getprop("/FMGC/internal/align1-done")) {
				me["Simple_C3S"].setText(abs(degrees) ~ "g" ~ minutes ~ " " ~ sign ~ "/" ~ abs(degrees2) ~ "g" ~ minutes2 ~ " " ~ sign2);
			} else {
				me["Simple_C3S"].setText("-----.--/-----.--");
			}
			if (systems.ADIRS.ADIRunits[1].operative and getprop("/FMGC/internal/align2-done")) {
				me["Simple_C4S"].setText(abs(degrees) ~ "g" ~ minutes ~ " " ~ sign ~ "/" ~ abs(degrees2) ~ "g" ~ minutes2 ~ " " ~ sign2);
			} else {
				me["Simple_C4S"].setText("-----.--/-----.--");
			}
			if (systems.ADIRS.ADIRunits[2].operative and getprop("/FMGC/internal/align3-done")) {
				me["Simple_C5S"].setText(abs(degrees) ~ "g" ~ minutes ~ " " ~ sign ~ "/" ~ abs(degrees2) ~ "g" ~ minutes2 ~ " " ~ sign2);
			} else {
				me["Simple_C5S"].setText("-----.--/-----.--");
			}
			
			if (align_set.getValue() == 1) {
				me["Simple_R6S"].setText("CONFIRM ALIGN ");
				me.colorRight("ack", "ack", "ack", "ack", "ack", "amb");
				me["IRSINIT_starS"].show();
				me.showRightArrow(0, 0, 0, 0, 0, -1);
			} else {
				me["Simple_R6S"].setText("ALIGN ON REF ");
				me["IRSINIT_starS"].hide();
				me.showRightArrow(0, 0, 0, 0, 0, 1);
			}
			
			if (systems.ADIRS.Operating.aligned[0].getValue()) {
				if (systems.ADIRS.ADIRunits[0].mode == 2) {
					me["Simple_C3SS"].setText("IRS1 IN ATT");
				} else {
					me["Simple_C3SS"].setText("IRS1 ALIGNED ON GPS");
				}
			} else {
				me["Simple_C3SS"].setText("IRS1 ALIGNING ON GPS");
			}
			
			if (systems.ADIRS.Operating.aligned[1].getValue()) {
				if (systems.ADIRS.ADIRunits[1].mode == 2) {
					me["Simple_C4SS"].setText("IRS2 IN ATT");
				} else {
					me["Simple_C4SS"].setText("IRS2 ALIGNED ON GPS");
				}
			} else {
				me["Simple_C4SS"].setText("IRS2 ALIGNING ON GPS");
			}
			
			if (systems.ADIRS.Operating.aligned[2].getValue()) {
				if (systems.ADIRS.ADIRunits[2].mode == 2) {
					me["Simple_C5SS"].setText("IRS3 IN ATT");
				} else {
					me["Simple_C5SS"].setText("IRS3 ALIGNED ON GPS");
				}
			} else {
				me["Simple_C5SS"].setText("IRS3 ALIGNING ON GPS");
			}
			
			me["Simple_L2SS"].setText("LAT");
			me["Simple_L6S"].setText(" RETURN");
			me["Simple_R2SS"].setText("LONG");
			me["Simple_C1SS"].setText("REFERENCE");
			me["Simple_C2SS"].setText("GPS POSITION");

		} else if (page == "ROUTESELECTION") {
			if (!pageSwitch[i].getBoolValue()) {
				me["SimpleS"].show();
				me["Simple_CenterS"].show();
				me["FPLNS"].hide();
				me["DIRTO_TMPY_groupS"].hide();
				me["INITAS"].hide();
				me["IRSINITS"].hide();
				me["INITBS"].hide();
				me["FUELPREDS"].hide();
				me["PROGS"].hide();
				me["PERFTOS"].hide();
				me["arrowsDepArrS"].hide();
				me["PERFAPPRS"].hide();
				me["PERFGAS"].hide();
				me["Simple_TitleS"].show();
				me["Simple_TitleS"].setText("ROUTE SELECTION");
				me["Simple_TitleS"].setColor(1, 1, 1);
				me["Simple_PageNumS"].setText("X/X");
				me["Simple_PageNumS"].hide();
				me["ArrowLeftS"].hide();
				me["ArrowRightS"].hide();
				
				me.showLeft(1, -1, -1, -1, -1, 1);
				me["Simple_L0SS"].hide();
				me.showLeftS(-1, -1, -1, -1, -1, -1);
				me.showLeftArrow(-1, -1, -1, -1, -1, 1);
				me.showRight(-1, -1, -1, -1, -1, -1);
				me.showRightS(-1, -1, -1, -1, -1, -1);
				me.showRightArrow(-1, -1, -1, -1, -1, -1);
				me.showCenter(-1, -1, -1, -1, -1, -1);
				me["Simple_C3BS"].hide();
				me["Simple_C4BS"].hide();
				me.showCenterS(-1, -1, -1, -1, -1, -1);
				
				me.fontLeft(default, 0, 0, 0, 0, default);
				
				me.fontSizeLeft(normal, 0, 0, 0, 0, normal);
				
				me.colorLeft("grn", "ack", "ack", "ack", "ack", "wht");
				
				pageSwitch[i].setBoolValue(1);
			}
			
			me["Simple_L1S"].setText("NONE");
			me["Simple_L6S"].setText(" RETURN");

			if (toFromSet.getValue() == 1 and alt_selected.getValue() == 0) {
				me["Simple_TitleS"].setText(sprintf("%s", depArpt.getValue() ~ "/" ~ arrArpt.getValue()));
			} else if (toFromSet.getValue() == 0 and alt_airport.getValue() != "" and alt_selected.getValue() == 1) {
				me["Simple_TitleS"].setText(sprintf("%s", alt_airport.getValue()));
			} else if (toFromSet.getValue() == 1 and alt_airport.getValue() != "" and alt_selected.getValue() == 1) {
				me["Simple_TitleS"].setText(sprintf("%s", arrArpt.getValue() ~ "/" ~ alt_airport.getValue()));
			} else {
				me["Simple_TitleS"].setText("ROUTE SELECTION");
			}

		} else if (page == "INITB") {
			if (!pageSwitch[i].getBoolValue()) {
				me["SimpleS"].show();
				me["Simple_CenterS"].show();
				me["FPLNS"].hide();
				me["DIRTO_TMPY_groupS"].hide();
				me["INITAS"].hide();
				me["IRSINITS"].hide();
				me["INITBS"].show();
				me["FUELPREDS"].hide();
				me["PROGS"].hide();
				me["PERFTOS"].hide();
				me["arrowsDepArrS"].hide();
				me["PERFAPPRS"].hide();
				me["PERFGAS"].hide();
				me["Simple_TitleS"].show();
				me["Simple_PageNumS"].setText("X/X");
				me["Simple_PageNumS"].hide();
				me["ArrowLeftS"].show();
				me["ArrowRightS"].show();
				
				me.showLeft(1, 1, 1, 1, 1, 1);
				me["Simple_L0SS"].hide();
				me.showLeftS(1, 1, 1, 1, 1, 1);
				me.showLeftArrow(-1, -1, -1, -1, -1, -1);
				me.showCenter(1, -1, 1, 1, 1, -1);
				me["Simple_C3BS"].hide();
				me["Simple_C4BS"].hide();
				me.showCenterS(-1, -1, -1, -1, -1, -1);
				me.showRight(-1, 1, 1, 1, 1, 1);
				me.showRightS(1, 1, 1, 1, 1, 1);
				me.showRightArrow(-1, -1, 1, -1, -1, -1);
				
				me.fontLeft(default, default, default, default, default, default);
				me.fontLeftS(default, default, default, default, default, default);
				me.fontRight(default, default, default, default, default, default);
				me.fontRightS(default, default, default, default, default, default);
				
				me.fontSizeLeft(small, small, small, small, small, small);
				me.fontSizeCenter(small, small, small, small, small, small);
				me.fontSizeRight(normal, normal, normal, small, small, small);
				me["Simple_C4BS"].setFontSize(small);
				
				me.colorLeft("blu", "wht", "wht", "wht", "wht", "wht");
				me.colorLeftS("wht", "wht", "wht", "wht", "wht", "wht");
				me.colorLeftArrow("wht", "wht", "wht", "wht", "wht", "wht");
				me.colorCenter("blu", "wht", "blu", "grn", "blu", "wht");
				me["Simple_C4BS"].setColor(GREEN);
				me.colorRight("blu", "blu", "amb", "wht", "blu", "wht");
				me.colorRightS("wht", "wht", "amb", "wht", "wht", "wht");
				me.colorRightArrow("wht", "wht", "amb", "wht", "wht", "wht");
				
				pageSwitch[i].setBoolValue(1);
			}
					
			me["Simple_L1SS"].setText("TAXI");
			me["Simple_L1S"].setText(sprintf("%2.1f", taxi_fuel.getValue()));
			me["Simple_L2SS"].setText("TRIP/TIME");
			me["Simple_L3SS"].setText("RTE RSV/PCT");
			me["Simple_L4SS"].setText("ALTN/TIME");
			me["Simple_L5SS"].setText("FINAL/TIME");
			me["Simple_L6SS"].setText("MIN DEST FOB");
			me["Simple_R2SS"].setText("BLOCK");
			me["Simple_R4SS"].setText("TOW/   LW");
			me["Simple_R5SS"].setText("TRIP WIND");
			me["Simple_R5S"].setText(trip_wind.getValue());
			me["Simple_R6SS"].setText("EXTRA/TIME");
			
			me["Simple_TitleS"].setColor(1, 1, 1);
			
			if (!getprop("/FMGC/internal/fuel-request-set")) {
				me["Simple_L2S"].setText("---.-/----");
				me["Simple_L3S"].setText("---.-");
				me["Simple_C3S"].setText(sprintf("/%.1f                ", rte_percent.getValue()));
				me["Simple_L4S"].setText("---.-/----");
				me["Simple_C4S"].hide();
				me["Simple_L5S"].setText("---.-");
				me["Simple_C5S"].setText(sprintf("/%s               ", final_time.getValue()));
				me["Simple_L6S"].setText("---.-");
				if (blockSet.getValue() == 1) {
					me["Simple_R2S"].show(); 
					me["INITB_BlockS"].hide();
					me["Simple_R2S"].setText(sprintf("%3.1f", block.getValue()));
				} else {
					me["Simple_R2S"].hide(); 
					me["INITB_BlockS"].show();
				}
				if (zfwSet.getValue() == 1) {
					me["Simple_R3SS"].show();
					me["Simple_R3S"].show(); 
					me["Simple_R3SS"].setText("FUEL");
					me["Simple_R3S"].setText("PLANNING ");
					me["Simple_R3_ArrowS"].show();
					me["Simple_R3_ArrowS"].setColor(AMBER);
				} else {
					me["Simple_R3SS"].hide();
					me["Simple_R3S"].hide(); 
					me["Simple_R3_ArrowS"].hide();
				}
				me["Simple_C4BS"].hide();
				me["Simple_R4S"].setText("---.-/---.-");
				me["Simple_R6S"].setText("---.-/----");
				
				me["Simple_TitleS"].setText("INIT");
				me["Simple_TitleS"].setColor(1, 1, 1);
				
				me.colorLeft("ack", "wht", "wht", "wht", "wht", "wht");
				me.colorRight("ack", "blu", "amb", "wht", "ack", "wht");
				me["Simple_R3SS"].setColor(AMBER);
			} else {
			
				me["Simple_TitleS"].setText("INIT FUEL PREDICTION ");
				
				if (getprop("/FMGC/internal/block-calculating")) {
					me["Simple_L2S"].setText("---.-/----");
					me["Simple_L3S"].setText("---.-");
					me["Simple_C3S"].setText(sprintf("/%.1f                ", rte_percent.getValue()));
					me["Simple_L4S"].setText("---.-/----");
					me["Simple_C4S"].hide();
					me["Simple_L5S"].setText("---.-");
					me["Simple_C5S"].setText(sprintf("/%s               ", final_time.getValue()));
					me["Simple_L6S"].setText("---.-");
					me["Simple_R2S"].show();
					me["Simple_R2S"].setText("---.-");
					me["INITB_BlockS"].hide();
					me["Simple_R3SS"].show();
					me["Simple_R3S"].show(); 
					me["Simple_R3SS"].setText("FUEL");
					me["Simple_R3S"].setText("PLANNING ");
					me["Simple_R3_ArrowS"].show();
					me["Simple_R3_ArrowS"].setColor(GREEN);
					me["Simple_C4BS"].hide();
					me["Simple_R4S"].setText("---.-/---.-");
					me["Simple_R6S"].setText("---.-/----");
				
					me.colorLeft("ack", "wht", "wht", "wht", "wht", "wht");
					me.colorRight("ack", "wht", "grn", "wht", "ack", "wht");
					me["Simple_R3SS"].setColor(GREEN);
				} else {
					if (!getprop("/FMGC/internal/block-confirmed")) {
						me["Simple_L2S"].setText("---.-/----");
						me["Simple_L3S"].setText("---.-");
						me["Simple_C3S"].setText(sprintf("/%.1f                ", rte_percent.getValue()));
						me["Simple_L4S"].setText("---.-/----");
						me["Simple_C4S"].hide();
						me["Simple_L5S"].setText("---.-");
						me["Simple_C5S"].setText(sprintf("/%s               ", final_time.getValue()));
						me["Simple_L6S"].setText("---.-");
						me["Simple_R2S"].show(); 
						me["INITB_BlockS"].hide();
						me["Simple_R2S"].setText(sprintf("%3.1f", block.getValue()));
						me["Simple_R3SS"].show();
						me["Simple_R3S"].show(); 
						me["Simple_R3SS"].setText("BLOCK");
						me["Simple_R3S"].setText("CONFIRM ");
						me["Simple_R3_ArrowS"].show();
						me["Simple_R3_ArrowS"].setColor(AMBER);
						me["Simple_C4BS"].show();
						if (num(tow.getValue()) >= 100.0) {
							me["Simple_C4BS"].setText(sprintf("              %4.1f/", tow.getValue()));
						} else {
							me["Simple_C4BS"].setText(sprintf("               %4.1f/", tow.getValue()));
						}
						me["Simple_R4S"].setText("---.-");
						me["Simple_R6S"].setText("---.-/----");
			
						me.colorLeft("ack", "wht", "wht", "wht", "wht", "wht");
						me.colorRight("ack", "blu", "amb", "wht", "ack", "wht");
						me["Simple_R3SS"].setColor(AMBER);
					} else {
						if (getprop("/FMGC/internal/fuel-calculating")) {
							me["Simple_L2S"].setText("---.-/----");
							me["Simple_L3S"].setText("---.-");
							if (rte_rsv_set.getValue() == 1) {
								me["Simple_C3S"].setText(sprintf("/%.1f             ", rte_percent.getValue()));
							} else if (rte_percent_set.getValue() == 1) {
								me["Simple_C3S"].setText(sprintf("/%.1f            ", rte_percent.getValue()));
							} else {
								me["Simple_C3S"].setText(sprintf("/%.1f                ", rte_percent.getValue()));
							}
							me["Simple_L4S"].setText("---.-/----");
							me["Simple_C4S"].hide();
							me["Simple_L5S"].setText("---.-");
							if (final_fuel_set.getValue() == 1 and final_time_set.getValue() == 1) {
								me["Simple_C5S"].setText(sprintf("/%s         ", final_time.getValue()));
							} else if (final_fuel_set.getValue() == 1) {
								me["Simple_C5S"].setText(sprintf("/%s             ", final_time.getValue()));
							} else if (final_time_set.getValue() == 1) {
								me["Simple_C5S"].setText(sprintf("/%s           ", final_time.getValue()));
							} else {
								me["Simple_C5S"].setText(sprintf("/%s               ", final_time.getValue()));
							}
							me["Simple_L6S"].setText("---.-");
							me["Simple_R2S"].show(); 
							me["INITB_BlockS"].hide();
							me["Simple_R2S"].setText(sprintf("%3.1f", block.getValue()));
							me["Simple_R3SS"].hide();
							me["Simple_R3S"].hide(); 
							me["Simple_R3_ArrowS"].hide();
							me["Simple_C4BS"].show();
							if (num(tow.getValue()) >= 100.0) {
								me["Simple_C4BS"].setText(sprintf("              %4.1f/", tow.getValue()));
							} else {
								me["Simple_C4BS"].setText(sprintf("               %4.1f/", tow.getValue()));
							}
							me["Simple_R4S"].setText("---.-");
							me["Simple_R6S"].setText("---.-/----");
				
							me.colorLeft("ack", "wht", "wht", "wht", "wht", "wht");
							me.colorRight("ack", "blu", "ack", "wht", "ack", "wht");
						} else {
							me["Simple_L2S"].setText(sprintf("%.1f/" ~ trip_time.getValue(), trip_fuel.getValue()));
							me["Simple_L3S"].setText(sprintf("%.1f", rte_rsv.getValue()));
							if (rte_rsv_set.getValue() == 1) {
								if (num(rte_rsv.getValue()) > 9.9 and num(rte_percent.getValue()) > 9.9) {
									me["Simple_C3S"].setText(sprintf("/%.1f               ", rte_percent.getValue()));
								} else if (num(rte_rsv.getValue()) > 9.9) {
									me["Simple_C3S"].setText(sprintf("/%.1f                ", rte_percent.getValue()));
								} else if (num(rte_percent.getValue()) > 9.9) {
									me["Simple_C3S"].setText(sprintf("/%.1f                 ", rte_percent.getValue()));
								} else {
									me["Simple_C3S"].setText(sprintf("/%.1f                  ", rte_percent.getValue()));
								}
							} else if (rte_percent_set.getValue() == 1) {
								if (num(rte_rsv.getValue()) > 9.9 and num(rte_percent.getValue()) > 9.9) {
									me["Simple_C3S"].setText(sprintf("/%.1f            ", rte_percent.getValue()));
								} else if (num(rte_rsv.getValue()) > 9.9) {
									me["Simple_C3S"].setText(sprintf("/%.1f             ", rte_percent.getValue()));
								} else if (num(rte_percent.getValue()) > 9.9) {
									me["Simple_C3S"].setText(sprintf("/%.1f              ", rte_percent.getValue()));
								} else {
									me["Simple_C3S"].setText(sprintf("/%.1f               ", rte_percent.getValue()));
								}
							} else {
								if (num(rte_rsv.getValue()) > 9.9 and num(rte_percent.getValue()) > 9.9) {
									me["Simple_C3S"].setText(sprintf("/%.1f                 ", rte_percent.getValue()));
								} else if (num(rte_rsv.getValue()) > 9.9) {
									me["Simple_C3S"].setText(sprintf("/%.1f                  ", rte_percent.getValue()));
								} else if (num(rte_percent.getValue()) > 9.9) {
									me["Simple_C3S"].setText(sprintf("/%.1f                   ", rte_percent.getValue()));
								} else {
									me["Simple_C3S"].setText(sprintf("/%.1f                    ", rte_percent.getValue()));
								}
							}
							if (altSet.getValue() == 1) {
								me["Simple_L4S"].setText(sprintf("%.1f", alt_fuel.getValue()));
								me["Simple_L4S"].setColor(BLUE);
								me["Simple_C4S"].show();
								if (alt_fuel_set.getValue() == 1) {
									if (num(alt_fuel.getValue()) > 9.9) {
										me["Simple_C4S"].setText(sprintf("/%s               ", alt_time.getValue()));
									} else {
										me["Simple_C4S"].setText(sprintf("/%s                 ", alt_time.getValue()));
									}
								} else {
									if (num(alt_fuel.getValue()) > 9.9) {
										me["Simple_C4S"].setText(sprintf("/%s                 ", alt_time.getValue()));
									} else {
										me["Simple_C4S"].setText(sprintf("/%s                   ", alt_time.getValue()));
									}
								}
							} else {
								me["Simple_L4S"].setText("---.-/----");
								me["Simple_L4S"].setColor(WHITE);
								me["Simple_C4S"].hide();
							}
							me["Simple_L5S"].setText(sprintf("%.1f", final_fuel.getValue()));
							if (final_time_set.getValue() == 1 and final_fuel_set.getValue() == 1) {
								if (num(final_fuel.getValue()) > 9.9) {
									me["Simple_C5S"].setText(sprintf("/%s           ", final_time.getValue()));
								} else {
									me["Simple_C5S"].setText(sprintf("/%s             ", final_time.getValue()));
								}
							} else if (final_time_set.getValue() == 1) {
								if (num(final_fuel.getValue()) > 9.9) {
									me["Simple_C5S"].setText(sprintf("/%s            ", final_time.getValue()));
								} else {
									me["Simple_C5S"].setText(sprintf("/%s              ", final_time.getValue()));
								}
							} else if (final_fuel_set.getValue() == 1) {
								if (num(final_fuel.getValue()) > 9.9) {
									me["Simple_C5S"].setText(sprintf("/%s               ", final_time.getValue()));
								} else {
									me["Simple_C5S"].setText(sprintf("/%s                  ", final_time.getValue()));
								}
							} else {
								if (num(final_fuel.getValue()) > 9.9) {
									me["Simple_C5S"].setText(sprintf("/%s                 ", final_time.getValue()));
								} else {
									me["Simple_C5S"].setText(sprintf("/%s                   ", final_time.getValue()));
								}
							}
							me["Simple_L6S"].setText(sprintf("%.1f", min_dest_fob.getValue()));
							me["Simple_R2S"].show(); 
							me["INITB_BlockS"].hide();
							me["Simple_R2S"].setText(sprintf("%3.1f", block.getValue()));
							me["Simple_R3SS"].hide();
							me["Simple_R3S"].hide(); 
							me["Simple_R3_ArrowS"].hide();
							me["Simple_C4BS"].hide();
							me["Simple_R4S"].setText(sprintf("%4.1f/", tow.getValue()) ~ sprintf("%4.1f", lw.getValue()));
							me["Simple_R6S"].setText(sprintf("%.1f/" ~ extra_time.getValue(), extra_fuel.getValue()));
				
							me.colorLeft("ack", "grn", "blu", "ack", "blu", "blu");
							me.colorRight("ack", "blu", "ack", "grn", "ack", "grn");
						}
					}
				}
			}
			
			me["Simple_R1SS"].setText("ZFWCG/   ZFW");
			me["Simple_R1S"].setText(sprintf("%3.1f", zfw.getValue()));
			if (zfwcgSet.getValue() == 1) {
				me["Simple_C1S"].setFontSize(normal); 
				me["Simple_C1S"].setText("        " ~ sprintf("%3.1f", zfwcg.getValue()));
				me["INITB_ZFWCGS"].hide();
			} else {
				me["Simple_C1S"].setFontSize(small);
				me["Simple_C1S"].setText("           " ~ sprintf("%3.1f", zfwcg.getValue()));
				me["INITB_ZFWCGS"].hide();
			}
			
			if (zfwSet.getValue() == 1) {
				me["INITB_ZFWS"].hide();
				me["INITB_ZFW_SS"].show();
				me["Simple_R1S"].show(); 
			} else {
				me["INITB_ZFWS"].show();
				me["INITB_ZFW_SS"].hide();
				me["Simple_R1S"].hide(); 
			}
			
			if (taxi_fuel_set.getValue() == 1) {
				me["Simple_L1S"].setFontSize(normal);
			} else {
				me["Simple_L1S"].setFontSize(small);
			}
			
			if (rte_rsv_set.getValue() == 1) {
				me["Simple_L3S"].setFontSize(normal);
				me["Simple_C3S"].setFontSize(small);
			} else if (rte_percent_set.getValue() == 1) {
				me["Simple_L3S"].setFontSize(small);
				me["Simple_C3S"].setFontSize(normal);
			} else {
				me["Simple_L3S"].setFontSize(small);
				me["Simple_C3S"].setFontSize(small);
			}
			
			if (alt_fuel_set.getValue() == 1 and altSet.getValue() == 1) {
				me["Simple_L4S"].setFontSize(normal);
			} else {
				me["Simple_L4S"].setFontSize(small);
			}
			
			if (final_fuel_set.getValue() == 1 and final_time_set.getValue() == 1) {
				me["Simple_L5S"].setFontSize(normal);
				me["Simple_C5S"].setFontSize(normal);
			} else if (final_fuel_set.getValue() == 1) {
				me["Simple_L5S"].setFontSize(normal);
				me["Simple_C5S"].setFontSize(small);
			} else if (final_time_set.getValue() == 1) {
				me["Simple_L5S"].setFontSize(small);
				me["Simple_C5S"].setFontSize(normal);
			} else {
				me["Simple_L5S"].setFontSize(small);
				me["Simple_C5S"].setFontSize(small);
			}
			
			if (min_dest_fob_set.getValue() == 1) {
				me["Simple_L6S"].setFontSize(normal);
			} else {
				me["Simple_L6S"].setFontSize(small);
			}
			
		} else if (page == "FUELPRED") {
			if (!pageSwitch[i].getBoolValue()) {
				me["SimpleS"].show();
				me["Simple_CenterS"].show();
				me["FPLNS"].hide();
				me["DIRTO_TMPY_groupS"].hide();
				me["INITAS"].hide();
				me["IRSINITS"].hide();
				me["INITBS"].hide();
				me["FUELPREDS"].show();
				me["PROGS"].hide();
				me["PERFTOS"].hide();
				me["arrowsDepArrS"].hide();
				me["PERFAPPRS"].hide();
				me["PERFGAS"].hide();
				me["Simple_TitleS"].show();
				me["Simple_TitleS"].setText("FUEL PRED");
				me["Simple_TitleS"].setColor(1, 1, 1);
				me["Simple_PageNumS"].setText("X/X");
				me["Simple_PageNumS"].hide();
				me["ArrowLeftS"].show();
				me["ArrowRightS"].show();
				
				me.showLeft(1, 1, 1, 1, 1, 1);
				me["Simple_L0SS"].hide();
				me.showLeftS(1, -1, 1, 1, 1, 1);
				me.showLeftArrow(-1, -1, -1, -1, -1, -1);
				me.showCenter(1, 1, 1, -1, 1, -1);
				me["Simple_C3BS"].show();
				me["Simple_C4BS"].hide();
				me.showCenterS(1, -1, -1, -1, -1, -1);
				me.showRight(1, 1, -1, 1, 1, 1);
				me.showRightS(1, -1, 1, 1, 1, 1);
				me.showRightArrow(-1, -1, -1, -1, -1, -1);
				
				me.fontLeft(default, default, default, default, default, default);
				me.fontLeftS(default, default, default, default, default, default);
				me.fontRight(default, default, default, default, default, default);
				me.fontRightS(default, default, default, default, default, default);
				
				me.fontSizeLeft(normal, normal, small, small, small, small);
				me.fontSizeCenter(small, small, small, small, small, small);
				me.fontSizeRight(normal, normal, normal, small, small, small);
				me["Simple_C3BS"].setFontSize(small);
				
				me.colorLeft("grn", "grn", "wht", "wht", "wht", "wht");
				me.colorLeftS("wht", "wht", "wht", "wht", "wht", "wht");
				me.colorLeftArrow("wht", "wht", "wht", "wht", "wht", "wht");
				me.colorCenter("grn", "grn", "blu", "grn", "blu", "wht");
				me["Simple_C3BS"].setColor(BLUE);
				me.colorCenterS("wht", "wht", "wht", "wht", "wht", "wht");
				me.colorRight("grn", "grn", "blu", "wht", "wht", "wht");
				me.colorRightS("wht", "wht", "wht", "wht", "wht", "wht");
				me.colorRightArrow("wht", "wht", "wht", "wht", "wht", "wht");
				
				pageSwitch[i].setBoolValue(1);
			}
			
			if (!engrdy.getBoolValue() or toFromSet.getValue() != 1) {
				me["Simple_L1S"].setText("----");
			} else {
				me["Simple_L1S"].setText(arrArpt.getValue());
			}
			if (!engrdy.getBoolValue() or alt_airport.getValue() == "") {
				me["Simple_L2S"].setText("----");
			} else {
				me["Simple_L2S"].setText(alt_airport.getValue());
			}
			
			me["Simple_L1SS"].setText("AT");
			me["Simple_L2SS"].setText("X");
			me["Simple_L3SS"].setText("RTE RSV/PCT");
			me["Simple_L4SS"].setText("ALTN/TIME");
			me["Simple_L5SS"].setText("FINAL/TIME");
			me["Simple_L6SS"].setText("MIN DEST FOB");
			
			me["Simple_C1SS"].setText("UTC");
			me["Simple_C1S"].setText("----");
			me["Simple_C2S"].setText("----");
			
			me["Simple_R1S"].setText("-.-");
			me["Simple_R2S"].setText("-.-");
			me["Simple_R1SS"].setText("EFOB");
			me["Simple_R2SS"].setText("X");
			me["Simple_R4SS"].setText("FOB     ");
			me["Simple_R5SS"].setText("   GW/   CG");
			me["Simple_R6SS"].setText("EXTRA/TIME");
			
			if (!getprop("/FMGC/internal/fuel-request-set") or !getprop("/FMGC/internal/block-confirmed") or getprop("/FMGC/internal/fuel-calculating")) {
				me["Simple_L3S"].setText("---.-");
				if (rte_rsv_set.getValue() == 1) {
					me["Simple_C3BS"].setText(sprintf("/%.1f             ", rte_percent.getValue()));
				} else if (rte_percent_set.getValue() == 1) {
					me["Simple_C3BS"].setText(sprintf("/%.1f            ", rte_percent.getValue()));
				} else {
					me["Simple_C3BS"].setText(sprintf("/%.1f                ", rte_percent.getValue()));
				}
				me["Simple_L4S"].setText("---.-/----");
				me["Simple_C4S"].hide();
				me["Simple_L5S"].setText("---.-");
				if (final_fuel_set.getValue() == 1 or final_time_set.getValue() == 1) {
					me["Simple_C5S"].setText(sprintf("/%s             ", final_time.getValue()));
				} else {
					me["Simple_C5S"].setText(sprintf("/%s               ", final_time.getValue()));
				}
				me["Simple_L6S"].setText("---.-");
				
				me["Simple_R4S"].setText("---.-/FF+FQ");
				me["Simple_R5S"].setText("---.-/---.-");
				me["Simple_R6S"].setText("---.-/----");
	
				me.colorLeft("ack", "ack", "wht", "wht", "wht", "wht");
				me.colorRight("ack", "ack", "ack", "wht", "wht", "wht");
			} else {
				me["Simple_L3S"].setText(sprintf("%.1f", rte_rsv.getValue()));
				if (rte_rsv_set.getValue() == 1) {
					if (num(rte_rsv.getValue()) > 9.9 and num(rte_percent.getValue()) > 9.9) {
						me["Simple_C3BS"].setText(sprintf("/%.1f               ", rte_percent.getValue()));
					} else if (num(rte_rsv.getValue()) > 9.9) {
						me["Simple_C3BS"].setText(sprintf("/%.1f                ", rte_percent.getValue()));
					} else if (num(rte_percent.getValue()) > 9.9) {
						me["Simple_C3BS"].setText(sprintf("/%.1f                 ", rte_percent.getValue()));
					} else {
						me["Simple_C3BS"].setText(sprintf("/%.1f                  ", rte_percent.getValue()));
					}
				} else if (rte_percent_set.getValue() == 1) {
					if (num(rte_rsv.getValue()) > 9.9 and num(rte_percent.getValue()) > 9.9) {
						me["Simple_C3BS"].setText(sprintf("/%.1f            ", rte_percent.getValue()));
					} else if (num(rte_rsv.getValue()) > 9.9) {
						me["Simple_C3BS"].setText(sprintf("/%.1f             ", rte_percent.getValue()));
					} else if (num(rte_percent.getValue()) > 9.9) {
						me["Simple_C3BS"].setText(sprintf("/%.1f              ", rte_percent.getValue()));
					} else {
						me["Simple_C3BS"].setText(sprintf("/%.1f               ", rte_percent.getValue()));
					}
				} else {
					if (num(rte_rsv.getValue()) > 9.9 and num(rte_percent.getValue()) > 9.9) {
						me["Simple_C3BS"].setText(sprintf("/%.1f                 ", rte_percent.getValue()));
					} else if (num(rte_rsv.getValue()) > 9.9) {
						me["Simple_C3BS"].setText(sprintf("/%.1f                  ", rte_percent.getValue()));
					} else if (num(rte_percent.getValue()) > 9.9) {
						me["Simple_C3BS"].setText(sprintf("/%.1f                   ", rte_percent.getValue()));
					} else {
						me["Simple_C3BS"].setText(sprintf("/%.1f                    ", rte_percent.getValue()));
					}
				}
				if (altSet.getValue() == 1) {
					me["Simple_L4S"].setText(sprintf("%.1f", alt_fuel.getValue()));
					me["Simple_L4S"].setColor(BLUE);
					me["Simple_C4S"].show();
					if (alt_fuel_set.getValue() == 1) {
						if (num(alt_fuel.getValue()) > 9.9) {
							me["Simple_C4S"].setText(sprintf("/%s               ", alt_time.getValue()));
						} else {
							me["Simple_C4S"].setText(sprintf("/%s                 ", alt_time.getValue()));
						}
					} else {
						if (num(alt_fuel.getValue()) > 9.9) {
							me["Simple_C4S"].setText(sprintf("/%s                 ", alt_time.getValue()));
						} else {
							me["Simple_C4S"].setText(sprintf("/%s                   ", alt_time.getValue()));
						}
					}
				} else {
					me["Simple_L4S"].setText("---.-/----");
					me["Simple_L4S"].setColor(WHITE);
					me["Simple_C4S"].hide();
				}
				me["Simple_L5S"].setText(sprintf("%.1f", final_fuel.getValue()));
				if (final_time_set.getValue() == 1 and final_fuel_set.getValue() == 1) {
					if (num(final_fuel.getValue()) > 9.9) {
						me["Simple_C5S"].setText(sprintf("/%s           ", final_time.getValue()));
					} else {
						me["Simple_C5S"].setText(sprintf("/%s             ", final_time.getValue()));
					}
				} else if (final_time_set.getValue() == 1) {
					if (num(final_fuel.getValue()) > 9.9) {
						me["Simple_C5S"].setText(sprintf("/%s            ", final_time.getValue()));
					} else {
						me["Simple_C5S"].setText(sprintf("/%s              ", final_time.getValue()));
					}
				} else if (final_fuel_set.getValue() == 1) {
					if (num(final_fuel.getValue()) > 9.9) {
						me["Simple_C5S"].setText(sprintf("/%s               ", final_time.getValue()));
					} else {
						me["Simple_C5S"].setText(sprintf("/%s                  ", final_time.getValue()));
					}
				} else {
					if (num(final_fuel.getValue()) > 9.9) {
						me["Simple_C5S"].setText(sprintf("/%s                 ", final_time.getValue()));
					} else {
						me["Simple_C5S"].setText(sprintf("/%s                   ", final_time.getValue()));
					}
				}
				me["Simple_L6S"].setText(sprintf("%.1f", min_dest_fob.getValue()));
				
				setprop("/FMGC/internal/fob", num(getprop("/consumables/fuel/total-fuel-lbs") / 1000));
				setprop("/FMGC/internal/fuel-pred-gw", num(getprop("/fdm/jsbsim/inertia/weight-lbs") / 1000));
				setprop("/FMGC/internal/cg", num(getprop("/FMGC/internal/zfwcg")));
				me["Simple_R4S"].setText(sprintf("%4.1f/" ~ fffq_sensor.getValue(), fob.getValue()));
				me["Simple_R5S"].setText(sprintf("%4.1f/", gw.getValue()) ~ sprintf("%4.1f", cg.getValue()));
				me["Simple_R6S"].setText(sprintf("%4.1f/" ~ extra_time.getValue(), extra_fuel.getValue()));
				
				me.colorLeft("ack", "ack", "blu", "ack", "blu", "blu");
				me.colorRight("ack", "ack", "blu", "grn", "grn", "grn");
			}
			
			me["Simple_R3SS"].setText("ZFWCG/ZFW");
			me["Simple_R3S"].setText(sprintf("%3.1f", zfw.getValue()));
			if (zfwcgSet.getValue() == 1) {
				me["Simple_C3S"].setFontSize(normal); 
				me["Simple_C3S"].setText("        " ~ sprintf("%3.1f", zfwcg.getValue()));
				me["FUELPRED_ZFWCGS"].hide();
			} else {
				me["Simple_C3S"].setFontSize(small);
				me["Simple_C3S"].setText("           " ~ sprintf("%3.1f", zfwcg.getValue()));
				me["FUELPRED_ZFWCGS"].hide();
			}
			
			if (zfwSet.getValue() == 1) {
				me["FUELPRED_ZFWS"].hide();
				me["FUELPRED_ZFW_SS"].show();
				me["Simple_R3S"].show(); 
			} else {
				me["FUELPRED_ZFWS"].show();
				me["FUELPRED_ZFW_SS"].hide();
				me["Simple_R3S"].hide(); 
			}
			
			if (rte_rsv_set.getValue() == 1) {
				me["Simple_L3S"].setFontSize(normal);
				me["Simple_C3BS"].setFontSize(small);
			} else if (rte_percent_set.getValue() == 1) {
				me["Simple_L3S"].setFontSize(small);
				me["Simple_C3BS"].setFontSize(normal);
			} else {
				me["Simple_L3S"].setFontSize(small);
				me["Simple_C3BS"].setFontSize(small);
			}
			
			if (alt_fuel_set.getValue() == 1 and altSet.getValue() == 1) {
				me["Simple_L4S"].setFontSize(normal);
			} else {
				me["Simple_L4S"].setFontSize(small);
			}
			
			if (final_fuel_set.getValue() == 1 and final_time_set.getValue() == 1) {
				me["Simple_L5S"].setFontSize(normal);
				me["Simple_C5S"].setFontSize(normal);
			} else if (final_fuel_set.getValue() == 1) {
				me["Simple_L5S"].setFontSize(normal);
				me["Simple_C5S"].setFontSize(small);
			} else if (final_time_set.getValue() == 1) {
				me["Simple_L5S"].setFontSize(small);
				me["Simple_C5S"].setFontSize(normal);
			} else {
				me["Simple_L5S"].setFontSize(small);
				me["Simple_C5S"].setFontSize(small);
			}
			
			if (min_dest_fob_set.getValue() == 1) {
				me["Simple_L6S"].setFontSize(normal);
			} else {
				me["Simple_L6S"].setFontSize(small);
			}
			
		} else if (page == "PROGTO" or page == "PROGCLB" or page == "PROGCRZ" or page == "PROGDES") {
			if (getprop("/FMGC/status/phase") == 0 or getprop("/FMGC/status/phase") == 1) {
				setprop("/MCDU[" ~ i ~ S"]/page", "PROGTO");
				page = "PROGTO";
			} else if (getprop("/FMGC/status/phase") == 2) {
				setprop("/MCDU[" ~ i ~ S"]/page", "PROGCLB");
				page = "PROGCLB";
			} else if (getprop("/FMGC/status/phase") == 3) {
				setprop("/MCDU[" ~ i ~ S"]/page", "PROGCRZ");
				page = "PROGCRZ";
			} else if (getprop("/FMGC/status/phase") == 4 or getprop("/FMGC/status/phase") == 5 or getprop("/FMGC/status/phase") == 6) {
				setprop("/MCDU[" ~ i ~ S"]/page", "PROGDES");
				page = "PROGDES";
			}
			
			if (!pageSwitch[i].getBoolValue()) {
				me["SimpleS"].show();
				me["Simple_CenterS"].show();
				me["FPLNS"].hide();
				me["DIRTO_TMPY_groupS"].hide();
				me["INITAS"].hide();
				me["IRSINITS"].hide();
				me["INITBS"].hide();
				me["FUELPREDS"].hide();
				me["PROGS"].show();
				me["PERFTOS"].hide();
				me["arrowsDepArrS"].hide();
				me["PERFAPPRS"].hide();
				me["PERFGAS"].hide();
				
				if (flightNumSet.getValue() == 1) {
					if (page == "PROGTO") {
						me["Simple_TitleS"].setText(sprintf("TAKE OFF %s", flightNum.getValue()));
					} else if (page == "PROGCLB") {
						me["Simple_TitleS"].setText(sprintf("CLIMB %s", flightNum.getValue()));
					} else if (page == "PROGCRZ") {
						me["Simple_TitleS"].setText(sprintf("CRUISE %s", flightNum.getValue()));
					} else if (page == "PROGDES") {
						me["Simple_TitleS"].setText(sprintf("DESCENT %s", flightNum.getValue()));
					}
				} else {
					if (page == "PROGTO") {
						me["Simple_TitleS"].setText("TAKE OFF");
					} else if (page == "PROGCLB") {
						me["Simple_TitleS"].setText("CLIMB");
					} else if (page == "PROGCRZ") {
						me["Simple_TitleS"].setText("CRUISE");
					} else if (page == "PROGDES") {
						me["Simple_TitleS"].setText("DESCENT");
					}
				}
				
				me["Simple_TitleS"].show();
				me["Simple_TitleS"].setColor(0.0509,0.7529,0.2941);
				me["Simple_PageNumS"].setText("X/X");
				me["Simple_PageNumS"].hide();
				me["ArrowLeftS"].hide();
				me["ArrowRightS"].hide();
				
				me.showLeft(1, 1, 1, 1, 1, 1);
				me["Simple_L0SS"].hide();
				me.showLeftS(1, -1, 1, 1, 1, 1);
				me.showLeftArrow(-1, 1, -1, -1, 1, -1);
				me.showRight(1, -1, -1, 1, 1, 1);
				me.showRightS(1, -1, -1, -1, -1, 1);
				me.showRightArrow(-1, -1, -1, -1, -1, -1);
				me.showCenter(1, -1, -1, 1, -1, 1);
				me["Simple_C3BS"].hide();
				me["Simple_C4BS"].hide();
				me.showCenterS(1, -1, -1, -1, -1, 1);
				
				me.fontLeft(default, default, symbol, default, default, default);
				me.fontLeftS(default, default, default, default, default, default);
				me.fontRight(default, symbol, symbol, symbol, default, default);
				me.fontRightS(default, default, default, default, default, default);
				
				if (page == "PROGCRZ") {
					me.showLeftS(0, 0, -1, 0, 0, 0);
					me.showCenterS(0, 0, 1, 0, 0, 0);
					#me.showRight(0, 0, 1, 0, 0, 0); #Add when implement cruise phase
					me.fontLeft(0, 0, default, 0, 0, 0);
				} else if (page == "PROGDES") {
					me.showRight(0, 1, 0, 0, 0, 0);
				}
				
				me.fontSizeLeft(normal, normal, small, small, normal, small);
				me.fontSizeLeftS(small, small, small, small, small, small);
				me.fontSizeRight(normal, small, small, small, normal, small);
				me.fontSizeRightS(small, small, small, small, small, small);
				me.fontSizeCenter(small, small, small, small, small, normal);
				me.fontSizeCenterS(normal, small, small, small, small, small);
				
				me.colorLeft("blu", "wht", "blu", "wht", "wht", "blu");
				me.colorLeftS("wht", "wht", "wht", "wht", "wht", "wht");
				me.colorLeftArrow("wht", "wht", "wht", "wht", "wht", "wht");
				me.colorRight("mag", "blu", "blu", "blu", "grn", "grn");
				me.colorRightS("wht", "wht", "wht", "wht", "wht", "wht");
				me.colorRightArrow("wht", "wht", "wht", "wht", "wht", "wht");
				me.colorCenter("grn", "wht", "wht", "wht", "wht", "grn");
				me.colorCenterS("wht", "wht", "wht", "wht", "wht", "wht");
				
				pageSwitch[i].setBoolValue(1);
			}
			
			if (cruiseSet.getValue() == 1 and page != "PROGDES") {
				if (getprop("/it-autoflight/input/alt") > cruiseFL_prog.getValue() * 100) {
					me["Simple_L1S"].setText(sprintf("%s", "FL" ~ getprop("/it-autoflight/input/alt") / 100));
				} else {
					me["Simple_L1S"].setText(sprintf("%s", "FL" ~ cruiseFL_prog.getValue()));
				}
			} else {
				me["Simple_L1S"].setText("----");
			}
			me["Simple_L2S"].setText(" REPORT");
			if (page == "PROGCRZ") {
				me["Simple_L3S"].setText(" -----.--/-----.--");
				#me["Simple_R3S"].setText("AGN *"); #Add when implement cruise phase
				me["PROG_UPDATES"].hide();
			} else {
				me["PROG_UPDATES"].show();
				me["Simple_L3S"].setText("  [    ]");
			}
			me["Simple_L4S"].setText(" ---g /----.-");
			me["Simple_L5S"].setText(" GPS");
			me["Simple_L6S"].setText("----");
			me["Simple_L1SS"].setText(" CRZ");
			me["Simple_L3SS"].setText(" UPDATE AT");
			me["Simple_L4SS"].setText("  BRG /DIST");
			me["Simple_L5SS"].setText(" PREDICTIVE");
			me["Simple_L6SS"].setText("REQUIRED");
			me["Simple_R1S"].setText("FL398");
			me["Simple_R2S"].setText("VDEV = + 750 FT");
			me["Simple_R4S"].setText("[    ]");
			me["Simple_R5S"].setText("GPS PRIMARY");
			me["Simple_R6S"].setText("----");
			me["Simple_R1SS"].setText("REC MAX ");
			me["Simple_R6SS"].setText("ESTIMATED");
			me["Simple_C1S"].setText("----");
			me["Simple_C1SS"].setText("OPT");
			me["Simple_C3SS"].setText("CONFIRM UPDATE AT");
			me["Simple_C4S"].setText("   TO");
			me["Simple_C6SS"].setText("ACCUR");
			me["Simple_C6S"].setText("HIGH");
			
		} else if (page == "PERFTO") {
			if (!pageSwitch[i].getBoolValue()) {
				me["SimpleS"].show();
				me["Simple_CenterS"].show();
				me["FPLNS"].hide();
				me["DIRTO_TMPY_groupS"].hide();
				me["INITAS"].hide();
				me["IRSINITS"].hide();
				me["INITBS"].hide();
				me["FUELPREDS"].hide();
				me["PROGS"].hide();
				me["PERFTOS"].show();
				me["arrowsDepArrS"].hide();
				me["PERFAPPRS"].hide();
				me["PERFGAS"].hide();
				me["Simple_TitleS"].show();
				me["Simple_TitleS"].setText("TAKE OFF");
				me["Simple_PageNumS"].setText("X/X");
				me["Simple_PageNumS"].hide();
				me["ArrowLeftS"].hide();
				me["ArrowRightS"].hide();
				
				me.showLeft(1, 1, 1, 1, 1, 1);
				me["Simple_L0SS"].hide();
				me.showLeftS(1, 1, 1, 1, 1, 1);
				me.showLeftArrow(-1, -1, -1, -1, -1, 1);
				me.showRight(-1, 1, 1, 1, 1, 1);
				me.showRightS(-1, 1, 1, 1, 1, 1);
				me.showRightArrow(-1, -1, -1, -1, -1, 1);
				me.showCenter(1, 1, 1, -1, -1, -1);
				me["Simple_C3BS"].hide();
				me["Simple_C4BS"].hide();
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
			
			me["Simple_L1S"].setText(sprintf("%3.0f", v1.getValue()));
			me["Simple_L2S"].setText(sprintf("%3.0f", vr.getValue()));
			me["Simple_L3S"].setText(sprintf("%3.0f", v2.getValue()));
			me["Simple_L4S"].setText(sprintf("%3.0f", fmgc.FMGCInternal.transAlt));
			me["Simple_L5S"].setText(sprintf("%3.0f", clbReducFt.getValue()) ~ sprintf("/%3.0f", reducFt.getValue()));
			me["Simple_L6S"].setText(" TO DATA");
			me["Simple_L1SS"].setText(" V1");
			me["Simple_L2SS"].setText(" VR");
			me["Simple_L3SS"].setText(" V2");
			me["Simple_L4SS"].setText("TRANS ALT");
			me["Simple_L5SS"].setText("THR RED/ACC");
			me["Simple_L6SS"].setText(" UPLINK");
			me["Simple_R2S"].setText("[    ]  ");
			me["Simple_R5S"].setText(sprintf("%3.0f", engOutAcc.getValue()));
			me["Simple_R6S"].setText("PHASE ");
			me["Simple_R1SS"].setText("RWY ");
			me["Simple_R2SS"].setText("TO SHIFT ");
			me["Simple_R3SS"].setText("FLAPS/THS");
			me["Simple_R4SS"].setText("FLEX TO TEMP");
			me["Simple_R5SS"].setText("ENG OUT ACC");
			me["Simple_R6SS"].setText("NEXT ");
			
			if (fmgc.FMGCInternal.transAltSet) {
				me["Simple_L4S"].setFontSize(normal);
			} else {
				me["Simple_L4S"].setFontSize(small);
			}
			
			if (getprop("/FMGC/status/phase") == 0 or getprop("/FMGC/status/phase") == 7) {
				me["Simple_L6_ArrowS"].show(); 
				me["Simple_L6S"].show();
				me["Simple_L6SS"].show();
			} else {
				me["Simple_L6_ArrowS"].hide(); 
				me["Simple_L6S"].hide();
				me["Simple_L6SS"].hide();
			}
			
			if (getprop("/FMGC/status/phase") == 1) {
				me["Simple_TitleS"].setColor(0.0509,0.7529,0.2941);
			} else {
				me["Simple_TitleS"].setColor(1, 1, 1);
			}
			
			if (fmgc.flightPlanController.flightplans[2].departure_runway != nil) {
				me["Simple_TitleS"].setText(sprintf("TAKE OFF RWY %s", fmgc.flightPlanController.flightplans[2].departure_runway.id));
			} else {
				me["Simple_TitleS"].setText("TAKE OFF");
			}
			
			if (v1Set.getValue() == 1) {
				me["PERFTO_V1S"].hide();
				me["Simple_L1S"].show();
			} else {
				me["PERFTO_V1S"].show();
				me["Simple_L1S"].hide();
			}
			if (vrSet.getValue() == 1) {
				me["PERFTO_VRS"].hide();
				me["Simple_L2S"].show();
			} else {
				me["PERFTO_VRS"].show();
				me["Simple_L2S"].hide();
			}
			if (v2Set.getValue() == 1) {
				me["PERFTO_V2S"].hide();
				me["Simple_L3S"].show();
			} else {
				me["PERFTO_V2S"].show();
				me["Simple_L3S"].hide();
			}
			if (thrAccSet.getValue() == 1) {
				me["Simple_L5S"].setFontSize(normal);
			} else {
				me["Simple_L5S"].setFontSize(small);
			}
			
			if (flapTHSSet.getValue() == 1) {
				me["Simple_R3S"].setFont(default); 
				me["Simple_R3S"].setFontSize(normal);
				if (THSTO.getValue() >= 0) {
					me["Simple_R3S"].setText(sprintf("%s", flapTO.getValue()) ~ sprintf("/UP%2.1f", THSTO.getValue()));
				} else {
					me["Simple_R3S"].setText(sprintf("%s", flapTO.getValue()) ~ sprintf("/DN%2.1f", -1 * THSTO.getValue()));
				}
			} else {
				me["Simple_R3S"].setFont(symbol); 
				me["Simple_R3S"].setFontSize(small); 
				me["Simple_R3S"].setText("[  ]/[      ]");
			}
			if (flexSet.getValue() == 1) {
				me["Simple_R4S"].setFont(default); 
				me["Simple_R4S"].setFontSize(normal); 
				me["Simple_R4S"].setText(sprintf("%3.0f", flex.getValue()));
			} else {
				me["Simple_R4S"].setFont(symbol); 
				me["Simple_R4S"].setFontSize(small); 
				me["Simple_R4S"].setText("[   ]");
			}
			if (engOutAccSet.getValue() == 1) {
				me["Simple_R5S"].setFontSize(normal);
			} else {
				me["Simple_R5S"].setFontSize(small);
			}
			
			if (zfwSet.getValue() == 1 and blockSet.getValue() == 1) {
				me["Simple_C1S"].setText(sprintf("%3.0f", getprop("/FMGC/internal/computed-speeds/flap2_to")));
				me["Simple_C2S"].setText(sprintf("%3.0f", getprop("/FMGC/internal/computed-speeds/slat_to")));
				me["Simple_C3S"].setText(sprintf("%3.0f", getprop("/FMGC/internal/computed-speeds/clean_to")));
			} else {
				me["Simple_C1S"].setText(" ---");
				me["Simple_C2S"].setText(" ---");
				me["Simple_C3S"].setText(" ---");
			}
			
			me["Simple_C1SS"].setText("FLP RETR");
			me["Simple_C2SS"].setText("SLT RETR");
			me["Simple_C3SS"].setText("CLEAN  ");
		} else if (page == "PERFCLB") {
			if (!pageSwitch[i].getBoolValue()) {
				me["SimpleS"].show();
				me["Simple_CenterS"].show();
				me["FPLNS"].hide();
				me["DIRTO_TMPY_groupS"].hide();
				me["INITAS"].hide();
				me["IRSINITS"].hide();
				me["INITBS"].hide();
				me["FUELPREDS"].hide();
				me["PROGS"].hide();
				me["PERFTOS"].hide();
				me["arrowsDepArrS"].hide();
				me["PERFAPPRS"].hide();
				me["PERFGAS"].hide();
				me["Simple_TitleS"].show();
				me["Simple_TitleS"].setText("CLB");
				me["Simple_TitleS"].setColor(1, 1, 1);
				me["Simple_PageNumS"].setText("X/X");
				me["Simple_PageNumS"].hide();
				me["ArrowLeftS"].hide();
				me["ArrowRightS"].hide();
				
				me.showLeft(1, 1, 1, 1, 1, 1);
				me["Simple_L0SS"].hide();
				me.showLeftS(1, 1, 1, 1, 1, 1);
				me.showLeftArrow(-1, -1, -1, -1, 1, 1);
				me.showRight(-1, 1, 1, 1, -1, 1);
				me.showRightS(-1, -1, 1, -1, 1, 1);
				me.showRightArrow(-1, -1, -1, -1, -1, 1);
				me.showCenter(-1, 1, 1, 1, -1, -1);
				me["Simple_C3BS"].hide();
				me["Simple_C4BS"].hide();
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
			
			if (getprop("/FMGC/status/phase") == 2) {
				me["Simple_TitleS"].setColor(0.0509,0.7529,0.2941);
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
					me["Simple_L4SS"].setText(" SELECTED");
					me.showLeft(0, 0, 0, 1, 0, 0);
					me.showLeftS(0, 0, 0, 1, 0, 0);
				}
				
				if (activate_once.getValue() == 0 and activate_twice.getValue() == 0) {
					me["Simple_L6SS"].setText(" ACTIVATE");
					me["Simple_L6S"].setText(" APPR PHASE");
					me.colorLeft("ack", "ack", "ack", "ack", "ack", "blu");
					me.colorLeftS("ack", "ack", "ack", "ack", "ack", "blu");
					me.colorLeftArrow("ack", "ack", "ack", "ack", "ack", "blu");
				} else if (activate_once.getValue() == 1 and activate_twice.getValue() == 0) {
					me["Simple_L6SS"].setText(" CONFIRM");
					me["Simple_L6S"].setText(" APPR PHASE");
					me.colorLeft("ack", "ack", "ack", "ack", "ack", "amb");
					me.colorLeftS("ack", "ack", "ack", "ack", "ack", "amb");
					me.colorLeftArrow("ack", "ack", "ack", "ack", "ack", "amb");
				} else if (getprop("/FMGC/status/phase") == 5) {
					me["Simple_L6SS"].setText("");
					me["Simple_L6S"].setText("");
					me.colorLeft("ack", "ack", "ack", "ack", "ack", "blu");
					me.colorLeftS("ack", "ack", "ack", "ack", "ack", "blu");
					me.colorLeftArrow("ack", "ack", "ack", "ack", "ack", "blu");
					me.showLeftArrow(0, 0, 0, 0, 0, -1);
				} else {
					setprop("/FMGC/internal/activate-once", 0);
					setprop("/FMGC/internal/activate-twice", 0);
				}
			} else {
				me["Simple_TitleS"].setColor(1, 1, 1);
				me.showLeft(0, 0, 0, 0, -1, 0);
				me.showLeftS(0, 0, 0, 0, -1, 0);
				me.showLeftArrow(0, 0, 0, 0, -1, 0);
				me.showRight(0, 0, 0, -1, 0, 0);
				me.showRightS(0, 0, 0, 0, -1, 0);
				me.showCenterS(0, 0, 0, 0, -1, 0);
				
				me.colorLeft("ack", "ack", "ack", "ack", "ack", "wht");
				me.colorLeftS("ack", "ack", "ack", "ack", "ack", "wht");
				me.colorLeftArrow("ack", "ack", "ack", "ack", "ack", "wht");
				
				me["Simple_L4SS"].setText(" PRESEL");
				me["Simple_L6SS"].setText(" PREV");
				me["Simple_L6S"].setText(" PHASE");	
			}
			
			me["Simple_L1SS"].setText("ACT MODE");
			if (managedSpeed.getValue() == 1) {
				me["Simple_L1S"].setText("MANAGED");
				me["Simple_L4S"].setText(" [    ]");
				me.fontLeft(0, 0, 0, symbol, 0, 0);
			} else {
				me["Simple_L1S"].setText("SELECTED");
				if (getprop("/it-autoflight/input/kts-mach")) {
					me["Simple_L4S"].setText(sprintf(" %3.3f", getprop("/it-autoflight/input/spd-mach")));
				} else {
					me["Simple_L4S"].setText(sprintf(" %s", int(getprop("/it-autoflight/input/spd-kts"))));
				}
				me.fontLeft(0, 0, 0, default, 0, 0);
			}		
			
			me["Simple_L2SS"].setText(" CI");
			if (costIndexSet.getValue() == 1) {
				me["Simple_L2S"].setColor(0.0901,0.6039,0.7176);
				me["Simple_L2S"].setText(sprintf(" %s", costIndex.getValue()));
			} else {
				me["Simple_L2S"].setColor(1,1,1);
				me["Simple_L2S"].setText(" ---");
			}
			
			me["Simple_L3SS"].setText(" MANAGED");
			if (getprop("/it-autoflight/input/kts-mach")) {
				me["Simple_L3S"].setText(sprintf(" %3.3f", getprop("/FMGC/internal/mng-spd")));
			} else {
				me["Simple_L3S"].setText(sprintf(" %s", int(getprop("/FMGC/internal/mng-spd"))));
			}
			
			me["Simple_L5SS"].setText(" EXPEDITE");
			me["Simple_L5S"].setText(" T/O PHASE");
			
			me["Simple_C2S"].setText("         PRED TO");
			me["Simple_R2S"].setText(sprintf("FL%s", getprop("/it-autoflight/input/alt") / 100));
			
			me["Simple_R3SS"].setText("DIST");
			me["Simple_R3S"].setText("---");
			
			me["Simple_R4S"].setText("---");
			me["Simple_R5SS"].setText("---");
			
			me["Simple_C3SS"].setText("UTC");
			me["Simple_C3S"].setText("----");
			me["Simple_C4S"].setText("----");
			me["Simple_C5SS"].setText("----");

			me["Simple_R6SS"].setText("NEXT ");
			me["Simple_R6S"].setText("PHASE ");
		} else if (page == "PERFCRZ") {
			if (!pageSwitch[i].getBoolValue()) {
				me["SimpleS"].show();
				me["Simple_CenterS"].show();
				me["FPLNS"].hide();
				me["DIRTO_TMPY_groupS"].hide();
				me["INITAS"].hide();
				me["IRSINITS"].hide();
				me["INITBS"].hide();
				me["FUELPREDS"].hide();
				me["PROGS"].hide();
				me["PERFTOS"].hide();
				me["arrowsDepArrS"].hide();
				me["PERFAPPRS"].hide();
				me["PERFGAS"].hide();
				me["Simple_TitleS"].show();
				me["Simple_TitleS"].setText("CRZ");
				me["Simple_TitleS"].setColor(1, 1, 1);
				me["Simple_PageNumS"].setText("X/X");
				me["Simple_PageNumS"].hide();
				me["ArrowLeftS"].hide();
				me["ArrowRightS"].hide();
				
				me.showLeft(1, 1, 1, 1, -1, 1);
				me["Simple_L0SS"].hide();
				me.showLeftS(1, 1, 1, 1, -1, 1);
				me.showLeftArrow(-1, -1, -1, -1, -1, 1);
				me.showRight(1, -1, -1, -1, 1, 1);
				me.showRightS(1, -1, -1, -1, 1, 1);
				me.showRightArrow(-1, -1, -1, -1, -1, 1);
				me.showCenter(1, -1, -1, -1, 1, -1);
				me["Simple_C3BS"].hide();
				me["Simple_C4BS"].hide();
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
			
			if (getprop("/FMGC/status/phase") == 3) {
				me["Simple_TitleS"].setColor(0.0509,0.7529,0.2941);

				if (managedSpeed.getValue() == 1) {
					me.showLeft(0, 0, 0, -1, 0, 0);
					me.showLeftS(0, 0, 0, -1, 0, 0);
				} else {
					me["Simple_L4SS"].setText(" SELECTED");
					me.showLeft(0, 0, 0, 1, 0, 0);
					me.showLeftS(0, 0, 0, 1, 0, 0);
				}
				
				if (activate_once.getValue() == 0 and activate_twice.getValue() == 0) {
					me["Simple_L6SS"].setText(" ACTIVATE");
					me["Simple_L6S"].setText(" APPR PHASE");
					me.colorLeft("ack", "ack", "ack", "ack", "ack", "blu");
					me.colorLeftS("ack", "ack", "ack", "ack", "ack", "blu");
					me.colorLeftArrow("ack", "ack", "ack", "ack", "ack", "blu");
				} else if (activate_once.getValue() == 1 and activate_twice.getValue() == 0) {
					me["Simple_L6SS"].setText(" CONFIRM");
					me["Simple_L6S"].setText(" APPR PHASE");
					me.colorLeft("ack", "ack", "ack", "ack", "ack", "amb");
					me.colorLeftS("ack", "ack", "ack", "ack", "ack", "amb");
					me.colorLeftArrow("ack", "ack", "ack", "ack", "ack", "amb");
				} else if (getprop("/FMGC/status/phase") == 5) {
					me["Simple_L6SS"].setText("");
					me["Simple_L6S"].setText("");
					me.colorLeft("ack", "ack", "ack", "ack", "ack", "blu");
					me.colorLeftS("ack", "ack", "ack", "ack", "ack", "blu");
					me.colorLeftArrow("ack", "ack", "ack", "ack", "ack", "blu");
					me.showLeftArrow(0, 0, 0, 0, 0, -1);
				} else {
					setprop("/FMGC/internal/activate-once", 0);
					setprop("/FMGC/internal/activate-twice", 0);
				}
			} else {
				me["Simple_TitleS"].setColor(1, 1, 1);
				
				me.colorLeft("ack", "ack", "ack", "ack", "ack", "wht");
				me.colorLeftS("ack", "ack", "ack", "ack", "ack", "wht");
				me.colorLeftArrow("ack", "ack", "ack", "ack", "ack", "wht");
				
				me["Simple_L4SS"].setText(" PRESEL");
				me["Simple_L6SS"].setText(" PREV");
				me["Simple_L6S"].setText(" PHASE");	
			}
			
			me["Simple_L1SS"].setText("ACT MODE");
			if (managedSpeed.getValue() == 1) {
				me["Simple_L1S"].setText("MANAGED");
				me["Simple_L4S"].setText(" [    ]");
				me.fontLeft(0, 0, 0, symbol, 0, 0);
			} else {
				me["Simple_L1S"].setText("SELECTED");
				if (getprop("/it-autoflight/input/kts-mach")) {
					me["Simple_L4S"].setText(sprintf(" %3.3f", getprop("/it-autoflight/input/spd-mach")));
				} else {
					me["Simple_L4S"].setText(sprintf(" %s", int(getprop("/it-autoflight/input/spd-kts"))));
				}
				me.fontLeft(0, 0, 0, default, 0, 0);
			}
			
			if (costIndexSet.getValue() == 1) {
				me["Simple_L2S"].setColor(0.0901,0.6039,0.7176);
				me["Simple_L2S"].setText(sprintf(" %s", costIndex.getValue()));
			} else {
				me["Simple_L2S"].setColor(1,1,1);
				me["Simple_L2S"].setText(" ---");
			}
			
			me["Simple_L1SS"].setText("ACT MODE");
			me["Simple_L2SS"].setText(" CI");
			
			me["Simple_L3SS"].setText(" MANAGED");
			if (getprop("/it-autoflight/input/kts-mach")) {
				me["Simple_L3S"].setText(sprintf(" %3.3f", getprop("/FMGC/internal/mng-spd")));
			} else {
				me["Simple_L3S"].setText(sprintf(" %s", int(getprop("/FMGC/internal/mng-spd"))));
			}
			
			me["Simple_R1SS"].setText("DEST EFOB");
			me["Simple_R1S"].setText("---");
			
			me["Simple_R5SS"].setText("DES CABIN RATE");
			me["Simple_C5S"].setText("             -350");
			me["Simple_R5S"].setText("FT/MIN");
			
			me["Simple_C1SS"].setText("UTC");
			me["Simple_C1S"].setText("---");
			
			me["Simple_R6SS"].setText("NEXT ");
			me["Simple_R6S"].setText("PHASE ");
			
		} else if (page == "PERFDES") {
			if (!pageSwitch[i].getBoolValue()) {
				me["SimpleS"].show();
				me["Simple_CenterS"].show();
				me["FPLNS"].hide();
				me["DIRTO_TMPY_groupS"].hide();
				me["INITAS"].hide();
				me["IRSINITS"].hide();
				me["INITBS"].hide();
				me["FUELPREDS"].hide();
				me["PROGS"].hide();
				me["PERFTOS"].hide();
				me["arrowsDepArrS"].hide();
				me["PERFAPPRS"].hide();
				me["PERFGAS"].hide();
				me["Simple_TitleS"].show();
				me["Simple_TitleS"].setText("DES");
				me["Simple_TitleS"].setColor(1, 1, 1);
				me["Simple_PageNumS"].setText("X/X");
				me["Simple_PageNumS"].hide();
				me["ArrowLeftS"].hide();
				me["ArrowRightS"].hide();
				
				me.showLeft(1, 1, 1, 1, 1, 1);
				me["Simple_L0SS"].hide();
				me.showLeftS(1, 1, 1, 1, -1, 1);
				me.showLeftArrow(-1, -1, -1, -1, -1, 1);
				me.showRight(1, 1, -1, 1, -1, 1);
				me.showRightS(1, -1, 1, -1, -1, 1);
				me.showRightArrow(-1, -1, -1, -1, -1, 1);
				me.showCenter(1, 1, -1, 1, 1, -1);
				me["Simple_C3BS"].hide();
				me["Simple_C4BS"].hide();
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
			
			if (getprop("/FMGC/status/phase") == 4) {
				me["Simple_TitleS"].setColor(0.0509,0.7529,0.2941);
				me.showLeft(0, 0, 0, 0, 1, 0);
				me.showRight(0, 1, 0, 1, 0, 0);
				me.showRightS(0, 0, 1, 0, 0, 0);
				me.showCenter(0, 1, 0, 1, 1, 0);
				me.showCenterS(0, 0, 1, 0, 0, 0);

				if (managedSpeed.getValue() == 1) {
					me.showLeft(0, 0, 0, -1, 0, 0);
					me.showLeftS(0, 0, 0, -1, 0, 0);
				} else {
					me["Simple_L4SS"].setText(" SELECTED");
					me.showLeft(0, 0, 0, 1, 0, 0);
					me.showLeftS(0, 0, 0, 1, 0, 0);
				}
				
				if (activate_once.getValue() == 0 and activate_twice.getValue() == 0) {
					me["Simple_L6SS"].setText(" ACTIVATE");
					me["Simple_L6S"].setText(" APPR PHASE");
					me.colorLeft("ack", "ack", "ack", "ack", "ack", "blu");
					me.colorLeftS("ack", "ack", "ack", "ack", "ack", "blu");
					me.colorLeftArrow("ack", "ack", "ack", "ack", "ack", "blu");
				} else if (activate_once.getValue() == 1 and activate_twice.getValue() == 0) {
					me["Simple_L6SS"].setText(" CONFIRM");
					me["Simple_L6S"].setText(" APPR PHASE");
					me.colorLeft("ack", "ack", "ack", "ack", "ack", "amb");
					me.colorLeftS("ack", "ack", "ack", "ack", "ack", "amb");
					me.colorLeftArrow("ack", "ack", "ack", "ack", "ack", "amb");
				} else if (getprop("/FMGC/status/phase") == 5) {
					me["Simple_L6SS"].setText("");
					me["Simple_L6S"].setText("");
					me.colorLeft("ack", "ack", "ack", "ack", "ack", "blu");
					me.colorLeftS("ack", "ack", "ack", "ack", "ack", "blu");
					me.colorLeftArrow("ack", "ack", "ack", "ack", "ack", "blu");
					me.showLeftArrow(0, 0, 0, 0, 0, -1);
				} else {
					setprop("/FMGC/internal/activate-once", 0);
					setprop("/FMGC/internal/activate-twice", 0);
				}
			} else {
				me["Simple_TitleS"].setColor(1, 1, 1);
				me.showLeft(0, 0, 0, 0, -1, 0);
				me.showRight(0, -1, 0, -1, 0, 0);
				me.showRightS(0, 0, -1, 0, 0, 0);
				me.showCenter(0, -1, 0, -1, -1, 0);
				me.showCenterS(0, 0, -1, 0, 0, 0);
				
				me.colorLeft("ack", "ack", "ack", "ack", "ack", "wht");
				me.colorLeftS("ack", "ack", "ack", "ack", "ack", "wht");
				me.colorLeftArrow("ack", "ack", "ack", "ack", "ack", "wht");
				
				me["Simple_L4SS"].setText(" PRESEL");
				me["Simple_L6SS"].setText(" PREV");
				me["Simple_L6S"].setText(" PHASE");	
			}
			
			me["Simple_L1SS"].setText("ACT MODE");
			if (managedSpeed.getValue() == 1) {
				me["Simple_L1S"].setText("MANAGED");
				me["Simple_L4S"].setText(" [    ]");
				me.fontLeft(0, 0, 0, symbol, 0, 0);
			} else {
				me["Simple_L1S"].setText("SELECTED");
				if (getprop("/it-autoflight/input/kts-mach")) {
					me["Simple_L4S"].setText(sprintf(" %3.3f", getprop("/it-autoflight/input/spd-mach")));
				} else {
					me["Simple_L4S"].setText(sprintf(" %3.0f", getprop("/it-autoflight/input/spd-kts")));
				}
				me.fontLeft(0, 0, 0, default, 0, 0);
			}
			
			if (costIndexSet.getValue() == 1) {
				me["Simple_L2S"].setColor(0.0901,0.6039,0.7176);
				me["Simple_L2S"].setText(sprintf(" %2.0f", costIndex.getValue()));
			} else {
				me["Simple_L2S"].setColor(1,1,1);
				me["Simple_L2S"].setText(" ---");
			}
			
			me["Simple_L1SS"].setText("ACT MODE");
			me["Simple_L2SS"].setText(" CI");
			
			me["Simple_L3SS"].setText(" MANAGED");
			if (getprop("/it-autoflight/input/kts-mach")) {
				me["Simple_L3S"].setText(sprintf(" %3.3f", getprop("/FMGC/internal/mng-spd")));
			} else {
				me["Simple_L3S"].setText(sprintf(" %3.0f", getprop("/FMGC/internal/mng-spd")));
			}
			
			me["Simple_L5S"].setText(" EXPEDITE");
			
			me["Simple_R1SS"].setText("DEST EFOB");
			me["Simple_R1S"].setText("---");
			
			me["Simple_C2S"].setText("         PRED TO");
			me["Simple_R2S"].setText(sprintf("FL%3.0f", getprop("/it-autoflight/input/alt") / 100));
			
			me["Simple_R3SS"].setText("DIST");
			me["Simple_R3S"].setText("---");
			
			me["Simple_R4S"].setText("---");
			me["Simple_R5SS"].setText("---");
			
			me["Simple_C1SS"].setText("UTC");
			me["Simple_C1S"].setText("---");
			me["Simple_C3SS"].setText("UTC");
			me["Simple_C3S"].setText("----");
			me["Simple_C4S"].setText("----");
			me["Simple_C5S"].setText("----");

			me["Simple_R6SS"].setText("NEXT ");
			me["Simple_R6S"].setText("PHASE ");
		} else if (page == "PERFAPPR") {
			if (!pageSwitch[i].getBoolValue()) {
				me["SimpleS"].show();
				me["Simple_CenterS"].show();
				me["FPLNS"].hide();
				me["DIRTO_TMPY_groupS"].hide();
				me["INITAS"].hide();
				me["IRSINITS"].hide();
				me["INITBS"].hide();
				me["FUELPREDS"].hide();
				me["PROGS"].hide();
				me["PERFTOS"].hide();
				me["arrowsDepArrS"].hide();
				me["PERFAPPRS"].show();
				me["PERFGAS"].hide();
				me["Simple_TitleS"].show();
				me["Simple_TitleS"].setText("APPR");
				me["Simple_TitleS"].setColor(1, 1, 1);
				me["Simple_PageNumS"].setText("X/X");
				me["Simple_PageNumS"].hide();
				me["ArrowLeftS"].hide();
				me["ArrowRightS"].hide();
				
				me.showLeft(1, 1, 1, 1, 1, 1);
				me["Simple_L0SS"].show();
				me.showLeftS(1, 1, 1, 1, 1, 1);
				me.showLeftArrow(-1, -1, -1, -1, -1, 1);
				me.showRight(1, 1, 1, 1, 1, 1);
				me.showRightS(1, 1, 1, 1, -1, 1);
				me.showRightArrow(-1, -1, -1, -1, -1, 1);
				me.showCenter(1, 1, 1, -1, 1, -1);
				me["Simple_C3BS"].hide();
				me["Simple_C4BS"].hide();
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
			
			if (getprop("/FMGC/status/phase") == 5) {
				me["Simple_TitleS"].setColor(0.0509,0.7529,0.2941);
			} else {
				me["Simple_TitleS"].setColor(1, 1, 1);
			}
			
			me["Simple_L0SS"].setText("DEST");
			me["Simple_L1SS"].setText("QNH");
			if (dest_qnh.getValue() != -1) {
				if (dest_qnh.getValue() < 100) {
					me["Simple_L1S"].setText(sprintf("%4.2f", dest_qnh.getValue()));
				} else {
					me["Simple_L1S"].setText(sprintf("%4.0f", dest_qnh.getValue()));
				}
				me.fontLeft(default, 0, 0, 0, 0, 0);
			} else {
				me["Simple_L1S"].setText("[    ]  ");
				me.fontLeft(symbol, 0, 0, 0, 0, 0);
			}
			
			me["Simple_L2SS"].setText("TEMP");
			if (dest_temp.getValue() != -999) {
				me["Simple_L2S"].setText(sprintf("%3.0fg", dest_temp.getValue()));
			} else {
				me["Simple_L2S"].setText("---g");
			}
			
			me["Simple_L3SS"].setText("MAG WIND");
			if (dest_mag.getValue() != -1 and dest_wind.getValue() != -1) {
				me["Simple_L3S"].setText(sprintf("%03.0fg", dest_mag.getValue()) ~ sprintf("/%.0f", dest_wind.getValue()));
			} else {
				me["Simple_L3S"].setText("---g/---");;
			}
			
			me["Simple_L4SS"].setText("TRANS FL");
			me["Simple_L4S"].setText("FL" ~ sprintf("%2.0f", (fmgc.FMGCInternal.transAlt / 100)));
			
			if (fmgc.FMGCInternal.transAltSet) {
				me["Simple_L4S"].setFontSize(normal);
			} else {
				me["Simple_L4S"].setFontSize(small);
			}
			
			me["Simple_R1SS"].setText("FINAL");
			if (fmgc.flightPlanController.flightplans[2].destination_runway != nil) {
				me["Simple_R1S"].setText(sprintf("%s",fmgc.flightPlanController.flightplans[2].destination_runway.id));
				me["Simple_R1S"].setColor(GREEN);
			} else {
				me["Simple_R1S"].setText("--- ");
				me["Simple_R1S"].setColor(WHITE);
			}
			
			me["Simple_R2SS"].setText("BARO");
			if (getprop("/FMGC/internal/baro") != 99999) {
				me["Simple_R2S"].setText(sprintf("%.0f", getprop("/FMGC/internal/baro")));
				me.fontRight(0, default, 0, 0, 0, 0);
				me.fontSizeRight(0, normal, 0, 0, 0, 0);
			} else {
				me["Simple_R2S"].setText(" [    ]");
				me.fontRight(0, symbol, 0, 0, 0, 0);
				me.fontSizeRight(0, small, 0, 0, 0, 0);
			}
			
			me["Simple_R3SS"].setText("RADIO");
			if (getprop("/FMGC/internal/radio") != 99999) {
				me["Simple_R3S"].setText(sprintf("%.0f", getprop("/FMGC/internal/radio")));
				me.fontRight(0, 0, default, 0, 0, 0);
				me.fontSizeRight(0, 0, normal, 0, 0, 0);
			} else if (getprop("/FMGC/internal/radio-no")) {
				me["Simple_R3S"].setText("NO");
				me.fontRight(0, 0, default, 0, 0, 0);
				me.fontSizeRight(0, 0, normal, 0, 0, 0);
			} else {
				me["Simple_R3S"].setText(" [    ]");
				me.fontRight(0, 0, symbol, 0, 0, 0);
				me.fontSizeRight(0, 0, small, 0, 0, 0);
			}
			
			me["Simple_R4SS"].setText("LDG CONF  ");
			me["Simple_R4S"].setText("CONF3  ");
			me["Simple_R5S"].setText("FULL  ");
			if (ldg_config_3_set.getValue() == 1 and ldg_config_f_set.getValue() == 0) {
				me["PERFAPPR_LDG_3S"].hide();
				me["PERFAPPR_LDG_FS"].show();
				me.fontSizeRight(0, 0, 0, normal, small, 0);
			} else {
				me["PERFAPPR_LDG_3S"].show();
				me["PERFAPPR_LDG_FS"].hide();
				me.fontSizeRight(0, 0, 0, small, normal, 0);
			}

			me["Simple_L6SS"].setText(" PREV");
			me["Simple_L6S"].setText(" PHASE");
			
			me["Simple_R6SS"].setText("NEXT ");
			me["Simple_R6S"].setText("PHASE ");
			
			me["Simple_L5SS"].setText(" VAPP");
			if (zfwSet.getValue() == 1 and blockSet.getValue() == 1) {
				me["Simple_C1S"].setText(sprintf("%3.0f", getprop("/FMGC/internal/computed-speeds/flap2_appr")));
				me["Simple_C2S"].setText(sprintf("%3.0f", getprop("/FMGC/internal/computed-speeds/slat_appr")));
				me["Simple_C3S"].setText(sprintf("%3.0f", getprop("/FMGC/internal/computed-speeds/clean_appr")));
				me["Simple_C5S"].setText(sprintf("%3.0f", getprop("/FMGC/internal/computed-speeds/vls_appr")));
				me["Simple_L5S"].setText(sprintf("%3.0f", getprop("/FMGC/internal/computed-speeds/vapp_appr")));
				me.fontLeft(0, 0, 0, 0, default, 0);
				if (vapp_speed_set.getValue()) {
					me.fontSizeLeft(0, 0, 0, 0, normal, 0);
				} else {
					me.fontSizeLeft(0, 0, 0, 0, small, 0);
				}
			} else {
				me["Simple_C1S"].setText(" ---");
				me["Simple_C2S"].setText(" ---");
				me["Simple_C3S"].setText(" ---");
				me["Simple_C5S"].setText(" ---");
				if (vapp_speed_set.getValue()) {
					me["Simple_L5S"].setText(sprintf("%3.0f", getprop("/FMGC/internal/computed-speeds/vapp_appr")));
					me.fontLeft(0, 0, 0, 0, default, 0);
					me.fontSizeLeft(0, 0, 0, 0, normal, 0);
				} else {
					me["Simple_L5S"].setText("[    ]  ");
					me.fontLeft(0, 0, 0, 0, symbol, 0);
					me.fontSizeLeft(0, 0, 0, 0, small, 0);
				}
			}
			
			me["Simple_C1SS"].setText("FLP RETR");
			me["Simple_C2SS"].setText("SLT RETR");
			me["Simple_C3SS"].setText("CLEAN  ");
			me["Simple_C5SS"].setText("VLS   ");
		} else if (page == "PERFGA") {
			if (!pageSwitch[i].getBoolValue()) {
				me["SimpleS"].show();
				me["Simple_CenterS"].show();
				me["FPLNS"].hide();
				me["DIRTO_TMPY_groupS"].hide();
				me["INITAS"].hide();
				me["IRSINITS"].hide();
				me["INITBS"].hide();
				me["FUELPREDS"].hide();
				me["PROGS"].hide();
				me["PERFTOS"].hide();
				me["arrowsDepArrS"].hide();
				me["PERFAPPRS"].hide();
				me["PERFGAS"].show();
				me["Simple_TitleS"].show();
				me["Simple_TitleS"].setText("GO AROUND");
				me["Simple_TitleS"].setColor(1, 1, 1);
				me["Simple_PageNumS"].setText("X/X");
				me["Simple_PageNumS"].hide();
				me["ArrowLeftS"].hide();
				me["ArrowRightS"].hide();
				
				me.showLeft(-1, -1, -1, -1, 1, 1);
				me["Simple_L0SS"].hide();
				me.showLeftS(-1, -1, -1, -1, 1, 1);
				me.showLeftArrow(-1, -1, -1, -1, -1, 1);
				me.showRight(-1, -1, -1, -1, 1, -1);
				me.showRightS(-1, -1, -1, -1, 1, -1);
				me.showRightArrow(-1, -1, -1, -1, -1, -1);
				me.showCenter(1, 1, 1, -1, -1, -1);
				me["Simple_C3BS"].hide();
				me["Simple_C4BS"].hide();
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
			
			if (getprop("/FMGC/status/phase") == 6) {
				me["Simple_TitleS"].setColor(0.0509,0.7529,0.2941);
			} else {
				me["Simple_TitleS"].setColor(1, 1, 1);
			}
			
			if (thrAccSet.getValue() == 1) {
				me["Simple_L5S"].setFontSize(normal);
			} else {
				me["Simple_L5S"].setFontSize(small);
			}
			if (engOutAccSet.getValue() == 1) {
				me["Simple_R5S"].setFontSize(normal);
			} else {
				me["Simple_R5S"].setFontSize(small);
			}
			
			me["Simple_L5S"].setText(sprintf("%3.0f", clbReducFt.getValue()) ~ sprintf("/%3.0f", reducFt.getValue()));
			me["Simple_L6S"].setText(" PHASE");
			me["Simple_L5SS"].setText("THR RED/ACC");
			me["Simple_L6SS"].setText(" PREV");
			me["Simple_R5S"].setText(sprintf("%3.0f", engOutAcc.getValue()));
			me["Simple_R5SS"].setText("ENG OUT ACC");
			
			if (zfwSet.getValue() == 1 and blockSet.getValue() == 1) {
				me["Simple_C1S"].setText(sprintf("%3.0f", getprop("/FMGC/internal/computed-speeds/flap2_appr")));
				me["Simple_C2S"].setText(sprintf("%3.0f", getprop("/FMGC/internal/computed-speeds/slat_appr")));
				me["Simple_C3S"].setText(sprintf("%3.0f", getprop("/FMGC/internal/computed-speeds/clean_appr")));
			} else {
				me["Simple_C1S"].setText(" ---");
				me["Simple_C2S"].setText(" ---");
				me["Simple_C3S"].setText(" ---");
			}
			
			me["Simple_C1SS"].setText("FLP RETR");
			me["Simple_C2SS"].setText("SLT RETR");
			me["Simple_C3SS"].setText("CLEAN  ");
		} else if (page == "LATREV") {
			if (!pageSwitch[i].getBoolValue()) {
				me["SimpleS"].show();
				me["Simple_CenterS"].show();
				me["FPLNS"].hide();
				me["DIRTO_TMPY_groupS"].hide();
				me["INITAS"].hide();
				me["IRSINITS"].hide();
				me["INITBS"].hide();
				me["FUELPREDS"].hide();
				me["PROGS"].hide();
				me["PERFTOS"].hide();
				me["arrowsDepArrS"].hide();
				me["Simple_PageNumS"].setText("X/X");
				me["Simple_PageNumS"].hide();
				me["Simple_TitleS"].show();
				me["ArrowLeftS"].hide();
				me["ArrowRightS"].hide();
				
				me["Simple_L0SS"].hide();
				me["Simple_C3BS"].hide();
				me["Simple_C4BS"].hide();
				
				me.fontLeft(default, default, default, default, default, default);
				me.fontLeftS(default, default, default, default, default, default);
				me.fontRight(default, default, default, default, default, default);
				me.fontRightS(default, default, default, default, default, default);
				
				me.fontSizeLeft(normal, normal, normal, normal, normal, normal);
				me.fontSizeRight(normal, normal, normal, normal, normal, normal);
				
				me.colorLeftS("wht", "wht", "wht", "wht", "wht", "wht");
				me.colorLeftArrow("wht", "wht", "wht", "wht", "wht", "wht");
				me.colorRightS("wht", "wht", "wht", "wht", "wht", "wht");
				me.colorRightArrow("wht", "wht", "wht", "wht", "wht", "wht");
				
				
				if (myLatRev[i] != nil) {
					me["Simple_TitleS"].setText(sprintf("%s", myLatRev[i].title[0] ~ myLatRev[i].title[1] ~ myLatRev[i].title[2]));
					
					if (myLatRev[i].subtitle[0] != nil) {
						me["Simple_CenterS"].show();
						me["Simple_C1SS"].setText(sprintf("%s", myLatRev[i].subtitle[0] ~ "/" ~ myLatRev[i].subtitle[1]));
						me["Simple_C1SS"].show();
						me["Simple_C1S"].hide();
						me["Simple_C2S"].hide();
						me["Simple_C3S"].hide();
						me["Simple_C4S"].hide();
						me["Simple_C5S"].hide();
						me["Simple_C6S"].hide();
						me["Simple_C2SS"].hide();
						me["Simple_C3SS"].hide();
						me["Simple_C4SS"].hide();
						me["Simple_C5SS"].hide();
						me["Simple_C6SS"].hide();
					} else {
						me["Simple_CenterS"].hide();
					}
					forindex (var matrixArrow; myLatRev[i].arrowsMatrix) {
						if (matrixArrow == 0) { 
							var sign = "L"; 
						} else { 
							var sign = "R"; 
						}
						forindex (var item; myLatRev[i].arrowsMatrix[matrixArrow]) {
							if (myLatRev[i].arrowsMatrix[matrixArrow][item] == 1) {
								me["Simple_" ~ sign ~ (item + 1) ~ "_ArrowS"].show();
							} else {
								me["Simple_" ~ sign ~ (item + 1) ~ "_ArrowS"].hide();
							}
						}
					}
					me.colorLeftArrow(myLatRev[i].arrowsColour[0][0],myLatRev[i].arrowsColour[0][1],myLatRev[i].arrowsColour[0][2],myLatRev[i].arrowsColour[0][3],myLatRev[i].arrowsColour[0][4],myLatRev[i].arrowsColour[0][5]);
					
					
					forindex (var matrixFont; myLatRev[i].fontMatrix) {
						if (matrixFont == 0) { 
							var sign = "L"; 
						} else { 
							var sign = "R"; 
						}
						forindex (var item; myLatRev[i].fontMatrix[matrixFont]) {
							if (myLatRev[i].fontMatrix[matrixFont][item] == 1) {
								me["Simple_" ~ sign ~ (item + 1)].setFont(symbol);
								me["Simple_" ~ sign ~ (item + 1)].setFontSize(small);
							} else {
								me["Simple_" ~ sign ~ (item + 1)].setFont(default);
								me["Simple_" ~ sign ~ (item + 1)].setFontSize(normal);
							}
						}
					}
					
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
				me["SimpleS"].show();
				me["Simple_CenterS"].show();
				me["FPLNS"].hide();
				me["DIRTO_TMPY_groupS"].hide();
				me["INITAS"].hide();
				me["IRSINITS"].hide();
				me["INITBS"].hide();
				me["FUELPREDS"].hide();
				me["PROGS"].hide();
				me["PERFTOS"].hide();
				me["arrowsDepArrS"].hide();
				me["Simple_PageNumS"].setText("X/X");
				me["Simple_PageNumS"].hide();
				me["Simple_TitleS"].show();
				me["ArrowLeftS"].hide();
				me["ArrowRightS"].hide();
				
				me["Simple_L0SS"].hide();
				me["Simple_C3BS"].hide();
				me["Simple_C4BS"].hide();
				
				me.fontLeft(default, default, default, default, default, default);
				me.fontLeftS(default, default, default, default, default, default);
				me.fontRight(default, default, default, default, default, default);
				me.fontRightS(default, default, default, default, default, default);
				
				me.fontSizeLeft(normal, normal, normal, normal, normal, normal);
				me.fontSizeRight(normal, normal, normal, normal, normal, normal);
				
				me.colorLeftS("wht", "wht", "wht", "wht", "wht", "wht");
				me.colorLeftArrow("wht", "wht", "wht", "wht", "wht", "wht");
				me.colorRightS("wht", "wht", "wht", "wht", "wht", "wht");
				me.colorRightArrow("wht", "wht", "wht", "wht", "wht", "wht");
				
				
				if (myVertRev[i] != nil) {
					me["Simple_TitleS"].setText(sprintf("%s", myVertRev[i].title[0] ~ myVertRev[i].title[1] ~ myVertRev[i].title[2]));
					
					if (myVertRev[i].subtitle[0] != nil) {
						me["Simple_CenterS"].show();
						me["Simple_C1SS"].setText(sprintf("%s", myVertRev[i].subtitle[0] ~ "/" ~ myVertRev[i].subtitle[1]));
						me["Simple_C1SS"].show();
						me["Simple_C1S"].hide();
						me["Simple_C2S"].hide();
						me["Simple_C3S"].hide();
						me["Simple_C4S"].hide();
						me["Simple_C5S"].hide();
						me["Simple_C6S"].hide();
						me["Simple_C2SS"].hide();
						me["Simple_C3SS"].hide();
						me["Simple_C4SS"].hide();
						me["Simple_C5SS"].hide();
						me["Simple_C6SS"].hide();
					} else {
						me["Simple_CenterS"].hide();
					}
					forindex (var matrixArrow; myVertRev[i].arrowsMatrix) {
						if (matrixArrow == 0) { 
							var sign = "L"; 
						} else { 
							var sign = "R"; 
						}
						forindex (var item; myVertRev[i].arrowsMatrix[matrixArrow]) {
							if (myVertRev[i].arrowsMatrix[matrixArrow][item] == 1) {
								me["Simple_" ~ sign ~ (item + 1) ~ "_ArrowS"].show();
							} else {
								me["Simple_" ~ sign ~ (item + 1) ~ "_ArrowS"].hide();
							}
						}
					}
					me.colorLeftArrow(myVertRev[i].arrowsColour[0][0],myVertRev[i].arrowsColour[0][1],myVertRev[i].arrowsColour[0][2],myVertRev[i].arrowsColour[0][3],myVertRev[i].arrowsColour[0][4],myVertRev[i].arrowsColour[0][5]);
					
					
					forindex (var matrixFont; myVertRev[i].fontMatrix) {
						if (matrixFont == 0) { 
							var sign = "L"; 
						} else { 
							var sign = "R"; 
						}
						forindex (var item; myVertRev[i].fontMatrix[matrixFont]) {
							if (myVertRev[i].fontMatrix[matrixFont][item] == 1) {
								me["Simple_" ~ sign ~ (item + 1)].setFont(symbol);
								me["Simple_" ~ sign ~ (item + 1)].setFontSize(small);
							} else {
								me["Simple_" ~ sign ~ (item + 1)].setFont(default);
								me["Simple_" ~ sign ~ (item + 1)].setFontSize(normal);
							}
						}
					}
					
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
				me["SimpleS"].show();
				me["Simple_CenterS"].show();
				me["FPLNS"].hide();
				me["DIRTO_TMPY_groupS"].hide();
				me["INITAS"].hide();
				me["IRSINITS"].hide();
				me["INITBS"].hide();
				me["FUELPREDS"].hide();
				me["PROGS"].hide();
				me["PERFTOS"].hide();
				me["Simple_PageNumS"].setText("X/X");
				me["Simple_PageNumS"].hide();
				me["Simple_TitleS"].show();
				me["ArrowLeftS"].show();
				me["ArrowRightS"].show();
				me["arrowsDepArrS"].show();
				me["Simple_L1_ArrowS"].hide();
				me["Simple_L2_ArrowS"].hide();
				me["Simple_L3_ArrowS"].hide();
				me["Simple_L4_ArrowS"].hide();
				me["Simple_L5_ArrowS"].hide();
				me["Simple_L6_ArrowS"].show();
				me["Simple_R1_ArrowS"].hide();
				me["Simple_R2_ArrowS"].hide();
				me["Simple_R3_ArrowS"].hide();
				me["Simple_R4_ArrowS"].hide();
				me["Simple_R5_ArrowS"].hide();
				me["Simple_R6_ArrowS"].hide();
				
				me["Simple_L0SS"].hide();
				me["Simple_C3BS"].hide();
				me["Simple_C4BS"].hide();
				
				me.fontLeft(default, default, default, default, default, default);
				me.fontLeftS(default, default, default, default, default, default);
				me.fontRight(default, default, default, default, default, default);
				me.fontRightS(default, default, default, default, default, default);
				
				me.fontSizeLeft(normal, normal, normal, normal, normal, normal);
				me.fontSizeRight(normal, normal, normal, normal, normal, normal);
				
				me.colorLeftS("wht", "wht", "wht", "wht", "wht", "wht");
				me.colorRightS("wht", "wht", "wht", "wht", "wht", "wht");
				
				
				if (myDeparture[i] != nil) {
					me["Simple_TitleS"].setText(sprintf("%s", myDeparture[i].title[0] ~ myDeparture[i].title[1] ~ myDeparture[i].title[2]));
					
					forindex (var matrixArrow; myDeparture[i].arrowsMatrix) {
						if (matrixArrow == 0) { 
							var sign = "L"; 
						} else { 
							var sign = "R"; 
						}
						forindex (var item; myDeparture[i].arrowsMatrix[matrixArrow]) {
							if (item == 5) { 
								me["Simple_L6_ArrowS"].setColor(getprop("/MCDUC/colors/" ~ myDeparture[i].arrowsColour[0][5] ~ "/r"), getprop("/MCDUC/colors/" ~ myDeparture[i].arrowsColour[0][5] ~ "/g"), getprop("/MCDUC/colors/" ~ myDeparture[i].arrowsColour[0][5] ~ "/b"));
								continue;
							}
							if (myDeparture[i].arrowsMatrix[matrixArrow][item] == 1) {
								me["arrow" ~ (item + 1) ~ sign].show();
								me["arrow" ~ (item + 1) ~ sign].setColor(getprop("/MCDUC/colors/" ~ myDeparture[i].arrowsColour[matrixArrow][item] ~ "/r"), getprop("/MCDUC/colors/" ~ myDeparture[i].arrowsColour[matrixArrow][item] ~ "/g"), getprop("/MCDUC/colors/" ~ myDeparture[i].arrowsColour[matrixArrow][item] ~ "/b"));
							} else {
								me["arrow" ~ (item + 1) ~ sign].hide();
							}
						}
					}
					
					forindex (var matrixFont; myDeparture[i].fontMatrix) {
						if (matrixFont == 0) { 
							var sign = "L"; 
						} else { 
							var sign = "R"; 
						}
						forindex (var item; myDeparture[i].fontMatrix[matrixFont]) {
							if (myDeparture[i].fontMatrix[matrixFont][item] == 1) {
								me["Simple_" ~ sign ~ (item + 1)].setFont(symbol);
								me["Simple_" ~ sign ~ (item + 1)].setFontSize(small);
							} else {
								me["Simple_" ~ sign ~ (item + 1)].setFont(default);
								me["Simple_" ~ sign ~ (item + 1)].setFontSize(normal);
							}
						}
					}
					
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
					
					me["Simple_C6S"].hide();
					me["Simple_C6SS"].hide();
						
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
				me["SimpleS"].show();
				me["Simple_CenterS"].show();
				me["FPLNS"].hide();
				me["DIRTO_TMPY_groupS"].hide();
				me["INITAS"].hide();
				me["IRSINITS"].hide();
				me["INITBS"].hide();
				me["FUELPREDS"].hide();
				me["PROGS"].hide();
				me["PERFTOS"].hide();
				me["arrowsDepArrS"].hide();
				me["Simple_PageNumS"].setText("X/X");
				me["Simple_PageNumS"].hide();
				me["Simple_TitleS"].show();
				me["ArrowLeftS"].hide();
				me["ArrowRightS"].hide();
				
				me["Simple_L0SS"].hide();
				me["Simple_C3BS"].hide();
				me["Simple_C4BS"].hide();
				
				me.fontLeft(default, default, default, default, default, default);
				me.fontLeftS(default, default, default, default, default, default);
				me.fontRight(default, default, default, default, default, default);
				me.fontRightS(default, default, default, default, default, default);
				
				me.fontSizeLeft(normal, normal, normal, normal, normal, normal);
				me.fontSizeRight(normal, normal, normal, normal, normal, normal);
				
				me.colorLeftS("wht", "wht", "wht", "wht", "wht", "wht");
				me.colorLeftArrow("wht", "wht", "wht", "wht", "wht", "wht");
				me.colorRightS("wht", "wht", "wht", "wht", "wht", "wht");
				me.colorRightArrow("wht", "wht", "wht", "wht", "wht", "wht");
				
				
				if (myDuplicate[i] != nil) {
					me["Simple_TitleS"].setText(sprintf("%s", myDuplicate[i].title));
					
					forindex (var matrixArrow; myDuplicate[i].arrowsMatrix) {
						if (matrixArrow == 0) { 
							var sign = "L"; 
						} else { 
							var sign = "R"; 
						}
						forindex (var item; myDuplicate[i].arrowsMatrix[matrixArrow]) {
							if (myDuplicate[i].arrowsMatrix[matrixArrow][item] == 1) {
								me["Simple_" ~ sign ~ (item + 1) ~ "_ArrowS"].show();
							} else {
								me["Simple_" ~ sign ~ (item + 1) ~ "_ArrowS"].hide();
							}
						}
					}
					me.colorLeftArrow(myDuplicate[i].arrowsColour[0][0],myDuplicate[i].arrowsColour[0][1],myDuplicate[i].arrowsColour[0][2],myDuplicate[i].arrowsColour[0][3],myDuplicate[i].arrowsColour[0][4],myDuplicate[i].arrowsColour[0][5]);
					
					
					forindex (var matrixFont; myDuplicate[i].fontMatrix) {
						if (matrixFont == 0) { 
							var sign = "L"; 
						} else { 
							var sign = "R"; 
						}
						forindex (var item; myDuplicate[i].fontMatrix[matrixFont]) {
							if (myDuplicate[i].fontMatrix[matrixFont][item] == 1) {
								me["Simple_" ~ sign ~ (item + 1)].setFont(symbol);
								me["Simple_" ~ sign ~ (item + 1)].setFontSize(small);
							} else {
								me["Simple_" ~ sign ~ (item + 1)].setFont(default);
								me["Simple_" ~ sign ~ (item + 1)].setFontSize(normal);
							}
						}
					}
					
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
					
					me["Simple_C6S"].hide();
					me["Simple_C6SS"].hide();
						
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
				me["SimpleS"].show();
				me["Simple_CenterS"].show();
				me["FPLNS"].hide();
				me["DIRTO_TMPY_groupS"].hide();
				me["INITAS"].hide();
				me["IRSINITS"].hide();
				me["INITBS"].hide();
				me["FUELPREDS"].hide();
				me["PROGS"].hide();
				me["PERFTOS"].hide();
				me["Simple_PageNumS"].setText("X/X");
				me["Simple_PageNumS"].hide();
				me["Simple_TitleS"].show();
				me["ArrowLeftS"].show();
				me["ArrowRightS"].show();
				me["arrowsDepArrS"].show();
				me["Simple_L1_ArrowS"].hide();
				me["Simple_L2_ArrowS"].hide();
				me["Simple_L3_ArrowS"].hide();
				me["Simple_L4_ArrowS"].hide();
				me["Simple_L5_ArrowS"].hide();
				me["Simple_L6_ArrowS"].show();
				me["Simple_R1_ArrowS"].hide();
				me["Simple_R2_ArrowS"].hide();
				me["Simple_R3_ArrowS"].hide();
				me["Simple_R4_ArrowS"].hide();
				me["Simple_R5_ArrowS"].hide();
				me["Simple_R6_ArrowS"].hide();
				
				me["Simple_L0SS"].hide();
				me["Simple_C3BS"].hide();
				me["Simple_C4BS"].hide();
				
				me.fontLeft(default, default, default, default, default, default);
				me.fontLeftS(default, default, default, default, default, default);
				me.fontRight(default, default, default, default, default, default);
				me.fontRightS(default, default, default, default, default, default);
				
				me.fontSizeLeft(normal, normal, normal, normal, normal, normal);
				me.fontSizeRight(normal, normal, normal, normal, normal, normal);
				
				me.colorLeftS("wht", "wht", "wht", "wht", "wht", "wht");
				me.colorRightS("wht", "wht", "wht", "wht", "wht", "wht");
				
				
				if (myArrival[i] != nil) {
					me["Simple_TitleS"].setText(sprintf("%s", myArrival[i].title[0] ~ myArrival[i].title[1] ~ myArrival[i].title[2]));
					
					forindex (var matrixArrow; myArrival[i].arrowsMatrix) {
						if (matrixArrow == 0) { 
							var sign = "L"; 
						} else { 
							var sign = "R"; 
						}
						forindex (var item; myArrival[i].arrowsMatrix[matrixArrow]) {
							if (item == 5) { 
								me["Simple_L6_ArrowS"].setColor(getprop("/MCDUC/colors/" ~ myArrival[i].arrowsColour[0][5] ~ "/r"), getprop("/MCDUC/colors/" ~ myArrival[i].arrowsColour[0][5] ~ "/g"), getprop("/MCDUC/colors/" ~ myArrival[i].arrowsColour[0][5] ~ "/b"));
								continue;
							}
							if (myArrival[i].arrowsMatrix[matrixArrow][item] == 1) {
								me["arrow" ~ (item + 1) ~ sign].show();
								me["arrow" ~ (item + 1) ~ sign].setColor(getprop("/MCDUC/colors/" ~ myArrival[i].arrowsColour[matrixArrow][item] ~ "/r"), getprop("/MCDUC/colors/" ~ myArrival[i].arrowsColour[matrixArrow][item] ~ "/g"), getprop("/MCDUC/colors/" ~ myArrival[i].arrowsColour[matrixArrow][item] ~ "/b"));
							} else {
								me["arrow" ~ (item + 1) ~ sign].hide();
							}
						}
					}
					
					forindex (var matrixFont; myArrival[i].fontMatrix) {
						if (matrixFont == 0) { 
							var sign = "L"; 
						} else { 
							var sign = "R"; 
						}
						forindex (var item; myArrival[i].fontMatrix[matrixFont]) {
							if (myArrival[i].fontMatrix[matrixFont][item] == 1) {
								me["Simple_" ~ sign ~ (item + 1)].setFont(symbol);
								me["Simple_" ~ sign ~ (item + 1)].setFontSize(small);
							} else {
								me["Simple_" ~ sign ~ (item + 1)].setFont(default);
								me["Simple_" ~ sign ~ (item + 1)].setFontSize(normal);
							}
						}
					}
					
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
					
					me["Simple_C6S"].hide();
					me["Simple_C6SS"].hide();
						
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
				me["SimpleS"].show();
				me["Simple_CenterS"].show();
				me["FPLNS"].hide();
				me["DIRTO_TMPY_groupS"].hide();
				me["INITAS"].hide();
				me["IRSINITS"].hide();
				me["INITBS"].hide();
				me["FUELPREDS"].hide();
				me["PROGS"].hide();
				me["PERFTOS"].hide();
				me["Simple_PageNumS"].setText("X/X");
				me["Simple_PageNumS"].hide();
				me["Simple_TitleS"].show();
				me["ArrowLeftS"].hide();
				me["ArrowRightS"].hide();
				me["arrowsDepArrS"].show();
				me["Simple_L1_ArrowS"].hide();
				me["Simple_L2_ArrowS"].hide();
				me["Simple_L3_ArrowS"].hide();
				me["Simple_L4_ArrowS"].hide();
				me["Simple_L5_ArrowS"].hide();
				me["Simple_L6_ArrowS"].show();
				me["Simple_R1_ArrowS"].hide();
				me["Simple_R2_ArrowS"].hide();
				me["Simple_R3_ArrowS"].hide();
				me["Simple_R4_ArrowS"].hide();
				me["Simple_R5_ArrowS"].hide();
				me["Simple_R6_ArrowS"].hide();
				
				me["Simple_L0SS"].hide();
				me["Simple_C3BS"].hide();
				me["Simple_C4BS"].hide();
				
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
					me["Simple_TitleS"].setText(sprintf("%s", myHold[i].title[0] ~ myHold[i].title[1] ~ myHold[i].title[2]));
					me["Simple_TitleS"].setColor(getprop("/MCDUC/colors/" ~ myHold[i].titleColour ~ "/r"), getprop("/MCDUC/colors/" ~ myHold[i].titleColour ~ "/g"), getprop("/MCDUC/colors/" ~ myHold[i].titleColour ~ "/b"));
					
					forindex (var matrixArrow; myHold[i].arrowsMatrix) {
						if (matrixArrow == 0) { 
							var sign = "L"; 
						} else { 
							var sign = "R"; 
						}
						forindex (var item; myHold[i].arrowsMatrix[matrixArrow]) {
							if (item == 5) { 
								me["Simple_L6_ArrowS"].setColor(getprop("/MCDUC/colors/" ~ myHold[i].arrowsColour[0][5] ~ "/r"), getprop("/MCDUC/colors/" ~ myHold[i].arrowsColour[0][5] ~ "/g"), getprop("/MCDUC/colors/" ~ myHold[i].arrowsColour[0][5] ~ "/b"));
								continue;
							}
							if (myHold[i].arrowsMatrix[matrixArrow][item] == 1) {
								me["arrow" ~ (item + 1) ~ sign].show();
								me["arrow" ~ (item + 1) ~ sign].setColor(getprop("/MCDUC/colors/" ~ myHold[i].arrowsColour[matrixArrow][item] ~ "/r"), getprop("/MCDUC/colors/" ~ myHold[i].arrowsColour[matrixArrow][item] ~ "/g"), getprop("/MCDUC/colors/" ~ myHold[i].arrowsColour[matrixArrow][item] ~ "/b"));
							} else {
								me["arrow" ~ (item + 1) ~ sign].hide();
							}
						}
					}
					
					forindex (var matrixFont; myHold[i].fontMatrix) {
						if (matrixFont == 0) { 
							var sign = "L"; 
						} else { 
							var sign = "R"; 
						}
						forindex (var item; myHold[i].fontMatrix[matrixFont]) {
							if (myHold[i].fontMatrix[matrixFont][item] == 1) {
								me["Simple_" ~ sign ~ (item + 1)].setFont(symbol);
								me["Simple_" ~ sign ~ (item + 1)].setFontSize(small);
							} else {
								me["Simple_" ~ sign ~ (item + 1)].setFont(default);
								me["Simple_" ~ sign ~ (item + 1)].setFontSize(normal);
							}
						}
					}
					
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
					
					me["Simple_C6S"].hide();
					me["Simple_C6SS"].hide();
						
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
				me["SimpleS"].show();
				me["Simple_CenterS"].show();
				me["FPLNS"].hide();
				me["DIRTO_TMPY_groupS"].hide();
				me["INITAS"].hide();
				me["IRSINITS"].hide();
				me["INITBS"].hide();
				me["FUELPREDS"].hide();
				me["PROGS"].hide();
				me["PERFTOS"].hide();
				me["Simple_PageNumS"].setText("X/X");
				me["Simple_PageNumS"].hide();
				me["Simple_TitleS"].show();
				me["ArrowLeftS"].hide();
				me["ArrowRightS"].hide();
				me["arrowsDepArrS"].show();
				me["Simple_L1_ArrowS"].hide();
				me["Simple_L2_ArrowS"].hide();
				me["Simple_L3_ArrowS"].hide();
				me["Simple_L4_ArrowS"].hide();
				me["Simple_L5_ArrowS"].hide();
				me["Simple_L6_ArrowS"].show();
				me["Simple_R1_ArrowS"].hide();
				me["Simple_R2_ArrowS"].hide();
				me["Simple_R3_ArrowS"].hide();
				me["Simple_R4_ArrowS"].hide();
				me["Simple_R5_ArrowS"].hide();
				me["Simple_R6_ArrowS"].hide();
				
				me["Simple_L0SS"].hide();
				me["Simple_C3BS"].hide();
				me["Simple_C4BS"].hide();
				
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
					me["Simple_TitleS"].setText(sprintf("%s", myAirways[i].title[0] ~ myAirways[i].title[1] ~ myAirways[i].title[2]));
					me["Simple_TitleS"].setColor(getprop("/MCDUC/colors/" ~ myAirways[i].titleColour ~ "/r"), getprop("/MCDUC/colors/" ~ myAirways[i].titleColour ~ "/g"), getprop("/MCDUC/colors/" ~ myAirways[i].titleColour ~ "/b"));
					
					forindex (var matrixArrow; myAirways[i].arrowsMatrix) {
						if (matrixArrow == 0) { 
							var sign = "L"; 
						} else { 
							var sign = "R"; 
						}
						forindex (var item; myAirways[i].arrowsMatrix[matrixArrow]) {
							if (item == 5) { 
								me["Simple_L6_ArrowS"].setColor(getprop("/MCDUC/colors/" ~ myAirways[i].arrowsColour[0][5] ~ "/r"), getprop("/MCDUC/colors/" ~ myAirways[i].arrowsColour[0][5] ~ "/g"), getprop("/MCDUC/colors/" ~ myAirways[i].arrowsColour[0][5] ~ "/b"));
								continue;
							}
							if (myAirways[i].arrowsMatrix[matrixArrow][item] == 1) {
								me["arrow" ~ (item + 1) ~ sign].show();
								me["arrow" ~ (item + 1) ~ sign].setColor(getprop("/MCDUC/colors/" ~ myAirways[i].arrowsColour[matrixArrow][item] ~ "/r"), getprop("/MCDUC/colors/" ~ myAirways[i].arrowsColour[matrixArrow][item] ~ "/g"), getprop("/MCDUC/colors/" ~ myAirways[i].arrowsColour[matrixArrow][item] ~ "/b"));
							} else {
								me["arrow" ~ (item + 1) ~ sign].hide();
							}
						}
					}
					
					forindex (var matrixFont; myAirways[i].fontMatrix) {
						if (matrixFont == 0) { 
							var sign = "L"; 
						} else { 
							var sign = "R"; 
						}
						forindex (var item; myAirways[i].fontMatrix[matrixFont]) {
							if (myAirways[i].fontMatrix[matrixFont][item] == 1) {
								me["Simple_" ~ sign ~ (item + 1)].setFont(symbol);
								me["Simple_" ~ sign ~ (item + 1)].setFontSize(small);
							} else {
								me["Simple_" ~ sign ~ (item + 1)].setFont(default);
								me["Simple_" ~ sign ~ (item + 1)].setFontSize(normal);
							}
						}
					}
					
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
					
					me["Simple_C6S"].hide();
					me["Simple_C6SS"].hide();
						
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
				me["SimpleS"].show();
				me["Simple_CenterS"].show();
				me["FPLNS"].hide();
				me["DIRTO_TMPY_groupS"].hide();
				me["INITAS"].hide();
				me["IRSINITS"].hide();
				me["INITBS"].hide();
				me["FUELPREDS"].hide();
				me["PROGS"].hide();
				me["PERFTOS"].hide();
				me["Simple_PageNumS"].setText("X/X");
				me["Simple_PageNumS"].hide();
				me["Simple_TitleS"].show();
				me["ArrowLeftS"].hide();
				me["ArrowRightS"].hide();
				me["arrowsDepArrS"].hide();
				me["Simple_L1_ArrowS"].hide();
				me["Simple_L2_ArrowS"].hide();
				me["Simple_L3_ArrowS"].hide();
				me["Simple_L4_ArrowS"].hide();
				me["Simple_L5_ArrowS"].hide();
				me["Simple_L6_ArrowS"].show();
				me["Simple_R1_ArrowS"].hide();
				me["Simple_R2_ArrowS"].hide();
				me["Simple_R3_ArrowS"].hide();
				me["Simple_R4_ArrowS"].hide();
				me["Simple_R5_ArrowS"].hide();
				me["Simple_R6_ArrowS"].show();
				
				me["Simple_L0SS"].hide();
				me["Simple_C3BS"].hide();
				me["Simple_C4BS"].hide();
				
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
					me["Simple_TitleS"].setText(sprintf("%s", myClosestAirport[i].title));
				
					me["Simple_L6_ArrowS"].setColor(getprop("/MCDUC/colors/" ~ myClosestAirport[i].arrowsColour[0][5] ~ "/r"), getprop("/MCDUC/colors/" ~ myClosestAirport[i].arrowsColour[0][5] ~ "/g"), getprop("/MCDUC/colors/" ~ myClosestAirport[i].arrowsColour[0][5] ~ "/b"));
					me["Simple_R6_ArrowS"].setColor(getprop("/MCDUC/colors/" ~ myClosestAirport[i].arrowsColour[1][5] ~ "/r"), getprop("/MCDUC/colors/" ~ myClosestAirport[i].arrowsColour[1][5] ~ "/g"), getprop("/MCDUC/colors/" ~ myClosestAirport[i].arrowsColour[1][5] ~ "/b"));
					
					forindex (var matrixFont; myClosestAirport[i].fontMatrix) {
						if (matrixFont == 0) { 
							var sign = "L"; 
						} else { 
							var sign = "R"; 
						}
						forindex (var item; myClosestAirport[i].fontMatrix[matrixFont]) {
							if (myClosestAirport[i].fontMatrix[matrixFont][item] == 1) {
								me["Simple_" ~ sign ~ (item + 1)].setFont(symbol);
								me["Simple_" ~ sign ~ (item + 1)].setFontSize(small);
							} else {
								me["Simple_" ~ sign ~ (item + 1)].setFont(default);
								me["Simple_" ~ sign ~ (item + 1)].setFontSize(normal);
							}
						}
					}
					
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
					
					me["Simple_C6S"].hide();
					me["Simple_C6SS"].hide();
						
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
				me["SimpleS"].show();
				me["Simple_CenterS"].hide();
				me["FPLNS"].hide();
				me["DIRTO_TMPY_groupS"].show();
				me["INITAS"].hide();
				me["IRSINITS"].hide();
				me["INITBS"].hide();
				me["FUELPREDS"].hide();
				me["PROGS"].hide();
				me["PERFTOS"].hide();
				me["arrowsDepArrS"].show();
				me["PERFAPPRS"].hide();
				me["PERFGAS"].hide();
				me["Simple_PageNumS"].setText("X/X");
				me["Simple_PageNumS"].hide();
				me["Simple_TitleS"].show();
				me["ArrowLeftS"].hide();
				me["ArrowRightS"].hide();
				me["Simple_L1_ArrowS"].hide();
				me["Simple_L2_ArrowS"].hide();
				me["Simple_L3_ArrowS"].hide();
				me["Simple_L4_ArrowS"].hide();
				me["Simple_L5_ArrowS"].hide();
				me["Simple_L6_ArrowS"].hide();
				me["Simple_R1_ArrowS"].hide();
				me["Simple_R2_ArrowS"].hide();
				me["Simple_R3_ArrowS"].hide();
				me["Simple_R4_ArrowS"].hide();
				me["Simple_R5_ArrowS"].hide();
				me["Simple_R6_ArrowS"].hide();
				
				me["Simple_L0SS"].hide();
				me["Simple_C3BS"].hide();
				me["Simple_C4BS"].hide();
				
				me.fontLeft(default, default, default, default, default, default);
				me.fontLeftS(default, default, default, default, default, default);
				me.fontRight(default, default, default, default, default, default);
				me.fontRightS(default, default, default, default, default, default);
				
				me.fontSizeLeft(normal, normal, normal, normal, normal, normal);
				me.fontSizeRight(normal, normal, normal, normal, normal, normal);
				
				me.colorLeftS("wht", "wht", "wht", "wht", "wht", "wht");
				me.colorRightS("wht", "wht", "wht", "wht", "wht", "wht");
				me.colorLeftArrow("wht", "wht", "wht", "wht", "wht", "wht");
				me.colorRightArrow("wht", "wht", "wht", "wht", "wht", "wht");
				
				if (myDirTo[i] != nil) {
					me["Simple_TitleS"].setText(sprintf("%s", myDirTo[i].title[0]));
					me["Simple_TitleS"].setColor(getprop("/MCDUC/colors/" ~ myDirTo[i].titleColour ~ "/r"), getprop("/MCDUC/colors/" ~ myDirTo[i].titleColour ~ "/g"), getprop("/MCDUC/colors/" ~ myDirTo[i].titleColour ~ "/b"));
					
					forindex (var matrixArrow; myDirTo[i].arrowsMatrix) {
						if (matrixArrow == 0) { 
							var sign = "L"; 
						} else { 
							var sign = "R"; 
						}
						forindex (var item; myDirTo[i].arrowsMatrix[matrixArrow]) {
							if (item == 5) { continue; }
							if (myDirTo[i].arrowsMatrix[matrixArrow][item] == 1) {
								me["arrow" ~ (item + 1) ~ sign].show();
								me["arrow" ~ (item + 1) ~ sign].setColor(getprop("/MCDUC/colors/" ~ myDirTo[i].arrowsColour[matrixArrow][item] ~ "/r"), getprop("/MCDUC/colors/" ~ myDirTo[i].arrowsColour[matrixArrow][item] ~ "/g"), getprop("/MCDUC/colors/" ~ myDirTo[i].arrowsColour[matrixArrow][item] ~ "/b"));
							} else {
								me["arrow" ~ (item + 1) ~ sign].hide();
							}
						}
					}
					
					forindex (var matrixFont; myDirTo[i].fontMatrix) {
						if (matrixFont == 0) { 
							var sign = "L"; 
						} else { 
							var sign = "R"; 
						}
						forindex (var item; myDirTo[i].fontMatrix[matrixFont]) {
							if (myDirTo[i].fontMatrix[matrixFont][item] == 1) {
								me["Simple_" ~ sign ~ (item + 1)].setFont(symbol);
								me["Simple_" ~ sign ~ (item + 1)].setFontSize(small);
							} else {
								me["Simple_" ~ sign ~ (item + 1)].setFont(default);
								me["Simple_" ~ sign ~ (item + 1)].setFontSize(normal);
							}
						}
					}
					
					if (fmgc.flightPlanController.temporaryFlag[i] and mcdu.dirToFlag) {
						me["DIRTO_TMPY_groupS"].show();
					} else {
						me["DIRTO_TMPY_groupS"].hide();
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
				me["SimpleS"].hide();
				me["FPLNS"].hide();
				me["DIRTO_TMPY_groupS"].hide();
				me["INITAS"].hide();
				me["IRSINITS"].hide();
				me["INITBS"].hide();
				me["FUELPREDS"].hide();
				me["PROGS"].hide();
				me["PERFTOS"].hide();
				me["arrowsDepArrS"].hide();
				me["PERFAPPRS"].hide();
				me["PERFGAS"].hide();
				me["ArrowLeftS"].hide();
				me["ArrowRightS"].hide();
				
				pageSwitch[i].setBoolValue(1);
			}
		}
		
		me["ScratchpadS"].setText(sprintf("%s", scratchpad[i].getValue()));
	},
	# ack = ignore, wht = white, grn = green, blu = blue, amb = amber, yel = yellow, mag = magenta
	colorLeft: func(a, b, c, d, e, f) {
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
	colorLeftS: func(a, b, c, d, e, f) {
		if (a != "ack") {
			me["Simple_L1SS"].setColor(getprop("/MCDUC/colors/" ~ a ~ "/r"), getprop("/MCDUC/colors/" ~ a ~ "/g"), getprop("/MCDUC/colors/" ~ a ~ "/b"));
		}
		if (b != "ack") {
			me["Simple_L2SS"].setColor(getprop("/MCDUC/colors/" ~ b ~ "/r"), getprop("/MCDUC/colors/" ~ b ~ "/g"), getprop("/MCDUC/colors/" ~ b ~ "/b"));
		}
		if (c != "ack") {
			me["Simple_L3SS"].setColor(getprop("/MCDUC/colors/" ~ c ~ "/r"), getprop("/MCDUC/colors/" ~ c ~ "/g"), getprop("/MCDUC/colors/" ~ c ~ "/b"));
		}
		if (d != "ack") {
			me["Simple_L4SS"].setColor(getprop("/MCDUC/colors/" ~ d ~ "/r"), getprop("/MCDUC/colors/" ~ d ~ "/g"), getprop("/MCDUC/colors/" ~ d ~ "/b"));
		}
		if (e != "ack") {
			me["Simple_L5SS"].setColor(getprop("/MCDUC/colors/" ~ e ~ "/r"), getprop("/MCDUC/colors/" ~ e ~ "/g"), getprop("/MCDUC/colors/" ~ e ~ "/b"));
		}
		if (f != "ack") {
			me["Simple_L6SS"].setColor(getprop("/MCDUC/colors/" ~ f ~ "/r"), getprop("/MCDUC/colors/" ~ f ~ "/g"), getprop("/MCDUC/colors/" ~ f ~ "/b"));
		}
	},
	colorLeftArrow: func(a, b, c, d, e, f) {
		if (a != "ack") {
			me["Simple_L1_ArrowS"].setColor(getprop("/MCDUC/colors/" ~ a ~ "/r"), getprop("/MCDUC/colors/" ~ a ~ "/g"), getprop("/MCDUC/colors/" ~ a ~ "/b"));
		}
		if (b != "ack") {
			me["Simple_L2_ArrowS"].setColor(getprop("/MCDUC/colors/" ~ b ~ "/r"), getprop("/MCDUC/colors/" ~ b ~ "/g"), getprop("/MCDUC/colors/" ~ b ~ "/b"));
		}
		if (c != "ack") {
			me["Simple_L3_ArrowS"].setColor(getprop("/MCDUC/colors/" ~ c ~ "/r"), getprop("/MCDUC/colors/" ~ c ~ "/g"), getprop("/MCDUC/colors/" ~ c ~ "/b"));
		}
		if (d != "ack") {
			me["Simple_L4_ArrowS"].setColor(getprop("/MCDUC/colors/" ~ d ~ "/r"), getprop("/MCDUC/colors/" ~ d ~ "/g"), getprop("/MCDUC/colors/" ~ d ~ "/b"));
		}
		if (e != "ack") {
			me["Simple_L5_ArrowS"].setColor(getprop("/MCDUC/colors/" ~ e ~ "/r"), getprop("/MCDUC/colors/" ~ e ~ "/g"), getprop("/MCDUC/colors/" ~ e ~ "/b"));
		}
		if (f != "ack") {
			me["Simple_L6_ArrowS"].setColor(getprop("/MCDUC/colors/" ~ f ~ "/r"), getprop("/MCDUC/colors/" ~ f ~ "/g"), getprop("/MCDUC/colors/" ~ f ~ "/b"));
		}
	},
	colorRight: func(a, b, c, d, e, f) {
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
	colorRightS: func(a, b, c, d, e, f) {
		if (a != "ack") {
			me["Simple_R1SS"].setColor(getprop("/MCDUC/colors/" ~ a ~ "/r"), getprop("/MCDUC/colors/" ~ a ~ "/g"), getprop("/MCDUC/colors/" ~ a ~ "/b"));
		}
		if (b != "ack") {
			me["Simple_R2SS"].setColor(getprop("/MCDUC/colors/" ~ b ~ "/r"), getprop("/MCDUC/colors/" ~ b ~ "/g"), getprop("/MCDUC/colors/" ~ b ~ "/b"));
		}
		if (c != "ack") {
			me["Simple_R3SS"].setColor(getprop("/MCDUC/colors/" ~ c ~ "/r"), getprop("/MCDUC/colors/" ~ c ~ "/g"), getprop("/MCDUC/colors/" ~ c ~ "/b"));
		}
		if (d != "ack") {
			me["Simple_R4SS"].setColor(getprop("/MCDUC/colors/" ~ d ~ "/r"), getprop("/MCDUC/colors/" ~ d ~ "/g"), getprop("/MCDUC/colors/" ~ d ~ "/b"));
		}
		if (e != "ack") {
			me["Simple_R5SS"].setColor(getprop("/MCDUC/colors/" ~ e ~ "/r"), getprop("/MCDUC/colors/" ~ e ~ "/g"), getprop("/MCDUC/colors/" ~ e ~ "/b"));
		}
		if (f != "ack") {
			me["Simple_R6SS"].setColor(getprop("/MCDUC/colors/" ~ f ~ "/r"), getprop("/MCDUC/colors/" ~ f ~ "/g"), getprop("/MCDUC/colors/" ~ f ~ "/b"));
		}
	},
	colorRightArrow: func(a, b, c, d, e, f) {
		if (a != "ack") {
			me["Simple_R1_ArrowS"].setColor(getprop("/MCDUC/colors/" ~ a ~ "/r"), getprop("/MCDUC/colors/" ~ a ~ "/g"), getprop("/MCDUC/colors/" ~ a ~ "/b"));
		}
		if (b != "ack") {
			me["Simple_R2_ArrowS"].setColor(getprop("/MCDUC/colors/" ~ b ~ "/r"), getprop("/MCDUC/colors/" ~ b ~ "/g"), getprop("/MCDUC/colors/" ~ b ~ "/b"));
		}
		if (c != "ack") {
			me["Simple_R3_ArrowS"].setColor(getprop("/MCDUC/colors/" ~ c ~ "/r"), getprop("/MCDUC/colors/" ~ c ~ "/g"), getprop("/MCDUC/colors/" ~ c ~ "/b"));
		}
		if (d != "ack") {
			me["Simple_R4_ArrowS"].setColor(getprop("/MCDUC/colors/" ~ d ~ "/r"), getprop("/MCDUC/colors/" ~ d ~ "/g"), getprop("/MCDUC/colors/" ~ d ~ "/b"));
		}
		if (e != "ack") {
			me["Simple_R5_ArrowS"].setColor(getprop("/MCDUC/colors/" ~ e ~ "/r"), getprop("/MCDUC/colors/" ~ e ~ "/g"), getprop("/MCDUC/colors/" ~ e ~ "/b"));
		}
		if (f != "ack") {
			me["Simple_R6_ArrowS"].setColor(getprop("/MCDUC/colors/" ~ f ~ "/r"), getprop("/MCDUC/colors/" ~ f ~ "/g"), getprop("/MCDUC/colors/" ~ f ~ "/b"));
		}
	},
	colorCenter: func(a, b, c, d, e, f) {
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
	colorCenterS: func(a, b, c, d, e, f) {
		if (a != "ack") {
			me["Simple_C1SS"].setColor(getprop("/MCDUC/colors/" ~ a ~ "/r"), getprop("/MCDUC/colors/" ~ a ~ "/g"), getprop("/MCDUC/colors/" ~ a ~ "/b"));
		}
		if (b != "ack") {
			me["Simple_C2SS"].setColor(getprop("/MCDUC/colors/" ~ b ~ "/r"), getprop("/MCDUC/colors/" ~ b ~ "/g"), getprop("/MCDUC/colors/" ~ b ~ "/b"));
		}
		if (c != "ack") {
			me["Simple_C3SS"].setColor(getprop("/MCDUC/colors/" ~ c ~ "/r"), getprop("/MCDUC/colors/" ~ c ~ "/g"), getprop("/MCDUC/colors/" ~ c ~ "/b"));
		}
		if (d != "ack") {
			me["Simple_C4SS"].setColor(getprop("/MCDUC/colors/" ~ d ~ "/r"), getprop("/MCDUC/colors/" ~ d ~ "/g"), getprop("/MCDUC/colors/" ~ d ~ "/b"));
		}
		if (e != "ack") {
			me["Simple_C5SS"].setColor(getprop("/MCDUC/colors/" ~ e ~ "/r"), getprop("/MCDUC/colors/" ~ e ~ "/g"), getprop("/MCDUC/colors/" ~ e ~ "/b"));
		}
		if (f != "ack") {
			me["Simple_C6SS"].setColor(getprop("/MCDUC/colors/" ~ f ~ "/r"), getprop("/MCDUC/colors/" ~ f ~ "/g"), getprop("/MCDUC/colors/" ~ f ~ "/b"));
		}
	},
	# -1 = hide, 0 = ignore, 1 = show
	showLeft: func (a, b, c, d, e, f) {
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
	showLeftS: func (a, b, c, d, e, f) {
		if (a != 0) {
			if (a >= 1) {
				me["Simple_L1SS"].show(); 
			} else {
				me["Simple_L1SS"].hide(); 
			}
		}
		if (b != 0) {
			if (b >= 1) {
				me["Simple_L2SS"].show(); 
			} else {
				me["Simple_L2SS"].hide(); 
			}
		}
		if (c != 0) {
			if (c >= 1) {
				me["Simple_L3SS"].show(); 
			} else {
				me["Simple_L3SS"].hide(); 
			}
		}
		if (d != 0) {
			if (d >= 1) {
				me["Simple_L4SS"].show(); 
			} else {
				me["Simple_L4SS"].hide(); 
			}
		}
		if (e != 0) {
			if (e >= 1) {
				me["Simple_L5SS"].show(); 
			} else {
				me["Simple_L5SS"].hide(); 
			}
		}
		if (f != 0) {
			if (f >= 1) {
				me["Simple_L6SS"].show(); 
			} else {
				me["Simple_L6SS"].hide(); 
			}
		}
	},
	showLeftArrow: func (a, b, c, d, e, f) {
		if (a != 0) {
			if (a >= 1) {
				me["Simple_L1_ArrowS"].show(); 
			} else {
				me["Simple_L1_ArrowS"].hide(); 
			}
		}
		if (b != 0) {
			if (b >= 1) {
				me["Simple_L2_ArrowS"].show(); 
			} else {
				me["Simple_L2_ArrowS"].hide(); 
			}
		}
		if (c != 0) {
			if (c >= 1) {
				me["Simple_L3_ArrowS"].show(); 
			} else {
				me["Simple_L3_ArrowS"].hide(); 
			}
		}
		if (d != 0) {
			if (d >= 1) {
				me["Simple_L4_ArrowS"].show(); 
			} else {
				me["Simple_L4_ArrowS"].hide(); 
			}
		}
		if (e != 0) {
			if (e >= 1) {
				me["Simple_L5_ArrowS"].show(); 
			} else {
				me["Simple_L5_ArrowS"].hide(); 
			}
		}
		if (f != 0) {
			if (f >= 1) {
				me["Simple_L6_ArrowS"].show(); 
			} else {
				me["Simple_L6_ArrowS"].hide(); 
			}
		}
	},
	showRight: func (a, b, c, d, e, f) {
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
	showRightS: func (a, b, c, d, e, f) {
		if (a != 0) {
			if (a >= 1) {
				me["Simple_R1SS"].show(); 
			} else {
				me["Simple_R1SS"].hide(); 
			}
		}
		if (b != 0) {
			if (b >= 1) {
				me["Simple_R2SS"].show(); 
			} else {
				me["Simple_R2SS"].hide(); 
			}
		}
		if (c != 0) {
			if (c >= 1) {
				me["Simple_R3SS"].show(); 
			} else {
				me["Simple_R3SS"].hide(); 
			}
		}
		if (d != 0) {
			if (d >= 1) {
				me["Simple_R4SS"].show(); 
			} else {
				me["Simple_R4SS"].hide(); 
			}
		}
		if (e != 0) {
			if (e >= 1) {
				me["Simple_R5SS"].show(); 
			} else {
				me["Simple_R5SS"].hide(); 
			}
		}
		if (f != 0) {
			if (f >= 1) {
				me["Simple_R6SS"].show(); 
			} else {
				me["Simple_R6SS"].hide(); 
			}
		}
	},
	showRightArrow: func (a, b, c, d, e, f) {
		if (a != 0) {
			if (a >= 1) {
				me["Simple_R1_ArrowS"].show(); 
			} else {
				me["Simple_R1_ArrowS"].hide(); 
			}
		}
		if (b != 0) {
			if (b >= 1) {
				me["Simple_R2_ArrowS"].show(); 
			} else {
				me["Simple_R2_ArrowS"].hide(); 
			}
		}
		if (c != 0) {
			if (c >= 1) {
				me["Simple_R3_ArrowS"].show(); 
			} else {
				me["Simple_R3_ArrowS"].hide(); 
			}
		}
		if (d != 0) {
			if (d >= 1) {
				me["Simple_R4_ArrowS"].show(); 
			} else {
				me["Simple_R4_ArrowS"].hide(); 
			}
		}
		if (e != 0) {
			if (e >= 1) {
				me["Simple_R5_ArrowS"].show(); 
			} else {
				me["Simple_R5_ArrowS"].hide(); 
			}
		}
		if (f != 0) {
			if (f >= 1) {
				me["Simple_R6_ArrowS"].show(); 
			} else {
				me["Simple_R6_ArrowS"].hide(); 
			}
		}
	},
	showCenter: func (a, b, c, d, e, f) {
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
	showCenterS: func (a, b, c, d, e, f) {
		if (a != 0) {
			if (a >= 1) {
				me["Simple_C1SS"].show(); 
			} else {
				me["Simple_C1SS"].hide(); 
			}
		}
		if (b != 0) {
			if (b >= 1) {
				me["Simple_C2SS"].show(); 
			} else {
				me["Simple_C2SS"].hide(); 
			}
		}
		if (c != 0) {
			if (c >= 1) {
				me["Simple_C3SS"].show(); 
			} else {
				me["Simple_C3SS"].hide(); 
			}
		}
		if (d != 0) {
			if (d >= 1) {
				me["Simple_C4SS"].show(); 
			} else {
				me["Simple_C4SS"].hide(); 
			}
		}
		if (e != 0) {
			if (e >= 1) {
				me["Simple_C5SS"].show(); 
			} else {
				me["Simple_C5SS"].hide(); 
			}
		}
		if (f != 0) {
			if (f >= 1) {
				me["Simple_C6SS"].show(); 
			} else {
				me["Simple_C6SS"].hide(); 
			}
		}
	},
	# 0 = ignore
	fontLeft: func (a, b, c, d, e, f) {
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
	fontLeftS: func (a, b, c, d, e, f) {
		if (a != 0) {
			me["Simple_L1SS"].setFont(a); 
		}
		if (b != 0) {
			me["Simple_L2SS"].setFont(b); 
		}
		if (c != 0) {
			me["Simple_L3SS"].setFont(c); 
		}
		if (d != 0) {
			me["Simple_L4SS"].setFont(d); 
		}
		if (e != 0) {
			me["Simple_L5SS"].setFont(e); 
		}
		if (f != 0) {
			me["Simple_L6SS"].setFont(f); 
		}
	},
	fontRight: func (a, b, c, d, e, f) {
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
	fontRightS: func (a, b, c, d, e, f) {
		if (a != 0) {
			me["Simple_R1SS"].setFont(a); 
		}
		if (b != 0) {
			me["Simple_R2SS"].setFont(b); 
		}
		if (c != 0) {
			me["Simple_R3SS"].setFont(c); 
		}
		if (d != 0) {
			me["Simple_R4SS"].setFont(d); 
		}
		if (e != 0) {
			me["Simple_R5SS"].setFont(e); 
		}
		if (f != 0) {
			me["Simple_R6SS"].setFont(f); 
		}
	},
	fontSizeLeft: func (a, b, c, d, e, f) {
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
	fontSizeLeftS: func (a, b, c, d, e, f) {
		if (a != 0) {
			me["Simple_L1SS"].setFontSize(a); 
		}
		if (b != 0) {
			me["Simple_L2SS"].setFontSize(b); 
		}
		if (c != 0) {
			me["Simple_L3SS"].setFontSize(c); 
		}
		if (d != 0) {
			me["Simple_L4SS"].setFontSize(d); 
		}
		if (e != 0) {
			me["Simple_L5SS"].setFontSize(e); 
		}
		if (f != 0) {
			me["Simple_L6SS"].setFontSize(f); 
		}
	},
	fontSizeRight: func (a, b, c, d, e, f) {
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
	fontSizeRightS: func (a, b, c, d, e, f) {
		if (a != 0) {
			me["Simple_R1SS"].setFontSize(a); 
		}
		if (b != 0) {
			me["Simple_R2SS"].setFontSize(b); 
		}
		if (c != 0) {
			me["Simple_R3SS"].setFontSize(c); 
		}
		if (d != 0) {
			me["Simple_R4SS"].setFontSize(d); 
		}
		if (e != 0) {
			me["Simple_R5SS"].setFontSize(e); 
		}
		if (f != 0) {
			me["Simple_R6SS"].setFontSize(f); 
		}
	},
	fontSizeCenter: func (a, b, c, d, e, f) {
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
	fontSizeCenterS: func (a, b, c, d, e, f) {
		if (a != 0) {
			me["Simple_C1SS"].setFontSize(a); 
		}
		if (b != 0) {
			me["Simple_C2SS"].setFontSize(b); 
		}
		if (c != 0) {
			me["Simple_C3SS"].setFontSize(c); 
		}
		if (d != 0) {
			me["Simple_C4SS"].setFontSize(d); 
		}
		if (e != 0) {
			me["Simple_C5SS"].setFontSize(e); 
		}
		if (f != 0) {
			me["Simple_C6SS"].setFontSize(f); 
		}
	},
	dynamicPageFunc: func (dynamic, string) {
		if (dynamic[0] == nil) {
			me[string].hide();
			me[string ~ "SS"].hide();
		} else {
			me[string].show();
			me[string].setText(dynamic[0]);
			if (dynamic[1] != nil) {
				me[string ~ "SS"].show();
				me[string ~ "SS"].setText(dynamic[1]);
			} else {
				me[string ~ "SS"].hide();
			}
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
