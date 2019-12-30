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
	sids: nil,
	computer: nil,
	enableScroll: 0,
	_runways: nil,
	_sids: nil,
	new: func(icao, computer) {
		var lr = {parents:[departurePage]};
		lr.id = icao;
		lr.computer = computer;
		lr._setupPageWithData();
		lr.updateRunways();
		lr.updateActiveRunway();
		return lr;
	},
	del: func() {
		return nil;
	},
	_setupPageWithData: func() {
		me.title = ["DEPARTURE", " FROM ", left(me.id, 4)];
		if (!TMPYActive[me.computer].getBoolValue()) {
			me.L6 = [" RETURN END", nil, "wht"];
		} else {
			me.L6 = [" F-PLN", " TMPY", "yel"];
			me.arrowsColour[0][5] = "yel";
		}
		
		me.C1 = ["------- ", "SID", "wht"];
		me.R1 = ["-------", "TRANS ", "wht"];
		me.fontMatrix = [[0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0]];
		me.arrowsMatrix = [[0, 0, 0, 0, 0, 1], [0, 0, 0, 0, 0, 0]];
		me.arrowsColour = [["ack", "ack", "ack", "ack", "ack", "wht"], ["ack", "ack", "ack", "ack", "ack", "ack"]];
	},
	updateActiveRunway: func() {
		if (me.selectedRunway != nil) {
			if (fmgc.fp[2].departure_runway != nil) {
				if (fmgc.fp[2].departure_runway.id == me.selectedRunway.id) {
					me.L1 = [fmgc.fp[me.computer].departure_runway.id, " RWY", "grn"];
				} elsif (fmgc.fp[me.computer].departure_runway != nil) {
					me.L1 = [fmgc.fp[me.computer].departure_runway.id, " RWY", "yel"];
				} else {
					me.L1 = ["---", " RWY", "wht"];
				} 
			} elsif (fmgc.fp[me.computer].departure_runway != nil) {
				me.L1 = [fmgc.fp[me.computer].departure_runway.id, " RWY", "yel"];
			} else {
				me.L1 = ["---", " RWY", "wht"];
			}
		} else {
			me.L1 = ["---", " RWY", "wht"];
		}
		canvas_mcdu.pageSwitch[me.computer].setBoolValue(0);
	},
	updateRunways: func() {
		me.depAirport = findAirportsByICAO(left(me.id, 4));
		me._runways = keys(me.depAirport[0].runways);
		me.runways = sort(me._runways,func(a,b) cmp(a,b));
		
		me.fourRunways = [nil, nil, nil, nil];
		
		if (size(me.runways) >= 1) {
			me.L2 = [" " ~ me.runways[0], nil, "blu"];
			me.C2 = [math.round(me.depAirport[0].runways[me.runways[0]].length) ~ "M", nil, "blu"];
			me.R2 = ["CRS" ~ math.round(me.depAirport[0].runways[me.runways[0]].heading), nil, "blu"];
			me.arrowsMatrix[0][1] = 1;
			me.arrowsColour[0][1] = "blu";
		}
		if (size(me.runways) >= 2) {
			me.L3 = [" " ~ me.runways[1], nil, "blu"];
			me.C3 = [math.round(me.depAirport[0].runways[me.runways[1]].length) ~ "M", nil, "blu"];
			me.R3 = ["CRS" ~ math.round(me.depAirport[0].runways[me.runways[1]].heading), nil, "blu"];
			me.arrowsMatrix[0][2] = 1;
			me.arrowsColour[0][2] = "blu";
		}
		if (size(me.runways) >= 3) {
			me.L4 = [" " ~ me.runways[2], nil, "blu"];
			me.C4 = [math.round(me.depAirport[0].runways[me.runways[2]].length) ~ "M", nil, "blu"];
			me.R4 = ["CRS" ~ math.round(me.depAirport[0].runways[me.runways[2]].heading), nil, "blu"];
			me.arrowsMatrix[0][3] = 1;
			me.arrowsColour[0][3] = "blu";
		}
		if (size(me.runways) >= 4) {
			me.L5 = [" " ~ me.runways[3], nil, "blu"];
			me.C5 = [math.round(me.depAirport[0].runways[me.runways[3]].length) ~ "M", nil, "blu"];
			me.R5 = ["CRS" ~ math.round(me.depAirport[0].runways[me.runways[3]].heading), nil, "blu"];
			me.arrowsMatrix[0][4] = 1;
			me.arrowsColour[0][4] = "blu";
		}
		
		if (size(me.runways) > 4) {
			me.enableScroll = 1;
		}
		canvas_mcdu.pageSwitch[me.computer].setBoolValue(0);
	},
	makeTmpy: func() {
		if (!TMPYActive[me.computer].getBoolValue()) {
			fmgc.flightplan.initTempFP(me.computer, 2);
			me.L6 = [" F-PLN", " TMPY", "yel"];
			me.arrowsColour[0][5] = "yel";
			canvas_mcdu.pageSwitch[me.computer].setBoolValue(0);
		}
	},
	depPushbuttonLeft: func(index) {
		if (size(me.runways) >= (index - 1)) {
			me.selectedRunway = me.depAirport[0].runway(me.runways[index - 2]);
			me.makeTmpy();
			fmgc.fp[me.computer].departure_runway = me.selectedRunway;
			me.updateActiveRunway();
			fmgc.flightplan.checkWPOutputs(me.computer);
		} else {
			notAllowed(me.computer);
		}
	},
};