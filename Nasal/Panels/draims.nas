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
var vhf3DataStandby = props.globals.initNode("/systems/draims/vhf3-data-standby", 0, "BOOL", 1);
var vhf3EmerStandby = props.globals.initNode("/systems/draims/vhf3-emer-standby", 0, "BOOL", 1);
var hfEmerStandby = [props.globals.initNode("/systems/draims/hf1-emer-standby", 0, "BOOL", 1), props.globals.initNode("/systems/draims/hf2-emer-standby", 0, "BOOL", 1)];
var draimsPanel = [nil, nil, nil];
var SVGKeysFreq = ["Transmit1", "Transmit2", "Transmit3", "Select1", "Select2", "Select3", "SelectATC", "Standby1", "Standby2", "Standby3", "Active1", "Active2", "Active3", "Channel1", "Channel3", "Channel2", "Volume1", "Volume2", "Volume3", "Mute1", "Mute2", "Mute3", "Label1", "Label2", "Label3", "SquawkLabel", "Squawk", "AboveBelow", "TARA", "Message1", "Message2", "Message3", "ArrowUp1", "ArrowDown1", "ArrowUp2", "ArrowDown2", "ArrowUp3", "ArrowDown3", "AM1", "AM2", "AMMode", "AMModeOn", "AMModeOff", "AMModeOnBox", "AMModeOffBox"];
var SVGKeysATC = ["SquawkLabel", "Ident", "Squawk", "Message1", "Message2", "Message3", "AltRptgOnBox", "AltRptgOffBox", "AltRptgOn", "AltRptgOff", "TcasDisplayMode", "TcasDisplayThrtBox", "TcasDisplayBlwBox", "TcasDisplayThrt", "TcasDisplayBlw", "TcasDisplayAbvBox", "TcasDisplayAbv", "TcasDisplayNormBox", "TcasDisplayNorm", "TcasModeTaBox", "TcasModeTaRaBox", "TcasModeTa", "TcasModeTaRa", "TcasModeStbyBox", "TcasModeStby", "XPDR2Box", "XPDR1Box", "XPDR2", "XPDR1", "AtcModeAutoBox", "AtcModeStbyBox", "AtcModeAuto", "AtcModeStby"];
var WHITE = [1.0000,1.0000,1.0000];
var GREY = [0.3, 0.3, 0.3];
var BLACK = [0, 0, 0];
var GREEN = [0.0509,0.7529,0.2941];
var BLUE = [0.0901,0.6039,0.7176];
var AMBER = [0.7333,0.3803,0.0000];
var YELLOW = [0.9333,0.9333,0.0000];
var MAGENTA = [0.6902,0.3333,0.7541];

