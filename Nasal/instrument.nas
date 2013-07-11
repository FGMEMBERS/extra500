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
#      Last change:      Dirk Dittmann
#      Date:             27.06.13
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
		
				
		m.nIAT = props.globals.initNode("/environment/temperature-degc",0.0,"DOUBLE");
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
	setListeners : func() {
		append(me._listeners, setlistener(me._nVolt,func(n){me._onVoltChange(n);},1,0) );
		append(me._listeners, setlistener(me._nAmpere,func(n){me._onAmpereChange(n);},1,0) );
		append(me._listeners, setlistener(me._nWatt,func(n){me._onWattChange(n);},1,0) );
		append(me._listeners, setlistener(me._nVoltMin,func(n){me._onVoltMinChange(n);},1,0) );
		append(me._listeners, setlistener(me._nVoltMax,func(n){me._onVoltMaxChange(n);},1,0) );
		append(me._listeners, setlistener(eSystem.circuitBreaker.VOLT_MON._nVoltOut,func(n){me._onVoltMonitorChange(n);},1,0) );
		
	},
	_onVoltMonitorChange : func(n){
		me.nIndicatedVDC.setValue(n.getValue()+ 0.05) 
	},
	init : func(){
		me.setListeners();
		me._backlight.setListeners();
		me._backlight.on();
		
		#eSystem.circuitBreaker.DIP_1.outputAdd(me);
		eSystem.circuitBreaker.DIP_1.outputAdd(me);
		eSystem.circuitBreaker.DIP_1.outputAdd(me._backlight);
		
		me._timerLoop = maketimer(1.0,me,DigitalInstrumentPackageClass.update);
		me._timerLoop.start();
		
	},
	update : func(){
		me._now 	= systime();
		me._dt 		= me._now - me._lastTime;
		me._lastTime	= me._now;
		
		
		me.nIndicatedGEN.setValue(eSystem._ampere + 0.5);
		me.nIndicatedBAT.setValue(eSystem._ampere + 0.5);
		
# 		me.nIndicatedFuelPress.setValue(me.nFuelPress.getValue() + 0.5);
# 		me.nIndicatedFuelTemp.setValue(me.nFuelTemp.getValue() + 0.5);
		interpolate(me.nIndicatedFuelPress ,me.nFuelPress.getValue()+ 0.5,me._dt);
		interpolate(me.nIndicatedFuelTemp ,me.nFuelTemp.getValue()+ 0.5,me._dt);
		
		me.nIndicatedIAT.setValue(me.nIAT.getValue() + 0.5);
		
		
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
	init : func(){
		me.setListeners();
		me._backlight.setListeners();
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
	init : func(){
		me._backlight.setListeners();
		
		
		eSystem.circuitBreaker.INST_LT.outputAdd(me._backlight);
	},
	setState : func(value){
		me._backlight.setState(value);
	}
};


var InstrumentClass = {
	new : func(root,name,brightness="/extra500/system/dimming/Instrument",watt=24.0){
		var m = { 
			parents : [
				InstrumentClass,
				ConsumerClass.new(root,name,watt)
			]
		};
		
		m._nBrightness		= props.globals.initNode(brightness,0.0,"DOUBLE");
		m._brightness		= 0;
		m._brightnessListener   = nil;
		m._nBacklight 		= m._nRoot.initNode("Backlight/state",0.0,"DOUBLE");
		m._backLight 		= 0;
		m._backLightState 		= 0;
		return m;
	},
	setListeners : func() {
		append(me._listeners, setlistener(me._nVolt,func(n){me._onVoltChange(n);},1,0) );
		append(me._listeners, setlistener(me._nAmpere,func(n){me._onAmpereChange(n);},1,0) );
		append(me._listeners, setlistener(me._nWatt,func(n){me._onWattChange(n);},1,0) );
		append(me._listeners, setlistener(me._nVoltMin,func(n){me._onVoltMinChange(n);},1,0) );
		append(me._listeners, setlistener(me._nVoltMax,func(n){me._onVoltMaxChange(n);},1,0) );
		append(me._listeners, setlistener(me._nBrightness,func(n){me._onBrightnessChange(n);},1,0) );
		
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
				me._backLight = me._brightness;
			}else{
				me._backLight = 0;	
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
	init : func(){
		me.setListeners();
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
	init : func(){
		me.setListeners();
	},
	setListeners : func() {
		append(me._listeners, setlistener(me._nVolt,func(n){me._onVoltChange(n);},1,0) );
		append(me._listeners, setlistener(me._nAmpere,func(n){me._onAmpereChange(n);},1,0) );
		append(me._listeners, setlistener(me._nWatt,func(n){me._onWattChange(n);},1,0) );
		append(me._listeners, setlistener(me._nVoltMin,func(n){me._onVoltMinChange(n);},1,0) );
		append(me._listeners, setlistener(me._nVoltMax,func(n){me._onVoltMaxChange(n);},1,0) );
		append(me._listeners, setlistener(eSystem.circuitBreaker.LOW_VOLT._nVoltOut,func(n){me._onVoltMonitorChange(n);},1,0) );
		
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

var engineInstrumentPackage = EngineInstrumentPackageClass.new("extra500/instrumentation/EIP","Engine Instrument Package",24.0);
var digitalInstrumentPackage = DigitalInstrumentPackageClass.new("extra500/instrumentation/DIP","Digital Instrument Package",12.0);
var lumi = LumiClass.new("extra500/light/Lumi","Lumi Switch",42.0);

var stbyHSI 		= InstrumentClass.new("extra500/instrumentation/StbyHSI","Standby Horizontal Sitiuation Indicator","/extra500/system/dimming/Instrument",6.0);
var stbyIAS		= InstrumentClass.new("extra500/instrumentation/StbyIAS","Standby Indecated Airspeed","/extra500/system/dimming/Instrument",6.0);
var stbyALT		= InstrumentClass.new("extra500/instrumentation/StbyALT","Standby Altitude","/extra500/system/dimming/Instrument",6.0);
var fuelQuantity	= InstrumentClass.new("extra500/instrumentation/FuelQuantity","Fuel Quantity","/extra500/system/dimming/Instrument",12.0);
var propellerHeat	= InstrumentClass.new("extra500/instrumentation/PropellerHeat","Propeller Heat Ammeter","/extra500/system/dimming/Instrument",6.0);
var turnCoordinator	= InstrumentClass.new("extra500/instrumentation/TrunCoordinator","Trun Coordinator","/extra500/system/dimming/Instrument",60.0);
var pcBoard1		= PcBoard1Class.new("extra500/electric/pcBoard1","PC Board 1",1.0);

eSystem.circuitBreaker.STBY_GYRO.outputAdd(stbyHSI);
eSystem.circuitBreaker.STBY_GYRO.outputAdd(stbyIAS);
eSystem.circuitBreaker.STBY_GYRO.outputAdd(stbyALT);
eSystem.circuitBreaker.FUEL_QTY.outputAdd(fuelQuantity);
eSystem.circuitBreaker.PROP_HT.outputAdd(propellerHeat);
eSystem.circuitBreaker.TB.outputAdd(turnCoordinator);




