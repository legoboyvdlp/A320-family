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
	windList: [],
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
		
		if (size(me.windList) >= 4) {
			me.L4 = ["[  ]/[  ]/[   ]", nil, "blu"];
		} else {
			me.L4 = [nil, nil, "ack"];
		}
		
		if (size(me.windList) >= 3) {
			me.L3 = ["[  ]/[  ]/[   ]", nil, "blu"];
		} else {
			me.L3 = [nil, nil, "ack"];
		}
		
		if (size(me.windList) >= 2) {
			me.L2 = ["[  ]/[  ]/[   ]", nil, "blu"];
		} else {
			me.L2 = [nil, nil, "ack"];
		}
		
		if (size(me.windList) >= 1) {
			me.L1 = ["[  ]/[  ]/[   ]", "TRU WIND/ALT", "blu"];
		}
		
		me.L5 = ["[  ]/[   ]", "SAT / ALT", "blu"];
		me.R2 = [" REQUEST ", "WIND ", "amb"];
		me.R4 = [" PHASE ", "PREV ", "wht"];
		me.R5 = [" PHASE ", "NEXT ", "wht"];

		me.arrowsMatrix = [[0, 0, 0, 0, 0, 1], [0, 0, 0, 1, 1, 0]];
		me.arrowsColour = [["ack", "ack", "ack", "ack", "ack", "wht"], ["ack", "ack", "ack", "wht", "wht", "ack"]];
		me.fontMatrix = [[1, 1, 1, 1, 1, 0], [0, 0, 0, 0, 0, 0]];
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
	pushButtonUp: func() {
		if (me.cur_location < size(fmgc.flightPlanController.getWaypointList(2)) - 1) {
			me.cur_location = me.cur_location + 1;
		} else {
			me.cur_location = 0;
		}
		me.waypoint = fmgc.flightPlanController.getWaypointList(2)[me.cur_location];
		me.windList = [];
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
		me.windList = [];
		#load stored data here
		me.reload();
	}
};