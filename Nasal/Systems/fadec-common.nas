# A3XX FADEC/Throttle Control System
# Copyright (c) 2021 Josh Davidson (Octal450)

if (pts.Options.eng.getValue() == "IAE") {
	io.include("fadec-iae.nas");
} else {
	io.include("fadec-cfm.nas");
}

var FADEC = {
	alphaFloor: props.globals.getNode("/fdm/jsbsim/fadec/alpha-floor"),
	clbReduc: props.globals.getNode("/fdm/jsbsim/fadec/clbreduc-ft"),
	detentOut: [props.globals.getNode("/fdm/jsbsim/fadec/control-1/detent-out", 1), props.globals.getNode("/fdm/jsbsim/fadec/control-2/detent-out", 1)],
	detentOutTemp: [0, 0],
	detentText: [props.globals.getNode("/fdm/jsbsim/fadec/control-1/detent-text"), props.globals.getNode("/fdm/jsbsim/fadec/control-2/detent-text")],
	detentTextTemp: [0, 0],
	engOut: props.globals.getNode("/fdm/jsbsim/fadec/eng-out"),
	Limit: {
		activeEpr: props.globals.getNode("/fdm/jsbsim/fadec/limit/active-epr"),
		activeMode: props.globals.getNode("/fdm/jsbsim/fadec/limit/active-mode"),
		activeN1: props.globals.getNode("/fdm/jsbsim/fadec/limit/active-n1"),
		flexActive: props.globals.getNode("/fdm/jsbsim/fadec/limit/flex-active"),
		flexActiveCmd: props.globals.getNode("/fdm/jsbsim/fadec/limit/flex-active-cmd"),
		flexTemp: props.globals.getNode("/fdm/jsbsim/fadec/limit/flex-temp"),
	},
	lvrClb: props.globals.getNode("/fdm/jsbsim/fadec/lvrclb"),
	lvrClbStatus: 0,
	togaLk: props.globals.getNode("/fdm/jsbsim/fadec/toga-lk"),
	thrustLimit: props.globals.getNode("/controls/engines/thrust-limit"),
	Lock: {
		thrLockAlert: props.globals.getNode("/fdm/jsbsim/fadec/thr-locked-alert"),
		thrLockCmd: props.globals.getNode("/fdm/jsbsim/fadec/thr-locked"),
		thrLockCmdN1: [props.globals.getNode("/fdm/jsbsim/fadec/thr-lock-cmd[0]"), props.globals.getNode("/fdm/jsbsim/fadec/thr-lock-cmd[1]")],
		thrLockFlash: props.globals.getNode("/fdm/jsbsim/fadec/thr-locked-flash"),
		thrLockTime: props.globals.getNode("/fdm/jsbsim/fadec/thr-locked-time"),
	},
	manThrAboveMct: [0, 0],
	n1Mode: [props.globals.getNode("/fdm/jsbsim/fadec/control-1/n1-mode"), props.globals.getNode("/fdm/jsbsim/fadec/control-2/n1-mode")],
	init: func() {
		me.engOut.setBoolValue(0);
		me.Limit.activeMode.setBoolValue("TOGA");
		me.Limit.flexActive.setBoolValue(0);
		me.Limit.flexActiveCmd.setBoolValue(0);
		systems.FADEC_S.init();
		thrustFlashT.start();
	},
	canEngageAthr: func() {
		if (pts.Gear.wow[0].getValue() and (pts.Engines.Engine.state[0].getValue() == 3 or pts.Engines.Engine.state[1].getValue() == 3)) {
			return 1;
		} else {
			return 0;
		}
	},
	cancelFlex: func() {
		if (me.detentOut[0].getValue() != 4 and me.detentOut[1].getValue() != 4 and !pts.Gear.wow[1].getValue() and !pts.Gear.wow[2].getValue()) {
			me.Limit.flexActive.setBoolValue(0);
		}
	},
	idleAthrOff: func() {
		if (me.detentOut[0].getValue() == 0 and me.detentOut[1].getValue() == 0) { # And not in TOGA LK and not in ALPHA FLOOR
			if (fmgc.Input.athr.getValue() and pts.Position.gearAglFt.getValue() > 50) {
				fcu.athrOff("soft");
			} else {
				fcu.athrOff("none");
			}
		}
	},
	updateDetent: func(n) {
		me.detentOutTemp[n] = me.detentOut[n].getValue();
		if (me.detentOutTemp[n] == 6) {
			me.manThrAboveMct[n] = 1;
			me.detentText[n].setValue("TOGA");
			if (!fmgc.Output.athr.getBoolValue() and me.canEngageAthr()) {
				fmgc.Input.athr.setValue(1);
			}
		} else if (me.detentOutTemp[n] == 5) {
			me.manThrAboveMct[n] = 1;
			me.detentText[n].setValue("MAN THR");
		} else if (me.detentOutTemp[n] == 4) {
			me.manThrAboveMct[n] = 0;
			me.detentText[n].setValue("MCT");
			if (me.engOut.getValue() != 1 and me.Limit.flexActive.getBoolValue()) {
				if (!fmgc.Output.athr.getBoolValue() and me.canEngageAthr()) {
					fmgc.Input.athr.setValue(1);
				}
			}
		} else if (me.detentOutTemp[n] == 3) {
			me.manThrAboveMct[n] = 0;
			me.detentText[n].setValue("MAN THR");
		} else if (me.detentOutTemp[n] == 2) {
			me.manThrAboveMct[n] = 0;
			me.detentText[n].setValue("CL");
		} else if (me.detentOutTemp[n] == 1) {
			me.manThrAboveMct[n] = 0;
			me.detentText[n].setValue("MAN");
		} else if (me.detentOutTemp[n] == 0) {
			me.manThrAboveMct[n] = 0;
			me.detentText[n].setValue("IDLE");
			me.idleAthrOff();
		}
		
		if (me.detentOutTemp[n] != 4) {
			if (me.Limit.flexActiveCmd.getBoolValue()) {
				me.cancelFlex();
			}
		}
	},
	loop: func() {
		FADEC_S.loop();
	},
	thrustFlash: func() {
		me.detentTextTemp[0] = systems.FADEC.detentText[0].getValue();
		me.detentTextTemp[1] = systems.FADEC.detentText[1].getValue();
		
		if (!pts.Gear.wow[1].getValue() and !pts.Gear.wow[2].getValue() and (pts.Engines.Engine.state[0].getValue() != 3 or pts.Engines.Engine.state[1].getValue() != 3)) {
			systems.FADEC.engOut.setValue(1)
		} else {
			systems.FADEC.engOut.setValue(0)
		}
		
		if (me.detentTextTemp[0] == "CL" and me.detentTextTemp[1] == "CL" and me.engOut.getValue() != 1) {
			me.lvrClb.setValue(0);
		} else if (me.detentTextTemp[0] == "MCT" and me.detentTextTemp[1] == "MCT" and !me.Limit.flexActive.getBoolValue() and me.engOut.getValue()) {
			me.lvrClb.setValue(0);
		} else {
			me.lvrClbStatus = me.lvrClb.getValue();
			if (me.lvrClbStatus == 0) {
				if (!pts.Gear.wow[0].getValue()) {
					if (systems.FADEC.detentText[0].getValue() == "MAN" or systems.FADEC.detentText[1].getValue() == "MAN") {
						me.lvrClb.setValue(1);
					} else {
						if (pts.Instrumentation.Altimeter.indicatedFt.getValue() >= me.clbReduc.getValue() and !pts.Gear.wow[1].getValue() and !pts.Gear.wow[2].getValue()) {
							me.lvrClb.setValue(1);
						} else if ((me.detentTextTemp[0] == "CL" and me.detentTextTemp[1] != "CL") or (me.detentTextTemp[0] != "CL" and me.detentTextTemp[1] == "CL") and me.engOut.getValue() != 1) {
							me.lvrClb.setValue(1);
						} else {
							me.lvrClb.setValue(0);
						}
					}
				}
			} else if (me.lvrClbStatus == 1) {
				me.lvrClb.setValue(0);
			}
		}
	},
};

var thrustFlashT = maketimer(0.5, FADEC, FADEC.thrustFlash);

setlistener("/fdm/jsbsim/fadec/control-1/detent-out", func {
	FADEC.updateDetent(0);
}, 0, 0);
setlistener("/fdm/jsbsim/fadec/control-2/detent-out", func {
	FADEC.updateDetent(1);
}, 0, 0);
