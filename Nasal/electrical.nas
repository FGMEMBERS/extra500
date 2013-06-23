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
var ElectronClass ={
	new : func(){
		var m = {parents:[
			ElectronClass
		]};
		m.volt		= 0.0;
		m.ampere	= 0.0;
		m.timestamp	= 0.0;
		return m;
	},
	copyConstructor : func (){
		var electron = Electron.new();
		electron.volt		= me.volt;
		electron.ampere		= me.ampere;
		electron.timestamp	= me.timestamp;
		return electron;
	},
	copy : func(electron){
		me.volt		= electron.volt;
		me.ampere	= electron.ampere;
		me.timestamp	= electron.timestamp;
		
	},
	paste : func(electron){
		electron.volt		= me.volt;
		electron.ampere		= me.ampere;
		electron.timestamp	= me.timestamp;
		
	},
	zero : func(){
		me.volt		= 0.0;
		me.ampere	= 0.0;
	},
	set : func(volt,ampere,timestamp){
		me.volt		= volt;
		me.ampere	= ampere;
		me.timestamp	= timestamp;
		
	},
	getText : func(){
		return sprintf("%0.4fV %0.4fA %f",me.volt,me.ampere,me.timestamp);
	},
	setMaxVolt : func(volt){
		if (volt > me.volt){
			me.volt		= volt;
		}
	},
	needUpdate : func(now){
		if(me.timestamp != now){
			return 1;
		}else{
			return 0;
		}
	},
	
};

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

var InputVoltListenerClass = {
	new : func(){
		var m = { 
			parents 	: [
				InputVoltListenerClass, 
			]
		};
		m._inputVoltListener		= nil;
		m._nInputVolt			= nil;
		m._inputVoltTime		= 0.0;
		return m;
	},
	_onInputVoltChange : func (n){
		print ("InputVoltListenerClass._onInputVoltChange() ... "~me._name);
		me._inputVoltTime = n.getValue();
		me._nVolt.setValue(me._nInputVolt.getValue());
	},
	setInputVoltListener : func(){
		me._nInputVolt		= me._nRoot.initNode("voltInput",0.0,"DOUBLE");
		me._inputVoltListener 	= setlistener(me._nInputVolt,func(n){me._onInputVoltChange(n);},0,1);
	},
	removeInputVoltListener : func(){
		if(me._inputVoltListener) {
			removelistener(me._inputVoltListener);
			me._inputVoltListener 	= nil;
		}
	},
	setInputVolt : func(volt){ 
		print("InputVoltListenerClass.setInputVolt("~volt~") ... "~me._name);
		me._inputVoltTime = systime();
		me._nInputVolt.setValue(volt);
	},
};
var VoltListenerClass = {
	new : func(){
		var m = { 
			parents 	: [
				VoltListenerClass, 
			]
		};
		m._voltListener		= nil;
		m._nVolt		= nil;
		return m;
	},
	_onVoltChange : func (n){
		print ("VoltListenerClass._onVoltChange() ... do some work."~me._name);
		
	},
	setVoltListener : func(){
		me._nVolt		= me._nRoot.initNode("volt",0.0,"DOUBLE");
		me._voltListener 	= setlistener(me._nVolt,func(n){me._onVoltChange(n);},0,0);
	},
	removeVoltListener : func(){
		if(me._voltListener) {
			removelistener(me._voltListener);
			me._voltListener 	= nil;
		}
	},
	setVolt : func(volt){ 
		print("VoltListenerClass.setInputVolt("~volt~") ... "~me._name);
		me._nVolt.setValue(volt);
	},
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
		#me._nState		= me._nRoot.initNode("state",0.0,"DOUBLE");
		me._stateListener = setlistener(me._nState,func(n){me.onStateChange(n);},1,0);
	},
	removeStateListener : func(){
		if(me._stateListener) {
			removelistener(me._stateListener);
			me._stateListener = nil;
		}
	},
};

