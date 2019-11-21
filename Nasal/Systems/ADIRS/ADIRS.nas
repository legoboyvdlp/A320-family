# A3XX ADIRS System
# Joshua Davidson (Octal450)

# Copyright (c) 2019 Joshua Davidson (Octal450)

var knob = 0;
var roll = 0;
var pitch = 0;
var gs = 0;
var ac1 = 0;
var ac2 = 0;
var dcbat = 0;
var pwr_src = "XX";
setprop("/controls/adirs/align-time", 600);

var ADIRS = {
	init: func() {
		setprop("/controls/adirs/numm", 0);
		setprop("/instrumentation/adirs/adr[0]/active", 0);
		setprop("/instrumentation/adirs/adr[1]/active", 0);
		setprop("/instrumentation/adirs/adr[2]/active", 0);
		setprop("/instrumentation/adirs/ir[0]/aligned", 0);
		setprop("/instrumentation/adirs/ir[1]/aligned", 0);
		setprop("/instrumentation/adirs/ir[2]/aligned", 0);
		setprop("/controls/adirs/adr[0]/fault", 0);
		setprop("/controls/adirs/adr[1]/fault", 0);
		setprop("/controls/adirs/adr[2]/fault", 0);
		setprop("/controls/adirs/adr[0]/off", 0);
		setprop("/controls/adirs/adr[1]/off", 0);
		setprop("/controls/adirs/adr[2]/off", 0);
		setprop("/controls/adirs/ir[0]/align", 0);
		setprop("/controls/adirs/ir[1]/align", 0);
		setprop("/controls/adirs/ir[2]/align", 0);
		setprop("/controls/adirs/ir[0]/time", 0);
		setprop("/controls/adirs/ir[1]/time", 0);
		setprop("/controls/adirs/ir[2]/time", 0);
		setprop("/controls/adirs/ir[0]/knob", 0);
		setprop("/controls/adirs/ir[1]/knob", 0);
		setprop("/controls/adirs/ir[2]/knob", 0);
		setprop("/controls/adirs/ir[0]/fault", 0);
		setprop("/controls/adirs/ir[1]/fault", 0);
		setprop("/controls/adirs/ir[2]/fault", 0);
		setprop("/controls/adirs/onbat", 0);
		setprop("/controls/adirs/mcdu/mode1", ""); # INVAL ALIGN NAV ATT or off (blank)
		setprop("/controls/adirs/mcdu/mode2", "");
		setprop("/controls/adirs/mcdu/mode3", "");
		setprop("/controls/adirs/mcdu/status1", ""); # see smith thales p487
		setprop("/controls/adirs/mcdu/status2", "");
		setprop("/controls/adirs/mcdu/status3", "");
		setprop("/controls/adirs/mcdu/hdg", ""); # only shown if in ATT mode
		setprop("/controls/adirs/mcdu/avgdrift1", "");
		setprop("/controls/adirs/mcdu/avgdrift2", "");
		setprop("/controls/adirs/mcdu/avgdrift3", "");
		setprop("/controls/adirs/mcducbtn", 0);
	},
	loop: func() {
		roll = getprop("/orientation/roll-deg");
		pitch = getprop("/orientation/pitch-deg");
		gs = getprop("/velocities/groundspeed-kt");
		ac1 = getprop("/systems/electrical/bus/ac-1");
		ac2 = getprop("/systems/electrical/bus/ac-2");
		dcbat = getprop("/systems/electrical/bus/dc-bat");
		
		if (getprop("/controls/adirs/skip") == 1) {
			if (getprop("/controls/adirs/align-time") != 5) {
				setprop("/controls/adirs/align-time", 5);
			}
		} else {
			if (getprop("/controls/adirs/align-time") != 600) {
				setprop("/controls/adirs/align-time", 600);
			}
		}
		
		if (gs > 5 or pitch > 5 or pitch < -5 or roll > 10 or roll < -10 or (ac1 < 110 and ac2 < 110 and dcbat < 25)) {
			if (getprop("/controls/adirs/ir[0]/align") == 1) {
				me.stopAlign(0,1);
			}
			if (getprop("/controls/adirs/ir[1]/align") == 1) {
				me.stopAlign(1,1);
			}
			if (getprop("/controls/adirs/ir[2]/align") == 1) {
				me.stopAlign(2,1);
			}
		}
		
		if (ac1 >= 110 or ac2 >= 110) {
			pwr_src = "AC";
		} else if (dcbat >= 25 and (getprop("/controls/adirs/ir[0]/knob") != 0 or getprop("/controls/adirs/ir[1]/knob") != 0 or getprop("/controls/adirs/ir[2]/knob") != 0)) {
			pwr_src = "BATT";
		} else {
			pwr_src = "XX";
		}
		
		if (getprop("/controls/adirs/ir[0]/time") + 3 >= getprop("/sim/time/elapsed-sec") or getprop("/controls/adirs/ir[1]/time") + 3 >= getprop("/sim/time/elapsed-sec") or getprop("/controls/adirs/ir[2]/time") + 3 >= getprop("/sim/time/elapsed-sec")) {
			setprop("/controls/adirs/onbat", 1);
		} else if (pwr_src == "BATT") {
			setprop("/controls/adirs/onbat", 1);
		} else {
			setprop("/controls/adirs/onbat", 0);
		}
	},
	knob: func(k) {
		knob = getprop("/controls/adirs/ir[" ~ k ~ "]/knob");
		if (knob == 0) {
			me.stopAlign(k,0);
		} else if (knob == 1) {
			me.beginAlign(k);
		} else if (knob == 2) {
			me.beginAlign(k);
		}
	},
	beginAlign: func(n) {
		ac1 = getprop("/systems/electrical/bus/ac-1");
		ac2 = getprop("/systems/electrical/bus/ac-2");
		dcbat = getprop("/systems/electrical/bus/dc-bat");
		setprop("/instrumentation/adirs/adr[" ~ n ~ "]/active", 1);
		if (getprop("/controls/adirs/ir[" ~ n ~ "]/align") != 1 and getprop("/instrumentation/adirs/ir[" ~ n ~ "]/aligned") != 1 and (ac1 >= 110 or ac2 >= 110 or dcbat >= 25)) {
			setprop("/controls/adirs/ir[" ~ n ~ "]/time", getprop("/sim/time/elapsed-sec"));
			setprop("/controls/adirs/ir[" ~ n ~ "]/align", 1);
			setprop("/controls/adirs/ir[" ~ n ~ "]/fault", 0);
			if (n == 0) {
				alignOne.start();
			} else if (n == 1) {
				alignTwo.start();
			} else if (n == 2) {
				alignThree.start();
			}
		}
	},
	stopAlign: func(n,f) {
		setprop("/controls/adirs/ir[" ~ n ~ "]/align", 0);
		if (f == 1) {
			setprop("/controls/adirs/ir[" ~ n ~ "]/fault", 1);
		} else {
			setprop("/controls/adirs/ir[" ~ n ~ "]/fault", 0);
		}
		if (n == 0) {
			alignOne.stop();
		} else if (n == 1) {
			alignTwo.stop();
		} else if (n == 2) {
			alignThree.stop();
		}
		setprop("/instrumentation/adirs/adr[" ~ n ~ "]/active", 0);
		setprop("/instrumentation/adirs/ir[" ~ n ~ "]/aligned", 0);
		setprop("/controls/adirs/mcducbtn", 0);
	},
	skip: func(n) {
		if (n == 0) {
			alignOne.stop();
		} else if (n == 1) {
			alignTwo.stop();
		} else if (n == 2) {
			alignThree.stop();
		}
		setprop("/controls/adirs/ir[" ~ n ~ "]/align", 0);
		setprop("/controls/adirs/ir[" ~ n ~ "]/fault", 0);
		setprop("/instrumentation/adirs/ir[" ~ n ~ "]/aligned", 1);
	},
};

