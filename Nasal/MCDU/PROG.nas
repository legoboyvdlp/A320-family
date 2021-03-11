# Copyright (c) 2020 Matthew Maring (mattmaring)

var altSet = props.globals.getNode("it-autoflight/input/alt", 1);
var brgDistResult = nil;

var progGENInput = func(key, i) {
	var scratchpad = mcdu_scratchpad.scratchpads[i].scratchpad;
	if (key == "R4") {
		if (scratchpad == "CLR") {
			bearingDistances[i].selectedPoint = nil;
			bearingDistances[i].displayID = nil;
			mcdu_scratchpad.scratchpads[i].empty();
		} else {
			brgDistResult = bearingDistances[i].newPoint(mcdu_scratchpad.scratchpads[i].scratchpad);
			if (brgDistResult != 1) {
				mcdu_message(i, "NOT IN DATA BASE");
			} else {
				mcdu_scratchpad.scratchpads[i].empty();
			}
		}
	}
}

var progTOInput = func(key, i) {
	var scratchpad = mcdu_scratchpad.scratchpads[i].scratchpad;
	if (key == "L1") {
		if (scratchpad == "CLR") {
			fmgc.FMGCInternal.crzProg = fmgc.FMGCInternal.crzFl;
			mcdu_scratchpad.scratchpads[i].empty();
		} else if (int(scratchpad) != nil) {
			var crzs = size(scratchpad);
			if (crzs >= 1 and crzs <= 3 and scratchpad > 0 and scratchpad <= 430 and fmgc.FMGCInternal.crzSet <= scratchpad * 100 and fmgc.FMGCInternal.crzSet) {
				fmgc.FMGCInternal.crzProg = scratchpad;
				mcdu_scratchpad.scratchpads[i].empty();
			} else {
				mcdu_message(i, "NOT ALLOWED");
			}
		} else {
			mcdu_message(i, "NOT ALLOWED");
		}
	}
}

var progCLBInput = func(key, i) {
	var scratchpad = mcdu_scratchpad.scratchpads[i].scratchpad;
	if (key == "L1") {
		if (scratchpad == "CLR") {
			fmgc.FMGCInternal.crzProg = fmgc.FMGCInternal.crzFl;
			if (fmgc.FMGCInternal.phase == 5) {
				fmgc.FMGCInternal.phase = 3;
				setprop("/FMGC/internal/activate-once", 0);
				setprop("/FMGC/internal/activate-twice", 0);
				setprop("/FMGC/internal/decel", 0);
			}
			mcdu_scratchpad.scratchpads[i].empty();
		} else if (int(scratchpad) != nil) {
			var crzs = size(scratchpad);
			if (crzs >= 1 and crzs <= 3 and scratchpad > 0 and scratchpad <= 430 and fmgc.FMGCInternal.crzSet <= scratchpad * 100) {
				fmgc.FMGCInternal.crzProg = scratchpad;
				mcdu_scratchpad.scratchpads[i].empty();
				if (fmgc.FMGCInternal.phase == 5) {
					fmgc.FMGCInternal.phase = 3;
					setprop("/FMGC/internal/activate-once", 0);
					setprop("/FMGC/internal/activate-twice", 0);
					setprop("/FMGC/internal/decel", 0);
				}
			} else {
				mcdu_message(i, "NOT ALLOWED");
			}
		} else {
			mcdu_message(i, "NOT ALLOWED");
		}
	}
}

