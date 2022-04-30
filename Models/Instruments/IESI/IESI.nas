# A3XX IESI

# Copyright (c) 2020 Josh Davidson (Octal450)

# props.nas nodes
var iesi_init = props.globals.initNode("/instrumentation/iesi/iesi-init", 0, "BOOL");

var pinPrograms = {
	metricAltitude: 1,
	showInHg: 1,
};

var canvas_IESI = {
	new: func(svg, name) {
		var obj = {parents: [canvas_IESI] };
		obj.canvas = canvas.new({
			"name": "IESI",
			"size": [1024, 1024],
			"view": [1024, 1024],
			"mipmapping": 1,
		});
		
		obj.canvas.addPlacement({"node": "iesi.screen"});
        obj.group = obj.canvas.createGroup();
		
		obj.font_mapper = func(family, weight) {
			return "ECAMFontRegular.ttf";
		};
		
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
		
		obj.AI_horizon_trans = obj["AI_horizon"].createTransform();
		obj.AI_horizon_rot = obj["AI_horizon"].createTransform();
		
		obj._aiCenter = obj["AI_center"].getCenter();
		
		obj._cachedInhg = -999;
		obj._cachedMetric = pinPrograms.metricAltitude;
		obj._cachedMode = nil;
		obj._cachedShowInhg = pinPrograms.showInHg;
		obj._canReset = 0;
		obj._excessMotionInInit = 0;
		obj._fastInit = 0;
		obj._IESITime = 0;
		obj._isNegativeAlt = 0;
		obj._middleAltOffset = nil;
		obj.iesiInAlign = 0;
		
		
		obj["IESI"].hide(); 
		obj["IESI_Init"].show();
		obj["ATTflag"].hide();
		
		obj.update_items = [
			props.UpdateManager.FromHashValue("airspeedIESI", 0.1, func(val) {
				obj["ASI_scale"].setTranslation(0, math.clamp(val - 30, 0, 490) * 8.295);
			}),
			props.UpdateManager.FromHashValue("altitudeIESI", 0.5, func(val) {
				val = math.clamp(val, -2000, 50000);
				
				obj["ALT_meters"].setText(sprintf("%5.0f", math.round(val * 0.3048, 10)));
				
				obj.middleAltText = roundaboutAlt(val / 100);
				
				obj["ALT_five"].setText(sprintf("%03d", abs(obj.middleAltText + 10)));
				obj["ALT_four"].setText(sprintf("%03d", abs(obj.middleAltText + 5)));
				obj["ALT_three"].setText(sprintf("%03d", abs(obj.middleAltText)));
				obj["ALT_two"].setText(sprintf("%03d", abs(obj.middleAltText - 5)));
				obj["ALT_one"].setText(sprintf("%03d", abs(obj.middleAltText - 10)));
				
				if (val < 0) {
					obj["negText"].show();
					obj._isNegativeAlt = 1;
				} else {
					obj["negText"].hide();
					obj._isNegativeAlt = 0;
				}
			}),
			props.UpdateManager.FromHashValue("altitudeIESI", 0.1, func(val) {
				val = math.clamp(val, -2000, 50000);
				
				obj.altOffset = (val / 500) - int(val / 500);
				
				if (obj.altOffset > 0.5) {
					obj._middleAltOffset = -(obj.altOffset - 1) * 258.5528;
				} else {
					obj._middleAltOffset = -obj.altOffset * 258.5528;
				}
				
				obj["ALT_scale"].setTranslation(0, -obj._middleAltOffset);
				obj["ALT_scale"].update();
				
				obj["ALT_tens"].setTranslation(0, num(right(sprintf("%02d", val), 2)) * 3.16);
			}),
			props.UpdateManager.FromHashValue("altitude_indIESI", 0.5, func(val) {
				obj["ALT_digits"].setText(sprintf("%s", math.clamp(val, -20, 500)));
			}),
			props.UpdateManager.FromHashValue("showMach", 1, func(val) {
				if (val) {
					obj["ASI_mach_decimal"].show();
					obj["ASI_mach"].show();
				} else {
					obj["ASI_mach_decimal"].hide();
					obj["ASI_mach"].hide();
				}
			}),
			props.UpdateManager.FromHashValue("mach", 0.001, func(val) {
				obj["ASI_mach"].setText(sprintf("%2.0f", math.clamp(val * 100, 0, 99)));
			}),
			props.UpdateManager.FromHashValue("iesiPitch", 0.025, func(val) {
				obj.AI_horizon_trans.setTranslation(0, val * 16.74);
			}),
			props.UpdateManager.FromHashValue("roll", 0.025, func(val) {
				obj.AI_horizon_rot.setRotation(-val * D2R, obj._aiCenter);
				obj["AI_bank"].setRotation(-val * D2R);
			}),
			props.UpdateManager.FromHashValue("skid", 0.1, func(val) {
				if (abs(val) >= 85) {
					obj["AI_slipskid"].hide();
				} else {
					obj["AI_slipskid"].setTranslation(-val, 0);
					obj["AI_slipskid"].show();
				}
			}),
		];
		
		obj.update_items_init = [
			props.UpdateManager.FromHashList(["iesiAlignTime","elapsedTime"], 0.5, func(val) {
				if (val.iesiAlignTime + 90 >= val.elapsedTime) {
					obj.iesiInAlign = 1;
				} else {
					obj.iesiInAlign = 0;
				}
			}),
			props.UpdateManager.FromHashList(["iesiInAlign","iesiFastInit","irAlignFault"], 1, func(val) {
				if (val.iesiInAlign) {
					if (!val.iesiFastInit and val.irAlignFault) {
						obj._excessMotionInInit = 1;
					}
				}
			}),
			props.UpdateManager.FromHashList(["iesiExcessMotion","iesiFastInit","iesiInAlign"], 1, func(val) {
				if (val.iesiInAlign) {
					if (val.iesiFastInit) {
						obj["IESI"].show(); 
						obj["IESI_Init"].hide();
						obj["AI_bank"].hide();
						obj["AI_bank_center"].hide();
						obj["AI_bank_scale"].hide();
						obj["AI_horizon"].hide();
						obj["AI_sky_bank"].hide();
						obj["ATTflag_text"].setText("ATT 10s");
						obj["ATTflag_text"].setColor(0,0,0);
						obj["ATTflag_rect"].setScale(1.5,1);
						obj["ATTflag_rect"].setTranslation(-250,0);
						obj["ATTflag_rect"].setColorFill(1,1,0);
						obj["ATTflag_rect"].setColor(1,1,0);
						obj["ATTflag"].show();
						obj["attRst"].hide();
						obj["attRstRect"].hide();
					} else {
						obj["IESI"].hide(); 
						obj["IESI_Init"].show();
						obj["ATTflag"].hide();
					}
				} else {
					if (!val.iesiExcessMotion) {
						obj["IESI_Init"].hide();
						obj["IESI"].show();
						obj["AI_bank"].show();
						obj["AI_bank_center"].show();
						obj["AI_bank_scale"].show();
						obj["AI_index"].show();
						obj["AI_horizon"].show();
						obj["AI_sky_bank"].show();
						obj["ATTflag"].hide();
					} else {
						obj["IESI_Init"].hide();
						obj["IESI"].show();
						obj["AI_bank"].hide();
						obj["AI_bank_center"].hide();
						obj["AI_bank_scale"].hide();
						obj["AI_horizon"].hide();
						obj["AI_sky_bank"].hide();
						obj["ATTflag_text"].setText("ATT");
						obj["ATTflag_text"].setColor(1,0,0);
						obj["ATTflag_rect"].setScale(1,1);
						obj["ATTflag_rect"].setTranslation(0,0);
						obj["ATTflag_rect"].setColorFill(0,0,0);
						obj["ATTflag_rect"].setColor(0,0,0);
						obj["ATTflag"].show();
						obj["attRst"].show();
						obj["attRstRect"].show();
					}
				}
			}),
		];
		
		obj.update_items_power = [
			props.UpdateManager.FromHashList(["iesiPowered","iesiBrt"], 0.005, func(val) {
				if (val.iesiPowered and val.iesiBrt > 0.01) {
					obj.group.setVisible(1);
				} else {
					obj.group.setVisible(0);
				}
			}),
			props.UpdateManager.FromHashList(["iesiPowered","acconfig","iesiInit"], 1, func(val) {
				if (val.iesiPowered) {
					if (val.iesiInit) return;
					obj.initIESI(val.acconfig);
				} elsif (val.iesiInit) {
					obj._canReset = 0;
					obj._excessMotionInInit = 0;
					obj._fastInit = 0;
					iesi_init.setBoolValue(0);
				}
			}),
		];
		return obj;
	},
	getKeys: func() {
		return ["IESI","IESI_Init","attRst","attRstRect","att90s","ATTflag","ATTflag_rect","ATTflag_text","ALTwarn","SPDwarn","ASI_scale","ASI_mach","ASI_mach_decimal","AI_center","AI_index","AI_horizon","AI_sky_bank","AI_bank","AI_bank_center","AI_slipskid","ALT_scale","ALT_one","ALT_two","ALT_three","ALT_four","ALT_five","ALT_digits","ALT_tens","ALT_meters","QNH_setting","QNH_std","negText","negText2","AI_bank_scale","metricM","metricBox"];
	},
	update: func(notification) {
		me.updatePower(notification);
		
		foreach(var update_item; me.update_items_power)
        {
            update_item.update(notification);
        }
		
		if (!me.group.getVisible()) { return; }
		
		notification.iesiAlignTime = me._IESITime;
		notification.iesiExcessMotion = me._excessMotionInInit;
		notification.iesiFastInit = me._fastInit;
		notification.iesiInAlign = me.iesiInAlign;
		
		foreach(var update_item; me.update_items_init)
        {
            update_item.update(notification);
        }
		
		if (math.abs(notification.qnh_inhg_iesi - me._cachedInhg) > 0.005 or notification.altimeter_mode_iesi != me._cachedMode or pinPrograms.showInHg != me._cachedShowInhg) {
			me._cachedInhg = notification.qnh_inhg_iesi;
			me._cachedMode = notification.altimeter_mode_iesi;
			me._cachedShowInhg = pinPrograms.showInHg;
			me.updateQNH(notification);
		}
		
		if (me.iesiInAlign and !me._fastInit) return;
		
		foreach(var update_item; me.update_items)
        {
            update_item.update(notification);
        }
		
		if (!me.iesiInAlign and pinPrograms.metricAltitude != me._cachedMetric) {
			me._cachedMetric = pinPrograms.metricAltitude;
			me.updateMetric(pinPrograms.metricAltitude);
		}
		
		if (pinPrograms.metricAltitude) {
			if (me._isNegativeAlt) {
				me["negText2"].show();
			} else {
				me["negText2"].hide();
			}
		}
	},
	updateMetric: func(val) {
		if (val) {
			me["ALT_meters"].show();
			me["metricM"].show();
			me["metricBox"].show();
		} else {
			me["ALT_meters"].hide();
			me["metricM"].hide();
			me["metricBox"].hide();
			me["negText2"].hide();
		}
	},
	updateQNH: func(notification) {
		if (notification.altimeter_mode_iesi) {
			me["QNH_setting"].hide();
			me["QNH_std"].show();
		} else {
			if (pinPrograms.showInHg) {
				me["QNH_setting"].setText(sprintf("%4.0f", notification.qnh_hpa_iesi) ~ "/" ~ sprintf("%2.2f", notification.qnh_inhg_iesi));
			} else {
				me["QNH_setting"].setText(sprintf("%4.0f", notification.qnh_hpa_iesi));
			}
			me["QNH_std"].hide();
			me["QNH_setting"].show();
		}
	},
	updatePower: func(notification) {
		if (notification.attReset == 1 and me._canReset) {
			me._canReset = 0;
			me._excessMotionInInit = 0;
			me._fastInit = 1;
			iesi_init.setBoolValue(0);
		} else if (me._IESITime + 90 < notification.elapsedTime and notification.iesiInit and !me._canReset) {
			me._canReset = 1;
		}
	},
	initIESI: func(acconfig) {
		iesi_init.setBoolValue(1);
		if (!acconfig) {
			me._IESITime = pts.Sim.Time.elapsedSec.getValue() - (me._fastInit ? 80 : 0);
		} else {
			me._IESITime = pts.Sim.Time.elapsedSec.getValue() - 87;
		}
	},
};

