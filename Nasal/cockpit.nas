# Airbus A320 Cockpit Controls
# Copyright (c) 2024 Josh Davidson (Octal450)

var variousReset = func() {
	setprop("/modes/cpt-du-xfr", 0);
	setprop("/modes/fo-du-xfr", 0);
	setprop("/instrumentation/mk-viii/serviceable", 1);
	setprop("/instrumentation/mk-viii/inputs/discretes/ta-tcf-inhibit", 0);
	setprop("/instrumentation/mk-viii/inputs/discretes/gpws-inhibit", 0);
	setprop("/instrumentation/mk-viii/inputs/discretes/glideslope-inhibit", 0);
	setprop("/instrumentation/mk-viii/inputs/discretes/momentary-flap-all-override", 0);
	setprop("/instrumentation/mk-viii/inputs/discretes/momentary-flap-3-override", 0);
	setprop("/controls/switches/cabinCall", 0);
	setprop("/controls/switches/mechCall", 0);
	pts.Controls.Switches.emerLtsSwitch.setValue(0.5);
	pts.Controls.Gear.brakeParking.setBoolValue(0);
	# cockpit voice recorder stuff
	setprop("/controls/CVR/power", 0);
	setprop("/controls/CVR/test", 0);
	setprop("/controls/CVR/tone", 0);
	setprop("/controls/CVR/gndctl", 0);
	setprop("/controls/CVR/erase", 0);
	setprop("/controls/switches/emerCallLtO", 0); # ON light, flashes white for 10s
	setprop("/controls/switches/emerCallLtC", 0); # CALL light, flashes amber for 10s
	setprop("/controls/switches/emerCall", 0);
	setprop("/controls/switches/LrainRpt", 0);
	setprop("/controls/switches/RrainRpt", 0);
	setprop("/controls/switches/wiperLspd", 0); # -1 = INTM 0 = OFF 1 = LO 2 = HI
	setprop("/controls/switches/wiperRspd", 0); # -1 = INTM 0 = OFF 1 = LO 2 = HI
	setprop("/controls/lighting/strobe", 0);
	setprop("/controls/lighting/beacon", 0);
	setprop("/controls/switches/beacon", 0);
	setprop("/controls/switches/wing-lights", 0);
	setprop("/controls/switches/landing-lights-l", 0);
	setprop("/controls/switches/landing-lights-r", 0);
	setprop("/controls/lighting/wing-lights", 0);
	setprop("/controls/lighting/nav-lights-switch", 0);
	setprop("/controls/lighting/landing-lights[1]", 0);
	setprop("/controls/lighting/landing-lights[2]", 0);
	setprop("/controls/lighting/taxi-light-switch", 0);
	setprop("/controls/lighting/DU/du1", 1);
	setprop("/controls/lighting/DU/du2", 1);
	setprop("/controls/lighting/DU/du2-layer", 1);
	setprop("/controls/lighting/DU/du3", 1);
	setprop("/controls/lighting/DU/du4", 1);
	setprop("/controls/lighting/DU/du5", 1);
	setprop("/controls/lighting/DU/du5-layer", 1);
	setprop("/controls/lighting/DU/du6", 1);
	setprop("/controls/lighting/DU/mcdu1", 1);
	setprop("/controls/lighting/DU/mcdu2", 1);
	setprop("/controls/navigation/switching/att-hdg", 0);
	setprop("/controls/navigation/switching/air-data", 0);
	setprop("/controls/switches/loudspeaker-l", 1);
	setprop("/controls/switches/loudspeaker-r", 1);
	pts.Controls.Switches.noSmokingSwitch.setValue(0);
	pts.Controls.Switches.seatbeltSwitch.setValue(0);
	pts.Controls.Switches.emerLtsSwitch.setValue(0);
}

# Commonality
var ApPanel = {
	apDisc: func() {
		fcu.FCUController.APDisc();
	},
	atDisc: func() {
		fcu.FCUController.ATDisc();
	},
};
