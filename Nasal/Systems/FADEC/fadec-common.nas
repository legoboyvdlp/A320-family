# A3XX FADEC/Throttle Control System

# Copyright (c) 2020 Josh Davidson (Octal450)

if (getprop("options/eng") == "IAE") {
	io.include("fadec-iae.nas");
} else {
	io.include("fadec-cfm.nas");
}

var thr1 = 0;
var thr2 = 0;
var state1 = 0;
var state2 = 0;
var engstate1 = 0;
var engstate2 = 0;
var eprtoga = 0;
var eprmct = 0;
var eprflx = 0;
var eprclb = 0;
var n1toga = 0;
var n1mct = 0;
var n1flx = 0;
var n1clb = 0;
var alpha = 0;
var flaps = 0;
var alphaProt = 0;
var togaLock = 0;
var gs = 0;
setprop("/systems/thrust/epr/toga-lim", 0.0);
setprop("/systems/thrust/epr/mct-lim", 0.0);
setprop("/systems/thrust/epr/flx-lim", 0.0);
setprop("/systems/thrust/epr/clb-lim", 0.0);
setprop("/systems/thrust/n1/toga-lim", 0.0);
setprop("/systems/thrust/n1/mct-lim", 0.0);
setprop("/systems/thrust/n1/flx-lim", 0.0);
setprop("/systems/thrust/n1/clb-lim", 0.0);
setprop("/systems/thrust/toga-lim", 0.0);
setprop("/systems/thrust/mct-lim", 0.0);
setprop("/systems/thrust/clb-lim", 0.0);
setprop("/engines/flex-derate", 0);
setprop("/engines/flx-thr", 0.0);

setlistener("/sim/signals/fdm-initialized", func {
	thrust_loop.start();
	thrust_flash.start();
});

var Fadec = {
	n1Mode: [props.globals.getNode("/systems/fadec/n1mode1"), props.globals.getNode("/systems/fadec/n1mode2")],
};

var Thrust = {
	alphaFloor: props.globals.getNode("/systems/thrust/alpha-floor"),
	clbReduc: props.globals.getNode("/systems/thrust/clbreduc-ft"),
	eprLimit: props.globals.getNode("/controls/engines/epr-limit"),
	n1Limit: props.globals.getNode("/controls/engines/n1-limit"),
	limFlex: props.globals.getNode("/systems/thrust/lim-flex"),
	lvrClb: props.globals.getNode("/systems/thrust/lvrclb"),
	togaLk: props.globals.getNode("/systems/thrust/toga-lk"),
	thrustLimit: props.globals.getNode("/controls/engines/thrust-limit"),
	Lock: {
		thrLockAlert: props.globals.getNode("/systems/thrust/thr-locked-alert"),
		thrLockCmd: props.globals.getNode("/systems/thrust/thr-locked"),
		thrLockCmdN1: [props.globals.getNode("/systems/thrust/thr-lock-cmd[0]"), props.globals.getNode("/systems/thrust/thr-lock-cmd[1]")],
		thrLockFlash: props.globals.getNode("/systems/thrust/thr-locked-flash"),
		thrLockTime: props.globals.getNode("/systems/thrust/thr-locked-time"),
	},
};

