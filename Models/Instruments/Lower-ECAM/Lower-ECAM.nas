# A3XX Lower ECAM Canvas

# Copyright (c) 2020 Josh Davidson (Octal450)

var lowerECAM_apu = nil;
var lowerECAM_bleed = nil;
var lowerECAM_cond = nil;
var lowerECAM_crz = nil;
var lowerECAM_door = nil;
var lowerECAM_elec = nil;
var lowerECAM_eng = nil;
var lowerECAM_fctl = nil;
var lowerECAM_fuel = nil;
var lowerECAM_hyd = nil;
var lowerECAM_press = nil;
var lowerECAM_status = nil;
var lowerECAM_wheel = nil;
var lowerECAM_test = nil;
var lowerECAM_display = nil;
var page = "fctl";
var oat = getprop("environment/temperature-degc");
var blue_psi = 0;
var green_psi = 0;
var yellow_psi = 0;
var autobrakemode = 0;
var nosegear = 0;
var leftgear = 0;
var rightgear = 0;
var leftdoor = 0;
var rightdoor = 0;
var nosedoor = 0;
var gearlvr = 0;
var elapsedtime = 0;
var tr1_v = 0;
var tr1_a = 0;
var tr2_v = 0;
var tr2_a = 0;
var essTramps = 0;
var essTrvolts = 0;

# Conversion factor pounds to kilogram
LBS2KGS = 0.4535924;

# Fetch Nodes
var acconfig_weight_kgs = props.globals.getNode("systems/acconfig/options/weight-kgs", 1);
var elapsed_sec = props.globals.getNode("sim/time/elapsed-sec", 1);
var ac2 = props.globals.getNode("systems/electrical/bus/ac-2", 1);
var autoconfig_running = props.globals.getNode("systems/acconfig/autoconfig-running", 1);
var ac1_src = props.globals.getNode("systems/electrical/ac1-src", 1);
var ac2_src = props.globals.getNode("systems/electrical/ac2-src", 1);
var lighting_du4 = props.globals.getNode("controls/lighting/DU/du4", 1);
var ecam_page = props.globals.getNode("ECAM/Lower/page", 1);
var hour = props.globals.getNode("sim/time/utc/hour", 1);
var minute = props.globals.getNode("sim/time/utc/minute", 1);
var apu_flap = props.globals.getNode("controls/apu/inlet-flap/position-norm", 1);
var apu_rpm = props.globals.getNode("engines/engine[2]/n1", 1);
var apu_egt = props.globals.getNode("systems/apu/egt-degC", 1);
var door_left = props.globals.getNode("ECAM/Lower/door-left", 1);
var door_right = props.globals.getNode("ECAM/Lower/door-right", 1);
var door_nose_left = props.globals.getNode("ECAM/Lower/door-nose-left", 1);
var door_nose_right = props.globals.getNode("ECAM/Lower/door-nose-right", 1);
var apu_rpm_rot = props.globals.getNode("ECAM/Lower/APU-N", 1);
var apu_egt_rot = props.globals.getNode("ECAM/Lower/APU-EGT", 1);
var oil_qt1 = props.globals.getNode("ECAM/Lower/Oil-QT[0]", 1);
var oil_qt2 = props.globals.getNode("ECAM/Lower/Oil-QT[1]", 1);
var oil_psi1 = props.globals.getNode("ECAM/Lower/Oil-PSI[0]", 1);
var oil_psi2 = props.globals.getNode("ECAM/Lower/Oil-PSI[1]", 1);
var bleedapu = props.globals.getNode("systems/pneumatic/bleedapu", 1);
var oil_psi_actual1 = props.globals.getNode("engines/engine[0]/oil-psi-actual", 1);
var oil_psi_actual2 = props.globals.getNode("engines/engine[1]/oil-psi-actual", 1);
var aileron_ind_left = props.globals.getNode("ECAM/Lower/aileron-ind-left", 1);
var aileron_ind_right = props.globals.getNode("ECAM/Lower/aileron-ind-right", 1);
var elevator_ind_left = props.globals.getNode("ECAM/Lower/elevator-ind-left", 1);
var elevator_ind_right = props.globals.getNode("ECAM/Lower/elevator-ind-right", 1);
var elevator_trim_deg = props.globals.getNode("ECAM/Lower/elevator-trim-deg", 1);
var final_deg = props.globals.getNode("fdm/jsbsim/hydraulics/rudder/final-deg", 1);
var temperature_degc = props.globals.getNode("environment/temperature-degc", 1);
var gw = props.globals.getNode("FMGC/internal/gw", 1);
var tank3_content_lbs = props.globals.getNode("fdm/jsbsim/propulsion/tank[2]/contents-lbs", 1);
var apu_master = props.globals.getNode("controls/apu/master", 1);
var ir2_knob = props.globals.getNode("controls/adirs/ir[1]/knob", 1);
var switch_bleedapu = props.globals.getNode("controls/pneumatic/switches/bleedapu", 1);
var pneumatic_xbleed_state = props.globals.getNode("systems/pneumatic/xbleed-state", 1);
var xbleed = props.globals.getNode("systems/pneumatic/xbleed", 1);
var hp_valve1_state = props.globals.getNode("systems/pneumatic/hp-valve-1-state", 1);
var hp_valve2_state = props.globals.getNode("systems/pneumatic/hp-valve-2-state", 1);
var hp_valve1 = props.globals.getNode("systems/pneumatic/hp-valve-1", 1);
var hp_valve2 = props.globals.getNode("systems/pneumatic/hp-valve-2", 1);
var eng_valve1_state = props.globals.getNode("systems/pneumatic/eng-valve-1-state", 1);
var eng_valve2_state = props.globals.getNode("systems/pneumatic/eng-valve-2-state", 1);
var eng_valve1 = props.globals.getNode("systems/pneumatic/eng-valve-1", 1);
var eng_valve2 = props.globals.getNode("systems/pneumatic/eng-valve-2", 1);
var precooler1_psi = props.globals.getNode("systems/pneumatic/precooler-1-psi", 1);
var precooler2_psi = props.globals.getNode("systems/pneumatic/precooler-2-psi", 1);
var precooler1_temp = props.globals.getNode("systems/pneumatic/precooler-1-temp", 1);
var precooler2_temp = props.globals.getNode("systems/pneumatic/precooler-2-temp", 1);
var precooler1_ovht = props.globals.getNode("systems/pneumatic/precooler-1-ovht", 1);
var precooler2_ovht = props.globals.getNode("systems/pneumatic/precooler-2-ovht", 1);
var gs_kt = props.globals.getNode("velocities/groundspeed-kt", 1);
var switch_wing_aice = props.globals.getNode("controls/switches/wing", 1);
var deice_wing = props.globals.getNode("controls/deice/wing", 1);
var eng1_n2_actual = props.globals.getNode("engines/engine[0]/n2-actual", 1);
var eng2_n2_actual = props.globals.getNode("engines/engine[1]/n2-actual", 1);
var pack1_out_temp = props.globals.getNode("systems/pressurization/pack-1-out-temp", 1);
var pack2_out_temp = props.globals.getNode("systems/pressurization/pack-2-out-temp", 1);
var pack1_comp_out_temp = props.globals.getNode("systems/pressurization/pack-1-comp-out-temp", 1);
var pack2_comp_out_temp = props.globals.getNode("systems/pressurization/pack-2-comp-out-temp", 1);
var pack1_bypass = props.globals.getNode("systems/pressurization/pack-1-bypass", 1);
var pack2_bypass = props.globals.getNode("systems/pressurization/pack-2-bypass", 1);
var pack1_flow = props.globals.getNode("systems/pressurization/pack-1-flow", 1);
var pack2_flow = props.globals.getNode("systems/pressurization/pack-2-flow", 1);
var pack1_valve = props.globals.getNode("systems/pressurization/pack-1-valve", 1);
var pack2_valve = props.globals.getNode("systems/pressurization/pack-2-valve", 1);
var switch_pack1 = props.globals.getNode("controls/pneumatic/switches/pack1", 1);
var switch_pack2 = props.globals.getNode("controls/pneumatic/switches/pack2", 1);
var oil_qt1_actual = props.globals.getNode("engines/engine[0]/oil-qt-actual", 1);
var oil_qt2_actual = props.globals.getNode("engines/engine[1]/oil-qt-actual", 1);
var fuel_used_lbs1 = props.globals.getNode("systems/fuel/fuel-used-1", 1);
var fuel_used_lbs2 = props.globals.getNode("systems/fuel/fuel-used-2", 1);
var doorL1_pos = props.globals.getNode("sim/model/door-positions/doorl1/position-norm", 1);
var doorR1_pos = props.globals.getNode("sim/model/door-positions/doorr1/position-norm", 1);
var doorL4_pos = props.globals.getNode("sim/model/door-positions/doorl4/position-norm", 1);
var doorR4_pos = props.globals.getNode("sim/model/door-positions/doorr4/position-norm", 1);
var cargobulk_pos = props.globals.getNode("sim/model/door-positions/cargobulk/position-norm", 1);
var cargofwd_pos = props.globals.getNode("sim/model/door-positions/cargofwd/position-norm", 1);
var cargoaft_pos = props.globals.getNode("sim/model/door-positions/cargoaft/position-norm", 1);

# Electrical nodes
var apu_volts = props.globals.getNode("systems/electrical/sources/apu/output-volt", 1);
var apu_hz = props.globals.getNode("systems/electrical/sources/apu/output-hertz", 1);
var gen_apu = props.globals.getNode("systems/electrical/relay/apu-glc/contact-pos", 1);
var switch_bat1 = props.globals.getNode("controls/electrical/switches/bat-1", 1);
var switch_bat2 = props.globals.getNode("controls/electrical/switches/bat-2", 1);
var bat1_amps = props.globals.getNode("systems/electrical/sources/bat-1/amp", 1);
var bat2_amps = props.globals.getNode("systems/electrical/sources/bat-2/amp", 1);
var bat1_volts = props.globals.getNode("systems/electrical/sources/bat-1/volt", 1);
var bat2_volts = props.globals.getNode("systems/electrical/sources/bat-2/volt", 1);
var bat1_fault = props.globals.getNode("systems/electrical/light/bat-1-fault", 1);
var bat2_fault = props.globals.getNode("systems/electrical/light/bat-2-fault", 1);
var emerGenVolts = props.globals.getNode("systems/electrical/relay/emer-glc/output", 1);
var emerGenHz = props.globals.getNode("systems/electrical/sources/emer-gen/output-hertz", 1);
var tr1_volts = props.globals.getNode("systems/electrical/relay/tr-contactor-1/output", 1);
var tr2_volts = props.globals.getNode("systems/electrical/relay/tr-contactor-2/output", 1);
var tr1_amps = props.globals.getNode("systems/electrical/relay/tr-contactor-1/output-amp", 1);
var tr2_amps = props.globals.getNode("systems/electrical/relay/tr-contactor-2/output-amp", 1);
var dc1 = props.globals.getNode("systems/electrical/bus/dc-1", 1);
var dc2 = props.globals.getNode("systems/electrical/bus/dc-2", 1);
var dc_ess = props.globals.getNode("systems/electrical/bus/dc-ess", 1);
var switch_emer_gen = props.globals.getNode("systems/electrical/sources/emer-gen/output-volt", 1);
var switch_gen1 = props.globals.getNode("controls/electrical/switches/gen-1", 1);
var switch_gen2 = props.globals.getNode("controls/electrical/switches/gen-2", 1);
var gen1_volts = props.globals.getNode("systems/electrical/sources/idg-1/output-volt", 1);
var gen2_volts = props.globals.getNode("systems/electrical/sources/idg-2/output-volt", 1);
var gen1_hz = props.globals.getNode("systems/electrical/sources/idg-1/output-hertz", 1);
var gen2_hz = props.globals.getNode("systems/electrical/sources/idg-2/output-hertz", 1);
var ext_volts = props.globals.getNode("systems/electrical/sources/ext/output-volt", 1);
var ext_hz = props.globals.getNode("systems/electrical/sources/ext/output-hertz", 1);
var galleyshed = props.globals.getNode("systems/electrical/extra/galleyshed", 1);
var switch_galley = props.globals.getNode("controls/electrical/switches/galley", 1);
var dcbat = props.globals.getNode("systems/electrical/bus/dc-bat", 1);
var ac_ess = props.globals.getNode("systems/electrical/bus/ac-ess", 1);
var ac1 = props.globals.getNode("systems/electrical/bus/ac-1", 1);
var ac2 = props.globals.getNode("systems/electrical/bus/ac-2", 1);
var switch_ac_ess_feed = props.globals.getNode("controls/electrical/switches/ac-ess-feed", 1);
var tr1_fault = props.globals.getNode("systems/failures/electrical/tr-1", 1);
var tr2_fault = props.globals.getNode("systems/failures/electrical/tr-2", 1);
var essTrVolt = props.globals.getNode("systems/electrical/relay/dc-ess-feed-tr/output", 1);
var essTrAmp = props.globals.getNode("systems/electrical/relay/dc-ess-feed-tr/output-amp", 1);

# Hydraulic
var blue_psi = 0;
var green_psi = 0;
var yellow_psi = 0;
var y_resv_lo_air_press = props.globals.getNode("systems/hydraulic/yellow-resv-lo-air-press", 1);
var b_resv_lo_air_press = props.globals.getNode("systems/hydraulic/blue-resv-lo-air-press", 1);
var g_resv_lo_air_press = props.globals.getNode("systems/hydraulic/green-resv-lo-air-press", 1);
var elec_pump_y_ovht = props.globals.getNode("systems/hydraulic/elec-pump-yellow-ovht", 1);
var elec_pump_b_ovht = props.globals.getNode("systems/hydraulic/elec-pump-blue-ovht", 1);
var rat_deployed = props.globals.getNode("controls/hydraulic/rat-deployed", 1);
var y_resv_ovht = props.globals.getNode("systems/hydraulic/yellow-resv-ovht", 1);
var b_resv_ovht = props.globals.getNode("systems/hydraulic/blue-resv-ovht", 1);
var g_resv_ovht = props.globals.getNode("systems/hydraulic/green-resv-ovht", 1);
var askidsw = 0;
var brakemode = 0;
var accum = 0;
var L1BrakeTempc = props.globals.getNode("gear/gear[1]/L1brake-temp-degc", 1);
var L2BrakeTempc = props.globals.getNode("gear/gear[1]/L2brake-temp-degc", 1);
var R3BrakeTempc = props.globals.getNode("gear/gear[2]/R3brake-temp-degc", 1);
var R4BrakeTempc = props.globals.getNode("gear/gear[2]/R4brake-temp-degc", 1);

var eng1_running = props.globals.getNode("engines/engine[0]/running", 1);
var eng2_running = props.globals.getNode("engines/engine[1]/running", 1);
var switch_cart = props.globals.getNode("controls/electrical/ground-cart", 1);
var total_psi = props.globals.getNode("systems/pneumatic/total-psi", 1);
var spoiler_L1 = props.globals.getNode("fdm/jsbsim/hydraulics/spoiler-l1/final-deg", 1);
var spoiler_L2 = props.globals.getNode("fdm/jsbsim/hydraulics/spoiler-l2/final-deg", 1);
var spoiler_L3 = props.globals.getNode("fdm/jsbsim/hydraulics/spoiler-l3/final-deg", 1);
var spoiler_L4 = props.globals.getNode("fdm/jsbsim/hydraulics/spoiler-l4/final-deg", 1);
var spoiler_L5 = props.globals.getNode("fdm/jsbsim/hydraulics/spoiler-l5/final-deg", 1);
var spoiler_R1 = props.globals.getNode("fdm/jsbsim/hydraulics/spoiler-r1/final-deg", 1);
var spoiler_R2 = props.globals.getNode("fdm/jsbsim/hydraulics/spoiler-r2/final-deg", 1);
var spoiler_R3 = props.globals.getNode("fdm/jsbsim/hydraulics/spoiler-r3/final-deg", 1);
var spoiler_R4 = props.globals.getNode("fdm/jsbsim/hydraulics/spoiler-r4/final-deg", 1);
var spoiler_R5 = props.globals.getNode("fdm/jsbsim/hydraulics/spoiler-r5/final-deg", 1);
var spoiler_L1_fail = props.globals.getNode("systems/failures/spoiler-l1", 1);
var spoiler_L2_fail = props.globals.getNode("systems/failures/spoiler-l2", 1);
var spoiler_L3_fail = props.globals.getNode("systems/failures/spoiler-l3", 1);
var spoiler_L4_fail = props.globals.getNode("systems/failures/spoiler-l4", 1);
var spoiler_L5_fail = props.globals.getNode("systems/failures/spoiler-l5", 1);
var spoiler_R1_fail = props.globals.getNode("systems/failures/spoiler-r1", 1);
var spoiler_R2_fail = props.globals.getNode("systems/failures/spoiler-r2", 1);
var spoiler_R3_fail = props.globals.getNode("systems/failures/spoiler-r3", 1);
var spoiler_R4_fail = props.globals.getNode("systems/failures/spoiler-r4", 1);
var spoiler_R5_fail = props.globals.getNode("systems/failures/spoiler-r5", 1);
var elac1 = props.globals.getNode("systems/fctl/elac1", 1);
var elac2 = props.globals.getNode("systems/fctl/elac2", 1);
var sec1 = props.globals.getNode("systems/fctl/sec1", 1);
var sec2 = props.globals.getNode("systems/fctl/sec2", 1);
var sec3 = props.globals.getNode("systems/fctl/sec3", 1);
var elac1_fail = props.globals.getNode("systems/failures/elac1", 1);
var elac2_fail = props.globals.getNode("systems/failures/elac2", 1);
var sec1_fail = props.globals.getNode("systems/failures/sec1", 1);
var sec2_fail = props.globals.getNode("systems/failures/sec2", 1);
var sec3_fail = props.globals.getNode("systems/failures/sec3", 1);
var eng1_n1 = props.globals.getNode("engines/engine[0]/n1-actual", 1);
var eng2_n1 = props.globals.getNode("engines/engine[1]/n1-actual", 1);
var total_fuel_lbs = props.globals.getNode("consumables/fuel/total-fuel-lbs", 1);
var fadec1 = props.globals.getNode("systems/fadec/powered1", 1);
var fadec2 = props.globals.getNode("systems/fadec/powered2", 1);
var fuel_flow1 = props.globals.getNode("engines/engine[0]/fuel-flow_actual", 1);
var fuel_flow2 = props.globals.getNode("engines/engine[1]/fuel-flow_actual", 1);
var fuel_left_outer_temp = props.globals.getNode("consumables/fuel/tank[0]/temperature_degC", 1);
var fuel_left_inner_temp = props.globals.getNode("consumables/fuel/tank[1]/temperature_degC", 1);
var fuel_right_outer_temp = props.globals.getNode("consumables/fuel/tank[3]/temperature_degC", 1);
var fuel_right_inner_temp = props.globals.getNode("consumables/fuel/tank[4]/temperature_degC", 1);
var cutoff_switch1 = props.globals.getNode("controls/engines/engine[0]/cutoff-switch", 1);
var cutoff_switch2 = props.globals.getNode("controls/engines/engine[1]/cutoff-switch", 1);
var fuel_xfeed = props.globals.getNode("controls/fuel/x-feed", 1);
var tank0pump1 = props.globals.getNode("controls/fuel/tank0pump1", 1);
var tank0pump2 = props.globals.getNode("controls/fuel/tank0pump2", 1);
var tank1pump1 = props.globals.getNode("controls/fuel/tank1pump1", 1);
var tank1pump2 = props.globals.getNode("controls/fuel/tank1pump2", 1);
var tank2pump1 = props.globals.getNode("controls/fuel/tank2pump1", 1);
var tank2pump2 = props.globals.getNode("controls/fuel/tank2pump2", 1);
var autobreak_mode = props.globals.getNode("controls/autobrake/mode", 1);
var gear1_pos = props.globals.getNode("gear/gear[0]/position-norm", 1);
var gear2_pos = props.globals.getNode("gear/gear[1]/position-norm", 1);
var gear3_pos = props.globals.getNode("gear/gear[2]/position-norm", 1);
var gear_door_L = props.globals.getNode("systems/hydraulic/gear/door-left", 1);
var gear_door_R = props.globals.getNode("systems/hydraulic/gear/door-right", 1);
var gear_door_N = props.globals.getNode("systems/hydraulic/gear/door-nose", 1);
var gear_down = props.globals.getNode("controls/gear/gear-down", 1);
var press_vs_norm = props.globals.getNode("systems/pressurization/vs-norm", 1);
var cabinalt = props.globals.getNode("systems/pressurization/cabinalt-norm", 1);
var gear0_wow = props.globals.getNode("gear/gear[0]/wow", 1);

# Create Nodes:
var apu_load = props.globals.initNode("/systems/electrical/extra/apu-load", 0, "DOUBLE");
var gen1_load = props.globals.initNode("/systems/electrical/extra/gen1-load", 0, "DOUBLE");
var gen2_load = props.globals.initNode("/systems/electrical/extra/gen2-load", 0, "DOUBLE");
var du4_test = props.globals.initNode("/instrumentation/du/du4-test", 0, "BOOL");
var du4_test_time = props.globals.initNode("/instrumentation/du/du4-test-time", 0, "DOUBLE");
var du4_test_amount = props.globals.initNode("/instrumentation/du/du4-test-amount", 0, "DOUBLE");
var du4_offtime = props.globals.initNode("/instrumentation/du/du4-off-time", 0.0, "DOUBLE");

