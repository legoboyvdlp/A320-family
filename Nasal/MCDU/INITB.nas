# A3XX mCDU by Joshua Davidson (Octal450), Jonathan Redpath, and Matthew Maring (mattmaring)

# Copyright (c) 2020 Matthew Maring (mattmaring)

var acconfig_weight_kgs = props.globals.getNode("/systems/acconfig/options/weight-kgs", 1);
# Conversion factor pounds to kilogram
var LBS2KGS = 0.4535924;

var initInputB = func(key, i) {
	var scratchpad = mcdu_scratchpad.scratchpads[i].scratchpad;
	if (key == "L1" and !fmgc.FMGCInternal.fuelCalculating) {
		if (scratchpad == "CLR") {
			fmgc.FMGCInternal.taxiFuel = 0.4;
			fmgc.FMGCInternal.taxiFuelSet = 0;
			if (fmgc.FMGCInternal.blockConfirmed) {
				fmgc.FMGCInternal.fuelCalculating = 1;
				fmgc.fuelCalculating.setValue(1);
			} else if (fmgc.FMGCInternal.fuelRequest) {
				fmgc.FMGCInternal.blockCalculating = 1;
				fmgc.blockCalculating.setValue(1);
			}
			mcdu_scratchpad.scratchpads[i].empty();
		} else {	
			var tfs = size(scratchpad);
			if (acconfig_weight_kgs.getValue() == 1) {
				scratchpad = scratchpad / LBS2KGS;
			}
			if (tfs >= 1 and tfs <= 4) {
				if (num(scratchpad) != nil and scratchpad >= 0.0 and scratchpad <= 9.9) {
					fmgc.FMGCInternal.taxiFuel = scratchpad;
					fmgc.FMGCInternal.taxiFuelSet = 1;
					if (fmgc.FMGCInternal.blockConfirmed) {
						fmgc.FMGCInternal.fuelCalculating = 1;
						fmgc.fuelCalculating.setValue(1);
					} else if (fmgc.FMGCInternal.fuelRequest) {
						fmgc.FMGCInternal.blockCalculating = 1;
						fmgc.blockCalculating.setValue(1);
					}
					mcdu_scratchpad.scratchpads[i].empty();
				} else {
					mcdu_message(i, "NOT ALLOWED");
				}
			} else {
				mcdu_message(i, "NOT ALLOWED");
			}
		}
	} else if (key == "L3" and fmgc.FMGCInternal.blockConfirmed and !fmgc.FMGCInternal.fuelCalculating) {
		if (scratchpad == "CLR") {
			fmgc.FMGCInternal.rteRsv = 0.05 * fmgc.FMGCInternal.tripFuel;
			fmgc.FMGCInternal.rteRsvSet = 0;
			fmgc.FMGCInternal.rtePercent = 5.0;
			fmgc.FMGCInternal.rtePercentSet = 0;
			fmgc.FMGCInternal.fuelCalculating = 1;
			fmgc.fuelCalculating.setValue(1);
			mcdu_scratchpad.scratchpads[i].empty();
		} else if (fmgc.FMGCInternal.tripFuel != 0) {
			var tf = num(scratchpad);
			if (acconfig_weight_kgs.getValue() == 1) {
				tf = tf / LBS2KGS;
			}
			var tfs = size(scratchpad);
			if (tfs >= 2 and tfs <= 5 and find("/", scratchpad) == 0) {
				var perc = num(split("/", scratchpad)[1]);
				if (perc != nil and perc >= 0.0 and perc <= 15.0) {
					fmgc.FMGCInternal.rteRsv = perc / 100 * fmgc.FMGCInternal.tripFuel;
					fmgc.FMGCInternal.rteRsvSet = 0;
					fmgc.FMGCInternal.rtePercent = perc;
					fmgc.FMGCInternal.rtePercentSet = 1;
					fmgc.FMGCInternal.fuelCalculating = 1;
					fmgc.fuelCalculating.setValue(1);
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
					fmgc.FMGCInternal.fuelCalculating = 1;
					fmgc.fuelCalculating.setValue(1);
					mcdu_scratchpad.scratchpads[i].empty();
			} else {
				mcdu_message(i, "NOT ALLOWED");
			}
		} else {
			mcdu_message(i, "NOT ALLOWED");
		}
	} else if (key == "L4" and fmgc.FMGCInternal.blockConfirmed and !fmgc.FMGCInternal.fuelCalculating and fmgc.FMGCInternal.altAirportSet) {
		if (scratchpad == "CLR") {
			fmgc.FMGCInternal.altFuel = 0.0;
			fmgc.FMGCInternal.altTime = "0000";
			fmgc.FMGCInternal.altFuelSet = 0;
			fmgc.FMGCInternal.fuelCalculating = 1;
			fmgc.fuelCalculating.setValue(1);
			mcdu_scratchpad.scratchpads[i].empty();
		} else if (find(".", scratchpad) != -1) {
			var tf = num(scratchpad);
			if (acconfig_weight_kgs.getValue() == 1) {
				tf = tf / LBS2KGS;
			}
			var tfs = size(scratchpad);
			if (tfs >= 3 and tfs <= 4 and tf != nil and tf >= 0 and tf <= 10.0) {
				fmgc.FMGCInternal.altFuel = tf;
				fmgc.FMGCInternal.altTime = "0000";
				fmgc.FMGCInternal.altFuelSet = 1;
				fmgc.FMGCInternal.fuelCalculating = 1;
				fmgc.fuelCalculating.setValue(1);
				mcdu_scratchpad.scratchpads[i].empty();
			} else {
				mcdu_message(i, "NOT ALLOWED");
			}
		} else {
			mcdu_message(i, "NOT ALLOWED");
		}
	} else if (key == "L5" and fmgc.FMGCInternal.blockConfirmed and !fmgc.FMGCInternal.fuelCalculating) {
		if (scratchpad == "CLR") {
			fmgc.FMGCInternal.finalFuel = 0.0;
			fmgc.FMGCInternal.finalTime = "0030";
			fmgc.FMGCInternal.finalFuelSet = 0;
			fmgc.FMGCInternal.finalTimeSet = 0;
			fmgc.FMGCInternal.fuelCalculating = 1;
			fmgc.fuelCalculating.setValue(1);
			mcdu_scratchpad.scratchpads[i].empty();
		} else if (find(".", scratchpad) != -1) {
			var tf = num(scratchpad);
			if (acconfig_weight_kgs.getValue() == 1) {
				tf = tf / LBS2KGS;
			}
			var tfs = size(scratchpad);
			if (tfs >= 3 and tfs <= 4 and tf != nil and tf >= 0 and tf <= 10.0) {
				fmgc.FMGCInternal.finalFuel = tf;
				fmgc.FMGCInternal.finalFuelSet = 1;
				fmgc.FMGCInternal.fuelCalculating = 1;
				fmgc.fuelCalculating.setValue(1);
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
				fmgc.FMGCInternal.fuelCalculating = 1;
				fmgc.fuelCalculating.setValue(1);
				mcdu_scratchpad.scratchpads[i].empty();
			} else {
				mcdu_message(i, "NOT ALLOWED");
			} 
		}
	} else if (key == "L6" and fmgc.FMGCInternal.blockConfirmed and !fmgc.FMGCInternal.fuelCalculating) {
		if (scratchpad == "CLR") {
			fmgc.FMGCInternal.minDestFob = 0;
			fmgc.FMGCInternal.minDestFobSet = 0;
			fmgc.FMGCInternal.fuelCalculating = 1;
			fmgc.fuelCalculating.setValue(1);
			mcdu_scratchpad.scratchpads[i].empty();
		} else if (find(".", scratchpad) != -1) {
			var tf = num(scratchpad);
			if (acconfig_weight_kgs.getValue() == 1) {
				tf = tf / LBS2KGS;
			}
			var tfs = size(scratchpad);
			if (tfs >= 3 and tfs <= 5 and tf != nil and tf >= 0 and tf <= 80.0) {
				fmgc.FMGCInternal.minDestFob = tf;
				fmgc.FMGCInternal.minDestFobSet = 1;
				fmgc.FMGCInternal.fuelCalculating = 1;
				fmgc.fuelCalculating.setValue(1);
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
	} else if (key == "R1" and !fmgc.FMGCInternal.fuelCalculating) {
		if (scratchpad == "CLR") {
			mcdu_message(i, "NOT ALLOWED");
		} else {
			var zfw_min = 80.6; #make based on performance
			var zfw_max = 134.5; #61,000 kg, make based on performance

			if (size(scratchpad) == 0) {
				var zfw = pts.Fdm.JSBsim.Inertia.weightLbs.getValue() - pts.Consumables.Fuel.totalFuelLbs.getValue();
				fmgc.FMGCInternal.zfw = sprintf("%3.1f", math.round(zfw / 1000, 0.1));
				fmgc.FMGCInternal.zfwSet = 1;
				if (!fmgc.FMGCInternal.blockConfirmed and fmgc.FMGCInternal.blockSet) {
					fmgc.FMGCInternal.tow = fmgc.FMGCInternal.zfw + fmgc.FMGCInternal.block - fmgc.FMGCInternal.taxiFuel;
					fmgc.FMGCInternal.fuelRequest = 1;
					fmgc.FMGCInternal.fuelCalculating = 1;
					fmgc.fuelCalculating.setValue(1);
					fmgc.FMGCInternal.blockCalculating = 0;
					fmgc.blockCalculating.setValue(0);
					fmgc.FMGCInternal.blockConfirmed = 1;
				} else if (fmgc.FMGCInternal.blockConfirmed) {
					fmgc.FMGCInternal.fuelCalculating = 1;
					fmgc.fuelCalculating.setValue(1);
				} else if (fmgc.FMGCInternal.fuelRequest) {
					fmgc.FMGCInternal.blockCalculating = 1;
					fmgc.blockCalculating.setValue(1);
				}
				mcdu_scratchpad.scratchpads[i].empty();
			} else if (find("/", scratchpad) != -1) {
				if (acconfig_weight_kgs.getValue() == 1) {
					scratchpad = scratchpad / LBS2KGS;
				}
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
						if (!fmgc.FMGCInternal.blockConfirmed and fmgc.FMGCInternal.blockSet) {
							fmgc.FMGCInternal.tow = fmgc.FMGCInternal.zfw + fmgc.FMGCInternal.block - fmgc.FMGCInternal.taxiFuel;
							fmgc.FMGCInternal.fuelRequest = 1;
							fmgc.FMGCInternal.fuelCalculating = 1;
							fmgc.fuelCalculating.setValue(1);
							fmgc.FMGCInternal.blockCalculating = 0;
							fmgc.blockCalculating.setValue(0);
							fmgc.FMGCInternal.blockConfirmed = 1;
						} else if (fmgc.FMGCInternal.blockConfirmed) {
							fmgc.FMGCInternal.fuelCalculating = 1;
							fmgc.fuelCalculating.setValue(1);
						} else if (fmgc.FMGCInternal.fuelRequest) {
							fmgc.FMGCInternal.blockCalculating = 1;
							fmgc.blockCalculating.setValue(1);
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
				if (acconfig_weight_kgs.getValue() == 1) {
					scratchpad = scratchpad / LBS2KGS;
				}
				if (scratchpad >= zfw_min and scratchpad <= zfw_max) {
					fmgc.FMGCInternal.zfw = scratchpad;
					fmgc.FMGCInternal.zfwSet = 1;
					if (!fmgc.FMGCInternal.blockConfirmed and fmgc.FMGCInternal.blockSet) {
						fmgc.FMGCInternal.tow = fmgc.FMGCInternal.zfw + fmgc.FMGCInternal.block - fmgc.FMGCInternal.taxiFuel;
						fmgc.FMGCInternal.fuelRequest = 1;
						fmgc.FMGCInternal.fuelCalculating = 1;
						fmgc.fuelCalculating.setValue(1);
						fmgc.FMGCInternal.blockCalculating = 0;
						fmgc.blockCalculating.setValue(0);
						fmgc.FMGCInternal.blockConfirmed = 1;
					} else if (fmgc.FMGCInternal.blockConfirmed) {
						fmgc.FMGCInternal.fuelCalculating = 1;
						fmgc.fuelCalculating.setValue(1);
					} else if (fmgc.FMGCInternal.fuelRequest) {
						fmgc.FMGCInternal.blockCalculating = 1;
						fmgc.blockCalculating.setValue(1);
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
	} else if (key == "R2" and !fmgc.FMGCInternal.fuelCalculating) {
		if (scratchpad == "CLR") {
			fmgc.FMGCInternal.block = 0.0;
			fmgc.FMGCInternal.blockSet = 0;
			fmgc.FMGCInternal.taxiFuel = 0.4;
			fmgc.FMGCInternal.taxiFuelSet = 0;
			fmgc.FMGCInternal.tripFuel = 0;
			fmgc.FMGCInternal.tripTime = "0000";
			fmgc.FMGCInternal.rteRsv = 0;
			fmgc.FMGCInternal.rteRsvSet = 0;
			fmgc.FMGCInternal.rtePercent = 5.0;
			fmgc.FMGCInternal.rtePercentSet = 0;
			fmgc.FMGCInternal.altFuel = 0;
			fmgc.FMGCInternal.altFuelSet = 0;
			fmgc.FMGCInternal.altTime = "0000";
			fmgc.FMGCInternal.finalFuel = 0;
			fmgc.FMGCInternal.finalFuelSet = 0;
			fmgc.FMGCInternal.finalTime = "0030";
			fmgc.FMGCInternal.finalTimeSet = 0;
			fmgc.FMGCInternal.minDestFob = 0;
			fmgc.FMGCInternal.minDestFobSet = 0;
			fmgc.FMGCInternal.tow = 0;
			fmgc.FMGCInternal.lw = 0;
			fmgc.FMGCInternal.tripWind = "HD000";
			fmgc.FMGCInternal.tripWindValue = 0;
			fmgc.FMGCInternal.fffqSensor = "FF+FQ";
			fmgc.FMGCInternal.extraFuel = 0;
			fmgc.FMGCInternal.extraTime = "0000";
			fmgc.FMGCInternal.fuelRequest = 0;
			fmgc.FMGCInternal.fuelCalculating = 0;
			fmgc.fuelCalculating.setValue(0);
			fmgc.FMGCInternal.blockCalculating = 0;
			fmgc.blockCalculating.setValue(0);
			fmgc.FMGCInternal.blockConfirmed = 0;
			mcdu_scratchpad.scratchpads[i].empty();
		} else {
			var tfs = size(scratchpad);
			var maxblock = getprop("/options/maxblock");
			if (tfs == 0) {
				fmgc.FMGCInternal.block = sprintf("%3.1f", math.round(pts.Consumables.Fuel.totalFuelLbs.getValue() / 1000, 0.1));
				fmgc.FMGCInternal.blockSet = 1;
				if (fmgc.FMGCInternal.zfwSet) {
					fmgc.FMGCInternal.tow = num(fmgc.FMGCInternal.zfw + fmgc.FMGCInternal.block - fmgc.FMGCInternal.taxiFuel);
					fmgc.FMGCInternal.fuelRequest = 1;
					fmgc.FMGCInternal.fuelCalculating = 1;
					fmgc.fuelCalculating.setValue(1);
					fmgc.FMGCInternal.blockCalculating = 0;
					fmgc.blockCalculating.setValue(0);
					fmgc.FMGCInternal.blockConfirmed = 1;
				}
			} else if (tfs >= 1 and tfs <= 5) {
				if (acconfig_weight_kgs.getValue() == 1) {
					scratchpad = scratchpad / LBS2KGS;
				}

				if (num(scratchpad) != nil and scratchpad >= 1.0 and scratchpad <= maxblock) {
					fmgc.FMGCInternal.block = scratchpad;
					fmgc.FMGCInternal.blockSet = 1;
					if (fmgc.FMGCInternal.zfwSet) {
						fmgc.FMGCInternal.tow = num(fmgc.FMGCInternal.zfw + fmgc.FMGCInternal.block - fmgc.FMGCInternal.taxiFuel);
						fmgc.FMGCInternal.fuelRequest = 1;
						fmgc.FMGCInternal.fuelCalculating = 1;
						fmgc.fuelCalculating.setValue(1);
						fmgc.FMGCInternal.blockCalculating = 0;
						fmgc.blockCalculating.setValue(0);
						fmgc.FMGCInternal.blockConfirmed = 1;
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
		if (scratchpad == "" and fmgc.FMGCInternal.zfwSet and !fmgc.FMGCInternal.fuelRequest) {
			fmgc.FMGCInternal.fuelRequest = 1;
			fmgc.FMGCInternal.blockCalculating = 1;
			fmgc.blockCalculating.setValue(1);
		} else if (scratchpad == "" and fmgc.FMGCInternal.zfwSet and fmgc.FMGCInternal.fuelRequest and !fmgc.FMGCInternal.blockConfirmed and !fmgc.FMGCInternal.blockCalculating) {
			fmgc.FMGCInternal.blockConfirmed = 1;
			fmgc.FMGCInternal.fuelCalculating = 1;
			fmgc.fuelCalculating.setValue(1);
		} else {
			mcdu_message(i, "NOT ALLOWED");
		}
	} else if (key == "R5" and !fmgc.FMGCInternal.fuelCalculating) {
		if (scratchpad == "CLR") {
			fmgc.FMGCInternal.tripWind = "HD000";
			fmgc.FMGCInternal.tripWindValue = 0;
			if (fmgc.FMGCInternal.blockConfirmed) {
				fmgc.FMGCInternal.fuelCalculating = 1;
				fmgc.fuelCalculating.setValue(1);
			}
			mcdu_scratchpad.scratchpads[i].empty();
		} else {
			if (find("TL", scratchpad) != -1 or find("HD", scratchpad) != -1) {
				var effwind = substr(scratchpad, 2);
				if (int(effwind) != nil and effwind >= 0 and effwind <= 500) {
					fmgc.FMGCInternal.tripWind = scratchpad;
					fmgc.FMGCInternal.tripWindValue = effwind;
					if (fmgc.FMGCInternal.blockConfirmed) {
						fmgc.FMGCInternal.fuelCalculating = 1;
						fmgc.fuelCalculating.setValue(1);
					}
					mcdu_scratchpad.scratchpads[i].empty();
				} else {
					mcdu_message(i, "NOT ALLOWED");
				}
			} else if (find("-", scratchpad) != -1 or find("+", scratchpad) != -1 or find("T", scratchpad) != -1 or find("H", scratchpad) != -1) {
				var effwind = substr(scratchpad, 1);
				if (int(effwind) != nil and effwind >= 0 and effwind <= 500) {
					fmgc.FMGCInternal.tripWind = scratchpad;
					fmgc.FMGCInternal.tripWindValue = effwind;
					if (fmgc.FMGCInternal.blockConfirmed) {
						fmgc.FMGCInternal.fuelCalculating = 1;
						fmgc.fuelCalculating.setValue(1);
					}
					mcdu_scratchpad.scratchpads[i].empty();
				} else {
					mcdu_message(i, "NOT ALLOWED");
				}
			} else {
				if (num(scratchpad) != nil and scratchpad >= 0 and scratchpad <= 500) {
					fmgc.FMGCInternal.tripWind = scratchpad;
					fmgc.FMGCInternal.tripWindValue = scratchpad;
					if (fmgc.FMGCInternal.blockConfirmed) {
						fmgc.FMGCInternal.fuelCalculating = 1;
						fmgc.fuelCalculating.setValue(1);
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
