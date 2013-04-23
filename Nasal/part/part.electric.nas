

var ElectricTreeDebugger = {
	new : func(){
				
		var m = {parents:[
			ElectricTreeDebugger
		]};
		m.on	 	= 0;
		m.depth 	= 0;
		m.defaultStr 	= "                                       ";
		m.debugLevel	=0;
		m.highLightType = "Relais";
		m.excludeType 	= "";
		m.debugName 	= "";
		m.nDebugOutput = props.globals.initNode("extra500/DebugOutput","","STRING");
		return m;

	},
	colorRed : func(s) { return globals.string.color("32", s)},
	in : func(type,name,connector,electron,icon=""){#└┬
		if (me.on == 1){
			if (find(me.debugName,name) > -1){
				me.debugLevel+=1;
				#print("ElectricTreeDebugger     found "~name);
			}
			
			if (me.debugLevel > 0){
				
				if (find(type,me.highLightType) > -1){
					type = me.colorRed(type);
				}
				if (find(type,me.excludeType) == -1){
					var space = substr(me.defaultStr,0,me.depth);
					var output = me.nDebugOutput.getValue();
					output ~= sprintf("%s %s %s %s %s %s\n",space,icon,type,name,connector,electron.getText());
					#print(output);
					me.nDebugOutput.setValue(output);
				}
				
			}
			me.depth += 1;
		}
	},
	out : func(type,name,connector,electron,icon=""){#┌┴
		if (me.on == 1){
			if (me.debugLevel > 0){
				if (find(type,me.highLightType) > -1){
					type = me.colorRed(type);
				}
				if (find(type,me.excludeType) == -1){
					var space = substr(me.defaultStr,0,me.depth);
					var output = me.nDebugOutput.getValue();
					output ~= sprintf("%s%s %s %s %s %s\n",space,icon,type,name,connector,electron.getText());
					#print(output);
					#me.nDebugOutput.setValue(output);
				}
			}
			if (find(me.debugName,name) > -1){
				me.debugLevel-=1;
			}
			me.depth -= 1;
		}
	},
	echo : func(msg,icon="**"){
		if (me.debugLevel > 0){
			var space = substr(me.defaultStr,0,me.depth);
			var output = me.nDebugOutput.getValue();
			output ~= sprintf("%s%s %s\n",space,icon,msg);
			#print(output);
			me.nDebugOutput.setValue(output);
			
		}
	},
	print : func(msg){
		if (me.on == 1){
			var output = me.nDebugOutput.getValue();
			output ~= msg~"\n";
			#print(msg);
			me.nDebugOutput.setValue(output);
			
		}
	},
	cls : func(){
		me.nDebugOutput.setValue("");
	},
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
		m.timestamp	= 0.0;
		return m;
	},
	copyConstructor : func (){
		var electron = Electron.new();
		electron.volt		= me.volt;
		electron.resistor	= me.resistor;
		electron.ampere		= me.ampere;
		electron.timestamp	= me.timestamp;
		return electron;
	},
	copy : func(electron){
		me.volt		= electron.volt;
		me.resistor	= electron.resistor;
		me.ampere	= electron.ampere;
		me.timestamp	= electron.timestamp;
		
	},
	paste : func(electron){
		electron.volt		= me.volt;
		electron.resistor	= me.resistor;
		electron.ampere		= me.ampere;
		electron.timestamp	= me.timestamp;
	},
	zero : func(){
		me.volt		= 0.0;
		me.resistor	= 0.0;
		me.ampere	= 0.0
	},
	set : func(volt,resistor,ampere,timestamp){
		me.volt		= volt;
		me.resistor	= resistor;
		me.ampere	= ampere;
		me.timestamp	= timestamp;
	},
	getText : func(){
		return sprintf("%0.4fV %0.4fR %0.4fA %f",me.volt,me.resistor,me.ampere,me.timestamp);
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
				me.ampereIndicated = electron.ampere;
				me.voltIndicated = electron.volt;
				
			}else if(name == "-"){
				GND = me.Plus.applyVoltage(electron);
				me.ampereIndicated = -electron.ampere;
				me.voltIndicated = -electron.volt;
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
		m.electron = Electron.new();
		m.electronTmp = Electron.new();
		m.index = nil;
		return m;
	},
	plug : func(connector,name="default"){
		if (name == "default"){
			name = sprintf("%s-%03i",me.name,size(me.connectors));
		}
		me.connectors[name] = ElectricConnector.new(name);
		me.connectors[name].solder(me);
		me.connectors[name].plug(connector);
		connector.plug(me.connectors[name]);
		me.order();
	},
	con : func(name="default"){
		if (name == "default"){
			name = sprintf("%s-%03i",me.name,size(me.connectors));
		}
		me.connectors[name] =  ElectricConnector.new(name);
		me.connectors[name].solder(me);
		me.order();
		return me.connectors[name];
	},
	applyVoltage : func(electron,name=""){ 
		etd.in("Bus",me.name,name,electron);
		var GND = 0;
		var ampereSum = 0;
		if ( electron != nil){
			if (me.electron.timestamp != electron.timestamp){
				me.electron.copy(electron);
								
				foreach(var i;me.index) {
					me.electronTmp.set(me.electron.volt,me.electron.resistor,0.0,me.electron.timestamp);
					if (i != name){
						if ( me.connectors[i].applyVoltage(me.electronTmp) ){
							GND = 1;
							me.electron.ampere += me.electronTmp.ampere;
						}
					}
				}
				me.electron.resirstor = me.electron.volt / me.electron.ampere;
				etd.echo("Bus electron " ~me.electron.getText());
				
				me.electron.paste(electron);
			}else{
				etd.echo("X-X-X Bus not CYCLE again " ~me.electron.getText());
			}
		}
		etd.out("Bus",me.name,name,electron);
		return GND;
	},
	order : func(){
		me.index = sort(keys(me.connectors), func (a,b) cmp (me.connectors[a].name, me.connectors[b].name)) ;
	},
	echoOrder : func(){
		foreach(var i;me.index) {
			print(sprintf("Bus %s %s %s",me.connectors[i].name,me.connectors[i].connector.name,me.connectors[i].connector.electricAble.name));
		}
	}
};

