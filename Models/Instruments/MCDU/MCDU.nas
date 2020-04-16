# A3XX mCDU by Joshua Davidson (Octal450), Jonathan Redpath, and Matthew Maring (hayden2000)

# Copyright (c) 2019 Joshua Davidson (Octal450)
# Copyright (c) 2020 Matthew Maring (hayden2000)

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
var myDuplicate = [nil, nil];
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
setprop("MCDUC/colors/wht/r", 1);
setprop("MCDUC/colors/wht/g", 1);
setprop("MCDUC/colors/wht/b", 1);
setprop("MCDUC/colors/grn/r", 0.0509);
setprop("MCDUC/colors/grn/g", 0.7529);
setprop("MCDUC/colors/grn/b", 0.2941);
setprop("MCDUC/colors/blu/r", 0.0901);
setprop("MCDUC/colors/blu/g", 0.6039);
setprop("MCDUC/colors/blu/b", 0.7176);
setprop("MCDUC/colors/amb/r", 0.7333);
setprop("MCDUC/colors/amb/g", 0.3803);
setprop("MCDUC/colors/amb/b", 0.0000);
setprop("MCDUC/colors/yel/r", 0.9333);
setprop("MCDUC/colors/yel/g", 0.9333);
setprop("MCDUC/colors/yel/b", 0.0000);
setprop("MCDUC/colors/mag/r", 0.6902);
setprop("MCDUC/colors/mag/g", 0.3333);
setprop("MCDUC/colors/mag/b", 0.7541);
var WHITE = [1.0000,1.0000,1.0000];
var GREEN = [0.0509,0.7529,0.2941];
var BLUE = [0.0901,0.6039,0.7176];
var AMBER = [0.7333,0.3803,0.0000];
var YELLOW = [0.9333,0.9333,0.0000];
var MAGENTA = [0.6902,0.3333,0.7541];

# Fetch nodes:
var mcdu_keyboard_left = props.globals.getNode("FMGC/keyboard-left", 0);
var mcdu_keyboard_right = props.globals.getNode("FMGC/keyboard-right", 0);

#ACCONFIG
var ac1 = props.globals.getNode("systems/electrical/bus/ac-1", 1);
var ac2 = props.globals.getNode("systems/electrical/bus/ac-2", 1);
var mcdu1_lgt = props.globals.getNode("controls/lighting/DU/mcdu1", 1);
var mcdu2_lgt = props.globals.getNode("controls/lighting/DU/mcdu2", 1);
var acType = props.globals.getNode("MCDUC/type", 1);
var engType = props.globals.getNode("MCDUC/eng", 1);
var database1 = props.globals.getNode("FMGC/internal/navdatabase", 1);
var database2 = props.globals.getNode("FMGC/internal/navdatabase2", 1);
var databaseCode = props.globals.getNode("FMGC/internal/navdatabasecode", 1);

# RADNAV
var vor1 = props.globals.getNode("FMGC/internal/vor1-mcdu", 1);
var vor2 = props.globals.getNode("FMGC/internal/vor2-mcdu", 1);
var ils1 = props.globals.getNode("FMGC/internal/ils1-mcdu", 1);
var adf1 = props.globals.getNode("FMGC/internal/adf1-mcdu", 1);
var adf2 = props.globals.getNode("FMGC/internal/adf2-mcdu", 1);
var vor1FreqSet = props.globals.getNode("FMGC/internal/vor1freq-set", 1);
var vor1CRSSet = props.globals.getNode("FMGC/internal/vor1crs-set", 1);
var vor2FreqSet = props.globals.getNode("FMGC/internal/vor2freq-set", 1);
var vor2CRSSet = props.globals.getNode("FMGC/internal/vor2crs-set", 1);
var ils1FreqSet = props.globals.getNode("FMGC/internal/ils1freq-set", 1);
var ils1CRSSet = props.globals.getNode("FMGC/internal/ils1crs-set", 1);
var adf1FreqSet = props.globals.getNode("FMGC/internal/adf1freq-set", 1);
var adf2FreqSet = props.globals.getNode("FMGC/internal/adf2freq-set", 1);
var ils1CRS = props.globals.getNode("instrumentation/nav[0]/radials/selected-deg", 1);
var vor1CRS = props.globals.getNode("instrumentation/nav[2]/radials/selected-deg", 1);
var vor2CRS = props.globals.getNode("instrumentation/nav[3]/radials/selected-deg", 1);

# INT-A
var flightNum = props.globals.getNode("MCDUC/flight-num", 1);
var flightNumSet = props.globals.getNode("MCDUC/flight-num-set", 1);
var depArpt = props.globals.getNode("FMGC/internal/dep-arpt", 1);
var arrArpt = props.globals.getNode("FMGC/internal/arr-arpt", 1);
var toFromSet = props.globals.getNode("FMGC/internal/tofrom-set", 1);
var alt_airport = props.globals.getNode("FMGC/internal/alt-airport", 1);
var altSet = props.globals.getNode("FMGC/internal/alt-set", 1);
var costIndex = props.globals.getNode("FMGC/internal/cost-index", 1);
var costIndexSet = props.globals.getNode("FMGC/internal/cost-index-set", 1);
var cruiseFL = props.globals.getNode("FMGC/internal/cruise-fl", 1);
var cruiseSet = props.globals.getNode("FMGC/internal/cruise-lvl-set", 1);
var cruiseTemp = props.globals.getNode("FMGC/internal/cruise-temp", 1);
var cruiseTempSet = props.globals.getNode("FMGC/internal/cruise-temp-set", 1);
var tropo = props.globals.getNode("FMGC/internal/tropo", 1);
var tropoSet = props.globals.getNode("FMGC/internal/tropo-set", 1);
var ADIRSMCDUBTN = props.globals.getNode("controls/adirs/mcducbtn", 1);

# IRSINIT variables
var align_set = props.globals.getNode("FMGC/internal/align-set", 1);

# ROUTE SELECTION
var alt_selected = props.globals.getNode("FMGC/internal/alt-selected", 1);

# INT-B
var zfwcg = props.globals.getNode("FMGC/internal/zfwcg", 1);
var zfwcgSet = props.globals.getNode("FMGC/internal/zfwcg-set", 1);
var zfw = props.globals.getNode("FMGC/internal/zfw", 1);
var zfwSet = props.globals.getNode("FMGC/internal/zfw-set", 1);
var block = props.globals.getNode("FMGC/internal/block", 1);
var blockSet = props.globals.getNode("FMGC/internal/block-set", 1);
var taxi_fuel = props.globals.getNode("FMGC/internal/taxi-fuel", 1);
var trip_fuel = props.globals.getNode("FMGC/internal/trip-fuel", 1);
var trip_time = props.globals.getNode("FMGC/internal/trip-time", 1);
var rte_rsv = props.globals.getNode("FMGC/internal/rte-rsv", 1);
var rte_percent = props.globals.getNode("FMGC/internal/rte-percent", 1);
var alt_fuel = props.globals.getNode("FMGC/internal/alt-fuel", 1);
var alt_time = props.globals.getNode("FMGC/internal/alt-time", 1);
var final_fuel = props.globals.getNode("FMGC/internal/final-fuel", 1);
var final_time = props.globals.getNode("FMGC/internal/final-time", 1);
var min_dest_fob = props.globals.getNode("FMGC/internal/min-dest-fob", 1);
var tow = props.globals.getNode("FMGC/internal/tow", 1);
var lw = props.globals.getNode("FMGC/internal/lw", 1);
var trip_wind = props.globals.getNode("FMGC/internal/trip-wind", 1);
var extra_fuel = props.globals.getNode("FMGC/internal/extra-fuel", 1);
var extra_time = props.globals.getNode("FMGC/internal/extra-time", 1);

# FUELPRED
var state1 = props.globals.getNode("engines/engine[0]/state", 1);
var state2 = props.globals.getNode("engines/engine[1]/state", 1);
var engrdy = props.globals.getNode("engines/ready", 1);
var pri_utc = props.globals.getNode("FMGC/internal/pri-utc", 1);
var alt_utc = props.globals.getNode("FMGC/internal/alt-utc", 1);
var pri_efob = props.globals.getNode("FMGC/internal/pri-efob", 1);
var alt_efob = props.globals.getNode("FMGC/internal/alt-efob", 1);
var fob = props.globals.getNode("FMGC/internal/fob", 1);
var fffq_sensor = props.globals.getNode("FMGC/internal/fffq-sensor", 1);
var gw = props.globals.getNode("FMGC/internal/gw", 1);
var cg = props.globals.getNode("FMGC/internal/cg", 1);

# PROG
var cruiseFL_prog = props.globals.getNode("FMGC/internal/cruise-fl-prog", 1);

# PERF
var altitude = props.globals.getNode("instrumentation/altimeter/indicated-altitude-ft", 1);

# TO PERF
var v1 = props.globals.getNode("FMGC/internal/v1", 1);
var v1Set = props.globals.getNode("FMGC/internal/v1-set", 1);
var vr = props.globals.getNode("FMGC/internal/vr", 1);
var vrSet = props.globals.getNode("FMGC/internal/vr-set", 1);
var v2 = props.globals.getNode("FMGC/internal/v2", 1);
var v2Set = props.globals.getNode("FMGC/internal/v2-set", 1);

var clbReducFt = props.globals.getNode("systems/thrust/clbreduc-ft", 1);
var reducFt = props.globals.getNode("FMGC/internal/reduc-agl-ft", 1); # It's not AGL anymore
var thrAccSet = props.globals.getNode("MCDUC/thracc-set", 1);
var flapTO = props.globals.getNode("FMGC/internal/to-flap", 1);
var THSTO = props.globals.getNode("FMGC/internal/to-ths", 1);
var flapTHSSet = props.globals.getNode("FMGC/internal/flap-ths-set", 1);
var flex = props.globals.getNode("FMGC/internal/flex", 1);
var flexSet = props.globals.getNode("FMGC/internal/flex-set", 1);
var engOutAcc = props.globals.getNode("FMGC/internal/eng-out-reduc", 1);
var engOutAccSet = props.globals.getNode("MCDUC/reducacc-set", 1);
var transAlt = props.globals.getNode("FMGC/internal/trans-alt", 1);
var managedSpeed = props.globals.getNode("it-autoflight/input/spd-managed", 1);

# CLB PERF
var activate_once = props.globals.getNode("FMGC/internal/activate-once", 1);
var activate_twice = props.globals.getNode("FMGC/internal/activate-twice", 1);

# CRZ PERF

# DES PERF

# APPR PERF
var dest_qnh = props.globals.getNode("FMGC/internal/dest-qnh", 1);
var dest_temp = props.globals.getNode("FMGC/internal/dest-temp", 1);
var dest_mag = props.globals.getNode("FMGC/internal/dest-mag", 1);
var dest_wind = props.globals.getNode("FMGC/internal/dest-wind", 1);
var vapp_speed_set = props.globals.getNode("FMGC/internal/vapp-speed-set", 1);
var final = props.globals.getNode("FMGC/internal/final", 1);
var mda = props.globals.getNode("FMGC/internal/mda", 1);
var dh = props.globals.getNode("FMGC/internal/dh", 1);
var ldg_config_3_set = props.globals.getNode("FMGC/internal/ldg-config-3-set", 1);
var ldg_config_f_set = props.globals.getNode("FMGC/internal/ldg-config-f-set", 1);

# GA PERF

