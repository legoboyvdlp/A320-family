# A3XX mCDU by Joshua Davidson (Octal450), Jonathan Redpath, and Matthew Maring (mattmaring)

# Copyright (c) 2020 Matthew Maring (mattmaring)

# From INIT-B
var fuelPredInput = func(key, i) {
	var scratchpad = mcdu_scratchpad.scratchpads[i].scratchpad;
	if (key == "L3" and getprop("/FMGC/internal/block-confirmed") and !getprop("/FMGC/internal/fuel-calculating")) {
		if (scratchpad == "CLR") {
			fmgc.FMGCInternal.rteRsv = 0.05 * fmgc.FMGCInternal.tripFuel;
			fmgc.FMGCInternal.rteRsvSet = 0;
			fmgc.FMGCInternal.rtePercent = 5.0;
			fmgc.FMGCInternal.rtePercentSet = 0;
			setprop("/FMGC/internal/fuel-calculating", 1);
			mcdu_scratchpad.scratchpads[i].empty();
		} else if (fmgc.FMGCInternal.tripFuel != 0) {
			var tf = num(scratchpad);
			var tfs = size(scratchpad);
			if (tfs >= 2 and tfs <= 5 and find("/", scratchpad) == 0) {
				var perc = num(split("/", scratchpad)[1]);
				if (perc != nil and perc >= 0.0 and perc <= 15.0) {
					fmgc.FMGCInternal.rteRsv = perc / 100 * fmgc.FMGCInternal.tripFuel;
					fmgc.FMGCInternal.rteRsvSet = 0;
					fmgc.FMGCInternal.rtePercent = perc;
					fmgc.FMGCInternal.rtePercentSet = 1;
					setprop("/FMGC/internal/fuel-calculating", 1);
					mcdu_scratchpad.scratchpads[i].empty();
				}
			} else if (tfs >= 1 and tfs <= 4 and tf != nil and tf >= 0 and tf <= 21.7) {
					fmgc.FMGCInternal.rteRsv = scratchpad;
					fmgc.FMGCInternal.rteRsvSet = 1;
					if (scratchpad / fmgc.FMGCInternal.tripFuel * 100 <= 15.0) {
						fmgc.FMGCInternal.rtePercent = scratchpad / fmgc.FMGCInternal.tripFuel * 100;
					} else {
						fmgc.FMGCInternal.rtePercent = 15.0; # need reasearch on this value
					}
					fmgc.FMGCInternal.rtePercentSet = 0;
					setprop("/FMGC/internal/fuel-calculating", 1);
					mcdu_scratchpad.scratchpads[i].empty();
			} else {
				mcdu_message(i, "NOT ALLOWED");
			}
		} else {
			mcdu_message(i, "NOT ALLOWED");
		}
	} else if (key == "L4" and getprop("/FMGC/internal/block-confirmed") and !getprop("/FMGC/internal/fuel-calculating") and fmgc.FMGCInternal.altAirportSet) {
		if (scratchpad == "CLR") {
			fmgc.FMGCInternal.altFuel = 0.0;
			fmgc.FMGCInternal.altTime = "0000";
			fmgc.FMGCInternal.altFuelSet = 0;
			setprop("/FMGC/internal/fuel-calculating", 1);
			mcdu_scratchpad.scratchpads[i].empty();
		} else if (find(".", scratchpad) != -1) {
			var tf = num(scratchpad);
			var tfs = size(scratchpad);
			if (tfs >= 3 and tfs <= 4 and tf != nil and tf >= 0 and tf <= 10.0) {
				fmgc.FMGCInternal.altFuel = tf;
				fmgc.FMGCInternal.altTime = "0000";
				fmgc.FMGCInternal.altFuelSet = 1;
				setprop("/FMGC/internal/fuel-calculating", 1);
				mcdu_scratchpad.scratchpads[i].empty();
			} else {
				mcdu_message(i, "NOT ALLOWED");
			}
		} else {
			mcdu_message(i, "NOT ALLOWED");
		}
	} else if (key == "L5" and getprop("/FMGC/internal/block-confirmed") and !getprop("/FMGC/internal/fuel-calculating")) {
		if (scratchpad == "CLR") {
			fmgc.FMGCInternal.finalFuel = 0.0;
			fmgc.FMGCInternal.finalTime = "0030";
			fmgc.FMGCInternal.finalFuelSet = 0;
			fmgc.FMGCInternal.finalTimeSet = 0;
			setprop("/FMGC/internal/fuel-calculating", 1);
			mcdu_scratchpad.scratchpads[i].empty();
		} else if (find(".", scratchpad) != -1) {
			var tf = num(scratchpad);
			var tfs = size(scratchpad);
			if (tfs >= 3 and tfs <= 4 and tf != nil and tf >= 0 and tf <= 10.0) {
				fmgc.FMGCInternal.finalFuel = tf;
				fmgc.FMGCInternal.finalFuelSet = 1;
				setprop("/FMGC/internal/fuel-calculating", 1);
				mcdu_scratchpad.scratchpads[i].empty();
			} else {
				mcdu_message(i, "NOT ALLOWED");
			}
		} else {
			var tf = num(scratchpad);
			var tfs = size(scratchpad);
			if (tfs == 4 and tf != nil and ((tf >= 0 and tf <= 59) or (tf >= 100 and tf <= 130))) {
				fmgc.FMGCInternal.finalTime = scratchpad;
				fmgc.FMGCInternal.finalTimeSet = 1;
				setprop("/FMGC/internal/fuel-calculating", 1);
				mcdu_scratchpad.scratchpads[i].empty();
			} else {
				mcdu_message(i, "NOT ALLOWED");
			} 
		}
	} else if (key == "L6" and getprop("/FMGC/internal/block-confirmed") and !getprop("/FMGC/internal/fuel-calculating")) {
		if (scratchpad == "CLR") {
			fmgc.FMGCInternal.minDestFob = 0;
			fmgc.FMGCInternal.minDestFobSet = 0;
			setprop("/FMGC/internal/fuel-calculating", 1);
			mcdu_scratchpad.scratchpads[i].empty();
		} else if (find(".", scratchpad) != -1) {
			var tf = num(scratchpad);
			var tfs = size(scratchpad);
			if (tfs >= 3 and tfs <= 5 and tf != nil and tf >= 0 and tf <= 80.0) {
				fmgc.FMGCInternal.minDestFob = tf;
				fmgc.FMGCInternal.minDestFobSet = 1;
				setprop("/FMGC/internal/fuel-calculating", 1);
				mcdu_scratchpad.scratchpads[i].empty();
				if (fmgc.FMGCInternal.minDestFob < fmgc.FMGCInternal.finalFuel + fmgc.FMGCInternal.altFuel) {
					mcdu_message(i, "CHECK MIN DEST FOB");
				}
			} else {
				mcdu_message(i, "NOT ALLOWED");
			}
		} else {
			mcdu_message(i, "NOT ALLOWED");
		}
	} else if (key == "R3" and !getprop("/FMGC/internal/fuel-calculating")) {
		if (scratchpad == "CLR") {
			mcdu_message(i, "NOT ALLOWED");
		} else {
			var zfw_min = 80.6; #make based on performance
			var zfw_max = 134.5; #61,000 kg, make based on performance
			if (size(scratchpad) == 0) {
				var zfw = getprop("/fdm/jsbsim/inertia/weight-lbs") - getprop("/consumables/fuel/total-fuel-lbs");
				fmgc.FMGCInternal.zfw = sprintf("%3.1f", math.round(zfw / 1000, 0.1));
				fmgc.FMGCInternal.zfwSet = 1;
				if (fmgc.FMGCInternal.blockSet != 1) {
					fmgc.FMGCInternal.block = getprop("consumables/fuel/total-fuel-lbs") / 1000;
					fmgc.FMGCInternal.blockSet = 1;
					fmgc.FMGCInternal.tow = fmgc.FMGCInternal.zfw + fmgc.FMGCInternal.block - fmgc.FMGCInternal.taxiFuel;
					setprop("/FMGC/internal/fuel-request-set", 1);
					setprop("/FMGC/internal/fuel-calculating", 1);
					setprop("/FMGC/internal/block-calculating", 0);
					setprop("/FMGC/internal/block-confirmed", 1);
				} else if (getprop("/FMGC/internal/block-confirmed")) {
					setprop("/FMGC/internal/fuel-calculating", 1);
				} 
				mcdu_scratchpad.scratchpads[i].empty();
			} else if (find("/", scratchpad) != -1) {
				var zfwi = split("/", scratchpad);
				var zfw = num(zfwi[0]);
				var zfwcg = num(zfwi[1]);
				var zfws = size(zfwi[0]);
				var zfwcgs = size(zfwi[1]);
				if (zfw != nil and zfws > 0 and zfws <= 5 and (find(".", zfwi[0]) == -1 or size(split(".", zfwi[0])[1]) <= 1) and zfwcg != nil and zfwcgs > 0 and zfwcgs <= 4 and (find(".", zfwi[1]) == -1 or size(split(".", zfwi[1])[1]) <= 1)) {
					if (zfw >= zfw_min and zfw <= zfw_max and zfwcg >= 8.0 and zfwcg <= 45.0) {
						fmgc.FMGCInternal.zfw = zfw;
						fmgc.FMGCInternal.zfwSet = 1;
						fmgc.FMGCInternal.zfwcg = zfwcg;
						fmgc.FMGCInternal.zfwcgSet = 1;
						if (fmgc.FMGCInternal.blockSet != 1) {
							fmgc.FMGCInternal.block = getprop("consumables/fuel/total-fuel-lbs") / 1000;
							fmgc.FMGCInternal.blockSet = 1;
							fmgc.FMGCInternal.tow = fmgc.FMGCInternal.zfw + fmgc.FMGCInternal.block - fmgc.FMGCInternal.taxiFuel;
							setprop("/FMGC/internal/fuel-request-set", 1);
							setprop("/FMGC/internal/fuel-calculating", 1);
							setprop("/FMGC/internal/block-calculating", 0);
							setprop("/FMGC/internal/block-confirmed", 1);
						} else if (getprop("/FMGC/internal/block-confirmed")) {
							setprop("/FMGC/internal/fuel-calculating", 1);
						} 
						mcdu_scratchpad.scratchpads[i].empty();
					} else {
						mcdu_message(i, "ENTRY OUT OF RANGE");
					}
				} else if (zfws == 0 and zfwcg != nil and zfwcgs > 0 and zfwcgs <= 4 and (find(".", zfwi[1]) == -1 or size(split(".", zfwi[1])[1]) <= 1)) {
					if (zfwcg >= 8.0 and zfwcg <= 45.0) {
						fmgc.FMGCInternal.zfwcg = zfwcg;
						fmgc.FMGCInternal.zfwcgSet = 1;
						mcdu_scratchpad.scratchpads[i].empty();
					} else {
						mcdu_message(i, "ENTRY OUT OF RANGE");
					}
				} else {
					mcdu_message(i, "NOT ALLOWED");
				}
			} else if (num(scratchpad) != nil and size(scratchpad) > 0 and size(scratchpad) <= 5 and (find(".", scratchpad) == -1 or size(split(".", scratchpad)[1]) <= 1)) {
				if (scratchpad >= zfw_min and scratchpad <= zfw_max) {
					fmgc.FMGCInternal.zfw = scratchpad;
					fmgc.FMGCInternal.zfwSet = 1;
					if (fmgc.FMGCInternal.blockSet != 1) {
						fmgc.FMGCInternal.block = getprop("consumables/fuel/total-fuel-lbs") / 1000;
						fmgc.FMGCInternal.blockSet = 1;
						fmgc.FMGCInternal.tow = fmgc.FMGCInternal.zfw + fmgc.FMGCInternal.block - fmgc.FMGCInternal.taxiFuel;
						setprop("/FMGC/internal/fuel-request-set", 1);
						setprop("/FMGC/internal/fuel-calculating", 1);
						setprop("/FMGC/internal/block-calculating", 0);
						setprop("/FMGC/internal/block-confirmed", 1);
					} else if (getprop("/FMGC/internal/block-confirmed")) {
						setprop("/FMGC/internal/fuel-calculating", 1);
					}
					mcdu_scratchpad.scratchpads[i].empty();
				} else {
					mcdu_message(i, "ENTRY OUT OF RANGE");
				}
			} else {
				mcdu_message(i, "NOT ALLOWED");
			}
			
			if (!fmgc.FMGCInternal.costIndexSet and fmgc.FMGCInternal.toFromSet) {
				mcdu_message(i, "USING COST INDEX N", getprop("/FMGC/internal/last-cost-index") or 0);
				fmgc.FMGCInternal.costIndexSet = 1;
				fmgc.FMGCInternal.costIndex = getprop("/FMGC/internal/last-cost-index") or 0;
				fmgc.FMGCNodes.costIndex.setValue(fmgc.FMGCInternal.costIndex);
			}
		}
	} else if (key == "R4") {
		if (scratchpad == "CLR") {
			fmgc.FMGCInternal.fffqSensor = "FF+FQ";
			mcdu_scratchpad.scratchpads[i].empty();
		} else if (find("/", scratchpad) == 0) {
			var sensor = substr(scratchpad, 1);
			if (sensor == "FF+FQ" or sensor == "FQ+FF" or sensor == "FF" or sensor == "FQ") {
				fmgc.FMGCInternal.fffqSensor = sensor;
				mcdu_scratchpad.scratchpads[i].empty();
			} else {
				mcdu_message(i, "NOT ALLOWED");
			}
		} else {
			mcdu_message(i, "NOT ALLOWED");
		}
	} else {
		mcdu_message(i, "NOT ALLOWED");
	}
}
