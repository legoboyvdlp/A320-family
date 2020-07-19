# Custom view positions
# Copyright (c) 2020 Josh Davidson (Octal450)

#########
# Views #
#########
var resetView = func() {
	if (getprop("/sim/current-view/view-number") == 0) {
		if (getprop("/sim/rendering/headshake/enabled")) {
			var _shakeFlag = 1;
			setprop("/sim/rendering/headshake/enabled", 0);
		} else {
			var _shakeFlag = 0;
		}
		
		var hd = getprop("/sim/current-view/heading-offset-deg");
		var hd_t = 360;
		if (hd < 180) {
		  hd_t = hd_t - 360;
		}
		
		interpolate("sim/current-view/field-of-view", 63, 0.66);
		interpolate("sim/current-view/heading-offset-deg", hd_t, 0.66);
		interpolate("sim/current-view/pitch-offset-deg", -14.6, 0.66);
		interpolate("sim/current-view/roll-offset-deg", 0, 0.66);
		interpolate("sim/current-view/x-offset-m", -0.45, 0.66); 
		interpolate("sim/current-view/y-offset-m", 2.34, 0.66); 
		interpolate("sim/current-view/z-offset-m", -13.75, 0.66);
		
		if (_shakeFlag) {
			setprop("/sim/rendering/headshake/enabled", 1);
		}
	} 
}

var autopilotView = func() {
	if (getprop("/sim/current-view/view-number") == 0) {
		if (getprop("/sim/rendering/headshake/enabled")) {
			var _shakeFlag = 1;
			setprop("/sim/rendering/headshake/enabled", 0);
		} else {
			var _shakeFlag = 0;
		}
		
		var hd = getprop("/sim/current-view/heading-offset-deg");
		var hd_t = 341.7;
		if (hd < 180) {
		  hd_t = hd_t - 360;
		}
		
		interpolate("sim/current-view/field-of-view", 63, 0.66);
		interpolate("sim/current-view/heading-offset-deg", hd_t, 0.66);
		interpolate("sim/current-view/pitch-offset-deg", -16.4, 0.66);
		interpolate("sim/current-view/roll-offset-deg", 0, 0.66);
		interpolate("sim/current-view/x-offset-m", -0.45, 0.66); 
		interpolate("sim/current-view/y-offset-m", 2.34, 0.66); 
		interpolate("sim/current-view/z-offset-m", -13.75, 0.66);
		
		if (_shakeFlag) {
			setprop("/sim/rendering/headshake/enabled", 1);
		}
	} 
}

var overheadView = func() {
	if (getprop("/sim/current-view/view-number") == 0) {
		if (getprop("/sim/rendering/headshake/enabled")) {
			var _shakeFlag = 1;
			setprop("/sim/rendering/headshake/enabled", 0);
		} else {
			var _shakeFlag = 0;
		}
		
		var hd = getprop("/sim/current-view/heading-offset-deg");
		var hd_t = 348;
		if (hd < 180) {
		  hd_t = hd_t - 360;
		}
		
		interpolate("sim/current-view/field-of-view", 105.8, 0.66);
		interpolate("sim/current-view/heading-offset-deg", hd_t, 0.66);
		interpolate("sim/current-view/pitch-offset-deg", 65.25, 0.66);
		interpolate("sim/current-view/roll-offset-deg", 0,0.66);
		interpolate("sim/current-view/x-offset-m", -0.12, 0.66); 
		interpolate("sim/current-view/y-offset-m", 2.34, 0.66); 
		interpolate("sim/current-view/z-offset-m", -13.75, 0.66);
		
		if (_shakeFlag) {
			setprop("/sim/rendering/headshake/enabled", 1);
		}
	} 
}

var pedestalView = func() {
	if (getprop("/sim/current-view/view-number") == 0) {
		if (getprop("/sim/rendering/headshake/enabled")) {
			var _shakeFlag = 1;
			setprop("/sim/rendering/headshake/enabled", 0);
		} else {
			var _shakeFlag = 0;
		}
		
		var hd = getprop("/sim/current-view/heading-offset-deg");
		var hd_t = 315;
		if (hd < 180) {
		  hd_t = hd_t - 360;
		}
		
		interpolate("sim/current-view/field-of-view", 63, 0.66);
		interpolate("sim/current-view/heading-offset-deg", hd_t, 0.66);
		interpolate("sim/current-view/pitch-offset-deg", -46.3, 0.66);
		interpolate("sim/current-view/roll-offset-deg", 0, 0.66);
		interpolate("sim/current-view/x-offset-m", -0.45, 0.66); 
		interpolate("sim/current-view/y-offset-m", 2.34, 0.66); 
		interpolate("sim/current-view/z-offset-m", -13.75, 0.66);
		
		if (_shakeFlag) {
			setprop("/sim/rendering/headshake/enabled", 1);
		}
	} 
}

var lightsView = func() {
	if (getprop("/sim/current-view/view-number") == 0) {
		if (getprop("/sim/rendering/headshake/enabled")) {
			var _shakeFlag = 1;
			setprop("/sim/rendering/headshake/enabled", 0);
		} else {
			var _shakeFlag = 0;
		}
		
		var hd = getprop("/sim/current-view/heading-offset-deg");
		var hd_t = 329;
		if (hd < 180) {
		  hd_t = hd_t - 360;
		}
		
		interpolate("sim/current-view/field-of-view", 63, 0.66);
		interpolate("sim/current-view/heading-offset-deg", hd_t, 0.66);
		interpolate("sim/current-view/pitch-offset-deg", 17.533, 0.66);
		interpolate("sim/current-view/roll-offset-deg", 0, 0.66);
		interpolate("sim/current-view/x-offset-m", -0.45, 0.66); 
		interpolate("sim/current-view/y-offset-m", 2.34, 0.66); 
		interpolate("sim/current-view/z-offset-m", -13.75, 0.66);
		
		if (_shakeFlag) {
			setprop("/sim/rendering/headshake/enabled", 1);
		}
	} 
}
