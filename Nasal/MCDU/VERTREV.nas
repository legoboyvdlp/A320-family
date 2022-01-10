var scratchpadStore = nil;
var scratchpadSplit = nil;

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
	new: func(type, id, index, computer, wp, plan) {
		var vr = {parents:[vertRev]};
		vr.type = type; # 0 = origin 1 = destination 2 = wpt not ppos 3 = ppos 4 = cruise wpt 5 = climb wpt (3 + 4 not needed yet)
		vr.id = id;
		vr.index = index;
		vr.computer = computer;
		vr.wp = wp;
		vr.plan = plan;
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
	getSpd: func() {
		if (me.wp.speed_cstr != nil and me.wp.speed_cstr > 0) {
			var tcol = (me.wp.speed_cstr_type == "computed" or me.wp.speed_cstr_type == "computed_mach") ? "grn" : "mag";  # TODO - check if only computed
			return [" " ~ sprintf("%3.0f", me.wp.speed_cstr), tcol];
		} else {
			return [nil,nil];
		}
	},
	getAlt: func() {
		if (me.wp.alt_cstr != nil and me.wp.alt_cstr > 0) {
			var tcol = (me.wp.alt_cstr_type == "computed" or me.wp.alt_cstr_type == "computed_mach") ? "grn" : "mag";  # TODO - check if only computed
			var cstrAlt = "";
			
			if (me.wp.alt_cstr > fmgc.FMGCInternal.transAlt) {
				cstrAlt = "FL" ~ math.round(num(me.wp.alt_cstr) / 100);
			} else {
				cstrAlt = me.wp.alt_cstr;
			}
			
			cstrAlt = (me.wp.alt_cstr_type == "above") ? "+" ~ cstrAlt : cstrAlt;
			cstrAlt = (me.wp.alt_cstr_type == "below") ? "-" ~ cstrAlt : cstrAlt;
			return [cstrAlt ~ (size(cstrAlt) == 6 ? "" : " "), tcol];
		} else {
			return [nil,nil];
		}
	},
	alt: nil,
	speed: nil,
	_setupPageWithData: func() {
		if (me.type == 3) { 
			me.title = ["VERT REV", " AT ", "PPOS"];
			me.L1 = ["", "  EFOB ---.-", "wht"];
			me.R1 = ["", "EXTRA ---.- ", "wht"];
			me.L2 = [fmgc.FMGCInternal.clbSpdLim ~ "/" ~ fmgc.FMGCInternal.clbSpdLimAlt, " CLB SPD LIM", "mag"];
			me.L4 = [" CONSTANT MACH", nil, "wht"];
			me.L5 = [" WIND DATA", nil, "wht"];
			me.L6 = [" RETURN", nil, "wht"];
			me.R2 = ["RTA ", nil, "wht"];
			me.arrowsMatrix = [[0, 0, 0, 1, 1, 1], [0, 1, 0, 0, 0, 0]];
			me.arrowsColour = [["ack", "ack", "ack", "wht", "wht", "wht"], ["ack", "wht", "ack", "ack", "wht", "wht"]];
			me.fontMatrix = [[0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0]];
		} elsif (me.type == 2) { 
			me.title = ["VERT REV", " AT ", me.id];
			me.fontMatrix = [[0, 0, 1, 0, 0, 0], [0, 0, 1, 0, 0, 0]];
			me.L1 = ["", "  EFOB ---.-", "wht"];
			me.R1 = ["", "EXTRA ---.- ", "wht"];
			me.L2 = [fmgc.FMGCInternal.clbSpdLim ~ "/" ~ fmgc.FMGCInternal.clbSpdLimAlt, " CLB SPD LIM", "mag"];
			me.speed = me.getSpd();
			if (me.speed[0] == nil) {
				me.L3 = [" [    ]", " SPD CSTR", "blu"];
				me.fontMatrix[0][2] = 1;
			} else {
				me.L3 = [me.speed[0], " SPD CSTR", me.speed[1]];
				me.fontMatrix[0][2] = 0;
			}
			me.L4 = [" CONSTANT MACH", nil, "wht"];
			me.L5 = [" WIND DATA", nil, "wht"];
			me.L6 = [" CLB", nil, "amb"];
			me.R2 = ["RTA ", nil, "wht"];
			me.alt = me.getAlt();
			if (me.alt[0] == nil) {
				me.R3 = ["[      ] ", "ALT CSTR  ", "blu"];
				me.fontMatrix[1][2] = 1;
			} else {
				me.R3 = [me.alt[0], "ALT CSTR  ", me.alt[1]];
				me.fontMatrix[1][2] = 0;
			}
			me.R6 = ["DES ", nil, "amb"];
			# When the system does vertical planning, L6 should be RETURN and R6 not used if the MCDU knows the waypoint is during climb or descent.
			# The CLB or DES prompts should only be shown for a vertical revision in the cruise phase.
			# For now we fake it and allow the user to press either, which both act like RETURN.
			# When CLB/DES are shown, a small "OR" should be shown between them.
			# The 'arrows' for CLB/DES should actually be asterisks.
			me.arrowsMatrix = [[0, 0, 0, 1, 1, 1], [0, 1, 0, 0, 0, 1]];
			me.arrowsColour = [["ack", "ack", "ack", "wht", "wht", "amb"], ["ack", "wht", "ack", "ack", "wht", "amb"]];
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
				me.L2 = [fmgc.FMGCInternal.clbSpdLim ~ "/" ~ fmgc.FMGCInternal.clbSpdLimAlt, " CLB SPD LIM", "mag"];
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
				me.L2 = [fmgc.FMGCInternal.desSpdLim ~ "/" ~ fmgc.FMGCInternal.desSpdLimAlt, " DES SPD LIM", "mag"];
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
				mcdu_message(me.computer, "DIR TO IN PROGRESS");
			}
			me._checkTmpy();
		}
	},
	updateR5: func() {
		if (fmgc.FMGCInternal.crzSet and (fmgc.FMGCInternal.phase < 4 or fmgc.FMGCInternal.phase == 7)) {
			me.R5 = ["STEP ALTS ", nil, "wht"];
			me.arrowsMatrix[1][4] = 1;
		} else {
			me.R5 = [nil, nil, "ack"];
			me.arrowsMatrix[1][4] = 0;
		}
	},
	pushButtonLeft: func(index) {
		scratchpadStore = mcdu_scratchpad.scratchpads[me.computer].scratchpad;
		if (index == 2) {
			if (scratchpadStore == "CLR") {
				if (me.type == 1) {
					fmgc.FMGCInternal.desSpdLim = 250;
					fmgc.FMGCInternal.desSpdLimAlt = 10000;
					fmgc.FMGCInternal.desSpdLimSet = 0;
				} else {
					fmgc.FMGCInternal.clbSpdLim = 250;
					fmgc.FMGCInternal.clbSpdLimAlt = 10000;
					fmgc.FMGCInternal.clbSpdLimSet = 0;
				}
				mcdu_scratchpad.scratchpads[me.computer].empty();
				me._setupPageWithData();
				canvas_mcdu.pageSwitch[me.computer].setBoolValue(0);
			} elsif (find("/", scratchpadStore) != -1) {
				scratchpadSplit = split("/", scratchpadStore);
				if (size(scratchpadSplit[0]) == 3 and num(scratchpadSplit[0]) != nil and size(scratchpadSplit[1]) >= 3 and size(scratchpadSplit[1]) <= 5 and num(scratchpadSplit[1]) != nil) {
					if (scratchpadSplit[0] >= 100 and scratchpadSplit[0] <= 340 and scratchpadSplit[1] >= 100 and scratchpadSplit[1] <= 39000) {
						if (me.type == 1) {
							fmgc.FMGCInternal.desSpdLim = scratchpadSplit[0];
							fmgc.FMGCInternal.desSpdLimSet = 1;
							if (size(scratchpadSplit[1]) != 0) {
								fmgc.FMGCInternal.desSpdLimAlt = scratchpadSplit[1];
							}
						} else {
							fmgc.FMGCInternal.clbSpdLim = scratchpadSplit[0];
							fmgc.FMGCInternal.clbSpdLimSet = 1;
							if (size(scratchpadSplit[1]) != 0) {
								fmgc.FMGCInternal.clbSpdLimAlt = scratchpadSplit[1];
							}
						}
						mcdu_scratchpad.scratchpads[me.computer].empty();
						me._setupPageWithData();
						canvas_mcdu.pageSwitch[me.computer].setBoolValue(0);
					} else {
						mcdu_message(me.computer, "ENTRY OUT OF RANGE");
					}
				} else {
					mcdu_message(me.computer, "FORMAT ERROR");
				}
			} elsif (num(scratchpadStore) != nil and size(scratchpadStore) == 3) {
				if (scratchpadStore >= 100 and scratchpadStore <= 340) {
					if (me.type == 1) {
						fmgc.FMGCInternal.desSpdLim = scratchpadStore;
						fmgc.FMGCInternal.desSpdLimSet = 1;
					} else {
						fmgc.FMGCInternal.clbSpdLim = scratchpadStore;
						fmgc.FMGCInternal.clbSpdLimSet = 1;
					}
					mcdu_scratchpad.scratchpads[me.computer].empty();
					me._setupPageWithData();
					canvas_mcdu.pageSwitch[me.computer].setBoolValue(0);
				} else {
					mcdu_message(me.computer, "ENTRY OUT OF RANGE");
				}
			} else {
				mcdu_message(me.computer, "FORMAT ERROR");
			}
		} elsif (index == 3 and me.type == 2) {
			if (scratchpadStore == "CLR") {
				me.wp.setSpeed("delete");
				mcdu_scratchpad.scratchpads[me.computer].empty();
				me._setupPageWithData();
				canvas_mcdu.pageSwitch[me.computer].setBoolValue(0);
			} elsif (num(scratchpadStore) != nil and size(scratchpadStore) == 3 and scratchpadStore >= 100 and scratchpadStore <= 350) {
				me.wp.setSpeed(scratchpadStore, "at");
				mcdu_scratchpad.scratchpads[me.computer].empty();
				me._setupPageWithData();
				canvas_mcdu.pageSwitch[me.computer].setBoolValue(0);
			} else {
				mcdu_message(me.computer, "FORMAT ERROR");
			}
		} elsif (index == 5) {
			if (me.wp.wp_role == "sid") {
				if (canvas_mcdu.myCLBWIND[me.computer] == nil) {
					canvas_mcdu.myCLBWIND[me.computer] = windCLBPage.new(me.computer);
				} else {
					canvas_mcdu.myCLBWIND[me.computer].reload();
				}
				fmgc.windController.accessPage[me.computer] = "VERTREV";
				setprop("MCDU[" ~ me.computer ~ "]/page", "WINDCLB");
			} else if (me.wp.wp_role == "star" or me.wp.wp_role == "approach" or me.wp.wp_role == "missed") {
				if (canvas_mcdu.myDESWIND[me.computer] == nil) {
					canvas_mcdu.myDESWIND[me.computer] = windDESPage.new(me.computer);
				} else {
					canvas_mcdu.myDESWIND[me.computer].reload();
				}
				fmgc.windController.accessPage[me.computer] = "VERTREV";
				setprop("MCDU[" ~ me.computer ~ "]/page", "WINDDES");
			} else if (me.wp.wp_role == nil and me.wp.wp_type == "navaid") {
				cur_location = 0;
				for (i = 0; i < size(fmgc.windController.nav_indicies[me.plan]); i += 1) {
					if (fmgc.windController.nav_indicies[me.plan][i] == me.index) {
						cur_location = i;
					}
				}
				if (canvas_mcdu.myCRZWIND[me.computer] == nil) {
					canvas_mcdu.myCRZWIND[me.computer] = windCRZPage.new(me.computer, me.wp, cur_location);
				} else {
					canvas_mcdu.myCRZWIND[me.computer].waypoint = me.wp;
					canvas_mcdu.myCRZWIND[me.computer].cur_location = cur_location;
					canvas_mcdu.myCRZWIND[me.computer].reload();
				}
				fmgc.windController.accessPage[me.computer] = "VERTREV";
				setprop("MCDU[" ~ me.computer ~ "]/page", "WINDCRZ");
			} else {
				if (canvas_mcdu.myCRZWIND[me.computer] == nil) {
					canvas_mcdu.myCRZWIND[me.computer] = windCRZPage.new(me.computer, nil, 0);
				} else {
					canvas_mcdu.myCRZWIND[me.computer].reload();
				}
				fmgc.windController.accessPage[me.computer] = "VERTREV";
				setprop("MCDU[" ~ me.computer ~ "]/page", "WINDCRZ");
			}
		} else {
			mcdu_message(me.computer, "NOT ALLOWED");
		}
	},
	pushButtonRight: func(index) {
		scratchpadStore = mcdu_scratchpad.scratchpads[me.computer].scratchpad;
		if (index == 3 and me.type == 2) {
			if (scratchpadStore == "CLR") {
				me.wp.setAltitude("delete");
				mcdu_scratchpad.scratchpads[me.computer].empty();
				me._setupPageWithData();
				canvas_mcdu.pageSwitch[me.computer].setBoolValue(0);
			} else {
				if (right(scratchpadStore, 1) == "+") {
					validateAltCstr(left(scratchpadStore, size(scratchpadStore) - 1), "above", me);
				} elsif (right(scratchpadStore, 1) == "-") {
					validateAltCstr(left(scratchpadStore, size(scratchpadStore) - 1), "below", me);
				} elsif (left(scratchpadStore, 1) == "+") {
					validateAltCstr(right(scratchpadStore, size(scratchpadStore) - 1), "above", me);
				} elsif (left(scratchpadStore, 1) == "-") {
					validateAltCstr(right(scratchpadStore, size(scratchpadStore) - 1), "below", me);
				} else {
					validateAltCstr(scratchpadStore, "at", me);
				}
			}
		}
	},
};

