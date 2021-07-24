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
var elac1Node = 0;
var elac2Node = 0;
var sec1Node = 0;
var sec2Node = 0;
var eng_valve_state = 0;
var bleed_valve_cur = 0;
var hp_valve_state = 0;
var xbleedcmdstate = 0;
var ramAirState = 0;

# Fetch Nodes
var acconfig_weight_kgs = props.globals.getNode("/systems/acconfig/options/weight-kgs", 1);
var rate = props.globals.getNode("/systems/acconfig/options/lecam-rate", 1);
var autoconfig_running = props.globals.getNode("/systems/acconfig/autoconfig-running", 1);
var ecam_page = props.globals.getNode("/ECAM/Lower/page", 1);
var hour = props.globals.getNode("/sim/time/utc/hour", 1);
var minute = props.globals.getNode("/sim/time/utc/minute", 1);
var apu_flap = props.globals.getNode("/controls/apu/inlet-flap/position-norm", 1);
var apu_rpm = props.globals.getNode("/engines/engine[2]/n1", 1);
var apu_egt = props.globals.getNode("/systems/apu/egt-degC", 1);
var door_left = props.globals.getNode("/ECAM/Lower/door-left", 1);
var door_right = props.globals.getNode("/ECAM/Lower/door-right", 1);
var door_nose_left = props.globals.getNode("/ECAM/Lower/door-nose-left", 1);
var door_nose_right = props.globals.getNode("/ECAM/Lower/door-nose-right", 1);
var apu_rpm_rot = props.globals.getNode("/ECAM/Lower/APU-N", 1);
var apu_egt_rot = props.globals.getNode("/ECAM/Lower/APU-EGT", 1);
var oil_qt1 = props.globals.getNode("/ECAM/Lower/Oil-QT[0]", 1);
var oil_qt2 = props.globals.getNode("/ECAM/Lower/Oil-QT[1]", 1);
var oil_psi1 = props.globals.getNode("/ECAM/Lower/Oil-PSI[0]", 1);
var oil_psi2 = props.globals.getNode("/ECAM/Lower/Oil-PSI[1]", 1);
var bleedapu = props.globals.getNode("", 1);
var aileron_ind_left = props.globals.getNode("", 1);
var aileron_ind_right = props.globals.getNode("/ECAM/Lower/aileron-ind-right", 1);
var elevator_ind_left = props.globals.getNode("", 1);
var elevator_ind_right = props.globals.getNode("/ECAM/Lower/elevator-ind-right", 1);
var elevator_trim_deg = props.globals.getNode("", 1);
var final_deg = props.globals.getNode("", 1);
var temperature_degc = props.globals.getNode("/environment/temperature-degc", 1);
var tank3_content_lbs = props.globals.getNode("/fdm/jsbsim/propulsion/tank[2]/contents-lbs", 1);
var ir2_knob = props.globals.getNode("/controls/adirs/ir[1]/knob", 1);
var apuBleedNotOn = props.globals.getNode("", 1);
var apu_valve = props.globals.getNode("/systems/pneumatics/valves/apu-bleed-valve-cmd", 1);
var apu_valve_state = props.globals.getNode("/systems/pneumatics/valves/apu-bleed-valve", 1);
var xbleedcmd = props.globals.getNode("/systems/pneumatics/valves/crossbleed-valve-cmd", 1);
var xbleed = props.globals.getNode("/systems/pneumatics/valves/crossbleed-valve", 1);
var xbleedstate = nil;
var precooler1_psi = props.globals.getNode("/systems/pneumatics/psi/engine-1-psi", 1);
var precooler2_psi = props.globals.getNode("/systems/pneumatics/psi/engine-2-psi", 1);
var precooler1_temp = props.globals.getNode("/systems/pneumatics/precooler/temp-1", 1);
var precooler2_temp = props.globals.getNode("/systems/pneumatics/precooler/temp-2", 1);
var precooler1_ovht = props.globals.getNode("/systems/pneumatics/precooler/ovht-1", 1);
var precooler2_ovht = props.globals.getNode("/systems/pneumatics/precooler/ovht-2", 1);
var bmc1working = props.globals.getNode("", 1);
var bmc2working = props.globals.getNode("/systems/pneumatics/indicating/bmc2-working", 1);
var bmc1 = 0;
var bmc2 = 0;
var gs_kt = props.globals.getNode("/velocities/groundspeed-kt", 1);
var switch_wing_aice = props.globals.getNode("/controls/ice-protection/wing", 1);
var pack1_bypass = props.globals.getNode("/systems/pneumatics/pack-1-bypass", 1);
var pack2_bypass = props.globals.getNode("/systems/pneumatics/pack-2-bypass", 1);
var oil_qt1_actual = props.globals.getNode("", 1);
var oil_qt2_actual = props.globals.getNode("/engines/engine[1]/oil-qt-actual", 1);
var fuel_used_lbs1 = props.globals.getNode("", 1);
var gLoad = props.globals.getNode("", 1);

