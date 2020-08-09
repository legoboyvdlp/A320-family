# A3XX mCDU by Joshua Davidson (Octal450), Jonathan Redpath, and Matthew Maring (mattmaring)

# Copyright (c) 2020 Matthew Maring (mattmaring)

var windHISTPage = {
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
		var whp = {parents:[windHISTPage]};
		whp.computer = computer;
		whp._setupPageWithData();
		#whp.updateTmpy();
		return whp;
	},
	del: func() {
		return nil;
	},
	_setupPageWithData: func() {
		me.title = "HISTORY WIND";
		me.titleColour = "wht";
		
		var lastIndex = 0;
		
		if (fmgc.windController.hist_winds.wind5.altitude != "") {
			lastIndex = 5;
		} else if (fmgc.windController.hist_winds.wind4.altitude != "") {
			lastIndex = 4;
		} else if (fmgc.windController.hist_winds.wind3.altitude != "") {
			lastIndex = 3;
		} else if (fmgc.windController.hist_winds.wind2.altitude != "") {
			lastIndex = 2;
		} else if (fmgc.windController.hist_winds.wind1.altitude != "") {
			lastIndex = 1;
		}
		
		if (fmgc.windController.hist_winds.wind1.altitude != "") {
			me.L1 = [sprintf("%03d°/", fmgc.windController.hist_winds.wind1.heading) ~ sprintf("%03d", fmgc.windController.hist_winds.wind1.magnitude), "", "grn"];
			if (lastIndex == 1) {
				me.C1 = ["       " ~ fmgc.windController.hist_winds.wind1.altitude ~ " CRZ FL", "", "grn"];
			} else {
				me.C1 = [fmgc.windController.hist_winds.wind1.altitude, "", "grn"];
			}
			fmgc.windController.hist_winds.wind1.set = 1;
		} else {
			me.L1 = ["", "", "grn"];
			me.C1 = ["", "", "grn"];
			#me.L1 = ["----/---", "", "grn"];
			#me.C1 = ["FL050", "", "grn"];
		}
		
		if (fmgc.windController.hist_winds.wind2.altitude != "") {
			me.L2 = [sprintf("%03d°/", fmgc.windController.hist_winds.wind2.heading) ~ sprintf("%03d", fmgc.windController.hist_winds.wind2.magnitude), "", "grn"];
			if (lastIndex == 2) {
				me.C2 = ["       " ~ fmgc.windController.hist_winds.wind2.altitude ~ " CRZ FL", "", "grn"];
			} else {
				me.C2 = [fmgc.windController.hist_winds.wind2.altitude, "", "grn"];
			}
			fmgc.windController.hist_winds.wind2.set = 1;
		} else {
			me.L2 = ["", "", "grn"];
			me.C2 = ["", "", "grn"];
			#me.L2 = ["----/---", "", "grn"];
			#me.C2 = ["FL150", "", "grn"];
		}
		
		if (fmgc.windController.hist_winds.wind3.altitude != "") {
			me.L3 = [sprintf("%03d°/", fmgc.windController.hist_winds.wind3.heading) ~ sprintf("%03d", fmgc.windController.hist_winds.wind3.magnitude), "", "grn"];
			if (lastIndex == 3) {
				me.C3 = ["       " ~ fmgc.windController.hist_winds.wind3.altitude ~ " CRZ FL", "", "grn"];
			} else {
				me.C3 = [fmgc.windController.hist_winds.wind3.altitude, "", "grn"];
			}
			fmgc.windController.hist_winds.wind3.set = 1;
		} else {
			me.L3 = ["", "", "grn"];
			me.C3 = ["", "", "grn"];
			#me.L3 = ["----/---", "", "grn"];
			#me.C3 = ["FL250", "", "grn"];
		}
		
		if (fmgc.windController.hist_winds.wind4.altitude != "") {
			me.L4 = [sprintf("%03d°/", fmgc.windController.hist_winds.wind4.heading) ~ sprintf("%03d", fmgc.windController.hist_winds.wind4.magnitude), "", "grn"];
			if (lastIndex == 4) {
				me.C4 = ["       " ~ fmgc.windController.hist_winds.wind4.altitude ~ " CRZ FL", "", "grn"];
			} else {
				me.C4 = [fmgc.windController.hist_winds.wind4.altitude, "", "grn"];
			}
			fmgc.windController.hist_winds.wind4.set = 1;
		} else {
			me.L4 = ["", "", "grn"];
			me.C4 = ["", "", "grn"];
			#me.L4 = ["----/---", "", "grn"];
			#me.C4 = ["       FL--- CRZ FL", "", "grn"];
		}
		
		if (fmgc.windController.hist_winds.wind5.altitude != "") {
			me.L5 = [sprintf("%03d°/", fmgc.windController.hist_winds.wind5.heading) ~ sprintf("%03d", fmgc.windController.hist_winds.wind5.magnitude), "", "grn"];
			if (lastIndex == 5) {
				me.C5 = ["       " ~ fmgc.windController.hist_winds.wind5.altitude ~ " CRZ FL", "", "grn"];
			} else {
				me.C5 = [fmgc.windController.hist_winds.wind5.altitude, "", "grn"];
			}
			fmgc.windController.hist_winds.wind5.set = 1;
		} else {
			me.L5 = ["", "", "grn"];
			me.C5 = ["", "", "grn"];
			#me.L5 = ["----/---", "", "grn"];
			#me.C5 = ["FL370", "", "grn"];
		}
		
		me.L6 = [" CLIMB WIND", "", "wht"];
		me.R6 = ["SELECT ", "", "amb"];

		me.arrowsMatrix = [[0, 0, 0, 0, 0, 1], [0, 0, 0, 0, 0, 0]];
		me.arrowsColour = [["ack", "ack", "ack", "ack", "ack", "wht"], ["ack", "ack", "ack", "ack", "ack", "ack"]];
		me.fontMatrix = [[1, 1, 1, 1, 1, 0], [0, 0, 0, 0, 0, 0]];
		canvas_mcdu.pageSwitch[me.computer].setBoolValue(0);
	},
	# makeTmpy: func() {
