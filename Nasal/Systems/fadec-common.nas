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
	detent: [props.globals.getNode("/fdm/jsbsim/fadec/control-1/detent", 1), props.globals.getNode("/fdm/jsbsim/fadec/control-2/detent", 1)],
	detentTemp: [0, 0],
	detentText: [props.globals.getNode("/fdm/jsbsim/fadec/control-1/detent-text"), props.globals.getNode("/fdm/jsbsim/fadec/control-2/detent-text")],
	detentTextTemp: [0, 0],
	engOut: props.globals.getNode("/fdm/jsbsim/fadec/eng-out"),
	Limit: {
		activeEpr: props.globals.getNode("/fdm/jsbsim/fadec/limit/active-epr"),
		activeMode: props.globals.getNode("/fdm/jsbsim/fadec/limit/active-mode"),
		activeModeInt: props.globals.getNode("/fdm/jsbsim/fadec/limit/active-mode-int"), # 0 TOGA, 1 MCT, 2 CL, 3 FLX, 4 MREV
		activeModeIntTemp: 0,
		activeN1: props.globals.getNode("/fdm/jsbsim/fadec/limit/active-n1"),
		flexActive: props.globals.getNode("/fdm/jsbsim/fadec/limit/flex-active"),
		flexActiveCmd: props.globals.getNode("/fdm/jsbsim/fadec/limit/flex-active-cmd"),
		flexTemp: props.globals.getNode("/fdm/jsbsim/fadec/limit/flex-temp"),
	},
	lvrClb: props.globals.getNode("/fdm/jsbsim/fadec/lvrclb"),
	lvrClbStatus: 0,
	Lock: {
		thrLockAlert: props.globals.getNode("/fdm/jsbsim/fadec/thr-locked-alert"),
		thrLockCmd: props.globals.getNode("/fdm/jsbsim/fadec/thr-locked"),
		thrLockFlash: props.globals.getNode("/fdm/jsbsim/fadec/thr-locked-flash"),
		thrLockTime: props.globals.getNode("/fdm/jsbsim/fadec/thr-locked-time"),
	},
	manThrAboveMct: [0, 0],
	maxDetent: props.globals.getNode("/fdm/jsbsim/fadec/max-detent"),
	n1Mode: [props.globals.getNode("/fdm/jsbsim/fadec/control-1/n1-mode"), props.globals.getNode("/fdm/jsbsim/fadec/control-2/n1-mode")],
	togaLk: props.globals.getNode("/fdm/jsbsim/fadec/toga-lk"),
	init: func() {
		me.engOut.setBoolValue(0);
		me.Limit.activeMode.setBoolValue("TOGA");
		me.Limit.activeModeInt.setValue(0);
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
		if (me.detent[0].getValue() != 4 and me.detent[1].getValue() != 4 and !pts.Gear.wow[1].getValue() and !pts.Gear.wow[2].getValue()) {
			me.Limit.flexActive.setBoolValue(0);
		}
	},
	idleAthrOff: func() {
		if (me.detent[0].getValue() == 0 and me.detent[1].getValue() == 0) { # And not in TOGA LK and not in ALPHA FLOOR
			if (fmgc.Input.athr.getValue() and pts.Position.gearAglFt.getValue() > 50) {
				fcu.athrOff("soft");
			} else {
				fcu.athrOff("none");
			}
		}
	},
	updateDetent: func(n) {
		me.detentTemp[n] = me.detent[n].getValue();
		if (me.detentTemp[n] == 6) {
			me.manThrAboveMct[n] = 1;
			me.detentText[n].setValue("TOGA");
			if (!fmgc.Output.athr.getBoolValue() and me.canEngageAthr()) {
				fmgc.Input.athr.setValue(1);
			}
		} else if (me.detentTemp[n] == 5) {
			me.manThrAboveMct[n] = 1;
			me.detentText[n].setValue("MAN THR");
		} else if (me.detentTemp[n] == 4) {
			me.manThrAboveMct[n] = 0;
			me.detentText[n].setValue("MCT");
			if (me.engOut.getValue() != 1 and me.Limit.flexActive.getBoolValue()) {
				if (!fmgc.Output.athr.getBoolValue() and me.canEngageAthr()) {
					fmgc.Input.athr.setValue(1);
				}
			}
		} else if (me.detentTemp[n] == 3) {
			me.manThrAboveMct[n] = 0;
			me.detentText[n].setValue("MAN THR");
		} else if (me.detentTemp[n] == 2) {
			me.manThrAboveMct[n] = 0;
			me.detentText[n].setValue("CL");
		} else if (me.detentTemp[n] == 1) {
			me.manThrAboveMct[n] = 0;
			me.detentText[n].setValue("MAN");
		} else if (me.detentTemp[n] == 0) {
			me.manThrAboveMct[n] = 0;
			me.detentText[n].setValue("IDLE");
			me.idleAthrOff();
		}
		
		if (me.detentTemp[n] != 4) {
			if (me.Limit.flexActiveCmd.getBoolValue()) {
				me.cancelFlex();
			}
		}
	},
	loop: func() {
		FADEC_S.loop(); # Update engine specific elements
		pts.Engines.Engine.stateTemp[0] = pts.Engines.Engine.state[0].getValue();
		pts.Engines.Engine.stateTemp[1] = pts.Engines.Engine.state[1].getValue();
		pts.Gear.wowTemp[1] = pts.Gear.wow[1].getValue();
		pts.Gear.wowTemp[2] = pts.Gear.wow[2].getValue();
		
		if (me.Limit.flexActiveCmd.getBoolValue() and !me.n1Mode[0].getValue() and !me.n1Mode[1].getValue() and pts.Gear.wowTemp[1] and pts.Gear.wowTemp[2] and pts.Velocities.groundspeedKt.getValue() < 40 and (pts.Engines.Engine.stateTemp[0] == 3 or pts.Engines.Engine.stateTemp[1] == 3)) {
			if (!me.Limit.flexActive.getBoolValue()) {
				me.Limit.flexActive.setBoolValue(1);
			}
		} else if (!me.Limit.flexActiveCmd.getBoolValue() or pts.Engines.Engine.stateTemp[0] != 3 or pts.Engines.Engine.stateTemp[1] != 3) {
			if (me.Limit.flexActive.getBoolValue()) {
				me.Limit.flexActive.setBoolValue(0);
			}
		}
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
	updateTxt: func() {
		me.Limit.activeModeIntTemp = me.Limit.activeModeInt.getValue();
		if (me.Limit.activeModeIntTemp == 0) {
			me.Limit.activeMode.setValue("TOGA");
		} else if (me.Limit.activeModeIntTemp == 1) {
			me.Limit.activeMode.setValue("MCT");
		} else if (me.Limit.activeModeIntTemp == 2) {
			me.Limit.activeMode.setValue("CLB");
		} else if (me.Limit.activeModeIntTemp == 3) {
			me.Limit.activeMode.setValue("FLX");
		} else if (me.Limit.activeModeIntTemp == 4) {
			me.Limit.activeMode.setValue("MREV");
		}
	},
};

