var fplnItem = {
	new: func(wp, index, plan, computer, colour = "grn") {
		var fI = {parents:[fplnItem]};
		fI.wp = wp;
		fI.index = index;
		fI.plan = plan;
		fI.computer = computer;
		fI.colour = colour;
		return fI;
	},
	updateLeftText: func() {
		if (me.wp != nil) {
			if (me.wp.wp_name != "DISCONTINUITY") {
				var wptName = split("-", me.wp.wp_name);
				if (wptName[0] == "VECTORS") {
					return ["MANUAL", nil, me.colour];
				} else {
					if (size(wptName) == 2) {
						return[wptName[0] ~ wptName[1], nil, me.colour];
					} else {
						return [me.wp.wp_name, nil, me.colour];
					}
				}
			} else {
				return [nil, nil, "ack"];
			}
		} else {
			return ["problem", nil, "ack"];
		}
	},
	updateCenterText: func() {
		if (me.wp != nil) { 
			if (me.wp.wp_name != "DISCONTINUITY") {
				me.brg = me.getBrg();
				me.track = me.getTrack();
				return ["---- ", nil, me.colour];
			} else {
				return ["---F-PLN DISCONTINUITY--", nil, "wht"];
			}
		} else {
			return ["problem", nil, "ack"];
		}
	},
	updateRightText: func() {
		if (me.wp != nil) {
			if (me.wp.wp_name != "DISCONTINUITY") {
				me.spd = me.getSpd();
				me.alt = me.getAlt();
				me.dist = me.getDist();
				return [me.spd ~ "/" ~ me.alt, " " ~ me.dist ~ "NM     ", me.colour];
			} else {
				return [nil, nil, "ack"];
			}
		} else {
			return ["problem", nil, "ack"];
		}
	},
	getBrg: func() {
		return nil;
	},
	getTrack: func() {
		return nil;
	},
	getSpd: func() {
		return "---";
	},
	getAlt: func() {
		return "-----";
	},
	getDist: func() {
		return "--";
	},
	pushButtonLeft: func() {
		if (canvas_mcdu.myLatRev[me.computer] != nil) {
			canvas_mcdu.myLatRev[me.computer].del();
		}
		canvas_mcdu.myLatRev[me.computer] = nil;
		
		if (me.wp.wp_name == "DISCONTINUITY") {
			canvas_mcdu.myLatRev[me.computer] = latRev.new(4, "DISCON", me.index, me.computer);
		} elsif (fmgc.flightPlanController.temporaryFlag[me.computer]) {
			if (me.index == fmgc.flightPlanController.arrivalIndex[me.computer]) {
				canvas_mcdu.myLatRev[me.computer] = latRev.new(1, left(me.wp.wp_name, 4), me.index, me.computer);
			} if (left(me.wp.wp_name, 4) == fmgc.flightPlanController.flightplans[me.computer].departure.id) {
				canvas_mcdu.myLatRev[me.computer] = latRev.new(0, left(me.wp.wp_name, 4), me.index, me.computer);
			} elsif (me.index == (fmgc.flightPlanController.currentToWptIndex.getValue() - 1)) {
				canvas_mcdu.myLatRev[me.computer] = latRev.new(2, me.wp.wp_name, me.index, me.computer);
			} else {
				canvas_mcdu.myLatRev[me.computer] = latRev.new(3, me.wp.wp_name, me.index, me.computer);
			}
		} else {
			if (me.index == fmgc.flightPlanController.arrivalIndex[2]) {
				canvas_mcdu.myLatRev[me.computer] = latRev.new(1, left(me.wp.wp_name, 4), me.index, me.computer);
			} elsif (left(me.wp.wp_name, 4) == fmgc.flightPlanController.flightplans[2].departure.id) {
				canvas_mcdu.myLatRev[me.computer] = latRev.new(0, left(me.wp.wp_name, 4), me.index, me.computer);
			} elsif (me.index == (fmgc.flightPlanController.currentToWptIndex.getValue() - 1)) {
				canvas_mcdu.myLatRev[me.computer] = latRev.new(2, me.wp.wp_name, me.index, me.computer);
			} else {
				canvas_mcdu.myLatRev[me.computer] = latRev.new(3, me.wp.wp_name, me.index, me.computer);
			}
		}
		setprop("MCDU[" ~ me.computer ~ "]/page", "LATREV");
	},
	pushButtonRight: func() {
		if (canvas_mcdu.myVertRev[me.computer] != nil) {
			canvas_mcdu.myVertRev[me.computer].del();
		}
		canvas_mcdu.myVertRev[me.computer] = nil;
		
		if (fmgc.flightPlanController.temporaryFlag[me.computer]) {
			if (me.index == fmgc.flightPlanController.arrivalIndex[me.computer]) {
				canvas_mcdu.myVertRev[me.computer] = vertRev.new(1, left(me.wp.wp_name, 4), me.index, me.computer);
			} if (left(me.wp.wp_name, 4) == fmgc.flightPlanController.flightplans[me.computer].departure.id) {
				notAllowed(me.computer);
				return;
			} elsif (me.index == (fmgc.flightPlanController.currentToWptIndex.getValue() - 1)) {
				canvas_mcdu.myVertRev[me.computer] = vertRev.new(3, me.wp.wp_name, me.index, me.computer);
			} else {
				canvas_mcdu.myVertRev[me.computer] = vertRev.new(2, me.wp.wp_name, me.index, me.computer);
			}
		} else {
			if (me.index == fmgc.flightPlanController.arrivalIndex[2]) {
				canvas_mcdu.myVertRev[me.computer] = vertRev.new(1, left(me.wp.wp_name, 4), me.index, me.computer);
			} elsif (left(me.wp.wp_name, 4) == fmgc.flightPlanController.flightplans[2].departure.id) {
				notAllowed(me.computer);
				return;
			} elsif (me.index == (fmgc.flightPlanController.currentToWptIndex.getValue() - 1)) {
				canvas_mcdu.myVertRev[me.computer] = vertRev.new(3, me.wp.wp_name, me.index, me.computer);
			} else {
				canvas_mcdu.myVertRev[me.computer] = vertRev.new(2, me.wp.wp_name, me.index, me.computer);
			}
		}
		setprop("MCDU[" ~ me.computer ~ "]/page", "VERTREV");
	},
};

