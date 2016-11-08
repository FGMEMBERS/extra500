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
#      Authors: Eric van den Berg
#      Date: 04.04.2016
#
#      Last change: Eric van den Berg     
#      Date: 07.11.2016            
#

var loadPerformanceTables = func(path=""){
	if(path == ""){
		path = getprop("/sim/aircraft-dir") ~ "/Nasal/performanceTables.nas";
	}
	
	io.load_nasal(path,"extra500");
		
}
# load the default Performance Tables file. into var performanceTable
loadPerformanceTables();

var PerfClass = {
	new : func(root,name){
		var m = {parents:[PerfClass],
		_root		: root,
		};
		# output structure to hold the calculated values 
		m.data = {
			rCode: -1 , # of trip
			# flight the sum of all phases
			trip	: {
				time	 	: 0,	# sec
				fuel	 	: 0,	# lbs
				distance 	: 0	# nm
			},
			startupTaxi :  {
				rCode		: -1,
				fuel		: 30	# lbs
			},
			climb : {
				rCode		: -1,
				time	 	: 0,	# sec
				fuel	 	: 0,	# lbs
				distance 	: 0	# nm
			},
			cruise : {
				rCode		: -1,
				speed		: 0,	# kts
				fuelFlow	: 0,	# lbs/h
				time	 	: 0,	# sec
				fuel	 	: 0,	# lbs
				distance 	: 0	# nm
			},
			descent : {
				rCode		: -1,
				time	 	: 0,	# sec
				fuel	 	: 0,	# lbs
				distance 	: 0	# nm
			}
		};
		m._listeners = [];

		return m;
	},
	init : func(instance=nil){
		if (instance==nil){instance=me;}
		me.setListeners(instance);
	},
	setListeners : func(instance) {
		append(me._listeners, setlistener("/sim/time/real/minute",func(){me._detectFlightPhase();},0,0) );
	},
#-------------------------------------------------------------------------
# DETECT FLIGHT PHASE-----------------------------------------------------
#
# detects taxi/startup, climb, cruise or descent
# input: the altitude and airspeed source properties
#
	initFlightPhase : func(altitude="/position/altitude-ft",airspeed="/velocities/airspeed-kt") {
		setprop(me._root,"data/altitude-source",altitude);
		setprop(me._root,"data/airspeed-source",airspeed);
		setprop(me._root,"data/old-altitude",getprop(altitude));
	},
	_detectFlightPhase : func() {

		var source_prop_alt = getprop(me._root,"data/altitude-source");
		var source_prop_speed = getprop(me._root,"data/airspeed-source");

		if (source_prop_alt == nil){ 
			source_prop_alt = "/position/altitude-ft";
			setprop(me._root,"data/altitude-source",source_prop_alt);
		 }
		if (source_prop_speed == nil){ 
			source_prop_speed = "/velocities/airspeed-kt"; 
			setprop(me._root,"data/airspeed-source",source_prop_speed);
		}

		var old_altitude = getprop(me._root,"data/old-altitude");
		var new_altitude = getprop(source_prop_alt);
		setprop(me._root,"data/new-altitude",new_altitude );

		if (old_altitude == nil) {old_altitude = new_altitude;}

		var phase = "off";

		var alt_diff = new_altitude-old_altitude;
		if ( math.abs(alt_diff) < 100 ) {
			if (getprop(source_prop_speed) < 1) {
				setprop(me._root,"phase","off" ); 
			} else if (getprop(source_prop_speed) < 40) {
				setprop(me._root,"phase","startupTaxi" ); 
			} else {
				setprop(me._root,"phase","cruise" ); 
			}
		} else if (alt_diff > 0) {
			setprop(me._root,"phase","climb" ); 
		} else {
			setprop(me._root,"phase","descent" ); 
		}

		setprop(me._root,"data/old-altitude",new_altitude);
	},


#-----------------------------------------------------------------------
# UPDATE TRIP ----------------------------------------------------------
#-----------------------------------------------------------------------
# adds parameters (time, distance, fuel) from all flight phases and publishes

	updateTrip : func() {
		var flightTime = me.data.cruise.time 	+ me.data.climb.time 		+ me.data.descent.time ; #sec
		var flightFuel = me.data.startupTaxi.fuel + me.data.cruise.fuel 		+ me.data.climb.fuel + me.data.descent.fuel; #lbs
		var flightDist = me.data.cruise.distance 	+ me.data.climb.distance 	+ me.data.descent.distance; # nm

		if (flightTime < 0) {flightTime=0;}
		if (flightFuel < 0) {flightFuel=0;}
		if (flightDist < 0) {flightDist=0;}

		me.data.trip.time 	= flightTime;
		me.data.trip.fuel 	= flightFuel;
		me.data.trip.distance 	= flightDist;

	},
	
	# publish the calculated value to the property tree
	publish : func(phase="all"){
		if (phase == "startupTaxi" or phase == "all"){
			setprop(me._root,"startupTaxi/fuel-lbs",me.data.startupTaxi.fuel);
		}
		if (phase == "climb" or phase == "all"){
			setprop(me._root,"climb/timeToAlt-s",me.data.climb.time);
			setprop(me._root,"climb/fuelToAlt-lbs",me.data.climb.fuel);
			setprop(me._root,"climb/distanceToAlt-nm",me.data.climb.distance);
		}	
		if (phase == "descent" or phase == "all"){
			setprop(me._root,"descent/timeToDes-s",me.data.descent.time);
			setprop(me._root,"descent/fuelToDes-lbs",me.data.descent.fuel);
			setprop(me._root,"descent/distanceToDes-nm",me.data.descent.distance);
		}
		if (phase == "cruise" or phase == "all"){
			setprop(me._root,"cruise/distance-nm",me.data.cruise.distance);
			setprop(me._root,"cruise/speed-ktas",me.data.cruise.speed);
			setprop(me._root,"cruise/fflow-lbs-h",me.data.cruise.fuelFlow);
			setprop(me._root,"cruise/time-s",me.data.cruise.time);
			setprop(me._root,"cruise/fuel-lbs",me.data.cruise.fuel);
		}
		if (phase == "trip" or phase == "all"){
			setprop(me._root,"trip/flightTime-s",me.data.trip.time);
			setprop(me._root,"trip/flightFuel-lbs",me.data.trip.fuel);
			setprop(me._root,"trip/flightDist-nm",me.data.trip.distance);
		}
		if ( (phase != "startupTaxi") and (phase != "climb") and (phase != "descent") and (phase != "cruise") and (phase != "trip") and (phase != "all") ){
			print("performance.publish: input not correct");
		}
	},
#-----------------------------------------------------------------------
# CALCULATE TRIP -------------------------------------------------------
#-----------------------------------------------------------------------
# calculates the time, distance and fuel for a complete trip or while enroute
#
# phase: "off"=calc whole trip, "taxi"=startup and taxi, "climb"=climb to cruise, "cruise"=cruise, "descent"=descent
# startupfuel: fuel used for startup and taxi (lbs). Only used when phase is 'off'.
# power: "minpow" or "maxpow", only used in cruise
# flightMode: is "distance", "time" or "fuel"
# currentAlt is used for the airport altitude when phase is 'off'
# it is also used for the phase that is current. So if the phase is 'cruise', currentAlt is used as the cruise altitude, not cruiseALT 
# totalFlight: is total available trip-distance (nm), -time (sec) or -fuel (lbs) dependent on flightMode
# currentGS (knots) and currentFF (lbs/h) are only used for the _current_ flight phase, else it is neglected
# windSp (knots), positive for tail wind, negative for head wind. Only used for the _not_ current flight phase, else neglected (since ground speed is used then!)

# return code 1: cruise distance/time/fuel negative
# return code 2: cruise fuel negative (enroute), range cannot be calculated

	trip : func(phase,startupfuel,power,flightMode,currentAlt,cruiseAlt,destAlt,totalFlight,currentGS,currentFF,windSp,TDISA) {
print(phase);
#print(startupfuel);
#print(power);
#print(flightMode);
#print(currentAlt);
#print(cruiseAlt);
#print(destAlt);
#print(totalFlight);
#print(currentGS);
#print(currentFF);
#print(windSp);
#print(TDISA);

		if (phase == nil) {phase = "off";}

		me.startupTaxi(phase,startupfuel);
		me.climb(phase,currentAlt,cruiseAlt,currentGS,currentFF,windSp,TDISA);
		me.descent(phase,cruiseAlt,destAlt,currentAlt,currentGS,currentFF,windSp);
		if ( flightMode == "distance" ) {cruiseFlight = totalFlight - ( me.data.climb.distance + me.data.descent.distance) }
		if ( flightMode == "time" ) {cruiseFlight = totalFlight - ( me.data.climb.time + me.data.descent.time) }
		if ( flightMode == "fuel" ) {cruiseFlight = totalFlight - ( me.data.climb.fuel + me.data.descent.fuel + me.data.startupTaxi.fuel ) }

		if ( ( cruiseFlight < 0 ) and ( phase == "off") ) {
			print("cruise distance/time/fuel negative, reduce cruise altitude");
			me.data.trip.distance = 0;
			me.data.trip.time = 0;
			me.data.trip.fuel = 0;

			return 1
		}

		if ( ( cruiseFlight < 0 ) and ( phase != "off") and ( flightMode == "fuel" ) ) { # not enough fuel to finish the trip
			me.data.trip.distance = 0;
			me.data.trip.time = 0;
			me.data.trip.fuel = 0;
			return 2
		}

		if ( phase == "descent" ) {    # in descent the "rest" distance is assumed 5000ft over destination altitude with low power
			cruiseFlight = math.abs(cruiseFlight);	# in case the descent is longer as the destination, it is assumed the 'overshoot' is done in cruise 
			cruiseAlt = destAlt + 5000;
			if ( cruiseAlt > currentAlt) { cruiseAlt = currentAlt }
			power = "minpow";
		}

		if ( (phase == "cruise") or (currentAlt > cruiseAlt) ) { cruiseAlt = currentAlt; }

		me.cruise(phase,power,flightMode,cruiseFlight,cruiseAlt,currentGS,currentFF,windSp,TDISA);
		me.updateTrip();
	
	},

#-----------------------------------------------------------------------
# CRUISE ---------------------------------------------------------------
#-----------------------------------------------------------------------
# calculates the time, distance and fuel for the cruise phase 
#
# phase: "off"=calc whole trip, "taxi"=startup and taxi, "climb"=climb to cruise, "cruise"=cruise, "descent"=descent
# if phase in NOT "off", mode2 must be set to "distance" or "fuel"!
# 'powerMode' is either "minpow" or "maxpow"
# 'mode2' is "distance", "time" or "fuel"
# depending on mode2, cruiseInput is the cruise distance (nm), cruise time (sec) or cruise fuel (lbs)
# altitude in ft, currentGS (ground Speed) in knots, currentFF (fuel flow) in lbs/h, windSp in knots, TDISA delta to ISA temp in degC
#
# return code 1: power mode is not set correctly
# return code 2: time or distance mode is not set correctly

	cruise : func(phase="off",powerMode="maxpow",mode2="distance",cruiseInput=0,cruiseAlt=0,currentGS=0,currentFF=0,windSp=0,TDISA=0) {
		var NUMBER=0; var ALTITUDE=1; var maxSPEED=2; var maxFFLOW=3; var minSPEED=4; var minFFLOW=5;

		var cruiseDist = 0;
		var cruiseSpeed = 0;
		var cruiseFF = 0;
		var cruiseTime = 0;
		var cruiseFuel = 0;

		var legendLenght = size(performanceTable.legend);
		var index0 = me.findIndex(TDISA,legendLenght,performanceTable.legend,0);
		var index1 = math.min(index0+1,legendLenght-1);

		var table0a = compile(performanceTable.legend[index0][1]);
		var table0 = table0a();
		var table1a = compile(performanceTable.legend[index1][1]);
		var table1 = table1a();

		if ( ( phase!="off" ) and (mode2!="distance" ) and (mode2!="fuel") ) {print("WARNING: when in flight, mode2 must be 'distance' or 'fuel'") } 

		if ( (phase=="off") or (phase=="startupTaxi") or (phase=="climb") or (phase=="descent") ) {
			if (powerMode=="maxpow"){
				var cruiseSpeed0 = me.matrixinterp(table0,cruiseAlt,ALTITUDE,maxSPEED); 
				var cruiseSpeed1 = me.matrixinterp(table1,cruiseAlt,ALTITUDE,maxSPEED);
				cruiseSpeed = me.lininterp(TDISA,performanceTable.legend[index0][0],performanceTable.legend[index1][0],cruiseSpeed0,cruiseSpeed1) + windSp;

				var cruiseFF0 = me.matrixinterp(table0,cruiseAlt,ALTITUDE,maxFFLOW);
				var cruiseFF1 = me.matrixinterp(table1,cruiseAlt,ALTITUDE,maxFFLOW);
				cruiseFF = me.lininterp(TDISA,performanceTable.legend[index0][0],performanceTable.legend[index1][0],cruiseFF0,cruiseFF1);
			} else if (powerMode=="minpow") {
				var cruiseSpeed0 = me.matrixinterp(table0,cruiseAlt,ALTITUDE,minSPEED); 
				var cruiseSpeed1 = me.matrixinterp(table1,cruiseAlt,ALTITUDE,minSPEED);
				cruiseSpeed = me.lininterp(TDISA,performanceTable.legend[index0][0],performanceTable.legend[index1][0],cruiseSpeed0,cruiseSpeed1) + windSp;

				var cruiseFF0 = me.matrixinterp(table0,cruiseAlt,ALTITUDE,minFFLOW);
				var cruiseFF1 = me.matrixinterp(table1,cruiseAlt,ALTITUDE,minFFLOW);
				cruiseFF = me.lininterp(TDISA,performanceTable.legend[index0][0],performanceTable.legend[index1][0],cruiseFF0,cruiseFF1);
			} else {
				print("ERROR: powerMode variable in cruise is not defined (correctly)");
				return 1
			}

			if (mode2=="distance") {
				cruiseDist = cruiseInput; # nm
				cruiseTime = cruiseInput / cruiseSpeed; #hours
				cruiseFuel = cruiseFF * cruiseTime; #pounds
			} else if (mode2 == "time") {
				cruiseTime = cruiseInput / 3600; #hours
				cruiseDist = cruiseSpeed * cruiseTime; # nm
				cruiseFuel = cruiseFF * cruiseTime; #pounds
			} else if (mode2 == "fuel") {
				cruiseFuel = cruiseInput; # lbs
				cruiseTime = cruiseFuel / cruiseFF; #hours
				cruiseDist = cruiseSpeed * cruiseTime; # nm
			} else {
				print("ERROR: mode2 variable in cruise is not defined (correctly)");
				return 2
			}

		} else if (phase=="cruise") { 

			cruiseSpeed = currentGS; #knots
			cruiseFF = currentFF; # lbs/h

			if (mode2=="distance") {
				cruiseDist = cruiseInput; #nm
				cruiseTime = cruiseDist / cruiseSpeed; # hours
				cruiseFuel = cruiseFF * cruiseTime; # lbs
			} else if (mode2 == "fuel") {
				cruiseFuel = cruiseInput; #lbs
				cruiseTime = cruiseFuel / cruiseFF; #hours
				cruiseDist = cruiseSpeed * cruiseTime; # nm
			}
		}

		me.data.cruise.distance 	= cruiseDist;
		me.data.cruise.speed 		= cruiseSpeed;
		me.data.cruise.fuelFlow 	= cruiseFF;
		me.data.cruise.time 		= cruiseTime*3600;
		me.data.cruise.fuel 		= cruiseFuel;

	},

#-----------------------------------------------------------------------
# CLIMB --------------------------------------------------------------
#-----------------------------------------------------------------------
# calculates the time, distance and fuel for the climb phase 
#
# return code 1: the current altitude is higher as destination altitude, not a climb!

	climb : func(phase="off",currentAlt=0,desAlt=0,currentGS=0,currentFF=0,windSp=0,TDISA=0){

		var timeToAlt = 0;
		var fuelToAlt = 0;
		var distanceToAlt = 0;

		if ((currentAlt >= desAlt) or (phase=="cruise") or (phase=="descent") ) {
			if ((currentAlt >= desAlt) and (phase=="climb")) {print("this is not a climb!")};
			me.data.climb.time = timeToAlt;
			me.data.climb.fuel = fuelToAlt;
			me.data.climb.distance = distanceToAlt;
			return 1
		}

		var legendLenght = size(performanceTable.legend);
		var index0 = me.findIndex(TDISA,legendLenght,performanceTable.legend,0);
		var index1 = math.min(index0+1,legendLenght-1);

		var table0a = compile(performanceTable.legend[index0][2]);
		var table0 = table0a();
		var table1a = compile(performanceTable.legend[index1][2]);
		var table1 = table1a();

		var NUMBER=0; var ALTITUDE=1; var SEC=2; var FUELLBS=3; var DIST=4;

		if ( (phase == "off") or (phase == "startupTaxi") ) {
			var timeToAlt0 = me.matrixinterp(table0,desAlt,ALTITUDE,SEC) - me.matrixinterp(table0,currentAlt,ALTITUDE,SEC);
			var timeToAlt1 = me.matrixinterp(table1,desAlt,ALTITUDE,SEC) - me.matrixinterp(table1,currentAlt,ALTITUDE,SEC);
			timeToAlt = me.lininterp(TDISA,performanceTable.legend[index0][0],performanceTable.legend[index1][0],timeToAlt0,timeToAlt1);

			var fuelToAlt0 = me.matrixinterp(table0,desAlt,ALTITUDE,FUELLBS) - me.matrixinterp(table0,currentAlt,ALTITUDE,FUELLBS);
			var fuelToAlt1 = me.matrixinterp(table1,desAlt,ALTITUDE,FUELLBS) - me.matrixinterp(table1,currentAlt,ALTITUDE,FUELLBS);
			fuelToAlt = me.lininterp(TDISA,performanceTable.legend[index0][0],performanceTable.legend[index1][0],fuelToAlt0,fuelToAlt1);

			var distanceToAlt0 = me.matrixinterp(table0,desAlt,ALTITUDE,DIST) - me.matrixinterp(table0,currentAlt,ALTITUDE,DIST); 
			var distanceToAlt1 = me.matrixinterp(table1,desAlt,ALTITUDE,DIST) - me.matrixinterp(table1,currentAlt,ALTITUDE,DIST);
			distanceToAlt = me.lininterp(TDISA,performanceTable.legend[index0][0],performanceTable.legend[index1][0],distanceToAlt0,distanceToAlt1) + windSp * timeToAlt / 3600;

		} else if ( (phase == "climb") ) {
			var timeToAlt0 = me.matrixinterp(table0,desAlt,ALTITUDE,SEC) - me.matrixinterp(table0,currentAlt,ALTITUDE,SEC);
			var timeToAlt1 = me.matrixinterp(table1,desAlt,ALTITUDE,SEC) - me.matrixinterp(table1,currentAlt,ALTITUDE,SEC);
			timeToAlt = me.lininterp(TDISA,performanceTable.legend[index0][0],performanceTable.legend[index1][0],timeToAlt0,timeToAlt1);

			var fuelToAlt0 = me.matrixinterp(table0,desAlt,ALTITUDE,FUELLBS) - me.matrixinterp(table0,currentAlt,ALTITUDE,FUELLBS);
			var fuelToAlt1 = me.matrixinterp(table1,desAlt,ALTITUDE,FUELLBS) - me.matrixinterp(table1,currentAlt,ALTITUDE,FUELLBS);
			fuelToAlt = me.lininterp(TDISA,performanceTable.legend[index0][0],performanceTable.legend[index1][0],fuelToAlt0,fuelToAlt1);

			distanceToAlt = currentGS * timeToAlt / 3600;

		} else if ( (phase=="cruise") or (phase=="descent") ) {
			# all stays 0
		}

		me.data.climb.time = timeToAlt; #sec
		me.data.climb.fuel = fuelToAlt; # lbs
		me.data.climb.distance = distanceToAlt; # nm

	},

#-----------------------------------------------------------------------
# DESCENT --------------------------------------------------------------
#-----------------------------------------------------------------------
# calculates the time, distance and fuel for the descent phase 
#
# desAlt; so this is the altitude your descending to

	descent : func(phase="off",cruiseAlt=0,desAlt=0,currentAlt=0,currentGS=0,currentFF=0,windSp=0){

		var timeToDes = 0;
		var fuelToDes = 0;
		var distanceToDes = 0;

		if ( ( (phase=="descent") or (phase=="cruise") ) and (currentAlt <= desAlt)) {
			print("This is not a descent!");
			me.data.descent.time = timeToDes;
			me.data.descent.fuel = fuelToDes;
			me.data.descent.distance = distanceToDes;
			return
		}

		if (( (phase=="off") or (phase=="startupTaxi") or (phase=="climb") ) and (cruiseAlt <= desAlt)) {
			print("Cruise altitude above destination airport!");
			me.data.descent.time = timeToDes;
			me.data.descent.fuel = fuelToDes;
			me.data.descent.distance = distanceToDes;
			return
		}

		var NUMBER=0; var ALTITUDE=1; var SECONDS=2; var FUELLBS=3; var DIST=4;

		if ( (phase == "off") or (phase == "startupTaxi") or (phase == "climb") ) {
			var timeToDes = me.matrixinterp(performanceTable.descent,cruiseAlt,ALTITUDE,SECONDS) - me.matrixinterp(performanceTable.descent,desAlt,ALTITUDE,SECONDS);
			var fuelToDes = me.matrixinterp(performanceTable.descent,cruiseAlt,ALTITUDE,FUELLBS) - me.matrixinterp(performanceTable.descent,desAlt,ALTITUDE,FUELLBS);
			var distanceToDes = me.matrixinterp(performanceTable.descent,cruiseAlt,ALTITUDE,DIST) - me.matrixinterp(performanceTable.descent,desAlt,ALTITUDE,DIST) + windSp * timeToDes / 3600;
		} else if ( phase == "cruise" ) {
			var timeToDes = me.matrixinterp(performanceTable.descent,currentAlt,ALTITUDE,SECONDS) - me.matrixinterp(performanceTable.descent,desAlt,ALTITUDE,SECONDS);
			var fuelToDes = me.matrixinterp(performanceTable.descent,currentAlt,ALTITUDE,FUELLBS) - me.matrixinterp(performanceTable.descent,desAlt,ALTITUDE,FUELLBS);
			var distanceToDes = me.matrixinterp(performanceTable.descent,currentAlt,ALTITUDE,DIST) - me.matrixinterp(performanceTable.descent,desAlt,ALTITUDE,DIST) + windSp * timeToDes / 3600;
		} else if ( phase == "descent" ) {
			var timeToDes = me.matrixinterp(performanceTable.descent,currentAlt,ALTITUDE,SECONDS) - me.matrixinterp(performanceTable.descent,desAlt,ALTITUDE,SECONDS);
			var fuelToDes = me.matrixinterp(performanceTable.descent,currentAlt,ALTITUDE,FUELLBS) - me.matrixinterp(performanceTable.descent,desAlt,ALTITUDE,FUELLBS);
			var distanceToDes = currentGS * timeToDes / 3600;
		}

		me.data.descent.time = timeToDes; # sec
		me.data.descent.fuel = fuelToDes; # lbs
		me.data.descent.distance = distanceToDes; #nm

	},

#-----------------------------------------------------------------------
# STARTUP AND TAXI -----------------------------------------------------
#-----------------------------------------------------------------------
# calculates the fuel for the startup and taxi phase 
#
	startupTaxi : func(phase="off",fuel_lbs=nil){
		if (fuel_lbs == nil) {var fuel_lbs = 30}
		if (phase != "off") {var fuel_lbs = 0}
		me.data.startupTaxi.fuel = fuel_lbs;
	},
#-----------------------------------------------------------------------
# RECOMMENDED TRIP ALTITUDE---------------------------------------------
#-----------------------------------------------------------------------
# calculates a recommended altitude based on trip distance and airport altitudes 
#
	RecomAlt : func(tripDistance,airportAlt,desAlt,TDISA){

		var legendLenght = size(performanceTable.legend);
		var index0 = me.findIndex(TDISA,legendLenght,performanceTable.legend,0);
		var index1 = math.min(index0+1,legendLenght-1);

		var table0a = compile(performanceTable.legend[index0][3]);
		var table0 = table0a();
		var table1a = compile(performanceTable.legend[index1][3]);
		var table1 = table1a();

		var NUMBER=0; var DISTANCE=1; var ALTITUDE=2;

		var recomalt = 0;
		if (tripDistance == nil) {return recomalt}
		if (airportAlt == nil) {airportAlt = 0}
		if (desAlt == nil) {desAlt = 0}
		
		var maxAirportAlt = math.max(airportAlt,desAlt);

		var recomalt0 = me.matrixinterp(table0,tripDistance,DISTANCE,ALTITUDE);
		var recomalt1 = me.matrixinterp(table1,tripDistance,DISTANCE,ALTITUDE);
		recomalt = me.lininterp(TDISA,performanceTable.legend[index0][0],performanceTable.legend[index1][0],recomalt0,recomalt1);
		
		return recomalt = math.round( math.clamp(recomalt,maxAirportAlt,25000),100);		
	},
#-----------------------------------------------------------------------
# Delta ISA ------------------------------------------------------------
#-----------------------------------------------------------------------
# calculates the ISA+ value dependent on pressure altitude and local temperature (ft and degC)
# Tropospere (up to 11000m) only! Although it can be easily extended...
#
	D_ISA : func(pressAlt_ft=0,Temp_degC=15){
		return Temp_degC -(15 - 0.0065 * pressAlt_ft * 0.3048);		
	},
#-----------------------------------------------------------------------
# MATRIX INTERPOLATION--------------------------------------------------
#-----------------------------------------------------------------------
# matrix = the matrix; 
# x = search value;  
# x1 = search value vector; 
# y1 = return vector
# returns a value from vector y1 corresponding to x, linear interpolated from vector x1 
#

	matrixinterp : func(matrix,x,x1,y1){ 

		var length = size(matrix);				
		if ( x <= matrix[0][x1] ) { return matrix[0][y1] }
		if ( x >= matrix[length-1][x1] ) { return matrix[length-1][y1] }

		var index = me.findIndex(x,length,matrix,x1);
		return me.lininterp(x,matrix[index][x1],matrix[index+1][x1],matrix[index][y1],matrix[index+1][y1])
#			}
#		}
	},
#-----------------------------------------------------------------------
# LINEAR INTERPOLATION--------------------------------------------------
#-----------------------------------------------------------------------
# x = search value;  
# x0 <= x <= x1
# y0 corresponds to x0, y1 corresponds to x1, 
# returns a value y linear interpolated between y0 and y1, depending on x 
#

	lininterp : func(x,x0,x1,y0,y1){
		if (x<=x0) {return y0}
		if (x>=x1) {return y1}
		return y0 + ( y1 - y0 ) / (x1 - x0 ) * (x - x0) 
	},
#-----------------------------------------------------------------------
# INDEX of MATRIX--------------------------------------------------
#-----------------------------------------------------------------------
# x = search value;  
# returns the (row-) index of the matrix when matrix[index][column] <= x <= matrix[index+1][column] 
#

	findIndex : func(x,length,matrix,column){
		if (x <= matrix[0][column]) { return 0 }
		if (x >= matrix[length-1][column]) { return length-1 }

		for(var index=0; index <= length-1; index=index+1) {
			if ( (x >= matrix[index][column]) and (x <= matrix[index+1][column]) ) {
				return index
			}
		}
	},
	
};

var perf = PerfClass.new("/extra500/perf","performance");
var perfIFD = PerfClass.new("/extra500/instrumentation/IFD/perf","performanceIFD");

