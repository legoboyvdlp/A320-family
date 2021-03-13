# A3XX FMGC Fuel Driver
# Copyright (c) 2020 Matthew Maring (mattmaring)

########
# FUEL #
########
# Calculations maintained at https://github.com/mattmaring/A320-family-fuel-model
# Copyright (c) 2020 Matthew Maring (mattmaring)
#

var efob_values = [[], [], []];
var time_values = [[], [], []];

var updateFuel = func {
	# Calculate (final) holding fuel
	if (fmgc.FMGCInternal.finalFuelSet) {
		final_fuel = 1000 * fmgc.FMGCInternal.finalFuel;
		zfw = 1000 * fmgc.FMGCInternal.zfw;
		final_time = final_fuel / (2.0 * ((zfw*zfw*-2e-10) + (zfw*0.0003) + 2.8903)); # x2 for 2 engines
		if (final_time < 0) {
			final_time = 0;
		} else if (final_time > 480) {
			final_time = 480;
		}
		if (num(final_time) >= 60) {
			final_min = int(math.mod(final_time, 60));
			final_hour = int((final_time - final_min) / 60);
			fmgc.FMGCInternal.finalTime = sprintf("%02d", final_hour) ~ sprintf("%02d", final_min);
		} else {
			fmgc.FMGCInternal.finalTime = sprintf("%04d", final_time);
		}
	} else {
		if (!fmgc.FMGCInternal.finalTimeSet) {
			fmgc.FMGCInternal.finalTime = "0030";
		}
		final_time = int(fmgc.FMGCInternal.finalTime);
		if (final_time >= 100) {
			final_time = final_time - 100 + 60; # can't be set above 90 (0130)
		}
		zfw = 1000 * fmgc.FMGCInternal.zfw;
		final_fuel = final_time * 2.0 * ((zfw*zfw*-2e-10) + (zfw*0.0003) + 2.8903); # x2 for 2 engines
		if (final_fuel < 0) {
			final_fuel = 0;
		} else if (final_fuel > 80000) {
			final_fuel = 80000;
		}
		fmgc.FMGCInternal.finalFuel = final_fuel / 1000;
	}
	
	# Calculate alternate fuel
	if (!fmgc.FMGCInternal.altFuelSet and fmgc.FMGCInternal.altAirportSet) {
		#calc
	} else if (fmgc.FMGCInternal.altFuelSet and fmgc.FMGCInternal.altAirportSet) {
		#dummy calc for now
		alt_fuel = 1000 * num(fmgc.FMGCInternal.altFuel);
		zfw = 1000 * fmgc.FMGCInternal.zfw;
		alt_time = alt_fuel / (2.0 * ((zfw*zfw*-2e-10) + (zfw*0.0003) + 2.8903)); # x2 for 2 engines
		if (alt_time < 0) {
			alt_time = 0;
		} else if (alt_time > 480) {
			alt_time = 480;
		}
		if (num(alt_time) >= 60) {
			alt_min = int(math.mod(alt_time, 60));
			alt_hour = int((alt_time - alt_min) / 60);
			fmgc.FMGCInternal.altTime = sprintf("%02d", alt_hour) ~ sprintf("%02d", alt_min);
		} else {
			fmgc.FMGCInternal.altTime = sprintf("%04d", alt_time);
		}
	} else if (!fmgc.FMGCInternal.altFuelSet) {
		fmgc.FMGCInternal.altFuel = 0.0;
		fmgc.FMGCInternal.altTime = "0000";
	}
	
	# Calculate min dest fob (final + alternate)
	if (!fmgc.FMGCInternal.minDestFobSet) {
		fmgc.FMGCInternal.minDestFob = num(fmgc.FMGCInternal.altFuel + fmgc.FMGCInternal.finalFuel);
	}
	
	if (fmgc.FMGCInternal.zfwSet) {
		fmgc.FMGCInternal.lw = num(fmgc.FMGCInternal.zfw + fmgc.FMGCInternal.altFuel + fmgc.FMGCInternal.finalFuel);
	}
	
	# Calculate trip fuel
	if (fmgc.FMGCInternal.toFromSet and fmgc.FMGCInternal.crzSet and fmgc.FMGCInternal.crzTempSet and fmgc.FMGCInternal.zfwSet) {
		crz = fmgc.FMGCInternal.crzFl;
		temp = fmgc.FMGCInternal.crzTemp;
		dist = flightPlanController.totalDist.getValue();
		
		trpWind = fmgc.FMGCInternal.tripWind;
		wind_value = fmgc.FMGCInternal.tripWindValue;
		if (find("HD", trpWind) != -1 or find("-", trpWind) != -1 or find("H", trpWind) != -1) {
			wind_value = wind_value * -1;
		}
		dist = dist - (dist * wind_value * 0.002);

		# get trip fuel
		trip_fuel = getprop("/fuel/integrated/lr-fuel") * 1000; # fix this
		
		# cruize temp correction
		trip_fuel = trip_fuel + (0.033 * (temp - 15 + (2 * crz / 10)) * flightPlanController.totalDist.getValue());
		
		# get trip time
		trip_time = getprop("/fuel/integrated/lr-time");
		
		# if (low air conditioning) {
		#	trip_fuel = trip_fuel * 0.995;
		#}
		# if (total anti-ice) {
		#	trip_fuel = trip_fuel * 1.045;
		#} else if (engine anti-ice) {
		#	trip_fuel = trip_fuel * 1.02;
		#}

		fmgc.FMGCInternal.tripFuel = trip_fuel / 1000;
		fmgc.FMGCInternal.tripTime_num = trip_time;
		if (num(trip_time) >= 60) {
			trip_min = int(math.mod(trip_time, 60));
			trip_hour = int((trip_time - trip_min) / 60);
			fmgc.FMGCInternal.tripTime = sprintf("%02d", trip_hour) ~ sprintf("%02d", trip_min);
		} else {
			fmgc.FMGCInternal.tripTime = sprintf("%04d", trip_time);
		}
	} else {
		fmgc.FMGCInternal.tripFuel = 0.0;
		fmgc.FMGCInternal.tripTime = "0000";
		fmgc.FMGCInternal.tripTime_num = 0.0;
	}
	
	# Calculate reserve fuel
	if (fmgc.FMGCInternal.rteRsvSet) {
		if (num(fmgc.FMGCInternal.tripFuel) <= 0.0) {
			fmgc.FMGCInternal.rtePercent = 0.0;
		} else {
			if (num(fmgc.FMGCInternal.rteRsv / fmgc.FMGCInternal.tripFuel * 100.0) <= 15.0) {
				fmgc.FMGCInternal.rtePercent = num(fmgc.FMGCInternal.rteRsv / fmgc.FMGCInternal.tripFuel * 100.0);
			} else {
				fmgc.FMGCInternal.rtePercent = 15.0; # need reasearch on this value
			}
		}
	} else if (fmgc.FMGCInternal.rtePercentSet) {
		fmgc.FMGCInternal.rteRsv = num(fmgc.FMGCInternal.tripFuel * fmgc.FMGCInternal.rtePercent / 100.0);
	} else {
		if (num(fmgc.FMGCInternal.tripFuel) <= 0.0) {
			fmgc.FMGCInternal.rtePercent = 5.0;
		} else {
			fmgc.FMGCInternal.rteRsv = num(fmgc.FMGCInternal.tripFuel * fmgc.FMGCInternal.rtePercent / 100.0);
		}
	}
	
	# Misc fuel claclulations
	if (fmgc.FMGCInternal.blockCalculating) {
		fmgc.FMGCInternal.block = num(fmgc.FMGCInternal.altFuel + fmgc.FMGCInternal.finalFuel + fmgc.FMGCInternal.tripFuel + fmgc.FMGCInternal.rteRsv + fmgc.FMGCInternal.taxiFuel);
		fmgc.FMGCInternal.blockSet = 1;
	}
	fmgc.FMGCInternal.fob = num(pts.Consumables.Fuel.totalFuelLbs.getValue() / 1000);
	fmgc.FMGCInternal.fuelPredGw = num(pts.Fdm.JSBsim.Inertia.weightLbs.getValue() / 1000);
	fmgc.FMGCInternal.cg = fmgc.FMGCInternal.zfwcg;
	
	# Calcualte extra fuel
	if (num(pts.Engines.Engine.n1Actual[0].getValue()) > 0 or num(pts.Engines.Engine.n1Actual[1].getValue()) > 0) {
		extra_fuel = 1000 * num(fmgc.FMGCInternal.fob - fmgc.FMGCInternal.tripFuel - fmgc.FMGCInternal.minDestFob - fmgc.FMGCInternal.taxiFuel - fmgc.FMGCInternal.rteRsv);
	} else {
		extra_fuel = 1000 * num(fmgc.FMGCInternal.block - fmgc.FMGCInternal.tripFuel - fmgc.FMGCInternal.minDestFob - fmgc.FMGCInternal.taxiFuel - fmgc.FMGCInternal.rteRsv);
	}
	fmgc.FMGCInternal.extraFuel = extra_fuel / 1000;
	lw = 1000 * fmgc.FMGCInternal.lw;
	extra_time = extra_fuel / (2.0 * ((lw*lw*-2e-10) + (lw*0.0003) + 2.8903)); # x2 for 2 engines
	if (extra_time < 0) {
		extra_time = 0;
	} else if (extra_time > 480) {
		extra_time = 480;
	}
	if (num(extra_time) >= 60) {
		extra_min = int(math.mod(extra_time, 60));
		extra_hour = int((extra_time - extra_min) / 60);
		fmgc.FMGCInternal.extraTime = sprintf("%02d", extra_hour) ~ sprintf("%02d", extra_min);
	} else {
		fmgc.FMGCInternal.extraTime = sprintf("%04d", extra_time);
	}
	if (fmgc.FMGCInternal.extraFuel > -0.1 and fmgc.FMGCInternal.extraFuel < 0.1) {
		fmgc.FMGCInternal.extraFuel = 0.0;
	}
	
	fmgc.FMGCInternal.tow = num(fmgc.FMGCInternal.zfw + fmgc.FMGCInternal.block - fmgc.FMGCInternal.taxiFuel);
	fmgc.FMGCNodes.tow.setValue(fmgc.FMGCInternal.tow);
	
	# Calculate climb/descent fuel
	if (fmgc.FMGCInternal.toFromSet and fmgc.FMGCInternal.crzSet and fmgc.FMGCInternal.crzTempSet and fmgc.FMGCInternal.zfwSet) {
		fmgc.FMGCInternal.clbFuel = getprop("/fuel/integrated/climb-fuel");
		fmgc.FMGCInternal.clbTime_num = getprop("/fuel/integrated/climb-time");
		if (num(fmgc.FMGCInternal.clbTime_num) >= 60) {
			clb_min = int(math.mod(fmgc.FMGCInternal.clbTime_num, 60));
			clb_hour = int((fmgc.FMGCInternal.clbTime_num - clb_min) / 60);
			fmgc.FMGCInternal.clbTime = sprintf("%02d", clb_hour) ~ sprintf("%02d", clb_min);
		} else {
			fmgc.FMGCInternal.clbTime = sprintf("%04d", fmgc.FMGCInternal.clbTime_num);
		}
		fmgc.FMGCInternal.clbDist = getprop("/fuel/integrated/climb-dist");
		fmgc.FMGCInternal.clbSet = 1;
		
		fmgc.FMGCInternal.desFuel = getprop("/fuel/integrated/descent-fuel");
		fmgc.FMGCInternal.desTime_num = getprop("/fuel/integrated/descent-time");
		if (num(fmgc.FMGCInternal.desTime_num) >= 60) {
			des_min = int(math.mod(fmgc.FMGCInternal.desTime_num, 60));
			des_hour = int((fmgc.FMGCInternal.desTime_num - des_min) / 60);
			fmgc.FMGCInternal.desTime = sprintf("%02d", des_hour) ~ sprintf("%02d", des_min);
		} else {
			fmgc.FMGCInternal.desTime = sprintf("%04d", fmgc.FMGCInternal.desTime_num);
		}
		fmgc.FMGCInternal.desDist = getprop("/fuel/integrated/descent-dist");
		fmgc.FMGCInternal.desSet = 1;
		
		# update reached states
		alt = pts.Instrumentation.Altimeter.indicatedFt.getValue();
		currentDistance = fmgc.flightPlanController.totalDist.getValue() - fmgc.flightPlanController.arrivalDist.getValue();
		crz = fmgc.FMGCInternal.crzFt;
		
		if (fmgc.flightPlanController.tocPoint != nil and !fmgc.FMGCInternal.clbReached) {
			fmgc.FMGCInternal.clbReached = courseAndDistance(geo.aircraft_position(), fmgc.flightPlanController.tocPoint)[1] < 0.1;
			fmgc.FMGCInternal.clbDist -= (alt / crz - currentDistance / fmgc.FMGCInternal.clbDist) * fmgc.FMGCInternal.clbDist; # move to xml
		}
		
		if (fmgc.flightPlanController.todPoint != nil and !fmgc.FMGCInternal.desReached) {
			fmgc.FMGCInternal.desReached = courseAndDistance(geo.aircraft_position(), fmgc.flightPlanController.todPoint)[1] < 0.1;
			# todo: check altitude/distance as well
		}
	} else {
		fmgc.FMGCInternal.clbSet = 0;
		fmgc.FMGCInternal.desSet = 0;
	}
	
	# calculate efob values
	for (var i = 0; i <= 2; i += 1) {
		if (fmgc.flightPlanController.getPlanSizeNoDiscont(i) <= 1) {
			continue;
		}
		efob_values[i] = [];
		time_values[i] = [];
		var _distance = 0;
		var _clb_distance = 0;
		var _crz_distance = 0;
		var _des_distance = 0;
		for (var wpt = 0; wpt < fmgc.flightPlanController.arrivalIndex[i]; wpt += 1) {
			if (fmgc.FMGCInternal.fuelCalculating) {
				append(efob_values[i], nil);
				append(time_values[i], nil);
				continue;
			}
			_distance += fmgc.flightPlanController.flightplans[i].getWP(wpt).leg_distance;
			var _wp = fmgc.flightPlanController.flightplans[i].getWP(wpt);
			if (wpt < fmgc.flightPlanController.getIndexOfTOC(i)) {
				_clb_distance += fmgc.flightPlanController.flightplans[i].getWP(wpt).leg_distance;
				var _multiplier = _clb_distance / fmgc.FMGCInternal.clbDist;
				append(efob_values[i], fmgc.FMGCInternal.block - fmgc.FMGCInternal.taxiFuel - _multiplier * fmgc.FMGCInternal.clbFuel / 1000);
				if (num(_multiplier * fmgc.FMGCInternal.clbTime_num) >= 60) {
					clb_min = int(math.mod(_multiplier * fmgc.FMGCInternal.clbTime_num, 60));
					clb_hour = int((_multiplier * fmgc.FMGCInternal.clbTime_num - clb_min) / 60);
					append(time_values[i], sprintf("%02d", clb_hour) ~ sprintf("%02d", clb_min));
				} else {
					append(time_values[i], sprintf("%04d", _multiplier * fmgc.FMGCInternal.clbTime_num));
				}
				var _altitude = _multiplier * fmgc.FMGCInternal.crzFt;
				if (_wp.alt_cstr == nil or _wp.alt_cstr == 0 or _wp.alt_cstr_type == "computed") {
					_wp.setAltitude(_altitude, "computed");
				}
				if (_wp.speed_cstr == nil or _wp.speed_cstr == 0 or _wp.speed_cstr_type == "computed" or _wp.speed_cstr_type == "computed-mach") {
					if (_altitude >= getprop("/FMGC/internal/accel-agl-ft") and _altitude < 10000) {
						_wp.setSpeed(250, "computed");
					}
					# to-do: add other conditions
				}
			} else if (wpt >= fmgc.flightPlanController.getIndexOfTOC(i) and wpt <= fmgc.flightPlanController.getIndexOfTOD(i)) {
				if (wpt != fmgc.flightPlanController.getIndexOfTOC(i)) {
					_crz_distance += fmgc.flightPlanController.flightplans[i].getWP(wpt).leg_distance;
				}
				var _multiplier = _crz_distance / (fmgc.flightPlanController.totalDist.getValue() - fmgc.FMGCInternal.clbDist - fmgc.FMGCInternal.desDist);
				append(efob_values[i], fmgc.FMGCInternal.block - fmgc.FMGCInternal.taxiFuel - fmgc.FMGCInternal.clbFuel / 1000 - _multiplier * (fmgc.FMGCInternal.tripFuel - fmgc.FMGCInternal.clbFuel / 1000 - fmgc.FMGCInternal.desFuel / 1000));
				_desTime = _multiplier * (fmgc.FMGCInternal.tripTime_num - fmgc.FMGCInternal.desTime_num - fmgc.FMGCInternal.clbTime_num) + fmgc.FMGCInternal.clbTime_num;
				if (num(_desTime) >= 60) {
					des_min = int(math.mod(_desTime, 60));
					des_hour = int((_desTime - des_min) / 60);
					append(time_values[i], sprintf("%02d", des_hour) ~ sprintf("%02d", des_min));
				} else {
					append(time_values[i], sprintf("%04d", _desTime));
				}
				if (_wp.alt_cstr == nil or _wp.alt_cstr == 0 or _wp.alt_cstr_type == "computed") {
					_wp.setAltitude(fmgc.FMGCInternal.crzFt, "computed");
				}
				# if (_wp.speed_cstr == nil or _wp.speed_cstr == 0 or _wp.speed_cstr_type == "computed" or _wp.speed_cstr_type == "computed-mach") {
# 					
# 				}
			} else if (wpt > fmgc.flightPlanController.getIndexOfTOD(i) and wpt < fmgc.flightPlanController.arrivalIndex[i]) {
				_des_distance += fmgc.flightPlanController.flightplans[i].getWP(wpt).leg_distance;
				var _multiplier = _des_distance / fmgc.FMGCInternal.desDist;
				append(efob_values[i], fmgc.FMGCInternal.block - fmgc.FMGCInternal.taxiFuel - fmgc.FMGCInternal.tripFuel + fmgc.FMGCInternal.desFuel / 1000 - _multiplier * fmgc.FMGCInternal.desFuel / 1000);
				_desTime = _multiplier * fmgc.FMGCInternal.desTime_num + fmgc.FMGCInternal.tripTime_num - fmgc.FMGCInternal.desTime_num;
				if (num(_desTime) >= 60) {
					des_min = int(math.mod(_desTime, 60));
					des_hour = int((_desTime - des_min) / 60);
					append(time_values[i], sprintf("%02d", des_hour) ~ sprintf("%02d", des_min));
				} else {
					append(time_values[i], sprintf("%04d", _desTime));
				}
				var _altitude = (1 - _multiplier) * fmgc.FMGCInternal.crzFt;
				if (_wp.alt_cstr == nil or _wp.alt_cstr == 0 or _wp.alt_cstr_type == "computed") {
					_wp.setAltitude(_altitude, "computed");
				}
				if (_wp.speed_cstr == nil or _wp.speed_cstr == 0 or _wp.speed_cstr_type == "computed" or _wp.speed_cstr_type == "computed-mach") {
					if (_altitude >= getprop("/systems/thrust/clbreduc-ft") and _altitude < 10000) {
						if (wpt <= fmgc.flightPlanController.getIndexOfFirstDecel(i)) {
							if (fmgc.FMGCInternal.clean > 0) {
								_wp.setSpeed(250, "computed");
							}
						} else {
							_wp.setSpeed(fmgc.FMGCInternal.clean, "computed"); # to-do: expand this caluclation
						}
					}
					# to-do: add other conditions
				}
			# to do: equal to toc and tod
			} else if (wpt == fmgc.flightPlanController.arrivalIndex[i]) {
				#_wp.setAltitude(nil, "computed");
				if (FMGCInternal.vapp_appr > 0) {
					_wp.setSpeed(FMGCInternal.vapp_appr, "computed");
				}
			} else {
				append(efob_values[i], nil);
				append(time_values[i], nil);
			}
		}
	}
}