# A3XX Audio Control Panel
# merspieler

############################
# Copyright (c) merspieler #
############################

# NOTE: This is just temporary until FG allows a full implementation of the audio system.

var vhf1_recive = props.globals.initNode("/controls/audio/acp[0]/vhf1-recive", 1, "BOOL");
var vhf2_recive = props.globals.initNode("/controls/audio/acp[0]/vhf2-recive", 1, "BOOL");

var vhf1_volume = props.globals.initNode("/controls/audio/acp[0]/vhf1-volume", 1, "DOUBLE");
var vhf2_volume = props.globals.initNode("/controls/audio/acp[0]/vhf2-volume", 1, "DOUBLE");

var com1_volume = props.globals.getNode("/instrumentation/comm[0]/volume");
var com2_volume = props.globals.getNode("/instrumentation/comm[1]/volume");

var init = func() {
	vhf1_recive.setValue(1);
	vhf2_recive.setValue(1);
	vhf1_volume.setValue(1);
	vhf2_volume.setValue(0.8);
}

var update_instruments = func(com_no) {
	if (com_no == 0) {
		if (vhf1_recive.getValue()) {
			com1_volume.setValue(vhf1_volume.getValue());
		} else {
			com1_volume.setValue(0);
		}
	} else if (com_no == 1) {
		if (vhf2_recive.getValue()) {
			com2_volume.setValue(vhf2_volume.getValue());
		} else {
			com2_volume.setValue(0);
		}
	}
}

setlistener("/controls/audio/acp[0]/vhf1-recive", func {
        update_instruments(0);
});

setlistener("/controls/audio/acp[0]/vhf1-volume", func {
        update_instruments(0);
});

setlistener("/controls/audio/acp[0]/vhf2-recive", func {
        update_instruments(1);
});

setlistener("/controls/audio/acp[0]/vhf2-volume", func {
        update_instruments(1);
});
