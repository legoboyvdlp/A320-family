var fplnItem = {
	new: func(wp, index, plan, computer, colour = "grn") {
		var fI = {parents:[fplnItem]};
		fI.wp = wp;
		fI.index = index;
		fI.plan = plan;
		fI.computer = computer;
		fI.colour = colour;
		fI.assembledStr = [nil, nil, colour];
		fI._colour = "wht";
		return fI;
	},
	updateLeftText: func() {
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
	updateCenterText: func() {
		if (me.wp != nil) { 
			if (me.wp.wp_name != "DISCONTINUITY") {
				if (me.index == fmgc.flightPlanController.currentToWptIndex.getValue() - 1 and fmgc.flightPlanController.fromWptTime != nil) {
					me.assembledStr[0] = fmgc.flightPlanController.fromWptTime ~ "   ";
					me.assembledStr[2] = "grn";
				} else {
					me.assembledStr[0] = "----   ";
					me.assembledStr[2] = "wht";
				}
				
				if (me.index == fmgc.flightPlanController.currentToWptIndex.getValue()) {
					me.assembledStr[1] = "BRG" ~ me.getBrg() ~ "   ";
				} elsif (me.index == (fmgc.flightPlanController.currentToWptIndex.getValue() + 1) or me.index == (fmgc.flightPlanController.arrivalIndex[me.plan] + 1)) {
					me.assembledStr[1] = "TRK" ~ me.getTrack() ~ "   ";
				} else {
					me.assembledStr[1] = nil;
				}
				
				return me.assembledStr;
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
				if (me.colour != "yel") {	# not temporary flightplan
					me._colour = "wht";
					#if (me.spd[1] != "wht" or me.alt[1] != "wht") {
					if (me.spd[1] == me.alt[1]) {
						me._colour = me.spd[1];
					}
					else if (me.spd[1] == "mag" or me.alt[1] == "mag") {
						me._colour = "mag";
					}
					else if (me.spd[1] == "grn" or me.alt[1] == "grn") {
						me._colour = "grn";
					}
					
				} else {	# temporary flightplan
					me._colour = "yel";
				}
				return [me.spd[0] ~ "/" ~ me.alt[0], " " ~ me.dist ~ "NM    ", me._colour];
			} else {
				return [nil, nil, "ack"];
			}
		} else {
			return ["problem", nil, "ack"];
		}
	},
	getBrg: func() {
		me.brg = fmgc.wpCourse[me.plan][me.index].getValue() - magvar();
		if (me.brg < 0) { me.brg += 360; }
		if (me.brg > 360) { me.brg -= 360; }
		return sprintf("%03.0f", math.round(me.brg));
	},
	getTrack: func() {
		var wp = fmgc.flightPlanController.flightplans[me.plan].getWP(me.index);
		me.trk = fmgc.wpCoursePrev[me.plan][me.index].getValue() - magvar(wp.lat, wp.lon);
		if (me.trk < 0) { me.trk += 360; }
		if (me.trk > 360) { me.trk -= 360; }
		return sprintf("%03.0f", math.round(me.trk));
	},
	getSpd: func() {
		if (me.index == 0 and left(me.wp.wp_name, 4) == fmgc.FMGCInternal.depApt and fmgc.FMGCInternal.v1set) {
			return [sprintf("%3.0f", math.round(fmgc.FMGCInternal.v1)), "grn"]; # why "mag"? I think "grn"
		} elsif (me.wp.speed_cstr != nil and me.wp.speed_cstr > 0) {
			var tcol = (me.wp.speed_cstr_type == "computed" or me.wp.speed_cstr_type == "computed_mach") ? "grn" : "mag";  # TODO - check if only computed
			return [sprintf("%3.0f", me.wp.speed_cstr), tcol];
		} else {
			return ["---", "wht"];
		}
	},
	getAlt: func() {
		if (me.index == 0 and left(me.wp.wp_name, 4) == fmgc.FMGCInternal.depApt and fmgc.flightPlanController.flightplans[me.plan].departure != nil) {
			return [" " ~ sprintf("%5.0f", math.round(fmgc.flightPlanController.flightplans[me.plan].departure.elevation * M2FT)), "grn"]; #fixed - aligned to right
		} elsif (me.index == (fmgc.flightPlanController.currentToWptIndex.getValue() - 1) and fmgc.flightPlanController.fromWptAlt != nil) {
			return [" " ~ fmgc.flightPlanController.fromWptAlt, "mag"];
		} elsif (me.wp.alt_cstr != nil and me.wp.alt_cstr > 0) {
			var tcol = (me.wp.alt_cstr_type == "computed" or me.wp.alt_cstr_type == "computed_mach") ? "grn" : "mag";  # TODO - check if only computed
			if (me.wp.alt_cstr > fmgc.FMGCInternal.transAlt) {
				return [" " ~ sprintf("%5s", "FL" ~ math.round(num(me.wp.alt_cstr) / 100)), tcol]; #fixed - aligned to right
			} else {
				return [" " ~ sprintf("%5.0f", me.wp.alt_cstr), tcol]; #fixed - aligned to right
			}
		} else {
			return ["------", "wht"];
		}
	},
	getDist: func() {
		if (me.index == fmgc.flightPlanController.currentToWptIndex.getValue()) {
			return math.round(fmgc.wpDistance[me.plan][me.index].getValue());
		} else {
			return math.round(fmgc.wpDistancePrev[me.plan][me.index].getValue());
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
				me.wp.setSpeed("delete");
				me.wp.setAltitude("delete");
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
			colour = "yel";
		} else {
			colour = "grn";
		}
		for (var i = 0; i < me.plan.getPlanSize(); i += 1) {
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
			me.L1 = me.outputList[0].updateLeftText();
			me.C1 = me.outputList[0].updateCenterText();
			me.C1[1] = (fmgc.flightPlanController.fromWptTime != nil) ? "UTC   " : "TIME   ";  # since TO change to UTC time (1 space left to center)
			me.R1 = me.outputList[0].updateRightText();
			me.R1[1] = "SPD/ALT    ";
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
		if (me.plan.getWP(fmgc.flightPlanController.arrivalIndex[me.planIndex]) != nil) {
			var destName = split("-", me.plan.getWP(fmgc.flightPlanController.arrivalIndex[me.planIndex]).wp_name);
			if (size(destName) == 2) {
				me.L6 = [destName[0] ~ destName[1], " DEST", "wht"];
			} else {
				me.L6 = [destName[0], " DEST", "wht"];
			}
		} else {
			me.L6 = ["----", " DEST", "wht"];
		}
		me.C6 = ["----   ", "TIME   ", "wht"];
		if (fmgc.flightPlanController.arrivalDist != nil) {
			me.R6 = [sprintf("%4.0f", int(fmgc.flightPlanController.arrivalDist)) ~ "  --.-", "DIST    EFOB", "wht"];
		} else {
			me.R6 = ["----   --.-", "DIST    EFOB", "wht"];
		}
	},
	update: func() {
		#me.basePage();
	},
	scrollUp: func() {
		if (size(me.planList) > 1) {
			me.scroll += 1;
			if (me.scroll > size(me.planList) - 3) {
				me.scroll = 0;
			}
			if (me.scroll < me.plan.getPlanSize()) {
				setprop("/instrumentation/efis[" ~ me.computer ~ "]/inputs/plan-wpt-index", me.scroll);
			}
		} else {
			me.scroll = 0;
			setprop("/instrumentation/efis[" ~ me.computer ~ "]/inputs/plan-wpt-index", -1);
		}
	},
	scrollDn: func() {
		if (size(me.planList) > 1) {
			me.scroll -= 1;
			if (me.scroll < 0) {
				me.scroll = size(me.planList) - 3;
			}
			if (me.scroll < me.plan.getPlanSize()) {
				setprop("/instrumentation/efis[" ~ me.computer ~ "]/inputs/plan-wpt-index", me.scroll);
			}
		} else {
			me.scroll = 0;
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