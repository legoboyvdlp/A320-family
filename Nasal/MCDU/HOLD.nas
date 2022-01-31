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
		me.arrowsMatrix = [[0, 0, 0, 0, 0, 1], [1, 1, 0, 0, 0, 0]];
		me.arrowsColour = [["ack", "ack", "ack", "ack", "ack", "wht"], ["blu", "blu", "ack", "ack", "ack", "ack"]];
		if (me.waypoint.fly_type == "Hold") {
			me.makeTmpy();
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
			me.R1 = ["COMPUTED ", nil, "blu"];
			me.R2 = ["DATABASE ", nil, "yel"];
			me.arrowsMatrix[1][1] = 0;
		} else {
			me.L1 = ["100°", "INB CRS", "blu"];
			me.L2 = ["R", " TURN", "blu"];
			if (pts.Instrumentation.Altimeter.indicatedFt.getValue() >= 14000) {
				me.L3 = ["1.5/----", "TIME/DIST", "blu"];
			} else {
				me.L3 = ["1.0/----", "TIME/DIST", "blu"];
			}
			me.R1 = ["COMPUTED ", nil, "blu"];
			me.R2 = ["DATABASE ", nil, "blu"];
		}
		me.L6 = [" RETURN", nil, "wht"];
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
			me.L1[2] = "yel";
			me.L2[2] = "yel";
			me.L3[2] = "yel";
			me.L6 = [" F-PLN", " TMPY", "yel"];
			me.R6 = ["INSERT ", " TMPY", "yel"];
			me.arrowsColour[0][5] = "yel";
			me.titleColour = "yel";
			canvas_mcdu.pageSwitch[me.computer].setBoolValue(0);
		} else {
			me.L1[2] = "blu";
			me.L2[2] = "blu";
			me.L3[2] = "blu";
			me.L6 = [" RETURN", nil, "wht"];
			me.R6 = [nil, nil, "ack"];
			me.arrowsColour[0][5] = "wht";
			me.titleColour = "wht";
			canvas_mcdu.pageSwitch[me.computer].setBoolValue(0);
		}
	}
};