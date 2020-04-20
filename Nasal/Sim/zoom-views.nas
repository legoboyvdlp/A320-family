# Distance Zooming
# Copyright (c) 2020 Josh Davidson (Octal450)
# Based on PropertyRule file by onox

var distance = 0;
var min_dist = 0;
var max_dist = 0;
var canChangeZOffset = 0;
var decStep = -0.5;
var incStep = 0.5;
var viewName = "XX";

var fovZoom = func(d) {
	viewName = getprop("sim/current-view/name");
	canChangeZOffset = getprop("sim/current-view/type") == "lookat" and viewName != "Tower View"  and viewName != "Tower View AGL" and viewName != "Fly-By View" and viewName != "Chase View" and viewName != "Chase View Without Yaw" and viewName != "Walk View" and viewName != "Walker Orbit View";
	
	if (getprop("sim/current-view/z-offset-m") <= -20) {
		decStep = -2;
	} else {
		decStep = -1;
	}
	
	if (getprop("sim/current-view/z-offset-m") < -20) { # Not a typo, the conditions are different
		incStep = 2;
	} else {
		incStep = 1;
	}
	
	if (d == -1) {
		if (canChangeZOffset) {
			distance = getprop("sim/current-view/z-offset-m");
			min_dist = getprop("sim/current-view/z-offset-min-m");
			
			distance = math.round(std.min(-min_dist, distance + incStep) / incStep, 0.1) * incStep;
			setprop("sim/current-view/z-offset-m", distance);
			
			gui.popupTip(sprintf("%d meters", abs(distance)));
		} else {
			view.decrease();
		}
	} else if (d == 1) {
		if (canChangeZOffset) {
			distance = getprop("sim/current-view/z-offset-m");
			max_dist = getprop("sim/current-view/z-offset-max-m");
			
			distance = math.round(std.max(-max_dist, distance + decStep) / decStep, 0.1) * decStep;
			setprop("sim/current-view/z-offset-m", distance);
			
			gui.popupTip(sprintf("%d meters", abs(distance)));
		} else {
			view.increase();
		}
	} else if (d == 0) {
		if (canChangeZOffset) {
			setprop("sim/current-view/z-offset-m", getprop("sim/current-view/z-offset-default") * -1);
			gui.popupTip(sprintf("%d meters", getprop("sim/current-view/z-offset-default")));
		} else {
			setprop("sim/current-view/field-of-view", getprop("sim/view/config/default-field-of-view-deg"));
			gui.popupTip(sprintf("FOV: %.1f", getprop("sim/current-view/field-of-view")))
		}
	}
}
