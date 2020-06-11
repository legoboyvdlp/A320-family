# A3XX FMGC Wind Driver
# Copyright (c) 2020 Matthew Maring (mattmaring)

var wind = {
	heading: 0,
	magnitude: 0,
	altitude: "",
	
	new: func() {
		return {
			parents: [wind],
			heading: 0,
			magnitude: 0,
			altitude: ""
		};
	},
	
	newcopy: func(heading, magnitude, altitude) {
		me.heading = heading;
		me.magnitude = magnitude;
		me.altitude = altitude;
		
		return {
			parents: [wind],
			heading: me.heading,
			magnitude: me.magnitude,
			altitude: me.altitude
		}
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
	},
	
	newcopy: func(id, type, includeWind, wind1, wind2, wind3, wind4, wind5) {
		me.id = id;
		me.type = type;
		me.includeWind = includeWind;
		me.wind1 = wind1;
		me.wind2 = wind2;
		me.wind3 = wind3;
		me.wind4 = wind4;
		me.wind5 = wind5;
		
		return {
			id: me.id,
			type: me.type, #departure, waypoint, arrival
			includeWind: me.includeWind,
			wind1: me.wind1,
			wind2: me.wind2,
			wind3: me.wind3,
			wind4: me.wind4,
			wind5: me.wind5
		};
	}
};

