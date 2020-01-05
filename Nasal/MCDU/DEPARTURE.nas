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
	sids: nil,
	transitions: nil,
	computer: nil,
	enableScrollRwy: 0,
	enableScrollSids: 0,
	scrollRwy: 0,
	scrollSids: 0,
	activePage: 0, # runways, sids, trans
	hasPressNoTrans: 0, # temporary
	_runways: nil,
	_sids: nil,
	_transitions: nil,
	new: func(icao, computer) {
		var lr = {parents:[departurePage]};
		lr.id = icao;
		lr.computer = computer;
		lr._setupPageWithData();
		return lr;
	},
	del: func() {
		return nil;
	},
	_setupPageWithData: func() {
		me.title = ["DEPARTURE", " FROM ", left(me.id, 4)];
		if (!fmgc.flightPlanController.temporaryFlag[me.computer]) {
			me.L6 = [" RETURN END", nil, "wht"];
		} else {
			me.L6 = [" F-PLN", " TMPY", "yel"];
			me.arrowsColour[0][5] = "yel";
		}
		
		if (!fmgc.flightPlanController.temporaryFlag[me.computer]) {
			if (fmgc.flightPlanController.flightplans[2].departure_runway != nil) {
				me.selectedRunway = fmgc.flightPlanController.flightplans[2].departure_runway;
			}
			if (fmgc.flightPlanController.flightplans[2].sid != nil) {
				me.selectedSID = fmgc.flightPlanController.flightplans[2].sid;
			}
		} else {
			if (fmgc.flightPlanController.flightplans[me.computer].departure_runway != nil) {
				me.selectedRunway = fmgc.flightPlanController.flightplans[me.computer].departure_runway;
			} elsif (fmgc.flightPlanController.flightplans[2].departure_runway != nil) {
				me.selectedRunway = fmgc.flightPlanController.flightplans[2].departure_runway;
			}
			if (fmgc.flightPlanController.flightplans[me.computer].sid != nil) {
				me.selectedSID = fmgc.flightPlanController.flightplans[me.computer].sid;
			} elsif (fmgc.flightPlanController.flightplans[2].sid != nil) {
				me.selectedSID = fmgc.flightPlanController.flightplans[2].sid;
			}
		}
		
		me.fontMatrix = [[0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0]];
		me.arrowsMatrix = [[0, 0, 0, 0, 0, 1], [0, 0, 0, 0, 0, 0]];
		me.arrowsColour = [["ack", "ack", "ack", "ack", "ack", "wht"], ["ack", "ack", "ack", "ack", "ack", "ack"]];
		
		if (me.activePage == 0) {
			me.updateRunways();
		} else {
			me.updateSIDs();
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
			if (fmgc.flightPlanController.flightplans[2].departure_runway != nil) {
				if (fmgc.flightPlanController.flightplans[2].departure_runway.id == me.selectedRunway.id) {
					me.L1 = [fmgc.flightPlanController.flightplans[2].departure_runway.id, " RWY", "grn"];
				} elsif (fmgc.flightPlanController.flightplans[me.computer].departure_runway != nil) {
					me.L1 = [fmgc.flightPlanController.flightplans[me.computer].departure_runway.id, " RWY", "yel"];
				} else {
					me.L1 = ["---", " RWY", "wht"];
				} 
			} elsif (fmgc.flightPlanController.flightplans[me.computer].departure_runway != nil) {
				me.L1 = [fmgc.flightPlanController.flightplans[me.computer].departure_runway.id, " RWY", "yel"];
			} else {
				me.L1 = ["---", " RWY", "wht"];
			}
		} else {
			me.L1 = ["---", " RWY", "wht"];
		}
		canvas_mcdu.pageSwitch[me.computer].setBoolValue(0);
	},
	updateActiveSIDs: func() {
		if (me.selectedSID != nil) {
			if (fmgc.flightPlanController.flightplans[2].sid != nil) {
				if (fmgc.flightPlanController.flightplans[2].sid == me.selectedSID) {
					me.C1 = [fmgc.flightPlanController.flightplans[2].sid.id, "SID", "grn"];
				} elsif (fmgc.flightPlanController.flightplans[me.computer].sid != nil) {
					me.C1 = [fmgc.flightPlanController.flightplans[me.computer].sid.id, "SID", "yel"];
				} else {
					me.C1 = ["------- ", "SID", "wht"];
				} 
			} elsif (fmgc.flightPlanController.flightplans[me.computer].sid.id != nil) {
				me.C1 = [fmgc.flightPlanController.flightplans[me.computer].sid.id, "SID", "yel"];
			} else {
				me.C1 = ["------- ", "SID", "wht"];
			}
		} else {
			me.C1 = ["------- ", "SID", "wht"];
		}
		canvas_mcdu.pageSwitch[me.computer].setBoolValue(0);
	},
	updateActiveTransitions: func() {
		if (me.selectedTransition != nil) {
			if (fmgc.flightPlanController.flightplans[2].sid_trans != nil) {
				if (fmgc.flightPlanController.flightplans[2].sid_trans == me.selectedTransition) {
					me.R1 = [fmgc.flightPlanController.flightplans[2].sid_trans.id, "TRANS", "grn"];
				} elsif (fmgc.flightPlanController.flightplans[me.computer].sid_trans != nil) {
					me.R1 = [fmgc.flightPlanController.flightplans[me.computer].sid_trans.id, "TRANS", "yel"];
				} else {
					me.R1 = ["-------", "TRANS ", "wht"];
				} 
			} elsif (fmgc.flightPlanController.flightplans[me.computer].sid_trans != nil) {
				me.C1 = [fmgc.flightPlanController.flightplans[me.computer].sid_trans.id, "SID", "yel"];
			} else {
				me.R1 = ["-------", "TRANS ", "wht"];
			}
		} else {
			me.R1 = ["-------", "TRANS ", "wht"];
		}
		canvas_mcdu.pageSwitch[me.computer].setBoolValue(0);
	},
	updateRunways: func() {
		if (me.depAirport == nil) {
			me.depAirport = findAirportsByICAO(left(me.id, 4));
		}
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
		if (me.selectedRunway != nil) {
			me._sids = me.depAirport[0].sids(me.selectedRunway.id);
		} else {
			me._sids = me.depAirport[0].sids();
		}
		
		me.sids = sort(me._sids,func(a,b) cmp(a,b));
		
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
		
		me.C2 = [nil, "AVAILABLE", "wht"];
		me.R2 = [nil, "TRANS ", "wht"];
		
		if (size(me.sids) > 4) {
			me.enableScrollSids = 1;
		}
		canvas_mcdu.pageSwitch[me.computer].setBoolValue(0);
	},
	updateTransitions: func() {
		if (me.depAirport == nil) {
			me.depAirport = findAirportsByICAO(left(me.id, 4));
		}
		
		me._transitions = me.depAirport[0].getSid(me.selectedSID).transitions;
		me.transitions = sort(me._transitions,func(a,b) cmp(a,b));
		
		if (size(me.transitions) == 0) {
			me.R2 = ["NO TRANS ", "TRANS", "blu"];
			if (!me.hasPressNoTrans) {
				me.arrowsMatrix[1][1] = 1;
				me.arrowsColour[1][1] = "blu";
			} else {
				me.arrowsMatrix[1][1] = 0;
				me.arrowsColour[1][1] = "ack";
			}
		} elsif (size(me.transitions) >= 1) {
			me.R2 = [" " ~ me.transitions[0], "TRANS", "blu"];
			if (me.transitions[0] != me.selectedTransition) {
				me.arrowsMatrix[1][1] = 1;
				me.arrowsColour[1][1] = "blu";
			} else {
				me.arrowsMatrix[1][1] = 0;
				me.arrowsColour[1][1] = "ack";
			}
		} elsif (size(me.transitions) >= 2) {
			me.R3 = [" " ~ me.transitions[1], nil, "blu"];
			if (me.transitions[1] != me.selectedTransition) {
				me.arrowsMatrix[1][2] = 1;
				me.arrowsColour[1][2] = "blu";
			} else {
				me.arrowsMatrix[1][2] = 0;
				me.arrowsColour[1][2] = "ack";
			}
		} elsif (size(me.transitions) >= 3) {
			me.R4 = [" " ~ me.transitions[2], nil, "blu"];
			if (me.transitions[2] != me.selectedTransition) {
				me.arrowsMatrix[1][3] = 1;
				me.arrowsColour[1][3] = "blu";
			} else {
				me.arrowsMatrix[1][3] = 0;
				me.arrowsColour[1][3] = "ack";
			}
		} elsif (size(me.transitions) >= 4) {
			me.R5 = [" " ~ me.transitions[3], nil, "blu"];
			if (me.transitions[3] != me.selectedTransition) {
				me.arrowsMatrix[1][4] = 1;
				me.arrowsColour[1][4] = "blu";
			} else {
				me.arrowsMatrix[1][4] = 0;
				me.arrowsColour[1][4] = "ack";
			}
		}
	},
	makeTmpy: func() {
		if (!fmgc.flightPlanController.temporaryFlag[me.computer]) {
			fmgc.flightPlanController.createTemporaryFlightPlan(me.computer);
			me.L6 = [" F-PLN", " TMPY", "yel"];
			me.arrowsColour[0][5] = "yel";
			canvas_mcdu.pageSwitch[me.computer].setBoolValue(0);
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
				me.selectedRunway = me.depAirport[0].runway(me.runways[index - 2 + me.scrollRwy]);
				me.makeTmpy();
				fmgc.flightPlanController.flightplans[me.computer].departure_runway = me.selectedRunway;
				me.updateActiveRunway();
				me.updateRunways();
				fmgc.flightPlanController.flightPlanChanged(me.computer);
				me.scrollRight();
			} else {
				notAllowed(me.computer);
			}
		} else {
			if (size(me.sids) >= (index - 1)) {
				me.selectedSID = me.sids[index - 2 + me.scrollSids];
				me.makeTmpy();
				fmgc.flightPlanController.flightplans[me.computer].sid = me.selectedSID;
				me.updateActiveSIDs();
				me.updateSIDs();
				me.updateTransitions();
				fmgc.flightPlanController.flightPlanChanged(me.computer);
			} else {
				notAllowed(me.computer);
			}
		}
	},
	depPushbuttonRight: func(index) {
		if (index == 2 and size(me.transitions) == 0) {
			me.hasPressNoTrans = 1;
			me.updateActiveTransitions();
			me.updateTransitions();
		} else {
			me.selectedTransition = me.transitions[index - 2];
			me.makeTmpy();
			fmgc.flightPlanController.flightplans[me.computer].sid_trans = me.selectedTransition;
			me.updateActiveTransitions();
			me.updateTransitions();
			fmgc.flightPlanController.flightPlanChanged(me.computer);
		}
	},
};