# A3XX Lower ECAM Canvas
# Copyright (c) 2021 Josh Davidson (Octal450) and Jonathan Redpath

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
		
		obj.units = acconfig_weight_kgs.getValue();
		
		# init
		obj["FUEL-clog-1"].hide();
		obj["FUEL-clog-2"].hide();
		obj["OIL-clog-1"].hide();
		obj["OIL-clog-2"].hide();
		
		obj.quantity = [nil, nil];
		
		obj.update_items = [
			props.UpdateManager.FromHashValue("engOilQt1", 0.005, func(val) {
				if (obj.units) {
					obj.quantity[0] = sprintf("%2.1f",(0.1 * math.round(val * QT2LTR * 10,5)));
					obj["OilQT1"].setText(sprintf("%s", left(obj.quantity[0], (size(obj.quantity[0]) == 4 ? 2 : 1))));
					obj["OilQT1-decimal"].setText(sprintf("%s", right(obj.quantity[0],1)));
					obj["OilQT1-needle"].setRotation(((val * QT2LTR) + 90) * D2R);
				} else {
					obj.quantity[0] = sprintf("%2.1f",(0.1 * math.round(val * 10,5)));
					obj["OilQT1"].setText(sprintf("%s", left(obj.quantity[0], (size(obj.quantity[0]) == 4 ? 2 : 1))));
					obj["OilQT1-decimal"].setText(sprintf("%s", right(obj.quantity[0],1)));
					obj["OilQT1-needle"].setRotation((val + 90) * D2R);
				}
			}),
			props.UpdateManager.FromHashValue("engOilQt2", 0.005, func(val) {
				if (obj.units) {
					obj.quantity[1] = sprintf("%2.1f",(0.1 * math.round(val * QT2LTR * 10,5)));
					obj["OilQT2"].setText(sprintf("%s", left(obj.quantity[1], (size(obj.quantity[1]) == 4 ? 2 : 1))));
					obj["OilQT2-decimal"].setText(sprintf("%s", right(obj.quantity[1],1)));
					obj["OilQT2-needle"].setRotation(((val * QT2LTR) + 90) * D2R);
				} else {
					obj.quantity[1] = sprintf("%2.1f",(0.1 * math.round(val * 10,5)));
					obj["OilQT2"].setText(sprintf("%s", left(obj.quantity[1], (size(obj.quantity[1]) == 4 ? 2 : 1))));
					obj["OilQT2-decimal"].setText(sprintf("%s", right(obj.quantity[1],1)));
					obj["OilQT2-needle"].setRotation((val + 90) * D2R);
				}
			}),
			props.UpdateManager.FromHashValue("engOilPsi1", 0.25, func(val) {
				if (val >= 13) {
					obj["OilPSI1"].setColor(0.0509,0.7529,0.2941);
					obj["OilPSI1-needle"].setColor(0.0509,0.7529,0.2941);
				} else {
					obj["OilPSI1"].setColor(1,0,0);
					obj["OilPSI1-needle"].setColor(1,0,0);
				}

				obj["OilPSI1"].setText(sprintf("%s", math.round(val)));
				obj["OilPSI1-needle"].setRotation((val + 90) * D2R);
			}),
			props.UpdateManager.FromHashValue("engOilPsi2", 0.25, func(val) {
				if (val >= 13) {
					obj["OilPSI2"].setColor(0.0509,0.7529,0.2941);
					obj["OilPSI2-needle"].setColor(0.0509,0.7529,0.2941);
				} else {
					obj["OilPSI2"].setColor(1,0,0);
					obj["OilPSI2-needle"].setColor(1,0,0);
				}
				
				obj["OilPSI2"].setText(sprintf("%s", math.round(val)));
				obj["OilPSI2-needle"].setRotation((val + 90) * D2R);
			}),
			props.UpdateManager.FromHashValue("acconfigUnits", nil, func(val) {
				if (val) {
					obj["Fused-weight-unit"].setText("KG");
					obj["Fused-oil-unit"].setText("LTR");
					# immediately update parameters
					obj.quantity[0] = sprintf("%2.1f",(0.1 * math.round(pts.Engines.Engine.oilQt[0].getValue() * QT2LTR * 10,5)));
					obj["OilQT1"].setText(sprintf("%s", left(obj.quantity[0], (size(obj.quantity[0]) == 4 ? 2 : 1))));
					obj["OilQT1-decimal"].setText(sprintf("%s", right(obj.quantity[0],1)));
					obj["OilQT1-needle"].setRotation(((pts.Engines.Engine.oilQt[0].getValue() * QT2LTR) + 90) * D2R);
					obj.quantity[1] = sprintf("%2.1f",(0.1 * math.round(pts.Engines.Engine.oilQt[1].getValue() * QT2LTR * 10,5)));
					obj["OilQT2"].setText(sprintf("%s", left(obj.quantity[1], (size(obj.quantity[1]) == 4 ? 2 : 1))));
					obj["OilQT2-decimal"].setText(sprintf("%s", right(obj.quantity[1],1)));
					obj["OilQT2-needle"].setRotation(((pts.Engines.Engine.oilQt[1].getValue() * QT2LTR) + 90) * D2R);
					obj["FUEL-used-1"].setText(sprintf("%s", math.round(fuel_used_lbs1.getValue() * LBS2KGS, 10)));
					obj["FUEL-used-2"].setText(sprintf("%s", math.round(fuel_used_lbs2.getValue() * LBS2KGS, 10)));
				} else {
					obj["Fused-weight-unit"].setText("LBS");
					obj["Fused-oil-unit"].setText("QT");
					obj.quantity[0] = sprintf("%2.1f",(0.1 * math.round(pts.Engines.Engine.oilQt[0].getValue() * 10,5)));
					obj["OilQT1"].setText(sprintf("%s", left(obj.quantity[0], (size(obj.quantity[0]) == 4 ? 2 : 1))));
					obj["OilQT1-decimal"].setText(sprintf("%s", right(obj.quantity[0],1)));
					obj["OilQT1-needle"].setRotation((pts.Engines.Engine.oilQt[0].getValue() + 90) * D2R);
					obj.quantity[1] = sprintf("%2.1f",(0.1 * math.round(pts.Engines.Engine.oilQt[1].getValue() * 10,5)));
					obj["OilQT2"].setText(sprintf("%s", left(obj.quantity[1], (size(obj.quantity[1]) == 4 ? 2 : 1))));
					obj["OilQT2-decimal"].setText(sprintf("%s", right(obj.quantity[1],1)));
					obj["OilQT2-needle"].setRotation((pts.Engines.Engine.oilQt[1].getValue() + 90) * D2R);
					obj["FUEL-used-1"].setText(sprintf("%s", math.round(fuel_used_lbs1.getValue(), 10)));
					obj["FUEL-used-2"].setText(sprintf("%s", math.round(fuel_used_lbs2.getValue(), 10)));
				}
			}),
			props.UpdateManager.FromHashValue("engFuelUsed1", 1, func(val) {
				if (obj.units) {
					obj["FUEL-used-1"].setText(sprintf("%s", math.round(val * LBS2KGS, 10)));
				} else {
					obj["FUEL-used-1"].setText(sprintf("%s", math.round(val, 10)));
				}
			}),
			props.UpdateManager.FromHashValue("engFuelUsed2", 1, func(val) {
				if (obj.units) {
					obj["FUEL-used-2"].setText(sprintf("%s", math.round(val * LBS2KGS, 10)));
				} else {
					obj["FUEL-used-2"].setText(sprintf("%s", math.round(val, 10)));
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
		return["OilQT1-needle","OilQT2-needle","OilQT1","OilQT2","OilQT1-decimal","OilQT2-decimal","OilPSI1-needle","OilPSI2-needle","OilPSI1","OilPSI2",
		"FUEL-used-1","FUEL-used-2", "Fused-weight-unit","Fused-oil-unit","FUEL-clog-1","FUEL-clog-2","OIL-clog-1","OIL-clog-2","OilTemp1","OilTemp2",
		"VIB-N1-1","VIB-N1-2","VIB-N2-1","VIB-N2-2"];
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
	engFuelUsed1: "/systems/fuel/fuel-used-1",
	engFuelUsed2: "/systems/fuel/fuel-used-2",
	engOilQt1: "/engines/engine[0]/oil-qt-actual",
	engOilQt2: "/engines/engine[1]/oil-qt-actual",
	engOilPsi1: "/engines/engine[0]/oil-psi-actual",
	engOilPsi2: "/engines/engine[1]/oil-psi-actual",
};

foreach (var name; keys(input)) {
	emesary.GlobalTransmitter.NotifyAll(notifications.FrameNotificationAddProperty.new("A320 System Display", name, input[name]));
}