var IESIRecipient =
{
	new: func(_ident)
	{
		var NewIESIRecipient = emesary.Recipient.new(_ident);
		NewIESIRecipient.MainScreen = nil;
		NewIESIRecipient.Receive = func(notification)
		{
			if (notification.NotificationType == "FrameNotification")
			{
				if (NewIESIRecipient.MainScreen == nil) {
						NewIESIRecipient.MainScreen = canvas_IESI.new("Aircraft/A320-family/Models/Instruments/IESI/res/iesi.svg", "A320 IESI");
				}
				
				if (math.mod(notifications.frameNotification.FrameCount,2) == 0) {
					NewIESIRecipient.MainScreen.update(notification);
				}
				return emesary.Transmitter.ReceiptStatus_OK;
			}
			return emesary.Transmitter.ReceiptStatus_NotProcessed;
		};
		return NewIESIRecipient;
	},
};

var A320IESI = IESIRecipient.new("A320 IESI");
emesary.GlobalTransmitter.Register(A320IESI);

# Emesary Frame Notifiaction Properties
var input = {
	"acconfig": "/systems/acconfig/autoconfig-running",
	"airspeedIESI": "/instrumentation/airspeed-indicator[0]/indicated-speed-kt",
	"altitudeIESI": "/instrumentation/altimeter[6]/indicated-altitude-ft",
	"altitude_indIESI": "/instrumentation/altimeter[6]/indicated-altitude-ft-pfd",
	"altimeter_mode_iesi": "/instrumentation/altimeter[6]/std",
	"attReset": "/instrumentation/iesi/att-reset",
	"iesiBrt": "/controls/lighting/DU/iesi",
	"iesiInit": "/instrumentation/iesi/iesi-init",
	"iesiPitch": "/instrumentation/iesi/pitch-deg",
	"iesiPowered": "/instrumentation/iesi/power/power-on",
	"irAlignFault": "/systems/navigation/align-fault",
	"mach": "/instrumentation/airspeed-indicator/indicated-mach",
	"qnh_hpa_iesi": "/instrumentation/altimeter[6]/setting-hpa",
	"qnh_inhg_iesi": "/instrumentation/altimeter[6]/setting-inhg",
	"roll": "/orientation/roll-deg",
	"showMach": "/instrumentation/iesi/display/show-mach",
	"skid": "/instrumentation/iesi/slip-skid",
};

foreach (var name; keys(input)) {
	emesary.GlobalTransmitter.NotifyAll(notifications.FrameNotificationAddProperty.new("A320 IESI", name, input[name]));
}

# Helper functions
var showIESI = func {
	var dlg = canvas.Window.new([512, 512], "dialog").set("resize", 1);
	dlg.setCanvas(A320IESI.MainScreen.canvas);
}

var roundabout = func(x) {
	return (x - int(x)) < 0.5 ? int(x) : 1 + int(x);
};

var roundaboutAlt = func(x) {
	return (x * 0.2 - int(x * 0.2)) < 0.5 ? 5 * int(x * 0.2) : 5 + 5 * int(x * 0.2);
};