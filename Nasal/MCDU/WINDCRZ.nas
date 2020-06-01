# A3XX mCDU by Joshua Davidson (Octal450), Jonathan Redpath, and Matthew Maring (mattmaring)

# Copyright (c) 2020 Matthew Maring (mattmaring)

var windCRZPage = {
	title: [nil, nil, nil],
	fontMatrix: [[0, 0, 0, 0, 0, 0],[0, 0, 0, 0, 0, 0]],
	arrowsMatrix: [[0, 0, 0, 0, 0, 0],[0, 0, 0, 0, 0, 0]],
	arrowsColour: [["ack", "ack", "ack", "ack", "ack", "ack"],["ack", "ack", "ack", "ack", "ack", "ack"]],
	L1: [nil, nil, "ack"], # content, title, colour
	L2: [nil, nil, "ack"],
	L3: [nil, nil, "ack"],
	L4: [nil, nil, "ack"],
	L5: [nil, nil, "ack"],
	L6: [nil, nil, "ack"],
	C1: [nil, nil, "ack"],
	C2: [nil, nil, "ack"],
	C3: [nil, nil, "ack"],
	C4: [nil, nil, "ack"],
	C5: [nil, nil, "ack"],
	C6: [nil, nil, "ack"],
	R1: [nil, nil, "ack"],
	R2: [nil, nil, "ack"],
	R3: [nil, nil, "ack"],
	R4: [nil, nil, "ack"],
	R5: [nil, nil, "ack"],
	R6: [nil, nil, "ack"],
	scroll: 0,
	vector: [],
	#index: nil,
	computer: nil,
	cur_location: 0,
	match_location: 0,
	windList: [nil],
	singleCRZ: 0,
	new: func(computer, waypoint, cur_location) {
		var wcp = {parents:[windCRZPage]};
		wcp.computer = computer;
		wcp.windList = [nil];
		wcp.waypoint = waypoint;
		wcp.cur_location = cur_location;
		if (waypoint == nil) {
			wcp.singleCRZ = 1;
		}
		wcp.match_location = fmgc.flightPlanController.getWaypointMapping(2)[wcp.cur_location];
		wcp._setupPageWithData();
		wcp.updateTmpy();
		return wcp;
	},
	del: func() {
		return nil;
	},
	_setupPageWithData: func() {
		if (me.singleCRZ == 1) {
			me.title = ["","CRZ WIND",""];
		} else {
			me.title = ["CRZ WIND", " AT ", me.waypoint.wp_name];
		}
		me.titleColour = "wht";
		me.arrowsMatrix = [[0, 0, 0, 0, 0, 1], [0, 0, 0, 1, 1, 0]];
		me.arrowsColour = [["ack", "ack", "ack", "ack", "ack", "wht"], ["ack", "ack", "ack", "wht", "wht", "ack"]];
		me.fontMatrix = [[1, 1, 1, 1, 1, 0], [0, 0, 0, 0, 0, 0]];
		
		# load wind list
		if (me.singleCRZ == 0) {
			if (fmgc.flightPlanController.temporaryFlag[me.computer]) {
				#get from 0
				me.windList = [nil];
				if (fmgc.wpWindAltitude0[me.computer][me.match_location].getValue() != "") {
					me.windList[0] = [fmgc.wpWindDirection0[me.computer][me.match_location].getValue(), fmgc.wpWindMagnitude0[me.computer][me.match_location].getValue(), fmgc.wpWindAltitude0[me.computer][me.match_location].getValue()];
					append(me.windList, nil);
				}
				if (fmgc.wpWindAltitude1[me.computer][me.match_location].getValue() != "") {
					me.windList[1] = [fmgc.wpWindDirection1[me.computer][me.match_location].getValue(), fmgc.wpWindMagnitude1[me.computer][me.match_location].getValue(), fmgc.wpWindAltitude1[me.computer][me.match_location].getValue()];
					append(me.windList, nil);
				}
				if (fmgc.wpWindAltitude2[me.computer][me.match_location].getValue() != "") {
					me.windList[2] = [fmgc.wpWindDirection2[me.computer][me.match_location].getValue(), fmgc.wpWindMagnitude2[me.computer][me.match_location].getValue(), fmgc.wpWindAltitude2[me.computer][me.match_location].getValue()];
					append(me.windList, nil);
				}
				if (fmgc.wpWindAltitude3[me.computer][me.match_location].getValue() != "") {
					me.windList[3] = [fmgc.wpWindDirection3[me.computer][me.match_location].getValue(), fmgc.wpWindMagnitude3[me.computer][me.match_location].getValue(), fmgc.wpWindAltitude3[me.computer][me.match_location].getValue()];
				}
			} else {
				#get from 2
				me.windList = [nil];
				if (fmgc.wpWindAltitude0[2][me.match_location].getValue() != "") {
					me.windList[0] = [fmgc.wpWindDirection0[2][me.match_location].getValue(), fmgc.wpWindMagnitude0[2][me.match_location].getValue(), fmgc.wpWindAltitude0[2][me.match_location].getValue()];
					append(me.windList, nil);
				}
				if (fmgc.wpWindAltitude1[2][me.match_location].getValue() != "") {
					me.windList[1] = [fmgc.wpWindDirection1[2][me.match_location].getValue(), fmgc.wpWindMagnitude1[2][me.match_location].getValue(), fmgc.wpWindAltitude1[2][me.match_location].getValue()];
					append(me.windList, nil);
				}
				if (fmgc.wpWindAltitude2[2][me.match_location].getValue() != "") {
					me.windList[2] = [fmgc.wpWindDirection2[2][me.match_location].getValue(), fmgc.wpWindMagnitude2[2][me.match_location].getValue(), fmgc.wpWindAltitude2[2][me.match_location].getValue()];
					append(me.windList, nil);
				}
				if (fmgc.wpWindAltitude3[2][me.match_location].getValue() != "") {
					me.windList[3] = [fmgc.wpWindDirection3[2][me.match_location].getValue(), fmgc.wpWindMagnitude3[2][me.match_location].getValue(), fmgc.wpWindAltitude3[2][me.match_location].getValue()];
				}
			}
		}
		
		# load data
		if (size(me.windList) >= 4) {
			if (me.windList[3] != nil) {
				me.L4 = [sprintf("%03d", me.windList[3][0]) ~ "/" ~ sprintf("%03d", me.windList[3][1]) ~ "/" ~ me.windList[3][2], nil, "blu"];
				me.fontMatrix[0][3] = 0;
			} else {
				me.L4 = ["[  ]/[  ]/[   ]", nil, "blu"];
				me.fontMatrix[0][3] = 1;
			}
		} else {
			me.L4 = [nil, nil, "ack"];
		}
		
		if (size(me.windList) >= 3) {
			if (me.windList[2] != nil) {
				me.L3 = ["%03d", me.windList[2][0]) ~ "/" ~ sprintf("%03d", me.windList[2][1]) ~ "/" ~ me.windList[2][2], nil, "blu"];
				me.fontMatrix[0][2] = 0;
			} else {
				me.L3 = ["[  ]/[  ]/[   ]", nil, "blu"];
				me.fontMatrix[0][2] = 1;
			}
		} else {
			me.L3 = [nil, nil, "ack"];
		}
		
		if (size(me.windList) >= 2) {
			if (me.windList[1] != nil) {
				me.L2 = ["%03d", me.windList[1][0]) ~ "/" ~ sprintf("%03d", me.windList[1][1]) ~ "/" ~ me.windList[1][2], nil, "blu"];
				me.fontMatrix[0][1] = 0;
			} else {
				me.L2 = ["[  ]/[  ]/[   ]", nil, "blu"];
				me.fontMatrix[0][1] = 1;
			}
		} else {
			me.L2 = [nil, nil, "ack"];
		}
		
		if (size(me.windList) >= 1) {
			if (me.windList[0] != nil) {
				me.L1 = ["%03d", me.windList[0][0]) ~ "/" ~ sprintf("%03d", me.windList[0][1]) ~ "/" ~ me.windList[0][2], "TRU WIND/ALT", "blu"];
				me.fontMatrix[0][0] = 0;
			} else {
				me.L1 = ["[  ]/[  ]/[   ]", "TRU WIND/ALT", "blu"];
				me.fontMatrix[0][0] = 1;
			}
		}
		
		me.L5 = ["[  ]/[   ]", "SAT / ALT", "blu"];
		me.R2 = [" REQUEST ", "WIND ", "amb"];
		me.R4 = [" PHASE ", "PREV ", "wht"];
		me.R5 = [" PHASE ", "NEXT ", "wht"];

		canvas_mcdu.pageSwitch[me.computer].setBoolValue(0);
	},
	makeTmpy: func() {
		if (!fmgc.flightPlanController.temporaryFlag[me.computer]) {
			fmgc.flightPlanController.createTemporaryFlightPlan(me.computer);
		}
	},
	updateTmpy: func() {
		if (fmgc.flightPlanController.temporaryFlag[me.computer]) {
			me.L1[2] = "yel";
			me.L2[2] = "yel";
			me.L3[2] = "yel";
			me.L4[2] = "yel";
			me.L5[2] = "yel";
			me.L6 = [" CANCEL", "UPDATE", "amb"];
			me.R6 = ["INSERT ", "UPDATE ", "amb"];
			me.arrowsMatrix[0][5] = 0;
			#draft title
			canvas_mcdu.pageSwitch[me.computer].setBoolValue(0);
		} else {
			me.L1[2] = "blu";
			me.L2[2] = "blu";
			me.L3[2] = "blu";
			me.L4[2] = "blu";
			me.L5[2] = "blu";
			me.L6 = [" RETURN", nil, "wht"];
			me.R6 = [nil, nil, "ack"];
			me.arrowsMatrix[0][5] = 1;
			#draft title
			canvas_mcdu.pageSwitch[me.computer].setBoolValue(0);
		}
	},
	reload: func() {
		me._setupPageWithData();
		me.updateTmpy();
	},
	pushButtonLeft: func(index) {
		#destroyTemporaryFlightPlan
		if (size(me.windList) >= index) {
			if (size(mcdu_scratchpad.scratchpads[me.computer].scratchpad) == 13) {
				var winds = split("/", mcdu_scratchpad.scratchpads[me.computer].scratchpad);
				if (size(winds[0]) == 3 and num(winds[0]) != nil and winds[0] >= 0 and winds[0] <= 360 and
				size(winds[1]) == 3 and num(winds[1]) != nil and winds[1] >= 0 and winds[1] <= 200 and
				size(winds[2]) == 5 and ((num(winds[2]) != nil and winds[2] >= 1000 and winds[2] <= 39000) or
				(num(split("FL", winds[2])[1]) != nil and split("FL", winds[2])[1] >= 10 and split("FL", winds[2])[1] <= 390))) {
					me.makeTmpy();
					if (me.singleCRZ == 1) {
						me.windList[index - 1] = [winds[0], winds[1], winds[2]];
						if (index != 4) {
							append(me.windList, nil);
						}
					} else {
						if (index == 1) {
							fmgc.wpWindDirection0[me.computer][me.match_location].setValue(num(winds[0]));
							fmgc.wpWindMagnitude0[me.computer][me.match_location].setValue(num(winds[1]));
							fmgc.wpWindAltitude0[me.computer][me.match_location].setValue(winds[2]);
						} else if (index == 2) {
							fmgc.wpWindDirection1[me.computer][me.match_location].setValue(num(winds[0]));
							fmgc.wpWindMagnitude1[me.computer][me.match_location].setValue(num(winds[1]));
							fmgc.wpWindAltitude1[me.computer][me.match_location].setValue(winds[2]);
						} else if (index == 3) {
							fmgc.wpWindDirection2[me.computer][me.match_location].setValue(num(winds[0]));
							fmgc.wpWindMagnitude2[me.computer][me.match_location].setValue(num(winds[1]));
							fmgc.wpWindAltitude2[me.computer][me.match_location].setValue(winds[2]);
						} else if (index == 4) {
							fmgc.wpWindDirection3[me.computer][me.match_location].setValue(num(winds[0]));
							fmgc.wpWindMagnitude3[me.computer][me.match_location].setValue(num(winds[1]));
							fmgc.wpWindAltitude3[me.computer][me.match_location].setValue(winds[2]);
						}
					}
					mcdu_scratchpad.scratchpads[me.computer].empty();
					me._setupPageWithData();
					me.updateTmpy();
				} else {
					mcdu_message(me.computer, "NOT ALLOWED");
				}
			} else {
				mcdu_message(me.computer, "NOT ALLOWED");
			}
		} else {
			mcdu_message(me.computer, "NOT ALLOWED");
		}
	},
	pushButtonUp: func() {
		if (me.cur_location < size(fmgc.flightPlanController.getWaypointList(2)) - 1) {
			me.cur_location = me.cur_location + 1;
		} else {
			me.cur_location = 0;
		}
		me.waypoint = fmgc.flightPlanController.getWaypointList(2)[me.cur_location];
		me.match_location = fmgc.flightPlanController.getWaypointMapping(2)[me.cur_location];
		#load stored data here
		me.reload();
	},
	pushButtonDown: func() {
		if (me.cur_location > 0) {
			me.cur_location = me.cur_location - 1;
		} else {
			me.cur_location = size(fmgc.flightPlanController.getWaypointList(2)) - 1;
		}
		me.waypoint = fmgc.flightPlanController.getWaypointList(2)[me.cur_location];
		me.match_location = fmgc.flightPlanController.getWaypointMapping(2)[me.cur_location];
		#load stored data here
		me.reload();
	}
};