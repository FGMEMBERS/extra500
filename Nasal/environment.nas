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
#       Date:             15.01.2016
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
		
		# all front faceing surfaces not heated catching ice 
		m._frostFuslageFront 		= getprop("/environment/aircraft-effects/frost-level-FuslageFront");
		# windshield
		m._frostWindshieldFront 	= getprop("/environment/aircraft-effects/frost-level-WindshieldFront");
		m._frostWindshieldHeated 	= getprop("/environment/aircraft-effects/frost-level-WindshieldHeated");
		m._frostNoice 			= getprop("/environment/aircraft-effects/frost-level-noice");
		# propeller
		m._frostPropellerBlade 		= getprop("/environment/aircraft-effects/frost-level-PropellerBlade");
		# boots		
		m._frostWingLHBootInner 	= getprop("/environment/aircraft-effects/frost-level-WingLHBootInner");
		m._frostWingLHBootOuter 	= getprop("/environment/aircraft-effects/frost-level-WingLHBootOuter");
		m._frostWingRHBootInner 	= getprop("/environment/aircraft-effects/frost-level-WingRHBootInner");
		m._frostWingRHBootOuter 	= getprop("/environment/aircraft-effects/frost-level-WingRHBootOuter");
		m._frostVStab 			= getprop("/environment/aircraft-effects/frost-level-VStab", );
		m._frostHStabLH			= getprop("/environment/aircraft-effects/frost-level-HStabLH", );
		m._frostHStabRH			= getprop("/environment/aircraft-effects/frost-level-HStabRH", );
		# pitot
		m._frostPitotLH			= getprop("/environment/aircraft-effects/frost-level-PitotLH", );
		m._frostPitotRH			= getprop("/environment/aircraft-effects/frost-level-PitotRH", );
		# static
		m._frostStaticLH		= getprop("/environment/aircraft-effects/frost-level-StaticLH", );
		m._frostStaticRH		= getprop("/environment/aircraft-effects/frost-level-StaticRH", );
		# stall
		m._frostStallWarnHeat		= getprop("/environment/aircraft-effects/frost-level-StallWarnHeat", );
		# inlet
		m._frostInlet			= getprop("/environment/aircraft-effects/frost-level-Inlet", );
		
		
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
		print("\nEnvironment::detectClouds() ...");
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
		
		if(getprop("/environment/metar/valid")){
		
			var nClouds 	= props.globals.getNode("/environment/metar/clouds");
			
			var aircraftAlt = getprop("/position/altitude-ft");
			var station_alt = getprop("/environment/metar/station-elevation-ft");
			
			
			print (sprintf("aircraft alt %5.0f altitude-ft",aircraftAlt));
			print (sprintf("\t%s %12s %s %s %s = %s","type","name","elevation","thickness","elevationMax","effect"));
				
			foreach(var layer; nClouds.getChildren("layer")){
				var elevation 	= layer.getNode("elevation-ft").getValue();
				var thickness 	= layer.getNode("thickness-ft").getValue();
				var type 	= layer.getNode("coverage-type").getValue();
				var name 	= layer.getNode("coverage").getValue();
				
				
				var thicknessRadius 	= thickness/2;
				#var elevationMsl	= elevation;
				var elevationMin 	= elevation;
				var elevationMax 	= elevation + thickness;
				
				
				
				var strRow = sprintf("\t%4i %12s %9.0f %9.0f %12.0f",type,name,elevation,thickness,elevationMax);
				
				if (aircraftAlt > elevation and aircraftAlt < elevationMax){
					
					var cloudCenterDistanceEffect = (1.5-(math.abs(aircraftAlt - (elevation + thicknessRadius)) / thicknessRadius));
					var eff = cloudCenterDistanceEffect * cloudTypeEffect[type];
					
					cloudEffectSum += eff;
					
					strRow ~= sprintf(" =  %6.5f",eff);
									
				}
				
				print(strRow);
			}
		
		}
		
		me._cloudEffect = global.clamp(cloudEffectSum,0.0,1.0);
		
		print (sprintf("Cloud effect sum %1.5f",me._cloudEffect));
		
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
		
		var energyFlow = 0;
		
