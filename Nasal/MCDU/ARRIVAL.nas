var arrivalPage = {
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
	arrAirport: nil,
	runways: nil,
	selectedRunway: nil,
	selectedVIA: nil,
	selectedSTAR: nil,
	selectedTransition: nil,
	stars: nil,
	transitions: nil,
	vias: nil,
	computer: nil,
	enableScrollApproach: 0,
	enableScrollStars: 0,
	scrollApproach: 0,
	scrollStars: 0,
	activePage: 0, # runways, stars, trans
	hasPressNoTrans: 0, # temporary
	_approaches: nil,
	_stars: nil,
	_transitions: nil,
	new: func(icao, computer) {
		var lr = {parents:[arrivalPage]};
		lr.id = icao;
		lr.computer = computer;
		lr._setupPageWithData();
		return lr;
	},
	del: func() {
		return nil;
	},
	_setupPageWithData: func() {
		me.title = ["ARRIVAL", " TO ", left(me.id, 4)];
		
		if (!fmgc.flightPlanController.temporaryFlag[me.computer]) {
			if (fmgc.flightPlanController.flightplans[2].destination_runway != nil) {
				me.selectedRunway = fmgc.flightPlanController.flightplans[2].destination_runway;
			}
			if (fmgc.flightPlanController.flightplans[2].star != nil) {
				me.selectedSTAR = fmgc.flightPlanController.flightplans[2].star;
			}
		} else {
			if (fmgc.flightPlanController.flightplans[me.computer].destination_runway != nil) {
				me.selectedRunway = fmgc.flightPlanController.flightplans[me.computer].destination_runway;
			} elsif (fmgc.flightPlanController.flightplans[2].destination_runway != nil) {
				me.selectedRunway = fmgc.flightPlanController.flightplans[2].destination_runway;
			}
			if (fmgc.flightPlanController.flightplans[me.computer].star != nil) {
				me.selectedSTAR = fmgc.flightPlanController.flightplans[me.computer].star;
			} elsif (fmgc.flightPlanController.flightplans[2].star != nil) {
				me.selectedSTAR = fmgc.flightPlanController.flightplans[2].star;
			}
		}
		
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
			me.updateApproaches();
		} else {
			me.updateSTARs();
		}
		
		#me.updateActiveRunway();
		#me.updateActiveSTARs();
		#me.updateActiveTransitions();
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
			if (fmgc.flightPlanController.flightplans[2].destination_runway != nil) {
				if (fmgc.flightPlanController.flightplans[2].destination_runway.id == me.selectedRunway.id) {
					me.L1 = [fmgc.flightPlanController.flightplans[2].destination_runway.id, " APPR", "grn"];
				} elsif (fmgc.flightPlanController.flightplans[me.computer].destination_runway != nil) {
					me.L1 = [fmgc.flightPlanController.flightplans[me.computer].destination_runway.id, " APPR", "yel"];
				} else {
					me.L1 = ["---", " APPR", "wht"];
				} 
			} elsif (fmgc.flightPlanController.flightplans[me.computer].destination_runway != nil) {
				me.L1 = [fmgc.flightPlanController.flightplans[me.computer].destination_runway.id, " APPR", "yel"];
			} else {
				me.L1 = ["---", " APPR", "wht"];
			}
		} else {
			me.L1 = ["---", " APPR", "wht"];
		}
		canvas_mcdu.pageSwitch[me.computer].setBoolValue(0);
	},
	updateActiveSTARs: func() {
		if (me.selectedSTAR != nil) {
			if (fmgc.flightPlanController.flightplans[2].star != nil) {
				if (fmgc.flightPlanController.flightplans[2].star == me.selectedSTAR) {
					me.C1 = [fmgc.flightPlanController.flightplans[2].star.id, "SID", "grn"];
				} elsif (fmgc.flightPlanController.flightplans[me.computer].star != nil) {
					me.C1 = [fmgc.flightPlanController.flightplans[me.computer].star.id, "SID", "yel"];
				} else {
					me.C1 = ["------- ", "SID", "wht"];
				} 
			} elsif (fmgc.flightPlanController.flightplans[me.computer].star.id != nil) {
				me.C1 = [fmgc.flightPlanController.flightplans[me.computer].star.id, "SID", "yel"];
			} else {
				me.C1 = ["------- ", "SID", "wht"];
			}
		} else {
			me.C1 = ["------- ", "SID", "wht"];
		}
		canvas_mcdu.pageSwitch[me.computer].setBoolValue(0);
	},
	updateActiveTransitions: func() {
		if (!me.hasPressNoTrans) {
			if (me.selectedTransition != nil) {
				if (fmgc.flightPlanController.flightplans[2].star_trans != nil) {
					if (fmgc.flightPlanController.flightplans[2].star_trans == me.selectedTransition) {
						me.R1 = [fmgc.flightPlanController.flightplans[2].star_trans.id, "TRANS", "grn"];
					} elsif (fmgc.flightPlanController.flightplans[me.computer].star_trans != nil) {
						me.R1 = [fmgc.flightPlanController.flightplans[me.computer].star_trans.id, "TRANS", "yel"];
					} else {
						me.R1 = ["-------", "TRANS ", "wht"];
					} 
				} elsif (fmgc.flightPlanController.flightplans[me.computer].star_trans != nil) {
					me.C1 = [fmgc.flightPlanController.flightplans[me.computer].star_trans.id, "SID", "yel"];
				} else {
					me.R1 = ["-------", "TRANS ", "wht"];
				}
			} else {
				me.R1 = ["-------", "TRANS ", "wht"];
			}
		} else {
			me.R1 = ["NONE", "TRANS ", "yel"];
		}
		canvas_mcdu.pageSwitch[me.computer].setBoolValue(0);
	},
	updateApproaches: func() {
		if (me.arrAirport == nil) {
			me.arrAirport = findAirportsByICAO(left(me.id, 4));
		}
		me._approaches = keys(me.arrAirport[0].getApproachList());
		me.approaches = sort(me._approaches,func(a,b) cmp(a,b));
		
		if (size(me.approaches) >= 1) {
			me.L3 = [" " ~ me.approaches[0 + me.scrollApproach], " APPR", "blu"];
			me.C3 = [math.round(me.arrAirport[0].runways[me.approaches[0 + me.scrollApproach]].runways[0].length) ~ "M", "AVAILABLE   ", "blu"];
			me.R3 = ["CRS" ~ math.round(me.arrAirport[0].runways[me.approaches[0 + me.scrollApproach]].runways[0].heading), nil, "blu"];
			if (me.approaches[0 + me.scrollApproach] != me.selectedRunway) {
				me.arrowsMatrix[0][1] = 1;
				me.arrowsColour[0][1] = "blu";
			} else {
				me.arrowsMatrix[0][1] = 0;
				me.arrowsColour[0][1] = "ack";
			}
		}
		if (size(me.approaches) >= 2) {
			me.L4 = [" " ~ me.approaches[1 + me.scrollApproach], nil, "blu"];
			me.C4 = [math.round(me.arrAirport[0].runways[me.approaches[1 + me.scrollApproach]].runways[1].length) ~ "M", sprintf("%7.2f", me.arrAirport[0].runways[0 + me.scrollApproach].ils_frequency_mhz), "blu"];
			me.R4 = ["CRS" ~ math.round(me.arrAirport[0].runways[me.approaches[1 + me.scrollApproach]].runways[1].heading), nil, "blu"];
			if (me.approaches[1 + me.scrollApproach] != me.selectedRunway) {
				me.arrowsMatrix[0][2] = 1;
				me.arrowsColour[0][2] = "blu";
			} else {
				me.arrowsMatrix[0][2] = 0;
				me.arrowsColour[0][2] = "ack";
			}
		}
		if (size(me.approaches) >= 3) {
			me.L5 = [" " ~ me.approaches[2 + me.scrollApproach], nil, "blu"];
			me.C5 = [math.round(me.arrAirport[0].runways[me.approaches[2 + me.scrollApproach]].runways[2].length) ~ "M", sprintf("%7.2f", me.arrAirport[0].runways[1 + me.scrollApproach].ils_frequency_mhz), "blu"];
			me.R5 = ["CRS" ~ math.round(me.arrAirport[0].runways[me.approaches[2 + me.scrollApproach]].runways[2].heading), nil, "blu"];
			me.C6[1] = sprintf("%7.2f", me.arrAirport[0].runways[2 + me.scrollApproach].ils_frequency_mhz);
			if (me.approaches[2 + me.scrollApproach] != me.selectedRunway) {
				me.arrowsMatrix[0][2] = 1;
				me.arrowsColour[0][2] = "blu";
			} else {
				me.arrowsMatrix[0][2] = 0;
				me.arrowsColour[0][2] = "ack";
			}
		}
		
		if (size(me.approaches) > 3) {
			me.enableScrollApproach = 1;
		}
		canvas_mcdu.pageSwitch[me.computer].setBoolValue(0);
	},
	updateSTARs: func() {
		if (me.arrAirport == nil) {
			me.arrAirport = findAirportsByICAO(left(me.id, 4));
		}
		if (me.selectedRunway != nil) {
			me._stars = me.arrAirport[0].stars(me.selectedRunway.id);
		} else {
			me._stars = me.arrAirport[0].stars();
		}
		
		me.stars = sort(me._stars,func(a,b) cmp(a,b));
		
		if (size(me.stars) >= 1) {
			me.L2 = [" " ~ me.stars[0 + me.scrollStars], "STARS", "blu"];
			if (me.stars[0 + me.scrollStars] != me.selectedSTAR) {
				me.arrowsMatrix[0][1] = 1;
				me.arrowsColour[0][1] = "blu";
			} else {
				me.arrowsMatrix[0][1] = 0;
				me.arrowsColour[0][1] = "ack";
			}
		}
		if (size(me.stars) >= 2) {
			me.L3 = [" " ~ me.stars[1 + me.scrollStars], nil, "blu"];
			if (me.stars[1 + me.scrollStars] != me.selectedSTAR) {
				me.arrowsMatrix[0][2] = 1;
				me.arrowsColour[0][2] = "blu";
			} else {
				me.arrowsMatrix[0][2] = 0;
				me.arrowsColour[0][2] = "ack";
			}
		}
		if (size(me.stars) >= 3) {
			me.L4 = [" " ~ me.stars[2 + me.scrollStars], nil, "blu"];
			if (me.stars[2 + me.scrollStars] != me.selectedSTAR) {
				me.arrowsMatrix[0][3] = 1;
				me.arrowsColour[0][3] = "blu";
			} else {
				me.arrowsMatrix[0][3] = 0;
				me.arrowsColour[0][3] = "ack";
			}
		}
		if (size(me.stars) >= 4) {
			me.L5 = [" " ~ me.stars[3 + me.scrollStars], nil, "blu"];
			if (me.stars[3 + me.scrollStars] != me.selectedSTAR) {
				me.arrowsMatrix[0][4] = 1;
				me.arrowsColour[0][4] = "blu";
			} else {
				me.arrowsMatrix[0][4] = 0;
				me.arrowsColour[0][4] = "ack";
			}
		}
		
		me.C2 = [nil, "AVAILABLE", "wht"];
		me.R2 = [nil, "TRANS ", "wht"];
		
		if (size(me.stars) > 4) {
			me.enableScrollStars = 1;
		}
		canvas_mcdu.pageSwitch[me.computer].setBoolValue(0);
	},
	updateTransitions: func() {
		if (me.arrAirport == nil) {
			me.arrAirport = findAirportsByICAO(left(me.id, 4));
		}
		
		me._transitions = me.arrAirport[0].getStar(me.selectedSTAR).transitions;
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
			me.R2 = [me.transitions[0] ~ " ", "TRANS", "blu"];
			if (me.transitions[0] != me.selectedTransition) {
				me.arrowsMatrix[1][1] = 1;
				me.arrowsColour[1][1] = "blu";
			} else {
				me.arrowsMatrix[1][1] = 0;
				me.arrowsColour[1][1] = "ack";
			}
		} elsif (size(me.transitions) >= 2) {
			me.R3 = [me.transitions[1] ~ " ", nil, "blu"];
			if (me.transitions[1] != me.selectedTransition) {
				me.arrowsMatrix[1][2] = 1;
				me.arrowsColour[1][2] = "blu";
			} else {
				me.arrowsMatrix[1][2] = 0;
				me.arrowsColour[1][2] = "ack";
			}
		} elsif (size(me.transitions) >= 3) {
			me.R4 = [me.transitions[2] ~ " ", nil, "blu"];
			if (me.transitions[2] != me.selectedTransition) {
				me.arrowsMatrix[1][3] = 1;
				me.arrowsColour[1][3] = "blu";
			} else {
				me.arrowsMatrix[1][3] = 0;
				me.arrowsColour[1][3] = "ack";
			}
		} elsif (size(me.transitions) >= 4) {
			me.R5 = [me.transitions[3] ~ " ", nil, "blu"];
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
			if (me.enableScrollApproach) {
				me.scrollApproach += 1;
				if (me.scrollApproach > size(me.approaches) - 4) {
					me.scrollApproach = 0;
				}
				me.updateApproaches();
			}
		} else {
			if (me.enableScrollStars) {
				me.scrollStars += 1;
				if (me.scrollStars > size(me.stars) - 4) {
					me.scrollStars = 0;
				}
				me.updateSTARs();
			}
		}
	},
	scrollDn: func() {
		if (me.activePage == 0) {
			if (me.enableScrollApproach) {
				me.scrollApproach -= 1;
				if (me.scrollApproach < 0) {
					me.scrollApproach = size(me.approaches) - 4;
				}
				me.updateApproaches();
			}
		} else {
			if (me.enableScrollStars) {
				me.scrollStars -= 1;
				if (me.scrollStars < 0) {
					me.scrollStars = size(me.stars) - 4;
				}
				me.updateSTARs();
				me.hasPressNoTrans = 0;
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
			if (size(me.approaches) >= (index - 1)) {
				me.selectedRunway = me.arrAirport[0].runway(me.approaches[index - 2 + me.scrollApproach]);
				me.makeTmpy();
				fmgc.flightPlanController.flightplans[me.computer].destination_runway = me.selectedRunway;
				me.updateActiveRunway();
				me.updateApproaches();
				fmgc.flightPlanController.flightPlanChanged(me.computer);
				me.scrollRight();
			} else {
				notAllowed(me.computer);
			}
		} else {
			if (size(me.stars) >= (index - 1)) {
				me.selectedSTAR = me.stars[index - 2 + me.scrollStars];
				me.makeTmpy();
				fmgc.flightPlanController.flightplans[me.computer].star = me.selectedSTAR;
				me.updateActiveSTARs();
				me.updateSTARs();
				me.hasPressNoTrans = 0;
				me.updateTransitions();
				me.updateActiveTransitions();
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
		} elsif (size(me.transitions) >= (index -  1)) {
			me.selectedTransition = me.transitions[index - 2];
			me.makeTmpy();
			fmgc.flightPlanController.flightplans[me.computer].star_trans = me.selectedTransition;
			me.updateActiveTransitions();
			me.updateTransitions();
			fmgc.flightPlanController.flightPlanChanged(me.computer);
		} else {
			notAllowed(me.computer);
		}
	},
};