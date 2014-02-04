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
#      Date: Jun 27 2013
#
#      Last change:      Eric van den Berg
#      Date:             04.02.14
#

var DigitalInstrumentPackageClass = {
	new : func(root,name,watt=12.0){
		var m = { 
			parents : [
				DigitalInstrumentPackageClass,
				ConsumerClass.new(root,name,watt)
			]
		};
		
		#m.nGenAmps = props.globals.initNode("extra500/electric/eBox/GeneratorShunt/indicatedAmpere",0.0,"DOUBLE");
		#m.nBatAmps = props.globals.initNode("extra500/electric/eBox/BatteryShunt/indicatedAmpere",0.0,"DOUBLE");
		
		m._backlight = LedClass.new("extra500/instrumentation/DIP/Backlight","DIP Backlight","extra500/system/dimming/Instrument",0.2);
		
				
		m.nIAT = props.globals.initNode("/fdm/jsbsim/aircraft/engine/IAT-degC",0.0,"DOUBLE");
		m.nFuelTemp = props.globals.initNode("/fdm/jsbsim/aircraft/engine/FT-degC",0.0,"DOUBLE");
		m.nFuelPress = props.globals.initNode("/fdm/jsbsim/aircraft/engine/FP-psi",0.0,"DOUBLE");
		
		m.nIndicatedVDC = m._nRoot.initNode("indicatedVDC",0.0,"DOUBLE");
		m.nIndicatedGEN = m._nRoot.initNode("indicatedGEN",0.0,"DOUBLE");
		m.nIndicatedBAT = m._nRoot.initNode("indicatedBAT",0.0,"DOUBLE");
		
		m.nIndicatedIAT = m._nRoot.initNode("indicatedIAT",0.0,"DOUBLE");
		m.nIndicatedFuelTemp = m._nRoot.initNode("indicatedFuelTemp",0.0,"DOUBLE");
		m.nIndicatedFuelPress = m._nRoot.initNode("indicatedFuelPress",0.0,"DOUBLE");
		
		m._dt = 0;
		m._now = systime();
		m._lastTime = m._now;
		m._timerLoop = nil;
		
		
		return m;
	},
	setListeners : func(instance) {
		append(me._listeners, setlistener(eSystem.circuitBreaker.VOLT_MON._nVoltOut,func(n){instance._onVoltMonitorChange(n);},1,0) );
		append(me._listeners, setlistener(eSystem._nLoadBattery,func(n){instance._onBatteryMonitorChange(n);},1,0) );
		append(me._listeners, setlistener(eSystem._nLoadGenerator,func(n){instance._onGeneratorMonitorChange(n);},1,0) );
	},
	init : func(instance=nil){
		if (instance==nil){instance=me;}
		me.parents[1].init(instance);
		me.setListeners(instance);
		
		me._backlight.init();
		me._backlight.on();
		
		#eSystem.circuitBreaker.DIP_1.outputAdd(me);
		eSystem.circuitBreaker.DIP_1.outputAdd(me);
		eSystem.circuitBreaker.DIP_1.outputAdd(me._backlight);
		
		me._timerLoop = maketimer(1.0,me,DigitalInstrumentPackageClass.update);
		me._timerLoop.start();
		
	},
	_onVoltMonitorChange : func(n){
		me.nIndicatedVDC.setValue(n.getValue()+ 0.05); 
	},
	_onBatteryMonitorChange : func(n){
		me.nIndicatedBAT.setValue(math.abs(n.getValue()+ 0.5));
	},
	_onGeneratorMonitorChange : func(n){
		me.nIndicatedGEN.setValue(math.abs(n.getValue()+ 0.5));
	},
	
	update : func(){
		me._now 	= systime();
		me._dt 		= me._now - me._lastTime;
		me._lastTime	= me._now;
		
		
		#me.nIndicatedGEN.setValue(eSystem._ampere + 0.5);
		#me.nIndicatedBAT.setValue(eSystem._ampere + 0.5);
		
# 		me.nIndicatedFuelPress.setValue(me.nFuelPress.getValue() + 0.5);
# 		me.nIndicatedFuelTemp.setValue(me.nFuelTemp.getValue() + 0.5);
		interpolate(me.nIndicatedFuelPress ,me.nFuelPress.getValue()+ 0.5,me._dt);
		interpolate(me.nIndicatedFuelTemp ,math.abs(me.nFuelTemp.getValue()+ 0.5* math.sgn(me.nIAT.getValue())),me._dt);
		
		me.nIndicatedIAT.setValue(math.abs(me.nIAT.getValue() + 0.5 * math.sgn(me.nIAT.getValue())));
		
		
	}
	
};
var EngineInstrumentPackageClass = {
	new : func(root,name,watt=24.0){
		var m = { 
			parents : [
				EngineInstrumentPackageClass,
				ConsumerClass.new(root,name,watt)
			]
		};
		m._backlight = LedClass.new("extra500/instrumentation/EIP/Backlight","EIP Backlight","extra500/system/dimming/Instrument",0.6);
		
		return m;
	},
	init : func(instance=nil){
		if (instance==nil){instance=me;}
		me.parents[1].init(instance);
		
		me._backlight.init();
		me._backlight.on();
		
		eSystem.circuitBreaker.ENG_INST_1.outputAdd(me);
		eSystem.circuitBreaker.ENG_INST_1.outputAdd(me._backlight);
		
	},
};

