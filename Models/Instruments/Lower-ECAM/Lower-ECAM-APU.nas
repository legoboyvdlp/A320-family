# A3XX Lower ECAM Canvas
# Copyright (c) 2023 Josh Davidson (Octal450) and Jonathan Redpath

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
		
		
		# init
		obj["APUGenOff"].hide();
		obj.apuADRState = 0;
		obj.apuBleedPsi = 0.0;
		obj.apuEgt = 0.0;
		obj.apuOilLevelLow = 0;
		obj.showApuParams = 0;
		
		obj.update_items = [
			props.UpdateManager.FromHashList(["apuAvailable","apuMaster","apuGenPB"], nil, func(val) {
				if (val.apuMaster or val.apuAvailable) {
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
			
			
			props.UpdateManager.FromHashValue("apuAdr", 0.5, func(val) {
				obj.apuADRState = val;
			}),
			props.UpdateManager.FromHashValue("apuAvailable", nil, func(val) {
				if (val) {
					obj["APUAvail"].show();
				} else {
					obj["APUAvail"].hide();
				}
			}),
			props.UpdateManager.FromHashValue("apuBleedValvePos", 0.1, func(val) {
				if (val >= 0.9) {
					obj["APUBleedValve"].setRotation(90 * D2R);
					obj["APUBleedOnline"].show();
				} else {
					obj["APUBleedValve"].setRotation(0);
					obj["APUBleedOnline"].hide();
				}
			}),
			props.UpdateManager.FromHashValue("apuBleedValvePositionsMatch", 1, func(val) {
				if (val) {
					obj["APUBleedValveCrossBar"].setColor(0.0509,0.7529,0.2941);
					obj["APUBleedValveCrossBar"].setColorFill(0.0509,0.7529,0.2941);
					obj["APUBleedValve"].setColor(0.0509,0.7529,0.2941);
				} else {
					obj["APUBleedValveCrossBar"].setColor(0.7333,0.3803,0);
					obj["APUBleedValveCrossBar"].setColorFill(0.7333,0.3803,0);
					obj["APUBleedValve"].setColor(0.7333,0.3803,0);
				}
			}),
			props.UpdateManager.FromHashValue("apuEgt", 0.05, func(val) {
				obj.apuEgt = sprintf("%s", math.clamp(math.round(val, 5), 0, 9995));
			}),
			props.UpdateManager.FromHashValue("apuEgtRot", 0.1, func(val) {
				obj["APUEGT-needle"].setRotation((val + 90) * D2R);
			}),
			props.UpdateManager.FromHashValue("apuFlap", 1, func(val) {
				if (val) {
					obj["APUFlapOpen"].show();
				} else {
					obj["APUFlapOpen"].hide();
				}
			}),
			props.UpdateManager.FromHashValue("apuGLC", nil, func(val) {
				if (val) {
					obj["APUGenOnline"].show();
				} else {
					obj["APUGenOnline"].hide();
				}
			}),
			props.UpdateManager.FromHashValue("apuHertz", 0.5, func(val) {
				obj["APUGenHz"].setText(sprintf("%s", math.round(val)));
				
				if (val >= 390 and val <= 410) {
					obj["APUGenHz"].setColor(0.0509,0.7529,0.2941);
				} else {
					obj["APUGenHz"].setColor(0.7333,0.3803,0);
				}
			}),
			props.UpdateManager.FromHashValue("apuLoad", 0.5, func(val) {
				obj["APUGenLoad"].setText(sprintf("%s", math.round(val)));
				
				if (val <= 100) {
					obj["APUGenLoad"].setColor(0.0509,0.7529,0.2941);
				} else {
					obj["APUGenLoad"].setColor(0.7333,0.3803,0);
				}
			}),
			props.UpdateManager.FromHashValue("apuNeedleRot", 0.1, func(val) {
				obj["APUN-needle"].setRotation((val + 90) * D2R);
			}),
			props.UpdateManager.FromHashValue("apuOilLevel", 0.05, func(val) {
				if (val < 3.7) {
					obj.apuOilLevelLow = 1;
				} else {
					obj.apuOilLevelLow = 0;
				}
			}),
			props.UpdateManager.FromHashValue("apuPsi", 0.5, func(val) {
				obj.apuBleedPsi = sprintf("%s", math.round(val));
			}),
			props.UpdateManager.FromHashValue("apuRpm", 0.5, func(val) {
				if (val >= 0.5) {
					if (val >= 107) {
						obj["APUN"].setColor(1,0,0);
						obj["APUN-needle"].setColor(1,0,0);
					} elsif (val >= 102) {
						obj["APUN"].setColor(0.7333,0.3803,0);
						obj["APUN-needle"].setColor(0.7333,0.3803,0);
					} else {
						obj["APUN"].setColor(0.0509,0.7529,0.2941);
						obj["APUN-needle"].setColor(0.0509,0.7529,0.2941);
					}
					
					obj["APUEGT"].setColor(0.0509,0.7529,0.2941);
					obj["APUN-needle"].show();
					obj["APUEGT-needle"].show();
					obj["APUN"].setText(sprintf("%s", math.round(val)));
					obj.showApuParams = 1;
				} else {
					obj["APUN"].setColor(0.7333,0.3803,0);
					obj["APUN-needle"].setColor(0.7333,0.3803,0);
					obj["APUEGT"].setColor(0.7333,0.3803,0);
					obj["APUN-needle"].hide();
					obj["APUEGT-needle"].hide();
					obj["APUN"].setText("XX");
					obj.showApuParams = 0;
				}
			}),
			props.UpdateManager.FromHashValue("apuVolt", 0.5, func(val) {
				obj["APUGenVolt"].setText(sprintf("%s", math.round(val)));
				
				if (val >= 110 and val <= 120) {
					obj["APUGenVolt"].setColor(0.0509,0.7529,0.2941);
				} else {
					obj["APUGenVolt"].setColor(0.7333,0.3803,0);
				}
			}),
		];
		
		obj.updateItemsPower = [
			props.UpdateManager.FromHashList(["du3Power","du4Power","du3InTest","du4InTest","ecamDuXfr","pageMatch"], 1, func(val) {
				if (val.pageMatch) {
					if (val.du4Power) {
						obj.group.setVisible(val.du4InTest ? 0 : 1);
						obj.test.setVisible(val.du4InTest ? 1 : 0);
					} else if (val.ecamDuXfr and val.du3Power) {
						obj.group.setVisible(val.du3InTest ? 0 : 1);
						obj.test.setVisible(val.du3InTest ? 1 : 0);
					} else {
						obj.group.setVisible(0);
						obj.test.setVisible(0);
					}
				} else {
					obj.group.setVisible(0);
				}
			}),
		];
		
		obj.updateItemsBottom = [
			props.UpdateManager.FromHashValue("acconfigUnits", 1, func(val) {
				if (val) {
					obj["GW-weight-unit"].setText("KG");
				} else {
					obj["GW-weight-unit"].setText("LBS");
				}
			}),
			props.UpdateManager.FromHashValue("hour", 1, func(val) {
				obj["UTCh"].setText(sprintf("%02d", val));
			}),
			props.UpdateManager.FromHashValue("minute", 1, func(val) {
				obj["UTCm"].setText(sprintf("%02d", val));
			}),
			props.UpdateManager.FromHashValue("gForce", 0.05, func(val) {
				obj["GLoad"].setText("G.LOAD " ~ sprintf("%3.1f", val));
			}),
			props.UpdateManager.FromHashValue("gForceDisplay", nil, func(val) {
				if (val) {
					obj["GLoad"].show();
				} else {
					obj["GLoad"].hide();
				}
			}),
			props.UpdateManager.FromHashValue("satTemp", 0.5, func(val) {
				obj["SAT"].setText(sprintf("%+2.0f", val));
			}),
			props.UpdateManager.FromHashValue("tatTemp", 0.5, func(val) {
				obj["TAT"].setText(sprintf("%+2.0f", val));
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
		if (fmgc.FMGCInternal.fuelRequest and fmgc.FMGCInternal.blockConfirmed and !fmgc.FMGCInternal.fuelCalculating and notification.FWCPhase != 1) {
			if (notification.acconfigUnits) {
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
			notification.satTemp = dmc.DMController.DMCs[1].outputs[4].getValue();
			me["SAT"].setColor(0.0509,0.7529,0.2941);
		} else {
			me["SAT"].setText("XX");
			me["SAT"].setColor(0.7333,0.3803,0);
		}
		
		if (dmc.DMController.DMCs[1].outputs[5] != nil) {
			notification.tatTemp = dmc.DMController.DMCs[1].outputs[5].getValue();
			me["TAT"].setColor(0.0509,0.7529,0.2941);
		} else {
			me["TAT"].setText("XX");
			me["TAT"].setColor(0.7333,0.3803,0);
		}
		
		foreach(var update_item_bottom; me.updateItemsBottom)
        {
            update_item_bottom.update(notification);
        }
	},
	update: func(notification) {
		me.updatePower(notification);
		
		if (me.test.getVisible() == 1) {
			me.updateTest(notification);
		}
		
		if (me.group.getVisible() == 0) {
			return;
		}
		
		if ((notification.apuBleedValveCmd >= 0.95 and notification.apuBleedValvePos) or (notification.apuBleedValveCmd <= 0.05 and !notification.apuBleedValvePos)) {
			notification.apuBleedValvePositionsMatch = 1;
		} else {
			notification.apuBleedValvePositionsMatch = 0;
		}
		
		foreach(var update_item; me.update_items)
        {
            update_item.update(notification);
        }
		
		if (me.showApuParams) {
			me["APUEGT"].setText(me.apuEgt);
		} else {
			me["APUEGT"].setText("XX");
		}
		
		if (notification.apuAvailable and notification.gear0Wow and me.apuOilLevelLow) {
			me["APU-low-oil"].show();
		} else {
			me["APU-low-oil"].hide();
		}
		
		if (me.apuADRState and me.showApuParams) {
			me["APUBleedPSI"].setColor(0.0509,0.7529,0.2941);
			me["APUBleedPSI"].setText(me.apuBleedPsi);
		} else {
			me["APUBleedPSI"].setColor(0.7333,0.3803,0);
			me["APUBleedPSI"].setText("XX");
		}
		
		me.updateBottom(notification);
	},
	updatePower: func(notification) {
		if (me.name == ecam.SystemDisplayController.displayedPage.name) {
			notification.pageMatch = 1;
		} else {
			notification.pageMatch = 0;
		}
		
		foreach(var update_item; me.updateItemsPower)
		{
			update_item.update(notification);
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