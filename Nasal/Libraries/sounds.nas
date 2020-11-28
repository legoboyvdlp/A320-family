# A320 Main Libraries
# Joshua Davidson (Octal450)

# Copyright (c) 2020 Josh Davidson (Octal450)

##########
# Sounds #
##########

setlistener("/sim/sounde/btn1", func {
	if (!getprop("/sim/sounde/btn1")) {
		return;
	}
	settimer(func {
		props.globals.getNode("/sim/sounde/btn1").setBoolValue(0);
	}, 0.05);
});

setlistener("/sim/sounde/oh-btn", func {
	if (!getprop("/sim/sounde/oh-btn")) {
		return;
	}
	settimer(func {
		props.globals.getNode("/sim/sounde/oh-btn").setBoolValue(0);
	}, 0.05);
});

setlistener("/sim/sounde/btn3", func {
	if (!getprop("/sim/sounde/btn3")) {
		return;
	}
	settimer(func {
		props.globals.getNode("/sim/sounde/btn3").setBoolValue(0);
	}, 0.05);
});

setlistener("/sim/sounde/knb1", func {
	if (!getprop("/sim/sounde/knb1")) {
		return;
	}
	settimer(func {
		props.globals.getNode("/sim/sounde/knb1").setBoolValue(0);
	}, 0.05);
});

setlistener("/sim/sounde/switch1", func {
	if (!getprop("/sim/sounde/switch1")) {
		return;
	}
	settimer(func {
		props.globals.getNode("/sim/sounde/switch1").setBoolValue(0);
	}, 0.05);
});

setlistener("/controls/lighting/seatbelt-sign", func {
	props.globals.getNode("/sim/sounde/seatbelt-sign").setBoolValue(1);
	settimer(func {
		props.globals.getNode("/sim/sounde/seatbelt-sign").setBoolValue(0);
	}, 2);
}, 0, 0);

setlistener("/controls/lighting/no-smoking-sign", func {
	props.globals.getNode("/sim/sounde/no-smoking-sign").setBoolValue(1);
	settimer(func {
		props.globals.getNode("/sim/sounde/no-smoking-sign").setBoolValue(0);
	}, 1);
}, 0, 0);

var flaps_click = props.globals.getNode("/sim/sounde/flaps-click");

setlistener("/controls/flight/flaps-input", func {
	flaps_click.setBoolValue(1);
}, 0, 0);

setlistener("/sim/sounde/flaps-click", func {
	if (!flaps_click.getValue()) {
		return;
	}
	settimer(func {
		flaps_click.setBoolValue(0);
	}, 0.4);
});

var spdbrk_click = props.globals.getNode("/sim/sounde/spdbrk-click");

setlistener("/controls/flight/speedbrake", func {
	spdbrk_click.setBoolValue(1);
}, 0, 0);

setlistener("/sim/sounde/spdbrk-click", func {
	if (!spdbrk_click.getValue()) {
		return;
	}
	settimer(func {
		spdbrk_click.setBoolValue(0);
	}, 0.4);
});

var relayBatt1 = func {
	setprop("/sim/sounde/relay-batt-1",1);
	settimer(func {setprop("/sim/sounde/relay-batt-1",0);},0.35);
}
var relayBatt2 = func {
	setprop("/sim/sounde/relay-batt-2",1);
	settimer(func {setprop("/sim/sounde/relay-batt-2",0);},0.35);
}
var relayApu = func {
	setprop("/sim/sounde/relay-apu",1);
	settimer(func {setprop("/sim/sounde/relay-apu",0);},0.35);
}
var relayExt = func {
	setprop("/sim/sounde/relay-ext",1);
	settimer(func {setprop("/sim/sounde/relay-ext",0);},0.35);
}

setlistener("/systems/electrical/sources/bat-1/contact", relayBatt1, nil, 0);
setlistener("/systems/electrical/sources/bat-2/contact", relayBatt2, nil, 0);
setlistener("/systems/electrical/relay/apu-glc/contact-pos", relayApu, nil, 0);
setlistener("/systems/electrical/relay/ext-epc/contact-pos", relayExt, nil, 0);

var pushbuttonSound = props.globals.getNode("/sim/sounde/pushbutton");
var pushbutton = func() {
	pushbuttonSound.setValue(1);
	settimer(func {pushbuttonSound.setValue(0);},0.20);
}