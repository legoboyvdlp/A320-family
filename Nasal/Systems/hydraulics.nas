# A3XX Hydraulic System
# Jonathan Redpath

# Copyright (c) 2019 Jonathan Redpath

var HYD = {
	Brakes: {
		accumPressPsi: props.globals.initNode("/systems/hydraulic/brakes/accumulator-pressure-psi", 0, "INT"),
		leftPressPsi: props.globals.initNode("/systems/hydraulic/brakes/pressure-left-psi", 0, "INT"),
		rightPressPsi: props.globals.initNode("/systems/hydraulic/brakes/pressure-right-psi", 0, "INT"),
		askidSw: props.globals.initNode("/systems/hydraulic/brakes/askidnwssw", 1, "BOOL"),
		mode: props.globals.initNode("/systems/hydraulic/brakes/mode", 0, "INT"),
		lbrake: props.globals.initNode("/systems/hydraulic/brakes/lbrake", 0, "INT"),
		rbrake: props.globals.initNode("/systems/hydraulic/brakes/rbrake", 0, "INT"),
		noserubber: props.globals.initNode("/systems/hydraulic/brakes/nose-rubber", 0, "INT"),
		counter: props.globals.initNode("/systems/hydraulic/brakes/counter", 0, "INT"),
	},
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
		blue: props.globals.getNode("/systems/hydraulic/blue-psi"),
		green: props.globals.getNode("/systems/hydraulic/green-psi"),
		yellow: props.globals.getNode("/systems/hydraulic/yellow-psi"),
	},
	Ptu: {
		active: props.globals.getNode("/systems/hydraulic/sources/ptu/ptu-hydraulic-condition"),
		diff: props.globals.getNode("/systems/hydraulic/yellow-psi-diff"),
	},
	Pump: {
		yellowElec: props.globals.getNode("/systems/hydraulic/sources/yellow-elec/pump-operate"),
	},
	Qty: {
		blueInput: props.globals.initNode("/systems/hydraulic/blue-qty-input", 0, "INT"),
		blue: props.globals.getNode("/systems/hydraulic/blue-qty"),
		greenInput: props.globals.initNode("/systems/hydraulic/green-qty-input", 0, "INT"),
		green: props.globals.getNode("/systems/hydraulic/green-qty"),
		yellowInput: props.globals.initNode("/systems/hydraulic/yellow-qty-input", 0, "INT"),
		yellow: props.globals.getNode("/systems/hydraulic/yellow-qty"),
	},
	Rat: {
		position: props.globals.getNode("/systems/hydraulic/sources/rat/position"),
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
	Valve: {
		yellowFire: props.globals.getNode("/systems/hydraulic/sources/yellow-edp/fire-valve"),
		greenFire: props.globals.getNode("/systems/hydraulic/sources/green-edp/fire-valve"),
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
		if (me.Brakes.mode.getValue() == 2) {
			if (me.Psi.yellow.getValue() > 2500 and me.Brakes.accumPressPsi.getValue() < 700) {
				me.Brakes.accumPressPsi.setValue(me.Brakes.accumPressPsi.getValue() + 50);
			}
		}
	},
};

setlistener("/controls/gear/gear-down", func {
	if (!pts.Controls.Gear.gearDown.getValue() and (pts.Gear.wow[0].getValue() or pts.Gear.wow[1].getValue() or pts.Gear.wow[2].getValue())) {
		pts.Controls.Gear.gearDown.setValue(1);
	}
});
