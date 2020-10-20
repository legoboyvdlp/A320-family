# A3XX Buttons
# Joshua Davidson (Octal450)

# Copyright (c) 2020 Josh Davidson (Octal450)

var wow = nil;
var wowr = nil;
var OnLt = props.globals.getNode("/controls/switches/emerCallLtO");
var CallLt = props.globals.getNode("/controls/switches/emerCallLtC");
var EmerCall = props.globals.getNode("/controls/switches/emerCall");
var CabinCall = props.globals.getNode("/controls/switches/cabinCall");
var MechCall = props.globals.getNode("/controls/switches/mechCall");	
var cvr_tone = props.globals.getNode("/controls/CVR/tone");

# Resets buttons to the default values
var variousReset = func {
	setprop("modes/cpt-du-xfr", 0);
	setprop("modes/fo-du-xfr", 0);
	setprop("/controls/fadec/n1mode1", 0);
	setprop("/controls/fadec/n1mode2", 0);
	setprop("instrumentation/mk-viii/serviceable", 1);
	setprop("instrumentation/mk-viii/inputs/discretes/ta-tcf-inhibit", 0);
	setprop("instrumentation/mk-viii/inputs/discretes/gpws-inhibit", 0);
	setprop("instrumentation/mk-viii/inputs/discretes/glideslope-inhibit", 0);
	setprop("instrumentation/mk-viii/inputs/discretes/momentary-flap-all-override", 0);
	setprop("instrumentation/mk-viii/inputs/discretes/momentary-flap-3-override", 0);
	setprop("/controls/switches/cabinCall", 0);
	setprop("/controls/switches/mechCall", 0);
	setprop("/controls/switches/emer-lights", 0.5);
	# cockpit voice recorder stuff
	setprop("/controls/CVR/power", 0);
	setprop("/controls/CVR/test", 0);
	setprop("/controls/CVR/tone", 0);
	setprop("/controls/CVR/gndctl", 0);
	setprop("/controls/CVR/erase", 0);
	setprop("/controls/switches/pneumatics/cabin-fans", 1);
	setprop("/controls/oxygen/crewOxyPB", 1); # 0 = OFF 1 = AUTO
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
	setprop("/controls/lighting/DU/du3", 1);
	setprop("/controls/lighting/DU/du4", 1);
	setprop("/controls/lighting/DU/du5", 1);
	setprop("/controls/lighting/DU/du6", 1);
	setprop("/controls/lighting/DU/mcdu1", 1);
	setprop("/controls/lighting/DU/mcdu2", 1);
	setprop("modes/fcu/hdg-time", -45);
	setprop("/controls/switching/ATTHDG", 0);
	setprop("/controls/switching/AIRDATA", 0);
	setprop("/controls/switches/no-smoking-sign", 1);
	setprop("/controls/switches/seatbelt-sign", 1);
}

var BUTTONS = {
	update: func() {
		if (EmerCall.getValue()) {
			EmerCallOnLight();
			EmerCallLight();
		}
	},
};

var _OnLt = nil;
var _EmerCall = nil;

var EmerCallOnLight = func() {
	_OnLt = OnLt.getValue();
	_EmerCall = EmerCall.getValue();
	if ((_OnLt and _EmerCall) or !_EmerCall) { 
		OnLt.setValue(0);
	} else if (!_OnLt and _EmerCall) { 
		OnLt.setValue(1);
	}
}

var _CallLt = nil;
var _EmerCall2 = nil;

var EmerCallLight = func() {
	_CallLt = CallLt.getValue();
	_EmerCall2 = EmerCall.getValue();
	if ((_CallLt and _EmerCall2) or !_EmerCall2) { 
		CallLt.setValue(0);
	} else if (!_CallLt and _EmerCall2) { 
		CallLt.setValue(1);
	}
}

var EmerCallFunc = func {
	EmerCall.setValue(1);
	settimer(func() {
		EmerCall.setValue(0);
	}, 10);
}

var CabinCallFunc = func {
	CabinCall.setValue(1);
	settimer(func() {
		CabinCall.setValue(0);
	}, 15);
}
		
var MechCallFunc = func {
	MechCall.setValue(1);
	settimer(func() {
		MechCall.setValue(0);
	}, 15);
}

var CVR_test = func {
	if (pts.Controls.Gear.parkingBrake.getValue()) {
		cvr_tone.setValue(1);
		settimer(func() {
			cvr_tone.setValue(0);
		}, 15);
	}
}

setlistener("/controls/apu/master", func() { # poor mans set-reset latch 
	if (!systems.APUNodes.Controls.master.getValue() and (systems.APUController.APU.signals.emer or systems.APUController.APU.signals.autoshutdown)) {
		systems.APUController.APU.signals.emer = 0;
		systems.APUController.APU.signals.autoshutdown = 0;
	}
}, 0, 0);

var toggleSTD = func {
	if (pts.Instrumentation.Altimeter.std.getBoolValue()) {
		pts.Instrumentation.Altimeter.settingInhg.setValue(pts.Instrumentation.Altimeter.oldQnh.getValue());
		pts.Instrumentation.Altimeter.std.setBoolValue(0);
	} else {
		pts.Instrumentation.Altimeter.oldQnh.setValue(pts.Instrumentation.Altimeter.settingInhg.getValue());
		pts.Instrumentation.Altimeter.settingInhg.setValue(29.92);
		pts.Instrumentation.Altimeter.std.setBoolValue(1);
	}
}

var pushbuttonSound = props.globals.getNode("/sim/sounde/pushbutton");
var pushbutton = func {
	pushbuttonSound.setValue(1);
  settimer(func {pushbuttonSound.setValue(0);},0.20);
}