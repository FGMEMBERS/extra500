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
#      Date: 20.03.2015
#
#      Last change:      Dirk Dittmann
#      Date:             31.03.2015
#

var Environment = {
	new : func(root,name){
		var m = { 
			parents 	: [Environment],
			_nRoot		: props.globals.initNode(root),
			_name		: name
		};
		m._windshieldTemperature = getprop("/environment/temperature-degc");
		m._nWindshieldTemperature = m._nRoot.initNode("windshieldTemperatur-degc",m._windshieldTemperature,"DOUBLE");
		m._windshieldElectricTemperature = getprop("/environment/temperature-degc");
		m._nWindshieldElectricTemperature = m._nRoot.initNode("windshieldHeatedTemperatur-degc",m._windshieldElectricTemperature,"DOUBLE");
		
		
		m._electricWatt = 0;
		m._defrostWatt = 0;
		m._updateSec = 1.0;
		m._timerLoop = nil;
		return m;
	},
	init : func(instance=nil){
		me.setListeners(instance);
		
		me._timerLoop = maketimer(me._updateSec,me,Environment.update);
		me._timerLoop.start();
	},
	setListeners : func(instance) {
		
	},
	update : func(){
		
		me.rainSplashVector();
		me.frost();
	},
	rainSplashVector : func(){
		var airspeed = getprop("/velocities/airspeed-kt");

		# f16
		var airspeed_max = 250;

		if (airspeed > airspeed_max) {airspeed = airspeed_max;}

		airspeed = math.sqrt(airspeed/airspeed_max);

		var splash_x = -0.1 - 2.0 * airspeed;
		var splash_y = 0.0;
		var splash_z = 1.0 - 1.35 * airspeed;



		interpolate("/environment/aircraft-effects/splash-vector-x", splash_x,me._updateSec);
		interpolate("/environment/aircraft-effects/splash-vector-y", splash_y,me._updateSec);
		interpolate("/environment/aircraft-effects/splash-vector-z", splash_z,me._updateSec);

	},
	frost : func(){
		var frost 	= getprop("/environment/aircraft-effects/frost-level");
		var frostFront 	= getprop("/environment/aircraft-effects/frost-level-front");
		var frostHeated = getprop("/environment/aircraft-effects/frost-level-heated");
		var frostNoice 	= getprop("/environment/aircraft-effects/frost-level-noice");
		
		#var dewpoint 	= getprop("/environment/dewpoint-degc");
		var humidity 	= getprop("/environment/relative-humidity");
		var temperature	= getprop("/environment/temperature-degc");
		#var ias		= getprop("/instrumentation/airspeed-backup/indicated-speed-kt");
		var waterCatchEffect = 0;
		
		me._windshieldTemperature 		= me._nWindshieldTemperature.getValue();
		me._windshieldTemperature 		+= ((temperature - me._windshieldTemperature) * 0.01)* me._updateSec;
		me._windshieldTemperature 		+= ((me._defrostWatt / 16.5) / 12 ) * me._updateSec;
		me._nWindshieldTemperature.setValue(me._windshieldTemperature);
		
		
		me._windshieldElectricTemperature 	= me._nWindshieldElectricTemperature.getValue();
		me._windshieldElectricTemperature	+= ((temperature - me._windshieldElectricTemperature) * 0.01) * me._updateSec;
		me._windshieldElectricTemperature 	+= ((me._defrostWatt / 16.5) / 12 ) * me._updateSec;
		me._windshieldElectricTemperature 	+= (((me._electricWatt) / 625) / 0.76 ) * me._updateSec;
		me._nWindshieldElectricTemperature.setValue(me._windshieldElectricTemperature);
		
		
		waterCatchEffect = humidity * 0.0001;
		
		frostFront 	+= -me._windshieldTemperature * waterCatchEffect;
		frostFront 		= global.clamp(frostFront,0.0,1.0);
		
		frostHeated 	+= -me._windshieldElectricTemperature * waterCatchEffect;
		frostHeated 	= global.clamp(frostHeated,0.0,1.0);
		
		#print("frost| ",sprintf("windshield: %0.2f, T: %0.2f, F: %0.2f,  a: %0.2f",me._windshieldTemperature,temperature,frost,adjust));
		
		interpolate("/environment/aircraft-effects/frost-level", frost ,me._updateSec);
		interpolate("/environment/aircraft-effects/frost-level-front", frostFront ,me._updateSec);
		interpolate("/environment/aircraft-effects/frost-level-heated", frostHeated ,me._updateSec);
		interpolate("/environment/aircraft-effects/frost-level-noice", frostNoice ,me._updateSec);
		
		
	},
	deforstWindshieldWatt : func(watt){
		me._defrostWatt = watt;
	},
	heatWindshieldElectric : func(watt){
		me._electricWatt = watt;
	},
	
	
	
};

var environment = Environment.new("/extra500/environment","Environment");