var ElectricBusDiode = {
	new : func(name){		
		var m = {parents:[
			ElectricBusDiode
		]};
		m.name = name;
		m.connectors = {};
		m.electron = Electron.new();
		m.electronTmp = Electron.new();
		
		m.Minus = ElectricConnector.new("-");
		m.Minus.solder(m);
		
		return m;
	},
	plug : func(connector,name="default"){
		if (name == "default"){
			name = sprintf("%s-%03i",me.name,size(me.connectors));
		}
		me.connectors[name] = ElectricConnector.new(name);
		me.connectors[name].solder(me);
		me.connectors[name].plug(connector);
		connector.plug(me.connectors[name]);
		me.order();
	},
	con : func(name="default"){
		if (name == "default"){
			name = sprintf("%s-%03i",me.name,size(me.connectors));
		}
		me.connectors[name] =  ElectricConnector.new(name);
		me.connectors[name].solder(me);
		me.order();
		return me.connectors[name];
	},
	applyVoltage : func(electron,name=""){ 
		etd.in("BusDiode",me.name,name,electron);
		var GND = 0;
		var ampereSum = 0;
		
		if ( electron != nil){
			if ( name != "-" ){
				GND = me.Minus.applyVoltage(electron);
			}
		}
		
		etd.out("BusDiode",me.name,name,electron);
		return GND;
	},
	order : func(){
		me.index = sort(keys(me.connectors), func (a,b) cmp (me.connectors[a].name, me.connectors[b].name)) ;
	},
	echoOrder : func(){
		foreach(var i;me.index) {
			print(sprintf("Bus %s %s %s",me.connectors[i].name,me.connectors[i].connector.name,me.connectors[i].connector.electricAble.name));
		}
	}
};

