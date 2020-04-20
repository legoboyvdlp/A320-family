# Copyright (c) 2020 Matthew Maring (hayden2000)

# APPR PERF
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
	} else if (key == "R2") {
		if (scratchpad == "CLR") {
			setprop("FMGC/internal/baro", 99999);
			setprop("MCDU[" ~ i ~ "]/scratchpad-msg", 0);
			setprop("MCDU[" ~ i ~ "]/scratchpad", "");
		} else if (int(scratchpad) != nil and scratchpad >= getprop("FMGC/internal/ldg-elev") and scratchpad <= 5000 + getprop("FMGC/internal/ldg-elev")) {
			if (getprop("FMGC/internal/radio-no") == 0) {
				setprop("FMGC/internal/radio", 99999);
			}
			setprop("FMGC/internal/baro", scratchpad);
			setprop("MCDU[" ~ i ~ "]/scratchpad", "");
		} else {
			notAllowed(i);
		}
	} else if (key == "R3") {
		if (scratchpad == "CLR") {
			setprop("FMGC/internal/radio", 99999);
			setprop("FMGC/internal/radio-no", 0);
			setprop("MCDU[" ~ i ~ "]/scratchpad-msg", 0);
			setprop("MCDU[" ~ i ~ "]/scratchpad", "");
		} else if (scratchpad == "NO") {
			setprop("FMGC/internal/radio", 99999);
			setprop("FMGC/internal/radio-no", 1);
			setprop("MCDU[" ~ i ~ "]/scratchpad", "");
		} else if (int(scratchpad) != nil and scratchpad >= 0 and scratchpad <= 700) {
			setprop("FMGC/internal/baro", 99999);
			setprop("FMGC/internal/radio-no", 0);
			setprop("FMGC/internal/radio", scratchpad);
			setprop("MCDU[" ~ i ~ "]/scratchpad", "");
		} else {
			notAllowed(i);
		}
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