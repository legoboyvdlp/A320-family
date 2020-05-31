# A3XX mCDU by Joshua Davidson (Octal450), Jonathan Redpath, and Matthew Maring (mattmaring)

# Copyright (c) 2020 Matthew Maring (mattmaring)

var windCLBPage = {
	title: nil,
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
	windList: [],
	new: func(computer) {
		var wcp = {parents:[windCLBPage]};
		wcp.computer = computer;
		wcp.windList = [nil];
		wcp._setupPageWithData();
		wcp.updateTmpy();
		return wcp;
	},
	del: func() {
		return nil;
	},
	_setupPageWithData: func() {
		me.title = "CLIMB WIND";
		#me.title = "DRAFT CLIMB WIND";
		me.titleColour = "wht";
		me.arrowsMatrix = [[0, 0, 0, 0, 0, 0], [1, 0, 0, 0, 1, 0]];
		me.arrowsColour = [["ack", "ack", "ack", "ack", "ack", "ack"], ["wht", "ack", "ack", "ack", "wht", "ack"]];
		me.fontMatrix = [[1, 1, 1, 1, 1, 0], [0, 0, 0, 0, 0, 0]];
		
		if (size(me.windList) >= 5) {
			if (me.windList[4] != nil) {
				me.L5 = [me.windList[4][0] ~ "/" ~ me.windList[4][1] ~ "/" ~ me.windList[4][2], nil, "blu"];
				me.fontMatrix[0][4] = 0;
			} else {
				me.L5 = ["[  ]/[  ]/[   ]", nil, "blu"];
				me.fontMatrix[0][4] = 1;
			}
		} else {
			me.L5 = [nil, nil, "ack"];
		}
		
		if (size(me.windList) >= 4) {
			if (me.windList[3] != nil) {
				me.L4 = [me.windList[3][0] ~ "/" ~ me.windList[3][1] ~ "/" ~ me.windList[3][2], nil, "blu"];
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
				me.L3 = [me.windList[2][0] ~ "/" ~ me.windList[2][1] ~ "/" ~ me.windList[2][2], nil, "blu"];
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
				me.L2 = [me.windList[1][0] ~ "/" ~ me.windList[1][1] ~ "/" ~ me.windList[1][2], nil, "blu"];
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
				me.L1 = [me.windList[0][0] ~ "/" ~ me.windList[0][1] ~ "/" ~ me.windList[0][2], "TRU WIND/ALT", "blu"];
				me.fontMatrix[0][0] = 0;
			} else {
				me.L1 = ["[  ]/[  ]/[   ]", "TRU WIND/ALT", "blu"];
				me.fontMatrix[0][0] = 1;
			}
		}
		
		me.R1 = [" HISTORY ", "WIND ", "wht"];
		me.R3 = [" REQUEST ", "WIND ", "amb"];
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
			me.L6 = [" CANCEL", " WIND", "amb"];
			me.R6 = ["UPDATE ", "WIND ", "amb"];
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
	pushButtonLeft: func(index) {
		if (size(me.windList) >= index) {
			if (size(mcdu_scratchpad.scratchpads[me.computer].scratchpad) == 13) {
				var winds = split("/", mcdu_scratchpad.scratchpads[me.computer].scratchpad);
				if (size(winds[0]) == 3 and num(winds[0]) != nil and winds[0] >= 0 and winds[0] <= 360 and
				size(winds[1]) == 3 and num(winds[1]) != nil and winds[1] >= 0 and winds[1] <= 200 and
				size(winds[2]) == 5 and ((num(winds[2]) != nil and winds[2] >= 1000 and winds[2] <= 39000) or
				(num(split("FL", winds[2])[1]) != nil and split("FL", winds[2])[1] >= 10 and split("FL", winds[2])[1] <= 390))) {
					me.windList[index - 1] = [winds[0], winds[1], winds[2]];
					mcdu_scratchpad.scratchpads[me.computer].empty();
					if (index != 5) {
						append(me.windList, nil);
					}
					me._setupPageWithData();
					me.makeTmpy();
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
	}
};