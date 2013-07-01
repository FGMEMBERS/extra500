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
			_path		: root,
			_nRoot		: props.globals.initNode(root),
			_name		: name,
		};
		return m;
	},
	getName : func(){
		return me._name;
	},
	getPath : func(){
		return me._path;
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
		m._nVolt.setValue(0.0);
		m._nAmpere.setValue(0.0);
		m._ampere		= 0.0;
		m._volt			= 0.0;
		return m;
	},
	setVolt : func(volt){ 
		#print("ElectricClass.setVolt("~volt~") ... "~me._name);
		me._nVolt.setValue(volt);
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

var SwitchFactory = {
	new : func(root,name,cfg=nil){
		var m = nil;
		if(cfg!=nil){
			if (cfg._type != "BOOL" ){
				return SwitchClass.new(root,name,cfg);
			}else{
				return SwitchBoolClass.new(root,name,cfg._default);	
			}
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
			_labels		: labels, #{-1:"low",0:"off",1:"high"}
		};
		return m;
	},
	cfgBOOL : func(default=0){
		var m = {
			_type		: "BOOL",
			_default	: default,
		};
		return m;
	}
};



### object class

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
		m._voltMax		= 28.5;
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
			me._nVolt.setValue(me._volt);
			me._nAmpereAvailable.setValue(me._ampereAvailable);
			
		}else{
			me._nVolt.setValue(0);
			me._nAmpereAvailable.setValue(0);
		}
	},
	_genSinusTest : func(now,dt){
		var sin = math.sin(now);
		
		me._volt = 26 + 2.5 * sin;
		me._ampereAvailable = 100 + 100 * sin;
			
		me._volt = global.clamp(me._volt,0.0,me._voltMax);
		me._ampereAvailable = global.clamp(me._ampereAvailable,0.0,me._ampereMax);
			
		me._nVolt.setValue(me._volt);
		me._nAmpereAvailable.setValue(me._ampereAvailable);
		
	},
	_spoolEngine : func(now,dt) {
		
	},
	update : func(now,dt){
		
		me._genSinusTest(now,dt);
# 		if ( me._nCtrlGenerator.getValue() ){
# 			me._spoolEngine(now,dt);
# 		}else{
# 			me._gernerateVolt(now,dt);
# 		}
	},
	_onVoltChange : func (n){
		me._volt = n.getValue();
		foreach( i;  me._outputIndex ){
			me._outputs[i].setInputVolt(me._volt);
		}		
	},
	applyAmpere : func(electron=nil){
		me._ampereAvailable = me._nAmpereAvailable.getValue();
		if (electron.ampere > 0){
			electron.ampere -= me._ampereAvailable;
		}
	},
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
			#interpolate(me._nVolt,me._volt,dt);
			#interpolate(me._nAmpereAvailable,me._ampereAvailable,dt);
			me._nVolt.setValue(me._volt);
			me._nAmpereAvailable.setValue(me._ampereAvailable);
			
		}else{
			me._nVolt.setValue(0);
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
	applyAmpere : func(electron=nil){
		me._ampereAvailable = me._nAmpereAvailable.getValue();
		if (electron.ampere > 0){
			electron.ampere -= me._ampereAvailable;
		}
	},
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
		m._ampereAvailable	= 0.0;			
		return m;
	},
	update : func(now,dt){
		me._volt = me._voltMax;
		me._nVolt.setValue(me._volt);
		me._nAmpereAvailable.setValue(me._ampereMax);
	},
	_onVoltChange : func (n){
		me._volt = n.getValue();
		foreach( i;  me._outputIndex ){
			me._outputs[i].setInputVolt(me._volt);
		}		
	},
	applyAmpere : func(electron=nil){
		me._ampereAvailable = me._nAmpereAvailable.getValue();
		if (electron.ampere > 0){
			electron.ampere -= me._ampereAvailable;
		}
	},
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
		m._nUsedAs		= m._nRoot.initNode("ampere_sec_used",0.0,"DOUBLE");
		m._nLoadLevel		= m._nRoot.initNode("loadLevel",0.0,"DOUBLE");
		m._capacityAs		= 28.0*3600;
		m._loadLevel = 0.8;
		m._usedAs = -(m._capacityAs * (1.0-m._loadLevel));
		m._voltMax		= 24.0;
		m._ampereMax		= 1000.0;
		m._lastTime		= systime();
		return m;
	},
	update : func(now,dt){
		me._volt = me._voltMax;
		me._nVolt.setValue(me._volt);
		me._nAmpereAvailable.setValue(me._ampereMax);
	},
	_onVoltChange : func (n){
		me._volt = n.getValue();
		foreach( i;  me._outputIndex ){
			me._outputs[i].setInputVolt(me._volt);
		}		
	},
	applyAmpere : func(electron=nil){
		if (electron.ampere > 0){
			var now = systime();
			var dt 	= now - me._lastTime;
			me._lastTime = now;
			
			me._usedAs += electron.ampere * dt;
					
			me._loadLevel = (me._capacityAs + me._usedAs) / me._capacityAs;
			
			me._nUsedAs.setValue(me._usedAs);
			me._nLoadLevel.setValue(me._loadLevel);
		}
	},
};

