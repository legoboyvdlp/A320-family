# A3XX Icing System
# Jonathan Redpath (legoboyvdlp)

# Copyright (c) 2020 Josh Davidson (Octal450)


### Ice sensitive components definition.
var Iceable = {
	new: func(node) {
		var m = { parents: [Iceable] };
		m.ice_inches = node.getNode("ice-inches", 1);
		m.sensitivity = node.getNode("sensitivity", 1);

		var deice_prop = node.getValue("salvage-control");
		m.deice = deice_prop ? props.globals.getNode(deice_prop, 1) : nil;
		var output_prop = node.getValue("output-property");
		m.output = output_prop ? props.globals.getNode(output_prop, 1): nil;

		return m;
	},

	update: func(factor, melt) {
		var icing = me.ice_inches.getValue();
		if(me.deice != nil and me.deice.getBoolValue()) {
			icing += melt;
		} else {
			icing += factor * me.sensitivity.getValue();
		}
		if(icing < 0) icing = 0;

		me.ice_inches.setValue(icing);
		if(me.output != nil) me.output.setValue(icing);
	},
};


### Icing parameters computation.
# Environmental parameters of the icing model.
var environment = {
	dewpoint: props.globals.getNode("/environment/dewpoint-degc"),
	temperature: props.globals.getNode("/environment/temperature-degc"),
	visibility: props.globals.getNode("/environment/effective-visibility-m"),
	visibLclWx: props.globals.getNode("/environment/visibility-m"),
};

var effects = {
	frost_inch: props.globals.getNode("/environment/aircraft-effects/frost-inch", 1),
	frost_norm: props.globals.getNode("/environment/aircraft-effects/frost-level"),
};


# Icing factor computation.

var severity_factor_table = [
	-0.00000166,
	0.00000277,
	0.00000277,
	0.00000554,
	0.00001108,
	0.00002216,
];

var melt_factor = -0.00005;

var temperature = 0;
var spread = 0;
var icingCond = 0;
var severity = 0;

var icing_factor = func() {
	temperature = environment.temperature.getValue();

	# Do we create ice?
	spread = temperature - environment.dewpoint.getValue();
	# freezing fog or low temp and below dp or in advanced wx cloud
	icingCond = ((spread < 0.1 or environment.visibility.getValue() < 1000 or environment.visibLclWx.getValue() < 5000)
					 and temperature < 0);

	severity = 0;
	if (icingCond) {
		if (temperature >= -2) {
			severity = 1;
		} else if (temperature >= -12) {
			severity = 3;
		} else if (temperature >= -30) {
			severity = 5;
		} else if (temperature >= -40) {
			severity = 3;
		} else if (temperature >= -99) {
			severity = 1;
		}
	}

	return severity_factor_table[severity];
}


var speed = 0;
var windowprobe = 0;
var wingBtn = 0;
var wingFault = 0;
var PSI = 0;
var wowl = 0;
var wowr = 0;
var PitotIcing = 0;
var PitotFailed = 0;
var lengBtn = 0;
var lengFault = 0;
var rengBtn = 0;
var rengFault = 0;
var WingHasBeenTurnedOff = 0;
var GroundModeFinished = 0;
var windowprb = 0;
var stateL = 0;
var stateR = 0;

var iceables = [];

var PitotIcing = [props.globals.getNode("/systems/pitot[0]/icing"),props.globals.getNode("/systems/pitot[1]/icing"),props.globals.getNode("/systems/pitot[2]/icing")];
var PitotServicable = [props.globals.getNode("/systems/pitot[0]/serviceable", 1),props.globals.getNode("/systems/pitot[1]/serviceable", 1),props.globals.getNode("/systems/pitot[2]/serviceable"), 1];

var icingInit = func {
	iceables = props.globals.getNode("/sim/model/icing", 1).getChildren("iceable");
	forindex(var i; iceables) {
		iceables[i] = Iceable.new(iceables[i]);
	}

	icing_timer.start();
}

var icingModel = func {
	var factor = icing_factor();
	foreach(iceable; iceables) {
		iceable.update(factor, melt_factor);
	}

	effects.frost_norm.setDoubleValue(effects.frost_inch.getValue() * 50);
	
	for (var i = 0; i <= 2; i = i + 1) {
		if (PitotIcing[i].getValue() > 0.03) {
			if (PitotServicable[i].getBoolValue()) {
				PitotServicable[i].setBoolValue(0);
			}
		} else {
			if (!PitotServicable[i].getBoolValue()) {
				PitotServicable[i].setBoolValue(1);
			}
		}
	}
}

###################
# Update Function #
###################

var update_Icing = func {
	icingModel();
}

var icing_timer = maketimer(0.2, update_Icing);
icing_timer.simulatedTime = 1;
