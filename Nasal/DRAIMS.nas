# A3XX DRAIMS RMP by Nia

# Copyright (c) 2025 Nia
var pageNode = [props.globals.getNode("/systems/draims/rmp[0]/page", 1), props.globals.getNode("/systems/draims/rmp[1]/page", 1), props.globals.getNode("/systems/draims/rmp[2]/page", 1)];
var focusNode = [props.globals.getNode("/systems/draims/rmp[0]/focus", 1), props.globals.getNode("/systems/draims/rmp[1]/focus", 1), props.globals.getNode("/systems/draims/rmp[2]/focus", 1)];
var enteringNode = [props.globals.getNode("/systems/draims/fields[0]/entering", 1), props.globals.getNode("/systems/draims/fields[1]/entering", 1), props.globals.getNode("/systems/draims/fields[2]/entering", 1), props.globals.getNode("/systems/draims/fields[3]/entering", 1)];
var enteredNode = [props.globals.getNode("/systems/draims/fields[0]/entered", 1), props.globals.getNode("/systems/draims/fields[1]/entered", 1), props.globals.getNode("/systems/draims/fields[2]/entered", 1), props.globals.getNode("/systems/draims/fields[3]/entered", 1)];
var msg = nil;
var RMPCanvas = [nil, nil, nil];
var RMP = [nil, nil, nil];
var SVGKeys = ["Transmit1", "Transmit2", "Transmit3", "Select1", "Select2", "Select3", "SelectATC", "Standby1", "Standby2", "Standby3", "Active1", "Active2", "Active3", "Channel1", "Channel3", "Channel2", "Volume1", "Volume2", "Volume3", "Mute1", "Mute2", "Mute3", "Label1", "Label2", "Label3", "SquawkLabel", "Squawk", "AboveBelow", "TARA", "Message1", "Message2", "Message3"];

var WHITE = [1.0000,1.0000,1.0000];
var BLACK = [0, 0, 0];
var GREEN = [0.0509,0.7529,0.2941];
var BLUE = [0.0901,0.6039,0.7176];
var AMBER = [0.7333,0.3803,0.0000];
var YELLOW = [0.9333,0.9333,0.0000];
var MAGENTA = [0.6902,0.3333,0.7541];

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
		canvas.parsesvg(group, "Aircraft/A320-family/Models/Instruments/DRAIMS/res/rmp.svg");
		group.setSize(1024,624);
		RMP[i] = {};
		foreach(var key; SVGKeys) {
			RMP[i][key] = group.getElementById(key);
			RMP[i][key].hide();
		}
		pageNode[i].setValue("vhf");
		enteringNode[i].setValue(0);
		enteredNode[i].setValue("");
		focusNode[i].setValue("");
	}
	enteringNode[3].setValue(0);
	enteredNode[3].setValue("");
	reset();
}

var reset = func() {
	setprop("/systems/atc/transponder-code", 2000);
	for (var i = 0; i <= 2; i += 1) {
		switchPage("vhf", i);
	}
}

var switchPage = func(page, i) {
	if (page == "vhf") {
		changeFocus("", i);
		updateVHF(i);
	} else if (page[i] == "hf") {
	} else if (page[i] == "tel") {
	} else if (page[i] == "atc") {
	} else if (page[i] == "menu") {
	} else if (page[i] == "nav") {
	}
	pageNode[i].setValue(page);
}

var updateAll = func() {
	for (var i = 0; i <= 2; i += 1) {
		var page = pageNode[i].getValue();
		if (page == "vhf") {
			updateVHF(i);
		} else if (page == "hf") {
		} else if (page == "tel") {
		} else if (page == "atc") {
		} else if (page == "menu") {
		} else if (page == "nav") {
		}
	}
}

# Validate the frequency for valid VHF ranges
# Allows checking for partly entered numbers
# Expects the already entered frequency without decimal point
var validateVHF = func(freq) {
	if (freq < 1000) {
		var major = freq;
		var minor = 0;
	} else {
		if (freq < 10000) {
			var major = math.round(freq/10);
			var minor = freq * 100 - major * 1000;
		} else if (freq < 100000) {
			var major = math.round(freq/100);
			var minor = freq * 10 - major * 1000;
		} else if (freq < 1000000) {
			var major = math.round(freq/1000);
			var minor = freq - major * 1000;
		} else {
			# More than 6 digits always invalid
			return 0;
		}
	}
	if (major == 0 or (major > 2 and major <= 10) or (major > 13 and major <= 117) or major >= 137) {
		return 0;
	}
	var check = math.mod(minor, 25);
	if (math.mod(check, 5) != 0 or check == 20) {
		return 0;
	}
	return 1;
}

