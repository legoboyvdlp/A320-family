# A3XX FMGC Wind Driver
# Copyright (c) 2020 Matthew Maring (mattmaring)

var wind = {
	new: func() {
		var w = {parents: [wind]};
		w.heading = 0;
		w.magnitude = 0;
		w.altitude = "";
		return w;
	},
	
	newcopy: func(heading, magnitude, altitude) {
		var w = {parents: [wind]};
		w.heading = heading;
		w.magnitude = magnitude;
		w.altitude = altitude;
		return w;
	}
};

var alt_wind = {
	new: func() {
		var aw = {parents: [alt_wind]};
		aw.heading = 0;
		aw.magnitude = 0;
		return aw;
	},
	
	newcopy: func(heading, magnitude) {
		var aw = {parents: [alt_wind]};
		aw.heading = heading ;
		aw.magnitude = magnitude;
		return aw;
	}
};

var sat_temp = {
	new: func() {
		var st = {parents: [sat_temp]};
		st.temp = 0;
		st.altitude = "";
		return st;
	},
	
	newcopy: func(temp, altitude) {
		var st = {parents: [sat_temp]};
		st.temp = temp;
		st.altitude = altitude;
		return st;
	}
};

var waypoint_winds = {
	new: func(id, type, includeWind) {
		var ww = {parents: [waypoint_winds]};
		ww.id = id;
		ww.type = type; #departure, waypoint, arrival
		ww.includeWind = includeWind;
		ww.wind1 = wind.new();
		ww.wind2 = wind.new();
		ww.wind3 = wind.new();
		ww.wind4 = wind.new();
		ww.wind5 = wind.new();
		ww.sat1 = sat_temp.new();
		ww.alt1 = alt_wind.new();
		return ww;
	},
	
	newcopy: func(id, type, includeWind, wind1, wind2, wind3, wind4, wind5, sat1, alt1) {
		var ww = {parents: [waypoint_winds]};
		ww.id = id;
		ww.type = type; #departure, waypoint, arrival
		ww.includeWind = includeWind;
		ww.wind1 = wind1;
		ww.wind2 = wind2;
		ww.wind3 = wind3;
		ww.wind4 = wind4;
		ww.wind5 = wind5;
		ww.sat1 = sat1;
		ww.alt1 = alt1;
		return ww;
	}
};

