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
	dewpoint: props.globals.getNode("environment/dewpoint-degc"),
	temperature: props.globals.getNode("environment/temperature-degc"),
	visibility: props.globals.getNode("environment/effective-visibility-m"),
	visibLclWx: props.globals.getNode("environment/visibility-m"),
};

var effects = {
	frost_inch: props.globals.getNode("environment/aircraft-effects/frost-inch", 1),
	frost_norm: props.globals.getNode("environment/aircraft-effects/frost-level"),
};


# Icing factor computation.
var maxSpread = 0;

var severity_factor_table = [
	-0.00000166,
	0.00000277,
	0.00000277,
	0.00000554,
	0.00001108,
	0.00002216,
];

var melt_factor = -0.00005;

var icing_factor = func() {
	var temperature = environment.temperature.getValue();
	var dewpoint = environment.dewpoint.getValue();
	var visibility = environment.visibility.getValue();
	var visibLclWx = environment.visibLclWx.getValue();

	# Do we create ice?
	var spread = temperature - dewpoint;
	# freezing fog or low temp and below dp or in advanced wx cloud
	var icingCond = ((spread < maxSpread or visibility < 1000 or visibLclWx < 5000)
					 and temperature < 0);

	# todo: turn this into a table or something
	var severity = 0;
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
var pause = 0;
var windowprobe = 0;
var wingBtn = 0;
var wingFault = 0;
var wingAnti = 0;
var PSI = 0;
var wowl = 0;
var wowr = 0;
var PitotIcing = 0;
var PitotFailed = 0;
var lengBtn = 0;
var lengFault = 0;
var rengBtn = 0;
var rengFault = 0;
var lengAnti = 0;
var rengAnti = 0;
var WingHasBeenTurnedOff = 0;
var GroundModeFinished = 0;
var windowprb = 0;
var stateL = 0;
var stateR = 0;

var iceables = [];

var icingInit = func {
	setprop("controls/switches/windowprobeheat", 0);
	setprop("controls/switches/wing", 0);
	setprop("controls/switches/wingfault", 0);
	setprop("controls/switches/leng", 0);
	setprop("controls/switches/lengfault", 0);
	setprop("controls/switches/reng", 0);
	setprop("controls/switches/rengfault", 0);
	setprop("controls/deice/wing", 0);
	setprop("controls/deice/lengine", 0);
	setprop("controls/deice/rengine", 0);
	setprop("controls/deice/windowprobeheat", 0);
	setprop("systems/pitot/icing", 0.0);
	setprop("systems/pitot/failed", 1);
	setprop("controls/deice/WingHasBeenTurnedOff", 0);
	setprop("controls/deice/GroundModeFinished", 0);

	iceables = props.globals.getNode("sim/model/icing", 1).getChildren("iceable");
	forindex(var i; iceables) {
		iceables[i] = Iceable.new(iceables[i]);
	}

	icing_timer.start();
}

var icingModel = func {
	speed = getprop("velocities/airspeed-kt");
	pause = getprop("sim/freeze/master");
	windowprobe = getprop("controls/deice/windowprobeheat");
	wingBtn = getprop("controls/switches/wing");
	wingFault = getprop("controls/switches/wingfault");
	wingAnti = getprop("controls/deice/wing");
	#PSI = getprop("systems/pneumatic/total-psi");
	wowl = getprop("gear/gear[1]/wow");
	wowr = getprop("gear/gear[2]/wow");
	PitotIcing = getprop("systems/pitot/icing");
	PitotFailed = getprop("systems/pitot/failed");
	lengBtn = getprop("controls/switches/leng");
	lengFault = getprop("controls/switches/lengfault");
	rengBtn = getprop("controls/switches/reng");
	rengFault = getprop("controls/switches/rengfault");
	lengAnti = getprop("controls/deice/lengine");
	rengAnti = getprop("controls/deice/rengine");
	WingHasBeenTurnedOff = getprop("controls/deice/WingHasBeenTurnedOff");
	GroundModeFinished = getprop("controls/deice/GroundModeFinished");

	var factor = icing_factor();
	foreach(iceable; iceables) {
		iceable.update(factor, melt_factor);
	}

	effects.frost_norm.setDoubleValue(effects.frost_inch.getValue() * 50);
	
	if (WingHasBeenTurnedOff and !wowl and !wowr and GroundModeFinished) {
		setprop("controls/deice/wing", 1);
		setprop("controls/switches/WingHasBeenTurnedOff", 0);
	}

	# If we have low pressure we have a fault
	#if (PSI < 10) {
	#	setprop("controls/switches/wingfault", 1);
	#	setprop("controls/deice/wing", 0);
	#} 
	
	#if (PSI > 10 and wingFault) {
	#	setprop("controls/switches/wingfault", 0);
	#	if (wingBtn) { 
	#		setprop("controls/deice/wing", 1);
	#	}
	#}
	
	if (PitotIcing > 0.03) {
		if (!PitotFailed) {
			setprop("systems/pitot/failed", 1);
		}
	} else if (PitotIcing < 0.03) {
		if (PitotFailed) {
			setprop("systems/pitot/failed", 0);
		}
	}

	# if ((getprop("systems/electrical/bus/dc-1") == 0 or getprop("systems/electrical/bus/dc-2") == 0) and getprop("fdm/jsbsim/position/wow") == 0) {
	#	setprop("controls/switches/leng", 1);
	#	setprop("controls/switches/reng", 1);
	# }
	
	#if (getprop("systems/electrical/bus/dc-ess-shed") == 0) {
	#	setprop("controls/switches/wing", 0);
	#}
}

#################
# LEng Anti-Ice #
#################

setlistener("/controls/switches/leng", func {
	if (getprop("controls/switches/leng") == 1 and getprop("engines/engine[0]/state") == 3) {
		setprop("controls/switches/lengfault", 1);
		settimer(func() {
			setprop("controls/switches/lengfault", 0);
			setprop("controls/deice/lengine", 1);
		}, 0.5);
	} else if (getprop("controls/switches/leng") == 0) {
		setprop("controls/switches/lengfault", 1);
		settimer(func() {
			setprop("controls/switches/lengfault", 0);
			setprop("controls/deice/lengine", 0);
		}, 0.5);
	}
});

setlistener("/engines/engine[0]/state", func {
	if (getprop("engines/engine[0]/state") != 3) {
		setprop("controls/switches/leng", 0);
	}
});

#################
# REng Anti-Ice #
#################

setlistener("/controls/switches/reng", func {
	if (getprop("controls/switches/reng") == 1 and getprop("engines/engine[1]/state") == 3) {
		setprop("controls/switches/rengfault", 1);
		settimer(func() {
			setprop("controls/switches/rengfault", 0);
			setprop("controls/deice/rengine", 1);
		}, 0.5);
	} else if (getprop("controls/switches/reng") == 0) {
		setprop("controls/switches/rengfault", 1);
		settimer(func() {
			setprop("controls/switches/rengfault", 0);
			setprop("controls/deice/rengine", 0);
		}, 0.5);
	}
});

setlistener("/engines/engine[1]/state", func {
	if (getprop("engines/engine[1]/state") != 3) {
		setprop("controls/switches/reng", 0);
	}
});

##################
# Probe Anti-Ice #
##################

setlistener("/controls/switches/windowprobeheat", func {
	windowprb = getprop("controls/switches/windowprobeheat");
	if (windowprb == 0.5) { # if in auto 
		wowl = getprop("gear/gear[1]/wow");
		wowr = getprop("gear/gear[2]/wow");
		stateL = getprop("engines/engine[0]/state");
		stateR = getprop("engines/engine[1]/state");
		if (!wowl or !wowr) {
			setprop("controls/deice/windowprobeheat", 1);
		} else if (stateL == 3 or stateR == 3) {
			setprop("controls/deice/windowprobeheat", 1);
		}
	} else if (windowprb == 1) { # if in ON
		setprop("controls/deice/windowprobeheat", 1);
	} else {
		setprop("controls/deice/windowprobeheat", 0);
	}
});	

#################
# Wing Anti-Ice #
#################

# Switching on the wing anti-ice
setlistener("/controls/switches/wing", func {
	wowl = getprop("gear/gear[1]/wow");
	wowr = getprop("gear/gear[2]/wow");
	wingBtn = getprop("controls/switches/wing");
	if (wowl and wowr and wingBtn) {
		setprop("controls/switches/wingfault", 1);
		settimer(func() {
			setprop("controls/switches/wingfault", 0);
			setprop("controls/deice/wing", 1);
		}, 0.5);
		settimer(func() {
			setprop("controls/deice/WingHasBeenTurnedOff", 1);
			setprop("controls/deice/wing", 0);
		}, 30.5);
		settimer(func() {
			setprop("controls/deice/GroundModeFinished", 1);
		}, 31);
	} else if (wingBtn and !wowl and !wowr) { # In the air
		setprop("controls/switches/wingfault", 1);
		settimer(func() {
			setprop("controls/switches/wingfault", 0);
			setprop("controls/deice/wing", 1);
		}, 0.5);
	} else if (!wingBtn) {
		setprop("controls/switches/wingfault", 1);
		settimer(func() {
			setprop("controls/switches/wingfault", 0);
			setprop("controls/deice/wing", 0);
		}, 0.5);
	}
});

###################
# Update Function #
###################

var update_Icing = func {
	icingModel();
}

var icing_timer = maketimer(0.2, update_Icing);
icing_timer.simulatedTime = 1;
