
var ElectricTreeDebugger = {
	new : func(){
				
		var m = {parents:[
			ElectricTreeDebugger
		]};
		m.depth 	= 0;
		m.defaultStr 	= "                                       ";
		m.debugLevel	=0;
		return m;

	},
	in : func(type,name,connector,volt,icon="└┬"){
		if (me.debugLevel > 0){
			var space = substr(me.defaultStr,0,me.depth);
			var output = sprintf("%s %s %s %s %s %.4fV",space,icon,type,name,connector,volt);
			print(output);
			me.depth += 1;
		}
		
	},
	out : func(type,name,connector,volt,ampere,icon="┌┴"){
		if (me.debugLevel > 0){
			var space = substr(me.defaultStr,0,me.depth);
			var output = sprintf("%s%s %s %s %s %.4fV %.4fA",space,icon,type,name,connector,volt,ampere);
			print(output);
			me.depth -= 1;
		}

	},
	echo : func(msg,icon="**"){
		if (me.debugLevel > 0){
			var space = substr(me.defaultStr,0,me.depth);
			var output = sprintf("%s%s %s",space,icon,msg);
			print(output);
		}
	}
		
};

var etd = ElectricTreeDebugger.new();

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
		connector.connector = me;
	},
	applyVoltage : func(volt,name=""){ 
		etd.in("Connector",me.name,name,volt);
		var ampere = 0;
		if ( volt > 0){
			if (me.connector != nil){
				ampere = me.connector.applyInputVoltage(volt);
			}else{
				etd.echo("ElectricConnector.applyVoltage() ... no connector");
			}
		}
		etd.out("Connector",me.name,name,volt,ampere);
		return ampere;
	},
	applyInputVoltage : func(volt){ 
		etd.in("Connector",me.name,"input",volt);
		var ampere = 0;
		if ( volt > 0){
			if (me.electricAble != nil){
				var ampere = 0;
				ampere =  me.electricAble.applyVoltage(volt,me.name);
			}else{
				etd.echo("ElectricConnector.applyInputVoltage() ... no electricAble");
			}
		}
		etd.out("Connector",me.name,"input",volt,ampere);
		return ampere;
	}
};

var ElectricDiode = {
	new : func(nRoot,name){
				
		var m = {parents:[
			ElectricDiode,
			#Part.new(nRoot,name),
			#ElectricAble.new(nRoot,name)
		]};
								
		m.Plus = ElectricConnector.new("+");
		m.Minus = ElectricConnector.new("-");
						
		m.Plus.solder(m);
		m.Minus.solder(m);
		return m;

	},
	applyVoltage : func(volt,name=""){ 
		etd.in("Diode",me.name,name,volt);
		var ampere = 0;
		if ( volt > 0){
			if (name == "+"){
				ampere = me.Minus.applyVoltage(volt);
			}
		}
		etd.out("Diode",me.name,name,volt,ampere);
		return ampere;
	},
	
	
};

