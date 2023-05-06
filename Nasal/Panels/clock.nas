# ﻿Chrono - Clock - ET clock

var cpt_timer = aircraft.timer.new("/instrumentation/ndchrono[0]/elapsetime-sec",1,0);
var fo_timer = aircraft.timer.new("/instrumentation/ndchrono[1]/elapsetime-sec",1,0);
var clock_timer = aircraft.timer.new("/instrumentation/clock/et/elapsetime-sec",1,0);
var clock_int_et = aircraft.timer.new("/instrumentation/clock/internal/elapsetime-sec",1,0);
var chrono_timer = aircraft.timer.new("/instrumentation/clock/chrono/elapsetime-sec",1,0);

var chr_min = nil;
var chr_sec = nil;
var chr_tmp = nil;
var et_hr = nil;
var et_min = nil;
var et_tmp = nil;
var rudder_val = nil;
var tmp = nil;
var tmp1 = nil;
var condition = nil;

var clock_et = {
	sec: props.globals.initNode("/instrumentation/clock/et/indicated-sec", 0, "STRING"),
	hrs: props.globals.initNode("/instrumentation/clock/et/indicated-hours", 0, "STRING"),
	min: props.globals.initNode("/instrumentation/clock/et/indicated-min", 0, "STRING"),
	elapsedString: props.globals.initNode("/instrumentation/clock/et/elapsed-string", "", "STRING"),
	et: props.globals.getNode("/instrumentation/clock/et/elapsetime-sec"),
	et_selector: props.globals.initNode("/instrumentation/clock/et/et-selector", 1, "INT"),
	visible: props.globals.initNode("/instrumentation/clock/et/visible", 0, "BOOL"),
};

var clock = {
	hhMM: props.globals.initNode("/instrumentation/clock/indicated-short-string", "", "STRING"),
	indicated_hh: props.globals.initNode("/instrumentation/clock/indicated-hours", "", "STRING"),
	indicated_mm: props.globals.initNode("/instrumentation/clock/indicated-minutes", "", "STRING"),
	indicated_sec: props.globals.initNode("/instrumentation/clock/indicated-seconds", "", "STRING"),
	utcDate: [props.globals.initNode("/instrumentation/clock/date", "", "STRING"), props.globals.initNode("/instrumentation/clock/date-month", "", "STRING"),
		props.globals.initNode("/instrumentation/clock/date-day", "", "STRING"), props.globals.initNode("/instrumentation/clock/date-year", "", "STRING")],
	mode_selector: props.globals.initNode("/instrumentation/clock/utc-selector", 0,"INT"),
	set_knob: props.globals.initNode("/instrumentation/clock/set-knob", 0,"INT"),
	set_knb_pos: props.globals.initNode("/instrumentation/clock/set-knb-pos", 0,"INT"),
	set_knb_count: props.globals.initNode("/instrumentation/clock/set-knb-count", 0,"INT"),
};

