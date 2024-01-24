# A3XX FCU
# Copyright (c) 2023 Josh Davidson (Octal450), Jonathan Redpath (legoboyvdlp)

# Nodes
var altSetMode = props.globals.getNode("/it-autoflight/config/altitude-dial-mode", 1);
var apOffSound = [props.globals.getNode("/it-autoflight/sound/apoffsound"),props.globals.getNode("/it-autoflight/sound/apoffsound2")];
var apWarningNode = props.globals.getNode("/it-autoflight/output/ap-warning");
var athrWarningNode = props.globals.getNode("/it-autoflight/output/athr-warning");
var apDiscBtn = props.globals.getNode("/sim/sound/apdiscbtn");
var FCUworkingNode = props.globals.initNode("/FMGC/FCU-working", 0, "BOOL");
var input = { 
   kts: props.globals.initNode("/fcu/input/kts", 100, "INT"),
   mach: props.globals.initNode("/fcu/input/mach", 0.01, "DOUBLE"),
   spdPreselect: props.globals.initNode("/fcu/input/spd-preselect", 0, "BOOL"),
};
var fcuCh1valid = props.globals.initNode("/fcu/fcu-ch1-valid", 0, "BOOL");
var fcuCh2valid = props.globals.initNode("/fcu/fcu-ch2-valid", 0, "BOOL");
var SidestickPriorityPressedLast = 0;
var priorityTimer = 0;
var spdPreselectTime = 5; # Preselected Speed stays for 15 secs