var CircuitBrakerClass = {
	new : func(root,name,ampereMax=1.0,default=1){
		var m = { 
			parents 		: [
				CircuitBrakerClass,
				ElectricClass.new(root,name)
			]
		};
		m._outputs		= {};
		m._outputIndex		= [];
		m._voltListener 	= nil;
		m._ampereListener 	= nil;
		m._stateListener	= nil;
		m._input 		= nil;
		m._lastAmpere		= 0.0;
		m._ampereMax		= ampereMax;
		m._nState		= m._nRoot.initNode("state",default,"BOOL");
		m._voltOut		= 0;
		return m;
	},
	setListerners : func() {
		me._voltListener 	= setlistener(me._nVolt,func(n){me._onVoltChange(n);},0,0);
		me._ampereListener 	= setlistener(me._nAmpere,func(n){me._onAmpereChange(n);},0,0);
		me._stateListener 	= setlistener(me._nState,func(n){me._onStateChange(n);},1,0);
	},
	setInput : func(obj){
		me._input = obj;
	},
	_deliverVolt : func(){
		if (me._state == 0){
			me._voltOut = 0;
		}else{
			me._voltOut = me._volt;
		}
		
		foreach( i;  me._outputIndex ){
			me._outputs[i].setVolt(me._voltOut);
		}
	},
	_onStateChange : func(n){
		me._state = n.getValue();
		me._deliverVolt();
		if (me._state == 0){
			print("CircuitBrakerClass._onStateChange() ... "~me._name~" break.");
		}
	},
	_onVoltChange : func(n){
		me._volt = n.getValue();
		me._deliverVolt();
	},
	_onAmpereChange : func(n){
		me._ampere = n.getValue();
		#print("CircuitBrakerClass._onAmpereChange("~me._ampere~") ... "~me._name~".");
		if (me._ampere < me._ampereMax){
			var dif = me._ampere - me._lastAmpere;
			me._lastAmpere = me._ampere;
			me._input.addAmpere(dif);
		}else{
			me._nState.setValue(0);
		}
	},
	onClick : func(value = nil){
		if (value == nil){
			me._nState.setValue(!me._nState.getValue());
		}else{
			me._nState.setValue(value);
		}
	},
	addAmpere : func(ampere){
		me._ampere = me._nAmpere.getValue();
		me._nAmpere.setValue(me._ampere + ampere);
	},
	addOutput : func(obj){
		me._outputs[obj.getName()] = obj;
		me._outputIndex = keys(me._outputs);
		obj.setInput(me);
		obj.setVolt(me._volt);
	},
	removeOutput : func(obj){
		delete(me._outputs, obj.getName());
		me._outputIndex = keys(me._outputs);
		obj.setVolt(0);
	},
	registerUI : func(){
		UI.register("Circuit Breaker "~me._name~"", 		func{me.onClick(); } 	);
		UI.register("Circuit Breaker "~me._name~" open", 	func{me.onClick(0); }	);
		UI.register("Circuit Breaker "~me._name~" close", 	func{me.onClick(1); }	);
		
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
		m._voltListener 	= nil;
		m._ampereListener 	= nil;
		m._input 		= nil;
		m._lastAmpere		= 0.0;
		m._watt			= watt;
		m._nWatt		= m._nRoot.initNode("watt",watt,"DOUBLE");
		m._nState		= m._nRoot.initNode("state",0,"BOOL");
		m._state		= 0;
		return m;
	},
	setInput : func(obj){
		me._input = obj;
	},
	setListerners : func() {
		me._voltListener 	= setlistener(me._nVolt,func(n){me._onVoltChange(n);},1,0);
		me._ampereListener 	= setlistener(me._nAmpere,func(n){me._onAmpereChange(n);},1,0);
	},
	_onVoltChange : func(n){
		
		me._volt = n.getValue();
		#print ("ConsumerClass._onVoltChange() ... "~me._name~" "~me._volt~"V");
		me.electricWork();
	},
	electricWork : func(){
		me._watt = me._nWatt.getValue();
		if(me._volt > 0){
			me._ampere = me._watt / me._volt;
			me._state  = 1;
		}else{
			me._ampere = 0;
			me._state  = 0;
		}
		me._nState.setValue(me._state);
		me._nAmpere.setValue(me._ampere);
	},
	_onAmpereChange : func(n){
		me._ampere = n.getValue();
		var dif = me._ampere - me._lastAmpere;
		me._lastAmpere = me._ampere;
		if (me._input != nil){
			me._input.addAmpere(dif);
		}
	},
	registerUI : func(){
		
	}
	
	
};

