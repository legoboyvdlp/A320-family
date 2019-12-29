var latRev = {
	title: [nil, nil, nil],
	subtitle: [nil, nil],
	fontMatrix: [[0, 0, 0, 0, 0, 0],[0, 0, 0, 0, 0, 0]],
	arrowsMatrix: [[0, 0, 0, 0, 0, 0],[0, 0, 0, 0, 0, 0]],
	L1: [nil, nil, "ack"], # content, title, colour
	L2: [nil, nil, "ack"],
	L3: [nil, nil, "ack"],
	L4: [nil, nil, "ack"],
	L5: [nil, nil, "ack"],
	L6: [nil, nil, "ack"],
	R1: [nil, nil, "ack"],
	R2: [nil, nil, "ack"],
	R3: [nil, nil, "ack"],
	R4: [nil, nil, "ack"],
	R5: [nil, nil, "ack"],
	R6: [nil, nil, "ack"],
	depAirport: nil,
	arrAirport: nil,
	new: func(type, id) {
		var lr = {parents:[latRev]};
		lr.type = type; # 0 = origin 1 = destination 2 = ppos (from waypoint) 3 = generic wpt
		lr.id = id;
		lr._setupPageWithData();
		return lr;
	},
	del: func() {
		return nil;
	},
	_setupPageWithData: func() {
		if (me.type == 2) { 
			me.title = ["LAT REV", " FROM ", "PPOS"];
			me.L2 = [" OFFSET", nil, "wht"];
			me.L3 = [" HOLD", nil, "wht"];
			me.L6 = [" RETURN", nil, "wht"];
			me.R1 = ["FIX INFO ", nil, "wht"];
			me.R2 = ["[      ]°/[    ]°/[   ]", "LL XING/INCR/NO", "blu"];
			me.arrowsMatrix = [[0, 1, 1, 0, 0, 1], [1, 0, 0, 0, 0, 0]];
			me.fontMatrix = [[0, 0, 0, 0, 0, 0], [0, 1, 0, 0, 0, 0]];
		} else {
			me.title = ["LAT REV", " FROM ", me.id];
			
			if (me.type == 0) {
				me.depAirport = findAirportsByICAO(me.id);
				me.subtitle = [dmsToString(sprintf(me.depAirport[0].lat), "lat"), dmsToString(sprintf(me.depAirport[0].lon), "lon")];
				me.L1 = [" DEPARTURE", nil, "wht"];
				me.L2 = [" OFFSET", nil, "wht"];
				me.L6 = [" RETURN", nil, "wht"];
				me.R1 = ["FIX INFO ", nil, "wht"];
				me.R2 = ["[      ]°/[    ]°/[   ]", "LL XING/INCR/NO", "blu"];
				me.R3 = ["[      ]", "NEXT WPT ", "blu"];
				me.R4 = ["[    ]", "NEW DEST", "blu"];
				me.arrowsMatrix = [[1, 1, 0, 0, 0, 1], [1, 0, 0, 0, 0, 0]];
				me.fontMatrix = [[0, 0, 0, 0, 0, 0], [0, 1, 1, 1, 0, 0]];
			} elsif (me.type == 1) {
				me.arrAirport = findAirportsByICAO(me.id);
				me.subtitle = [dmsToString(sprintf(me.arrAirport[0].lat), "lat"), dmsToString(sprintf(me.arrAirport[0].lon), "lon")];
				me.L3 = [" ALTN", nil, "wht"];
				me.L4 = [" ALTN", "ENABLE", "blu"];
				me.L6 = [" RETURN", nil, "wht"];
				me.R1 = ["ARRIVAL ", nil, "wht"];
				me.R3 = ["[      ]", "NEXT WPT ", "blu"];
				me.arrowsMatrix = [[0, 0, 1, 1, 0, 1], [1, 0, 0, 0, 0, 0]];
				me.fontMatrix = [[0, 0, 0, 0, 0, 0], [0, 0, 1, 0, 0, 0]];
			} elsif (me.type == 3) {
				if (size(me.id) == 2 or size(me.id) == 3) {
					me.wpt = findNavaidsByID(me.id);
				} elsif (size(me.id) == 4) {
					me.wpt = findAirportsByICAO(me.id);
				} elsif (size(me.id) == 5) {
					me.wpt = findFixesByID(me.id);
				}
				me.subtitle = [dmsToString(sprintf(me.wpt[0].lat), "lat"), dmsToString(sprintf(me.wpt[0].lon), "lon")];
				me.L3 = [" HOLD", nil, "wht"];
				me.L4 = [" ALTN", "ENABLE", "blu"];
				me.L6 = [" RETURN", nil, "wht"];
				me.R1 = ["FIX INFO ", nil, "wht"];
				me.R3 = ["[      ]", "NEXT WPT ", "blu"];
				me.R4 = ["[    ]", "NEW DEST", "blu"];
				me.R5 = ["AIRWAYS ", nil, "wht"];
				me.arrowsMatrix = [[0, 0, 1, 1, 0, 1], [1, 0, 0, 0, 1, 0]];
				me.fontMatrix = [[0, 0, 0, 0, 0, 0], [0, 0, 1, 1, 0, 0]];
			}
		}
	},
};

var dmsToString = func(dms, type) {
	var decimalSplit = split(".", dms);
	var degrees = decimalSplit[0];
	var minutes = decimalSplit[1] * 60;
	if (type == "lat") {
		var sign = degrees >= 0 ? "N" : "S";
	} else {
		var sign = degrees >= 0 ? "E" : "W";
	}
	return degrees ~ "g" ~ minutes ~ " " ~ sign;
}