var canvas_lowerECAM_base = {
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
	getKeys: func() {
		return [];
	},
	updateDu4: func() {
		var elapsedtime = elapsed_sec.getValue();
		
		if (ac2.getValue() >= 110) {
			if (du4_offtime.getValue() + 3 < elapsedtime) {
				if (gear0_wow.getValue() == 1) {
					if (autoconfig_running.getValue() != 1 and du4_test.getValue() != 1) {
						du4_test.setValue(1);
						du4_test_amount.setValue(math.round((rand() * 5 ) + 35, 0.1));
						du4_test_time.setValue(elapsedtime);
					} else if (autoconfig_running.getValue() == 1 and du4_test.getValue() != 1) {
						du4_test.setValue(1);
						du4_test_amount.setValue(math.round((rand() * 5 ) + 35, 0.1));
						du4_test_time.setValue(elapsedtime - 30);
					}
				} else {
					du4_test.setValue(1);
					du4_test_amount.setValue(0);
					du4_test_time.setValue(-100);
				}
			}
		} else {
			du4_test.setValue(0);
			du4_offtime.setValue(elapsedtime);
		}
	},
	update: func() {
		var elapsedtime = elapsed_sec.getValue();
		
		if (ac2.getValue() >= 110 and lighting_du4.getValue() > 0.01) {
			if (du4_test_time.getValue() + du4_test_amount.getValue() >= elapsedtime) {
				lowerECAM_apu.page.hide();
				lowerECAM_bleed.page.hide();
				lowerECAM_cond.page.hide();
				lowerECAM_crz.page.hide();
				lowerECAM_door.page.hide();
				lowerECAM_elec.page.hide();
				lowerECAM_eng.page.hide();
				lowerECAM_fctl.page.hide();
				lowerECAM_fuel.page.hide();
				lowerECAM_press.page.hide();
				lowerECAM_status.page.hide();
				lowerECAM_wheel.page.hide();
				lowerECAM_test.page.show();
				lowerECAM_test.update();
			} else {
				lowerECAM_test.page.hide();
				page = ecam_page.getValue();
				if (page == "apu") {
					lowerECAM_apu.page.show();
					lowerECAM_bleed.page.hide();
					lowerECAM_cond.page.hide();
					lowerECAM_crz.page.hide();
					lowerECAM_door.page.hide();
					lowerECAM_elec.page.hide();
					lowerECAM_eng.page.hide();
					lowerECAM_fctl.page.hide();
					lowerECAM_fuel.page.hide();
					lowerECAM_press.page.hide();
					lowerECAM_status.page.hide();
					lowerECAM_hyd.page.hide();
					lowerECAM_wheel.page.hide();
					lowerECAM_apu.update();
				} else if (page == "bleed") {
					lowerECAM_apu.page.hide();
					lowerECAM_bleed.page.show();
					lowerECAM_cond.page.hide();
					lowerECAM_crz.page.hide();
					lowerECAM_door.page.hide();
					lowerECAM_elec.page.hide();
					lowerECAM_eng.page.hide();
					lowerECAM_fctl.page.hide();
					lowerECAM_fuel.page.hide();
					lowerECAM_press.page.hide();
					lowerECAM_status.page.hide();
					lowerECAM_hyd.page.hide();
					lowerECAM_wheel.page.hide();
					lowerECAM_bleed.update();
				} else if (page == "cond") {
					lowerECAM_apu.page.hide();
					lowerECAM_bleed.page.hide();
					lowerECAM_cond.page.show();
					lowerECAM_crz.page.hide();
					lowerECAM_door.page.hide();
					lowerECAM_elec.page.hide();
					lowerECAM_eng.page.hide();
					lowerECAM_fctl.page.hide();
					lowerECAM_fuel.page.hide();
					lowerECAM_press.page.hide();
					lowerECAM_status.page.hide();
					lowerECAM_hyd.page.hide();
					lowerECAM_wheel.page.hide();
					lowerECAM_cond.update();
				} else if (page == "crz") {
					lowerECAM_apu.page.hide();
					lowerECAM_bleed.page.hide();
					lowerECAM_cond.page.hide();
					lowerECAM_crz.page.show();
					lowerECAM_door.page.hide();
					lowerECAM_elec.page.hide();
					lowerECAM_eng.page.hide();
					lowerECAM_fctl.page.hide();
					lowerECAM_fuel.page.hide();
					lowerECAM_press.page.hide();
					lowerECAM_status.page.hide();
					lowerECAM_hyd.page.hide();
					lowerECAM_wheel.page.hide();
					lowerECAM_crz.update();
				} else if (page == "door") {
					lowerECAM_apu.page.hide();
					lowerECAM_bleed.page.hide();
					lowerECAM_cond.page.hide();
					lowerECAM_crz.page.hide();
					lowerECAM_door.page.show();
					lowerECAM_elec.page.hide();
					lowerECAM_eng.page.hide();
					lowerECAM_fctl.page.hide();
					lowerECAM_fuel.page.hide();
					lowerECAM_press.page.hide();
					lowerECAM_status.page.hide();
					lowerECAM_hyd.page.hide();
					lowerECAM_wheel.page.hide();
					lowerECAM_door.update();
				} else if (page == "elec") {
					lowerECAM_apu.page.hide();
					lowerECAM_bleed.page.hide();
					lowerECAM_cond.page.hide();
					lowerECAM_crz.page.hide();
					lowerECAM_door.page.hide();
					lowerECAM_elec.page.show();
					lowerECAM_eng.page.hide();
					lowerECAM_fctl.page.hide();
					lowerECAM_fuel.page.hide();
					lowerECAM_press.page.hide();
					lowerECAM_status.page.hide();
					lowerECAM_hyd.page.hide();
					lowerECAM_wheel.page.hide();
					lowerECAM_elec.update();
				} else if (page == "eng") {
					lowerECAM_apu.page.hide();
					lowerECAM_bleed.page.hide();
					lowerECAM_cond.page.hide();
					lowerECAM_crz.page.hide();
					lowerECAM_door.page.hide();
					lowerECAM_elec.page.hide();
					lowerECAM_eng.page.show();
					lowerECAM_fctl.page.hide();
					lowerECAM_fuel.page.hide();
					lowerECAM_press.page.hide();
					lowerECAM_status.page.hide();
					lowerECAM_hyd.page.hide();
					lowerECAM_wheel.page.hide();
					lowerECAM_eng.update();
				} else if (page == "fctl") {
					lowerECAM_apu.page.hide();
					lowerECAM_bleed.page.hide();
					lowerECAM_cond.page.hide();
					lowerECAM_crz.page.hide();
					lowerECAM_door.page.hide();
					lowerECAM_elec.page.hide();
					lowerECAM_eng.page.hide();
					lowerECAM_fctl.page.show();
					lowerECAM_fuel.page.hide();
					lowerECAM_press.page.hide();
					lowerECAM_status.page.hide();
					lowerECAM_hyd.page.hide();
					lowerECAM_wheel.page.hide();
					lowerECAM_fctl.update();
				} else if (page == "fuel") {
					lowerECAM_apu.page.hide();
					lowerECAM_bleed.page.hide();
					lowerECAM_cond.page.hide();
					lowerECAM_crz.page.hide();
					lowerECAM_door.page.hide();
					lowerECAM_elec.page.hide();
					lowerECAM_eng.page.hide();
					lowerECAM_fctl.page.hide();
					lowerECAM_fuel.page.show();
					lowerECAM_press.page.hide();
					lowerECAM_status.page.hide();
					lowerECAM_hyd.page.hide();
					lowerECAM_wheel.page.hide();
					lowerECAM_fuel.update();
				} else if (page == "press") {
					lowerECAM_apu.page.hide();
					lowerECAM_bleed.page.hide();
					lowerECAM_cond.page.hide();
					lowerECAM_crz.page.hide();
					lowerECAM_door.page.hide();
					lowerECAM_elec.page.hide();
					lowerECAM_eng.page.hide();
					lowerECAM_fctl.page.hide();
					lowerECAM_fuel.page.hide();
					lowerECAM_press.page.show();
					lowerECAM_status.page.hide();
					lowerECAM_hyd.page.hide();
					lowerECAM_wheel.page.hide();
					lowerECAM_press.update();
				} else if (page == "sts") {
					lowerECAM_apu.page.hide();
					lowerECAM_bleed.page.hide();
					lowerECAM_cond.page.hide();
					lowerECAM_crz.page.hide();
					lowerECAM_door.page.hide();
					lowerECAM_elec.page.hide();
					lowerECAM_eng.page.hide();
					lowerECAM_fctl.page.hide();
					lowerECAM_fuel.page.hide();
					lowerECAM_press.page.hide();
					lowerECAM_status.page.show();
					lowerECAM_hyd.page.hide();
					lowerECAM_wheel.page.hide();
					lowerECAM_status.update();
				} else if (page == "hyd") {
					lowerECAM_apu.page.hide();
					lowerECAM_bleed.page.hide();
					lowerECAM_cond.page.hide();
					lowerECAM_crz.page.hide();
					lowerECAM_door.page.hide();
					lowerECAM_elec.page.hide();
					lowerECAM_eng.page.hide();
					lowerECAM_fctl.page.hide();
					lowerECAM_fuel.page.hide();
					lowerECAM_press.page.hide();
					lowerECAM_status.page.hide();
					lowerECAM_hyd.page.show();
					lowerECAM_wheel.page.hide();
					lowerECAM_hyd.update();
				} else if (page == "wheel") {
					lowerECAM_apu.page.hide();
					lowerECAM_bleed.page.hide();
					lowerECAM_cond.page.hide();
					lowerECAM_crz.page.hide();
					lowerECAM_door.page.hide();
					lowerECAM_elec.page.hide();
					lowerECAM_eng.page.hide();
					lowerECAM_fctl.page.hide();
					lowerECAM_fuel.page.hide();
					lowerECAM_press.page.hide();
					lowerECAM_status.page.hide();
					lowerECAM_hyd.page.hide();
					lowerECAM_wheel.page.show();
					lowerECAM_wheel.update();
				} else {
					lowerECAM_apu.page.hide();
					lowerECAM_bleed.page.hide();
					lowerECAM_cond.page.hide();
					lowerECAM_crz.page.hide();
					lowerECAM_door.page.hide();
					lowerECAM_elec.page.hide();
					lowerECAM_eng.page.hide();
					lowerECAM_fctl.page.hide();
					lowerECAM_fuel.page.hide();
					lowerECAM_press.page.hide();
					lowerECAM_status.page.hide();
					lowerECAM_hyd.page.hide();
					lowerECAM_wheel.page.hide();
				}
			}
		} else {
			lowerECAM_test.page.hide();
			lowerECAM_apu.page.hide();
			lowerECAM_bleed.page.hide();
			lowerECAM_cond.page.hide();
			lowerECAM_crz.page.hide();
			lowerECAM_door.page.hide();
			lowerECAM_elec.page.hide();
			lowerECAM_eng.page.hide();
			lowerECAM_fctl.page.hide();
			lowerECAM_fuel.page.hide();
			lowerECAM_press.page.hide();
			lowerECAM_status.page.hide();
			lowerECAM_hyd.page.hide();
			lowerECAM_wheel.page.hide();
		}
	},
	updateBottomStatus: func() {
		if (dmc.DMController.DMCs[1].outputs[4] != nil) {
			me["SAT"].setText(sprintf("%2.0f", dmc.DMController.DMCs[1].outputs[4].getValue()));
			me["SAT"].setColor(0.0509,0.7529,0.2941);
		} else {
			me["SAT"].setText(sprintf("%s", "XX"));
			me["SAT"].setColor(0.7333,0.3803,0);
		}
		
		if (dmc.DMController.DMCs[1].outputs[5] != nil) {
			me["TAT"].setText(sprintf("%2.0f", dmc.DMController.DMCs[1].outputs[5].getValue()));
			me["TAT"].setColor(0.0509,0.7529,0.2941);
		} else {
			me["TAT"].setText(sprintf("%s", "XX"));
			me["TAT"].setColor(0.7333,0.3803,0);
		}
		
		me["UTCh"].setText(sprintf("%02d", hour.getValue()));
		me["UTCm"].setText(sprintf("%02d", minute.getValue()));
		if (acconfig_weight_kgs.getValue() == 1) {
			me["GW"].setText(sprintf("%s", math.round(gw.getValue() * LBS2KGS)));
			me["GW-weight-unit"].setText("KG");
		} else {
			me["GW"].setText(sprintf("%s", math.round(gw.getValue())));
			me["GW-weight-unit"].setText("LBS");
		}
	},
};

var canvas_lowerECAM_apu = {
	new: func(canvas_group, file) {
		var m = {parents: [canvas_lowerECAM_apu, canvas_lowerECAM_base]};
		m.init(canvas_group, file);

		return m;
	},
	getKeys: func() {
		return ["TAT","SAT","GW","UTCh","UTCm","GW-weight-unit","APUN-needle","APUEGT-needle","APUN","APUEGT","APUAvail","APUFlapOpen","APUBleedValve","APUBleedOnline","APUGenOnline","APUGentext","APUGenLoad","APUGenbox","APUGenVolt","APUGenHz","APUBleedPSI","APUfuelLO","APU-low-oil",
		"text3724","text3728","text3732"];
	},
	update: func() {
		oat = temperature_degc.getValue();

		# Avail and Flap Open
		if (apu_flap.getValue() == 1) {
			me["APUFlapOpen"].show();
		} else {
			me["APUFlapOpen"].hide();
		}

		if (apu_rpm.getValue() > 94.9) {
			me["APUAvail"].show();
		} else {
			me["APUAvail"].hide();
		}

		if (!systems.FUEL.Pumps.apu.getBoolValue() and systems.FUEL.Pumps.allOff.getBoolValue()) {
			me["APUfuelLO"].show();
		} else {
			me["APUfuelLO"].hide();
		}

		# APU Gen
		if (apu_volts.getValue() >= 110) {
			me["APUGenVolt"].setColor(0.0509,0.7529,0.2941);
		} else {
			me["APUGenVolt"].setColor(0.7333,0.3803,0);
		}

		if (apu_hz.getValue() > 380) {
			me["APUGenHz"].setColor(0.0509,0.7529,0.2941);
		} else {
			me["APUGenHz"].setColor(0.7333,0.3803,0);
		}

		if (apu_master.getValue() == 1 or apu_rpm.getValue() >= 94.9) {
			me["APUGenbox"].show();
			me["APUGenHz"].show();
			me["APUGenVolt"].show();
			me["APUGenLoad"].show();
			me["text3724"].show();
			me["text3728"].show();
			me["text3732"].show();
		} else {
			me["APUGenbox"].hide();
			me["APUGenHz"].hide();
			me["APUGenVolt"].hide();
			me["APUGenLoad"].hide();
			me["text3724"].hide();
			me["text3728"].hide();
			me["text3732"].hide();
		}

		if ((apu_rpm.getValue() > 94.9) and (gen_apu.getValue() == 1)) {
			me["APUGenOnline"].show();
		} else {
			me["APUGenOnline"].hide();
		}

		if ((apu_master.getValue() == 0) or ((apu_master.getValue() == 1) and (gen_apu.getValue() == 1) and (apu_rpm.getValue() > 94.9))) {
			me["APUGentext"].setColor(0.8078,0.8039,0.8078);
		} else if ((apu_master.getValue() == 1) and (gen_apu.getValue() == 0) and (apu_rpm.getValue() < 94.9)) { 
			me["APUGentext"].setColor(0.7333,0.3803,0);
		}

		me["APUGenLoad"].setText(sprintf("%s", math.round(apu_load.getValue())));
		me["APUGenVolt"].setText(sprintf("%s", math.round(apu_volts.getValue())));
		me["APUGenHz"].setText(sprintf("%s", math.round(apu_hz.getValue())));

		# APU Bleed
		if (systems.ADIRSnew.Operating.adr[0].getValue() and (apu_master.getValue() == 1 or bleedapu.getValue() > 0)) {
			me["APUBleedPSI"].setColor(0.0509,0.7529,0.2941);
			me["APUBleedPSI"].setText(sprintf("%s", math.round(bleedapu.getValue())));
		} else {
			me["APUBleedPSI"].setColor(0.7333,0.3803,0);
			me["APUBleedPSI"].setText(sprintf("%s", "XX"));
		}

		if (switch_bleedapu.getValue() == 1) {
			me["APUBleedValve"].setRotation(90 * D2R);
			me["APUBleedOnline"].show();
		} else {
			me["APUBleedValve"].setRotation(0);
			me["APUBleedOnline"].hide();
		}

		# APU N and EGT
		if (apu_master.getValue() == 1) {
			me["APUN"].setColor(0.0509,0.7529,0.2941);
			me["APUN"].setText(sprintf("%s", math.round(apu_rpm.getValue() or 0)));
			me["APUEGT"].setColor(0.0509,0.7529,0.2941);
			me["APUEGT"].setText(sprintf("%s", math.round(apu_egt.getValue() or 0, 5)));
		} else if (apu_rpm.getValue() >= 1) {
			me["APUN"].setColor(0.0509,0.7529,0.2941);
			me["APUN"].setText(sprintf("%s", math.round(apu_rpm.getValue() or 0)));
			me["APUEGT"].setColor(0.0509,0.7529,0.2941);
			me["APUEGT"].setText(sprintf("%s", math.round(apu_egt.getValue() or 0, 5)));
		} else {
			me["APUN"].setColor(0.7333,0.3803,0);
			me["APUN"].setText(sprintf("%s", "XX"));
			me["APUEGT"].setColor(0.7333,0.3803,0);
			me["APUEGT"].setText(sprintf("%s", "XX"));
		}
		me["APUN-needle"].setRotation((apu_rpm_rot.getValue() + 90) * D2R);
		me["APUEGT-needle"].setRotation((apu_egt_rot.getValue() + 90) * D2R);

		if (systems.APUNodes.Oil.level.getValue() < 3.69 and apu_rpm.getValue() < 94.9 and gear0_wow.getValue()) {
			me["APU-low-oil"].show();
		} else {
			me["APU-low-oil"].hide();
		}
		
		me.updateBottomStatus();
	},
};

