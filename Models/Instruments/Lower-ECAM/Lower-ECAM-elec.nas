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
			props.UpdateManager.FromHashValue("apuLoad", 0.1, func(val) {
				obj["APUGenLoad"].setText(sprintf("%s", math.round(val)));
				
				if (val < 110) {
					obj["APUGenHz"].setColor(0.0509,0.7529,0.2941);
				} else {
					obj["APUGenHz"].setColor(0.7333,0.3803,0);
				}
			}),
			props.UpdateManager.FromHashValue("apuHertz", 0.5, func(val) {
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
			props.UpdateManager.FromHashList(["apuMaster","apuVolt","apuLoad","apuHertz","apuGLC"], nil, func(val) {
				if (val.apuMaster == 0) {
					obj["APUGentext"].setColor(0.8078,0.8039,0.8078);
				} else {
					if (val.apuGLC == 0) {
						obj["APUGentext"].setColor(0.7333,0.3803,0);
					} else if (val.apuVolt > 120 or val.apuVolt < 110 or val.apuHertz > 410 or val.apuHertz < 390 or val.apuLoad >= 100) {
						obj["APUGentext"].setColor(0.7333,0.3803,0);
					} else {
						obj["APUGentext"].setColor(0.8078,0.8039,0.8078);
					}
				}
			}),
			props.UpdateManager.FromHashList(["apuMaster","apuGLC"], nil, func(val) {
				if (val.apuMaster == 0) {
					obj["APU-content"].hide();
					obj["APUGEN-off"].hide();
					obj["APU-border"].hide();
				} else {
					obj["APU-border"].show();
					if (val.apuGLC == 0) {
						obj["APU-content"].hide();
						obj["APUGEN-off"].show();
					} else {
						obj["APU-content"].show();
						obj["APUGEN-off"].hide();
					}
				}
			}),
			props.UpdateManager.FromHashValue("elecIDG1Disc", nil, func(val) {
				if (!val) {
					obj["IDG1-DISC"].show();
					obj["ELEC-IDG-1-label"].setColor(0.7333,0.3803,0);
				} else {
					obj["IDG1-DISC"].hide();
					obj["ELEC-IDG-1-label"].setColor(0.8078,0.8039,0.8078);
				}
			}),
			props.UpdateManager.FromHashValue("elecIDG2Disc", nil, func(val) {
				if (!val) {
					obj["IDG2-DISC"].show();
					obj["ELEC-IDG-2-label"].setColor(0.7333,0.3803,0);
				} else {
					obj["IDG2-DISC"].hide();
					obj["ELEC-IDG-2-label"].setColor(0.8078,0.8039,0.8078);
				}
			}),
			props.UpdateManager.FromHashValue("engine1Running", nil, func(val) {
				if (val == 0) {
					obj["ELEC-IDG-1-num-label"].setColor(0.7333,0.3803,0);
				} else {
					obj["ELEC-IDG-1-num-label"].setColor(0.8078,0.8039,0.8078);
				}
			}),
			props.UpdateManager.FromHashValue("engine2Running", nil, func(val) {
				if (val == 0) {
					obj["ELEC-IDG-2-num-label"].setColor(0.7333,0.3803,0);
				} else {
					obj["ELEC-IDG-2-num-label"].setColor(0.8078,0.8039,0.8078);
				}
			}),
			props.UpdateManager.FromHashValue("dc1", 0.5, func(val) {
				if (val > 25) {
					obj["ELEC-DC1-label"].setColor(0.0509,0.7529,0.2941);
				} else {
					obj["ELEC-DC1-label"].setColor(0.7333,0.3803,0);
				}
			}),
			props.UpdateManager.FromHashValue("dc2", 0.5, func(val) {
				if (val > 25) {
					obj["ELEC-DC2-label"].setColor(0.0509,0.7529,0.2941);
				} else {
					obj["ELEC-DC2-label"].setColor(0.7333,0.3803,0);
				}
			}),
			props.UpdateManager.FromHashValue("dcEss", 0.5, func(val) {
				if (val > 25) {
					obj["ELEC-DCESS-label"].setColor(0.0509,0.7529,0.2941);
				} else {
					obj["ELEC-DCESS-label"].setColor(0.7333,0.3803,0);
				}
			}),
			props.UpdateManager.FromHashValue("ac1", 0.5, func(val) {
				if (val >= 110) {
					obj["ELEC-AC1-label"].setColor(0.0509,0.7529,0.2941);
					obj["AC1-in"].show();
				} else {
					obj["ELEC-AC1-label"].setColor(0.7333,0.3803,0);
					obj["AC1-in"].hide();
				}
			}),
			props.UpdateManager.FromHashValue("ac2", 0.5, func(val) {
				if (val >= 110) {
					obj["ELEC-AC2-label"].setColor(0.0509,0.7529,0.2941);
					obj["AC2-in"].show();
				} else {
					obj["ELEC-AC2-label"].setColor(0.7333,0.3803,0);
					obj["AC2-in"].hide();
				}
			}),
			props.UpdateManager.FromHashValue("acEss", 0.5, func(val) {
				if (val >= 110) {
					obj["ELEC-ACESS-label"].setColor(0.0509,0.7529,0.2941);
				} else {
					obj["ELEC-ACESS-label"].setColor(0.7333,0.3803,0);
				}
			}),
			props.UpdateManager.FromHashValue("acEssShed", 0.5, func(val) {
				if (val >= 110) {
					obj["ACESS-SHED"].hide();
				} else {
					obj["ACESS-SHED"].show();
				}
			}),
			props.UpdateManager.FromHashValue("ElecGalleyShed", nil, func(val) {
				if (val) {
					obj["GalleyShed"].show();
				} else {
					obj["GalleyShed"].hide();
				}
			}),
			props.UpdateManager.FromHashList(["elecBat1Switch","elecBat2Switch","dcBat"], nil, func(val) {
				if (val.elecBat1Switch or val.elecBat2Switch) {
					obj["ELEC-DCBAT-label"].setText("DC BAT");
					if (val.dcBat > 25) {
						obj["ELEC-DCBAT-label"].setColor(0.0509,0.7529,0.2941);
					} else {
						obj["ELEC-DCBAT-label"].setColor(0.7333,0.3803,0);
					}
				} else {
					obj["ELEC-DCBAT-label"].setText("XX"); # BCL not powered hence no voltage info supplied from BCL
					obj["ELEC-DCBAT-label"].setColor(0.7333,0.3803,0);
				}
			}),
			props.UpdateManager.FromHashList(["elecBat1Switch","elecBat1Volt","elecBat1Amp","elecBat1Direction","elecBat1Fault"], nil, func(val) {
				if (val.elecBat1Switch == 0) {
					obj["BAT1-OFF"].show();
					obj["BAT1-content"].hide();
					obj["BAT1-discharge"].hide();
					obj["BAT1-charge"].hide();
				} else {
					obj["BAT1-OFF"].hide();
					obj["BAT1-content"].show();
					obj["Bat1Ampere"].setText(sprintf("%s", val.elecBat1Amp));
					obj["Bat1Volt"].setText(sprintf("%s", val.elecBat1Volt));

					if (val.elecBat1Volt >= 24.95 and val.elecBat1Volt <= 31.05) {
						obj["Bat1Volt"].setColor(0.0509,0.7529,0.2941);
					} else {
						obj["Bat1Volt"].setColor(0.7333,0.3803,0);
					}

					if (val.elecBat1Amp > 5) {
						obj["Bat1Ampere"].setColor(0.7333,0.3803,0);
					} else {
						obj["Bat1Ampere"].setColor(0.0509,0.7529,0.2941);
					}

					if (val.elecBat1Direction == 0) {
						obj["BAT1-discharge"].hide();
						obj["BAT1-charge"].hide();
					} else {
						if (val.elecBat1Direction == -1) {
							obj["BAT1-charge"].show();
							obj["BAT1-discharge"].hide();
						} else {
							obj["BAT1-discharge"].show();
							obj["BAT1-charge"].hide();
						}
					}
				}
				
				if (val.elecBat1Fault or val.elecBat1Volt < 25 or val.elecBat1Volt > 31 or val.elecBat1Amp > 5) {
					obj["BAT1-label"].setColor(0.7333,0.3803,0);
				} else {
					obj["BAT1-label"].setColor(0.8078,0.8039,0.8078);
				}
			}),
			props.UpdateManager.FromHashList(["elecBat2Switch","elecBat2Volt","elecBat2Amp","elecBat2Direction","elecBat2Fault"], nil, func(val) {
				if (val.elecBat2Switch == 0) {
					obj["BAT2-OFF"].show();
					obj["BAT2-content"].hide();
					obj["BAT2-discharge"].hide();
					obj["BAT2-charge"].hide();
				} else {
					obj["BAT2-OFF"].hide();
					obj["BAT2-content"].show();
					obj["Bat2Ampere"].setText(sprintf("%s", val.elecBat2Amp));
					obj["Bat2Volt"].setText(sprintf("%s", val.elecBat2Volt));

					if (val.elecBat2Volt >= 24.95 and val.elecBat2Volt <= 31.05) {
						obj["Bat2Volt"].setColor(0.0509,0.7529,0.2941);
					} else {
						obj["Bat2Volt"].setColor(0.7333,0.3803,0);
					}

					if (val.elecBat2Amp > 5) {
						obj["Bat2Ampere"].setColor(0.7333,0.3803,0);
					} else {
						obj["Bat2Ampere"].setColor(0.0509,0.7529,0.2941);
					}

					if (val.elecBat2Direction == 0) {
						obj["BAT2-discharge"].hide();
						obj["BAT2-charge"].hide();
					} else {
						if (val.elecBat2Direction == -1) {
							obj["BAT2-charge"].show();
							obj["BAT2-discharge"].hide();
						} else {
							obj["BAT2-discharge"].show();
							obj["BAT2-charge"].hide();
						}
					}
				}
				
				if (val.elecBat2Fault or val.elecBat2Volt < 25 or val.elecBat2Volt > 31 or val.elecBat2Amp > 5) {
					obj["BAT2-label"].setColor(0.7333,0.3803,0);
				} else {
					obj["BAT2-label"].setColor(0.8078,0.8039,0.8078);
				}
			}),
			props.UpdateManager.FromHashList(["elecTR1Amp","elecTR1Volt"], nil, func(val) {
				obj["TR1Volt"].setText(sprintf("%s", math.round(val.elecTR1Volt)));
				obj["TR1Ampere"].setText(sprintf("%s", math.round(val.elecTR1Amp)));

				if (val.elecTR1Volt < 25 or val.elecTR1Volt > 31 or val.elecTR1Amp < 5) {
					obj["TR1-label"].setColor(0.7333,0.3803,0);
				} else {
					obj["TR1-label"].setColor(0.8078,0.8039,0.8078);
				}

				if (val.elecTR1Volt < 25 or val.elecTR1Volt > 31) {
					obj["TR1Volt"].setColor(0.7333,0.3803,0);
				} else {
					obj["TR1Volt"].setColor(0.0509,0.7529,0.2941);
				}

				if (val.elecTR1Amp < 5) {
					obj["TR1Ampere"].setColor(0.7333,0.3803,0);
				} else {
					obj["TR1Ampere"].setColor(0.0509,0.7529,0.2941);
				}
			}),
			props.UpdateManager.FromHashList(["elecTR2Amp","elecTR2Volt"], nil, func(val) {
				obj["TR2Volt"].setText(sprintf("%s", math.round(val.elecTR2Volt)));
				obj["TR2Ampere"].setText(sprintf("%s", math.round(val.elecTR2Amp)));

				if (val.elecTR2Volt < 25 or val.elecTR2Volt > 31 or val.elecTR2Amp < 5) {
					obj["TR2-label"].setColor(0.7333,0.3803,0);
				} else {
					obj["TR2-label"].setColor(0.8078,0.8039,0.8078);
				}

				if (val.elecTR2Volt < 25 or val.elecTR2Volt > 31) {
					obj["TR2Volt"].setColor(0.7333,0.3803,0);
				} else {
					obj["TR2Volt"].setColor(0.0509,0.7529,0.2941);
				}

				if (val.elecTR2Amp < 5) {
					obj["TR2Ampere"].setColor(0.7333,0.3803,0);
				} else {
					obj["TR2Ampere"].setColor(0.0509,0.7529,0.2941);
				}
			}),
			props.UpdateManager.FromHashList(["elecExtHertz","elecExtVolt","elecGroundCart"], nil, func(val) {
				if (val.elecGroundCart == 0) {
					obj["EXTPWR-group"].hide();
				} else {
					obj["EXTPWR-group"].show();
					obj["ExtVolt"].setText(sprintf("%s", math.round(val.elecExtVolt)));
					obj["ExtHz"].setText(sprintf("%s", math.round(val.elecExtHertz)));

					if (val.elecExtHertz > 410 or val.elecExtHertz < 390 or val.elecExtVolt > 120 or val.elecExtVolt < 110) {
						obj["EXTPWR-label"].setColor(0.7333,0.3803,0);
					} else {
						obj["EXTPWR-label"].setColor(0.0509,0.7529,0.2941);
					}

					if (val.elecExtHertz > 410 or val.elecExtHertz < 390) {
						obj["ExtHz"].setColor(0.7333,0.3803,0);
					} else {
						obj["ExtHz"].setColor(0.0509,0.7529,0.2941);
					}

					if (val.elecExtVolt > 120 or val.elecExtVolt < 110) {
						obj["ExtVolt"].setColor(0.7333,0.3803,0);
					} else {
						obj["ExtVolt"].setColor(0.0509,0.7529,0.2941);
					}
				}
			}),
			props.UpdateManager.FromHashValue("elecDCTie1", nil, func(val) {
				if (val) {
					obj["ELEC-Line-DC1-DCESS_DCBAT"].show();
				} else {
					obj["ELEC-Line-DC1-DCESS_DCBAT"].hide();
				}
			}),
			props.UpdateManager.FromHashValue("elecDCTie2", nil, func(val) {
				if (val) {
					obj["ELEC-Line-DC2-DCESS_DCBAT"].show();
					obj["ELEC-Line-DC2-DCBAT"].show();
				} else {
					obj["ELEC-Line-DC2-DCESS_DCBAT"].hide();
					obj["ELEC-Line-DC2-DCBAT"].show();
				}
			}),
			props.UpdateManager.FromHashList(["elecDcEssFeedBat","elecDCTie1"], nil, func(val) {
				if (val.elecDcEssFeedBat or val.elecDCTie1) {
					obj["ELEC-Line-DC1-DCBAT"].show();
				} else {
					obj["ELEC-Line-DC1-DCBAT"].hide();
				}
			}),
			props.UpdateManager.FromHashValue("elecDcEssFeedBat", nil, func(val) {
				if (val) {
					obj["ELEC-Line-DC1-DCESS"].show();
				} else {
					obj["ELEC-Line-DC1-DCESS"].hide();
				}
			}),
			props.UpdateManager.FromHashValue("elecDcEssFeedTr", nil, func(val) {
				if (val) {
					obj["ELEC-Line-ESSTR-DCESS"].show();
				} else {
					obj["ELEC-Line-ESSTR-DCESS"].hide();
				}
			}),
			props.UpdateManager.FromHashValue("elecAcEssEmerGenFeed", nil, func(val) {
				if (val) {
					obj["EMERGEN-out"].show();
					obj["ELEC-Line-Emergen-ESSTR"].show();
				} else {
					obj["EMERGEN-out"].hide();
					obj["ELEC-Line-Emergen-ESSTR"].hide();
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
	elecBat1Amp: "/systems/electrical/sources/bat-1/amps",
	elecBat2Amp: "/systems/electrical/sources/bat-2/amps",
	elecBat1Direction: "/systems/electrical/sources/bat-1/direction",
	elecBat2Direction: "/systems/electrical/sources/bat-2/direction",
	elecBat1Fault: "/systems/electrical/light/bat-1-fault",
	elecBat2Fault: "/systems/electrical/light/bat-2-fault",
	elecBat1Volt: "/systems/electrical/sources/bat-1/volt",
	elecBat2Volt: "/systems/electrical/sources/bat-2/volt",
	elecBat1Switch: "/controls/electrical/switches/bat-1",
	elecBat2Switch: "/controls/electrical/switches/bat-2",
	elecTR1Amp: "/systems/electrical/relay/tr-contactor-1/output-amp",
	elecTR2Amp: "/systems/electrical/relay/tr-contactor-2/output-amp",
	elecTR1Volt: "/systems/electrical/relay/tr-contactor-1/output",
	elecTR2Volt: "/systems/electrical/relay/tr-contactor-2/output",
	elecIDG1Disc: "/controls/electrical/switches/idg-1-disc",
	elecIDG2Disc: "/controls/electrical/switches/idg-2-disc",
	elecGroundCart: "/controls/electrical/ground-cart",
	elecExtHertz: "/systems/electrical/sources/ext/output-hertz",
	elecExtVolt: "/systems/electrical/sources/ext/output-volt",
	elecDCTie1: "/systems/electrical/relay/dc-bus-tie-dc-1/contact-pos",
	elecDCTie2: "/systems/electrical/relay/dc-bus-tie-dc-2/contact-pos",
	elecDcEssFeedBat: "/systems/electrical/relay/dc-ess-feed-bat/contact-pos",
	elecDcEssFeedTr: "/systems/electrical/relay/dc-ess-feed-tr/contact-pos",
	elecAcEssEmerGenFeed: "/systems/electrical/relay/ac-ess-feed-emer-gen/contact-pos",
	ElecGalleyShed: "/systems/electrical/some-electric-thingie/galley-shed",
};

foreach (var name; keys(input)) {
	emesary.GlobalTransmitter.NotifyAll(notifications.FrameNotificationAddProperty.new("A320 System Display", name, input[name]));
}