var clock_internal = {
	mode: props.globals.initNode("/instrumentation/clock/internal/mode", 0,"INT"),
	et: props.globals.initNode("/instrumentation/clock/internal/elapsetime-sec", 0, "DOUBLE"),
	hrs: props.globals.initNode("/instrumentation/clock/internal/hr", 0, "INT"),
	min: props.globals.initNode("/instrumentation/clock/internal/min", 0, "INT"),
	sec: props.globals.initNode("/instrumentation/clock/internal/sec", 0, "INT"),
	hhMM: props.globals.initNode("/instrumentation/clock/internal/indicated-short-string", "", "STRING"),
	bisextile_year: props.globals.initNode("/instrumentation/clock/internal/bisextile-year", 0, "BOOL"),
	date: [props.globals.initNode("/instrumentation/clock/internal/date", "", "STRING"), props.globals.initNode("/instrumentation/clock/internal/date-year", "", "STRING"),
		props.globals.initNode("/instrumentation/clock/internal/date-month", "", "STRING"), props.globals.initNode("/instrumentation/clock/internal/date-day", "", "STRING")],
	year: props.globals.initNode("/instrumentation/clock/internal/year", 0, "INT"),
	month: props.globals.initNode("/instrumentation/clock/internal/month", 0, "INT"),
	day: props.globals.initNode("/instrumentation/clock/internal/day", 0, "INT"),
	set_cont: props.globals.initNode("/instrumentation/clock/internal/set-cont", 0,"INT"),
	elapsedString: props.globals.initNode("/instrumentation/clock/internal/elapsed-string", "", "STRING"),
	indicated_hh: props.globals.initNode("/instrumentation/clock/internal/indicated-hours", 0, "STRING"),
	indicated_mm: props.globals.initNode("/instrumentation/clock/internal/indicated-minutes", 0, "STRING"),
	indicated_sec: props.globals.initNode("/instrumentation/clock/internal/indicated-seconds", 0, "STRING"),
	blink_hh: props.globals.initNode("/instrumentation/clock/internal/blink-hh", 0, "BOOL"),
	blink_mm: props.globals.initNode("/instrumentation/clock/internal/blink-mm", 0, "BOOL"),
	blink_day: props.globals.initNode("/instrumentation/clock/internal/blink-day", 0, "BOOL"),
	blink_month: props.globals.initNode("/instrumentation/clock/internal/blink-month", 0, "BOOL"),
	blink_year: props.globals.initNode("/instrumentation/clock/internal/blink-year", 0, "BOOL"),
};

var chrono = {
	reset: props.globals.initNode("/instrumentation/clock/chrono/chrono-reset", 1, "INT"),
	reset_btn: props.globals.initNode("/instrumentation/clock/chrono/chrono-reset-btn", 0, "INT"),
	btn: props.globals.initNode("/instrumentation/clock/chrono/chrono-btn", 0, "INT"),
	et: props.globals.initNode("/instrumentation/clock/chrono/elapsetime-sec", 0, "INT"),
	etMin: props.globals.initNode("/instrumentation/clock/chrono/chr-et-min", 0, "STRING"),
	etSec: props.globals.initNode("/instrumentation/clock/chrono/chr-et-sec", 0, "STRING"),
	etString: props.globals.initNode("/instrumentation/clock/chrono/chr-et-string", "", "STRING"),
	paused: props.globals.initNode("/instrumentation/clock/chrono/paused", 0, "BOOL"),
	started: props.globals.initNode("/instrumentation/clock/chrono/started", 0,"BOOL"),
};

#Cpt chrono
var cpttimer = {
	et: props.globals.initNode("/instrumentation/ndchrono[0]/elapsetime-sec", 0, "INT"),
	etHh_cpt: props.globals.initNode("/instrumentation/ndchrono[0]/etHh_cpt", 0, "INT"),
	etMin_cpt: props.globals.initNode("/instrumentation/ndchrono[0]/etMin_cpt", 0, "INT"),
	etSec_cpt:  props.globals.initNode("/instrumentation/ndchrono[0]/etSec_cpt", 0, "INT"),
	text: props.globals.initNode("/instrumentation/ndchrono[0]/text", "", "STRING"),
};

#Fo chrono
var fotimer = {
	et: props.globals.initNode("/instrumentation/ndchrono[1]/elapsetime-sec", 0, "INT"),
	etHh_fo: props.globals.initNode("/instrumentation/ndchrono[1]/etHh_fo", 0, "INT"),
	etMin_fo: props.globals.initNode("/instrumentation/ndchrono[1]/etMin_fo", 0, "INT"),
	etSec_fo:  props.globals.initNode("/instrumentation/ndchrono[1]/etSec_fo", 0, "INT"),
	text: props.globals.initNode("/instrumentation/ndchrono[1]/text", "", "STRING"),
};

#Rudder Trim Indicator
var rudderTrim = {
	rudderTrimDisplay: props.globals.initNode("/controls/flight/rudder-trim-display", "", "STRING"),
	rudderTrimDisplayLetter: props.globals.initNode("/controls/flight/rudder-trim-letter-display", "", "STRING"),
};

setlistener("/sim/signals/fdm-initialized", func {
	chrono_timer.reset();
	clock_timer.reset();
	clock_int_et.reset();
	cpt_timer.reset();
	fo_timer.reset();
	rudderTrim.rudderTrimDisplay.setValue(sprintf("%2.1f", pts.Fdm.JSBsim.Hydraulics.Rudder.trimDeg.getValue()));
	loop.start();
});

