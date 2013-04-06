
var ElectricConnector = {
	new : func(name){
				
		var m = {parents:[
			ElectricConnector
		]};
		m.electricAble 	= nil;
		m.name 		= name;	
		m.connector 	= nil;
		return m;

	},
	solder : func(electricAble){
		me.electricAble = electricAble;
	},
	plug : func(connector){
		me.connector = connector;
	},
	applyVoltage : func(volt,name=""){ 
		print("ElectricConnector["~me.name~"].applyVoltage("~volt~","~name~") ...");
		if (me.connector != nil){
			var ampere = 0;
			ampere = me.connector.applyInputVoltage(volt);
			print("\t"~me.name~" "~ampere~"A");
			return ampere;
		}else{
			print("no connector");
		}
		return 0;
	},
	applyInputVoltage : func(volt){ 
		print("ElectricConnector["~me.name~"].applyInputVoltage("~volt~") ...");
		if (me.electricAble != nil){
			var ampere = 0;
			ampere =  me.electricAble.applyVoltage(volt,me.name);
			print("\t"~me.name~" "~ampere~"A");
			return ampere;
		}else{
			print("no electricAble");
		}
		return 0;
	}
};

var ElectricBus = {
	new : func(name){		
		var m = {parents:[
			ElectricBus
		]};
		m.name = name;
		m.connectors = {};
		return m;
	},
	plug : func(connector,name="default"){
		if (name == "default"){
			name = me.name~"-"~size(me.connectors);
		}
		me.connectors[name] = ElectricConnector.new(name);
		me.connectors[name].solder(me);
		me.connectors[name].plug(connector);
		connector.plug(me.connectors[name]);
	},
	applyVoltage : func(volt,name=""){ 
		print("ElectricBus["~me.name~"].applyVoltage("~volt~","~name~") ...");
		var ampere = 0;
		var ampereSum = 0;
		foreach(var i;keys(me.connectors)) {
			if (i != name){
				ampere = me.connectors[i].applyVoltage(volt);
				print("\t"~me.name~" "~ampere~"A");
				ampereSum += ampere;
			}
		}
		print("ElectricBus["~me.name~"].applyVoltage("~volt~","~name~") ... return "~ampereSum~"A");
		return ampereSum;
	}
};
 
 var ElectricBattery = {
	new : func(nRoot,name){
				
		var m = {parents:[
			ElectricBattery,
			Part.new(nRoot,name),
			ElectricAble.new(nRoot,name)
		]};
		
		m.capacityAs = 230400.0;
		m.usedAs = 0.0;
		m.loadLevel = 1.0;
		m.nCapacityAs = nRoot.initNode("capacityAs",m.capacityAs,"DOUBLE");
		m.nUsedAs = nRoot.initNode("usedAs",0.0,"DOUBLE");
		m.nLoadLevel = nRoot.initNode("loadLevel",m.loadLevel,"DOUBLE");
		m.simTime = systime();
		
		m.plus = ElectricConnector.new("+");
		m.minus = ElectricConnector.new("-");
		
		m.plus.solder(m);
		m.minus.solder(m);
		return m;

	},
	applyVoltage : func(volt,name=""){ 
		if (name == "+"){
			return 1.0;
		}
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
	update : func(){
		print("ElectricBattery.update() ...");
		var ampere = 0;
		ampere = me.plus.applyVoltage(me.volt);
		if (ampere > 0){
			me.setAmpereOutput(ampere);
		}
	}
};

var ElectricSwitch2P = {
	new : func(nRoot,name){
		
		#nRoot = nRoot.initNode("switch");
		
		var m = {parents:[
			ElectricSwitch2P,
			Part.new(nRoot,name),
			ElectricAble.new(nRoot,name)
		]};
		m.nState = nRoot.initNode("state",0,"BOOL");
		m.state = 0;
		
		m.In = ElectricConnector.new("in");
		m.On = ElectricConnector.new("on");
		m.Off = ElectricConnector.new("off");
		
		m.In.solder(m);
		m.On.solder(m);
		m.Off.solder(m);
		
		return m;

	},
	setAlias:func(alias){
		me.nState.alias(alias);
	},
	applyVoltage : func(volt,name=""){ 
		volt *= me.qos;
		if (me.state){
			if (name == "on"){
				return me.In.applyVoltage(volt);
			}else if(name == "in"){
				return me.On.applyVoltage(volt);
			}
		}else{
			if (name == "off"){
				return me.In.applyVoltage(volt);
			}else if(name == "in"){
				return me.On.applyVoltage(volt);
			}
		}
		return 0;
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

var ElectricSwitch3P = {
	new : func(nRoot,name,state=0){
		
		#nRoot = nRoot.initNode("switch");
		
		var m = {parents:[
			ElectricSwitch3P,
			Part.new(nRoot,name),
			ElectricAble.new(nRoot,name)
		]};
		m.state = state;
		m.nState = nRoot.initNode("state",state,"INT");
		m.min = -1;
		m.max = 1;
		m.step = 1;
		
		m.In = ElectricConnector.new("in");
		m.High = ElectricConnector.new("high");
		m.Mid = ElectricConnector.new("mid");
		m.Low = ElectricConnector.new("low");
		
		m.In.solder(m);
		m.High.solder(m);
		m.Mid.solder(m);
		m.Low.solder(m);
		
		return m;

	},
	setAlias:func(alias){
		me.nState.alias(alias);
	},
	applyVoltage : func(volt,name=""){ 
		volt *= me.qos;
		if (me.state == 1){
			if (name == "high"){
				return me.In.applyVoltage(volt);
			}else if(name == "in"){
				return me.High.applyVoltage(volt);
			}
		}else if(me.state == 0){
			if (name == "mid"){
				return me.In.applyVoltage(volt);
			}else if(name == "in"){
				return me.Mid.applyVoltage(volt);
			}
		}else if(me.state == -1){
			if (name == "low"){
				return me.In.applyVoltage(volt);
			}else if(name == "in"){
				return me.Low.applyVoltage(volt);
			}
		}
		return 0;
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

var ElectricDimmer = {
	new : func(nRoot,name,type="DOUBLE",min=0.0,max=1.0,step=0.05,state=0.0){
				
		var m = {parents:[
			ElectricDimmer,
			Part.new(nRoot,name),
			ElectricAble.new(nRoot,name)
		]};
		m.state = state;
		m.min = min;
		m.max = max;
		m.step = step;
		
		m.nState = nRoot.initNode("state",m.state,type);
		
		m.In = ElectricConnector.new("in");
		m.Out = ElectricConnector.new("out");
			
		m.In.solder(m);
		m.Out.solder(m);
				
		return m;

	},
	applyVoltage : func(volt,name=""){
		volt *= me.state * me.qos;
		if (name == "in"){
			return me.Out.applyVoltage(volt);
		}else{
			return me.In.applyVoltage(volt);
		}
		return 0;
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

var ElectricCircuitBraker = {
	new : func(nRoot,name,state=1){
		
		#nRoot = nRoot.initNode("switch");
		
		var m = {parents:[
			ElectricCircuitBraker,
			Part.new(nRoot,name),
			ElectricAble.new(nRoot,name)
		]};
		m.state = state;
		m.nState = nRoot.initNode("state",m.state,"BOOL");
		
		m.In = ElectricConnector.new("in");
		m.Out = ElectricConnector.new("out");
			
		m.In.solder(m);
		m.Out.solder(m);
		
		#append(aListElectricFuseAble,m);
		return m;

	},
	applyVoltage : func(volt,name=""){
		if (me.state){
			volt *= me.qos;
			if (name == "in"){
				return me.Out.applyVoltage(volt);
			}else{
				return me.In.applyVoltage(volt);
			}
		}
		return 0;
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

var ElectricRelais = {
	new : func(nRoot,name,state=0){
		
		#nRoot = nRoot.initNode("switch");
		
		var m = {parents:[
			ElectricCircuitBraker,
			Part.new(nRoot,name),
			ElectricAble.new(nRoot,name)
		]};
		m.state = state;
		m.nState = nRoot.initNode("state",m.state,"BOOL");
		
		m.Plus = ElectricConnector.new("+");
		m.Minus = ElectricConnector.new("-");
		
		m.In = ElectricConnector.new("in");
		m.Out = ElectricConnector.new("out");
			
		
		
		m.Plus.solder(m);
		m.Minus.solder(m);
		
		m.In.solder(m);
		m.Out.solder(m);
		
		#append(aListElectricFuseAble,m);
		return m;

	},
	applyVoltage : func(volt,name=""){
		if (me.state){
			volt *= me.qos;
			if (name == "in"){
				return me.Out.applyVoltage(volt);
			}else if (name == "out"){
				return me.In.applyVoltage(volt);
			}
		}
		
		if (name == "+"){
			var ampere = 0;
			ampere = me.In.applyVoltage(volt);
			if (ampere > 0){
				_setValue(1);
			}else{
				_setValue(0);
			}
			return ampere;
		}
		return 0;
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