var LedClass = {
	new : func(root,name,bright="extra500/system/dimming/fullBright",watt=0.3){
		var m = { 
			parents : [
				LedClass,
				ConsumerClass.new(root,name,watt)
			]
		};
		m._nBrightness		= props.globals.initNode(bright,1.0,"DOUBLE");
		m._brightness		= 0;
		m._brightnessListener   = nil;
		m._nState		= m._nRoot.initNode("state",0.0,"DOUBLE",1);
		
		m._on = 0;
		m._test = 0;
		m._state = 0;
		return m;
	},
	setListerners : func() {
		me._voltListener 	= setlistener(me._nVolt,func(n){me._onVoltChange(n);},1,0);
		me._ampereListener 	= setlistener(me._nAmpere,func(n){me._onAmpereChange(n);},1,0);
		me._brightnessListener	= setlistener(me._nBrightness,func(n){me._onBrightnessChange(n);},1,0);
	},
	_onBrightnessChange : func(n){
		me._brightness = n.getValue();
		me.electricWork();
	},
	electricWork : func(){
		if ((me._on == 1 or me._test ==1) and me._volt > 22.0){
			me._watt = me._nWatt.getValue() * me._brightness;
			me._ampere = me._watt / me._volt;
			me._state = me._brightness;
		}else{
			me._ampere = 0;
			me._state = 0;
		}
		me._nAmpere.setValue(me._ampere);
		me._nState.setValue(me._state);
		me.shine(me._state);
	},
	# for override to get the light
	shine : func(light){
		
	},
	setState : func(value){
		me._on = value;
		me.electricWork();
	},
	on : func(){
		me._on = 1;
		me.electricWork();
	},
	off : func(){
		me._on = 0;
		me.electricWork();
	},
	testOn : func(){
		me._test = 1;
		me.electricWork();
	},
	testOff : func(){
		me._test = 0;
		me.electricWork();
	},
	
	
};

### User interface classes

var SwitchBoolClass = {
	new : func(root,name,default=0){
		var m = {parents : [
				SwitchBoolClass,
				ServiceClass.new(root,name)
		]};
		m._nState	= m._nRoot.initNode("state",default,"BOOL");
		m._state	= 0;
		return m;
	},
	setListerners : func() {
		me._stateListener = setlistener(me._nState,func(n){me.onStateChange(n);},1,0);
	},
	onStateChange : func (n){
		me._state	= n.getValue();
	},
	onClick : func(value=nil){
		if (value == nil){
			me._state = value == 1 ? 0 : 1;
		}else{
			me._state = value;
		}
		me._nState.setValue(me._state);
	},
	registerUI : func(){
		UI.register(me._name~"", 	func{me.onClick(); } 	);
		UI.register(me._name~" off", 	func{me.onClick(0); }	);
		UI.register(me._name~" on", 	func{me.onClick(1); }	);
		
	},
	
};

var SwitchClass = {
	new : func(root,name,cfg){ 
		var m = { 
			parents : [
				SwitchClass,
				ServiceClass.new(root,name)
			]			
		};
		m._nState		= m._nRoot.initNode("state",cfg._default,cfg._type);
		m._state		= 0;
		m._min			= cfg._min;
		m._max			= cfg._max;
		m._step			= cfg._step;
		m._labels		= cfg._labels;
		m._default		= cfg._default;
		return m;
	},
	setListerners : func() {
		me._stateListener = setlistener(me._nState,func(n){me.onStateChange(n);},1,0);
	},
	onStateChange : func (n){
		me._state	= n.getValue();
	},
	onAdjust : func(value=0){
		value = me._nState.getValue() + value;
		value = global.clamp(value,me._min,me._max);
		me._nState.setValue(value);
	},
	onSet	: func(value=nil){
		print("SwitchClass.onSet("~value~") ... "~me._name);
		if (value == nil){
			value = me._default;
		}
		value = global.clamp(value,me._min,me._max);
		me._nState.setValue(value);
	},
	onLable : func(value){
		#print("SwitchClass.onLable("~value~") ...");
		if(contains(me._labels,value)){
			me._nState.setValue(me._labels[value]);
		}
	},
	registerUI : func(){
		#print("SwitchClass.registerUI() ... "~me._name);
		UI.register(me._name~"", 	func{me.onSet(); } 	);
		UI.register(me._name~" >", 	func{me.onAdjust(me._step); } 	);
		UI.register(me._name~" <", 	func{me.onAdjust(-me._step); } 	);
		UI.register(me._name~" =", 	func(v=0){me.onSet(v); } 	);
		UI.register(me._name~" +=", 	func(v=0){me.onAdjust(v); } 	);
		if (me._labels != nil){
			#debug.dump(me._labels["0"]);
			var labelIndex = keys(me._labels);
			#debug.dump(labelIndex);
# 			for (var i=me._min; i <= me._max; i = i+1){
# 				
# 				if(contains(me._labels,i)){
# 					UI.register(me._name~" "~me._labels[i], 	func{me.onSet(i); }	);
# 				}else{
# 					print("no key at "~i);
# 				}
# 			}
			
			foreach(i ; labelIndex){
				UI.register(me._name~" "~i, 	func(i){me.onLable(""~i); },i	);
			}
		}
	},
	
};

