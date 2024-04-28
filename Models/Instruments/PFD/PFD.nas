# A3XX PFD
# Copyright (c) 2024 Josh Davidson (Octal450) and Jonathan Redpath (legoboyvdlp)

var acconfig = props.globals.getNode("/systems/acconfig/autoconfig-running", 1);
var acconfig_weight_kgs = props.globals.getNode("/systems/acconfig/options/weight-kgs", 1);
var adr_1_switch = props.globals.getNode("/controls/navigation/adirscp/switches/adr-1", 1);
var adr_2_switch = props.globals.getNode("/controls/navigation/adirscp/switches/adr-2", 1);
var adr_3_switch = props.globals.getNode("/controls/navigation/adirscp/switches/adr-3", 1);
var adr_1_fault = props.globals.getNode("/controls/navigation/adirscp/lights/adr-1-fault", 1);
var adr_2_fault = props.globals.getNode("/controls/navigation/adirscp/lights/adr-2-fault", 1);
var adr_3_fault = props.globals.getNode("/controls/navigation/adirscp/lights/adr-3-fault", 1);
var air_data_switch = props.globals.getNode("/controls/navigation/switching/air-data", 1);
var altitude = props.globals.getNode("/instrumentation/altimeter/indicated-altitude-ft", 1);
var alt_hpa = props.globals.getNode("/instrumentation/altimeter/setting-hpa", 1);
var alt_inhg = props.globals.getNode("/instrumentation/altimeter/setting-inhg", 1);
var aoa_1 = props.globals.getNode("/systems/navigation/adr/output/aoa-1-damped", 1);
var aoa_2 = props.globals.getNode("/systems/navigation/adr/output/aoa-2-damped", 1);
var aoa_3 = props.globals.getNode("/systems/navigation/adr/output/aoa-3-damped", 1);
var hundredAbove = props.globals.getNode("/instrumentation/pfd/hundred-above", 1);
var minimum = props.globals.getNode("/instrumentation/pfd/minimums", 1);

# Create Nodes:
var altFlash = [0,0];
var amberFlash = [0, 0];
var aFloorFlash = 0;
var dhFlash = 0;
var togaLkFlash = 0;
var ilsFlash = [0,0];
var qnhFlash = [0,0];
var vsFlash = [0, 0];
var elapsedtime_act = nil;
var du1_test = props.globals.initNode("/instrumentation/du/du1-test", 0, "BOOL");
var du1_test_time = props.globals.initNode("/instrumentation/du/du1-test-time", 0.0, "DOUBLE");
var du1_offtime = props.globals.initNode("/instrumentation/du/du1-off-time", 0.0, "DOUBLE");
var du1_test_amount = props.globals.initNode("/instrumentation/du/du1-test-amount", 0.0, "DOUBLE");
var du2_test = props.globals.initNode("/instrumentation/du/du2-test", 0, "BOOL");
var du2_test_time = props.globals.initNode("/instrumentation/du/du2-test-time", 0.0, "DOUBLE");
var du2_test_amount = props.globals.initNode("/instrumentation/du/du2-test-amount", 0.0, "DOUBLE");
var du5_test = props.globals.initNode("/instrumentation/du/du5-test", 0, "BOOL");
var du5_test_time = props.globals.initNode("/instrumentation/du/du5-test-time", 0.0, "DOUBLE");
var du5_test_amount = props.globals.initNode("/instrumentation/du/du5-test-amount", 0.0, "DOUBLE");
var du6_test = props.globals.initNode("/instrumentation/du/du6-test", 0, "BOOL");
var du6_test_time = props.globals.initNode("/instrumentation/du/du6-test-time", 0.0, "DOUBLE");
var du6_test_amount = props.globals.initNode("/instrumentation/du/du6-test-amount", 0.0, "DOUBLE");
var du6_offtime = props.globals.initNode("/instrumentation/du/du6-off-time", 0.0, "DOUBLE");
var autoland_alarm = props.globals.initNode("/instrumentation/pfd/logic/autoland/autoland-alarm", 0, "BOOL");
var autoland_pulse = props.globals.initNode("/instrumentation/pfd/logic/autoland/autoland-sw-pulse", 0, "BOOL");
var autoland_pitch_land = props.globals.initNode("/instrumentation/pfd/logic/autoland/pitch-land", 0, "BOOL");
var autoland_ap_disc_ft = props.globals.initNode("/instrumentation/pfd/logic/autoland/ap-disc-ft", 0, "INT");

