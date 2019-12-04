# A320 RM panel
# merspieler

# Copyright (c) 2019 merspieler

# Distribute under the terms of GPLv2.

var _default_instrument_mhz = props.globals.getNode("instrumentation/comm[0]/frequencies/standby-mhz");
var _default_instrument_chan = props.globals.getNode("instrumentation/comm[0]/frequencies/standby-channel");

var rmpClass = {
	new: func(instance) {
		var m = {parents:[rmpClass]};
		m._title = "RMP " ~ instance;
		m._gfd = nil;
		m._canvas = nil;
		m._timer = maketimer(0.1, m, rmpClass._timerf);
		m._timerMhzUp = maketimer(0.1, m, rmpClass._mhzUp);
		m._timerMhzDn = maketimer(0.1, m, rmpClass._mhzDn);
		m._timerKhzUp = maketimer(0.1, m, rmpClass._khzUp);
		m._timerKhzDn = maketimer(0.1, m, rmpClass._khzDn);
		m._instance = instance;

		# Get nodes for this rmp
		m._prop_power = props.globals.getNode("controls/radio/rmp[" ~ (instance - 1) ~ "]/on");
		m._prop_am_active = props.globals.getNode("systems/radio/rmp[" ~ (instance - 1) ~ "]/am-active");
		m._prop_bfo_active = props.globals.getNode("systems/radio/rmp[" ~ (instance - 1) ~ "]/bfo-active");
		m._prop_hf1_stby = props.globals.getNode("systems/radio/rmp[" ~ (instance - 1) ~ "]/hf1-standby");
		m._prop_hf2_stby = props.globals.getNode("systems/radio/rmp[" ~ (instance - 1) ~ "]/hf2-standby");
		m._prop_nav = props.globals.getNode("systems/radio/rmp[" ~ (instance - 1) ~ "]/nav");
		m._prop_sel_light = props.globals.getNode("systems/radio/rmp[" ~ (instance - 1) ~ "]/sel-light");
		m._prop_sel_chan = props.globals.getNode("systems/radio/rmp[" ~ (instance - 1) ~ "]/sel_chan");
		m._prop_vhf1_stby = props.globals.getNode("systems/radio/rmp[" ~ (instance - 1) ~ "]/vhf1-standby");
		m._prop_vhf2_stby = props.globals.getNode("systems/radio/rmp[" ~ (instance - 1) ~ "]/vhf2-standby");
		m._prop_vhf3_stby = props.globals.getNode("systems/radio/rmp[" ~ (instance - 1) ~ "]/vhf3-standby");

		m._prop_display_active = props.globals.getNode("/controls/radio/rmp[" ~ (instance - 1) ~ "]/active-display");
		m._prop_display_standby = props.globals.getNode("/controls/radio/rmp[" ~ (instance - 1) ~ "]/standby-display");

		# Power source depending on RMP number
		if (instance == 1) {
			m._prop_power_source = systems.ELEC.Bus.dcEss;
		} else if (instance == 2) {
			m._prop_power_source = systems.ELEC.Bus.dc2;
		} else {
			m._prop_power_source = systems.ELEC.Bus.dc1;
		}
		return m;
	},
	close: func() {
		me._timer.stop();
		me._timerMhzUp.stop();
		me._timerMhzDn.stop();
		me._timerKhzUp.stop();
		me._timerKhzDn.stop();

		me._gfd.del();
		me._gfd = nil;
	},
	openDialog: func() {
		me._gfd = canvas.Window.new([320,196], "dialog");
		me._gfd._onClose = func() {rmpDialog._onClose();}

		me._gfd.set("title", me._title);
		me._canvas  = me._gfd.createCanvas();
		me._root = me._canvas.createGroup();

		me._svg = me._root.createChild("group");
		canvas.parsesvg(me._svg, "Aircraft/A320-family/gui/dialogs/rmp.svg");
	
		me._Transfer = me._svg.getElementById("Transfer-hb");
		me._VHF1 = me._svg.getElementById("VHF1-hb");
		me._VHF2 = me._svg.getElementById("VHF2-hb");
		me._VHF3 = me._svg.getElementById("VHF3-hb");
		me._HF1 = me._svg.getElementById("HF1-hb");
		me._HF2 = me._svg.getElementById("HF2-hb");
		me._AM = me._svg.getElementById("AM-hb");
		me._NAV = me._svg.getElementById("NAV-hb");
		me._VOR = me._svg.getElementById("VOR-hb");
		me._LS = me._svg.getElementById("LS-hb");
		me._ADF = me._svg.getElementById("ADF-hb");
		me._BFO = me._svg.getElementById("BFO-hb");

		# Indicators
		me._VHF1_ind = me._svg.getElementById("VHF1-ind");
		me._VHF2_ind = me._svg.getElementById("VHF2-ind");
		me._VHF3_ind = me._svg.getElementById("VHF3-ind");
		me._HF1_ind = me._svg.getElementById("HF1-ind");
		me._HF2_ind = me._svg.getElementById("HF2-ind");
		me._AM_ind = me._svg.getElementById("AM-ind");
		me._NAV_ind = me._svg.getElementById("NAV-ind");
		me._VOR_ind = me._svg.getElementById("VOR-ind");
		me._LS_ind = me._svg.getElementById("LS-ind");
		me._ADF_ind = me._svg.getElementById("ADF-ind");
		me._BFO_ind = me._svg.getElementById("BFO-ind");

		me._Active = me._svg.getElementById("Active-freq");
		me._STBY = me._svg.getElementById("STBY-freq");
		me._Sel = me._svg.getElementById("Sel");
		me._Sel_lt = me._svg.getElementById("Sel-lt");

		me._Power_off_hb = me._svg.getElementById("Power-off-hb");
		me._Power_on_hb = me._svg.getElementById("Power-on-hb");
		me._Power_off = me._svg.getElementById("Power-off");
		me._Power_on = me._svg.getElementById("Power-on");

		me._Inc_mhz = me._svg.getElementById("Inc-mhz");
		me._Dec_mhz = me._svg.getElementById("Dec-mhz");
		me._Inc_khz = me._svg.getElementById("Inc-khz");
		me._Dec_khz = me._svg.getElementById("Dec-khz");

		me._Power_on_hb.addEventListener("click", func() {
			me._Power_on.show();
			me._Power_off.hide();
			me._prop_power.setValue(1);
		});

		me._Power_off_hb.addEventListener("click", func() {
			me._Power_on.hide();
			me._Power_off.show();
			me._prop_power.setValue(0);
		});

		me._Transfer.addEventListener("click", func() {
			if (me._prop_power_source.getValue() >= 25 and me._prop_power.getValue() == 1)
			{
				rmp.transfer(me._instance);
			}
		});

		me._VHF1.addEventListener("click", func() {
			if (me._prop_power_source.getValue() >= 25 and me._prop_power.getValue() == 1)
			{
				me._prop_sel_chan.setValue("vhf1");
			}
		});

		me._VHF2.addEventListener("click", func() {
			if (me._prop_power_source.getValue() >= 25 and me._prop_power.getValue() == 1)
			{
				me._prop_sel_chan.setValue("vhf2");
			}
		});

		me._VHF3.addEventListener("click", func() {
			if (me._prop_power_source.getValue() >= 25 and me._prop_power.getValue() == 1)
			{
				me._prop_sel_chan.setValue("vhf3");
			}
		});

		me._Inc_mhz.addEventListener("mousedown", func() {
			me._timerMhzUp.start();
		});

		me._Dec_mhz.addEventListener("mousedown", func() {
			me._timerMhzDn.start();
		});

		me._Inc_khz.addEventListener("mousedown", func() {
			me._timerKhzUp.start();
		});

		me._Dec_khz.addEventListener("mousedown", func() {
			me._timerKhzDn.start();
		});

		me._Inc_khz.addEventListener("mouseup", func() {
			me._timerKhzUp.stop();
		});

		me._Dec_khz.addEventListener("mouseup", func() {
			me._timerKhzDn.stop();
		});

		me._Inc_mhz.addEventListener("mouseup", func() {
			me._timerMhzUp.stop();
		});

		me._Dec_mhz.addEventListener("mouseup", func() {
			me._timerMhzDn.stop();
		});

		me._timerf();
		me._timer.start();
	},
	_timerf: func() {
		var pwr_switch = me._prop_power.getValue();

		if (pwr_switch == 1) {
			me._Power_on.show();
			me._Power_off.hide();
		} else {
			me._Power_on.hide();
			me._Power_off.show();
		}

		if (pwr_switch == 1 and me._prop_power_source.getValue() >= 25) {
			me._Active.show();
			me._STBY.show();

			me._Active.setText(me._prop_display_active.getValue());
			me._STBY.setText(me._prop_display_standby.getValue());

			if (me._prop_sel_light.getValue() == 1) {
				me._Sel.setColor(1, 0.675, 0.325);
				me._Sel_lt.setColor(1, 0.675, 0.325);
				me._Sel_lt.setColorFill(1, 0.675, 0.325);
			} else {
				me._Sel.setColor(0.204, 0.176, 0.141);
				me._Sel_lt.setColor(0.204, 0.176, 0.141);
				me._Sel_lt.setColorFill(0.204, 0.176, 0.141);
			}

			var chan_sel = me._prop_sel_chan.getValue();

			if (chan_sel == "vhf1") {
				me._VHF1_ind.setColorFill(0, 0.635, 0.165);
			} else {
				me._VHF1_ind.setColorFill(0.125, 0.125, 0.125);
			}

			if (chan_sel == "vhf2") {
				me._VHF2_ind.setColorFill(0, 0.635, 0.165);
			} else {
				me._VHF2_ind.setColorFill(0.125, 0.125, 0.125);
			}

			if (chan_sel == "vhf3") {
				me._VHF3_ind.setColorFill(0, 0.635, 0.165);
			} else {
				me._VHF3_ind.setColorFill(0.125, 0.125, 0.125);
			}
		} else {
			me._Active.hide();
			me._STBY.hide();
			me._Sel.setColor(0.204, 0.176, 0.141);
			me._Sel_lt.setColor(0.204, 0.176, 0.141);
			me._Sel_lt.setColorFill(0.204, 0.176, 0.141);
			me._VHF1_ind.setColorFill(0.125, 0.125, 0.125);
			me._VHF2_ind.setColorFill(0.125, 0.125, 0.125);
			me._VHF3_ind.setColorFill(0.125, 0.125, 0.125);
			me._HF1_ind.setColorFill(0.125, 0.125, 0.125);
			me._HF2_ind.setColorFill(0.125, 0.125, 0.125);
			me._AM_ind.setColorFill(0.125, 0.125, 0.125);
			me._NAV_ind.setColorFill(0.125, 0.125, 0.125);
			me._VOR_ind.setColorFill(0.125, 0.125, 0.125);
			me._LS_ind.setColorFill(0.125, 0.125, 0.125);
			me._ADF_ind.setColorFill(0.125, 0.125, 0.125);
			me._BFO_ind.setColorFill(0.125, 0.125, 0.125);
		}
	},
	_mhzUp: func() {
		if (me._prop_power_source.getValue() >= 25 and me._prop_power.getValue() == 1) {
			var chan_sel = me._prop_sel_chan.getValue();
			if (chan_sel == "vhf1") {
				var freq = me._prop_vhf1_stby.getValue();
				if (freq >= 136) {
					freq = freq - 18;
				} else {
					freq = freq + 1;
				}
				me._prop_vhf1_stby.setValue(freq);
			} else if (chan_sel == "vhf2") {
				var freq = me._prop_vhf2_stby.getValue();
				if (freq >= 136) {
					freq = freq - 18;
				} else {
					freq = freq + 1;
				}
				me._prop_vhf2_stby.setValue(freq);
			} else if (chan_sel == "vhf3") {
				var freq = me._prop_vhf3_stby.getValue();
				if (freq >= 136) {
					freq = freq - 18;
				} else {
					freq = freq + 1;
				}
				me._prop_vhf3_stby.setValue(freq);
			}
		}
	},
	_mhzDn: func() {
		if (me._prop_power_source.getValue() >= 25 and me._prop_power.getValue() == 1) {
			var chan_sel = me._prop_sel_chan.getValue();
			if (chan_sel == "vhf1") {
				var freq = me._prop_vhf1_stby.getValue();
				if (freq < 119) {
					freq = freq + 18;
				} else {
					freq = freq - 1;
				}
				me._prop_vhf1_stby.setValue(freq);
			} else if (chan_sel == "vhf2") {
				var freq = me._prop_vhf2_stby.getValue();
				if (freq < 119) {
					freq = freq + 18;
				} else {
					freq = freq - 1;
				}
				me._prop_vhf2_stby.setValue(freq);
			} else if (chan_sel == "vhf3") {
				var freq = me._prop_vhf3_stby.getValue();
				if (freq < 119) {
					freq = freq + 18;
				} else {
					freq = freq - 1;
				}
				me._prop_vhf3_stby.setValue(freq);
			}
		}
	},
	# We use a little hack to get 8.33KHz spacing working:
 	#    First we assign our current STBY freq we want to adjust to the default instrument.
 	#    Then we change the channel there.
 	#    Finally we assign the value back to out own prop.
	_khzUp: func() {
		if (me._prop_power_source.getValue() >= 25 and me._prop_power.getValue() == 1) {
			var chan_sel = me._prop_sel_chan.getValue();
			if (chan_sel == "vhf1") {
				_default_instrument_mhz.setValue(me._prop_vhf1_stby.getValue());
				var chan = _default_instrument_chan.getValue();
				chan = chan + 1;
				_default_instrument_chan.setValue(chan);
				me._prop_vhf1_stby.setValue(_default_instrument_mhz.getValue());
			} else if (chan_sel == "vhf2") {
				_default_instrument_mhz.setValue(me._prop_vhf2_stby.getValue());
				var chan = _default_instrument_chan.getValue();
				chan = chan + 1;
				_default_instrument_chan.setValue(chan);
				me._prop_vhf2_stby.setValue(_default_instrument_mhz.getValue());
			} else if (chan_sel == "vhf3") {
				_default_instrument_mhz.setValue(me._prop_vhf3_stby.getValue());
				var chan = _default_instrument_chan.getValue();
				chan = chan + 1;
				_default_instrument_chan.setValue(chan);
				me._prop_vhf3_stby.setValue(_default_instrument_mhz.getValue());
			}
		}
	},
	_khzDn: func() {
		if (me._prop_power_source.getValue() >= 25 and me._prop_power.getValue() == 1) {
			var chan_sel = me._prop_sel_chan.getValue();
			if (chan_sel == "vhf1") {
				_default_instrument_mhz.setValue(me._prop_vhf1_stby.getValue());
				var chan = _default_instrument_chan.getValue();
				chan = chan - 1;
				_default_instrument_chan.setValue(chan);
				me._prop_vhf1_stby.setValue(_default_instrument_mhz.getValue());
			} else if (chan_sel == "vhf2") {
				_default_instrument_mhz.setValue(me._prop_vhf2_stby.getValue());
				var chan = _default_instrument_chan.getValue();
				chan = chan - 1;
				_default_instrument_chan.setValue(chan);
				me._prop_vhf2_stby.setValue(_default_instrument_mhz.getValue());
			} else if (chan_sel == "vhf3") {
				_default_instrument_mhz.setValue(me._prop_vhf3_stby.getValue());
				var chan = _default_instrument_chan.getValue();
				chan = chan - 1;
				_default_instrument_chan.setValue(chan);
				me._prop_vhf3_stby.setValue(_default_instrument_mhz.getValue());
			}
		}
	},
	_onClose: func() {
		me.close();
	},
};

var rmp1Dialog = rmpClass.new(1);
var rmp2Dialog = rmpClass.new(2);
var rmp3Dialog = rmpClass.new(3);