#Chrono
setlistener("/instrumentation/clock/chrono/chrono-btn", func {
	if (chrono.btn.getValue() == 1) {
		chrono.reset.setBoolValue(0);
		if (chrono.started.getBoolValue()) {
			#chrono started
			if (chrono.paused.getBoolValue()) {
				#chrono paused
				chrono_timer.start();
				chrono.paused.setBoolValue(0);
			} else {
				#chrono running
				chrono_timer.stop();
				chrono.paused.setBoolValue(1);
			}
		} else {
			#chrono not started
			chrono_timer.start();
			chrono.paused.setBoolValue(0);
			chrono.started.setBoolValue(1);
		}	
	}
}, 0, 0);

setlistener("/instrumentation/clock/chrono/chrono-reset-btn", func {
	if (chrono.reset.getValue() == 1) {
		if (chrono.started.getBoolValue()) {
			#chrono started
			if (chrono.paused.getBoolValue()) {
				#chrono paused
				chrono_timer.stop();
				chrono_timer.reset();
				chrono.started.setBoolValue(0);
				chrono.paused.setBoolValue(0);
			} else {
				#chrono running
				chrono.et.setValue(0);
			};
		} else {
			#chrono not started
			chrono_timer.stop();
			chrono_timer.reset();
			chrono.started.setBoolValue(0);
			chrono.paused.setBoolValue(0);
			chrono.reset.setBoolValue(1);
		}
	} else {
		if (chrono.started.getBoolValue()) {
			#chrono started
			if (chrono.paused.getBoolValue()) {
				#chrono paused
				chrono_timer.stop();
				chrono_timer.reset();
				chrono.started.setBoolValue(0);
				chrono.paused.setBoolValue(0);
			} else {
				#chrono running
				chrono.et.setValue(0);
			};
		} else {
			#chrono not started
			chrono_timer.stop();
			chrono_timer.reset();
			chrono.started.setBoolValue(0);
			chrono.paused.setBoolValue(0);
			chrono.reset.setBoolValue(1);
		}
	}
}, 0, 0);

#ND Chrono - CPT
setlistener("/instrumentation/efis[0]/inputs/CHRONO", func {
		chrono0 = props.globals.getValue("/instrumentation/efis[0]/inputs/CHRONO");
		if (chrono0 == 1){
			cpt_timer.start();
		} elsif (chrono0 == 2) {
			cpt_timer.stop();
		} elsif (chrono0 == 0) {
			cpt_timer.reset();
		}
}, 0, 0);

#ND Chrono - FO
setlistener("/instrumentation/efis[1]/inputs/CHRONO", func {
		chrono1 = props.globals.getValue("/instrumentation/efis[1]/inputs/CHRONO");
		if (chrono1 == 1){
			fo_timer.start();
		} elsif (chrono1 == 2) {
			fo_timer.stop();
		} elsif (chrono1 == 0) {
			fo_timer.reset();
		}
}, 0, 0);

#ET Clock
setlistener("/instrumentation/clock/et/et-selector", func {
	tmp1 = clock_et.et_selector.getValue();
	if (tmp1 == 2){
		clock_timer.reset();
		clock_et.visible.setValue(0);
		attivo=0
	} elsif (tmp1 == 1){
		clock_timer.stop();
	} elsif (tmp1 == 0){
		clock_timer.start();
		clock_et.visible.setValue(1);
	}
}, 0, 0);

