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
       #m.LBrakeDecel    = getprop("systems/hydraulic/brakes/pressure-left-psi") / 1000 * getprop("controls/autobrake/decel-error"); # kt/s^2
       #m.RBrakeDecel    = getprop("systems/hydraulic/brakes/pressure-right-psi") / 1000 * getprop("controls/autobrake/decel-error"); # kt/s^2
       # Higher value means quicker cooling
       m.CoolingFactor = 0.005;
       # Scaling divisor. Use this to scale the energy output.
       # Manually tune this value: a total energy output
       # at "/gear/brake-thermal-energy" > 1.0 means overheated brakes,
       # anything below <= 1.0 means energy absorbed by brakes is OK. 
       #m.ScalingDivisor= 700000*450.0;
       m.ScalingDivisor= 1;
       
       m.LSmokeActive   = 0;
       m.LSmokeToggle   = 0;
       m.RSmokeActive   = 0;
       m.RSmokeToggle   = 0;
       m.nCoolFactor  = math.ln(1-m.CoolingFactor);

       m.reset();

       return m;
    },

    reset : func()
    {
        # Initial thermal energy
        setprop("gear/Lbrake-thermal-energy",0.0);
        setprop("gear/Rbrake-thermal-energy",0.0);
        setprop("gear/Lbrake-smoke",0);
        setprop("gear/Rbrake-smoke",0);
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
            var OnGround = getprop("gear/gear[1]/wow");
            var LThermalEnergy = getprop("gear/Lbrake-thermal-energy");
            var RThermalEnergy = getprop("gear/Rbrake-thermal-energy");
            if (getprop("controls/gear/brake-parking"))
            {
                var LBrakeLevel=1.0;
                var RBrakeLevel=1.0;
                var BrakeLevel = (LBrakeLevel + RBrakeLevel)/2;
            }
            else
                var LBrakeLevel = getprop("fdm/jsbsim/fcs/left-brake-cmd-norm");
                var RBrakeLevel = getprop("fdm/jsbsim/fcs/right-brake-cmd-norm");
                var BrakeLevel = (LBrakeLevel + RBrakeLevel)/2;
            if ((OnGround)and(BrakeLevel>0))
            {
                # absorb more energy
                var V1 = getprop("velocities/groundspeed-kt");
                var Mass = getprop("fdm/jsbsim/inertia/weight-lbs")/(me.ScalingDivisor*200000000);
                # absorb some kinetic energy:
                # dE= 1/2 * m * V1^2 - 1/2 * m * V2^2) 
                var V2_L = V1 - me.BrakeDecel*dt * LBrakeLevel;
                var V2_R = V1 - me.BrakeDecel*dt * RBrakeLevel;
                # do not absorb more energy when plane is (almost) stopped
                if (V2_L>0)
                    LThermalEnergy += Mass * (V1*V1 - V2_L*V2_L)/2;
                if (V2_R>0)
                    RThermalEnergy += Mass * (V1*V1 - V2_R*V2_R)/2;
            }

            # cooling effect: reduce thermal energy by factor (1-m.CoolingFactor)^dt
            LThermalEnergy = LThermalEnergy * math.exp(me.nCoolFactor * dt);
            RThermalEnergy = RThermalEnergy * math.exp(me.nCoolFactor * dt);

            setprop("gear/Lbrake-thermal-energy",LThermalEnergy);
            setprop("gear/Rbrake-thermal-energy",RThermalEnergy);
            
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
        if ((me.LSmokeActive)and(getprop("gear/Lbrake-thermal-energy")>1))
        {
            # make density of smoke effect depend on energy level  
            var LSmokeDelay=0;
            var LThermalEnergy = getprop("gear/Lbrake-thermal-energy");
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
            setprop("gear/Lbrake-smoke",LSmokeValue);
            settimer(func { BrakeSys.Lsmoke(); },LSmokeDelay);
        }
        else
        {
            # stop smoke processing
            setprop("gear/Lbrake-smoke",0);
            setprop("sim/animation/fire-services",0);
            me.LSmokeActive = 0;
        }
        if (getprop("gear/Lbrake-thermal-energy") > 1.5)
            setprop("sim/animation/fire-services",1);
        else
            setprop("sim/animation/fire-services",0);
    },

    # smoke processing
    Rsmoke : func()
    {
        if ((me.RSmokeActive)and(getprop("gear/Rbrake-thermal-energy")>1))
        {
            # make density of smoke effect depend on energy level  
            var RSmokeDelay=0;
            var RThermalEnergy = getprop("gear/Rbrake-thermal-energy");
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
            setprop("gear/Rbrake-smoke",RSmokeValue);
            settimer(func { BrakeSys.Rsmoke(); },RSmokeDelay);
        }
        else
        {
            # stop smoke processing
            setprop("gear/Rbrake-smoke",0);
            me.RSmokeActive = 0;
        }
        if (getprop("gear/Rbrake-thermal-energy") > 1.5)
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
