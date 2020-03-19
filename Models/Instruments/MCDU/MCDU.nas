# A3XX MCDU

# Copyright (c) 2019 Joshua Davidson (Octal450)

var MCDU_1 = nil;
var MCDU_2 = nil;
var MCDU1_display = nil;
var MCDU2_display = nil;
var myLatRev = [nil, nil];
var myVertRev = [nil, nil];
var myDeparture = [nil, nil];
var myArrival = [nil, nil];
var myFpln = [nil, nil];
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
		
		me["PERFAPPR_FE"].setFont(symbol);
		me["PERFAPPR_SE"].setFont(symbol);
		me["PERFAPPR_OE"].setFont(symbol);
		me["PERFAPPR_FE"].setColor(0.8078,0.8039,0.8078);
		me["PERFAPPR_SE"].setColor(0.8078,0.8039,0.8078);
		me["PERFAPPR_OE"].setColor(0.8078,0.8039,0.8078);
		
		me.page = canvas_group;
		
		return me;
	},
	getKeys: func() {
		return ["Simple","Simple_Center","Scratchpad","Simple_Title","Simple_PageNum","ArrowLeft","ArrowRight","Simple_L1","Simple_L2","Simple_L3","Simple_L4"
		,"Simple_L5","Simple_L6","Simple_L0S","Simple_L1S","Simple_L2S","Simple_L3S","Simple_L4S","Simple_L5S","Simple_L6S", "Simple_L1_Arrow",
		"Simple_L2_Arrow","Simple_L3_Arrow","Simple_L4_Arrow","Simple_L5_Arrow","Simple_L6_Arrow","Simple_R1","Simple_R2","Simple_R3","Simple_R4","Simple_R5",
		"Simple_R6","Simple_R1S","Simple_R2S","Simple_R3S","Simple_R4S","Simple_R5S","Simple_R6S","Simple_R1_Arrow","Simple_R2_Arrow","Simple_R3_Arrow",
		"Simple_R4_Arrow","Simple_R5_Arrow","Simple_R6_Arrow","Simple_C1","Simple_C2","Simple_C3","Simple_C4","Simple_C5","Simple_C6","Simple_C1S",
		"Simple_C2S","Simple_C3S","Simple_C4S","Simple_C5S","Simple_C6S","INITA","INITA_CoRoute","INITA_FltNbr","INITA_CostIndex","INITA_CruiseFLTemp",
		"INITA_FromTo","INITA_InitRequest","INITA_AlignIRS","INITB","INITB_ZFWCG","INITB_ZFW","INITB_ZFW_S","INITB_Block","PERFTO","PERFTO_V1","PERFTO_VR","PERFTO_V2","PERFTO_FE","PERFTO_SE","PERFTO_OE","PERFAPPR","PERFAPPR_FE","PERFAPPR_SE","PERFAPPR_OE","FPLN","FPLN_From","FPLN_TMPY_group",
		"FPLN_Callsign","departureTMPY", "arrowsDepArr","arrow1L","arrow2L","arrow3L","arrow4L","arrow5L","arrow1R","arrow2R","arrow3R","arrow4R","arrow5R"];
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
				me["INITA"].hide();
				me["INITB"].hide();
				me["PERFTO"].hide();
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
				
				#if (mcdu.FPLNLines[i].index == 0) {
				#	me["FPLN_From"].show();
				#} else {
				#	me["FPLN_From"].hide();
				#}
				
				if (fmgc.flightPlanController.temporaryFlag[i]) {
					me["FPLN_TMPY_group"].show();
				} else {
					me["FPLN_TMPY_group"].hide();
				}
			}
		} elsif (page == "MCDU") {
			if (!pageSwitch[i].getBoolValue()) {
				me["Simple"].show();
				me["Simple_Center"].hide();
				me["FPLN"].hide();
				me["INITA"].hide();
				me["INITB"].hide();
				me["PERFTO"].hide();
				me["arrowsDepArr"].hide();
				me["PERFAPPR"].hide();
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
				me["Simple_L0S"].hide();
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
				me["arrowsDepArr"].hide();
				me["PERFAPPR"].hide();
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
				me["Simple_L0S"].hide();
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
				me["arrowsDepArr"].hide();
				me["PERFAPPR"].hide();
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
				me["Simple_L0S"].hide();
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
				me["arrowsDepArr"].hide();
				me["PERFAPPR"].hide();
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
				me["Simple_L0S"].hide();
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
				me["arrowsDepArr"].hide();
				me["PERFAPPR"].hide();
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
				me["Simple_L0S"].hide();
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
				me["arrowsDepArr"].hide();
				me["PERFAPPR"].hide();
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
				me["Simple_L0S"].hide();
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
				me["arrowsDepArr"].hide();
				me["PERFAPPR"].hide();
				me["Simple_Title"].setText("INIT");
				me["Simple_PageNum"].setText("X/X");
				me["Simple_PageNum"].hide();
				
				me["Simple_L2"].show();
				me["Simple_L4"].show();
				me["Simple_L6"].show();
				me["Simple_L0S"].hide();
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
				me["arrowsDepArr"].hide();
				me["PERFAPPR"].hide();
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
				me["Simple_L0S"].hide();
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
				me["arrowsDepArr"].hide();
				me["PERFAPPR"].hide();
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
				me["Simple_L0S"].hide();
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
				me["arrowsDepArr"].hide();
				me["PERFAPPR"].hide();
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
				me["Simple_L0S"].hide();
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
				me["Simple_C1"].show();
				me["Simple_C2"].show();
				me["Simple_C3"].show();
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
			me["Simple_C1"].setText(" ---");
			me["Simple_C2"].setText(" ---");
			me["Simple_C3"].setText(" ---");
			me["Simple_C1S"].setText("FLP RETR");
			me["Simple_C2S"].setText("SLT RETR");
			me["Simple_C3S"].setText("CLEAN  ");
		} else if (page == "APPR") {
			if (!pageSwitch[i].getBoolValue()) {
				me["Simple"].show();
				me["Simple_Center"].show();
				me["INITA"].hide();
				me["INITB"].hide();
				me["PERFTO"].hide();
				me["PERFAPPR"].show();
				me["Simple_Title"].setText("APPR");
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
				me["Simple_L0S"].show();
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
				me["Simple_R5"].hide();
				me["Simple_R6"].show();
				me["Simple_R1S"].show();
				me["Simple_R2S"].show();
				me["Simple_R3S"].show();
				me["Simple_R4S"].show();
				me["Simple_R5S"].hide();
				me["Simple_R6S"].show();
				me["Simple_R1_Arrow"].hide();
				me["Simple_R2_Arrow"].hide();
				me["Simple_R3_Arrow"].hide();
				me["Simple_R4_Arrow"].hide();
				me["Simple_R5_Arrow"].hide();
				me["Simple_R6_Arrow"].show();
				me["Simple_C1"].show();
				me["Simple_C2"].show();
				me["Simple_C3"].show();
				me["Simple_C4"].hide();
				me["Simple_C5"].show();
				me["Simple_C6"].hide();
				me["Simple_C1S"].show();
				me["Simple_C2S"].show();
				me["Simple_C3S"].show();
				me["Simple_C4S"].hide();
				me["Simple_C5S"].show();
				me["Simple_C6S"].hide();
				
				me.fontLeft(symbol, default, default, default, symbol, default);
				me.fontLeftS(default, default, default, default, default, default);
				me.fontRight(default, symbol, symbol, symbol, default, default);
				me.fontRightS(default, default, default, default, default, default);
				
				me.fontSizeLeft(small, small, small, small, small, normal);
				me.fontSizeRight(small, small, small, small, 0, normal);
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
			
			me["Simple_L1"].setText("[    ]  ");
			me["Simple_L2"].setText("---g  ");
			me["Simple_L3"].setText("---g/---");
			me["Simple_L4"].setText(sprintf("%3.0f", transAlt.getValue()));
			me["Simple_L5"].setText("[    ]  ");
			me["Simple_L6"].setText(" PHASE");
			me["Simple_L0S"].setText("DEST");
			me["Simple_L1S"].setText("QNH");
			me["Simple_L2S"].setText("TEMP");
			me["Simple_L3S"].setText("MAG WIND");
			me["Simple_L4S"].setText("TRANS ALT");
			me["Simple_L5S"].setText(" VAPP");
			me["Simple_L6S"].setText(" PREV");
			me["Simple_R1"].setText("-----");
			me["Simple_R2"].setText(" [    ]");
			me["Simple_R3"].setText(" [    ]");
			me["Simple_R4"].setText(" [    ]");
			me["Simple_R1S"].setText("FINAL");
			me["Simple_R2S"].setText("MDA");
			me["Simple_R3S"].setText("DH");
			me["Simple_R4S"].setText("LDG CONF");
			me["Simple_C1"].setText(" ---");
			me["Simple_C2"].setText(" ---");
			me["Simple_C3"].setText(" ---");
			me["Simple_C5"].setText(" ---");
			me["Simple_C1S"].setText("FLP RETR");
			me["Simple_C2S"].setText("SLT RETR");
			me["Simple_C3S"].setText("CLEAN  ");
			me["Simple_C5S"].setText("VLS   ");
		} else if (page == "CLB" or page == "CRZ" or page == "DES") {
			if (!pageSwitch[i].getBoolValue()) {
				me["Simple"].show();
				me["Simple_Center"].show();
				me["FPLN"].hide();
				me["INITA"].hide();
				me["INITB"].hide();
				me["PERFTO"].hide();
				me["arrowsDepArr"].hide();
				me["PERFAPPR"].hide();
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
				me["Simple_L0S"].hide();
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
				me["Simple_C5"].hide();
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
				me["Simple_Center"].show();
				me["FPLN"].hide();
				me["INITA"].hide();
				me["INITB"].hide();
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
		} elsif (page == "VERTREV") {
			if (!pageSwitch[i].getBoolValue()) {
				me["Simple"].show();
				me["Simple_Center"].show();
				me["FPLN"].hide();
				me["INITA"].hide();
				me["INITB"].hide();
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
		} elsif (page == "DEPARTURE") {
			if (!pageSwitch[i].getBoolValue()) {
				me["Simple"].show();
				me["Simple_Center"].show();
				me["FPLN"].hide();
				me["INITA"].hide();
				me["INITB"].hide();
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
		} elsif (page == "DUPLICATENAMES") {
			if (!pageSwitch[i].getBoolValue()) {
				me["Simple"].show();
				me["Simple_Center"].show();
				me["FPLN"].hide();
				me["INITA"].hide();
				me["INITB"].hide();
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
		} elsif (page == "ARRIVAL") {
			if (!pageSwitch[i].getBoolValue()) {
				me["Simple"].show();
				me["Simple_Center"].show();
				me["FPLN"].hide();
				me["INITA"].hide();
				me["INITB"].hide();
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
		} else {
			if (!pageSwitch[i].getBoolValue()) {
				me["Simple"].hide();
				me["FPLN"].hide();
				me["INITA"].hide();
				me["INITB"].hide();
				me["PERFTO"].hide();
				me["PERFAPPR"].hide();
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
