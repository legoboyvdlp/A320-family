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

var RouteManagerDelegate = {
    new: func(fp) {
    # if this property is set, don't build a delegate at all
    if (getprop('/autopilot/route-manager/disable-route-manager'))
        return nil;

        var m = { parents: [RouteManagerDelegate] };
        m.flightplan = fp;
        return m;
    },

    departureChanged: func
    {
        logprint(LOG_INFO, 'saw departure changed');
        me.flightplan.clearWPType('sid');
        if (me.flightplan.departure == nil)
            return;

        if (me.flightplan.departure_runway == nil) {
        # no runway, only an airport, use that
            var wp = createWPFrom(me.flightplan.departure);
            wp.wp_role = 'sid';
            me.flightplan.insertWP(wp, 0);
            return;
        }
    # first, insert the runway itself
        var wp = createWPFrom(me.flightplan.departure_runway);
        wp.wp_role = 'sid';
        me.flightplan.insertWP(wp, 0);
        if (me.flightplan.sid == nil)
            return;

    # and we have a SID
        var sid = me.flightplan.sid;
        logprint(LOG_INFO, 'routing via SID ' ~ sid.id);
        me.flightplan.insertWaypoints(sid.route(me.flightplan.departure_runway, me.flightplan.sid_trans), 1);
    },

    arrivalChanged: func
    {
        me.flightplan.clearWPType('star');
        me.flightplan.clearWPType('approach');
        if (me.flightplan.destination == nil)
            return;

        if (me.flightplan.destination_runway == nil) {
        # no runway, only an airport, use that
            var wp = createWPFrom(me.flightplan.destination);
            wp.wp_role = 'approach';
            me.flightplan.appendWP(wp);
            return;
        }

        var initialApproachFix = nil;
        if (me.flightplan.star != nil) {
            logprint(LOG_INFO, 'routing via STAR ' ~ me.flightplan.star.id);
            var wps = me.flightplan.star.route(me.flightplan.destination_runway, me.flightplan.star_trans);
            if (wps != nil) {
                me.flightplan.insertWaypoints(wps, -1);
                initialApproachFix = wps[-1]; # final waypoint of STAR
            }
        }

        if (me.flightplan.approach != nil) {
            var wps = nil;
            var approachIdent = me.flightplan.approach.id;

            if (me.flightplan.approach_trans != nil) {
                # if an approach transition was specified, let's use it explicitly
                wps = me.flightplan.approach.route(me.flightplan.destination_runway, me.flightplan.approach_trans);
                if (wps == nil) {
                    logprint(LOG_WARN, "couldn't route approach " ~ approachIdent ~ " based on specified transition:" ~ me.flightplan.approach_trans);
                }
            } else if (initialApproachFix != nil) {
                # no explicit approach transition, let's use the IAF to guess one
                wps = me.flightplan.approach.route(me.flightplan.destination_runway, initialApproachFix);
                if (wps == nil) {
                    logprint(LOG_INFO, "couldn't route approach " ~ approachIdent ~ " based on IAF:" ~ initialApproachFix.wp_name);
                }
            }

            # depending on the order the user selects the approach or STAR, we might get into
            # a mess here. If we failed to route so far, just try a direct to the approach
            if (wps == nil) {
                # route direct
                 wps = me.flightplan.approach.route(me.flightplan.destination_runway);
            }

            if (wps == nil) {
                logprint(LOG_WARN, 'routing via approach ' ~ approachIdent ~ ' failed entirely.');
            } else {
                me.flightplan.insertWaypoints(wps, -1);
            }
        } else {
            # no approach, just use the runway waypoint
            var wp = createWPFrom(me.flightplan.destination_runway);
            wp.wp_role = 'approach';
            me.flightplan.appendWP(wp);
        }
    },

    cleared: func
    {
        logprint(LOG_INFO, "saw active flightplan cleared, deactivating");
        # see http://https://code.google.com/p/flightgear-bugs/issues/detail?id=885
        fgcommand("activate-flightplan", props.Node.new({"activate": 0}));
    },

    endOfFlightPlan: func
    {
        logprint(LOG_INFO, "end of flight-plan, deactivating");
        fgcommand("activate-flightplan", props.Node.new({"activate": 0}));
    }
};

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

var DefaultGPSDeleagte = {
    new: func(fp) {
        # if this property is set, don't build a delegate at all
        if (getprop('/autopilot/route-manager/disable-fms'))
            return nil;

        var m = { parents: [DefaultGPSDeleagte], flightplan:fp, landingCheck:nil };

        logprint(LOG_INFO, 'creating default GPS FPDelegate');

        # tell the GPS C++ code we will do sequencing ourselves, so it can disable
        # its legacy logic for this
        setprop(GPSPath ~ '/config/delegate-sequencing', 1);

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

        #logprint(LOG_INFO, 'saw current WP changed, now ' ~ me.flightplan.current);
        var active = me.flightplan.currentWP();
        if (active == nil) return;

        if (active.alt_cstr_type == "at") {
            logprint(LOG_INFO, 'Default GPS: new WP has valid altitude restriction, setting on AP');
            setprop('/autopilot/settings/target-altitude-ft', active.alt_cstr);
        }

        var activeRunway = active.runway();
        # this check is needed to avoid problems with circular routes; when
        # activating the FP we end up here, and without this check, immediately
        # detect that we've 'landed' and finish the FP again.
        var wow = getprop('gear/gear[0]/wow');

        if (!wow and
            (activeRunway != nil) and
            (activeRunway.id == me.flightplan.destination_runway.id))
        {
            me.landingCheck = maketimer(2.0, me, DefaultGPSDeleagte._landingCheckTimeout);
            me.landingCheck.start();
        }
    }
};

registerFlightPlanDelegate(DefaultGPSDeleagte.new);
registerFlightPlanDelegate(RouteManagerDelegate.new);

