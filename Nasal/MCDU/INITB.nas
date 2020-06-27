# A3XX mCDU by Joshua Davidson (Octal450), Jonathan Redpath, and Matthew Maring (mattmaring)

# Copyright (c) 2020 Matthew Maring (mattmaring)

var initInputB = func(key, i) {
	var scratchpad = mcdu_scratchpad.scratchpads[i].scratchpad;
	if (key == "L1" and !getprop("/FMGC/internal/fuel-calculating")) {
		if (scratchpad == "CLR") {
			setprop("/FMGC/internal/taxi-fuel", 0.4);
			setprop("/FMGC/internal/taxi-fuel-set", 0);
			if (getprop("/FMGC/internal/block-confirmed")) {
				setprop("/FMGC/internal/fuel-calculating", 1);
			} else if (getprop("/FMGC/internal/fuel-request-set")) {
				setprop("/FMGC/internal/block-calculating", 1);
			}
			mcdu_scratchpad.scratchpads[i].empty();
		} else {
			var tfs = size(scratchpad);
			if (tfs >= 1 and tfs <= 4) {
				if (num(scratchpad) != nil and scratchpad >= 0.0 and scratchpad <= 9.9) {
					setprop("/FMGC/internal/taxi-fuel", scratchpad);
					setprop("/FMGC/internal/taxi-fuel-set", 1);
					if (getprop("/FMGC/internal/block-confirmed")) {
						setprop("/FMGC/internal/fuel-calculating", 1);
					} else if (getprop("/FMGC/internal/fuel-request-set")) {
						setprop("/FMGC/internal/block-calculating", 1);
					}
					mcdu_scratchpad.scratchpads[i].empty();
				} else {
					mcdu_message(i, "NOT ALLOWED");
				}
			} else {
				mcdu_message(i, "NOT ALLOWED");
			} 
		}
	} else if (key == "L3" and getprop("/FMGC/internal/block-confirmed") and !getprop("/FMGC/internal/fuel-calculating")) {
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
	} else if (key == "R1" and !getprop("/FMGC/internal/fuel-calculating")) {
		if (scratchpad == "CLR") {
			mcdu_message(i, "NOT ALLOWED");
		} else {
			if (!getprop("/FMGC/internal/cost-index-set") and getprop("/FMGC/internal/tofrom-set")) {
				mcdu_message(i, "USING COST INDEX N", getprop("/FMGC/internal/last-cost-index"));
				setprop("/FMGC/internal/cost-index-set", 1);
				setprop("/FMGC/internal/cost-index", getprop("/FMGC/internal/last-cost-index"));
			}
			var zfw_min = 80.6; #make based on performance
			var zfw_max = 134.5; #61,000 kg, make based on performance
			if (size(scratchpad) == 0) {
				var zfw = getprop("/fdm/jsbsim/inertia/weight-lbs") - getprop("/consumables/fuel/total-fuel-lbs");
				setprop("/FMGC/internal/zfw", sprintf("%3.1f", math.round(zfw / 1000, 0.1)));
				setprop("/FMGC/internal/zfw-set", 1);
				if (!getprop("/FMGC/internal/block-confirmed") and getprop("/FMGC/internal/block-set")) {
					setprop("/FMGC/internal/tow", num(getprop("/FMGC/internal/zfw") + getprop("/FMGC/internal/block") - getprop("/FMGC/internal/taxi-fuel")));
					setprop("/FMGC/internal/tow-set", 1);
					setprop("/FMGC/internal/fuel-request-set", 1);
					setprop("/FMGC/internal/fuel-calculating", 1);
					setprop("/FMGC/internal/block-calculating", 0);
					setprop("/FMGC/internal/block-confirmed", 1);
				} else if (getprop("/FMGC/internal/block-confirmed")) {
					setprop("/FMGC/internal/fuel-calculating", 1);
				} else if (getprop("/FMGC/internal/fuel-request-set")) {
					setprop("/FMGC/internal/block-calculating", 1);
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
						if (!getprop("/FMGC/internal/block-confirmed") and getprop("/FMGC/internal/block-set")) {
							setprop("/FMGC/internal/tow", num(getprop("/FMGC/internal/zfw") + getprop("/FMGC/internal/block") - getprop("/FMGC/internal/taxi-fuel")));
							setprop("/FMGC/internal/tow-set", 1);
							setprop("/FMGC/internal/fuel-request-set", 1);
							setprop("/FMGC/internal/fuel-calculating", 1);
							setprop("/FMGC/internal/block-calculating", 0);
							setprop("/FMGC/internal/block-confirmed", 1);
						} else if (getprop("/FMGC/internal/block-confirmed")) {
							setprop("/FMGC/internal/fuel-calculating", 1);
						} else if (getprop("/FMGC/internal/fuel-request-set")) {
							setprop("/FMGC/internal/block-calculating", 1);
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
					if (!getprop("/FMGC/internal/block-confirmed") and getprop("/FMGC/internal/block-set")) {
						setprop("/FMGC/internal/tow", num(getprop("/FMGC/internal/zfw") + getprop("/FMGC/internal/block") - getprop("/FMGC/internal/taxi-fuel")));
						setprop("/FMGC/internal/tow-set", 1);
						setprop("/FMGC/internal/fuel-request-set", 1);
						setprop("/FMGC/internal/fuel-calculating", 1);
						setprop("/FMGC/internal/block-calculating", 0);
						setprop("/FMGC/internal/block-confirmed", 1);
					} else if (getprop("/FMGC/internal/block-confirmed")) {
						setprop("/FMGC/internal/fuel-calculating", 1);
					} else if (getprop("/FMGC/internal/fuel-request-set")) {
						setprop("/FMGC/internal/block-calculating", 1);
					}
					mcdu_scratchpad.scratchpads[i].empty();
				} else {
					mcdu_message(i, "ENTRY OUT OF RANGE");
				}
			} else {
				mcdu_message(i, "NOT ALLOWED");
			}
		}
	} else if (key == "R2" and !getprop("/FMGC/internal/fuel-calculating")) {
		if (scratchpad == "CLR") {
			setprop("/FMGC/internal/block", 0.0);
			setprop("/FMGC/internal/block-set", 0);
			setprop("/FMGC/internal/taxi-fuel", 0.4);
			setprop("/FMGC/internal/taxi-fuel-set", 0);
			setprop("/FMGC/internal/trip-fuel", 0);
			setprop("/FMGC/internal/trip-time", "0000");
			setprop("/FMGC/internal/rte-rsv", 0);
			setprop("/FMGC/internal/rte-rsv-set", 0);
			setprop("/FMGC/internal/rte-percent", 5.0);
			setprop("/FMGC/internal/rte-percent-set", 0);
			setprop("/FMGC/internal/alt-fuel", 0);
			setprop("/FMGC/internal/alt-fuel-set", 0);
			setprop("/FMGC/internal/alt-time", "0000");
			setprop("/FMGC/internal/final-fuel", 0);
			setprop("/FMGC/internal/final-fuel-set", 0);
			setprop("/FMGC/internal/final-time", "0030");
			setprop("/FMGC/internal/final-time-set", 0);
			setprop("/FMGC/internal/min-dest-fob", 0);
			setprop("/FMGC/internal/min-dest-fob-set", 0);
			setprop("/FMGC/internal/tow", 0);
			setprop("/FMGC/internal/lw", 0);
			setprop("/FMGC/internal/trip-wind", "HD000");
			setprop("/FMGC/internal/trip-wind-value", 0);
			setprop("/FMGC/internal/fffq-sensor", "FF+FQ");
			setprop("/FMGC/internal/extra-fuel", 0);
			setprop("/FMGC/internal/extra-time", "0000");
			setprop("/FMGC/internal/fuel-request-set", 0);
			setprop("/FMGC/internal/fuel-calculating", 0);
			setprop("/FMGC/internal/block-calculating", 0);
			setprop("/FMGC/internal/block-confirmed", 0);
			mcdu_scratchpad.scratchpads[i].empty();
		} else {
			var tfs = size(scratchpad);
			var maxblock = getprop("/options/maxblock");
			if (tfs == 0) {
				setprop("/FMGC/internal/block", sprintf("%3.1f", math.round(getprop("/consumables/fuel/total-fuel-lbs") / 1000, 0.1)));
				setprop("/FMGC/internal/block-set", 1);
				if (getprop("/FMGC/internal/zfw-set")) {
					setprop("/FMGC/internal/tow", num(getprop("/FMGC/internal/zfw") + getprop("/FMGC/internal/block") - getprop("/FMGC/internal/taxi-fuel")));
					setprop("/FMGC/internal/tow-set", 1);
					setprop("/FMGC/internal/fuel-request-set", 1);
					setprop("/FMGC/internal/fuel-calculating", 1);
					setprop("/FMGC/internal/block-calculating", 0);
					setprop("/FMGC/internal/block-confirmed", 1);
				}
			} else if (tfs >= 1 and tfs <= 5) {
				if (num(scratchpad) != nil and scratchpad >= 1.0 and scratchpad <= maxblock) {
					setprop("/FMGC/internal/block", scratchpad);
					setprop("/FMGC/internal/block-set", 1);
					if (getprop("/FMGC/internal/zfw-set")) {
						setprop("/FMGC/internal/tow", num(getprop("/FMGC/internal/zfw") + getprop("/FMGC/internal/block") - getprop("/FMGC/internal/taxi-fuel")));
						setprop("/FMGC/internal/tow-set", 1);
						setprop("/FMGC/internal/fuel-request-set", 1);
						setprop("/FMGC/internal/fuel-calculating", 1);
						setprop("/FMGC/internal/block-calculating", 0);
						setprop("/FMGC/internal/block-confirmed", 1);
					}
					mcdu_scratchpad.scratchpads[i].empty();
				} else {
					mcdu_message(i, "NOT ALLOWED");
				}
			} else {
				mcdu_message(i, "NOT ALLOWED");
			}
		}
	} else if (key == "R3") {
		if (scratchpad == "" and getprop("/FMGC/internal/zfw-set") and !getprop("/FMGC/internal/fuel-request-set")) {
			setprop("/FMGC/internal/fuel-request-set", 1);
			setprop("/FMGC/internal/block-calculating", 1);
		} else if (scratchpad == "" and getprop("/FMGC/internal/zfw-set") and getprop("/FMGC/internal/fuel-request-set") and !getprop("/FMGC/internal/block-confirmed") and !getprop("/FMGC/internal/block-calculating")) {
			setprop("/FMGC/internal/block-confirmed", 1);
			setprop("/FMGC/internal/fuel-calculating", 1);
		} else {
			mcdu_message(i, "NOT ALLOWED");
		}
	} else if (key == "R5" and !getprop("/FMGC/internal/fuel-calculating")) {
		if (scratchpad == "CLR") {
			setprop("/FMGC/internal/trip-wind", "HD000");
			setprop("/FMGC/internal/trip-wind-value", 0);
			if (getprop("/FMGC/internal/block-confirmed")) {
				setprop("/FMGC/internal/fuel-calculating", 1);
			}
			mcdu_scratchpad.scratchpads[i].empty();
		} else {
			if (find("TL", scratchpad) != -1 or find("HD", scratchpad) != -1) {
				var effwind = substr(scratchpad, 2);
				if (int(effwind) != nil and effwind >= 0 and effwind <= 500) {
					setprop("/FMGC/internal/trip-wind", scratchpad);
					setprop("/FMGC/internal/trip-wind-value", effwind);
					if (getprop("/FMGC/internal/block-confirmed")) {
						setprop("/FMGC/internal/fuel-calculating", 1);
					}
					mcdu_scratchpad.scratchpads[i].empty();
				} else {
					mcdu_message(i, "NOT ALLOWED");
				}
			} else if (find("-", scratchpad) != -1 or find("+", scratchpad) != -1 or find("T", scratchpad) != -1 or find("H", scratchpad) != -1) {
				var effwind = substr(scratchpad, 1);
				if (int(effwind) != nil and effwind >= 0 and effwind <= 500) {
					setprop("/FMGC/internal/trip-wind", scratchpad);
					setprop("/FMGC/internal/trip-wind-value", effwind);
					if (getprop("/FMGC/internal/block-confirmed")) {
						setprop("/FMGC/internal/fuel-calculating", 1);
					}
					mcdu_scratchpad.scratchpads[i].empty();
				} else {
					mcdu_message(i, "NOT ALLOWED");
				}
			} else {
				if (num(scratchpad) != nil and scratchpad >= 0 and scratchpad <= 500) {
					setprop("/FMGC/internal/trip-wind", scratchpad);
					setprop("/FMGC/internal/trip-wind-value", scratchpad);
					if (getprop("/FMGC/internal/block-confirmed")) {
						setprop("/FMGC/internal/fuel-calculating", 1);
					}
					mcdu_scratchpad.scratchpads[i].empty();
				} else {
					mcdu_message(i, "NOT ALLOWED");
				}
			}
		}
	} else {
		mcdu_message(i, "NOT ALLOWED");
	}
}