var progCRZInput = func(key, i) {
	var scratchpad = mcdu_scratchpad.scratchpads[i].scratchpad;
	if (key == "L1") {
		if (scratchpad == "CLR") {
			fmgc.FMGCInternal.crzProg = fmgc.FMGCInternal.crzFl;
			if (fmgc.FMGCInternal.phase == 5) {
				fmgc.FMGCInternal.phase = 3;
				setprop("/FMGC/internal/activate-once", 0);
				setprop("/FMGC/internal/activate-twice", 0);
				setprop("/FMGC/internal/decel", 0);
			}
			mcdu_scratchpad.scratchpads[i].empty();
		} else if (int(scratchpad) != nil) {
			var crzs = size(scratchpad);
			if (crzs >= 1 and crzs <= 3 and scratchpad > 0 and scratchpad <= 430 and fmgc.FMGCInternal.crzSet <= scratchpad * 100) {
				fmgc.FMGCInternal.crzProg = scratchpad;
				mcdu_scratchpad.scratchpads[i].empty();
				if (fmgc.FMGCInternal.phase == 5) {
					fmgc.FMGCInternal.phase = 3;
					setprop("/FMGC/internal/activate-once", 0);
					setprop("/FMGC/internal/activate-twice", 0);
					setprop("/FMGC/internal/decel", 0);
				}
			} else {
				mcdu_message(i, "NOT ALLOWED");
			}
		} else {
			mcdu_message(i, "NOT ALLOWED");
		}
	}
}

var progDESInput = func(key, i) {
	var scratchpad = mcdu_scratchpad.scratchpads[i].scratchpad;
	if (key == "L1") {
		if (scratchpad == "CLR") {
			fmgc.FMGCInternal.crzProg = fmgc.FMGCInternal.crzFl;
			if (fmgc.FMGCInternal.phase == 5 or fmgc.FMGCInternal.phase == 6) {
				fmgc.FMGCInternal.phase = 3;
				setprop("/FMGC/internal/activate-once", 0);
				setprop("/FMGC/internal/activate-twice", 0);
				setprop("/FMGC/internal/decel", 0);
			}
			mcdu_scratchpad.scratchpads[i].empty();
		} else if (int(scratchpad) != nil) {
			var crzs = size(scratchpad);
			if (crzs >= 1 and crzs <= 3 and scratchpad > 0 and scratchpad <= 430 and fmgc.FMGCInternal.crzSet <= scratchpad * 100) {
				fmgc.FMGCInternal.crzProg = scratchpad;
				mcdu_scratchpad.scratchpads[i].empty();
				if (fmgc.FMGCInternal.phase == 4 or fmgc.FMGCInternal.phase == 5 or fmgc.FMGCInternal.phase == 6) {
					fmgc.FMGCInternal.phase = 3;
					setprop("/FMGC/internal/activate-once", 0);
					setprop("/FMGC/internal/activate-twice", 0);
					setprop("/FMGC/internal/decel", 0);
				}
			} else {
				mcdu_message(i, "NOT ALLOWED");
			}
		} else {
			mcdu_message(i, "NOT ALLOWED");
		}
	}
}