var alignOne = maketimer(0.1, func {
	if (getprop("/controls/adirs/ir[0]/time") + getprop("/controls/adirs/align-time") >= getprop("/sim/time/elapsed-sec")) {
		if (getprop("/instrumentation/adirs/ir[0]/aligned") != 0) {
			setprop("/instrumentation/adirs/ir[0]/aligned", 0);
		}
		if (getprop("/controls/adirs/ir[0]/align") != 1) {
			setprop("/controls/adirs/ir[0]/align", 1);
		}
	} else {
		if (getprop("/instrumentation/adirs/ir[0]/aligned") != 1 and getprop("/controls/adirs/mcducbtn") == 1) {
			alignOne.stop();
			setprop("/instrumentation/adirs/ir[0]/aligned", 1);
		}
		if (getprop("/controls/adirs/ir[0]/align") != 0) {
			setprop("/controls/adirs/ir[0]/align", 0);
		}
	}
});

var alignTwo = maketimer(0.1, func {
	if (getprop("/controls/adirs/ir[1]/time") + getprop("/controls/adirs/align-time") >= getprop("/sim/time/elapsed-sec")) {
		if (getprop("/instrumentation/adirs/ir[1]/aligned") != 0) {
			setprop("/instrumentation/adirs/ir[1]/aligned", 0);
		}
		if (getprop("/controls/adirs/ir[1]/align") != 1) {
			setprop("/controls/adirs/ir[1]/align", 1);
		}
	} else {
		if (getprop("/instrumentation/adirs/ir[1]/aligned") != 1 and getprop("/controls/adirs/mcducbtn") == 1) {
			alignTwo.stop();
			setprop("/instrumentation/adirs/ir[1]/aligned", 1);
		}
		if (getprop("/controls/adirs/ir[1]/align") != 0) {
			setprop("/controls/adirs/ir[1]/align", 0);
		}
	}
});

var alignThree = maketimer(0.1, func {
	if (getprop("/controls/adirs/ir[2]/time") + getprop("/controls/adirs/align-time") >= getprop("/sim/time/elapsed-sec")) {
		if (getprop("/instrumentation/adirs/ir[2]/aligned") != 0) {
			setprop("/instrumentation/adirs/ir[2]/aligned", 0);
		}
		if (getprop("/controls/adirs/ir[2]/align") != 1) {
			setprop("/controls/adirs/ir[2]/align", 1);
		}
	} else {
		if (getprop("/instrumentation/adirs/ir[2]/aligned") != 1 and getprop("/controls/adirs/mcducbtn") == 1) {
			alignThree.stop();
			setprop("/instrumentation/adirs/ir[2]/aligned", 1);
		}
		if (getprop("/controls/adirs/ir[2]/align") != 0) {
			setprop("/controls/adirs/ir[2]/align", 0);
		}
	}
});

setlistener("/controls/adirs/ir[0]/knob", func {
	ADIRS.knob(0);
});

setlistener("/controls/adirs/ir[1]/knob", func {
	ADIRS.knob(1);
});

setlistener("/controls/adirs/ir[2]/knob", func {
	ADIRS.knob(2);
});
