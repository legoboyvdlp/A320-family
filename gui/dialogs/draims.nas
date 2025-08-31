# A320 DRAIMS RMP

# Copyright (c) 2025 Nia

# Distribute under the terms of GPLv2.

var SVGKeys = ["INTClickspot", "RADClickspot", "LSK1", "LSK2", "LSK3", "LSK4", "RSK4", "RSK3", "RSK1", "RSK2", "Brightness", "LShortcut", "RShortcut", "VHF1Transmit", "VHF1TransmitLabel", "VHF1TransmitLight", "VHF2Transmit", "VHF2TransmitLabel", "VHF2TransmitLight", "VHF3Transmit", "VHF3TransmitLabel", "VHF3TransmitLight", "HF1Transmit", "HF1TransmitLabel", "HF1TransmitLight", "HF2Transmit", "HF2TransmitLabel", "HF2TransmitLight", "TEL1Transmit", "TEL1TransmitLabel", "TEL1TransmitLight", "TEL2Transmit", "TEL2TransmitLabel", "TEL2TransmitLight", "INTTransmit", "INTTransmitLabel", "INTTransmitLight", "CABTransmit", "CABTransmitLabel", "CABTransmitLight", "PATransmit", "PATransmitLabel", "PATransmitLight", "1Key", "2Key", "3Key", "4Key", "5Key", "6Key", "7Key", "8Key", "9Key", "decimalKey", "0Key", "CLRKey", "VHF1Vol", "VHF1Knob", "VHF2Vol", "VHF2Knob", "VHF3Vol", "VHF3Knob", "HF1Vol", "HF1Knob", "HF2Vol", "HF2Knob", "TEL1Vol", "TEL1Knob", "TEL2Vol", "TEL2Knob", "INTVol", "INTKnob", "CABVol", "CABKnob", "PAVol", "PAKnob", "NAVVol", "NAVKnob", "Page_Blank", "Page_Menu", "Page_NAV", "Page_VHF", "Page_HF", "Page_TEL", "Page_ATC", "UpArrow", "DownArrow", "INTRAD", "RAD", "INT"];

var colors = {};
colors["volOff"] = [0.2901960784, 0.3019607843, 0.2862745098];
colors["volOn"] = [0.7764705882, 0.8941176471, 0.5176470588];
colors["transmitOff"] = [0.1411764706, 0.1450980392, 0.1450980392];
colors["transmitOn"] = [0.3607843137, 0.9725490196, 0.03529411765];

var toggle = func (prop) {
	if (getprop(prop)) {
		setprop(prop, 0);
	} else {
		setprop(prop, 1);
	}
}

