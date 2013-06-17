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
#      Date: Jun 06 2013
#
#      Last change:      Dirk Dittmann
#      Date:             15.06.13
#




### Base Classes

var ServiceClass = {
	new : func(root,name){
		var m = { 
			parents 	: [ServiceClass] ,
			_nRoot		: props.globals.initNode(root),
			_name		: name,
		};
		return m;
	},
	getName : func(){
		return me._name;
	}
	
};


var ElectricClass = {
	new : func(root,name){
		var m = { 
			parents 	: [
				ElectricClass, 
				ServiceClass.new(root,name)
			]
		};
		m._nVolt		= m._nRoot.initNode("volt",0.0,"DOUBLE");
		m._nAmpere		= m._nRoot.initNode("ampere",0.0,"DOUBLE");
		m._ampere		= 0.0;
		m._volt			= 0.0;
		return m;
	},
	getAmpere	 : func(){ return me._nAmpere.getValue();},
	getVolt		 : func(){ 
		#print("ElectricClass.getVolt() ... "~me._name);
		return me._nVolt.getValue();
		
	},
	setVolt		 : func(volt){ me._nVolt.setValue(volt);},
	
};

var StateListenerClass = {
	new : func(){
		var m = { 
			parents 	: [
				StateListenerClass, 
			]
		};
		m._stateListener		= nil;
		return m;
	},
	onStateChange : func (n){
		
	},
	setStateListener : func(){
		me._stateListener = setlistener(me._nState,func(n){me.onStateChange(n);},0,0);
	},
	removeStateListener : func(){
		if(me._stateListener) {
			removelistener(me._stateListener);
			me._stateListener = nil;
		}
	},
};

### 
var GeneratorClass = {
	new : func(root,name){
		var m = { 
			parents : [
				GeneratorClass,
				ElectricClass.new(root,name)
			]
		};
		m._nAmpereAvailable	= m._nRoot.initNode("ampere_available",0.0,"DOUBLE");
		m._nN1			= props.globals.initNode("/engines/engine[0]/n1");
		m._nCtrlStarter		= props.globals.initNode("/controls/engines/engine[0]/starter",0,"BOOL");
		m._nCtrlGenerator	= props.globals.initNode("/controls/electric/engine[0]/generator",0,"BOOL");
		m._N1			= 0.0;
		m._voltMax		= 28.0;
		m._ampereMax		= 200.0;
		m._ampereAvailable	= 0.0;
			
		return m;
	},
	_gernerateVolt : func(now,dt){
		me._N1 = me._nN1.getValue();
		if (me._N1 > 30.0){
			me._volt = 0.8 * me._N1;
			me._ampereAvailable = 2.85 * me._N1;
			me._volt = global.clamp(me._volt,0.0,me._voltMax);
			me._ampereAvailable = global.clamp(me._ampereAvailable,0.0,me._ampereMax);
			interpolate(me._nVolt,me._volt,dt);
			interpolate(me._nAmpereAvailable,me._ampereAvailable,dt);
			
		}else{
			me._nVolt.setValue(0);
			me._nAmpereAvailable.setValue(0);
		}
	},
	_spoolEngine : func(now,dt) {
		
	},
	update : func(now,dt){
		if ( me._nCtrlGenerator.getValue() ){
			me._spoolEngine(now,dt);
		}else{
			me._gernerateVolt(now,dt);
		}
	}
};

var ExternalGeneratorClass = {
	new : func(root,name){
		var m = { 
			parents : [
				ExternalGeneratorClass,
				ElectricClass.new(root,name)
			]
		};
		m._nAmpereAvailable	= m._nRoot.initNode("ampere_available",0.0,"DOUBLE");
		m._voltMax		= 28.5;
		m._ampereMax		= 1200.0;
						
		return m;
	},
	update : func(now,dt){
		me._nVolt.setValue(me._voltMax);
		me._nAmpereAvailable.setValue(me._ampereMax);
	}
};

