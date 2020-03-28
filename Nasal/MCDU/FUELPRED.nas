# A3XX mCDU by Joshua Davidson (Octal450), Jonathan Redpath, and Matthew Maring (hayden2000)

# Copyright (c) 2020 Matthew Maring (hayden2000)

# From INIT-B
var zfw = props.globals.getNode("FMGC/internal/zfw", 1);
var block = props.globals.getNode("FMGC/internal/block", 1);
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
var extra_fuel = props.globals.getNode("FMGC/internal/extra-fuel", 1);
var extra_time = props.globals.getNode("FMGC/internal/extra-time", 1);

var fuelPredInput = func(key, i) {
	var scratchpad = getprop("MCDU[" ~ i ~ "]/scratchpad");
	if (key == "L3") {
		if (scratchpad == "CLR") {
			notAllowed(i);
		} else if (getprop("FMGC/internal/trip-fuel") != 0) {
			var tfs = size(scratchpad);
			if (tfs >= 2 and tfs <= 5 and find("/", scratchpad) == 0) {
				var perc = split("/", scratchpad)[1];
				if (perc >= 0.0 and perc <= 100.0) {
					setprop("FMGC/internal/rte-rsv", num(perc) / 100 * num(trip_fuel.getValue()));
					setprop("FMGC/internal/rte-percent", perc);
					setprop("MCDU[" ~ i ~ "]/scratchpad", "");
				}
			} else if (tfs >= 1 and tfs <= 4) {
				if (scratchpad >= 0.0 and scratchpad <= trip_fuel.getValue()) {
					setprop("FMGC/internal/rte-rsv", scratchpad);
					setprop("FMGC/internal/rte-percent", scratchpad / num(trip_fuel.getValue()) * 100);
					setprop("MCDU[" ~ i ~ "]/scratchpad", "");
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
			notAllowed(i);
		} else {
			var tfs = size(scratchpad);
			if (tfs >= 1 and tfs <= 3) {
				if (scratchpad >= 0.0 and scratchpad <= 99.9) {
					setprop("FMGC/internal/alt-fuel", scratchpad);
					setprop("MCDU[" ~ i ~ "]/scratchpad", "");
					
					setprop("FMGC/internal/min-dest-fob", num(alt_fuel.getValue() + final_fuel.getValue()));
					setprop("FMGC/internal/rte-rsv", num((block.getValue() - taxi_fuel.getValue() - min_dest_fob.getValue()) * (rte_percent.getValue() / 100) / (1 + rte_percent.getValue() / 100)));
					setprop("FMGC/internal/trip-fuel", num(block.getValue() - taxi_fuel.getValue() - min_dest_fob.getValue() - rte_rsv.getValue()));
					setprop("FMGC/internal/tow", num(block.getValue() + zfw.getValue() - taxi_fuel.getValue()));
					setprop("FMGC/internal/lw", num(tow.getValue() - trip_fuel.getValue()));

				} else {
					notAllowed(i);
				}
			} else {
				notAllowed(i);
			} 
		}
	} else if (key == "L5") {
		if (scratchpad == "CLR") {
			notAllowed(i);
		} else {
			var tfs = size(scratchpad);
			if (tfs >= 1 and tfs <= 3) {
				if (scratchpad >= 0.0 and scratchpad <= 99.9) {
					setprop("FMGC/internal/final-fuel", scratchpad);
					setprop("MCDU[" ~ i ~ "]/scratchpad", "");
					
					setprop("FMGC/internal/min-dest-fob", num(alt_fuel.getValue() + final_fuel.getValue()));
					setprop("FMGC/internal/rte-rsv", num((block.getValue() - taxi_fuel.getValue() - min_dest_fob.getValue()) * (rte_percent.getValue() / 100) / (1 + rte_percent.getValue() / 100)));
					setprop("FMGC/internal/trip-fuel", num(block.getValue() - taxi_fuel.getValue() - min_dest_fob.getValue() - rte_rsv.getValue()));
					setprop("FMGC/internal/tow", num(block.getValue() + zfw.getValue() - taxi_fuel.getValue()));
					setprop("FMGC/internal/lw", num(tow.getValue() - trip_fuel.getValue()));

				} else {
					notAllowed(i);
				}
			} else {
				notAllowed(i);
			} 
		}
	} else if (key == "R3") {
		if (scratchpad == "CLR") {
			notAllowed(i);
		} else {
			var tfs = size(scratchpad);
			if (tfs == 0) {
				var zfw = getprop("fdm/jsbsim/inertia/weight-lbs") - getprop("consumables/fuel/total-fuel-lbs");
				setprop("MCDU[" ~ i ~ "]/scratchpad", "/" ~ sprintf("%3.1f", math.round(zfw / 1000, 0.1)));
			} else if (tfs >= 2 and tfs <= 11 and find("/", scratchpad) != -1) {
				var zfwi = split("/", scratchpad);
				var zfwcg = size(zfwi[0]);
				var zfw = size(zfwi[1]);
				if (zfwcg >= 1 and zfwcg <= 5 and zfwi[0] > 0 and zfwi[0] <= 99.9) {
					setprop("FMGC/internal/zfwcg", zfwi[0]);
					setprop("FMGC/internal/zfwcg-set", 1);
					if (getprop("FMGC/internal/block-set") != 1) {
						setprop("FMGC/internal/block", 30);
						setprop("FMGC/internal/block-set", 1);
					}
				}
				if (zfw >= 1 and zfw <= 5 and zfwi[1] > 0 and zfwi[1] <= 999.9) {
					setprop("FMGC/internal/zfw", zfwi[1]);
					setprop("FMGC/internal/zfw-set", 1);
					if (getprop("FMGC/internal/block-set") != 1) {
						setprop("FMGC/internal/block", 30);
						setprop("FMGC/internal/block-set", 1);
					}
				}
				if ((zfwcg >= 1 and zfwcg <= 5 and zfwi[0] > 0 and zfwi[0] <= 99.9) or (zfw >= 1 and zfw <= 5 and zfwi[1] > 0 and zfwi[1] <= 999.9)) {
					setprop("MCDU[" ~ i ~ "]/scratchpad", "");
				} else {
					notAllowed(i);
				}
			} else if (tfs >= 1 and tfs <= 5) {
				var zfwcg = size(scratchpad);
				if (zfwcg >= 1 and zfwcg <= 5 and scratchpad > 0 and scratchpad <= 99.9) {
					setprop("FMGC/internal/zfwcg", scratchpad);
					setprop("FMGC/internal/zfwcg-set", 1);
					if (getprop("FMGC/internal/block-set") != 1) {
						setprop("FMGC/internal/block", 30);
						setprop("FMGC/internal/block-set", 1);
					}
					setprop("MCDU[" ~ i ~ "]/scratchpad", "");
				} else {
					notAllowed(i);
				}
			} else {
				notAllowed(i);
			}
		}
	}
}
