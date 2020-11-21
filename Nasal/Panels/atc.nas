# A3XX ATC Panel
# Jonathan Redpath

# Copyright (c) 2019 Jonathan Redpath

var idCode = props.globals.getNode("instrumentation/transponder/id-code", 1);

var guiModes = ['OFF', 'STANDBY', 'TEST', 'GROUND', 'ON', 'ALTITUDE'];
var guiNode = props.globals.getNode("/sim/gui/dialogs/radios/transponder-mode", 1);
var forLoopFlag = 0;

var altimeter = props.globals.initNode("/instrumentation/transponder/altimeter-input-src", 0, "INT");
var airspeed = props.globals.initNode("/instrumentation/transponder/airspeed-input-src", 0, "INT");

var Transponder = {
	mode: 0,
	code: "2000",
	selected: 0,
	electricalSrc: "",
	activeADIRS: 1,
	condition: 0,
	failed: 0,
	codeDigitsNodes: [props.globals.getNode("instrumentation/transponder/inputs/digit[0]", 1), props.globals.getNode("instrumentation/transponder/inputs/digit[1]", 1), props.globals.getNode("instrumentation/transponder/inputs/digit[2]", 1), props.globals.getNode("instrumentation/transponder/inputs/digit[3]", 1)],
	serviceableNode: props.globals.getNode("instrumentation/transponder/serviceable", 1),
	knobNode: props.globals.getNode("instrumentation/transponder/inputs/knob-mode", 1),
	identNode: props.globals.getNode("instrumentation/transponder/inputs/ident-btn", 1),
	ac1Node: props.globals.getNode("/systems/electrical/bus/ac-1", 1),
	tcasNode: props.globals.getNode("instrumentation/tcas/inputs/mode"),
	aglNode: props.globals.getNode("position/gear-agl-ft", 1),
	electricNode: props.globals.getNode("/systems/electrical/outputs/transponder", 1), # communicate to generic systems
	new: func(elecSrc, ADIRS) {
		var t = {parents:[Transponder]};
		t.mode = 1;
		t.code = "2000";
		t.selected = 0;
		t.condition = 100;
		t.failed = 0;
		t.electricalSrc = props.globals.getNode(elecSrc, 1);
		t.activeADIRS = ADIRS;
		
		return t;
	},
	update: func() {
		# TCAS - on seperate electrical source, so has to be before transponder electrical checking
		if (me.ac1Node.getValue() < 110) {
			me.tcasNode.setValue(0); # off
		} else {
			if (me.mode >= 1 and me.mode <= 3) {
				me.tcasNode.setValue(1); # stby
			} else if (me.mode == 4 or (me.mode == 5 and me.aglNode.getValue() < 1000)) {
				me.tcasNode.setValue(2); # TA only
			} else if (me.mode == 5) {
				me.tcasNode.setValue(3); # TA/RA
			}
		}
		
		if (me.electricalSrc.getValue() > 110 and me.failed == 0) {
			me.condition = 100;
			transponderPanel.atcFailLight(0);
			me.electricNode.setValue(28);
			transponderPanel.modeSwitch(transponderPanel.modeSel);
		} else {
			me.condition = 0;
			transponderPanel.atcFailLight(1);
			me.setMode(0); # off
			if (me.electricalSrc.getValue() < 110) {
				me.electricNode.setValue(0);
			} else {
				me.electricNode.setValue(28);
			}
		}
		
		if (me.condition == 0 or me.selected != 1) {
			return;
		}
		
		if (me.mode == 1) {
			if (me.knobNode.getValue() != 1) {
				me.setMode(1); # stby
			}
		} else if (me.mode == 2) {
			if (me.knobNode.getValue() != 4) {
				me.setMode(4); # on
			}
		} else if (me.mode >= 3) {
			if (pts.Fdm.JSBsim.Position.wow.getBoolValue()) {
				if (me.knobNode.getValue() != 3) {
					me.setMode(3); # gnd
				}
			} else {
				if (me.knobNode.getValue() != 5) {
					me.setMode(5); # alt
				}
			}
		}
	},
	switchADIRS: func(newADIRS) {
		if (newADIRS < 1 or newADIRS > 3) {
			return;
		}
		me.activeADIRS = newADIRS;
		altimeter.setValue(newADIRS);
		airspeed.setValue(newADIRS);
	},
	modeSwitch: func(newMode) {
		me.mode = newMode;
	},
	setCode: func(newCode) {
		me.code = newCode;
		forLoopFlag = 1;
		for (index = 0; index < 4; index = index + 1) {
			me.codeDigitsNodes[3 - index].setValue(substr(me.code, index, 1));
		}
		forLoopFlag = 0;
	},
	setMode: func(m) {
		me.knobNode.setValue(m);
        guiNode.setValue(guiModes[m]);
	},
	fail: func() {
		me.failed = 1;
		me.serviceableNode.setBoolValue(0);
		transponderPanel.atcFailLight(1);
	},
	restore: func() {
		me.failed = 0;
		me.serviceableNode.setBoolValue(1);
		transponderPanel.atcFailLight(0);
	},
	ident: func() {
		me.identNode.setValue(0);
		settimer(func() {
			me.identNode.setValue(1);
		}, 0.1);
	},
};

