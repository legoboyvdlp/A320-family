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
			props.UpdateManager.FromHashList(["apuMaster","apuGenPB"], nil, func(val) {
				if (val.apuMaster == 0) {
					obj["APU-content"].hide();
					obj["APUGEN-off"].hide();
					obj["APU-border"].hide();
				} else {
					obj["APU-border"].show();
					if (val.apuGenPB == 0) {
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
					obj["GEN1-num-label"].setColor(0.7333,0.3803,0);
				} else {
					obj["ELEC-IDG-1-num-label"].setColor(0.8078,0.8039,0.8078);
					obj["GEN1-num-label"].setColor(0.8078,0.8039,0.8078);
				}
			}),
			props.UpdateManager.FromHashValue("engine2Running", nil, func(val) {
				if (val == 0) {
					obj["ELEC-IDG-2-num-label"].setColor(0.7333,0.3803,0);
					obj["GEN2-num-label"].setColor(0.7333,0.3803,0);
				} else {
					obj["ELEC-IDG-2-num-label"].setColor(0.8078,0.8039,0.8078);
					obj["GEN2-num-label"].setColor(0.8078,0.8039,0.8078);
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
			props.UpdateManager.FromHashValue("elecAC1", 0.5, func(val) {
				if (val >= 110) {
					obj["ELEC-AC1-label"].setColor(0.0509,0.7529,0.2941);
					obj["ELEC-Line-AC1-TR1"].setColor(0.0509,0.7529,0.2941);
				} else {
					obj["ELEC-AC1-label"].setColor(0.7333,0.3803,0);
					obj["ELEC-Line-AC1-TR1"].setColor(0.7333,0.3803,0);
				}
			}),
			props.UpdateManager.FromHashValue("elecAC2", 0.5, func(val) {
				if (val >= 110) {
					obj["ELEC-AC2-label"].setColor(0.0509,0.7529,0.2941);
					obj["ELEC-Line-AC2-TR2"].setColor(0.0509,0.7529,0.2941);
				} else {
					obj["ELEC-AC2-label"].setColor(0.7333,0.3803,0);
					obj["ELEC-Line-AC2-TR2"].setColor(0.7333,0.3803,0);
				}
			}),
			props.UpdateManager.FromHashList(["elecGen1GLC","elecAcTie1"], nil, func(val) {
				if (val.elecGen1GLC or val.elecAcTie1) {
					obj["AC1-in"].show();
				} else {
					obj["AC1-in"].hide();
				}
			}),
			props.UpdateManager.FromHashList(["elecGen2GLC","elecAcTie2"], nil, func(val) {
				if (val.elecGen2GLC or val.elecAcTie2) {
					obj["AC2-in"].show();
				} else {
					obj["AC2-in"].hide();
				}
			}),
			props.UpdateManager.FromHashValue("elecACEss", 0.5, func(val) {
				if (val >= 110) {
					obj["ELEC-ACESS-label"].setColor(0.0509,0.7529,0.2941);
				} else {
					obj["ELEC-ACESS-label"].setColor(0.7333,0.3803,0);
				}
			}),
			props.UpdateManager.FromHashValue("elecACEssShed", 0.5, func(val) {
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
					obj["Bat1Ampere"].setText(sprintf("%2.0f", val.elecBat1Amp));
					
					obj["Bat1Volt"].setText(sprintf("%2.0f", val.elecBat1Volt));

					if (val.elecBat1Volt >= 24.95 and val.elecBat1Volt <= 31.05) {
						obj["Bat1Volt"].setColor(0.0509,0.7529,0.2941);
					} else {
						obj["Bat1Volt"].setColor(0.7333,0.3803,0);
					}

					if (val.elecBat1Amp > 5 and val.elecBat1Direction == 1) {
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
					obj["Bat2Ampere"].setText(sprintf("%2.0f", val.elecBat2Amp));
					
					obj["Bat2Volt"].setText(sprintf("%2.0f", val.elecBat2Volt));

					if (val.elecBat2Volt >= 24.95 and val.elecBat2Volt <= 31.05) {
						obj["Bat2Volt"].setColor(0.0509,0.7529,0.2941);
					} else {
						obj["Bat2Volt"].setColor(0.7333,0.3803,0);
					}

					if (val.elecBat2Amp > 5 and val.elecBat2Direction == 1) {
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
					obj["ELEC-Line-DC2-DCBAT"].hide();
				}
			}),
			props.UpdateManager.FromHashValue("elecDCTie1", nil, func(val) {
				if (val) {
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
			props.UpdateManager.FromHashValue("elecTrEssContact", nil, func(val) {
				if (val) {
					obj["ELEC-Line-ESSTR-DCESS"].show();
				} else {
					obj["ELEC-Line-ESSTR-DCESS"].hide();
				}
			}),
			props.UpdateManager.FromHashList(["elecEmerGenVoltsRelay","elec15XE1"], nil, func(val) {
				if (val.elecEmerGenVoltsRelay) {
					if (val.elec15XE1) {
						obj["EMERGEN-out"].show();
					} else {
						obj["EMERGEN-out"].hide();
					}
					obj["ELEC-Line-Emergen-ESSTR"].show();
				} else {
					obj["EMERGEN-out"].hide();
					obj["ELEC-Line-Emergen-ESSTR"].hide();
				}
			}),
			props.UpdateManager.FromHashList(["elecTREssAmp","elecTREssVolt","elecTrEssContact"], nil, func(val) {
				if (val.elecTrEssContact) {
					obj["ESSTR-group"].show();
					obj["ESSTR-Volt"].setText(sprintf("%s", math.round(val.elecTREssVolt)));
					obj["ESSTR-Ampere"].setText(sprintf("%s", math.round(val.elecTREssAmp)));
					
					if (val.elecTREssVolt < 25 or val.elecTREssVolt > 31 or val.elecTREssAmp < 5) {
						obj["ESSTR"].setColor(0.7333,0.3803,0);
					} else {
						obj["ESSTR"].setColor(0.8078,0.8039,0.8078);
					}
					
					if (val.elecTREssVolt < 25 or val.elecTREssVolt > 31) {
						obj["ESSTR-Volt"].setColor(0.7333,0.3803,0);
					} else {
						obj["ESSTR-Volt"].setColor(0.0509,0.7529,0.2941);
					}
					
					if (val.elecTREssAmp < 5) {
						obj["ESSTR-Ampere"].setColor(0.7333,0.3803,0);
					} else {
						obj["ESSTR-Ampere"].setColor(0.0509,0.7529,0.2941);
					}
				} else {
					obj["ESSTR-group"].hide();
				}
			}),
			props.UpdateManager.FromHashList(["elecEmerGenHertz","elecEmerGenVolts","elecEmerGenVoltsRelay"], nil, func(val) {
				if (val.elecEmerGenVolts == 0) {
					obj["EMERGEN-group"].hide();
					obj["ELEC-Line-Emergen-ESSTR"].hide();
					obj["ELEC-Line-Emergen-ESSTR-off"].show();
					obj["EMERGEN-Label-off"].show();
				} else {
					obj["EMERGEN-group"].show();
					obj["ELEC-Line-Emergen-ESSTR"].show();
					obj["ELEC-Line-Emergen-ESSTR-off"].hide();
					obj["EMERGEN-Label-off"].hide();
					
					obj["EmergenVolt"].setText(sprintf("%s", math.round(val.elecEmerGenVoltsRelay)));
					obj["EmergenHz"].setText(sprintf("%s", math.round(val.elecEmerGenHertz)));
					
					if (val.elecEmerGenVoltsRelay > 120 or val.elecEmerGenVoltsRelay < 110 or val.elecEmerGenHertz > 410 or val.elecEmerGenHertz < 390) {
						obj["Emergen-Label"].setColor(0.7333,0.3803,0);
					} else {
						obj["Emergen-Label"].setColor(0.8078,0.8039,0.8078);
					}

					if (val.elecEmerGenVoltsRelay > 120 or val.elecEmerGenVoltsRelay < 110) {
						obj["EmergenVolt"].setColor(0.7333,0.3803,0);
					} else {
						obj["EmergenVolt"].setColor(0.0509,0.7529,0.2941);
					}

					if (val.elecEmerGenHertz > 410 or val.elecEmerGenHertz < 390) {
						obj["EmergenHz"].setColor(0.7333,0.3803,0);
					} else {
						obj["EmergenHz"].setColor(0.0509,0.7529,0.2941);
					}
				}
			}),
			props.UpdateManager.FromHashList(["elecGen1Switch","elecGen1Hertz","elecGen1Volt","engine1Running","elecGen1Relay"], nil, func(val) {
				if (val.elecGen1Switch == 0) {
					obj["GEN1-content"].hide();
					obj["GEN1-off"].show();
					if (val.elecGen1Relay) {
						obj["GEN1-label"].setColor(0.7333,0.3803,0);
					} else {
						obj["GEN1-label"].setColor(0.8078,0.8039,0.8078);
					}
				} else {
					obj["GEN1-content"].show();
					obj["GEN1-off"].hide();
					obj["Gen1Volt"].setText(sprintf("%s", math.round(val.elecGen1Volt)));

					if (val.elecGen1Hertz == 0) {
						obj["Gen1Hz"].setText(sprintf("XX"));
					} else {
						obj["Gen1Hz"].setText(sprintf("%s", math.round(val.elecGen1Hertz)));
					}

					if (val.elecGen1Volt > 120 or val.elecGen1Volt < 110 or val.elecGen1Hertz > 410 or val.elecGen1Hertz < 390) {
						obj["GEN1-label"].setColor(0.7333,0.3803,0);
					} else {
						obj["GEN1-label"].setColor(0.8078,0.8039,0.8078);
					}

					if (val.elecGen1Volt > 120 or val.elecGen1Volt < 110) {
						obj["Gen1Volt"].setColor(0.7333,0.3803,0);
					} else {
						obj["Gen1Volt"].setColor(0.0509,0.7529,0.2941);
					}

					if (val.elecGen1Hertz > 410 or val.elecGen1Hertz < 390) {
						obj["Gen1Hz"].setColor(0.7333,0.3803,0);
					} else {
						obj["Gen1Hz"].setColor(0.0509,0.7529,0.2941);
					}
				}
			}),
			props.UpdateManager.FromHashList(["elecGen2Switch","elecGen2Hertz","elecGen2Volt","engine1Running","elecGen2Relay"], nil, func(val) {
				if (val.elecGen2Switch == 0) {
					obj["GEN2-content"].hide();
					obj["GEN2-off"].show();
					if (val.elecGen2Relay) {
						obj["GEN2-label"].setColor(0.7333,0.3803,0);
					} else {
						obj["GEN2-label"].setColor(0.8078,0.8039,0.8078);
					}
				} else {
					obj["GEN2-content"].show();
					obj["GEN2-off"].hide();
					obj["Gen2Volt"].setText(sprintf("%s", math.round(val.elecGen2Volt)));

					if (val.elecGen2Hertz == 0) {
						obj["Gen2Hz"].setText(sprintf("XX"));
					} else {
						obj["Gen2Hz"].setText(sprintf("%s", math.round(val.elecGen2Hertz)));
					}

					if (val.elecGen2Volt > 120 or val.elecGen2Volt < 110 or val.elecGen2Hertz > 410 or val.elecGen2Hertz < 390) {
						obj["GEN2-label"].setColor(0.7333,0.3803,0);
					} else {
						obj["GEN2-label"].setColor(0.8078,0.8039,0.8078);
					}

					if (val.elecGen2Volt > 120 or val.elecGen2Volt < 110) {
						obj["Gen2Volt"].setColor(0.7333,0.3803,0);
					} else {
						obj["Gen2Volt"].setColor(0.0509,0.7529,0.2941);
					}

					if (val.elecGen2Hertz > 410 or val.elecGen2Hertz < 390) {
						obj["Gen2Hz"].setColor(0.7333,0.3803,0);
					} else {
						obj["Gen2Hz"].setColor(0.0509,0.7529,0.2941);
					}
				}
			}),
			props.UpdateManager.FromHashList(["elecTR1Contact","elecAC1"], nil, func(val) {
				if (val.elecTR1Contact) {
					obj["ELEC-Line-TR1-DC1"].show();
				} else {
					obj["ELEC-Line-TR1-DC1"].hide();
				}
			}),
			props.UpdateManager.FromHashList(["elecTR2Contact","elecAC2"], nil, func(val) {
				if (val.elecTR2Contact) {
					obj["ELEC-Line-TR2-DC2"].show();
				} else {
					obj["ELEC-Line-TR2-DC2"].hide();
				}
			}),
			props.UpdateManager.FromHashList(["elecAcEssFeed1","elecAcEssFeed2","elecAC1","elecAC2"], nil, func(val) {
				if (val.elecAcEssFeed1) {
					if (val.elecAC1 >= 110) {
						obj["ELEC-Line-AC1-ACESS"].show();
					} else {
						obj["ELEC-Line-AC1-ACESS"].hide();
					}
					obj["ELEC-Line-AC2-ACESS"].hide();
				} elsif (val.elecAcEssFeed2) {
					obj["ELEC-Line-AC1-ACESS"].hide();
					if (val.elecAC2 >= 110) {
						obj["ELEC-Line-AC2-ACESS"].show();
					} else {
						obj["ELEC-Line-AC2-ACESS"].hide();
					}
				} else {
					obj["ELEC-Line-AC1-ACESS"].hide();
					obj["ELEC-Line-AC2-ACESS"].hide();
				}
			}),
			props.UpdateManager.FromHashList(["elecGen1Volt","elecGen1GLC"], nil, func(val) {
				if (val.elecGen1Volt >= 110 and val.elecGen1GLC) {
					obj["ELEC-Line-GEN1-AC1"].show();
				} else {
					obj["ELEC-Line-GEN1-AC1"].hide();
				}
			}),
			props.UpdateManager.FromHashList(["elecGen2Volt","elecGen2GLC"], nil, func(val) {
				if (val.elecGen2Volt >= 110 and val.elecGen2GLC) {
					obj["ELEC-Line-GEN2-AC2"].show();
				} else {
					obj["ELEC-Line-GEN2-AC2"].hide();
				}
			}),
			props.UpdateManager.FromHashValue("elecAcTie1", nil, func(val) {
				if (val) {
					obj["ELEC-Line-APU-AC1"].show();
				} else {
					obj["ELEC-Line-APU-AC1"].hide();
				}
			}),
			props.UpdateManager.FromHashValue("elecAcTie2", nil, func(val) {
				if (val) {
					obj["ELEC-Line-EXT-AC2"].show();
				} else {
					obj["ELEC-Line-EXT-AC2"].hide();
				}
			}),	
			props.UpdateManager.FromHashList(["elecAcTie1","elecAcTie2","apuGLC","elecExtEPC"], nil, func(val) {
				if ((val.apuGLC and val.elecAcTie2) or (val.elecExtEPC and val.elecAcTie1) or (val.elecAcTie1 and val.elecAcTie2)) {
					obj["ELEC-Line-APU-EXT"].show();
				} else {
					obj["ELEC-Line-APU-EXT"].hide();
				}
			}),
			props.UpdateManager.FromHashValue("elecExtEPC", nil, func(val) {
				if (val) {
					obj["EXT-out"].show();
				} else {
					obj["EXT-out"].hide();
				}
			}),
			props.UpdateManager.FromHashValue("apuGLC", nil, func(val) {
				if (val) {
					obj["APU-out"].show();
				} else {
					obj["APU-out"].hide();
				}
			}),
			props.UpdateManager.FromHashList(["elecEmerGenVoltsRelay","elec15XE1"], nil, func(val) {
				if (!val.elecEmerGenVoltsRelay and val.elec15XE1) {
					obj["ELEC-Line-ACESS-TRESS"].show();
				} else {
					obj["ELEC-Line-ACESS-TRESS"].hide();
				}
			}),
			props.UpdateManager.FromHashValue("elec15XE2", nil, func(val) {
				if (val) {
					obj["STATINV-group"].show();
				} else {
					obj["STATINV-group"].hide();
				}
			}),
			props.UpdateManager.FromHashValue("statInvVolts", 0.1, func(val) {
				obj["StatVolt"].setText(sprintf("%s",math.round(val)));
			}),
			props.UpdateManager.FromHashValue("statInvHertz", 0.5, func(val) {
				obj["StatHz"].setText(sprintf("%s",math.round(val)));
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
		"ELEC-ACESS-SHED-label","ELEC-DCBAT-label","ELEC-DCESS-label","ELEC-DC2-label","ELEC-DC1-label","ELEC-AC1-label","ELEC-AC2-label","ELEC-ACESS-label","ELEC-Line-ESSTR-DCESS-off","ELEC-Line-Emergen-ESSTR-off","STATINV-group","StatVolt","StatHz"];
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
	elecAcEssFeed1: "/systems/electrical/relay/ac-ess-feed-1/contact-pos",
	elecAcEssFeed2: "/systems/electrical/relay/ac-ess-feed-2/contact-pos",
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
	elecTR1Contact: "/systems/electrical/relay/tr-contactor-1/contact-pos",
	elecTR2Contact: "/systems/electrical/relay/tr-contactor-2/contact-pos",
	elecTREssAmp: "/systems/electrical/relay/ess-tr-contactor/output-amp",
	elecTrEssContact: "/systems/electrical/relay/ess-tr-contactor/contact-pos",
	elecTREssVolt: "/systems/electrical/relay/ess-tr-contactor/output",
	elecIDG1Disc: "/controls/electrical/switches/idg-1-disc",
	elecIDG2Disc: "/controls/electrical/switches/idg-2-disc",
	elecGroundCart: "/controls/electrical/ground-cart",
	elecExtHertz: "/systems/electrical/sources/ext/output-hertz",
	elecExtVolt: "/systems/electrical/sources/ext/output-volt",
	elecDCTie1: "/systems/electrical/relay/dc-bat-tie-dc-1/contact-pos",
	elecDCTie2: "/systems/electrical/relay/dc-bat-tie-dc-2/contact-pos",
	elecDcEssFeedBat: "/systems/electrical/relay/dc-bat-tie-dc-ess/contact-pos",
	elecAcEssEmerGenFeed: "/systems/electrical/relay/ac-ess-feed-emer-gen/contact-pos",
	elecEmerGenVolts: "/systems/electrical/sources/emer-gen/output-volt",
	elecEmerGenVoltsRelay: "/systems/electrical/relay/emer-glc/output",
	elecEmerGenHertz: "/systems/electrical/sources/emer-gen/output-hertz",
	elecGen1Switch: "/controls/electrical/switches/gen-1",
	elecGen1Hertz: "/systems/electrical/sources/idg-1/output-hertz",
	elecGen1Volt: "/systems/electrical/sources/idg-1/output-volt",
	elecGen1Relay: "/systems/electrical/sources/idg-1/gcr-relay",
	elecGen1GLC: "/systems/electrical/relay/gen-1-glc/contact-pos",
	elecGen2Switch: "/controls/electrical/switches/gen-2",
	elecGen2Hertz: "/systems/electrical/sources/idg-2/output-hertz",
	elecGen2Volt: "/systems/electrical/sources/idg-2/output-volt",
	elecGen2Relay: "/systems/electrical/sources/idg-2/gcr-relay",
	elecGen2GLC: "/systems/electrical/relay/gen-2-glc/contact-pos",
	elecAcTie1: "/systems/electrical/relay/ac-bus-ac-bus-tie-1/contact-pos",
	elecAcTie2: "/systems/electrical/relay/ac-bus-ac-bus-tie-2/contact-pos",
	elecExtEPC: "/systems/electrical/relay/ext-epc/contact-pos",
	elec15XE1: "/systems/electrical/relay/relay-15XE1/contact-pos",
	elec15XE2: "/systems/electrical/relay/relay-15XE2/contact-pos",
	statInvVolts: "/systems/electrical/sources/si-1/output-volt",
	statInvHertz: "/systems/electrical/sources/si-1/output-hertz",
	ElecGalleyShed: "/systems/electrical/some-electric-thingie/galley-shed",
};

foreach (var name; keys(input)) {
	emesary.GlobalTransmitter.NotifyAll(notifications.FrameNotificationAddProperty.new("A320 System Display", name, input[name]));
}