var UpdateListenerClass = {
	new : func(){
		var m = { 
			parents 	: [
				UpdateListenerClass, 
			]
		};
		m._updateListener	= nil;
		m._nUpdateTime		= nil;
		m._updateLast 		= 0.0;
		return m;
	},
	_onUpdate : func (n){
		var now = n.getValue();
		var dt = now - me._updateLast;
		me._updateLast = now;
		me.update(now,dt);
	},
	fireUpdate : func(){
		if (me._nUpdateTime != nil){
			var time = systime();
			print("UpdateListenerClass.fireUpdate() ..."~me._name ~" "~time);
			me._nUpdateTime.setValue(time);
		}
	},
	setUpdateListener : func(){
		me._nUpdateTime		= me._nRoot.initNode("updateTime",0.0,"DOUBLE");
		me._updateListener 	= setlistener(me._nUpdateTime,func(n){me._onUpdate(n);},0,0);
	},
	removeUpdateListener : func(){
		if(me._updateListener) {
			removelistener(me._updateListener);
			me._updateListener 	= nil;
			me._nUpdateTime		= nil;
		}
	},
	update : func(now,dt){
		
	},
	
};

var ElectricClass = {
	new : func(root,name){
		var m = { 
			parents 	: [
				ElectricClass, 
				ServiceClass.new(root,name),
				InputVoltListenerClass.new(),
				VoltListenerClass.new(),
			]
		};
		m._nVolt		= m._nRoot.initNode("volt",0.0,"DOUBLE");
		m._nAmpere		= m._nRoot.initNode("ampere",0.0,"DOUBLE");
		m._ampere		= 0.0;
		m._volt			= 0.0;
		return m;
	},
	getAmpere	 : func(){ 
		 
		return me._ampere = me._nAmpere.getValue();
	},
	getVolt		 : func(){ 
		#print("ElectricClass.getVolt() ... "~me._name);
		return me._volt = me._nVolt.getValue();
		
	},
	checkVolt : func(electron=nil){
		electron.setMaxVolt(me._nVolt.getValue());
	},
	checkAmpere : func(electron=nil){
		electron.ampere += me.getAmpere();
	}
	
};

var ElectricConnectAble = {
	new : func(root,name){
		var m = { 
			parents 	: [
				ElectricConnectAble, 
				ElectricClass.new(root,name)
			]
		};
		m._inputs		= {};
		m._inputIndex		= [];
		m._outputs		= {};
		m._outputIndex		= [];
		return m;
	},
	
	_addInput : func(obj){
		me._inputs[obj.getName()] = obj;
		me._inputIndex = keys(me._inputs);
	},
	_remInput : func(obj){
		delete(me._inputs, obj.getName());
		me._inputIndex = keys(me._inputs);
	},
	_addOutput : func(obj){
		me._outputs[obj.getName()] = obj;
		me._outputIndex = keys(me._outputs);
		},
	_remOutput : func(obj){
		delete(me._outputs, obj.getName());
		me._outputIndex = keys(me._outputs);
	},
	
	addInput : func(obj){
		me._addInput(obj);
		me.setInputVolt(obj.getVolt());
	},
	removeInput : func(obj){
		me._remInput(obj);
		me.setInputVolt(0);
	},
	addOutput : func(obj){
		me._addOutput(obj);
		obj.setInputVolt(me._nVolt.getValue());
	},
	removeOutput : func(obj){
		me._remOutput(obj);
		obj.setInputVolt(0);
	},
	
	connectInput : func(obj){
		me._addInput(obj);
		obj._addOutput(me);
		me.setInputVolt(obj.getVolt());
	},
	disconnectInput : func(obj){
		me._remInput(obj);
		obj._remOutput(me);
		me.setInputVolt(0);
	},
	connectOutput : func(obj){
		me._addOutput(obj);
		obj._addInput(me);
		obj.setInputVolt(me.getVolt());
	},
	disconnectOutput : func(obj){
		me._remOutput(obj);
		obj._remInput(me);
		obj.setInputVolt(0);
	},
	
	connectOutputInput : func (obj){
		me._addOutput(obj);
		obj._addInput(me);
		obj._addOutput(me);
		me._addInput(obj);
		obj.setInputVolt(me.getVolt());
	},
	disconnectOutputInput : func (obj){
		me._remInput(obj);
		obj._remOutput(me);
		obj._remInput(me);
		me._remOutput(obj);
		obj.setInputVolt(0);
	},
	connectInputOutput : func (obj){
		me._addInput(obj);
		obj._addOutput(me);
		obj._addInput(me);
		me._addOutput(obj);
		me.setInputVolt(obj.getVolt());
	},
	disconnectInputOutput : func (obj){
		me._remOutput(obj);
		obj._remInput(me);
		obj._remOutput(me);
		me._remInput(obj);
		me.setInputVolt(0);
	},
	
	
	
};


