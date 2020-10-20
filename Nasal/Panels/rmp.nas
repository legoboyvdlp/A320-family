# A3XX Radio Managment Panel
# merspieler

############################
# Copyright (c) merspieler #
############################

var genFourRand = func() {
	var sequence = int(rand() * 10) ~ int(rand() * 10) ~ int(rand() * 10) ~ int(rand() * 10);
	while (sequence < 2000 or sequence > 10000) {
		sequence = int(rand() * 10) ~ int(rand() * 10) ~ int(rand() * 10) ~ int(rand() * 10);
	}
	return sequence;
}

var genFiveRand = func() {
	var sequence = int(rand() * 10) ~ int(rand() * 10) ~ int(rand() * 10) ~ int(rand() * 10) ~ int(rand() * 10);
	while (sequence < 10000 or sequence > 29999) {
		sequence = int(rand() * 10) ~ int(rand() * 10) ~ int(rand() * 10) ~ int(rand() * 10) ~ int(rand() * 10);
	}
	return sequence;
}

# GLOBAL TODO add stuff for HF1, HF2, VOR, LS and ADF

var chan_rmp1_v = "vhr1";
var chan_rmp2_v = "vhr2";
var chan_rmp3_v = "vhr3";

var act_vhf1 = props.globals.getNode("instrumentation/comm[0]/frequencies/selected-mhz");
var act_vhf2 = props.globals.getNode("instrumentation/comm[1]/frequencies/selected-mhz");
var act_vhf3 = props.globals.getNode("instrumentation/comm[2]/frequencies/selected-mhz");

var act_ls1 = props.globals.getNode("instrumentation/nav[0]/frequencies/selected-mhz");
var act_vor1 = props.globals.getNode("instrumentation/nav[2]/frequencies/selected-mhz");
var act_vor2 = props.globals.getNode("instrumentation/nav[3]/frequencies/selected-mhz");
var act_adf1 = props.globals.getNode("instrumentation/adf[0]/frequencies/selected-khz");
var act_adf2 = props.globals.getNode("instrumentation/adf[1]/frequencies/selected-khz");
var stby_ls1 = props.globals.getNode("instrumentation/nav[0]/frequencies/standby-mhz");
var stby_vor1 = props.globals.getNode("instrumentation/nav[2]/frequencies/standby-mhz");
var stby_vor2 = props.globals.getNode("instrumentation/nav[3]/frequencies/standby-mhz");
var stby_adf1 = props.globals.getNode("instrumentation/adf[0]/frequencies/standby-khz");
var stby_adf2 = props.globals.getNode("instrumentation/adf[1]/frequencies/standby-khz");
var act_ls1_crs = props.globals.getNode("instrumentation/nav[0]/radials/selected-deg");
var act_vor1_crs = props.globals.getNode("instrumentation/nav[2]/radials/selected-deg");
var act_vor2_crs = props.globals.getNode("instrumentation/nav[3]/radials/selected-deg");

if (rand() > 0.5) {
	var hf1 = genFourRand();
	var hf2 = genFiveRand();
} else {
	var hf1 = genFiveRand();
	var hf2 = genFourRand();
}

var act_display_rmp1 = props.globals.initNode("/controls/radio/rmp[0]/active-display", "118.700", "STRING");
var stby_display_rmp1 = props.globals.initNode("/controls/radio/rmp[0]/standby-display", "121.400", "STRING");
var stby_rmp1_vhf1 = props.globals.initNode("/systems/radio/rmp[0]/vhf1-standby", 121.4, "DOUBLE");
var stby_rmp1_vhf2 = props.globals.initNode("/systems/radio/rmp[0]/vhf2-standby", 122.6, "DOUBLE");
var stby_rmp1_vhf3 = props.globals.initNode("/systems/radio/rmp[0]/vhf3-standby", 123.2, "DOUBLE");
var stby_rmp1_hf1 = props.globals.initNode("/systems/radio/rmp[0]/hf1-standby", hf1, "DOUBLE");
var stby_rmp1_hf2 = props.globals.initNode("/systems/radio/rmp[0]/hf2-standby", hf2, "DOUBLE");