var canvas_lowerECAM_bleed = {
	new: func(canvas_group, file) {
		var m = {parents: [canvas_lowerECAM_bleed, canvas_lowerECAM_base]};
		m.init(canvas_group, file);

		return m;
	},
	getKeys: func() {
		return ["TAT","SAT","GW","UTCh","UTCm","GW-weight-unit", "BLEED-XFEED", "BLEED-Ram-Air", "BLEED-APU", "BLEED-HP-Valve-1",
		"BLEED-ENG-1", "BLEED-HP-Valve-2", "BLEED-ENG-2", "BLEED-Precooler-1-Inlet-Press", "BLEED-Precooler-1-Outlet-Temp",
		"BLEED-Precooler-2-Inlet-Press", "BLEED-Precooler-2-Outlet-Temp", "BLEED-ENG-1-label", "BLEED-ENG-2-label",
		"BLEED-GND", "BLEED-Pack-1-Flow-Valve", "BLEED-Pack-2-Flow-Valve", "BLEED-Pack-1-Out-Temp",
		"BLEED-Pack-1-Comp-Out-Temp", "BLEED-Pack-1-Packflow-needel", "BLEED-Pack-1-Bypass-needel", "BLEED-Pack-2-Out-Temp",
		"BLEED-Pack-2-Bypass-needel", "BLEED-Pack-2-Comp-Out-Temp", "BLEED-Pack-2-Packflow-needel", "BLEED-Anti-Ice-Left",
		"BLEED-Anti-Ice-Right", "BLEED-HP-2-connection", "BLEED-HP-1-connection", "BLEED-ANTI-ICE-ARROW-LEFT", "BLEED-ANTI-ICE-ARROW-RIGHT"];
	},
	update: func() {
		# X BLEED
		if (pneumatic_xbleed_state.getValue() == "transit") {
			me["BLEED-XFEED"].setColor(0.7333,0.3803,0);
			me["BLEED-XFEED"].setRotation(45 * D2R);
		} else {
			if (pneumatic_xbleed_state.getValue() == "open") {
				var xbleed_state = 1;
			} else {
				var xbleed_state = 0;
			}

			if (xbleed_state == 1) {
				me["BLEED-XFEED"].setRotation(0);
			} else {
				me["BLEED-XFEED"].setRotation(90 * D2R);
			}
			if (xbleed_state == xbleed.getValue()) {
				me["BLEED-XFEED"].setColor(0.0509,0.7529,0.2941);
			} else {
				me["BLEED-XFEED"].setColor(0.7333,0.3803,0);
			}
		}

		# HP valve 1
		var hp_valve_state = hp_valve1_state.getValue();

		if (hp_valve_state == 1) {
			me["BLEED-HP-Valve-1"].setRotation(90 * D2R);
		} else {
			me["BLEED-HP-Valve-1"].setRotation(0);
		}
		if (hp_valve_state == hp_valve1.getValue()) {
			me["BLEED-HP-Valve-1"].setColor(0.0509,0.7529,0.2941);
		} else {
			me["BLEED-HP-Valve-1"].setColor(0.7333,0.3803,0);
		}

		# HP valve 2
		var hp_valve_state = hp_valve2_state.getValue();

		if (hp_valve_state == 1) {
			me["BLEED-HP-Valve-2"].setRotation(90 * D2R);
		} else {
			me["BLEED-HP-Valve-2"].setRotation(0);
		}
		if (hp_valve_state == hp_valve2.getValue()) {
			me["BLEED-HP-Valve-2"].setColor(0.0509,0.7529,0.2941);
		} else {
			me["BLEED-HP-Valve-2"].setColor(0.7333,0.3803,0);
		}

		# ENG BLEED valve 1
		var eng_valve_state = eng_valve1_state.getValue();

		if (eng_valve_state == 1) {
			me["BLEED-ENG-1"].setRotation(90 * D2R);
		} else {
			me["BLEED-ENG-1"].setRotation(0);
		}
		if (eng_valve_state == eng_valve1.getValue()) {
			me["BLEED-ENG-1"].setColor(0.0509,0.7529,0.2941);
		} else {
			me["BLEED-ENG-1"].setColor(0.7333,0.3803,0);
		}

		# ENG BLEED valve 2
		var eng_valve_state = eng_valve2_state.getValue();

		if (eng_valve_state == 1) {
			me["BLEED-ENG-2"].setRotation(90 * D2R);
		} else {
			me["BLEED-ENG-2"].setRotation(0);
		}
		if (eng_valve_state == eng_valve2.getValue()) {
			me["BLEED-ENG-2"].setColor(0.0509,0.7529,0.2941);
		} else {
			me["BLEED-ENG-2"].setColor(0.7333,0.3803,0);
		}

		# Precooler inlet 1
		var precooler_psi = precooler1_psi.getValue();
		me["BLEED-Precooler-1-Inlet-Press"].setText(sprintf("%s", math.round(precooler_psi)));
		if (precooler_psi < 4 or precooler_psi > 57) {
			me["BLEED-Precooler-1-Inlet-Press"].setColor(0.7333,0.3803,0);
		} else {
			me["BLEED-Precooler-1-Inlet-Press"].setColor(0.0509,0.7529,0.2941);
		}

		# Precooler inlet 2
		var precooler_psi = precooler2_psi.getValue();
		me["BLEED-Precooler-2-Inlet-Press"].setText(sprintf("%s", math.round(precooler_psi)));
		if (precooler_psi < 4 or precooler_psi > 57) {
			me["BLEED-Precooler-2-Inlet-Press"].setColor(0.7333,0.3803,0);
		} else {
			me["BLEED-Precooler-2-Inlet-Press"].setColor(0.0509,0.7529,0.2941);
		}

		# Precooler outlet 1
		var precooler_temp = precooler1_temp.getValue();
		me["BLEED-Precooler-1-Outlet-Temp"].setText(sprintf("%s", math.round(precooler_temp)));
		if (precooler_temp < 150 or precooler1_ovht.getValue()) {
			me["BLEED-Precooler-1-Outlet-Temp"].setColor(0.7333,0.3803,0);
		} else {
			me["BLEED-Precooler-1-Outlet-Temp"].setColor(0.0509,0.7529,0.2941);
		}

		# Precooler outlet 2
		var precooler_temp = precooler2_temp.getValue();
		me["BLEED-Precooler-2-Outlet-Temp"].setText(sprintf("%s", math.round(precooler_temp)));
		if (precooler_temp < 150 or precooler2_ovht.getValue() == 1) {
			me["BLEED-Precooler-2-Outlet-Temp"].setColor(0.7333,0.3803,0);
		} else {
			me["BLEED-Precooler-2-Outlet-Temp"].setColor(0.0509,0.7529,0.2941);
		}

		# GND air
		if (gs_kt.getValue() < 1) {
			me["BLEED-GND"].show();
		} else {
			me["BLEED-GND"].hide();
		}

		# WING ANTI ICE
		if (switch_wing_aice.getValue() == 1) {
			me["BLEED-Anti-Ice-Left"].show();
			me["BLEED-Anti-Ice-Right"].show();
			# TODO when seperated valves for left and right wing are implemented, do the following `if` and `else` clause for each wing.
			if (deice_wing.getValue()) {
				me["BLEED-ANTI-ICE-ARROW-LEFT"].show();
				me["BLEED-ANTI-ICE-ARROW-RIGHT"].show();
				if (total_psi.getValue() < 4 or total_psi.getValue() > 57) {
					me["BLEED-ANTI-ICE-ARROW-LEFT"].setColor(0.7333,0.3803,0);
					me["BLEED-ANTI-ICE-ARROW-RIGHT"].setColor(0.7333,0.3803,0);
				} else {
					me["BLEED-ANTI-ICE-ARROW-LEFT"].setColor(0.0509,0.7529,0.2941);
					me["BLEED-ANTI-ICE-ARROW-RIGHT"].setColor(0.0509,0.7529,0.2941);
				}
			} else {
				me["BLEED-ANTI-ICE-ARROW-LEFT"].hide();
				me["BLEED-ANTI-ICE-ARROW-RIGHT"].hide();
			}
		} else {
			me["BLEED-Anti-Ice-Left"].hide();
			me["BLEED-Anti-Ice-Right"].hide();
		}

		# ENG 1 label
		if (eng1_n2_actual.getValue() >= 59) {
			me["BLEED-ENG-1-label"].setColor(0.8078,0.8039,0.8078);
		} else {
			me["BLEED-ENG-1-label"].setColor(0.7333,0.3803,0);
		}

		# ENG 2 label
		if (eng2_n2_actual.getValue() >= 59) {
			me["BLEED-ENG-2-label"].setColor(0.8078,0.8039,0.8078);
		} else {
			me["BLEED-ENG-2-label"].setColor(0.7333,0.3803,0);
		}

		# PACK 1 -----------------------------------------
		me["BLEED-Pack-1-Out-Temp"].setText(sprintf("%s", pack1_out_temp.getValue()));
		me["BLEED-Pack-1-Comp-Out-Temp"].setText(sprintf("%s", pack1_comp_out_temp.getValue()));

		if (pack1_out_temp.getValue() > 90) {
			me["BLEED-Pack-1-Out-Temp"].setColor(0.7333,0.3803,0);
		} else {
			me["BLEED-Pack-1-Out-Temp"].setColor(0.0509,0.7529,0.2941);
		}

		var bypass_pos = pack1_bypass.getValue() - 50; # `-50` cause the middel position from where we move the needel is at 50
		bypass_pos = bypass_pos * D2R;
		me["BLEED-Pack-1-Bypass-needel"].setRotation(bypass_pos);

		if (pack1_comp_out_temp.getValue() > 230) {
			me["BLEED-Pack-1-Comp-Out-Temp"].setColor(0.7333,0.3803,0);
		} else {
			me["BLEED-Pack-1-Comp-Out-Temp"].setColor(0.0509,0.7529,0.2941);
		}

		var flow_pos = pack1_flow.getValue() - 50; # `-50` cause the middel position from where we move the needel is at 50
		flow_pos = flow_pos * D2R;
		me["BLEED-Pack-1-Packflow-needel"].setRotation(flow_pos);

		if (pack1_valve.getValue() == 0) {
			me["BLEED-Pack-1-Packflow-needel"].setColor(0.7333,0.3803,0);
		} else {
			me["BLEED-Pack-1-Packflow-needel"].setColor(0.0509,0.7529,0.2941);
		}

		if (pack1_valve.getValue() == 1) {
			me["BLEED-Pack-1-Flow-Valve"].setRotation(0);
		} else {
			me["BLEED-Pack-1-Flow-Valve"].setRotation(90 * D2R);
		}

		var pack_state = pack1_valve.getValue();
		if (pack_state == 1) {
			me["BLEED-Pack-1-Flow-Valve"].setRotation(0);
		} else {
			me["BLEED-Pack-2-Flow-Valve"].setRotation(90 * D2R);
		}

		if (pack_state == switch_pack1.getValue()) {
			me["BLEED-Pack-1-Flow-Valve"].setColor(0.0509,0.7529,0.2941);
		} else {
			me["BLEED-Pack-1-Flow-Valve"].setColor(0.7333,0.3803,0);
		}

		# PACK 2 -----------------------------------------
		me["BLEED-Pack-2-Out-Temp"].setText(sprintf("%s", pack2_out_temp.getValue()));
		me["BLEED-Pack-2-Comp-Out-Temp"].setText(sprintf("%s", pack2_comp_out_temp.getValue()));

		if (pack2_out_temp.getValue() > 90) {
			me["BLEED-Pack-2-Out-Temp"].setColor(0.7333,0.3803,0);
		} else {
			me["BLEED-Pack-2-Out-Temp"].setColor(0.0509,0.7529,0.2941);
		}

		var bypass_pos = pack2_bypass.getValue() - 50; # `-50` cause the middel position from where we move the needel is at 50
		bypass_pos = bypass_pos * D2R;
		me["BLEED-Pack-2-Bypass-needel"].setRotation(bypass_pos);

		if (pack2_comp_out_temp.getValue() > 230) {
			me["BLEED-Pack-2-Comp-Out-Temp"].setColor(0.7333,0.3803,0);
		} else {
			me["BLEED-Pack-2-Comp-Out-Temp"].setColor(0.0509,0.7529,0.2941);
		}

		var flow_pos = pack2_flow.getValue() - 50; # `-50` cause the middel position from where we move the needel is at 50
		flow_pos = flow_pos * D2R;
		me["BLEED-Pack-2-Packflow-needel"].setRotation(flow_pos);

		if (pack2_valve.getValue() == 0) {
			me["BLEED-Pack-2-Packflow-needel"].setColor(0.7333,0.3803,0);
		} else {
			me["BLEED-Pack-2-Packflow-needel"].setColor(0.0509,0.7529,0.2941);
		}

		var pack_state = pack2_valve.getValue();
		if (pack_state == 1) {
			me["BLEED-Pack-2-Flow-Valve"].setRotation(0);
		} else {
			me["BLEED-Pack-2-Flow-Valve"].setRotation(90 * D2R);
		}

		if (pack_state == switch_pack2.getValue()) {
			me["BLEED-Pack-2-Flow-Valve"].setColor(0.0509,0.7529,0.2941);
		} else {
			me["BLEED-Pack-2-Flow-Valve"].setColor(0.7333,0.3803,0);
		}

		me.updateBottomStatus();
	},
};

var canvas_lowerECAM_cond = {
	new: func(canvas_group, file) {
		var m = {parents: [canvas_lowerECAM_cond, canvas_lowerECAM_base]};
		m.init(canvas_group, file);

		return m;
	},
	getKeys: func() {
		return ["TAT","SAT","GW","UTCh","UTCm","GW-weight-unit"];
	},
	update: func() {

		me.updateBottomStatus();
	},
};

var canvas_lowerECAM_crz = {
	new: func(canvas_group, file) {
		var m = {parents: [canvas_lowerECAM_crz, canvas_lowerECAM_base]};
		m.init(canvas_group, file);

		return m;
	},
	getKeys: func() {
		return ["TAT","SAT","GW","UTCh","UTCm","GW-weight-unit","Oil1","Oil2","FUsed1","FUsed2","FUsed","VIB1N1","VIB1N2","VIB2N1","VIB2N2","deltaPSI","LDGELEV-AUTO","LDGELEV","CABVS","CABALT","VS-Arrow-UP","VS-Arrow-DN","CKPT-TEMP","FWD-TEMP","AFT-TEMP","Fused-weight-unit"];
	},
	update: func() {

		me["Oil1"].setText(sprintf("%2.1f", oil_qt1_actual.getValue()));
		me["Oil2"].setText(sprintf("%2.1f", oil_qt2_actual.getValue()));

		if (acconfig_weight_kgs.getValue() == 1) {
			me["Fused-weight-unit"].setText("KG");
			me["FUsed1"].setText(sprintf("%s", math.round(fuel_used_lbs1.getValue() * LBS2KGS, 10)));
			me["FUsed2"].setText(sprintf("%s", math.round(fuel_used_lbs2.getValue() * LBS2KGS, 10)));
			me["FUsed"].setText(sprintf("%s", (math.round(fuel_used_lbs1.getValue() * LBS2KGS, 10) + math.round(fuel_used_lbs2.getValue() * LBS2KGS, 10))));
		} else {
			me["Fused-weight-unit"].setText("LBS");
			me["FUsed1"].setText(sprintf("%s", math.round(fuel_used_lbs1.getValue(), 10)));
			me["FUsed2"].setText(sprintf("%s", math.round(fuel_used_lbs2.getValue(), 10)));
			me["FUsed"].setText(sprintf("%s", (math.round(fuel_used_lbs1.getValue(), 10) + math.round(fuel_used_lbs2.getValue(), 10))));
		}

		me.updateBottomStatus();
	},
};

var canvas_lowerECAM_door = {
	new: func(canvas_group, file) {
		var m = {parents: [canvas_lowerECAM_door, canvas_lowerECAM_base]};
		m.init(canvas_group, file);

		return m;
	},
	getKeys: func() {
		return["TAT","SAT","GW","UTCh","UTCm","GW-weight-unit","Bulk","BulkLine","BulkLbl","Exit1L","Exit1R","Cabin1Left","Cabin1LeftLbl","Cabin1LeftLine","Cabin1LeftSlide","Cabin1Right","Cabin1RightLbl","Cabin1RightLine","Cabin1RightSlide","Cabin2Left","Cabin2LeftLbl",
		"Cabin2LeftLine","Cabin2LeftSlide","Cabin2Right","Cabin2RightLbl","Cabin2RightLine","Cabin2RightSlide","Cabin3Left","Cabin3LeftLbl","Cabin3LeftLine","Cabin3LeftSlide","Cabin3Right","Cabin3RightLbl","Cabin3RightLine","Cabin3RightSlide","AvionicsLine1",
		"AvionicsLbl1","AvionicsLine2","AvionicsLbl2","Cargo1Line","Cargo1Lbl","Cargo1Door","Cargo2Line","Cargo2Lbl","Cargo2Door","ExitLSlide","ExitLLine","ExitLLbl","ExitRSlide","ExitRLine","ExitRLbl","Cabin4Left","Cabin4LeftLbl","Cabin4LeftLine",
		"Cabin4LeftSlide","Cabin4Right","Cabin4RightLbl","Cabin4RightLine","Cabin4RightSlide","DOOROXY-REGUL-LO-PR"];
	},
	update: func() {
		# If you make AirBerlin or Allegiant livery add below 

		if (doorL1_pos.getValue() > 0) {
			me["Cabin1Left"].show();
			me["Cabin1Left"].setColor(0.7333,0.3803,0);
			me["Cabin1Left"].setColorFill(0.7333,0.3803,0);
			me["Cabin1LeftLbl"].show();
			me["Cabin1LeftLine"].show();
		} else {
			me["Cabin1Left"].setColor(0.0509,0.7529,0.2941);
			me["Cabin1Left"].setColorFill(0,0,0);
			me["Cabin1LeftLbl"].hide();
			me["Cabin1LeftLine"].hide();
		}

		if (doorR1_pos.getValue() > 0) {
			me["Cabin1Right"].show();
			me["Cabin1Right"].setColor(0.7333,0.3803,0);
			me["Cabin1Right"].setColorFill(0.7333,0.3803,0);
			me["Cabin1RightLbl"].show();
			me["Cabin1RightLine"].show();
		} else {
			me["Cabin1Right"].setColor(0.0509,0.7529,0.2941);
			me["Cabin1Right"].setColorFill(0,0,0);
			me["Cabin1RightLbl"].hide();
			me["Cabin1RightLine"].hide();
		}

		if (doorL4_pos.getValue() > 0) {
			me["Cabin4Left"].show();
			me["Cabin4Left"].setColor(0.7333,0.3803,0);
			me["Cabin4Left"].setColorFill(0.7333,0.3803,0);
			me["Cabin4LeftLbl"].show();
			me["Cabin4LeftLine"].show();
		} else {
			me["Cabin4Left"].setColor(0.0509,0.7529,0.2941);
			me["Cabin4Left"].setColorFill(0,0,0);
			me["Cabin4LeftLbl"].hide();
			me["Cabin4LeftLine"].hide();
		}

		if (doorR4_pos.getValue() > 0) {
			me["Cabin4Right"].show();
			me["Cabin4Right"].setColor(0.7333,0.3803,0);
			me["Cabin4Right"].setColorFill(0.7333,0.3803,0);
			me["Cabin4RightLbl"].show();
			me["Cabin4RightLine"].show();
		} else {
			me["Cabin4Right"].setColor(0.0509,0.7529,0.2941);
			me["Cabin4Right"].setColorFill(0,0,0);
			me["Cabin4RightLbl"].hide();
			me["Cabin4RightLine"].hide();
		}

		if (cargobulk_pos.getValue() > 0) {
			me["Bulk"].setColor(0.7333,0.3803,0);
			me["Bulk"].setColorFill(0.7333,0.3803,0);
			me["BulkLbl"].show();
			me["BulkLine"].show();
		} else {
			me["Bulk"].setColor(0.0509,0.7529,0.2941);
			me["Bulk"].setColorFill(0,0,0);
			me["BulkLbl"].hide();
			me["BulkLine"].hide();
		}

		if (cargofwd_pos.getValue() > 0) {
			me["Cargo1Door"].setColor(0.7333,0.3803,0);
			me["Cargo1Door"].setColorFill(0.7333,0.3803,0);
			me["Cargo1Lbl"].show();
			me["Cargo1Line"].show();
		} else {
			me["Cargo1Door"].setColor(0.0509,0.7529,0.2941);
			me["Cargo1Door"].setColorFill(0,0,0);
			me["Cargo1Lbl"].hide();
			me["Cargo1Line"].hide();
		}

		if (cargoaft_pos.getValue() > 0) {
			me["Cargo2Door"].setColor(0.7333,0.3803,0);
			me["Cargo2Door"].setColorFill(0.7333,0.3803,0);
			me["Cargo2Lbl"].show();
			me["Cargo2Line"].show();
		} else {
			me["Cargo2Door"].setColor(0.0509,0.7529,0.2941);
			me["Cargo2Door"].setColorFill(0,0,0);
			me["Cargo2Lbl"].hide();
			me["Cargo2Line"].hide();
		}

		me["Cabin1LeftSlide"].hide();
		me["Cabin1RightSlide"].hide();
		me["Cabin2LeftSlide"].hide();
		me["Cabin2RightSlide"].hide();
		me["Cabin3LeftSlide"].hide();
		me["Cabin3RightSlide"].hide();
		me["Cabin4LeftSlide"].hide();
		me["Cabin4RightSlide"].hide();

		me["DOOROXY-REGUL-LO-PR"].hide();
		me["AvionicsLine1"].hide();
		me["AvionicsLine2"].hide();
		me["AvionicsLbl1"].hide();
		me["AvionicsLbl2"].hide();
		me["ExitLSlide"].hide();
		me["ExitLLine"].hide();
		me["ExitLLbl"].hide();
		me["ExitRSlide"].hide();
		me["ExitRLine"].hide();
		me["ExitRLbl"].hide();
		me["Cabin1LeftSlide"].hide();
		me["Cabin1RightSlide"].hide();
		me["Cabin4LeftSlide"].hide();
		me["Cabin4RightSlide"].hide();
		me["Cabin2Left"].hide();
		me["Cabin2LeftLine"].hide();
		me["Cabin2LeftLbl"].hide();
		me["Cabin2Right"].hide();
		me["Cabin2RightLine"].hide();
		me["Cabin2RightLbl"].hide();
		me["Cabin3Left"].hide();
		me["Cabin3LeftLine"].hide();
		me["Cabin3LeftLbl"].hide();
		me["Cabin3Right"].hide();
		me["Cabin3RightLine"].hide();
		me["Cabin3RightLbl"].hide();

		me.updateBottomStatus();
	},
};

