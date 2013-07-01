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
#      Date: Jun 30 2013
#
#      Last change:      Dirk Dittmann
#      Date:             30.06.13
#


var AnnunciatorLedClass = {
	new : func(root,name="Annunciator LED"){
		var m = { 
			parents : [
				AnnunciatorLedClass, 
				ServiceClass.new(root,name)
			]
		};
		m._value		= 0;
		m._nState		= m._nRoot.initNode("state",0.0,"DOUBLE",1);
		
		m._on = 0;
		m._test = 0;
		m._state = 0;
		m._brightness = 0;
		
		return m;
	},
	_checkState : func(){
		if (me._test == 1){
			me._state = 1.0
		}else{
			me._state = me._on * me._brightness;
		}
		me._nState.setValue(me._state);
	},
	setState : func(value){
		me._on = value;
		me._checkState();
		
	},
	setBrightness : func(value,test){
		me._brightness 	= value;
		me._test 	= test;
		me._checkState();
		
	},
	
};

var AnnunciatorClass = {
	new : func(root,name,watt=12.0){
		var m = { 
			parents : [
				AnnunciatorClass,
				ConsumerClass.new(root,name,watt)
			]
		};
		
		#m.nGenAmps = props.globals.initNode("extra500/electric/eBox/GeneratorShunt/indicatedAmpere",0.0,"DOUBLE");
		#m.nBatAmps = props.globals.initNode("extra500/electric/eBox/BatteryShunt/indicatedAmpere",0.0,"DOUBLE");
		
		#m._backlight = LedClass.new("extra500/instrumentation/DIP/Backlight","DIP Backlight","extra500/system/dimming/Instrument",0.2);
		

		m._leds = {};
		
		m._leds["GeneratorFail"] 		= AnnunciatorLedClass.new("extra500/panel/Annunciator/GeneratorFail");
		m._leds["AFTDoor"] 			= AnnunciatorLedClass.new("extra500/panel/Annunciator/AFTDoor");
		m._leds["StallHeat"] 			= AnnunciatorLedClass.new("extra500/panel/Annunciator/StallHeat");
		m._leds["OilPress"] 			= AnnunciatorLedClass.new("extra500/panel/Annunciator/OilPress");
		m._leds["ChipDetection"] 		= AnnunciatorLedClass.new("extra500/panel/Annunciator/ChipDetection");
		m._leds["HydraulicPump"] 		= AnnunciatorLedClass.new("extra500/panel/Annunciator/HydraulicPump");
		m._leds["GearWarn"] 			= AnnunciatorLedClass.new("extra500/panel/Annunciator/GearWarn");
		m._leds["StallWarn"] 			= AnnunciatorLedClass.new("extra500/panel/Annunciator/StallWarn");
		m._leds["WindshieldHeatFail"] 		= AnnunciatorLedClass.new("extra500/panel/Annunciator/WindshieldHeatFail");
		m._leds["FuelPress"] 			= AnnunciatorLedClass.new("extra500/panel/Annunciator/FuelPress");
		m._leds["PitotHeatLeft"] 		= AnnunciatorLedClass.new("extra500/panel/Annunciator/PitotHeatLeft");
		m._leds["PitotHeatRight"] 		= AnnunciatorLedClass.new("extra500/panel/Annunciator/PitotHeatRight");
		m._leds["Flaps"] 			= AnnunciatorLedClass.new("extra500/panel/Annunciator/Flaps");
		m._leds["CabinPressure"] 		= AnnunciatorLedClass.new("extra500/panel/Annunciator/CabinPressure");
		m._leds["BleedOvertemp"] 		= AnnunciatorLedClass.new("extra500/panel/Annunciator/BleedOvertemp");
		m._leds["StaticHeatLeft"] 		= AnnunciatorLedClass.new("extra500/panel/Annunciator/StaticHeatLeft");
		m._leds["StaticHeatRight"] 		= AnnunciatorLedClass.new("extra500/panel/Annunciator/StaticHeatRight");
		m._leds["FuelTransLeft"] 		= AnnunciatorLedClass.new("extra500/panel/Annunciator/FuelTransLeft");
		m._leds["FuelTransRight"] 		= AnnunciatorLedClass.new("extra500/panel/Annunciator/FuelTransRight");
		m._leds["StandByAlternOn"] 		= AnnunciatorLedClass.new("extra500/panel/Annunciator/StandByAlternOn");
		m._leds["IgnitionActive"] 		= AnnunciatorLedClass.new("extra500/panel/Annunciator/IgnitionActive");
		m._leds["IntakeHeat"] 			= AnnunciatorLedClass.new("extra500/panel/Annunciator/IntakeHeat");
		m._leds["RecognLight"] 			= AnnunciatorLedClass.new("extra500/panel/Annunciator/RecognLight");
		m._leds["FuelFilterByPass"] 		= AnnunciatorLedClass.new("extra500/panel/Annunciator/FuelFilterByPass");
		m._leds["PneumaticLow"] 		= AnnunciatorLedClass.new("extra500/panel/Annunciator/PneumaticLow");
		m._leds["LowVoltage"] 			= AnnunciatorLedClass.new("extra500/panel/Annunciator/LowVoltage");
		m._leds["DeiceBoots"] 			= AnnunciatorLedClass.new("extra500/panel/Annunciator/DeiceBoots");
		m._leds["LandingLight"] 		= AnnunciatorLedClass.new("extra500/panel/Annunciator/LandingLight");
		m._leds["FuelLowLeft"] 			= AnnunciatorLedClass.new("extra500/panel/Annunciator/FuelLowLeft");
		m._leds["FuelLowRight"] 		= AnnunciatorLedClass.new("extra500/panel/Annunciator/FuelLowRight");
		m._leds["PropellerLowPitch"] 		= AnnunciatorLedClass.new("extra500/panel/Annunciator/PropellerLowPitch");
		m._leds["ExternalPower"] 		= AnnunciatorLedClass.new("extra500/panel/Annunciator/ExternalPower");
		m._leds["WindshieldHeatOn"] 		= AnnunciatorLedClass.new("extra500/panel/Annunciator/WindshieldHeatOn");
	
		m._ledsIndex = keys(m._leds);
		
		m._brightness 		= 0;
		m._test		 	= 0;
		
		m._dt = 0;
		m._now = systime();
		m._lastTime = m._now;
		m.timerLoop = maketimer(1.0,m,AnnunciatorClass.update);
				
		
		return m;
	},
	init : func(){
		me.setListerners();
		
		eSystem.circuitBreaker.WARN_LT.addOutput(me);
		#eSystem.circuitBreaker.DIP_2.addOutput(me);
		#eSystem.circuitBreaker.DIP_2.addOutput(me._backlight);
		me._testListener 	= setlistener("/extra500/system/dimming/Test",func(n){me._onDimTestChange(n);},1,0);
		me._brightnessListener	= setlistener("/extra500/system/dimming/Annunciator",func(n){me._onBrightnessChange(n);},1,0);
	
		me.timerLoop.start();
		
	},
	electricWork : func(){
		if (me._volt > 22.0){
			me._watt = me._nWatt.getValue() * me._brightness;
			me._ampere = me._watt / me._volt;
			me._state = 1;
			
			foreach(l;me._ledsIndex){
				me._leds[l].setBrightness(me._brightness,me._test);
			}
			
		}else{
			me._ampere = 0;
			me._state = 0;
			
			foreach(l;me._ledsIndex){
				me._leds[l].setBrightness(0,0);
			}
		}
		me._nAmpere.setValue(me._ampere);
		me._nState.setValue(me._state);
	},
	_onBrightnessChange : func(n){
		me._brightness = n.getValue();
		me.electricWork();
	},
	_onDimTestChange : func(n){
		me._test = n.getValue();
		me.electricWork();
	},
	update : func(){
		me._now 	= systime();
		me._dt 		= me._now - me._lastTime;
		me._lastTime	= me._now;
	}
	
};

var annunciator = AnnunciatorClass.new("extra500/panel/Annunciator","Annuciator Panel",24.0);