var act_display_rmp2 = props.globals.initNode("/controls/radio/rmp[1]/active-display", "119.400", "STRING");
var stby_display_rmp2 = props.globals.initNode("/controls/radio/rmp[1]/standby-display", "122.600", "STRING");
var stby_rmp2_vhf1 = props.globals.initNode("/systems/radio/rmp[1]/vhf1-standby", 121.4, "DOUBLE");
var stby_rmp2_vhf2 = props.globals.initNode("/systems/radio/rmp[1]/vhf2-standby", 122.6, "DOUBLE");
var stby_rmp2_vhf3 = props.globals.initNode("/systems/radio/rmp[1]/vhf3-standby", 123.2, "DOUBLE");
var stby_rmp2_hf1 = props.globals.initNode("/systems/radio/rmp[1]/hf1-standby", hf1, "DOUBLE");
var stby_rmp2_hf2 = props.globals.initNode("/systems/radio/rmp[1]/hf2-standby", hf2, "DOUBLE");

var act_display_rmp3 = props.globals.initNode("/controls/radio/rmp[2]/active-display", "data", "STRING");
var stby_display_rmp3 = props.globals.initNode("/controls/radio/rmp[2]/standby-display", "123.200", "STRING");
var stby_rmp3_vhf1 = props.globals.initNode("/systems/radio/rmp[2]/vhf1-standby", 121.4, "DOUBLE");
var stby_rmp3_vhf2 = props.globals.initNode("/systems/radio/rmp[2]/vhf2-standby", 122.6, "DOUBLE");
var stby_rmp3_vhf3 = props.globals.initNode("/systems/radio/rmp[2]/vhf3-standby", 123.2, "DOUBLE");
var stby_rmp3_hf1 = props.globals.initNode("/systems/radio/rmp[2]/hf1-standby", hf1, "DOUBLE");
var stby_rmp3_hf2 = props.globals.initNode("/systems/radio/rmp[2]/hf2-standby", hf2, "DOUBLE");

var chan_rmp1 = props.globals.initNode("/systems/radio/rmp[0]/sel_chan", "vhf1", "STRING");
var chan_rmp2 = props.globals.initNode("/systems/radio/rmp[1]/sel_chan", "vhf2", "STRING");
var chan_rmp3 = props.globals.initNode("/systems/radio/rmp[2]/sel_chan", "vhf3", "STRING");

var pwr_sw_rmp1 = props.globals.initNode("/controls/radio/rmp[0]/on", 0, "BOOL");
var pwr_sw_rmp2 = props.globals.initNode("/controls/radio/rmp[1]/on", 0, "BOOL");
var pwr_sw_rmp3 = props.globals.initNode("/controls/radio/rmp[2]/on", 0, "BOOL");

var sel_light_rmp1 = props.globals.initNode("/systems/radio/rmp[0]/sel-light", 0, "BOOL");
var sel_light_rmp2 = props.globals.initNode("/systems/radio/rmp[1]/sel-light", 0, "BOOL");
var sel_light_rmp3 = props.globals.initNode("/systems/radio/rmp[2]/sel-light", 0, "BOOL");

var am_mode_rmp1 = props.globals.initNode("/systems/radio/rmp[0]/am-active", 0, "BOOL");
var am_mode_rmp2 = props.globals.initNode("/systems/radio/rmp[1]/am-active", 0, "BOOL");
var am_mode_rmp3 = props.globals.initNode("/systems/radio/rmp[2]/am-active", 0, "BOOL");

var sel_crs_rmp1 = props.globals.initNode("/systems/radio/rmp[0]/select-crs", 1, "BOOL");
var sel_crs_rmp2 = props.globals.initNode("/systems/radio/rmp[1]/select-crs", 1, "BOOL");

var init = func() {
	chan_rmp1.setValue("vhf1");
	chan_rmp2.setValue("vhf2");
	chan_rmp3.setValue("vhf3");
	pwr_sw_rmp1.setBoolValue(0);
	pwr_sw_rmp2.setBoolValue(0);
	pwr_sw_rmp3.setBoolValue(0);
}

