# AUTOPUSH
# Basic pushback logic class.
#
# Copyright (c) 2018 Autopush authors:
#  Michael Danilov <mike.d.ft402 -eh- gmail.com>
#  Joshua Davidson http://github.com/Octal450
#  Merspieler http://gitlab.com/merspieler
# Distribute under the terms of GPLv2.


var _K_p = nil;
var _F_p = nil;
var _K_i = nil;
var _F_i = nil;
var _K_d = nil;
var _F_d = nil;
var _F = nil;
var _int = nil;
var _V = nil;
var _T_f = nil;
var _K_yaw = nil;
var _yasim = 0;
var _time = nil;
# (ft / s^2) / ((km / h) / s)
var _unitconv = M2FT / 3.6;
var _debug = nil;

var _loop = func() {
	if (!getprop("/sim/model/autopush/available")) {
		_stop();
		return;
	}
	var force = 0.0;
	var x = 0.0;
	var y = 0.0;
	var z = 0.0;
	# Rollspeed is only adequate if the wheel is touching the ground.
	if (getprop("/gear/gear[0]/wow")) {
		var V = getprop("/gear/gear[0]/rollspeed-ms") * 3.6;
		var deltaV = getprop("/sim/model/autopush/target-speed-km_h") - V;
		var minus_dV = _V - V;
		var time = getprop("/sim/time/elapsed-sec");
		var prop = math.min(math.max(_K_p * deltaV, -_F_p), _F_p);
		var dt = time - _time;
		var deriv = 0.0;
		# XXX Sanitising dt. Smaller chance of freakout on lag spike.
		if(dt > 0.0) {
			if(dt < 0.05) {
				_int = math.min(math.max(_int + _K_i * deltaV * dt, -_F_i), _F_i);
			}
			if(dt > 0.002) {
				deriv = math.min(math.max(_K_d * minus_dV / dt, -_F_d), _F_d);
			}
		}
		var accel = prop + _int + deriv;
		if (_debug > 2) {
			print("pushback prop " ~ prop ~ ", _int " ~ _int ~ ", deriv " ~ deriv);
		}
		_V = V;
		_time = time;
		if (!_yasim) {
			force = accel * getprop("/fdm/jsbsim/inertia/weight-lbs") * _unitconv;
		} else {
			force = accel * getprop("/fdm/yasim/gross-weight-lbs") * _unitconv;
		}
		var pitch = getprop("/sim/model/autopush/pitch-deg") * D2R;
		z = math.sin(pitch);
		var pz = math.cos(pitch);
		var yaw = getprop("/sim/model/autopush/yaw") * _K_yaw;
		x = math.cos(yaw) * pz;
		y = math.sin(yaw) * pz;
		setprop("/sim/model/autopush/force-x", x);
		setprop("/sim/model/autopush/force-y", y);
		# JSBSim force's z is down.
		setprop("/sim/model/autopush/force-z", -z);
	}
	setprop("/sim/model/autopush/force-lbf", force);
	if (_yasim) {
		# The force is divided by YASim thrust="100000.0" setting.
		setprop("/sim/model/autopush/force-x-yasim", x * force * 0.00001);
		# YASim force's y is to the left.
		setprop("/sim/model/autopush/force-y-yasim", -y * force * 0.00001);
		setprop("/sim/model/autopush/force-z-yasim", z * force * 0.00001);
	}
}

var _timer = maketimer(0.0167, func{_loop()});
_timer.simulatedTime = 1;

var _start = func() {
	# Else overwritten by dialog.
	settimer(func() {
		setprop("/sim/model/autopush/target-speed-km_h", 0.0)
	}, 0.1, 1);
	_K_p = getprop("/sim/model/autopush/K_p");
	_F_p = getprop("/sim/model/autopush/F_p");
	_K_i = getprop("/sim/model/autopush/K_i");
	_F_i = getprop("/sim/model/autopush/F_i");
	_K_d = getprop("/sim/model/autopush/K_d");
	_F_d = getprop("/sim/model/autopush/F_d");
	_F = getprop("/sim/model/autopush/F");
	_T_f = getprop("/sim/model/autopush/T_f");
	_K_yaw = getprop("/sim/model/autopush/yaw-mult") * D2R;
	_yasim = (getprop("/sim/flight-model") == "yasim");
	_debug = getprop("/sim/model/autopush/debug") or 0;
	_int = 0.0;
	_V = 0.0;
	_time = getprop("/sim/time/elapsed-sec");
	setprop("/sim/model/autopush/connected", 1);
	if (!_timer.isRunning) {
		if (getprop("/sim/model/autopush/chocks")) {
			setprop("/sim/model/autopush/chocks", 0);
			screen.log.write("(pushback): Pushback connected, chocks removed. Please release brakes.");
		} else {
			screen.log.write("(pushback): Pushback connected, please release brakes.");
		}
	}
	_timer.start();
}

var _stop = func() {
	if (_timer.isRunning) {
		screen.log.write("(pushback): Pushback and bypass pin removed.");
	}
	_timer.stop();
	setprop("/sim/model/autopush/force-lbf", 0.0);
	if (_yasim) {
		setprop("/sim/model/autopush/force-x-yasim", 0.0);
		setprop("/sim/model/autopush/force-y-yasim", 0.0);
	}
	setprop("/sim/model/autopush/connected", 0);
	setprop("/sim/model/autopush/enabled", 0);
}

setlistener("/sim/model/autopush/enabled", func(p) {
	var enabled = p.getValue();
	if ((enabled) and getprop("/sim/model/autopush/available")) {
		_start();
	} else {
		_stop();
	}
}, 1, 0);
