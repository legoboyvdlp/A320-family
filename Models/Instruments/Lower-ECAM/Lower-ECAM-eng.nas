# A3XX Lower ECAM Canvas
# Copyright (c) 2022 Josh Davidson (Octal450) and Jonathan Redpath

var fuel_used_lbs1 = props.globals.getNode("/systems/fuel/fuel-used-1", 1);
var fuel_used_lbs2 = props.globals.getNode("/systems/fuel/fuel-used-2", 1);

var QT2LTR = 0.946353;

var canvas_lowerECAMPageEng =
{
	new: func(svg,name) {
		var obj = {parents: [canvas_lowerECAMPageEng,canvas_lowerECAM_base] };
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
		obj["FUEL-clog-1"].hide();
		obj["FUEL-clog-2"].hide();
		obj["OIL-clog-1"].hide();
		obj["OIL-clog-2"].hide();
		
		obj.quantity = [0, 0];
		obj.pressure = [0, 0];
		obj.temperature = [0, 0];
		
		obj.update_items = [
			props.UpdateManager.FromHashList(["engOilQT1","acconfigUnits"], 0.005, func(val) {
				if (val.acconfigUnits) {
					obj.quantity[0] = sprintf("%2.1f", math.clamp((0.1 * math.round(val.engOilQT1 * QT2LTR * 10, 5)), 0, 99.5));
				} else {
					obj.quantity[0] = sprintf("%2.1f", math.clamp((0.1 * math.round(val.engOilQT1 * 10, 5)), 0, 99.5));
				}
				obj["OilQT1"].setText(sprintf("%s", left(obj.quantity[0], (size(obj.quantity[0]) == 4 ? 2 : 1))));
				obj["OilQT1-decimal"].setText(sprintf("%s", right(obj.quantity[0], 1)));
				obj["OilQT1-needle"].setRotation(math.clamp(val.engOilQT1, 0, 27) * 6.66 * D2R);
			}),
			props.UpdateManager.FromHashList(["engOilQT2","acconfigUnits"], 0.005, func(val) {
				if (val.acconfigUnits) {
					obj.quantity[1] = sprintf("%2.1f", math.clamp((0.1 * math.round(val.engOilQT2 * QT2LTR * 10, 5)), 0, 99.5));
				} else {
					obj.quantity[1] = sprintf("%2.1f", math.clamp((0.1 * math.round(val.engOilQT2 * 10, 5)), 0, 99.5));
				}
				obj["OilQT2"].setText(sprintf("%s", left(obj.quantity[1], (size(obj.quantity[1]) == 4 ? 2 : 1))));
				obj["OilQT2-decimal"].setText(sprintf("%s", right(obj.quantity[1], 1)));
				obj["OilQT2-needle"].setRotation(math.clamp(val.engOilQT2, 0, 27) * 6.66 * D2R);
			}),
			props.UpdateManager.FromHashValue("engOilPsi1", 0.25, func(val) {
				obj.pressure[0] = val;
				
				if (val >= 13) {
					obj["OilPSI1-needle"].setColor(0.0509,0.7529,0.2941);
				} else {
					obj["OilPSI1-needle"].setColor(1,0,0);
				}
				obj["OilPSI1-needle"].setRotation(math.clamp(val, 0, 100) * 1.8 * D2R);
			}),
			props.UpdateManager.FromHashValue("engOilPsi2", 0.25, func(val) {
				obj.pressure[1] = val;
				
				if (val >= 13) {
					obj["OilPSI2-needle"].setColor(0.0509,0.7529,0.2941);
				} else {
					obj["OilPSI2-needle"].setColor(1,0,0);
				}
				obj["OilPSI2-needle"].setRotation(math.clamp(val, 0, 100) * 1.8 * D2R);
			}),
			props.UpdateManager.FromHashList(["engFuelUsed1","acconfigUnits"], 1, func(val) {
				if (val.acconfigUnits) {
					obj["FUEL-used-1"].setText(sprintf("%s", math.round(val.engFuelUsed1 * LBS2KGS, 10)));
				} else {
					obj["FUEL-used-1"].setText(sprintf("%s", math.round(val.engFuelUsed1, 10)));
				}
			}),
			props.UpdateManager.FromHashList(["engFuelUsed2","acconfigUnits"], 1, func(val) {
				if (val.acconfigUnits) {
					obj["FUEL-used-2"].setText(sprintf("%s", math.round(val.engFuelUsed2 * LBS2KGS, 10)));
				} else {
					obj["FUEL-used-2"].setText(sprintf("%s", math.round(val.engFuelUsed2, 10)));
				}
			}),
			props.UpdateManager.FromHashValue("acconfigUnits", 1, func(val) {
				if (val) {
					obj["Fused-weight-unit"].setText("KG");
					obj["Fused-oil-unit"].setText("LTR");
				} else {
					obj["Fused-weight-unit"].setText("LBS");
					obj["Fused-oil-unit"].setText("QT");
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
		return["OilQT1-needle","OilQT2-needle","OilQT1","OilQT2","OilQT1-decimal","OilQT2-decimal","OilPSI1-needle","OilPSI2-needle","OilPSI1","OilPSI2",
		"FUEL-used-1","FUEL-used-2", "Fused-weight-unit","Fused-oil-unit","FUEL-clog-1","FUEL-clog-2","OIL-clog-1","OIL-clog-2","OilTemp1","OilTemp2",
		"VIB-N1-1","VIB-N1-2","VIB-N2-1","VIB-N2-2","OilQT1-decimalpt","OilQT2-decimalpt","OilQT1-XX","OilQT2-XX"];
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
		
		if (notification.dc1 >= 25) {
			me["OilQT1-XX"].hide();
			me["OilQT1"].show();
			
			me["OilPSI1"].setText(sprintf("%s", math.clamp(math.round(me.pressure[0], 2), 0, 998)));
			if (me.pressure[0] >= 13) {
				me["OilPSI1"].setColor(0.0509,0.7529,0.2941);
			} else {
				me["OilPSI1"].setColor(1,0,0);
			}
			
			me["OilQT1-decimalpt"].show();
			me["OilQT1-decimal"].show();
			me["OilQT1-needle"].show();
			me["OilPSI1-needle"].show();
		} else {
			me["OilQT1"].hide();
			me["OilQT1-XX"].show();
			me["OilQT1"].setColor(0.7333,0.3803,0);
			me["OilPSI1"].setColor(0.7333,0.3803,0);
			me["OilQT1"].setText(" XX");
			me["OilPSI1"].setText("XX");
			
			me["OilQT1-decimalpt"].hide();
			me["OilQT1-decimal"].hide();
			me["OilQT1-needle"].hide();
			me["OilPSI1-needle"].hide();
		}
		
		if (notification.dc2 >= 25) {
			me["OilQT2-XX"].hide();
			me["OilQT2"].show();
			
			me["OilPSI2"].setText(sprintf("%s", math.clamp(math.round(me.pressure[0], 2), 0, 998)));
			if (me.pressure[1] >= 13) {
				me["OilPSI2"].setColor(0.0509,0.7529,0.2941);
			} else {
				me["OilPSI2"].setColor(1,0,0);
			}
			
			me["OilQT2-decimalpt"].show();
			me["OilQT2-decimal"].show();
			me["OilQT2-needle"].show();
			me["OilPSI2-needle"].show();
		} else {
			me["OilQT2"].hide();
			me["OilQT2-XX"].show();
			me["OilPSI2"].setColor(0.7333,0.3803,0);
			me["OilPSI2"].setText("XX");
			
			me["OilQT2-decimalpt"].hide();
			me["OilQT2-decimal"].hide();
			me["OilQT2-needle"].hide();
			me["OilPSI2-needle"].hide();
		}
		
		if (notification.dcBat >= 25) {
			me["OilTemp1"].setText("22");
			me["OilTemp1"].setColor(0.0509,0.7529,0.2941);
		} else {
			me["OilTemp1"].setText("XX");
			me["OilTemp1"].setColor(0.7333,0.3803,0);
		}
		
		if (notification.dcEss >= 25) {
			me["OilTemp2"].setText("22");
			me["OilTemp2"].setColor(0.0509,0.7529,0.2941);
		} else {
			me["OilTemp2"].setText("XX");
			me["OilTemp2"].setColor(0.7333,0.3803,0);
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
	engFuelUsed1: "/systems/fuel/fuel-used-1",
	engFuelUsed2: "/systems/fuel/fuel-used-2",
	engOilQT1: "/engines/engine[0]/oil-qt-actual",
	engOilQT2: "/engines/engine[1]/oil-qt-actual",
	engOilPsi1: "/engines/engine[0]/oil-psi-actual",
	engOilPsi2: "/engines/engine[1]/oil-psi-actual",
};

foreach (var name; keys(input)) {
	emesary.GlobalTransmitter.NotifyAll(notifications.FrameNotificationAddProperty.new("A320 System Display", name, input[name]));
}