var LumiClass = {
	new : func(root,name,watt=42.0){
		var m = { 
			parents : [
				LumiClass,
				ServiceClass.new(root,name)
			]
		};
		m._backlight = LedClass.new("extra500/light/Lumi/Backlight","Lumi Switch Backlight","extra500/system/dimming/Switch",watt);
		
		return m;
	},
	init : func(instance=nil){
		if (instance==nil){instance=me;}
		me.parents[1].init(instance);
		
		me._backlight.init();
				
		eSystem.circuitBreaker.INST_LT.outputAdd(me._backlight);
	},
	setState : func(value){
		me._backlight.setState(value);
	}
};

var BacklightClass = {
	new : func(root,name,brightness="/extra500/system/dimming/Instrument",watt=1.0){
		var m = { 
			parents : [
				BacklightClass,
				ConsumerClass.new(root,name,watt)
			]
		};
		m._nState		= m._nRoot.initNode("state",0,"DOUBLE",1);
		m._nBrightness		= props.globals.initNode(brightness,0.0,"DOUBLE");
		m._brightness		= 0;
		#m._nBacklight 		= m._nRoot.initNode("Backlight/state",0.0,"DOUBLE");
		m._backLight 		= 0;
		m._backLightState 	= 0;
		return m;
	},
	setListeners : func(instance) {
		append(me._listeners, setlistener(me._nBrightness,func(n){instance._onBrightnessChange(n);},1,0) );
	},
	init : func(instance=nil){
		if (instance==nil){instance=me;}
		me.parents[1].init(instance);
		me.setListeners(instance);
	},
	_onBrightnessChange : func(n){
		me._brightness = n.getValue();
		me.electricWork();
	},
	electricWork : func(){
		if (me._volt > me._voltMin){
			me._watt = me._nWatt.getValue();
			me._ampere = me._watt / me._volt;
			me._state = 1;
			if (me._backLightState == 1){
				me._backLight = me._brightness * me._qos * me._voltNorm;
			}else{
				me._backLight = 0;	
			}
		}else{
			me._ampere = 0;
			me._state = 0;
			me._backLight = 0;
		}
		
		me._nAmpere.setValue(me._ampere);
		me._nState.setValue(me._backLight);
		#me._nBacklight.setValue(me._backLight);
	},
	setBacklight : func(value){
		me._backLightState = value;
		me.electricWork();
	}
};

var InstrumentClass = {
	new : func(root,name,brightness="/extra500/system/dimming/Instrument",powerWatt=24.0,lightWatt=1.0){
		var m = { 
			parents : [
				InstrumentClass,
				ConsumerClass.new(root,name,powerWatt)
			]
		};
		
		m._light	= BacklightClass.new(root~"/Backlight",name~" Backlight",brightness,lightWatt);

		return m;
	},
	init : func(instance=nil){
		if (instance==nil){instance=me;}
		me.parents[1].init(instance);
		me._light.init();
		me.setListeners(instance);
	},
	setBacklight : func(value){
		me._light.setBacklight(value);
	}
	
};
var DigitalInstrumentClass = {
	new : func(root,name,brightness="/extra500/system/dimming/Instrument",watt=24.0){
		var m = { 
			parents : [
				DigitalInstrumentClass,
				ConsumerClass.new(root,name,watt)
			]
		};
		
		m._nBrightness		= props.globals.initNode(brightness,0.0,"DOUBLE");
		m._brightness		= 0;
		m._nBacklight 		= m._nRoot.initNode("Backlight/state",0.0,"DOUBLE");
		m._backLight 		= 0;
		m._backLightState 	= 0;
		return m;
	},
	setListeners : func(instance) {
		append(me._listeners, setlistener(me._nBrightness,func(n){instance._onBrightnessChange(n);},1,0) );
	},
	init : func(instance=nil){
		if (instance==nil){instance=me;}
		me.parents[1].init(instance);
		me.setListeners(instance);
	},
	_onBrightnessChange : func(n){
		me._brightness = n.getValue();
		me.electricWork();
	},
	electricWork : func(){
		if (me._volt > me._voltMin){
			me._watt = me._nWatt.getValue();
			me._ampere = me._watt / me._volt;
			me._state = 1;
			if (me._backLightState == 1){
				me._backLight = me._brightness * me._qos * me._voltNorm;
			}else{
				me._backLight = 1;	
			}
		}else{
			me._ampere = 0;
			me._state = 0;
			me._backLight = 0;
		}
		
		me._nAmpere.setValue(me._ampere);
		me._nState.setValue(me._state);
		me._nBacklight.setValue(me._backLight);
	},
	setBacklight : func(value){
		me._backLightState = value;
		me.electricWork();
	}
};

