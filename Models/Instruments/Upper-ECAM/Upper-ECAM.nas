# A3XX Upper ECAM Canvas

# Copyright (c) 2020 Josh Davidson (Octal450)

var upperECAM_cfm_eis2 = nil;
var upperECAM_iae_eis2 = nil;
var upperECAM_test = nil;
var upperECAM_display = nil;

# Conversion factor pounds to kilogram
LBS2KGS = 0.4535924;

# Create Nodes:
var EPR_1 = props.globals.initNode("/ECAM/Upper/EPR[0]", 0, "DOUBLE");
var EPR_2 = props.globals.initNode("/ECAM/Upper/EPR[1]", 0, "DOUBLE");
var EPR_thr_1 = props.globals.initNode("/ECAM/Upper/EPRthr[0]", 0);
var EPR_thr_2 = props.globals.initNode("/ECAM/Upper/EPRthr[1]", 0);
var EPR_lim = props.globals.initNode("/ECAM/Upper/EPRylim", 0, "DOUBLE");
var EGT_1 = props.globals.initNode("/ECAM/Upper/EGT[0]", 0, "DOUBLE");
var EGT_2 = props.globals.initNode("/ECAM/Upper/EGT[1]", 0, "DOUBLE");
var N1_1 = props.globals.initNode("/ECAM/Upper/N1[0]", 0, "DOUBLE");
var N1_2 = props.globals.initNode("/ECAM/Upper/N1[1]", 0, "DOUBLE");
var N1_thr_1 = props.globals.initNode("/ECAM/Upper/N1thr[0]", 0, "DOUBLE");
var N1_thr_2 = props.globals.initNode("/ECAM/Upper/N1thr[1]", 0, "DOUBLE");
var N1_lim = props.globals.initNode("/ECAM/Upper/N1ylim", 0, "DOUBLE");
var du3_test = props.globals.initNode("/instrumentation/du/du3-test", 0, "BOOL");
var du3_test_time = props.globals.initNode("/instrumentation/du/du3-test-time", 0.0, "DOUBLE");
var du3_test_amount = props.globals.initNode("/instrumentation/du/du3-test-amount", 0.0, "DOUBLE");
var du3_offtime = props.globals.initNode("/instrumentation/du/du3-off-time", 0.0, "DOUBLE");
var slatLockFlash = props.globals.initNode("/instrumentation/du/slat-lock-flash", 0, "BOOL");

# Fetch nodes:
var acconfig_weight_kgs = props.globals.getNode("/systems/acconfig/options/weight-kgs", 1);
var acconfig = props.globals.getNode("/systems/acconfig/autoconfig-running", 1);
var eng_option = props.globals.getNode("/options/eng", 1);
var du3_lgt = props.globals.getNode("/controls/lighting/DU/du3", 1);
var flaps3_ovr = props.globals.getNode("/instrumentation/mk-viii/inputs/discretes/momentary-flap-3-override", 1);
var fadecpower_1 = props.globals.getNode("/systems/fadec/powered1", 1);
var fadecpower_2 = props.globals.getNode("/systems/fadec/powered2", 1);
var fadecpowerup = props.globals.getNode("/systems/fadec/powerup", 1);
var thr_limit = props.globals.getNode("/controls/engines/thrust-limit", 1);
var n1_limit = props.globals.getNode("/controls/engines/n1-limit", 1);
var epr_limit = props.globals.getNode("/controls/engines/epr-limit", 1);
var flapXOffset = props.globals.getNode("/ECAM/Upper/FlapX", 1);
var flapYOffset = props.globals.getNode("/ECAM/Upper/FlapY", 1);
var slatXOffset = props.globals.getNode("/ECAM/Upper/SlatX", 1);
var slatYOffset = props.globals.getNode("/ECAM/Upper/SlatY", 1);
var flapXTranslate = props.globals.getNode("/ECAM/Upper/FlapXtrans", 1);
var flapYTranslate = props.globals.getNode("/ECAM/Upper/FlapYtrans", 1);
var slatXTranslate = props.globals.getNode("/ECAM/Upper/SlatXtrans", 1);
var slatYTranslate = props.globals.getNode("/ECAM/Upper/SlatYtrans", 1);
var ECAM_line1 = props.globals.getNode("/ECAM/msg/line1", 1);
var ECAM_line2 = props.globals.getNode("/ECAM/msg/line2", 1);
var ECAM_line3 = props.globals.getNode("/ECAM/msg/line3", 1);
var ECAM_line4 = props.globals.getNode("/ECAM/msg/line4", 1);
var ECAM_line5 = props.globals.getNode("/ECAM/msg/line5", 1);
var ECAM_line6 = props.globals.getNode("/ECAM/msg/line6", 1);
var ECAM_line7 = props.globals.getNode("/ECAM/msg/line7", 1);
var ECAM_line8 = props.globals.getNode("/ECAM/msg/line8", 1);
var ECAM_line1c = props.globals.getNode("/ECAM/msg/linec1", 1);
var ECAM_line2c = props.globals.getNode("/ECAM/msg/linec2", 1);
var ECAM_line3c = props.globals.getNode("/ECAM/msg/linec3", 1);
var ECAM_line4c = props.globals.getNode("/ECAM/msg/linec4", 1);
var ECAM_line5c = props.globals.getNode("/ECAM/msg/linec5", 1);
var ECAM_line6c = props.globals.getNode("/ECAM/msg/linec6", 1);
var ECAM_line7c = props.globals.getNode("/ECAM/msg/linec7", 1);
var ECAM_line8c = props.globals.getNode("/ECAM/msg/linec8", 1);
var ECAM_line1r = props.globals.getNode("/ECAM/rightmsg/line1", 1);
var ECAM_line2r = props.globals.getNode("/ECAM/rightmsg/line2", 1);
var ECAM_line3r = props.globals.getNode("/ECAM/rightmsg/line3", 1);
var ECAM_line4r = props.globals.getNode("/ECAM/rightmsg/line4", 1);
var ECAM_line5r = props.globals.getNode("/ECAM/rightmsg/line5", 1);
var ECAM_line6r = props.globals.getNode("/ECAM/rightmsg/line6", 1);
var ECAM_line7r = props.globals.getNode("/ECAM/rightmsg/line7", 1);
var ECAM_line8r = props.globals.getNode("/ECAM/rightmsg/line8", 1);
var ECAM_line1rc = props.globals.getNode("/ECAM/rightmsg/linec1", 1);
var ECAM_line2rc = props.globals.getNode("/ECAM/rightmsg/linec2", 1);
var ECAM_line3rc = props.globals.getNode("/ECAM/rightmsg/linec3", 1);
var ECAM_line4rc = props.globals.getNode("/ECAM/rightmsg/linec4", 1);
var ECAM_line5rc = props.globals.getNode("/ECAM/rightmsg/linec5", 1);
var ECAM_line6rc = props.globals.getNode("/ECAM/rightmsg/linec6", 1);
var ECAM_line7rc = props.globals.getNode("/ECAM/rightmsg/linec7", 1);
var ECAM_line8rc = props.globals.getNode("/ECAM/rightmsg/linec8", 1);
var rate = props.globals.getNode("/systems/acconfig/options/uecam-rate", 1);

