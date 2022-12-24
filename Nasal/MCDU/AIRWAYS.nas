var airwaysPage = {
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
	curWP: nil,
	computer: nil,
	titleColour: nil,
	new: func(computer, waypoint) {
		var ap = {parents:[airwaysPage]};
		ap.computer = computer;
		ap.waypoint = waypoint;
		ap._setupPageWithData();
		ap.updateTmpy();
		return ap;
	},
	del: func() {
		return nil;
	},
	_setupPageWithData: func() {
		me.title = ["AIRWAYS", " FROM ", me.waypoint.wp_name];
		me.titleColour = "grn";
		me.index = "L1";
		me.L1 = ["[    ]", "  VIA", "blu"];
		me.R1 = [nil, "TO  ", "blu"];
		me.arrowsMatrix = [[0, 0, 0, 0, 0, 1], [0, 0, 0, 0, 0, 0]];
		me.arrowsColour = [["ack", "ack", "ack", "ack", "ack", "wht"], ["ack", "ack", "ack", "ack", "ack", "ack"]];
		me.curWP = me.waypoint;
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
			me.R6 = ["INSERT* ", " TMPY", "yel"];
			me.arrowsColour[0][5] = "yel";
			canvas_mcdu.pageSwitch[me.computer].setBoolValue(0);
		} else {
			me.L6 = [" RETURN", nil, "wht"];
			me.R6 = [nil, nil, "ack"];
			me.arrowsColour[0][5] = "wht";
			canvas_mcdu.pageSwitch[me.computer].setBoolValue(0);
		}
	},
	updateAirways: func(name) { # Find route to waypoint by airway
		var fix = [];
		if (size(name) <= 3) {
			fix = findNavaidsByID(name);
		} else {
			fix = findFixesByID(name);
		}
		if (size(fix) == 0) {
			return 0;
		}
		fix = createWPFrom(fix[0]);
		#var rtGhosts = airwaysRoute(me.curWP, fix);
		var rt = airwaysRoute(me.curWP, fix);
		#foreach (var wp; rtGhosts) {
		#	append(rt, createWPFrom(wp));
		#}
		append(rt, fix);
		fmgc.flightPlanController.flightplans[me.computer].insertWaypoints(rt, fmgc.flightPlanController.flightplans[me.computer].indexOfWP(me.curWP) + 1);
		fmgc.flightPlanController.flightPlanChanged(me.computer);
		me.curWP = fix;
		return 1;
	},
};