# Completes the frequency to its full length
# Expects the already entered frequency without decimal point
var completeVHF = func(freq) {
	if (freq < 100) {
		return freq * 10000;
	}
	if (freq < 1000) {
		return freq * 1000;
	}
	if (freq < 10000) {
		return freq * 100;
	}
	if (freq < 100000) {
		return freq * 10;
	}
	return freq;
}

var updateVHF = func(i) {
	foreach(var key; SVGKeys) {
		RMP[i][key].hide();
	}
	for (var j = 1; j <= 3; j += 1) {
		if (j == 3 and getprop("/systems/radio/vhf3-data-mode")) {
			RMP[i]["Active" ~ j].setText("DATA");
		} else {
			RMP[i]["Active" ~ j].setText(sprintf("%3.3f", getprop("/instrumentation/comm[" ~ (j - 1) ~ "]/frequencies/selected-mhz")));
		}
		RMP[i]["Active" ~ j].show();
		# TODO arrows
		RMP[i]["Standby" ~ j].setText(sprintf("%3.3f", getprop("/instrumentation/comm[" ~ (j - 1) ~ "]/frequencies/standby-mhz")));
		if (focusNode[i].getValue() == j) {
			RMP[i]["Standby" ~ j].setColor(BLUE);
			RMP[i]["Label" ~ j].setText("STBY");
			RMP[i]["Label" ~ j].setColor(WHITE);
			RMP[i]["Label" ~ j].show();
			RMP[i]["Select" ~ j].show();
		} else {
			RMP[i]["Standby" ~ j].setColor(WHITE);
		}
		if (enteringNode[j - 1].getValue()) {
			RMP[i]["Standby" ~ j].setFontSize(35, 1.0);
			# Check for invalid entries
			var entered = int(enteredNode[j - 1].getValue());
			var completionChar = "_";
			if (!validateVHF(entered)) {
				RMP[i]["Standby" ~ j].setColor(AMBER);
				RMP[i]["Label" ~ j].setText("INVALID");
				RMP[i]["Label" ~ j].setColor(AMBER);
				RMP[i]["Label" ~ j].show();
				RMP[i]["Select" ~ j].show();
			} else if (entered > 100) { # Completion possible starting at 3 digits entered
				var completionChar = "o";
			}
			var entered = enteredNode[j - 1].getValue();
			while (size(entered) < 3) {
				entered = entered ~ completionChar;
			}
			if(size(entered) < 4) {
				entered = entered ~ ".";
			} else if (size(entered) == 4) {
				entered = sprintf("%3.1f", int(entered) / 10);
			} else if (size(entered) == 5){
				entered = sprintf("%3.2f", int(entered) / 100);
			} else {
				entered = sprintf("%3.3f", int(entered) / 1000);
			}
			while (size(entered) < 7) {
				entered = entered ~ completionChar;
			}
			RMP[i]["Standby" ~ j].setText(entered);
		} else {
			RMP[i]["Standby" ~ j].setFontSize(45, 1.0);
		}
		RMP[i]["Standby" ~ j].show();
		if (getprop("/controls/audio/acp[" ~ i ~ "]/vhf" ~ j ~ "-recive")) {
			RMP[i]["Volume" ~ j].show();
		}
		RMP[i]["Channel" ~ j].setColor(WHITE);
		if (getprop("/systems/audio/acp[" ~ i ~ "]/call_chan") == "vhf" ~ j) {
			RMP[i]["Transmit" ~ j].show();
			if (!getprop("/controls/audio/acp[" ~ i ~ "]/vhf" ~ j ~ "-recive")) {
				RMP[i]["Volume" ~ j].show();
				RMP[i]["Mute" ~ j].show();
			}
			RMP[i]["Channel" ~ j].setColor(BLACK);
		}
		RMP[i]["Channel" ~ j].setText("VHF" ~ j);
		RMP[i]["Channel" ~ j].show();
	}
	updateLower(i);
}

