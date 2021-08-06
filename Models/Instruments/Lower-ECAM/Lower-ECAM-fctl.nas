# A3XX Lower ECAM Canvas
# Copyright (c) 2021 Josh Davidson (Octal450) and Jonathan Redpath

var canvas_lowerECAMPageFctl =
{
	new: func(svg,name) {
		var obj = {parents: [canvas_lowerECAMPageFctl,canvas_lowerECAM_base] };
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
		
		obj.update_items = [
			props.UpdateManager.FromHashList(["green","elac1","elac2","sec2"], nil, func(val) {
				if (val.green >= 1450) {
					if (val.elac2 or val.sec2) {
						obj["elevLgreen"].setColor(0.0509,0.7529,0.2941);
					} else {
						obj["elevLgreen"].setColor(0.7333,0.3803,0);
					}
					
					if (val.elac2) {
						obj["ailLgreen"].setColor(0.0509,0.7529,0.2941);
					} else {
						obj["ailLgreen"].setColor(0.7333,0.3803,0);
					}
					if (val.elac1) {
						obj["ailRgreen"].setColor(0.0509,0.7529,0.2941);
					} else {
						obj["ailRgreen"].setColor(0.7333,0.3803,0);
					}
					obj["ruddergreen"].setColor(0.0509,0.7529,0.2941);
					obj["PTgreen"].setColor(0.0509,0.7529,0.2941);
					obj["spdbrkgreen"].setColor(0.0509,0.7529,0.2941);
				} else {
					obj["ailLgreen"].setColor(0.7333,0.3803,0);
					obj["ailRgreen"].setColor(0.7333,0.3803,0);
					obj["elevLgreen"].setColor(0.7333,0.3803,0);
					obj["ruddergreen"].setColor(0.7333,0.3803,0);
					obj["PTgreen"].setColor(0.7333,0.3803,0);
					obj["spdbrkgreen"].setColor(0.7333,0.3803,0);
				}
			}),
			props.UpdateManager.FromHashList(["yellow","elac2","sec2"], nil, func(val) {
				if (val.yellow >= 1450) {
					if (val.elac2 or val.sec2) {
						obj["elevRyellow"].setColor(0.0509,0.7529,0.2941);
					} else {
						obj["elevRyellow"].setColor(0.7333,0.3803,0);
					}
					obj["rudderyellow"].setColor(0.0509,0.7529,0.2941);
					obj["PTyellow"].setColor(0.0509,0.7529,0.2941);
					obj["spdbrkyellow"].setColor(0.0509,0.7529,0.2941);
				} else {
					obj["elevRyellow"].setColor(0.7333,0.3803,0);
					obj["rudderyellow"].setColor(0.7333,0.3803,0);
					obj["PTyellow"].setColor(0.7333,0.3803,0);
					obj["spdbrkyellow"].setColor(0.7333,0.3803,0);
				}
			}),
			props.UpdateManager.FromHashList(["blue","elac1","elac2","sec1"], nil, func(val) {
				if (val.blue >= 1500) {
					if (val.elac1) {
						obj["ailLblue"].setColor(0.0509,0.7529,0.2941);
					} else {
						obj["ailLblue"].setColor(0.7333,0.3803,0);
					}
					if (val.elac1 or val.sec1) {
						obj["elevLblue"].setColor(0.0509,0.7529,0.2941);
						obj["elevRblue"].setColor(0.0509,0.7529,0.2941);
					} else {
						obj["elevLblue"].setColor(0.7333,0.3803,0);
						obj["elevRblue"].setColor(0.7333,0.3803,0);
					}
					if (val.elac2) {
						obj["ailRblue"].setColor(0.0509,0.7529,0.2941);
					} else {
						obj["ailRblue"].setColor(0.7333,0.3803,0);
					}
					obj["rudderblue"].setColor(0.0509,0.7529,0.2941);
					obj["spdbrkblue"].setColor(0.0509,0.7529,0.2941);
				} else {
					obj["ailLblue"].setColor(0.7333,0.3803,0);
					obj["ailRblue"].setColor(0.7333,0.3803,0);
					obj["elevLblue"].setColor(0.7333,0.3803,0);
					obj["elevRblue"].setColor(0.7333,0.3803,0);
					obj["rudderblue"].setColor(0.7333,0.3803,0);
					obj["spdbrkblue"].setColor(0.7333,0.3803,0);
				}
			}),
			props.UpdateManager.FromHashValue("fctlAilL", 0.001, func(val) {
				obj["ailL"].setTranslation(0, val * 100);
			}),
			props.UpdateManager.FromHashValue("fctlAilR", 0.001, func(val) {
				obj["ailR"].setTranslation(0, val * -100);
			}),
			props.UpdateManager.FromHashList(["blue","green","elac1","elac2"], nil, func(val) {
				if ((val.blue < 1500 or !val.elac1) and (val.green < 1500 or !val.elac2)) {
					obj["ailL"].setColor(0.7333,0.3803,0);
				} else {
					obj["ailL"].setColor(0.0509,0.7529,0.2941);
				}
				if ((val.green < 1500 or !val.elac1) and (val.blue < 1500 or !val.elac2)) {
					obj["ailR"].setColor(0.7333,0.3803,0);
				} else {
					obj["ailR"].setColor(0.0509,0.7529,0.2941);
				}
			}),
			props.UpdateManager.FromHashValue("fctlElevL", 0.001, func(val) {
				obj["elevL"].setTranslation(0, val * 100);
			}),
			props.UpdateManager.FromHashValue("fctlElevR", 0.001, func(val) {
				obj["elevR"].setTranslation(0, val * 100);
			}),
			props.UpdateManager.FromHashList(["blue","green","yellow","elac1","elac2","sec1","sec2"], nil, func(val) {
				if ((val.blue < 1500 or (!val.elac1 and !val.sec1)) and (val.green < 1500 or (!val.elac2 and !val.sec2))) {
					obj["elevL"].setColor(0.7333,0.3803,0);
				} else {
					obj["elevL"].setColor(0.0509,0.7529,0.2941);
				}

				if ((val.blue < 1500 or (!val.elac1 and !val.sec1)) and (val.yellow < 1500 or (!val.elac2 and !val.sec2))) {
					obj["elevR"].setColor(0.7333,0.3803,0);
				} else {
					obj["elevR"].setColor(0.0509,0.7529,0.2941);
				}
			}),
			props.UpdateManager.FromHashValue("fctlElevTrim", 0.01, func(val) {
				obj["PT"].setText(sprintf("%2.1f", val));
				if (val >= 0.09) {
					obj["PTupdn"].setText("UP");
					obj["PTupdn"].show();
				} elsif (val <= -0.09) {
					obj["PTupdn"].setText("DN");
					obj["PTupdn"].show();
				} else {
					obj["PTupdn"].hide();
				}
			}),
			props.UpdateManager.FromHashValue("elac1", nil, func(val) {
				if (val) {
					obj["elac1"].setColor(0.0509,0.7529,0.2941);
					obj["path4249"].setColor(0.0509,0.7529,0.2941);
				} else {
					obj["elac1"].setColor(0.7333,0.3803,0);
					obj["path4249"].setColor(0.7333,0.3803,0);
				}
			}),
			props.UpdateManager.FromHashValue("elac2", nil, func(val) {
				if (val) {
					obj["elac2"].setColor(0.0509,0.7529,0.2941);
					obj["path4249-3"].setColor(0.0509,0.7529,0.2941);
				} else {
					obj["elac2"].setColor(0.7333,0.3803,0);
					obj["path4249-3"].setColor(0.7333,0.3803,0);
				}
			}),
			props.UpdateManager.FromHashValue("sec1", nil, func(val) {
				if (val) {
					obj["sec1"].setColor(0.0509,0.7529,0.2941);
					obj["path4249-3-6-7"].setColor(0.0509,0.7529,0.2941);
				} else {
					obj["sec1"].setColor(0.7333,0.3803,0);
					obj["path4249-3-6-7"].setColor(0.7333,0.3803,0);
				}
			}),
			props.UpdateManager.FromHashValue("sec2", nil, func(val) {
				if (val) {
					obj["sec2"].setColor(0.0509,0.7529,0.2941);
					obj["path4249-3-6-7-5"].setColor(0.0509,0.7529,0.2941);
				} else {
					obj["sec2"].setColor(0.7333,0.3803,0);
					obj["path4249-3-6-7-5"].setColor(0.7333,0.3803,0);
				}
			}),
			props.UpdateManager.FromHashValue("sec3", nil, func(val) {
				if (val) {
					obj["sec3"].setColor(0.0509,0.7529,0.2941);
					obj["path4249-3-6"].setColor(0.0509,0.7529,0.2941);
				} else {
					obj["sec3"].setColor(0.7333,0.3803,0);
					obj["path4249-3-6"].setColor(0.7333,0.3803,0);
				}
			}),
			props.UpdateManager.FromHashList(["blue","yellow","green"], 25, func(val) {
				if (val.green < 1500 and val.yellow < 1500) {
					obj["PT"].setColor(0.7333,0.3803,0);
					obj["PTupdn"].setColor(0.7333,0.3803,0);
					obj["PTcc"].setColor(0.7333,0.3803,0);
				} else {
					obj["PT"].setColor(0.0509,0.7529,0.2941);
					obj["PTupdn"].setColor(0.0509,0.7529,0.2941);
					obj["PTcc"].setColor(0.0901,0.6039,0.7176);
				}
				
				if (val.blue < 1500 and val.yellow < 1500 and val.green < 1500) {
					obj["rudder"].setColor(0.7333,0.3803,0);
				} else {
					obj["rudder"].setColor(0.0509,0.7529,0.2941);
				}
			}),
			props.UpdateManager.FromHashValue("fctlRudder", 0.001, func(val) {
				obj["rudder"].setRotation(val * -0.024);
			}),
			props.UpdateManager.FromHashValue("fctlRudderTrim", 0.01, func(val) {
				obj["rudderTrimInd"].setRotation(val * -0.024);
			}),
			props.UpdateManager.FromHashValue("fctlTHSJam", nil, func(val) {
				if (val) {
					obj["pitchTrimStatus"].setColor(0.7333,0.3803,0);
				} else {
					obj["pitchTrimStatus"].setColor(0.8078,0.8039,0.8078);
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
		return["ailL","ailR","elevL","elevR","PTcc","PT","PTupdn","elac1","elac2","sec1","sec2","sec3","ailLblue","ailRblue","elevLblue","elevRblue","rudderblue","ailLgreen","ailRgreen","elevLgreen","ruddergreen","PTgreen",
		"elevRyellow","rudderyellow","PTyellow","rudder","spdbrkblue","spdbrkgreen","spdbrkyellow","spoiler1Rex","spoiler1Rrt","spoiler2Rex","spoiler2Rrt","spoiler3Rex","spoiler3Rrt","spoiler4Rex","spoiler4Rrt","spoiler5Rex","spoiler5Rrt","spoiler1Lex",
		"spoiler1Lrt","spoiler2Lex","spoiler2Lrt","spoiler3Lex","spoiler3Lrt","spoiler4Lex","spoiler4Lrt","spoiler5Lex","spoiler5Lrt","spoiler1Rf","spoiler2Rf","spoiler3Rf","spoiler4Rf","spoiler5Rf","spoiler1Lf","spoiler2Lf","spoiler3Lf","spoiler4Lf",
		"spoiler5Lf","ailLscale","ailRscale","path4249","path4249-3","path4249-3-6-7","path4249-3-6-7-5","path4249-3-6","pitchTrimStatus","rudderTrimInd"];
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
	elac1: "/systems/fctl/elac1",
	elac2: "/systems/fctl/elac2",
	elac1Fail: "/systems/failures/fctl/elac1",
	elac2Fail: "/systems/failures/fctl/elac2",
	sec1: "/systems/fctl/sec1",
	sec2: "/systems/fctl/sec2",
	sec3: "/systems/fctl/sec3",
	sec1Fail: "/systems/failures/fctl/sec1",
	sec2Fail: "/systems/failures/fctl/sec2",
	sec3Fail: "/systems/failures/fctl/sec3",
	fac1: "/systems/fctl/fac1-healthy-signal",
	fac2: "/systems/fctl/fac2-healthy-signal",
	fac1Fail: "/systems/failures/fctl/fac1",
	fac2Fail: "/systems/failures/fctl/fac2",
	fctlAilL: "/ECAM/Lower/aileron-ind-left",
	fctlAilR: "/ECAM/Lower/aileron-ind-right",
	fctlElevL: "/ECAM/Lower/elevator-ind-left",
	fctlElevR: "/ECAM/Lower/elevator-ind-right",
	fctlElevTrim: "/ECAM/Lower/elevator-trim-deg",
	fctlRudder: "/fdm/jsbsim/hydraulics/rudder/final-deg",
	fctlRudderTrim: "/fdm/jsbsim/hydraulics/rudder/trim-deg",
	fctlTHSJam: "/systems/failures/fctl/ths-jam",
};

foreach (var name; keys(input)) {
	emesary.GlobalTransmitter.NotifyAll(notifications.FrameNotificationAddProperty.new("A320 System Display", name, input[name]));
}