### 
var GeneratorClass = {
	new : func(root,name){
		var m = { 
			parents : [
				GeneratorClass,
				ElectricConnectAble.new(root,name)
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
			#interpolate(me._nVolt,me._volt,dt);
			#interpolate(me._nAmpereAvailable,me._ampereAvailable,dt);
			me._nInputVolt.setValue(me._volt);
			me._nAmpereAvailable.setValue(me._ampereAvailable);
			
		}else{
			me._nInputVolt.setValue(0);
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
	},
	_onVoltChange : func (n){
		me._volt = n.getValue();
		foreach( i;  me._outputIndex ){
			me._outputs[i].setInputVolt(me._volt);
		}		
	},
	
};

var AlternatorClass = {
	new : func(root,name){
		var m = { 
			parents : [
				AlternatorClass,
				ElectricConnectAble.new(root,name)
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
			#interpolate(me._nVolt,me._volt,dt);
			#interpolate(me._nAmpereAvailable,me._ampereAvailable,dt);
			me._nInputVolt.setValue(me._volt);
			me._nAmpereAvailable.setValue(me._ampereAvailable);
			
		}else{
			me._nInputVolt.setValue(0);
			me._nAmpereAvailable.setValue(0);
		}
	},
	update : func(now,dt){
		if (me._nBusVolt.getValue() < me._voltMax){
			me._gernerateVolt(now,dt);
		}
	},
	_onVoltChange : func (n){
		me._volt = n.getValue();
		foreach( i;  me._outputIndex ){
			me._outputs[i].setInputVolt(me._volt);
		}		
	},

};
var ExternalGeneratorClass = {
	new : func(root,name){
		var m = { 
			parents : [
				ExternalGeneratorClass,
				ElectricConnectAble.new(root,name)
			]
		};
		m._nAmpereAvailable	= m._nRoot.initNode("ampere_available",0.0,"DOUBLE");
		m._voltMax		= 28.5;
		m._ampereMax		= 1200.0;
						
		return m;
	},
	update : func(now,dt){
		me._nInputVolt.setValue(me._voltMax);
		me._nAmpereAvailable.setValue(me._ampereMax);
	},
	_onVoltChange : func (n){
		me._volt = n.getValue();
		foreach( i;  me._outputIndex ){
			me._outputs[i].setInputVolt(me._volt);
		}		
	},
	
};



var BatteryClass = {
	new : func(root,name){
		var m = { 
			parents : [
				BatteryClass,
				ElectricConnectAble.new(root,name)
			]
		};
		m._nAmpereAvailable	= m._nRoot.initNode("ampere_available",0.0,"DOUBLE");
		m._voltMax		= 24.0;
		m._ampereMax		= 1000.0;
		m._capacityAh		= 28.0;
		return m;
	},
	update : func(now,dt){
		me._nInputVolt.setValue(me._voltMax);
		me._nAmpereAvailable.setValue(me._ampereMax);
	},
	_onVoltChange : func (n){
		me._volt = n.getValue();
		foreach( i;  me._outputIndex ){
			me._outputs[i].setInputVolt(me._volt);
		}		
	},
	
};

var DCBusClass = {
	new : func(root,name){
		var m = { 
			parents : [
				DCBusClass, 
				ElectricConnectAble.new(root,name),
				UpdateListenerClass.new()
			]
		};
		m._electron = ElectronClass.new();
		m._voltIndex = [];
		return m;
	},
# 	_collectVolt : func(electron){
# 		var volt = 0;
# 		foreach( i;  me._inputIndex ){
# 			volt = me._inputs[i].getVolt(electron.timestamp);
# 			if (volt > electron.volt){
# 				electron.volt = volt;
# 			}
# 		}
# 		me._volt = electron.volt;
# 		me._nVolt.setValue(electron.volt);
# 	},
# 	getVolt : func(){
# 		me._electron.volt = 0 ; 
# 		me._electron.timestamp = systime();
# 		me._inputVoltTime = me._electron.timestamp;
# 		me.checkVolt(me._electron);
# 		return me._nVolt.getValue();
# 	},
	checkAmpere : func(electron=nil){
		if(electron != nil){
			if (electron.needUpdate(me._inputVoltTime) == 1){
				me._inputVoltTime = electron.timestamp;
				foreach( i;  me._outputIndex ){
					me._outputs[i].checkAmpere(electron);
				}
				me._ampere = electron.ampere;
				me._nAmpere.setValue(electron.ampere);
				
				foreach( i;  me._voltIndex ){
					me._outputs[i].checkAmpere(electron);
					if (electron.ampere <= 0){
						break;
					}
				}
				
			}
		}
	},
	checkVolt : func(electron=nil){
		if(electron != nil){
			
			if (electron.needUpdate(me._inputVoltTime) == 1){
				me._inputVoltTime = electron.timestamp;
				print ("DCBusClass.checkVolt() ... "~me._name ~"\t"~me._electron.volt);
						
				foreach( i;  me._inputIndex ){
					me._inputs[i].checkVolt(electron);
				}
				me._volt = electron.volt;
				me._nVolt.setValue(me._volt);
				
				me._voltIndex = sort(me._inputIndex,func (a,b){ return me._inputs[a]._volt > me._inputs[b]._volt ? 1 : 0 ;});
				debug.dump(me._voltIndex);
			}
		}	
	},
	_onVoltChange : func (n){
		me._volt = n.getValue();
		foreach( i;  me._outputIndex ){
			me._outputs[i].setInputVolt(me._volt);
		}		
	},
	_onOutputAmpereChange : func(n){
		me._electron.timestamp = n.getValue(); 
		me._electron.volt = me._volt;
		me._electron.ampere = 0.0;
		me.checkAmpere(me._electron);
		
	},
	_onInputVoltChange : func (n){
		#me._volt = n.getValue();
		me._electron.timestamp = me._inputVoltTime; 
		me._electron.volt = n.getValue();
		me._electron.ampere = 0.0;
		
		me._inputVoltTime = 0;
		
		me.checkVolt(me._electron);
# 		print ("DCBusClass._onInputVoltChange() ... "~me._name ~"\t"~me._volt);

	},
	update : func(now,dt){
		#me._distributeVolt();
	}
	
};

var CircuitBrakerClass = {
	new : func(root,name,ampereMax=1.0){
		var m = { 
			parents 		: [
				DCBusClass,
				ElectricClass.new(root,name),
				UpdateListenerClass.new()
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
	setInputVolt		 : func(volt,now = 0){ 
		if (me._nState.getValue() == 1){
			me._nVolt.setValue(volt);
		}else{
			me._nVolt.setValue(0);
		}
		me.fireUpdate();
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
	setInputVolt : func(volt,now = 0){ 
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

var SwitchFactory = {
	new : func(root,name,cfg=nil){
		var m = nil;
		if(cfg!=nil){
			return SwitchClass.new(root,name,cfg);
		}else{
			return SwitchBoolClass.new(root,name);
		}
		return m;
	},
	config : func(type="INT",min=-1,max=1,step=1,default=0,labels=nil){
		var m = {
			_type		: type,
			_min		: min,
			_max		: max,
			_step		: step,
			_default	: default,
			_labels		: nil, #{-1:"low",0:"off",1:"high"}
		};
		return m;
	},
};


var SwitchBoolClass = {
	new : func(root,name){
		var m = {parents : [
				SwitchBoolClass,
				ElectricClass.new(root,name),
				StateListenerClass.new()
		]};
		m._nState	= m._nRoot.initNode("state",0,"BOOL");
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

var SwitchClass = {
	new : func(root,name,cfg){ 
		var m = { 
			parents : [
				SwitchClass,
				ServiceClass.new(root,name),
				StateListenerClass.new()
			]			
		};
		m._nState		= m._nRoot.initNode("state",cfg._default,cfg._type);
		m._min			= cfg._min;
		m._max			= cfg._max;
		m._step			= cfg._step;
		m._labels		= cfg._labels;
		m._default		= cfg._default;
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


var src = {
	generator 		: GeneratorClass.new("/extra500/electric2/Generator","Generator"),
	externalGenerator 	: ExternalGeneratorClass.new("/extra500/electric2/ExternalGenerator","ExternalGenerator"),
	alternator 		: AlternatorClass.new("/extra500/electric2/Alternator","Alternator"),
	battery 		: BatteryClass.new("/extra500/electric2/Battery","Battery"),
};
var bus = {
	hot 			: DCBusClass.new("/extra500/electric2/Bus/HotBus","HotBus"),
	battery 		: DCBusClass.new("/extra500/electric2/Bus/BatteryBus","BatteryBus"),
	load 			: DCBusClass.new("/extra500/electric2/Bus/LoadBus","LoadBus"),
	emergency 		: DCBusClass.new("/extra500/electric2/Bus/EmergencyBus","EmergencyBus"),
	avionics 		: DCBusClass.new("/extra500/electric2/Bus/AvionicsBus","AvionicsBus"),
};
var swt = {
	battery 		: SwitchFactory.new("extra500/panel/Side/Main/Battery","Main Battery"),
	alternator 		: SwitchFactory.new("extra500/panel/Side/Main/StandbyAlt","Main Standby Alternator"),
	generator 		: SwitchFactory.new("extra500/panel/Side/Main/Generator","Main Generator",SwitchFactory.config("INT",-1,1,1,0,{"-1":"reset","0":"off","1":"on"})),
	external 		: SwitchFactory.new("extra500/panel/Side/Main/ExternalPower","Main External"),
	generatorTest 		: SwitchFactory.new("extra500/panel/Side/Main/GeneratorTest","Main Generator Test",SwitchFactory.config("INT",-1,1,1,0,{"-1":"trip","0":"off","1":"on"})),
	avionics 		: SwitchFactory.new("extra500/panel/Side/Main/Avionics","Main Avionics"),
	
};


# switches 

swt.battery.onStateChange = func(n){
	print("\nSwitch.onStateChange() ... "~me._name~"\n");
	
	if (n.getValue()){
		bus.hot.connectOutputInput(bus.battery);
	}else{
		bus.hot.disconnectOutputInput(bus.battery);
	}
	
};

swt.alternator.onStateChange = func(n){
	var position = n.getValue();
	if (position){
		src.alternator.connectOutputInput(bus.emergency);
	}elsif(position == -1){

	}else{
		src.alternator.disconnectOutputInput(bus.emergency);
	}
};

swt.generator.onStateChange = func(n){
	var position = n.getValue();
	if (position == 1){
		src.generator.connectOutputInput(bus.load);
	}else{
		src.generator.disconnectOutputInput(bus.load);
	}
};

swt.external.onStateChange = func(n){
	if (n.getValue()){
		src.externalGenerator.connectOutputInput(bus.battery);
	}else{
		src.externalGenerator.disconnectOutputInput(bus.battery);

	}
};

swt.generatorTest.onStateChange = func(n){
	var position = n.getValue();
	if(position == 1){
		
	}elsif(position == -1){
		
	}else{
		
	}
	
};

swt.avionics.onStateChange = func(n){
	if (n.getValue()){
		bus.battery.connectOutput(bus.avionics);
	}else{
		bus.battery.disconnectOutput(bus.avionics);

	}
};

var connectStatik = func(){
	
	src.battery.connectOutputInput(bus.hot);
	
	
	bus.battery.connectOutputInput(bus.emergency);
	bus.battery.connectOutputInput(bus.load);
	bus.battery.connectOutputInput(bus.emergency);
	
# 	bus.battery.addInput(bus.emergency);
	
# 	bus.emergency.addInput(bus.battery);
# 	bus.emergency.addOutput(bus.battery);
# 	
# 
# 	bus.load.addInput(bus.battery);
# 	bus.load.addOutput(bus.battery);
# 	bus.battery.addInput(bus.load);
# 	
# 	bus.battery.addOutput(bus.avionics);
# 	bus.avionics.addInput(bus.battery);
	
	
};

var init = func(){

#switch listeners
	#debug.dump(swt);
	var index = nil;
	
	index =  keys(src);
	foreach (i;index){
		src[i].setInputVoltListener();
		src[i].setVoltListener();
	}
	
	index =  keys(bus);
	foreach (i;index){
		#bus[i].setUpdateListener();
		bus[i].setInputVoltListener();
		bus[i].setVoltListener();
	}
	
	index =  keys(swt);
	foreach (i;index){
		swt[i].registerUI();
		swt[i].setStateListener();
	}
	
	connectStatik();
};

var updateBuses = func(){
	
};

var update = func(now,dt){
	print("\neSystem.update("~now~","~dt~") ...\n");
	src.externalGenerator.update(now,dt);
	src.generator.update(now,dt);
	src.alternator.update(now,dt);
	src.battery.update(now,dt);
	
	#bus.avionics.update(now,dt);
	#bus.emergency.update(now,dt);
	#bus.load.update(now,dt);
	#bus.battery.update(now,dt);
	#bus.hot.update(now,dt);
	
};



