# Copyright (c) 2020 Josh Davidson (Octal450), Jonathan Redpath (legoboyvdlp), and Matthew Maring (mattmaring)
var normal = 70;
var small = 56;

var fplnItem = {
	new: func(wp, index, plan, computer, colour = "grn") {
		var fI = {parents:[fplnItem]};
		fI.type = "fpln_item";
		fI.wp = wp;
		fI.index = index;
		fI.plan = plan;
		fI.computer = computer;
		fI.colour = colour;
		fI.assembledStr = [nil, nil, colour, colour, small];
		return fI;
	},
	updateLeftText: func(page) {
		if (me.wp != nil) {
			if (me.wp.wp_name == "T-P") {
				return ["T-P", nil, me.colour];
			} elsif (me.wp.wp_name != "DISCONTINUITY") {
				var wptName = split("-", me.wp.wp_name);
				if (wptName[0] == "VECTORS") {
					return ["MANUAL", me.getSubText(), me.colour];
				} else {
					if (size(wptName) == 2) {
						return[wptName[0] ~ wptName[1], me.getSubText(), me.colour];
					} else {
						return [me.wp.wp_name, me.getSubText(), me.colour];
					}
				}
			} else {
				return [nil, nil, "ack"];
			}
		} else {
			return ["problem", nil, "ack"];
		}
	},
	getSubText: func() {
		return nil;
	},
	updateCenterText: func(page) {
		if (me.wp != nil) { 
			if (me.wp.wp_name != "DISCONTINUITY" and page == "A") {
				if (me.index == fmgc.flightPlanController.currentToWptIndex.getValue() - 1 and fmgc.flightPlanController.fromWptTime != nil) {
					me.assembledStr[0] = fmgc.flightPlanController.fromWptTime ~ "   ";
					me.assembledStr[2] = me.colour;
					me.assembledStr[3] = me.colour;
					me.assembledStr[4] = small;
				} else {
					me.assembledStr[0] = me.getTime()[0];
					me.assembledStr[2] = me.getTime()[1];
					me.assembledStr[3] = me.colour;
					me.assembledStr[4] = small;
				}
				if (me.index == fmgc.flightPlanController.currentToWptIndex.getValue()) {
					me.assembledStr[1] = "BRG" ~ me.getBrg() ~ "   ";
				} elsif (me.index == (fmgc.flightPlanController.currentToWptIndex.getValue() + 1) or me.index == (fmgc.flightPlanController.arrivalIndex[me.plan] + 1)) {
					me.assembledStr[1] = "TRK" ~ me.getTrack() ~ "   ";
				} else {
					me.assembledStr[1] = nil;
				}
				return me.assembledStr;
			} else if (me.wp.wp_name != "DISCONTINUITY" and page == "B") {
				me.assembledStr[0] = me.getFuel()[0];
				me.assembledStr[2] = me.getFuel()[1];
				me.assembledStr[3] = me.colour;
				me.assembledStr[4] = small;
				if (me.index == fmgc.flightPlanController.currentToWptIndex.getValue()) {
					me.assembledStr[1] = "BRG" ~ me.getBrg() ~ "   ";
				} elsif (me.index == (fmgc.flightPlanController.currentToWptIndex.getValue() + 1) or me.index == (fmgc.flightPlanController.arrivalIndex[me.plan] + 1)) {
					me.assembledStr[1] = "TRK" ~ me.getTrack() ~ "   ";
				} else {
					me.assembledStr[1] = nil;
				}
				return me.assembledStr;
			} else {
				return ["---F-PLN DISCONTINUITY--", nil, "wht", "ack", normal];
			}
		} else {
			return ["problem", nil, "ack", "ack", normal];
		}
	},
	updateRightText: func(page) {
		if (me.wp != nil) {
			if (me.wp.wp_name != "DISCONTINUITY" and page == "A") {
				me.alt = me.getAlt();
				me.dist = me.getDist();
				return ["   /" ~ me.alt[0], " " ~ me.dist ~ "NM    ", me.alt[1], me.colour];
			} else if (me.wp.wp_name != "DISCONTINUITY" and page == "B") {
				me.hdg = me.getHdg();
				me.mag = ["---", "wht"]; #me.getMag();
				me.dist = me.getDist();
				if (me.hdg[1] == "wht" and me.mag[1] == "wht") {
					return [me.hdg[0] ~ "g/" ~ me.mag[0], " " ~ me.dist ~ "NM    ", "wht", me.colour];
				} else {
					return [me.hdg[0] ~ "g/" ~ me.mag[0], " " ~ me.dist ~ "NM    ", me.colour, me.colour];
				}
			} else {
				return [nil, nil, "ack", "ack"];
			}
		} else {
			return ["problem", nil, "ack", "ack"];
		}
	},
	updateRightBText: func(page) {
		if (me.wp != nil) {
			if (me.wp.wp_name != "DISCONTINUITY" and page == "A") {
				me.spd = me.getSpd();
				return [me.spd[0] ~ "       ", nil, me.spd[1]];
			} else {
				return [nil, nil, "ack"];
			}
		} else {
			return ["problem", nil, "ack"];
		}
	},
	getTime: func() {
		if (me.plan == 2 and fmgc.FMGCInternal.blockSet and fmgc.FMGCInternal.tripFuel > 0) {
			if (me.index == fmgc.flightPlanController.arrivalIndex[me.plan]) {
				return [fmgc.FMGCInternal.tripTime ~ "   ", me.colour];
			} else if (me.index < fmgc.flightPlanController.arrivalIndex[me.plan] and fmgc.time_values[me.plan][me.index] != nil) {
				return [fmgc.time_values[me.plan][me.index] ~ "   ", me.colour];
			} else {
				return ["----   ", "wht"];
			}
		} else {
			return ["----   ", "wht"];
		}
	},
	getBrg: func() {
		var wp = fmgc.flightPlanController.flightplans[me.plan].getWP(me.index);
		var courseDistanceFrom = courseAndDistance(wp);
		me.brg = courseDistanceFrom[0] - magvar();
		if (me.brg < 0) { me.brg += 360; }
		if (me.brg > 360) { me.brg -= 360; }
		return sprintf("%03.0f", math.round(me.brg));
	},
	getTrack: func() {
		var wp = fmgc.flightPlanController.flightplans[me.plan].getWP(me.index);
		me.trk = me.wp.leg_bearing - magvar(wp.lat, wp.lon);
		if (me.trk < 0) { me.trk += 360; }
		if (me.trk > 360) { me.trk -= 360; }
		return sprintf("%03.0f", math.round(me.trk));
	},
	getFuel: func() {
		if (me.plan == 2 and fmgc.FMGCInternal.blockSet and fmgc.FMGCInternal.tripFuel > 0) {
			if (me.index == fmgc.flightPlanController.arrivalIndex[me.plan]) {
				return [sprintf("%.1f", fmgc.FMGCInternal.block - fmgc.FMGCInternal.taxiFuel - fmgc.FMGCInternal.tripFuel), me.colour];
			} else if (me.index < fmgc.flightPlanController.arrivalIndex[me.plan] and fmgc.efob_values[me.plan][me.index] != nil) {
				return [sprintf("%.1f", fmgc.efob_values[me.plan][me.index]), me.colour];
			} else {
				return ["--.-", "wht"];
			}
		} else {
			return ["--.-", "wht"];
		}
	},
	getSpd: func() {
		if (me.index == 0 and left(me.wp.wp_name, 4) == fmgc.FMGCInternal.depApt and fmgc.FMGCInternal.v1set) {
			return [sprintf("%3.0f", math.round(fmgc.FMGCInternal.v1)), me.colour];
		} elsif (me.wp.speed_cstr != nil and me.wp.speed_cstr != 0) {
			var _colour = me.colour;
			if (me.wp.alt_cstr_type == "above") {
				_colour = "mag";
			} else if (me.wp.alt_cstr_type == "below") {
				_colour = "mag";
			} else if (me.wp.alt_cstr_type == "at") {
				_colour = "mag";
			}
			return [sprintf("%3.0f", me.wp.speed_cstr), _colour];
		} else {
			return ["---", "wht"];
		}
	},
	getAlt: func() {
		if (me.index == 0 and left(me.wp.wp_name, 4) == fmgc.FMGCInternal.depApt and fmgc.flightPlanController.flightplans[me.plan].departure != nil) {
			return [" " ~ sprintf("%5.0f", math.round(fmgc.flightPlanController.flightplans[me.plan].departure.elevation * M2FT)), me.colour];
		} elsif (me.index == (fmgc.flightPlanController.currentToWptIndex.getValue() - 1) and fmgc.flightPlanController.fromWptAlt != nil) {
			return [" " ~ fmgc.flightPlanController.fromWptAlt, me.colour];
		} elsif (me.wp.alt_cstr != nil and me.wp.alt_cstr != 0) {
			var _colour = me.colour;
			var _blank = " ";
			if (me.wp.alt_cstr_type == "above") {
				_colour = "mag";
				_blank = "+";
			} else if (me.wp.alt_cstr_type == "below") {
				_colour = "mag";
				_blank = "-";
			} else if (me.wp.alt_cstr_type == "at") {
				_colour = "mag";
				_blank = " ";
			}
			if (me.wp.alt_cstr >= 10000) {
				return [_blank ~ sprintf("%5s", "FL" ~ math.round(num(me.wp.alt_cstr) / 100)), _colour];
			} else {
				return [_blank ~ sprintf("%5.0f", me.wp.alt_cstr), _colour];
			}
		} else {
			return [" -----", "wht"];
		}
	},
	getDist: func() {
		var wp = fmgc.flightPlanController.flightplans[me.plan].getWP(me.index);
		if (me.index == fmgc.flightPlanController.currentToWptIndex.getValue()) {
			var courseDistanceFrom = courseAndDistance(wp);
			return math.round(courseDistanceFrom[1]);
		} else {
			return math.round(wp.leg_distance);
		}
	},
	getHdg: func() {
		if (me.index < fmgc.flightPlanController.arrivalIndex[me.plan]) {
			return ["---", "wht"];
		} else {
			return ["---", "wht"];
		}
	},
	pushButtonLeft: func() {
		if (canvas_mcdu.myLatRev[me.computer] != nil) {
			canvas_mcdu.myLatRev[me.computer].del();
		}
		canvas_mcdu.myLatRev[me.computer] = nil;
		
		if (me.wp.wp_name == "DISCONTINUITY") {
			canvas_mcdu.myLatRev[me.computer] = latRev.new(4, me.wp, me.index, me.computer);
		} elsif (fmgc.flightPlanController.temporaryFlag[me.computer]) {
			if (me.index == fmgc.flightPlanController.arrivalIndex[me.computer]) {
				canvas_mcdu.myLatRev[me.computer] = latRev.new(1, me.wp, me.index, me.computer);
			} elsif (left(me.wp.wp_name, 4) == fmgc.flightPlanController.flightplans[me.computer].departure.id) {
				canvas_mcdu.myLatRev[me.computer] = latRev.new(0, me.wp, me.index, me.computer);
			} elsif (me.index == (fmgc.flightPlanController.currentToWptIndex.getValue() - 1)) {
				canvas_mcdu.myLatRev[me.computer] = latRev.new(2, me.wp, me.index, me.computer);
			} else {
				canvas_mcdu.myLatRev[me.computer] = latRev.new(3, me.wp, me.index, me.computer);
			}
		} else {
			if (me.index == fmgc.flightPlanController.arrivalIndex[2]) {
				canvas_mcdu.myLatRev[me.computer] = latRev.new(1, me.wp, me.index, me.computer);
			} elsif (left(me.wp.wp_name, 4) == fmgc.flightPlanController.flightplans[2].departure.id) {
				canvas_mcdu.myLatRev[me.computer] = latRev.new(0, me.wp, me.index, me.computer);
			} elsif (me.index == (fmgc.flightPlanController.currentToWptIndex.getValue() - 1)) {
				canvas_mcdu.myLatRev[me.computer] = latRev.new(2, me.wp, me.index, me.computer);
			} else {
				canvas_mcdu.myLatRev[me.computer] = latRev.new(3, me.wp, me.index, me.computer);
			}
		}
		setprop("MCDU[" ~ me.computer ~ "]/page", "LATREV");
	},
	pushButtonRight: func() {
		if (size(mcdu_scratchpad.scratchpads[me.computer].scratchpad) == 0) {
			if (canvas_mcdu.myVertRev[me.computer] != nil) {
				canvas_mcdu.myVertRev[me.computer].del();
			}
			canvas_mcdu.myVertRev[me.computer] = nil;
			
			if (fmgc.flightPlanController.temporaryFlag[me.computer]) {
				if (me.index == fmgc.flightPlanController.arrivalIndex[me.computer]) {
					canvas_mcdu.myVertRev[me.computer] = vertRev.new(1, left(me.wp.wp_name, 4), me.index, me.computer, me.wp, me.plan);
				} if (left(me.wp.wp_name, 4) == fmgc.flightPlanController.flightplans[me.computer].departure.id) {
					canvas_mcdu.myVertRev[me.computer] = vertRev.new(0, left(me.wp.wp_name, 4), me.index, me.computer, me.wp, me.plan);
				} elsif (me.index == (fmgc.flightPlanController.currentToWptIndex.getValue() - 1)) {
					canvas_mcdu.myVertRev[me.computer] = vertRev.new(3, me.wp.wp_name, me.index, me.computer, me.wp, me.plan);
				} else {
					canvas_mcdu.myVertRev[me.computer] = vertRev.new(2, me.wp.wp_name, me.index, me.computer, me.wp, me.plan);
				}
			} else {
				if (me.index == fmgc.flightPlanController.arrivalIndex[2]) {
					canvas_mcdu.myVertRev[me.computer] = vertRev.new(1, left(me.wp.wp_name, 4), me.index, me.computer, me.wp, me.plan);
				} elsif (left(me.wp.wp_name, 4) == fmgc.flightPlanController.flightplans[2].departure.id) {
					canvas_mcdu.myVertRev[me.computer] = vertRev.new(0, left(me.wp.wp_name, 4), me.index, me.computer, me.wp, me.plan);
				} elsif (me.index == (fmgc.flightPlanController.currentToWptIndex.getValue() - 1)) {
					canvas_mcdu.myVertRev[me.computer] = vertRev.new(3, me.wp.wp_name, me.index, me.computer, me.wp, me.plan);
				} else {
					canvas_mcdu.myVertRev[me.computer] = vertRev.new(2, me.wp.wp_name, me.index, me.computer, me.wp, me.plan);
				}
			}
			setprop("MCDU[" ~ me.computer ~ "]/page", "VERTREV");
		} elsif (me.index != 0) { # todo - only apply to climb, descent, or missed waypoints
			var scratchpadStore = mcdu_scratchpad.scratchpads[me.computer].scratchpad;
			
			if (scratchpadStore == "CLR") {
				me.wp.setSpeed(nil, "computed");
				me.wp.setAltitude(nil, "computed");
				mcdu_scratchpad.scratchpads[me.computer].empty();
			} elsif (find("/",  scratchpadStore) != -1) {
				var scratchpadSplit = split("/", scratchpadStore);
				
				if (size(scratchpadSplit[0]) == 0) {
					if (num(scratchpadSplit[1]) != nil and (size(scratchpadSplit[1]) == 4 or size(scratchpadSplit[1]) == 5) and scratchpadSplit[1] >= 0 and scratchpadSplit[1] <= 39000) {
						me.wp.setAltitude(math.round(scratchpadSplit[1], 10), "at");
						mcdu_scratchpad.scratchpads[me.computer].empty();
					} else {
						mcdu_message(me.computer, "FORMAT ERROR");
					}
				} else {
					if (num(scratchpadSplit[0]) != nil and size(scratchpadSplit[0]) == 3 and scratchpadSplit[0] >= 100 and scratchpadSplit[0] <= 350 and
						num(scratchpadSplit[1]) != nil and (size(scratchpadSplit[1]) == 4 or size(scratchpadSplit[1]) == 5) and scratchpadSplit[1] >= 0 and scratchpadSplit[1] <= 39000) {
						me.wp.setSpeed(scratchpadSplit[0], "at");
						me.wp.setAltitude(math.round(scratchpadSplit[1], 10), "at");
						mcdu_scratchpad.scratchpads[me.computer].empty();
					} elsif (num(scratchpadSplit[0]) != nil and size(scratchpadSplit[0]) == 3 and scratchpadSplit[0] >= 100 and scratchpadSplit[0] <= 350 and size(scratchpadSplit[1]) == 0) {
						me.wp.setSpeed(scratchpadSplit[0], "at");
						mcdu_scratchpad.scratchpads[me.computer].empty();
					} else {
						mcdu_message(me.computer, "FORMAT ERROR");
					}
				}
			} elsif (num(scratchpadStore) != nil and size(scratchpadStore) == 3 and scratchpadStore >= 100 and scratchpadStore <= 350) {
				me.wp.setSpeed(scratchpadStore, "at");
				mcdu_scratchpad.scratchpads[me.computer].empty();
			} else {
				mcdu_message(me.computer, "FORMAT ERROR");
			}
		} else {
			mcdu_message(me.computer, "NOT ALLOWED");
		}
	},
};

