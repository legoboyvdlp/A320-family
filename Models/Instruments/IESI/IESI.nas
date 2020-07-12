# A3XX IESI

# Copyright (c) 2020 Josh Davidson (Octal450)

var IESI = nil;
var IESI_display = nil;
var elapsedtime = 0;
var ASI = 0;
var alt = 0;
var altTens = 0;
var airspeed_act = 0;
var mach_act = 0;

# props.nas nodes
var iesi_init = props.globals.initNode("/instrumentation/iesi/iesi-init", 0, "BOOL");
var iesi_time = props.globals.initNode("/instrumentation/iesi/iesi-init-time", 0.0, "DOUBLE");
var iesi_rate = props.globals.getNode("/systems/acconfig/options/iesi-rate", 1);
var et = props.globals.getNode("/sim/time/elapsed-sec", 1);
var aconfig = props.globals.getNode("/systems/acconfig/autoconfig-running", 1);

var airspeed = props.globals.getNode("/instrumentation/airspeed-indicator/indicated-speed-kt", 1);
var mach = props.globals.getNode("/instrumentation/airspeed-indicator/indicated-mach", 1);
var pitch = props.globals.getNode("/orientation/pitch-deg", 1);
var roll =  props.globals.getNode("/orientation/roll-deg", 1);
var skid = props.globals.getNode("/instrumentation/slip-skid-ball/indicated-slip-skid", 1);
var altitude = props.globals.getNode("/instrumentation/altimeter/indicated-altitude-ft", 1);
var altitude_ind = props.globals.getNode("/instrumentation/altimeter/indicated-altitude-ft-pfd", 1);

var altimeter_mode = props.globals.getNode("/instrumentation/altimeter[0]/std", 1);
var qnh_hpa = props.globals.getNode("/instrumentation/altimeter/setting-hpa", 1);
var qnh_inhg = props.globals.getNode("/instrumentation/altimeter/setting-inhg", 1);

var canvas_IESI_base = {
	init: func(canvas_group, file) {
		var font_mapper = func(family, weight) {
			return "LiberationFonts/LiberationSans-Regular.ttf";
		};
		
		canvas.parsesvg(canvas_group, file, {"font-mapper": font_mapper});
		
		var svg_keys = me.getKeys();
		foreach(var key; svg_keys) {
			me[key] = canvas_group.getElementById(key);
			var svg_keys = me.getKeys();

			foreach (var key; svg_keys) {
				me[key] = canvas_group.getElementById(key);

				var clip_el = canvas_group.getElementById(key ~ "_clip");
				if (clip_el != nil) {
					clip_el.setVisible(0);
					var tran_rect = clip_el.getTransformedBounds();

					var clip_rect = sprintf("rect(%d,%d, %d,%d)", 
					tran_rect[1], # 0 ys
					tran_rect[2], # 1 xe
					tran_rect[3], # 2 ye
					tran_rect[0]); #3 xs
					#   coordinates are top,right,bottom,left (ys, xe, ye, xs) ref: l621 of simgear/canvas/CanvasElement.cxx
					me[key].set("clip", clip_rect);
					me[key].set("clip-frame", canvas.Element.PARENT);
				}
			}
		}
		
		me.AI_horizon_trans = me["AI_horizon"].createTransform();
		me.AI_horizon_rot = me["AI_horizon"].createTransform();
		
		me.page = canvas_group;
		
		return me;
	},
	getKeys: func() {
		return [];
	},
	update: func() {
		cur_time = et.getValue();
		if (systems.ELEC.Bus.dcEss.getValue() >= 25 or (systems.ELEC.Bus.dcHot1.getValue() >= 25 and airspeed.getValue() >= 50 and cur_time >= 5)) {
			IESI.page.show();
			IESI.update();
			
			if (aconfig.getValue() != 1 and iesi_init.getValue() != 1) {
				iesi_init.setBoolValue(1);
				iesi_time.setValue(cur_time);
			} else if (aconfig.getValue() == 1 and iesi_init.getValue() != 1) {
				iesi_init.setBoolValue(1);
				iesi_time.setValue(cur_time - 87);
			}
		} else {
			iesi_init.setBoolValue(0);
			IESI.page.hide();
		}
	},
};

