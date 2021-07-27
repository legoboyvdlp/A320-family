# A3XX Electronic Centralised Aircraft Monitoring System
# Copyright (c) 2021 Jonathan Redpath (legoboyvdlp)

var lines = [props.globals.getNode("ECAM/msg/line1", 1), props.globals.getNode("ECAM/msg/line2", 1), props.globals.getNode("ECAM/msg/line3", 1), props.globals.getNode("ECAM/msg/line4", 1), props.globals.getNode("ECAM/msg/line5", 1), props.globals.getNode("ECAM/msg/line6", 1), props.globals.getNode("ECAM/msg/line7", 1), props.globals.getNode("ECAM/msg/line8", 1)];
var linesCol = [props.globals.getNode("ECAM/msg/linec1", 1), props.globals.getNode("ECAM/msg/linec2", 1), props.globals.getNode("ECAM/msg/linec3", 1), props.globals.getNode("ECAM/msg/linec4", 1), props.globals.getNode("ECAM/msg/linec5", 1), props.globals.getNode("ECAM/msg/linec6", 1), props.globals.getNode("ECAM/msg/linec7", 1), props.globals.getNode("ECAM/msg/linec8", 1)];
var rightLines = [props.globals.getNode("ECAM/rightmsg/line1", 1), props.globals.getNode("ECAM/rightmsg/line2", 1), props.globals.getNode("ECAM/rightmsg/line3", 1), props.globals.getNode("ECAM/rightmsg/line4", 1), props.globals.getNode("ECAM/rightmsg/line5", 1), props.globals.getNode("ECAM/rightmsg/line6", 1), props.globals.getNode("ECAM/rightmsg/line7", 1), props.globals.getNode("ECAM/rightmsg/line8", 1)];
var rightLinesCol = [props.globals.getNode("ECAM/rightmsg/linec1", 1), props.globals.getNode("ECAM/rightmsg/linec2", 1), props.globals.getNode("ECAM/rightmsg/linec3", 1), props.globals.getNode("ECAM/rightmsg/linec4", 1), props.globals.getNode("ECAM/rightmsg/linec5", 1), props.globals.getNode("ECAM/rightmsg/linec6", 1), props.globals.getNode("ECAM/rightmsg/linec7", 1), props.globals.getNode("ECAM/rightmsg/linec8", 1)];
var statusLines = [props.globals.getNode("ECAM/status/line1", 1), props.globals.getNode("ECAM/status/line2", 1), props.globals.getNode("ECAM/status/line3", 1), props.globals.getNode("ECAM/status/line4", 1), props.globals.getNode("ECAM/status/line5", 1), props.globals.getNode("ECAM/status/line6", 1), props.globals.getNode("ECAM/status/line7", 1), props.globals.getNode("ECAM/status/line8", 1)];
var statusLinesCol = [props.globals.getNode("ECAM/status/linec1", 1), props.globals.getNode("ECAM/status/linec2", 1), props.globals.getNode("ECAM/status/linec3", 1), props.globals.getNode("ECAM/status/linec4", 1), props.globals.getNode("ECAM/status/linec5", 1), props.globals.getNode("ECAM/status/linec6", 1), props.globals.getNode("ECAM/status/linec7", 1), props.globals.getNode("ECAM/status/linec8", 1)];

var leftOverflow  = props.globals.initNode("/ECAM/warnings/overflow-left", 0, "BOOL");
var rightOverflow = props.globals.initNode("/ECAM/warnings/overflow-right", 0, "BOOL");
var overflow = props.globals.initNode("/ECAM/warnings/overflow", 0, "BOOL");


var lights = [props.globals.initNode("/ECAM/warnings/master-warning-light", 0, "BOOL"), props.globals.initNode("/ECAM/warnings/master-caution-light", 0, "BOOL")]; 
var aural = [props.globals.initNode("/sim/sound/warnings/crc", 0, "BOOL"), props.globals.initNode("/sim/sound/warnings/chime", 0, "BOOL"), props.globals.initNode("/sim/sound/warnings/cricket", 0, "BOOL"), props.globals.initNode("/sim/sound/warnings/retard", 0, "BOOL"), props.globals.initNode("/sim/sound/warnings/cchord", 0, "BOOL"), props.globals.initNode("/sim/sound/warnings/click", 0, "BOOL")];
var warningFlash = props.globals.initNode("/ECAM/warnings/master-warning-flash", 0, "BOOL");

