# A3XX Pneumatic System
# Copyright (c) 2019 Jonathan Redpath (legoboyvdlp)

# Local vars
var cabinalt = nil;
var targetalt = nil;
var ambient = nil;
var cabinpsi = nil;
var state1 = nil;
var state2 = nil;
var pressmode = nil;
var wowl = nil;
var wowr = nil;
var vs = nil;
var manvs = nil;
var pause = nil;
var auto = nil;
var speed = nil;
var ditch = nil;
var outflowpos = nil;
var targetvs = nil; 
var eng1_starter = nil;
var eng2_starter = nil;
		
# Main class
var PNEU = {
	Fail: {
		apu: props.globals.getNode("/systems/failures/pneumatics/apu-valve"),
		bleed1: props.globals.getNode("/systems/failures/pneumatics/bleed-1-valve"),
		bleed2: props.globals.getNode("/systems/failures/pneumatics/bleed-2-valve"),
		bmc1: props.globals.getNode("/systems/failures/pneumatics/bmc-1"),
		bmc2: props.globals.getNode("/systems/failures/pneumatics/bmc-2"),
		cabinFans: props.globals.getNode("/systems/failures/pneumatics/cabin-fans"),
		hotAir: props.globals.getNode("/systems/failures/pneumatics/hot-air-valve"),
		hp1Valve: props.globals.getNode("/systems/failures/pneumatics/hp-1-valve"),
		hp2Valve: props.globals.getNode("/systems/failures/pneumatics/hp-2-valve"),
		pack1: props.globals.getNode("/systems/failures/pneumatics/pack-1-valve"),
		pack2: props.globals.getNode("/systems/failures/pneumatics/pack-2-valve"),
		ramAir: props.globals.getNode("/systems/failures/pneumatics/ram-air-valve"),
		trimValveCockpit: props.globals.getNode("/systems/failures/pneumatics/trim-valve-cockpit"),
		trimValveAft: props.globals.getNode("/systems/failures/pneumatics/trim-valve-cabin-aft"),
		trimValveFwd: props.globals.getNode("/systems/failures/pneumatics/trim-valve-cabin-fwd"),
		xbleed: props.globals.getNode("/systems/failures/pneumatics/x-bleed-valve"),
	},
	Packs: {
		packFlow1: props.globals.getNode("/ECAM/Lower/pack-1-flow-output"),
		packFlow2: props.globals.getNode("/ECAM/Lower/pack-2-flow-output"),
		pack1OutTemp: props.globals.getNode("/systems/air-conditioning/packs/pack-1-output-temp"),
		pack2OutTemp: props.globals.getNode("/systems/air-conditioning/packs/pack-2-output-temp"),
		pack1OutletTemp: props.globals.getNode("/systems/air-conditioning/packs/pack-1-outlet-temp"),
		pack2OutletTemp: props.globals.getNode("/systems/air-conditioning/packs/pack-2-outlet-temp"),
		trimCockpit: props.globals.getNode("/ECAM/Lower/trim-cockpit-output"),
		trimAft: props.globals.getNode("/ECAM/Lower/trim-aft-output"),
		trimFwd: props.globals.getNode("/ECAM/Lower/trim-fwd-output"),
		cockpitDuctTemp: props.globals.getNode("/systems/air-conditioning/temperatures/cockpit-duct"),
		cabinAftDuctTemp: props.globals.getNode("/systems/air-conditioning/temperatures/cabin-aft-duct"),
		cabinFwdDuctTemp: props.globals.getNode("/systems/air-conditioning/temperatures/cabin-fwd-duct"),
		cockpitTemp: props.globals.getNode("/systems/air-conditioning/temperatures/cockpit-temp"),
		cabinAftTemp: props.globals.getNode("/systems/air-conditioning/temperatures/cabin-aft-temp"),
		cabinFwdTemp: props.globals.getNode("/systems/air-conditioning/temperatures/cabin-fwd-temp"),
	},
	Psi: {
		engine1: props.globals.getNode("/systems/pneumatics/psi/engine-1-psi"),
		engine2: props.globals.getNode("/systems/pneumatics/psi/engine-2-psi"),
	},
	Switch: {
		apu: props.globals.getNode("/controls/pneumatics/switches/apu"),
		bleed1: props.globals.getNode("/controls/pneumatics/switches/bleed-1"),
		bleed2: props.globals.getNode("/controls/pneumatics/switches/bleed-2"),
		blower: props.globals.getNode("/controls/pneumatics/switches/blower"),
		cabinFans: props.globals.getNode("/controls/pneumatics/switches/cabin-fans"),
		extract: props.globals.getNode("/controls/pneumatics/switches/extract"),
		hotAir: props.globals.getNode("/controls/pneumatics/switches/hot-air"),
		pack1: props.globals.getNode("/controls/pneumatics/switches/pack-1"),
		pack2: props.globals.getNode("/controls/pneumatics/switches/pack-2"),
		packFlow: props.globals.getNode("/controls/pneumatics/switches/pack-flow"),
		ramAir: props.globals.getNode("/controls/pneumatics/switches/ram-air"),
		tempAft: props.globals.getNode("/controls/pneumatics/switches/temp-cabin-aft"),
		tempFwd: props.globals.getNode("/controls/pneumatics/switches/temp-cabin-fwd"),
		tempCockpit: props.globals.getNode("/controls/pneumatics/switches/temp-cockpit"),
		xbleed: props.globals.getNode("/controls/pneumatics/switches/x-bleed"),
	},
	Warnings: {
		prv1Disag: props.globals.getNode("/systems/pneumatics/valves/engine-1-prv-valve-disag"),
		prv2Disag: props.globals.getNode("/systems/pneumatics/valves/engine-2-prv-valve-disag"),
		ovht1: props.globals.getNode("/systems/pneumatics/warnings/ovht-1-mem"),
		ovht2: props.globals.getNode("/systems/pneumatics/warnings/ovht-2-mem"),
		overpress1: props.globals.getNode("/systems/pneumatics/warnings/overpress-1-mem"),
		overpress2: props.globals.getNode("/systems/pneumatics/warnings/overpress-2-mem"),
	},
	Valves: {
		apu: props.globals.getNode("/systems/pneumatics/valves/apu-bleed-valve"),
		crossbleed: props.globals.getNode("/systems/pneumatics/valves/crossbleed-valve"),
		prv1: props.globals.getNode("/systems/pneumatics/valves/engine-1-prv-valve"),
		prv2: props.globals.getNode("/systems/pneumatics/valves/engine-2-prv-valve"),
		pack1: props.globals.getNode("/systems/air-conditioning/valves/flow-control-valve-1"),
		pack2: props.globals.getNode("/systems/air-conditioning/valves/flow-control-valve-2"),
		ramAir: props.globals.getNode("/systems/air-conditioning/valves/ram-air"),
		hotAir: props.globals.getNode("/systems/air-conditioning/valves/hot-air"),
		starter1: props.globals.getNode("/systems/pneumatics/valves/starter-valve-1"),
		starter2: props.globals.getNode("/systems/pneumatics/valves/starter-valve-2"),
		wingLeft: props.globals.getNode("/systems/pneumatics/valves/wing-ice-1"),
		wingRight: props.globals.getNode("/systems/pneumatics/valves/wing-ice-2"),
	},
	pressMode: props.globals.getNode("/systems/pressurization/mode", 1),
	init: func() {
		me.resetFail();
		
		# Legacy pressurization system
		setprop("/systems/pressurization/mode", "GN");
		setprop("/systems/pressurization/vs", "0");
		setprop("/systems/pressurization/targetvs", "0");
		setprop("/systems/pressurization/vs-norm", "0");
		setprop("/systems/pressurization/auto", 1);
		setprop("/systems/pressurization/deltap", "0");
		setprop("/systems/pressurization/outflowpos", "0");
		setprop("/systems/pressurization/deltap-norm", "0");
		setprop("/systems/pressurization/outflowpos-norm", "0");
		setprop("/systems/pressurization/outflowpos-man", "0.5");
		setprop("/systems/pressurization/outflowpos-man-sw", "0");
		setprop("/systems/pressurization/outflowpos-norm-cmd", "0");
		setprop("/systems/pressurization/cabinalt", pts.Instrumentation.Altimeter.indicatedFt.getValue());
		setprop("/systems/pressurization/targetalt", pts.Instrumentation.Altimeter.indicatedFt.getValue()); 
		setprop("/systems/pressurization/diff-to-target", "0");
		setprop("/systems/pressurization/ditchingpb", 0);
		setprop("/systems/pressurization/targetvs", "0");
		setprop("/systems/pressurization/ambientpsi", "0");
		setprop("/systems/pressurization/cabinpsi", "0");
		setprop("/systems/pressurization/manvs-cmd", "0");
		setprop("/systems/pressurization/pack-1-out-temp", 0);
		setprop("/systems/pressurization/pack-2-out-temp", 0);
		setprop("/systems/pressurization/pack-1-bypass", 0);
		setprop("/systems/pressurization/pack-2-bypass", 0);
		setprop("/systems/pressurization/pack-1-flow", 0);
		setprop("/systems/pressurization/pack-2-flow", 0);
		setprop("/systems/pressurization/pack-1-comp-out-temp", 0);
		setprop("/systems/pressurization/pack-2-comp-out-temp", 0);
		setprop("/systems/pressurization/pack-1-valve", 0);
		setprop("/systems/pressurization/pack-2-valve", 0);
		#setprop("/systems/ventilation/cabin/fans", 0); # aircon fans
		#setprop("/systems/ventilation/avionics/extractvalve", "0");
		#setprop("/systems/ventilation/avionics/inletvalve", "0");
		setprop("/controls/oxygen/masksDeploy", 0);
		setprop("/controls/oxygen/masksDeployMan", 0);
		setprop("/controls/oxygen/masksReset", 0); # this is the TMR RESET pb on the maintenance panel, needs 3D model
		setprop("/controls/oxygen/masksSys", 0);
	},
	resetFail: func() {
		me.Fail.apu.setBoolValue(0);
		me.Fail.bleed1.setBoolValue(0);
		me.Fail.bleed2.setBoolValue(0);
		me.Fail.cabinFans.setBoolValue(0);
		me.Fail.hotAir.setBoolValue(0);
		me.Fail.hp1Valve.setBoolValue(0);
		me.Fail.hp2Valve.setBoolValue(0);
		me.Fail.pack1.setBoolValue(0);
		me.Fail.pack2.setBoolValue(0);
		me.Fail.ramAir.setBoolValue(0);
		me.Fail.trimValveCockpit.setBoolValue(0);
		me.Fail.trimValveAft.setBoolValue(0);
		me.Fail.trimValveFwd.setBoolValue(0);
		me.Fail.xbleed.setBoolValue(0);
	},
	loop: func() {
		wowl = getprop("gear/gear[1]/wow");
		wowr = getprop("gear/gear[2]/wow");
		
		# Legacy pressurization
		cabinalt = getprop("/systems/pressurization/cabinalt");
		targetalt = getprop("/systems/pressurization/targetalt");
		ambient = getprop("/systems/pressurization/ambientpsi");
		cabinpsi = getprop("/systems/pressurization/cabinpsi");
		state1 = pts.Systems.Thrust.state[0].getValue();
		state2 = pts.Systems.Thrust.state[1].getValue();
		pressmode = getprop("/systems/pressurization/mode");
		vs = getprop("/systems/pressurization/vs-norm");
		manvs = getprop("/systems/pressurization/manvs-cmd");
		pause = getprop("/sim/freeze/master");
		auto = getprop("/systems/pressurization/auto");
		speed = getprop("velocities/groundspeed-kt");
		ditch = getprop("/systems/pressurization/ditchingpb");
		outflowpos = getprop("/systems/pressurization/outflowpos");
		targetvs = getprop("/systems/pressurization/targetvs");
		
		setprop("/systems/pressurization/diff-to-target", targetalt - cabinalt); 
		setprop("/systems/pressurization/deltap", cabinpsi - ambient); 

		if ((pressmode == "GN") and (pressmode != "CL") and (wowl and wowr) and ((state1 == "MCT") or (state1 == "TOGA")) and ((state2 == "MCT") or (state2 == "TOGA"))) {
			setprop("/systems/pressurization/mode", "TO");
		} else if (((!wowl) or (!wowr)) and (speed > 100) and (pressmode == "TO")) {
			setprop("/systems/pressurization/mode", "CL");	
		}
		
		if (vs != targetvs and !wowl and !wowr) {
			setprop("/systems/pressurization/vs", targetvs);
		}
		
		if (cabinalt != targetalt and !wowl and !wowr and !pause and auto) {
			setprop("/systems/pressurization/cabinalt", cabinalt + ((vs / 60) / 10));
		} else if (!auto and !pause) {
			setprop("/systems/pressurization/cabinalt", cabinalt + ((manvs / 60) / 10));
		}
		
		#if (ditch and auto) {
			#setprop("/systems/pressurization/outflowpos", "1");
			#setprop("/systems/ventilation/avionics/extractvalve", "1");
			#setprop("/systems/ventilation/avionics/inletvalve", "1");
		#}
		
		# Oxygen
		if (cabinalt > 13500) { 
			setprop("/controls/oxygen/masksDeploy", 1);
			setprop("/controls/oxygen/masksSys", 1);
		}
	},
};


# Oxygen (Cabin)

setlistener("/controls/oxygen/masksDeployMan", func {
	guard = getprop("/controls/oxygen/masksGuard");
	masks = getprop("/controls/oxygen/masksDeployMan");
	
	if (guard and masks) {
		setprop("/controls/oxygen/masksDeployMan", 0);
	} else if (!guard and masks) {
		setprop("/controls/oxygen/masksDeployMan", 1);
		setprop("/controls/oxygen/masksDeploy", 1);
		setprop("/controls/oxygen/masksSys", 1);
	}
}, 0, 0);

setlistener("/controls/oxygen/masksDeployMan", func {
	masks = getprop("/controls/oxygen/masksDeployMan");
	autoMasks = getprop("/controls/oxygen/masksDeploy");
	if (!masks) { 
		setprop("/controls/oxygen/masksDeployMan", 1);
	}
}, 0, 0);

setlistener("/controls/oxygen/masksDeploy", func {
	masks = getprop("/controls/oxygen/masksDeployMan");
	autoMasks = getprop("/controls/oxygen/masksDeploy");
	if (!autoMasks) { 
		setprop("/controls/oxygen/masksDeploy", 1);
	}
}, 0, 0);