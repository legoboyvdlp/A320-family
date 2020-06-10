# A3XX FMGC Wind Driver
# Copyright (c) 2020 Matthew Maring (mattmaring)

var wpDep = nil;
var wpArr = nil;
var pos = nil;
var geoPosPrev = geo.Coord.new();
var currentLegCourseDist = nil;
var courseDistanceFrom = nil;
var courseDistanceFromPrev = nil;
var sizeWP = nil;
var magTrueError = 0;
var storeCourse = nil;

var DEBUG_DISCONT = 0;

# Props.getNode
var magHDG = props.globals.getNode("/orientation/heading-magnetic-deg", 1);
var trueHDG = props.globals.getNode("/orientation/heading-deg", 1);
var FMGCdep = props.globals.getNode("/FMGC/internal/dep-arpt", 1);
var FMGCarr = props.globals.getNode("/FMGC/internal/arr-arpt", 1);
var toFromSet = props.globals.getNode("/FMGC/internal/tofrom-set", 1);

var wind = {
	new: func() {
		return {
			parents: [wind],
			heading: 0,
			magnitude: 0,
			altitude: 0
		};
	}
};

var waypoint_winds = {
	type: "", #departure, waypoint, arrival
	includeWind: 1,
	wind1: 0,
	wind2: 0,
	wind3: 0,
	wind4: 0,
	wind5: 0,
	
	new: func(id, type, includeWind) {
		me.id = id;
		me.type = type;
		me.includeWind = includeWind;
		return {
			id: me.id,
			type: me.type, #departure, waypoint, arrival
			includeWind: me.includeWind,
			wind1: wind.new(),
			wind2: wind.new(),
			wind3: wind.new(),
			wind4: wind.new(),
			wind5: wind.new()
		};
	}
};

