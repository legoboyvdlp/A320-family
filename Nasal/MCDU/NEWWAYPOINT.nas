var newWaypointPage = {
	title: nil,
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
	new: func(computer) {
		var ap = {parents:[newWaypointPage]};
		ap.computer = computer;
		ap._setupPageWithData();
		return ap;
	},
	del: func() {
		return nil;
	},
	_setupPageWithData: func() {
		me.title = "PILOTS WAYPOINT";
		me.L1 = [fmgc.WaypointDatabase.waypointsVec[me.scroll].id, "  IDENT", "grn"];
		
		var ghost = fmgc.WaypointDatabase.waypointsVec[me.scroll].wpGhost;
		me.L2 = [me.translateLatitude(ghost.lat) ~ "/" ~ me.translateLongitude(ghost.lon), "     LAT/LON", "grn"];
		
		me.R5 = ["WAYPOINT ", "NEW ", "wht"];
		me.R6 = ["DELETE ALL ", nil, "blu"];
		
		me.arrowsMatrix = [[0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 1, 1]];
		me.arrowsColour = [["ack", "ack", "ack", "ack", "ack", "ack"], ["ack", "ack", "ack", "ack", "wht", "blu"]];
		canvas_mcdu.pageSwitch[me.computer].setBoolValue(0);
	},
	translateLatitude: func(latitude) {
		var split = split(".", sprintf("%s", latitude));
		var degree = split[0];
		if (latitude >= 0) {
			var decimal = sprintf("%04.1f", (latitude - num(degree)) * 60);
			return sprintf("%02.0f", degree) ~ decimal ~ "N";
		} else {
			var decimal = sprintf("%04.1f", (latitude - num(degree)) * 60);
			return sprintf("%02.0f", degree) ~ decimal ~ "S";
		}
	},
	translateLongitude: func(longitude) {
		var split = split(".", sprintf("%s", longitude));
		var degree = split[0];
		if (longitude >= 0) {
			var decimal = sprintf("%04.1f", (longitude - num(degree)) * 60);
			return sprintf("%03.0f", degree) ~ decimal ~ "E";
		} else {
			var decimal = sprintf("%04.1f", (longitude - num(degree)) * 60);
			return sprintf("%03.0f", degree) ~ decimal ~ "W";
		}
	},
	deleteCmd: func() {
		if (fmgc.WaypointDatabase.confirm[me.computer]) {
			me.R6 = ["CONFIRM DELETE ALL ", nil, "amb"];
			me.arrowsColour[1][5] = "amb";
			canvas_mcdu.pageSwitch[me.computer].setBoolValue(0);
		} else {
			me.R6 = ["DELETE ALL ", nil, "blu"];
			me.arrowsColour[1][5] = "blu";
			fmgc.WaypointDatabase.delete(me.computer);
			me.scroll = fmgc.WaypointDatabase.getNonNilIndex();
			me._setupPageWithData();
			canvas_mcdu.pageSwitch[me.computer].setBoolValue(0);
		}
	},
};