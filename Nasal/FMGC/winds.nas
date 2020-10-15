# A3XX FMGC Wind Driver
# Copyright (c) 2020 Matthew Maring (mattmaring)

var wind = {
	new: func() {
		var w = {parents: [wind]};
		w.heading = -1;
		w.magnitude = -1;
		w.altitude = "";
		w.set = 0;
		return w;
	},
	
	newcopy: func(heading, magnitude, altitude, set) {
		var w = {parents: [wind]};
		w.heading = heading;
		w.magnitude = magnitude;
		w.altitude = altitude;
		w.set = set;
		return w;
	}
};

var alt_wind = {
	new: func() {
		var aw = {parents: [alt_wind]};
		aw.heading = -1;
		aw.magnitude = -1;
		aw.set = 0;
		return aw;
	},
	
	newcopy: func(heading, magnitude, set) {
		var aw = {parents: [alt_wind]};
		aw.heading = heading;
		aw.magnitude = magnitude;
		aw.set = set;
		return aw;
	}
};

var sat_temp = {
	new: func() {
		var st = {parents: [sat_temp]};
		st.temp = -999;
		st.altitude = "";
		st.set = 0;
		return st;
	},
	
	newcopy: func(temp, altitude, set) {
		var st = {parents: [sat_temp]};
		st.temp = temp;
		st.altitude = altitude;
		st.set = set;
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
	hist_winds: 0,
	fl50_wind: [-1, -1, ""],
	fl150_wind: [-1, -1, ""],
	fl250_wind: [-1, -1, ""],
	flcrz_wind: [-1, -1, ""],
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
		me.hist_winds = waypoint_winds.new("history", "waypoint", 1);
		me.read();
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
	
	resetDesWinds: func() {
		me.des_winds[0] = 0;
		me.des_winds[1] = 0;
		me.des_winds[2] = waypoint_winds.new("descent", "waypoint", 1);
	},
	
	copyClbWind: func(n) {
		var id = me.clb_winds[n].id;
		var type = me.clb_winds[n].type;
		var includeWind = me.clb_winds[n].includeWind;
		var wind1 = wind.newcopy(me.clb_winds[n].wind1.heading, me.clb_winds[n].wind1.magnitude, me.clb_winds[n].wind1.altitude, me.clb_winds[n].wind1.set);
		var wind2 = wind.newcopy(me.clb_winds[n].wind2.heading, me.clb_winds[n].wind2.magnitude, me.clb_winds[n].wind2.altitude, me.clb_winds[n].wind2.set);
		var wind3 = wind.newcopy(me.clb_winds[n].wind3.heading, me.clb_winds[n].wind3.magnitude, me.clb_winds[n].wind3.altitude, me.clb_winds[n].wind3.set);
		var wind4 = wind.newcopy(me.clb_winds[n].wind4.heading, me.clb_winds[n].wind4.magnitude, me.clb_winds[n].wind4.altitude, me.clb_winds[n].wind4.set);
		var wind5 = wind.newcopy(me.clb_winds[n].wind5.heading, me.clb_winds[n].wind5.magnitude, me.clb_winds[n].wind5.altitude, me.clb_winds[n].wind5.set);
		var sat1 = sat_temp.newcopy(me.clb_winds[n].sat1.temp, me.clb_winds[n].sat1.altitude, me.clb_winds[n].sat1.set);
		var alt1 = alt_wind.newcopy(me.clb_winds[n].alt1.heading, me.clb_winds[n].alt1.magnitude, me.clb_winds[n].alt1.set);
		return waypoint_winds.newcopy(id, type, includeWind, wind1, wind2, wind3, wind4, wind5, sat1, alt1);
	},
	
	copyCrzWind: func(n) {
		var id = me.crz_winds[n].id;
		var type = me.crz_winds[n].type;
		var includeWind = me.crz_winds[n].includeWind;
		var wind1 = wind.newcopy(me.crz_winds[n].wind1.heading, me.crz_winds[n].wind1.magnitude, me.crz_winds[n].wind1.altitude, me.crz_winds[n].wind1.set);
		var wind2 = wind.newcopy(me.crz_winds[n].wind2.heading, me.crz_winds[n].wind2.magnitude, me.crz_winds[n].wind2.altitude, me.crz_winds[n].wind2.set);
		var wind3 = wind.newcopy(me.crz_winds[n].wind3.heading, me.crz_winds[n].wind3.magnitude, me.crz_winds[n].wind3.altitude, me.crz_winds[n].wind3.set);
		var wind4 = wind.newcopy(me.crz_winds[n].wind4.heading, me.crz_winds[n].wind4.magnitude, me.crz_winds[n].wind4.altitude, me.crz_winds[n].wind4.set);
		var wind5 = wind.newcopy(me.crz_winds[n].wind5.heading, me.crz_winds[n].wind5.magnitude, me.crz_winds[n].wind5.altitude, me.crz_winds[n].wind5.set);
		var sat1 = sat_temp.newcopy(me.crz_winds[n].sat1.temp, me.crz_winds[n].sat1.altitude, me.crz_winds[n].sat1.set);
		var alt1 = alt_wind.newcopy(me.crz_winds[n].alt1.heading, me.crz_winds[n].alt1.magnitude, me.crz_winds[n].alt1.set);
		return waypoint_winds.newcopy(id, type, includeWind, wind1, wind2, wind3, wind4, wind5, sat1, alt1);
	},
	
	copyDesWind: func(n) {
		var id = me.des_winds[n].id;
		var type = me.des_winds[n].type;
		var includeWind = me.des_winds[n].includeWind;
		var wind1 = wind.newcopy(me.des_winds[n].wind1.heading, me.des_winds[n].wind1.magnitude, me.des_winds[n].wind1.altitude, me.des_winds[n].wind1.set);
		var wind2 = wind.newcopy(me.des_winds[n].wind2.heading, me.des_winds[n].wind2.magnitude, me.des_winds[n].wind2.altitude, me.des_winds[n].wind2.set);
		var wind3 = wind.newcopy(me.des_winds[n].wind3.heading, me.des_winds[n].wind3.magnitude, me.des_winds[n].wind3.altitude, me.des_winds[n].wind3.set);
		var wind4 = wind.newcopy(me.des_winds[n].wind4.heading, me.des_winds[n].wind4.magnitude, me.des_winds[n].wind4.altitude, me.des_winds[n].wind4.set);
		var wind5 = wind.newcopy(me.des_winds[n].wind5.heading, me.des_winds[n].wind5.magnitude, me.des_winds[n].wind5.altitude, me.des_winds[n].wind5.set);
		var sat1 = sat_temp.newcopy(me.des_winds[n].sat1.temp, me.des_winds[n].sat1.altitude, me.des_winds[n].sat1.set);
		var alt1 = alt_wind.newcopy(me.des_winds[n].alt1.heading, me.des_winds[n].alt1.magnitude, me.des_winds[n].alt1.set);
		return waypoint_winds.newcopy(id, type, includeWind, wind1, wind2, wind3, wind4, wind5, sat1, alt1);
	},
	
	copyWinds: func(n) {
		var tempWind = [];
		for (i = 0; i < size(me.winds[n]); i += 1) {
			var id = me.winds[n][i].id;
			var type = me.winds[n][i].type;
			var includeWind = me.winds[n][i].includeWind;
			var wind1 = wind.newcopy(me.winds[n][i].wind1.heading, me.winds[n][i].wind1.magnitude, me.winds[n][i].wind1.altitude, me.winds[n][i].wind1.set);
			var wind2 = wind.newcopy(me.winds[n][i].wind2.heading, me.winds[n][i].wind2.magnitude, me.winds[n][i].wind2.altitude, me.winds[n][i].wind2.set);
			var wind3 = wind.newcopy(me.winds[n][i].wind3.heading, me.winds[n][i].wind3.magnitude, me.winds[n][i].wind3.altitude, me.winds[n][i].wind3.set);
			var wind4 = wind.newcopy(me.winds[n][i].wind4.heading, me.winds[n][i].wind4.magnitude, me.winds[n][i].wind4.altitude, me.winds[n][i].wind4.set);
			var wind5 = wind.newcopy(me.winds[n][i].wind5.heading, me.winds[n][i].wind5.magnitude, me.winds[n][i].wind5.altitude, me.winds[n][i].wind5.set);
			var sat1 = sat_temp.newcopy(me.winds[n][i].sat1.temp, me.winds[n][i].sat1.altitude, me.winds[n][i].sat1.set);
			var alt1 = alt_wind.newcopy(me.winds[n][i].alt1.heading, me.winds[n][i].alt1.magnitude, me.winds[n][i].alt1.set);
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
		#me.waypointsChanged();
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
		me.waypointsChanged();
		#me.temporaryFlag[n] = 0;
	},
	# read - read from hist wind file, create one if it doesn't exist
	read: func() {
		var path = getprop("/sim/fg-home") ~ "/Export/A320SavedWinds.txt";
		# create file if it doesn't exist
		if (io.stat(path) == nil) {
			me.write();
		}
		var file = io.open(path);
		if (file != nil) {
			var line = io.readln(file);
			var temp_line = split(",", line);
			me.hist_winds.wind1.heading = temp_line[0];
			me.hist_winds.wind1.magnitude = temp_line[1];
			me.hist_winds.wind1.altitude = temp_line[2];
			
			line = io.readln(file);
			temp_line = split(",", line);
			me.hist_winds.wind2.heading = temp_line[0];
			me.hist_winds.wind2.magnitude = temp_line[1];
			me.hist_winds.wind2.altitude = temp_line[2];
			
			line = io.readln(file);
			temp_line = split(",", line);
			me.hist_winds.wind3.heading = temp_line[0];
			me.hist_winds.wind3.magnitude = temp_line[1];
			me.hist_winds.wind3.altitude = temp_line[2];
			
			line = io.readln(file);
			temp_line = split(",", line);
			me.hist_winds.wind4.heading = temp_line[0];
			me.hist_winds.wind4.magnitude = temp_line[1];
			me.hist_winds.wind4.altitude = temp_line[2];
			
			line = io.readln(file);
			temp_line = split(",", line);
			me.hist_winds.wind5.heading = temp_line[0];
			me.hist_winds.wind5.magnitude = temp_line[1];
			me.hist_winds.wind5.altitude = temp_line[2];
		}
	},
	# write - write to hist wind file, called whenever winds changed
	write: func() {
		if (me.des_winds[2] != 0) {
			var path = getprop("/sim/fg-home") ~ "/Export/A320SavedWinds.txt";
			var file = io.open(path, "wb");
			var winds_added = 0;
			
			if (me.fl50_wind[2] != "") {
				io.write(file, me.fl50_wind[0] ~ "," ~ me.fl50_wind[1] ~ "," ~ me.fl50_wind[2] ~ "\n");
				winds_added += 1;
			}
			
			if (me.fl150_wind[2] != "") {
				io.write(file, me.fl150_wind[0] ~ "," ~ me.fl150_wind[1] ~ "," ~ me.fl150_wind[2] ~ "\n");
				winds_added += 1;
			}
			
			if (me.fl250_wind[2] != "") {
				io.write(file, me.fl250_wind[0] ~ "," ~ me.fl250_wind[1] ~ "," ~ me.fl250_wind[2] ~ "\n");
				winds_added += 1;
			}
			
			if (me.flcrz_wind[2] != "") {
				io.write(file, me.flcrz_wind[0] ~ "," ~ me.flcrz_wind[1] ~ "," ~ me.flcrz_wind[2] ~ "\n");
				winds_added += 1;
			}
			
			while (winds_added < 5) {
				io.write(file, "-1,-1,\n");
				winds_added += 1;
			}
			
			io.close(file);
		} else {
			print("no wind data");
		}
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
		me.waypointsChanged();
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
		me.waypointsChanged();
	},
	
	waypointsChanged: func() {
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
			canvas_mcdu.myCRZWIND[1].reload();
		}
		if (canvas_mcdu.myCRZWIND[0] != nil) {
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
