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
       m.CoolingFactor = 0.007;
       # Scaling divisor. Use this to scale the energy output.
       # Manually tune this value: a total energy output
       # at "/gear/brake-thermal-energy" > 1.0 means overheated brakes,
       # anything below <= 1.0 means energy absorbed by brakes is OK. 
       m.ScalingDivisor= 800000*450.0;
       
       m.SmokeActive   = 0;
       m.SmokeToggle   = 0;
       m.LnCoolFactor  = math.ln(1-m.CoolingFactor);

       m.reset();

       return m;
    },

    reset : func()
    {
        # Initial thermal energy
        setprop("gear/brake-thermal-energy",0.0);
        setprop("gear/brake-smoke",0);
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
            var ThermalEnergy = getprop("gear/brake-thermal-energy");
            if (getprop("controls/gear/brake-parking"))
                var BrakeLevel=1.0;
            else
#                var BrakeLevel = (getprop("autopilot/autobrake/left-brake-output")+getprop("autopilot/autobrake/right-brake-output"))/2;
                var BrakeLevel = getprop("controls/autobrake/decel-error");
            if ((OnGround)and(BrakeLevel>0))
            {
                # absorb more energy
                var V1 = getprop("velocities/groundspeed-kt");
                var Mass = getprop("fdm/jsbsim/inertia/weight-lbs")/me.ScalingDivisor;
                # absorb some kinetic energy:
                # dE= 1/2 * m * V1^2 - 1/2 * m * V2^2) 
                var V2 = V1 - me.BrakeDecel*dt * BrakeLevel;
                # do not absorb more energy when plane is (almost) stopped
                if (V2>0)
                    ThermalEnergy += Mass * (V1*V1 - V2*V2)/2;
            }

            # cooling effect: reduce thermal energy by factor (1-m.CoolingFactor)^dt
            ThermalEnergy = ThermalEnergy * math.exp(me.LnCoolFactor * dt);

            setprop("gear/brake-thermal-energy",ThermalEnergy);
            
            if ((ThermalEnergy>1)and(!me.SmokeActive))
            {
                # start smoke processing 
                me.SmokeActive = 1;
                settimer(func { BrakeSys.smoke(); },0);
            }
        }
        
        me.LastSimTime = CurrentTime;
        # 5 updates per second are good enough
        settimer(func { BrakeSys.update(); },0.2);
    },

    # smoke processing
    smoke : func()
    {
        if ((me.SmokeActive)and(getprop("gear/brake-thermal-energy")>1))
        {
            # make density of smoke effect depend on energy level  
            var SmokeDelay=0;
            var ThermalEnergy = getprop("gear/brake-thermal-energy");
            if (ThermalEnergy < 1.5)
                SmokeDelay=(1.5-ThermalEnergy);
            else
                setprop("sim/animation/fire-services",1);
            # No smoke when gear retracted
            var SmokeValue = (getprop("gear/gear[1]/position-norm")>0.5);
            # toggle smoke to interpolate different densities 
            if (SmokeDelay>0.05)
            {
                me.SmokeToggle = !me.SmokeToggle;
                if (!me.SmokeToggle)
                    SmokeValue = 0;
                else
                    SmokeDelay = 0;
            }
            setprop("gear/brake-smoke",SmokeValue);
            settimer(func { BrakeSys.smoke(); },SmokeDelay);
        }
        else
        {
            # stop smoke processing
            setprop("gear/brake-smoke",0);
            setprop("sim/animation/fire-services",0);
            me.SmokeActive = 0;
        }
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