var psuedoItem = {
	new: func(name, plan, computer, colour = "grn") {
		var pI = {parents:[psuedoItem]};
		pI.name = name;
		if (name == "(T/C)") {
			pI.wp = createWP({lat: fmgc.FMGCInternal.tocPoint.lat, lon: fmgc.FMGCInternal.tocPoint.lon}, "(T/C)");
			pI.index = fmgc.FMGCInternal.tocIndex[plan];
		} else if (name == "(T/D)") {
			pI.wp = createWP({lat: fmgc.FMGCInternal.todPoint.lat, lon: fmgc.FMGCInternal.todPoint.lon}, "(T/D)");
			pI.index = fmgc.FMGCInternal.todIndex[plan];
		}
		pI.type = "psuedo_item";
		pI.plan = plan;
		pI.computer = computer;
		pI.colour = colour;
		pI.assembledStr = [nil, nil, colour];
		return pI;
	},
	updateLeftText: func(page) {
		if (me.name != nil) { 
			return [me.name, nil, me.colour];
		} else {
			return ["problem", nil, "ack"];
		}
	},
	updateCenterText: func(page) {
		if (me.name != nil) {
			if (page == "A") {
				return me.getTime();
			} else if (page == "B") {
				return me.getFuel();
			} else {
				return [nil, nil, "ack", "ack", normal];
			}
		} else {
			return ["problem", nil, "ack", "ack", normal];
		}
	},
	updateRightText: func(page) {
		if (me.name != nil) {
			if (page == "A") {
				me.alt = me.getAlt();
				me.dist = me.getDist();
				return ["   /" ~ me.alt[0], " " ~ me.dist ~ "NM    ", me.alt[1], me.colour]; # to do: separate NM symbol 
			} else if (page == "B") {
				me.hdg = ["---", "wht"]; #me.getHdg();
				me.mag = ["---", "wht"]; #me.getMag();
				me.dist = me.getDist();
				if (me.hdg[1] == "wht" and me.mag[1] == "wht") {
					return [me.hdg[0] ~ "g/" ~ me.mag[0], " " ~ me.dist ~ "NM    ", "wht", me.colour];
				} else {
					return [me.hdg[0] ~ "g/" ~ me.mag[0], " " ~ me.dist ~ "NM    ", me.colour, me.colour];
				}
			} else {
				return [nil, nil, "ack"];
			}
		} else {
			return ["problem", nil, "ack"];
		}
	},
	updateRightBText: func(page) {
		if (me.name != nil) {
			if (page == "A") {
				me.spd = ["---", "wht"]; #me.getSpd();
				return [me.spd[0] ~ "       ", nil, me.spd[1]];
			} else {
				return [nil, nil, "ack"];
			}
		} else {
			return ["problem", nil, "ack"];
		}
	},
	getTime: func() {
		if (me.plan == 2 and me.name == "(T/C)" and fmgc.FMGCInternal.clbTime_num > 0) {
			return [fmgc.FMGCInternal.clbTime ~ "   ", nil, me.colour, me.colour, small];
		} else if (me.plan == 2 and me.name == "(T/D)" and fmgc.FMGCInternal.desTime_num > 0) {
			_desTime = fmgc.FMGCInternal.tripTime_num - fmgc.FMGCInternal.desTime_num;
			if (num(_desTime) >= 60) {
				des_min = int(math.mod(_desTime, 60));
				des_hour = int((_desTime - des_min) / 60);
				return [sprintf("%02d", des_hour) ~ sprintf("%02d", des_min) ~ "   ", nil, me.colour, me.colour, small];
			} else {
				return [sprintf("%04d", _desTime) ~ "   ", nil, me.colour, me.colour, small];
			}
		} else {
			return ["----   ", nil, "wht", me.colour, small];
		}
	},
	getFuel: func() {
		if (me.plan == 2 and me.name == "(T/C)" and fmgc.FMGCInternal.clbFuel > 0) {
			_clbFuel = fmgc.FMGCInternal.block - fmgc.FMGCInternal.taxiFuel - fmgc.FMGCInternal.clbFuel / 1000;
			return [sprintf("%.1f", _clbFuel), nil, me.colour, me.colour, small];
		} else if (me.plan == 2 and me.name == "(T/D)" and fmgc.FMGCInternal.desFuel > 0) {
			_desFuel = fmgc.FMGCInternal.block - fmgc.FMGCInternal.taxiFuel - fmgc.FMGCInternal.tripFuel + fmgc.FMGCInternal.desFuel / 1000;
			return [sprintf("%.1f", _desFuel), nil, me.colour, me.colour, small];
		} else {
			return ["----   ", nil, "wht", me.colour];
		}
	},
	getAlt: func() {
		if (me.name == "(T/C)" or me.name == "(T/D)") {
			if (fmgc.FMGCInternal.crzFt >= 10000) {
				return [sprintf(" %s", "FL" ~ fmgc.FMGCInternal.crzFl), me.colour];
			} else {
				return ["  " ~ fmgc.FMGCInternal.crzFt, me.colour];
			}
		} else {
			return ["------", "wht"];
		}
	},
	getDist: func() {
		var _distance = 0;
		for (var i = me.index - 1; i > 0; i -= 1) {
			_distance += fmgc.flightPlanController.flightplans[me.plan].getWP(i).leg_distance;
		}
		if (me.name == "(T/C)") {
			return math.round(fmgc.FMGCInternal.clbDist - fmgc.flightPlanController.traversedDist - _distance);
		} else if (me.name == "(T/D)") {
			return math.round(fmgc.flightPlanController.arrivalDist.getValue() - fmgc.FMGCInternal.desDist - _distance);
		} else {
			return 0;
		}
	},
	pushButtonLeft: func() {
		if (me.name == "(T/C)" or me.name == "(T/D)") {
			if (canvas_mcdu.myLatRev[me.computer] != nil) {
				canvas_mcdu.myLatRev[me.computer].del();
			}
			canvas_mcdu.myLatRev[me.computer] = nil;
			canvas_mcdu.myLatRev[me.computer] = latRev.new(3, me.wp, me.index, me.computer);
			setprop("MCDU[" ~ me.computer ~ "]/page", "LATREV");
		} else {
			mcdu_message(me.computer, "NOT ALLOWED");
		}
	},
	pushButtonRight: func() {
		if (size(mcdu_scratchpad.scratchpads[me.computer].scratchpad) == 0) {
			if (canvas_mcdu.myVertRev[me.computer] != nil) {
				canvas_mcdu.myVertRev[me.computer].del();
			}
			canvas_mcdu.myVertRev[me.computer] = nil;
			if (me.name == "(T/C)") {
				canvas_mcdu.myVertRev[me.computer] = vertRev.new(4, me.name, me.index, me.computer, me.wp, me.plan);
				setprop("MCDU[" ~ me.computer ~ "]/page", "VERTREV");
			} else if (me.name == "(T/D)") {
				canvas_mcdu.myVertRev[me.computer] = vertRev.new(5, me.name, me.index, me.computer, me.wp, me.plan);
				setprop("MCDU[" ~ me.computer ~ "]/page", "VERTREV");
			} else {
				mcdu_message(me.computer, "NOT ALLOWED");
			}
		} else {
			mcdu_message(me.computer, "NOT ALLOWED");
		}
	},
};