# Fetch nodes into vectors
var pageProp = [props.globals.getNode("MCDU[0]/page", 1), props.globals.getNode("MCDU[1]/page", 1)];
var active = [props.globals.getNode("MCDU[0]/active", 1), props.globals.getNode("MCDU[1]/active", 1)];
var scratchpad = [props.globals.getNode("MCDU[0]/scratchpad", 1), props.globals.getNode("MCDU[1]/scratchpad", 1)];

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
	"Simple_R4_Arrow","Simple_R5_Arrow","Simple_R6_Arrow","Simple_C1","Simple_C2","Simple_C3","Simple_C4","Simple_C5","Simple_C6","Simple_C1S",
	"Simple_C2S","Simple_C3S","Simple_C4S","Simple_C5S","Simple_C6S","INITA","INITA_CoRoute","INITA_FltNbr","INITA_CostIndex","INITA_CruiseFLTemp",
	"INITA_FromTo","INITA_InitRequest","INITA_AlignIRS","INITB","INITB_ZFWCG","INITB_ZFW","INITB_ZFW_S","INITB_Block","FUELPRED","FUELPRED_ZFW",
	"FUELPRED_ZFWCG","FUELPRED_ZFW_S","PROG","PROG_UPDATE","PERFTO","PERFTO_V1","PERFTO_VR","PERFTO_V2","PERFTO_FE","PERFTO_SE","PERFTO_OE","PERFAPPR",
	"PERFAPPR_FE","PERFAPPR_SE","PERFAPPR_OE","PERFAPPR_LDG_3","PERFAPPR_LDG_F","PERFGA","PERFGA_FE","PERFGA_SE","PERFGA_OE","FPLN","FPLN_From",
	"FPLN_TMPY_group","FPLN_FROM","FPLN_Callsign","departureTMPY", "arrowsDepArr","arrow1L","arrow2L","arrow3L","arrow4L","arrow5L","arrow1R","arrow2R",
	"arrow3R","arrow4R","arrow5R","DIRTO_TMPY_group"];
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
		if (page == "F-PLNA" or page == "F-PLNB") {
			if (!pageSwitch[i].getBoolValue()) {
				me["Simple"].show();
				me["Simple_Center"].show();
				me["FPLN"].show();
				me["DIRTO_TMPY_group"].hide();
				me["INITA"].hide();
				me["INITB"].hide();
				me["PERFTO"].hide();
				me["PERFAPPR"].hide();
				me["PERFGA"].hide();
				me["Simple_Title"].hide();
				me["Simple_PageNum"].hide();
				me["ArrowLeft"].show();
				me["ArrowRight"].show();
				me["arrowsDepArr"].hide();
				
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
				
				if (myFpln[i].L1[0] == nil) {
					me["Simple_L1"].hide();
					me["Simple_L1S"].hide();
				} else {
					me["Simple_L1"].show();
					me["Simple_L1"].setText(myFpln[i].L1[0]);
					if (myFpln[i].L1[1] != nil) {
						me["Simple_L1S"].show();
						me["Simple_L1S"].setText(myFpln[i].L1[1]);
					} else {
						me["Simple_L1S"].hide();
					}
				}
				
				if (myFpln[i].L2[0] == nil) {
					me["Simple_L2"].hide();
					me["Simple_L2S"].hide();
				} else {
					me["Simple_L2"].show();
					me["Simple_L2"].setText(myFpln[i].L2[0]);
					if (myFpln[i].L2[1] != nil) {
						me["Simple_L2S"].show();
						me["Simple_L2S"].setText(myFpln[i].L2[1]);
					} else {
						me["Simple_L2S"].hide();
					}
				}
				
				if (myFpln[i].L3[0] == nil) {
					me["Simple_L3"].hide();
					me["Simple_L3S"].hide();
				} else {
					me["Simple_L3"].show();
					me["Simple_L3"].setText(myFpln[i].L3[0]);
					if (myFpln[i].L3[1] != nil) {
						me["Simple_L3S"].show();
						me["Simple_L3S"].setText(myFpln[i].L3[1]);
					} else {
						me["Simple_L3S"].hide();
					}
				}
				
				if (myFpln[i].L4[0] == nil) {
					me["Simple_L4"].hide();
					me["Simple_L4S"].hide();
				} else {
					me["Simple_L4"].show();
					me["Simple_L4"].setText(myFpln[i].L4[0]);
					if (myFpln[i].L4[1] != nil) {
						me["Simple_L4S"].show();
						me["Simple_L4S"].setText(myFpln[i].L4[1]);
					} else {
						me["Simple_L4S"].hide();
					}
				}
				
				if (myFpln[i].L5[0] == nil) {
					me["Simple_L5"].hide();
					me["Simple_L5S"].hide();
				} else {
					me["Simple_L5"].show();
					me["Simple_L5"].setText(myFpln[i].L5[0]);
					if (myFpln[i].L5[1] != nil) {
						me["Simple_L5S"].show();
						me["Simple_L5S"].setText(myFpln[i].L5[1]);
					} else {
						me["Simple_L5S"].hide();
					}
				}
				
				if (myFpln[i].L6[0] == nil or fmgc.flightPlanController.temporaryFlag[i]) {
					me["Simple_L6"].hide();
					me["Simple_L6S"].hide();
				} else {
					me["Simple_L6"].show();
					me["Simple_L6"].setText(myFpln[i].L6[0]);
					if (myFpln[i].L6[1] != nil) {
						me["Simple_L6S"].show();
						me["Simple_L6S"].setText(myFpln[i].L6[1]);
					} else {
						me["Simple_L6S"].hide();
					}
				}
				me.colorLeft(myFpln[i].L1[2],myFpln[i].L2[2],myFpln[i].L3[2],myFpln[i].L4[2],myFpln[i].L5[2],myFpln[i].L6[2]);
				
				if (myFpln[i].C1[0] == nil) {
					me["Simple_C1"].hide();
					me["Simple_C1S"].hide();
				} else {
					me["Simple_C1"].show();
					me["Simple_C1"].setText(myFpln[i].C1[0]);
					if (myFpln[i].C1[1] != nil) {
						me["Simple_C1S"].show();
						me["Simple_C1S"].setText(myFpln[i].C1[1]);
					} else {
						me["Simple_C1S"].hide();
					}
				}
				
				if (myFpln[i].C2[0] == nil) {
					me["Simple_C2"].hide();
					me["Simple_C2S"].hide();
				} else {
					me["Simple_C2"].show();
					me["Simple_C2"].setText(myFpln[i].C2[0]);
					if (myFpln[i].C2[1] != nil) {
						me["Simple_C2S"].show();
						me["Simple_C2S"].setText(myFpln[i].C2[1]);
					} else {
						me["Simple_C2S"].hide();
					}
				}
				
				if (myFpln[i].C3[0] == nil) {
					me["Simple_C3"].hide();
					me["Simple_C3S"].hide();
				} else {
					me["Simple_C3"].show();
					me["Simple_C3"].setText(myFpln[i].C3[0]);
					if (myFpln[i].C3[1] != nil) {
						me["Simple_C3S"].show();
						me["Simple_C3S"].setText(myFpln[i].C3[1]);
					} else {
						me["Simple_C3S"].hide();
					}
				}
				
				if (myFpln[i].C4[0] == nil) {
					me["Simple_C4"].hide();
					me["Simple_C4S"].hide();
				} else {
					me["Simple_C4"].show();
					me["Simple_C4"].setText(myFpln[i].C4[0]);
					if (myFpln[i].C4[1] != nil) {
						me["Simple_C4S"].show();
						me["Simple_C4S"].setText(myFpln[i].C4[1]);
					} else {
						me["Simple_C4S"].hide();
					}
				}
				
				if (myFpln[i].C5[0] == nil) {
					me["Simple_C5"].hide();
					me["Simple_C5S"].hide();
				} else {
					me["Simple_C5"].show();
					me["Simple_C5"].setText(myFpln[i].C5[0]);
					if (myFpln[i].C5[1] != nil) {
						me["Simple_C5S"].show();
						me["Simple_C5S"].setText(myFpln[i].C5[1]);
					} else {
						me["Simple_C5S"].hide();
					}
				}
				
				if (myFpln[i].C6[0] == nil or fmgc.flightPlanController.temporaryFlag[i]) {
					me["Simple_C6"].hide();
					me["Simple_C6S"].hide();
				} else {
					me["Simple_C6"].show();
					me["Simple_C6"].setText(myFpln[i].C6[0]);
					if (myFpln[i].C6[1] != nil) {
						me["Simple_C6S"].show();
						me["Simple_C6S"].setText(myFpln[i].C6[1]);
					} else {
						me["Simple_C6S"].hide();
					}
				}
				
				me.colorCenter(myFpln[i].C1[2],myFpln[i].C2[2],myFpln[i].C3[2],myFpln[i].C4[2],myFpln[i].C5[2],myFpln[i].C6[2]);
					
				if (myFpln[i].R1[0] == nil) {
					me["Simple_R1"].hide();
					me["Simple_R1S"].hide();
				} else {
					me["Simple_R1"].show();
					me["Simple_R1"].setText(myFpln[i].R1[0]);
					if (myFpln[i].R1[1] != nil) {
						me["Simple_R1S"].show();
						me["Simple_R1S"].setText(myFpln[i].R1[1]);
					} else {
						me["Simple_R1S"].hide();
					}
				}
				
				if (myFpln[i].R2[0] == nil) {
					me["Simple_R2"].hide();
					me["Simple_R2S"].hide();
				} else {
					me["Simple_R2"].show();
					me["Simple_R2"].setText(myFpln[i].R2[0]);
					if (myFpln[i].R2[1] != nil) {
						me["Simple_R2S"].show();
						me["Simple_R2S"].setText(myFpln[i].R2[1]);
					} else {
						me["Simple_R2S"].hide();
					}
				}
				
				if (myFpln[i].R3[0] == nil) {
					me["Simple_R3"].hide();
					me["Simple_R3S"].hide();
				} else {
					me["Simple_R3"].show();
					me["Simple_R3"].setText(myFpln[i].R3[0]);
					if (myFpln[i].R3[1] != nil) {
						me["Simple_R3S"].show();
						me["Simple_R3S"].setText(myFpln[i].R3[1]);
					} else {
						me["Simple_R3S"].hide();
					}
				}
				
				if (myFpln[i].R4[0] == nil) {
					me["Simple_R4"].hide();
					me["Simple_R4S"].hide();
				} else {
					me["Simple_R4"].show();
					me["Simple_R4"].setText(myFpln[i].R4[0]);
					if (myFpln[i].R4[1] != nil) {
						me["Simple_R4S"].show();
						me["Simple_R4S"].setText(myFpln[i].R4[1]);
					} else {
						me["Simple_R4S"].hide();
					}
				}
				
				if (myFpln[i].R5[0] == nil) {
					me["Simple_R5"].hide();
					me["Simple_R5S"].hide();
				} else {
					me["Simple_R5"].show();
					me["Simple_R5"].setText(myFpln[i].R5[0]);
					if (myFpln[i].R5[1] != nil) {
						me["Simple_R5S"].show();
						me["Simple_R5S"].setText(myFpln[i].R5[1]);
					} else {
						me["Simple_R5S"].hide();
					}
				}
				
				if (myFpln[i].R6[0] == nil or fmgc.flightPlanController.temporaryFlag[i]) {
					me["Simple_R6"].hide();
					me["Simple_R6S"].hide();
				} else {
					me["Simple_R6"].show();
					me["Simple_R6"].setText(myFpln[i].R6[0]);
					if (myFpln[i].R6[1] != nil) {
						me["Simple_R6S"].show();
						me["Simple_R6S"].setText(myFpln[i].R6[1]);
					} else {
						me["Simple_R6S"].hide();
					}
				}
				me.colorRight(myFpln[i].R1[2],myFpln[i].R2[2],myFpln[i].R3[2],myFpln[i].R4[2],myFpln[i].R5[2],myFpln[i].R6[2]);
				
				me.colorLeftS("wht", "wht", "wht", "wht", "wht", "wht");
				me.colorLeftArrow("wht", "wht", "wht", "wht", "wht", "wht");
				me.colorRightS("wht", "wht", "wht", "wht", "wht", "wht");
				me.colorRightArrow("wht", "wht", "wht", "wht", "wht", "wht");
				
				#if (mcdu.FPLNLines[i].index == 0) {
				#	me["FPLN_From"].show();
				#} else {
				#	me["FPLN_From"].hide();
				#}
				
				if (fmgc.flightPlanController.temporaryFlag[i]) {
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
				}
			}
		} else if (page == "MCDU") {
			if (!pageSwitch[i].getBoolValue()) {
				me["Simple"].show();
				me["Simple_Center"].hide();
				me["FPLN"].hide();
				me["DIRTO_TMPY_group"].hide();
				me["INITA"].hide();
				me["INITB"].hide();
				me["FUELPRED"].hide();
				me["PROG"].hide();
				me["PERFTO"].hide();
				me["arrowsDepArr"].hide();
				me["PERFAPPR"].hide();
				me["PERFGA"].hide();
				me["Simple_Title"].show();
				me["Simple_Title"].setText("MCDU MENU");
				me["Simple_Title"].setColor(1, 1, 1);
				me["Simple_PageNum"].setText("X/X");
				me["Simple_PageNum"].hide();
				me["ArrowLeft"].hide();
				me["ArrowRight"].hide();
				
				me.showLeft(1, 1, 1, 1, -1, -1);
				me["Simple_L0S"].hide();
				me.showLeftS(-1, -1, -1, -1, -1, -1);
				me.showLeftArrow(1, 1, 1, 1, -1, -1);
				me.showRight(-1, -1, -1, -1, -1, 1);
				me.showRightS(-1, -1, -1, -1, -1, -1);
				me.showRightArrow(-1, -1, -1, -1, -1, 1);
				
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
				me["Simple_L1"].setText(" FMGC");
				me["Simple_L1"].setColor(1,1,1);
			} else if (active[i].getValue() == 1) {
				me["Simple_L1"].setText(" FMGC(SEL)");
				me["Simple_L1"].setColor(0.0901,0.6039,0.7176);
			} else if (active[i].getValue() == 2) {
				me["Simple_L1"].setText(" FMGC");
				me["Simple_L1"].setColor(0.0509,0.7529,0.2941);
			}
			me["Simple_L2"].setText(" ACARS");
			me["Simple_L3"].setText(" AIDS");
			me["Simple_L4"].setText(" CFDS");
			me["Simple_R6"].setText("RETURN ");
		} else if (page == "STATUS") {
			if (!pageSwitch[i].getBoolValue()) {
				me["Simple"].show();
				me["Simple_Center"].hide();
				me["FPLN"].hide();
				me["DIRTO_TMPY_group"].hide();
				me["INITA"].hide();
				me["INITB"].hide();
				me["FUELPRED"].hide();
				me["PROG"].hide();
				me["PERFTO"].hide();
				me["arrowsDepArr"].hide();
				me["PERFAPPR"].hide();
				me["PERFGA"].hide();
				me["Simple_Title"].show();
				me["Simple_Title"].setText(sprintf("%s", "    " ~ acType.getValue()));
				me["Simple_Title"].setColor(1, 1, 1);
				me["Simple_PageNum"].setText("X/X");
				me["Simple_PageNum"].hide();
				me["ArrowLeft"].hide();
				me["ArrowRight"].hide();
				
				me.showLeft(1, 1, 1, -1, 1, 1);
				me["Simple_L0S"].hide();
				me.showLeftS(1, 1, 1, -1, 1, 1);
				me.showLeftArrow(-1, -1, 1, -1, -1, -1);
				me.showRight(-1, 1, -1, -1, -1, 1);
				me.showRightS(-1, -1, -1, -1, -1, 1);
				me.showRightArrow(-1, -1, -1, -1, -1, 1);
				
				me.fontLeft(default, default, default, default, symbol, default);
				me.fontLeftS(default, default, default, default, default, default);
				me.fontRight(default, default, default, default, default, default);
				me.fontRightS(default, default, default, default, default, default);
				
				me.fontSizeLeft(normal, normal, normal, normal, small, normal);
				me.fontSizeRight(normal, normal, normal, normal, normal, normal);
				
				me.colorLeft("grn", "blu", "blu", "wht", "blu", "grn");
				me.colorLeftS("wht", "wht", "wht", "wht", "wht", "wht");
				me.colorLeftArrow("wht", "blu", "blu", "wht", "wht", "wht");
				me.colorRight("wht", "grn", "wht", "wht", "wht", "wht");
				me.colorRightS("wht", "wht", "wht", "wht", "wht", "wht");
				me.colorRightArrow("wht", "wht", "wht", "wht", "wht", "wht");
				
				pageSwitch[i].setBoolValue(1);
			}
			
			me["Simple_L1"].setText(sprintf("%s", engType.getValue()));
			me["Simple_L2"].setText(sprintf("%s", " " ~ database1.getValue()));
			me["Simple_L3"].setText(sprintf("%s", " " ~ database2.getValue()));
			me["Simple_L5"].setText("[   ]");
			me["Simple_L6"].setText("+4.0/+0.0");
			me["Simple_L1S"].setText(" ENG");
			me["Simple_L2S"].setText(" ACTIVE NAV DATA BASE");
			me["Simple_L3S"].setText(" SECOND NAV DATA BASE");
			me["Simple_L5S"].setText("CHG CODE");
			me["Simple_L6S"].setText("IDLE/PERF");
			me["Simple_R2"].setText(sprintf("%s", databaseCode.getValue() ~ " "));
			me["Simple_R6"].setText("STATUS/XLOAD ");
			me["Simple_R6S"].setText("SOFTWARE ");
		} else if (page == "DATA") {
			if (!pageSwitch[i].getBoolValue()) {
				me["Simple"].show();
				me["Simple_Center"].hide();
				me["FPLN"].hide();
				me["DIRTO_TMPY_group"].hide();
				me["INITA"].hide();
				me["INITB"].hide();
				me["FUELPRED"].hide();
				me["PROG"].hide();
				me["PERFTO"].hide();
				me["arrowsDepArr"].hide();
				me["PERFAPPR"].hide();
				me["PERFGA"].hide();
				me["Simple_Title"].show();
				me["Simple_Title"].setText("DATA INDEX");
				me["Simple_Title"].setColor(1, 1, 1);
				me["Simple_PageNum"].setText("1/2");
				me["Simple_PageNum"].show();
				me["ArrowLeft"].show();
				me["ArrowRight"].show();
				
				me.showLeft(1, 1, 1, 1, -1, -1);
				me["Simple_L0S"].hide();
				me.showLeftS(1, 1, 1, -1, -1, -1);
				me.showLeftArrow(1, 1, 1, 1, -1, -1);
				me.showRight(-1, -1, -1, -1, 1, 1);
				me.showRightS(-1, -1, -1, -1, 1, 1);
				me.showRightArrow(-1, -1, -1, -1, 1, 1);
				
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
			
			me["Simple_L1"].setText(" MONITOR");
			me["Simple_L2"].setText(" MONITOR");
			me["Simple_L3"].setText(" MONITOR");
			me["Simple_L4"].setText(" A/C STATUS");
			me["Simple_L1S"].setText(" POSITION");
			me["Simple_L2S"].setText(" IRS");
			me["Simple_L3S"].setText(" GPS");
			me["Simple_R5"].setText("FUNCTION ");
			me["Simple_R6"].setText("FUNCTION ");
			me["Simple_R5S"].setText("PRINT ");
			me["Simple_R6S"].setText("AOC ");
		} else if (page == "DATA2") {
			if (!pageSwitch[i].getBoolValue()) {
				me["Simple"].show();
				me["Simple_Center"].hide();
				me["FPLN"].hide();
				me["DIRTO_TMPY_group"].hide();
				me["INITA"].hide();
				me["INITB"].hide();
				me["FUELPRED"].hide();
				me["PROG"].hide();
				me["PERFTO"].hide();
				me["arrowsDepArr"].hide();
				me["PERFAPPR"].hide();
				me["PERFGA"].hide();
				me["Simple_Title"].show();
				me["Simple_Title"].setText("DATA INDEX");
				me["Simple_Title"].setColor(1, 1, 1);
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
		} else if (page == "POSMON") {
			if (!pageSwitch[i].getBoolValue()) {
				me["Simple"].show();
				me["Simple_Center"].show();
				me["FPLN"].hide();
				me["DIRTO_TMPY_group"].hide();
				me["INITA"].hide();
				me["INITB"].hide();
				me["FUELPRED"].hide();
				me["PROG"].hide();
				me["PERFTO"].hide();
				me["arrowsDepArr"].hide();
				me["PERFAPPR"].hide();
				me["PERFGA"].hide();
				me["Simple_Title"].show();
				me["Simple_Title"].setText("POSITION MONITOR");
				me["Simple_Title"].setColor(1, 1, 1);
				me["Simple_PageNum"].setText("X/X");
				me["Simple_PageNum"].hide();
				me["ArrowLeft"].hide();
				me["ArrowRight"].hide();
				
				me.showLeft(1, 1, 1, 1, 1, 1);
				me["Simple_L0S"].hide();
				me.showLeftS(-1, -1, -1, -1, 1, -1);
				me.showLeftArrow(-1, -1, -1, -1, -1, 1);
				me.showCenter(-1, -1, -1, -1, 1, -1);
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
			
			me["Simple_L1"].setText("FMGC1");
			me["Simple_L2"].setText("FMGC2");
			me["Simple_L3"].setText("GPIRS");
			me["Simple_L4"].setText("MIX IRS");
			me["Simple_L5"].setText("NAV -.-");
			me["Simple_L6"].setText(" FREEZE");
			me["Simple_L5S"].setText("   IRS1");
			me["Simple_R1"].setText("----.-X/-----.-X");
			me["Simple_R2"].setText("----.-X/-----.-X");
			me["Simple_R3"].setText("----.-X/-----.-X");
			me["Simple_R4"].setText("----.-X/-----.-X");
			me["Simple_R5"].setText("NAV -.-");
			me["Simple_R5S"].setText("IRS3	 ");
			me["Simple_R6S"].setText("SEL ");
			me["Simple_C5"].setText("NAV -.-");
			me["Simple_C5S"].setText("IRS2");
		} else if (page == "RADNAV") {
			if (!pageSwitch[i].getBoolValue()) {
				me["Simple"].show();
				me["Simple_Center"].hide();
				me["FPLN"].hide();
				me["DIRTO_TMPY_group"].hide();
				me["INITA"].hide();
				me["INITB"].hide();
				me["FUELPRED"].hide();
				me["PROG"].hide();
				me["PERFTO"].hide();
				me["arrowsDepArr"].hide();
				me["PERFAPPR"].hide();
				me["PERFGA"].hide();
				me["Simple_Title"].show();
				me["Simple_Title"].setText("RADIO NAV");
				me["Simple_Title"].setColor(1, 1, 1);
				me["Simple_PageNum"].setText("X/X");
				me["Simple_PageNum"].hide();
				me["ArrowLeft"].hide();
				me["ArrowRight"].hide();
				
				me.showLeft(1, 1, 1, 1, 1, -1);
				me["Simple_L0S"].hide();
				me.showLeftS(1, 1, 1, 1, 1, -1);
				me.showLeftArrow(-1, -1, -1, -1, -1, -1);
				me.showRight(1, 1, 1, 1, 1, -1);
				me.showRightS(1, 1, 1, 1, 1, -1);
				me.showRightArrow(-1, -1, -1, -1, -1, -1);
				
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
				me["Simple_L5"].setText("[    ]/[     . ]");
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
				me["Simple_R5"].setText("[     . ]/[    ]");
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
			me["Simple_R3"].setText("[   ]/[    ]");
			me["Simple_R4"].setText("-.-   [   ]");
			me["Simple_R1S"].setText("FREQ/VOR2");
			me["Simple_R2S"].setText("CRS");
			me["Simple_R3S"].setText("CHAN/ MLS");
			me["Simple_R4S"].setText("SLOPE   CRS");
			me["Simple_R5S"].setText("FREQ/ADF2");
		} else if (page == "INITA") {
			if (!pageSwitch[i].getBoolValue()) {
				me["Simple"].show();
				me["Simple_Center"].hide();
				me["FPLN"].hide();
				me["DIRTO_TMPY_group"].hide();
				me["INITA"].show();
				me["INITB"].hide();
				me["FUELPRED"].hide();
				me["PROG"].hide();
				me["PERFTO"].hide();
				me["arrowsDepArr"].hide();
				me["PERFAPPR"].hide();
				me["PERFGA"].hide();
				me["Simple_Title"].show();
				me["Simple_Title"].setText("INIT");
				me["Simple_Title"].setColor(1, 1, 1);
				me["Simple_PageNum"].setText("X/X");
				me["Simple_PageNum"].hide();
				me["ArrowLeft"].show();
				me["ArrowRight"].show();
				
				me.showLeft(0, 1, 0, 1, 0, 1);
				me["Simple_L0S"].hide();
				me.showLeftS(1, 1, 1, 1, 1, 1);
				me.showLeftArrow(-1, -1, -1, -1, -1, -1);
				me.showRight(0, 0, 1, 1, 1, 1);
				me.showRightS(1, 0, -1, 1, -1, 1);
				me.showRightArrow(-1, -1, -1, -1, 1, -1);
				
				me.fontLeft(default, default, default, default, default, default);
				me.fontLeftS(default, default, default, default, default, default);
				me.fontRight(default, default, default, default, default, default);
				me.fontRightS(default, default, default, default, default, default);
				
				me.fontSizeLeft(normal, normal, normal, normal, normal, normal);
				me.fontSizeRight(normal, normal, normal, normal, normal, 0);
				
				me.colorLeft("blu", "wht", "blu", "blu", "ack", "ack");
				me.colorLeftS("wht", "wht", "wht", "wht", "wht", "wht");
				me.colorLeftArrow("wht", "wht", "wht", "wht", "wht", "wht");
				me.colorRight("blu", "amb", "amb", "blu", "wht", "blu");
				me.colorRightS("wht", "amb", "wht", "wht", "wht", "wht");
				me.colorRightArrow("wht", "wht", "wht", "wht", "wht", "wht");
				
				pageSwitch[i].setBoolValue(1);
			}
			
			if (flightNumSet.getValue() == 1) {
				me["INITA_FltNbr"].hide();
				me["Simple_L3"].show();
			} else {
				me["INITA_FltNbr"].show();
				me["Simple_L3"].hide();
			}
			if (toFromSet.getValue() != 1 and costIndexSet.getValue() != 1) {
				me["INITA_CostIndex"].hide();
				me["Simple_L5"].setColor(1,1,1);
				me["Simple_L5"].show();
				me["Simple_L5"].setText("---");
			} else if (costIndexSet.getValue() == 1) {
				me["INITA_CostIndex"].hide();
				me["Simple_L5"].setColor(0.0901,0.6039,0.7176);
				me["Simple_L5"].show();
				me["Simple_L5"].setText(sprintf("%s", costIndex.getValue()));
			} else {
				me["INITA_CostIndex"].show();
				me["Simple_L5"].hide();
			}
			if (toFromSet.getValue() != 1 and cruiseSet.getValue() != 1) {
				me["INITA_CruiseFLTemp"].hide();
				me["Simple_L6"].setColor(1,1,1);
				me["Simple_L6"].setText("-----/---g");
			} else if (cruiseSet.getValue() == 1 and cruiseTempSet.getValue() == 1) {
				me["INITA_CruiseFLTemp"].hide();
				me["Simple_L6"].setColor(0.0901,0.6039,0.7176);
				me["Simple_L6"].setText(sprintf("%s", "FL" ~ cruiseFL.getValue()) ~ sprintf("/%sg", cruiseTemp.getValue()));
			} else if (cruiseSet.getValue() == 1) {
				me["INITA_CruiseFLTemp"].hide();
				me["Simple_L6"].setColor(0.0901,0.6039,0.7176);
				setprop("FMGC/internal/cruise-temp", 15 - (2 * cruiseFL.getValue() / 10));
				setprop("FMGC/internal/cruise-temp-set", 1);
				me["Simple_L6"].setText(sprintf("%s", "FL" ~ cruiseFL.getValue()) ~ sprintf("/%sg", cruiseTemp.getValue()));
			} else {
				me["INITA_CruiseFLTemp"].show();
				me["Simple_L6"].setColor(0.7333,0.3803,0);
				me["Simple_L6"].setText("         g");
			}
			if (toFromSet.getValue() == 1) {
				me["INITA_CoRoute"].hide();
				me["INITA_FromTo"].hide();
				me["Simple_L1"].show();
				me["Simple_L2"].setColor(0.0901,0.6039,0.7176);
				if (altSet.getValue() == 1) {
					me["Simple_L2"].setText(alt_airport.getValue());
				} else {
					me["Simple_L2"].setText("NONE");
				}
				me.showRight(1, -1, 0, 0, 0, 0);
				me["Simple_R2S"].hide();
				me["INITA_InitRequest"].hide();
				dms = getprop("FMGC/flightplan[2]/wp[0]/lat");
				degrees = int(dms);
				minutes = sprintf("%.1f",abs((dms - degrees) * 60));
				sign = degrees >= 0 ? "N" : "S";
				me["Simple_L4"].setText(abs(degrees) ~ "g" ~ minutes ~ " " ~ sign);
				dms = getprop("FMGC/flightplan[2]/wp[0]/lon");
				degrees = int(dms);
				minutes = sprintf("%.1f",abs((dms - degrees) * 60));
				sign = degrees >= 0 ? "E" : "W";
				me["Simple_R4"].setText(abs(degrees) ~ "g" ~ minutes ~ " " ~ sign);
			} else {
				me["INITA_CoRoute"].show();
				me["INITA_FromTo"].show();
				me["Simple_L1"].hide();
				me["Simple_L2"].setColor(1,1,1);
				me["Simple_L2"].setText("----/----------");
				me.showRight(-1, 1, 0, 0, 0, 0);
				me["Simple_R2S"].show();
				me["INITA_InitRequest"].show();
				me["Simple_L4"].setText("----.-");
				me["Simple_R4"].setText("-----.--");
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
			if (tropoSet.getValue() == 1) {
				me["Simple_R6"].setFontSize(normal); 
			} else {
				me["Simple_R6"].setFontSize(small); 
			}
			
			me["Simple_L1S"].setText(" CO RTE");
			me["Simple_L2S"].setText("ALTN/CO RTE");
			me["Simple_L3S"].setText("FLT NBR");
			me["Simple_L4S"].setText("LAT");
			me["Simple_L5S"].setText("COST INDEX");
			me["Simple_L6S"].setText("CRZ FL/TEMP");
			me["Simple_L1"].setText("NONE");
			me["Simple_L3"].setText(sprintf("%s", flightNum.getValue()));
			me["Simple_R1S"].setText("FROM/TO   ");
			me["Simple_R2S"].setText("INIT ");
			me["Simple_R4S"].setText("LONG");
			me["Simple_R6S"].setText("TROPO");
			me["Simple_R1"].setText(sprintf("%s", depArpt.getValue() ~ "/" ~ arrArpt.getValue()));
			me["Simple_R2"].setText("REQUEST ");
			me["Simple_R3"].setText("IRS INIT ");
			me["Simple_R5"].setText("WIND ");
			me["Simple_R6"].setText(sprintf("%5.0f", tropo.getValue()));
		} else if (page == "IRSINIT") {
			if (!pageSwitch[i].getBoolValue()) {
				me["Simple"].show();
				me["Simple_Center"].show();
				me["FPLN"].hide();
				me["DIRTO_TMPY_group"].hide();
				me["INITA"].hide();
				me["INITB"].hide();
				me["FUELPRED"].hide();
				me["PROG"].hide();
				me["PERFTO"].hide();
				me["arrowsDepArr"].hide();
				me["PERFAPPR"].hide();
				me["PERFGA"].hide();
				me["Simple_Title"].show();
				me["Simple_Title"].setText("IRS INIT");
				me["Simple_Title"].setColor(1, 1, 1);
				me["Simple_PageNum"].setText("X/X");
				me["Simple_PageNum"].hide();
				me["ArrowLeft"].hide();
				me["ArrowRight"].hide();
				
				me.showLeft(1, 1, -1, -1, -1, 1);
				me["Simple_L0S"].hide();
				me.showLeftS(1, 1, -1, -1, -1, -1);
				me.showLeftArrow(-1, -1, -1, -1, -1, 1);
				me.showRight(1, 1, -1, -1, -1, 1);
				me.showRightS(1, 1, -1, -1, -1, -1);
				me.showRightArrow(-1, -1, -1, -1, -1, 1);
				me.showCenter(1, -1, 1, 1, 1, -1);
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
			
			if (toFromSet.getValue() == 1) {
				dms = getprop("FMGC/flightplan[2]/wp[0]/lat");
				degrees = int(dms);
				minutes = sprintf("%.1f",abs((dms - degrees) * 60));
				sign = degrees >= 0 ? "N" : "S";
				me["Simple_L1"].setText(abs(degrees) ~ "g" ~ minutes ~ " " ~ sign);
				dms = getprop("FMGC/flightplan[2]/wp[0]/lon");
				degrees = int(dms);
				minutes = sprintf("%.1f",abs((dms - degrees) * 60));
				sign = degrees >= 0 ? "E" : "W";
				me["Simple_R1"].setText(abs(degrees) ~ "g" ~ minutes ~ " " ~ sign);
				me["Simple_C1"].setText(sprintf("%s", depArpt.getValue()));
			} else {
				me["Simple_L1"].setText("-----.--");
				me["Simple_R1"].setText("------.--");
				me["Simple_C1"].setText("----");
			}
			
			dms = getprop("position/latitude-deg");
			degrees = int(dms);
			minutes = sprintf("%.1f",abs((dms - degrees) * 60));
			sign = degrees >= 0 ? "N" : "S";
			me["Simple_L2"].setText(abs(degrees) ~ "g" ~ minutes ~ " " ~ sign);
			dms2 = getprop("position/longitude-deg");
			degrees2 = int(dms2);
			minutes2 = sprintf("%.1f",abs((dms2 - degrees2) * 60));
			sign2 = degrees2 >= 0 ? "E" : "W";
			me["Simple_R2"].setText(abs(degrees2) ~ "g" ~ minutes2 ~ " " ~ sign2);
			if (getprop("systems/navigation/adr/operating-1")) {
				me["Simple_C3"].setText(abs(degrees) ~ "g" ~ minutes ~ " " ~ sign ~ "/" ~ abs(degrees2) ~ "g" ~ minutes2 ~ " " ~ sign2);
			} else {
				me["Simple_C3"].setText("-----.--/-----.--");
			}
			if (getprop("systems/navigation/adr/operating-2")) {
				me["Simple_C4"].setText(abs(degrees) ~ "g" ~ minutes ~ " " ~ sign ~ "/" ~ abs(degrees2) ~ "g" ~ minutes2 ~ " " ~ sign2);
			} else {
				me["Simple_C4"].setText("-----.--/-----.--");
			}
			if (getprop("systems/navigation/adr/operating-3")) {
				me["Simple_C5"].setText(abs(degrees) ~ "g" ~ minutes ~ " " ~ sign ~ "/" ~ abs(degrees2) ~ "g" ~ minutes2 ~ " " ~ sign2);
			} else {
				me["Simple_C5"].setText("-----.--/-----.--");
			}
			
			if (align_set.getValue() == 1) {
				#still need * to right of button instead of arrow
				me["Simple_R6"].setText("CONFIRM ALIGN ");
				me.colorRight("ack", "ack", "ack", "ack", "ack", "amb");
				me.colorRightArrow("ack", "ack", "ack", "ack", "ack", "amb");
			} else {
				me["Simple_R6"].setText("ALIGN ON REF ");
			}
			
			me["Simple_L1S"].setText("LAT");
			me["Simple_L2S"].setText("LAT");
			me["Simple_L6"].setText(" RETURN");
			me["Simple_R1S"].setText("LONG");
			me["Simple_R2S"].setText("LONG");
			me["Simple_C1S"].setText("REFERENCE");
			me["Simple_C2S"].setText("GPS POSITION");
			me["Simple_C3S"].setText("IRS1 ALIGNING ON GPS");
			me["Simple_C4S"].setText("IRS2 ALIGNING ON GPS");
			me["Simple_C5S"].setText("IRS3 ALIGNING ON GPS");

		} else if (page == "ROUTESELECTION") {
			if (!pageSwitch[i].getBoolValue()) {
				me["Simple"].show();
				me["Simple_Center"].show();
				me["FPLN"].hide();
				me["DIRTO_TMPY_group"].hide();
				me["INITA"].hide();
				me["INITB"].hide();
				me["FUELPRED"].hide();
				me["PROG"].hide();
				me["PERFTO"].hide();
				me["arrowsDepArr"].hide();
				me["PERFAPPR"].hide();
				me["PERFGA"].hide();
				me["Simple_Title"].show();
				me["Simple_Title"].setText("ROUTE SELECTION");
				me["Simple_Title"].setColor(1, 1, 1);
				me["Simple_PageNum"].setText("X/X");
				me["Simple_PageNum"].hide();
				me["ArrowLeft"].hide();
				me["ArrowRight"].hide();
				
				me.showLeft(1, -1, -1, -1, -1, 1);
				me["Simple_L0S"].hide();
				me.showLeftS(-1, -1, -1, -1, -1, -1);
				me.showLeftArrow(-1, -1, -1, -1, -1, 1);
				me.showRight(-1, -1, -1, -1, -1, -1);
				me.showRightS(-1, -1, -1, -1, -1, -1);
				me.showRightArrow(-1, -1, -1, -1, -1, -1);
				me.showCenter(-1, -1, -1, -1, -1, -1);
				me.showCenterS(-1, -1, -1, -1, -1, -1);
				
				me.fontLeft(default, 0, 0, 0, 0, default);
				
				me.fontSizeLeft(normal, 0, 0, 0, 0, normal);
				
				me.colorLeft("grn", "ack", "ack", "ack", "ack", "wht");
				
				pageSwitch[i].setBoolValue(1);
			}
			
			me["Simple_L1"].setText("NONE");
			me["Simple_L6"].setText(" RETURN");

			if (toFromSet.getValue() == 1 and alt_selected.getValue() == 0) {
				me["Simple_Title"].setText(sprintf("%s", depArpt.getValue() ~ "/" ~ arrArpt.getValue()));
			} else if (toFromSet.getValue() == 0 and alt_airport.getValue() != "" and alt_selected.getValue() == 1) {
				me["Simple_Title"].setText(sprintf("%s", alt_airport.getValue()));
			} else if (toFromSet.getValue() == 1 and alt_airport.getValue() != "" and alt_selected.getValue() == 1) {
				me["Simple_Title"].setText(sprintf("%s", arrArpt.getValue() ~ "/" ~ alt_airport.getValue()));
			} else {
				me["Simple_Title"].setText("ROUTE SELECTION");
			}

		} else if (page == "INITB") {
			if (!pageSwitch[i].getBoolValue()) {
				me["Simple"].show();
				me["Simple_Center"].show();
				me["FPLN"].hide();
				me["DIRTO_TMPY_group"].hide();
				me["INITA"].hide();
				me["INITB"].show();
				me["FUELPRED"].hide();
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
				me.showCenter(1, -1, -1, -1, -1, -1);
				me.showCenterS(-1, -1, -1, -1, -1, -1);
				me.showRight(-1, 1, 1, 1, 1, 1);
				me.showRightS(1, 1, 1, 1, 1, 1);
				me.showRightArrow(-1, -1, 1, -1, -1, -1);
				
				me.fontLeft(default, default, default, default, default, default);
				me.fontLeftS(default, default, default, default, default, default);
				me.fontRight(default, default, default, default, default, default);
				me.fontRightS(default, default, default, default, default, default);
				
				me.fontSizeLeft(small, small, small, small, small, small);
				me.fontSizeRight(normal, normal, normal, small, small, small);
				
				me.colorLeft("blu", "wht", "wht", "wht", "wht", "wht");
				me.colorLeftS("wht", "wht", "wht", "wht", "wht", "wht");
				me.colorLeftArrow("wht", "wht", "wht", "wht", "wht", "wht");
				me.colorCenter("blu", "wht", "wht", "grn", "wht", "wht");
				me.colorRight("blu", "blu", "amb", "wht", "blu", "wht");
				me.colorRightS("wht", "wht", "amb", "wht", "wht", "wht");
				me.colorRightArrow("wht", "wht", "amb", "wht", "wht", "wht");
				
				pageSwitch[i].setBoolValue(1);
			}
					
			me["Simple_L1S"].setText("TAXI");
			me["Simple_L1"].setText(sprintf("%2.1f", taxi_fuel.getValue()));
			me["Simple_L2S"].setText("TRIP/TIME");
			me["Simple_L3S"].setText("RTE RSV/PCT");
			me["Simple_L4S"].setText("ALTN/TIME");
			me["Simple_L5S"].setText("FINAL/TIME");
			me["Simple_L6S"].setText("MIN DEST FOB");
			me["Simple_R2S"].setText("BLOCK");
			me["Simple_R2"].setText(sprintf("%3.1f", block.getValue()));
			me["Simple_R3S"].setText("FUEL");
			me["Simple_R3"].setText("PLANNING ");
			me["Simple_R4S"].setText("TOW/   LW");
			me["Simple_R5S"].setText("TRIP WIND");
			me["Simple_R5"].setText(trip_wind.getValue());
			me["Simple_R6S"].setText("EXTRA/TIME");
			
			if (blockSet.getValue() == 1 and zfwSet.getValue() == 1) {
				setprop("FMGC/internal/rte-rsv", num((block.getValue() - taxi_fuel.getValue() - min_dest_fob.getValue()) * (rte_percent.getValue() / 100) / (1 + rte_percent.getValue() / 100)));
				setprop("FMGC/internal/trip-fuel", num(block.getValue() - taxi_fuel.getValue() - min_dest_fob.getValue() - rte_rsv.getValue()));
				setprop("FMGC/internal/tow", num(block.getValue() + zfw.getValue() - taxi_fuel.getValue()));
				setprop("FMGC/internal/lw", num(tow.getValue() - trip_fuel.getValue()));
				
				me["Simple_L2"].setText(sprintf("%4.1f/" ~ trip_time.getValue(), trip_fuel.getValue()));
				me["Simple_L3"].setText(sprintf("%4.1f/", rte_rsv.getValue()) ~ sprintf("%4.1f", rte_percent.getValue()));
				me["Simple_L4"].setText(sprintf("%4.1f/" ~ alt_time.getValue(), alt_fuel.getValue()));
				me["Simple_L5"].setText(sprintf("%4.1f/" ~ final_time.getValue(), final_fuel.getValue()));
				me["Simple_L6"].setText(sprintf("%2.1f", min_dest_fob.getValue()));
				me["Simple_R3S"].hide();
				me["Simple_R3"].hide(); 
				me["Simple_R3_Arrow"].hide();
				me["Simple_C4"].hide();
				me["Simple_R4"].setText(sprintf("%4.1f/", tow.getValue()) ~ sprintf("%4.1f", lw.getValue()));
				me["Simple_R6"].setText(sprintf("%4.1f/" ~ extra_time.getValue(), extra_fuel.getValue()));
				
				me["Simple_Title"].setText("INIT FUEL PREDICTION ");
				me["Simple_Title"].setColor(1, 1, 1);
				
				me.colorLeft("ack", "grn", "blu", "blu", "blu", "blu");
				me.colorRight("ack", "ack", "ack", "grn", "ack", "grn");
			} else {
				me["Simple_L2"].setText("---.-/----");
				me["Simple_L3"].setText("---.-/---.-");
				me["Simple_L4"].setText("---.-/----");
				me["Simple_L5"].setText("---.-/0030");
				me["Simple_L6"].setText("---.-");
				me["Simple_R3S"].show();
				me["Simple_R3"].show(); 
				me["Simple_R3_Arrow"].show();
				me["Simple_R4"].setText("---.-/---.-");
				me["Simple_R6"].setText("---.-/----");
				
				me["Simple_Title"].setText("INIT");
				me["Simple_Title"].setColor(1, 1, 1);
			}
			
			me["Simple_R1S"].setText("ZFWCG/   ZFW");
			me["Simple_R1"].setText(sprintf("%3.1f", zfw.getValue()));
			if (zfwcgSet.getValue() == 1) {
				me["Simple_C1"].setFontSize(normal); 
				me["Simple_C1"].setText("        " ~ sprintf("%3.1f", zfwcg.getValue()));
				me["INITB_ZFWCG"].hide();
			} else {
				me["Simple_C1"].setFontSize(small);
				me["Simple_C1"].setText("           " ~ sprintf("%3.1f", zfwcg.getValue()));
				me["INITB_ZFWCG"].hide();
			}
			
			if (zfwSet.getValue() == 1) {
				me["INITB_ZFW"].hide();
				me["INITB_ZFW_S"].show();
				me["Simple_R1"].show(); 
			} else {
				me["INITB_ZFW"].show();
				me["INITB_ZFW_S"].hide();
				me["Simple_R1"].hide(); 
			}
			
			if (blockSet.getValue() == 1) {
				me["Simple_R2"].show();
				me["INITB_Block"].hide();			
			} else {
				me["Simple_R2"].hide(); 
				me["INITB_Block"].show();
			}
			
		} else if (page == "FUELPRED") {
			if (!pageSwitch[i].getBoolValue()) {
				me["Simple"].show();
				me["Simple_Center"].show();
				me["FPLN"].hide();
				me["DIRTO_TMPY_group"].hide();
				me["INITA"].hide();
				me["INITB"].hide();
				me["FUELPRED"].show();
				me["PROG"].hide();
				me["PERFTO"].hide();
				me["arrowsDepArr"].hide();
				me["PERFAPPR"].hide();
				me["PERFGA"].hide();
				me["Simple_Title"].show();
				me["Simple_Title"].setText("FUEL PRED");
				me["Simple_Title"].setColor(1, 1, 1);
				me["Simple_PageNum"].setText("X/X");
				me["Simple_PageNum"].hide();
				me["ArrowLeft"].show();
				me["ArrowRight"].show();
				
				me.showLeft(1, 1, 1, 1, 1, 1);
				me["Simple_L0S"].hide();
				me.showLeftS(1, -1, 1, 1, 1, 1);
				me.showLeftArrow(-1, -1, -1, -1, -1, -1);
				me.showCenter(1, 1, 1, -1, -1, -1);
				me.showCenterS(1, -1, -1, -1, -1, -1);
				me.showRight(1, 1, -1, 1, 1, 1);
				me.showRightS(1, -1, 1, 1, 1, 1);
				me.showRightArrow(-1, -1, -1, -1, -1, -1);
				
				me.fontLeft(default, default, default, default, default, default);
				me.fontLeftS(default, default, default, default, default, default);
				me.fontRight(default, default, default, default, default, default);
				me.fontRightS(default, default, default, default, default, default);
				
				me.fontSizeLeft(normal, normal, small, small, small, small);
				me.fontSizeRight(normal, normal, small, small, small, small);
				
				me.colorLeft("grn", "grn", "wht", "wht", "wht", "wht");
				me.colorLeftS("wht", "wht", "wht", "wht", "wht", "wht");
				me.colorLeftArrow("wht", "wht", "wht", "wht", "wht", "wht");
				me.colorCenter("grn", "grn", "blu", "wht", "wht", "wht");
				me.colorCenterS("wht", "wht", "wht", "wht", "wht", "wht");
				me.colorRight("grn", "grn", "blu", "wht", "wht", "wht");
				me.colorRightS("wht", "wht", "wht", "wht", "wht", "wht");
				me.colorRightArrow("wht", "wht", "wht", "wht", "wht", "wht");
				
				pageSwitch[i].setBoolValue(1);
			}
			
			if (!engrdy.getBoolValue() or toFromSet.getValue() != 1) {
				me["Simple_L1"].setText("----");
			} else {
				me["Simple_L1"].setText(arrArpt.getValue());
			}
			if (!engrdy.getBoolValue() or alt_airport.getValue() == "") {
				me["Simple_L2"].setText("----");
			} else {
				me["Simple_L2"].setText(alt_airport.getValue());
			}
			
			me["Simple_L1S"].setText("AT");
			me["Simple_L2S"].setText("X");
			me["Simple_L3S"].setText("RTE RSV/PCT");
			me["Simple_L4S"].setText("ALTN/TIME");
			me["Simple_L5S"].setText("FINAL/TIME");
			me["Simple_L6S"].setText("MIN DEST FOB");
			
			me["Simple_C1S"].setText("UTC");
			me["Simple_C1"].setText("----");
			me["Simple_C2"].setText("----");
			
			me["Simple_R1"].setText("-.-");
			me["Simple_R2"].setText("-.-");
			me["Simple_R1S"].setText("EFOB");
			me["Simple_R2S"].setText("X");
			me["Simple_R4S"].setText("FOB     ");
			me["Simple_R5S"].setText("   GW/   CG");
			me["Simple_R6S"].setText("EXTRA/TIME");
			
			if (blockSet.getValue() == 1 and zfwSet.getValue() == 1) {
				setprop("FMGC/internal/rte-rsv", num((block.getValue() - taxi_fuel.getValue() - min_dest_fob.getValue()) * (rte_percent.getValue() / 100) / (1 + rte_percent.getValue() / 100)));
				setprop("FMGC/internal/trip-fuel", num(block.getValue() - taxi_fuel.getValue() - min_dest_fob.getValue() - rte_rsv.getValue()));
				setprop("FMGC/internal/tow", num(block.getValue() + zfw.getValue() - taxi_fuel.getValue()));
				setprop("FMGC/internal/lw", num(tow.getValue() - trip_fuel.getValue()));
				
				me["Simple_L3"].setText(sprintf("%4.1f/", rte_rsv.getValue()) ~ sprintf("%4.1f", rte_percent.getValue()));
				me["Simple_L4"].setText(sprintf("%4.1f/" ~ alt_time.getValue(), alt_fuel.getValue()));
				me["Simple_L5"].setText(sprintf("%4.1f/" ~ final_time.getValue(), final_fuel.getValue()));
				me["Simple_L6"].setText(sprintf("%2.1f", min_dest_fob.getValue()));
				
				setprop("FMGC/internal/fob", num(getprop("consumables/fuel/total-fuel-lbs") / 1000));
				setprop("FMGC/internal/gw", num(getprop("fdm/jsbsim/inertia/weight-lbs") / 1000));
				setprop("FMGC/internal/cg", num(getprop("FMGC/internal/zfwcg")));
				me["Simple_R4"].setText(sprintf("%4.1f/" ~ fffq_sensor.getValue(), fob.getValue()));
				me["Simple_R5"].setText(sprintf("%4.1f/", gw.getValue()) ~ sprintf("%4.1f", cg.getValue()));
				me["Simple_R6"].setText(sprintf("%4.1f/" ~ extra_time.getValue(), extra_fuel.getValue()));
				
				me.colorLeft("ack", "ack", "blu", "blu", "blu", "blu");
				me.colorRight("ack", "ack", "blu", "grn", "grn", "grn");
			} else {
				me["Simple_L3"].setText("---.-/---.-");
				me["Simple_L4"].setText("---.-/----");
				me["Simple_L5"].setText("---.-/0030");
				me["Simple_L6"].setText("---.-");

				me["Simple_R4"].setText("---.-/FF+FQ");
				me["Simple_R5"].setText("---.-/---.-");
				me["Simple_R6"].setText("---.-/----");
			}
			
			me["Simple_R3S"].setText("ZFWCG/ZFW");
			me["Simple_R3"].setText(sprintf("%3.1f", zfw.getValue()));
			if (zfwcgSet.getValue() == 1) {
				me["Simple_C3"].setFontSize(normal); 
				me["Simple_C3"].setText("        " ~ sprintf("%3.1f", zfwcg.getValue()));
				me["FUELPRED_ZFWCG"].hide();
			} else {
				me["Simple_C3"].setFontSize(small);
				me["Simple_C3"].setText("           " ~ sprintf("%3.1f", zfwcg.getValue()));
				me["FUELPRED_ZFWCG"].hide();
			}
			
			if (zfwSet.getValue() == 1) {
				me["FUELPRED_ZFW"].hide();
				me["FUELPRED_ZFW_S"].show();
				me["Simple_R3"].show(); 
			} else {
				me["FUELPRED_ZFW"].show();
				me["FUELPRED_ZFW_S"].hide();
				me["Simple_R3"].hide(); 
			}
			
		} else if (page == "PROGTO" or page == "PROGCLB" or page == "PROGCRZ" or page == "PROGDES") {
			if (getprop("FMGC/status/phase") == 0 or getprop("FMGC/status/phase") == 1) {
				setprop("MCDU[" ~ i ~ "]/page", "PROGTO");
				page = "PROGTO";
			} else if (getprop("FMGC/status/phase") == 2) {
				setprop("MCDU[" ~ i ~ "]/page", "PROGCLB");
				page = "PROGCLB";
			} else if (getprop("FMGC/status/phase") == 3) {
				setprop("MCDU[" ~ i ~ "]/page", "PROGCRZ");
				page = "PROGCRZ";
			} else if (getprop("FMGC/status/phase") == 4 or getprop("FMGC/status/phase") == 5 or getprop("FMGC/status/phase") == 6) {
				setprop("MCDU[" ~ i ~ "]/page", "PROGDES");
				page = "PROGDES";
			}
			
			if (!pageSwitch[i].getBoolValue()) {
				me["Simple"].show();
				me["Simple_Center"].show();
				me["FPLN"].hide();
				me["DIRTO_TMPY_group"].hide();
				me["INITA"].hide();
				me["INITB"].hide();
				me["FUELPRED"].hide();
				me["PROG"].show();
				me["PERFTO"].hide();
				me["arrowsDepArr"].hide();
				me["PERFAPPR"].hide();
				me["PERFGA"].hide();
				
				if (flightNumSet.getValue() == 1) {
					if (page == "PROGTO") {
						me["Simple_Title"].setText(sprintf("TAKE OFF %s", flightNum.getValue()));
					} else if (page == "PROGCLB") {
						me["Simple_Title"].setText(sprintf("CLIMB %s", flightNum.getValue()));
					} else if (page == "PROGCRZ") {
						me["Simple_Title"].setText(sprintf("CRUISE %s", flightNum.getValue()));
					} else if (page == "PROGDES") {
						me["Simple_Title"].setText(sprintf("DESCENT %s", flightNum.getValue()));
					}
				} else {
					if (page == "PROGTO") {
						me["Simple_Title"].setText("TAKE OFF");
					} else if (page == "PROGCLB") {
						me["Simple_Title"].setText("CLIMB");
					} else if (page == "PROGCRZ") {
						me["Simple_Title"].setText("CRUISE");
					} else if (page == "PROGDES") {
						me["Simple_Title"].setText("DESCENT");
					}
				}
				
				me["Simple_Title"].show();
				me["Simple_Title"].setColor(0.0509,0.7529,0.2941);
				me["Simple_PageNum"].setText("X/X");
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
				if (getprop("it-autoflight/input/alt") > cruiseFL_prog.getValue() * 100) {
					me["Simple_L1"].setText(sprintf("%s", "FL" ~ getprop("it-autoflight/input/alt") / 100));
				} else {
					me["Simple_L1"].setText(sprintf("%s", "FL" ~ cruiseFL_prog.getValue()));
				}
			} else {
				me["Simple_L1"].setText("----");
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
			me["Simple_L4"].setText(" ---g /----.-");
			me["Simple_L5"].setText(" GPS");
			me["Simple_L6"].setText("----");
			me["Simple_L1S"].setText(" CRZ");
			me["Simple_L3S"].setText(" UPDATE AT");
			me["Simple_L4S"].setText("  BRG /DIST");
			me["Simple_L5S"].setText(" PREDICTIVE");
			me["Simple_L6S"].setText("REQUIRED");
			me["Simple_R1"].setText("FL398");
			me["Simple_R2"].setText("VDEV = + 750 FT");
			me["Simple_R4"].setText("[    ]");
			me["Simple_R5"].setText("GPS PRIMARY");
			me["Simple_R6"].setText("----");
			me["Simple_R1S"].setText("REC MAX ");
			me["Simple_R6S"].setText("ESTIMATED");
			me["Simple_C1"].setText("----");
			me["Simple_C1S"].setText("OPT");
			me["Simple_C3S"].setText("CONFIRM UPDATE AT");
			me["Simple_C4"].setText("   TO");
			me["Simple_C6S"].setText("ACCUR");
			me["Simple_C6"].setText("HIGH");
			
		} else if (page == "PERFTO") {
			if (!pageSwitch[i].getBoolValue()) {
				me["Simple"].show();
				me["Simple_Center"].show();
				me["FPLN"].hide();
				me["DIRTO_TMPY_group"].hide();
				me["INITA"].hide();
				me["INITB"].hide();
				me["FUELPRED"].hide();
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
				me.showRight(1, 1, 1, 1, 1, 1);
				me.showRightS(1, 1, 1, 1, 1, 1);
				me.showRightArrow(-1, -1, -1, -1, -1, 1);
				me.showCenter(1, 1, 1, -1, -1, -1);
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
			
			me["Simple_L1"].setText(sprintf("%3.0f", v1.getValue()));
			me["Simple_L2"].setText(sprintf("%3.0f", vr.getValue()));
			me["Simple_L3"].setText(sprintf("%3.0f", v2.getValue()));
			me["Simple_L4"].setText(sprintf("%3.0f", transAlt.getValue()));
			me["Simple_L5"].setText(sprintf("%3.0f", clbReducFt.getValue()) ~ sprintf("/%3.0f", reducFt.getValue()));
			me["Simple_L6"].setText(" TO DATA");
			me["Simple_L1S"].setText(" V1");
			me["Simple_L2S"].setText(" VR");
			me["Simple_L3S"].setText(" V2");
			me["Simple_L4S"].setText("TRANS ALT");
			me["Simple_L5S"].setText("THR RED/ACC");
			me["Simple_L6S"].setText(" UPLINK");
			me["Simple_R2"].setText("[    ]  ");
			me["Simple_R5"].setText(sprintf("%3.0f", engOutAcc.getValue()));
			me["Simple_R6"].setText("PHASE ");
			me["Simple_R1S"].setText("RWY ");
			me["Simple_R2S"].setText("TO SHIFT ");
			me["Simple_R3S"].setText("FLAPS/THS");
			me["Simple_R4S"].setText("FLEX TO TEMP");
			me["Simple_R5S"].setText("ENG OUT ACC");
			me["Simple_R6S"].setText("NEXT ");
			
			if (getprop("FMGC/status/phase") == 1) {
				me["Simple_Title"].setColor(0.0509,0.7529,0.2941);
			} else {
				me["Simple_Title"].setColor(1, 1, 1);
			}
			
			if (v1Set.getValue() == 1) {
				me["PERFTO_V1"].hide();
				me["Simple_L1"].show();
			} else {
				me["PERFTO_V1"].show();
				me["Simple_L1"].hide();
			}
			if (vrSet.getValue() == 1) {
				me["PERFTO_VR"].hide();
				me["Simple_L2"].show();
			} else {
				me["PERFTO_VR"].show();
				me["Simple_L2"].hide();
			}
			if (v2Set.getValue() == 1) {
				me["PERFTO_V2"].hide();
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
			
			if (fmgc.flightPlanController.flightplans[2].departure_runway != nil) {
				me["Simple_R1"].setText(sprintf("%s",fmgc.flightPlanController.flightplans[2].departure_runway.id));
			} else {
				me["Simple_R1"].setText("--- ");
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
				me["Simple_R3"].setText("[  ]/[      ]");
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
			
			if (zfwSet.getValue() == 1 and blockSet.getValue() == 1) {
				me["Simple_C1"].setText(sprintf("%3.0f", getprop("FMGC/internal/computed-speeds/flap2_to")));
				me["Simple_C2"].setText(sprintf("%3.0f", getprop("FMGC/internal/computed-speeds/slat_to")));
				me["Simple_C3"].setText(sprintf("%3.0f", getprop("FMGC/internal/computed-speeds/clean_to")));
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
				me["Simple"].show();
				me["Simple_Center"].show();
				me["FPLN"].hide();
				me["DIRTO_TMPY_group"].hide();
				me["INITA"].hide();
				me["INITB"].hide();
				me["FUELPRED"].hide();
				me["PROG"].hide();
				me["PERFTO"].hide();
				me["arrowsDepArr"].hide();
				me["PERFAPPR"].hide();
				me["PERFGA"].hide();
				me["Simple_Title"].show();
				me["Simple_Title"].setText("CLB");
				me["Simple_Title"].setColor(1, 1, 1);
				me["Simple_PageNum"].setText("X/X");
				me["Simple_PageNum"].hide();
				me["ArrowLeft"].hide();
				me["ArrowRight"].hide();
				
				me.showLeft(1, 1, 1, 1, 1, 1);
				me["Simple_L0S"].hide();
				me.showLeftS(1, 1, 1, 1, 1, 1);
				me.showLeftArrow(-1, -1, -1, -1, 1, 1);
				me.showRight(-1, 1, 1, 1, -1, 1);
				me.showRightS(-1, -1, 1, -1, 1, 1);
				me.showRightArrow(-1, -1, -1, -1, -1, 1);
				me.showCenter(-1, 1, 1, 1, -1, -1);
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
			
			if (getprop("FMGC/status/phase") == 2) {
				me["Simple_Title"].setColor(0.0509,0.7529,0.2941);
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
				} else if (getprop("FMGC/status/phase") == 5) {
					me["Simple_L6S"].setText("");
					me["Simple_L6"].setText("");
					me.colorLeft("ack", "ack", "ack", "ack", "ack", "blu");
					me.colorLeftS("ack", "ack", "ack", "ack", "ack", "blu");
					me.colorLeftArrow("ack", "ack", "ack", "ack", "ack", "blu");
					me.showLeftArrow(0, 0, 0, 0, 0, -1);
				} else {
					setprop("FMGC/internal/activate-once", 0);
					setprop("FMGC/internal/activate-twice", 0);
				}
			} else {
				me["Simple_Title"].setColor(1, 1, 1);
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
				if (getprop("it-autoflight/input/kts-mach")) {
					me["Simple_L4"].setText(sprintf(" %3.3f", getprop("it-autoflight/input/spd-mach")));
				} else {
					me["Simple_L4"].setText(sprintf(" %s", int(getprop("it-autoflight/input/spd-kts"))));
				}
				me.fontLeft(0, 0, 0, default, 0, 0);
			}		
			
			me["Simple_L2S"].setText(" CI");
			if (costIndexSet.getValue() == 1) {
				me["Simple_L2"].setColor(0.0901,0.6039,0.7176);
				me["Simple_L2"].setText(sprintf(" %s", costIndex.getValue()));
			} else {
				me["Simple_L2"].setColor(1,1,1);
				me["Simple_L2"].setText(" ---");
			}
			
			me["Simple_L3S"].setText(" MANAGED");
			if (getprop("it-autoflight/input/kts-mach")) {
				me["Simple_L3"].setText(sprintf(" %3.3f", getprop("FMGC/internal/mng-spd")));
			} else {
				me["Simple_L3"].setText(sprintf(" %s", int(getprop("FMGC/internal/mng-spd"))));
			}
			
			me["Simple_L5S"].setText(" EXPEDITE");
			me["Simple_L5"].setText(" T/O PHASE");
			
			me["Simple_C2"].setText("         PRED TO");
			me["Simple_R2"].setText(sprintf("FL%s", getprop("it-autoflight/input/alt") / 100));
			
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
				me["Simple"].show();
				me["Simple_Center"].show();
				me["FPLN"].hide();
				me["DIRTO_TMPY_group"].hide();
				me["INITA"].hide();
				me["INITB"].hide();
				me["FUELPRED"].hide();
				me["PROG"].hide();
				me["PERFTO"].hide();
				me["arrowsDepArr"].hide();
				me["PERFAPPR"].hide();
				me["PERFGA"].hide();
				me["Simple_Title"].show();
				me["Simple_Title"].setText("CRZ");
				me["Simple_Title"].setColor(1, 1, 1);
				me["Simple_PageNum"].setText("X/X");
				me["Simple_PageNum"].hide();
				me["ArrowLeft"].hide();
				me["ArrowRight"].hide();
				
				me.showLeft(1, 1, 1, 1, -1, 1);
				me["Simple_L0S"].hide();
				me.showLeftS(1, 1, 1, 1, -1, 1);
				me.showLeftArrow(-1, -1, -1, -1, -1, 1);
				me.showRight(1, -1, -1, -1, 1, 1);
				me.showRightS(1, -1, -1, -1, 1, 1);
				me.showRightArrow(-1, -1, -1, -1, -1, 1);
				me.showCenter(1, -1, -1, -1, 1, -1);
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
			
			if (getprop("FMGC/status/phase") == 3) {
				me["Simple_Title"].setColor(0.0509,0.7529,0.2941);

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
				} else if (getprop("FMGC/status/phase") == 5) {
					me["Simple_L6S"].setText("");
					me["Simple_L6"].setText("");
					me.colorLeft("ack", "ack", "ack", "ack", "ack", "blu");
					me.colorLeftS("ack", "ack", "ack", "ack", "ack", "blu");
					me.colorLeftArrow("ack", "ack", "ack", "ack", "ack", "blu");
					me.showLeftArrow(0, 0, 0, 0, 0, -1);
				} else {
					setprop("FMGC/internal/activate-once", 0);
					setprop("FMGC/internal/activate-twice", 0);
				}
			} else {
				me["Simple_Title"].setColor(1, 1, 1);
				
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
				if (getprop("it-autoflight/input/kts-mach")) {
					me["Simple_L4"].setText(sprintf(" %3.3f", getprop("it-autoflight/input/spd-mach")));
				} else {
					me["Simple_L4"].setText(sprintf(" %s", int(getprop("it-autoflight/input/spd-kts"))));
				}
				me.fontLeft(0, 0, 0, default, 0, 0);
			}
			
			if (costIndexSet.getValue() == 1) {
				me["Simple_L2"].setColor(0.0901,0.6039,0.7176);
				me["Simple_L2"].setText(sprintf(" %s", costIndex.getValue()));
			} else {
				me["Simple_L2"].setColor(1,1,1);
				me["Simple_L2"].setText(" ---");
			}
			
			me["Simple_L1S"].setText("ACT MODE");
			me["Simple_L2S"].setText(" CI");
			
			me["Simple_L3S"].setText(" MANAGED");
			if (getprop("it-autoflight/input/kts-mach")) {
				me["Simple_L3"].setText(sprintf(" %3.3f", getprop("FMGC/internal/mng-spd")));
			} else {
				me["Simple_L3"].setText(sprintf(" %s", int(getprop("FMGC/internal/mng-spd"))));
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
				me["Simple"].show();
				me["Simple_Center"].show();
				me["FPLN"].hide();
				me["DIRTO_TMPY_group"].hide();
				me["INITA"].hide();
				me["INITB"].hide();
				me["FUELPRED"].hide();
				me["PROG"].hide();
				me["PERFTO"].hide();
				me["arrowsDepArr"].hide();
				me["PERFAPPR"].hide();
				me["PERFGA"].hide();
				me["Simple_Title"].show();
				me["Simple_Title"].setText("DES");
				me["Simple_Title"].setColor(1, 1, 1);
				me["Simple_PageNum"].setText("X/X");
				me["Simple_PageNum"].hide();
				me["ArrowLeft"].hide();
				me["ArrowRight"].hide();
				
				me.showLeft(1, 1, 1, 1, 1, 1);
				me["Simple_L0S"].hide();
				me.showLeftS(1, 1, 1, 1, -1, 1);
				me.showLeftArrow(-1, -1, -1, -1, -1, 1);
				me.showRight(1, 1, -1, 1, -1, 1);
				me.showRightS(1, -1, 1, -1, -1, 1);
				me.showRightArrow(-1, -1, -1, -1, -1, 1);
				me.showCenter(1, 1, -1, 1, 1, -1);
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
			
			if (getprop("FMGC/status/phase") == 4) {
				me["Simple_Title"].setColor(0.0509,0.7529,0.2941);
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
				} else if (getprop("FMGC/status/phase") == 5) {
					me["Simple_L6S"].setText("");
					me["Simple_L6"].setText("");
					me.colorLeft("ack", "ack", "ack", "ack", "ack", "blu");
					me.colorLeftS("ack", "ack", "ack", "ack", "ack", "blu");
					me.colorLeftArrow("ack", "ack", "ack", "ack", "ack", "blu");
					me.showLeftArrow(0, 0, 0, 0, 0, -1);
				} else {
					setprop("FMGC/internal/activate-once", 0);
					setprop("FMGC/internal/activate-twice", 0);
				}
			} else {
				me["Simple_Title"].setColor(1, 1, 1);
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
				if (getprop("it-autoflight/input/kts-mach")) {
					me["Simple_L4"].setText(sprintf(" %3.3f", getprop("it-autoflight/input/spd-mach")));
				} else {
					me["Simple_L4"].setText(sprintf(" %3.0f", getprop("it-autoflight/input/spd-kts")));
				}
				me.fontLeft(0, 0, 0, default, 0, 0);
			}
			
			if (costIndexSet.getValue() == 1) {
				me["Simple_L2"].setColor(0.0901,0.6039,0.7176);
				me["Simple_L2"].setText(sprintf(" %2.0f", costIndex.getValue()));
			} else {
				me["Simple_L2"].setColor(1,1,1);
				me["Simple_L2"].setText(" ---");
			}
			
			me["Simple_L1S"].setText("ACT MODE");
			me["Simple_L2S"].setText(" CI");
			
			me["Simple_L3S"].setText(" MANAGED");
			if (getprop("it-autoflight/input/kts-mach")) {
				me["Simple_L3"].setText(sprintf(" %3.3f", getprop("FMGC/internal/mng-spd")));
			} else {
				me["Simple_L3"].setText(sprintf(" %3.0f", getprop("FMGC/internal/mng-spd")));
			}
			
			me["Simple_L5"].setText(" EXPEDITE");
			
			me["Simple_R1S"].setText("DEST EFOB");
			me["Simple_R1"].setText("---");
			
			me["Simple_C2"].setText("         PRED TO");
			me["Simple_R2"].setText(sprintf("FL%3.0f", getprop("it-autoflight/input/alt") / 100));
			
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
				me["Simple"].show();
				me["Simple_Center"].show();
				me["FPLN"].hide();
				me["DIRTO_TMPY_group"].hide();
				me["INITA"].hide();
				me["INITB"].hide();
				me["FUELPRED"].hide();
				me["PROG"].hide();
				me["PERFTO"].hide();
				me["arrowsDepArr"].hide();
				me["PERFAPPR"].show();
				me["PERFGA"].hide();
				me["Simple_Title"].show();
				me["Simple_Title"].setText("APPR");
				me["Simple_Title"].setColor(1, 1, 1);
				me["Simple_PageNum"].setText("X/X");
				me["Simple_PageNum"].hide();
				me["ArrowLeft"].hide();
				me["ArrowRight"].hide();
				
				me.showLeft(1, 1, 1, 1, 1, 1);
				me["Simple_L0S"].show();
				me.showLeftS(1, 1, 1, 1, 1, 1);
				me.showLeftArrow(-1, -1, -1, -1, -1, 1);
				me.showRight(1, 1, 1, 1, 1, 1);
				me.showRightS(1, 1, 1, 1, -1, 1);
				me.showRightArrow(-1, -1, -1, -1, -1, 1);
				me.showCenter(1, 1, 1, -1, 1, -1);
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
			
			if (getprop("FMGC/status/phase") == 5) {
				me["Simple_Title"].setColor(0.0509,0.7529,0.2941);
			} else {
				me["Simple_Title"].setColor(1, 1, 1);
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
			if (dest_mag.getValue() != -1 and dest_wind.getValue() != -1) {
				me["Simple_L3"].setText(sprintf("%3.0fg", dest_mag.getValue()) ~ sprintf("/%3.0f", dest_wind.getValue()));
			} else {
				me["Simple_L3"].setText("---g/---");;
			}
			
			me["Simple_L4S"].setText("TRANS ALT");
			me["Simple_L4"].setText(sprintf("%3.0f", transAlt.getValue()));
			
			me["Simple_R1S"].setText("FINAL");
			if (fmgc.flightPlanController.flightplans[2].approach != nil) {
				me["Simple_R1"].setText(sprintf("%s",fmgc.flightPlanController.flightplans[2].approach.id));
			} else {
				me["Simple_R1"].setText("--- ");
			}
			
			me["Simple_R2S"].setText("MDA");
			me["Simple_R2"].setText(" [    ]");
			
			me["Simple_R3S"].setText("DH");
			me["Simple_R3"].setText(" [    ]");
			
			me["Simple_R4S"].setText("LDG CONF  ");
			me["Simple_R4"].setText("CONF3  ");
			me["Simple_R5"].setText("FULL  ");
			if (ldg_config_3_set.getValue() == 1 and ldg_config_f_set.getValue() == 0) {
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
			if (zfwSet.getValue() == 1 and blockSet.getValue() == 1) {
				me["Simple_C1"].setText(sprintf("%3.0f", getprop("FMGC/internal/computed-speeds/flap2_appr")));
				me["Simple_C2"].setText(sprintf("%3.0f", getprop("FMGC/internal/computed-speeds/slat_appr")));
				me["Simple_C3"].setText(sprintf("%3.0f", getprop("FMGC/internal/computed-speeds/clean_appr")));
				me["Simple_C5"].setText(sprintf("%3.0f", getprop("FMGC/internal/computed-speeds/vls_appr")));
				me["Simple_L5"].setText(sprintf("%3.0f", getprop("FMGC/internal/computed-speeds/vapp_appr")));
				me.fontLeft(0, 0, 0, 0, default, 0);
				if (vapp_speed_set.getValue() == 1) {
					me.fontSizeLeft(0, 0, 0, 0, normal, 0);
				} else {
					me.fontSizeLeft(0, 0, 0, 0, small, 0);
				}
			} else {
				me["Simple_C1"].setText(" ---");
				me["Simple_C2"].setText(" ---");
				me["Simple_C3"].setText(" ---");
				me["Simple_C5"].setText(" ---");
				me["Simple_L5"].setText("[    ]  ");
				me.fontLeft(0, 0, 0, 0, symbol, 0);
			}
			
			me["Simple_C1S"].setText("FLP RETR");
			me["Simple_C2S"].setText("SLT RETR");
			me["Simple_C3S"].setText("CLEAN  ");
			me["Simple_C5S"].setText("VLS   ");
		} else if (page == "PERFGA") {
			if (!pageSwitch[i].getBoolValue()) {
				me["Simple"].show();
				me["Simple_Center"].show();
				me["FPLN"].hide();
				me["DIRTO_TMPY_group"].hide();
				me["INITA"].hide();
				me["INITB"].hide();
				me["FUELPRED"].hide();
				me["PROG"].hide();
				me["PERFTO"].hide();
				me["arrowsDepArr"].hide();
				me["PERFAPPR"].hide();
				me["PERFGA"].show();
				me["Simple_Title"].show();
				me["Simple_Title"].setText("GO AROUND");
				me["Simple_Title"].setColor(1, 1, 1);
				me["Simple_PageNum"].setText("X/X");
				me["Simple_PageNum"].hide();
				me["ArrowLeft"].hide();
				me["ArrowRight"].hide();
				
				me.showLeft(-1, -1, -1, -1, 1, 1);
				me["Simple_L0S"].hide();
				me.showLeftS(-1, -1, -1, -1, 1, 1);
				me.showLeftArrow(-1, -1, -1, -1, -1, 1);
				me.showRight(-1, -1, -1, -1, 1, -1);
				me.showRightS(-1, -1, -1, -1, 1, -1);
				me.showRightArrow(-1, -1, -1, -1, -1, -1);
				me.showCenter(1, 1, 1, -1, -1, -1);
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
			
			if (getprop("FMGC/status/phase") == 6) {
				me["Simple_Title"].setColor(0.0509,0.7529,0.2941);
			} else {
				me["Simple_Title"].setColor(1, 1, 1);
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
			
			if (zfwSet.getValue() == 1 and blockSet.getValue() == 1) {
				me["Simple_C1"].setText(sprintf("%3.0f", getprop("FMGC/internal/computed-speeds/flap2_appr")));
				me["Simple_C2"].setText(sprintf("%3.0f", getprop("FMGC/internal/computed-speeds/slat_appr")));
				me["Simple_C3"].setText(sprintf("%3.0f", getprop("FMGC/internal/computed-speeds/clean_appr")));
			} else {
				me["Simple_C1"].setText(" ---");
				me["Simple_C2"].setText(" ---");
				me["Simple_C3"].setText(" ---");
			}
			
			me["Simple_C1S"].setText("FLP RETR");
			me["Simple_C2S"].setText("SLT RETR");
			me["Simple_C3S"].setText("CLEAN  ");
		} else if (page == "LATREV") {
			if (!pageSwitch[i].getBoolValue()) {
				me["Simple"].show();
				me["Simple_Center"].show();
				me["FPLN"].hide();
				me["DIRTO_TMPY_group"].hide();
				me["INITA"].hide();
				me["INITB"].hide();
				me["FUELPRED"].hide();
				me["PROG"].hide();
				me["PERFTO"].hide();
				me["arrowsDepArr"].hide();
				me["Simple_PageNum"].setText("X/X");
				me["Simple_PageNum"].hide();
				me["Simple_Title"].show();
				me["ArrowLeft"].hide();
				me["ArrowRight"].hide();
				
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
					me["Simple_Title"].setText(sprintf("%s", myLatRev[i].title[0] ~ myLatRev[i].title[1] ~ myLatRev[i].title[2]));
					
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
					forindex (var matrixArrow; myLatRev[i].arrowsMatrix) {
						if (matrixArrow == 0) { 
							var sign = "L"; 
						} else { 
							var sign = "R"; 
						}
						forindex (var item; myLatRev[i].arrowsMatrix[matrixArrow]) {
							if (myLatRev[i].arrowsMatrix[matrixArrow][item] == 1) {
								me["Simple_" ~ sign ~ (item + 1) ~ "_Arrow"].show();
							} else {
								me["Simple_" ~ sign ~ (item + 1) ~ "_Arrow"].hide();
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
					
					if (myLatRev[i].L1[0] == nil) {
						me["Simple_L1"].hide();
						me["Simple_L1S"].hide();
					} else {
						me["Simple_L1"].show();
						me["Simple_L1"].setText(myLatRev[i].L1[0]);
						if (myLatRev[i].L1[1] != nil) {
							me["Simple_L1S"].show();
							me["Simple_L1S"].setText(myLatRev[i].L1[1]);
						} else {
							me["Simple_L1S"].hide();
						}
					}
					
					if (myLatRev[i].L2[0] == nil) {
						me["Simple_L2"].hide();
						me["Simple_L2S"].hide();
					} else {
						me["Simple_L2"].show();
						me["Simple_L2"].setText(myLatRev[i].L2[0]);
						if (myLatRev[i].L2[1] != nil) {
							me["Simple_L2S"].show();
							me["Simple_L2S"].setText(myLatRev[i].L2[1]);
						} else {
							me["Simple_L2S"].hide();
						}
					}
					
					if (myLatRev[i].L3[0] == nil) {
						me["Simple_L3"].hide();
						me["Simple_L3S"].hide();
					} else {
						me["Simple_L3"].show();
						me["Simple_L3"].setText(myLatRev[i].L3[0]);
						if (myLatRev[i].L3[1] != nil) {
							me["Simple_L3S"].show();
							me["Simple_L3S"].setText(myLatRev[i].L3[1]);
						} else {
							me["Simple_L3S"].hide();
						}
					}
					
					if (myLatRev[i].L4[0] == nil) {
						me["Simple_L4"].hide();
						me["Simple_L4S"].hide();
					} else {
						me["Simple_L4"].show();
						me["Simple_L4"].setText(myLatRev[i].L4[0]);
						if (myLatRev[i].L4[1] != nil) {
							me["Simple_L4S"].show();
							me["Simple_L4S"].setText(myLatRev[i].L4[1]);
						} else {
							me["Simple_L4S"].hide();
						}
					}
					
					if (myLatRev[i].L5[0] == nil) {
						me["Simple_L5"].hide();
						me["Simple_L5S"].hide();
					} else {
						me["Simple_L5"].show();
						me["Simple_L5"].setText(myLatRev[i].L5[0]);
						if (myLatRev[i].L5[1] != nil) {
							me["Simple_L5S"].show();
							me["Simple_L5S"].setText(myLatRev[i].L5[1]);
						} else {
							me["Simple_L5S"].hide();
						}
					}
					
					if (myLatRev[i].L6[0] == nil) {
						me["Simple_L6"].hide();
						me["Simple_L6S"].hide();
					} else {
						me["Simple_L6"].show();
						me["Simple_L6"].setText(myLatRev[i].L6[0]);
						if (myLatRev[i].L6[1] != nil) {
							me["Simple_L6S"].show();
							me["Simple_L6S"].setText(myLatRev[i].L6[1]);
						} else {
							me["Simple_L6S"].hide();
						}
					}
					me.colorLeft(myLatRev[i].L1[2],myLatRev[i].L2[2],myLatRev[i].L3[2],myLatRev[i].L4[2],myLatRev[i].L5[2],myLatRev[i].L6[2]);
					
					if (myLatRev[i].R1[0] == nil) {
						me["Simple_R1"].hide();
						me["Simple_R1S"].hide();
					} else {
						me["Simple_R1"].show();
						me["Simple_R1"].setText(myLatRev[i].R1[0]);
						if (myLatRev[i].R1[1] != nil) {
							me["Simple_R1S"].show();
							me["Simple_R1S"].setText(myLatRev[i].R1[1]);
						} else {
							me["Simple_R1S"].hide();
						}
					}
					
					if (myLatRev[i].R2[0] == nil) {
						me["Simple_R2"].hide();
						me["Simple_R2S"].hide();
					} else {
						me["Simple_R2"].show();
						me["Simple_R2"].setText(myLatRev[i].R2[0]);
						if (myLatRev[i].R2[1] != nil) {
							me["Simple_R2S"].show();
							me["Simple_R2S"].setText(myLatRev[i].R2[1]);
						} else {
							me["Simple_R2S"].hide();
						}
					}
					
					if (myLatRev[i].R3[0] == nil) {
						me["Simple_R3"].hide();
						me["Simple_R3S"].hide();
					} else {
						me["Simple_R3"].show();
						me["Simple_R3"].setText(myLatRev[i].R3[0]);
						if (myLatRev[i].R3[1] != nil) {
							me["Simple_R3S"].show();
							me["Simple_R3S"].setText(myLatRev[i].R3[1]);
						} else {
							me["Simple_R3S"].hide();
						}
					}
					
					if (myLatRev[i].R4[0] == nil) {
						me["Simple_R4"].hide();
						me["Simple_R4S"].hide();
					} else {
						me["Simple_R4"].show();
						me["Simple_R4"].setText(myLatRev[i].R4[0]);
						if (myLatRev[i].R4[1] != nil) {
							me["Simple_R4S"].show();
							me["Simple_R4S"].setText(myLatRev[i].R4[1]);
						} else {
							me["Simple_R4S"].hide();
						}
					}
					
					if (myLatRev[i].R5[0] == nil) {
						me["Simple_R5"].hide();
						me["Simple_R5S"].hide();
					} else {
						me["Simple_R5"].show();
						me["Simple_R5"].setText(myLatRev[i].R5[0]);
						if (myLatRev[i].R5[1] != nil) {
							me["Simple_R5S"].show();
							me["Simple_R5S"].setText(myLatRev[i].R5[1]);
						} else {
							me["Simple_R5S"].hide();
						}
					}
					
					if (myLatRev[i].R6[0] == nil) {
						me["Simple_R6"].hide();
						me["Simple_R6S"].hide();
					} else {
						me["Simple_R6"].show();
						me["Simple_R6"].setText(myLatRev[i].R6[0]);
						if (myLatRev[i].R6[1] != nil) {
							me["Simple_R6S"].show();
							me["Simple_R6S"].setText(myLatRev[i].R6[1]);
						} else {
							me["Simple_R6S"].hide();
						}
					}
					me.colorRight(myLatRev[i].R1[2],myLatRev[i].R2[2],myLatRev[i].R3[2],myLatRev[i].R4[2],myLatRev[i].R5[2],myLatRev[i].R6[2]);
				}
				pageSwitch[i].setBoolValue(1);
			}
		} else if (page == "VERTREV") {
			if (!pageSwitch[i].getBoolValue()) {
				me["Simple"].show();
				me["Simple_Center"].show();
				me["FPLN"].hide();
				me["DIRTO_TMPY_group"].hide();
				me["INITA"].hide();
				me["INITB"].hide();
				me["FUELPRED"].hide();
				me["PROG"].hide();
				me["PERFTO"].hide();
				me["arrowsDepArr"].hide();
				me["Simple_PageNum"].setText("X/X");
				me["Simple_PageNum"].hide();
				me["Simple_Title"].show();
				me["ArrowLeft"].hide();
				me["ArrowRight"].hide();
				
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
					forindex (var matrixArrow; myVertRev[i].arrowsMatrix) {
						if (matrixArrow == 0) { 
							var sign = "L"; 
						} else { 
							var sign = "R"; 
						}
						forindex (var item; myVertRev[i].arrowsMatrix[matrixArrow]) {
							if (myVertRev[i].arrowsMatrix[matrixArrow][item] == 1) {
								me["Simple_" ~ sign ~ (item + 1) ~ "_Arrow"].show();
							} else {
								me["Simple_" ~ sign ~ (item + 1) ~ "_Arrow"].hide();
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
					
					if (myVertRev[i].L1[0] == nil) {
						me["Simple_L1"].hide();
						me["Simple_L1S"].hide();
					} else {
						me["Simple_L1"].show();
						me["Simple_L1"].setText(myVertRev[i].L1[0]);
						if (myVertRev[i].L1[1] != nil) {
							me["Simple_L1S"].show();
							me["Simple_L1S"].setText(myVertRev[i].L1[1]);
						} else {
							me["Simple_L1S"].hide();
						}
					}
					
					if (myVertRev[i].L2[0] == nil) {
						me["Simple_L2"].hide();
						me["Simple_L2S"].hide();
					} else {
						me["Simple_L2"].show();
						me["Simple_L2"].setText(myVertRev[i].L2[0]);
						if (myVertRev[i].L2[1] != nil) {
							me["Simple_L2S"].show();
							me["Simple_L2S"].setText(myVertRev[i].L2[1]);
						} else {
							me["Simple_L2S"].hide();
						}
					}
					
					if (myVertRev[i].L3[0] == nil) {
						me["Simple_L3"].hide();
						me["Simple_L3S"].hide();
					} else {
						me["Simple_L3"].show();
						me["Simple_L3"].setText(myVertRev[i].L3[0]);
						if (myVertRev[i].L3[1] != nil) {
							me["Simple_L3S"].show();
							me["Simple_L3S"].setText(myVertRev[i].L3[1]);
						} else {
							me["Simple_L3S"].hide();
						}
					}
					
					if (myVertRev[i].L4[0] == nil) {
						me["Simple_L4"].hide();
						me["Simple_L4S"].hide();
					} else {
						me["Simple_L4"].show();
						me["Simple_L4"].setText(myVertRev[i].L4[0]);
						if (myVertRev[i].L4[1] != nil) {
							me["Simple_L4S"].show();
							me["Simple_L4S"].setText(myVertRev[i].L4[1]);
						} else {
							me["Simple_L4S"].hide();
						}
					}
					
					if (myVertRev[i].L5[0] == nil) {
						me["Simple_L5"].hide();
						me["Simple_L5S"].hide();
					} else {
						me["Simple_L5"].show();
						me["Simple_L5"].setText(myVertRev[i].L5[0]);
						if (myVertRev[i].L5[1] != nil) {
							me["Simple_L5S"].show();
							me["Simple_L5S"].setText(myVertRev[i].L5[1]);
						} else {
							me["Simple_L5S"].hide();
						}
					}
					
					if (myVertRev[i].L6[0] == nil) {
						me["Simple_L6"].hide();
						me["Simple_L6S"].hide();
					} else {
						me["Simple_L6"].show();
						me["Simple_L6"].setText(myVertRev[i].L6[0]);
						if (myVertRev[i].L6[1] != nil) {
							me["Simple_L6S"].show();
							me["Simple_L6S"].setText(myVertRev[i].L6[1]);
						} else {
							me["Simple_L6S"].hide();
						}
					}
					me.colorLeft(myVertRev[i].L1[2],myVertRev[i].L2[2],myVertRev[i].L3[2],myVertRev[i].L4[2],myVertRev[i].L5[2],myVertRev[i].L6[2]);
					
					if (myVertRev[i].R1[0] == nil) {
						me["Simple_R1"].hide();
						me["Simple_R1S"].hide();
					} else {
						me["Simple_R1"].show();
						me["Simple_R1"].setText(myVertRev[i].R1[0]);
						if (myVertRev[i].R1[1] != nil) {
							me["Simple_R1S"].show();
							me["Simple_R1S"].setText(myVertRev[i].R1[1]);
						} else {
							me["Simple_R1S"].hide();
						}
					}
					
					if (myVertRev[i].R2[0] == nil) {
						me["Simple_R2"].hide();
						me["Simple_R2S"].hide();
					} else {
						me["Simple_R2"].show();
						me["Simple_R2"].setText(myVertRev[i].R2[0]);
						if (myVertRev[i].R2[1] != nil) {
							me["Simple_R2S"].show();
							me["Simple_R2S"].setText(myVertRev[i].R2[1]);
						} else {
							me["Simple_R2S"].hide();
						}
					}
					
					if (myVertRev[i].R3[0] == nil) {
						me["Simple_R3"].hide();
						me["Simple_R3S"].hide();
					} else {
						me["Simple_R3"].show();
						me["Simple_R3"].setText(myVertRev[i].R3[0]);
						if (myVertRev[i].R3[1] != nil) {
							me["Simple_R3S"].show();
							me["Simple_R3S"].setText(myVertRev[i].R3[1]);
						} else {
							me["Simple_R3S"].hide();
						}
					}
					
					if (myVertRev[i].R4[0] == nil) {
						me["Simple_R4"].hide();
						me["Simple_R4S"].hide();
					} else {
						me["Simple_R4"].show();
						me["Simple_R4"].setText(myVertRev[i].R4[0]);
						if (myVertRev[i].R4[1] != nil) {
							me["Simple_R4S"].show();
							me["Simple_R4S"].setText(myVertRev[i].R4[1]);
						} else {
							me["Simple_R4S"].hide();
						}
					}
					
					if (myVertRev[i].R5[0] == nil) {
						me["Simple_R5"].hide();
						me["Simple_R5S"].hide();
					} else {
						me["Simple_R5"].show();
						me["Simple_R5"].setText(myVertRev[i].R5[0]);
						if (myVertRev[i].R5[1] != nil) {
							me["Simple_R5S"].show();
							me["Simple_R5S"].setText(myVertRev[i].R5[1]);
						} else {
							me["Simple_R5S"].hide();
						}
					}
					
					if (myVertRev[i].R6[0] == nil) {
						me["Simple_R6"].hide();
						me["Simple_R6S"].hide();
					} else {
						me["Simple_R6"].show();
						me["Simple_R6"].setText(myVertRev[i].R6[0]);
						if (myVertRev[i].R6[1] != nil) {
							me["Simple_R6S"].show();
							me["Simple_R6S"].setText(myVertRev[i].R6[1]);
						} else {
							me["Simple_R6S"].hide();
						}
					}
					me.colorRight(myVertRev[i].R1[2],myVertRev[i].R2[2],myVertRev[i].R3[2],myVertRev[i].R4[2],myVertRev[i].R5[2],myVertRev[i].R6[2]);
				}
				pageSwitch[i].setBoolValue(1);
			}
		} else if (page == "DEPARTURE") {
			if (!pageSwitch[i].getBoolValue()) {
				me["Simple"].show();
				me["Simple_Center"].show();
				me["FPLN"].hide();
				me["DIRTO_TMPY_group"].hide();
				me["INITA"].hide();
				me["INITB"].hide();
				me["FUELPRED"].hide();
				me["PROG"].hide();
				me["PERFTO"].hide();
				me["Simple_PageNum"].setText("X/X");
				me["Simple_PageNum"].hide();
				me["Simple_Title"].show();
				me["ArrowLeft"].show();
				me["ArrowRight"].show();
				me["arrowsDepArr"].show();
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
				
				me.fontLeft(default, default, default, default, default, default);
				me.fontLeftS(default, default, default, default, default, default);
				me.fontRight(default, default, default, default, default, default);
				me.fontRightS(default, default, default, default, default, default);
				
				me.fontSizeLeft(normal, normal, normal, normal, normal, normal);
				me.fontSizeRight(normal, normal, normal, normal, normal, normal);
				
				me.colorLeftS("wht", "wht", "wht", "wht", "wht", "wht");
				me.colorRightS("wht", "wht", "wht", "wht", "wht", "wht");
				
				
				if (myDeparture[i] != nil) {
					me["Simple_Title"].setText(sprintf("%s", myDeparture[i].title[0] ~ myDeparture[i].title[1] ~ myDeparture[i].title[2]));
					
					forindex (var matrixArrow; myDeparture[i].arrowsMatrix) {
						if (matrixArrow == 0) { 
							var sign = "L"; 
						} else { 
							var sign = "R"; 
						}
						forindex (var item; myDeparture[i].arrowsMatrix[matrixArrow]) {
							if (item == 5) { 
								me["Simple_L6_Arrow"].setColor(getprop("MCDUC/colors/" ~ myDeparture[i].arrowsColour[0][5] ~ "/r"), getprop("MCDUC/colors/" ~ myDeparture[i].arrowsColour[0][5] ~ "/g"), getprop("MCDUC/colors/" ~ myDeparture[i].arrowsColour[0][5] ~ "/b"));
								continue;
							}
							if (myDeparture[i].arrowsMatrix[matrixArrow][item] == 1) {
								me["arrow" ~ (item + 1) ~ sign].show();
								me["arrow" ~ (item + 1) ~ sign].setColor(getprop("MCDUC/colors/" ~ myDeparture[i].arrowsColour[matrixArrow][item] ~ "/r"), getprop("MCDUC/colors/" ~ myDeparture[i].arrowsColour[matrixArrow][item] ~ "/g"), getprop("MCDUC/colors/" ~ myDeparture[i].arrowsColour[matrixArrow][item] ~ "/b"));
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
					
					if (myDeparture[i].L1[0] == nil) {
						me["Simple_L1"].hide();
						me["Simple_L1S"].hide();
					} else {
						me["Simple_L1"].show();
						me["Simple_L1"].setText(myDeparture[i].L1[0]);
						if (myDeparture[i].L1[1] != nil) {
							me["Simple_L1S"].show();
							me["Simple_L1S"].setText(myDeparture[i].L1[1]);
						} else {
							me["Simple_L1S"].hide();
						}
					}
					
					if (myDeparture[i].L2[0] == nil) {
						me["Simple_L2"].hide();
						me["Simple_L2S"].hide();
					} else {
						me["Simple_L2"].show();
						me["Simple_L2"].setText(myDeparture[i].L2[0]);
						if (myDeparture[i].L2[1] != nil) {
							me["Simple_L2S"].show();
							me["Simple_L2S"].setText(myDeparture[i].L2[1]);
						} else {
							me["Simple_L2S"].hide();
						}
					}
					
					if (myDeparture[i].L3[0] == nil) {
						me["Simple_L3"].hide();
						me["Simple_L3S"].hide();
					} else {
						me["Simple_L3"].show();
						me["Simple_L3"].setText(myDeparture[i].L3[0]);
						if (myDeparture[i].L3[1] != nil) {
							me["Simple_L3S"].show();
							me["Simple_L3S"].setText(myDeparture[i].L3[1]);
						} else {
							me["Simple_L3S"].hide();
						}
					}
					
					if (myDeparture[i].L4[0] == nil) {
						me["Simple_L4"].hide();
						me["Simple_L4S"].hide();
					} else {
						me["Simple_L4"].show();
						me["Simple_L4"].setText(myDeparture[i].L4[0]);
						if (myDeparture[i].L4[1] != nil) {
							me["Simple_L4S"].show();
							me["Simple_L4S"].setText(myDeparture[i].L4[1]);
						} else {
							me["Simple_L4S"].hide();
						}
					}
					
					if (myDeparture[i].L5[0] == nil) {
						me["Simple_L5"].hide();
						me["Simple_L5S"].hide();
					} else {
						me["Simple_L5"].show();
						me["Simple_L5"].setText(myDeparture[i].L5[0]);
						if (myDeparture[i].L5[1] != nil) {
							me["Simple_L5S"].show();
							me["Simple_L5S"].setText(myDeparture[i].L5[1]);
						} else {
							me["Simple_L5S"].hide();
						}
					}
					
					if (myDeparture[i].L6[0] == nil) {
						me["Simple_L6"].hide();
						me["Simple_L6S"].hide();
					} else {
						me["Simple_L6"].show();
						me["Simple_L6"].setText(myDeparture[i].L6[0]);
						if (myDeparture[i].L6[1] != nil) {
							me["Simple_L6S"].show();
							me["Simple_L6S"].setText(myDeparture[i].L6[1]);
						} else {
							me["Simple_L6S"].hide();
						}
					}
					me.colorLeft(myDeparture[i].L1[2],myDeparture[i].L2[2],myDeparture[i].L3[2],myDeparture[i].L4[2],myDeparture[i].L5[2],myDeparture[i].L6[2]);
					
					if (myDeparture[i].C1[0] == nil) {
						me["Simple_C1"].hide();
						me["Simple_C1S"].hide();
					} else {
						me["Simple_C1"].show();
						me["Simple_C1"].setText(myDeparture[i].C1[0]);
						if (myDeparture[i].C1[1] != nil) {
							me["Simple_C1S"].show();
							me["Simple_C1S"].setText(myDeparture[i].C1[1]);
						} else {
							me["Simple_C1S"].hide();
						}
					}
					
					if (myDeparture[i].C2[0] == nil) {
						me["Simple_C2"].hide();
						me["Simple_C2S"].hide();
					} else {
						me["Simple_C2"].show();
						me["Simple_C2"].setText(myDeparture[i].C2[0]);
						if (myDeparture[i].C2[1] != nil) {
							me["Simple_C2S"].show();
							me["Simple_C2S"].setText(myDeparture[i].C2[1]);
						} else {
							me["Simple_C2S"].hide();
						}
					}
					
					if (myDeparture[i].C3[0] == nil) {
						me["Simple_C3"].hide();
						me["Simple_C3S"].hide();
					} else {
						me["Simple_C3"].show();
						me["Simple_C3"].setText(myDeparture[i].C3[0]);
						if (myDeparture[i].C3[1] != nil) {
							me["Simple_C3S"].show();
							me["Simple_C3S"].setText(myDeparture[i].C3[1]);
						} else {
							me["Simple_C3S"].hide();
						}
					}
					
					if (myDeparture[i].C4[0] == nil) {
						me["Simple_C4"].hide();
						me["Simple_C4S"].hide();
					} else {
						me["Simple_C4"].show();
						me["Simple_C4"].setText(myDeparture[i].C4[0]);
						if (myDeparture[i].C4[1] != nil) {
							me["Simple_C4S"].show();
							me["Simple_C4S"].setText(myDeparture[i].C4[1]);
						} else {
							me["Simple_C4S"].hide();
						}
					}
					
					if (myDeparture[i].C5[0] == nil) {
						me["Simple_C5"].hide();
						me["Simple_C5S"].hide();
					} else {
						me["Simple_C5"].show();
						me["Simple_C5"].setText(myDeparture[i].C5[0]);
						if (myDeparture[i].C5[1] != nil) {
							me["Simple_C5S"].show();
							me["Simple_C5S"].setText(myDeparture[i].C5[1]);
						} else {
							me["Simple_C5S"].hide();
						}
					}
					me.colorCenter(myDeparture[i].C1[2],myDeparture[i].C2[2],myDeparture[i].C3[2],myDeparture[i].C4[2],myDeparture[i].C5[2],myDeparture[i].C6[2]);
					
					me["Simple_C6"].hide();
					me["Simple_C6S"].hide();
						
					if (myDeparture[i].R1[0] == nil) {
						me["Simple_R1"].hide();
						me["Simple_R1S"].hide();
					} else {
						me["Simple_R1"].show();
						me["Simple_R1"].setText(myDeparture[i].R1[0]);
						if (myDeparture[i].R1[1] != nil) {
							me["Simple_R1S"].show();
							me["Simple_R1S"].setText(myDeparture[i].R1[1]);
						} else {
							me["Simple_R1S"].hide();
						}
					}
					
					if (myDeparture[i].R2[0] == nil) {
						me["Simple_R2"].hide();
						me["Simple_R2S"].hide();
					} else {
						me["Simple_R2"].show();
						me["Simple_R2"].setText(myDeparture[i].R2[0]);
						if (myDeparture[i].R2[1] != nil) {
							me["Simple_R2S"].show();
							me["Simple_R2S"].setText(myDeparture[i].R2[1]);
						} else {
							me["Simple_R2S"].hide();
						}
					}
					
					if (myDeparture[i].R3[0] == nil) {
						me["Simple_R3"].hide();
						me["Simple_R3S"].hide();
					} else {
						me["Simple_R3"].show();
						me["Simple_R3"].setText(myDeparture[i].R3[0]);
						if (myDeparture[i].R3[1] != nil) {
							me["Simple_R3S"].show();
							me["Simple_R3S"].setText(myDeparture[i].R3[1]);
						} else {
							me["Simple_R3S"].hide();
						}
					}
					
					if (myDeparture[i].R4[0] == nil) {
						me["Simple_R4"].hide();
						me["Simple_R4S"].hide();
					} else {
						me["Simple_R4"].show();
						me["Simple_R4"].setText(myDeparture[i].R4[0]);
						if (myDeparture[i].R4[1] != nil) {
							me["Simple_R4S"].show();
							me["Simple_R4S"].setText(myDeparture[i].R4[1]);
						} else {
							me["Simple_R4S"].hide();
						}
					}
					
					if (myDeparture[i].R5[0] == nil) {
						me["Simple_R5"].hide();
						me["Simple_R5S"].hide();
					} else {
						me["Simple_R5"].show();
						me["Simple_R5"].setText(myDeparture[i].R5[0]);
						if (myDeparture[i].R5[1] != nil) {
							me["Simple_R5S"].show();
							me["Simple_R5S"].setText(myDeparture[i].R5[1]);
						} else {
							me["Simple_R5S"].hide();
						}
					}
					
					if (myDeparture[i].R6[0] == nil) {
						me["Simple_R6"].hide();
						me["Simple_R6S"].hide();
					} else {
						me["Simple_R6"].show();
						me["Simple_R6"].setText(myDeparture[i].R6[0]);
						if (myDeparture[i].R6[1] != nil) {
							me["Simple_R6S"].show();
							me["Simple_R6S"].setText(myDeparture[i].R6[1]);
						} else {
							me["Simple_R6S"].hide();
						}
					}
					me.colorRight(myDeparture[i].R1[2],myDeparture[i].R2[2],myDeparture[i].R3[2],myDeparture[i].R4[2],myDeparture[i].R5[2],myDeparture[i].R6[2]);
				}
				pageSwitch[i].setBoolValue(1);
			}
		} else if (page == "DUPLICATENAMES") {
			if (!pageSwitch[i].getBoolValue()) {
				me["Simple"].show();
				me["Simple_Center"].show();
				me["FPLN"].hide();
				me["DIRTO_TMPY_group"].hide();
				me["INITA"].hide();
				me["INITB"].hide();
				me["FUELPRED"].hide();
				me["PROG"].hide();
				me["PERFTO"].hide();
				me["arrowsDepArr"].hide();
				me["Simple_PageNum"].setText("X/X");
				me["Simple_PageNum"].hide();
				me["Simple_Title"].show();
				me["ArrowLeft"].hide();
				me["ArrowRight"].hide();
				
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
					me["Simple_Title"].setText(sprintf("%s", myDuplicate[i].title));
					
					forindex (var matrixArrow; myDuplicate[i].arrowsMatrix) {
						if (matrixArrow == 0) { 
							var sign = "L"; 
						} else { 
							var sign = "R"; 
						}
						forindex (var item; myDuplicate[i].arrowsMatrix[matrixArrow]) {
							if (myDuplicate[i].arrowsMatrix[matrixArrow][item] == 1) {
								me["Simple_" ~ sign ~ (item + 1) ~ "_Arrow"].show();
							} else {
								me["Simple_" ~ sign ~ (item + 1) ~ "_Arrow"].hide();
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
					
					if (myDuplicate[i].L1[0] == nil) {
						me["Simple_L1"].hide();
						me["Simple_L1S"].hide();
					} else {
						me["Simple_L1"].show();
						me["Simple_L1"].setText(myDuplicate[i].L1[0]);
						if (myDuplicate[i].L1[1] != nil) {
							me["Simple_L1S"].show();
							me["Simple_L1S"].setText(myDuplicate[i].L1[1]);
						} else {
							me["Simple_L1S"].hide();
						}
					}
					
					if (myDuplicate[i].L2[0] == nil) {
						me["Simple_L2"].hide();
						me["Simple_L2S"].hide();
					} else {
						me["Simple_L2"].show();
						me["Simple_L2"].setText(myDuplicate[i].L2[0]);
						if (myDuplicate[i].L2[1] != nil) {
							me["Simple_L2S"].show();
							me["Simple_L2S"].setText(myDuplicate[i].L2[1]);
						} else {
							me["Simple_L2S"].hide();
						}
					}
					
					if (myDuplicate[i].L3[0] == nil) {
						me["Simple_L3"].hide();
						me["Simple_L3S"].hide();
					} else {
						me["Simple_L3"].show();
						me["Simple_L3"].setText(myDuplicate[i].L3[0]);
						if (myDuplicate[i].L3[1] != nil) {
							me["Simple_L3S"].show();
							me["Simple_L3S"].setText(myDuplicate[i].L3[1]);
						} else {
							me["Simple_L3S"].hide();
						}
					}
					
					if (myDuplicate[i].L4[0] == nil) {
						me["Simple_L4"].hide();
						me["Simple_L4S"].hide();
					} else {
						me["Simple_L4"].show();
						me["Simple_L4"].setText(myDuplicate[i].L4[0]);
						if (myDuplicate[i].L4[1] != nil) {
							me["Simple_L4S"].show();
							me["Simple_L4S"].setText(myDuplicate[i].L4[1]);
						} else {
							me["Simple_L4S"].hide();
						}
					}
					
					if (myDuplicate[i].L5[0] == nil) {
						me["Simple_L5"].hide();
						me["Simple_L5S"].hide();
					} else {
						me["Simple_L5"].show();
						me["Simple_L5"].setText(myDuplicate[i].L5[0]);
						if (myDuplicate[i].L5[1] != nil) {
							me["Simple_L5S"].show();
							me["Simple_L5S"].setText(myDuplicate[i].L5[1]);
						} else {
							me["Simple_L5S"].hide();
						}
					}
					
					if (myDuplicate[i].L6[0] == nil) {
						me["Simple_L6"].hide();
						me["Simple_L6S"].hide();
					} else {
						me["Simple_L6"].show();
						me["Simple_L6"].setText(myDuplicate[i].L6[0]);
						if (myDuplicate[i].L6[1] != nil) {
							me["Simple_L6S"].show();
							me["Simple_L6S"].setText(myDuplicate[i].L6[1]);
						} else {
							me["Simple_L6S"].hide();
						}
					}
					me.colorLeft(myDuplicate[i].L1[2],myDuplicate[i].L2[2],myDuplicate[i].L3[2],myDuplicate[i].L4[2],myDuplicate[i].L5[2],myDuplicate[i].L6[2]);
					
					
					if (myDuplicate[i].C1[0] == nil) {
						me["Simple_C1"].hide();
						me["Simple_C1S"].hide();
					} else {
						me["Simple_C1"].show();
						me["Simple_C1"].setText(myDuplicate[i].C1[0]);
						if (myDuplicate[i].C1[1] != nil) {
							me["Simple_C1S"].show();
							me["Simple_C1S"].setText(myDuplicate[i].C1[1]);
						} else {
							me["Simple_C1S"].hide();
						}
					}
					
					if (myDuplicate[i].C2[0] == nil) {
						me["Simple_C2"].hide();
						me["Simple_C2S"].hide();
					} else {
						me["Simple_C2"].show();
						me["Simple_C2"].setText(myDuplicate[i].C2[0]);
						if (myDuplicate[i].C2[1] != nil) {
							me["Simple_C2S"].show();
							me["Simple_C2S"].setText(myDuplicate[i].C2[1]);
						} else {
							me["Simple_C2S"].hide();
						}
					}
					
					if (myDuplicate[i].C3[0] == nil) {
						me["Simple_C3"].hide();
						me["Simple_C3S"].hide();
					} else {
						me["Simple_C3"].show();
						me["Simple_C3"].setText(myDuplicate[i].C3[0]);
						if (myDuplicate[i].C3[1] != nil) {
							me["Simple_C3S"].show();
							me["Simple_C3S"].setText(myDuplicate[i].C3[1]);
						} else {
							me["Simple_C3S"].hide();
						}
					}
					
					if (myDuplicate[i].C4[0] == nil) {
						me["Simple_C4"].hide();
						me["Simple_C4S"].hide();
					} else {
						me["Simple_C4"].show();
						me["Simple_C4"].setText(myDuplicate[i].C4[0]);
						if (myDuplicate[i].C4[1] != nil) {
							me["Simple_C4S"].show();
							me["Simple_C4S"].setText(myDuplicate[i].C4[1]);
						} else {
							me["Simple_C4S"].hide();
						}
					}
					
					if (myDuplicate[i].C5[0] == nil) {
						me["Simple_C5"].hide();
						me["Simple_C5S"].hide();
					} else {
						me["Simple_C5"].show();
						me["Simple_C5"].setText(myDuplicate[i].C5[0]);
						if (myDuplicate[i].C5[1] != nil) {
							me["Simple_C5S"].show();
							me["Simple_C5S"].setText(myDuplicate[i].C5[1]);
						} else {
							me["Simple_C5S"].hide();
						}
					}
					me.colorCenter(myDuplicate[i].C1[2],myDuplicate[i].C2[2],myDuplicate[i].C3[2],myDuplicate[i].C4[2],myDuplicate[i].C5[2],myDuplicate[i].C6[2]);
					
					me["Simple_C6"].hide();
					me["Simple_C6S"].hide();
					
					if (myDuplicate[i].R1[0] == nil) {
						me["Simple_R1"].hide();
						me["Simple_R1S"].hide();
					} else {
						me["Simple_R1"].show();
						me["Simple_R1"].setText(myDuplicate[i].R1[0]);
						if (myDuplicate[i].R1[1] != nil) {
							me["Simple_R1S"].show();
							me["Simple_R1S"].setText(myDuplicate[i].R1[1]);
						} else {
							me["Simple_R1S"].hide();
						}
					}
					
					if (myDuplicate[i].R2[0] == nil) {
						me["Simple_R2"].hide();
						me["Simple_R2S"].hide();
					} else {
						me["Simple_R2"].show();
						me["Simple_R2"].setText(myDuplicate[i].R2[0]);
						if (myDuplicate[i].R2[1] != nil) {
							me["Simple_R2S"].show();
							me["Simple_R2S"].setText(myDuplicate[i].R2[1]);
						} else {
							me["Simple_R2S"].hide();
						}
					}
					
					if (myDuplicate[i].R3[0] == nil) {
						me["Simple_R3"].hide();
						me["Simple_R3S"].hide();
					} else {
						me["Simple_R3"].show();
						me["Simple_R3"].setText(myDuplicate[i].R3[0]);
						if (myDuplicate[i].R3[1] != nil) {
							me["Simple_R3S"].show();
							me["Simple_R3S"].setText(myDuplicate[i].R3[1]);
						} else {
							me["Simple_R3S"].hide();
						}
					}
					
					if (myDuplicate[i].R4[0] == nil) {
						me["Simple_R4"].hide();
						me["Simple_R4S"].hide();
					} else {
						me["Simple_R4"].show();
						me["Simple_R4"].setText(myDuplicate[i].R4[0]);
						if (myDuplicate[i].R4[1] != nil) {
							me["Simple_R4S"].show();
							me["Simple_R4S"].setText(myDuplicate[i].R4[1]);
						} else {
							me["Simple_R4S"].hide();
						}
					}
					
					if (myDuplicate[i].R5[0] == nil) {
						me["Simple_R5"].hide();
						me["Simple_R5S"].hide();
					} else {
						me["Simple_R5"].show();
						me["Simple_R5"].setText(myDuplicate[i].R5[0]);
						if (myDuplicate[i].R5[1] != nil) {
							me["Simple_R5S"].show();
							me["Simple_R5S"].setText(myDuplicate[i].R5[1]);
						} else {
							me["Simple_R5S"].hide();
						}
					}
					
					if (myDuplicate[i].R6[0] == nil) {
						me["Simple_R6"].hide();
						me["Simple_R6S"].hide();
					} else {
						me["Simple_R6"].show();
						me["Simple_R6"].setText(myDuplicate[i].R6[0]);
						if (myDuplicate[i].R6[1] != nil) {
							me["Simple_R6S"].show();
							me["Simple_R6S"].setText(myDuplicate[i].R6[1]);
						} else {
							me["Simple_R6S"].hide();
						}
					}
					me.colorRight(myDuplicate[i].R1[2],myDuplicate[i].R2[2],myDuplicate[i].R3[2],myDuplicate[i].R4[2],myDuplicate[i].R5[2],myDuplicate[i].R6[2]);
				}
				pageSwitch[i].setBoolValue(1);
			}
		} else if (page == "ARRIVAL") {
			if (!pageSwitch[i].getBoolValue()) {
				me["Simple"].show();
				me["Simple_Center"].show();
				me["FPLN"].hide();
				me["DIRTO_TMPY_group"].hide();
				me["INITA"].hide();
				me["INITB"].hide();
				me["FUELPRED"].hide();
				me["PROG"].hide();
				me["PERFTO"].hide();
				me["Simple_PageNum"].setText("X/X");
				me["Simple_PageNum"].hide();
				me["Simple_Title"].show();
				me["ArrowLeft"].show();
				me["ArrowRight"].show();
				me["arrowsDepArr"].show();
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
				
				me.fontLeft(default, default, default, default, default, default);
				me.fontLeftS(default, default, default, default, default, default);
				me.fontRight(default, default, default, default, default, default);
				me.fontRightS(default, default, default, default, default, default);
				
				me.fontSizeLeft(normal, normal, normal, normal, normal, normal);
				me.fontSizeRight(normal, normal, normal, normal, normal, normal);
				
				me.colorLeftS("wht", "wht", "wht", "wht", "wht", "wht");
				me.colorRightS("wht", "wht", "wht", "wht", "wht", "wht");
				
				
				if (myArrival[i] != nil) {
					me["Simple_Title"].setText(sprintf("%s", myArrival[i].title[0] ~ myArrival[i].title[1] ~ myArrival[i].title[2]));
					
					forindex (var matrixArrow; myArrival[i].arrowsMatrix) {
						if (matrixArrow == 0) { 
							var sign = "L"; 
						} else { 
							var sign = "R"; 
						}
						forindex (var item; myArrival[i].arrowsMatrix[matrixArrow]) {
							if (item == 5) { 
								me["Simple_L6_Arrow"].setColor(getprop("MCDUC/colors/" ~ myArrival[i].arrowsColour[0][5] ~ "/r"), getprop("MCDUC/colors/" ~ myArrival[i].arrowsColour[0][5] ~ "/g"), getprop("MCDUC/colors/" ~ myArrival[i].arrowsColour[0][5] ~ "/b"));
								continue;
							}
							if (myArrival[i].arrowsMatrix[matrixArrow][item] == 1) {
								me["arrow" ~ (item + 1) ~ sign].show();
								me["arrow" ~ (item + 1) ~ sign].setColor(getprop("MCDUC/colors/" ~ myArrival[i].arrowsColour[matrixArrow][item] ~ "/r"), getprop("MCDUC/colors/" ~ myArrival[i].arrowsColour[matrixArrow][item] ~ "/g"), getprop("MCDUC/colors/" ~ myArrival[i].arrowsColour[matrixArrow][item] ~ "/b"));
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
					
					if (myArrival[i].L1[0] == nil) {
						me["Simple_L1"].hide();
						me["Simple_L1S"].hide();
					} else {
						me["Simple_L1"].show();
						me["Simple_L1"].setText(myArrival[i].L1[0]);
						if (myArrival[i].L1[1] != nil) {
							me["Simple_L1S"].show();
							me["Simple_L1S"].setText(myArrival[i].L1[1]);
						} else {
							me["Simple_L1S"].hide();
						}
					}
					
					if (myArrival[i].L2[0] == nil) {
						me["Simple_L2"].hide();
						me["Simple_L2S"].hide();
					} else {
						me["Simple_L2"].show();
						me["Simple_L2"].setText(myArrival[i].L2[0]);
						if (myArrival[i].L2[1] != nil) {
							me["Simple_L2S"].show();
							me["Simple_L2S"].setText(myArrival[i].L2[1]);
						} else {
							me["Simple_L2S"].hide();
						}
					}
					
					if (myArrival[i].L3[0] == nil) {
						me["Simple_L3"].hide();
						me["Simple_L3S"].hide();
					} else {
						me["Simple_L3"].show();
						me["Simple_L3"].setText(myArrival[i].L3[0]);
						if (myArrival[i].L3[1] != nil) {
							me["Simple_L3S"].show();
							me["Simple_L3S"].setText(myArrival[i].L3[1]);
						} else {
							me["Simple_L3S"].hide();
						}
					}
					
					if (myArrival[i].L4[0] == nil) {
						me["Simple_L4"].hide();
						me["Simple_L4S"].hide();
					} else {
						me["Simple_L4"].show();
						me["Simple_L4"].setText(myArrival[i].L4[0]);
						if (myArrival[i].L4[1] != nil) {
							me["Simple_L4S"].show();
							me["Simple_L4S"].setText(myArrival[i].L4[1]);
						} else {
							me["Simple_L4S"].hide();
						}
					}
					
					if (myArrival[i].L5[0] == nil) {
						me["Simple_L5"].hide();
						me["Simple_L5S"].hide();
					} else {
						me["Simple_L5"].show();
						me["Simple_L5"].setText(myArrival[i].L5[0]);
						if (myArrival[i].L5[1] != nil) {
							me["Simple_L5S"].show();
							me["Simple_L5S"].setText(myArrival[i].L5[1]);
						} else {
							me["Simple_L5S"].hide();
						}
					}
					
					if (myArrival[i].L6[0] == nil) {
						me["Simple_L6"].hide();
						me["Simple_L6S"].hide();
					} else {
						me["Simple_L6"].show();
						me["Simple_L6"].setText(myArrival[i].L6[0]);
						if (myArrival[i].L6[1] != nil) {
							me["Simple_L6S"].show();
							me["Simple_L6S"].setText(myArrival[i].L6[1]);
						} else {
							me["Simple_L6S"].hide();
						}
					}
					me.colorLeft(myArrival[i].L1[2],myArrival[i].L2[2],myArrival[i].L3[2],myArrival[i].L4[2],myArrival[i].L5[2],myArrival[i].L6[2]);
					
					if (myArrival[i].C1[0] == nil) {
						me["Simple_C1"].hide();
						me["Simple_C1S"].hide();
					} else {
						me["Simple_C1"].show();
						me["Simple_C1"].setText(myArrival[i].C1[0]);
						if (myArrival[i].C1[1] != nil) {
							me["Simple_C1S"].show();
							me["Simple_C1S"].setText(myArrival[i].C1[1]);
						} else {
							me["Simple_C1S"].hide();
						}
					}
					
					if (myArrival[i].C2[0] == nil) {
						me["Simple_C2"].hide();
						me["Simple_C2S"].hide();
					} else {
						me["Simple_C2"].show();
						me["Simple_C2"].setText(myArrival[i].C2[0]);
						if (myArrival[i].C2[1] != nil) {
							me["Simple_C2S"].show();
							me["Simple_C2S"].setText(myArrival[i].C2[1]);
						} else {
							me["Simple_C2S"].hide();
						}
					}
					
					if (myArrival[i].C3[0] == nil) {
						me["Simple_C3"].hide();
						me["Simple_C3S"].hide();
					} else {
						me["Simple_C3"].show();
						me["Simple_C3"].setText(myArrival[i].C3[0]);
						if (myArrival[i].C3[1] != nil) {
							me["Simple_C3S"].show();
							me["Simple_C3S"].setText(myArrival[i].C3[1]);
						} else {
							me["Simple_C3S"].hide();
						}
					}
					
					if (myArrival[i].C4[0] == nil) {
						me["Simple_C4"].hide();
						me["Simple_C4S"].hide();
					} else {
						me["Simple_C4"].show();
						me["Simple_C4"].setText(myArrival[i].C4[0]);
						if (myArrival[i].C4[1] != nil) {
							me["Simple_C4S"].show();
							me["Simple_C4S"].setText(myArrival[i].C4[1]);
						} else {
							me["Simple_C4S"].hide();
						}
					}
					
					if (myArrival[i].C5[0] == nil) {
						me["Simple_C5"].hide();
						me["Simple_C5S"].hide();
					} else {
						me["Simple_C5"].show();
						me["Simple_C5"].setText(myArrival[i].C5[0]);
						if (myArrival[i].C5[1] != nil) {
							me["Simple_C5S"].show();
							me["Simple_C5S"].setText(myArrival[i].C5[1]);
						} else {
							me["Simple_C5S"].hide();
						}
					}
					me.colorCenter(myArrival[i].C1[2],myArrival[i].C2[2],myArrival[i].C3[2],myArrival[i].C4[2],myArrival[i].C5[2],myArrival[i].C6[2]);
					
					me["Simple_C6"].hide();
					me["Simple_C6S"].hide();
						
					if (myArrival[i].R1[0] == nil) {
						me["Simple_R1"].hide();
						me["Simple_R1S"].hide();
					} else {
						me["Simple_R1"].show();
						me["Simple_R1"].setText(myArrival[i].R1[0]);
						if (myArrival[i].R1[1] != nil) {
							me["Simple_R1S"].show();
							me["Simple_R1S"].setText(myArrival[i].R1[1]);
						} else {
							me["Simple_R1S"].hide();
						}
					}
					
					if (myArrival[i].R2[0] == nil) {
						me["Simple_R2"].hide();
						me["Simple_R2S"].hide();
					} else {
						me["Simple_R2"].show();
						me["Simple_R2"].setText(myArrival[i].R2[0]);
						if (myArrival[i].R2[1] != nil) {
							me["Simple_R2S"].show();
							me["Simple_R2S"].setText(myArrival[i].R2[1]);
						} else {
							me["Simple_R2S"].hide();
						}
					}
					
					if (myArrival[i].R3[0] == nil) {
						me["Simple_R3"].hide();
						me["Simple_R3S"].hide();
					} else {
						me["Simple_R3"].show();
						me["Simple_R3"].setText(myArrival[i].R3[0]);
						if (myArrival[i].R3[1] != nil) {
							me["Simple_R3S"].show();
							me["Simple_R3S"].setText(myArrival[i].R3[1]);
						} else {
							me["Simple_R3S"].hide();
						}
					}
					
					if (myArrival[i].R4[0] == nil) {
						me["Simple_R4"].hide();
						me["Simple_R4S"].hide();
					} else {
						me["Simple_R4"].show();
						me["Simple_R4"].setText(myArrival[i].R4[0]);
						if (myArrival[i].R4[1] != nil) {
							me["Simple_R4S"].show();
							me["Simple_R4S"].setText(myArrival[i].R4[1]);
						} else {
							me["Simple_R4S"].hide();
						}
					}
					
					if (myArrival[i].R5[0] == nil) {
						me["Simple_R5"].hide();
						me["Simple_R5S"].hide();
					} else {
						me["Simple_R5"].show();
						me["Simple_R5"].setText(myArrival[i].R5[0]);
						if (myArrival[i].R5[1] != nil) {
							me["Simple_R5S"].show();
							me["Simple_R5S"].setText(myArrival[i].R5[1]);
						} else {
							me["Simple_R5S"].hide();
						}
					}
					
					if (myArrival[i].R6[0] == nil) {
						me["Simple_R6"].hide();
						me["Simple_R6S"].hide();
					} else {
						me["Simple_R6"].show();
						me["Simple_R6"].setText(myArrival[i].R6[0]);
						if (myArrival[i].R6[1] != nil) {
							me["Simple_R6S"].show();
							me["Simple_R6S"].setText(myArrival[i].R6[1]);
						} else {
							me["Simple_R6S"].hide();
						}
					}
					me.colorRight(myArrival[i].R1[2],myArrival[i].R2[2],myArrival[i].R3[2],myArrival[i].R4[2],myArrival[i].R5[2],myArrival[i].R6[2]);
				}
				pageSwitch[i].setBoolValue(1);
			}
		} else if (page == "HOLD") {
			if (!pageSwitch[i].getBoolValue()) {
				me["Simple"].show();
				me["Simple_Center"].show();
				me["FPLN"].hide();
				me["DIRTO_TMPY_group"].hide();
				me["INITA"].hide();
				me["INITB"].hide();
				me["FUELPRED"].hide();
				me["PROG"].hide();
				me["PERFTO"].hide();
				me["Simple_PageNum"].setText("X/X");
				me["Simple_PageNum"].hide();
				me["Simple_Title"].show();
				me["ArrowLeft"].show();
				me["ArrowRight"].show();
				me["arrowsDepArr"].show();
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
					
					forindex (var matrixArrow; myHold[i].arrowsMatrix) {
						if (matrixArrow == 0) { 
							var sign = "L"; 
						} else { 
							var sign = "R"; 
						}
						forindex (var item; myHold[i].arrowsMatrix[matrixArrow]) {
							if (item == 5) { 
								me["Simple_L6_Arrow"].setColor(getprop("MCDUC/colors/" ~ myHold[i].arrowsColour[0][5] ~ "/r"), getprop("MCDUC/colors/" ~ myHold[i].arrowsColour[0][5] ~ "/g"), getprop("MCDUC/colors/" ~ myHold[i].arrowsColour[0][5] ~ "/b"));
								continue;
							}
							if (myHold[i].arrowsMatrix[matrixArrow][item] == 1) {
								me["arrow" ~ (item + 1) ~ sign].show();
								me["arrow" ~ (item + 1) ~ sign].setColor(getprop("MCDUC/colors/" ~ myHold[i].arrowsColour[matrixArrow][item] ~ "/r"), getprop("MCDUC/colors/" ~ myHold[i].arrowsColour[matrixArrow][item] ~ "/g"), getprop("MCDUC/colors/" ~ myHold[i].arrowsColour[matrixArrow][item] ~ "/b"));
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
					
					if (myHold[i].L1[0] == nil) {
						me["Simple_L1"].hide();
						me["Simple_L1S"].hide();
					} else {
						me["Simple_L1"].show();
						me["Simple_L1"].setText(myHold[i].L1[0]);
						if (myHold[i].L1[1] != nil) {
							me["Simple_L1S"].show();
							me["Simple_L1S"].setText(myHold[i].L1[1]);
						} else {
							me["Simple_L1S"].hide();
						}
					}
					
					if (myHold[i].L2[0] == nil) {
						me["Simple_L2"].hide();
						me["Simple_L2S"].hide();
					} else {
						me["Simple_L2"].show();
						me["Simple_L2"].setText(myHold[i].L2[0]);
						if (myHold[i].L2[1] != nil) {
							me["Simple_L2S"].show();
							me["Simple_L2S"].setText(myHold[i].L2[1]);
						} else {
							me["Simple_L2S"].hide();
						}
					}
					
					if (myHold[i].L3[0] == nil) {
						me["Simple_L3"].hide();
						me["Simple_L3S"].hide();
					} else {
						me["Simple_L3"].show();
						me["Simple_L3"].setText(myHold[i].L3[0]);
						if (myHold[i].L3[1] != nil) {
							me["Simple_L3S"].show();
							me["Simple_L3S"].setText(myHold[i].L3[1]);
						} else {
							me["Simple_L3S"].hide();
						}
					}
					
					if (myHold[i].L4[0] == nil) {
						me["Simple_L4"].hide();
						me["Simple_L4S"].hide();
					} else {
						me["Simple_L4"].show();
						me["Simple_L4"].setText(myHold[i].L4[0]);
						if (myHold[i].L4[1] != nil) {
							me["Simple_L4S"].show();
							me["Simple_L4S"].setText(myHold[i].L4[1]);
						} else {
							me["Simple_L4S"].hide();
						}
					}
					
					if (myHold[i].L5[0] == nil) {
						me["Simple_L5"].hide();
						me["Simple_L5S"].hide();
					} else {
						me["Simple_L5"].show();
						me["Simple_L5"].setText(myHold[i].L5[0]);
						if (myHold[i].L5[1] != nil) {
							me["Simple_L5S"].show();
							me["Simple_L5S"].setText(myHold[i].L5[1]);
						} else {
							me["Simple_L5S"].hide();
						}
					}
					
					if (myHold[i].L6[0] == nil) {
						me["Simple_L6"].hide();
						me["Simple_L6S"].hide();
					} else {
						me["Simple_L6"].show();
						me["Simple_L6"].setText(myHold[i].L6[0]);
						if (myHold[i].L6[1] != nil) {
							me["Simple_L6S"].show();
							me["Simple_L6S"].setText(myHold[i].L6[1]);
						} else {
							me["Simple_L6S"].hide();
						}
					}
					me.colorLeft(myHold[i].L1[2],myHold[i].L2[2],myHold[i].L3[2],myHold[i].L4[2],myHold[i].L5[2],myHold[i].L6[2]);
					
					if (myHold[i].C1[0] == nil) {
						me["Simple_C1"].hide();
						me["Simple_C1S"].hide();
					} else {
						me["Simple_C1"].show();
						me["Simple_C1"].setText(myHold[i].C1[0]);
						if (myHold[i].C1[1] != nil) {
							me["Simple_C1S"].show();
							me["Simple_C1S"].setText(myHold[i].C1[1]);
						} else {
							me["Simple_C1S"].hide();
						}
					}
					
					if (myHold[i].C2[0] == nil) {
						me["Simple_C2"].hide();
						me["Simple_C2S"].hide();
					} else {
						me["Simple_C2"].show();
						me["Simple_C2"].setText(myHold[i].C2[0]);
						if (myHold[i].C2[1] != nil) {
							me["Simple_C2S"].show();
							me["Simple_C2S"].setText(myHold[i].C2[1]);
						} else {
							me["Simple_C2S"].hide();
						}
					}
					
					if (myHold[i].C3[0] == nil) {
						me["Simple_C3"].hide();
						me["Simple_C3S"].hide();
					} else {
						me["Simple_C3"].show();
						me["Simple_C3"].setText(myHold[i].C3[0]);
						if (myHold[i].C3[1] != nil) {
							me["Simple_C3S"].show();
							me["Simple_C3S"].setText(myHold[i].C3[1]);
						} else {
							me["Simple_C3S"].hide();
						}
					}
					
					if (myHold[i].C4[0] == nil) {
						me["Simple_C4"].hide();
						me["Simple_C4S"].hide();
					} else {
						me["Simple_C4"].show();
						me["Simple_C4"].setText(myHold[i].C4[0]);
						if (myHold[i].C4[1] != nil) {
							me["Simple_C4S"].show();
							me["Simple_C4S"].setText(myHold[i].C4[1]);
						} else {
							me["Simple_C4S"].hide();
						}
					}
					
					if (myHold[i].C5[0] == nil) {
						me["Simple_C5"].hide();
						me["Simple_C5S"].hide();
					} else {
						me["Simple_C5"].show();
						me["Simple_C5"].setText(myHold[i].C5[0]);
						if (myHold[i].C5[1] != nil) {
							me["Simple_C5S"].show();
							me["Simple_C5S"].setText(myHold[i].C5[1]);
						} else {
							me["Simple_C5S"].hide();
						}
					}
					me.colorCenter(myHold[i].C1[2],myHold[i].C2[2],myHold[i].C3[2],myHold[i].C4[2],myHold[i].C5[2],myHold[i].C6[2]);
					
					me["Simple_C6"].hide();
					me["Simple_C6S"].hide();
						
					if (myHold[i].R1[0] == nil) {
						me["Simple_R1"].hide();
						me["Simple_R1S"].hide();
					} else {
						me["Simple_R1"].show();
						me["Simple_R1"].setText(myHold[i].R1[0]);
						if (myHold[i].R1[1] != nil) {
							me["Simple_R1S"].show();
							me["Simple_R1S"].setText(myHold[i].R1[1]);
						} else {
							me["Simple_R1S"].hide();
						}
					}
					
					if (myHold[i].R2[0] == nil) {
						me["Simple_R2"].hide();
						me["Simple_R2S"].hide();
					} else {
						me["Simple_R2"].show();
						me["Simple_R2"].setText(myHold[i].R2[0]);
						if (myHold[i].R2[1] != nil) {
							me["Simple_R2S"].show();
							me["Simple_R2S"].setText(myHold[i].R2[1]);
						} else {
							me["Simple_R2S"].hide();
						}
					}
					
					if (myHold[i].R3[0] == nil) {
						me["Simple_R3"].hide();
						me["Simple_R3S"].hide();
					} else {
						me["Simple_R3"].show();
						me["Simple_R3"].setText(myHold[i].R3[0]);
						if (myHold[i].R3[1] != nil) {
							me["Simple_R3S"].show();
							me["Simple_R3S"].setText(myHold[i].R3[1]);
						} else {
							me["Simple_R3S"].hide();
						}
					}
					
					if (myHold[i].R4[0] == nil) {
						me["Simple_R4"].hide();
						me["Simple_R4S"].hide();
					} else {
						me["Simple_R4"].show();
						me["Simple_R4"].setText(myHold[i].R4[0]);
						if (myHold[i].R4[1] != nil) {
							me["Simple_R4S"].show();
							me["Simple_R4S"].setText(myHold[i].R4[1]);
						} else {
							me["Simple_R4S"].hide();
						}
					}
					
					if (myHold[i].R5[0] == nil) {
						me["Simple_R5"].hide();
						me["Simple_R5S"].hide();
					} else {
						me["Simple_R5"].show();
						me["Simple_R5"].setText(myHold[i].R5[0]);
						if (myHold[i].R5[1] != nil) {
							me["Simple_R5S"].show();
							me["Simple_R5S"].setText(myHold[i].R5[1]);
						} else {
							me["Simple_R5S"].hide();
						}
					}
					
					if (myHold[i].R6[0] == nil) {
						me["Simple_R6"].hide();
						me["Simple_R6S"].hide();
					} else {
						me["Simple_R6"].show();
						me["Simple_R6"].setText(myHold[i].R6[0]);
						if (myHold[i].R6[1] != nil) {
							me["Simple_R6S"].show();
							me["Simple_R6S"].setText(myHold[i].R6[1]);
						} else {
							me["Simple_R6S"].hide();
						}
					}
					me.colorRight(myHold[i].R1[2],myHold[i].R2[2],myHold[i].R3[2],myHold[i].R4[2],myHold[i].R5[2],myHold[i].R6[2]);
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
				me["INITB"].hide();
				me["FUELPRED"].hide();
				me["PROG"].hide();
				me["PERFTO"].hide();
				me["arrowsDepArr"].show();
				me["Simple_PageNum"].setText("X/X");
				me["Simple_PageNum"].hide();
				me["Simple_Title"].show();
				me["ArrowLeft"].hide();
				me["ArrowRight"].hide();
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
				me.fontSizeRight(normal, normal, normal, normal, normal, normal);
				
				me.colorLeftS("wht", "wht", "wht", "wht", "wht", "wht");
				me.colorRightS("wht", "wht", "wht", "wht", "wht", "wht");
				me.colorLeftArrow("wht", "wht", "wht", "wht", "wht", "wht");
				me.colorRightArrow("wht", "wht", "wht", "wht", "wht", "wht");
				
				if (myDirTo[i] != nil) {
					me["Simple_Title"].setText(sprintf("%s", myDirTo[i].title[0]));
					me["Simple_Title"].setColor(getprop("MCDUC/colors/" ~ myDirTo[i].titleColour ~ "/r"), getprop("MCDUC/colors/" ~ myDirTo[i].titleColour ~ "/g"), getprop("MCDUC/colors/" ~ myDirTo[i].titleColour ~ "/b"));
					
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
								me["arrow" ~ (item + 1) ~ sign].setColor(getprop("MCDUC/colors/" ~ myDirTo[i].arrowsColour[matrixArrow][item] ~ "/r"), getprop("MCDUC/colors/" ~ myDirTo[i].arrowsColour[matrixArrow][item] ~ "/g"), getprop("MCDUC/colors/" ~ myDirTo[i].arrowsColour[matrixArrow][item] ~ "/b"));
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
						me["DIRTO_TMPY_group"].show();
					} else {
						me["DIRTO_TMPY_group"].hide();
					}
					
					if (myDirTo[i].L1[0] == nil) {
						me["Simple_L1"].hide();
						me["Simple_L1S"].hide();
					} else {
						me["Simple_L1"].show();
						me["Simple_L1"].setText(myDirTo[i].L1[0]);
						if (myDirTo[i].L1[1] != nil) {
							me["Simple_L1S"].show();
							me["Simple_L1S"].setText(myDirTo[i].L1[1]);
						} else {
							me["Simple_L1S"].hide();
						}
					}
					
					if (myDirTo[i].L2[0] == nil) {
						me["Simple_L2"].hide();
						me["Simple_L2S"].hide();
					} else {
						me["Simple_L2"].show();
						me["Simple_L2"].setText(myDirTo[i].L2[0]);
						if (myDirTo[i].L2[1] != nil) {
							me["Simple_L2S"].show();
							me["Simple_L2S"].setText(myDirTo[i].L2[1]);
						} else {
							me["Simple_L2S"].hide();
						}
					}
					
					if (myDirTo[i].L3[0] == nil) {
						me["Simple_L3"].hide();
						me["Simple_L3S"].hide();
					} else {
						me["Simple_L3"].show();
						me["Simple_L3"].setText(myDirTo[i].L3[0]);
						if (myDirTo[i].L3[1] != nil) {
							me["Simple_L3S"].show();
							me["Simple_L3S"].setText(myDirTo[i].L3[1]);
						} else {
							me["Simple_L3S"].hide();
						}
					}
					
					if (myDirTo[i].L4[0] == nil) {
						me["Simple_L4"].hide();
						me["Simple_L4S"].hide();
					} else {
						me["Simple_L4"].show();
						me["Simple_L4"].setText(myDirTo[i].L4[0]);
						if (myDirTo[i].L4[1] != nil) {
							me["Simple_L4S"].show();
							me["Simple_L4S"].setText(myDirTo[i].L4[1]);
						} else {
							me["Simple_L4S"].hide();
						}
					}
					
					if (myDirTo[i].L5[0] == nil) {
						me["Simple_L5"].hide();
						me["Simple_L5S"].hide();
					} else {
						me["Simple_L5"].show();
						me["Simple_L5"].setText(myDirTo[i].L5[0]);
						if (myDirTo[i].L5[1] != nil) {
							me["Simple_L5S"].show();
							me["Simple_L5S"].setText(myDirTo[i].L5[1]);
						} else {
							me["Simple_L5S"].hide();
						}
					}
					
					if (myDirTo[i].L6[0] == nil) {
						me["Simple_L6"].hide();
						me["Simple_L6S"].hide();
					} else {
						me["Simple_L6"].show();
						me["Simple_L6"].setText(myDirTo[i].L6[0]);
						if (myDirTo[i].L6[1] != nil) {
							me["Simple_L6S"].show();
							me["Simple_L6S"].setText(myDirTo[i].L6[1]);
						} else {
							me["Simple_L6S"].hide();
						}
					}
					me.colorLeft(myDirTo[i].L1[2],myDirTo[i].L2[2],myDirTo[i].L3[2],myDirTo[i].L4[2],myDirTo[i].L5[2],myDirTo[i].L6[2]);
					
					if (myDirTo[i].R1[0] == nil) {
						me["Simple_R1"].hide();
						me["Simple_R1S"].hide();
					} else {
						me["Simple_R1"].show();
						me["Simple_R1"].setText(myDirTo[i].R1[0]);
						if (myDirTo[i].R1[1] != nil) {
							me["Simple_R1S"].show();
							me["Simple_R1S"].setText(myDirTo[i].R1[1]);
						} else {
							me["Simple_R1S"].hide();
						}
					}
					
					if (myDirTo[i].R2[0] == nil) {
						me["Simple_R2"].hide();
						me["Simple_R2S"].hide();
					} else {
						me["Simple_R2"].show();
						me["Simple_R2"].setText(myDirTo[i].R2[0]);
						if (myDirTo[i].R2[1] != nil) {
							me["Simple_R2S"].show();
							me["Simple_R2S"].setText(myDirTo[i].R2[1]);
						} else {
							me["Simple_R2S"].hide();
						}
					}
					
					if (myDirTo[i].R3[0] == nil) {
						me["Simple_R3"].hide();
						me["Simple_R3S"].hide();
					} else {
						me["Simple_R3"].show();
						me["Simple_R3"].setText(myDirTo[i].R3[0]);
						if (myDirTo[i].R3[1] != nil) {
							me["Simple_R3S"].show();
							me["Simple_R3S"].setText(myDirTo[i].R3[1]);
						} else {
							me["Simple_R3S"].hide();
						}
					}
					
					if (myDirTo[i].R4[0] == nil) {
						me["Simple_R4"].hide();
						me["Simple_R4S"].hide();
					} else {
						me["Simple_R4"].show();
						me["Simple_R4"].setText(myDirTo[i].R4[0]);
						if (myDirTo[i].R4[1] != nil) {
							me["Simple_R4S"].show();
							me["Simple_R4S"].setText(myDirTo[i].R4[1]);
						} else {
							me["Simple_R4S"].hide();
						}
					}
					
					if (myDirTo[i].R5[0] == nil) {
						me["Simple_R5"].hide();
						me["Simple_R5S"].hide();
					} else {
						me["Simple_R5"].show();
						me["Simple_R5"].setText(myDirTo[i].R5[0]);
						if (myDirTo[i].R5[1] != nil) {
							me["Simple_R5S"].show();
							me["Simple_R5S"].setText(myDirTo[i].R5[1]);
						} else {
							me["Simple_R5S"].hide();
						}
					}
					
					if (myDirTo[i].R6[0] == nil) {
						me["Simple_R6"].hide();
						me["Simple_R6S"].hide();
					} else {
						me["Simple_R6"].show();
						me["Simple_R6"].setText(myDirTo[i].R6[0]);
						if (myDirTo[i].R6[1] != nil) {
							me["Simple_R6S"].show();
							me["Simple_R6S"].setText(myDirTo[i].R6[1]);
						} else {
							me["Simple_R6S"].hide();
						}
					}
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
				me["INITB"].hide();
				me["FUELPRED"].hide();
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
		
		me["Scratchpad"].setText(sprintf("%s", scratchpad[i].getValue()));
	},
	# ack = ignore, wht = white, grn = green, blu = blue, amb = amber, yel = yellow, mag = magenta
	colorLeft: func(a, b, c, d, e, f) {
		if (a != "ack") {
			me["Simple_L1"].setColor(getprop("MCDUC/colors/" ~ a ~ "/r"), getprop("MCDUC/colors/" ~ a ~ "/g"), getprop("MCDUC/colors/" ~ a ~ "/b"));
		}
		if (b != "ack") {
			me["Simple_L2"].setColor(getprop("MCDUC/colors/" ~ b ~ "/r"), getprop("MCDUC/colors/" ~ b ~ "/g"), getprop("MCDUC/colors/" ~ b ~ "/b"));
		}
		if (c != "ack") {
			me["Simple_L3"].setColor(getprop("MCDUC/colors/" ~ c ~ "/r"), getprop("MCDUC/colors/" ~ c ~ "/g"), getprop("MCDUC/colors/" ~ c ~ "/b"));
		}
		if (d != "ack") {
			me["Simple_L4"].setColor(getprop("MCDUC/colors/" ~ d ~ "/r"), getprop("MCDUC/colors/" ~ d ~ "/g"), getprop("MCDUC/colors/" ~ d ~ "/b"));
		}
		if (e != "ack") {
			me["Simple_L5"].setColor(getprop("MCDUC/colors/" ~ e ~ "/r"), getprop("MCDUC/colors/" ~ e ~ "/g"), getprop("MCDUC/colors/" ~ e ~ "/b"));
		}
		if (f != "ack") {
			me["Simple_L6"].setColor(getprop("MCDUC/colors/" ~ f ~ "/r"), getprop("MCDUC/colors/" ~ f ~ "/g"), getprop("MCDUC/colors/" ~ f ~ "/b"));
		}
	},
	colorLeftS: func(a, b, c, d, e, f) {
		if (a != "ack") {
			me["Simple_L1S"].setColor(getprop("MCDUC/colors/" ~ a ~ "/r"), getprop("MCDUC/colors/" ~ a ~ "/g"), getprop("MCDUC/colors/" ~ a ~ "/b"));
		}
		if (b != "ack") {
			me["Simple_L2S"].setColor(getprop("MCDUC/colors/" ~ b ~ "/r"), getprop("MCDUC/colors/" ~ b ~ "/g"), getprop("MCDUC/colors/" ~ b ~ "/b"));
		}
		if (c != "ack") {
			me["Simple_L3S"].setColor(getprop("MCDUC/colors/" ~ c ~ "/r"), getprop("MCDUC/colors/" ~ c ~ "/g"), getprop("MCDUC/colors/" ~ c ~ "/b"));
		}
		if (d != "ack") {
			me["Simple_L4S"].setColor(getprop("MCDUC/colors/" ~ d ~ "/r"), getprop("MCDUC/colors/" ~ d ~ "/g"), getprop("MCDUC/colors/" ~ d ~ "/b"));
		}
		if (e != "ack") {
			me["Simple_L5S"].setColor(getprop("MCDUC/colors/" ~ e ~ "/r"), getprop("MCDUC/colors/" ~ e ~ "/g"), getprop("MCDUC/colors/" ~ e ~ "/b"));
		}
		if (f != "ack") {
			me["Simple_L6S"].setColor(getprop("MCDUC/colors/" ~ f ~ "/r"), getprop("MCDUC/colors/" ~ f ~ "/g"), getprop("MCDUC/colors/" ~ f ~ "/b"));
		}
	},
	colorLeftArrow: func(a, b, c, d, e, f) {
		if (a != "ack") {
			me["Simple_L1_Arrow"].setColor(getprop("MCDUC/colors/" ~ a ~ "/r"), getprop("MCDUC/colors/" ~ a ~ "/g"), getprop("MCDUC/colors/" ~ a ~ "/b"));
		}
		if (b != "ack") {
			me["Simple_L2_Arrow"].setColor(getprop("MCDUC/colors/" ~ b ~ "/r"), getprop("MCDUC/colors/" ~ b ~ "/g"), getprop("MCDUC/colors/" ~ b ~ "/b"));
		}
		if (c != "ack") {
			me["Simple_L3_Arrow"].setColor(getprop("MCDUC/colors/" ~ c ~ "/r"), getprop("MCDUC/colors/" ~ c ~ "/g"), getprop("MCDUC/colors/" ~ c ~ "/b"));
		}
		if (d != "ack") {
			me["Simple_L4_Arrow"].setColor(getprop("MCDUC/colors/" ~ d ~ "/r"), getprop("MCDUC/colors/" ~ d ~ "/g"), getprop("MCDUC/colors/" ~ d ~ "/b"));
		}
		if (e != "ack") {
			me["Simple_L5_Arrow"].setColor(getprop("MCDUC/colors/" ~ e ~ "/r"), getprop("MCDUC/colors/" ~ e ~ "/g"), getprop("MCDUC/colors/" ~ e ~ "/b"));
		}
		if (f != "ack") {
			me["Simple_L6_Arrow"].setColor(getprop("MCDUC/colors/" ~ f ~ "/r"), getprop("MCDUC/colors/" ~ f ~ "/g"), getprop("MCDUC/colors/" ~ f ~ "/b"));
		}
	},
	colorRight: func(a, b, c, d, e, f) {
		if (a != "ack") {
			me["Simple_R1"].setColor(getprop("MCDUC/colors/" ~ a ~ "/r"), getprop("MCDUC/colors/" ~ a ~ "/g"), getprop("MCDUC/colors/" ~ a ~ "/b"));
		}
		if (b != "ack") {
			me["Simple_R2"].setColor(getprop("MCDUC/colors/" ~ b ~ "/r"), getprop("MCDUC/colors/" ~ b ~ "/g"), getprop("MCDUC/colors/" ~ b ~ "/b"));
		}
		if (c != "ack") {
			me["Simple_R3"].setColor(getprop("MCDUC/colors/" ~ c ~ "/r"), getprop("MCDUC/colors/" ~ c ~ "/g"), getprop("MCDUC/colors/" ~ c ~ "/b"));
		}
		if (d != "ack") {
			me["Simple_R4"].setColor(getprop("MCDUC/colors/" ~ d ~ "/r"), getprop("MCDUC/colors/" ~ d ~ "/g"), getprop("MCDUC/colors/" ~ d ~ "/b"));
		}
		if (e != "ack") {
			me["Simple_R5"].setColor(getprop("MCDUC/colors/" ~ e ~ "/r"), getprop("MCDUC/colors/" ~ e ~ "/g"), getprop("MCDUC/colors/" ~ e ~ "/b"));
		}
		if (f != "ack") {
			me["Simple_R6"].setColor(getprop("MCDUC/colors/" ~ f ~ "/r"), getprop("MCDUC/colors/" ~ f ~ "/g"), getprop("MCDUC/colors/" ~ f ~ "/b"));
		}
	},
	colorRightS: func(a, b, c, d, e, f) {
		if (a != "ack") {
			me["Simple_R1S"].setColor(getprop("MCDUC/colors/" ~ a ~ "/r"), getprop("MCDUC/colors/" ~ a ~ "/g"), getprop("MCDUC/colors/" ~ a ~ "/b"));
		}
		if (b != "ack") {
			me["Simple_R2S"].setColor(getprop("MCDUC/colors/" ~ b ~ "/r"), getprop("MCDUC/colors/" ~ b ~ "/g"), getprop("MCDUC/colors/" ~ b ~ "/b"));
		}
		if (c != "ack") {
			me["Simple_R3S"].setColor(getprop("MCDUC/colors/" ~ c ~ "/r"), getprop("MCDUC/colors/" ~ c ~ "/g"), getprop("MCDUC/colors/" ~ c ~ "/b"));
		}
		if (d != "ack") {
			me["Simple_R4S"].setColor(getprop("MCDUC/colors/" ~ d ~ "/r"), getprop("MCDUC/colors/" ~ d ~ "/g"), getprop("MCDUC/colors/" ~ d ~ "/b"));
		}
		if (e != "ack") {
			me["Simple_R5S"].setColor(getprop("MCDUC/colors/" ~ e ~ "/r"), getprop("MCDUC/colors/" ~ e ~ "/g"), getprop("MCDUC/colors/" ~ e ~ "/b"));
		}
		if (f != "ack") {
			me["Simple_R6S"].setColor(getprop("MCDUC/colors/" ~ f ~ "/r"), getprop("MCDUC/colors/" ~ f ~ "/g"), getprop("MCDUC/colors/" ~ f ~ "/b"));
		}
	},
	colorRightArrow: func(a, b, c, d, e, f) {
		if (a != "ack") {
			me["Simple_R1_Arrow"].setColor(getprop("MCDUC/colors/" ~ a ~ "/r"), getprop("MCDUC/colors/" ~ a ~ "/g"), getprop("MCDUC/colors/" ~ a ~ "/b"));
		}
		if (b != "ack") {
			me["Simple_R2_Arrow"].setColor(getprop("MCDUC/colors/" ~ b ~ "/r"), getprop("MCDUC/colors/" ~ b ~ "/g"), getprop("MCDUC/colors/" ~ b ~ "/b"));
		}
		if (c != "ack") {
			me["Simple_R3_Arrow"].setColor(getprop("MCDUC/colors/" ~ c ~ "/r"), getprop("MCDUC/colors/" ~ c ~ "/g"), getprop("MCDUC/colors/" ~ c ~ "/b"));
		}
		if (d != "ack") {
			me["Simple_R4_Arrow"].setColor(getprop("MCDUC/colors/" ~ d ~ "/r"), getprop("MCDUC/colors/" ~ d ~ "/g"), getprop("MCDUC/colors/" ~ d ~ "/b"));
		}
		if (e != "ack") {
			me["Simple_R5_Arrow"].setColor(getprop("MCDUC/colors/" ~ e ~ "/r"), getprop("MCDUC/colors/" ~ e ~ "/g"), getprop("MCDUC/colors/" ~ e ~ "/b"));
		}
		if (f != "ack") {
			me["Simple_R6_Arrow"].setColor(getprop("MCDUC/colors/" ~ f ~ "/r"), getprop("MCDUC/colors/" ~ f ~ "/g"), getprop("MCDUC/colors/" ~ f ~ "/b"));
		}
	},
	colorCenter: func(a, b, c, d, e, f) {
		if (a != "ack") {
			me["Simple_C1"].setColor(getprop("MCDUC/colors/" ~ a ~ "/r"), getprop("MCDUC/colors/" ~ a ~ "/g"), getprop("MCDUC/colors/" ~ a ~ "/b"));
		}
		if (b != "ack") {
			me["Simple_C2"].setColor(getprop("MCDUC/colors/" ~ b ~ "/r"), getprop("MCDUC/colors/" ~ b ~ "/g"), getprop("MCDUC/colors/" ~ b ~ "/b"));
		}
		if (c != "ack") {
			me["Simple_C3"].setColor(getprop("MCDUC/colors/" ~ c ~ "/r"), getprop("MCDUC/colors/" ~ c ~ "/g"), getprop("MCDUC/colors/" ~ c ~ "/b"));
		}
		if (d != "ack") {
			me["Simple_C4"].setColor(getprop("MCDUC/colors/" ~ d ~ "/r"), getprop("MCDUC/colors/" ~ d ~ "/g"), getprop("MCDUC/colors/" ~ d ~ "/b"));
		}
		if (e != "ack") {
			me["Simple_C5"].setColor(getprop("MCDUC/colors/" ~ e ~ "/r"), getprop("MCDUC/colors/" ~ e ~ "/g"), getprop("MCDUC/colors/" ~ e ~ "/b"));
		}
		if (f != "ack") {
			me["Simple_C6"].setColor(getprop("MCDUC/colors/" ~ f ~ "/r"), getprop("MCDUC/colors/" ~ f ~ "/g"), getprop("MCDUC/colors/" ~ f ~ "/b"));
		}
	},
	colorCenterS: func(a, b, c, d, e, f) {
		if (a != "ack") {
			me["Simple_C1S"].setColor(getprop("MCDUC/colors/" ~ a ~ "/r"), getprop("MCDUC/colors/" ~ a ~ "/g"), getprop("MCDUC/colors/" ~ a ~ "/b"));
		}
		if (b != "ack") {
			me["Simple_C2S"].setColor(getprop("MCDUC/colors/" ~ b ~ "/r"), getprop("MCDUC/colors/" ~ b ~ "/g"), getprop("MCDUC/colors/" ~ b ~ "/b"));
		}
		if (c != "ack") {
			me["Simple_C3S"].setColor(getprop("MCDUC/colors/" ~ c ~ "/r"), getprop("MCDUC/colors/" ~ c ~ "/g"), getprop("MCDUC/colors/" ~ c ~ "/b"));
		}
		if (d != "ack") {
			me["Simple_C4S"].setColor(getprop("MCDUC/colors/" ~ d ~ "/r"), getprop("MCDUC/colors/" ~ d ~ "/g"), getprop("MCDUC/colors/" ~ d ~ "/b"));
		}
		if (e != "ack") {
			me["Simple_C5S"].setColor(getprop("MCDUC/colors/" ~ e ~ "/r"), getprop("MCDUC/colors/" ~ e ~ "/g"), getprop("MCDUC/colors/" ~ e ~ "/b"));
		}
		if (f != "ack") {
			me["Simple_C6S"].setColor(getprop("MCDUC/colors/" ~ f ~ "/r"), getprop("MCDUC/colors/" ~ f ~ "/g"), getprop("MCDUC/colors/" ~ f ~ "/b"));
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
	setprop("FMGC/keyboard-left", 1);
	gui.showDialog("mcdu1");
}

var showMCDU2 = func {
	setprop("FMGC/keyboard-right", 1);
	gui.showDialog("mcdu2");
}

setlistener("/MCDU[0]/page", func {
	pageSwitch[0].setBoolValue(0);
}, 0, 0);

setlistener("/MCDU[1]/page", func {
	pageSwitch[1].setBoolValue(0);
}, 0, 0);