var ESystem = {
	new : func(root,name){ 
		var m = { 
			parents : [
				ESystem,
				ServiceClass.new(root,name),
				
			]			
		};
		m._nVolt		= m._nRoot.initNode("volt",0.0,"DOUBLE");
		m._nAmpere		= m._nRoot.initNode("ampere",0.0,"DOUBLE");
		m._voltListener 	= nil;
		m._ampereListener 	= nil;
		m.source	 	= nil;
		m.switch	 	= nil;
		m.circuitBreaker 	= nil;
		m.consumer	 	= nil;
		m._outputs		= {};
		m._outputIndex		= [];
		
		m._volt = 0;
		m._ampere = 0;
		
		m._lastTime = systime();
		
		m._electron = ElectronClass.new();
		
		m.timerLoop = maketimer(1.0,m,ESystem.checkSource);
		
		return m;
	},
	init : func(){
		
	},
	setListerners : func() {
		me._voltListener 	= setlistener(me._nVolt,func(n){me._onVoltChange(n);},0,0);
		me._ampereListener 	= setlistener(me._nAmpere,func(n){me._onAmpereChange(n);},0,0);
	},
	connectOutput : func(obj){
		me._outputs[obj.getName()] = obj;
		me._outputIndex = keys(me._outputs);
		obj.setVolt(me._volt);
	},
	_onVoltChange : func(n){
		me._volt = n.getValue();
		
		foreach( i;  me._outputIndex ){
			me._outputs[i].setVolt(me._volt);
		}
	},
	_onAmpereChange : func(n){
		me._ampere = n.getValue();
		me.applyAmpere(me._ampere);
	},
	_setMaxVolt : func(volt){
		if(volt > me._volt){
			me._volt = volt;
		}
	},
	checkSource : func(){
		var now = systime();
		var dt = now - me._lastTime;
		me._lastTime = now;
		
		me._volt = 0;
		
# 		print ("\n ESystem.checkSource() ... "~now ~" "~dt~"\n");
		if(me.switch.External._state == 1){
			me.source.ExternalGenerator.update(now,dt);
			me._setMaxVolt(me.source.ExternalGenerator._volt);
# 			print ("External Generator " ~ me.source.externalGenerator._volt);
		}
		
		if(me.switch.Generator._state == 1){
			me.source.Generator.update(now,dt);
			me._setMaxVolt(me.source.Generator._volt);
# 			print ("Generator " ~ me.source.generator._volt);
		}
				
		if(me.switch.Alternator._state == 1){
			me.source.Alternator.update(now,dt);
			me._setMaxVolt(me.source.Alternator._volt);
# 			print ("Alternator " ~ me.source.alternator._volt);
		}
		
		if(me.switch.Battery._state == 1){
			me.source.Battery.update(now,dt);
			me._setMaxVolt(me.source.Battery._volt);
# 			print ("Battery " ~ me.source.battery._volt);
		}
		#print("Bus Volt " ~ me._volt);
		me._nVolt.setValue(me._volt);
	},
	applyAmpere : func(ampere){
		var now = systime();
		var dt = now - me._lastTime;
		me._lastTime = now;
		
		me._electron.ampere = ampere;
		
		if(me.switch.External._state == 1){
			me.source.ExternalGenerator.applyAmpere(me._electron,dt);
			me._setMaxVolt(me.source.ExternalGenerator._volt);
		}
		
		if(me.switch.Generator._state == 1){
			me.source.Generator.applyAmpere(me._electron,dt);
			me._setMaxVolt(me.source.Generator._volt);
		}
				
		if(me.switch.Alternator._state == 1){
			me.source.Alternator.applyAmpere(me._electron,dt);
			me._setMaxVolt(me.source.Alternator._volt);
		}
		
		if(me.switch.Battery._state == 1){
			me.source.Battery.applyAmpere(me._electron,dt);
			me._setMaxVolt(me.source.Battery._volt);
		}
		
		me._nVolt.setValue(me._volt);
	},
	addAmpere : func(ampere){
		me._ampere = me._nAmpere.getValue();
		me._nAmpere.setValue(me._ampere + ampere);
	},
	addOutput : func(obj){
		me._outputs[obj.getName()] = obj;
		me._outputIndex = keys(me._outputs);
		obj.setInput(me);
		obj.setVolt(me._volt);
	},
	
	
};





var eSystem = ESystem.new("/extra500/electric2/eSystem","EBox");

eSystem.source = {
	Generator 		: GeneratorClass.new("/extra500/electric2/Generator","Generator"),
	ExternalGenerator 	: ExternalGeneratorClass.new("/extra500/electric2/ExternalGenerator","ExternalGenerator"),
	Alternator 		: AlternatorClass.new("/extra500/electric2/Alternator","Alternator"),
	Battery 		: BatteryClass.new("/extra500/electric2/Battery","Battery"),
};

