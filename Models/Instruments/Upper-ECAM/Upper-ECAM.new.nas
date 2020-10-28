var flapsPos = nil;
var slatLockFlash = props.globals.initNode("/instrumentation/du/slat-lock-flash", 0, "BOOL");
var acconfig_weight_kgs = props.globals.getNode("/systems/acconfig/options/weight-kgs", 1);

var ECAM_line1 = props.globals.getNode("/ECAM/msg/line1", 1);
var ECAM_line2 = props.globals.getNode("/ECAM/msg/line2", 1);
var ECAM_line3 = props.globals.getNode("/ECAM/msg/line3", 1);
var ECAM_line4 = props.globals.getNode("/ECAM/msg/line4", 1);
var ECAM_line5 = props.globals.getNode("/ECAM/msg/line5", 1);
var ECAM_line6 = props.globals.getNode("/ECAM/msg/line6", 1);
var ECAM_line7 = props.globals.getNode("/ECAM/msg/line7", 1);
var ECAM_line8 = props.globals.getNode("/ECAM/msg/line8", 1);
var ECAM_line1r = props.globals.getNode("/ECAM/rightmsg/line1", 1);
var ECAM_line2r = props.globals.getNode("/ECAM/rightmsg/line2", 1);
var ECAM_line3r = props.globals.getNode("/ECAM/rightmsg/line3", 1);
var ECAM_line4r = props.globals.getNode("/ECAM/rightmsg/line4", 1);
var ECAM_line5r = props.globals.getNode("/ECAM/rightmsg/line5", 1);
var ECAM_line6r = props.globals.getNode("/ECAM/rightmsg/line6", 1);
var ECAM_line7r = props.globals.getNode("/ECAM/rightmsg/line7", 1);
var ECAM_line8r = props.globals.getNode("/ECAM/rightmsg/line8", 1);
var ECAM_line1c = props.globals.getNode("/ECAM/msg/linec1", 1);
var ECAM_line2c = props.globals.getNode("/ECAM/msg/linec2", 1);
var ECAM_line3c = props.globals.getNode("/ECAM/msg/linec3", 1);
var ECAM_line4c = props.globals.getNode("/ECAM/msg/linec4", 1);
var ECAM_line5c = props.globals.getNode("/ECAM/msg/linec5", 1);
var ECAM_line6c = props.globals.getNode("/ECAM/msg/linec6", 1);
var ECAM_line7c = props.globals.getNode("/ECAM/msg/linec7", 1);
var ECAM_line8c = props.globals.getNode("/ECAM/msg/linec8", 1);
var ECAM_line1rc = props.globals.getNode("/ECAM/rightmsg/linec1", 1);
var ECAM_line2rc = props.globals.getNode("/ECAM/rightmsg/linec2", 1);
var ECAM_line3rc = props.globals.getNode("/ECAM/rightmsg/linec3", 1);
var ECAM_line4rc = props.globals.getNode("/ECAM/rightmsg/linec4", 1);
var ECAM_line5rc = props.globals.getNode("/ECAM/rightmsg/linec5", 1);
var ECAM_line6rc = props.globals.getNode("/ECAM/rightmsg/linec6", 1);
var ECAM_line7rc = props.globals.getNode("/ECAM/rightmsg/linec7", 1);
var ECAM_line8rc = props.globals.getNode("/ECAM/rightmsg/linec8", 1);