var canvas_lowerECAM_elec = {
	new: func(canvas_group, file) {
		var m = {parents: [canvas_lowerECAM_elec, canvas_lowerECAM_base]};
		m.init(canvas_group, file);

		return m;
	},
	getKeys: func() {
		return ["TAT","SAT","GW","UTCh","UTCm","GW-weight-unit","BAT1-label","Bat1Volt","Bat1Ampere","BAT2-label","Bat2Volt","Bat2Ampere","BAT1-charge","BAT1-discharge","BAT2-charge","BAT2-discharge","ELEC-Line-DC1-DCBAT","ELEC-Line-DC1-DCESS","ELEC-Line-DC2-DCBAT",
		"ELEC-Line-DC1-DCESS_DCBAT","ELEC-Line-DC2-DCESS_DCBAT","ELEC-Line-TR1-DC1","ELEC-Line-TR2-DC2","Shed-label","ELEC-Line-ESSTR-DCESS","TR1-label","TR1Volt","TR1Ampere","TR2-label","TR2Volt","TR2Ampere","EMERGEN-group","EmergenVolt","EmergenHz",
		"ELEC-Line-Emergen-ESSTR","EMERGEN-Label-off","Emergen-Label","EMERGEN-out","ELEC-Line-ACESS-TRESS","ELEC-Line-AC1-TR1","ELEC-Line-AC2-TR2","ELEC-Line-AC1-ACESS","ELEC-Line-AC2-ACESS","ACESS-SHED","ACESS","AC1-in","AC2-in","ELEC-Line-GEN1-AC1","ELEC-Line-GEN2-AC2",
		"ELEC-Line-APU-AC1","ELEC-Line-APU-EXT","ELEC-Line-EXT-AC2","APU-out","EXT-out","EXTPWR-group","ExtVolt","ExtHz","APU-content","APU-border","APUGentext","APUGenLoad","APUGenVolt","APUGenHz","APUGEN-off","GEN1-label","Gen1Load","Gen1Volt","Gen1Hz",
		"GEN2-label","Gen2Load","GEN2-off","Gen2Volt","Gen2Hz","ELEC-IDG-1-label","ELEC-IDG-1-num-label","ELEC-IDG-1-Temp","IDG1-LOPR","IDG1-DISC","IDG1-RISE-Value","IDG1-RISE-label","GalleyShed","ELEC-IDG-2-Temp","ELEC-IDG-2-label","ELEC-IDG-2-num-label","IDG2-RISE-label","IDG2-RISE-Value","IDG2-LOPR",
		"IDG2-DISC","ESSTR-group","ESSTR","ESSTR-Volt","ESSTR-Ampere","BAT1-content","BAT2-content","BAT1-OFF","BAT2-OFF","GEN1-content","GEN2-content","GEN-1-num-label","GEN-2-num-label","GEN1-off","GEN2-off","GEN1-num-label","GEN2-num-label","EXTPWR-label",
		"ELEC-ACESS-SHED-label","ELEC-DCBAT-label","ELEC-DCESS-label","ELEC-DC2-label","ELEC-DC1-label","ELEC-AC1-label","ELEC-AC2-label","ELEC-ACESS-label","ELEC-Line-ESSTR-DCESS-off","ELEC-Line-Emergen-ESSTR-off"];
	},
	update: func() {

		# BAT1
		if (switch_bat1.getValue() == 0) {
			me["BAT1-OFF"].show();
			me["BAT1-content"].hide();
			me["BAT1-discharge"].hide();
			me["BAT1-charge"].hide();
		} else {
			me["BAT1-OFF"].hide();
			me["BAT1-content"].show();
			me["Bat1Ampere"].setText(sprintf("%s", math.round(bat1_amps.getValue())));
			me["Bat1Volt"].setText(sprintf("%s", math.round(bat1_volts.getValue())));

			if (bat1_volts.getValue() >= 25 and bat1_volts.getValue() <= 31) {
				me["Bat1Volt"].setColor(0.0509,0.7529,0.2941);
			} else {
				me["Bat1Volt"].setColor(0.7333,0.3803,0);
			}

			if (bat1_amps.getValue() > 5) {
				me["Bat1Ampere"].setColor(0.7333,0.3803,0);
			} else {
				me["Bat1Ampere"].setColor(0.0509,0.7529,0.2941);
			}

			if (!systems.ELEC.Source.Bat1.limiter.getBoolValue()) {
				me["BAT1-discharge"].hide();
				me["BAT1-charge"].hide();
			} else {
				if (systems.ELEC.Bus.dcBat.getValue() > 25) {
					me["BAT1-charge"].show();
					me["BAT1-discharge"].hide();
				} else {
					me["BAT1-discharge"].show();
					me["BAT1-charge"].hide();
				}
			}
		}

		if (bat1_fault.getValue() == 1 or bat1_volts.getValue() < 25 or bat1_volts.getValue() > 31 or bat1_amps.getValue() > 5) {
			me["BAT1-label"].setColor(0.7333,0.3803,0);
		} else {
			me["BAT1-label"].setColor(0.8078,0.8039,0.8078);
		}

		# BAT2
		if (switch_bat2.getValue() == 0) {
			me["BAT2-OFF"].show();
			me["BAT2-content"].hide();
			me["BAT2-discharge"].hide();
			me["BAT2-charge"].hide();
		} else {
			me["BAT2-OFF"].hide();
			me["BAT2-content"].show();
			me["Bat2Ampere"].setText(sprintf("%s", math.round(bat2_amps.getValue())));
			me["Bat2Volt"].setText(sprintf("%s", math.round(bat2_volts.getValue())));

			if (bat2_volts.getValue() >= 25 and bat2_volts.getValue() <= 31) {
				me["Bat2Volt"].setColor(0.0509,0.7529,0.2941);
			} else {
				me["Bat2Volt"].setColor(0.7333,0.3803,0);
			}

			if (bat2_amps.getValue() > 5) {
				me["Bat2Ampere"].setColor(0.7333,0.3803,0);
			} else {
				me["Bat2Ampere"].setColor(0.0509,0.7529,0.2941);
			}
			
			if (!systems.ELEC.Source.Bat2.limiter.getBoolValue()) {
				me["BAT2-discharge"].hide();
				me["BAT2-charge"].hide();
			} else {
				if (systems.ELEC.Bus.dcBat.getValue() > 25) {
					me["BAT2-charge"].show();
					me["BAT2-discharge"].hide();
				} else {
					me["BAT2-discharge"].show();
					me["BAT2-charge"].hide();
				}
			}
		}

		if (bat2_fault.getValue() == 1 or bat2_volts.getValue() < 25 or bat2_volts.getValue() > 31 or bat2_amps.getValue() > 5) {
			me["BAT2-label"].setColor(0.7333,0.3803,0);
		} else {
			me["BAT2-label"].setColor(0.8078,0.8039,0.8078);
		}

		# TR1
		# is only powered when ac1 has power
		tr1_v = tr1_volts.getValue();
		tr1_a = tr1_amps.getValue();

		me["TR1Volt"].setText(sprintf("%s", math.round(tr1_v)));
		me["TR1Ampere"].setText(sprintf("%s", math.round(tr1_a)));

		if (tr1_v < 25 or tr1_v > 31 or tr1_a < 5) {
			me["TR1-label"].setColor(0.7333,0.3803,0);
		} else {
			me["TR1-label"].setColor(0.8078,0.8039,0.8078);
		}

		if (tr1_v < 25 or tr1_v > 31) {
			me["TR1Volt"].setColor(0.7333,0.3803,0);
		} else {
			me["TR1Volt"].setColor(0.0509,0.7529,0.2941);
		}

		if (tr1_a < 5) {
			me["TR1Ampere"].setColor(0.7333,0.3803,0);
		} else {
			me["TR1Ampere"].setColor(0.0509,0.7529,0.2941);
		}

		# TR2
		# is only powered when ac2 has power
		tr2_v = tr2_volts.getValue();
		tr2_a = tr2_amps.getValue();

		me["TR2Volt"].setText(sprintf("%s", math.round(tr2_v)));
		me["TR2Ampere"].setText(sprintf("%s", math.round(tr2_a)));

		if (tr2_v < 25 or tr2_v > 31 or tr2_a < 5) {
			me["TR2-label"].setColor(0.7333,0.3803,0);
		} else {
			me["TR2-label"].setColor(0.8078,0.8039,0.8078);
		}

		if (tr2_v < 25 or tr2_v > 31) {
			me["TR2Volt"].setColor(0.7333,0.3803,0);
		} else {
			me["TR2Volt"].setColor(0.0509,0.7529,0.2941);
		}

		if (tr2_a < 5) {
			me["TR2Ampere"].setColor(0.7333,0.3803,0);
		} else {
			me["TR2Ampere"].setColor(0.0509,0.7529,0.2941);
		}

		# ESS TR
		essTrvolts = essTrVolt.getValue();
		essTramps = essTrAmp.getValue();
		if (systems.ELEC.Relay.essTrContactor.getValue()) {
			me["ESSTR-group"].show();
			me["ESSTR-Volt"].setText(sprintf("%s", math.round(essTrvolts)));
			me["ESSTR-Ampere"].setText(sprintf("%s", math.round(essTramps)));
			
			if (essTrvolts < 25 or essTrvolts > 31 or essTramps < 5) {
				me["ESSTR"].setColor(0.7333,0.3803,0);
			} else {
				me["ESSTR"].setColor(0.8078,0.8039,0.8078);
			}
			
			if (essTrvolts < 25 or essTrvolts > 31) {
				me["ESSTR-Volt"].setColor(0.7333,0.3803,0);
			} else {
				me["ESSTR-Volt"].setColor(0.0509,0.7529,0.2941);
			}
			
			if (essTramps < 5) {
				me["ESSTR-Ampere"].setColor(0.7333,0.3803,0);
			} else {
				me["ESSTR-Ampere"].setColor(0.0509,0.7529,0.2941);
			}
		} else {
			me["ESSTR-group"].hide();
		}

		# EMER GEN
		if (switch_emer_gen.getValue() == 0) {
			me["EMERGEN-group"].hide();
			me["ELEC-Line-Emergen-ESSTR"].hide();
			me["ELEC-Line-Emergen-ESSTR-off"].show();
			me["EMERGEN-Label-off"].show();
		} else {
			me["EMERGEN-group"].show();
			me["ELEC-Line-Emergen-ESSTR"].show();
			me["ELEC-Line-Emergen-ESSTR-off"].hide();
			me["EMERGEN-Label-off"].hide();
			
			me["EmergenVolt"].setText(sprintf("%s", math.round(emerGenVolts.getValue())));
			me["EmergenHz"].setText(sprintf("%s", math.round(emerGenHz.getValue())));
			
			if (emerGenVolts.getValue() > 120 or emerGenVolts.getValue() < 110 or emerGenHz.getValue() > 410 or emerGenHz.getValue() < 390) {
				me["Emergen-Label"].setColor(0.7333,0.3803,0);
			} else {
				me["Emergen-Label"].setColor(0.8078,0.8039,0.8078);
			}

			if (emerGenVolts.getValue() > 120 or emerGenVolts.getValue() < 110) {
				me["EmergenVolt"].setColor(0.7333,0.3803,0);
			} else {
				me["EmergenVolt"].setColor(0.0509,0.7529,0.2941);
			}

			if (emerGenHz.getValue() > 410 or emerGenHz.getValue() < 390) {
				me["EmergenHz"].setColor(0.7333,0.3803,0);
			} else {
				me["EmergenHz"].setColor(0.0509,0.7529,0.2941);
			}
		}
		
		# IDG 1
		if (!systems.ELEC.Switch.idg1Disc.getBoolValue()) {
			me["IDG1-DISC"].show();
			me["ELEC-IDG-1-label"].setColor(0.7333,0.3803,0);
		} else {
			me["IDG1-DISC"].hide();
			me["ELEC-IDG-1-label"].setColor(0.8078,0.8039,0.8078);
		}

		if (eng1_running.getValue() == 0) {
			me["ELEC-IDG-1-num-label"].setColor(0.7333,0.3803,0);
		} else {
			me["ELEC-IDG-1-num-label"].setColor(0.8078,0.8039,0.8078);
		}
		
		if (eng2_running.getValue() == 0) {
			me["ELEC-IDG-2-num-label"].setColor(0.7333,0.3803,0);
		} else {
			me["ELEC-IDG-2-num-label"].setColor(0.8078,0.8039,0.8078);
		}
			
		# IDG 2
		if (!systems.ELEC.Switch.idg2Disc.getBoolValue()) {
			me["IDG2-DISC"].show();
			me["ELEC-IDG-2-label"].setColor(0.7333,0.3803,0);
		} else {
			me["IDG2-DISC"].hide();
			me["ELEC-IDG-2-label"].setColor(0.8078,0.8039,0.8078);
		}
		
		# GEN1
		if (switch_gen1.getValue() == 0) {
			me["GEN1-content"].hide();
			me["GEN1-off"].show();
			if (systems.ELEC.Source.IDG1.gcrRelay.getValue()) {
				me["GEN1-label"].setColor(0.7333,0.3803,0);
			} else {
				me["GEN1-label"].setColor(0.8078,0.8039,0.8078);
			}

			if (eng1_running.getValue() == 0) {
				me["GEN1-num-label"].setColor(0.7333,0.3803,0);
			} else {
				me["GEN1-num-label"].setColor(0.8078,0.8039,0.8078);
			}
		} else {
			me["GEN1-content"].show();
			me["GEN1-off"].hide();
			# me["Gen1Load"].setText(sprintf("%s", math.round(gen1_load.getValue())));
			me["Gen1Volt"].setText(sprintf("%s", math.round(gen1_volts.getValue())));

			if (gen1_hz.getValue() == 0) {
				me["Gen1Hz"].setText(sprintf("XX"));
			} else {
				me["Gen1Hz"].setText(sprintf("%s", math.round(gen1_hz.getValue())));
			}

			if (eng1_running.getValue() == 0) {
				me["GEN1-num-label"].setColor(0.7333,0.3803,0);
			} else {
				me["GEN1-num-label"].setColor(0.8078,0.8039,0.8078);
			}

			if (gen1_volts.getValue() > 120 or gen1_volts.getValue() < 110 or gen1_hz.getValue() > 410 or gen1_hz.getValue() < 390 or gen1_load.getValue() >= 110) {
				me["GEN1-label"].setColor(0.7333,0.3803,0);
			} else {
				me["GEN1-label"].setColor(0.8078,0.8039,0.8078);
			}

			if (gen1_load.getValue() >= 110) {
				me["Gen1Load"].setColor(0.7333,0.3803,0);
			} else {
				me["Gen1Load"].setColor(0.0509,0.7529,0.2941);
			}

			if (gen1_volts.getValue() > 120 or gen1_volts.getValue() < 110) {
				me["Gen1Volt"].setColor(0.7333,0.3803,0);
			} else {
				me["Gen1Volt"].setColor(0.0509,0.7529,0.2941);
			}

			if (gen1_hz.getValue() > 410 or gen1_hz.getValue() < 390) {
				me["Gen1Hz"].setColor(0.7333,0.3803,0);
			} else {
				me["Gen1Hz"].setColor(0.0509,0.7529,0.2941);
			}
		}

		# GEN2
		if (switch_gen2.getValue() == 0) {
			me["GEN2-content"].hide();
			me["GEN2-off"].show();
			if (systems.ELEC.Source.IDG2.gcrRelay.getValue()) {
				me["GEN2-label"].setColor(0.7333,0.3803,0);
			} else {
				me["GEN2-label"].setColor(0.8078,0.8039,0.8078);
			}

			if (eng2_running.getValue() == 0) {
				me["GEN2-num-label"].setColor(0.7333,0.3803,0);
			} else {
				me["GEN2-num-label"].setColor(0.8078,0.8039,0.8078);
			}
		} else {
			me["GEN2-content"].show();
			me["GEN2-off"].hide();
			# me["Gen2Load"].setText(sprintf("%s", math.round(gen2_load.getValue())));
			me["Gen2Volt"].setText(sprintf("%s", math.round(gen2_volts.getValue())));
			if (gen2_hz.getValue() == 0) {
				me["Gen2Hz"].setText(sprintf("XX"));
			} else {
				me["Gen2Hz"].setText(sprintf("%s", math.round(gen2_hz.getValue())));
			}

			if (eng2_running.getValue() == 0) {
				me["GEN2-num-label"].setColor(0.7333,0.3803,0);
			} else {
				me["GEN2-num-label"].setColor(0.8078,0.8039,0.8078);
			}

			if (gen2_volts.getValue() > 120 or gen2_volts.getValue() < 110 or gen2_hz.getValue() > 410 or gen2_hz.getValue() < 390 or gen2_load.getValue() >= 110) {
				me["GEN2-label"].setColor(0.7333,0.3803,0);
			} else {
				me["GEN2-label"].setColor(0.8078,0.8039,0.8078);
			}

			if (gen2_load.getValue() >= 110) {
				me["Gen2Load"].setColor(0.7333,0.3803,0);
			} else {
				me["Gen2Load"].setColor(0.0509,0.7529,0.2941);
			}


			if (gen2_volts.getValue() > 120 or gen2_volts.getValue() < 110) {
				me["Gen2Volt"].setColor(0.7333,0.3803,0);
			} else {
				me["Gen2Volt"].setColor(0.0509,0.7529,0.2941);
			}

			if (gen2_hz.getValue() > 410 or gen2_hz.getValue() < 390) {
				me["Gen2Hz"].setColor(0.7333,0.3803,0);
			} else {
				me["Gen2Hz"].setColor(0.0509,0.7529,0.2941);
			}
		}

		# APU
		if (apu_master.getValue() == 0) {
			me["APU-content"].hide();
			me["APUGEN-off"].hide();
			me["APU-border"].hide();
			me["APUGentext"].setColor(0.8078,0.8039,0.8078);
		} else {
			me["APU-border"].show();
			if (gen_apu.getValue() == 0) {
				me["APU-content"].hide();
				me["APUGEN-off"].show();
				me["APUGentext"].setColor(0.7333,0.3803,0);
			} else {
				me["APU-content"].show();
				me["APUGEN-off"].hide();
				# me["APUGenLoad"].setText(sprintf("%s", math.round(apu_load.getValue())));
				me["APUGenVolt"].setText(sprintf("%s", math.round(apu_volts.getValue())));

				if (apu_hz.getValue() == 0) {
					me["APUGenHz"].setText(sprintf("XX"));
				} else {
					me["APUGenHz"].setText(sprintf("%s", math.round(apu_hz.getValue())));
				}

				if (apu_volts.getValue() > 120 or apu_volts.getValue() < 110 or apu_hz.getValue() > 410 or apu_hz.getValue() < 390 or apu_load.getValue() >= 110) {
					me["APUGentext"].setColor(0.7333,0.3803,0);
				} else {
					me["APUGentext"].setColor(0.8078,0.8039,0.8078);
				}

				if(apu_load.getValue() >= 110) {
					me["APUGenLoad"].setColor(0.7333,0.3803,0);
				} else {
					me["APUGenLoad"].setColor(0.0509,0.7529,0.2941);
				}

				if (apu_volts.getValue() > 120 or apu_volts.getValue() < 110) {
					me["APUGenVolt"].setColor(0.7333,0.3803,0);
				} else {
					me["APUGenVolt"].setColor(0.0509,0.7529,0.2941);
				}

				if (apu_hz.getValue() > 410 or apu_hz.getValue() < 390) {
					me["APUGenHz"].setColor(0.7333,0.3803,0);
				} else {
					me["APUGenHz"].setColor(0.0509,0.7529,0.2941);
				}
			}
		}

		# EXT PWR

		if (switch_cart.getValue() == 0) {
			me["EXTPWR-group"].hide();
		} else {
			me["EXTPWR-group"].show();
			me["ExtVolt"].setText(sprintf("%s", math.round(ext_volts.getValue())));
			me["ExtHz"].setText(sprintf("%s", math.round(ext_hz.getValue())));

			if (ext_hz.getValue() > 410 or ext_hz.getValue() < 390 or ext_volts.getValue() > 120 or ext_volts.getValue() < 110) {
				me["EXTPWR-label"].setColor(0.7333,0.3803,0);
			} else {
				me["EXTPWR-label"].setColor(0.0509,0.7529,0.2941);
			}

			if (ext_hz.getValue() > 410 or ext_hz.getValue() < 390) {
				me["ExtHz"].setColor(0.7333,0.3803,0);
			} else {
				me["ExtHz"].setColor(0.0509,0.7529,0.2941);
			}

			if (ext_volts.getValue() > 120 or ext_volts.getValue() < 110) {
				me["ExtVolt"].setColor(0.7333,0.3803,0);
			} else {
				me["ExtVolt"].setColor(0.0509,0.7529,0.2941);
			}
		}

		if (galleyshed.getValue() == 1 or (switch_galley.getValue() == 0)) {
			me["GalleyShed"].show();
		} else {
			me["GalleyShed"].hide();
		}

		# Bus indicators
		if (dcbat.getValue() > 25) {
			me["ELEC-DCBAT-label"].setColor(0.0509,0.7529,0.2941);
		} else {
			me["ELEC-DCBAT-label"].setColor(0.7333,0.3803,0);
		}

		if (dc1.getValue() > 25) {
			me["ELEC-DC1-label"].setColor(0.0509,0.7529,0.2941);
		} else {
			me["ELEC-DC1-label"].setColor(0.7333,0.3803,0);
		}

		if (dc2.getValue() > 25) {
			me["ELEC-DC2-label"].setColor(0.0509,0.7529,0.2941);
		} else {
			me["ELEC-DC2-label"].setColor(0.7333,0.3803,0);
		}

		if (dc_ess.getValue() > 25) {
			me["ELEC-DCESS-label"].setColor(0.0509,0.7529,0.2941);
		} else {
			me["ELEC-DCESS-label"].setColor(0.7333,0.3803,0);
		}

		if (ac_ess.getValue() >= 110) {
			me["ELEC-ACESS-label"].setColor(0.0509,0.7529,0.2941);
		} else {
			me["ELEC-ACESS-label"].setColor(0.7333,0.3803,0);
		}

		if (systems.ELEC.Bus.acEssShed.getValue() >= 110) {
			me["ACESS-SHED"].hide();
		} else {
			me["ACESS-SHED"].show();
		}

		if (ac1.getValue() >= 110) {
			me["ELEC-AC1-label"].setColor(0.0509,0.7529,0.2941);
		} else {
			me["ELEC-AC1-label"].setColor(0.7333,0.3803,0);
		}

		if (ac2.getValue() >= 110) {
			me["ELEC-AC2-label"].setColor(0.0509,0.7529,0.2941);
		} else {
			me["ELEC-AC2-label"].setColor(0.7333,0.3803,0);
		}


		# Managment of the connecting lines between the components
		if (getprop("systems/electrical/relay/apu-glc/contact-pos") and (getprop("systems/electrical/relay/ac-bus-ac-bus-tie-1/contact-pos") or getprop("systems/electrical/relay/ac-bus-ac-bus-tie-2/contact-pos"))) {
			me["APU-out"].show();
		} else {
			me["APU-out"].hide();
		}

		if (getprop("systems/electrical/relay/ext-epc/contact-pos") and (getprop("systems/electrical/relay/ac-bus-ac-bus-tie-1/contact-pos") or getprop("systems/electrical/relay/ac-bus-ac-bus-tie-2/contact-pos"))) {
			me["EXT-out"].show();
		} else {
			me["EXT-out"].hide();
		}

		if (gen1_volts.getValue() >= 110 and getprop("systems/electrical/relay/gen-1-glc/contact-pos")) {
			me["ELEC-Line-GEN1-AC1"].show();
		} else {
			me["ELEC-Line-GEN1-AC1"].hide();
		}

		if (gen2_volts.getValue() >= 110 and getprop("systems/electrical/relay/gen-2-glc/contact-pos")) {
			me["ELEC-Line-GEN2-AC2"].show();
		} else {
			me["ELEC-Line-GEN2-AC2"].hide();
		}

		if (ac1.getValue() >= 110) {
			me["AC1-in"].show();
		} else {
			me["AC1-in"].hide();
		}

		if (ac2.getValue() >= 110) {
			me["AC2-in"].show();
		} else {
			me["AC2-in"].hide();
		}

		if (getprop("systems/electrical/relay/ac-bus-ac-bus-tie-1/contact-pos") and getprop("systems/electrical/relay/ac-bus-ac-bus-tie-2/contact-pos")) {
			me["ELEC-Line-APU-AC1"].show();
			me["ELEC-Line-APU-EXT"].show();
			me["ELEC-Line-EXT-AC2"].show();
		} else {
			if (getprop("systems/electrical/relay/ac-bus-ac-bus-tie-1/contact-pos")) {
				me["ELEC-Line-APU-AC1"].show();
			} else {
				me["ELEC-Line-APU-AC1"].hide();
			}
			
			if ((getprop("systems/electrical/relay/ac-bus-ac-bus-tie-2/contact-pos") and getprop("systems/electrical/relay/apu-glc/contact-pos") and !getprop("systems/electrical/relay/gen-2-glc/contact-pos")) or (getprop("systems/electrical/relay/ac-bus-ac-bus-tie-1/contact-pos") and getprop("systems/electrical/relay/ext-epc/contact-pos") and !getprop("systems/electrical/relay/gen-1-glc/contact-pos"))) {
				me["ELEC-Line-APU-EXT"].show();
			} else {
				me["ELEC-Line-APU-EXT"].hide();
			}
			
			if (getprop("systems/electrical/relay/ac-bus-ac-bus-tie-2/contact-pos")) {
				me["ELEC-Line-EXT-AC2"].show();
			} else {
				me["ELEC-Line-EXT-AC2"].hide();
			}
		}

		if (getprop("systems/electrical/relay/ac-ess-feed-1/contact-pos") == 1) {
			if (ac1.getValue() >= 110) {
				me["ELEC-Line-AC1-ACESS"].show();
			} else {
				me["ELEC-Line-AC1-ACESS"].hide();
			}
			me["ELEC-Line-AC2-ACESS"].hide();
		} elsif (getprop("systems/electrical/relay/ac-ess-feed-2/contact-pos") == 1) {
			me["ELEC-Line-AC1-ACESS"].hide();
			if (ac2.getValue() >= 110) {
				me["ELEC-Line-AC2-ACESS"].show();
			} else {
				me["ELEC-Line-AC2-ACESS"].hide();
			}
		} else {
			me["ELEC-Line-AC1-ACESS"].hide();
			me["ELEC-Line-AC2-ACESS"].hide();
		}

		if (getprop("systems/electrical/relay/tr-contactor-1/contact-pos") == 1) {
			if (ac1.getValue() < 110) {
				me["ELEC-Line-AC1-TR1"].setColorFill(0.7333,0.3803,0);
			} else {
				me["ELEC-Line-AC1-TR1"].setColorFill(0.0509,0.7529,0.2941);
			}
			me["ELEC-Line-AC1-TR1"].show();
			me["ELEC-Line-TR1-DC1"].show();
		} else {
			me["ELEC-Line-AC1-TR1"].hide();
			me["ELEC-Line-TR1-DC1"].hide();
		}

		if (getprop("systems/electrical/relay/tr-contactor-2/contact-pos") == 1) {
			if (ac2.getValue() < 110) {
				me["ELEC-Line-AC2-TR2"].setColorFill(0.7333,0.3803,0);
			} else {
				me["ELEC-Line-AC2-TR2"].setColorFill(0.0509,0.7529,0.2941);
			}
			me["ELEC-Line-AC2-TR2"].show();
			me["ELEC-Line-TR2-DC2"].show();
		} else {
			me["ELEC-Line-AC2-TR2"].hide();
			me["ELEC-Line-TR2-DC2"].hide();
		}
		
		if (getprop("systems/electrical/relay/dc-bus-tie-dc-1/contact-pos")) {
			me["ELEC-Line-DC1-DCESS_DCBAT"].show();
		} else {
			me["ELEC-Line-DC1-DCESS_DCBAT"].hide();
		}
		
		if (getprop("systems/electrical/relay/dc-ess-feed-bat/contact-pos")) {
			me["ELEC-Line-DC1-DCESS"].show();
		} else {
			me["ELEC-Line-DC1-DCESS"].hide();
		}
		
		if (getprop("systems/electrical/relay/dc-ess-feed-bat/contact-pos") or getprop("systems/electrical/relay/dc-bus-tie-dc-1/contact-pos")) {
			me["ELEC-Line-DC1-DCBAT"].show();
		} else {
			me["ELEC-Line-DC1-DCBAT"].hide();
		}
		
		if (getprop("systems/electrical/relay/dc-bus-tie-dc-2/contact-pos")) {
			me["ELEC-Line-DC2-DCBAT"].show();
			me["ELEC-Line-DC2-DCESS_DCBAT"].show();
		} else {
			me["ELEC-Line-DC2-DCBAT"].hide();
			me["ELEC-Line-DC2-DCESS_DCBAT"].hide();
		}
		
		if (getprop("systems/electrical/relay/ac-ess-feed-emer-gen/contact-pos")) {
			me["EMERGEN-out"].show();
			me["ELEC-Line-Emergen-ESSTR"].show();
		} else {
			me["EMERGEN-out"].hide();
			me["ELEC-Line-Emergen-ESSTR"].hide();
		}
		
		if (systems.ELEC.Bus.acEss.getValue() >= 110 and !getprop("systems/electrical/relay/ac-ess-feed-emer-gen/contact-pos") and (!getprop("systems/electrical/relay/tr-contactor-1/contact-pos") or !getprop("systems/electrical/relay/tr-contactor-2/contact-pos"))) {
			me["ELEC-Line-ACESS-TRESS"].show();
		} else {
			me["ELEC-Line-ACESS-TRESS"].hide();
		}
		
		if (getprop("systems/electrical/relay/dc-ess-feed-tr/contact-pos")) {
			me["ELEC-Line-ESSTR-DCESS"].show();
		} else {
			me["ELEC-Line-ESSTR-DCESS"].hide();
		}
		
		# hide not yet implemented items
		me["IDG1-LOPR"].hide();
		me["IDG2-LOPR"].hide();
		me["Shed-label"].hide();
		me["IDG2-RISE-label"].hide();
		me["IDG2-RISE-Value"].hide();
		me["IDG1-RISE-label"].hide();
		me["IDG1-RISE-Value"].hide();

		me.updateBottomStatus();
	},
};