var ElectricBattery = {
	new : func(nRoot,name,capacityAh=28.0){
				
		var m = {parents:[
			ElectricBattery,
			Part.new(nRoot,name),
			ElectricAble.new(nRoot,name)
		]};
		
		m.capacityAs = capacityAh*3600;
		m.loadLevel = 0.8;
		m.usedAs = -(m.capacityAs * (1.0-m.loadLevel));
		m.nCapacityAs = nRoot.initNode("capacityAs",m.capacityAs,"DOUBLE");
		m.nUsedAs = nRoot.initNode("usedAs",m.usedAs,"DOUBLE");
		m.nLoadLevel = nRoot.initNode("loadLevel",m.loadLevel,"DOUBLE");
		m.simTime = systime();
		
		m.electron = Electron.new();
		
		m.Plus = ElectricConnector.new("+");
		m.Minus = ElectricConnector.new("-");
		
		m.Plus.solder(m);
		m.Minus.solder(m);
		return m;

	},
	applyVoltage : func(electron,name=""){ 
		etd.in("Battery",me.name,name,electron);
		var GND = 0;
		
		if (electron != nil){
			
			if (name == "+"){
				etd.print("Battery loading ...");
				electron.ampere = 2.8 * (1-me.loadLevel);
				me.setAmpereUsage(electron.ampere);
				GND = 1;
			}
			
			
		}
		etd.out("Battery",me.name,name,electron);
		return GND;
	},
	setAmpereUsage : func(ampere){
		#global.fnAnnounce("debug",""~me.name~"\t\t ElectricBattery.setAmpereOutput("~ampere~"A) ... ");
		
		var simNow = systime();
		
		#ampere += me.ampere;
		me.setAmpere(ampere);
		
		
		var simElapsed = simNow - me.simTime;
		
		var usedAs = ampere / simElapsed;
		
		me.usedAs += usedAs;
				
		me.loadLevel = (me.capacityAs + me.usedAs) / me.capacityAs;
		
		me.nUsedAs.setValue(me.usedAs);
		me.nLoadLevel.setValue(me.loadLevel);
		
	},
	update : func(timestamp){
		
		etd.print("--- Battery.update() ...          ---");
		etd.print("-------------------------------------");
		#etd.echo("Battery.update() ...");
		
		me.electron.volt = 24.0;
		me.electron.resistor = 0.0;
		me.electron.ampere = 0.0;
		me.electron.timestamp = timestamp;
		
		var GND = 0;
		GND = me.Plus.applyVoltage(me.electron);
		if (GND > 0){
			me.setAmpereUsage(-me.electron.ampere);
		}
		etd.print("-------------------------------------");
	},
	test_consumer : func(electron){
		electron.resistor += 100.0;
		print(electron.getText());
	}
	
};

var ElectricGenerator = {
	new : func(nRoot,name){
				
		var m = {parents:[
			ElectricGenerator,
			Part.new(nRoot,name),
			ElectricAble.new(nRoot,name)
		]};
		
		m.simTime = systime();
		
		m.electron = Electron.new();
		m.capStarter = 0;
		
		m.Plus = ElectricConnector.new("+");
		m.Minus = ElectricConnector.new("-");
		m.InterPole = ElectricConnector.new("InterPole");
		
		m.nEngineRunning = props.globals.getNode("engines/engine[0]/running",1);
		m.nControlStarter = props.globals.getNode("controls/engines/engine[0]/starter",1);
		m.nControlGenerator = props.globals.getNode("controls/electric/engine/generator",1);
		
		m.Plus.solder(m);
		m.Minus.solder(m);
		m.InterPole.solder(m);
		return m;

	},
	capacitorStarter : func (amount){
		me.capStarter += amount;
		if (me.capStarter > 3){me.capStarter=3;}
		if (me.capStarter < 0){me.capStarter=0;}
		

		me.nControlStarter.setValue(me.capStarter);
		me.nControlGenerator.setValue(me.capStarter);

	},
	applyVoltage : func(electron,name=""){ 
		etd.in("Generator",me.name,name,electron);
		var GND = 0;
		
		if (electron != nil){
			me.setVolt(electron.volt);
			electron.resistor += me.resistor;# * me.qos
			
			if (name == "+"){
				GND = me.Minus.applyVoltage(electron);
				if (GND){
					var watt = me.electricWork(electron);
					me.nControlStarter.setValue(1);
					me.nControlGenerator.setValue(1);
					me.capacitorStarter(3);
					#print("Generator.applyVoltage ... starting");
				}
				
			}
			
			me.setAmpere(electron.ampere);
		}
		etd.out("Generator",me.name,name,electron);
		return GND;
	},
	setAmpereOutput : func(ampere){
		#global.fnAnnounce("debug",""~me.name~"\t\t ElectricBattery.setAmpereOutput("~ampere~"A) ... ");
		
		var simNow = systime();

		me.setAmpere(ampere);
		
	},
	update : func(timestamp){
		
		etd.print("--- Generator.update() ...        ---");
		
		me.capacitorStarter(-1);
		
		if (me.nEngineRunning.getValue()){
			#etd.echo("Battery.update() ...");
			#me.nControlStarter.setValue(0);
			#me.nControlGenerator.setValue(0);
			
			etd.print("-------------------------------------");
			me.electron.volt = 28.0;
			me.electron.resistor = 0.0;
			me.electron.ampere = 0.0;
			me.electron.timestamp = timestamp;
			
			var GND = 0;
			GND = me.InterPole.applyVoltage(me.electron);
			me.electron.resistor = 0;
			me.electron.ampere = 0;
			GND = me.Plus.applyVoltage(me.electron);
			if (GND > 0){
				me.setAmpereOutput(me.electron.ampere);
			}
		}else{
			me.electron.volt = 0.1;
			me.electron.resistor = 0.0;
			me.electron.ampere = 0.0;
			me.electron.timestamp = timestamp;
			GND = me.InterPole.applyVoltage(me.electron);
			etd.print("--- Engine not running            ---");
		}
		etd.print("-------------------------------------");
	}
};

