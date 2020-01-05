var fplnItem = {
	new: func(wp, index, plan) {
		var fI = {parents:[fplnItem]};
		fI.wp = wp;
		fI.index = index;
		fI.plan = plan;
		return fI;
	},
	updateLeftText: func() {
		if (me.wp.wp_name != "DISCONTINUITY") {
			return [me.wp.wp_name, nil, "grn"];
		} else {
			return [nil, nil, "ack"];
		}
	},
	updateCenterText: func() {
		if (me.wp.wp_name != "DISCONTINUITY") {
			me.brg = me.getBrg();
			me.track = me.getTrack();
			return ["---- ", nil, "grn"];
		} else {
			return ["---F-PLN DISCONTINUITY--", nil, "wht"];
		}
	},
	updateRightText: func() {
		me.spd = me.getSpd();
		me.spd = me.getAlt();
		me.spd = me.getDist();
		return [me.spd ~ "/" ~ me.alt, "-" ~ me.dist ~ "NM     ", "grn"];
	},
	getBrg: func() {
		return nil;
	},
	getTrack: func() {
		return nil;
	},
	getSpd: func() {
		return nil;
	},
	getAlt: func() {
		return nil;
	},
	getDist: func() {
		return nil;
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
	new: func(plan, computer) {
		var lr = {parents:[fplnPage]};
		lr.plan = fmgc.flightPlanController.flightplans[plan];
		lr.planIndex = plan;
		lr.computer = computer;
		lr._setupPageWithData();
		return lr;
	},
	_setupPageWithData: func() {
		me.destInfo();
		me.createPlanList();
	},
	getText: func(type) {
		if (me.type == "discontinuity") {
			return "---F-PLN DISCONTINUITY--";
		} else if (me.type == "fplnEnd") {
			return "------END OF F-PLN------";
		} else if (me.type == "altnFplnEnd") {
			return "----END OF ALTN F-PLN---";
		} else if (me.type == "noAltnFpln") {
			return "------NO ALTN F-PLN-----";
		} else if (me.type == "empty") {
			return "";
		}
	},
	createPlanList: func() {
		me.planList = [];
		for (var i = 0; i < me.plan.getPlanSize(); i += 1) {
			append(me.planList, fplnItem.new(me.plan.getWP(i), i, me.plan));
		}
		
	},
	basePage: func() {
		me.outputList = [];
		for (var i = 0; i < size(me.planList); i += 1) {
			if (i == 5) { break; }
			append(me.outputList, me.planList[i + me.scroll] );
		}
		if (size(me.outputList) > 1) {
			me.L1 = me.outputList[0].updateLeftText();
			me.C1 = me.outputList[0].updateCenterText();
			me.C1[1] = "TIME ";
			me.R1 = ["---/-----", "SPD/ALT   ", "grn"];
		}
		if (size(me.outputList) > 2) {
			me.L2 = me.outputList[1].updateLeftText();
			me.C2 = me.outputList[1].updateCenterText();
			me.R2 = ["---/-----", nil, "grn"];
		}
		if (size(me.outputList) > 3) {
			me.L3 = me.outputList[2].updateLeftText();
			me.C3 = me.outputList[2].updateCenterText();
			me.R3 = ["---/-----", nil, "grn"];
		}
		if (size(me.outputList) > 4) {
			me.L4 = me.outputList[3].updateLeftText();
			me.C4 = me.outputList[3].updateCenterText();
			me.R4 = ["---/-----", nil, "grn"];
		}
		if (size(me.outputList) > 5) {
			me.L5 = me.outputList[4].updateLeftText();
			me.C5 = me.outputList[4].updateCenterText();
			me.R5 = ["---/-----", nil, "grn"];
		}
	},
	destInfo: func() {
		me.L6 = [me.plan.getWP(fmgc.flightPlanController.arrivalIndex[me.planIndex]).wp_name, " DEST", "wht"];
		me.C6 = ["----  " ~ int(fmgc.flightPlanController.arrivalDist), "TIME   DIST", "wht"];
		me.R6 = ["--.-", "EFOB", "wht"];
	},
	update: func() {
		me.destInfo();
		me.basePage();
	},
	scrollUp: func() {
		if (size(me.planList) > 4) {
			me.scroll += 1;
			if (me.scroll > size(me.planList) - 4) {
				me.scroll = 0;
			}
		}
	},
	scrollDn: func() {
		if (size(me.planList) > 4) {
			me.scroll += 1;
			if (me.scroll < 0) {
				me.scroll = size(me.planList) - 4
			}
		}
	},
};
	
var notInDataBase = func(i) {
		if (getprop("/MCDU[" ~ i ~ "]/scratchpad-msg") == 1) {
			setprop("/MCDU[" ~ i ~ "]/last-scratchpad", "NOT IN DATABASE");
		} else {
			setprop("/MCDU[" ~ i ~ "]/last-scratchpad", getprop("/MCDU[" ~ i ~ "]/scratchpad"));
		}
	setprop("/MCDU[" ~ i ~ "]/scratchpad-msg", 1);
	setprop("/MCDU[" ~ i ~ "]/scratchpad", "NOT IN DATABASE");
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
	distances: [],
	new: func(vector, type, computer) {
		var lr = {parents:[duplicateNamesPage]};
		lr.id = vector;
		lr.type = type; # 0 = other, 1 = navaid
		lr.computer = computer;
		lr._setupPageWithData();
		return lr;
	},
	del: func() {
		return nil;
	},
	_setupPageWithData: func() {
		me.title = "DUPLICATE NAMES";
		me.arrowsMatrix = [[0, 0, 0, 0, 0, 1], [0, 0, 0, 0, 0, 0]];
		me.arrowsColour = [["ack", "ack", "ack", "ack", "ack", "wht"], ["ack", "ack", "ack", "ack", "ack", "ack"]];
		me.fontMatrix = [[0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0]];
		
		for (var i = 0; i <= size(me.vector); i += 1) {
			append(distances, courseAndDistance(me.vector[i]));
		}
		
		me.C1[1] = "LAT/LONG";
		me.R1[1] = "FREQ";
		if (size(me.vector) >= 1) {
			me.L1 = [" " ~ me.vector[0 + me.scroll].id, "   " ~ me.distances[0 + me.scroll] ~ "NM", "blu"];
			me.arrowsMatrix[0][0] = 1;
			me.arrowsColour[0][0] = "blu";
			me.C1 = [" " ~ decimalToShortString(me.vector[0 + me.scroll].lat, "lat") ~ "/" ~ decimalToShortString(me.vector[0 + me.scroll].lon, "lon"), "LAT/LONG", "grn"];
			if (me.vector[0 + me.scroll].frequency != nil) {
				me.R1 = [me.vector[0 + me.scroll].frequency, "FREQ", "grn"];
			}
		}
		if (size(me.vector) >= 2) {
			me.L2 = [" " ~ me.vector[0 + me.scroll].id, "   " ~ me.distances[1 + me.scroll] ~ "NM", "blu"];
			me.arrowsMatrix[0][1] = 1;
			me.arrowsColour[0][1] = "blu";
			me.C2 = [" " ~ decimalToShortString(me.vector[1 + me.scroll].lat, "lat") ~ "/" ~ decimalToShortString(me.vector[1 + me.scroll].lon, "lon"), "LAT/LONG", "grn"];
			if (me.vector[1 + me.scroll].frequency != nil) {
				me.R2 = [me.vector[1 + me.scroll].frequency, nil, "grn"];
			}
		}
		if (size(me.vector) >= 3) {
			me.L3 = [" " ~ me.vector[0 + me.scroll].id, "   " ~ me.distances[2 + me.scroll] ~ "NM", "blu"];
			me.arrowsMatrix[0][2] = 1;
			me.arrowsColour[0][2] = "blu";
			me.C3 = [" " ~ decimalToShortString(me.vector[2 + me.scroll].lat, "lat") ~ "/" ~ decimalToShortString(me.vector[2 + me.scroll].lon, "lon"), "LAT/LONG", "grn"];
			if (me.vector[2 + me.scroll].frequency != nil) {
				me.R3 = [me.vector[2 + me.scroll].frequency, nil, "grn"];
			}
		}
		if (size(me.vector) >= 4) {
			me.L4 = [" " ~ me.vector[0 + me.scroll].id, "   " ~ me.distances[3 + me.scroll] ~ "NM", "blu"];
			me.arrowsMatrix[0][3] = 1;
			me.arrowsColour[0][3] = "blu";
			me.C4 = [" " ~ decimalToShortString(me.vector[3 + me.scroll].lat, "lat") ~ "/" ~ decimalToShortString(me.vector[3 + me.scroll].lon, "lon"), "LAT/LONG", "grn"];
			if (me.vector[3 + me.scroll].frequency != nil) {
				me.R4 = [me.vector[3 + me.scroll].frequency, nil, "grn"];
			}
		}
		if (size(me.vector) >= 5) {
			me.L5 = [" " ~ me.vector[0 + me.scroll].id, "   " ~ me.distances[4 + me.scroll] ~ "NM", "blu"];
			me.arrowsMatrix[0][4] = 1;
			me.arrowsColour[0][4] = "blu";
			me.C5 = [" " ~ decimalToShortString(me.vector[4 + me.scroll].lat, "lat") ~ "/" ~ decimalToShortString(me.vector[4 + me.scroll].lon, "lon"), "LAT/LONG", "grn"];
			if (me.vector[4 + me.scroll].frequency != nil) {
				me.R5 = [me.vector[4 + me.scroll].frequency, nil, "grn"];
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
};

var decimalToShortString = func(dms, type) {
	var degrees = split(".", dms)[0];
	if (type == "lat") {
		var sign = degrees >= 0 ? "N" : "S";
	} else {
		var sign = degrees >= 0 ? "E" : "W";
	}
	return abs(degrees) ~ sign;
}