var canvas_upperECAM = {
	new: func(svg) {
		var obj = {parents: [canvas_upperECAM] };
		obj.canvas = canvas.new({
			"name": "upperECAM",
			"size": [1024, 1024],
			"view": [1024, 1024],
			"mipmapping": 1,
		});
		
		obj.canvas.addPlacement({"node": "uecam.screen"});
        obj.group = obj.canvas.createGroup();
		
		obj.font_mapper = func(family, weight) {
			return "LiberationFonts/LiberationSans-Regular.ttf";
		};
		
		canvas.parsesvg(obj.group, svg, {"font-mapper": obj.font_mapper} );
		
		foreach(var key; obj.getKeys()) {
			obj[key] = obj.group.getElementById(key);
			
			var clip_el = obj.group.getElementById(key ~ "_clip");
			if (clip_el != nil) {
				clip_el.setVisible(0);
				var tran_rect = clip_el.getTransformedBounds();

				var clip_rect = sprintf("rect(%d,%d, %d,%d)", 
				tran_rect[1],
				tran_rect[2],
				tran_rect[3],
				tran_rect[0]);
				obj[key].set("clip", clip_rect);
				obj[key].set("clip-frame", canvas.Element.PARENT);
			}
		};
		
		obj.update_items_fadec_powered_n1 = [
			props.UpdateManager.FromHashValue("N1_1", 0.0001, func(val) {
				obj["N11-needle"].setRotation((val + 90) * D2R);
			}),
			props.UpdateManager.FromHashValue("N1_2", 0.0001, func(val) {
				obj["N12-needle"].setRotation((val + 90) * D2R);
			}),
			props.UpdateManager.FromHashValue("N1_actual_1", 0.001, func(val) {
				obj["N11"].setText(sprintf("%s", math.floor(val + 0.05)));
				obj["N11-decimal"].setText(sprintf("%s", int(10 * math.mod(val + 0.05, 1))));
			}),
			props.UpdateManager.FromHashValue("N1_actual_2", 0.001, func(val) {
				obj["N12"].setText(sprintf("%s", math.floor(val + 0.05)));
				obj["N12-decimal"].setText(sprintf("%s", int(10 * math.mod(val + 0.05, 1))));
			}),
			props.UpdateManager.FromHashValue("N1_lim", 0.0001, func(val) {
				obj["N11-ylim"].setRotation((val + 90) * D2R);
				obj["N12-ylim"].setRotation((val + 90) * D2R);
			}),
			props.UpdateManager.FromHashValue("N1thr_1", 0.0001, func(val) {
				obj["N11-thr"].setRotation((val + 90) * D2R);
			}),
			props.UpdateManager.FromHashValue("N1thr_2", 0.0001, func(val) {
				obj["N12-thr"].setRotation((val + 90) * D2R);
			}),
			props.UpdateManager.FromHashValue("reverser_1", 0.0001, func(val) {
				if (val < 0.01 and fadec.FADEC.Eng1.n1 == 1) {
					obj["N11-thr"].show();
				} else {
					obj["N11-thr"].hide();
				}
				
				if (val >= 0.01 and fadec.FADEC.Eng1.n1 == 1) {
					obj["REV1"].show();
					obj["REV1-box"].show();
				} else {
					obj["REV1"].hide();
					obj["REV1-box"].hide();
				}
				
				if (val >= 0.95) {
					obj["REV2"].setColor(0.0509,0.7529,0.2941);
				} else {
					obj["REV2"].setColor(0.7333,0.3803,0);
				}
			}),
			props.UpdateManager.FromHashValue("reverser_2", 0.0001, func(val) {
				if (val < 0.01 and fadec.FADEC.Eng2.n1 == 1) {
					obj["N12-thr"].show();
				} else {
					obj["N12-thr"].hide();
				}
				
				if (val >= 0.01 and fadec.FADEC.Eng2.n1 == 1) {
					obj["REV2"].show();
					obj["REV2-box"].show();
				} else {
					obj["REV2"].hide();
					obj["REV2-box"].hide();
				}
				
				if (val >= 0.95) {
					obj["REV1"].setColor(0.0509,0.7529,0.2941);
				} else {
					obj["REV1"].setColor(0.7333,0.3803,0);
				}
			}),
		];
		
		obj.update_items_fadec_powered_n2 = [
			props.UpdateManager.FromHashValue("N2_actual_1", 0.001, func(val) {
				obj["N21"].setText(sprintf("%s", math.floor(val + 0.05)));
				obj["N21-decimal"].setText(sprintf("%s", int(10 * math.mod(val + 0.05, 1))));
			}),
			props.UpdateManager.FromHashValue("N2_actual_2", 0.001, func(val) {
				obj["N22"].setText(sprintf("%s", math.floor(val + 0.05)));
				obj["N22-decimal"].setText(sprintf("%s", int(10 * math.mod(val + 0.05, 1))));
			}),
		];
		
		obj.update_items_fadec_powered_egt = [
			props.UpdateManager.FromHashValue("egt_1", 0.5, func(val) {
				obj["EGT1"].setText(sprintf("%s", math.round(val)));
			}),
			props.UpdateManager.FromHashValue("egt_1_needle", 0.01, func(val) {
				obj["EGT1-needle"].setRotation((val + 90) * D2R);
			}),
			props.UpdateManager.FromHashValue("egt_2", 0.5, func(val) {
				obj["EGT2"].setText(sprintf("%s", math.round(val)));
			}),
			props.UpdateManager.FromHashValue("egt_2_needle", 0.01, func(val) {
				obj["EGT2-needle"].setRotation((val + 90) * D2R);
			}),
		];
		
		obj.update_items_fadec_powered_ff = [
			props.UpdateManager.FromHashValue("fuelflow_1", 0.5, func(val) {
				if (acconfig_weight_kgs.getValue()) {
					obj["FF1"].setText(sprintf("%s", math.round(val * LBS2KGS, 10)));
				} else {
					obj["FF1"].setText(sprintf("%s", math.round(val, 10)));
				}
			}),
			props.UpdateManager.FromHashValue("fuelflow_2", 0.5, func(val) {
				if (acconfig_weight_kgs.getValue()) {
					obj["FF2"].setText(sprintf("%s", math.round(val * LBS2KGS, 10)));
				} else {
					obj["FF2"].setText(sprintf("%s", math.round(val, 10)));
				}
			}),
		];
		
		obj.update_items = [
			props.UpdateManager.FromHashList(["AcEssBus", "DisplayBrightness"], 0.01, func(val) {
				if (val.DisplayBrightness > 0.01 and val.AcEssBus >= 110) {
					obj.group.setVisible(1);
				} else {
					obj.group.setVisible(0);
				}
			}),
			props.UpdateManager.FromHashValue("acconfigUnits", 1, func(val) {
				if (val) {
					obj["FOB-weight-unit"].setText("KG");
					obj["FFlow-weight-unit"].setText("KG/H");
				} else {
					obj["FOB-weight-unit"].setText("LBS");
					obj["FFlow-weight-unit"].setText("LBS/H");
				}
			}),
			props.UpdateManager.FromHashValue("fuelTotalLbs", 1, func(val) {
				if (acconfig_weight_kgs.getValue())
				{
					obj["FOB-LBS"].setText(sprintf("%s", math.round(val * LBS2KGS, 10)));
				} else {
					obj["FOB-LBS"].setText(sprintf("%s", math.round(val, 10)));
				}
			}),
			props.UpdateManager.FromHashList(["flapxOffset", "flapyOffset"], 0.01, func(val) {
				obj["FlapIndicator"].setTranslation(val.flapxOffset,val.flapyOffset);
			}),
			props.UpdateManager.FromHashList(["slatxOffset", "slatyOffset"], 0.01, func(val) {
				obj["SlatIndicator"].setTranslation(val.slatxOffset,val.slatyOffset);
			}),
			props.UpdateManager.FromHashList(["flapxOffsetTrans", "flapyOffsetTrans"], 0.01, func(val) {
				obj["FlapLine"].setTranslation(val.flapxOffsetTrans,val.flapyOffsetTrans);
			}),
			props.UpdateManager.FromHashList(["slatxOffsetTrans", "slatyOffsetTrans"], 0.01, func(val) {
				obj["SlatLine"].setTranslation(val.slatxOffsetTrans,val.slatyOffsetTrans);
			}),
			props.UpdateManager.FromHashValue("alphaFloor", 1, func(val) {
				if (val) {
					obj["aFloor"].show();
				} else {
					obj["aFloor"].hide();
				}
			}),
			props.UpdateManager.FromHashValue("flapsPos", 1, func(val) {
				flapsPos = val;
				if (flapsPos == 1) {
					obj["FlapTxt"].setText("1");
				} else if (flapsPos == 2) {
					obj["FlapTxt"].setText("1+F");
				} else if (flapsPos == 3) {
					obj["FlapTxt"].setText("2");
				} else if (flapsPos == 4) {
					obj["FlapTxt"].setText("3");
				} else if (flapsPos == 5) {
					obj["FlapTxt"].setText("FULL");
				} else {
					obj["FlapTxt"].setText(" "); # More efficient then hide/show
				}
				
				if (flapsPos > 0) {
					obj["FlapDots"].show();
				} else {
					obj["FlapDots"].hide();
				}
			}),
			props.UpdateManager.FromHashValue("thrustLimit", 1, func(val) {
				if (val == "FLX") {
					obj["FlxLimDegreesC"].show();
					obj["FlxLimTemp"].show();
				} else {
					obj["FlxLimDegreesC"].hide();
					obj["FlxLimTemp"].hide();
				}
				obj["N1Lim-mode"].setText(sprintf("%s", val));
			}),
			props.UpdateManager.FromHashValue("n1Limit", 0.01, func(val) {
				obj["N1Lim"].setText(sprintf("%s", math.floor(val + 0.05)));
				obj["N1Lim-decimal"].setText(sprintf("%s", int(10 * math.mod(val + 0.05, 1))));
			}),
			props.UpdateManager.FromHashValue("flexTemp", 1, func(val) {
				obj["FlxLimTemp"].setText(sprintf("%2.0d",val));
			}),
			props.UpdateManager.FromHashList(["fadecPower1", "fadecPower2", "fadecPowerStart","thrustLimit"], 1, func(val) {
				if (val.fadecPower1 or val.fadecPower2 or val.fadecPowerStart) {
					obj["N1Lim-mode"].show();
					obj["N1Lim-XX"].hide();
					obj["N1Lim-XX2"].hide();
				} else {
					obj["N1Lim-mode"].hide();
					obj["N1Lim-XX"].show();
					obj["N1Lim-XX2"].show();
				}
				
				if ((val.fadecPower1 or val.fadecPower2 or val.fadecPowerStart) and val.thrustLimit != "MREV") {
					obj["N1Lim"].show();
					obj["N1Lim-decpnt"].show();
					obj["N1Lim-decimal"].show();
					obj["N1Lim-percent"].show();
				} else {
					obj["N1Lim"].hide();
					obj["N1Lim-decpnt"].hide();
					obj["N1Lim-decimal"].hide();
					obj["N1Lim-percent"].hide();
				}
			}),
		];
		
		obj.ecam_update = [
			props.UpdateManager.FromHashValue("ecamMsg1", 1, func(val) {
				obj["ECAML1"].setText(sprintf("%s", val));
			}),
			props.UpdateManager.FromHashValue("ecamMsg2", 1, func(val) {
				obj["ECAML2"].setText(sprintf("%s", val));
			}),
			props.UpdateManager.FromHashValue("ecamMsg3", 1, func(val) {
				obj["ECAML3"].setText(sprintf("%s", val));
			}),
			props.UpdateManager.FromHashValue("ecamMsg4", 1, func(val) {
				obj["ECAML4"].setText(sprintf("%s", val));
			}),
			props.UpdateManager.FromHashValue("ecamMsg5", 1, func(val) {
				obj["ECAML5"].setText(sprintf("%s", val));
			}),
			props.UpdateManager.FromHashValue("ecamMsg6", 1, func(val) {
				obj["ECAML6"].setText(sprintf("%s", val));
			}),
			props.UpdateManager.FromHashValue("ecamMsg7", 1, func(val) {
				obj["ECAML7"].setText(sprintf("%s", val));
			}),
			props.UpdateManager.FromHashValue("ecamMsg8", 1, func(val) {
				obj["ECAML8"].setText(sprintf("%s", val));
			}),
			props.UpdateManager.FromHashValue("ecamMsg1R", 1, func(val) {
				obj["ECAMR1"].setText(sprintf("%s", val));
			}),
			props.UpdateManager.FromHashValue("ecamMsg2R", 1, func(val) {
				obj["ECAMR2"].setText(sprintf("%s", val));
			}),
			props.UpdateManager.FromHashValue("ecamMsg3R", 1, func(val) {
				obj["ECAMR3"].setText(sprintf("%s", val));
			}),
			props.UpdateManager.FromHashValue("ecamMsg4R", 1, func(val) {
				obj["ECAMR4"].setText(sprintf("%s", val));
			}),
			props.UpdateManager.FromHashValue("ecamMsg5R", 1, func(val) {
				obj["ECAMR5"].setText(sprintf("%s", val));
			}),
			props.UpdateManager.FromHashValue("ecamMsg6R", 1, func(val) {
				obj["ECAMR6"].setText(sprintf("%s", val));
			}),
			props.UpdateManager.FromHashValue("ecamMsg7R", 1, func(val) {
				obj["ECAMR7"].setText(sprintf("%s", val));
			}),
			props.UpdateManager.FromHashValue("ecamMsg8R", 1, func(val) {
				obj["ECAMR8"].setText(sprintf("%s", val));
			}),
		];
		
		obj.createListenerForLine("/ECAM/msg/linec1", ECAM_line1c, "ECAML1");
		obj.createListenerForLine("/ECAM/msg/linec2", ECAM_line2c, "ECAML2");
		obj.createListenerForLine("/ECAM/msg/linec3", ECAM_line3c, "ECAML3");
		obj.createListenerForLine("/ECAM/msg/linec4", ECAM_line4c, "ECAML4");
		obj.createListenerForLine("/ECAM/msg/linec5", ECAM_line5c, "ECAML5");
		obj.createListenerForLine("/ECAM/msg/linec6", ECAM_line6c, "ECAML6");
		obj.createListenerForLine("/ECAM/msg/linec7", ECAM_line7c, "ECAML7");
		obj.createListenerForLine("/ECAM/msg/linec8", ECAM_line8c, "ECAML8");
		
		obj.createListenerForLine("/ECAM/rightmsg/linec1", ECAM_line1rc, "ECAMR1");
		obj.createListenerForLine("/ECAM/rightmsg/linec2", ECAM_line2rc, "ECAMR2");
		obj.createListenerForLine("/ECAM/rightmsg/linec3", ECAM_line3rc, "ECAMR3");
		obj.createListenerForLine("/ECAM/rightmsg/linec4", ECAM_line4rc, "ECAMR4");
		obj.createListenerForLine("/ECAM/rightmsg/linec5", ECAM_line5rc, "ECAMR5");
		obj.createListenerForLine("/ECAM/rightmsg/linec6", ECAM_line6rc, "ECAMR6");
		obj.createListenerForLine("/ECAM/rightmsg/linec7", ECAM_line7rc, "ECAMR7");
		obj.createListenerForLine("/ECAM/rightmsg/linec8", ECAM_line8rc, "ECAMR8");
		
		obj.page = obj.group;
		return obj;
	},
	getKeys: func() {
		return ["N11-needle","N11-thr","N11-ylim","N11","N11-decpnt","N11-decimal","N11-box","N11-scale","N11-scale2","N11-scaletick","N11-scalenum","N11-XX","N11-XX2","N11-XX-box","EGT1-needle","EGT1","EGT1-scale","EGT1-box","EGT1-scale2","EGT1-scaletick",
		"EGT1-XX","N21","N21-decpnt","N21-decimal","N21-XX","FF1","FF1-XX","N12-needle","N12-thr","N12-ylim","N12","N12-decpnt","N12-decimal","N12-box","N12-scale","N12-scale2","N12-scaletick","N12-scalenum","N12-XX","N12-XX2","N12-XX-box","EGT2-needle","EGT2",
		"EGT2-scale","EGT2-box","EGT2-scale2","EGT2-scaletick","EGT2-XX","N22","N22-decpnt","N22-decimal","N22-XX","FF2","FF2-XX","FOB-LBS","FlapTxt","FlapDots","N1Lim-mode","N1Lim","N1Lim-decpnt","N1Lim-decimal","N1Lim-percent","N1Lim-XX","N1Lim-XX2","REV1",
		"REV1-box","REV2","REV2-box","ECAM_Left","ECAML1","ECAML2","ECAML3","ECAML4","ECAML5","ECAML6","ECAML7","ECAML8","ECAMR1", "ECAMR2", "ECAMR3", "ECAMR4", "ECAMR5", "ECAMR6", "ECAMR7", "ECAMR8", "ECAM_Right",
		"FOB-weight-unit","FFlow-weight-unit","SlatAlphaLock","SlatIndicator","FlapIndicator","SlatLine","FlapLine","aFloor","FlxLimDegreesC","FlxLimTemp"];
	},
	getColorString: func(color) {
		if (color == "w") {
			return [0.8078,0.8039,0.8078];
		} else if (color == "m") {
			return [0.6901,0.3333,0.7450];
		} else if (color == "c") {
			return [0.0901,0.6039,0.7176];
		} else if (color == "g") {
			return [0.0509,0.7529,0.2941];
		} else if (color == "a") {
			return [0.7333,0.3803,0];
		} else if (color == "r") {
			return [1,0,0];
		} else {
			return [1,1,1];
		}
	},
	createListenerForLine: func(prop, node, key) {
		setlistener(prop, func() {
			me[key].setColor(me.getColorString(node.getValue()));
		}, 0, 0);
	},
	update: func(notification) {
		foreach(var update_item; me.update_items)
        {
            update_item.update(notification);
        }
		
		if (me.group.getVisible == 0) {
			return;
		}
		
		if (fadec.FADEC.Eng1.n1 == 1) {
			me["N11-scale"].setColor(0.8078,0.8039,0.8078);
			me["N11-scale2"].setColor(1,0,0);
			me["N11"].show();
			me["N11-decimal"].show();
			me["N11-decpnt"].show();
			me["N11-needle"].show();
			me["N11-ylim"].show();
			me["N11-scaletick"].show();
			me["N11-scalenum"].show();
			me["N11-box"].show();
			me["N11-XX"].hide();
			me["N11-XX2"].hide();
			me["N11-XX-box"].hide();
		} else {
			me["N11-scale"].setColor(0.7333,0.3803,0);
			me["N11-scale2"].setColor(0.7333,0.3803,0);
			me["N11"].hide();
			me["N11-decimal"].hide();
			me["N11-decpnt"].hide();
			me["N11-needle"].hide();
			me["N11-ylim"].hide();
			me["N11-scaletick"].hide();
			me["N11-scalenum"].hide();
			me["N11-box"].hide();
			me["N11-XX"].show();
			me["N11-XX2"].show();
			me["N11-XX-box"].show();
		}
		
		if (fadec.FADEC.Eng2.n1 == 1) {
			me["N12-scale"].setColor(0.8078,0.8039,0.8078);
			me["N12-scale2"].setColor(1,0,0);
			me["N12"].show();
			me["N12-decimal"].show();
			me["N12-decpnt"].show();
			me["N12-needle"].show();
			me["N12-ylim"].show();
			me["N12-scaletick"].show();
			me["N12-scalenum"].show();
			me["N12-box"].show();
			me["N12-XX"].hide();
			me["N12-XX2"].hide();
			me["N12-XX-box"].hide();
		} else {
			me["N12-scale"].setColor(0.7333,0.3803,0);
			me["N12-scale2"].setColor(0.7333,0.3803,0);
			me["N12"].hide();
			me["N12-decimal"].hide();
			me["N12-decpnt"].hide();
			me["N12-needle"].hide();
			me["N12-ylim"].hide();
			me["N12-scaletick"].hide();
			me["N12-scalenum"].hide();
			me["N12-box"].hide();
			me["N12-XX"].show();
			me["N12-XX2"].show();
			me["N12-XX-box"].show();
		}
		
		if (fadec.FADEC.Eng1.egt == 1) {
			me["EGT1-scale"].setColor(0.8078,0.8039,0.8078);
			me["EGT1-scale2"].setColor(1,0,0);
			me["EGT1"].show();
			me["EGT1-needle"].show();
			me["EGT1-scaletick"].show();
			me["EGT1-box"].show();
			me["EGT1-XX"].hide();
		} else {
			me["EGT1-scale"].setColor(0.7333,0.3803,0);
			me["EGT1-scale2"].setColor(0.7333,0.3803,0);
			me["EGT1"].hide();
			me["EGT1-needle"].hide();
			me["EGT1-scaletick"].hide();
			me["EGT1-box"].hide();
			me["EGT1-XX"].show();
		}
		
		if (fadec.FADEC.Eng2.egt == 1) {
			me["EGT2-scale"].setColor(0.8078,0.8039,0.8078);
			me["EGT2-scale2"].setColor(1,0,0);
			me["EGT2"].show();
			me["EGT2-needle"].show();
			me["EGT2-scaletick"].show();
			me["EGT2-box"].show();
			me["EGT2-XX"].hide();
		} else {
			me["EGT2-scale"].setColor(0.7333,0.3803,0);
			me["EGT2-scale2"].setColor(0.7333,0.3803,0);
			me["EGT2"].hide();
			me["EGT2-needle"].hide();
			me["EGT2-scaletick"].hide();
			me["EGT2-box"].hide();
			me["EGT2-XX"].show();
		}
		
		if (fadec.FADEC.Eng1.n2 == 1) {
			me["N21"].show();
			me["N21-decimal"].show();
			me["N21-decpnt"].show();
			me["N21-XX"].hide();
		} else {
			me["N21"].hide();
			me["N21-decimal"].hide();
			me["N21-decpnt"].hide();
			me["N21-XX"].show();
		}
		
		if (fadec.FADEC.Eng2.n2 == 1) {
			me["N22"].show();
			me["N22-decimal"].show();
			me["N22-decpnt"].show();
			me["N22-XX"].hide();
		} else {
			me["N22"].hide();
			me["N22-decimal"].hide();
			me["N22-decpnt"].hide();
			me["N22-XX"].show();
		}
		
		if (fadec.FADEC.Eng1.ff == 1) {
			me["FF1"].show();
			me["FF1-XX"].hide();
		} else {
			me["FF1"].hide();
			me["FF1-XX"].show();
		}
		
		if (fadec.FADEC.Eng2.ff == 1) {
			me["FF2"].show();
			me["FF2-XX"].hide();
		} else {
			me["FF2"].hide();
			me["FF2-XX"].show();
		}
		
		if (pts.Fdm.JSBsim.Fcs.slatLocked.getValue()) {
			if (slatLockGoing == 0) {
				slatLockGoing = 1;
			}
			if (slatLockGoing == 1) {
				slatLockTimer.start();
				if (slatLockFlash.getValue()) {
					me["SlatAlphaLock"].show();	
				} else {
					me["SlatAlphaLock"].hide();	
				}
			}
		} else {
			slatLockTimer.stop();
			slatLockGoing = 0;
			me["SlatAlphaLock"].hide();	
		}
		
		if (fadec.FADEC.Eng1.n1 or fadec.FADEC.Eng2.n1) {
			foreach(var update_item; me.update_items_fadec_powered_n1)
			{
				update_item.update(notification);
			}
		}
		
		if (fadec.FADEC.Eng1.n2 or fadec.FADEC.Eng2.n2) {
			foreach(var update_item; me.update_items_fadec_powered_n2)
			{
				update_item.update(notification);
			}
		}
		
		if (fadec.FADEC.Eng1.egt or fadec.FADEC.Eng2.egt) {
			foreach(var update_item; me.update_items_fadec_powered_egt)
			{
				update_item.update(notification);
			}
		}
		
		if (fadec.FADEC.Eng1.ff or fadec.FADEC.Eng2.ff) {
			foreach(var update_item; me.update_items_fadec_powered_ff)
			{
				update_item.update(notification);
			}
		}
		
		foreach (var update_item; me.ecam_update)
		{
			update_item.update(notification);
		}
	},
};

