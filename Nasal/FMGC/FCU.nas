# A3XX FCU
# Copyright (c) 2020 Josh Davidson (Octal450), Jonathan Redpath (legoboyvdlp)

# Nodes
var fd1 = props.globals.getNode("/it-autoflight/output/fd1", 1);
var fd2 = props.globals.getNode("/it-autoflight/output/fd2", 1);
var ap1 = props.globals.getNode("/it-autoflight/output/ap1", 1);
var ap2 = props.globals.getNode("/it-autoflight/output/ap2", 1);
var athr = props.globals.getNode("/it-autoflight/output/athr", 1);
var fd1Input = props.globals.getNode("/it-autoflight/input/fd1", 1);
var fd2Input = props.globals.getNode("/it-autoflight/input/fd2", 1);
var ap1Input = props.globals.getNode("/it-autoflight/input/ap1", 1);
var ap2Input = props.globals.getNode("/it-autoflight/input/ap2", 1);
var athrInput = props.globals.getNode("/it-autoflight/input/athr", 1);
var ktsMach = props.globals.getNode("/it-autoflight/input/kts-mach", 1);
var iasSet = props.globals.getNode("/it-autoflight/input/kts", 1);
var machSet = props.globals.getNode("/it-autoflight/input/mach", 1);
var hdgSet = props.globals.getNode("/it-autoflight/input/hdg", 1);
var altSet = props.globals.getNode("/it-autoflight/input/alt", 1);
var altSetMode = props.globals.getNode("/it-autoflight/config/altitude-dial-mode", 1);
var vsSet = props.globals.getNode("/it-autoflight/input/vs", 1);
var fpaSet = props.globals.getNode("/it-autoflight/input/fpa", 1);
var iasNow = props.globals.getNode("/instrumentation/airspeed-indicator/indicated-speed-kt", 1);
var machNow = props.globals.getNode("/instrumentation/airspeed-indicator/indicated-mach", 1);
var spdManaged = props.globals.getNode("/it-autoflight/input/spd-managed", 1);
var showHDG = props.globals.getNode("/it-autoflight/custom/show-hdg", 1);
var trkFpaSW = props.globals.getNode("/it-autoflight/custom/trk-fpa", 1);
var latMode = props.globals.getNode("/it-autoflight/output/lat", 1);
var vertMode = props.globals.getNode("/it-autoflight/output/vert", 1);
var fpaModeInput = props.globals.getNode("/it-autoflight/input/fpa", 1);
var latModeInput = props.globals.getNode("/it-autoflight/input/lat", 1);
var vertModeInput = props.globals.getNode("/it-autoflight/input/vert", 1);
var vsModeInput = props.globals.getNode("/it-autoflight/input/vs", 1);
var locArm = props.globals.getNode("/it-autoflight/output/loc-armed", 1);
var apprArm = props.globals.getNode("/it-autoflight/output/appr-armed", 1);
var FCUworkingNode = props.globals.initNode("/FMGC/FCU-working", 0, "BOOL");

var FCU = {
	elecSupply: "",
	failed: 0,
	condition: 100,
	new: func(elecNode) {
        var f = { parents:[FCU] };
		f.elecSupply = elecNode;
        return f;
    },
	loop: func() {
		me.failed = (me.elecSupply.getValue() < 25 or me.condition == 0) ? 1 : 0;
	},
	setFail: func() {
		me.condition = 0;
	},
	restore: func() {
		me.condition = 100;
	},
};

