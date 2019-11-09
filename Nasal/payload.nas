# A32X Fuelling and Loading
# Jonathan Redpath

var fuelSvc = {
	enable: props.globals.getNode("/services/fuel-truck/enable"),
	connect: props.globals.getNode("/services/fuel-truck/connect"),
	operate: props.globals.getNode("/services/fuel-truck/operate"),
	Nodes: {
		requestLbs: props.globals.getNode("/services/fuel-truck/request-lbs"),
		requestTotalLbs: props.globals.getNode("/services/fuel-truck/request-total-lbs"),
	},
	
	newRequest: func() {
		if (pts.Sim.aero.getValue() == "A320-200-CFM") {
			me.Nodes.requestTotalLbs.setValue(math.min(pts.Consumables.Fuel.totalFuelLbs.getValue() + me.Nodes.requestLbs.getValue(), 42872));
		} elsif (pts.Sim.aero.getValue() == "A320-200-IAE" or pts.Sim.aero.getValue() == "A320-100-CFM") {
			me.Nodes.requestTotalLbs.setValue(math.min(pts.Consumables.Fuel.totalFuelLbs.getValue() + me.Nodes.requestLbs.getValue(), 42214));
		} elsif (pts.Sim.aero.getValue() == "A320neo-CFM" or pts.Sim.aero.getValue() == "A320neo-PW") {
			me.Nodes.requestTotalLbs.setValue(math.min(pts.Consumables.Fuel.totalFuelLbs.getValue() + me.Nodes.requestLbs.getValue(), 41977));
		}
	},
	
	refuel: func() {
		if (me.operate.getBoolValue()) { return; }
		
		if (me.enable.getValue() and me.connect.getValue()) {
			me.operate.setBoolValue(1);
		}
		
		fuelTimer.start();
		systems.FUEL.refuelling.setBoolValue(1);
		
		systems.FUEL.Valves.refuelLeft.setBoolValue(1);
		systems.FUEL.Valves.refuelRight.setBoolValue(1);
		
		if (pts.Sim.aero.getValue() == "A320-200-CFM" and me.Nodes.requestTotalLbs.getValue() > 28229.9) {
			systems.FUEL.Valves.refuelCenter.setBoolValue(1);
		} elsif ((pts.Sim.aero.getValue() == "A320-200-IAE" or pts.Sim.aero.getValue() == "A320-100-CFM") and me.Nodes.requestTotalLbs.getValue() > 27591.8) {
			systems.FUEL.Valves.refuelCenter.setBoolValue(1);
		} elsif ((pts.Sim.aero.getValue() == "A320neo-CFM" or pts.Sim.aero.getValue() == "A320neo-PW") and me.Nodes.requestTotalLbs.getValue() > 27357.8) {
			systems.FUEL.Valves.refuelCenter.setBoolValue(1);
		}
	},
	
	stop: func() {
		systems.FUEL.refuelling.setBoolValue(0);
		systems.FUEL.Valves.refuelLeft.setBoolValue(0);
		systems.FUEL.Valves.refuelCenter.setBoolValue(0);
		systems.FUEL.Valves.refuelRight.setBoolValue(0);
		me.operate.setBoolValue(0);
	},
};

setlistener("/services/fuel-truck/request-lbs", func() {
	fuelSvc.newRequest();
}, 0, 0);

setlistener("/services/fuel-truck/enable", func() {
	if (!fuelSvc.enable.getBoolValue()) {
		fuelSvc.stop();
	}
}, 0, 0);

setlistener("/services/fuel-truck/connect", func() {
	if (!fuelSvc.connect.getBoolValue()) {
		fuelSvc.stop();
	}
}, 0, 0);

var fuelTimer = maketimer(0.25, func() {
	if (systems.FUEL.Quantity.leftInnerPct.getValue() >= 0.999) {
		systems.FUEL.Valves.refuelLeft.setBoolValue(0);
	}
	
	if (systems.FUEL.Quantity.centerPct.getValue() >= 0.999) {
		systems.FUEL.Valves.refuelCenter.setBoolValue(0);
	}
	
	if (systems.FUEL.Quantity.rightInnerPct.getValue() >= 0.999) {
		systems.FUEL.Valves.refuelRight.setBoolValue(0);
	}
	
	if (abs(pts.Consumables.Fuel.totalFuelLbs.getValue() - fuelSvc.Nodes.requestTotalLbs.getValue()) < 5) {
		fuelSvc.stop();
		fuelTimer.stop();
	}
});