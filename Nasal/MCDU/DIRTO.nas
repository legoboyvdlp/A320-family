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
		me.L6 = [" ERASE", "   DIR TO", "yel"];
		me.R1 = ["----   ---  ", "UTC   DIST  ", "wht"];
		me.R2 = ["DIRECT TO ", nil, "blu"];
		me.R3 = ["ABEAM PTS ", "WITH        ", "blu"];
		me.R4 = ["[   ]  ", "RADIAL IN   ", "blu"];
		me.R5 = ["[   ]  ", "RADIAL OUT  ", "blu"];
		me.R6 = ["INSERT* ", "DIR TO   ", "yel"];
		me.arrowsMatrix = [[0, 0, 0, 0, 0, 0], [0, 1, 0, 1, 0, 0]];
		me.arrowsColour = [["ack", "blu", "blu", "blu", "blu", "ack"], ["ack", "blu", "ack", "blu", "ack", "ack"]];
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
			me.L6 = [" ERASE", "   DIR TO", "yel"];
			me.R6 = ["INSERT ", "DIR TO   ", "yel"];
			me.arrowsMatrix[0][5] = 1;
			me.arrowsColour[0][5] = "yel";
			me.L1[2] = "yel";
			me.R2[2] = "yel";
			me.titleColour = "yel";
		} else {
			me.L6 = [nil, nil, "yel"];
			me.R6 = [nil, nil, "yel"];
			me.arrowsMatrix[0][5] = 0;
			me.arrowsColour[0][5] = "ack";
			me.L1[2] = "blu";
			me.R2[2] = "blu";
			me.titleColour = "wht";
		}
		canvas_mcdu.pageSwitch[me.computer].setBoolValue(0);
	},
	updateFromFpln: func() {
		if (canvas_mcdu.myFpln[me.computer] == nil) {
			 canvas_mcdu.myFpln[i] = fplnPage.new(2, me.computer);
		}
		
		var x = 0;
		me.vector = [];
		for (var i = 1 + (me.scroll - 1); i < size(canvas_mcdu.myFpln[me.computer].planList) - 2; i = i + 1) {
			if (canvas_mcdu.myFpln[me.computer].planList[i].wp.wp_name == "DISCONTINUITY" or canvas_mcdu.myFpln[me.computer].planList[i].wp.wp_type == "hdgToAlt") { continue; }
			if (fmgc.flightPlanController.temporaryFlag[me.computer] and canvas_mcdu.myFpln[me.computer].planList[i].index > fmgc.flightPlanController.arrivalIndex[me.computer]) { 
				continue; 
			} elsif (!fmgc.flightPlanController.temporaryFlag[me.computer] and canvas_mcdu.myFpln[me.computer].planList[i].index > fmgc.flightPlanController.arrivalIndex[2]) {
				continue; 
			}
			append(me.vector, " " ~ canvas_mcdu.myFpln[me.computer].planList[i].wp.wp_name);
			x += 1;
			if (x == 4) { break; }
		}
		
		if (size(me.vector) > 0) {
			me.L2[0] = me.vector[0];
			me.arrowsMatrix[0][1] = 1;
		} else {
			me.L2[0] = nil;
			me.arrowsMatrix[0][1] = 0;
		}
		if (size(me.vector) > 1) {
			me.L3[0] = me.vector[1];
			me.arrowsMatrix[0][2] = 1;
		} else {
			me.L3[0] = nil;
			me.arrowsMatrix[0][2] = 0;
		}
		if (size(me.vector) > 2) {
			me.L4[0] = me.vector[2];
			me.arrowsMatrix[0][3] = 1;
		} else {
			me.L4[0] = nil;
			me.arrowsMatrix[0][3] = 0;
		}
		if (size(me.vector) > 3) {
			me.L5[0] = me.vector[3];
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
};