setlistener("/controls/engines/engine[0]/throttle-pos", func {
	engstate1 = pts.Engines.Engine.state[0].getValue();
	engstate2 = pts.Engines.Engine.state[1].getValue();
	thr1 = pts.Controls.Engines.Engine.throttlePos[0].getValue();
	if (!Thrust.alphaFloor.getValue() and !Thrust.togaLk.getValue()) {
		if (thr1 < 0.01) {
			pts.Systems.Thrust.state[0].setValue("IDLE");
			unflex();
			atoff_request();
		} else if (thr1 >= 0.01 and thr1 < 0.60) {
			pts.Systems.Thrust.state[0].setValue("MAN");
			unflex();
		} else if (thr1 >= 0.60 and thr1 < 0.65) {
			pts.Systems.Thrust.state[0].setValue("CL");
			unflex();
		} else if (thr1 >= 0.65 and thr1 < 0.78) {
			pts.Systems.Thrust.state[0].setValue("MAN THR");
			unflex();
		} else if (thr1 >= 0.78 and thr1 < 0.83) {
			if (pts.Systems.Thrust.engOut.getValue() != 1) {
				if (Thrust.thrustLimit.getValue() == "FLX") {
					if (pts.Gear.wow[0].getValue() and (engstate1 == 3 or engstate2 == 3)) {
						fmgc.Input.athr.setValue(1);
					}
					pts.Controls.Engines.Engine.throttleFdm[0].setValue(0.99);
				} else {
					pts.Controls.Engines.Engine.throttleFdm[0].setValue(0.95);
				}
			}
			pts.Systems.Thrust.state[0].setValue("MCT");
		} else if (thr1 >= 0.83 and thr1 < 0.95) {
			pts.Systems.Thrust.state[0].setValue("MAN THR");
			unflex();
		} else if (thr1 >= 0.95) {
			if (pts.Gear.wow[0].getValue() and (engstate1 == 3 or engstate2 == 3)) {
				fmgc.Input.athr.setValue(1);
			}
			pts.Controls.Engines.Engine.throttleFdm[0].setValue(0.99);
			pts.Systems.Thrust.state[0].setValue("TOGA");
			unflex();
		}
	} else {
		if (thr1 < 0.01) {
			pts.Systems.Thrust.state[0].setValue("IDLE");
		} else if (thr1 >= 0.01 and thr1 < 0.60) {
			pts.Systems.Thrust.state[0].setValue("MAN");
		} else if (thr1 >= 0.60 and thr1 < 0.65) {
			pts.Systems.Thrust.state[0].setValue("CL");
		} else if (thr1 >= 0.65 and thr1 < 0.78) {
			pts.Systems.Thrust.state[0].setValue("MAN THR");
		} else if (thr1 >= 0.78 and thr1 < 0.83) {
			pts.Systems.Thrust.state[0].setValue("MCT");
		} else if (thr1 >= 0.83 and thr1 < 0.95) {
			pts.Systems.Thrust.state[0].setValue("MAN THR");
		} else if (thr1 >= 0.95) {
			pts.Systems.Thrust.state[0].setValue("TOGA");
		}
		pts.Controls.Engines.Engine.throttleFdm[0].setValue(0.99);
	}
}, 0, 0);

setlistener("/controls/engines/engine[1]/throttle-pos", func {
	engstate1 = pts.Engines.Engine.state[0].getValue();
	engstate2 = pts.Engines.Engine.state[1].getValue();
	thr2 = pts.Controls.Engines.Engine.throttlePos[1].getValue();
	if (!Thrust.alphaFloor.getValue() and !Thrust.togaLk.getValue()) {
		if (thr2 < 0.01) {
			pts.Systems.Thrust.state[1].setValue("IDLE");
			unflex();
			atoff_request();
		} else if (thr2 >= 0.01 and thr2 < 0.60) {
			pts.Systems.Thrust.state[1].setValue("MAN");
			unflex();
		} else if (thr2 >= 0.60 and thr2 < 0.65) {
			pts.Systems.Thrust.state[1].setValue("CL");
			unflex();
		} else if (thr2 >= 0.65 and thr2 < 0.78) {
			pts.Systems.Thrust.state[1].setValue("MAN THR");
			unflex();
		} else if (thr2 >= 0.78 and thr2 < 0.83) {
			if (pts.Systems.Thrust.engOut.getValue() != 1) {
				if (Thrust.thrustLimit.getValue() == "FLX") {
					if (pts.Gear.wow[0].getValue() and (engstate1 == 3 or engstate2 == 3)) {
						fmgc.Input.athr.setValue(1);
					}
					pts.Controls.Engines.Engine.throttleFdm[1].setValue(0.99);
				} else {
					pts.Controls.Engines.Engine.throttleFdm[1].setValue(0.95);
				}
			}
			pts.Systems.Thrust.state[1].setValue("MCT");
		} else if (thr2 >= 0.83 and thr2 < 0.95) {
			pts.Systems.Thrust.state[1].setValue("MAN THR");
			unflex();
		} else if (thr2 >= 0.95) {
			if (pts.Gear.wow[0].getValue() and (engstate1 == 3 or engstate2 == 3)) {
				fmgc.Input.athr.setValue(1);
			}
			pts.Controls.Engines.Engine.throttleFdm[1].setValue(0.99);
			pts.Systems.Thrust.state[1].setValue("TOGA");
			unflex();
		}
	} else {
		if (thr2 < 0.01) {
			pts.Systems.Thrust.state[1].setValue("IDLE");
		} else if (thr2 >= 0.01 and thr2 < 0.60) {
			pts.Systems.Thrust.state[1].setValue("MAN");
		} else if (thr2 >= 0.60 and thr2 < 0.65) {
			pts.Systems.Thrust.state[1].setValue("CL");
		} else if (thr2 >= 0.65 and thr2 < 0.78) {
			pts.Systems.Thrust.state[1].setValue("MAN THR");
		} else if (thr2 >= 0.78 and thr2 < 0.83) {
			pts.Systems.Thrust.state[1].setValue("MCT");
		} else if (thr2 >= 0.83 and thr2 < 0.95) {
			pts.Systems.Thrust.state[1].setValue("MAN THR");
		} else if (thr2 >= 0.95) {
			pts.Systems.Thrust.state[1].setValue("TOGA");
		}
		pts.Controls.Engines.Engine.throttleFdm[1].setValue(0.99);
	}
}, 0, 0);

