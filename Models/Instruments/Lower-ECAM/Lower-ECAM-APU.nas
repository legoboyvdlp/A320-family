# A3XX Lower ECAM Canvas
# Copyright (c) 2021 Josh Davidson (Octal450) and Jonathan Redpath

var apu_load = props.globals.initNode("/systems/electrical/extra/apu-load", 0, "DOUBLE");
var gen1_load = props.globals.initNode("/systems/electrical/extra/gen1-load", 0, "DOUBLE");
var gen2_load = props.globals.initNode("/systems/electrical/extra/gen2-load", 0, "DOUBLE");

var canvas_lowerECAMPageApu =
{
	new: func(svg,name) {
		var obj = {parents: [canvas_lowerECAMPageApu,canvas_lowerECAM_base] };
        obj.group = obj.canvas.createGroup();
		obj.name = name;
        
		canvas.parsesvg(obj.group, svg, {"font-mapper": obj.font_mapper} );
		
 		foreach(var key; obj.getKeys()) {
			obj[key] = obj.group.getElementById(key);
		};
		
		foreach(var key; obj.getKeysBottom()) {
			obj[key] = obj.group.getElementById(key);
		};
		
		obj.units = acconfig_weight_kgs.getValue();
		
		# init
		obj["APUGenOff"].hide();
		
		obj.update_items = [
			props.UpdateManager.FromHashValue("apuFlap",1, func(val) {
				if (val) {
					obj["APUFlapOpen"].show();
				} else {
					obj["APUFlapOpen"].hide();
				}
			}),
			props.UpdateManager.FromHashValue("apuNeedleRot",0.1, func(val) {
				obj["APUN-needle"].setRotation((val + 90) * D2R);
			}),
			props.UpdateManager.FromHashValue("apuEgtRot",0.1, func(val) {
				obj["APUEGT-needle"].setRotation((val + 90) * D2R);
			}),
			props.UpdateManager.FromHashValue("apuAvailable", nil, func(val) {
				if (val) {
					obj["APUAvail"].show();
				} else {
					obj["APUAvail"].hide();
				}
			}),
			props.UpdateManager.FromHashList(["apuRpm","apuEgt","apuMaster","apuGenPB"], nil, func(val) {
				if (val.apuRpm > 0.001) {
					obj["APUN"].setColor(0.0509,0.7529,0.2941);
					obj["APUN"].setText(sprintf("%s", math.round(val.apuRpm)));
					obj["APUN-needle"].show();
					obj["APUEGT"].setColor(0.0509,0.7529,0.2941);
					obj["APUEGT"].setText(sprintf("%s", math.round(val.apuEgt, 5)));
					obj["APUEGT-needle"].show();
				} else {
					obj["APUN"].setColor(0.7333,0.3803,0);
					obj["APUN"].setText(sprintf("%s", "XX"));
					obj["APUN-needle"].hide();
					obj["APUEGT"].setColor(0.7333,0.3803,0);
					obj["APUEGT"].setText(sprintf("%s", "XX"));
					obj["APUEGT-needle"].hide();
				}
				
				if (val.apuMaster or val.apuRpm >= 94.9) {
					obj["APUGenbox"].show();
					if (val.apuGenPB) {
						obj["APUGenOff"].hide();
						obj["APUGentext"].setColor(0.8078,0.8039,0.8078);
						obj["APUGenHz"].show();
						obj["APUGenVolt"].show();
						obj["APUGenLoad"].show();
						obj["text3724"].show();
						obj["text3728"].show();
						obj["text3732"].show();
					} else {
						obj["APUGenOff"].show();
						obj["APUGentext"].setColor(0.7333,0.3803,0);
						obj["APUGenHz"].hide();
						obj["APUGenVolt"].hide();
						obj["APUGenLoad"].hide();
						obj["text3724"].hide();
						obj["text3728"].hide();
						obj["text3732"].hide();
					}
				} else {
					obj["APUGentext"].setColor(0.8078,0.8039,0.8078);
					obj["APUGenbox"].hide();
					obj["APUGenHz"].hide();
					obj["APUGenVolt"].hide();
					obj["APUGenLoad"].hide();
					obj["text3724"].hide();
					obj["text3728"].hide();
					obj["text3732"].hide();
				}
			}),
			props.UpdateManager.FromHashList(["apuFuelPumpsOff","apuFuelPump"], nil, func(val) {
				if (val.apuFuelPumpsOff and !val.apuFuelPump) {
					obj["APUfuelLO"].show();
				} else {
					obj["APUfuelLO"].hide();
				}
			}),
			props.UpdateManager.FromHashList(["apuRpm","apuOilLevel","gear0Wow"], nil, func(val) {
				if (val.apuRpm >= 94.9 and val.gear0Wow and val.apuOilLevel < 3.69) {
					obj["APU-low-oil"].show();
				} else {
					obj["APU-low-oil"].hide();
				}
			}),
			props.UpdateManager.FromHashList(["apuAdr","apuPsi","apuRpm"], nil, func(val) {
				if (val.apuAdr and val.apuRpm > 0.001) {
					obj["APUBleedPSI"].setColor(0.0509,0.7529,0.2941);
					obj["APUBleedPSI"].setText(sprintf("%s", math.round(val.apuPsi)));
				} else {
					obj["APUBleedPSI"].setColor(0.7333,0.3803,0);
					obj["APUBleedPSI"].setText(sprintf("%s", "XX"));
				}
			}),
			props.UpdateManager.FromHashValue("apuLoad", 0.1, func(val) {
				obj["APUGenLoad"].setText(sprintf("%s", math.round(val)));
				
				if (val <= 100) {
					obj["APUGenHz"].setColor(0.0509,0.7529,0.2941);
				} else {
					obj["APUGenHz"].setColor(0.7333,0.3803,0);
				}
			}),
			props.UpdateManager.FromHashValue("apuHertz", 1, func(val) {
				if (val == 0) {
					obj["APUGenHz"].setText(sprintf("XX"));
				} else {
					obj["APUGenHz"].setText(sprintf("%s", math.round(val)));
				}
				
				if (val >= 390 and val <= 410) {
					obj["APUGenHz"].setColor(0.0509,0.7529,0.2941);
				} else {
					obj["APUGenHz"].setColor(0.7333,0.3803,0);
				}
			}),
			props.UpdateManager.FromHashValue("apuVolt", 0.1, func(val) {
				obj["APUGenVolt"].setText(sprintf("%s", math.round(val)));
				
				if (val >= 110 and val <= 120) {
					obj["APUGenVolt"].setColor(0.0509,0.7529,0.2941);
				} else {
					obj["APUGenVolt"].setColor(0.7333,0.3803,0);
				}
			}),
			props.UpdateManager.FromHashValue("apuGLC", nil, func(val) {
				if (val) {
					obj["APUGenOnline"].show();
				} else {
					obj["APUGenOnline"].hide();
				}
			}),
			props.UpdateManager.FromHashList(["apuBleedValvePos","apuBleedValveCmd"], nil, func(val) {
				if (val.apuBleedValvePos == 1) {
					obj["APUBleedValve"].setRotation(90 * D2R);
					obj["APUBleedOnline"].show();
				} else {
					obj["APUBleedValve"].setRotation(0);
					obj["APUBleedOnline"].hide();
				}
				
				if (val.apuBleedValveCmd == val.apuBleedValvePos) {
					obj["APUBleedValveCrossBar"].setColor(0.0509,0.7529,0.2941);
					obj["APUBleedValveCrossBar"].setColorFill(0.0509,0.7529,0.2941);
					obj["APUBleedValve"].setColor(0.0509,0.7529,0.2941);
				} else {
					obj["APUBleedValveCrossBar"].setColor(0.7333,0.3803,0);
					obj["APUBleedValveCrossBar"].setColorFill(0.7333,0.3803,0);
					obj["APUBleedValve"].setColor(0.7333,0.3803,0);
				}
			}),
		];
		
		obj.displayedGForce = 0;
		obj.updateItemsBottom = [
			props.UpdateManager.FromHashValue("acconfigUnits", nil, func(val) {
				obj.units = val;
				if (val) {
					obj["GW-weight-unit"].setText("KG");
				} else {
					obj["GW-weight-unit"].setText("LBS");
				}
			}),
			props.UpdateManager.FromHashValue("hour", nil, func(val) {
				obj["UTCh"].setText(sprintf("%02d", val));
			}),
			props.UpdateManager.FromHashValue("minute", nil, func(val) {
				obj["UTCm"].setText(sprintf("%02d", val));
			}),
			props.UpdateManager.FromHashValue("gForce", 0.05, func(val) {
				if (obj.displayedGForce) {
					obj["GLoad"].setText("G.LOAD " ~ sprintf("%3.1f", val));
				}
			}),
			props.UpdateManager.FromHashValue("gForceDisplay", nil, func(val) {
				if ((val == 1 and !obj.displayedGForce) or (val != 0 and obj.displayedGForce)) {
					obj.displayedGForce = 1;
					obj["GLoad"].show();
				} else {
					obj.displayedGForce = 0;
					obj["GLoad"].hide();
				}
			}),
		];
		return obj;
	},
	getKeysBottom: func() {
		return ["TAT","SAT","GW","UTCh","UTCm","GLoad","GW-weight-unit"];
	},
	getKeys: func() {
		return ["APUN-needle","APUEGT-needle","APUN","APUEGT","APUAvail","APUFlapOpen","APUBleedValve","APUBleedOnline","APUBleedValveCrossBar","APUGenOnline","APUGenOff","APUGentext","APUGenLoad","APUGenbox","APUGenVolt","APUGenHz","APUBleedPSI","APUfuelLO","APU-low-oil","text3724","text3728","text3732"];
	},
	updateBottom: func(notification) {
		foreach(var update_item_bottom; me.updateItemsBottom)
        {
            update_item_bottom.update(notification);
        }
		
		if (fmgc.FMGCInternal.fuelRequest and fmgc.FMGCInternal.blockConfirmed and !fmgc.FMGCInternal.fuelCalculating and notification.FWCPhase != 1) {
			if (me.units) {
				me["GW"].setText(sprintf("%s", math.round(fmgc.FMGCInternal.fuelPredGw * 1000 * LBS2KGS, 100)));
			} else {
				me["GW"].setText(sprintf("%s", math.round(fmgc.FMGCInternal.fuelPredGw * 1000, 100)));
			}
			me["GW"].setColor(0.0509,0.7529,0.2941);
		} else {
			me["GW"].setText(sprintf("%s", " --    "));
			me["GW"].setColor(0.0901,0.6039,0.7176);
		}
		
		if (dmc.DMController.DMCs[1].outputs[4] != nil) {
			me["SAT"].setText(sprintf("%+2.0f", dmc.DMController.DMCs[1].outputs[4].getValue()));
			me["SAT"].setColor(0.0509,0.7529,0.2941);
		} else {
			me["SAT"].setText(sprintf("%s", "XX"));
			me["SAT"].setColor(0.7333,0.3803,0);
		}
		
		if (dmc.DMController.DMCs[1].outputs[5] != nil) {
			me["TAT"].setText(sprintf("%+2.0f", dmc.DMController.DMCs[1].outputs[5].getValue()));
			me["TAT"].setColor(0.0509,0.7529,0.2941);
		} else {
			me["TAT"].setText(sprintf("%s", "XX"));
			me["TAT"].setColor(0.7333,0.3803,0);
		}
	},
	update: func(notification) {
		me.updatePower();
		
		if (me.test.getVisible() == 1) {
			me.updateTest(notification);
		}
		
		if (me.group.getVisible() == 0) {
			return;
		}
		
		foreach(var update_item; me.update_items)
        {
            update_item.update(notification);
        }
		
		me.updateBottom(notification);
	},
	updatePower: func() {
		if (me.name == ecam.SystemDisplayController.displayedPage.name) {
			if (du4_lgt.getValue() > 0.01 and systems.ELEC.Bus.ac2.getValue() >= 110) {
				if (du4_test_time.getValue() + du4_test_amount.getValue() >= pts.Sim.Time.elapsedSec.getValue()) {
					me.group.setVisible(0);
					me.test.setVisible(1);
				} else {
					me.group.setVisible(1);
					me.test.setVisible(0);
				}
			} else {
				if (pts.Modes.EcamDuXfr.getBoolValue()) {
					if (du3_lgt.getValue() > 0.01 and systems.ELEC.Bus.acEss.getValue() >= 110) {
						if (du3_test_time.getValue() + du3_test_amount.getValue() >= pts.Sim.Time.elapsedSec.getValue()) {
							me.group.setVisible(0);
							me.test.setVisible(1);
						} else {
							me.group.setVisible(1);
							me.test.setVisible(0);
						}
					} else {
						me.group.setVisible(0);
						me.test.setVisible(0);
					}
				} else {
					me.group.setVisible(0);
					me.test.setVisible(0);
				}
			}
		} else {
			me.group.setVisible(0);
			# don't hide the test group; just let whichever page is active control it
		}
	},
};

