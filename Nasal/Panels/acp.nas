# A3XX Audio Control Panel
# Nia

#####################
# Copyright (c) Nia #
#####################

# NOTE: This is just temporary until FG allows a full implementation of the audio system.

var ACP = [nil, nil, nil];

var acpClass = {
	new: func(instance) {
		var m = {parents:[acpClass]};
		m._instance = instance;
		m.receive = {};
		m.volume = {};
		m.receive.vhf = {};
		m.volume.vhf = {};
		for (var i = 1; i <= 3; i += 1) {
			m.receive.vhf[i - 1] = props.globals.initNode("/controls/audio/acp[" ~ instance ~ "]/vhf" ~ i ~ "-receive", 1, "BOOL");
			m.volume.vhf[i - 1] = props.globals.initNode("/controls/audio/acp[" ~ instance ~ "]/vhf" ~ i ~ "-volume", 1, "BOOL");
		}
		m.receive.hf = {};
		m.receive.tel = {};
		m.receive.adf = {};
		m.receive.vor = {};
		m.volume.hf = {};
		m.volume.tel = {};
		m.volume.adf = {};
		m.volume.vor = {};
		for (var i = 1; i <= 2; i += 1) {
			m.receive.hf[i - 1] = props.globals.initNode("/controls/audio/acp[" ~ instance ~ "]/hf" ~ i ~ "-receive", 0, "BOOL");
			m.receive.tel[i - 1] = props.globals.initNode("/controls/audio/acp[" ~ instance ~ "]/tel" ~ i ~ "-receive", 0, "BOOL");
			m.receive.adf[i - 1] = props.globals.initNode("/controls/audio/acp[" ~ instance ~ "]/adf" ~ i ~ "-receive", 0, "BOOL");
			m.receive.vor[i - 1] = props.globals.initNode("/controls/audio/acp[" ~ instance ~ "]/vor" ~ i ~ "-receive", 0, "BOOL");
			m.volume.hf[i - 1] = props.globals.initNode("/controls/audio/acp[" ~ instance ~ "]/hf" ~ i ~ "-volume", 1, "BOOL");
			m.volume.tel[i - 1] = props.globals.initNode("/controls/audio/acp[" ~ instance ~ "]/tel" ~ i ~ "-volume", 1, "BOOL");
			m.volume.adf[i - 1] = props.globals.initNode("/controls/audio/acp[" ~ instance ~ "]/adf" ~ i ~ "-volume", 1, "BOOL");
			m.volume.vor[i - 1] = props.globals.initNode("/controls/audio/acp[" ~ instance ~ "]/vor" ~ i ~ "-volume", 1, "BOOL");
		}
		m.receive.mkr = props.globals.initNode("/controls/audio/acp[" ~ instance ~ "]/mkr-receive", 0, "BOOL");
		m.volume.mkr = props.globals.initNode("/controls/audio/acp[" ~ instance ~ "]/mkr-volume", 0, "BOOL");
		m.receive.ils = props.globals.initNode("/controls/audio/acp[" ~ instance ~ "]/ils-receive", 0, "BOOL");
		m.volume.ils = props.globals.initNode("/controls/audio/acp[" ~ instance ~ "]/ils-volume", 0, "BOOL");
		return m;
	},
	transmitButton: func(channel) {

	},
};

var init = func() {
	for (var i = 0; i <= 2; i += 1) {
		ACP[i].receive.vhf[2].setValue(0);
		ACP[i].volume.vhf[1].setValue(0.8);
	}
}

for (var i = 0; i <= 2; i += 1) {
	ACP[i] = acpClass.new(i);
}
