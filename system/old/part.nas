# extra500 global part classes




var ServiceAble = {
	new : func(nRoot){
		var m = {parents:[
			ServiceAble
		]};
		
		m.nService = nRoot.getNode("service",1);
		
		m.nQos  = m.nService.initNode("qos",1.0,"DOUBLE");
		m.nLifetime = m.nService.initNode("lifetime",72000000,"INT");
		m.nBuildin = m.nService.initNode("buildin",0,"INT");
		m.nSerialNumber = m.nService.initNode("SerialNumber","","STRING");
		m.qos = 0.99;
		return m;
	},
	serviceConfig : func(serialnumber,lifetime,buildin){
		me.nSerialNumber.setValue(serialnumber);
		me.nLifetime.setValue(lifetime);
		me.nBuildin.setValue(buildin);
	},
	calcQos : func(utcSec){
			used = utcSec - me.nBuildin.getValue();
			
			qos = 1.0 - (used / me.nLifetime.getValue());
			
			if (qos < 0.0){	qos = 0.0; }
			if (qos > 1.0){ qos = 1.0; }
			
			me.nQos.setValue(qos);
			me.qos = qos;
			
	},
};

var ElectricAble = {
	new : func(nRoot,name){
		var m = {parents:[
			ElectricAble
			
		]};
		
		m.nElectric = nRoot.getNode("electric",1);
		
		m.nAmpere = m.nElectric.initNode("ampere",0.0,"DOUBLE");
		m.nVolt = m.nElectric.initNode("volt",0.0,"DOUBLE");
		m.nMinVolt = m.nElectric.initNode("voltMin",18.0,"DOUBLE");
		m.nWatt = m.nElectric.initNode("watt",0.0001,"DOUBLE");
		m.isPowered = 0;
		m.volt = 0;
		m.minVolt = 18;
		m.ampere = 0;
		m.watt = 0.0001;
		
		return m;
	},
	electricConfig : func(minVolt,watt){
		me.minVolt = minVolt;
		me.watt = watt;
		me.nMinVolt.setValue(me.minVolt);
		me.nWatt.setValue(me.watt);		
	},
	setVolt : func(value){
		me.volt = value;
		me.nVolt.setValue(value);
	},
	setMinVolt : func(value){
		me.minVolt = value;
		me.nMinVolt.setValue(value);
	},
	setAmpere : func(value){
		me.ampere = value;
		me.nAmpere.setValue(value);
	},
	setWatt : func(value){
		me.watt = value;
		me.nWatt.setValue(value);
	},
	hasPower : func(volt=nil){
		if (volt!=nil){
			if (me.volt >= volt){
				me.isPowered = 1;
			}else{
				me.isPowered = 0;
			}
		}else{
			if (me.volt >= me.minVolt){
				me.isPowered = 1;
			}else{
				me.isPowered = 0;
			}
		}
		return me.isPowered;
	}
	
};

var ElectricInputAble = {
	new : func(nRoot,name){
		var m = {parents:[
			ElectricInputAble,
			ElectricAble.new(nRoot,name)
		]};
		m.mainBoardSource = nil;
		m.sourceSlot = 0;
		return m;
	},
	plugElectricSource : func(mainBoardOutputAble,slot=1){
		#debug.dump(mainBoardOutputAble);
		me.mainBoardSource = mainBoardOutputAble;
		me.sourceSlot = slot;
		#global.fnAnnounce("debug",""~me.name~"\t\tElectricInputAble.plugElectricSource() ... "~me.mainBoardSource.name);
		
	},
	electricWork : func() {
		var volt = 0.0;
		var ampere = 0.0;
				
		if (me.mainBoardSource != nil){
			
			volt = me.mainBoardSource.getVoltOutput(me.sourceSlot);
			if (me.hasPower()){
				ampere = me.watt / volt;
				#me.mainBoardSource.setAmpereOutput(ampere);
			}
		}
		
		me.setVolt(volt);
		me.setAmpere(ampere);
		
		#global.fnAnnounce("debug",""~me.name~"\t\tElectricInputAble.electricWork() ... "~volt~"V "~ampere~"A");
		
	},
	setAmpereUsage : func(){
		if (me.mainBoardSource != nil){
			me.mainBoardSource.setAmpereOutput(me.ampere);
		}
	}

};