var GeneratorControlUnit = {
	new : func(nRoot,name){
		var m = {parents:[
			GeneratorControlUnit,
			Part.new(nRoot,name),
			ElectricAble.new(nRoot,name)
		]};
		
		m.generatorHasPower = 0;
		m.controlStarter = 0;
		
		m.StartPower = ElectricConnector.new("StartPower");
		m.StartContactor = ElectricConnector.new("StartContactor");
		m.RemoteTrip = ElectricConnector.new("RemoteTrip");
		m.OverVoltageSelfTest = ElectricConnector.new("OverVoltageSelfTest");
		m.InterPole = ElectricConnector.new("InterPole");
		m.GeneratorControlSwitch = ElectricConnector.new("GeneratorControlSwitch");
		m.Reset = ElectricConnector.new("Reset");
		m.AntiCycle = ElectricConnector.new("AntiCycle");
		m.LoadBus = ElectricConnector.new("LoadBus");
		m.POR = ElectricConnector.new("POR");
		m.LineContactorCoil = ElectricConnector.new("LineContactorCoil");
		m.GeneratorOutput = ElectricConnector.new("GeneratorOutput");
		m.GND = ElectricConnector.new("GND");
		
		
		m.generatorOutputBus = ElectricBus.new("GeneratorOutputBus");
		
		m.nControlGenerator = props.globals.getNode("controls/electric/engine/generator",1);
		
		m.StartPower.solder(m);
		m.StartContactor.solder(m);
		m.RemoteTrip.solder(m);
		m.OverVoltageSelfTest.solder(m);
		m.InterPole.solder(m);
		m.GeneratorControlSwitch.solder(m);
		m.Reset.solder(m);
		m.AntiCycle.solder(m);
		m.LoadBus.solder(m);
		m.POR.solder(m);
		m.LineContactorCoil.solder(m);
		m.GeneratorOutput.solder(m);
			
		append(aListSimStateAble,m);
		return m;
	},
	simReset : func(){
		me.capacitorStarter(-1);
	},
	simUpdate : func(){

	},
	capacitorStarter : func (amount){
		me.controlStarter += amount;
		if (me.controlStarter > 3){me.controlStarter=3;}
		if (me.controlStarter < 0){me.controlStarter=0;}
	},
	applyVoltage : func(electron,name=""){ 
		etd.in("GeneratorControlUnit",me.name,name,electron);
		var GND = 0;
		if(electron != nil){
			electron.resistor += 4700;
			if (name == "POR" or name == "LoadBus"){
				if (me.controlStarter>0){
					GND = me.StartContactor.applyVoltage(electron);
				}
				GND = me.GeneratorOutput.applyVoltage(electron);
			}elsif (name == "InterPole"){
				if (electron.volt >= 27.0){
					me.generatorHasPower = 1;
					me.capacitorStarter(-4);
				}else{
					me.generatorHasPower = 0;
				}
				GND = me.GND.applyVoltage(electron);
			}elsif (name == "RemoteTrip"){
				GND = me.GND.applyVoltage(electron);
			}elsif (name == "OverVoltageSelfTest"){
				GND = me.GND.applyVoltage(electron);
			}elsif (name == "GeneratorControlSwitch"){
				if (me.generatorHasPower == 1){
					GND = me.LineContactorCoil.applyVoltage(electron);
				}
				GND = me.GND.applyVoltage(electron);
			}elsif (name == "Reset"){
				GND = me.GND.applyVoltage(electron);
			}elsif (name == "AntiCycle"){
				GND = me.GND.applyVoltage(electron);
			}elsif (name == "StartPower"){
				if (me.generatorHasPower == 0){
					me.capacitorStarter(3);
					GND = me.StartContactor.applyVoltage(electron);
				}
			}
		}
		etd.out("GeneratorControlUnit",me.name,name,electron);
		return GND;
	},
	
};


