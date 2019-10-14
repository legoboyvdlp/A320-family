# A3XX ECAM
# Joshua Davidson (Octal450)

# Copyright (c) 2019 Joshua Davidson (Octal450)

var stateL = 0;
var stateR = 0;
var thrustL = 0;
var thrustR = 0;
var elec = 0;
var speed = 0;
var wow = 0;
var altitude = 0;
var phase = 1;
var toPowerSet = 0;
var eng = "XX";
var eprlim = 0;
var n1lim = 0;
var mode = "XX";
var modeI = "XX";
var man_sel = 0;
var fault_sel = 0;
var fault_page = "";
var warnPhase = 1;
var page = "door";
var aileron = 0;
var elevator = 0;
var elapsedSec = 0;
var fctlCounting = 0;
var fctlTime = 0;
var showAPUPage = 0;
var APUMaster = 0;
var APURPM = 0;
var APUTime = 0;
var APUCounting = 0;
var engModeSel = 0;
var showENGPage = 0;
var ENGTime = 0;
var ENGCounting = 0;
var flapLever = 0;
var CRZTime = 0;
var CRZCondition = 0;
var CRZCounting = 0;
var agl = 0;
var ap_active = 0;
var athr_active = 0;
setprop("/ECAM/left-msg", "NONE");
setprop("/position/gear-agl-ft", 0);
# w = White, b = Blue, g = Green, a = Amber, r = Red

