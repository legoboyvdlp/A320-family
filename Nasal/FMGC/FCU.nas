# A3XX FCU
# Copyright (c) 2020 Josh Davidson (Octal450), Jonathan Redpath (legoboyvdlp)

# Nodes
var altSetMode = props.globals.getNode("/it-autoflight/config/altitude-dial-mode", 1);
var apOffSound = [props.globals.getNode("/it-autoflight/sound/apoffsound"),props.globals.getNode("/it-autoflight/sound/apoffsound2")];
var apWarningNode = props.globals.getNode("/it-autoflight/output/ap-warning");
var athrWarningNode = props.globals.getNode("/it-autoflight/output/athr-warning");
var apDiscBtn = props.globals.getNode("/sim/sounde/apdiscbtn");
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
	loop: func(notification) {
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
			update_item.update(notification);
		}
	},
	update_items: [
		props.UpdateManager.FromPropertyHashList(["/it-autoflight/output/fd1","/it-autoflight/output/fd2", "/it-autoflight/output/ap1", "/it-autoflight/output/ap2"], nil, func(notification)
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
			if (!fmgc.Output.ap1.getBoolValue() and fbw.FBW.apOff == 0) {
				fmgc.Input.ap1.setValue(1);
				ecam.apWarnNode.setValue(0);
				pts.Controls.Flight.rudderTrim.setValue(0);
			} else {
				apOff("hard", 1);
			}
		}
	},
	AP2: func() {
		if (me.FCUworking) {
			if (!fmgc.Output.ap2.getBoolValue() and fbw.FBW.apOff == 0) {
				fmgc.Input.ap2.setValue(1);
				ecam.apWarnNode.setValue(0);
				pts.Controls.Flight.rudderTrim.setValue(0);
			} else {
				apOff("hard", 2);
			}
		}
	},
	ATHR: func() {
		if (me.FCUworking) {
			if (!fmgc.Output.athr.getBoolValue() and !pts.FMGC.CasCompare.casRejectAll.getBoolValue() and fbw.FBW.apOff == 0) {
				fmgc.Input.athr.setValue(1);
			} else {
				athrOff("hard");
			}
		}
	},
	FD1: func() {
		if (me.FCUworking) {
			if (!fmgc.Output.fd1.getBoolValue()) {
				fmgc.Input.fd1.setValue(1);
			} else {
				fmgc.Input.fd1.setValue(0);
			}
		}
	},
	FD2: func() {
		if (me.FCUworking) {
			if (!fmgc.Output.fd2.getBoolValue()) {
				fmgc.Input.fd2.setValue(1);
			} else {
				fmgc.Input.fd2.setValue(0);
			}
		}
	},
	APDisc: func() {
		# physical button sound - so put it outside here as you get a sound even if it doesn't work!
		apDiscBtn.setValue(1);
		settimer(func {
			apDiscBtn.setValue(0);
		}, 0.5);
		
		if (me.FCUworking) {
			if (fmgc.Output.ap1.getBoolValue() or fmgc.Output.ap2.getBoolValue()) {
				apOff("soft", 0);
			} else {
				if (apOffSound[0].getValue() or apOffSound[1].getValue()) {
					apOffSound[0].setValue(0);
					apOffSound[1].setValue(0);
				}
				if (apWarningNode.getValue() != 0) {
					apWarningNode.setValue(0);
					ecam.lights[0].setValue(0);
				}
			}
		}
	},
	ATDisc: func() {
		# physical button sound - so put it outside here as you get a sound even if it doesn't work!
		apDiscBtn.setValue(1);
		settimer(func {
			apDiscBtn.setValue(0);
		}, 0.5);
		
		if (me.FCUworking) {
			if (fmgc.Output.athr.getBoolValue()) {
				athrOff("soft");
				ecam.lights[1].setValue(1);
			} else {
				if (athrWarningNode.getValue() == 1) {
					athrWarningNode.setValue(0);
					ecam.lights[1].setValue(0);
				}
			}
		}
	},
	IASMach: func() {
		if (me.FCUworking) {
			if (fmgc.Input.ktsMach.getBoolValue()) {
				fmgc.Input.ktsMach.setBoolValue(0);
			} else {
				fmgc.Input.ktsMach.setBoolValue(1);
			}
		}
	},
	SPDPush: func() {
		if (me.FCUworking) {
			if (fmgc.FMGCInternal.crzSet and fmgc.FMGCInternal.costIndexSet) {
				fmgc.Custom.Input.spdManaged.setBoolValue(1);
				fmgc.ManagedSPD.start();
			}
		}
	},
	ias: nil,
	mach: nil,
	SPDPull: func() {
		if (me.FCUworking) {
			fmgc.Custom.Input.spdManaged.setBoolValue(0);
			fmgc.ManagedSPD.stop();
			me.ias = fmgc.Velocities.indicatedAirspeedKt.getValue();
			me.mach = fmgc.Velocities.indicatedMach.getValue();
			if (!fmgc.Input.ktsMach.getBoolValue()) {
				if (me.ias >= 100 and me.ias <= 399) {
					fmgc.Input.kts.setValue(math.round(me.ias));
				} else if (me.ias < 100) {
					fmgc.Input.kts.setValue(100);
				} else if (me.ias > 399) {
					fmgc.Input.kts.setValue(399);
				}
			} else if (fmgc.Input.ktsMach.getBoolValue()) {
				if (me.mach >= 0.10 and me.mach <= 0.99) {
					fmgc.Input.mach.setValue(math.round(me.mach, 0.001));
				} else if (me.mach < 0.10) {
					fmgc.Input.mach.setValue(0.10);
				} else if (me.mach > 0.99) {
					fmgc.Input.mach.setValue(0.99);
				}
			}
		}
	},
	machTemp: nil,
	iasTemp: nil,
	SPDAdjust: func(d) {
		if (me.FCUworking) {
			if (!fmgc.Custom.Input.spdManaged.getBoolValue()) {
				if (fmgc.Input.ktsMach.getBoolValue()) {
					me.machTemp = fmgc.Input.mach.getValue();
					if (d == 1) {
						me.machTemp = math.round(me.machTemp + 0.001, 0.001); # Kill floating point error
					} else if (d == -1) {
						me.machTemp = math.round(me.machTemp - 0.001, 0.001); # Kill floating point error
					} else if (d == 10) {
						me.machTemp = math.round(me.machTemp + 0.01, 0.01); # Kill floating point error
					} else if (d == -10) {
						me.machTemp = math.round(me.machTemp - 0.01, 0.01); # Kill floating point error
					}
					if (me.machTemp < 0.10) {
						fmgc.Input.mach.setValue(0.10);
					} else if (me.machTemp > 0.99) {
						fmgc.Input.mach.setValue(0.99);
					} else {
						fmgc.Input.mach.setValue(me.machTemp);
					}
				} else {
					me.iasTemp = fmgc.Input.kts.getValue();
					if (d == 1) {
						me.iasTemp = me.iasTemp + 1;
					} else if (d == -1) {
						me.iasTemp = me.iasTemp - 1;
					} else if (d == 10) {
						me.iasTemp = me.iasTemp + 10;
					} else if (d == -10) {
						me.iasTemp = me.iasTemp - 10;
					}
					if (me.iasTemp < 100) {
						fmgc.Input.kts.setValue(100);
					} else if (me.iasTemp > 399) {
						fmgc.Input.kts.setValue(399);
					} else {
						fmgc.Input.kts.setValue(me.iasTemp);
					}
				}
			}
		}
	},
	HDGPush: func() {
		if (me.FCUworking) {
			if (fmgc.Output.fd1.getBoolValue() or fmgc.Output.fd2.getBoolValue() or fmgc.Output.ap1.getBoolValue() or fmgc.Output.ap2.getBoolValue()) {
				fmgc.Input.lat.setValue(1);
			}
		}
	},
	HDGPull: func() {
		if (me.FCUworking) {
			if (fmgc.Output.fd1.getBoolValue() or fmgc.Output.fd2.getBoolValue() or fmgc.Output.ap1.getBoolValue() or fmgc.Output.ap2.getBoolValue()) {
				if (fmgc.Output.lat.getValue() == 0 or !fmgc.Custom.showHdg.getBoolValue()) {
					fmgc.Input.lat.setValue(3);
				} else {
					fmgc.Input.lat.setValue(0);
				}
			}
		}
	},
	hdgTemp: nil,
	HDGAdjust: func(d) {
		if (me.FCUworking) {
			if (fmgc.Output.lat.getValue() != 0) {
				hdgInput();
			}
			if (fmgc.Custom.showHdg.getBoolValue()) {
				me.hdgTemp = fmgc.Input.hdg.getValue();
				if (d == 1) {
					me.hdgTemp = me.hdgTemp + 1;
				} else if (d == -1) {
					me.hdgTemp = me.hdgTemp - 1;
				} else if (d == 10) {
					me.hdgTemp = me.hdgTemp + 10;
				} else if (d == -10) {
					me.hdgTemp = me.hdgTemp - 10;
				}
				if (me.hdgTemp < 0.5) {
					fmgc.Input.hdg.setValue(me.hdgTemp + 360);
				} else if (me.hdgTemp >= 360.5) {
					fmgc.Input.hdg.setValue(me.hdgTemp - 360);
				} else {
					fmgc.Input.hdg.setValue(me.hdgTemp);
				}
			}
		}
	},
	vertTemp: nil,
	LOCButton: func() {
		if (me.FCUworking) {
			me.vertTemp = fmgc.Output.vert.getValue();
			if ((fmgc.Output.locArm.getBoolValue() or fmgc.Output.lat.getValue() == 2) and !fmgc.Output.apprArm.getBoolValue() and me.vertTemp != 2 and me.vertTemp != 6) {
				if (fmgc.Output.lat.getValue() == 2) {
					fmgc.Input.lat.setValue(0);
				} else {
					fmgc.ITAF.disarmLOC();
				}
				if (me.vertTemp == 2 or me.vertTemp == 6) {
					me.VSPull();
				} else {
					fmgc.ITAF.disarmGS();
				}
			} else {
				if (pts.Position.gearAglFt.getValue() >= 400 and me.vertTemp != 7) {
					fmgc.Input.lat.setValue(2);
					if (me.vertTemp == 2 or me.vertTemp == 6) {
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
			fmgc.Input.vert.setValue(4);
		}
	},
	altTemp: nil,
	ALTAdjust: func(d) {
		if (me.FCUworking) {
			me.altTemp = fmgc.Input.alt.getValue();
			if (d == 1) {
				if (altSetMode.getBoolValue()) {
					me.altTemp = me.altTemp + 1000;
				} else {
					me.altTemp = me.altTemp + 100;
				}
			} else if (d == -1) {
				if (altSetMode.getBoolValue()) {
					me.altTemp = me.altTemp - 1000;
				} else {
					me.altTemp = me.altTemp - 100;
				}
			} else if (d == 2) {
				me.altTemp = me.altTemp + 100;
			} else if (d == -2) {
				me.altTemp = me.altTemp - 100;
			} else if (d == 10) {
				me.altTemp = me.altTemp + 1000;
			} else if (d == -10) {
				me.altTemp = me.altTemp - 1000;
			}
			if (me.altTemp < 100) {
				fmgc.Input.alt.setValue(100);
			} else if (me.altTemp > 49000) {
				fmgc.Input.alt.setValue(49000);
			} else {
				fmgc.Input.alt.setValue(me.altTemp);
			}
		}
	},
	VSPush: func() {
		if (me.FCUworking) {
			if (fmgc.Custom.trkFpa.getBoolValue()) {
				fmgc.Input.vert.setValue(5);
				fmgc.Input.fpa.setValue(0);
			} else {
				fmgc.Input.vert.setValue(1);
				fmgc.Input.vs.setValue(0);
				fmgc.Custom.Output.vsFCU.setValue(left(sprintf("%+05.0f",0),3));
			}
		}
	},
	VSPull: func() {
		if (me.FCUworking) {
			if (fmgc.Custom.trkFpa.getBoolValue()) {
				fmgc.Input.vert.setValue(5);
			} else {
				fmgc.Input.vert.setValue(1);
			}
		}
	},
	vsTemp: nil,
	fpaTemp: nil,
	VSAdjust: func(d) {
		if (me.FCUworking) {
			if (fmgc.Output.vert.getValue() == 1) {
				me.vsTemp = fmgc.Input.vs.getValue();
				if (d == 1) {
					me.vsTemp = me.vsTemp + 100;
				} else if (d == -1) {
					me.vsTemp = me.vsTemp - 100;
				} else if (d == 10) {
					me.vsTemp = me.vsTemp + 1000;
				} else if (d == -10) {
					me.vsTemp = me.vsTemp - 1000;
				}
				if (me.vsTemp < -6000) {
					fmgc.Input.vs.setValue(-6000);
				} else if (me.vsTemp > 6000) {
					fmgc.Input.vs.setValue(6000);
				} else {
					fmgc.Input.vs.setValue(me.vsTemp);
				}
				fmgc.Custom.Output.vsFCU.setValue(left(sprintf("%+05.0f",fmgc.Input.vs.getValue()),3));
			} else if (fmgc.Output.vert.getValue() == 5) {
				me.fpaTemp = fmgc.Input.fpa.getValue();
				if (d == 1) {
					me.fpaTemp = math.round(me.fpaTemp + 0.1, 0.1);
				} else if (d == -1) {
					me.fpaTemp = math.round(me.fpaTemp - 0.1, 0.1);
				} else if (d == 10) {
					me.fpaTemp = me.fpaTemp + 1;
				} else if (d == -10) {
					me.fpaTemp = me.fpaTemp - 1;
				}
				if (me.fpaTemp < -9.9) {
					fmgc.Input.fpa.setValue(-9.9);
				} else if (me.fpaTemp > 9.9) {
					fmgc.Input.fpa.setValue(9.9);
				} else {
					fmgc.Input.fpa.setValue(me.fpaTemp);
				}
			}
			if ((fmgc.Output.vert.getValue() != 1 and !fmgc.Custom.trkFpa.getBoolValue()) or (fmgc.Output.vert.getValue() != 5 and fmgc.Custom.trkFpa.getBoolValue())) {
				me.VSPull();
			}
		}
	},
	APPRButton: func() {
		if (me.FCUworking) {
			me.vertTemp = fmgc.Output.vert.getValue();
			if ((fmgc.Output.locArm.getBoolValue() or fmgc.Output.lat.getValue() == 2) and (fmgc.Output.apprArm.getBoolValue() or me.vertTemp == 2 or me.vertTemp == 6)) {
				if (fmgc.Output.lat.getValue() == 2) {
					fmgc.Input.lat.setValue(0);
				} else {
					fmgc.ITAF.disarmLOC();
				}
				if (me.vertTemp == 2 or me.vertTemp == 6) {
					me.VSPull();
				} else {
					fmgc.ITAF.disarmGS();
				}
			} else {
				if (pts.Position.gearAglFt.getValue() >= 400 and me.vertTemp != 7) {
					fmgc.Input.vert.setValue(2);
				}
			}
		}
	},
};

# Master / slave principle of operation depending on the autopilot / flight director engagement
var updateActiveFMGC = func {
	if (fmgc.Output.ap1.getBoolValue()) {
		FCUController.activeFMGC.setValue(1);
	} elsif (fmgc.Output.ap2.getBoolValue()) {
		FCUController.activeFMGC.setValue(2);
	} elsif (fmgc.Output.fd1.getBoolValue()) {
		FCUController.activeFMGC.setValue(1);
	} elsif (fmgc.Output.fd2.getBoolValue()) {
		FCUController.activeFMGC.setValue(2);
	} else {
		FCUController.activeFMGC.setValue(1);
	}
}

# Autopilot Disconnection
var apOff = func(type, side) {
	if ((fmgc.Input.ap1.getValue() and (side == 1 or side == 0)) or (fmgc.Input.ap2.getValue() and (side == 2 or side == 0))) {
		ecam.doApWarn(type);
	}
	
	if (side == 0) {
		fmgc.Input.ap1.setValue(0);
		fmgc.Input.ap2.setValue(0);
	} elsif (side == 1) {
		fmgc.Input.ap1.setValue(0);
	} elsif (side == 2) {
		fmgc.Input.ap2.setValue(0);
	}
}

# Autothrust Disconnection
var athrOff = func(type) {
	if (fmgc.Input.athr.getValue() == 1) {
		if (type == "hard") {
			fadec.lockThr();
		}
		fmgc.Input.athr.setValue(0);
		ecam.doAthrWarn(type);
	}
}

# If the heading knob is turned while in nav mode, it will display heading for a period of time
var hdgInput = func {
	if (fmgc.Output.lat.getValue() != 0) {
		fmgc.Custom.showHdg.setBoolValue(1);
		fmgc.Custom.hdgTime.setValue(pts.Sim.Time.elapsedSec.getValue());
	}
}
