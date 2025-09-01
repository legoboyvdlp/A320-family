# A3XX DRAIMS RMP by Nia

# Copyright (c) 2025 Nia
var enteringNode = [
	props.globals.initNode("/systems/draims/fields[0]/entering", 1),
	props.globals.initNode("/systems/draims/fields[1]/entering", 1),
	props.globals.initNode("/systems/draims/fields[2]/entering", 1),
	props.globals.initNode("/systems/draims/fields[3]/entering", 1)];
var enteredNode = [
	props.globals.getNode("/systems/draims/fields[0]/entered", 1),
	props.globals.getNode("/systems/draims/fields[1]/entered", 1),
	props.globals.getNode("/systems/draims/fields[2]/entered", 1),
	props.globals.getNode("/systems/draims/fields[3]/entered", 1)];
var draimsPanel = [nil, nil, nil];
var SVGKeys = ["Transmit1", "Transmit2", "Transmit3", "Select1", "Select2", "Select3", "SelectATC", "Standby1", "Standby2", "Standby3", "Active1", "Active2", "Active3", "Channel1", "Channel3", "Channel2", "Volume1", "Volume2", "Volume3", "Mute1", "Mute2", "Mute3", "Label1", "Label2", "Label3", "SquawkLabel", "Squawk", "AboveBelow", "TARA", "Message1", "Message2", "Message3"];

var WHITE = [1.0000,1.0000,1.0000];
var BLACK = [0, 0, 0];
var GREEN = [0.0509,0.7529,0.2941];
var BLUE = [0.0901,0.6039,0.7176];
var AMBER = [0.7333,0.3803,0.0000];
var YELLOW = [0.9333,0.9333,0.0000];
var MAGENTA = [0.6902,0.3333,0.7541];