var AlternatorClass = {
	new : func(root,name){
		var m = { 
			parents : [
				AlternatorClass,
				ElectricClass.new(root,name)
			]
		};
		m._nAmpereAvailable	= m._nRoot.initNode("ampere_available",0.0,"DOUBLE");
		m._nField		= m._nRoot.initNode("field_volt",0,"BOOL");
		m._nN1			= props.globals.initNode("/engines/engine[0]/n1");
		m._nBusVolt		= props.globals.initNode("/extra500/electric2/Bus/EmergencyBus/volt");
		m._N1			= 0.0;
		m._voltMax		= 26.0;
		m._ampereMax		= 20.0;
		m._ampereAvailable	= 0.0;
		return m;
	},
	_gernerateVolt : func(now,dt){
		me._N1 = me._nN1.getValue();
		if (me._N1 > 30.0){
			me._volt = 0.8 * me._N1;
			me._ampereAvailable = me._N1 * 0.594795539 - 36.0892193309;
			me._volt = global.clamp(me._volt,0.0,me._voltMax);
			me._ampereAvailable = global.clamp(me._ampereAvailable,0.0,me._ampereMax);
			interpolate(me._nVolt,me._volt,dt);
			interpolate(me._nAmpereAvailable,me._ampereAvailable,dt);
			
		}else{
			me._nVolt.setValue(0);
			me._nAmpereAvailable.setValue(0);
		}
	},
	update : func(now,dt){
		if (me._nBusVolt.getValue() < me._voltMax){
			me._gernerateVolt(now,dt);
		}
	}
};

var BatteryClass = {
	new : func(root,name){
		var m = { 
			parents : [
				BatteryClass,
				ElectricClass.new(root,name)
			]
		};
		m._nAmpereAvailable	= m._nRoot.initNode("ampere_available",0.0,"DOUBLE");
		m._voltMax		= 24.0;
		m._ampereMax		= 1000.0;
		m._capacityAh		= 28.0;
		return m;
	},
	update : func(now,dt){
		me._nVolt.setValue(me._voltMax);
		me._nAmpereAvailable.setValue(me._ampereMax);
	}
};

var DCBusClass = {
	new : func(root,name){
		var m = { 
			parents : [
				DCBusClass, 
				ElectricClass.new(root,name)
			]
		};
		m._inputs		= {};
		m._inputIndex		= [];
		m._outputs		= {};
		m._outputIndex		= [];
		
		return m;
	},
	addInput : func(obj){
		me._inputs[obj.getName()] = obj;
		me._inputIndex = keys(me._inputs);
	},
	removeInput : func(obj){
		delete(me._inputs, obj.getName());
		me._inputIndex = keys(me._inputs);
	},
	addOutput : func(obj){
		me._outputs[obj.getName()] = obj;
		me._outputIndex = keys(me._outputs);
	},
	removeOutput : func(obj){
		delete(me._outputs, obj.getName());
		me._outputIndex = keys(me._outputs);
	},
	_collectVolt : func(){
		var volt = 0;
		me._volt = 0;
		foreach( index;  me._inputIndex ){
			volt = me._inputs[index].getVolt();
			if (volt > me._volt){
				me._volt = volt;
			}
		}
		me._nVolt.setValue(me._volt);
	},
	_dirstributeVolt :func(){
		me._ampere = 0;
		foreach( index;  me._outputIndex ){
			me._outputs[index].setVolt(me._volt);
			me._ampere += me._outputs[index].getAmpere();
		}
		me._nAmpere.setValue(me._ampere);
	},
	update : func(now,dt){
		me._collectVolt();
		me._dirstributeVolt();
	}
	
};

