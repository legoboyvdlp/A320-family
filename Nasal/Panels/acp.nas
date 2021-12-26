# A3XX Audio Control Panel
# merspieler

############################
# Copyright (c) merspieler #
############################

# NOTE: This is just temporary until FG allows a full implementation of the audio system.

var mkr_capt_recive = props.globals.initNode("/controls/audio/acp[0]/mkr-recive", 0, "BOOL");
var mkr_capt_volume = props.globals.initNode("/controls/audio/acp[0]/mkr-volume", 1, "DOUBLE");
var mkr_fo_recive = props.globals.initNode("/controls/audio/acp[1]/mkr-recive", 0, "BOOL");
var mkr_fo_volume = props.globals.initNode("/controls/audio/acp[1]/mkr-volume", 1, "DOUBLE");
var ils_capt_recive = props.globals.initNode("/controls/audio/acp[0]/ils-recive", 0, "BOOL");
var ils_capt_volume = props.globals.initNode("/controls/audio/acp[0]/ils-volume", 1, "DOUBLE");
var ils_fo_recive = props.globals.initNode("/controls/audio/acp[1]/ils-recive", 0, "BOOL");
var ils_fo_volume = props.globals.initNode("/controls/audio/acp[1]/ils-volume", 1, "DOUBLE");

var vhf1_capt_recive = props.globals.initNode("/controls/audio/acp[0]/vhf1-recive", 1, "BOOL");
var vhf2_capt_recive = props.globals.initNode("/controls/audio/acp[0]/vhf2-recive", 1, "BOOL");
var vhf1_capt_volume = props.globals.initNode("/controls/audio/acp[0]/vhf1-volume", 1, "DOUBLE");
var vhf2_capt_volume = props.globals.initNode("/controls/audio/acp[0]/vhf2-volume", 1, "DOUBLE");
var adf1_capt_receive = props.globals.initNode("/controls/audio/acp[0]/adf1-recive", 0, "BOOL");
var adf1_capt_volume = props.globals.initNode("/controls/audio/acp[0]/adf1-volume", 1, "DOUBLE");
var adf2_capt_receive = props.globals.initNode("/controls/audio/acp[0]/adf2-recive", 0, "BOOL");
var adf2_capt_volume = props.globals.initNode("/controls/audio/acp[0]/adf2-volume", 1, "DOUBLE");
var vor1_capt_receive = props.globals.initNode("/controls/audio/acp[0]/vor1-recive", 0, "BOOL");
var vor1_capt_volume = props.globals.initNode("/controls/audio/acp[0]/vor1-volume", 1, "DOUBLE");
var vor2_capt_receive = props.globals.initNode("/controls/audio/acp[0]/vor2-recive", 0, "BOOL");
var vor2_capt_volume = props.globals.initNode("/controls/audio/acp[0]/vor2-volume", 1, "DOUBLE");

var vhf1_fo_recive = props.globals.initNode("/controls/audio/acp[1]/vhf1-recive", 1, "BOOL");
var vhf2_fo_recive = props.globals.initNode("/controls/audio/acp[1]/vhf2-recive", 1, "BOOL");
var vhf1_fo_volume = props.globals.initNode("/controls/audio/acp[1]/vhf1-volume", 1, "DOUBLE");
var vhf2_fo_volume = props.globals.initNode("/controls/audio/acp[1]/vhf2-volume", 1, "DOUBLE");
var adf1_fo_receive = props.globals.initNode("/controls/audio/acp[1]/adf1-recive", 0, "BOOL");
var adf1_fo_volume = props.globals.initNode("/controls/audio/acp[1]/adf1-volume", 1, "DOUBLE");
var adf2_fo_receive = props.globals.initNode("/controls/audio/acp[1]/adf2-recive", 0, "BOOL");
var adf2_fo_volume = props.globals.initNode("/controls/audio/acp[1]/adf2-volume", 1, "DOUBLE");
var vor1_fo_receive = props.globals.initNode("/controls/audio/acp[1]/vor1-recive", 0, "BOOL");
var vor1_fo_volume = props.globals.initNode("/controls/audio/acp[1]/vor1-volume", 1, "DOUBLE");
var vor2_fo_receive = props.globals.initNode("/controls/audio/acp[1]/vor2-recive", 0, "BOOL");
var vor2_fo_volume = props.globals.initNode("/controls/audio/acp[1]/vor2-volume", 1, "DOUBLE");

var com1_volume = props.globals.getNode("instrumentation/comm[0]/volume");
var com2_volume = props.globals.getNode("instrumentation/comm[1]/volume");

var init = func() {
	vhf1_capt_recive.setValue(1);
	vhf2_capt_recive.setValue(1);
	vhf1_capt_volume.setValue(1);
	vhf2_capt_volume.setValue(0.8);
	vhf1_fo_recive.setValue(1);
	vhf2_fo_recive.setValue(1);
	vhf1_fo_volume.setValue(0.8);
	vhf2_fo_volume.setValue(1);
}

var update_com1 = func() {	
	if (acconfig.foViewNode.getValue() == 1) {
		if (vhf1_fo_recive.getValue()) {
			com1_volume.setValue(vhf1_fo_volume.getValue());
		} else {
			com1_volume.setValue(0);
		}
	} else {
		if (vhf1_capt_recive.getValue()) {
			com1_volume.setValue(vhf1_capt_volume.getValue());
		} else {
			com1_volume.setValue(0);
		}
	}
}

var update_com2 = func() {	
	if (acconfig.foViewNode.getValue() == 1) {
		if (vhf2_fo_recive.getValue()) {
			com2_volume.setValue(vhf2_fo_volume.getValue());
		} else {
			com2_volume.setValue(0);
		}
	} else {
		if (vhf2_capt_recive.getValue()) {
			com2_volume.setValue(vhf2_capt_volume.getValue());
		} else {
			com2_volume.setValue(0);
		}
	}
}

setlistener("/controls/audio/acp[0]/vhf1-recive", func {
	update_com1();
});

setlistener("/controls/audio/acp[0]/vhf1-volume", func {
	update_com1();
});

setlistener("/controls/audio/acp[0]/vhf2-recive", func {
	update_com2();
});

setlistener("/controls/audio/acp[0]/vhf2-volume", func {
	update_com2();
});

setlistener("/controls/audio/acp[1]/vhf1-recive", func {
	update_com1();
});

setlistener("/controls/audio/acp[1]/vhf1-volume", func {
	update_com1();
});

setlistener("/controls/audio/acp[1]/vhf2-recive", func {
	update_com2();
});

setlistener("/controls/audio/acp[1]/vhf2-volume", func {
	update_com2();
});

setlistener("/systems/acconfig/options/fo-view", func {
	update_com1();
	update_com2();
});

