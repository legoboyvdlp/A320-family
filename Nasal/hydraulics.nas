# A3XX Hydraulic System
# Jonathan Redpath

# Copyright (c) 2019 Jonathan Redpath


var HYD = {
	Fail: {
		blueElec: props.globals.getNode("/systems/failures/hydraulic/blue-elec"),
		blueLeak: props.globals.getNode("/systems/failures/hydraulic/blue-leak"),
		greenEng: props.globals.getNode("/systems/failures/hydraulic/green-edp"),
		greenLeak: props.globals.getNode("/systems/failures/hydraulic/green-leak"),
		ptuFault: props.globals.getNode("/systems/failures/hydraulic/ptu"),
		yellowEng: props.globals.getNode("/systems/failures/hydraulic/yellow-edp"),
		yellowElec: props.globals.getNode("/systems/failures/hydraulic/yellow-elec"),
		yellowLeak: props.globals.getNode("/systems/failures/hydraulic/yellow-leak"),
	},
	Psi: {
	},
	Qty: {
		blueInput: props.globals.initNode("/systems/hydraulic/blue-qty-input", 0, "INT"),
		greenInput: props.globals.initNode("/systems/hydraulic/green-qty-input", 0, "INT"),
		yellowInput: props.globals.initNode("/systems/hydraulic/yellow-qty-input", 0, "INT"),
	},
	Switch: {
		blueElec: props.globals.getNode("/controls/hydraulic/switches/blue-elec"),
		blueElecOvrd: props.globals.getNode("/controls/hydraulic/switches/blue-elec-ovrd"),
		greenEDP: props.globals.getNode("/controls/hydraulic/switches/green-edp"),
		ptu: props.globals.getNode("/controls/hydraulic/switches/ptu"),
		rat: props.globals.getNode("/controls/hydraulic/switches/rat-man"),
		yellowEDP: props.globals.getNode("/controls/hydraulic/switches/yellow-edp"),
		yellowElec: props.globals.getNode("/controls/hydraulic/switches/yellow-elec"),
	},
	init: func() {
		me.resetFail();
		me.Qty.blueInput.setValue(math.round((rand() * 4) + 8 , 0.1)); # Random between 8 and 12
		me.Qty.greenInput.setValue(math.round((rand() * 4) + 8 , 0.1)); # Random between 8 and 12
		me.Qty.yellowInput.setValue(math.round((rand() * 4) + 8 , 0.1)); # Random between 8 and 12
		me.Switch.blueElec.setValue(1);
		me.Switch.blueElecOvrd.setValue(0);
		me.Switch.greenEDP.setValue(1);
		me.Switch.ptu.setValue(1);
		me.Switch.rat.setValue(0);
		me.Switch.yellowEDP.setValue(1);
		me.Switch.yellowElec.setValue(0);
	},
	resetFail: func() {
		me.Fail.blueElec.setBoolValue(0);
		me.Fail.blueLeak.setBoolValue(0);
		me.Fail.greenEng.setBoolValue(0);
		me.Fail.greenLeak.setBoolValue(0);
		me.Fail.ptuFault.setBoolValue(0);
		me.Fail.yellowEng.setBoolValue(0);
		me.Fail.yellowElec.setBoolValue(0);
		me.Fail.yellowLeak.setBoolValue(0);
	},
	loop: func() {
	},
};

setlistener("/controls/gear/gear-down", func {
	down = getprop("/controls/gear/gear-down");
	if (!down and (getprop("/gear/gear[0]/wow") or getprop("/gear/gear[1]/wow") or getprop("/gear/gear[2]/wow"))) {
		setprop("/controls/gear/gear-down", 1);
	}
});
