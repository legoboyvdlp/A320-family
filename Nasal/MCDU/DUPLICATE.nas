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
	new: func(vector, index, type, computer, flagPBD = 0, pbdBrg = -999, pbdDist = -99, flagProg = 0) {
		var dn = {parents:[duplicateNamesPage]};
		dn.vector = vector;
		dn.index = index;
		dn.type = type; # 0 = other, 1 = navaid
		dn.flagPBD = flagPBD;
		dn.bearing = pbdBrg;
		dn.distance = pbdDist;
		dn.computer = computer;
		dn.flagPROG = flagProg;
		dn._setupPageWithData();
		dn.distances = [];
		return dn;
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
		if (!dirToFlag) {
			if (!me.flagPBD and !me.flagPROG) {
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
			} elsif (me.flagPBD) {
				fmgc.flightPlanController.getWPforPBD(me.vector[0].id ~ "/" ~ me.bearing ~ "/" ~ me.distance, me.index, me.computer, 1, indexSelect - 1);
				setprop("MCDU[" ~ me.computer ~ "]/page", "F-PLNA");
			} else {
				if (me.type == 0) {
					mcdu.bearingDistances[me.computer].newPointResult(me.vector, 1, indexSelect - 1);
				} else {
					mcdu.bearingDistances[me.computer].newPointNavaid(me.vector, 1, indexSelect - 1);
				}
				pagebutton("prog",me.computer);
			}
		} else {
			canvas_mcdu.myDirTo[me.computer].fieldL1(me.vector[0].id, 1, indexSelect - 1);
			setprop("MCDU[" ~ me.computer ~ "]/page", "DIRTO");
		}
	},
};