# freeze windshield
		# cooling the windshield
		
		
		# Air effect factor 0.001 and min 0.1
		var eff_factor 	= me._nFrostAirEffectFactor.getValue() ;
		var eff_min	= me._nFrostAirEffectMin.getValue() ;
		
		var flowSpeed	= me._airspeed ; 	# (ft/s)
		var density = me._density ;
		
		# exchange Factor between Air and Windshield default 0.1 for V = 0
		var exchangeFactor = me._nFrostExchangeFactor.getValue() ;
		var eff = eff_min + flowSpeed * density * eff_factor;
				
		# put the energie flow onto the windshield
		#	energie flow		= (exchange factor) * (massflow) * (Delta Temp)
		
		#var debugText = "frost| windshield ";
		var  energyFlow 		= eff * exchangeFactor * 0.937 * (me._temperature - cabin._windShield._temperature) ;# W
		cabin._windShield.addWatt( energyFlow ,me._dt);
		#debugText ~= sprintf("%0.3f W ",energyFlow);
		
		var  energyFlow 	= eff * exchangeFactor * 0.063 * (me._temperature - cabin._windShieldHeated._temperature) ;# W
		cabin._windShieldHeated.addWatt( energyFlow ,me._dt);
		#debugText ~= sprintf("%0.3f W ",energyFlow);
		#print(debugText);
		
		# put the water(ice) on the surface
		me._frostWindshieldFront 	-= me.surfaceWaterCatchEffect(cabin._windShield._temperature) * me._dt;
		me._frostWindshieldFront 	 = global.clamp(me._frostWindshieldFront,0.0,1.0);
		
		me._frostWindshieldHeated -= me.surfaceWaterCatchEffect(cabin._windShieldHeated._temperature) * me._dt;
		me._frostWindshieldHeated  = global.clamp(me._frostWindshieldHeated,0.0,1.0);
		
		#print("frost| ",sprintf("windshield: %0.2f, T: %0.2f, F: %0.2f,  a: %0.2f",me._windshieldTemperature,temperature,me._frost,adjust));
		
		interpolate("/environment/aircraft-effects/frost-level-WindshieldFront", me._frostWindshieldFront ,me._dt);
		interpolate("/environment/aircraft-effects/frost-level-WindshieldHeated", me._frostWindshieldHeated ,me._dt);
		
		
# freeze propeller
		 
		# heating 600 W 
		# delta T  60 °C
		# max cooling capacity 10W / °C
		eff 	= 2  ;# W static exchange
		eff 	+= 1 * global.norm(flowSpeed,0,350); # W airflow
		eff 	+= 7 * global.norm(getprop("/engines/engine/rpm"),0,2030); # W PRM
		
		energyFlow 	= eff * (me._temperature - cabin._propeller._temperature); # Delta °C
		cabin._propeller.addWatt( energyFlow ,me._dt);
		
		# put the water(ice) on the surface
		me._frostPropellerBlade 	-= me.surfaceWaterCatchEffect(cabin._propeller._temperature) * me._dt;
		me._frostPropellerBlade 	= global.clamp(me._frostPropellerBlade,0.0,1.0);
		
		interpolate("/environment/aircraft-effects/frost-level-PropellerBlade", me._frostPropellerBlade ,me._dt);

# freeze pitot
		# heating 110W 
		# delta T  60°C
		# max cooling capacity 1,8W / °C
		eff 		=  0.1  ;# W static exchange
		eff 		+= 1.7 * global.norm(flowSpeed,0,350); # W airflow
		
		
		energyFlow 		= eff * (me._temperature - cabin._pitotLH._temperature); # Delta °C
		cabin._pitotLH.addWatt( energyFlow ,me._dt);
		
		energyFlow 		= eff * (me._temperature - cabin._pitotRH._temperature); # Delta °C
		cabin._pitotRH.addWatt( energyFlow ,me._dt);
		
		# put the water(ice) on the surface
		me._frostPitotLH 	-= me.surfaceWaterCatchEffect(cabin._pitotLH._temperature) * me._dt;
		me._frostPitotLH 	 = global.clamp(me._frostPitotLH,0.0,1.0);
		
		me._frostPitotRH 	-= me.surfaceWaterCatchEffect(cabin._pitotRH._temperature) * me._dt;
		me._frostPitotRH 	 = global.clamp(me._frostPitotRH,0.0,1.0);
		
		interpolate("/environment/aircraft-effects/frost-level-PitotLH", me._frostPitotLH ,me._dt);
		interpolate("/environment/aircraft-effects/frost-level-PitotRH", me._frostPitotRH ,me._dt);
		
# freeze static : only get cooled but not catching ice
		
		# heating 16W 
		# delta T  60°C
		# max cooling capacity 0,25W / °C
		eff 		=  0.01  ;# W static exchange
		eff 		+= 0.24 * global.norm(flowSpeed,0,350); # W airflow
		
		energyFlow 		= eff * (me._temperature - cabin._staticLH._temperature); # Delta °C
		cabin._staticLH.addWatt( energyFlow ,me._dt);
		
		energyFlow 		= eff * (me._temperature - cabin._staticRH._temperature); # Delta °C
		cabin._staticRH.addWatt( energyFlow ,me._dt);
		
		# put the water(ice) on the surface
