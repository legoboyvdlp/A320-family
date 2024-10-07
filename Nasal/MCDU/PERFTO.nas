# A3XX mCDU by Joshua Davidson (Octal450), Jonathan Redpath, and Matthew Maring (mattmaring)

# Copyright (c) 2024 Josh Davidson (Octal450)
# Copyright (c) 2020 Matthew Maring (mattmaring)

# TODO - DepArp elevation or current elevation (on ground only!!) ->  math.round(fmgc.flightPlanController.flightplans[2].departure.elevation * M2FT))

var doneMessageCheck = 0;
var perfToCheckTakeoffData = func(i) {
	if (fmgc.FMGCInternal.v1set and fmgc.FMGCInternal.vrset and fmgc.FMGCInternal.v2set) {
		if (doneMessageCheck) {
			mcdu_scratchpad.messageQueues[i].deleteWithText("CHECK TAKE OFF DATA");
		}
		mcdu_scratchpad.messageQueues[i].addNewMsg(mcdu_scratchpad.MessageController.getTypeIIMsgByText("CHECK TAKE OFF DATA"));
		doneMessageCheck = 1;
	}
}

var doneMessageDisag = 0;
var perfTOCheckVSpeedsConsistency = func(i) {
	if (fmgc.FMGCInternal.v1set and fmgc.FMGCInternal.vrset and fmgc.FMGCInternal.v2set) {
		if (!(fmgc.FMGCInternal.v1 <= fmgc.FMGCInternal.vr and fmgc.FMGCInternal.vr <= fmgc.FMGCInternal.v2)) {
			if (doneMessageDisag) {
				mcdu_scratchpad.messageQueues[i].deleteWithText("V1/VR/V2 DISAGREE");
			}
			mcdu_scratchpad.messageQueues[i].addNewMsg(mcdu_scratchpad.MessageController.getTypeIIMsgByText("V1/VR/V2 DISAGREE"));
			doneMessageDisag = 1;
		}
	}
}

var VMCA = props.globals.getNode("/FMGC/internal/vmca-kt");
var VMCG = props.globals.getNode("/FMGC/internal/vmcg-kt");

var chooseVS1G = func() {
	if (fmgc.FMGCInternal.toFlap == 1) {
		return fmgc.FMGCInternal.vs1g_conf_1f;
	} elsif (fmgc.FMGCInternal.toFlap == 2) {
		return fmgc.FMGCInternal.vs1g_conf_2;
	} elsif (fmgc.FMGCInternal.toFlap == 3) {
		return fmgc.FMGCInternal.vs1g_conf_3;
	}
};

var doneMessageToLow = 0;
var perfTOCheckVSpeedsLimitations = func(i) {
	if (fmgc.FMGCInternal.toFlapThsSet and fmgc.FMGCInternal.zfwSet and fmgc.FMGCInternal.blockSet and fmgc.FMGCInternal.v1set and fmgc.FMGCInternal.vrset and fmgc.FMGCInternal.v2set) {
		if (fmgc.FMGCInternal.v1 < VMCG.getValue() or fmgc.FMGCInternal.vr < (VMCA.getValue() * 1.05) or fmgc.FMGCInternal.v2 < (VMCA.getValue() * 1.10) or fmgc.FMGCInternal.v2 < (1.13 * chooseVS1G())) {
			if (doneMessageToLow) {
				mcdu_scratchpad.messageQueues[i].deleteWithText("T.O SPEEDS TOO LOW");
			}
			mcdu_scratchpad.messageQueues[i].addNewMsg(mcdu_scratchpad.MessageController.getTypeIIMsgByText("T.O SPEEDS TOO LOW"));
			doneMessageToLow = 1;
		}
	}
}

