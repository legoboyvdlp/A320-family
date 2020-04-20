# A3XX ADIRS System
# Joshua Davidson (Octal450)

# Copyright (c) 2020 Josh Davidson (Octal450)
var ADIRS = {
	init: func() {
		setprop("controls/adirs/mcdu/mode1", ""); # INVAL ALIGN NAV ATT or off (blank)
		setprop("controls/adirs/mcdu/mode2", "");
		setprop("controls/adirs/mcdu/mode3", "");
		setprop("controls/adirs/mcdu/status1", ""); # see smith thales p487
		setprop("controls/adirs/mcdu/status2", "");
		setprop("controls/adirs/mcdu/status3", "");
		setprop("controls/adirs/mcdu/hdg", ""); # only shown if in ATT mode
		setprop("controls/adirs/mcdu/avgdrift1", "");
		setprop("controls/adirs/mcdu/avgdrift2", "");
		setprop("controls/adirs/mcdu/avgdrift3", "");
		setprop("controls/adirs/mcducbtn", 0);
	},
};