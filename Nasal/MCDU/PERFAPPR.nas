# Copyright (c) 2020 Matthew Maring (mattmaring)

# APPR PERF
var ldg_config_3_set = props.globals.getNode("/FMGC/internal/ldg-config-3-set", 1);
var ldg_config_f_set = props.globals.getNode("/FMGC/internal/ldg-config-f-set", 1);

var perfAPPRInput = func(key, i) {
	var scratchpad = mcdu_scratchpad.scratchpads[i].scratchpad;
	if (key == "L1") {
		if (scratchpad == "CLR") {
			setprop("/FMGC/internal/dest-qnh-inhg", -1);
			setprop("/FMGC/internal/dest-qnh-hpa", -1);
			mcdu_scratchpad.scratchpads[i].empty();
		} else if (num(scratchpad) != nil) {
			# doesn't support accidental temp input yet
			if (scratchpad >= 28.06 and scratchpad <= 31.01) {
				setprop("/FMCG/internal/dest-qnh-is-hpa", 0);
				setprop("/FMGC/internal/dest-qnh-inhg", scratchpad);
				setprop("/FMGC/internal/dest-qnh-hpa", scratchpad * 33.863886666667);
				mcdu_scratchpad.scratchpads[i].empty();
			} elsif (scratchpad >= 745 and scratchpad <= 1050) {
				setprop("/FMCG/internal/dest-qnh-is-hpa", 1);
				setprop("/FMGC/internal/dest-qnh-inhg", scratchpad * 0.02952998307);
				setprop("/FMGC/internal/dest-qnh-hpa", scratchpad);
				mcdu_scratchpad.scratchpads[i].empty();
			} else {
			mcdu_message(i, "NOT ALLOWED");
				}
		} else {
			mcdu_message(i, "NOT ALLOWED");
		}
	} else if (key == "L2") {
		if (scratchpad == "CLR") {
			setprop("/FMGC/internal/dest-temp", -999);
			mcdu_scratchpad.scratchpads[i].empty();
		} else if (num(scratchpad) != nil and scratchpad >= -99 and scratchpad < 99) {
			setprop("/FMGC/internal/dest-temp", scratchpad);
			mcdu_scratchpad.scratchpads[i].empty();
		} else {
			mcdu_message(i, "NOT ALLOWED");
		}
	} else if (key == "L3") {
		var tfs = size(scratchpad);
		if (scratchpad == "CLR") {
			fmgc.FMGCInternal.destMag = 0;
			fmgc.FMGCInternal.destMagSet = 0;
			fmgc.FMGCInternal.destWind = 0;
			fmgc.FMGCInternal.destWindSet = 0;
			mcdu_scratchpad.scratchpads[i].empty();
		} else if (tfs >= 3 and tfs <= 7 and find("/", scratchpad) != -1) {
			var weather = split("/", scratchpad);
			var mags = size(weather[0]);
			var winds = size(weather[1]);
			if (mags >= 1 and mags <= 3 and winds >= 1 and winds <= 3) {
				if (num(weather[0]) != nil and num(weather[1]) != nil and int(weather[0]) >= 0 and int(weather[0]) <= 360 and int(weather[1]) >= 0 and int(weather[1]) <= 200) {
					fmgc.FMGCInternal.destMag = weather[0];
					fmgc.FMGCInternal.destMagSet = 1;
					fmgc.FMGCInternal.destWind = weather[1];
					fmgc.FMGCInternal.destWindSet = 1;
					mcdu_scratchpad.scratchpads[i].empty();
					fmgc.updateARPT();
				} else {
					mcdu_message(i, "NOT ALLOWED");
				}
			} else {
				mcdu_message(i, "NOT ALLOWED");
			}
		} else {
			mcdu_message(i, "NOT ALLOWED");
		}
	} else if (key == "L4") {
		if (scratchpad == "CLR") {
			fmgc.FMGCInternal.transAlt = 18000;
			fmgc.FMGCInternal.transAltSet = 0;
			mcdu_scratchpad.scratchpads[i].empty();
		} else {
			var tfs = size(scratchpad);
			if (int(scratchpad) != nil and (tfs == 4 or tfs == 5) and scratchpad >= 1000 and scratchpad <= 39000) {
				fmgc.FMGCInternal.transAlt = math.round(scratchpad, 500);
				fmgc.FMGCInternal.transAltSet = 1;
				mcdu_scratchpad.scratchpads[i].empty();
			} elsif (int(scratchpad) != nil and (tfs == 2 or tfs == 3) and scratchpad >= 10 and scratchpad <= 390) {
				fmgc.FMGCInternal.transAlt = math.round(scratchpad * 100, 5);
				fmgc.FMGCInternal.transAltSet = 1;
				mcdu_scratchpad.scratchpads[i].empty();
			} else {
				mcdu_message(i, "NOT ALLOWED");
			}
		}
	} else if (key == "L5") {
		if (scratchpad == "CLR") {
			setprop("/FMGC/internal/vapp-speed-set", 0);
			mcdu_scratchpad.scratchpads[i].empty();
		} else if (int(scratchpad) != nil and scratchpad >= 100 and scratchpad <= 350) {
			setprop("/FMGC/internal/vapp-speed-set", 1);
			setprop("/FMGC/internal/computed-speeds/vapp_appr", scratchpad);
			mcdu_scratchpad.scratchpads[i].empty();
		} else {
			mcdu_message(i, "NOT ALLOWED");
		}
	} else if (key == "L6") {
		setprop("/MCDU[" ~ i ~ "]/page", "PERFDES");
	} else if (key == "R2") {
		if (scratchpad == "CLR") {
			setprop("/FMGC/internal/baro", 99999);
			mcdu_scratchpad.scratchpads[i].empty();
		} else if (int(scratchpad) != nil and scratchpad >= fmgc.FMGCnodes.ldgElev.getValue() and scratchpad <= 5000 + fmgc.FMGCnodes.ldgElev.getValue()) {
			if (getprop("/FMGC/internal/radio-no") == 0) {
				setprop("/FMGC/internal/radio", 99999);
			}
			setprop("/FMGC/internal/baro", scratchpad);
			mcdu_scratchpad.scratchpads[i].empty();
		} else {
			mcdu_message(i, "NOT ALLOWED");
		}
	} else if (key == "R3") {
		if (scratchpad == "CLR") {
			setprop("/FMGC/internal/radio", 99999);
			setprop("/FMGC/internal/radio-no", 0);
			mcdu_scratchpad.scratchpads[i].empty();
		} else if (scratchpad == "NO") {
			setprop("/FMGC/internal/radio", 99999);
			setprop("/FMGC/internal/radio-no", 1);
			mcdu_scratchpad.scratchpads[i].empty();
		} else if (int(scratchpad) != nil and scratchpad >= 0 and scratchpad <= 700) {
			setprop("/FMGC/internal/baro", 99999);
			setprop("/FMGC/internal/radio-no", 0);
			setprop("/FMGC/internal/radio", scratchpad);
			mcdu_scratchpad.scratchpads[i].empty();
		} else {
			mcdu_message(i, "NOT ALLOWED");
		}
	} else if (key == "R4") {
		if (scratchpad == "" and ldg_config_f_set.getValue() == 1 and ldg_config_3_set.getValue() == 0) {
			setprop("/FMGC/internal/ldg-config-3-set", 1);
			setprop("/FMGC/internal/ldg-config-f-set", 0);
		} else {
			mcdu_message(i, "NOT ALLOWED");
		}
	} else if (key == "R5") {
		if (scratchpad == "" and ldg_config_3_set.getValue() == 1 and ldg_config_f_set.getValue() == 0) {
			setprop("/FMGC/internal/ldg-config-3-set", 0);
			setprop("/FMGC/internal/ldg-config-f-set", 1);
		} else {
			mcdu_message(i, "NOT ALLOWED");
		}
	} else if (key == "R6") {
		setprop("/MCDU[" ~ i ~ "]/page", "PERFGA");
	}

}