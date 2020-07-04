#
# Chrono - Clock - ET
#
var chr = aircraft.timer.new("instrumentation/chrono[0]/elapsetime-sec",1);
var clk = aircraft.timer.new("instrumentation/clock/elapsetime-sec",1);

setlistener("sim/signals/fdm-initialized", func {
	chr.stop();
	chr.reset();
	clk.stop();
	clk.reset();
	props.globals.initNode("instrumentation/clock/clock_hh_mm", 0,"STRING");
	props.globals.initNode("instrumentation/clock/indicated-string",0,"STRING");
	props.globals.initNode("instrumentation/clock/elapsed-string",0,"STRING");
	props.globals.initNode("instrumentation/clock/elapsetime-sec",0,"INT");
	props.globals.initNode("instrumentation/clock/et-selector",1,"INT");
	props.globals.initNode("instrumentation/clock/utc-selector",0,"INT");
	props.globals.initNode("instrumentation/clock/set-knob",0,"INT");
	props.globals.initNode("instrumentation/clock/et-hr",0,"INT");
	props.globals.initNode("instrumentation/clock/et-min",0,"INT");
	props.globals.initNode("instrumentation/chrono[0]/chr-et-string",0,"STRING");
	props.globals.initNode("instrumentation/chrono[0]/elapsetime-sec",0,"INT");
	props.globals.initNode("instrumentation/chrono[0]/chrono-reset",1,"INT");
	props.globals.initNode("instrumentation/chrono[0]/chr-et-min",0,"INT");
	props.globals.initNode("instrumentation/chrono[0]/chr-et-sec",0,"INT");
	props.globals.initNode("controls/flight/rudder-trim-display",0,"STRING");
	setprop("controls/flight/rudder-trim-display", sprintf("%2.1f", getprop("fdm/jsbsim/hydraulics/rudder/trim-cmd-deg")));
	start_loop.start();
});

setlistener("instrumentation/chrono[0]/chrono-reset", func(et){
	var tmp = et.getValue();
	if (tmp == 2) {
		if (getprop("instrumentation/chrono[0]/started") == 1) {
			if (getprop("instrumentation/chrono[0]/paused") == 0) {
				setprop("instrumentation/chrono[0]/elapsetime-sec", 0);
				setprop("instrumentation/chrono[0]/chrono-reset", 0);
			} else {
				chr.stop();
				chr.reset();
				setprop("instrumentation/chrono[0]/chrono-reset", 1);
				setprop("instrumentation/chrono[0]/started", 0);
				setprop("instrumentation/chrono[0]/paused", 0);
			};
		} else {
			if (getprop("instrumentation/chrono[0]/paused") == 0) {
				# No action required
			} else {
				setprop("instrumentation/chrono[0]/paused", 0);
			};
		};
	} elsif (tmp == 1) {
		if (getprop("instrumentation/chrono[0]/started") == 1) {
			if (getprop("instrumentation/chrono[0]/paused") == 0) {
				chr.stop();
				setprop("instrumentation/chrono[0]/paused", 1);
			} else {
				chr.stop();
			};
		} else {
			if (getprop("instrumentation/chrono[0]/paused") == 0) {
				chr.stop();
			} else {
				chr.stop();
				setprop("instrumentation/chrono[0]/paused", 0);
			};
		};
	} elsif (tmp == 0) {
		if (getprop("instrumentation/chrono[0]/started") == 0) {
			if (getprop("instrumentation/chrono[0]/paused") == 0) {
				chr.start();
				setprop("instrumentation/chrono[0]/started", 1);
			} else {
				chr.start();
				setprop("instrumentation/chrono[0]/paused", 0);
			};
		} else {
			if (getprop("instrumentation/chrono[0]/paused") == 0) {
				# No action required
			} else {
				chr.start();
				setprop("instrumentation/chrono[0]/paused", 0);
			};
		};
	};
},0,0);

setlistener("instrumentation/clock/et-selector", func(et){
	var tmp1 = et.getValue();
	if(tmp1 == 2){
		clk.reset();
	}elsif(tmp1==1){
		clk.stop();
	}elsif(tmp1==0){
		clk.start();
	}
},0,0);