# Alpha Floor and Toga Lock
setlistener("/it-autoflight/input/athr", func {
	if (Thrust.alphaFloor.getValue()) {
		fmgc.Input.athr.setValue(1);
	} else {
		Thrust.togaLk.setValue(0);
	}
});

# Checks if all throttles are in the IDLE position, before tuning off the A/THR.
var atoff_request = func {
	state1 = pts.Systems.Thrust.state[0].getValue();
	state2 = pts.Systems.Thrust.state[1].getValue();
	if (state1 == "IDLE" and state2 == "IDLE" and !Thrust.alphaFloor.getValue() and !Thrust.togaLk.getValue()) {
		if (fmgc.Input.athr.getValue() and pts.Position.gearAglFt.getValue() > 50) {
			fcu.athrOff("soft");
		} elsif (pts.Position.gearAglFt.getValue() < 50) {
			fcu.athrOff("none");
		}
	}
}

var thrust_loop = maketimer(0.04, func {
	state1 = pts.Systems.Thrust.state[0].getValue();
	state2 = pts.Systems.Thrust.state[1].getValue();
	engstate1 = pts.Engines.Engine.state[0].getValue();
	engstate2 = pts.Engines.Engine.state[1].getValue();
	thr1 = pts.Controls.Engines.Engine.throttlePos[0].getValue();
	thr2 = pts.Controls.Engines.Engine.throttlePos[1].getValue();
	eprtoga = getprop("/systems/thrust/epr/toga-lim");
	eprmct = getprop("/systems/thrust/epr/mct-lim");
	eprflx = getprop("/systems/thrust/epr/flx-lim");
	eprclb = getprop("/systems/thrust/epr/clb-lim");
	n1toga = getprop("/systems/thrust/n1/toga-lim");
	n1mct = getprop("/systems/thrust/n1/mct-lim");
	n1flx = getprop("/systems/thrust/n1/flx-lim");
	n1clb = getprop("/systems/thrust/n1/clb-lim");
	gs = pts.Velocities.groundspeed.getValue();
	if (fmgc.FMGCNodes.flexSet.getValue() and !Fadec.n1Mode[0].getValue() and !Fadec.n1Mode[1].getValue() and pts.Gear.wow[1].getValue() and pts.Gear.wow[2].getValue() and gs < 40) {
		Thrust.limFlex.setValue(1);
	} else if (!fmgc.FMGCNodes.flexSet.getValue() or engstate1 != 3 or engstate2 != 3) {
		Thrust.limFlex.setValue(0);
	}
	if (pts.Controls.Engines.Engine.reverser[0].getValue() or pts.Controls.Engines.Engine.reverser[1].getValue()) {
		Thrust.thrustLimit.setValue("MREV");
		Thrust.eprLimit.setValue(1.0);
		Thrust.n1Limit.setValue(0.0);
	} else if (!pts.Gear.wow[1].getValue() or !pts.Gear.wow[2].getValue() or (engstate1 != 3 and engstate2 != 3)) {
		if ((state1 == "TOGA" or state2 == "TOGA" or (state1 == "MAN THR" and thr1 >= 0.83) or (state2 == "MAN THR" and thr2 >= 0.83)) or Thrust.alphaFloor.getValue() or Thrust.togaLk.getValue()) {
			Thrust.thrustLimit.setValue("TOGA");
			Thrust.eprLimit.setValue(eprtoga);
			Thrust.n1Limit.setValue(n1toga);
		} else if ((state1 == "MCT" or state2 == "MCT" or (state1 == "MAN THR" and thr1 < 0.83) or (state2 == "MAN THR" and thr2 < 0.83)) and !Thrust.limFlex.getValue()) {
			Thrust.thrustLimit.setValue("MCT");
			Thrust.eprLimit.setValue(eprmct);
			Thrust.n1Limit.setValue(n1mct);
		} else if ((state1 == "MCT" or state2 == "MCT" or (state1 == "MAN THR" and thr1 < 0.83) or (state2 == "MAN THR" and thr2 < 0.83)) and Thrust.limFlex.getValue()) {
			Thrust.thrustLimit.setValue("FLX");
			Thrust.eprLimit.setValue(eprflx);
			Thrust.n1Limit.setValue(n1flx);
		} else if (state1 == "CL" or state2 == "CL" or state1 == "MAN" or state2 == "MAN" or state1 == "IDLE" or state2 == "IDLE") {
			Thrust.thrustLimit.setValue("CLB");
			Thrust.eprLimit.setValue(eprclb);
			Thrust.n1Limit.setValue(n1clb);
		}
	} else if (fmgc.FMGCNodes.flexSet.getValue() and !Fadec.n1Mode[0].getValue() and !Fadec.n1Mode[1].getValue()) {
		if ((state1 == "TOGA" or state2 == "TOGA" or (state1 == "MAN THR" and thr1 >= 0.83) or (state2 == "MAN THR" and thr2 >= 0.83)) or Thrust.alphaFloor.getValue() or Thrust.togaLk.getValue()) {
			Thrust.thrustLimit.setValue("TOGA");
			Thrust.eprLimit.setValue(eprtoga);
			Thrust.n1Limit.setValue(n1toga);
		} else {
			Thrust.thrustLimit.setValue("FLX");
			Thrust.eprLimit.setValue(eprflx);
			Thrust.n1Limit.setValue(n1flx);
		}
	} else {
		Thrust.thrustLimit.setValue("TOGA");
		Thrust.eprLimit.setValue(eprtoga);
		Thrust.n1Limit.setValue(n1toga);
	}
	
	alpha = pts.Fdm.JSBsim.Aero.alpha.getValue();
	flaps = pts.Controls.Flight.flapsPos.getValue();
	if (flaps == 0) {
		alphaProt = 9.5;
	} else if (flaps == 1 or flaps == 2 or flaps == 3) {
		alphaProt = 15.0;
	} else if (flaps == 4) {
		alphaProt = 14.0;
	} else if (flaps == 5) {
		alphaProt = 13.0;
	}
	
	togaLock = alphaProt - 1;
	if (!pts.Gear.wow[1].getValue() and !pts.Gear.wow[2].getValue() and fbw.FBW.activeLaw.getValue() == 0 and (!pts.Systems.Thrust.engOut.getValue() or (pts.Systems.Thrust.engOut.getValue() and flaps == 0)) and !Fadec.n1Mode[0].getValue() 
	and !Fadec.n1Mode[1].getValue()) {
		if (alpha > alphaProt and pts.Position.gearAglFt.getValue() >= 100) {
			Thrust.alphaFloor.setValue(1);
			Thrust.togaLk.setValue(0);
			fmgc.Input.athr.setValue(1);
			pts.Controls.Engines.Engine.throttleFdm[0].setValue(0.99);
			pts.Controls.Engines.Engine.throttleFdm[1].setValue(0.99);
		} else if (Thrust.alphaFloor.getValue() and alpha < togaLock) {
			fmgc.Input.athr.setValue(1);
			Thrust.alphaFloor.setValue(0);
			Thrust.togaLk.setValue(1);
			pts.Controls.Engines.Engine.throttleFdm[0].setValue(0.99);
			pts.Controls.Engines.Engine.throttleFdm[1].setValue(0.99);
		}
	} else {
		Thrust.alphaFloor.setValue(0);
		Thrust.togaLk.setValue(0);
	}
});

