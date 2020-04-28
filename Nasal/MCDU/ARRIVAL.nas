var isNoStar = [0, 0];

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
	apprIsRwyFlag: nil,
	arrAirport: nil,
	runways: nil,
	selectedApproach: nil,
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
		var page = {parents:[arrivalPage]};
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
		isNoStar[me.computer] = 0;
		me.selectedSTAR = nil;
		me.hasPressNoTrans = 0;
	},
	_setupFirstTime: func() {
		if (!fmgc.flightPlanController.temporaryFlag[me.computer]) {
			if (fmgc.flightPlanController.flightplans[2].approach != nil) {
				me.selectedApproach = fmgc.flightPlanController.flightplans[2].approach;
			}
			if (fmgc.flightPlanController.flightplans[2].star != nil) {
				me.selectedSTAR = fmgc.flightPlanController.flightplans[2].star;
				isNoStar[me.computer] = 0;
			} elsif (isNoStar[me.computer] == 1) {
				me.selectedSTAR = "NO STAR";
				me.hasPressNoTrans = 1;
			}
		} else {
			if (fmgc.flightPlanController.flightplans[me.computer].approach != nil) {
				me.selectedApproach = fmgc.flightPlanController.flightplans[me.computer].approach;
			} elsif (fmgc.flightPlanController.flightplans[2].approach != nil) {
				me.selectedApproach = fmgc.flightPlanController.flightplans[2].approach;
			}
			if (fmgc.flightPlanController.flightplans[me.computer].star != nil) {
				me.selectedSTAR = fmgc.flightPlanController.flightplans[me.computer].star;
				isNoStar[me.computer] = 0;
			} elsif (fmgc.flightPlanController.flightplans[2].star != nil) {
				me.selectedSTAR = fmgc.flightPlanController.flightplans[2].star;
				isNoStar[me.computer] = 0;
			} elsif (isNoStar[me.computer] == 1) {
				me.selectedSTAR = "NO STAR";
				me.hasPressNoTrans = 1;
			}
		}
	},
	_setupPageWithData: func() {
		me.title = ["ARRIVAL", " TO ", left(me.id, 4)];
		
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
		
		me.updateActiveApproach();
		me.updateActiveSTARs();
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
	updateActiveApproach: func() {
		if (me.apprIsRwyFlag) {
			if (!fmgc.flightPlanController.temporaryFlag[me.computer]) {
				if (fmgc.flightPlanController.flightplans[me.computer].destination_runway != nil) {
					me.L1 = [fmgc.flightPlanController.flightplans[me.computer].destination_runway.id, " APPR", "yel"];
				} elsif (fmgc.flightPlanController.flightplans[2].destination_runway != nil) {
					me.L1 = [fmgc.flightPlanController.flightplans[2].destination_runway.id, " APPR", "grn"];
				} else {
					me.L1 = ["---", " APPR", "wht"];
				}
			} else {
				if (fmgc.flightPlanController.flightplans[me.computer].destination_runway != nil) {
					me.L1 = [fmgc.flightPlanController.flightplans[me.computer].destination_runway.id, " APPR", "yel"];
				} else {
					me.L1 = ["---", " APPR", "wht"];
				}
			}
		} elsif (me.selectedApproach != nil) {
			if (fmgc.flightPlanController.flightplans[2].approach != nil) {
				if (fmgc.flightPlanController.flightplans[me.computer].approach != nil) {
					me.L1 = [fmgc.flightPlanController.flightplans[me.computer].approach.id, " APPR", "yel"];
				} elsif (fmgc.flightPlanController.flightplans[2].approach.id == me.selectedApproach.id) {
					me.L1 = [fmgc.flightPlanController.flightplans[2].approach.id, " APPR", "grn"];
				} else {
					me.L1 = ["---", " APPR", "wht"];
				} 
			} elsif (fmgc.flightPlanController.flightplans[me.computer].approach != nil) {
				me.L1 = [fmgc.flightPlanController.flightplans[me.computer].approach.id, " APPR", "yel"];
			} else {
				me.L1 = ["---", " APPR", "wht"];
			}
		} else {
			me.L1 = ["---", " APPR", "wht"];
		}
		canvas_mcdu.pageSwitch[me.computer].setBoolValue(0);
	},
	updateActiveSTARs: func() {
		if (me.selectedSTAR == "NO STAR") {
			if (!fmgc.flightPlanController.temporaryFlag[me.computer]) {
				me.C1 = ["NONE", "STAR", "grn"];
			} else {
				me.C1 = ["NONE", "STAR", "yel"];
			}
		} elsif (me.selectedSTAR != nil) {
			if (fmgc.flightPlanController.flightplans[2].star != nil) {
				if (fmgc.flightPlanController.flightplans[me.computer].star != nil) {
					me.C1 = [fmgc.flightPlanController.flightplans[me.computer].star.id, "STAR", "yel"];
				} elsif (fmgc.flightPlanController.flightplans[2].star.id == me.selectedSTAR.id) {
					me.C1 = [fmgc.flightPlanController.flightplans[2].star.id, "STAR", "grn"];
				} else {
					me.C1 = ["------- ", "STAR", "wht"];
				} 
			} elsif (fmgc.flightPlanController.flightplans[me.computer].star.id != nil) {
				me.C1 = [fmgc.flightPlanController.flightplans[me.computer].star.id, "STAR", "yel"];
			} else {
				me.C1 = ["------- ", "STAR", "wht"];
			}
		} else {
			me.C1 = ["------- ", "STAR", "wht"];
		}
		canvas_mcdu.pageSwitch[me.computer].setBoolValue(0);
	},
	updateActiveTransitions: func() {
		if (!me.hasPressNoTrans) {
			if (me.selectedTransition != nil) {
				if (fmgc.flightPlanController.flightplans[2].star_trans != nil) {
					if (fmgc.flightPlanController.flightplans[me.computer].star_trans != nil) {
						me.R1 = [fmgc.flightPlanController.flightplans[me.computer].star_trans.id, "TRANS", "yel"];
					} elsif (fmgc.flightPlanController.flightplans[2].star_trans.id == me.selectedTransition.id) {
						me.R1 = [fmgc.flightPlanController.flightplans[2].star_trans.id, "TRANS", "grn"];
					} else {
						me.R1 = ["-------", "TRANS ", "wht"];
					} 
				} elsif (fmgc.flightPlanController.flightplans[me.computer].star_trans != nil) {
					me.C1 = [fmgc.flightPlanController.flightplans[me.computer].star_trans.id, "STAR", "yel"];
				} else {
					me.R1 = ["-------", "TRANS ", "wht"];
				}
			} else {
				me.R1 = ["-------", "TRANS ", "wht"];
			}
		} else {
			if (!fmgc.flightPlanController.temporaryFlag[me.computer]) {
				me.R1 = ["NONE", "TRANS ", "grn"];
			} else {
				me.R1 = ["NONE", "TRANS ", "yel"];
			}
		}
		canvas_mcdu.pageSwitch[me.computer].setBoolValue(0);
	},
	updateApproaches: func() {
		me.apprIsRwyFlag = 0;
		if (me.arrAirport == nil) {
			me.arrAirport = findAirportsByICAO(left(me.id, 4));
		}
		me._approaches = me.arrAirport[0].getApproachList();
		me.approaches = sort(me._approaches,func(a,b) cmp(a,b));
		if (me.approaches == nil or size(me.approaches) == 0) {
			me.apprIsRwyFlag = 1;
			me._approaches = me.arrAirport[0].runways;
			me.approaches = sort(keys(me._approaches),func(a,b) cmp(a,b));
		}
		if (!me.apprIsRwyFlag) {
			if (size(me.approaches) >= 1) {
				me.L3 = [" " ~ me.approaches[0 + me.scrollApproach], " APPR", "blu"];
				me.C3 = [math.round(me.arrAirport[0].runways[me.arrAirport[0].getIAP(me.approaches[0 + me.scrollApproach]).runways[0]].length) ~ "M", "AVAILABLE   ", "blu"];
				me.R3 = ["CRS" ~ math.round(me.arrAirport[0].runways[me.arrAirport[0].getIAP(me.approaches[0 + me.scrollApproach]).runways[0]].heading), nil, "blu"];
				if (me.approaches[0 + me.scrollApproach] != me.selectedApproach) {
					me.arrowsMatrix[0][2] = 1;
					me.arrowsColour[0][2] = "blu";
				} else {
					me.arrowsMatrix[0][2] = 0;
					me.arrowsColour[0][2] = "ack";
				}
			}
			if (size(me.approaches) >= 2) {
				me.L4 = [" " ~ me.approaches[1 + me.scrollApproach], nil, "blu"];
				if (me.arrAirport[0].getIAP(me.approaches[0 + me.scrollApproach]).radio == "ILS") {
					me.C4 = [math.round(me.arrAirport[0].runways[me.arrAirport[0].getIAP(me.approaches[1 + me.scrollApproach]).runways[0]].length) ~ "M", me.arrAirport[0].runways[me.arrAirport[0].getIAP(me.approaches[0 + me.scrollApproach]).runways[0]].ils.id ~ "/" ~ sprintf("%7.2f", me.arrAirport[0].runways[me.arrAirport[0].getIAP(me.approaches[0 + me.scrollApproach]).runways[0]].ils_frequency_mhz), "blu"];
				} else {
					me.C4 = [math.round(me.arrAirport[0].runways[me.arrAirport[0].getIAP(me.approaches[1 + me.scrollApproach]).runways[0]].length) ~ "M", nil, "blu"];
				}
				me.R4 = ["CRS" ~ math.round(me.arrAirport[0].runways[me.arrAirport[0].getIAP(me.approaches[1 + me.scrollApproach]).runways[0]].heading), nil, "blu"];
				if (me.approaches[1 + me.scrollApproach] != me.selectedApproach) {
					me.arrowsMatrix[0][3] = 1;
					me.arrowsColour[0][3] = "blu";
				} else {
					me.arrowsMatrix[0][3] = 0;
					me.arrowsColour[0][3] = "ack";
				}
			}
			if (size(me.approaches) >= 3) {
				me.L5 = [" " ~ me.approaches[2 + me.scrollApproach], nil, "blu"];
				if (me.arrAirport[0].getIAP(me.approaches[1 + me.scrollApproach]).radio == "ILS") {
					me.C5 = [math.round(me.arrAirport[0].runways[me.arrAirport[0].getIAP(me.approaches[2 + me.scrollApproach]).runways[0]].length) ~ "M", me.arrAirport[0].runways[me.arrAirport[0].getIAP(me.approaches[1 + me.scrollApproach]).runways[0]].ils.id ~ "/" ~ sprintf("%7.2f", me.arrAirport[0].runways[me.arrAirport[0].getIAP(me.approaches[1 + me.scrollApproach]).runways[0]].ils_frequency_mhz), "blu"];
				} else {
					me.C5 = [math.round(me.arrAirport[0].runways[me.arrAirport[0].getIAP(me.approaches[2 + me.scrollApproach]).runways[0]].length) ~ "M", nil, "blu"];
				}
				me.R5 = ["CRS" ~ math.round(me.arrAirport[0].runways[me.arrAirport[0].getIAP(me.approaches[2 + me.scrollApproach]).runways[0]].heading), nil, "blu"];
				if (me.arrAirport[0].getIAP(me.approaches[2 + me.scrollApproach]).radio == "ILS") {
					me.C6[1] = me.arrAirport[0].runways[me.arrAirport[0].getIAP(me.approaches[2 + me.scrollApproach]).runways[0]].ils.id ~ "/" ~ sprintf("%7.2f", me.arrAirport[0].runways[me.arrAirport[0].getIAP(me.approaches[2 + me.scrollApproach]).runways[0]].ils_frequency_mhz);
				}
				if (me.approaches[2 + me.scrollApproach] != me.selectedApproach) {
					me.arrowsMatrix[0][4] = 1;
					me.arrowsColour[0][4] = "blu";
				} else {
					me.arrowsMatrix[0][3] = 0;
					me.arrowsColour[0][3] = "ack";
				}
			}
		} else {
			# show runways, not IAPS if no approaches. Not realistic but people with no navigraph keep complaining
			if (size(me.approaches) >= 1) {
				me.L3 = [" " ~ me._approaches[me.approaches[0 + me.scrollApproach]].id, " RWY", "blu"];
				me.C3 = [math.round(me._approaches[me.approaches[0 + me.scrollApproach]].length) ~ "M", "AVAILABLE   ", "blu"];
				me.R3 = ["CRS" ~ math.round(me._approaches[me.approaches[0 + me.scrollApproach]].heading), nil, "blu"];
				if (me.approaches[0 + me.scrollApproach] != me.selectedApproach) {
					me.arrowsMatrix[0][2] = 1;
					me.arrowsColour[0][2] = "blu";
				} else {
					me.arrowsMatrix[0][2] = 0;
					me.arrowsColour[0][2] = "ack";
				}
			}
			if (size(me.approaches) >= 2) {
				me.L4 = [" " ~ me._approaches[me.approaches[1 + me.scrollApproach]].id, nil, "blu"];
				if (me._approaches[me.approaches[0 + me.scrollApproach]].ils != nil) {
					me.C4 = [math.round(me._approaches[me.approaches[1 + me.scrollApproach]].length) ~ "M", me._approaches[me.approaches[0 + me.scrollApproach]].ils.id ~ "/" ~ sprintf("%7.2f", me._approaches[me.approaches[0 + me.scrollApproach]].ils_frequency_mhz), "blu"];
				} else {
					me.C4 = [math.round(me._approaches[me.approaches[1 + me.scrollApproach]].length) ~ "M", nil, "blu"];
				}
				me.R4 = ["CRS" ~ math.round(me._approaches[me.approaches[1 + me.scrollApproach]].heading), nil, "blu"];
				if (me.approaches[1 + me.scrollApproach] != me.selectedApproach) {
					me.arrowsMatrix[0][3] = 1;
					me.arrowsColour[0][3] = "blu";
				} else {
					me.arrowsMatrix[0][3] = 0;
					me.arrowsColour[0][3] = "ack";
				}
			}
			if (size(me.approaches) >= 3) {
				me.L5 = [" " ~ me._approaches[me.approaches[2 + me.scrollApproach]].id, nil, "blu"];
				if (me._approaches[me.approaches[1 + me.scrollApproach]].ils != nil) {
					me.C5 = [math.round(me._approaches[me.approaches[2 + me.scrollApproach]].length) ~ "M", me._approaches[me.approaches[1 + me.scrollApproach]].ils.id ~ "/" ~ sprintf("%7.2f", me._approaches[me.approaches[1 + me.scrollApproach]].ils_frequency_mhz), "blu"];
				} else {
					me.C5 = [math.round(me._approaches[me.approaches[2 + me.scrollApproach]].length) ~ "M", nil, "blu"];
				}
				me.R5 = ["CRS" ~ math.round(me._approaches[me.approaches[2 + me.scrollApproach]].heading), nil, "blu"];
				if (me._approaches[me.approaches[2 + me.scrollApproach]].ils != nil) {
					me.C6[1] = me._approaches[me.approaches[1 + me.scrollApproach]].ils.id ~ "/" ~ sprintf("%7.2f", me._approaches[me.approaches[1 + me.scrollApproach]].ils_frequency_mhz);
				}
				if (me.approaches[2 + me.scrollApproach] != me.selectedApproach) {
					me.arrowsMatrix[0][4] = 1;
					me.arrowsColour[0][4] = "blu";
				} else {
					me.arrowsMatrix[0][4] = 0;
					me.arrowsColour[0][4] = "ack";
				}
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
		if (me.selectedApproach != nil) {
			me._stars = me.arrAirport[0].stars(me.selectedApproach.runways[0]);
		} else {
			me._stars = me.arrAirport[0].stars();
		}
		
		me.stars = sort(me._stars,func(a,b) cmp(a,b));
		if (me.stars == nil) {
			me.stars = ["NO STAR"];
		} else {
			append(me.stars, "NO STAR");
		}
		
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
		if (me.arrAirport == nil) {
			me.arrAirport = findAirportsByICAO(left(me.id, 4));
		}
		if (me.selectedSTAR == nil) {
			me.R2 = ["NO TRANS ", "TRANS", "blu"];
			if (!me.hasPressNoTrans) {
				me.arrowsMatrix[1][1] = 1;
				me.arrowsColour[1][1] = "blu";
			} else {
				me.arrowsMatrix[1][1] = 0;
				me.arrowsColour[1][1] = "ack";
			}
			return;
		}
		if (me.selectedSTAR == "NO STAR") {
		
			return;
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
			if (!dirToFlag) {
				fmgc.flightPlanController.createTemporaryFlightPlan(me.computer);
				me.L6 = [" F-PLN", " TMPY", "yel"];
				me.arrowsColour[0][5] = "yel";
				canvas_mcdu.pageSwitch[me.computer].setBoolValue(0);
			} else {
				setprop("MCDU[" ~ i ~ "]/scratchpad-msg", 1);
                setprop("MCDU[" ~ i ~ "]/scratchpad", "DIR TO IN PROGRESS");
			}
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
				if (me.selectedSTAR == nil or me.selectedSTAR == "NO STAR") {
					me.clearTransitions();
				} else {
					me.updateTransitions();
				}
				me.hasPressNoTrans = 0;
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
				if (me.selectedSTAR == nil or me.selectedSTAR == "NO STAR") {
					me.clearTransitions();
				} else {
					me.updateTransitions();
				}
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
	arrPushbuttonLeft: func(index) {
		if (me.activePage == 0) {
			if (size(me.approaches) >= (index - 2) and index != 2) {
				if (!dirToFlag) {
					me.selectedSTAR = nil;
					me.hasPressNoTrans = 0;
					isNoStar[me.computer] = 0;
					me.makeTmpy();
					if (!me.apprIsRwyFlag) {
						me.selectedApproach = me.arrAirport[0].getIAP(me.approaches[index - 3 + me.scrollApproach]);
						fmgc.flightPlanController.flightplans[me.computer].destination_runway = me.arrAirport[0].runways[me.selectedApproach.runways[0]];
						fmgc.flightPlanController.flightplans[me.computer].approach = me.selectedApproach;
					} else {
						me.selectedApproach = me.arrAirport[0].runways[index - 3 + me.scrollApproach];
						fmgc.flightPlanController.flightplans[me.computer].destination_runway = me.arrAirport[0].runway(me.approaches[index - 3 + me.scrollApproach]);
					}
					setprop("FMGC/internal/baro", 99999);
					setprop("FMGC/internal/radio", 99999);
					setprop("FMGC/internal/radio-no", 0);
					me.updateActiveApproach();
					me.updateApproaches();
					fmgc.flightPlanController.flightPlanChanged(me.computer);
					me.scrollRight();
				} else {
					setprop("MCDU[" ~ me.computer ~ "]/scratchpad-msg", 1);
					setprop("MCDU[" ~ me.computer ~ "]/scratchpad", "DIR TO IN PROGRESS");
				}
			} else {
				notAllowed(me.computer);
			}
		} else {
			if (size(me.stars) >= (index - 2)) {
				if (!dirToFlag) {
					me.selectedSTAR = me.stars[index - 2 + me.scrollStars];
					me.makeTmpy();
					if (me.selectedSTAR != "NO STAR") {
						isNoStar[me.computer] = 0;
						fmgc.flightPlanController.flightplans[me.computer].star = me.arrAirport[0].getStar(me.selectedSTAR);
					} else {
						isNoStar[me.computer] = 1;
						fmgc.flightPlanController.flightplans[me.computer].star = nil;
						if (fmgc.flightPlanController.flightplans[me.computer].approach == nil) {
							fmgc.flightPlanController.insertNOSTAR(me.computer);
						}
					}
					me.updateActiveSTARs();
					me.updateSTARs();
					if (me.selectedSTAR != "NO STAR") {
						me.hasPressNoTrans = 0;
						me.updateTransitions();
					} else {
						me.hasPressNoTrans = 1;
					}
					me.updateActiveTransitions();
					fmgc.flightPlanController.flightPlanChanged(me.computer);
				} else {
					setprop("MCDU[" ~ me.computer ~ "]/scratchpad-msg", 1);
					setprop("MCDU[" ~ me.computer ~ "]/scratchpad", "DIR TO IN PROGRESS");
				}
			} else {
				notAllowed(me.computer);
			}
		}
	},
	arrPushbuttonRight: func(index) {
		if (index == 2 and size(me.transitions) == 0) {
			if (!dirToFlag) {
				me.hasPressNoTrans = 1;
				me.updateActiveTransitions();
				me.updateTransitions();
			} else {
				setprop("MCDU[" ~ me.computer ~ "]/scratchpad-msg", 1);
				setprop("MCDU[" ~ me.computer ~ "]/scratchpad", "DIR TO IN PROGRESS");
			}
		} elsif (size(me.transitions) >= (index -  1)) {
			if (!dirToFlag) {
				me.selectedTransition = me.transitions[index - 2];
				me.makeTmpy();
				fmgc.flightPlanController.flightplans[me.computer].star_trans = me.selectedTransition;
				me.updateActiveTransitions();
				me.updateTransitions();
				fmgc.flightPlanController.flightPlanChanged(me.computer);
			} else {
				setprop("MCDU[" ~ me.computer ~ "]/scratchpad-msg", 1);
				setprop("MCDU[" ~ me.computer ~ "]/scratchpad", "DIR TO IN PROGRESS");
			}
		} else {
			notAllowed(me.computer);
		}
	},
};