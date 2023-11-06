# Copyright (c) 2020 Matthew Maring (mattmaring)

# and flinkekoralle 2023

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
				var tempThrRed = 0;
				var tempAcc = 0;
				if (thrred >= 3 and thrred <= 5) {tempThrRed = int(thracc[0]/ 10) * 10;}
				if (acc >= 3 and acc <= 5) {tempAcc = int(thracc[1]/ 10) * 10;}

				if (thrred and acc and tempAcc < tempThrRed) {
					tempAcc = tempThrRed; # accel is always greater or eqal thrust reduction
				}

				# at the moment 400ft/1500ft and 39000ft are hard coded defaults.
				# needs to be checked
				if (tempThrRed >= 400 and tempThrRed <= 39000 and tempAcc >= 1500 and tempAcc <= 39000) {
					setprop("/fdm/jsbsim/fadec/ga-clbreduc-ft", tempThrRed);
					setprop("/FMGC/internal/ga-accel-agl-ft", tempAcc);
					setprop("MCDUC/ga-acc-set-manual", 1);
					setprop("MCDUC/ga-thrRed-set-manual", 1);
					mcdu_scratchpad.scratchpads[i].empty();
				} else if (tempAcc >= 1500 and tempAcc <= 39000) {
					setprop("/FMGC/internal/ga-accel-agl-ft", tempAcc);
					setprop("MCDUC/ga-acc-set-manual", 1);
					mcdu_scratchpad.scratchpads[i].empty();
				} else if (tempThrRed >= 400 and tempThrRed <= 39000) {
					setprop("/fdm/jsbsim/fadec/ga-clbreduc-ft", tempThrRed);
					setprop("MCDUC/ga-thrRed-set-manual", 1);
					mcdu_scratchpad.scratchpads[i].empty();
				} else {
					mcdu_message(i, "NOT ALLOWED");
				}
			} else {
				if (tfs >= 3 and tfs <= 5){
					var tempImp = int(scratchpad / 10) * 10;
					if (tempImp and (tempImp >= 400) and (tempImp <= 39000)) {
						setprop("/fdm/jsbsim/fadec/ga-clbreduc-ft", tempImp);
						setprop("MCDUC/ga-thrRed-set-manual", 1);

						if (tempImp > getprop("/FMGC/internal/ga-accel-agl-ft")){ # set accel as high as thrRed
							setprop("/FMGC/internal/ga-accel-agl-ft", tempImp);
							setprop("MCDUC/ga-acc-set-manual", 1);
						}
						mcdu_scratchpad.scratchpads[i].empty();
					} else {
						mcdu_message(i, "NOT ALLOWED");
					}
				} else {
					mcdu_message(i, "NOT ALLOWED");
				}
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