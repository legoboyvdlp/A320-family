# A3XX Lower ECAM Canvas
# Copyright (c) 2021 Josh Davidson (Octal450) and Jonathan Redpath

var canvas_lowerECAMPageHyd =
{
	new: func(svg,name) {
		var obj = {parents: [canvas_lowerECAMPageHyd,canvas_lowerECAM_base] };
        obj.group = obj.canvas.createGroup();
		obj.name = name;
        
		canvas.parsesvg(obj.group, svg, {"font-mapper": obj.font_mapper} );
		
 		foreach(var key; obj.getKeys()) {
			obj[key] = obj.group.getElementById(key);
			
			var clip_el = obj.group.getElementById(key ~ "_clip");
			if (clip_el != nil) {
				clip_el.setVisible(0);
				var tran_rect = clip_el.getTransformedBounds();

				var clip_rect = sprintf("rect(%d,%d, %d,%d)", 
				tran_rect[1],
				tran_rect[2],
				tran_rect[3],
				tran_rect[0]);
				obj[key].set("clip", clip_rect);
				obj[key].set("clip-frame", canvas.Element.PARENT);
			}
		};
		
		foreach(var key; obj.getKeysBottom()) {
			obj[key] = obj.group.getElementById(key);
		};
		
		obj.units = acconfig_weight_kgs.getValue();
		
		# init
		
		obj.update_items = [
			props.UpdateManager.FromHashList(["blue", "dcEssShed"], 25, func(val) {
				if (val.dcEssShed >= 25) {
					if (val.blue >= 100) {
						obj["Press-Blue"].setText(sprintf("%s", math.round(val.blue, 50)));
					} else {
						obj["Press-Blue"].setText(sprintf("%s", 0));
					}
					
					if (val.blue > 1450) {
						obj["Blue-Line"].setColor(0.0509,0.7529,0.2941);
						obj["Blue-Line"].setColorFill(0.0509,0.7529,0.2941);
						obj["Blue-Line-Top"].setColorFill(0.0509,0.7529,0.2941);
						obj["Blue-Line-Bottom"].setColorFill(0.0509,0.7529,0.2941);
						obj["Blue-Indicator"].setColor(0.0509,0.7529,0.2941);
						obj["Press-Blue"].setColor(0.0509,0.7529,0.2941);
						obj["Blue-label"].setColor(0.8078,0.8039,0.8078);
					} else {
						obj["Blue-Line"].setColor(0.7333,0.3803,0);
						obj["Blue-Line"].setColorFill(0.7333,0.3803,0);
						obj["Blue-Line-Top"].setColorFill(0.7333,0.3803,0);
						obj["Blue-Line-Bottom"].setColorFill(0.7333,0.3803,0);
						obj["Blue-Indicator"].setColor(0.7333,0.3803,0);
						obj["Press-Blue"].setColor(0.7333,0.3803,0);
						obj["Blue-label"].setColor(0.7333,0.3803,0);
					}
				} else {
					obj["Press-Blue"].setText(sprintf("%s", "XX"));
					obj["Blue-Line"].setColor(0.7333,0.3803,0);
					obj["Blue-Line"].setColorFill(0.7333,0.3803,0);
					obj["Blue-Line-Top"].setColorFill(0.7333,0.3803,0);
					obj["Blue-Line-Bottom"].setColorFill(0.7333,0.3803,0);
					obj["Blue-Indicator"].setColor(0.7333,0.3803,0);
					obj["Press-Blue"].setColor(0.7333,0.3803,0);
					obj["Blue-label"].setColor(0.7333,0.3803,0);
				}
			}),
			props.UpdateManager.FromHashList(["yellow", "dcEssShed"], 25, func(val) {
				if (val.dcEssShed >= 25) {
					if (val.yellow >= 100) {
						obj["Press-Yellow"].setText(sprintf("%s", math.round(val.yellow, 50)));
					} else {
						obj["Press-Yellow"].setText(sprintf("%s", 0));
					}
					
					if (val.yellow > 1450) {
						obj["Yellow-Line"].setColor(0.0509,0.7529,0.2941);
						obj["Yellow-Line"].setColorFill(0.0509,0.7529,0.2941);
						obj["Yellow-Line-Top"].setColorFill(0.0509,0.7529,0.2941);
						obj["Yellow-Line-Middle"].setColorFill(0.0509,0.7529,0.2941);
						obj["Yellow-Line-Bottom"].setColorFill(0.0509,0.7529,0.2941);
						obj["Yellow-Indicator"].setColor(0.0509,0.7529,0.2941);
						obj["Press-Yellow"].setColor(0.0509,0.7529,0.2941);
						obj["Yellow-label"].setColor(0.8078,0.8039,0.8078);
					} else {
						obj["Yellow-Line"].setColor(0.7333,0.3803,0);
						obj["Yellow-Line"].setColorFill(0.7333,0.3803,0);
						obj["Yellow-Line-Top"].setColorFill(0.7333,0.3803,0);
						obj["Yellow-Line-Middle"].setColorFill(0.7333,0.3803,0);
						obj["Yellow-Line-Bottom"].setColorFill(0.7333,0.3803,0);
						obj["Yellow-Indicator"].setColor(0.7333,0.3803,0);
						obj["Press-Yellow"].setColor(0.7333,0.3803,0);
						obj["Yellow-label"].setColor(0.7333,0.3803,0);
					}
				} else {
					obj["Press-Yellow"].setText(sprintf("%s", "XX"));
					obj["Yellow-Line"].setColor(0.7333,0.3803,0);
					obj["Yellow-Line"].setColorFill(0.7333,0.3803,0);
					obj["Yellow-Line-Top"].setColorFill(0.7333,0.3803,0);
					obj["Yellow-Line-Middle"].setColorFill(0.7333,0.3803,0);
					obj["Yellow-Line-Bottom"].setColorFill(0.7333,0.3803,0);
					obj["Yellow-Indicator"].setColor(0.7333,0.3803,0);
					obj["Press-Yellow"].setColor(0.7333,0.3803,0);
					obj["Yellow-label"].setColor(0.7333,0.3803,0);
				}
			}),
			props.UpdateManager.FromHashList(["green", "dcEssShed"], 25, func(val) {
				if (val.dcEssShed) {
					if (val.green >= 100) {
						obj["Press-Green"].setText(sprintf("%s", math.round(val.green, 50)));
					} else {
						obj["Press-Green"].setText(sprintf("%s", 0));
					}
					
					if (val.green > 1450) {
						obj["Green-Line"].setColor(0.0509,0.7529,0.2941);
						obj["Green-Line"].setColorFill(0.0509,0.7529,0.2941);
						obj["Green-Line-Top"].setColorFill(0.0509,0.7529,0.2941);
						obj["Green-Line-Middle"].setColorFill(0.0509,0.7529,0.2941);
						obj["Green-Line-Bottom"].setColorFill(0.0509,0.7529,0.2941);
						obj["Green-Indicator"].setColor(0.0509,0.7529,0.2941);
						obj["Press-Green"].setColor(0.0509,0.7529,0.2941);
						obj["Green-label"].setColor(0.8078,0.8039,0.8078);
					} else {
						obj["Green-Line"].setColor(0.7333,0.3803,0);
						obj["Green-Line"].setColorFill(0.7333,0.3803,0);
						obj["Green-Line-Top"].setColorFill(0.7333,0.3803,0);
						obj["Green-Line-Middle"].setColorFill(0.7333,0.3803,0);
						obj["Green-Line-Bottom"].setColorFill(0.7333,0.3803,0);
						obj["Green-Indicator"].setColor(0.7333,0.3803,0);
						obj["Press-Green"].setColor(0.7333,0.3803,0);
						obj["Green-label"].setColor(0.7333,0.3803,0);
					}
				} else {
					obj["Press-Green"].setText(sprintf("%s", "XX"));
					obj["Green-Line"].setColor(0.7333,0.3803,0);
					obj["Green-Line"].setColorFill(0.7333,0.3803,0);
					obj["Green-Line-Top"].setColorFill(0.7333,0.3803,0);
					obj["Green-Line-Middle"].setColorFill(0.7333,0.3803,0);
					obj["Green-Line-Bottom"].setColorFill(0.7333,0.3803,0);
					obj["Green-Indicator"].setColor(0.7333,0.3803,0);
					obj["Press-Green"].setColor(0.7333,0.3803,0);
					obj["Green-label"].setColor(0.7333,0.3803,0);
				}
			}),
			props.UpdateManager.FromHashValue("N2_actual_1", 0.5, func(val) {
				if (val >= 59) {
					obj["Pump-Green-label"].setColor(0.8078,0.8039,0.8078);
				} else {
					obj["Pump-Green-label"].setColor(0.7333,0.3803,0);
				}
			}),
			props.UpdateManager.FromHashValue("N2_actual_2", 0.5, func(val) {
				if (val >= 59) {
					obj["Pump-Yellow-label"].setColor(0.8078,0.8039,0.8078);
				} else {
					obj["Pump-Yellow-label"].setColor(0.7333,0.3803,0);
				}
			}),
			props.UpdateManager.FromHashValue("hydBlueResvLoPrs", nil, func(val) {
				if (val) {
					obj["LO-AIR-PRESS-Blue"].show();
				} else {
					obj["LO-AIR-PRESS-Blue"].hide();
				}
			}),
			props.UpdateManager.FromHashValue("hydGreenResvLoPrs", nil, func(val) {
				if (val) {
					obj["LO-AIR-PRESS-Green"].show();
				} else {
					obj["LO-AIR-PRESS-Green"].hide();
				}
			}),
			props.UpdateManager.FromHashValue("hydYellowResvLoPrs", nil, func(val) {
				if (val) {
					obj["LO-AIR-PRESS-Yellow"].show();
				} else {
					obj["LO-AIR-PRESS-Yellow"].hide();
				}
			}),
			props.UpdateManager.FromHashValue("hydYellowElecPumpOvht", nil, func(val) {
				if (val) {
					obj["ELEC-OVHT-Yellow"].show();
				} else {
					obj["ELEC-OVHT-Yellow"].hide();
				}
			}),
			props.UpdateManager.FromHashValue("hydBlueElecPumpOvht", nil, func(val) {
				if (val) {
					obj["ELEC-OVHT-Blue"].show();
				} else {
					obj["ELEC-OVHT-Blue"].hide();
				}
			}),
			props.UpdateManager.FromHashValue("hydBlueResvOvht", nil, func(val) {
				if (val) {
					obj["OVHT-Blue"].show();
				} else {
					obj["OVHT-Blue"].hide();
				}
			}),
			props.UpdateManager.FromHashValue("hydGreenResvOvht", nil, func(val) {
				if (val) {
					obj["OVHT-Green"].show();
				} else {
					obj["OVHT-Green"].hide();
				}
			}),
			props.UpdateManager.FromHashValue("hydYellowResvOvht", nil, func(val) {
				if (val) {
					obj["OVHT-Yellow"].show();
				} else {
					obj["OVHT-Yellow"].hide();
				}
			}),
			props.UpdateManager.FromHashValue("hydRATPosition", nil, func(val) {
				if (val) {
					obj["RAT-stowed"].hide();
					obj["RAT-not-stowed"].show();
				} else {
					obj["RAT-stowed"].show();
					obj["RAT-not-stowed"].hide();
				}
			}),
			props.UpdateManager.FromHashValue("hydGreenFireValve", nil, func(val) {
				if (val != 0) {
					obj["Fire-Valve-Green"].setColor(0.7333,0.3803,0);
					obj["Fire-Valve-Green-Cross"].setColorFill(0.7333,0.3803,0);
					obj["Fire-Valve-Green"].setRotation(90 * D2R);
				} else {
					obj["Fire-Valve-Green"].setColor(0.0509,0.7529,0.2941);
					obj["Fire-Valve-Green-Cross"].setColorFill(0.0509,0.7529,0.2941);
					obj["Fire-Valve-Green"].setRotation(0);
				}
			}),
			props.UpdateManager.FromHashValue("hydYellowFireValve", nil, func(val) {
				if (val != 0) {
					obj["Fire-Valve-Yellow"].setColor(0.7333,0.3803,0);
					obj["Fire-Valve-Yellow-Cross"].setColorFill(0.7333,0.3803,0);
					obj["Fire-Valve-Yellow"].setRotation(90 * D2R);
				} else {
					obj["Fire-Valve-Yellow"].setColor(0.0509,0.7529,0.2941);
					obj["Fire-Valve-Yellow-Cross"].setColorFill(0.0509,0.7529,0.2941);
					obj["Fire-Valve-Yellow"].setRotation(0);
				}
			}),
			props.UpdateManager.FromHashList(["elecAC1","dcEss"], 1, func(val) {
				if (val.elecAC1 >= 110 and val.dcEss >= 25) {
					obj["ELEC-Blue-label"].setColor(0.8078,0.8039,0.8078);
				} else {
					obj["ELEC-Blue-label"].setColor(0.7333,0.3803,0);
				}
			}),
			props.UpdateManager.FromHashList(["elecAC2","dc2"], 1, func(val) {
				if (val.elecAC2 >= 110 and val.dc2 >= 25) {
					obj["ELEC-Yellow-label"].setColor(0.8078,0.8039,0.8078);
				} else {
					obj["ELEC-Yellow-label"].setColor(0.7333,0.3803,0);
				}
			}),
			props.UpdateManager.FromHashList(["yellow","hydYellowElecPumpSwitch"], nil, func(val) {
				if (!val.hydYellowElecPumpSwitch) {
					obj["ELEC-Yellow-on"].hide();
					obj["ELEC-Yellow-off"].show();
				} else {
					obj["ELEC-Yellow-on"].show();
					obj["ELEC-Yellow-off"].hide();
					if (val.yellow > 1450) {
						obj["ELEC-Yellow-on"].setColor(0.0509,0.7529,0.2941);
					} else {
						obj["ELEC-Yellow-on"].setColor(0.7333,0.3803,0);
					}
				}
			}),
			props.UpdateManager.FromHashList(["blue","hydBlueElecPumpSwitch"], nil, func(val) {
				if (val.hydBlueElecPumpSwitch) {
					obj["Pump-Blue-off"].hide();
					if (val.blue > 1450) {
						obj["Pump-Blue-on"].show();
						obj["Pump-LOPR-Blue"].hide();
						obj["Pump-Blue"].setColorFill(0.0509,0.7529,0.2941);
						obj["Pump-Blue"].setColor(0.0509,0.7529,0.2941);
					} else {
						obj["Pump-Blue-on"].hide();
						obj["Pump-LOPR-Blue"].show();
						obj["Pump-Blue"].setColorFill(0.7333,0.3803,0);
						obj["Pump-Blue"].setColor(0.7333,0.3803,0);
					}
				} else {
					obj["Pump-Blue-off"].show();
					obj["Pump-Blue-on"].hide();
					obj["Pump-LOPR-Blue"].hide();
					obj["Pump-Blue"].setColorFill(0.7333,0.3803,0);
					obj["Pump-Blue"].setColor(0.7333,0.3803,0);
				}
			}),
			props.UpdateManager.FromHashList(["yellow","hydYellowEDPPumpSwitch"], nil, func(val) {
				if (val.hydYellowEDPPumpSwitch) {
					obj["Pump-Yellow-off"].hide();
					if (val.yellow > 1450) {
						obj["Pump-Yellow-on"].show();
						obj["Pump-LOPR-Yellow"].hide();
						obj["Pump-Yellow"].setColorFill(0.0509,0.7529,0.2941);
						obj["Pump-Yellow"].setColor(0.0509,0.7529,0.2941);
					} else {
						obj["Pump-Yellow-on"].hide();
						obj["Pump-LOPR-Yellow"].show();
						obj["Pump-Yellow"].setColorFill(0.7333,0.3803,0);
						obj["Pump-Yellow"].setColor(0.7333,0.3803,0);
					}
				} else {
					obj["Pump-Yellow-off"].show();
					obj["Pump-Yellow-on"].hide();
					obj["Pump-LOPR-Yellow"].hide();
					obj["Pump-Yellow"].setColorFill(0.7333,0.3803,0);
					obj["Pump-Yellow"].setColor(0.7333,0.3803,0);
				}
			}),
			props.UpdateManager.FromHashList(["green","hydGreenEDPPumpSwitch"], nil, func(val) {
				if (val.hydGreenEDPPumpSwitch) {
					obj["Pump-Green-off"].hide();
					if (val.green > 1450) {
						obj["Pump-Green-on"].show();
						obj["Pump-LOPR-Green"].hide();
						obj["Pump-Green"].setColor(0.0509,0.7529,0.2941);
						obj["Pump-Green"].setColorFill(0.0509,0.7529,0.2941);
					} else {
						obj["Pump-Green-on"].hide();
						obj["Pump-LOPR-Green"].show();
						obj["Pump-Green"].setColor(0.7333,0.3803,0);
						obj["Pump-Green"].setColorFill(0.7333,0.3803,0);
					}
				} else {
					obj["Pump-Green-off"].show();
					obj["Pump-Green-on"].hide();
					obj["Pump-LOPR-Green"].hide();
					obj["Pump-Green"].setColor(0.7333,0.3803,0);
				}
			}),
			props.UpdateManager.FromHashList(["hydPTUSwitch","hydPTUDiff","hydPTUActive","hydPTUFault"], nil, func(val) {
				if (val.hydPTUSwitch and !val.hydPTUFault) {
					obj["PTU-connection"].setColor(0.0509,0.7529,0.2941);

					if (val.hydPTUActive) {
						if (val.hydPTUDiff < 0) {
							obj["PTU-Supply-Line"].show();
							obj["PTU-supply-yellow"].show();
							obj["PTU-supply-green"].hide();
							obj["PTU-Auto-or-off"].hide();
						} else {
							obj["PTU-Supply-Line"].show();
							obj["PTU-supply-yellow"].hide();
							obj["PTU-supply-green"].show();
							obj["PTU-Auto-or-off"].hide();
						}
					} else {
						obj["PTU-Auto-or-off"].setColor(0.0509,0.7529,0.2941);
						obj["PTU-Supply-Line"].hide();
						obj["PTU-supply-yellow"].hide();
						obj["PTU-supply-green"].hide();
						obj["PTU-Auto-or-off"].show();
					}
				} else {
					obj["PTU-connection"].setColor(0.7333,0.3803,0);
					obj["PTU-Auto-or-off"].setColor(0.7333,0.3803,0);
					obj["PTU-Supply-Line"].hide();
					obj["PTU-supply-yellow"].hide();
					obj["PTU-supply-green"].hide();
					obj["PTU-Auto-or-off"].show();
				}
			}),
			props.UpdateManager.FromHashValue("hydBlueQTY", 0.05, func(val) {
				obj["Quantity-Indicator-Blue"].setTranslation(0,((val / 8) * -140) + 140);
				if (val >= 2.4) {
					obj["Quantity-Indicator-Blue"].setColor(0.0509,0.7529,0.2941);
					obj["path5561-4"].setColor(0.0509,0.7529,0.2941);
				} else {
					obj["Quantity-Indicator-Blue"].setColor(0.7333,0.3803,0);
					obj["path5561-4"].setColor(0.7333,0.3803,0);
				}
			}),
			props.UpdateManager.FromHashValue("hydGreenQTY", 0.05, func(val) {
				obj["Quantity-Indicator-Green"].setTranslation(0,((val / 18) * -140) + 140);
				if (val >= 3.5) {
					obj["Quantity-Indicator-Green"].setColor(0.0509,0.7529,0.2941);
					obj["path5561-5"].setColor(0.0509,0.7529,0.2941);
				} else {
					obj["Quantity-Indicator-Green"].setColor(0.7333,0.3803,0);
					obj["path5561-5"].setColor(0.7333,0.3803,0);
				}
			}),
			props.UpdateManager.FromHashValue("hydYellowQTY", 0.05, func(val) {
				obj["Quantity-Indicator-Yellow"].setTranslation(0,((val / 15) * -140) + 140);
				if (val >= 3.5) {
					obj["Quantity-Indicator-Yellow"].setColor(0.0509,0.7529,0.2941);
					obj["path5561"].setColor(0.0509,0.7529,0.2941);
				} else {
					obj["Quantity-Indicator-Yellow"].setColor(0.7333,0.3803,0);
					obj["path5561"].setColor(0.7333,0.3803,0);
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
		return ["TAT","SAT","GW","UTCh","UTCm","GLoad","GW-weight-unit","Green-Indicator","HYD-Quantity-Group-Blue","HYD-Quantity-Group-Yellow","HYD-Quantity-Group-Green","Blue-Indicator","Yellow-Indicator","Press-Green","Press-Blue","Press-Yellow","Green-Line","Blue-Line","Yellow-Line","Green-Line-Top","Blue-Line-Top","Yellow-Line-Middle","Green-Line-Middle","Yellow-Line-Bottom","Green-Line-Bottom","Blue-Line-Bottom","Yellow-Line-Top","PTU-Supply-Line","PTU-supply-yellow","PTU-supply-green","PTU-connection",
		"PTU-Auto-or-off","RAT-label","RAT-stowed","RAT-not-stowed","ELEC-Yellow-off","ELEC-Yellow-on","ELEC-Yellow-label","ELEC-OVTH-Yellow","ELEC-Blue-label","ELEC-OVHT-Blue","ELEC-OVHT-Yellow","Pump-Green-label","Pump-Yellow-label","Pump-Green",
		"Pump-LOPR-Green","Pump-Green-off","Pump-Green-on","Pump-Yellow","Pump-LOPR-Yellow","Pump-Yellow-off","Pump-Yellow-on","Pump-Blue","Pump-LOPR-Blue","Pump-Blue-off","Pump-Blue-on","Fire-Valve-Green","Fire-Valve-Yellow","LO-AIR-PRESS-Green",
		"LO-AIR-PRESS-Yellow","LO-AIR-PRESS-Blue","OVHT-Green","OVHT-Blue","OVHT-Yellow","Quantity-Indicator-Green","Quantity-Indicator-Blue","Quantity-Indicator-Yellow","Green-label","Blue-label","Yellow-label","Fire-Valve-Yellow-Cross","Fire-Valve-Green-Cross","path5561","path5561-4","path5561-5"];
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
	hydBlueResvOvht: "/systems/hydraulic/relays/blue-reservoir-overheat",
	hydGreenResvOvht: "/systems/hydraulic/relays/green-reservoir-overheat",
	hydYellowResvOvht: "/systems/hydraulic/relays/yellow-reservoir-overheat",
	hydBlueResvLoPrs: "/systems/failures/hydraulic/blue-reservoir-air-press-lo",
	hydGreenResvLoPrs: "/systems/failures/hydraulic/green-reservoir-air-press-lo",
	hydYellowResvLoPrs: "/systems/failures/hydraulic/yellow-reservoir-air-press-lo",
	hydBlueElecPumpOvht: "/systems/failures/hydraulic/blue-elec-ovht",
	hydYellowElecPumpOvht: "/systems/failures/hydraulic/yellow-elec-ovht",
	hydRATPosition: "/systems/hydraulic/sources/rat/position",
	hydGreenFireValve: "/systems/hydraulic/sources/green-edp/fire-valve",
	hydYellowFireValve: "/systems/hydraulic/sources/yellow-edp/fire-valve",
	hydBlueElecPumpSwitch: "/controls/hydraulic/switches/blue-elec",
	hydGreenEDPPumpSwitch: "/controls/hydraulic/switches/green-edp",
	hydYellowElecPumpSwitch: "/controls/hydraulic/switches/yellow-elec",
	hydYellowEDPPumpSwitch: "/controls/hydraulic/switches/yellow-edp",
	hydPTUSwitch: "/controls/hydraulic/switches/ptu",
	hydPTUFault: "/systems/failures/hydraulic/ptu",
	hydPTUActive: "/systems/hydraulic/sources/ptu/ptu-loop-sound-cmd",
	hydPTUDiff: "/systems/hydraulic/yellow-psi-diff",
	hydBlueQTY: "/systems/hydraulic/blue-qty",
	hydGreenQTY: "/systems/hydraulic/green-qty",
	hydYellowQTY: "/systems/hydraulic/yellow-qty",
};

foreach (var name; keys(input)) {
	emesary.GlobalTransmitter.NotifyAll(notifications.FrameNotificationAddProperty.new("A320 System Display", name, input[name]));
}