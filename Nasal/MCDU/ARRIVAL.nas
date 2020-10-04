var isNoStar = [0, 0, 0];
var isNoTransArr = [0, 0, 0];
var isNoVia = [0, 0, 0];

var version = nil;

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
	stars: [],
	transitions: [],
	vias: [],
	computer: nil,
	enableScrollApproach: 0,
	enableScrollStars: 0,
	enableScrollVias: 0,
	scrollApproach: 0,
	scrollStars: 0,
	scrollVias: 0,
	activePage: 0, # runways, stars, vias
	oldPage: 0,
	_approaches: nil,
	_vias: nil,
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
		me.selectedApproach = nil;
		me.selectedSTAR = nil;
		me.selectedTransition = nil;
		me.selectedVIA = nil;
		isNoStar[me.computer] = 0;
		isNoTransArr[me.computer] = 0;
		isNoVia[me.computer] = 0;
	},
	_setupFirstTime: func() {
		if (!fmgc.flightPlanController.temporaryFlag[me.computer]) {
			if (fmgc.flightPlanController.flightplans[2].approach != nil) {
				me.selectedApproach = fmgc.flightPlanController.flightplans[2].approach;
				
				version = pts.Sim.Version.getValue();
				if (version == "2020.2.0" or version == "2020.2.1" or version == "2020.3.0") {
					if (fmgc.flightPlanController.flightplans[2].approach_trans != nil) {
						me.selectedVIA = fmgc.flightPlanController.flightplans[2].approach_trans;
					} elsif (isNoVia[2] == 1) {
						me.selectedVIA = "NO VIA";
					}
				}
			}
			
			if (fmgc.flightPlanController.flightplans[2].star != nil) {
				me.selectedSTAR = fmgc.flightPlanController.flightplans[2].star;
				isNoStar[2] = 0;
			} elsif (isNoStar[2] == 1) {
				me.selectedSTAR = "NO STAR";
			}
			
			if (isNoTransArr[2]) {
				me.selectedTransition = "NO TRANS";
			} elsif (fmgc.flightPlanController.flightplans[2].star != nil) {
				me.selectedTransition = fmgc.flightPlanController.flightplans[2].star_trans;
			}
		} else {
			if (fmgc.flightPlanController.flightplans[me.computer].approach != nil) {
				me.selectedApproach = fmgc.flightPlanController.flightplans[me.computer].approach;
				version = pts.Sim.Version.getValue();
				if (version == "2020.2.0" or version == "2020.2.1" or version == "2020.3.0") {
					if (fmgc.flightPlanController.flightplans[me.computer].approach_trans != nil) {
						me.selectedVIA = fmgc.flightPlanController.flightplans[me.computer].approach_trans;
					} elsif (isNoVia[me.computer] == 1) {
						me.selectedVIA = "NO VIA";
					}
				}
			} elsif (fmgc.flightPlanController.flightplans[2].approach != nil) {
				me.selectedApproach = fmgc.flightPlanController.flightplans[2].approach;
				version = pts.Sim.Version.getValue();
				if (version == "2020.2.0" or version == "2020.2.1" or version == "2020.3.0") {
					if (fmgc.flightPlanController.flightplans[2].approach_trans != nil) {
						me.selectedVIA = fmgc.flightPlanController.flightplans[2].approach_trans;
					}
				}
			}
			if (fmgc.flightPlanController.flightplans[me.computer].star != nil) {
				me.selectedSTAR = fmgc.flightPlanController.flightplans[me.computer].star;
				isNoStar[me.computer] = 0;
			} elsif (fmgc.flightPlanController.flightplans[2].star != nil) {
				me.selectedSTAR = fmgc.flightPlanController.flightplans[2].star;
				isNoStar[me.computer] = 0;
				isNoStar[2] = 0;
			} elsif (isNoStar[me.computer] == 1) {
				me.selectedSTAR = "NO STAR";
			}
			
			if (isNoTransArr[me.computer] or isNoTransArr[2]) {
				me.selectedTransition = "NO TRANS";
			} elsif (fmgc.flightPlanController.flightplans[me.computer].star != nil) {
				me.selectedTransition = fmgc.flightPlanController.flightplans[me.computer].star_trans;
			} elsif (fmgc.flightPlanController.flightplans[2].star != nil) {
				me.selectedTransition = fmgc.flightPlanController.flightplans[2].star_trans;
			}
		}
	},
	_setupPageWithData: func() {
		me.title = ["ARRIVAL", " TO ", left(me.id, 4)];
		
		me.fontMatrix = [[0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0]];
		me.arrowsMatrix = [[0, 0, 0, 0, 0, 1], [0, 0, 0, 0, 0, 0]];
		me.arrowsColour = [["ack", "ack", "ack", "ack", "ack", "wht"], ["ack", "ack", "ack", "ack", "ack", "ack"]];
		
		if (!fmgc.flightPlanController.temporaryFlag[me.computer] or me.activePage == 2) {
			me.L6 = [" RETURN", nil, "wht"];
		} else {
			me.L6 = [" F-PLN", " TMPY", "yel"];
			me.arrowsColour[0][5] = "yel";
		}
		
		if (me.activePage == 0) {
			me.updateApproaches();
		} elsif (me.activePage == 1) {
			me.updateSTARs();
			me.updateTransitions();
		} else {
			me.updateVIAs();
		}
		
		me.checkPageType();
		
		me.updateActiveApproach();
		me.updateActiveVIAs();
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
	
	# Functions to populate top row
	updateActiveApproach: func() {
		if (me.apprIsRwyFlag) {
			if (fmgc.flightPlanController.temporaryFlag[me.computer]) {
				if (fmgc.flightPlanController.flightplans[me.computer].destination_runway != nil) {
					me.L1 = [fmgc.flightPlanController.flightplans[me.computer].destination_runway.id, " APPR", "yel"];
				} elsif (fmgc.flightPlanController.flightplans[2].destination_runway != nil and fmgc.flightPlanController.flightplans[2].destination_runway.id == me.selectedApproach.id) {
					me.L1 = [fmgc.flightPlanController.flightplans[2].destination_runway.id, " APPR", "yel"];
				} else {
					me.L1 = ["-----", " APPR", "wht"];
				}
			} else {
				if (fmgc.flightPlanController.flightplans[2].destination_runway != nil) {
					me.L1 = [fmgc.flightPlanController.flightplans[2].destination_runway.id, " APPR", "grn"];
				} else {
					me.L1 = ["-----", " APPR", "wht"];
				}
			}
		} elsif (me.selectedApproach != nil) {
			if (fmgc.flightPlanController.temporaryFlag[me.computer]) {
				if (fmgc.flightPlanController.flightplans[me.computer].approach != nil) {
					me.L1 = [fmgc.flightPlanController.flightplans[me.computer].approach.id, " APPR", "yel"];
				} elsif (fmgc.flightPlanController.flightplans[2].approach != nil and fmgc.flightPlanController.flightplans[2].approach.id == me.selectedApproach.id) {
					me.L1 = [fmgc.flightPlanController.flightplans[2].approach.id, " APPR", "yel"];
				} else {
					me.L1 = ["-----", " APPR", "wht"];
				} 
			} else {
				if (fmgc.flightPlanController.flightplans[2].approach != nil) {
					me.L1 = [fmgc.flightPlanController.flightplans[2].approach.id, " APPR", "grn"];
				} else {
					me.L1 = ["-----", " APPR", "wht"];
				}
			}
		} else {
			me.L1 = ["-----", " APPR", "wht"];
		}
		canvas_mcdu.pageSwitch[me.computer].setBoolValue(0);
	},
	
	updateActiveVIAs: func() {
		version = pts.Sim.Version.getValue();
		if (version != "2020.2.0" and version != "2020.2.1" and version != "2020.3.0") { return; }
				
		if (me.selectedVIA == "NO VIA") {
			if (!fmgc.flightPlanController.temporaryFlag[me.computer]) {
				me.C1 = ["NONE", "VIA", "grn"];
			} else {
				me.C1 = ["NONE", "VIA", "yel"];
			}
		} elsif (me.selectedVIA != nil) {
			if (fmgc.flightPlanController.temporaryFlag[me.computer]) {
				if (fmgc.flightPlanController.flightplans[me.computer].approach_trans != nil) {
					me.C1 = [fmgc.flightPlanController.flightplans[me.computer].approach_trans.id, "VIA", "yel"];
				} elsif (fmgc.flightPlanController.flightplans[2].approach_trans != nil and fmgc.flightPlanController.flightplans[2].approach_trans.id == me.selectedVIA.id) {
					me.C1 = [fmgc.flightPlanController.flightplans[2].approach_trans.id, "VIA", "yel"];
				} else {
					me.C1 = ["-------", "VIA", "wht"];
				} 
			} else {
				if (fmgc.flightPlanController.flightplans[2].approach_trans != nil) {
					me.C1 = [fmgc.flightPlanController.flightplans[2].approach_trans.id, "VIA", "grn"];
				} else {
					me.C1 = ["-------", "VIA", "wht"];
				}
			}
		} else {
			me.C1 = ["-------", "VIA", "wht"];
		}
		canvas_mcdu.pageSwitch[me.computer].setBoolValue(0);
	},
	
	updateActiveSTARs: func() {
		if (me.selectedSTAR == "NO STAR") {
			if (!fmgc.flightPlanController.temporaryFlag[me.computer]) {
				me.R1 = ["NONE", "STAR  ", "grn"];
			} else {
				me.R1 = ["NONE", "STAR  ", "yel"];
			}
		} elsif (me.selectedSTAR != nil) {
			if (fmgc.flightPlanController.temporaryFlag[me.computer]) {
				if (fmgc.flightPlanController.flightplans[me.computer].star != nil) {
					me.R1 = [fmgc.flightPlanController.flightplans[me.computer].star.id, "STAR  ", "yel"];
				} elsif (fmgc.flightPlanController.flightplans[2].star != nil and fmgc.flightPlanController.flightplans[2].star.id == me.selectedSTAR.id) {
					me.R1 = [fmgc.flightPlanController.flightplans[2].star.id, "STAR  ", "yel"];
				} else {
					me.R1 = ["-------", "STAR  ", "wht"];
				} 
			} else {
				if (fmgc.flightPlanController.flightplans[2].star != nil) {
					me.R1 = [fmgc.flightPlanController.flightplans[2].star.id, "STAR  ", "grn"];
				} else {
					me.R1 = ["-------", "STAR  ", "wht"];
				}
			}
		} else {
			me.R1 = ["-------", "STAR  ", "wht"];
		}
		canvas_mcdu.pageSwitch[me.computer].setBoolValue(0);
	},
	
	updateActiveTransitions: func() {
		if (me.selectedTransition == "NO TRANS") {
			if (!fmgc.flightPlanController.temporaryFlag[me.computer]) {
				me.R2 = ["NONE", "TRANS  ", "grn"];
			} else {
				me.R2 = ["NONE", "TRANS  ", "yel"];
			}
		} else {
			if (me.selectedTransition != nil) {
				if (fmgc.flightPlanController.temporaryFlag[me.computer]) {
					if (fmgc.flightPlanController.flightplans[me.computer].star_trans != nil) {
						me.R2 = [fmgc.flightPlanController.flightplans[me.computer].star_trans.id, "TRANS  ", "yel"];
					} elsif (fmgc.flightPlanController.flightplans[2].star_trans != nil and fmgc.flightPlanController.flightplans[2].star_trans.id == me.selectedTransition.id) {
						me.R2 = [fmgc.flightPlanController.flightplans[2].star_trans.id, "TRANS  ", "yel"];
					} else {
						me.R2 = ["-------", "TRANS  ", "wht"];
					} 
				} else { 
					if (fmgc.flightPlanController.flightplans[2].star_trans != nil) {
						me.R2 = [fmgc.flightPlanController.flightplans[2].star_trans.id, "TRANS  ", "grn"];
					} else {
						me.R2 = ["-------", "TRANS  ", "wht"];
					}
				}
			} else {
				me.R2 = ["-------", "TRANS  ", "wht"];
			}
		}
		canvas_mcdu.pageSwitch[me.computer].setBoolValue(0);
	},
	
	updateApproaches: func() {
		me.apprIsRwyFlag = 0;
		if (me.arrAirport == nil) {
			me.arrAirport = findAirportsByICAO(left(me.id, 4));
		}
		
		me.approaches = [];
		me._approaches = nil;
		
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
					me.C6[1] = me._approaches[me.approaches[2 + me.scrollApproach]].ils.id ~ "/" ~ sprintf("%7.2f", me._approaches[me.approaches[2 + me.scrollApproach]].ils_frequency_mhz);
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
		
		me.stars = [];
		me._stars = nil;
		
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
			me.L3 = [" " ~ me.stars[0 + me.scrollStars], "STARS", "blu"];
			if (me.stars[0 + me.scrollStars] != me.selectedSTAR) {
				me.arrowsMatrix[0][2] = 1;
				me.arrowsColour[0][2] = "blu";
			} else {
				me.arrowsMatrix[0][2] = 0;
				me.arrowsColour[0][2] = "ack";
			}
		}
		if (size(me.stars) >= 2) {
			me.L4 = [" " ~ me.stars[1 + me.scrollStars], nil, "blu"];
			if (me.stars[1 + me.scrollStars] != me.selectedSTAR) {
				me.arrowsMatrix[0][3] = 1;
				me.arrowsColour[0][3] = "blu";
			} else {
				me.arrowsMatrix[0][3] = 0;
				me.arrowsColour[0][3] = "ack";
			}
		}
		if (size(me.stars) >= 3) {
			me.L5 = [" " ~ me.stars[2 + me.scrollStars], nil, "blu"];
			if (me.stars[2 + me.scrollStars] != me.selectedSTAR) {
				me.arrowsMatrix[0][4] = 1;
				me.arrowsColour[0][4] = "blu";
			} else {
				me.arrowsMatrix[0][4] = 0;
				me.arrowsColour[0][4] = "ack";
			}
		}
		
		me.C3[1] = "AVAILABLE";
		me.R3[1] = "TRANS ";
		
		if (size(me.stars) > 3) {
			me.enableScrollStars = 1;
		}
		canvas_mcdu.pageSwitch[me.computer].setBoolValue(0);
	},
	updateVIAs: func() {
		version = pts.Sim.Version.getValue();
		if (version != "2020.2.0" and version != "2020.2.1" and version != "2020.3.0") { return; }
		if (me.selectedApproach == nil or me.activePage != 2) {
			me.clearVias();
			return;
		}
		me.vias = [];
		me._vias = nil;
		me._vias = me.selectedApproach.transitions;
		me.vias = sort(me._vias, func(a,b) cmp(a,b));
		append(me.vias, "NO VIA");
		
		if (size(me.vias) >= 1) {
			me.L2 = [" " ~ me.vias[0 + me.scrollVias], " APP VIAS", "blu"];
			if (me.vias[0 + me.scrollVias] != me.selectedVIA) {
				me.arrowsMatrix[0][1] = 1;
				me.arrowsColour[0][1] = "blu";
			} else {
				me.arrowsMatrix[0][1] = 0;
				me.arrowsColour[0][1] = "ack";
			}
		} 
		if (size(me.vias) >= 2) {
			me.L3 = [" " ~ me.vias[1 + me.scrollVias], nil, "blu"];
			if (me.vias[1 + me.scrollVias] != me.selectedVIA) {
				me.arrowsMatrix[0][2] = 1;
				me.arrowsColour[0][2] = "blu";
			} else {
				me.arrowsMatrix[0][2] = 0;
				me.arrowsColour[0][2] = "ack";
			}
		}
		if (size(me.vias) >= 3) {
			me.L4 = [" " ~ me.vias[2 + me.scrollVias], nil, "blu"];
			if (me.vias[2 + me.scrollVias] != me.selectedVIA) {
				me.arrowsMatrix[0][3] = 1;
				me.arrowsColour[0][3] = "blu";
			} else {
				me.arrowsMatrix[0][3] = 0;
				me.arrowsColour[0][3] = "ack";
			}
		}
		if (size(me.vias) >= 4) {
			me.L5 = [" " ~ me.vias[3 + me.scrollVias], nil, "blu"];
			if (me.vias[3 + me.scrollVias] != me.selectedVIA) {
				me.arrowsMatrix[0][4] = 1;
				me.arrowsColour[0][4] = "blu";
			} else {
				me.arrowsMatrix[0][4] = 0;
				me.arrowsColour[0][4] = "ack";
			}
		}
		
		if (size(me.vias) > 3) {
			me.enableScrollVias = 1;
		}
	},
	clearTransitions: func() {
		me.R3 = [nil, nil, "wht"];
		me.R4 = [nil, nil, "wht"];
		me.R5 = [nil, nil, "wht"];
		me.arrowsMatrix[1][2] = 0;
		me.arrowsColour[1][2] = "ack";
		me.arrowsMatrix[1][3] = 0;
		me.arrowsColour[1][3] = "ack";
		me.arrowsMatrix[1][4] = 0;
		me.arrowsColour[1][4] = "ack";
	},
	clearVias: func() {
		me.L2 = [nil, nil, "wht"];
		me.L3 = [nil, nil, "wht"];
		me.L4 = [nil, nil, "wht"];
		me.L5 = [nil, nil, "wht"];
		me.arrowsMatrix[0][1] = 0;
		me.arrowsColour[0][1] = "ack";
		me.arrowsMatrix[0][2] = 0;
		me.arrowsColour[0][2] = "ack";
		me.arrowsMatrix[0][3] = 0;
		me.arrowsColour[0][3] = "ack";
		me.arrowsMatrix[0][4] = 0;
		me.arrowsColour[0][4] = "ack";
		if (me.activePage == 2) {
			me.activePage = me.oldPage;
		}
	},
	updateTransitions: func() {
		if (me.arrAirport == nil) {
			me.arrAirport = findAirportsByICAO(left(me.id, 4));
		}

		me.transitions = [];
		me._transitions = nil;
		
		me.clearTransitions();
		if (me.selectedSTAR == nil or me.selectedSTAR == "NO STAR") {
			append(me.transitions, "NO TRANS");
			return;
		}
		
		if (isghost(me.selectedSTAR)) {
			me._transitions = me.arrAirport[0].getStar(me.selectedSTAR.id).transitions;
		} else {
			me._transitions = me.arrAirport[0].getStar(me.selectedSTAR).transitions;
		}
		me.transitions = sort(me._transitions,func(a,b) cmp(a,b));
		append(me.transitions, "NO TRANS");
		
		if (size(me.transitions) >= 1) {
			me.R3 = [me.transitions[0] ~ " ", "TRANS", "blu"];
			if (me.transitions[0] != me.selectedTransition) {
				me.arrowsMatrix[1][2] = 1;
				me.arrowsColour[1][2] = "blu";
			} else {
				me.arrowsMatrix[1][2] = 0;
				me.arrowsColour[1][2] = "ack";
			}
		}
		if (size(me.transitions) >= 2) {
			me.R4 = [me.transitions[1] ~ " ", nil, "blu"];
			if (me.transitions[1] != me.selectedTransition) {
				me.arrowsMatrix[1][3] = 1;
				me.arrowsColour[1][3] = "blu";
			} else {
				me.arrowsMatrix[1][3] = 0;
				me.arrowsColour[1][3] = "ack";
			}
		} 
		if (size(me.transitions) >= 3) {
			me.R5 = [me.transitions[2] ~ " ", nil, "blu"];
			if (me.transitions[2] != me.selectedTransition) {
				me.arrowsMatrix[1][4] = 1;
				me.arrowsColour[1][4] = "blu";
			} else {
				me.arrowsMatrix[1][4] = 0;
				me.arrowsColour[1][4] = "ack";
			}
		}
		
		# no indication it is scrollable...
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
	checkPageType: func() {
		if (me.activePage == 0) {
			me.L2 = [nil, nil, "wht"];
			me.arrowsMatrix[0][1] = 0;
			me.arrowsColour[0][1] = "wht";
		} elsif (me.activePage == 1) {
			me.L2 = [" VIAS", " APPR", "wht"];
			me.arrowsMatrix[0][1] = 1;
			me.arrowsColour[0][1] = "wht";
		}
	},
	scrollUp: func() {
		if (me.activePage == 0) {
			if (me.enableScrollApproach) {
				me.scrollApproach += 1;
				if (me.scrollApproach > size(me.approaches) - 3) {
					me.scrollApproach = 0;
				}
				me.updateApproaches();
			}
		} elsif (me.activePage == 1) {
			if (me.enableScrollStars) {
				me.scrollStars += 1;
				if (me.scrollStars > size(me.stars) - 3) {
					me.scrollStars = 0;
				}
				me.updateSTARs();
				if (me.selectedSTAR == nil or me.selectedSTAR == "NO STAR") {
					me.clearTransitions();
				} else {
					me.updateTransitions();
				}
			}
		} elsif (me.activePage == 2) {
			if (me.enableScrollVias) {
				me.scrollVias += 1;
				if (me.scrollVias > size(me.vias) - 4) {
					me.scrollVias = 0;
				}
				me.updateActiveVIAs();
				me.updateVIAs();
			}
		}
	},
	scrollDn: func() {
		if (me.activePage == 0) {
			if (me.enableScrollApproach) {
				me.scrollApproach -= 1;
				if (me.scrollApproach < 0) {
					me.scrollApproach = size(me.approaches) - 3;
				}
				me.updateApproaches();
			}
		} elsif (me.activePage == 1) {
			if (me.enableScrollStars) {
				me.scrollStars -= 1;
				if (me.scrollStars < 0) {
					me.scrollStars = size(me.stars) - 3;
				}
				me.updateSTARs();
				if (me.selectedSTAR == nil or me.selectedSTAR == "NO STAR") {
					me.clearTransitions();
				} else {
					me.updateTransitions();
				}
			}
		} elsif (me.activePage == 2) {
			if (me.enableScrollVias) {
				me.scrollVias -= 1;
				if (me.scrollVias < 0) {
					me.scrollVias = size(me.vias) - 4;
				}
				me.updateActiveVIAs();
				me.updateVIAs();
			}
		}
	},
	scrollLeft: func() {
		if (me.activePage == 2) { return; }
		me.activePage = !me.activePage;
		me.checkPageType();
		me.updatePage();
	},
	scrollRight: func() {
		if (me.activePage == 2) { return; }
		me.activePage = !me.activePage;
		me.checkPageType();
		me.updatePage();
	},
	arrPushbuttonLeft: func(index) {
		if (index == 2 and me.activePage == 1 and me.selectedApproach != nil) {
			version = pts.Sim.Version.getValue();
			if (version != "2020.2.0" and version != "2020.2.1" and version != "2020.3.0") { return; }
			me.oldPage = me.activePage;
			me.activePage = 2;
			me.updatePage();
			me.updateVIAs();
		} elsif (index == 6 and me.activePage == 2) {
			me.activePage = me.oldPage;
			me.oldPage = 0;
			me.updatePage();
		} elsif (index == 6 and me.activePage != 2) {
			if (fmgc.flightPlanController.temporaryFlag[me.computer]) {
				setprop("/MCDU[" ~ me.computer ~ "]/page", "F-PLNA");
			} else {
				setprop("/MCDU[" ~ me.computer ~ "]/page", "LATREV");
			}
		} elsif (me.activePage == 0 and index != 6) {
			if (size(me.approaches) >= (index - 2) and index != 2) { # index = 3, size = 1
				if (!dirToFlag) {
					me.selectedVIA = nil;
					isNoTransArr[me.computer] = 0;
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
					fmgc.FMGCInternal.radioNo = 0;
					me.updateApproaches();
					me.updatePage();
					fmgc.flightPlanController.flightPlanChanged(me.computer);
					me.scrollRight();
					me.checkPageType();
				} else {
					mcdu_message(me.computer, "DIR TO IN PROGRESS");
				}
			} else {
				mcdu_message(me.computer, "NOT ALLOWED");
			}
		} elsif (me.activePage == 1 and index != 6) {
			if (size(me.stars) >= (index - 2) and index != 2) {
				if (!dirToFlag) {
					me.selectedTransition = nil;
					me.selectedSTAR = me.stars[index - 3 + me.scrollStars];
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
					me.updateSTARs();
					if (me.selectedSTAR != "NO STAR") {
						isNoTransArr[me.computer] = 0;
					} else {
						isNoTransArr[me.computer] = 1;
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
		} elsif (me.activePage == 2 and index != 6) {
			if (size(me.vias) >= (index - 1)) { # different!!
				if (!dirToFlag) {
					me.selectedVIA = me.vias[index - 2 + me.scrollVias];
					me.makeTmpy();
					if (me.selectedVIA != "NO VIA") {
						isNoVia[me.computer] = 0;
						fmgc.flightPlanController.flightplans[me.computer].approach_trans = me.selectedVIA;
					} else {
						isNoVia[me.computer] = 1;
						fmgc.flightPlanController.flightplans[me.computer].approach_trans = nil;
					}
					me.updateVIAs();
					me.updatePage();
					fmgc.flightPlanController.flightPlanChanged(me.computer);
				} else {
					mcdu_message(me.computer, "DIR TO IN PROGRESS");
				}
			} else {
				mcdu_message(me.computer, "NOT ALLOWED");
			}
		} else {
			mcdu_message(me.computer, "NOT ALLOWED");
		}
	},
	arrPushbuttonRight: func(index) {
		if (size(me.transitions) >= (index - 2)) {
			if (!dirToFlag) {
				me.selectedTransition = me.transitions[index - 3];
				me.makeTmpy();
				if (me.selectedTransition != "NO TRANS") {
					isNoTransArr[me.computer] = 0;
					fmgc.flightPlanController.flightplans[me.computer].star_trans = me.selectedTransition;
				} else {
					isNoTransArr[me.computer] = 1;
					fmgc.flightPlanController.flightplans[me.computer].star_trans = nil;
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