var canvas_lowerECAM_eng = {
	new: func(canvas_group, file) {
		var m = {parents: [canvas_lowerECAM_eng, canvas_lowerECAM_base]};
		m.init(canvas_group, file);

		return m;
	},
	getKeys: func() {
		return ["TAT","SAT","GW","UTCh","UTCm","GW-weight-unit","OilQT1-needle","OilQT2-needle","OilQT1","OilQT2","OilQT1-decimal","OilQT2-decimal","OilPSI1-needle","OilPSI2-needle","OilPSI1","OilPSI2","FUEL-used-1","FUEL-used-2", "Fused-weight-unit"];
	},
	update: func() {
		# Oil Quantity
		me["OilQT1"].setText(sprintf("%s", int(oil_qt1_actual.getValue())));
		me["OilQT2"].setText(sprintf("%s", int(oil_qt2_actual.getValue())));
		me["OilQT1-decimal"].setText(sprintf("%s", int(10*math.mod(oil_qt1_actual.getValue(),1))));
		me["OilQT2-decimal"].setText(sprintf("%s", int(10*math.mod(oil_qt2_actual.getValue(),1))));

		me["OilQT1-needle"].setRotation((oil_qt1.getValue() + 90) * D2R);
		me["OilQT2-needle"].setRotation((oil_qt2.getValue() + 90) * D2R);

		# Oil Pressure
		if (oil_psi_actual1.getValue() >= 20) {
			me["OilPSI1"].setColor(0.0509,0.7529,0.2941);
			me["OilPSI1-needle"].setColor(0.0509,0.7529,0.2941);
		} else {
			me["OilPSI1"].setColor(1,0,0);
			me["OilPSI1-needle"].setColor(1,0,0);
		}

		if (oil_psi_actual2.getValue() >= 20) {
			me["OilPSI2"].setColor(0.0509,0.7529,0.2941);
			me["OilPSI2-needle"].setColor(0.0509,0.7529,0.2941);
		} else {
			me["OilPSI2"].setColor(1,0,0);
			me["OilPSI2-needle"].setColor(1,0,0);
		}

		me["OilPSI1"].setText(sprintf("%s", math.round(oil_psi_actual1.getValue())));
		me["OilPSI2"].setText(sprintf("%s", math.round(oil_psi_actual2.getValue())));

		me["OilPSI1-needle"].setRotation((oil_psi1.getValue() + 90) * D2R);
		me["OilPSI2-needle"].setRotation((oil_psi2.getValue() + 90) * D2R);

		# Fuel Used
		if (acconfig_weight_kgs.getValue() == 1) {
			me["FUEL-used-1"].setText(sprintf("%s", math.round(fuel_used_lbs1.getValue() * LBS2KGS, 10)));
			me["FUEL-used-2"].setText(sprintf("%s", math.round(fuel_used_lbs2.getValue() * LBS2KGS, 10)));
			me["Fused-weight-unit"].setText("KG");
		} else {
			me["FUEL-used-1"].setText(sprintf("%s", math.round(fuel_used_lbs1.getValue(), 10)));
			me["FUEL-used-2"].setText(sprintf("%s", math.round(fuel_used_lbs2.getValue(), 10)));
			me["Fused-weight-unit"].setText("LBS");
		}
		
		me.updateBottomStatus();
	},
};

var canvas_lowerECAM_fctl = {
	new: func(canvas_group, file) {
		var m = {parents: [canvas_lowerECAM_fctl, canvas_lowerECAM_base]};
		m.init(canvas_group, file);

		return m;
	},
	getKeys: func() {
		return["TAT","SAT","GW","UTCh","UTCm","GW-weight-unit","ailL","ailR","elevL","elevR","PTcc","PT","PTupdn","elac1","elac2","sec1","sec2","sec3","ailLblue","ailRblue","elevLblue","elevRblue","rudderblue","ailLgreen","ailRgreen","elevLgreen","ruddergreen","PTgreen",
		"elevRyellow","rudderyellow","PTyellow","rudder","spdbrkblue","spdbrkgreen","spdbrkyellow","spoiler1Rex","spoiler1Rrt","spoiler2Rex","spoiler2Rrt","spoiler3Rex","spoiler3Rrt","spoiler4Rex","spoiler4Rrt","spoiler5Rex","spoiler5Rrt","spoiler1Lex",
		"spoiler1Lrt","spoiler2Lex","spoiler2Lrt","spoiler3Lex","spoiler3Lrt","spoiler4Lex","spoiler4Lrt","spoiler5Lex","spoiler5Lrt","spoiler1Rf","spoiler2Rf","spoiler3Rf","spoiler4Rf","spoiler5Rf","spoiler1Lf","spoiler2Lf","spoiler3Lf","spoiler4Lf",
		"spoiler5Lf","ailLscale","ailRscale","path4249","path4249-3","path4249-3-6-7","path4249-3-6-7-5","path4249-3-6"];
	},
	update: func() {
		blue_psi = systems.HYD.Psi.blue.getValue();
		green_psi = systems.HYD.Psi.green.getValue();
		yellow_psi = systems.HYD.Psi.yellow.getValue();

		# Pitch Trim
		me["PT"].setText(sprintf("%2.1f", math.round(elevator_trim_deg.getValue(), 0.1)));

		if (math.round(elevator_trim_deg.getValue(), 0.1) >= 0) {
			me["PTupdn"].setText(sprintf("UP"));
		} else if (math.round(elevator_trim_deg.getValue(), 0.1) < 0) {
			me["PTupdn"].setText(sprintf("DN"));
		}

		if (green_psi < 1500 and yellow_psi < 1500) {
			me["PT"].setColor(0.7333,0.3803,0);
			me["PTupdn"].setColor(0.7333,0.3803,0);
			me["PTcc"].setColor(0.7333,0.3803,0);
		} else {
			me["PT"].setColor(0.0509,0.7529,0.2941);
			me["PTupdn"].setColor(0.0509,0.7529,0.2941);
			me["PTcc"].setColor(0.0509,0.7529,0.2941);
		}

		# Ailerons
		me["ailL"].setTranslation(0, aileron_ind_left.getValue() * 100);
		me["ailR"].setTranslation(0, aileron_ind_right.getValue() * (-100));

		if (blue_psi < 1500 and green_psi < 1500) {
			me["ailL"].setColor(0.7333,0.3803,0);
			me["ailR"].setColor(0.7333,0.3803,0);
		} else {
			me["ailL"].setColor(0.0509,0.7529,0.2941);
			me["ailR"].setColor(0.0509,0.7529,0.2941);
		}

		# Elevators
		me["elevL"].setTranslation(0, elevator_ind_left.getValue() * 100);
		me["elevR"].setTranslation(0, elevator_ind_right.getValue() * 100);

		if (blue_psi < 1500 and green_psi < 1500) {
			me["elevL"].setColor(0.7333,0.3803,0);
		} else {
			me["elevL"].setColor(0.0509,0.7529,0.2941);
		}

		if (blue_psi < 1500 and yellow_psi < 1500) {
			me["elevR"].setColor(0.7333,0.3803,0);
		} else {
			me["elevR"].setColor(0.0509,0.7529,0.2941);
		}

		# Rudder
		me["rudder"].setRotation(final_deg.getValue() * -0.024);

		if (blue_psi < 1500 and yellow_psi < 1500 and green_psi < 1500) {
			me["rudder"].setColor(0.7333,0.3803,0);
		} else {
			me["rudder"].setColor(0.0509,0.7529,0.2941);
		}

		# Spoilers
		if (spoiler_L1.getValue() < 1.5) {
			me["spoiler1Lex"].hide();
			me["spoiler1Lrt"].show();
		} else {
			me["spoiler1Lrt"].hide();
			me["spoiler1Lex"].show();
		}

		if (spoiler_L2.getValue() < 1.5) {
			me["spoiler2Lex"].hide();
			me["spoiler2Lrt"].show();
		} else {
			me["spoiler2Lrt"].hide();
			me["spoiler2Lex"].show();
		}

		if (spoiler_L3.getValue() < 1.5) {
			me["spoiler3Lex"].hide();
			me["spoiler3Lrt"].show();
		} else {
			me["spoiler3Lrt"].hide();
			me["spoiler3Lex"].show();
		}

		if (spoiler_L4.getValue() < 1.5) {
			me["spoiler4Lex"].hide();
			me["spoiler4Lrt"].show();
		} else {
			me["spoiler4Lrt"].hide();
			me["spoiler4Lex"].show();
		}

		if (spoiler_L5.getValue() < 1.5) {
			me["spoiler5Lex"].hide();
			me["spoiler5Lrt"].show();
		} else {
			me["spoiler5Lrt"].hide();
			me["spoiler5Lex"].show();
		}

		if (spoiler_R1.getValue() < 1.5) {
			me["spoiler1Rex"].hide();
			me["spoiler1Rrt"].show();
		} else {
			me["spoiler1Rrt"].hide();
			me["spoiler1Rex"].show();
		}

		if (spoiler_R2.getValue() < 1.5) {
			me["spoiler2Rex"].hide();
			me["spoiler2Rrt"].show();
		} else {
			me["spoiler2Rrt"].hide();
			me["spoiler2Rex"].show();
		}

		if (spoiler_R3.getValue() < 1.5) {
			me["spoiler3Rex"].hide();
			me["spoiler3Rrt"].show();
		} else {
			me["spoiler3Rrt"].hide();
			me["spoiler3Rex"].show();
		}

		if (spoiler_R4.getValue() < 1.5) {
			me["spoiler4Rex"].hide();
			me["spoiler4Rrt"].show();
		} else {
			me["spoiler4Rrt"].hide();
			me["spoiler4Rex"].show();
		}

		if (spoiler_R5.getValue() < 1.5) {
			me["spoiler5Rex"].hide();
			me["spoiler5Rrt"].show();
		} else {
			me["spoiler5Rrt"].hide();
			me["spoiler5Rex"].show();
		}

		# Spoiler Fail
		if (spoiler_L1_fail.getValue() or green_psi < 1500) {
			me["spoiler1Lex"].setColor(0.7333,0.3803,0);
			me["spoiler1Lrt"].setColor(0.7333,0.3803,0);
			if (spoiler_L1.getValue() < 1.5) {
				me["spoiler1Lf"].show();
			} else {
				me["spoiler1Lf"].hide();
			}
		} else {
			me["spoiler1Lex"].setColor(0.0509,0.7529,0.2941);
			me["spoiler1Lrt"].setColor(0.0509,0.7529,0.2941);
			me["spoiler1Lf"].hide();
		}

		if (spoiler_L2_fail.getValue() or yellow_psi < 1500) {
			me["spoiler2Lex"].setColor(0.7333,0.3803,0);
			me["spoiler2Lrt"].setColor(0.7333,0.3803,0);
			if (spoiler_L2.getValue() < 1.5) {
				me["spoiler2Lf"].show();
			} else {
				me["spoiler2Lf"].hide();
			}
		} else {
			me["spoiler2Lex"].setColor(0.0509,0.7529,0.2941);
			me["spoiler2Lrt"].setColor(0.0509,0.7529,0.2941);
			me["spoiler2Lf"].hide();
		}

		if (spoiler_L3_fail.getValue() or blue_psi < 1500) {
			me["spoiler3Lex"].setColor(0.7333,0.3803,0);
			me["spoiler3Lrt"].setColor(0.7333,0.3803,0);
			if (spoiler_L3.getValue() < 1.5) {
				me["spoiler3Lf"].show();
			} else {
				me["spoiler3Lf"].hide();
			}
		} else {
			me["spoiler3Lex"].setColor(0.0509,0.7529,0.2941);
			me["spoiler3Lrt"].setColor(0.0509,0.7529,0.2941);
			me["spoiler3Lf"].hide();
		}

		if (spoiler_L4_fail.getValue() or yellow_psi < 1500) {
			me["spoiler4Lex"].setColor(0.7333,0.3803,0);
			me["spoiler4Lrt"].setColor(0.7333,0.3803,0);
			if (spoiler_L4.getValue() < 1.5) {
				me["spoiler4Lf"].show();
			} else {
				me["spoiler4Lf"].hide();
			}
		} else {
			me["spoiler4Lex"].setColor(0.0509,0.7529,0.2941);
			me["spoiler4Lrt"].setColor(0.0509,0.7529,0.2941);
			me["spoiler4Lf"].hide();
		}

		if (spoiler_L5_fail.getValue() or green_psi < 1500) {
			me["spoiler5Lex"].setColor(0.7333,0.3803,0);
			me["spoiler5Lrt"].setColor(0.7333,0.3803,0);
			if (spoiler_L5.getValue() < 1.5) {
				me["spoiler5Lf"].show();
			} else {
				me["spoiler5Lf"].hide();
			}
		} else {
			me["spoiler5Lex"].setColor(0.0509,0.7529,0.2941);
			me["spoiler5Lrt"].setColor(0.0509,0.7529,0.2941);
			me["spoiler5Lf"].hide();
		}

		if (spoiler_R1_fail.getValue() or green_psi < 1500) {
			me["spoiler1Rex"].setColor(0.7333,0.3803,0);
			me["spoiler1Rrt"].setColor(0.7333,0.3803,0);
			if (spoiler_R1.getValue() < 1.5) {
				me["spoiler1Rf"].show();
			} else {
				me["spoiler1Rf"].hide();
			}
		} else {
			me["spoiler1Rex"].setColor(0.0509,0.7529,0.2941);
			me["spoiler1Rrt"].setColor(0.0509,0.7529,0.2941);
			me["spoiler1Rf"].hide();
		}

		if (spoiler_R2_fail.getValue() or yellow_psi < 1500) {
			me["spoiler2Rex"].setColor(0.7333,0.3803,0);
			me["spoiler2Rrt"].setColor(0.7333,0.3803,0);
			if (spoiler_R2.getValue() < 1.5) {
				me["spoiler2Rf"].show();
			} else {
				me["spoiler2Rf"].hide();
			}
		} else {
			me["spoiler2Rex"].setColor(0.0509,0.7529,0.2941);
			me["spoiler2Rrt"].setColor(0.0509,0.7529,0.2941);
			me["spoiler2Rf"].hide();
		}

		if (spoiler_R3_fail.getValue() or blue_psi < 1500) {
			me["spoiler3Rex"].setColor(0.7333,0.3803,0);
			me["spoiler3Rrt"].setColor(0.7333,0.3803,0);
			if (spoiler_R3.getValue() < 1.5) {
				me["spoiler3Rf"].show();
			} else {
				me["spoiler3Rf"].hide();
			}
		} else {
			me["spoiler3Rex"].setColor(0.0509,0.7529,0.2941);
			me["spoiler3Rrt"].setColor(0.0509,0.7529,0.2941);
			me["spoiler3Rf"].hide();
		}

		if (spoiler_R4_fail.getValue() or yellow_psi < 1500) {
			me["spoiler4Rex"].setColor(0.7333,0.3803,0);
			me["spoiler4Rrt"].setColor(0.7333,0.3803,0);
			if (spoiler_R4.getValue() < 1.5) {
				me["spoiler4Rf"].show();
			} else {
				me["spoiler4Rf"].hide();
			}
		} else {
			me["spoiler4Rex"].setColor(0.0509,0.7529,0.2941);
			me["spoiler4Rrt"].setColor(0.0509,0.7529,0.2941);
			me["spoiler4Rf"].hide();
		}

		if (spoiler_R5_fail.getValue() or green_psi < 1500) {
			me["spoiler5Rex"].setColor(0.7333,0.3803,0);
			me["spoiler5Rrt"].setColor(0.7333,0.3803,0);
			if (spoiler_R5.getValue() < 1.5) {
				me["spoiler5Rf"].show();
			} else {
				me["spoiler5Rf"].hide();
			}
		} else {
			me["spoiler5Rex"].setColor(0.0509,0.7529,0.2941);
			me["spoiler5Rrt"].setColor(0.0509,0.7529,0.2941);
			me["spoiler5Rf"].hide();
		}

		# Flight Computers
		if (elac1.getValue()) {
			me["elac1"].setColor(0.0509,0.7529,0.2941);
			me["path4249"].setColor(0.0509,0.7529,0.2941);
		} else if ((elac1.getValue() == 0) or (elac1_fail.getValue() == 1)) {
			me["elac1"].setColor(0.7333,0.3803,0);
			me["path4249"].setColor(0.7333,0.3803,0);
		}

		if (elac2.getValue()) {
			me["elac2"].setColor(0.0509,0.7529,0.2941);
			me["path4249-3"].setColor(0.0509,0.7529,0.2941);
		} else if ((elac2.getValue() == 0) or (elac2_fail.getValue() == 1)) {
			me["elac2"].setColor(0.7333,0.3803,0);
			me["path4249-3"].setColor(0.7333,0.3803,0);
		}

		if (sec1.getValue()) {
			me["sec1"].setColor(0.0509,0.7529,0.2941);
			me["path4249-3-6-7"].setColor(0.0509,0.7529,0.2941);
		} else if ((sec1.getValue() == 0) or (sec1_fail.getValue() == 1)) {
			me["sec1"].setColor(0.7333,0.3803,0);
			me["path4249-3-6-7"].setColor(0.7333,0.3803,0);
		}

		if (sec2.getValue()) {
			me["sec2"].setColor(0.0509,0.7529,0.2941);
			me["path4249-3-6-7-5"].setColor(0.0509,0.7529,0.2941);
		} else if ((sec2.getValue() == 0) or (sec2_fail.getValue() == 1)) {
			me["sec2"].setColor(0.7333,0.3803,0);
			me["path4249-3-6-7-5"].setColor(0.7333,0.3803,0);
		}

		if (sec3.getValue()) {
			me["sec3"].setColor(0.0509,0.7529,0.2941);
			me["path4249-3-6"].setColor(0.0509,0.7529,0.2941);
		} else if ((sec3.getValue() == 0) or (sec3_fail.getValue() == 1)) {
			me["sec3"].setColor(0.7333,0.3803,0);
			me["path4249-3-6"].setColor(0.7333,0.3803,0);
		}

		# Hydraulic Indicators
		if (blue_psi >= 1500) {
			me["ailLblue"].setColor(0.0509,0.7529,0.2941);
			me["ailRblue"].setColor(0.0509,0.7529,0.2941);
			me["elevLblue"].setColor(0.0509,0.7529,0.2941);
			me["elevRblue"].setColor(0.0509,0.7529,0.2941);
			me["rudderblue"].setColor(0.0509,0.7529,0.2941);
			me["spdbrkblue"].setColor(0.0509,0.7529,0.2941);
		} else {
			me["ailLblue"].setColor(0.7333,0.3803,0);
			me["ailRblue"].setColor(0.7333,0.3803,0);
			me["elevLblue"].setColor(0.7333,0.3803,0);
			me["elevRblue"].setColor(0.7333,0.3803,0);
			me["rudderblue"].setColor(0.7333,0.3803,0);
			me["spdbrkblue"].setColor(0.7333,0.3803,0);
		}

		if (green_psi >= 1500) {
			me["ailLgreen"].setColor(0.0509,0.7529,0.2941);
			me["ailRgreen"].setColor(0.0509,0.7529,0.2941);
			me["elevLgreen"].setColor(0.0509,0.7529,0.2941);
			me["ruddergreen"].setColor(0.0509,0.7529,0.2941);
			me["PTgreen"].setColor(0.0509,0.7529,0.2941);
			me["spdbrkgreen"].setColor(0.0509,0.7529,0.2941);
		} else {
			me["ailLgreen"].setColor(0.7333,0.3803,0);
			me["ailRgreen"].setColor(0.7333,0.3803,0);
			me["elevLgreen"].setColor(0.7333,0.3803,0);
			me["ruddergreen"].setColor(0.7333,0.3803,0);
			me["PTgreen"].setColor(0.7333,0.3803,0);
			me["spdbrkgreen"].setColor(0.7333,0.3803,0);
		}

		if (yellow_psi >= 1500) {
			me["elevRyellow"].setColor(0.0509,0.7529,0.2941);
			me["rudderyellow"].setColor(0.0509,0.7529,0.2941);
			me["PTyellow"].setColor(0.0509,0.7529,0.2941);
			me["spdbrkyellow"].setColor(0.0509,0.7529,0.2941);
		} else {
			me["elevRyellow"].setColor(0.7333,0.3803,0);
			me["rudderyellow"].setColor(0.7333,0.3803,0);
			me["PTyellow"].setColor(0.7333,0.3803,0);
			me["spdbrkyellow"].setColor(0.7333,0.3803,0);
		}

		me.updateBottomStatus();
	},
};

