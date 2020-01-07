
	pushButtonLeft: func() {
		if (me.type != "discontinuity") {
			notAllowed(me.computer.mcdu);
		} else {
			var scratchpad = getprop("/MCDU[" ~ me.computer.mcdu ~ "]/scratchpad");
			if (me.computer.lines == MAIN and scratchpad != "CLR" and scratchpad != "") {
				fmgc.flightPlanController.createTemporaryFlightPlan(me.computer.mcdu);
			}
			if (fmgc.flightPlanController.temporaryFlag[me.computer.mcdu]) {
				if (scratchpad == "CLR") {
					if (fmgc.flightPlanController.deleteWP(me.index, me.computer.mcdu, 0) != 0) {
						notAllowed(me.computer.mcdu);
					} else {
						setprop("/MCDU[" ~ me.computer.mcdu ~ "]/scratchpad-msg", 0);
						setprop("/MCDU[" ~ me.computer.mcdu ~ "]/scratchpad", "");
					}
				} elsif (size(scratchpad) == 5) {
					var fix = findFixesByID(scratchpad);
					if (size(fix) >= 1) {
						var indexWp = fmgc.flightPlanController.flightplans[me.computer.mcdu].indexOfWP(fix[0]);
						if (indexWp == -1) {
							var insertReturn = fmgc.flightPlanController.insertFix(scratchpad, me.index, me.computer.mcdu);
							fmgc.flightPlanController.flightPlanChanged(me.computer.mcdu);
						} else {
							var numTimesDelete = indexWp - me.index;
							while (numTimesDelete > 0) {
								fmgc.flightPlanController.deleteWP(me.index + 1, me.computer.mcdu, 0);
								numTimesDelete -= 1;
							}
						}
						if (insertReturn == 2) {
							notAllowed(me.computer.mcdu);
						} else if (insertReturn == 1) {
							notInDataBase(me.computer.mcdu);
						} else {
							setprop("/MCDU[" ~ me.computer.mcdu ~ "]/scratchpad", "");
						}
					} else {
						notInDataBase(me.computer.mcdu);
					}
				} else if (size(scratchpad) == 4) {
					var arpt = findAirportsByICAO(scratchpad);
					if (size(arpt) >= 1) {
						var indexWp = fmgc.flightPlanController.flightplans[me.computer.mcdu].indexOfWP(arpt[0]);
						if (indexWp == -1) {
							var insertReturn = fmgc.flightPlanController.insertArpt(scratchpad, me.index, me.computer.mcdu);
							fmgc.flightPlanController.flightPlanChanged(me.computer.mcdu);
						} else {
							var numTimesDelete = indexWp - me.index;
							while (numTimesDelete > 0) {
								fmgc.flightPlanController.deleteWP(me.index + 1, me.computer.mcdu, 0);
								numTimesDelete -= 1;
							}
						}
						if (insertReturn == 2) {
							notAllowed(me.computer.mcdu);
						} else if (insertReturn == 1) {
							notInDataBase(me.computer.mcdu);
						} else {
							setprop("/MCDU[" ~ me.computer.mcdu ~ "]/scratchpad", "");
						}
					} else {
						notInDataBase(me.computer.mcdu);
					}
				} else if (size(scratchpad) == 3 or size(scratchpad) == 2) {
					var navaid = findNavaidsByID(scratchpad);
					if (size(navaid) >= 1) {
						var indexWp = fmgc.flightPlanController.flightplans[me.computer.mcdu].indexOfWP(navaid[0]);
						if (indexWp == -1) {
							var insertReturn = fmgc.flightPlanController.insertNavaid(scratchpad, me.index, me.computer.mcdu);
							fmgc.flightPlanController.flightPlanChanged(me.computer.mcdu);
						} else {
							var numTimesDelete = indexWp - me.index;
							while (numTimesDelete > 0) {
								fmgc.flightPlanController.deleteWP(me.index + 1, me.computer.mcdu, 0);
								numTimesDelete -= 1;
							}
						}
						if (insertReturn == 2) {
							notAllowed(me.computer.mcdu);
						} else if (insertReturn == 1) {
							notInDataBase(me.computer.mcdu);
						} else {
							setprop("/MCDU[" ~ me.computer.mcdu ~ "]/scratchpad", "");
						}
					} else {
						notInDataBase(me.computer.mcdu);
					}
				} elsif (scratchpad == "") {
					if (canvas_mcdu.myLatRev[me.computer.mcdu] != nil) {
						canvas_mcdu.myLatRev[me.computer.mcdu].del();
					}
					canvas_mcdu.myLatRev[me.computer.mcdu] = nil;
					canvas_mcdu.myLatRev[me.computer.mcdu] = latRev.new(4, "DISCON", me.index, me.computer.mcdu);
					setprop("/MCDU[" ~ me.computer.mcdu ~ "]/page", "LATREV");
				} else {
					notAllowed(me.computer.mcdu);
				}
			} else {
				if (scratchpad == "CLR") {
					if (fmgc.flightPlanController.deleteWP(me.index, 2, 0) != 0) {
						notAllowed(me.computer.mcdu);
					} else {
						setprop("/MCDU[" ~ me.computer.mcdu ~ "]/scratchpad-msg", 0);
						setprop("/MCDU[" ~ me.computer.mcdu ~ "]/scratchpad", "");
					}
				} elsif (size(scratchpad) != 0) {
					me.pushButtonLeft();
				} elsif (scratchpad == "") {
					if (canvas_mcdu.myLatRev[me.computer.mcdu] != nil) {
						canvas_mcdu.myLatRev[me.computer.mcdu].del();
					}
					canvas_mcdu.myLatRev[me.computer.mcdu] = nil;
					canvas_mcdu.myLatRev[me.computer.mcdu] = latRev.new(4, "DISCON", me.index, me.computer.mcdu);
					setprop("/MCDU[" ~ me.computer.mcdu ~ "]/page", "LATREV");
				} else {
					notAllowed(me.computer.mcdu);
				}
			}
		}
	},