var UpperECAMRecipient =
{
	new: func(_ident)
	{
		var new_class = emesary.Recipient.new(_ident);
		new_class.MainScreen = nil;
		new_class.Receive = func(notification)
		{
			if (notification.NotificationType == "FrameNotification")
			{
				if (new_class.MainScreen == nil)
					new_class.MainScreen = canvas_upperECAM.new("Aircraft/A320-family/Models/Instruments/Upper-ECAM/res/cfm-eis2.svg", "A320 Upper ECAM CFM");
					if (!math.mod(notifications.frameNotification.FrameCount,2)){
						new_class.MainScreen.update(notification);
					}
				return emesary.Transmitter.ReceiptStatus_OK;
			}
			return emesary.Transmitter.ReceiptStatus_NotProcessed;
		};
		return new_class;
	},
};

emesary.GlobalTransmitter.Register(UpperECAMRecipient.new("A320 Upper ECAM"));

input = {
	fuelTotalLbs: "/consumables/fuel/total-fuel-lbs",
	AcEssBus: "/systems/electrical/bus/ac-ess",
	DisplayBrightness: "/controls/lighting/DU/du3",
	acconfigUnits: "/systems/acconfig/options/weight-kgs",
	
	# N1 parameters
	N1_1: "/ECAM/Upper/N1[0]",
	N1_2: "/ECAM/Upper/N1[1]",
	N1_actual_1: "/engines/engine[0]/n1-actual",
	N1_actual_2: "/engines/engine[1]/n1-actual",
	N1_lim: "/ECAM/Upper/N1ylim",
	N1thr_1: "/ECAM/Upper/N1thr[0]",
	N1thr_2: "/ECAM/Upper/N1thr[1]",
	
	# N2 parameters
	N2_actual_1: "/engines/engine[0]/n2-actual",
	N2_actual_2: "/engines/engine[1]/n2-actual",
	
	# Reverse thrust
	reverser_1: "/engines/engine[0]/reverser-pos-norm",
	reverser_2: "/engines/engine[1]/reverser-pos-norm",
	
	# EGT
	egt_1: "/engines/engine[0]/egt-actual",
	egt_2: "/engines/engine[1]/egt-actual",
	egt_1_needle: "/ECAM/Upper/EGT[0]",
	egt_2_needle: "/ECAM/Upper/EGT[1]",
	
	# fuel flow
	fuelflow_1: "/engines/engine[0]/fuel-flow_actual",
	fuelflow_2: "/engines/engine[1]/fuel-flow_actual",
	
	# flaps
	flapsPos: "/controls/flight/flaps-pos",
	flapxOffset: "/ECAM/Upper/FlapX",
	flapyOffset: "/ECAM/Upper/FlapY",
	slatxOffset: "/ECAM/Upper/SlatX",
	slatyOffset: "/ECAM/Upper/SlatY",
	flapxOffsetTrans: "/ECAM/Upper/FlapXtrans",
	flapyOffsetTrans: "/ECAM/Upper/FlapYtrans",
	slatxOffsetTrans: "/ECAM/Upper/SlatXtrans",
	slatyOffsetTrans: "/ECAM/Upper/SlatYtrans",
	
	# fadec
	alphaFloor: "/systems/thrust/alpha-floor",
	thrustLimit: "/controls/engines/thrust-limit",
	n1Limit: "/controls/engines/n1-limit",
	flexTemp: "/FMGC/internal/flex",
	fadecPower1: "/systems/fadec/power1",
	fadecPower2: "/systems/fadec/power2",
	fadecPowerStart: "/systems/fadec/powerup",
	
	# ecam
	ecamMsg1: "/ECAM/msg/line1",
	ecamMsg2: "/ECAM/msg/line2",
	ecamMsg3: "/ECAM/msg/line3",
	ecamMsg4: "/ECAM/msg/line4",
	ecamMsg5: "/ECAM/msg/line5",
	ecamMsg6: "/ECAM/msg/line6",
	ecamMsg7: "/ECAM/msg/line7",
	ecamMsg8: "/ECAM/msg/line8",
	ecamMsg1R: "/ECAM/rightmsg/line1",
	ecamMsg2R: "/ECAM/rightmsg/line2",
	ecamMsg3R: "/ECAM/rightmsg/line3",
	ecamMsg4R: "/ECAM/rightmsg/line4",
	ecamMsg5R: "/ECAM/rightmsg/line5",
	ecamMsg6R: "/ECAM/rightmsg/line6",
	ecamMsg7R: "/ECAM/rightmsg/line7",
	ecamMsg8R: "/ECAM/rightmsg/line8",
};

foreach (var name; keys(input)) {
	emesary.GlobalTransmitter.NotifyAll(notifications.FrameNotificationAddProperty.new("A320 Upper ECAM", name, input[name]));
}

setlistener("/sim/signals/fdm-initialized", func() {
	execLoop();
}, 0, 0);

var slatLockGoing = 0;
var slatLockTimer = maketimer(0.50, func {
	if (!slatLockFlash.getBoolValue()) {
		slatLockFlash.setBoolValue(1);
	} else {
		slatLockFlash.setBoolValue(0);
	}
});