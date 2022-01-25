# A3XX mCDU by Joshua Davidson (Octal450), Jonathan Redpath, and Matthew Maring (mattmaring)

# Copyright (c) 2020 Josh Davidson (Octal450)
# Copyright (c) 2020 Matthew Maring (mattmaring)

# TODO - DepArp elevation or current elevation (on ground only!!) ->  math.round(fmgc.flightPlanController.flightplans[2].departure.elevation * M2FT))

var doneMessageDisag = 0;
var perfTOCheckVSpeedsConsistency = func(i) {
	if (fmgc.FMGCInternal.v1set == 1 and fmgc.FMGCInternal.vrset == 1 and fmgc.FMGCInternal.v2set == 1) {
		if (!(fmgc.FMGCInternal.v1 <= fmgc.FMGCInternal.vr and fmgc.FMGCInternal.vr <= fmgc.FMGCInternal.v2)) {
			if (doneMessageDisag) {
				mcdu_scratchpad.messageQueues[i].deleteWithText("V1/VR/V2 DISAGREE");
			}
			mcdu_scratchpad.messageQueues[i].addNewMsg(mcdu_scratchpad.MessageController.getTypeIIMsgByText("V1/VR/V2 DISAGREE"));
			doneMessageDisag = 1;
		}
	}
}

# VMCA 109.5 at 0ft
# VMCG 106.5 at 0ft all conf

var VMCA = props.globals.getNode("/FMGC/internal/vmca-kt");
var VMCG = props.globals.getNode("/FMGC/internal/vmcg-kt");