# TODO is there a power on self test?
# TODO messages such as vhf1 reverted
var draimsPanelClass = {
	new: func(instance) {
		var m = {parents:[draimsPanelClass]};
		m.instance = instance;
		m.canvas = canvas.new({
			"name": "RMP" ~ (instance + 1) ~ " Display",
			"size": [1024, 624],
			"view": [1024, 624],
			"mipmapping": 1
		});

		m.freqPage = m.canvas.createGroup();
		canvas.parsesvg(m.freqPage, "Aircraft/A320-family/Models/Instruments/DRAIMS/res/freq.svg");
		m.freqPage.setSize(1024,624);
		m.elements = {};
		foreach(var key; SVGKeysFreq) {
			m.elements[key] = m.freqPage.getElementById(key);
			m.elements[key].hide();
		}

		m.atcPage = m.canvas.createGroup();
		canvas.parsesvg(m.atcPage, "Aircraft/A320-family/Models/Instruments/DRAIMS/res/atc.svg");
		m.atcPage.setSize(1024,624);
		m.elementsAtc = {};
		foreach(var key; SVGKeysATC) {
			m.elementsAtc[key] = m.atcPage.getElementById(key);
		}
		m.atcPage.hide();

		m.page = props.globals.getNode("/systems/draims/rmp[" ~ instance ~ "]/page", "vhf", "STRING", 1);
		m.focus = props.globals.initNode("/systems/draims/rmp[" ~ instance ~ "]/focus", "", "STRING", 1);
		m.on = props.globals.getNode("/systems/draims/rmp[" ~ instance ~ "]/on", 1);
		return m;
	},
	switchPage: func(page) {
		if (page == "vhf" or page == "hf" or page == "tel") {
			me.changeFocus("");
			me.freqPage.show();
			me.atcPage.hide();
		} else if (page == "atc") {
			me.changeFocus("ATC");
			me.freqPage.hide();
			me.atcPage.show();
		}
		me.page.setValue(page);
		me.updatePage();
	},
	updatePage: func() {
		if (!me.on.getValue()) {
			me.freqPage.hide();
			me.atcPage.hide();
			return;
		}
		page = me.page.getValue();
		if (page == "vhf") {
			me.freqPage.show();
			me.updateVHF();
		} else if (page == "hf") {
			me.freqPage.show();
			me.updateHF();
		} else if (page == "tel") {
		} else if (page == "atc") {
			me.atcPage.show();
			me.updateATC();
		} else if (page == "menu") {
		} else if (page == "nav") {
		}
	},
	updateVHF: func() {
		foreach(var key; SVGKeysFreq) {
			me.elements[key].hide();
		}
		for (var j = 1; j <= 3; j += 1) {
			# Active
			if (j == 3 and getprop("/systems/radio/vhf3-data-mode")) {
				me.elements["Active" ~ j].setText("DATA");
			} else {
				me.elements["Active" ~ j].setText(sprintf("%3.3f", getprop("/instrumentation/comm[" ~ (j - 1) ~ "]/frequencies/selected-mhz")));
			}
			me.elements["Active" ~ j].show();
			# Standby
			if (j == 3 and vhf3DataStandby.getValue()) {
				me.elements["Standby" ~ j].setText("DATA");
			} else if (j == 3 and vhf3EmerStandby.getValue()) {
				me.elements["Standby" ~ j].setText("121.500");
			} else {
				me.elements["Standby" ~ j].setText(sprintf("%3.3f", getprop("/instrumentation/comm[" ~ (j - 1) ~ "]/frequencies/standby-mhz")));
			}
			# Focus, Standby Color and Arrows
			if (me.focus.getValue() == j) {
				if (j == 3) {
					if (vhf3DataStandby.getValue()) {
						me.elements["ArrowUp3"].show();
						me.elements["ArrowDown3"].show();
					} else if (vhf3EmerStandby.getValue()) {
						me.elements["ArrowUp3"].show();
						me.elements["Label" ~ j].setText("EMER");
						me.elements["Label" ~ j].show();
					} else {
						me.elements["ArrowDown3"].show();
						me.elements["Label" ~ j].setText("STBY");
						me.elements["Label" ~ j].show();
					}
				} else {
					me.elements["Label" ~ j].setText("STBY");
					me.elements["Label" ~ j].show();
				}
				me.elements["Standby" ~ j].setColor(BLUE);
				me.elements["Label" ~ j].setColor(WHITE);
				me.elements["Select" ~ j].show();
			} else {
				me.elements["Standby" ~ j].setColor(WHITE);
			}
			# Standby entering content
			if (enteringNode[j - 1].getValue()) {
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
			}
			# Reception
			me.elements["Standby" ~ j].show();
			if (acp.ACP[me.instance].receive.vhf[j - 1].getValue()) {
				me.elements["Volume" ~ j].show();
			}
			# Transmission and Mute
			me.elements["Channel" ~ j].setColor(WHITE);
			if (acp.ACP[me.instance].transmitChannel.getValue() == "vhf" ~ j) {
				me.elements["Transmit" ~ j].show();
				me.elements["Channel" ~ j].setColor(BLACK);
				if (!acp.ACP[me.instance].receive.vhf[j - 1].getValue()) {
					me.elements["Volume" ~ j].show();
					me.elements["Mute" ~ j].show();
				}
			}
			me.elements["Channel" ~ j].setText("VHF" ~ j);
			me.elements["Channel" ~ j].show();
		}
		me.updateLower();
	},
	updateHF: func() {
		foreach(var key; SVGKeysFreq) {
			me.elements[key].hide();
		}
		var focus = me.focus.getValue();
		for (var j = 1; j <= 2; j += 1) {
			# Active
			me.elements["Active" ~ j].setText(sprintf("%2.3f", systems.HFS[j - 1].selectedChannelKhz / 1000));
			me.elements["Active" ~ j].show();
			# Standby
			if (hfEmerStandby[j - 1].getValue()) {
				me.elements["Standby" ~ j].setText(sprintf("%2.3f", 8.364));
			} else {
				me.elements["Standby" ~ j].setText(sprintf("%2.3f", getprop("/systems/radio/rmp[" ~ me.instance ~ "]/hf" ~ j ~ "-standby") / 1000));
			}
			# Focus, Standby Color and Arrows
			if (focus == j) {
				if (hfEmerStandby[j - 1].getValue()) {
					me.elements["ArrowUp" ~ j].show();
					me.elements["Label" ~ j].setText("EMER");
					me.elements["Label" ~ j].show();
				} else {
					me.elements["ArrowDown" ~ j].show();
					me.elements["Label" ~ j].setText("STBY");
					me.elements["Label" ~ j].show();
				}
				me.elements["Standby" ~ j].setColor(BLUE);
				me.elements["Label" ~ j].setColor(WHITE);
				me.elements["Select" ~ j].show();
			} else {
				me.elements["Standby" ~ j].setColor(WHITE);
			}
			# Standby entering content TODO
			if (enteringNode[j - 1].getValue()) {
				# Check for invalid entries
				var entered = int(enteredNode[j - 1].getValue());
				var completionChar = "_";
				if (!validateVHF(entered)) {
					me.elements["Standby" ~ j].setColor(AMBER);
					me.elements["Label" ~ j].setText("INVALID");
					me.elements["Label" ~ j].setColor(AMBER);
					me.elements["Label" ~ j].show();
					me.elements["Select" ~ j].show();
				} else if (entered > 100) { # Completion possible starting at 3 digits entered TODO
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
			}
			# Reception
			me.elements["Standby" ~ j].show();
			if (acp.ACP[me.instance].receive.hf[j - 1].getValue()) {
				me.elements["Volume" ~ j].show();
			}
			# Transmission and Mute
			me.elements["Channel" ~ j].setColor(WHITE);
			if (acp.ACP[me.instance].transmitChannel.getValue() == "hf" ~ j) {
				me.elements["Transmit" ~ j].show();
				me.elements["Channel" ~ j].setColor(BLACK);
				if (!acp.ACP[me.instance].receive.hf[j - 1].getValue()) {
					me.elements["Volume" ~ j].show();
					me.elements["Mute" ~ j].show();
				}
			}
			me.elements["Channel" ~ j].setText("HF" ~ j);
			me.elements["Channel" ~ j].show();
			# AM indication
			if (systems.HFS[j - 1].am.getValue()) {
				me.elements["AM" ~ j].show();
			}
		}
		# AM Mode switch
		if (focus == 1 or focus == 2) {
			me.elements["AMMode"].setText("HF" ~ sprintf("%1.0f", focus) ~ " AM MODE");
			me.elements["AMMode"].show();
			var amActive = systems.HFS[focus - 1].am.getValue();
			if (amActive) {
				me.elements["AMModeOn"].setColor(BLACK);
				me.elements["AMModeOff"].setColor(WHITE);
				me.elements["AMModeOnBox"].show();
			} else {
				me.elements["AMModeOn"].setColor(WHITE);
				me.elements["AMModeOff"].setColor(BLACK);
				me.elements["AMModeOffBox"].show();
			}
			me.elements["AMModeOn"].show();
			me.elements["AMModeOff"].show();
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
		me.elements["Squawk"].setText(sprintf("%04.0f", getprop("/systems/atc/transponder-code")));
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
	updateATC: func() {
		var tcasBoxes = ["TcasDisplayThrtBox", "TcasDisplayBlwBox", "TcasDisplayAbvBox", "TcasDisplayNormBox", "TcasModeTaBox", "TcasModeTaRaBox", "TcasModeStbyBox", "AltRptgOnBox", "AltRptgOffBox"];
		if (getprop("/controls/atc/mode-knob") < 3) {
			foreach(var key; tcasBoxes) {
				me.elementsAtc[key].setColorFill(BLACK);
				me.elementsAtc[key].hide();
			}
			me.elementsAtc["Ident"].setColor(GREY);
			me.elementsAtc["SquawkLabel"].setText("STBY");
			me.elementsAtc["AtcModeStby"].setColor(BLACK);
			me.elementsAtc["AtcModeAuto"].setColor(WHITE);
			me.elementsAtc["AtcModeStbyBox"].show();
			me.elementsAtc["AtcModeAutoBox"].hide();
			var tcasTextColor = WHITE;
		} else {
			foreach(var key; tcasBoxes) {
				me.elementsAtc[key].setColorFill(BLUE);
				me.elementsAtc[key].hide();
			}
			me.elementsAtc["Ident"].setColor(BLUE);
			me.elementsAtc["SquawkLabel"].setText("SQWK" ~ (getprop("/controls/atc/system-knob") + 1));
			me.elementsAtc["AtcModeStby"].setColor(WHITE);
			me.elementsAtc["AtcModeAuto"].setColor(BLACK);
			me.elementsAtc["AtcModeStbyBox"].hide();
			me.elementsAtc["AtcModeAutoBox"].show();
			var tcasTextColor = BLACK;
		}
		me.elementsAtc["Squawk"].setColor(BLUE);
		me.elementsAtc["Squawk"].setText(sprintf("%04.0f", getprop("/systems/atc/transponder-code")));
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
		if (getprop("/controls/atc/system-knob")) {
			me.elementsAtc["XPDR1"].setColor(WHITE);
			me.elementsAtc["XPDR2"].setColor(BLACK);
			me.elementsAtc["XPDR1Box"].hide();
			me.elementsAtc["XPDR2Box"].show();
		} else {
			me.elementsAtc["XPDR1"].setColor(BLACK);
			me.elementsAtc["XPDR2"].setColor(WHITE);
			me.elementsAtc["XPDR1Box"].show();
			me.elementsAtc["XPDR2Box"].hide();
		}
		var mode = getprop("/controls/atc/mode-knob");
		if (mode == 4) {
			me.elementsAtc["TcasModeTaRa"].setColor(tcasTextColor);
			me.elementsAtc["TcasModeTaRaBox"].show();
			me.elementsAtc["TcasModeTa"].setColor(WHITE);
			me.elementsAtc["TcasModeStby"].setColor(WHITE);
		} else if (mode == 3) {
			me.elementsAtc["TcasModeTa"].setColor(tcasTextColor);
			me.elementsAtc["TcasModeTaBox"].show();
			me.elementsAtc["TcasModeTaRa"].setColor(WHITE);
			me.elementsAtc["TcasModeStby"].setColor(WHITE);
		}
		# TODO standby
		me.elementsAtc["TcasDisplayThrt"].setColor(WHITE);
		me.elementsAtc["TcasDisplayNorm"].setColor(WHITE);
		me.elementsAtc["TcasDisplayAbv"].setColor(WHITE);
		me.elementsAtc["TcasDisplayBlw"].setColor(WHITE);
		if (getprop("/controls/atc/thrt-all")) {
			me.elementsAtc["TcasDisplayThrt"].setColor(tcasTextColor);
			me.elementsAtc["TcasDisplayThrtBox"].show();
		} else if (getprop("/controls/atc/abv-blw") == 1) {
			me.elementsAtc["TcasDisplayBlw"].setColor(tcasTextColor);
			me.elementsAtc["TcasDisplayBlwBox"].show();
		} else if (getprop("/controls/atc/abv-blw") == -1) {
			me.elementsAtc["TcasDisplayAbv"].setColor(tcasTextColor);
			me.elementsAtc["TcasDisplayAbvBox"].show();
		} else {
			me.elementsAtc["TcasDisplayNorm"].setColor(tcasTextColor);
			me.elementsAtc["TcasDisplayNormBox"].show();
		}
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
				var oldData = getprop("/systems/radio/vhf3-data-mode");
				if (btn == 3 and getprop("/systems/radio/vhf3-data-mode")) {
					setprop("/systems/radio/vhf3-data-mode", 0);
				}
				if (btn == 3 and vhf3DataStandby.getValue()) {
					vhf3DataStandby.setValue(0);
					setprop("/systems/radio/vhf3-data-mode", 1);
					if (!oldData) {
						setprop("/instrumentation/comm[" ~ rmpID ~ "]/frequencies/standby-mhz", oldSelected);
					}
				} else if (btn == 3 and vhf3EmerStandby.getValue()) {
					vhf3EmerStandby.setValue(0);
					setprop("/instrumentation/comm[" ~ rmpID ~ "]/frequencies/selected-mhz", 121.5);
					if (!oldData) {
						setprop("/instrumentation/comm[" ~ rmpID ~ "]/frequencies/standby-mhz", oldSelected);
					}
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
			if (btn == 1 and btn == 2) {
				# TODO
				updateAll();
			} else if (btn == 4) {
				me.changeFocus("ATC");
				updateAll();
			}
		} else if (page == "tel") {
		} else if (page == "atc") {
			if (btn == 1) {
				if (getprop("/controls/atc/system-knob") == 0) {
					setprop("/controls/atc/system-knob", 1);
				} else {
					setprop("/controls/atc/system-knob", 0);
				}
			} else if (btn == 2) {
			}
			updateAll();
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
		var focus = me.focus.getValue();
		if (page == "vhf") {
			if (btn >= 1 and btn <= 3) {
				var rmpID = btn - 1;
				if (btn == focus and enteringNode[rmpID].getValue()) {
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
			if (btn == 1 or btn == 2) {
			#	# TODO check how completion on HF works
			#	var rmpID = btn - 1;
			#	if (btn == me.focus.getValue() and enteringNode[rmpID].getValue()) {
			#		if (validateVHF(enteredNode[rmpID].getValue()) and enteredNode[rmpID].getValue() >= 100) { # 100 check cause we need at least 3 digits to complete
			#			setprop("/instrumentation/comm[" ~ rmpID ~ "]/frequencies/standby-mhz", completeVHF(enteredNode[rmpID].getValue()) / 1000);
			#			enteringNode[rmpID].setValue(0);
			#			enteredNode[rmpID].setValue("");
			#		} else {
			#			return; # Abort if we wanna complete to an invalid frequency
			#		}
			#	} else {
					me.changeFocus(btn);
			#	}
				updateAll();
			} else if (btn == 3) {
				if (systems.HFS[focus - 1].am.getValue()) {
					systems.HFS[focus - 1].am.setValue(0);
				} else {
					systems.HFS[focus - 1].am.setValue(1);
				}
				updateAll();
			}
		} else if (page == "tel") {
		} else if (page == "atc") {
			if (btn == 2) {
				if (getprop("/controls/atc/thrt-all")) {
					setprop("/controls/atc/thrt-all", 0);
				} else if (getprop("/controls/atc/abv-blw") == 0) {
					setprop("/controls/atc/abv-blw", -1);
				} else if (getprop("/controls/atc/abv-blw") == -1) {
					setprop("/controls/atc/abv-blw", 1);
				} else {
					setprop("/controls/atc/abv-blw", 0);
					setprop("/controls/atc/thrt-all", 1);
				}
			}
			updateAll();
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
			if (focus == 3) {
				vhf3DataStandby.setValue(0);
				vhf3EmerStandby.setValue(0);
			}
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
		me.switchPage(btn);
	},
	shortCutButton: func(btn) {
		# No need if RMP is off/no power
		if (!me.on.getValue()) {
			return;
		}
		var page = me.page.getValue();
		if (page == "vhf" or page == "hf" or page == "tel") {
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
			focus = 4;
		}
		if (focus != "") {
			enteringNode[focus - 1].setValue(0);
			enteredNode[focus - 1].setValue("");
		}
		me.focus.setValue(item);
		return 1;
	},
	arrowButton: func(btn) {
		# No need if RMP is off/no power
		if (!me.on.getValue()) {
			return;
		}
		var focus = me.focus.getValue();
		var page =  me.page.getValue();
		if (focus == 3 and page == "vhf") {
			if (btn == "u") {
				if (vhf3DataStandby.getValue()) {
					vhf3DataStandby.setValue(0);
				} else if (vhf3EmerStandby.getValue()) {
					vhf3DataStandby.setValue(1);
					vhf3EmerStandby.setValue(0);
				}
			} else {
				if (vhf3DataStandby.getValue()) {
					vhf3DataStandby.setValue(0);
					vhf3EmerStandby.setValue(1);
				} else if (!vhf3EmerStandby.getValue()) {
					vhf3DataStandby.setValue(1);
				}
			}
			updateAll();
		}
		if ((focus == 1 or focus == 2) and page == "hf") {
			if (btn == "u") {
				hfEmerStandby[focus - 1].setValue(0);
			} else {
				hfEmerStandby[focus - 1].setValue(1);
			}
			updateAll();
		}
	},
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
	setlistener("/systems/audio/acp[" ~ i ~ "]/transmitChannel", updateAll, 0, 0);
	setlistener("/systems/draims/rmp[" ~ i ~ "]/on", updateAll, 0, 0);
	for (var j = 1; j <= 3; j += 1) {
		setlistener("/controls/audio/acp[" ~ i ~ "]/vhf" ~ j ~ "-receive", updateAll, 0, 0);
	}
	for (var j = 1; j <= 2; j += 1) {
		setlistener("/controls/audio/acp[" ~ i ~ "]/hf" ~ j ~ "-receive", updateAll, 0, 0);
		setlistener("/controls/audio/acp[" ~ i ~ "]/tel" ~ j ~ "-receive", updateAll, 0, 0);
	}
}