var ECAM = {
	init: func() {
		setprop("/ECAM/engine-start-time", 0);
		setprop("/ECAM/engine-start-time-switch", 0);
		setprop("/ECAM/to-memo-enable", 1);
		setprop("/ECAM/to-config", 0);
		setprop("/ECAM/ldg-memo-enable", 0);
		setprop("/systems/gear/landing-gear-warning-light", 0);
		setprop("/ECAM/Lower/page", "door");
		setprop("/ECAM/Lower/man-select", 0);
		setprop("/ECAM/Lower/fault-select", 0);
		setprop("/ECAM/Lower/fault-page", "");
		setprop("/ECAM/Lower/apu-timer", 0);
		setprop("/ECAM/Lower/eng-timer", 0);
		setprop("/ECAM/Lower/fctl-timer", 0);
		setprop("/ECAM/Lower/light/apu", 0);
		setprop("/ECAM/Lower/light/bleed", 0);
		setprop("/ECAM/Lower/light/cond", 0);
		setprop("/ECAM/Lower/light/door", 0);
		setprop("/ECAM/Lower/light/elec", 0);
		setprop("/ECAM/Lower/light/eng", 0);
		setprop("/ECAM/Lower/light/fctl", 0);
		setprop("/ECAM/Lower/light/fuel", 0);
		setprop("/ECAM/Lower/light/hyd", 0);
		setprop("/ECAM/Lower/light/press", 0);
		setprop("/ECAM/Lower/light/sts", 0);
		setprop("/ECAM/Lower/light/wheel", 0);
		setprop("/ECAM/Lower/light/clr", 0);
		setprop("/ECAM/warning-phase", 1);
		setprop("/ECAM/warning-phase-10-time", 0);
		setprop("/ECAM/ap-off-time", 0);
		setprop("/ECAM/athr-off-time", 0);
		setprop("/it-autoflight/output/ap-warning", 0);
		setprop("/it-autoflight/output/athr-warning", 0);
		var ap_off_time = getprop("/ECAM/ap-off-time");
		var athr_off_time = getprop("/ECAM/athr-off-time");
		LowerECAM.reset();
	},
	MSGclr: func() {
		setprop("/ECAM/ecam-checklist-active", 0);
		setprop("/ECAM/left-msg", "NONE");
		setprop("/ECAM/msg/line1", "");
		setprop("/ECAM/msg/line2", "");
		setprop("/ECAM/msg/line3", "");
		setprop("/ECAM/msg/line4", "");
		setprop("/ECAM/msg/line5", "");
		setprop("/ECAM/msg/line6", "");
		setprop("/ECAM/msg/line7", "");
		setprop("/ECAM/msg/line8", "");
		setprop("/ECAM/msg/linec1", "w");
		setprop("/ECAM/msg/linec2", "w");
		setprop("/ECAM/msg/linec3", "w");
		setprop("/ECAM/msg/linec4", "w");
		setprop("/ECAM/msg/linec5", "w");
		setprop("/ECAM/msg/linec6", "w");
		setprop("/ECAM/msg/linec7", "w");
		setprop("/ECAM/msg/linec8", "w");
		setprop("/ECAM/rightmsg/line1", "");
		setprop("/ECAM/rightmsg/line2", "");
		setprop("/ECAM/rightmsg/line3", "");
		setprop("/ECAM/rightmsg/line4", "");
		setprop("/ECAM/rightmsg/line5", "");
		setprop("/ECAM/rightmsg/line6", "");
		setprop("/ECAM/rightmsg/line7", "");
		setprop("/ECAM/rightmsg/line8", "");
		setprop("/ECAM/rightmsg/linec1", "w");
		setprop("/ECAM/rightmsg/linec2", "w");
		setprop("/ECAM/rightmsg/linec3", "w");
		setprop("/ECAM/rightmsg/linec4", "w");
		setprop("/ECAM/rightmsg/linec5", "w");
		setprop("/ECAM/rightmsg/linec6", "w");
		setprop("/ECAM/rightmsg/linec7", "w");
		setprop("/ECAM/rightmsg/linec8", "w");
	},
	loop: func() {
		stateL = getprop("/engines/engine[0]/state");
		stateR = getprop("/engines/engine[1]/state");
		thrustL = getprop("/systems/thrust/state1");
		thrustR = getprop("/systems/thrust/state2");
		elec = getprop("/systems/electrical/on");
		speed = getprop("/instrumentation/airspeed-indicator/indicated-speed-kt");
		wow = getprop("/gear/gear[0]/wow");
		eng = getprop("/options/eng");
		
		if (stateL == 3 and stateR == 3 and wow == 1) {
			if (getprop("/ECAM/engine-start-time-switch") != 1) {
				setprop("/ECAM/engine-start-time", getprop("/sim/time/elapsed-sec"));
				setprop("/ECAM/engine-start-time-switch", 1);
			}
		} else if (wow == 1) {
			if (getprop("/ECAM/engine-start-time-switch") != 0) {
				setprop("/ECAM/engine-start-time-switch", 0);
			}
		}
		
		if (getprop("/ECAM/warning-phase") >= 3) {
			setprop("/ECAM/to-memo-enable", 0);
		} else {
			setprop("/ECAM/to-memo-enable", 1);
		}
		
		if (getprop("/position/gear-agl-ft") <= 2000 and (getprop("/FMGC/status/phase") == 3 or getprop("/FMGC/status/phase") == 4 or getprop("/FMGC/status/phase") == 5) and wow == 0) {
			setprop("/ECAM/ldg-memo-enable", 1);
		} else if (getprop("/ECAM/left-msg") == "LDG-MEMO" and speed <= 80 and wow == 1) {
			setprop("/ECAM/ldg-memo-enable", 0);
		} else if (getprop("/ECAM/left-msg") != "LDG-MEMO") {
			setprop("/ECAM/ldg-memo-enable", 0);
		}
		
		if (stateL == 3 and stateR == 3 and getprop("/ECAM/engine-start-time") + 120 < getprop("/sim/time/elapsed-sec") and getprop("/ECAM/to-memo-enable") == 1 and wow == 1) {
			setprop("/ECAM/left-msg", "TO-MEMO");
		} elsif (getprop("/ECAM/ldg-memo-enable") == 1) {
			setprop("/ECAM/left-msg", "LDG-MEMO");
		} elsif (getprop("/ECAM/show-left-msg") == 1) {
			setprop("/ECAM/left-msg", "MSG"); # messages should have priority over memos - how?
		} else {
			setprop("/ECAM/left-msg", "NONE");
		}
		
		if (getprop("/ECAM/show-right-msg") == 1) {
			setprop("/ECAM/right-msg", "MSG");
		} else {
			setprop("/ECAM/right-msg", "NONE");
		}
		
		if (getprop("/controls/autobrake/mode") == 3 and getprop("/controls/lighting/no-smoking-sign") == 1 and getprop("/controls/lighting/seatbelt-sign") == 1 and getprop("/controls/flight/speedbrake-arm") == 1 and getprop("/controls/flight/flap-pos") > 0 
		and getprop("/controls/flight/flap-pos") < 5) {
			# Do nothing
		} else {
			setprop("/ECAM/to-config", 0);
		}
		
		if (eng == "IAE") {
			eprlim = getprop("/controls/engines/epr-limit");
			if (abs(getprop("/engines/engine[0]/epr-actual") - eprlim) <= 0.005 or abs(getprop("/engines/engine[0]/epr-actual") - eprlim) <= 0.005) {
				toPowerSet = 1;
			} else {
				toPowerSet = 0;
			}
		} else {
			n1lim = getprop("/controls/engines/n1-limit");
			if (abs(getprop("/engines/engine[0]/n1-actual") - n1lim) <= 0.1 or abs(getprop("/engines/engine[0]/n1-actual") - n1lim) <= 0.1) {
				toPowerSet = 1;
			} else {
				toPowerSet = 0;
			}
		}
		
		# AP / ATHR warnings
		if (ap_active == 1 and getprop("/it-autoflight/output/ap-warning") == 0) {
			ap_active = 0;
		} elsif (ap_active == 1 and getprop("/it-autoflight/output/ap-warning") == 1 and getprop("/sim/time/elapsed-sec") > (getprop("/ECAM/ap-off-time") + 9)) {
			ap_active = 0;
			setprop("/it-autoflight/output/ap-warning", 0);
		} elsif (ap_active == 0 and getprop("/it-autoflight/output/ap-warning") != 0) {
			ap_active = 1;
		}
		
		if (ap_active == 1 and getprop("/it-autoflight/output/ap-warning") == 1 and getprop("/sim/time/elapsed-sec") > (getprop("/ECAM/ap-off-time") + 3) and getprop("/ECAM/warnings/master-warning-light") == 1) {
			setprop("/ECAM/warnings/master-warning-light", 0);
		}
		
		if (getprop("/it-autoflight/output/ap-warning") == 2 and (getprop("/it-autoflight/output/ap1") == 1 or getprop("/it-autoflight/output/ap2") == 1)) {
			setprop("/it-autoflight/output/ap-warning", 0);
		}
		
		if (athr_active == 1 and getprop("/it-autoflight/output/athr-warning") == 0) {
			athr_active = 0;
		} elsif (athr_active == 1 and getprop("/it-autoflight/output/athr-warning") == 1 and getprop("/sim/time/elapsed-sec") > (getprop("/ECAM/athr-off-time") + 9)) {
			athr_active = 0;
			setprop("/it-autoflight/output/athr-warning", 0);
		} elsif (athr_active == 0 and getprop("/it-autoflight/output/athr-warning") != 0) {
			athr_active = 1;
		}
		
		
		if (athr_active == 1 and getprop("/it-autoflight/output/athr-warning") == 1 and getprop("/sim/time/elapsed-sec") > (getprop("/ECAM/athr-off-time") + 3) and getprop("/ECAM/warnings/master-caution-light") == 1) {
			setprop("/ECAM/warnings/master-caution-light", 0);
		}
		
		if (getprop("/it-autoflight/output/athr-warning") == 2 and getprop("/it-autoflight/output/athr") == 1) {
			setprop("/it-autoflight/output/athr-warning", 0);
		}
		
		
		# Warning Phases
		if (getprop("/systems/electrical/bus/ac-1") < 110 and getprop("/systems/electrical/bus/ac-2") < 110 and getprop("/systems/electrical/bus/ac-ess") < 110) { # Reset warning phases
			if (getprop("/ECAM/warning-phase") != 1) {
				setprop("/ECAM/warning-phase", 1);
			}
		} else {
			phase = getprop("/ECAM/warning-phase");
			mode = getprop("/modes/pfd/fma/pitch-mode");
			modeI = getprop("/it-autoflight/mode/vert");
			
			if (phase == 1 and (stateL == 3 or stateR == 3)) {
				setprop("/ECAM/warning-phase", 2);
			} else if (phase == 2 and toPowerSet) {
				setprop("/ECAM/warning-phase", 3);
			} else if (phase == 3 and speed >= 80) {
				setprop("/ECAM/warning-phase", 4);
			} else if (phase == 4 and getprop("/fdm/jsbsim/position/wow") == 0) { # Liftoff
				setprop("/ECAM/warning-phase", 5);
			} else if (phase == 5 and getprop("/position/gear-agl-ft") >= 1500) {
				setprop("/ECAM/warning-phase", 6);
			} else if (phase == 6 and getprop("/position/gear-agl-ft") < 800) {
				if (mode == "OP CLB" or mode == "CLB" or (modeI == "V/S" and getprop("/it-autoflight/input/vs") >= 100) or (modeI == "FPA" and getprop("/it-autoflight/input/fpa") >= 0.1)) {
					# Do not do this if we are climbing, not in FCOM, but prevents terrain  from causing early mode change. If this ends up using baro alt, not radio, then delete this if
				} else {
					setprop("/ECAM/warning-phase", 7);
				}
			} else if (phase == 7 and getprop("/fdm/jsbsim/position/wow") == 1) { # Touchdown
				setprop("/ECAM/warning-phase", 8);
			} else if (phase == 8 and speed < 80) {
				setprop("/ECAM/warning-phase", 9);
			} else if (phase == 9 and (stateL == 0 or stateR == 0)) {
				setprop("/ECAM/warning-phase", 10);
				setprop("/ECAM/warning-phase-10-time", getprop("/sim/time/elapsed-sec"));
			} else if (phase == 10 and getprop("/ECAM/warning-phase-10-time") + 300 < getprop("/sim/time/elapsed-sec")) { # After 5 mins, reset to phase 1
				setprop("/ECAM/warning-phase", 1);
			}
		}
		
		LowerECAM.loop();
	},
	toConfig: func() {
		stateL = getprop("/engines/engine[0]/state");
		stateR = getprop("/engines/engine[1]/state");
		wow = getprop("/gear/gear[0]/wow");
		
		if ((getprop("/ECAM/warning-phase") == 2 or getprop("/ECAM/warning-phase") == 9) and wow == 1 and (stateL == 3 or stateR == 3) and getprop("/ECAM/left-msg") != "TO-MEMO") {
			setprop("/ECAM/to-memo-enable", 1);
			setprop("/ECAM/engine-start-time", getprop("/ECAM/engine-start-time") - 120);
		}
		
		if (getprop("/controls/autobrake/mode") == 3 and getprop("/controls/switches/no-smoking-sign") == 1 and getprop("/controls/switches/seatbelt-sign") == 1 and getprop("/controls/flight/speedbrake-arm") == 1 and getprop("/controls/flight/flap-pos") > 0 
		and getprop("/controls/flight/flap-pos") < 5) {
			setprop("/ECAM/to-config", 1);
		}
	},
};