var ElectricOutputAble = {
	new : func(nRoot,name){
		var m = {parents:[
			ElectricOutputAble,
			ElectricInputAble.new(nRoot,name)
		]};
		return m;
	},
	getVoltOutput : func(slot=1){
		var voltOutput = 0;
		me.electricWork();
		voltOutput = me.volt;
		#global.fnAnnounce("debug",""~me.name~"\t\tElectricOutputAble.getVoltOutput() ... "~voltOutput~"V");
		return voltOutput;
	},
	setAmpereOutput : func(ampere){
		if (me.mainBoardSource != nil){
			me.mainBoardSource.setAmpereOutput(ampere + me.ampere);
		}
	},
	
};
var Decider = {
	new : func(nRoot,name){
		var m = {parents:[
			Decider,
		]};
		return m;
	},
	ask : func(){
		return 0;
	}
}; 
var ElectricDecider = {
	new : func(nRoot,name){
		var m = {parents:[
			ElectricDecider,
			ElectricInputAble.new(nRoot,name)
		]};
		return m;
	},
	ask : func(){
		me.electricWork();
		return me.isPowered;
	}
};
var ElectricAskingOutputAble = {
	new : func(nRoot,name){
		var m = {parents:[
			ElectricAskingOutputAble,
			ElectricOutputAble.new(nRoot,name)
		]};
		m.oDecider = nil;
		return m;
	},
	setDecider : func(decider){
		me.oDecider = decider;
	},
	getVoltOutput : func(slot=1){
		var voltOutput = 0;
		if (me.oDecider != nil){
			if (me.oDecider.ask()){
				
				me.electricWork();
				voltOutput = me.volt;
			}
		}
		#global.fnAnnounce("debug","\t\t ElectricAskingOutputAble.getVoltOutput() ... "~voltOutput~"V");
		
		return voltOutput;
	},
	
};
var ElectricFuseAble = {
	new : func(nRoot,name){
		var m = {parents:[
			ElectricFuseAble
			
		]};
		
		m.nFuse = nRoot.getNode("fuse",1);
		
		m.ampereMax = 10.0;
		m.ampereUsed = 0.0;
		m.isFuseClosed = 1;
		m.nAmpereUsed = m.nFuse.initNode("ampereUsed",0.0,"DOUBLE");
		m.nAmpereMax = m.nFuse.initNode("ampereMax",m.ampereMax,"DOUBLE");
		m.nAmperePeak = m.nFuse.initNode("amperePeak",0.0,"DOUBLE");
		
		
		return m;
	},
	fuseAddAmpere : func(ampere){
		#global.fnAnnounce("debug",""~me.name~"\t\t ElectricFuseAble.fuseAddAmpere("~ampere~") ... ");
		
		me.ampereUsed += ampere;
		me.nAmpereUsed.setValue(me.ampereUsed);
		
		if (me.nAmperePeak.getValue() < me.ampereUsed){
			me.nAmperePeak.setValue(me.ampereUsed)
		}
		
		if (me.ampereUsed > me.ampereMax){
			me.isFuseClosed = 0;
		}
	},
	fuseConfig : func(ampereMax){
		me.ampereMax = ampereMax;
		me.nAmpereMax.setValue(me.ampereMax);
	},
	fuseReset : func(){
		#global.fnAnnounce("debug",""~me.name~"\t\t ElectricFuseAble.fuseReset() ... ");
		
		
		me.ampereUsed = 0.0;
		me.nAmpereUsed.setValue(me.ampereUsed);
	},
	fuseCheck : func(){
		return me.isFuseClosed;
	},
	fuseClose : func(){
		me.fuseReset();
		me.isFuseClosed = 1;
	},
	fuseOpen : func(){
		me.isFuseClosed = 0;
	}
	
	
};


