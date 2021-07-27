# A3XX Lower ECAM Canvas
# Copyright (c) 2021 Josh Davidson (Octal450) and Jonathan Redpath

var canvas_lowerECAMPagePress =
{
	new: func(svg,name) {
		var obj = {parents: [canvas_lowerECAMPagePress,canvas_lowerECAM_base] };
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
		obj["PRESS-Sys-2"].hide();
		obj["PRESS-Outlet-Transit-Failed"].hide();
		obj["PRESS-Inlet-Transit-Failed"].hide();
		
		obj.update_items = [
			props.UpdateManager.FromHashValue("pressDelta", 0.05, func(val) {
				if (val > 31.9) {
					obj["PRESS-deltaP"].setText(sprintf("%2.1f", 31.9));
				} else if (val < -9.9) {
					obj["PRESS-deltaP"].setText(sprintf("%2.1f", -9.9));
				} else {
					obj["PRESS-deltaP"].setText(sprintf("%2.1f", val));
				}
				
				if (val < -0.4 or val > 8.5) {
					obj["PRESS-deltaP"].setColor(0.7333,0.3803,0);
				} else {
					obj["PRESS-deltaP"].setColor(0.0509,0.7529,0.2941);
				}
			}),
			props.UpdateManager.FromHashValue("pressVS", 25, func(val) {
				if (val > 9950) {
					obj["PRESS-Cab-VS"].setText(sprintf("%4.0f", 9950));
				} else if (val < -9950) {
					obj["PRESS-Cab-VS"].setText(sprintf("%4.0f", -9950));
				} else {
					obj["PRESS-Cab-VS"].setText(sprintf("%-4.0f", math.round(val,50)));
				}
				
				if (abs(val) > 2000) {
					obj["PRESS-Cab-VS"].setColor(0.7333,0.3803,0);
				} else {
					obj["PRESS-Cab-VS"].setColor(0.0509,0.7529,0.2941);
				}
			}),
			props.UpdateManager.FromHashValue("pressAlt", 25, func(val) {
				if (val > 32750) {
					obj["PRESS-Cab-Alt"].setText(sprintf("%5.0f", 32750));
				} else if (val < -9950) {
					obj["PRESS-Cab-Alt"].setText(sprintf("%5.0f", -9950));
				} else {
					obj["PRESS-Cab-Alt"].setText(sprintf("%5.0f", math.round(val,50)));
				}
				
				if (val > 9550) {
					obj["PRESS-Cab-Alt"].setColor(1,0,0);
				} else {
					obj["PRESS-Cab-Alt"].setColor(0.0509,0.7529,0.2941);
				}
			}),
			props.UpdateManager.FromHashValue("pressAuto", nil, func(val) {
				if (val) {
					obj["PRESS-Man"].hide();
					obj["PRESS-Sys-1"].show();
				} else {
					obj["PRESS-Man"].show();
					obj["PRESS-Sys-1"].hide();
				}
			}),
			props.UpdateManager.FromHashList(["flowCtlValve1","engine1State"], nil, func(val) {
				if (val.flowCtlValve1 == 0 and val.engine1State == 3) {
					obj["PRESS-Pack-1-Triangle"].setColor(0.7333,0.3803,0);
					obj["PRESS-Pack-1"].setColor(0.7333,0.3803,0);
				} else {
					obj["PRESS-Pack-1-Triangle"].setColor(0.0509,0.7529,0.2941);
					obj["PRESS-Pack-1"].setColor(0.8078,0.8039,0.8078);
				}
			}),
			props.UpdateManager.FromHashList(["flowCtlValve2","engine2State"], nil, func(val) {
				if (val.flowCtlValve2 == 0 and val.engine2State == 3) {
					obj["PRESS-Pack-2-Triangle"].setColor(0.7333,0.3803,0);
					obj["PRESS-Pack-2"].setColor(0.7333,0.3803,0);
				} else {
					obj["PRESS-Pack-2-Triangle"].setColor(0.0509,0.7529,0.2941);
					obj["PRESS-Pack-2"].setColor(0.8078,0.8039,0.8078);
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
		return["PRESS-Cab-VS", "PRESS-Cab-VS-neg", "PRESS-Cab-Alt", "PRESS-deltaP", "PRESS-LDG-Elev", "PRESS-deltaP-needle", "PRESS-VS-needle", "PRESS-Alt-needle",
		"PRESS-Man", "PRESS-Sys-1", "PRESS-Sys-2", "PRESS-Outlet-Transit-Failed", "PRESS-Inlet-Transit-Failed", "PRESS-LDG-Elev-mode","PRESS-Pack-1-Triangle","PRESS-Pack-2-Triangle",
		"PRESS-Pack-1","PRESS-Pack-2"];
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
	pressAlt: "/systems/pressurization/cabinalt-norm",
	pressAuto: "/systems/pressurization/auto",
	pressDelta: "/systems/pressurization/deltap-norm",
	pressVS: "/systems/pressurization/vs-norm",
	
	flowCtlValve1: "/systems/air-conditioning/valves/flow-control-valve-1",
	flowCtlValve2: "/systems/air-conditioning/valves/flow-control-valve-2",
};

foreach (var name; keys(input)) {
	emesary.GlobalTransmitter.NotifyAll(notifications.FrameNotificationAddProperty.new("A320 System Display", name, input[name]));
}