var rmpUpdate = func() {
	chan_rmp1_v = chan_rmp1.getValue();
	chan_rmp2_v = chan_rmp2.getValue();
	chan_rmp3_v = chan_rmp3.getValue();
	
	# SEL lights
	if (chan_rmp1_v == "vhf2" or chan_rmp1_v == "vhf3" or chan_rmp1_v == "hf1" or chan_rmp1_v == "hf2" or chan_rmp2_v == "vhf1" or chan_rmp2_v == "vhf3" or chan_rmp2_v == "hf1" or chan_rmp2_v == "hf2" or chan_rmp3_v == "vhf1" or chan_rmp3_v == "vhf2") {
		if (!sel_light_rmp1.getBoolValue()) {
			sel_light_rmp1.setBoolValue(1);
		}
		if (!sel_light_rmp2.getBoolValue()) {
			sel_light_rmp2.setBoolValue(1);
		}
		if (!sel_light_rmp3.getBoolValue()) {
			sel_light_rmp3.setBoolValue(1);
		}
	} else {
		if (sel_light_rmp1.getBoolValue()) {
			sel_light_rmp1.setBoolValue(0);
		}
		if (sel_light_rmp2.getBoolValue()) {
			sel_light_rmp2.setBoolValue(0);
		}
		if (sel_light_rmp3.getBoolValue()) {
			sel_light_rmp3.setBoolValue(0);
		}
	}
	
	# Disable AM mode if not in HF
	if (chan_rmp1_v != "hf1" and chan_rmp1_v != "hf2" and am_mode_rmp1.getBoolValue()) {
		am_mode_rmp1.setBoolValue(0);
	}
	
	if (chan_rmp2_v != "hf1" and chan_rmp2_v != "hf2" and am_mode_rmp2.getBoolValue()) {
		am_mode_rmp2.setBoolValue(0);
	}
	
	if (chan_rmp3_v != "hf1" and chan_rmp3_v != "hf2" and am_mode_rmp3.getBoolValue()) {
		am_mode_rmp3.setBoolValue(0);
	}
}

var update_active_vhf = func(vhf) {
	var sel1 = chan_rmp1.getValue();
	var sel2 = chan_rmp2.getValue();
	var sel3 = chan_rmp3.getValue();

	if (vhf == 1) {
		if (sel1 == "vhf1" or sel2 == "vhf1") {
			var act = sprintf("%3.3f", act_vhf1.getValue());

			if (sel1 == "vhf1") {
				act_display_rmp1.setValue(act);
			}
			if (sel2 == "vhf1") {
				act_display_rmp2.setValue(act);
			}
			if (sel3 == "vhf1") {
				act_display_rmp3.setValue(act);
			}
		}
	} else if (vhf == 2) {
		if (sel1 == "vhf2" or sel2 == "vhf2") {
			var act = sprintf("%3.3f", act_vhf2.getValue());

			if (sel1 == "vhf2") {
				act_display_rmp1.setValue(act);
			}
			if (sel2 == "vhf2") {
				act_display_rmp2.setValue(act);
			}
			if (sel3 == "vhf2") {
				act_display_rmp3.setValue(act);
			}
		}
	} else if (vhf == 3) {
		if (sel1 == "vhf3" or sel2 == "vhf3") {
			var act = sprintf("%3.3f", act_vhf3.getValue());

			if (sel1 == "vhf3") {
				if (act == 0) {
					act_display_rmp1.setValue("data");
				} else {
					act_display_rmp1.setValue(act);
				}
			}
			if (sel2 == "vhf3") {
				if (act == 0) {
					act_display_rmp2.setValue("data");
				} else {
					act_display_rmp2.setValue(act);
				}
			}
			if (sel3 == "vhf3") {
				if (act == 0) {
					act_display_rmp3.setValue("data");
				} else {
					act_display_rmp3.setValue(act);
				}
			}
		}
	} else if (vhf == 4) {
		if (sel1 == "hf1" or sel2 == "hf1") {
			var act = sprintf("%5.0f", systems.HFS[0].selectedChannelKhz);

			if (sel1 == "hf1") {
				act_display_rmp1.setValue(act);
			}
			if (sel2 == "hf1") {
				act_display_rmp2.setValue(act);
			}
			if (sel3 == "hf1") {
				act_display_rmp3.setValue(act);
			}
		}
	} else if (vhf == 5) {
		if (sel1 == "hf2" or sel2 == "hf2") {
			var act = sprintf("%5.0f", systems.HFS[1].selectedChannelKhz);

			if (sel1 == "hf2") {
				act_display_rmp1.setValue(act);
			}
			if (sel2 == "hf2") {
				act_display_rmp2.setValue(act);
			}
			if (sel3 == "hf2") {
				act_display_rmp3.setValue(act);
			}
		}
	}
}

