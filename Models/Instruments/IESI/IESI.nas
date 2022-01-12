# A3XX IESI

# Copyright (c) 2020 Josh Davidson (Octal450)

# props.nas nodes
var iesi_init = props.globals.initNode("/instrumentation/iesi/iesi-init", 0, "BOOL");
var iesi_reset = props.globals.initNode("/instrumentation/iesi/att-reset", 0, "DOUBLE");

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
		
		obj._cachedInhg = nil;
		obj._excessMotion = 0;
		obj._fast = 0;
		obj._IESITime = 0;
		obj._showIESI = 0;
		obj.ASI = 0;
		obj.canReset = 0;
		obj.isNegativeAlt = 0;
		obj.middleAltOffset = nil;
		
		obj.update_items = [
			props.UpdateManager.FromHashValue("airspeed", nil, func(val) {
				# Subtract 30, since the scale starts at 30, but don't allow less than 0, or more than 520 knots
				if (val <= 30) {
					obj.ASI = 0;
				} else if (val >= 520) {
					obj.ASI = 490;
				} else {
					obj.ASI = val - 30;
				}
				obj["ASI_scale"].setTranslation(0, obj.ASI * 8.295);
			}),
			props.UpdateManager.FromHashList(["altitude","altitude_ind"], nil, func(val) {
				if (val.altitude > 50000) {
					val.altitude = 50000;
				} elsif (val.altitude < -2000) {
					val.altitude = -2000;
				}
				
				if (val.altitude < 0) {
					obj["negText"].show();
					obj.isNegativeAlt = 1;
				} else {
					obj["negText"].hide();
					obj.isNegativeAlt = 0;
				}
				
				obj.altOffset = (val.altitude / 500) - int(val.altitude / 500);
				obj.middleAltText = roundaboutAlt(val.altitude / 100);
				if (obj.altOffset > 0.5) {
					obj.middleAltOffset = -(obj.altOffset - 1) * 258.5528;
				} else {
					obj.middleAltOffset = -obj.altOffset * 258.5528;
				}
				
				obj["ALT_scale"].setTranslation(0, -obj.middleAltOffset);
				obj["ALT_scale"].update();
				obj["ALT_five"].setText(sprintf("%03d", abs(obj.middleAltText+10)));
				obj["ALT_four"].setText(sprintf("%03d", abs(obj.middleAltText+5)));
				obj["ALT_three"].setText(sprintf("%03d", abs(obj.middleAltText)));
				obj["ALT_two"].setText(sprintf("%03d", abs(obj.middleAltText-5)));
				obj["ALT_one"].setText(sprintf("%03d", abs(obj.middleAltText-10)));
				
				
				if (val.altitude < 0 and val.altitude_ind > 20) {
					val.altitude_ind = 20;
				} elsif (val.altitude > 0 and val.altitude_ind > 500) {
					val.altitude_ind = 500;
				}
				
				obj["ALT_digits"].setText(sprintf("%s", val.altitude_ind));
				obj["ALT_meters"].setText(sprintf("%5.0f", math.round(val.altitude * 0.3048, 10)));
				obj.altTens = num(right(sprintf("%02d", val.altitude), 2));
				obj["ALT_tens"].setTranslation(0, obj.altTens * 3.16);
			}),
			props.UpdateManager.FromHashValue("mach", nil, func(val) {
				if (val >= 0.5) {
					obj._machWasAbove50 = 1;
					obj["ASI_mach_decimal"].show();
					obj["ASI_mach"].show();
				} elsif (val >= 0.45 and obj._machWasAbove50) {
					obj["ASI_mach_decimal"].show();
					obj["ASI_mach"].show();
				} else {
					obj._machWasAbove50 = 0;
					obj["ASI_mach_decimal"].hide();
					obj["ASI_mach"].hide();
				}
				
				if (val >= 0.999) {
					obj["ASI_mach"].setText("99");
				} else {
					obj["ASI_mach"].setText(sprintf("%2.0f", val * 100));
				}
			}),
			props.UpdateManager.FromHashValue("pitch", nil, func(val) {
				obj.AI_horizon_trans.setTranslation(0, val * 16.74);
			}),
			props.UpdateManager.FromHashValue("roll", nil, func(val) {
				obj.AI_horizon_rot.setRotation(-val * D2R, obj["AI_center"].getCenter());
				obj["AI_bank"].setRotation(-val * D2R);
			}),
			props.UpdateManager.FromHashValue("skid", nil, func(val) {
				if (abs(val) >= 84.99) {
					obj["AI_slipskid"].hide();
				} else {
					obj["AI_slipskid"].setTranslation(-val, 0);
					obj["AI_slipskid"].show();
				}
			}),
			props.UpdateManager.FromHashList(["altimeter_mode","qnh_hpa","qnh_inhg"], nil, func(val) {
				obj.updateQNH(val);
			}),
		];
		return obj;
	},	
	getKeys: func() {
		return ["IESI","IESI_Init","attRst","attRstRect","att90s","ATTflag","ATTflag_rect","ATTflag_text","ALTwarn","SPDwarn","ASI_scale","ASI_mach","ASI_mach_decimal","AI_center","AI_index","AI_horizon","AI_sky_bank","AI_bank","AI_bank_center","AI_slipskid","ALT_scale","ALT_one","ALT_two","ALT_three","ALT_four","ALT_five","ALT_digits","ALT_tens","ALT_meters","QNH_setting","QNH_std","negText","negText2","AI_bank_scale","metricM","metricBox"];
	},
	update: func(notification) {
		if (notification.qnh_inhg != me._cachedInhg) {
			me._cachedInhg = notification.qnh_inhg;
			me.updateQNH(notification);
		}
		
		me.updatePower(notification);
		if (me.group.getVisible() == 0) {
			return;
		}
		
		if (me._IESITime + 90 >= notification.elapsedTime) {
			if (notification.groundspeed > 2) {
				me._excessMotion = 1;
			}
			
			if (me._fast) {
				me["IESI"].show(); 
				me["IESI_Init"].hide();
				me["AI_bank"].hide();
				me["AI_bank_center"].hide();
				me["AI_bank_scale"].hide();
				me["AI_horizon"].hide();
				me["AI_sky_bank"].hide();
				me["ATTflag_text"].setText("ATT 10s");
				me["ATTflag_text"].setColor(0,0,0);
				me["ATTflag_rect"].setScale(1.5,1);
				me["ATTflag_rect"].setTranslation(-250,0);
				me["ATTflag_rect"].setColorFill(1,1,0);
				me["ATTflag_rect"].setColor(1,1,0);
				me["ATTflag"].show();
				me["attRst"].hide();
				me["attRstRect"].hide();
			} else {
				me["IESI"].hide(); 
				me["IESI_Init"].show();
				me["ATTflag"].hide();
			}
			return;
		} else {
			if (pinPrograms.metricAltitude) {
				me["ALT_meters"].show();
				me["metricM"].show();
				me["metricBox"].show();
				
				if (me.isNegativeAlt) {
					me["negText2"].show();
				} else {
					me["negText2"].hide();
				}
			} else {
				me["ALT_meters"].hide();
				me["metricM"].hide();
				me["metricBox"].hide();
				me["negText2"].hide();
			}
			
			if (!me._excessMotion) {
				me["IESI_Init"].hide();
				me["IESI"].show();
				me["AI_bank"].show();
				me["AI_bank_center"].show();
				me["AI_bank_scale"].show();
				me["AI_index"].show();
				me["AI_horizon"].show();
				me["AI_sky_bank"].show();
				me["ATTflag"].hide();
			} else {
				me["IESI_Init"].hide();
				me["IESI"].show();
				me["AI_bank"].hide();
				me["AI_bank_center"].hide();
				me["AI_bank_scale"].hide();
				me["AI_horizon"].hide();
				me["AI_sky_bank"].hide();
				me["ATTflag_text"].setText("ATT");
				me["ATTflag_text"].setColor(1,0,0);
				me["ATTflag_rect"].setScale(1,1);
				me["ATTflag_rect"].setTranslation(0,0);
				me["ATTflag_rect"].setColorFill(0,0,0);
				me["ATTflag_rect"].setColor(0,0,0);
				me["ATTflag"].show();
				me["attRst"].show();
				me["attRstRect"].show();
			}
		}
		
		foreach(var update_item; me.update_items)
        {
            update_item.update(notification);
        }
	},
	updateQNH: func(notification) {
		if (notification.altimeter_mode) {
			me["QNH_setting"].hide();
			me["QNH_std"].show();
		} else {
			if (pinPrograms.showInHg) {
				me["QNH_setting"].setText(sprintf("%4.0f", notification.qnh_hpa) ~ "/" ~ sprintf("%2.2f", notification.qnh_inhg));
			} else {
				me["QNH_setting"].setText(sprintf("%4.0f", notification.qnh_hpa));
			}
			me["QNH_setting"].show();
			me["QNH_std"].hide();
		}
	},
	_transientVar: 0,
	updatePower: func(notification) {
		# todo 20W power consumption
		if (notification.attReset == 1 and me.canReset) {
			me.canReset = 0;
			me._excessMotion = 0;
			me._fast = 1;
			iesi_init.setBoolValue(0);
		} else if (me._IESITime + 90 < notification.elapsedTime and notification.iesiInit and !me.canReset) {
			me.canReset = 1;
		}
		
		if (notification.dcEss >= 25 or (notification.relay7XB and notification.dcHot1703 >= 25)) {
			me._showIESI = 1;
			if (notification.acconfig != 1 and notification.iesiInit != 1) {
				iesi_init.setBoolValue(1);
				if (me._fast) {
					me._IESITime = notification.elapsedTime - 80;
				} else {
					me._IESITime = notification.elapsedTime;
				}
			} else if (notification.acconfig == 1 and notification.iesiInit != 1) {
				iesi_init.setBoolValue(1);
				me._IESITime = notification.elapsedTime - 87;
			}
		} elsif (notification.iesiInit) {
			if (!me._transientVar) {
				me._transientVar = 1;
				settimer(func() {
					if (systems.ELEC.Bus.dcEss.getValue() >= 25 or (systems.ELEC.Bus.dcHot1703.getValue() >= 25 and systems.ELEC.Relay.relay7XB.getValue())) {
						me._transientVar = 0;
					} else {
						me.canReset = 0;
						me._excessMotion = 0;
						me._fast = 0;
						me._showIESI = 0;
						me._transientVar = 0;
						iesi_init.setBoolValue(0);
					}
				}, 0.2); # 200ms delay power transients
			}
		}
		
		if (me._showIESI and notification.iesiBrt > 0.01) {
			me.group.setVisible(1);
		} else {
			me.group.setVisible(0);
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

var input = {
	"acconfig": "/systems/acconfig/autoconfig-running",
	"airspeed": "/instrumentation/airspeed-indicator[0]/indicated-speed-kt",
	"altitude": "/instrumentation/altimeter[6]/indicated-altitude-ft",
	"altitude_ind": "/instrumentation/altimeter[6]/indicated-altitude-ft-pfd",
	"altimeter_mode": "/instrumentation/altimeter[6]/std",
	"attReset": "/instrumentation/iesi/att-reset",
	"iesiBrt": "/controls/lighting/DU/iesi",
	"iesiInit": "/instrumentation/iesi/iesi-init",
	"mach": "/instrumentation/airspeed-indicator/indicated-mach",
	"pitch": "/instrumentation/iesi/pitch-deg",
	"qnh_hpa": "/instrumentation/altimeter[6]/setting-hpa",
	"qnh_inhg": "/instrumentation/altimeter[6]/setting-inhg",
	"roll": "/orientation/roll-deg",
	"skid": "/instrumentation/iesi/slip-skid",
	"relay7XB": "/systems/electrical/sources/si-1/inverter-control/relay-7xb",
};

foreach (var name; keys(input)) {
	emesary.GlobalTransmitter.NotifyAll(notifications.FrameNotificationAddProperty.new("A320 IESI", name, input[name]));
}

var showIESI = func {
	var dlg = canvas.Window.new([512, 512], "dialog").set("resize", 1);
	dlg.setCanvas(A320IESI.MainScreen.canvas);
}

var roundabout = func(x) {
	var y = x - int(x);
	return y < 0.5 ? int(x) : 1 + int(x);
};

var roundaboutAlt = func(x) {
	var y = x * 0.2 - int(x * 0.2);
	return y < 0.5 ? 5 * int(x * 0.2) : 5 + 5 * int(x * 0.2);
};