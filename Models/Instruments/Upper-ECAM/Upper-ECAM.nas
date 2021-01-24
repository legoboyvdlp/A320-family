var flapsPos = nil;
var LBS2KGS = 0.4535924;
var slatLockGoing = 0;
var slatLockFlash = 0;
var acconfig_weight_kgs = props.globals.getNode("/systems/acconfig/options/weight-kgs", 1);
var acconfig = props.globals.getNode("/systems/acconfig/autoconfig-running", 1);
var du3_test = props.globals.initNode("/instrumentation/du/du3-test", 0, "BOOL");
var du3_test_time = props.globals.initNode("/instrumentation/du/du3-test-time", 0.0, "DOUBLE");
var du3_test_amount = props.globals.initNode("/instrumentation/du/du3-test-amount", 0.0, "DOUBLE");
var du3_offtime = props.globals.initNode("/instrumentation/du/du3-off-time", 0.0, "DOUBLE");
var du3_lgt = props.globals.getNode("/controls/lighting/DU/du3");
var eng_option = props.globals.getNode("/options/eng", 1);

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
	new: func(svg, name, type) {
		var obj = {parents: [canvas_upperECAM] };
		obj.canvas = canvas.new({
			"name": "upperECAM",
			"size": [1024, 1024],
			"view": [1024, 1024],
			"mipmapping": 1,
		});
		
		obj.canvas.addPlacement({"node": "uecam.screen"});
        obj.group = obj.canvas.createGroup();
        obj.test = obj.canvas.createGroup();
		
		obj.typeString = type;
		
		obj.font_mapper = func(family, weight) {
			return "LiberationFonts/LiberationSans-Regular.ttf";
		};
		
		canvas.parsesvg(obj.group, svg, {"font-mapper": obj.font_mapper} );
		obj.keysHash = (type == "IAE" ? obj.getKeysIAE() : obj.getKeysCFM());
 		foreach(var key; obj.keysHash) {
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
		
		canvas.parsesvg(obj.test, "Aircraft/A320-family/Models/Instruments/Common/res/du-test.svg", {"font-mapper": obj.font_mapper} );
		foreach(var key; obj.getKeysTest()) {
			obj[key] = obj.test.getElementById(key);
		};
		
		obj.units = acconfig_weight_kgs.getValue();
		
		obj.update_items = [
			props.UpdateManager.FromHashValue("acconfigUnits", 1, func(val) {
				if (obj.typeString == "IAE") {
					if (val) {
						obj["FOB-weight-unit"].setText("KG");
						obj["FFlow1-weight-unit"].setText("KG/H");
						obj["FFlow2-weight-unit"].setText("KG/H");
					} else {
						obj["FOB-weight-unit"].setText("LBS");
						obj["FFlow1-weight-unit"].setText("LBS/H");
						obj["FFlow2-weight-unit"].setText("LBS/H");
					}
				} else {
					if (val) {
						obj["FOB-weight-unit"].setText("KG");
						obj["FFlow-weight-unit"].setText("KG/H");
					} else {
						obj["FOB-weight-unit"].setText("LBS");
						obj["FFlow-weight-unit"].setText("LBS/H");
					}
				}
				obj.units = val;
			}),
			props.UpdateManager.FromHashList(["fuelTotalLbs","acconfigUnits"], 1, func(val) {
				if (obj.units)
				{
					obj["FOB-LBS"].setText(sprintf("%s", math.round(val.fuelTotalLbs * LBS2KGS, 10)));
				} else {
					obj["FOB-LBS"].setText(sprintf("%s", math.round(val.fuelTotalLbs, 10)));
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
			props.UpdateManager.FromHashValue("flexTemp", 1, func(val) {
				obj["FlxLimTemp"].setText(sprintf("%2.0d",val));
			}),
			props.UpdateManager.FromHashValue("slatLocked", nil, func(val) {
				if (val) {
					if (slatLockGoing == 0) {
						slatLockGoing = 1;
						slatLockTimer.start();
					}
				} else {
					slatLockTimer.stop();
					slatLockGoing = 0;
					slatLockFlash = 0;
				}
			}),
		];
		
		obj.update_items_fadec_powered_n1 = [
			props.UpdateManager.FromHashValue("N1_1", 0.01, func(val) {
				obj["N11-needle"].setRotation((val + 90) * D2R);
			}),
			props.UpdateManager.FromHashValue("N1_2", 0.01, func(val) {
				obj["N12-needle"].setRotation((val + 90) * D2R);
			}),
			props.UpdateManager.FromHashValue("N1_actual_1", 0.025, func(val) {
				obj["N11"].setText(sprintf("%s", math.floor(val + 0.05)));
				obj["N11-decimal"].setText(sprintf("%s", int(10 * math.mod(val + 0.05, 1))));
			}),
			props.UpdateManager.FromHashValue("N1_actual_2", 0.025, func(val) {
				obj["N12"].setText(sprintf("%s", math.floor(val + 0.05)));
				obj["N12-decimal"].setText(sprintf("%s", int(10 * math.mod(val + 0.05, 1))));
			}),
			props.UpdateManager.FromHashValue("N1_lim", 0.01, func(val) {
				obj["N11-ylim"].setRotation((val + 90) * D2R);
				obj["N12-ylim"].setRotation((val + 90) * D2R);
			}),
			props.UpdateManager.FromHashValue("N1thr_1", 0.01, func(val) {
				obj["N11-thr"].setRotation((val + 90) * D2R);
			}),
			props.UpdateManager.FromHashValue("N1thr_2", 0.01, func(val) {
				obj["N12-thr"].setRotation((val + 90) * D2R);
			}),
			props.UpdateManager.FromHashList(["reverser_1","eng1_n1","eng1_epr","N1_mode_1"], nil, func(val) {
				obj.updateFadecN1Power1(val);
			}),
			props.UpdateManager.FromHashList(["reverser_2","eng2_n1","eng2_epr","N1_mode_2"], nil, func(val) {
				obj.updateFadecN1Power2(val);
			}),
		];
		
		obj.update_items_fadec_powered_epr = [
			props.UpdateManager.FromHashValue("EPR_1", 0.01, func(val) {
				obj["EPR1-needle"].setRotation((val + 90) * D2R);
			}),
			props.UpdateManager.FromHashValue("EPR_2", 0.01, func(val) {
				obj["EPR2-needle"].setRotation((val + 90) * D2R);
			}),
			props.UpdateManager.FromHashValue("EPR_actual_1", 0.0001, func(val) {
				obj["EPR1"].setText(sprintf("%1.0f", math.floor(val)));
				obj["EPR1-decimal"].setText(sprintf("%03d", (val - int(val)) * 1000));
			}),
			props.UpdateManager.FromHashValue("EPR_actual_2", 0.0001, func(val) {
				obj["EPR2"].setText(sprintf("%1.0f", math.floor(val)));
				obj["EPR2-decimal"].setText(sprintf("%03d", (val - int(val)) * 1000));
			}),
			props.UpdateManager.FromHashValue("EPR_lim", 0.005, func(val) {
				obj["EPR1-ylim"].setRotation((val + 90) * D2R);
				obj["EPR2-ylim"].setRotation((val + 90) * D2R);
			}),
			props.UpdateManager.FromHashValue("EPRthr_1", 0.005, func(val) {
				obj["EPR1-thr"].setRotation((val + 90) * D2R);
			}),
			props.UpdateManager.FromHashValue("EPRthr_2", 0.005, func(val) {
				obj["EPR2-thr"].setRotation((val + 90) * D2R);
			}),
		];
		
		obj.update_items_fadec_powered_n2 = [
			props.UpdateManager.FromHashValue("N2_actual_1", 0.025, func(val) {
				obj["N21"].setText(sprintf("%s", math.floor(val + 0.05)));
				obj["N21-decimal"].setText(sprintf("%s", int(10 * math.mod(val + 0.05, 1))));
			}),
			props.UpdateManager.FromHashValue("N2_actual_2", 0.025, func(val) {
				obj["N22"].setText(sprintf("%s", math.floor(val + 0.05)));
				obj["N22-decimal"].setText(sprintf("%s", int(10 * math.mod(val + 0.05, 1))));
			}),
		];
		
		obj.update_items_cfm_only = [
			props.UpdateManager.FromHashValue("thrustLimit", nil, func(val) {
				obj["N1Lim-mode"].setText(sprintf("%s", val));
			}),
			props.UpdateManager.FromHashValue("n1Limit", 0.01, func(val) {
				obj["N1Lim"].setText(sprintf("%s", math.floor(val + 0.05)));
				obj["N1Lim-decimal"].setText(sprintf("%s", int(10 * math.mod(val + 0.05, 1))));
			}),
			props.UpdateManager.FromHashList(["fadecPower1", "fadecPower2", "fadecPowerStart","thrustLimit"], nil, func(val) {
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
				
				if ((val.fadecPower1 or val.fadecPower2 or val.fadecPowerStart) and val.thrustLimit == "FLX") {
					obj["FlxLimDegreesC"].show();
					obj["FlxLimTemp"].show();
				} else {
					obj["FlxLimDegreesC"].hide();
					obj["FlxLimTemp"].hide();
				}
			}),
		];
		
		obj.update_items_iae_only = [
			props.UpdateManager.FromHashValue("thrustLimit", nil, func(val) {
				obj["EPRLim-mode"].setText(sprintf("%s", val));
			}),
			props.UpdateManager.FromHashValue("eprLimit", 0.0005, func(val) {
				obj["EPRLim"].setText(sprintf("%1.0f", math.floor(val)));
				obj["EPRLim-decimal"].setText(sprintf("%03d", (val - int(val)) * 1000));
			}),
			props.UpdateManager.FromHashList(["fadecPower1", "fadecPower2", "fadecPowerStart","thrustLimit"], nil, func(val) {
				if (val.fadecPower1 or val.fadecPower2 or val.fadecPowerStart) {
					obj["EPRLim-mode"].show();
					obj["EPRLim-XX"].hide();
					obj["EPRLim-XX2"].hide();
				} else {
					obj["EPRLim-mode"].hide();
					obj["EPRLim-XX"].show();
					obj["EPRLim-XX2"].show();
				}
				
				if ((val.fadecPower1 or val.fadecPower2 or val.fadecPowerStart) and val.thrustLimit != "MREV") {
					obj["EPRLim"].show();
					obj["EPRLim-decpnt"].show();
					obj["EPRLim-decimal"].show();
				} else {
					obj["EPRLim"].hide();
					obj["EPRLim-decpnt"].hide();
					obj["EPRLim-decimal"].hide();
				}
				
				if ((val.fadecPower1 or val.fadecPower2 or val.fadecPowerStart) and val.thrustLimit == "FLX") {
					obj["FlxLimDegreesC"].show();
					obj["FlxLimTemp"].show();
				} else {
					obj["FlxLimDegreesC"].hide();
					obj["FlxLimTemp"].hide();
				}
			}),
			props.UpdateManager.FromHashValue("N1_mode_1", nil, func(val) {
				if (fadec.FADEC.Eng1.n1.getValue() == 1 and val) {
					obj["N11-thr"].show();
					obj["N11-ylim"].hide(); # Keep it hidden, since N1 mode limit calculation is not done yet
				} else {
					obj["N11-thr"].hide();
					obj["N11-ylim"].hide();
				}
			}),
			props.UpdateManager.FromHashValue("N1_mode_2", nil, func(val) {
				if (fadec.FADEC.Eng2.n1.getValue() == 1 and val) {
					obj["N12-thr"].show();
					obj["N12-ylim"].hide(); # Keep it hidden, since N1 mode limit calculation is not done yet
				} else {
					obj["N12-thr"].hide();
					obj["N12-ylim"].hide();
				}
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
			props.UpdateManager.FromHashList(["fuelflow_1","acconfigUnits"], 1, func(val) {
				if (obj.units) {
					obj["FF1"].setText(sprintf("%s", math.round(val.fuelflow_1 * LBS2KGS, 10)));
				} else {
					obj["FF1"].setText(sprintf("%s", math.round(val.fuelflow_1, 10)));
				}
			}),
			props.UpdateManager.FromHashList(["fuelflow_2","acconfigUnits"], 1, func(val) {
				if (obj.units) {
					obj["FF2"].setText(sprintf("%s", math.round(val.fuelflow_2 * LBS2KGS, 10)));
				} else {
					obj["FF2"].setText(sprintf("%s", math.round(val.fuelflow_2, 10)));
				}
			}),
		];
		
		obj.ecam_update = [
			props.UpdateManager.FromHashValue("ecamMsg1", nil, func(val) {
				obj["ECAML1"].setText(sprintf("%s", val));
			}),
			props.UpdateManager.FromHashValue("ecamMsg2", nil, func(val) {
				obj["ECAML2"].setText(sprintf("%s", val));
			}),
			props.UpdateManager.FromHashValue("ecamMsg3", nil, func(val) {
				obj["ECAML3"].setText(sprintf("%s", val));
			}),
			props.UpdateManager.FromHashValue("ecamMsg4", nil, func(val) {
				obj["ECAML4"].setText(sprintf("%s", val));
			}),
			props.UpdateManager.FromHashValue("ecamMsg5", nil, func(val) {
				obj["ECAML5"].setText(sprintf("%s", val));
			}),
			props.UpdateManager.FromHashValue("ecamMsg6", nil, func(val) {
				obj["ECAML6"].setText(sprintf("%s", val));
			}),
			props.UpdateManager.FromHashValue("ecamMsg7", nil, func(val) {
				obj["ECAML7"].setText(sprintf("%s", val));
			}),
			props.UpdateManager.FromHashValue("ecamMsg8", nil, func(val) {
				obj["ECAML8"].setText(sprintf("%s", val));
			}),
			props.UpdateManager.FromHashValue("ecamMsg1R", nil, func(val) {
				obj["ECAMR1"].setText(sprintf("%s", val));
			}),
			props.UpdateManager.FromHashValue("ecamMsg2R", nil, func(val) {
				obj["ECAMR2"].setText(sprintf("%s", val));
			}),
			props.UpdateManager.FromHashValue("ecamMsg3R", nil, func(val) {
				obj["ECAMR3"].setText(sprintf("%s", val));
			}),
			props.UpdateManager.FromHashValue("ecamMsg4R", nil, func(val) {
				obj["ECAMR4"].setText(sprintf("%s", val));
			}),
			props.UpdateManager.FromHashValue("ecamMsg5R", nil, func(val) {
				obj["ECAMR5"].setText(sprintf("%s", val));
			}),
			props.UpdateManager.FromHashValue("ecamMsg6R", nil, func(val) {
				obj["ECAMR6"].setText(sprintf("%s", val));
			}),
			props.UpdateManager.FromHashValue("ecamMsg7R", nil, func(val) {
				obj["ECAMR7"].setText(sprintf("%s", val));
			}),
			props.UpdateManager.FromHashValue("ecamMsg8R", nil, func(val) {
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
		
		obj["ECAML1"].setFont("LiberationMonoCustom.ttf");
		obj["ECAML2"].setFont("LiberationMonoCustom.ttf");
		obj["ECAML3"].setFont("LiberationMonoCustom.ttf");
		obj["ECAML4"].setFont("LiberationMonoCustom.ttf");
		obj["ECAML5"].setFont("LiberationMonoCustom.ttf");
		obj["ECAML6"].setFont("LiberationMonoCustom.ttf");
		obj["ECAML7"].setFont("LiberationMonoCustom.ttf");
		obj["ECAML8"].setFont("LiberationMonoCustom.ttf");
		obj["ECAMR1"].setFont("LiberationMonoCustom.ttf");
		obj["ECAMR2"].setFont("LiberationMonoCustom.ttf");
		obj["ECAMR3"].setFont("LiberationMonoCustom.ttf");
		obj["ECAMR4"].setFont("LiberationMonoCustom.ttf");
		obj["ECAMR5"].setFont("LiberationMonoCustom.ttf");
		obj["ECAMR6"].setFont("LiberationMonoCustom.ttf");
		obj["ECAMR7"].setFont("LiberationMonoCustom.ttf");
		obj["ECAMR8"].setFont("LiberationMonoCustom.ttf");
		
		# cache
		obj._cachedN1 = [nil, nil];
		obj._cachedN2 = [nil, nil];
		obj._cachedEGT = [nil, nil];
		obj._cachedEPR = [nil, nil];
		obj._cachedFF = [nil, nil];
		
		obj.updateFadecN1Power1({reverser_1: 0, eng1_n1: 0, eng1_epr: 0, N1_mode_1: 0});
		obj.updateFadecN1Power2({reverser_2: 0, eng2_n1: 0, eng2_epr: 0, N1_mode_2: 0});
		
		return obj;
	},
	getKeysCFM: func() {
		return ["N11-needle","N11-thr","N11-ylim","N11","N11-decpnt","N11-decimal","N11-box","N11-scale","N11-scale2","N11-scaletick","N11-scalenum","N11-XX","N11-XX2","N11-XX-box","EGT1-needle","EGT1","EGT1-scale","EGT1-box","EGT1-scale2","EGT1-scaletick",
		"EGT1-XX","N21","N21-decpnt","N21-decimal","N21-XX","FF1","FF1-XX","N12-needle","N12-thr","N12-ylim","N12","N12-decpnt","N12-decimal","N12-box","N12-scale","N12-scale2","N12-scaletick","N12-scalenum","N12-XX","N12-XX2","N12-XX-box","EGT2-needle","EGT2",
		"EGT2-scale","EGT2-box","EGT2-scale2","EGT2-scaletick","EGT2-XX","N22","N22-decpnt","N22-decimal","N22-XX","FF2","FF2-XX","FOB-LBS","FlapTxt","FlapDots","N1Lim-mode","N1Lim","N1Lim-decpnt","N1Lim-decimal","N1Lim-percent","N1Lim-XX","N1Lim-XX2","REV1",
		"REV1-box","REV2","REV2-box","ECAM_Left","ECAML1","ECAML2","ECAML3","ECAML4","ECAML5","ECAML6","ECAML7","ECAML8","ECAMR1", "ECAMR2", "ECAMR3", "ECAMR4", "ECAMR5", "ECAMR6", "ECAMR7", "ECAMR8", "ECAM_Right",
		"FOB-weight-unit","FFlow-weight-unit","SlatAlphaLock","SlatIndicator","FlapIndicator","SlatLine","FlapLine","aFloor","FlxLimDegreesC","FlxLimTemp"];
	},
	getKeysIAE: func() {
		return ["EPR1-needle","EPR1-thr","EPR1-ylim","EPR1","EPR1-decpnt","EPR1-decimal","EPR1-box","EPR1-scale","EPR1-scaletick","EPR1-scalenum","EPR1-XX","EPR1-XX2","EGT1-needle","EGT1","EGT1-scale","EGT1-box","EGT1-scale2","EGT1-scaletick","EGT1-XX",
		"N11-needle","N11-thr","N11-ylim","N11","N11-decpnt","N11-decimal","N11-scale","N11-scale2","N11-scaletick","N11-scalenum","N11-XX","N21","N21-decpnt","N21-decimal","N21-XX","FF1","FF1-XX","EPR2-needle","EPR2-thr","EPR2-ylim","EPR2","EPR2-decpnt",
		"EPR2-decimal","EPR2-box","EPR2-scale","EPR2-scaletick","EPR2-scalenum","EPR2-XX","EPR2-XX2","EGT2-needle","EGT2","EGT2-scale","EGT2-scale2","EGT2-box","EGT2-scaletick","EGT2-XX","N12-needle","N12-thr","N12-ylim","N12","N12-decpnt","N12-decimal",
		"N12-scale","N12-scale2","N12-scaletick","N12-scalenum","N12-XX","N22","N22-decpnt","N22-decimal","N22-XX","FF2","FF2-XX","FOB-LBS","FlapTxt","FlapDots","EPRLim-mode","EPRLim","EPRLim-decpnt","EPRLim-decimal","EPRLim-XX","EPRLim-XX2","REV1","REV1-box",
		"REV2","REV2-box","ECAM_Left","ECAML1","ECAML2","ECAML3","ECAML4","ECAML5","ECAML6","ECAML7","ECAML8", "ECAMR1", "ECAMR2", "ECAMR3", "ECAMR4", "ECAMR5", "ECAMR6", "ECAMR7", "ECAMR8", "ECAM_Right",
		"FFlow1-weight-unit", "FFlow2-weight-unit", "FOB-weight-unit","SlatAlphaLock","SlatIndicator","FlapIndicator","SlatLine","FlapLine","aFloor","FlxLimDegreesC","FlxLimTemp"];
	},
	getKeysTest: func() {
		return ["Test_white","Test_text"];
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
	updateCommon: func(notification) {
		me.updatePower();
		
		if (me.test.getVisible() == 1) {
			me.updateTest(notification);
		}
		
		if (me.group.getVisible() == 0) {
			return;
		}
		
		foreach(var update_item; me.update_items)
        {
            update_item.update(notification);
        }
		
		if (notification.eng1_n1 != me._cachedN1[0]) {
			me.updateN11(notification);
		}
		if (notification.eng2_n1 != me._cachedN1[1]) {
			me.updateN12(notification);
		}
		
		if (fadec.FADEC.Eng1.n2 != me._cachedN2[0]) {
			me.updateN21();
		}
		if (fadec.FADEC.Eng2.n2 != me._cachedN2[1]) {
			me.updateN22();
		}
		
		if (fadec.FADEC.Eng1.egt != me._cachedEGT[0]) {
			me.updateEGT1();
		}
		if (fadec.FADEC.Eng2.egt != me._cachedEGT[1]) {
			me.updateEGT2();
		}
		
		if (fadec.FADEC.Eng1.ff != me._cachedFF[0]) {
			me.updateFF1();
		}
		if (fadec.FADEC.Eng2.ff != me._cachedFF[1]) {
			me.updateFF2();
		}
		
		if (notification.eng1_n1 or notification.eng2_n1) {
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
		
		if (slatLockFlash) {
			me["SlatAlphaLock"].show();	
		} else {
			me["SlatAlphaLock"].hide();	
		}
		
		foreach (var update_item; me.ecam_update)
		{
			update_item.update(notification);
		}
	},
	updateCFM: func(notification) {
		me.updateCommon(notification);
		if (me.group.getVisible() == 0) {
			return;
		}
		
		foreach (var update_item; me.update_items_cfm_only) {
			update_item.update(notification);
		}
	},
	updateIAE: func(notification) {
		me.updateCommon(notification);
		if (me.group.getVisible() == 0) {
			return;
		}
		
		foreach (var update_item; me.update_items_iae_only) {
			update_item.update(notification);
		}
		
		if (notification.eng1_epr != me._cachedEPR[0]) {
			me.updateEPR1(notification);
		}
		if (notification.eng2_epr != me._cachedEPR[1]) {
			me.updateEPR2(notification);
		}
		
		if (notification.eng1_epr or notification.eng2_epr) {
			foreach(var update_item; me.update_items_fadec_powered_epr)
			{
				update_item.update(notification);
			}
		}
	},
	
	updateN11: func(notification) {
		me._cachedN1[0] = notification.eng1_n1;
		if (me._cachedN1[0] == 1) {
			me["N11-scale"].setColor(0.8078,0.8039,0.8078);
			me["N11-scale2"].setColor(1,0,0);
			me["N11"].show();
			me["N11-decimal"].show();
			me["N11-decpnt"].show();
			me["N11-needle"].show();
			me["N11-scaletick"].show();
			me["N11-scalenum"].show();
			me["N11-XX"].hide();
			
			if (me.typeString == "CFM") {
				me["N11-ylim"].show();
				me["N11-box"].show();
				me["N11-XX2"].hide();
				me["N11-XX-box"].hide();
			}
		} else {
			me["N11-scale"].setColor(0.7333,0.3803,0);
			me["N11-scale2"].setColor(0.7333,0.3803,0);
			me["N11"].hide();
			me["N11-decimal"].hide();
			me["N11-decpnt"].hide();
			me["N11-needle"].hide();
			me["N11-scaletick"].hide();
			me["N11-scalenum"].hide();
			me["N11-XX"].show();
			
			if (me.typeString == "CFM") {
				me["N11-ylim"].hide();
				me["N11-box"].hide();
				me["N11-XX2"].show();
				me["N11-XX-box"].show();
			}
		}
	},
	updateN12: func(notification) {
		me._cachedN1[1] = notification.eng2_n1;
		if (me._cachedN1[1] == 1) {
			me["N12-scale"].setColor(0.8078,0.8039,0.8078);
			me["N12-scale2"].setColor(1,0,0);
			me["N12"].show();
			me["N12-decimal"].show();
			me["N12-decpnt"].show();
			me["N12-needle"].show();
			me["N12-scaletick"].show();
			me["N12-scalenum"].show();
			me["N12-XX"].hide();
			
			if (me.typeString == "CFM") {
				me["N12-ylim"].show();
				me["N12-box"].show();
				me["N12-XX2"].hide();
				me["N12-XX-box"].hide();
			}
		} else {
			me["N12-scale"].setColor(0.7333,0.3803,0);
			me["N12-scale2"].setColor(0.7333,0.3803,0);
			me["N12"].hide();
			me["N12-decimal"].hide();
			me["N12-decpnt"].hide();
			me["N12-needle"].hide();
			me["N12-scaletick"].hide();
			me["N12-scalenum"].hide();
			me["N12-XX"].show();
			
			if (me.typeString == "CFM") {
				me["N12-ylim"].hide();
				me["N12-box"].hide();
				me["N12-XX2"].show();
				me["N12-XX-box"].show();
			}
		}
	},
	
	updateN21: func() {
		me._cachedN2[0] = fadec.FADEC.Eng1.n2;
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
	},
	updateN22: func() {
		me._cachedN2[1] = fadec.FADEC.Eng2.n2;
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
	},
	
	updateEGT1: func() {
		me._cachedEGT[0] = fadec.FADEC.Eng1.egt;
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
	},
	updateEGT2: func() {
		me._cachedEGT[1] = fadec.FADEC.Eng2.egt;
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
	},
	
	updateEPR1: func(notification) {
		me._cachedEPR[0] = notification.eng1_epr;
		if (me._cachedEPR[0] == 1) {
			me["EPR1-scale"].setColor(0.8078,0.8039,0.8078);
			me["EPR1"].show();
			me["EPR1-decpnt"].show();
			me["EPR1-decimal"].show();
			me["EPR1-needle"].show();
			me["EPR1-ylim"].show();
			me["EPR1-scaletick"].show();
			me["EPR1-scalenum"].show();
			me["EPR1-box"].show();
			me["EPR1-XX"].hide();
			me["EPR1-XX2"].hide();
		} else {
			me["EPR1-scale"].setColor(0.7333,0.3803,0);
			me["EPR1"].hide();
			me["EPR1-decpnt"].hide();
			me["EPR1-decimal"].hide();
			me["EPR1-needle"].hide();
			me["EPR1-ylim"].hide();
			me["EPR1-scaletick"].hide();
			me["EPR1-scalenum"].hide();
			me["EPR1-box"].hide();
			me["EPR1-XX"].show();
			me["EPR1-XX2"].show();
		}
	},
	updateEPR2: func(notification) {
		me._cachedEPR[1] = notification.eng2_epr;
		if (me._cachedEPR[1] == 1) {
			me["EPR2-scale"].setColor(0.8078,0.8039,0.8078);
			me["EPR2"].show();
			me["EPR2-decpnt"].show();
			me["EPR2-decimal"].show();
			me["EPR2-needle"].show();
			me["EPR2-ylim"].show();
			me["EPR2-scaletick"].show();
			me["EPR2-scalenum"].show();
			me["EPR2-box"].show();
			me["EPR2-XX"].hide();
			me["EPR2-XX2"].hide();
		} else {
			me["EPR2-scale"].setColor(0.7333,0.3803,0);
			me["EPR2"].hide();
			me["EPR2-decpnt"].hide();
			me["EPR2-decimal"].hide();
			me["EPR2-needle"].hide();
			me["EPR2-ylim"].hide();
			me["EPR2-scaletick"].hide();
			me["EPR2-scalenum"].hide();
			me["EPR2-box"].hide();
			me["EPR2-XX"].show();
			me["EPR2-XX2"].show();
		}
	},
	updateFF1: func() {
		me._cachedFF[0] = fadec.FADEC.Eng1.ff;
		if (fadec.FADEC.Eng1.ff == 1) {
			me["FF1"].show();
			me["FF1-XX"].hide();
		} else {
			me["FF1"].hide();
			me["FF1-XX"].show();
		}
	},
	updateFF2: func() {
		me._cachedFF[1] = fadec.FADEC.Eng2.ff;
		if (fadec.FADEC.Eng2.ff == 1) {
			me["FF2"].show();
			me["FF2-XX"].hide();
		} else {
			me["FF2"].hide();
			me["FF2-XX"].show();
		}
	},
			
	updateFadecN1Power1: func(val) {
		if (me.typeString == "IAE") {
			if (val.reverser_1 < 0.01 and val.eng1_epr == 1 and val.N1_mode_1 != 1) {
				me["EPR1-thr"].show();
			} else {
				me["EPR1-thr"].hide();
			}
		} else {
			if (val.reverser_1 < 0.01 and val.eng1_n1 == 1) {
				me["N11-thr"].show();
			} else {
				me["N11-thr"].hide();
			}
		}
		
		if (val.reverser_1 >= 0.01 and val.eng1_n1 == 1) {
			me["REV1"].show();
			me["REV1-box"].show();
		} else {
			me["REV1"].hide();
			me["REV1-box"].hide();
		}
		
		if (val.reverser_1 >= 0.95) {
			me["REV1"].setColor(0.0509,0.7529,0.2941);
		} else {
			me["REV1"].setColor(0.7333,0.3803,0);
		}
	},
	updateFadecN1Power2: func(val) {
		if (me.typeString == "IAE") {
			if (val.reverser_2 < 0.01 and val.eng2_epr == 1 and val.N1_mode_2 != 1) {
				me["EPR2-thr"].show();
			} else {
				me["EPR2-thr"].hide();
			}
		} else {
			if (val.reverser_2 < 0.01 and val.eng2_n1 == 1) {
				me["N12-thr"].show();
			} else {
				me["N12-thr"].hide();
			}
		}
		
		if (val.reverser_2 >= 0.01 and val.eng2_n1 == 1) {
			me["REV2"].show();
			me["REV2-box"].show();
		} else {
			me["REV2"].hide();
			me["REV2-box"].hide();
		}
		
		if (val.reverser_2 >= 0.95) {
			me["REV2"].setColor(0.0509,0.7529,0.2941);
		} else {
			me["REV2"].setColor(0.7333,0.3803,0);
		}
	},
	
	updateTest: func(notification) {
		if (du3_test_time.getValue() + 1 >= notification.elapsedTime) {
			me["Test_white"].show();
			me["Test_text"].hide();
		} else {
			me["Test_white"].hide();
			me["Test_text"].show();
		}
	},
	powerTransient: func() {
		if (systems.ELEC.Bus.acEss.getValue() >= 110) {
			if (du3_offtime.getValue() + 3 < pts.Sim.Time.elapsedSec.getValue()) {
				if (pts.Gear.wow[0].getValue()) {
					if (!acconfig.getBoolValue() and !du3_test.getBoolValue()) {
						du3_test.setValue(1);
						du3_test_amount.setValue(math.round((rand() * 5 ) + 35, 0.1));
						du3_test_time.setValue(pts.Sim.Time.elapsedSec.getValue());
					} else if (acconfig.getBoolValue() and !du3_test.getBoolValue()) {
						du3_test.setValue(1);
						du3_test_amount.setValue(math.round((rand() * 5 ) + 35, 0.1));
						du3_test_time.setValue(pts.Sim.Time.elapsedSec.getValue() - 30);
					}
				} else {
					du3_test.setValue(1);
					du3_test_amount.setValue(0);
					du3_test_time.setValue(-100);
				}
			}
		} else {
			du3_test.setValue(0);
			du3_offtime.setValue(pts.Sim.Time.elapsedSec.getValue());
		}
	},
	updatePower: func() {
		if (du3_lgt.getValue() > 0.01 and systems.ELEC.Bus.acEss.getValue() >= 110) {
			if (du3_test_time.getValue() + du3_test_amount.getValue() >= pts.Sim.Time.elapsedSec.getValue()) {
				me.group.setVisible(0);
				me.test.setVisible(1);
			} else {
				me.group.setVisible(1);
				me.test.setVisible(0);
			}
		} else {
			me.group.setVisible(0);
			me.test.setVisible(0);
		}
	},
};

var UpperECAMRecipient =
{
	new: func(_ident)
	{
		var EWDRecipient = emesary.Recipient.new(_ident);
		EWDRecipient.MainScreen = nil;
		EWDRecipient.type = eng_option.getValue() == "IAE" ? 1 : 0;
		EWDRecipient.Receive = func(notification)
		{
			if (notification.NotificationType == "FrameNotification")
			{
				if (EWDRecipient.MainScreen == nil) {
					if (EWDRecipient.type) {
						EWDRecipient.MainScreen = canvas_upperECAM.new("Aircraft/A320-family/Models/Instruments/Upper-ECAM/res/iae-eis2.svg", "A320 E/WD IAE", "IAE");
					} else {
						EWDRecipient.MainScreen = canvas_upperECAM.new("Aircraft/A320-family/Models/Instruments/Upper-ECAM/res/cfm-eis2.svg", "A320 E/WD CFM", "CFM");
					}
				}
				if (math.mod(notifications.frameNotification.FrameCount,2) == 0) {
					if (EWDRecipient.type) {
						EWDRecipient.MainScreen.updateIAE(notification);
					} else {
						EWDRecipient.MainScreen.updateCFM(notification);
					
					}
				}
				return emesary.Transmitter.ReceiptStatus_OK;
			}
			return emesary.Transmitter.ReceiptStatus_NotProcessed;
		};
		return EWDRecipient;
	},
};

var A320EWD = UpperECAMRecipient.new("A320 E/WD");
emesary.GlobalTransmitter.Register(A320EWD);

input = {
	fuelTotalLbs: "/consumables/fuel/total-fuel-lbs",
	acconfigUnits: "/systems/acconfig/options/weight-kgs",
	slatLocked: "/fdm/jsbsim/fcs/slat-locked",
	
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
	
	# N1 parameters
	EPR_1: "/ECAM/Upper/EPR[0]",
	EPR_2: "/ECAM/Upper/EPR[1]",
	EPR_actual_1: "/engines/engine[0]/epr-actual",
	EPR_actual_2: "/engines/engine[1]/epr-actual",
	EPR_lim: "/ECAM/Upper/EPRylim",
	EPRthr_1: "/ECAM/Upper/EPRthr[0]",
	EPRthr_2: "/ECAM/Upper/EPRthr[1]",
	
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
	eprLimit: "/controls/engines/epr-limit",
	thrustLimit: "/controls/engines/thrust-limit",
	n1Limit: "/controls/engines/n1-limit",
	flexTemp: "/FMGC/internal/flex",
	fadecPower1: "/systems/fadec/powered1",
	fadecPower2: "/systems/fadec/powered2",
	fadecPowerStart: "/systems/fadec/powerup",
	N1_mode_1: "/systems/fadec/n1mode1",
	N1_mode_2: "/systems/fadec/n1mode2",
	eng1_epr: "/systems/fadec/eng1/epr",
	eng2_epr: "/systems/fadec/eng2/epr",
	eng1_n1: "/systems/fadec/eng1/n1",
	eng2_n1: "/systems/fadec/eng2/n1",
	
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

var showUpperECAM = func {
	var dlg = canvas.Window.new([512, 512], "dialog").set("resize", 1);
	dlg.setCanvas(A320EWD.MainScreen.canvas);
}

setlistener("/systems/electrical/bus/ac-ess", func() {
	if (A320EWD.MainScreen != nil) { A320EWD.MainScreen.powerTransient() }
}, 0, 0);

var slatLockTimer = maketimer(0.50, func {
	if (!slatLockFlash) {
		slatLockFlash = 1;
	} else {
		slatLockFlash = 0;
	}
});