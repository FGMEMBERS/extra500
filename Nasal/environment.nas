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
#       Last change:      Dirk Dittmann
#       Date:             06.01.2016
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
		m._rainNorm 	= getprop("/environment/rain-norm");
		m._rainLevel 	= getprop("/environment/params/precipitation-level-ft");
		
		
		m._nFrostWaterCatchFactor 	= m._nRoot.initNode("frost/waterCatchFactor",0.25,"DOUBLE",1);
		m._nDeFrostFactor	 	= m._nRoot.initNode("frost/deFrostFactor",0.001,"DOUBLE",1);
		m._nFrostAirEffectFactor 	= m._nRoot.initNode("frost/airEffectFactor",5.0,"DOUBLE",1);
		m._nFrostAirEffectMin 		= m._nRoot.initNode("frost/airEffectMin",0.1,"DOUBLE",1);
		m._nFrostExchangeFactor		= m._nRoot.initNode("frost/exchangeFactor",50,"DOUBLE",1);
		m._nAbsoluteHumidityMin		= m._nRoot.initNode("frost/absoluteHumidityMin",0.005,"DOUBLE",1);
		
		# windshield
		m._frost 		= getprop("/environment/aircraft-effects/frost-level");
		m._frostFront 		= getprop("/environment/aircraft-effects/frost-level-front");
		m._frostHeated 		= getprop("/environment/aircraft-effects/frost-level-heated");
		m._frostNoice 		= getprop("/environment/aircraft-effects/frost-level-noice");
		# propeller
		m._frostPropeller 	= getprop("/environment/aircraft-effects/frost-level-Propeller");
		# boots		
		m._frostWingLeft 	= getprop("/environment/aircraft-effects/frost-level-WingLeft");
		m._frostWingRight 	= getprop("/environment/aircraft-effects/frost-level-WingRight");
		m._frostVStab 		= getprop("/environment/aircraft-effects/frost-level-VStab", );
		m._frostHStabLeft	= getprop("/environment/aircraft-effects/frost-level-HStabLeft", );
		m._frostHStabRight	= getprop("/environment/aircraft-effects/frost-level-HStabRight", );
		
		
		
		m._cloudEffect = 0; # 0-1 intersection clouds
		
		m._electricWatt = 0;
		m._defrostWatt  = 0;
		m._dt 		= 1.0;
		m._timerLoop 	= nil;
		
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
		
		me._airspeed 		= getprop("/fdm[0]/jsbsim[0]/velocities[0]/vt-fps");
		me._temperature		= getprop("/environment/temperature-degc");
		me._humidity 		= getprop("/environment/relative-humidity");
		me._density 		= getprop("/environment/density-slugft3");
		me._absoluteHumidity 	= getprop("/environment/a-kg-per-m3");
		me._rainNorm 		= getprop("/environment/rain-norm");
		me._rainLevelFt		= getprop("/environment/params/precipitation-level-ft");
		me._posAltitudeFt 	= getprop("/position/altitude-ft");
		
		me.detectClouds();
		
		me.rainSplashVector();
		me.frost();
		me.fog();
	},
	rainSplashVector : func(){
		var airspeed = getprop("/fdm/jsbsim/aircraft/propeller/Vind-fps") + getprop("/fdm/jsbsim/velocities/u-aero-fps");
#		var airspeed_max = 100;

#		if (airspeed > airspeed_max) airspeed = airspeed_max;

#		var airspeed = math.sqrt(math.abs(airspeed)/airspeed_max);

#		var splash_x = -0.1 - 2.0 * airspeed;
#		var splash_y = 0.0;
#		var splash_z = 1.0 - 1.35 * airspeed;
		var splash_x = 0.35 - 0.015 * airspeed;
		var splash_y = 0.15 + 0.001 * airspeed;
		var splash_z = 1.0 - 0.002 * airspeed;

		
		if(me._posAltitudeFt > me._rainLevelFt){
			me._rainNorm = 0.0;
		}
		
		interpolate("/extra500/environment/rain-norm", me._rainNorm,me._dt);

		interpolate("/environment/aircraft-effects/splash-vector-x", splash_x,me._dt);
		interpolate("/environment/aircraft-effects/splash-vector-y", splash_y,me._dt);
		interpolate("/environment/aircraft-effects/splash-vector-z", splash_z,me._dt);

	},
	detectClouds : func(){
		print("Environment::detectClouds() ...");
		var cloudEffectSum 	= 0; # norm 0-1
		
		

# 	SG_CLOUD_OVERCAST = 0,
# 	SG_CLOUD_BROKEN,
# 	SG_CLOUD_SCATTERED,
# 	SG_CLOUD_FEW,
# 	SG_CLOUD_CIRRUS,
# 	SG_CLOUD_CLEAR,
# 	SG_MAX_CLOUD_COVERAGES

		
		var cloudTypeEffect = {
			0 : 1,  	# OVERCAST
			1 : 0.75,  	# BROKEN
			2 : 0.5,  	# SCATTERED
			3 : 0.25,  	# FEW
			4 : 0.1,  	# CIRRUS
			5 : 0,  	# CLEAR
			6 : 0,  	# MAX_CLOUD_COVERAGES ??
		};	
		
		
		var nClouds 	= props.globals.getNode("/environment/metar/clouds");
		
		var aircraftAlt = getprop("/position/altitude-ft");
		var station_alt = getprop("/environment/metar/station-elevation-ft");
		
		
		print (sprintf("aircraft alt %5.0f",aircraftAlt));
		
		foreach(var layer; nClouds.getChildren("layer")){
			var elevation 	= layer.getNode("elevation-ft").getValue();
			var thickness 	= layer.getNode("thickness-ft").getValue();
			var type 	= layer.getNode("coverage-type").getValue();
			var name 	= layer.getNode("coverage").getValue();
			
			
			var thicknessRadius 	= thickness/2;
			#var elevationMsl	= elevation;
			var elevationMin 	= elevation;
			var elevationMax 	= elevation + thickness;
			
			
			
			var strRow = sprintf("\t%2i %12s %5.0f %5.0f %5.0f %5.0f",type,name,elevation,thickness,elevationMin,elevationMax);
			
			if (aircraftAlt > elevation and aircraftAlt < elevationMax){
				
				var cloudCenterDistanceEffect = (1.5-(math.abs(aircraftAlt - (elevation + thicknessRadius)) / thicknessRadius));
				var eff = cloudCenterDistanceEffect * cloudTypeEffect[type];
				
				cloudEffectSum += eff;
				
				strRow ~= sprintf(" =  %1.5f",eff);
								
			}
			
			print(strRow);
		}
		me._cloudEffect = global.clamp(cloudEffectSum,0.0,1.0);
		
		print (sprintf("Cloud effect %1.5f",me._cloudEffect));
		
	},
	
	# param : surfaceTemperature 
	# returns : water(ice)/sec
	surfaceWaterCatchEffect : func(surfaceTemperature=0.0){
		var waterCatchEffect = 0;
		
		if (surfaceTemperature > 0.0){
			
			# ice melting
			waterCatchEffect = surfaceTemperature * me._nDeFrostFactor.getValue();
		}else	if ( (me._cloudEffect > 0) ){
			
			# in the clouds layer the cloud-type and cloud-thickness drive the effect
			waterCatchEffect = surfaceTemperature * me._absoluteHumidity * me._cloudEffect;
			
		}else	if ( (me._absoluteHumidity > me._nAbsoluteHumidityMin.getValue()) and (me._temperature > -18) and (me._humidity == 100 ) ){
			
			# no liquid water below -18degC, so no icing. Only liquid water in air if dewpoint is below temperature (=rel humidity 100%).
			# cannot detect clouds sadly. So only use absolute humidity as 'indication' of ice accretion. Is wrong, I know...
			waterCatchEffect = surfaceTemperature * me._absoluteHumidity * me._nFrostWaterCatchFactor.getValue();
			
		}else{
			waterCatchEffect = 0;
		}
	
		return waterCatchEffect;
	},
	
	frost : func(){
		print("Environment::frost() ...");
		
		
		

		# cooling the windshield
		
		
		# Air effect factor 0.001 and min 0.1
		var eff_factor 	= me._nFrostAirEffectFactor.getValue() ;
		var eff_min	= me._nFrostAirEffectMin.getValue() ;
		
		var flowSpeed	= me._airspeed ; 	# (ft/s)
		var density = me._density ;
		
		# exchange Factor between Air and Windshield default 0.1 for V = 0
		var exchangeFactor = me._nFrostExchangeFactor.getValue() ;
		var eff = eff_min + flowSpeed * density * eff_factor;

# freeze windshield
		#	energie flow		= (exchange factor) * (massflow) * (Delta Temp)
		var  energyWindShield 		= eff * exchangeFactor * 0.937 * (me._temperature - cabin._windShield._temperature) ;# W
		
		var  energyWindShieldHeated 	= eff * exchangeFactor * 0.063 * (me._temperature - cabin._windShieldHeated._temperature) ;# W
		
		#print("frost| ",sprintf("windshield %0.3f W %0.3f W",energyWindShield,energyWindShieldHeated));
		
		# put the energie flow onto the windshield
		cabin._windShield.addWatt( energyWindShield ,me._dt);
		cabin._windShieldHeated.addWatt( energyWindShieldHeated ,me._dt);
		
		var waterCatchEffectFront = 0;
		var waterCatchEffectHeated = 0;
		
		
		waterCatchEffectFront = me.surfaceWaterCatchEffect(cabin._windShield._temperature);
		me._frostFront 	-= waterCatchEffectFront * me._dt;
		me._frostFront 	= global.clamp(me._frostFront,0.0,1.0);
		
		waterCatchEffectHeated = me.surfaceWaterCatchEffect(cabin._windShieldHeated._temperature);
		me._frostHeated 	-= waterCatchEffectHeated * me._dt;
		me._frostHeated 	= global.clamp(me._frostHeated,0.0,1.0);
		
		#print("frost| ",sprintf("windshield: %0.2f, T: %0.2f, F: %0.2f,  a: %0.2f",me._windshieldTemperature,temperature,me._frost,adjust));
		
		interpolate("/environment/aircraft-effects/frost-level", me._frost ,me._dt);
		interpolate("/environment/aircraft-effects/frost-level-front", me._frostFront ,me._dt);
		interpolate("/environment/aircraft-effects/frost-level-heated", me._frostHeated ,me._dt);
		
		
# freeze propeller
		
		# max cooling capacity 10W / °C
		var energyPropeller 		= 2  ;# W static exchange
		energyPropeller 		+= 1 * global.norm(flowSpeed,0,350); # W airflow
		energyPropeller 		+= 7 * global.norm(getprop("/engines/engine/rpm"),0,2030); # W PRM
		energyPropeller 		*= (me._temperature - cabin._propeller._temperature); # Delta °C
		
		cabin._propeller.addWatt( energyPropeller ,me._dt);
		
		var waterCatchEffectPropeller 	= 0;
		
		waterCatchEffectPropeller = me.surfaceWaterCatchEffect(cabin._propeller._temperature);
		me._frostPropeller 	-= waterCatchEffectPropeller * me._dt;
		me._frostPropeller 	= global.clamp(me._frostPropeller,0.0,1.0);
		
		interpolate("/environment/aircraft-effects/frost-level-Propeller", me._frostPropeller ,me._dt);
		
		
# freeze all boots 
		
		var waterCatchEffectBoots = 0;
		# surface temperature is environment temperature
		waterCatchEffectBoots = me.surfaceWaterCatchEffect(me._temperature);
		
		
		me._frostWingLeft 		-= waterCatchEffectBoots * me._dt;
		me._frostWingLeft 		= global.clamp(me._frostWingLeft,0.0,1.0);
		
		me._frostWingRight 		-= waterCatchEffectBoots * me._dt;
		me._frostWingRight 		= global.clamp(me._frostWingRight,0.0,1.0);
		
		me._frostVStab 		-= waterCatchEffectBoots * me._dt;
		me._frostVStab 		= global.clamp(me._frostVStab,0.0,1.0);
		
		me._frostHStabLeft 		-= waterCatchEffectBoots * me._dt;
		me._frostHStabLeft 		= global.clamp(me._frostHStabLeft,0.0,1.0);
		
		me._frostHStabRight 	-= waterCatchEffectBoots * me._dt;
		me._frostHStabRight 	= global.clamp(me._frostHStabRight,0.0,1.0);
		
				
		interpolate("/environment/aircraft-effects/frost-level-WingLeft", me._frostWingLeft, me._dt);
		interpolate("/environment/aircraft-effects/frost-level-WingRight", me._frostWingRight, me._dt);
		interpolate("/environment/aircraft-effects/frost-level-VStab", me._frostVStab, me._dt);
		interpolate("/environment/aircraft-effects/frost-level-HStabLeft", me._frostHStabLeft, me._dt);
		interpolate("/environment/aircraft-effects/frost-level-HStabRight", me._frostHStabRight, me._dt);
		
		
		
		
		#interpolate("/environment/aircraft-effects/frost-level-noice", me._frostNoice ,me._dt);
		
# 		print("frost| ",sprintf("windshield %0.3fJ (%0.1f°C),  %0.3fJ (%0.1f°C)",
# #				cabin._windShield._energy,
# 			  energyWindShield,
# 				cabin._windShield._temperature,
# #				cabin._windShieldHeated._energy,
# 			  energyWindShieldHeated,
# 				cabin._windShieldHeated._temperature
# 				       ));
		
	},
	fog : func(){
		#var fog 	= getprop("/environment/aircraft-effects/fog-level");
		var fogFront 	= getprop("/environment/aircraft-effects/fog-level-front");
		var fogHeated 	= getprop("/environment/aircraft-effects/fog-level-heated");
		
		var effectFront = 0;
		var effectHeated = 0;
		
		var deltaHumidity = cabin._absoluteHumidity - 0.003;
		
			
		effectFront 	+=  deltaHumidity * (cabin._windShield._temperature - 12.0);
		effectHeated 	+=  deltaHumidity * (cabin._windShieldHeated._temperature - 12.0);
			
		if (deiceSystem._WindshieldDefrost._state == 1){
			effectFront	+= 0.05;
			effectHeated	+= 0.05;
		}
		
		
		
		
		fogFront 	-= effectFront * me._dt;
		fogFront 	= global.clamp(fogFront,0.0,1.0);
		
		fogHeated 	-= effectHeated * me._dt;
		fogHeated 	= global.clamp(fogHeated,0.0,1.0);
		
# 				print("fog  | ",sprintf("windshield: %0.1f°C , hum: %0.5f , effect: %f , level: %f",
# 					cabin._windShield._temperature,
# 					cabin._absoluteHumidity,
# 					effectFront,
# 					fogFront
# 			    
# 				));
				
				
		
		interpolate("/environment/aircraft-effects/fog-level", fogFront ,me._dt);
		interpolate("/environment/aircraft-effects/fog-level-front", fogFront ,me._dt);
		interpolate("/environment/aircraft-effects/fog-level-heated", fogHeated ,me._dt);
		
		
	},
		
};

var environment = Environment.new("/extra500/environment","Environment");

