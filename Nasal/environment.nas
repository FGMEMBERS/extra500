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
#      Date:             07.04.15
#



var Environment = {
	new : func(root,name){
		var m = { 
			parents 	: [Environment],
			_nRoot		: props.globals.initNode(root),
			_name		: name
		};
		m._temperature 	= getprop("/environment/temperature-degc");
		m._airspeed 	= getprop("/velocities/airspeed-kt");
		m._humidity 	= getprop("/environment/relative-humidity");
		
		m._nFrostWaterCatchFactor 	= m._nRoot.initNode("frost/waterCatchFactor",0.0001,"DOUBLE",1);
		m._nFrostAirEffectFactor 	= m._nRoot.initNode("frost/airEffectFactor",0.001,"DOUBLE",1);
		m._nFrostAirEffectMin 		= m._nRoot.initNode("frost/airEffectMin",0.1,"DOUBLE",1);
		m._nFrostExchangeFactor		= m._nRoot.initNode("frost/exchangeFactor",0.1,"DOUBLE",1);
		
		m._electricWatt = 0;
		m._defrostWatt = 0;
		m._dt = 1.0;
		m._timerLoop = nil;
		return m;
	},
	init : func(instance=nil){
		me.setListeners(instance);
		
		#me._timerLoop = maketimer(me._dt,me,Environment.update);
		#me._timerLoop.start();
	},
	setListeners : func(instance) {
		
	},
	update : func(dt){
		me._dt = dt;
		
		me._airspeed 	= getprop("/fdm[0]/jsbsim[0]/velocities[0]/vt-fps");
		me._temperature	= getprop("/environment/temperature-degc");
		me._humidity 	= getprop("/environment/relative-humidity");
		me._density 	= getprop("/environment/density-slugft3") * 0.413253311; # (kg/m³)

		
		me.rainSplashVector();
		me.frost();
	},
	rainSplashVector : func(){
		var airspeed = me._airspeed;
		# f16
		var airspeed_max = 250;

		if (airspeed > airspeed_max) airspeed = airspeed_max;

		var airspeed = math.sqrt(airspeed/airspeed_max);

		var splash_x = -0.1 - 2.0 * airspeed;
		var splash_y = 0.0;
		var splash_z = 1.0 - 1.35 * airspeed;



		interpolate("/environment/aircraft-effects/splash-vector-x", splash_x,me._dt);
		interpolate("/environment/aircraft-effects/splash-vector-y", splash_y,me._dt);
		interpolate("/environment/aircraft-effects/splash-vector-z", splash_z,me._dt);

	},
	frost : func(){
		var frost 	= getprop("/environment/aircraft-effects/frost-level");
		var frostFront 	= getprop("/environment/aircraft-effects/frost-level-front");
		var frostHeated = getprop("/environment/aircraft-effects/frost-level-heated");
		var frostNoice 	= getprop("/environment/aircraft-effects/frost-level-noice");
		

		# cooling the windshield
		
		
		# Air effect factor 0.001 and min 0.1
		var eff_factor 	= me._nFrostAirEffectFactor.getValue() ;
		var eff_min	= me._nFrostAirEffectMin.getValue() ;
		
		# specificHeatCapacity Air 1.005 kJ / (kg*K)
		# windshield  ~ 0.53376m² = 0.48m * 1.112m
		# Massflow 	(kg/s) = (kg/m³) * (m/s) * (m²)
		# energie 	(kJ) = (1.005) * (kg/s) * (°C)
		var flowSpeed	= me._airspeed * 0.3048 ; 	# (m/s)
		var area	= 0.53376 ; 			# (m²) 
		var massflow 	= me._density * (eff_min + eff_factor * flowSpeed) * area; 	# (kg/s)
		massflow *= (1005); # specific Air 
		
		# echange Factor between Air and Windshield default 0.1
		var exchangeFactor = me._nFrostExchangeFactor.getValue() ;
		
		#	energie flow		= (exchange factor) * (massflow) * (Delta Temp)
		var  engerieWindShield 		= (exchangeFactor) * (massflow * (0.937)) * (me._temperature - cabin._windShield._temperature) ;# W
		
		var  engerieWindShieldHeated 	= (exchangeFactor) * (massflow * (0.063)) * (me._temperature - cabin._windShieldHeated._temperature) ;# W
		
		#print("frost| ",sprintf("windshield %0.3f W %0.3f W",engerieWindShield,engerieWindShieldHeated));
		
		# put the energie flow onto the windshield
		cabin._windShield.addWatt( engerieWindShield ,me._dt);
		cabin._windShieldHeated.addWatt( engerieWindShieldHeated ,me._dt);
		
		
		var waterCatchEffect = me._humidity * me._nFrostWaterCatchFactor.getValue();
		
		frostFront 	+= - cabin._windShield._temperature * waterCatchEffect;
		frostFront 	= global.clamp(frostFront,0.0,1.0);
		
		frostHeated 	+= - cabin._windShieldHeated._temperature * waterCatchEffect;
		frostHeated 	= global.clamp(frostHeated,0.0,1.0);
		
		#print("frost| ",sprintf("windshield: %0.2f, T: %0.2f, F: %0.2f,  a: %0.2f",me._windshieldTemperature,temperature,frost,adjust));
		
		interpolate("/environment/aircraft-effects/frost-level", frost ,me._dt);
		interpolate("/environment/aircraft-effects/frost-level-front", frostFront ,me._dt);
		interpolate("/environment/aircraft-effects/frost-level-heated", frostHeated ,me._dt);
		#interpolate("/environment/aircraft-effects/frost-level-noice", frostNoice ,me._dt);
		
		print("frost| ",sprintf("windshield %0.3fJ+=%0.3fJ (%0.1f°C),  %0.3fJ+=%0.3fJ (%0.1f°C)",
				cabin._windShield._energie,
			  engerieWindShield,
				cabin._windShield._temperature,
				cabin._windShieldHeated._energie,
			  engerieWindShieldHeated,
				cabin._windShieldHeated._temperature
				       ));
		
	},
		
};

var environment = Environment.new("/extra500/environment","Environment");

