# Custom view positions
# Copyright (c) 2020 Josh Davidson (Octal450)

#########
# Views #
#########
var viewNumberRaw = 0;
var shakeFlag = 0;
var resetView = func() {
	viewNumberRaw = pts.Sim.CurrentView.viewNumberRaw.getValue();
	if (viewNumberRaw == 0 or (viewNumberRaw >= 100 and viewNumberRaw <= 109) or viewNumberRaw == 112) {
		if (pts.Sim.Rendering.Headshake.enabled.getBoolValue()) {
			shakeFlag = 1;
			pts.Sim.Rendering.Headshake.enabled.setBoolValue(0);
		} else {
			shakeFlag = 0;
		}
		
		pts.Sim.CurrentView.fieldOfView.setValue(props.globals.getNode("/sim/view[" ~ viewNumberRaw ~ "]/config/default-field-of-view-deg").getValue());
		pts.Sim.CurrentView.headingOffsetDeg.setValue(props.globals.getNode("/sim/view[" ~ viewNumberRaw ~ "]/config/heading-offset-deg").getValue());
		pts.Sim.CurrentView.pitchOffsetDeg.setValue(props.globals.getNode("/sim/view[" ~ viewNumberRaw ~ "]/config/pitch-offset-deg").getValue());
		pts.Sim.CurrentView.rollOffsetDeg.setValue(props.globals.getNode("/sim/view[" ~ viewNumberRaw ~ "]/config/roll-offset-deg").getValue());
		pts.Sim.CurrentView.xOffsetM.setValue(props.globals.getNode("/sim/view[" ~ viewNumberRaw ~ "]/config/x-offset-m").getValue());
		pts.Sim.CurrentView.yOffsetM.setValue(props.globals.getNode("/sim/view[" ~ viewNumberRaw ~ "]/config/y-offset-m").getValue());
		pts.Sim.CurrentView.zOffsetM.setValue(props.globals.getNode("/sim/view[" ~ viewNumberRaw ~ "]/config/z-offset-m").getValue());
		
		if (shakeFlag) {
			pts.Sim.Rendering.Headshake.enabled.setBoolValue(1);
		}
	} 
}

var autopilotView = func() {
	if (pts.Sim.CurrentView.viewNumberRaw.getValue() == 0) {
		if (pts.Sim.Rendering.Headshake.enabled.getBoolValue()) {
			shakeFlag = 1;
			pts.Sim.Rendering.Headshake.enabled.setBoolValue(0);
		} else {
			shakeFlag = 0;
		}
		
		pts.Sim.CurrentView.fieldOfView.setValue(63);
		pts.Sim.CurrentView.headingOffsetDeg.setValue(341.7);
		pts.Sim.CurrentView.pitchOffsetDeg.setValue(-16.4);
		pts.Sim.CurrentView.rollOffsetDeg.setValue(0);
		pts.Sim.CurrentView.xOffsetM.setValue(-0.45); 
		pts.Sim.CurrentView.yOffsetM.setValue(2.34); 
		pts.Sim.CurrentView.zOffsetM.setValue(-13.75);
		
		if (shakeFlag) {
			pts.Sim.Rendering.Headshake.enabled.setBoolValue(1);
		}
	} 
}

var overheadView = func() {
	if (pts.Sim.CurrentView.viewNumberRaw.getValue() == 0) {
		if (pts.Sim.Rendering.Headshake.enabled.getBoolValue()) {
			shakeFlag = 1;
			pts.Sim.Rendering.Headshake.enabled.setBoolValue(0);
		} else {
			shakeFlag = 0;
		}
		
		pts.Sim.CurrentView.fieldOfView.setValue(105.8);
		pts.Sim.CurrentView.headingOffsetDeg.setValue(348);
		pts.Sim.CurrentView.pitchOffsetDeg.setValue(65.25);
		pts.Sim.CurrentView.rollOffsetDeg.setValue(0,0.66);
		pts.Sim.CurrentView.xOffsetM.setValue(-0.12); 
		pts.Sim.CurrentView.yOffsetM.setValue(2.34); 
		pts.Sim.CurrentView.zOffsetM.setValue(-13.75);
		
		if (shakeFlag) {
			pts.Sim.Rendering.Headshake.enabled.setBoolValue(1);
		}
	} 
}

var pedestalView = func() {
	if (pts.Sim.CurrentView.viewNumberRaw.getValue() == 0) {
		if (pts.Sim.Rendering.Headshake.enabled.getBoolValue()) {
			shakeFlag = 1;
			pts.Sim.Rendering.Headshake.enabled.setBoolValue(0);
		} else {
			shakeFlag = 0;
		}
		
		pts.Sim.CurrentView.fieldOfView.setValue(63);
		pts.Sim.CurrentView.headingOffsetDeg.setValue(315);
		pts.Sim.CurrentView.pitchOffsetDeg.setValue(-46.3);
		pts.Sim.CurrentView.rollOffsetDeg.setValue(0);
		pts.Sim.CurrentView.xOffsetM.setValue(-0.45); 
		pts.Sim.CurrentView.yOffsetM.setValue(2.34); 
		pts.Sim.CurrentView.zOffsetM.setValue(-13.75);
		
		if (shakeFlag) {
			pts.Sim.Rendering.Headshake.enabled.setBoolValue(1);
		}
	} 
}

var lightsView = func() {
	if (pts.Sim.CurrentView.viewNumberRaw.getValue() == 0) {
		if (pts.Sim.Rendering.Headshake.enabled.getBoolValue()) {
			shakeFlag = 1;
			pts.Sim.Rendering.Headshake.enabled.setBoolValue(0);
		} else {
			shakeFlag = 0;
		}
		
		pts.Sim.CurrentView.fieldOfView.setValue(63);
		pts.Sim.CurrentView.headingOffsetDeg.setValue(329);
		pts.Sim.CurrentView.pitchOffsetDeg.setValue(17.533);
		pts.Sim.CurrentView.rollOffsetDeg.setValue(0);
		pts.Sim.CurrentView.xOffsetM.setValue(-0.45); 
		pts.Sim.CurrentView.yOffsetM.setValue(2.34); 
		pts.Sim.CurrentView.zOffsetM.setValue(-13.75);
		
		if (shakeFlag) {
			pts.Sim.Rendering.Headshake.enabled.setBoolValue(1);
		}
	} 
}