var perfTOInput = func(key, i) {	
	var modifiable = (fmgc.FMGCInternal.phase == 1) ? 0 : 1;
	var scratchpad = mcdu_scratchpad.scratchpads[i].scratchpad;

	if (key == "L1" and modifiable) {		
		if (scratchpad == "CLR") {
			fmgc.FMGCInternal.v1 = 0;
			fmgc.FMGCInternal.v1set = 0;
			fmgc.FMGCNodes.v1.setValue(0);
			fmgc.FMGCNodes.v1set.setValue(0);
			mcdu_scratchpad.scratchpads[i].empty();
		} else {
			var tfs = size(scratchpad);
			if (tfs == 3) {
				if (int(scratchpad) != nil and scratchpad >= 100 and scratchpad <= 350) {
					fmgc.FMGCInternal.v1 = scratchpad;
					fmgc.FMGCInternal.v1set = 1;
					
					# for sounds:
					fmgc.FMGCNodes.v1.setValue(scratchpad);
					fmgc.FMGCNodes.v1set.setValue(1);
					mcdu_scratchpad.scratchpads[i].empty();

					perfTOCheckVSpeedsConsistency(i); 
					perfTOCheckVSpeedsLimitations(i);
				} else {
					mcdu_message(i, "NOT ALLOWED");
				}
			} else {
				mcdu_message(i, "NOT ALLOWED");
			}
		}
	} else if (key == "L2" and modifiable) {
		if (scratchpad == "CLR") {
			fmgc.FMGCInternal.vr = 0;
			fmgc.FMGCInternal.vrset = 0;
			mcdu_scratchpad.scratchpads[i].empty();
		} else {
			var tfs = size(scratchpad);
			if (tfs == 3) {
				if (int(scratchpad) != nil and scratchpad >= 100 and scratchpad <= 350) {
					fmgc.FMGCInternal.vr = scratchpad;
					fmgc.FMGCInternal.vrset = 1;
					mcdu_scratchpad.scratchpads[i].empty();

					perfTOCheckVSpeedsConsistency(i); 
					perfTOCheckVSpeedsLimitations(i);
				} else {
					mcdu_message(i, "NOT ALLOWED");
				}
			} else {
				mcdu_message(i, "NOT ALLOWED");
			}
		}
	} else if (key == "L3" and modifiable) {
		if (scratchpad == "CLR") {
			fmgc.FMGCInternal.v2 = 0;
			fmgc.FMGCInternal.v2set = 0;
			mcdu_scratchpad.scratchpads[i].empty();
		} else {
			var tfs = size(scratchpad);
			if (tfs == 3) {
				if (int(scratchpad) != nil and scratchpad >= 100 and scratchpad <= 350) {
					fmgc.FMGCInternal.v2 = scratchpad;
					fmgc.FMGCInternal.v2set = 1;
					fmgc.setFmaText("pitchMode2Armed", fmgc.FMGCInternal.v2set ? "CLB" : " ", fmgc.genericCallback, "pitchMode2ArmedTime");
					mcdu_scratchpad.scratchpads[i].empty();

					perfTOCheckVSpeedsConsistency(i); 
					perfTOCheckVSpeedsLimitations(i);
				} else {
					mcdu_message(i, "NOT ALLOWED");
				}
			} else {
				mcdu_message(i, "NOT ALLOWED");
			}
		}
	} else if (key == "L4") {
		if (scratchpad == "CLR") {
			fmgc.FMGCInternal.transAlt = 18000;
			fmgc.FMGCInternal.transAltSet = 0;
			mcdu_scratchpad.scratchpads[i].empty();
		} else {
			var tfs = size(scratchpad);
			if (int(scratchpad) != nil and (tfs == 4 or tfs <= 5) and scratchpad >= 1000 and scratchpad <= 39000) {
				fmgc.FMGCInternal.transAlt = int(scratchpad / 10) * 10;
				fmgc.FMGCInternal.transAltSet = 1;
				mcdu_scratchpad.scratchpads[i].empty();
			} else {
				mcdu_message(i, "NOT ALLOWED");
			}
		}
	} else if (key == "L5" and modifiable) {
		if (scratchpad == "CLR") {
			if (fmgc.FMGCInternal.depApt != "") {
				if (getprop("/options/company-options/default-accel-agl")) {
					fmgc.FMGCInternal.AccelAlt = getprop("/options/company-options/default-accel-agl") + fmgc.FMGCInternal.depAptElev;
				} else {
					# to check: minimum value if no company option is 400 ft above dep aerodrome
					fmgc.FMGCInternal.AccelAlt = 400 + fmgc.FMGCInternal.depAptElev;
				}

				if (getprop("/options/company-options/default-thrRed-agl")) {
					fmgc.FMGCInternal.thrRedAlt = getprop("/options/company-options/default-thrRed-agl") + fmgc.FMGCInternal.depAptElev;
				} else {
					# to check: minimum value if no company option is 400 ft above dep aerodrome
					fmgc.FMGCInternal.thrRedAlt = 400 + fmgc.FMGCInternal.depAptElev;
				}
			} else {
				fmgc.FMGCInternal.AccelAlt = 1500; # todo: default accel if no depApt / probably doesn't exist?
				fmgc.FMGCInternal.thrRedAlt = 1500; # todo: default ThrRed if no depApt / probably doesn't exist?
			}
			setprop("/FMGC/internal/accel-agl-ft", fmgc.FMGCInternal.AccelAlt);
			setprop("/fdm/jsbsim/fadec/clbreduc-ft", fmgc.FMGCInternal.thrRedAlt);
			setprop("MCDUC/thracc-set", 0);
			setprop("MCDUC/acc-set-manual", 0);
			setprop("MCDUC/thrRed-set-manual", 0);

			mcdu_scratchpad.scratchpads[i].empty();
		} else {
			var tfs = size(scratchpad);
			if (find("/", scratchpad) != -1) {
				var thracc = split("/", scratchpad);
				var thrred = thracc[0];
				var thrreds = size(thrred);
				var acc = thracc[1];
				var accs = size(acc);

				#TODO - manual check - four digit alwway 0000 - default = runaway_elevation + 800 ft, min values runaway_elevation+400ft
				if (int(thrred) != nil and (thrreds >= 3 and thrreds <= 5) and thrred >= fmgc.minThrRed and thrred <= 39000 and int(acc) != nil and (accs >= 3 and accs <= 5) and acc >= fmgc.minAccelAlt and acc <= 39000) {
						setprop("/fdm/jsbsim/fadec/clbreduc-ft", int(thrred / 10) * 10);
						setprop("/FMGC/internal/accel-agl-ft", int(acc / 10) * 10);
						setprop("MCDUC/thracc-set", 1);
						setprop("MCDUC/acc-set-manual", 1);
						setprop("MCDUC/thrRed-set-manual", 1);
						mcdu_scratchpad.scratchpads[i].empty();
				} else if (thrreds == 0 and int(acc) != nil and (accs >= 3 and accs <= 5) and acc >= fmgc.minAccelAlt and acc <= 39000) {
					setprop("/FMGC/internal/accel-agl-ft", int(acc / 10) * 10);
					setprop("MCDUC/acc-set-manual", 1);
					mcdu_scratchpad.scratchpads[i].empty();
				} else {
					mcdu_message(i, "FORMAT ERROR");
				}
			} else if (num(scratchpad) != nil and (tfs >= 3 and tfs <= 5) and scratchpad >= fmgc.minThrRed and scratchpad <= 39000) {
				setprop("/fdm/jsbsim/fadec/clbreduc-ft", int(scratchpad / 10) * 10);
				setprop("MCDUC/thrRed-set-manual", 1);
				mcdu_scratchpad.scratchpads[i].empty();
			} else {
				mcdu_message(i, "FORMAT ERROR");
			}
		}
	} else if (key == "R3" and modifiable) {
		if (scratchpad == "CLR") {
			fmgc.FMGCInternal.toFlap = 0;
			fmgc.FMGCInternal.toThs = 0;
			fmgc.FMGCInternal.toFlapThsSet = 0;
			mcdu_scratchpad.scratchpads[i].empty();
		} else {
			if (find("/", scratchpad) != -1) {
				var flapths = split("/", scratchpad);
				var flap = flapths[0];
				var flaps = size(flap);
				var trim = flapths[1];
				var trims = size(trim);
				var trima = substr(trim, 2);
				var trimb = substr(trim, 0, 3);
				
				var validtrima = num(trima) != nil and num(trima) >= 0 and num(trima) <= 7.0;
				var validtrimb = num(trimb) != nil and num(trimb) >= 0 and num(trimb) <= 7.0;
				
				if (flaps == 0 and fmgc.FMGCInternal.toFlapThsSet) {
					if (trims == 5 and find("DN", trim) != -1 and validtrima) {
						fmgc.FMGCInternal.toThs = -1 * trima;
						mcdu_scratchpad.scratchpads[i].empty();
						perfTOCheckVSpeedsLimitations(i);
						perfToCheckTakeoffData(i);
					} else if (trims == 5 and find("DN", trim) != -1 and validtrimb) {
						fmgc.FMGCInternal.toThs = -1 * trimb;
						mcdu_scratchpad.scratchpads[i].empty();
						perfTOCheckVSpeedsLimitations(i);
						perfToCheckTakeoffData(i);
					} else if (trims == 5 and find("UP", trim) != -1 and validtrima) {
						fmgc.FMGCInternal.toThs = trima;
						mcdu_scratchpad.scratchpads[i].empty();
						perfTOCheckVSpeedsLimitations(i);
						perfToCheckTakeoffData(i);
					} else if (trims == 5 and find("UP", trim) != -1 and validtrimb) {
						fmgc.FMGCInternal.toThs = trimb;
						mcdu_scratchpad.scratchpads[i].empty();
						perfTOCheckVSpeedsLimitations(i);
						perfToCheckTakeoffData(i);
					} else {
						mcdu_message(i, "NOT ALLOWED");
					}
				} else if (flaps == 1 and num(flap) != nil and flap >= 0 and flap <= 3) {
					if (trims == 5 and find("DN", trim) != -1 and validtrima) {
						fmgc.FMGCInternal.toFlap = flap;
						fmgc.FMGCInternal.toThs = -1 * trima;
						mcdu_scratchpad.scratchpads[i].empty();
						perfTOCheckVSpeedsLimitations(i);
						if (fmgc.FMGCInternal.toFlapThsSet) {
							perfToCheckTakeoffData(i);
						}
						fmgc.FMGCInternal.toFlapThsSet = 1;
					} else if (trims == 5 and find("DN", trim) != -1 and validtrimb) {
						fmgc.FMGCInternal.toFlap = flap;
						fmgc.FMGCInternal.toThs = -1 * trimb;
						mcdu_scratchpad.scratchpads[i].empty();
						perfTOCheckVSpeedsLimitations(i);
						if (fmgc.FMGCInternal.toFlapThsSet) {
							perfToCheckTakeoffData(i);
						}
						fmgc.FMGCInternal.toFlapThsSet = 1;
					} else if (trims == 5 and find("UP", trim) != -1 and validtrima) {
						fmgc.FMGCInternal.toFlap = flap;
						fmgc.FMGCInternal.toThs = trima;
						mcdu_scratchpad.scratchpads[i].empty();
						perfTOCheckVSpeedsLimitations(i);
						if (fmgc.FMGCInternal.toFlapThsSet) {
							perfToCheckTakeoffData(i);
						}
						fmgc.FMGCInternal.toFlapThsSet = 1;
					} else if (trims == 5 and find("UP", trim) != -1 and validtrimb) {
						fmgc.FMGCInternal.toFlap = flap;
						fmgc.FMGCInternal.toThs = trimb;
						mcdu_scratchpad.scratchpads[i].empty();
						perfTOCheckVSpeedsLimitations(i);
						if (fmgc.FMGCInternal.toFlapThsSet) {
							perfToCheckTakeoffData(i);
						}
						fmgc.FMGCInternal.toFlapThsSet = 1;
					} else {
						mcdu_message(i, "NOT ALLOWED");
					}
				} else {
					mcdu_message(i, "NOT ALLOWED");
				}
			} else if (size(scratchpad) == 1 and num(scratchpad) != nil and scratchpad >= 0 and scratchpad <= 3) {
				fmgc.FMGCInternal.toFlap = scratchpad;
				mcdu_scratchpad.scratchpads[i].empty();
				perfTOCheckVSpeedsLimitations(i);
				if (fmgc.FMGCInternal.toFlapThsSet) {
					perfToCheckTakeoffData(i);
				}
				fmgc.FMGCInternal.toFlapThsSet = 1;
			} else {
				mcdu_message(i, "NOT ALLOWED");
			}
		}
	} else if (key == "R4" and modifiable) {
		if (scratchpad == "CLR") {
			systems.FADEC.Limit.flexTemp.setValue(30);
			systems.FADEC.Limit.flexActiveCmd.setBoolValue(0);
			mcdu_scratchpad.scratchpads[i].empty();
		} else {
			var tfs = size(scratchpad);
			if (tfs == 1 or tfs == 2) {
				if (int(scratchpad) != nil and scratchpad >= 0 and scratchpad <= 99) {
					systems.FADEC.Limit.flexTemp.setValue(scratchpad);
					systems.FADEC.Limit.flexActiveCmd.setBoolValue(1);
					perfTOCheckVSpeedsLimitations(i);
					perfToCheckTakeoffData(i);
					mcdu_scratchpad.scratchpads[i].empty();
				} else {
					mcdu_message(i, "NOT ALLOWED");
				}
			} else {
				mcdu_message(i, "NOT ALLOWED");
			}
		}
	} else if (key == "R5" and modifiable) {
		if (scratchpad == "CLR") {
			setprop("/FMGC/internal/eng-out-reduc", "1500");
			setprop("MCDUC/reducacc-set", 0);
			mcdu_scratchpad.scratchpads[i].empty();
		} else {
			var tfs = size(scratchpad);
			if (int(scratchpad) != nil and (tfs == 4 or tfs == 5) and scratchpad >= 1000 and scratchpad <= 39000) {
				setprop("/FMGC/internal/eng-out-reduc", scratchpad);
				setprop("MCDUC/reducacc-set", 1);
				mcdu_scratchpad.scratchpads[i].empty();
			} else {
				mcdu_message(i, "NOT ALLOWED");
			}
		}
	} else if (key == "R6") {
		setprop("MCDU[" ~ i ~ "]/page", "PERFCLB");
	} else {
		mcdu_message(i, "NOT ALLOWED");
	}
}