var thrustFlashT = maketimer(0.5, FADEC, FADEC.thrustFlash);

setlistener("/fdm/jsbsim/fadec/control-1/detent", func() {
	FADEC.updateDetent(0);
}, 0, 0);
setlistener("/fdm/jsbsim/fadec/control-2/detent", func() {
	FADEC.updateDetent(1);
}, 0, 0);
setlistener("/fdm/jsbsim/fadec/limit/active-mode-int", func() {
	FADEC.updateTxt();
}, 0, 0);

var lockThr = func() {
	state1 = systems.FADEC.detentText[0].getValue();
	state2 = systems.FADEC.detentText[1].getValue();
	if ((state1 == "CL" and state2 == "CL" and !systems.FADEC.engOut.getValue()) or (state1 == "MCT" and state2 == "MCT" and systems.FADEC.engOut.getValue())) {
		FADEC.Lock.thrLockTime.setValue(pts.Sim.Time.elapsedSec.getValue());
		FADEC.Lock.thrLockCmd.setValue(1);
		lockTimer.start();
	}
}

var checkLockThr = func() {
	if (FADEC.Lock.thrLockTime.getValue() + 5 > pts.Sim.Time.elapsedSec.getValue()) { return; }
	
	if (fmgc.Output.athr.getBoolValue()) {
		lockTimer.stop();
		FADEC.Lock.thrLockCmd.setValue(0);
		FADEC.Lock.thrLockAlert.setValue(0);
		FADEC.Lock.thrLockTime.setValue(0);
		FADEC.Lock.thrLockFlash.setValue(0);
		return;
	}
	
	if (!FADEC.Lock.thrLockCmd.getValue()) {
		lockTimer.stop();
		FADEC.Lock.thrLockCmd.setValue(0);
		FADEC.Lock.thrLockAlert.setValue(0);
		FADEC.Lock.thrLockTime.setValue(0);
		FADEC.Lock.thrLockFlash.setValue(0);
		return;
	}
	
	state1 = systems.FADEC.detentText[0].getValue();
	state2 = systems.FADEC.detentText[1].getValue();
	
	if ((state1 != "CL" and state2 != "CL" and !systems.FADEC.engOut.getValue()) or (state1 != "MCT" and state2 != "MCT" and systems.FADEC.engOut.getValue())) {
		lockTimer.stop();
		FADEC.Lock.thrLockCmd.setValue(0);
		FADEC.Lock.thrLockAlert.setValue(0);
		FADEC.Lock.thrLockTime.setValue(0);
		FADEC.Lock.thrLockFlash.setValue(0);
	} elsif ((state1 == "CL" and state2 == "CL" and !systems.FADEC.engOut.getValue()) or (state1 == "MCT" and state2 == "MCT" and systems.FADEC.engOut.getValue())) {
		FADEC.Lock.thrLockAlert.setValue(1);
		FADEC.Lock.thrLockTime.setValue(pts.Sim.Time.elapsedSec.getValue());
		FADEC.Lock.thrLockFlash.setValue(1);
		lockTimer.stop();
		lockTimer2.start();
	}
}