# 		me._frostStaticLH 	-= me.surfaceWaterCatchEffect(cabin._staticLH._temperature) * me._dt;
# 		me._frostStaticLH 	 = global.clamp(me._frostStaticLH,0.0,1.0);
# 		
# 		me._frostStaticRH 	-= me.surfaceWaterCatchEffect(cabin._staticRH._temperature) * me._dt;
# 		me._frostStaticRH 	 = global.clamp(me._frostStaticRH,0.0,1.0);
# 		
# 		interpolate("/environment/aircraft-effects/frost-level-StaticLH", me._frostStaticLH ,me._dt);
# 		interpolate("/environment/aircraft-effects/frost-level-StaticRH", me._frostStaticRH ,me._dt);
		
# freeze stall warner
		# heating 130W 
		# delta T  60°C
		# max cooling capacity 2,1W / °C
		eff 		=  0.01  ;# W static exchange
		eff 		+= 2.09 * global.norm(flowSpeed,0,350); # W airflow
		
		energyFlow 		= eff * (me._temperature - cabin._stallWarnHeat._temperature); # Delta °C
		cabin._stallWarnHeat.addWatt( energyFlow ,me._dt);
		
		
		# put the water(ice) on the surface
		me._frostStallWarnHeat 	-= me.surfaceWaterCatchEffect(cabin._stallWarnHeat._temperature) * me._dt;
		me._frostStallWarnHeat 	 = global.clamp(me._frostStallWarnHeat,0.0,1.0);
		
		interpolate("/environment/aircraft-effects/frost-level-StallWarnHeat", me._frostStallWarnHeat ,me._dt);
		
		
# freeze all boots and front surfaces
		
		var waterCatchEffectSurface = 0;
		# surface temperature is environment temperature
		waterCatchEffectSurface = me.surfaceWaterCatchEffect(me._temperature);
		
		# put the water(ice) on the surface
		waterCatchEffectSurface *= me._dt;
		
		me._frostWingLHBootInner 	-= waterCatchEffectSurface;
		me._frostWingLHBootInner 	 = global.clamp(me._frostWingLHBootInner,0.0,1.0);
		interpolate("/environment/aircraft-effects/frost-level-WingLHBootInner", me._frostWingLHBootInner, me._dt);
		
		me._frostWingLHBootOuter 	-= waterCatchEffectSurface;
		me._frostWingLHBootOuter 	 = global.clamp(me._frostWingLHBootOuter,0.0,1.0);
		interpolate("/environment/aircraft-effects/frost-level-WingLHBootOuter", me._frostWingLHBootOuter, me._dt);
		
		me._frostWingRHBootInner 	-= waterCatchEffectSurface;
		me._frostWingRHBootInner 	 = global.clamp(me._frostWingRHBootInner,0.0,1.0);
		interpolate("/environment/aircraft-effects/frost-level-WingRHBootInner", me._frostWingRHBootInner, me._dt);
		
		me._frostWingRHBootOuter 	-= waterCatchEffectSurface;
		me._frostWingRHBootOuter 	 = global.clamp(me._frostWingRHBootOuter,0.0,1.0);
		interpolate("/environment/aircraft-effects/frost-level-WingRHBootOuter", me._frostWingRHBootOuter, me._dt);
		
		me._frostVStab 		-= waterCatchEffectSurface;
		me._frostVStab 		 = global.clamp(me._frostVStab,0.0,1.0);
		interpolate("/environment/aircraft-effects/frost-level-VStab", me._frostVStab, me._dt);
		
		me._frostHStabLH 	-= waterCatchEffectSurface;
		me._frostHStabLH 	 = global.clamp(me._frostHStabLH,0.0,1.0);
		interpolate("/environment/aircraft-effects/frost-level-HStabLH", me._frostHStabLH, me._dt);
		
		me._frostHStabRH 	-= waterCatchEffectSurface;
		me._frostHStabRH 	 = global.clamp(me._frostHStabRH,0.0,1.0);
		interpolate("/environment/aircraft-effects/frost-level-HStabRH", me._frostHStabRH, me._dt);
				
		me._frostFuslageFront 	-= waterCatchEffectSurface;
		me._frostFuslageFront 	 = global.clamp(me._frostFuslageFront,0.0,1.0);
		interpolate("/environment/aircraft-effects/frost-level-FuslageFront", me._frostFuslageFront ,me._dt);
		
