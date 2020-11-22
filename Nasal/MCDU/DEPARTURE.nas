var isNoSid = [0, 0, 0];
var isNoTransDep = [0, 0, 0];

var departurePage = {
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
	depAirport: nil,
	runways: nil,
	selectedRunway: nil,
	selectedSID: nil,
	selectedTransition: nil,
	computer: nil,
	enableScrollRwy: 0,
	enableScrollSids: 0,
	scrollRwy: 0,
	scrollSids: 0,
	activePage: 0, # runways, sids, trans
	_runways: nil,
	_sids: nil,
	_transitions: nil,
	runways: [],
	sids: [],
	transitions: [],
	new: func(icao, computer) {
		var page = {parents:[departurePage]};
		page.id = icao;
		page.computer = computer;
		page._setupFirstTime();
		page._setupPageWithData();
		return page;
	},
	del: func() {
		return nil;
	},
	reset: func() {
		isNoSid[me.computer] = 0;
		isNoTransDep[me.computer] = 0;
		me.selectedSID = nil;
		me.selectedTransition = nil;
	},
	_setupFirstTime: func() {
		if (!fmgc.flightPlanController.temporaryFlag[me.computer]) {
			if (fmgc.flightPlanController.flightplans[2].departure_runway != nil) {
				me.selectedRunway = fmgc.flightPlanController.flightplans[2].departure_runway;
			}
			if (fmgc.flightPlanController.flightplans[2].sid != nil) {
				me.selectedSID = fmgc.flightPlanController.flightplans[2].sid;
				isNoSid[me.computer] = 0;
			} elsif (isNoSid[2] == 1) {
				me.selectedSID = "NO SID";
			}
			
			if (isNoTransDep[2]) {
				me.selectedTransition = "NO TRANS";
			} elsif (fmgc.flightPlanController.flightplans[2].sid != nil) {
				me.selectedTransition = fmgc.flightPlanController.flightplans[2].sid_trans;
			}
		} else {
			if (fmgc.flightPlanController.flightplans[me.computer].departure_runway != nil) {
				me.selectedRunway = fmgc.flightPlanController.flightplans[me.computer].departure_runway;
			} elsif (fmgc.flightPlanController.flightplans[2].departure_runway != nil) {
				me.selectedRunway = fmgc.flightPlanController.flightplans[2].departure_runway;
			}
			if (fmgc.flightPlanController.flightplans[me.computer].sid != nil) {
				me.selectedSID = fmgc.flightPlanController.flightplans[me.computer].sid;
				isNoSid[me.computer] = 0;
			} elsif (fmgc.flightPlanController.flightplans[2].sid != nil) {
				me.selectedSID = fmgc.flightPlanController.flightplans[2].sid;
				isNoSid[me.computer] = 0;
			} elsif (isNoSid[me.computer] == 1) {
				me.selectedSID = "NO SID";
			}
			
			if (isNoTransDep[me.computer] or isNoTransDep[2]) {
				me.selectedTransition = "NO TRANS";
			} elsif (fmgc.flightPlanController.flightplans[me.computer].sid != nil) {
				me.selectedTransition = fmgc.flightPlanController.flightplans[me.computer].sid_trans;
			} elsif (fmgc.flightPlanController.flightplans[2].sid != nil) {
				me.selectedTransition = fmgc.flightPlanController.flightplans[2].sid_trans;
			}
		}
	},
	_setupPageWithData: func() {
		me.title = ["DEPARTURE", " FROM ", left(me.id, 4)];
		
		me.fontMatrix = [[0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0]];
		me.arrowsMatrix = [[0, 0, 0, 0, 0, 1], [0, 0, 0, 0, 0, 0]];
		me.arrowsColour = [["ack", "ack", "ack", "ack", "ack", "wht"], ["ack", "ack", "ack", "ack", "ack", "ack"]];
		
		if (!fmgc.flightPlanController.temporaryFlag[me.computer]) {
			me.L6 = [" RETURN END", nil, "wht"];
		} else {
			me.L6 = [" F-PLN", " TMPY", "yel"];
			me.arrowsColour[0][5] = "yel";
		}
		
		if (me.activePage == 0) {
			me.updateRunways();
		} else {
			me.updateSIDs();
			me.updateTransitions();
		}
		
		me.updateActiveRunway();
		me.updateActiveSIDs();
		me.updateActiveTransitions();
	},
	_clearPage: func() {
		me.L1 = [nil, nil, "ack"];
		me.L2 = [nil, nil, "ack"];
		me.L3 = [nil, nil, "ack"];
		me.L4 = [nil, nil, "ack"];
		me.L5 = [nil, nil, "ack"];
		me.L6 = [nil, nil, "ack"];
		me.C1 = [nil, nil, "ack"];
		me.C2 = [nil, nil, "ack"];
		me.C3 = [nil, nil, "ack"];
		me.C4 = [nil, nil, "ack"];
		me.C5 = [nil, nil, "ack"];
		me.C6 = [nil, nil, "ack"];
		me.R1 = [nil, nil, "ack"];
		me.R2 = [nil, nil, "ack"];
		me.R3 = [nil, nil, "ack"];
		me.R4 = [nil, nil, "ack"];
		me.R5 = [nil, nil, "ack"];
		me.R6 = [nil, nil, "ack"];
		me.fontMatrix = [[0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0]];
		me.arrowsMatrix = [[0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0]];
		me.arrowsColour = [["ack", "ack", "ack", "ack", "ack", "ack"], ["ack", "ack", "ack", "ack", "ack", "ack"]];
	},
	updatePage: func() {
		me._clearPage();
		me._setupPageWithData();
	},
	updateActiveRunway: func() {
		if (me.selectedRunway != nil) {
			if (fmgc.flightPlanController.temporaryFlag[me.computer]) {
				if (fmgc.flightPlanController.flightplans[me.computer].departure_runway != nil) {
					me.L1 = [fmgc.flightPlanController.flightplans[me.computer].departure_runway.id, " RWY", "yel"];
				} elsif (fmgc.flightPlanController.flightplans[2].departure_runway != nil and fmgc.flightPlanController.flightplans[2].departure_runway.id == me.selectedRunway.id) {
					me.L1 = [fmgc.flightPlanController.flightplans[2].departure_runway.id, " RWY", "yel"];
				} else {
					me.L1 = ["---", " RWY", "wht"];
				} 
			} else {
				if (fmgc.flightPlanController.flightplans[2].departure_runway != nil) {
					me.L1 = [fmgc.flightPlanController.flightplans[2].departure_runway.id, " RWY", "grn"];
				} else {
					me.L1 = ["---", " RWY", "wht"];
				}
			}
		} else {
			me.L1 = ["---", " RWY", "wht"];
		}
		canvas_mcdu.pageSwitch[me.computer].setBoolValue(0);
	},
	updateActiveSIDs: func() {
		if (me.selectedSID == "NO SID") {
			if (!fmgc.flightPlanController.temporaryFlag[me.computer]) {
				me.C1 = ["NONE", "SID", "grn"];
			} else {
				me.C1 = ["NONE", "SID", "yel"];
			}
		} elsif (me.selectedSID != nil) {
			if (fmgc.flightPlanController.temporaryFlag[me.computer]) {
				if (fmgc.flightPlanController.flightplans[me.computer].sid != nil) {
					me.C1 = [fmgc.flightPlanController.flightplans[me.computer].sid.id, "SID", "yel"];
				} elsif (fmgc.flightPlanController.flightplans[2].sid != nil and fmgc.flightPlanController.flightplans[2].sid.id == me.selectedSID.id) {
					me.C1 = [fmgc.flightPlanController.flightplans[2].sid.id, "SID", "yel"];
				} else {
					me.C1 = ["------- ", "SID", "wht"];
				} 
			} else {
				if (fmgc.flightPlanController.flightplans[2].sid != nil) {
				me.C1 = [fmgc.flightPlanController.flightplans[2].sid.id, "SID", "grn"];
				} else {
					me.C1 = ["------- ", "SID", "wht"];
				}
			}
		} else {
			me.C1 = ["------- ", "SID", "wht"];
		}
		canvas_mcdu.pageSwitch[me.computer].setBoolValue(0);
	},
	updateActiveTransitions: func() {
		if (me.selectedTransition == "NO TRANS") {
			if (!fmgc.flightPlanController.temporaryFlag[me.computer]) {
				me.R1 = ["NONE", "TRANS ", "grn"];
			} else {
				me.R1 = ["NONE", "TRANS ", "yel"];
			}
		} else {
			if (me.selectedTransition != nil) {
				if (fmgc.flightPlanController.temporaryFlag[me.computer]) {
					if (fmgc.flightPlanController.flightplans[me.computer].sid_trans != nil) {
						me.R1 = [fmgc.flightPlanController.flightplans[me.computer].sid_trans.id, "TRANS", "yel"];
					} elsif (fmgc.flightPlanController.flightplans[2].sid_trans != nil and fmgc.flightPlanController.flightplans[2].sid_trans.id == me.selectedTransition.id) {
						me.R1 = [fmgc.flightPlanController.flightplans[2].sid_trans.id, "TRANS", "yel"];
					} else {
						me.R1 = ["-------", "TRANS ", "wht"];
					} 
				} else { 
					if (fmgc.flightPlanController.flightplans[2].sid_trans != nil) {
						me.R1 = [fmgc.flightPlanController.flightplans[2].sid_trans.id, "SID", "grn"];
					} else {
						me.R1 = ["-------", "TRANS ", "wht"];
					}
				}
			} else {
				me.R1 = ["-------", "TRANS ", "wht"];
			}
		}
		canvas_mcdu.pageSwitch[me.computer].setBoolValue(0);
	},
	updateRunways: func() {
		if (me.depAirport == nil) {
			me.depAirport = findAirportsByICAO(left(me.id, 4));
		}
		
		me.runways = [];
		me._runways = nil; 
		
		me._runways = keys(me.depAirport[0].runways);
		me.runways = sort(me._runways,func(a,b) cmp(a,b));
		
		if (size(me.runways) >= 1) {
			me.L2 = [" " ~ me.runways[0 + me.scrollRwy], nil, "blu"];
			me.C2 = [math.round(me.depAirport[0].runways[me.runways[0 + me.scrollRwy]].length) ~ "M", "AVAILABLE RUNWAYS", "blu"];
			me.R2 = ["CRS" ~ math.round(me.depAirport[0].runways[me.runways[0 + me.scrollRwy]].heading), nil, "blu"];
			if (me.runways[0 + me.scrollRwy] != me.selectedRunway) {
				me.arrowsMatrix[0][1] = 1;
				me.arrowsColour[0][1] = "blu";
			} else {
				me.arrowsMatrix[0][1] = 0;
				me.arrowsColour[0][1] = "ack";
			}
		}
		if (size(me.runways) >= 2) {
			me.L3 = [" " ~ me.runways[1 + me.scrollRwy], nil, "blu"];
			me.C3 = [math.round(me.depAirport[0].runways[me.runways[1 + me.scrollRwy]].length) ~ "M", nil, "blu"];
			me.R3 = ["CRS" ~ math.round(me.depAirport[0].runways[me.runways[1 + me.scrollRwy]].heading), nil, "blu"];
			if (me.runways[1 + me.scrollRwy] != me.selectedRunway) {
				me.arrowsMatrix[0][2] = 1;
				me.arrowsColour[0][2] = "blu";
			} else {
				me.arrowsMatrix[0][2] = 0;
				me.arrowsColour[0][2] = "ack";
			}
		}
		if (size(me.runways) >= 3) {
			me.L4 = [" " ~ me.runways[2 + me.scrollRwy], nil, "blu"];
			me.C4 = [math.round(me.depAirport[0].runways[me.runways[2 + me.scrollRwy]].length) ~ "M", nil, "blu"];
			me.R4 = ["CRS" ~ math.round(me.depAirport[0].runways[me.runways[2 + me.scrollRwy]].heading), nil, "blu"];
			if (me.runways[2 + me.scrollRwy] != me.selectedRunway) {
				me.arrowsMatrix[0][3] = 1;
				me.arrowsColour[0][3] = "blu";
			} else {
				me.arrowsMatrix[0][3] = 0;
				me.arrowsColour[0][3] = "ack";
			}
		}
		if (size(me.runways) >= 4) {
			me.L5 = [" " ~ me.runways[3 + me.scrollRwy], nil, "blu"];
			me.C5 = [math.round(me.depAirport[0].runways[me.runways[3 + me.scrollRwy]].length) ~ "M", nil, "blu"];
			me.R5 = ["CRS" ~ math.round(me.depAirport[0].runways[me.runways[3 + me.scrollRwy]].heading), nil, "blu"];
			if (me.runways[3 + me.scrollRwy] != me.selectedRunway) {
				me.arrowsMatrix[0][4] = 1;
				me.arrowsColour[0][4] = "blu";
			} else {
				me.arrowsMatrix[0][4] = 0;
				me.arrowsColour[0][4] = "ack";
			}
		}
		
		if (size(me.runways) > 4) {
			me.enableScrollRwy = 1;
		}
		canvas_mcdu.pageSwitch[me.computer].setBoolValue(0);
	},
	updateSIDs: func() {
		if (me.depAirport == nil) {
			me.depAirport = findAirportsByICAO(left(me.id, 4));
		}
		
		me.sids = [];
		me._sids = nil;
		
		if (me.selectedRunway != nil) {
			me._sids = me.depAirport[0].sids(me.selectedRunway.id);
		} else {
			me._sids = me.depAirport[0].sids();
		}
		
		me.sids = sort(me._sids,func(a,b) cmp(a,b));
		
		if (me.sids == nil) {
			me.sids = ["NO SID"];
		} else {
			append(me.sids, "NO SID");
		}
		
		if (size(me.sids) >= 1) {
			me.L2 = [" " ~ me.sids[0 + me.scrollSids], "SIDS", "blu"];
			if (me.sids[0 + me.scrollSids] != me.selectedSID) {
				me.arrowsMatrix[0][1] = 1;
				me.arrowsColour[0][1] = "blu";
			} else {
				me.arrowsMatrix[0][1] = 0;
				me.arrowsColour[0][1] = "ack";
			}
		}
		if (size(me.sids) >= 2) {
			me.L3 = [" " ~ me.sids[1 + me.scrollSids], nil, "blu"];
			if (me.sids[1 + me.scrollSids] != me.selectedSID) {
				me.arrowsMatrix[0][2] = 1;
				me.arrowsColour[0][2] = "blu";
			} else {
				me.arrowsMatrix[0][2] = 0;
				me.arrowsColour[0][2] = "ack";
			}
		}
		if (size(me.sids) >= 3) {
			me.L4 = [" " ~ me.sids[2 + me.scrollSids], nil, "blu"];
			if (me.sids[2 + me.scrollSids] != me.selectedSID) {
				me.arrowsMatrix[0][3] = 1;
				me.arrowsColour[0][3] = "blu";
			} else {
				me.arrowsMatrix[0][3] = 0;
				me.arrowsColour[0][3] = "ack";
			}
		}
		if (size(me.sids) >= 4) {
			me.L5 = [" " ~ me.sids[3 + me.scrollSids], nil, "blu"];
			if (me.sids[3 + me.scrollSids] != me.selectedSID) {
				me.arrowsMatrix[0][4] = 1;
				me.arrowsColour[0][4] = "blu";
			} else {
				me.arrowsMatrix[0][4] = 0;
				me.arrowsColour[0][4] = "ack";
			}
		}
		
		me.C2[1] = "AVAILABLE";
		me.R2[1] = "TRANS ";
		
		if (size(me.sids) > 4) {
			me.enableScrollSids = 1;
		}
		canvas_mcdu.pageSwitch[me.computer].setBoolValue(0);
	},
	clearTransitions: func() {
		me.R2 = [nil, "TRANS", "wht"];
		me.R3 = [nil, "TRANS", "wht"];
		me.R4 = [nil, "TRANS", "wht"];
		me.R5 = [nil, "TRANS", "wht"];
		me.arrowsMatrix[1][1] = 0;
		me.arrowsColour[1][1] = "ack";
		me.arrowsMatrix[1][2] = 0;
		me.arrowsColour[1][2] = "ack";
		me.arrowsMatrix[1][3] = 0;
		me.arrowsColour[1][3] = "ack";
		me.arrowsMatrix[1][4] = 0;
		me.arrowsColour[1][4] = "ack";
	},
	updateTransitions: func() {
		if (me.depAirport == nil) {
			me.depAirport = findAirportsByICAO(left(me.id, 4));
		}
		
		me.clearTransitions();
		if (me.selectedSID == nil or me.selectedSID == "NO SID") {
			append(me.transitions, "NO TRANS");
			return;
		}
		
		if (isghost(me.selectedSID)) {
			me._transitions = me.depAirport[0].getSid(me.selectedSID.id).transitions;
		} else {
			me._transitions = me.depAirport[0].getSid(me.selectedSID).transitions;
		}
		me._transitions = me.depAirport[0].getSid(me.selectedSID).transitions;
		me.transitions = sort(me._transitions,func(a,b) cmp(a,b));
		append(me.transitions, "NO TRANS");
		
		if (size(me.transitions) >= 1) {
			me.R2 = [me.transitions[0] ~ " ", "TRANS", "blu"];
			if (me.transitions[0] != me.selectedTransition) {
				me.arrowsMatrix[1][1] = 1;
				me.arrowsColour[1][1] = "blu";
			} else {
				me.arrowsMatrix[1][1] = 0;
				me.arrowsColour[1][1] = "ack";
			}
		} 
		if (size(me.transitions) >= 2) {
			me.R3 = [me.transitions[1] ~ " ", nil, "blu"];
			if (me.transitions[1] != me.selectedTransition) {
				me.arrowsMatrix[1][2] = 1;
				me.arrowsColour[1][2] = "blu";
			} else {
				me.arrowsMatrix[1][2] = 0;
				me.arrowsColour[1][2] = "ack";
			}
		} 
		if (size(me.transitions) >= 3) {
			me.R4 = [me.transitions[2] ~ " ", nil, "blu"];
			if (me.transitions[2] != me.selectedTransition) {
				me.arrowsMatrix[1][3] = 1;
				me.arrowsColour[1][3] = "blu";
			} else {
				me.arrowsMatrix[1][3] = 0;
				me.arrowsColour[1][3] = "ack";
			}
		} 
		if (size(me.transitions) >= 4) {
			me.R5 = [me.transitions[3] ~ " ", nil, "blu"];
			if (me.transitions[3] != me.selectedTransition) {
				me.arrowsMatrix[1][4] = 1;
				me.arrowsColour[1][4] = "blu";
			} else {
				me.arrowsMatrix[1][4] = 0;
				me.arrowsColour[1][4] = "ack";
			}
		}
		canvas_mcdu.pageSwitch[me.computer].setBoolValue(0);
	},
	makeTmpy: func() {
		if (!fmgc.flightPlanController.temporaryFlag[me.computer]) {
			if (!dirToFlag) {
				fmgc.flightPlanController.createTemporaryFlightPlan(me.computer);
				me.L6 = [" F-PLN", " TMPY", "yel"];
				me.arrowsColour[0][5] = "yel";
				canvas_mcdu.pageSwitch[me.computer].setBoolValue(0);
			} else {
				mcdu_message(me.computer, "DIR TO IN PROGRESS");
            }
		}
	},
	scrollUp: func() {
		if (me.activePage == 0) {
			if (me.enableScrollRwy) {
				me.scrollRwy += 1;
				if (me.scrollRwy > size(me.runways) - 4) {
					me.scrollRwy = 0;
				}
				me.updateRunways();
			}
		} else {
			if (me.enableScrollSids) {
				me.scrollSids += 1;
				if (me.scrollSids > size(me.sids) - 4) {
					me.scrollSids = 0;
				}
				me.updateSIDs();
				if (me.selectedSID == nil or me.selectedSID == "NO SID") {
					me.clearTransitions();
				} else {
					me.updateTransitions();
				}
			}
		}
	},
	scrollDn: func() {
		if (me.activePage == 0) {
			if (me.enableScrollRwy) {
				me.scrollRwy -= 1;
				if (me.scrollRwy < 0) {
					me.scrollRwy = size(me.runways) - 4;
				}
				me.updateRunways();
			}
		} else {
			if (me.enableScrollSids) {
				me.scrollSids -= 1;
				if (me.scrollSids < 0) {
					me.scrollSids = size(me.sids) - 4;
				}
				me.updateSIDs();
				if (me.selectedSID == nil or me.selectedSID == "NO SID") {
					me.clearTransitions();
				} else {
					me.updateTransitions();
				}
			}
		}
	},
	scrollLeft: func() {
		me.activePage = !me.activePage;
		me.updatePage();
	},
	scrollRight: func() {
		me.activePage = !me.activePage;
		me.updatePage();
	},
	depPushbuttonLeft: func(index) {
		if (me.activePage == 0) {
			if (size(me.runways) >= (index - 1)) {
				if (!dirToFlag) {
					me.selectedSID = nil;
					isNoSid[me.computer] = 0;
					isNoTransDep[me.computer] = 0;
					me.selectedRunway = me.depAirport[0].runway(me.runways[index - 2 + me.scrollRwy]);
					me.makeTmpy();
					fmgc.flightPlanController.flightplans[me.computer].departure_runway = me.selectedRunway;
					me.updateRunways();
					me.updatePage();
					fmgc.flightPlanController.flightPlanChanged(me.computer);
					me.scrollRight();
				} else {
					mcdu_message(me.computer, "DIR TO IN PROGRESS");
				}
			} else {
				mcdu_message(me.computer, "NOT ALLOWED");
			}
		} else {
			if (size(me.sids) >= (index - 1)) {
				if (!dirToFlag) {
					me.selectedSID = me.sids[index - 2 + me.scrollSids];
					me.makeTmpy();
					if (me.selectedSID != "NO SID") {
						isNoSid[me.computer] = 0;
						fmgc.flightPlanController.flightplans[me.computer].sid = me.depAirport[0].getSid(me.selectedSID);
					} else {
						isNoSid[me.computer] = 1;
						fmgc.flightPlanController.flightplans[me.computer].sid = nil;
						fmgc.flightPlanController.insertNOSID(me.computer);
					}
					me.updateSIDs();
					if (me.selectedSID != "NO SID") {
						isNoTransDep[me.computer] = 0;
					} else {
						isNoTransDep[me.computer] = 1;
						me.selectedTransition = "NO TRANS";
					}
					me.updatePage();
					fmgc.flightPlanController.flightPlanChanged(me.computer);
				} else {
				mcdu_message(me.computer, "DIR TO IN PROGRESS");
				}
			} else {
				mcdu_message(me.computer, "NOT ALLOWED");
			}
		}
	},
	depPushbuttonRight: func(index) {
		if (size(me.transitions) >= (index -  1)) {
			if (!dirToFlag) {
				me.selectedTransition = me.transitions[index - 2];
				me.makeTmpy();
				if (me.selectedTransition != "NO TRANS") {
					isNoTransDep[me.computer] = 0;
					fmgc.flightPlanController.flightplans[me.computer].sid_trans = me.selectedTransition;
				} else {
					isNoTransDep[me.computer] = 1;
					fmgc.flightPlanController.flightplans[me.computer].sid_trans = nil;
				}
				me.updatePage();
				fmgc.flightPlanController.flightPlanChanged(me.computer);
			} else {
				mcdu_message(me.computer, "DIR TO IN PROGRESS");
			}
		} else {
			mcdu_message(me.computer, "NOT ALLOWED");
		}
	},
};