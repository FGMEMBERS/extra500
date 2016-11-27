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
#	Last change:	Eric van den Berg
#	Date:		27.11.16
#

# internal flightplan
var InternalFlightPlan = {
	new : func(){
		var m = {parents:[InternalFlightPlan],
			isReady 	: 0,
			isUpdated 	: 0,
			destination : {
				bearingCourse 		: 0,
				bearingDistance 	: 0,
				icao			: "",
				name			: "",
				runway	: {
					id : "",
				}
			},
			departure : {
				bearingCourse 		: 0,
				bearingDistance 	: 0,
				icao			: "",
				name			: "",
				runway	: {
					id : "",
				}
			},
			planSize 	: 0,
			wp 		: [],
			currentWp 	: 0 ,
			distanceToGo 	: 0 ,
			fuelAt	 	: 0,
			eta 		: 0,
			ete 		: 0,
		};
		return m;
	},
	
	
};

var InternalFlightPlanData = {
	new : func(){
		var m = {parents:[
			InternalFlightPlanData
			
		]};
		m.index		= 0;		# index inside nasal flightplan
		
		m.id		= "";
		m.name		= "";
		m.lat 		= 0;
		m.lon 		= 0;
		
			
		m.distanceTo 	= 0;
		m.ete 		= 0;
		m.eta 		= 0;
		m.fuelAt 	= 0;
		m.course	= nil;
		m.distance	= nil;
		
		m.type 		= nil;
		m.role 		= nil;
		m.flyType 	= nil;
		
		# Avidyne waypoint data
		m.variant	= "Default"; # Origin,Arrival,Default
		m.sid		= ""; # Sid name
		m.arrival	= ""; # arrival name
		m.approach	= ""; # approach name
		
		m.path 		= nil;
		
		m.constraint = {
			before:{type:nil,value:0},
			alt:{type:nil,value:0},
			#distance:{type:nil,value:0}
		};
		
		
		
		return m;
	},
	setConstrainAlt : func(v){
		me.constraint.alt.value = v;
		me.constraint.alt.type = "at";
		
		fms._nasalFlightPlan.getWP(me.index).setAltitude(me.constraint.alt.value,"at");
	},
	setConstrainAt : func(v){
		me.constraint.alt.type = v;
	},
	setConstrainBefore : func(v){
		me.constraint.before.value = v; 
		me.constraint.before.type = (v > 0 ? 1 : nil);
	},
	
	
};