var validateAltCstr = func(scratchpadStore, type, self) {
	if (num(scratchpadStore) != nil and (size(scratchpadStore) >= 3 and size(scratchpadStore) <= 5)) {
		if (scratchpadStore >= 100 and scratchpadStore <= 39000) {
			self.wp.setAltitude(math.round(scratchpadStore, 10), type);
			mcdu_scratchpad.scratchpads[self.computer].empty();
			self._setupPageWithData();
			canvas_mcdu.pageSwitch[self.computer].setBoolValue(0);
		} else {
			mcdu_message(self.computer, "ENTRY OUT OF RANGE");
		}
	} else {
		mcdu_message(self.computer, "FORMAT ERROR");
	}
}

var updateCrzLvlCallback = func () {
	if (canvas_mcdu.myVertRev[0] != nil) { 
		canvas_mcdu.myVertRev[0].updateR5();
	}
	
	if (canvas_mcdu.myVertRev[1] != nil) { 
		canvas_mcdu.myVertRev[1].updateR5();
	}
};

var updatePhaseCallback = func() {
	if (canvas_mcdu.myVertRev[0] != nil) { 
		canvas_mcdu.myVertRev[0].updateR5();
	}
	
	if (canvas_mcdu.myVertRev[1] != nil) { 
		canvas_mcdu.myVertRev[1].updateR5();
	}
};