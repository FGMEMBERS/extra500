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
#      Date: Jul 02 2013
#
#       Last change:      Eric van den Berg
#       Date:             31.01.2016
#
# MM Page 563

var TemperatureSurface = {
	new : func(root,name,temp=0.0){
		var m = { 
			parents : [
				TemperatureSurface, 
				ServiceClass.new(root,name)
			]
		};
		m._temperature = temp; #°C
		m._deltaTemp = 0;
		m._nTemperature = m._nRoot.initNode("temperature-degc",m._temperature,"DOUBLE",1);
		
		return m;
	},
	setTemperatur : func(temp){
		me._temperature = temp;
		me._nTemperature.setValue(me._temperature);
		
	},
	addTemperature : func(temp){
		me._temperature += temp;
		me._nTemperature.setValue(me._temperature);
	},
	addWatt : func(watt=0.0,dt=1.0){
		me._deltaTemp = watt * dt / (me._mass * me._specificHeatCapacity);
		me.addTemperature(me._deltaTemp);
	},
		
};


var CabinClass = {
	new : func(root,name){
		var m = { 
			parents : [
				CabinClass,
				ServiceClass.new(root,name)
			]
		};
		
		var initTemperature = environment._temperature;
		#initTemperature = 0;	
		m._nCabinPressure	= m._nRoot.initNode("hasPressureWarning",0,"BOOL");
		m._nBleedOvertemp	= m._nRoot.initNode("hasBleedOvertempWarning",0,"BOOL");
		
		m._nBlackoutOnsetG	= props.globals.initNode("/sim[0]/rendering[0]/redout[0]/parameters[0]/blackout-onset-g",0,"DOUBLE");
		m._blackoutOnsetG	= 3.5;# FG default
		m._nBlackoutOnsetG.setValue(m._blackoutOnsetG);
		
		m._nBlackoutCompleteG	= props.globals.initNode("/sim[0]/rendering[0]/redout[0]/parameters[0]/blackout-complete-g",0,"DOUBLE");
		m._blackoutCompleteG	= 5.0;# FG default
		m._nBlackoutCompleteG.setValue(m._blackoutCompleteG);
		
		m._nCabinPressureAltFt  = props.globals.initNode("/instrumentation[0]/cabin-altitude[0]/pressure-alt-ft",0,"DOUBLE");
		m._oxygenLevel 		= 1.0;
		m._oxygenRate 		= 0.05; # Levelchange/deltaT
		m._dt 	= 1.0;
		m._timerLoop = nil;
		
		m._windShield 		=  TemperatureSurface.new(root~"/windShield","windshield",initTemperature);
		m._windShield._mass = 11.244 ; # kg
		m._windShield._specificHeatCapacity = 1470 ;# J / (kg*K) acryl
		m._windShield.setTemperatur(initTemperature);
		
		m._windShieldHeated 	=  TemperatureSurface.new(root~"/windShieldHeated","windshieldHeated",initTemperature);
		m._windShieldHeated._mass = 0.756 ; # kg
		m._windShieldHeated._specificHeatCapacity = 1470 ;# J / (kg*K) acryl
		m._windShieldHeated.setTemperatur(initTemperature);
		
		m._propeller 	=  TemperatureSurface.new(root~"/propeller","propeller",initTemperature);
		m._propeller._mass = 1.5 ; # kg, heated part (5 blades, inner front part; prop = 46kg, one blade about 8kg, heat boot per blade ~0.3kg)
		m._propeller._specificHeatCapacity = 1000 ;# J / (kg*K) general plastic
		m._propeller.setTemperatur(initTemperature);
		
		m._pitotLH 	=  TemperatureSurface.new(root~"/pitotLH","pitotLH",initTemperature);
		m._pitotLH._mass = 0.1 ; # kg, heated part
		m._pitotLH._specificHeatCapacity = 500 ;# J / (kg*K) Stainless steel
		m._pitotLH.setTemperatur(initTemperature);
		
		m._pitotRH 	=  TemperatureSurface.new(root~"/pitotRH","pitotRH",initTemperature);
		m._pitotRH._mass = 0.1 ; # kg
		m._pitotRH._specificHeatCapacity = 500 ;# J / (kg*K) Stainless steel
		m._pitotRH.setTemperatur(initTemperature);
		
		m._staticLH 	=  TemperatureSurface.new(root~"/staticLH","staticLH",initTemperature);
		m._staticLH._mass = 0.05 ; # kg, heated part
		m._staticLH._specificHeatCapacity = 920 ;# J / (kg*K) aluminum alloy
		m._staticLH.setTemperatur(initTemperature);
		
		m._staticRH 	=  TemperatureSurface.new(root~"/staticRH","staticRH",initTemperature);
		m._staticRH._mass = 0.05 ; # kg
		m._staticRH._specificHeatCapacity = 920 ;# J / (kg*K) aluminum alloy
		m._staticRH.setTemperatur(initTemperature);
		
		m._stallWarnHeat 	=  TemperatureSurface.new(root~"/stallWarnHeat","stallWarnHeat",initTemperature);
		m._stallWarnHeat._mass = 0.1 ; # kg
		m._stallWarnHeat._specificHeatCapacity = 920 ;# J / (kg*K) aluminum alloy
		m._stallWarnHeat.setTemperatur(initTemperature);
		
		m._inlet 	=  TemperatureSurface.new(root~"/inlet","inlet",initTemperature);
		m._inlet._mass = 1.8 ; # kg, heated part
		m._inlet._specificHeatCapacity = 500 ;# J / (kg*K) Stainless steel
		m._inlet.setTemperatur(initTemperature);
		
		m._absoluteHumidity = 0;
		
		return m;
	},
	init : func(instance=nil){
		if (instance==nil){instance=me;}
		me.parents[1].init(instance);
		me._timerLoop = maketimer(me._dt,me,CabinClass.update);
		me._timerLoop.start();
		
		me._absoluteHumidity = getprop("/environment/a-kg-per-m3");
		
	},
	update : func(){
		me.oxygen();
		me.humidity();
	},
	oxygen : func(){
		
		 
		var cabinPressureAlt = me._nCabinPressureAltFt.getValue();
		
		if (cabinPressureAlt > 18000.0){# ab 9600 ft
			me._oxygenRate = -((cabinPressureAlt * 0.00000053 - 0.0045321637) * me._dt);
		}else{
			me._oxygenRate = 0.0025 * me._dt;
		}
		
		me._oxygenLevel += me._oxygenRate;
				
		me._oxygenLevel = global.clamp(me._oxygenLevel,0.001,1.0);
		
		var blackoutOn 		= me._blackoutOnsetG * (me._oxygenLevel);
		var blackoutComplete 	= me._blackoutCompleteG * (me._oxygenLevel);
		
		
		blackoutOn 		= global.clamp(blackoutOn,0.1,me._blackoutOnsetG);
		blackoutComplete 	= global.clamp(blackoutComplete,1.1,me._blackoutCompleteG);
		
		
		#print(sprintf("%f/%f : %f += %f",blackoutOn,blackoutComplete,me._oxygenLevel,me._oxygenRate));
		if ( getprop("/gear/gear/wow") == 1 ){
			interpolate(me._nBlackoutOnsetG,me._blackoutOnsetG,me._dt);
			interpolate(me._nBlackoutCompleteG,me._blackoutCompleteG,me._dt);
		}else{
			interpolate(me._nBlackoutOnsetG,blackoutOn,me._dt);
			interpolate(me._nBlackoutCompleteG,blackoutComplete,me._dt);
		}
		
	},
	humidity : func(){
		var absoluteHumidity = getprop("/environment/a-kg-per-m3");
		var rate = 0;
		
		
		var deltaHumidity = (absoluteHumidity - me._absoluteHumidity);
		
		if (eSystem.switch.EnvironmentalAir._state == 1){
			rate += 0.02;
		}
		
		if (eSystem.switch.Pressure._state == -1){
			rate += 0.2;
		}
		
		if( 	   getprop("/extra500/door/lowerpass/state")>0 
			or getprop("/extra500/door/upperpass/state")>0
			or getprop("/extra500/door/emergencyexit/state")>0
		){
			rate += 0.4;
		}
		
# 		print("cabin| ",sprintf("delta: %0.5f , hum: %0.5f , fog: %0.5f",
# 					deltaHumidity,
# 					rate,
# 					me._absoluteHumidity
# 				));
		
		me._absoluteHumidity += deltaHumidity * rate * me._dt;
		
	},

};

var cabin = CabinClass.new("/extra500/cabin","Cabin");
