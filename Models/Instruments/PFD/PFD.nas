# A3XX PFD

# Copyright (c) 2020 Josh Davidson (Octal450)

var PFD_1 = nil;
var PFD_2 = nil;
var PFD_1_test = nil;
var PFD_2_test = nil;
var PFD_1_mismatch = nil;
var PFD_2_mismatch = nil;
var PFD1_display = nil;
var PFD2_display = nil;
var et = 0;
var altTens = 0;
var track_diff = 0;
var AICenter = nil;

# Fetch nodes:
var state1 = props.globals.getNode("/systems/thrust/state1", 1);
var state2 = props.globals.getNode("/systems/thrust/state2", 1);
var throttle_mode = props.globals.getNode("/modes/pfd/fma/throttle-mode", 1);
var pitch_mode = props.globals.getNode("/modes/pfd/fma/pitch-mode", 1);
var pitch_mode_armed = props.globals.getNode("/modes/pfd/fma/pitch-mode-armed", 1);
var pitch_mode2_armed = props.globals.getNode("/modes/pfd/fma/pitch-mode2-armed", 1);
var pitch_mode_armed_box = props.globals.getNode("/modes/pfd/fma/pitch-mode-armed-box", 1);
var pitch_mode2_armed_box = props.globals.getNode("/modes/pfd/fma/pitch-mode2-armed-box", 1);
var roll_mode = props.globals.getNode("/modes/pfd/fma/roll-mode", 1);
var roll_mode_armed = props.globals.getNode("/modes/pfd/fma/roll-mode-armed", 1);
var roll_mode_box = props.globals.getNode("/modes/pfd/fma/roll-mode-box", 1);
var roll_mode_armed_box = props.globals.getNode("/modes/pfd/fma/roll-mode-armed-box", 1);
var thr1 = props.globals.getNode("/controls/engines/engine[0]/throttle-pos", 1);
var thr2 = props.globals.getNode("/controls/engines/engine[1]/throttle-pos", 1);
var wow0 = props.globals.getNode("/gear/gear[0]/wow");
var wow1 = props.globals.getNode("/gear/gear[1]/wow");
var wow2 = props.globals.getNode("/gear/gear[2]/wow");
var pitch = props.globals.getNode("/instrumentation/pfd/pitch-deg-non-linear", 1);
var roll = props.globals.getNode("/orientation/roll-deg", 1);
var elapsedtime = props.globals.getNode("/sim/time/elapsed-sec", 1);
var du1_lgt = props.globals.getNode("/controls/lighting/DU/du1", 1);
var du6_lgt = props.globals.getNode("/controls/lighting/DU/du6", 1);
var acconfig = props.globals.getNode("/systems/acconfig/autoconfig-running", 1);
var acconfig_mismatch = props.globals.getNode("/systems/acconfig/mismatch-code", 1);
var cpt_du_xfr = props.globals.getNode("/modes/cpt-du-xfr", 1);
var fo_du_xfr = props.globals.getNode("/modes/fo-du-xfr", 1);
var eng_out = props.globals.getNode("/systems/thrust/eng-out", 1);
var eng0_state = props.globals.getNode("/engines/engine[0]/state", 1);
var eng1_state = props.globals.getNode("/engines/engine[1]/state", 1);
var alpha_floor = props.globals.getNode("/systems/thrust/alpha-floor", 1);
var toga_lk = props.globals.getNode("/systems/thrust/toga-lk", 1);
var thrust_limit = props.globals.getNode("/controls/engines/thrust-limit", 1);
var flex = props.globals.getNode("/FMGC/internal/flex", 1);
var lvr_clb = props.globals.getNode("/systems/thrust/lvrclb", 1);
var throt_box = props.globals.getNode("/modes/pfd/fma/throttle-mode-box", 1);
var pitch_box = props.globals.getNode("/modes/pfd/fma/pitch-mode-box", 1);
var ap_box = props.globals.getNode("/modes/pfd/fma/ap-mode-box", 1);
var fd_box	= props.globals.getNode("/modes/pfd/fma/fd-mode-box", 1);
var at_box = props.globals.getNode("/modes/pfd/fma/athr-mode-box", 1);
var fbw_law = props.globals.getNode("/it-fbw/law", 1);
var ap_mode = props.globals.getNode("/modes/pfd/fma/ap-mode", 1);
var fd_mode = props.globals.getNode("/modes/pfd/fma/fd-mode", 1);
var at_mode = props.globals.getNode("/modes/pfd/fma/at-mode", 1);
var alt_std_mode = props.globals.getNode("/instrumentation/altimeter/std", 1);
var alt_inhg_mode = props.globals.getNode("/instrumentation/altimeter/inhg", 1);
var alt_hpa = props.globals.getNode("/instrumentation/altimeter/setting-hpa", 1);
var alt_inhg = props.globals.getNode("/instrumentation/altimeter/setting-inhg", 1);
var target_altitude = props.globals.getNode("/autopilot/settings/target-altitude-ft", 1);
var altitude = props.globals.getNode("/instrumentation/altimeter/indicated-altitude-ft", 1);
var altitude_pfd = props.globals.getNode("/instrumentation/altimeter/indicated-altitude-ft-pfd", 1);
var ap_alt = props.globals.getNode("/it-autoflight/internal/alt", 1);
var vs_needle = props.globals.getNode("/instrumentation/pfd/vs-needle", 1);
var vs_digit = props.globals.getNode("/instrumentation/pfd/vs-digit-trans", 1);
var ap_vs_pfd = props.globals.getNode("/it-autoflight/internal/vert-speed-fpm-pfd", 1);
var athr_arm = props.globals.getNode("/modes/pfd/fma/athr-armed", 1);
var ind_spd_kt = props.globals.getNode("/instrumentation/airspeed-indicator/indicated-speed-kt", 1);
var ind_spd_mach = props.globals.getNode("/instrumentation/airspeed-indicator/indicated-mach", 1);
var at_mach_mode = props.globals.getNode("/it-autoflight/input/kts-mach", 1);
var at_input_spd_mach = props.globals.getNode("/it-autoflight/input/mach", 1);
var at_input_spd_kts = props.globals.getNode("/it-autoflight/input/kts", 1);
var fd_roll = props.globals.getNode("/it-autoflight/fd/roll-bar", 1);
var fd_pitch = props.globals.getNode("/it-autoflight/fd/pitch-bar", 1);
var decision = props.globals.getNode("/instrumentation/mk-viii/inputs/arinc429/decision-height", 1);
var slip_skid = props.globals.getNode("/instrumentation/pfd/slip-skid", 1);
var loc = props.globals.getNode("/instrumentation/nav[0]/heading-needle-deflection-norm", 1);
var gs = props.globals.getNode("/instrumentation/nav[0]/gs-needle-deflection-norm", 1);
var show_hdg = props.globals.getNode("/it-autoflight/custom/show-hdg", 1);
var ap_hdg = props.globals.getNode("/it-autoflight/input/hdg", 1);
var ap_trk_sw = props.globals.getNode("/it-autoflight/custom/trk-fpa", 1);
var ap_ils_mode = props.globals.getNode("/modes/pfd/ILS1", 1);
var ap_ils_mode2 = props.globals.getNode("/modes/pfd/ILS2", 1);
var loc_in_range = props.globals.getNode("/instrumentation/nav[0]/in-range", 1);
var gs_in_range = props.globals.getNode("/instrumentation/nav[0]/gs-in-range", 1);
var nav0_signalq = props.globals.getNode("/instrumentation/nav[0]/signal-quality-norm", 1);
var hasloc = props.globals.getNode("/instrumentation/nav[0]/nav-loc", 1);
var hasgs = props.globals.getNode("/instrumentation/nav[0]/has-gs", 1);
var pfdrate = props.globals.getNode("/systems/acconfig/options/pfd-rate", 1);
var managed_spd = props.globals.getNode("/it-autoflight/input/spd-managed", 1);
var at_tgt_ias = props.globals.getNode("/FMGC/internal/target-ias-pfd", 1);
var ap1 = props.globals.getNode("/it-autoflight/output/ap1", 1);
var ap2 = props.globals.getNode("/it-autoflight/output/ap2", 1);
var fd1 = props.globals.getNode("/it-autoflight/output/fd1", 1);
var fd2 = props.globals.getNode("/it-autoflight/output/fd2", 1);
var athr = props.globals.getNode("/it-autoflight/output/athr", 1);
var gear_agl = props.globals.getNode("/position/gear-agl-ft", 1);
var aileron_input = props.globals.getNode("/controls/flight/aileron-input-fast", 1);
var elevator_input = props.globals.getNode("/controls/flight/elevator-input-fast", 1);
var att_switch = props.globals.getNode("/controls/navigation/switching/att-hdg", 1);
var air_switch = props.globals.getNode("/controls/navigation/switching/air-data", 1);
var appr_enabled = props.globals.getNode("/it-autoflight/output/appr-armed/", 1);
var loc_enabled = props.globals.getNode("/it-autoflight/output/loc-armed/", 1);
var vert_gs = props.globals.getNode("/it-autoflight/output/vert/", 1);
var vert_state = props.globals.getNode("/it-autoflight/output/vert/", 1);
var ils_data1 = props.globals.getNode("/FMGC/internal/ils1-mcdu/", 1);
# Independent MCDU ILS not implemented yet, use MCDU1 in the meantime
# var ils_data2 = props.globals.getNode("/FMGC/internal/ils2-mcdu/", 1);
var dme_in_range = props.globals.getNode("/instrumentation/nav[0]/dme-in-range", 1);
var dme_data = props.globals.getNode("/instrumentation/dme[0]/indicated-distance-nm", 1);
var ils_crs = props.globals.getNode("/instrumentation/nav[0]/radials/selected-deg", 1);
var ils1_crs_set = props.globals.getNode("/FMGC/internal/ils1crs-set/", 1);
var outer_marker = props.globals.getNode("/instrumentation/marker-beacon/outer", 1);
var middle_marker = props.globals.getNode("/instrumentation/marker-beacon/middle", 1);
var inner_marker = props.globals.getNode("/instrumentation/marker-beacon/inner", 1);
var flap_config = props.globals.getNode("/controls/flight/flaps-input", 1);
var hundredAbove = props.globals.getNode("/instrumentation/pfd/hundred-above", 1);
var minimum = props.globals.getNode("/instrumentation/pfd/minimums", 1);
var aoa_1 = props.globals.getNode("/systems/navigation/adr/output/aoa-1", 1);
var aoa_2 = props.globals.getNode("/systems/navigation/adr/output/aoa-2", 1);
var aoa_3 = props.globals.getNode("/systems/navigation/adr/output/aoa-3", 1);
var adr_1_switch = props.globals.getNode("/controls/navigation/adirscp/switches/adr-1", 1);
var adr_2_switch = props.globals.getNode("/controls/navigation/adirscp/switches/adr-2", 1);
var adr_3_switch = props.globals.getNode("/controls/navigation/adirscp/switches/adr-3", 1);
var adr_1_fault = props.globals.getNode("/controls/navigation/adirscp/lights/adr-1-fault", 1);
var adr_2_fault = props.globals.getNode("/controls/navigation/adirscp/lights/adr-2-fault", 1);
var adr_3_fault = props.globals.getNode("/controls/navigation/adirscp/lights/adr-3-fault", 1);
var air_data_switch = props.globals.getNode("/controls/navigation/switching/air-data", 1);

# Create Nodes:
var heading = props.globals.initNode("/instrumentation/pfd/heading-deg", 0.0, "DOUBLE");
var horizon_pitch = props.globals.initNode("/instrumentation/pfd/horizon-pitch", 0.0, "DOUBLE");
var horizon_ground = props.globals.initNode("/instrumentation/pfd/horizon-ground", 0.0, "DOUBLE");
var hdg_diff = props.globals.initNode("/instrumentation/pfd/hdg-diff", 0.0, "DOUBLE");
var hdg_scale = props.globals.initNode("/instrumentation/pfd/heading-scale", 0.0, "DOUBLE");
var track = props.globals.initNode("/instrumentation/pfd/track-deg", 0.0, "DOUBLE");
#var track_diff = props.globals.initNode("/instrumentation/pfd/track-hdg-diff", 0.0, "DOUBLE"); # returns incorrect value
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
var ilsFlash1 = props.globals.initNode("/instrumentation/pfd/flash-indicators/ils-flash-1", 0, "BOOL");
var ilsFlash2 = props.globals.initNode("/instrumentation/pfd/flash-indicators/ils-flash-2", 0, "BOOL");
var qnhFlash = props.globals.initNode("/instrumentation/pfd/flash-indicators/qnh-flash", 0, "BOOL");
var altFlash1 = props.globals.initNode("/instrumentation/pfd/flash-indicators/alt-flash-1", 0, "BOOL");
var altFlash2 = props.globals.initNode("/instrumentation/pfd/flash-indicators/alt-flash-2", 0, "BOOL");
var amberFlash1 = props.globals.initNode("/instrumentation/pfd/flash-indicators/amber-flash-1", 0, "BOOL");
var amberFlash2 = props.globals.initNode("/instrumentation/pfd/flash-indicators/amber-flash-2", 0, "BOOL");
var dhFlash = props.globals.initNode("/instrumentation/pfd/flash-indicators/dh-flash", 0, "BOOL");