var FlowAble = {
	new : func(nRoot){
		var m = {parents:[
			FlowAble
		]};
		
		m.nFlow = nRoot.getNode("flow",1);
		
		m.nFluid = m.nFlow.initNode("fluid","","STRING");
		m.nUnit = m.nFlow.initNode("unit","","STRING");
		m.nMax = m.nFlow.initNode("max",0.0,"DOUBLE");
		m.max = 0;
		return m;
	},
	flowConfig : func(fluid,max,unit="gal/sec"){
		me.nFluid.setValue(fluid);
		me.nUnit.setValue(unit);
		me.nMax.setValue(max);
		me.max = max;
	},
	flow : func(flow){
		return flow;
	},
};

########## part ##############################################################################
var aListElectricFuseAble = [];

var Part = {
	new : func(nRoot,name){
		var m = {parents:[
			Part,
			ServiceAble.new(nRoot)
		]};
		m.nRoot = nRoot;
		m.nRoot.initNode("name",name,"STRING");
		m.name = name;
		return m;
	},
};

##############################################################################################

var ElectricCircuitBraker = {
	new : func(nRoot,name,state=1){
		
		#nRoot = nRoot.initNode("switch");
		
		var m = {parents:[
			ElectricCircuitBraker,
			Part.new(nRoot,name),
			ElectricOutputAble.new(nRoot,name),
			ElectricFuseAble.new(nRoot,name),
		]};
		m.state = state;
		m.nState = nRoot.initNode("state",m.state,"BOOL");

		append(aListElectricFuseAble,m);
		return m;

	},
	setAmpereOutput : func(ampere){
		if (me.mainBoardSource != nil){
			ampere+=me.ampere;
			me.mainBoardSource.setAmpereOutput(ampere);
			me.fuseAddAmpere(ampere);
			if (!me.fuseCheck()){
				me._setValue(0);
			}
		}
	},
	getVoltOutput : func(slot=1){
		var voltOutput = 0;
		if (me.state == slot ){
			me.electricWork();
			if (me.fuseCheck()){
				voltOutput = me.volt * me.qos;
			}else{
				me._setValue(0);
			}
		}
		#global.fnAnnounce("debug",""~me.name~"\t\tElectricSwitch.getVoltOutput() ... "~voltOutput~"V");
		return voltOutput;
	},
	_setValue : func(value){
		me.state = value;
		me.nState.setValue(value);
		sound.click(2);
	},
	open : func(){
		me._setValue(0);
	},
	close : func(){
		me._setValue(1);
	},
	toggle : func(){
		me.state = me.nState.getValue();
		if (me.state){
			me._setValue(0);
		}else{
			me._setValue(1);
		}
		#global.fnAnnounce("debug",""~me.name~"\t\tElectricSwitch.toggle() ... "~me.nState.getValue());
	},
	
	
};




var ElectricSwitch = {
	new : func(nRoot,name){
		
		#nRoot = nRoot.initNode("switch");
		
		var m = {parents:[
			ElectricSwitch,
			Part.new(nRoot,name),
			ElectricOutputAble.new(nRoot,name)
		]};
		m.nState = nRoot.initNode("state",0,"BOOL");
		m.state = 0;
		return m;

	},
	setAlias:func(alias){
		me.nState.alias(alias);
	},
	getVoltOutput : func(slot=1){
		var voltOutput = 0;
		if (me.state == slot){
			me.electricWork();
			voltOutput = me.volt * me.qos;
		}
		#global.fnAnnounce("debug",""~me.name~"\t\tElectricSwitch.getVoltOutput() ... "~voltOutput~"V");
		return voltOutput;
	},
	_setValue : func(value){
		me.state = value;
		me.nState.setValue(value);
	},
	on : func(){
		me._setValue(1);
		sound.click(4);
	},
	off : func(){
		me._setValue(0);
		sound.click(4);
	},
	toggle : func(){
		me.state = me.nState.getValue();
		if (me.state){
			me._setValue(0);
		}else{
			me._setValue(1);
		}
		sound.click(4);
		#global.fnAnnounce("debug",""~me.name~"\t\tElectricSwitch.toggle() ... "~me.nState.getValue());
	},
	
	
};