#Clock
setlistener("/instrumentation/clock/utc-selector", func {
	if (clock.mode_selector.getValue() != 2) {
		clock_internal.set_cont.setValue(1);
		clock.set_knb_count.setValue(0);
	}
	if (clock.mode_selector.getValue() == 0){
		#GPS Clock
		clock_internal.mode.setValue(0);
		clock_int_et.reset();
		clock_int_et.stop();
	}
	if (clock.mode_selector.getValue() == 2) {
		# INT Clock - SET Mode
		clock_internal.mode.setValue(1);
	}
	if (clock.mode_selector.getValue() == 1) {
		# INT Clock - INT mode");
		clock_int_et.reset();
		if (clock_internal.mode.getValue() == 0) {
			#Start INT Clock from GPS mode
			clock_internal.year.setValue(props.globals.getValue("sim/time/utc/year"));
			clock_internal.month.setValue(props.globals.getValue("sim/time/utc/month"));
			clock_internal.day.setValue(props.globals.getValue("sim/time/utc/day"));
			clock_internal.hrs.setValue(props.globals.getValue("sim/time/utc/hour"));
			clock_internal.min.setValue(props.globals.getValue("sim/time/utc/minute"));
			clock_internal.sec.setValue(props.globals.getValue("sim/time/utc/second"));
			clock_internal.et.setValue(props.globals.getValue("sim/time/utc/day-seconds"));
		} else {
			#Start INT Clock from SET mode
			clock_internal.et.setValue((clock_internal.hrs.getValue() * 3600) + (clock_internal.min.getValue() * 60));
		}
		clock_int_et.start();
	}
}, 0, 0);

setlistener("/instrumentation/clock/set-knob", func {
	if (clock.set_knob.getValue() == 1) {
		if (clock.mode_selector.getValue() == 2) {
			#Clock SET mode
			#set custom UTC time
			if (clock_internal.set_cont.getValue() == 0) {
				clock_internal.set_cont.setValue(1);
			}
			if (clock_internal.set_cont.getValue() < 5) {
				clock_internal.set_cont.setValue(clock_internal.set_cont.getValue() + 1);
			} else {
				clock_internal.set_cont.setValue(clock_internal.set_cont.getValue() - 4);
			}
		}
		if (clock_internal.set_cont.getValue() == 1) {
			#clock set minutes
			clock.set_knb_count.setValue(0);
		} elsif (clock_internal.set_cont.getValue() == 2) {
			#clock set hours
			clock.set_knb_count.setValue(0);
		} elsif (clock_internal.set_cont.getValue() == 3) {
			#clock set year
			clock.set_knb_count.setValue(0);
		} elsif (clock_internal.set_cont.getValue() == 4) {
			#clock set month
			clock.set_knb_count.setValue(0);
		} elsif (clock_internal.set_cont.getValue() == 5) {
			#clock set day
			clock.set_knb_count.setValue(0);
		} else {
			print('clock custom date/time setting error')
		}
	}
}, 0, 0);

