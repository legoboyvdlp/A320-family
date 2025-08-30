# A320 DRAIMS RMP

# Copyright (c) 2025 Nia

# Distribute under the terms of GPLv2.

var SVGKeys = ["INTClickspot", "RADClickspot", "LSK1", "LSK2", "LSK3", "LSK4", "RSK4", "RSK3", "RSK1", "RSK2", "Brightness", "LShortcut", "RShortcut", "VHF1Transmit", "VHF1TransmitLabel", "VHF1TransmitLight", "VHF2Transmit", "VHF2TransmitLabel", "VHF2TransmitLight", "VHF3Transmit", "VHF3TransmitLabel", "VHF3TransmitLight", "HF1Transmit", "HF1TransmitLabel", "HF1TransmitLight", "HF2Transmit", "HF2TransmitLabel", "HF2TransmitLight", "TEL1Transmit", "TEL1TransmitLabel", "TEL1TransmitLight", "TEL2Transmit", "TEL2TransmitLabel", "TEL2TransmitLight", "INTTransmit", "INTTransmitLabel", "INTTransmitLight", "CABTransmit", "CABTransmitLabel", "CABTransmitLight", "PATransmit", "PATransmitLabel", "PATransmitLight", "1Key", "2Key", "3Key", "4Key", "5Key", "6Key", "7Key", "8Key", "9Key", "decimalKey", "0Key", "CLRKey", "VHF1Vol", "VHF1Knob", "VHF2Vol", "VHF2Knob", "VHF3Vol", "VHF3Knob", "HF1Vol", "HF1Knob", "HF2Vol", "HF2Knob", "TEL1Vol", "TEL1Knob", "TEL2Vol", "TEL2Knob", "INTVol", "INTKnob", "CABVol", "CABKnob", "PAVol", "PAKnob", "NAVVol", "NAVKnob", "Page_Blank", "Page_Menu", "Page_NAV", "Page_VHF", "Page_HF", "Page_TEL", "Page_ATC", "UpArrow", "DownArrow", "INTRAD", "RAD", "INT"];

var draimsClass = {
	new: func(instance) {
		var m = {parents:[draimsClass]};
		m._title = "RMP " ~ instance;
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

	#	me._Power_on_hb.addEventListener("click", func() {
	#		me._Power_on.show();
	#		me._Power_off.hide();
	#		me._prop_power.setValue(1);
	#	});

		me._timerf();
		me._timer.start();
	},
	_timerf: func() {
		var intrad = getprop("/controls/audio/acp[" ~ (me._instance - 1) ~ "]/int-rad");

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

var draims1Dialog = draimsClass.new(1);
var draims2Dialog = draimsClass.new(2);
var draims3Dialog = draimsClass.new(3);