var ElectricKnob = {
	new : func(nRoot,name,type="INT",min=nil,max=nil,step=nil,state=0){
				
		var m = {parents:[
			ElectricKnob,
			Part.new(nRoot,name),
			ElectricOutputAble.new(nRoot,name)
		]};
		m.state = state;
		m.min = min;
		m.max = max;
		m.step = step;
		
		m.nState = nRoot.initNode("state",m.state,type);
		return m;

	},
	_setValue : func(value){
		#global.fnAnnounce("debug",""~me.name~"\t\ElectricKnob._setValue("~value~") ... ");
		if (me.min != nil){
			if (value < me.min){
				value = me.min;
			}
		}
		if (me.max != nil){
			if (value > me.max){
				value = me.max;
			}
		}
		me.state = value;
		me.nState.setValue(me.state);
		
	},
	getVoltOutput : func(slot=1){
		var voltOutput = 0;
		if (m.state = slot){
			me.electricWork();
			voltOutput = me.volt * me.qos;
		}
		#global.fnAnnounce("debug",""~me.name~"\t\ElectricKnob.getVoltOutput() ... "~voltOutput~"V");
		return voltOutput;
	},
	adjust : func(value){
		var state = me.nState.getValue();
		
		me._setValue(state + value);
		sound.click(4);
	},
	setValue : func(value){
		me._setValue(value);
		sound.click(4);
	},
	left : func(){
		if (me.step != nil){
			var state = me.nState.getValue();
			me._setValue(state - me.step);
		}
		sound.click(4);
	},
	right : func(){
		#global.fnAnnounce("debug",""~me.name~"\t\ElectricKnob.right() ... ");
		if (me.step != nil){
			var state = me.nState.getValue();
			me._setValue(state + me.step);
		}
		sound.click(4);
	}
};

var ElectricRelais = {
	new : func(nRoot,name){
		
		var m = {parents:[
			ElectricRelais,
			Part.new(nRoot,name),
			ElectricDecider.new(nRoot,name),
		]};
		var nNode = nil;
		nNode = nRoot.initNode("connector");
		m.oLeft = ElectricAskingOutputAble.new(nNode,name);
		nNode = nRoot.initNode("connector");
		m.oRight = ElectricAskingOutputAble.new(nNode,name);
		
		return m;

	},
	update : func(){
			me.electricWork();
			if (me.hasPower()){
				me.setAmpereUsage();
			}
	},
	plugLeftElectricSource : func(oSource){
		me.oLeft.setDecider(me);
		me.oLeft.plugElectricSource(oSource);
		
	},
	plugRightElectricSource : func(oSource){
		me.oRight.setDecider(me);
		me.oRight.plugElectricSource(oSource);
	},
	
	
};

var ElectricBusTie = {
	new : func(nRoot,name){
		
		var m = {parents:[
			ElectricBusTie,
			Part.new(nRoot,name),
			Decider.new(nRoot,name)
		]};
		var nNode = nil;
		nNode = nRoot.initNode("connector");
		m.oLeft = ElectricAskingOutputAble.new(nNode,name);
		nNode = nRoot.initNode("connector");
		m.oRight = ElectricAskingOutputAble.new(nNode,name);
		
		m.nState = nRoot.initNode("state",0,"BOOL");
		m.state = 0;
		return m;

	},
	plugElectricSource : func(left,right){
		me.oLeft.setDecider(me);
		me.oLeft.plugElectricSource(left);
		
		me.oRight.setDecider(me);
		me.oRight.plugElectricSource(right);	
	},
	ask : func(){
		return me.state;
	},
	_setValue : func(value){
		me.state = value;
		me.nState.setValue(value);
		me.oLeft._setValue(value);
		me.oRight._setValue(value);
		
	},
	open : func(){
		me._setValue(1);
		sound.click(2);
	},
	close : func(){
		me._setValue(0);
		sound.click(2);
	},
	toggle : func(){
		me.state = me.nState.getValue();
		if (me.state){
			me._setValue(0);
		}else{
			me._setValue(1);
		}
		sound.click(2);
		#global.fnAnnounce("debug",""~me.name~"\t\tElectricSwitch.toggle() ... "~me.nState.getValue());
	},

};