var canvas_IESI = {
	new: func(canvas_group, file) {
		var m = {parents: [canvas_IESI, canvas_IESI_base]};
		m.init(canvas_group, file);
		m._cachedInhg = -99;
		
		return m;
	},
	getKeys: func() {
		return ["IESI","IESI_Init","ASI_scale","ASI_mach","ASI_mach_decimal","AI_center","AI_horizon","AI_bank","AI_slipskid","ALT_scale","ALT_one","ALT_two","ALT_three","ALT_four","ALT_five","ALT_digits","ALT_tens","ALT_meters","QNH_setting","QNH_std"];
	},
	update: func() {
		if (iesi_time.getValue() + 90 >= et.getValue()) {
			me["IESI"].hide(); 
			me["IESI_Init"].show();
			return;
		} else {
			me["IESI_Init"].hide();
			me["IESI"].show();
		}
		
		# Airspeed
		# Subtract 30, since the scale starts at 30, but don"t allow less than 0, or more than 420 situations
		airspeed_act = airspeed.getValue();
		mach_act = mach.getValue();
		if (airspeed_act <= 30) {
			ASI = 0;
		} else if (airspeed_act >= 420) {
			ASI = 390;
		} else {
			ASI = airspeed_act - 30;
		}
		me["ASI_scale"].setTranslation(0, ASI * 8.295);
		
		if (mach_act >= 0.5) {
			me["ASI_mach_decimal"].show();
			me["ASI_mach"].show();
		} else {
			me["ASI_mach_decimal"].hide();
			me["ASI_mach"].hide();
		}
		
		if (mach_act >= 0.999) {
			me["ASI_mach"].setText("99");
		} else {
			me["ASI_mach"].setText(sprintf("%2.0f", mach_act * 100));
		}
		
		# Attitude
		me.AI_horizon_trans.setTranslation(0, pitch.getValue() * 16.74);
		me.AI_horizon_rot.setRotation(-roll.getValue() * D2R, me["AI_center"].getCenter());
		
		me["AI_slipskid"].setTranslation(math.clamp(skid.getValue(), -7, 7) * -15, 0);
		me["AI_bank"].setRotation(-roll.getValue() * D2R);
		
		# Altitude
		me.altitude = altitude.getValue();
		me.altOffset = me.altitude / 500 - int(me.altitude / 500);
		me.middleAltText = roundaboutAlt(me.altitude / 100);
		me.middleAltOffset = nil;
		if (me.altOffset > 0.5) {
			me.middleAltOffset = -(me.altOffset - 1) * 258.5528;
		} else {
			me.middleAltOffset = -me.altOffset * 258.5528;
		}
		me["ALT_scale"].setTranslation(0, -me.middleAltOffset);
		me["ALT_scale"].update();
		me["ALT_five"].setText(sprintf("%03d", abs(me.middleAltText+10)));
		me["ALT_four"].setText(sprintf("%03d", abs(me.middleAltText+5)));
		me["ALT_three"].setText(sprintf("%03d", abs(me.middleAltText)));
		me["ALT_two"].setText(sprintf("%03d", abs(me.middleAltText-5)));
		me["ALT_one"].setText(sprintf("%03d", abs(me.middleAltText-10)));
		
		me["ALT_digits"].setText(sprintf("%s", altitude_ind.getValue()));
		me["ALT_meters"].setText(sprintf("%5.0f", me.altitude * 0.3048));
		altTens = num(right(sprintf("%02d", altitude.getValue()), 2));
		me["ALT_tens"].setTranslation(0, altTens * 3.16);
		
		if (qnh_inhg.getValue() != me._cachedInhg) {
			me._cachedInhg = qnh_inhg.getValue();
			me.updateQNH();
		}
	},
	updateQNH: func() {
		if (altimeter_mode.getBoolValue()) {
			me["QNH_setting"].hide();
			me["QNH_std"].show();
		} else {
			me["QNH_setting"].setText(sprintf("%4.0f", qnh_hpa.getValue()) ~ "/" ~ sprintf("%2.2f", qnh_inhg.getValue()));
			me["QNH_setting"].show();
			me["QNH_std"].hide();
		}
	}
};

setlistener("sim/signals/fdm-initialized", func {
	IESI_display = canvas.new({
		"name": "IESI",
		"size": [1024, 1024],
		"view": [1024, 1024],
		"mipmapping": 1
	});
	IESI_display.addPlacement({"node": "iesi.screen"});
	var group_IESI = IESI_display.createGroup();
	
	IESI = canvas_IESI.new(group_IESI, "Aircraft/A320-family/Models/Instruments/IESI/res/iesi.svg");
	
	IESI.updateQNH();
	
	IESI_update.start();
	if (iesi_rate.getValue() > 1) {
		rateApply();
	}
});

setlistener("/instrumentation/altimeter[0]/std", func() { if (IESI != nil) { IESI.updateQNH(); } }, 0, 0);

var rateApply = func {
	IESI_update.restart(0.05 * iesi_rate.getValue());
}

var IESI_update = maketimer(0.05, func {
	canvas_IESI_base.update();
});

var showIESI = func {
	var dlg = canvas.Window.new([256, 256], "dialog").set("resize", 1);
	dlg.setCanvas(IESI_display);
}

var roundabout = func(x) {
	var y = x - int(x);
	return y < 0.5 ? int(x) : 1 + int(x);
};

var roundaboutAlt = func(x) {
	var y = x * 0.2 - int(x * 0.2);
	return y < 0.5 ? 5 * int(x * 0.2) : 5 + 5 * int(x * 0.2);
};
