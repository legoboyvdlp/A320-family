# A3XX Engine Control
# Copyright (c) 2021 Josh Davidson (Octal450)

var manStart = [props.globals.initNode("/controls/engines/engine[0]/man-start", 0, "BOOL"),props.globals.initNode("/controls/engines/engine[1]/man-start", 0, "BOOL")];
var lastIgniter = [props.globals.getNode("/controls/engines/engine[0]/last-igniter"),props.globals.initNode("/controls/engines/engine[1]/last-igniter")];
var igniterA = [props.globals.initNode("/controls/engines/engine[0]/igniter-a", 0, "BOOL"),props.globals.initNode("/controls/engines/engine[1]/igniter-a", 0, "BOOL")];
var igniterB = [props.globals.initNode("/controls/engines/engine[0]/igniter-b", 0, "BOOL"),props.globals.initNode("/controls/engines/engine[1]/igniter-b", 0, "BOOL")];

if (pts.Options.eng.getValue() == "IAE") {
	io.include("engines-iae.nas");
} else {
	io.include("engines-cfm.nas");
}

var eng_common_init = func {
	manStart[0].setValue(0);
	manStart[1].setValue(0);
}

# Engine thrust commands
var doIdleThrust = func {
	# Idle does not respect selected engines, because it is used to respond
	# to "Retard" and both engines must be idle for spoilers to deploy
	pts.Controls.Engines.Engine.throttle[0].setValue(0);
	pts.Controls.Engines.Engine.throttle[1].setValue(0);
}

var doClThrust = func {
	if (pts.Sim.Input.Selected.engine[0].getBoolValue()) {
		pts.Controls.Engines.Engine.throttle[0].setValue(0.63);
	}
	if (pts.Sim.Input.Selected.engine[1].getBoolValue()) {
		pts.Controls.Engines.Engine.throttle[1].setValue(0.63);
	}
}

var doMctThrust = func {
	if (pts.Sim.Input.Selected.engine[0].getBoolValue()) {
		pts.Controls.Engines.Engine.throttle[0].setValue(0.8);
	}
	if (pts.Sim.Input.Selected.engine[1].getBoolValue()) {
		pts.Controls.Engines.Engine.throttle[1].setValue(0.8);
	}
}

var doTogaThrust = func {
	if (pts.Sim.Input.Selected.engine[0].getBoolValue()) {
		pts.Controls.Engines.Engine.throttle[0].setValue(1);
	}
	if (pts.Sim.Input.Selected.engine[1].getBoolValue()) {
		pts.Controls.Engines.Engine.throttle[1].setValue(1);
	}
}

# Reverse Thrust System - TODO: Totally f*cked! Redo the whole d*mn thing!
var toggleFastRevThrust = func {
	#if (systems.FADEC.detentText[0].getValue() == "IDLE" and systems.FADEC.detentText[1].getValue() == "IDLE" and pts.Controls.Engines.Engine.reverseCmd[0].getValue() == 0 and pts.Controls.Engines.Engine.reverseCmd[1].getValue() == 0 and pts.Gear.wow[1].getValue() == 1 and pts.Gear.wow[2].getValue() == 1) {
	#	if (pts.Sim.Input.Selected.engine[0].getBoolValue()) {
	#		interpolate("/engines/engine[0]/reverser-pos-norm", 1, 1.4);
	#		pts.Controls.Engines.Engine.reverseCmd[0].setValue(1);
	#		pts.Controls.Engines.Engine.reverseLever[0].setValue(0.65);
	#		pts.Fdm.JSBsim.Propulsion.Engine.reverseCmdAngle[0].setValue(3.14);
	#	}
	#	if (pts.Sim.Input.Selected.engine[1].getBoolValue()) {
	#		interpolate("/engines/engine[1]/reverser-pos-norm", 1, 1.4);
	#		pts.Controls.Engines.Engine.reverseCmd[1].setValue(1);
	#		pts.Controls.Engines.Engine.reverseLever[1].setValue(0.65);
	#		pts.Fdm.JSBsim.Propulsion.Engine.reverseCmdAngle[1].setValue(3.14);
	#	}
	#} else if (pts.Controls.Engines.Engine.reverseCmd[0].getValue() == 1 or pts.Controls.Engines.Engine.reverseCmd[1].getValue() == 1) {
	#	interpolate("/engines/engine[0]/reverser-pos-norm", 0, 1.0);
	#	interpolate("/engines/engine[1]/reverser-pos-norm", 0, 1.0);
	#	pts.Controls.Engines.Engine.reverseLever[0].setValue(0);
	#	pts.Controls.Engines.Engine.reverseLever[1].setValue(0);
	#	pts.Fdm.JSBsim.Propulsion.Engine.reverseCmdAngle[0].setValue(0);
	#	pts.Fdm.JSBsim.Propulsion.Engine.reverseCmdAngle[1].setValue(0);
	#	pts.Controls.Engines.Engine.reverseCmd[0].setValue(0);
	#	pts.Controls.Engines.Engine.reverseCmd[1].setValue(0);
	#}
}

