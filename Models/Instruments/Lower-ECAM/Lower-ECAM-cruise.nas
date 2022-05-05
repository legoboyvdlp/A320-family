# A3XX Lower ECAM Canvas
# Copyright (c) 2021 Josh Davidson (Octal450) and Jonathan Redpath

var canvas_lowerECAMPageCruise =
{
	new: func(svg,name) {
		var obj = {parents: [canvas_lowerECAMPageCruise,canvas_lowerECAM_base] };
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
		obj.quantity = [0, 0];
		
		obj.update_items = [
			props.UpdateManager.FromHashList(["engOil1", "acconfigUnits"], 0.005, func(val) {
				if (val.acconfigUnits) {
					obj.quantity[0] = sprintf("%2.1f", math.clamp((0.1 * math.round(val.engOilQt1 * QT2LTR * 10, 5)), 0, 99.5));
				} else {
					obj.quantity[0] = sprintf("%2.1f", math.clamp((0.1 * math.round(val.engOilQt1 * 10, 5)), 0, 99.5));
				}
			}),
			props.UpdateManager.FromHashList(["engOil2", "acconfigUnits"], 0.005, func(val) {
				if (val.acconfigUnits) {
					obj.quantity[1] = sprintf("%2.1f", math.clamp((0.1 * math.round(val.engOil2 * 10, 5)), 0, 99.5));
				} else {
					obj.quantity[1] = sprintf("%2.1f", math.clamp((0.1 * math.round(val.engOil2 * 10, 5)), 0, 99.5));
				}
			}),
			props.UpdateManager.FromHashValue("acconfigUnits", 1, func(val) {
				if (val) {
					obj["Fused-weight-unit"].setText("KG");
					obj["OilUnit"].setText("LTR");
				} else {
					obj["Fused-weight-unit"].setText("LBS");
					obj["OilUnit"].setText("QT");
				}
			}),
			props.UpdateManager.FromHashList(["engFuelUsed1","acconfigUnits"], 1, func(val) {
				if (val.acconfigUnits) {
					obj["FUsed1"].setText(sprintf("%s", math.round(val.engFuelUsed1 * LBS2KGS, 10)));
				} else {
					obj["FUsed1"].setText(sprintf("%s", math.round(val.engFuelUsed1, 10)));
				}
			}),
			props.UpdateManager.FromHashList(["engFuelUsed2","acconfigUnits"], 1, func(val) {
				if (val.acconfigUnits) {
					obj["FUsed2"].setText(sprintf("%s", math.round(val.engFuelUsed2 * LBS2KGS, 10)));
				} else {
					obj["FUsed2"].setText(sprintf("%s", math.round(val.engFuelUsed2, 10)));
				}
			}),
			props.UpdateManager.FromHashList(["engFuelUsed1","engFuelUsed2","acconfigUnits"], 1, func(val) {
				if (val.acconfigUnits) {
					obj["FUsed"].setText(sprintf("%s", math.round((val.engFuelUsed1 + val.engFuelUsed2) * LBS2KGS, 10)));
				} else {
					obj["FUsed"].setText(sprintf("%s", math.round((val.engFuelUsed1 + val.engFuelUsed2), 10)));
				}
			}),
			props.UpdateManager.FromHashValue("pressDelta", 0.05, func(val) {
				obj["deltaPSI"].setText(sprintf("%2.1f", math.clamp(val, -9.9, 31.9)));
				
				if (val < -0.4 or val > 8.5) {
					obj["deltaPSI"].setColor(0.7333,0.3803,0);
				} else {
					obj["deltaPSI"].setColor(0.0509,0.7529,0.2941);
				}
			}),
			props.UpdateManager.FromHashValue("pressVS", 25, func(val) {
				obj["CABVS"].setText(sprintf("%-4.0f", math.clamp(math.round(val,50), -9950, 9950)));
				
				if (val >= 25) {
					obj["VS-Arrow-UP"].show();
					obj["VS-Arrow-DN"].hide();
				} elsif (val <= -25) {
					obj["VS-Arrow-UP"].hide();
					obj["VS-Arrow-DN"].show();
				} else {
					obj["VS-Arrow-UP"].hide();
					obj["VS-Arrow-DN"].hide();
				}
			}),
			props.UpdateManager.FromHashValue("pressAlt", 25, func(val) {
				obj["CABALT"].setText(sprintf("%5.0f", math.clamp(math.round(val,50), -9950, 32750)));
				
				if (val > 9550) {
					obj["CABALT"].setColor(1,0,0);
				} else {
					obj["CABALT"].setColor(0.0509,0.7529,0.2941);
				}
			}),
			props.UpdateManager.FromHashValue("condTempCockpit", 0.5, func(val) {
				obj["CKPT-TEMP"].setText(sprintf("%2.0f",val));
			}),
			props.UpdateManager.FromHashValue("condTempAft", 0.5, func(val) {
				obj["AFT-TEMP"].setText(sprintf("%2.0f",val));
			}),
			props.UpdateManager.FromHashValue("condTempFwd", 0.5, func(val) {
				obj["FWD-TEMP"].setText(sprintf("%2.0f",val));
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
		return["Oil1","Oil2","OilUnit","FUsed1","FUsed2","FUsed","VIB1N1","VIB1N2","VIB2N1","VIB2N2","deltaPSI","LDGELEV-AUTO","LDGELEV","CABVS","CABALT","VS-Arrow-UP","VS-Arrow-DN","CKPT-TEMP","FWD-TEMP","AFT-TEMP","Fused-weight-unit"];
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
			me["Oil1"].setText(me.quantity[0]);
		} else {
			me["Oil1"].setText("XX");
		}
		if (notification.dc2 >= 25) {
			me["Oil2"].setText(me.quantity[1]);
		} else {
			me["Oil2"].setText("XX");
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
};

foreach (var name; keys(input)) {
	emesary.GlobalTransmitter.NotifyAll(notifications.FrameNotificationAddProperty.new("A320 System Display", name, input[name]));
}