var ElectricBattery = {
	new : func(nRoot,name){
				
		var m = {parents:[
			ElectricBattery,
			Part.new(nRoot,name),
			ElectricOutputAble.new(nRoot,name)
		]};
		
		m.capacityAs = 230400.0;
		m.usedAs = 0.0;
		m.loadLevel = 1.0;
		m.nCapacityAs = nRoot.initNode("capacityAs",m.capacityAs,"DOUBLE");
		m.nUsedAs = nRoot.initNode("usedAs",0.0,"DOUBLE");
		m.nLoadLevel = nRoot.initNode("loadLevel",m.loadLevel,"DOUBLE");
		m.simTime = systime();
		return m;

	},
	getVoltOutput : func(slot=1){
		var voltOutput = 0;
		voltOutput = me.volt * me.qos;
		#global.fnAnnounce("debug",""~me.name~"\t\t ElectricBattery.getVoltOutput() ... "~voltOutput~"V");
		return voltOutput;
	},
	setAmpereOutput : func(ampere){
		#global.fnAnnounce("debug",""~me.name~"\t\t ElectricBattery.setAmpereOutput("~ampere~"A) ... ");
		
		var simNow = systime();
		
		#ampere += me.ampere;
		me.setAmpere(ampere);
		
		
		var simElapsed = simNow - me.simTime;
		
		var usedAs = ampere / simElapsed;
		
		me.usedAs += usedAs;
				
		me.loadLevel = (me.capacityAs - me.usedAs) / me.capacityAs;
		
		me.nUsedAs.setValue(me.usedAs);
		me.nLoadLevel.setValue(me.loadLevel);
		
	},
};

var ElectricBus = {
	new : func(nRoot,name){
				
		var m = {parents:[
			ElectricBus,
			Part.new(nRoot,name),
			ElectricOutputAble.new(nRoot,name)
		]};
		return m;

	},
# 	getVoltOutput : func(){
# 		var voltOutput = 0;
# 		voltOutput = me.volt * me.qos;
# 		global.fnAnnounce("debug",""~me.name~"\t\t ElectricBus.getVoltOutput() ... "~voltOutput~"V");
# 		return voltOutput;
# 	},
# 	setAmpereOutput : func(ampere){
# 		#global.fnAnnounce("debug",""~me.name~"\t\t ElectricBus.setAmpereOutput("~ampere~"A) ... ");
# 		
# 		if (me.mainBoardSource != nil){
# 			me.mainBoardSource.setAmpereOutput(ampere);
# 		}
# 		
# 		ampere += me.ampere;
# 		
# 		me.setAmpere(ampere);
# 	},
	
};



var ElectricPump = {
	new : func(nRoot,name){
		var m = {parents:[
			ElectricPump,
			Part.new(nRoot,name),
			ElectricInputAble.new(nRoot,name),
			FlowAble.new(nRoot)
		]};

		return m;

	},
	flow : func(flow){
		me.electricWork();
		if (me.hasPower()){
			flow = flow * me.qos;
			if (flow > me.max) { flow = me.max; }
			if (flow < 0) { flow = 0; }
			
			me.setAmpereUsage();
		}else{
			flow = 0;
		}
		
		return flow;
	},
};

var Filter = {
	new : func(nRoot,name){
		var m = {parents:[
			Filter,
			Part.new(nRoot,name),
			FlowAble.new(nRoot)
		]};
		return m;
	},
	flow : func(flow){
		flow = flow * me.qos;
		if (flow > me.max) { flow = me.max; }
		if (flow < 0) { flow = 0; }
		return flow;
	},
};

var SelectorValve = {
	new : func(nRoot,name){
		var m = {parents:[
			SelectorValve,
			Part.new(nRoot,name),
			FlowAble.new(nRoot)
		]};
		m.nState = nRoot.initNode("state",0,"INT");
		m.state = 2;# Selector valve 0/1/2/3 = off/left/both/right
		return m;
	},
	setValue : func(state){
		if (state < 0){	state = 0;}
		if (state > 3){	state = 3;}
		me.state = state;
		me.nState.setValue(state);
	},
	flow : func(flow){
		flow = flow * me.qos;
		if (flow > me.max) { flow = me.max; }
		if (flow < 0) { flow = 0; }
		return flow;
	},
	left : func(){
		me.setValue(me.state -1);
	},
	right : func(){
		me.setValue(me.state +1);
	}
	
};