var doRevThrust = func {
	#if (pts.Gear.wow[1].getValue() != 1 and pts.Gear.wow[2].getValue() != 1) {
	#	# Can't select reverse if not on the ground
	#	return;
	#}
	#if (pts.Sim.Input.Selected.engine[0].getBoolValue() and pts.Controls.Engines.Engine.reverseCmd[0].getValue() == 1) {
	#	var pos = pts.Controls.Engines.Engine.reverseLever[0].getValue();
	#	if (pos < 0.649) {
	#		pts.Controls.Engines.Engine.reverseLever[0].setValue(pos + 0.15);
	#	}
	#}
	#if (pts.Sim.Input.Selected.engine[1].getBoolValue() and pts.Controls.Engines.Engine.reverseCmd[1].getValue() == 1) {
	#	var pos = pts.Controls.Engines.Engine.reverseLever[1].getValue();
	#	if (pos < 0.649) {
	#		pts.Controls.Engines.Engine.reverseLever[1].setValue(pos + 0.15);
	#	}
	#}
	#
	#if (pts.Sim.Input.Selected.engine[0].getBoolValue() and systems.FADEC.detentText[0].getValue() == "IDLE" and pts.Controls.Engines.Engine.reverseCmd[0].getValue() == 0) {
	#	interpolate("/engines/engine[0]/reverser-pos-norm", 1, 1.4);
	#	pts.Controls.Engines.Engine.reverseLever[0].setValue(0.05);
	#	pts.Controls.Engines.Engine.reverseCmd[0].setValue(1);
	#	pts.Fdm.JSBsim.Propulsion.Engine.reverseCmdAngle[0].setValue(3.14);
	#}
	#if (pts.Sim.Input.Selected.engine[1].getBoolValue() and systems.FADEC.detentText[1].getValue() == "IDLE" and pts.Controls.Engines.Engine.reverseCmd[1].getValue() == 0) {
	#	interpolate("/engines/engine[1]/reverser-pos-norm", 1, 1.4);
	#	pts.Controls.Engines.Engine.reverseLever[1].setValue(0.05);
	#	pts.Controls.Engines.Engine.reverseCmd[1].setValue(1);
	#	pts.Fdm.JSBsim.Propulsion.Engine.reverseCmdAngle[1].setValue(3.14);
	#}
}

var unRevThrust = func {
	#if (pts.Sim.Input.Selected.engine[0].getBoolValue() and pts.Controls.Engines.Engine.reverseCmd[0].getValue() == 1) {
	#	var pos = pts.Controls.Engines.Engine.reverseLever[0].getValue();
	#	if (pos > 0.051) {
	#		pts.Controls.Engines.Engine.reverseLever[0].setValue(pos - 0.15);
	#	} else {
	#		interpolate("/engines/engine[0]/reverser-pos-norm", 0, 1.0);
	#		pts.Controls.Engines.Engine.reverseLever[0].setValue(0);
	#		pts.Controls.Engines.Engine.reverseCmd[0].setValue(0);
	#		pts.Fdm.JSBsim.Propulsion.Engine.reverseCmdAngle[0].setValue(0);
	#	}
	#}
	#if (pts.Sim.Input.Selected.engine[1].getBoolValue() and pts.Controls.Engines.Engine.reverseCmd[1].getValue() == 1) {
	#	var pos = pts.Controls.Engines.Engine.reverseLever[1].getValue();
	#	if (pos > 0.051) {
	#		pts.Controls.Engines.Engine.reverseLever[1].setValue(pos - 0.15);
	#	} else {
	#		interpolate("/engines/engine[1]/reverser-pos-norm", 0, 1.0);
	#		pts.Controls.Engines.Engine.reverseLever[1].setValue(0);
	#		pts.Controls.Engines.Engine.reverseCmd[1].setValue(0);
	#		pts.Fdm.JSBsim.Propulsion.Engine.reverseCmdAngle[1].setValue(0);
	#	}
	#}
}