eSystem.switch = {
#side panel
	Battery 		: SwitchFactory.new("extra500/panel/Side/Main/Battery","Main Battery"),
	Alternator 		: SwitchFactory.new("extra500/panel/Side/Main/StandbyAlt","Main Standby Alternator"),
	Generator 		: SwitchFactory.new("extra500/panel/Side/Main/Generator","Main Generator",SwitchFactory.config("INT",-1,1,1,0,{"reset":-1,"off":0,"on":1})), 
	External 		: SwitchFactory.new("extra500/panel/Side/Main/ExternalPower","Main External Power"),
	GeneratorTest 		: SwitchFactory.new("extra500/panel/Side/Main/GeneratorTest","Main Generator Test",SwitchFactory.config("INT",-1,1,1,0,{"trip":-1,"off":0,"on":1})),
	Avionics 		: SwitchFactory.new("extra500/panel/Side/Main/Avionics","Main Avionics",SwitchFactory.cfgBOOL(1)),
	Strobe	 		: SwitchFactory.new("extra500/panel/Side/Light/Strobe","Light Strobe",SwitchFactory.cfgBOOL(1)),
	Navigation 		: SwitchFactory.new("extra500/panel/Side/Light/Navigation","Light Navigation"),
	Landing 		: SwitchFactory.new("extra500/panel/Side/Light/Landing","Light Landing"),
	Recognition 		: SwitchFactory.new("extra500/panel/Side/Light/Recognition","Light Recognition"),
	Cabin	 		: SwitchFactory.new("extra500/panel/Side/Light/Cabin","Light Cabin"),
	Map 			: SwitchFactory.new("extra500/panel/Side/Light/Map","Light Map"),
	Instrument 		: SwitchFactory.new("extra500/panel/Side/Light/Instrument","Light Instrument"),
	Glare	 		: SwitchFactory.new("extra500/panel/Side/Light/Glare","Light Glare"),
	Night	 		: SwitchFactory.new("extra500/panel/Side/Light/Night","Night",SwitchFactory.config("INT",-1,1,1,0,{"test":-1,"day":0,"night":1})),
	Ice 			: SwitchFactory.new("extra500/panel/Side/Light/Ice","Light Ice"),
	Propeller 		: SwitchFactory.new("extra500/panel/Side/Deicing/Propeller","Deicing Propeller"),
	PitotL 			: SwitchFactory.new("extra500/panel/Side/Deicing/PitotL","Deicing Pitot Left",SwitchFactory.config("INT",-1,1,1,1,{"test":-1,"off":0,"on":1})),
	PitotR 			: SwitchFactory.new("extra500/panel/Side/Deicing/PitotR","Deicing Pitot Right",SwitchFactory.config("INT",-1,1,1,1,{"test":-1,"off":0,"on":1})),
	Windshield 		: SwitchFactory.new("extra500/panel/Side/Deicing/Windshield","Deicing Windshield"),
	Boots 			: SwitchFactory.new("extra500/panel/Side/Deicing/Boots","Deicing Boots"),
	Pressure 		: SwitchFactory.new("extra500/panel/Side/Cabin/Pressure","Cabin Pressure Controller",SwitchFactory.config("INT",-1,1,1,1,{"dump":-1,"off":0,"on":1})),
	AirCondition 		: SwitchFactory.new("extra500/panel/Side/Cabin/AirCondition","Cabin Air Condition"),
	Vent 			: SwitchFactory.new("extra500/panel/Side/Cabin/Vent","Cabin Vent",SwitchFactory.config("INT",-1,1,1,-1,{"off":-1,"low":0,"high":1})),
	EnvironmentalAir 	: SwitchFactory.new("extra500/panel/Side/Cabin/EnvironmentalAir","Cabin Environmental Air"),
	TempMode 		: SwitchFactory.new("extra500/panel/Side/Cabin/TempMode","Cabin Temperature Controller Mode",SwitchFactory.config("INT",-1,1,1,0,{"cool":-1,"auto":0,"warm":1})),
	TempCtrl 		: SwitchFactory.new("extra500/panel/Side/Cabin/TempCtrl","Cabin Temperature Controller",SwitchFactory.cfgBOOL(1)),
	Temperature 		: SwitchFactory.new("extra500/panel/Side/Cabin/Temperature","Cabin Temperature",SwitchFactory.config("DOUBLE",-1.0,1.0,0.1,0.6)),
	Emergency 		: SwitchFactory.new("extra500/panel/Side/Emergency","Emergency"),
#master panel
	AutopilotMaster 	: SwitchFactory.new("extra500/panel/Master/Autopilot/Master","Autopilot Master",SwitchFactory.config("INT",-1,1,1,1,{"off":-1,"fd":0,"ap":1})),
	AutopilotPitchTrim 	: SwitchFactory.new("extra500/panel/Master/Autopilot/PitchTrim","Autopilot PitchTrim",SwitchFactory.cfgBOOL(1)),
	AutopilotYawDamper 	: SwitchFactory.new("extra500/panel/Master/Autopilot/YawDamper","Autopilot YawDamper",SwitchFactory.cfgBOOL(1)),
	AutopilotYawTrim 	: SwitchFactory.new("extra500/panel/Master/Autopilot/YawTrim","Autopilot Yaw Trim",SwitchFactory.config("DOUBLE",-1.0,1.0,0.1,0)),
	FuelTransferLeft 	: SwitchFactory.new("extra500/panel/Master/Fuel/TransferLeft","Fuel Transfer Left",SwitchFactory.cfgBOOL(1)),
	FuelTransferRight 	: SwitchFactory.new("extra500/panel/Master/Fuel/TransferRight","Fuel Transfer Right",SwitchFactory.cfgBOOL(1)),
	FuelPump1 		: SwitchFactory.new("extra500/panel/Master/Fuel/Pump1","Fuel Pump 1"),
	FuelPump2 		: SwitchFactory.new("extra500/panel/Master/Fuel/Pump2","Fuel Pump 2"),
	EngineOverSpeed 	: SwitchFactory.new("extra500/panel/Master/Engine/OverSpeed","Engine OverSpeed"),
	EngineMotoring 		: SwitchFactory.new("extra500/panel/Master/Engine/Motoring","Engine Motoring",SwitchFactory.config("INT",-1,1,1,-1,{"normal":-1,"abort":0,"on":1})),
	EngineStart 		: SwitchFactory.new("extra500/panel/Master/Engine/Start","Engine Start",SwitchFactory.config("INT",-1,1,1,-1,{"off":-1,"ign":0,"on":1})),
	DimmingKeypad 		: SwitchFactory.new("extra500/panel/Master/Dimming/Keypad","Dimmer Keypad",SwitchFactory.config("DOUBLE",0.0,1.0,0.1,0.5)),
	DimmingGlare 		: SwitchFactory.new("extra500/panel/Master/Dimming/Glare","Dimmer Glare",SwitchFactory.config("DOUBLE",0.0,1.0,0.1,0.25)),
	DimmingInstrument 	: SwitchFactory.new("extra500/panel/Master/Dimming/Instrument","Dimmer Instrument",SwitchFactory.config("DOUBLE",0.0,1.0,0.1,0.75)),
	DimmingSwitch 		: SwitchFactory.new("extra500/panel/Master/Dimming/Switch","Dimmer Switch",SwitchFactory.config("DOUBLE",0.0,1.0,0.1,0.5)),
	DimmingAnnunciator 	: SwitchFactory.new("extra500/panel/Master/Dimming/Annunciator","Dimmer Annunciator",SwitchFactory.config("DOUBLE",0.0,1.0,0.1,0.5)),
	
};

