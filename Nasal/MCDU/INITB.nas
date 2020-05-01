# A3XX mCDU by Joshua Davidson (Octal450), Jonathan Redpath, and Matthew Maring (mattmaring)

# Copyright (c) 2020 Matthew Maring (mattmaring)

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
var extra_fuel = props.globals.getNode("FMGC/internal/extra-fuel", 1);
var extra_time = props.globals.getNode("FMGC/internal/extra-time", 1);

var initInputB = func(key, i) {
	var scratchpad = getprop("MCDU[" ~ i ~ "]/scratchpad");
	if (key == "L1") {
		if (scratchpad == "CLR") {
			setprop("FMGC/internal/taxi-fuel", 0.4);
			setprop("MCDU[" ~ i ~ "]/scratchpad-msg", 0);
			setprop("MCDU[" ~ i ~ "]/scratchpad", "");
		} else {
			var tfs = size(scratchpad);
			if (tfs >= 1 and tfs <= 4) {
				if (num(scratchpad) != nil and scratchpad >= 0.0 and scratchpad <= 9.9) {
					setprop("FMGC/internal/taxi-fuel", scratchpad);
					setprop("MCDU[" ~ i ~ "]/scratchpad", "");
					fmgc.updateFuel();
				} else {
					notAllowed(i);
				}
			} else {
				notAllowed(i);
			} 
		}
#	}
#   else if (key == "L2") {
#		if (scratchpad == "CLR") {
#			notAllowed(i);
#		} else if (getprop("FMGC/internal/trip-fuel") != 0) {
#			var tfs = size(scratchpad);
#			if (tfs >= 1 and tfs <= 4) {
#				var temp_rte = num(scratchpad * (rte_percent.getValue() / 100) / (1 + rte_percent.getValue() / 100));
#				if (scratchpad >= 0.0 and scratchpad <= block.getValue() - taxi_fuel.getValue() - min_dest_fob.getValue() - temp_rte) {
#					setprop("FMGC/internal/trip-fuel", scratchpad);
#					setprop("MCDU[" ~ i ~ "]/scratchpad", "");
#					
#					setprop("FMGC/internal/rte-rsv", temp_rte);
#					  setprop("FMGC/internal/tow", num(block.getValue() + zfw.getValue() - taxi_fuel.getValue()));
#					  setprop("FMGC/internal/lw", num(tow.getValue() - trip_fuel.getValue()));
#				} else {
#					notAllowed(i);
#				}
#			} else {
#				notAllowed(i);
#			}
#		} else {
#			  notAllowed(i);
#		  }
#	
	} else if (key == "L3" and blockSet.getValue() == 1 and zfwSet.getValue() == 1) {
		if (scratchpad == "CLR") {
			setprop("FMGC/internal/rte-rsv", 0.05 * num(trip_fuel.getValue()));
			setprop("FMGC/internal/rte-percent", 5.0);
			setprop("MCDU[" ~ i ~ "]/scratchpad-msg", 0);
			setprop("MCDU[" ~ i ~ "]/scratchpad", "");
			fmgc.updateFuel();
		} else if (getprop("FMGC/internal/trip-fuel") != 0) {
			var tf = num(scratchpad);
			var tfs = size(scratchpad);
			if (tfs >= 2 and tfs <= 5 and find("/", scratchpad) == 0) {
				var perc = num(split("/", scratchpad)[1]);
				if (perc != nil and perc >= 0.0 and perc <= 15.0) {
					setprop("FMGC/internal/rte-rsv", num(perc) / 100 * num(trip_fuel.getValue()));
					setprop("FMGC/internal/rte-percent", perc);
					setprop("MCDU[" ~ i ~ "]/scratchpad", "");
				}
			} else if (tfs >= 1 and tfs <= 4 and tf != nil and tf >= 0 and tf <= 21.7 and tf / num(trip_fuel.getValue()) <= 0.15) {
					setprop("FMGC/internal/rte-rsv", scratchpad);
					setprop("FMGC/internal/rte-percent", scratchpad / num(trip_fuel.getValue()) * 100);
					setprop("MCDU[" ~ i ~ "]/scratchpad", "");
			} else {
				notAllowed(i);
			}
		} else {
			notAllowed(i);
		}
	} else if (key == "L4" and blockSet.getValue() == 1 and zfwSet.getValue() == 1) {
		if (scratchpad == "CLR") {
			setprop("FMGC/internal/alt-fuel", 0.0);
			setprop("FMGC/internal/alt-time", "0000");
			setprop("MCDU[" ~ i ~ "]/scratchpad-msg", 0);
			setprop("MCDU[" ~ i ~ "]/scratchpad", "");
			fmgc.updateFuel();
		} else if (find(".", scratchpad) != -1) {
			var tf = num(scratchpad);
			var tfs = size(scratchpad);
			if (tfs >= 3 and tfs <= 4 and tf != nil and tf >= 0 and tf <= 10.0 and tf < trip_fuel.getValue() + alt_fuel.getValue()) {
				setprop("FMGC/internal/alt-fuel", tf);
				setprop("MCDU[" ~ i ~ "]/scratchpad", "");
				fmgc.updateFuel();
			} else {
				notAllowed(i);
			}
		} else {
			var tf = num(scratchpad);
			var tfs = size(scratchpad);
			if (tfs == 4 and tf != nil and ((tf >= 0 and tf <= 59) or (tf >= 100 and tf <= 130))) {
				setprop("FMGC/internal/alt-time", scratchpad);
				setprop("MCDU[" ~ i ~ "]/scratchpad", "");
			} else {
				notAllowed(i);
			} 
		}
	} else if (key == "L5" and blockSet.getValue() == 1 and zfwSet.getValue() == 1) {
		if (scratchpad == "CLR") {
			setprop("FMGC/internal/final-fuel", 0.0);
			setprop("FMGC/internal/final-time", "0030");
			setprop("MCDU[" ~ i ~ "]/scratchpad-msg", 0);
			setprop("MCDU[" ~ i ~ "]/scratchpad", "");
			fmgc.updateFuel();
		} else if (find(".", scratchpad) != -1) {
			var tf = num(scratchpad);
			var tfs = size(scratchpad);
			if (tfs >= 3 and tfs <= 4 and tf != nil and tf >= 0 and tf <= 10.0 and tf < trip_fuel.getValue() + final_fuel.getValue()) {
				setprop("FMGC/internal/final-fuel", tf);
				setprop("MCDU[" ~ i ~ "]/scratchpad", "");
				fmgc.updateFuel();
			} else {
				notAllowed(i);
			}
		} else {
			var tf = num(scratchpad);
			var tfs = size(scratchpad);
			if (tfs == 4 and tf != nil and ((tf >= 0 and tf <= 59) or (tf >= 100 and tf <= 130))) {
				setprop("FMGC/internal/final-time", scratchpad);
				setprop("MCDU[" ~ i ~ "]/scratchpad", "");
			} else {
				notAllowed(i);
			} 
		}
	} else if (key == "R1") {
		if (scratchpad == "CLR") {
			notAllowed(i);
		} else {
			var tfs = size(scratchpad);
			if (tfs == 0) {
				var zfw = getprop("fdm/jsbsim/inertia/weight-lbs") - getprop("consumables/fuel/total-fuel-lbs");
				setprop("MCDU[" ~ i ~ "]/scratchpad", "/" ~ sprintf("%3.1f", math.round(zfw / 1000, 0.1)));
			} else if (tfs >= 2 and tfs <= 11 and find("/", scratchpad) != -1) {
				var zfwi = split("/", scratchpad);
				var zfwcg = num(zfwi[0]);
				var zfw = num(zfwi[1]);
				var zfwcgs = size(zfwi[0]);
				var zfws = size(zfwi[1]);
				if (zfwcg != nil and zfwcgs >= 1 and zfwcgs <= 5 and zfwcg > 0 and zfwcg <= 99.9) {
					setprop("FMGC/internal/zfwcg", zfwi[0]);
					setprop("FMGC/internal/zfwcg-set", 1);
				}
				if (zfw != nil and zfws >= 1 and zfws <= 5 and zfw > 0 and zfw <= 999.9) {
					setprop("FMGC/internal/zfw", zfwi[1]);
					setprop("FMGC/internal/zfw-set", 1);
				}
				if ((zfwcg != nil and zfwcgs >= 1 and zfwcgs <= 5 and zfwcg > 0 and zfwcg <= 99.9) or (zfw != nil and zfws >= 1 and zfws <= 5 and zfw > 0 and zfw <= 999.9)) {
					setprop("MCDU[" ~ i ~ "]/scratchpad", "");
				} else {
					notAllowed(i);
				}
			} else if (tfs >= 1 and tfs <= 5) {
				var zfwcg = size(scratchpad);
				if (num(scratchpad) != nil and zfwcg >= 1 and zfwcg <= 5 and scratchpad > 0 and scratchpad <= 99.9) {
					setprop("FMGC/internal/zfwcg", scratchpad);
					setprop("FMGC/internal/zfwcg-set", 1);
					setprop("MCDU[" ~ i ~ "]/scratchpad", "");
				} else {
					notAllowed(i);
				}
			} else {
				notAllowed(i);
			}
		}
	} else if (key == "R2") {
		if (scratchpad == "CLR") {
			setprop("FMGC/internal/block", 0.0);
			setprop("FMGC/internal/block-set", 0);
			setprop("FMGC/internal/taxi-fuel", 0.4);
			setprop("FMGC/internal/rte-rsv", 0.05 * num(trip_fuel.getValue()));
			setprop("FMGC/internal/rte-percent", 5.0);
			setprop("FMGC/internal/alt-fuel", 0.0);
			setprop("FMGC/internal/alt-time", "0000");
			setprop("FMGC/internal/final-fuel", 0.0);
			setprop("FMGC/internal/final-time", "0030");
			setprop("FMGC/internal/extra-fuel", 0.0);
			setprop("FMGC/internal/extra-time", "0000");
			setprop("FMGC/internal/min-dest-fob", 0.0);
			setprop("MCDU[" ~ i ~ "]/scratchpad-msg", 0);
			setprop("MCDU[" ~ i ~ "]/scratchpad", "");
		} else {
			var tfs = size(scratchpad);
			var maxblock = getprop("options/maxblock");
			if (tfs == 0) {
				setprop("MCDU[" ~ i ~ "]/scratchpad", sprintf("%3.1f", math.round(getprop("consumables/fuel/total-fuel-lbs") / 1000, 0.1)));
			} else if (tfs >= 1 and tfs <= 5) {
				if (num(scratchpad) != nil and scratchpad >= 1.0 and scratchpad <= maxblock) {
					setprop("FMGC/internal/block", scratchpad);
					setprop("FMGC/internal/block-set", 1);
					setprop("FMGC/internal/taxi-fuel", 0.4);
					setprop("FMGC/internal/rte-rsv", 0.05 * num(trip_fuel.getValue()));
					setprop("FMGC/internal/rte-percent", 5.0);
					setprop("FMGC/internal/alt-fuel", 0.0);
					setprop("FMGC/internal/alt-time", "0000");
					setprop("FMGC/internal/final-fuel", 0.0);
					setprop("FMGC/internal/final-time", "0030");
					setprop("FMGC/internal/extra-fuel", 0.0);
					setprop("FMGC/internal/extra-time", "0000");
					setprop("FMGC/internal/min-dest-fob", 0.0);
					setprop("MCDU[" ~ i ~ "]/scratchpad", "");
				} else {
					notAllowed(i);
				}
			} else {
				notAllowed(i);
			}
		}
	} else if (key == "R3") {
		if (scratchpad == "" and (!getprop("FMGC/internal/block-set") or !getprop("FMGC/internal/zfw-set"))) {
			setprop("FMGC/internal/zfw", num((getprop("fdm/jsbsim/inertia/weight-lbs") - getprop("consumables/fuel/total-fuel-lbs")) / 1000));
			setprop("FMGC/internal/zfw-set", 1);
			setprop("FMGC/internal/block", num(getprop("consumables/fuel/total-fuel-lbs") / 1000));
			setprop("FMGC/internal/block-set", 1);
		} else {
			notAllowed(i);
		}
	} else if (key == "R5") {
		if (scratchpad == "CLR") {
			setprop("FMGC/internal/trip-wind", "HD000");
			setprop("MCDU[" ~ i ~ "]/scratchpad-msg", 0);
			setprop("MCDU[" ~ i ~ "]/scratchpad", "");
		} else {
			if (find("TL", scratchpad) != -1 or find("HD", scratchpad) != -1) {
				var effwind = substr(scratchpad, 2);
				if (int(effwind) != nil and effwind >= 0 and effwind <= 500) {
					setprop("FMGC/internal/trip-wind", scratchpad);
					setprop("MCDU[" ~ i ~ "]/scratchpad", "");
				} else {
					notAllowed(i);
				}
			} else if (find("-", scratchpad) != -1 or find("+", scratchpad) != -1 or find("T", scratchpad) != -1 or find("H", scratchpad) != -1) {
				var effwind = substr(scratchpad, 1);
				if (int(effwind) != nil and effwind >= 0 and effwind <= 500) {
					setprop("FMGC/internal/trip-wind", scratchpad);
					setprop("MCDU[" ~ i ~ "]/scratchpad", "");
				} else {
					notAllowed(i);
				}
			} else {
				if (num(scratchpad) != nil and scratchpad >= 0 and scratchpad <= 500) {
					setprop("FMGC/internal/trip-wind", scratchpad);
					setprop("MCDU[" ~ i ~ "]/scratchpad", "");
				} else {
					notAllowed(i);
				}
			}
		}
	} else {
		notAllowed(i);
	}
}