var FPLNLineComputer = {
	new: func(mcdu) {
		var in = {parents:[FPLNLineComputer]};
		in.mcdu = mcdu;
		in.planEnd = StaticText.new(in, "fplnEnd");
		in.planNoAlt = StaticText.new(in, "noAltnFpln");
		if (debug == 1) printf("%d: Line computer created.", in.mcdu);
		return in;
	},
	index: 0,
	planList: [],
	destination: nil,
	destIndex: nil,
	planEnd: nil,
	planNoAlt: nil,
	lines: nil,
	output: [],
	mcdu: nil,
	fplnID: nil,
	enableScroll: 0,
	clear: func() {
		me.planList = [];
		me.destIndex = -1;
		me.destination = nil;
		me.index = 0;
		me.output = [];
		me.enableScroll = 0;
		if (me.lines == nil) {
			me.lines = MAIN;
		}
		me.updateScroll();
	},
	replacePlan: func(fplnID, lines, firstLineIndex) {
		# Here you set another plan, do this when changing plan on display or when destination changes
		if (debug == 1) printf("%d: replacePlan called for %d lines and firstLine %d", me.mcdu, lines, firstLineIndex);
		var fpln = nil;
		
		me.planList = [];
		
		if (!fmgc.flightPlanController.active.getBoolValue()) {
			me.destIndex = -1;
			me.destination = nil;
		} else {
			fpln = fmgc.flightPlanController.flightplans[fplnID]; # Get the Nasal Flightplan
			me.destIndex = fmgc.flightPlanController.arrivalIndex[fplnID];
			me.destination = FPLNText.new(me, fpln.getWP(me.destIndex), 1, fplnID, me.destIndex);
			for (var j = 0; j < fpln.getPlanSize(); j += 1) {
				me.dest = 0;
				if (j == me.destIndex) {
					me.dest = 1;
				}
				var wpt = fpln.getWP(j);
				if (wpt.wp_name == "DISCONTINUITY") {
					append(me.planList, StaticText.new(me, "discontinuity", j));
				} else {
					append(me.planList, FPLNText.new(me, fpln.getWP(j), me.dest, fplnID, j));
				}
			}
			if (debug == 1) printf("%d: dest is: %s", me.mcdu, fpln.getWP(me.destIndex).wp_name);
		}
		me.index = firstLineIndex;
		me.lines = lines;
		me.initScroll();
	},
	initScroll: func() {
		me.maxItems = size(me.planList) + 2; # + 2 is for end of plan line and altn end of plan.
		me.enableScroll = me.lines < me.maxItems;
		me.checkIndex();
		if (debug == 1) printf("%d: scroll is %d. Size of plan is %d", me.mcdu, me.enableScroll, size(me.planList));
		me.updateScroll();
	},
};