var checkLockThr2 = func() {
	if (fmgc.Output.athr.getBoolValue()) {
		lockTimer2.stop();
		FADEC.Lock.thrLockCmd.setValue(0);
		FADEC.Lock.thrLockAlert.setValue(0);
		FADEC.Lock.thrLockTime.setValue(0);
		FADEC.Lock.thrLockFlash.setValue(0);
		return;
	}
	
	if (!FADEC.Lock.thrLockCmd.getValue()) {
		lockTimer2.stop();
		FADEC.Lock.thrLockCmd.setValue(0);
		FADEC.Lock.thrLockAlert.setValue(0);
		FADEC.Lock.thrLockTime.setValue(0);
		FADEC.Lock.thrLockFlash.setValue(0);
		return;
	}
	
	if (FADEC.Lock.thrLockTime.getValue() + 5 < pts.Sim.Time.elapsedSec.getValue()) {
		FADEC.Lock.thrLockFlash.setValue(0);
		settimer(func() {
			FADEC.Lock.thrLockFlash.setValue(1);
			FADEC.Lock.thrLockTime.setValue(pts.Sim.Time.elapsedSec.getValue());
			ecam.athr_lock.noRepeat = 0;
			ecam.athr_lock.noRepeat2 = 0;
		}, 0.2);
	}
	
	state1 = systems.FADEC.detentText[0].getValue();
	state2 = systems.FADEC.detentText[1].getValue();
	
	if ((state1 != "CL" and state2 != "CL" and !systems.FADEC.engOut.getValue()) or (state1 != "MCT" and state2 != "MCT" and systems.FADEC.engOut.getValue())) {
		lockTimer2.stop();
		FADEC.Lock.thrLockCmd.setValue(0);
		FADEC.Lock.thrLockAlert.setValue(0);
		FADEC.Lock.thrLockFlash.setValue(0);
		FADEC.Lock.thrLockTime.setValue(0);
	}
}

var lockTimer = maketimer(0.1, checkLockThr);
var lockTimer2 = maketimer(0.1, checkLockThr2);