var ElectricShunt = {
	new : func(nRoot,name){
				
		var m = {parents:[
			ElectricShunt,
			Part.new(nRoot,name),
			SimStateAble.new(nRoot,"DOUBLE",0.0),
			ElectricAble.new(nRoot,name)
		]};
		
		#m.ampereUsed = 0.0;
		m.ampereIndicated = 0.0;
		m.voltIndicated = 0.0;
		
		#m.nAmpereUsed = m.nFuse.initNode("ampereUsed",m.ampereUsed,"DOUBLE");
		m.nAmpereIndicated = nRoot.initNode("ampereIndicated",0.0,"DOUBLE");
		m.nVoltIndicated = nRoot.initNode("voltIndicated",0.0,"DOUBLE");
		
		
		m.Plus = ElectricConnector.new("+");
		m.Minus = ElectricConnector.new("-");
		
		m.Plus.solder(m);
		m.Minus.solder(m);
		
		append(aListSimStateAble,m);
		
		return m;

	},
	applyVoltage : func(volt,name=""){ 
		etd.in("Shunt",me.name,name,volt);
		var ampere = 0;
		me.setVolt(volt);
		me.voltIndicated = volt;
		if ( volt > 0){
			if (name == "+"){
				ampere += me.Minus.applyVoltage(volt);
				me.ampereIndicated = -ampere;
				me.voltIndicated = -volt;
				
			}else if(name == "-"){
				ampere += me.Plus.applyVoltage(volt);
				me.ampereIndicated = ampere;
				me.voltIndicated = volt;
			}
		}
		me.setAmpere(ampere);
		
		etd.out("Shunt",me.name,name,volt,ampere);
		return ampere;
	},
	simUpdate : func(){
		me.nState.setValue(me.state);
		me.nAmpereIndicated.setValue(me.ampereIndicated);
		me.nVoltIndicated.setValue(me.voltIndicated);
	},
	simReset : func(){
		me.nAmpereIndicated.setValue(me.ampereIndicated);
		me.nVoltIndicated.setValue(me.voltIndicated);
		me.nState.setValue(me.state);
		
		me.state = me.default;
		me.voltIndicated = 0.0;
		me.ampereIndicated = 0.0;
	},
	
	
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
		etd.in("Bus",me.name,name,volt);
		var ampere = 0;
		var ampereSum = 0;
		if ( volt > 0){
			foreach(var i;keys(me.connectors)) {
				if (i != name){
					ampere = me.connectors[i].applyVoltage(volt);
					ampereSum += ampere;
				}
			}
		}
		etd.out("Bus",me.name,name,volt,ampere);
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
		etd.echo("Battery.update() ...");
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
			#ElectricAble.new(nRoot,name)
		]};
		m.state = 0;
		m.In = ElectricConnector.new("in");
		m.On = ElectricConnector.new("on");
		m.Off = ElectricConnector.new("off");
		
		m.nState = nRoot.initNode("state",m.state,"BOOL");
		
		
		
		m.In.solder(m);
		m.On.solder(m);
		m.Off.solder(m);
		
		return m;

	},
	setAlias:func(alias){
		me.nState.alias(alias);
	},
	applyVoltage : func(volt,name=""){ 
		etd.in("Switch2P",me.name,name,volt);
		var ampere = 0;
		volt *= me.qos ;
		if ( volt > 0){
			if (name == "in"){
				if (me.state){
					ampere = me.On.applyVoltage(volt);
				}else{
					ampere = me.Off.applyVoltage(volt);
				}
			}else if (name == "on"){
				if (me.state){
					ampere = me.In.applyVoltage(volt);
				}
			}else if (name == "off"){
				if (!me.state){
					ampere = me.In.applyVoltage(volt);
				}
			}
		}
		etd.out("Switch2P",me.name,name,volt,ampere);
		return ampere;
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
			#ElectricAble.new(nRoot,name)
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
		etd.in("Switch3P",me.name,name,volt);
		var ampere = 0;
		volt *= me.qos;
		if ( volt > 0){
			if (name == "in"){
				if (me.state == 1){
					ampere = me.High.applyVoltage(volt);
				}else if(me.state == 0){
					ampere = me.Mid.applyVoltage(volt);
				}else if(me.state == -1){
					ampere = me.Low.applyVoltage(volt);
				}
			}else{
				ampere = me.In.applyVoltage(volt);
			}
		}
		etd.out("Switch3P",me.name,name,volt,ampere);
		return ampere;
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
		etd.in("Dimmer",me.name,name,volt);
		var ampere = 0;
		volt *= me.state * me.qos;
		if ( volt > 0){
			if (name == "in"){
				ampere =  me.Out.applyVoltage(volt);
				if (ampere){
					ampere += me.electricWork(volt);
				}
			}else{
				ampere =  me.In.applyVoltage(volt);
				if (ampere){
					ampere += me.electricWork(volt);
				}
			}
		}
		etd.out("Switch2P",me.name,name,volt,ampere);
		return ampere;
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
			SimStateAble.new(nRoot,"BOOL",state),
			ElectricAble.new(nRoot,name),
			ElectricFuseAble.new(nRoot,name)
			
		]};
		
		m.In = ElectricConnector.new("in");
		m.Out = ElectricConnector.new("out");
			
		m.In.solder(m);
		m.Out.solder(m);
		
		append(aListElectricFuseAble,m);
		
		return m;

	},
	applyVoltage : func(volt,name=""){
		etd.in("CircuitBraker",me.name,name,volt);
		var ampere = 0;
		if ( volt > 0){
			if (me.state){
				volt *= me.qos;
				if (name == "in"){
					ampere = me.Out.applyVoltage(volt);
					if (ampere){
						ampere += me.electricWork(volt);
						me.fuseAddAmpere(ampere);
					}
				}else{
					ampere = me.In.applyVoltage(volt);
					if (ampere){
						ampere += me.electricWork(volt);
						me.fuseAddAmpere(ampere);
					}
				}
			}
		}
		etd.out("CircuitBraker",me.name,name,volt,ampere);
		return ampere;
	},
	_setValue : func(value){
		me.state = value;
		me.simUpdate();
	},
	open : func(){
		me._setValue(0);
		sound.click(2);
	},
	close : func(){
		me.fuseReset();
		me._setValue(1);
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

var ElectricRelais = {
	new : func(nRoot,name,state=0){
		
		#nRoot = nRoot.initNode("switch");
		
		var m = {parents:[
			ElectricRelais,
			Part.new(nRoot,name),
			SimStateAble.new(nRoot,"BOOL",state),
			ElectricAble.new(nRoot,name)
		]};
		
		m.Plus = ElectricConnector.new("+");
		m.Minus = ElectricConnector.new("-");
		
		m.In = ElectricConnector.new("in");
		m.Out = ElectricConnector.new("out");
			
		
		
		m.Plus.solder(m);
		m.Minus.solder(m);
		
		m.In.solder(m);
		m.Out.solder(m);
		
		append(aListSimStateAble,m);
		return m;

	},
	applyVoltage : func(volt,name=""){
		etd.in("Relais",me.name,name,volt);
		var ampere = 0;
		volt *= me.qos;
		if(volt > 0){
			if (me.state){
				if (name == "in"){
					ampere = me.Out.applyVoltage(volt);
				}else if (name == "out"){
					ampere = me.In.applyVoltage(volt);
				}
			}
			
			if (name == "+"){
				ampere = me.Minus.applyVoltage(volt);
				if (ampere > 0 ){
					ampere += me.electricWork(volt);
					me._setValue(1);
				}else{
					me._setValue(0);
				}
			}
		}
		etd.out("Relais",me.name,name,volt,ampere);
		return ampere;
	},
	_setValue : func(value){
		me.state = value;
	},
	open : func(){
		me._setValue(0);
		sound.click(2);
	},
	close : func(){
		me._setValue(1);
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

var ElectricLight = {
	new : func(nRoot,name){
				
		var m = {parents:[
			ElectricLight,
			Part.new(nRoot,name),
			SimStateAble.new(nRoot,"DOUBLE",0.0),
			ElectricAble.new(nRoot,name)
		]};
		
						
		m.Plus = ElectricConnector.new("+");
		m.Minus = ElectricConnector.new("-");
						
		m.Plus.solder(m);
		m.Minus.solder(m);
		
		append(aListSimStateAble,m);
		
		return m;

	},
	applyVoltage : func(volt,name=""){ 
		etd.in("Light",me.name,name,volt);
		var ampere = 0;
		volt *= me.qos;
		me.setVolt(volt);
		
		if (name == "+"){
			ampere = me.Minus.applyVoltage(volt);
			if (ampere){
				ampere += me.electricWork(volt);
				me._dimm(volt);
			}
		}
		
		me.setAmpere(ampere);
		etd.out("Light",me.name,name,volt,ampere);
		return ampere;
	},
	_setValue : func(value){
		
		if (value > 1.0) { value = 1.0 };
		if (value < 0.0) { value = 0.0 };
		
		me.state = value;
	},
	_dimm : func(volt){
		
		var percentage = (volt - me.minVolt)  / (me.maxVolt - me.minVolt);
		me._setValue(percentage);
		
	},
	
};