var windController = {
	winds: [[], [], []],
	nav_indicies: [[], [], []],
	windSizes: [0, 0, 0],
	#temporaryFlag: [0, 0],
	
	init: func() {
		me.resetWind(2);
		#me.insertWind(2, 0, 1);
		#me.insertWind(2, 1, 0);
		# temp = waypoint_winds.new("KCVG", "waypoint", 1);
# 		print(temp.wind2.magnitude);
# 		temp.wind2.magnitude = 200;
# 		print(temp.wind2.magnitude);
	},
	
	reset: func() {
		#me.temporaryFlag[0] = 0;
		#me.temporaryFlag[1] = 0;
		me.resetWind(0);
		me.resetWind(1);
		me.resetWind(2);
	},
	
	resetWind: func(n) {
		me.winds[n] = [];
		me.nav_indicies[n] = [];
		me.windSizes[n] = 0;
	},
	
	createTemporaryWinds: func(n) {
		me.resetWind(n);
		me.winds[n] = me.winds[2];
		me.nav_indicies[n] = me.nav_indicies[2];
		me.windSizes[n] = me.windSizes[2];
		#me.temporaryFlag[n] = 1;
	},
	
	destroyTemporaryWinds: func(n, a) { # a = 1 activate, a = 0 erase
		me.updatePlans();
		if (a == 1) {
			me.resetWind(2);
			me.winds[2] = me.winds[n];
			me.nav_indicies[2] = me.nav_indicies[n];
			me.windSizes[2] = me.windSizes[n];
		}
		if (n == 3) { return; }
		me.resetWind(n);
		#me.temporaryFlag[n] = 0;
	},
	
	insertWind: func(plan, index, value, id) {
		if (me.windSizes[plan] == index) {
			if (value == 3) {
				append(me.winds[plan], waypoint_winds.new(id, "arrival", 0));
			} else if (value == 2) {
				append(me.winds[plan], waypoint_winds.new(id, "departure", 0));
			} else if (value == 1) {
				append(me.winds[plan], waypoint_winds.new(id, "waypoint", 1));
			} else {
				append(me.winds[plan], waypoint_winds.new(id, "waypoint", 0));
			}
			me.windSizes[plan] += 1;
		} else if (me.windSizes[plan] > index and index >= 0) {
			append(me.winds[plan], waypoint_winds.new(id, "waypoint", 0));
			me.windSizes[plan] += 1;
			for (i = me.windSizes[plan] - 1; i > index; i -= 1) {
				me.winds[plan][i] = me.winds[plan][i - 1];
			}
			if (value == 3) {
				me.winds[plan][index] = waypoint_winds.new(id, "arrival", 0);
			} else if (value == 2) {
				me.winds[plan][index] = waypoint_winds.new(id, "departure", 0);
			} else if (value == 1) {
				me.winds[plan][index] = waypoint_winds.new(id, "waypoint", 1);
			} else {
				me.winds[plan][index] = waypoint_winds.new(id, "waypoint", 0);
			}
		} else {
			print("insert invalid id: ", id, ", plan: ", plan, ", index: ", index, ", size: ", me.windSizes[plan]);
			debug.dump(me.winds);
			debug.dump(me.windSizes);
			return;
		}
		print("insert plan: ", plan, ", index: ", index);
		debug.dump(me.winds);
		debug.dump(me.windSizes);
	},
	
	deleteWind: func(plan, index) {
		if (me.windSizes[plan] == index) {
			pop(me.winds[plan]);
			me.windSizes[plan] -= 1;
		} else if (me.windSizes[plan] > index and index >= 0) {
			for (i = index; i < me.windSizes[plan] - 1; i += 1) {
				me.winds[plan][i] = me.winds[plan][i + 1];
			}
			pop(me.winds[plan]);
			me.windSizes[plan] -= 1;
		} else {
			print("delete invalid plan: ", plan, ", index: ", index, ", size: ", me.windSizes[plan]);
			debug.dump(me.winds);
			debug.dump(me.windSizes);
			return;
		}
		print("delete plan: ", plan, ", index: ", index);
		debug.dump(me.winds);
		debug.dump(me.windSizes);
	},
	
	updatePlans: func() {
		var winds_copy = me.winds;
		var windSizes_copy = me.windSizes;
		me.winds = [[], [], []];
		me.nav_indicies = [[], [], []];
		me.windSizes = [0, 0, 0];
		# loop through waypoints
		for (plan = 0; plan <= 2; plan += 1) {
			for (i = 0; i < fmgc.flightPlanController.flightplans[plan].getPlanSize(); i += 1) {
				var waypoint = fmgc.flightPlanController.flightplans[plan].getWP(i);
				print(waypoint.wp_role, "| : |", waypoint.wp_type);
				if (waypoint.wp_role == "sid") {
					append(me.winds[plan], waypoint_winds.new(waypoint.id, "departure", 0));
					me.windSizes[plan] += 1;
				} else if (waypoint.wp_role == "star" or waypoint.wp_role == "arrival" or waypoint.wp_role == "missed") {
					append(me.winds[plan], waypoint_winds.new(waypoint.id, "arrival", 0));
					me.windSizes[plan] += 1;
				} else if (waypoint.wp_role == nil and waypoint.wp_type == "navaid") {
					var found = 0;
					for (index = 0; index < windSizes_copy[plan]; index += 1) {
						print(waypoint.id, " : ", winds_copy[plan][index].id);
						if (waypoint.id == winds_copy[plan][index].id) {
							append(me.winds[plan], waypoint_winds.new(waypoint.id, "waypoint", 1));
							append(me.nav_indicies[plan], i);
							me.windSizes[plan] += 1;
							found = 1;
						}
					}
					if (found != 1) {
						append(me.winds[plan], waypoint_winds.new(waypoint.id, "waypoint", 0));
						me.windSizes[plan] += 1;
					}
				} else {
					append(me.winds[plan], waypoint_winds.new(waypoint.id, "waypoint", 0));
					me.windSizes[plan] += 1;
				}
				print("insert plan: ", plan, ", index: ", i);
				debug.dump(me.winds);
				debug.dump(me.nav_indicies);
				debug.dump(me.windSizes);
			}
		}
		
		me.updateWind(0);
		me.updateWind(1);
		me.updateWind(2);
	},

	updateWind: func(n) {
		if (n == 0) {
			if (canvas_mcdu.myCLBWIND[0] != nil and canvas_mcdu.myCLBWIND[1] != nil) {
				canvas_mcdu.myCLBWIND[1].windList = canvas_mcdu.myCLBWIND[0].windList;
				canvas_mcdu.myCLBWIND[1]._setupPageWithData();
			}
			
			if (canvas_mcdu.myCRZWIND[0] != nil and canvas_mcdu.myCRZWIND[1] != nil) {
				if (!getprop("/FMGC/internal/tofrom-set") and size(me.getWaypointList(0)) == 0) {
					canvas_mcdu.myCRZWIND[1].windList = canvas_mcdu.myCRZWIND[0].windList;
				} else {
					canvas_mcdu.myCRZWIND[1].del();
					canvas_mcdu.myCRZWIND[1] = nil;
					canvas_mcdu.myCRZWIND[1] = mcdu.windCRZPage.new(1, me.getWaypointList(2)[0], 0);
				}
				canvas_mcdu.myCRZWIND[1]._setupPageWithData();
			} else if (canvas_mcdu.myCRZWIND[1] != nil and getprop("/FMGC/internal/tofrom-set") and size(me.getWaypointList(0)) > 0) {
				canvas_mcdu.myCRZWIND[1].del();
				canvas_mcdu.myCRZWIND[1] = nil;
				canvas_mcdu.myCRZWIND[1] = mcdu.windCRZPage.new(1, me.getWaypointList(2)[0], 0);
				canvas_mcdu.myCRZWIND[1]._setupPageWithData();
			}
			
			if (canvas_mcdu.myDESWIND[0] != nil and canvas_mcdu.myDESWIND[1] != nil) {
				canvas_mcdu.myDESWIND[1].windList = canvas_mcdu.myDESWIND[0].windList;
				canvas_mcdu.myDESWIND[1]._setupPageWithData();
			}
			
			if (canvas_mcdu.myHISTWIND[1] != nil) {
				canvas_mcdu.myHISTWIND[1]._setupPageWithData();
			}
		} else {
			if (canvas_mcdu.myCLBWIND[0] != nil and canvas_mcdu.myCLBWIND[1] != nil) {
				canvas_mcdu.myCLBWIND[0].windList = canvas_mcdu.myCLBWIND[1].windList;
				canvas_mcdu.myCLBWIND[0]._setupPageWithData();
			}
			
			if (canvas_mcdu.myCRZWIND[0] != nil and canvas_mcdu.myCRZWIND[1] != nil) {
				if (!getprop("/FMGC/internal/tofrom-set") and size(me.getWaypointList(1)) == 0) {
					canvas_mcdu.myCRZWIND[0].windList = canvas_mcdu.myCRZWIND[1].windList;
				} else {
					canvas_mcdu.myCRZWIND[0].del();
					canvas_mcdu.myCRZWIND[0] = nil;
					canvas_mcdu.myCRZWIND[0] = mcdu.windCRZPage.new(0, me.getWaypointList(2)[0], 0);
				}
				canvas_mcdu.myCRZWIND[0]._setupPageWithData();
			} else if (canvas_mcdu.myCRZWIND[0] != nil and getprop("/FMGC/internal/tofrom-set") and size(me.getWaypointList(1)) > 0) {
				canvas_mcdu.myCRZWIND[0].del();
				canvas_mcdu.myCRZWIND[0] = nil;
				canvas_mcdu.myCRZWIND[0] = mcdu.windCRZPage.new(0, me.getWaypointList(2)[0], 0);
				canvas_mcdu.myCRZWIND[0]._setupPageWithData();
			}
			
			if (canvas_mcdu.myDESWIND[0] != nil and canvas_mcdu.myDESWIND[1] != nil) {
				canvas_mcdu.myDESWIND[0].windList = canvas_mcdu.myDESWIND[1].windList;
				canvas_mcdu.myDESWIND[0]._setupPageWithData();
			}
			
			if (canvas_mcdu.myHISTWIND[0] != nil) {
				canvas_mcdu.myHISTWIND[0]._setupPageWithData();
			}
		}
	}
};