# Temporary variables
var cur_eng_option = 0;
var elapsedtime = 0;
var EGT_1_cur = 0;
var EGT_2_cur = 0;
var eprLimit = 0;
var EPR_1_cur = 0;
var EPR_2_cur = 0;
var EPR_1_act = 0;
var EPR_2_act = 0;
var EPR_lim_cur = 0;
var EPR_thr_1_act = 0;
var EPR_thr_2_act = 0;
var flapsPos = 0;
var fuel1 = 0;
var fuel2 = 0;
var fadecPower1 = 0;
var fadecPower2 = 0;
var fadecPowerStart = 0;
var n1Limit = 0;
var N1_1_cur = 0;
var N1_2_cur = 0;
var N1_1_act = 0;
var N1_2_act = 0;
var N1_lim_cur = 0;
var n2cur_1 = 0;
var n2cur_2 = 0;
var rev_1_act = 0;
var rev_2_act = 0;
var rev_1_cur = 0;
var rev_2_cur = 0;
var thrLimit = 0;

var canvas_upperECAM_base = {
	init: func(canvas_group, file) {
		var font_mapper = func(family, weight) {
			return "LiberationFonts/LiberationSans-Regular.ttf";
		};

		canvas.parsesvg(canvas_group, file, {"font-mapper": font_mapper});

		var svg_keys = me.getKeys();
		foreach(var key; svg_keys) {
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
		
		# set font
		me["ECAML1"].setFont("LiberationMonoCustom.ttf");
		me["ECAML2"].setFont("LiberationMonoCustom.ttf");
		me["ECAML3"].setFont("LiberationMonoCustom.ttf");
		me["ECAML4"].setFont("LiberationMonoCustom.ttf");
		me["ECAML5"].setFont("LiberationMonoCustom.ttf");
		me["ECAML6"].setFont("LiberationMonoCustom.ttf");
		me["ECAML7"].setFont("LiberationMonoCustom.ttf");
		me["ECAML8"].setFont("LiberationMonoCustom.ttf");
		me["ECAMR1"].setFont("LiberationMonoCustom.ttf");
		me["ECAMR2"].setFont("LiberationMonoCustom.ttf");
		me["ECAMR3"].setFont("LiberationMonoCustom.ttf");
		me["ECAMR4"].setFont("LiberationMonoCustom.ttf");
		me["ECAMR5"].setFont("LiberationMonoCustom.ttf");
		me["ECAMR6"].setFont("LiberationMonoCustom.ttf");
		me["ECAMR7"].setFont("LiberationMonoCustom.ttf");
		me["ECAMR8"].setFont("LiberationMonoCustom.ttf");
	

		me.page = canvas_group;

		return me;
	},
	getKeys: func() {
		return [];
	},
	updateDu3: func() {
		elapsedtime = pts.Sim.Time.elapsedSec.getValue();
		
		if (systems.ELEC.Bus.acEss.getValue() >= 110) {
			if (du3_offtime.getValue() + 3 < elapsedtime) {
				if (pts.Gear.wow[0].getValue()) {
					if (acconfig.getValue() != 1 and du3_test.getValue() != 1) {
						du3_test.setValue(1);
						du3_test_amount.setValue(math.round((rand() * 5 ) + 35, 0.1));
						du3_test_time.setValue(elapsedtime);
					} else if (acconfig.getValue() and du3_test.getValue() != 1) {
						du3_test.setValue(1);
						du3_test_amount.setValue(math.round((rand() * 5 ) + 35, 0.1));
						du3_test_time.setValue(elapsedtime - 30);
					}
				} else {
					du3_test.setValue(1);
					du3_test_amount.setValue(0);
					du3_test_time.setValue(-100);
				}
			}
		} else {
			du3_test.setValue(0);
			du3_offtime.setValue(elapsedtime);
		}
	},
	update: func() {
		elapsedtime = pts.Sim.Time.elapsedSec.getValue();
		cur_eng_option = eng_option.getValue();
		
		if (systems.ELEC.Bus.acEss.getValue() >= 110 and du3_lgt.getValue() > 0.01) {
			if (du3_test_time.getValue() + du3_test_amount.getValue() >= elapsedtime) {
				upperECAM_cfm_eis2.page.hide();
				upperECAM_iae_eis2.page.hide();
				upperECAM_test.page.show();
				upperECAM_test.update();
			} else {
				upperECAM_test.page.hide();
				if (cur_eng_option == "CFM") {
					upperECAM_cfm_eis2.page.show();
					upperECAM_iae_eis2.page.hide();
					upperECAM_cfm_eis2.update();
				} else if (cur_eng_option == "IAE") {
					upperECAM_cfm_eis2.page.hide();
					upperECAM_iae_eis2.page.show();
					upperECAM_iae_eis2.update();
				}
			}
		} else {
			upperECAM_test.page.hide();
			upperECAM_cfm_eis2.page.hide();
			upperECAM_iae_eis2.page.hide();
		}
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
	updateBase: func() {
		# Reversers
		rev_1_cur = pts.Engines.Engine.reverser[0].getValue();
		rev_2_cur = pts.Engines.Engine.reverser[1].getValue();
		cur_eng_option = eng_option.getValue();
		if (rev_1_cur >= 0.01 and fadec.FADEC.Eng1.n1 == 1 and cur_eng_option == "CFM") {
			me["REV1"].show();
			me["REV1-box"].show();
		} else if (rev_1_cur >= 0.01 and fadec.FADEC.Eng1.epr == 1 and cur_eng_option == "IAE") {
			me["REV1"].show();
			me["REV1-box"].show();
		} else {
			me["REV1"].hide();
			me["REV1-box"].hide();
		}
		
		if (rev_1_cur >= 0.95) {
			me["REV1"].setColor(0.0509,0.7529,0.2941);
		} else {
			me["REV1"].setColor(0.7333,0.3803,0);
		}
		
		if (rev_2_cur >= 0.01 and fadec.FADEC.Eng2.n1 == 1 and cur_eng_option == "CFM") {
			me["REV2"].show();
			me["REV2-box"].show();
		} else if (rev_2_cur >= 0.01 and fadec.FADEC.Eng2.epr == 1 and cur_eng_option == "IAE") {
			me["REV2"].show();
			me["REV2-box"].show();
		} else {
			me["REV2"].hide();
			me["REV2-box"].hide();
		}
		
		if (rev_2_cur >= 0.95) {
			me["REV2"].setColor(0.0509,0.7529,0.2941);
		} else {
			me["REV2"].setColor(0.7333,0.3803,0);
		}
		
		# Flap Indicator
		flapsPos = pts.Controls.Flight.flapsPos.getValue();
		if (flapsPos == 1) {
			me["FlapTxt"].setText("1");
		} else if (flapsPos == 2) {
			me["FlapTxt"].setText("1+F");
		} else if (flapsPos == 3) {
			me["FlapTxt"].setText("2");
		} else if (flapsPos == 4) {
			me["FlapTxt"].setText("3");
		} else if (flapsPos == 5) {
			me["FlapTxt"].setText("FULL");
		} else {
			me["FlapTxt"].setText(" "); # More efficient then hide/show
		}
		
		if (flapsPos > 0) {
			me["FlapDots"].show();
		} else {
			me["FlapDots"].hide();
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
		
		me["FlapIndicator"].setTranslation(flapXOffset.getValue(),flapYOffset.getValue());
		me["SlatIndicator"].setTranslation(slatXOffset.getValue(),slatYOffset.getValue());
		me["FlapLine"].setTranslation(flapXTranslate.getValue(),flapYTranslate.getValue());
		me["SlatLine"].setTranslation(slatXTranslate.getValue(),slatYTranslate.getValue());
		
		# FOB
		if (acconfig_weight_kgs.getValue())
		{
			me["FOB-LBS"].setText(sprintf("%s", math.round(pts.Consumables.Fuel.totalFuelLbs.getValue() * LBS2KGS, 10)));
			me["FOB-weight-unit"].setText("KG");
		} else {
			me["FOB-LBS"].setText(sprintf("%s", math.round(pts.Consumables.Fuel.totalFuelLbs.getValue(), 10)));
			me["FOB-weight-unit"].setText("LBS");
		}
		
		# ECAM Messages
		
		me["ECAML1"].setText(sprintf("%s", ECAM_line1.getValue()));
		me["ECAML2"].setText(sprintf("%s", ECAM_line2.getValue()));
		me["ECAML3"].setText(sprintf("%s", ECAM_line3.getValue()));
		me["ECAML4"].setText(sprintf("%s", ECAM_line4.getValue()));
		me["ECAML5"].setText(sprintf("%s", ECAM_line5.getValue()));
		me["ECAML6"].setText(sprintf("%s", ECAM_line6.getValue()));
		me["ECAML7"].setText(sprintf("%s", ECAM_line7.getValue()));
		me["ECAML8"].setText(sprintf("%s", ECAM_line8.getValue()));
			
		me["ECAM_Left"].show();
		
		me["ECAMR1"].setText(sprintf("%s", ECAM_line1r.getValue()));
		me["ECAMR2"].setText(sprintf("%s", ECAM_line2r.getValue()));
		me["ECAMR3"].setText(sprintf("%s", ECAM_line3r.getValue()));
		me["ECAMR4"].setText(sprintf("%s", ECAM_line4r.getValue()));
		me["ECAMR5"].setText(sprintf("%s", ECAM_line5r.getValue()));
		me["ECAMR6"].setText(sprintf("%s", ECAM_line6r.getValue()));
		me["ECAMR7"].setText(sprintf("%s", ECAM_line7r.getValue()));
		me["ECAMR8"].setText(sprintf("%s", ECAM_line8r.getValue()));
			
		me["ECAM_Right"].show();
	},
};

var canvas_upperECAM_cfm_eis2 = {
	new: func(canvas_group, file) {
		var m = {parents: [canvas_upperECAM_cfm_eis2, canvas_upperECAM_base]};
		m.init(canvas_group, file);

		return m;
	},
	getKeys: func() {
		return ["N11-needle","N11-thr","N11-ylim","N11","N11-decpnt","N11-decimal","N11-box","N11-scale","N11-scale2","N11-scaletick","N11-scalenum","N11-XX","N11-XX2","N11-XX-box","EGT1-needle","EGT1","EGT1-scale","EGT1-box","EGT1-scale2","EGT1-scaletick",
		"EGT1-XX","N21","N21-decpnt","N21-decimal","N21-XX","FF1","FF1-XX","N12-needle","N12-thr","N12-ylim","N12","N12-decpnt","N12-decimal","N12-box","N12-scale","N12-scale2","N12-scaletick","N12-scalenum","N12-XX","N12-XX2","N12-XX-box","EGT2-needle","EGT2",
		"EGT2-scale","EGT2-box","EGT2-scale2","EGT2-scaletick","EGT2-XX","N22","N22-decpnt","N22-decimal","N22-XX","FF2","FF2-XX","FOB-LBS","FlapTxt","FlapDots","N1Lim-mode","N1Lim","N1Lim-decpnt","N1Lim-decimal","N1Lim-percent","N1Lim-XX","N1Lim-XX2","REV1",
		"REV1-box","REV2","REV2-box","ECAM_Left","ECAML1","ECAML2","ECAML3","ECAML4","ECAML5","ECAML6","ECAML7","ECAML8","ECAMR1", "ECAMR2", "ECAMR3", "ECAMR4", "ECAMR5", "ECAMR6", "ECAMR7", "ECAMR8", "ECAM_Right",
		"FOB-weight-unit","FFlow-weight-unit","SlatAlphaLock","SlatIndicator","FlapIndicator","SlatLine","FlapLine"];
	},
	update: func() {
		# N1
		N1_1_cur = N1_1.getValue();
		N1_2_cur = N1_2.getValue();
		N1_1_act = pts.Engines.Engine.n1Actual[0].getValue();
		N1_2_act = pts.Engines.Engine.n1Actual[1].getValue();
		N1_lim_cur = N1_lim.getValue();
		N1_thr_1_act = N1_thr_1.getValue();
		N1_thr_2_act = N1_thr_2.getValue();
		rev_1_act = pts.Engines.Engine.reverser[0].getValue();
		rev_2_act = pts.Engines.Engine.reverser[1].getValue();
		EGT_1_cur = EGT_1.getValue();
		EGT_2_cur = EGT_2.getValue();
		n2cur_1 = pts.Engines.Engine.n2Actual[0].getValue();
		n2cur_2 = pts.Engines.Engine.n2Actual[1].getValue();
		
		me["N11"].setText(sprintf("%s", math.floor(N1_1_act + 0.05)));
		me["N11-decimal"].setText(sprintf("%s", int(10 * math.mod(N1_1_act + 0.05, 1))));
		
		me["N12"].setText(sprintf("%s", math.floor(N1_2_act + 0.05)));
		me["N12-decimal"].setText(sprintf("%s", int(10 * math.mod(N1_2_act + 0.05, 1))));
		
		me["N11-needle"].setRotation((N1_1_cur + 90) * D2R);
		me["N11-thr"].setRotation((N1_thr_1_act + 90) * D2R);
		me["N11-ylim"].setRotation((N1_lim_cur + 90) * D2R);
		
		me["N12-needle"].setRotation((N1_2_cur + 90) * D2R);
		me["N12-thr"].setRotation((N1_thr_2_act + 90) * D2R);
		me["N12-ylim"].setRotation((N1_lim_cur + 90) * D2R);
		
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
		
		if (rev_1_act < 0.01 and fadec.FADEC.Eng1.n1 == 1) {
			me["N11-thr"].show();
		} else {
			me["N11-thr"].hide();
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
		
		if (rev_2_act < 0.01 and fadec.FADEC.Eng2.n1 == 1) {
			me["N12-thr"].show();
		} else {
			me["N12-thr"].hide();
		}
		
		# EGT
		me["EGT1"].setText(sprintf("%s", math.round(pts.Engines.Engine.egtActual[0].getValue())));
		me["EGT2"].setText(sprintf("%s", math.round(pts.Engines.Engine.egtActual[1].getValue())));
		
		me["EGT1-needle"].setRotation((EGT_1_cur + 90) * D2R);
		me["EGT2-needle"].setRotation((EGT_2_cur + 90) * D2R);
		
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
		
		# N2
		
		me["N21"].setText(sprintf("%s", math.floor(n2cur_1 + 0.05)));
		me["N21-decimal"].setText(sprintf("%s", int(10 * math.mod(n2cur_1 + 0.05, 1))));
		me["N22"].setText(sprintf("%s", math.floor(n2cur_2 + 0.05)));
		me["N22-decimal"].setText(sprintf("%s", int(10 * math.mod(n2cur_2 + 0.05, 1))));
		
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
		
		# FF
		fuel1 = pts.Engines.Engine.fuelFlow[0].getValue();
		fuel2 = pts.Engines.Engine.fuelFlow[1].getValue();
		
		if (acconfig_weight_kgs.getValue()) {
			me["FF1"].setText(sprintf("%s", math.round(fuel1 * LBS2KGS, 10)));
			me["FF2"].setText(sprintf("%s", math.round(fuel2 * LBS2KGS, 10)));
			me["FFlow-weight-unit"].setText("KG/H");
		} else {
			me["FF1"].setText(sprintf("%s", math.round(fuel1, 10)));
			me["FF2"].setText(sprintf("%s", math.round(fuel2, 10)));
			me["FFlow-weight-unit"].setText("LBS/H");
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
		
		# N1 Limit
		thrLimit = thr_limit.getValue();
		n1Limit = n1_limit.getValue();
		
		me["N1Lim-mode"].setText(sprintf("%s", thrLimit));
		me["N1Lim"].setText(sprintf("%s", math.floor(n1Limit + 0.05)));
		me["N1Lim-decimal"].setText(sprintf("%s", int(10 * math.mod(n1Limit + 0.05, 1))));
		
		fadecPower1 = fadecpower_1.getValue();
		fadecPower2 = fadecpower_2.getValue();
		fadecPowerStart = fadecpowerup.getValue();
		
		if (fadecPower1 or fadecPower2 or fadecPowerStart) {
			me["N1Lim-mode"].show();
			me["N1Lim-XX"].hide();
			me["N1Lim-XX2"].hide();
		} else {
			me["N1Lim-mode"].hide();
			me["N1Lim-XX"].show();
			me["N1Lim-XX2"].show();
		}
		
		if ((fadecPower1 or fadecPower2 or fadecPowerStart) and thrLimit != "MREV") {
			me["N1Lim"].show();
			me["N1Lim-decpnt"].show();
			me["N1Lim-decimal"].show();
			me["N1Lim-percent"].show();
		} else {
			me["N1Lim"].hide();
			me["N1Lim-decpnt"].hide();
			me["N1Lim-decimal"].hide();
			me["N1Lim-percent"].hide();
		}
		
		me.updateBase();
	},
};

var canvas_upperECAM_iae_eis2 = {
	new: func(canvas_group, file) {
		var m = {parents: [canvas_upperECAM_iae_eis2, canvas_upperECAM_base]};
		m.init(canvas_group, file);

		return m;
	},
	getKeys: func() {
		return ["EPR1-needle","EPR1-thr","EPR1-ylim","EPR1","EPR1-decpnt","EPR1-decimal","EPR1-box","EPR1-scale","EPR1-scaletick","EPR1-scalenum","EPR1-XX","EPR1-XX2","EGT1-needle","EGT1","EGT1-scale","EGT1-box","EGT1-scale2","EGT1-scaletick","EGT1-XX",
		"N11-needle","N11-thr","N11-ylim","N11","N11-decpnt","N11-decimal","N11-scale","N11-scale2","N11-scaletick","N11-scalenum","N11-XX","N21","N21-decpnt","N21-decimal","N21-XX","FF1","FF1-XX","EPR2-needle","EPR2-thr","EPR2-ylim","EPR2","EPR2-decpnt",
		"EPR2-decimal","EPR2-box","EPR2-scale","EPR2-scaletick","EPR2-scalenum","EPR2-XX","EPR2-XX2","EGT2-needle","EGT2","EGT2-scale","EGT2-scale2","EGT2-box","EGT2-scaletick","EGT2-XX","N12-needle","N12-thr","N12-ylim","N12","N12-decpnt","N12-decimal",
		"N12-scale","N12-scale2","N12-scaletick","N12-scalenum","N12-XX","N22","N22-decpnt","N22-decimal","N22-XX","FF2","FF2-XX","FOB-LBS","FlapTxt","FlapDots","EPRLim-mode","EPRLim","EPRLim-decpnt","EPRLim-decimal","EPRLim-XX","EPRLim-XX2","REV1","REV1-box",
		"REV2","REV2-box","ECAM_Left","ECAML1","ECAML2","ECAML3","ECAML4","ECAML5","ECAML6","ECAML7","ECAML8", "ECAMR1", "ECAMR2", "ECAMR3", "ECAMR4", "ECAMR5", "ECAMR6", "ECAMR7", "ECAMR8", "ECAM_Right",
		"FFlow1-weight-unit", "FFlow2-weight-unit", "FOB-weight-unit","SlatAlphaLock","SlatIndicator","FlapIndicator","SlatLine","FlapLine"];
	},
	update: func() {
		N1_1_cur = N1_1.getValue();
		N1_2_cur = N1_2.getValue();
		N1_1_act = pts.Engines.Engine.n1Actual[0].getValue();
		N1_2_act = pts.Engines.Engine.n1Actual[1].getValue();
		N1_lim_cur = N1_lim.getValue();
		EPR_1_cur = EPR_1.getValue();
		EPR_2_cur = EPR_2.getValue();
		EPR_1_act = pts.Engines.Engine.eprActual[0].getValue();
		EPR_2_act = pts.Engines.Engine.eprActual[1].getValue();
		EPR_lim_cur = EPR_lim.getValue();
		EPR_thr_1_act = EPR_thr_1.getValue();
		EPR_thr_2_act = EPR_thr_2.getValue();
		rev_1_act = pts.Engines.Engine.reverser[0].getValue();
		rev_2_act = pts.Engines.Engine.reverser[1].getValue();
		EGT_1_cur = EGT_1.getValue();
		EGT_2_cur = EGT_2.getValue();
		n2cur_1 = pts.Engines.Engine.n2Actual[0].getValue();
		n2cur_2 = pts.Engines.Engine.n2Actual[1].getValue();
		
		# EPR
		me["EPR1"].setText(sprintf("%1.0f", math.floor(EPR_1_act)));
		me["EPR1-decimal"].setText(sprintf("%03d", (EPR_1_act - int(EPR_1_act)) * 1000));
		me["EPR2"].setText(sprintf("%1.0f", math.floor(EPR_2_act)));
		me["EPR2-decimal"].setText(sprintf("%03d", (EPR_2_act - int(EPR_2_act)) * 1000));
		
		me["EPR1-needle"].setRotation((EPR_1_cur + 90) * D2R);
		me["EPR1-thr"].setRotation((EPR_thr_1_act + 90) * D2R);
		me["EPR1-ylim"].setRotation((EPR_lim_cur + 90) * D2R);
		me["EPR2-needle"].setRotation((EPR_2_cur + 90) * D2R);
		me["EPR2-thr"].setRotation((EPR_thr_2_act + 90) * D2R);
		me["EPR2-ylim"].setRotation((EPR_lim_cur + 90) * D2R);
		
		if (fadec.FADEC.Eng1.epr == 1) {
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
		
		if (rev_1_act < 0.01 and fadec.FADEC.Eng1.epr == 1) {
			me["EPR1-thr"].show();
		} else {
			me["EPR1-thr"].hide();
		}
		
		if (fadec.FADEC.Eng2.epr == 1) {
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
		
		if (rev_2_act < 0.01 and fadec.FADEC.Eng2.epr == 1) {
			me["EPR2-thr"].show();
		} else {
			me["EPR2-thr"].hide();
		}
		
		# EGT
		me["EGT1"].setText(sprintf("%s", math.round(pts.Engines.Engine.egtActual[0].getValue())));
		me["EGT2"].setText(sprintf("%s", math.round(pts.Engines.Engine.egtActual[1].getValue())));
		
		me["EGT1-needle"].setRotation((EGT_1_cur + 90) * D2R);
		me["EGT2-needle"].setRotation((EGT_2_cur + 90) * D2R);
		
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
		
		# N1
		me["N11"].setText(sprintf("%s", math.floor(pts.Engines.Engine.n1Actual[0].getValue() + 0.05)));
		me["N11-decimal"].setText(sprintf("%s", int(10 * math.mod(pts.Engines.Engine.n1Actual[0].getValue() + 0.05, 1))));
		
		me["N12"].setText(sprintf("%s", math.floor(pts.Engines.Engine.n1Actual[1].getValue() + 0.05)));
		me["N12-decimal"].setText(sprintf("%s", int(10 * math.mod(pts.Engines.Engine.n1Actual[1].getValue() + 0.05, 1))));
		
		me["N11-needle"].setRotation((N1_1_cur + 90) * D2R);
		me["N11-thr"].setRotation((N1_thr_1.getValue() + 90) * D2R);
		me["N11-ylim"].setRotation((N1_lim_cur + 90) * D2R);
		
		me["N12-needle"].setRotation((N1_2_cur + 90) * D2R);
		me["N12-thr"].setRotation((N1_thr_2.getValue() + 90) * D2R);
		me["N12-ylim"].setRotation((N1_lim_cur + 90) * D2R);
		
		if (fadec.FADEC.Eng1.n1 == 1) {
			me["N11-scale"].setColor(0.8078,0.8039,0.8078);
			me["N11-scale2"].setColor(1,0,0);
			me["N11"].show();
			me["N11-decimal"].show();
			me["N11-decpnt"].show();
			me["N11-needle"].show();
			me["N11-scaletick"].show();
			me["N11-scalenum"].show();
			me["N11-XX"].hide();
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
		}
		
		if (fadec.FADEC.Eng2.n1 == 1) {
			me["N12-scale"].setColor(0.8078,0.8039,0.8078);
			me["N12-scale2"].setColor(1,0,0);
			me["N12"].show();
			me["N12-decimal"].show();
			me["N12-decpnt"].show();
			me["N12-needle"].show();
			me["N12-scaletick"].show();
			me["N12-scalenum"].show();
			me["N12-XX"].hide();
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
		}
		
		if (fadec.FADEC.Eng1.n1 == 1 and fadec.Fadec.n1Mode[0].getValue()) {
			me["N11-thr"].show();
			me["N11-ylim"].hide(); # Keep it hidden, since N1 mode limit calculation is not done yet
		} else {
			me["N11-thr"].hide();
			me["N11-ylim"].hide();
		}
		
		if (fadec.FADEC.Eng2.n1 == 1 and fadec.Fadec.n1Mode[1].getValue()) {
			me["N12-thr"].show();
			me["N12-ylim"].hide(); # Keep it hidden, since N1 mode limit calculation is not done yet
		} else {
			me["N12-thr"].hide();
			me["N12-ylim"].hide();
		}
		
		# N2
		me["N21"].setText(sprintf("%s", math.floor(pts.Engines.Engine.n2Actual[0].getValue() + 0.05)));
		me["N21-decimal"].setText(sprintf("%s", int(10 * math.mod(pts.Engines.Engine.n2Actual[0].getValue() + 0.05, 1))));
		me["N22"].setText(sprintf("%s", math.floor(pts.Engines.Engine.n2Actual[1].getValue() + 0.05)));
		me["N22-decimal"].setText(sprintf("%s", int(10 * math.mod(pts.Engines.Engine.n2Actual[1].getValue() + 0.05, 1))));
		
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
		
		# FF
		fuel1 = pts.Engines.Engine.fuelFlow[0].getValue();
		fuel2 = pts.Engines.Engine.fuelFlow[1].getValue();
		if (acconfig_weight_kgs.getValue()) {
			me["FF1"].setText(sprintf("%s", math.round(fuel1 * LBS2KGS, 10)));
			me["FF2"].setText(sprintf("%s", math.round(fuel2 * LBS2KGS, 10)));
			me["FFlow1-weight-unit"].setText("KG/H");
			me["FFlow2-weight-unit"].setText("KG/H");
		} else {
			me["FF1"].setText(sprintf("%s", math.round(fuel1, 10)));
			me["FF2"].setText(sprintf("%s", math.round(fuel2, 10)));
			me["FFlow1-weight-unit"].setText("LBS/H");
			me["FFlow2-weight-unit"].setText("LBS/H");
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
		
		# EPR Limit
		thrLimit = thr_limit.getValue();
		eprLimit = epr_limit.getValue();
		
		me["EPRLim-mode"].setText(sprintf("%s", thrLimit));
		me["EPRLim"].setText(sprintf("%1.0f", math.floor(eprLimit)));
		me["EPRLim-decimal"].setText(sprintf("%03d", (eprLimit - int(eprLimit)) * 1000));
		
		fadecPower1 = fadecpower_1.getValue();
		fadecPower2 = fadecpower_2.getValue();
		fadecPowerStart = fadecpowerup.getValue();
		
		if (fadecPower1 or fadecPower2 or fadecPowerStart) {
			me["EPRLim-mode"].show();
			me["EPRLim-XX"].hide();
			me["EPRLim-XX2"].hide();
		} else {
			me["EPRLim-mode"].hide();
			me["EPRLim-XX"].show();
			me["EPRLim-XX2"].show();
		}
		
		if ((fadecPower1 or fadecPower2 or fadecPowerStart) and thrLimit != "MREV") {
			me["EPRLim"].show();
			me["EPRLim-decpnt"].show();
			me["EPRLim-decimal"].show();
		} else {
			me["EPRLim"].hide();
			me["EPRLim-decpnt"].hide();
			me["EPRLim-decimal"].hide();
		}
		
		me.updateBase();
	},
};

var canvas_upperECAM_test = {
	init: func(canvas_group, file) {
		var font_mapper = func(family, weight) {
			return "LiberationFonts/LiberationSans-Regular.ttf";
		};

		canvas.parsesvg(canvas_group, file, {"font-mapper": font_mapper});
		
		var svg_keys = me.getKeys();
		foreach(var key; svg_keys) {
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

		me.page = canvas_group;

		return me;
	},
	new: func(canvas_group, file) {
		var m = {parents: [canvas_upperECAM_test]};
		m.init(canvas_group, file);

		return m;
	},
	getKeys: func() {
		return ["Test_white","Test_text"];
	},
	update: func() {
		elapsedtime = pts.Sim.Time.elapsedSec.getValue();
		if (du3_test_time.getValue() + 1 >= elapsedtime) {
			me["Test_white"].show();
			me["Test_text"].hide();
		} else {
			me["Test_white"].hide();
			me["Test_text"].show();
		}
	},
};

var createListenerForLine = func(prop, node, key) {
	setlistener(prop, func() {
		if (eng_option.getValue() == "IAE") {
			upperECAM_iae_eis2[key].setColor(upperECAM_iae_eis2.getColorString(node.getValue()));
		} else {
			upperECAM_cfm_eis2[key].setColor(upperECAM_cfm_eis2.getColorString(node.getValue()));
		}
	}, 0, 0);
};


setlistener("sim/signals/fdm-initialized", func {
	upperECAM_display = canvas.new({
		"name": "upperECAM",
		"size": [1024, 1024],
		"view": [1024, 1024],
		"mipmapping": 1
	});
	upperECAM_display.addPlacement({"node": "uecam.screen"});
	var group_cfm_eis2 = upperECAM_display.createGroup();
	var group_iae_eis2 = upperECAM_display.createGroup();
	var group_test = upperECAM_display.createGroup();

	upperECAM_cfm_eis2 = canvas_upperECAM_cfm_eis2.new(group_cfm_eis2, "Aircraft/A320-family/Models/Instruments/Upper-ECAM/res/cfm-eis2.svg");
	upperECAM_iae_eis2 = canvas_upperECAM_iae_eis2.new(group_iae_eis2, "Aircraft/A320-family/Models/Instruments/Upper-ECAM/res/iae-eis2.svg");
	upperECAM_test = canvas_upperECAM_test.new(group_test, "Aircraft/A320-family/Models/Instruments/Common/res/du-test.svg");
	
	createListenerForLine("/ECAM/msg/linec1", ECAM_line1c, "ECAML1");
	createListenerForLine("/ECAM/msg/linec2", ECAM_line2c, "ECAML2");
	createListenerForLine("/ECAM/msg/linec3", ECAM_line3c, "ECAML3");
	createListenerForLine("/ECAM/msg/linec4", ECAM_line4c, "ECAML4");
	createListenerForLine("/ECAM/msg/linec5", ECAM_line5c, "ECAML5");
	createListenerForLine("/ECAM/msg/linec6", ECAM_line6c, "ECAML6");
	createListenerForLine("/ECAM/msg/linec7", ECAM_line7c, "ECAML7");
	createListenerForLine("/ECAM/msg/linec8", ECAM_line8c, "ECAML8");
	
	createListenerForLine("/ECAM/rightmsg/linec1", ECAM_line1rc, "ECAMR1");
	createListenerForLine("/ECAM/rightmsg/linec2", ECAM_line2rc, "ECAMR2");
	createListenerForLine("/ECAM/rightmsg/linec3", ECAM_line3rc, "ECAMR3");
	createListenerForLine("/ECAM/rightmsg/linec4", ECAM_line4rc, "ECAMR4");
	createListenerForLine("/ECAM/rightmsg/linec5", ECAM_line5rc, "ECAMR5");
	createListenerForLine("/ECAM/rightmsg/linec6", ECAM_line6rc, "ECAMR6");
	createListenerForLine("/ECAM/rightmsg/linec7", ECAM_line7rc, "ECAMR7");
	createListenerForLine("/ECAM/rightmsg/linec8", ECAM_line8rc, "ECAMR8");
	
	upperECAM_update.start();
	if (rate.getValue() > 1) {
		u_rateApply();
	}
});

var u_rateApply = func {
	upperECAM_update.restart(0.05 * rate.getValue());
}

var upperECAM_update = maketimer(0.05, func {
	canvas_upperECAM_base.update();
});

var showUpperECAM = func {
	var dlg = canvas.Window.new([512, 512], "dialog").set("resize", 1);
	dlg.setCanvas(upperECAM_display);
}

setlistener("/systems/electrical/bus/ac-ess", func() {
	canvas_upperECAM_base.updateDu3();
}, 0, 0);


var slatLockGoing = 0;
var slatLockTimer = maketimer(0.50, func {
	if (!slatLockFlash.getBoolValue()) {
		slatLockFlash.setBoolValue(1);
	} else {
		slatLockFlash.setBoolValue(0);
	}
});