var CircuitBrakerClass = {
	new : func(root,name,ampereMax=1.0){
		var m = { 
			parents 		: [
				DCBusClass,
				ElectricClass.new(root,name)
			]
		};
			m._outputs		= {};
			m._outputIndex		= [];
			m._ampereMax		= ampereMax;
			m._nState		= m._nRoot.initNode("state",1,"BOOL");
		return m;
	},
	addOutput : func(obj){
		me._outputs[obj.getName()] = obj;
		me._outputIndex = keys(me._outputs);
	},
	removeOutput : func(obj){
		delete(me._outputs, obj.getName());
		me._outputIndex = keys(me._outputs);
	},
	setVolt		 : func(volt){ 
		if (me._nState.getValue() == 1){
			me._nVolt.setValue(volt);
		}else{
			me._nVolt.setValue(0);
		}
	},
	getAmpere	 : func(){ 
		me._ampere = 0;
		if(me._nState.getValue() == 1 ){
			foreach( index;  me._outputIndex ){
				me._ampere +=me._outputs[index].getAmpere();
			}
			if (me._ampere > me._ampereMax){
				me._nState.setValue(0);
				me._ampere = 0;
			}
		}
		me._nAmpere.setValue(me._ampere);
		return me._ampere;
	},
	onClick : func(value = nil){
		if (value == nil){
			me._nState.SetValue(!me._nState.getValue());
		}else{
			me._nState.SetValue(value);
		}
	},
	registerUI : func(){
		UI.register("Circuit Breaker "~me.name~"", 		func{me.onClick(); } 	);
		UI.register("Circuit Breaker "~me.name~" open", 	func{me.onClick(0); }	);
		UI.register("Circuit Breaker "~me.name~" close", 	func{me.onClick(1); }	);
		
	}
	
};

var ConsumerClass = {
	new : func(root,name,watt=1.0){
		var m = { 
			parents : [
				ConsumerClass,
				ElectricClass.new(root,name)
			]
		};
			m._watt			= watt;
			m._nWatt		= m._nRoot.initNode("watt",watt,"DOUBLE");
		return m;
	},
	setVolt		 : func(volt){ 
		me._volt	= volt;
		me._watt	= me._nWatt.getValue();
		if (me._volt > 0 ){
			me._ampere = me._watt / me._volt;
		}else{
			me._volt = 0;
			me._ampere = 0;
		}
		me._nVolt.setValue(me._volt);
		me._nAmpere.setValue(me._ampere);		
	},
	
};

var RelaisClass = {
	new : func(root,name){
		var m = { 
			parents : [
				RelaisClass,
				ElectricClass.new(root,name),
				StateListenerClass.new()
			]
		};
		m._nState			= m._nRoot.initNode("state",0,"BOOL");
		return m;
	},
	open : func(){
		me._nState.setValue(0);
	},
	close : func(){
		me._nState.setValue(1);
	},
	isClosed : func(){
		return me._nState.getValue();
	}
};
### User interface classes

var SwitchBoolClass = {
	new : func(root,name){
		var m = {parents : [
				SwitchBoolClass,
				ElectricClass.new(root,name),
				StateListenerClass.new()
		]};
		m._nState			= m._nRoot.initNode("state",0,"BOOL");
		return m;
	},
	onSet : func(value=nil){
		if (value == nil){
			me._nState.setValue(!me._nState.getValue());
		}else{
			me._nState.setValue(value);
		}
	},
	registerUI : func(){
		UI.register(me._name~"", 	func{me.onSet(); } 	);
		UI.register(me._name~" off", 	func{me.onSet(0); }	);
		UI.register(me._name~" on", 	func{me.onSet(1); }	);
		
	}
};

