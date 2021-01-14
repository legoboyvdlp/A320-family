# AOC Flight Log system
# Basic OOOI system implementation

var OOOIReport = {
	new: func(state,fob="",time="") {
		var report = {parents:[OOOIReport]};
		report.state = state;
		report.fob = (fob != "") ? fob : fmgc.FMGCInternal.fob;
		report.time = (time != "") ? time : sprintf("%02d.%02d", getprop("/sim/time/utc/hour"), getprop("/sim/time/utc/minute"));		
		report.elapsed = int(getprop("/sim/time/elapsed-sec"));
		report.gmt = getprop("/sim/time/gmt-string");
		report.date = getprop("/sim/time/utc/day");
		report.fltnum = (fmgc.FMGCInternal.flightNumSet == 1) ? fmgc.FMGCInternal.flightNum : "----";
		report.tofrom = (fmgc.FMGCInternal.toFromSet) ? fmgc.FMGCInternal.depApt ~ "-" ~ fmgc.FMGCInternal.arrApt : "----/----";
		return report;
	},
};

# Flight phase states:  RESET, BEGIN, WPUSH, OUT, OFF, ON, END

var OOOIReportPage = {
	new: func(index) {
		var page = {parents:[OOOIReportPage]};
		page.index = index;
		page.fltstate = ""; #UNDEF state RESET/BEGIN/WPUSH
		page.fltnum = (fmgc.FMGCInternal.flightNumSet == 1) ? fmgc.FMGCInternal.flightNum : "";
		page.date = getprop("/sim/time/utc/day");
		page.tofrom = (fmgc.FMGCInternal.toFromSet) ? fmgc.FMGCInternal.depApt ~ "-" ~ fmgc.FMGCInternal.arrApt : "";
		page.fltstart = 0;
		page.blkstart = 0;
		page.flttime = "--.--";
		page.blktime = "--.--";	
		return page;		
	},
};

var formatSecToHHMM = func(sec) {
	var mn = int(sec / 60);
	return sprintf("%02d.%02d",int(mn/60),math.mod(mn,60));
}

var FlightLogDatabase = {
	database: std.Vector.new(),
	pages: std.Vector.new(),
	addReport: func(report) {
		if (report.state == 0) me.pages.append( OOOIReportPage.new(me.getSize()) );
        me.database.append(report);
		var pg = me.pages.vector[me.pages.size()-1];
		pg.fltnum = report.fltnum;
		pg.tofrom = report.tofrom;
		if (report.state == 0) {
			pg.fltstate = "OUT";
			pg.blkstart = report.elapsed;			
		}
		else if (report.state == 1) {
			pg.fltstate = "OFF";
			pg.fltstart = report.elapsed;
		}
		else if (report.state == 2) {
			pg.fltstate = "ON";
			if (pg.fltstart > 0) pg.flttime = formatSecToHHMM(report.elapsed - pg.fltstart);
		}
		else if (report.state > 2) {
			pg.fltstate = "END";
			if (pg.blkstart > 0) pg.blktime = formatSecToHHMM(report.elapsed - pg.blkstart);
		}
    },
	getSize: func() {
		return me.database.size();
	},    
	getPageSize: func() {
		return me.pages.size();
	},
	clearDatabase: func() {
		me.database.clear();
		me.pages.clear();
	},
	getLogs: func() {
		var lst = [];
		foreach (var log; me.database) {
			append(lst,log);
		}
		return lst;
	},
	getPage: func(pg) {
		return (pg<=me.getPageSize()) ? me.pages.vector[pg-1] : OOOIReportPage.new(0);
	},
	getLogByPage: func(no) {
		var lst = [nil,nil,nil,nil];
		if (me.getPageSize() == 0) return lst;
		var i = (me.getPageSize()>=no) ? me.pages.vector[no-1].index : 0;
		var len = me.getSize();
		var v = 0;		
		var p = 0;
		while (i<len) {
			p = me.database.vector[i].state;
			if (v == 0 or p != 0) lst[v] = me.database.vector[i];
			else i = len;
			i+=1;
			v+=1;
		}
		return lst;
	},
};

var expectedOOOIState = 0; # OOOI states: 0 = out, 1 = OFF, 2 = ON, 3 = IN, 4 = RETURN-IN

var doorL1_pos = props.globals.getNode("/sim/model/door-positions/doorl1/position-norm", 1);
var doorR1_pos = props.globals.getNode("/sim/model/door-positions/doorr1/position-norm", 1);
var doorL4_pos = props.globals.getNode("/sim/model/door-positions/doorl4/position-norm", 1);
var doorR4_pos = props.globals.getNode("/sim/model/door-positions/doorr4/position-norm", 1);

#check for A/C state change - advice me for a better method, please :/
var waitingOOOIChange = maketimer(1, func(){  # 1sec precision

    var phase = fmgc.FMGCInternal.phase;
    var gs = pts.Velocities.groundspeed.getValue();
    var gear0 = pts.Gear.wow[0].getBoolValue();
	
	#print(sprintf("OOOI check: %d %d %.2f %s",expectedOOOIState,phase,gs,gear0));

	if (expectedOOOIState == 0) { # OUT
		if (gear0 and phase == 0) {
			if (gs>9) {  # imho - it's useful few speed tollerance, 10kts min speed on taxiways - CHECKME - better with pushback detection?
				FlightLogDatabase.addReport(OOOIReport.new(expectedOOOIState));
				expectedOOOIState = 1;
			}
		}
	} else if (expectedOOOIState == 1) { # OFF
		if (!gear0) {
			FlightLogDatabase.addReport(OOOIReport.new(expectedOOOIState));
			expectedOOOIState = 2;
		}	
		else if (gs < 1) {  # RETURN-IN ?? - rejected takeoff, A/C back to apron - CHECKME
			if (doorL1_pos.getValue()>0 or doorR1_pos.getValue()>0 or doorL4_pos.getValue()>0 or doorR4_pos.getValue()>0) {			
				FlightLogDatabase.addReport(OOOIReport.new(4)); # RETURN-IN
				expectedOOOIState = 0;
			}			
		}
	} else if (expectedOOOIState == 2) { # ON
		if (gear0 and (phase == 7 or phase == 0)) {  #done or preflight
			FlightLogDatabase.addReport(OOOIReport.new(expectedOOOIState));
			expectedOOOIState = 3;
		}
	} else if (expectedOOOIState == 3) { # IN
		if (gear0 and gs < 1) {
			if (doorL1_pos.getValue()>0 or doorR1_pos.getValue()>0 or doorL4_pos.getValue()>0 or doorR4_pos.getValue()>0) {
				FlightLogDatabase.addReport(OOOIReport.new(expectedOOOIState));
				expectedOOOIState = 0;
			}
		}
	}

});

var engine_one_chk_OOOI = setlistener("/engines/engine[0]/state", func {
	if (getprop("/engines/engine[0]/state") == 3) {
		removelistener(engine_one_chk_OOOI);
		waitingOOOIChange.start();
	}
},0,0);