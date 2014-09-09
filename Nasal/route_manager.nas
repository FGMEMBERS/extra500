# route_manager.nas -  FlightPlan delegate(s) corresponding to the built-
# in route-manager dialog and GPS. Intended to provide a sensible default behaviour, 
# but can be disabled by an aircraft-specific FMS / GPS system.

var RouteManagerDelegate = {
	new: func(fp) {
    # if this property is set, don't build a delegate at all
    #if (getprop('/autopilot/route-manager/disable-route-manager'))
    #    return nil;
        
		var m = { parents: [RouteManagerDelegate] };
		m.flightplan = fp;
		return m;
	},

    departureChanged: func
    {
        debug.dump('saw departure changed');
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
        debug.dump('routing via SID ' ~ sid.id);
        me.flightplan.insertWaypoints(sid.route(me.flightplan.departure_runway), 1);
    },

    arrivalChanged: func
    {
        debug.dump('saw arrival changed');
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
         
        if (me.flightplan.star != nil) {
            debug.dump('routing via STAR ' ~ me.flightplan.star.id);
            var wps = me.flightplan.star.route(me.flightplan.destination_runway);
            me.flightplan.insertWaypoints(wps, -1);
        }
        
        if (me.flightplan.approach != nil) {
            debug.dump('routing via approach ' ~ me.flightplan.approach.id);
            var wps = me.flightplan.approach.route();
            me.flightplan.insertWaypoints(wps, -1);
        } else {
            debug.dump('routing direct to runway ' ~ me.flightplan.destination_runway.id);
            # no approach, just use the runway waypoint
            var wp = createWPFrom(me.flightplan.destination_runway);
            wp.wp_role = 'approach';
            me.flightplan.appendWP(wp);
        }
    },
    
    cleared: func
    {
        debug.dump("saw active flightplan cleared, deactivating");
        # see http://https://code.google.com/p/flightgear-bugs/issues/detail?id=885
        fgcommand("activate-flightplan", props.Node.new({"activate": 0}));
    },
    
    endOfFlightPlan: func
    {
        debug.dump("end of flight-plan, deactivating");
        fgcommand("activate-flightplan", props.Node.new({"activate": 0}));
    }
};


var FMSDelegate = {
	new: func(fp) {
    # if this property is set, don't build a delegate at all
    #if (getprop('/autopilot/route-manager/disable-fms'))
     #   return nil;
            
		var m = { parents: [FMSDelegate], flightplan:fp, landingCheck:nil };
		return m;
	},
    
    _landingCheckTimeout: func
    {
        var wow = getprop('gear/gear[0]/wow');
        var gs = getprop('velocities/groundspeed-kt');
        if (wow and (gs < 25))  {
          debug.dump('touchdown on destination runway, end of route.');
          me.landingCheck.stop();
          # record touch-down time?
          me.flightplan.finish();
        }
    },
    
    waypointsChanged: func
    {
	   debug.dump('FMSDelegate.waypointsChanged() ...'); 
	   setprop("/autopilot/route-manager/signals/waypoint-changed",systime());
    },
    
    endOfFlightPlan: func
    {
      debug.dump('end of flight-plan');
      
    },
    
    currentWaypointChanged: func
    {
	debug.dump('FMSDelegate.currentWaypointChanged() ...');
	setprop("/autopilot/route-manager/signals/current-waypoint-changed",systime());
        if (me.landingCheck != nil) {
            me.landingCheck.stop();
            me.landingCheck = nil; # delete timer
        }
        
        #debug.dump('saw current WP changed, now ' ~ me.flightplan.current);
        var active = me.flightplan.currentWP();
        if (active == nil) return;
        
        if (active.alt_cstr_type != nil) {
            debug.dump('new WP has valid altitude restriction, setting on AP');
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
            me.landingCheck = maketimer(2.0, me, FMSDelegate._landingCheckTimeout);
            me.landingCheck.start();
        }
    }
};

registerFlightPlanDelegate(FMSDelegate.new);
registerFlightPlanDelegate(RouteManagerDelegate.new);

