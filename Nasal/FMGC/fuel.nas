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
		crz = fmgc.FMGCInternal.crzFl;
		temp = fmgc.FMGCInternal.crzTemp - 15 + (2 * crz / 10); # crz temp minus ISA
		tow = fmgc.FMGCInternal.tow;
		todw = fmgc.FMGCInternal.tow - fmgc.FMGCInternal.taxiFuel - fmgc.FMGCInternal.tripFuel;
		
		fmgc.FMGCInternal.clbFuel = 1.421139e-02 + (crz*3.236393e+03) + (crz*crz*1.120007e+00) + (crz*crz*crz*-2.722871e-03) + (crz*crz*crz*crz*7.256755e-06) + (crz*crz*crz*crz*crz*-1.612218e-08) + (crz*crz*crz*crz*crz*crz*1.326596e-11) + (tow*-2.096727e+03) + (crz*tow*-1.174940e+02) + (crz*crz*tow*-2.446904e-02) + (crz*crz*crz*tow*2.697128e-05) + (crz*crz*crz*crz*tow*2.964427e-10) + (crz*crz*crz*crz*crz*tow*5.392939e-13) + (tow*tow*7.508311e+01) + (crz*tow*tow*1.691499e+00) + (crz*crz*tow*tow*2.260348e-04) + (crz*crz*crz*tow*tow*-2.122250e-07) + (crz*crz*crz*crz*tow*tow*9.535209e-12) + (tow*tow*tow*-1.068184e+00) + (crz*tow*tow*tow*-1.208297e-02) + (crz*crz*tow*tow*tow*-8.634399e-07) + (crz*crz*crz*tow*tow*tow*5.221886e-10) + (tow*tow*tow*tow*7.556674e-03) + (crz*tow*tow*tow*tow*4.283091e-05) + (crz*crz*tow*tow*tow*tow*1.127184e-09) + (tow*tow*tow*tow*tow*-2.658266e-05) + (crz*tow*tow*tow*tow*tow*-6.025789e-08) + (tow*tow*tow*tow*tow*tow*3.720043e-08) + (temp*-2.910550e+04) + (crz*temp*1.285581e+01) + (crz*crz*temp*-1.272942e-02) + (crz*crz*crz*temp*-3.925488e-06) + (crz*crz*crz*crz*temp*4.165313e-08) + (crz*crz*crz*crz*crz*temp*-1.131495e-11) + (tow*temp*1.039383e+03) + (crz*tow*temp*-3.514567e-01) + (crz*crz*tow*temp*3.116650e-04) + (crz*crz*crz*tow*temp*-2.045133e-07) + (crz*crz*crz*crz*tow*temp*-2.171672e-10) + (tow*tow*temp*-1.474017e+01) + (crz*tow*tow*temp*3.469855e-03) + (crz*crz*tow*tow*temp*-2.021211e-06) + (crz*crz*crz*tow*tow*temp*1.475405e-09) + (tow*tow*tow*temp*1.038394e-01) + (crz*tow*tow*tow*temp*-1.486194e-05) + (crz*crz*tow*tow*tow*temp*3.292894e-09) + (tow*tow*tow*tow*temp*-3.635322e-04) + (crz*tow*tow*tow*tow*temp*2.370644e-08) + (tow*tow*tow*tow*tow*temp*5.061256e-07) + (temp*temp*-6.049159e+00) + (crz*temp*temp*9.271569e-03) + (crz*crz*temp*temp*-4.787863e-05) + (crz*crz*crz*temp*temp*1.544306e-07) + (crz*crz*crz*crz*temp*temp*-1.189408e-10) + (tow*temp*temp*1.618150e-01) + (crz*tow*temp*temp*-1.244027e-04) + (crz*crz*tow*temp*temp*1.847018e-07) + (crz*crz*crz*tow*temp*temp*-5.084243e-10) + (tow*tow*temp*temp*-1.634968e-03) + (crz*tow*tow*temp*temp*7.582337e-07) + (crz*crz*tow*tow*temp*temp*2.039694e-10) + (tow*tow*tow*temp*temp*7.357701e-06) + (crz*tow*tow*tow*temp*temp*-1.997496e-09) + (tow*tow*tow*tow*temp*temp*-1.238556e-08) + (temp*temp*temp*-1.556897e+00) + (crz*temp*temp*temp*3.820685e-03) + (crz*crz*temp*temp*temp*-1.536057e-06) + (crz*crz*crz*temp*temp*temp*4.479777e-10) + (tow*temp*temp*temp*2.904938e-02) + (crz*tow*temp*temp*temp*-4.732752e-05) + (crz*crz*tow*temp*temp*temp*1.881360e-08) + (tow*tow*temp*temp*temp*-1.862818e-04) + (crz*tow*tow*temp*temp*temp*1.615777e-07) + (tow*tow*tow*temp*temp*temp*4.064634e-07) + (temp*temp*temp*temp*7.111483e-04) + (crz*temp*temp*temp*temp*4.605684e-07) + (crz*crz*temp*temp*temp*temp*-2.085822e-09) + (tow*temp*temp*temp*temp*-1.033525e-05) + (crz*tow*temp*temp*temp*temp*1.427061e-09) + (tow*tow*temp*temp*temp*temp*3.527457e-08) + (temp*temp*temp*temp*temp*2.890019e-04) + (crz*temp*temp*temp*temp*temp*-9.768280e-07) + (tow*temp*temp*temp*temp*temp*-1.589498e-06) + (temp*temp*temp*temp*temp*temp*-2.382194e-09);
		fmgc.FMGCInternal.clbTime_num = 8.546574e-05 + (crz*-1.218477e+00) + (crz*crz*-7.124805e-03) + (crz*crz*crz*-6.089542e-06) + (crz*crz*crz*crz*6.577291e-08) + (crz*crz*crz*crz*crz*-1.518018e-10) + (crz*crz*crz*crz*crz*crz*1.197574e-13) + (tow*1.424043e+01) + (crz*tow*5.830025e-02) + (crz*crz*tow*1.989222e-04) + (crz*crz*crz*tow*-1.371607e-07) + (crz*crz*crz*crz*tow*5.306187e-12) + (crz*crz*crz*crz*crz*tow*8.582371e-14) + (tow*tow*-5.053610e-01) + (crz*tow*tow*-9.894229e-04) + (crz*crz*tow*tow*-1.722098e-06) + (crz*crz*crz*tow*tow*7.331638e-10) + (crz*crz*crz*crz*tow*tow*-1.696028e-13) + (tow*tow*tow*7.100580e-03) + (crz*tow*tow*tow*7.726864e-06) + (crz*crz*tow*tow*tow*6.781362e-09) + (crz*crz*crz*tow*tow*tow*-1.012461e-12) + (tow*tow*tow*tow*-4.937929e-05) + (crz*tow*tow*tow*tow*-2.876036e-08) + (crz*crz*tow*tow*tow*tow*-1.054797e-11) + (tow*tow*tow*tow*tow*1.701731e-07) + (crz*tow*tow*tow*tow*tow*4.180070e-11) + (tow*tow*tow*tow*tow*tow*-2.327957e-10) + (temp*-1.487934e+02) + (crz*temp*1.635853e-01) + (crz*crz*temp*-6.533805e-05) + (crz*crz*crz*temp*-8.593744e-08) + (crz*crz*crz*crz*temp*1.929578e-10) + (crz*crz*crz*crz*crz*temp*-9.294195e-14) + (tow*temp*5.055150e+00) + (crz*tow*temp*-4.650570e-03) + (crz*crz*tow*temp*2.197799e-06) + (crz*crz*crz*tow*temp*-1.790411e-10) + (crz*crz*crz*crz*tow*temp*-6.980202e-13) + (tow*tow*temp*-6.816110e-02) + (crz*tow*tow*temp*4.759886e-05) + (crz*crz*tow*tow*temp*-1.775598e-08) + (crz*crz*crz*tow*tow*temp*3.773141e-12) + (tow*tow*tow*temp*4.566271e-04) + (crz*tow*tow*tow*temp*-2.104527e-07) + (crz*crz*tow*tow*tow*temp*4.057553e-11) + (tow*tow*tow*tow*temp*-1.521686e-06) + (crz*tow*tow*tow*tow*temp*3.424056e-10) + (tow*tow*tow*tow*tow*temp*2.019730e-09) + (temp*temp*-4.691397e-02) + (crz*temp*temp*-4.589895e-05) + (crz*crz*temp*temp*-3.063260e-08) + (crz*crz*crz*temp*temp*7.825434e-10) + (crz*crz*crz*crz*temp*temp*-7.469565e-13) + (tow*temp*temp*1.369177e-03) + (crz*tow*temp*temp*7.097826e-07) + (crz*crz*tow*temp*temp*-2.011447e-09) + (crz*crz*crz*tow*temp*temp*-1.785053e-12) + (tow*tow*temp*temp*-1.444385e-05) + (crz*tow*tow*temp*temp*-2.111174e-09) + (crz*crz*tow*tow*temp*temp*1.004928e-11) + (tow*tow*tow*temp*temp*6.632896e-08) + (crz*tow*tow*tow*temp*temp*-2.408713e-12) + (tow*tow*tow*tow*temp*temp*-1.129910e-10) + (temp*temp*temp*-1.581872e-04) + (crz*temp*temp*temp*2.438163e-05) + (crz*crz*temp*temp*temp*-5.665674e-08) + (crz*crz*crz*temp*temp*temp*3.737388e-11) + (tow*temp*temp*temp*-1.353915e-05) + (crz*tow*temp*temp*temp*-2.243763e-07) + (crz*crz*tow*temp*temp*temp*3.526936e-10) + (tow*tow*temp*temp*temp*1.368333e-07) + (crz*tow*tow*temp*temp*temp*5.825907e-10) + (tow*tow*tow*temp*temp*temp*-3.081415e-10) + (temp*temp*temp*temp*-6.442379e-07) + (crz*temp*temp*temp*temp*3.243133e-08) + (crz*crz*temp*temp*temp*temp*-2.379161e-11) + (tow*temp*temp*temp*temp*-2.815596e-08) + (crz*tow*temp*temp*temp*temp*-1.459261e-10) + (tow*tow*temp*temp*temp*temp*2.232566e-10) + (temp*temp*temp*temp*temp*1.805413e-06) + (crz*temp*temp*temp*temp*temp*-6.375023e-09) + (tow*temp*temp*temp*temp*temp*-9.569016e-09) + (temp*temp*temp*temp*temp*temp*-2.201936e-09);
		if (num(fmgc.FMGCInternal.clbTime_num) >= 60) {
			clb_min = int(math.mod(fmgc.FMGCInternal.clbTime_num, 60));
			clb_hour = int((fmgc.FMGCInternal.clbTime_num - clb_min) / 60);
			fmgc.FMGCInternal.clbTime = sprintf("%02d", clb_hour) ~ sprintf("%02d", clb_min);
		} else {
			fmgc.FMGCInternal.clbTime = sprintf("%04d", fmgc.FMGCInternal.clbTime_num);
		}
		fmgc.FMGCInternal.clbDist = 2.733214e-04 + (crz*3.303628e+00) + (crz*crz*-1.942714e-02) + (crz*crz*crz*3.719504e-05) + (crz*crz*crz*crz*-4.153478e-08) + (crz*crz*crz*crz*crz*2.118945e-11) + (tow*-1.277802e+00) + (crz*tow*-6.338520e-02) + (crz*crz*tow*3.244369e-04) + (crz*crz*crz*tow*-3.700204e-07) + (crz*crz*crz*crz*tow*1.697370e-10) + (tow*tow*2.890675e-02) + (crz*tow*tow*4.198539e-04) + (crz*crz*tow*tow*-1.821915e-06) + (crz*crz*crz*tow*tow*1.095987e-09) + (tow*tow*tow*-2.314586e-04) + (crz*tow*tow*tow*-9.470935e-07) + (crz*crz*tow*tow*tow*3.354832e-09) + (tow*tow*tow*tow*7.589140e-07) + (crz*tow*tow*tow*tow*2.129195e-10) + (tow*tow*tow*tow*tow*-8.001809e-10) + (temp*-1.096860e+01) + (crz*temp*-3.051487e-02) + (crz*crz*temp*2.127747e-04) + (crz*crz*crz*temp*-2.752134e-07) + (crz*crz*crz*crz*temp*8.427234e-12) + (tow*temp*2.462013e-01) + (crz*tow*temp*7.342185e-04) + (crz*crz*tow*temp*-3.056328e-06) + (crz*crz*crz*tow*temp*2.538470e-09) + (tow*tow*temp*-2.454924e-03) + (crz*tow*tow*temp*-3.906183e-06) + (crz*crz*tow*tow*temp*8.289368e-09) + (tow*tow*tow*temp*1.162654e-05) + (crz*tow*tow*tow*temp*4.965479e-09) + (tow*tow*tow*tow*temp*-2.073121e-08) + (temp*temp*8.503371e-02) + (crz*temp*temp*-6.834545e-06) + (crz*crz*temp*temp*7.685558e-07) + (crz*crz*crz*temp*temp*-9.135024e-10) + (tow*temp*temp*-1.854582e-03) + (crz*tow*temp*temp*-1.463171e-06) + (crz*crz*tow*temp*temp*-2.181700e-09) + (tow*tow*temp*temp*1.398180e-05) + (crz*tow*tow*temp*temp*7.379637e-09) + (tow*tow*tow*temp*temp*-3.535769e-08) + (temp*temp*temp*1.778024e-02) + (crz*temp*temp*temp*-8.594420e-05) + (crz*crz*temp*temp*temp*1.157695e-07) + (tow*temp*temp*temp*-1.399377e-04) + (crz*tow*temp*temp*temp*4.666109e-07) + (tow*tow*temp*temp*temp*3.167345e-07) + (temp*temp*temp*temp*-5.172935e-06) + (crz*temp*temp*temp*temp*6.003772e-09) + (tow*temp*temp*temp*temp*2.994848e-08) + (temp*temp*temp*temp*temp*-6.608905e-06);
		fmgc.FMGCInternal.clbSet = 1;
		
		fmgc.FMGCInternal.desFuel = -6.544e+01 + (crz*2.427e+00) + (crz*crz*-7.732e-03) + (crz*crz*crz*-2.756e-05) + (crz*crz*crz*crz*1.085e-07) + (todw*5.009e-01) + (crz*todw*-1.871e-02) + (crz*crz*todw*2.019e-04) + (crz*crz*crz*todw*-4.272e-07) + (todw*todw*2.059e-09) + (crz*todw*todw*2.167e-13) + (crz*crz*todw*todw*-6.990e-16) + (todw*todw*todw*-1.090e-11) + (crz*todw*todw*todw*1.988e-16) + (todw*todw*todw*todw*2.136e-14);
		fmgc.FMGCInternal.desTime_num = -1.656 + (crz*7.375e-02) + (crz*crz*-3.196e-04) + (crz*crz*crz*1.553e-07) + (crz*crz*crz*crz*1.050e-09) + (todw*5.111e-03) + (crz*todw*-8.082e-05) + (crz*crz*todw*2.831e-06) + (crz*crz*crz*todw*-6.160e-09) + (todw*todw*1.149e-10) + (crz*todw*todw*4.051e-14) + (crz*crz*todw*todw*-1.102e-17) + (todw*todw*todw*-6.286e-13) + (crz*todw*todw*todw*-9.381e-17) + (todw*todw*todw*todw*1.279e-15);
		if (num(fmgc.FMGCInternal.desTime_num) >= 60) {
			des_min = int(math.mod(fmgc.FMGCInternal.desTime_num, 60));
			des_hour = int((fmgc.FMGCInternal.desTime_num - des_min) / 60);
			fmgc.FMGCInternal.desTime = sprintf("%02d", des_hour) ~ sprintf("%02d", des_min);
		} else {
			fmgc.FMGCInternal.desTime = sprintf("%04d", fmgc.FMGCInternal.desTime_num);
		}
		fmgc.FMGCInternal.desDist = -1.064e+01 + (crz*4.264e-01) + (crz*crz*-1.832e-03) + (crz*crz*crz*-2.981e-08) + (crz*crz*crz*crz*8.901e-09) + (todw*5.939e-02) + (crz*todw*-1.871e-03) + (crz*crz*todw*2.544e-05) + (crz*crz*crz*todw*-5.090e-08) + (todw*todw*6.264e-10) + (crz*todw*todw*2.420e-13) + (crz*crz*todw*todw*-6.709e-17) + (todw*todw*todw*-3.436e-12) + (crz*todw*todw*todw*-5.591e-16) + (todw*todw*todw*todw*7.009e-15);
		fmgc.FMGCInternal.desSet = 1;
		
		# update reached states
		if (fmgc.flightPlanController.tocPoint != nil and !fmgc.FMGCInternal.clbReached) {
			fmgc.FMGCInternal.clbReached = courseAndDistance(geo.aircraft_position(), fmgc.flightPlanController.tocPoint)[1] < 0.1;
			# todo: check altitude/distance as well
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
				var _multiplier = _crz_distance / (fmgc.flightPlanController.arrivalDist.getValue() - fmgc.FMGCInternal.clbDist - fmgc.FMGCInternal.desDist);
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