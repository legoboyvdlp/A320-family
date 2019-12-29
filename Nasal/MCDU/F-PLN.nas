# Airbus A3XX FMGC MCDU Bridge

# Copyright (c) 2019 Joshua Davidson (Octal450) and Nikolai V. Chr. (Necolatis)

# Lowercase "g" is a degree symbol in the MCDU font.

var TMPY = 5;
var MAIN = 6;
var debug = 0; # Set to 1 to check inner functionality
var insertReturn = nil;
var active_out = [nil, nil, props.globals.getNode("/FMGC/flightplan[2]/active")];
var num_out = [props.globals.getNode("/FMGC/flightplan[0]/num"), props.globals.getNode("/FMGC/flightplan[1]/num"), props.globals.getNode("/FMGC/flightplan[2]/num")];
var TMPYActive = [props.globals.getNode("/FMGC/internal/tmpy-active[0]"), props.globals.getNode("/FMGC/internal/tmpy-active[1]")];

var clearFPLNComputer = func {
	FPLNLines[0].clear();
	FPLNLines[1].clear();
}

var StaticText = {
	new: func(computer, type) {
		var in = {parents:[StaticText]};
		in.type = type;
		in.computer = computer;
		return in;
	},
	getText: func() {
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
	getColor: func() {
		return canvas_mcdu.WHITE;
	},
	getSubText: func() {
		return "";
	},
	type: nil,
	pushButtonLeft: func() {
		notAllowed(me.computer.mcdu);
	},
	pushButtonRight: func() {
		notAllowed(me.computer.mcdu);
	},
};

var FPLNText = {
	new: func(computer, wp, dest, fp, wpIndex) {
		var in = {parents:[FPLNText]};
		in.wp = wp;
		in.dest = dest;
		in.fp = fp;
		in.index = wpIndex;
		in.computer = computer;
		return in;
	},
	getText: func() {
		return me.wp.wp_name;
	},
	getColor: func(i) {
		if (TMPYActive[i].getBoolValue()) {
			if (me.dest) {
				return canvas_mcdu.WHITE;
			} else {
				return canvas_mcdu.YELLOW;
			}
		} else {
			if (me.dest) {
				return canvas_mcdu.WHITE;
			} else {
				return canvas_mcdu.GREEN;
			}
		}
	},
	getSubText: func(i) {
		if (me.index == 0) {
				return "";
		} else if (TMPYActive[i].getBoolValue()) {
			if (fmgc.arrivalAirportI[i] == me.index) {
				return "DEST";
			} else {
				return "C" ~ sprintf("%03d", fmgc.wpCoursePrev[me.fp][me.index].getValue()) ~ "g";
			}
		} else {
			if (fmgc.arrivalAirportI[2] == me.index) {
				return "DEST";
			} else {
				return "C" ~ sprintf("%03d", fmgc.wpCoursePrev[me.fp][me.index].getValue()) ~ "g";
			}
		}
	},
	wp: nil,
	pushButtonLeft: func() {
		var scratchpad = getprop("/MCDU[" ~ me.computer.mcdu ~ "]/scratchpad");
		if (me.computer.lines == MAIN and scratchpad != "") {
			fmgc.flightplan.initTempFP(me.computer.mcdu, 2);
		}
		if (scratchpad == "CLR") {
			if (fmgc.flightplan.deleteWP(me.index, me.computer.mcdu, 0) != 0) {
				notAllowed(me.computer.mcdu);
			} else {
				setprop("/MCDU[" ~ me.computer.mcdu ~ "]/scratchpad-msg", 0);
				setprop("/MCDU[" ~ me.computer.mcdu ~ "]/scratchpad", "");
			}
		} else {
			if (size(scratchpad) == 5) {
				var insertReturn = fmgc.flightplan.insertFix(scratchpad, me.index, me.computer.mcdu);
				if (insertReturn == 2) {
					notAllowed(me.computer.mcdu);
				} else if (insertReturn == 1) {
					notInDataBase(me.computer.mcdu);
				} else {
					setprop("/MCDU[" ~ me.computer.mcdu ~ "]/scratchpad", "");
				}
			} else if (size(scratchpad) == 4) {
				var insertReturn = fmgc.flightplan.insertArpt(scratchpad, me.index, me.computer.mcdu);
				if (insertReturn == 2) {
					notAllowed(me.computer.mcdu);
				} else if (insertReturn == 1) {
					notInDataBase(me.computer.mcdu);
				} else {
					setprop("/MCDU[" ~ me.computer.mcdu ~ "]/scratchpad", "");
				}
			} else if (size(scratchpad) == 3 or size(scratchpad) == 2) {
				var insertReturn = fmgc.flightplan.insertNavaid(scratchpad, me.index, me.computer.mcdu);
				if (insertReturn == 2) {
					notAllowed(me.computer.mcdu);
				} else if (insertReturn == 1) {
					notInDataBase(me.computer.mcdu);
				} else {
					setprop("/MCDU[" ~ me.computer.mcdu ~ "]/scratchpad", "");
				}
			} else if (size(scratchpad) == 1) {
				formatError(me.computer.mcdu);
			} else {
				if (me.getText() == fmgc.fp[2].departure.id) {
					if (canvas_mcdu.myLatRev != nil) {
						canvas_mcdu.myLatRev.del();
					}
					canvas_mcdu.myLatRev = nil;
					canvas_mcdu.myLatRev = latRev.new(0, me.getText());
				} elsif (me.index == fmgc.arrivalAirportI[2]) {
					if (canvas_mcdu.myLatRev != nil) {
						canvas_mcdu.myLatRev.del();
					}
					canvas_mcdu.myLatRev = nil;
					canvas_mcdu.myLatRev = latRev.new(1, me.getText());
				} elsif (me.index == fmgc.currentWP[2]) {
					if (canvas_mcdu.myLatRev != nil) {
						canvas_mcdu.myLatRev.del();
					}
					canvas_mcdu.myLatRev = nil;
					canvas_mcdu.myLatRev = latRev.new(2, me.getText());
				} else {
					if (canvas_mcdu.myLatRev != nil) {
						canvas_mcdu.myLatRev.del();
					}
					canvas_mcdu.myLatRev = nil;
					canvas_mcdu.myLatRev = latRev.new(3, me.getText());
				}
				setprop("/MCDU[" ~ me.computer.mcdu ~ "]/page", "LATREV");
			}
		}
	},
	pushButtonRight: func() {
		notAllowed(me.computer.mcdu);
	},
};

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
		
		if (!fmgc.active_out[2].getBoolValue()) {
			me.destIndex = -1;
			me.destination = nil;
		} else {
			fpln = fmgc.fp[fplnID]; # Get the Nasal Flightplan
			me.destIndex = fmgc.arrivalAirportI[fplnID];
			me.destination = FPLNText.new(me, fpln.getWP(me.destIndex), 1, fplnID, me.destIndex);
			for (var j = 0; j < fpln.getPlanSize(); j += 1) {
				me.dest = 0;
				if (j == me.destIndex) {
					me.dest = 1;
				}
				append(me.planList, FPLNText.new(me, fpln.getWP(j), me.dest, fplnID, j));
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
	checkIndex: func() {
		if (!me.enableScroll) {
			me.index = 0;
			if (debug == 1) printf("%d: index forced to 0",me.mcdu);
		} elsif (me.index > size(me.planList) + 2 - me.lines) {
			me.index = size(me.planList) + 2 - me.lines;
			if (debug == 1) printf("%d: index forced to %d",me.mcdu,me.index);
		}
	},
	scrollDown: func() { # Scroll Up in Thales Manual
		if (debug == 1) printf("%d: scroll down", me.mcdu);
		me.extra = 1;
		if (!me.enableScroll) {
			me.index = 0;
		} else {
			me.index += 1;
			if (me.index > size(me.planList) + 2 - me.lines) {
				me.index = 0;
			}
		}
		me.updateScroll();
	},
	scrollUp: func() { # Scroll Down in Thales Manual
		if (debug == 1) printf("%d: scroll up", me.mcdu);
		me.extra = 1;
		if (!me.enableScroll) {
			me.index = 0;
		} else {
			me.index -= 1;
			if (me.index < 0) {
				me.index = size(me.planList) + 2 - me.lines;
			}
		}
		me.updateScroll();
	},
	updateScroll: func() {
		me.output = [];
		if (me.index <= size(me.planList) + 1) {
			var i = 0;
			me.realIndex = me.index - 1;
			if (debug == 1) printf("%d: updating display from index %d", me.mcdu, me.realIndex);
			for (i = me.index; i < math.min(size(me.planList), me.index + 5); i += 1) {
				append(me.output, me.planList[i]);
				me.realIndex = i;
			}
			if (debug == 1) printf("%d: populated until wp index %d", me.mcdu,me.realIndex);
			if (me.realIndex < me.destIndex and me.lines == MAIN) {
				# Destination has not been shown yet, now its time (if we show 6 lines)
				append(me.output, me.destination);
				if (debug == 1) printf("%d: added dest at bottom for total of %d lines", me.mcdu, size(me.output));
				return;
			} else if (size(me.output) < me.lines) {
				for (i = me.realIndex + 1; size(me.output) < me.lines and i < size(me.planList); i += 1) {
					append(me.output, me.planList[i]);
					me.realIndex = i;
				}
				if (debug == 1) printf("%d: populated after until wp index %d", me.mcdu,me.realIndex);
				if (size(me.output) < me.lines) {
					if (me.realIndex == size(me.planList)-1) {
						# Show the end of plan
						append(me.output, me.planEnd);
						me.realIndex += 1;
						if (debug == 1) printf("%d: added end, wp index=%d", me.mcdu, me.realIndex);
					}
					if (size(me.output) < me.lines and (me.realIndex == size(me.planList))) {
						append(me.output, me.planNoAlt);
						me.realIndex += 1;
						if (debug == 1) printf("%d: added no-alt, wp index=%d", me.mcdu,me.realIndex);
						if (me.enableScroll and size(me.output) < me.lines) {
							# We start wrapping
							for (var j = 0; size(me.output) < me.lines; j += 1) {
								append(me.output, me.planList[j]);
							}							
						}
					}
				}
			}
		}
		while (size(me.output) < me.lines) {
			append(me.output, StaticText.new(me, "empty"));
		}
		if (debug == 1) printf("%d: %d lines", me.mcdu, size(me.output));
	},
};

var FPLNLines = [FPLNLineComputer.new(0), FPLNLineComputer.new(1)];
clearFPLNComputer(); # Just in case, we have it in the clear state.

var slewFPLN = func(d, i) { # Scrolling function. d is -1 or 1 for direction, and i is instance.
	if (d == 1) {
		FPLNLines[i].scrollDown(); # Scroll Up in Thales Manual
	} else if (d == -1) {
		FPLNLines[i].scrollUp(); # Scroll Down in Thales Manual
	}
}

# Button and Inputs
var FPLNButton = func(s, key, i) {
	var scratchpad = getprop("/MCDU[" ~ i ~ "]/scratchpad");
	if (s == "L") {
		if (key == 6 and TMPYActive[i].getBoolValue()) {
			fmgc.flightplan.eraseTempFP(i, 2);
		} else {
			if (size(FPLNLines[i].output) >= key) {
				FPLNLines[i].output[key - 1].pushButtonLeft();
			}
		}
	} else if (s == "R") {
		if (key == 6 and TMPYActive[i].getBoolValue()) {
			fmgc.flightplan.executeTempFP(i, 2);
		} else {
#			if (scratchpad != "") {
#				if (size(FPLNLines[i].output) >= key) {
#					FPLNLines[i].output[key - 1].pushButtonRight();
#				}
#			} else {
				notAllowed(i); # Remove when has functionality
				# FIXME: Add VERT REV Logic
#			}
		}
	}
}

var notInDataBase = func(i) {
		if (getprop("/MCDU[" ~ i ~ "]/scratchpad-msg") == 1) { # Messages clear after NOT IN DATABASE
			setprop("/MCDU[" ~ i ~ "]/last-scratchpad", "NOT IN DATABASE");
		} else {
			setprop("/MCDU[" ~ i ~ "]/last-scratchpad", getprop("/MCDU[" ~ i ~ "]/scratchpad"));
		}
	setprop("/MCDU[" ~ i ~ "]/scratchpad-msg", 1);
	setprop("/MCDU[" ~ i ~ "]/scratchpad", "NOT IN DATABASE");
}

# For testing purposes only -- do not touch!
var test = func {
	var fp = createFlightplan(getprop("sim/aircraft-dir")~"/plan.gpx");
	var desti = int(fp.getPlanSize()*0.5);
	FPLNLines[0].replacePlan(fp,6,desti,0);
	print("Display:");
	foreach(line;FPLNLines[0].output) {
		printf("line: %s",line.getText());
	}
	print("down");FPLNLines[0].scrollDown();
	foreach(line;FPLNLines[0].output) {
		printf("line: %s",line.getText());
	}
	print("down");FPLNLines[0].scrollDown();
	foreach(line;FPLNLines[0].output) {
		printf("line: %s",line.getText());
	}
	print("down");FPLNLines[0].scrollDown();
	foreach(line;FPLNLines[0].output) {
		printf("line: %s",line.getText());
	}
	print("down");FPLNLines[0].scrollDown();
	foreach(line;FPLNLines[0].output) {
		printf("line: %s",line.getText());
	}
	print("down");FPLNLines[0].scrollDown();
	foreach(line;FPLNLines[0].output) {
		printf("line: %s",line.getText());
	}
	print("down");FPLNLines[0].scrollDown();
	foreach(line;FPLNLines[0].output) {
		printf("line: %s",line.getText());
	}
	print("down");FPLNLines[0].scrollDown();
	foreach(line;FPLNLines[0].output) {
		printf("line: %s",line.getText());
	}
	print("down");FPLNLines[0].scrollDown();
	foreach(line;FPLNLines[0].output) {
		printf("line: %s",line.getText());
	}
	print("down");FPLNLines[0].scrollDown();
	foreach(line;FPLNLines[0].output) {
		printf("line: %s",line.getText());
	}
	print("down");FPLNLines[0].scrollDown();
	foreach(line;FPLNLines[0].output) {
		printf("line: %s",line.getText());
	}
	print("down");FPLNLines[0].scrollDown();
	foreach(line;FPLNLines[0].output) {
		printf("line: %s",line.getText());
	}
	print("down");FPLNLines[0].scrollDown();
	foreach(line;FPLNLines[0].output) {
		printf("line: %s",line.getText());
	}
	print("down");FPLNLines[0].scrollDown();
	foreach(line;FPLNLines[0].output) {
		printf("line: %s",line.getText());
	}
	print("down");FPLNLines[0].scrollDown();
	foreach(line;FPLNLines[0].output) {
		printf("line: %s",line.getText());
	}
	print("down");FPLNLines[0].scrollDown();
	foreach(line;FPLNLines[0].output) {
		printf("line: %s",line.getText());
	}
	print("down");FPLNLines[0].scrollDown();
	foreach(line;FPLNLines[0].output) {
		printf("line: %s",line.getText());
	}
	print("down");FPLNLines[0].scrollDown();
	foreach(line;FPLNLines[0].output) {
		printf("line: %s",line.getText());
	}
	print("down");FPLNLines[0].scrollDown();
	foreach(line;FPLNLines[0].output) {
		printf("line: %s",line.getText());
	}
	print("down");FPLNLines[0].scrollDown();
	foreach(line;FPLNLines[0].output) {
		printf("line: %s",line.getText());
	}
	print("down");FPLNLines[0].scrollDown();
	foreach(line;FPLNLines[0].output) {
		printf("line: %s",line.getText());
	}
	print("down");FPLNLines[0].scrollDown();
	foreach(line;FPLNLines[0].output) {
		printf("line: %s",line.getText());
	}
	print("down");FPLNLines[0].scrollDown();
	foreach(line;FPLNLines[0].output) {
		printf("line: %s",line.getText());
	}
	print("down");FPLNLines[0].scrollDown();
	foreach(line;FPLNLines[0].output) {
		printf("line: %s",line.getText());
	}
	print("down");FPLNLines[0].scrollDown();
	foreach(line;FPLNLines[0].output) {
		printf("line: %s",line.getText());
	}
	print("down");FPLNLines[0].scrollDown();
	foreach(line;FPLNLines[0].output) {
		printf("line: %s",line.getText());
	}
	print("up");FPLNLines[0].scrollUp();
	foreach(line;FPLNLines[0].output) {
		printf("line: %s",line.getText());
	}
	print("up");FPLNLines[0].scrollUp();
	foreach(line;FPLNLines[0].output) {
		printf("line: %s",line.getText());
	}
	print("up");FPLNLines[0].scrollUp();
	foreach(line;FPLNLines[0].output) {
		printf("line: %s",line.getText());
	}
	print("up");FPLNLines[0].scrollUp();
	foreach(line;FPLNLines[0].output) {
		printf("line: %s",line.getText());
	}
	print("up");FPLNLines[0].scrollUp();
	foreach(line;FPLNLines[0].output) {
		printf("line: %s",line.getText());
	}
	print("up");FPLNLines[0].scrollUp();
	foreach(line;FPLNLines[0].output) {
		printf("line: %s",line.getText());
	}
	print("up");FPLNLines[0].scrollUp();
	foreach(line;FPLNLines[0].output) {
		printf("line: %s",line.getText());
	}
	print("up");FPLNLines[0].scrollUp();
	foreach(line;FPLNLines[0].output) {
		printf("line: %s",line.getText());
	}
	print("up");FPLNLines[0].scrollUp();
	foreach(line;FPLNLines[0].output) {
		printf("line: %s",line.getText());
	}
	print("up");FPLNLines[0].scrollUp();
	foreach(line;FPLNLines[0].output) {
		printf("line: %s",line.getText());
	}
	print("up");FPLNLines[0].scrollUp();
	foreach(line;FPLNLines[0].output) {
		printf("line: %s",line.getText());
	}
	print("up");FPLNLines[0].scrollUp();
	foreach(line;FPLNLines[0].output) {
		printf("line: %s",line.getText());
	}
}

#test();
