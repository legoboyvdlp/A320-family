#
# Chrono - Clock - ET
#
var chr = aircraft.timer.new("instrumentation/chrono[0]/elapsetime-sec",1);
var clk = aircraft.timer.new("instrumentation/clock/elapsetime-sec",1);

var chr_min = nil;
var chr_sec = nil;
var chr_tmp = nil;
var clock2_1 = nil;
var clock2_2 = nil;
var day = nil;
var et_hr = nil;
var et_min = nil;
var et_tmp = nil;
var month = nil;
var rudder_val = nil;
var tmp = nil;
var tmp1 = nil;
var UTC_date = nil;
var UTC_date1 = nil;
var UTC_date2 = nil;
var UTC_date3 = nil;
var year = nil;

var et_selector = props.globals.initNode("/instrumentation/clock/et-selector", 1, "INT");
var utc_selector = props.globals.initNode("/instrumentation/clock/utc-selector",0,"INT");
var set_knob = props.globals.initNode("/instrumentation/clock/set-knob",0,"INT");

var clock = {
	elapsedHour: props.globals.initNode("/instrumentation/clock/et-hr", 0, "INT"),
	elapsedMin: props.globals.initNode("/instrumentation/clock/et-min", 0, "INT"),
	elapsedString: props.globals.initNode("/instrumentation/clock/elapsed-string", 0, "STRING"),
	elapsedSec: props.globals.initNode("/instrumentation/clock/elapsetime-sec", 0, "INT"),
	indicatedSec: props.globals.getNode("/instrumentation/clock/indicated-seconds"),
	hhMM: props.globals.initNode("/instrumentation/clock/clock_hh_mm", 0, "STRING"),
	utcDate: [props.globals.initNode("/instrumentation/clock/utc-date", "", "STRING"), props.globals.initNode("/instrumentation/clock/utc-date1", "", "STRING"),
		props.globals.initNode("/instrumentation/clock/utc-date2", "", "STRING"),props.globals.initNode("/instrumentation/clock/utc-date3", "", "STRING")],
	
};

var chrono = {
	chronoReset: props.globals.initNode("/instrumentation/chrono[0]/chrono-reset", 1, "INT"),
	elapseTime: props.globals.initNode("/instrumentation/chrono[0]/elapsetime-sec", 0, "INT"),
	etMin: props.globals.initNode("/instrumentation/chrono[0]/chr-et-min", 0, "INT"),
	etSec: props.globals.initNode("/instrumentation/chrono[0]/chr-et-sec", 0, "INT"),
	etString: props.globals.initNode("/instrumentation/chrono[0]/chr-et-string", 0, "STRING"),
	paused: props.globals.getNode("/instrumentation/chrono[0]/paused"),
	started: props.globals.getNode("/instrumentation/chrono[0]/started"),
};

var rudderTrim = {
	rudderTrimDisplay: props.globals.initNode("/controls/flight/rudder-trim-display", 0, "STRING"),
	rudderTrimDisplayLetter: props.globals.initNode("/controls/flight/rudder-trim-letter-display", "", "STRING"),
};

setlistener("sim/signals/fdm-initialized", func {
	chr.stop();
	chr.reset();
	clk.stop();
	clk.reset();
	rudderTrim.rudderTrimDisplay.setValue(sprintf("%2.1f", pts.Fdm.JSBsim.Hydraulics.Rudder.trimDeg.getValue()));
	start_loop.start();
});

setlistener("/instrumentation/chrono[0]/chrono-reset", func(et){
	tmp = et.getValue();
	if (tmp == 2) {
		if (chrono.started.getBoolValue()) {
			if (!chrono.paused.getBoolValue()) {
				chrono.elapseTime.setValue(0);
				chrono.chronoReset.setBoolValue(0);
			} else {
				chr.stop();
				chr.reset();
				chrono.chronoReset.setBoolValue(1);
				chrono.started.setBoolValue(0);
				chrono.paused.setBoolValue(0);
			};
		} else {
			if (!chrono.paused.getBoolValue()) {
				# No action required
			} else {
				chrono.paused.setBoolValue(0);
			};
		};
	} elsif (tmp == 1) {
		if (chrono.started.getBoolValue()) {
			if (!chrono.paused.getBoolValue()) {
				chr.stop();
				chrono.paused.setBoolValue(1);
			} else {
				chr.stop();
			};
		} else {
			if (!chrono.paused.getBoolValue()) {
				chr.stop();
			} else {
				chr.stop();
				chrono.paused.setBoolValue(0);
			};
		};
	} elsif (tmp == 0) {
		if (!chrono.started.getBoolValue()) {
			if (!chrono.paused.getBoolValue()) {
				chr.start();
				chrono.started.setBoolValue(1);
			} else {
				chr.start();
				chrono.paused.setBoolValue(0);
			};
		} else {
			if (!chrono.paused.getBoolValue()) {
				# No action required
			} else {
				chr.start();
				chrono.paused.setBoolValue(0);
			};
		};
	};
}, 0, 0);

setlistener("instrumentation/clock/et-selector", func(et){
	tmp1 = et.getValue();
	if (tmp1 == 2){
		clk.reset();
	} elsif (tmp1 == 1){
		clk.stop();
	} elsif (tmp1 == 0){
		clk.start();
	}
}, 0, 0);