var update_displays_nav = func(nav) {
	var chan1 = chan_rmp1.getValue();
	var chan2 = chan_rmp2.getValue();
	
	if (nav == 1) {
		if (chan1 == "ls") {
			act_display_rmp1.setValue(sprintf("%3.2f", act_ls1.getValue()));
			if (sel_crs_rmp1.getBoolValue()) {
				stby_display_rmp1.setValue("C-" ~ sprintf("%3.0f", act_ls1_crs.getValue()));
			} else {
				stby_display_rmp1.setValue(sprintf("%3.2f", stby_ls1.getValue()));
			}
		}
		if (chan2 == "ls") {
			act_display_rmp2.setValue(sprintf("%3.2f", act_ls1.getValue()));
			if (sel_crs_rmp2.getBoolValue()) {
				stby_display_rmp2.setValue("C-" ~ sprintf("%3.0f", act_ls1_crs.getValue()));
			} else {
				stby_display_rmp2.setValue(sprintf("%3.2f", stby_ls1.getValue()));
			}
		}
	} else if (nav == 3 and chan1 == "vor") {
		act_display_rmp1.setValue(sprintf("%3.2f", act_vor1.getValue()));
		if (sel_crs_rmp1.getBoolValue()) {
			stby_display_rmp1.setValue("C-" ~ sprintf("%3.0f", act_vor1_crs.getValue()));
		} else {
			stby_display_rmp1.setValue(sprintf("%3.2f", stby_vor1.getValue()));
		}

	} else if (nav == 4 and chan2 == "vor") {
		act_display_rmp2.setValue(sprintf("%3.2f", act_vor2.getValue()));
		if (sel_crs_rmp2.getBoolValue()) {
			stby_display_rmp2.setValue("C-" ~ sprintf("%3.0f", act_vor2_crs.getValue()));
		} else {
			stby_display_rmp2.setValue(sprintf("%3.2f", stby_vor2.getValue()));
		}
	} else if (nav == 5 and chan1 == "adf") {
		act_display_rmp1.setValue(sprintf("%4.0f", act_adf1.getValue()));
		stby_display_rmp1.setValue(sprintf("%4.0f", stby_adf1.getValue()));
	} else if (nav == 6 and chan2 == "adf") {
		act_display_rmp2.setValue(sprintf("%4.0f", act_adf2.getValue()));
		stby_display_rmp2.setValue(sprintf("%4.0f", stby_adf2.getValue()));
	}
}

