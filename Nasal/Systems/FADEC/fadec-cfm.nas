# A3XX CFM FADEC by Joshua Davidson (Octal450)

# Copyright (c) 2020 Josh Davidson (Octal450)

var powerAvailTemp = nil;
var master1 = nil;
var master2 = nil;
var state1 = nil;
var state2 = nil;
var modeSel = nil;
var powered1 = nil;
var powered2 = nil;
var powerup = nil;
var N11 = nil;
var N12 = nil;
var N21 = nil;
var N22 = nil;

var FADEC = {
	Power: {
		powered1: props.globals.initNode("/systems/fadec/powered1", 0, "BOOL"),
		powered2: props.globals.initNode("/systems/fadec/powered2", 0, "BOOL"),
		powerup: props.globals.initNode("/systems/fadec/powerup", 0, "BOOL"),
		powerAvail: props.globals.initNode("/systems/fadec/power-avail", 0, "BOOL"),
		poweredTime: props.globals.initNode("/systems/fadec/powered-time", 0, "DOUBLE"),
	},
	Eng1: {
		eng1Time: props.globals.initNode("/systems/fadec/eng1-master-time", -300, "DOUBLE"),
		eng1Off: props.globals.initNode("/systems/fadec/eng1-off-power", 0, "BOOL"),
		eng1Counting: 0,
		epr: props.globals.initNode("/systems/fadec/eng1/epr", 0, "BOOL"),
		egt: 0,
		n1: props.globals.initNode("/systems/fadec/eng1/n1", 0, "BOOL"),
		n2: 0,
		ff: 0,
	},
	Eng2: {
		eng2Time: props.globals.initNode("/systems/fadec/eng2-master-time", -300, "DOUBLE"),
		eng2Off: props.globals.initNode("/systems/fadec/eng2-off-power", 0, "BOOL"),
		eng2Counting: 0,
		epr: props.globals.initNode("/systems/fadec/eng2/epr", 0, "BOOL"),
		egt: 0,
		n1: props.globals.initNode("/systems/fadec/eng2/n1", 0, "BOOL"),
		n2: 0,
		ff: 0,
	},
	Switches: {
		n1ModeSwitch1: props.globals.initNode("/controls/fadec/n1mode1", 0, "BOOL"),
		n1ModeSwitch2: props.globals.initNode("/controls/fadec/n1mode2", 0, "BOOL"),
	},
	Modes: {
		n1Mode1: props.globals.initNode("/systems/fadec/n1mode1", 0, "BOOL"),  # 0 == EPR, 1 == N1 Rated, 2 == N1 Unrated #
		n1Mode2: props.globals.initNode("/systems/fadec/n1mode2", 0, "BOOL"),
	},
	init: func() {
		me.Power.poweredTime.setValue(-300);
		me.Eng1.eng1Time.setValue(-300);
		me.Eng2.eng2Time.setValue(-300);
	},
	loop: func() {
		var elapsedSec = pts.Sim.Time.elapsedSec.getValue();
		powerAvailTemp = me.Power.powerAvail.getValue();
		
		if (systems.ELEC.Bus.ac1.getValue() >= 110 or systems.ELEC.Bus.ac2.getValue() >= 110 or systems.ELEC.Bus.acEss.getValue() >= 110) {
			if (powerAvailTemp != 1) {
				me.Power.poweredTime.setValue(elapsedSec);
				me.Power.powerAvail.setValue(1);
			}
		} else {
			if (powerAvailTemp != 0) {
				me.Power.powerAvail.setValue(0);
			}
		}
		
		powerAvailTemp = me.Power.powerAvail.getValue();
		
		if (me.Power.poweredTime.getValue() + 300 >= elapsedSec) {
			if (!me.Power.powerup.getValue()) {
				me.Power.powerup.setValue(1);
			}
		} else {
			if (me.Power.powerup.getValue()) {
				me.Power.powerup.setValue(0);
			}
		}
		
		master1 = pts.Controls.Engines.Engine.cutoffSw[0].getValue();
		
		if (master1 == 1) {
			if (me.Eng1.eng1Counting != 1) {
				me.Eng1.eng1Time.setValue(elapsedSec);
				me.Eng1.eng1Counting = 1;
			}
		} else {
			if (me.Eng1.eng1Counting != 0) {
				me.Eng1.eng1Counting = 0;
			}
		}
		
		if (me.Eng1.eng1Time.getValue() + 300 >= elapsedSec) {
			me.Eng1.eng1Off.setValue(1);
		} else {
			me.Eng1.eng1Off.setValue(0);
		}
		
		master2 = pts.Controls.Engines.Engine.cutoffSw[1].getValue();
		
		if (master2 == 1) {
			if (me.Eng2.eng2Counting != 1) {
				me.Eng2.eng2Time.setValue(elapsedSec);
				me.Eng2.eng2Counting = 1;
			}
		} else {
			if (me.Eng2.eng2Counting != 0) {
				me.Eng2.eng2Counting = 0;
			}
		}
		
		if (me.Eng2.eng2Time.getValue() + 300 >= elapsedSec) {
			me.Eng2.eng2Off.setValue(1);
		} else {
			me.Eng2.eng2Off.setValue(0);
		}
		
		state1 = pts.Engines.Engine.state[0].getValue();
		state2 = pts.Engines.Engine.state[1].getValue();
		modeSel =  pts.Controls.Engines.startSw.getValue();
		
		if (state1 == 3) {
			me.Power.powered1.setValue(1);
		} else if (powerAvailTemp and modeSel == 2) {
			me.Power.powered1.setValue(1);
		} else {
			me.Power.powered1.setValue(0);
		}
		
		if (state2 == 3) {
			me.Power.powered2.setValue(1);
		} else if (powerAvailTemp and modeSel == 2) {
			me.Power.powered2.setValue(1);
		} else {
			me.Power.powered2.setValue(0);
		}
		
		powered1 = me.Power.powered1.getValue();
		powered2 = me.Power.powered2.getValue();
		powerup = me.Power.powerup.getValue();
		
		if (powered1 or powerup or me.Eng1.eng1Off.getValue()) {
			me.Eng1.n1.setValue(1);
			me.Eng1.n2 = 1;
			me.Eng1.egt = 1;
			me.Eng1.ff = 1;
		} else {
			me.Eng1.n1.setValue(0);
			me.Eng1.n2 = 0;
			me.Eng1.egt = 0;
			me.Eng1.ff = 0;
		}
		
		if (powered2 or powerup or me.Eng2.eng2Off.getValue()) {
			me.Eng2.n1.setValue(1);
			me.Eng2.n2 = 1;
			me.Eng2.egt = 1;
			me.Eng2.ff = 1;
		} else {
			me.Eng2.n1.setValue(0);
			me.Eng2.n2 = 0;
			me.Eng2.egt = 0;
			me.Eng2.ff = 0;
		}
	},
};