var PcBoard1Class = {
	new : func(root,name,watt=1.0){
		var m = { 
			parents : [
				PcBoard1Class,
				ConsumerClass.new(root,name,watt)
			]
		};
		m._nLowVoltage 		= m._nRoot.initNode("lowVoltage",0.0,"DOUBLE");
		
		return m;
	},
	setListeners : func(instance) {
		append(me._listeners, setlistener(eSystem.circuitBreaker.LOW_VOLT._nVoltOut,func(n){instance._onVoltMonitorChange(n);},1,0) );
		
	},
	init : func(instance=nil){
		if (instance==nil){instance=me;}
		me.parents[1].init(instance);
		me.setListeners(instance);
	},
	_onVoltMonitorChange : func(n){
		me._lowVoltMonitor = n.getValue();
		if(me._lowVoltMonitor < 25.5 ){
			me._nLowVoltage.setValue(1);
		}else{
			me._nLowVoltage.setValue(0);
		}
	},
	
};

var FuelInstrumentClass = {
	new : func(root,name,brightness="/extra500/system/dimming/Instrument",watt=24.0){
		var m = { 
			parents : [
				FuelInstrumentClass,
				InstrumentClass.new(root,name,brightness,watt)
			]
		};
		m._tankLevel = [
			props.globals.initNode("/consumables/fuel/tank[0]/level-norm",0.0,"DOUBLE"),
			props.globals.initNode("/consumables/fuel/tank[1]/level-norm",0.0,"DOUBLE"),
			props.globals.initNode("/consumables/fuel/tank[2]/level-norm",0.0,"DOUBLE"),
			props.globals.initNode("/consumables/fuel/tank[4]/level-norm",0.0,"DOUBLE"),
			props.globals.initNode("/consumables/fuel/tank[5]/level-norm",0.0,"DOUBLE"),
			props.globals.initNode("/consumables/fuel/tank[6]/level-norm",0.0,"DOUBLE"),
		];
		m._tankIndication = [
			m._nRoot.initNode("tank[0]/level-norm",0.0,"DOUBLE"),
			m._nRoot.initNode("tank[1]/level-norm",0.0,"DOUBLE"),
			m._nRoot.initNode("tank[2]/level-norm",0.0,"DOUBLE"),
			m._nRoot.initNode("tank[4]/level-norm",0.0,"DOUBLE"),
			m._nRoot.initNode("tank[5]/level-norm",0.0,"DOUBLE"),
			m._nRoot.initNode("tank[6]/level-norm",0.0,"DOUBLE"),
		];
		m._interpolating = 0; 
		m._indication = 0;
		m._tankCount = 6;
		return m;
	},
	setListeners : func(instance) {
		#append(me._listeners, setlistener(me._nBrightness,func(n){instance._onBrightnessChange(n);},1,0) );
		append(me._listeners, setlistener(me._nState,func(n){instance._onStateChange(n);},1,0) );
	},
	init : func(instance=nil){
		if (instance==nil){instance=me;}
		me.parents[1].init(instance);
		me.setListeners(instance);
	},
	_onStateChange : func(){
		if (me._state == 0){
			for (var i = 0; i < 6 ; i += 1){
				me._tankIndication[i].unalias();
				me._tankIndication[i].setValue(me._tankLevel[i].getValue());
				interpolate(me._tankIndication[i],0,1);
			}
		}elsif(me._state == 1){
			for (var i = 0; i < 6 ; i += 1){
				interpolate(me._tankIndication[i],me._tankLevel[i].getValue(),1);
			}
			settimer(func{
				for (var i = 0; i < 6 ; i += 1){
					me._tankIndication[i].alias(me._tankLevel[i]);
				}
			},1);
		}
			
	},

};