var start_loop = maketimer(0.1, func {
	if (systems.ELEC.Bus.dcEss.getValue() < 25) { return; }
	# Annun-test
	if (getprop("controls/switches/annun-test") == 1) {
		var UTC_date = sprintf("%02d %02d %02d", "88", "88", "88");
		var UTC_date1 = sprintf("%02d", "88");
		var UTC_date2 = sprintf("%02d", "88");
		var UTC_date3 = sprintf("%02d", "88");
		var clock2_1 = "88:88";
		var clock2_2 = sprintf("%02d", 88);
		setprop("instrumentation/clock/clock_hh_mm", clock2_1);
		setprop("instrumentation/clock/indicated-seconds", clock2_2);
		setprop("instrumentation/clock/utc-date", UTC_date);
		setprop("instrumentation/clock/utc-date1", UTC_date1);
		setprop("instrumentation/clock/utc-date2", UTC_date2);
		setprop("instrumentation/clock/utc-date3", UTC_date3);
		setprop("instrumentation/chrono[0]/chr-et-string", "88 88");
		setprop("instrumentation/clock/elapsed-string", "88:88");
	} else {
		# Clock
		var UTC_date = sprintf("%02d %02d %02d", getprop("sim/time/utc/month"), getprop("sim/time/utc/day"), substr(sprintf("%2d", getprop("sim/time/utc/year")),1,2));
		setprop("instrumentation/clock/utc-date", UTC_date);
		var UTC_date1 = sprintf("%02d", getprop("sim/time/utc/month"));
		var UTC_date2 = sprintf("%02d", getprop("sim/time/utc/day"));
		var UTC_date3 = substr(sprintf("%2d", getprop("sim/time/utc/year")),2,2);
		var clock2_1 = getprop("instrumentation/clock/indicated-short-string");
		var clock2_2 = sprintf("%02d", substr(getprop("instrumentation/clock/indicated-string"),6,2));
		setprop("instrumentation/clock/clock_hh_mm", clock2_1);
		setprop("instrumentation/clock/indicated-seconds", clock2_2);
		setprop("instrumentation/clock/utc-date", UTC_date);
		setprop("instrumentation/clock/utc-date1", UTC_date1);
		setprop("instrumentation/clock/utc-date2", UTC_date2);
		setprop("instrumentation/clock/utc-date3", UTC_date3);
		if (getprop("instrumentation/clock/set-knob") == "") {
			setprop("instrumentation/clock/set-knob", 0);
		};
		if (getprop("instrumentation/clock/utc-selector") == "") {
			setprop("instrumentation/clock/utc-selector", 0);
		};
#		if (getprop("instrumentation/clock/utc-selector") == 0) {
#			# To do - GPS mode
#		};
#		if (getprop("instrumentation/clock/utc-selector") == 1) {
#			# To do - INT mode
#		};
#		if (getprop("instrumentation/clock/utc-selector") == 2) {
#			# To do - SET mode
#		};

		# Chrono
		var chr_tmp = getprop("instrumentation/chrono[0]/elapsetime-sec");
		if (chr_tmp >= 6000) {
			setprop("instrumentation/chrono[0]/elapsetime-sec", chr_tmp-6000);
		};
		var chr_min = int(chr_tmp * 0.0166666666667);
		if (chr_tmp >= 60) {
			var chr_sec = int(chr_tmp - (chr_min * 60));
		} else {
			var chr_sec = int(chr_tmp);
		};
		setprop("instrumentation/chrono[0]/chr-et-min",chr_min);
		setprop("instrumentation/chrono[0]/chr-et-sec",chr_sec);
		chr_tmp = sprintf("%02d:%02d", chr_min, chr_sec);
		setprop("instrumentation/chrono[0]/chr-et-string", chr_tmp);

		# ET clock
		var et_tmp = getprop("instrumentation/clock/elapsetime-sec");
		if (et_tmp >= 360000) {
			setprop("instrumentation/clock/elapsetime-sec", et_tmp-360000);
		};
		var et_min = int(et_tmp * 0.0166666666667);
		var et_hr  = int(et_min * 0.0166666666667);
		et_min = et_min - (et_hr * 60);
		setprop("instrumentation/clock/et-hr",et_hr);
		setprop("instrumentation/clock/et-min",et_min);
		et_tmp = sprintf("%02d:%02d", et_hr, et_min);
		setprop("instrumentation/clock/elapsed-string", et_tmp);
	};
});

setlistener("fdm/jsbsim/hydraulics/rudder/trim-cmd-deg", func() {
	if (systems.ELEC.Bus.dcEss.getValue() < 25 and systems.ELEC.Bus.dc2.getValue() < 25) { return; }
	var rudder_val = getprop("fdm/jsbsim/hydraulics/rudder/trim-cmd-deg");
	if (getprop("controls/switches/annun-test") == 1) {
		setprop("controls/flight/rudder-trim-display", "88.8");
		setprop("controls/flight/rudder-trim-letter-display", "8");
	} else {
		if (rudder_val > -0.05 and rudder_val < 0.05) {
			setprop("controls/flight/rudder-trim-display", sprintf("%2.1f", abs(rudder_val)));
			setprop("controls/flight/rudder-trim-letter-display", "");
		} else {
			if (rudder_val >= 0.05) {
				setprop("controls/flight/rudder-trim-display", sprintf("%2.1f", abs(rudder_val)));
				setprop("controls/flight/rudder-trim-letter-display", "R");
			} else {
				if (rudder_val <= -0.05) {
					setprop("controls/flight/rudder-trim-display", sprintf("%2.1f", abs(rudder_val)));
					setprop("controls/flight/rudder-trim-letter-display", "L");
				};
			};
		};
	};
},0, 0);
