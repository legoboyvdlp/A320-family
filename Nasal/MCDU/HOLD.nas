var holdPage = {
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
		hp.updateTmpy();
		hp._setupPageWithData();
		return hp;
	},
	del: func() {
		return nil;
	},
	_setupPageWithData: func() {
		# me.title = ["LAT REV", " AT ", me.waypoint.wp_name]; TODO FIXME LATREV
		me.title = ["HOLD", " AT ", me.waypoint];
		me.titleColour = "wht";
		me.L1 = [" [   ]", " INB CRS", "blu"];
		me.L2 = [" R", " TURN", "blu"];
		if (pts.Instrumentation.Altimeter.indicatedFt.getValue() >= 14000) {
			me.L2 = [" 1.5/----", "TIME/DIST", "blu"];
		} else {
			me.L2 = [" 1.0/----", "TIME/DIST", "blu"];
		}
		me.L6 = [" RETURN", nil, "wht"];
		me.C4 = ["LAST EXIT", nil, "wht"];
		me.C5 = ["----  ---.-", "UTC    FUEL", "wht"];
		me.R1 = ["COMPUTED ", nil, "blu"];
		me.R2 = ["DATABASE ", nil, "blu"];
		me.arrowsMatrix = [[0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0]];
		me.arrowsColour = [["ack", "ack", "ack", "ack", "ack", "wht"], ["blu", "blu", "ack", "ack", "ack", "ack"]];
		me.fontMatrix = [[1, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0]];
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
			me.arrowsColour[0][5] = "yel";
			me.R2[2] = "yel";
			me.R3[2] = "yel";
			me.R4[2] = "yel";
			canvas_mcdu.pageSwitch[me.computer].setBoolValue(0);
		}
	}
};