# A3XX IESI

# Copyright (c) 2020 Josh Davidson (Octal450)

# props.nas nodes
var iesi_init = props.globals.initNode("/instrumentation/iesi/iesi-init", 0, "BOOL");
var iesi_reset = props.globals.initNode("/instrumentation/iesi/att-reset", 0, "DOUBLE");

var ASI = 0;
var _showIESI = 0;
var _fast = 0;
var _IESITime = 0;

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
			return "LiberationFonts/LiberationSans-Regular.ttf";
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
		
		obj.middleAltOffset = nil;
		
		obj.update_items = [
			props.UpdateManager.FromHashValue("airspeed", nil, func(val) {
				# Subtract 30, since the scale starts at 30, but don't allow less than 0, or more than 520 knots
				if (val <= 30) {
					ASI = 0;
				} else if (val >= 520) {
					ASI = 490;
				} else {
					ASI = val - 30;
				}
				obj["ASI_scale"].setTranslation(0, ASI * 8.295);
			}),
			props.UpdateManager.FromHashList(["altitude","altitude_ind"], nil, func(val) {
				if (val.altitude > 50000) {
					val.altitude = 50000;
				} elsif (val.altitude < -2000) {
					val.altitude = -2000;
				}
				
				if (val.altitude < 0) {
					obj["negText"].show();
					obj["negText2"].show();
				} else {
					obj["negText"].hide();
					obj["negText2"].hide();
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
				obj["AI_slipskid"].setTranslation(val, 0);
			}),
			props.UpdateManager.FromHashList(["altimeter_mode","qnh_hpa","qnh_inhg"], nil, func(val) {
				obj.updateQNH(val);
			}),
		];
		
		_showIESI = 0;
		_fast = 0;
		_IESITime = 0.0;
		obj._cachedInhg = nil;
		
		return obj;
	},	
	getKeys: func() {
		return ["IESI","IESI_Init","ASI_scale","ASI_mach","ASI_mach_decimal","AI_center","AI_horizon","AI_bank","AI_slipskid","ALT_scale","ALT_one","ALT_two","ALT_three","ALT_four","ALT_five","ALT_digits","ALT_tens","ALT_meters","QNH_setting","QNH_std","negText","negText2","AI_bank_scale"];
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
		
		if (_IESITime + 90 >= notification.elapsedTime) {
			me["IESI"].hide(); 
			me["IESI_Init"].show();
			return;
		} else {
			me["IESI_Init"].hide();
			me["IESI"].show();
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
			me["QNH_setting"].setText(sprintf("%4.0f", notification.qnh_hpa) ~ "/" ~ sprintf("%2.2f", notification.qnh_inhg));
			me["QNH_setting"].show();
			me["QNH_std"].hide();
		}
	},
	updatePower: func(notification) {
		# todo consider relay 7XB for power of DC HOT 1
		# todo transient max 0.2s
		# todo 20W power consumption
		if (notification.attReset == 1) {
			if (notification.iesiInit and _IESITime + 90 >= notification.elapsedTime) {
				_fast = 1;
			} else {
				_fast = 0;
			}
			iesi_init.setBoolValue(0);
		}
		
		if (notification.dcEss >= 25 or (notification.dcHot1 >= 25 and notification.airspeed >= 50 and notification.elapsedTime >= 5)) {
			_showIESI = 1;
			if (notification.acconfig != 1 and notification.iesiInit != 1) {
				iesi_init.setBoolValue(1);
				if (_fast) {
					_IESITime = notification.elapsedTime - 80;
					_fast = 0;
				} else {
					_IESITime = notification.elapsedTime;
				}
			} else if (notification.acconfig == 1 and notification.iesiInit != 1) {
				iesi_init.setBoolValue(1);
				_IESITime = notification.elapsedTime - 87;
			}
		} else {
			_showIESI = 0;
			iesi_init.setBoolValue(0);
		}
		
		if (_showIESI and notification.iesiBrt > 0.01) {
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
	"altitude": "/instrumentation/altimeter/indicated-altitude-ft",
	"altitude_ind": "/instrumentation/altimeter/indicated-altitude-ft-pfd",
	"altimeter_mode": "/instrumentation/altimeter[0]/std",
	"attReset": "/instrumentation/iesi/att-reset",
	"dcEss": "/systems/electrical/bus/dc-ess",
	"dcHot1": "/systems/electrical/bus/dc-hot-1",
	"iesiBrt": "/controls/lighting/DU/iesi",
	"iesiInit": "/instrumentation/iesi/iesi-init",
	"mach": "/instrumentation/airspeed-indicator/indicated-mach",
	"pitch": "/instrumentation/iesi/pitch-deg",
	"qnh_hpa": "/instrumentation/altimeter[0]/setting-hpa",
	"qnh_inhg": "/instrumentation/altimeter[0]/setting-inhg",
	"roll": "/orientation/roll-deg",
	"skid": "/instrumentation/iesi/slip-skid",
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