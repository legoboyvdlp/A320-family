# AUTOPUSH
# Pushback driver class.
#
# Command the pushback to tow/push the aircraft.
#
# Copyright (c) 2018 Autopush authors:
#  Michael Danilov <mike.d.ft402 -eh- gmail.com>
#  Joshua Davidson http://github.com/Octal450
#  Merspieler http://gitlab.com/merspieler
# Distribute under the terms of GPLv2.


var _K_V = nil;
var _F_V = nil;
var _R_turn_min = nil;
var _D_stop = nil;
var _K_psi = nil;
var _debug = nil;

var _route = nil;
var _route_reverse = nil;
var _push = nil;
var _sign = nil;

var _to_wp = 1;
var _is_last_wp = 0;
var _is_reverse_wp = 0;


var _advance_wp = func(flip_sign = 0) {
	_to_wp += 1;
	_is_last_wp = (_to_wp == (size(_route) - 1));
	_is_reverse_wp = (_route_reverse[_to_wp]);
	if (flip_sign) {
		_sign *= -1;
		_push = !_push;
	}
	if (_debug == 1) {
		print("autopush_driver to_wp " ~ _to_wp);
	}
}

var _loop = func() {
	if (!getprop("/sim/model/autopush/connected")) {
		stop();
		return;
	}
	var psi = getprop("/orientation/heading-deg") + _push * 180.0;
	var (A, D) = courseAndDistance(_route[_to_wp]);
	D *= NM2M;
	var (psi_leg, D_leg) = courseAndDistance(_route[_to_wp - 1], _route[_to_wp]);
	var deltapsi = geo.normdeg180(A - psi_leg);
	var deltaA = geo.normdeg180(A - psi);
	# TODO Either use _K_V and total remaining distance or turn radius to calculate speed.
	# TODO Make slider input override speed.
	var V = _F_V;
	if (_is_reverse_wp or _is_last_wp) {
		if ((D < _D_stop) or (abs(deltapsi) > 90.0)) {
			if (_is_last_wp) {
				_done();
				return;
			}
			if (_is_reverse_wp) {
				_advance_wp(1);
			}
		}
	} else {
		if ((D < _R_turn_min) or (abs(deltapsi) > 90.0)) {
			_advance_wp();
		}
	}

	if (_debug > 1) {
		print("autopush_driver to_wp " ~ _to_wp ~ ", psi_target " ~ geo.normdeg(A) ~ ", deltapsi " ~ deltapsi ~ ", deltapsi_steer " ~ _sign * deltaA);
	}
	setprop("/sim/model/autopush/target-speed-km_h", _sign * V);
	steering = math.min(math.max(_sign * _K_psi * deltaA, -1.0), 1.0);
	setprop("/sim/model/autopush/steer-cmd-norm", steering);
}

var _timer = maketimer(0.051, func{_loop()});

var _done = func() {
	stop();
	autopush_route.clear();
	screen.log.write("(pushback): Pushback complete, please set parking brake.");
}

var start = func() {
	if (_timer.isRunning) {
		gui.popupTip("Already moving");
		return;
	}
	if (!getprop("/sim/model/autopush/connected")) {
		gui.popupTip("Pushback not connected");
		return;
	}
	_route = autopush_route.route();
	_route_reverse = autopush_route.route_reverse();
	if ((_route == nil) or size(_route) < 2) {
		gui.popupTip("Pushback route empty or invalid");
		return;
	}else{
		autopush_route.done();
	}
	_K_V = getprop("/sim/model/autopush/driver/K_V");
	_F_V = getprop("/sim/model/autopush/driver/F_V");
	_R_turn_min = getprop("/sim/model/autopush/min-turn-radius-m");
	_D_stop = getprop("/sim/model/autopush/stopping-distance-m");
	_K_psi = getprop("/sim/model/autopush/driver/K_psi");
	_debug = getprop("/sim/model/autopush/debug") or 0;
	if (_to_wp == 1) {
		var (psi_park, D_park) = courseAndDistance(_route[0], _route[1]);
		_push = (abs(geo.normdeg180(getprop("/orientation/heading-deg") - psi_park)) > 90.0);
		_sign = 1.0 - 2.0 * _push;
	}
	_timer.start();
	var endsign = _sign;
	for (ii = _to_wp; ii < size(_route_reverse); ii += 1) {
		if (_route_reverse[ii]) {
			endsign = -endsign;
		}
	}
	var (psi_twy, D_twy) = courseAndDistance(_route[size(_route) - 2], _route[size(_route) - 1]);
	if (endsign < 0.0) {
		screen.log.write("(pushback): Push back facing " ~ int(geo.normdeg(psi_twy + 180.0 - magvar())) ~ ".");
	} else {
		screen.log.write("(pushback): Tow facing " ~ int(geo.normdeg(psi_twy - magvar())) ~ ".");
	}
}

var pause = func() {
	_timer.stop();
	setprop("/sim/model/autopush/target-speed-km_h", 0.0);
}

var stop = func() {
	pause();
	_to_wp = 1;
	_is_last_wp = 0;
	_is_reverse_wp = 0;
}
