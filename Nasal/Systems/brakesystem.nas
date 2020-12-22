# A3XX Autobrake and Braking
# Joshua Davidson (Octal450)

# Copyright (c) 2020 Josh Davidson (Octal450)


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
# Updated Nasal to project standards
# 2020, Jonathan Redpath
##########################################################################

var LThermalEnergy = 0;
var RThermalEnergy = 0;
var dt = 0;
var LBrakeLevel = 0;
var RBrakeLevel = 0;
var tatdegc = 0;
var L_thrust = 0;
var R_thrust = 0;
var airspeed = 0;

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
	   m.thermalEnergy  = [0.0, 0.0];
	   m.brakeFans      = props.globals.getNode("/controls/gear/brake-fans");
	   m.fireServices   = props.globals.getNode("/sim/animation/fire-services");
	   m.gearSmoke      = [props.globals.getNode("/gear/gear[1]/Lbrake-smoke"), props.globals.getNode("/gear/gear[2]/Rbrake-smoke")];
	   m.lBrakeTemp     = [props.globals.getNode("/gear/gear[1]/L1brake-temp-degc"),props.globals.getNode("/gear/gear[1]/L2brake-temp-degc")];
	   m.rBrakeTemp     = [props.globals.getNode("/gear/gear[2]/R3brake-temp-degc"),props.globals.getNode("/gear/gear[2]/R4brake-temp-degc")];
	   m.L1error        = 0;
	   m.L2error        = 0;
	   m.R3error        = 0;
	   m.R4error        = 0;
	   m.counter        = 0;

	   return m;
	},

	reset : func()
	{
		# Initial thermal energy
		me.thermalEnergy[0] = 0.0;
		me.thermalEnergy[1] = 0.0;

		me.brakeFans.setValue(0);
		me.gearSmoke[0].setValue(0);
		me.gearSmoke[1].setValue(0);
		me.fireServices.setValue(0);

		#Introducing a random error on temp sensors (max 5°C)
		me.L1error = math.round(rand()*(5));
		me.L2error = math.round(rand()*(5));	  
		me.R3error = math.round(rand()*(5));
		me.R4error = math.round(rand()*(5));

		var tatdegc = pts.Fdm.JSBsim.Propulsion.tatC.getValue() or 0;

		me.lBrakeTemp[0].setValue(tatdegc+me.L1error);
		me.lBrakeTemp[1].setValue(tatdegc+me.L2error);
		me.rBrakeTemp[0].setValue(tatdegc+me.R3error);
		me.rBrakeTemp[1].setValue(tatdegc+me.R4error);

		me.LastSimTime = 0.0;
	},
	
	# update brake energy
	update : func()
	{
		if (me.counter == 0) {
			me.counter = 1;
		} else {
			me.counter = 0;
			return;
		}
		
		LThermalEnergy = me.thermalEnergy[0];
		RThermalEnergy = me.thermalEnergy[1];
		me.CurrentTime = pts.Sim.Time.elapsedSec.getValue();
		dt = me.CurrentTime - me.LastSimTime;
		LBrakeLevel = pts.Fdm.JSBsim.Fcs.brake[0].getValue();
		RBrakeLevel = pts.Fdm.JSBsim.Fcs.brake[1].getValue();
		tatdegc = pts.Fdm.JSBsim.Propulsion.tatC.getValue() or 0;

		if (pts.Sim.replayState.getValue() == 0 and dt < 1.0) {
			#cooling effect: adjust cooling factor by a value proportional to the environment temp (m.CoolingFactor + environment temp-degc * 0.00001)
			var LCoolingRatio = me.CoolingFactor+(tatdegc*0.000001);
			var RCoolingRatio = me.CoolingFactor+(tatdegc*0.000001);
			if (me.brakeFans.getValue()) {
				#increase CoolingRatio if Brake Fans are active
				LCoolingRatio = LCoolingRatio * 3;
				RCoolingRatio = RCoolingRatio * 3;
			};
			airspeed = pts.Velocities.airspeed.getValue();
			if (pts.Gear.position[1].getValue()) {
				#increase CoolingRatio if gear down according to airspeed
				LCoolingRatio = LCoolingRatio * airspeed;				
			} else {
				#Reduced CoolingRatio if gear up
				LCoolingRatio = LCoolingRatio * 0.1;
			};
			if (pts.Gear.position[2].getValue()) {
				#increase CoolingRatio if gear down according to airspeed
				RCoolingRatio = RCoolingRatio * airspeed;
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

			# disabled thrust effect
			L_Thrust = 0;
			R_Thrust = 0;

			if (pts.Gear.wow[1].getValue()) {
				var V1 = pts.Velocities.groundspeed.getValue();
				var Mass = pts.Fdm.JSBsim.Inertia.weightLbs.getValue() * me.ScalingDivisor;

				# absorb some kinetic energy:
				# dE= 1/2 * m * V1^2 - 1/2 * m * V2^2) 
				var V2_L = V1 - me.BrakeDecel * dt * LBrakeLevel;
				var V2_R = V1 - me.BrakeDecel * dt * RBrakeLevel;

				LThermalEnergy += (Mass * pts.Gear.compression[1].getValue() * (math.pow(V1, 2) - math.pow(V2_L, 2)) / 2);
				if (pts.Controls.Gear.chocks.getValue()) {
					if (!pts.Controls.Gear.parkingBrake.getValue()) {
						# cooling effect: reduce thermal energy by (LnCoolFactor) * dt
						LThermalEnergy = LThermalEnergy * math.exp(LnCoolFactor * dt);					
					} else {
						#LThermalEnergy += L_Thrust;
						# cooling effect: reduce thermal energy by (LnCoolFactor) * dt
						LThermalEnergy = (LThermalEnergy * math.exp(LnCoolFactor * dt)) + (L_Thrust * dt);
					};
				} else {
					if (!pts.Controls.Gear.parkingBrake.getValue()) {
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

				RThermalEnergy += (Mass * pts.Gear.compression[2].getValue() * (math.pow(V1, 2) - math.pow(V2_R, 2)) / 2);
				if (pts.Controls.Gear.chocks.getValue()) {
					if (!pts.Controls.Gear.parkingBrake.getValue()) {
						# cooling effect: reduce thermal energy by (RnCoolFactor) * dt
						RThermalEnergy = RThermalEnergy * math.exp(RnCoolFactor * dt);
					} else {
						#RThermalEnergy += math.abs(R_Thrust);
						# cooling effect: reduce thermal energy by (RnCoolFactor) * dt
						RThermalEnergy = (RThermalEnergy * math.exp(RnCoolFactor * dt)) + (R_Thrust * dt);
					};
				} else {
					if (!pts.Controls.Gear.parkingBrake.getValue()) {
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

			me.thermalEnergy[0] = LThermalEnergy;
			me.thermalEnergy[1] = RThermalEnergy;

			#Calculating Brakes temperature
			me.lBrakeTemp[0].setValue(tatdegc+me.L1error+(LThermalEnergy * (300-tatdegc-me.L1error)));
			me.lBrakeTemp[1].setValue(tatdegc+me.L2error+(LThermalEnergy * (300-tatdegc-me.L2error)));
			me.rBrakeTemp[0].setValue(tatdegc+me.R3error+(RThermalEnergy * (300-tatdegc-me.R3error)));
			me.rBrakeTemp[1].setValue(tatdegc+me.R4error+(RThermalEnergy * (300-tatdegc-me.R4error)));

			if (LThermalEnergy>1 and !me.LSmokeActive) {
				# start smoke processing 
				me.LSmokeActive = 1;
				settimer(func { BrakeSys.Lsmoke(); },0);
			};
			if (RThermalEnergy>1 and !me.RSmokeActive) {
				# start smoke processing 
				me.RSmokeActive = 1;
				settimer(func { BrakeSys.Rsmoke(); },0);
			};
		};

		me.LastSimTime = me.CurrentTime;
	},

	# smoke processing
	Lsmoke : func()
	{
		if (me.LSmokeActive and me.thermalEnergy[0] > 1) {
			# make density of smoke effect depend on energy level  
			var LSmokeDelay = 0;
			var LThermalEnergy = me.thermalEnergy[0];
			if (LThermalEnergy < 1.5) {
				LSmokeDelay = (1.5 - LThermalEnergy);			
			};

			# No smoke when gear retracted
			var LSmokeValue = (pts.Gear.position[1].getValue() > 0.5);
			# toggle smoke to interpolate different densities 
			if (LSmokeDelay > 0.05) {
				me.LSmokeToggle = !me.LSmokeToggle;
				if (!me.LSmokeToggle)
					LSmokeValue = 0;
				else
					LSmokeDelay = 0;
			};
			me.gearSmoke[0].setValue(LSmokeValue);
			settimer(func { BrakeSys.Lsmoke(); },LSmokeDelay);
		} else {
			# stop smoke processing
			me.gearSmoke[0].setValue(0);
			me.LSmokeActive = 0;
		};
		if (me.thermalEnergy[0] > 1.5) {
			me.fireServices.setValue(1);
		} else {
			me.fireServices.setValue(0);
		};

	},

	# smoke processing
	Rsmoke : func()
	{
		if (me.RSmokeActive and me.thermalEnergy[1] > 1) {
			# make density of smoke effect depend on energy level  
			var RSmokeDelay = 0;
			var RThermalEnergy = me.thermalEnergy[1];
			if (RThermalEnergy < 1.5) {
				RSmokeDelay = (1.5 - RThermalEnergy);
			};
			
			# No smoke when gear retracted
			var RSmokeValue = (pts.Gear.position[2].getValue() > 0.5);
			# toggle smoke to interpolate different densities 
			if (RSmokeDelay > 0.05) {
				me.RSmokeToggle = !me.RSmokeToggle;
				if (!me.RSmokeToggle)
					RSmokeValue = 0;
				else
					RSmokeDelay = 0;
			};
			me.gearSmoke[1].setValue(RSmokeValue);
			settimer(func { BrakeSys.Rsmoke(); },RSmokeDelay);
		} else {
			# stop smoke processing
			me.gearSmoke[1].setValue(0);
			me.RSmokeActive = 0;
		};
		if (me.thermalEnergy[1] > 1.5) {
			me.fireServices.setValue(1);
		} else {
			me.fireServices.setValue(0);	
		};
	},
};

var BrakeSys = BrakeSystem.new();

#############
# Autobrake #
#############

var Autobrake = {
	active: props.globals.initNode("/controls/autobrake/active", 0, "BOOL"),
	mode: props.globals.initNode("/controls/autobrake/mode", 0, "INT"),
	decel: props.globals.initNode("/controls/autobrake/decel-rate", 0, "DOUBLE"),
	_wow0: 0,
	_gnd_speed: 0,
	_mode: 0,
	_active: 0,
	init: func() {
		me.active.setBoolValue(0);
		me.mode.setValue(0);
		me.decel.setValue(0);
	},
	arm_autobrake: func(mode) {
		me._wow0 = pts.Gear.wow[0].getBoolValue();
		me._gnd_speed = pts.Velocities.groundspeed.getValue();
		if (mode == 0) { # OFF
			absChk.stop();
			if (me.active.getBoolValue()) {
				me.active.setBoolValue(0);
				pts.Controls.Gear.brake[0].setValue(0);
				pts.Controls.Gear.brake[1].setValue(0);
			}
			me.decel.setValue(0);
			me.mode.setValue(0);
		} else if (mode == 1 and !me._wow0) { # LO
			me.decel.setValue(2.0);
			me.mode.setValue(1);
			absChk.start();
		} else if (mode == 2 and !me._wow0) { # MED
			me.decel.setValue(3);
			me.mode.setValue(2);
			absChk.start();
		} else if (mode == 3 and me._wow0 and me._gnd_speed < 40) { # MAX
			me.decel.setValue(6);
			me.mode.setValue(3);
			absChk.start();
		}
	},
	loop: func() {
		me._wow0 = pts.Gear.wow[0].getBoolValue();
		me._gnd_speed = pts.Velocities.groundspeed.getValue();
		me._mode = me.mode.getValue();
		me._active = me.active.getBoolValue();
		if (me._gnd_speed > 72) {
			if (me._mode != 0 and pts.Controls.Engines.Engine.throttle[0].getValue() < 0.15 and pts.Controls.Engines.Engine.throttle[1].getValue() < 0.15 and me._wow0 and systems.HYD.Brakes.askidSw.getValue() and systems.HYD.Psi.green.getValue() >= 2500 ) {
				me.active.setBoolValue(1);
			} elsif (me._active) {
				me.active.setBoolValue(0);
				pts.Controls.Gear.brake[0].setValue(0);
				pts.Controls.Gear.brake[1].setValue(0);
			}
		}
		
		if (me._mode == 3 and !pts.Controls.Gear.gearDown.getBoolValue()) {
			me.arm_autobrake(0);
		}
		if (me._mode != 0 and me._wow0 and me._active and (pts.Controls.Gear.brake[0].getValue() > 0.05 or pts.Controls.Gear.brake[1].getValue() > 0.05)) {
			me.arm_autobrake(0);
		}
	},
};

# Override FG's generic brake
controls.applyBrakes = func(v, which = 0) {
	if (!pts.Acconfig.running.getBoolValue()) {
		if (which <= 0) {
			pts.Controls.Gear.brake[0].setValue(v);
		}
		if (which >= 0) {
			pts.Controls.Gear.brake[1].setValue(v);
		}
	}
}

# Autobrake loop
var absChk = maketimer(0.2, func {
	Autobrake.loop();
});
