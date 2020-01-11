var latRev = {
	title: [nil, nil, nil],
	subtitle: [nil, nil],
	fontMatrix: [[0, 0, 0, 0, 0, 0],[0, 0, 0, 0, 0, 0]],
	arrowsMatrix: [[0, 0, 0, 0, 0, 0],[0, 0, 0, 0, 0, 0]],
	arrowsColour: [["ack", "ack", "ack", "ack", "ack", "ack"],["ack", "ack", "ack", "ack", "ack", "ack"]],
	L1: [nil, nil, "ack"], # content, title, colour
	L2: [nil, nil, "ack"],
	L3: [nil, nil, "ack"],
	L4: [nil, nil, "ack"],
	L5: [nil, nil, "ack"],
	L6: [nil, nil, "ack"],
	R1: [nil, nil, "ack"],
	R2: [nil, nil, "ack"],
	R3: [nil, nil, "ack"],
	R4: [nil, nil, "ack"],
	R5: [nil, nil, "ack"],
	R6: [nil, nil, "ack"],
	depAirport: nil,
	arrAirport: nil,
	index: nil,
	computer: nil,
	new: func(type, id, index, computer) {
		var lr = {parents:[latRev]};
		lr.type = type; # 0 = origin 1 = destination 2 = ppos (from waypoint) 3 = generic wpt, 4 = discon
		lr.id = id;
		lr.index = index;
		lr.computer = computer;
		lr._setupPageWithData();
		lr._checkTmpy();
		return lr;
	},
	del: func() {
		return nil;
	},
	_checkTmpy: func() {
		if (fmgc.flightPlanController.temporaryFlag[me.computer]) {
			me.L6 = [" F-PLN", " TMPY", "yel"];
			me.arrowsColour[0][5] = "yel";
			me.R2[2] = "yel";
			me.R3[2] = "yel";
			me.R4[2] = "yel";
			canvas_mcdu.pageSwitch[me.computer].setBoolValue(0);
		}
	},
	_setupPageWithData: func() {
		if (me.type == 2) { 
			me.title = ["LAT REV", " FROM ", "PPOS"];
			me.L2 = [" OFFSET", nil, "wht"];
			me.L3 = [" HOLD", nil, "wht"];
			me.L6 = [" RETURN", nil, "wht"];
			me.R1 = ["FIX INFO ", nil, "wht"];
			me.R2 = ["[      ]°/[    ]°/[  ]", "LL XING/INCR/NO", "blu"];
			me.arrowsMatrix = [[0, 1, 1, 0, 0, 1], [1, 0, 0, 0, 0, 0]];
			me.arrowsColour = [["ack", "wht", "wht", "ack", "ack", "wht"], ["wht", "ack", "ack", "ack", "ack", "ack"]];
			me.fontMatrix = [[0, 0, 0, 0, 0, 0], [0, 1, 0, 0, 0, 0]];
		} elsif (me.type == 4) { 
			me.title = ["LAT REV", " FROM ", "DISCON"];
			me.R3 = ["[        ]", "NEXT WPT  ", "blu"];
			me.R4 = ["[     ]", "NEW DEST", "blu"];
			me.L6 = [" RETURN", nil, "wht"];
			me.arrowsMatrix = [[0, 0, 0, 0, 0, 1], [0, 0, 0, 0, 0, 0]];
			me.arrowsColour = [["ack", "ack", "ack", "ack", "ack", "wht"], ["ack", "ack", "ack", "ack", "ack", "ack"]];
			me.fontMatrix = [[0, 0, 0, 0, 0, 0], [0, 0, 1, 1, 0, 0]];
		} else {
			me.title = ["LAT REV", " FROM ", me.id];
			
			if (me.type == 0) {	
				if (size(me.id) > 4) {
					me.depAirport = findAirportsByICAO(left(me.id, 4));
				} else {
					me.depAirport = findAirportsByICAO(me.id);
				}
				me.subtitle = [dmsToString(sprintf(me.depAirport[0].lat), "lat"), dmsToString(sprintf(me.depAirport[0].lon), "lon")];
				me.L1 = [" DEPARTURE", nil, "wht"];
				me.L2 = [" OFFSET", nil, "wht"];
				me.L6 = [" RETURN", nil, "wht"];
				me.R1 = ["FIX INFO ", nil, "wht"];
				me.R2 = ["[      ]°/[    ]°/[  ]", "LL XING/INCR/NO", "blu"];
				me.R3 = ["[        ]", "NEXT WPT  ", "blu"];
				me.R4 = ["[     ]", "NEW DEST", "blu"];
				me.arrowsMatrix = [[1, 1, 0, 0, 0, 1], [1, 0, 0, 0, 0, 0]];
				me.arrowsColour = [["wht", "wht", "ack", "ack", "ack", "wht"], ["wht", "ack", "ack", "ack", "ack", "ack"]];
				me.fontMatrix = [[0, 0, 0, 0, 0, 0], [0, 1, 1, 1, 0, 0]];
			} elsif (me.type == 1) {
				if (size(me.id) > 4) {
					me.arrAirport = findAirportsByICAO(left(me.id, 4));
				} else {
					me.arrAirport = findAirportsByICAO(me.id);
				}
				me.subtitle = [dmsToString(sprintf(me.arrAirport[0].lat), "lat"), dmsToString(sprintf(me.arrAirport[0].lon), "lon")];
				me.L3 = [" ALTN", nil, "wht"];
				me.L4 = [" ALTN", " ENABLE", "blu"];
				me.L6 = [" RETURN", nil, "wht"];
				me.R1 = ["ARRIVAL ", nil, "wht"];
				me.R3 = ["[        ]", "NEXT WPT  ", "blu"];
				me.arrowsMatrix = [[0, 0, 1, 1, 0, 1], [1, 0, 0, 0, 0, 0]];
				me.arrowsColour = [["ack", "ack", "wht", "blu", "ack", "wht"], ["wht", "ack", "ack", "ack", "ack", "ack"]];
				me.fontMatrix = [[0, 0, 0, 0, 0, 0], [0, 0, 1, 0, 0, 0]];
			} elsif (me.type == 3) {
				if (size(me.id) == 2 or size(me.id) == 3) {
					me.wpt = findNavaidsByID(me.id);
				} elsif (size(me.id) == 4) {
					me.wpt = findAirportsByICAO(me.id);
				} elsif (size(me.id) == 5) {
					me.wpt = findFixesByID(me.id);
				}
				me.subtitle = [dmsToString(sprintf(me.wpt[0].lat), "lat"), dmsToString(sprintf(me.wpt[0].lon), "lon")];
				me.L3 = [" HOLD", nil, "wht"];
				me.L4 = [" ALTN", " ENABLE", "blu"];
				me.L6 = [" RETURN", nil, "wht"];
				me.R1 = ["FIX INFO ", nil, "wht"];
				me.R3 = ["[        ]", "NEXT WPT  ", "blu"];
				me.R4 = ["[     ]", "NEW DEST", "blu"];
				me.R5 = ["AIRWAYS ", nil, "wht"];
				me.arrowsMatrix = [[0, 0, 1, 1, 0, 1], [1, 0, 0, 0, 1, 0]];
				me.arrowsColour = [["ack", "ack", "wht", "blu", "ack", "wht"], ["wht", "ack", "ack", "ack", "wht", "ack"]];
				me.fontMatrix = [[0, 0, 0, 0, 0, 0], [0, 0, 1, 1, 0, 0]];
			}
		}
	},
	makeTmpy: func() {
		if (!fmgc.flightPlanController.temporaryFlag[me.computer]) {
			fmgc.flightPlanController.createTemporaryFlightPlan(me.computer);
			me._checkTmpy();
		}
	},
	nextWpt: func() {
		me.makeTmpy();
		me.R3 = [getprop("/MCDU[" ~ me.computer ~ "]/scratchpad"), "NEXT WPT   ", "yel"];
		me.fontMatrix[1][2] = 0;
		
		# check if it is part of the active f-pln, if so delete intermediate wpts, if not create discontinuiity after it with original wpts
		if (size(me.R3[0]) == 5) {
			var fix = findFixesByID(me.R3[0]);
			if (size(fix) >= 1) {
				var indexWp = fmgc.flightPlanController.flightplans[me.computer].indexOfWP(fix[0]);
				if (indexWp == -1) {
					var _insert = fmgc.flightPlanController.insertFix(me.R3[0], me.index + 1, me.computer);
					fmgc.flightPlanController.flightplans[me.computer].insertWP(createDiscontinuity(), me.index + 2);
					fmgc.flightPlanController.flightPlanChanged(me.computer);
				} else {
					var numTimesDelete = indexWp - me.index;
					while (numTimesDelete > 1) {
						fmgc.flightPlanController.deleteWP(me.index + 1, me.computer.mcdu, 0);
						numTimesDelete -= 1;
					}
					var _insert = 0;
				}
			} else {
				var _insert = 1;
			}
		} elsif (size(me.R3[0]) == 4) {
			var airport = findAirportsByICAO(me.R3[0]);
			if (size(airport) >= 1) {
				var indexWp = fmgc.flightPlanController.flightplans[me.computer].indexOfWP(fix[0]);
				if (indexWp == -1) {
					var _insert = fmgc.flightPlanController.insertArpt(me.R3[0], me.index + 1, me.computer);
					fmgc.flightPlanController.flightplans[me.computer].insertWP(createDiscontinuity(), me.index + 2);
					fmgc.flightPlanController.flightPlanChanged(me.computer);
				} else {
					var numTimesDelete = indexWp - me.index;
					while (numTimesDelete > 1) {
						fmgc.flightPlanController.deleteWP(me.index + 1, me.computer.mcdu, 0);
						numTimesDelete -= 1;
					}
					var _insert = 0;
				}
			} else {
				var _insert = 1;
			}
		} elsif (size(me.R3[0]) == 3 or size(me.R3[0]) == 2) {
			var navaid = findNavaidsByID(me.R3[0]);
			if (size(navaid) >= 1) {
				var indexWp = fmgc.flightPlanController.flightplans[me.computer].indexOfWP(navaid[0]);
				if (indexWp == -1) {
					var _insert = fmgc.flightPlanController.insertNavaid(me.R3[0], me.index + 1, me.computer);
					fmgc.flightPlanController.flightplans[me.computer].insertWP(createDiscontinuity(), me.index + 2);
					fmgc.flightPlanController.flightPlanChanged(me.computer);
				} else {
					var numTimesDelete = indexWp - me.index;
					while (numTimesDelete > 1) {
						fmgc.flightPlanController.deleteWP(me.index + 1, me.computer.mcdu, 0);
						numTimesDelete -= 1;
					}
					var _insert = 0;
				}
			} else {
				var _insert = 1;
			}
		} else {
			formatError(me.computer);
		}
		
		if (_insert == 1) {
			notInDataBase(me.computer);
		} elsif (_insert == 2) {
			notAllowed(me.computer);
		} else {
			setprop("/MCDU[" ~ me.computer ~ "]/scratchpad", "");
			fmgc.flightPlanController.flightPlanChanged(me.computer);
			setprop("/MCDU[" ~ me.computer ~ "]/page", "F-PLNA");
		}
	},
};

var dmsToString = func(dms, type) {
	var degrees = int(dms);
	var minutes = sprintf("%.1f",abs((dms - degrees) * 60));
	if (type == "lat") {
		var sign = degrees >= 0 ? "N" : "S";
	} else {
		var sign = degrees >= 0 ? "E" : "W";
	}
	return abs(degrees) ~ "g" ~ minutes ~ " " ~ sign;
}


var stringToDegrees = func(string, type) {
	if (type == "lat") {
		var degrees = left(string, 2);
		var minutesStr = right(string, 5);
	} else {
		var degrees = left(string, 3);
		var minutesStr = right(string, 5);
	}
	
	var minutes = left(minutesStr, 4);
	var sign = right(minutesStr, 1);
	var decimal = degrees + (minutes / 60);
	if (type == "lat") {
		if (sign == "N") {
			return decimal;
		} else {
			return -decimal;
		}
	} else {
		if (sign == "E") {
			return decimal;
		} else {
			return -decimal;
		}
	}
}