var unflex = func {
	state1 = pts.Systems.Thrust.state[0].getValue();
	state2 = pts.Systems.Thrust.state[1].getValue();
	if (state1 != "MCT" and state2 != "MCT" and !pts.Gear.wow[1].getValue() and !pts.Gear.wow[2].getValue()) {
		Thrust.limFlex.setValue(0);
	}
}

var thrust_flash = maketimer(0.5, func {
	state1 = pts.Systems.Thrust.state[0].getValue();
	state2 = pts.Systems.Thrust.state[1].getValue();
	
	if (!pts.Gear.wow[1].getValue() and !pts.Gear.wow[2].getValue() and (pts.Engines.Engine.state[0].getValue() != 3 or pts.Engines.Engine.state[1].getValue() != 3)) {
		pts.Systems.Thrust.engOut.setValue(1)
	} else {
		pts.Systems.Thrust.engOut.setValue(0)
	}
	
	if (state1 == "CL" and state2 == "CL" and pts.Systems.Thrust.engOut.getValue() != 1) {
		Thrust.lvrClb.setValue(0);
	} else if (state1 == "MCT" and state2 == "MCT" and !Thrust.limFlex.getValue() and pts.Systems.Thrust.engOut.getValue()) {
		Thrust.lvrClb.setValue(0);
	} else {
		var status = Thrust.lvrClb.getValue();
		if (status == 0) {
			if (!pts.Gear.wow[0].getValue()) {
				if (pts.Systems.Thrust.state[0].getValue() == "MAN" or pts.Systems.Thrust.state[1].getValue() == "MAN") {
					Thrust.lvrClb.setValue(1);
				} else {
					if (pts.Instrumentation.Altimeter.indicatedFt.getValue() >= Thrust.clbReduc.getValue() and !pts.Gear.wow[1].getValue() and !pts.Gear.wow[2].getValue()) {
						Thrust.lvrClb.setValue(1);
					} else if ((state1 == "CL" and state2 != "CL") or (state1 != "CL" and state2 == "CL") and pts.Systems.Thrust.engOut.getValue() != 1) {
						Thrust.lvrClb.setValue(1);
					} else {
						Thrust.lvrClb.setValue(0);
					}
				}
			}
		} else if (status == 1) {
			Thrust.lvrClb.setValue(0);
		}
	}
});