var engineInstrumentPackage = EngineInstrumentPackageClass.new("extra500/instrumentation/EIP","Engine Instrument Package",29.0);
var digitalInstrumentPackage = DigitalInstrumentPackageClass.new("extra500/instrumentation/DIP","Digital Instrument Package",13.0);
var lumi = LumiClass.new("extra500/light/Lumi","Lumi Switch",42.0);

var stbyHSI 		= InstrumentClass.new("extra500/instrumentation/StbyHSI","Standby Horizontal Sitiuation Indicator","/extra500/system/dimming/Instrument",7.0);
var stbyIAS		= InstrumentClass.new("extra500/instrumentation/StbyIAS","Standby Indecated Airspeed","/extra500/system/dimming/Instrument",0);
var stbyALT		= InstrumentClass.new("extra500/instrumentation/StbyALT","Standby Altitude","/extra500/system/dimming/Instrument",0);
var cabincontroller 	= InstrumentClass.new("extra500/instrumentation/CabinController","Cabin Controller","/extra500/system/dimming/Instrument",10.0);
var cabinaltimeter 	= InstrumentClass.new("extra500/instrumentation/CabinAltimeter","Cabin Altimeter","/extra500/system/dimming/Instrument",0.0);
var cabinclimb 		= InstrumentClass.new("extra500/instrumentation/CabinClimb","Cabin Climb","/extra500/system/dimming/Instrument",0.0);
var propellerHeat	= InstrumentClass.new("extra500/instrumentation/PropellerHeat","Propeller Heat Ammeter","/extra500/system/dimming/Instrument",0.0);
var turnCoordinator	= InstrumentClass.new("extra500/instrumentation/TurnCoordinator","Turn Coordinator","/extra500/system/dimming/Instrument",8.0);
var xpdr		= InstrumentClass.new("extra500/instrumentation/xpdr","Transponder","/extra500/system/dimming/Instrument",6.0,0);

var fuelQuantity	= FuelInstrumentClass.new("extra500/instrumentation/FuelQuantity","Fuel Quantity","/extra500/system/dimming/Instrument",3.0);
var fuelFlow		= DigitalInstrumentClass.new("extra500/instrumentation/FuelFlow","Fuel Flow","/extra500/system/dimming/Instrument",6.0);
var dmeInd			= DigitalInstrumentClass.new("extra500/instrumentation/dmeInd","DME Indicator","/extra500/system/dimming/Instrument",21.0);
var dmeSwitch		= DigitalInstrumentClass.new("extra500/instrumentation/dmeSwitch","DME Switch","/extra500/system/dimming/Instrument",1.0);
var magCompass		= DigitalInstrumentClass.new("extra500/instrumentation/magCompass","Mag Compass","/extra500/system/dimming/Instrument",1.0);
var pcBoard1		= PcBoard1Class.new("extra500/electric/pcBoard1","PC Board 1",1.0);


eSystem.circuitBreaker.STBY_GYRO.outputAdd(stbyHSI);
eSystem.circuitBreaker.C_PRESS.outputAdd(cabincontroller);
eSystem.circuitBreaker.C_PRESS.outputAdd(cabinaltimeter);
eSystem.circuitBreaker.C_PRESS.outputAdd(cabinclimb);
eSystem.circuitBreaker.PROP_HT.outputAdd(propellerHeat);
eSystem.circuitBreaker.TB.outputAdd(turnCoordinator);
eSystem.circuitBreaker.ATC.outputAdd(xpdr);
eSystem.circuitBreaker.FUEL_QTY.outputAdd(fuelQuantity);
eSystem.circuitBreaker.FUEL_FLOW.outputAdd(fuelFlow);
eSystem.circuitBreaker.DME.outputAdd(dmeInd);
eSystem.circuitBreaker.INST_LT.outputAdd(dmeSwitch);
eSystem.circuitBreaker.WARN_LT.outputAdd(magCompass);


eSystem.circuitBreaker.INST_LT.outputAdd(stbyIAS._light);
eSystem.circuitBreaker.INST_LT.outputAdd(stbyHSI._light);
eSystem.circuitBreaker.INST_LT.outputAdd(stbyALT._light);
eSystem.circuitBreaker.INST_LT.outputAdd(cabincontroller._light);
eSystem.circuitBreaker.INST_LT.outputAdd(cabinaltimeter._light);
eSystem.circuitBreaker.INST_LT.outputAdd(cabinclimb._light);
eSystem.circuitBreaker.INST_LT.outputAdd(propellerHeat._light);
eSystem.circuitBreaker.INST_LT.outputAdd(turnCoordinator._light);
eSystem.circuitBreaker.INST_LT.outputAdd(fuelQuantity._light);