# 		if (!fmgc.flightPlanController.temporaryFlag[me.computer]) {
# 			fmgc.flightPlanController.createTemporaryFlightPlan(me.computer);
# 		}
# 	},
	# updateTmpy: func() {
# 		if (fmgc.flightPlanController.temporaryFlag[me.computer]) {
# 			me.L1[2] = "yel";
# 			me.L2[2] = "yel";
# 			me.L3[2] = "yel";
# 			me.L4[2] = "yel";
# 			me.L5[2] = "yel";
# 			me.C1[2] = "yel";
# 			me.C2[2] = "yel";
# 			me.C3[2] = "yel";
# 			me.C4[2] = "yel";
# 			me.C5[2] = "yel";
# 			canvas_mcdu.pageSwitch[me.computer].setBoolValue(0);
# 		} else {
# 			me.L1[2] = "blu";
# 			me.L2[2] = "blu";
# 			me.L3[2] = "blu";
# 			me.L4[2] = "blu";
# 			me.L5[2] = "blu";
# 			me.C1[2] = "blu";
# 			me.C2[2] = "blu";
# 			me.C3[2] = "blu";
# 			me.C4[2] = "blu";
# 			me.C5[2] = "blu";
# 			canvas_mcdu.pageSwitch[me.computer].setBoolValue(0);
# 		}
# 	},
	reload: func() {
		me._setupPageWithData();
		#me.updateTmpy();
	},
	pushButtonRight: func(index) {
		if (index == 6) {
			var hist_winds = fmgc.windController.hist_winds;
			if (hist_winds.wind1.set) {
				fmgc.windController.clb_winds[2].wind1.heading = hist_winds.wind1.heading;
				fmgc.windController.clb_winds[2].wind1.magnitude = hist_winds.wind1.magnitude;
				fmgc.windController.clb_winds[2].wind1.altitude = hist_winds.wind1.altitude;
				fmgc.windController.clb_winds[2].wind1.set = 1;
				if (hist_winds.wind2.set) {
					fmgc.windController.clb_winds[2].wind2.heading = hist_winds.wind2.heading;
					fmgc.windController.clb_winds[2].wind2.magnitude = hist_winds.wind2.magnitude;
					fmgc.windController.clb_winds[2].wind2.altitude = hist_winds.wind2.altitude;
					fmgc.windController.clb_winds[2].wind2.set = 1;
				}
				if (hist_winds.wind3.set) {
					fmgc.windController.clb_winds[2].wind3.heading = hist_winds.wind3.heading;
					fmgc.windController.clb_winds[2].wind3.magnitude = hist_winds.wind3.magnitude;
					fmgc.windController.clb_winds[2].wind3.altitude = hist_winds.wind3.altitude;
					fmgc.windController.clb_winds[2].wind3.set = 1;
				}
				if (hist_winds.wind4.set) {
					fmgc.windController.clb_winds[2].wind4.heading = hist_winds.wind4.heading;
					fmgc.windController.clb_winds[2].wind4.magnitude = hist_winds.wind4.magnitude;
					fmgc.windController.clb_winds[2].wind4.altitude = hist_winds.wind4.altitude;
					fmgc.windController.clb_winds[2].wind4.set = 1;
				}
				if (hist_winds.wind5.set) {
					fmgc.windController.clb_winds[2].wind5.heading = hist_winds.wind5.heading;
					fmgc.windController.clb_winds[2].wind5.magnitude = hist_winds.wind5.magnitude;
					fmgc.windController.clb_winds[2].wind5.altitude = hist_winds.wind5.altitude;
					fmgc.windController.clb_winds[2].wind5.set = 1;
				}
				if (canvas_mcdu.myCLBWIND[me.computer] == nil) {
					canvas_mcdu.myCLBWIND[me.computer] = windCLBPage.new(me.computer);
				} else {
					canvas_mcdu.myCLBWIND[me.computer].reload();
				}
				setprop("MCDU[" ~ me.computer ~ "]/page", "WINDCLB");
			} else {
				mcdu_message(me.computer, "NO WINDS");
			}
		} else {
			mcdu_message(me.computer, "NOT ALLOWED");
		}
	}
};