var staticText = {
	new: func(computer, text) {
		var sT = {parents:[staticText]};
		sT.type = "static_item";
		sT.computer = computer;
		sT.text = text;
		return sT;
	},
	updateLeftText: func(page) {
		return [nil, nil, "ack"];
	},
	updateCenterText: func(page) {
		return [me.text, nil, "wht", "ack", normal];
	},
	updateRightText: func(page) {
		return [nil, nil, "ack", "ack"];
	},
	updateRightBText: func(page) {
		return [nil, nil, "ack"];
	},
	pushButtonLeft: func() {
		mcdu_message(me.computer, "NOT ALLOWED");
	},
	pushButtonRight: func() {
		mcdu_message(me.computer, "NOT ALLOWED");
	},
};

var pseudoItem = {
	new: func(computer, text) {
		var pI = {parents:[pseudoItem]};
		pI.computer = computer;
		pI.text = text;
		pI.colour = colour;
		return pI;
	},
	updateLeftText: func() {
		return [me.text, nil, me.colour];
	},
	updateCenterText: func() {
		return ["----", nil, "wht"];
	},
	updateRightText: func() {
		return ["---/------", " --NM    ", "wht"];
	},
	pushButtonLeft: func() {
		mcdu_message(me.computer, "NOT ALLOWED");
	},
	pushButtonRight: func() {
		mcdu_message(me.computer, "NOT ALLOWED");
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
	C1: [nil, nil, "ack", "ack", small],
	C2: [nil, nil, "ack", "ack", small],
	C3: [nil, nil, "ack", "ack", small],
	C4: [nil, nil, "ack", "ack", small],
	C5: [nil, nil, "ack", "ack", small],
	C6: [nil, nil, "ack", "ack", small],
	R1: [nil, nil, "ack", "ack"],
	R2: [nil, nil, "ack", "ack"],
	R3: [nil, nil, "ack", "ack"],
	R4: [nil, nil, "ack", "ack"],
	R5: [nil, nil, "ack", "ack"],
	R6: [nil, nil, "ack", "ack"],
	R1B: [nil, nil, "ack"],
	R2B: [nil, nil, "ack"],
	R3B: [nil, nil, "ack"],
	R4B: [nil, nil, "ack"],
	R5B: [nil, nil, "ack"],
	
	planList: [],
	outputList: [],
	scroll: 0,
	scroll_index: 0,
	page: "A",
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
		} else if (type == "decel") { 
			return "(DECEL)";
		} else if (type == "empty") {
			return "";
		}
	},
	createPlanList: func() {
		me.planList = [];
		if (me.temporaryFlagFpln) {
			colour = "yel";
		} else {
			colour = "grn";
		}
		
		var startingIndex = fmgc.flightPlanController.currentToWptIndex.getValue() == -1 ? 0 : fmgc.flightPlanController.currentToWptIndex.getValue() - 1;
		for (var i = startingIndex; i < me.plan.getPlanSize(); i += 1) {
			if (!fmgc.FMGCInternal.clbReached and i == fmgc.FMGCInternal.tocIndex[me.planIndex]) {
				append(me.planList, psuedoItem.new("(T/C)", me.planIndex, me.computer, colour));
			}
			if (!fmgc.FMGCInternal.desReached and i == fmgc.FMGCInternal.todIndex[me.planIndex]) {
				append(me.planList, psuedoItem.new("(T/D)", me.planIndex, me.computer, colour));
			}
			if (!me.temporaryFlagFpln and i > fmgc.flightPlanController.arrivalIndex[me.planIndex] and fmgc.FMGCInternal.phase != 6) {
				append(me.planList, fplnItem.new(me.plan.getWP(i), i, me.planIndex, me.computer, "blu"));
			} else {
				append(me.planList, fplnItem.new(me.plan.getWP(i), i, me.planIndex, me.computer, colour));
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
			me.L1 = me.outputList[0].updateLeftText(me.page);
			me.C1 = me.outputList[0].updateCenterText(me.page);
			me.R1 = me.outputList[0].updateRightText(me.page);
			me.R1B = me.outputList[0].updateRightBText(me.page);
			if (me.page == "A") {
				me.C1[1] = "TIME   "; # to-do add UTC
				me.R1[1] = "SPD/ALT   ";
			} else if (me.page == "B") {
				me.C1[1] = "EFOB";
				me.R1[1] = "T.WIND ";
			}
		} else {
			me.L1 = [nil, nil, "ack"];
			me.C1 = [nil, nil, "ack", "ack", small];
			me.R1 = [nil, nil, "ack", "ack"];
			me.R1B = [nil, nil, "ack"];
		}
		if (size(me.outputList) >= 2) {
			me.L2 = me.outputList[1].updateLeftText(me.page);
			me.C2 = me.outputList[1].updateCenterText(me.page);
			me.R2 = me.outputList[1].updateRightText(me.page);
			me.R2B = me.outputList[1].updateRightBText(me.page);
		} else {
			me.L2 = [nil, nil, "ack"];
			me.C2 = [nil, nil, "ack", "ack", small];
			me.R2 = [nil, nil, "ack", "ack"];
			me.R2B = [nil, nil, "ack"];
		}
		if (size(me.outputList) >= 3) {
			me.L3 = me.outputList[2].updateLeftText(me.page);
			me.C3 = me.outputList[2].updateCenterText(me.page);
			me.R3 = me.outputList[2].updateRightText(me.page);
			me.R3B = me.outputList[2].updateRightBText(me.page);
		} else {
			me.L3 = [nil, nil, "ack"];
			me.C3 = [nil, nil, "ack", "ack", small];
			me.R3 = [nil, nil, "ack", "ack"];
			me.R3B = [nil, nil, "ack"];
		}
		if (size(me.outputList) >= 4) {
			me.L4 = me.outputList[3].updateLeftText(me.page);
			me.C4 = me.outputList[3].updateCenterText(me.page);
			me.R4 = me.outputList[3].updateRightText(me.page);
			me.R4B = me.outputList[3].updateRightBText(me.page);
		} else {
			me.L4 = [nil, nil, "ack"];
			me.C4 = [nil, nil, "ack", "ack", small];
			me.R4 = [nil, nil, "ack", "ack"];
			me.R4B = [nil, nil, "ack"];
		}
		if (size(me.outputList) >= 5) {
			me.L5 = me.outputList[4].updateLeftText(me.page);
			me.C5 = me.outputList[4].updateCenterText(me.page);
			me.R5 = me.outputList[4].updateRightText(me.page);
			me.R5B = me.outputList[4].updateRightBText(me.page);
		} else {
			me.L5 = [nil, nil, "ack"];
			me.C5 = [nil, nil, "ack", "ack", small];
			me.R5 = [nil, nil, "ack", "ack"];
			me.R5B = [nil, nil, "ack"];
		}
	},
	destInfo: func() {
		if (me.plan.getWP(fmgc.flightPlanController.arrivalIndex[me.planIndex]) != nil and fmgc.flightPlanController.getPlanSizeNoDiscont(me.planIndex) > 1) {
			var destName = split("-", me.plan.getWP(fmgc.flightPlanController.arrivalIndex[me.planIndex]).wp_name);
			if (size(destName) == 2) {
				me.L6 = [destName[0] ~ destName[1], " DEST", "wht"];
			} else {
				me.L6 = [destName[0], " DEST", "wht"];
			}
			if (fmgc.FMGCInternal.blockSet and fmgc.FMGCInternal.tripFuel > 0) {
				_time = fmgc.FMGCInternal.tripTime;
				if (num(_time) >= 60) {
					_min = int(math.mod(_time, 60));
					_hour = int((_time - _min) / 60);
					me.C6 = [sprintf("%02d ", _hour) ~ sprintf("%02d  ", _min), "TIME   ", "wht", "wht", small];
				} else {
					me.C6 = [sprintf("%04d   ", _time), "TIME   ", "wht", "wht", small];
				}
				me.R6 = [sprintf("%4.0f", int(fmgc.flightPlanController.arrivalDist.getValue())) ~ sprintf("    %2.1f", fmgc.FMGCInternal.block - fmgc.FMGCInternal.taxiFuel - fmgc.FMGCInternal.tripFuel), "DIST   EFOB", "wht", "wht"];
			} else {
				me.C6 = ["----   ", "TIME   ", "wht", "wht", small];
				me.R6 = [sprintf("%4.0f", int(fmgc.flightPlanController.arrivalDist.getValue())) ~ "   --.-", "DIST   EFOB", "wht", "wht"];
			}
		} else {
			me.L6 = ["----", " DEST", "wht"];
			me.C6 = ["----   ", "TIME   ", "wht", "wht", small];
			me.R6 = ["----   --.-", "DIST   EFOB", "wht", "wht"];
		}
	},
	update: func() {
		#me.basePage();
	},
	scrollLeft: func() {
		if (me.page == "B") {
			me.page = "A";
		} else if (me.page == "A") {
			me.page = "B";
		}
	},
	scrollRight: func() {
		if (me.page == "B") {
			me.page = "A";
		} else if (me.page == "A") {
			me.page = "B";
		}
	},
	scrollUp: func() {
		if (size(me.planList) > 1) {
			me.scroll += 1;
			if (me.planList[me.scroll].type == "fpln_item") {
				me.scroll_index += 1;
			}
			if (me.scroll > size(me.planList) - 3) {
				me.scroll = 0;
				me.scroll_index = 0;
			}
			if (me.scroll_index < me.plan.getPlanSize()) {
				setprop("/instrumentation/efis[" ~ me.computer ~ "]/inputs/plan-wpt-index", me.scroll_index);
			}
		} else {
			me.scroll = 0;
			me.scroll_index = 0;
			setprop("/instrumentation/efis[" ~ me.computer ~ "]/inputs/plan-wpt-index", -1);
		}
	},
	scrollDn: func() {
		if (size(me.planList) > 1) {
			me.scroll -= 1;
			if (me.planList[me.scroll].type == "fpln_item") {
				me.scroll_index -= 1;
			}
			if (me.scroll < 0) {
				me.scroll = size(me.planList) - 3;
				me.scroll_index = size(me.planList) - 3;
			}
			if (me.scroll_index < me.plan.getPlanSize()) {
				setprop("/instrumentation/efis[" ~ me.computer ~ "]/inputs/plan-wpt-index", me.scroll_index);
			}
		} else {
			me.scroll = 0;
			me.scroll_index = 0;
			setprop("/instrumentation/efis[" ~ me.computer ~ "]/inputs/plan-wpt-index", -1);
		}
	},
	pushButtonLeft: func(index) {
		if (index == 6) {
			if (fmgc.flightPlanController.temporaryFlag[me.computer]) {
				fmgc.flightPlanController.destroyTemporaryFlightPlan(me.computer, 0);
				# push update to fuel
				if (fmgc.FMGCInternal.blockConfirmed) {
					fmgc.FMGCInternal.fuelCalculating = 0;
					fmgc.fuelCalculating.setValue(0);
					fmgc.FMGCInternal.fuelCalculating = 1;
					fmgc.fuelCalculating.setValue(1);
				}
			} else {
				if (canvas_mcdu.myLatRev[me.computer] != nil) {
					canvas_mcdu.myLatRev[me.computer].del();
				}
				canvas_mcdu.myLatRev[me.computer] = nil;
				canvas_mcdu.myLatRev[me.computer] = latRev.new(1, fmgc.flightPlanController.flightplans[2].getWP(fmgc.flightPlanController.arrivalIndex[2]), fmgc.flightPlanController.arrivalIndex[2], me.computer);
				setprop("MCDU[" ~ me.computer ~ "]/page", "LATREV");
			}
		} else {
			if (size(me.outputList) >= index) {
				if (size(mcdu_scratchpad.scratchpads[me.computer].scratchpad) > 0) {
					if (mcdu_scratchpad.scratchpads[me.computer].scratchpad == "CLR") {
						if (me.outputList[index + 1].wp.wp_name == "(DECEL)" or me.outputList[index + 1].wp.wp_name == "(T/C)" or me.outputList[index + 1].wp.wp_name == "(T/D)") {
							mcdu_message(me.computer, "NOT ALLOWED");
							return;
						}
					}

					var returny = fmgc.flightPlanController.scratchpad(mcdu_scratchpad.scratchpads[me.computer].scratchpad, (index - 1 + me.scroll), me.computer);
					if (returny == 3) {
						mcdu_message(me.computer, "DIR TO IN PROGRESS");
					} elsif (returny == 0) {
						mcdu_message(me.computer, "NOT IN DATA BASE");
					} elsif (returny == 1) {
						mcdu_message(me.computer, "NOT ALLOWED");
					} elsif (returny == 4) {
						mcdu_message(me.computer, "LIST OF 20 IN USE");
					} else {
						mcdu_scratchpad.scratchpads[me.computer].empty();
					}
				} else {
					me.outputList[index - 1].pushButtonLeft();
				}
			} else {
				mcdu_message(me.computer, "NOT ALLOWED");
			}
		}
	},
	pushButtonRight: func(index) {
		if (index == 6) {
			if (fmgc.flightPlanController.temporaryFlag[me.computer]) {
				if (dirToFlag) { dirToFlag = 0; }
				fmgc.flightPlanController.destroyTemporaryFlightPlan(me.computer, 1);
				# push update to fuel
				if (fmgc.FMGCInternal.blockConfirmed) {
					fmgc.FMGCInternal.fuelCalculating = 0;
					fmgc.fuelCalculating.setValue(0);
					fmgc.FMGCInternal.fuelCalculating = 1;
					fmgc.fuelCalculating.setValue(1);
				}
			} else {
				mcdu_message(me.computer, "NOT ALLOWED");
			}
		} else {
			if (size(me.outputList) >= index) {
				me.outputList[index - 1].pushButtonRight();
			} else {
				mcdu_message(me.computer, "NOT ALLOWED");
			}
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