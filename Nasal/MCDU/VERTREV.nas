var vertRev = {
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
	R1: [nil, nil, "ack"],
	R2: [nil, nil, "ack"],
	R3: [nil, nil, "ack"],
	R4: [nil, nil, "ack"],
	R5: [nil, nil, "ack"],
	R6: [nil, nil, "ack"],
	depAirport: nil,
	arrAirport: nil,
	index: nil,
	computer: nil,
	new: func(type, id, index, computer) {
		var vr = {parents:[vertRev]};
		vr.type = type; # 0 = origin 1 = destination 2 = wpt not ppos 3 = ppos 4 = cruise wpt 5 = climb wpt (3 + 4 not needed yet)
		vr.id = id;
		vr.index = index;
		vr.computer = computer;
		vr._setupPageWithData();
		vr._checkTmpy();
		return vr;
	},
	del: func() {
		return nil;
	},
	_checkTmpy: func() {
		if (fmgc.flightPlanController.temporaryFlag[me.computer]) {
			me.L6 = [" F-PLN", " TMPY", "yel"];
			me.arrowsColour[0][5] = "yel";
			canvas_mcdu.pageSwitch[me.computer].setBoolValue(0);
		}
	},
	_setupPageWithData: func() {
		if (me.type == 3) { 
			me.title = ["VERT REV", " AT ", "PPOS"];
			me.L1 = ["", "  EFOB ---.-", "wht"];
			me.R1 = ["", "EXTRA ---.- ", "wht"];
			me.L2 = ["250/10000", " CLB SPD LIM", "mag"];
			me.L4 = [" CONSTANT MACH", nil, "wht"];
			me.L5 = [" WIND DATA", nil, "wht"];
			me.L6 = [" RETURN", nil, "wht"];
			me.R2 = ["RTA ", nil, "wht"];
			me.arrowsMatrix = [[0, 0, 0, 1, 1, 1], [0, 1, 0, 0, 0, 0]];
			me.arrowsColour = [["ack", "ack", "ack", "wht", "wht", "wht"], ["ack", "wht", "ack", "ack", "wht", "wht"]];
			me.fontMatrix = [[0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0]];
		} if (me.type == 2) { 
			me.title = ["VERT REV", " AT ", me.id];
			me.L1 = ["", "  EFOB ---.-", "wht"];
			me.R1 = ["", "EXTRA ---.- ", "wht"];
			me.L2 = ["250/10000", " CLB SPD LIM", "mag"];
			me.L3 = [" [    ]", " SPD CSTR", "blu"];
			me.L4 = [" CONSTANT MACH", nil, "wht"];
			me.L5 = [" WIND DATA", nil, "wht"];
			me.L6 = [" CLB", nil, "amb"];
			me.R2 = ["RTA ", nil, "wht"];
			me.R3 = ["[      ] ", "ALT CSTR  ", "blu"];
			me.R6 = ["DES ", nil, "amb"];
			me.arrowsMatrix = [[0, 0, 0, 1, 1, 1], [0, 1, 0, 0, 0, 1]];
			me.arrowsColour = [["ack", "ack", "ack", "wht", "wht", "wht"], ["ack", "wht", "ack", "ack", "wht", "wht"]];
			me.fontMatrix = [[0, 0, 1, 0, 0, 0], [0, 0, 1, 0, 0, 0]];
		} else {
			me.title = ["VERT REV", " AT ", me.id];
			
			if (me.type == 0) {	
				if (size(me.id) > 4) {
					me.arrAirport = findAirportsByICAO(left(me.id, 4));
				} else {
					me.arrAirport = findAirportsByICAO(me.id);
				}
				me.L1 = ["", "  EFOB ---.-", "wht"];
				me.R1 = ["", "EXTRA ---.- ", "wht"];
				me.L2 = ["250/10000", " CLB SPD LIM", "mag"];
				me.L4 = [" CONSTANT MACH", nil, "wht"];
				me.L5 = [" WIND DATA", nil, "wht"];
				me.L6 = [" RETURN", nil, "wht"];
				me.R2 = ["RTA ", nil, "wht"];
				me.arrowsMatrix = [[0, 0, 0, 1, 1, 1], [0, 1, 0, 0, 0, 0]];
				me.arrowsColour = [["ack", "ack", "ack", "wht", "wht", "wht"], ["ack", "wht", "ack", "ack", "wht", "wht"]];
				me.fontMatrix = [[0, 0, 1, 0, 0, 0], [0, 0, 0, 0, 0, 0]];
			} elsif (me.type == 1) {
				if (size(me.id) > 4) {
					me.arrAirport = findAirportsByICAO(left(me.id, 4));
				} else {
					me.arrAirport = findAirportsByICAO(me.id);
				}
				me.L1 = ["", "  EFOB ---.-", "wht"];
				me.R1 = ["", "EXTRA ---.- ", "wht"];
				me.L2 = ["250/10000", " DES SPD LIM", "mag"];
				me.L4 = [" CONSTANT MACH", nil, "wht"];
				me.L5 = [" WIND DATA", nil, "wht"];
				me.L6 = [" RETURN", nil, "wht"];
				me.R2 = ["RTA ", nil, "wht"];
				me.R3 = ["3000", "G/S INTCP", "grn"];
				me.arrowsMatrix = [[0, 0, 0, 1, 1, 1], [0, 1, 0, 0, 0, 0]];
				me.arrowsColour = [["ack", "ack", "ack", "wht", "wht", "wht"], ["ack", "wht", "ack", "ack", "wht", "wht"]];
				me.fontMatrix = [[0, 0, 1, 0, 0, 0], [0, 0, 0, 0, 0, 0]];
			}
		}
		me.updateR5();
	},
	makeTmpy: func() {
		if (!fmgc.flightPlanController.temporaryFlag[me.computer]) {
			if (!dirToFlag) {
				fmgc.flightPlanController.createTemporaryFlightPlan(me.computer);
			} else {
			    setprop("MCDU[" ~ me.computer ~ "]/scratchpad-msg", 1);
                setprop("MCDU[" ~ me.computer ~ "]/scratchpad", "DIR TO IN PROGRESS");
			}
			me._checkTmpy();
		}
	},
	updateR5: func() {
		if (getprop("FMGC/internal/cruise-lvl-set") and (getprop("FMGC/status/phase") < 4 or getprop("FMGC/status/phase") == 7)) {
			me.R5 = ["STEP ALTS ", nil, "wht"];
			me.arrowsMatrix[1][4] = 1;
		} else {
			me.R5 = [nil, nil, "ack"];
			me.arrowsMatrix[1][4] = 0;
		}
	},
};

setlistener("FMGC/internal/cruise-lvl-set", func() {
	if (canvas_mcdu.myVertRev[0] != nil) { 
		canvas_mcdu.myVertRev[0].updateR5();
	}
	
	if (canvas_mcdu.myVertRev[1] != nil) { 
		canvas_mcdu.myVertRev[1].updateR5();
	}
}, 0, 0);

setlistener("FMGC/status/phase", func() {
	if (canvas_mcdu.myVertRev[0] != nil) { 
		canvas_mcdu.myVertRev[0].updateR5();
	}
	
	if (canvas_mcdu.myVertRev[1] != nil) { 
		canvas_mcdu.myVertRev[1].updateR5();
	}
}, 0, 0);