var updateLower = func(i) {
	var mode = getprop("/controls/atc/mode-knob");
	if (mode == 4) {
		RMP[i]["TARA"].setText("TA/RA");
		RMP[i]["TARA"].setColor(GREEN);
		RMP[i]["Squawk"].setColor(GREEN);
		RMP[i]["AboveBelow"].setColor(GREEN);
		RMP[i]["SquawkLabel"].setText("SQWK" ~ (getprop("/controls/atc/system-knob") + 1));
	} else if (mode == 3) {
		RMP[i]["TARA"].setText("TA");
		RMP[i]["TARA"].setColor(GREEN);
		RMP[i]["Squawk"].setColor(GREEN);
		RMP[i]["AboveBelow"].setColor(GREEN);
		RMP[i]["SquawkLabel"].setText("SQWK" ~ (getprop("/controls/atc/system-knob") + 1));
	} else {
		# TODO STBY sometimes green and sometimes white, figure out reason
		RMP[i]["TARA"].setText("STBY");
		RMP[i]["TARA"].setColor(WHITE);
		RMP[i]["Squawk"].setColor(WHITE);
		RMP[i]["AboveBelow"].setColor(WHITE);
		RMP[i]["SquawkLabel"].setText("STBY");
	}
	RMP[i]["TARA"].show();
	RMP[i]["SquawkLabel"].show();
	RMP[i]["Squawk"].setText(sprintf("%4.0f", getprop("/systems/atc/transponder-code")));
	if (enteringNode[3].getValue()) {
		RMP[i]["Squawk"].setFontSize(45, 1.0);
		var entered = enteredNode[3].getValue();
		while (size(entered) < 4) {
			entered = entered ~ "_";
		}
		RMP[i]["Squawk"].setText(entered);
	} else {
		RMP[i]["Squawk"].setFontSize(67, 1.0);
	}
	RMP[i]["Squawk"].show();
	if (focusNode[i].getValue() == "ATC") {
		RMP[i]["Squawk"].setColor(BLUE);
		RMP[i]["SelectATC"].show();
	}
	var abvBlw = getprop("/controls/atc/abv-blw");
	if (abvBlw == 0) {
		RMP[i]["AboveBelow"].setText("NORM");
	} else if (abvBlw == -1) {
		RMP[i]["AboveBelow"].setText("ABV");
	} else {
		RMP[i]["AboveBelow"].setText("BLW");
	}
	RMP[i]["AboveBelow"].show();
}

var lskbutton = func(btn, i) {
	# No need if RMP is off/no power
	if (getprop("/controls/draims/rmp[" ~ i ~ "]/on") == 0) {
		return;
	}
	var page = pageNode[i].getValue();
	if (page == "vhf") {
		if (btn >= 1 and btn <= 3) {
			rmpID = btn - 1;
			if (enteringNode[rmpID].getValue()) {
				if (validateVHF(enteredNode[rmpID].getValue()) and enteredNode[rmpID].getValue() >= 100) { # 100 check cause we need at least 3 digits to complete
					setprop("/instrumentation/comm[" ~ rmpID ~ "]/frequencies/standby-mhz", completeVHF(enteredNode[rmpID].getValue()) / 1000);
					enteringNode[rmpID].setValue(0);
					enteredNode[rmpID].setValue("");
				} else {
					return; # Abort if we wanna switch to an invalid frequency
				}
			}
			var oldSelected = getprop("/instrumentation/comm[" ~ rmpID ~ "]/frequencies/selected-mhz");
			var oldStandby = getprop("/instrumentation/comm[" ~ rmpID ~ "]/frequencies/standby-mhz");
			# TODO activation of DATA mode
			if (btn == 3 and getprop("/systems/radio/vhf3-data-mode")) {
				setprop("/systems/radio/vhf3-data-mode", 0);
				setprop("/instrumentation/comm[" ~ rmpID ~ "]/frequencies/selected-mhz", oldStandby);
			} else {
				setprop("/instrumentation/comm[" ~ rmpID ~ "]/frequencies/selected-mhz", oldStandby);
				setprop("/instrumentation/comm[" ~ rmpID ~ "]/frequencies/standby-mhz", oldSelected);
			}
			updateAll();
		} else if (btn == 4) {
			changeFocus("ATC", i);
			updateAll(i);
		}
	} else if (page == "hf") {
	} else if (page == "tel") {
	} else if (page == "atc") {
	} else if (page == "menu") {
	} else if (page == "nav") {
	}
}