# TODO is there a power on self test?
var draimsPanelClass = {
	new: func(instance) {
		var m = {parents:[draimsPanelClass]};
		m.canvas = canvas.new({
			"name": "RMP" ~ (instance + 1) ~ " Display",
			"size": [1024, 624],
			"view": [1024, 624],
			"mipmapping": 1
		});
		var group = m.canvas.createGroup();
		canvas.parsesvg(group, "Aircraft/A320-family/Models/Instruments/DRAIMS/res/rmp.svg");
		group.setSize(1024,624);
		m.elements = {};
		foreach(var key; SVGKeys) {
			m.elements[key] = group.getElementById(key);
			m.elements[key].hide();
		}
		m.page = props.globals.getNode("/systems/draims/rmp[" ~ instance ~ "]/page", "vhf", "STRING", 1);
		m.focus = props.globals.initNode("/systems/draims/rmp[" ~ instance ~ "]/focus", "", "STRING", 1);
		m.on = props.globals.getNode("/controls/draims/rmp[" ~ i ~ "]/on", 1);
		return m;
	},
	switchPage: func(page) {
		me.page.setValue(page);
		me.changeFocus("");
		me.updatePage();
	},
	updatePage: func() {
		page = me.page.getValue();
		if (page == "vhf") {
			me.updateVHF();
		} else if (page == "hf") {
		} else if (page == "tel") {
		} else if (page == "atc") {
		} else if (page == "menu") {
		} else if (page == "nav") {
		}
	},
	updateVHF: func() {
		foreach(var key; SVGKeys) {
			me.elements[key].hide();
		}
		for (var j = 1; j <= 3; j += 1) {
			if (j == 3 and getprop("/systems/radio/vhf3-data-mode")) {
				me.elements["Active" ~ j].setText("DATA");
			} else {
				me.elements["Active" ~ j].setText(sprintf("%3.3f", getprop("/instrumentation/comm[" ~ (j - 1) ~ "]/frequencies/selected-mhz")));
			}
			me.elements["Active" ~ j].show();
			# TODO arrows
			me.elements["Standby" ~ j].setText(sprintf("%3.3f", getprop("/instrumentation/comm[" ~ (j - 1) ~ "]/frequencies/standby-mhz")));
			if (me.focus.getValue() == j) {
				me.elements["Standby" ~ j].setColor(BLUE);
				me.elements["Label" ~ j].setText("STBY");
				me.elements["Label" ~ j].setColor(WHITE);
				me.elements["Label" ~ j].show();
				me.elements["Select" ~ j].show();
			} else {
				me.elements["Standby" ~ j].setColor(WHITE);
			}
			if (enteringNode[j - 1].getValue()) {
				me.elements["Standby" ~ j].setFontSize(35, 1.0);
				# Check for invalid entries
				var entered = int(enteredNode[j - 1].getValue());
				var completionChar = "_";
				if (!validateVHF(entered)) {
					me.elements["Standby" ~ j].setColor(AMBER);
					me.elements["Label" ~ j].setText("INVALID");
					me.elements["Label" ~ j].setColor(AMBER);
					me.elements["Label" ~ j].show();
					me.elements["Select" ~ j].show();
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
				me.elements["Standby" ~ j].setText(entered);
			} else {
				me.elements["Standby" ~ j].setFontSize(45, 1.0);
			}
			me.elements["Standby" ~ j].show();
			if (getprop("/controls/audio/acp[" ~ i ~ "]/vhf" ~ j ~ "-receive")) {
				me.elements["Volume" ~ j].show();
			}
			me.elements["Channel" ~ j].setColor(WHITE);
			if (getprop("/systems/audio/acp[" ~ i ~ "]/call_chan") == "vhf" ~ j) {
				me.elements["Transmit" ~ j].show();
				if (!getprop("/controls/audio/acp[" ~ i ~ "]/vhf" ~ j ~ "-receive")) {
					me.elements["Volume" ~ j].show();
					me.elements["Mute" ~ j].show();
				}
				me.elements["Channel" ~ j].setColor(BLACK);
			}
			me.elements["Channel" ~ j].setText("VHF" ~ j);
			me.elements["Channel" ~ j].show();
		}
		me.updateLower();
	},
	updateLower: func() {
		var mode = getprop("/controls/atc/mode-knob");
		if (mode == 4) {
			me.elements["TARA"].setText("TA/RA");
			me.elements["TARA"].setColor(GREEN);
			me.elements["Squawk"].setColor(GREEN);
			me.elements["AboveBelow"].setColor(GREEN);
			me.elements["SquawkLabel"].setText("SQWK" ~ (getprop("/controls/atc/system-knob") + 1));
		} else if (mode == 3) {
			me.elements["TARA"].setText("TA");
			me.elements["TARA"].setColor(GREEN);
			me.elements["Squawk"].setColor(GREEN);
			me.elements["AboveBelow"].setColor(GREEN);
			me.elements["SquawkLabel"].setText("SQWK" ~ (getprop("/controls/atc/system-knob") + 1));
		} else {
			# TODO STBY sometimes green and sometimes white, figure out reason
			me.elements["TARA"].setText("STBY");
			me.elements["TARA"].setColor(WHITE);
			me.elements["Squawk"].setColor(WHITE);
			me.elements["AboveBelow"].setColor(WHITE);
			me.elements["SquawkLabel"].setText("STBY");
		}
		me.elements["TARA"].show();
		me.elements["SquawkLabel"].show();
		me.elements["Squawk"].setText(sprintf("%4.0f", getprop("/systems/atc/transponder-code")));
		if (enteringNode[3].getValue()) {
			me.elements["Squawk"].setFontSize(45, 1.0);
			var entered = enteredNode[3].getValue();
			while (size(entered) < 4) {
				entered = entered ~ "_";
			}
			me.elements["Squawk"].setText(entered);
		} else {
			me.elements["Squawk"].setFontSize(67, 1.0);
		}
		me.elements["Squawk"].show();
		if (me.focus.getValue() == "ATC") {
			me.elements["Squawk"].setColor(BLUE);
			me.elements["SelectATC"].show();
		}
		var abvBlw = getprop("/controls/atc/abv-blw");
		if (abvBlw == 0) {
			me.elements["AboveBelow"].setText("NORM");
		} else if (abvBlw == -1) {
			me.elements["AboveBelow"].setText("ABV");
		} else {
			me.elements["AboveBelow"].setText("BLW");
		}
		me.elements["AboveBelow"].show();
	},
	lskbutton: func(btn) {
		# No need if RMP is off/no power
		if (!me.on.getValue()) {
			return;
		}
		var page = me.page.getValue();
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
				me.changeFocus("ATC");
				updateAll();
			}
		} else if (page == "hf") {
		} else if (page == "tel") {
		} else if (page == "atc") {
		} else if (page == "menu") {
		} else if (page == "nav") {
		}
	},
	rskbutton: func(btn) {
		# No need if RMP is off/no power
		if (!me.on.getValue()) {
			return;
		}
		var page = me.page.getValue();
		if (page == "vhf") {
			if (btn >= 1 and btn <= 3) {
				var rmpID = btn - 1;
				if (btn == me.focus.getValue() and enteringNode[rmpID].getValue()) {
					if (validateVHF(enteredNode[rmpID].getValue()) and enteredNode[rmpID].getValue() >= 100) { # 100 check cause we need at least 3 digits to complete
						setprop("/instrumentation/comm[" ~ rmpID ~ "]/frequencies/standby-mhz", completeVHF(enteredNode[rmpID].getValue()) / 1000);
						enteringNode[rmpID].setValue(0);
						enteredNode[rmpID].setValue("");
					} else {
						return; # Abort if we wanna complete to an invalid frequency
					}
				} else {
					me.changeFocus(btn);
				}
				updateAll();
			}
		} else if (page == "hf") {
		} else if (page == "tel") {
		} else if (page == "atc") {
		} else if (page == "menu") {
		} else if (page == "nav") {
		}
	},
	numberbutton: func(btn) {
		# No need if RMP is off/no power
		if (!me.on.getValue()) {
			return;
		}
		var focus = me.focus.getValue();
		var page = me.page.getValue();
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
		} else if (page == "vhf") {
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
	},
	menuButton: func(btn) {
		# No need if RMP is off/no power
		if (!me.on.getValue()) {
			return;
		}
		# TODO
	},
	shortCutButton: func(btn) {
		# No need if RMP is off/no power
		if (!me.on.getValue()) {
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
	},
	clearButton: func() {
		# No need if RMP is off/no power
		if (!me.on.getValue()) {
			return;
		}
		var focus = me.focus.getValue();
		var page = me.page.getValue();
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
	},
	decimalButton: func() {
		# No need if RMP is off/no power
		if (!me.on.getValue()) {
			return;
		}
		# TODO figure out when this is used
	},
	changeFocus: func(item) {
		var focus = me.focus.getValue();
		if (item == focus) {
			return 0;
		}
		if (focus == "ATC") {
			focus = 3;
		}
		if (focus != "") {
			enteringNode[focus - 1].setValue(0);
			enteredNode[focus - 1].setValue("");
		}
		me.focus.setValue(item);
		return 1;
	},
#	arrowButton: func() {
#		# No need if RMP is off/no power
#		if (!me.on.getValue()) {
#			return;
#		}
#		# TODO implement
#	},
};