# 0	In ─  ─ Out
# 1	In ──── Out
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
				}else{
					GND = me.In.applyVoltage(electron);
				}
				if (GND){
					if(me.fuseAddAmpere(electron.ampere)){
						electron.ampere = 0;
						sound.click(2);
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

# ElectricSwitchDT	Double Throw
# 0	      ┌── L11
# 1	Com1 ─┘ ─ L12
var ElectricSwitchDT = {

	new : func(nRoot,name,state=0){
		
		#nRoot = nRoot.initNode("switch");
		
		var m = {parents:[
			ElectricSwitchDT,
			Part.new(nRoot,name),
			SimStateAble.new(nRoot,"BOOL",state),
			ElectricAble.new(nRoot,name)
		]};
			
		m.min = 0;
		m.max = 1;
		m.step = 1;
		
		m.output = {};
		m.output[0] = {};
		m.output[1] = {};
			
		return m;

	},
	setPoles : func(count){
		var Com = "";
		var L1 = "";
		var L2 = "";
		for(var i=1; i<=count; i += 1) {
			Com = "Com"~i;
			L1 = "L"~i~"1";
			L2 = "L"~i~"2";
			
			me[Com] = ElectricConnector.new(Com);
			me[L1] = ElectricConnector.new(L1);
			me[L2] = ElectricConnector.new(L2);
						
			me.output[0][Com] = me[L1];
			me.output[0][L1] = me[Com];
			me.output[1][Com] = me[L2];
			me.output[1][L2] = me[Com];
					
			me[Com].solder(me);
			me[L1].solder(me);
			me[L2].solder(me);
			
		}
		
# 		foreach(var i ;keys(me.output[0]) ){
# 			print("Pole [0]["~i~"] = "~typeof(me.output[0][i]));
# 		}
	},
	applyVoltage : func(electron,name=""){
		etd.in("SwitchDT",me.name,name,electron);
		var GND = 0;
		if(electron != nil){
			#electron.resistor += me.qos;
			#print("Pole ["~me.state~"]["~name~"] = "~typeof(me.output[me.state][name]));
			if (contains(me.output[me.state],name)){
				GND = me.output[me.state][name].applyVoltage(electron);
			}	
			
		}
		etd.out("SwitchDT",me.name,name,electron);
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

# ElectricSwitchCO	Center Off
# 1	        ─ L11
# 0	Com1 ────
# -1	        ─ L12
var ElectricSwitchCO = {
	new : func(nRoot,name,state=0){
		
		#nRoot = nRoot.initNode("switch");
		
		var m = {parents:[
			ElectricSwitchCO,
			Part.new(nRoot,name),
			SimStateAble.new(nRoot,"INT",state),
			ElectricAble.new(nRoot,name)
		]};
			
		m.min = -1;
		m.max = 1;
		m.step = 1;
		m.output = {};
		m.output[1] = {};
		m.output[-1] = {};
			
		return m;

	},
	setPoles : func(count){
		var Com = "";
		var L1 = "";
		var L2 = "";
		for(var i=1; i<=count; i += 1) {
			Com = "Com"~i;
			L1 = "L"~i~"1";
			L2 = "L"~i~"2";
			
			me[Com] = ElectricConnector.new(Com);
			me[L1] = ElectricConnector.new(L1);
			me[L2] = ElectricConnector.new(L2);
			
						
			me.output[1][Com] = me[L1];
			me.output[1][L1] = me[Com];
			me.output[-1][Com] = me[L2];
			me.output[-1][L2] = me[Com];
					
			me[Com].solder(me);
			me[L1].solder(me);
			me[L2].solder(me);
			
		}
	},
	applyVoltage : func(electron,name=""){
		etd.in("SwitchCO",me.name,name,electron);
		var GND = 0;
		if(electron != nil){
			#electron.resistor += me.qos;
			if(me.state != 0){
				if (contains(me.output[me.state],name)){
					GND = me.output[me.state][name].applyVoltage(electron);
				}	
			}
		}
		etd.out("SwitchCO",me.name,name,electron);
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
	},

};

# ElectricSwitchTT	Tripple Throw
# 1	        ─ L11
# 0	Com1 ──── L12
# -1	        ─ L13
var ElectricSwitchTT = {
	new : func(nRoot,name,state=0){
		
		#nRoot = nRoot.initNode("switch");
		
		var m = {parents:[
			ElectricSwitchTT,
			Part.new(nRoot,name),
			SimStateAble.new(nRoot,"INT",state),
			ElectricAble.new(nRoot,name)
		]};
			
		m.min = -1;
		m.max = 1;
		m.step = 1;
		m.output = {};
		m.output[-1] = {};
		m.output[0] = {};
		m.output[1] = {};
			
		return m;

	},
	setPoles : func(count){
		var Com = "";
		var L1 = "";
		var L2 = "";
		var L3 = "";
		for(var i=1; i<=count; i += 1) {
			Com = "Com"~i;
			L1 = "L"~i~"1";
			L2 = "L"~i~"2";
			L3 = "L"~i~"3";
			
			me[Com] = ElectricConnector.new(Com);
			me[L1] = ElectricConnector.new(L1);
			me[L2] = ElectricConnector.new(L2);
			me[L3] = ElectricConnector.new(L3);
			
			me.output[1][Com] = me[L1];
			me.output[1][L1] = me[Com];
			me.output[0][Com] = me[L2];
			me.output[0][L2] = me[Com];
			me.output[-1][Com] = me[L3];
			me.output[-1][L3] = me[Com];
					
			me[Com].solder(me);
			me[L1].solder(me);
			me[L2].solder(me);
			me[L3].solder(me);
		}
	},
	applyVoltage : func(electron,name=""){
		etd.in("SwitchTT",me.name,name,electron);
		var GND = 0;
		if(electron != nil){
			#electron.resistor += me.qos;
			if (contains(me.output[me.state],name)){
				GND = me.output[me.state][name].applyVoltage(electron);
			}	
		}
		etd.out("SwitchTT",me.name,name,electron);
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
	},

};

# ElectricRelaisXPDT	Double Throw
#	 A1  ─[]─ A2
# 0	      ┌── L12
# 1	 P11 ─┘ ─ L24
var ElectricRelaisXPDT = {

	
	new : func(nRoot,name,state=0){
		
		#nRoot = nRoot.initNode("switch");
		
		var m = {parents:[
			ElectricRelaisXPDT,
			Part.new(nRoot,name),
			SimStateAble.new(nRoot,"BOOL",state),
			ElectricAble.new(nRoot,name)
		]};
		
		m.A1 = ElectricConnector.new("A1");
		m.A2 = ElectricConnector.new("A2");
		
		m.output = {};
		m.output[0] = {};
		m.output[1] = {};
			
		m.output["A1"] = m.A2;
		m.output["A2"] = m.A1;
		
		m.A1.solder(m);
		m.A2.solder(m);
		
		append(aListSimStateAble,m);
		return m;

	},
	setPoles : func(count){
		var p1 = "";
		var p2 = "";
		var p4 = "";
		for(var i=1; i<=count; i += 1) {
			p1 = "P"~i~"1";
			p2 = "P"~i~"2";
			p4 = "P"~i~"4";
			
			me[p1] = ElectricConnector.new(p1);
			me[p2] = ElectricConnector.new(p2);
			me[p4] = ElectricConnector.new(p4);
			
			
			me.output[0][p1] = me[p2];
			me.output[0][p2] = me[p1];
			me.output[1][p1] = me[p4];
			me.output[1][p4] = me[p1];
					
			me[p1].solder(me);
			me[p2].solder(me);
			me[p4].solder(me);
		}
	},
	applyVoltage : func(electron,name=""){
		etd.in("Relais",me.name,name,electron);
		var GND = 0;
		if(electron != nil){
			
			#electron.resistor += me.qos;
						
			if (name == "A1" or name == "A2"){
				electron.resistor += 190.0;
				GND = me.output[name].applyVoltage(electron);
				if (GND > 0 ){
					#GND += me.electricWork(electron);
					me._setValue(1);
				}else{
					me._setValue(0);
				}
			}else{
				if (contains(me.output[me.state],name)){
					GND = me.output[me.state][name].applyVoltage(electron);
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

# ElectricRelaisXPST	Single Throw
#	 A1  ─[]─ A2
# 0	      ┌── 
# 1	 P11 ─┘ ─ L14
var ElectricRelaisXPST = {

	new : func(nRoot,name,state=0){
		
		#nRoot = nRoot.initNode("switch");
		
		var m = {parents:[
			ElectricRelaisXPST,
			Part.new(nRoot,name),
			SimStateAble.new(nRoot,"BOOL",state),
			ElectricAble.new(nRoot,name)
		]};
		
		m.A1 = ElectricConnector.new("A1");
		m.A2 = ElectricConnector.new("A2");
		
		m.output = {};
		
		m.output["A1"] = m.A2;
		m.output["A2"] = m.A1;
		
		m.A1.solder(m);
		m.A2.solder(m);
		
		append(aListSimStateAble,m);
		return m;

	},
	setPoles : func(count){
		var p1 = "";
		var p4 = "";
		for(var i=1; i<=count; i += 1) {
			p1 = "P"~i~"1";
			p4 = "P"~i~"4";
			
			me[p1] = ElectricConnector.new(p1);
			me[p4] = ElectricConnector.new(p4);
			
			me.output[p1] = me[p4];
			me.output[p4] = me[p1];
					
			me[p1].solder(me);
			me[p4].solder(me);
			
		}
	},
	applyVoltage : func(electron,name=""){
		etd.in("ElectricRelaisXPST",me.name,name,electron);
		var GND = 0;
		if(electron != nil){
			
			#electron.resistor += me.qos;
						
			if (name == "A1" or name == "A2"){
				electron.resistor += 190.0;
				GND = me.output[name].applyVoltage(electron);
				if (GND > 0 ){
					#GND += me.electricWork(electron);
					me._setValue(1);
				}else{
					me._setValue(0);
				}
			}else{
				if (me.state == 1){
					GND = me.output[name].applyVoltage(electron);
				}
			}
		
			
		}
		etd.out("ElectricRelaisXPST",me.name,name,electron);
		return GND;
	},
	_setValue : func(value){
		me.state = value;
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

# 1	In ==>─ Out
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
		
		m.electron = Electron.new();		
		
		
		m.In = ElectricConnector.new("in");
		m.Out = ElectricConnector.new("out");
			
		m.In.solder(m);
		m.Out.solder(m);
				
		return m;

	},
	applyVoltage : func(electron,name=""){
		etd.in("Dimmer",me.name,name,electron);
		var GND = 0;
		if ( electron != nil){
			me.electron.copy(electron);
			var volt = me.voltMin + me.voltDelta * me.state * me.qos;
			if (volt < me.electron.volt){
				me.electron.volt = volt;
			}
			me.electron.resistor += me.resistor;
			me.setVolt(me.electron.volt);
			if (name == "in"){
				GND =  me.Out.applyVoltage(me.electron);
			}else{
				GND =  me.In.applyVoltage(me.electron);
			}
			
			if (GND){
				electron.ampere += me.electron.ampere;
			}
		}
		etd.out("Dimmer",me.name,name,electron);
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

#	plus ─⊗─ Out
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
					me._dimm();
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
	_dimm : func(){
		var percentage = ((me.volt-me.voltMin) * me.qos / (me.voltDelta)) ;
		me._setValue(percentage);
		
	},
	
};



