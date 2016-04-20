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
#      Date: 20.04.2016            
#

var PerfClass = {
	new : func(root,name){
		var m = {parents:[PerfClass],
		_root		: root,
		};

		return m;
	},

#-----------------------------------------------------------------------
# UPDATE TRIP ----------------------------------------------------------
#-----------------------------------------------------------------------
# adds parameters (time, distance, fuel) from all flight phases and publishes

	updateTrip : func() {
		var flightTime = getprop(me._root,"cruise/time-s") + getprop(me._root,"climb/timeToAlt-s") + getprop(me._root,"descent/timeToDes-s");
		var flightFuel = getprop(me._root,"startupTaxi/fuel-lbs") + getprop(me._root,"cruise/fuel-lbs") + getprop(me._root,"climb/fuelToAlt-lbs") + getprop(me._root,"descent/fuelToDes-lbs");
		var flightDist = getprop(me._root,"cruise/distance-nm") + getprop(me._root,"climb/distanceToAlt-nm") + getprop(me._root,"descent/distanceToDes-nm");

		setprop(me._root,"trip/flightTime-s",flightTime);
		setprop(me._root,"trip/flightFuel-lbs",flightFuel);
		setprop(me._root,"trip/flightDist-nm",flightDist);
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
		if ( flightMode == "distance" ) {cruiseFlight = totalFlight - getprop(me._root,"climb/distanceToAlt-nm") - getprop(me._root,"descent/distanceToDes-nm")}
		if ( flightMode == "time" ) {cruiseFlight = totalFlight - getprop(me._root,"climb/timeToAlt-s") - getprop(me._root,"descent/timeToDes-s")}
		if ( flightMode == "fuel" ) {cruiseFlight = totalFlight - getprop(me._root,"climb/fuelToAlt-lbs") - getprop(me._root,"descent/fuelToDes-lbs") - getprop(me._root,"startupTaxi/fuel-lbs")}

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
		var cruise = [
				[1,0,199,242,145,155],
				[2,2000,202,238,147,150],
				[3,4000,206,234,149,145],
				[4,6000,210,232,151,141],	
				[5,8000,213,230,153,136],
				[6,10000,217,229,156,132],
				[7,12000,221,227,158,129],
				[8,14000,218,211,161,125],
				[9,16000,216,200,163,123],
				[10,18000,214,190,166,120],
				[11,20000,203,166,158,108],
				[12,22000,199,152,161,107],
				[13,24000,193,140,154,105],
				[14,25000,186,128,165,105]
				];

		var cruiseDist = 0;
		var cruiseSpeed = 0;
		var cruiseFF = 0;
		var cruiseTime = 0;
		var cruiseFuel = 0;

		if ( ( phase!="off" ) and (mode2!="distance" ) and (mode2!="fuel") ) {print("WARNING: when in flight, mode2 must be 'distance' or 'fuel'") } 

		if ( (phase=="off") or (phase=="taxi") or (phase=="climb") or (phase=="descent") ) {
			if (powerMode=="maxpow"){
				cruiseSpeed = me.matrixinterp(cruise,14,cruiseAlt,ALTITUDE,maxSPEED);
				cruiseFF = me.matrixinterp(cruise,14,cruiseAlt,ALTITUDE,maxFFLOW);
			} else if (powerMode=="minpow") {
				cruiseSpeed = me.matrixinterp(cruise,14,cruiseAlt,ALTITUDE,minSPEED);
				cruiseFF = me.matrixinterp(cruise,14,cruiseAlt,ALTITUDE,minFFLOW);
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

		setprop(me._root,"cruise/distance-nm",cruiseDist);
		setprop(me._root,"cruise/speed-ktas",cruiseSpeed);
		setprop(me._root,"cruise/fflow-lbs-h",cruiseFF);
		setprop(me._root,"cruise/time-s",cruiseTime*3600);
		setprop(me._root,"cruise/fuel-lbs",cruiseFuel);
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

		if ((currentAlt >= desAlt) and (phase=="cruise") and (phase=="descent") ) {
			print("this is not a climb!");
			setprop(me._root,"climb/timeToAlt-s",timeToAlt);
			setprop(me._root,"climb/fuelToAlt-lbs",fuelToAlt);
			setprop(me._root,"climb/distanceToAlt-nm",0);
			return 1
		}

		var NUMBER=0; var ALTITUDE=1; var SECONDS=2; var FUELLBS=3; var DIST=4;
		var climb = [
				[1,0,0,0,0],
				[2,1000,42,3,1],
				[3,2000,90,6,3],
				[4,3000,132,9,4],
				[5,4000,180,12,6],	
				[6,5000,222,15,7],
				[7,6000,270,18,9],
				[8,7000,312,20,10],
				[9,8000,360,23,12],
				[10,9000,402,26,13],
				[11,10000,444,29,15],
				[12,11000,492,32,16],
				[13,12000,534,35,18],
				[14,13000,582,38,20],
				[15,14000,630,41,21],
				[16,15000,684,44,23],
				[17,16000,744,47,26],
				[18,17000,810,50,28],
				[19,18000,876,54,31],
				[20,19000,960,58,34],
				[21,20000,1050,63,38],
				[22,21000,1152,67,42],
				[23,22000,1272,73,48],
				[24,23000,1422,79,54],
				[25,24000,1620,87,63],
				[26,25000,1976,98,75]
				];

		if ( (phase == "off") or (phase == "taxi") ) {
			timeToAlt = me.matrixinterp(climb,26,desAlt,ALTITUDE,SECONDS) - me.matrixinterp(climb,26,currentAlt,ALTITUDE,SECONDS);
			fuelToAlt = me.matrixinterp(climb,26,desAlt,ALTITUDE,FUELLBS) - me.matrixinterp(climb,26,currentAlt,ALTITUDE,FUELLBS);
			distanceToAlt = me.matrixinterp(climb,26,desAlt,ALTITUDE,DIST) - me.matrixinterp(climb,26,currentAlt,ALTITUDE,DIST);
		} else if ( (phase == "climb") ) {
			timeToAlt = me.matrixinterp(climb,26,desAlt,ALTITUDE,SECONDS) - me.matrixinterp(climb,26,currentAlt,ALTITUDE,SECONDS);
			fuelToAlt = me.matrixinterp(climb,26,desAlt,ALTITUDE,FUELLBS) - me.matrixinterp(climb,26,currentAlt,ALTITUDE,FUELLBS);
			distanceToAlt = currentGS * timeToAlt / 3600;
		} else if ( (phase=="cruise") or (phase=="descent") ) {
			# all stays 0
		}

		setprop(me._root,"climb/timeToAlt-s",timeToAlt);
		setprop(me._root,"climb/fuelToAlt-lbs",fuelToAlt);
		setprop(me._root,"climb/distanceToAlt-nm",distanceToAlt);
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

		if (currentAlt <= desAlt) {
			print("This is not a descent!");
			setprop(me._root,"descent/timeToDes-s",timeToDes);
			setprop(me._root,"descent/fuelToDes-lbs",fuelToDes);
			setprop(me._root,"descent/distanceToDes-nm",distanceToDes);
			return
		}

		var NUMBER=0; var ALTITUDE=1; var SECONDS=2; var FUELLBS=3; var DIST=4;
		var descent = [
				[1,0,0,0,0],
				[2,1000,30,1,2],
				[3,2000,60,2,4],
				[4,3000,90,3,6],
				[5,4000,120,4,8],	
				[6,5000,150,5,10],
				[7,6000,180,6,12],
				[8,7000,210,8,14],
				[9,8000,240,9,16],
				[10,9000,270,10,18],
				[11,10000,300,11,20],
				[12,11000,330,12,22],
				[13,12000,360,13,24],
				[14,13000,390,14,26],
				[15,14000,420,16,28],
				[16,15000,450,17,30],
				[17,16000,480,18,32],
				[18,17000,510,19,34],
				[19,18000,540,20,36],
				[20,19000,570,22,37],
				[21,20000,600,23,39],
				[22,21000,630,24,41],
				[23,22000,660,25,43],
				[24,23000,690,27,44],
				[25,24000,720,28,46],
				[26,25000,750,29,48]
				];

		if ( (phase == "off") or (phase == "taxi") or (phase == "climb") ) {
			var timeToDes = me.matrixinterp(descent,26,cruiseAlt,ALTITUDE,SECONDS) - me.matrixinterp(descent,26,desAlt,ALTITUDE,SECONDS);
			var fuelToDes = me.matrixinterp(descent,26,cruiseAlt,ALTITUDE,FUELLBS) - me.matrixinterp(descent,26,desAlt,ALTITUDE,FUELLBS);
			var distanceToDes = me.matrixinterp(descent,26,cruiseAlt,ALTITUDE,DIST) - me.matrixinterp(descent,26,desAlt,ALTITUDE,DIST);
		} else if ( phase == "cruise" ) {
			var timeToDes = me.matrixinterp(descent,26,currentAlt,ALTITUDE,SECONDS) - me.matrixinterp(descent,26,desAlt,ALTITUDE,SECONDS);
			var fuelToDes = me.matrixinterp(descent,26,currentAlt,ALTITUDE,FUELLBS) - me.matrixinterp(descent,26,desAlt,ALTITUDE,FUELLBS);
			var distanceToDes = me.matrixinterp(descent,26,currentAlt,ALTITUDE,DIST) - me.matrixinterp(descent,26,desAlt,ALTITUDE,DIST);
		} else if ( phase == "descent" ) {
			var timeToDes = me.matrixinterp(descent,26,currentAlt,ALTITUDE,SECONDS) - me.matrixinterp(descent,26,desAlt,ALTITUDE,SECONDS);
			var fuelToDes = me.matrixinterp(descent,26,currentAlt,ALTITUDE,FUELLBS) - me.matrixinterp(descent,26,desAlt,ALTITUDE,FUELLBS);
			var distanceToDes = currentGS * timeToDes / 3600;
		}

		setprop(me._root,"descent/timeToDes-s",timeToDes);
		setprop(me._root,"descent/fuelToDes-lbs",fuelToDes);
		setprop(me._root,"descent/distanceToDes-nm",distanceToDes);

	},

#-----------------------------------------------------------------------
# STARTUP AND TAXI -----------------------------------------------------
#-----------------------------------------------------------------------
# calculates the fuel for the startup and taxi phase 
#
	startupTaxi : func(phase="off",fuel_lbs=nil){
		if (fuel_lbs == nil) {var fuel_lbs = 30}
		if (phase != "off") {var fuel_lbs = 0}
		setprop(me._root,"startupTaxi/fuel-lbs",fuel_lbs);
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