eSystem.circuitBreaker = {
#load bus
	AIR_CON			: CircuitBrakerClass.new("extra500/panel/CircuitBreaker/BankA/AirCondition","Air Condition",125),
	VENT			: CircuitBrakerClass.new("extra500/panel/CircuitBreaker/BankA/Vent","Vent",30),
	AIR_CTRL		: CircuitBrakerClass.new("extra500/panel/CircuitBreaker/BankA/AirControl","Air Control",2),
	PITOT_R			: CircuitBrakerClass.new("extra500/panel/CircuitBreaker/BankB/PitotR","Pitot R",15),
	CIGA_LTR		: CircuitBrakerClass.new("extra500/panel/CircuitBreaker/BankA/CigaretteLighter","Cigarette Lighter",10),
	DIP_2			: CircuitBrakerClass.new("extra500/panel/CircuitBreaker/BankB/DIP2","DIP-2",1),
	ENG_INST_2		: CircuitBrakerClass.new("extra500/panel/CircuitBreaker/BankB/EngineInstrument2","Engine Instrument 2",2),
	FUEL_TR_L		: CircuitBrakerClass.new("extra500/panel/CircuitBreaker/BankB/FuelTransferL","Fuel Transfer L",5),
	FUEL_TR_R		: CircuitBrakerClass.new("extra500/panel/CircuitBreaker/BankB/FuelTransferR","Fuel Transfer R",5),
	P_VENT			: CircuitBrakerClass.new("extra500/panel/CircuitBreaker/BankA/PanelVent","Panel Vent",2),
	CABIN_LT		: CircuitBrakerClass.new("extra500/panel/CircuitBreaker/BankB/CabinLight","Cabin Light",5),
	NAV_LT			: CircuitBrakerClass.new("extra500/panel/CircuitBreaker/BankB/NavLight","Nav Light",5),
	RECO_LT			: CircuitBrakerClass.new("extra500/panel/CircuitBreaker/BankB/RecognitionLight","Recognition Light",5),
	O_SP_TEST		: CircuitBrakerClass.new("extra500/panel/CircuitBreaker/BankB/OverSpeed","Over Speed Test",2),
	IFD_RH_A		: CircuitBrakerClass.new("extra500/panel/CircuitBreaker/BankA/IFD-RH-A","IFD Right A",10),
	WTHR_DET		: CircuitBrakerClass.new("extra500/panel/CircuitBreaker/BankA/WeatherDetection","Weather Detection",10),
	DME			: CircuitBrakerClass.new("extra500/panel/CircuitBreaker/BankA/DME","DME",2),
	AUDIO_MRK		: CircuitBrakerClass.new("extra500/panel/CircuitBreaker/BankA/AudioMarker","Audio Marker",5),
	VDC12			: CircuitBrakerClass.new("extra500/panel/CircuitBreaker/BankA/VDC12","VDC12",10),
	IRIDUM			: CircuitBrakerClass.new("extra500/panel/CircuitBreaker/BankA/Iridium","Iridium",10),
	SIRIUS			: CircuitBrakerClass.new("extra500/panel/CircuitBreaker/BankA/Sirius","Sirius",10),
	EMGC_2			: CircuitBrakerClass.new("extra500/panel/CircuitBreaker/BankB/Emergency2","Emergency 2",10),
#battery bus
	GEAR_AUX_1		: CircuitBrakerClass.new("extra500/panel/CircuitBreaker/BankD/GearAux1","Gear Aux 1",5),
	GEAR_CTRL		: CircuitBrakerClass.new("extra500/panel/CircuitBreaker/BankC/GearControl","Gear Control",5),
	HYDR			: CircuitBrakerClass.new("extra500/panel/CircuitBreaker/BankC/Hydraulic","Hydraulic",50),
	WSH_HT			: CircuitBrakerClass.new("extra500/panel/CircuitBreaker/BankC/WindShieldHeat","Wind Shield Heat",20),
	WSH_CTRL		: CircuitBrakerClass.new("extra500/panel/CircuitBreaker/BankC/WindShieldControl","Wind Shield Control",2),
	PROP_HT			: CircuitBrakerClass.new("extra500/panel/CircuitBreaker/BankC/PropellerHeat","PropellerHeat",20),
	FUEL_P_2		: CircuitBrakerClass.new("extra500/panel/CircuitBreaker/BankC/FuelPump2","Fuel Pump 2",7.5),
	START			: CircuitBrakerClass.new("extra500/panel/CircuitBreaker/BankC/Start","Start",5),
	IGN			: CircuitBrakerClass.new("extra500/panel/CircuitBreaker/BankC/Ignition","Ignition",5),
	ENV_BLEED		: CircuitBrakerClass.new("extra500/panel/CircuitBreaker/BankC/EnvironmentalBleed","Environmental Bleed",5),
	FLAP_CTRL		: CircuitBrakerClass.new("extra500/panel/CircuitBreaker/BankC/FlapControl","Flap Control",5),
	FLAP			: CircuitBrakerClass.new("extra500/panel/CircuitBreaker/BankC/Flap","Flap",7.5),
	FUEL_FLOW		: CircuitBrakerClass.new("extra500/panel/CircuitBreaker/BankC/FuelFlow","Fuel Flow",1),
	ICE_LT			: CircuitBrakerClass.new("extra500/panel/CircuitBreaker/BankC/IceLight","Ice Light",7.5),
	STROBE_LT		: CircuitBrakerClass.new("extra500/panel/CircuitBreaker/BankC/StrobeLight","Strobe Light",7.5),
	INST_LT			: CircuitBrakerClass.new("extra500/panel/CircuitBreaker/BankC/InstrumentLight","Instrument Light",7.5),
	BOOTS			: CircuitBrakerClass.new("extra500/panel/CircuitBreaker/BankC/Boots","Boots",2),
	AP_SERVO		: CircuitBrakerClass.new("extra500/panel/CircuitBreaker/BankC/AutopilotServo","Autopilot Servo",5),
	IFD_LH_B		: CircuitBrakerClass.new("extra500/panel/CircuitBreaker/BankC/IFD-LH-B","IFD Left B",10),
	VNE_WARN		: CircuitBrakerClass.new("extra500/panel/CircuitBreaker/BankC/VneWarn","Vne Warn",1),
	AV_BUS			: CircuitBrakerClass.new("extra500/panel/CircuitBreaker/BankC/AvBus","AV Bus",30),
	EMGC_1			: CircuitBrakerClass.new("extra500/panel/CircuitBreaker/BankC/Emergency1","Emergency 1",30),
#emergency bus
	GEAR_WARN		: CircuitBrakerClass.new("extra500/panel/CircuitBreaker/BankD/GearWarn","Gear Warn",2),
	FUEL_P_1		: CircuitBrakerClass.new("extra500/panel/CircuitBreaker/BankD/FuelPump1","Fuel Pump 1",7.5),
	PITOT_L			: CircuitBrakerClass.new("extra500/panel/CircuitBreaker/BankD/PitotL","Pitot L",10),
	DIP_1			: CircuitBrakerClass.new("extra500/panel/CircuitBreaker/BankD/DIP1","DIP 1",1),
	ENG_INST_1		: CircuitBrakerClass.new("extra500/panel/CircuitBreaker/BankD/EngineInstrument1","Engine Instrument 1",2),
	C_PRESS			: CircuitBrakerClass.new("extra500/panel/CircuitBreaker/BankD/CabinPressure","Cabin Pressure",3),
	DUMP			: CircuitBrakerClass.new("extra500/panel/CircuitBreaker/BankD/Dump","Dump",2),
	FUEL_QTY		: CircuitBrakerClass.new("extra500/panel/CircuitBreaker/BankD/FuelQuantity","Fuel Quantity",2),
	LOW_VOLT		: CircuitBrakerClass.new("extra500/panel/CircuitBreaker/BankD/LowVolt","Low Volt",1),
	STALL_WARN		: CircuitBrakerClass.new("extra500/panel/CircuitBreaker/BankD/StallWarning","Stall Warning",1),
	VOLT_MON		: CircuitBrakerClass.new("extra500/panel/CircuitBreaker/BankD/VoltMonitor","Volt Monitor",1),
	LDG_LT			: CircuitBrakerClass.new("extra500/panel/CircuitBreaker/BankD/LandingLight","Landing Light",10),
	WARN_LT			: CircuitBrakerClass.new("extra500/panel/CircuitBreaker/BankD/WarnLight","Warn Light",7.5),
	GLARE_LT		: CircuitBrakerClass.new("extra500/panel/CircuitBreaker/BankD/GlareLight","Glare Light",1),
	INTAKE_AI		: CircuitBrakerClass.new("extra500/panel/CircuitBreaker/BankD/IntakeAI","Intake AI",2),
	STBY_GYRO		: CircuitBrakerClass.new("extra500/panel/CircuitBreaker/BankD/StandbyGyroskop","Standby Gyroskop",2),
	IFD_LH_A		: CircuitBrakerClass.new("extra500/panel/CircuitBreaker/BankD/IFD-LH-A","IFD Left A",10),
	KEYPAD			: CircuitBrakerClass.new("extra500/panel/CircuitBreaker/BankD/Keypad","Keypad",1),
	ATC			: CircuitBrakerClass.new("extra500/panel/CircuitBreaker/BankD/ATC","ATC",3),
	GEN_RESET		: CircuitBrakerClass.new("extra500/panel/CircuitBreaker/BankD/GeneratorReset","Generator Reset",5),
	ALT			: CircuitBrakerClass.new("extra500/panel/CircuitBreaker/BankD/Alt","Alt",2),
#hot bus
	GEAR_AUX_2		: CircuitBrakerClass.new("extra500/panel/CircuitBreaker/GearAux2","Gear Aux 2",5),
	EXT_LADER		: CircuitBrakerClass.new("extra500/panel/CircuitBreaker/EXT_LADER","EXT LADER",5),
	ALT_FIELD		: CircuitBrakerClass.new("extra500/panel/CircuitBreaker/ALT_FIELD","ALT FIELD",2),
	COURTESY_LT		: CircuitBrakerClass.new("extra500/panel/CircuitBreaker/COURTESY_LT","Courtesy Light",5),
	ELT			: CircuitBrakerClass.new("extra500/panel/CircuitBreaker/ELT","ELT",1),
#avionic bus
	IFD_RH_B		: CircuitBrakerClass.new("extra500/panel/CircuitBreaker/BankB/IFD-RH-B","IFD Right B",10),
	TAS			: CircuitBrakerClass.new("extra500/panel/CircuitBreaker/BankB/TAS","TAS",3),
	AP_CMPTR		: CircuitBrakerClass.new("extra500/panel/CircuitBreaker/BankB/AutopilotComputer","Autopilot Computer",5),
	TB			: CircuitBrakerClass.new("extra500/panel/CircuitBreaker/BankB/TurnCoordinator","Turn Coordinator",5),
#no Bus
	FLAP_UNB		: CircuitBrakerClass.new("extra500/panel/CircuitBreaker/BankC/FlapUNB","Flap UNB",1),
	RCCB			: CircuitBrakerClass.new("extra500/panel/CircuitBreaker/BankB/RCCB","RCCB",1),
	BUS_TIE			: CircuitBrakerClass.new("extra500/panel/CircuitBreaker/BankB/BusTie","Bus Tie",0),
	
};


