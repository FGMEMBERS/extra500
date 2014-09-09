#    This file is part of extra500
#
#    extra500 is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 2 of the License, or
#    (at your option) any later version.
#
#    extra500 is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with extra500.  If not, see <http://www.gnu.org/licenses/>.
#
#      Authors: Dirk Dittmann
#      Date: 07.06.2014
#
#      Last change:      Eric van den Berg 
#      Date:             21.06.2014
#

var FlightManagementSystemClass = {
	new : func(root,name){
		var m = {parents:[
			FlightManagementSystemClass,
			extra500.ServiceClass.new(root,name)
		]};
		m._selectedWaypointIndex = 0;
		m._fplActive = 0;
		m._nRoute 		= props.globals.getNode("/autopilot/route-manager/route",1);
		m._nFlightPan		= m._nRoot.initNode("FlightPlan");
		
		m._obsMode = 0;
		m._dtoModeLast = 0;
		m._btnObsMode = 0;
		m._gpssMode = 0;
		m._gpssInTurn = 0;
		
		m._flyVectors = 0;
		m._flyVectorsBtn = 0;
		m._directTo = 0;
		m._directToBtn = 0;
		
		m._destinationCourseDistance = [0,0];
		
		m._signal = {
			fplReady	: props.globals.initNode("/instrumentation/fms[0]/signal/fpl-ready",0,"BOOL"),
			fplUpdated	: props.globals.initNode("/instrumentation/fms[0]/signal/fpl-updated",0,"BOOL"),
			fplChange	: props.globals.initNode("/instrumentation/fms[0]/signal/fpl-change",0,"BOOL"),
			currentWpChange	: props.globals.initNode("/instrumentation/fms[0]/signal/fpl-current-waypoint-change",0,"INT"),
			
		};
		
		m._node = {
			btnObsMode	: props.globals.initNode("/instrumentation/fms[0]/btn-obs-mode",m._btnObsMode,"BOOL"),
			btnFlyVectors	: props.globals.initNode("/instrumentation/fms[0]/btn-FlyVectors",m._flyVectors,"BOOL"),
			btnDirectTo	: props.globals.initNode("/instrumentation/fms[0]/btn-DirectTo",m._flyVectors,"BOOL"),
			
			DirectTo	: props.globals.initNode("/autopilot/settings/dto-leg",0,"BOOL"),
			ObsMode		: props.globals.initNode("/autopilot/settings/obs-mode",0,"BOOL"),
			FlyVector	: props.globals.initNode("/autopilot/settings/fly-vector",0,"BOOL"),
			CurrentWp	: props.globals.initNode("/autopilot/route-manager/current-wp",0,"INT"),
			vsrRate		: props.globals.initNode("/instrumentation/fms[0]/vsr",0,"INT"),
		};

		m._fpl 		= nil; # the nasal flightplan();
		m._fightPlan 	= {
			isReady 	: 0,
			isUpdated 	: 0,
			destination : {
				bearingCourse 		: 0,
				bearingDistance 	: 0,
			},
			planSize 	: 0,
			wp 		: [],
			currentWp 	: 0 ,
			distanceToGo 	: 0 ,
			fuelAt	 	: 0,
			eta 		: 0,
			ete 		: 0,
			
		};
		
		m._dynamicPoint = {
			TOD : {
				position 	: {lat:0,lon:0},
				distance	: 0,
				rate		: -1600,
				visible		: 0,
			},
			TOC : {
				position 	: {lat:0,lon:0},
				distance	: 0,
				rate		: 0,
				visible		: 0,
			},
			RTA : {
				position 	: {lat:0,lon:0},
				distance	: 0,
				rate		: 0,
				visible		: 0,
			},
		};
		
		m._constraint = {
			VSR : {
				alt 		: 0,
				distance	: 0,
				rate		: 0,
				wptIndex	: 0,
				visible		: 0,
			},
		};
		
		m._updateTimer = maketimer(1.0,m,FlightManagementSystemClass.update);
		return m;
	},
	setListeners : func(instance) {
		append(me._listeners, setlistener("/autopilot/route-manager/signals/waypoint-changed",func(n){me._onFlightPlanChange(n);},1,0) );
		append(me._listeners, setlistener(me._node.CurrentWp,func(n){me._onCurrentWaypointChange(n);},1,0) );
		append(me._listeners, setlistener("/autopilot/route-manager/active",func(n){me._onFPLActiveChange(n);},1,0) );
		append(me._listeners, setlistener(me._node.btnObsMode,func(n){me._onObsModeBtnChange(n);},1,0) );
		append(me._listeners, setlistener(me._node.ObsMode,func(n){me._onObsModeChange(n);},1,0) );
		append(me._listeners, setlistener(me._node.FlyVector,func(n){me._onFlyVectorsChange(n);},1,0) );
		append(me._listeners, setlistener(me._node.DirectTo,func(n){me._onDirectToChange(n);},1,0) );
		append(me._listeners, setlistener(extra500.autopilot.nModeNavGpss,func(n){me._onGPSSChange(n);},1,0) );
		append(me._listeners, setlistener("/autopilot/fms-channel/gpss/in-turn",func(n){me._onGPSSInTurnChange(n);},1,0) );
	},
	init : func(instance=nil){
		if (instance==nil){instance=me;}
		me.setListeners(instance);
		me._updateTimer.start();
	},
	#IFD & route Manager selection, called from IFD page_FMS.nas
	setSelectedWaypoint : func(index){
		me._selectedWaypointIndex = index;
	},
	_onFlightPlanChange : func(n){
# 		print("FlightManagementSystemClass._onFlightPlanChange() ... ");
		me._fpl = flightplan();
		#updating the flightplan
		me._fightPlan.planSize = me._fpl.getPlanSize();
		me._fightPlan.currentWp = me._fpl.current;
		#resize the waypoint vector
		setsize(me._fightPlan.wp,me._fightPlan.planSize);
				
		#destination bearing
		if(me._fpl.destination != nil){
			var result= courseAndDistance(me._fpl.destination.lat,me._fpl.destination.lon);
			me._fightPlan.destination.bearingCourse 	= result[0];
			me._fightPlan.destination.bearingDistance 	= result[1];
		}
		me._signal.fplChange.setValue(n.getValue());
	},
	_onCurrentWaypointChange : func(n){
# 		print("FlightManagementSystemClass._onFlightPlanChange() ... ");
		
		me._fightPlan.currentWp = n.getValue();
		if ( me._fightPlan.currentWp >= 0 ) {
#			settimer(func(){me._nextGpssBearing()},1);
			me._nextGpssBearing();
		
		
		
# getting and setting the frequency in nav1 if new current waypoint is a VOR or destination ILS (course is set in extra500-autopilot.xml)
			var freq = nil;
			var course = nil;
			var currentWP = me._fpl.currentWP();
			if (currentWP.wp_role == "approach") {
# is approach, looking for ILS freq
				var apt = airportinfo(getprop("/autopilot/route-manager/destination/airport"));
				var ils = apt.runways[getprop("/autopilot/route-manager/destination/runway")].ils;
				if(ils != nil){
					freq = ils.frequency;
					course = ils.course ;
# set course
					if (course != nil) {
						course = geo.normdeg( course- getprop("/environment/magnetic-variation-deg"));
						setprop("/autopilot/fms-channel/autotuning/approach",1);
						setprop("/instrumentation/nav/radials/selected-deg",course);
					}
				}
				
			} else {
				setprop("/autopilot/fms-channel/autotuning/approach",0);
# looking for VOR 
				var navaid = navinfo("vor",currentWP.id);
				if (size(navaid) != 0 ) {
					freq = navaid[0].frequency;
				}
			}
# set frequency
			if (freq != nil) {
				setprop("/instrumentation/nav/frequencies/selected-mhz",freq/100);
			}

			
		}else {
			setprop("/autopilot/fms-channel/autotuning/approach",0);
		}
		
		me._node.btnObsMode.setValue(0);
		me._signal.currentWpChange.setValue(me._fightPlan.currentWp);
		
		
	},
	_nextGpssBearing : func(){
		setprop("/autopilot/fms-channel/gpss/next-bearing-deg",getprop("/autopilot/route-manager/route/wp["~me._fightPlan.currentWp~"]/leg-bearing-true-deg"));
	},
	# Operation functions of Avidyne FMS 
	jumpTo : func(){
		me.checkOBSMode(0);
		me._node.CurrentWp.setValue(me._selectedWaypointIndex);
	},
	directTo : func(){# called from keypad.nas
		if(me._fplActive){
			if ( me._directTo ) {
				me._node.DirectTo.setValue(0);
			} else {
				me.checkOBSMode(0);
				
				me._node.CurrentWp.setValue(me._selectedWaypointIndex);
				me._node.DirectTo.setValue(1);
			}
		}
	},
	checkOBSMode : func(active=1){
		
		var nextMode = 	me._btnObsMode 
				and me._fplActive
				and active
				;
		
		if(me._obsMode != nextMode){
			me._obsMode = nextMode;
			if(me._obsMode){
				var wypt = me._fpl.getWP(me._fpl.current);
				
				var nGPS0 = props.globals.getNode("/instrumentation/gps[0]/scratch", 1);
				var nGPS1 = props.globals.getNode("/instrumentation/gps[1]/scratch", 1);
				
				nGPS0.setValues({
					"latitude-deg"	: wypt.lat,
					"longitude-deg"	: wypt.lon,
					"ident"		: wypt.id,
					"type"		: 'WPT',
				});
				
				nGPS1.setValues({
					"latitude-deg"	: wypt.lat,
					"longitude-deg"	: wypt.lon,
					"ident"		: wypt.id,
					"type"		: 'WPT',
				});
				
				setprop("/instrumentation/gps[0]/command","obs");
				setprop("/instrumentation/gps[1]/command","obs");
				
				me._dtoModeLast = me._directTo;
				
				me._node.DirectTo.setValue(0);
				me._node.ObsMode.setValue(1);

			}else{
				me._node.ObsMode.setValue(0);
				me._node.DirectTo.setValue(me._dtoModeLast);
				
				setprop("/instrumentation/gps[0]/command","leg");
				setprop("/instrumentation/gps[1]/command","leg");
				
			}
		}
		
	},
	flyVectors : func(){
		if ( ( getprop("/autopilot/route-manager/active") == 1 ) and ( getprop("/instrumentation/nav-source") == 2 ) and ( getprop("/autopilot/mode/nav") == 1 ) ) {
			me._node.FlyVector.setValue(me._flyVectors==0);
		}
	},
	
	_onDirectToChange : func(n){
		me._directTo = n.getValue();
	},
	_onFlyVectorsChange : func(n){
		me._flyVectors = n.getValue();
	},
	_onObsModeBtnChange : func(n){
		me._btnObsMode = n.getValue();
		me.checkOBSMode();
	},
	_onObsModeChange : func(n){
		me._obsMode = n.getValue();
	},
		
	
	_onGPSSInTurnChange : func(n){
		me._gpssInTurn = n.getValue();
		if(me._gpssInTurn == 1){
			#me._node.btnObsMode.setValue(0);
		}
		
	},
	_onGPSSChange : func(n){
		me._gpssMode = n.getValue();
		#me.checkOBSMode();
	},
	_onFPLActiveChange : func(n){
		me._fplActive = n.getValue();
		me.checkOBSMode();
	},
	update : func(){
		me._fightPlan.isReady = 0;
		me._fightPlan.isUpdated = 0;
		
		me._dynamicPoint.TOD.visible 	= 0;
		me._dynamicPoint.TOC.visible 	= 0;
		me._dynamicPoint.RTA.visible 	= 0;
		
		me._constraint.VSR.alt 		= 0;
		me._constraint.VSR.distance	= 0;
		me._constraint.VSR.rate		= 0;
		me._constraint.VSR.wptIndex	= 0;
		me._constraint.VSR.visible	= 0;
		
		if(me._fplActive){
			me._fightPlan.isReady = 1;
			
			if(me._fpl.destination != nil){
				var result= courseAndDistance(me._fpl.destination.lat,me._fpl.destination.lon);
				me._fightPlan.destination.bearingCourse 	= result[0];
				me._fightPlan.destination.bearingDistance 	= result[1];
			}
		
						
			var gs = getprop("/velocities/groundspeed-kt");
			if(gs > 15){
				
				me._dynamicPoint.TOC.distance	= 0;
				
				me._dynamicPoint.TOC.distance	= 0;
				me._dynamicPoint.TOC.rate	= getprop("/instrumentation/ivsi-IFD-LH/indicated-speed-fpm");
				
				me._dynamicPoint.RTA.distance	= 0;
				me._dynamicPoint.RTA.rate	= me._dynamicPoint.TOC.rate;
							
				
# 				print("FlightManagementSystemClass.calcRoute() ... ");
				var gsSec = gs / 3600;
				var gsMin = gs / 60;
				var time 		= systime() + getprop("/sim/time/warp");
				var fuelGalUs 		= getprop("/consumables/fuel/total-fuel-gal_us");
				var fuelFlowGalUSpSec 	= extra500.fuelSystem._nFuelFlowGalUSpSec.getValue();
				var currentAlt 		= getprop("/instrumentation/altimeter-IFD-LH/indicated-altitude-ft");
				var altBug 		= getprop("/autopilot/settings/tgt-altitude-ft");
				
				var distance 		= getprop("/autopilot/route-manager/wp/dist");
				var distanceToGo 	= distance;
				var ete 		= distance / gsSec ;
				var eta 		= time + ete;
				var fuelAt 		= fuelGalUs -= fuelFlowGalUSpSec * ete;
				
				me._constraint.VSR.alt = getprop("/autopilot/route-manager/destination/field-elevation-ft");
				
				for (var i = 0 ; i < me._fightPlan.planSize ; i+=1){
					var fmsWP = me._fpl.getWP(i);
					me._fightPlan.wp[i] = {};
					me._fightPlan.wp[i].altConstrainType 	= fmsWP.alt_cstr_type;
					me._fightPlan.wp[i].altConstrain	= fmsWP.alt_cstr;
					
					
					if (i >= me._fightPlan.currentWp){
					
						me._fightPlan.wp[i].distanceTo 	= distance;
						me._fightPlan.wp[i].ete		= ete;
						me._fightPlan.wp[i].eta 	= eta;
						me._fightPlan.wp[i].fuelAt 	= fuelAt;
						
						distance 			= fmsWP.leg_distance;
																			
						if ((fmsWP.alt_cstr_type != nil) and ( me._constraint.VSR.distance == 0 ) ) {
							me._constraint.VSR.alt = fmsWP.alt_cstr;
							me._constraint.VSR.distance = distanceToGo;
							me._constraint.VSR.wptIndex = i;
							#print(""~fmsWP.wp_name ~" constraint : "~fmsWP.alt_cstr_type~" "~me._constraint.VSR.alt~" in "~me._constraint.VSR.distance~" nm");
							
						}
					
						# count data for the next waypoint
						distanceToGo += distance;
						ete = distance / gsSec ;
						eta = time + (distanceToGo / gsSec);
						fuelAt = fuelGalUs -= fuelFlowGalUSpSec * ete;
					}else{
						
						me._fightPlan.wp[i].distanceTo 	= 0;
						me._fightPlan.wp[i].ete		= 0;
						me._fightPlan.wp[i].eta 	= 0;
						me._fightPlan.wp[i].fuelAt 	= 0;
						
					}
						
				}
				
				me._fightPlan.distanceToGo	= distanceToGo;
				me._fightPlan.ete		= distanceToGo / gsSec ;
				me._fightPlan.eta		= time + (distanceToGo / gsSec);
				me._fightPlan.fuelAt		= fuelGalUs;
							
				
				if(me._constraint.VSR.distance == 0){
					me._constraint.VSR.wptIndex = me._fightPlan.planSize-1;
					me._constraint.VSR.distance = distanceToGo;
				}
				var altToGo = (me._constraint.VSR.alt - currentAlt);
				
				#			ft	/	min
				if(altToGo <= -100 or altToGo >= 100){
					me._constraint.VSR.rate =  altToGo / ((me._constraint.VSR.distance / gs) * 60 );
					me._constraint.VSR.rate = math.floor((me._constraint.VSR.rate+50)/100) * 100; 
					me._constraint.VSR.rate = global.clamp(me._constraint.VSR.rate,-1600,1600);
					me._constraint.VSR.visible = 1;
				}
				
				var legMode = (me._obsMode == 0) and (me._directTo == 0) and (me._flyVectors == 0);
				
				# me._dynamicPoint.TOD 
				if(altToGo <= -150){
					me._dynamicPoint.TOD.distance = (altToGo / me._dynamicPoint.TOD.rate) * gsMin ;
					me._dynamicPoint.TOD.position = me._fpl.pathGeod(me._constraint.VSR.wptIndex, -me._dynamicPoint.TOD.distance);
					me._dynamicPoint.TOD.visible = legMode;
				}
				
				# me._dynamicPoint.TOC 
				if (me._dynamicPoint.TOC.rate > 0 and altToGo >= 150){
					me._dynamicPoint.TOC.distance = me._constraint.VSR.distance - (altToGo / me._dynamicPoint.TOC.rate) * gsMin ;
					me._dynamicPoint.TOC.position = me._fpl.pathGeod(me._constraint.VSR.wptIndex, -me._dynamicPoint.TOC.distance);
					me._dynamicPoint.TOC.visible = legMode;
				}
				
				# me._dynamicPoint.RTA Range to Altitude
				var difAltBug = altBug - currentAlt;
				if ((me._dynamicPoint.RTA.rate <= -100 or me._dynamicPoint.RTA.rate >= 100) and (difAltBug >= 150 or difAltBug <= -150)){
					me._dynamicPoint.RTA.distance = distanceToGo - math.abs((difAltBug / me._dynamicPoint.RTA.rate) * gsMin) ;
					me._dynamicPoint.RTA.position = me._fpl.pathGeod(-1, -me._dynamicPoint.RTA.distance);
					me._dynamicPoint.RTA.visible = legMode and (me._dynamicPoint.RTA.distance > 0);
				}
				
				
				me._fightPlan.isUpdated = 1;
				
				#for debug deploy to property-tree not needed
				#me._nFlightPan.setValues(me._fightPlan);
			}else{
				
			}
			
		}
		
		me._node.vsrRate.setValue(me._constraint.VSR.rate);
		
		me._signal.fplReady.setValue(me._fightPlan.isReady);
		if(me._fightPlan.isUpdated){
			me._signal.fplUpdated.setValue(1);
		}
	},
};

var fms = FlightManagementSystemClass.new("extra500/instrumentation/FMS","FMS");