var loop = maketimer(0.1, func (){
	if (systems.ELEC.Bus.dcEss.getValue() < 25) { return; }
	if (pts.Controls.Switches.annunTest.getBoolValue()) {
		# Annun-test
		#date
		clock.utcDate[0].setValue(sprintf("%02d %02d %02d", "88", "88", "88"));
		#month
		clock.utcDate[1].setValue(sprintf("%02d", "88"));
		#day
		clock.utcDate[2].setValue(sprintf("%02d", "88"));
		#year
		clock.utcDate[3].setValue(sprintf("%02d", "88"));

		#Clock
		clock.indicated_hh.setValue(sprintf("%02d", "88"));
		clock.indicated_mm.setValue(sprintf("%02d", "88"));
		#clock.hhMM.setValue("88:88");
		clock.indicated_sec.setValue(sprintf("%02d", "88"));

		#Chrono
		chrono.etString.setValue("88:88");

		#ET Clock
		clock_et.elapsedString.setValue("88:88");

	} else {
		#Normal mode (Annun-test off)
		#Date
		clock.utcDate[0].setValue(sprintf("%02d %02d %02d", pts.Sim.Time.Utc.month.getValue(), pts.Sim.Time.Utc.day.getValue(), substr(sprintf("%2d", pts.Sim.Time.Utc.year.getValue()),2,2)));
		clock.utcDate[1].setValue(sprintf("%02d", pts.Sim.Time.Utc.month.getValue()));
		clock.utcDate[2].setValue(sprintf("%02d", pts.Sim.Time.Utc.day.getValue()));
		clock.utcDate[3].setValue(substr(sprintf("%02d", pts.Sim.Time.Utc.year.getValue()),2,2));

		#Clock
		clock.indicated_hh.setValue(sprintf("%02d", substr(pts.Instrumentation.Clock.indicatedString.getValue(),0,2)));
		clock.indicated_mm.setValue(sprintf("%02d", substr(pts.Instrumentation.Clock.indicatedString.getValue(),3,2)));
		clock.indicated_sec.setValue(sprintf("%02d", substr(pts.Instrumentation.Clock.indicatedString.getValue(),6,2)));

#		#Clock Internal
		if (math.fmod(clock_internal.year.getValue(), 4) == 0 or math.fmod(clock_internal.year.getValue(), 400) == 0) {
			clock_internal.bisextile_year.setValue(1);
		} else {
			clock_internal.bisextile_year.setValue(0);
		}

		clock_internal_tmp = clock_internal.et.getValue();

		if (clock_internal_tmp >= 86400) {
			clock_internal.et.setValue(clock_internal_tmp - 86400);
			#Aggiungi un giorno
			if (clock_internal.month.getValue() == 12) {
				if (clock_internal.day.getValue() == 31) {
					#Aggiungi Anno
					clock_internal.year.setValue(clock_internal.year.getValue() + 1);
					clock_internal.month.setValue(1);
					clock_internal.day.setValue(1);
				} else {
					clock_internal.day.setValue(clock_internal.day.getValue() + 1);
				}
			} else {
				if ((clock_internal.month.getValue() == 4) or (clock_internal.month.getValue() == 6) or (clock_internal.month.getValue() == 9) or (clock_internal.month.getValue() == 11)) {
					if (clock_internal.day.getValue() == 30) {
						clock_internal.month.setValue(clock_internal.month.getValue() + 1);
						clock_internal.day.setValue(1);
					} else {
						clock_internal.day.setValue(clock_internal.day.getValue() + 1);
					}
				} else {
					if (clock_internal.month.getValue() == 2) {
						if (math.fmod(clock_internal.year.getValue(), 4) == 0 or math.fmod(clock_internal.year.getValue(), 400) == 0) {
							if (clock_internal.day.getValue() == 29) {
								clock_internal.day.setValue(1);
								clock_internal.month.setValue(3);
							} else {
								if (clock_internal.day.getValue() == 28) {
									clock_internal.day.setValue(1);
									clock_internal.month.setValue(3);
								}
								clock_internal.day.setValue(clock_internal.day.getValue() + 1);
							}
						} else {
							clock_internal.day.setValue(clock_internal.day.getValue() + 1);
						}
					} else {
						if (clock_internal.day.getValue() == 31) {
							clock_internal.month.setValue(clock_internal.month.getValue() + 1);
							clock_internal.day.setValue(1);
						} else {
							clock_internal.day.setValue(clock_internal.day.getValue() + 1);
						}
					}
				}
			}
		} else {
			if (clock.mode_selector.getValue() == 1){
				clock_internal.hrs.setValue(int(clock_internal.et.getValue() * 0.000277777777778));
				clock_internal.min.setValue((clock_internal.et.getValue() - (clock_internal.hrs.getValue() * 3600)) * 0.0166666666667 );
				clock_internal.sec.setValue(clock_internal.et.getValue() - ((clock_internal.hrs.getValue() * 3600) + (clock_internal.min.getValue() * 60)));
			} elsif (clock.mode_selector.getValue() == 2) {
				#nothing to do
			}
		}


		#Clock internal SET Mode
		clock_internal.hhMM.setValue(sprintf("%02d", clock_internal.hrs.getValue()) ~ ":" ~ sprintf("%02d", clock_internal.min.getValue()));
		clock_internal.indicated_hh.setValue(sprintf("%02d", clock_internal.hrs.getValue()));
		clock_internal.indicated_mm.setValue(sprintf("%02d", clock_internal.min.getValue()));
		clock_internal.indicated_sec.setValue(sprintf("%02d", clock_internal.sec.getValue()));
		clock_internal.date[0].setValue(sprintf("%02d", clock_internal.month.getValue()) ~ " " ~ sprintf("%02d",clock_internal.day.getValue()) ~ " " ~ substr(sprintf("%02d",clock_internal.year.getValue()),2,2));
		clock_internal.date[1].setValue(substr(sprintf("%02d",clock_internal.year.getValue()),2,2));
		clock_internal.date[2].setValue(sprintf("%02d",clock_internal.month.getValue()));
		clock_internal.date[3].setValue(sprintf("%02d",clock_internal.day.getValue()));

		condition = (getprop("/sim/time/elapsed-sec") - math.floor(getprop("/sim/time/elapsed-sec"))) < 0.5;

		if (clock.set_knob.getValue() == 0) {
			if (clock.mode_selector.getValue() == 0) {
				#show Time
				clock_internal.blink_hh.setValue(1);
				clock_internal.blink_mm.setValue(1);
				clock_internal.blink_day.setValue(1);
				clock_internal.blink_month.setValue(1);
				clock_internal.blink_year.setValue(1);
			} elsif (clock.mode_selector.getValue() == 1) {
				#show Time
				clock_internal.blink_hh.setValue(1);
				clock_internal.blink_mm.setValue(1);
				clock_internal.blink_day.setValue(1);
				clock_internal.blink_month.setValue(1);
				clock_internal.blink_year.setValue(1);
			} else {
				if (clock_internal.set_cont.getValue() == 1) {
					#clock internal SET minutes
					if (condition) {
						clock_internal.hhMM.setValue(sprintf("%02d", clock_internal.hrs.getValue()) ~ ":" ~ sprintf("%02d", clock_internal.min.getValue()));
						clock_internal.blink_hh.setValue(1);
						clock_internal.blink_mm.setValue(1);
						clock_internal.blink_day.setValue(1);
						clock_internal.blink_month.setValue(1);
						clock_internal.blink_year.setValue(1);
					} else {
						clock_internal.hhMM.setValue(sprintf("%02d", clock_internal.hrs.getValue()) ~ ":" ~ "   ");
						clock_internal.blink_hh.setValue(1);
						clock_internal.blink_mm.setValue(0);
						clock_internal.blink_day.setValue(1);
						clock_internal.blink_month.setValue(1);
						clock_internal.blink_year.setValue(1);
					}
				} elsif (clock_internal.set_cont.getValue() == 2) {
					#clock internal SET hours
					if (condition) {
						clock_internal.hhMM.setValue(sprintf("%02d", clock_internal.hrs.getValue()) ~ ":" ~ sprintf("%02d", clock_internal.min.getValue()));
						clock_internal.blink_hh.setValue(1);
						clock_internal.blink_mm.setValue(1);
						clock_internal.blink_day.setValue(1);
						clock_internal.blink_month.setValue(1);
						clock_internal.blink_year.setValue(1);
					} else {
						clock_internal.hhMM.setValue("   " ~ ":" ~ sprintf("%02d", clock_internal.min.getValue()));
						clock_internal.blink_hh.setValue(0);
						clock_internal.blink_mm.setValue(1);
						clock_internal.blink_day.setValue(1);
						clock_internal.blink_month.setValue(1);
						clock_internal.blink_year.setValue(1);
					}
				} elsif (clock_internal.set_cont.getValue() == 3) {
					#clock internal SET year
					if (condition) {
						clock_internal.blink_hh.setValue(1);
						clock_internal.blink_mm.setValue(1);
						clock_internal.blink_day.setValue(1);
						clock_internal.blink_month.setValue(1);
						clock_internal.blink_year.setValue(1);
					} else {
						clock_internal.blink_hh.setValue(1);
						clock_internal.blink_mm.setValue(1);
						clock_internal.blink_day.setValue(1);
						clock_internal.blink_month.setValue(1);
						clock_internal.blink_year.setValue(0);
					}
				} elsif (clock_internal.set_cont.getValue() == 4) {
					#clock internal SET month
					if (condition) {
						clock_internal.blink_hh.setValue(1);
						clock_internal.blink_mm.setValue(1);
						clock_internal.blink_day.setValue(1);
						clock_internal.blink_month.setValue(1);
						clock_internal.blink_year.setValue(1);
					} else {
						clock_internal.blink_hh.setValue(1);
						clock_internal.blink_mm.setValue(1);
						clock_internal.blink_day.setValue(1);
						clock_internal.blink_month.setValue(0);
						clock_internal.blink_year.setValue(1);
					}
				} elsif (clock_internal.set_cont.getValue() == 5) {
					#clock internal SET day
					if (condition) {
						clock_internal.blink_hh.setValue(1);
						clock_internal.blink_mm.setValue(1);
						clock_internal.blink_day.setValue(1);
						clock_internal.blink_month.setValue(1);
						clock_internal.blink_year.setValue(1);
					} else {
						clock_internal.blink_hh.setValue(1);
						clock_internal.blink_mm.setValue(1);
						clock_internal.blink_day.setValue(0);
						clock_internal.blink_month.setValue(1);
						clock_internal.blink_year.setValue(1);
					}
				}
			}
		} else {
			if (clock.mode_selector.getValue() == 0) {
				#show Date
				clock_internal.blink_hh.setValue(1);
				clock_internal.blink_mm.setValue(1);
				clock_internal.blink_day.setValue(1);
				clock_internal.blink_month.setValue(1);
				clock_internal.blink_year.setValue(1);
			} elsif (clock.mode_selector.getValue() == 1) {
				#show Date
				clock_internal.blink_hh.setValue(1);
				clock_internal.blink_mm.setValue(1);
				clock_internal.blink_day.setValue(1);
				clock_internal.blink_month.setValue(1);
				clock_internal.blink_year.setValue(1);
			} else {
				if (clock_internal.set_cont.getValue() == 1) {
					#clock internal SET minutes
					if (condition) {
						clock_internal.blink_hh.setValue(1);
						clock_internal.blink_mm.setValue(1);
						clock_internal.blink_day.setValue(1);
						clock_internal.blink_month.setValue(1);
						clock_internal.blink_year.setValue(1);
					} else {
						clock_internal.blink_hh.setValue(1);
						clock_internal.blink_mm.setValue(0);
						clock_internal.blink_day.setValue(1);
						clock_internal.blink_month.setValue(1);
						clock_internal.blink_year.setValue(1);
					}
				} elsif (clock_internal.set_cont.getValue() == 2) {
					#clock internal SET hours
					if (condition) {
						clock_internal.blink_hh.setValue(1);
						clock_internal.blink_mm.setValue(1);
						clock_internal.blink_day.setValue(1);
						clock_internal.blink_month.setValue(1);
						clock_internal.blink_year.setValue(1);
					} else {
						clock_internal.blink_hh.setValue(0);
						clock_internal.blink_mm.setValue(1);
						clock_internal.blink_day.setValue(1);
						clock_internal.blink_month.setValue(1);
						clock_internal.blink_year.setValue(1);
					}
				} elsif (clock_internal.set_cont.getValue() == 3) {
					#clock internal SET year
					if (condition) {
						clock_internal.blink_hh.setValue(1);
						clock_internal.blink_mm.setValue(1);
						clock_internal.blink_day.setValue(1);
						clock_internal.blink_month.setValue(1);
						clock_internal.blink_year.setValue(1);
					} else {
						clock_internal.blink_hh.setValue(1);
						clock_internal.blink_mm.setValue(1);
						clock_internal.blink_day.setValue(1);
						clock_internal.blink_month.setValue(1);
						clock_internal.blink_year.setValue(0);
					}
				} elsif (clock_internal.set_cont.getValue() == 4) {
					#clock internal SET month
					if (condition) {
						clock_internal.blink_hh.setValue(1);
						clock_internal.blink_mm.setValue(1);
						clock_internal.blink_day.setValue(1);
						clock_internal.blink_month.setValue(1);
						clock_internal.blink_year.setValue(1);
					} else {
						clock_internal.blink_hh.setValue(1);
						clock_internal.blink_mm.setValue(1);
						clock_internal.blink_day.setValue(1);
						clock_internal.blink_month.setValue(0);
						clock_internal.blink_year.setValue(1);
					}
				} elsif (clock_internal.set_cont.getValue() == 5) {
					#clock internal SET day
					if (condition) {
						clock_internal.blink_hh.setValue(1);
						clock_internal.blink_mm.setValue(1);
						clock_internal.blink_day.setValue(1);
						clock_internal.blink_month.setValue(1);
						clock_internal.blink_year.setValue(1);
					} else {
						clock_internal.blink_hh.setValue(1);
						clock_internal.blink_mm.setValue(1);
						clock_internal.blink_day.setValue(0);
						clock_internal.blink_month.setValue(1);
						clock_internal.blink_year.setValue(1);
					}
				}
			}
		}

		if (clock.set_knob.getValue() == "") {
			clock.set_knob.setValue(0);
		}

		#Chrono
		chr_tmp = chrono.et.getValue();
		if (chr_tmp >= 6000) {
			chrono.et.setValue(chr_tmp - 6000);
		}
		chr_min = int(chr_tmp * 0.0166666666667);
		if (chr_tmp >= 60) {
			chr_sec = int(chr_tmp - (chr_min * 60));
		} else {
			chr_sec = int(chr_tmp);
		}
		chrono.etMin.setValue(sprintf("%02d", chr_min));
		chrono.etSec.setValue(sprintf("%02d", chr_sec));
		if (chrono.paused.getBoolValue()) {
			chrono.etString.setValue(sprintf("%02d %02d", chr_min, chr_sec));
		} else {
			chrono.etString.setValue(sprintf("%02d:%02d", chr_min, chr_sec));
		}

		#ET clock
		et_tmp = clock_et.et.getValue();
		if (et_tmp >= 360000) {
			clock_et.et.setValue(et_tmp - 360000);
		}

		et_min = int(et_tmp * 0.0166666666667);
		et_hr  = int(et_min * 0.0166666666667);
		et_min = et_min - (et_hr * 60);

		clock_et.hrs.setValue(sprintf("%02d", et_hr));
		clock_et.min.setValue(sprintf("%02d",et_min));
		if (clock_et.et_selector.getValue()==1) {
			if (clock_et.et.getValue()==0) {
				clock_et.elapsedString.setValue("");
			} else {
				clock_et.elapsedString.setValue(sprintf("%02d %02d", et_hr, et_min));
			}
		} else {
			clock_et.elapsedString.setValue(sprintf("%02d:%02d", et_hr, et_min));
		}

		#Rudder Trim update loop
		foreach (item; update_items) {
			item.update(nil);
		}

	}
	
	#Cpt Chrono
	chr0_tmp = cpttimer.et.getValue();
	if (chr0_tmp >= 360000) {
		cpttimer.et.setValue(chr0_tmp - 360000);
	}

	chr0_hh = int(chr0_tmp * 0.000277777777778);
	chr0_min = int((chr0_tmp * 0.0166666666667) - (chr0_hh * 60));
	chr0_sec = int(chr0_tmp - (chr0_min * 60) - (chr0_hh * 3600));
	cpttimer.etHh_cpt.setValue(chr0_hh);
	cpttimer.etMin_cpt.setValue(chr0_min);
	cpttimer.etSec_cpt.setValue(chr0_sec);
	if (chr0_tmp >= 3600) {
		cpttimer.text.setValue(sprintf("%2d H %2d'", chr0_hh, chr0_min));
	} else {
		cpttimer.text.setValue(sprintf("%2d' %2d''", chr0_min, chr0_sec));
	}

	#Fo Chrono
	chr1_tmp = fotimer.et.getValue();
	if (chr1_tmp >= 360000) {
		fotimer.et.setValue(chr1_tmp - 360000);
	}

	chr1_hh = int(chr1_tmp * 0.000277777777778);
	chr1_min = int(chr1_tmp * 0.0166666666667);
	chr1_sec = int(chr1_tmp - (chr1_min * 60) - (chr1_hh * 3600));
	fotimer.etHh_fo.setValue(chr1_hh);
	fotimer.etMin_fo.setValue(chr1_min);
	fotimer.etSec_fo.setValue(chr1_sec);
	if (chr1_tmp >= 3600) {
		fotimer.text.setValue(sprintf("%2d H %2d'", chr1_hh, chr1_min));
	} else {
		fotimer.text.setValue(sprintf("%2d' %2d''", chr1_min, chr1_sec));
	}

});

var updateRudderTrim = func() {
	if (pts.Controls.Switches.annunTest.getBoolValue()) {
		rudderTrim.rudderTrimDisplay.setValue(sprintf("%2.1f", "88.8"));
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