var windController = {
	clb_winds: [0, 0, 0],
	crz_winds: [0, 0, 0],
	des_winds: [0, 0, 0],
	winds: [[], [], []], #waypoint winds used if route includes navaids
	nav_indicies: [[], [], []],
	windSizes: [0, 0, 0],
	accessPage: ["", ""],
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
		var sat1 = sat_temp.newcopy(me.clb_winds[n].sat1.temp, me.clb_winds[n].sat1.altitude);
		var alt1 = alt_wind.newcopy(me.clb_winds[n].alt1.heading, me.clb_winds[n].alt1.magnitude);
		return waypoint_winds.newcopy(id, type, includeWind, wind1, wind2, wind3, wind4, wind5, sat1, alt1);
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
		var sat1 = sat_temp.newcopy(me.crz_winds[n].sat1.temp, me.crz_winds[n].sat1.altitude);
		var alt1 = alt_wind.newcopy(me.crz_winds[n].alt1.heading, me.crz_winds[n].alt1.magnitude);
		return waypoint_winds.newcopy(id, type, includeWind, wind1, wind2, wind3, wind4, wind5, sat1, alt1);
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
		var sat1 = sat_temp.newcopy(me.des_winds[n].sat1.temp, me.des_winds[n].sat1.altitude);
		var alt1 = alt_wind.newcopy(me.des_winds[n].alt1.heading, me.des_winds[n].alt1.magnitude);
		return waypoint_winds.newcopy(id, type, includeWind, wind1, wind2, wind3, wind4, wind5, sat1, alt1);
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
			var sat1 = sat_temp.newcopy(me.winds[n][i].sat1.temp, me.winds[n][i].sat1.altitude);
			var alt1 = alt_wind.newcopy(me.winds[n][i].alt1.heading, me.winds[n][i].alt1.magnitude);
			append(tempWind, waypoint_winds.newcopy(id, type, includeWind, wind1, wind2, wind3, wind4, wind5, sat1, alt1));
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
				} else if (waypoint.wp_role == "star" or waypoint.wp_role == "approach" or waypoint.wp_role == "missed") {
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
		
		if (canvas_mcdu.myCLBWIND[1] != nil) {
			canvas_mcdu.myCLBWIND[1].reload();
		}
		if (canvas_mcdu.myCLBWIND[0] != nil) {
			canvas_mcdu.myCLBWIND[0].reload();
		}
		if (canvas_mcdu.myCRZWIND[1] != nil) {
			if (!fmgc.flightPlanController.temporaryFlag[1]) {
				if (fmgc.FMGCInternal.toFromSet and size(fmgc.windController.nav_indicies[2]) > 0) {
					canvas_mcdu.myCRZWIND[1].waypoint = fmgc.flightPlanController.flightplans[2].getWP(me.nav_indicies[2][0]);
					canvas_mcdu.myCRZWIND[1].singleCRZ = 0;
					canvas_mcdu.myCRZWIND[1].cur_location = 0;
				} else {
					canvas_mcdu.myCRZWIND[1].waypoint = nil;
					canvas_mcdu.myCRZWIND[1].singleCRZ = 1;
					canvas_mcdu.myCRZWIND[1].cur_location = 0;
				}
			} else {
				if (fmgc.FMGCInternal.toFromSet and size(fmgc.windController.nav_indicies[1]) > 0) {
					canvas_mcdu.myCRZWIND[1].waypoint = fmgc.flightPlanController.flightplans[1].getWP(me.nav_indicies[1][0]);
					canvas_mcdu.myCRZWIND[1].singleCRZ = 0;
					canvas_mcdu.myCRZWIND[1].cur_location = 0;
				} else {
					canvas_mcdu.myCRZWIND[1].waypoint = nil;
					canvas_mcdu.myCRZWIND[1].singleCRZ = 1;
					canvas_mcdu.myCRZWIND[1].cur_location = 0;
				}
			}
			canvas_mcdu.myCRZWIND[1].reload();
		}
		if (canvas_mcdu.myCRZWIND[0] != nil) {
			if (!fmgc.flightPlanController.temporaryFlag[0]) {
				if (fmgc.FMGCInternal.toFromSet and size(fmgc.windController.nav_indicies[2]) > 0) {
					canvas_mcdu.myCRZWIND[0].waypoint = fmgc.flightPlanController.flightplans[2].getWP(me.nav_indicies[2][0]);
					canvas_mcdu.myCRZWIND[0].singleCRZ = 0;
					canvas_mcdu.myCRZWIND[0].cur_location = 0;
				} else {
					canvas_mcdu.myCRZWIND[0].waypoint = nil;
					canvas_mcdu.myCRZWIND[0].singleCRZ = 1;
					canvas_mcdu.myCRZWIND[0].cur_location = 0;
				}
			} else {
				if (fmgc.FMGCInternal.toFromSet and size(fmgc.windController.nav_indicies[0]) > 0) {
					canvas_mcdu.myCRZWIND[0].waypoint = fmgc.flightPlanController.flightplans[0].getWP(me.nav_indicies[0][0]);
					canvas_mcdu.myCRZWIND[0].singleCRZ = 0;
					canvas_mcdu.myCRZWIND[0].cur_location = 0;
				} else {
					canvas_mcdu.myCRZWIND[0].waypoint = nil;
					canvas_mcdu.myCRZWIND[0].singleCRZ = 1;
					canvas_mcdu.myCRZWIND[0].cur_location = 0;
				}
			}
			canvas_mcdu.myCRZWIND[0].reload();
		}
		if (canvas_mcdu.myDESWIND[1] != nil) {
			canvas_mcdu.myDESWIND[1].reload();
		}
		if (canvas_mcdu.myDESWIND[0] != nil) {
			canvas_mcdu.myDESWIND[0].reload();
		}
		if (canvas_mcdu.myHISTWIND[1] != nil) {
			canvas_mcdu.myHISTWIND[1].reload();
		}
		if (canvas_mcdu.myHISTWIND[0] != nil) {
			canvas_mcdu.myHISTWIND[0].reload();
		}
	}
};
