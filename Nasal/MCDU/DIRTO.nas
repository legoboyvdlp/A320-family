var dirToFlag = 0;

var dirTo = {
	title: [nil],
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
	scroll: 0,
	vector: [],
	index: nil,
	computer: nil,
	new: func(computer) {
		var dt = {parents:[dirTo]};
		dt.computer = computer;
		dt._setupPageWithData();
		return dt;
	},
	del: func() {
		return nil;
	},
	_setupPageWithData: func() {
		me.title = ["DIR TO"];
		me.titleColour = "wht";
		me.L1 = [" [       ]", " WAYPOINT", "blu"];
		me.L2 = [nil, " F-PLN WPTS", "blu"];
		me.L3 = [nil, nil, "blu"];
		me.L4 = [nil, nil, "blu"];
		me.L5 = [nil, nil, "blu"];
		me.R1 = ["----   ---  ", "UTC   DIST  ", "wht"];
		me.R2 = ["DIRECT TO ", nil, "blu"];
		me.R3 = ["ABEAM PTS ", "WITH        ", "blu"];
		me.R4 = ["[   ]  ", "RADIAL IN   ", "blu"];
		me.R5 = ["[   ]  ", "RADIAL OUT  ", "blu"];
		me.arrowsMatrix = [[0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0]];
		me.arrowsColour = [["ack", "blu", "blu", "blu", "blu", "ack"], ["ack", "blu", "blu", "ack", "ack", "ack"]];
		me.fontMatrix = [[1, 0, 0, 0, 0, 0], [0, 0, 0, 1, 1, 0]];
		me.updateFromFpln();
		me.updateTmpy();
		canvas_mcdu.pageSwitch[me.computer].setBoolValue(0);
	},
	makeTmpy: func() {
		if (!fmgc.flightPlanController.temporaryFlag[me.computer]) {
			fmgc.flightPlanController.createTemporaryFlightPlan(me.computer);
		}
		dirToFlag = 1;
	},
	insertDirTo: func() {
		dirToFlag = 0;
	},
	updateTmpy: func() {
		if (fmgc.flightPlanController.temporaryFlag[me.computer]) {
			me.L1[2] = "yel";
			me.R2[2] = "yel";
			me.arrowsMatrix[1][2] = 1;
			me.titleColour = "yel";
		} else {
			me.L1[2] = "blu";
			me.R2[2] = "blu";
			me.arrowsMatrix[1][2] = 0;
			me.titleColour = "wht";
		}
		canvas_mcdu.pageSwitch[me.computer].setBoolValue(0);
	},
	updateFromFpln: func() {
		if (canvas_mcdu.myFpln[me.computer] == nil) {
			 canvas_mcdu.myFpln[me.computer] = fplnPage.new(2, me.computer);
		}
		
		var x = 0;
		me.vector = [];
		for (var i = 1 + (me.scroll); i < size(canvas_mcdu.myFpln[me.computer].planList) - 2; i = i + 1) {
			if (canvas_mcdu.myFpln[me.computer].planList[i].wp.wp_name == "DISCONTINUITY" or canvas_mcdu.myFpln[me.computer].planList[i].wp.wp_name == "VECTORS" or canvas_mcdu.myFpln[me.computer].planList[i].wp.wp_name == "T-P" or canvas_mcdu.myFpln[me.computer].planList[i].wp.wp_type == "hdgToAlt") { continue; } # can't ever have tmpy with dir to
			if (canvas_mcdu.myFpln[me.computer].planList[i].index > fmgc.flightPlanController.arrivalIndex[2]) {
				continue; 
			}
			append(me.vector, canvas_mcdu.myFpln[me.computer].planList[i].wp);
			x += 1;
			if (x == 4) { break; }
		}
		
		if (size(me.vector) > 0) {
			me.L2[0] = " " ~ me.vector[0].wp_name;
			me.arrowsMatrix[0][1] = 1;
		} else {
			me.L2[0] = nil;
			me.arrowsMatrix[0][1] = 0;
		}
		if (size(me.vector) > 1) {
			me.L3[0] = " " ~ me.vector[1].wp_name;
			me.arrowsMatrix[0][2] = 1;
		} else {
			me.L3[0] = nil;
			me.arrowsMatrix[0][2] = 0;
		}
		if (size(me.vector) > 2) {
			me.L4[0] = " " ~ me.vector[2].wp_name;
			me.arrowsMatrix[0][3] = 1;
		} else {
			me.L4[0] = nil;
			me.arrowsMatrix[0][3] = 0;
		}
		if (size(me.vector) > 3) {
			me.L5[0] = " " ~ me.vector[3].wp_name;
			me.arrowsMatrix[0][4] = 1;
		} else {
			me.L5[0] = nil;
			me.arrowsMatrix[0][4] = 0;
		}
		me.updateTmpy();
	},
	scrollUp: func() {
		if (size(canvas_mcdu.myFpln[me.computer].planList) > 4) {
			me.scroll += 1;
			if (me.scroll > size(canvas_mcdu.myFpln[me.computer].planList) - 6) {
				me.scroll = 0;
			}
		} else {
			me.scroll = 0;
		}
		me.updateFromFpln();
		canvas_mcdu.pageSwitch[me.computer].setBoolValue(0);
	},
	scrollDn: func() {
		if (size(canvas_mcdu.myFpln[me.computer].planList) > 4) {
			me.scroll -= 1;
			if (me.scroll < 0) {
				me.scroll = size(canvas_mcdu.myFpln[me.computer].planList) - 6;
			}
		} else {
			me.scroll = 0;
		}
		me.updateFromFpln();
		canvas_mcdu.pageSwitch[me.computer].setBoolValue(0);
	},
	fieldL1: func(text, override = 0, overrideIndex = -1) {
		me.makeTmpy();
		me.L1[0] = text;
		me.fontMatrix = [[0, 0, 0, 0, 0, 0], [0, 0, 0, 1, 1, 0]];
		if (size(text) == 16) {
			# lat lon
			var lat = split("/", text)[0];
			var lon = split("/", text)[1];
			var latDecimal = mcdu.stringToDegrees(lat, "lat");
			var lonDecimal = mcdu.stringToDegrees(lon, "lon");
			
			if (latDecimal > 90 or latDecimal < -90 or lonDecimal > 180 or lonDecimal < -180) {
				mcdu_message(me.computer, "NOT ALLOWED");
			}
			
			var myWpLatLon = createWP(latDecimal, lonDecimal, "LL" ~ 01);
			fmgc.flightPlanController.directTo(myWpLatLon, me.computer);
			
		} elsif (size(text) == 5) {
			# fix
			var fix = findFixesByID(text);
			if (size(fix) == 0) {
				mcdu_message(me.computer, "NOT IN DATA BASE");
			}
			
			if (size(fix) == 1 or override) {
				if (!override) {
					fmgc.flightPlanController.directTo(fix[0], me.computer);
				} else {
					fmgc.flightPlanController.directTo(fix[overrideIndex], me.computer);
				}
			} elsif (size(fix) >= 1) {
				if (canvas_mcdu.myDuplicate[me.computer] != nil) {
					canvas_mcdu.myDuplicate[me.computer].del();
				}
				canvas_mcdu.myDuplicate[me.computer] = nil;
				canvas_mcdu.myDuplicate[me.computer] = mcdu.duplicateNamesPage.new(fix, 0, 0, me.computer);
				setprop("MCDU[" ~ me.computer ~ "]/page", "DUPLICATENAMES");
			}
			
		} elsif (size(text) == 4) {
			# airport
			var airport =  findAirportsByICAO(text);
			if (size(airport) == 0) {
				mcdu_message(me.computer, "NOT IN DATA BASE");
			}
			
			if (size(airport) == 1 or override) {
				if (!override) {
					fmgc.flightPlanController.directTo(airport[0], me.computer);
				} else {
					fmgc.flightPlanController.directTo(airport[overrideIndex], me.computer);
				}
			} elsif (size(airport) >= 1) {
				if (canvas_mcdu.myDuplicate[me.computer] != nil) {
					canvas_mcdu.myDuplicate[me.computer].del();
				}
				canvas_mcdu.myDuplicate[me.computer] = nil;
				canvas_mcdu.myDuplicate[me.computer] = mcdu.duplicateNamesPage.new(airport, 0, 0, me.computer);
				setprop("MCDU[" ~ me.computer ~ "]/page", "DUPLICATENAMES");
			}
			
		} elsif (size(text) == 3 or size(text) == 2) {
			# navaid
			var navaid =  findNavaidsByID(text);
			if (size(navaid) == 0) {
				mcdu_message(me.computer, "NOT IN DATA BASE");
			}
			
			if (size(navaid) == 1 or override) {
				if (!override) {
					fmgc.flightPlanController.directTo(navaid[0], me.computer);
				} else {
					fmgc.flightPlanController.directTo(navaid[overrideIndex], me.computer);
				}
			} elsif (size(navaid) >= 1) {
				if (canvas_mcdu.myDuplicate[me.computer] != nil) {
					canvas_mcdu.myDuplicate[me.computer].del();
				}
				canvas_mcdu.myDuplicate[me.computer] = nil;
				canvas_mcdu.myDuplicate[me.computer] = mcdu.duplicateNamesPage.new(navaid, 0, 0, me.computer);
				setprop("MCDU[" ~ me.computer ~ "]/page", "DUPLICATENAMES");
			}
			
		} else {
			mcdu_message(me.computer, "NOT ALLOWED");
		}
		mcdu_scratchpad.scratchpads[me.computer].empty();
	},
	leftFieldBtn: func(index) {
		me.makeTmpy();
		me.L1[0] = me.vector[index - 2].wp_name;
		me.fontMatrix = [[0, 0, 0, 0, 0, 0], [0, 0, 0, 1, 1, 0]];
		fmgc.flightPlanController.directTo(me.vector[index - 2], me.computer);
		me.arrowsMatrix[0][1] = 0;
		# FIGURE OUT HOW TO MAKE IT SO IT DOESN'T DELETE THE WAYPOINTS ON DIR TO BUT DOES IN FLIGHTPLAN
		#for (var i = 2; i != 6; i = i + 1) {
		#	if (i == index) {
		#		me.arrowsMatrix[0][i - 1] = 0;
		#	} else {
		#		me.arrowsMatrix[0][i - 1] = 1;
		#	}
		#}
	},
	fieldL6: func() {
		if (fmgc.flightPlanController.temporaryFlag[me.computer] and dirToFlag) {
			dirToFlag = 0;
			fmgc.flightPlanController.destroyTemporaryFlightPlan(me.computer, 0);
			me.L1 = [" [       ]", " WAYPOINT", "blu"];
			me.fontMatrix = [[1, 0, 0, 0, 0, 0], [0, 0, 0, 1, 1, 0]];
			me.R1 = ["----   ---  ", "UTC   DIST  ", "wht"];
		} else {
			mcdu_message(me.computer, "NOT ALLOWED");
		}
	},
	fieldR6: func() {
		if (fmgc.flightPlanController.temporaryFlag[me.computer] and dirToFlag) {
			dirToFlag = 0;
			fmgc.flightPlanController.destroyTemporaryFlightPlan(me.computer, 1);
			me.L1 = [" [       ]", " WAYPOINT", "blu"];
			me.fontMatrix = [[1, 0, 0, 0, 0, 0], [0, 0, 0, 1, 1, 0]];
			me.R1 = ["----   ---  ", "UTC   DIST  ", "wht"];
			setprop("MCDU[" ~ me.computer ~ "]/page", "F-PLNA"); # todo - remember horizontal srcoll of f-plna?
		} else {
			mcdu_message(me.computer, "NOT ALLOWED");
		}
	},
	updateDist: func(dist) {
		me.R1 = ["----   " ~ sprintf("%.0f", dist) ~ "  ", "UTC   DIST  ", "wht"];
	},
};