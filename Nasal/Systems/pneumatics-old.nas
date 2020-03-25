# A3XX Pneumatic System
# Copyright (c) 2019 Jonathan Redpath (legoboyvdlp)

# Local vars

# Main class
var PNEU = {
	Fail: {
		apu: props.globals.getNode("systems/failures/pneumatics/apu-valve");
		bleed1: props.globals.getNode("systems/failures/pneumatics/bleed-1-valve");
		bleed2: props.globals.getNode("systems/failures/pneumatics/bleed-2-valve");
		cabinFans: props.globals.getNode("systems/failures/pneumatics/cabin-fans");
		hotAir: props.globals.getNode("systems/failures/pneumatics/hot-air");
		pack1: props.globals.getNode("systems/failures/pneumatics/pack-1-valve");
		pack2: props.globals.getNode("systems/failures/pneumatics/pack-2-valve");
		ramAir: props.globals.getNode("systems/failures/pneumatics/ram-air");
		trimValveCockpit: props.globals.getNode("systems/failures/pneumatics/trim-valve-cockpit");
		trimValveAft: props.globals.getNode("systems/failures/pneumatics/trim-valve-cabin-aft");
		trimValveFwd: props.globals.getNode("systems/failures/pneumatics/trim-valve-cabin-fwd");
		xbleed: props.globals.getNode("systems/failures/pneumatics/x-bleed-valve");
	}
	Psi: {
	},
	Switch: {
		apu: props.globals.getNode("controls/pneumatics/switches/apu");
		bleed1: props.globals.getNode("controls/pneumatics/switches/bleed-1");
		bleed2: props.globals.getNode("controls/pneumatics/switches/bleed-2");
		blower: props.globals.getNode("controls/pneumatics/switches/blower");
		cabinFans: props.globals.getNode("controls/pneumatics/switches/cabin-fans");
		extract: props.globals.getNode("controls/pneumatics/switches/extract");
		hotAir: props.globals.getNode("controls/pneumatics/switches/hot-air");
		pack1: props.globals.getNode("controls/pneumatics/switches/pack-1");
		pack2: props.globals.getNode("controls/pneumatics/switches/pack-2");
		packFlow: props.globals.getNode("controls/pneumatics/switches/pack-flow");
		ramAir: props.globals.getNode("controls/pneumatics/switches/ram-air");
		tempCockpit: props.globals.getNode("controls/pneumatics/switches/temp-cockpit");
		tempAft: props.globals.getNode("controls/pneumatics/switches/temp-cabin-aft");
		tempFwd: props.globals.getNode("controls/pneumatics/switches/temp-cabin-fwd");
		xbleed: props.globals.getNode("controls/pneumatics/switches/x-bleed");
	},
	init: func() {
		me.resetFail();
	},
	resetFail: func() {
		me.Fail.apu.setBoolValue(0);
		me.Fail.bleed1.setBoolValue(0);
		me.Fail.bleed2.setBoolValue(0);
		me.Fail.cabinFans.setBoolValue(0);
		me.Fail.hotAir.setBoolValue(0);
		me.Fail.pack1.setBoolValue(0);
		me.Fail.pack2.setBoolValue(0);
		me.Fail.ramAir.setBoolValue(0);
		me.Fail.trimValveCockpit.setBoolValue(0);
		me.Fail.trimValveAft.setBoolValue(0);
		me.Fail.trimValveFwd.setBoolValue(0);
		me.Fail.xbleed.setBoolValue(0);
	},
	loop: func() {
		
	},
}