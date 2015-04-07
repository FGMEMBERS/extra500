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
#      Last change:      Dirk Dittmann
#      Date:             07.04.15
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
		m._mass = 12 ; # kg
		m._specificHeatCapacity = 1.47 ;# kJ / (kg*K) glas
		m._energie = 0.0 ;# kJ
		m._temperature = temp; #°C
		m._nTemperature = m._nRoot.initNode("temperature-degc",m._temperature,"DOUBLE",1);
		m._nEnergie = m._nRoot.initNode("energie-kJ",m._energie,"DOUBLE",1);
		
		return m;
	},
	setTemperatur : func(temp){
		me._temperature = temp;
		me._nTemperature.setValue(me._temperature);
		
		me._energie = me._specificHeatCapacity * (me._mass * me._temperature);
		me._nEnergie.setValue(me._energie);
	},
	addTemperature : func(temp){
		me._temperature += temp;
		me._nTemperature.setValue(me._temperature);
		
		me._energie = me._specificHeatCapacity * (me._mass * me._temperature);
		me._nEnergie.setValue(me._energie);
	},
	addWatt : func(watt=0.0,dt=1.0){
		var energieFlow = (watt/1000) * dt;
		me._energie += energieFlow;
		me._nEnergie.setValue(me._energie);
		
		me._temperature = me._energie / (me._mass * me._specificHeatCapacity);
		me._nTemperature.setValue(me._temperature);
		
	},
	setEnergie : func(kJ){
		
		me._energie =kJ;
		me._nEnergie.setValue(me._energie);
		
		me._temperature = me._energie / (me._mass * me._specificHeatCapacity);
		me._nTemperature.setValue(me._temperature);
		
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
		m._oxygenDeltaT 	= 15.0;
		m._timerLoop = nil;
		
		m._windShield 		=  TemperatureSurface.new(root~"/windShield","windshield",environment._temperature);
		m._windShield._mass = 11.244 ; # kg
		m._windShield.setTemperatur(environment._temperature);
		
		m._windShieldHeated 	=  TemperatureSurface.new(root~"/windShieldHeated","windshieldHeated",environment._temperature);
		m._windShieldHeated._mass = 0.756 ; # kg
		m._windShieldHeated.setTemperatur(environment._temperature);
		
		
		
		
		return m;
	},
	init : func(instance=nil){
		if (instance==nil){instance=me;}
		me.parents[1].init(instance);
		me._timerLoop = maketimer(me._oxygenDeltaT,me,CabinClass.oxygen);
		me._timerLoop.start();
	},
	oxygen : func(){
		
		 
		var cabinPressureAlt = me._nCabinPressureAltFt.getValue();
		
		if (cabinPressureAlt > 9600.0){# ab 9600 ft
			me._oxygenRate = -((cabinPressureAlt * 0.00000053 - 0.0045321637) * me._oxygenDeltaT);
		}else{
			me._oxygenRate = 0.0025 * me._oxygenDeltaT;
		}
		
		me._oxygenLevel += me._oxygenRate;
				
		me._oxygenLevel = global.clamp(me._oxygenLevel,0.001,1.0);
		
		var blackoutOn 		= me._blackoutOnsetG * (me._oxygenLevel);
		var blackoutComplete 	= me._blackoutCompleteG * (me._oxygenLevel);
		
		
		blackoutOn 		= global.clamp(blackoutOn,0.1,me._blackoutOnsetG);
		blackoutComplete 	= global.clamp(blackoutComplete,1.1,me._blackoutCompleteG);
		
		
		#print(sprintf("%f/%f : %f += %f",blackoutOn,blackoutComplete,me._oxygenLevel,me._oxygenRate));
		
		interpolate(me._nBlackoutOnsetG,blackoutOn,me._oxygenDeltaT);
		interpolate(me._nBlackoutCompleteG,blackoutComplete,me._oxygenDeltaT);
		
		
	},

};

var cabin = CabinClass.new("/extra500/cabin","Cabin");