# A3XX MCDU

# Copyright (c) 2019 Joshua Davidson (Octal450)

var MCDU_1 = nil;
var MCDU_2 = nil;
var MCDU1_display = nil;
var MCDU2_display = nil;
var myLatRev = nil;
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

var WHITE = [1.0000,1.0000,1.0000];
var GREEN = [0.0509,0.7529,0.2941];
var BLUE = [0.0901,0.6039,0.7176];
var AMBER = [0.7333,0.3803,0.0000];
var YELLOW = [0.9333,0.9333,0.0000];

# Fetch nodes:
var mcdu1_lgt = props.globals.getNode("/controls/lighting/DU/mcdu1", 1);
var mcdu2_lgt = props.globals.getNode("/controls/lighting/DU/mcdu2", 1);
var acType = props.globals.getNode("/MCDUC/type", 1);
var engType = props.globals.getNode("/MCDUC/eng", 1);
var database1 = props.globals.getNode("/FMGC/internal/navdatabase", 1);
var database2 = props.globals.getNode("/FMGC/internal/navdatabase2", 1);
var databaseCode = props.globals.getNode("/FMGC/internal/navdatabasecode", 1);
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
var flightNum = props.globals.getNode("/MCDUC/flight-num", 1);
var flightNumSet = props.globals.getNode("/MCDUC/flight-num-set", 1);
var depArpt = props.globals.getNode("/FMGC/internal/dep-arpt", 1);
var arrArpt = props.globals.getNode("/FMGC/internal/arr-arpt", 1);
var toFromSet = props.globals.getNode("/FMGC/internal/tofrom-set", 1);
var costIndex = props.globals.getNode("/FMGC/internal/cost-index", 1);
var costIndexSet = props.globals.getNode("/FMGC/internal/cost-index-set", 1);
var cruiseFL = props.globals.getNode("/FMGC/internal/cruise-fl", 1);
var cruiseSet = props.globals.getNode("/FMGC/internal/cruise-lvl-set", 1);
var tropo = props.globals.getNode("/FMGC/internal/tropo", 1);
var tropoSet = props.globals.getNode("/FMGC/internal/tropo-set", 1);
var ADIRSMCDUBTN = props.globals.getNode("/controls/adirs/mcducbtn", 1);
var zfwcg = props.globals.getNode("/FMGC/internal/zfwcg", 1);
var zfwcgSet = props.globals.getNode("/FMGC/internal/zfwcg-set", 1);
var zfw = props.globals.getNode("/FMGC/internal/zfw", 1);
var zfwSet = props.globals.getNode("/FMGC/internal/zfw-set", 1);
var block = props.globals.getNode("/FMGC/internal/block", 1);
var blockSet = props.globals.getNode("/FMGC/internal/block-set", 1);
var state1 = props.globals.getNode("/engines/engine[0]/state", 1);
var state2 = props.globals.getNode("/engines/engine[1]/state", 1);
var engrdy = props.globals.getNode("/engines/ready", 1);
var v1 = props.globals.getNode("/FMGC/internal/v1", 1);
var v1Set = props.globals.getNode("/FMGC/internal/v1-set", 1);
var vr = props.globals.getNode("/FMGC/internal/vr", 1);
var vrSet = props.globals.getNode("/FMGC/internal/vr-set", 1);
var v2 = props.globals.getNode("/FMGC/internal/v2", 1);
var v2Set = props.globals.getNode("/FMGC/internal/v2-set", 1);
var clbReducFt = props.globals.getNode("/systems/thrust/clbreduc-ft", 1);
var reducFt = props.globals.getNode("/FMGC/internal/reduc-agl-ft", 1); # It's not AGL anymore
var thrAccSet = props.globals.getNode("/MCDUC/thracc-set", 1);
var flapTO = props.globals.getNode("/FMGC/internal/to-flap", 1);
var THSTO = props.globals.getNode("/FMGC/internal/to-ths", 1);
var flapTHSSet = props.globals.getNode("/FMGC/internal/flap-ths-set", 1);
var flex = props.globals.getNode("/FMGC/internal/flex", 1);
var flexSet = props.globals.getNode("/FMGC/internal/flex-set", 1);
var engOutAcc = props.globals.getNode("/FMGC/internal/eng-out-reduc", 1);
var engOutAccSet = props.globals.getNode("/MCDUC/reducacc-set", 1);
var transAlt = props.globals.getNode("/FMGC/internal/trans-alt", 1);
var managedSpeed = props.globals.getNode("/it-autoflight/input/spd-managed", 1);
var TMPYActive = [props.globals.getNode("/FMGC/internal/tmpy-active[0]"), props.globals.getNode("/FMGC/internal/tmpy-active[1]")];

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
					#   coordinates are top,right,bottom,left (ys, xe, ye, xs) ref: l621 of simgear/canvas/CanvasElement.cxx
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
		
		me.page = canvas_group;
		
		return me;
	},
	getKeys: func() {
		return ["Simple","Simple_Center","Scratchpad","Simple_Title","Simple_PageNum","ArrowLeft","ArrowRight","Simple_L1","Simple_L2","Simple_L3","Simple_L4","Simple_L5","Simple_L6","Simple_L1S","Simple_L2S","Simple_L3S","Simple_L4S","Simple_L5S","Simple_L6S",
		"Simple_L1_Arrow","Simple_L2_Arrow","Simple_L3_Arrow","Simple_L4_Arrow","Simple_L5_Arrow","Simple_L6_Arrow","Simple_R1","Simple_R2","Simple_R3","Simple_R4","Simple_R5","Simple_R6","Simple_R1S","Simple_R2S","Simple_R3S","Simple_R4S","Simple_R5S",
		"Simple_R6S","Simple_R1_Arrow","Simple_R2_Arrow","Simple_R3_Arrow","Simple_R4_Arrow","Simple_R5_Arrow","Simple_R6_Arrow","Simple_C1","Simple_C2","Simple_C3","Simple_C4","Simple_C5","Simple_C6","Simple_C1S","Simple_C2S","Simple_C3S","Simple_C4S",
		"Simple_C5S","Simple_C6S","INITA","INITA_CoRoute","INITA_FltNbr","INITA_CostIndex","INITA_CruiseFLTemp","INITA_FromTo","INITA_InitRequest","INITA_AlignIRS","INITB","INITB_ZFWCG","INITB_ZFW","INITB_ZFW_S","INITB_Block","PERFTO","PERFTO_V1","PERFTO_VR",
		"PERFTO_V2","PERFTO_FE","PERFTO_SE","PERFTO_OE","FPLN","FPLN_From","FPLN_TMPY_group","FPLN_Callsign","FPLN_L1","FPLN_L2","FPLN_L3","FPLN_L4","FPLN_L5","FPLN_L6","FPLN_L1S","FPLN_L2S","FPLN_L3S","FPLN_L4S","FPLN_L5S","FPLN_L6S","FPLN_6_group"];
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
				me["Simple"].hide();
				me["Simple_Center"].hide();
				me["FPLN"].show();
				me["INITA"].hide();
				me["INITB"].hide();
				me["PERFTO"].hide();
				me["Simple_PageNum"].hide();
				me["ArrowLeft"].show();
				me["ArrowRight"].show();
				
				pageSwitch[i].setBoolValue(1);
			}
			
			if (flightNumSet.getValue()) {
				me["FPLN_Callsign"].setText(flightNum.getValue());
				me["FPLN_Callsign"].show();
			} else {
				me["FPLN_Callsign"].hide();
			}
			
			fplnLineSize = size(mcdu.FPLNLines[i].output);
			
			if (fplnLineSize >= 1) {
				fplnl1 = mcdu.FPLNLines[i].output[0].getText();
				if (fplnl1 != "") {
					me["FPLN_L1"].setColor(mcdu.FPLNLines[i].output[0].getColor(i));
					me["FPLN_L1"].setText(fplnl1);
					me["FPLN_L1"].show();
				} else {
					me["FPLN_L1"].hide();
				}
				fplnl1s = mcdu.FPLNLines[i].output[0].getSubText(i);
				if (fplnl1s != "") {
					me["FPLN_L1S"].setText(fplnl1s);
					me["FPLN_L1S"].show();
				} else {
					me["FPLN_L1S"].hide();
				}
			} else {
				me["FPLN_L1"].hide();
				me["FPLN_L1S"].hide();
			}
			
			if (fplnLineSize >= 2) {
				fplnl2 = mcdu.FPLNLines[i].output[1].getText();
				if (fplnl2 != "") {
					me["FPLN_L2"].setColor(mcdu.FPLNLines[i].output[1].getColor(i));
					me["FPLN_L2"].setText(fplnl2);
					me["FPLN_L2"].show();
				} else {
					me["FPLN_L2"].hide();
				}
				fplnl2s = mcdu.FPLNLines[i].output[1].getSubText(i);
				if (fplnl2s != "") {
					me["FPLN_L2S"].setText(fplnl2s);
					me["FPLN_L2S"].show();
				} else {
					me["FPLN_L2S"].hide();
				}
			} else {
				me["FPLN_L2"].hide();
				me["FPLN_L2S"].hide();
			}
			
			if (fplnLineSize >= 3) {
				fplnl3 = mcdu.FPLNLines[i].output[2].getText();
				if (fplnl3 != "") {
					me["FPLN_L3"].setColor(mcdu.FPLNLines[i].output[2].getColor(i));
					me["FPLN_L3"].setText(fplnl3);
					me["FPLN_L3"].show();
				} else {
					me["FPLN_L3"].hide();
				}
				fplnl3s = mcdu.FPLNLines[i].output[2].getSubText(i);
				if (fplnl3s != "") {
					me["FPLN_L3S"].setText(fplnl3s);
					me["FPLN_L3S"].show();
				} else {
					me["FPLN_L3S"].hide();
				}
			} else {
				me["FPLN_L3"].hide();
				me["FPLN_L3S"].hide();
			}
			
			if (fplnLineSize >= 4) {
				fplnl4 = mcdu.FPLNLines[i].output[3].getText();
				if (fplnl4 != "") {
					me["FPLN_L4"].setColor(mcdu.FPLNLines[i].output[3].getColor(i));
					me["FPLN_L4"].setText(fplnl4);
					me["FPLN_L4"].show();
				} else {
					me["FPLN_L4"].hide();
				}
				fplnl4s = mcdu.FPLNLines[i].output[3].getSubText(i);
				if (fplnl4s != "") {
					me["FPLN_L4S"].setText(fplnl4s);
					me["FPLN_L4S"].show();
				} else {
					me["FPLN_L4S"].hide();
				}
			} else {
				me["FPLN_L4"].hide();
				me["FPLN_L4S"].hide();
			}
			
			if (fplnLineSize >= 5) {
				fplnl5 = mcdu.FPLNLines[i].output[4].getText();
				if (fplnl5 != "") {
					me["FPLN_L5"].setColor(mcdu.FPLNLines[i].output[4].getColor(i));
					me["FPLN_L5"].setText(fplnl5);
					me["FPLN_L5"].show();
				} else {
					me["FPLN_L5"].hide();
				}
				fplnl5s = mcdu.FPLNLines[i].output[4].getSubText(i);
				if (fplnl5s != "") {
					me["FPLN_L5S"].setText(fplnl5s);
					me["FPLN_L5S"].show();
				} else {
					me["FPLN_L5S"].hide();
				}
			} else {
				me["FPLN_L5"].hide();
				me["FPLN_L5S"].hide();
			}
			
			if (fplnLineSize >= 6) {
				fplnl6 = mcdu.FPLNLines[i].output[5].getText();
				if (fplnl6 != "") {
					me["FPLN_L6"].setColor(mcdu.FPLNLines[i].output[5].getColor(i));
					me["FPLN_L6"].setText(fplnl6);
					me["FPLN_L6"].show();
				} else {
					me["FPLN_L6"].hide();
				}
				fplnl6s = mcdu.FPLNLines[i].output[5].getSubText(i);
				if (fplnl6s != "") {
					me["FPLN_L6S"].setText(fplnl6s);
					me["FPLN_L6S"].show();
				} else {
					me["FPLN_L6S"].hide();
				}
			} else {
				me["FPLN_L6"].hide();
				me["FPLN_L6S"].hide();
			}
			
			if (mcdu.FPLNLines[i].index == 0) {
				me["FPLN_From"].show();
			} else {
				me["FPLN_From"].hide();
			}
			
			if (TMPYActive[i].getBoolValue()) {
				me["FPLN_TMPY_group"].show();
				me["FPLN_6_group"].hide();
			} else {
				me["FPLN_TMPY_group"].hide();
				me["FPLN_6_group"].show();
			}
		} elsif (page == "MCDU") {
			if (!pageSwitch[i].getBoolValue()) {
				me["Simple"].show();
				me["Simple_Center"].hide();
				me["FPLN"].hide();
				me["INITA"].hide();
				me["INITB"].hide();
				me["PERFTO"].hide();
				me["Simple_Title"].setText("MCDU MENU");
				me["Simple_PageNum"].setText("X/X");
				me["Simple_PageNum"].hide();
				me["ArrowLeft"].hide();
				me["ArrowRight"].hide();
				me["Simple_L1"].show();
				me["Simple_L2"].show();
				me["Simple_L3"].show();
				me["Simple_L4"].show();
				me["Simple_L5"].hide();
				me["Simple_L6"].hide();
				me["Simple_L1S"].hide();
				me["Simple_L2S"].hide();
				me["Simple_L3S"].hide();
				me["Simple_L4S"].hide();
				me["Simple_L5S"].hide();
				me["Simple_L6S"].hide();
				me["Simple_L1_Arrow"].show();
				me["Simple_L2_Arrow"].show();
				me["Simple_L3_Arrow"].show();
				me["Simple_L4_Arrow"].show();
				me["Simple_L5_Arrow"].hide();
				me["Simple_L6_Arrow"].hide();
				me["Simple_R1"].hide();
				me["Simple_R2"].hide();
				me["Simple_R3"].hide();
				me["Simple_R4"].hide();
				me["Simple_R5"].hide();
				me["Simple_R6"].show();
				me["Simple_R1S"].hide();
				me["Simple_R2S"].hide();
				me["Simple_R3S"].hide();
				me["Simple_R4S"].hide();
				me["Simple_R5S"].hide();
				me["Simple_R6S"].hide();
				me["Simple_R1_Arrow"].hide();
				me["Simple_R2_Arrow"].hide();
				me["Simple_R3_Arrow"].hide();
				me["Simple_R4_Arrow"].hide();
				me["Simple_R5_Arrow"].hide();
				me["Simple_R6_Arrow"].show();
				
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
				me["INITA"].hide();
				me["INITB"].hide();
				me["PERFTO"].hide();
				me["Simple_Title"].setText(sprintf("%s", "    " ~ acType.getValue()));
				me["Simple_PageNum"].setText("X/X");
				me["Simple_PageNum"].hide();
				me["ArrowLeft"].hide();
				me["ArrowRight"].hide();
				
				me["Simple_L1"].show();
				me["Simple_L2"].show();
				me["Simple_L3"].show();
				me["Simple_L4"].hide();
				me["Simple_L5"].show();
				me["Simple_L6"].show();
				me["Simple_L1S"].show();
				me["Simple_L2S"].show();
				me["Simple_L3S"].show();
				me["Simple_L4S"].hide();
				me["Simple_L5S"].show();
				me["Simple_L6S"].show();
				me["Simple_L1_Arrow"].hide();
				me["Simple_L2_Arrow"].hide();
				me["Simple_L3_Arrow"].show();
				me["Simple_L4_Arrow"].hide();
				me["Simple_L5_Arrow"].hide();
				me["Simple_L6_Arrow"].hide();
				me["Simple_R1"].hide();
				me["Simple_R2"].show();
				me["Simple_R3"].hide();
				me["Simple_R4"].hide();
				me["Simple_R5"].hide();
				me["Simple_R6"].show(); 
				me["Simple_R1S"].hide();
				me["Simple_R2S"].hide();
				me["Simple_R3S"].hide();
				me["Simple_R4S"].hide();
				me["Simple_R5S"].hide();
				me["Simple_R6S"].show();
				me["Simple_R1_Arrow"].hide();
				me["Simple_R2_Arrow"].hide();
				me["Simple_R3_Arrow"].hide();
				me["Simple_R4_Arrow"].hide();
				me["Simple_R5_Arrow"].hide();
				me["Simple_R6_Arrow"].show();
				
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
				me["INITA"].hide();
				me["INITB"].hide();
				me["PERFTO"].hide();
				me["Simple_Title"].setText("DATA INDEX");
				me["Simple_PageNum"].setText("1/2");
				me["Simple_PageNum"].show();
				me["ArrowLeft"].show();
				me["ArrowRight"].show();
				
				me["Simple_L1"].show();
				me["Simple_L2"].show();
				me["Simple_L3"].show();
				me["Simple_L4"].show();
				me["Simple_L5"].hide();
				me["Simple_L6"].hide();
				me["Simple_L1S"].show();
				me["Simple_L2S"].show();
				me["Simple_L3S"].show();
				me["Simple_L4S"].hide();
				me["Simple_L5S"].hide();
				me["Simple_L6S"].hide();
				me["Simple_L1_Arrow"].show();
				me["Simple_L2_Arrow"].show();
				me["Simple_L3_Arrow"].show();
				me["Simple_L4_Arrow"].show();
				me["Simple_L5_Arrow"].hide();
				me["Simple_L6_Arrow"].hide();
				me["Simple_R1"].hide();
				me["Simple_R2"].hide();
				me["Simple_R3"].hide();
				me["Simple_R4"].hide();
				me["Simple_R5"].show();
				me["Simple_R6"].show();
				me["Simple_R1S"].hide();
				me["Simple_R2S"].hide();
				me["Simple_R3S"].hide();
				me["Simple_R4S"].hide();
				me["Simple_R5S"].show();
				me["Simple_R6S"].show();
				me["Simple_R1_Arrow"].hide();
				me["Simple_R2_Arrow"].hide();
				me["Simple_R3_Arrow"].hide();
				me["Simple_R4_Arrow"].hide();
				me["Simple_R5_Arrow"].show();
				me["Simple_R6_Arrow"].show();
				
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
				me["INITA"].hide();
				me["INITB"].hide();
				me["PERFTO"].hide();
				me["Simple_Title"].setText("DATA INDEX");
				me["Simple_PageNum"].setText("2/2");
				me["Simple_PageNum"].show();
				me["ArrowLeft"].show();
				me["ArrowRight"].show();
				
				me["Simple_L1"].show();
				me["Simple_L2"].show();
				me["Simple_L3"].show();
				me["Simple_L4"].show();
				me["Simple_L5"].show();
				me["Simple_L6"].show();
				me["Simple_L1S"].hide();
				me["Simple_L2S"].hide();
				me["Simple_L3S"].hide();
				me["Simple_L4S"].hide();
				me["Simple_L5S"].show();
				me["Simple_L6S"].show();
				me["Simple_L1_Arrow"].show();
				me["Simple_L2_Arrow"].show();
				me["Simple_L3_Arrow"].show();
				me["Simple_L4_Arrow"].show();
				me["Simple_L5_Arrow"].show();
				me["Simple_L6_Arrow"].show();
				me["Simple_R1"].show();
				me["Simple_R2"].show();
				me["Simple_R3"].show();
				me["Simple_R4"].show();
				me["Simple_R5"].hide();
				me["Simple_R6"].hide();
				me["Simple_R1S"].show();
				me["Simple_R2S"].show();
				me["Simple_R3S"].show();
				me["Simple_R4S"].show();
				me["Simple_R5S"].hide();
				me["Simple_R6S"].hide();
				me["Simple_R1_Arrow"].show();
				me["Simple_R2_Arrow"].show();
				me["Simple_R3_Arrow"].show();
				me["Simple_R4_Arrow"].show();
				me["Simple_R5_Arrow"].hide();
				me["Simple_R6_Arrow"].hide();
				
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
				me["INITA"].hide();
				me["INITB"].hide();
				me["PERFTO"].hide();
				me["Simple_Title"].setText("POSITION MONITOR");
				me["Simple_PageNum"].setText("X/X");
				me["Simple_PageNum"].hide();
				me["ArrowLeft"].hide();
				me["ArrowRight"].hide();
				
				me["Simple_L1"].show();
				me["Simple_L2"].show();
				me["Simple_L3"].show();
				me["Simple_L4"].show();
				me["Simple_L5"].show();
				me["Simple_L6"].show();
				me["Simple_L1S"].hide();
				me["Simple_L2S"].hide();
				me["Simple_L3S"].hide();
				me["Simple_L4S"].hide();
				me["Simple_L5S"].show();
				me["Simple_L6S"].hide();
				me["Simple_L1_Arrow"].hide();
				me["Simple_L2_Arrow"].hide();
				me["Simple_L3_Arrow"].hide();
				me["Simple_L4_Arrow"].hide();
				me["Simple_L5_Arrow"].hide();
				me["Simple_L6_Arrow"].show();
				me["Simple_C1"].hide();
				me["Simple_C2"].hide();
				me["Simple_C3"].hide();
				me["Simple_C4"].hide();
				me["Simple_C5"].show();
				me["Simple_C6"].hide();
				me["Simple_C1S"].hide();
				me["Simple_C2S"].hide();
				me["Simple_C3S"].hide();
				me["Simple_C4S"].hide();
				me["Simple_C5S"].show();
				me["Simple_C6S"].hide();
				me["Simple_R1"].show();
				me["Simple_R2"].show();
				me["Simple_R3"].show();
				me["Simple_R4"].show();
				me["Simple_R5"].show();
				me["Simple_R6"].show();
				me["Simple_R1S"].hide();
				me["Simple_R2S"].hide();
				me["Simple_R3S"].hide();
				me["Simple_R4S"].hide();
				me["Simple_R5S"].show();
				me["Simple_R6S"].show();
				me["Simple_R1_Arrow"].hide();
				me["Simple_R2_Arrow"].hide();
				me["Simple_R3_Arrow"].hide();
				me["Simple_R4_Arrow"].hide();
				me["Simple_R5_Arrow"].hide();
				me["Simple_R6_Arrow"].show();
				
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
			me["Simple_R5S"].setText("IRS3   ");
			me["Simple_R6S"].setText("SEL ");
			me["Simple_C5"].setText("NAV -.-");
			me["Simple_C5S"].setText("IRS2");
		} else if (page == "RADNAV") {
			if (!pageSwitch[i].getBoolValue()) {
				me["Simple"].show();
				me["Simple_Center"].hide();
				me["FPLN"].hide();
				me["INITA"].hide();
				me["INITB"].hide();
				me["PERFTO"].hide();
				me["Simple_Title"].setText("RADIO NAV");
				me["Simple_PageNum"].setText("X/X");
				me["Simple_PageNum"].hide();
				me["ArrowLeft"].hide();
				me["ArrowRight"].hide();
				
				me["Simple_L1"].show();
				me["Simple_L2"].show();
				me["Simple_L3"].show();
				me["Simple_L4"].show();
				me["Simple_L5"].show();
				me["Simple_L6"].hide();
				me["Simple_L1S"].show();
				me["Simple_L2S"].show();
				me["Simple_L3S"].show();
				me["Simple_L4S"].show();
				me["Simple_L5S"].show();
				me["Simple_L6S"].hide();
				me["Simple_L1_Arrow"].hide();
				me["Simple_L2_Arrow"].hide();
				me["Simple_L3_Arrow"].hide();
				me["Simple_L4_Arrow"].hide();
				me["Simple_L5_Arrow"].hide();
				me["Simple_L6_Arrow"].hide();
				me["Simple_R1"].show();
				me["Simple_R2"].show();
				me["Simple_R3"].show();
				me["Simple_R4"].show();
				me["Simple_R5"].show();
				me["Simple_R6"].hide(); 
				me["Simple_R1S"].show();
				me["Simple_R2S"].show();
				me["Simple_R3S"].show();
				me["Simple_R4S"].show();
				me["Simple_R5S"].show();
				me["Simple_R6S"].hide();
				me["Simple_R1_Arrow"].hide();
				me["Simple_R2_Arrow"].hide();
				me["Simple_R3_Arrow"].hide();
				me["Simple_R4_Arrow"].hide();
				me["Simple_R5_Arrow"].hide();
				me["Simple_R6_Arrow"].hide();
				
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
				me["INITA"].show();
				me["INITB"].hide();
				me["PERFTO"].hide();
				me["Simple_Title"].setText("INIT");
				me["Simple_PageNum"].setText("X/X");
				me["Simple_PageNum"].hide();
				
				me["Simple_L2"].show();
				me["Simple_L4"].show();
				me["Simple_L6"].show();
				me["Simple_L1S"].show();
				me["Simple_L2S"].show();
				me["Simple_L3S"].show();
				me["Simple_L4S"].show();
				me["Simple_L5S"].show();
				me["Simple_L6S"].show();
				me["Simple_L1_Arrow"].hide();
				me["Simple_L2_Arrow"].hide();
				me["Simple_L3_Arrow"].hide();
				me["Simple_L4_Arrow"].hide();
				me["Simple_L5_Arrow"].hide();
				me["Simple_L6_Arrow"].hide();
				me["Simple_R4"].show();
				me["Simple_R5"].show();
				me["Simple_R6"].show();
				me["Simple_R1S"].show();
				me["Simple_R3S"].hide();
				me["Simple_R4S"].show();
				me["Simple_R5S"].hide();
				me["Simple_R6S"].show();
				me["Simple_R1_Arrow"].hide();
				me["Simple_R2_Arrow"].hide();
				me["Simple_R3_Arrow"].hide();
				me["Simple_R4_Arrow"].hide();
				me["Simple_R5_Arrow"].show();
				me["Simple_R6_Arrow"].hide();
				
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
			
			if (state1.getValue() != 3 and state2.getValue() != 3) {
				me["ArrowLeft"].show();
				me["ArrowRight"].show();
			} else {
				me["ArrowLeft"].hide();
				me["ArrowRight"].hide();
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
			} else if (cruiseSet.getValue() == 1) {
				me["INITA_CruiseFLTemp"].hide();
				me["Simple_L6"].setColor(0.0901,0.6039,0.7176);
				me["Simple_L6"].setText(sprintf("%s", "FL" ~ cruiseFL.getValue() ~ "/---g"));
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
				me["Simple_L2"].setText("NONE");
				me["Simple_R1"].show();
				me["Simple_R2"].hide();
				me["Simple_R2S"].hide();
				me["INITA_InitRequest"].hide();
			} else {
				me["INITA_CoRoute"].show();
				me["INITA_FromTo"].show();
				me["Simple_L1"].hide();
				me["Simple_L2"].setColor(1,1,1);
				me["Simple_L2"].setText("----/----------");
				me["Simple_R1"].hide();
				me["Simple_R2"].show();
				me["Simple_R2S"].show();
				me["INITA_InitRequest"].show();
			}
			if (toFromSet.getValue() == 1 and ADIRSMCDUBTN.getValue() != 1) {
				me["INITA_AlignIRS"].show();
				me["Simple_R3"].show();
			} else {
				me["INITA_AlignIRS"].hide();
				me["Simple_R3"].hide();
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
			me["Simple_L4"].setText("----.-");
			me["Simple_R1S"].setText("FROM/TO   ");
			me["Simple_R2S"].setText("INIT ");
			me["Simple_R4S"].setText("LONG");
			me["Simple_R6S"].setText("TROPO");
			me["Simple_R1"].setText(sprintf("%s", depArpt.getValue() ~ "/" ~ arrArpt.getValue()));
			me["Simple_R2"].setText("REQUEST ");
			me["Simple_R3"].setText("IRS INIT >");
			me["Simple_R4"].setText("-----.--");
			me["Simple_R5"].setText("WIND ");
			me["Simple_R6"].setText(sprintf("%5.0f", tropo.getValue()));
		} else if (page == "INITB") {
			if (!pageSwitch[i].getBoolValue()) {
				me["Simple"].show();
				me["Simple_Center"].show();
				me["FPLN"].hide();
				me["INITA"].hide();
				me["INITB"].show();
				me["PERFTO"].hide();
				me["Simple_Title"].setText("INIT");
				me["Simple_PageNum"].setText("X/X");
				me["Simple_PageNum"].hide();
				me["ArrowLeft"].show();
				me["ArrowRight"].show();
				
				me["Simple_L1"].show();
				me["Simple_L2"].show();
				me["Simple_L3"].show();
				me["Simple_L4"].show();
				me["Simple_L5"].show();
				me["Simple_L6"].show();
				me["Simple_L1S"].show();
				me["Simple_L2S"].show();
				me["Simple_L3S"].show();
				me["Simple_L4S"].show();
				me["Simple_L5S"].show();
				me["Simple_L6S"].show();
				me["Simple_L1_Arrow"].hide();
				me["Simple_L2_Arrow"].hide();
				me["Simple_L3_Arrow"].hide();
				me["Simple_L4_Arrow"].hide();
				me["Simple_L5_Arrow"].hide();
				me["Simple_L6_Arrow"].hide();
				me["Simple_C1"].show();
				me["Simple_C2"].hide();
				me["Simple_C3"].hide();
				me["Simple_C4"].hide();
				me["Simple_C5"].hide();
				me["Simple_C6"].hide();
				me["Simple_C1S"].hide();
				me["Simple_C2S"].hide();
				me["Simple_C3S"].hide();
				me["Simple_C4S"].hide();
				me["Simple_C5S"].hide();
				me["Simple_C6S"].hide();
				me["Simple_R1"].hide();
				me["Simple_R2"].show();
				me["Simple_R3"].hide();
				me["Simple_R4"].show();
				me["Simple_R5"].show();
				me["Simple_R6"].hide();
				me["Simple_R1S"].show();
				me["Simple_R2S"].show();
				me["Simple_R3S"].hide();
				me["Simple_R4S"].show();
				me["Simple_R5S"].show();
				me["Simple_R6S"].hide();
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
				
				me.colorLeft("blu", "wht", "wht", "wht", "wht", "wht");
				me.colorLeftS("wht", "wht", "wht", "wht", "wht", "wht");
				me.colorLeftArrow("wht", "wht", "wht", "wht", "wht", "wht");
				me.colorCenter("blu", "wht", "wht", "wht", "wht", "wht");
				me.colorRight("blu", "blu", "wht", "wht", "wht", "wht");
				me.colorRightS("wht", "wht", "wht", "wht", "wht", "wht");
				me.colorRightArrow("wht", "wht", "wht", "wht", "wht", "wht");
				
				pageSwitch[i].setBoolValue(1);
			}
			
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
				me["INITB_Block"].hide();
				me["Simple_R2"].show(); 
			} else {
				me["INITB_Block"].show();
				me["Simple_R2"].hide(); 
			}
			
			me["Simple_L1"].setText("0.2");
			me["Simple_L2"].setText("---.-/----");
			me["Simple_L3"].setText("---.-/--.-");
			me["Simple_L4"].setText("---.-/----");
			me["Simple_L5"].setText("---.-/----");
			me["Simple_L6"].setText("---.-/----");
			me["Simple_L1S"].setText("TAXI");
			me["Simple_L2S"].setText("TRIP/TIME");
			me["Simple_L3S"].setText("RTE RSV/");
			me["Simple_L4S"].setText("ALTN/TIME");
			me["Simple_L5S"].setText("FINAL/TIME");
			me["Simple_L6S"].setText("EXTRA/TIME");
			me["Simple_R1"].setText(sprintf("%3.1f", zfw.getValue()));
			me["Simple_R2"].setText(sprintf("%3.1f", block.getValue()));
			me["Simple_R4"].setText("---.-");
			me["Simple_R5"].setText("---.-");
			me["Simple_R1S"].setText("ZFWCG/   ZFW");
			me["Simple_R2S"].setText("BLOCK");
			me["Simple_R4S"].setText("TOW");
			me["Simple_R5S"].setText("LW");
		} else if (page == "FUELPRED") {
			if (!pageSwitch[i].getBoolValue()) {
				me["Simple"].show();
				me["Simple_Center"].show();
				me["FPLN"].hide();
				me["INITA"].hide();
				me["INITB"].hide();
				me["PERFTO"].hide();
				me["Simple_Title"].setText("FUEL PRED");
				me["Simple_PageNum"].setText("X/X");
				me["Simple_PageNum"].hide();
				me["ArrowLeft"].hide();
				me["ArrowRight"].hide();
				
				me["Simple_L1"].show();
				me["Simple_L2"].show();
				me["Simple_L3"].show();
				me["Simple_L4"].show();
				me["Simple_L5"].show();
				me["Simple_L6"].show();
				me["Simple_L1S"].show();
				me["Simple_L2S"].hide();
				me["Simple_L3S"].show();
				me["Simple_L4S"].show();
				me["Simple_L5S"].show();
				me["Simple_L6S"].show();
				me["Simple_L1_Arrow"].hide();
				me["Simple_L2_Arrow"].hide();
				me["Simple_L3_Arrow"].hide();
				me["Simple_L4_Arrow"].hide();
				me["Simple_L5_Arrow"].hide();
				me["Simple_L6_Arrow"].hide();
				me["Simple_C1"].show();
				me["Simple_C2"].show();
				me["Simple_C3"].hide();
				me["Simple_C4"].hide();
				me["Simple_C5"].hide();
				me["Simple_C6"].hide();
				me["Simple_C1S"].show();
				me["Simple_C2S"].hide();
				me["Simple_C3S"].hide();
				me["Simple_C4S"].hide();
				me["Simple_C5S"].hide();
				me["Simple_C6S"].hide();
				me["Simple_R1"].show();
				me["Simple_R2"].show();
				me["Simple_R3"].show();
				me["Simple_R4"].show();
				me["Simple_R5"].hide();
				me["Simple_R6"].hide();
				me["Simple_R1S"].show();
				me["Simple_R2S"].hide();
				me["Simple_R3S"].show();
				me["Simple_R4S"].show();
				me["Simple_R5S"].hide();
				me["Simple_R6S"].hide();
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
				
				me.colorLeft("grn", "grn", "blu", "blu", "blu", "grn");
				me.colorLeftS("wht", "wht", "wht", "wht", "wht", "wht");
				me.colorLeftArrow("wht", "wht", "wht", "wht", "wht", "wht");
				me.colorCenter("grn", "grn", "wht", "wht", "wht", "wht");
				me.colorCenterS("wht", "wht", "wht", "wht", "wht", "wht");
				me.colorRight("grn", "grn", "blu", "blu", "wht", "wht");
				me.colorRightS("wht", "wht", "wht", "wht", "wht", "wht");
				me.colorRightArrow("wht", "wht", "wht", "wht", "wht", "wht");
				
				pageSwitch[i].setBoolValue(1);
			}
			
			if (!engrdy.getBoolValue() or toFromSet.getValue() != 1) {
				me["Simple_L1"].setText("----");
			} else {
				me["Simple_L1"].setText(arrArpt.getValue());
			}
			
			me["Simple_L2"].setText("----");
			me["Simple_L3"].setText("--.-/--.-");
			me["Simple_L4"].setText("-.-/-.-");
			me["Simple_L5"].setText("--.-/----");
			me["Simple_L6"].setText("--.-/----");
			me["Simple_L1S"].setText("AT");
			me["Simple_L2S"].setText("X");
			me["Simple_L3S"].setText("GW/CG");
			me["Simple_L4S"].setText("RTE RSV/");
			me["Simple_L5S"].setText("FINAL/TIME");
			me["Simple_L6S"].setText("EXTRA/TIME");
			
			me["Simple_C1S"].setText("UTC");
			me["Simple_C1"].setText("----");
			me["Simple_C2"].setText("----");
			
			me["Simple_R1"].setText("-.-");
			me["Simple_R2"].setText("-.-");
			me["Simple_R3"].setText("-.-/--+--");
			me["Simple_R4"].setText("----*/36090");
			me["Simple_R1S"].setText("EFOB");
			me["Simple_R3S"].setText("FOB");
			me["Simple_R4S"].setText("CRZTEMP/TROPO");
		} else if (page == "TO") {
			if (!pageSwitch[i].getBoolValue()) {
				me["Simple"].show();
				me["Simple_Center"].show();
				me["FPLN"].hide();
				me["INITA"].hide();
				me["INITB"].hide();
				me["PERFTO"].show();
				me["Simple_Title"].setText("TAKE OFF");
				me["Simple_PageNum"].setText("X/X");
				me["Simple_PageNum"].hide();
				me["ArrowLeft"].hide();
				me["ArrowRight"].hide();
				
				me["Simple_L1"].show();
				me["Simple_L2"].show();
				me["Simple_L3"].show();
				me["Simple_L4"].show();
				me["Simple_L5"].show();
				me["Simple_L6"].show();
				me["Simple_L1S"].show();
				me["Simple_L2S"].show();
				me["Simple_L3S"].show();
				me["Simple_L4S"].show();
				me["Simple_L5S"].show();
				me["Simple_L6S"].show();
				me["Simple_L1_Arrow"].hide();
				me["Simple_L2_Arrow"].hide();
				me["Simple_L3_Arrow"].hide();
				me["Simple_L4_Arrow"].hide();
				me["Simple_L5_Arrow"].hide();
				me["Simple_L6_Arrow"].show();
				me["Simple_R1"].show();
				me["Simple_R2"].show();
				me["Simple_R3"].show();
				me["Simple_R4"].show();
				me["Simple_R5"].show();
				me["Simple_R6"].show();
				me["Simple_R1S"].show();
				me["Simple_R2S"].show();
				me["Simple_R3S"].show();
				me["Simple_R4S"].show();
				me["Simple_R5S"].show();
				me["Simple_R6S"].show();
				me["Simple_R1_Arrow"].hide();
				me["Simple_R2_Arrow"].hide();
				me["Simple_R3_Arrow"].hide();
				me["Simple_R4_Arrow"].hide();
				me["Simple_R5_Arrow"].hide();
				me["Simple_R6_Arrow"].show();
				me["Simple_C1"].hide();
				me["Simple_C2"].hide();
				me["Simple_C3"].hide();
				me["Simple_C4"].hide();
				me["Simple_C5"].hide();
				me["Simple_C6"].hide();
				me["Simple_C1S"].show();
				me["Simple_C2S"].show();
				me["Simple_C3S"].show();
				me["Simple_C4S"].hide();
				me["Simple_C5S"].hide();
				me["Simple_C6S"].hide();
				
				me.fontLeft(default, default, default, default, default, default);
				me.fontLeftS(default, default, default, default, default, default);
				me.fontRight(default, symbol, 0, 0, default, default);
				me.fontRightS(default, default, default, default, default, default);
				
				me.fontSizeLeft(normal, normal, normal, normal, 0, normal);
				me.fontSizeRight(normal, small, 0, 0, 0, normal);
				
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
			if (flapTHSSet.getValue() == 1) {
				me["Simple_R3"].setFont(default); 
				me["Simple_R3"].setFontSize(normal); 
				me["Simple_R3"].setText(sprintf("%s", flapTO.getValue() ~ "/UP" ~ THSTO.getValue()));
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
			
			me["Simple_L1"].setText(sprintf("%3.0f", v1.getValue()));
			me["Simple_L2"].setText(sprintf("%3.0f", vr.getValue()));
			me["Simple_L3"].setText(sprintf("%3.0f", v2.getValue()));
			me["Simple_L4"].setText(sprintf("%3.0f", transAlt.getValue()));
			me["Simple_L5"].setText(sprintf("%s", clbReducFt.getValue() ~ "/" ~ reducFt.getValue()));
			me["Simple_L6"].setText(" TO DATA");
			me["Simple_L1S"].setText(" V1");
			me["Simple_L2S"].setText(" VR");
			me["Simple_L3S"].setText(" V2");
			me["Simple_L4S"].setText("TRANS ALT");
			me["Simple_L5S"].setText("THR RED/ACC");
			me["Simple_L6S"].setText(" UPLINK");
			me["Simple_R1"].setText("--- ");
			me["Simple_R2"].setText("[    ]  ");
			me["Simple_R5"].setText(sprintf("%3.0f", engOutAcc.getValue()));
			me["Simple_R6"].setText("PHASE ");
			me["Simple_R1S"].setText("RWY ");
			me["Simple_R2S"].setText("TO SHIFT ");
			me["Simple_R3S"].setText("FLAPS/THS");
			me["Simple_R4S"].setText("FLEX TO TEMP");
			me["Simple_R5S"].setText("ENG OUT ACC");
			me["Simple_R6S"].setText("NEXT ");
			me["Simple_C1S"].setText("FLP RETR        ");
			me["Simple_C2S"].setText("SLT RETR        ");
			me["Simple_C3S"].setText("CLEAN      ");
		} else if (page == "CLB" or page == "CRZ" or page == "DES") {
			if (!pageSwitch[i].getBoolValue()) {
				me["Simple"].show();
				me["Simple_Center"].show();
				me["FPLN"].hide();
				me["INITA"].hide();
				me["INITB"].hide();
				me["PERFTO"].hide();
				me["Simple_Title"].setText(sprintf("%s", page));
				me["Simple_PageNum"].setText("X/X");
				me["Simple_PageNum"].hide();
				me["ArrowLeft"].hide();
				me["ArrowRight"].hide();
				
				me["Simple_L1"].show();
				me["Simple_L2"].show();
				me["Simple_L3"].show();
				me["Simple_L4"].hide();
				me["Simple_L5"].hide();
				me["Simple_L6"].show();
				me["Simple_L1S"].show();
				me["Simple_L2S"].show();
				me["Simple_L3S"].show();
				me["Simple_L4S"].hide();
				me["Simple_L5S"].hide();
				me["Simple_L6S"].show();
				me["Simple_L1_Arrow"].hide();
				me["Simple_L2_Arrow"].hide();
				me["Simple_L3_Arrow"].hide();
				me["Simple_L4_Arrow"].hide();
				me["Simple_L5_Arrow"].hide();
				me["Simple_L6_Arrow"].show();
				me["Simple_R1"].show();
				me["Simple_R2"].hide();
				me["Simple_R3"].hide();
				me["Simple_R4"].hide();
				me["Simple_R6"].show();
				me["Simple_R1S"].show();
				me["Simple_R2S"].hide();
				me["Simple_R3S"].hide();
				me["Simple_R4S"].hide();
				me["Simple_R6S"].show();
				me["Simple_R1_Arrow"].hide();
				me["Simple_R2_Arrow"].hide();
				me["Simple_R3_Arrow"].hide();
				me["Simple_R4_Arrow"].hide();
				me["Simple_R5_Arrow"].hide();
				me["Simple_R6_Arrow"].show();
				me["Simple_C1"].show();
				me["Simple_C2"].hide();
				me["Simple_C3"].hide();
				me["Simple_C4"].hide();
				me["Simple_C6"].hide();
				me["Simple_C1S"].show();
				me["Simple_C2S"].hide();
				me["Simple_C3S"].hide();
				me["Simple_C4S"].hide();
				me["Simple_C5S"].hide();
				me["Simple_C6S"].hide();
				
				me.fontLeft(default, default, default, symbol, default, default);
				me.fontLeftS(default, default, default, default, default, default);
				me.fontRight(default, default, default, default, default, default);
				me.fontRightS(default, default, default, default, default, default);
				
				me.fontSizeLeft(normal, normal, small, small, normal, normal);
				me.fontSizeRight(normal, normal, normal, normal, small, normal);
				me.fontSizeCenter(normal, normal, normal, normal, small, normal);
				
				me.colorLeft("grn", "ack", "grn", "blu", "wht", "wht");
				me.colorLeftS("wht", "wht", "wht", "wht", "wht", "wht");
				me.colorLeftArrow("wht", "wht", "wht", "wht", "wht", "wht");
				me.colorRight("wht", "wht", "wht", "wht", "wht", "wht");
				me.colorRightS("wht", "wht", "wht", "wht", "wht", "wht");
				me.colorRightArrow("wht", "wht", "wht", "wht", "wht", "wht");
				me.colorCenter("wht", "wht", "wht", "wht", "blu", "wht");
				me.colorCenterS("wht", "wht", "wht", "wht", "wht", "wht");
				
				pageSwitch[i].setBoolValue(1);
			}
			
			if (managedSpeed.getValue() == 1) {
				me["Simple_L1"].setText("MANAGED");
			} else {
				me["Simple_L1"].setText("SELECTED");
			}
			
			if (costIndexSet.getValue() == 1) {
				me["Simple_L2"].setColor(0.0901,0.6039,0.7176);
				me["Simple_L2"].setText(sprintf("%s", costIndex.getValue()));
			} else {
				me["Simple_L2"].setColor(1,1,1);
				me["Simple_L2"].setText("---");
			}
			
			if (page == "CRZ") {
				me["Simple_R5"].show();
				me["Simple_R5S"].show();
				me["Simple_C5"].show();
			} else {
				me["Simple_R5"].hide();
				me["Simple_R5S"].hide();
				me["Simple_C5"].hide();
			}
			
			me["Simple_L3"].setText("");
			me["Simple_L4"].setText(" [    ]");
			me["Simple_L6"].setText(" PHASE");
			me["Simple_L1S"].setText("ACT MODE");
			me["Simple_L2S"].setText(" CI");
			me["Simple_L3S"].setText(" MANAGED");
			me["Simple_L4S"].setText(" PRESEL");
			me["Simple_L6S"].setText(" PREV");
			me["Simple_R1"].setText("---");
			me["Simple_R5"].setText("FT/MIN");
			me["Simple_R6"].setText("PHASE ");
			me["Simple_R1S"].setText("DES EFOB");
			me["Simple_R5S"].setText("DES CABIN RATE");
			me["Simple_R6S"].setText("NEXT ");
			me["Simple_C1"].setText("---  ");
			me["Simple_C5"].setText("             -350");
			me["Simple_C1S"].setText("TIME  ");
		} elsif (page == "LATREV") {
			if (!pageSwitch[i].getBoolValue()) {
				me["Simple"].show();
				me["Simple_Center"].hide();
				me["FPLN"].hide();
				me["INITA"].hide();
				me["INITB"].hide();
				me["PERFTO"].hide();
				me["Simple_PageNum"].setText("X/X");
				me["Simple_PageNum"].hide();
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
				
				
				if (myLatRev != nil) {
					me["Simple_Title"].setText(sprintf("%s", myLatRev.title[0] ~ myLatRev.title[1] ~ myLatRev.title[2]));
					
					forindex (var matrixArrow; myLatRev.arrowsMatrix) {
						if (matrixArrow == 0) { 
							var sign = "L"; 
						} else { 
							var sign = "R"; 
						}
						forindex (var item; myLatRev.arrowsMatrix[matrixArrow]) {
							if (myLatRev.arrowsMatrix[matrixArrow][item] == 1) {
								me["Simple_" ~ sign ~ (item + 1) ~ "_Arrow"].show();
							} else {
								me["Simple_" ~ sign ~ (item + 1) ~ "_Arrow"].hide();
							}
						}
					}
					
					forindex (var matrixFont; myLatRev.fontMatrix) {
						if (matrixFont == 0) { 
							var sign = "L"; 
						} else { 
							var sign = "R"; 
						}
						forindex (var item; myLatRev.fontMatrix[matrixFont]) {
							if (myLatRev.fontMatrix[matrixFont][item] == 1) {
								me["Simple_" ~ sign ~ (item + 1)].setFont(symbol);
								me["Simple_" ~ sign ~ (item + 1)].setFontSize(small);
							} else {
								me["Simple_" ~ sign ~ (item + 1)].setFont(default);
								me["Simple_" ~ sign ~ (item + 1)].setFontSize(normal);
							}
						}
					}
					
					if (myLatRev.L1[0] == nil) {
						me["Simple_L1"].hide();
						me["Simple_L1S"].hide();
					} else {
						me["Simple_L1"].show();
						me["Simple_L1"].setText(myLatRev.L1[0]);
						if (myLatRev.L1[1] != nil) {
							me["Simple_L1S"].show();
							me["Simple_L1S"].setText(myLatRev.L1[1]);
						} else {
							me["Simple_L1S"].hide();
						}
					}
					
					if (myLatRev.L2[0] == nil) {
						me["Simple_L2"].hide();
						me["Simple_L2S"].hide();
					} else {
						me["Simple_L2"].show();
						me["Simple_L2"].setText(myLatRev.L2[0]);
						if (myLatRev.L2[1] != nil) {
							me["Simple_L2S"].show();
							me["Simple_L2S"].setText(myLatRev.L2[1]);
						} else {
							me["Simple_L2S"].hide();
						}
					}
					
					if (myLatRev.L3[0] == nil) {
						me["Simple_L3"].hide();
						me["Simple_L3S"].hide();
					} else {
						me["Simple_L3"].show();
						me["Simple_L3"].setText(myLatRev.L3[0]);
						if (myLatRev.L3[1] != nil) {
							me["Simple_L3S"].show();
							me["Simple_L3S"].setText(myLatRev.L3[1]);
						} else {
							me["Simple_L3S"].hide();
						}
					}
					
					if (myLatRev.L4[0] == nil) {
						me["Simple_L4"].hide();
						me["Simple_L4S"].hide();
					} else {
						me["Simple_L4"].show();
						me["Simple_L4"].setText(myLatRev.L4[0]);
						if (myLatRev.L4[1] != nil) {
							me["Simple_L4S"].show();
							me["Simple_L4S"].setText(myLatRev.L4[1]);
						} else {
							me["Simple_L4S"].hide();
						}
					}
					
					if (myLatRev.L5[0] == nil) {
						me["Simple_L5"].hide();
						me["Simple_L5S"].hide();
					} else {
						me["Simple_L5"].show();
						me["Simple_L5"].setText(myLatRev.L5[0]);
						if (myLatRev.L5[1] != nil) {
							me["Simple_L5S"].show();
							me["Simple_L5S"].setText(myLatRev.L5[1]);
						} else {
							me["Simple_L5S"].hide();
						}
					}
					
					if (myLatRev.L6[0] == nil) {
						me["Simple_L6"].hide();
						me["Simple_L6S"].hide();
					} else {
						me["Simple_L6"].show();
						me["Simple_L6"].setText(myLatRev.L6[0]);
						if (myLatRev.L6[1] != nil) {
							me["Simple_L6S"].show();
							me["Simple_L6S"].setText(myLatRev.L6[1]);
						} else {
							me["Simple_L6S"].hide();
						}
					}
					me.colorLeft(myLatRev.L1[2],myLatRev.L2[2],myLatRev.L3[2],myLatRev.L4[2],myLatRev.L5[2],myLatRev.L6[2]);
					
					if (myLatRev.R1[0] == nil) {
						me["Simple_R1"].hide();
						me["Simple_R1S"].hide();
					} else {
						me["Simple_R1"].show();
						me["Simple_R1"].setText(myLatRev.R1[0]);
						if (myLatRev.R1[1] != nil) {
							me["Simple_R1S"].show();
							me["Simple_R1S"].setText(myLatRev.R1[1]);
						} else {
							me["Simple_R1S"].hide();
						}
					}
					
					if (myLatRev.R2[0] == nil) {
						me["Simple_R2"].hide();
						me["Simple_R2S"].hide();
					} else {
						me["Simple_R2"].show();
						me["Simple_R2"].setText(myLatRev.R2[0]);
						if (myLatRev.R2[1] != nil) {
							me["Simple_R2S"].show();
							me["Simple_R2S"].setText(myLatRev.R2[1]);
						} else {
							me["Simple_R2S"].hide();
						}
					}
					
					if (myLatRev.R3[0] == nil) {
						me["Simple_R3"].hide();
						me["Simple_R3S"].hide();
					} else {
						me["Simple_R3"].show();
						me["Simple_R3"].setText(myLatRev.R3[0]);
						if (myLatRev.R3[1] != nil) {
							me["Simple_R3S"].show();
							me["Simple_R3S"].setText(myLatRev.R3[1]);
						} else {
							me["Simple_R3S"].hide();
						}
					}
					
					if (myLatRev.R4[0] == nil) {
						me["Simple_R4"].hide();
						me["Simple_R4S"].hide();
					} else {
						me["Simple_R4"].show();
						me["Simple_R4"].setText(myLatRev.R4[0]);
						if (myLatRev.R4[1] != nil) {
							me["Simple_R4S"].show();
							me["Simple_R4S"].setText(myLatRev.R4[1]);
						} else {
							me["Simple_R4S"].hide();
						}
					}
					
					if (myLatRev.R5[0] == nil) {
						me["Simple_R5"].hide();
						me["Simple_R5S"].hide();
					} else {
						me["Simple_R5"].show();
						me["Simple_R5"].setText(myLatRev.R5[0]);
						if (myLatRev.R5[1] != nil) {
							me["Simple_R5S"].show();
							me["Simple_R5S"].setText(myLatRev.R5[1]);
						} else {
							me["Simple_R5S"].hide();
						}
					}
					
					if (myLatRev.R6[0] == nil) {
						me["Simple_R6"].hide();
						me["Simple_R6S"].hide();
					} else {
						me["Simple_R6"].show();
						me["Simple_R6"].setText(myLatRev.R6[0]);
						if (myLatRev.R6[1] != nil) {
							me["Simple_R6S"].show();
							me["Simple_R6S"].setText(myLatRev.R6[1]);
						} else {
							me["Simple_R6S"].hide();
						}
					}
					me.colorRight(myLatRev.R1[2],myLatRev.R2[2],myLatRev.R3[2],myLatRev.R4[2],myLatRev.R5[2],myLatRev.R6[2]);
				}
				pageSwitch[i].setBoolValue(1);
			}
		} else {
			if (!pageSwitch[i].getBoolValue()) {
				me["Simple"].hide();
				me["FPLN"].hide();
				me["INITA"].hide();
				me["INITB"].hide();
				me["PERFTO"].hide();
				me["ArrowLeft"].hide();
				me["ArrowRight"].hide();
				
				pageSwitch[i].setBoolValue(1);
			}
		}
		
		me["Scratchpad"].setText(sprintf("%s", scratchpad[i].getValue()));
	},
	# ack = ignore, wht = white, grn = green, blu = blue, amb = amber, yel = yellow
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
		if (b != "ack") {
			me["Simple_L2"].setFontSize(b); 
		}
		if (c != "ack") {
			me["Simple_L3"].setFontSize(c); 
		}
		if (d != "ack") {
			me["Simple_L4"].setFontSize(d); 
		}
		if (e != "ack") {
			me["Simple_L5"].setFontSize(e); 
		}
		if (f != "ack") {
			me["Simple_L6"].setFontSize(f); 
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