var FlightManagementSystemClass = {
	new : func(root,name){
		var m = {parents:[
			FlightManagementSystemClass,
			extra500.ServiceClass.new(root,name)
		]};
		
		m._selectedWaypointIndex = -1;
		m._cursorOption = 0;
		m._cursorFocus = 0;
		
		m._routeManagerActive = 0;
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
		
		m._engineRunTime 	= 0;
		m._fuelFlow 		= 0;
		m._fuelLiter 		= 0;
		m._fuelTime 		= 0;
		m._fuelRange 		= 0;
		m._fuelRangeReserve 	= 0;
		m._fuelTimeReserve	= 2700; #sec 45min
		
		
		
		m._signal = {
			fplReady 		: props.globals.initNode("/instrumentation/fms[0]/signal/fpl/ready",0,"BOOL"),
			fplUpdated 		: props.globals.initNode("/instrumentation/fms[0]/signal/fpl/updated",0,"BOOL"),
			fplChange 		: props.globals.initNode("/instrumentation/fms[0]/signal/fpl/change",0,"BOOL"),
			currentWpChange	 	: props.globals.initNode("/instrumentation/fms[0]/signal/fpl/current-waypoint-change",0,"INT"),
			selectedWpChange 	: props.globals.initNode("/instrumentation/fms[0]/signal/fpl/selected-waypoint-change",0,"INT"),
			cursorOptionChange 	: props.globals.initNode("/instrumentation/fms[0]/signal/fpl/cursor-option",0,"INT"),
			cursorFocusChange	: props.globals.initNode("/instrumentation/fms[0]/signal/fpl/cursor-index",0,"INT"),
			
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
			vsrVisible	: props.globals.initNode("/instrumentation/fms[0]/vsrVisible",0,"INT"),
			
			RouteManagerSelection		: props.globals.initNode("/sim/gui/dialogs/route-manager/selection",-1,"INT"),
			
			EngineRunTime		: m._nRoot.initNode("engineRunTime_sec",0,"INT"),
			FuelTime		: m._nRoot.initNode("fuelTime_sec",0,"INT"),
			FuelRange		: m._nRoot.initNode("fuelRange_nm",0,"DOUBLE"),
			FuelRangeReserve	: m._nRoot.initNode("fuelRangeReserve_nm",0,"DOUBLE"),
			
			
		};

		m._nasalFlightPlan 	= nil; 			# the nasal flightplan();
		m._flightPlan 		= InternalFlightPlan.new();	# the internal FlightPlan
		
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
		append(me._listeners, setlistener(me._node.RouteManagerSelection,func(n){me._onSelectionChange(n)},1,0));	
		
	},
	init : func(instance=nil){
		if (instance==nil){instance=me;}
		me.setListeners(instance);
		me._updateTimer.start();
	},
	_onSelectionChange : func(n){
		var index = n.getValue();
		if(index != nil){
			me.setCursorOption(0);
			me.setSelectedWaypoint(index);
			
		}
	},
	#IFD & route Manager selection, called from IFD page_FMS.nas
	setSelectedWaypoint : func(index){
		me._selectedWaypointIndex 	= index; 
		me._signal.selectedWpChange.setValue(me._selectedWaypointIndex);
		me.setCursorFocus(1+index*2);
	},
	setCursorOption : func(index){
		me._cursorOption = index;
		me._signal.cursorOptionChange.setValue(me._cursorOption);
	},
	setCursorFocus : func(index){
		me._cursorFocus = index;
		me._signal.cursorFocusChange.setValue(me._cursorFocus);
		if ( global.odd(index)){
			# only the odd index are Waypoints from the FG flightplan
			me._selectedWaypointIndex = ((index-1) / 2);
			#debug.dump("FlightManagementSystemClass::setCursorFocus ... _selectedWaypointIndex",me._selectedWaypointIndex);
		}else{
			me._selectedWaypointIndex = -1;
		}
		me._signal.selectedWpChange.setValue(me._selectedWaypointIndex);
		
	},
	_onFlightPlanChange : func(n){
		dP.bulk("FlightManagementSystemClass::_onFlightPlanChange() ... ");
		me._nasalFlightPlan = flightplan();
		#updating the flightplan
 		dP.info("FlightManagementSystemClass::_onFlightPlanChange() ... getPlanSize()");
		me._flightPlan.planSize = me._nasalFlightPlan.getPlanSize();
 		dP.info("FlightManagementSystemClass::_onFlightPlanChange() ... current");
		me._flightPlan.currentWpIndex = me._nasalFlightPlan.current;
		#resize the waypoint vector
 		dP.info("FlightManagementSystemClass::_onFlightPlanChange() ... size");
		setsize(me._flightPlan.wp,me._flightPlan.planSize);
				
		# destination bearing
 		# prepair the Procedure data
		dP.info("FlightManagementSystemClass::_onFlightPlanChange() ... Procedure data");
		if (me._nasalFlightPlan.destination != nil){
			var result= courseAndDistance(me._nasalFlightPlan.destination.lat,me._nasalFlightPlan.destination.lon);
			me._flightPlan.destination.bearingCourse 	= result[0];
			me._flightPlan.destination.bearingDistance 	= result[1];
			
			me._flightPlan.destination.icao 	= me._nasalFlightPlan.destination.id;
			me._flightPlan.destination.name 	= me._nasalFlightPlan.destination.name;
			
			if (me._nasalFlightPlan.destination_runway != nil){
				me._flightPlan.destination.runway.id 	= me._nasalFlightPlan.destination_runway.id;
			}
		}
		if (me._nasalFlightPlan.departure != nil){
			me._flightPlan.departure.icao 		= me._nasalFlightPlan.departure.id;
			me._flightPlan.departure.name 		= me._nasalFlightPlan.departure.name;
			if (me._nasalFlightPlan.departure_runway != nil){
				me._flightPlan.departure.runway.id 	= me._nasalFlightPlan.departure_runway.id;
			}
# 		
		}
		
		#dP.bulk("FlightManagementSystemClass::_onFlightPlanChange() ... details");
		for (var i = 0 ; i < me._flightPlan.planSize ; i+=1){
			var fmsWP = me._nasalFlightPlan.getWP(i);
			
			#debug.dump(fmsWP);
			
			me._flightPlan.wp[i] = InternalFlightPlanData.new();
			
			me._flightPlan.wp[i].index			= i;
			me._flightPlan.wp[i].id			 	= fmsWP.id;
			me._flightPlan.wp[i].name		 	= fmsWP.wp_name;
			me._flightPlan.wp[i].type			= fmsWP.wp_type;
			me._flightPlan.wp[i].flyType			= fmsWP.fly_type;
			me._flightPlan.wp[i].role			= fmsWP.wp_role;
			me._flightPlan.wp[i].lat		 	= fmsWP.wp_lat;
			me._flightPlan.wp[i].lon		 	= fmsWP.wp_lon;
			me._flightPlan.wp[i].constraint.alt.type 	= fmsWP.alt_cstr_type;
			me._flightPlan.wp[i].constraint.alt.value	= fmsWP.alt_cstr;
			me._flightPlan.wp[i].path			= fmsWP.path();
						
			if (	(me._flightPlan.wp[i].role == "sid") and 
				( 
					(me._flightPlan.wp[i].type == "navaid") or 
					(me._flightPlan.wp[i].type == "runway")
				)
			   ){
				me._flightPlan.wp[i].variant 	= "Origin";
				if(me._nasalFlightPlan.sid != nil){
					me._flightPlan.wp[i].sid	= me._nasalFlightPlan.sid.id;
				}
			
			
			}elsif(	(me._flightPlan.wp[i].role == "approach") and 
				( 
					(me._flightPlan.wp[i].type == "navaid") or 
					(me._flightPlan.wp[i].type == "runway")
				)
			   ){
				me._flightPlan.wp[i].variant = "Arrival";
				if(me._nasalFlightPlan.star != nil){
					me._flightPlan.wp[i].arrival	= me._nasalFlightPlan.star.id;
				}
				if(me._nasalFlightPlan.approach != nil){
					me._flightPlan.wp[i].approach	= me._nasalFlightPlan.approach.id;
				}
			}else{
				me._flightPlan.wp[i].variant = "Default";
			}	
			
# fixed in flightgear 
# 			if(i>0){
# 				me._flightPlan.wp[i].course			= me._nasalFlightPlan.getWP(i-1).leg_bearing;
# 			}
			
			me._flightPlan.wp[i].course			= fmsWP.leg_bearing;
			me._flightPlan.wp[i].distance			= fmsWP.leg_distance;
			
		}
		
 		dP.info("FlightManagementSystemClass::_onFlightPlanChange() ... signal");
		me._signal.fplChange.setValue(n.getValue());
	},
	_onCurrentWaypointChange : func(n){
 		dP.bulk("FlightManagementSystemClass._onFlightPlanChange() ... ");
		
		me._flightPlan.currentWpIndex = n.getValue();
		if ( me._flightPlan.currentWpIndex >= 0 ) {
#			settimer(func(){me._nextGpssBearing()},1);
			me._nextGpssBearing();
		
		
			if (getprop("/instrumentation/nav-source") == 2 ) {
# getting and setting the frequency in nav1 if new current waypoint is a VOR or destination ILS (course is set in extra500-autopilot.xml)
				var freq = nil;
				var course = nil;
				var currentWP = me._nasalFlightPlan.currentWP();
				if(currentWP != nil){
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
				}
# set frequency
				if (freq != nil) {
					setprop("/instrumentation/nav/frequencies/selected-mhz",freq/100);
				}

			}	
		}else {
			setprop("/autopilot/fms-channel/autotuning/approach",0);
		}
		
		me._node.btnObsMode.setValue(0);
		me._signal.currentWpChange.setValue(me._flightPlan.currentWpIndex);
		
		
	},
	getOriginRunwayList : func(){
		var list = [];
		var runways = me._nasalFlightPlan.departure.runways;
		foreach(var rwy ; keys(runways)){
			append(list,runways[rwy].id);
		}
		return list;
	},
	setOriginRunway : func(rwy){
		dP.bulk(sprintf("FlightManagementSystemClass::setOriginRunway(%s)",rwy));
		me._nasalFlightPlan.departure_runway = me._nasalFlightPlan.departure.runways[rwy];
		setprop("/autopilot[0]/route-manager[0]/departure[0]/runway",rwy);
	},
	getOriginSidList : func(){
		var list = [""];
		var rwy 	= me._nasalFlightPlan.departure_runway;
		var data 	= me._nasalFlightPlan.departure.sids(rwy);
		#debug.dump(rwy,data);
		foreach(var i ; data){
			append(list,i);
		}
		if (size(list)== 1){
			append(list,"DEFAULT");
		}
		return list;
	},
	setOriginSid : func(sid){
		dP.bulk(sprintf("FlightManagementSystemClass::setOriginSid(%s)",sid));
		#me._nasalFlightPlan = flightplan();
		#me._nasalFlightPlan.sid = sid;
		setprop("/autopilot[0]/route-manager[0]/departure[0]/sid",sid);
	},
	getDestinationRunwayList : func(){
		var list = [];
		var data = me._nasalFlightPlan.destination.runways;
		#debug.dump(data);
		foreach(var i ; keys(data)){
			append(list,data[i].id);
		}
		return list;
	},
	setDestinationRunway : func(rwy){
		dP.bulk(sprintf("FlightManagementSystemClass::setDestinationRunway(%s)",rwy));
		#me._nasalFlightPlan = flightplan();
		#me._nasalFlightPlan.destination_runway = me._nasalFlightPlan.destination.runways[rwy];
		setprop("/autopilot[0]/route-manager[0]/destination[0]/runway",rwy);
	},
	getDestinationArrivalList : func(){
		var list = [""];
		var rwy 	= me._nasalFlightPlan.destination_runway;
		var data 	= me._nasalFlightPlan.destination.stars(rwy);
		#debug.dump(rwy,data);
		foreach(var i ; data){
			append(list,i);
		}
		if (size(list)== 1){
			append(list,"DEFAULT");
		}
		return list;
	},
	setDestinationArrival : func(s){
		dP.bulk(sprintf("FlightManagementSystemClass::setDestinationArrival(%s)",s));
		#me._nasalFlightPlan = flightplan();
		#me._nasalFlightPlan.star = s;
		setprop("/autopilot[0]/route-manager[0]/destination[0]/star",s);
	},
	getDestinationApproachList : func(){
		var list = [""];
		var rwy 	= me._nasalFlightPlan.destination_runway;
		var data 	= me._nasalFlightPlan.destination.getApproachList(rwy);
		#debug.dump(rwy,data);
		foreach(var i ; data){
			append(list,i);
		}
		if (size(list)== 1){
			append(list,"DEFAULT");
		}
		return list;
	},
	setDestinationApproach : func(s){
		dP.bulk(sprintf("FlightManagementSystemClass::setDestinationApproach(%s)",s));
		#me._nasalFlightPlan = flightplan();
		#me._nasalFlightPlan.approach = s;
		setprop("/autopilot[0]/route-manager[0]//destination[0]/approach",s);
	},
	
	
	
	_nextGpssBearing : func(){
		
		var nextWpIndex = me._flightPlan.currentWpIndex+1;
		if((nextWpIndex > 0) and (nextWpIndex < me._flightPlan.planSize)){
			var bearing = getprop("/autopilot/route-manager/route/wp["~nextWpIndex~"]/leg-bearing-true-deg");
			#debug.dump(bearing);
			setprop("/autopilot/fms-channel/gpss/next-bearing-deg",bearing);
		}
	},

	# Operation functions of Avidyne FMS 

	deleteWaypoint : func(index=nil){
		if(index != nil){
			me._selectedWaypointIndex = index;
		}
		
		if(me._selectedWaypointIndex > 0){
			me._nasalFlightPlan.deleteWP(me._selectedWaypointIndex);
		}
	},
	insertWaypoint : func(index=nil){
		dP.bulk("FlightManagementSystemClass::insertWaypoint() ... not implemented yet.");
	},

	jumpTo : func(){
		me.checkOBSMode(0);
		if(me._selectedWaypointIndex > 0){
			me._node.CurrentWp.setValue(me._selectedWaypointIndex);
		}
	},
	directTo : func(){# called from keypad.nas
		if(me._routeManagerActive){
			if ( me._directTo ) {
				me._node.DirectTo.setValue(0);
			} else {
				me.checkOBSMode(0);
				if(me._selectedWaypointIndex > 0){
					me._node.CurrentWp.setValue(me._selectedWaypointIndex);
					me._node.DirectTo.setValue(1);
				}
			}
		}
	},
	checkOBSMode : func(active=1){
		
		var nextMode = 	me._btnObsMode 
				and me._routeManagerActive
				and active
				;
		
		if(me._obsMode != nextMode){
			me._obsMode = nextMode;
			if(me._obsMode){
				var wypt = me._nasalFlightPlan.getWP(me._nasalFlightPlan.current);
				
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
		me._routeManagerActive = n.getValue();
		me.checkOBSMode();
	},
	
	
	
	update : func(){
		me._flightPlan.isReady = 0;
		me._flightPlan.isUpdated = 0;
		
		me._dynamicPoint.TOD.visible 	= 0;
		me._dynamicPoint.TOC.visible 	= 0;
		me._dynamicPoint.RTA.visible 	= 0;
		
		me._constraint.VSR.alt 		= 0;
		me._constraint.VSR.distance	= 0;
		me._constraint.VSR.rate		= 0;
		me._constraint.VSR.wptIndex	= 0;
		me._constraint.VSR.visible	= 0;
		
		var gs 			= getprop("/velocities/groundspeed-kt");
		me._fuelLiter		= getprop("/consumables/fuel/total-fuel-m3") * 1000 - 28;
		me._fuellbs			= getprop("/fdm/jsbsim/propulsion/total-fuel-lbs");
		me._fuelFlow		= getprop("/fdm/jsbsim/aircraft/engine/FF-l_h");
		me._fuelFlowlbsh		= getprop("/fdm/jsbsim/aircraft/engine/FF-lbs_h");
		var fuelFlowLpSec 	= me._fuelFlow / 3600.0;
		var phase 			= getprop("/extra500/instrumentation/IFD/perf/phase");
		var currentAlt 		= getprop("/instrumentation/altimeter-IFD-LH/indicated-altitude-ft");
		var altBug 			= getprop("/autopilot/settings/tgt-altitude-ft");
		var distance 		= getprop("/autopilot/route-manager/wp/dist");
		var destAlt 		= getprop("/autopilot/route-manager/destination/field-elevation-ft");
		
		# Fuel calculation
# FIXME: the fuel remaining (and subsequent range calculation is dependent on the initial fuel volume (inputted by pilot) and integrated fuel flow.
# The actual fuel quantity measurement (by sensors in tank) is not available to IFD-s

		# for max range calculations (green range circle), the -50.2 (lbs) is the unusable fuel as the total fuel is total capacity
#TODO: get the current head/tail wind in here!
		extra500.perfIFD.trip(phase,30,"maxpow","fuel",currentAlt,altBug,destAlt,me._fuellbs-50.2,gs,me._fuelFlowlbsh,0,0);
#		extra500.perfIFD.publish(); # only for debug, remove later

		if (extra500.engine.nIsRunning.getValue()){
			me._engineRunTime += 1;
			me._node.EngineRunTime.setValue(me._engineRunTime);
		}

		me._fuelTime = extra500.perfIFD.data.trip.time;
		me._fuelRange = extra500.perfIFD.data.trip.distance;
		me._fuelRangeReserve = 0;

		me._node.FuelTime.setValue(me._fuelTime);
		me._node.FuelRange.setValue(me._fuelRange);
		me._node.FuelRangeReserve.setValue(me._fuelRangeReserve);
		
						
		
		if(me._routeManagerActive){
			me._flightPlan.isReady = 1;
			
			if(me._nasalFlightPlan.destination != nil){
				var result= courseAndDistance(me._nasalFlightPlan.destination.lat,me._nasalFlightPlan.destination.lon);
				me._flightPlan.destination.bearingCourse 	= result[0];
				me._flightPlan.destination.bearingDistance 	= result[1];
			}
		
			# for trip ete,eta and fuel remaining
			var time 				= systime() + getprop("/sim/time/warp");
			var distanceToDest 		= getprop("/autopilot/route-manager/distance-remaining-nm");				
			me._flightPlan.distanceToGo	= distanceToDest;
			extra500.perfIFD.trip(phase,30,"maxpow","distance",currentAlt,altBug,destAlt,distanceToDest,gs,me._fuelFlowlbsh,0,0);
extra500.perfIFD.publish(); # debug only, remove later
			me._flightPlan.ete 		= extra500.perfIFD.data.trip.time;
			me._flightPlan.eta		= time + me._flightPlan.ete;
			me._flightPlan.fuelAt		= (me._fuellbs - 50.2 - extra500.perfIFD.data.trip.fuel)* global.CONST.JETA_LB2L;				

			# fuel and time to each wp in flightplan
			for (var i = 0 ; i < me._flightPlan.planSize ; i+=1){
				if (i >= me._flightPlan.currentWpIndex){
					me._flightPlan.wp[i].distanceTo = getprop("/autopilot/route-manager/route/wp["~i~"]/distance-along-route-nm") - getprop("/autopilot/route-manager/total-distance") + distanceToDest;
					extra500.perfIFD.waypoint(me._flightPlan.wp[i].distanceTo,phase,currentAlt,altBug,gs,me._fuelFlowlbsh,0,0);
					me._flightPlan.wp[i].ete	= extra500.perfIFD.data.waypoint.time;
					me._flightPlan.wp[i].eta 	= time + me._flightPlan.wp[i].ete;
					me._flightPlan.wp[i].fuelAt 	= (me._fuellbs-50.2 - extra500.perfIFD.data.waypoint.fuel)* global.CONST.JETA_LB2L;
				}
			}

		
			if(gs > 15){

				me._dynamicPoint.TOC.distance	= 0;
#				me._dynamicPoint.TOC.rate	= getprop("/instrumentation/ivsi-IFD-LH/indicated-speed-fpm");
				
				me._dynamicPoint.RTA.distance	= 0;
#				me._dynamicPoint.RTA.rate	= me._dynamicPoint.TOC.rate;
							
				
# 				dP.bulk("FlightManagementSystemClass.calcRoute() ... ");
#				var gsSec = gs / 3600;
#				var gsMin = gs / 60;
#				var time 		= systime() + getprop("/sim/time/warp");
#				var fuelGalUs 		= getprop("/consumables/fuel/total-fuel-gal_us");
#				var fuelFlowGalUSpSec 	= extra500.fuelSystem._nFuelFlowGalUSpSec.getValue();
				
				
#				var currentAlt 		= getprop("/instrumentation/altimeter-IFD-LH/indicated-altitude-ft");
#				var altBug 		= getprop("/autopilot/settings/tgt-altitude-ft");
				
#				var distance 		= getprop("/autopilot/route-manager/wp/dist");
				var distanceToGo 	= 0;
#				var ete 		= 0;
#				var eta 		= 0;
#				var fuelAt 		= 0;
#				var fuelLiter 	= me._fuelLiter;
				
				me._constraint.VSR.alt = destAlt;
				
				for (var i = 0 ; i < me._flightPlan.planSize ; i+=1){
# 					
					if (i >= me._flightPlan.currentWpIndex){
					
			#			if(i == me._flightPlan.currentWpIndex){
			#				me._flightPlan.wp[i].distanceTo 	= distance;
			#			}else{
			#				me._flightPlan.wp[i].distanceTo 	= me._flightPlan.wp[i].distance;
			#			}
						
#						distanceToGo 	+= me._flightPlan.wp[i].distanceTo;
#						ete 		 = me._flightPlan.wp[i].distanceTo / gsSec ;
#						eta 		 = time + (distanceToGo / gsSec);
#						fuelAt 		 = (fuelLiter -= fuelFlowLpSec * ete);
						
						
#						me._flightPlan.wp[i].ete	= ete;
#						me._flightPlan.wp[i].eta 	= eta;
#						me._flightPlan.wp[i].fuelAt 	= fuelAt;
						
						
						if ((me._flightPlan.wp[i].constraint.alt.type != nil) and ( me._constraint.VSR.distance == 0 ) ) {
							me._constraint.VSR.alt = me._flightPlan.wp[i].constraint.alt.value;
							me._constraint.VSR.distance = me._flightPlan.wp[i].distanceTo ;
							me._constraint.VSR.wptIndex = i;
							
							if (me._flightPlan.wp[i].constraint.before.type != nil){
								me._constraint.VSR.distance -= me._flightPlan.wp[i].constraint.before.value;
							}
							#dP.bulk(""~fmsWP.wp_name ~" constraint : "~me._flightPlan.wp[i].constraint.alt.type~" "~me._constraint.VSR.alt~" in "~me._constraint.VSR.distance~" nm");
							
						}
						
						
					
						
#					}else{
						
#						me._flightPlan.wp[i].distanceTo 	= 0;
#						me._flightPlan.wp[i].ete		= 0;
#						me._flightPlan.wp[i].eta 	= 0;
#						me._flightPlan.wp[i].fuelAt 	= 0;
						
					}
						
				}
#				me._flightPlan.distanceToGo	= distanceToGo;
#				me._flightPlan.ete		= distanceToGo / gsSec ;
#				me._flightPlan.eta		= time + me._flightPlan.ete;
#				me._flightPlan.fuelAt		= me._fuelLiter;

							
				
				if(me._constraint.VSR.distance == 0){
					me._constraint.VSR.wptIndex = me._flightPlan.planSize-1;
					me._constraint.VSR.distance = me._flightPlan.wp[me._constraint.VSR.wptIndex].distanceTo ;
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
					extra500.perfIFD.descent(phase,altBug,me._constraint.VSR.alt,currentAlt,gs,currentFF=0,windSp=0); # calculating distance to of the descent to the waypoint (with altitude restraint)
					me._dynamicPoint.TOD.distance = extra500.perfIFD.data.descent.distance ;
#					me._dynamicPoint.TOD.distance = (altToGo / me._dynamicPoint.TOD.rate) * gsMin ;
					me._dynamicPoint.TOD.position = me._nasalFlightPlan.pathGeod(me._constraint.VSR.wptIndex, -me._dynamicPoint.TOD.distance);
					me._dynamicPoint.TOD.visible = legMode;
				}
				
				# me._dynamicPoint.TOC 
#				if (me._dynamicPoint.TOC.rate > 0 and altToGo >= 150){
				if (altToGo >= 150){
					extra500.perfIFD.climb(phase,currentAlt,me._constraint.VSR.alt,gs,currentFF=0,windSp=0,TDISA=0); # calculating distance to of the climb to the waypoint (with altitude restraint)
					me._dynamicPoint.TOC.distance = extra500.perfIFD.data.climb.distance ;
#					me._dynamicPoint.TOC.distance = me._constraint.VSR.distance - (altToGo / me._dynamicPoint.TOC.rate) * gsMin ;
					me._dynamicPoint.TOC.position = me._nasalFlightPlan.pathGeod(me._constraint.VSR.wptIndex, -me._dynamicPoint.TOC.distance);
					me._dynamicPoint.TOC.visible = legMode and (me._dynamicPoint.TOC.distance < me._flightPlan.wp[me._constraint.VSR.wptIndex].distanceTo);
				}
				
				# me._dynamicPoint.RTA Range to Altitude
				var difAltBug = altBug - currentAlt;
				if ( ( phase == "climb") and (difAltBug >= 150) ) {
					me._dynamicPoint.RTA.distance = distanceToDest - extra500.perfIFD.data.trip.distToAlt ;
					me._dynamicPoint.RTA.position = me._nasalFlightPlan.pathGeod(me._flightPlan.planSize-1, -me._dynamicPoint.RTA.distance);
					me._dynamicPoint.RTA.visible = legMode and (me._dynamicPoint.RTA.distance > 0);
				} else if (	( phase == "descent") and (difAltBug <= -150) ) {
					extra500.perfIFD.descent(phase,0,altBug,currentAlt,gs,currentFF=0,windSp=0); # calculating distance to where in the descent the alt bug altitude is reached
					me._dynamicPoint.RTA.distance = distanceToDest - extra500.perfIFD.data.descent.distance ; # distance calculated backwards from end of flightplan
					me._dynamicPoint.RTA.position = me._nasalFlightPlan.pathGeod(me._flightPlan.planSize-1, -me._dynamicPoint.RTA.distance);
					me._dynamicPoint.RTA.visible = legMode and (me._dynamicPoint.RTA.distance > 0);
				}	

#				var difAltBug = altBug - currentAlt;
#				if ((me._dynamicPoint.RTA.rate <= -100 or me._dynamicPoint.RTA.rate >= 100) and (difAltBug >= 150 or difAltBug <= -150)){
#					me._dynamicPoint.RTA.distance = distanceToDest - extra500.perfIFD.data.trip.distToAlt ;
#					me._dynamicPoint.RTA.distance = distanceToDest - math.abs((difAltBug / me._dynamicPoint.RTA.rate) * gsMin) ;
#					me._dynamicPoint.RTA.position = me._nasalFlightPlan.pathGeod(me._flightPlan.planSize-1, -me._dynamicPoint.RTA.distance);
#					me._dynamicPoint.RTA.visible = legMode and (me._dynamicPoint.RTA.distance > 0);
#				}
				
				
				me._flightPlan.isUpdated = 1;
				
				#for debug deploy to property-tree not needed
				#me._nFlightPan.setValues(me._flightPlan);
			}else{
				
			}
			
		}

		me._node.vsrVisible.setValue(me._constraint.VSR.visible);	
		me._node.vsrRate.setValue(me._constraint.VSR.rate);
		
		me._signal.fplReady.setValue(me._flightPlan.isReady);
		if(me._flightPlan.isUpdated){
			me._signal.fplUpdated.setValue(1);
		}
	},
};

var fms = FlightManagementSystemClass.new("extra500/instrumentation/FMS","FMS");