var canvas_pfd = {
	alt_diff_cur: 0,
	ASItrendIsShown: 0,
	leftText1: 0,
	leftText2: 0,
	leftText3: 0,
	heading: 0,
	heading10: 0,
	headOffset: 0,
	magnetic_hdg_dif: 0,
	middleOffset: 0,
	middleText: 0,
	rightText1: 0,
	rightText2: 0,
	rightText3: 0,
	split_ils: 0,
	track_diff: 0,
	new: func(svg, name, number) {
		var obj = {parents: [canvas_pfd] };
		obj.canvas = canvas.new({
			"name": "PFD" ~ number,
			"size": [1024, 1024],
			"view": [1024, 1024],
			"mipmapping": 1,
		});
		obj.canvas.addPlacement({"node": "pfd" ~ (number + 1) ~ ".screen"});
		
        obj.group = obj.canvas.createGroup();
        obj.test = obj.canvas.createGroup();
        obj.mismatch = obj.canvas.createGroup();
		
		obj.font_mapper = func(family, weight) {
			return "ECAMFontRegular.ttf";
		};
		obj.font_mapper_ls = func(family, weight) {
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
		
		canvas.parsesvg(obj.test, "Aircraft/A320-family/Models/Instruments/Common/res/du-test.svg", {"font-mapper": obj.font_mapper} );
		canvas.parsesvg(obj.mismatch, "Aircraft/A320-family/Models/Instruments/Common/res/Error.svg", {"font-mapper": obj.font_mapper_ls} );
		
		foreach(var key; obj.getKeysTest()) {
			obj[key] = obj.test.getElementById(key);
		};
		foreach(var key; obj.getKeysMismatch()) {
			obj[key] = obj.mismatch.getElementById(key);
		};
		
		obj.number = number;
		obj.units = acconfig_weight_kgs.getValue();
		
		# temporary vars
		obj.ASItrendIsShown = 0;
		obj.alt_diff_cur = 0;
		obj.heading = 0;
		obj.heading10 = 0;
		obj.headOffset = 0;
		obj.leftText1 = 0;
		obj.leftText2 = 0;
		obj.leftText3 = 0;
		obj.magnetic_hdg_dif = 0;
		obj.middleOffset = 0;
		obj.middleText = 0;
		obj.rightText1 = 0;
		obj.rightText2 = 0;
		obj.rightText3 = 0;
		obj.split_ils = 0;
		obj.track_diff = 0;
		
		# hide non-updated objects
		obj["FMA_catmode"].hide();
		obj["FMA_cattype"].hide();
		obj["FMA_catmode_box"].hide();
		obj["FMA_cattype_box"].hide();
		obj["FMA_cat_box"].hide();
		obj["spdLimError"].hide();
		obj["FMA_dh_box"].hide();
		
		# init hidden objects
		obj["LOC_scale"].hide();
		obj["GS_scale"].hide();
		
		obj.temporaryNodes = {
			showGroundReferenceAGL: 0,
			showTailstrikeAGL: 0,
			showTailstrikeGroundspeed: 0,
			showTailstrikeThrust: 0,
		};
		
		obj.AICenter = obj["AI_center"].getCenter();
		
		obj.update_items = [
			props.UpdateManager.FromHashValue("pitchPFD", 0.025, func(val) {
				obj.AI_horizon_trans.setTranslation(0, val * 11.825);
			}),
			props.UpdateManager.FromHashValue("roll", 0.025, func(val) {
				obj.AI_horizon_rot.setRotation(-val * D2R, obj.AICenter);
				obj.AI_horizon_ground_rot.setRotation(-val * D2R, obj.AICenter);
				obj.AI_horizon_sky_rot.setRotation(-val * D2R, obj.AICenter);
				obj.AI_horizon_hdg_rot.setRotation(-val * D2R, obj.AICenter);
				obj["AI_bank"].setRotation(-val * D2R);
				obj["AI_agl_g"].setRotation(-val * D2R);
				obj.AI_fpv_rot.setRotation(-val * D2R, obj.AICenter);
				obj["FPV"].setRotation(val * D2R); # It shouldn't be rotated, only the axis should
			}),
			props.UpdateManager.FromHashList(["FDRollBar","roll"], 0.025, func(val) {
				obj.AI_fpd_rot.setRotation(-val.roll * D2R, obj.AICenter);
				obj["FPD"].setRotation((val.roll + val.FDRollBar) * D2R); # It shouldn't be rotated, only the axis should + FD rotation
			}),
			props.UpdateManager.FromHashValue("fbwLaw", 1, func(val) {
				if (val == 0) {
					obj["AI_bank_lim"].show();
					obj["AI_pitch_lim"].show();
					obj["AI_bank_lim_X"].hide();
					obj["AI_pitch_lim_X"].hide();
				} else {
					obj["AI_bank_lim"].hide();
					obj["AI_pitch_lim"].hide();
					obj["AI_bank_lim_X"].show();
					obj["AI_pitch_lim_X"].show();
				}
			}),
			props.UpdateManager.FromHashValue("horizonGround", 0.1, func(val) {
				obj.AI_horizon_ground_trans.setTranslation(0, val * 11.825);
			}),
			props.UpdateManager.FromHashList(["middleOffset","horizonPitch"], 0.1, func(val) {
				obj.AI_horizon_hdg_trans.setTranslation(val.middleOffset, val.horizonPitch * 11.825);
			}),
			props.UpdateManager.FromHashValue("slipSkid", 0.1, func(val) {
				obj["AI_slipskid"].setTranslation(math.clamp(val, -15, 15) * 7, 0);
			}),
			props.UpdateManager.FromHashValue("FDRollBar", 0.1, func(val) {
				obj["FD_roll"].setTranslation(val * 2.2, 0);
			}),
			props.UpdateManager.FromHashValue("FDPitchBar", 0.1, func(val) {
				obj["FD_pitch"].setTranslation(0, val * -11.825);
			}),
			props.UpdateManager.FromHashValue("agl", 0.5, func(val) {
				var roundingFactor = 1;
				if (val >= 50) {
					roundingFactor = 10;
				} else if (val >= 5) {
					roundingFactor = 5;
				}
				
				obj["AI_agl"].setText(sprintf("%s", math.round(math.clamp(val, 0, 2500), roundingFactor)));
				
				obj["ground_ref"].setTranslation(0, (-val / 100) * -48.66856);
				obj["ground"].setTranslation(0, (-val / 100) * -48.66856);
				
				if (abs(val) <= 565) {
					obj.temporaryNodes.showGroundReferenceAGL = 1;
				} else {
					obj.temporaryNodes.showGroundReferenceAGL = 0;
				}
				
				if (val <= 400) {
					obj.temporaryNodes.showTailstrikeAGL = 1;
				} else {
					obj.temporaryNodes.showTailstrikeAGL = 0;
				}
			}),
			props.UpdateManager.FromHashValue("vsNeedle", 0.1, func(val) {
				obj["VS_pointer"].setRotation(val * D2R);
			}),
			props.UpdateManager.FromHashValue("vsDigit", 0.5, func(val) {
				obj["VS_box"].setTranslation(0, val);
			}),
			props.UpdateManager.FromHashValue("vsPFD", 0.5, func(val) {
				if (val < 2) {
					obj["VS_box"].hide();
				} else {
					obj["VS_digit"].setText(sprintf("%02d", val));
					obj["VS_box"].show();
				}
			}),
			props.UpdateManager.FromHashValue("localizer", 0.0025, func(val) {
				obj["LOC_pointer"].setTranslation(val * 197, 0);	
			}),
			props.UpdateManager.FromHashValue("glideslope", 0.0025, func(val) {
				obj["GS_pointer"].setTranslation(0, val * -197);
			}),
			props.UpdateManager.FromHashList(["athr", "thrustLvrClb"], 1, func(val) {
				if (val.athr and val.thrustLvrClb) {
					obj["FMA_lvrclb"].show();
				} else {
					obj["FMA_lvrclb"].hide();
				}
			}),
			props.UpdateManager.FromHashList(["trackHdgDiff","aoaPFD","FPDPitch"], 0.01, func(val) {
				obj.track_diff = val.trackHdgDiff; # store this to use in FPV
				obj["TRK_pointer"].setTranslation(obj.getTrackDiffPixels(obj.track_diff),0);
				obj.AI_fpv_trans.setTranslation(obj.getTrackDiffPixels(math.clamp(obj.track_diff, -21, 21)), math.clamp(val.aoaPFD, -15, 15) * 11.825); 
				obj.AI_fpd_trans.setTranslation(obj.getTrackDiffPixels(math.clamp(obj.track_diff, -21, 21)), val.FPDPitch * 11.825); 
			}),
			props.UpdateManager.FromHashList(["vsAutopilot","agl"], 5, func(val) {
				if (abs(val.vsAutopilot) >= 6000 or (val.vsAutopilot <= -2000 and val.agl <= 2500) or (val.vsAutopilot <= -1200 and val.agl <= 1000)) {
					obj["VS_digit"].setColor(0.7333,0.3803,0);
					obj["VS_pointer"].setColor(0.7333,0.3803,0);
					obj["VS_pointer"].setColorFill(0.7333,0.3803,0);
				} else {
					obj["VS_digit"].setColor(0.0509,0.7529,0.2941);
					obj["VS_pointer"].setColor(0.0509,0.7529,0.2941);
					obj["VS_pointer"].setColorFill(0.0509,0.7529,0.2941);
				}
			}),
			props.UpdateManager.FromHashList(["aileronPFD","elevatorPFD"], 0.01, func(val) {
				obj["AI_stick_pos"].setTranslation(val.aileronPFD * 196.8, val.elevatorPFD * 151.5);
			}),
			props.UpdateManager.FromHashValue("headingScale", 0.025, func(val) {
				obj.heading = val;
				obj.heading10 = (obj.heading / 10);
				obj.headOffset = obj.heading10 - int(obj.heading10);
				obj.middleText = roundabout(obj.heading10);
				
				obj.middleOffset = 0;
				
				if (obj.middleText == 36) {
					obj.middleText = 0;
				}
				
				obj.leftText1 = obj.middleText == 0 ? 35 : obj.middleText - 1;
				obj.rightText1 = obj.middleText == 35 ? 0: obj.middleText + 1;
				obj.leftText2 = obj.leftText1 == 0 ? 35 : obj.leftText1 - 1;
				obj.rightText2 = obj.rightText1 == 35 ? 0 : obj.rightText1 + 1;
				obj.leftText3 = obj.leftText2 == 0 ? 35 : obj.leftText2 - 1;
				obj.rightText3 = obj.rightText2 == 35 ? 0 : obj.rightText2 + 1;
				
				if (obj.headOffset > 0.5) {
					obj.middleOffset = -(obj.headOffset - 1) * 98.5416;
				} else {
					obj.middleOffset = -obj.headOffset * 98.5416;
				}
				
				obj["HDG_scale"].setTranslation(obj.middleOffset, 0);
				obj["HDG_scale"].update();
				
				obj["HDG_four"].setText(sprintf("%d", obj.middleText));
				obj["HDG_five"].setText(sprintf("%d", obj.rightText1));
				obj["HDG_three"].setText(sprintf("%d", obj.leftText1));
				obj["HDG_six"].setText(sprintf("%d", obj.rightText2));
				obj["HDG_two"].setText(sprintf("%d", obj.leftText2));
				obj["HDG_seven"].setText(sprintf("%d", obj.rightText3));
				obj["HDG_one"].setText(sprintf("%d", obj.leftText3));
				
				# TODO: optimize here - only when the attributes update
				obj["HDG_four"].setFontSize(fontSizeHDG(obj.middleText), 1);
				obj["HDG_five"].setFontSize(fontSizeHDG(obj.rightText1), 1);
				obj["HDG_three"].setFontSize(fontSizeHDG(obj.leftText1), 1);
				obj["HDG_six"].setFontSize(fontSizeHDG(obj.rightText2), 1);
				obj["HDG_two"].setFontSize(fontSizeHDG(obj.leftText2), 1);
				obj["HDG_seven"].setFontSize(fontSizeHDG(obj.rightText3), 1);
				obj["HDG_one"].setFontSize(fontSizeHDG(obj.leftText3), 1);
			}),
			props.UpdateManager.FromHashValue("altitudeAutopilot", 50, func(val) {
				obj["ALT_digit_UP_metric"].setText(sprintf("%5.0fM", val * 0.3048));
			}),
			props.UpdateManager.FromHashList(["fac1","fac2"], 1, func(val) {
				if (obj.number == 0) { # LHS only acc to manual
					if (!val.fac1 and !val.fac2) {
						obj["spdLimError"].show();
					} else {
						obj["spdLimError"].hide();
					}
				}
			}),
			props.UpdateManager.FromHashList(["fd1","fd2","ap1","ap2"], 1, func(val) {
				if (val.fd1 or val.fd2 or val.ap1 or val.ap2) {
					obj["FMA_pitcharm"].show();
					obj["FMA_pitcharm2"].show();
					obj["FMA_rollarm"].show();
					obj["FMA_pitch"].show();
					obj["FMA_roll"].show();
				} else {
					obj["FMA_pitcharm"].hide();
					obj["FMA_pitcharm2"].hide();
					obj["FMA_rollarm"].hide();
					obj["FMA_pitch"].hide();
					obj["FMA_roll"].hide();
				}
			}),
			props.UpdateManager.FromHashList(["gear1Wow","gear2Wow","fmgcPhase","engine1State","engine2State"], 1, func(val) {
				if ((val.gear1Wow or val.gear2Wow) and val.fmgcPhase != 0 and val.fmgcPhase != 1) {
					obj["AI_stick"].show();
					obj["AI_stick_pos"].show();
				} else if ((val.gear1Wow or val.gear2Wow) and (val.fmgcPhase == 0 or val.fmgcPhase == 1) and (val.engine1State == 3 or val.engine2State == 3)) {
					obj["AI_stick"].show();
					obj["AI_stick_pos"].show();
				} else {
					obj["AI_stick"].hide();
					obj["AI_stick_pos"].hide();
				}
			}),
			props.UpdateManager.FromHashList(["markerO","markerM","markerI"], 1, func(val) {
				if (val.markerO) {
					obj["outerMarker"].show();
					obj["middleMarker"].hide();
					obj["innerMarker"].hide();
				} else if (val.markerM) {
					obj["middleMarker"].show();
					obj["outerMarker"].hide();
					obj["innerMarker"].hide();
				} else if (val.markerI) {
					obj["innerMarker"].show();
					obj["outerMarker"].hide();
					obj["middleMarker"].hide();
				} else {
					obj["outerMarker"].hide();
					obj["middleMarker"].hide();
					obj["innerMarker"].hide();	
				}
			}),
			props.UpdateManager.FromHashList(["pfdILS1","pfdILS2"], 1, func(val) {
				if ((obj.number == 0 and val.pfdILS1) or (obj.number == 1 and val.pfdILS2)) {
					obj["LOC_scale"].show();
					obj["GS_scale"].show();
				} else {
					obj["LOC_scale"].hide();
					obj["GS_scale"].hide();
				}
			}),
			props.UpdateManager.FromHashList(["hasLocalizer","hasGlideslope","signalQuality","localizerInRange","glideslopeInRange","pfdILS1","pfdILS2"], nil, func(val) {
				if (((obj.number == 0 and val.pfdILS1) or (obj.number == 1 and val.pfdILS2)) and val.localizerInRange and val.hasLocalizer and val.signalQuality > 0.99) {
					obj["LOC_pointer"].show();
				} else {
					obj["LOC_pointer"].hide();
				}
				if (((obj.number == 0 and val.pfdILS1) or (obj.number == 1 and val.pfdILS2)) and val.glideslopeInRange and val.hasGlideslope and val.signalQuality > 0.99) {
					obj["GS_pointer"].show();
				} else {
					obj["GS_pointer"].hide();
				}
			}),
			props.UpdateManager.FromHashValue("flexTemp", 1, func(val) {
				obj["FMA_flxtemp"].setText(sprintf("%s", "+" ~ val));
			}),
			props.UpdateManager.FromHashValue("groundspeed", 1, func(val) {
				if (val > 50) {
					obj.temporaryNodes.showTailstrikeGroundspeed = 1;
				} else {
					obj.temporaryNodes.showTailstrikeGroundspeed = 0;
				}
			}),
			props.UpdateManager.FromHashList(["detent1","detent2"], 1, func(val) {
				if (val.detent1 <= 3 and val.detent2 <= 3) {
					obj.temporaryNodes.showTailstrikeThrust = 1;
				} else {
					obj.temporaryNodes.showTailstrikeThrust = 0;
				}
			}),
			props.UpdateManager.FromHashValue("targetHeading", 0.5, func(val) {
				obj["HDG_digit_L"].setText(sprintf("%3.0f", val));
				obj["HDG_digit_R"].setText(sprintf("%3.0f", val));
			}),
			props.UpdateManager.FromHashValue("hdgDiff", 0.025, func(val) {
				obj["HDG_target"].setTranslation((val / 10) * 98.5416, 0);
			}),
			props.UpdateManager.FromHashList(["hdgDiff","showHdg"], 0.01, func(val) {
				if (val.showHdg and val.hdgDiff >= -23.62 and val.hdgDiff <= 23.62) {
					obj["HDG_digit_L"].hide();
					obj["HDG_digit_R"].hide();
					obj["HDG_target"].show();
				} else if (val.showHdg and val.hdgDiff < -23.62 and val.hdgDiff >= -180) {
					obj["HDG_digit_L"].show();
					obj["HDG_digit_R"].hide();
					obj["HDG_target"].hide();
				} else if (val.showHdg and val.hdgDiff > 23.62 and val.hdgDiff <= 180) {
					obj["HDG_digit_R"].show();
					obj["HDG_digit_L"].hide();
					obj["HDG_target"].hide();
				} else {
					obj["HDG_digit_L"].hide();
					obj["HDG_digit_R"].hide();
					obj["HDG_target"].hide();
				}
			}),
			props.UpdateManager.FromHashList(["altimeterHpa","altimeterInhg","altimeterInhgModeLeft","altimeterInhgModeRight"], 0.005, func(val) {
				if ((obj.number == 0 and val.altimeterInhgModeLeft == 0) or (obj.number == 1 and val.altimeterInhgModeRight == 0)) {
					obj["QNH_setting"].setText(sprintf("%4d", math.round(val.altimeterHpa)));
				} else {
					obj["QNH_setting"].setText(sprintf("%2.2f", math.round(val.altimeterInhg * 100) / 100));
				}
			}),
			props.UpdateManager.FromHashList(["altimeterStd","altitudeAutopilot"], 1, func(val) {
				if (val.altimeterStd == 1) {
					obj["ALT_digit_UP"].setText(sprintf("FL%3d", val.altitudeAutopilot / 100));
					obj["ALT_digit_DN"].setText(sprintf("FL%3d", val.altitudeAutopilot / 100));
				} else {
					obj["ALT_digit_UP"].setText(sprintf("%5d", val.altitudeAutopilot));
					obj["ALT_digit_DN"].setText(sprintf("%5d", val.altitudeAutopilot));
				}
			}),
			props.UpdateManager.FromHashValue("managedSpd", 1, func(val) {
				if (val) {
					obj["ASI_target"].setColor(0.6901,0.3333,0.7450);
					obj["ASI_digit_UP"].setColor(0.6901,0.3333,0.7450);
					obj["ASI_decimal_UP"].setColor(0.6901,0.3333,0.7450);
					obj["ASI_digit_DN"].setColor(0.6901,0.3333,0.7450);
					obj["ASI_decimal_DN"].setColor(0.6901,0.3333,0.7450);
				} else {
					obj["ASI_target"].setColor(0.0901,0.6039,0.7176);
					obj["ASI_digit_UP"].setColor(0.0901,0.6039,0.7176);
					obj["ASI_decimal_UP"].setColor(0.0901,0.6039,0.7176);
					obj["ASI_digit_DN"].setColor(0.0901,0.6039,0.7176);
					obj["ASI_decimal_DN"].setColor(0.0901,0.6039,0.7176);
				}
			}),
			props.UpdateManager.FromHashValue("dmeDistance", 0.025, func(val) {
				if (val < 19.95) {
					obj["dme_dist"].setText(sprintf("%1.1f", val));
				} else {
					obj["dme_dist"].setText(sprintf("%2.0f", val));
				}
			}),
			props.UpdateManager.FromHashValue("speedError", 1, func(val) {
				if (!val) {
					obj["ASI_error"].hide();
					obj["ASI_buss"].hide();
					obj["ASI_buss_ref"].hide();
					obj["ASI_buss_ref_blue"].hide();
					obj["ASI_frame"].setColor(1,1,1);
					obj["ASI_group"].show();
					obj["VLS_min"].hide();
					obj["ALPHA_PROT"].hide();
					obj["ALPHA_MAX"].hide();
					obj["ALPHA_SW"].hide();
				} else {
					obj["ASI_group"].hide();
					obj["ASI_frame"].setColor(1,0,0);
					obj["clean_speed"].hide();
					obj["S_target"].hide();
					obj["F_target"].hide();
					obj["flap_max"].hide();
					obj["v1_group"].hide();
					obj["v1_text"].hide();
					obj["vr_speed"].hide();
					obj["ground"].hide(); # Why?
					obj["ground_ref"].hide();
					obj["VLS_min"].hide();
					obj["VLS_min"].hide();
					obj["ALPHA_PROT"].hide();
					obj["ALPHA_MAX"].hide();
					obj["ALPHA_SW"].hide();
				}
			}),
			props.UpdateManager.FromHashList(["speedError","fac1","fac2"], 1, func(val) {
				if (!val.speedError and (val.fac1 or val.fac2)) {
					obj["ASI_max"].show();
				} else {
					obj["ASI_max"].hide();
				}
			}),
			props.UpdateManager.FromHashList(["speedError","fac1","fac2","ASItrendIsShown"], 1, func(val) {
				if (!val.speedError and (val.fac1 or val.fac2)) {
					if (val.ASItrendIsShown == 1) {
						obj["ASI_trend_up"].show();
						obj["ASI_trend_down"].hide();
					} else if (val.ASItrendIsShown == -1) {
						obj["ASI_trend_up"].hide();
						obj["ASI_trend_down"].show();
					} else {
						obj["ASI_trend_up"].hide();
						obj["ASI_trend_down"].hide();
					}
				} else {
						obj["ASI_trend_up"].hide();
						obj["ASI_trend_down"].hide();
				}
			}),
			props.UpdateManager.FromHashValue("ASI", 0.1, func(val) {
				obj["ASI_scale"].setTranslation(0, val * 6.6);
			}),
			props.UpdateManager.FromHashValue("ASImax", 0.1, func(val) {
				obj["ASI_max"].setTranslation(0, val * -6.6);
			}),
			props.UpdateManager.FromHashValue("ASItrend", 0.1, func(val) {
				obj["ASI_trend_up"].setTranslation(0, math.clamp(val, 0, 50) * -6.6);
				obj["ASI_trend_down"].setTranslation(0, math.clamp(val, -50, 0) * -6.6);
			}),
			props.UpdateManager.FromHashValue("V1trgt", 0.1, func(val) {
				obj["v1_group"].setTranslation(0, val * -6.6);
				obj["v1_text"].setText(sprintf("%3.0f", fmgc.FMGCInternal.v1));
			}),
			props.UpdateManager.FromHashList(["speedError","showVr","SPDv1trgtdiff","fmgcPhase","agl"], 0.5, func(val) {
				if (!val.speedError and val.showVr) {
					if (val.agl < 55 and val.fmgcPhase <= 2 and abs(val.SPDv1trgtdiff) <= 42) {
						obj["v1_group"].show();
						obj["v1_text"].hide();
					} else if (val.agl < 55 and fmgc.FMGCInternal.phase <= 2) {
						obj["v1_group"].hide();
						obj["v1_text"].show();
					} else {
						obj["v1_group"].hide();
						obj["v1_text"].hide();
					}
				} else {
					obj["v1_group"].hide();
					obj["v1_text"].hide();
				}
			}),
			props.UpdateManager.FromHashValue("VRtrgt", 0.1, func(val) {
				obj["vr_speed"].setTranslation(0, val * -6.6);
			}),
			props.UpdateManager.FromHashList(["speedError","showVr","SPDvrtrgtdiff","fmgcPhase","agl"], 0.5, func(val) {
				if (!val.speedError and val.showVr) {
					if (val.agl < 55 and val.fmgcPhase <= 2 and abs(val.SPDvrtrgtdiff) <= 42) {
						obj["vr_speed"].show();
					} else {
						obj["vr_speed"].hide();
					}
				} else {
					obj["vr_speed"].hide();
				}
			}),
			props.UpdateManager.FromHashList(["speedError","showV2","SPDv2trgtdiff","fmgcPhase","agl","V2trgt"], 0.5, func(val) {
				if (!val.speedError and val.showVr) {
					if (val.agl < 55 and val.fmgcPhase <= 2 and abs(val.SPDv2trgtdiff) <= 42) {
						obj["ASI_target"].show();
						obj["ASI_target"].setTranslation(0, val.V2trgt * -6.6);
						obj["ASI_digit_UP"].setText(sprintf("%3.0f", fmgc.FMGCInternal.v2));
					} else if (val.agl < 55 and fmgc.FMGCInternal.phase <= 2) {
						obj["ASI_target"].hide();
						obj["ASI_digit_UP"].setText(sprintf("%3.0f", fmgc.FMGCInternal.v2));
					}
				}
			}),
			props.UpdateManager.FromHashList(["machError","ind_mach"], 0.001, func(val) {
				if (val.machError) {
					obj["ASI_mach"].hide();
					obj["machError"].show();
				} else {
					obj["machError"].hide();
					
					if (val.ind_mach >= 0.999) {
						obj["ASI_mach"].setText(".999");
					} else {
						obj["ASI_mach"].setText(sprintf(".%3.0f", math.round(val.ind_mach * 1000)));
					}
					
					if (val.ind_mach >= 0.5) {
						obj["ASI_mach"].show();
					} else {
						obj["ASI_mach"].hide();
					}
				}
			}),
			props.UpdateManager.FromHashList(["flapMaxSpeed","ASI"], 0.1, func(val) {
				obj["flap_max"].setTranslation(0, (val.flapMaxSpeed - 30 - val.ASI) * -6.6);
			}),
			props.UpdateManager.FromHashList(["speedError","fac1","fac2","flapMaxSpeed","flapsInput","ind_spd"], 0.5, func(val) {
				if (!val.speedError and (val.fac1 or val.fac2)) {
					if (abs(val.flapMaxSpeed - val.ind_spd) <= 42 and val.flapsInput != 4) {
						obj["flap_max"].show();
					} else {
						obj["flap_max"].hide();
					}
				} else {
					obj["flap_max"].hide();
				}
			}),
			props.UpdateManager.FromHashValue("Ctrgt", 0.1, func(val) {
				obj["clean_speed"].setTranslation(0, val * -6.6);
			}),
			props.UpdateManager.FromHashValue("Ftrgt", 0.1, func(val) {
				obj["F_target"].setTranslation(0, val * -6.6);
			}),
			props.UpdateManager.FromHashValue("Strgt", 0.1, func(val) {
				obj["S_target"].setTranslation(0, val * -6.6);
			}),
			props.UpdateManager.FromHashList(["speedError","fac1","fac2","flapsInput","SPDstrgtdiff","SPDftrgtdiff","SPDcleantrgtdiff","agl"], 0.5, func(val) {
				if (!val.speedError and (val.fac1 or val.fac2)) {
					if (val.flapsInput == 1) {
						obj["F_target"].hide();
						obj["clean_speed"].hide();
						
						if (abs(val.SPDstrgtdiff) <= 42 and val.agl >= 400) {
							obj["S_target"].show();
						} else {
							obj["S_target"].hide();
						}
					} else if (val.flapsInput == 2 or val.flapsInput == 3) {
						obj["S_target"].hide();
						obj["clean_speed"].hide();
						
						if (abs(val.SPDftrgtdiff) <= 42 and val.agl >= 400) {
							obj["F_target"].show();
						} else {
							obj["F_target"].hide();
						}
					} else if (val.flapsInput == 4) {
						obj["S_target"].hide();
						obj["F_target"].hide();
						obj["clean_speed"].hide();	
					} else {
						obj["S_target"].hide();
						obj["F_target"].hide();
						
						if (abs(val.SPDcleantrgtdiff) <= 42) {
							obj["clean_speed"].show();
						} else {
							obj["clean_speed"].hide();
						}	
						
					}
				} else {
					obj["S_target"].hide();
					obj["F_target"].hide();
					obj["clean_speed"].hide();
				}
			}),
			props.UpdateManager.FromHashValue("bussTranslate", 0.2, func(val) {
				obj["ASI_buss"].setTranslation(0, val);
				obj["ASI_buss_ref_blue"].setTranslation(0, val);
			}),
			props.UpdateManager.FromHashList(["speedError","fac1","fac2","fbwLaw","fmgcPhase","gear1Wow","gear2Wow","fmgcTakeoffState"], 1, func(val) {
				if (!val.fmgcTakeoffState and val.fmgcPhase >= 1 and !val.gear1Wow and !val.gear2Wow and !val.speedError and (val.fac1 or val.fac2)) {
					obj["VLS_min"].show();
					if (val.fbwLaw == 0) {
						obj["ALPHA_PROT"].show();
						obj["ALPHA_MAX"].show();
						obj["ALPHA_SW"].hide();
					} else {
						obj["ALPHA_PROT"].hide();
						obj["ALPHA_MAX"].hide();
						obj["ALPHA_SW"].show();
					}
				} else {
					obj["VLS_min"].hide();
					obj["ALPHA_PROT"].hide();
					obj["ALPHA_MAX"].hide();
					obj["ALPHA_SW"].hide();
				}
			}),
			props.UpdateManager.FromHashValue("ALPHAprot", 0.1, func(val) {
				obj["ALPHA_PROT"].setTranslation(0, val * -6.6);
			}),
			props.UpdateManager.FromHashValue("ALPHAmax", 0.1, func(val) {
				obj["ALPHA_MAX"].setTranslation(0, val * -6.6);
			}),
			props.UpdateManager.FromHashValue("ALPHAvsw", 0.1, func(val) {
				obj["ALPHA_SW"].setTranslation(0, val * -6.6);
			}),
			props.UpdateManager.FromHashValue("VLSmin", 0.1, func(val) {
				obj["VLS_min"].setTranslation(0, val * -6.6);
			}),
			props.UpdateManager.FromHashValue("ASItrgt", 0.1, func(val) {
				obj["ASI_target"].setTranslation(0, val * -6.6);
			}),
			props.UpdateManager.FromHashList(["speedError","ASItrgtdiff","targetMach","tgt_kts","ktsMach"], 0.5, func(val) {
				if (!val.speedError) {
					if (abs(val.ASItrgtdiff) <= 42) {
						obj["ASI_digit_UP"].hide();
						obj["ASI_decimal_UP"].hide();
						obj["ASI_digit_DN"].hide();
						obj["ASI_decimal_DN"].hide();
						obj["ASI_target"].show();
					} else if (val.ASItrgtdiff < -42) {
						if (val.ktsMach) {
							obj["ASI_digit_DN"].setText(sprintf("%3.0f", val.targetMach * 1000));
							obj["ASI_decimal_UP"].hide();
							obj["ASI_decimal_DN"].show();
						} else {
							obj["ASI_digit_DN"].setText(sprintf("%3.0f", val.tgt_kts));
							obj["ASI_decimal_UP"].hide();
							obj["ASI_decimal_DN"].hide();
						}
						obj["ASI_digit_DN"].show();
						obj["ASI_digit_UP"].hide();
						obj["ASI_target"].hide();
					} else if (val.ASItrgtdiff > 42) {
						if (val.ktsMach) {
							obj["ASI_digit_UP"].setText(sprintf("%3.0f", val.targetMach * 1000));
							obj["ASI_decimal_UP"].show();
							obj["ASI_decimal_DN"].hide();
						} else {
							obj["ASI_digit_UP"].setText(sprintf("%3.0f", val.tgt_kts));
							obj["ASI_decimal_UP"].hide();
							obj["ASI_decimal_DN"].hide();
						}
						obj["ASI_digit_UP"].show();
						obj["ASI_digit_DN"].hide();
						obj["ASI_target"].hide();
					}
				}
			}),
			props.UpdateManager.FromHashList(["showPFDILS","magnetic_hdg_dif"], 0.01, func(val) {
				if (val.showPFDILS) {
					if (abs(val.magnetic_hdg_dif) <= 23.62) {
						obj["CRS_pointer"].setTranslation((val.magnetic_hdg_dif / 10) * 98.5416, 0);
						
						obj["ILS_HDG_L"].hide();
						obj["ILS_HDG_R"].hide();
						obj["CRS_pointer"].show();
					} else if (val.magnetic_hdg_dif < -23.62 and val.magnetic_hdg_dif >= -180) {
						obj["ILS_HDG_L"].show();
						obj["ILS_HDG_R"].hide();
						obj["CRS_pointer"].hide();
					} else if (val.magnetic_hdg_dif > 23.62 and val.magnetic_hdg_dif <= 180) {
						obj["ILS_HDG_L"].hide();
						obj["ILS_HDG_R"].show();
						obj["CRS_pointer"].hide();
					} else {
						obj["ILS_HDG_L"].hide();
						obj["ILS_HDG_R"].hide();
						obj["CRS_pointer"].hide();
					}
				} else {
					obj["ILS_HDG_L"].hide();
					obj["ILS_HDG_R"].hide();
					obj["CRS_pointer"].hide();
				}
			}),
			props.UpdateManager.FromHashValue("ilsCrs", 0.5, func(val) {
				if (int(val) < 10) {
					obj["ILS_left"].setText(sprintf("00%1.0f", int(val)));
					obj["ILS_right"].setText(sprintf("00%1.0f", int(val)));
				} else if (int(val) < 100) {
					obj["ILS_left"].setText(sprintf("0%2.0f", int(val)));
					obj["ILS_right"].setText(sprintf("0%2.0f", int(val)));
				} else {
					obj["ILS_left"].setText(sprintf("%3.0f", int(val)));
					obj["ILS_right"].setText(sprintf("%3.0f", int(val)));
				}
			}),
			props.UpdateManager.FromHashValue("altimeterStd", 1, func(val) {
				if (val) {
					obj["QNH"].hide();
					obj["QNH_setting"].hide();
				} else {
					obj["QNH_std"].hide();
					obj["QNH_box"].hide();
				}
			}),
			props.UpdateManager.FromHashList(["showDecisionHeight","agl","decision","radio","baro","radioNo"], 0.5, func(val) {
				if (!val.showDecisionHeight) {
					obj["FMA_dh"].hide();
					obj["FMA_dhn"].hide();
					obj["FMA_nodh"].hide();
					
					if (val.agl <= 2500) {
						obj["AI_agl"].show();
						if (val.agl <= val.decision) {
							obj["AI_agl"].setColor(0.7333,0.3803,0);
							obj["AI_agl"].setFontSize(55);
						} else {
							if (val.agl <= 400) {
								obj["AI_agl"].setFontSize(55);
							} else {
								obj["AI_agl"].setFontSize(45);
							}
							obj["AI_agl"].setColor(0.0509,0.7529,0.2941);
						}
					} else {
						obj["AI_agl"].hide();
					}
				} else {
					if (val.agl <= 2500) {
						obj["AI_agl"].show();
						
						# Minimums
						if (int(val.radio) != 99999) {
							obj["FMA_dh"].setText("RADIO");
							obj["FMA_dh"].show();
							obj["FMA_dhn"].setText(sprintf("%.0f", val.radio));
							obj["FMA_dhn"].show();
							obj["FMA_nodh"].hide();
							hundredAbove.setValue(val.radio + 100);
							minimum.setValue(val.radio);
							
							if (val.agl <= val.radio + 100) {
								obj["AI_agl"].setColor(0.7333,0.3803,0);
								obj["AI_agl"].setFontSize(55);
							} else {
								if (val.agl <= 400) {
									obj["AI_agl"].setFontSize(55);
								} else {
									obj["AI_agl"].setFontSize(45);
								}
								obj["AI_agl"].setColor(0.0509,0.7529,0.2941);
							}
						} else if (int(val.baro) != 99999) {
							obj["FMA_dh"].setText("BARO");
							obj["FMA_dh"].show();
							obj["FMA_dhn"].setText(sprintf("%.0f", val.baro));
							obj["FMA_dhn"].show();
							obj["FMA_nodh"].hide();
							hundredAbove.setValue(val.baro + 100);
							minimum.setValue(val.baro);
							
							if (val.agl <= val.baro + 100) {
								obj["AI_agl"].setColor(0.7333,0.3803,0);
								obj["AI_agl"].setFontSize(55);
							} else {
								if (val.agl <= 400) {
									obj["AI_agl"].setFontSize(55);
								} else {
									obj["AI_agl"].setFontSize(45);
								}
								obj["AI_agl"].setColor(0.0509,0.7529,0.2941);
							}
						} else if (val.radioNo) {
							obj["FMA_dh"].setText("BARO");
							obj["FMA_dh"].show();
							obj["FMA_dhn"].setText("100");
							obj["FMA_dhn"].show();
							obj["FMA_nodh"].hide();
							hundredAbove.setValue(100);
							minimum.setValue(0);
							
							if (val.agl <= 400) {
								obj["AI_agl"].setFontSize(55);
							} else {
								obj["AI_agl"].setFontSize(45);
							}
							
							if (val.agl <= 100) {
								obj["AI_agl"].setColor(0.7333,0.3803,0);
							} else {
								obj["AI_agl"].setColor(0.0509,0.7529,0.2941);
							}
						} else {
							obj["FMA_dh"].hide();
							obj["FMA_dhn"].hide();
							obj["FMA_nodh"].show();
							hundredAbove.setValue(400);
							minimum.setValue(300);
							
							if (val.agl <= 400) {
								obj["AI_agl"].setColor(0.7333,0.3803,0);
								obj["AI_agl"].setFontSize(55);
							} else {
								obj["AI_agl"].setColor(0.0509,0.7529,0.2941);
								obj["AI_agl"].setFontSize(45);
							}
						}
					} else {
						obj["AI_agl"].hide();
						obj["FMA_nodh"].hide();
						
						# Minimums
						if (int(val.radio) != 99999) {
							obj["FMA_dh"].setText("RADIO");
							obj["FMA_dh"].show();
							obj["FMA_dhn"].setText(sprintf("%.0f", val.radio));
							obj["FMA_dhn"].show();
							obj["FMA_nodh"].hide();
						} else if (int(val.baro) != 99999) {
							obj["FMA_dh"].setText("BARO");
							obj["FMA_dh"].show();
							obj["FMA_dhn"].setText(sprintf("%.0f", val.baro));
							obj["FMA_dhn"].show();
							obj["FMA_nodh"].hide();
						} else if (fmgc.FMGCInternal.radioNo) {
							obj["FMA_dh"].setText("BARO");
							obj["FMA_dh"].show();
							obj["FMA_dhn"].setText("100");
							obj["FMA_dhn"].show();
							obj["FMA_nodh"].hide();
						} else {
							obj["FMA_dh"].hide();
							obj["FMA_dhn"].hide();
							obj["FMA_nodh"].show();
						}
					}
				}
			}),
			props.UpdateManager.FromHashValue("altError", 1, func(val) {
				if (val) {
					obj["ALT_error"].show();
					obj["ALT_frame"].setColor(1,0,0);
					obj["ALT_group"].hide();
					obj["ALT_tens"].hide();
					obj["ALT_neg"].hide();
					obj["ALT_group2"].hide();
					obj["ALT_scale"].hide();
					obj["ALT_box_flash"].hide();
					obj["ALT_box_amber"].hide();
					obj["ALT_box"].hide();
					obj["Metric_box"].hide();
					obj["Metric_letter"].hide();
					obj["Metric_cur_alt"].hide();
					obj["ALT_digit_UP_metric"].hide();
				} else {
					obj["ALT_error"].hide();
					obj["ALT_frame"].setColor(1,1,1);
					obj["ALT_group"].show();
					obj["ALT_tens"].show();
					obj["ALT_box"].show();
					obj["ALT_group2"].show();
					obj["ALT_scale"].show();
				}
			}),
			props.UpdateManager.FromHashList(["altError","showMetric"], 1, func(val) {
				if (!val.altError and val.showMetric) {	
					obj["ALT_digit_UP_metric"].show();
					obj["Metric_box"].show();
					obj["Metric_letter"].show();
					obj["Metric_cur_alt"].show();
				} else {
					obj["ALT_digit_UP_metric"].hide();
					obj["Metric_box"].hide();
					obj["Metric_letter"].hide();
					obj["Metric_cur_alt"].hide();
				}
			}),
			props.UpdateManager.FromHashList(["altitudePFD","altError"], 0.5, func(val) {
				if (!val.altError) {
					obj["Metric_cur_alt"].setText(sprintf("%5.0f", val.altitudePFD * 0.3048));
					
					obj.middleAltText = roundaboutAlt(val.altitudePFD / 100);
					
					obj["ALT_five"].setText(sprintf("%03d", abs(obj.middleAltText + 10)));
					obj["ALT_four"].setText(sprintf("%03d", abs(obj.middleAltText + 5)));
					obj["ALT_three"].setText(sprintf("%03d", abs(obj.middleAltText)));
					obj["ALT_two"].setText(sprintf("%03d", abs(obj.middleAltText - 5)));
					obj["ALT_one"].setText(sprintf("%03d", abs(obj.middleAltText - 10)));
				}
			}),
			props.UpdateManager.FromHashList(["altitudePFD","altError"], 0.1, func(val) {
				if (!val.altError) {
					obj.altOffset = val.altitudePFD / 500 - int(val.altitudePFD / 500);
					obj.middleAltOffset = nil;
					obj["ALT_tapes"].show();
					
					if (val.altitudePFD < 0) {
						obj["ALT_neg"].show();
						obj["ALT_tenthousands"].hide();
					} else {
						obj["ALT_neg"].hide();
						obj["ALT_tenthousands"].show();
					}
					
					if (obj.altOffset > 0.5) {
						obj.middleAltOffset = -(obj.altOffset - 1) * 243.3424;
					} else {
						obj.middleAltOffset = -obj.altOffset * 243.3424;
					}
					
					obj["ALT_scale"].setTranslation(0, -obj.middleAltOffset);
					obj["ALT_scale"].update();
					
					obj.altAbs = abs(val.altitudePFD);
					
					if (obj.altAbs < 9900) { # Prepare to show the zero at 10000
						obj["ALT_thousands_zero"].hide();
					} else {
						obj["ALT_thousands_zero"].show();
					}
					
					obj.altTenThousands = num(right(sprintf("%05d", obj.altAbs), 5)) / 100; # Unlikely it would be above 99999 but lets account for it anyways
					obj["ALT_tenthousands"].setTranslation(0, genevaAltTenThousands(obj.altTenThousands) * 51.61);
					
					obj.altThousands = num(right(sprintf("%04d", obj.altAbs), 4)) / 100;
					obj["ALT_thousands"].setTranslation(0, genevaAltThousands(obj.altThousands) * 51.61);
					
					obj.altHundreds = num(right(sprintf("%03d", obj.altAbs), 3)) / 100;
					obj["ALT_hundreds"].setTranslation(0, genevaAltHundreds(obj.altHundreds) * 51.61);
					
					obj["ALT_tens"].setTranslation(0, num(right(sprintf("%02d", obj.altAbs), 2)) * 1.498);
				} else {
					obj["ALT_tapes"].hide();
				}
			}),
			props.UpdateManager.FromHashValue("altitudeDifference", 0.1, func(val) {
				obj["ALT_target"].setTranslation(0, (val / 100) * -48.66856);
			}),
			props.UpdateManager.FromHashValue("altitudeAutopilot", 25, func(val) {
				obj["ALT_target_digit"].setText(sprintf("%03d", math.round(val / 100)));
			}),
			props.UpdateManager.FromHashList(["altError","altitudeDifference"], 1, func(val) {
				if (!val.altError and abs(val.altitudeDifference) <= 565) {
					obj["ALT_digit_UP"].hide();
					obj["ALT_digit_DN"].hide();
					obj["ALT_target"].show();
				} else {
					if (val.altitudeDifference < -565 and !val.altError) {
						obj["ALT_digit_DN"].show();
						obj["ALT_digit_UP"].hide();
					} else if (val.altitudeDifference > 565 and  !val.altError) {
						obj["ALT_digit_UP"].show();
						obj["ALT_digit_DN"].hide();
					} else {
						obj["ALT_digit_UP"].hide();
						obj["ALT_digit_DN"].hide();
					}
					obj["ALT_target"].hide();
				}
			}),
		];
		
		obj.update_items_mismatch = [
			props.UpdateManager.FromHashValue("acconfigMismatch", nil, func(val) {
				obj["Error_Code"].setText(val);
			}),
		];
		
		obj.AI_horizon_trans = obj["AI_horizon"].createTransform();
		obj.AI_horizon_rot = obj["AI_horizon"].createTransform();
		
		obj.AI_horizon_ground_trans = obj["AI_horizon_ground"].createTransform();
		obj.AI_horizon_ground_rot = obj["AI_horizon_ground"].createTransform();
		
		obj.AI_horizon_sky_rot = obj["AI_horizon_sky"].createTransform();
		
		obj.AI_horizon_hdg_trans = obj["AI_heading"].createTransform();
		obj.AI_horizon_hdg_rot = obj["AI_heading"].createTransform();

		obj.AI_fpv_trans = obj["FPV"].createTransform();
		obj.AI_fpv_rot = obj["FPV"].createTransform();
		
		obj.AI_fpd_trans = obj["FPD"].createTransform();
		obj.AI_fpd_rot = obj["FPD"].createTransform();
		
		obj.page = obj.group;
		
		return obj;
	},
	getKeys: func() {
		return ["FMA_man","FMA_manmode","FMA_flxmode","FMA_flxtemp","FMA_thrust","FMA_lvrclb","FMA_pitch","FMA_pitcharm","FMA_pitcharm2","FMA_roll","FMA_rollarm","FMA_combined","FMA_ctr_msg","FMA_catmode","FMA_cattype","FMA_nodh","FMA_dh","FMA_dhn","FMA_ap",
		"FMA_fd","FMA_athr","FMA_man_box","FMA_flx_box","FMA_thrust_box","FMA_pitch_box","FMA_pitcharm_box","FMA_roll_box","FMA_rollarm_box","FMA_combined_box","FMA_catmode_box","FMA_cattype_box","FMA_cat_box","FMA_dh_box","FMA_ap_box","FMA_fd_box",
		"FMA_athr_box","FMA_Middle1","FMA_Middle2","ALPHA_MAX","ALPHA_PROT","ALPHA_SW","ALPHA_bars","VLS_min","ASI_max","ASI_scale","ASI_target","ASI_mach","ASI_trend_up","ASI_trend_down","ASI_digit_UP","ASI_digit_DN","ASI_decimal_UP",
		"ASI_decimal_DN","ASI_index","ASI_error","ASI_group","ASI_frame","AI_center","AI_bank","AI_bank_lim","AI_bank_lim_X","AI_pitch_lim","AI_pitch_lim_X","AI_slipskid","AI_horizon","AI_horizon_ground","AI_horizon_sky","AI_stick","AI_stick_pos","AI_heading",
		"AI_agl_g","AI_agl","AI_error","AI_group","FD_roll","FD_pitch","ALT_box_flash","ALT_box","ALT_box_amber","ALT_scale","ALT_target","ALT_target_digit","ALT_one","ALT_two","ALT_three","ALT_four","ALT_five","ALT_tens","ALT_digit_UP","ALT_tapes","ALT_hundreds",
		"ALT_thousands","ALT_thousands_zero","ALT_tenthousands","ALT_digit_DN","ALT_digit_UP_metric","ALT_error","ALT_neg","ALT_group","ALT_group2","ALT_frame","VS_pointer","VS_box","VS_digit","VS_error","VS_group","QNH","QNH_setting","QNH_std","QNH_box",
		"LOC_pointer","LOC_scale","GS_scale","GS_pointer","CRS_pointer","HDG_target","HDG_scale","HDG_one","HDG_two","HDG_three","HDG_four","HDG_five","HDG_six","HDG_seven","HDG_digit_L","HDG_digit_R","HDG_error","HDG_group","HDG_frame","TRK_pointer","machError",
		"ilsError","ils_code","ils_freq","dme_dist","dme_dist_legend","ILS_HDG_R","ILS_HDG_L","ILS_right","ILS_left","outerMarker","middleMarker","innerMarker","v1_group","v1_text","vr_speed","F_target","S_target","FS_targets","flap_max","clean_speed","ground",
		"ground_ref","FPV","FPD","spdLimError","vsFMArate","tailstrikeInd","Metric_box","Metric_letter","Metric_cur_alt","ASI_buss","ASI_buss_ref","ASI_buss_ref_blue"];
	},
	getKeysTest: func() {
		return ["Test_white","Test_text"];
	},
	getKeysMismatch: func() {
		return ["Error_Code"];
	},
	showMetricAlt: 0,
	onsideADIRSOperating: 0,
	update: func(notification) {
		me.updatePower(notification);
		
		if (me.mismatch.getVisible() == 1) {
			me.updateMismatch(notification);
			return;
		}
		
		if (me.test.getVisible() == 1) {
			me.updateTest(notification);
		}
		
		if (me.group.getVisible() == 0) {
			return;
		}
		
		# Errors
		if (systems.ADIRS.ADIRunits[(me.number == 0 ? 0 : 1)].operating == 1 or (systems.ADIRS.ADIRunits[2].operating == 1 and notification.attSwitch == (me.number == 0 ? -1 : 1))) {
			me.onsideADIRSOperating = 1;
		} else {
			me.onsideADIRSOperating = 0;
		}
		
		if (me.onsideADIRSOperating) {
			me["AI_group"].show();
			me["HDG_group"].show();
			me["AI_error"].hide();
			me["HDG_error"].hide();
			me["HDG_frame"].setColor(1,1,1);
			me["VS_group"].show();
			me["VS_error"].hide(); # VS is inertial-sourced
		} else {
			me["AI_error"].show();
			me["HDG_error"].show();
			me["HDG_frame"].setColor(1,0,0);
			me["AI_group"].hide();
			me["HDG_group"].hide();
			me["VS_error"].show();
			me["VS_group"].hide();
		}
		
		notification.aoaPFD = (me.number == 0 ? me.getAOAForPFD1() : me.getAOAForPFD2());
		notification.middleOffset = me.middleOffset;
		
		# FPV
		if (notification.trkFpa) {
			if (notification.aoaPFD == nil or !me.onsideADIRSOperating){
				me["FPV"].hide();
			} else {
				me["FPV"].show();
			}
		} else {
			me["FPV"].hide();
		}
		
		# ILS
		if (((me.number == 0 and notification.pfdILS1 == 0) or (me.number == 1 and notification.pfdILS2 == 0)) and (notification.apprArmed or notification.locArmed or notification.autopilotVert == 2)) {
			if (me.number == 0 and ils_going1 == 0) {
				ils_going1 = 1;
				ilsTimer1.start();
			} else if (me.number == 1 and ils_going2 == 0) {
				ils_going2 = 1;
				ilsTimer2.start();
			}
			
			if ((me.number == 0 and ils_going1 == 1) and (me.number == 1 and ils_going2 == 1)) {
				if (ilsFlash[me.number]) {
					me["ilsError"].show();	
				} else {
					me["ilsError"].hide();	
				}
			}
		} else {
			if (me.number == 0) {
				ilsTimer1.stop();
				ils_going1 = 0;
			} else {
				ilsTimer2.stop();
				ils_going2 = 0;
			}
			me["ilsError"].hide();
		}
		
		# Airspeed
		if (dmc.DMController.DMCs[me.number].outputs[0] != nil) {
			me.ind_spd = dmc.DMController.DMCs[me.number].outputs[0].getValue();
			notification.ind_spd = me.ind_spd;
			notification.speedError = 0;
			
			if (me.ind_spd <= 30) {
				notification.ASI = 0;
			} else if (me.ind_spd >= 420) {
				notification.ASI = 390;
			} else {
				notification.ASI = me.ind_spd - 30;
			}
			
			if (fmgc.FMGCInternal.maxspeed <= 30) {
				notification.ASImax = 0 - notification.ASI;
			} else if (fmgc.FMGCInternal.maxspeed >= 420) {
				notification.ASImax = 390 - notification.ASI;
			} else {
				notification.ASImax = fmgc.FMGCInternal.maxspeed - 30 - notification.ASI;
			}
			
			if (fmgc.FMGCInternal.v1set) {
				if (fmgc.FMGCInternal.v1 <= 30) {
					notification.V1trgt = 0 - notification.ASI;
				} else if (fmgc.FMGCInternal.v1 >= 420) {
					notification.V1trgt = 390 - notification.ASI;
				} else {
					notification.V1trgt = fmgc.FMGCInternal.v1 - 30 - notification.ASI;
				}
			
				notification.SPDv1trgtdiff = fmgc.FMGCInternal.v1 - me.ind_spd;
				notification.showV1 = 1;
			} else {
				notification.V1trgt = 0;
				notification.SPDv1trgtdiff = 0;
				notification.showV1 = 0;
			}
			
			if (fmgc.FMGCInternal.vrset) {
				if (fmgc.FMGCInternal.vr <= 30) {
					notification.VRtrgt = 0 - notification.ASI;
				} else if (fmgc.FMGCInternal.vr >= 420) {
					notification.VRtrgt = 390 - notification.ASI;
				} else {
					notification.VRtrgt = fmgc.FMGCInternal.vr - 30 - notification.ASI;
				}
			
				notification.SPDvrtrgtdiff = fmgc.FMGCInternal.vr - me.ind_spd;
				notification.showVr = 1;
			} else {
				notification.VRtrgt = 0;
				notification.SPDvrtrgtdiff = 0;
				notification.showVr = 0;
			}
			
			if (fmgc.FMGCInternal.v2set) {
				if (fmgc.FMGCInternal.v2 <= 30) {
					notification.V2trgt = 0 - notification.ASI;
				} else if (fmgc.FMGCInternal.v2 >= 420) {
					notification.V2trgt = 390 - notification.ASI;
				} else {
					notification.V2trgt = fmgc.FMGCInternal.v2 - 30 - notification.ASI;
				}
			
				notification.SPDv2trgtdiff = fmgc.FMGCInternal.v2 - me.ind_spd;
				notification.showV2 = 1;
			} else {
				notification.V2trgt = 0;
				notification.SPDv2trgtdiff = 0;
				notification.showV2 = 0;
			}
			
			if (notification.fac1 or notification.fac2) {
				if (notification.flapsInput == 1) {
					if (fmgc.FMGCInternal.slat <= 30) {
						notification.Strgt = 0 - notification.ASI;
					} else if (fmgc.FMGCInternal.slat >= 420) {
						notification.Strgt = 390 - notification.ASI;
					} else {
						notification.Strgt = fmgc.FMGCInternal.slat - 30 - notification.ASI;
					}
				
					notification.SPDstrgtdiff = fmgc.FMGCInternal.slat - me.ind_spd;
					notification.flapMaxSpeed = 200;
				} else if (notification.flapsInput == 2) {
					if (fmgc.FMGCInternal.flap2 <= 30) {
						notification.Ftrgt = 0 - notification.ASI;
					} else if (fmgc.FMGCInternal.flap2 >= 420) {
						notification.Ftrgt = 390 - notification.ASI;
					} else {
						notification.Ftrgt = fmgc.FMGCInternal.flap2 - 30 - notification.ASI;
					}
				
					notification.SPDftrgtdiff = fmgc.FMGCInternal.flap2 - me.ind_spd;
					notification.flapMaxSpeed = 185;
				} else if (notification.flapsInput == 3) {
					if (fmgc.FMGCInternal.flap3 <= 30) {
						notification.Ftrgt = 0 - notification.ASI;
					} else if (fmgc.FMGCInternal.flap3 >= 420) {
						notification.Ftrgt = 390 - notification.ASI;
					} else {
						notification.Ftrgt = fmgc.FMGCInternal.flap3 - 30 - notification.ASI;
					}
				
					notification.SPDftrgtdiff = fmgc.FMGCInternal.flap3 - me.ind_spd;
					notification.flapMaxSpeed = 177;
				} else if (notification.flapsInput == 0) {
					notification.Ctrgt = fmgc.FMGCInternal.clean - 30 - notification.ASI;
					
					notification.SPDcleantrgtdiff = fmgc.FMGCInternal.clean - me.ind_spd;
					notification.flapMaxSpeed = 230;
				}
			} else {
				notification.SPDcleantrgtdiff = 0;
				notification.SPDftrgtdiff = 0;
				notification.SPDstrgtdiff = 0;
				notification.Strgt = 0;
				notification.Ftrgt = 0;
				notification.Ctrgt = 0;
				notification.flapMaxSpeed = 0;
			}
			
			if (!fmgc.FMGCNodes.toState.getValue() and fmgc.FMGCInternal.phase >= 1 and !notification.gear1Wow and !notification.gear2Wow) {
				if (notification.vls <= 30) {
					notification.VLSmin = 0 - notification.ASI;
				} else if (notification.vls >= 420) {
					notification.VLSmin = 390 - notification.ASI;
				} else {
					notification.VLSmin = notification.vls - 30 - notification.ASI;
				}
				
				if (notification.valphaProt <= 30) {
					notification.ALPHAprot = 0 - notification.ASI;
				} else if (notification.valphaProt >= 420) {
					notification.ALPHAprot = 390 - notification.ASI;
				} else {
					notification.ALPHAprot = notification.valphaProt - 30 - notification.ASI;
				}
				
				if (notification.valphaMax <= 30) {
					notification.ALPHAmax = 0 - notification.ASI;
				} else if (notification.valphaMax >= 420) {
					notification.ALPHAmax = 390 - notification.ASI;
				} else {
					notification.ALPHAmax = notification.valphaMax - 30 - notification.ASI;
				}
				
				if (notification.vsw <= 30) {
					notification.ALPHAvsw = 0 - notification.ASI;
				} else if (notification.vsw >= 420) {
					notification.ALPHAvsw = 390 - notification.ASI;
				} else {
					notification.ALPHAvsw = notification.vsw - 30 - notification.ASI;
				}
			} else {
				notification.ALPHAprot = 0;
				notification.ALPHAmax = 0;
				notification.ALPHAvsw = 0;
				notification.VLSmin = 0;
			}
			
			
			me.tgt_ias = notification.targetIasPFD;
			me.tgt_kts = notification.targetKts;

			if (notification.managedSpd) {
				if (fmgc.FMGCInternal.decel) {
					me.tgt_ias = fmgc.FMGCInternal.minspeed;
					me.tgt_kts = fmgc.FMGCInternal.minspeed;
				} else if (fmgc.FMGCInternal.phase == 6) {
					me.tgt_ias = fmgc.FMGCInternal.clean;
					me.tgt_kts = fmgc.FMGCInternal.clean;
				}
			}

			notification.tgt_kts = me.tgt_kts;
			
			if (me.tgt_ias <= 30) {
				notification.ASItrgt = 0 - notification.ASI;
			} else if (me.tgt_ias >= 420) {
				notification.ASItrgt = 390 - notification.ASI;
			} else {
				notification.ASItrgt = me.tgt_ias - 30 - notification.ASI;
			}
			
			notification.ASItrgtdiff = me.tgt_ias - notification.ind_spd;
			
			notification.ASItrend = dmc.DMController.DMCs[me.number].outputs[6].getValue() - notification.ASI;
			if (notification.ASItrend >= 2 or (me.ASItrendIsShown != 0 and notification.ASItrend >= 1)) {
				me.ASItrendIsShown = 1;
			} else if (notification.ASItrend <= -2 or (me.ASItrendIsShown != 0 and notification.ASItrend <= -1)) {
				me.ASItrendIsShown = -1;
			} else {
				me.ASItrendIsShown = 0;
			}
			notification.ASItrendIsShown = me.ASItrendIsShown;
			
			if (me.temporaryNodes.showGroundReferenceAGL) {
				me["ground_ref"].show();
			} else {
				me["ground_ref"].hide();
			}
		} else {
			notification.ind_spd = 0;
			notification.speedError = 1;
			
			if (!systems.ADIRS.Operating.adr[0].getValue() and !systems.ADIRS.Operating.adr[1].getValue() and !systems.ADIRS.Operating.adr[2].getValue()) {
				me["ASI_buss"].show();
				me["ASI_buss_ref"].show();
				me["ASI_buss_ref_blue"].show();
				me["ASI_error"].hide();
			} else {
				me["ASI_buss"].hide();
				me["ASI_buss_ref"].hide();
				me["ASI_buss_ref_blue"].hide();
				me["ASI_error"].show();
			}
			
			notification.ASI = 0;
			notification.ASImax = 0;
			notification.ASItrgt = 0;
			notification.ASItrgtdiff = 0;
			notification.ASItrend = 0;
			notification.ALPHAprot = 0;
			notification.ALPHAmax = 0;
			notification.ALPHAvsw = 0;
			notification.ASItrendIsShown = 0;
			notification.Ctrgt = 0;
			notification.flapMaxSpeed = 0;
			notification.Ftrgt = 0;
			notification.Strgt = 0;
			notification.showV1 = 0;
			notification.showVr = 0;
			notification.showV2 = 0;
			notification.SPDcleantrgtdiff = 0;
			notification.SPDftrgtdiff = 0;
			notification.SPDstrgtdiff = 0;
			notification.SPDv1trgtdiff = 0;
			notification.SPDvrtrgtdiff = 0;
			notification.SPDv2trgtdiff = 0;
			notification.tgt_kts = 0;
			notification.V1trgt = 0;
			notification.VRtrgt = 0;
			notification.V2trgt = 0;
			notification.VLSmin = 0;
		}
		
		# Mach	
		if (dmc.DMController.DMCs[me.number].outputs[2] != nil) {
			notification.ind_mach = dmc.DMController.DMCs[me.number].outputs[2].getValue();
			notification.machError = 0;
		} else {
			notification.machError = 1;
		}
		
		# Altitude
		notification.showMetric = me.showMetricAlt;
		
		if (dmc.DMController.DMCs[me.number].outputs[1] != nil) {
			notification.altError = 0;
			notification.altitudePFD = dmc.DMController.DMCs[me.number].outputs[1].getValue();
			notification.altitudeDifference = dmc.DMController.DMCs[me.number].outputs[7].getValue();
			
			if (!ecam.altAlertFlash and !ecam.altAlertSteady) {
				if (me.number == 0) {
					alt_going1 = 0;
					amber_going1 = 0;
				} else {
					alt_going2 = 0;
					amber_going2 = 0;
				}
				me["ALT_box"].show();
				me["ALT_box_flash"].hide();
				me["ALT_box_amber"].hide();
			} else {
				if (ecam.altAlertFlash) {
					# Cancel steady alert
					if (me.number == 0) {
						if (alt_going1 == 1) {
							me["ALT_box_flash"].hide(); 
							altTimer1.stop();
							alt_going1 = 0;
						}
					} else {
						if (alt_going2 == 1) {
							me["ALT_box_flash"].hide(); 
							altTimer2.stop();
							alt_going2 = 0;
						}
					}
					
					if (me.number == 0 and amber_going1 == 0) {
						amber_going1 = 1;
						amberTimer1.start();
					} else if (me.number == 1 and amber_going2 == 0) {
						amber_going2 = 1;
						amberTimer2.start();
					}
					
					if ((me.number == 0 and amber_going1) or (me.number == 1 and amber_going2)) {
						if (amberFlash[me.number]) {
							me["ALT_box_amber"].hide(); 
						} else {
							me["ALT_box_amber"].show(); 
						}
						me["ALT_box"].hide();
					}
				} elsif (ecam.altAlertSteady) {
					# Cancel any flash alert
					if (me.number == 0) {
						if (amber_going1 == 1) {
							me["ALT_box"].show();
							me["ALT_box_amber"].hide();
							amberTimer1.stop();
							amber_going1 = 0;
						}
					} else {
						if (amber_going2 == 1) {
							me["ALT_box"].show();
							me["ALT_box_amber"].hide();
							amberTimer2.stop();
							amber_going2 = 0;
						}
					}
					
					if (me.number == 0 and alt_going1 == 0) {
						alt_going1 = 1;
						altTimer1.start();
					} else if (me.number == 1 and alt_going2 == 0) {
						alt_going2 = 1;
						altTimer2.start();
					}
					
					if ((me.number == 0 and alt_going1 == 1) or (me.number == 1 and alt_going2 == 1)) {
						if (altFlash[me.number]) {
							me["ALT_box_flash"].show(); 
						} else {
							me["ALT_box_flash"].hide(); 
						}
					}
				}
			}
		} else {
			notification.altError = 1;
			notification.altitudePFD = -9999;
			notification.altitudeDifference = -9999;
		}
		
		if (fmgc.Modes.PFD.FMA.pitchMode == "LAND" or fmgc.Modes.PFD.FMA.pitchMode == "FLARE" or fmgc.Modes.PFD.FMA.pitchMode == "ROLL OUT") {
			if (fmgc.Modes.PFD.FMA.pitchMode == "LAND") {
				autoland_pitch_land.setBoolValue(1);
			} else {
				autoland_pitch_land.setBoolValue(0);
			}
			
			if (ecam.directLaw.active) {
				me["FMA_ctr_msg"].setText("USE MAN PITCH TRIM");
				me["FMA_ctr_msg"].setColor(0.7333,0.3803,0);
				me["FMA_ctr_msg"].show();
			} else if (notification.fbwLaw == 3) {
				me["FMA_ctr_msg"].setText("MAN PITCH TRIM ONLY");
				me["FMA_ctr_msg"].setColor(1,0,0);
				me["FMA_ctr_msg"].show();
			} else {
				me["FMA_ctr_msg"].hide();
			}
		} else {
			if (ecam.directLaw.active) {
				me["FMA_ctr_msg"].setText("USE MAN PITCH TRIM");
				me["FMA_ctr_msg"].setColor(0.7333,0.3803,0);
				me["FMA_Middle1"].hide();
				me["FMA_Middle2"].show();
				me["FMA_ctr_msg"].show();
			} else if (notification.fbwLaw == 3) {
				me["FMA_ctr_msg"].setText("MAN PITCH TRIM ONLY");
				me["FMA_ctr_msg"].setColor(1,0,0);
				me["FMA_Middle1"].hide();
				me["FMA_Middle2"].show();
				me["FMA_ctr_msg"].show();
			} else {
				me["FMA_ctr_msg"].hide();
				me["FMA_Middle1"].show();
				me["FMA_Middle2"].hide();
			}
		}
		
		if (notification.athr and (notification.thrust1 == "TOGA" or notification.thrust1 == "MCT" or notification.thrust1 == "MAN THR" or notification.thrust2 == "TOGA" or notification.thrust2 == "MCT" or notification.thrust2 == "MAN THR") and notification.engOut != 1 and notification.alphaFloor != 1 and 
		notification.togaLk != 1) {
			me["FMA_man"].show();
			if (notification.thrust1 == "TOGA" or notification.thrust2 == "TOGA") {
				me["FMA_flx_box"].hide();
				me["FMA_flxtemp"].hide();
				me["FMA_man_box"].show();
				me["FMA_manmode"].show();
				me["FMA_flxmode"].hide();
				me["FMA_manmode"].setText("TOGA");
				me["FMA_man_box"].setColor(0.8078,0.8039,0.8078);
			} else if ((notification.thrust1 == "MAN THR" and systems.FADEC.manThrAboveMct[0]) or (notification.thrust2 == "MAN THR" and systems.FADEC.manThrAboveMct[1])) {
				me["FMA_flx_box"].hide();
				me["FMA_flxtemp"].hide();
				me["FMA_man_box"].show();
				me["FMA_manmode"].show();
				me["FMA_flxmode"].hide();
				me["FMA_manmode"].setText("THR");
				me["FMA_man_box"].setColor(0.7333,0.3803,0);
			} else if ((notification.thrust1 == "MCT" or notification.thrust2 == "MCT") and notification.thrustLimit != "FLX") {
				me["FMA_flx_box"].hide();
				me["FMA_flxtemp"].hide();
				me["FMA_man_box"].show();
				me["FMA_manmode"].show();
				me["FMA_flxmode"].hide();
				me["FMA_manmode"].setText("MCT");
				me["FMA_man_box"].setColor(0.8078,0.8039,0.8078);
			} else if ((notification.thrust1 == "MCT" or notification.thrust2 == "MCT") and notification.thrustLimit == "FLX") {
				me["FMA_man_box"].hide();
				me["FMA_flx_box"].show();
				me["FMA_flxtemp"].show();
				me["FMA_manmode"].hide();
				me["FMA_flxmode"].show();
				me["FMA_man_box"].setColor(0.8078,0.8039,0.8078);
			} else if ((notification.thrust1 == "MAN THR" and !systems.FADEC.manThrAboveMct[0]) or (notification.thrust2 == "MAN THR" and !systems.FADEC.manThrAboveMct[1])) {
				me["FMA_flx_box"].hide();
				me["FMA_flxtemp"].hide();
				me["FMA_man_box"].show();
				me["FMA_manmode"].show();
				me["FMA_flxmode"].hide();
				me["FMA_manmode"].setText("THR");
				me["FMA_man_box"].setColor(0.7333,0.3803,0);
			}
		} else if (notification.athr and (notification.thrust1 == "TOGA" or (notification.thrust1 == "MCT" and notification.thrustLimit == "FLX") or (notification.thrust1 == "MAN THR" and systems.FADEC.manThrAboveMct[0]) or notification.thrust2 == "TOGA" or (notification.thrust2 == "MCT" and 
		notification.thrustLimit == "FLX") or (notification.thrust2 == "MAN THR" and systems.FADEC.manThrAboveMct[1])) and notification.engOut and notification.alphaFloor != 1 and notification.togaLk != 1) {
			me["FMA_man"].show();
			if (notification.thrust1 == "TOGA" or notification.thrust2 == "TOGA") {
				me["FMA_flx_box"].hide();
				me["FMA_flxtemp"].hide();
				me["FMA_man_box"].show();
				me["FMA_manmode"].show();
				me["FMA_flxmode"].hide();
				me["FMA_manmode"].setText("TOGA");
				me["FMA_man_box"].setColor(0.8078,0.8039,0.8078);
			} else if ((notification.thrust1 == "MAN THR" and systems.FADEC.manThrAboveMct[0]) or (notification.thrust2 == "MAN THR" and systems.FADEC.manThrAboveMct[1])) {
				me["FMA_flx_box"].hide();
				me["FMA_flxtemp"].hide();
				me["FMA_man_box"].show();
				me["FMA_manmode"].show();
				me["FMA_flxmode"].hide();
				me["FMA_manmode"].setText("THR");
				me["FMA_man_box"].setColor(0.7333,0.3803,0);
			} else if ((notification.thrust1 == "MCT" or notification.thrust2 == "MCT") and notification.thrustLimit == "FLX") {
				me["FMA_man_box"].hide();
				me["FMA_flx_box"].show();
				me["FMA_flxtemp"].show();
				me["FMA_manmode"].hide();
				me["FMA_flxmode"].show();
				me["FMA_man_box"].setColor(0.8078,0.8039,0.8078);
			}
		} else {
			me["FMA_man"].hide();
			me["FMA_manmode"].hide();
			me["FMA_man_box"].hide();
			me["FMA_flx_box"].hide();
			me["FMA_flxtemp"].hide();
			me["FMA_flxmode"].hide();
		}
			
		if (notification.alphaFloor != 1 and notification.togaLk != 1) {
			if (notification.athr and notification.engOut != 1 and (notification.thrust1 == "MAN" or notification.thrust1 == "CL") and (notification.thrust2 == "MAN" or notification.thrust2 == "CL")) {
				me["FMA_thrust"].show();
				if (fmgc.Modes.PFD.FMA.throttleModeBox and fmgc.Modes.PFD.FMA.throttleMode != " ") {
					me["FMA_thrust_box"].show();
				} else {
					me["FMA_thrust_box"].hide();
				}
			} else if (notification.athr and notification.engOut and (notification.thrust1 == "MAN" or notification.thrust1 == "CL" or (notification.thrust1 == "MAN THR" and !systems.FADEC.manThrAboveMct[0]) or (notification.thrust1 == "MCT" and notification.thrustLimit != "FLX")) and 
			(notification.thrust2 == "MAN" or notification.thrust2 == "CL" or (notification.thrust2 == "MAN THR" and !systems.FADEC.manThrAboveMct[1]) or (notification.thrust2 == "MCT" and notification.thrustLimit != "FLX"))) {
				me["FMA_thrust"].show();
				if (fmgc.Modes.PFD.FMA.throttleModeBox and fmgc.Modes.PFD.FMA.throttleMode != " ") {
					me["FMA_thrust_box"].show();
				} else {
					me["FMA_thrust_box"].hide();
				}
			} else {
				me["FMA_thrust"].hide();
				me["FMA_thrust_box"].hide();
			}
		} else {
			me["FMA_thrust"].show();
			if (notification.alphaFloor) {
				if (!afloor_going) {
					aFloorTimer.start();
					afloor_going = 1;
				}
				
				if (aFloorFlash and afloor_going) {
					me["FMA_thrust_box"].show();
				} else {
					me["FMA_thrust_box"].hide();
				}
			} else {
				aFloorTimer.stop();
				afloor_going = 0;
			
			}
			if (notification.togaLk) {
				if (!togalk_going) {
					togaLkTimer.start();
					togalk_going = 1;
				}
				
				if (togaLkFlash and togalk_going) {
					me["FMA_thrust_box"].show();
				} else {
					me["FMA_thrust_box"].hide();
				}
			} else {
				togaLkTimer.stop();
				togalk_going = 0;
			
			}
		}
		
		notification.radioNo = fmgc.FMGCInternal.radioNo;
		if (fmgc.FMGCInternal.phase < 3 or fmgc.flightPlanController.arrivalDist.getValue() >= 250) {
			notification.showDecisionHeight = 0;
		} else {
			notification.showDecisionHeight = 1;
		}
		
		if (notification.altimeterStd == 1) {
			if (notification.altitudePFD < fmgc.FMGCInternal.transAlt and fmgc.FMGCInternal.phase == 4) {
				if (me.number == 0) {
					if (qnh_going1 == 0) {
						qnhTimer1.start();
						qnh_going1 = 1;
					}
				} else {
					if (qnh_going2 == 0) {
						qnhTimer2.start();
						qnh_going2 = 1;
					}
				}
				
				if ((me.number == 0 and qnh_going1) or (me.number == 1 and qnh_going2)) {
					if (qnhFlash[me.number]) {
						me["QNH_std"].show();
						me["QNH_box"].show();
					} else {
						me["QNH_std"].hide();
						me["QNH_box"].hide();
					}
				}
			} else {
				if (me.number == 0) {
					qnhTimer1.stop();
					qnh_going1 = 0;
				} else {
					qnhTimer2.stop();
					qnh_going2 = 0;
				}
				me["QNH_std"].show();
				me["QNH_box"].show();
			}
		} else {
			if (notification.altitudePFD >= fmgc.FMGCInternal.transAlt and fmgc.FMGCInternal.phase == 2) {
				if (me.number == 0) {
					if (qnh_going1 == 0) {
						qnhTimer1.start();
						qnh_going1 = 1;
					}
				} else {
					if (qnh_going2 == 0) {
						qnhTimer2.start();
						qnh_going2 = 1;
					}
				}
				
				if ((me.number == 0 and qnh_going1) or (me.number == 1 and qnh_going2)) {
					if (qnhFlash[me.number]) {
						me["QNH"].show();
						me["QNH_setting"].show();
					} else {
						me["QNH"].hide();
						me["QNH_setting"].hide();
					}
				}
			} else {
				if (me.number == 0) {
					qnhTimer1.stop();
					qnh_going1 = 0;
				} else {
					qnhTimer2.stop();
					qnh_going2 = 0;
				}
				me["QNH"].show();
				me["QNH_setting"].show();
			}
		}
		
		me.split_ils = split("/", fmgc.FMGCInternal.ILS.mcdu);
		if ((me.number == 0 and notification.pfdILS1) or (me.number == 1 and notification.pfdILS2)) {
			if (size(me.split_ils) < 2) {
				me["ils_freq"].setText(me.split_ils[0]);
				me["ils_freq"].show();
				me["ils_code"].hide();
				me["dme_dist"].hide();
				me["dme_dist_legend"].hide();
			} else {
				me["ils_code"].setText(me.split_ils[0]);
				me["ils_freq"].setText(me.split_ils[1]);
				me["ils_code"].show();
				me["ils_freq"].show();
				
				if (notification.dmeInRange) {
					me["dme_dist"].show();
					me["dme_dist_legend"].show();
				} else {
					me["dme_dist"].hide();
					me["dme_dist_legend"].hide();
				}
			}
		} else {
			me["ils_code"].hide();
			me["ils_freq"].hide();
			me["dme_dist"].hide();
			me["dme_dist_legend"].hide();
		}
		
		if (((me.number == 0 and notification.pfdILS1) or (me.number == 1 and notification.pfdILS2)) and size(me.split_ils) == 2) {
			notification.showPFDILS = 1;
			notification.magnetic_hdg_dif = geo.normdeg180(notification.ilsCrs - notification.headingPFD);
		} else {
			notification.showPFDILS = 0;
			notification.magnetic_hdg_dif = 0;
		}
		
		if (me.temporaryNodes.showGroundReferenceAGL) {
			if ((notification.fmgcPhase == 5 or notification.fmgcPhase == 6) and !notification.gear1Wow and !notification.gear2Wow) { # TODO: add std too
				me["ground"].show();
			} else {
				me["ground"].hide();
			}
		} else {
			me["ground"].hide();
		}
		
		if (me.temporaryNodes.showTailstrikeAGL and me.temporaryNodes.showTailstrikeGroundspeed and me.temporaryNodes.showTailstrikeThrust) {
			me["tailstrikeInd"].show();
		} else {
			me["tailstrikeInd"].hide();
		}
		
		
		# FMA
		me["FMA_lvrclb"].setText(systems.FADEC.lvrClbType);
		
		me["FMA_ap"].setText(sprintf("%s", fmgc.Modes.PFD.FMA.apMode));
		if (fmgc.Modes.PFD.FMA.apModeBox and fmgc.Modes.PFD.FMA.apMode != " ") {
			me["FMA_ap_box"].show();
		} else {
			me["FMA_ap_box"].hide();
		}
		
		me["FMA_athr"].setText(sprintf("%s", fmgc.Modes.PFD.FMA.athrMode));
		if (fmgc.Modes.PFD.FMA.athrModeBox and fmgc.Modes.PFD.FMA.athrMode != " ") {
			me["FMA_athr_box"].show();
		} else {
			me["FMA_athr_box"].hide();
		}
		
		me["FMA_fd"].setText(sprintf("%s", fmgc.Modes.PFD.FMA.fdMode));
		if (fmgc.Modes.PFD.FMA.fdModeBox and fmgc.Modes.PFD.FMA.fdMode != " ") {
			me["FMA_fd_box"].show();
		} else {
			me["FMA_fd_box"].hide();
		}
		
		if (fmgc.Modes.PFD.FMA.athrArmed != 1) {
			me["FMA_athr"].setColor(0.8078,0.8039,0.8078);
		} else {
			me["FMA_athr"].setColor(0.0901,0.6039,0.7176);
		}
		
		me["FMA_roll"].setText(sprintf("%s", fmgc.Modes.PFD.FMA.rollMode));
		me["FMA_rollarm"].setText(sprintf("%s", fmgc.Modes.PFD.FMA.rollModeArmed));
		me["FMA_combined"].setText(sprintf("%s", fmgc.Modes.PFD.FMA.pitchMode));
		me["FMA_pitcharm"].setText(sprintf("%s", fmgc.Modes.PFD.FMA.pitchModeArmed));
		me["FMA_pitcharm2"].setText(sprintf("%s", fmgc.Modes.PFD.FMA.pitchMode2Armed));
		
		if (fmgc.Modes.PFD.FMA.pitchMode == "V/S") {
			me["FMA_pitch"].setText(sprintf("%s       ", fmgc.Modes.PFD.FMA.pitchMode));
			me["vsFMArate"].setText(sprintf("%+4.0f",notification.autopilotVS));
			me["vsFMArate"].show();
		} elsif (fmgc.Modes.PFD.FMA.pitchMode == "FPA") {
			me["FMA_pitch"].setText(sprintf("%s       ", fmgc.Modes.PFD.FMA.pitchMode));
			me["vsFMArate"].setText(sprintf("%+3.1f°",notification.autopilotFPA));
			me["vsFMArate"].show();
		} else {
			me["FMA_pitch"].setText(sprintf("%s", fmgc.Modes.PFD.FMA.pitchMode));
			me["vsFMArate"].hide();
		}
		
		
		if (fmgc.Modes.PFD.FMA.pitchMode == "LAND" or fmgc.Modes.PFD.FMA.pitchMode == "FLARE" or fmgc.Modes.PFD.FMA.pitchMode == "ROLL OUT") {
			me["FMA_pitch"].hide();
			me["FMA_roll"].hide();
			me["FMA_pitch_box"].hide();
			me["FMA_roll_box"].hide();
			me["FMA_pitcharm_box"].hide();
			me["FMA_rollarm_box"].hide();
			me["FMA_Middle1"].hide();
			me["FMA_Middle2"].hide();
			me["FMA_combined"].show();
			
			if (fmgc.Modes.PFD.FMA.pitchModeBox and fmgc.Modes.PFD.FMA.pitchMode != " ") {
				me["FMA_combined_box"].show();
			} else {
				me["FMA_combined_box"].hide();
			}
		} else {
			me["FMA_combined"].hide();
			me["FMA_combined_box"].hide();
			if ((notification.ap1 or notification.ap2) and (fmgc.Modes.PFD.FMA.pitchMode == "V/S" or fmgc.Modes.PFD.FMA.pitchMode == "FPA") and (notification.overspeedVsProt or notification.underspeedVsProt)) {
				me.amberBoxVS = 1;
			} else {
				me.amberBoxVS = 0;
			}
			
			if ((me.amberBoxVS or fmgc.Modes.PFD.FMA.pitchModeBox) and fmgc.Modes.PFD.FMA.pitchMode != " " and (notification.ap1 or notification.ap2 or notification.fd1 or notification.fd2)) {
				if (me.amberBoxVS) {
					me["FMA_pitch_box"].setColor(0.7333,0.3803,0.0000);
					if (me.number == 0 and vs_going1 == 0) {
						vs_going1 = 1;
						vsTimer1.start();
					} else if (me.number == 1 and vs_going2 == 0) {
						vs_going2 = 1;
						vsTimer2.start();
					}
					
					if ((me.number == 0 and vs_going1 == 1) and (me.number == 0 and vs_going2 == 1)) {
						if (vsFlash[me.number]) {
							me["FMA_pitch_box"].show();
						} else {
							me["FMA_pitch_box"].hide();
						}
					}
				} else {
					me["FMA_pitch_box"].setColor(1,1,1);
					me["FMA_pitch_box"].show();
				}
			} else {
				me["FMA_pitch_box"].hide();
				vs_going1 = 0;
				vsTimer1.stop();
				vs_going2 = 0;
				vsTimer2.stop();
			}
			
			if (fmgc.Modes.PFD.FMA.pitchModeArmed == " " and fmgc.Modes.PFD.FMA.pitchMode2Armed == " ") {
				me["FMA_pitcharm_box"].hide();
			} else {
				if ((fmgc.Modes.PFD.FMA.pitchModeArmedBox or fmgc.Modes.PFD.FMA.pitchMode2ArmedBox) and (notification.ap1 or notification.ap2 or notification.fd1 or notification.fd2)) {
					me["FMA_pitcharm_box"].show();
				} else {
					me["FMA_pitcharm_box"].hide();
				}
			}
			
			if (fmgc.Modes.PFD.FMA.rollModeBox == 1 and fmgc.Modes.PFD.FMA.rollMode != " "  and (notification.ap1 or notification.ap2 or notification.fd1 or notification.fd2)) {
				me["FMA_roll_box"].show();
			} else {
				me["FMA_roll_box"].hide();
			}
			
			if (fmgc.Modes.PFD.FMA.rollModeArmedBox == 1 and fmgc.Modes.PFD.FMA.rollModeArmed != " " and (notification.ap1 or notification.ap2 or notification.fd1 or notification.fd2)) {
				me["FMA_rollarm_box"].show();
			} else {
				me["FMA_rollarm_box"].hide();
			}
		}
		
		if (notification.alphaFloor) {
			me["FMA_thrust"].setText("A.FLOOR");
			me["FMA_thrust_box"].setColor(0.7333,0.3803,0);
		} else if (notification.togaLk) {
			me["FMA_thrust"].setText("TOGA LK");
			me["FMA_thrust_box"].setColor(0.7333,0.3803,0);
		} else {
			me["FMA_thrust"].setText(sprintf("%s", fmgc.Modes.PFD.FMA.throttleMode));
			me["FMA_thrust_box"].setColor(0.8078,0.8039,0.8078);
		}
		
		if (((me.number == 0 and notification.fd1) or (me.number == 1 and notification.fd2)) and notification.pitchPFD < 25 and notification.pitchPFD > -13 and notification.roll < 45 and notification.roll > -45) {
			if (notification.trkFpa) {
				me["FD_roll"].hide();
				me["FD_pitch"].hide();
				
				if (fmgc.Modes.PFD.FMA.rollMode != " " and fmgc.Modes.PFD.FMA.pitchMode != " " and !notification.gear1Wow) {
					me["FPD"].show();
				} else {
					me["FPD"].hide();
				}
			} else {
				me["FPD"].hide();
				
				if (fmgc.Modes.PFD.FMA.rollMode != " " and !notification.gear1Wow) {
					me["FD_roll"].show();
				} else {
					me["FD_roll"].hide();
				}
				
				if (fmgc.Modes.PFD.FMA.pitchMode != " ") {
					me["FD_pitch"].show();
				} else {
					me["FD_pitch"].hide();
				}
			}
		} else {
			me["FPD"].hide();
			me["FD_roll"].hide();
			me["FD_pitch"].hide();
		}
		
		foreach(var update_item; me.update_items)
        {
            update_item.update(notification);
        }
		
		me["AI_heading"].update();
	},
	updateTest: func(notification) {
		if (me.number == 1) {
			if ((du6_test_time.getValue() + 1 >= notification.elapsedTime) and notification.foDuXfr != 1) {
				me["Test_white"].show();
				me["Test_text"].hide();
			} else if ((du5_test_time.getValue() + 1 >= notification.elapsedTime) and notification.foDuXfr != 0) {
				me["Test_white"].show();
				me["Test_text"].hide();
			} else {
				me["Test_white"].hide();
				me["Test_text"].show();
			}
		} else {
			if ((du1_test_time.getValue() + 1 >= notification.elapsedTime) and notification.cptDuXfr != 1) {
				me["Test_white"].show();
				me["Test_text"].hide();
			} else if ((du2_test_time.getValue() + 1 >= notification.elapsedTime) and notification.cptDuXfr != 0) {
				me["Test_white"].show();
				me["Test_text"].hide();
			} else {
				me["Test_white"].hide();
				me["Test_text"].show();
			}
		}
	},
	updateMismatch: func(notification) {
		foreach(var update_item; me.update_items_mismatch)
		{
			update_item.update(notification);
		}
	},
	off: 0,
	on: 0,
	powerNode: 0,
	offTimeNode: 0,
	testNode: 0,
	testamountNode: 0,
	powerTransient: func() {
		if (me.number == 1) {
			me.powerNode = systems.ELEC.Bus.ac2;
			me.offTimeNode = du6_offtime;
			me.testNode = du6_test;
			me.testAmountNode = du6_test_amount;
			me.testTimeNode = du6_test_time;
		} else {
			me.powerNode = systems.ELEC.Bus.acEss;
			me.offTimeNode = du1_offtime;
			me.testNode = du1_test;
			me.testAmountNode = du1_test_amount;
			me.testTimeNode = du1_test_time;
		}
		
		elapsedtime_act = pts.Sim.Time.elapsedSec.getValue();
		if (me.powerNode.getValue() >= 110) {
			if (!me.on) {
				if (me.offTimeNode.getValue() + 3 < elapsedtime_act) { 
					if (pts.Gear.wow[0].getValue()) {
						if (acconfig.getValue() != 1 and me.testNode.getValue() != 1) {
							me.testNode.setValue(1);
							me.testAmountNode.setValue(math.round((rand() * 5 ) + 35, 0.1));
							me.testTimeNode.setValue(elapsedtime_act);
						} else if (acconfig.getValue() == 1 and me.testNode.getValue() != 1) {
							me.testNode.setValue(1);
							me.testAmountNode.setValue(math.round((rand() * 5 ) + 35, 0.1));
							me.testTimeNode.setValue(elapsedtime_act - 30);
						}
					} else {
						me.testNode.setValue(1);
						me.testAmountNode.setValue(0);
						me.testTimeNode.setValue(-100);
					}
				}
				me.off = 0;
				me.on = 1;
			}
		} else {
			if (!me.off) {
				me.testNode.setValue(0);
				me.offTimeNode.setValue(elapsedtime_act);
				me.off = 1;
				me.on = 0;
			}
		}
	},
	updatePower: func(notification) {
		if (notification.acconfigMismatch == "0x000") {
			me.mismatch.setVisible(0);
			
			if (me.number == 1) {
				if (notification.elecAC2 >= 110 and notification.du6Lgt > 0.01) {
					pts.Instrumentation.Du.du6On.setBoolValue(1);
					if (du6_test_time.getValue() + du6_test_amount.getValue() >= notification.elapsedTime and notification.foDuXfr != 1) {
						me.group.setVisible(0);
						me.test.setVisible(1);
					} else if (du5_test_time.getValue() + du5_test_amount.getValue() >= notification.elapsedTime and notification.foDuXfr == 1) {
						me.group.setVisible(0);
						me.test.setVisible(1);
					} else {
						me.group.setVisible(1);
						me.test.setVisible(0);
					}
				} else {
					pts.Instrumentation.Du.du6On.setBoolValue(0);
					me.group.setVisible(0);
					me.test.setVisible(0);
				}
			} else {
				if (notification.elecACEss >= 110 and notification.du1Lgt > 0.01) {
					pts.Instrumentation.Du.du1On.setBoolValue(1);
					if (du1_test_time.getValue() + du1_test_amount.getValue() >= notification.elapsedTime and notification.cptDuXfr != 1) {
						me.group.setVisible(0);
						me.test.setVisible(1);
					} else if (du2_test_time.getValue() + du2_test_amount.getValue() >= notification.elapsedTime and notification.cptDuXfr == 1) {
						me.group.setVisible(0);
						me.test.setVisible(1);
					} else {
						me.group.setVisible(1);
						me.test.setVisible(0);
					}
				} else {
					pts.Instrumentation.Du.du1On.setBoolValue(0);
					me.group.setVisible(0);
					me.test.setVisible(0);
				}
			}
		} else {
			pts.Instrumentation.Du.du1On.setBoolValue(1);
			pts.Instrumentation.Du.du6On.setBoolValue(1);
			me.mismatch.setVisible(1);
			me.group.setVisible(0);
			me.test.setVisible(0);
		}
	},

	# Get Angle of Attack from ADR1 or, depending on Switching panel, ADR3
	getAOAForPFD1: func() {
		if (air_data_switch.getValue() != -1 and adr_1_switch.getValue() and !adr_1_fault.getValue()) return aoa_1.getValue();
		if (air_data_switch.getValue() == -1 and adr_3_switch.getValue() and !adr_3_fault.getValue()) return aoa_3.getValue();
		return 0;
	},
	
	# Get Angle of Attack from ADR2 or, depending on Switching panel, ADR3
	getAOAForPFD2: func() {
		if (air_data_switch.getValue() != 1 and adr_2_switch.getValue() and !adr_2_fault.getValue()) return aoa_2.getValue();
		if (air_data_switch.getValue() == 1 and adr_3_switch.getValue() and !adr_3_fault.getValue()) return aoa_3.getValue();
		return 0;
	},

	# Convert difference between magnetic heading and track measured in degrees to pixel for display on PFDs
	# And set max and minimum values
	getTrackDiffPixels: func(track_diff_deg) {
		return ((math.clamp(track_diff_deg, -23.62, 23.62) / 10) * 98.5416);
	},
};

var PFDRecipient =
{
	new: func(_ident, number)
	{
		var PFDRecipient = emesary.Recipient.new(_ident);
		PFDRecipient.MainScreen = nil;
		PFDRecipient.Receive = func(notification)
		{
			if (notification.NotificationType == "FrameNotification")
			{
				if (PFDRecipient.MainScreen == nil) {
					PFDRecipient.MainScreen = canvas_pfd.new("Aircraft/A320-family/Models/Instruments/PFD/res/pfd.svg", "A320 PFD", number);
				}
				if (math.mod(notifications.frameNotification.FrameCount,2) == 0) {
					PFDRecipient.MainScreen.update(notification);
				}
				return emesary.Transmitter.ReceiptStatus_OK;
			}
			return emesary.Transmitter.ReceiptStatus_NotProcessed;
		};
		return PFDRecipient;
	},
};

var A320PFD1 = PFDRecipient.new("A320 PFD", 0);
emesary.GlobalTransmitter.Register(A320PFD1);
var A320PFD2 = PFDRecipient.new("A320 PFD", 1);
emesary.GlobalTransmitter.Register(A320PFD2);

var input = {
	acconfigMismatch: "/systems/acconfig/mismatch-code",
	cptDuXfr: "/modes/cpt-du-xfr",
	foDuXfr: "/modes/fo-du-xfr",
	du1Lgt: "/controls/lighting/DU/du1",
	du6Lgt: "/controls/lighting/DU/du6",
	attSwitch: "/controls/navigation/switching/att-hdg",
	
	athr: "/it-autoflight/output/athr",
	altitudeAutopilot: "/it-autoflight/internal/alt",
	pitchPFD: "/instrumentation/pfd/pitch-deg-non-linear",
	horizonGround: "/instrumentation/pfd/horizon-ground",
	horizonPitch: "/instrumentation/pfd/horizon-pitch",
	slipSkid: "/instrumentation/pfd/slip-skid",
	fbwLaw: "/it-fbw/law",
	FDRollBar: "/it-autoflight/fd/roll-bar",
	FDPitchBar: "/it-autoflight/fd/pitch-bar",
	FPDPitch: "/it-autoflight/fd/fpd-pitch",
	vsAutopilot: "/it-autoflight/internal/vert-speed-fpm",
	vsDigit: "/instrumentation/pfd/vs-digit-trans",
	vsNeedle: "/instrumentation/pfd/vs-needle",
	vsPFD: "/it-autoflight/internal/vert-speed-fpm-pfd",
	
	trackHdgDiff: "/instrumentation/pfd/track-hdg-diff",
	headingPFD: "/instrumentation/pfd/heading-deg",
	headingScale: "/instrumentation/pfd/heading-scale",
	localizer: "/instrumentation/nav[0]/heading-needle-deflection-norm",
	glideslope: "/instrumentation/nav[0]/gs-needle-deflection-norm",
	dmeInRange: "/instrumentation/nav[0]/dme-in-range",
	dmeDistance: "/instrumentation/dme[0]/indicated-distance-nm",
	ilsCrs: "/instrumentation/nav[0]/radials/selected-deg",
	localizerInRange: "/instrumentation/nav[0]/in-range",
	glideslopeInRange: "/instrumentation/nav[0]/gs-in-range",
	signalQuality: "/instrumentation/nav[0]/signal-quality-norm",
	hasLocalizer: "/instrumentation/nav[0]/nav-loc",
	hasGlideslope: "/instrumentation/nav[0]/has-gs",
	locArmed: "/it-autoflight/output/loc-armed",
	apprArmed: "/it-autoflight/output/appr-armed",
	autopilotVert: "/it-autoflight/output/vert",
	autopilotFPA: "/it-autoflight/input/fpa",
	autopilotVS: "/it-autoflight/input/vs",
	
	aileronPFD: "/fdm/jsbsim/fbw/roll/a-i-pfd",
	elevatorPFD: "/fdm/jsbsim/fbw/pitch/e-i-pfd",
	flapsInput: "/controls/flight/flaps-input",
	
	thrustLvrClb: "/fdm/jsbsim/fadec/lvrclb",
	
	fmgcPhase: "/FMGC/internal/phase",
	fmgcTakeoffState: "/FMGC/internal/to-state",
	fd1: "/it-autoflight/output/fd1",
	fd2: "/it-autoflight/output/fd2",
	trkFpa: "/it-autoflight/custom/trk-fpa",
	
	pfdILS1: "/modes/pfd/ILS1",
	pfdILS2: "/modes/pfd/ILS2",
	
	markerO: "/instrumentation/marker-beacon/outer",
	markerM: "/instrumentation/marker-beacon/middle",
	markerI: "/instrumentation/marker-beacon/inner",
	
	altimeterStd: "/instrumentation/altimeter/std",
	altimeterInhgModeLeft: "/instrumentation/altimeter/inhg-left",
	altimeterInhgModeRight: "/instrumentation/altimeter/inhg-right",
	altimeterInhg: "/instrumentation/altimeter/setting-inhg",
	altimeterHpa: "/instrumentation/altimeter/setting-hpa",
	targetIasPFD: "/FMGC/internal/target-ias-pfd",
	targetMach: "/it-autoflight/input/mach",
	targetKts: "/it-autoflight/input/kts",
	targetHeading: "/it-autoflight/input/hdg",
	managedSpd: "/FMGC/internal/mng-spd-active",
	ktsMach: "/it-autoflight/input/kts-mach",
	showHdg: "/it-autoflight/custom/show-hdg",
	hdgDiff: "/instrumentation/pfd/hdg-diff",
	
	thrust1: "/fdm/jsbsim/fadec/control-1/detent-text",
	thrust2: "/fdm/jsbsim/fadec/control-2/detent-text",
	engOut: "/fdm/jsbsim/fadec/eng-out",
	alphaFloor: "/fdm/jsbsim/fadec/alpha-floor",
	togaLk: "/fdm/jsbsim/fadec/toga-lk",
	thrustLimit: "/fdm/jsbsim/fadec/limit/active-mode",
	detent1: "/fdm/jsbsim/fadec/control-1/detent",
	detent2: "/fdm/jsbsim/fadec/control-2/detent",
	
	decision: "/instrumentation/mk-viii/inputs/arinc429/decision-height",
	radio: "/FMGC/internal/radio",
	baro: "/FMGC/internal/baro",
	
	bussTranslate: "/instrumentation/pfd/buss/translate",
	overspeedVsProt: "/it-autoflight/internal/overspeed-vs-prot",
	underspeedVsProt: "/it-autoflight/internal/underspeed-vs-prot",
	valphaMax: "/FMGC/internal/valpha-max",
	valphaProt: "/FMGC/internal/valpha-prot",
	vls: "/FMGC/internal/vls",
	vsw: "/FMGC/internal/vsw",
};

foreach (var name; keys(input)) {
	emesary.GlobalTransmitter.NotifyAll(notifications.FrameNotificationAddProperty.new("A320 PFD", name, input[name]));
}


# Power
setlistener("/systems/electrical/bus/ac-ess", func() {
	if (A320PFD1.MainScreen != nil) { A320PFD1.MainScreen.powerTransient() }
}, 0, 0);

setlistener("/systems/electrical/bus/ac-2", func() {
	if (A320PFD2.MainScreen != nil) { A320PFD2.MainScreen.powerTransient() }
}, 0, 0);

# Helper Functions
var roundabout = func(x) {
	return (x - int(x)) < 0.5 ? int(x) : 1 + int(x);
};

var roundaboutAlt = func(x) {
	return (x * 0.2 - int(x * 0.2)) < 0.5 ? 5 * int(x * 0.2) : 5 + 5 * int(x * 0.2);
};

var genevaAltTenThousands = func(input) {
	var m = math.floor(input / 100);
	var s = math.max(0, (math.mod(input, 1) - 0.8) * 5);
	if (math.mod(input / 10, 1) < 0.9 or math.mod(input / 100, 1) < 0.9) s = 0;
	return m + s;
}

var genevaAltThousands = func(input) {
	var m = math.floor(input / 10);
	var s = math.max(0, (math.mod(input, 1) - 0.8) * 5);
	if (math.mod(input / 10, 1) < 0.9) s = 0;
	return m + s;
}

var genevaAltHundreds = func(input) {
	var m = math.floor(input);
	var s = math.max(0, (math.mod(input, 1) - 0.8) * 5);
	return m + s;
}

var _fontSizeHDGTempVar = nil;

var fontSizeHDG = func(input) {
	_fontSizeHDGTempVar = input / 3;
	if (_fontSizeHDGTempVar == int(_fontSizeHDGTempVar)) {
		return 42;
	} else {
		return 32;
	}
};

var showPFD1 = func {
	var dlg = canvas.Window.new([512, 512], "dialog").set("resize", 1);
	dlg.setCanvas(A320PFD1.MainScreen.canvas);
}

var showPFD2 = func {
	var dlg = canvas.Window.new([512, 512], "dialog").set("resize", 1);
	dlg.setCanvas(A320PFD2.MainScreen.canvas);
}
# Flash managers
var ils_going1 = 0;
var ilsTimer1 = maketimer(0.50, func {
	if (!ilsFlash[0]) {
		ilsFlash[0] = 1;
	} else {
		ilsFlash[0] = 0;
	}
});

var ils_going2 = 0;
var ilsTimer2 = maketimer(0.50, func {
	if (!ilsFlash[1]) {
		ilsFlash[1] = 1;
	} else {
		ilsFlash[1] = 0;
	}
});

var qnh_going1 = 0;
var qnhTimer1 = maketimer(0.50, func {
	if (!qnhFlash[0]) {
		qnhFlash[0] = 1;
	} else {
		qnhFlash[0] = 0;
	}
});

var qnh_going2 = 0;
var qnhTimer2 = maketimer(0.50, func {
	if (!qnhFlash[1]) {
		qnhFlash[1] = 1;
	} else {
		qnhFlash[1] = 0;
	}
});

var afloor_going = 0;
var aFloorTimer = maketimer(0.50, func {
	if (!aFloorFlash) {
		aFloorFlash = 1;
	} else {
		aFloorFlash = 0;
	}
});

var alt_going1 = 0;
var altTimer1 = maketimer(0.50, func {
	if (!altFlash[0]) {
		altFlash[0] = 1;
	} else {
		altFlash[0] = 0;
	}
});

var alt_going2 = 0;
var altTimer2 = maketimer(0.50, func {
	if (!altFlash[1]) {
		altFlash[1] = 1;
	} else {
		altFlash[1] = 0;
	}
});

var amber_going1 = 0;
var amberTimer1 = maketimer(0.50, func {
	if (!amberFlash[0]) {
		amberFlash[0] = 1;
	} else {
		amberFlash[0] = 0;
	}
});

var amber_going2 = 0;
var amberTimer2 = maketimer(0.50, func {
	if (!amberFlash[1]) {
		amberFlash[1] = 1;
	} else {
		amberFlash[1] = 0;
	}
});

var vs_going1 = 0;
var vsTimer1 = maketimer(0.50, func {
	if (!vsFlash[0]) {
		vsFlash[0] = 1;
	} else {
		vsFlash[0] = 0;
	}
});

var vs_going2 = 0;
var vsTimer2 = maketimer(0.50, func {
	if (!vsFlash[1]) {
		vsFlash[1] = 1;
	} else {
		vsFlash[1] = 0;
	}
});

var dh_going = 0;
var dhTimer = maketimer(0.50, func {
	if (!dhFlash) {
		dhFlash = 1;
	} else {
		dhFlash = 0;
	}
});

var togalk_going = 0;
var togaLkTimer = maketimer(0.50, func {
	if (!togaLkFlash) {
		togaLkFlash = 1;
	} else {
		togaLkFlash = 0;
	}
});


var autolandTimer = maketimer(0.5, func {
	if (autoland_pulse.getBoolValue()) {
		autoland_pulse.setBoolValue(0);
	} else {
		autoland_pulse.setBoolValue(1);
	}
});

setlistener(autoland_alarm, func(alarm) {
	if (alarm.getBoolValue()) {
		autoland_pulse.setBoolValue(1);
		autolandTimer.start();
	} else {
		autolandTimer.stop();
		autoland_pulse.setBoolValue(0);
	}
}, 0, 0);
