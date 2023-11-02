# Copyright (c) 2020 Matthew Maring (mattmaring)

# uses universal values, will implement separately once FPLN is finished

var perfGAInput = func(key, i) {
	var scratchpad = mcdu_scratchpad.scratchpads[i].scratchpad;
	if (key == "L5") {
		if (scratchpad == "CLR") {
			if (fmgc.FMGCInternal.arrApt != "") {
				fmgc.FMGCInternal.gaThrRedAlt = fmgc.pinOptionGaThrRedAlt + fmgc.FMGCInternal.destAptElev;
				fmgc.FMGCInternal.gaAccelAlt = fmgc.pinOptionGaAccelAlt + fmgc.FMGCInternal.destAptElev;
			} else {
				fmgc.FMGCInternal.gaThrRedAlt = fmgc.pinOptionGaThrRedAlt;
				fmgc.FMGCInternal.gaAccelAlt = fmgc.pinOptionGaAccelAlt;
			}

			setprop("/fdm/jsbsim/fadec/ga-clbreduc-ft", fmgc.FMGCInternal.gaThrRedAlt);
			setprop("/FMGC/internal/ga-accel-agl-ft", fmgc.FMGCInternal.gaAccelAlt);
			setprop("MCDUC/ga-acc-set-manual", 0);
			setprop("MCDUC/ga-thrRed-set-manual", 0);

			mcdu_scratchpad.scratchpads[i].empty();

		} else {
			var tfs = size(scratchpad);
			if (find("/", scratchpad) != -1) {
				var thracc = split("/", scratchpad);
				var thrred = size(thracc[0]);
				var acc = size(thracc[1]);
				if (thracc[0] > thracc[1]) {
					thracc[1] = thracc[0]; # accel is always greater or eqal thrust reduction
				}
				if (int(thrred) != nil and int(acc) != nil 
				and (thrred >= 3 and thrred <= 5) and (acc >= 3 and acc <= 5)
				and thracc[0] >= 400 and thracc[0] <= 39000 and thracc[1] >= 1500 and thracc[1] <= 39000) {
					setprop("/fdm/jsbsim/fadec/ga-clbreduc-ft", int(thracc[0] / 10) * 10);
					setprop("/FMGC/internal/ga-accel-agl-ft", int(thracc[1] / 10) * 10);
					setprop("MCDUC/ga-acc-set-manual", 1);
					setprop("MCDUC/ga-thrRed-set-manual", 1);
					mcdu_scratchpad.scratchpads[i].empty();
				} else if (int(thrred) == 0 and int(acc) != nil and (acc >= 3 and acc <= 5) and thracc[1] >= 1500 and thracc[1] <= 39000) {
					setprop("/FMGC/internal/ga-accel-agl-ft", int(thracc[1] / 10) * 10);
					setprop("MCDUC/ga-acc-set-manual", 1);
					mcdu_scratchpad.scratchpads[i].empty();
				} else if (int(thrred) != nil and int(acc) == nil and thracc[0] >= 400 and thracc[0] <= 39000 and (thrred >= 3 and thrred <= 5)) {
					setprop("/fdm/jsbsim/fadec/ga-clbreduc-ft", int(thracc[0] / 10) * 10);
					setprop("MCDUC/ga-thrRed-set-manual", 1);
					mcdu_scratchpad.scratchpads[i].empty();
				} else {
					mcdu_message(i, "NOT ALLOWED");
				}
			} else if ((num(scratchpad) != nil) and (tfs >= 3 and tfs <= 5) and (scratchpad >= 400) and (scratchpad <= 39000)) {
				if (scratchpad > getprop("/FMGC/internal/ga-accel-agl-ft")){
					setprop("/FMGC/internal/ga-accel-agl-ft", scratchpad); # set accel as high as thrRed
				} else {
					setprop("/fdm/jsbsim/fadec/ga-clbreduc-ft", int(scratchpad / 10) * 10);
				}
				setprop("MCDUC/ga-thrRed-set-manual", 1);
				mcdu_scratchpad.scratchpads[i].empty();
			} else {
				mcdu_message(i, "NOT ALLOWED");
			}
		}
	} else if (key == "L6") {
		setprop("MCDU[" ~ i ~ "]/page", "PERFAPPR");
	} else if (key == "R5") {
		if (scratchpad == "CLR") {
			setprop("/FMGC/internal/eng-out-reduc", "1500");
			setprop("MCDUC/reducacc-set", 0);
			mcdu_scratchpad.scratchpads[i].empty();
		} else {
			var tfs = size(scratchpad);
			if (int(scratchpad) != nil and tfs >= 3 and tfs <= 5) {
				setprop("/FMGC/internal/eng-out-reduc", scratchpad);
				setprop("MCDUC/reducacc-set", 1);
				mcdu_scratchpad.scratchpads[i].empty();
			} else {
				mcdu_message(i, "NOT ALLOWED");
			}
		}
	}
}