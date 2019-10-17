# A3XX Upper ECAM Canvas

# Copyright (c) 2019 Joshua Davidson (Octal450)

var upperECAM_cfm_eis2 = nil;
var upperECAM_iae_eis2 = nil;
var upperECAM_test = nil;
var upperECAM_display = nil;
var elapsedtime = 0;
var leftmsg = "XX";
var rightmsg = "XX";

# Create Nodes:
var fuel_1 = props.globals.initNode("/engines/engine[0]/fuel-flow_actual", 0);
var fuel_2 = props.globals.initNode("/engines/engine[1]/fuel-flow_actual", 0);
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
var du3_off_time = props.globals.initNode("/instrumentation/du/du3-off-time", 0.0, "DOUBLE");
var du3_off_time_2 = props.globals.initNode("/instrumentation/du/du3-off-time-2", 0.0, "DOUBLE");
var du3_test_amount = props.globals.initNode("/instrumentation/du/du3-test-amount", 0.0, "DOUBLE");

# Fetch nodes:
var et = props.globals.getNode("/sim/time/elapsed-sec", 1);
var acconfig = props.globals.getNode("/systems/acconfig/autoconfig-running", 1);
var acess = props.globals.getNode("/systems/electrical/bus/ac-ess", 1);
var eng_option = props.globals.getNode("/options/eng", 1);
var du3_lgt = props.globals.getNode("/controls/lighting/DU/du3", 1);
var rev_1 = props.globals.getNode("/engines/engine[0]/reverser-pos-norm", 1);
var rev_2 = props.globals.getNode("/engines/engine[1]/reverser-pos-norm", 1);
var eng1_n1mode = props.globals.getNode("/systems/fadec/eng1/n1", 1);
var eng1_eprmode = props.globals.getNode("/systems/fadec/eng1/epr", 1);
var eng2_n1mode = props.globals.getNode("/systems/fadec/eng2/n1", 1);
var eng2_eprmode = props.globals.getNode("/systems/fadec/eng2/epr", 1);
var eng1_n2mode = props.globals.getNode("/systems/fadec/eng1/n2", 1);
var eng2_n2mode = props.globals.getNode("/systems/fadec/eng2/n2", 1);
var flap_text = props.globals.getNode("/controls/flight/flap-txt", 1);
var flap_pos = props.globals.getNode("/controls/flight/flap-pos", 1);
var fuel = props.globals.getNode("/consumables/fuel/total-fuel-lbs", 1);
var modeautobrake = props.globals.getNode("/controls/autobrake/mode", 1);
var speedbrakearm = props.globals.getNode("/controls/flight/speedbrake-arm", 1);
var ECAMtoconfig = props.globals.getNode("/ECAM/to-config", 1);
var gear = props.globals.getNode("/gear/gear[1]/position-norm", 1);
var smoke = props.globals.getNode("/controls/lighting/no-smoking-sign", 1);
var seatbelt = props.globals.getNode("/controls/lighting/seatbelt-sign", 1);
var flaps3_ovr = props.globals.getNode("/instrumentation/mk-viii/inputs/discretes/momentary-flap-3-override", 1);
var wow0 = props.globals.getNode("/gear/gear[0]/wow");
var eng1_n1 = props.globals.getNode("/engines/engine[0]/n1-actual", 1);
var eng2_n1 = props.globals.getNode("/engines/engine[1]/n1-actual", 1);
var eng1_n2 = props.globals.getNode("/engines/engine[0]/n2-actual", 1);
var eng2_n2 = props.globals.getNode("/engines/engine[1]/n2-actual", 1);
var eng1_epr = props.globals.getNode("/engines/engine[0]/epr-actual", 1);
var eng2_epr = props.globals.getNode("/engines/engine[1]/epr-actual", 1);
var eng1_egt = props.globals.getNode("/engines/engine[0]/egt-actual", 1);
var eng2_egt = props.globals.getNode("/engines/engine[1]/egt-actual", 1);
var eng1_egtmode = props.globals.getNode("/systems/fadec/eng1/egt", 1);
var eng2_egtmode = props.globals.getNode("/systems/fadec/eng2/egt", 1);
var eng1_ffmode = props.globals.getNode("/systems/fadec/eng1/ff", 1);
var eng2_ffmode = props.globals.getNode("/systems/fadec/eng2/ff", 1);
var fadecpower_1 = props.globals.getNode("/systems/fadec/powered1", 1);
var fadecpower_2 = props.globals.getNode("/systems/fadec/powered2", 1);
var fadecpowerup = props.globals.getNode("/systems/fadec/powerup", 1);
var thr_limit = props.globals.getNode("/controls/engines/thrust-limit", 1);
var n1_limit = props.globals.getNode("/controls/engines/n1-limit", 1);
var epr_limit = props.globals.getNode("/controls/engines/epr-limit", 1);
var n1mode1 = props.globals.getNode("/systems/fadec/n1mode1", 1);
var n1mode2 = props.globals.getNode("/systems/fadec/n1mode2", 1);
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
var ECAMleft = props.globals.getNode("/ECAM/left-msg", 1);
var ECAMright = props.globals.getNode("/ECAM/right-msg", 1);
var rate = props.globals.getNode("/systems/acconfig/options/uecam-rate", 1);

