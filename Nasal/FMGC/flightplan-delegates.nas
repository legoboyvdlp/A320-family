# SPDX-License-Identifier: GPL-2.0-or-later
#
# NOTE! This copyright does *not* cover user models that use these Nasal
# services by normal function calls - this is merely considered normal use
# of the code, and does *not* fall under the heading of "derived work."
#
# Copyright (C) 2012-202 by James Turner

# route_manager.nas -  FlightPlan delegate(s) corresponding to the built-
# in route-manager dialog and GPS. Intended to provide a sensible default behaviour,
# but can be disabled by an aircraft-specific FMS / GPS system.

# This delegate corresponds to functionality of the built-in route-manager dialog.
# if you disable it, the built-in route-manager dialog may not work as expected.
# Especially, this dialog is responsible for building departure, approach and
# arrival waypoints corresponding to the requested SID/STAR/approach,
# and replacing them when the inputs change (eg, user seelcted a different 
# destination or STAR while enroute)
#
# You can disable the default GPS behaviour *without* touching this delegate : they are
# kept seperate since this first one is less likely to need changes

var GPSPath = "/instrumentation/gps";

# this delegate corresponds to the default behaviour of the built-in GPS.
# depending on the real GPS/FMS you are modelling, you probably need to
# replace this with your own.
#
# To do that, just set /autopilot/route-manager/disable-fms to true, which
# will block creation of this delegate.
#
# Of course you are then responsible for many basic FMS functions, such as
# route sequencing and activation
#

var A320GPSDeleagte = {
    new: func(fp) {
        var m = { parents: [A320GPSDeleagte], flightplan:fp, landingCheck:nil };

        logprint(LOG_INFO, 'creating A320 GPS FPDelegate');

        # tell the GPS C++ code we will do sequencing ourselves, so it can disable
        # its legacy logic for this
        setprop(GPSPath ~ '/config/delegate-sequencing', 1);
		
        # enable 2020.2 C++ turn anticipation
        # setprop(GPSPath ~ '/config/enable-fly-by', 1);
		
		# Set maximum lateral deviation for sequencing to 5 miles
		setprop(GPSPath ~ '/config/overflight-arm-distance', 5);

        # make FlightPlan behaviour match GPS config state
        fp.followLegTrackToFix = getprop(GPSPath ~ '/config/follow-leg-track-to-fix') or 0;

        # similarly, make FlightPlan follow the performance category settings
        fp.aircraftCategory = getprop('/autopilot/settings/icao-aircraft-category') or 'A';

        m._modeProp = props.globals.getNode(GPSPath ~ '/mode');
        return m;
    },

    _landingCheckTimeout: func
    {
        var wow = getprop('gear/gear[0]/wow');
        var gs = getprop('velocities/groundspeed-kt');
        if (wow and (gs < 25))  {
          logprint(LOG_INFO, 'GPS saw speed < 25kts on destination runway, end of route.');
          me.landingCheck.stop();
          # record touch-down time?
          me.flightplan.finish();
        }
    },

    _captureCurrentCourse: func
    {
        var crs = getprop(GPSPath ~ "/desired-course-deg");
        setprop(GPSPath ~ "/selected-course-deg", crs);
    },

    _selectOBSMode: func
    {
        setprop(GPSPath ~ "/command", "obs");
    },

    waypointsChanged: func
    {
    },

    activated: func
    {
        if (!me.flightplan.active)
            return;

        logprint(LOG_INFO,'flightplan activated, default GPS to LEG mode');
        setprop(GPSPath ~ "/command", "leg");

        if (getprop(GPSPath ~ '/wp/wp[1]/from-flag')) {
            logprint(LOG_INFO, '\tat GPS activation, already passed active WP, sequencing');
            me.sequence();
        }
    },

    deactivated: func
    {
        if (me._modeProp.getValue() == 'leg') {
            logprint(LOG_INFO, 'flightplan deactivated, default GPS to OBS mode');
            me._captureCurrentCourse();
            me._selectOBSMode();
        }
    },

    endOfFlightPlan: func
    {
        if (me._modeProp.getValue() == 'leg') {
            logprint(LOG_INFO, 'end of flight-plan, switching GPS to OBS mode');
            me._captureCurrentCourse();
            me._selectOBSMode();
        }
    },

    cleared: func
    {
        if (!me.flightplan.active)
            return;

        if (me._modeProp.getValue() == 'leg') {
            logprint(LOG_INFO, 'flight-plan cleared, switching GPS to OBS mode');
            me._captureCurrentCourse();
            me._selectOBSMode();
        }
    },

    sequence: func
    {
        if (!me.flightplan.active)
            return;
			
		flightPlanController.autoSequencing();
		
        var mode = me._modeProp.getValue();
        if (mode == 'dto') {
            # direct-to is done, check if we should resume the following leg
            var index = me.flightplan.indexOfWP(getprop(GPSPath ~ '/wp/wp[1]/latitude-deg'),
                                                getprop(GPSPath ~ '/wp/wp[1]/longitude-deg'));
            if (index >= 0) {
                logprint(LOG_INFO, "default GPS reached Direct-To, resuming FP leg at " ~ index);
                me.flightplan.current = index + 1;
                setprop(GPSPath ~ "/command", "leg");
            } else {
                # revert to OBS mode
                logprint(LOG_INFO, "default GPS reached Direct-To, resuming to OBS");

                me._captureCurrentCourse();
                me._selectOBSMode();
            }
        } else if (mode == 'leg') {
            # standard leq sequencing
            var nextIndex = me.flightplan.current + 1;
			#if (nextIndex < me.flightplan.numWaypoints() and me.flightplan.nextWP().id == '(DECEL)') {
			#	nextIndex += 1;
            #   logprint(LOG_INFO, "default GPS reached DECEL, going to next waypoint");
			#} 
			
			if (nextIndex >= me.flightplan.numWaypoints()) {
                logprint(LOG_INFO, "default GPS sequencing, finishing flightplan");
                me.flightplan.finish();
            } elsif (me.flightplan.nextWP().wp_type == 'discontinuity') {
                logprint(LOG_INFO, "default GPS sequencing DISCONTINUITY in flightplan, switching to OBS mode");

                me._captureCurrentCourse();
                me._selectOBSMode();
            } else {
                logprint(LOG_INFO, "default GPS sequencing to next WP");
                me.flightplan.current = nextIndex;
            }
        } else {
            # OBS, do nothing
        }
		
    },

    currentWaypointChanged: func
    {
        if (!me.flightplan.active)
            return;

        if (me.landingCheck != nil) {
            me.landingCheck.stop();
            me.landingCheck = nil; # delete timer
        }
		
        var active = me.flightplan.currentWP();
        if (active == nil) return;

        var activeRunway = active.runway();
        # this check is needed to avoid problems with circular routes; when
        # activating the FP we end up here, and without this check, immediately
        # detect that we've 'landed' and finish the FP again.
        var wow = getprop('gear/gear[0]/wow');

        if (!wow and
            (activeRunway != nil) and
            (activeRunway.id == me.flightplan.destination_runway.id))
        {
            me.landingCheck = maketimer(2.0, me, A320GPSDeleagte._landingCheckTimeout);
            me.landingCheck.start();
        }
    }
};

registerFlightPlanDelegate(A320GPSDeleagte.new);

