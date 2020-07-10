# A3XX mCDU by Joshua Davidson (Octal450), Jonathan Redpath, and Matthew Maring (mattmaring)

# Copyright (c) 2020 Matthew Maring (mattmaring)

# From INIT-B
var zfwcg = props.globals.getNode("FMGC/internal/zfwcg", 1);
var zfwcgSet = props.globals.getNode("FMGC/internal/zfwcg-set", 1);
var zfw = props.globals.getNode("FMGC/internal/zfw", 1);
var zfwSet = props.globals.getNode("FMGC/internal/zfw-set", 1);
var block = props.globals.getNode("FMGC/internal/block", 1);
var blockSet = props.globals.getNode("FMGC/internal/block-set", 1);
var taxi_fuel = props.globals.getNode("FMGC/internal/taxi-fuel", 1);
var trip_fuel = props.globals.getNode("FMGC/internal/trip-fuel", 1);
var trip_time = props.globals.getNode("FMGC/internal/trip-time", 1);
var rte_rsv = props.globals.getNode("FMGC/internal/rte-rsv", 1);
var rte_percent = props.globals.getNode("FMGC/internal/rte-percent", 1);
var alt_fuel = props.globals.getNode("FMGC/internal/alt-fuel", 1);
var alt_time = props.globals.getNode("FMGC/internal/alt-time", 1);
var final_fuel = props.globals.getNode("FMGC/internal/final-fuel", 1);
var final_time = props.globals.getNode("FMGC/internal/final-time", 1);
var min_dest_fob = props.globals.getNode("FMGC/internal/min-dest-fob", 1);
var tow = props.globals.getNode("FMGC/internal/tow", 1);
var lw = props.globals.getNode("FMGC/internal/lw", 1);
var trip_wind = props.globals.getNode("FMGC/internal/trip-wind", 1);
var trip_wind_value = props.globals.getNode("FMGC/internal/trip-wind", 1);
var fob = props.globals.getNode("FMGC/internal/fob", 1);
var fffq_sensor = props.globals.getNode("FMGC/internal/fffq-sensor", 1);
var extra_fuel = props.globals.getNode("FMGC/internal/extra-fuel", 1);
var extra_time = props.globals.getNode("FMGC/internal/extra-time", 1);

