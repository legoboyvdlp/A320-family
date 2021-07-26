# A3XX FMGC Waypoint database
# Copyright (c) 2020 Josh Davidson (Octal450) and Jonathan Redpath (legoboyvdlp)

var nilTree = {
	"latitude": 0,
	"longitude": 0,
	"ident": "",
};

var WaypointDatabase = {
	waypointsVec: [],
	confirm: [0, 0],
	# addWP - adds pilot waypoint to waypoints vector
	# arg: wpObj - passed pilot waypoint object
	# return: 
	#  0 - not allowed
	#  2 - accepted
	#  4 - database full
	addWP: func(wpObj) {
		# validate ghost
		if (wpObj.wpGhost == nil) {
			return 0;
		}
		
		# check size of database
		if (me.getCount() >= 20) { 
			return 4;
		}
		
		if (wpObj.index >= me.getSize()) {
			# add to end, since index doesn't exist
			append(me.waypointsVec, wpObj);
			me.write();
			return 2;
		} elsif (me.waypointsVec[wpObj.index] == nil) {
			# add at passed index
			me.waypointsVec[wpObj.index] = wpObj;
			me.write();
			return 2;
		} else {
			# fall back to end
			logprint(4, "pilotWaypoint constructor claims index " ~ wpObj.index ~ " is nil, but it isn't!");
			append(me.waypointsVec, wpObj);
			me.write();
			return 2;
		}
		
	},
	# delete - empties waypoints vector
	# callerIdx is the calling mcdu
	delete: func(callerIdx) {
		var noDel = 0;
		for (var i = 0; i < me.getSize(); i = i + 1) {
			if (me.waypointsVec[i] != nil) {
				if (fmgc.flightPlanController.flightplans[2].indexOfWP(me.waypointsVec[i].wpGhost) == -1) { # docs says only checks active and secondary
					me.waypointsVec[i] = nil;
				}
			}
		}
		me.write();
		if (me.getCount() != 0) {
			mcdu.mcdu_message(callerIdx, "PILOT ELEMENT RETAINED");
		}
	},
	# deleteAtIndex - delete at specific index. Set to nil, so it still exists in vector
	deleteAtIndex: func(index) {
		if (index < 0 or index >= me.getSize() or index >= 20) {
			return;
		}
		me.waypointsVec[index] = nil;
		me.write();
	},
	# getNilIndex - find the first nil
	# post 2020.1 use dedicated function vecindex()
	getNilIndex: func() {
		for (var i = 0; i < me.getSize(); i = i + 1) {
			if (me.waypointsVec[i] == nil) {
				return i;
			}
		}
		return -1;
	},
	# getNonNilIndex - find the first non-nil
	# post 2020.1 use dedicated function vecindex()
	getNonNilIndex: func() {
		for (var i = 0; i < me.getSize(); i = i + 1) {
			if (me.waypointsVec[i] != nil) {
				return i;
			}
		}
		return -1;
	},
	# getNextFromIndex - find the next non-nil after a passed index
	getNextFromIndex: func(index) {
		for (var i = (index + 1); i < me.getSize(); i = i + 1) {
			if (me.waypointsVec[i] != nil) {
				return i;
			}
		}
		
		for (var i = 0; i <= index; i = i + 1) {
			if (me.waypointsVec[i] != nil) {
				return i;
			}
		}
		return index;
	},
	# getPreviousFromIndex - find the next non-nil before a passed index
	getPreviousFromIndex: func(index) {
		for (var i = (index - 1); i >= 0; i = i - 1) {
			if (me.waypointsVec[i] != nil) {
				return i;
			}
		}
		
		for (var i = (me.getSize() - 1); i >= index; i = i - 1) {
			if (me.waypointsVec[i] != nil) {
				return i;
			}
		}
		return index;
	},
	# getNoOfIndex - return what number passed item is in list, neglecting "nil"
	getNoOfIndex: func(index) {
		var count = 0;
		for (var i = 0; i <= index; i = i + 1) {
			if (me.waypointsVec[i] == nil) {
				continue;
			}
			count += 1;
		}
		return count;
	},
	# getCount - return size, neglecting "nil"
	getCount: func() {
		var count = 0;
		for (var i = 0; i < me.getSize(); i = i + 1) {
			if (me.waypointsVec[i] == nil) {
				continue;
			}
			count += 1;
		}
		return count;
	},
	# getSize - return maximum size of vector
	getSize: func() {
		return size(me.waypointsVec);
	},
	# getWP - try to find waypoint whose name matches passed argument
	getWP: func(text) {
		for (var i = 0; i < me.getSize(); i = i + 1) {
			if (me.waypointsVec[i] == nil) {
				continue;
			}
			if (text == me.waypointsVec[i].wpGhost.wp_name) {
				return me.waypointsVec[i].wpGhost;
			}
		}
		return nil;
	},
	# write - write to file, as a hash structure
	write: func() {
		var path = pts.Sim.fgHome.getValue() ~ "/Export/A320SavedWaypoints.xml";
		var tree = {
			waypoints: {
			
			},
		};
		
		for (var i = 0; i < me.getSize(); i = i + 1) {
			if (me.waypointsVec[i] != nil) {
				tree.waypoints["waypoint" ~ i] = me.waypointsVec[i].tree;
			}
		}
		
		io.writexml(path, props.Node.new(tree)); # write the data
	},
	# read - read from a file, extract using props interface
	read: func() {
		var path = pts.Sim.fgHome.getValue() ~ "/Export/A320SavedWaypoints.xml";
		# create file if it doesn't exist
		if (io.stat(path) == nil) {
			me.write();
			return;
		}
		var data = io.readxml(path).getChild("waypoints");
		var pilotWP = nil;
		for (var i = 0; i < 20; i = i + 1) {
			pilotWP = nil;
			var childNode = data.getChild("waypoint" ~ i); 
			if (childNode == nil) { 
				continue; 
			}
			
			var wpt = createWP({lat: num(childNode.getChild("latitude").getValue()), lon: num(childNode.getChild("longitude").getValue())},childNode.getChild("ident").getValue());
			
			if (left(childNode.getChild("ident").getValue(), 3) == "PBD") {
				pilotWP = pilotWaypoint.newAtPosition(wpt, "PBD", right(childNode.getChild("ident").getValue(), 1));
			} else {
				pilotWP = pilotWaypoint.newAtPosition(wpt, "LL", right(childNode.getChild("ident").getValue(), 1));
			}
			me.addWPToPos(pilotWP, right(childNode.getChild("ident").getValue(), 1));
		}
	},
	# addWPToPos - helper for reading - inserts at specific index
	# will create nil for intermediates
	addWPToPos: func(wpObj, position) {
		if (me.getSize() >= position) {
			me.waypointsVec[position - 1] = wpObj;
		} else {
			var numToIns = position - me.getSize();
			while (numToIns >= 1) {
				append(me.waypointsVec, nil);
				numToIns -= 1;
			}
			me.waypointsVec[position - 1] = wpObj;
		}
	},
};

