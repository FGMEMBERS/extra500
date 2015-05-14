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
#      Last change:      Eric van den Berg
#      Date:             17.01.14
#

# MM Page 590

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
	init : func(instance){
		if (instance==nil){instance=me;}
		me.parents[1].init(instance);
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
	setBrightness : func(brightness,test){
		me._brightness 	= brightness;
		me._test 	= test;
		me._checkState();
		
	},
	
};

var AnnunciatorClass = {
	new : func(root,name,watt=12.0){
		var m = { 
			parents : [
				AnnunciatorClass,
				ConsumerClass.new(root,name,watt),
				SubSystemClass.new()
			]
		};
		
		#m.nGenAmps = props.globals.initNode("extra500/electric/eBox/GeneratorShunt/indicatedAmpere",0.0,"DOUBLE");
		#m.nBatAmps = props.globals.initNode("extra500/electric/eBox/BatteryShunt/indicatedAmpere",0.0,"DOUBLE");
		
		#m._backlight = LedClass.new("extra500/instrumentation/DIP/Backlight","DIP Backlight","extra500/system/dimming/Instrument",0.2);
		m._nBlink1Hz		= m._nRoot.initNode("blink1Hz",0,"BOOL");
		
		m._listeners	= [];
		m._leds 	= {};
		
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
		m._timerLoop = nil;
				
		
		return m;
	},
	init : func(instance=nil){
		if (instance==nil){instance=me;}
		me.parents[1].init(instance);
		me.setListeners(instance);
		
		eSystem.circuitBreaker.WARN_LT.outputAdd(me);
		#eSystem.circuitBreaker.DIP_2.outputAdd(me);
		#eSystem.circuitBreaker.DIP_2.outputAdd(me._backlight);
		
		
		#me._timerLoop = maketimer(1.0,me,AnnunciatorClass.update);
		#me._timerLoop.start();
		
		me.__initSubSystem(me);
		subSystemManager2Hz.register(me);
		
	},
	setListeners : func(instance) {
		append(me._listeners, setlistener("/extra500/system/dimming/Test",func(n){instance._onDimTestChange(n);},1,0) );
		append(me._listeners, setlistener("/extra500/system/dimming/Annunciator",func(n){instance._onBrightnessChange(n);},1,0) );
		
		append(me._listeners, setlistener("/extra500/door/upperpass/state",		func(n){instance._leds["AFTDoor"].setState(n.getValue());},1,0) );
		append(me._listeners, setlistener("/extra500/system/deice/StallHeat/state",	func(n){instance._leds["StallHeat"].setState(!n.getValue());},1,0) );
		append(me._listeners, setlistener("/extra500/engine/lowOilPressure",		func(n){instance._leds["OilPress"].setState(n.getValue());},1,0) );
		append(me._listeners, setlistener("/extra500/electric/relay/K3/state",		func(n){instance._leds["GeneratorFail"].setState(!n.getValue());},1,0) );
		append(me._listeners, setlistener("/extra500/engine/defectChip",			func(n){instance._leds["ChipDetection"].setState(n.getValue());},1,0) );
		append(me._listeners, setlistener("/systems/gear/annunciators/hydcaution/warn",	func(n){instance._leds["HydraulicPump"].setState(n.getValue());},1,0) );
		append(me._listeners, setlistener("/systems/gear/annunciators/gearwarn",		func(n){instance._leds["GearWarn"].setState(n.getValue());},1,0) );
		append(me._listeners, setlistener("/extra500/system/pitot/StallWarn/state",	func(n){instance._leds["StallWarn"].setState(n.getValue());},1,0) );
		append(me._listeners, setlistener("/extra500/system/deice/WindshieldHeat/Fail",	func(n){instance._leds["WindshieldHeatFail"].setState(n.getValue());},1,0) );
		append(me._listeners, setlistener("/extra500/engine/lowFuelPressure",		func(n){instance._leds["FuelPress"].setState(n.getValue());},1,0) );
		append(me._listeners, setlistener("/extra500/system/deice/PitotHeatLeft/state",	func(n){instance._leds["PitotHeatLeft"].setState(!n.getValue());},1,0) );
		append(me._listeners, setlistener("/extra500/system/deice/PitotHeatRight/state",func(n){instance._leds["PitotHeatRight"].setState(!n.getValue());},1,0) );
		append(me._listeners, setlistener("/extra500/system/flap/hasWarning",		func(n){instance._leds["Flaps"].setState(n.getValue());},1,0) );
		append(me._listeners, setlistener("/systems/pressurization/warning",		func(n){instance._leds["CabinPressure"].setState(n.getValue());},1,0) );
		append(me._listeners, setlistener("/extra500/cabin/hasBleedOvertempWarning",	func(n){instance._leds["BleedOvertemp"].setState(n.getValue());},1,0) );
		append(me._listeners, setlistener("/extra500/system/deice/StaticHeatLeft/state",func(n){instance._leds["StaticHeatLeft"].setState(!n.getValue());},1,0) );
		append(me._listeners, setlistener("/extra500/system/deice/StaticHeatRight/state",func(n){instance._leds["StaticHeatRight"].setState(!n.getValue());},1,0) );
		append(me._listeners, setlistener("/extra500/system/fuel/FuelPumpTransLeft/state",	func(n){instance._leds["FuelTransLeft"].setState(!n.getValue());},1,0) );
		append(me._listeners, setlistener("/extra500/system/fuel/FuelPumpTransRight/state",	func(n){instance._leds["FuelTransRight"].setState(!n.getValue());},1,0) );
		append(me._listeners, setlistener("/extra500/electric/source/Alternator/hasLoad",	func(n){instance._leds["StandByAlternOn"].setState(n.getValue());},1,0) );
		append(me._listeners, setlistener("/controls/engines/engine[0]/ignition",	func(n){instance._leds["IgnitionActive"].setState(n.getValue());},1,0) );
		append(me._listeners, setlistener("/extra500/system/deice/IntakeHeat/state",	func(n){instance._leds["IntakeHeat"].setState(n.getValue());},1,0) );
		append(me._listeners, setlistener("/extra500/panel/Side/Light/Recognition/state",func(n){instance._leds["RecognLight"].setState(n.getValue());},1,0) );
		append(me._listeners, setlistener("/extra500/system/fuel/FuelFilterByPass",	func(n){instance._leds["FuelFilterByPass"].setState(n.getValue());},1,0) );
		append(me._listeners, setlistener("/systems/pneumatic/low-pressure-caution",	func(n){instance._leds["PneumaticLow"].setState(n.getValue());},1,0) );
		append(me._listeners, setlistener("/extra500/electric/pcBoard1/lowVoltage",	func(n){instance._leds["LowVoltage"].setState(n.getValue());},1,0) );
		append(me._listeners, setlistener("/systems/pneumatic/boots-safe-oper",		func(n){instance._leds["DeiceBoots"].setState(n.getValue());},1,0) );
		append(me._listeners, setlistener("/extra500/panel/Side/Light/Landing/state",	func(n){instance._leds["LandingLight"].setState(n.getValue());},1,0) );
		append(me._listeners, setlistener("/extra500/system/fuel/FuelLowLeft",		func(n){instance._leds["FuelLowLeft"].setState(n.getValue());},1,0) );
		append(me._listeners, setlistener("/extra500/system/fuel/FuelLowRight",		func(n){instance._leds["FuelLowRight"].setState(n.getValue());},1,0) );
		append(me._listeners, setlistener("/extra500/engine/lowPitch",			func(n){instance._leds["PropellerLowPitch"].setState(n.getValue());},1,0) );
		append(me._listeners, setlistener("/extra500/electric/source/ExternalGenerator/isPluged",		func(n){instance._leds["ExternalPower"].setState(n.getValue());},1,0) );
		append(me._listeners, setlistener("/extra500/system/deice/WindshieldHeat/state",	func(n){instance._leds["WindshieldHeatOn"].setState(n.getValue());},1,0) );
		
	},
	electricWork : func(){
		if (me._volt > me._voltMin){
			me._watt = me._nWatt.getValue() * me._brightness;
			me._ampere = me._watt / me._volt;
			me._state = 1;
			
# 			foreach(var l;me._ledsIndex){
# 				me._leds[l].setBrightness(me._brightness,me._test);
# 			}
			
			var brightness = me._brightness  * me._qos * me._voltNorm;
# 			
			me._leds["GeneratorFail"].setBrightness(brightness,me._test);
			me._leds["AFTDoor"].setBrightness(brightness,me._test);
			me._leds["StallHeat"].setBrightness(brightness,me._test);
			me._leds["OilPress"].setBrightness(brightness,me._test);
			me._leds["ChipDetection"].setBrightness(brightness,me._test);
			me._leds["HydraulicPump"].setBrightness(brightness,me._test);
			me._leds["GearWarn"].setBrightness(brightness,me._test);
			me._leds["StallWarn"].setBrightness(brightness,me._test);
			me._leds["WindshieldHeatFail"].setBrightness(brightness,me._test);
			me._leds["FuelPress"].setBrightness(brightness,me._test);
			me._leds["PitotHeatLeft"].setBrightness(brightness,me._test);
			me._leds["PitotHeatRight"].setBrightness(brightness,me._test);
			me._leds["Flaps"].setBrightness(brightness,me._test);
			me._leds["CabinPressure"].setBrightness(brightness,me._test);
			me._leds["BleedOvertemp"].setBrightness(brightness,me._test);
			me._leds["StaticHeatLeft"].setBrightness(brightness,me._test);
			me._leds["StaticHeatRight"].setBrightness(brightness,me._test);
			me._leds["FuelTransLeft"].setBrightness(brightness,me._test);
			me._leds["FuelTransRight"].setBrightness(brightness,me._test);
			me._leds["StandByAlternOn"].setBrightness(brightness,me._test);
			me._leds["IgnitionActive"].setBrightness(brightness,me._test);
			me._leds["IntakeHeat"].setBrightness(brightness,me._test);
			me._leds["RecognLight"].setBrightness(brightness,me._test);
			me._leds["FuelFilterByPass"].setBrightness(brightness,me._test);
			me._leds["PneumaticLow"].setBrightness(brightness,me._test);
			me._leds["LowVoltage"].setBrightness(brightness,me._test);
			me._leds["DeiceBoots"].setBrightness(brightness,me._test);
			me._leds["LandingLight"].setBrightness(brightness,me._test);
			me._leds["FuelLowLeft"].setBrightness(brightness,me._test);
			me._leds["FuelLowRight"].setBrightness(brightness,me._test);
			me._leds["PropellerLowPitch"].setBrightness(brightness,me._test);
			me._leds["ExternalPower"].setBrightness(1.0,me._test);
			me._leds["WindshieldHeatOn"].setBrightness(brightness,me._test);
			
		}else{
			me._ampere = 0;
			me._state = 0;
			
# 			foreach(var l;me._ledsIndex){
# 				me._leds[l].setBrightness(0,0);
# 			}
			
			me._leds["GeneratorFail"].setBrightness(0,0);
			me._leds["AFTDoor"].setBrightness(0,0);
			me._leds["StallHeat"].setBrightness(0,0);
			me._leds["OilPress"].setBrightness(0,0);
			me._leds["ChipDetection"].setBrightness(0,0);
			me._leds["HydraulicPump"].setBrightness(0,0);
			me._leds["GearWarn"].setBrightness(0,0);
			me._leds["StallWarn"].setBrightness(0,0);
			me._leds["WindshieldHeatFail"].setBrightness(0,0);
			me._leds["FuelPress"].setBrightness(0,0);
			me._leds["PitotHeatLeft"].setBrightness(0,0);
			me._leds["PitotHeatRight"].setBrightness(0,0);
			me._leds["Flaps"].setBrightness(0,0);
			me._leds["CabinPressure"].setBrightness(0,0);
			me._leds["BleedOvertemp"].setBrightness(0,0);
			me._leds["StaticHeatLeft"].setBrightness(0,0);
			me._leds["StaticHeatRight"].setBrightness(0,0);
			me._leds["FuelTransLeft"].setBrightness(0,0);
			me._leds["FuelTransRight"].setBrightness(0,0);
			me._leds["StandByAlternOn"].setBrightness(0,0);
			me._leds["IgnitionActive"].setBrightness(0,0);
			me._leds["IntakeHeat"].setBrightness(0,0);
			me._leds["RecognLight"].setBrightness(0,0);
			me._leds["FuelFilterByPass"].setBrightness(0,0);
			me._leds["PneumaticLow"].setBrightness(0,0);
			me._leds["LowVoltage"].setBrightness(0,0);
			me._leds["DeiceBoots"].setBrightness(0,0);
			me._leds["LandingLight"].setBrightness(0,0);
			me._leds["FuelLowLeft"].setBrightness(0,0);
			me._leds["FuelLowRight"].setBrightness(0,0);
			me._leds["PropellerLowPitch"].setBrightness(0,0);
			me._leds["ExternalPower"].setBrightness(1.0,0);
			me._leds["WindshieldHeatOn"].setBrightness(0,0);
	
			
			
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
		
		me._nBlink1Hz.setValue( !me._nBlink1Hz.getValue() );
	}
	
};

var annunciator = AnnunciatorClass.new("extra500/panel/Annunciator","Annuciator Panel",24.0);