var FCU = {
	elecSupply: "",
	failed: 0,
	condition: 100,
	new: func(elecNode) {
        var f = { parents:[FCU] };
		f.elecSupply = elecNode;
        return f;
    },
	elec: nil,
	powerOffTime: -99,
	loop: func(notification) {
		me.elec = me.elecSupply.getValue();
		if (me.elec < 25) {
			if (me.powerOffTime == -99) {
				me.powerOffTime = notification.elapsedTime;
			}
		} else {
			me.powerOffTime = -99;
		}
		me.failed = ((notification.elapsedTime > (me.powerOffTime + 0.25) and me.elec < 25) or me.condition == 0) ? 1 : 0;
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
   kts: props.globals.initNode("/fcu/input/kts", 100, "INT"),
   mach: props.globals.initNode("/fcu/input/mach", 0.01, "DOUBLE"),
   # FCU Speed Modes are 0: undefined 1: selected 2: managed
   spdPreselect: props.globals.initNode("/fcu/input/spd-preselect", 0, "BOOL"),
   spdWindowOpen: props.globals.initNode("/fcu/output/spd-window-open", 1, "BOOL"),
   spdWindowDot: props.globals.initNode("/fcu/output/spd-window-dot", 0, "BOOL"),
	_init: 0,
	init: func() {
		me.FCU1 = FCU.new(systems.ELEC.Bus.dcEss);
		me.FCU2 = FCU.new(systems.ELEC.Bus.dc2);
		me._init = 1;
	},
	loop: func(notification) {
		if (me._init == 0) { return; }
		
		# Update FCU Power
		me.FCU1.loop(notification);
		me.FCU2.loop(notification);
		
      # set validity for every FCU channel for faults
		if (me.FCU1.failed) {
         fcuCh1valid.setBoolValue(nil);
      } else {
         fcuCh1valid.setBoolValue(1);
      }
		if (me.FCU2.failed) {
         fcuCh2valid.setBoolValue(nil);
      } else {
         fcuCh2valid.setBoolValue(1);
      }

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
	resetFailures: func() {
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
	APDisc: func(side = 0, press = 0) {
		# side: 0 = none, 1 = capt, 2 = fo
		# physical button sound - so put it outside here as you get a sound even if it doesn't work!
		apDiscBtn.setValue(1);
		settimer(func {
			apDiscBtn.setValue(0);
		}, 0.5);
		
		if (me.FCUworking) {
			if (fmgc.Output.ap1.getBoolValue() or fmgc.Output.ap2.getBoolValue()) {
				apOff("soft", 0);
			} else if (apOffSound[0].getValue() or apOffSound[1].getValue() or apWarningNode.getValue() != 0) {
				if (press == 1) {
					if (apOffSound[0].getValue() or apOffSound[1].getValue()) {
						apOffSound[0].setValue(0);
						apOffSound[1].setValue(0);
					}
					if (apWarningNode.getValue() != 0) {
						apWarningNode.setValue(0);
						ecam.lights[0].setValue(0);
					}
				}
			} else if (side != 0) {
				if (press == 1) {
					setprop("/fdm/jsbsim/fbw/sidestick/active[" ~ (2 - side) ~ "]", 0);
					setprop("/fdm/jsbsim/fbw/sidestick/active[" ~ (side - 1) ~ "]", 1);
					SidestickPriorityPressedLast = side;
					if (side == 1) {
						setprop("/sim/sound/priority-left", 1);
						settimer(func {
							setprop("/sim/sound/priority-left", 0);
						}, 1.5);
					} else {
						setprop("/sim/sound/priority-right", 1);
						settimer(func {
							setprop("/sim/sound/priority-right", 0);
						}, 1.5);
					}
					priorityTimer = pts.Sim.Time.elapsedSec.getValue();
				} else {
					# Only release, if this side has pressed the button last
					# to avoide the first pressed side getting activated again
					# when released.
					if (SidestickPriorityPressedLast == side and priorityTimer + 40 >= pts.Sim.Time.elapsedSec.getValue()) {
						setprop("/fdm/jsbsim/fbw/sidestick/active[0]", 1);
						setprop("/fdm/jsbsim/fbw/sidestick/active[1]", 1);
					}
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
			fmgc.ManagedSPD.start();
		}
	},
	ias: 0,
	mach: 0,
	SPDPull: func() {
		if (me.FCUworking and fmgc.FMGCNodes.selSpdEnable.getBoolValue()) {
         if (fmgc.Custom.Input.spdManaged.getBoolValue()) {
            fmgc.ManagedSPD.stop();
            fmgc.FMGCNodes.mngSpdActive.setBoolValue(nil);
            fmgc.Custom.Input.spdManaged.setBoolValue(nil);
            if (input.spdPreselect.getBoolValue()){
               input.spdPreselect.setBoolValue(nil);
               spdSelectTimer.stop();
               if (fmgc.Input.ktsMach.getBoolValue()){
                  fmgc.Input.mach.setValue(fcu.input.mach.getValue());
               } else {
                  fmgc.Input.kts.setValue(fcu.input.kts.getValue());
               }
            } else {
               if (fmgc.Input.ktsMach.getBoolValue()){
			         me.mach = math.clamp(math.round(fmgc.Velocities.indicatedMach.getValue(), 0.01), 0.01, 0.99);
                  fmgc.Input.mach.setValue(me.mach);
                  fcu.input.mach.setValue(me.mach);
               } else {
			         me.ias = math.clamp(math.round(fmgc.Velocities.indicatedAirspeedKt.getValue()), 100, 399);
                  fmgc.Input.kts.setValue(me.ias);
                  fcu.input.kts.setValue(me.ias);
               }
            }
         } else {
            if (fmgc.Input.ktsMach.getBoolValue()){
               me.mach = fcu.input.mach.getValue();
            } else {
               me.ias = fcu.input.kts.getValue();
            }
         }

         # a selected speed must be available. SPD window can be opened
         me.spdWindowOpen.setBoolValue(1);

         fmgc.ManagedSPD.stop();
		}
	},
	machTemp: nil,
	iasTemp: nil,
	SPDAdjust: func(d) {
		if (me.FCUworking) {
         # window can be opened. it will close if preselect
         # timer is over
         me.spdWindowOpen.setBoolValue(1);

         if (fmgc.Input.ktsMach.getBoolValue()) {
            if (fmgc.Custom.Input.spdManaged.getBoolValue()) {
               # get actual managed speed
               # get from fmgc when window opens
               # get from window if window already open
               if(!input.spdPreselect.getBoolValue()) {
                  # speed preselection on FCU as speed is managed
                  input.spdPreselect.setBoolValue(1);
                  me.machTemp = math.clamp(math.round(fmgc.Velocities.indicatedMach.getValue(), 0.01), 0.01, 0.99);
               } else {
                  me.machTemp = fcu.input.mach.getValue();
               }
               me.spdWindowOpen.setBoolValue(1);

               # timer is started by rotating speed selection knob
               # and reset by rotating again
               if (!spdSelectTimer.isRunning){
                  spdSelectTimer.start();
               } else {
                  spdSelectTimer.restart(spdPreselectTime);
               }

               if (d == 1) {
                  me.machTemp = math.round(me.machTemp + 0.001, 0.001); # Kill floating point error
               } else if (d == -1) {
                  me.machTemp = math.round(me.machTemp - 0.001, 0.001); # Kill floating point error
               } else if (d == 10) {
                  me.machTemp = math.round(me.machTemp + 0.01, 0.01); # Kill floating point error
               } else if (d == -10) {
                  me.machTemp = math.round(me.machTemp - 0.01, 0.01); # Kill floating point error
               }
               fcu.input.mach.setValue(math.clamp(me.machTemp, 0.10, 0.99));

            } else {
               # get actual selected speed
               # speed is directly controlled if it is not managed
					me.machTemp = fcu.input.mach.getValue();

               if (d == 1) {
                  me.machTemp = math.round(me.machTemp + 0.001, 0.001); # Kill floating point error
               } else if (d == -1) {
                  me.machTemp = math.round(me.machTemp - 0.001, 0.001); # Kill floating point error
               } else if (d == 10) {
                  me.machTemp = math.round(me.machTemp + 0.01, 0.01); # Kill floating point error
               } else if (d == -10) {
                  me.machTemp = math.round(me.machTemp - 0.01, 0.01); # Kill floating point error
               }
               fmgc.Input.mach.setValue(math.clamp(me.machTemp, 0.10, 0.99));
               fcu.input.mach.setValue(math.clamp(me.machTemp, 0.10, 0.99));
            }
         } else {
            if (fmgc.Custom.Input.spdManaged.getBoolValue()) {
               # get actual managed speed
               # get from fmgc when window opens
               # get from window if window already open
               if(!input.spdPreselect.getBoolValue()) {
                  # speed preselection on FCU as speed is managed
                  input.spdPreselect.setBoolValue(1);
                  me.iasTemp = math.clamp(math.round(fmgc.Velocities.indicatedAirspeedKt.getValue()), 100, 399);
               } else {
                  me.iasTemp = fcu.input.kts.getValue();
               }
               me.spdWindowOpen.setBoolValue(1);

               # timer is started by rotating speed selection knob
               # and reset by rotating again
               if (!spdSelectTimer.isRunning){
               spdSelectTimer.start();
               } else {
               spdSelectTimer.restart(spdPreselectTime);
               }

               if (d == 1) {
                  me.iasTemp = me.iasTemp + 1;
               } else if (d == -1) {
                  me.iasTemp = me.iasTemp - 1;
               } else if (d == 10) {
                  me.iasTemp = me.iasTemp + 10;
               } else if (d == -10) {
                  me.iasTemp = me.iasTemp - 10;
               }
               fcu.input.kts.setValue(math.clamp(me.iasTemp, 100, 399));
            } else {
               # get actual selected speed
               # speed is directly controlled if it is not managed
					me.iasTemp = fcu.input.kts.getValue();

					if (d == 1) {
						me.iasTemp = me.iasTemp + 1;
					} else if (d == -1) {
						me.iasTemp = me.iasTemp - 1;
					} else if (d == 10) {
						me.iasTemp = me.iasTemp + 10;
					} else if (d == -10) {
						me.iasTemp = me.iasTemp - 10;
					}
               fmgc.Input.kts.setValue(math.clamp(me.iasTemp, 100, 399));
               fcu.input.kts.setValue(math.clamp(me.iasTemp, 100, 399));
				}
			}
		}
	},
	HDGPush: func() {
		if (me.FCUworking) {
			if (fmgc.Output.fd1.getBoolValue() or fmgc.Output.fd2.getBoolValue() or fmgc.Output.ap1.getBoolValue() or fmgc.Output.ap2.getBoolValue()) {
				var wp = fmgc.flightPlanController.flightplans[2].getWP(fmgc.flightPlanController.currentToWptIndex.getValue());
				if (wp != nil and wp.wp_type != "discontinuity" and wp.wp_type != "vectors") {
					fmgc.Input.lat.setValue(1);
				}
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
					fmgc.ITAF.disarmLoc();
				}
				if (me.vertTemp == 2 or me.vertTemp == 6) {
					me.VSPull();
				} else {
					fmgc.ITAF.disarmAppr();
				}
			} else {
				if (pts.Position.gearAglFt.getValue() >= 400 and me.vertTemp != 7) {
					fmgc.Input.lat.setValue(2);
					if (me.vertTemp == 2 or me.vertTemp == 6) {
						me.VSPull();
					} else {
						fmgc.ITAF.disarmAppr();
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
					me.altTemp = math.ceil((me.altTemp + 100)/1000) * 1000;
				} else {
					me.altTemp = me.altTemp + 100;
				}
			} else if (d == -1) {
				if (altSetMode.getBoolValue()) {
					me.altTemp = math.floor((me.altTemp - 100)/1000) * 1000;
				} else {
					me.altTemp = me.altTemp - 100;
				}
			} else if (d == 2) {
				me.altTemp = me.altTemp + 100;
			} else if (d == -2) {
				me.altTemp = me.altTemp - 100;
			} else if (d == 10) {
				me.altTemp = math.ceil((me.altTemp + 100)/1000) * 1000;
			} else if (d == -10) {
				me.altTemp = math.floor((me.altTemp - 100)/1000) * 1000;
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
					fmgc.ITAF.disarmLoc();
				}
				if (me.vertTemp == 2 or me.vertTemp == 6) {
					me.VSPull();
				} else {
					fmgc.ITAF.disarmAppr();
				}
			} else {
				if (pts.Position.gearAglFt.getValue() >= 400 and me.vertTemp != 7) {
					fmgc.Input.vert.setValue(2);
				}
			}
		}
	},
	MetricAlt: func() {
		if (me.FCUworking) {
			canvas_pfd.A320PFD1.MainScreen.showMetricAlt = !canvas_pfd.A320PFD1.MainScreen.showMetricAlt;
			canvas_pfd.A320PFD2.MainScreen.showMetricAlt = !canvas_pfd.A320PFD2.MainScreen.showMetricAlt;
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

    var radarft = (side == 2) ? getprop("/instrumentation/radar-altimeter[1]/radar-altitude-ft-corrected") : getprop("/instrumentation/radar-altimeter[0]/radar-altitude-ft-corrected");
	setprop("/instrumentation/pfd/logic/autoland/ap-disc-ft",radarft);
}

# Autothrust Disconnection
var athrOff = func(type) {
	if (fmgc.Input.athr.getValue() == 1 and !systems.FADEC.alphaFloor.getBoolValue()) {
		if (type == "hard") {
			systems.lockThr();
		}
		fmgc.Input.athr.setValue(0);
		ecam.doAthrWarn(type);
	}
}

# If the heading knob is turned while in nav mode, it will display heading for a period of time
var hdgInput = func {
	if (fmgc.Output.lat.getValue() != 0) {
		fmgc.Custom.showHdg.setBoolValue(1);
		fmgc.Custom.hdgTime = pts.Sim.Time.elapsedSec.getValue();
	}
}

# Selecting speed in managed goes into speed preselection
var spdSelectTimer =  maketimer(spdPreselectTime, func(){
      fcu.input.spdPreselect.setBoolValue(nil);
      fcu.FCUController.spdWindowOpen.setBoolValue(nil);
   });
spdSelectTimer.singleShot = 1; # timer will only be run once