var SwitchIntClass = {
	new : func(root,name,min=0,max=1,step=1,labels=nil,default=0){ # {0:"off",1:"on"}
		var m = { 
			parents : [
				DCBusClass,
				ServiceClass.new(root,name),
				StateListenerClass.new()
			]			
		};
		m._nState		= m._nRoot.initNode("state",default,"INT");
		m._min			= min;
		m._max			= max;
		m._step			= step;
		m._labels		= labels;
		m._default		= default;
		return m;
	},
	onAdjust : func(value=0){
		value = me._nState.getValue() + value;
		value = global.clamp(value,me._min,me._max);
		me._nState.setValue(value);
	},
	onSet	: func(value=nil){
		if (value == nil){
			value = me._default;
		}
		value = global.clamp(value,me._min,me._max);
		me._nState.setValue(value);
	},
	registerUI : func(){
		UI.register(me._name~"", 	func{me.onSet(); } 	);
		UI.register(me._name~" >", 	func{me.onAdjust(me._step); } 	);
		UI.register(me._name~" <", 	func{me.onAdjust(-me._step); } 	);
		UI.register(me._name~" =", 	func(v=0){me.onSet(v); } 	);
		UI.register(me._name~" +=", 	func(v=0){me.onAdjust(v); } 	);
		
		if (me._labels != nil){
			for (var i=me._min; i <= me._max; i = i+1){
				if(contains(me._labels,i)){
					UI.register(me._name~" "~me._labels[i], 	func{me.onSet(i); }	);
				}
			}
		}
	}
};



var generator 		= GeneratorClass.new("/extra500/electric2/Generator","Generator");
var externalGenerator 	= ExternalGeneratorClass.new("/extra500/electric2/ExternalGenerator","ExternalGenerator");
var alternator 		= AlternatorClass.new("/extra500/electric2/Alternator","Alternator");
var battery 		= BatteryClass.new("/extra500/electric2/Battery","Battery");

var hotBus 		= DCBusClass.new("/extra500/electric2/Bus/HotBus","HotBus");
var batteryBus 		= DCBusClass.new("/extra500/electric2/Bus/BatteryBus","BatteryBus");
var loadBus 		= DCBusClass.new("/extra500/electric2/Bus/LoadBus","LoadBus");
var emergencyBus 	= DCBusClass.new("/extra500/electric2/Bus/EmergencyBus","EmergencyBus");
var avionicsBus 	= DCBusClass.new("/extra500/electric2/Bus/AvionicsBus","AvionicsBus");



var mainBattery = SwitchBoolClass.new("extra500/panel/Side/Main/Battery","Main Battery");
mainBattery.onStateChange = func(n){
	print("Es wurde der Battery Master geschaltet.");
	
	if (n.getValue()){
		batteryBus.addInput(hotBus);
		batteryBus.addOutput(hotBus);
	}else{
		batteryBus.removeInput(hotBus);
		batteryBus.removeOutput(hotBus);
	}
	
};
# switches
var mainAlternator = SwitchBoolClass.new("extra500/panel/Side/Main/StandbyAlt","Main Standby Alternator");
mainAlternator.onStateChange = func(n){
	if (n.getValue()){
		emergencyBus.addInput(alternator);
	}else{
		emergencyBus.removeInput(alternator);
	}
};

var mainGenerator = SwitchBoolClass.new("extra500/panel/Side/Main/Generator","Main Generator");
mainGenerator.onStateChange = func(n){
	if (n.getValue()){
		loadBus.addInput(generator);
	}else{
		loadBus.removeInput(generator);
	}
};

var mainExternal = SwitchBoolClass.new("extra500/panel/Side/Main/ExternalPower","Main External");
mainExternal.onStateChange = func(n){
	if (n.getValue()){
		batteryBus.addInput(externalGenerator);
	}else{
		batteryBus.removeInput(externalGenerator);
	}
};



var connectStatik = func(){
	
	hotBus.addInput(battery);
	hotBus.addOutput(battery);
	
	
}

var init = func(){

#switch listeners
	mainBattery.registerUI();
	mainBattery.setStateListener();
	mainAlternator.registerUI();
	mainAlternator.setStateListener();
	mainGenerator.registerUI();
	mainGenerator.setStateListener();
	mainExternal.registerUI();
	mainExternal.setStateListener();
	
}

var update = func(now,dt){
	#print("eSystem.update("~now~","~dt~") ...");
	externalGenerator.update(now,dt);
	generator.update(now,dt);
	alternator.update(now,dt);
	battery.update(now,dt);
	
	avionicsBus.update(now,dt);
	emergencyBus.update(now,dt);
	loadBus.update(now,dt);
	batteryBus.update(now,dt);
	hotBus.update(now,dt);
	
}

connectStatik();

