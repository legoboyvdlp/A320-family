# A3XX Lower ECAM Canvas
# Copyright (c) 2021 Josh Davidson (Octal450) and Jonathan Redpath

var canvas_lowerECAMPageDoor =
{
	new: func(svg,name) {
		var obj = {parents: [canvas_lowerECAMPageDoor,canvas_lowerECAM_base] };
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
		obj["Cabin2LeftSlide"].hide();
		obj["Cabin2RightSlide"].hide();
		obj["Cabin3LeftSlide"].hide();
		obj["Cabin3RightSlide"].hide();

		obj["AvionicsLine1"].hide();
		obj["AvionicsLine2"].hide();
		obj["AvionicsLbl1"].hide();
		obj["AvionicsLbl2"].hide();
		obj["ExitLLine"].hide();
		obj["ExitLLbl"].hide();
		obj["ExitRLine"].hide();
		obj["ExitRLbl"].hide();
		obj["Cabin2Left"].hide();
		obj["Cabin2LeftLine"].hide();
		obj["Cabin2LeftLbl"].hide();
		obj["Cabin2Right"].hide();
		obj["Cabin2RightLine"].hide();
		obj["Cabin2RightLbl"].hide();
		obj["Cabin3Left"].hide();
		obj["Cabin3LeftLine"].hide();
		obj["Cabin3LeftLbl"].hide();
		obj["Cabin3Right"].hide();
		obj["Cabin3RightLine"].hide();
		obj["Cabin3RightLbl"].hide();

		
		obj.update_items = [
			props.UpdateManager.FromHashValue("doorL1", nil, func(val) {
				if (val > 0) {
					obj["Cabin1Left"].show();
					obj["Cabin1Left"].setColor(0.7333,0.3803,0);
					obj["Cabin1Left"].setColorFill(0.7333,0.3803,0);
					obj["Cabin1LeftLbl"].show();
					obj["Cabin1LeftLine"].show();
					obj["Cabin1LeftSlide"].hide();
				} else {
					obj["Cabin1Left"].setColor(0.0509,0.7529,0.2941);
					obj["Cabin1Left"].setColorFill(0,0,0);
					obj["Cabin1LeftLbl"].hide();
					obj["Cabin1LeftLine"].hide();
					obj["Cabin1LeftSlide"].show();
				}
			}),
			props.UpdateManager.FromHashValue("doorL4", nil, func(val) {
				if (val > 0) {
					obj["Cabin4Left"].show();
					obj["Cabin4Left"].setColor(0.7333,0.3803,0);
					obj["Cabin4Left"].setColorFill(0.7333,0.3803,0);
					obj["Cabin4LeftLbl"].show();
					obj["Cabin4LeftLine"].show();
					obj["Cabin4LeftSlide"].hide();
				} else {
					obj["Cabin4Left"].setColor(0.0509,0.7529,0.2941);
					obj["Cabin4Left"].setColorFill(0,0,0);
					obj["Cabin4LeftLbl"].hide();
					obj["Cabin4LeftLine"].hide();
					obj["Cabin4LeftSlide"].show();
				}
			}),
			props.UpdateManager.FromHashValue("doorR1", nil, func(val) {
				if (val > 0) {
					obj["Cabin1Right"].show();
					obj["Cabin1Right"].setColor(0.7333,0.3803,0);
					obj["Cabin1Right"].setColorFill(0.7333,0.3803,0);
					obj["Cabin1RightLbl"].show();
					obj["Cabin1RightLine"].show();
					obj["Cabin1RightSlide"].hide();
				} else {
					obj["Cabin1Right"].setColor(0.0509,0.7529,0.2941);
					obj["Cabin1Right"].setColorFill(0,0,0);
					obj["Cabin1RightLbl"].hide();
					obj["Cabin1RightLine"].hide();
					obj["Cabin1RightSlide"].show();
				}
			}),
			props.UpdateManager.FromHashValue("doorR4", nil, func(val) {
				if (val > 0) {
					obj["Cabin4Right"].show();
					obj["Cabin4Right"].setColor(0.7333,0.3803,0);
					obj["Cabin4Right"].setColorFill(0.7333,0.3803,0);
					obj["Cabin4RightLbl"].show();
					obj["Cabin4RightLine"].show();
					obj["Cabin4RightSlide"].hide();
				} else {
					obj["Cabin4Right"].setColor(0.0509,0.7529,0.2941);
					obj["Cabin4Right"].setColorFill(0,0,0);
					obj["Cabin4RightLbl"].hide();
					obj["Cabin4RightLine"].hide();
					obj["Cabin4RightSlide"].show();
				}
			}),
			props.UpdateManager.FromHashValue("cargoAft", nil, func(val) {
				if (val > 0) {
					obj["Cargo2Door"].setColor(0.7333,0.3803,0);
					obj["Cargo2Door"].setColorFill(0.7333,0.3803,0);
					obj["Cargo2Lbl"].show();
					obj["Cargo2Line"].show();
				} else {
					obj["Cargo2Door"].setColor(0.0509,0.7529,0.2941);
					obj["Cargo2Door"].setColorFill(0,0,0);
					obj["Cargo2Lbl"].hide();
					obj["Cargo2Line"].hide();
				}
			}),
			props.UpdateManager.FromHashValue("cargoBulk", nil, func(val) {
				if (val > 0) {
					obj["Bulk"].setColor(0.7333,0.3803,0);
					obj["Bulk"].setColorFill(0.7333,0.3803,0);
					obj["BulkLbl"].show();
					obj["BulkLine"].show();
				} else {
					obj["Bulk"].setColor(0.0509,0.7529,0.2941);
					obj["Bulk"].setColorFill(0,0,0);
					obj["BulkLbl"].hide();
					obj["BulkLine"].hide();
				}
			}),
			props.UpdateManager.FromHashValue("cargoFwd", nil, func(val) {
				if (val > 0) {
					obj["Cargo1Door"].setColor(0.7333,0.3803,0);
					obj["Cargo1Door"].setColorFill(0.7333,0.3803,0);
					obj["Cargo1Lbl"].show();
					obj["Cargo1Line"].show();
				} else {
					obj["Cargo1Door"].setColor(0.0509,0.7529,0.2941);
					obj["Cargo1Door"].setColorFill(0,0,0);
					obj["Cargo1Lbl"].hide();
					obj["Cargo1Line"].hide();
				}
			}),
			props.UpdateManager.FromHashList(["oxyPB","oxyBottlePress","oxyBottleRegulLoPr"], nil, func(val) {
				if (val.oxyPB) {
					if (val.oxyBottlePress < 300 or val.oxyBottleRegulLoPr) {
						obj["DOOROXY-OxyIndicator"].setColor(0.7333,0.3803,0);
					} else {
						obj["DOOROXY-OxyIndicator"].setColor(0.8078,0.8039,0.8078);
					}
				} else {
					obj["DOOROXY-OxyIndicator"].setColor(0.7333,0.3803,0);
				}
				
				if (val.oxyBottlePress < 300) {
					obj["DOOROXY-PR"].setColor(0.7333,0.3803,0);
				} else {
					obj["DOOROXY-PR"].setColor(0.0509,0.7529,0.2941);
				}
				obj["DOOROXY-PR"].setText(sprintf("%4.0f", math.round(val.oxyBottlePress, 10)));
			}),
			props.UpdateManager.FromHashValue("pressVS", nil, func(val) {
				if (val > 9950) {
					obj["DOOR-VS"].setText(sprintf("%+4.0f", 9950));
				} else if (val < -9950) {
					obj["DOOR-VS"].setText(sprintf("%+4.0f", -9950));
				} else {
					obj["DOOR-VS"].setText(sprintf("%+4.0f", math.round(val,50)));
				}
				
				if (abs(val) > 2000) {
					obj["DOOR-VS"].setColor(0.7333,0.3803,0);
				} else {
					obj["DOOR-VS"].setColor(0.0509,0.7529,0.2941);
				}
			}),
			props.UpdateManager.FromHashValue("FWCPhase", nil, func(val) {
				if (val >= 5 and val <= 7) {
					obj["DOOR-VS-Container"].show();
				} else {
					obj["DOOR-VS-Container"].hide();
				}
			}),
			props.UpdateManager.FromHashValue("oxyBottleRegulLoPr", nil, func(val) {
				if (val) {
					obj["DOOROXY-REGUL-LO-PR"].show();
				} else {
					obj["DOOROXY-REGUL-LO-PR"].hide();
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
		return["Bulk","BulkLine","BulkLbl","Exit1L","Exit1R","Cabin1Left","Cabin1LeftLbl","Cabin1LeftLine","Cabin1LeftSlide","Cabin1Right","Cabin1RightLbl","Cabin1RightLine","Cabin1RightSlide","Cabin2Left","Cabin2LeftLbl",
		"Cabin2LeftLine","Cabin2LeftSlide","Cabin2Right","Cabin2RightLbl","Cabin2RightLine","Cabin2RightSlide","Cabin3Left","Cabin3LeftLbl","Cabin3LeftLine","Cabin3LeftSlide","Cabin3Right","Cabin3RightLbl","Cabin3RightLine","Cabin3RightSlide","AvionicsLine1",
		"AvionicsLbl1","AvionicsLine2","AvionicsLbl2","Cargo1Line","Cargo1Lbl","Cargo1Door","Cargo2Line","Cargo2Lbl","Cargo2Door","ExitLSlide","ExitLLine","ExitLLbl","ExitRSlide","ExitRLine","ExitRLbl","Cabin4Left","Cabin4LeftLbl","Cabin4LeftLine",
		"Cabin4LeftSlide","Cabin4Right","Cabin4RightLbl","Cabin4RightLine","Cabin4RightSlide","DOOROXY-REGUL-LO-PR","DOOROXY-PR","DOOROXY-OxyIndicator","DOOR-VS","DOOR-VS-Container"];
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
	doorL1: "/sim/model/door-positions/doorl1/position-norm",
	doorL4: "/sim/model/door-positions/doorl4/position-norm",
	doorR1: "/sim/model/door-positions/doorr1/position-norm",
	doorR4: "/sim/model/door-positions/doorr4/position-norm",
	cargoAft: "/sim/model/door-positions/cargoaft/position-norm",
	cargoBulk: "/sim/model/door-positions/cargobulk/position-norm",
	cargoFwd: "/sim/model/door-positions/cargofwd/position-norm",
	oxyPB: "/controls/oxygen/cockpit-oxygen-supply-pb",
	oxyBottlePress: "/systems/oxygen/cockpit-oxygen/bottle-psi",
	oxyBottleRegulLoPr: "/systems/oxygen/cockpit-oxygen/regul-lo-pr",
};

foreach (var name; keys(input)) {
	emesary.GlobalTransmitter.NotifyAll(notifications.FrameNotificationAddProperty.new("A320 System Display", name, input[name]));
}