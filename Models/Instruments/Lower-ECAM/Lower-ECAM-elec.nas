# A3XX Lower ECAM Canvas
# Copyright (c) 2021 Josh Davidson (Octal450) and Jonathan Redpath

var canvas_lowerECAMPageElec =
{
	new: func(svg,name) {
		var obj = {parents: [canvas_lowerECAMPageElec,canvas_lowerECAM_base] };
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
		obj["IDG1-LOPR"].hide();
		obj["IDG2-LOPR"].hide();
		obj["Shed-label"].hide();
		obj["IDG2-RISE-label"].hide();
		obj["IDG2-RISE-Value"].hide();
		obj["IDG1-RISE-label"].hide();
		obj["IDG1-RISE-Value"].hide();

		
		obj.update_items = [
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
		return ["TAT","SAT","GW","UTCh","UTCm","GLoad","GW-weight-unit","BAT1-label","Bat1Volt","Bat1Ampere","BAT2-label","Bat2Volt","Bat2Ampere","BAT1-charge","BAT1-discharge","BAT2-charge","BAT2-discharge","ELEC-Line-DC1-DCBAT","ELEC-Line-DC1-DCESS","ELEC-Line-DC2-DCBAT",
		"ELEC-Line-DC1-DCESS_DCBAT","ELEC-Line-DC2-DCESS_DCBAT","ELEC-Line-TR1-DC1","ELEC-Line-TR2-DC2","Shed-label","ELEC-Line-ESSTR-DCESS","TR1-label","TR1Volt","TR1Ampere","TR2-label","TR2Volt","TR2Ampere","EMERGEN-group","EmergenVolt","EmergenHz",
		"ELEC-Line-Emergen-ESSTR","EMERGEN-Label-off","Emergen-Label","EMERGEN-out","ELEC-Line-ACESS-TRESS","ELEC-Line-AC1-TR1","ELEC-Line-AC2-TR2","ELEC-Line-AC1-ACESS","ELEC-Line-AC2-ACESS","ACESS-SHED","ACESS","AC1-in","AC2-in","ELEC-Line-GEN1-AC1","ELEC-Line-GEN2-AC2",
		"ELEC-Line-APU-AC1","ELEC-Line-APU-EXT","ELEC-Line-EXT-AC2","APU-out","EXT-out","EXTPWR-group","ExtVolt","ExtHz","APU-content","APU-border","APUGentext","APUGenLoad","APUGenVolt","APUGenHz","APUGEN-off","GEN1-label","Gen1Load","Gen1Volt","Gen1Hz",
		"GEN2-label","Gen2Load","GEN2-off","Gen2Volt","Gen2Hz","ELEC-IDG-1-label","ELEC-IDG-1-num-label","ELEC-IDG-1-Temp","IDG1-LOPR","IDG1-DISC","IDG1-RISE-Value","IDG1-RISE-label","GalleyShed","ELEC-IDG-2-Temp","ELEC-IDG-2-label","ELEC-IDG-2-num-label","IDG2-RISE-label","IDG2-RISE-Value","IDG2-LOPR",
		"IDG2-DISC","ESSTR-group","ESSTR","ESSTR-Volt","ESSTR-Ampere","BAT1-content","BAT2-content","BAT1-OFF","BAT2-OFF","GEN1-content","GEN2-content","GEN-1-num-label","GEN-2-num-label","GEN1-off","GEN2-off","GEN1-num-label","GEN2-num-label","EXTPWR-label",
		"ELEC-ACESS-SHED-label","ELEC-DCBAT-label","ELEC-DCESS-label","ELEC-DC2-label","ELEC-DC1-label","ELEC-AC1-label","ELEC-AC2-label","ELEC-ACESS-label","ELEC-Line-ESSTR-DCESS-off","ELEC-Line-Emergen-ESSTR-off"];
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
			me["GW"].setText(sprintf("%s", "-----"));
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
				me.group.setVisible(0);
				me.test.setVisible(0);
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