var lineIndex = 0;
var rightLineIndex = 0;
var statusIndex = 0;

var flash = 0;
var hasCleared = 0;
var statusFlag = 0;
var counter = 0;
var counterClear = 0;
var noMainMsg = 0;
var storeFirstWarning = nil;

var warning = {
	new: func(msg,colour = "g",aural = 9,light = 9,isMainMsg = 0,lastSubmsg = 0, sdPage = "nil", isMemo = 0) {
		var t = {parents:[warning]};
		
		t.msg = msg;
		t.colour = colour;
		t.aural = aural;
		t.light = light;
		t.isMainMsg = isMainMsg;
		t.lastSubmsg = lastSubmsg;
		t.active = 0;
		t.noRepeat = 0;
		t.noRepeat2 = 0;
		t.clearFlag = 0;
		t.sdPage = sdPage;
		t.isMemo = isMemo;
		t.hasCalled = 0;
		t.wasActive = 0;
		
		return t
	},
	write: func() {
		if (me.active == 0) { return; }
		me.wasActive = 1;
		lineIndex = 0;
		while (lineIndex <= 7 and lines[lineIndex].getValue() != "") {
			lineIndex = lineIndex + 1; # go to next line until empty line
		}
		
		if (lineIndex == 8) {
			leftOverflow.setBoolValue(1);
		} elsif (leftOverflow.getBoolValue()) {
			leftOverflow.setBoolValue(0);
		}
		
		if (lineIndex <= 7) {
			if (lines[lineIndex].getValue() == "" and me.msg != "") { # at empty line. Also checks if message is not blank to allow for some warnings with no displayed msg, eg stall
				lines[lineIndex].setValue(me.msg);
				linesCol[lineIndex].setValue(me.colour);
			}
		}
	},
	warnlight: func() {
		if (me.light > 1) { return; }
		if (me.active == 0 and me.wasActive == 1) {
			lights[me.light].setBoolValue(0);
			me.wasActive = 0;
		}
		
		if (me.noRepeat == 1 or me.active == 0) { return; }
		
		lights[me.light].setBoolValue(1);
		me.noRepeat = 1;
	},
	sound: func() {
		if (me.aural == 9) { return; }
		if (me.active == 0 and me.wasActive == 1) {
			aural[me.aural].setBoolValue(0); 
			me.wasActive = 0;
		}
		
        if (me.noRepeat2 == 1 or me.active == 0) { return; }
		
		if (me.aural != 0) {
			aural[me.aural].setBoolValue(0); 
			settimer(func() {
				aural[me.aural].setBoolValue(1);
			}, 0.15);
		} else {
			aural[me.aural].setBoolValue(1);
		}
		me.noRepeat2 = 1;
    },
	callPage: func() {
		if (me.sdPage == "nil" or me.hasCalled == 1) { return; }
		ecam.SystemDisplayController.failureCall(me.sdPage);
		me.hasCalled = 1;
	}
};

var memo = {
	new: func(msg,colour = "g") {
		var t = {parents:[memo]};
		
		t.msg = msg;
		t.colour = colour;
		t.active = 0;
		
		return t
	},
	write: func() {
		if (me.active == 1) {
			rightLineIndex = 0;
			while (rightLines[rightLineIndex].getValue() != "" and rightLineIndex <= 7) {
				rightLineIndex = rightLineIndex + 1; # go to next line until empty line
			} 
			
			if (rightLineIndex > 7) {
				rightOverflow.setBoolValue(1);
			} elsif (rightOverflow.getBoolValue()) {
				rightOverflow.setBoolValue(0);
			}
			
			if (rightLines[rightLineIndex].getValue() == "" and rightLineIndex <= 7) { # at empty line
				rightLines[rightLineIndex].setValue(me.msg);
				rightLinesCol[rightLineIndex].setValue(me.colour);
			}
		}
	},
};