var canvas_lowerECAM_fuel = {
	new: func(canvas_group, file) {
		var m = {parents: [canvas_lowerECAM_fuel, canvas_lowerECAM_base]};
		m.init(canvas_group, file);

		return m;
	},
	getKeys: func() {
		return["TAT","SAT","GW","UTCh","UTCm","GW-weight-unit","FUEL-Pump-Left-1","FUEL-Pump-Left-2","FUEL-Pump-Center-1","FUEL-Pump-Center-2","FUEL-Pump-Right-1","FUEL-Pump-Right-2","FUEL-Left-blocked","FUEL-Right-blocked","FUEL-Center-blocked","FUEL-Left-Transfer",
		"FUEL-Right-Transfer","FUEL-Left-Outer-Inacc","FUEL-Left-Inner-Inacc","FUEL-Center-Inacc","FUEL-Right-Inner-Inacc","FUEL-Right-Outer-Inacc","FUEL-Left-Outer-quantity","FUEL-Left-Inner-quantity","FUEL-Center-quantity","FUEL-Right-Inner-quantity",
		"FUEL-Right-Outer-quantity","FUEL-On-Board","FUEL-Flow-per-min","FUEL-APU-arrow","FUEL-APU-line","FUEL-APU-label","FUEL-used-1","FUEL-used-both","FUEL-used-2","FUEL-ENG-Master-1","FUEL-ENG-Master-2","FUEL-XFEED","FUEL-XFEED-pipes","FUEL-Left-Outer-temp",
		"FUEL-Left-Inner-temp","FUEL-Right-Inner-temp","FUEL-Right-Outer-temp","FUEL-Pump-Left-1-Closed","FUEL-Pump-Left-1-Open","FUEL-Pump-Left-2-Closed","FUEL-Pump-Left-2-Open","FUEL-Pump-Center-1-Open","FUEL-Pump-Center-1-Closed","FUEL-Pump-Center-2-Closed",
		"FUEL-Pump-Center-2-Open","FUEL-Pump-Right-1-Closed","FUEL-Pump-Right-1-Open","FUEL-Pump-Right-2-Closed","FUEL-Pump-Right-2-Open","FUEL-ENG-1-label","FUEL-ENG-2-label","FUEL-ENG-1-pipe","FUEL-ENG-2-pipe","ENG1idFFlow","ENG2idFFlow","FUEL-used-1","FUEL-used-2","FUEL-used-both",
		"Fused-weight-unit","FFlow-weight-unit","FOB-weight-unit"];
	},
	update: func() {
		_weight_kgs = acconfig_weight_kgs.getValue();

		# if (getprop("engines/engine[0]/n1-actual") < getprop("controls/engines/idle-limit")) {
		if (eng1_n1.getValue() <= 18.8) {
			me["ENG1idFFlow"].setColor(0.7333,0.3803,0);
			me["FUEL-ENG-1-label"].setColor(0.7333,0.3803,0);
		} else {
			me["ENG1idFFlow"].setColor(0.8078,0.8039,0.8078);
			me["FUEL-ENG-1-label"].setColor(0.8078,0.8039,0.8078);
		}

		# if (getprop("engines/engine[1]/n1-actual") < getprop("controls/engines/idle-limit")) {
		if (eng2_n1.getValue() <= 18.5) {
			me["ENG2idFFlow"].setColor(0.7333,0.3803,0);
			me["FUEL-ENG-2-label"].setColor(0.7333,0.3803,0);
		} else {
			me["ENG2idFFlow"].setColor(0.8078,0.8039,0.8078);
			me["FUEL-ENG-2-label"].setColor(0.8078,0.8039,0.8078);
		}

		# TODO add FOB half-boxed amber if some fuel is blocked
		if (_weight_kgs == 1)
		{
			me["FUEL-On-Board"].setText(sprintf("%s", math.round(total_fuel_lbs.getValue() * LBS2KGS, 10)));
			me["FOB-weight-unit"].setText("KG");
		} else {
			me["FUEL-On-Board"].setText(sprintf("%s", math.round(total_fuel_lbs.getValue(), 10)));
			me["FOB-weight-unit"].setText("LBS");
		}

		if (_weight_kgs == 1) {
			me["FFlow-weight-unit"].setText("KG/MIN");
		} else {
			me["FFlow-weight-unit"].setText("LBS/MIN");
		}

		if (fadec1.getValue() == 1 and fadec2.getValue() == 1) {
			me["FUEL-Flow-per-min"].setColor(0.0509,0.7529,0.2941);
			if (_weight_kgs == 1) {
				me["FUEL-Flow-per-min"].setText(sprintf("%s", math.round(((fuel_flow1.getValue() + fuel_flow2.getValue()) * LBS2KGS) / 60, 10)));
			} else {
				me["FUEL-Flow-per-min"].setText(sprintf("%s", math.round((fuel_flow1.getValue() + fuel_flow2.getValue()) / 60, 10)));
			}
		} else {
			me["FUEL-Flow-per-min"].setColor(0.7333,0.3803,0);
			me["FUEL-Flow-per-min"].setText("XX");
		}

		# TODO use the valve prop and add amber if difference between eng master and valve
		# TODO add transition state
		if (systems.FUEL.Valves.lpValve1.getValue() == 1) {
			me["FUEL-ENG-Master-1"].setRotation(0);
			me["FUEL-ENG-Master-1"].setColor(0.0509,0.7529,0.2941);
			me["FUEL-ENG-Master-1"].setColorFill(0.0509,0.7529,0.2941);
			me["FUEL-ENG-1-pipe"].setColor(0.0509,0.7529,0.2941);
		} else {
			me["FUEL-ENG-Master-1"].setRotation(90 * D2R);
			me["FUEL-ENG-Master-1"].setColor(0.7333,0.3803,0);
			me["FUEL-ENG-Master-1"].setColorFill(0.7333,0.3803,0);
			me["FUEL-ENG-1-pipe"].setColor(0.7333,0.3803,0);
		}

		# TODO use the valve prop and add amber if difference between eng master and valve
		# TODO add transition state
		if (systems.FUEL.Valves.lpValve2.getValue() == 1) {
			me["FUEL-ENG-Master-2"].setRotation(0);
			me["FUEL-ENG-Master-2"].setColor(0.0509,0.7529,0.2941);
			me["FUEL-ENG-Master-2"].setColorFill(0.0509,0.7529,0.2941);
			me["FUEL-ENG-2-pipe"].setColor(0.0509,0.7529,0.2941);
		} else {
			me["FUEL-ENG-Master-2"].setRotation(90 * D2R);
			me["FUEL-ENG-Master-2"].setColor(0.7333,0.3803,0);
			me["FUEL-ENG-Master-2"].setColorFill(0.7333,0.3803,0);
			me["FUEL-ENG-2-pipe"].setColor(0.7333,0.3803,0);
		}

		# this is now bound to the XFEED switch
		# TODO use the valve prop
		# TODO add amber when disagree between switch and btn
		# TODO add transition state
		if (systems.FUEL.Valves.crossfeed.getValue() == 1) {
			me["FUEL-XFEED"].setRotation(0);
			me["FUEL-XFEED-pipes"].show();
		} else {
			me["FUEL-XFEED"].setRotation(90 * D2R);
			me["FUEL-XFEED-pipes"].hide();
		}

		# TODO add LO indication
		if (systems.FUEL.Switches.pumpLeft1.getValue() == 1) {
			me["FUEL-Pump-Left-1-Open"].show();
			me["FUEL-Pump-Left-1-Closed"].hide();
			me["FUEL-Pump-Left-1"].setColor(0.0509,0.7529,0.2941);
			me["FUEL-Pump-Left-1"].setColorFill(0.0509,0.7529,0.2941);
		} else {
			me["FUEL-Pump-Left-1-Open"].hide();
			me["FUEL-Pump-Left-1-Closed"].show();
			me["FUEL-Pump-Left-1"].setColor(0.7333,0.3803,0);
			me["FUEL-Pump-Left-1"].setColorFill(0.7333,0.3803,0);
		}

		# TODO add LO indication
		if (systems.FUEL.Switches.pumpLeft2.getValue() == 1) {
			me["FUEL-Pump-Left-2-Open"].show();
			me["FUEL-Pump-Left-2-Closed"].hide();
			me["FUEL-Pump-Left-2"].setColor(0.0509,0.7529,0.2941);
			me["FUEL-Pump-Left-2"].setColorFill(0.0509,0.7529,0.2941);
		} else {
			me["FUEL-Pump-Left-2-Open"].hide();
			me["FUEL-Pump-Left-2-Closed"].show();
			me["FUEL-Pump-Left-2"].setColor(0.7333,0.3803,0);
			me["FUEL-Pump-Left-2"].setColorFill(0.7333,0.3803,0);
		}

		# TODO add functionality to match FCOM 1.28.20 "Amber: Transfer valve is open, whereas commanded closed in automatic or manual mode" 
		if (systems.FUEL.Switches.pumpCenter1.getValue() == 1) {
			me["FUEL-Pump-Center-1-Open"].show();
			me["FUEL-Pump-Center-1-Closed"].hide();
			me["FUEL-Pump-Center-1"].setColor(0.0509,0.7529,0.2941);
			me["FUEL-Pump-Center-1"].setColorFill(0.0509,0.7529,0.2941);
		} else {
			me["FUEL-Pump-Center-1-Open"].hide();
			me["FUEL-Pump-Center-1-Closed"].show();
			me["FUEL-Pump-Center-1"].setColor(0.7333,0.3803,0);
			me["FUEL-Pump-Center-1"].setColorFill(0.7333,0.3803,0);
		}

		# TODO add LO indication
		if (systems.FUEL.Switches.pumpCenter2.getValue() == 1) {
			me["FUEL-Pump-Center-2-Open"].show();
			me["FUEL-Pump-Center-2-Closed"].hide();
			me["FUEL-Pump-Center-2"].setColor(0.0509,0.7529,0.2941);
			me["FUEL-Pump-Center-2"].setColorFill(0.0509,0.7529,0.2941);
		} else {
			me["FUEL-Pump-Center-2-Open"].hide();
			me["FUEL-Pump-Center-2-Closed"].show();
			me["FUEL-Pump-Center-2"].setColor(0.7333,0.3803,0);
			me["FUEL-Pump-Center-2"].setColorFill(0.7333,0.3803,0);
		}

		# TODO add LO indication
		if (systems.FUEL.Switches.pumpRight1.getValue() == 1) {
			me["FUEL-Pump-Right-1-Open"].show();
			me["FUEL-Pump-Right-1-Closed"].hide();
			me["FUEL-Pump-Right-1"].setColor(0.0509,0.7529,0.2941);
			me["FUEL-Pump-Right-1"].setColorFill(0.0509,0.7529,0.2941);
		} else {
			me["FUEL-Pump-Right-1-Open"].hide();
			me["FUEL-Pump-Right-1-Closed"].show();
			me["FUEL-Pump-Right-1"].setColor(0.7333,0.3803,0);
			me["FUEL-Pump-Right-1"].setColorFill(0.7333,0.3803,0);
		}

		# TODO add LO indication
		if (systems.FUEL.Switches.pumpRight2.getValue() == 1) {
			me["FUEL-Pump-Right-2-Open"].show();
			me["FUEL-Pump-Right-2-Closed"].hide();
			me["FUEL-Pump-Right-2"].setColor(0.0509,0.7529,0.2941);
			me["FUEL-Pump-Right-2"].setColorFill(0.0509,0.7529,0.2941);
		} else {
			me["FUEL-Pump-Right-2-Open"].hide();
			me["FUEL-Pump-Right-2-Closed"].show();
			me["FUEL-Pump-Right-2"].setColor(0.7333,0.3803,0);
			me["FUEL-Pump-Right-2"].setColorFill(0.7333,0.3803,0);
		}

		# Fuel Used
		if (_weight_kgs == 1) {
			me["FUEL-used-1"].setText(sprintf("%s", math.round(fuel_used_lbs1.getValue() * LBS2KGS, 10)));
			me["FUEL-used-2"].setText(sprintf("%s", math.round(fuel_used_lbs2.getValue() * LBS2KGS, 10)));
			me["FUEL-used-both"].setText(sprintf("%s", (math.round(fuel_used_lbs1.getValue() * LBS2KGS, 10) + math.round(fuel_used_lbs2.getValue() * LBS2KGS, 10))));
			me["Fused-weight-unit"].setText("KG");
		} else {
			me["FUEL-used-1"].setText(sprintf("%s", math.round(fuel_used_lbs1.getValue(), 10)));
			me["FUEL-used-2"].setText(sprintf("%s", math.round(fuel_used_lbs2.getValue(), 10)));
			me["FUEL-used-both"].setText(sprintf("%s", (math.round(fuel_used_lbs1.getValue(), 10) + math.round(fuel_used_lbs2.getValue(), 10))));
			me["Fused-weight-unit"].setText("LBS");
		}

		# Fuel Temp
		me["FUEL-Left-Outer-temp"].setText(sprintf("%s", math.round(fuel_left_outer_temp.getValue())));
		me["FUEL-Left-Inner-temp"].setText(sprintf("%s", math.round(fuel_left_inner_temp.getValue())));
		me["FUEL-Right-Outer-temp"].setText(sprintf("%s", math.round(fuel_right_outer_temp.getValue())));
		me["FUEL-Right-Inner-temp"].setText(sprintf("%s", math.round(fuel_right_inner_temp.getValue())));

		# Fuel Quantity
		# TODO add LO indication
		if (_weight_kgs == 1) {
			me["FUEL-Left-Outer-quantity"].setText(sprintf("%s",  math.round(systems.FUEL.Quantity.leftOuter.getValue() * LBS2KGS, 10)));
			me["FUEL-Left-Inner-quantity"].setText(sprintf("%s", math.round(systems.FUEL.Quantity.leftInner.getValue() * LBS2KGS, 10)));
			me["FUEL-Center-quantity"].setText(sprintf("%s", math.round(systems.FUEL.Quantity.center.getValue() * LBS2KGS, 10)));
			me["FUEL-Right-Inner-quantity"].setText(sprintf("%s", math.round(systems.FUEL.Quantity.rightInner.getValue() * LBS2KGS, 10)));
			me["FUEL-Right-Outer-quantity"].setText(sprintf("%s",  math.round(systems.FUEL.Quantity.rightOuter.getValue() * LBS2KGS, 10)));
		} else {
			me["FUEL-Left-Outer-quantity"].setText(sprintf("%s",  math.round(systems.FUEL.Quantity.leftOuter.getValue(), 10)));
			me["FUEL-Left-Inner-quantity"].setText(sprintf("%s", math.round(systems.FUEL.Quantity.leftInner.getValue(), 10)));
			me["FUEL-Center-quantity"].setText(sprintf("%s", math.round(systems.FUEL.Quantity.center.getValue(), 10)));
			me["FUEL-Right-Inner-quantity"].setText(sprintf("%s", math.round(systems.FUEL.Quantity.rightInner.getValue(), 10)));
			me["FUEL-Right-Outer-quantity"].setText(sprintf("%s",  math.round(systems.FUEL.Quantity.rightOuter.getValue(), 10)));
		}
		
		if (systems.FUEL.Valves.transfer1.getValue() == 0) {
			me["FUEL-Left-Transfer"].hide();
		} else {
			if (systems.FUEL.Valves.transfer1.getValue() == 1) {
				me["FUEL-Left-Transfer"].setColor(0.0509,0.7529,0.2941);
			} else {
				me["FUEL-Left-Transfer"].setColor(0.7333,0.3803,0);
			}
			me["FUEL-Left-Transfer"].show();
		}
		
		if (systems.FUEL.Valves.transfer2.getValue() == 0) {
			me["FUEL-Right-Transfer"].hide();
		} else {
			if (systems.FUEL.Valves.transfer2.getValue() == 1) {
				me["FUEL-Right-Transfer"].setColor(0.0509,0.7529,0.2941);
			} else {
				me["FUEL-Right-Transfer"].setColor(0.7333,0.3803,0);
			}
			me["FUEL-Right-Transfer"].show();
		}
		
		if (!systems.FUEL.Switches.pumpCenter1.getValue() and !systems.FUEL.Switches.pumpCenter2.getValue()) {
			me["FUEL-Center-blocked"].show();
		} else {
			me["FUEL-Center-blocked"].hide();
		}
		
		# APU
		if (systems.FUEL.Valves.apu.getValue() == 1 and systems.APUNodes.Controls.master.getValue() and !systems.APUNodes.Controls.fire.getValue()) {
			me["FUEL-APU-label"].setColor(0.8078, 0.8039, 0.8078);
			me["FUEL-APU-line"].setColor(0.0509,0.7529,0.2941);
			me["FUEL-APU-arrow"].setColor(0.0509,0.7529,0.2941);
			me["FUEL-APU-line"].show();
			me["FUEL-APU-arrow"].show();
		} elsif (systems.FUEL.Valves.apu.getValue() == 1 and (!systems.APUNodes.Controls.master.getValue() or systems.APUNodes.Controls.fire.getValue())) {
			me["FUEL-APU-label"].setColor(0.7333,0.3803,0);
			me["FUEL-APU-line"].setColor(0.7333,0.3803,0);
			me["FUEL-APU-arrow"].setColor(0.7333,0.3803,0);
			me["FUEL-APU-line"].show();
			me["FUEL-APU-arrow"].show();
		} elsif (systems.FUEL.Valves.apu.getValue() != 1 and (systems.APUNodes.Controls.master.getValue() or systems.APUNodes.Controls.fire.getValue())) {
			me["FUEL-APU-label"].setColor(0.7333,0.3803,0);
			me["FUEL-APU-line"].hide();
			me["FUEL-APU-arrow"].hide();
		} else {
			me["FUEL-APU-label"].setColor(0.8078, 0.8039, 0.8078);
			me["FUEL-APU-arrow"].setColor(0.8078, 0.8039, 0.8078);
			me["FUEL-APU-line"].hide();
			me["FUEL-APU-arrow"].show();
		}

		# Hide not yet implemented features
		# TODO add them
		me["FUEL-Left-blocked"].hide();
		me["FUEL-Right-blocked"].hide();
		me["FUEL-Left-Outer-Inacc"].hide();
		me["FUEL-Left-Inner-Inacc"].hide();
		me["FUEL-Right-Outer-Inacc"].hide();
		me["FUEL-Right-Inner-Inacc"].hide();
		me["FUEL-Center-Inacc"].hide();
		me.updateBottomStatus();
	},
};

