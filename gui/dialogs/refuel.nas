# A320 Refeul panel
# merspieler

# Copyright (c) 2019 merspieler

# Distribute under the terms of GPLv2.

# TODO check max fuel
max_fuel = 30;

# Get nodes
valve_l_guard = props.globals.getNode("/controls/fuel/refuel/valve-l-guard", 1);
valve_c_guard = props.globals.getNode("/controls/fuel/refuel/valve-c-guard", 1);
valve_r_guard = props.globals.getNode("/controls/fuel/refuel/valve-r-guard", 1);
mode_guard = props.globals.getNode("/controls/fuel/refuel/mode-guard", 1);
valve_l = props.globals.getNode("/controls/fuel/refuel/valve-l", 1);
valve_c = props.globals.getNode("/controls/fuel/refuel/valve-c", 1);
valve_r = props.globals.getNode("/controls/fuel/refuel/valve-r", 1);
mode = props.globals.getNode("/controls/fuel/refuel/mode", 1);
power = props.globals.getNode("/controls/fuel/refuel/power", 1);
test = props.globals.getNode("/controls/fuel/refuel/test", 1);
amount = props.globals.getNode("/controls/fuel/refuel/amount", 1);
dc_hot_1 = props.globals.getNode("/systems/electrical/bus/dc-hot-1");
dc_2 = props.globals.getNode("/systems/electrical/bus/dc-2");