var update_stby_freq = func(rmp_no, freq) {
	if (rmp_no == 0) {
		if (freq == 1) {
			var stby = sprintf("%3.3f", stby_rmp1_vhf1.getValue());
		} else if (freq == 2) {
			var stby = sprintf("%3.3f", stby_rmp1_vhf2.getValue());
		} else if (freq == 3) {
			var stby = sprintf("%3.3f", stby_rmp1_vhf3.getValue());
		} else if (freq == 4) {
			var stby = sprintf("%5.0f", stby_rmp1_hf1.getValue());
		} else if (freq == 5) {
			var stby = sprintf("%5.0f", stby_rmp1_hf2.getValue());
		}

		if (stby == 0) {
			stby_display_rmp1.setValue("data");
		} else {
			stby_display_rmp1.setValue(stby);
		}
	} else if (rmp_no == 1) {
		if (freq == 1) {
			var stby = sprintf("%3.3f", stby_rmp2_vhf1.getValue());
		} else if (freq == 2) {
			var stby = sprintf("%3.3f", stby_rmp2_vhf2.getValue());
		} else if (freq == 3) {
			var stby = sprintf("%3.3f", stby_rmp2_vhf3.getValue());
		} else if (freq == 4) {
			var stby = sprintf("%5.0f", stby_rmp2_hf1.getValue());
		} else if (freq == 5) {
			var stby = sprintf("%5.0f", stby_rmp2_hf2.getValue());
		}

		if (stby == 0) {
			stby_display_rmp2.setValue("data");
		} else {
			stby_display_rmp2.setValue(stby);
		}
	} else {
		if (freq == 1) {
			var stby = sprintf("%3.3f", stby_rmp3_vhf1.getValue());
		} else if (freq == 2) {
			var stby = sprintf("%3.3f", stby_rmp3_vhf2.getValue());
		} else if (freq == 3) {
			var stby = sprintf("%3.3f", stby_rmp3_vhf3.getValue());
		} else if (freq == 4) {
			var stby = sprintf("%5.0f", stby_rmp3_hf1.getValue());
		} else if (freq == 5) {
			var stby = sprintf("%5.0f", stby_rmp3_hf2.getValue());
		}

		if (stby == 0) {
			stby_display_rmp3.setValue("data");
		} else {
			stby_display_rmp3.setValue(stby);
		}
	}
}

var update_chan_sel = func(rmp_no) {
	update_active_vhf(1);
	update_active_vhf(2);
	update_active_vhf(3);
	update_active_vhf(4);
	update_active_vhf(5);
	
	update_displays_nav(1);
	update_displays_nav(rmp_no + 3);
	update_displays_nav(rmp_no + 5);

	if (rmp_no == 0) {
		var chan = chan_rmp1.getValue();
		if (chan == "vhf1") {
			update_stby_freq(rmp_no, 1);
		} else if (chan == "vhf2") {
			update_stby_freq(rmp_no, 2);
		} else if (chan == "vhf3") {
			update_stby_freq(rmp_no, 3);
		} else if (chan == "hf1") {
			update_stby_freq(rmp_no, 4);
		} else if (chan == "hf2") {
			update_stby_freq(rmp_no, 5);
		}
	} else if (rmp_no == 1) {
		var chan = chan_rmp2.getValue();
		if (chan == "vhf1") {
			update_stby_freq(rmp_no, 1);
		} else if (chan == "vhf2") {
			update_stby_freq(rmp_no, 2);
		} else if (chan == "vhf3") {
			update_stby_freq(rmp_no, 3);
		} else if (chan == "hf1") {
			update_stby_freq(rmp_no, 4);
		} else if (chan == "hf2") {
			update_stby_freq(rmp_no, 5);
		}
	} else {
		var chan = chan_rmp3.getValue();
		if (chan == "vhf1") {
			update_stby_freq(rmp_no, 1);
		} else if (chan == "vhf2") {
			update_stby_freq(rmp_no, 2);
		} else if (chan == "vhf3") {
			update_stby_freq(rmp_no, 3);
		} else if (chan == "hf1") {
			update_stby_freq(rmp_no, 4);
		} else if (chan == "hf2") {
			update_stby_freq(rmp_no, 5);
		}
	}
}