var input = {
	apuAdr: "/systems/navigation/adr/operating-1",
	apuAvailable: "/systems/apu/available",
	apuBleed: "/controls/pneumatics/switches/apu",
	apuBleedValveCmd: "/systems/pneumatics/valves/apu-bleed-valve-cmd",
	apuBleedValvePos: "/systems/pneumatics/valves/apu-bleed-valve",
	apuEgt: "/systems/apu/egt-degC",
	apuEgtRot: "/ECAM/Lower/APU-EGT",
	apuGenPB: "/controls/electrical/switches/apu",
	apuGLC: "/systems/electrical/relay/apu-glc/contact-pos",
	apuFireBtn: "/controls/apu/fire-btn",
	apuFlap: "/controls/apu/inlet-flap/position-norm",
	apuFuelPump: "/systems/fuel/pumps/apu-operate",
	apuFuelPumpsOff: "/systems/fuel/pumps/all-eng-pump-off",
	apuOilLevel: "/systems/apu/oil/level-l",
	apuMaster: "/controls/apu/master",
	apuNeedleRot: "/ECAM/Lower/APU-N",
	apuRpm: "/engines/engine[2]/n1",
	apuPsi: "/systems/pneumatics/source/apu-psi",
	apuLoad: "/systems/electrical/extra/apu-load",
	apuHertz: "/systems/electrical/sources/apu/output-hertz",
	apuVolt: "/systems/electrical/sources/apu/output-volt",
};

foreach (var name; keys(input)) {
	emesary.GlobalTransmitter.NotifyAll(notifications.FrameNotificationAddProperty.new("A320 System Display", name, input[name]));
}