var init = func() {
	setprop("/systems/atc/transponder-code", 2000);
	for (var i = 0; i <= 3; i += 1) {
		enteringNode[i].setValue(0);
		enteredNode[i].setValue("");
	}
	for (var i = 0; i <= 2; i += 1) {
		draimsPanel[i].switchPage("vhf");
	}
}


var updateAll = func() {
	for (var i = 0; i <= 2; i += 1) {
		draimsPanel[i].updatePage();
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


# To comply with function call convention
var lskbutton = func(btn, i) {
	draimsPanel[i].lskbutton(btn);
}

# To comply with function call convention
var rskbutton = func(btn, i) {
	draimsPanel[i].rskbutton(btn);
}

# To comply with function call convention
var shortCutButton = func(btn, i) {
	draimsPanel[i].shortCutButton(btn);
}

# To comply with function call convention
var numberbutton = func(btn, i) {
	draimsPanel[i].numberbutton(btn);
}

# To comply with function call convention
var menuButton = func(btn, i) {
	draimsPanel[i].menuButton(btn);
}

# To comply with function call convention
var clearButton = func(i) {
	draimsPanel[i].clearButton();
}

# To comply with function call convention
var decimalButton = func(i) {
	draimsPanel[i].decimalButton();
}

# To comply with function call convention
var arrowButton = func(dir, i) {
	draimsPanel[i].arrowButton(dir);
}

for (var i = 0; i <= 2; i += 1) {
	draimsPanel[i] = draimsPanelClass.new(i);
}

for (var i = 0; i <= 2; i += 1) {
	for (var j = 1; j <= 3; j += 1) {
		setlistener("/controls/audio/acp[" ~ i ~ "]/vhf" ~ j ~ "-receive", updateAll, 0, 0);
	}
	for (var j = 1; j <= 2; j += 1) {
		setlistener("/controls/audio/acp[" ~ i ~ "]/hf" ~ j ~ "-receive", updateAll, 0, 0);
		setlistener("/controls/audio/acp[" ~ i ~ "]/tel" ~ j ~ "-receive", updateAll, 0, 0);
	}
}
