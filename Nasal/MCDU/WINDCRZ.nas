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
	index: nil,
	computer: nil,
	cur_location: 0,
	match_location: 0,
	items: 0,
	singleCRZ: 0,
	new: func(computer, waypoint, cur_location) {
		var wcp = {parents:[windCRZPage]};
		wcp.computer = computer;
		wcp.waypoint = waypoint;
		wcp.cur_location = cur_location;
		if (waypoint == nil) {
			wcp.singleCRZ = 1;
		}
		wcp._setupPageWithData();
		wcp.updateTmpy();
		return wcp;
	},
	del: func() {
		return nil;
	},
	_setupPageWithData: func() {
		print("setup called");
		
		if (me.singleCRZ == 1) {
			me.title = ["","CRZ WIND",""];
		} else {
			me.title = ["CRZ WIND", " AT ", me.waypoint.wp_name];
		}
		me.titleColour = "wht";
		me.arrowsMatrix = [[0, 0, 0, 0, 0, 1], [0, 0, 0, 1, 1, 0]];
		me.arrowsColour = [["ack", "ack", "ack", "ack", "ack", "wht"], ["ack", "ack", "ack", "wht", "wht", "ack"]];
		me.fontMatrix = [[1, 1, 1, 1, 1, 0], [0, 0, 0, 0, 0, 0]];
		
		var computer_temp = 2;
		if (fmgc.flightPlanController.temporaryFlag[me.computer]) {
			computer_temp = me.computer;
		}
		
		#debug.dump(fmgc.windController.crz_winds[0]);
		#debug.dump(fmgc.windController.crz_winds[1]);
		#debug.dump(fmgc.windController.crz_winds[2]);
		
		if (me.singleCRZ == 1) {
			if (fmgc.windController.crz_winds[computer_temp] == 0 or fmgc.windController.crz_winds[computer_temp].wind1.altitude == "") {
				me.items = 1;
			} else if (fmgc.windController.crz_winds[computer_temp].wind2.altitude == "") {
				me.items = 2;
			} else if (fmgc.windController.crz_winds[computer_temp].wind3.altitude == "") {
				me.items = 3;
			} else {
				me.items = 4;
			}
		} else {
			me.match_location = fmgc.windController.nav_indicies[computer_temp][me.cur_location];
			if (size(fmgc.windController.winds[computer_temp]) == 0 or fmgc.windController.winds[computer_temp][me.match_location].wind1.altitude == "") {
				me.items = 1;
			} else if (fmgc.windController.winds[computer_temp][me.match_location].wind2.altitude == "") {
				me.items = 2;
			} else if (fmgc.windController.winds[computer_temp][me.match_location].wind3.altitude == "") {
				me.items = 3;
			} else {
				me.items = 4;
			}
		}
		
		# load data
		if (me.singleCRZ == 1) {
			if (me.items >= 4) {
				wind = fmgc.windController.crz_winds[computer_temp].wind4;
				if (wind.altitude != "") {
					me.L4 = [wind.heading ~ "/" ~ wind.magnitude ~ "/" ~ wind.altitude, nil, "blu"];
					me.fontMatrix[0][3] = 0;
				} else {
					me.L4 = ["[  ]/[  ]/[   ]", nil, "blu"];
					me.fontMatrix[0][3] = 1;
				}
			} else {
				me.L4 = [nil, nil, "ack"];
			}
		
			if (me.items >= 3) {
				wind = fmgc.windController.crz_winds[computer_temp].wind3;
				if (wind.altitude != "") {
					me.L3 = [wind.heading ~ "/" ~ wind.magnitude ~ "/" ~ wind.altitude, nil, "blu"];
					me.fontMatrix[0][2] = 0;
				} else {
					me.L3 = ["[  ]/[  ]/[   ]", nil, "blu"];
					me.fontMatrix[0][2] = 1;
				}
			} else {
				me.L3 = [nil, nil, "ack"];
			}
		
			if (me.items >= 2) {
				wind = fmgc.windController.crz_winds[computer_temp].wind2;
				if (wind.altitude != "") {
					me.L2 = [wind.heading ~ "/" ~ wind.magnitude ~ "/" ~ wind.altitude, nil, "blu"];
					me.fontMatrix[0][1] = 0;
				} else {
					me.L2 = ["[  ]/[  ]/[   ]", nil, "blu"];
					me.fontMatrix[0][1] = 1;
				}
			} else {
				me.L2 = [nil, nil, "ack"];
			}
		
			if (me.items >= 1) {
				wind = fmgc.windController.crz_winds[computer_temp].wind1;
				if (wind.altitude != "") {
					me.L1 = [wind.heading ~ "/" ~ wind.magnitude ~ "/" ~ wind.altitude, "TRU WIND/ALT", "blu"];
					me.fontMatrix[0][0] = 0;
				} else {
					me.L1 = ["[  ]/[  ]/[   ]", "TRU WIND/ALT", "blu"];
					me.fontMatrix[0][0] = 1;
				}
			}
			
			wind = fmgc.windController.crz_winds[computer_temp].sat1;
			if (wind.altitude != "") {
				me.L5 = [wind.temp ~ "/" ~ wind.altitude, "SAT / ALT", "blu"];
				me.fontMatrix[0][4] = 0;
			} else {
				me.L5 = ["[  ]/[   ]", "SAT / ALT", "blu"];
				me.fontMatrix[0][4] = 1;
			}
		} else {
			if (me.items >= 4) {
				wind = fmgc.windController.winds[computer_temp][me.match_location].wind4;
				if (wind.altitude != "") {
					me.L4 = [wind.heading ~ "/" ~ wind.magnitude ~ "/" ~ wind.altitude, nil, "blu"];
					me.fontMatrix[0][3] = 0;
				} else {
					me.L4 = ["[  ]/[  ]/[   ]", nil, "blu"];
					me.fontMatrix[0][3] = 1;
				}
			} else {
				me.L4 = [nil, nil, "ack"];
			}
		
			if (me.items >= 3) {
				wind = fmgc.windController.winds[computer_temp][me.match_location].wind3;
				if (wind.altitude != "") {
					me.L3 = [wind.heading ~ "/" ~ wind.magnitude ~ "/" ~ wind.altitude, nil, "blu"];
					me.fontMatrix[0][2] = 0;
				} else {
					me.L3 = ["[  ]/[  ]/[   ]", nil, "blu"];
					me.fontMatrix[0][2] = 1;
				}
			} else {
				me.L3 = [nil, nil, "ack"];
			}
		
			if (me.items >= 2) {
				wind = fmgc.windController.winds[computer_temp][me.match_location].wind2;
				if (wind.altitude != "") {
					me.L2 = [wind.heading ~ "/" ~ wind.magnitude ~ "/" ~ wind.altitude, nil, "blu"];
					me.fontMatrix[0][1] = 0;
				} else {
					me.L2 = ["[  ]/[  ]/[   ]", nil, "blu"];
					me.fontMatrix[0][1] = 1;
				}
			} else {
				me.L2 = [nil, nil, "ack"];
			}
		
			if (me.items >= 1) {
				wind = fmgc.windController.winds[computer_temp][me.match_location].wind1;
				if (wind.altitude != "") {
					me.L1 = [wind.heading ~ "/" ~ wind.magnitude ~ "/" ~ wind.altitude, "TRU WIND/ALT", "blu"];
					me.fontMatrix[0][0] = 0;
				} else {
					me.L1 = ["[  ]/[  ]/[   ]", "TRU WIND/ALT", "blu"];
					me.fontMatrix[0][0] = 1;
				}
			}
			
			wind = fmgc.windController.winds[computer_temp][me.match_location].sat1;
			if (wind.altitude != "") {
				me.L5 = [wind.temp ~ "/" ~ wind.altitude, "SAT / ALT", "blu"];
				me.fontMatrix[0][4] = 0;
			} else {
				me.L5 = ["[  ]/[   ]", "SAT / ALT", "blu"];
				me.fontMatrix[0][4] = 1;
			}
		}
		
		me.L6 = [" RETURN", nil, "wht"];
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
		if (index == 6 and fmgc.flightPlanController.temporaryFlag[me.computer]) {
			if (canvas_mcdu.myFpln[me.computer] != nil) {
				canvas_mcdu.myFpln[me.computer].pushButtonLeft(index);
			} else {
				fmgc.flightPlanController.destroyTemporaryFlightPlan(me.computer, 0);
				# push update to fuel
				if (getprop("/FMGC/internal/block-confirmed")) {
					setprop("/FMGC/internal/fuel-calculating", 0);
					setprop("/FMGC/internal/fuel-calculating", 1);
				}
			}
			me.reload();
		} else if (index == 6) {
			setprop("/MCDU[" ~ me.computer ~ "]/page", "INITA");
		} else if (index == 5) {
			var sts = size(mcdu_scratchpad.scratchpads[me.computer].scratchpad);
			if (sts >= 7 and sts <= 9) {
				var winds = split("/", mcdu_scratchpad.scratchpads[me.computer].scratchpad);
				if (size(winds[0]) >= 1 and size(winds[0]) <= 3 and num(winds[0]) != nil and winds[0] >= -99 and winds[0] <= 99 and
				size(winds[1]) == 5 and ((num(winds[1]) != nil and winds[1] >= 1000 and winds[1] <= 39000) or
				(num(split("FL", winds[1])[1]) != nil and split("FL", winds[1])[1] >= 10 and split("FL", winds[1])[1] <= 390))) {
					me.makeTmpy();
					var computer_temp = 2;
					if (fmgc.flightPlanController.temporaryFlag[me.computer]) {
						computer_temp = me.computer;
					}
					#print(computer_temp);
					if (me.singleCRZ == 1) {
						fmgc.windController.crz_winds[computer_temp].sat1.temp = winds[0];
						fmgc.windController.crz_winds[computer_temp].sat1.altitude = winds[1];
					} else {
						fmgc.windController.winds[computer_temp][me.match_location].sat1.temp = winds[0];
						fmgc.windController.winds[computer_temp][me.match_location].sat1.altitude = winds[1];
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
		} else if (me.items >= index) {
			if (size(mcdu_scratchpad.scratchpads[me.computer].scratchpad) == 13) {
				var winds = split("/", mcdu_scratchpad.scratchpads[me.computer].scratchpad);
				if (size(winds[0]) == 3 and num(winds[0]) != nil and winds[0] >= 0 and winds[0] <= 360 and
				size(winds[1]) == 3 and num(winds[1]) != nil and winds[1] >= 0 and winds[1] <= 200 and
				size(winds[2]) == 5 and ((num(winds[2]) != nil and winds[2] >= 1000 and winds[2] <= 39000) or
				(num(split("FL", winds[2])[1]) != nil and split("FL", winds[2])[1] >= 10 and split("FL", winds[2])[1] <= 390))) {
					me.makeTmpy();
					var computer_temp = 2;
					if (fmgc.flightPlanController.temporaryFlag[me.computer]) {
						computer_temp = me.computer;
					}
					#print(computer_temp);
					if (me.singleCRZ == 1) {
						if (index == 4) {
							fmgc.windController.crz_winds[computer_temp].wind4.heading = winds[0];
							fmgc.windController.crz_winds[computer_temp].wind4.magnitude = winds[1];
							fmgc.windController.crz_winds[computer_temp].wind4.altitude = winds[2];
						} else if (index == 3) {
							fmgc.windController.crz_winds[computer_temp].wind3.heading = winds[0];
							fmgc.windController.crz_winds[computer_temp].wind3.magnitude = winds[1];
							fmgc.windController.crz_winds[computer_temp].wind3.altitude = winds[2];
						} else if (index == 2) {
							fmgc.windController.crz_winds[computer_temp].wind2.heading = winds[0];
							fmgc.windController.crz_winds[computer_temp].wind2.magnitude = winds[1];
							fmgc.windController.crz_winds[computer_temp].wind2.altitude = winds[2];
						} else if (index == 1) {
							fmgc.windController.crz_winds[computer_temp].wind1.heading = winds[0];
							fmgc.windController.crz_winds[computer_temp].wind1.magnitude = winds[1];
							fmgc.windController.crz_winds[computer_temp].wind1.altitude = winds[2];
						}
					} else {
						if (index == 4) {
							fmgc.windController.winds[computer_temp][me.match_location].wind4.heading = winds[0];
							fmgc.windController.winds[computer_temp][me.match_location].wind4.magnitude = winds[1];
							fmgc.windController.winds[computer_temp][me.match_location].wind4.altitude = winds[2];
						} else if (index == 3) {
							fmgc.windController.winds[computer_temp][me.match_location].wind3.heading = winds[0];
							fmgc.windController.winds[computer_temp][me.match_location].wind3.magnitude = winds[1];
							fmgc.windController.winds[computer_temp][me.match_location].wind3.altitude = winds[2];
						} else if (index == 2) {
							fmgc.windController.winds[computer_temp][me.match_location].wind2.heading = winds[0];
							fmgc.windController.winds[computer_temp][me.match_location].wind2.magnitude = winds[1];
							fmgc.windController.winds[computer_temp][me.match_location].wind2.altitude = winds[2];
						} else if (index == 1) {
							fmgc.windController.winds[computer_temp][me.match_location].wind1.heading = winds[0];
							fmgc.windController.winds[computer_temp][me.match_location].wind1.magnitude = winds[1];
							fmgc.windController.winds[computer_temp][me.match_location].wind1.altitude = winds[2];
						}
					}
					mcdu_scratchpad.scratchpads[me.computer].empty();
					if (me.items == index and index != 4) {
						me.items += 1;
					}
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
	pushButtonRight: func(index) {
		if (index == 6 and fmgc.flightPlanController.temporaryFlag[me.computer]) {
			if (canvas_mcdu.myFpln[me.computer] != nil) {
				canvas_mcdu.myFpln[me.computer].pushButtonRight(index);
			} else {
				fmgc.flightPlanController.destroyTemporaryFlightPlan(me.computer, 1);
				# push update to fuel
				if (getprop("/FMGC/internal/block-confirmed")) {
					setprop("/FMGC/internal/fuel-calculating", 0);
					setprop("/FMGC/internal/fuel-calculating", 1);
				}
			}
			me.reload();
		} else {
			mcdu_message(me.computer, "NOT ALLOWED");
		}
	},
	pushButtonUp: func() {
		var computer_temp = 2;
		if (fmgc.flightPlanController.temporaryFlag[me.computer]) {
			computer_temp = me.computer;
		}
		if (me.cur_location < size(fmgc.windController.nav_indicies[computer_temp]) - 1) {
			me.cur_location = me.cur_location + 1;
		} else {
			me.cur_location = 0;
		}
		me.match_location = fmgc.windController.nav_indicies[computer_temp][me.cur_location];
		me.waypoint = fmgc.flightPlanController.flightplans[computer_temp].getWP(me.match_location);
		me.reload();
	},
	pushButtonDown: func() {
		var computer_temp = 2;
		if (fmgc.flightPlanController.temporaryFlag[me.computer]) {
			computer_temp = me.computer;
		}
		if (me.cur_location > 0) {
			me.cur_location = me.cur_location - 1;
		} else {
			me.cur_location = size(fmgc.windController.nav_indicies[computer_temp]) - 1;
		}
		me.match_location = fmgc.windController.nav_indicies[computer_temp][me.cur_location];
		me.waypoint = fmgc.flightPlanController.flightplans[computer_temp].getWP(me.match_location);
		me.reload();
	}
};