var refuelClass = {
	new: func() {
		var m = {parents:[refuelClass]};
		m._title = "Refuel Panel";
		m._gfd = nil;
		m._canvas = nil;
		m._timer = maketimer(1.0, m, refuelClass._timerf);
		return m;
	},
	close: func() {
		me._timer.stop();

		me._gfd.del();
		me._gfd = nil;
	},
	openDialog: func() {
		me._gfd = canvas.Window.new([500,424], "dialog");
		me._gfd._onClose = func() {refuelDialog._onClose();}

		me._gfd.set("title", me._title);
		me._canvas  = me._gfd.createCanvas();
		me._root = me._canvas.createGroup();

		me._svg = me._root.createChild("group");
		canvas.parsesvg(me._svg, "Aircraft/A320-family/gui/dialogs/refuel.svg");

		me._HI_LVL_L = me._svg.getElementById("HI-LVL-L");
		me._HI_LVL_C = me._svg.getElementById("HI-LVL-C");
		me._HI_LVL_R = me._svg.getElementById("HI-LVL-R");
		me._Valve_defuel = me._svg.getElementById("Valve-defuel");

		me._Valve_L_guard_open = me._svg.getElementById("Valve-L-guard-open");
		me._Valve_L_guard_closed = me._svg.getElementById("Valve-L-guard-closed");

		me._Valve_C_guard_open = me._svg.getElementById("Valve-C-guard-open");
		me._Valve_C_guard_closed = me._svg.getElementById("Valve-C-guard-closed");

		me._Valve_R_guard_open = me._svg.getElementById("Valve-R-guard-open");
		me._Valve_R_guard_closed = me._svg.getElementById("Valve-R-guard-closed");

		me._Mode_guard_open = me._svg.getElementById("Mode-guard-open");
		me._Mode_guard_closed = me._svg.getElementById("Mode-guard-closed");

		me._Power_on = me._svg.getElementById("Power-on");
		me._Power_norm = me._svg.getElementById("Power-norm");

		me._Power_on_hb = me._svg.getElementById("Power-on-hb");
		me._Power_norm_hb = me._svg.getElementById("Power-norm-hb");

		me._Pre_inc_hb = me._svg.getElementById("Pre-inc-hb");
		me._Pre_dec_hb = me._svg.getElementById("Pre-dec-hb");

		me._Test_hi_lvl = me._svg.getElementById("Test-hi-lvl");
		me._Test_lts = me._svg.getElementById("Test-lts");
		me._Test_off = me._svg.getElementById("Test-off");

		me._Test_hi_lvl_hb = me._svg.getElementById("Test-hi-lvl-hb");
		me._Test_lts_hb = me._svg.getElementById("Test-lts-hb");

		me._Valve_L_open = me._svg.getElementById("Valve-L-open");
		me._Valve_L_norm = me._svg.getElementById("Valve-L-norm");
		me._Valve_L_shut = me._svg.getElementById("Valve-L-shut");

		me._Valve_L_open_hb = me._svg.getElementById("Valve-L-open-hb");
		me._Valve_L_norm_hb = me._svg.getElementById("Valve-L-norm-hb");
		me._Valve_L_shut_hb = me._svg.getElementById("Valve-L-shut-hb");

		me._Valve_C_open = me._svg.getElementById("Valve-C-open");
		me._Valve_C_norm = me._svg.getElementById("Valve-C-norm");
		me._Valve_C_shut = me._svg.getElementById("Valve-C-shut");

		me._Valve_C_open_hb = me._svg.getElementById("Valve-C-open-hb");
		me._Valve_C_norm_hb = me._svg.getElementById("Valve-C-norm-hb");
		me._Valve_C_shut_hb = me._svg.getElementById("Valve-C-shut-hb");

		me._Valve_R_open = me._svg.getElementById("Valve-R-open");
		me._Valve_R_norm = me._svg.getElementById("Valve-R-norm");
		me._Valve_R_shut = me._svg.getElementById("Valve-R-shut");

		me._Valve_R_open_hb = me._svg.getElementById("Valve-R-open-hb");
		me._Valve_R_norm_hb = me._svg.getElementById("Valve-R-norm-hb");
		me._Valve_R_shut_hb = me._svg.getElementById("Valve-R-shut-hb");

		me._Mode_refuel = me._svg.getElementById("Mode-refuel");
		me._Mode_off = me._svg.getElementById("Mode-off");
		me._Mode_defuel = me._svg.getElementById("Mode-defuel");

		me._Mode_refuel_hb = me._svg.getElementById("Mode-refuel-hb");
		me._Mode_off_hb = me._svg.getElementById("Mode-off-hb");
		me._Mode_defuel_hb = me._svg.getElementById("Mode-defuel-hb");

		me._FQI_actual = me._svg.getElementById("FQI-actual");
		me._FQI_pre = me._svg.getElementById("FQI-pre");
		me._FQI_L = me._svg.getElementById("FQI-L");
		me._FQI_C = me._svg.getElementById("FQI-C");
		me._FQI_R = me._svg.getElementById("FQI-R");

		me._END_ind = me._svg.getElementById("END-ind");

		# Load current panel state
		# Guards
		if (valve_l_guard.getValue() == 1) {
			me._Valve_L_guard_open.show();
			me._Valve_L_guard_closed.hide();
		} else {
			me._Valve_L_guard_open.hide();
			me._Valve_L_guard_closed.show();
		}

		if (valve_l_guard.getValue() == 1) {
			me._Valve_C_guard_open.show();
			me._Valve_C_guard_closed.hide();
		} else {
			me._Valve_C_guard_open.hide();
			me._Valve_C_guard_closed.show();
		}

		if (valve_l_guard.getValue() == 1) {
			me._Valve_R_guard_open.show();
			me._Valve_R_guard_closed.hide();
		} else {
			me._Valve_R_guard_open.hide();
			me._Valve_R_guard_closed.show();
		}

		if (mode.getValue() == 1) {
			me._Mode_guard_open.show();
			me._Mode_guard_closed.hide();
		} else {
			me._Mode_guard_open.hide();
			me._Mode_guard_closed.show();
		}

		# Switches
		if (power.getValue() == 1) {
			me._Power_on.show();
			me._Power_norm.hide();
		} else {
			me._Power_on.hide();
			me._Power_norm.show();
		}

		if (test.getValue() == 1) {
			me._Test_hi_lvl.show();
			me._Test_off.hide();
			me._Test_lts.hide();
		} else if (test.getValue() == 0.5) {
			me._Test_hi_lvl.hide();
			me._Test_off.show();
			me._Test_lts.hide();
		} else {
			me._Test_hi_lvl.hide();
			me._Test_off.hide();
			me._Test_lts.show();
		}

		if (valve_l.getValue() == 1) {
			me._Valve_L_open.show();
			me._Valve_L_norm.hide();
			me._Valve_L_shut.hide();
		} else if (valve_l.getValue() == 0.5) {
			me._Valve_L_open.hide();
			me._Valve_L_norm.show();
			me._Valve_L_shut.hide();
		} else {
			me._Valve_L_open.hide();
			me._Valve_L_norm.hide();
			me._Valve_L_shut.show();
		}

		if (valve_c.getValue() == 1) {
			me._Valve_C_open.show();
			me._Valve_C_norm.hide();
			me._Valve_C_shut.hide();
		} else if (valve_c.getValue() == 0.5) {
			me._Valve_C_open.hide();
			me._Valve_C_norm.show();
			me._Valve_C_shut.hide();
		} else {
			me._Valve_C_open.hide();
			me._Valve_C_norm.hide();
			me._Valve_C_shut.show();
		}

		if (valve_r.getValue() == 1) {
			me._Valve_R_open.show();
			me._Valve_R_norm.hide();
			me._Valve_R_shut.hide();
		} else if (valve_r.getValue() == 0.5) {
			me._Valve_R_open.hide();
			me._Valve_R_norm.show();
			me._Valve_R_shut.hide();
		} else {
			me._Valve_R_open.hide();
			me._Valve_R_norm.hide();
			me._Valve_R_shut.show();
		}

		if (mode.getValue() == 1) {
			me._Mode_refuel.show();
			me._Mode_off.hide();
			me._Mode_defuel.hide();
		} else if (mode.getValue() == 0.5) {
			me._Mode_refuel.hide();
			me._Mode_off.show();
			me._Mode_defuel.hide();
		} else {
			me._Mode_refuel.hide();
			me._Mode_off.hide();
			me._Mode_defuel.show();
		}

		# Listeners
		# Guards
		me._Valve_L_guard_open.addEventListener("click", func() {
			me._Valve_L_guard_open.hide();
			me._Valve_L_guard_closed.show();
			valve_l_guard.setBoolValue(0);
			me._Valve_L_open.hide();
			me._Valve_L_norm.show();
			me._Valve_L_shut.hide();
			valve_l.setValue(0.5);
		});

		me._Valve_L_guard_closed.addEventListener("click", func() {
			me._Valve_L_guard_closed.hide();
			me._Valve_L_guard_open.show();
			valve_l_guard.setBoolValue(1);
		});

		me._Valve_C_guard_open.addEventListener("click", func() {
			me._Valve_C_guard_open.hide();
			me._Valve_C_guard_closed.show();
			valve_c_guard.setBoolValue(0);
			me._Valve_C_open.hide();
			me._Valve_C_norm.show();
			me._Valve_C_shut.hide();
			valve_c.setValue(0.5);
		});

		me._Valve_C_guard_closed.addEventListener("click", func() {
			me._Valve_C_guard_closed.hide();
			me._Valve_C_guard_open.show();
			valve_c_guard.setBoolValue(1);
		});

		me._Valve_R_guard_open.addEventListener("click", func() {
			me._Valve_R_guard_open.hide();
			me._Valve_R_guard_closed.show();
			valve_r_guard.setBoolValue(0);
			me._Valve_R_open.hide();
			me._Valve_R_norm.show();
			me._Valve_R_shut.hide();
			valve_r.setValue(0.5);
		});

		me._Valve_R_guard_closed.addEventListener("click", func() {
			me._Valve_R_guard_closed.hide();
			me._Valve_R_guard_open.show();
			valve_r_guard.setBoolValue(1);
		});

		me._Mode_guard_open.addEventListener("click", func() {
			me._Mode_guard_open.hide();
			me._Mode_guard_closed.show();
			mode_guard.setBoolValue(0);
			me._Mode_refuel.hide();
			me._Mode_off.show();
			me._Mode_defuel.hide();
		});

		me._Mode_guard_closed.addEventListener("click", func() {
			me._Mode_guard_closed.hide();
			me._Mode_guard_open.show();
			mode_guard.setBoolValue(1);
		});

		# Switches
		me._Valve_L_open_hb.addEventListener("click", func() {
			if (valve_l_guard.getValue() == 1) {
				me._Valve_L_open.show();
				me._Valve_L_norm.hide();
				me._Valve_L_shut.hide();
				valve_l.setValue(1);
			}
		});

		me._Valve_L_norm_hb.addEventListener("click", func() {
			if (valve_l_guard.getValue() == 1) {
				me._Valve_L_open.hide();
				me._Valve_L_norm.show();
				me._Valve_L_shut.hide();
				valve_l.setValue(0.5);
			}
		});

		me._Valve_L_shut_hb.addEventListener("click", func() {
			if (valve_l_guard.getValue() == 1) {
				me._Valve_L_open.hide();
				me._Valve_L_norm.hide();
				me._Valve_L_shut.show();
				valve_l.setValue(0);
			}
		});

		me._Valve_C_open_hb.addEventListener("click", func() {
			if (valve_c_guard.getValue() == 1) {
				me._Valve_C_open.show();
				me._Valve_C_norm.hide();
				me._Valve_C_shut.hide();
				valve_c.setValue(1);
			}
		});

		me._Valve_C_norm_hb.addEventListener("click", func() {
			if (valve_c_guard.getValue() == 1) {
				me._Valve_C_open.hide();
				me._Valve_C_norm.show();
				me._Valve_C_shut.hide();
				valve_c.setValue(0.5);
			}
		});

		me._Valve_C_shut_hb.addEventListener("click", func() {
			if (valve_c_guard.getValue() == 1) {
				me._Valve_C_open.hide();
				me._Valve_C_norm.hide();
				me._Valve_C_shut.show();
				valve_c.setValue(0);
			}
		});

		me._Valve_R_open_hb.addEventListener("click", func() {
			if (valve_r_guard.getValue() == 1) {
				me._Valve_R_open.show();
				me._Valve_R_norm.hide();
				me._Valve_R_shut.hide();
				valve_r.setValue(1);
			}
		});

		me._Valve_R_norm_hb.addEventListener("click", func() {
			if (valve_r_guard.getValue() == 1) {
				me._Valve_R_open.hide();
				me._Valve_R_norm.show();
				me._Valve_R_shut.hide();
				valve_r.setValue(0.5);
			}
		});

		me._Valve_R_shut_hb.addEventListener("click", func() {
			if (valve_r_guard.getValue() == 1) {
				me._Valve_R_open.hide();
				me._Valve_R_norm.hide();
				me._Valve_R_shut.show();
				valve_r.setValue(0);
			}
		});

		me._Mode_refuel_hb.addEventListener("click", func() {
			if (mode_guard.getValue() == 1) {
				me._Mode_refuel.show();
				me._Mode_off.hide();
				me._Mode_defuel.hide();
				mode.setValue(1);
			}
		});

		me._Mode_off_hb.addEventListener("click", func() {
			if (mode_guard.getValue() == 1) {
				me._Mode_refuel.hide();
				me._Mode_off.show();
				me._Mode_defuel.hide();
				mode.setValue(0.5);
			}
		});

		me._Mode_defuel_hb.addEventListener("click", func() {
			if (mode_guard.getValue() == 1) {
				me._Mode_refuel.hide();
				me._Mode_off.hide();
				me._Mode_defuel.show();
				mode.setValue(0);
			}
		});

		# TODO make it spring loaded
		me._Test_hi_lvl_hb.addEventListener("click", func() {
			me._Test_hi_lvl.show();
			me._Test_off.hide();
			me._Test_lts.hide();
			test.setValue(1);
		});

		# TODO make it spring loaded
		me._Test_lts_hb.addEventListener("click", func() {
			me._Test_hi_lvl.hide();
			me._Test_off.hide();
			me._Test_lts.show();
			test.setValue(0);
		});

		me._Power_on_hb.addEventListener("click", func() {
			me._Power_on.show();
			me._Power_norm.hide();
			power.setBoolValue(1);
		});

		me._Power_norm_hb.addEventListener("click", func() {
			me._Power_on.hide();
			me._Power_norm.show();
			power.setBoolValue(0);
		});

		# TODO keep decreasing when hold
		me._Pre_dec_hb.addEventListener("click", func() {
			target = amount.getValue();
			if (target > 0) {
				amount.setValue(target - 0.1);
			}
		});

		# TODO keep increasing when hold
		me._Pre_inc_hb.addEventListener("click", func() {
			target = amount.getValue();
			if (target < max_fuel) {
				amount.setValue(target + 0.1);
			}
		});




		me._timerf();
		me._timer.start();
	},
	_timerf: func() {
		# Check power
		# TODO cut off power when turned on with BATT POWER switch:
		# The electrical supply is automatically cut off:
		# ‐ After 10 min, if no refuel operation is selected, or
		# ‐ At the end of refueling.
		if (dc_hot_1.getValue() >= 25 and power.getValue() == 1 or dc_2.getValue() >= 25) {
			me._FQI_actual.show();
			me._FQI_pre.show();
			me._FQI_L.show();
			me._FQI_C.show();
			me._FQI_R.show();

			# TODO hook up fuel sensors

			me._FQI_pre.setText(sprintf("%2.1f", amount.getValue()));

			# HI LVL indicator color: #0184f6
			# DEFUEL indicator color: #ffe23f
		} else {
			me._FQI_actual.hide();
			me._FQI_pre.hide();
			me._FQI_L.hide();
			me._FQI_C.hide();
			me._FQI_R.hide();
			me._Valve_defuel.setColor(0.2353, 0.2117, 0.2117);
			me._HI_LVL_L.setColor(0.2353, 0.2117, 0.2117);
			me._HI_LVL_C.setColor(0.2353, 0.2117, 0.2117);
			me._HI_LVL_R.setColor(0.2353, 0.2117, 0.2117);
		}
	},
	_onClose: func() {
		me.close();
	},
};

var refuelDialog = refuelClass.new();