var transfer = func(rmp_no) {
	rmp_no = rmp_no - 1;
	var sel_chan = getprop("/systems/radio/rmp[" ~ rmp_no ~ "]/sel_chan");
	var sel_crs = getprop("/systems/radio/rmp[" ~ rmp_no ~ "]/select-crs");

	if (string.match(sel_chan, "vhf[1-3]")) {
		var mod1 = int(string.replace(sel_chan, "vhf", ""));
		var mod = mod1 - 1;

		var mem = getprop("instrumentation/comm[" ~ mod ~ "]/frequencies/selected-mhz");
		setprop("instrumentation/comm[" ~ mod ~ "]/frequencies/selected-mhz", getprop("/systems/radio/rmp[" ~ rmp_no ~ "]/vhf" ~ mod1 ~ "-standby"));
		setprop("/systems/radio/rmp[" ~ rmp_no ~ "]/vhf" ~ mod1 ~ "-standby", mem);
	} elsif (string.match(sel_chan, "hf[1-2]")) {
		var mod1 = int(string.replace(sel_chan, "hf", ""));
		var mod = mod1 - 1;
		
		var mem = systems.HFS[mod].selectedChannelKhz;
		systems.HFS[mod].selectChannel(getprop("/systems/radio/rmp[" ~ rmp_no ~ "]/hf" ~ mod1 ~ "-standby"));
		setprop("/systems/radio/rmp[" ~ rmp_no ~ "]/hf" ~ mod1 ~ "-standby", mem);
	} elsif (sel_chan == "adf") {
		var mem = getprop("instrumentation/adf[" ~ rmp_no ~ "]/frequencies/selected-khz");
		setprop("instrumentation/adf[" ~ rmp_no ~ "]/frequencies/selected-khz", getprop("instrumentation/adf[" ~ rmp_no ~ "]/frequencies/standby-khz"));
		setprop("instrumentation/adf[" ~ rmp_no ~ "]/frequencies/standby-khz", mem);
		update_displays_nav(rmp_no + 5);
	} elsif (sel_chan == "vor") {
		if (sel_crs) {
			setprop("instrumentation/nav[" ~ (rmp_no + 2) ~ "]/frequencies/standby-mhz", getprop("instrumentation/nav[" ~ (rmp_no + 2) ~ "]/frequencies/selected-mhz"));
			setprop("/systems/radio/rmp[" ~ rmp_no ~ "]/select-crs", 0);
			update_displays_nav(rmp_no + 3);
		} else {
			setprop("instrumentation/nav[" ~ (rmp_no + 2) ~ "]/frequencies/selected-mhz", getprop("instrumentation/nav[" ~ (rmp_no + 2) ~ "]/frequencies/standby-mhz"));
			setprop("/systems/radio/rmp[" ~ rmp_no ~ "]/select-crs", 1);
			update_displays_nav(rmp_no + 3);
		}
	} elsif (sel_chan == "ls") {
		if (sel_crs) {
			setprop("instrumentation/nav[0]/frequencies/standby-mhz", getprop("instrumentation/nav[0]/frequencies/selected-mhz"));
			setprop("/systems/radio/rmp[" ~ rmp_no ~ "]/select-crs", 0);
			update_displays_nav(1);
		} else {
			setprop("instrumentation/nav[0]/frequencies/selected-mhz", getprop("instrumentation/nav[0]/frequencies/standby-mhz"));
			setprop("/systems/radio/rmp[" ~ rmp_no ~ "]/select-crs", 1);
			update_displays_nav(1);
		}
	}
}

var change_nav_mode = func(rmp_nr, nav_mode) {
	if (!nav_mode.getBoolValue()) {
		if (rmp_nr == 1 and (chan_rmp1.getValue() == "vor" or chan_rmp1.getValue() == "ls" or chan_rmp1.getValue() == "adf")) {
			chan_rmp1.setValue("vhf1");
		}
		if (rmp_nr == 2 and (chan_rmp2.getValue() == "vor" or chan_rmp2.getValue() == "ls" or chan_rmp2.getValue() == "adf")) {
			chan_rmp2.setValue("vhf2");
		}
		setprop("/FMGC/internal/ils1freq-set", 1);
		setprop("/FMGC/internal/ils1crs-set", 1);
		setprop("/FMGC/internal/vor1freq-set", 1);
		setprop("/FMGC/internal/vor1crs-set", 1);
		setprop("/FMGC/internal/vor2freq-set", 1);
		setprop("/FMGC/internal/vor2crs-set", 1);
		setprop("/FMGC/internal/adf1freq-set", 1);
		setprop("/FMGC/internal/adf2freq-set", 1);	
	}
}

setlistener("/systems/radio/rmp[0]/vhf1-standby", func {
	update_stby_freq(0, 1);
});