var fuelPredInput = func(key, i) {
	var scratchpad = mcdu_scratchpad.scratchpads[i].scratchpad;
	if (key == "L3" and getprop("/FMGC/internal/block-confirmed") and !getprop("/FMGC/internal/fuel-calculating")) {
		if (scratchpad == "CLR") {
			setprop("/FMGC/internal/rte-rsv", 0.05 * num(getprop("/FMGC/internal/trip-fuel")));
			setprop("/FMGC/internal/rte-rsv-set", 0);
			setprop("/FMGC/internal/rte-percent", 5.0);
			setprop("/FMGC/internal/rte-percent-set", 0);
			setprop("/FMGC/internal/fuel-calculating", 1);
			mcdu_scratchpad.scratchpads[i].empty();
		} else if (getprop("/FMGC/internal/trip-fuel") != 0) {
			var tf = num(scratchpad);
			var tfs = size(scratchpad);
			if (tfs >= 2 and tfs <= 5 and find("/", scratchpad) == 0) {
				var perc = num(split("/", scratchpad)[1]);
				if (perc != nil and perc >= 0.0 and perc <= 15.0) {
					setprop("/FMGC/internal/rte-rsv", num(perc) / 100 * num(getprop("/FMGC/internal/trip-fuel")));
					setprop("/FMGC/internal/rte-rsv-set", 0);
					setprop("/FMGC/internal/rte-percent", perc);
					setprop("/FMGC/internal/rte-percent-set", 1);
					setprop("/FMGC/internal/fuel-calculating", 1);
					mcdu_scratchpad.scratchpads[i].empty();
				}
			} else if (tfs >= 1 and tfs <= 4 and tf != nil and tf >= 0 and tf <= 21.7) {
					setprop("/FMGC/internal/rte-rsv", scratchpad);
					setprop("/FMGC/internal/rte-rsv-set", 1);
					if (scratchpad / num(getprop("/FMGC/internal/trip-fuel")) * 100 <= 15.0) {
						setprop("/FMGC/internal/rte-percent", scratchpad / num(getprop("/FMGC/internal/trip-fuel")) * 100);
					} else {
						setprop("/FMGC/internal/rte-percent", 15.0); # need reasearch on this value
					}
					setprop("/FMGC/internal/rte-percent-set", 0);
					setprop("/FMGC/internal/fuel-calculating", 1);
					mcdu_scratchpad.scratchpads[i].empty();
			} else {
				mcdu_message(i, "NOT ALLOWED");
			}
		} else {
			mcdu_message(i, "NOT ALLOWED");
		}
	} else if (key == "L4" and getprop("/FMGC/internal/block-confirmed") and !getprop("/FMGC/internal/fuel-calculating") and getprop("/FMGC/internal/alt-set")) {
		if (scratchpad == "CLR") {
			setprop("/FMGC/internal/alt-fuel", 0.0);
			setprop("/FMGC/internal/alt-time", "0000");
			setprop("/FMGC/internal/alt-fuel-set", 0);
			setprop("/FMGC/internal/fuel-calculating", 1);
			mcdu_scratchpad.scratchpads[i].empty();
		} else if (find(".", scratchpad) != -1) {
			var tf = num(scratchpad);
			var tfs = size(scratchpad);
			if (tfs >= 3 and tfs <= 4 and tf != nil and tf >= 0 and tf <= 10.0) {
				setprop("/FMGC/internal/alt-fuel", tf);
				setprop("/FMGC/internal/alt-time", "0000");
				setprop("/FMGC/internal/alt-fuel-set", 1);
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
			setprop("/FMGC/internal/final-fuel", 0.0);
			setprop("/FMGC/internal/final-time", "0030");
			setprop("/FMGC/internal/final-fuel-set", 0);
			setprop("/FMGC/internal/final-time-set", 0);
			setprop("/FMGC/internal/fuel-calculating", 1);
			mcdu_scratchpad.scratchpads[i].empty();
		} else if (find(".", scratchpad) != -1) {
			var tf = num(scratchpad);
			var tfs = size(scratchpad);
			if (tfs >= 3 and tfs <= 4 and tf != nil and tf >= 0 and tf <= 10.0) {
				setprop("/FMGC/internal/final-fuel", tf);
				setprop("/FMGC/internal/final-fuel-set", 1);
				setprop("/FMGC/internal/fuel-calculating", 1);
				mcdu_scratchpad.scratchpads[i].empty();
			} else {
				mcdu_message(i, "NOT ALLOWED");
			}
		} else {
			var tf = num(scratchpad);
			var tfs = size(scratchpad);
			if (tfs == 4 and tf != nil and ((tf >= 0 and tf <= 59) or (tf >= 100 and tf <= 130))) {
				setprop("/FMGC/internal/final-time", scratchpad);
				setprop("/FMGC/internal/final-time-set", 1);
				setprop("/FMGC/internal/fuel-calculating", 1);
				mcdu_scratchpad.scratchpads[i].empty();
			} else {
				mcdu_message(i, "NOT ALLOWED");
			} 
		}
	} else if (key == "L6" and getprop("/FMGC/internal/block-confirmed") and !getprop("/FMGC/internal/fuel-calculating")) {
		if (scratchpad == "CLR") {
			setprop("/FMGC/internal/min-dest-fob", 0);
			setprop("/FMGC/internal/min-dest-fob-set", 0);
			setprop("/FMGC/internal/fuel-calculating", 1);
			mcdu_scratchpad.scratchpads[i].empty();
		} else if (find(".", scratchpad) != -1) {
			var tf = num(scratchpad);
			var tfs = size(scratchpad);
			if (tfs >= 3 and tfs <= 5 and tf != nil and tf >= 0 and tf <= 80.0) {
				setprop("/FMGC/internal/min-dest-fob", tf);
				setprop("/FMGC/internal/min-dest-fob-set", 1);
				setprop("/FMGC/internal/fuel-calculating", 1);
				mcdu_scratchpad.scratchpads[i].empty();
				if (num(getprop("/FMGC/internal/min-dest-fob")) < num(getprop("/FMGC/internal/final-fuel") + getprop("/FMGC/internal/alt-fuel"))) {
					genericMessage(i, "CHECK MIN DEST FOB", "wht");
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
				setprop("/FMGC/internal/zfw", sprintf("%3.1f", math.round(zfw / 1000, 0.1)));
				setprop("/FMGC/internal/zfw-set", 1);
				if (getprop("/FMGC/internal/block-set") != 1) {
					setprop("/FMGC/internal/block", num(getprop("consumables/fuel/total-fuel-lbs") / 1000));
					setprop("/FMGC/internal/block-set", 1);
					setprop("/FMGC/internal/fuel-request-set", 1);
					setprop("/FMGC/internal/fuel-calculating", 1);
					setprop("/FMGC/internal/block-calculating", 0);
					setprop("/FMGC/internal/block-confirmed", 1);
				}
				mcdu_scratchpad.scratchpads[i].empty();
			} else if (find("/", scratchpad) != -1) {
				var zfwi = split("/", scratchpad);
				var zfw = num(zfwi[0]);
				var zfwcg = num(zfwi[1]);
				var zfws = size(zfwi[0]);
				var zfwcgs = size(zfwi[1]);
				if (zfw != nil and zfws > 0 and zfws <= 5 and size(split(".", zfwi[0])[1]) <= 1 and zfwcg != nil and zfwcgs > 0 and zfwcgs <= 4 and size(split(".", zfwi[1])[1]) <= 1) {
					if (zfw >= zfw_min and zfw <= zfw_max and zfwcg >= 8.0 and zfwcg <= 45.0) {
						setprop("/FMGC/internal/zfw", zfw);
						setprop("/FMGC/internal/zfw-set", 1);
						setprop("/FMGC/internal/zfwcg", zfwcg);
						setprop("/FMGC/internal/zfwcg-set", 1);
						if (getprop("/FMGC/internal/block-set") != 1) {
							setprop("/FMGC/internal/block", num(getprop("consumables/fuel/total-fuel-lbs") / 1000));
							setprop("/FMGC/internal/block-set", 1);
							setprop("/FMGC/internal/fuel-request-set", 1);
							setprop("/FMGC/internal/fuel-calculating", 1);
							setprop("/FMGC/internal/block-calculating", 0);
							setprop("/FMGC/internal/block-confirmed", 1);
						}
						mcdu_scratchpad.scratchpads[i].empty();
					} else {
						mcdu_message(i, "ENTRY OUT OF RANGE");
					}
				} else if (zfws == 0 and zfwcg != nil and zfwcgs > 0 and zfwcgs <= 4 and size(split(".", zfwi[1])[1]) <= 1) {
					if (zfwcg >= 8.0 and zfwcg <= 45.0) {
						setprop("/FMGC/internal/zfwcg", zfwcg);
						setprop("/FMGC/internal/zfwcg-set", 1);
						mcdu_scratchpad.scratchpads[i].empty();
					} else {
						mcdu_message(i, "ENTRY OUT OF RANGE");
					}
				} else {
					mcdu_message(i, "NOT ALLOWED");
				}
			} else if (num(scratchpad) != nil and size(scratchpad) > 0 and size(scratchpad) <= 5 and size(split(".", scratchpad)[1]) <= 1) {
				if (scratchpad >= zfw_min and scratchpad <= zfw_max) {
					setprop("/FMGC/internal/zfw", scratchpad);
					setprop("/FMGC/internal/zfw-set", 1);
					if (getprop("/FMGC/internal/block-set") != 1) {
						setprop("/FMGC/internal/block", num(getprop("consumables/fuel/total-fuel-lbs") / 1000));
						setprop("/FMGC/internal/block-set", 1);
						setprop("/FMGC/internal/fuel-request-set", 1);
						setprop("/FMGC/internal/fuel-calculating", 1);
						setprop("/FMGC/internal/block-calculating", 0);
						setprop("/FMGC/internal/block-confirmed", 1);
					}
					mcdu_scratchpad.scratchpads[i].empty();
				} else {
					mcdu_message(i, "ENTRY OUT OF RANGE");
				}
			} else {
				mcdu_message(i, "NOT ALLOWED");
			}
			
			if (!getprop("/FMGC/internal/cost-index-set") and fmgc.FMGCInternal.toFromSet) {
				mcdu_message(i, "USING COST INDEX N", getprop("/FMGC/internal/last-cost-index") or 0);
				setprop("/FMGC/internal/cost-index-set", 1);
				setprop("/FMGC/internal/cost-index", getprop("/FMGC/internal/last-cost-index") or 0);
			}
		}
	} else if (key == "R4") {
		if (scratchpad == "CLR") {
			setprop("/FMGC/internal/fffq-sensor", "FF+FQ");
			mcdu_scratchpad.scratchpads[i].empty();
		} else if (find("/", scratchpad) == 0) {
			var sensor = substr(scratchpad, 1);
			if (sensor == "FF+FQ" or sensor == "FQ+FF" or sensor == "FF" or sensor == "FQ") {
				setprop("FMGC/internal/fffq-sensor", sensor);
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
