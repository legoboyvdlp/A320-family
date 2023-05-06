var holdPage = {
	title: [nil, nil, nil],
	subtitle: [nil, nil],
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
	new: func(computer, waypoint) {
		var hp = {parents:[holdPage]};
		hp.computer = computer;
		hp.waypoint = waypoint;
		hp._setupPageWithData();
		hp.updateTmpy();
		return hp;
	},
	del: func() {
		return nil;
	},
	_setupPageWithData: func() {
		me.title = ["HOLD", " AT ", me.waypoint.wp_name];
		me.titleColour = "wht";
		me.arrowsMatrix = [[0, 0, 0, 0, 0, 1], [0, 0, 0, 0, 0, 0]];
		me.arrowsColour = [["ack", "ack", "ack", "ack", "ack", "wht"], ["blu", "blu", "ack", "ack", "ack", "ack"]];
		
		if (me.waypoint.fly_type == "Hold") {
			me.R1 = ["COMPUTED ", nil, "wht"];
			me.R2 = ["DATABASE ", nil, "blu"];
			me.arrowsColour[1][0] = "wht";
			me.arrowsColour[1][1] = "blu";
			me.arrowsMatrix[1][0] = 1;
			me.arrowsMatrix[1][1] = 0;
		} else {
			# waypoint is a leg, figure out how to handle it
			return;
			me.waypoint.hold_count = 999;
			me.waypoint.hold_is_left_handed = 0;
			me.waypoint.hold_is_distance = 0;
			me.waypoint.hold_inbound_radial = me.waypoint.leg_bearing;
			
			if (pts.Instrumentation.Altimeter.indicatedFt.getValue() >= 14000) {
				me.waypoint.hold_time_or_distance = 90;
			} else {
				me.waypoint.hold_time_or_distance = 60;
			}
			
			me.R1 = ["COMPUTED ", nil, "yel"];
			me.R2 = ["DATABASE ", nil, "wht"];
			me.arrowsColour[1][0] = "yel";
			me.arrowsColour[1][1] = "wht";
			me.arrowsMatrix[1][0] = 0;
			me.arrowsMatrix[1][1] = 1;
		}
		
		me.L1 = [sprintf("%03.0f°", me.waypoint.hold_inbound_radial), "INB CRS", "blu"];
		if (me.waypoint.hold_is_left_handed) {
			me.L2 = ["L", " TURN", "blu"];
		} else {
			me.L2 = ["R", " TURN", "blu"];
		}
		if (me.waypoint.hold_is_distance) {
			me.L3 = [" -.-/" ~ me.waypoint.hold_time_or_distance, "TIME/DIST", "blu"];
		} else {
			me.L3 = [sprintf("%3.1f", (me.waypoint.hold_time_or_distance / 60)) ~ "/----", "TIME/DIST", "blu"];
		}
		
		me.C4 = ["LAST EXIT", nil, "wht"];
		me.C5 = ["----  ---.-", "UTC    FUEL", "wht"];
		canvas_mcdu.pageSwitch[me.computer].setBoolValue(0);
	},
	makeTmpy: func() {
		if (!fmgc.flightPlanController.temporaryFlag[me.computer]) {
			fmgc.flightPlanController.createTemporaryFlightPlan(me.computer);
		}
	},
	updateTmpy: func() {
		if (fmgc.flightPlanController.temporaryFlag[me.computer]) {
			me.L6 = [" F-PLN", " TMPY", "yel"];
			me.R6 = ["INSERT ", " TMPY", "yel"];
			me.arrowsColour[0][5] = "yel";
			me.titleColour = "yel";
			canvas_mcdu.pageSwitch[me.computer].setBoolValue(0);
		} else {
			me.L6 = [" RETURN", nil, "wht"];
			me.R6 = [nil, nil, "ack"];
			me.arrowsColour[0][5] = "wht";
			me.titleColour = "wht";
			canvas_mcdu.pageSwitch[me.computer].setBoolValue(0);
		}
	},
	pushbuttonLeft: func(index) {
		me.scratchpad = mcdu_scratchpad.scratchpads[me.computer].scratchpad;
		if (index == 1) {
			if (size(me.scratchpad) <= 3 and num(me.scratchpad) != nil) {
				me.waypoint.hold_inbound_radial = me.scratchpad;
				mcdu_scratchpad.scratchpads[me.computer].empty();
				me._setupPageWithData();
			} else {
				mcdu_message(me.computer, "NOT ALLOWED");
			}
		} else if (index == 2) {
			if (me.scratchpad == "L") {
				me.waypoint.hold_is_left_handed = 1;
				mcdu_scratchpad.scratchpads[me.computer].empty();
				me._setupPageWithData();
			} elsif (me.scratchpad == "R") {
				me.waypoint.hold_is_left_handed = 0;
				mcdu_scratchpad.scratchpads[me.computer].empty();
				me._setupPageWithData();
			} else {
				mcdu_message(me.computer, "NOT ALLOWED");
			}
		} elsif (index == 3) {
			if (num(me.scratchpad) != nil) {
				me.waypoint.hold_time_or_distance = me.scratchpad;
				mcdu_scratchpad.scratchpads[me.computer].empty();
				me._setupPageWithData();
			} else {
				mcdu_message(me.computer, "NOT ALLOWED");
			}
		} else {
			mcdu_message(me.computer, "NOT ALLOWED");
		}
	},
	pushbuttonRight: func(index) {
		me.scratchpad = mcdu_scratchpad.scratchpads[me.computer].scratchpad;
		if (size(me.scratchpad) != 0) {
			mcdu_message(me.computer, "NOT ALLOWED");
		} else {
			if (index == 6) {
				if (fmgc.flightPlanController.temporaryFlag[me.computer]) {
					setprop("/MCDU[" ~ me.computer ~ "]/page", "F-PLNA");
				} else {
					mcdu_message(me.computer, "NOT ALLOWED");
				}
			} else {
				mcdu_message(me.computer, "NOT ALLOWED");
			}
		}
	},
};