var pilotWaypoint = {
	new: func(positioned, typeStr) {
		var pilotWp = { parents:[pilotWaypoint] };
		
		# Figure out what the first index is we can use
		var nilIndex = WaypointDatabase.getNilIndex();
		var position = nil;
		
		if (nilIndex == -1) {
			position = WaypointDatabase.getSize() + 1;
		} else {
			position = nilIndex + 1
		}
		
		pilotWp.setId(typeStr ~ sprintf("%s", position));
		pilotWp.index = position - 1;
		
		# set ghost to created waypoint
		pilotWp.wpGhost = createWP(positioned, pilotWp.id);
		
		pilotWp.tree = {
			"latitude": pilotWp.wpGhost.wp_lat,
			"longitude": pilotWp.wpGhost.wp_lon,
			"ident": pilotWp.id,
		};
		
		return pilotWp;
	},
	newAtPosition: func(positioned, typeStr, position) {
		var pilotWp = { parents:[pilotWaypoint] };
		
		pilotWp.setId(typeStr ~ sprintf("%s", position));
		pilotWp.index = position - 1;
		
		# set ghost to created waypoint
		pilotWp.wpGhost = positioned;
		
		pilotWp.tree = {
			"latitude": pilotWp.wpGhost.wp_lat,
			"longitude": pilotWp.wpGhost.wp_lon,
			"ident": pilotWp.id,
		};
		
		return pilotWp;
	},
	setId: func(id) {
		if (typeof(id) == "scalar") { me.id = id; }
	},
	getId: func() {
		if (me.id != nil) { return id; }
	},
};

setlistener("/MCDU[0]/page", func() {
	if (getprop("/MCDU[0]/page") != "PILOTWP" and getprop("/MCDU[0]/page") != "STATUS") {
		WaypointDatabase.confirm[0] = 0;
	}
}, 0, 0);

setlistener("/MCDU[1]/page", func() {
	if (getprop("/MCDU[1]/page") != "PILOTWP" and getprop("/MCDU[1]/page") != "STATUS") {
		WaypointDatabase.confirm[1] = 0;
	}
}, 0, 0);