var canvas_lowerECAM_press = {
	new: func(canvas_group, file) {
		var m = {parents: [canvas_lowerECAM_press, canvas_lowerECAM_base]};
		m.init(canvas_group, file);

		return m;
	},
	getKeys: func() {
		return ["TAT","SAT","GW","UTCh","UTCm","GW-weight-unit", "PRESS-Cab-VS", "PRESS-Cab-VS-neg", "PRESS-Cab-Alt"];
	},
	update: func() {
		me["PRESS-Cab-VS"].setText(sprintf("%4.0f", press_vs_norm.getValue()));
		me["PRESS-Cab-Alt"].setText(sprintf("%4.0f", cabinalt.getValue()));


		me.updateBottomStatus();
	},
};

var canvas_lowerECAM_status = {
	new: func(canvas_group, file) {
		var m = {parents: [canvas_lowerECAM_status, canvas_lowerECAM_base]};
		m.init(canvas_group, file);

		return m;
	},
	getKeys: func() {
		return ["TAT","SAT","GW","UTCh","UTCm","GW-weight-unit"];
	},
	update: func() {

		me.updateBottomStatus();
	},
};

var canvas_lowerECAM_hyd = {
	new: func(canvas_group, file) {
		var m = {parents: [canvas_lowerECAM_hyd, canvas_lowerECAM_base]};
		m.init(canvas_group, file);

		return m;
	},
	getKeys: func() {
		return ["TAT","SAT","GW","UTCh","UTCm","GW-weight-unit","Green-Indicator","Blue-Indicator","Yellow-Indicator","Press-Green","Press-Blue","Press-Yellow","Green-Line","Blue-Line","Yellow-Line","PTU-Supply-Line","PTU-supply-yellow","PTU-supply-green","PTU-connection",
		"PTU-Auto-or-off","RAT-label","RAT-stowed","RAT-not-stowed","ELEC-Yellow-off","ELEC-Yellow-on","ELEC-Yellow-label","ELEC-OVTH-Yellow","ELEC-Blue-label","ELEC-OVHT-Blue","ELEC-OVHT-Yellow","Pump-Green-label","Pump-Yellow-label","Pump-Green",
		"Pump-LOPR-Green","Pump-Green-off","Pump-Green-on","Pump-Yellow","Pump-LOPR-Yellow","Pump-Yellow-off","Pump-Yellow-on","Pump-Blue", "Pump-Blue-off","Pump-Blue-on","Fire-Valve-Green","Fire-Valve-Yellow","LO-AIR-PRESS-Green",
		"LO-AIR-PRESS-Yellow","LO-AIR-PRESS-Blue","OVHT-Green","OVHT-Blue","OVHT-Yellow","Quantity-Indicator-Green","Quantity-Indicator-Blue","Quantity-Indicator-Yellow","Green-label","Blue-label","Yellow-label"];
	},
	update: func() {
		blue_psi = systems.HYD.Psi.blue.getValue();
		green_psi = systems.HYD.Psi.green.getValue();
		yellow_psi = systems.HYD.Psi.yellow.getValue();

		me["Press-Green"].setText(sprintf("%s", math.round(green_psi, 50)));
		me["Press-Blue"].setText(sprintf("%s", math.round(blue_psi, 50)));
		me["Press-Yellow"].setText(sprintf("%s", math.round(yellow_psi, 50)));

		if (blue_psi >= 1500) {
			me["Blue-Line"].setColor(0.0509,0.7529,0.2941);
			me["Blue-Line"].setColorFill(0.0509,0.7529,0.2941);
			me["Blue-Indicator"].setColor(0.0509,0.7529,0.2941);
			me["Press-Blue"].setColor(0.0509,0.7529,0.2941);
			me["Blue-label"].setColor(0.8078,0.8039,0.8078);
		} else {
			me["Blue-Line"].setColor(0.7333,0.3803,0);
			me["Blue-Line"].setColorFill(0.7333,0.3803,0);
			me["Blue-Indicator"].setColor(0.7333,0.3803,0);
			me["Press-Blue"].setColor(0.7333,0.3803,0);
			me["Blue-label"].setColor(0.7333,0.3803,0);
		}

		if (yellow_psi >= 1500) {
			me["Yellow-Line"].setColor(0.0509,0.7529,0.2941);
			me["Yellow-Line"].setColorFill(0.0509,0.7529,0.2941);
			me["Yellow-Indicator"].setColor(0.0509,0.7529,0.2941);
			me["Press-Yellow"].setColor(0.0509,0.7529,0.2941);
			me["Yellow-label"].setColor(0.8078,0.8039,0.8078);
		} else {
			me["Yellow-Line"].setColor(0.7333,0.3803,0);
			me["Yellow-Line"].setColorFill(0.7333,0.3803,0);
			me["Yellow-Indicator"].setColor(0.7333,0.3803,0);
			me["Press-Yellow"].setColor(0.7333,0.3803,0);
			me["Yellow-label"].setColor(0.7333,0.3803,0);
		}

		if (green_psi >= 1500) {
			me["Green-Line"].setColor(0.0509,0.7529,0.2941);
			me["Green-Line"].setColorFill(0.0509,0.7529,0.2941);
			me["Green-Indicator"].setColor(0.0509,0.7529,0.2941);
			me["Press-Green"].setColor(0.0509,0.7529,0.2941);
			me["Green-label"].setColor(0.8078,0.8039,0.8078);
		} else {
			me["Green-Line"].setColor(0.7333,0.3803,0);
			me["Green-Line"].setColorFill(0.7333,0.3803,0);
			me["Green-Indicator"].setColor(0.7333,0.3803,0);
			me["Press-Green"].setColor(0.7333,0.3803,0);
			me["Green-label"].setColor(0.7333,0.3803,0);
		}
		
		if (systems.HYD.Switch.ptu.getValue() and !systems.HYD.Fail.ptuFault.getValue()) {
			me["PTU-connection"].setColor(0.0509,0.7529,0.2941);

			if (systems.HYD.Ptu.active.getValue()) {
				if (systems.HYD.Ptu.diff.getValue() < 0) {
					me["PTU-Supply-Line"].show();
					me["PTU-supply-yellow"].show();
					me["PTU-supply-green"].hide();
					me["PTU-Auto-or-off"].hide();
				} else {
					me["PTU-Supply-Line"].show();
					me["PTU-supply-yellow"].hide();
					me["PTU-supply-green"].show();
					me["PTU-Auto-or-off"].hide();
				}
			} else {
				me["PTU-Auto-or-off"].setColor(0.0509,0.7529,0.2941);
				me["PTU-Supply-Line"].hide();
				me["PTU-supply-yellow"].hide();
				me["PTU-supply-green"].hide();
				me["PTU-Auto-or-off"].show();
			}
		} else {
			me["PTU-connection"].setColor(0.7333,0.3803,0);
			me["PTU-Auto-or-off"].setColor(0.7333,0.3803,0);
			me["PTU-Supply-Line"].hide();
			me["PTU-supply-yellow"].hide();
			me["PTU-supply-green"].hide();
			me["PTU-Auto-or-off"].show();
		}

		if (eng1_n2.getValue() >= 59) {
			me["Pump-Green-label"].setColor(0.8078,0.8039,0.8078);
		} else {
			me["Pump-Green-label"].setColor(0.7333,0.3803,0);
		}

		if (eng2_n2.getValue() >= 59) {
			me["Pump-Yellow-label"].setColor(0.8078,0.8039,0.8078);
		} else {
			me["Pump-Yellow-label"].setColor(0.7333,0.3803,0);
		}

		if (systems.HYD.Switch.greenEDP.getValue()) {
			me["Pump-Green-off"].hide();
			if (green_psi >= 1500) {
				me["Pump-Green-on"].show();
				me["Pump-LOPR-Green"].hide();
				me["Pump-Green"].setColor(0.0509,0.7529,0.2941);
				me["Pump-Green"].setColorFill(0.0509,0.7529,0.2941);
			} else {
				me["Pump-Green-on"].hide();
				me["Pump-LOPR-Green"].show();
				me["Pump-Green"].setColor(0.7333,0.3803,0);
				me["Pump-Green"].setColorFill(0.7333,0.3803,0);
			}
		} else {
			me["Pump-Green-off"].show();
			me["Pump-Green-on"].hide();
			me["Pump-LOPR-Green"].hide();
			me["Pump-Green"].setColor(0.7333,0.3803,0);
		}

		if (systems.HYD.Switch.yellowEDP.getValue()) {
			me["Pump-Yellow-off"].hide();
			if (yellow_psi >= 1500) {
				me["Pump-Yellow-on"].show();
				me["Pump-LOPR-Yellow"].hide();
				me["Pump-Yellow"].setColorFill(0.0509,0.7529,0.2941);
				me["Pump-Yellow"].setColor(0.0509,0.7529,0.2941);
			} else {
				me["Pump-Yellow-on"].hide();
				me["Pump-LOPR-Yellow"].show();
				me["Pump-Yellow"].setColorFill(0.7333,0.3803,0);
				me["Pump-Yellow"].setColor(0.7333,0.3803,0);
			}
		} else {
			me["Pump-Yellow-off"].show();
			me["Pump-Yellow-on"].hide();
			me["Pump-LOPR-Yellow"].hide();
			me["Pump-Yellow"].setColorFill(0.7333,0.3803,0);
			me["Pump-Yellow"].setColor(0.7333,0.3803,0);
		}

		if (systems.HYD.Switch.blueElec.getValue()) {
			me["Pump-Blue-off"].hide();
			if (blue_psi >= 1500) {
				me["Pump-Blue-on"].show();
				me["Pump-Blue-off"].hide();
				me["Pump-Blue"].setColorFill(0.0509,0.7529,0.2941);
				me["Pump-Blue"].setColor(0.0509,0.7529,0.2941);
			} else {
				me["Pump-Blue-off"].show();
				me["Pump-Blue-on"].hide();
				me["Pump-Blue"].setColorFill(0.7333,0.3803,0);
				me["Pump-Blue"].setColor(0.7333,0.3803,0);
			}
		} else {
			me["Pump-Blue-off"].show();
			me["Pump-Blue-on"].hide();
			me["Pump-Blue"].setColorFill(0.7333,0.3803,0);
			me["Pump-Blue"].setColor(0.7333,0.3803,0);
		}

		if (!systems.HYD.Switch.yellowElec.getValue()) {
			me["ELEC-Yellow-on"].hide();
			me["ELEC-Yellow-off"].show();
		} else {
			me["ELEC-Yellow-on"].show();
			me["ELEC-Yellow-off"].hide();
			if (yellow_psi >= 1500) {
				me["ELEC-Yellow-on"].setColor(0.0509,0.7529,0.2941);
			} else {
				me["ELEC-Yellow-on"].setColor(0.7333,0.3803,0);
			}
		}

		if (y_resv_lo_air_press.getValue() == 1) {
			me["LO-AIR-PRESS-Yellow"].show();
		} else {
			me["LO-AIR-PRESS-Yellow"].hide();
		}

		if (b_resv_lo_air_press.getValue() == 1) {
			me["LO-AIR-PRESS-Blue"].show();
		} else {
			me["LO-AIR-PRESS-Blue"].hide();
		}

		if (g_resv_lo_air_press.getValue() == 1) {
			me["LO-AIR-PRESS-Green"].show();
		} else {
			me["LO-AIR-PRESS-Green"].hide();
		}

		if (elec_pump_y_ovht.getValue() == 1) {
			me["ELEC-OVHT-Yellow"].show();
		} else {
			me["ELEC-OVHT-Yellow"].hide();
		}

		if (elec_pump_b_ovht.getValue() == 1) {
			me["ELEC-OVHT-Blue"].show();
		} else {
			me["ELEC-OVHT-Blue"].hide();
		}

		if (systems.HYD.Rat.position.getValue() == 1) {
			me["RAT-stowed"].hide();
			me["RAT-not-stowed"].show();
		} else {
			me["RAT-stowed"].show();
			me["RAT-not-stowed"].hide();
		}

		if (y_resv_ovht.getValue() == 1) {
			me["OVHT-Yellow"].show();
		} else {
			me["OVHT-Yellow"].hide();
		}

		if (b_resv_ovht.getValue() == 1) {
			me["OVHT-Green"].show();
		} else {
			me["OVHT-Green"].hide();
		}

		if (g_resv_ovht.getValue() == 1) {
			me["OVHT-Blue"].show();
		} else {
			me["OVHT-Blue"].hide();
		}

		if (systems.ELEC.Bus.ac1.getValue() >= 110) {
			me["ELEC-Blue-label"].setColor(0.8078,0.8039,0.8078);
		} else {
			me["ELEC-Blue-label"].setColor(0.7333,0.3803,0);
		}

		if (systems.ELEC.Bus.ac2.getValue() >= 110) {
			me["ELEC-Yellow-label"].setColor(0.8078,0.8039,0.8078);
		} else {
			me["ELEC-Yellow-label"].setColor(0.7333,0.3803,0);
		}

		if (systems.HYD.Valve.yellowFire.getValue() != 0) {
			me["Fire-Valve-Yellow"].setColor(0.7333,0.3803,0);
			me["Fire-Valve-Yellow"].setRotation(90 * D2R);
		} else {
			me["Fire-Valve-Yellow"].setColor(0.0509,0.7529,0.2941);
			me["Fire-Valve-Yellow"].setRotation(0);
		}

		if (systems.HYD.Valve.greenFire.getValue() != 0) {
			me["Fire-Valve-Green"].setColor(0.7333,0.3803,0);
			me["Fire-Valve-Green"].setRotation(90 * D2R);
		} else {
			me["Fire-Valve-Green"].setColor(0.0509,0.7529,0.2941);
			me["Fire-Valve-Green"].setRotation(0);
		}

		me.updateBottomStatus();
	},
};