var canvas_upperECAM_base = {
	init: func(canvas_group, file) {
		var font_mapper = func(family, weight) {
			return "LiberationFonts/LiberationSans-Regular.ttf";
		};

		canvas.parsesvg(canvas_group, file, {"font-mapper": font_mapper});

		var svg_keys = me.getKeys();
		foreach(var key; svg_keys) {
			me[key] = canvas_group.getElementById(key);
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
	update: func() {
		elapsedtime = et.getValue();
		
		if (acess.getValue() >= 110) {
			if (du3_off_time.getValue() != 0) {
				du3_off_time_2.setValue(elapsedtime - du3_off_time.getValue());
				du3_off_time.setValue(0);
			}
			if (wow0.getValue() == 1) {
				if (acconfig.getValue() != 1 and du3_test.getValue() != 1) {
					du3_test.setValue(1);
					du3_test_amount.setValue(math.round((rand() * 5 ) + 35, 0.1));
					du3_test_time.setValue(elapsedtime);
				} else if (acconfig.getValue() == 1 and du3_test.getValue() != 1) {
					du3_test.setValue(1);
					du3_test_amount.setValue(math.round((rand() * 5 ) + 35, 0.1));
					du3_test_time.setValue(elapsedtime - 30);
				}
			} else {
				du3_test.setValue(1);
				du3_test_amount.setValue(0);
				du3_test_time.setValue(-100);
			}
		} elsif (du3_test.getValue() != 0) {
			du3_test.setValue(0);
			du3_off_time.setValue(elapsedtime);
			du3_off_time_2.setValue(0);
		}
		
		cur_eng_option = eng_option.getValue();
		if (acess.getValue() >= 110 and du3_lgt.getValue() > 0.01) {
			if (du3_test_time.getValue() + du3_test_amount.getValue() >= elapsedtime and du3_off_time_2.getValue() > 0.5) {
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
	updateBase: func() {
		# Reversers
		rev_1_cur = rev_1.getValue();
		rev_2_cur = rev_2.getValue();
		cur_eng_option = eng_option.getValue();
		if (rev_1_cur >= 0.01 and eng1_n1mode.getValue() == 1 and cur_eng_option == "CFM") {
			me["REV1"].show();
			me["REV1-box"].show();
		} else if (rev_1_cur >= 0.01 and eng1_eprmode.getValue() == 1 and cur_eng_option == "IAE") {
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
		
		if (rev_2_cur >= 0.01 and eng2_n1mode.getValue() == 1 and cur_eng_option == "CFM") {
			me["REV2"].show();
			me["REV2-box"].show();
		} else if (rev_2_cur >= 0.01 and eng2_eprmode.getValue() == 1 and cur_eng_option == "IAE") {
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
		me["FlapTxt"].setText(sprintf("%s", flap_text.getValue()));
		
		if (flap_pos.getValue() > 0) {
			me["FlapDots"].show();
		} else {
			me["FlapDots"].hide();
		}
		
		# FOB
		me["FOB-LBS"].setText(sprintf("%s", math.round(fuel.getValue(), 10)));
		
		# Left ECAM Messages
		line1c = ECAM_line1c.getValue();
		line2c = ECAM_line2c.getValue();
		line3c = ECAM_line3c.getValue();
		line4c = ECAM_line4c.getValue();
		line5c = ECAM_line5c.getValue();
		line6c = ECAM_line6c.getValue();
		line7c = ECAM_line7c.getValue();
		line8c = ECAM_line8c.getValue();
		leftmsg = ECAMleft.getValue();
		rightmsg = ECAMright.getValue();
		
		if (leftmsg == "MSG") {
			me["ECAML1"].setText(sprintf("%s", ECAM_line1.getValue()));
			me["ECAML2"].setText(sprintf("%s", ECAM_line2.getValue()));
			me["ECAML3"].setText(sprintf("%s", ECAM_line3.getValue()));
			me["ECAML4"].setText(sprintf("%s", ECAM_line4.getValue()));
			me["ECAML5"].setText(sprintf("%s", ECAM_line5.getValue()));
			me["ECAML6"].setText(sprintf("%s", ECAM_line6.getValue()));
			me["ECAML7"].setText(sprintf("%s", ECAM_line7.getValue()));
			me["ECAML8"].setText(sprintf("%s", ECAM_line8.getValue()));
			
			if (line1c == "w") {
				me["ECAML1"].setColor(0.8078,0.8039,0.8078);
			} else if (line1c == "c") {
				me["ECAML1"].setColor(0.0901,0.6039,0.7176);
			} else if (line1c == "g") {
				me["ECAML1"].setColor(0.0509,0.7529,0.2941);
			} else if (line1c == "a") {
				me["ECAML1"].setColor(0.7333,0.3803,0);
			} else if (line1c == "r") {
				me["ECAML1"].setColor(1,0,0);
			}
			
			if (line2c == "w") {
				me["ECAML2"].setColor(0.8078,0.8039,0.8078);
			} else if (line2c == "c") {
				me["ECAML2"].setColor(0.0901,0.6039,0.7176);
			} else if (line2c == "g") {
				me["ECAML2"].setColor(0.0509,0.7529,0.2941);
			} else if (line2c == "a") {
				me["ECAML2"].setColor(0.7333,0.3803,0);
			} else if (line2c == "r") {
				me["ECAML2"].setColor(1,0,0);
			}
			
			if (line3c == "w") {
				me["ECAML3"].setColor(0.8078,0.8039,0.8078);
			} else if (line3c == "c") {
				me["ECAML3"].setColor(0.0901,0.6039,0.7176);
			} else if (line3c == "g") {
				me["ECAML3"].setColor(0.0509,0.7529,0.2941);
			} else if (line3c == "a") {
				me["ECAML3"].setColor(0.7333,0.3803,0);
			} else if (line3c == "r") {
				me["ECAML3"].setColor(1,0,0);
			}
			
			if (line4c == "w") {
				me["ECAML4"].setColor(0.8078,0.8039,0.8078);
			} else if (line4c == "c") {
				me["ECAML4"].setColor(0.0901,0.6039,0.7176);
			} else if (line4c == "g") {
				me["ECAML4"].setColor(0.0509,0.7529,0.2941);
			} else if (line4c == "a") {
				me["ECAML4"].setColor(0.7333,0.3803,0);
			} else if (line4c == "r") {
				me["ECAML4"].setColor(1,0,0);
			}
			
			if (line5c == "w") {
				me["ECAML5"].setColor(0.8078,0.8039,0.8078);
			} else if (line5c == "c") {
				me["ECAML5"].setColor(0.0901,0.6039,0.7176);
			} else if (line5c == "g") {
				me["ECAML5"].setColor(0.0509,0.7529,0.2941);
			} else if (line5c == "a") {
				me["ECAML5"].setColor(0.7333,0.3803,0);
			} else if (line5c == "r") {
				me["ECAML5"].setColor(1,0,0);
			}
			
			if (line6c == "w") {
				me["ECAML6"].setColor(0.8078,0.8039,0.8078);
			} else if (line6c == "c") {
				me["ECAML6"].setColor(0.0901,0.6039,0.7176);
			} else if (line6c == "g") {
				me["ECAML6"].setColor(0.0509,0.7529,0.2941);
			} else if (line6c == "a") {
				me["ECAML6"].setColor(0.7333,0.3803,0);
			} else if (line6c == "r") {
				me["ECAML6"].setColor(1,0,0);
			}
			
			if (line7c == "w") {
				me["ECAML7"].setColor(0.8078,0.8039,0.8078);
			} else if (line7c == "c") {
				me["ECAML7"].setColor(0.0901,0.6039,0.7176);
			} else if (line7c == "g") {
				me["ECAML7"].setColor(0.0509,0.7529,0.2941);
			} else if (line7c == "a") {
				me["ECAML7"].setColor(0.7333,0.3803,0);
			} else if (line7c == "r") {
				me["ECAML7"].setColor(1,0,0);
			}
			
			if (line8c == "w") {
				me["ECAML8"].setColor(0.8078,0.8039,0.8078);
			} else if (line8c == "c") {
				me["ECAML8"].setColor(0.0901,0.6039,0.7176);
			} else if (line8c == "g") {
				me["ECAML8"].setColor(0.0509,0.7529,0.2941);
			} else if (line8c == "a") {
				me["ECAML8"].setColor(0.7333,0.3803,0);
			} else if (line8c == "r") {
				me["ECAML8"].setColor(1,0,0);
			}
			
			me["TO_Memo"].hide();
			me["LDG_Memo"].hide();
			me["ECAM_Left"].show();
		} else if (leftmsg == "TO-MEMO") {
			modebrk = modeautobrake.getValue();
			if (modebrk == 3) {
				me["TO_Autobrake"].setText("AUTO BRK MAX");
				me["TO_Autobrake_B"].hide();
			} else {
				me["TO_Autobrake"].setText("AUTO BRK");
				me["TO_Autobrake_B"].show();
			}
			
			if (smoke.getValue() == 1 and seatbelt.getValue() == 1) {
				me["TO_Signs"].setText("SIGNS ON");
				me["TO_Signs_B"].hide();
			} else {
				me["TO_Signs"].setText("SIGNS");
				me["TO_Signs_B"].show();
			}
			
			if (speedbrakearm.getValue() == 1) {
				me["TO_Spoilers"].setText("SPLRS ARM");
				me["TO_Spoilers_B"].hide();
			} else {
				me["TO_Spoilers"].setText("SPLRS");
				me["TO_Spoilers_B"].show();
			}
			
			if (flap_pos.getValue() > 0 and flap_pos.getValue() < 5) {
				me["TO_Flaps"].setText("FLAPS T.O");
				me["TO_Flaps_B"].hide();
			} else {
				me["TO_Flaps"].setText("FLAPS");
				me["TO_Flaps_B"].show();
			}
			
			if (ECAMtoconfig.getValue() == 1) {
				me["TO_Config"].setText("T.O CONFIG NORMAL");
				me["TO_Config_B"].hide();
			} else {
				me["TO_Config"].setText("T.O CONFIG");
				me["TO_Config_B"].show();
			}
			
			me["ECAM_Left"].hide();
			me["LDG_Memo"].hide();
			me["TO_Memo"].show();
		} else if (leftmsg == "LDG-MEMO") {
			if (gear.getValue() == 1) {
				me["LDG_Gear"].setText("LDG GEAR DN");
				me["LDG_Gear_B"].hide();
			} else {
				me["LDG_Gear"].setText("LDG GEAR");
				me["LDG_Gear_B"].show();
			}
			
			if (smoke.getValue() == 1 and seatbelt.getValue() == 1) {
				me["LDG_Signs"].setText("SIGNS ON");
				me["LDG_Signs_B"].hide();
			} else {
				me["LDG_Signs"].setText("SIGNS");
				me["LDG_Signs_B"].show();
			}
			
			if (speedbrakearm.getValue() == 1) {
				me["LDG_Spoilers"].setText("SPLRS ARM");
				me["LDG_Spoilers_B"].hide();
			} else {
				me["LDG_Spoilers"].setText("SPLRS");
				me["LDG_Spoilers_B"].show();
			}
			
			flaps3 = flaps3_ovr.getValue();
			flaps_position = flap_pos.getValue();
			if (flaps3 != 1 and flaps_position == 5) {
				me["LDG_Flaps"].setText("FLAPS FULL");
				me["LDG_Flaps_B"].hide();
				me["LDG_Flaps_B3"].hide();
			} else if (flaps3 == 1 and flaps_position >= 4) {
				me["LDG_Flaps"].setText("FLAPS 3");
				me["LDG_Flaps_B"].hide();
				me["LDG_Flaps_B3"].hide();
			} else {
				me["LDG_Flaps"].setText("FLAPS");
				if (flaps3 == 1) {
					me["LDG_Flaps_B"].hide();
					me["LDG_Flaps_B3"].show();
				} else {
					me["LDG_Flaps_B3"].hide();
					me["LDG_Flaps_B"].show();
				}
			}
			
			me["ECAM_Left"].hide();
			me["TO_Memo"].hide();
			me["LDG_Memo"].show();
		} else {
			me["ECAM_Left"].hide();
			me["TO_Memo"].hide();
			me["LDG_Memo"].hide();
		}
		
		# Right ECAM Messages
		if (rightmsg == "MSG") {
			me["ECAMR1"].setText(sprintf("%s", getprop("/ECAM/rightmsg/line1")));
			me["ECAMR2"].setText(sprintf("%s", getprop("/ECAM/rightmsg/line2")));
			me["ECAMR3"].setText(sprintf("%s", getprop("/ECAM/rightmsg/line3")));
			me["ECAMR4"].setText(sprintf("%s", getprop("/ECAM/rightmsg/line4")));
			me["ECAMR5"].setText(sprintf("%s", getprop("/ECAM/rightmsg/line5")));
			me["ECAMR6"].setText(sprintf("%s", getprop("/ECAM/rightmsg/line6")));
			me["ECAMR7"].setText(sprintf("%s", getprop("/ECAM/rightmsg/line7")));
			me["ECAMR8"].setText(sprintf("%s", getprop("/ECAM/rightmsg/line8")));
			
			if (getprop("/ECAM/rightmsg/linec1") == "w") {
				me["ECAMR1"].setColor(0.8078,0.8039,0.8078);
			} else if (getprop("/ECAM/rightmsg/linec1") == "c") {
				me["ECAMR1"].setColor(0.0901,0.6039,0.7176);
			} else if (getprop("/ECAM/rightmsg/linec1") == "g") {
				me["ECAMR1"].setColor(0.0509,0.7529,0.2941);
			} else if (getprop("/ECAM/rightmsg/linec1") == "a") {
				me["ECAMR1"].setColor(0.7333,0.3803,0);
			} else if (getprop("/ECAM/rightmsg/linec1") == "r") {
				me["ECAMR1"].setColor(1,0,0);
			} else if (getprop("/ECAM/rightmsg/linec1") == "m") {
				me["ECAMR1"].setColor(0.6901,0.3333,0.7450);
			}
			
			if (getprop("/ECAM/rightmsg/linec2") == "w") {
				me["ECAMR2"].setColor(0.8078,0.8039,0.8078);
			} else if (getprop("/ECAM/rightmsg/linec2") == "c") {
				me["ECAMR2"].setColor(0.0901,0.6039,0.7176);
			} else if (getprop("/ECAM/rightmsg/linec2") == "g") {
				me["ECAMR2"].setColor(0.0509,0.7529,0.2941);
			} else if (getprop("/ECAM/rightmsg/linec2") == "a") {
				me["ECAMR2"].setColor(0.7333,0.3803,0);
			} else if (getprop("/ECAM/rightmsg/linec2") == "r") {
				me["ECAMR2"].setColor(1,0,0);
			} else if (getprop("/ECAM/rightmsg/linec2") == "m") {
				me["ECAMR2"].setColor(0.6901,0.3333,0.7450);
			}
			
			if (getprop("/ECAM/rightmsg/linec3") == "w") {
				me["ECAMR3"].setColor(0.8078,0.8039,0.8078);
			} else if (getprop("/ECAM/rightmsg/linec3") == "c") {
				me["ECAMR3"].setColor(0.0901,0.6039,0.7176);
			} else if (getprop("/ECAM/rightmsg/linec3") == "g") {
				me["ECAMR3"].setColor(0.0509,0.7529,0.2941);
			} else if (getprop("/ECAM/rightmsg/linec3") == "a") {
				me["ECAMR3"].setColor(0.7333,0.3803,0);
			} else if (getprop("/ECAM/rightmsg/linec3") == "r") {
				me["ECAMR3"].setColor(1,0,0);
			} else if (getprop("/ECAM/rightmsg/linec3") == "m") {
				me["ECAMR3"].setColor(0.6901,0.3333,0.7450);
			}
			
			if (getprop("/ECAM/rightmsg/linec4") == "w") {
				me["ECAMR4"].setColor(0.8078,0.8039,0.8078);
			} else if (getprop("/ECAM/rightmsg/linec4") == "c") {
				me["ECAMR4"].setColor(0.0901,0.6039,0.7176);
			} else if (getprop("/ECAM/rightmsg/linec4") == "g") {
				me["ECAMR4"].setColor(0.0509,0.7529,0.2941);
			} else if (getprop("/ECAM/rightmsg/linec4") == "a") {
				me["ECAMR4"].setColor(0.7333,0.3803,0);
			} else if (getprop("/ECAM/rightmsg/linec4") == "r") {
				me["ECAMR4"].setColor(1,0,0);
			} else if (getprop("/ECAM/rightmsg/linec4") == "m") {
				me["ECAMR4"].setColor(0.6901,0.3333,0.7450);
			}
			
			if (getprop("/ECAM/rightmsg/linec5") == "w") {
				me["ECAMR5"].setColor(0.8078,0.8039,0.8078);
			} else if (getprop("/ECAM/rightmsg/linec5") == "c") {
				me["ECAMR5"].setColor(0.0901,0.6039,0.7176);
			} else if (getprop("/ECAM/rightmsg/linec5") == "g") {
				me["ECAMR5"].setColor(0.0509,0.7529,0.2941);
			} else if (getprop("/ECAM/rightmsg/linec5") == "a") {
				me["ECAMR5"].setColor(0.7333,0.3803,0);
			} else if (getprop("/ECAM/rightmsg/linec5") == "r") {
				me["ECAMR5"].setColor(1,0,0);
			} else if (getprop("/ECAM/rightmsg/linec5") == "m") {
				me["ECAMR5"].setColor(0.6901,0.3333,0.7450);
			}
			
			if (getprop("/ECAM/rightmsg/linec6") == "w") {
				me["ECAMR6"].setColor(0.8078,0.8039,0.8078);
			} else if (getprop("/ECAM/rightmsg/linec6") == "c") {
				me["ECAMR6"].setColor(0.0901,0.6039,0.7176);
			} else if (getprop("/ECAM/rightmsg/linec6") == "g") {
				me["ECAMR6"].setColor(0.0509,0.7529,0.2941);
			} else if (getprop("/ECAM/rightmsg/linec6") == "a") {
				me["ECAMR6"].setColor(0.7333,0.3803,0);
			} else if (getprop("/ECAM/rightmsg/linec6") == "r") {
				me["ECAMR6"].setColor(1,0,0);
			} else if (getprop("/ECAM/rightmsg/linec6") == "m") {
				me["ECAMR6"].setColor(0.6901,0.3333,0.7450);
			}
			
			if (getprop("/ECAM/rightmsg/linec7") == "w") {
				me["ECAMR7"].setColor(0.8078,0.8039,0.8078);
			} else if (getprop("/ECAM/rightmsg/linec7") == "c") {
				me["ECAMR7"].setColor(0.0901,0.6039,0.7176);
			} else if (getprop("/ECAM/rightmsg/linec7") == "g") {
				me["ECAMR7"].setColor(0.0509,0.7529,0.2941);
			} else if (getprop("/ECAM/rightmsg/linec7") == "a") {
				me["ECAMR7"].setColor(0.7333,0.3803,0);
			} else if (getprop("/ECAM/rightmsg/linec7") == "r") {
				me["ECAMR7"].setColor(1,0,0);
			} else if (getprop("/ECAM/rightmsg/linec7") == "m") {
				me["ECAMR7"].setColor(0.6901,0.3333,0.7450);
			}
			
			if (getprop("/ECAM/rightmsg/linec8") == "w") {
				me["ECAMR8"].setColor(0.8078,0.8039,0.8078);
			} else if (getprop("/ECAM/rightmsg/linec8") == "c") {
				me["ECAMR8"].setColor(0.0901,0.6039,0.7176);
			} else if (getprop("/ECAM/rightmsg/linec8") == "g") {
				me["ECAMR8"].setColor(0.0509,0.7529,0.2941);
			} else if (getprop("/ECAM/rightmsg/linec8") == "a") {
				me["ECAMR8"].setColor(0.7333,0.3803,0);
			} else if (getprop("/ECAM/rightmsg/linec8") == "r") {
				me["ECAMR8"].setColor(1,0,0);
			} else if (getprop("/ECAM/rightmsg/linec8") == "m") {
				me["ECAMR8"].setColor(0.6901,0.3333,0.7450);
			}
			
			me["ECAM_Right"].show();
		} else {
			me["ECAM_Right"].hide();
		}
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
		"REV1-box","REV2","REV2-box","ECAM_Left","ECAML1","ECAML2","ECAML3","ECAML4","ECAML5","ECAML6","ECAML7","ECAML8","ECAMR1", "ECAMR2", "ECAMR3", "ECAMR4", "ECAMR5", "ECAMR6", "ECAMR7", "ECAMR8", "ECAM_Right", "TO_Memo","TO_Autobrake","TO_Signs","TO_Spoilers","TO_Flaps","TO_Config","TO_Autobrake_B","TO_Signs_B","TO_Spoilers_B","TO_Flaps_B",
		"TO_Config_B","LDG_Memo","LDG_Gear","LDG_Signs","LDG_Spoilers","LDG_Flaps","LDG_Gear_B","LDG_Signs_B","LDG_Spoilers_B","LDG_Flaps_B","LDG_Flaps_B3"];
	},
	update: func() {
		# N1
		N1_1_cur = N1_1.getValue();
		N1_2_cur = N1_2.getValue();
		N1_1_act = eng1_n1.getValue();
		N1_2_act = eng2_n1.getValue();
		N1_lim_cur = N1_lim.getValue();
		N1_thr_1_act = N1_thr_1.getValue();
		N1_thr_2_act = N1_thr_2.getValue();
		n1mode_1 = eng1_n1mode.getValue();
		n1mode_2 = eng2_n1mode.getValue();
		rev_1_act = rev_1.getValue();
		rev_2_act = rev_2.getValue();
		ff_1 = eng1_ffmode.getValue();
		ff_2 = eng2_ffmode.getValue();
		EGT_1_cur = EGT_1.getValue();
		EGT_2_cur = EGT_2.getValue();
		n2cur_1 = eng1_n2.getValue();
		n2cur_2 = eng2_n2.getValue();
		
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
		
		if (n1mode_1 == 1) {
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
		
		if (rev_1_act < 0.01 and n1mode_1 == 1) {
			me["N11-thr"].show();
		} else {
			me["N11-thr"].hide();
		}
		
		if (n1mode_2 == 1) {
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
		
		if (rev_2_act < 0.01 and n1mode_2 == 1) {
			me["N12-thr"].show();
		} else {
			me["N12-thr"].hide();
		}
		
		# EGT
		me["EGT1"].setText(sprintf("%s", math.round(eng1_egt.getValue())));
		me["EGT2"].setText(sprintf("%s", math.round(eng2_egt.getValue())));
		
		me["EGT1-needle"].setRotation((EGT_1_cur + 90) * D2R);
		me["EGT2-needle"].setRotation((EGT_2_cur + 90) * D2R);
		
		if (eng1_egtmode.getValue() == 1) {
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
		
		if (eng2_egtmode.getValue() == 1) {
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
		
		if (eng1_n2mode.getValue() == 1) {
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
		
		if (eng2_n2mode.getValue() == 1) {
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
		me["FF1"].setText(sprintf("%s", math.round(fuel_1.getValue(), 10)));
		me["FF2"].setText(sprintf("%s", math.round(fuel_2.getValue(), 10)));
		
		if (ff_1 == 1) {
			me["FF1"].show();
			me["FF1-XX"].hide();
		} else {
			me["FF1"].hide();
			me["FF1-XX"].show();
		}
		
		if (ff_2 == 1) {
			me["FF2"].show();
			me["FF2-XX"].hide();
		} else {
			me["FF2"].hide();
			me["FF2-XX"].show();
		}
		
		# N1 Limit
		me["N1Lim-mode"].setText(sprintf("%s", thr_limit.getValue()));
		me["N1Lim"].setText(sprintf("%s", math.floor(n1_limit.getValue() + 0.05)));
		me["N1Lim-decimal"].setText(sprintf("%s", int(10 * math.mod(n1_limit.getValue() + 0.05, 1))));
		
		if (fadecpower_1.getValue() == 1 or fadecpower_2.getValue() == 1 or fadecpowerup.getValue()) {
			me["N1Lim-mode"].show();
			me["N1Lim-XX"].hide();
			me["N1Lim-XX2"].hide();
		} else {
			me["N1Lim-mode"].hide();
			me["N1Lim-XX"].show();
			me["N1Lim-XX2"].show();
		}
		
		if ((fadecpower_1.getValue() == 1 or fadecpower_2.getValue() == 1 or fadecpowerup.getValue()) and thr_limit.getValue() != "MREV") {
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
		"REV2","REV2-box","ECAM_Left","ECAML1","ECAML2","ECAML3","ECAML4","ECAML5","ECAML6","ECAML7","ECAML8", "ECAMR1", "ECAMR2", "ECAMR3", "ECAMR4", "ECAMR5", "ECAMR6", "ECAMR7", "ECAMR8", "ECAM_Right", "TO_Memo","TO_Autobrake","TO_Signs","TO_Spoilers","TO_Flaps","TO_Config","TO_Autobrake_B","TO_Signs_B","TO_Spoilers_B","TO_Flaps_B","TO_Config_B",
		"LDG_Memo","LDG_Gear","LDG_Signs","LDG_Spoilers","LDG_Flaps","LDG_Gear_B","LDG_Signs_B","LDG_Spoilers_B","LDG_Flaps_B","LDG_Flaps_B3"];
	},
	update: func() {
		N1_1_cur = N1_1.getValue();
		N1_2_cur = N1_2.getValue();
		N1_1_act = eng1_n1.getValue();
		N1_2_act = eng2_n1.getValue();
		N1_lim_cur = N1_lim.getValue();
		EPR_1_cur = EPR_1.getValue();
		EPR_2_cur = EPR_2.getValue();
		EPR_1_act = eng1_epr.getValue();
		EPR_2_act = eng2_epr.getValue();
		EPR_lim_cur = EPR_lim.getValue();
		EPR_thr_1_act = EPR_thr_1.getValue();
		EPR_thr_2_act = EPR_thr_2.getValue();
		eprmode1 = eng1_eprmode.getValue();
		eprmode2 = eng2_eprmode.getValue();
		rev_1_act = rev_1.getValue();
		rev_2_act = rev_2.getValue();
		ff_1 = eng1_ffmode.getValue();
		ff_2 = eng2_ffmode.getValue();
		EGT_1_cur = EGT_1.getValue();
		EGT_2_cur = EGT_2.getValue();
		n2cur_1 = eng1_n2.getValue();
		n2cur_2 = eng2_n2.getValue();
		
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
		
		if (eprmode1 == 1) {
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
		
		if (rev_1_act < 0.01 and eprmode1 == 1) {
			me["EPR1-thr"].show();
		} else {
			me["EPR1-thr"].hide();
		}
		
		if (eprmode2 == 1) {
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
		
		if (rev_2_act < 0.01 and eprmode2 == 1) {
			me["EPR2-thr"].show();
		} else {
			me["EPR2-thr"].hide();
		}
		
		# EGT
		me["EGT1"].setText(sprintf("%s", math.round(eng1_egt.getValue())));
		me["EGT2"].setText(sprintf("%s", math.round(eng2_egt.getValue())));
		
		me["EGT1-needle"].setRotation((EGT_1_cur + 90) * D2R);
		me["EGT2-needle"].setRotation((EGT_2_cur + 90) * D2R);
		
		if (eng1_egtmode.getValue() == 1) {
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
		
		if (eng2_egtmode.getValue() == 1) {
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
		me["N11"].setText(sprintf("%s", math.floor(eng1_n1.getValue() + 0.05)));
		me["N11-decimal"].setText(sprintf("%s", int(10 * math.mod(eng1_n1.getValue() + 0.05, 1))));
		
		me["N12"].setText(sprintf("%s", math.floor(eng2_n1.getValue() + 0.05)));
		me["N12-decimal"].setText(sprintf("%s", int(10 * math.mod(eng2_n1.getValue() + 0.05, 1))));
		
		me["N11-needle"].setRotation((N1_1_cur + 90) * D2R);
		me["N11-thr"].setRotation((N1_thr_1.getValue() + 90) * D2R);
		me["N11-ylim"].setRotation((N1_lim_cur + 90) * D2R);
		
		me["N12-needle"].setRotation((N1_2_cur + 90) * D2R);
		me["N12-thr"].setRotation((N1_thr_2.getValue() + 90) * D2R);
		me["N12-ylim"].setRotation((N1_lim_cur + 90) * D2R);
		
		if (eng1_n1mode.getValue() == 1) {
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
		
		if (eng2_n1mode.getValue() == 1) {
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
		
		if (eng1_n1mode.getValue() == 1 and n1mode1.getValue() == 1) {
			me["N11-thr"].show();
			me["N11-ylim"].hide(); # Keep it hidden, since N1 mode limit calculation is not done yet
		} else {
			me["N11-thr"].hide();
			me["N11-ylim"].hide();
		}
		
		if (eng2_n1mode.getValue() == 1 and n1mode2.getValue() == 1) {
			me["N12-thr"].show();
			me["N12-ylim"].hide(); # Keep it hidden, since N1 mode limit calculation is not done yet
		} else {
			me["N12-thr"].hide();
			me["N12-ylim"].hide();
		}
		
		# N2
		me["N21"].setText(sprintf("%s", math.floor(eng1_n2.getValue() + 0.05)));
		me["N21-decimal"].setText(sprintf("%s", int(10 * math.mod(eng1_n2.getValue() + 0.05, 1))));
		me["N22"].setText(sprintf("%s", math.floor(eng2_n2.getValue() + 0.05)));
		me["N22-decimal"].setText(sprintf("%s", int(10 * math.mod(eng2_n2.getValue() + 0.05, 1))));
		
		if (eng1_n2mode.getValue() == 1) {
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
		
		if (eng2_n2mode.getValue() == 1) {
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
		me["FF1"].setText(sprintf("%s", math.round(fuel_1.getValue(), 10)));
		me["FF2"].setText(sprintf("%s", math.round(fuel_2.getValue(), 10)));
		
		if (ff_1 == 1) {
			me["FF1"].show();
			me["FF1-XX"].hide();
		} else {
			me["FF1"].hide();
			me["FF1-XX"].show();
		}
		
		if (ff_2 == 1) {
			me["FF2"].show();
			me["FF2-XX"].hide();
		} else {
			me["FF2"].hide();
			me["FF2-XX"].show();
		}
		
		# EPR Limit
		me["EPRLim-mode"].setText(sprintf("%s", thr_limit.getValue()));
		me["EPRLim"].setText(sprintf("%1.0f", math.floor(epr_limit.getValue())));
		me["EPRLim-decimal"].setText(sprintf("%03d", (epr_limit.getValue() - int(epr_limit.getValue())) * 1000));
		
		if (fadecpower_1.getValue() == 1 or fadecpower_2.getValue() == 1 or fadecpowerup.getValue()) {
			me["EPRLim-mode"].show();
			me["EPRLim-XX"].hide();
			me["EPRLim-XX2"].hide();
		} else {
			me["EPRLim-mode"].hide();
			me["EPRLim-XX"].show();
			me["EPRLim-XX2"].show();
		}
		
		if ((fadecpower_1.getValue() == 1 or fadecpower_2.getValue() == 1 or fadecpowerup.getValue()) and thr_limit.getValue() != "MREV") {
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
		if (du3_test_time.getValue() + 1 >= elapsedtime) {
			me["Test_white"].show();
			me["Test_text"].hide();
		} else {
			me["Test_white"].hide();
			me["Test_text"].show();
		}
	},
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