var transponderPanel = {
	atcSel: 1,
	modeSel: 1,
	identBtn: 0,
	code: "2000",
	codeDisp: "2000",
	codeProp: props.globals.initNode("/systems/atc/transponder-code", "2000", "STRING"),
	failLight: 0,
	clearFlag: 0,
	keypad: func(keyNum) {
		if (props.globals.getNode("/controls/switches/annun-test", 1).getBoolValue() or props.globals.getNode("/systems/electrical/bus/dc-ess", 1).getValue() < 25) {
			return;
		}
		if (keyNum < 0 or keyNum > 7) {
			return;
		}
		
		if (size(me.codeDisp) < 3) {
			me.codeDisp = me.codeDisp ~ keyNum;
			me.codeProp.setValue(sprintf("%s", me.codeDisp));
		} elsif (size(me.codeDisp) == 3) {
			me.codeDisp = me.codeDisp ~ keyNum;
			me.codeProp.setValue(sprintf("%s", me.codeDisp));
			me.code = me.codeDisp;
			Transponders.vector[me.atcSel - 1].setCode(me.code);
		}
	},
	clearKey: func() {
		if (props.globals.getNode("/controls/switches/annun-test", 1).getBoolValue() or props.globals.getNode("/systems/electrical/bus/dc-ess", 1).getValue() < 25) {
			return;
		}
		if (me.codeDisp != "") {
			if (me.clearFlag == 0) {
				me.codeDisp = left(me.codeDisp, size(me.codeDisp) - 1);
				me.codeProp.setValue(sprintf("%s", me.codeDisp));
				me.clearFlag = 1;
			} else {
				me.codeDisp = "";
				me.codeProp.setValue(sprintf("%s", me.codeDisp));
			}
		}
	},
	atcSwitch: func(newSel) {
		if (newSel < 1 or newSel > 2) { 
			return;
		}
		me.atcSel = newSel;
		
		# update code
		if (me.newSel = 1) {
			Transponders.vector[1].selected = 0;
		} else {
			Transponders.vector[0].selected = 0;
		}
		
		Transponders.vector[me.atcSel - 1].selected = 1;
		me.code = Transponders.vector[me.atcSel - 1].code;
		me.codeDisp = me.code;
		me.codeProp.setValue(sprintf("%s", me.codeDisp));
		Transponders.vector[me.atcSel - 1].setCode(me.code); # update transmitted code to other transponders code
		me.clearFlag = 0;
		
		# update newly selected transponder
		Transponders.vector[me.atcSel - 1].modeSwitch(me.modeSel);
		me.atcFailLight(Transponders.vector[me.atcSel - 1].failed);
		
		me.updateAirData();
	},
	modeSwitch: func(newMode) {
		if (newMode < 0 or newMode > 5) {
			return;
		}
		me.modeSel = newMode;
		Transponders.vector[me.atcSel - 1].modeSwitch(me.modeSel);
	},
	atcFailLight: func(newFail) {
		if (newFail < 0 or newFail > 1) {
			return;
		}
		me.failLight = newFail;
		props.globals.getNode("/systems/atc/failed").setBoolValue(me.failLight);
	},
	identSwitch: func() {
		Transponders.vector[me.atcSel - 1].ident();
	},
	fastSetCode: func(newCode) {
		if (size(newCode) != 4 or size(me.codeDisp) != 4) {
			return;
		}
		me.clearFlag = 0;
		me.code = newCode;
		me.codeDisp = me.code;
		me.codeProp.setValue(sprintf("%s", me.codeDisp));
		Transponders.vector[me.atcSel - 1].setCode(me.code);
	},
	updateAirData: func() {
		if (me.atcSel == 1) {
			if (systems.SwitchingPanel.Switches.airData.getValue() == -1) {
				Transponders.vector[0].switchADIRS(3);
			} else {
				Transponders.vector[0].switchADIRS(1);
			}
		} else {
			if (systems.SwitchingPanel.Switches.airData.getValue() == 1) {
				Transponders.vector[1].switchADIRS(3);
			} else {
				Transponders.vector[1].switchADIRS(2);
			}
		}
		
		if (Transponders.vector[me.atcSel - 1].activeADIRS == 1) {
			me.updateADR1(systems.ADIRS.Operating.adr[0].getValue());
		} elsif (Transponders.vector[me.atcSel - 1].activeADIRS == 2) {
			me.updateADR2(systems.ADIRS.Operating.adr[1].getValue());
		} elsif (Transponders.vector[me.atcSel - 1].activeADIRS == 3) {
			me.updateADR3(systems.ADIRS.Operating.adr[2].getValue());
		}
	},
	updateADR1: func(val) {
		if (Transponders.vector[me.atcSel - 1].activeADIRS == 1) {
			if (val) {
				setprop("/instrumentation/tcas/serviceable", 1);
			} else {
				setprop("/instrumentation/tcas/serviceable", 0);
			}
		}
	},
	updateADR2: func(val) {
		if (Transponders.vector[me.atcSel - 1].activeADIRS == 2) {
			if (val) {
				setprop("/instrumentation/tcas/serviceable", 1);
			} else {
				setprop("/instrumentation/tcas/serviceable", 0);
			}
		}
	},
	updateADR3: func(val) {
		if (Transponders.vector[me.atcSel - 1].activeADIRS == 3) {
			if (val) {
				setprop("/instrumentation/tcas/serviceable", 1);
			} else {
				setprop("/instrumentation/tcas/serviceable", 0);
			}
		}
	},
};

var init = func() {
	transponderPanel.atcSwitch(1);
	transponderPanel.updateAirData();
	transponderTimer.start();
}

# Handler for code change from generic dialog
setlistener("/instrumentation/transponder/id-code", func {
	if (transponderPanel.code != idCode.getValue() and forLoopFlag == 0) {
		transponderPanel.fastSetCode(sprintf("%04d", idCode.getValue()));
	}
}, 0, 0);

var Transponders = std.Vector.new([Transponder.new("/systems/electrical/bus/ac-ess-shed", 1), Transponder.new("/systems/electrical/bus/ac-2", 2)]);
	
var transponderTimer = maketimer(0.1, func() {
	Transponders.vector[transponderPanel.atcSel - 1].update();
});

setlistener("/systems/navigation/adr/operating-1", func() {
	transponderPanel.updateADR1(systems.ADIRS.Operating.adr[0].getValue());
}, 1, 0);

setlistener("/systems/navigation/adr/operating-2", func() {
	transponderPanel.updateADR2(systems.ADIRS.Operating.adr[1].getValue());
}, 1, 0);

setlistener("/systems/navigation/adr/operating-3", func() {
	transponderPanel.updateADR3(systems.ADIRS.Operating.adr[2].getValue());
}, 1, 0);