var canvas_lowerECAM_wheel = {
	new: func(canvas_group, file) {
		var m = {parents: [canvas_lowerECAM_wheel, canvas_lowerECAM_base]};
		m.init(canvas_group, file);

		return m;
	},
	getKeys: func() {
		return ["TAT","SAT","GW","UTCh","UTCm","GW-weight-unit","lgctltext","NORMbrk","NWStext","leftdoor","rightdoor","nosegeardoorL","nosegeardoorR","autobrk","autobrkind","NWS","NWSrect","normbrk-rect","altnbrk","normbrkhyd","spoiler1Rex","spoiler1Rrt","spoiler2Rex",
		"spoiler2Rrt","spoiler3Rex","spoiler3Rrt","spoiler4Rex","spoiler4Rrt","spoiler5Rex","spoiler5Rrt","spoiler1Lex","spoiler1Lrt","spoiler2Lex","spoiler2Lrt","spoiler3Lex","spoiler3Lrt","spoiler4Lex","spoiler4Lrt","spoiler5Lex","spoiler5Lrt","spoiler1Rf",
		"spoiler2Rf","spoiler3Rf","spoiler4Rf","spoiler5Rf","spoiler1Lf","spoiler2Lf","spoiler3Lf","spoiler4Lf","spoiler5Lf","ALTNbrk","altnbrkhyd","altnbrk-rect","antiskidtext","brakearrow","accupress_text","accuonlyarrow","accuonly","braketemp1","normbrkhyd",
		"braketemp2","braketemp3","braketemp4","toparc1","toparc2","toparc3","toparc4","leftuplock","noseuplock","rightuplock","Triangle-Left1","Triangle-Left2","Triangle-Nose1","Triangle-Nose2","Triangle-Right1","Triangle-Right2","BSCUrect1","BSCUrect2","BSCU1","BSCU2"];
	},
	update: func() {
		blue_psi = systems.HYD.Psi.blue.getValue();
		green_psi = systems.HYD.Psi.green.getValue();
		yellow_psi = systems.HYD.Psi.yellow.getValue();
		autobrakemode = autobreak_mode.getValue();
		nosegear = gear1_pos.getValue();
		leftgear = gear2_pos.getValue();
		rightgear = gear3_pos.getValue();
		leftdoor = gear_door_L.getValue();
		rightdoor = gear_door_R.getValue();
		nosedoor = gear_door_N.getValue();
		gearlvr = gear_down.getValue();
		askidsw = systems.HYD.Brakes.askidSw.getBoolValue();
		brakemode = systems.HYD.Brakes.mode.getBoolValue();
		accum = systems.HYD.Brakes.accumPressPsi.getBoolValue();

		# L/G CTL
		if ((leftgear == 0 or nosegear == 0 or rightgear == 0 and gearlvr == 0) or (leftgear == 1 or nosegear == 1 or rightgear == 1 and gearlvr == 1)) {
			me["lgctltext"].hide();
		} else {
			me["lgctltext"].show();
		}

		# NWS / Antiskid / Brakes
		if (askidsw and yellow_psi >= 1500) {
			me["NWStext"].hide();
			me["NWS"].hide();
			me["NWSrect"].hide();
			me["antiskidtext"].hide();
			me["BSCUrect1"].hide();
			me["BSCUrect2"].hide();
			me["BSCU1"].hide();
			me["BSCU2"].hide();
		} else if (!askidsw and yellow_psi >= 1500) {
			me["NWStext"].show();
			me["NWS"].show();
			me["NWS"].setColor(0.0509,0.7529,0.2941);
			me["NWSrect"].show();
			me["antiskidtext"].show();
			me["antiskidtext"].setColor(0.7333,0.3803,0);
			me["BSCUrect1"].show();
			me["BSCUrect2"].show();
			me["BSCU1"].show();
			me["BSCU2"].show();
		} else {
			me["NWStext"].show();
			me["NWS"].show();
			me["NWS"].setColor(0.7333,0.3803,0);
			me["NWSrect"].show();
			me["antiskidtext"].show();
			me["antiskidtext"].setColor(0.7333,0.3803,0);
			me["BSCUrect1"].show();
			me["BSCUrect2"].show();
			me["BSCU1"].show();
			me["BSCU2"].show();
		}

		if (green_psi >= 1500 and brakemode == 1) {
			me["NORMbrk"].hide();
			me["normbrk-rect"].hide();
			me["normbrkhyd"].hide();
		} else if (green_psi >= 1500 and askidsw) {
			me["NORMbrk"].show();
			me["normbrk-rect"].show();
			me["NORMbrk"].setColor(0.7333,0.3803,0);
			me["normbrkhyd"].setColor(0.0509,0.7529,0.2941);
		} else if (green_psi < 1500 or !askidsw) {
			me["NORMbrk"].show();
			me["normbrk-rect"].show();
			me["NORMbrk"].setColor(0.7333,0.3803,0);
			me["normbrkhyd"].setColor(0.7333,0.3803,0);
		}

		if (brakemode != 2) {
			me["ALTNbrk"].hide();
			me["altnbrk-rect"].hide();
			me["altnbrkhyd"].hide();
		} else if (yellow_psi >= 1500) {
			me["ALTNbrk"].show();
			me["altnbrk-rect"].show();
			me["altnbrkhyd"].setColor(0.0509,0.7529,0.2941);
		} else {
			me["ALTNbrk"].show();
			me["altnbrk-rect"].show();
			me["altnbrkhyd"].setColor(0.7333,0.3803,0);
		}

		if (brakemode == 2 and accum < 200 and yellow_psi < 1500) {
			me["accupress_text"].show();
			me["brakearrow"].hide();
			me["accupress_text"].setColor(0.7333,0.3803,0);
		} else if (brakemode == 2 and accum > 200 and yellow_psi >= 1500){
			me["accupress_text"].show();
			me["brakearrow"].show();
			me["accupress_text"].setColor(0.0509,0.7529,0.2941);
		} else if (brakemode == 2 and accum > 200 and yellow_psi < 1500) {
			me["accuonlyarrow"].show();
			me["accuonly"].show();
			me["brakearrow"].hide();
			me["accupress_text"].hide();
		} else {
			me["accuonlyarrow"].hide();
			me["accuonly"].hide();
			me["brakearrow"].hide();
			me["accupress_text"].hide();
		}

		# Gear Doors
		me["leftdoor"].setRotation(door_left.getValue() * D2R);
		me["rightdoor"].setRotation(door_right.getValue() * D2R);
		me["nosegeardoorL"].setRotation(door_nose_left.getValue() * D2R);
		me["nosegeardoorR"].setRotation(door_nose_right.getValue() * D2R);

		if (nosedoor == 0) {
			me["nosegeardoorL"].setColorFill(0.0509,0.7529,0.2941);
			me["nosegeardoorR"].setColorFill(0.0509,0.7529,0.2941);
		} else {
			me["nosegeardoorL"].setColorFill(0.7333,0.3803,0);
			me["nosegeardoorR"].setColorFill(0.7333,0.3803,0);
		}

		if (leftdoor == 0) {
			me["leftdoor"].setColorFill(0.0509,0.7529,0.2941);
		} else {
			me["leftdoor"].setColorFill(0.7333,0.3803,0);
		}

		if (rightdoor == 0) {
			me["rightdoor"].setColorFill(0.0509,0.7529,0.2941);
		} else {
			me["rightdoor"].setColorFill(0.7333,0.3803,0);
		}

		# Triangles
		if (leftgear < 0.2 or leftgear > 0.8) {
			me["Triangle-Left1"].hide();
			me["Triangle-Left2"].hide();
		} else {
			me["Triangle-Left1"].show();
			me["Triangle-Left2"].show();
		}

		if (leftgear == 1) {
			me["Triangle-Left1"].setColor(0.0509,0.7529,0.2941);
			me["Triangle-Left2"].setColor(0.0509,0.7529,0.2941);
		} else {
			me["Triangle-Left1"].setColor(1,0,0);
			me["Triangle-Left2"].setColor(1,0,0);
		}

		if (nosegear < 0.2 or nosegear > 0.8) {
			me["Triangle-Nose1"].hide();
			me["Triangle-Nose2"].hide();
		} else {
			me["Triangle-Nose1"].show();
			me["Triangle-Nose2"].show();
		}

		if (nosegear == 1) {
			me["Triangle-Nose1"].setColor(0.0509,0.7529,0.2941);
			me["Triangle-Nose2"].setColor(0.0509,0.7529,0.2941);
		} else {
			me["Triangle-Nose1"].setColor(1,0,0);
			me["Triangle-Nose2"].setColor(1,0,0);
		}

		if (rightgear < 0.2 or rightgear > 0.8) {
			me["Triangle-Right1"].hide();
			me["Triangle-Right2"].hide();
		} else {
			me["Triangle-Right1"].show();
			me["Triangle-Right2"].show();
		}

		if (rightgear == 1) {
			me["Triangle-Right1"].setColor(0.0509,0.7529,0.2941);
			me["Triangle-Right2"].setColor(0.0509,0.7529,0.2941);
		} else {
			me["Triangle-Right1"].setColor(1,0,0);
			me["Triangle-Right2"].setColor(1,0,0);
		}

		# Autobrake
		if (autobrakemode == 0) {
			me["autobrkind"].hide();
		} elsif (autobrakemode == 1) {
			me["autobrkind"].show();
			me["autobrkind"].setText(sprintf("%s", "LO"));
		} elsif (autobrakemode == 2) {
			me["autobrkind"].show();
			me["autobrkind"].setText(sprintf("%s", "MED"));
		} elsif (autobrakemode == 3) {
			me["autobrkind"].show();
			me["autobrkind"].setText(sprintf("%s", "MAX"));
		}

		if (autobrakemode != 0) {
			me["autobrk"].show();
		} elsif (autobrakemode == 0) {
			me["autobrk"].hide();
		}

		# Spoilers
		if (spoiler_L1.getValue() < 1.5) {
			me["spoiler1Lex"].hide();
			me["spoiler1Lrt"].show();
		} else {
			me["spoiler1Lrt"].hide();
			me["spoiler1Lex"].show();
		}

		if (spoiler_L2.getValue() < 1.5) {
			me["spoiler2Lex"].hide();
			me["spoiler2Lrt"].show();
		} else {
			me["spoiler2Lrt"].hide();
			me["spoiler2Lex"].show();
		}

		if (spoiler_L3.getValue() < 1.5) {
			me["spoiler3Lex"].hide();
			me["spoiler3Lrt"].show();
		} else {
			me["spoiler3Lrt"].hide();
			me["spoiler3Lex"].show();
		}

		if (spoiler_L4.getValue() < 1.5) {
			me["spoiler4Lex"].hide();
			me["spoiler4Lrt"].show();
		} else {
			me["spoiler4Lrt"].hide();
			me["spoiler4Lex"].show();
		}

		if (spoiler_L5.getValue() < 1.5) {
			me["spoiler5Lex"].hide();
			me["spoiler5Lrt"].show();
		} else {
			me["spoiler5Lrt"].hide();
			me["spoiler5Lex"].show();
		}

		if (spoiler_R1.getValue() < 1.5) {
			me["spoiler1Rex"].hide();
			me["spoiler1Rrt"].show();
		} else {
			me["spoiler1Rrt"].hide();
			me["spoiler1Rex"].show();
		}

		if (spoiler_R2.getValue() < 1.5) {
			me["spoiler2Rex"].hide();
			me["spoiler2Rrt"].show();
		} else {
			me["spoiler2Rrt"].hide();
			me["spoiler2Rex"].show();
		}

		if (spoiler_R3.getValue() < 1.5) {
			me["spoiler3Rex"].hide();
			me["spoiler3Rrt"].show();
		} else {
			me["spoiler3Rrt"].hide();
			me["spoiler3Rex"].show();
		}

		if (spoiler_R4.getValue() < 1.5) {
			me["spoiler4Rex"].hide();
			me["spoiler4Rrt"].show();
		} else {
			me["spoiler4Rrt"].hide();
			me["spoiler4Rex"].show();
		}

		if (spoiler_R5.getValue() < 1.5) {
			me["spoiler5Rex"].hide();
			me["spoiler5Rrt"].show();
		} else {
			me["spoiler5Rrt"].hide();
			me["spoiler5Rex"].show();
		}

		# Spoiler Fail
		if (spoiler_L1_fail.getValue() or green_psi < 1500) {
			me["spoiler1Lex"].setColor(0.7333,0.3803,0);
			me["spoiler1Lrt"].setColor(0.7333,0.3803,0);
			if (spoiler_L1.getValue() < 1.5) {
				me["spoiler1Lf"].show();
			} else {
				me["spoiler1Lf"].hide();
			}
		} else {
			me["spoiler1Lex"].setColor(0.0509,0.7529,0.2941);
			me["spoiler1Lrt"].setColor(0.0509,0.7529,0.2941);
			me["spoiler1Lf"].hide();
		}

		if (spoiler_L2_fail.getValue() or yellow_psi < 1500) {
			me["spoiler2Lex"].setColor(0.7333,0.3803,0);
			me["spoiler2Lrt"].setColor(0.7333,0.3803,0);
			if (spoiler_L2.getValue() < 1.5) {
				me["spoiler2Lf"].show();
			} else {
				me["spoiler2Lf"].hide();
			}
		} else {
			me["spoiler2Lex"].setColor(0.0509,0.7529,0.2941);
			me["spoiler2Lrt"].setColor(0.0509,0.7529,0.2941);
			me["spoiler2Lf"].hide();
		}

		if (spoiler_L3_fail.getValue() or blue_psi < 1500) {
			me["spoiler3Lex"].setColor(0.7333,0.3803,0);
			me["spoiler3Lrt"].setColor(0.7333,0.3803,0);
			if (spoiler_L3.getValue() < 1.5) {
				me["spoiler3Lf"].show();
			} else {
				me["spoiler3Lf"].hide();
			}
		} else {
			me["spoiler3Lex"].setColor(0.0509,0.7529,0.2941);
			me["spoiler3Lrt"].setColor(0.0509,0.7529,0.2941);
			me["spoiler3Lf"].hide();
		}

		if (spoiler_L4_fail.getValue() or yellow_psi < 1500) {
			me["spoiler4Lex"].setColor(0.7333,0.3803,0);
			me["spoiler4Lrt"].setColor(0.7333,0.3803,0);
			if (spoiler_L4.getValue() < 1.5) {
				me["spoiler4Lf"].show();
			} else {
				me["spoiler4Lf"].hide();
			}
		} else {
			me["spoiler4Lex"].setColor(0.0509,0.7529,0.2941);
			me["spoiler4Lrt"].setColor(0.0509,0.7529,0.2941);
			me["spoiler4Lf"].hide();
		}

		if (spoiler_L5_fail.getValue() or green_psi < 1500) {
			me["spoiler5Lex"].setColor(0.7333,0.3803,0);
			me["spoiler5Lrt"].setColor(0.7333,0.3803,0);
			if (spoiler_L5.getValue() < 1.5) {
				me["spoiler5Lf"].show();
			} else {
				me["spoiler5Lf"].hide();
			}
		} else {
			me["spoiler5Lex"].setColor(0.0509,0.7529,0.2941);
			me["spoiler5Lrt"].setColor(0.0509,0.7529,0.2941);
			me["spoiler5Lf"].hide();
		}

		if (spoiler_R1_fail.getValue() or green_psi < 1500) {
			me["spoiler1Rex"].setColor(0.7333,0.3803,0);
			me["spoiler1Rrt"].setColor(0.7333,0.3803,0);
			if (spoiler_R1.getValue() < 1.5) {
				me["spoiler1Rf"].show();
			} else {
				me["spoiler1Rf"].hide();
			}
		} else {
			me["spoiler1Rex"].setColor(0.0509,0.7529,0.2941);
			me["spoiler1Rrt"].setColor(0.0509,0.7529,0.2941);
			me["spoiler1Rf"].hide();
		}

		if (spoiler_R2_fail.getValue() or yellow_psi < 1500) {
			me["spoiler2Rex"].setColor(0.7333,0.3803,0);
			me["spoiler2Rrt"].setColor(0.7333,0.3803,0);
			if (spoiler_R2.getValue() < 1.5) {
				me["spoiler2Rf"].show();
			} else {
				me["spoiler2Rf"].hide();
			}
		} else {
			me["spoiler2Rex"].setColor(0.0509,0.7529,0.2941);
			me["spoiler2Rrt"].setColor(0.0509,0.7529,0.2941);
			me["spoiler2Rf"].hide();
		}

		if (spoiler_R3_fail.getValue() or blue_psi < 1500) {
			me["spoiler3Rex"].setColor(0.7333,0.3803,0);
			me["spoiler3Rrt"].setColor(0.7333,0.3803,0);
			if (spoiler_R3.getValue() < 1.5) {
				me["spoiler3Rf"].show();
			} else {
				me["spoiler3Rf"].hide();
			}
		} else {
			me["spoiler3Rex"].setColor(0.0509,0.7529,0.2941);
			me["spoiler3Rrt"].setColor(0.0509,0.7529,0.2941);
			me["spoiler3Rf"].hide();
		}

		if (spoiler_R4_fail.getValue() or yellow_psi < 1500) {
			me["spoiler4Rex"].setColor(0.7333,0.3803,0);
			me["spoiler4Rrt"].setColor(0.7333,0.3803,0);
			if (spoiler_R4.getValue() < 1.5) {
				me["spoiler4Rf"].show();
			} else {
				me["spoiler4Rf"].hide();
			}
		} else {
			me["spoiler4Rex"].setColor(0.0509,0.7529,0.2941);
			me["spoiler4Rrt"].setColor(0.0509,0.7529,0.2941);
			me["spoiler4Rf"].hide();
		}

		if (spoiler_R5_fail.getValue() or green_psi < 1500) {
			me["spoiler5Rex"].setColor(0.7333,0.3803,0);
			me["spoiler5Rrt"].setColor(0.7333,0.3803,0);
			if (spoiler_R5.getValue() < 1.5) {
				me["spoiler5Rf"].show();
			} else {
				me["spoiler5Rf"].hide();
			}
		} else {
			me["spoiler5Rex"].setColor(0.0509,0.7529,0.2941);
			me["spoiler5Rrt"].setColor(0.0509,0.7529,0.2941);
			me["spoiler5Rf"].hide();
		}

		# Show Brakes temperature
		if (L1BrakeTempc.getValue() > 300) {
			me["braketemp1"].setColor(0.7333,0.3803,0);
		} else {
			me["braketemp1"].setColor(0.0509,0.7529,0.2941);
		}

		if (L2BrakeTempc.getValue() > 300) {
			me["braketemp2"].setColor(0.7333,0.3803,0);
		} else {
			me["braketemp2"].setColor(0.0509,0.7529,0.2941);
		}
		if (R3BrakeTempc.getValue() > 300) {
			me["braketemp3"].setColor(0.7333,0.3803,0);
		} else {
			me["braketemp3"].setColor(0.0509,0.7529,0.2941);
		}
		if (R4BrakeTempc.getValue() > 300) {
			me["braketemp4"].setColor(0.7333,0.3803,0);
		} else {
			me["braketemp4"].setColor(0.0509,0.7529,0.2941);
		}
		
		# Brake arcs
		if (L1BrakeTempc.getValue() > 300) {
			me["toparc1"].setColor(0.7333,0.3803,0);
		} else 
		{
			if (L1BrakeTempc.getValue() > 100 and L1BrakeTempc.getValue() < 300)
			{
				me["toparc1"].setColor(0.0509,0.7529,0.2941);
			}
			else { 
				me["toparc1"].setColor(0.8078,0.8039,0.8078);
			}
		}
		if (L2BrakeTempc.getValue() > 300) {
			me["toparc2"].setColor(0.7333,0.3803,0);
		} else 
		{
			if (L2BrakeTempc.getValue() > 100 and L2BrakeTempc.getValue() < 300)
			{
				me["toparc2"].setColor(0.0509,0.7529,0.2941);
			}
			else { 
				me["toparc2"].setColor(0.8078,0.8039,0.8078);
			}
		}
		if (R3BrakeTempc.getValue() > 300) {
			me["toparc3"].setColor(0.7333,0.3803,0);
		} else 
		{
			if (R3BrakeTempc.getValue() > 100 and R3BrakeTempc.getValue() < 300)
			{
				me["toparc3"].setColor(0.0509,0.7529,0.2941);
			}
			else { 
				me["toparc3"].setColor(0.8078,0.8039,0.8078);
			}
		}
		if (R4BrakeTempc.getValue() > 300) {
			me["toparc4"].setColor(0.7333,0.3803,0);
		} else 
		{
			if (R4BrakeTempc.getValue() > 100 and R4BrakeTempc.getValue() < 300)
			{
				me["toparc4"].setColor(0.0509,0.7529,0.2941);
			}
			else { 
				me["toparc4"].setColor(0.8078,0.8039,0.8078);
			}
		}
		me["braketemp1"].setText(sprintf("%s", math.round(L1BrakeTempc.getValue(), 1)));
		me["braketemp2"].setText(sprintf("%s", math.round(L2BrakeTempc.getValue(), 1)));
		me["braketemp3"].setText(sprintf("%s", math.round(R3BrakeTempc.getValue(), 1)));
		me["braketemp4"].setText(sprintf("%s", math.round(R4BrakeTempc.getValue(), 1)));
		me["braketemp1"].show();
		me["braketemp2"].show();
		me["braketemp3"].show();
		me["braketemp4"].show();
		me["toparc1"].show();
		me["toparc2"].show();
		me["toparc3"].show();
		me["toparc4"].show();

		# Hide not yet implemented stuff
		me["leftuplock"].hide();
		me["noseuplock"].hide();
		me["rightuplock"].hide();

		me.updateBottomStatus();
	},
};

var canvas_lowerECAM_test = {
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
		var m = {parents: [canvas_lowerECAM_test]};
		m.init(canvas_group, file);

		return m;
	},
	getKeys: func() {
		return ["Test_white","Test_text"];
	},
	update: func() {
		var elapsedtime = elapsed_sec.getValue();
		if (du4_test_time.getValue() + 1 >= elapsedtime) {
			me["Test_white"].show();
			me["Test_text"].hide();
		} else {
			me["Test_white"].hide();
			me["Test_text"].show();
		}
	},
};

setlistener("sim/signals/fdm-initialized", func {
	lowerECAM_display = canvas.new({
		"name": "lowerECAM",
		"size": [1024, 1024],
		"view": [1024, 1024],
		"mipmapping": 1
	});
	lowerECAM_display.addPlacement({"node": "lecam.screen"});
	var groupApu = lowerECAM_display.createGroup();
	var groupBleed = lowerECAM_display.createGroup();
	var groupCond = lowerECAM_display.createGroup();
	var groupCrz = lowerECAM_display.createGroup();
	var groupDoor = lowerECAM_display.createGroup();
	var groupElec = lowerECAM_display.createGroup();
	var groupEng = lowerECAM_display.createGroup();
	var groupFctl = lowerECAM_display.createGroup();
	var groupFuel = lowerECAM_display.createGroup();
	var groupPress = lowerECAM_display.createGroup();
	var groupStatus = lowerECAM_display.createGroup();
	var groupHyd = lowerECAM_display.createGroup();
	var groupWheel = lowerECAM_display.createGroup();
	var group_test = lowerECAM_display.createGroup();

	lowerECAM_apu = canvas_lowerECAM_apu.new(groupApu, "Aircraft/A320-family/Models/Instruments/Lower-ECAM/res/apu.svg");
	lowerECAM_bleed = canvas_lowerECAM_bleed.new(groupBleed, "Aircraft/A320-family/Models/Instruments/Lower-ECAM/res/bleed.svg");
	lowerECAM_cond = canvas_lowerECAM_cond.new(groupCond, "Aircraft/A320-family/Models/Instruments/Lower-ECAM/res/cond.svg");
	lowerECAM_crz = canvas_lowerECAM_crz.new(groupCrz, "Aircraft/A320-family/Models/Instruments/Lower-ECAM/res/crz.svg");
	lowerECAM_door = canvas_lowerECAM_door.new(groupDoor, "Aircraft/A320-family/Models/Instruments/Lower-ECAM/res/door.svg");
	lowerECAM_elec = canvas_lowerECAM_elec.new(groupElec, "Aircraft/A320-family/Models/Instruments/Lower-ECAM/res/elec.svg");
	lowerECAM_eng = canvas_lowerECAM_eng.new(groupEng, "Aircraft/A320-family/Models/Instruments/Lower-ECAM/res/eng.svg");
	lowerECAM_fctl = canvas_lowerECAM_fctl.new(groupFctl, "Aircraft/A320-family/Models/Instruments/Lower-ECAM/res/fctl.svg");
	lowerECAM_fuel = canvas_lowerECAM_fuel.new(groupFuel, "Aircraft/A320-family/Models/Instruments/Lower-ECAM/res/fuel.svg");
	lowerECAM_press = canvas_lowerECAM_press.new(groupPress, "Aircraft/A320-family/Models/Instruments/Lower-ECAM/res/press.svg");
	lowerECAM_status = canvas_lowerECAM_status.new(groupStatus, "Aircraft/A320-family/Models/Instruments/Lower-ECAM/res/status.svg");
	lowerECAM_hyd = canvas_lowerECAM_hyd.new(groupHyd, "Aircraft/A320-family/Models/Instruments/Lower-ECAM/res/hyd.svg");
	lowerECAM_wheel = canvas_lowerECAM_wheel.new(groupWheel, "Aircraft/A320-family/Models/Instruments/Lower-ECAM/res/wheel.svg");
	lowerECAM_test = canvas_lowerECAM_test.new(group_test, "Aircraft/A320-family/Models/Instruments/Common/res/du-test.svg");

	lowerECAM_update.start();
	if (getprop("systems/acconfig/options/lecam-rate") > 1) {
		l_rateApply();
	}
});

var l_rateApply = func {
	lowerECAM_update.restart(0.05 * getprop("systems/acconfig/options/lecam-rate"));
}

var lowerECAM_update = maketimer(0.05, func {
	canvas_lowerECAM_base.update();
});

var showLowerECAM = func {
	var dlg = canvas.Window.new([512, 512], "dialog").set("resize", 1);
	dlg.setCanvas(lowerECAM_display);
}

setlistener("/systems/electrical/bus/ac-2", func() {
	canvas_lowerECAM_base.updateDu4();
}, 0, 0);