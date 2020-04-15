# Copyright (c) 2020 Matthew Maring (hayden2000)

# APPR PERF
var dest_qnh = props.globals.getNode("FMGC/internal/dest-qnh", 1);
var dest_temp = props.globals.getNode("FMGC/internal/dest-temp", 1);
var dest_mag = props.globals.getNode("FMGC/internal/dest-mag", 1);
var dest_wind = props.globals.getNode("FMGC/internal/dest-wind", 1);
var transAlt = props.globals.getNode("FMGC/internal/trans-alt", 1);
var final = props.globals.getNode("FMGC/internal/final", 1);
var mda = props.globals.getNode("FMGC/internal/mda", 1);
var dh = props.globals.getNode("FMGC/internal/dh", 1);
var ldg_config_3_set = props.globals.getNode("FMGC/internal/ldg-config-3-set", 1);
var ldg_config_f_set = props.globals.getNode("FMGC/internal/ldg-config-f-set", 1);

var perfAPPRInput = func(key, i) {
	var scratchpad = getprop("MCDU[" ~ i ~ "]/scratchpad");
	if (key == "L1") {
		if (scratchpad == "CLR") {
			setprop("FMGC/internal/dest-qnh", -1);
			setprop("MCDU[" ~ i ~ "]/scratchpad-msg", 0);
			setprop("MCDU[" ~ i ~ "]/scratchpad", "");
		} else if (num(scratchpad) != nil and (scratchpad >= 28.06 and scratchpad <= 31.01) or (scratchpad >= 745 and scratchpad <= 1050)) {
			# doesn't support accidental temp input yet
			setprop("FMGC/internal/dest-qnh", scratchpad);
			setprop("MCDU[" ~ i ~ "]/scratchpad", "");
		} else {
			notAllowed(i);
		}
	} else if (key == "L2") {
		if (scratchpad == "CLR") {
			setprop("FMGC/internal/dest-temp", -999);
			setprop("MCDU[" ~ i ~ "]/scratchpad-msg", 0);
			setprop("MCDU[" ~ i ~ "]/scratchpad", "");
		} else if (num(scratchpad) != nil and scratchpad >= -99 and scratchpad < 99) {
			setprop("FMGC/internal/dest-temp", scratchpad);
			setprop("MCDU[" ~ i ~ "]/scratchpad", "");
		} else {
			notAllowed(i);
		}
	} else if (key == "L3") {
		var tfs = size(scratchpad);
		if (scratchpad == "CLR") {
			setprop("FMGC/internal/dest-mag", -1);
			setprop("FMGC/internal/dest-wind", -1);
			setprop("MCDU[" ~ i ~ "]/scratchpad-msg", 0);
			setprop("MCDU[" ~ i ~ "]/scratchpad", "");
		} else if (tfs >= 3 and tfs <= 7 and find("/", scratchpad) != -1) {
			var weather = split("/", scratchpad);
			var mag = int(weather[0]);
			var mags = size(weather[0]);
			var wind = int(weather[1]);
			var winds = size(weather[1]);
			if (mags >= 1 and mags <= 3 and winds >= 1 and winds <= 3) {
				if (mag != nil and wind != nil and mag >= 0 and mag <= 360 and wind >= 0 and wind <= 200) {
					setprop("FMGC/internal/dest-mag", weather[0]);
					setprop("FMGC/internal/dest-wind", weather[1]);
					setprop("MCDU[" ~ i ~ "]/scratchpad", "");
					fmgc.updateARPT();
				} else {
					notAllowed(i);
				}
			} else {
				notAllowed(i);
			}
		} else {
			notAllowed(i);
		}
	} else if (key == "L4") {
		if (scratchpad == "CLR") {
			setprop("FMGC/internal/trans-alt", 18000);
			setprop("MCDU[" ~ i ~ "]/scratchpad-msg", 0);
			setprop("MCDU[" ~ i ~ "]/scratchpad", "");
		} else if (int(scratchpad) != nil and scratchpad >= 0 and scratchpad <= 50000) {
			setprop("FMGC/internal/trans-alt", scratchpad);
			setprop("MCDU[" ~ i ~ "]/scratchpad", "");
		} else {
			notAllowed(i);
		}
	} else if (key == "L5") {
		if (scratchpad == "CLR") {
			setprop("FMGC/internal/vapp-speed-set", 0);
			setprop("MCDU[" ~ i ~ "]/scratchpad-msg", 0);
			setprop("MCDU[" ~ i ~ "]/scratchpad", "");
		} else if (int(scratchpad) != nil and scratchpad >= 0 and scratchpad <= 200) {
			setprop("FMGC/internal/vapp-speed-set", 1);
			setprop("FMGC/internal/computed-speeds/vapp_appr", scratchpad);
			setprop("MCDU[" ~ i ~ "]/scratchpad", "");
		} else {
			notAllowed(i);
		}
	} else if (key == "L6") {
		setprop("MCDU[" ~ i ~ "]/page", "PERFDES");
	} else if (key == "R4") {
		if (scratchpad == "" and ldg_config_f_set.getValue() == 1 and ldg_config_3_set.getValue() == 0) {
			setprop("FMGC/internal/ldg-config-3-set", 1);
			setprop("FMGC/internal/ldg-config-f-set", 0);
		} else {
			notAllowed(i);
		}
	} else if (key == "R5") {
		if (scratchpad == "" and ldg_config_3_set.getValue() == 1 and ldg_config_f_set.getValue() == 0) {
			setprop("FMGC/internal/ldg-config-3-set", 0);
			setprop("FMGC/internal/ldg-config-f-set", 1);
		} else {
			notAllowed(i);
		}
	} else if (key == "R6") {
		setprop("MCDU[" ~ i ~ "]/page", "PERFGA");
	}

}