var status = {
	new: func(msg,colour) {
		var t = {parents:[status]};
		
		t.msg = msg;
		t.colour = colour;
		t.active = 0;
		
		return t
	},
	write: func() {
		if (me.active == 1) {
			statusIndex = 0;
			while (statusLines[statusIndex].getValue() != "" and statusIndex <= 7) {
				statusIndex = statusIndex + 1; # go to next line until empty line
			} 
			
			if (statusLines[statusIndex].getValue() == "" and statusIndex <= 7) { # at empty line
				statusLines[rightLineIndex].setValue(me.msg);
				statusLinesCol[rightLineIndex].setValue(me.colour);
			}
		}
	},
};

var ECAM_controller = {
	_recallCounter: 0,
	_noneActive: 0,
	_ready: 0,
	init: func() {
		me.reset();
		me._ready = 1;
	},
	loop: func(notification) {
		if (!me._ready) {
			return;
		}
		if ((systems.ELEC.Bus.acEss.getValue() >= 110 or systems.ELEC.Bus.ac2.getValue() >= 110) and !pts.Acconfig.running.getBoolValue()) {
			# check active messages
			messages_priority_3();
			messages_priority_2();
			messages_priority_1();
			messages_priority_0();
			messages_config_memo();
			messages_memo();
			messages_right_memo();
		} else {
			foreach (var w; warnings.vector) {
				w.active = 0;
			}
			shutUpYou();
		}
		
		# clear display momentarily
		
		
		for(var n = 0; n <= 7; n += 1) {
			lines[n].setValue("");
		}
		
		for(var n = 0; n <= 7; n += 1) {
			rightLines[n].setValue("");
		}
		
		# write to ECAM
		counter = 0;
		
		if (!pts.Acconfig.running.getBoolValue()) {
			foreach (var w; warnings.vector) {
				if (w.active == 1) {
					if (counter < 9) {
						w.write();
						counter += 1;
						w.callPage();
					}
					w.warnlight();
					w.sound();
				} elsif (w.wasActive == 1) {
					w.warnlight();
					w.sound();
				}
			}
		}
			
		if (lines[0].getValue() == "" and flash == 0) { # disable left memos if a warning exists. Warnings are processed first, so this stops leftmemos if line1 is not empty
			foreach (var c; configmemos.vector) {
				c.write();
			}
		}
		
		if (lines[0].getValue() == "" and flash == 0) { # disable left memos if a warning exists. Warnings are processed first, so this stops leftmemos if line1 is not empty
			foreach (var l; leftmemos.vector) {
				l.write();
			}
		}
		
		foreach (var sL; specialLines.vector) {
			sL.write();
		}
		
		foreach (var sF; secondaryFailures.vector) {
			sF.write();
		}
		
		foreach (var m; memos.vector) {
			m.write();
		}
		
		if (leftOverflow.getBoolValue() == 1 or leftOverflow.getBoolValue() == 1) {
			overflow.setBoolValue(1);
		} elsif (leftOverflow.getBoolValue() == 0 and leftOverflow.getBoolValue() == 0) {
			overflow.setBoolValue(0);
		}
	},
	reset: func() {
		me._ready = 0;
		foreach (var w; warnings.vector) {
			if (w.active == 1) {
				w.active = 0;
			}
		}
		
		foreach (var l; configmemos.vector) {
			if (l.active == 1) {
				l.active = 0;
			}
		}
		
		foreach (var l; leftmemos.vector) {
			if (l.active == 1) {
				l.active = 0;
			}
		}
		
		foreach (var sL; specialLines.vector) {
			if (sL.active == 1) {
				sL.active = 0;
			}
		}
		
		foreach (var sF; secondaryFailures.vector) {
			if (sF.active == 1) {
				sF.active = 0;
			}
		}
		
		foreach (var m; memos.vector) {
			if (m.active == 1) {
				m.active = 0;
			}
		}
		me._ready = 1;
	},
	clear: func() {
		hasCleared = 0;
		counterClear = 0;
		noMainMsg = 0;
		storeFirstWarning = nil;
		
		# first go through the first eight, see how many mainMsg there are
		foreach (var w; warnings.vector) {
			if (counterClear >= 8) { break; }
			if (w.active == 1 and w.clearFlag != 1 and w.isMemo != 1) {
				counterClear += 1;
				if (w.isMainMsg == 1) {
					if (noMainMsg == 0) {
						storeFirstWarning = w;
					}
					noMainMsg += 1;
				}
			}
		}
		
		# then, if there is an overflow and noMainMsg == 1, we clear the first shown ones
		if (leftOverflow.getBoolValue() and noMainMsg == 1) {
			counterClear = 0;
			foreach (var w; warnings.vector) {
				if (counterClear >= 8) { break; }
				if (w.active == 1 and w.clearFlag != 1 and w.isMemo != 1) {
					counterClear += 1;
					if (w.isMainMsg == 1) { continue; }
					w.clearFlag = 1;
					hasCleared = 1;
					statusFlag = 1;
				}
			}
		}
		
		# else, we clear the first mainMsg stored
		else {
			if (storeFirstWarning != nil) {
				if (storeFirstWarning.active == 1 and storeFirstWarning.clearFlag != 1 and storeFirstWarning.isMainMsg == 1 and storeFirstWarning.isMemo != 1) {
					storeFirstWarning.clearFlag = 1;
					hasCleared = 1;
					statusFlag = 1;
				}
			}
		}
		
		if (!hasCleared and statusFlag) {
			statusFlag = 0;
			ecam.SystemDisplayController.manCall("statusPage");
			return;
		}
		
		if (!hasCleared and !statusFlag) {
			SystemDisplayController.manCall("CLR");
		}
	},
	recall: func() {
		me._noneActive = 1;
		me._recallCounter = 0;
		foreach (var w; warnings.vector) {
			if (w.clearFlag == 1) {
				w.noRepeat = 0;
				w.clearFlag = 0;
				me._recallCounter += 1;
			}
			
			if (w.active == 1) {
				me._noneActive = 0;
			}
		}
		
		if (me._recallCounter == 0 and me._noneActive) {
			FWC.Btn.recallStsNormal.setValue(1);
			settimer(func() {
				if (FWC.Btn.recallStsNormal.getValue() == 1) { # catch unexpected error, trying something new here
					FWC.Btn.recallStsNormal.setValue(0);
				} else {
					die("Exception in ECAM-controller.nas, line 316");
				}
			}, 0.1);
		}
	},
	warningReset: func(warning) {
		if (warning.aural != 9 and warning.active == 1) {
			aural[warning.aural].setBoolValue(0); 
		}
		warning.active = 0;
		warning.noRepeat = 0;
		warning.noRepeat2 = 0;
		# don't set .wasActive to 0, warnlight / sound funcs do that
	},
};

setlistener("/systems/electrical/bus/dc-ess", func {
	if (systems.ELEC.Bus.dcEss.getValue() < 25) {
		ECAM_controller.reset();
	}
}, 0, 0);

# Flash Master Warning Light
var shutUpYou = func() {
	lights[0].setBoolValue(0);
}

var warnTimer = maketimer(0.25, func {
	if (!lights[0].getBoolValue()) {
		warnTimer.stop();
		warningFlash.setBoolValue(0);
	} else if (!warningFlash.getBoolValue()) {
		warningFlash.setBoolValue(1);
	} else {
		warningFlash.setBoolValue(0);
	}
});

setlistener("/ECAM/warnings/master-warning-light", func {
	if (lights[0].getBoolValue()) {
		warningFlash.setBoolValue(0);
		warnTimer.start();
	} else {
		warnTimer.stop();
		warningFlash.setBoolValue(0);
	}
}, 0, 0);