ECAM.MSGclr();

# Lower ECAM Pages

var LowerECAM = {
	button: func(b) {
		man_sel = getprop("/ECAM/Lower/man-select");
		if (b == "clr" and getprop("/it-autoflight/output/athr-warning") == 2) {
			setprop("/it-autoflight/output/athr-warning", 0);
			setprop("/ECAM/Lower/light/clr", 0);
			setprop("/ECAM/warnings/master-caution-light", 0);
			return;
		}

		if (b == "clr" and getprop("/it-autoflight/output/ap-warning") == 2) {
			setprop("/it-autoflight/output/ap-warning", 0);
			setprop("/ECAM/Lower/light/clr", 0);
			setprop("/ECAM/warnings/master-warning-light", 0);
			return;
		}

		if (b == "clr") {
			ecam.ECAM_controller.clear();
			return;
		}
		
		if (getprop("/ECAM/Lower/fault-select") == 0) {
			if (b != "clr") {
				if (!man_sel) {
					setprop("/ECAM/Lower/man-select", 1);
					setprop("/ECAM/Lower/page", b);
					setprop("/ECAM/Lower/light/" ~ b, 1);
				} else {
					if (b == getprop("/ECAM/Lower/page")) {
						setprop("/ECAM/Lower/man-select", 0);
						LowerECAM.loop();
						setprop("/ECAM/Lower/light/" ~ b, 0);
					} else {
						setprop("/ECAM/Lower/light/" ~ getprop("/ECAM/Lower/page"), 0);
						setprop("/ECAM/Lower/page", b);
						setprop("/ECAM/Lower/light/" ~ b, 1);
					}
				}
			} elsif (getprop("/ECAM/Lower/light/clr") == 1) {
				setprop("/ECAM/Lower/light/clr", 0);
			}
		} else {
			if (b == "clr") {
				setprop("/ECAM/Lower/light/clr", 0);
				setprop("/ECAM/Lower/fault-select", 0);
				setprop("/ECAM/Lower/fault-page", "");
				LowerECAM.loop();
			} elsif (!man_sel) {
				setprop("/ECAM/Lower/man-select", 1);
				setprop("/ECAM/Lower/page", b);
				setprop("/ECAM/Lower/light/" ~ b, 1);
			} else {
				if (b == getprop("/ECAM/Lower/page")) {
					setprop("/ECAM/Lower/man-select", 0);
					setprop("/ECAM/Lower/light/" ~ b, 0);
					setprop("/ECAM/Lower/fault-select", 1);
					setprop("/ECAM/Lower/page", getprop("/ECAM/Lower/fault-page"));
				} else {
					setprop("/ECAM/Lower/light/" ~ getprop("/ECAM/Lower/page"), 0);
					setprop("/ECAM/Lower/page", b);
					setprop("/ECAM/Lower/light/" ~ b, 1);
				}
			}
		}
	},
	loop: func() {
		man_sel = getprop("/ECAM/Lower/man-select");
		fault_sel = getprop("/ECAM/Lower/fault-select");
		fault_page = getprop("/ECAM/Lower/fault-page");
		page = getprop("/ECAM/Lower/page");
		
		if (!man_sel) {
			if (!fault_sel) {
				warnPhase = getprop("/ECAM/warning-phase");
				aileron = getprop("/fdm/jsbsim/fbw/aileron-sidestick");
				elevator = getprop("/fdm/jsbsim/fbw/elevator-sidestick");
				APUMaster = getprop("/controls/APU/master");
				APURPM = getprop("/systems/apu/rpm");
				stateL = getprop("/engines/engine[0]/state");
				stateR = getprop("/engines/engine[1]/state");
				engModeSel = getprop("/controls/engines/engine-start-switch");
				elapsedSec = getprop("/sim/time/elapsed-sec");
				
				if (warnPhase == 2) {
					if (abs(aileron) > 0.3 or abs(elevator) > 0.3) {
						fctlTime = elapsedSec;
						fctlCounting = 1;
					} else if (fctlCounting) {
						if (fctlTime + 20 < elapsedSec) {
							fctlCounting = 0;
						}
					}
				} else {
					fctlCounting = 0;
				}

				if (APURPM > 95) {
					if (APUTime + 10 < elapsedSec) {
						APUCounting = 0;
					}
				} else {
					if (APUMaster) {
						APUTime = elapsedSec;
						APUCounting = 1;
					} else {
						APUCounting = 0;
					}
				}

				if ((APURPM <= 95 or APUCounting) and APUMaster) {
					showAPUPage = 1;
				} else {
					showAPUPage = 0;
				}

				if (stateL == 3 or stateR == 3) {
					if (ENGCounting and ENGTime + 10 < elapsedSec) {
						ENGCounting = 0;
					}
				}

				if (((stateL > 0 and stateL != 3) or (stateR > 0 and stateR != 3)) and engModeSel == 2) {
					ENGTime = elapsedSec;
					ENGCounting = 1;
				} else if ((stateL == 0 and stateR == 0) or engModeSel == 1) {
					ENGCounting = 0;
				}
				
				if (ENGCounting or engModeSel == 0) {
					showENGPage = 1;
				} else {
					showENGPage = 0;
				}

				if (warnPhase == 1 or warnPhase == 10) {
					if (showENGPage) {
						if (page != "eng") {
							setprop("/ECAM/Lower/page", "eng");
						}
					} else if (showAPUPage) {
						if (page != "apu") {
							setprop("/ECAM/Lower/page", "apu");
						}
					} else if (page != "door") {
						setprop("/ECAM/Lower/page", "door");
					}
				} else if (warnPhase == 2) {
					
					if (showENGPage) {
						if (page != "eng") {
							setprop("/ECAM/Lower/page", "eng");
						}
					} else if (showAPUPage) {
						if (page != "apu") {
							setprop("/ECAM/Lower/page", "apu");
						}
					} else if (fctlCounting == 1) {
						if (page != "fctl") {
							setprop("/ECAM/Lower/page", "fctl");
						}
					} else if (page != "wheel") {
						setprop("/ECAM/Lower/page", "wheel");
					}
				} else if (warnPhase >= 3 and warnPhase <= 5) {
					if (page != "eng") {
						setprop("/ECAM/Lower/page", "eng");
					}
				} else if (warnPhase >= 7 and warnPhase <= 9) {
					if (showENGPage) {
						if (page != "eng") {
							setprop("/ECAM/Lower/page", "eng");
						}
					} else if (showAPUPage) {
						if (page != "apu") {
							setprop("/ECAM/Lower/page", "apu");
						}
					} else if (page != "wheel") {
						setprop("/ECAM/Lower/page", "wheel");
					}
				} else if (warnPhase == 6) {
					flapLever = getprop("/controls/flight/flap-lever");
					gearLever = getprop("/controls/gear/gear-down");
					agl = getprop("/position/gear-agl-ft");
					
					if (CRZCounting and (toPowerSet or flapLever > 0) and !CRZCondition) {
						if (CRZTime + 60 < elapsedSec) {
							CRZCondition = 1;
							CRZCounting = 0;
						} else {
							CRZCondition = 0;
						}
					} 

					if (!CRZCounting and (toPowerSet or flapLever > 0) and !CRZCondition) {
						CRZTime = elapsedSec;
						CRZCondition = 0;
						CRZCounting = 1;
					}
					
					if (CRZCondition or (flapLever == 0 and !toPowerSet)) {
						if (gearLever and agl <= 16000) {
							if (page != "wheel") {
								setprop("/ECAM/Lower/page", "wheel");
							}
						} else if (page != "crz") {
							setprop("/ECAM/Lower/page", "crz");
						}
					} else {
						if (showENGPage) {
							if (page != "eng") {
								setprop("/ECAM/Lower/page", "eng");
							}
						} else if (showAPUPage) {
							if (page != "apu") {
								setprop("/ECAM/Lower/page", "apu");
							}
						} else if (page != "eng") {
							setprop("/ECAM/Lower/page", "eng");
						}
					}
				}
			} else {
				setprop("/ECAM/Lower/light/apu", 0);
				setprop("/ECAM/Lower/light/bleed", 0);
				setprop("/ECAM/Lower/light/cond", 0);
				setprop("/ECAM/Lower/light/door", 0);
				setprop("/ECAM/Lower/light/elec", 0);
				setprop("/ECAM/Lower/light/eng", 0);
				setprop("/ECAM/Lower/light/fctl", 0);
				setprop("/ECAM/Lower/light/fuel", 0);
				setprop("/ECAM/Lower/light/hyd", 0);
				setprop("/ECAM/Lower/light/press", 0);
				setprop("/ECAM/Lower/light/sts", 0);
				setprop("/ECAM/Lower/light/wheel", 0);
			}
		}
	},
	reset: func() {
		setprop("/ECAM/Lower/page", "door");
		setprop("/ECAM/Lower/man-select", 0);
		setprop("/ECAM/Lower/fault-select", 0);
		setprop("/ECAM/Lower/light/apu", 0);
		setprop("/ECAM/Lower/light/bleed", 0);
		setprop("/ECAM/Lower/light/cond", 0);
		setprop("/ECAM/Lower/light/door", 0);
		setprop("/ECAM/Lower/light/elec", 0);
		setprop("/ECAM/Lower/light/eng", 0);
		setprop("/ECAM/Lower/light/fctl", 0);
		setprop("/ECAM/Lower/light/fuel", 0);
		setprop("/ECAM/Lower/light/hyd", 0);
		setprop("/ECAM/Lower/light/press", 0);
		setprop("/ECAM/Lower/light/sts", 0);
		setprop("/ECAM/Lower/light/wheel", 0);
	},
	failCall: func(page) {
		setprop("/ECAM/Lower/man-select", 0);
		setprop("/ECAM/Lower/fault-select", 1);
		setprop("/ECAM/Lower/fault-page", page);
		setprop("/ECAM/Lower/page", page);
		setprop("/ECAM/Lower/light/clr", 1);
	},
	clrLight: func() {
		setprop("/ECAM/Lower/light/clr", 1);
	}
};