var FCUController = {
	FCU1: nil,
	FCU2: nil,
	activeFMGC: props.globals.getNode("/FMGC/active-fmgc-channel"),
	FCUworking: 0,
	_init: 0,
	init: func() {
		me.FCU1 = FCU.new(systems.ELEC.Bus.dcEss);
		me.FCU2 = FCU.new(systems.ELEC.Bus.dc2);
		me._init = 1;
	},
	loop: func() {
		if (me._init == 0) { return; }
		
		# Update FCU Power
		me.FCU1.loop();
		me.FCU2.loop();
		
		if (!me.FCU1.failed or !me.FCU2.failed) {
			me.FCUworking = 1;
			FCUworkingNode.setValue(1);
		} else {
			me.FCUworking = 0;
			FCUworkingNode.setValue(0);
		}
		
		foreach (var update_item; me.update_items) {
			update_item.update(nil);
		}
	},
	update_items: [
		props.UpdateManager.FromPropertyHashList(["/it-autoflight/output/fd1","/it-autoflight/output/fd2", "/it-autoflight/output/ap1", "/it-autoflight/output/ap2"], 1, func(notification)
			{
				updateActiveFMGC();
			}
		),
	],
	resetFail: func() {
		if (me._init == 0) { return; }
		me.FCU1.restore();
		me.FCU2.restore();
	},
	AP1: func() {
		if (me.FCUworking) {
			if (!ap1.getBoolValue() and fbw.FBW.apOff == 0) {
				ap1Input.setValue(1);
				ecam.apWarnNode.setValue(0);
				pts.Controls.Flight.rudderTrim.setValue(0);
			} else {
				apOff("hard", 1);
			}
		}
	},
	AP2: func() {
		if (me.FCUworking) {
			if (!ap2.getBoolValue() and fbw.FBW.apOff == 0) {
				ap2Input.setValue(1);
				ecam.apWarnNode.setValue(0);
				pts.Controls.Flight.rudderTrim.setValue(0);
			} else {
				apOff("hard", 2);
			}
		}
	},
	ATHR: func() {
		if (me.FCUworking) {
			if (!athr.getBoolValue() and !pts.FMGC.CasCompare.casRejectAll.getBoolValue() and fbw.FBW.apOff == 0) {
				athrInput.setValue(1);
			} else {
				athrOff("hard");
			}
		}
	},
	FD1: func() {
		if (me.FCUworking) {
			if (!fd1.getBoolValue()) {
				fd1Input.setValue(1);
			} else {
				fd1Input.setValue(0);
			}
		}
	},
	FD2: func() {
		if (me.FCUworking) {
			if (!fd2.getBoolValue()) {
				fd2Input.setValue(1);
			} else {
				fd2Input.setValue(0);
			}
		}
	},
	APDisc: func() {
		# physical button sound - so put it outside here as you get a sound even if it doesn't work!
		setprop("/sim/sounde/apdiscbtn", 1);
		settimer(func {
			setprop("/sim/sounde/apdiscbtn", 0);
		}, 0.5);
		
		if (me.FCUworking) {
			if (ap1.getBoolValue() or ap2.getBoolValue()) {
				apOff("soft", 0);
			} else {
				if (getprop("/it-autoflight/sound/apoffsound") == 1 or getprop("/it-autoflight/sound/apoffsound2") == 1) {
					setprop("/it-autoflight/sound/apoffsound", 0);
					setprop("/it-autoflight/sound/apoffsound2", 0);
				}
				if (getprop("/it-autoflight/output/ap-warning") != 0) {
					setprop("/it-autoflight/output/ap-warning", 0);
					ecam.lights[0].setValue(0);
				}
			}
		}
	},
	ATDisc: func() {
		# physical button sound - so put it outside here as you get a sound even if it doesn't work!
		setprop("/sim/sounde/apdiscbtn", 1);
		settimer(func {
			setprop("/sim/sounde/apdiscbtn", 0);
		}, 0.5);
		
		if (me.FCUworking) {
			if (athr.getBoolValue()) {
				athrOff("soft");
				ecam.lights[1].setValue(1);
			} else {
				if (getprop("/it-autoflight/output/athr-warning") == 1) {
					setprop("/it-autoflight/output/athr-warning", 0);
					ecam.lights[1].setValue(0);
				}
			}
		}
	},
	IASMach: func() {
		if (me.FCUworking) {
			if (ktsMach.getBoolValue()) {
				ktsMach.setBoolValue(0);
			} else {
				ktsMach.setBoolValue(1);
			}
		}
	},
	SPDPush: func() {
		if (me.FCUworking) {
			if (fmgc.FMGCInternal.crzSet and fmgc.FMGCInternal.costIndexSet) {
				spdManaged.setBoolValue(1);
				fmgc.ManagedSPD.start();
			}
		}
	},
	SPDPull: func() {
		if (me.FCUworking) {
			spdManaged.setBoolValue(0);
			fmgc.ManagedSPD.stop();
			var ias = iasNow.getValue();
			var mach = machNow.getValue();
			if (!ktsMach.getBoolValue()) {
				if (ias >= 100 and ias <= 350) {
					iasSet.setValue(math.round(ias));
				} else if (ias < 100) {
					iasSet.setValue(100);
				} else if (ias > 350) {
					iasSet.setValue(350);
				}
			} else if (ktsMach.getBoolValue()) {
				if (mach >= 0.50 and mach <= 0.82) {
					machSet.setValue(math.round(mach, 0.001));
				} else if (mach < 0.50) {
					machSet.setValue(0.50);
				} else if (mach > 0.82) {
					machSet.setValue(0.82);
				}
			}
		}
	},
	SPDAdjust: func(d) {
		if (me.FCUworking) {
			if (!spdManaged.getBoolValue()) {
				if (ktsMach.getBoolValue()) {
					var machTemp = machSet.getValue();
					if (d == 1) {
						machTemp = math.round(machTemp + 0.001, 0.001); # Kill floating point error
					} else if (d == -1) {
						machTemp = math.round(machTemp - 0.001, 0.001); # Kill floating point error
					} else if (d == 10) {
						machTemp = math.round(machTemp + 0.01, 0.01); # Kill floating point error
					} else if (d == -10) {
						machTemp = math.round(machTemp - 0.01, 0.01); # Kill floating point error
					}
					if (machTemp < 0.50) {
						machSet.setValue(0.50);
					} else if (machTemp > 0.82) {
						machSet.setValue(0.82);
					} else {
						machSet.setValue(machTemp);
					}
				} else {
					var iasTemp = iasSet.getValue();
					if (d == 1) {
						iasTemp = iasTemp + 1;
					} else if (d == -1) {
						iasTemp = iasTemp - 1;
					} else if (d == 10) {
						iasTemp = iasTemp + 10;
					} else if (d == -10) {
						iasTemp = iasTemp - 10;
					}
					if (iasTemp < 100) {
						iasSet.setValue(100);
					} else if (iasTemp > 350) {
						iasSet.setValue(350);
					} else {
						iasSet.setValue(iasTemp);
					}
				}
			}
		}
	},
	HDGPush: func() {
		if (me.FCUworking) {
			if (fd1.getBoolValue() or fd2.getBoolValue() or ap1.getBoolValue() or ap2.getBoolValue()) {
				latModeInput.setValue(1);
			}
		}
	},
	HDGPull: func() {
		if (me.FCUworking) {
			if (fd1.getBoolValue() or fd2.getBoolValue() or ap1.getBoolValue() or ap2.getBoolValue()) {
				if (latMode.getValue() == 0 or !showHDG.getBoolValue()) {
					latModeInput.setValue(3);
				} else {
					latModeInput.setValue(0);
				}
			}
		}
	},
	HDGAdjust: func(d) {
		if (me.FCUworking) {
			if (latMode.getValue() != 0) {
				hdgInput();
			}
			if (showHDG.getBoolValue()) {
				var hdgTemp = hdgSet.getValue();
				if (d == 1) {
					hdgTemp = hdgTemp + 1;
				} else if (d == -1) {
					hdgTemp = hdgTemp - 1;
				} else if (d == 10) {
					hdgTemp = hdgTemp + 10;
				} else if (d == -10) {
					hdgTemp = hdgTemp - 10;
				}
				if (hdgTemp < 0.5) {
					hdgSet.setValue(hdgTemp + 360);
				} else if (hdgTemp >= 360.5) {
					hdgSet.setValue(hdgTemp - 360);
				} else {
					hdgSet.setValue(hdgTemp);
				}
			}
		}
	},
	LOCButton: func() {
		if (me.FCUworking) {
			var vertTemp = vertMode.getValue();
			if ((locArm.getBoolValue() or latMode.getValue() == 2) and !apprArm.getBoolValue() and vertTemp != 2 and vertTemp != 6) {
				if (latMode.getValue() == 2) {
					latModeInput.setValue(0);
				} else {
					fmgc.ITAF.disarmLOC();
				}
				if (vertTemp == 2 or vertTemp == 6) {
					me.VSPull();
				} else {
					fmgc.ITAF.disarmGS();
				}
			} else {
				if (pts.Position.gearAglFt.getValue() >= 400 and vertTemp != 7) {
					latModeInput.setValue(2);
					if (vertTemp == 2 or vertTemp == 6) {
						me.VSPull();
					} else {
						fmgc.ITAF.disarmGS();
					}
				}
			}
		}
	},
	TRKFPA: func() {
		if (me.FCUworking) {
			fmgc.ITAF.toggleTrkFpa();
		}
	},
	ALTPush: func() {
		if (me.FCUworking) {
			# setprop("/it-autoflight/input/vert", 8); # He don't work yet m8
		}
	},
	ALTPull: func() {
		if (me.FCUworking) {
			vertModeInput.setValue(4);
		}
	},
	ALTAdjust: func(d) {
		if (me.FCUworking) {
			var altTemp = altSet.getValue();
			if (d == 1) {
				if (altSetMode.getBoolValue()) {
					altTemp = altTemp + 1000;
				} else {
					altTemp = altTemp + 100;
				}
			} else if (d == -1) {
				if (altSetMode.getBoolValue()) {
					altTemp = altTemp - 1000;
				} else {
					altTemp = altTemp - 100;
				}
			} else if (d == 2) {
				altTemp = altTemp + 100;
			} else if (d == -2) {
				altTemp = altTemp - 100;
			} else if (d == 10) {
				altTemp = altTemp + 1000;
			} else if (d == -10) {
				altTemp = altTemp - 1000;
			}
			if (altTemp < 100) {
				altSet.setValue(100);
			} else if (altTemp > 49000) {
				altSet.setValue(49000);
			} else {
				altSet.setValue(altTemp);
			}
		}
	},
	VSPush: func() {
		if (me.FCUworking) {
			if (trkFpaSW.getBoolValue()) {
				vertModeInput.setValue(5);
				fpaModeInput.setValue(0);
			} else {
				vertModeInput.setValue(1);
				vsModeInput.setValue(0);
			}
		}
	},
	VSPull: func() {
		if (me.FCUworking) {
			if (trkFpaSW.getBoolValue()) {
				vertModeInput.setValue(5);
			} else {
				vertModeInput.setValue(1);
			}
		}
	},
	VSAdjust: func(d) {
		if (me.FCUworking) {
			if (vertMode.getValue() == 1) {
				var vsTemp = vsSet.getValue();
				if (d == 1) {
					vsTemp = vsTemp + 100;
				} else if (d == -1) {
					vsTemp = vsTemp - 100;
				} else if (d == 10) {
					vsTemp = vsTemp + 1000;
				} else if (d == -10) {
					vsTemp = vsTemp - 1000;
				}
				if (vsTemp < -6000) {
					vsSet.setValue(-6000);
				} else if (vsTemp > 6000) {
					vsSet.setValue(6000);
				} else {
					vsSet.setValue(vsTemp);
				}
			} else if (vertMode.getValue() == 5) {
				var fpaTemp = fpaSet.getValue();
				if (d == 1) {
					fpaTemp = math.round(fpaTemp + 0.1, 0.1);
				} else if (d == -1) {
					fpaTemp = math.round(fpaTemp - 0.1, 0.1);
				} else if (d == 10) {
					fpaTemp = fpaTemp + 1;
				} else if (d == -10) {
					fpaTemp = fpaTemp - 1;
				}
				if (fpaTemp < -9.9) {
					fpaSet.setValue(-9.9);
				} else if (fpaTemp > 9.9) {
					fpaSet.setValue(9.9);
				} else {
					fpaSet.setValue(fpaTemp);
				}
			}
			if ((vertMode.getValue() != 1 and !trkFpaSW.getBoolValue()) or (vertMode.getValue() != 5 and trkFpaSW.getBoolValue())) {
				me.VSPull();
			}
		}
	},
	APPRButton: func() {
		if (me.FCUworking) {
			var vertTemp = vertMode.getValue();
			if ((locArm.getBoolValue() or latMode.getValue() == 2) and (apprArm.getBoolValue() or vertTemp == 2 or vertTemp == 6)) {
				if (latMode.getValue() == 2) {
					latModeInput.setValue(0);
				} else {
					fmgc.ITAF.disarmLOC();
				}
				if (vertTemp == 2 or vertTemp == 6) {
					me.VSPull();
				} else {
					fmgc.ITAF.disarmGS();
				}
			} else {
				if (pts.Position.gearAglFt.getValue() >= 400 and vertTemp != 7) {
					vertModeInput.setValue(2);
				}
			}
		}
	},
};