var lockThr = func() {
	state1 = pts.Systems.Thrust.state[0].getValue();
	state2 = pts.Systems.Thrust.state[1].getValue();
	if ((state1 == "CL" and state2 == "CL" and !pts.Systems.Thrust.engOut.getValue()) or (state1 == "MCT" and state2 == "MCT" and pts.Systems.Thrust.engOut.getValue())) {
		Thrust.Lock.thrLockTime.setValue(pts.Sim.Time.elapsedSec.getValue());
		Thrust.Lock.thrLockCmd.setValue(1);
		lockTimer.start();
	}
}

var checkLockThr = func() {
	if (Thrust.Lock.thrLockTime.getValue() + 5 > pts.Sim.Time.elapsedSec.getValue()) { return; }
	
	if (fmgc.Output.athr.getBoolValue()) {
		lockTimer.stop();
		Thrust.Lock.thrLockCmd.setValue(0);
		Thrust.Lock.thrLockAlert.setValue(0);
		Thrust.Lock.thrLockTime.setValue(0);
		Thrust.Lock.thrLockFlash.setValue(0);
		return;
	}
	
	if (!Thrust.Lock.thrLockCmd.getValue()) {
		lockTimer.stop();
		Thrust.Lock.thrLockCmd.setValue(0);
		Thrust.Lock.thrLockAlert.setValue(0);
		Thrust.Lock.thrLockTime.setValue(0);
		Thrust.Lock.thrLockFlash.setValue(0);
		return;
	}
	
	state1 = pts.Systems.Thrust.state[0].getValue();
	state2 = pts.Systems.Thrust.state[1].getValue();
	
	if ((state1 != "CL" and state2 != "CL" and !pts.Systems.Thrust.engOut.getValue()) or (state1 != "MCT" and state2 != "MCT" and pts.Systems.Thrust.engOut.getValue())) {
		lockTimer.stop();
		Thrust.Lock.thrLockCmd.setValue(0);
		Thrust.Lock.thrLockAlert.setValue(0);
		Thrust.Lock.thrLockTime.setValue(0);
		Thrust.Lock.thrLockFlash.setValue(0);
	} elsif ((state1 == "CL" and state2 == "CL" and !pts.Systems.Thrust.engOut.getValue()) or (state1 == "MCT" and state2 == "MCT" and pts.Systems.Thrust.engOut.getValue())) {
		Thrust.Lock.thrLockAlert.setValue(1);
		Thrust.Lock.thrLockTime.setValue(pts.Sim.Time.elapsedSec.getValue());
		Thrust.Lock.thrLockFlash.setValue(1);
		lockTimer.stop();
		lockTimer2.start();
	}
}

