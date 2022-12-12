# A320 Main Libraries
# Joshua Davidson (Octal450)

# Copyright (c) 2022 Josh Davidson (Octal450)

##########
# Sounds #
##########

var playSoundOnce = func(path,delay) {
	setprop(path,1);
	settimer(func {setprop(path,0);},delay);
}

setlistener("/sim/sound/btn1", func {
	if (!getprop("/sim/sound/btn1")) {
		return;
	}
	settimer(func {
		props.globals.getNode("/sim/sound/btn1").setBoolValue(0);
	}, 0.05);
});

setlistener("/sim/sound/oh-btn", func {
	if (!getprop("/sim/sound/oh-btn")) {
		return;
	}
	settimer(func {
		props.globals.getNode("/sim/sound/oh-btn").setBoolValue(0);
	}, 0.05);
});

setlistener("/sim/sound/btn3", func {
	if (!getprop("/sim/sound/btn3")) {
		return;
	}
	settimer(func {
		props.globals.getNode("/sim/sound/btn3").setBoolValue(0);
	}, 0.05);
});

setlistener("/sim/sound/knb1", func {
	if (!getprop("/sim/sound/knb1")) {
		return;
	}
	settimer(func {
		props.globals.getNode("/sim/sound/knb1").setBoolValue(0);
	}, 0.05);
});

setlistener("/sim/sound/switch1", func {
	if (!getprop("/sim/sound/switch1")) {
		return;
	}
	settimer(func {
		props.globals.getNode("/sim/sound/switch1").setBoolValue(0);
	}, 0.05);
});

setlistener("/controls/lighting/seatbelt-sign", func {
	props.globals.getNode("/sim/sound/seatbelt-sign").setBoolValue(1);
	settimer(func {
		props.globals.getNode("/sim/sound/seatbelt-sign").setBoolValue(0);
	}, 2);
}, 0, 0);

setlistener("/controls/lighting/no-smoking-sign", func {
	props.globals.getNode("/sim/sound/no-smoking-sign").setBoolValue(1);
	settimer(func {
		props.globals.getNode("/sim/sound/no-smoking-sign").setBoolValue(0);
	}, 1);
}, 0, 0);

var flaps_click = props.globals.getNode("/sim/sound/flaps-click");

setlistener("/controls/flight/flaps-input", func {
	flaps_click.setBoolValue(1);
}, 0, 0);

setlistener("/sim/sound/flaps-click", func {
	if (!flaps_click.getValue()) {
		return;
	}
	settimer(func {
		flaps_click.setBoolValue(0);
	}, 0.4);
});

var spdbrk_click = props.globals.getNode("/sim/sound/spdbrk-click");

setlistener("/controls/flight/speedbrake", func {
	spdbrk_click.setBoolValue(1);
}, 0, 0);

setlistener("/sim/sound/spdbrk-click", func {
	if (!spdbrk_click.getValue()) {
		return;
	}
	settimer(func {
		spdbrk_click.setBoolValue(0);
	}, 0.4);
});

var relayBatt1 = func {
	setprop("/sim/sound/relay-batt-1",1);
	settimer(func {setprop("/sim/sound/relay-batt-1",0);},0.35);
}
var relayBatt2 = func {
	setprop("/sim/sound/relay-batt-2",1);
	settimer(func {setprop("/sim/sound/relay-batt-2",0);},0.35);
}
var relayApu = func {
	setprop("/sim/sound/relay-apu",1);
	settimer(func {setprop("/sim/sound/relay-apu",0);},0.35);
}
var relayExt = func {
	setprop("/sim/sound/relay-ext",1);
	settimer(func {setprop("/sim/sound/relay-ext",0);},0.35);
}

setlistener("/systems/electrical/sources/bat-1/bcl-supply", relayBatt1, nil, 0);
setlistener("/systems/electrical/sources/bat-2/bcl-supply", relayBatt2, nil, 0);
setlistener("/systems/electrical/relay/apu-glc/contact-pos", relayApu, nil, 0);
setlistener("/systems/electrical/relay/ext-epc/contact-pos", relayExt, nil, 0);

var pushbuttonSound = props.globals.getNode("/sim/sound/pushbutton");
var pushbutton = func() {
	pushbuttonSound.setValue(1);
	settimer(func {pushbuttonSound.setValue(0);},0.20);
}

setlistener("/sim/model/door-positions/doorc/lock-status",func(lock) {
	if (lock.getValue() == 1) 
		playSoundOnce("/sim/sound/doorc_locking",0.5);
	else
		playSoundOnce("/sim/sound/doorc_unlocking",0.5);
},0,0);