var staticText = {
	new: func(computer, text) {
		var sT = {parents:[staticText]};
		sT.computer = computer;
		sT.text = text;
		return sT;
	},
	updateLeftText: func() {
		return [nil, nil, "ack"];
	},
	updateCenterText: func() {
		return [me.text, nil, "wht"];
	},
	updateRightText: func() {
		return [nil, nil, "ack"];
	},
	pushButtonLeft: func() {
		notAllowed(me.computer);
	},
	pushButtonRight: func() {
		notAllowed(me.computer);
	},
};

var fplnPage = { # this one is only created once, and then updated - remember this
	fontMatrix: [[0, 0, 0, 0, 0, 0],[0, 0, 0, 0, 0, 0]],
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
	
	# init conditions
	# line 1 = FROM
	# line 2 = TO
	# line 6 = DEST
	# neither pseudo nor markers may be FROM waypoint
	# bearing between FROM and TO waypoints
	# track between line 2 and line 3 waypoints
	# name of LEG above TO waypoint - is airway identifier, or waypoint name
	
	# DEST in LINE 6 time prediction, distance along flightplan, and EFOB
	# dashes if no predictions
	planList: [],
	outputList: [],
	scroll: 0,
	temporaryFlagFpln: 0,
	new: func(plan, computer) {
		var fp = {parents:[fplnPage]};
		fp.plan = fmgc.flightPlanController.flightplans[plan];
		fp.planIndex = plan;
		fp.computer = computer;
		fp.planList = [];
		fp.outputList = [];
		return fp;
	},
	_setupPageWithData: func() {
		me.destInfo();
		me.createPlanList();
	},
	updatePlan: func() {
		if (!fmgc.flightPlanController.temporaryFlag[me.computer]) {
			me.planIndex = 2;
			me.plan = fmgc.flightPlanController.flightplans[2];
			me.temporaryFlagFpln = 0;
		} else {
			me.planIndex = me.computer;
			me.plan = fmgc.flightPlanController.flightplans[me.computer];
			me.temporaryFlagFpln = 1;
		}
		me._setupPageWithData();
	},
	getText: func(type) {
		if (type == "fplnEnd") {
			return "------END OF F-PLN------";
		} else if (type == "altnFplnEnd") {
			return "----END OF ALTN F-PLN---";
		} else if (type == "noAltnFpln") {
			return "------NO ALTN F-PLN-----";
		} else if (type == "empty") {
			return "";
		}
	},
	createPlanList: func() {
		me.planList = [];
		if (me.temporaryFlagFpln) {
			for (var i = 0; i < me.plan.getPlanSize(); i += 1) {
				append(me.planList, fplnItem.new(me.plan.getWP(i), i, me.plan, me.computer, "yel"));
			}
		} else {
			for (var i = 0; i < me.plan.getPlanSize(); i += 1) {
				append(me.planList, fplnItem.new(me.plan.getWP(i), i, me.plan, me.computer));
			}
		}
		append(me.planList, staticText.new(me.computer, me.getText("fplnEnd")));
		append(me.planList, staticText.new(me.computer, me.getText("noAltnFpln")));
		me.basePage();
	},
	basePage: func() {
		me.outputList = [];
		for (var i = 0; i + me.scroll < size(me.planList); i += 1) {
			append(me.outputList, me.planList[i + me.scroll] );
		}
		if (size(me.outputList) >= 1) {
			me.L1 = me.outputList[0].updateLeftText();
			me.C1 = me.outputList[0].updateCenterText();
			me.C1[1] = "TIME ";
			me.R1 = me.outputList[0].updateRightText();
			me.R1[1] = "SPD/ALT   ";
		} else {
			me.L1 = [nil, nil, "ack"];
			me.C1 = [nil, nil, "ack"];
			me.R1 = [nil, nil, "ack"];
		}
		if (size(me.outputList) >= 2) {
			me.L2 = me.outputList[1].updateLeftText();
			me.C2 = me.outputList[1].updateCenterText();
			me.R2 = me.outputList[1].updateRightText();
		} else {
			me.L2 = [nil, nil, "ack"];
			me.C2 = [nil, nil, "ack"];
			me.R2 = [nil, nil, "ack"];
		}
		if (size(me.outputList) >= 3) {
			me.L3 = me.outputList[2].updateLeftText();
			me.C3 = me.outputList[2].updateCenterText();
			me.R3 = me.outputList[2].updateRightText();
		} else {
			me.L3 = [nil, nil, "ack"];
			me.C3 = [nil, nil, "ack"];
			me.R3 = [nil, nil, "ack"];
		}
		if (size(me.outputList) >= 4) {
			me.L4 = me.outputList[3].updateLeftText();
			me.C4 = me.outputList[3].updateCenterText();
			me.R4 = me.outputList[3].updateRightText();
		} else {
			me.L4 = [nil, nil, "ack"];
			me.C4 = [nil, nil, "ack"];
			me.R4 = [nil, nil, "ack"];
		}
		if (size(me.outputList) >= 5) {
			me.L5 = me.outputList[4].updateLeftText();
			me.C5 = me.outputList[4].updateCenterText();
			me.R5 = me.outputList[4].updateRightText();
		} else {
			me.L5 = [nil, nil, "ack"];
			me.C5 = [nil, nil, "ack"];
			me.R5 = [nil, nil, "ack"];
		}
	},
	destInfo: func() {
		me.L6 = [left(me.plan.getWP(fmgc.flightPlanController.arrivalIndex[me.planIndex]).wp_name, 4), " DEST", "wht"];
		me.C6 = ["----  " ~ int(fmgc.flightPlanController.arrivalDist), "TIME   DIST", "wht"];
		me.R6 = ["--.-", "EFOB", "wht"];
	},
	update: func() {
		#me.basePage();
	},
	scrollUp: func() {
		if (size(me.planList) > 5) {
			me.scroll += 1;
			if (me.scroll > size(me.planList) - 5) {
				me.scroll = 0;
			}
		} else {
			me.scroll = 0;
		}
	},
	scrollDn: func() {
		if (size(me.planList) > 5) {
			me.scroll -= 1;
			if (me.scroll < 0) {
				me.scroll = size(me.planList) - 5;
			}
		} else {
			me.scroll = 0;
		}
	},
	pushButtonLeft: func(index) {
		if (index == 6) {
			if (fmgc.flightPlanController.temporaryFlag[me.computer]) {
				fmgc.flightPlanController.destroyTemporaryFlightPlan(me.computer, 0);
			} else {
				if (canvas_mcdu.myLatRev[me.computer] != nil) {
					canvas_mcdu.myLatRev[me.computer].del();
				}
				canvas_mcdu.myLatRev[me.computer] = nil;
				canvas_mcdu.myLatRev[me.computer] = latRev.new(1, me.L6[0], fmgc.flightPlanController.arrivalIndex[me.computer], me.computer);
				setprop("MCDU[" ~ me.computer ~ "]/page", "LATREV");
			}
		} else {
			if (size(me.outputList) >= index) {
				if (size(getprop("MCDU[" ~ me.computer ~ "]/scratchpad")) > 0) {
					var returny = fmgc.flightPlanController.scratchpad(getprop("MCDU[" ~ me.computer ~ "]/scratchpad"), (index - 1 + me.scroll), me.computer);
					if (returny == 0) {
						notInDataBase(me.computer);
					} elsif (returny == 1) {
						notAllowed(me.computer);
					} else {
						setprop("MCDU[" ~ me.computer ~ "]/scratchpad-msg", "");
						setprop("MCDU[" ~ me.computer ~ "]/scratchpad", "");
					}
				} else {
					me.outputList[index - 1].pushButtonLeft();
				}
			} else {
				notAllowed(me.computer);
			}
		}
	},
	pushButtonRight: func(index) {
		if (index == 6) {
			if (fmgc.flightPlanController.temporaryFlag[me.computer]) {
				fmgc.flightPlanController.destroyTemporaryFlightPlan(me.computer, 1);
			} else {
				notAllowed(me.computer);
			}
		} else {
			if (size(me.outputList) >= index) {
				if (size(getprop("MCDU[" ~ me.computer ~ "]/scratchpad")) > 0) {
					notAllowed(me.computer);
				} else {
					me.outputList[index - 1].pushButtonRight();
				}
			} else {
				notAllowed(me.computer);
			}
		}
	},
};

