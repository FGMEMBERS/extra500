var FuelPump = {
	new : func(nRoot,name){
		var m = {parents:[
			FuelPump,
			Part.new(nRoot,name),
			ElectricAble.new(nRoot,name)
		]};
		m.state = 0;
		m.max = 0.1;	
		
		m.Plus = ElectricConnector.new("+");
		m.Minus = ElectricConnector.new("-");
		
		m.nState = nRoot.initNode("state",m.state,"BOOL");
				
		m.Plus.solder(m);
		m.Minus.solder(m);
		return m;

	},
	flow : func(flow){
		if (me.hasPower()){
			flow = flow * me.qos;
		}else{
			flow = 0;
		}
		
		return flow;
	},
	applyVoltage : func(volt,name=""){ 
		etd.in("Pump",me.name,name,volt);
		var ampere = 0;
		volt *= me.qos;
		me.setVolt(volt);
		
		if (name == "+"){
			ampere = me.Minus.applyVoltage(volt);
			if (ampere){
				ampere += me.electricWork(volt);
				me.state = 1;
			}else{
				me.state = 0;
			}
		}
		
		me.setAmpere(ampere);
		etd.out("Pump",me.name,name,volt,ampere);
		return ampere;
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