var rskbutton = func(btn, i) {
	# No need if RMP is off/no power
	if (getprop("/controls/draims/rmp[" ~ i ~ "]/on") == 0) {
		return;
	}
	var page = pageNode[i].getValue();
	if (page == "vhf") {
		if (btn >= 1 and btn <= 3) {
			var rmpID = btn - 1;
			if (btn == focusNode[i].getValue() and enteringNode[rmpID].getValue()) {
				if (validateVHF(enteredNode[rmpID].getValue()) and enteredNode[rmpID].getValue() >= 100) { # 100 check cause we need at least 3 digits to complete
					setprop("/instrumentation/comm[" ~ rmpID ~ "]/frequencies/standby-mhz", completeVHF(enteredNode[rmpID].getValue()) / 1000);
					enteringNode[rmpID].setValue(0);
					enteredNode[rmpID].setValue("");
				} else {
					return; # Abort if we wanna complete to an invalid frequency
				}
			} else {
				changeFocus(btn, i);
			}
			updateAll();
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
	updateAll();
}

var numberbutton = func(btn, i) {
	# No need if RMP is off/no power
	if (getprop("/controls/draims/rmp[" ~ i ~ "]/on") == 0) {
		return;
	}
	var focus = focusNode[i].getValue();
	if (focus == "ATC") {
		if (btn < 8) {
			enteringNode[3].setValue(1);
			enteredNode[3].setValue(enteredNode[3].getValue() ~ btn);
			if (size(enteredNode[3].getValue()) == 4) {
				enteringNode[3].setValue(0);
				setprop("/systems/atc/transponder-code", enteredNode[3].getValue());
				enteredNode[3].setValue("");
			}
			updateAll();
		}
	} else if (pageNode[i].getValue() == "vhf") {
		focus = focus - 1;
		if (enteredNode[focus].getValue() == "" and (btn == 2 or btn == 3)) {
			enteredNode[focus].setValue("1");
		}
		enteringNode[focus].setValue(1);
		if (size(enteredNode[focus].getValue()) < 6) {
			enteredNode[focus].setValue(enteredNode[focus].getValue() ~ btn);
		}
		if (size(enteredNode[focus].getValue()) == 6) {
			if (validateVHF(enteredNode[focus].getValue())) {
				enteringNode[focus].setValue(0);
				setprop("/instrumentation/comm[" ~ focus ~ "]/frequencies/standby-mhz", enteredNode[focus].getValue() / 1000);
				enteredNode[focus].setValue("");
			}
		}
		updateAll();
	}
}

var menuButton = func(btn, i) {
	# No need if RMP is off/no power
	if (getprop("/controls/draims/rmp[" ~ i ~ "]/on") == 0) {
		return;
	}
	# TODO
}

var clearButton = func(i) {
	# No need if RMP is off/no power
	if (getprop("/controls/draims/rmp[" ~ i ~ "]/on") == 0) {
		return;
	}
	var focus = focusNode[i].getValue();
	var page = pageNode[i].getValue();
	if (focus == "ATC" or page == "vhf" ) {
		if (focus == "ATC") {
			focus = 3;
		} else {
			focus = focus - 1;
		}
		var s = size(enteredNode[focus].getValue());
		if (s > 0) {
			enteredNode[focus].setValue(left(enteredNode[focus].getValue(), s - 1));
			if (s == 1) {
				enteringNode[focus].setValue(0);
			}
		}
	}
	updateAll();
}

var decimalButton = func(i) {
	# No need if RMP is off/no power
	if (getprop("/controls/draims/rmp[" ~ i ~ "]/on") == 0) {
		return;
	}
	# TODO
}

var changeFocus = func(item, i) {
	var focus = focusNode[i].getValue();
	if (item != focus) {
		if (focus == "ATC") {
			focus = 3;
		}
		if (focus != "") {
			enteringNode[focus - 1].setValue(0);
			enteredNode[focus - 1].setValue("");
		}
		focusNode[i].setValue(item);
		return 1;
	}
	return 0;
}

var arrowButton = func(dir, i) {
	# TODO implement
}

for (var i = 0; i <= 2; i += 1) {
	for (var j = 1; j <= 3; j += 1) {
		setlistener("/controls/audio/acp[" ~ i ~ "]/vhf" ~ j ~ "-recive", updateAll, 0, 0);
	}
	for (var j = 1; j <= 2; j += 1) {
		setlistener("/controls/audio/acp[" ~ i ~ "]/hf" ~ j ~ "-recive", updateAll, 0, 0);
		setlistener("/controls/audio/acp[" ~ i ~ "]/tel" ~ j ~ "-recive", updateAll, 0, 0);
	}
}

init();