# When ZFW, BLOCK, or CONF are entered
# Above or takeoff thrust (FLEX or throttle) modified
# Engines started
var doneMessageToLow = 0;
var perfTOCheckVSpeedsLimitations = func(i) {
	if (fmgc.FMGCInternal.v1 < VMCG.getValue() or fmgc.FMGCInternal.vr < (VMCA.getValue() * 1.05) or fmgc.FMGCInternal.v2 < (VMCA.getValue() * 1.10)) {
		if (doneMessageToLow) {
			mcdu_scratchpad.messageQueues[i].deleteWithText("TO SPEEDS TOO LOW");
		}
		mcdu_scratchpad.messageQueues[i].addNewMsg(mcdu_scratchpad.MessageController.getTypeIIMsgByText("TO SPEEDS TOO LOW"));
		doneMessageToLow = 1;
	}
	#else if (Vr<KVr*VS1G or V2<KV2*VS1G) mcdu_messageTypeII(i,"TO SPEEDS TOO LOW"); #TODO - check to VS1G and look constant KVr KV2 on manual, not own by me :/
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
			setprop("/it-autoflight/settings/togaspd", 157);
			mcdu_scratchpad.scratchpads[i].empty();
		} else {
			var tfs = size(scratchpad);
			if (tfs == 3) {
				if (int(scratchpad) != nil and scratchpad >= 100 and scratchpad <= 350) {
					fmgc.FMGCInternal.v2 = scratchpad;
					fmgc.FMGCInternal.v2set = 1;
					fmgc.updatePitchArm2();
					setprop("/it-autoflight/settings/togaspd", scratchpad);
					mcdu_scratchpad.scratchpads[i].empty();

					perfTOCheckVSpeedsConsistency(i); 
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
			setprop("/systems/thrust/clbreduc-ft", 1500);
			setprop("/FMGC/internal/accel-agl-ft", 1500);
			setprop("MCDUC/thracc-set", 0);
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

				if (int(thrred) != nil and (thrreds >= 3 and thrreds <= 5) and thrred >= 400 and thrred <= 39000 and int(acc) != nil and (accs == 3 or accs == 4 or accs == 5) and acc >= 400 and acc <= 39000) {

					if (thrred<=acc) { # validation
						setprop("/systems/thrust/clbreduc-ft", int(thrred / 10) * 10);
						setprop("/FMGC/internal/accel-agl-ft", int(acc / 10) * 10);
						setprop("MCDUC/thracc-set", 1);
						mcdu_scratchpad.scratchpads[i].empty();
					} else {
						mcdu_message(i, "NOT ALLOWED");	
					}
				} else if (thrreds == 0 and int(acc) != nil and (accs >= 3 and accs <= 5) and acc >= 400 and acc <= 39000) {
					setprop("/FMGC/internal/accel-agl-ft", int(acc / 10) * 10);
					mcdu_scratchpad.scratchpads[i].empty();
				} else {
					mcdu_message(i, "NOT ALLOWED");
				}
			} else if (num(scratchpad) != nil and (tfs >= 3 and tfs <= 5) and scratchpad >= 400 and scratchpad <= 39000) {
				setprop("/systems/thrust/clbreduc-ft", int(scratchpad / 10) * 10);
				mcdu_scratchpad.scratchpads[i].empty();
			} else {
				mcdu_message(i, "NOT ALLOWED");
			}
		}
	} else if (key == "R3" and modifiable) {
		if (scratchpad == "CLR") {
			setprop("/FMGC/internal/to-flap", 0);
			setprop("/FMGC/internal/to-ths", "0.0");
			setprop("/FMGC/internal/flap-ths-set", 0);
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
				if (flaps == 0 and getprop("/FMGC/internal/flap-ths-set")) {
					if (trims == 5 and find("DN", trim) != -1 and validtrima) {
						setprop("/FMGC/internal/to-ths", -1 * trima);
						mcdu_scratchpad.scratchpads[i].empty();
					} else if (trims == 5 and find("DN", trim) != -1 and validtrimb) {
						setprop("/FMGC/internal/to-ths", -1 * trimb);
						mcdu_scratchpad.scratchpads[i].empty();
					} else if (trims == 5 and find("UP", trim) != -1 and validtrima) {
						setprop("/FMGC/internal/to-ths", trima);
						mcdu_scratchpad.scratchpads[i].empty();
					} else if (trims == 5 and find("UP", trim) != -1 and validtrimb) {
						setprop("/FMGC/internal/to-ths", trimb);
						mcdu_scratchpad.scratchpads[i].empty();
					} else {
						mcdu_message(i, "NOT ALLOWED");
					}
				} else if (flaps == 1 and num(flap) != nil and flap >= 0 and flap <= 3) {
					if (trims == 5 and find("DN", trim) != -1 and validtrima) {
						setprop("/FMGC/internal/to-flap", flap);
						setprop("/FMGC/internal/to-ths", -1 * trima);
						setprop("/FMGC/internal/flap-ths-set", 1);
						mcdu_scratchpad.scratchpads[i].empty();
					} else if (trims == 5 and find("DN", trim) != -1 and validtrimb) {
						setprop("/FMGC/internal/to-flap", flap);
						setprop("/FMGC/internal/to-ths", -1 * trimb);
						setprop("/FMGC/internal/flap-ths-set", 1);
						mcdu_scratchpad.scratchpads[i].empty();
					} else if (trims == 5 and find("UP", trim) != -1 and validtrima) {
						setprop("/FMGC/internal/to-flap", flap);
						setprop("/FMGC/internal/to-ths", trima);
						setprop("/FMGC/internal/flap-ths-set", 1);
						mcdu_scratchpad.scratchpads[i].empty();
					} else if (trims == 5 and find("UP", trim) != -1 and validtrimb) {
						setprop("/FMGC/internal/to-flap", flap);
						setprop("/FMGC/internal/to-ths", trimb);
						setprop("/FMGC/internal/flap-ths-set", 1);
						mcdu_scratchpad.scratchpads[i].empty();
					} else {
						mcdu_message(i, "NOT ALLOWED");
					}
				} else {
					mcdu_message(i, "NOT ALLOWED");
				}
			} else if (size(scratchpad) == 1 and num(scratchpad) != nil and scratchpad >= 0 and scratchpad <= 3) {
				setprop("/FMGC/internal/to-flap", scratchpad);
				if (!getprop("/FMGC/internal/flap-ths-set")) {
					setprop("/FMGC/internal/flap-ths-set", 1);
				}
				mcdu_scratchpad.scratchpads[i].empty();
			} else {
				mcdu_message(i, "NOT ALLOWED");
			}
		}
	} else if (key == "R4" and modifiable) {
		if (scratchpad == "CLR") {
			setprop("/FMGC/internal/flex", 0);
			setprop("/FMGC/internal/flex-set", 0);
			mcdu_scratchpad.scratchpads[i].empty();
		} else {
			var tfs = size(scratchpad);
			if (tfs == 1 or tfs == 2) {
				if (int(scratchpad) != nil and scratchpad >= 0 and scratchpad <= 99) {
					setprop("/FMGC/internal/flex", scratchpad);
					setprop("/FMGC/internal/flex-set", 1);
					var flex_calc = getprop("/FMGC/internal/flex") - getprop("environment/temperature-degc");
					setprop("/FMGC/internal/flex-cmd", flex_calc);
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