# switches 

eSystem.switch.Battery.onStateChange = func(n){
	me._state = n.getValue();
	#print("\nSwitch.onStateChange() ... "~me._name~" "~me._state~"\n");
	eSystem.checkSource();
};

eSystem.switch.Alternator.onStateChange = func(n){
	me._state = n.getValue();
	#print("\nSwitch.onStateChange() ... "~me._name~" "~me._state~"\n");
	eSystem.checkSource();
};

eSystem.switch.Generator.onStateChange = func(n){
	me._state = n.getValue();
	#print("\nSwitch.onStateChange() ... "~me._name~" "~me._state~"\n");
	eSystem.checkSource();
};

eSystem.switch.External.onStateChange = func(n){
	me._state = n.getValue();
	#print("\nSwitch.onStateChange() ... "~me._name~" "~me._state~"\n");
	eSystem.checkSource();
};

eSystem.switch.GeneratorTest.onStateChange = func(n){
	me._state = n.getValue();
	#print("\nSwitch.onStateChange() ... "~me._name~" "~me._state~"\n");
	eSystem.checkSource();
};

eSystem.switch.Avionics.onStateChange = func(n){
	me._state = n.getValue();
	#print("\nSwitch.onStateChange() ... "~me._name~" "~me._state~"\n");
	
};


var ConsumerPerCircuitBreaker = 6;

eSystem.init = func(){
	me.setListerners();
	var index = nil;

	index =  keys(me.switch);
	foreach (i;index){
		me.switch[i].registerUI();
		me.switch[i].setListerners();
	}
	index =  keys(me.circuitBreaker);
	var consumerCount = 0;
	foreach (i;index){
		me.circuitBreaker[i].registerUI();
		me.circuitBreaker[i].setListerners();
		me.addOutput(me.circuitBreaker[i]);
	}
	#print("Consumer count " ~ consumerCount);
	#connectStatik();
};





