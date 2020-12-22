# Octal's Distance Zooming
# Copyright (c) 2020 Josh Davidson (Octal450)
# Based on PropertyRule file by onox

var distance = 0;
var min_dist = 0;
var max_dist = 0;
var canChangeZOffset = 0;
var decStep = -5;
var incStep = 5;
var viewName = "XX";

var fovZoom = func(d) {
	viewName = pts.Sim.CurrentView.name.getValue();
	canChangeZOffset = pts.Sim.CurrentView.type.getValue() == "lookat" and viewName != "Tower View" and viewName != "Fly-By View" and viewName != "Chase View" and viewName != "Chase View Without Yaw" and viewName != "Walk View";
	
	if (pts.Sim.CurrentView.zOffsetM.getValue() <= -50) {
		decStep = -10;
	} else {
		decStep = -5;
	}
	
	if (pts.Sim.CurrentView.zOffsetM.getValue() < -50) { # Not a typo, the conditions are different
		incStep = 10;
	} else {
		incStep = 5;
	}
	
	if (d == -1) {
		if (canChangeZOffset) {
			distance = pts.Sim.CurrentView.zOffsetM.getValue();
			min_dist = pts.Sim.CurrentView.zOffsetMinM.getValue();
			
			distance = math.round(std.min(-min_dist, distance + incStep) / incStep, 0.1) * incStep;
			pts.Sim.CurrentView.zOffsetM.setValue(distance);
			
			gui.popupTip(sprintf("%d meters", abs(distance)));
		} else {
			view.decrease();
		}
	} else if (d == 1) {
		if (canChangeZOffset) {
			distance = pts.Sim.CurrentView.zOffsetM.getValue();
			max_dist = pts.Sim.CurrentView.zOffsetMaxM.getValue();
			
			distance = math.round(std.max(-max_dist, distance + decStep) / decStep, 0.1) * decStep;
			pts.Sim.CurrentView.zOffsetM.setValue(distance);
			
			gui.popupTip(sprintf("%d meters", abs(distance)));
		} else {
			view.increase();
		}
	} else if (d == 0) {
		if (canChangeZOffset) {
			pts.Sim.CurrentView.zOffsetM.setValue(pts.Sim.CurrentView.zOffsetDefault.getValue() * -1);
			gui.popupTip(sprintf("%d meters", pts.Sim.CurrentView.zOffsetDefault.getValue()));
		} else {
			pts.Sim.CurrentView.fieldOfView.setValue(pts.Sim.View.Config.defaultFieldOfViewDeg.getValue());
			gui.popupTip(sprintf("FOV: %.1f", pts.Sim.CurrentView.fieldOfView.getValue()));
		}
	}
}
