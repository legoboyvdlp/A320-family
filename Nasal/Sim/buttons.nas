# A3XX Buttons
# Joshua Davidson (Octal450)

# Copyright (c) 2019 Joshua Davidson (Octal450)

# Resets buttons to the default values
var variousReset = func {
	setprop("modes/cpt-du-xfr", 0);
	setprop("modes/fo-du-xfr", 0);
	setprop("controls/fadec/n1mode1", 0);
	setprop("controls/fadec/n1mode2", 0);
	setprop("instrumentation/mk-viii/serviceable", 1);
	setprop("instrumentation/mk-viii/inputs/discretes/terr-inhibit", 0);
	setprop("instrumentation/mk-viii/inputs/discretes/gpws-inhibit", 0);
	setprop("instrumentation/mk-viii/inputs/discretes/glideslope-cancel", 0);
	setprop("instrumentation/mk-viii/inputs/discretes/momentary-flap-all-override", 0);
	setprop("instrumentation/mk-viii/inputs/discretes/momentary-flap-3-override", 0);
	setprop("controls/switches/cabinCall", 0);
	setprop("controls/switches/mechCall", 0);
	setprop("controls/switches/emer-lights", 0.5);
	# cockpit voice recorder stuff
	setprop("controls/CVR/power", 0);
	setprop("controls/CVR/test", 0);
	setprop("controls/CVR/tone", 0);
	setprop("controls/CVR/gndctl", 0);
	setprop("controls/CVR/erase", 0);
	setprop("controls/switches/cabinfan", 1);
	setprop("controls/oxygen/crewOxyPB", 1); # 0 = OFF 1 = AUTO
	setprop("controls/switches/emerCallLtO", 0); # ON light, flashes white for 10s
	setprop("controls/switches/emerCallLtC", 0); # CALL light, flashes amber for 10s
	setprop("controls/switches/emerCall", 0);
	setprop("controls/switches/LrainRpt", 0);
	setprop("controls/switches/RrainRpt", 0);
	setprop("controls/switches/wiperLspd", 0); # -1 = INTM 0 = OFF 1 = LO 2 = HI
	setprop("controls/switches/wiperRspd", 0); # -1 = INTM 0 = OFF 1 = LO 2 = HI
	setprop("controls/lighting/strobe", 0);
	setprop("controls/lighting/beacon", 0);
	setprop("controls/switches/beacon", 0);
	setprop("controls/switches/wing-lights", 0);
	setprop("controls/switches/landing-lights-l", 0);
	setprop("controls/switches/landing-lights-r", 0);
	setprop("controls/lighting/wing-lights", 0);
	setprop("controls/lighting/nav-lights-switch", 0);
	setprop("controls/lighting/landing-lights[1]", 0);
	setprop("controls/lighting/landing-lights[2]", 0);
	setprop("controls/lighting/taxi-light-switch", 0);
	setprop("controls/lighting/DU/du1", 1);
	setprop("controls/lighting/DU/du2", 1);
	setprop("controls/lighting/DU/du3", 1);
	setprop("controls/lighting/DU/du4", 1);
	setprop("controls/lighting/DU/du5", 1);
	setprop("controls/lighting/DU/du6", 1);
	setprop("controls/lighting/DU/mcdu1", 1);
	setprop("controls/lighting/DU/mcdu2", 1);
	setprop("modes/fcu/hdg-time", -45);
	setprop("controls/switching/ATTHDG", 0);
	setprop("controls/switching/AIRDATA", 0);
	setprop("controls/switches/no-smoking-sign", 1);
	setprop("controls/switches/seatbelt-sign", 1);
}

var BUTTONS = {
	init: func() {
		var stateL = getprop("engines/engine[0]/state");
		var stateR = getprop("engines/engine[1]/state");
		var Lrain = getprop("controls/switches/LrainRpt");
		var Rrain = getprop("controls/switches/RrainRpt");
		var OnLt = getprop("controls/switches/emerCallLtO");
		var CallLt = getprop("controls/switches/emerCallLtC");
		var EmerCall = getprop("controls/switches/emerCall");
		var wow = getprop("gear/gear[1]/wow");
		var wowr = getprop("gear/gear[2]/wow");
		var gndCtl = getprop("systems/CVR/gndctl");
		var acPwr = getprop("systems/electrical/bus/ac-ess");
	},
	update: func() {
		rainRepel();
		CVR_master();
		if (getprop("controls/switches/emerCall")) {
			EmerCallOnLight();
			EmerCallLight();
		}
	},
};

var rainRepel = func() {
	Lrain = getprop("controls/switches/LrainRpt");
	Rrain = getprop("controls/switches/RrainRpt");
	wow = getprop("gear/gear[1]/wow");
	stateL = getprop("engines/engine[0]/state");
	stateR = getprop("engines/engine[1]/state");
	if (Lrain and (stateL != 3 and stateR != 3 and wow)) {	
		setprop("controls/switches/LrainRpt", 0);
	}
	if (Rrain and (stateL != 3 and stateR != 3 and wow)) { 
		setprop("controls/switches/RrainRpt", 0);
	}
}

var EmerCallOnLight = func() {
	OnLt = getprop("controls/switches/emerCallLtO");
	EmerCall = getprop("controls/switches/emerCall");
	if ((OnLt and EmerCall) or !EmerCall) { 
		setprop("controls/switches/emerCallLtO", 0);
	} else if (!OnLt and EmerCall) { 
		setprop("controls/switches/emerCallLtO", 1);
	}
}

var EmerCallLight = func() {
	CallLt = getprop("controls/switches/emerCallLtC");
	EmerCall = getprop("controls/switches/emerCall");
	if ((CallLt and EmerCall) or !EmerCall) { 
		setprop("controls/switches/emerCallLtC", 0);
	} else if (!CallLt and EmerCall) { 
		setprop("controls/switches/emerCallLtC", 1);
	}
}

var CVR_master = func() {
	stateL = getprop("engines/engine[0]/state");
	stateR = getprop("engines/engine[1]/state");
	wow = getprop("gear/gear[1]/wow");
	wowr = getprop("gear/gear[2]/wow");
	gndCtl = getprop("systems/CVR/gndctl");
	acPwr = getprop("systems/electrical/bus/ac-ess");
	if (acPwr > 0 and wow and wowr and (gndCtl or (stateL == 3 or stateR == 3))) {
		setprop("controls/CVR/power", 1);
	} else if (!wow and !wowr and acPwr > 0) {
		setprop("controls/CVR/power", 1);
	} else {
		setprop("controls/CVR/power", 0);
	}
}

var EmerCall = func {
	setprop("controls/switches/emerCall", 1);
	settimer(func() {
		setprop("controls/switches/emerCall", 0);
	}, 10);
}

var CabinCall = func {
	setprop("controls/switches/cabinCall", 0);
	settimer(func() {
		setprop("controls/switches/cabinCall", 0);
	}, 15);
}
		
var MechCall = func {
	setprop("controls/switches/mechCall", 1);
	settimer(func() {
		setprop("controls/switches/mechCall", 0);
	}, 15);
}

var CVR_test = func {
	var parkBrake = getprop("controls/gear/brake-parking");
	if (parkBrake) {
		setprop("controls/CVR/tone", 1);
		settimer(func() {
			setprop("controls/CVR/tone", 0);
		}, 15);
	}
}

setlistener("/controls/apu/master", func() {
	if (!getprop("controls/apu/master") and systems.apuEmerShutdown.getBoolValue()) {
		systems.apuEmerShutdown.setBoolValue(0);
	}
}, 0, 0);