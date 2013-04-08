

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
	in : func(type,name,connector,electron,icon="└┬"){
		if (me.debugLevel > 0){
			var space = substr(me.defaultStr,0,me.depth);
			var output = sprintf("%s %s %s %s %s %s",space,icon,type,name,connector,electron.getText());
			print(output);
			me.depth += 1;
		}
		
	},
	out : func(type,name,connector,electron,icon="┌┴"){
		if (me.debugLevel > 0){
			var space = substr(me.defaultStr,0,me.depth);
			var output = sprintf("%s%s %s %s %s %s",space,icon,type,name,connector,electron.getText());
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

var Electron ={
	new : func(){
		var m = {parents:[
			Electron
		]};
		m.volt		= 0.0;
		m.resistor	= 0.0;
		m.ampere	= 0.0;
		return m;
	},
	getText : func(){
		return sprintf("%0.4fV %0.4fO %0.4fA",me.volt,me.resistor,me.ampere);
	}
};



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
	applyVoltage : func(electron,name=""){ 
		etd.in("Connector",me.name,name,electron);
		var GND = 0;
		if ( electron != nil){
			if (me.connector != nil){
				GND = me.connector.applyInputVoltage(electron);
			}else{
				etd.echo("ElectricConnector.applyVoltage() ... no connector");
			}
		}else{
			etd.echo("ElectricConnector.applyInputVoltage() ... no electron");
		}
		etd.out("Connector",me.name,name,electron);
		return GND;
	},
	applyInputVoltage : func(electron){ 
		etd.in("Connector",me.name,"input",electron);
		var GND = 0;
		if ( electron != nil){
			if (me.electricAble != nil){
				GND =  me.electricAble.applyVoltage(electron,me.name);
			}else{
				etd.echo("ElectricConnector.applyInputVoltage() ... no electricAble");
			}
		}else{
			etd.echo("ElectricConnector.applyInputVoltage() ... no electron");
		}
		etd.out("Connector",me.name,"input",electron);
		return GND;
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
	applyVoltage : func(electron,name=""){ 
		etd.in("Diode",me.name,name,electron);
		var GND = 0;
		if ( electron > 0){
			if (name == "+"){
				GND = me.Minus.applyVoltage(electron);
			}
		}
		etd.out("Diode",me.name,name,electron);
		return GND;
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
	applyVoltage : func(electron,name=""){ 
		etd.in("Shunt",me.name,name,electron);
		var GND = 0;
		me.setVolt(electron.volt);
		me.voltIndicated = electron.volt;
		
		if ( electron != nil){
			if (name == "+"){
				GND = me.Minus.applyVoltage(electron);
				me.ampereIndicated = -electron.ampere;
				me.voltIndicated = -electron.volt;
				
			}else if(name == "-"){
				GND = me.Plus.applyVoltage(electron);
				me.ampereIndicated = electron.ampere;
				me.voltIndicated = electron.volt;
			}
		}
		me.setAmpere(electron.ampere);
		
		etd.out("Shunt",me.name,name,electron);
		return GND;
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
	applyVoltage : func(electron,name=""){ 
		etd.in("Bus",me.name,name,electron);
		var GND = 0;
		var ampereSum = 0;
		if ( electron != nil){
			var electronTmp = electron;
			
			foreach(var i;keys(me.connectors)) {
				var electronBus = electron;
				if (i != name){
					GND = me.connectors[i].applyVoltage(electronBus);
					if (GND){
						electronTmp.ampere += electronBus.ampere;
					}
				}
			}
			
			electronTmp.resirstor = electronTmp.volt / electronTmp.ampere;
			
		}
		etd.out("Bus",me.name,name,electron);
		return GND;
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
		
		m.electron = Electron.new();
		
		m.plus = ElectricConnector.new("+");
		m.minus = ElectricConnector.new("-");
		
		m.plus.solder(m);
		m.minus.solder(m);
		return m;

	},
	applyVoltage : func(electron,name=""){ 
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
		
		me.electron.volt = 24.0;
		me.electron.resistor = 0.0;
		me.electron.ampere = 0.0;
		
		
		var GND = 0;
		GND = me.plus.applyVoltage(me.electron);
		if (GND > 0){
			me.setAmpereOutput(me.electron.ampere);
		}
	},
	test_consumer : func(electron){
		electron.resistor += 100.0;
		print(electron.getText());
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
	applyVoltage : func(electron,name=""){ 
		etd.in("Switch2P",me.name,name,electron);
		var GND = 0;
		#electron.resistor += me.qos  ;
		if ( electron != nil){
			if (name == "in"){
				if (me.state){
					GND = me.On.applyVoltage(electron);
				}else{
					GND = me.Off.applyVoltage(electron);
				}
			}else if (name == "on"){
				if (me.state){
					GND = me.In.applyVoltage(electron);
				}
			}else if (name == "off"){
				if (!me.state){
					GND = me.In.applyVoltage(electron);
				}
			}
		}
		etd.out("Switch2P",me.name,name,electron);
		return GND;
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
	applyVoltage : func(electron,name=""){ 
		etd.in("Switch3P",me.name,name,electron);
		var GND = 0;
		#electron.resistor *= me.qos;
		if ( electron != nil){
			if (name == "in"){
				if (me.state == 1){
					GND = me.High.applyVoltage(electron);
				}else if(me.state == 0){
					GND = me.Mid.applyVoltage(electron);
				}else if(me.state == -1){
					GND = me.Low.applyVoltage(electron);
				}
			}else{
				GND = me.In.applyVoltage(electron);
			}
		}
		etd.out("Switch3P",me.name,name,electron);
		return GND;
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
	applyVoltage : func(electron,name=""){
		etd.in("Dimmer",me.name,name,electron);
		var GND = 0;
		if ( electron > 0){
			electron.resistor += me.resistor * (1.0-me.state) * me.qos;
			if (name == "in"){
				GND =  me.Out.applyVoltage(electron);
			}else{
				GND =  me.In.applyVoltage(electron);
			}
		}
		etd.out("Switch2P",me.name,name,electron);
		return GND;
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
	applyVoltage : func(electron,name=""){
		etd.in("CircuitBraker",me.name,name,electron);
		var GND = 0;
		if ( electron != nil){
			#electron.resistor += me.qos;
			if (me.state){
				
				if (name == "in"){
					GND = me.Out.applyVoltage(electron);
					if (GND){
						me.fuseAddAmpere(electron.ampere);
					}
				}else{
					GND = me.In.applyVoltage(electron);
					if (GND){
						me.fuseAddAmpere(GND);
					}
				}
			}
		}
		etd.out("CircuitBraker",me.name,name,electron);
		return GND;
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
	applyVoltage : func(electron,name=""){
		etd.in("Relais",me.name,name,electron);
		var GND = 0;
		if(electron != nil){
			#electron.resistor += me.qos;
			if (me.state){
				if (name == "in"){
					GND = me.Out.applyVoltage(electron);
				}else if (name == "out"){
					GND = me.In.applyVoltage(electron);
				}
			}
			
			if (name == "+"){
				GND = me.Minus.applyVoltage(electron);
				if (GND > 0 ){
					GND += me.electricWork(electron);
					me._setValue(1);
				}else{
					me._setValue(0);
				}
			}
		}
		etd.out("Relais",me.name,name,electron);
		return GND;
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
	applyVoltage : func(electron,name=""){ 
		etd.in("Light",me.name,name,electron);
		var GND = 0;
		
		if (electron != nil){
			me.setVolt(electron.volt);
			electron.resistor += me.resistor;# * me.qos
			
			if (name == "+"){
				GND = me.Minus.applyVoltage(electron);
				if (GND){
					var watt = me.electricWork(electron);
					me._dimm(watt);
				}
			}
			
			me.setAmpere(electron.ampere);
		}
		etd.out("Light",me.name,name,electron);
		return GND;
	},
	_setValue : func(value){
		
		if (value > 1.0) { value = 1.0 };
		if (value < 0.0) { value = 0.0 };
		
		me.state = value;
	},
	_dimm : func(watt){
		var percentage = (watt / me.watt) * me.qos;
		me._setValue(percentage);
		
	},
	
};