var checkLockThr2 = func() {
	if (fmgc.Output.athr.getBoolValue()) {
		lockTimer2.stop();
		Thrust.Lock.thrLockCmd.setValue(0);
		Thrust.Lock.thrLockAlert.setValue(0);
		Thrust.Lock.thrLockTime.setValue(0);
		Thrust.Lock.thrLockFlash.setValue(0);
		return;
	}
	
	if (!Thrust.Lock.thrLockCmd.getValue()) {
		lockTimer2.stop();
		Thrust.Lock.thrLockCmd.setValue(0);
		Thrust.Lock.thrLockAlert.setValue(0);
		Thrust.Lock.thrLockTime.setValue(0);
		Thrust.Lock.thrLockFlash.setValue(0);
		return;
	}
	
	if (Thrust.Lock.thrLockTime.getValue() + 5 < pts.Sim.Time.elapsedSec.getValue()) {
		Thrust.Lock.thrLockFlash.setValue(0);
		settimer(func() {
			Thrust.Lock.thrLockFlash.setValue(1);
			Thrust.Lock.thrLockTime.setValue(pts.Sim.Time.elapsedSec.getValue());
			ecam.athr_lock.noRepeat = 0;
			ecam.athr_lock.noRepeat2 = 0;
		}, 0.2);
	}
	
	state1 = pts.Systems.Thrust.state[0].getValue();
	state2 = pts.Systems.Thrust.state[1].getValue();
	
	
	if ((state1 != "CL" and state2 != "CL" and !pts.Systems.Thrust.engOut.getValue()) or (state1 != "MCT" and state2 != "MCT" and pts.Systems.Thrust.engOut.getValue())) {
		lockTimer2.stop();
		Thrust.Lock.thrLockCmd.setValue(0);
		Thrust.Lock.thrLockAlert.setValue(0);
		Thrust.Lock.thrLockFlash.setValue(0);
		Thrust.Lock.thrLockTime.setValue(0);
	}
}

setlistener("/systems/thrust/thr-locked", func {
	if (Thrust.Lock.thrLockCmd.getValue()) {
		Thrust.Lock.thrLockCmdN1[0].setValue(pts.Controls.Engines.Engine.throttleOutput[0].getValue());
		Thrust.Lock.thrLockCmdN1[1].setValue(pts.Controls.Engines.Engine.throttleOutput[1].getValue());
	}
}, 0, 0);

var lockTimer = maketimer(0.1, checkLockThr);
var lockTimer2 = maketimer(0.1, checkLockThr2);