var start_loop = maketimer(0.1, func {
	if (systems.ELEC.Bus.dcEss.getValue() < 25) { return; }
	
	# Annun-test
	if (pts.Controls.Switches.annunTest.getBoolValue()) {
		UTC_date = sprintf("%02d %02d %02d", "88", "88", "88");
		UTC_date1 = sprintf("%02d", "88");
		UTC_date2 = sprintf("%02d", "88");
		UTC_date3 = sprintf("%02d", "88");
		clock2_1 = "88:88";
		clock2_2 = sprintf("%02d", 88);
		
		clock.hhMM.setValue(clock2_1);
		clock.indicatedSec.setValue(clock2_2);
		clock.utcDate[0].setValue(UTC_date);
		clock.utcDate[1].setValue(UTC_date1);
		clock.utcDate[2].setValue(UTC_date2);
		clock.utcDate[3].setValue(UTC_date3);
		
		chrono.etString.setValue("88 88");
		clock.elapsedString.setValue("88:88");
	} else {
		day = pts.Sim.Time.UTC.day.getValue();
		month = pts.Sim.Time.UTC.month.getValue();
		year = pts.Sim.Time.UTC.year.getValue();
		
		# Clock
		UTC_date = sprintf("%02d %02d %02d", month, day, substr(sprintf("%2d", year),1,2));
		UTC_date1 = sprintf("%02d", month);
		UTC_date2 = sprintf("%02d", day);
		UTC_date3 = substr(sprintf("%2d", year),2,2);
		clock2_1 = pts.Instrumentation.Clock.indicatedStringShort.getValue();
		clock2_2 = sprintf("%02d", substr(pts.Instrumentation.Clock.indicatedString.getValue(),6,2));
		
		clock.hhMM.setValue(clock2_1);
		clock.indicatedSec.setValue(clock2_2);
		clock.utcDate[0].setValue(UTC_date);
		clock.utcDate[1].setValue(UTC_date1);
		clock.utcDate[2].setValue(UTC_date2);
		clock.utcDate[3].setValue(UTC_date3);
		
		if (set_knob.getValue() == "") {
			set_knob.setValue(0);
		}
	
		if (utc_selector.getValue() == "") {
			utc_selector.setValue(0);
		}
		
#		if (getprop("/instrumentation/clock/utc-selector") == 0) {
#			# To do - GPS mode
#		};
#		if (getprop("/instrumentation/clock/utc-selector") == 1) {
#			# To do - INT mode
#		};
#		if (getprop("/instrumentation/clock/utc-selector") == 2) {
#			# To do - SET mode
#		};

		# Chrono
		chr_tmp = chrono.elapseTime.getValue();
		if (chr_tmp >= 6000) {
			chrono.elapseTime.setValue(chr_tmp - 6000);
		}
		
		chr_min = int(chr_tmp * 0.0166666666667);
		if (chr_tmp >= 60) {
			chr_sec = int(chr_tmp - (chr_min * 60));
		} else {
			chr_sec = int(chr_tmp);
		}
		
		chrono.etMin.setValue(chr_min);
		chrono.etSec.setValue(chr_sec);
		chrono.etString.setValue(sprintf("%02d:%02d", chr_min, chr_sec));

		# ET clock
		et_tmp = clock.elapsedSec.getValue();
		if (et_tmp >= 360000) {
			clock.elapsedSec.setValue(et_tmp - 360000);
		}
		
		et_min = int(et_tmp * 0.0166666666667);
		et_hr  = int(et_min * 0.0166666666667);
		et_min = et_min - (et_hr * 60);
		
		clock.elapsedHour.setValue(et_hr);
		clock.elapsedMin.setValue(et_min);
		clock.elapsedString.setValue(sprintf("%02d:%02d", et_hr, et_min));
		
		foreach (item; update_items) {
			item.update(nil);
		}
	}
});

var updateRudderTrim = func() {
	if (pts.Controls.Switches.annunTest.getBoolValue()) {
		rudderTrim.rudderTrimDisplay.setValue(sprintf("%3.1f", "88.8"));
		rudderTrim.rudderTrimDisplayLetter.setValue(sprintf("%1.0f", "8"));
	} else {
		rudder_val = pts.Fdm.JSBsim.Hydraulics.Rudder.trimDeg.getValue();
		if (rudder_val > -0.05 and rudder_val < 0.05) {
			rudderTrim.rudderTrimDisplay.setValue(sprintf("%2.1f", abs(rudder_val)));
			rudderTrim.rudderTrimDisplayLetter.setValue("");
		} else {
			rudderTrim.rudderTrimDisplay.setValue(sprintf("%2.1f", abs(rudder_val)));
			if (rudder_val >= 0.05) {
				rudderTrim.rudderTrimDisplayLetter.setValue("R");
			} elsif (rudder_val <= -0.05) {
				rudderTrim.rudderTrimDisplayLetter.setValue("L");
			}
		}
	}
}

var update_items = [
	props.UpdateManager.FromProperty("/fdm/jsbsim/hydraulics/rudder/trim-deg", 0.05, func(notification)
		{
			updateRudderTrim();
		}
	),
];

setlistener("/controls/switches/annun-test", updateRudderTrim, 0, 0);