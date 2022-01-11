# A3XX PFD
# Copyright (c) 2020 Josh Davidson (Octal450)

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
var aoa_1 = props.globals.getNode("/systems/navigation/adr/output/aoa-1", 1);
var aoa_2 = props.globals.getNode("/systems/navigation/adr/output/aoa-2", 1);
var aoa_3 = props.globals.getNode("/systems/navigation/adr/output/aoa-3", 1);
var elapsedtime = props.globals.getNode("/sim/time/elapsed-sec", 1);
var hundredAbove = props.globals.getNode("/instrumentation/pfd/hundred-above", 1);
var minimum = props.globals.getNode("/instrumentation/pfd/minimums", 1);

# Create Nodes:
var altFlash = [0,0];
var amberFlash = [0, 0];
var dhFlash = 0;
var ilsFlash = [0,0];
var qnhFlash = [0,0];
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

var canvas_pfd = {
	middleOffset: 0,
	heading: 0,
	heading10: 0,
	headOffset: 0,
	middleText: 0,
	leftText1: 0,
	leftText2: 0,
	leftText3: 0,
	rightText1: 0,
	rightText2: 0,
	rightText3: 0,
	track_diff: 0,
	split_ils: 0,
	magnetic_hdg: 0,
	magnetic_hdg_dif: 0,
	alt_diff_cur: 0,
	ASI: 0,
	ASImax: 0,
	ASItrend: 0,
	ASItrgt: 0,
	ASItrgtdiff: 0,
	V1trgt: 0,
	VRtrgt: 0,
	V2trgt: 0,
	Strgt: 0,
	Ftrgt: 0,
	flaptrgt: 0,
	cleantrgt: 0,
	SPDv1trgtdiff: 0,
	SPDvrtrgtdiff: 0,
	SPDv2trgtdiff: 0,
	SPDstrgtdiff: 0,
	SPDftrgtdiff: 0,
	SPDflaptrgtdiff: 0,
	SPDcleantrgtdiff: 0,
	ind_mach: 0,
	ind_spd: 0,
	tgt_kts: 0,
	tgt_ias: 0,
	vapp: 0,
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
		canvas.parsesvg(obj.mismatch, "Aircraft/A320-family/Models/Instruments/Common/res/mismatch.svg", {"font-mapper": obj.font_mapper} );
		
		foreach(var key; obj.getKeysTest()) {
			obj[key] = obj.test.getElementById(key);
		};
		foreach(var key; obj.getKeysMismatch()) {
			obj[key] = obj.mismatch.getElementById(key);
		};
		
		obj.number = number;
		obj.units = acconfig_weight_kgs.getValue();
		
		# temporary vars
		obj.middleOffset = 0;
		obj.heading = 0;
		obj.heading10 = 0;
		obj.headOffset = 0;
		obj.middleText = 0;
		obj.leftText1 = 0;
		obj.leftText2 = 0;
		obj.leftText3 = 0;
		obj.rightText1 = 0;
		obj.rightText2 = 0;
		obj.rightText3 = 0;
		obj.track_diff = 0;
		obj.split_ils = 0;
		obj.magnetic_hdg = 0;
		obj.magnetic_hdg_dif = 0;
		obj.alt_diff_cur = 0;
		obj.ASI = 0;
		obj.ASImax = 0;
		obj.ASItrend = 0;
		obj.ASItrgt = 0;
		obj.ASItrgtdiff = 0;
		obj.V1trgt = 0;
		obj.VRtrgt = 0;
		obj.V2trgt = 0;
		obj.Strgt = 0;
		obj.Ftrgt = 0;
		obj.flaptrgt = 0;
		obj.cleantrgt = 0;
		obj.SPDv1trgtdiff = 0;
		obj.SPDvrtrgtdiff = 0;
		obj.SPDv2trgtdiff = 0;
		obj.SPDstrgtdiff = 0;
		obj.SPDftrgtdiff = 0;
		obj.SPDflaptrgtdiff = 0;
		obj.SPDcleantrgtdiff = 0;
		obj.ind_mach = 0;
		obj.ind_spd = 0;
		obj.tgt_kts = 0;
		obj.tgt_ias = 0;
		obj.vapp = 0;
		
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
		
		obj.update_items = [
			props.UpdateManager.FromHashValue("pitchPFD", nil, func(val) {
				obj.AI_horizon_trans.setTranslation(0, val * 11.825);
			}),
			props.UpdateManager.FromHashValue("roll", nil, func(val) {
				obj.AI_horizon_rot.setRotation(-val * D2R, obj["AI_center"].getCenter());
				obj.AI_horizon_ground_rot.setRotation(-val * D2R, obj["AI_center"].getCenter());
				obj.AI_horizon_sky_rot.setRotation(-val * D2R, obj["AI_center"].getCenter());
				obj["AI_bank"].setRotation(-val * D2R);
				obj["AI_agl_g"].setRotation(-val * D2R);
				obj.AI_horizon_hdg_rot.setRotation(-val * D2R, obj["AI_center"].getCenter());
			}),
			props.UpdateManager.FromHashValue("fbwLaw", nil, func(val) {
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
			props.UpdateManager.FromHashValue("horizonGround", nil, func(val) {
				obj.AI_horizon_ground_trans.setTranslation(0, val * 11.825);
			}),
			props.UpdateManager.FromHashValue("horizonPitch", nil, func(val) {
				obj.AI_horizon_hdg_trans.setTranslation(obj.middleOffset, val * 11.825);
			}),
			props.UpdateManager.FromHashValue("slipSkid", nil, func(val) {
				obj["AI_slipskid"].setTranslation(math.clamp(val, -15, 15) * 7, 0);
			}),
			props.UpdateManager.FromHashValue("FDRollBar", nil, func(val) {
				obj["FD_roll"].setTranslation(val * 2.2, 0);
			}),
			props.UpdateManager.FromHashValue("FDPitchBar", nil, func(val) {
				obj["FD_pitch"].setTranslation(0, val * -3.8);
			}),
			props.UpdateManager.FromHashValue("agl", nil, func(val) {
				if (val >= 50) {
					obj["AI_agl"].setText(sprintf("%s", math.round(math.clamp(val, 0, 2500),10)));
				} else if (val >= 5) {
					obj["AI_agl"].setText(sprintf("%s", math.round(math.clamp(val, 0, 2500),5)));
				} else {
					obj["AI_agl"].setText(sprintf("%s", math.round(math.clamp(val, 0, 2500))));
				}
				obj["ground_ref"].setTranslation(0, (-val / 100) * -48.66856);
			}),
			props.UpdateManager.FromHashList(["agl","gear1Wow", "gear2Wow","fmgcPhase"], nil, func(val) {
				if (-val.agl >= -565 and -val.agl <= 565) {
					if ((val.fmgcPhase == 5 or val.fmgcPhase == 6) and !val.gear1Wow and !val.gear2Wow) { # TODO: add std too
						obj["ground"].setTranslation(0, (-val.agl / 100) * -48.66856);
						obj["ground"].show();
					} else {
						obj["ground"].hide();
					}
				} else {
					obj["ground"].hide();
				}
			}),
			props.UpdateManager.FromHashValue("vsNeedle", nil, func(val) {
				obj["VS_pointer"].setRotation(val * D2R);
			}),
			props.UpdateManager.FromHashValue("vsDigit", nil, func(val) {
				obj["VS_box"].setTranslation(0, val);
			}),
			props.UpdateManager.FromHashValue("localizer", nil, func(val) {
				obj["LOC_pointer"].setTranslation(val * 197, 0);	
			}),
			props.UpdateManager.FromHashValue("glideslope", nil, func(val) {
				obj["GS_pointer"].setTranslation(0, val * -197);
			}),
			props.UpdateManager.FromHashList(["athr", "thrustLvrClb"], nil, func(val) {
				if (val.athr and val.thrustLvrClb) {
					obj["FMA_lvrclb"].show();
				} else {
					obj["FMA_lvrclb"].hide();
				}
			}),
			props.UpdateManager.FromHashList(["trackPFD","headingPFD"], nil, func(val) {
				obj.track_diff = geo.normdeg180(val.trackPFD - val.headingPFD);
				obj["TRK_pointer"].setTranslation(obj.getTrackDiffPixels(obj.track_diff),0);
			}),
			props.UpdateManager.FromHashValue("vsPFD", nil, func(val) {
				if (val < 2) {
					obj["VS_box"].hide();
				} else {
					obj["VS_box"].show();
				}
				
				if (val < 10) {
					obj["VS_digit"].setText(sprintf("%02d", "0" ~ val));
				} else {
					obj["VS_digit"].setText(sprintf("%02d", val));
				}
			}),
			props.UpdateManager.FromHashList(["vsAutopilot","agl"], nil, func(val) {
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
			props.UpdateManager.FromHashList(["aileronPFD","elevatorPFD"], nil, func(val) {
				obj["AI_stick_pos"].setTranslation(val.aileronPFD * 196.8, val.elevatorPFD * 151.5);
			}),
			props.UpdateManager.FromHashValue("headingScale", nil, func(val) {
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
			props.UpdateManager.FromHashValue("altitudeAutopilot", nil, func(val) {
				obj["ALT_digit_UP_metric"].setText(sprintf("%5.0fM", val * 0.3048));
			}),
			props.UpdateManager.FromHashList(["fac1","fac2"], nil, func(val) {
				if (obj.number == 0) { # LHS only acc to manual
					if (!val.fac1 and !val.fac2) {
						obj["spdLimError"].show();
					} else {
						obj["spdLimError"].hide();
					}
				}
			}),
			props.UpdateManager.FromHashValue("athrArm", nil, func(val) {
				if (val != 1) {
					obj["FMA_athr"].setColor(0.8078,0.8039,0.8078);
				} else {
					obj["FMA_athr"].setColor(0.0901,0.6039,0.7176);
				}
			}),
			props.UpdateManager.FromHashList(["apBox","apMode"], nil, func(val) {
				obj["FMA_ap"].setText(sprintf("%s", val.apMode));
				if (val.apBox and val.apMode != " ") {
					obj["FMA_ap_box"].show();
				} else {
					obj["FMA_ap_box"].hide();
				}
			}),
			props.UpdateManager.FromHashList(["atBox","atMode"], nil, func(val) {
				obj["FMA_athr"].setText(sprintf("%s", val.atMode));
				if (val.atBox and val.atMode != " ") {
					obj["FMA_athr_box"].show();
				} else {
					obj["FMA_athr_box"].hide();
				}
			}),
			props.UpdateManager.FromHashValue("rollMode", nil, func(val) {
				obj["FMA_roll"].setText(sprintf("%s", val));
			}),
			props.UpdateManager.FromHashValue("rollModeArmed", nil, func(val) {
				obj["FMA_rollarm"].setText(sprintf("%s", val));
			}),
			props.UpdateManager.FromHashList(["pitchMode","pitchModeBox","autopilotVS","autopilotFPA","pitchMode2Armed","pitchModeArmed","pitchMode2ArmedBox","pitchModeArmedBox","rollMode","rollModeBox","rollModeArmed","rollModeArmedBox","ap1","ap2","fd1","fd2"], nil, func(val) {
				obj["FMA_combined"].setText(sprintf("%s", val.pitchMode));
				if (val.pitchMode == "V/S") {
					obj["FMA_pitch"].setText(sprintf("%s     ", val.pitchMode));
					obj["vsFMArate"].setText(sprintf("%+4.0f",val.autopilotVS));
					obj["vsFMArate"].show();
				} elsif (val.pitchMode == "FPA") {
					obj["FMA_pitch"].setText(sprintf("%s     ", val.pitchMode));
					obj["vsFMArate"].setText(sprintf("%+3.1f°",val.autopilotFPA));
					obj["vsFMArate"].show();
				} else {
					obj["FMA_pitch"].setText(sprintf("%s", val.pitchMode));
					obj["vsFMArate"].hide();
				}
				
				
				if (val.pitchMode == "LAND" or val.pitchMode == "FLARE" or val.pitchMode == "ROLL OUT") {
					obj["FMA_pitch"].hide();
					obj["FMA_roll"].hide();
					obj["FMA_pitch_box"].hide();
					obj["FMA_roll_box"].hide();
					obj["FMA_pitcharm_box"].hide();
					obj["FMA_rollarm_box"].hide();
					obj["FMA_Middle1"].hide();
					obj["FMA_Middle2"].hide();
					obj["FMA_combined"].show();
					
					if (val.pitchModeBox and val.pitchMode != " ") {
						obj["FMA_combined_box"].show();
					} else {
						obj["FMA_combined_box"].hide();
					}
				} else {
					obj["FMA_combined"].hide();
					obj["FMA_combined_box"].hide();
					
					if (val.pitchModeBox and val.pitchMode != " " and (val.ap1 or val.ap2 or val.fd1 or val.fd2)) {
						obj["FMA_pitch_box"].show();
					} else {
						obj["FMA_pitch_box"].hide();
					}
					
					if (val.pitchModeArmed == " " and val.pitchMode2Armed == " ") {
						obj["FMA_pitcharm_box"].hide();
					} else {
						if ((val.pitchModeArmedBox or val.pitchMode2ArmedBox) and (val.ap1 or val.ap2 or val.fd1 or val.fd2)) {
							obj["FMA_pitcharm_box"].show();
						} else {
							obj["FMA_pitcharm_box"].hide();
						}
					}
					
					if (val.rollModeBox == 1 and val.rollMode != " " and (val.ap1 or val.ap2 or val.fd1 or val.fd2)) {
						obj["FMA_roll_box"].show();
					} else {
						obj["FMA_roll_box"].hide();
					}
					
					if (val.rollModeArmedBox == 1 and val.rollModeArmed != " " and (val.ap1 or val.ap2 or val.fd1 or val.fd2)) {
						obj["FMA_rollarm_box"].show();
					} else {
						obj["FMA_rollarm_box"].hide();
					}
				}
			}),
			props.UpdateManager.FromHashValue("pitchModeArmed", nil, func(val) {
				obj["FMA_pitcharm"].setText(sprintf("%s", val));
			}),
			props.UpdateManager.FromHashValue("pitchMode2Armed", nil, func(val) {
				obj["FMA_pitcharm2"].setText(sprintf("%s", val));
			}),
			props.UpdateManager.FromHashList(["fdBox","fdMode"], nil, func(val) {
				obj["FMA_fd"].setText(sprintf("%s", val.fdMode));
				if (val.fdBox and val.fdMode != " ") {
					obj["FMA_fd_box"].show();
				} else {
					obj["FMA_fd_box"].hide();
				}
			}),
			props.UpdateManager.FromHashList(["fd1","fd2","ap1","ap2"], nil, func(val) {
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
			props.UpdateManager.FromHashList(["gear1Wow","gear2Wow","fmgcPhase","engine1State","engine2State"], nil, func(val) {
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
			props.UpdateManager.FromHashList(["markerO","markerM","markerI"], nil, func(val) {
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
			props.UpdateManager.FromHashList(["pfdILS1","pfdILS2"], nil, func(val) {
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
			props.UpdateManager.FromHashList(["fd1","fd2","rollMode","pitchMode","trkFpa","pitchPFD","roll","gear1Wow"], nil, func(val) {
				if (((obj.number == 0 and val.fd1) or (obj.number == 1 and val.fd2)) and val.trkFpa == 0 and val.pitchPFD < 25 and val.pitchPFD > -13 and val.roll < 45 and val.roll > -45) {
					if (val.rollMode != " " and !val.gear1Wow) {
						obj["FD_roll"].show();
					} else {
						obj["FD_roll"].hide();
					}
					
					if (val.pitchMode != " ") {
						obj["FD_pitch"].show();
					} else {
						obj["FD_pitch"].hide();
					}
				} else {
					obj["FD_roll"].hide();
					obj["FD_pitch"].hide();
				}
			}),
			props.UpdateManager.FromHashList(["thrust1","thrust2","engOut"], nil, func(val) {
				if ((val.thrust1 == "CL" and val.thrust2 != "CL") or (val.thrust1 != "CL" and val.thrust2 == "CL") and val.engOut != 1) {
					obj["FMA_lvrclb"].setText("LVR ASYM");
				} else {
					if (val.engOut == 1) {
						obj["FMA_lvrclb"].setText("LVR MCT");
					} else {
						obj["FMA_lvrclb"].setText("LVR CLB");
					}
				}
			}),
			props.UpdateManager.FromHashList(["alphaFloor","togaLk","thrust1","thrust2","throttleMode","throttleModeBox","thrustLimit","engOut","thr1","thr2","athr"], nil, func(val) {
				if (val.athr and (val.thrust1 == "TOGA" or val.thrust1 == "MCT" or val.thrust1 == "MAN THR" or val.thrust2 == "TOGA" or val.thrust2 == "MCT" or val.thrust2 == "MAN THR") and val.engOut != 1 and val.alphaFloor != 1 and 
				val.togaLk != 1) {
					obj["FMA_man"].show();
					if (val.thrust1 == "TOGA" or val.thrust2 == "TOGA") {
						obj["FMA_flx_box"].hide();
						obj["FMA_flxtemp"].hide();
						obj["FMA_man_box"].show();
						obj["FMA_manmode"].show();
						obj["FMA_flxmode"].hide();
						obj["FMA_manmode"].setText("TOGA");
						obj["FMA_man_box"].setColor(0.8078,0.8039,0.8078);
					} else if ((val.thrust1 == "MAN THR" and val.thr1 >= 0.83) or (val.thrust2 == "MAN THR" and val.thr2 >= 0.83)) {
						obj["FMA_flx_box"].hide();
						obj["FMA_flxtemp"].hide();
						obj["FMA_man_box"].show();
						obj["FMA_manmode"].show();
						obj["FMA_flxmode"].hide();
						obj["FMA_manmode"].setText("THR");
						obj["FMA_man_box"].setColor(0.7333,0.3803,0);
					} else if ((val.thrust1 == "MCT" or val.thrust2 == "MCT") and val.thrustLimit != "FLX") {
						obj["FMA_flx_box"].hide();
						obj["FMA_flxtemp"].hide();
						obj["FMA_man_box"].show();
						obj["FMA_manmode"].show();
						obj["FMA_flxmode"].hide();
						obj["FMA_manmode"].setText("MCT");
						obj["FMA_man_box"].setColor(0.8078,0.8039,0.8078);
					} else if ((val.thrust1 == "MCT" or val.thrust2 == "MCT") and val.thrustLimit == "FLX") {
						obj["FMA_man_box"].hide();
						obj["FMA_flx_box"].show();
						obj["FMA_flxtemp"].show();
						obj["FMA_manmode"].hide();
						obj["FMA_flxmode"].show();
						obj["FMA_man_box"].setColor(0.8078,0.8039,0.8078);
					} else if ((val.thrust1 == "MAN THR" and val.thr1 < 0.83) or (val.thrust2 == "MAN THR" and val.thr2 < 0.83)) {
						obj["FMA_flx_box"].hide();
						obj["FMA_flxtemp"].hide();
						obj["FMA_man_box"].show();
						obj["FMA_manmode"].show();
						obj["FMA_flxmode"].hide();
						obj["FMA_manmode"].setText("THR");
						obj["FMA_man_box"].setColor(0.7333,0.3803,0);
					}
				} else if (val.athr and (val.thrust1 == "TOGA" or (val.thrust1 == "MCT" and val.thrustLimit == "FLX") or (val.thrust1 == "MAN THR" and val.thr1 >= 0.83) or val.thrust2 == "TOGA" or (val.thrust2 == "MCT" and 
				val.thrustLimit == "FLX") or (val.thrust2 == "MAN THR" and val.thr2 >= 0.83)) and val.engOut and val.alphaFloor != 1 and val.togaLk != 1) {
					obj["FMA_man"].show();
					if (val.thrust1 == "TOGA" or val.thrust2 == "TOGA") {
						obj["FMA_flx_box"].hide();
						obj["FMA_flxtemp"].hide();
						obj["FMA_man_box"].show();
						obj["FMA_manmode"].show();
						obj["FMA_flxmode"].hide();
						obj["FMA_manmode"].setText("TOGA");
						obj["FMA_man_box"].setColor(0.8078,0.8039,0.8078);
					} else if ((val.thrust1 == "MAN THR" and val.thr1 >= 0.83) or (val.thrust2 == "MAN THR" and val.thr2 >= 0.83)) {
						obj["FMA_flx_box"].hide();
						obj["FMA_flxtemp"].hide();
						obj["FMA_man_box"].show();
						obj["FMA_manmode"].show();
						obj["FMA_flxmode"].hide();
						obj["FMA_manmode"].setText("THR");
						obj["FMA_man_box"].setColor(0.7333,0.3803,0);
					} else if ((val.thrust1 == "MCT" or val.thrust2 == "MCT") and val.thrustLimit == "FLX") {
						obj["FMA_man_box"].hide();
						obj["FMA_flx_box"].show();
						obj["FMA_flxtemp"].show();
						obj["FMA_manmode"].hide();
						obj["FMA_flxmode"].show();
						obj["FMA_man_box"].setColor(0.8078,0.8039,0.8078);
					}
				} else {
					obj["FMA_man"].hide();
					obj["FMA_manmode"].hide();
					obj["FMA_man_box"].hide();
					obj["FMA_flx_box"].hide();
					obj["FMA_flxtemp"].hide();
					obj["FMA_flxmode"].hide();
				}
				
				if (val.alphaFloor != 1 and val.togaLk != 1) {
					if (val.athr and val.engOut != 1 and (val.thrust1 == "MAN" or val.thrust1 == "CL") and (val.thrust2 == "MAN" or val.thrust2 == "CL")) {
						obj["FMA_thrust"].show();
						if (val.throttleModeBox and val.throttleMode != " ") {
							obj["FMA_thrust_box"].show();
						} else {
							obj["FMA_thrust_box"].hide();
						}
					} else if (val.athr and val.engOut and (val.thrust1 == "MAN" or val.thrust1 == "CL" or (val.thrust1 == "MAN THR" and val.thr1 < 0.83) or (val.thrust1 == "MCT" and val.thrustLimit != "FLX")) and 
					(val.thrust2 == "MAN" or val.thrust2 == "CL" or (val.thrust2 == "MAN THR" and val.thr2 < 0.83) or (val.thrust2 == "MCT" and val.thrustLimit != "FLX"))) {
						obj["FMA_thrust"].show();
						if (val.throttleModeBox and val.throttleMode != " ") {
							obj["FMA_thrust_box"].show();
						} else {
							obj["FMA_thrust_box"].hide();
						}
					} else {
						obj["FMA_thrust"].hide();
						obj["FMA_thrust_box"].hide();
					}
				} else {
					obj["FMA_thrust"].show();
					obj["FMA_thrust_box"].show();
				}
				
				if (val.alphaFloor) {
					obj["FMA_thrust"].setText("A.FLOOR");
					obj["FMA_thrust_box"].setColor(0.7333,0.3803,0);
				} else if (val.togaLk) {
					obj["FMA_thrust"].setText("TOGA LK");
					obj["FMA_thrust_box"].setColor(0.7333,0.3803,0);
				} else {
					obj["FMA_thrust"].setText(sprintf("%s", val.throttleMode));
					obj["FMA_thrust_box"].setColor(0.8078,0.8039,0.8078);
				}
			}),
			props.UpdateManager.FromHashValue("flexTemp", nil, func(val) {
				obj["FMA_flxtemp"].setText(sprintf("%s", "+" ~ val));
			}),
			props.UpdateManager.FromHashList(["agl","groundspeed","thr1","thr2"], nil, func(val) {
				if (val.agl < 400 and val.groundspeed > 50 and val.thr1 < 0.78 and val.thr2 < 0.78) {
					obj["tailstrikeInd"].show();
				} else {
					obj["tailstrikeInd"].hide();
				}
			}),
			props.UpdateManager.FromHashList(["hdgDiff","showHdg","targetHeading"], nil, func(val) {
				if (val.showHdg and val.hdgDiff >= -23.62 and val.hdgDiff <= 23.62) {
					obj["HDG_target"].setTranslation((val.hdgDiff / 10) * 98.5416, 0);
					obj["HDG_digit_L"].hide();
					obj["HDG_digit_R"].hide();
					obj["HDG_target"].show();
				} else if (val.showHdg and val.hdgDiff < -23.62 and val.hdgDiff >= -180) {
					obj["HDG_digit_L"].setText(sprintf("%3.0f", val.targetHeading));
					obj["HDG_digit_L"].show();
					obj["HDG_digit_R"].hide();
					obj["HDG_target"].hide();
				} else if (val.showHdg and val.hdgDiff > 23.62 and val.hdgDiff <= 180) {
					obj["HDG_digit_R"].setText(sprintf("%3.0f", val.targetHeading));
					obj["HDG_digit_R"].show();
					obj["HDG_digit_L"].hide();
					obj["HDG_target"].hide();
				} else {
					obj["HDG_digit_L"].hide();
					obj["HDG_digit_R"].hide();
					obj["HDG_target"].hide();
				}
			}),
			props.UpdateManager.FromHashList(["altimeterHpa","altimeterInhg","altimeterInhgMode"], nil, func(val) {
				if (val.altimeterInhgMode == 0) {
					obj["QNH_setting"].setText(sprintf("%4.0f", val.altimeterHpa));
				} else {
					obj["QNH_setting"].setText(sprintf("%2.2f", val.altimeterInhg));
				}
			}),
			props.UpdateManager.FromHashList(["altimeterStd","altitudeAutopilot"], nil, func(val) {
				if (val.altimeterStd == 1) {
					if (val.altitudeAutopilot < 10000) {
						obj["ALT_digit_UP"].setText(sprintf("%s", "FL   " ~ val.altitudeAutopilot / 100));
						obj["ALT_digit_DN"].setText(sprintf("%s", "FL   " ~ val.altitudeAutopilot / 100));
					} else {
						obj["ALT_digit_UP"].setText(sprintf("%s", "FL " ~ val.altitudeAutopilot / 100));
						obj["ALT_digit_DN"].setText(sprintf("%s", "FL " ~ val.altitudeAutopilot / 100));
					}
				} else {
					obj["ALT_digit_UP"].setText(sprintf("%5.0f", val.altitudeAutopilot));
					obj["ALT_digit_DN"].setText(sprintf("%5.0f", val.altitudeAutopilot));
				}
			}),
			props.UpdateManager.FromHashValue("managedSpd", nil, func(val) {
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
		];
		
		obj.update_items_mismatch = [
			props.UpdateManager.FromHashValue("acconfigMismatch", nil, func(val) {
				obj["ERRCODE"].setText(val);
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
		
		obj.page = obj.group;
		
		return obj;
	},
	getKeys: func() {
		return ["FMA_man","FMA_manmode","FMA_flxmode","FMA_flxtemp","FMA_thrust","FMA_lvrclb","FMA_pitch","FMA_pitcharm","FMA_pitcharm2","FMA_roll","FMA_rollarm","FMA_combined","FMA_ctr_msg","FMA_catmode","FMA_cattype","FMA_nodh","FMA_dh","FMA_dhn","FMA_ap",
		"FMA_fd","FMA_athr","FMA_man_box","FMA_flx_box","FMA_thrust_box","FMA_pitch_box","FMA_pitcharm_box","FMA_roll_box","FMA_rollarm_box","FMA_combined_box","FMA_catmode_box","FMA_cattype_box","FMA_cat_box","FMA_dh_box","FMA_ap_box","FMA_fd_box",
		"FMA_athr_box","FMA_Middle1","FMA_Middle2","ALPHA_MAX","ALPHA_PROT","ALPHA_SW","ALPHA_bars","VLS_min","ASI_max","ASI_scale","ASI_target","ASI_mach","ASI_mach_decimal","ASI_trend_up","ASI_trend_down","ASI_digit_UP","ASI_digit_DN","ASI_decimal_UP",
		"ASI_decimal_DN","ASI_index","ASI_error","ASI_group","ASI_frame","AI_center","AI_bank","AI_bank_lim","AI_bank_lim_X","AI_pitch_lim","AI_pitch_lim_X","AI_slipskid","AI_horizon","AI_horizon_ground","AI_horizon_sky","AI_stick","AI_stick_pos","AI_heading",
		"AI_agl_g","AI_agl","AI_error","AI_group","FD_roll","FD_pitch","ALT_box_flash","ALT_box","ALT_box_amber","ALT_scale","ALT_target","ALT_target_digit","ALT_one","ALT_two","ALT_three","ALT_four","ALT_five","ALT_digits","ALT_tens","ALT_digit_UP",
		"ALT_digit_DN","ALT_digit_UP_metric","ALT_error","ALT_neg","ALT_group","ALT_group2","ALT_frame","VS_pointer","VS_box","VS_digit","VS_error","VS_group","QNH","QNH_setting","QNH_std","QNH_box","LOC_pointer","LOC_scale","GS_scale","GS_pointer","CRS_pointer",
		"HDG_target","HDG_scale","HDG_one","HDG_two","HDG_three","HDG_four","HDG_five","HDG_six","HDG_seven","HDG_digit_L","HDG_digit_R","HDG_error","HDG_group","HDG_frame","TRK_pointer","machError","ilsError","ils_code","ils_freq","dme_dist","dme_dist_legend",
		"ILS_HDG_R","ILS_HDG_L","ILS_right","ILS_left","outerMarker","middleMarker","innerMarker","v1_group","v1_text","vr_speed","F_target","S_target","FS_targets","flap_max","clean_speed","ground","ground_ref","FPV","spdLimError","vsFMArate","tailstrikeInd",
		"Metric_box","Metric_letter","Metric_cur_alt","ASI_buss","ASI_buss_ref","ASI_buss_ref_blue"];
	},
	getKeysTest: func() {
		return ["Test_white","Test_text"];
	},
	getKeysMismatch: func() {
		return ["ERRCODE"];
	},
	aoa: 0,
	showMetricAlt: 0,
	ASItrendIsShown: 0,
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
		
		# FPV
		if (notification.trkFpa) {
			me.aoa = (me.number == 0 ? me.getAOAForPFD1() : me.getAOAForPFD2());	
			if (me.aoa == nil or (systems.ADIRS.ADIRunits[(me.number == 0 ? 0 : 1)].operating != 1) or (systems.ADIRS.ADIRunits[2].operating != 1 and notification.attSwitch == (me.number == 0 ? -1 : 1))){
				me["FPV"].hide();	
			} else {
				me.AI_fpv_trans.setTranslation(me.getTrackDiffPixels(math.clamp(me.track_diff, -21, 21)), math.clamp(me.aoa, -20, 20) * 12.5); 
				me.AI_fpv_rot.setRotation(-notification.roll * D2R, me["AI_center"].getCenter());
				me["FPV"].setRotation(notification.roll * D2R); # It shouldn't be rotated, only the axis should be
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
		
		if (dmc.DMController.DMCs[me.number].outputs[0] != nil) {
			me.ind_spd = dmc.DMController.DMCs[me.number].outputs[0].getValue();
			me["ASI_error"].hide();
			me["ASI_buss"].hide();
			me["ASI_buss_ref"].hide();
			me["ASI_buss_ref_blue"].hide();
			me["ASI_frame"].setColor(1,1,1);
			me["ASI_group"].show();
			me["VLS_min"].hide();
			me["ALPHA_PROT"].hide();
			me["ALPHA_MAX"].hide();
			me["ALPHA_SW"].hide();
			
			if (me.ind_spd <= 30) {
				me.ASI = 0;
			} else if (me.ind_spd >= 420) {
				me.ASI = 390;
			} else {
				me.ASI = me.ind_spd - 30;
			}
			
			if (fmgc.FMGCInternal.maxspeed <= 30) {
				me.ASImax = 0 - me.ASI;
			} else if (fmgc.FMGCInternal.maxspeed >= 420) {
				me.ASImax = 390 - me.ASI;
			} else {
				me.ASImax = fmgc.FMGCInternal.maxspeed - 30 - me.ASI;
			}
			
			me["ASI_scale"].setTranslation(0, me.ASI * 6.6);
			
			if (notification.fac1 or notification.fac2) {
				me["ASI_max"].setTranslation(0, me.ASImax * -6.6);
				me["ASI_max"].show();
			} else {
				me["ASI_max"].hide();
			}
			
			if (!fmgc.FMGCInternal.takeoffState and fmgc.FMGCInternal.phase >= 1 and !notification.gear1Wow and !notification.gear2Wow) {
				if (fmgc.FMGCInternal.vls_min <= 30) {
					me.VLSmin = 0 - me.ASI;
				} else if (fmgc.FMGCInternal.vls_min >= 420) {
					me.VLSmin = 390 - me.ASI;
				} else {
					me.VLSmin = fmgc.FMGCInternal.vls_min - 30 - me.ASI;
				}
				
				if (fmgc.FMGCInternal.alpha_prot <= 30) {
					me.ALPHAprot = 0 - me.ASI;
				} else if (fmgc.FMGCInternal.alpha_prot >= 420) {
					me.ALPHAprot = 390 - me.ASI;
				} else {
					me.ALPHAprot = fmgc.FMGCInternal.alpha_prot - 30 - me.ASI;
				}
				
				if (fmgc.FMGCInternal.alpha_max <= 30) {
					me.ALPHAmax = 0 - me.ASI;
				} else if (fmgc.FMGCInternal.alpha_max >= 420) {
					me.ALPHAmax = 390 - me.ASI;
				} else {
					me.ALPHAmax = fmgc.FMGCInternal.alpha_max - 30 - me.ASI;
				}
				
				if (fmgc.FMGCInternal.vsw <= 30) {
					me.ALPHAvsw = 0 - me.ASI;
				} else if (fmgc.FMGCInternal.vsw >= 420) {
					me.ALPHAvsw = 390 - me.ASI;
				} else {
					me.ALPHAvsw = fmgc.FMGCInternal.vsw - 30 - me.ASI;
				}
				
				if (notification.fac1 or notification.fac2) {
					me["VLS_min"].setTranslation(0, me.VLSmin * -6.6);
					me["VLS_min"].show();
					if (notification.fbwLaw == 0) {
						me["ALPHA_PROT"].setTranslation(0, me.ALPHAprot * -6.6);
						me["ALPHA_MAX"].setTranslation(0, me.ALPHAmax * -6.6);
						me["ALPHA_PROT"].show();
						me["ALPHA_MAX"].show();
						me["ALPHA_SW"].hide();
					} else {
						me["ALPHA_PROT"].hide();
						me["ALPHA_MAX"].hide();
						me["ALPHA_SW"].setTranslation(0, me.ALPHAvsw * -6.6);
						me["ALPHA_SW"].show();
					}
				} else {
					me["VLS_min"].hide();
					me["ALPHA_PROT"].hide();
					me["ALPHA_MAX"].hide();
					me["ALPHA_SW"].hide();
				}
			}
			
			me.tgt_ias = notification.targetIasPFD;
			me.tgt_kts = notification.targetKts;
			
			if (notification.managedSpd) {
				if (notification.decel) {
					me.tgt_ias = fmgc.FMGCInternal.vappSpeedSet ? fmgc.FMGCInternal.vapp_appr : fmgc.FMGCInternal.vapp;
					me.tgt_kts = fmgc.FMGCInternal.vappSpeedSet ? fmgc.FMGCInternal.vapp_appr : fmgc.FMGCInternal.vapp;
				} else if (fmgc.FMGCInternal.phase == 6) {
					me.tgt_ias = fmgc.FMGCInternal.clean;
					me.tgt_kts = fmgc.FMGCInternal.clean;
				}
			}
			
			if (me.tgt_ias <= 30) {
				me.ASItrgt = 0 - me.ASI;
			} else if (me.tgt_ias >= 420) {
				me.ASItrgt = 390 - me.ASI;
			} else {
				me.ASItrgt = me.tgt_ias - 30 - me.ASI;
			}
			
			me.ASItrgtdiff = me.tgt_ias - me.ind_spd;
			
			if (me.ASItrgtdiff >= -42 and me.ASItrgtdiff <= 42) {
				me["ASI_target"].setTranslation(0, me.ASItrgt * -6.6);
				me["ASI_digit_UP"].hide();
				me["ASI_decimal_UP"].hide();
				me["ASI_digit_DN"].hide();
				me["ASI_decimal_DN"].hide();
				me["ASI_target"].show();
			} else if (me.ASItrgtdiff < -42) {
				if (notification.ktsMach) {
					me["ASI_digit_DN"].setText(sprintf("%3.0f", notification.targetMach * 1000));
					me["ASI_decimal_UP"].hide();
					me["ASI_decimal_DN"].show();
				} else {
					me["ASI_digit_DN"].setText(sprintf("%3.0f", me.tgt_kts));
					me["ASI_decimal_UP"].hide();
					me["ASI_decimal_DN"].hide();
				}
				me["ASI_digit_DN"].show();
				me["ASI_digit_UP"].hide();
				me["ASI_target"].hide();
			} else if (me.ASItrgtdiff > 42) {
				if (notification.ktsMach) {
					me["ASI_digit_UP"].setText(sprintf("%3.0f", notification.targetMach * 1000));
					me["ASI_decimal_UP"].show();
					me["ASI_decimal_DN"].hide();
				} else {
					me["ASI_digit_UP"].setText(sprintf("%3.0f", me.tgt_kts));
					me["ASI_decimal_UP"].hide();
					me["ASI_decimal_DN"].hide();
				}
				me["ASI_digit_UP"].show();
				me["ASI_digit_DN"].hide();
				me["ASI_target"].hide();
			}
			
			if (fmgc.FMGCInternal.v1set) {
				if (fmgc.FMGCInternal.v1 <= 30) {
					me.V1trgt = 0 - me.ASI;
				} else if (fmgc.FMGCInternal.v1 >= 420) {
					me.V1trgt = 390 - me.ASI;
				} else {
					me.V1trgt = fmgc.FMGCInternal.v1 - 30 - me.ASI;
				}
			
				me.SPDv1trgtdiff = fmgc.FMGCInternal.v1 - me.ind_spd;
			
				if (notification.agl < 55 and fmgc.FMGCInternal.phase <= 2 and me.SPDv1trgtdiff >= -42 and me.SPDv1trgtdiff <= 42) {
					me["v1_group"].show();
					me["v1_text"].hide();
					me["v1_group"].setTranslation(0, me.V1trgt * -6.6);
				} else if (notification.agl < 55 and fmgc.FMGCInternal.phase <= 2) {
					me["v1_group"].hide();
					me["v1_text"].show();
					me["v1_text"].setText(sprintf("%3.0f", fmgc.FMGCInternal.v1));
				} else {
					me["v1_group"].hide();
					me["v1_text"].hide();
				}
			} else {
				me["v1_group"].hide();
				me["v1_text"].hide();
			}
			
			if (fmgc.FMGCInternal.vrset) {
				if (fmgc.FMGCInternal.vr <= 30) {
					me.VRtrgt = 0 - me.ASI;
				} else if (fmgc.FMGCInternal.vr >= 420) {
					me.VRtrgt = 390 - me.ASI;
				} else {
					me.VRtrgt = fmgc.FMGCInternal.vr - 30 - me.ASI;
				}
			
				me.SPDvrtrgtdiff = fmgc.FMGCInternal.vr - me.ind_spd;
			
				if (notification.agl < 55 and fmgc.FMGCInternal.phase <= 2 and me.SPDvrtrgtdiff >= -42 and me.SPDvrtrgtdiff <= 42) {
					me["vr_speed"].show();
					me["vr_speed"].setTranslation(0, me.VRtrgt * -6.6);
				} else {
					me["vr_speed"].hide();
				}
			} else {
				me["vr_speed"].hide();
			}
			
			if (fmgc.FMGCInternal.v2set) {
				if (fmgc.FMGCInternal.v2 <= 30) {
					me.V2trgt = 0 - me.ASI;
				} else if (fmgc.FMGCInternal.v2 >= 420) {
					me.V2trgt = 390 - me.ASI;
				} else {
					me.V2trgt = fmgc.FMGCInternal.v2 - 30 - me.ASI;
				}
			
				me.SPDv2trgtdiff = fmgc.FMGCInternal.v2 - me.ind_spd;
			
				if (notification.agl < 55 and fmgc.FMGCInternal.phase <= 2 and me.SPDv2trgtdiff >= -42 and me.SPDv2trgtdiff <= 42) {
					me["ASI_target"].show();
					me["ASI_target"].setTranslation(0, me.V2trgt * -6.6);
					me["ASI_digit_UP"].setText(sprintf("%3.0f", fmgc.FMGCInternal.v2));
				} else if (notification.agl < 55 and fmgc.FMGCInternal.phase <= 2) {
					me["ASI_target"].hide();
					me["ASI_digit_UP"].setText(sprintf("%3.0f", fmgc.FMGCInternal.v2));
				}
			}
			
			if (notification.fac1 or notification.fac2) {
				if (notification.flapsInput == '1') {
					me["F_target"].hide();
					me["clean_speed"].hide();
				
					if (fmgc.FMGCInternal.slat <= 30) {
						me.Strgt = 0 - me.ASI;
					} else if (fmgc.FMGCInternal.slat >= 420) {
						me.Strgt = 390 - me.ASI;
					} else {
						me.Strgt = fmgc.FMGCInternal.slat - 30 - me.ASI;
					}
				
					me.SPDstrgtdiff = fmgc.FMGCInternal.slat - me.ind_spd;
				
					if (me.SPDstrgtdiff >= -42 and me.SPDstrgtdiff <= 42 and notification.agl >= 400) {
						me["S_target"].show();
						me["S_target"].setTranslation(0, me.Strgt * -6.6);
					} else {
						me["S_target"].hide();
					}
					
					me.SPDflaptrgtdiff = 200 - me.ind_spd;
				
					if (me.SPDflaptrgtdiff >= -42 and me.SPDflaptrgtdiff <= 42) {
						me["flap_max"].show();
						me["flap_max"].setTranslation(0, (200 - 30 - me.ASI) * -6.6);
					} else {
						me["flap_max"].hide();
					}
				} else if (notification.flapsInput == '2') {
					me["S_target"].hide();
					me["clean_speed"].hide();
					
					if (fmgc.FMGCInternal.flap2 <= 30) {
						me.Ftrgt = 0 - me.ASI;
					} else if (fmgc.FMGCInternal.flap2 >= 420) {
						me.Ftrgt = 390 - me.ASI;
					} else {
						me.Ftrgt = fmgc.FMGCInternal.flap2 - 30 - me.ASI;
					}
				
					me.SPDftrgtdiff = fmgc.FMGCInternal.flap2 - me.ind_spd;
				
					if (me.SPDftrgtdiff >= -42 and me.SPDftrgtdiff <= 42 and notification.agl >= 400) {
						me["F_target"].show();
						me["F_target"].setTranslation(0, me.Ftrgt * -6.6);
					} else {
						me["F_target"].hide();
					}
					
					me.SPDflaptrgtdiff = 185 - me.ind_spd;
				
					if (me.SPDflaptrgtdiff >= -42 and me.SPDflaptrgtdiff <= 42) {
						me["flap_max"].show();
						me["flap_max"].setTranslation(0, (185 - 30 - me.ASI) * -6.6);
					} else {
						me["flap_max"].hide();
					}
				} else if (notification.flapsInput == '3') {
					me["S_target"].hide();
					me["clean_speed"].hide();
					
					if (fmgc.FMGCInternal.flap3 <= 30) {
						me.Ftrgt = 0 - me.ASI;
					} else if (fmgc.FMGCInternal.flap3 >= 420) {
						me.Ftrgt = 390 - me.ASI;
					} else {
						me.Ftrgt = fmgc.FMGCInternal.flap3 - 30 - me.ASI;
					}
				
					me.SPDftrgtdiff = fmgc.FMGCInternal.flap3 - me.ind_spd;
				
					if (me.SPDftrgtdiff >= -42 and me.SPDftrgtdiff <= 42 and notification.agl >= 400) {
						me["F_target"].show();
						me["F_target"].setTranslation(0, me.Ftrgt * -6.6);
					} else {
						me["F_target"].hide();
					}
					
					me.SPDflaptrgtdiff = 177 - me.ind_spd;
				
					if (me.SPDflaptrgtdiff >= -42 and me.SPDflaptrgtdiff <= 42) {
						me["flap_max"].show();
						me["flap_max"].setTranslation(0, (177 - 30 - me.ASI) * -6.6);
					} else {
						me["flap_max"].hide();
					}
				} else if (notification.flapsInput == '4') {
					me["S_target"].hide();
					me["F_target"].hide();
					me["clean_speed"].hide();	
					me["flap_max"].hide();
				} else {
					me["S_target"].hide();
					me["F_target"].hide();
					
					me.SPDcleantrgtdiff = fmgc.FMGCInternal.clean - me.ind_spd;
				
					if (me.SPDcleantrgtdiff >= -42 and me.SPDcleantrgtdiff <= 42) {
						me["clean_speed"].show();
						me["clean_speed"].setTranslation(0, (fmgc.FMGCInternal.clean - 30 - me.ASI) * -6.6);
					} else {
						me["clean_speed"].hide();
					}	
					
					me.SPDflaptrgtdiff = 230 - me.ind_spd;
				
					if (me.SPDflaptrgtdiff >= -42 and me.SPDflaptrgtdiff <= 42) {
						me["flap_max"].show();
						me["flap_max"].setTranslation(0, (230 - 30 - me.ASI) * -6.6);
					} else {
						me["flap_max"].hide();
					}
				}
			} else {
				me["S_target"].hide();
				me["F_target"].hide();
				me["clean_speed"].hide();
				me["flap_max"].hide();
			}
			
			me.ASItrend = dmc.DMController.DMCs[me.number].outputs[6].getValue() - me.ASI;
			me["ASI_trend_up"].setTranslation(0, math.clamp(me.ASItrend, 0, 50) * -6.6);
			me["ASI_trend_down"].setTranslation(0, math.clamp(me.ASItrend, -50, 0) * -6.6);
			
			if (notification.fac1 or notification.fac2) {
				if (me.ASItrend >= 2 or (me.ASItrendIsShown and me.ASItrend >= 1)) {
					me["ASI_trend_up"].show();
					me["ASI_trend_down"].hide();
					me.ASItrendIsShown = 1;
				} else if (me.ASItrend <= -2 or (me.ASItrendIsShown and me.ASItrend <= -1)) {
					me["ASI_trend_up"].hide();
					me["ASI_trend_down"].show();
					me.ASItrendIsShown = 1;
				} else {
					me["ASI_trend_up"].hide();
					me["ASI_trend_down"].hide();
				}
			} else {
				me["ASI_trend_up"].hide();
				me["ASI_trend_down"].hide();
			}
					
			if (-notification.agl >= -565 and -notification.agl <= 565) {
				me["ground_ref"].show();
			} else {
				me["ground_ref"].hide();
			}
		} else {
			me["ASI_group"].hide();
			if (!systems.ADIRS.Operating.adr[0].getValue() and !systems.ADIRS.Operating.adr[1].getValue() and !systems.ADIRS.Operating.adr[2].getValue()) {
				me["ASI_buss"].show();
				me["ASI_buss_ref"].show();
				me["ASI_buss_ref_blue"].show();
				me["ASI_buss"].setTranslation(0, notification.bussTranslate);
				me["ASI_buss_ref_blue"].setTranslation(0, notification.bussTranslate);
				me["ASI_error"].hide();
			} else {
				me["ASI_buss"].hide();
				me["ASI_buss_ref"].hide();
				me["ASI_buss_ref_blue"].hide();
				me["ASI_error"].show();
			}
			me["ASI_frame"].setColor(1,0,0);
			me["clean_speed"].hide();
			me["S_target"].hide();
			me["F_target"].hide();
			me["flap_max"].hide();
			me["v1_group"].hide();
			me["v1_text"].hide();
			me["vr_speed"].hide();
			me["ground"].hide();
			me["ground_ref"].hide();
			me["VLS_min"].hide();
			me["VLS_min"].hide();
			me["ALPHA_PROT"].hide();
			me["ALPHA_MAX"].hide();
			me["ALPHA_SW"].hide();
		}
		
		if (dmc.DMController.DMCs[me.number].outputs[2] != nil) {
			me.ind_mach = dmc.DMController.DMCs[me.number].outputs[2].getValue();
			me["machError"].hide();
			
			if (me.ind_mach >= 0.999) {
				me["ASI_mach"].setText("999");
			} else {
				me["ASI_mach"].setText(sprintf("%3.0f", me.ind_mach * 1000));
			}
			
			if (me.ind_mach >= 0.5) {
				me["ASI_mach_decimal"].show();
				me["ASI_mach"].show();
			} else {
				me["ASI_mach_decimal"].hide();
				me["ASI_mach"].hide();
			}
		} else {
			me["machError"].show();
		}
		
		# Altitude
		if (dmc.DMController.DMCs[me.number].outputs[1] != nil) {
			me["ALT_error"].hide();
			me["ALT_frame"].setColor(1,1,1);
			me["ALT_group"].show();
			me["ALT_tens"].show();
			me["ALT_box"].show();
			me["ALT_group2"].show();
			me["ALT_scale"].show();
			
			me.altitude = dmc.DMController.DMCs[me.number].outputs[1].getValue();
		
			if (me.showMetricAlt) {
				me["ALT_digit_UP_metric"].show();
				me["Metric_box"].show();
				me["Metric_letter"].show();
				me["Metric_cur_alt"].show();
				me["Metric_cur_alt"].setText(sprintf("%5.0f", me.altitude * 0.3048));
			} else {
				me["ALT_digit_UP_metric"].hide();
				me["Metric_box"].hide();
				me["Metric_letter"].hide();
				me["Metric_cur_alt"].hide();
			}
			
			me.altOffset = me.altitude / 500 - int(me.altitude / 500);
			me.middleAltText = roundaboutAlt(me.altitude / 100);
			me.middleAltOffset = nil;
			if (me.altOffset > 0.5) {
				me.middleAltOffset = -(me.altOffset - 1) * 243.3424;
			} else {
				me.middleAltOffset = -me.altOffset * 243.3424;
			}
			me["ALT_scale"].setTranslation(0, -me.middleAltOffset);
			me["ALT_scale"].update();
			me["ALT_five"].setText(sprintf("%03d", abs(me.middleAltText+10)));
			me["ALT_four"].setText(sprintf("%03d", abs(me.middleAltText+5)));
			me["ALT_three"].setText(sprintf("%03d", abs(me.middleAltText)));
			me["ALT_two"].setText(sprintf("%03d", abs(me.middleAltText-5)));
			me["ALT_one"].setText(sprintf("%03d", abs(me.middleAltText-10)));
			
			if (me.altitude < 0) {
				me["ALT_neg"].show();
			} else {
				me["ALT_neg"].hide();
			}
			
			me["ALT_digits"].setText(sprintf("%d", dmc.DMController.DMCs[me.number].outputs[3].getValue()));
			me["ALT_tens"].setTranslation(0, num(right(sprintf("%02d", me.altitude), 2)) * 1.392);
			
			me.alt_diff_cur = dmc.DMController.DMCs[me.number].outputs[7].getValue();
			if (me.alt_diff_cur >= -565 and me.alt_diff_cur <= 565) {
				me["ALT_target"].setTranslation(0, (me.alt_diff_cur / 100) * -48.66856);
				me["ALT_target_digit"].setText(sprintf("%03d", math.round(notification.altitudeAutopilot / 100)));
				me["ALT_digit_UP"].hide();
				me["ALT_digit_DN"].hide();
				me["ALT_target"].show();
			} else {
				me["ALT_target"].hide();
				if (me.alt_diff_cur < -565) {
					me["ALT_digit_DN"].show();
					me["ALT_digit_UP"].hide();
				} else if (me.alt_diff_cur > 565) {
					me["ALT_digit_UP"].show();
					me["ALT_digit_DN"].hide();
				}
			}
			
			if (!ecam.altAlertFlash and !ecam.altAlertSteady) {
				if (me.number == 0) {
					alt_going1 = 0;
					amber_going1 = 0;
				} else {
					alt_going2 = 0;
					amber_going2 = 0;
				}
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
			me["ALT_error"].show();
			me["ALT_frame"].setColor(1,0,0);
			me["ALT_group"].hide();
			me["ALT_tens"].hide();
			me["ALT_neg"].hide();
			me["ALT_group2"].hide();
			me["ALT_scale"].hide();
			me["ALT_box_flash"].hide();
			me["ALT_box_amber"].hide();
			me["ALT_box"].hide();
			me["Metric_box"].hide();
			me["Metric_letter"].hide();
			me["Metric_cur_alt"].hide();
			me["ALT_digit_UP_metric"].hide();
		}
		
		if (notification.pitchMode == "LAND" or notification.pitchMode == "FLARE" or notification.pitchMode == "ROLL OUT") {
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
		
		if (fmgc.FMGCInternal.phase < 3 or fmgc.flightPlanController.arrivalDist >= 250) {
			me["FMA_dh"].hide();
			me["FMA_dhn"].hide();
			me["FMA_nodh"].hide();
			if (notification.agl <= 2500) {
				me["AI_agl"].show();
				if (notification.agl <= notification.decision) {
					me["AI_agl"].setColor(0.7333,0.3803,0);
					me["AI_agl"].setFontSize(55);
				} else {
					if (notification.agl <= 400) {
						me["AI_agl"].setFontSize(55);
					} else {
						me["AI_agl"].setFontSize(45);
					}
					me["AI_agl"].setColor(0.0509,0.7529,0.2941);
				}
			} else {
				me["AI_agl"].hide();
			}
		} else {
			if (notification.agl <= 2500) {
				me["AI_agl"].show();
				if (int(notification.radio) != 99999) {
					me["FMA_dh"].setText("RADIO");
					me["FMA_dh"].show();
					me["FMA_dhn"].setText(sprintf("%.0f", notification.radio));
					me["FMA_dhn"].show();
					me["FMA_nodh"].hide();
					hundredAbove.setValue(notification.radio + 100);
					minimum.setValue(notification.radio);
					if (notification.agl <= notification.radio + 100) {
						me["AI_agl"].setColor(0.7333,0.3803,0);
						me["AI_agl"].setFontSize(55);
					} else {
						if (notification.agl <= 400) {
							me["AI_agl"].setFontSize(55);
						} else {
							me["AI_agl"].setFontSize(45);
						}
						me["AI_agl"].setColor(0.0509,0.7529,0.2941);
					}
				} else if (int(notification.baro) != 99999) {
					me["FMA_dh"].setText("BARO");
					me["FMA_dh"].show();
					me["FMA_dhn"].setText(sprintf("%.0f", notification.baro));
					me["FMA_dhn"].show();
					me["FMA_nodh"].hide();
					hundredAbove.setValue(notification.baro + 100);
					minimum.setValue(notification.baro);
					if (notification.agl <= notification.baro + 100) {
						me["AI_agl"].setColor(0.7333,0.3803,0);
						me["AI_agl"].setFontSize(55);
					} else {
						if (notification.agl <= 400) {
							me["AI_agl"].setFontSize(55);
						} else {
							me["AI_agl"].setFontSize(45);
						}
						me["AI_agl"].setColor(0.0509,0.7529,0.2941);
					}
				} else if (fmgc.FMGCInternal.radioNo) {
					me["FMA_dh"].setText("BARO");
					me["FMA_dh"].show();
					me["FMA_dhn"].setText("100");
					me["FMA_dhn"].show();
					me["FMA_nodh"].hide();
					hundredAbove.setValue(100);
					minimum.setValue(0);
					if (notification.agl <= 400) {
						me["AI_agl"].setFontSize(55);
					} else {
						me["AI_agl"].setFontSize(45);
					}
					
					if (notification.agl <= 100) {
						me["AI_agl"].setColor(0.7333,0.3803,0);
					} else {
						me["AI_agl"].setColor(0.0509,0.7529,0.2941);
					}
				} else {
					me["FMA_dh"].hide();
					me["FMA_dhn"].hide();
					me["FMA_nodh"].show();
					hundredAbove.setValue(400);
					minimum.setValue(300);
					if (notification.agl <= 400) {
						me["AI_agl"].setColor(0.7333,0.3803,0);
						me["AI_agl"].setFontSize(55);
					} else {
						me["AI_agl"].setColor(0.0509,0.7529,0.2941);
						me["AI_agl"].setFontSize(45);
					}
				}
			} else {
				me["AI_agl"].hide();
				me["FMA_nodh"].hide();
				if (int(notification.radio) != 99999) {
					me["FMA_dh"].setText("RADIO");
					me["FMA_dh"].show();
					me["FMA_dhn"].setText(sprintf("%.0f", notification.radio));
					me["FMA_dhn"].show();
					me["FMA_nodh"].hide();
				} else if (int(notification.baro) != 99999) {
					me["FMA_dh"].setText("BARO");
					me["FMA_dh"].show();
					me["FMA_dhn"].setText(sprintf("%.0f", notification.baro));
					me["FMA_dhn"].show();
					me["FMA_nodh"].hide();
				} else if (fmgc.FMGCInternal.radioNo) {
					me["FMA_dh"].setText("BARO");
					me["FMA_dh"].show();
					me["FMA_dhn"].setText("100");
					me["FMA_dhn"].show();
					me["FMA_nodh"].hide();
				} else {
					me["FMA_dh"].hide();
					me["FMA_dhn"].hide();
					me["FMA_nodh"].show();
				}
			}
		}
		
		if (notification.altimeterStd == 1) {
			me["QNH"].hide();
			me["QNH_setting"].hide();
			
			if (notification.altitude < fmgc.FMGCInternal.transAlt and fmgc.FMGCInternal.phase == 4) {
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
			me["QNH_std"].hide();
			me["QNH_box"].hide();
		
			if (notification.altitude >= fmgc.FMGCInternal.transAlt and fmgc.FMGCInternal.phase == 2) {
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
					
					if (notification.dmeDistance < 20.0) {
						me["dme_dist"].setText(sprintf("%1.1f", notification.dmeDistance));
					} else {
						me["dme_dist"].setText(sprintf("%2.0f", notification.dmeDistance));
					}
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
			me.magnetic_hdg = notification.ilsCrs;
			me.magnetic_hdg_dif = geo.normdeg180(me.magnetic_hdg - notification.headingPFD);
			if (me.magnetic_hdg_dif >= -23.62 and me.magnetic_hdg_dif <= 23.62) {
				me["CRS_pointer"].setTranslation((me.magnetic_hdg_dif / 10) * 98.5416, 0);
				me["ILS_HDG_R"].hide();
				me["ILS_HDG_L"].hide();
				me["CRS_pointer"].show();
			} else if (me.magnetic_hdg_dif < -23.62 and me.magnetic_hdg_dif >= -180) {
				if (int(me.magnetic_hdg) < 10) {
					me["ILS_left"].setText(sprintf("00%1.0f", int(me.magnetic_hdg)));
				} else if (int(me.magnetic_hdg) < 100) {
					me["ILS_left"].setText(sprintf("0%2.0f", int(me.magnetic_hdg)));
				} else {
					me["ILS_left"].setText(sprintf("%3.0f", int(me.magnetic_hdg)));
				}
				me["ILS_HDG_L"].show();
				me["ILS_HDG_R"].hide();
				me["CRS_pointer"].hide();
			} else if (me.magnetic_hdg_dif > 23.62 and me.magnetic_hdg_dif <= 180) {
				if (int(me.magnetic_hdg) < 10) {
					me["ILS_right"].setText(sprintf("00%1.0f", int(me.magnetic_hdg)));
				} else if (int(me.magnetic_hdg) < 100) {
					me["ILS_right"].setText(sprintf("0%2.0f", int(me.magnetic_hdg)));
				} else {
					me["ILS_right"].setText(sprintf("%3.0f", int(me.magnetic_hdg)));
				}
				me["ILS_HDG_R"].show();
				me["ILS_HDG_L"].hide();
				me["CRS_pointer"].hide();
			} else {
				me["ILS_HDG_R"].hide();
				me["ILS_HDG_L"].hide();
				me["CRS_pointer"].hide();
			}
		} else {
			me["ILS_HDG_R"].hide();
			me["ILS_HDG_L"].hide();
			me["CRS_pointer"].hide();
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
		
		var elapsedtime_act = elapsedtime.getValue();
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
					me.group.setVisible(0);
					me.test.setVisible(0);
				}
			} else {
				if (notification.elecACEss >= 110 and notification.du1Lgt > 0.01) {
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
					me.group.setVisible(0);
					me.test.setVisible(0);
				}
			}
		} else {
			me.mismatch.setVisible(1);
			me.group.setVisible(0);
			me.test.setVisible(0);
		}
	},

	# Get Angle of Attack from ADR1 or, depending on Switching panel, ADR3
	getAOAForPFD1: func() {
		if (air_data_switch.getValue() != -1 and adr_1_switch.getValue() and !adr_1_fault.getValue()) return aoa_1.getValue();
		if (air_data_switch.getValue() == -1 and adr_3_switch.getValue() and !adr_3_fault.getValue()) return aoa_3.getValue();
		return nil;
	},
	
	# Get Angle of Attack from ADR2 or, depending on Switching panel, ADR3
	getAOAForPFD2: func() {
		if (air_data_switch.getValue() != 1 and adr_2_switch.getValue() and !adr_2_fault.getValue()) return aoa_2.getValue();
		if (air_data_switch.getValue() == 1 and adr_3_switch.getValue() and !adr_3_fault.getValue()) return aoa_3.getValue();
		return nil;
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
	
	atMode: "/modes/pfd/fma/at-mode",
	apMode: "/modes/pfd/fma/ap-mode",
	fdMode: "/modes/pfd/fma/fd-mode",
	atBox: "/modes/pfd/fma/athr-mode-box",
	apBox: "/modes/pfd/fma/ap-mode-box",
	fdBox: "/modes/pfd/fma/fd-mode-box",
	athr: "/it-autoflight/output/athr",
	athrArm: "/modes/pfd/fma/athr-armed",
	rollMode: "/modes/pfd/fma/roll-mode",
	rollModeArmed: "/modes/pfd/fma/roll-mode-armed",
	rollModeBox: "/modes/pfd/fma/roll-mode-box",
	rollModeArmedBox: "/modes/pfd/fma/roll-mode-armed-box",
	pitchMode: "/modes/pfd/fma/pitch-mode",
	pitchModeArmed: "/modes/pfd/fma/pitch-mode-armed",
	pitchMode2Armed: "/modes/pfd/fma/pitch-mode2-armed",
	pitchModeBox: "/modes/pfd/fma/pitch-mode-box",
	pitchModeArmedBox: "/modes/pfd/fma/pitch-mode-armed-box",
	pitchMode2ArmedBox: "/modes/pfd/fma/pitch-mode2-armed-box",
	throttleMode: "/modes/pfd/fma/throttle-mode",
	throttleModeBox: "/modes/pfd/fma/throttle-mode-box",
	
	altitudeAutopilot: "/it-autoflight/internal/alt",
	pitchPFD: "/instrumentation/pfd/pitch-deg-non-linear",
	horizonGround: "/instrumentation/pfd/horizon-ground",
	horizonPitch: "/instrumentation/pfd/horizon-pitch",
	slipSkid: "/instrumentation/pfd/slip-skid",
	fbwLaw: "/it-fbw/law",
	FDRollBar: "/it-autoflight/fd/roll-bar",
	FDPitchBar: "/it-autoflight/fd/pitch-bar",
	vsAutopilot: "/it-autoflight/internal/vert-speed-fpm",
	vsDigit: "/instrumentation/pfd/vs-digit-trans",
	vsNeedle: "/instrumentation/pfd/vs-needle",
	vsPFD: "/it-autoflight/internal/vert-speed-fpm-pfd",
	
	trackPFD: "/instrumentation/pfd/track-deg",
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
	
	aileronPFD: "/controls/flight/aileron-input-fast",
	elevatorPFD: "/controls/flight/elevator-input-fast",
	flapsInput: "/controls/flight/flaps-input",
	
	thrustLvrClb: "/systems/thrust/lvrclb",
	
	fmgcPhase: "/FMGC/internal/phase",
	fd1: "/it-autoflight/output/fd1",
	fd2: "/it-autoflight/output/fd2",
	trkFpa: "/it-autoflight/custom/trk-fpa",
	
	pfdILS1: "/modes/pfd/ILS1",
	pfdILS2: "/modes/pfd/ILS2",
	
	markerO: "/instrumentation/marker-beacon/outer",
	markerM: "/instrumentation/marker-beacon/middle",
	markerI: "/instrumentation/marker-beacon/inner",
	
	altimeterStd: "/instrumentation/altimeter/std",
	altimeterInhgMode: "/instrumentation/altimeter/inhg",
	altimeterInhg: "/instrumentation/altimeter/setting-inhg",
	altimeterHpa: "/instrumentation/altimeter/setting-hpa",
	targetIasPFD: "/FMGC/internal/target-ias-pfd",
	targetMach: "/it-autoflight/input/mach",
	targetKts: "/it-autoflight/input/kts",
	targetHeading: "/it-autoflight/input/hdg",
	managedSpd: "/it-autoflight/input/spd-managed",
	ktsMach: "/it-autoflight/input/kts-mach",
	showHdg: "/it-autoflight/custom/show-hdg",
	hdgDiff: "/instrumentation/pfd/hdg-diff",
	
	thrust1: "/systems/thrust/state1",
	thrust2: "/systems/thrust/state2",
	engOut: "/systems/thrust/eng-out",
	alphaFloor: "/systems/thrust/alpha-floor",
	togaLk: "/systems/thrust/toga-lk",
	thrustLimit: "/controls/engines/thrust-limit",
	thr1: "/controls/engines/engine[0]/throttle-pos",
	thr2: "/controls/engines/engine[1]/throttle-pos",
	
	decision: "/instrumentation/mk-viii/inputs/arinc429/decision-height",
	decel: "/FMGC/internal/decel",
	radio: "/FMGC/internal/radio",
	baro: "/FMGC/internal/baro",
	
	bussTranslate: "/instrumentation/pfd/buss/translate",
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
	var y = x - int(x);
	return y < 0.5 ? int(x) : 1 + int(x);
};

var roundaboutAlt = func(x) {
	var y = x * 0.2 - int(x * 0.2);
	return y < 0.5 ? 5 * int(x * 0.2) : 5 + 5 * int(x * 0.2);
};

var fontSizeHDG = func(input) {
	var test = input / 3;
	if (test == int(test)) {
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

var dh_going = 0;
var dhTimer = maketimer(0.50, func {
	if (!dhFlash) {
		dhFlash = 1;
	} else {
		dhFlash = 0;
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

setlistener("/modes/pfd/fma/pitch-mode", func(pitch) {
	if (pitch.getValue() == "LAND") {
		autoland_pitch_land.setBoolValue(1);
	} else {
		autoland_pitch_land.setBoolValue(0);
	}
},0,0);
