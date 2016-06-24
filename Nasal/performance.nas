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
#      Date: 24.06.2016            
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
		
		return m;
	},
#-------------------------------------------------------------------------
# DETECT FLIGHT PHASE-----------------------------------------------------
#
# detects taxi/startup, climb, cruise or descent
# sets it after 60 seconds to root/phase
# input: the altitude and airspeed source properties
#
	detectFlightPhase : func(altitude="/instrumentation/altimeter/pressure-alt-ft",airspeed="/instrumentation/airspeed/indicated-airspeed-kt") {
		setprop(me._root,"data/altitude-source",altitude);
		setprop(me._root,"data/airspeed-source",airspeed);
		setprop(me._root,"data/old-altitude",getprop(altitude));
		settimer(func(){ me._detectFlightPhase2();},60);
	},
	_detectFlightPhase2 : func() {

		var source_prop_alt = getprop(me._root,"data/altitude-source");
		var source_prop_speed = getprop(me._root,"data/airspeed-source");

		var old_altitude = getprop(me._root,"data/old-altitude");
		var new_altitude = getprop(source_prop_alt);
		setprop(me._root,"data/new-altitude",new_altitude );

		var phase = "off";

		var alt_diff = new_altitude-old_altitude;
		if ( math.abs(alt_diff) < 100 ) {
			if (getprop(source_prop_speed) < 40) {
				setprop(me._root,"phase","startupTaxi" ); 
			} else {
				setprop(me._root,"phase","cruise" ); 
			}
		} else if (alt_diff > 0) {
			setprop(me._root,"phase","climb" ); 
		} else {
			setprop(me._root,"phase","descent" ); 
		}	 
	},


