# A3XX Lower ECAM Canvas
# Copyright (c) 2024 Josh Davidson (Octal450) and Jonathan Redpath

var fuel_used_lbs1 = props.globals.getNode("/systems/fuel/fuel-used-1", 1);
var fuel_used_lbs2 = props.globals.getNode("/systems/fuel/fuel-used-2", 1);

var canvas_lowerECAMPageFuel =
{
	new: func(svg,name) {
		var obj = {parents: [canvas_lowerECAMPageFuel,canvas_lowerECAM_base] };
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
		obj["FUEL-Left-blocked"].hide();
		obj["FUEL-Right-blocked"].hide();
		obj["FUEL-Left-Outer-Inacc"].hide();
		obj["FUEL-Left-Inner-Inacc"].hide();
		obj["FUEL-Right-Outer-Inacc"].hide();
		obj["FUEL-Right-Inner-Inacc"].hide();
		obj["FUEL-Center-Inacc"].hide();
		
		obj.update_items = [
			props.UpdateManager.FromHashValue("acconfigUnits", 1, func(val) {
				if (val) {
					obj["FOB-weight-unit"].setText("KG");
					obj["Fused-weight-unit"].setText("KG");
					obj["FFlow-weight-unit"].setText("KG/MIN");
				} else {
					obj["FOB-weight-unit"].setText("LBS");
					obj["Fused-weight-unit"].setText("LBS");
					obj["FFlow-weight-unit"].setText("LBS/MIN");
				}
			}),
			props.UpdateManager.FromHashList(["engFuelUsed1","acconfigUnits"], 0.5, func(val) {
				if (val.acconfigUnits) {
					obj["FUEL-used-1"].setText(sprintf("%s", math.round(val.engFuelUsed1 * LBS2KGS, 10)));
				} else {
					obj["FUEL-used-1"].setText(sprintf("%s", math.round(val.engFuelUsed1, 10)));
				}
			}),
			props.UpdateManager.FromHashList(["engFuelUsed2","acconfigUnits"], 0.5, func(val) {
				if (val.acconfigUnits) {
					obj["FUEL-used-2"].setText(sprintf("%s", math.round(val.engFuelUsed2 * LBS2KGS, 10)));
				} else {
					obj["FUEL-used-2"].setText(sprintf("%s", math.round(val.engFuelUsed2, 10)));
				}
			}),
			props.UpdateManager.FromHashList(["engFuelUsed1","engFuelUsed2","acconfigUnits"], 0.5, func(val) {
				if (val.acconfigUnits) {
					obj["FUEL-used-both"].setText(sprintf("%s", (math.round((val.engFuelUsed1 * LBS2KGS) + (val.engFuelUsed2 * LBS2KGS), 10))));
				} else {
					obj["FUEL-used-both"].setText(sprintf("%s", (math.round(val.engFuelUsed1 + val.engFuelUsed2, 10))));
				}
			}),
			props.UpdateManager.FromHashList(["fuelLeftOuterQty","acconfigUnits"], 0.25, func(val) {
				if (val.acconfigUnits) {
					obj["FUEL-Left-Outer-quantity"].setText(sprintf("%s",  math.round(val.fuelLeftOuterQty * LBS2KGS, 10)));
				} else {
					obj["FUEL-Left-Outer-quantity"].setText(sprintf("%s",  math.round(val.fuelLeftOuterQty, 10)));
				}
			}),
			props.UpdateManager.FromHashList(["fuelRightOuterQty","acconfigUnits"], 0.25, func(val) {
				if (val.acconfigUnits) {
					obj["FUEL-Right-Outer-quantity"].setText(sprintf("%s",  math.round(val.fuelRightOuterQty * LBS2KGS, 10)));
				} else {
					obj["FUEL-Right-Outer-quantity"].setText(sprintf("%s",  math.round(val.fuelRightOuterQty, 10)));
				}
			}),
			props.UpdateManager.FromHashList(["fuelCenterQty","acconfigUnits"], 0.25, func(val) {
				if (val.acconfigUnits) {
					obj["FUEL-Center-quantity"].setText(sprintf("%s",  math.round(val.fuelCenterQty * LBS2KGS, 10)));
				} else {
					obj["FUEL-Center-quantity"].setText(sprintf("%s",  math.round(val.fuelCenterQty, 10)));
				}
			}),
			props.UpdateManager.FromHashList(["fuelLeftInnerQty","acconfigUnits"], 0.25, func(val) {
				if (val.acconfigUnits) {
					obj["FUEL-Left-Inner-quantity"].setText(sprintf("%s",  math.round(val.fuelLeftInnerQty * LBS2KGS, 10)));
				} else {
					obj["FUEL-Left-Inner-quantity"].setText(sprintf("%s",  math.round(val.fuelLeftInnerQty, 10)));
				}
			}),
			props.UpdateManager.FromHashList(["fuelRightInnerQty","acconfigUnits"], 0.25, func(val) {
				if (val.acconfigUnits) {
					obj["FUEL-Right-Inner-quantity"].setText(sprintf("%s",  math.round(val.fuelRightInnerQty * LBS2KGS, 10)));
				} else {
					obj["FUEL-Right-Inner-quantity"].setText(sprintf("%s",  math.round(val.fuelRightInnerQty, 10)));
				}
			}),
			props.UpdateManager.FromHashList(["fuelflow_1","fuelflow_2","acconfigUnits"], 0.25, func(val) {
				if (val.acconfigUnits) {
					obj.fuelFlowPerMinute = sprintf("%s", math.round(((val.fuelflow_1 + val.fuelflow_2) * LBS2KGS) / 60, 10));
				} else {
					obj.fuelFlowPerMinute = sprintf("%s", math.round((val.fuelflow_1 + val.fuelflow_2) / 60, 10));
				}
			}),
			props.UpdateManager.FromHashValue("N1_actual_1", 0.05, func(val) {
				if (val <= 18.8) {
					obj["ENG1idFFlow"].setColor(0.7333,0.3803,0);
					obj["FUEL-ENG-1-label"].setColor(0.7333,0.3803,0);
				} else {
					obj["ENG1idFFlow"].setColor(0.8078,0.8039,0.8078);
					obj["FUEL-ENG-1-label"].setColor(0.8078,0.8039,0.8078);
				}
			}),
			props.UpdateManager.FromHashValue("N1_actual_2", 0.05, func(val) {
				if (val <= 18.8) {
					obj["ENG2idFFlow"].setColor(0.7333,0.3803,0);
					obj["FUEL-ENG-2-label"].setColor(0.7333,0.3803,0);
				} else {
					obj["ENG2idFFlow"].setColor(0.8078,0.8039,0.8078);
					obj["FUEL-ENG-2-label"].setColor(0.8078,0.8039,0.8078);
				}
			}),
			props.UpdateManager.FromHashValue("fuelLeftSwitch1", 1, func(val) {
				if (val) {
					obj["FUEL-Pump-Left-1-Open"].show();
					obj["FUEL-Pump-Left-1-Closed"].hide();
					obj["FUEL-Pump-Left-1"].setColor(0.0509,0.7529,0.2941);
					obj["FUEL-Pump-Left-1"].setColorFill(0.0509,0.7529,0.2941);
					obj["FUEL-Pump-Left-1-Square"].setColorFill(0.0509,0.7529,0.2941);
					obj["FUEL-Pump-Left-1-Open"].setColorFill(0.0509,0.7529,0.2941);
					obj["FUEL-Pump-Left-1-Closed"].setColorFill(0.0509,0.7529,0.2941);
				} else {
					obj["FUEL-Pump-Left-1-Open"].hide();
					obj["FUEL-Pump-Left-1-Closed"].show();
					obj["FUEL-Pump-Left-1"].setColor(0.7333,0.3803,0);
					obj["FUEL-Pump-Left-1-Square"].setColorFill(0.7333,0.3803,0);
					obj["FUEL-Pump-Left-1"].setColorFill(0.7333,0.3803,0);
					obj["FUEL-Pump-Left-1-Open"].setColorFill(0.7333,0.3803,0);
					obj["FUEL-Pump-Left-1-Closed"].setColorFill(0.7333,0.3803,0);
				}
			}),
			props.UpdateManager.FromHashValue("fuelLeftSwitch2", 1, func(val) {
				if (val) {
					obj["FUEL-Pump-Left-2-Open"].show();
					obj["FUEL-Pump-Left-2-Closed"].hide();
					obj["FUEL-Pump-Left-2"].setColor(0.0509,0.7529,0.2941);
					obj["FUEL-Pump-Left-2"].setColorFill(0.0509,0.7529,0.2941);
					obj["FUEL-Pump-Left-2-Square"].setColorFill(0.0509,0.7529,0.2941);
					obj["FUEL-Pump-Left-2-Open"].setColorFill(0.0509,0.7529,0.2941);
					obj["FUEL-Pump-Left-2-Closed"].setColorFill(0.0509,0.7529,0.2941);
				} else {
					obj["FUEL-Pump-Left-2-Open"].hide();
					obj["FUEL-Pump-Left-2-Closed"].show();
					obj["FUEL-Pump-Left-2"].setColor(0.7333,0.3803,0);
					obj["FUEL-Pump-Left-2"].setColorFill(0.7333,0.3803,0);
					obj["FUEL-Pump-Left-2-Square"].setColorFill(0.7333,0.3803,0);
					obj["FUEL-Pump-Left-2-Open"].setColorFill(0.7333,0.3803,0);
					obj["FUEL-Pump-Left-2-Closed"].setColorFill(0.7333,0.3803,0);
				}
			}),
			props.UpdateManager.FromHashValue("fuelCenterSwitch1", 1, func(val) {
				if (val) {
					obj["FUEL-Pump-Center-1-Open"].show();
					obj["FUEL-Pump-Center-1-Closed"].hide();
					obj["FUEL-Pump-Center-1"].setColor(0.0509,0.7529,0.2941);
					obj["FUEL-Pump-Center-1"].setColorFill(0.0509,0.7529,0.2941);
					obj["FUEL-Pump-Center-1-Square"].setColorFill(0.0509,0.7529,0.2941);
					obj["FUEL-Pump-Center-1-Open"].setColorFill(0.0509,0.7529,0.2941);
					obj["FUEL-Pump-Center-1-Closed"].setColorFill(0.0509,0.7529,0.2941);
				} else {
					obj["FUEL-Pump-Center-1-Open"].hide();
					obj["FUEL-Pump-Center-1-Closed"].show();
					obj["FUEL-Pump-Center-1"].setColor(0.7333,0.3803,0);
					obj["FUEL-Pump-Center-1"].setColorFill(0.7333,0.3803,0);
					obj["FUEL-Pump-Center-1-Square"].setColorFill(0.7333,0.3803,0);
					obj["FUEL-Pump-Center-1-Open"].setColorFill(0.7333,0.3803,0);
					obj["FUEL-Pump-Center-1-Closed"].setColorFill(0.7333,0.3803,0);
				}
			}),
			props.UpdateManager.FromHashValue("fuelCenterSwitch2", 1, func(val) {
				if (val) {
					obj["FUEL-Pump-Center-2-Open"].show();
					obj["FUEL-Pump-Center-2-Closed"].hide();
					obj["FUEL-Pump-Center-2"].setColor(0.0509,0.7529,0.2941);
					obj["FUEL-Pump-Center-2"].setColorFill(0.0509,0.7529,0.2941);
					obj["FUEL-Pump-Center-2-Square"].setColorFill(0.0509,0.7529,0.2941);
					obj["FUEL-Pump-Center-2-Open"].setColorFill(0.0509,0.7529,0.2941);
					obj["FUEL-Pump-Center-2-Closed"].setColorFill(0.0509,0.7529,0.2941);
				} else {
					obj["FUEL-Pump-Center-2-Open"].hide();
					obj["FUEL-Pump-Center-2-Closed"].show();
					obj["FUEL-Pump-Center-2"].setColor(0.7333,0.3803,0);
					obj["FUEL-Pump-Center-2"].setColorFill(0.7333,0.3803,0);
					obj["FUEL-Pump-Center-2-Square"].setColorFill(0.7333,0.3803,0);
					obj["FUEL-Pump-Center-2-Open"].setColorFill(0.7333,0.3803,0);
					obj["FUEL-Pump-Center-2-Closed"].setColorFill(0.7333,0.3803,0);
				}
			}),
			props.UpdateManager.FromHashValue("fuelRightSwitch1", 1, func(val) {
				if (val) {
					obj["FUEL-Pump-Right-1-Open"].show();
					obj["FUEL-Pump-Right-1-Closed"].hide();
					obj["FUEL-Pump-Right-1"].setColor(0.0509,0.7529,0.2941);
					obj["FUEL-Pump-Right-1"].setColorFill(0.0509,0.7529,0.2941);
					obj["FUEL-Pump-Right-1-Square"].setColorFill(0.0509,0.7529,0.2941);
					obj["FUEL-Pump-Right-1-Open"].setColorFill(0.0509,0.7529,0.2941);
					obj["FUEL-Pump-Right-1-Closed"].setColorFill(0.0509,0.7529,0.2941);
				} else {
					obj["FUEL-Pump-Right-1-Open"].hide();
					obj["FUEL-Pump-Right-1-Closed"].show();
					obj["FUEL-Pump-Right-1"].setColor(0.7333,0.3803,0);
					obj["FUEL-Pump-Right-1"].setColorFill(0.7333,0.3803,0);
					obj["FUEL-Pump-Right-1-Square"].setColorFill(0.7333,0.3803,0);
					obj["FUEL-Pump-Right-1-Open"].setColorFill(0.7333,0.3803,0);
					obj["FUEL-Pump-Right-1-Closed"].setColorFill(0.7333,0.3803,0);
				}
			}),
			props.UpdateManager.FromHashValue("fuelRightSwitch2", 1, func(val) {
				if (val) {
					obj["FUEL-Pump-Right-2-Open"].show();
					obj["FUEL-Pump-Right-2-Closed"].hide();
					obj["FUEL-Pump-Right-2"].setColor(0.0509,0.7529,0.2941);
					obj["FUEL-Pump-Right-2"].setColorFill(0.0509,0.7529,0.2941);
					obj["FUEL-Pump-Right-2-Square"].setColor(0.0509,0.7529,0.2941);
					obj["FUEL-Pump-Right-2-Open"].setColorFill(0.0509,0.7529,0.2941);
					obj["FUEL-Pump-Right-2-Closed"].setColorFill(0.0509,0.7529,0.2941);
				} else {
					obj["FUEL-Pump-Right-2-Open"].hide();
					obj["FUEL-Pump-Right-2-Closed"].show();
					obj["FUEL-Pump-Right-2"].setColor(0.7333,0.3803,0);
					obj["FUEL-Pump-Right-2"].setColorFill(0.7333,0.3803,0);
					obj["FUEL-Pump-Right-2-Square"].setColor(0.7333,0.3803,0);
					obj["FUEL-Pump-Right-2-Open"].setColorFill(0.7333,0.3803,0);
					obj["FUEL-Pump-Right-2-Closed"].setColorFill(0.7333,0.3803,0);
				}
			}),
			props.UpdateManager.FromHashList(["fuelCenterSwitch1","fuelCenterSwitch2"], 1, func(val) {
				if (!val.fuelCenterSwitch1 and !val.fuelCenterSwitch2) {
					obj["FUEL-Center-blocked"].show();
				} else {
					obj["FUEL-Center-blocked"].hide();
				}
			}),
			props.UpdateManager.FromHashList(["fuelCrossfeedValve","fuelCrossfeedSwitch"], 0.1, func(val) {
				if (val.fuelCrossfeedValve >= 0.9) {
					obj["FUEL-XFEED"].setRotation(0);
					obj["FUEL-XFEED-pipes"].show();
					if (val.fuelCrossfeedSwitch) {
						obj["FUEL-XFEED"].setColor(0.0509,0.7529,0.2941);
						obj["FUEL-XFEED"].setColorFill(0.0509,0.7529,0.2941);
						obj["FUEL-XFEED-Cross"].setColorFill(0.0509,0.7529,0.2941);
					} else {
						obj["FUEL-XFEED"].setColor(0.7333,0.3803,0);
						obj["FUEL-XFEED"].setColorFill(0.7333,0.3803,0);
						obj["FUEL-XFEED-Cross"].setColorFill(0.7333,0.3803,0);
					}
				} elsif (val.fuelCrossfeedValve <= 0.1) {
					obj["FUEL-XFEED"].setRotation(90 * D2R);
					obj["FUEL-XFEED-pipes"].hide();
					if (!val.fuelCrossfeedSwitch) {
						obj["FUEL-XFEED"].setColor(0.0509,0.7529,0.2941);
						obj["FUEL-XFEED"].setColorFill(0.0509,0.7529,0.2941);
						obj["FUEL-XFEED-Cross"].setColorFill(0.0509,0.7529,0.2941);
					} else {
						obj["FUEL-XFEED"].setColor(0.7333,0.3803,0);
						obj["FUEL-XFEED"].setColorFill(0.7333,0.3803,0);
						obj["FUEL-XFEED-Cross"].setColorFill(0.7333,0.3803,0);
					}
				} else {
					obj["FUEL-XFEED"].setRotation(45 * D2R);
					obj["FUEL-XFEED-pipes"].hide();
					obj["FUEL-XFEED"].setColor(0.7333,0.3803,0);
					obj["FUEL-XFEED"].setColorFill(0.7333,0.3803,0);
					obj["FUEL-XFEED-Cross"].setColorFill(0.7333,0.3803,0);
				}
			}),
			props.UpdateManager.FromHashList(["fuelEngine1Valve","engineCutoff1"], 0.1, func(val) {
				if (val.fuelEngine1Valve > 0.1) {
					if (val.fuelEngine1Valve >= 0.9) {
						obj["FUEL-ENG-Master-1"].setRotation(0);
					} else {
						obj["FUEL-ENG-Master-1"].setRotation(45 * D2R);
					}
					if (val.engineCutoff1) {
						obj["FUEL-ENG-Master-1"].setColor(0.7333,0.3803,0);
						obj["FUEL-ENG-Master-1"].setColorFill(0.7333,0.3803,0);
						obj["FUEL-ENG-Master-1-Cross"].setColorFill(0.7333,0.3803,0);
						obj["FUEL-ENG-1-pipe"].setColorFill(0.7333,0.3803,0);
						obj["FUEL-ENG-1-pipe"].setColorFill(0.7333,0.3803,0);
					} else {
						obj["FUEL-ENG-Master-1"].setColor(0.0509,0.7529,0.2941);
						obj["FUEL-ENG-Master-1"].setColorFill(0.0509,0.7529,0.2941);
						obj["FUEL-ENG-Master-1-Cross"].setColorFill(0.0509,0.7529,0.2941);
						obj["FUEL-ENG-1-pipe"].setColor(0.0509,0.7529,0.2941);
						obj["FUEL-ENG-1-pipe"].setColorFill(0.0509,0.7529,0.2941);
					}
				} else {
					obj["FUEL-ENG-Master-1"].setRotation(90 * D2R);
					obj["FUEL-ENG-Master-1"].setColor(0.7333,0.3803,0);
					obj["FUEL-ENG-Master-1"].setColorFill(0.7333,0.3803,0);
					obj["FUEL-ENG-Master-1-Cross"].setColorFill(0.7333,0.3803,0);
					obj["FUEL-ENG-1-pipe"].setColor(0.7333,0.3803,0);
					obj["FUEL-ENG-1-pipe"].setColorFill(0.7333,0.3803,0);
				}
			}),
			props.UpdateManager.FromHashList(["fuelEngine2Valve","engineCutoff2"], 0.1, func(val) {
				if (val.fuelEngine2Valve > 0.1) {
					if (val.fuelEngine2Valve >= 0.9) {
						obj["FUEL-ENG-Master-2"].setRotation(0);
					} else {
						obj["FUEL-ENG-Master-2"].setRotation(45 * D2R);
					}
					if (val.engineCutoff2) {
						obj["FUEL-ENG-Master-2"].setColor(0.7333,0.3803,0);
						obj["FUEL-ENG-Master-2"].setColorFill(0.7333,0.3803,0);
						obj["FUEL-ENG-Master-2-Cross"].setColorFill(0.7333,0.3803,0);
						obj["FUEL-ENG-2-pipe"].setColorFill(0.7333,0.3803,0);
						obj["FUEL-ENG-2-pipe"].setColorFill(0.7333,0.3803,0);
					} else {
						obj["FUEL-ENG-Master-2"].setColor(0.0509,0.7529,0.2941);
						obj["FUEL-ENG-Master-2"].setColorFill(0.0509,0.7529,0.2941);
						obj["FUEL-ENG-Master-2-Cross"].setColorFill(0.0509,0.7529,0.2941);
						obj["FUEL-ENG-2-pipe"].setColor(0.0509,0.7529,0.2941);
						obj["FUEL-ENG-2-pipe"].setColorFill(0.0509,0.7529,0.2941);
					}
				} else {
					obj["FUEL-ENG-Master-2"].setRotation(90 * D2R);
					obj["FUEL-ENG-Master-2"].setColor(0.7333,0.3803,0);
					obj["FUEL-ENG-Master-2"].setColorFill(0.7333,0.3803,0);
					obj["FUEL-ENG-Master-2-Cross"].setColorFill(0.7333,0.3803,0);
					obj["FUEL-ENG-2-pipe"].setColor(0.7333,0.3803,0);
					obj["FUEL-ENG-2-pipe"].setColorFill(0.7333,0.3803,0);
				}
			}),
			props.UpdateManager.FromHashValue("fuelTransferValve1", 0.1, func(val) {
				if (val <= 0.1) {
					obj["FUEL-Left-Transfer"].hide();
				} else {
					if (val >= 0.9) {
						obj["FUEL-Left-Transfer"].setColor(0.0509,0.7529,0.2941);
					} else {
						obj["FUEL-Left-Transfer"].setColor(0.7333,0.3803,0);
					}
					obj["FUEL-Left-Transfer"].show();
				}
			}),
			props.UpdateManager.FromHashValue("fuelTransferValve2", 0.1, func(val) {
				if (val <= 0.1) {
					obj["FUEL-Right-Transfer"].hide();
				} else {
					if (val >= 0.9) {
						obj["FUEL-Right-Transfer"].setColor(0.0509,0.7529,0.2941);
					} else {
						obj["FUEL-Right-Transfer"].setColor(0.7333,0.3803,0);
					}
					obj["FUEL-Right-Transfer"].show();
				}
			}),
			props.UpdateManager.FromHashList(["fuelTotalLbs","acconfigUnits"], 1, func(val) {
				if (val.acconfigUnits) {
					obj["FUEL-On-Board"].setText(sprintf("%s", math.round(val.fuelTotalLbs * LBS2KGS, 10)));
				} else {
					obj["FUEL-On-Board"].setText(sprintf("%s", math.round(val.fuelTotalLbs, 10)));
				}
			}),
			props.UpdateManager.FromHashValue("fuelTempLeftOuter", 0.5, func(val) {
				obj["FUEL-Left-Outer-temp"].setText(sprintf("%s", math.round(val)));
				if (val > 55 or val < -40) {
					obj["FUEL-Left-Outer-temp"].setColor(0.7333,0.3803,0);
				} else {
					obj["FUEL-Left-Outer-temp"].setColor(0.0509,0.7529,0.2941);
				}
			}),
			props.UpdateManager.FromHashValue("fuelTempLeftInner", 0.5, func(val) {
				obj["FUEL-Left-Inner-temp"].setText(sprintf("%s", math.round(val)));
				if (val > 45 or val < -40) {
					obj["FUEL-Left-Inner-temp"].setColor(0.7333,0.3803,0);
				} else {
					obj["FUEL-Left-Inner-temp"].setColor(0.0509,0.7529,0.2941);
				}
			}),
			props.UpdateManager.FromHashValue("fuelTempRightInner", 0.5, func(val) {
				obj["FUEL-Right-Inner-temp"].setText(sprintf("%s", math.round(val)));
				if (val > 45 or val < -40) {
					obj["FUEL-Right-Inner-temp"].setColor(0.7333,0.3803,0);
				} else {
					obj["FUEL-Right-Inner-temp"].setColor(0.0509,0.7529,0.2941);
				}
			}),
			props.UpdateManager.FromHashValue("fuelTempRightOuter", 0.5, func(val) {
				obj["FUEL-Right-Outer-temp"].setText(sprintf("%s", math.round(val)));
				if (val > 55 or val < -40) {
					obj["FUEL-Right-Outer-temp"].setColor(0.7333,0.3803,0);
				} else {
					obj["FUEL-Right-Outer-temp"].setColor(0.0509,0.7529,0.2941);
				}
			}),
			props.UpdateManager.FromHashList(["fuelApuValve","apuMaster","apuFireBtn"], nil, func(val) {
				if (val.fuelApuValve == 0) {
					if (val.apuMaster or val.apuFireBtn) {
						obj["FUEL-APU-label"].setColor(0.7333,0.3803,0);
						obj["FUEL-APU-line"].hide();
						obj["FUEL-APU-arrow"].hide();
					} else {
						obj["FUEL-APU-label"].setColor(0.8078, 0.8039, 0.8078);
						obj["FUEL-APU-arrow"].setColor(0.8078, 0.8039, 0.8078);
						obj["FUEL-APU-line"].hide();
						obj["FUEL-APU-arrow"].show();
					}
				} else {
					if (!val.apuMaster or val.apuFireBtn) {
						obj["FUEL-APU-label"].setColor(0.7333,0.3803,0);
						obj["FUEL-APU-line"].setColor(0.7333,0.3803,0);
						obj["FUEL-APU-line"].setColorFill(0.7333,0.3803,0);
						obj["FUEL-APU-arrow"].setColor(0.7333,0.3803,0);
						obj["FUEL-APU-line"].show();
						obj["FUEL-APU-arrow"].show();
					} else {
						obj["FUEL-APU-label"].setColor(0.8078, 0.8039, 0.8078);
						obj["FUEL-APU-line"].setColor(0.0509,0.7529,0.2941);
						obj["FUEL-APU-arrow"].setColor(0.0509,0.7529,0.2941);
						obj["FUEL-APU-line"].show();
						obj["FUEL-APU-arrow"].show();
					}
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
		return["TAT","SAT","GW","UTCh","UTCm","GLoad","GW-weight-unit","FUEL-Pump-Left-1","FUEL-Pump-Left-2","FUEL-Pump-Center-1","FUEL-Pump-Center-2","FUEL-Pump-Right-1","FUEL-Pump-Right-2","FUEL-Left-blocked","FUEL-Right-blocked","FUEL-Center-blocked","FUEL-Left-Transfer",
		"FUEL-Right-Transfer","FUEL-Left-Outer-Inacc","FUEL-Left-Inner-Inacc","FUEL-Center-Inacc","FUEL-Right-Inner-Inacc","FUEL-Right-Outer-Inacc","FUEL-Left-Outer-quantity","FUEL-Left-Inner-quantity","FUEL-Center-quantity","FUEL-Right-Inner-quantity",
		"FUEL-Right-Outer-quantity","FUEL-On-Board","FUEL-Flow-per-min","FUEL-APU-arrow","FUEL-APU-line","FUEL-APU-label","FUEL-used-1","FUEL-used-both","FUEL-used-2","FUEL-ENG-Master-1","FUEL-ENG-Master-2","FUEL-XFEED","FUEL-XFEED-Cross","FUEL-XFEED-pipes","FUEL-Left-Outer-temp",
		"FUEL-Left-Inner-temp","FUEL-Right-Inner-temp","FUEL-Right-Outer-temp","FUEL-Pump-Left-1-Closed","FUEL-Pump-Left-1-Open","FUEL-Pump-Left-2-Closed","FUEL-Pump-Left-2-Open","FUEL-Pump-Center-1-Open","FUEL-Pump-Center-1-Closed","FUEL-Pump-Center-2-Closed",
		"FUEL-Pump-Center-2-Open","FUEL-Pump-Right-1-Closed","FUEL-Pump-Right-1-Open","FUEL-Pump-Right-2-Closed","FUEL-Pump-Right-2-Open","FUEL-ENG-1-label","FUEL-ENG-2-label","FUEL-ENG-1-pipe","FUEL-ENG-2-pipe","ENG1idFFlow","ENG2idFFlow","FUEL-used-1","FUEL-used-2","FUEL-used-both",
		"Fused-weight-unit","FFlow-weight-unit","FOB-weight-unit","FUEL-ENG-Master-1-Cross","FUEL-ENG-Master-2-Cross","FUEL-Pump-Left-1-Square","FUEL-Pump-Left-2-Square","FUEL-Pump-Center-1-Square","FUEL-Pump-Center-2-Square","FUEL-Pump-Right-1-Square","FUEL-Pump-Right-2-Square"];
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
		
		if (notification.fadecPower1 or notification.fadecPower2 or notification.fadecPowerStart) {
			me["FUEL-Flow-per-min"].setColor(0.0509,0.7529,0.2941);
			me["FUEL-Flow-per-min"].setText(me.fuelFlowPerMinute);
		} else {
			me["FUEL-Flow-per-min"].setColor(0.7333,0.3803,0);
			me["FUEL-Flow-per-min"].setText("XX");
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
	engineCutoff1: "/controls/engines/engine[0]/cutoff-switch",
	engineCutoff2: "/controls/engines/engine[1]/cutoff-switch",
	fuelApuValve: "/systems/fuel/valves/apu-lp-valve",
	fuelCrossfeedSwitch: "/controls/fuel/switches/crossfeed",
	fuelCrossfeedValve: "/systems/fuel/valves/crossfeed-valve",
	fuelEngine1Valve: "/systems/fuel/valves/engine-1-lp-valve",
	fuelEngine2Valve: "/systems/fuel/valves/engine-2-lp-valve",
	fuelTransferValve1: "/systems/fuel/valves/outer-inner-transfer-valve-1",
	fuelTransferValve2: "/systems/fuel/valves/outer-inner-transfer-valve-2",
	fuelLeftSwitch1: "/controls/fuel/switches/pump-left-1",
	fuelLeftSwitch2: "/controls/fuel/switches/pump-left-2",
	fuelCenterSwitch1: "/controls/fuel/switches/pump-center-1",
	fuelCenterSwitch2: "/controls/fuel/switches/pump-center-2",
	fuelRightSwitch1: "/controls/fuel/switches/pump-right-1",
	fuelRightSwitch2: "/controls/fuel/switches/pump-right-2",
	fuelTempLeftOuter: "/consumables/fuel/tank[0]/temperature_degC",
	fuelTempLeftInner: "/consumables/fuel/tank[1]/temperature_degC",
	fuelTempRightOuter: "/consumables/fuel/tank[4]/temperature_degC",
	fuelTempRightInner: "/consumables/fuel/tank[3]/temperature_degC",
	fuelLeftOuterQty: "/consumables/fuel/tank[0]/level-lbs",
	fuelLeftInnerQty: "/consumables/fuel/tank[1]/level-lbs",
	fuelRightOuterQty: "/consumables/fuel/tank[4]/level-lbs",
	fuelRightInnerQty: "/consumables/fuel/tank[3]/level-lbs",
	fuelCenterQty: "/consumables/fuel/tank[2]/level-lbs",
	fuelTotalLbs: "/consumables/fuel/total-fuel-lbs",
};

foreach (var name; keys(input)) {
	emesary.GlobalTransmitter.NotifyAll(notifications.FrameNotificationAddProperty.new("A320 System Display", name, input[name]));
}