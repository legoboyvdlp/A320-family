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

var BrakeSystem =
{
    new : func()
    {
       var m = { parents : [BrakeSystem]};
       # deceleration caused by brakes alone (knots/s2)
       m.BrakeDecel    = 1.0; # kt/s^2
       # Higher value means quicker cooling
       m.CoolingFactor = 0.0005;
       # Scaling divisor. Use this to scale the energy output.
       # Manually tune this value: a total energy output
       # at "/gear/brake-thermal-energy" > 1.0 means overheated brakes,
       # anything below <= 1.0 means energy absorbed by brakes is OK. 
       #m.ScalingDivisor= 700000*450.0;

       m.ScalingDivisor = 0.000000008;
       
       m.LSmokeActive   = 0;
       m.LSmokeToggle   = 0;
       m.RSmokeActive   = 0;
       m.RSmokeToggle   = 0;
#       m.LnCoolFactor   = math.ln(1-m.CoolingFactor);

       m.reset();

       return m;
    },

    reset : func()
    {
        # Initial thermal energy
        setprop("controls/gear/brake-fans",0);
        setprop("gear/gear[1]/Lbrake-thermal-energy",0.0);
        setprop("gear/gear[2]/Rbrake-thermal-energy",0.0);
        setprop("gear/gear[1]/Lbrake-smoke",0);
        setprop("gear/gear[2]/Rbrake-smoke",0);
       	setprop("gear/gear[1]/L1brake-temp-degc",getprop("environment/temperature-degc"));
       	setprop("gear/gear[1]/L2brake-temp-degc",getprop("environment/temperature-degc"));
       	setprop("gear/gear[2]/R3brake-temp-degc",getprop("environment/temperature-degc"));
       	setprop("gear/gear[2]/R4brake-temp-degc",getprop("environment/temperature-degc"));
       	setprop("gear/gear[1]/L1brake-temp-degf",getprop("environment/temperature-degf"));
       	setprop("gear/gear[1]/L2brake-temp-degf",getprop("environment/temperature-degf"));
       	setprop("gear/gear[2]/R3brake-temp-degf",getprop("environment/temperature-degf"));
       	setprop("gear/gear[2]/R4brake-temp-degf",getprop("environment/temperature-degf"));
		
		#Introducing a random error on the brakes temp sensors
        if (rand() > 0.5)
        {
        	setprop("gear/gear[1]/L1error_temp_degc", math.round(rand()*5));
        	setprop("gear/gear[1]/L2error_temp_degc", math.round(rand()*5));
        	setprop("gear/gear[2]/R3error_temp_degc", math.round(rand()*5));
        	setprop("gear/gear[2]/R4error_temp_degc", math.round(rand()*5));
        } else {
        	setprop("gear/gear[1]/L1error_temp_degc", math.round(rand()*(-5)));
        	setprop("gear/gear[1]/L2error_temp_degc", math.round(rand()*(-5)));
        	setprop("gear/gear[2]/R3error_temp_degc", math.round(rand()*(-5)));
        	setprop("gear/gear[2]/R4error_temp_degc", math.round(rand()*(-5)));        
        }
        setprop("sim/animation/fire-services",0);
        me.LastSimTime = 0.0;
    },

    # update brake energy
    update : func()
    {
        var CurrentTime = getprop("sim/time/elapsed-sec");
        var dt = CurrentTime - me.LastSimTime;

        if (dt<1.0)
        {
			#cooling effect: adjust cooling factor by a value proportional to the environment temp (m.CoolingFactor + environment temp-degf * 0.00001)
			var CoolingRatio = me.CoolingFactor+(getprop("environment/temperature-degf")*0.00001);
	        if (getprop("controls/gear/brake-fans"))
	        {
		        #increase CoolingRatio if Brake Fans are active
	           	CoolingRatio = CoolingRatio * 3;
			}
						
			var nCoolFactor = math.ln(1-CoolingRatio);

            var OnGround = getprop("gear/gear[1]/wow");
            var LThermalEnergy = getprop("gear/gear[1]/Lbrake-thermal-energy");
            var RThermalEnergy = getprop("gear/gear[2]/Rbrake-thermal-energy");
			
            var LBrakeLevel = getprop("fdm/jsbsim/fcs/left-brake-cmd-norm");
            var RBrakeLevel = getprop("fdm/jsbsim/fcs/right-brake-cmd-norm");
			#}
			var BrakeLevel = (LBrakeLevel + RBrakeLevel)/2;
            if ((OnGround)and(BrakeLevel>0))
            {
                # absorb more energy
                var V1 = getprop("velocities/groundspeed-kt");
                var Mass = getprop("fdm/jsbsim/inertia/weight-lbs")*(me.ScalingDivisor);
                # absorb some kinetic energy:
                # dE= 1/2 * m * V1^2 - 1/2 * m * V2^2) 
                var V2_L = V1 - me.BrakeDecel * dt * LBrakeLevel;
                var V2_R = V1 - me.BrakeDecel * dt * RBrakeLevel;
                # do not absorb more energy when plane is (almost) stopped
                # Thermal energy computation 
                if (V2_L>0)
                {
                    LThermalEnergy += Mass * (V1*V1 - V2_L*V2_L)/2;
		            # cooling effect: reduce thermal energy by (nCoolFactor)^dt
		           	LThermalEnergy = LThermalEnergy * math.exp(nCoolFactor * dt);
		        } else {                
		            # cooling effect: reduced cooling when speed = 0 and brakes on
       	           	LThermalEnergy = LThermalEnergy * math.exp(nCoolFactor * 0.3 * dt);
       	        }
                if (V2_R>0)
                {
                    RThermalEnergy += Mass * (V1*V1 - V2_R*V2_R)/2;
                    # cooling effect: reduce thermal energy by (nCoolFactor)^dt
		           	RThermalEnergy = RThermalEnergy * math.exp(nCoolFactor * dt);
                } else {
		            # cooling effect: reduced cooling when speed = 0 and brakes on
 		           	RThermalEnergy = RThermalEnergy * math.exp(nCoolFactor * 0.3 * dt);
		        }
            } else {
            	LThermalEnergy = LThermalEnergy * math.exp(nCoolFactor * dt);
            	RThermalEnergy = RThermalEnergy * math.exp(nCoolFactor * dt);
            }
            
            setprop("gear/gear[1]/Lbrake-thermal-energy",LThermalEnergy);
            setprop("gear/gear[2]/Rbrake-thermal-energy",RThermalEnergy);

            #Calculating Brakes temperature
            setprop("gear/gear[1]/L1brake-temp-degc",getprop("gear/gear[1]/L1error_temp_degc")+getprop("environment/temperature-degc")+(LThermalEnergy * (300-getprop("gear/gear[1]/L1error_temp_degc")-getprop("environment/temperature-degc"))));
            setprop("gear/gear[1]/L2brake-temp-degc",getprop("gear/gear[1]/L2error_temp_degc")+getprop("environment/temperature-degc")+(LThermalEnergy * (300-getprop("gear/gear[1]/L2error_temp_degc")-getprop("environment/temperature-degc"))));
            setprop("gear/gear[2]/R3brake-temp-degc",getprop("gear/gear[2]/R3error_temp_degc")+getprop("environment/temperature-degc")+(RThermalEnergy * (300-getprop("gear/gear[2]/R3error_temp_degc")-getprop("environment/temperature-degc"))));
            setprop("gear/gear[2]/R4brake-temp-degc",getprop("gear/gear[2]/R4error_temp_degc")+getprop("environment/temperature-degc")+(RThermalEnergy * (300-getprop("gear/gear[2]/R4error_temp_degc")-getprop("environment/temperature-degc"))));
            setprop("gear/gear[1]/L1brake-temp-degf",(32 + (1.8 * getprop("gear/gear[1]/L1brake-temp-degc"))));
            setprop("gear/gear[1]/L2brake-temp-degf",(32 + (1.8 * getprop("gear/gear[1]/L2brake-temp-degc"))));
            setprop("gear/gear[2]/R3brake-temp-degf",(32 + (1.8 * getprop("gear/gear[2]/R3brake-temp-degc"))));
            setprop("gear/gear[2]/R4brake-temp-degf",(32 + (1.8 * getprop("gear/gear[2]/R4brake-temp-degc"))));
            
            if ((LThermalEnergy>1)and(!me.LSmokeActive))
            {
                # start smoke processing 
                me.LSmokeActive = 1;
                settimer(func { BrakeSys.Lsmoke(); },0);
            }
            if ((RThermalEnergy>1)and(!me.RSmokeActive))
            {
                # start smoke processing 
                me.RSmokeActive = 1;
                settimer(func { BrakeSys.Rsmoke(); },0);
            }
        }
        
        me.LastSimTime = CurrentTime;
        # 5 updates per second are good enough
        settimer(func { BrakeSys.update(); },0.2);
    },

    # smoke processing
    Lsmoke : func()
    {
        if ((me.LSmokeActive)and(getprop("gear/gear[1]/Lbrake-thermal-energy")>1))
        {
            # make density of smoke effect depend on energy level  
            var LSmokeDelay=0;
            var LThermalEnergy = getprop("gear/gear[1]/Lbrake-thermal-energy");
            if (LThermalEnergy < 1.5)
                LSmokeDelay=(1.5-LThermalEnergy);
            # No smoke when gear retracted
            var LSmokeValue = (getprop("gear/gear[1]/position-norm")>0.5);
            # toggle smoke to interpolate different densities 
            if (LSmokeDelay>0.05)
            {
                me.LSmokeToggle = !me.LSmokeToggle;
                if (!me.LSmokeToggle)
                    LSmokeValue = 0;
                else
                    LSmokeDelay = 0;
            }
            setprop("gear/gear[1]/Lbrake-smoke",LSmokeValue);
            settimer(func { BrakeSys.Lsmoke(); },LSmokeDelay);
        }
        else
        {
            # stop smoke processing
            setprop("gear/gear[1]/Lbrake-smoke",0);
            setprop("sim/animation/fire-services",0);
            me.LSmokeActive = 0;
        }
        if (getprop("gear/gear[1]/Lbrake-thermal-energy") > 1.5)
            setprop("sim/animation/fire-services",1);
        else
            setprop("sim/animation/fire-services",0);
    },

    # smoke processing
    Rsmoke : func()
    {
        if ((me.RSmokeActive)and(getprop("gear/gear[2]/Rbrake-thermal-energy")>1))
        {
            # make density of smoke effect depend on energy level  
            var RSmokeDelay=0;
            var RThermalEnergy = getprop("gear/gear[2]/Rbrake-thermal-energy");
            if (RThermalEnergy < 1.5)
                RSmokeDelay=(1.5-RThermalEnergy);
            # No smoke when gear retracted
            var RSmokeValue = (getprop("gear/gear[2]/position-norm")>0.5);
            # toggle smoke to interpolate different densities 
            if (RSmokeDelay>0.05)
            {
                me.RSmokeToggle = !me.RSmokeToggle;
                if (!me.RSmokeToggle)
                    RSmokeValue = 0;
                else
                    RSmokeDelay = 0;
            }
            setprop("gear/gear[2]/Rbrake-smoke",RSmokeValue);
            settimer(func { BrakeSys.Rsmoke(); },RSmokeDelay);
        }
        else
        {
            # stop smoke processing
            setprop("gear/gear[2]/Rbrake-smoke",0);
            me.RSmokeActive = 0;
        }
        if (getprop("gear/gear[2]/Rbrake-thermal-energy") > 1.5)
            setprop("sim/animation/fire-services",1);
        else
            setprop("sim/animation/fire-services",0);
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
