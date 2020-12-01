# A320 Main Libraries
# Joshua Davidson (Octal450)

# Copyright (c) 2020 Josh Davidson (Octal450)

############
# Controls #
############

controls.stepSpoilers = func(step) {
	pts.Controls.Flight.speedbrakeArm.setValue(0);
	if (step == 1) {
		deploySpeedbrake();
	} else if (step == -1) {
		retractSpeedbrake();
	}
}

var deploySpeedbrake = func() {
	if (pts.Gear.wow[1].getBoolValue() or pts.Gear.wow[2].getBoolValue()) {
		if (pts.Controls.Flight.speedbrake.getValue() < 1.0) {
			pts.Controls.Flight.speedbrake.setValue(1.0);
		}
	} else {
		if (pts.Controls.Flight.speedbrake.getValue() < 0.5) {
			pts.Controls.Flight.speedbrake.setValue(0.5);
		} else if (pts.Controls.Flight.speedbrake.getValue() < 1.0) {
			pts.Controls.Flight.speedbrake.setValue(1.0);
		}
	}
}

var retractSpeedbrake = func() {
	if (pts.Gear.wow[1].getBoolValue() or pts.Gear.wow[2].getBoolValue()) {
		if (pts.Controls.Flight.speedbrake.getValue() > 0.0) {
			pts.Controls.Flight.speedbrake.setValue(0.0);
		}
	} else {
		if (pts.Controls.Flight.speedbrake.getValue() > 0.5) {
			pts.Controls.Flight.speedbrake.setValue(0.5);
		} else if (pts.Controls.Flight.speedbrake.getValue() > 0.0) {
			pts.Controls.Flight.speedbrake.setValue(0.0);
		}
	}
}

var delta = 0;
var output = 0;
var slewProp = func(prop, delta) {
    delta *= pts.Sim.Time.deltaRealtimeSec.getValue();
    output = props.globals.getNode(prop).getValue() + delta;
    props.globals.getNode(prop).setValue(output);
    return output;
}

controls.flapsDown = func(step) {
	pts.Controls.Flight.flapsTemp = pts.Controls.Flight.flaps.getValue();
	if (step == 1) {
		if (pts.Controls.Flight.flapsTemp < 0.2) {
			pts.Controls.Flight.flaps.setValue(0.2);
		} else if (pts.Controls.Flight.flapsTemp < 0.4) {
			pts.Controls.Flight.flaps.setValue(0.4);
		} else if (pts.Controls.Flight.flapsTemp < 0.6) {
			pts.Controls.Flight.flaps.setValue(0.6);
		} else if (pts.Controls.Flight.flapsTemp < 0.8) {
			pts.Controls.Flight.flaps.setValue(0.8);
		}
	} else if (step == -1) {
		if (pts.Controls.Flight.flapsTemp > 0.6) {
			pts.Controls.Flight.flaps.setValue(0.6);
		} else if (pts.Controls.Flight.flapsTemp > 0.4) {
			pts.Controls.Flight.flaps.setValue(0.4);
		} else if (pts.Controls.Flight.flapsTemp > 0.2) {
			pts.Controls.Flight.flaps.setValue(0.2);
		} else if (pts.Controls.Flight.flapsTemp > 0) {
			pts.Controls.Flight.flaps.setValue(0);
		}
	}
}

controls.elevatorTrim = func(d) {
    if (systems.HYD.Psi.green.getValue() >= 1500 or systems.HYD.Psi.yellow.getValue() >= 1500) {
        slewProp("/controls/flight/elevator-trim", d * 0.0185); # Rate in JSB normalized (0.25 / 13.5)
    } else {
		slewProp("/controls/flight/elevator-trim", d * 0.0092) # Handcranking?
	}
}

setlistener("/controls/flight/elevator-trim", func() {
    if (pts.Controls.Flight.elevatorTrim.getValue() > 0.296296) {
        pts.Controls.Flight.elevatorTrim.setValue(0.296296);
    }
}, 0, 0);

# For the cockpit rotation and anywhere else you want to use it
var cmdDegCalc = 0;
var slewPitchWheel = func(d) {
	cmdDegCalc = math.round(pts.Fdm.JSBsim.Hydraulics.ElevatorTrim.cmdDeg.getValue(), 0.1);
	if (d > 0) { # DN
		if (cmdDegCalc < 4) {
			cmdDegCalc = (cmdDegCalc + 0.1) / 13.5; # Add and normalize, NOT 4! 13.5 = 1 on either polarity
			pts.Controls.Flight.elevatorTrim.setValue(cmdDegCalc);
		}
	} else { # UP
		if (cmdDegCalc > -13.5) {
			cmdDegCalc = (cmdDegCalc - 0.1) / 13.5; # Subtract and normalize
			pts.Controls.Flight.elevatorTrim.setValue(cmdDegCalc);
		}
	}
}
