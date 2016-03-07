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
#      Last change:      Eric van den Berg
#      Date:             22.01.15
#




### Base Classes
var ElectronClass ={
	new : func(name="unNamed"){
		var m = {parents:[
			ElectronClass
		]};
		m.volt		= 0.0;
		m.ampere	= 0.0;
		m.timestamp	= 0.0;
		m.name		= name;
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
	balanceVolt : func(obj){
		if(obj.volt > me.volt){
			me.volt = obj.volt;
		}else{
			obj.volt = me.volt;
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
		m._listeners = [];
		m._nService = m._nRoot.getNode("service",1);
		m._qos = 1.0;
		
		m._nQos  		= m._nService.initNode("qos",1.0,"DOUBLE");
		m._nLifetime 		= m._nService.initNode("lifetime",72000000,"INT");
		m._nBuildin 		= m._nService.initNode("buildin",0,"INT");
		m._nSerialNumber 	= m._nService.initNode("SerialNumber","","STRING");
		
		
		
		return m;
	},
	getName : func(){
		return me._name;
	},
	getPath : func(){
		return me._path;
	},
	init : func(instance=nil){
		if (instance==nil){instance=me;}
		me.setListeners(instance);
		#print("Service init\t" ~me._name);
	},
	deinit : func(){
		me.removeListeners();
	},
	setListeners  :func(instance){
		#print("ServiceClass.setListeners() ... " ~me._name);
	},
	removeListeners  :func(){
		foreach(var l;me._listeners){
			removelistener(l);
		}
		me._listeners = [];
	},
	
};

var OutPutClass = {
	new : func(){
		var m = { parents : [ OutPutClass ] };
		m._outputs		= {};
		m._outputIndex		= [];
		return m;
	},
	outputIndexRebuild : func(){
		me._outputIndex = keys(me._outputs);
	},
	outputAdd : func(obj){
		if (!contains(me._outputs,obj.getName())){
			me._outputs[obj.getName()] = obj;
			me._outputIndex = keys(me._outputs);
			obj.setInput(me);
			obj.setVolt(me._volt);
		}else{
# 			print("OutPutClass.outputAdd("~obj.getName()~") ... exists at "~me.getName());
# 			foreach(var i;  me._outputIndex ){
# 				print (i~" : "~me._outputs[i].getName());
# 			}
		}
	},
	outputRemove : func(obj){
		if (contains(me._outputs,obj.getName())){
			delete(me._outputs, obj.getName());
			me._outputIndex = keys(me._outputs);
			obj.setVolt(0);
		}
	},
};

var InputClass = {
	new : func(){
		var m = { parents : [ InputClass ] };
		m._input 		= nil;
		return m;
	},
	setInput : func(obj){
		me._input = obj;
	},
};

var ElectricClass = {
	new : func(root,name){
		var m = { 
			parents : [
				ElectricClass, 
				ServiceClass.new(root,name)
			]
		};
		m._ampere		= 0.0;
		m._volt			= 0.0;
		m._nVolt		= m._nRoot.initNode("volt",m._volt,"DOUBLE");
		m._nAmpere		= m._nRoot.initNode("ampere",m._ampere,"DOUBLE");
		m._nVolt.setValue(0.0);
		m._nAmpere.setValue(0.0);
		return m;
	},
	init : func(instance=nil){
		if (instance==nil){instance=me;}
		me.parents[1].init(instance);
		me.setListeners(instance);
	},
	setListeners : func(instance) {
		append(me._listeners, setlistener(me._nVolt,func(n){instance._onVoltChange(n);},1,0) );
		append(me._listeners, setlistener(me._nAmpere,func(n){instance._onAmpereChange(n);},1,0) );
	},
	_onVoltChange : func(n){
		#print ("ElectricClass._onVoltChange() ... Not what i want. WARNING !!!" ~me._name);
	},
	_onAmpereChange : func(n){
		#print ("ElectricClass._onAmpereChange() ... Not what i want. WARNING !!!"~me._name);
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
				ElectricClass.new(root,name),
				OutPutClass.new()
			]
		};
		m._ampereAvailable	= 0.0;
		m._nAmpereAvailable	= m._nRoot.initNode("ampere_available",m._ampereAvailable,"DOUBLE");
		m._generating		= 0;
		m._nGenerating		= m._nRoot.initNode("generating",m._generating,"BOOL");
		m._N1			= 0.0;
		m._nN1			= props.globals.initNode("/engines/engine[0]/n1");
		#m._nCtrlStarter		= props.globals.initNode("/controls/engines/engine[0]/starter",0,"BOOL");
		#m._nCtrlGenerator	= props.globals.initNode("/controls/electric/engine[0]/generator",0,"BOOL");
		m._voltMax		= 28.0;
		m._ampereMax		= 200.0;
		m._modeGenerator	= 0;
		m._ampereApplyed	= 0;
			
		return m;
	},
	init : func(instance=nil){
		if (instance==nil){instance=me;}
		me.parents[1].init(instance);
		
		me.outputIndexRebuild();
	},
	_gernerateVolt : func(now,dt){
		me._N1 = me._nN1.getValue();
		if ( (me._N1 > 55.0) and (me._modeGenerator == 1) ){
			me._volt 		= 0.8 * me._N1;
			me._ampereAvailable	= 2.85 * me._N1;
			
			me._volt 		= global.clamp(me._volt,0.0,me._voltMax);
			me._ampereAvailable 	= global.clamp(me._ampereAvailable,0.0,me._ampereMax);
			me._generating 		= 1;
		}else{
			me._volt 		= 0;
			me._ampereAvailable	= 0;
			me._generating 		= 0;
		}
		me._nVolt.setValue(me._volt);
		me._nAmpereAvailable.setValue(me._ampereAvailable);
		me._nGenerating.setValue(me._generating);
	},
	setModeGenerator : func(value){
		me._modeGenerator = value;
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
	update : func(now,dt){
		me._gernerateVolt(now,dt);
	},
	_onVoltChange : func (n){
		me._volt = n.getValue();
		foreach(var i;  me._outputIndex ){
			me._outputs[i].setInputVolt(me._volt);
		}		
	},
	applyAmpere : func(electron=nil){
		#me._ampereAvailable = me._nAmpereAvailable.getValue();
		if (electron.ampere <= me._ampereAvailable){
			me._ampereApplyed = electron.ampere;
		}else{
			me._ampereApplyed = me._ampereAvailable;
			
		}
		electron.ampere -= me._ampereApplyed;
	},
};
# MM Page 568
var AlternatorClass = {
	new : func(root,name){
		var m = { 
			parents : [
				AlternatorClass,
				ElectricClass.new(root,name),
				OutPutClass.new(),
				InputClass.new()
			]
		};
		m._nAmpereAvailable	= m._nRoot.initNode("ampere_available",0.0,"DOUBLE");
		m._nAmpereSurplus	= m._nRoot.initNode("ampere_surplus",0.0,"DOUBLE");
		m._nField		= m._nRoot.initNode("volt_field",0.0,"DOUBLE");
		m._nHasLoad		= m._nRoot.initNode("hasLoad",0,"BOOL");
		m._nN1			= props.globals.initNode("/engines/engine[0]/n1");
		m._N1			= 0.0;
		m._voltMin		= 18.0;
		m._voltMax		= 26.0;
		m._ampereMax		= 20.0;
		m._ampereAvailable	= 0.0;
		m._ampereApplyed	= 0;
		
		m._online		= 0;
		m._field		= 0;
		m._surplusAmpere	= 0;
		
		return m;
	},
	init : func(instance=nil){
		if (instance==nil){instance=me;}
		me.parents[1].init(instance);
		
		me.outputIndexRebuild();
	},
	setVolt : func(volt){ 
		#print("ElectricClass.setVolt("~volt~") ... "~me._name);
		me._field = volt;
		me._nField.setValue(me._field);
	},
	_checkBusSource : func(){
		
	},
	_gernerateVolt : func(now,dt){
		me._N1 = me._nN1.getValue();
		if ( (me._N1 > 55.0) and (me._online == 1) and (me._field >= me._voltMin) ){
			me._volt 		= me._voltMax;
			#me._ampereAvailable 	= me._N1 * 0.594795539 - 36.0892193309;
			
			if(me._N1 < 67.4){ 
				me._ampereAvailable = 4.0;
			}elsif(me._N1 > 90.3){ #94.3
				me._ampereAvailable = 20.0;
			}else{
				me._ampereAvailable = me._N1 * 0.594795539 - 36.0892193309;
			}
			# TODO : stop swinging with battery charge
			#me._volt = (me._voltMin) + (8 * me._surplusAmpere);
			#me._volt = (me._field) + (2 * (me._surplusAmpere));
			#me._volt = (me._field) + (1 * (me._surplusAmpere));
			me._volt = me._field + me._surplusAmpere;
			
			var min = me._voltMin;
			#min = eSystem.circuitBreaker.ALT_FIELD._volt;
			min = eSystem.source.Battery._volt;
			
			
			me._volt 		= global.clamp(me._volt,min,me._voltMax);
			#me._ampereAvailable 	= global.clamp(me._ampereAvailable,0.0,me._ampereMax);
			
		}else{
			me._volt 		= 0;
			me._ampereAvailable 	= 0;
			#me._nHasLoad.setValue(0);
		}
		me._nVolt.setValue(me._volt);
		me._nAmpereAvailable.setValue(me._ampereAvailable);
		
		me._nHasLoad.setValue((me._ampereApplyed > 0) and (me._online==1));
		me._ampereApplyed = 0;
			
	},
	setOnline : func(value){
		me._online = value;
		me._nHasLoad.setValue(0);
	},
	update : func(now,dt){
		
		me._gernerateVolt(now,dt);
		
	},
	_onVoltChange : func (n){
		me._volt = n.getValue();
		foreach(var  i;  me._outputIndex ){
			me._outputs[i].setInputVolt(me._volt);
		}		
	},
	applyAmpere : func(electron=nil){
		me._ampereAvailable = me._nAmpereAvailable.getValue();
		me._ampere = electron.ampere;
		me._ampereApplyed = 0;
		if(electron.ampere>0){
			me._nHasLoad.setValue(me._online);
			#me._surplusAmpere = (me._ampereAvailable - electron.ampere) / 20;
			if(me._ampereAvailable > 0){
				me._surplusAmpere = 1.0 - (electron.ampere/me._ampereAvailable);
				
				if (me._surplusAmpere >= 0){
					me._ampereApplyed = electron.ampere;
				}else{
					me._ampereApplyed = me._ampereAvailable;
				}
				electron.ampere -= me._ampereApplyed;
				
			}
		}else{
			me._ampereApplyed = 0;
			me._surplusAmpere = 1.0;
			me._nHasLoad.setValue(0);
		}
		me._surplusAmpere = global.clamp(me._surplusAmpere,-1,1);
		me._nAmpereSurplus.setValue(me._surplusAmpere);
		me._nAmpere.setValue(me._ampere);
		
	},
};

var ExternalGeneratorClass = {
	new : func(root,name){
		var m = { 
			parents : [
				ExternalGeneratorClass,
				ElectricClass.new(root,name),
				OutPutClass.new()
			]
		};
		m._nAmpereAvailable	= m._nRoot.initNode("ampere_available",0.0,"DOUBLE");
		m._nAmpereSurplus	= m._nRoot.initNode("ampere_surplus",0.0,"DOUBLE");
		m._nHasLoad		= m._nRoot.initNode("hasLoad",0,"BOOL");
		m._isPluged		= 0;
		m._nIsPluged		= m._nRoot.initNode("isPluged",m._isPluged,"BOOL");
		m._isPluged		= m._nIsPluged.getValue();
		m._voltMax		= 28.2; # 28.2 + 0.3 = 28.5 
		m._ampereMax		= 1200.0;
		m._ampereAvailable	= 0.0;	
		m._ampereApplyed	= 0;
		m._surplusAmpere	= 1.0;
		
		return m;
	},
	init : func(instance=nil){
		if (instance==nil){instance=me;}
		me.parents[1].init(instance);
		
		me.outputIndexRebuild();
		
		
		
		me.registerUI();
	},
	update : func(now,dt){
		if (me._isPluged == 1){
			me._volt 		= me._voltMax + (0.3 * me._surplusAmpere) + 0.05;
			me._ampereAvailable 	= me._ampereMax;
		}else{
			me._volt 		= 0;
			me._ampereAvailable 	= 0;
		}
		me._nVolt.setValue(me._volt);
		me._nAmpereAvailable.setValue(me._ampereAvailable);
	},
	_onVoltChange : func (n){
		me._volt = n.getValue();
		foreach(var  i;  me._outputIndex ){
			me._outputs[i].setInputVolt(me._volt);
		}		
	},
	applyAmpere : func(electron=nil){
		me._ampereAvailable = me._nAmpereAvailable.getValue();
		me._ampere = electron.ampere;
		if(electron.ampere>0){
			me._nHasLoad.setValue(1);
			me._surplusAmpere = (me._ampereAvailable - electron.ampere) / me._ampereMax;
			
			if (me._surplusAmpere >= 0){
				me._ampereApplyed = electron.ampere;
			}else{
				me._ampereApplyed =  me._ampereAvailable;
			}
			electron.ampere -= me._ampereApplyed;
		}else{
			me._ampereApplyed = 0;
			me._surplusAmpere = 1.0;
			me._nHasLoad.setValue(0);
		
		}
			
		me._nAmpereSurplus.setValue(me._surplusAmpere);
		me._nAmpere.setValue(me._ampere);
	},
	onPlug : func(value = nil){
		if (value == nil){
			me._isPluged 	= me._isPluged == 1 ? 0 : 1;
		}else{
			me._isPluged	= value;
		}
		me._nIsPluged.setValue(me._isPluged);
	},
	registerUI : func(){
		UI.register("Ground External Power Generator", 		func{me.onPlug(); } 	);
		UI.register("Ground External Power Generator on",	func{me.onPlug(1); } 	);
		UI.register("Ground External Power Generator off",	func{me.onPlug(0); } 	);
		
	},
};

var BatteryClass = {
	new : func(root,name){
		var m = { 
			parents : [
				BatteryClass,
				ElectricClass.new(root,name),
				OutPutClass.new()
			]
		};
		m._capacityAs		= 28.0*3600;
		m._ampereMax		= 1000.0;
		m._ampereApplyed	= 0;
		m._loadLevel 		= 0.97;
		m._usedAs 		= (m._capacityAs * (1.0-m._loadLevel));
		m._availableAs		= m._capacityAs * m._loadLevel;
		m._nAmpereAvailable	= m._nRoot.initNode("ampere_available",m._ampereMax,"DOUBLE");
		m._nAvailableAs		= m._nRoot.initNode("ampere_sec_available",m._availableAs,"DOUBLE");
		#m._nUsedAs		= m._nRoot.initNode("ampere_sec_used",m._usedAs,"DOUBLE");
		m._nLoadLevel		= m._nRoot.initNode("loadLevel",m._loadLevel,"DOUBLE");
		m._nAmpereCharge	= m._nRoot.initNode("ampere_charge",0,"DOUBLE",1);
		m._voltCells		= 0;
		m._voltPole		= 0;
		m._voltMin		= 15.3;
		m._voltMax		= 24.3;
		m._voltDelta		= m._voltMax - m._voltMin;
		m._lastTime		= systime();
		m._dt			= 0;
		return m;
	},
	init : func(instance=nil){
		if (instance==nil){instance=me;}
		me.parents[1].init(instance);
		
		me.outputIndexRebuild();
		
		me._loadLevel 		= me._nLoadLevel.getValue();
		
		me._availableAs 	= me._capacityAs * me._loadLevel;
		me._nAvailableAs.setValue(me._availableAs);
		
	},
	update : func(now,dt){
		me._dt = dt;

		if(me._loadLevel>0){
			# cell volts curve by remaining capacity
			me._voltCells = me._voltMax * (1 - ((1/(me._loadLevel*me._loadLevel)) * 0.00025) ) ;
			# lower the cell volts by load
			me._voltCells -= 1.5 *  (me._ampereApplyed / me._ampereMax) ; 
		}else{
			me._voltCells = 0;
		}
		
		me._voltCells = global.clamp(me._voltCells,0,me._voltMax);
				
		me._volt = me._voltCells;
		
		me._nVolt.setValue(me._volt);
	},
	_onVoltChange : func (n){
		me._volt = n.getValue();
		foreach(var  i;  me._outputIndex ){
			me._outputs[i].setInputVolt(me._volt);
		}		
	},
	applyAmpere : func(electron=nil){
		if (electron.ampere > 0){
			me._availableAs -= electron.ampere * me._dt;
			
			me._ampereApplyed = electron.ampere;
			electron.ampere = 0;
			
			me._availableAs = global.clamp(me._availableAs,0,me._capacityAs);
			me._loadLevel = me._availableAs / me._capacityAs;
			
			me._nAvailableAs.setValue(me._availableAs);
			me._nLoadLevel.setValue(me._loadLevel);
		}else{
			me._ampereApplyed = 0;
		}
	},
	charge : func(electron=nil){
		if (electron.volt > me._voltCells){
			me._voltPole = electron.volt;
# 			electron.ampere = 48.0 * (1 - ((me._volt - me._voltMin) / (electron.volt - me._voltMin))) * (1-me._loadLevel) ; ### FIXME : Better charge Curve
# 			Ka < 23Ah; I =90A
# 			Ka >=23Ah; I = 90-18*(Ka-23)
			var voltDelta = (electron.volt - me._voltCells) / 4;
			
			me._ampereCharge =  ( 90 - ( 18 * ( (me._availableAs/3600) - 23 ) ) ) ; 
			me._ampereCharge *=  voltDelta * voltDelta;
			me._ampereCharge = global.clamp(me._ampereCharge,0,90.0);
			
			me._availableAs += me._ampereCharge * me._dt ;
			me._availableAs = global.clamp(me._availableAs,0,me._capacityAs);
			me._loadLevel = me._availableAs / me._capacityAs;
				
			me._nAvailableAs.setValue(me._availableAs);
			me._nLoadLevel.setValue(me._loadLevel);
			
			electron.ampere += me._ampereCharge;
			
		}else{
			me._voltPole 		= me._voltCells;
			me._ampereCharge 	= 0;
		}
		me._nAmpereCharge.setValue(me._ampereCharge);
		#me._volt = me._voltCells >= me._voltPole ? me._voltCells : me._voltPole;
		
		#me._nVolt.setValue(me._volt);
	}
};

var RelayClass = {
	new : func(root,name,default=0){
		var m = { 
			parents 		: [
				RelayClass,
				ServiceClass.new(root,name)
			]
		};
		m._nState	= m._nRoot.initNode("state",default,"BOOL");
		m._state 	= 0;
		
		return m;
	},
	init : func(instance=nil){
		if (instance==nil){instance=me;}
		me.parents[1].init(instance);
		me.setListeners(instance);
	},
	setListeners : func(instance) {
		append(me._listeners ,setlistener(me._nState,func(n){instance._onStateChange(n);},1,0) );
	},
	_onStateChange : func(n){
		me._state = n.getValue();
	},
	checkCondition : func(){
		
	},
	setState : func(value){
		me._nState.setValue(value);
	},
	getState : func(value){
		return me._nState.getValue();
	},
};



var ConsumerClass = {
	new : func(root,name,watt=1.0){
		var m = { 
			parents : [
				ConsumerClass,
				ElectricClass.new(root,name),
				InputClass.new(),
				
			]
		};
		m._lastAmpere		= 0.0;
		m._watt			= watt;
		m._voltMin		= 16.0;
		m._voltMax		= 28.0;
		m._voltNorm		= global.norm(m._volt,m._voltMin,m._voltMax);
		m._nVoltMin		= m._nRoot.initNode("voltMin",m._voltMin,"DOUBLE");
		m._nVoltMax		= m._nRoot.initNode("voltMax",m._voltMax,"DOUBLE");
		m._nVoltNorm		= m._nRoot.initNode("voltNorm",m._voltNorm,"DOUBLE");
		m._nWatt		= m._nRoot.initNode("watt",watt,"DOUBLE");
		m._nState		= m._nRoot.initNode("state",0,"BOOL");
		m._state		= 0;
		return m;
	},
	setListeners : func(instance) {
		append(me._listeners, setlistener(me._nWatt,func(n){instance._onWattChange(n);},1,0) );
		append(me._listeners, setlistener(me._nVoltMin,func(n){instance._onVoltMinChange(n);},1,0) );
		append(me._listeners, setlistener(me._nVoltMax,func(n){instance._onVoltMaxChange(n);},1,0) );
		append(me._listeners, setlistener(me._nState,func(n){instance._onStateChange(n);},1,0) );
		
	},
	init : func(instance=nil){
		if (instance==nil){instance=me;}
		me.parents[1].init(instance);
		me.setListeners(instance);
	},
	_onVoltMinChange : func(n){
		
		me._voltMin = n.getValue();
		me._voltNorm	= global.norm(me._volt,me._voltMin,me._voltMax);
		me._nVoltNorm.setValue(me._voltNorm);
		#print ("ConsumerClass._onVoltChange() ... "~me._name~" "~me._volt~"V");
		me.electricWork();
	},
	_onVoltMaxChange : func(n){
		
		me._voltMax = n.getValue();
		me._voltNorm	= global.norm(me._volt,me._voltMin,me._voltMax);
		me._nVoltNorm.setValue(me._voltNorm);
		#print ("ConsumerClass._onVoltChange() ... "~me._name~" "~me._volt~"V");
		me.electricWork();
	},
	_onVoltChange : func(n){
		
		me._volt = n.getValue();
		me._voltNorm	= global.norm(me._volt,me._voltMin,me._voltMax);
		me._nVoltNorm.setValue(me._voltNorm);
		#print ("ConsumerClass._onVoltChange() ... "~me._name~" "~me._volt~"V");
		me.electricWork();
	},
	electricWork : func(){
		if(me._volt > me._voltMin){
			me._ampere = me._watt / me._volt;
			me._state  = 1;
		}else{
			me._ampere = 0;
			me._state  = 0;
		}
		me._nState.setValue(me._state);
		me._nAmpere.setValue(me._ampere);
	},
	_onWattChange : func(){
		me._watt = me._nWatt.getValue();
		me.electricWork();
	},
	_onAmpereChange : func(n){
		me._ampere = n.getValue();
		var dif = me._ampere - me._lastAmpere;
		me._lastAmpere = me._ampere;
		if (me._input != nil){
			me._input.addAmpere(dif);
		}
	},
	_onStateChange : func(n){
		me._state = n.getValue();
	},
	
	registerUI : func(){
		
	},
	
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
		m._nState		= m._nRoot.initNode("state",0.0,"DOUBLE",1);
		
		m._on = 0;
		m._test = 0;
		m._state = 0;
		return m;
	},
	setListeners : func(instance) {
		append(me._listeners, setlistener(me._nBrightness,func(n){instance._onBrightnessChange(n);},1,0));
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
		if ((me._on == 1 or me._test ==1) and me._volt > me._voltMin){
			me._watt = me._nWatt.getValue() * me._brightness;
			me._ampere = me._watt / me._volt;
			me._state = me._brightness * me._qos * me._voltNorm;
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
		m._state	= default;
		return m;
	},
	setListeners : func(instance) {
		append(me._listeners, setlistener(me._nState,func(n){instance.onStateChange(n);},1,0) );
	},
	init : func(instance=nil){
		if (instance==nil){instance=me;}
		me.parents[1].init(instance);
		me.setListeners(instance);
		me.registerUI();
	},
	onStateChange : func (n){
		me._state	= n.getValue();
	},
	onClick : func(value=nil){
		if (value == nil){
			me._state = me._state == 1 ? 0 : 1;
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
	setListeners : func(instance) {
		append(me._listeners, setlistener(me._nState,func(n){instance.onStateChange(n);},1,0) );
	},
	init : func(instance=nil){
		if (instance==nil){instance=me;}
		me.parents[1].init(instance);
		me.setListeners(instance);
		me.registerUI();
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

			foreach(var i ; labelIndex){
				UI.register(me._name~" "~i, 	func(i){me.onLable(""~i); },i	);
			}
		}
	},
	
};

var DcBusClass = {
	new : func(root,name){
		var m = { 
			parents 		: [
				DcBusClass,
				ElectricClass.new(root,name),
				InputClass.new(),
				OutPutClass.new(),
			]
		};
		m._lastAmpere		= 0;
		return m;
	},
	setListeners : func(instance) {

	},
	init : func(instance=nil){
		if (instance==nil){instance=me;}
		me.parents[1].init(instance);
		me.setListeners(instance);
		me.outputIndexRebuild();
	},
	_deliverVolt : func(){
		foreach(var  i;  me._outputIndex ){
			me._outputs[i].setVolt(me._volt);
		}
	},
	_onVoltChange : func(n){
		me._volt = n.getValue();
		me._deliverVolt();
	},
	_onAmpereChange : func(n){
		me._ampere = n.getValue();
		var dif = me._ampere - me._lastAmpere;
		me._lastAmpere = me._ampere;
		if(me._input!=nil){
			me._input.addAmpere(dif);
		}
	},
	addAmpere : func(ampere){
		me._ampere = me._nAmpere.getValue();
		me._nAmpere.setValue(me._ampere + ampere);
	},

};

var CircuitBrakerClass = {
	new : func(root,name,ampereMax=1.0,default=1){
		var m = { 
			parents 		: [
				CircuitBrakerClass,
				DcBusClass.new(root,name)
			]
		};
		m._ampereMax		= ampereMax;
		m._state		= 0;
		m._nState		= m._nRoot.initNode("state",default,"BOOL");
		m._voltOut		= 0;
		m._nVoltOut		= m._nRoot.initNode("voltOut",0.0,"DOUBLE");
		return m;
	},
	setListeners : func(instance) {
		append(me._listeners ,setlistener(me._nState,func(n){instance._onStateChange(n);},1,0) );
	},
	init : func(instance=nil){
		if (instance==nil){instance=me;}
		me.parents[1].init(instance);
		me.setListeners(instance);
		me.outputIndexRebuild();
		me.registerUI();
	},
	_deliverVolt : func(){
		if (me._state == 0){
			me._voltOut = 0;
		}else{
			me._voltOut = me._volt;
		}
		me._nVoltOut.setValue(me._voltOut);
		foreach(var  i;  me._outputIndex ){
			me._outputs[i].setVolt(me._voltOut);
		}
		
	},
	_onStateChange : func(n){
		me._state = n.getValue();
		me._deliverVolt();
		if (me._state == 0){
			#print("CircuitBrakerClass._onStateChange() ... "~me._name~" break.");
		}
	},
	_onAmpereChange : func(n){
		me._ampere = n.getValue();
		#print("CircuitBrakerClass._onAmpereChange("~me._ampere~") ... "~me._name~".");
		if (me._ampere < me._ampereMax){
			var dif = me._ampere - me._lastAmpere;
			me._lastAmpere = me._ampere;
			if(me._input!=nil){
				me._input.addAmpere(dif);
			}
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
	registerUI : func(){
		UI.register("Circuit Breaker "~me._name~"", 		func{me.onClick(); } 	);
		UI.register("Circuit Breaker "~me._name~" open", 	func{me.onClick(0); }	);
		UI.register("Circuit Breaker "~me._name~" close", 	func{me.onClick(1); }	);
		
	}
	
};


var ESystem = {
	new : func(root,name){ 
		var m = { 
			parents : [
				ESystem,
				ServiceClass.new(root,name),
				OutPutClass.new(),
				
			]			
		};
		m._nVolt		= m._nRoot.initNode("volt",0.0,"DOUBLE");
		m._nAmpere		= m._nRoot.initNode("ampere",0.0,"DOUBLE");
		m._nShuntBattery	= m._nRoot.initNode("loadBattery",0.0,"DOUBLE");
		m._nShuntGenerator	= m._nRoot.initNode("loadGenerator",0.0,"DOUBLE");
		
		m._shuntBattery		= 0;
		m._shuntGenerator	= 0;
		
		
		m._loadBattery		= 0.0;
		m._loadGenerator	= 0.0;
		
		
		m.relay		 	= nil;
		m.source	 	= nil;
		m.switch	 	= nil;
		m.circuitBreaker 	= nil;
		m.consumer	 	= nil;
				
		m._HotBus		= DcBusClass.new("/extra500/electric/bus/hot","Emergency Bus PP1");
		m._BatteryBus		= DcBusClass.new("/extra500/electric/bus/battery","Battery Bus PP2");
		m._LoadBus		= DcBusClass.new("/extra500/electric/bus/load","Load Bus PP3");
		m._EmergencyBus		= DcBusClass.new("/extra500/electric/bus/emergency","Emergency Bus PP4");
		m._AvionicsBus		= DcBusClass.new("/extra500/electric/bus/avionics","Avionics Bus PP5");
		m._PreBatteryBus	= DcBusClass.new("/extra500/electric/bus/preBattery","PreBatteryBus Bus PPx2");
		
		m._vExternPowerBus 	= ElectronClass.new("vExternPowerBus");
		m._vGeneratorBus 	= ElectronClass.new("vGeneratorBus");
		m._vStandbyAltBus 	= ElectronClass.new("vStandbyAltBus");
		m._vHotBus 		= ElectronClass.new("vHotBus");
		m._vPreBatteryBus 	= ElectronClass.new("vPreBatteryBus");
		m._vBatteryBus 		= ElectronClass.new("vBatteryBus");
		m._vLoadBus 		= ElectronClass.new("vLoadBus");
		m._vEmergencyBus 	= ElectronClass.new("vEmergencyBus");
		
		m._listBuses 	= [
				m._vExternPowerBus,
				m._vGeneratorBus,
				m._vStandbyAltBus,
				m._vHotBus,
				m._vPreBatteryBus,
				m._vBatteryBus,
				m._vLoadBus,
				m._vEmergencyBus
			];
		
		m._NullLoad		= ElectronClass.new();
		
		m._volt = 0;
		m._ampere = 0;
		
		m._lastTime = systime();
		
		m._electron = ElectronClass.new();
		
		m.timerLoop = nil;
		#print("ESystem.new() ... created.");
		
		return m;
	},
	init : func(instance=nil){
		#print("ESystem.init() ...");
		
		if (instance==nil){instance=me;}
		me.parents[1].init(instance);
		me.setListeners(instance);
		
		me.initUI();
		
		var index = nil;

		
		
				
		me._LoadBus.outputAdd(me.circuitBreaker.AIR_CON);
		me._LoadBus.outputAdd(me.circuitBreaker.VENT);
		me._LoadBus.outputAdd(me.circuitBreaker.AIR_CTRL);
		me._LoadBus.outputAdd(me.circuitBreaker.PITOT_R);
		me._LoadBus.outputAdd(me.circuitBreaker.CIGA_LTR);
		me._LoadBus.outputAdd(me.circuitBreaker.DIP_2);
		me._LoadBus.outputAdd(me.circuitBreaker.ENG_INST_2);
		me._LoadBus.outputAdd(me.circuitBreaker.FUEL_TR_L);
		me._LoadBus.outputAdd(me.circuitBreaker.FUEL_TR_R);
		me._LoadBus.outputAdd(me.circuitBreaker.P_VENT);
		me._LoadBus.outputAdd(me.circuitBreaker.CABIN_LT);
		me._LoadBus.outputAdd(me.circuitBreaker.NAV_LT);
		me._LoadBus.outputAdd(me.circuitBreaker.RECO_LT);
		me._LoadBus.outputAdd(me.circuitBreaker.O_SP_TEST);
		me._LoadBus.outputAdd(me.circuitBreaker.IFD_RH_A);
		me._LoadBus.outputAdd(me.circuitBreaker.WTHR_DET);
		me._LoadBus.outputAdd(me.circuitBreaker.DME);
		me._LoadBus.outputAdd(me.circuitBreaker.AUDIO_MRK);
		me._LoadBus.outputAdd(me.circuitBreaker.VDC12);
		me._LoadBus.outputAdd(me.circuitBreaker.IRIDUM);
		me._LoadBus.outputAdd(me.circuitBreaker.SIRIUS);
		me._LoadBus.outputAdd(me.circuitBreaker.EMGC_2);

		me._BatteryBus.outputAdd(me.circuitBreaker.GEAR_AUX_1);
		me._BatteryBus.outputAdd(me.circuitBreaker.GEAR_CTRL);
		me._BatteryBus.outputAdd(me.circuitBreaker.HYDR);
		me._BatteryBus.outputAdd(me.circuitBreaker.WSH_HT);
		me._BatteryBus.outputAdd(me.circuitBreaker.WSH_CTRL);
		me._BatteryBus.outputAdd(me.circuitBreaker.PROP_HT);
		me._BatteryBus.outputAdd(me.circuitBreaker.FUEL_P_2);
		me._BatteryBus.outputAdd(me.circuitBreaker.START);
		me._BatteryBus.outputAdd(me.circuitBreaker.IGN);
		me._BatteryBus.outputAdd(me.circuitBreaker.ENV_BLEED);
		me._BatteryBus.outputAdd(me.circuitBreaker.FLAP_CTRL);
		me._BatteryBus.outputAdd(me.circuitBreaker.FLAP);
		me._BatteryBus.outputAdd(me.circuitBreaker.FUEL_FLOW);
		me._BatteryBus.outputAdd(me.circuitBreaker.ICE_LT);
		me._BatteryBus.outputAdd(me.circuitBreaker.STROBE_LT);
		me._BatteryBus.outputAdd(me.circuitBreaker.INST_LT);
		me._BatteryBus.outputAdd(me.circuitBreaker.BOOTS);
		me._BatteryBus.outputAdd(me.circuitBreaker.AP_SERVO);
		me._BatteryBus.outputAdd(me.circuitBreaker.IFD_LH_B);
		me._BatteryBus.outputAdd(me.circuitBreaker.VNE_WARN);
		me._BatteryBus.outputAdd(me.circuitBreaker.AV_BUS);
		me._BatteryBus.outputAdd(me.circuitBreaker.EMGC_1);

		me._EmergencyBus.outputAdd(me.circuitBreaker.GEAR_WARN);
		me._EmergencyBus.outputAdd(me.circuitBreaker.FUEL_P_1);
		me._EmergencyBus.outputAdd(me.circuitBreaker.PITOT_L);
		me._EmergencyBus.outputAdd(me.circuitBreaker.DIP_1);
		me._EmergencyBus.outputAdd(me.circuitBreaker.ENG_INST_1);
		me._EmergencyBus.outputAdd(me.circuitBreaker.C_PRESS);
		me._EmergencyBus.outputAdd(me.circuitBreaker.DUMP);
		me._EmergencyBus.outputAdd(me.circuitBreaker.FUEL_QTY);
		me._EmergencyBus.outputAdd(me.circuitBreaker.LOW_VOLT);
		me._EmergencyBus.outputAdd(me.circuitBreaker.STALL_WARN);
		me._EmergencyBus.outputAdd(me.circuitBreaker.VOLT_MON);
		me._EmergencyBus.outputAdd(me.circuitBreaker.LDG_LT);
		me._EmergencyBus.outputAdd(me.circuitBreaker.WARN_LT);
		me._EmergencyBus.outputAdd(me.circuitBreaker.GLARE_LT);
		me._EmergencyBus.outputAdd(me.circuitBreaker.INTAKE_AI);
		me._EmergencyBus.outputAdd(me.circuitBreaker.STBY_GYRO);
		me._EmergencyBus.outputAdd(me.circuitBreaker.IFD_LH_A);
		me._EmergencyBus.outputAdd(me.circuitBreaker.KEYPAD);
		me._EmergencyBus.outputAdd(me.circuitBreaker.ATC);
		me._EmergencyBus.outputAdd(me.circuitBreaker.GEN_RESET);
		me._EmergencyBus.outputAdd(me.circuitBreaker.ALT);

		me._HotBus.outputAdd(me.circuitBreaker.GEAR_AUX_2);
		me._HotBus.outputAdd(me.circuitBreaker.EXT_LADER);
		me._HotBus.outputAdd(me.circuitBreaker.ALT_FIELD);
		me._HotBus.outputAdd(me.circuitBreaker.COURTESY_LT);
		me._HotBus.outputAdd(me.circuitBreaker.ELT);

		me._AvionicsBus.outputAdd(me.circuitBreaker.IFD_RH_B);
		me._AvionicsBus.outputAdd(me.circuitBreaker.TAS);
		me._AvionicsBus.outputAdd(me.circuitBreaker.AP_CMPTR);
		me._AvionicsBus.outputAdd(me.circuitBreaker.TB);

		me.outputAdd(me._HotBus);
		me.outputAdd(me._BatteryBus);
		me.outputAdd(me._LoadBus);
		me.outputAdd(me._EmergencyBus);
		me.outputAdd(me._PreBatteryBus);
		#me.outputAdd(me._AvionicsBus);
		
		me._HotBus.init();
		me._BatteryBus.init();
		me._LoadBus.init();
		me._EmergencyBus.init();
		me._AvionicsBus.init();
		me._PreBatteryBus.init();
		
		index =  keys(me.source);
		foreach (var i;index){
			me.source[i].init();
		}
		
		
		index =  keys(me.relay);
		foreach (var i;index){
			me.relay[i].init();
		}
		
		index =  keys(me.circuitBreaker);
		foreach (var i;index){
			me.circuitBreaker[i].init();
			#me.outputAdd(me.circuitBreaker[i]);
		}
		
		index =  keys(me.switch);
		foreach (var i;index){
			me.switch[i].init();
		}

		eSystem.relay.K1.checkCondition();
		eSystem.relay.K2.checkCondition();
		eSystem.relay.K3.checkCondition();
		eSystem.relay.K4.checkCondition();
		eSystem.relay.K5.checkCondition();
		eSystem.relay.K7.checkCondition();
		eSystem.relay.K10.checkCondition();
		

		me._timerLoop = maketimer(1.0,me,ESystem.checkSource);
		me._timerLoop.start();
		
	},
	setListeners : func(instance) {
		#append(me._listeners, setlistener(me._nVolt,func(n){me._onVoltChange(n);},1,0) );
		#append(me._listeners, setlistener(me._nAmpere,func(n){me._onAmpereChange(n);},1,0) );
	},
	connectOutput : func(obj){
		me._outputs[obj.getName()] = obj;
		me._outputIndex = keys(me._outputs);
		obj.setVolt(me._volt);
	},
	_onVoltChange : func(n){
		me._volt = n.getValue();
		
# 		foreach(var  i;  me._outputIndex ){
# 			me._outputs[i].setVolt(me._volt);
# 		}
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
		me.checkSource2();
	},
	
	checkSource2 : func(){
		var now = systime();
		var dt = now - me._lastTime;
		me._lastTime = now;
		# gererate the source voltage
		me.source.Generator.update(now,dt);
		me.source.Battery.update(now,dt);
		me.source.ExternalGenerator.update(now,dt);
		me.source.Alternator.update(now,dt);
		
		# set the vbus voltage
		me._vExternPowerBus.volt 	= me.source.ExternalGenerator._volt;
		me._vGeneratorBus.volt 		= me.source.Generator._volt;
		me._vStandbyAltBus.volt 	= me.source.Alternator._volt;
		me._vHotBus.volt 		= me.source.Battery._volt;
		me._vPreBatteryBus.volt 	= 0;
		me._vBatteryBus.volt 		= 0;
		me._vLoadBus.volt 		= 0;
		me._vEmergencyBus.volt 		= 0;

		# balance all busses
		me._balanceVoltage();
		
		# distribute the bus voltage to the property tree
		me._HotBus._nVolt.setValue(me._vHotBus.volt);
		me._BatteryBus._nVolt.setValue(me._vBatteryBus.volt);
		me._LoadBus._nVolt.setValue(me._vLoadBus.volt);
		me._EmergencyBus._nVolt.setValue(me._vEmergencyBus.volt);
		me._PreBatteryBus._nVolt.setValue(me._vPreBatteryBus.volt);
		
		# set the vbus ampere from the property tree (last round)
		me._vExternPowerBus.ampere 	= 0;
		me._vGeneratorBus.ampere 	= 0;
		me._vStandbyAltBus.ampere 	= 0;
		me._vHotBus.ampere 		= me._HotBus._ampere;
		me._vPreBatteryBus.ampere 	= me._PreBatteryBus._ampere;
		me._vBatteryBus.ampere 		= me._BatteryBus._ampere;
		me._vLoadBus.ampere 		= me._LoadBus._ampere;
		me._vEmergencyBus.ampere 	= me._EmergencyBus._ampere;
		
		# charge the battery from the vHotBus to get the amps
		me.source.Battery.charge(me._vHotBus);
		
# # 		var debugText = "";
# # 		
# # 		debugText ~= sprintf("--- Bus Voltage ------\n");
# # 		foreach(var bus; me._listBuses){
# # 			debugText ~= "\t" ~ sprintf("%15s: %0.2fV, %0.2fA\n",bus.name,bus.volt,bus.ampere);
# # 		}
		
		
		# map to hold the bus per voltage(tree)
		# volt => bus
		var mapBusVoltAmpere = {};
		
		# list Sources mapped to the tagging bus
		var listSources = [
			{source:me.source.ExternalGenerator,bus:me._vExternPowerBus},
			{source:me.source.Generator,bus:me._vGeneratorBus},
			{source:me.source.Alternator,bus:me._vStandbyAltBus},
			{source:me.source.Battery,bus:me._vHotBus}
		];
		
		# sum the amps in a bus(ElectronClass) for each voltage(tree)
		foreach(var bus; me._listBuses){
			#debug.dump(bus);
			if (bus.ampere > 0){
				#debug.dump(bus.volt,bus.ampere);
				if (mapBusVoltAmpere[bus.volt] == nil) {mapBusVoltAmpere[bus.volt] = ElectronClass.new();}
				mapBusVoltAmpere[bus.volt].ampere += bus.ampere; 
			}
		}
		# keep the index list for multiple usage
		var mapBusVoltIndex = keys (mapBusVoltAmpere);
# # 		debugText ~= sprintf ("\n");
# # 		
# # 		debugText ~= sprintf ("--- BusTree total ampere ------\n");
# # 		foreach (var i; mapBusVoltIndex) {
# # 			debugText ~= "\t" ~ sprintf("%0.2fV\t: %0.2fA\n",i,mapBusVoltAmpere[i].ampere);
# # 		}
		
# # 		debugText ~= sprintf ("--- applyAmpere to all sources ------\n");
		
		# search for source which is in the voltage(tree) by its tagging bus and apply the load.
		foreach (var s; listSources) {
# # 			var text = sprintf("%15s %0.2fV: bus:%0.2fV",s.source._name,s.source._volt,s.bus.volt);
			
			foreach (var voltIndex; mapBusVoltIndex) {
				if ( s.bus.volt == voltIndex ){
# # 					text ~= sprintf(", input: %0.2fA",mapBusVoltAmpere[voltIndex].ampere);
					
					# apply the load
					s.source.applyAmpere(mapBusVoltAmpere[voltIndex]);
					
# # 					text ~= sprintf(", rest: %0.2fA",mapBusVoltAmpere[voltIndex].ampere);
				}
			}
# # 			debugText ~= "\t" ~ text ~ "\n";
		}
		
# # 		debugText ~= sprintf ("--- BusTree total ampere left ------\n");
# # 		foreach (var i; mapBusVoltIndex) {
# # 			debugText ~= "\t" ~ sprintf("%0.2fV\t: %0.2fA\n",i,mapBusVoltAmpere[i].ampere);
# # 		}
# # 		
# # 		debugText ~= sprintf ("\n");
# # 		
# # 		#print(debugText);
		
		# calc the shunts 
		me._calcShunts();
		
		eSystem.relay.K7.checkCondition();
	},
	_calcShunts : func(){
		if (me.relay.K3._state == 1){
			me._shuntGenerator	= me.source.Generator._ampereApplyed;
		}else{
			me._shuntGenerator	= me.source.Alternator._ampereApplyed;
		}
		me._shuntBattery	= 0;
		
		
		
		if (me._vBatteryBus.volt == me._vExternPowerBus.volt) { # for external power
			
			me._shuntBattery -= me.source.ExternalGenerator._ampereApplyed;
			
			if (me.relay.K4._state == 1){
				me._shuntBattery += me.source.Battery._ampereCharge;
			}
			
		} else if ( ( (me._vBatteryBus.volt == me._vGeneratorBus.volt) or (me._vBatteryBus.volt == me._vStandbyAltBus.volt) ) and (me.relay.K4._state == 1)) {
			# for generator and alternator
			
			me._shuntBattery += me._vHotBus.ampere;
			me._shuntBattery -= me.source.Battery._ampereApplyed;
			
			if (me.relay.K10._state == 1){
				me._shuntBattery += me._vEmergencyBus.ampere;
			}
			
		} else if (me.relay.K4._state == 1) {
			# for battery only
			
			me._shuntBattery -= me.source.Battery._ampereApplyed;
			me._shuntBattery += me._vHotBus.ampere;
		} else {
			# no power source
			me._shuntBattery = 0;
		}
		
		
		me._nShuntBattery.setValue(me._shuntBattery);
		me._nShuntGenerator.setValue(me._shuntGenerator);
	},
	_balanceVoltage : func(){
		
# setting voltages on electrical busses depending on relays and CB-s	
# if alt relay is closed, EB has alt voltage
		if(me.relay.K7._state == 0){
			me._vEmergencyBus.volt = me._vStandbyAltBus.volt;
		}
# if altcharge relay is powered, hotbus is connected to emergency bus, take highest voltage
		if(me.relay.K10._state == 1){
			me._vEmergencyBus.volt = me._vHotBus.volt;
			me._vEmergencyBus.balanceVolt(me._vStandbyAltBus);
		}
# if external power is on (pre)battery bus has ext powr voltage, take highest voltage
		if(me.relay.K1._state == 1){
			me._vPreBatteryBus.balanceVolt(me._vExternPowerBus);
			me._vPreBatteryBus.balanceVolt(me._vBatteryBus);
		}
# gen relay on: generator voltage (external power relay automatically off)		
		if(me.relay.K3._state == 1){
			me._vLoadBus.balanceVolt(me._vGeneratorBus);
		}
		
# batt relay on: hotbus connected to pre batt bus, take highest voltage		
		if(me.relay.K4._state == 1){
			me._vHotBus.balanceVolt(me._vPreBatteryBus);
			me._vPreBatteryBus.balanceVolt(me._vBatteryBus);
		}

# RCCB closed: take highest voltage between load and batt bus OR bus tie closed: take highest voltage between load and batt bus
		if( (me.relay.K5._state == 1) or (me.circuitBreaker.BUS_TIE._state == 1) ){
			me._vBatteryBus.balanceVolt(me._vLoadBus);
		}
# when emerg2 CB is in and load bus voltage higher then emerg bus, take load bus voltage for emergency bus (not other way around;diode)		
		if((me.circuitBreaker.EMGC_2._state == 1) and (me._vLoadBus.volt > me._vEmergencyBus.volt)) {
			me._vEmergencyBus.volt = me._vLoadBus.volt;
		}
# alt charge closed: take highest voltage between batt and emergency bus
		if(me.relay.K10._state == 0){
			me._vBatteryBus.balanceVolt(me._vEmergencyBus);
		}
# batt relay on (for batt charging): if batt bus has higher voltage; transfer to hotbus
		if(me.relay.K4._state == 1){
			me._vBatteryBus.balanceVolt(me._vPreBatteryBus);
			me._vPreBatteryBus.balanceVolt(me._vHotBus);
		}
# when emerg1 CB is in and batt bus voltage higher then emerg bus, take batt bus voltage for emergency bus (not other way around;diode)
		if((me.circuitBreaker.EMGC_1._state == 1) and (me._vBatteryBus.volt > me._vEmergencyBus.volt)) {
			me._vEmergencyBus.volt = me._vBatteryBus.volt;
		}
		
# if altcharge relay is powered, hotbus is connected to emergency bus, take highest voltage (battery charging on alternator)		
		if(me.relay.K10._state == 1) {
			me._vHotBus.balanceVolt(me._vEmergencyBus);
		}
		
	},
	
	checkSource_old : func(){
		var now = systime();
		var dt = now - me._lastTime;
		me._lastTime = now;
		
		me._volt = 0;
		
		me.source.Generator.update(now,dt);
		me.source.Battery.update(now,dt);
		me.source.ExternalGenerator.update(now,dt);
		me.source.Alternator.update(now,dt);
		
		me._vHotBus.volt = me.source.Battery._volt;
		me._vBatteryBus.volt = 0;
		me._vLoadBus.volt = 0;
		me._vEmergencyBus.volt = 0;
		me._vPreBatteryBus.volt = 0;
		me._vStandbyAltBus.volt = me.source.Alternator._volt;
		me._vGeneratorBus.volt = me.source.Generator._volt;
		me._vExternPowerBus.volt = me.source.ExternalGenerator._volt;
		
		me._ballanceBuses_old();
		
		me._HotBus._nVolt.setValue(me._vHotBus.volt);
		me._BatteryBus._nVolt.setValue(me._vBatteryBus.volt);
		me._LoadBus._nVolt.setValue(me._vLoadBus.volt);
		me._EmergencyBus._nVolt.setValue(me._vEmergencyBus.volt);
		me._PreBatteryBus._nVolt.setValue(me._vPreBatteryBus.volt);
		
		me._loadBattery 	= 0;
		me._loadAlt		= 0;
		me._loadGenerator	= 0;
		me._loadExtPower	= 0;

		me._CurrBattShunt	= 0;
			
		me._vHotBus.ampere		= 0;
		me._vBatteryBus.ampere 		= 0;
		me._vLoadBus.ampere 		= 0;
		me._vEmergencyBus.ampere 	= 0;
		me._vPreBatteryBus.ampere 	= 0;
		
		me.source.Battery.charge(me._vHotBus);
		
		me._vHotBus.ampere		+= me._HotBus._ampere;
		me._vBatteryBus.ampere 		+= me._BatteryBus._ampere;
		me._vLoadBus.ampere 		+= me._LoadBus._ampere;
		me._vEmergencyBus.ampere 	+= me._EmergencyBus._ampere;
		me._vPreBatteryBus.ampere 	+= me._PreBatteryBus._ampere;
		
# Load bus check voltage and apply load to applicable source
		if (me._vLoadBus.volt == me.source.ExternalGenerator._volt) {
			me._loadExtPower += me._vLoadBus.ampere;
		} else if (me._vLoadBus.volt == me.source.Generator._volt) {
			me._loadGenerator	+= me._vLoadBus.ampere;
		} else if (me._vLoadBus.volt == me.source.Alternator._volt) {
			me._loadAlt	+= me._vLoadBus.ampere;
		} else if (me._vLoadBus.volt == me.source.Battery._volt) {
			me._loadBattery	+= me._vLoadBus.ampere;
		}

# Batt bus check voltage and apply load to applicable source
		if (me._vBatteryBus.volt == me.source.ExternalGenerator._volt) {
			me._loadExtPower += me._vBatteryBus.ampere;
		} else if (me._vBatteryBus.volt == me.source.Generator._volt) {
			me._loadGenerator	+= me._vBatteryBus.ampere;
		} else if (me._vBatteryBus.volt == me.source.Alternator._volt) {
			me._loadAlt	+= me._vBatteryBus.ampere;
		} else if (me._vBatteryBus.volt == me.source.Battery._volt) {
			me._loadBattery	+= me._vBatteryBus.ampere;
		}

# emergency bus check voltage and apply load to applicable source
		if (me._vEmergencyBus.volt == me.source.ExternalGenerator._volt) {
			me._loadExtPower += me._vEmergencyBus.ampere;
		} else if (me._vEmergencyBus.volt == me.source.Generator._volt) {
			me._loadGenerator	+= me._vEmergencyBus.ampere;
		} else if (me._vEmergencyBus.volt == me.source.Alternator._volt) {
			me._loadAlt	+= me._vEmergencyBus.ampere;
		} else if (me._vEmergencyBus.volt == me.source.Battery._volt) {
			me._loadBattery	+= me._vEmergencyBus.ampere;
		}

# hot bus check voltage and apply load to applicable source
		if (me._vHotBus.volt == me.source.ExternalGenerator._volt) {
			me._loadExtPower += me._vHotBus.ampere;
		} else if (me._vHotBus.volt == me.source.Generator._volt) {
			me._loadGenerator	+= me._vHotBus.ampere;
		} else if (me._vHotBus.volt == me.source.Alternator._volt) {
			me._loadAlt	+= me._vHotBus.ampere;
		} else if (me._vHotBus.volt == me.source.Battery._volt) {
			me._loadBattery	+= me._vHotBus.ampere;
		}

# battery shunt calcs (indicated on engine instruments)
		if (me._vBatteryBus.volt == me.source.ExternalGenerator._volt) { # for external power
			me._shuntBattery = me._loadExtPower - getprop("/extra500/electric/source/Battery/ampere_charge");
		} else if ( ( (me._vBatteryBus.volt == me.source.Generator._volt) or (me._vBatteryBus.volt == me.source.Alternator._volt) ) and (me.relay.K4._state == 1)) {
			me._shuntBattery = - getprop("/extra500/electric/source/Battery/ampere_charge");
		} else if (me.relay.K4._state == 1) {
			me._shuntBattery = me._loadBattery;
		} else {
			me._shuntBattery = 0;
		}
		setprop("/extra500/electric/shunt/battery_shunt",me._CurrBattShunt);
		

#		if (me._vHotBus.volt > me.source.Battery._volt) {me._loadBattery = -me._loadBattery;}

		
		var mapBusVoltAmpere = {};
		var listBuses 	= [
				me._vHotBus,
				me._vBatteryBus,
				me._vPreBatteryBus,
				me._vLoadBus,
				me._vEmergencyBus,
				me._vStandbyAltBus,
				me._vExternPowerBus,
				me._vGeneratorBus,
				
			];
		var listSources = [
				{source:me.source.ExternalGenerator,bus:me._vPreBatteryBus},
				{source:me.source.Generator,bus:me._vLoadBus},
				{source:me.source.Alternator,bus:me._vStandbyAltBus},
				{source:me.source.Battery,bus:me._vHotBus}
			];
			
			
		foreach(var bus; listBuses){
			#debug.dump(bus);
			if (bus.ampere > 0){
				#debug.dump(bus.volt,bus.ampere);
				if (mapBusVoltAmpere[bus.volt] == nil) {mapBusVoltAmpere[bus.volt] = ElectronClass.new();}
				mapBusVoltAmpere[bus.volt].ampere += bus.ampere; 
			}
		}
		
		var mapBusVoltIndex = keys (mapBusVoltAmpere);
		print ("\n");
		
		print ("--- BusTree total ampere ------");
		foreach (var i; mapBusVoltIndex) {

			#print the key and new value:
			print ("\t",sprintf("%0.2fV\t: %0.2fA",i,mapBusVoltAmpere[i].ampere));
		}
		
		print ("--- applyAmpere to all sources ------");
		foreach (var s; listSources) {
			var text = sprintf("%s %0.2fV: bus:%0.2fV",s.source._name,s.source._volt,s.bus.volt);
			
			foreach (var voltIndex; mapBusVoltIndex) {
				if (s.source._volt == voltIndex and s.bus.volt == voltIndex ){
					text ~= sprintf(", input: %0.2fA",mapBusVoltAmpere[voltIndex].ampere);
					
					s.source.applyAmpere(mapBusVoltAmpere[voltIndex]);
					
					text ~= sprintf(", rest: %0.2fA",mapBusVoltAmpere[voltIndex].ampere);
				}
			}
			print ("\t",text);
		}
		
		print ("--- BusTree total ampere left ------");
		foreach (var i; mapBusVoltIndex) {
			print ("\t",sprintf("%0.2fV\t: %0.2fA",i,mapBusVoltAmpere[i].ampere));
		}
		
		print ("\n");
		
		
# 		me.source.ExternalGenerator.applyAmpere(me._loadExtPower,dt);
# 		me.source.Generator.applyAmpere(me._loadGenerator,dt);
# 		me.source.Alternator.applyAmpere(me._loadAlt,dt);
# 		me.source.Battery.applyAmpere(me._loadBattery,dt);
		
#		if (me.relay.K1._state == 1){ # Load goes to external Generator
#			if( (me.relay.K5._state == 1) or (me.circuitBreaker.BUS_TIE._state == 1) ){ # load bus is connected to batt bus
#				me._vBatteryBus.ampere += me._LoadBus._ampere;
#			}
#			if( (me.relay.K10._state == 0) or (me.circuitBreaker.EMGC_1._state == 1) or ( (me.circuitBreaker.BUS_TIE._state == 1) and (me.circuitBreaker.EMGC_2._state == 1) ) ){
#				me._vBatteryBus.ampere += me._EmergencyBus._ampere;
#			}else{
#				me._vHotBus.ampere 	+= me._EmergencyBus._ampere;
#			}
#			
#			me._loadBattery			-= me._vBatteryBus.ampere; # does not matter as long as loading voltage is not higher as batt voltage...
#			me._vPreBatteryBus.ampere	+= me._vBatteryBus.ampere;
#			
#			if(me.relay.K4._state == 1){ # batt relay closed
#				me._vPreBatteryBus.ampere	+= me._vHotBus.ampere;
#			}else{
#				me.source.Battery.applyAmpere(me._vHotBus,dt);
#			}
#						
#			me.source.ExternalGenerator.applyAmpere(me._vPreBatteryBus,dt);
			
			
#		}else{
			
			
#			if (me.relay.K3._state == 1){ # Load goes to Generator
				
#				if( (me.relay.K5._state == 1) or (me.circuitBreaker.BUS_TIE._state == 1) ){ # load bus is connected to batt bus
					
#					if( (me.relay.K10._state == 0) or (me.circuitBreaker.EMGC_1._state == 1) or ( (me.circuitBreaker.BUS_TIE._state == 1) and (me.circuitBreaker.EMGC_2._state == 1) ) ){ # emergency bus connected to batt bus
#						me._vBatteryBus.ampere += me._EmergencyBus._ampere;
#					}else{
#						me._vHotBus.ampere 	+= me._EmergencyBus._ampere;
#					}
										
#					if(me.relay.K4._state == 1){ # batt relay closed
#						me._vPreBatteryBus.ampere 	+= me._vHotBus.ampere;						
#					}else{
#						if ( (me.relay.K10._state == 1) and (me.relay.K7._state == 0) ){ # batt relay open and hotbus connected to emergency bus, alt relay closed
#							me.source.Alternator.applyAmpere(me._vHotBus,dt);
#						}
#						me.source.Battery.applyAmpere(me._vHotBus,dt);
#					}
#					
#					me._loadBattery 	+= me._vPreBatteryBus.ampere;
#					me._vBatteryBus.ampere 	+= me._vPreBatteryBus.ampere;
#					
#					me._vLoadBus.ampere 	+= me._vBatteryBus.ampere;
#					
#					me._loadGenerator 	= me._vLoadBus.ampere;
#					me.source.Generator.applyAmpere(me._vLoadBus,dt);
#					me._loadGenerator	-= me._vLoadBus.ampere;
						
					
#					if ( (me.relay.K10._state == 0) and (me.relay.K7._state == 0) ){
#						me.source.Alternator.applyAmpere(me._vLoadBus,dt);
#					}
					
#					if (me.relay.K4._state == 1 ){
#						me._loadBattery		+= me._vLoadBus.ampere;
#						me.source.Battery.applyAmpere(me._vLoadBus,dt);
#					}
#				}
				

				
			
#			}else{
#				if( (me.relay.K7._state == 0) ){# Load goes to Alternator
#					if(me.relay.K10._state == 0){ # ALT Charge (Emergency)
						
#						if(me.relay.K5._state == 1){
#							me._vBatteryBus.ampere += me._vLoadBus.ampere;
#						}
#						
#						if(me.relay.K4._state == 1){
#							me._vPreBatteryBus.ampere 	+= me._vHotBus.ampere;
							
#						}
#						me._vBatteryBus.ampere 		+= me._vPreBatteryBus.ampere;
#						me._loadBattery			+= me._vPreBatteryBus.ampere;
#						me._vEmergencyBus.ampere 	+= me._vBatteryBus.ampere;
						
#						me._loadGenerator 	= me._vEmergencyBus.ampere;
						
#						me.source.Alternator.applyAmpere(me._vEmergencyBus,dt);
#						me._loadGenerator	-= me._vEmergencyBus.ampere;
						
#						if (me.relay.K4._state == 1 ){
#							me._loadBattery		-= me._vEmergencyBus.ampere;
#							me.source.Battery.applyAmpere(me._vEmergencyBus,dt);
#						}
						
#					}else{
#						if(me.relay.K4._state == 1){
#							if(me.relay.K5._state == 1){
#								me._vBatteryBus.ampere += me._vLoadBus.ampere;
#							}
#							me._vPreBatteryBus.ampere += me._vBatteryBus.ampere;
#							me._loadBattery		  -= me._vBatteryBus.ampere;
						
#						}
#						me._vEmergencyBus.ampere 	+= me._vHotBus.ampere;
#						
#						me._loadGenerator 	= me._vEmergencyBus.ampere;
#						me.source.Alternator.applyAmpere(me._vEmergencyBus,dt);
#						me._loadGenerator	-= me._vEmergencyBus.ampere;
#						me.source.Battery.applyAmpere(me._vEmergencyBus,dt);
						
#					}
					
					
					
#				}else{
#					if (me.relay.K4._state == 1 ){# Load goes to Battery
						
#						if(me.relay.K5._state == 1){
#							me._vBatteryBus.ampere += me._LoadBus._ampere;
#						}
						
#						if(me.relay.K10._state == 0){
#							me._vBatteryBus.ampere += me._EmergencyBus._ampere;
#						}else{
#							me._vHotBus.ampere 	+= me._EmergencyBus._ampere;
#						}
						
						
#						me._loadBattery		-= me._vBatteryBus.ampere;
						
#						me._vHotBus.ampere		+= me._vBatteryBus.ampere;
#						me._vHotBus.ampere		+= me._PreBatteryBus._ampere;
							
#						me.source.Battery.applyAmpere(me._vHotBus,dt);
#					}else{
						#print("eSystem.checkSource() ... WARNING ! no Source to apply load.")
#					}
					
#				}
#			}

#		}
		
		
		
		me._nShuntBattery.setValue(me._loadBattery);
		me._nShuntGenerator.setValue(me._loadGenerator);
		
		eSystem.relay.K7.checkCondition();
		
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
	onClickSC : func(value=nil){
#		/extra500/panel/Side/Emergency/safetyCap/state
#		/extra500/panel/Side/Emergency/state"
		if (value == nil) {
			if (getprop("/extra500/panel/Side/Emergency/safetyCap/state") == 0 ) {
				setprop("/extra500/panel/Side/Emergency/safetyCap/state",1);
			} else {
				setprop("/extra500/panel/Side/Emergency/safetyCap/state",0);
				setprop("/extra500/panel/Side/Emergency/state",0);
			}
		} else {
			if (value == 1) {
				setprop("/extra500/panel/Side/Emergency/safetyCap/state",1);
			} else {
				setprop("/extra500/panel/Side/Emergency/safetyCap/state",0);
				setprop("/extra500/panel/Side/Emergency/state",0);
			}
		}
	},
	initUI : func(){
		UI.register("EM safetyCap",func{extra500.eSystem.onClickSC(); } 	);
		UI.register("EM safetyCap off",func{extra500.eSystem.onClickSC(0); } 	);
		UI.register("EM safetyCap on",func{extra500.eSystem.onClickSC(1); } 	);
	}
};





var eSystem = ESystem.new("/extra500/electric/eSystem","EBox");

eSystem.relay = {
	K1			: RelayClass.new("/extra500/electric/relay/K1","EXT Power Relay K1"),
	K2			: RelayClass.new("/extra500/electric/relay/K2","Start Relay K2"),
	K3			: RelayClass.new("/extra500/electric/relay/K3","Generator Relay K3"),
	K4			: RelayClass.new("/extra500/electric/relay/K4","Battery Relay K4"),
	K5			: RelayClass.new("/extra500/electric/relay/K5","RCCB Relay K5"),
	K7			: RelayClass.new("/extra500/electric/relay/K7","Alternator Relay K7"),
	K10			: RelayClass.new("/extra500/electric/relay/K10","Alt Charge Relay K10"),
};


eSystem.source = {
	Generator 		: GeneratorClass.new("/extra500/electric/source/Generator","Generator"),
	ExternalGenerator 	: ExternalGeneratorClass.new("/extra500/electric/source/ExternalGenerator","External"),
	Alternator 		: AlternatorClass.new("/extra500/electric/source/Alternator","Alternator"),
	Battery 		: BatteryClass.new("/extra500/electric/source/Battery","Battery"),
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
	AIR_CON		: CircuitBrakerClass.new("extra500/panel/CircuitBreaker/BankA/AirCondition","Air Condition",125),
	VENT		: CircuitBrakerClass.new("extra500/panel/CircuitBreaker/BankA/Vent","Vent",30),
	AIR_CTRL	: CircuitBrakerClass.new("extra500/panel/CircuitBreaker/BankA/AirControl","Air Control",2),
	PITOT_R		: CircuitBrakerClass.new("extra500/panel/CircuitBreaker/BankB/PitotR","Pitot R",15),
	CIGA_LTR	: CircuitBrakerClass.new("extra500/panel/CircuitBreaker/BankA/CigaretteLighter","Cigarette Lighter",10),
	DIP_2		: CircuitBrakerClass.new("extra500/panel/CircuitBreaker/BankB/DIP2","DIP-2",1),
	ENG_INST_2	: CircuitBrakerClass.new("extra500/panel/CircuitBreaker/BankB/EngineInstrument2","Engine Instrument 2",2),
	FUEL_TR_L	: CircuitBrakerClass.new("extra500/panel/CircuitBreaker/BankB/FuelTransferL","Fuel Transfer L",5),
	FUEL_TR_R	: CircuitBrakerClass.new("extra500/panel/CircuitBreaker/BankB/FuelTransferR","Fuel Transfer R",5),
	P_VENT		: CircuitBrakerClass.new("extra500/panel/CircuitBreaker/BankA/PanelVent","Panel Vent",2),
	CABIN_LT	: CircuitBrakerClass.new("extra500/panel/CircuitBreaker/BankB/CabinLight","Cabin Light",5),
	NAV_LT		: CircuitBrakerClass.new("extra500/panel/CircuitBreaker/BankB/NavLight","Nav Light",5),
	RECO_LT		: CircuitBrakerClass.new("extra500/panel/CircuitBreaker/BankB/RecognitionLight","Recognition Light",5),
	O_SP_TEST	: CircuitBrakerClass.new("extra500/panel/CircuitBreaker/BankB/OverSpeed","Over Speed Test",2),
	IFD_RH_A	: CircuitBrakerClass.new("extra500/panel/CircuitBreaker/BankA/IFD-RH-A","IFD Right A",10),
	WTHR_DET	: CircuitBrakerClass.new("extra500/panel/CircuitBreaker/BankA/WeatherDetection","Weather Detection",10),
	DME		: CircuitBrakerClass.new("extra500/panel/CircuitBreaker/BankA/DME","DME",2),
	AUDIO_MRK	: CircuitBrakerClass.new("extra500/panel/CircuitBreaker/BankA/AudioMarker","Audio Marker",5),
	VDC12		: CircuitBrakerClass.new("extra500/panel/CircuitBreaker/BankA/VDC12","VDC12",10),
	IRIDUM		: CircuitBrakerClass.new("extra500/panel/CircuitBreaker/BankA/Iridium","Iridium",10),
	SIRIUS		: CircuitBrakerClass.new("extra500/panel/CircuitBreaker/BankA/Sirius","Sirius",10),
	EMGC_2		: CircuitBrakerClass.new("extra500/panel/CircuitBreaker/BankB/Emergency2","Emergency 2",10),
#battery bus
	GEAR_AUX_1	: CircuitBrakerClass.new("extra500/panel/CircuitBreaker/BankD/GearAux1","Gear Aux 1",5),
	GEAR_CTRL	: CircuitBrakerClass.new("extra500/panel/CircuitBreaker/BankC/GearControl","Gear Control",5),
	HYDR		: CircuitBrakerClass.new("extra500/panel/CircuitBreaker/BankC/Hydraulic","Hydraulic",50),
	WSH_HT		: CircuitBrakerClass.new("extra500/panel/CircuitBreaker/BankC/WindShieldHeat","Wind Shield Heat",20),
	WSH_CTRL	: CircuitBrakerClass.new("extra500/panel/CircuitBreaker/BankC/WindShieldControl","Wind Shield Control",2),
	PROP_HT		: CircuitBrakerClass.new("extra500/panel/CircuitBreaker/BankC/PropellerHeat","PropellerHeat",30),
	FUEL_P_2	: CircuitBrakerClass.new("extra500/panel/CircuitBreaker/BankC/FuelPump2","Fuel Pump 2",7.5),
	START		: CircuitBrakerClass.new("extra500/panel/CircuitBreaker/BankC/Start","Start",5),
	IGN		: CircuitBrakerClass.new("extra500/panel/CircuitBreaker/BankC/Ignition","Ignition",5),
	ENV_BLEED	: CircuitBrakerClass.new("extra500/panel/CircuitBreaker/BankC/EnvironmentalBleed","Environmental Bleed",5),
	FLAP_CTRL	: CircuitBrakerClass.new("extra500/panel/CircuitBreaker/BankC/FlapControl","Flap Control",5),
	FLAP		: CircuitBrakerClass.new("extra500/panel/CircuitBreaker/BankC/Flap","Flap",7.5),
	FUEL_FLOW	: CircuitBrakerClass.new("extra500/panel/CircuitBreaker/BankC/FuelFlow","Fuel Flow",1),
	ICE_LT		: CircuitBrakerClass.new("extra500/panel/CircuitBreaker/BankC/IceLight","Ice Light",7.5),
	STROBE_LT	: CircuitBrakerClass.new("extra500/panel/CircuitBreaker/BankC/StrobeLight","Strobe Light",7.5),
	INST_LT		: CircuitBrakerClass.new("extra500/panel/CircuitBreaker/BankC/InstrumentLight","Instrument Light",7.5),
	BOOTS		: CircuitBrakerClass.new("extra500/panel/CircuitBreaker/BankC/Boots","Boots",2),
	AP_SERVO	: CircuitBrakerClass.new("extra500/panel/CircuitBreaker/BankC/AutopilotServo","Autopilot Servo",5),
	IFD_LH_B	: CircuitBrakerClass.new("extra500/panel/CircuitBreaker/BankC/IFD-LH-B","IFD Left B",10),
	VNE_WARN	: CircuitBrakerClass.new("extra500/panel/CircuitBreaker/BankC/VneWarn","Vne Warn",1),
	AV_BUS		: CircuitBrakerClass.new("extra500/panel/CircuitBreaker/BankC/AvBus","AV Bus",30),
	EMGC_1		: CircuitBrakerClass.new("extra500/panel/CircuitBreaker/BankC/Emergency1","Emergency 1",30),
#emergency bus
	GEAR_WARN	: CircuitBrakerClass.new("extra500/panel/CircuitBreaker/BankD/GearWarn","Gear Warn",2),
	FUEL_P_1	: CircuitBrakerClass.new("extra500/panel/CircuitBreaker/BankD/FuelPump1","Fuel Pump 1",7.5),
	PITOT_L		: CircuitBrakerClass.new("extra500/panel/CircuitBreaker/BankD/PitotL","Pitot L",10),
	DIP_1		: CircuitBrakerClass.new("extra500/panel/CircuitBreaker/BankD/DIP1","DIP 1",1),
	ENG_INST_1	: CircuitBrakerClass.new("extra500/panel/CircuitBreaker/BankD/EngineInstrument1","Engine Instrument 1",2),
	C_PRESS		: CircuitBrakerClass.new("extra500/panel/CircuitBreaker/BankD/CabinPressure","Cabin Pressure",3),
	DUMP		: CircuitBrakerClass.new("extra500/panel/CircuitBreaker/BankD/Dump","Dump",2),
	FUEL_QTY	: CircuitBrakerClass.new("extra500/panel/CircuitBreaker/BankD/FuelQuantity","Fuel Quantity",2),
	LOW_VOLT	: CircuitBrakerClass.new("extra500/panel/CircuitBreaker/BankD/LowVolt","Low Volt",1),
	STALL_WARN	: CircuitBrakerClass.new("extra500/panel/CircuitBreaker/BankD/StallWarning","Stall Warning",1),
	VOLT_MON	: CircuitBrakerClass.new("extra500/panel/CircuitBreaker/BankD/VoltMonitor","Volt Monitor",1),
	LDG_LT		: CircuitBrakerClass.new("extra500/panel/CircuitBreaker/BankD/LandingLight","Landing Light",10),
	WARN_LT		: CircuitBrakerClass.new("extra500/panel/CircuitBreaker/BankD/WarnLight","Warn Light",7.5),
	GLARE_LT	: CircuitBrakerClass.new("extra500/panel/CircuitBreaker/BankD/GlareLight","Glare Light",1),
	INTAKE_AI	: CircuitBrakerClass.new("extra500/panel/CircuitBreaker/BankD/IntakeAI","Intake AI",2),
	STBY_GYRO	: CircuitBrakerClass.new("extra500/panel/CircuitBreaker/BankD/StandbyGyroskop","Standby Gyroskop",2),
	IFD_LH_A	: CircuitBrakerClass.new("extra500/panel/CircuitBreaker/BankD/IFD-LH-A","IFD Left A",10),
	KEYPAD		: CircuitBrakerClass.new("extra500/panel/CircuitBreaker/BankD/Keypad","Keypad",1),
	ATC		: CircuitBrakerClass.new("extra500/panel/CircuitBreaker/BankD/ATC","ATC",3),
	GEN_RESET	: CircuitBrakerClass.new("extra500/panel/CircuitBreaker/BankD/GeneratorReset","Generator Reset",5),
	ALT		: CircuitBrakerClass.new("extra500/panel/CircuitBreaker/BankD/Alt","Alt",2),
#hot bus
	GEAR_AUX_2	: CircuitBrakerClass.new("extra500/panel/CircuitBreaker/GearAux2","Gear Aux 2",5),
	EXT_LADER	: CircuitBrakerClass.new("extra500/panel/CircuitBreaker/EXT_LADER","EXT LADER",5),
	ALT_FIELD	: CircuitBrakerClass.new("extra500/panel/CircuitBreaker/ALT_FIELD","ALT FIELD",2),
	COURTESY_LT	: CircuitBrakerClass.new("extra500/panel/CircuitBreaker/COURTESY_LT","Courtesy Light",5),
	ELT		: CircuitBrakerClass.new("extra500/panel/CircuitBreaker/ELT","ELT",1),
#avionic bus
	IFD_RH_B	: CircuitBrakerClass.new("extra500/panel/CircuitBreaker/BankB/IFD-RH-B","IFD Right B",10),
	TAS		: CircuitBrakerClass.new("extra500/panel/CircuitBreaker/BankB/TAS","TAS",3),
	AP_CMPTR	: CircuitBrakerClass.new("extra500/panel/CircuitBreaker/BankB/AutopilotComputer","Autopilot Computer",5),
	TB		: CircuitBrakerClass.new("extra500/panel/CircuitBreaker/BankB/TurnCoordinator","Turn Coordinator",5),
#no Bus
	FLAP_UNB	: CircuitBrakerClass.new("extra500/panel/CircuitBreaker/BankC/FlapUNB","Flap UNB",1),
	RCCB		: CircuitBrakerClass.new("extra500/panel/CircuitBreaker/BankB/RCCB","RCCB",1),
	BUS_TIE		: CircuitBrakerClass.new("extra500/panel/CircuitBreaker/BankB/BusTie","Bus Tie",0),
	
};




### External Power K1 Relay MM Page 571
eSystem.relay.K1.checkCondition = func(){
	if ( 	(eSystem.switch.External._state == 1) 
		and (eSystem.relay.K3._state == 0 ) 
		and (eSystem.source.ExternalGenerator._isPluged == 1 )
	){
		me.setState(1);
	}else{
		me.setState(0);
		eSystem.source.ExternalGenerator.applyAmpere(eSystem._NullLoad);
	}

};
eSystem.relay.K1.setListeners = func() {
	append(me._listeners ,setlistener(me._nState,func(n){me._onStateChange(n);},1,0) );
	append(me._listeners ,setlistener(eSystem.source.ExternalGenerator._nIsPluged,func(){me.checkCondition();eSystem.checkSource();},1,0) );
};
	
eSystem.relay.K1._onStateChange = func(n){
	me._state = n.getValue();
	eSystem.relay.K5.checkCondition();
}


### Start Relay K2 MM Page 567, 569 
eSystem.relay.K2.checkCondition = func(){
	
};
eSystem.relay.K2._onStateChange = func(n){
	me._state = n.getValue();
	eSystem.relay.K5.checkCondition();
}

### Generator Relay K3 MM Page 567, 569
eSystem.relay.K3.checkCondition = func(){
	if ( (eSystem.switch.Generator._state == 1) and (eSystem.source.Generator._generating == 1) ){
		me.setState(1);
	}else{
		me.setState(0);
	}
	
};
eSystem.relay.K3.setListeners = func() {
	append(me._listeners ,setlistener(me._nState,func(n){me._onStateChange(n);},1,0) );
	append(me._listeners ,setlistener(eSystem.source.Generator._nGenerating,func(){me.checkCondition();eSystem.checkSource();},1,0) );
};
eSystem.relay.K3._onStateChange = func(n){
	me._state = n.getValue();
	eSystem.relay.K1.checkCondition();
	eSystem.relay.K5.checkCondition();
}

### Battery Relay K4 MM Page 567, 569
eSystem.relay.K4.checkCondition = func(){
	if ( (eSystem.switch.Battery._state == 1) and (eSystem.switch.Emergency._state==0) ){
		me.setState(1);
	}else{
		me.setState(0);
	}
	
};
eSystem.relay.K4._onStateChange = func(n){
	me._state = n.getValue();
	eSystem.relay.K5.checkCondition();
}


### RCCB Relay K5 MM Page 569
eSystem.relay.K5.checkCondition = func(){
	if ( 			
		(eSystem.circuitBreaker.RCCB._state == 1)
		and
		((eSystem.relay.K1._state == 1) or (eSystem.relay.K3._state == 1))
		and
		(eSystem.relay.K2._state == 0)
				
	){
		me.setState(1);
	}else{
		me.setState(0);
	}
	
};
eSystem.relay.K5._onStateChange = func(n){
	me._state = n.getValue();
}

### Alternator Relay K7 MM Page 569, 568
eSystem.relay.K7.checkCondition = func(){
	if ( (eSystem.switch.Alternator._state == 0) and (eSystem.circuitBreaker.ALT._volt >= 14.0) ){
		me.setState(1);
	}else{
		me.setState(0);
	}
	
};
eSystem.relay.K7._onStateChange = func(n){
	me._state = n.getValue();
	eSystem.source.Alternator.setOnline(!me._state);
}

### Alt Charge Relay K10 MM Page 569, 568
eSystem.relay.K10.checkCondition = func(){
	if ( (eSystem.switch.Emergency._state == 1)){
		me.setState(1);
	}else{
		me.setState(0);
	}
	
};
eSystem.relay.K10._onStateChange = func(n){
	me._state = n.getValue();
}


eSystem.source.Alternator._checkBusSource = func(){
	if (eSystem.switch.Alternator._state == 1){
		eSystem.circuitBreaker.ALT.outputAdd(eSystem.source.Alternator);
	}else{
		eSystem.circuitBreaker.ALT.outputRemove(eSystem.source.Alternator);
	}
};
	


### Circuit Breaker

eSystem.circuitBreaker.RCCB._onStateChange = func(n){
	me._state = n.getValue();
	eSystem.relay.K5.checkCondition();
	eSystem.checkSource();
};


### switches 

eSystem.switch.Battery.onStateChange = func(n){
	me._state = n.getValue();
# 	print("\nSwitch.onStateChange() ... "~me._name~" "~me._state~"\n");
	eSystem.source.Alternator._checkBusSource();
	eSystem.relay.K4.checkCondition();
	eSystem.checkSource();
	
};

eSystem.switch.Alternator.onStateChange = func(n){
	me._state = n.getValue();
# 	print("\nSwitch.onStateChange() ... "~me._name~" "~me._state~"\n");
	eSystem.source.Alternator._checkBusSource();
	eSystem.relay.K7.checkCondition();
	eSystem.checkSource();
};

eSystem.switch.Generator.onStateChange = func(n){
	me._state = n.getValue();
	#print("\nSwitch.onStateChange() ... "~me._name~" "~me._state~"\n");
	eSystem.relay.K3.checkCondition();
	eSystem.checkSource();
};

eSystem.switch.External.onStateChange = func(n){
	me._state = n.getValue();
	#print("\nSwitch.onStateChange() ... "~me._name~" "~me._state~"\n");
	eSystem.relay.K1.checkCondition();
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
	if (me._state == 1){
		eSystem.circuitBreaker.AV_BUS.outputAdd(eSystem._AvionicsBus);
	}else{
		eSystem.circuitBreaker.AV_BUS.outputRemove(eSystem._AvionicsBus);
	}
	
};

eSystem.switch.Emergency.onStateChange = func(n){
	me._state = n.getValue();
	#print("\nSwitch.onStateChange() ... "~me._name~" "~me._state~"\n");
	eSystem.relay.K10.checkCondition();
	eSystem.relay.K4.checkCondition();
	eSystem.checkSource();
};






