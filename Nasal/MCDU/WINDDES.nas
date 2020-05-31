# A3XX mCDU by Joshua Davidson (Octal450), Jonathan Redpath, and Matthew Maring (mattmaring)

# Copyright (c) 2020 Matthew Maring (mattmaring)

var windDESPage = {
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
	new: func(computer) {
		var wdp = {parents:[windDESPage]};
		wdp.computer = computer;
		wdp._setupPageWithData();
		wdp.updateTmpy();
		return wdp;
	},
	del: func() {
		return nil;
	},
	_setupPageWithData: func() {
		me.title = "DESCENT WIND";
		#me.title = "DRAFT DESCENT WIND";
		me.titleColour = "wht";
		me.L1 = ["[   ]g/[   ]/FL---", "TRU WIND/ALT", "blu"];
		me.L2 = ["[   ]g/[   ]/FL200", "", "blu"];
		me.L3 = ["[   ]g/[   ]/FL100", "", "blu"];
		me.L4 = ["[   ]g/[   ]/FL050", "", "blu"];
		me.L5 = ["[   ]g/[   ]/GRND", "", "blu"];
		me.L6 = [" CANCEL", " WIND", "amb"];
		me.R1 = ["[   ]g/[   ]", "WIND ", "blu"];
		me.R2 = ["", "FL---", "grn"];
		me.R3 = [" REQUEST ", "WIND ", "wht"];
		me.R4 = [" PHASE ", "PREV ", "wht"];
		me.R6 = ["UPDATE ", "WIND ", "amb"];
# 		me.L2 = [" R", " TURN", "blu"];
# 		if (pts.Instrumentation.Altimeter.indicatedFt.getValue() >= 14000) {
# 			me.L2 = [" 1.5/----", "TIME/DIST", "blu"];
# 		} else {
# 			me.L2 = [" 1.0/----", "TIME/DIST", "blu"];
# 		}
# 		me.L6 = [" RETURN", nil, "wht"];
# 		me.C4 = ["LAST EXIT", nil, "wht"];
# 		me.C5 = ["----  ---.-", "UTC    FUEL", "wht"];
# 		me.R1 = ["COMPUTED ", nil, "wht"];
# 		me.R2 = ["DATABASE ", nil, "wht"];
		me.arrowsMatrix = [[0, 0, 0, 0, 0, 0], [0, 0, 0, 1, 0, 0]];
		me.arrowsColour = [["ack", "ack", "ack", "ack", "ack", "ack"], ["ack", "ack", "ack", "wht", "ack", "ack"]];
		me.fontMatrix = [[1, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0]];
		canvas_mcdu.pageSwitch[me.computer].setBoolValue(0);
	},
	makeTmpy: func() {
		# if (!fmgc.flightPlanController.temporaryFlag[me.computer]) {
# 			fmgc.flightPlanController.createTemporaryFlightPlan(me.computer);
# 		}
	},
	updateTmpy: func() {
		# if (fmgc.flightPlanController.temporaryFlag[me.computer]) {
# 			me.L1[2] = "yel";
# 			me.L2[2] = "yel";
# 			me.L6 = [" F-PLN", " TMPY", "yel"];
# 			me.R6 = ["INSERT* ", " TMPY", "yel"];
# 			me.arrowsColour[0][5] = "yel";
# 			me.titleColour = "yel";
# 			canvas_mcdu.pageSwitch[me.computer].setBoolValue(0);
# 		} else {
# 			me.L1[2] = "blu";
# 			me.L2[2] = "blu";
# 			me.L6 = [" RETURN", nil, "wht"];
# 			me.R6 = [nil, nil, "ack"];
# 			me.arrowsColour[0][5] = "wht";
# 			me.titleColour = "wht";
# 			canvas_mcdu.pageSwitch[me.computer].setBoolValue(0);
# 		}
	}
};