# Hydraulic
var blue_psi = 0;
var green_psi = 0;
var yellow_psi = 0;
var rat_deployed = props.globals.getNode("/controls/hydraulic/rat-deployed", 1);
var y_resv_ovht = props.globals.getNode("/systems/hydraulic/yellow-resv-ovht", 1);
var b_resv_ovht = props.globals.getNode("/systems/hydraulic/blue-resv-ovht", 1);
var g_resv_ovht = props.globals.getNode("/systems/hydraulic/green-resv-ovht", 1);
var askidsw = 0;
var brakemode = 0;
var accum = 0;
var L1BrakeTempc = props.globals.getNode("/gear/gear[1]/L1brake-temp-degc", 1);
var L2BrakeTempc = props.globals.getNode("/gear/gear[1]/L2brake-temp-degc", 1);
var R3BrakeTempc = props.globals.getNode("/gear/gear[2]/R3brake-temp-degc", 1);
var R4BrakeTempc = props.globals.getNode("/gear/gear[2]/R4brake-temp-degc", 1);

var switch_cart = props.globals.getNode("/controls/electrical/ground-cart", 1);
var fuel_flow1 = props.globals.getNode("/engines/engine[0]/fuel-flow_actual", 1);
var fuel_flow2 = props.globals.getNode("/engines/engine[1]/fuel-flow_actual", 1);
var cutoff_switch1 = props.globals.getNode("/controls/engines/engine[0]/cutoff-switch", 1);
var cutoff_switch2 = props.globals.getNode("/controls/engines/engine[1]/cutoff-switch", 1);
var autobreak_mode = props.globals.getNode("/controls/autobrake/mode", 1);
var gear1_pos = props.globals.getNode("/gear/gear[0]/position-norm", 1);
var gear2_pos = props.globals.getNode("/gear/gear[1]/position-norm", 1);
var gear3_pos = props.globals.getNode("/gear/gear[2]/position-norm", 1);
var gear_door_L = props.globals.getNode("/systems/hydraulic/gear/door-left", 1);
var gear_door_R = props.globals.getNode("/systems/hydraulic/gear/door-right", 1);
var gear_door_N = props.globals.getNode("/systems/hydraulic/gear/door-nose", 1);
var gear_down = props.globals.getNode("/controls/gear/gear-down", 1);
var press_vs_norm = props.globals.getNode("", 1);
var cabinalt = props.globals.getNode("", 1);
var gear0_wow = props.globals.getNode("/gear/gear[0]/wow", 1);

		
		# ESS TR
		essTrvolts = systems.ELEC.Source.trEss.outputVoltRelay.getValue();
		essTramps = systems.ELEC.Source.trEss.outputAmpRelay.getValue();
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
		if (systems.ELEC.Source.EmerGen.volts.getValue() == 0) {
			me["EMERGEN-group"].hide();
			me["ELEC-Line-Emergen-ESSTR"].hide();
			me["ELEC-Line-Emergen-ESSTR-off"].show();
			me["EMERGEN-Label-off"].show();
		} else {
			me["EMERGEN-group"].show();
			me["ELEC-Line-Emergen-ESSTR"].show();
			me["ELEC-Line-Emergen-ESSTR-off"].hide();
			me["EMERGEN-Label-off"].hide();
			
			me["EmergenVolt"].setText(sprintf("%s", math.round(systems.ELEC.Source.EmerGen.voltsRelay.getValue())));
			me["EmergenHz"].setText(sprintf("%s", math.round(systems.ELEC.Source.EmerGen.hertz.getValue())));
			
			if (systems.ELEC.Source.EmerGen.voltsRelay.getValue() > 120 or systems.ELEC.Source.EmerGen.voltsRelay.getValue() < 110 or systems.ELEC.Source.EmerGen.hertz.getValue() > 410 or systems.ELEC.Source.EmerGen.hertz.getValue() < 390) {
				me["Emergen-Label"].setColor(0.7333,0.3803,0);
			} else {
				me["Emergen-Label"].setColor(0.8078,0.8039,0.8078);
			}

			if (systems.ELEC.Source.EmerGen.voltsRelay.getValue() > 120 or systems.ELEC.Source.EmerGen.voltsRelay.getValue() < 110) {
				me["EmergenVolt"].setColor(0.7333,0.3803,0);
			} else {
				me["EmergenVolt"].setColor(0.0509,0.7529,0.2941);
			}

			if (systems.ELEC.Source.EmerGen.hertz.getValue() > 410 or systems.ELEC.Source.EmerGen.hertz.getValue() < 390) {
				me["EmergenHz"].setColor(0.7333,0.3803,0);
			} else {
				me["EmergenHz"].setColor(0.0509,0.7529,0.2941);
			}
		}
		
		
		
		# GEN1
		if (systems.ELEC.Switch.gen1.getValue() == 0) {
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
			me["Gen1Volt"].setText(sprintf("%s", math.round(systems.ELEC.Source.IDG1.volts.getValue())));

			if (systems.ELEC.Source.IDG1.hertz.getValue() == 0) {
				me["Gen1Hz"].setText(sprintf("XX"));
			} else {
				me["Gen1Hz"].setText(sprintf("%s", math.round(systems.ELEC.Source.IDG1.hertz.getValue())));
			}

			if (eng1_running.getValue() == 0) {
				me["GEN1-num-label"].setColor(0.7333,0.3803,0);
			} else {
				me["GEN1-num-label"].setColor(0.8078,0.8039,0.8078);
			}

			if (systems.ELEC.Source.IDG1.volts.getValue() > 120 or systems.ELEC.Source.IDG1.volts.getValue() < 110 or systems.ELEC.Source.IDG1.hertz.getValue() > 410 or systems.ELEC.Source.IDG1.hertz.getValue() < 390 or gen1_load.getValue() >= 110) {
				me["GEN1-label"].setColor(0.7333,0.3803,0);
			} else {
				me["GEN1-label"].setColor(0.8078,0.8039,0.8078);
			}

			if (gen1_load.getValue() >= 110) {
				me["Gen1Load"].setColor(0.7333,0.3803,0);
			} else {
				me["Gen1Load"].setColor(0.0509,0.7529,0.2941);
			}

			if (systems.ELEC.Source.IDG1.volts.getValue() > 120 or systems.ELEC.Source.IDG1.volts.getValue() < 110) {
				me["Gen1Volt"].setColor(0.7333,0.3803,0);
			} else {
				me["Gen1Volt"].setColor(0.0509,0.7529,0.2941);
			}

			if (systems.ELEC.Source.IDG1.hertz.getValue() > 410 or systems.ELEC.Source.IDG1.hertz.getValue() < 390) {
				me["Gen1Hz"].setColor(0.7333,0.3803,0);
			} else {
				me["Gen1Hz"].setColor(0.0509,0.7529,0.2941);
			}
		}

		# GEN2
		if (systems.ELEC.Switch.gen2.getValue() == 0) {
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
			me["Gen2Volt"].setText(sprintf("%s", math.round(systems.ELEC.Source.IDG2.volts.getValue())));
			if (systems.ELEC.Source.IDG2.hertz.getValue() == 0) {
				me["Gen2Hz"].setText(sprintf("XX"));
			} else {
				me["Gen2Hz"].setText(sprintf("%s", math.round(systems.ELEC.Source.IDG2.hertz.getValue())));
			}

			if (eng2_running.getValue() == 0) {
				me["GEN2-num-label"].setColor(0.7333,0.3803,0);
			} else {
				me["GEN2-num-label"].setColor(0.8078,0.8039,0.8078);
			}

			if (systems.ELEC.Source.IDG2.volts.getValue() > 120 or systems.ELEC.Source.IDG2.volts.getValue() < 110 or systems.ELEC.Source.IDG2.hertz.getValue() > 410 or systems.ELEC.Source.IDG2.hertz.getValue() < 390 or gen2_load.getValue() >= 110) {
				me["GEN2-label"].setColor(0.7333,0.3803,0);
			} else {
				me["GEN2-label"].setColor(0.8078,0.8039,0.8078);
			}

			if (gen2_load.getValue() >= 110) {
				me["Gen2Load"].setColor(0.7333,0.3803,0);
			} else {
				me["Gen2Load"].setColor(0.0509,0.7529,0.2941);
			}


			if (systems.ELEC.Source.IDG2.volts.getValue() > 120 or systems.ELEC.Source.IDG2.volts.getValue() < 110) {
				me["Gen2Volt"].setColor(0.7333,0.3803,0);
			} else {
				me["Gen2Volt"].setColor(0.0509,0.7529,0.2941);
			}

			if (systems.ELEC.Source.IDG2.hertz.getValue() > 410 or systems.ELEC.Source.IDG2.hertz.getValue() < 390) {
				me["Gen2Hz"].setColor(0.7333,0.3803,0);
			} else {
				me["Gen2Hz"].setColor(0.0509,0.7529,0.2941);
			}
		}



		# Managment of the connecting lines between the components
		if (systems.ELEC.Relay.apuGlc.getValue() and (systems.ELEC.Relay.acTie1.getValue() or systems.ELEC.Relay.acTie2.getValue())) {
			me["APU-out"].show();
		} else {
			me["APU-out"].hide();
		}

		if (systems.ELEC.Relay.extEpc.getValue() and (systems.ELEC.Relay.acTie1.getValue() or systems.ELEC.Relay.acTie2.getValue())) {
			me["EXT-out"].show();
		} else {
			me["EXT-out"].hide();
		}

		if (systems.ELEC.Source.IDG1.volts.getValue() >= 110 and systems.ELEC.Relay.glc1.getValue()) {
			me["ELEC-Line-GEN1-AC1"].show();
		} else {
			me["ELEC-Line-GEN1-AC1"].hide();
		}

		if (systems.ELEC.Source.IDG2.volts.getValue() >= 110 and systems.ELEC.Relay.glc2.getValue()) {
			me["ELEC-Line-GEN2-AC2"].show();
		} else {
			me["ELEC-Line-GEN2-AC2"].hide();
		}

		if (systems.ELEC.Relay.acTie1.getValue() and systems.ELEC.Relay.acTie2.getValue()) {
			me["ELEC-Line-APU-AC1"].show();
			me["ELEC-Line-APU-EXT"].show();
			me["ELEC-Line-EXT-AC2"].show();
		} else {
			if (systems.ELEC.Relay.acTie1.getValue()) {
				me["ELEC-Line-APU-AC1"].show();
			} else {
				me["ELEC-Line-APU-AC1"].hide();
			}
			
			if ((systems.ELEC.Relay.acTie2.getValue() and systems.ELEC.Relay.apuGlc.getValue() and !systems.ELEC.Relay.glc2.getValue()) or (systems.ELEC.Relay.acTie1.getValue() and systems.ELEC.Relay.extEpc.getValue() and !systems.ELEC.Relay.glc1.getValue())) {
				me["ELEC-Line-APU-EXT"].show();
			} else {
				me["ELEC-Line-APU-EXT"].hide();
			}
			
			if (systems.ELEC.Relay.acTie2.getValue()) {
				me["ELEC-Line-EXT-AC2"].show();
			} else {
				me["ELEC-Line-EXT-AC2"].hide();
			}
		}

		if (systems.ELEC.Relay.acEssFeed1.getValue()) {
			if (systems.ELEC.Bus.ac1.getValue() >= 110) {
				me["ELEC-Line-AC1-ACESS"].show();
			} else {
				me["ELEC-Line-AC1-ACESS"].hide();
			}
			me["ELEC-Line-AC2-ACESS"].hide();
		} elsif (systems.ELEC.Relay.acEssFeed2.getValue()) {
			me["ELEC-Line-AC1-ACESS"].hide();
			if (systems.ELEC.Bus.ac2.getValue() >= 110) {
				me["ELEC-Line-AC2-ACESS"].show();
			} else {
				me["ELEC-Line-AC2-ACESS"].hide();
			}
		} else {
			me["ELEC-Line-AC1-ACESS"].hide();
			me["ELEC-Line-AC2-ACESS"].hide();
		}

		if (systems.ELEC.Relay.tr1Contactor.getValue()) {
			if (systems.ELEC.Bus.ac1.getValue() < 110) {
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

		if (systems.ELEC.Relay.tr2Contactor.getValue()) {
			if (systems.ELEC.Bus.ac2.getValue() < 110) {
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
		
		if (systems.ELEC.Bus.acEss.getValue() >= 110 and !systems.ELEC.Relay.acEssEmerGenFeed.getValue() and (!systems.ELEC.Relay.tr1Contactor.getValue() or !systems.ELEC.Relay.tr2Contactor.getValue())) {
			me["ELEC-Line-ACESS-TRESS"].show();
		} else {
			me["ELEC-Line-ACESS-TRESS"].hide();
		}