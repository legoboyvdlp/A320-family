# A320 DRAIMS RMP

# Copyright (c) 2025 Nia

# Distribute under the terms of GPLv2.

var SVGKeys = ["INTClickspot", "RADClickspot", "LSK1", "LSK2", "LSK3", "LSK4", "RSK4", "RSK3", "RSK1", "RSK2", "Brightness", "LShortcut", "RShortcut", "VHF1Transmit", "VHF1TransmitLabel", "VHF1TransmitLight", "VHF2Transmit", "VHF2TransmitLabel", "VHF2TransmitLight", "VHF3Transmit", "VHF3TransmitLabel", "VHF3TransmitLight", "HF1Transmit", "HF1TransmitLabel", "HF1TransmitLight", "HF2Transmit", "HF2TransmitLabel", "HF2TransmitLight", "TEL1Transmit", "TEL1TransmitLabel", "TEL1TransmitLight", "TEL2Transmit", "TEL2TransmitLabel", "TEL2TransmitLight", "INTTransmit", "INTTransmitLabel", "INTTransmitLight", "CABTransmit", "CABTransmitLabel", "CABTransmitLight", "PATransmit", "PATransmitLabel", "PATransmitLight", "1Key", "2Key", "3Key", "4Key", "5Key", "6Key", "7Key", "8Key", "9Key", "decimalKey", "0Key", "CLRKey", "VHF1Vol", "VHF1Knob", "VHF2Vol", "VHF2Knob", "VHF3Vol", "VHF3Knob", "HF1Vol", "HF1Knob", "HF2Vol", "HF2Knob", "TEL1Vol", "TEL1Knob", "TEL2Vol", "TEL2Knob", "INTVol", "INTKnob", "CABVol", "CABKnob", "PAVol", "PAKnob", "NAVVol", "NAVKnob", "Page_Blank", "Page_Menu", "Page_NAV", "Page_VHF", "Page_HF", "Page_TEL", "Page_ATC", "UpArrow", "DownArrow", "INTRAD", "RAD", "INT"];

var draimsClass = {
	new: func(instance) {
		var m = {parents:[draimsClass]};
		m._title = "RMP " ~ (instance + 1);
		m._gfd = nil;
		m._canvas = nil;
		m._timer = maketimer(0.3, m, draimsClass._timerf);
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
	},
	_onClose: func() {
		me.close();
	},
};

var draims1Dialog = draimsClass.new(0);
var draims2Dialog = draimsClass.new(1);
var draims3Dialog = draimsClass.new(2);
