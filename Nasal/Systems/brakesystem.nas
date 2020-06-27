##########################################################################
# Simple Brake Simulation System
# 2010, Thorsten Brehm
#
# Simple simulation of brake energy absorption and cooling effects.
#
# This module computes (approximates... :-) ) an energy level which
# (faintly) resembles the kinetic energy absorption and cooling effects
# of a brake system. But instead of computing real temperatures, this
# is just meant to distinguish normal energy levels from exceptionally
# high levels. The target is to drive EICAS "brakes overheat" messages
# and gear effects only, to "reward" pilots with exceptionally bad
# landings...		
#
# To avoid complicated calculations of different braking effects (roll/air
# drag, reverse thrust etc), we simply assume the brake system to cause a
# fixed deceleration (me.BrakeDecel). With this deceleration we approximate
# the speed difference which would be caused by the brake system alone for
# any given simulation interval. The difference of the kinetic energy level
# at the current speed and the decelerated speed are then added up to the
# total absorbed brake energy.
# Units (knots/lbs/Kg) do not matter much here. Eventually a magic scaling
# divisor is used to scale the output level. Any output > 1 means
# "overheated brakes", any level <=1 means "brake temperature OK".
# No exact science here - but good enough for now :-).
##########################################################################
#
# Added brakes temp calculations and adapted for A320-family
# 2020, Andrea Vezzali
#
##########################################################################
var BrakeSystem =
{
	new : func()
	{
	   var m = { parents : [BrakeSystem]};
	   # deceleration caused by brakes alone (knots/s2)
	   m.BrakeDecel	   = 1.0; # kt/s^2
	   # Higher value means quicker cooling
	   m.CoolingFactor = 0.000125;
	   # Scaling divisor. Use this to scale the energy output.
	   # Manually tune this value: a total energy output
	   # at "/gear/brake-thermal-energy" > 1.0 means overheated brakes,
	   # anything below <= 1.0 means energy absorbed by brakes is OK. 
	   #m.ScalingDivisor= 700000*450.0;

	   m.ScalingDivisor = 0.000000006;
	   
	   m.LSmokeActive	= 0;
	   m.LSmokeToggle	= 0;
	   m.RSmokeActive	= 0;
	   m.RSmokeToggle	= 0;
#		m.LnCoolFactor	 = math.ln(1-m.CoolingFactor);

	   m.reset();

	   return m;
	},

	reset : func()
	{
		# Initial thermal energy
		setprop("gear/gear[1]/Lbrake-thermal-energy",0.0);
		setprop("gear/gear[2]/Rbrake-thermal-energy",0.0);

		setprop("controls/gear/brake-fans",0);
		setprop("gear/gear[1]/Lbrake-smoke",0);
		setprop("gear/gear[2]/Rbrake-smoke",0);
		setprop("gear/gear[1]/L-Thrust",0);
		setprop("gear/gear[2]/R-Thrust",0);

		#Introducing a random error on temp sensors (max 5°C)
		setprop("gear/gear[1]/L1error-temp-degc", math.round(rand()*(5)));
		setprop("gear/gear[1]/L2error-temp-degc", math.round(rand()*(5)));
		setprop("gear/gear[2]/R3error-temp-degc", math.round(rand()*(5)));
		setprop("gear/gear[2]/R4error-temp-degc", math.round(rand()*(5)));		  

		#var atemp  =  getprop("environment/temperature-degc") or 0;
		#var vmach  =  getprop("velocities/mach") or 0;
		var tatdegc = getprop("/systems/navigation/probes/tat-1/compute-tat") or 0;
		var atemp  =  getprop("environment/temperature-degc") or 0;
		var vmach  =  getprop("velocities/mach") or 0;
		var tatdegc = getprop("systems/navigation/probes/tat-1/compute-tat");

		setprop("gear/gear[1]/L1brake-temp-degc",tatdegc+getprop("gear/gear[1]/L1error-temp-degc"));
		setprop("gear/gear[1]/L2brake-temp-degc",tatdegc+getprop("gear/gear[1]/L2error-temp-degc"));
		setprop("gear/gear[2]/R3brake-temp-degc",tatdegc+getprop("gear/gear[2]/R3error-temp-degc"));
		setprop("gear/gear[2]/R4brake-temp-degc",tatdegc+getprop("gear/gear[2]/R4error-temp-degc"));

		setprop("sim/animation/fire-services",0);
		me.LastSimTime = 0.0;
	},

	# update brake energy
	update : func()
	{
		var CurrentTime = getprop("sim/time/elapsed-sec");
		var dt = CurrentTime - me.LastSimTime;
		var LThermalEnergy = getprop("gear/gear[1]/Lbrake-thermal-energy");
		var RThermalEnergy = getprop("gear/gear[2]/Rbrake-thermal-energy");
		var LBrakeLevel = getprop("fdm/jsbsim/fcs/left-brake-cmd-norm");
		var RBrakeLevel = getprop("fdm/jsbsim/fcs/right-brake-cmd-norm");
		#var atemp  =  getprop("environment/temperature-degc") or 0;
		#var vmach  =  getprop("velocities/mach") or 0;
		#var tatdegc = atemp * (1 + (0.2 * math.pow(vmach, 2)));
		var tatdegc = getprop("/systems/navigation/probes/tat-1/compute-tat") or 0;
		var L_thrust_lb = getprop("engines/engine[0]/thrust_lb");
		var R_thrust_lb = getprop("engines/engine[1]/thrust_lb");

		if (getprop("sim/freeze/replay-state")==0 and dt<1.0) {
			var OnGround = getprop("gear/gear[1]/wow");
			#cooling effect: adjust cooling factor by a value proportional to the environment temp (m.CoolingFactor + environment temp-degc * 0.00001)
			var LCoolingRatio = me.CoolingFactor+(tatdegc*0.000001);
			var RCoolingRatio = me.CoolingFactor+(tatdegc*0.000001);
			if (getprop("controls/gear/brake-fans")) {
				#increase CoolingRatio if Brake Fans are active
				LCoolingRatio = LCoolingRatio * 3;
				RCoolingRatio = RCoolingRatio * 3;
			};
			if (getprop("gear/gear[1]/position-norm")) {
				#increase CoolingRatio if gear down according to airspeed
				LCoolingRatio = LCoolingRatio * getprop("velocities/airspeed-kt");				
			} else {
				#Reduced CoolingRatio if gear up
				LCoolingRatio = LCoolingRatio * 0.1;
			};
			if (getprop("gear/gear[2]/position-norm")) {
				#increase CoolingRatio if gear down according to airspeed
				RCoolingRatio = RCoolingRatio * getprop("velocities/airspeed-kt");
			} else {
				#Reduced CoolingRatio if gear up
				RCoolingRatio = RCoolingRatio * 0.1;
			};
			if (LBrakeLevel>0) {
				#Reduced CoolingRatio if Brakes used
				LCoolingRatio = LCoolingRatio * 0.1 * LBrakeLevel;
			};
			if (RBrakeLevel>0) {
				#Reduced CoolingRatio if Brakes used
				RCoolingRatio = RCoolingRatio * 0.1 * RBrakeLevel;
			};

			var LnCoolFactor = math.ln(1-LCoolingRatio);
			var RnCoolFactor = math.ln(1-RCoolingRatio);

			L_thrust_lb = math.abs(getprop("engines/engine[0]/thrust_lb"));
			if (L_thrust_lb < 1) {
				L_thrust_lb = 1
			};
			#Disabling thrust computation on Brakes temperature
			#L_Thrust = math.pow((math.log10(L_thrust_lb)),10)*0.0000000002;
			L_Thrust = 0;

			R_thrust_lb = math.abs(getprop("engines/engine[1]/thrust_lb"));
			if (R_thrust_lb < 1) {
				R_thrust_lb = 1
			};
			#Disabling thrust computation on Brakes temperature
			#R_Thrust = math.pow((math.log10(R_thrust_lb)),10)*0.0000000002;
			R_Thrust = 0;

			if (OnGround) {
				var V1 = getprop("velocities/groundspeed-kt");
				var Mass = getprop("fdm/jsbsim/inertia/weight-lbs")*(me.ScalingDivisor);

				# absorb some kinetic energy:
				# dE= 1/2 * m * V1^2 - 1/2 * m * V2^2) 
				var V2_L = V1 - me.BrakeDecel * dt * LBrakeLevel;
				var V2_R = V1 - me.BrakeDecel * dt * RBrakeLevel;

				LThermalEnergy += (Mass * getprop("gear/gear[1]/compression-norm") * (math.pow(V1, 2) - math.pow(V2_L, 2)) / 2);
				if (getprop("services/chocks/enable")) {
					if (!getprop("controls/gear/brake-parking")) {
						# cooling effect: reduce thermal energy by (LnCoolFactor) * dt
						LThermalEnergy = LThermalEnergy * math.exp(LnCoolFactor * dt);					
					} else {
						#LThermalEnergy += L_Thrust;
						# cooling effect: reduce thermal energy by (LnCoolFactor) * dt
						LThermalEnergy = (LThermalEnergy * math.exp(LnCoolFactor * dt)) + (L_Thrust * dt);
					};
				} else {
					if (!getprop("controls/gear/brake-parking")) {
						if (LBrakeLevel>0) {
							if (V2_L>0)	{
								#LThermalEnergy += (Mass * (math.pow(V1, 2) - math.pow(V2_L, 2)) / 2) + L_thrust;
								# cooling effect: reduce thermal energy by (LnCoolFactor) * dt
								LThermalEnergy = LThermalEnergy * math.exp(LnCoolFactor * dt);
							} else {
								#LThermalEnergy += math.abs(L_Thrust);
								# cooling effect: reduce thermal energy by (LnCoolFactor) * dt
								LThermalEnergy =  (LThermalEnergy * math.exp(LnCoolFactor * dt)) + (L_Thrust * dt);
							};
						} else {
							# cooling effect: reduce thermal energy by (LnCoolFactor) * dt
							LThermalEnergy = LThermalEnergy * math.exp(LnCoolFactor * dt);
						};
					} else {
						#LThermalEnergy += math.abs(L_Thrust);
						# cooling effect: reduce thermal energy by (LnCoolFactor) * dt
						LThermalEnergy =  (LThermalEnergy * math.exp(LnCoolFactor * dt)) + (L_Thrust * dt);
					};
				};

				RThermalEnergy += (Mass * getprop("gear/gear[2]/compression-norm") * (math.pow(V1, 2) - math.pow(V2_R, 2)) / 2);
				if (getprop("services/chocks/enable")) {
					if (!getprop("controls/gear/brake-parking")) {
						# cooling effect: reduce thermal energy by (RnCoolFactor) * dt
						RThermalEnergy = RThermalEnergy * math.exp(RnCoolFactor * dt);
					} else {
						#RThermalEnergy += math.abs(R_Thrust);
						# cooling effect: reduce thermal energy by (RnCoolFactor) * dt
						RThermalEnergy = (RThermalEnergy * math.exp(RnCoolFactor * dt)) + (R_Thrust * dt);
					};
				} else {
					if (!getprop("controls/gear/brake-parking")) {
						if (RBrakeLevel>0) {
							if (V2_R>0)	{
								#RThermalEnergy += (Mass * (math.pow(V1, 2) - math.pow(V2_R, 2)) / 2) + R_thrust;
								# cooling effect: reduce thermal energy by (RnCoolFactor) * dt
								RThermalEnergy = RThermalEnergy * math.exp(RnCoolFactor * dt);
							} else {
								#RThermalEnergy += math.abs(R_Thrust);
								# cooling effect: reduce thermal energy by (RnCoolFactor) * dt
								RThermalEnergy = (RThermalEnergy * math.exp(RnCoolFactor * dt)) + (R_Thrust * dt);
							};
						} else {
							# cooling effect: reduce thermal energy by (RnCoolFactor) * dt
							RThermalEnergy = RThermalEnergy * math.exp(RnCoolFactor * dt);
						};
					} else {
						#RThermalEnergy += math.abs(R_Thrust);
						# cooling effect: reduce thermal energy by (RnCoolFactor) * dt
						RThermalEnergy = (RThermalEnergy * math.exp(RnCoolFactor * dt)) + (R_Thrust * dt);
					};
				};
			} else {
				LThermalEnergy = LThermalEnergy * math.exp(LnCoolFactor * dt);
				RThermalEnergy = RThermalEnergy * math.exp(RnCoolFactor * dt);
			};
				if (LThermalEnergy < 0) {
				LThermalEnergy = 0
			};
			if (LThermalEnergy > 3) {
				LThermalEnergy = 3
			};
			if (RThermalEnergy < 0) {
				RThermalEnergy = 0
			};
			if (RThermalEnergy > 3) {
				RThermalEnergy = 3
			};

			setprop("gear/gear[1]/L-Thrust",L_Thrust);
			setprop("gear/gear[2]/R-Thrust",R_Thrust);
			setprop("gear/gear[1]/Lbrake-thermal-energy",LThermalEnergy);
			setprop("gear/gear[2]/Rbrake-thermal-energy",RThermalEnergy);

			#Calculating Brakes temperature
			setprop("gear/gear[1]/L1brake-temp-degc",tatdegc+getprop("gear/gear[1]/L1error-temp-degc")+(LThermalEnergy * (300-tatdegc-getprop("gear/gear[1]/L1error-temp-degc"))));
			setprop("gear/gear[1]/L2brake-temp-degc",tatdegc+getprop("gear/gear[1]/L2error-temp-degc")+(LThermalEnergy * (300-tatdegc-getprop("gear/gear[1]/L2error-temp-degc"))));
			setprop("gear/gear[2]/R3brake-temp-degc",tatdegc+getprop("gear/gear[2]/R3error-temp-degc")+(RThermalEnergy * (300-tatdegc-getprop("gear/gear[2]/R3error-temp-degc"))));
			setprop("gear/gear[2]/R4brake-temp-degc",tatdegc+getprop("gear/gear[2]/R4error-temp-degc")+(RThermalEnergy * (300-tatdegc-getprop("gear/gear[2]/R4error-temp-degc"))));

			if ((LThermalEnergy>1)and(!me.LSmokeActive)) {
				# start smoke processing 
				me.LSmokeActive = 1;
				settimer(func { BrakeSys.Lsmoke(); },0);
			};
			if ((RThermalEnergy>1)and(!me.RSmokeActive)) {
				# start smoke processing 
				me.RSmokeActive = 1;
				settimer(func { BrakeSys.Rsmoke(); },0);
			};
		};

		me.LastSimTime = CurrentTime;
		# 5 updates per second are good enough
		settimer(func { BrakeSys.update(); },0.2);
	},

	# smoke processing
	Lsmoke : func()
	{
		if ((me.LSmokeActive)and(getprop("gear/gear[1]/Lbrake-thermal-energy")>1)) {
			# make density of smoke effect depend on energy level  
			var LSmokeDelay=0;
			var LThermalEnergy = getprop("gear/gear[1]/Lbrake-thermal-energy");
			if (LThermalEnergy < 1.5) {
				LSmokeDelay=(1.5-LThermalEnergy);			
			};

			# No smoke when gear retracted
			var LSmokeValue = (getprop("gear/gear[1]/position-norm")>0.5);
			# toggle smoke to interpolate different densities 
			if (LSmokeDelay>0.05) {
				me.LSmokeToggle = !me.LSmokeToggle;
				if (!me.LSmokeToggle)
					LSmokeValue = 0;
				else
					LSmokeDelay = 0;
			};
			setprop("gear/gear[1]/Lbrake-smoke",LSmokeValue);
			settimer(func { BrakeSys.Lsmoke(); },LSmokeDelay);
		} else {
			# stop smoke processing
			setprop("gear/gear[1]/Lbrake-smoke",0);
			setprop("sim/animation/fire-services",0);
			me.LSmokeActive = 0;
		};
		if (getprop("gear/gear[1]/Lbrake-thermal-energy") > 1.5) {
			setprop("sim/animation/fire-services",1);
		} else {
			setprop("sim/animation/fire-services",0);		
		};

	},

	# smoke processing
	Rsmoke : func()
	{
		if ((me.RSmokeActive)and(getprop("gear/gear[2]/Rbrake-thermal-energy")>1)) {
			# make density of smoke effect depend on energy level  
			var RSmokeDelay=0;
			var RThermalEnergy = getprop("gear/gear[2]/Rbrake-thermal-energy");
			if (RThermalEnergy < 1.5) {
				RSmokeDelay=(1.5-RThermalEnergy);
			};
			
			# No smoke when gear retracted
			var RSmokeValue = (getprop("gear/gear[2]/position-norm")>0.5);
			# toggle smoke to interpolate different densities 
			if (RSmokeDelay>0.05) {
				me.RSmokeToggle = !me.RSmokeToggle;
				if (!me.RSmokeToggle)
					RSmokeValue = 0;
				else
					RSmokeDelay = 0;
			};
			setprop("gear/gear[2]/Rbrake-smoke",RSmokeValue);
			settimer(func { BrakeSys.Rsmoke(); },RSmokeDelay);
		} else {
			# stop smoke processing
			setprop("gear/gear[2]/Rbrake-smoke",0);
			me.RSmokeActive = 0;
		};
		if (getprop("gear/gear[2]/Rbrake-thermal-energy") > 1.5) {
			setprop("sim/animation/fire-services",1);		
		} else {
			setprop("sim/animation/fire-services",0);		
		};
	},
};

var BrakeSys = BrakeSystem.new();

setlistener("sim/signals/fdm-initialized",
	# executed on _every_ FDM reset (but not installing new listeners)
	func(idle) { BrakeSys.reset(); },
0,0);

settimer(func()
	{
		BrakeSys.update();
	}, 5);