var windController = {
	clb_winds: [0, 0, 0],
	crz_winds: [0, 0, 0],
	des_winds: [0, 0, 0],
	winds: [[], [], []], #waypoint winds used if route includes navaids
	nav_indicies: [[], [], []],
	windSizes: [0, 0, 0],
	#temporaryFlag: [0, 0],
	
	init: func() {
		me.resetWind(2);
		me.clb_winds[2] = waypoint_winds.new("climb", "waypoint", 1);
		me.crz_winds[2] = waypoint_winds.new("cruize", "waypoint", 1);
		me.des_winds[2] = waypoint_winds.new("descent", "waypoint", 1);
	},
	
	reset: func() {
		#me.temporaryFlag[0] = 0;
		#me.temporaryFlag[1] = 0;
		me.resetWind(0);
		me.resetWind(1);
		me.resetWind(2);
	},
	
	resetWind: func(n) {
		me.clb_winds[n] = 0;
		me.crz_winds[n] = 0;
		me.des_winds[n] = 0;
		me.winds[n] = [];
		me.nav_indicies[n] = [];
		me.windSizes[n] = 0;
	},
	
	copyClbWind: func(n) {
		var id = me.clb_winds[n].id;
		var type = me.clb_winds[n].type;
		var includeWind = me.clb_winds[n].includeWind;
		var wind1 = wind.newcopy(me.clb_winds[n].wind1.heading, me.clb_winds[n].wind1.magnitude, me.clb_winds[n].wind1.altitude);
		var wind2 = wind.newcopy(me.clb_winds[n].wind2.heading, me.clb_winds[n].wind2.magnitude, me.clb_winds[n].wind2.altitude);
		var wind3 = wind.newcopy(me.clb_winds[n].wind3.heading, me.clb_winds[n].wind3.magnitude, me.clb_winds[n].wind3.altitude);
		var wind4 = wind.newcopy(me.clb_winds[n].wind4.heading, me.clb_winds[n].wind4.magnitude, me.clb_winds[n].wind4.altitude);
		var wind5 = wind.newcopy(me.clb_winds[n].wind5.heading, me.clb_winds[n].wind5.magnitude, me.clb_winds[n].wind5.altitude);
		return waypoint_winds.newcopy(id, type, includeWind, wind1, wind2, wind3, wind4, wind5);
	},
	
	copyCrzWind: func(n) {
		var id = me.crz_winds[n].id;
		var type = me.crz_winds[n].type;
		var includeWind = me.crz_winds[n].includeWind;
		var wind1 = wind.newcopy(me.crz_winds[n].wind1.heading, me.crz_winds[n].wind1.magnitude, me.crz_winds[n].wind1.altitude);
		var wind2 = wind.newcopy(me.crz_winds[n].wind2.heading, me.crz_winds[n].wind2.magnitude, me.crz_winds[n].wind2.altitude);
		var wind3 = wind.newcopy(me.crz_winds[n].wind3.heading, me.crz_winds[n].wind3.magnitude, me.crz_winds[n].wind3.altitude);
		var wind4 = wind.newcopy(me.crz_winds[n].wind4.heading, me.crz_winds[n].wind4.magnitude, me.crz_winds[n].wind4.altitude);
		var wind5 = wind.newcopy(me.crz_winds[n].wind5.heading, me.crz_winds[n].wind5.magnitude, me.crz_winds[n].wind5.altitude);
		return waypoint_winds.newcopy(id, type, includeWind, wind1, wind2, wind3, wind4, wind5);
	},
	
	copyDesWind: func(n) {
		var id = me.des_winds[n].id;
		var type = me.des_winds[n].type;
		var includeWind = me.des_winds[n].includeWind;
		var wind1 = wind.newcopy(me.des_winds[n].wind1.heading, me.des_winds[n].wind1.magnitude, me.des_winds[n].wind1.altitude);
		var wind2 = wind.newcopy(me.des_winds[n].wind2.heading, me.des_winds[n].wind2.magnitude, me.des_winds[n].wind2.altitude);
		var wind3 = wind.newcopy(me.des_winds[n].wind3.heading, me.des_winds[n].wind3.magnitude, me.des_winds[n].wind3.altitude);
		var wind4 = wind.newcopy(me.des_winds[n].wind4.heading, me.des_winds[n].wind4.magnitude, me.des_winds[n].wind4.altitude);
		var wind5 = wind.newcopy(me.des_winds[n].wind5.heading, me.des_winds[n].wind5.magnitude, me.des_winds[n].wind5.altitude);
		return waypoint_winds.newcopy(id, type, includeWind, wind1, wind2, wind3, wind4, wind5);
	},
	
	copyWinds: func(n) {
		var tempWind = [];
		for (i = 0; i < size(me.winds[n]); i += 1) {
			var id = me.winds[n][i].id;
			var type = me.winds[n][i].type;
			var includeWind = me.winds[n][i].includeWind;
			var wind1 = wind.newcopy(me.winds[n][i].wind1.heading, me.winds[n][i].wind1.magnitude, me.winds[n][i].wind1.altitude);
			var wind2 = wind.newcopy(me.winds[n][i].wind2.heading, me.winds[n][i].wind2.magnitude, me.winds[n][i].wind2.altitude);
			var wind3 = wind.newcopy(me.winds[n][i].wind3.heading, me.winds[n][i].wind3.magnitude, me.winds[n][i].wind3.altitude);
			var wind4 = wind.newcopy(me.winds[n][i].wind4.heading, me.winds[n][i].wind4.magnitude, me.winds[n][i].wind4.altitude);
			var wind5 = wind.newcopy(me.winds[n][i].wind5.heading, me.winds[n][i].wind5.magnitude, me.winds[n][i].wind5.altitude);
			append(tempWind, waypoint_winds.newcopy(id, type, includeWind, wind1, wind2, wind3, wind4, wind5));
		}
		return tempWind;
	},
	
	createTemporaryWinds: func(n) {
		me.resetWind(n);
		me.clb_winds[n] = me.copyClbWind(2);
		me.crz_winds[n] = me.copyCrzWind(2);
		me.des_winds[n] = me.copyDesWind(2);
		me.winds[n] = me.copyWinds(2);
		me.nav_indicies[n] = me.nav_indicies[2];
		me.windSizes[n] = me.windSizes[2];
		#me.temporaryFlag[n] = 1;
	},
	
	destroyTemporaryWinds: func(n, a) { # a = 1 activate, a = 0 erase
		#print("destroying temporary ", n);
		if (a == 1) {
			me.resetWind(2);
			me.clb_winds[2] = me.copyClbWind(n);
			me.crz_winds[2] = me.copyCrzWind(n);
			me.des_winds[2] = me.copyDesWind(n);
			me.winds[2] = me.copyWinds(n);
			me.nav_indicies[2] = me.nav_indicies[n];
			me.windSizes[2] = me.windSizes[n];
		}
		if (n == 3) { return; }
		me.resetWind(n);
		#me.updatePlans();
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
			#print("insert invalid id: ", id, ", plan: ", plan, ", index: ", index, ", size: ", me.windSizes[plan]);
			#debug.dump(me.winds);
			#debug.dump(me.windSizes);
			return;
		}
		#print("insert plan: ", plan, ", index: ", index);
		#debug.dump(me.winds);
		#debug.dump(me.windSizes);
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
			#print("delete invalid plan: ", plan, ", index: ", index, ", size: ", me.windSizes[plan]);
			#debug.dump(me.winds);
			#debug.dump(me.windSizes);
			return;
		}
		#print("delete plan: ", plan, ", index: ", index);
		#debug.dump(me.winds);
		#debug.dump(me.windSizes);
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
				#print(waypoint.wp_role, "| : |", waypoint.wp_type);
				if (waypoint.wp_role == "sid") {
					append(me.winds[plan], waypoint_winds.new(waypoint.id, "departure", 0));
					me.windSizes[plan] += 1;
				} else if (waypoint.wp_role == "star" or waypoint.wp_role == "arrival" or waypoint.wp_role == "missed") {
					append(me.winds[plan], waypoint_winds.new(waypoint.id, "arrival", 0));
					me.windSizes[plan] += 1;
				} else if (waypoint.wp_role == nil and waypoint.wp_type == "navaid") {
					var found = 0;
					for (index = 0; index < windSizes_copy[plan]; index += 1) {
						#print(waypoint.id, " : ", winds_copy[plan][index].id);
						if (waypoint.id == winds_copy[plan][index].id) {
							append(me.winds[plan], winds_copy[plan][index]);
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
				#print("insert plan: ", plan, ", index: ", i);
				#debug.dump(me.winds);
				#debug.dump(me.nav_indicies);
				#debug.dump(me.windSizes);
			}
		}
		
		debug.dump(me.nav_indicies);
		
		if (canvas_mcdu.myCLBWIND[1] != nil) {
			canvas_mcdu.myCLBWIND[1].reload();
		}
		if (canvas_mcdu.myCLBWIND[0] != nil) {
			canvas_mcdu.myCLBWIND[0].reload();
		}
		if (canvas_mcdu.myCRZWIND[1] != nil) {
			if (getprop("/FMGC/internal/tofrom-set") and size(fmgc.windController.nav_indicies[1]) > 0) {
				canvas_mcdu.myCRZWIND[1].waypoint = fmgc.flightPlanController.flightplans[2].getWP(me.nav_indicies[2][0]);
				canvas_mcdu.myCRZWIND[1].cur_location = 0;
			}
			canvas_mcdu.myCRZWIND[1].reload();
		}
		if (canvas_mcdu.myCRZWIND[0] != nil) {
			if (getprop("/FMGC/internal/tofrom-set") and size(fmgc.windController.nav_indicies[0]) > 0) {
				canvas_mcdu.myCRZWIND[0].waypoint = fmgc.flightPlanController.flightplans[2].getWP(me.nav_indicies[2][0]);
				canvas_mcdu.myCRZWIND[0].cur_location = 0;
			}
			canvas_mcdu.myCRZWIND[0].reload();
		}
		if (canvas_mcdu.myDESWIND[1] != nil) {
			canvas_mcdu.myDESWIND[1].reload();
		}
		if (canvas_mcdu.myDESWIND[0] != nil) {
			canvas_mcdu.myDESWIND[0].reload();
		}
	}
};
