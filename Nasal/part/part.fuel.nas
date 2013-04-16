var FuelPump = {
	new : func(nRoot,name,state=0){
		var m = {parents:[
			FuelPump,
			Part.new(nRoot,name),
			SimStateAble.new(nRoot,"BOOL",state),
			ElectricAble.new(nRoot,name)
		]};
		
		m.max = 0.1;	
		
		m.Plus = ElectricConnector.new("+");
		m.Minus = ElectricConnector.new("-");
						
		m.Plus.solder(m);
		m.Minus.solder(m);
		
		append(aListSimStateAble,m);
		return m;

	},
	flow : func(flow){
		if (me.state){
			flow = flow * me.qos;
		}else{
			flow = 0;
		}
		
		return flow;
	},
	applyVoltage : func(electron,name=""){ 
		etd.in("Pump",me.name,name,electron);
		var GND = 0;
		#volt *= me.qos;
		electron.resistor += me.resistor;
		if (name == "+"){
			GND = me.Minus.applyVoltage(electron);
			if (GND){
				var watt = me.electricWork(electron);
				me.state = 1;
			}else{
				me.state = 0;
			}
		}
		me.setVolt(electron.volt);
		me.setAmpere(electron.ampere);
		etd.out("Pump",me.name,name,electron);
		return GND;
	},
	
};

var FuelFilter = {
	new : func(nRoot,name){
		var m = {parents:[
			FuelFilter,
			Part.new(nRoot,name)
		]};
		return m;
	},
	flow : func(flow){
		flow = flow * me.qos;
		return flow;
	},
};

var FuelSelectorValve = {
	new : func(nRoot,name){
		var m = {parents:[
			FuelSelectorValve,
			Part.new(nRoot,name)
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
		return flow;
	},
	left : func(){
		me.setValue(me.state -1);
	},
	right : func(){
		me.setValue(me.state +1);
	}
	
};