var draimsClass = {
	new: func(instance) {
		var m = {parents:[draimsClass]};
		m._title = "RMP " ~ (instance + 1);
		m._gfd = nil;
		m._canvas = nil;
		m._timer = maketimer(0.1, m, draimsClass._timerf);
		m._instance = instance;
		return m;
	},
	close: func() {
		me._timer.stop();
		me._gfd.del();
		me._gfd = nil;
	},
	openDialog: func() {
		me._gfd = canvas.Window.new([470,540], "dialog");
		me._gfd._onClose = func() {draimsDialog._onClose();}

		me._gfd.set("title", me._title);
		me._canvas  = me._gfd.createCanvas();
		me._root = me._canvas.createGroup();

		me._svg = me._root.createChild("group");
		canvas.parsesvg(me._svg, "Aircraft/A320-family/gui/dialogs/draims.svg");

		me._elements = {};
		foreach(var key; SVGKeys) {
			me._elements[key] = me._svg.getElementById(key);
		}

		me._root.createChild("image").setFile(draims.RMPCanvas[me._instance].getPath()).setSize(294, 188).setTranslation(89, 50);

		# Shortcuts
		me._elements["RShortcut"].addEventListener("click", func() {draims.shortCutButton("r", me._instance);});
		me._elements["LShortcut"].addEventListener("click", func() {draims.shortCutButton("l", me._instance);});

		# Pages
		me._elements["Page_Menu"].addEventListener("click", func() {draims.menuButton("menu", me._instance);});
		me._elements["Page_NAV"].addEventListener("click", func() {draims.menuButton("nav", me._instance);});
		me._elements["Page_VHF"].addEventListener("click", func() {draims.menuButton("vhf", me._instance);});
		me._elements["Page_HF"].addEventListener("click", func() {draims.menuButton("hf", me._instance);});
		me._elements["Page_TEL"].addEventListener("click", func() {draims.menuButton("tel", me._instance);});
		me._elements["Page_ATC"].addEventListener("click", func() {draims.menuButton("atc", me._instance);});

		# Numpad
		me._elements["1Key"].addEventListener("click", func() {draims.numberbutton(1, me._instance);});
		me._elements["2Key"].addEventListener("click", func() {draims.numberbutton(2, me._instance);});
		me._elements["3Key"].addEventListener("click", func() {draims.numberbutton(3, me._instance);});
		me._elements["4Key"].addEventListener("click", func() {draims.numberbutton(4, me._instance);});
		me._elements["5Key"].addEventListener("click", func() {draims.numberbutton(5, me._instance);});
		me._elements["6Key"].addEventListener("click", func() {draims.numberbutton(6, me._instance);});
		me._elements["7Key"].addEventListener("click", func() {draims.numberbutton(7, me._instance);});
		me._elements["8Key"].addEventListener("click", func() {draims.numberbutton(8, me._instance);});
		me._elements["9Key"].addEventListener("click", func() {draims.numberbutton(9, me._instance);});
		me._elements["0Key"].addEventListener("click", func() {draims.numberbutton(0, me._instance);});
		me._elements["decimalKey"].addEventListener("click", func() {draims.decimalButton(me._instance);});
		me._elements["CLRKey"].addEventListener("click", func() {draims.clearButton(me._instance);});

		# LSKs
		me._elements["LSK1"].addEventListener("click", func() {draims.lskbutton(1, me._instance);});
		me._elements["LSK2"].addEventListener("click", func() {draims.lskbutton(2, me._instance);});
		me._elements["LSK3"].addEventListener("click", func() {draims.lskbutton(3, me._instance);});
		me._elements["LSK4"].addEventListener("click", func() {draims.lskbutton(4, me._instance);});
		me._elements["RSK1"].addEventListener("click", func() {draims.rskbutton(1, me._instance);});
		me._elements["RSK2"].addEventListener("click", func() {draims.rskbutton(2, me._instance);});
		me._elements["RSK3"].addEventListener("click", func() {draims.rskbutton(3, me._instance);});
		me._elements["RSK4"].addEventListener("click", func() {draims.rskbutton(4, me._instance);});

		# Volume Knobs
		me._elements["VHF1Vol"].addEventListener("click", func() {toggle("/controls/audio/acp[" ~ me._instance ~ "]/vhf1-recive");});
		me._elements["VHF2Vol"].addEventListener("click", func() {toggle("/controls/audio/acp[" ~ me._instance ~ "]/vhf2-recive");});
		me._elements["VHF3Vol"].addEventListener("click", func() {toggle("/controls/audio/acp[" ~ me._instance ~ "]/vhf3-recive");});
		me._elements["HF1Vol"].addEventListener("click", func() {toggle("/controls/audio/acp[" ~ me._instance ~ "]/hf1-recive");});
		me._elements["HF2Vol"].addEventListener("click", func() {toggle("/controls/audio/acp[" ~ me._instance ~ "]/hf2-recive");});
		me._elements["TEL1Vol"].addEventListener("click", func() {toggle("/controls/audio/acp[" ~ me._instance ~ "]/tel1-recive");});
		me._elements["TEL2Vol"].addEventListener("click", func() {toggle("/controls/audio/acp[" ~ me._instance ~ "]/tel2-recive");});
		me._elements["INTVol"].addEventListener("click", func() {toggle("/controls/audio/acp[" ~ me._instance ~ "]/int-recive");});
		me._elements["CABVol"].addEventListener("click", func() {toggle("/controls/audio/acp[" ~ me._instance ~ "]/cab-recive");});
		me._elements["NAVVol"].addEventListener("click", func() {toggle("/controls/audio/acp[" ~ me._instance ~ "]/nav-recive");});
		me._elements["PAVol"].addEventListener("click", func() {toggle("/controls/audio/acp[" ~ me._instance ~ "]/pa-recive");});

		me._timerf();
		me._timer.start();
	},
	_timerf: func() {
		var intrad = getprop("/controls/audio/acp[" ~ me._instance ~ "]/int-rad");

		if (intrad == 2) {
			me._elements["INT"].show();
			me._elements["INTRAD"].hide();
			me._elements["RAD"].hide();
		} else if (intrad == 1) {
			me._elements["INT"].hide();
			me._elements["INTRAD"].show();
			me._elements["RAD"].hide();
		} else {
			me._elements["INT"].hide();
			me._elements["INTRAD"].hide();
			me._elements["RAD"].show();
		}

		var on = getprop("/controls/draims/rmp[" ~ me._instance ~ "]/on");
		for (var i = 1; i <= 3; i += 1) {
			if (on and getprop("/controls/audio/acp[" ~ me._instance ~ "]/vhf" ~ i ~ "-recive")) {
				me._elements["VHF" ~ i ~ "Knob"].setColorFill(colors["volOn"]);
			} else {
				me._elements["VHF" ~ i ~ "Knob"].setColorFill(colors["volOff"]);
			}
		}
		for (var i = 1; i <= 2; i += 1) {
			if (on and getprop("/controls/audio/acp[" ~ me._instance ~ "]/hf" ~ i ~ "-recive")) {
				me._elements["HF" ~ i ~ "Knob"].setColorFill(colors["volOn"]);
			} else {
				me._elements["HF" ~ i ~ "Knob"].setColorFill(colors["volOff"]);
			}
			if (on and getprop("/controls/audio/acp[" ~ me._instance ~ "]/tel" ~ i ~ "-recive")) {
				me._elements["TEL" ~ i ~ "Knob"].setColorFill(colors["volOn"]);
			} else {
				me._elements["TEL" ~ i ~ "Knob"].setColorFill(colors["volOff"]);
			}
		}
		if (on and getprop("/controls/audio/acp[" ~ me._instance ~ "]/nav-recive")) {
			me._elements["NAVKnob"].setColorFill(colors["volOn"]);
		} else {
			me._elements["NAVKnob"].setColorFill(colors["volOff"]);
		}
		if (on and getprop("/controls/audio/acp[" ~ me._instance ~ "]/int-recive")) {
			me._elements["INTKnob"].setColorFill(colors["volOn"]);
		} else {
			me._elements["INTKnob"].setColorFill(colors["volOff"]);
		}
		if (on and getprop("/controls/audio/acp[" ~ me._instance ~ "]/cab-recive")) {
			me._elements["CABKnob"].setColorFill(colors["volOn"]);
		} else {
			me._elements["CABKnob"].setColorFill(colors["volOff"]);
		}
		if (on and getprop("/controls/audio/acp[" ~ me._instance ~ "]/pa-recive")) {
			me._elements["PAKnob"].setColorFill(colors["volOn"]);
		} else {
			me._elements["PAKnob"].setColorFill(colors["volOff"]);
		}
	},
	_onClose: func() {
		me.close();
	},
};

var draims1Dialog = draimsClass.new(0);
var draims2Dialog = draimsClass.new(1);
var draims3Dialog = draimsClass.new(2);
