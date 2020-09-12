# A3XX CFM FADEC by Joshua Davidson (Octal450)

# Copyright (c) 2020 Josh Davidson (Octal450)

setprop("/systems/fadec/n1mode1", 0); # Doesn't do anything, just here for other logic #
setprop("/systems/fadec/n1mode2", 0); # Doesn't do anything, just here for other logic #
setprop("/systems/fadec/eng1/egt", 1);
setprop("/systems/fadec/eng1/n1", 1);
setprop("/systems/fadec/eng1/n2", 1);
setprop("/systems/fadec/eng1/ff", 1);
setprop("/systems/fadec/eng2/egt", 1);
setprop("/systems/fadec/eng2/n1", 1);
setprop("/systems/fadec/eng2/n2", 1);
setprop("/systems/fadec/eng2/ff", 1);
setprop("/systems/fadec/power-avail", 0);
setprop("/systems/fadec/powered1", 0);
setprop("/systems/fadec/powered2", 0);
setprop("/systems/fadec/powered-time", -300);
setprop("/systems/fadec/powerup", 0);
setprop("/systems/fadec/eng1-master-count", 0);
setprop("/systems/fadec/eng1-master-time", -300);
setprop("/systems/fadec/eng1-off-power", 0);
setprop("/systems/fadec/eng2-master-count", 0);
setprop("/systems/fadec/eng2-master-time", -300);
setprop("/systems/fadec/eng2-off-power", 0);

var FADEC = {
	init: func() {
		setprop("/systems/fadec/powered-time", 0);
		setprop("/systems/fadec/eng1-master-time", -300);
		setprop("/systems/fadec/eng2-master-time", -300);
	},
	loop: func() {
		var ac1 = systems.ELEC.Bus.ac1.getValue();
		var ac2 = systems.ELEC.Bus.ac2.getValue();
		var acess = systems.ELEC.Bus.acEss.getValue();
		var state1 = pts.Engines.Engine.state[0].getValue();
		var state2 = pts.Engines.Engine.state[1].getValue();
		var master1 = pts.Controls.Engines.Engine.cutoffSw[0].getValue();
		var master2 = pts.Controls.Engines.Engine.cutoffSw[1].getValue();
		var modeSel = pts.Controls.Engines.startSw.getValue();
		var elapsedSec = pts.Sim.Time.elapsedSec.getValue();
		
		if (ac1 >= 110 or ac2 >= 110 or acess >= 110) {
			if (getprop("/systems/fadec/power-avail") != 1) {
				setprop("/systems/fadec/powered-time", elapsedSec);
				setprop("/systems/fadec/power-avail", 1);
			}
		} else {
			if (getprop("/systems/fadec/power-avail") != 0) {
				setprop("/systems/fadec/power-avail", 0);
			}
		}
		
		var powerAvail = getprop("/systems/fadec/power-avail");
		
		if (getprop("/systems/fadec/powered-time") + 300 >= elapsedSec) {
			setprop("/systems/fadec/powerup", 1);
		} else {
			setprop("/systems/fadec/powerup", 0);	
		}
		
		if (master1 == 1) {
			if (getprop("/systems/fadec/eng1-master-count") != 1) {
				setprop("/systems/fadec/eng1-master-time", elapsedSec);
				setprop("/systems/fadec/eng1-master-count", 1);
			}
		} else {
			if (getprop("/systems/fadec/eng1-master-count") != 0) {
				setprop("/systems/fadec/eng1-master-count", 0);
			}
		}
		
		if (getprop("/systems/fadec/eng1-master-time") + 300 >= elapsedSec) {
			setprop("/systems/fadec/eng1-off-power", 1);
		} else {
			setprop("/systems/fadec/eng1-off-power", 0);
		}
		
		if (master2 == 1) {
			if (getprop("/systems/fadec/eng2-master-count") != 1) {
				setprop("/systems/fadec/eng2-master-time", elapsedSec);
				setprop("/systems/fadec/eng2-master-count", 1);
			}
		} else {
			if (getprop("/systems/fadec/eng2-master-count") != 0) {
				setprop("/systems/fadec/eng2-master-count", 0);
			}
		}
		
		if (getprop("/systems/fadec/eng2-master-time") + 300 >= elapsedSec) {
			setprop("/systems/fadec/eng2-off-power", 1);
		} else {
			setprop("/systems/fadec/eng2-off-power", 0);
		}
		
		if (state1 == 3) {
			setprop("/systems/fadec/powered1", 1);
		} else if (powerAvail and modeSel == 2) {
			setprop("/systems/fadec/powered1", 1);
		} else {
			setprop("/systems/fadec/powered1", 0);
		}
		
		if (state2 == 3) {
			setprop("/systems/fadec/powered2", 1);
		} else if (powerAvail and modeSel == 2) {
			setprop("/systems/fadec/powered2", 1);
		} else {
			setprop("/systems/fadec/powered2", 0);
		}
		
		var powered1 = getprop("/systems/fadec/powered1");
		var powered2 = getprop("/systems/fadec/powered2");
		
		if (powered1 or getprop("/systems/fadec/powerup") or getprop("/systems/fadec/eng1-off-power")) {
			setprop("/systems/fadec/eng1/n1", 1);
			setprop("/systems/fadec/eng1/egt", 1);
			setprop("/systems/fadec/eng1/n2", 1);
			setprop("/systems/fadec/eng1/ff", 1);
		} else {
			setprop("/systems/fadec/eng1/n1", 0);
			setprop("/systems/fadec/eng1/egt", 0);
			setprop("/systems/fadec/eng1/n2", 0);
			setprop("/systems/fadec/eng1/ff", 0);
		}
		
		if (powered2 or getprop("/systems/fadec/powerup") or getprop("/systems/fadec/eng2-off-power")) {
			setprop("/systems/fadec/eng2/n1", 1);
			setprop("/systems/fadec/eng2/egt", 1);
			setprop("/systems/fadec/eng2/n2", 1);
			setprop("/systems/fadec/eng2/ff", 1);
		} else {
			setprop("/systems/fadec/eng2/n1", 0);
			setprop("/systems/fadec/eng2/egt", 0);
			setprop("/systems/fadec/eng2/n2", 0);
			setprop("/systems/fadec/eng2/ff", 0);
		}
	},
};
