# A3XX Lower ECAM Canvas
# Copyright (c) 2021 Josh Davidson (Octal450) and Jonathan Redpath

var canvas_lowerECAMPageWheel =
{
	new: func(svg,name) {
		var obj = {parents: [canvas_lowerECAMPageWheel,canvas_lowerECAM_base] };
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
		obj["leftuplock"].hide();
		obj["noseuplock"].hide();
		obj["rightuplock"].hide();
		obj["tirepress1"].hide();
		obj["tirepress2"].hide();
		obj["tirepress3"].hide();
		obj["tirepress4"].hide();
		obj["tirepress5"].hide();
		obj["tirepress6"].hide();

		
		obj.update_items = [
			props.UpdateManager.FromHashList(["gearPosNorm","gearPosNorm1","gearPosNorm2","gearLever"], nil, func(val) {
				if (val.gearLever and (val.gearPosNorm != 1 or val.gearPosNorm1 != 1 or val.gearPosNorm2 != 1)) {
					obj["lgctltext"].show();
				} elsif (!val.gearLever and (val.gearPosNorm != 0 or val.gearPosNorm1 != 0 or val.gearPosNorm2 != 0)) {
					obj["lgctltext"].show();
				} else {
					obj["lgctltext"].hide();
				}
			}),
			props.UpdateManager.FromHashValue("gearPosNorm", nil, func(val) {
				if (val < 0.2) {
					obj["Triangle-Nose1"].hide();
					obj["Triangle-Nose2"].hide();
				} else {
					obj["Triangle-Nose1"].show();
					obj["Triangle-Nose2"].show();
				}

				if (val == 1) {
					obj["Triangle-Nose1"].setColor(0.0509,0.7529,0.2941);
					obj["Triangle-Nose2"].setColor(0.0509,0.7529,0.2941);
				} else {
					obj["Triangle-Nose1"].setColor(1,0,0);
					obj["Triangle-Nose2"].setColor(1,0,0);
				}
			}),
			props.UpdateManager.FromHashValue("gearPosNorm1", nil, func(val) {
				if (val < 0.2) {
					obj["Triangle-Left1"].hide();
					obj["Triangle-Left2"].hide();
				} else {
					obj["Triangle-Left1"].show();
					obj["Triangle-Left2"].show();
				}

				if (val == 1) {
					obj["Triangle-Left1"].setColor(0.0509,0.7529,0.2941);
					obj["Triangle-Left2"].setColor(0.0509,0.7529,0.2941);
				} else {
					obj["Triangle-Left1"].setColor(1,0,0);
					obj["Triangle-Left2"].setColor(1,0,0);
				}
			}),
			props.UpdateManager.FromHashValue("gearPosNorm2", nil, func(val) {
				if (val < 0.2) {
					obj["Triangle-Right1"].hide();
					obj["Triangle-Right2"].hide();
				} else {
					obj["Triangle-Right1"].show();
					obj["Triangle-Right2"].show();
				}

				if (val == 1) {
					obj["Triangle-Right1"].setColor(0.0509,0.7529,0.2941);
					obj["Triangle-Right2"].setColor(0.0509,0.7529,0.2941);
				} else {
					obj["Triangle-Right1"].setColor(1,0,0);
					obj["Triangle-Right2"].setColor(1,0,0);
				}
			}),
			props.UpdateManager.FromHashList(["yellow","green","NWSSwitch","brakesMode","val.accumPressPsiPressPsi","leftBrakeFCS","rightBrakeFCS"], nil, func(val) {
				if (val.NWSSwitch and val.yellow >= 1500) {
					obj["NWStext"].hide();
					obj["NWS"].hide();
					obj["NWSrect"].hide();
				} else if (!val.NWSSwitch and val.yellow >= 1500) {
					obj["NWStext"].show();
					obj["NWS"].show();
					obj["NWS"].setColor(0.0509,0.7529,0.2941);
					obj["NWSrect"].show();
				} else {
					obj["NWStext"].show();
					obj["NWS"].show();
					obj["NWS"].setColor(0.7333,0.3803,0);
					obj["NWSrect"].show();
				}
				
				if ((val.yellow < 1500 and val.brakesMode == 1) or !val.NWSSwitch) {
					obj["antiskidtext"].show();
					obj["antiskidtext"].setColor(0.7333,0.3803,0);
					obj["BSCUrect1"].show();
					obj["BSCUrect2"].show();
					obj["BSCU1"].show();
					obj["BSCU2"].show();
				} else {
					obj["antiskidtext"].hide();
					obj["BSCUrect1"].hide();
					obj["BSCUrect2"].hide();
					obj["BSCU1"].hide();
					obj["BSCU2"].hide();
				}
				
				if (val.green >= 1500) {
					obj["normbrkhyd"].setColor(0.0509,0.7529,0.2941);
				} else {
					obj["normbrkhyd"].setColor(0.7333,0.3803,0);
				}
				
				if (val.yellow >= 1500) {
					obj["altnbrkhyd"].setColor(0.0509,0.7529,0.2941);
				} else {
					obj["altnbrkhyd"].setColor(0.7333,0.3803,0);
				}
				
				if (!val.NWSSwitch or val.green < 1500) {
					obj["NORMbrk"].show();
					obj["normbrk-rect"].show();
					obj["normbrkhyd"].show();
				} else {
					obj["NORMbrk"].hide();
					obj["normbrk-rect"].hide();
					obj["normbrkhyd"].hide();
				}
				
				if (val.brakesMode != 2 or val.green < 1500 or val.yellow < 1500 or !val.NWSSwitch) {
					obj["ALTNbrk"].hide();
					obj["altnbrk-rect"].hide();
					obj["altnbrkhyd"].hide();
				} else {
					obj["ALTNbrk"].show();
					obj["altnbrk-rect"].show();
					obj["altnbrkhyd"].show();
					if (val.yellow < 1500 and val.accumPressPsi < 1500) {
						obj["ALTNbrk"].setColor(0.7333,0.3803,0);
					} else {
						obj["ALTNbrk"].setColor(0.0509,0.7529,0.2941);
					}
				}

				if (val.brakesMode == 2 and val.accumPressPsi < 200 and val.yellow < 1500) {
					obj["accuonlyarrow"].hide();
					obj["accuonly"].hide();
					obj["accupress_text"].show();
					obj["brakearrow"].hide();
					obj["accupress_text"].setColor(0.7333,0.3803,0);
				} else if (val.brakesMode == 2 and val.NWSSwitch and val.accumPressPsi > 200 and val.yellow >= 1500){
					obj["accuonlyarrow"].hide();
					obj["accuonly"].hide();
					obj["accupress_text"].show();
					obj["brakearrow"].show();
					obj["accupress_text"].setColor(0.0509,0.7529,0.2941);
				} else if (val.brakesMode == 2 and val.accumPressPsi > 200 and val.yellow < 1500) {
					obj["accuonlyarrow"].show();
					obj["accuonly"].show();
					obj["brakearrow"].hide();
					obj["accupress_text"].hide();
				} else {
					obj["accuonlyarrow"].hide();
					obj["accuonly"].hide();
					obj["brakearrow"].hide();
					obj["accupress_text"].hide();
				}
				
				if (val.brakesMode == 1) {
					obj["releaseL1"].hide();
					obj["releaseL2"].hide();
					obj["releaseL3"].hide();
					obj["releaseL4"].hide();
					obj["releaseR1"].hide();
					obj["releaseR2"].hide();
					obj["releaseR3"].hide();
					obj["releaseR4"].hide();
				} else { # Display if the brakes are released and in alternate braking
					if (val.leftBrakeFCS == 0) {
						obj["releaseL1"].show();
						obj["releaseL2"].show();
						obj["releaseL3"].show();
						obj["releaseL4"].show();
					} else {
						obj["releaseL1"].hide();
						obj["releaseL2"].hide();
						obj["releaseL3"].hide();
						obj["releaseL4"].hide();
					}
					
					if (val.rightBrakeFCS == 0) {
						obj["releaseR1"].show();
						obj["releaseR2"].show();
						obj["releaseR3"].show();
						obj["releaseR4"].show();
					} else {
						obj["releaseR1"].hide();
						obj["releaseR2"].hide();
						obj["releaseR3"].hide();
						obj["releaseR4"].hide();
					}
				}
			}),
			props.UpdateManager.FromHashList(["brakeAutobrkMode","NWSSwitch"], nil, func(val) {
				if (val.brakeAutobrkMode == 0) {
					obj["autobrkind"].hide();
				} elsif (val.brakeAutobrkMode == 1) {
					obj["autobrkind"].show();
					obj["autobrkind"].setText(sprintf("%s", "LO"));
				} elsif (val.brakeAutobrkMode == 2) {
					obj["autobrkind"].show();
					obj["autobrkind"].setText(sprintf("%s", "MED"));
				} elsif (val.brakeAutobrkMode == 3) {
					obj["autobrkind"].show();
					obj["autobrkind"].setText(sprintf("%s", "MAX"));
				}

				if (val.brakeAutobrkMode != 0 or !val.NWSSwitch) {
					obj["autobrk"].show();
				} else {
					obj["autobrk"].hide();
				}
				
				if (!val.NWSSwitch) {
					obj["autobrk"].setColor(0.7333,0.3803,0);
				} else {
					obj["autobrk"].setColor(0.0509,0.7529,0.2941);
				}
			}),
			props.UpdateManager.FromHashValue("brakeLeft1", 0.5, func(val) {
				obj["braketemp1"].setText(sprintf("%s", math.round(val, 5)));
				
				if (val > 300) {
					obj["braketemp1"].setColor(0.7333,0.3803,0);
					obj["toparc1"].setColor(0.7333,0.3803,0);
				} else {
					if (val > 100 and val <= 300) {
						obj["toparc1"].setColor(0.0509,0.7529,0.2941);
					} else {
						obj["toparc1"].setColor(0.8078,0.8039,0.8078);
					}
					obj["braketemp1"].setColor(0.0509,0.7529,0.2941);
				}
			}),
			props.UpdateManager.FromHashValue("brakeLeft2", 0.5, func(val) {
				obj["braketemp2"].setText(sprintf("%s", math.round(val, 5)));
				
				if (val > 300) {
					obj["braketemp2"].setColor(0.7333,0.3803,0);
					obj["toparc2"].setColor(0.7333,0.3803,0);
				} else {
					if (val > 100 and val <= 300) {
						obj["toparc2"].setColor(0.0509,0.7529,0.2941);
					} else {
						obj["toparc2"].setColor(0.8078,0.8039,0.8078);
					}
					obj["braketemp2"].setColor(0.0509,0.7529,0.2941);
				}
			}),
			props.UpdateManager.FromHashValue("brakeRight1", 0.5, func(val) {
				obj["braketemp3"].setText(sprintf("%s", math.round(val, 5)));
				
				if (val > 300) {
					obj["braketemp3"].setColor(0.7333,0.3803,0);
					obj["toparc3"].setColor(0.7333,0.3803,0);
				} else {
					if (val > 100 and val <= 300) {
						obj["toparc3"].setColor(0.0509,0.7529,0.2941);
					} else {
						obj["toparc3"].setColor(0.8078,0.8039,0.8078);
					}
					obj["braketemp3"].setColor(0.0509,0.7529,0.2941);
				}
			}),
			props.UpdateManager.FromHashValue("brakeRight2", 0.5, func(val) {
				obj["braketemp4"].setText(sprintf("%s", math.round(val, 5)));
				
				if (val > 300) {
					obj["braketemp4"].setColor(0.7333,0.3803,0);
					obj["toparc4"].setColor(0.7333,0.3803,0);
				} else {
					if (val > 100 and val <= 300) {
						obj["toparc4"].setColor(0.0509,0.7529,0.2941);
					} else {
						obj["toparc4"].setColor(0.8078,0.8039,0.8078);
					}
					obj["braketemp4"].setColor(0.0509,0.7529,0.2941);
				}
			}),
			props.UpdateManager.FromHashValue("wheelLeftDoor", 0.5, func(val) {
				obj["leftdoor"].setRotation(val * D2R);
			}),
			props.UpdateManager.FromHashValue("wheelNoseLeftDoor", 0.5, func(val) {
				obj["nosegeardoorL"].setRotation(val * D2R);
			}),
			props.UpdateManager.FromHashValue("wheelNoseRightDoor", 0.5, func(val) {
				obj["nosegeardoorR"].setRotation(val * D2R);
			}),
			props.UpdateManager.FromHashValue("wheelRightDoor", 0.5, func(val) {
				obj["rightdoor"].setRotation(val * D2R);
			}),
			props.UpdateManager.FromHashValue("wheelLeftDoorPos", 0.01, func(val) {
				if (val == 0) {
					obj["leftdoor"].setColorFill(0.0509,0.7529,0.2941);
				} else {
					obj["leftdoor"].setColorFill(0.7333,0.3803,0);
				}
			}),
			props.UpdateManager.FromHashValue("wheelNoseDoorPos", 0.01, func(val) {
				if (val == 0) {
					obj["nosegeardoorL"].setColorFill(0.0509,0.7529,0.2941);
					obj["nosegeardoorR"].setColorFill(0.0509,0.7529,0.2941);
				} else {
					obj["nosegeardoorL"].setColorFill(0.7333,0.3803,0);
					obj["nosegeardoorR"].setColorFill(0.7333,0.3803,0);
				}
			}),
			props.UpdateManager.FromHashValue("wheelRightDoorPos", 0.01, func(val) {
				if (val == 0) {
					obj["rightdoor"].setColorFill(0.0509,0.7529,0.2941);
				} else {
					obj["rightdoor"].setColorFill(0.7333,0.3803,0);
				}
			}),
			props.UpdateManager.FromHashValue("spoilerL1", 0.5, func(val) {
				if (val < 1.5) {
					obj["spoiler1Lex"].hide();
					obj["spoiler1Lrt"].show();
				} else {
					obj["spoiler1Lrt"].hide();
					obj["spoiler1Lex"].show();
				}
			}),
			props.UpdateManager.FromHashValue("spoilerL2", 0.5, func(val) {
				if (val < 1.5) {
					obj["spoiler2Lex"].hide();
					obj["spoiler2Lrt"].show();
				} else {
					obj["spoiler2Lrt"].hide();
					obj["spoiler2Lex"].show();
				}
			}),
			props.UpdateManager.FromHashValue("spoilerL3", 0.5, func(val) {
				if (val < 1.5) {
					obj["spoiler3Lex"].hide();
					obj["spoiler3Lrt"].show();
				} else {
					obj["spoiler3Lrt"].hide();
					obj["spoiler3Lex"].show();
				}
			}),
			props.UpdateManager.FromHashValue("spoilerL4", 0.5, func(val) {
				if (val < 1.5) {
					obj["spoiler4Lex"].hide();
					obj["spoiler4Lrt"].show();
				} else {
					obj["spoiler4Lrt"].hide();
					obj["spoiler4Lex"].show();
				}
			}),
			props.UpdateManager.FromHashValue("spoilerL5", 0.5, func(val) {
				if (val < 1.5) {
					obj["spoiler5Lex"].hide();
					obj["spoiler5Lrt"].show();
				} else {
					obj["spoiler5Lrt"].hide();
					obj["spoiler5Lex"].show();
				}
			}),
			props.UpdateManager.FromHashValue("spoilerR1", 0.5, func(val) {
				if (val < 1.5) {
					obj["spoiler1Rex"].hide();
					obj["spoiler1Rrt"].show();
				} else {
					obj["spoiler1Rrt"].hide();
					obj["spoiler1Rex"].show();
				}
			}),
			props.UpdateManager.FromHashValue("spoilerR2", 0.5, func(val) {
				if (val < 1.5) {
					obj["spoiler2Rex"].hide();
					obj["spoiler2Rrt"].show();
				} else {
					obj["spoiler2Rrt"].hide();
					obj["spoiler2Rex"].show();
				}
			}),
			props.UpdateManager.FromHashValue("spoilerR3", 0.5, func(val) {
				if (val < 1.5) {
					obj["spoiler3Rex"].hide();
					obj["spoiler3Rrt"].show();
				} else {
					obj["spoiler3Rrt"].hide();
					obj["spoiler3Rex"].show();
				}
			}),
			props.UpdateManager.FromHashValue("spoilerR4", 0.5, func(val) {
				if (val < 1.5) {
					obj["spoiler4Rex"].hide();
					obj["spoiler4Rrt"].show();
				} else {
					obj["spoiler4Rrt"].hide();
					obj["spoiler4Rex"].show();
				}
			}),
			props.UpdateManager.FromHashValue("spoilerR5", 0.5, func(val) {
				if (val < 1.5) {
					obj["spoiler5Rex"].hide();
					obj["spoiler5Rrt"].show();
				} else {
					obj["spoiler5Rrt"].hide();
					obj["spoiler5Rex"].show();
				}
			}),
			props.UpdateManager.FromHashList(["spoilerL1Failure","spoilerL1","green"], nil, func(val) {
				if (val.spoilerL1Failure or val.green < 1500) {
					obj["spoiler1Lex"].setColor(0.7333,0.3803,0);
					obj["spoiler1Lrt"].setColor(0.7333,0.3803,0);
					if (val.spoilerL1 < 1.5) {
						obj["spoiler1Lf"].show();
					} else {
						obj["spoiler1Lf"].hide();
					}
				} else {
					obj["spoiler1Lex"].setColor(0.0509,0.7529,0.2941);
					obj["spoiler1Lrt"].setColor(0.0509,0.7529,0.2941);
					obj["spoiler1Lf"].hide();
				}
			}),
			props.UpdateManager.FromHashList(["spoilerL2Failure","spoilerL2","yellow"], nil, func(val) {
				if (val.spoilerL2Failure or val.yellow < 1500) {
					obj["spoiler2Lex"].setColor(0.7333,0.3803,0);
					obj["spoiler2Lrt"].setColor(0.7333,0.3803,0);
					if (val.spoilerL2 < 1.5) {
						obj["spoiler2Lf"].show();
					} else {
						obj["spoiler2Lf"].hide();
					}
				} else {
					obj["spoiler2Lex"].setColor(0.0509,0.7529,0.2941);
					obj["spoiler2Lrt"].setColor(0.0509,0.7529,0.2941);
					obj["spoiler2Lf"].hide();
				}
			}),
			props.UpdateManager.FromHashList(["spoilerL3Failure","spoilerL3","blue"], nil, func(val) {
				if (val.spoilerL3Failure or val.blue < 1500) {
					obj["spoiler3Lex"].setColor(0.7333,0.3803,0);
					obj["spoiler3Lrt"].setColor(0.7333,0.3803,0);
					if (val.spoilerL3 < 1.5) {
						obj["spoiler3Lf"].show();
					} else {
						obj["spoiler3Lf"].hide();
					}
				} else {
					obj["spoiler3Lex"].setColor(0.0509,0.7529,0.2941);
					obj["spoiler3Lrt"].setColor(0.0509,0.7529,0.2941);
					obj["spoiler3Lf"].hide();
				}
			}),
			props.UpdateManager.FromHashList(["spoilerL4Failure","spoilerL4","yellow"], nil, func(val) {
				if (val.spoilerL4Failure or val.yellow < 1500) {
					obj["spoiler4Lex"].setColor(0.7333,0.3803,0);
					obj["spoiler4Lrt"].setColor(0.7333,0.3803,0);
					if (val.spoilerL4 < 1.5) {
						obj["spoiler4Lf"].show();
					} else {
						obj["spoiler4Lf"].hide();
					}
				} else {
					obj["spoiler4Lex"].setColor(0.0509,0.7529,0.2941);
					obj["spoiler4Lrt"].setColor(0.0509,0.7529,0.2941);
					obj["spoiler4Lf"].hide();
				}
			}),
			props.UpdateManager.FromHashList(["spoilerL5Failure","spoilerL5","green"], nil, func(val) {
				if (val.spoilerL5Failure or val.green < 1500) {
					obj["spoiler5Lex"].setColor(0.7333,0.3803,0);
					obj["spoiler5Lrt"].setColor(0.7333,0.3803,0);
					if (val.spoilerL5 < 1.5) {
						obj["spoiler5Lf"].show();
					} else {
						obj["spoiler5Lf"].hide();
					}
				} else {
					obj["spoiler5Lex"].setColor(0.0509,0.7529,0.2941);
					obj["spoiler5Lrt"].setColor(0.0509,0.7529,0.2941);
					obj["spoiler5Lf"].hide();
				}
			}),
			props.UpdateManager.FromHashList(["spoilerR1Failure","spoilerR1","green"], nil, func(val) {
				if (val.spoilerR1Failure or val.green < 1500) {
					obj["spoiler1Rex"].setColor(0.7333,0.3803,0);
					obj["spoiler1Rrt"].setColor(0.7333,0.3803,0);
					if (val.spoilerR1 < 1.5) {
						obj["spoiler1Rf"].show();
					} else {
						obj["spoiler1Rf"].hide();
					}
				} else {
					obj["spoiler1Rex"].setColor(0.0509,0.7529,0.2941);
					obj["spoiler1Rrt"].setColor(0.0509,0.7529,0.2941);
					obj["spoiler1Rf"].hide();
				}
			}),
			props.UpdateManager.FromHashList(["spoilerR2Failure","spoilerR2","yellow"], nil, func(val) {
				if (val.spoilerR2Failure or val.yellow < 1500) {
					obj["spoiler2Rex"].setColor(0.7333,0.3803,0);
					obj["spoiler2Rrt"].setColor(0.7333,0.3803,0);
					if (val.spoilerR2 < 1.5) {
						obj["spoiler2Rf"].show();
					} else {
						obj["spoiler2Rf"].hide();
					}
				} else {
					obj["spoiler2Rex"].setColor(0.0509,0.7529,0.2941);
					obj["spoiler2Rrt"].setColor(0.0509,0.7529,0.2941);
					obj["spoiler2Rf"].hide();
				}
			}),
			props.UpdateManager.FromHashList(["spoilerR3Failure","spoilerR3","blue"], nil, func(val) {
				if (val.spoilerR3Failure or val.blue < 1500) {
					obj["spoiler3Rex"].setColor(0.7333,0.3803,0);
					obj["spoiler3Rrt"].setColor(0.7333,0.3803,0);
					if (val.spoilerR3 < 1.5) {
						obj["spoiler3Rf"].show();
					} else {
						obj["spoiler3Rf"].hide();
					}
				} else {
					obj["spoiler3Rex"].setColor(0.0509,0.7529,0.2941);
					obj["spoiler3Rrt"].setColor(0.0509,0.7529,0.2941);
					obj["spoiler3Rf"].hide();
				}
			}),
			props.UpdateManager.FromHashList(["spoilerR4Failure","spoilerR4","yellow"], nil, func(val) {
				if (val.spoilerR4Failure or val.yellow < 1500) {
					obj["spoiler4Rex"].setColor(0.7333,0.3803,0);
					obj["spoiler4Rrt"].setColor(0.7333,0.3803,0);
					if (val.spoilerR4 < 1.5) {
						obj["spoiler4Rf"].show();
					} else {
						obj["spoiler4Rf"].hide();
					}
				} else {
					obj["spoiler4Rex"].setColor(0.0509,0.7529,0.2941);
					obj["spoiler4Rrt"].setColor(0.0509,0.7529,0.2941);
					obj["spoiler4Rf"].hide();
				}
			}),
			props.UpdateManager.FromHashList(["spoilerR5Failure","spoilerR5","green"], nil, func(val) {
				if (val.spoilerR5Failure or val.green < 1500) {
					obj["spoiler5Rex"].setColor(0.7333,0.3803,0);
					obj["spoiler5Rrt"].setColor(0.7333,0.3803,0);
					if (val.spoilerR5 < 1.5) {
						obj["spoiler5Rf"].show();
					} else {
						obj["spoiler5Rf"].hide();
					}
				} else {
					obj["spoiler5Rex"].setColor(0.0509,0.7529,0.2941);
					obj["spoiler5Rrt"].setColor(0.0509,0.7529,0.2941);
					obj["spoiler5Rf"].hide();
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
		return["lgctltext","NORMbrk","NWStext","leftdoor","rightdoor","nosegeardoorL","nosegeardoorR",
		"autobrk","autobrkind","NWS","NWSrect","normbrk-rect","altnbrk","normbrkhyd","spoiler1Rex","spoiler1Rrt","spoiler2Rex","spoiler2Rrt","spoiler3Rex",
		"spoiler3Rrt","spoiler4Rex","spoiler4Rrt","spoiler5Rex","spoiler5Rrt","spoiler1Lex","spoiler1Lrt","spoiler2Lex","spoiler2Lrt",
		"spoiler3Lex","spoiler3Lrt","spoiler4Lex","spoiler4Lrt","spoiler5Lex","spoiler5Lrt","spoiler1Rf","spoiler2Rf","spoiler3Rf","spoiler4Rf","spoiler5Rf",
		"spoiler1Lf","spoiler2Lf","spoiler3Lf","spoiler4Lf","spoiler5Lf","ALTNbrk","altnbrkhyd","altnbrk-rect","antiskidtext","brakearrow","accupress_text",
		"accuonlyarrow","accuonly","braketemp1","normbrkhyd","braketemp2","braketemp3","braketemp4","toparc1","toparc2","toparc3","toparc4","leftuplock",
		"noseuplock","rightuplock","Triangle-Left1","Triangle-Left2","Triangle-Nose1","Triangle-Nose2","Triangle-Right1","Triangle-Right2","BSCUrect1",
		"BSCUrect2","BSCU1","BSCU2","tirepress1","tirepress2","tirepress3","tirepress4","tirepress5","tirepress6","releaseL1","releaseL2","releaseR1","releaseR2",
		"releaseL3","releaseL4","releaseR3","releaseR4"];
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
	brakeAutobrkMode: "/controls/autobrake/mode",
	brakeLeft1: "/gear/gear[1]/L1brake-temp-degc",
	brakeLeft2: "/gear/gear[1]/L2brake-temp-degc",
	brakeRight1: "/gear/gear[2]/R3brake-temp-degc",
	brakeRight2: "/gear/gear[2]/R4brake-temp-degc",
	wheelLeftDoor: "/ECAM/Lower/door-left",
	wheelNoseLeftDoor: "/ECAM/Lower/door-nose-left",
	wheelNoseRightDoor: "/ECAM/Lower/door-nose-right",
	wheelRightDoor: "/ECAM/Lower/door-right",
	wheelLeftDoorPos: "/systems/hydraulic/gear/door-left",
	wheelNoseDoorPos: "/systems/hydraulic/gear/door-nose",
	wheelRightDoorPos: "/systems/hydraulic/gear/door-right",
	
	spoilerL1: "/fdm/jsbsim/hydraulics/spoiler-l1/final-deg",
	spoilerL2: "/fdm/jsbsim/hydraulics/spoiler-l2/final-deg",
	spoilerL3: "/fdm/jsbsim/hydraulics/spoiler-l3/final-deg",
	spoilerL4: "/fdm/jsbsim/hydraulics/spoiler-l4/final-deg",
	spoilerL5: "/fdm/jsbsim/hydraulics/spoiler-l5/final-deg",
	spoilerR1: "/fdm/jsbsim/hydraulics/spoiler-r1/final-deg",
	spoilerR2: "/fdm/jsbsim/hydraulics/spoiler-r2/final-deg",
	spoilerR3: "/fdm/jsbsim/hydraulics/spoiler-r3/final-deg",
	spoilerR4: "/fdm/jsbsim/hydraulics/spoiler-r4/final-deg",
	spoilerR5: "/fdm/jsbsim/hydraulics/spoiler-r5/final-deg",
	spoilerL1Failure: "/systems/failures/spoilers/spoiler-l1",
	spoilerL2Failure: "/systems/failures/spoilers/spoiler-l2",
	spoilerL3Failure: "/systems/failures/spoilers/spoiler-l3",
	spoilerL4Failure: "/systems/failures/spoilers/spoiler-l4",
	spoilerL5Failure: "/systems/failures/spoilers/spoiler-l5",
	spoilerR1Failure: "/systems/failures/spoilers/spoiler-r1",
	spoilerR2Failure: "/systems/failures/spoilers/spoiler-r2",
	spoilerR3Failure: "/systems/failures/spoilers/spoiler-r3",
	spoilerR4Failure: "/systems/failures/spoilers/spoiler-r4",
	spoilerR5Failure: "/systems/failures/spoilers/spoiler-r5",
};

foreach (var name; keys(input)) {
	emesary.GlobalTransmitter.NotifyAll(notifications.FrameNotificationAddProperty.new("A320 System Display", name, input[name]));
}