#-----------------------------------------------------------------------
# UPDATE TRIP ----------------------------------------------------------
#-----------------------------------------------------------------------
# adds parameters (time, distance, fuel) from all flight phases and publishes

	updateTrip : func() {
		var flightTime = me.data.cruise.time 	+ me.data.climb.time 		+ me.data.descent.time ; #sec
		var flightFuel = me.data.startupTaxi.fuel + me.data.cruise.fuel 		+ me.data.climb.fuel + me.data.descent.fuel; #lbs
		var flightDist = me.data.cruise.distance 	+ me.data.climb.distance 	+ me.data.descent.distance; # nm

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

# return code 1: cruise distance/time/fuel negative
# return code 2: cruise fuel negative (enroute), range cannot be calculated

	trip : func(phase,startupfuel,power,flightMode,currentAlt,cruiseAlt,destAlt,totalFlight,currentGS,currentFF) {
		me.startupTaxi(phase,startupfuel);
		me.climb(phase,currentAlt,cruiseAlt,currentGS,currentFF);
		me.descent(phase,cruiseAlt,destAlt,currentAlt,currentGS,currentFF);
		if ( flightMode == "distance" ) {cruiseFlight = totalFlight - ( me.data.climb.distance + me.data.descent.distance) }
		if ( flightMode == "time" ) {cruiseFlight = totalFlight - ( me.data.climb.time + me.data.descent.time) }
		if ( flightMode == "fuel" ) {cruiseFlight = totalFlight - ( me.data.climb.fuel + me.data.descent.fuel + me.data.startupTaxi.fuel ) }

		if ( ( cruiseFlight < 0 ) and ( phase == "off") ) {
			print("cruise distance/time/fuel negative, reduce cruise altitude");
			return 1
		}

		if ( ( cruiseFlight < 0 ) and ( phase != "off") and ( flightMode == "fuel" ) ) { # not enough fuel to finish the trip
			return 2
		}

		if ( phase == "descent" ) {    # in descent the "rest" distance is assumed 5000ft over destination altitude with low power
			cruiseFlight = math.abs(cruiseFlight);	# in case the descent is longer as the destination, it is assumed the 'overshoot' is done in cruise 
			cruiseAlt = destAlt + 5000;
			if ( cruiseAlt > currentAlt) { cruiseAlt = currentAlt }
			power = "minpow";
		}

		if ( phase == "cruise" ) { cruiseAlt = currentAlt; }

		me.cruise(phase,power,flightMode,cruiseFlight,cruiseAlt,currentGS,currentFF);
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
# altitude in ft, currentGS (ground Speed) in knots, currentFF (fuel flow) in lbs/h 
#
# return code 1: power mode is not set correctly
# return code 2: time or distance mode is not set correctly

	cruise : func(phase="off",powerMode="maxpow",mode2="distance",cruiseInput=0,cruiseAlt=0,currentGS=0,currentFF=0) {
		var NUMBER=0; var ALTITUDE=1; var maxSPEED=2; var maxFFLOW=3; var minSPEED=4; var minFFLOW=5;

		var cruiseDist = 0;
		var cruiseSpeed = 0;
		var cruiseFF = 0;
		var cruiseTime = 0;
		var cruiseFuel = 0;

		if ( ( phase!="off" ) and (mode2!="distance" ) and (mode2!="fuel") ) {print("WARNING: when in flight, mode2 must be 'distance' or 'fuel'") } 

		if ( (phase=="off") or (phase=="taxi") or (phase=="climb") or (phase=="descent") ) {
			if (powerMode=="maxpow"){
				cruiseSpeed = me.matrixinterp(performanceTable.cruise,14,cruiseAlt,ALTITUDE,maxSPEED);
				cruiseFF = me.matrixinterp(performanceTable.cruise,14,cruiseAlt,ALTITUDE,maxFFLOW);
			} else if (powerMode=="minpow") {
				cruiseSpeed = me.matrixinterp(performanceTable.cruise,14,cruiseAlt,ALTITUDE,minSPEED);
				cruiseFF = me.matrixinterp(performanceTable.cruise,14,cruiseAlt,ALTITUDE,minFFLOW);
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

	climb : func(phase="off",currentAlt=0,desAlt=0,currentGS=0,currentFF=0){

		var timeToAlt = 0;
		var fuelToAlt = 0;
		var distanceToAlt = 0;

		if ((currentAlt >= desAlt) or (phase=="cruise") or (phase=="descent") ) {
			if (currentAlt >= desAlt) {print("this is not a climb!")};
			me.data.climb.time = timeToAlt;
			me.data.climb.fuel = fuelToAlt;
			me.data.climb.distance = distanceToAlt;
			return 1
		}

		var NUMBER=0; var ALTITUDE=1; var SECONDS=2; var FUELLBS=3; var DIST=4;

		if ( (phase == "off") or (phase == "taxi") ) {
			timeToAlt = me.matrixinterp(performanceTable.climb,26,desAlt,ALTITUDE,SECONDS) - me.matrixinterp(performanceTable.climb,26,currentAlt,ALTITUDE,SECONDS);
			fuelToAlt = me.matrixinterp(performanceTable.climb,26,desAlt,ALTITUDE,FUELLBS) - me.matrixinterp(performanceTable.climb,26,currentAlt,ALTITUDE,FUELLBS);
			distanceToAlt = me.matrixinterp(performanceTable.climb,26,desAlt,ALTITUDE,DIST) - me.matrixinterp(performanceTable.climb,26,currentAlt,ALTITUDE,DIST);
		} else if ( (phase == "climb") ) {
			timeToAlt = me.matrixinterp(performanceTable.climb,26,desAlt,ALTITUDE,SECONDS) - me.matrixinterp(performanceTable.climb,26,currentAlt,ALTITUDE,SECONDS);
			fuelToAlt = me.matrixinterp(performanceTable.climb,26,desAlt,ALTITUDE,FUELLBS) - me.matrixinterp(performanceTable.climb,26,currentAlt,ALTITUDE,FUELLBS);
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

	descent : func(phase="off",cruiseAlt=0,desAlt=0,currentAlt=0,currentGS=0,currentFF=0){

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

		if (( (phase=="off") or (phase=="taxi") or (phase=="climb") ) and (cruiseAlt <= desAlt)) {
			print("Cruise altitude above destination airport!");
			me.data.descent.time = timeToDes;
			me.data.descent.fuel = fuelToDes;
			me.data.descent.distance = distanceToDes;
			return
		}

		var NUMBER=0; var ALTITUDE=1; var SECONDS=2; var FUELLBS=3; var DIST=4;

		if ( (phase == "off") or (phase == "taxi") or (phase == "climb") ) {
			var timeToDes = me.matrixinterp(performanceTable.descent,26,cruiseAlt,ALTITUDE,SECONDS) - me.matrixinterp(performanceTable.descent,26,desAlt,ALTITUDE,SECONDS);
			var fuelToDes = me.matrixinterp(performanceTable.descent,26,cruiseAlt,ALTITUDE,FUELLBS) - me.matrixinterp(performanceTable.descent,26,desAlt,ALTITUDE,FUELLBS);
			var distanceToDes = me.matrixinterp(performanceTable.descent,26,cruiseAlt,ALTITUDE,DIST) - me.matrixinterp(performanceTable.descent,26,desAlt,ALTITUDE,DIST);
		} else if ( phase == "cruise" ) {
			var timeToDes = me.matrixinterp(performanceTable.descent,26,currentAlt,ALTITUDE,SECONDS) - me.matrixinterp(performanceTable.descent,26,desAlt,ALTITUDE,SECONDS);
			var fuelToDes = me.matrixinterp(performanceTable.descent,26,currentAlt,ALTITUDE,FUELLBS) - me.matrixinterp(performanceTable.descent,26,desAlt,ALTITUDE,FUELLBS);
			var distanceToDes = me.matrixinterp(performanceTable.descent,26,currentAlt,ALTITUDE,DIST) - me.matrixinterp(performanceTable.descent,26,desAlt,ALTITUDE,DIST);
		} else if ( phase == "descent" ) {
			var timeToDes = me.matrixinterp(performanceTable.descent,26,currentAlt,ALTITUDE,SECONDS) - me.matrixinterp(performanceTable.descent,26,desAlt,ALTITUDE,SECONDS);
			var fuelToDes = me.matrixinterp(performanceTable.descent,26,currentAlt,ALTITUDE,FUELLBS) - me.matrixinterp(performanceTable.descent,26,desAlt,ALTITUDE,FUELLBS);
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
	RecomAlt : func(tripDistance,airportAlt,desAlt){
		var recomalt = 0;
		if (tripDistance == nil) {return recomalt}
		if (airportAlt == nil) {airportAlt = 0}
		if (desAlt == nil) {desAlt = 0}
		
		var maxAirportAlt = math.max(airportAlt,desAlt) + 5000;

		if ( tripDistance <= 80 ) {
			recomalt = 275 * tripDistance - 6000;
		} else {
			recomalt = 90 * tripDistance + 8800;
		}
		
		return recomalt = math.round( math.clamp(recomalt,maxAirportAlt,25000),100);		
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

	matrixinterp : func(matrix,length,x,x1,y1){ 

		##### DD : length = size(matrix) ?? could reduce parameters and make the matrix size dynamic ??  
				
		if ( x <= matrix[0][x1] ) { return matrix[0][y1] }
		if ( x >= matrix[length-1][x1] ) { return matrix[length-1][y1] }

		for(var index=0; index <= length-1; index=index+1) {
			if ( (x > matrix[index][x1]) and (x <= matrix[index+1][x1]) ) {
				return matrix[index][y1] + (x - matrix[index][x1]) / (matrix[index+1][x1] - matrix[index][x1] ) * (matrix[index+1][y1] - matrix[index][y1])
			}
		}
	},

	
};

var perf = PerfClass.new("/extra500/perf","performance");