var _result = [nil, nil];
var _courseAndDistance = [nil, nil];
var bearingDistanceInstance = {
	new: func(id) {
		var bd = {parents: [bearingDistanceInstance]};
		bd.id = id;
		bd.bearing = 360;
		bd.distance = 0;
		bd.selectedPoint = nil;
		bd.displayID = nil;
		return bd;
	},
	newPointResult: func(result, duplicateNames = 0, duplicateNamesIndex = nil) {
		if (duplicateNames != 0) {
			me.selectedPoint = result[duplicateNamesIndex];
			me.displayID = result[duplicateNamesIndex].id;
		} elsif (size(result) > 1) {
			if (canvas_mcdu.myDuplicate[me.id] != nil) {
				canvas_mcdu.myDuplicate[me.id].del();
			}
			canvas_mcdu.myDuplicate[me.id] = nil;
			canvas_mcdu.myDuplicate[me.id] = mcdu.duplicateNamesPage.new(result, 0, 0, me.id, 0, -999, -999, 1);
			setprop("MCDU[" ~ me.id ~ "]/page", "DUPLICATENAMES");
		} else {
			me.selectedPoint = result[0];
			me.displayID = result[0].id;
		}
		return 1;
	},
	newPointNavaid: func(result, duplicateNames = 0, duplicateNamesIndex = nil) {
		if (duplicateNames != 0) {
			me.selectedPoint = result[duplicateNamesIndex];
			me.displayID = result[duplicateNamesIndex].id;
		} elsif (size(result) > 1) {
			if (canvas_mcdu.myDuplicate[me.id] != nil) {
				canvas_mcdu.myDuplicate[me.id].del();
			}
			canvas_mcdu.myDuplicate[me.id] = nil;
			canvas_mcdu.myDuplicate[me.id] = mcdu.duplicateNamesPage.new(result, 0, 1, me.id, 0, -999, -999, 1);
			setprop("MCDU[" ~ me.id ~ "]/page", "DUPLICATENAMES");
		} else {
			me.selectedPoint = result[0];
			me.displayID = result[0].id;
			print("YES");
		}
		return 1;
	},
	newPointRWY: func(result,ID) {
		if (size(result) > 1) {
			#spawnPAGE
		} else {
			var string = split(left(ID,4),ID)[1];
			if (find("C",string) != -1 or find("L",string) != -1 or find("R",string) != -1) {
				if (size(string) == 2) {
					string = "0" ~ string;
				}
			} else {
				if (size(string) == 1) {
					string = "0" ~ string;
				}
			}
			
			if (contains(result[0].runways,string)) {
				me.selectedPoint = {lat: result[0].runways[string].lat, lon: result[0].runways[string].lon};
				me.displayID = left(ID,4) ~ string;
				return 1;
			} else {
				return 0;
			}
		}
		return 1;
	},
	newPointLatLon: func(result) {
		return 0;
	},
	newPoint: func(id) {
		_result[me.id] = fmgc.WaypointDatabase.getWP(id);
		if (_result[me.id] != nil) {
			me.selectedPoint = _result[me.id];
			me.displayID = _result[me.id].id;
			return 1;
		}
		
		if (size(id) >= 2 and size(id) <= 3) {
			_result[me.id] = findNavaidsByID(id);
			if (size(_result[me.id]) != 0) {
				return me.newPointNavaid(_result[me.id]);
			} else {
				_result[me.id] = findAirportsByICAO(id); # consider 3 letter ICAOs
				if (size(_result[me.id]) != 0) {
					return me.newPointResult(_result[me.id]);
				}
			}
			return 0;
		} elsif (size(id) == 4) {
			_result[me.id] = findAirportsByICAO(id);
			if (size(_result[me.id]) != 0) {
				return me.newPointResult(_result[me.id]);
			} else {
				_result[me.id] = findFixesByID(id);
				if (size(_result[me.id]) != 0) {
					return me.newPointResult(_result[me.id]);
				}
			}
			return 0;
		} elsif (size(id) >= 5 and size(id) <= 7) {
			_result[me.id] = findFixesByID(id);
			if (size(_result[me.id]) != 0) {
				return me.newPointResult(_result[me.id]);
			} else {
				_result[me.id] = findAirportsByICAO(left(id,4));
				if (size(_result[me.id]) != 0) {
					return me.newPointRWY(_result[me.id],id);
				}
			}
			return 0;
		} elsif (size(id) >= 12) {
			_result[me.id] = fetchLatLon(id);
			if (size(_result[me.id]) != 0) {
				return me.newPointLatLon(_result[me.id]);
			}
			return 0;
		}
		return 0;
	},
	update: func() {
		if (me.selectedPoint == nil) {
			return;
		}
		if (find("PROG",canvas_mcdu.pageProp[me.id].getValue()) == -1) {
			return;
		}
		_courseAndDistance[me.id] = courseAndDistance(me.selectedPoint);
		me.bearing = _courseAndDistance[me.id][0];
		me.distance = _courseAndDistance[me.id][1];
	},
};

var bearingDistances = [bearingDistanceInstance.new(0),bearingDistanceInstance.new(1)];

var BDTimer = maketimer(2, func(){
    bearingDistances[0].update();
    bearingDistances[1].update();
});
BDTimer.start();