# freeze inlet
		
		# heating 600 W 
		# delta T  60 °C
		# max cooling capacity 10W / °C
		eff 	= 2  ;# W static exchange
		eff 	+= 3 * global.norm(flowSpeed,0,350); # W airflow
		eff 	+= 5 * global.norm(getprop("/engines/engine/rpm"),0,2030); # W PRM
		
		energyFlow 	= eff * (me._temperature - cabin._inlet._temperature); # Delta °C
		cabin._inlet.addWatt( energyFlow ,me._dt);
		
		# put the water(ice) on the surface
		me._frostInlet 	-= me.surfaceWaterCatchEffect(cabin._inlet._temperature) * me._dt;
		me._frostInlet 	= global.clamp(me._frostInlet,0.0,1.0);
		
		interpolate("/environment/aircraft-effects/frost-level-Inlet", me._frostInlet ,me._dt);

		
		
		
		#interpolate("/environment/aircraft-effects/frost-level-noice", me._frostNoice ,me._dt);
		
# 		print("frost| ",sprintf("windshield %0.3fJ (%0.1f°C),  %0.3fJ (%0.1f°C)",
# #				cabin._windShield._energy,
# 			  energyWindShield,
# 				cabin._windShield._temperature,
# #				cabin._windShieldHeated._energy,
# 			  energyWindShieldHeated,
# 				cabin._windShieldHeated._temperature
# 				       ));
	
		
		print(sprintf("environment   %7.3f°C",me._temperature));
		print(sprintf("              %7s %7s","surface","frost"));
		
		
		print(sprintf("Fuslage front %7.3f°C %2.5f",me._temperature, me._frostFuslageFront));
		print(sprintf("WingLH Boot I %7.3f°C %2.5f",me._temperature, me._frostWingLHBootInner));
		print(sprintf("WingLH Boot O %7.3f°C %2.5f",me._temperature, me._frostWingLHBootOuter));
		print(sprintf("WingRH Boot I %7.3f°C %2.5f",me._temperature, me._frostWingRHBootInner));
		print(sprintf("WingRH Boot O %7.3f°C %2.5f",me._temperature, me._frostWingRHBootOuter));
		print(sprintf("VStab         %7.3f°C %2.5f",me._temperature, me._frostVStab));
		print(sprintf("HStabLH       %7.3f°C %2.5f",me._temperature, me._frostHStabLH));
		print(sprintf("HStabRH       %7.3f°C %2.5f",me._temperature, me._frostHStabRH));
		
		print(sprintf("windschild    %7.3f°C %2.5f",cabin._windShield._temperature, me._frostWindshieldFront));
		print(sprintf("windschild he %7.3f°C %2.5f",cabin._windShieldHeated._temperature, me._frostWindshieldHeated));
		print(sprintf("propeller     %7.3f°C %2.5f",cabin._propeller._temperature, me._frostPropellerBlade));
		print(sprintf("pitot LH      %7.3f°C %2.5f",cabin._pitotLH._temperature, me._frostPitotLH));
		print(sprintf("pitot RH      %7.3f°C %2.5f",cabin._pitotRH._temperature, me._frostPitotRH));
		print(sprintf("static LH     %7.3f°C %2.5f",cabin._staticLH._temperature, me._frostStaticLH));
		print(sprintf("static RH     %7.3f°C %2.5f",cabin._staticRH._temperature, me._frostStaticRH));
		print(sprintf("stall warner  %7.3f°C %2.5f",cabin._stallWarnHeat._temperature, me._frostStallWarnHeat));
		print(sprintf("inlet         %7.3f°C %2.5f",cabin._inlet._temperature, me._frostInlet));
		
	},
	fog : func(){
		#var fog 	= getprop("/environment/aircraft-effects/fog-level");
		var fogFront 	= getprop("/environment/aircraft-effects/fog-level-WindshieldFront");
		var fogHeated 	= getprop("/environment/aircraft-effects/fog-level-WindshieldHeated");
		
		var effectFront = 0;
		var effectHeated = 0;
		
		var deltaHumidity = 0;
		
		if (cabin._absoluteHumidity > 0.003){
			deltaHumidity = cabin._absoluteHumidity - 0.003;
		}
			
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
		interpolate("/environment/aircraft-effects/fog-level-WindshieldFront", fogFront ,me._dt);
		interpolate("/environment/aircraft-effects/fog-level-WindshieldHeated", fogHeated ,me._dt);
		
		
	},
		
};

var environment = Environment.new("/extra500/environment","Environment");