# Master / slave principle of operation depending on the autopilot / flight director engagement
var updateActiveFMGC = func {
	if (ap1.getBoolValue()) {
		FCUController.activeFMGC.setValue(1);
	} elsif (ap2.getBoolValue()) {
		FCUController.activeFMGC.setValue(2);
	} elsif (fd1.getBoolValue()) {
		FCUController.activeFMGC.setValue(1);
	} elsif (fd2.getBoolValue()) {
		FCUController.activeFMGC.setValue(2);
	} else {
		FCUController.activeFMGC.setValue(1);
	}
}

# Autopilot Disconnection
var apOff = func(type, side) {
	if ((ap1Input.getValue() and (side == 1 or side == 0)) or (ap2Input.getValue() and (side == 2 or side == 0))) {
		ecam.doApWarn(type);
	}
	
	if (side == 0) {
		ap1Input.setValue(0);
		ap2Input.setValue(0);
	} elsif (side == 1) {
		ap1Input.setValue(0);
	} elsif (side == 2) {
		ap2Input.setValue(0);
	}
}

# Autothrust Disconnection
var athrOff = func(type) {
	if (athrInput.getValue() == 1) {
		if (type == "hard") {
			fadec.lockThr();
		}
		athrInput.setValue(0);
		ecam.doAthrWarn(type);
	}
}

# If the heading knob is turned while in nav mode, it will display heading for a period of time
var hdgInput = func {
	if (latMode.getValue() != 0) {
		showHDG.setBoolValue(1);
		var hdgnow = fmgc.Input.hdg.getValue();
		fmgc.Custom.hdgTime.setValue(pts.Sim.Time.elapsedSec.getValue());
	}
}