var canvas_PFD_base = {
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
				#	coordinates are top,right,bottom,left (ys, xe, ye, xs) ref: l621 of simgear/canvas/CanvasElement.cxx
				me[key].set("clip", clip_rect);
				me[key].set("clip-frame", canvas.Element.PARENT);
			}
		}
		
		me.AI_horizon_trans = me["AI_horizon"].createTransform();
		me.AI_horizon_rot = me["AI_horizon"].createTransform();
		
		me.AI_horizon_ground_trans = me["AI_horizon_ground"].createTransform();
		me.AI_horizon_ground_rot = me["AI_horizon_ground"].createTransform();
		
		me.AI_horizon_sky_rot = me["AI_horizon_sky"].createTransform();
		
		me.AI_horizon_hdg_trans = me["AI_heading"].createTransform();
		me.AI_horizon_hdg_rot = me["AI_heading"].createTransform();

		me.AI_fpv_trans = me["FPV"].createTransform();
		me.AI_fpv_rot = me["FPV"].createTransform();

		me.page = canvas_group;

		return me;
	},
	getKeys: func() {
		return ["FMA_man","FMA_manmode","FMA_flxmode","FMA_flxtemp","FMA_thrust","FMA_lvrclb","FMA_pitch","FMA_pitcharm","FMA_pitcharm2","FMA_roll","FMA_rollarm","FMA_combined","FMA_ctr_msg","FMA_catmode","FMA_cattype","FMA_nodh","FMA_dh","FMA_dhn","FMA_ap",
		"FMA_fd","FMA_athr","FMA_man_box","FMA_flx_box","FMA_thrust_box","FMA_pitch_box","FMA_pitcharm_box","FMA_roll_box","FMA_rollarm_box","FMA_combined_box","FMA_catmode_box","FMA_cattype_box","FMA_cat_box","FMA_dh_box","FMA_ap_box","FMA_fd_box",
		"FMA_athr_box","FMA_Middle1","FMA_Middle2","ALPHA_MAX","ALPHA_PROT","ALPHA_SW","ALPHA_bars","VLS_min","ASI_max","ASI_scale","ASI_target","ASI_mach","ASI_mach_decimal","ASI_trend_up","ASI_trend_down","ASI_digit_UP","ASI_digit_DN","ASI_decimal_UP",
		"ASI_decimal_DN","ASI_index","ASI_error","ASI_group","ASI_frame","AI_center","AI_bank","AI_bank_lim","AI_bank_lim_X","AI_pitch_lim","AI_pitch_lim_X","AI_slipskid","AI_horizon","AI_horizon_ground","AI_horizon_sky","AI_stick","AI_stick_pos","AI_heading",
		"AI_agl_g","AI_agl","AI_error","AI_group","FD_roll","FD_pitch","ALT_box_flash","ALT_box","ALT_box_amber","ALT_scale","ALT_target","ALT_target_digit","ALT_one","ALT_two","ALT_three","ALT_four","ALT_five","ALT_digits","ALT_tens","ALT_digit_UP",
		"ALT_digit_DN","ALT_error","ALT_neg","ALT_group","ALT_group2","ALT_frame","VS_pointer","VS_box","VS_digit","VS_error","VS_group","QNH","QNH_setting","QNH_std","QNH_box","LOC_pointer","LOC_scale","GS_scale","GS_pointer","CRS_pointer","HDG_target","HDG_scale",
		"HDG_one","HDG_two","HDG_three","HDG_four","HDG_five","HDG_six","HDG_seven","HDG_digit_L","HDG_digit_R","HDG_error","HDG_group","HDG_frame","TRK_pointer","machError","ilsError","ils_code","ils_freq","dme_dist","dme_dist_legend","ILS_HDG_R","ILS_HDG_L",
		"ILS_right","ILS_left","outerMarker","middleMarker","innerMarker","v1_group","v1_text","vr_speed","F_target","S_target","FS_targets","flap_max","clean_speed","ground","ground_ref","FPV","spdLimError"];
	},
	updateDu1: func() {
		var elapsedtime_act = elapsedtime.getValue();
		if (systems.ELEC.Bus.acEss.getValue() >= 110) {
			if (du1_offtime.getValue() + 3 < elapsedtime_act) { 
				if (wow0.getValue() == 1) {
					if (acconfig.getValue() != 1 and du1_test.getValue() != 1) {
						du1_test.setValue(1);
						du1_test_amount.setValue(math.round((rand() * 5 ) + 35, 0.1));
						du1_test_time.setValue(elapsedtime_act);
					} else if (acconfig.getValue() == 1 and du1_test.getValue() != 1) {
						du1_test.setValue(1);
						du1_test_amount.setValue(math.round((rand() * 5 ) + 35, 0.1));
						du1_test_time.setValue(elapsedtime_act - 30);
					}
				} else {
					du1_test.setValue(1);
					du1_test_amount.setValue(0);
					du1_test_time.setValue(-100);
				}
			}
		} else {
			du1_test.setValue(0);
			du1_offtime.setValue(elapsedtime_act);
		}
	},
	updateDu6: func() {
		var elapsedtime_act = elapsedtime.getValue();
		if (systems.ELEC.Bus.ac2.getValue() >= 110) {
			if (du6_offtime.getValue() + 3 < elapsedtime_act) { 
				if (wow0.getValue() == 1) {
					if (acconfig.getValue() != 1 and du6_test.getValue() != 1) {
						du6_test.setValue(1);
						du6_test_amount.setValue(math.round((rand() * 5 ) + 35, 0.1));
						du6_test_time.setValue(elapsedtime_act);
					} else if (acconfig.getValue() == 1 and du6_test.getValue() != 1) {
						du6_test.setValue(1);
						du6_test_amount.setValue(math.round((rand() * 5 ) + 35, 0.1));
						du6_test_time.setValue(elapsedtime_act - 30);
					}
				} else {
					du6_test.setValue(1);
					du6_test_amount.setValue(0);
					du6_test_time.setValue(-100);
				}
			}
		} else {
			du6_test.setValue(0);
			du6_offtime.setValue(elapsedtime_act);
		}
	},
	update: func() {
		var elapsedtime_act = elapsedtime.getValue();
		
		if (acconfig_mismatch.getValue() == "0x000") {
			PFD_1_mismatch.page.hide();
			PFD_2_mismatch.page.hide();
			if (systems.ELEC.Bus.acEss.getValue() >= 110 and du1_lgt.getValue() > 0.01) {
				if (du1_test_time.getValue() + du1_test_amount.getValue() >= elapsedtime_act and cpt_du_xfr.getValue() != 1) {
					PFD_1_test.update();
					PFD_1.page.hide();
					PFD_1_test.page.show();
				} else if (du2_test_time.getValue() + du2_test_amount.getValue() >= elapsedtime_act and cpt_du_xfr.getValue() == 1) {
					PFD_1_test.update();
					PFD_1.page.hide();
					PFD_1_test.page.show();
				} else {
					PFD_1.update();
					PFD_1_test.page.hide();
					PFD_1.page.show();
				}
			} else {
				PFD_1_test.page.hide();
				PFD_1.page.hide();
			}
			if (systems.ELEC.Bus.ac2.getValue() >= 110 and du6_lgt.getValue() > 0.01) {
				if (du6_test_time.getValue() + du6_test_amount.getValue() >= elapsedtime_act and fo_du_xfr.getValue() != 1) {
					PFD_2_test.update();
					PFD_2.page.hide();
					PFD_2_test.page.show();
				} else if (du5_test_time.getValue() + du5_test_amount.getValue() >= elapsedtime_act and fo_du_xfr.getValue() == 1) {
					PFD_2_test.update();
					PFD_2.page.hide();
					PFD_2_test.page.show();
				} else {
					PFD_2.update();
					PFD_2_test.page.hide();
					PFD_2.page.show();
				}
			} else {
				PFD_2_test.page.hide();
				PFD_2.page.hide();
			}
		} else {
			PFD_1_test.page.hide();
			PFD_1.page.hide();
			PFD_2_test.page.hide();
			PFD_2.page.hide();
			PFD_1_mismatch.update();
			PFD_2_mismatch.update();
			PFD_1_mismatch.page.show();
			PFD_2_mismatch.page.show();
		}
	},
	updateCommon: func () {
		# FMA MAN TOGA MCT FLX THR
		# Set properties used a lot to a variable to avoid calling getValue() multiple times
		state1_act = state1.getValue();
		state2_act = state2.getValue();
		thrust_limit_act = thrust_limit.getValue();
		alpha_floor_act = alpha_floor.getValue();
		toga_lk_act = toga_lk.getValue();
		thr1_act = thr1.getValue();
		thr2_act = thr2.getValue();
		
		# Attitude Indicator
		pitch_cur = pitch.getValue();
		roll_cur =	roll.getValue();
		
		me.AI_horizon_trans.setTranslation(0, pitch_cur * 11.825);
		me.AI_horizon_rot.setRotation(-roll_cur * D2R, me["AI_center"].getCenter());
		me.AI_horizon_ground_trans.setTranslation(0, horizon_ground.getValue() * 11.825);
		me.AI_horizon_ground_rot.setRotation(-roll_cur * D2R, me["AI_center"].getCenter());
		me.AI_horizon_sky_rot.setRotation(-roll_cur * D2R, me["AI_center"].getCenter());
		
		me["AI_slipskid"].setTranslation(math.clamp(slip_skid.getValue(), -15, 15) * 7, 0);
		me["AI_bank"].setRotation(-roll_cur * D2R);
		
		if (fbw_law.getValue() == 0) {
			me["AI_bank_lim"].show();
			me["AI_pitch_lim"].show();
			me["AI_bank_lim_X"].hide();
			me["AI_pitch_lim_X"].hide();
		} else {
			me["AI_bank_lim"].hide();
			me["AI_pitch_lim"].hide();
			me["AI_bank_lim_X"].show();
			me["AI_pitch_lim_X"].show();
		}
		
		fd_roll_cur = fd_roll.getValue();
		fd_pitch_cur = fd_pitch.getValue();
		if (fd_roll_cur != nil) {
			me["FD_roll"].setTranslation((fd_roll_cur) * 2.2, 0);
		}
		if (fd_pitch_cur != nil) {
			me["FD_pitch"].setTranslation(0, -(fd_pitch_cur) * 3.8);
		}
		
		gear_agl_cur = gear_agl.getValue();
		
		me["AI_agl"].setText(sprintf("%s", math.round(math.clamp(gear_agl_cur, 0, 2500))));
		
		if (fmgc.FMGCInternal.phase < 3 or fmgc.flightPlanController.arrivalDist >= 250) {
			me["FMA_dh_box"].hide();
			me["FMA_dh"].hide();
			me["FMA_dhn"].hide();
			me["FMA_nodh"].hide();
			#me["dhReached"].hide();
			if (gear_agl_cur <= 2500) {
				me["AI_agl"].show();
				if (gear_agl_cur <= decision.getValue()) {
					me["AI_agl"].setColor(0.7333,0.3803,0);
				} else {
					me["AI_agl"].setColor(0.0509,0.7529,0.2941);
				}
			} else {
				me["AI_agl"].hide();
			}
		} else {
			if (gear_agl_cur <= 2500) {
				me["AI_agl"].show();
				me["FMA_dh_box"].hide(); #not implemented
				if (int(getprop("/FMGC/internal/radio")) != 99999) {
					me["FMA_dh"].setText("RADIO");
					me["FMA_dh"].show();
					me["FMA_dhn"].setText(sprintf("%.0f", getprop("/FMGC/internal/radio")));
					me["FMA_dhn"].show();
					me["FMA_nodh"].hide();
					hundredAbove.setValue(getprop("/FMGC/internal/radio") + 100);
					minimum.setValue(getprop("/FMGC/internal/radio"));
					if (gear_agl_cur <= getprop("/FMGC/internal/radio") + 100) {
						me["AI_agl"].setColor(0.7333,0.3803,0);
					} else {
						me["AI_agl"].setColor(0.0509,0.7529,0.2941);
					}
				} else if (int(getprop("/FMGC/internal/baro")) != 99999) {
					me["FMA_dh"].setText("BARO");
					me["FMA_dh"].show();
					me["FMA_dhn"].setText(sprintf("%.0f", getprop("/FMGC/internal/baro")));
					me["FMA_dhn"].show();
					me["FMA_nodh"].hide();
					hundredAbove.setValue(getprop("/FMGC/internal/baro") + 100);
					minimum.setValue(getprop("/FMGC/internal/baro"));
					if (gear_agl_cur <= getprop("/FMGC/internal/baro") + 100) {
						me["AI_agl"].setColor(0.7333,0.3803,0);
					} else {
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
					if (gear_agl_cur <= 100) {
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
					if (gear_agl_cur <= 400) {
						me["AI_agl"].setColor(0.7333,0.3803,0);
					} else {
						me["AI_agl"].setColor(0.0509,0.7529,0.2941);
					}
				}
			} else {
				me["AI_agl"].hide();
				me["FMA_nodh"].hide();
				me["FMA_dh_box"].hide(); #not implemented
				if (int(getprop("/FMGC/internal/radio")) != 99999) {
					me["FMA_dh"].setText("RADIO");
					me["FMA_dh"].show();
					me["FMA_dhn"].setText(sprintf("%.0f", getprop("/FMGC/internal/radio")));
					me["FMA_dhn"].show();
					me["FMA_nodh"].hide();
				} else if (int(getprop("/FMGC/internal/baro")) != 99999) {
					me["FMA_dh"].setText("BARO");
					me["FMA_dh"].show();
					me["FMA_dhn"].setText(sprintf("%.0f", getprop("/FMGC/internal/baro")));
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
		
		me["AI_agl_g"].setRotation(-roll_cur * D2R);
		
		FMGCphase_act = fmgc.FMGCInternal.phase;
		if ((wow1.getValue() == 1 or wow2.getValue() == 1) and FMGCphase_act != 0 and FMGCphase_act != 1) {
			me["AI_stick"].show();
			me["AI_stick_pos"].show();
			
		} else if ((wow1.getValue() == 1 or wow2.getValue() == 1) and (FMGCphase_act == 0 or FMGCphase_act == 1) and (eng0_state.getValue() == 3 or eng1_state.getValue() == 3)) {
			me["AI_stick"].show();
			me["AI_stick_pos"].show();
		} else {
			me["AI_stick"].hide();
			me["AI_stick_pos"].hide();
		}
		
		me["AI_stick_pos"].setTranslation(aileron_input.getValue() * 196.8, elevator_input.getValue() * 151.5);
		
		# Vertical Speed
		me["VS_pointer"].setRotation(vs_needle.getValue() * D2R);
		
		me["VS_box"].setTranslation(0, vs_digit.getValue());
		
		var vs_pfd_cur = ap_vs_pfd.getValue();
		if (vs_pfd_cur < 2) {
			me["VS_box"].hide();
		} else {
			me["VS_box"].show();
		}
		
		if (vs_pfd_cur < 10) {
			me["VS_digit"].setText(sprintf("%02d", "0" ~ vs_pfd_cur));
		} else {
			me["VS_digit"].setText(sprintf("%02d", vs_pfd_cur));
		}
		
		var vs_itaf = fmgc.Internal.vs.getValue();
		var gearAgl = gear_agl.getValue();
		
		if (abs(vs_itaf) >= 6000 or (vs_itaf <= -2000 and gearAgl <= 2500) or (vs_itaf <= -1200 and gearAgl <= 1000)) {
			me["VS_digit"].setColor(0.7333,0.3803,0);
			me["VS_pointer"].setColor(0.7333,0.3803,0);
			me["VS_pointer"].setColorFill(0.7333,0.3803,0);
		} else {
			me["VS_digit"].setColor(0.0509,0.7529,0.2941);
			me["VS_pointer"].setColor(0.0509,0.7529,0.2941);
			me["VS_pointer"].setColorFill(0.0509,0.7529,0.2941);
		}
		
		# ILS		
		me["LOC_pointer"].setTranslation(loc.getValue() * 197, 0);	
		me["GS_pointer"].setTranslation(0, gs.getValue() * -197);
		
		# Heading
		me.heading = hdg_scale.getValue();
		me.headOffset = me.heading / 10 - int(me.heading / 10);
		me.middleText = roundabout(me.heading / 10);
		me.middleOffset = nil;
		if(me.middleText == 36) {
			me.middleText = 0;
		}
		me.leftText1 = me.middleText == 0?35:me.middleText - 1;
		me.rightText1 = me.middleText == 35?0:me.middleText + 1;
		me.leftText2 = me.leftText1 == 0?35:me.leftText1 - 1;
		me.rightText2 = me.rightText1 == 35?0:me.rightText1 + 1;
		me.leftText3 = me.leftText2 == 0?35:me.leftText2 - 1;
		me.rightText3 = me.rightText2 == 35?0:me.rightText2 + 1;
		if (me.headOffset > 0.5) {
			me.middleOffset = -(me.headOffset - 1) * 98.5416;
		} else {
			me.middleOffset = -me.headOffset * 98.5416;
		}
		me["HDG_scale"].setTranslation(me.middleOffset, 0);
		me["HDG_scale"].update();
		me["HDG_four"].setText(sprintf("%d", me.middleText));
		me["HDG_five"].setText(sprintf("%d", me.rightText1));
		me["HDG_three"].setText(sprintf("%d", me.leftText1));
		me["HDG_six"].setText(sprintf("%d", me.rightText2));
		me["HDG_two"].setText(sprintf("%d", me.leftText2));
		me["HDG_seven"].setText(sprintf("%d", me.rightText3));
		me["HDG_one"].setText(sprintf("%d", me.leftText3));
		
		me["HDG_four"].setFontSize(fontSizeHDG(me.middleText), 1);
		me["HDG_five"].setFontSize(fontSizeHDG(me.rightText1), 1);
		me["HDG_three"].setFontSize(fontSizeHDG(me.leftText1), 1);
		me["HDG_six"].setFontSize(fontSizeHDG(me.rightText2), 1);
		me["HDG_two"].setFontSize(fontSizeHDG(me.leftText2), 1);
		me["HDG_seven"].setFontSize(fontSizeHDG(me.rightText3), 1);
		me["HDG_one"].setFontSize(fontSizeHDG(me.leftText3), 1);
		
		show_hdg_act = show_hdg.getValue();
		hdg_diff_act = hdg_diff.getValue();
		if (show_hdg_act == 1 and hdg_diff_act >= -23.62 and hdg_diff_act <= 23.62) {
			me["HDG_target"].setTranslation((hdg_diff_act / 10) * 98.5416, 0);
			me["HDG_digit_L"].hide();
			me["HDG_digit_R"].hide();
			me["HDG_target"].show();
		} else if (show_hdg_act == 1 and hdg_diff_act < -23.62 and hdg_diff_act >= -180) {
			me["HDG_digit_L"].setText(sprintf("%3.0f", ap_hdg.getValue()));
			me["HDG_digit_L"].show();
			me["HDG_digit_R"].hide();
			me["HDG_target"].hide();
		} else if (show_hdg_act == 1 and hdg_diff_act > 23.62 and hdg_diff_act <= 180) {
			me["HDG_digit_R"].setText(sprintf("%3.0f", ap_hdg.getValue()));
			me["HDG_digit_R"].show();
			me["HDG_digit_L"].hide();
			me["HDG_target"].hide();
		} else {
			me["HDG_digit_L"].hide();
			me["HDG_digit_R"].hide();
			me["HDG_target"].hide();
		}
		

		var heading_deg = heading.getValue();
		track_diff = geo.normdeg180(track.getValue() - heading_deg);
		me["TRK_pointer"].setTranslation(me.getTrackDiffPixels(track_diff),0);
		split_ils = split("/", ils_data1.getValue());
		
		if (ap_ils_mode.getValue() == 1 and size(split_ils) == 2) {
			magnetic_hdg = ils_crs.getValue();
			magnetic_hdg_dif = geo.normdeg180(magnetic_hdg - heading_deg);
			if (magnetic_hdg_dif >= -23.62 and magnetic_hdg_dif <= 23.62) {
				me["CRS_pointer"].setTranslation((magnetic_hdg_dif / 10) * 98.5416, 0);
				me["ILS_HDG_R"].hide();
				me["ILS_HDG_L"].hide();
				me["CRS_pointer"].show();
			} else if (magnetic_hdg_dif < -23.62 and magnetic_hdg_dif >= -180) {
				if (int(magnetic_hdg) < 10) {
					me["ILS_left"].setText(sprintf("00%1.0f", int(magnetic_hdg)));
				} else if (int(magnetic_hdg) < 100) {
					me["ILS_left"].setText(sprintf("0%2.0f", int(magnetic_hdg)));
				} else {
					me["ILS_left"].setText(sprintf("%3.0f", int(magnetic_hdg)));
				}
				me["ILS_HDG_L"].show();
				me["ILS_HDG_R"].hide();
				me["CRS_pointer"].hide();
			} else if (magnetic_hdg_dif > 23.62 and magnetic_hdg_dif <= 180) {
				if (int(magnetic_hdg) < 10) {
					me["ILS_right"].setText(sprintf("00%1.0f", int(magnetic_hdg)));
				} else if (int(magnetic_hdg) < 100) {
					me["ILS_right"].setText(sprintf("0%2.0f", int(magnetic_hdg)));
				} else {
					me["ILS_right"].setText(sprintf("%3.0f", int(magnetic_hdg)));
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

		# AI HDG
		me.AI_horizon_hdg_trans.setTranslation(me.middleOffset, horizon_pitch.getValue() * 11.825);
		me.AI_horizon_hdg_rot.setRotation(-roll_cur * D2R, me["AI_center"].getCenter());
		me["AI_heading"].update();
		
		if (athr.getValue() == 1 and (state1_act == "TOGA" or state1_act == "MCT" or state1_act == "MAN THR" or state2_act == "TOGA" or state2_act == "MCT" or state2_act == "MAN THR") and eng_out.getValue() != 1 and alpha_floor_act != 1 and 
		toga_lk_act != 1) {
			me["FMA_man"].show();
			if (state1_act == "TOGA" or state2_act == "TOGA") {
				me["FMA_flx_box"].hide();
				me["FMA_flxtemp"].hide();
				me["FMA_man_box"].show();
				me["FMA_manmode"].show();
				me["FMA_flxmode"].hide();
				me["FMA_manmode"].setText("TOGA");
				me["FMA_man_box"].setColor(0.8078,0.8039,0.8078);
			} else if ((state1_act == "MAN THR" and thr1_act >= 0.83) or (state2_act == "MAN THR" and thr2_act >= 0.83)) {
				me["FMA_flx_box"].hide();
				me["FMA_flxtemp"].hide();
				me["FMA_man_box"].show();
				me["FMA_manmode"].show();
				me["FMA_flxmode"].hide();
				me["FMA_manmode"].setText("THR");
				me["FMA_man_box"].setColor(0.7333,0.3803,0);
			} else if ((state1_act == "MCT" or state2_act == "MCT") and thrust_limit_act != "FLX") {
				me["FMA_flx_box"].hide();
				me["FMA_flxtemp"].hide();
				me["FMA_man_box"].show();
				me["FMA_manmode"].show();
				me["FMA_flxmode"].hide();
				me["FMA_manmode"].setText("MCT");
				me["FMA_man_box"].setColor(0.8078,0.8039,0.8078);
			} else if ((state1_act == "MCT" or state2_act == "MCT") and thrust_limit_act == "FLX") {
				me["FMA_flxtemp"].setText(sprintf("%s", "+" ~ flex.getValue()));
				me["FMA_man_box"].hide();
				me["FMA_flx_box"].show();
				me["FMA_flxtemp"].show();
				me["FMA_manmode"].hide();
				me["FMA_flxmode"].show();
				me["FMA_man_box"].setColor(0.8078,0.8039,0.8078);
			} else if ((state1_act == "MAN THR" and thr1_act < 0.83) or (state2_act == "MAN THR" and thr2_act < 0.83)) {
				me["FMA_flx_box"].hide();
				me["FMA_flxtemp"].hide();
				me["FMA_man_box"].show();
				me["FMA_manmode"].show();
				me["FMA_flxmode"].hide();
				me["FMA_manmode"].setText("THR");
				me["FMA_man_box"].setColor(0.7333,0.3803,0);
			}
		} else if (athr.getValue() == 1 and (state1_act == "TOGA" or (state1_act == "MCT" and thrust_limit_act == "FLX") or (state1_act == "MAN THR" and thr1_act >= 0.83) or state2_act == "TOGA" or (state2_act == "MCT" and 
		thrust_limit_act == "FLX") or (state2_act == "MAN THR" and thr2_act >= 0.83)) and eng_out.getValue() == 1 and alpha_floor_act != 1 and toga_lk_act != 1) {
			me["FMA_man"].show();
			if (state1_act == "TOGA" or state2_act == "TOGA") {
				me["FMA_flx_box"].hide();
				me["FMA_flxtemp"].hide();
				me["FMA_man_box"].show();
				me["FMA_manmode"].show();
				me["FMA_flxmode"].hide();
				me["FMA_manmode"].setText("TOGA");
				me["FMA_man_box"].setColor(0.8078,0.8039,0.8078);
			} else if ((state1_act == "MAN THR" and thr1_act >= 0.83) or (state2_act == "MAN THR" and thr2_act >= 0.83)) {
				me["FMA_flx_box"].hide();
				me["FMA_flxtemp"].hide();
				me["FMA_man_box"].show();
				me["FMA_manmode"].show();
				me["FMA_flxmode"].hide();
				me["FMA_manmode"].setText("THR");
				me["FMA_man_box"].setColor(0.7333,0.3803,0);
			} else if ((state1_act == "MCT" or state2_act == "MCT") and thrust_limit_act == "FLX") {
				me["FMA_flxtemp"].setText(sprintf("%s", "+" ~ flex.getValue()));
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
		
		if ((state1_act == "CL" and state2_act != "CL") or (state1_act != "CL" and state2_act == "CL") and eng_out.getValue() != 1) {
			me["FMA_lvrclb"].setText("LVR ASYM");
		} else {
			if (eng_out.getValue() == 1) {
				me["FMA_lvrclb"].setText("LVR MCT");
			} else {
				me["FMA_lvrclb"].setText("LVR CLB");
			}
		}
		
		if (athr.getValue() == 1 and lvr_clb.getValue() == 1) {
			me["FMA_lvrclb"].show();
		} else {
			me["FMA_lvrclb"].hide();
		}
	
		# FMA A/THR
		if (alpha_floor_act != 1 and toga_lk_act != 1) {
			if (athr.getValue() == 1 and eng_out.getValue() != 1 and (state1_act == "MAN" or state1_act == "CL") and (state2_act == "MAN" or state2_act == "CL")) {
				me["FMA_thrust"].show();
				if (throt_box.getValue() == 1 and throttle_mode.getValue() != " ") {
					me["FMA_thrust_box"].show();
				} else {
					me["FMA_thrust_box"].hide();
				}
			} else if (athr.getValue() == 1 and eng_out.getValue() == 1 and (state1_act == "MAN" or state1_act == "CL" or (state1_act == "MAN THR" and thr1_act < 0.83) or (state1_act == "MCT" and thrust_limit_act != "FLX")) and 
			(state2_act == "MAN" or state2_act == "CL" or (state2_act == "MAN THR" and thr2_act < 0.83) or (state2_act == "MCT" and thrust_limit_act != "FLX"))) {
				me["FMA_thrust"].show();
				if (throt_box.getValue() == 1 and throttle_mode.getValue() != " ") {
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
			me["FMA_thrust_box"].show();
		}
		
		if (alpha_floor_act == 1) {
			me["FMA_thrust"].setText("A.FLOOR");
			me["FMA_thrust_box"].setColor(0.7333,0.3803,0);
		} else if (toga_lk_act == 1) {
			me["FMA_thrust"].setText("TOGA LK");
			me["FMA_thrust_box"].setColor(0.7333,0.3803,0);
		} else {
			me["FMA_thrust"].setText(sprintf("%s", throttle_mode.getValue()));
			me["FMA_thrust_box"].setColor(0.8078,0.8039,0.8078);
		}
		
		# FMA Pitch Roll Common
		pitch_mode_act = pitch_mode.getValue(); # only call getValue once per loop, not multiple times
		pitch_mode_armed_act = pitch_mode_armed.getValue();
		pitch_mode2_armed_act = pitch_mode2_armed.getValue();
		roll_mode_act = roll_mode.getValue();
		roll_mode_armed_act = roll_mode_armed.getValue();
		fbw_curlaw = fbw_law.getValue();
		me["FMA_combined"].setText(sprintf("%s", pitch_mode_act));
		
		if (pitch_mode_act == "LAND" or pitch_mode_act == "FLARE" or pitch_mode_act == "ROLL OUT") {
			me["FMA_pitch"].hide();
			me["FMA_roll"].hide();
			me["FMA_pitch_box"].hide();
			me["FMA_roll_box"].hide();
			me["FMA_pitcharm_box"].hide();
			me["FMA_rollarm_box"].hide();
			me["FMA_Middle1"].hide();
			me["FMA_Middle2"].hide();
			
			if (ecam.directLaw.active) {
				me["FMA_ctr_msg"].setText("USE MAN PITCH TRIM");
				me["FMA_ctr_msg"].setColor(0.7333,0.3803,0);
				me["FMA_ctr_msg"].show();
			} else if (fbw_curlaw == 3) {
				me["FMA_ctr_msg"].setText("MAN PITCH TRIM ONLY");
				me["FMA_ctr_msg"].setColor(1,0,0);
				me["FMA_ctr_msg"].show();
			} else {
				me["FMA_ctr_msg"].hide();
			}
			
			me["FMA_combined"].show();
			if (pitch_box.getValue() == 1 and pitch_mode_act != " ") {
				me["FMA_combined_box"].show();
			} else {
				me["FMA_combined_box"].hide();
			}
		} else {
			me["FMA_combined"].hide();
			me["FMA_combined_box"].hide();
			if (ecam.directLaw.active) {
				me["FMA_ctr_msg"].setText("USE MAN PITCH TRIM");
				me["FMA_ctr_msg"].setColor(0.7333,0.3803,0);
				me["FMA_Middle1"].hide();
				me["FMA_Middle2"].show();
				me["FMA_ctr_msg"].show();
			} else if (fbw_curlaw == 3) {
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
			
			if (ap1.getValue() == 1 or ap2.getValue() == 1 or fd1.getValue() == 1 or fd2.getValue() == 1) {
				me["FMA_pitch"].show();
				me["FMA_roll"].show();
			} else {
				me["FMA_pitch"].hide();
				me["FMA_roll"].hide();
			}
			if (pitch_box.getValue() == 1 and pitch_mode_act != " " and (ap1.getValue() == 1 or ap2.getValue() == 1 or fd1.getValue() == 1 or fd2.getValue() == 1)) {
				me["FMA_pitch_box"].show();
			} else {
				me["FMA_pitch_box"].hide();
			}
			if (pitch_mode_armed_act == " " and pitch_mode2_armed_act == " ") {
				me["FMA_pitcharm_box"].hide();
			} else {
				if ((pitch_mode_armed_box.getValue() == 1 or pitch_mode2_armed_box.getValue() == 1) and (ap1.getValue() == 1 or ap2.getValue() == 1 or fd1.getValue() == 1 or fd2.getValue() == 1)) {
					me["FMA_pitcharm_box"].show();
				} else {
					me["FMA_pitcharm_box"].hide();
				}
			}
			if (roll_mode_box.getValue() == 1 and roll_mode_act != " " and (ap1.getValue() == 1 or ap2.getValue() == 1 or fd1.getValue() == 1 or fd2.getValue() == 1)) {
				me["FMA_roll_box"].show();
			} else {
				me["FMA_roll_box"].hide();
			}
			if (roll_mode_armed_box.getValue() == 1 and roll_mode_armed_act != " " and (ap1.getValue() == 1 or ap2.getValue() == 1 or fd1.getValue() == 1 or fd2.getValue() == 1)) {
				me["FMA_rollarm_box"].show();
			} else {
				me["FMA_rollarm_box"].hide();
			}
		}
		
		if (ap1.getValue() == 1 or ap2.getValue() == 1 or fd1.getValue() == 1 or fd2.getValue() == 1) {
			me["FMA_pitcharm"].show();
			me["FMA_pitcharm2"].show();
			me["FMA_rollarm"].show();
		} else {
			me["FMA_pitcharm"].hide();
			me["FMA_pitcharm2"].hide();
			me["FMA_rollarm"].hide();
		}
		
		# FMA Pitch
		me["FMA_pitch"].setText(sprintf("%s", pitch_mode_act));
		me["FMA_pitcharm"].setText(sprintf("%s", pitch_mode_armed_act));
		me["FMA_pitcharm2"].setText(sprintf("%s", pitch_mode2_armed_act));
		
		# FMA Roll
		me["FMA_roll"].setText(sprintf("%s", roll_mode_act));
		me["FMA_rollarm"].setText(sprintf("%s", roll_mode_armed_act));
		
		# FMA CAT DH
		me["FMA_catmode"].hide();
		me["FMA_cattype"].hide();
		me["FMA_catmode_box"].hide();
		me["FMA_cattype_box"].hide();
		me["FMA_cat_box"].hide();
		
		# FMA AP FD ATHR
		me["FMA_ap"].setText(sprintf("%s", ap_mode.getValue()));
		me["FMA_fd"].setText(sprintf("%s", fd_mode.getValue()));
		me["FMA_athr"].setText(sprintf("%s", at_mode.getValue()));
		
		if (athr_arm.getValue() != 1) {
			me["FMA_athr"].setColor(0.8078,0.8039,0.8078);
		} else {
			me["FMA_athr"].setColor(0.0901,0.6039,0.7176);
		}
		
		if (ap_box.getValue() == 1 and ap_mode.getValue() != " ") {
			me["FMA_ap_box"].show();
		} else {
			me["FMA_ap_box"].hide();
		}
		
		if (fd_box.getValue() == 1 and fd_mode.getValue() != " ") {
			me["FMA_fd_box"].show();
		} else {
			me["FMA_fd_box"].hide();
		}
		
		if (at_box.getValue() == 1 and at_mode.getValue() != " ") {
			me["FMA_athr_box"].show();
		} else {
			me["FMA_athr_box"].hide();
		}
		
		# QNH
		if (alt_std_mode.getValue() == 1) {
			
			me["QNH"].hide();
			me["QNH_setting"].hide();
			
			if (altitude.getValue() < fmgc.FMGCInternal.transAlt and fmgc.FMGCInternal.phase == 4) {
				if (qnh_going == 0) {
					qnh_going = 1;
				}
				if (qnh_going == 1) {
					qnhTimer.start();
					if (qnhFlash.getValue() == 1) {
						me["QNH_std"].show();
						me["QNH_box"].show();
					} else {
						me["QNH_std"].hide();
						me["QNH_box"].hide();
					}
				}
			} else {
				qnhTimer.stop();
				qnh_going = 0;
				me["QNH_std"].show();
				me["QNH_box"].show();
			}
		} else if (alt_inhg_mode.getValue() == 0) {
			
			me["QNH_std"].hide();
			me["QNH_box"].hide();
		
			if (altitude.getValue() >= fmgc.FMGCInternal.transAlt and fmgc.FMGCInternal.phase == 2) {
				if (qnh_going == 0) {
					qnh_going = 1;
				}
				if (qnh_going == 1) {
					qnhTimer.start();
					if (qnhFlash.getValue() == 1) {
						me["QNH_setting"].setText(sprintf("%4.0f", alt_hpa.getValue()));
						me["QNH"].show();
						me["QNH_setting"].show();
					} else {
						me["QNH"].hide();
						me["QNH_setting"].hide();
					}
				}
			} else {
				qnhTimer.stop();
				qnh_going = 0;
				me["QNH_setting"].setText(sprintf("%4.0f", alt_hpa.getValue()));
				me["QNH"].show();
				me["QNH_setting"].show();
			}

		} else if (alt_inhg_mode.getValue() == 1) {
		
			if (altitude.getValue() >= fmgc.FMGCInternal.transAlt and fmgc.FMGCInternal.phase == 2) {
				if (qnh_going == 0) {
					qnh_going = 1;
				}
				if (qnh_going == 1) {
					qnhTimer.start();
					if (qnhFlash.getValue() == 1) {
						me["QNH_setting"].setText(sprintf("%2.2f", alt_inhg.getValue()));
						me["QNH"].show();
						me["QNH_setting"].show();
					} else {
						me["QNH"].hide();
						me["QNH_setting"].hide();
					}
				}
			} else {
				qnhTimer.stop();
				qnh_going = 0;
				me["QNH_setting"].setText(sprintf("%2.2f", alt_inhg.getValue()));
				me["QNH"].show();
				me["QNH_setting"].show();
			}
			
			me["QNH_std"].hide();
			me["QNH_box"].hide();
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

var canvas_PFD_1 = {
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
	new: func(canvas_group, file) {
		var m = {parents: [canvas_PFD_1, canvas_PFD_base]};
		m.init(canvas_group, file);

		return m;
	},
	update: func() {
		fd1_act = fd1.getValue();
		pitch_mode_cur = pitch_mode.getValue();
		roll_mode_cur = roll_mode.getValue();
		pitch_cur = pitch.getValue();
		roll_cur = roll.getValue();
		wow1_act = wow1.getValue();
		wow2_act = wow2.getValue();
		
		# Errors
		if (systems.ADIRS.ADIRunits[0].operating == 1 or (systems.ADIRS.ADIRunits[2].operating == 1 and att_switch.getValue() == -1)) {
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
		
		# Apparently SPD LIM only on captains PFD. I find this odd. But manual says it.
		# Spd Lim Error
		if (!fbw.FBW.Computers.fac1.getValue() and !fbw.FBW.Computers.fac2.getValue()) {
			me["spdLimError"].show();
		} else {
			me["spdLimError"].hide();
		}
		
		# FD
		if (fd1_act == 1 and ((!wow1_act and !wow2_act and roll_mode_cur != " ") or roll_mode_cur != " ") and ap_trk_sw.getValue() == 0 and pitch_cur < 25 and pitch_cur > -13 and roll_cur < 45 and roll_cur > -45) {
			me["FD_roll"].show();
		} else {
			me["FD_roll"].hide();
		}
		
		if (fd1_act == 1 and ((!wow1_act and !wow2_act and pitch_mode_cur != " ") or pitch_mode_cur != " ") and ap_trk_sw.getValue() == 0 and pitch_cur < 25 and pitch_cur > -13 and roll_cur < 45 and roll_cur > -45) {
			me["FD_pitch"].show();
		} else {
			me["FD_pitch"].hide();
		}
		
		# If TRK FPA selected, display FPV on PFD1
		if (ap_trk_sw.getValue() == 0 ) {
			me["FPV"].hide();	
		} else {
			var aoa = me.getAOAForPFD1();	
			if (aoa == nil or (systems.ADIRS.ADIRunits[0].operating != 1 and att_switch.getValue() == 0) or (systems.ADIRS.ADIRunits[2].operating != 1 and att_switch.getValue() == -1)){
				me["FPV"].hide();	
			} else {
				var roll_deg = roll.getValue() or 0; 
				AICenter = me["AI_center"].getCenter();
				var track_x_translation = me.getTrackDiffPixels(track_diff); 

				me.AI_fpv_trans.setTranslation(track_x_translation, math.clamp(aoa, -20, 20) * 12.5); 
				me.AI_fpv_rot.setRotation(-roll_deg * D2R, AICenter);
				me["FPV"].setRotation(roll_deg * D2R); # It shouldn't be rotated, only the axis should be
				me["FPV"].show();
			}

		}

		# ILS
		if (ap_ils_mode.getValue() == 1) {
			me["LOC_scale"].show();
			me["GS_scale"].show();
			split_ils = split("/", ils_data1.getValue());
			
			if (size(split_ils) < 2) {
				me["ils_freq"].setText(split_ils[0]);
				me["ils_freq"].show();
				me["ils_code"].hide();
				me["dme_dist"].hide();
				me["dme_dist_legend"].hide();
			} else {
				me["ils_code"].setText(split_ils[0]);
				me["ils_freq"].setText(split_ils[1]);
				me["ils_code"].show();
				me["ils_freq"].show();
			}
			
			if (dme_in_range.getValue() == 1) {
				dme_dist_data = dme_data.getValue();
				if (dme_dist_data < 20.0) {
					me["dme_dist"].setText(sprintf("%1.1f", dme_dist_data));
				} else {
					me["dme_dist"].setText(sprintf("%2.0f", dme_dist_data));
				}
				me["dme_dist"].show(); 
				me["dme_dist_legend"].show();
			}
		} else {
			me["LOC_scale"].hide();
			me["GS_scale"].hide();
			me["ils_code"].hide();
			me["ils_freq"].hide();
			me["dme_dist"].hide();
			me["dme_dist_legend"].hide();
			me["outerMarker"].hide();
			me["middleMarker"].hide();
			me["innerMarker"].hide();	
		}
		
		if (outer_marker.getValue() == 1) {
			me["outerMarker"].show();
			me["middleMarker"].hide();
			me["innerMarker"].hide();
		} else if (middle_marker.getValue()) {
			me["middleMarker"].show();
			me["outerMarker"].hide();
			me["innerMarker"].hide();
		} else if (inner_marker.getValue()) {
			me["innerMarker"].show();
			me["outerMarker"].hide();
			me["middleMarker"].hide();
		} else {
			me["outerMarker"].hide();
			me["middleMarker"].hide();
			me["innerMarker"].hide();	
		}
		
		if (ap_ils_mode.getValue() == 1 and loc_in_range.getValue() == 1 and hasloc.getValue() == 1 and nav0_signalq.getValue() > 0.99) {
			me["LOC_pointer"].show();
		} else {
			me["LOC_pointer"].hide();
		}
		if (ap_ils_mode.getValue() == 1 and gs_in_range.getValue() == 1 and hasgs.getValue() == 1 and nav0_signalq.getValue() > 0.99) {
			me["GS_pointer"].show();
		} else {
			me["GS_pointer"].hide();
		}

		if (ap_ils_mode.getValue() == 0 and (appr_enabled.getValue() == 1 or loc_enabled.getValue() == 1 or vert_gs.getValue() == 2)) {
			if (ils_going1 == 0) {
				ils_going1 = 1;
			}
			if (ils_going1 == 1) {
				ilsTimer1.start();
				if (ilsFlash1.getValue() == 1) {
					me["ilsError"].show();	
				} else {
					me["ilsError"].hide();	
				}
			}
		} else {
			ilsTimer1.stop();
			ils_going1 = 0;
			me["ilsError"].hide();
		}
			
		# Airspeed
		# ind_spd = ind_spd_kt.getValue();
		# Subtract 30, since the scale starts at 30, but don"t allow less than 0, or more than 420 situations
		
		if (dmc.DMController.DMCs[0].outputs[0] != nil) {
			ind_spd = dmc.DMController.DMCs[0].outputs[0].getValue();
			me["ASI_error"].hide();
			me["ASI_frame"].setColor(1,1,1);
			me["ASI_group"].show();
			me["VLS_min"].hide();
			me["ALPHA_PROT"].hide();
			me["ALPHA_MAX"].hide();
			me["ALPHA_SW"].hide();
			
			if (ind_spd <= 30) {
				me.ASI = 0;
			} else if (ind_spd >= 420) {
				me.ASI = 390;
			} else {
				me.ASI = ind_spd - 30;
			}
			
			me.FMGC_max = fmgc.FMGCInternal.maxspeed;
			if (me.FMGC_max <= 30) {
				me.ASImax = 0 - me.ASI;
			} else if (me.FMGC_max >= 420) {
				me.ASImax = 390 - me.ASI;
			} else {
				me.ASImax = me.FMGC_max - 30 - me.ASI;
			}
			
			me["ASI_scale"].setTranslation(0, me.ASI * 6.6);
			if (fbw.FBW.Computers.fac1.getValue() or fbw.FBW.Computers.fac2.getValue()) {
				me["ASI_max"].setTranslation(0, me.ASImax * -6.6);
				me["ASI_max"].show();
			} else {
				me["ASI_max"].hide();
			}
			
			if (!fmgc.FMGCInternal.takeoffState and fmgc.FMGCInternal.phase >= 1 and !wow1.getValue() and !wow2.getValue()) {
				me.FMGC_vls = fmgc.FMGCInternal.vls_min;
				if (me.FMGC_vls <= 30) {
					me.VLSmin = 0 - me.ASI;
				} else if (me.FMGC_vls >= 420) {
					me.VLSmin = 390 - me.ASI;
				} else {
					me.VLSmin = me.FMGC_vls - 30 - me.ASI;
				}
				me.FMGC_prot = fmgc.FMGCInternal.alpha_prot;
				if (me.FMGC_prot <= 30) {
					me.ALPHAprot = 0 - me.ASI;
				} else if (me.FMGC_prot >= 420) {
					me.ALPHAprot = 390 - me.ASI;
				} else {
					me.ALPHAprot = me.FMGC_prot - 30 - me.ASI;
				}
				me.FMGC_max = fmgc.FMGCInternal.alpha_max;
				if (me.FMGC_max <= 30) {
					me.ALPHAmax = 0 - me.ASI;
				} else if (me.FMGC_max >= 420) {
					me.ALPHAmax = 390 - me.ASI;
				} else {
					me.ALPHAmax = me.FMGC_max - 30 - me.ASI;
				}
				me.FMGC_vsw = fmgc.FMGCInternal.vsw;
				if (me.FMGC_vsw <= 30) {
					me.ALPHAvsw = 0 - me.ASI;
				} else if (me.FMGC_vsw >= 420) {
					me.ALPHAvsw = 390 - me.ASI;
				} else {
					me.ALPHAvsw = me.FMGC_vsw - 30 - me.ASI;
				}
				
				if (fbw.FBW.Computers.fac1.getValue() or fbw.FBW.Computers.fac2.getValue()) {
					me["VLS_min"].setTranslation(0, me.VLSmin * -6.6);
					me["VLS_min"].show();
					if (getprop("/it-fbw/law") == 0) {
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
			
			tgt_ias = at_tgt_ias.getValue();
			tgt_mach = at_input_spd_mach.getValue();
			tgt_kts = at_input_spd_kts.getValue();
			
			if (managed_spd.getValue() == 1) {
				if (getprop("/FMGC/internal/decel") == 1) {
					if (fmgc.FMGCInternal.vappSpeedSet) {
						vapp = fmgc.FMGCInternal.vapp_appr;
					} else {
						vapp = fmgc.FMGCInternal.vapp;
					}
					tgt_ias = vapp;
					tgt_kts = vapp;
				} else if (fmgc.FMGCInternal.phase == 6) {
					clean = fmgc.FMGCInternal.clean;
					tgt_ias = clean;
					tgt_kts = clean;
				}
				
				me["ASI_target"].setColor(0.6901,0.3333,0.7450);
				me["ASI_digit_UP"].setColor(0.6901,0.3333,0.7450);
				me["ASI_decimal_UP"].setColor(0.6901,0.3333,0.7450);
				me["ASI_digit_DN"].setColor(0.6901,0.3333,0.7450);
				me["ASI_decimal_DN"].setColor(0.6901,0.3333,0.7450);
			} else {
				me["ASI_target"].setColor(0.0901,0.6039,0.7176);
				me["ASI_digit_UP"].setColor(0.0901,0.6039,0.7176);
				me["ASI_decimal_UP"].setColor(0.0901,0.6039,0.7176);
				me["ASI_digit_DN"].setColor(0.0901,0.6039,0.7176);
				me["ASI_decimal_DN"].setColor(0.0901,0.6039,0.7176);
			}
			
			if (tgt_ias <= 30) {
				me.ASItrgt = 0 - me.ASI;
			} else if (tgt_ias >= 420) {
				me.ASItrgt = 390 - me.ASI;
			} else {
				me.ASItrgt = tgt_ias - 30 - me.ASI;
			}
			
			me.ASItrgtdiff = tgt_ias - ind_spd;
			
			if (me.ASItrgtdiff >= -42 and me.ASItrgtdiff <= 42) {
				me["ASI_target"].setTranslation(0, me.ASItrgt * -6.6);
				me["ASI_digit_UP"].hide();
				me["ASI_decimal_UP"].hide();
				me["ASI_digit_DN"].hide();
				me["ASI_decimal_DN"].hide();
				me["ASI_target"].show();
			} else if (me.ASItrgtdiff < -42) {
				if (at_mach_mode.getValue() == 1) {
					me["ASI_digit_DN"].setText(sprintf("%3.0f", tgt_mach * 1000));
					me["ASI_decimal_UP"].hide();
					me["ASI_decimal_DN"].show();
				} else {
					me["ASI_digit_DN"].setText(sprintf("%3.0f", tgt_kts));
					me["ASI_decimal_UP"].hide();
					me["ASI_decimal_DN"].hide();
				}
				me["ASI_digit_DN"].show();
				me["ASI_digit_UP"].hide();
				me["ASI_target"].hide();
			} else if (me.ASItrgtdiff > 42) {
				if (at_mach_mode.getValue() == 1) {
					me["ASI_digit_UP"].setText(sprintf("%3.0f", tgt_mach * 1000));
					me["ASI_decimal_UP"].show();
					me["ASI_decimal_DN"].hide();
				} else {
					me["ASI_digit_UP"].setText(sprintf("%3.0f", tgt_kts));
					me["ASI_decimal_UP"].hide();
					me["ASI_decimal_DN"].hide();
				}
				me["ASI_digit_UP"].show();
				me["ASI_digit_DN"].hide();
				me["ASI_target"].hide();
			}
			
			if (fmgc.FMGCInternal.v1set) {
				tgt_v1 = fmgc.FMGCInternal.v1;
				if (tgt_v1 <= 30) {
					me.V1trgt = 0 - me.ASI;
				} else if (tgt_v1 >= 420) {
					me.V1trgt = 390 - me.ASI;
				} else {
					me.V1trgt = tgt_v1 - 30 - me.ASI;
				}
			
				me.SPDv1trgtdiff = tgt_v1 - ind_spd;
			
				if (pts.Position.gearAglFt.getValue() < 55 and fmgc.FMGCInternal.phase <= 2 and me.SPDv1trgtdiff >= -42 and me.SPDv1trgtdiff <= 42) {
					me["v1_group"].show();
					me["v1_text"].hide();
					me["v1_group"].setTranslation(0, me.V1trgt * -6.6);
				} else if (pts.Position.gearAglFt.getValue() < 55 and fmgc.FMGCInternal.phase <= 2) {
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
				tgt_vr = fmgc.FMGCInternal.vr;
				if (tgt_vr <= 30) {
					me.VRtrgt = 0 - me.ASI;
				} else if (tgt_vr >= 420) {
					me.VRtrgt = 390 - me.ASI;
				} else {
					me.VRtrgt = tgt_vr - 30 - me.ASI;
				}
			
				me.SPDvrtrgtdiff = tgt_vr - ind_spd;
			
				if (pts.Position.gearAglFt.getValue() < 55 and fmgc.FMGCInternal.phase <= 2 and me.SPDvrtrgtdiff >= -42 and me.SPDvrtrgtdiff <= 42) {
					me["vr_speed"].show();
					me["vr_speed"].setTranslation(0, me.VRtrgt * -6.6);
				} else {
					me["vr_speed"].hide();
				}
			} else {
				me["vr_speed"].hide();
			}
			
			if (fmgc.FMGCInternal.v2set) {
				tgt_v2 = fmgc.FMGCInternal.v2;
				if (tgt_v2 <= 30) {
					me.V2trgt = 0 - me.ASI;
				} else if (tgt_v2 >= 420) {
					me.V2trgt = 390 - me.ASI;
				} else {
					me.V2trgt = tgt_v2 - 30 - me.ASI;
				}
			
				me.SPDv2trgtdiff = tgt_v2 - ind_spd;
			
				if (pts.Position.gearAglFt.getValue() < 55 and fmgc.FMGCInternal.phase <= 2 and me.SPDv2trgtdiff >= -42 and me.SPDv2trgtdiff <= 42) {
					me["ASI_target"].show();
					me["ASI_target"].setTranslation(0, me.V2trgt * -6.6);
					me["ASI_digit_UP"].setText(sprintf("%3.0f", fmgc.FMGCInternal.v2));
				} else if (pts.Position.gearAglFt.getValue() < 55 and fmgc.FMGCInternal.phase <= 2) {
					me["ASI_target"].hide();
					me["ASI_digit_UP"].setText(sprintf("%3.0f", fmgc.FMGCInternal.v2));
				}
			}
			
			if (fbw.FBW.Computers.fac1.getValue() or fbw.FBW.Computers.fac2.getValue()) {
				if (flap_config.getValue() == '1') {
					me["F_target"].hide();
					me["clean_speed"].hide();
					
					tgt_S = fmgc.FMGCInternal.slat;
				
					if (tgt_S <= 30) {
						me.Strgt = 0 - me.ASI;
					} else if (tgt_S >= 420) {
						me.Strgt = 390 - me.ASI;
					} else {
						me.Strgt = tgt_S - 30 - me.ASI;
					}
				
					me.SPDstrgtdiff = tgt_S - ind_spd;
				
					if (me.SPDstrgtdiff >= -42 and me.SPDstrgtdiff <= 42 and gear_agl.getValue() >= 400) {
						me["S_target"].show();
						me["S_target"].setTranslation(0, me.Strgt * -6.6);
					} else {
						me["S_target"].hide();
					}
					
					tgt_flap = 200;
					me.flaptrgt = tgt_flap - 30 - me.ASI;
					
					me.SPDflaptrgtdiff = tgt_flap - ind_spd;
				
					if (me.SPDflaptrgtdiff >= -42 and me.SPDflaptrgtdiff <= 42) {
						me["flap_max"].show();
						me["flap_max"].setTranslation(0, me.flaptrgt * -6.6);
					} else {
						me["flap_max"].hide();
					}
				} else if (flap_config.getValue() == '2') {
					me["S_target"].hide();
					me["clean_speed"].hide();
					
					tgt_F = fmgc.FMGCInternal.flap2;
					
					if (tgt_F <= 30) {
						me.Ftrgt = 0 - me.ASI;
					} else if (tgt_F >= 420) {
						me.Ftrgt = 390 - me.ASI;
					} else {
						me.Ftrgt = tgt_F - 30 - me.ASI;
					}
				
					me.SPDftrgtdiff = tgt_F - ind_spd;
				
					if (me.SPDftrgtdiff >= -42 and me.SPDftrgtdiff <= 42 and gear_agl.getValue() >= 400) {
						me["F_target"].show();
						me["F_target"].setTranslation(0, me.Ftrgt * -6.6);
					} else {
						me["F_target"].hide();
					}
					
					tgt_flap = 185;
					me.flaptrgt = tgt_flap - 30 - me.ASI;
					
					me.SPDflaptrgtdiff = tgt_flap - ind_spd;
				
					if (me.SPDflaptrgtdiff >= -42 and me.SPDflaptrgtdiff <= 42) {
						me["flap_max"].show();
						me["flap_max"].setTranslation(0, me.flaptrgt * -6.6);
					} else {
						me["flap_max"].hide();
					}
				} else if (flap_config.getValue() == '3') {
					me["S_target"].hide();
					me["clean_speed"].hide();
					
					tgt_F = fmgc.FMGCInternal.flap3;
						
					if (tgt_F <= 30) {
						me.Ftrgt = 0 - me.ASI;
					} else if (tgt_F >= 420) {
						me.Ftrgt = 390 - me.ASI;
					} else {
						me.Ftrgt = tgt_F - 30 - me.ASI;
					}
				
					me.SPDftrgtdiff = tgt_F - ind_spd;
				
					if (me.SPDftrgtdiff >= -42 and me.SPDftrgtdiff <= 42 and gear_agl.getValue() >= 400) {
						me["F_target"].show();
						me["F_target"].setTranslation(0, me.Ftrgt * -6.6);
					} else {
						me["F_target"].hide();
					}
					
					tgt_flap = 177;
					me.flaptrgt = tgt_flap - 30 - me.ASI;
					
					me.SPDflaptrgtdiff = tgt_flap - ind_spd;
				
					if (me.SPDflaptrgtdiff >= -42 and me.SPDflaptrgtdiff <= 42) {
						me["flap_max"].show();
						me["flap_max"].setTranslation(0, me.flaptrgt * -6.6);
					} else {
						me["flap_max"].hide();
					}
				} else if (flap_config.getValue() == '4') {
					me["S_target"].hide();
					me["F_target"].hide();
					me["clean_speed"].hide();	
					me["flap_max"].hide();
				} else {
					me["S_target"].hide();
					me["F_target"].hide();
					
					tgt_clean = fmgc.FMGCInternal.clean;
					
					me.cleantrgt = tgt_clean - 30 - me.ASI;
					me.SPDcleantrgtdiff = tgt_clean - ind_spd;
				
					if (me.SPDcleantrgtdiff >= -42 and me.SPDcleantrgtdiff <= 42) {
						me["clean_speed"].show();
						me["clean_speed"].setTranslation(0, me.cleantrgt * -6.6);
					} else {
						me["clean_speed"].hide();
					}	
					
					tgt_flap = 230;
					me.flaptrgt = tgt_flap - 30 - me.ASI;
					
					me.SPDflaptrgtdiff = tgt_flap - ind_spd;
				
					if (me.SPDflaptrgtdiff >= -42 and me.SPDflaptrgtdiff <= 42) {
						me["flap_max"].show();
						me["flap_max"].setTranslation(0, me.flaptrgt * -6.6);
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
			
			me.ASItrend = dmc.DMController.DMCs[0].outputs[6].getValue() - me.ASI;
			me["ASI_trend_up"].setTranslation(0, math.clamp(me.ASItrend, 0, 50) * -6.6);
			me["ASI_trend_down"].setTranslation(0, math.clamp(me.ASItrend, -50, 0) * -6.6);
			
			if (me.ASItrend >= 2) {
				me["ASI_trend_up"].show();
				me["ASI_trend_down"].hide();
			} else if (me.ASItrend <= -2) {
				me["ASI_trend_down"].show();
				me["ASI_trend_up"].hide();
			} else {
				me["ASI_trend_up"].hide();
				me["ASI_trend_down"].hide();
			}
		} else {
			me["ASI_group"].hide();
			me["ASI_error"].show();
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
		
		if (dmc.DMController.DMCs[0].outputs[2] != nil) {
			ind_mach = dmc.DMController.DMCs[0].outputs[2].getValue();
			me["machError"].hide();
			if (ind_mach >= 0.5) {
				me["ASI_mach_decimal"].show();
				me["ASI_mach"].show();
			} else {
				me["ASI_mach_decimal"].hide();
				me["ASI_mach"].hide();
			}
			
			if (ind_mach >= 0.999) {
				me["ASI_mach"].setText("999");
			} else {
				me["ASI_mach"].setText(sprintf("%3.0f", ind_mach * 1000));
			}
		} else {
			me["machError"].show();
		}
		
		# Altitude
		if (dmc.DMController.DMCs[0].outputs[1] != nil) {
			me["ALT_error"].hide();
			me["ALT_frame"].setColor(1,1,1);
			me["ALT_group"].show();
			me["ALT_tens"].show();
			me["ALT_box"].show();
			me["ALT_group2"].show();
			me["ALT_scale"].show();
			
			me.altitude = dmc.DMController.DMCs[0].outputs[1].getValue();
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
			
			me["ALT_digits"].setText(sprintf("%d", dmc.DMController.DMCs[0].outputs[3].getValue()));
			altTens = num(right(sprintf("%02d", me.altitude), 2));
			me["ALT_tens"].setTranslation(0, altTens * 1.392);
			
			ap_alt_cur = ap_alt.getValue();
			alt_diff_cur = dmc.DMController.DMCs[0].outputs[7].getValue();
			if (alt_diff_cur >= -565 and alt_diff_cur <= 565) {
				me["ALT_target"].setTranslation(0, (alt_diff_cur / 100) * -48.66856);
				me["ALT_target_digit"].setText(sprintf("%03d", math.round(ap_alt_cur / 100)));
				me["ALT_digit_UP"].hide();
				me["ALT_digit_DN"].hide();
				me["ALT_target"].show();
			} else if (alt_diff_cur < -565) {
				if (alt_std_mode.getValue() == 1) {
					if (ap_alt_cur < 10000) {
						me["ALT_digit_DN"].setText(sprintf("%s", "FL   " ~ ap_alt_cur / 100));
					} else {
						me["ALT_digit_DN"].setText(sprintf("%s", "FL " ~ ap_alt_cur / 100));
					}
				} else {
					me["ALT_digit_DN"].setText(sprintf("%5.0f", ap_alt_cur));
				}
				me["ALT_digit_DN"].show();
				me["ALT_digit_UP"].hide();
				me["ALT_target"].hide();
			} else if (alt_diff_cur > 565) {
				if (alt_std_mode.getValue() == 1) {
					if (ap_alt_cur < 10000) {
						me["ALT_digit_UP"].setText(sprintf("%s", "FL   " ~ ap_alt_cur / 100));
					} else {
						me["ALT_digit_UP"].setText(sprintf("%s", "FL " ~ ap_alt_cur / 100));
					}
				} else {
					me["ALT_digit_UP"].setText(sprintf("%5.0f", ap_alt_cur));
				}
				me["ALT_digit_UP"].show();
				me["ALT_digit_DN"].hide();
				me["ALT_target"].hide();
			}
			
			ground_diff_cur = -gear_agl.getValue();
			if (ground_diff_cur >= -565 and ground_diff_cur <= 565) {
				me["ground_ref"].setTranslation(0, (ground_diff_cur / 100) * -48.66856);
				me["ground_ref"].show();
			} else {
				me["ground_ref"].hide();
			}
			
			if (ground_diff_cur >= -565 and ground_diff_cur <= 565) {
				if ((fmgc.FMGCInternal.phase == 5 or fmgc.FMGCInternal.phase == 6) and !wow1.getValue() and !wow2.getValue()) { #add std too
					me["ground"].setTranslation(0, (ground_diff_cur / 100) * -48.66856);
					me["ground"].show();
				} else {
					me["ground"].hide();
				}
			} else {
				me["ground"].hide();
			}
			
			if (!ecam.altAlertFlash and !ecam.altAlertSteady) {
				alt_going1 = 0;
				amber_going1 = 0;
				me["ALT_box_flash"].hide();
				me["ALT_box_amber"].hide();
			} else {
				if (ecam.altAlertFlash) {
					if (alt_going1 == 1) {
						me["ALT_box_flash"].hide(); 
						altTimer1.stop();
					}
					if (amber_going1 == 0) {
						amber_going1 = 1;
					}
					if (amber_going1 == 1) {
						me["ALT_box_amber"].show();
						me["ALT_box"].hide();
						amberTimer1.start();
					}
					if (amberFlash1.getValue() == 1) {
						me["ALT_box_amber"].hide(); 
					} else {
						me["ALT_box_amber"].show(); 
					}
				} elsif (ecam.altAlertSteady) {
					if (amber_going1 == 1) {
						me["ALT_box"].show();
						me["ALT_box_amber"].hide();
						amberTimer1.stop();
					}
					if (alt_going1 == 0) {
						alt_going1 = 1;
					}
					if (alt_going1 == 1) {
						me["ALT_box_flash"].show(); 
						altTimer1.start();
					}
					if (altFlash1.getValue() == 1) {
						me["ALT_box_flash"].show(); 
					} else {
						me["ALT_box_flash"].hide(); 
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
		}
		
		me.updateCommon();
	},
};

var canvas_PFD_2 = {
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
	FMGC_max: 0,
	new: func(canvas_group, file) {
		var m = {parents: [canvas_PFD_2, canvas_PFD_base]};
		m.init(canvas_group, file);

		return m;
	},
	update: func() {
		fd2_act = fd2.getValue();
		pitch_mode_cur = pitch_mode.getValue();
		roll_mode_cur = roll_mode.getValue();
		pitch_cur = pitch.getValue();
		roll_cur = roll.getValue();
		wow1_act = wow1.getValue();
		wow2_act = wow2.getValue();
		
		# Errors
		if (systems.ADIRS.ADIRunits[1].operating == 1 or (systems.ADIRS.ADIRunits[2].operating == 1 and att_switch.getValue() == 1)) {
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
		me["spdLimError"].hide();
		
		# FD
		if (fd2_act == 1 and ((!wow1_act and !wow2_act and roll_mode_cur != " ") or roll_mode_cur != " ") and ap_trk_sw.getValue() == 0 and pitch_cur < 25 and pitch_cur > -13 and roll_cur < 45 and roll_cur > -45) {
			me["FD_roll"].show();
		} else {
			me["FD_roll"].hide();
		}
		
		if (fd2_act == 1 and ((!wow1_act and !wow2_act and pitch_mode_cur != " ") or pitch_mode_cur != " ") and ap_trk_sw.getValue() == 0 and pitch_cur < 25 and pitch_cur > -13 and roll_cur < 45 and roll_cur > -45) {
			me["FD_pitch"].show();
		} else {
			me["FD_pitch"].hide();
		}
		
		# If TRK FPA selected, display FPV on PFD2
		if (ap_trk_sw.getValue() == 0 ) {
			me["FPV"].hide();	
		} else {
			var aoa = me.getAOAForPFD2();
			if (aoa == nil or (systems.ADIRS.ADIRunits[1].operating != 1 and att_switch.getValue() == 0) or (systems.ADIRS.ADIRunits[2].operating != 1 and att_switch.getValue() == 1)) {
				me["FPV"].hide();	
			} else {
				var roll_deg = roll.getValue() or 0;	
				AICenter = me["AI_center"].getCenter();
				var track_x_translation = me.getTrackDiffPixels(track_diff);

				me.AI_fpv_trans.setTranslation(track_x_translation, math.clamp(aoa, -20, 20) * 12.5);
				me.AI_fpv_rot.setRotation(-roll_deg * D2R, AICenter);
				me["FPV"].setRotation(roll_deg * D2R); # It shouldn't be rotated, only the axis should be
				me["FPV"].show();
			}
		}

		# ILS
		if (ap_ils_mode2.getValue() == 1) {
			me["LOC_scale"].show();
			me["GS_scale"].show();
			split_ils = split("/", ils_data1.getValue());
			
			if (size(split_ils) < 2) {
				me["ils_freq"].setText(split_ils[0]);
				me["ils_freq"].show();
				me["ils_code"].hide();
				me["dme_dist"].hide();
				me["dme_dist_legend"].hide();
			} else {
				me["ils_code"].setText(split_ils[0]);
				me["ils_freq"].setText(split_ils[1]);
				me["ils_code"].show();
				me["ils_freq"].show();
			}
			
			if (dme_in_range.getValue() == 1) {
				dme_dist_data = dme_data.getValue();
				if (dme_dist_data < 20.0) {
					me["dme_dist"].setText(sprintf("%1.1f", dme_dist_data));
				} else {
					me["dme_dist"].setText(sprintf("%2.0f", dme_dist_data));
				}
				me["dme_dist"].show(); 
				me["dme_dist_legend"].show();
			}
		} else {
			me["LOC_scale"].hide();
			me["GS_scale"].hide();
			me["ils_code"].hide();
			me["ils_freq"].hide();
			me["dme_dist"].hide();
			me["dme_dist_legend"].hide();
			me["outerMarker"].hide();
			me["middleMarker"].hide();
			me["innerMarker"].hide();	
		}
		
		if (outer_marker.getValue() == 1) {
			me["outerMarker"].show();
			me["middleMarker"].hide();
			me["innerMarker"].hide();
		} else if (middle_marker.getValue()) {
			me["middleMarker"].show();
			me["outerMarker"].hide();
			me["innerMarker"].hide();
		} else if (inner_marker.getValue()) {
			me["innerMarker"].show();
			me["outerMarker"].hide();
			me["middleMarker"].hide();
		} else {
			me["outerMarker"].hide();
			me["middleMarker"].hide();
			me["innerMarker"].hide();	
		}
		
		if (ap_ils_mode2.getValue() == 1 and loc_in_range.getValue() == 1 and hasloc.getValue() == 1 and nav0_signalq.getValue() > 0.99) {
			me["LOC_pointer"].show();
		} else {
			me["LOC_pointer"].hide();
		}
		if (ap_ils_mode2.getValue() == 1 and gs_in_range.getValue() == 1 and hasgs.getValue() == 1 and nav0_signalq.getValue() > 0.99) {
			me["GS_pointer"].show();
		} else {
			me["GS_pointer"].hide();
		}
		
		if (ap_ils_mode2.getValue() == 0 and (appr_enabled.getValue() == 1 or loc_enabled.getValue() == 1 or vert_gs.getValue() == 2)) {
			if (ils_going2 == 0) {
				ils_going2 = 1;
			}
			if (ils_going2 == 1) {
				ilsTimer2.start();
				if (ilsFlash2.getValue() == 1) {
					me["ilsError"].show();	
				} else {
					me["ilsError"].hide();	
				}
			}
		} else {
			ilsTimer2.stop();
			ils_going2 = 0;
			me["ilsError"].hide();
		}
		
		# Airspeed
		# ind_spd = ind_spd_kt.getValue();
		# Subtract 30, since the scale starts at 30, but don"t allow less than 0, or more than 420 situations
		
		if (dmc.DMController.DMCs[1].outputs[0] != nil) {
			ind_spd = dmc.DMController.DMCs[1].outputs[0].getValue();
			me["ASI_error"].hide();
			me["ASI_frame"].setColor(1,1,1);
			me["ASI_group"].show();
			me["VLS_min"].hide();
			me["ALPHA_PROT"].hide();
			me["ALPHA_MAX"].hide();
			me["ALPHA_SW"].hide();
			
			if (ind_spd <= 30) {
				me.ASI = 0;
			} else if (ind_spd >= 420) {
				me.ASI = 390;
			} else {
				me.ASI = ind_spd - 30;
			}
			
			me.FMGC_max = fmgc.FMGCInternal.maxspeed;
			if (me.FMGC_max <= 30) {
				me.ASImax = 0 - me.ASI;
			} else if (me.FMGC_max >= 420) {
				me.ASImax = 390 - me.ASI;
			} else {
				me.ASImax = me.FMGC_max - 30 - me.ASI;
			}
			
			me["ASI_scale"].setTranslation(0, me.ASI * 6.6);
			
			if (fbw.FBW.Computers.fac1.getValue() or fbw.FBW.Computers.fac2.getValue()) {
				me["ASI_max"].setTranslation(0, me.ASImax * -6.6);
				me["ASI_max"].show();
			} else {
				me["ASI_max"].hide();
			}
			
			if (!fmgc.FMGCInternal.takeoffState and fmgc.FMGCInternal.phase >= 1 and !wow1.getValue() and !wow2.getValue()) {
				me.FMGC_vls = fmgc.FMGCInternal.vls_min;
				if (me.FMGC_vls <= 30) {
					me.VLSmin = 0 - me.ASI;
				} else if (me.FMGC_vls >= 420) {
					me.VLSmin = 390 - me.ASI;
				} else {
					me.VLSmin = me.FMGC_vls - 30 - me.ASI;
				}
				me.FMGC_prot = fmgc.FMGCInternal.alpha_prot;
				if (me.FMGC_prot <= 30) {
					me.ALPHAprot = 0 - me.ASI;
				} else if (me.FMGC_prot >= 420) {
					me.ALPHAprot = 390 - me.ASI;
				} else {
					me.ALPHAprot = me.FMGC_prot - 30 - me.ASI;
				}
				me.FMGC_max = fmgc.FMGCInternal.alpha_max;
				if (me.FMGC_max <= 30) {
					me.ALPHAmax = 0 - me.ASI;
				} else if (me.FMGC_max >= 420) {
					me.ALPHAmax = 390 - me.ASI;
				} else {
					me.ALPHAmax = me.FMGC_max - 30 - me.ASI;
				}
				me.FMGC_vsw = fmgc.FMGCInternal.vsw;
				if (me.FMGC_vsw <= 30) {
					me.ALPHAvsw = 0 - me.ASI;
				} else if (me.FMGC_vsw >= 420) {
					me.ALPHAvsw = 390 - me.ASI;
				} else {
					me.ALPHAvsw = me.FMGC_vsw - 30 - me.ASI;
				}
				
				if (fbw.FBW.Computers.fac1.getValue() or fbw.FBW.Computers.fac2.getValue()) {
					me["VLS_min"].setTranslation(0, me.VLSmin * -6.6);
					me["VLS_min"].show();
					if (getprop("/it-fbw/law") == 0) {
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
			
			tgt_ias = at_tgt_ias.getValue();
			tgt_mach = at_input_spd_mach.getValue();
			tgt_kts = at_input_spd_kts.getValue();
				
			if (managed_spd.getValue() == 1) {
				if (getprop("/FMGC/internal/decel") == 1) {
					if (fmgc.FMGCInternal.vappSpeedSet) {
						vapp = fmgc.FMGCInternal.vapp_appr;
					} else {
						vapp = fmgc.FMGCInternal.vapp;
					}
					tgt_ias = vapp;
					tgt_kts = vapp;
				} else if (fmgc.FMGCInternal.phase == 6) {
					clean = fmgc.FMGCInternal.clean;
					tgt_ias = clean;
					tgt_kts = clean;
				}
				
				me["ASI_target"].setColor(0.6901,0.3333,0.7450);
				me["ASI_digit_UP"].setColor(0.6901,0.3333,0.7450);
				me["ASI_decimal_UP"].setColor(0.6901,0.3333,0.7450);
				me["ASI_digit_DN"].setColor(0.6901,0.3333,0.7450);
				me["ASI_decimal_DN"].setColor(0.6901,0.3333,0.7450);
			} else {
				me["ASI_target"].setColor(0.0901,0.6039,0.7176);
				me["ASI_digit_UP"].setColor(0.0901,0.6039,0.7176);
				me["ASI_decimal_UP"].setColor(0.0901,0.6039,0.7176);
				me["ASI_digit_DN"].setColor(0.0901,0.6039,0.7176);
				me["ASI_decimal_DN"].setColor(0.0901,0.6039,0.7176);
			}
			
			if (tgt_ias <= 30) {
				me.ASItrgt = 0 - me.ASI;
			} else if (tgt_ias >= 420) {
				me.ASItrgt = 390 - me.ASI;
			} else {
				me.ASItrgt = tgt_ias - 30 - me.ASI;
			}
			
			me.ASItrgtdiff = tgt_ias - ind_spd;
			
			if (me.ASItrgtdiff >= -42 and me.ASItrgtdiff <= 42) {
				me["ASI_target"].setTranslation(0, me.ASItrgt * -6.6);
				me["ASI_digit_UP"].hide();
				me["ASI_decimal_UP"].hide();
				me["ASI_digit_DN"].hide();
				me["ASI_decimal_DN"].hide();
				me["ASI_target"].show();
			} else if (me.ASItrgtdiff < -42) {
				if (at_mach_mode.getValue() == 1) {
					me["ASI_digit_DN"].setText(sprintf("%3.0f", tgt_mach * 1000));
					me["ASI_decimal_UP"].hide();
					me["ASI_decimal_DN"].show();
				} else {
					me["ASI_digit_DN"].setText(sprintf("%3.0f", tgt_kts));
					me["ASI_decimal_UP"].hide();
					me["ASI_decimal_DN"].hide();
				}
				me["ASI_digit_DN"].show();
				me["ASI_digit_UP"].hide();
				me["ASI_target"].hide();
			} else if (me.ASItrgtdiff > 42) {
				if (at_mach_mode.getValue() == 1) {
					me["ASI_digit_UP"].setText(sprintf("%3.0f", tgt_mach * 1000));
					me["ASI_decimal_UP"].show();
					me["ASI_decimal_DN"].hide();
				} else {
					me["ASI_digit_UP"].setText(sprintf("%3.0f", tgt_kts));
					me["ASI_decimal_UP"].hide();
					me["ASI_decimal_DN"].hide();
				}
				me["ASI_digit_UP"].show();
				me["ASI_digit_DN"].hide();
				me["ASI_target"].hide();
			}
			
			if (fmgc.FMGCInternal.v1set) {
				tgt_v1 = fmgc.FMGCInternal.v1;
				if (tgt_v1 <= 30) {
					me.V1trgt = 0 - me.ASI;
				} else if (tgt_v1 >= 420) {
					me.V1trgt = 390 - me.ASI;
				} else {
					me.V1trgt = tgt_v1 - 30 - me.ASI;
				}
			
				me.SPDv1trgtdiff = tgt_v1 - ind_spd;
			
				if (pts.Position.gearAglFt.getValue() < 55 and fmgc.FMGCInternal.phase <= 2 and me.SPDv1trgtdiff >= -42 and me.SPDv1trgtdiff <= 42) {
					me["v1_group"].show();
					me["v1_text"].hide();
					me["v1_group"].setTranslation(0, me.V1trgt * -6.6);
				} else if (pts.Position.gearAglFt.getValue() < 55 and fmgc.FMGCInternal.phase <= 2) {
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
				tgt_vr = fmgc.FMGCInternal.vr;
				if (tgt_vr <= 30) {
					me.VRtrgt = 0 - me.ASI;
				} else if (tgt_vr >= 420) {
					me.VRtrgt = 390 - me.ASI;
				} else {
					me.VRtrgt = tgt_vr - 30 - me.ASI;
				}
			
				me.SPDvrtrgtdiff = tgt_vr - ind_spd;
			
				if (pts.Position.gearAglFt.getValue() < 55 and fmgc.FMGCInternal.phase <= 2 and me.SPDvrtrgtdiff >= -42 and me.SPDvrtrgtdiff <= 42) {
					me["vr_speed"].show();
					me["vr_speed"].setTranslation(0, me.VRtrgt * -6.6);
				} else {
					me["vr_speed"].hide();
				}
			} else {
				me["vr_speed"].hide();
			}
			
			if (fmgc.FMGCInternal.v2set) {
				tgt_v2 = fmgc.FMGCInternal.v2;
				if (tgt_v2 <= 30) {
					me.V2trgt = 0 - me.ASI;
				} else if (tgt_v2 >= 420) {
					me.V2trgt = 390 - me.ASI;
				} else {
					me.V2trgt = tgt_v2 - 30 - me.ASI;
				}
			
				me.SPDv2trgtdiff = tgt_v2 - ind_spd;
			
				if (pts.Position.gearAglFt.getValue() < 55 and fmgc.FMGCInternal.phase <= 2 and me.SPDv2trgtdiff >= -42 and me.SPDv2trgtdiff <= 42) {
					me["ASI_target"].show();
					me["ASI_target"].setTranslation(0, me.V2trgt * -6.6);
					me["ASI_digit_UP"].setText(sprintf("%3.0f", fmgc.FMGCInternal.v2));
				} else if (pts.Position.gearAglFt.getValue() < 55 and fmgc.FMGCInternal.phase <= 2) {
					me["ASI_target"].hide();
					me["ASI_digit_UP"].setText(sprintf("%3.0f", fmgc.FMGCInternal.v2));
				}
			}
			
			if (fbw.FBW.Computers.fac1.getValue() or fbw.FBW.Computers.fac2.getValue()) {
				if (flap_config.getValue() == '1') {
					me["F_target"].hide();
					me["clean_speed"].hide();
					
					tgt_S = fmgc.FMGCInternal.slat;
				
					if (tgt_S <= 30) {
						me.Strgt = 0 - me.ASI;
					} else if (tgt_S >= 420) {
						me.Strgt = 390 - me.ASI;
					} else {
						me.Strgt = tgt_S - 30 - me.ASI;
					}
				
					me.SPDstrgtdiff = tgt_S - ind_spd;
				
					if (me.SPDstrgtdiff >= -42 and me.SPDstrgtdiff <= 42 and gear_agl.getValue() >= 400) {
						me["S_target"].show();
						me["S_target"].setTranslation(0, me.Strgt * -6.6);
					} else {
						me["S_target"].hide();
					}
					
					tgt_flap = 200;
					me.flaptrgt = tgt_flap - 30 - me.ASI;
					
					me.SPDflaptrgtdiff = tgt_flap - ind_spd;
				
					if (me.SPDflaptrgtdiff >= -42 and me.SPDflaptrgtdiff <= 42) {
						me["flap_max"].show();
						me["flap_max"].setTranslation(0, me.flaptrgt * -6.6);
					} else {
						me["flap_max"].hide();
					}
				} else if (flap_config.getValue() == '2') {
					me["S_target"].hide();
					me["clean_speed"].hide();
					
					tgt_F = fmgc.FMGCInternal.flap2;
					
					if (tgt_F <= 30) {
						me.Ftrgt = 0 - me.ASI;
					} else if (tgt_F >= 420) {
						me.Ftrgt = 390 - me.ASI;
					} else {
						me.Ftrgt = tgt_F - 30 - me.ASI;
					}
				
					me.SPDftrgtdiff = tgt_F - ind_spd;
				
					if (me.SPDftrgtdiff >= -42 and me.SPDftrgtdiff <= 42 and gear_agl.getValue() >= 400) {
						me["F_target"].show();
						me["F_target"].setTranslation(0, me.Ftrgt * -6.6);
					} else {
						me["F_target"].hide();
					}
					
					tgt_flap = 185;
					me.flaptrgt = tgt_flap - 30 - me.ASI;
					
					me.SPDflaptrgtdiff = tgt_flap - ind_spd;
				
					if (me.SPDflaptrgtdiff >= -42 and me.SPDflaptrgtdiff <= 42) {
						me["flap_max"].show();
						me["flap_max"].setTranslation(0, me.flaptrgt * -6.6);
					} else {
						me["flap_max"].hide();
					}
				} else if (flap_config.getValue() == '3') {
					me["S_target"].hide();
					me["clean_speed"].hide();
					
					tgt_F = fmgc.FMGCInternal.flap3;
						
					if (tgt_F <= 30) {
						me.Ftrgt = 0 - me.ASI;
					} else if (tgt_F >= 420) {
						me.Ftrgt = 390 - me.ASI;
					} else {
						me.Ftrgt = tgt_F - 30 - me.ASI;
					}
				
					me.SPDftrgtdiff = tgt_F - ind_spd;
				
					if (me.SPDftrgtdiff >= -42 and me.SPDftrgtdiff <= 42 and gear_agl.getValue() >= 400) {
						me["F_target"].show();
						me["F_target"].setTranslation(0, me.Ftrgt * -6.6);
					} else {
						me["F_target"].hide();
					}
					
					tgt_flap = 177;
					me.flaptrgt = tgt_flap - 30 - me.ASI;
					
					me.SPDflaptrgtdiff = tgt_flap - ind_spd;
				
					if (me.SPDflaptrgtdiff >= -42 and me.SPDflaptrgtdiff <= 42) {
						me["flap_max"].show();
						me["flap_max"].setTranslation(0, me.flaptrgt * -6.6);
					} else {
						me["flap_max"].hide();
					}
				} else if (flap_config.getValue() == '4') {
					me["S_target"].hide();
					me["F_target"].hide();
					me["clean_speed"].hide();	
					me["flap_max"].hide();
				} else {
					me["S_target"].hide();
					me["F_target"].hide();
					
					tgt_clean = fmgc.FMGCInternal.clean;
					
					me.cleantrgt = tgt_clean - 30 - me.ASI;
					me.SPDcleantrgtdiff = tgt_clean - ind_spd;
				
					if (me.SPDcleantrgtdiff >= -42 and me.SPDcleantrgtdiff <= 42) {
						me["clean_speed"].show();
						me["clean_speed"].setTranslation(0, me.cleantrgt * -6.6);
					} else {
						me["clean_speed"].hide();
					}	
					
					tgt_flap = 230;
					me.flaptrgt = tgt_flap - 30 - me.ASI;
					
					me.SPDflaptrgtdiff = tgt_flap - ind_spd;
				
					if (me.SPDflaptrgtdiff >= -42 and me.SPDflaptrgtdiff <= 42) {
						me["flap_max"].show();
						me["flap_max"].setTranslation(0, me.flaptrgt * -6.6);
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
			
			me.ASItrend = dmc.DMController.DMCs[1].outputs[6].getValue() - me.ASI;
			me["ASI_trend_up"].setTranslation(0, math.clamp(me.ASItrend, 0, 50) * -6.6);
			me["ASI_trend_down"].setTranslation(0, math.clamp(me.ASItrend, -50, 0) * -6.6);
			
			if (me.ASItrend >= 2) {
				me["ASI_trend_up"].show();
				me["ASI_trend_down"].hide();
			} else if (me.ASItrend <= -2) {
				me["ASI_trend_down"].show();
				me["ASI_trend_up"].hide();
			} else {
				me["ASI_trend_up"].hide();
				me["ASI_trend_down"].hide();
			}
		} else {
			me["ASI_error"].show();
			me["ASI_group"].hide();
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
		
		if (dmc.DMController.DMCs[1].outputs[2] != nil) {
			ind_mach = dmc.DMController.DMCs[1].outputs[2].getValue();
			me["machError"].hide();
			if (ind_mach >= 0.5) {
				me["ASI_mach_decimal"].show();
				me["ASI_mach"].show();
			} else {
				me["ASI_mach_decimal"].hide();
				me["ASI_mach"].hide();
			}
			
			if (ind_mach >= 0.999) {
				me["ASI_mach"].setText("999");
			} else {
				me["ASI_mach"].setText(sprintf("%3.0f", ind_mach * 1000));
			}
		} else {
			me["machError"].show();
		}
		
		if (dmc.DMController.DMCs[1].outputs[1] != nil) {
			me["ALT_error"].hide();
			me["ALT_frame"].setColor(1,1,1);
			me["ALT_group"].show();
			me["ALT_tens"].show();
			me["ALT_box"].show();
			me["ALT_group2"].show();
			me["ALT_scale"].show();
			
			me.altitude = dmc.DMController.DMCs[1].outputs[1].getValue();
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
			
			me["ALT_digits"].setText(sprintf("%d", dmc.DMController.DMCs[1].outputs[3].getValue()));
			altTens = num(right(sprintf("%02d", me.altitude), 2));
			me["ALT_tens"].setTranslation(0, altTens * 1.392);
			
			ap_alt_cur = ap_alt.getValue();
			alt_diff_cur = dmc.DMController.DMCs[1].outputs[7].getValue();
			if (alt_diff_cur >= -565 and alt_diff_cur <= 565) {
				me["ALT_target"].setTranslation(0, (alt_diff_cur / 100) * -48.66856);
				me["ALT_target_digit"].setText(sprintf("%03d", math.round(ap_alt_cur / 100)));
				me["ALT_digit_UP"].hide();
				me["ALT_digit_DN"].hide();
				me["ALT_target"].show();
			} else if (alt_diff_cur < -565) {
				if (alt_std_mode.getValue() == 1) {
					if (ap_alt_cur < 10000) {
						me["ALT_digit_DN"].setText(sprintf("%s", "FL   " ~ ap_alt_cur / 100));
					} else {
						me["ALT_digit_DN"].setText(sprintf("%s", "FL " ~ ap_alt_cur / 100));
					}
				} else {
					me["ALT_digit_DN"].setText(sprintf("%5.0f", ap_alt_cur));
				}
				me["ALT_digit_DN"].show();
				me["ALT_digit_UP"].hide();
				me["ALT_target"].hide();
			} else if (alt_diff_cur > 565) {
				if (alt_std_mode.getValue() == 1) {
					if (ap_alt_cur < 10000) {
						me["ALT_digit_UP"].setText(sprintf("%s", "FL   " ~ ap_alt_cur / 100));
					} else {
						me["ALT_digit_UP"].setText(sprintf("%s", "FL " ~ ap_alt_cur / 100));
					}
				} else {
					me["ALT_digit_UP"].setText(sprintf("%5.0f", ap_alt_cur));
				}
				me["ALT_digit_UP"].show();
				me["ALT_digit_DN"].hide();
				me["ALT_target"].hide();
			}
			
			ground_diff_cur = -gear_agl.getValue();
			if (ground_diff_cur >= -565 and ground_diff_cur <= 565) {
				me["ground_ref"].setTranslation(0, (ground_diff_cur / 100) * -48.66856);
				me["ground_ref"].show();
			} else {
				me["ground_ref"].hide();
			}
			
			if (ground_diff_cur >= -565 and ground_diff_cur <= 565) {
				if ((fmgc.FMGCInternal.phase == 5 or fmgc.FMGCInternal.phase == 6) and !wow1.getValue() and !wow2.getValue()) { #add std too
					me["ground"].setTranslation(0, (ground_diff_cur / 100) * -48.66856);
					me["ground"].show();
				} else {
					me["ground"].hide();
				}
			} else {
				me["ground"].hide();
			}
			
			if (!ecam.altAlertFlash and !ecam.altAlertSteady) {
				alt_going2 = 0;
				amber_going2 = 0;
				me["ALT_box_flash"].hide();
				me["ALT_box_amber"].hide();
			} else {
				if (ecam.altAlertFlash) {
					if (alt_going2 == 1) {
						me["ALT_box_flash"].hide(); 
						altTimer2.stop();
					}
					if (amber_going2 == 0) {
						amber_going2 = 1;
					}
					if (amber_going2 == 1) {
						me["ALT_box_amber"].show();
						me["ALT_box"].hide();
						amberTimer2.start();
					}
					if (amberFlash2.getValue() == 1) {
						me["ALT_box_amber"].show(); 
					} else {
						me["ALT_box_amber"].hide(); 
					}
				} elsif (ecam.altAlertSteady) {
					if (amber_going2 == 1) {
						me["ALT_box"].show();
						me["ALT_box_amber"].hide();
						amberTimer2.stop();
					}
					if (alt_going2 == 0) {
						alt_going2 = 1;
					}
					if (alt_going2 == 1) {
						me["ALT_box_flash"].show(); 
						altTimer2.start();
					}
					if (altFlash2.getValue() == 1) {
						me["ALT_box_flash"].show(); 
					} else {
						me["ALT_box_flash"].hide(); 
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
		}
		
		me.updateCommon();
	},
};

var canvas_PFD_1_test = {
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
		var m = {parents: [canvas_PFD_1_test]};
		m.init(canvas_group, file);

		return m;
	},
	getKeys: func() {
		return ["Test_white","Test_text"];
	},
	update: func() {
		et = elapsedtime.getValue() or 0;
		if ((du1_test_time.getValue() + 1 >= et) and cpt_du_xfr.getValue() != 1) {
			me["Test_white"].show();
			me["Test_text"].hide();
		} else if ((du2_test_time.getValue() + 1 >= et) and cpt_du_xfr.getValue() != 0) {
			me["Test_white"].show();
			me["Test_text"].hide();
		} else {
			me["Test_white"].hide();
			me["Test_text"].show();
		}
	},
};

var canvas_PFD_2_test = {
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
		var m = {parents: [canvas_PFD_2_test]};
		m.init(canvas_group, file);

		return m;
	},
	getKeys: func() {
		return ["Test_white","Test_text"];
	},
	update: func() {
		et = elapsedtime.getValue() or 0;
		if ((du6_test_time.getValue() + 1 >= et) and fo_du_xfr.getValue() != 1) {
			me["Test_white"].show();
			me["Test_text"].hide();
		} else if ((du5_test_time.getValue() + 1 >= et) and fo_du_xfr.getValue() != 0) {
			me["Test_white"].show();
			me["Test_text"].hide();
		} else {
			me["Test_white"].hide();
			me["Test_text"].show();
		}
	},
};

var canvas_PFD_1_mismatch = {
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
		var m = {parents: [canvas_PFD_1_mismatch]};
		m.init(canvas_group, file);

		return m;
	},
	getKeys: func() {
		return ["ERRCODE"];
	},
	update: func() {
		me["ERRCODE"].setText(acconfig_mismatch.getValue());
	},
};

var canvas_PFD_2_mismatch = {
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
		var m = {parents: [canvas_PFD_2_mismatch]};
		m.init(canvas_group, file);

		return m;
	},
	getKeys: func() {
		return ["ERRCODE"];
	},
	update: func() {
		me["ERRCODE"].setText(acconfig_mismatch.getValue());
	},
};

setlistener("sim/signals/fdm-initialized", func {
	PFD1_display = canvas.new({
		"name": "PFD1",
		"size": [1024, 1024],
		"view": [1024, 1024],
		"mipmapping": 1
	});
	PFD2_display = canvas.new({
		"name": "PFD2",
		"size": [1024, 1024],
		"view": [1024, 1024],
		"mipmapping": 1
	});
	PFD1_display.addPlacement({"node": "pfd1.screen"});
	PFD2_display.addPlacement({"node": "pfd2.screen"});
	var group_pfd1 = PFD1_display.createGroup();
	var group_pfd1_test = PFD1_display.createGroup();
	var group_pfd1_mismatch = PFD1_display.createGroup();
	var group_pfd2 = PFD2_display.createGroup();
	var group_pfd2_test = PFD2_display.createGroup();
	var group_pfd2_mismatch = PFD2_display.createGroup();

	PFD_1 = canvas_PFD_1.new(group_pfd1, "Aircraft/A320-family/Models/Instruments/PFD/res/pfd.svg");
	PFD_1_test = canvas_PFD_1_test.new(group_pfd1_test, "Aircraft/A320-family/Models/Instruments/Common/res/du-test.svg");
	PFD_1_mismatch = canvas_PFD_1_mismatch.new(group_pfd1_mismatch, "Aircraft/A320-family/Models/Instruments/Common/res/mismatch.svg");
	PFD_2 = canvas_PFD_2.new(group_pfd2, "Aircraft/A320-family/Models/Instruments/PFD/res/pfd.svg");
	PFD_2_test = canvas_PFD_2_test.new(group_pfd2_test, "Aircraft/A320-family/Models/Instruments/Common/res/du-test.svg");
	PFD_2_mismatch = canvas_PFD_2_mismatch.new(group_pfd2_mismatch, "Aircraft/A320-family/Models/Instruments/Common/res/mismatch.svg");
	
	PFD_update.start();
	
	if (pfdrate.getValue() == 1) {
		rateApply();
	}
});

var rateApply = func {
	PFD_update.restart(0.05 * pfdrate.getValue());
}

var PFD_update = maketimer(0.05, func {
	canvas_PFD_base.update();
});

var showPFD1 = func {
	var dlg = canvas.Window.new([512, 512], "dialog").set("resize", 1);
	dlg.setCanvas(PFD1_display);
}

var showPFD2 = func {
	var dlg = canvas.Window.new([512, 512], "dialog").set("resize", 1);
	dlg.setCanvas(PFD2_display);
}

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

setlistener("/systems/electrical/bus/ac-ess", func() {
	canvas_PFD_base.updateDu1();
}, 0, 0);

setlistener("/systems/electrical/bus/ac-2", func() {
	canvas_PFD_base.updateDu6();
}, 0, 0);

# Flash managers
var ils_going1 = 0;
var ilsTimer1 = maketimer(0.50, func {
	if (!ilsFlash1.getBoolValue()) {
		ilsFlash1.setBoolValue(1);
	} else {
		ilsFlash1.setBoolValue(0);
	}
});

var ils_going2 = 0;
var ilsTimer2 = maketimer(0.50, func {
	if (!ilsFlash2.getBoolValue()) {
		ilsFlash2.setBoolValue(1);
	} else {
		ilsFlash2.setBoolValue(0);
	}
});

var qnh_going = 0;
var qnhTimer = maketimer(0.50, func {
	if (!qnhFlash.getBoolValue()) {
		qnhFlash.setBoolValue(1);
	} else {
		qnhFlash.setBoolValue(0);
	}
});

var alt_going1 = 0;
var altTimer1 = maketimer(0.50, func {
	if (!altFlash1.getBoolValue()) {
		altFlash1.setBoolValue(1);
	} else {
		altFlash1.setBoolValue(0);
	}
});

var alt_going2 = 0;
var altTimer2 = maketimer(0.50, func {
	if (!altFlash2.getBoolValue()) {
		altFlash2.setBoolValue(1);
	} else {
		altFlash2.setBoolValue(0);
	}
});

var amber_going1 = 0;
var amberTimer1 = maketimer(0.50, func {
	if (!amberFlash1.getBoolValue()) {
		amberFlash1.setBoolValue(1);
	} else {
		amberFlash1.setBoolValue(0);
	}
});

var amber_going2 = 0;
var amberTimer2 = maketimer(0.50, func {
	if (!amberFlash2.getBoolValue()) {
		amberFlash2.setBoolValue(1);
	} else {
		amberFlash2.setBoolValue(0);
	}
});

var dh_going = 0;
var dh_count = 0;
var dhTimer = maketimer(0.50, func {
	if (!dhFlash.getBoolValue()) {
		dhFlash.setBoolValue(1);
	} else {
		dhFlash.setBoolValue(0);
	}
	if (dh_count == 18) {
		dh_count = 0;
	} else {
		dh_count = dh_count + 1;
	}
});
