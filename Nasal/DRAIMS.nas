# A3XX DRAIMS RMP by Nia

# Copyright (c) 2025 Nia
var pageNode = [props.globals.getNode("/systems/draims/rmp[0]", 1), props.globals.getNode("/systems/draims/rmp[1]", 1), props.globals.getNode("/systems/draims/rmp[2]", 1)];
var page = "vhf";
var msg = nil;
var RMPCanvas = [nil, nil, nil];
var RMP = [nil, nil, nil];

var init = func() {
	# TODO is there a power on self test?
	for (var i = 0; i <= 2; i += 1) {
		RMPCanvas[i] = canvas.new({
			"name": "RMP" ~ i,
			"size": [1024, 624],
			"view": [1024, 624],
			"mipmapping": 1
		});
		var group = RMPCanvas[i].createGroup();
		RMP[i] = canvas.parsesvg(group, "Aircraft/A320-family/Models/Instruments/DRAIMS/res/rmp.svg");
	}
	reset();
}

var reset = func() {
	for (var i = 0; i <= 2; i += 1) {
		pageNode[i].setValue("vhf");
		setprop("/systems/draims/rmp[" ~ i ~ "]/entry-focus", "");
		setprop("/systems/draims/rmp[" ~ i ~ "]/vhf3-selection", "freq");
		changeFocus("", i);
	}
	setprop("/systems/atc/transponder-code", 2000);
}

var lskbutton = func(btn, i) {
	# No need if RMP is off/no power
	if (getprop("/controls/draims/rmp[" ~ i ~ "]/on") == 0) {
		return;
	}
	page = pageNode[i].getValue();
	if (page == "vhf") {
		if (btn == 1) {
			var oldSelected = getprop("/instrumentation/comm[0]/frequencies/selected-mhz");
			var oldStandby = getprop("/instrumentation/comm[0]/frequencies/standby-mhz");
			setprop("/instrumentation/comm[0]/frequencies/selected-mhz", oldStandby);
			setprop("/instrumentation/comm[0]/frequencies/standby-mhz", oldSelected);
		} else if (btn == 2) {
			var oldSelected = getprop("/instrumentation/comm[1]/frequencies/selected-mhz");
			var oldStandby = getprop("/instrumentation/comm[1]/frequencies/standby-mhz");
			setprop("/instrumentation/comm[1]/frequencies/selected-mhz", oldStandby);
			setprop("/instrumentation/comm[1]/frequencies/standby-mhz", oldSelected);
		} else if (btn == 3) {
			var oldSelected = getprop("/instrumentation/comm[2]/frequencies/selected-mhz");
			var oldStandby = getprop("/instrumentation/comm[2]/frequencies/standby-mhz");
			setprop("/instrumentation/comm[2]/frequencies/selected-mhz", oldStandby);
			setprop("/instrumentation/comm[2]/frequencies/standby-mhz", oldSelected);
			# TODO handle data correctly
			# TODO find out what the standby field does on switch
		} else if (btn == 4) {
			changeFocus("atc", i);
		}
	} else if (page == "hf") {
	} else if (page == "tel") {
	} else if (page == "atc") {
	} else if (page == "menu") {
	} else if (page == "nav") {
	}
}

var shortCutButton = func(btn, i) {
	# No need if RMP is off/no power
	if (getprop("/controls/draims/rmp[" ~ i ~ "]/on") == 0) {
		return;
	}
	if (btn == "r") {
		var mode = getprop("/controls/atc/mode-knob");
		if (mode == 0) {
			setprop("/controls/atc/mode-knob", 4);
		} else if (mode == 4) {
			setprop("/controls/atc/mode-knob", 3);
		} else if (mode == 3) {
			setprop("/controls/atc/mode-knob", 0);
		} else {
			setprop("/controls/atc/mode-knob", 0);
		}

	} else if (btn == "l") {
		var mode = getprop("/controls/atc/abv-blw");
		if (mode == 0) {
			setprop("/controls/atc/abv-blw", -1);
		} else if (mode == -1) {
			setprop("/controls/atc/abv-blw", 1);
		} else if (mode == 1) {
			setprop("/controls/atc/abv-blw", 0);
		} else {
			setprop("/controls/atc/abv-blw", 0);
		}
	}
}

var changeFocus = func(item, i) {
	if (getprop("/systems/draims/rmp[" ~ i ~ "]/entry-focus") == item) {
		return;
	}
	# TODO restore previously selected field
	setprop("/systems/draims/rmp[" ~ i ~ "]/entry-focus", item);
}

var arrowButton = func(dir, i) {
	# TODO implement
}
