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
		me.L1 = [" [       ]", " WAYPOINT", "blu"];
		me.L2 = [nil, " F-PLN WPTS", "blu"];
		me.L6 = [" ERASE", "  DIR TO", "yel"];
		me.R1 = ["----   --- ", "UTC   DIST ", "wht"];
		me.R2 = ["DIRECT TO ", nil, "blu"];
		me.R3 = ["ABEAM PTS ", "WITH      ", "blu"];
		me.R4 = ["[   ]  ", "RADIAL IN ", "blu"];
		me.R5 = ["[   ]  ", "RADIAL OUT ", "blu"];
		me.arrowsMatrix = [[0, 1, 1, 1, 1, 1], [0, 1, 0, 1, 0, 0]];
		me.arrowsColour = [["ack", "blu", "blu", "blu", "blu", "yel"], ["ack", "blu", "ack", "blu", "ack", "ack"]];
		me.fontMatrix = [[1, 0, 0, 0, 0, 0], [0, 0, 0, 1, 1, 0]];
		canvas_mcdu.pageSwitch[me.computer].setBoolValue(0);
	},
	makeTmpy: func() {
		if (!fmgc.flightPlanController.temporaryFlag[me.computer]) {
			fmgc.flightPlanController.createTemporaryFlightPlan(me.computer);
		}
	},
};