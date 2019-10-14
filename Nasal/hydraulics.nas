# A3XX Hydraulic System
# Joshua Davidson (Octal450)

# Copyright (c) 2019 Joshua Davidson (Octal450)

var eng1_pump_sw = 0;
var eng2_pump_sw = 0;
var elec_pump_blue_sw = 0;
var elec_pump_yellow_sw = 0;
var yellow_hand_pump = 0;
var ptu_sw = 0;
var blue_psi = 0;
var green_psi = 0;
var yellow_psi = 0;
var rpmapu = 0;
var stateL = 0;
var stateR = 0;
var dc_ess = 0;
var psi_diff = 0;
var rat = 0;
var gs = 0;
var blue_leak = 0;
var green_leak = 0;
var yellow_leak = 0;
var blue_pump_fail = 0;
var green_pump_fail = 0;
var yellow_pump_eng_fail = 0;
var yellow_pump_elec_fail = 0;
var ptu_fail = 0;
var dc2 = 0;
var ptu_active = 0;
var accum = 0;
var lpsi = 0;
var rpsi = 0;
var parking = 0;
var askidnws_sw = 0;
var brake_mode = 0;
var brake_l = 0;
var brake_r = 0;
var brake_nose = 0;
var counter = 0;
var down = 0;

var HYD = {
	init: func() {
		setprop("/controls/hydraulic/eng1-pump", 1);
		setprop("/controls/hydraulic/eng2-pump", 1);
		setprop("/controls/hydraulic/elec-pump-blue", 1);
		setprop("/controls/hydraulic/elec-pump-yellow", 0);
		setprop("/controls/hydraulic/hand-pump-yellow", 0);
		setprop("/controls/hydraulic/ptu", 1);
		setprop("/systems/hydraulic/ptu-active", 0);
		setprop("/systems/hydraulic/blue-psi", 0);
		setprop("/systems/hydraulic/green-psi", 0);
		setprop("/systems/hydraulic/yellow-psi", 0);
		setprop("/controls/gear/brake-parking", 0);
		setprop("/systems/hydraulic/brakes/accumulator-pressure-psi", 0);
		setprop("/systems/hydraulic/brakes/pressure-left-psi", 0);
		setprop("/systems/hydraulic/brakes/pressure-right-psi", 0);
		setprop("/systems/hydraulic/brakes/askidnwssw", 1);
		setprop("/systems/hydraulic/brakes/mode", 0);
		setprop("/systems/hydraulic/brakes/lbrake", 0);
		setprop("/systems/hydraulic/brakes/rbrake", 0);
		setprop("/systems/hydraulic/brakes/nose-rubber", 0);
		setprop("/systems/hydraulic/brakes/counter", 0);
		setprop("/systems/hydraulic/brakes/accumulator-pressure-psi-1", 0);
		setprop("/systems/hydraulic/eng1-pump-fault", 0);
		setprop("/systems/hydraulic/eng2-pump-fault", 0);
		setprop("/systems/hydraulic/elec-pump-b-fault", 0);
		setprop("/systems/hydraulic/elec-pump-y-fault", 0);
		setprop("/systems/hydraulic/ptu-fault", 0);
		setprop("/systems/hydraulic/ptu-supplies", "XX");
		setprop("/systems/hydraulic/yellow-resv-lo-air-press", 0);
		setprop("/systems/hydraulic/blue-resv-lo-air-press", 0);
		setprop("/systems/hydraulic/green-resv-lo-air-press", 0);
		setprop("/systems/hydraulic/yellow-resv-ovht", 0);
		setprop("/systems/hydraulic/blue-resv-ovht", 0);
		setprop("/systems/hydraulic/green-resv-ovht", 0);
		setprop("/systems/hydraulic/elec-pump-yellow-ovht", 0);
		setprop("/systems/hydraulic/elec-pump-blue-ovht", 0);
		setprop("/systems/hydraulic/yellow-fire-valve", 0);
		setprop("/systems/hydraulic/green-fire-valve", 0);
	},
	loop: func() {
		eng1_pump_sw = getprop("/controls/hydraulic/eng1-pump");
		eng2_pump_sw = getprop("/controls/hydraulic/eng2-pump");
		elec_pump_blue_sw = getprop("/controls/hydraulic/elec-pump-blue");
		elec_pump_yellow_sw = getprop("/controls/hydraulic/elec-pump-yellow");
		yellow_hand_pump = getprop("/controls/hydraulic/hand-pump-yellow");
		ptu_sw = getprop("/controls/hydraulic/ptu");
		blue_psi = getprop("/systems/hydraulic/blue-psi");
		green_psi = getprop("/systems/hydraulic/green-psi");
		yellow_psi = getprop("/systems/hydraulic/yellow-psi");
		rpmapu = getprop("/systems/apu/rpm");
		stateL = getprop("/engines/engine[0]/state");
		stateR = getprop("/engines/engine[1]/state");
		dc_ess = getprop("/systems/electrical/bus/dc-ess");
		psi_diff = green_psi - yellow_psi;
		rat = getprop("/systems/hydraulic/rat-position");
		gs = getprop("/velocities/groundspeed-kt");
		blue_leak = getprop("/systems/failures/hyd-blue");
		green_leak = getprop("/systems/failures/hyd-green");
		yellow_leak = getprop("/systems/failures/hyd-yellow");
		blue_pump_fail = getprop("/systems/failures/pump-blue");
		green_pump_fail = getprop("/systems/failures/pump-green");
		yellow_pump_eng_fail = getprop("/systems/failures/pump-yellow-eng");
		yellow_pump_elec_fail = getprop("/systems/failures/pump-yellow-elec");
		ptu_fail = getprop("/systems/failures/ptu");
		dc2 = getprop("/systems/electrical/bus/dc-2");
		
		if ((psi_diff > 500 or psi_diff < -500) and ptu_sw and dc2 > 25) {
			setprop("/systems/hydraulic/ptu-active", 1);
		} else if (psi_diff < 20 and psi_diff > -20) {
			setprop("/systems/hydraulic/ptu-active", 0);
		}

		ptu_active = getprop("/systems/hydraulic/ptu-active");
		
		if (elec_pump_blue_sw and dc_ess >= 25 and !blue_pump_fail and (stateL == 3 or stateR == 3 or getprop("/gear/gear[0]/wow") == 0) and !blue_leak) {
			if (blue_psi < 2900) {
				setprop("/systems/hydraulic/blue-psi", blue_psi + 50);
			} else {
				setprop("/systems/hydraulic/blue-psi", 3000);
			}
		} else if (gs >= 50 and (rat == 1) and !blue_leak) {
			if (blue_psi < 2400) {
				setprop("/systems/hydraulic/blue-psi", blue_psi + 50);
			} else {
				setprop("/systems/hydraulic/blue-psi", 2500);
			}
		} else {
			if (blue_psi > 1) {
				setprop("/systems/hydraulic/blue-psi", blue_psi - 25);
			} else {
				setprop("/systems/hydraulic/blue-psi", 0);
			}
		}
		
		if (eng1_pump_sw and stateL == 3 and !green_pump_fail and !green_leak) {
			if (green_psi < 2900) {
				setprop("/systems/hydraulic/green-psi", green_psi + 50);
			} else {
				setprop("/systems/hydraulic/green-psi", 3000);
			}
		} else if (ptu_active and !ptu_fail and yellow_psi >= 1500 and !green_leak) {
			if (green_psi < 2900) {
				setprop("/systems/hydraulic/green-psi", green_psi + 50);
			} else {
				setprop("/systems/hydraulic/green-psi", 3000);
			}
		} else {
			if (green_psi > 1) {
				setprop("/systems/hydraulic/green-psi", green_psi - 25);
			} else {
				setprop("/systems/hydraulic/green-psi", 0);
			}
		}
		
		if (eng2_pump_sw and stateR == 3 and !yellow_pump_eng_fail and !yellow_leak) {
			if (yellow_psi < 2900) {
				setprop("/systems/hydraulic/yellow-psi", yellow_psi + 50);
			} else {
				setprop("/systems/hydraulic/yellow-psi", 3000);
			}
		} else if (elec_pump_yellow_sw and dc_ess >= 25 and !yellow_pump_elec_fail and !yellow_leak) {
			if (yellow_psi < 2900) {
				setprop("/systems/hydraulic/yellow-psi", yellow_psi + 50);
			} else {
				setprop("/systems/hydraulic/yellow-psi", 3000);
			}
		} else if (ptu_active and !ptu_fail and green_psi >= 1500 and !yellow_leak) {
			if (yellow_psi < 2900) {
				setprop("/systems/hydraulic/yellow-psi", yellow_psi + 50);
			} else {
				setprop("/systems/hydraulic/yellow-psi", 3000);
			}
		} else if (yellow_hand_pump and !yellow_leak and (getprop("/gear/gear[0]/wow") or getprop("/gear/gear[1]/wow") or getprop("/gear/gear[2]/wow"))) {
			if (yellow_psi < 2900) {
				setprop("/systems/hydraulic/yellow-psi", yellow_psi + 25);
			} else {
				setprop("/systems/hydraulic/yellow-psi", 3000);
			}
		} else {
			if (yellow_psi > 1) {
				setprop("/systems/hydraulic/yellow-psi", yellow_psi - 25);
			} else {
				setprop("/systems/hydraulic/yellow-psi", 0);
			}
		}
		
		accum = getprop("/systems/hydraulic/brakes/accumulator-pressure-psi");
		lpsi = getprop("/systems/hydraulic/brakes/pressure-left-psi");
		rpsi = getprop("/systems/hydraulic/brakes/pressure-right-psi");
		parking = getprop("/controls/gear/brake-parking");
		askidnws_sw = getprop("/systems/hydraulic/brakes/askidnwssw");
		brake_mode = getprop("/systems/hydraulic/brakes/mode");
		brake_l = getprop("/systems/hydraulic/brakes/lbrake");
		brake_r = getprop("/systems/hydraulic/brakes/rbrake");
		brake_nose = getprop("/systems/hydraulic/brakes/nose-rubber");
		counter = getprop("/systems/hydraulic/brakes/counter");
		
		if (!parking and askidnws_sw and green_psi > 2500) {
			# set mode to on
			setprop("/systems/hydraulic/brakes/mode", 1); 
		} else if ((!parking and askidnws_sw and yellow_psi > 2500) or (!parking and askidnws_sw and accum > 0)) {
			# set mode to altn
			setprop("/systems/hydraulic/brakes/mode", 2); 
		} else {
			# set mode to off
			setprop("/systems/hydraulic/brakes/mode", 0);
		}
		
		if (brake_mode == 2 and yellow_psi > 2500 and accum < 700) {
			setprop("/systems/hydraulic/brakes/accumulator-pressure-psi", accum + 50);
		}
		
		# Fault lights
		if (green_pump_fail and eng1_pump_sw) {
			setprop("/systems/hydraulic/eng1-pump-fault", 1);
		} else {
			setprop("/systems/hydraulic/eng1-pump-fault", 0);
		}
		
		if (blue_pump_fail and elec_pump_blue_sw) {
			setprop("/systems/hydraulic/elec-pump-b-fault", 1);
		} else {
			setprop("/systems/hydraulic/elec-pump-b-fault", 0);
		}
		
		if (ptu_fail and ptu_sw) {
			setprop("/systems/hydraulic/ptu-fault", 1);
		} else {
			setprop("/systems/hydraulic/ptu-fault", 0);
		}
		
		if (yellow_pump_eng_fail and eng2_pump_sw) {
			setprop("/systems/hydraulic/eng2-pump-fault", 1);
		} else {
			setprop("/systems/hydraulic/eng2-pump-fault", 0);
		}
		
		if (yellow_pump_elec_fail and elec_pump_yellow_sw) {
			setprop("/systems/hydraulic/elec-pump-y-fault", 1);
		} else {
			setprop("/systems/hydraulic/elec-pump-y-fault", 0);
		}
	},
};

setlistener("/controls/gear/gear-down", func {
	down = getprop("/controls/gear/gear-down");
	if (!down and (getprop("/gear/gear[0]/wow") or getprop("/gear/gear[1]/wow") or getprop("/gear/gear[2]/wow"))) {
		setprop("/controls/gear/gear-down", 1);
	}
});