var notInDataBase = func(i) {
		if (getprop("MCDU[" ~ i ~ "]/scratchpad-msg") == 1) {
			setprop("MCDU[" ~ i ~ "]/last-scratchpad", "NOT IN DATABASE");
		} else {
			setprop("MCDU[" ~ i ~ "]/last-scratchpad", getprop("MCDU[" ~ i ~ "]/scratchpad"));
		}
	setprop("MCDU[" ~ i ~ "]/scratchpad-msg", 1);
	setprop("MCDU[" ~ i ~ "]/scratchpad", "NOT IN DATABASE");
}


var duplicateNamesPage = {
	title: nil,
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
	vector: nil,
	type: nil,
	computer: nil,
	enableScroll: 0,
	scroll: 0,
	distances: nil,
	new: func(vector, index, type, computer) {
		var fp = {parents:[duplicateNamesPage]};
		fp.vector = vector;
		fp.index = index;
		fp.type = type; # 0 = other, 1 = navaid
		fp.computer = computer;
		fp._setupPageWithData();
		fp.distances = [];
		return fp;
	},
	del: func() {
		return nil;
	},
	_setupPageWithData: func() {
		me.title = "DUPLICATE NAMES";
		me.arrowsMatrix = [[0, 0, 0, 0, 0, 1], [0, 0, 0, 0, 0, 0]];
		me.arrowsColour = [["ack", "ack", "ack", "ack", "ack", "wht"], ["ack", "ack", "ack", "ack", "ack", "ack"]];
		me.fontMatrix = [[0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0]];
		
		me.distances = [];
		for (var i = 0; i < size(me.vector); i += 1) {
			append(me.distances, math.round(courseAndDistance(me.vector[i])[1]));
		}
		
		me.C1[1] = "LAT/LONG";
		me.R1[1] = "FREQ";
		if (size(me.vector) >= 1) {
			me.L1 = [" " ~ me.vector[0 + me.scroll].id, "   " ~ me.distances[0 + me.scroll] ~ "NM", "blu"];
			me.arrowsMatrix[0][0] = 1;
			me.arrowsColour[0][0] = "blu";
			me.C1 = [" " ~ decimalToShortString(me.vector[0 + me.scroll].lat, "lat") ~ "/" ~ decimalToShortString(me.vector[0 + me.scroll].lon, "lon"), "LAT/LONG", "grn"];
			if (me.type == 1) {
				if (me.vector[0 + me.scroll].frequency != nil) {
					me.R1 = [sprintf("%7.2f", me.vector[0 + me.scroll].frequency / 100), "FREQ", "grn"];
				}
			}
		}
		if (size(me.vector) >= 2) {
			me.L2 = [" " ~ me.vector[0 + me.scroll].id, "   " ~ me.distances[1 + me.scroll] ~ "NM", "blu"];
			me.arrowsMatrix[0][1] = 1;
			me.arrowsColour[0][1] = "blu";
			me.C2 = [" " ~ decimalToShortString(me.vector[1 + me.scroll].lat, "lat") ~ "/" ~ decimalToShortString(me.vector[1 + me.scroll].lon, "lon"), "LAT/LONG", "grn"];
			if (me.type == 1) {
				if (me.vector[1 + me.scroll].frequency != nil) {
					me.R2 = [sprintf("%7.2f", me.vector[1 + me.scroll].frequency / 100), "FREQ", "grn"];
				}
			}
		}
		if (size(me.vector) >= 3) {
			me.L3 = [" " ~ me.vector[0 + me.scroll].id, "   " ~ me.distances[2 + me.scroll] ~ "NM", "blu"];
			me.arrowsMatrix[0][2] = 1;
			me.arrowsColour[0][2] = "blu";
			me.C3 = [" " ~ decimalToShortString(me.vector[2 + me.scroll].lat, "lat") ~ "/" ~ decimalToShortString(me.vector[2 + me.scroll].lon, "lon"), "LAT/LONG", "grn"];
			if (me.type == 1) {
				if (me.vector[2 + me.scroll].frequency != nil) {
					me.R3 = [sprintf("%7.2f", me.vector[2 + me.scroll].frequency / 100), "FREQ", "grn"];
				}
			}
		}
		if (size(me.vector) >= 4) {
			me.L4 = [" " ~ me.vector[0 + me.scroll].id, "   " ~ me.distances[3 + me.scroll] ~ "NM", "blu"];
			me.arrowsMatrix[0][3] = 1;
			me.arrowsColour[0][3] = "blu";
			me.C4 = [" " ~ decimalToShortString(me.vector[3 + me.scroll].lat, "lat") ~ "/" ~ decimalToShortString(me.vector[3 + me.scroll].lon, "lon"), "LAT/LONG", "grn"];
			if (me.type == 1) {
				if (me.vector[3 + me.scroll].frequency != nil) {
					me.R4 = [sprintf("%7.2f", me.vector[3 + me.scroll].frequency / 100), "FREQ", "grn"];
				}
			}
		}
		if (size(me.vector) >= 5) {
			me.L5 = [" " ~ me.vector[0 + me.scroll].id, "   " ~ me.distances[4 + me.scroll] ~ "NM", "blu"];
			me.arrowsMatrix[0][4] = 1;
			me.arrowsColour[0][4] = "blu";
			me.C5 = [" " ~ decimalToShortString(me.vector[4 + me.scroll].lat, "lat") ~ "/" ~ decimalToShortString(me.vector[4 + me.scroll].lon, "lon"), "LAT/LONG", "grn"];
			if (me.type == 1) {
				if (me.vector[4 + me.scroll].frequency != nil) {
					me.R5 = [sprintf("%7.2f", me.vector[4 + me.scroll].frequency / 100), "FREQ", "grn"];
				}
			}
		}
		if (size(me.vector) > 5) { me.enableScroll = 1; }
		
		me.L6 = [" RETURN", nil, "wht"];
	},
	scrollUp: func() {
		if (me.enableScroll) {
			me.scroll += 1;
			if (me.scroll > size(me.vector) - 5) {
				me.scroll = 0;
			}
		}	
	},
	scrollDn: func() {
		if (me.enableScroll) {
			me.scroll -= 1;
			if (me.scroll < 0) {
				me.scroll = size(me.vector) - 5;
			}
		}	
	},
	pushButtonLeft: func(indexSelect) {
		if (size(me.vector[0].id) == 5) {
			fmgc.flightPlanController.insertFix(me.vector[0].id, me.index, me.computer, 1, indexSelect - 1);
			setprop("MCDU[" ~ me.computer ~ "]/page", "F-PLNA");
		} elsif (size(me.vector[0].id) == 4) {
			fmgc.flightPlanController.insertAirport(me.vector[0].id, me.index, me.computer, 1, indexSelect - 1);
			setprop("MCDU[" ~ me.computer ~ "]/page", "F-PLNA");
		} elsif (size(me.vector[0].id) == 3 or size(me.vector[0].id)== 2) {
			fmgc.flightPlanController.insertNavaid(me.vector[0].id, me.index, me.computer, 1, indexSelect - 1);
			setprop("MCDU[" ~ me.computer ~ "]/page", "F-PLNA");
		}
	},
};

var decimalToShortString = func(dms, type) {
	var degrees = split(".", sprintf(dms))[0];
	if (type == "lat") {
		var sign = degrees >= 0 ? "N" : "S";
	} else {
		var sign = degrees >= 0 ? "E" : "W";
	}
	return abs(degrees) ~ sign;
}