setlistener("/systems/radio/rmp[0]/vhf2-standby", func {
	update_stby_freq(0, 2);
});

setlistener("/systems/radio/rmp[0]/vhf3-standby", func {
	update_stby_freq(0, 3);
});

setlistener("/systems/radio/rmp[0]/hf1-standby", func {
	update_stby_freq(0, 4);
});

setlistener("/systems/radio/rmp[0]/hf2-standby", func {
	update_stby_freq(0, 5);
});

setlistener("/systems/radio/rmp[1]/vhf1-standby", func {
	update_stby_freq(1, 1);
});

setlistener("/systems/radio/rmp[1]/vhf2-standby", func {
	update_stby_freq(1, 2);
});

setlistener("/systems/radio/rmp[1]/vhf3-standby", func {
	update_stby_freq(1, 3);
});

setlistener("/systems/radio/rmp[1]/hf1-standby", func {
	update_stby_freq(1, 4);
});

setlistener("/systems/radio/rmp[1]/hf2-standby", func {
	update_stby_freq(3, 5);
});

setlistener("/systems/radio/rmp[2]/vhf1-standby", func {
	update_stby_freq(2, 1);
});

setlistener("/systems/radio/rmp[2]/vhf2-standby", func {
	update_stby_freq(2, 2);
});

setlistener("/systems/radio/rmp[2]/vhf3-standby", func {
	update_stby_freq(2, 3);
});

setlistener("/systems/radio/rmp[2]/hf1-standby", func {
	update_stby_freq(2, 4);
});

setlistener("/systems/radio/rmp[2]/hf2-standby", func {
	update_stby_freq(2, 5);
});

setlistener("/instrumentation/comm[0]/frequencies/selected-mhz", func {
	update_active_vhf(1);
});

setlistener("/instrumentation/comm[1]/frequencies/selected-mhz", func {
	update_active_vhf(2);
});

setlistener("/instrumentation/comm[2]/frequencies/selected-mhz", func {
	update_active_vhf(3);
});

setlistener("/systems/radio/rmp[0]/sel_chan", func {
	update_chan_sel(0);
});

setlistener("/systems/radio/rmp[1]/sel_chan", func {
	update_chan_sel(1);
});

setlistener("/systems/radio/rmp[2]/sel_chan", func {
	update_chan_sel(2);
});

setlistener("/instrumentation/nav[0]/frequencies/selected-mhz", func {
	update_displays_nav(1);
});

setlistener("/instrumentation/nav[0]/frequencies/standby-mhz", func {
	update_displays_nav(1);
});

setlistener("/instrumentation/nav[2]/frequencies/selected-mhz", func {
	update_displays_nav(3);
});

setlistener("/instrumentation/nav[2]/frequencies/standby-mhz", func {
	update_displays_nav(3);
});

setlistener("/instrumentation/nav[3]/frequencies/selected-mhz", func {
	update_displays_nav(4);
});

setlistener("/instrumentation/nav[3]/frequencies/standby-mhz", func {
	update_displays_nav(4);
});

setlistener("/instrumentation/adf[0]/frequencies/selected-khz", func {
	update_displays_nav(5);
});

setlistener("/instrumentation/adf[0]/frequencies/standby-khz", func {
	update_displays_nav(5);
});

setlistener("/instrumentation/adf[1]/frequencies/selected-khz", func {
	update_displays_nav(6);
});

setlistener("/instrumentation/adf[1]/frequencies/standby-khz", func {
	update_displays_nav(6);
});

setlistener("/instrumentation/nav[0]/radials/selected-deg", func {
	update_displays_nav(1);
});

setlistener("/instrumentation/nav[2]/radials/selected-deg", func {
	update_displays_nav(3);
});

setlistener("/instrumentation/nav[3]/radials/selected-deg", func {
	update_displays_nav(4);
});

setlistener("/systems/radio/rmp[0]/nav", func(nav_mode) {
	change_nav_mode(1, nav_mode);
});

setlistener("/systems/radio/rmp[1]/nav", func(nav_mode) {
	change_nav_mode(2, nav_mode);
});

