# A3XX FMGC Waypoint database
# Copyright (c) 2020 Josh Davidson (Octal450) and Jonathan Redpath (legoboyvdlp)

var WaypointDatabase = {
	waypointsVec: [],
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
			return 2;
		} elsif (me.waypointsVec[wpObj.index] == nil) {
			# add at passed index
			me.waypointsVec[wpObj.index] = wpObj;
		} else {
			# fall back to end
			logprint(4, "pilotWaypoint constructor claims index " ~ wpObj.index ~ " is nil, but it isn't!");
			append(me.waypointsVec, wpObj);
			return 2;
		}
	},
	# delete - empties waypoints vector
	delete: func() {
		me.waypointsVec = [];
	},
	# deleteAtIndex - delete at specific index. Set to nil, so it still exists in vector
	deleteAtIndex: func(index) {
		if (index < 0 or index >= me.getSize() or index >= 20) {
			return;
		}
		me.waypointsVec[index] = nil;
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
	# write - write to file, as a delimited string
	write: func() {
		var path = getprop("/sim/fg-home") ~ "/Export/savedWaypoints.txt";
		var file = io.open(path, "wb"); # open in write mode
		
		var tree = {
			"waypoints": {
			
			},
		};
		
		var node = props.Node.new(tree);
		
		for (var i = 0; i < me.getSize(); i = i + 1) {
			if (me.waypointsVec[i] != nil) {
				node.getChild("waypoints").addChild(me.waypointsVec[i].tree);
				debug.dump(me.waypointsVec[i].tree);
			}
		}
		debug.dump(node);
		
		io.writexml(file, node); # write the data
		io.close(file); # close (and flush) the file stream
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
			"waypoint": {
				"latitude": pilotWp.wpGhost.wp_lat,
				"longitude": pilotWp.wpGhost.wp_lon,
				"ident": pilotWp.id,
			},
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