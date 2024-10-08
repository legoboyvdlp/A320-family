# A3XX Buttons
var OnLt = props.globals.getNode("/controls/switches/emerCallLtO");
var CallLt = props.globals.getNode("/controls/switches/emerCallLtC");
var EmerCall = props.globals.getNode("/controls/switches/emerCall");
var CabinCall = props.globals.getNode("/controls/switches/cabinCall");
var MechCall = props.globals.getNode("/controls/switches/mechCall");	
var cvr_tone = props.globals.getNode("/controls/CVR/tone");

var BUTTONS = {
	storeEmerCall: 0,
	update: func() {
		me.storeEmerCall = EmerCall.getValue();
		if (me.storeEmerCall) {
			EmerCallOnLight(me.storeEmerCall);
			EmerCallLight(me.storeEmerCall);
		}
	},
};

var _OnLt = nil;
var EmerCallOnLight = func(emerCallSts) {
	_OnLt = OnLt.getValue();
	if ((_OnLt and emerCallSts) or !emerCallSts) { 
		OnLt.setValue(0);
	} else if (!_OnLt and emerCallSts) { 
		OnLt.setValue(1);
	}
}

var _CallLt = nil;
var EmerCallLight = func(emerCallSts) {
	_CallLt = CallLt.getValue();
	_EmerCall2 = emerCallSts;
	if ((_CallLt and emerCallSts) or !emerCallSts) { 
		CallLt.setValue(0);
	} else if (!_CallLt and emerCallSts) { 
		CallLt.setValue(1);
	}
}

var _EmerCallRunning = 0;
var EmerCallFunc = func() {
	if (!_EmerCallRunning) {
		_EmerCallRunning = 1;
		EmerCall.setValue(1);
		settimer(func() {
			EmerCall.setValue(0);
			_EmerCallRunning = 0;
		}, 7);
	}
}

var _CabinCallRunning = 0;
var CabinCallFunc = func() {
	if (!_CabinCallRunning) {	
		_CabinCallRunning = 1;
		CabinCall.setValue(1);
		settimer(func() {
			CabinCall.setValue(0);
			_CabinCallRunning = 0;
		}, 2);
	}
}
	
var _MechCallRunning = 0;	
var MechCallFunc = func() {
	if (!_MechCallRunning) {
		_MechCallRunning = 1;	
		MechCall.setValue(1);
		settimer(func() {
			MechCall.setValue(0);
			_MechCallRunning = 0;	
		}, 6);
	}
}

var _CVRtestRunning = 0;
var CVR_test = func() {
	if (pts.Controls.Gear.brakeParking.getValue()) {
		if (!_CVRtestRunning) {
			_CVRtestRunning = 1;
			cvr_tone.setValue(1);
			settimer(func() {
				_CVRtestRunning = 0;
				cvr_tone.setValue(0);
			}, 15);
		}
	}
}

setlistener("/controls/apu/master", func() { # poor mans set-reset latch 
	if (!systems.APUNodes.Controls.master.getValue() and (systems.APUController.APU.signals.emer or systems.APUController.APU.signals.autoshutdown)) {
		systems.APUController.APU.signals.emer = 0;
		systems.APUController.APU.signals.autoshutdown = 0;
	}
}, 0, 0);

var toggleSTD = func() {
	if (pts.Instrumentation.Altimeter.std.getBoolValue()) {
		pts.Instrumentation.Altimeter.settingInhg.setValue(pts.Instrumentation.Altimeter.oldQnh.getValue());
		pts.Instrumentation.Altimeter.std.setBoolValue(0);
	} else {
		pts.Instrumentation.Altimeter.oldQnh.setValue(pts.Instrumentation.Altimeter.settingInhg.getValue());
		pts.Instrumentation.Altimeter.settingInhg.setValue(29.92);
		pts.Instrumentation.Altimeter.std.setBoolValue(1);
	}
}

var toggleSTDIESI = func() {
	if (pts.Instrumentation.Altimeter.stdIESI.getBoolValue()) {
		pts.Instrumentation.Altimeter.settingInhgIESI.setValue(pts.Instrumentation.Altimeter.oldQnhIESI.getValue());
		pts.Instrumentation.Altimeter.stdIESI.setBoolValue(0);
	} else {
		pts.Instrumentation.Altimeter.oldQnhIESI.setValue(pts.Instrumentation.Altimeter.settingInhgIESI.getValue());
		pts.Instrumentation.Altimeter.settingInhgIESI.setValue(29.92);
		pts.Instrumentation.Altimeter.stdIESI.setBoolValue(1);
	}
}
