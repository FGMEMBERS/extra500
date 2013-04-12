# extra500 tank routing

# 	
#1 Gallone US  = 3,785411784 Liter

var FuelSystem = {
	new : func{
		var m = {parents:[FuelSystem]};
		
		m.fuelFlowByGravity = 0.4;
		m.fuelFlowByPump = 0.4;
		
		m.nFuel = props.globals.getNode("extra500/fuel",1);
		
		var node = nil; 
		
		node = m.nFuel.initNode("valve");
		m.oSelectorValve = Part.SelectorValve.new(node,"Tank Selector Valve");
		m.oSelectorValve.flowConfig("JET-A",0.05,"gal_us/sec");
		
		node = m.nFuel.initNode("pump");
		m.oPump1= Part.ElectricPump.new(node,"Fuel Pump 1");
		m.oPump1.flowConfig("JET-A",0.05,"gal_us/sec");
		
		node = m.nFuel.initNode("pump");
		m.oPump2= Part.ElectricPump.new(node,"Fuel Pump 2");
		m.oPump2.electricConfig(18.0,20);
		m.oPump2.flowConfig("JET-A",0.05,"gal_us/sec");
		
		
		node = m.nFuel.initNode("pump");
		m.oPumpLeft= Part.ElectricPump.new(node,"Fuel Transfer Pump Left");
		m.oPumpLeft.flowConfig("JET-A",0.05,"gal_us/sec");
		
		node = m.nFuel.initNode("pump");
		m.oPumpRight= Part.ElectricPump.new(node,"Fuel Transfer Pump Right");
		m.oPumpRight.flowConfig("JET-A",0.1,"gal_us/sec");
				
		node = m.nFuel.initNode("Filter");
		m.oMainFilter= Part.Filter.new(node,"Fuel Main Filter");
		m.oMainFilter.flowConfig("JET-A",0.1,"gal_us/sec");
		
		node = m.nFuel.initNode("Filter");
		m.oLeftFilter = Part.Filter.new(node,"Fuel Left Filter");
		m.oLeftFilter.flowConfig("JET-A",0.05,"gal_us/sec");
		
		node = m.nFuel.initNode("Filter");
		m.oRightFilter = Part.Filter.new(node,"Fuel Right Filter");
		m.oRightFilter.flowConfig("JET-A",0.05,"gal_us/sec");
		
		
		
		### calculate all in gal_us
		
		m.nTankLeftAuxiliary 	= props.globals.getNode("/consumables/fuel/tank[0]",1);
		m.nTankLeftMain 	= props.globals.getNode("/consumables/fuel/tank[1]",1);
		m.nTankLeftCollector 	= props.globals.getNode("/consumables/fuel/tank[2]",1);
		m.nTankEngine 		= props.globals.getNode("/consumables/fuel/tank[3]",1);
		m.nTankRightCollector 	= props.globals.getNode("/consumables/fuel/tank[4]",1);
		m.nTankRightMain 	= props.globals.getNode("/consumables/fuel/tank[5]",1);
		m.nTankRightAuxiliary 	= props.globals.getNode("/consumables/fuel/tank[6]",1);
		
		m.nLevelLeftAuxiliary 	= m.nTankLeftAuxiliary.getNode("level-gal_us",1);
		m.nLevelLeftMain 	= m.nTankLeftMain.getNode("level-gal_us",1);
		m.nLevelLeftCollector 	= m.nTankLeftCollector.getNode("level-gal_us",1);
		m.nLevelEngine 		= m.nTankEngine.getNode("level-gal_us",1);
		m.nLevelRightCollector 	= m.nTankRightCollector.getNode("level-gal_us",1);
		m.nLevelRightMain 	= m.nTankRightMain.getNode("level-gal_us",1);
		m.nLevelRightAuxiliary 	= m.nTankRightAuxiliary.getNode("level-gal_us",1);
		
		
		
		m.capLeftAuxiliary 	= m.nTankLeftAuxiliary.getNode("capacity-gal_us",1).getValue();
		m.capLeftMain 		= m.nTankLeftMain.getNode("capacity-gal_us",1).getValue();
		m.capLeftCollector 	= m.nTankLeftCollector.getNode("capacity-gal_us",1).getValue();
		m.capEngine 		= m.nTankEngine.getNode("capacity-gal_us",1).getValue();
		m.capRightCollector 	= m.nTankRightCollector.getNode("capacity-gal_us",1).getValue();
		m.capRightMain 		= m.nTankRightMain.getNode("capacity-gal_us",1).getValue();
		m.capRightAuxiliary 	= m.nTankRightAuxiliary.getNode("capacity-gal_us",1).getValue();
		
		m.levelEngine 		= m.nLevelEngine.getValue();
		m.levelLeftAuxiliary 	= m.nLevelLeftAuxiliary.getValue();
		m.levelLeftMain 	= m.nLevelLeftMain.getValue();
		m.levelLeftCollector 	= m.nLevelLeftCollector.getValue();
		m.levelRightCollector 	= m.nLevelRightCollector.getValue();
		m.levelRightMain 	= m.nLevelRightMain.getValue();
		m.levelRightAuxiliary 	= m.nLevelRightAuxiliary.getValue();
		
		return m;
	},
	plugElectric : func(){
		global.fnAnnounce("debug","FuelSystem.plugElectric() ...");
		
		me.oPump1.plugElectricSource(masterPanel.FuelPump1);
		me.oPump2.plugElectricSource(masterPanel.FuelPump2);
		
		me.oPumpLeft.plugElectricSource(masterPanel.FuelTransferLeft);
		me.oPumpRight.plugElectricSource(masterPanel.FuelTransferRight);
		
			
	},
	# can only used when Module extra500 is completly loaded.
	# All callback functions must called from a global namespace
	initUI : func(){
		UI.register("Fuel Select Valve <", 	func{extra500.oFuelSystem.oSelectorValve.left();} 			);
		UI.register("Fuel Select Valve >", 	func{extra500.oFuelSystem.oSelectorValve.right();} 		);
	},
	_levelByGravity : func(){
		var frac1 = me.levelLeftMain / me.capLeftMain;
		var frac2 = me.levelLeftCollector / me.capLeftCollector;
		
		var frac5 = me.levelRightMain / me.capRightMain;
		var frac4 = me.levelRightCollector / me.capRightCollector;
		
		var flowLeft = (frac1 - frac2 ) * me.fuelFlowByGravity;
		var flowRight = (frac5 - frac4 ) * me.fuelFlowByGravity;
		
		me.levelLeftMain -= flowLeft;
		me.levelLeftCollector += flowLeft;
		
		me.levelRightMain -= flowRight;
		me.levelRightCollector += flowRight;
	},
	_getFromTank : func(level,flow){
		if (level < flow){
			return level;
		}
		return flow;
	},
	_levelByPump: func(){
		var flow = 0.0;
		var auxflow = 0.0;
		var mainFlow = 0.0;
		var overflow = 0.0;
		
		
		flow = me.oPumpLeft.flow(me.oPumpLeft.max);
		if (flow>0){	
			flow = me.oLeftFilter.flow(flow);
			auxflow = me._getFromTank(me.levelLeftAuxiliary,flow*0.35);
			me.levelLeftAuxiliary -= auxflow;
			
			mainFlow = me._getFromTank(me.levelLeftMain,flow*0.65);
			me.levelLeftMain -= mainFlow;
						
			overflow = me.levelLeftCollector + mainFlow + auxflow;
			if (overflow > me.capLeftCollector){
				me.levelLeftCollector = me.capLeftCollector;
				overflow -= me.capLeftCollector;
				me.levelLeftMain += overflow;
			}else{
				me.levelLeftCollector = overflow;
			}	
		}
		
		
		flow = me.oPumpRight.flow(me.oPumpRight.max);
		if (flow>0){	
			flow = me.oRightFilter.flow(flow);
			auxflow = me._getFromTank(me.levelRightAuxiliary,flow*0.35);
			me.levelRightAuxiliary -= auxflow;
			
			mainFlow = me._getFromTank(me.levelRightMain,flow*0.65);
			me.levelRightMain -= mainFlow;
						
			overflow = me.levelRightCollector + mainFlow + auxflow;
			if (overflow >= me.capRightCollector){
				me.levelRightCollector = me.capRightCollector;
				overflow -= me.capRightCollector;
				me.levelRightMain += overflow;
			}else{
				me.levelRightCollector = overflow;
			}
		}
		
		
	},
	_flowViaValve : func(amount){
		var flow = 0;
		if (me.oSelectorValve.state == 1){ # Left Tank
			flow = me._flowLeft(amount);
		}else if(me.oSelectorValve.state == 2){ # Both
			toPump = amount / 2;
			if (me.levelRightCollector <= me.levelLeftCollector){
				flow = me._flowRight(toPump);
				amount -= flow;
				flow += me._flowLeft(amount);
			}else{
				flow = me._flowLeft(toPump);
				amount -= flow;
				flow += me._flowRight(amount);
			}
		}else if(me.oSelectorValve.state == 3){ # Right
			flow = me._flowRight(amount);
		}else { # closed
			print("Selector Valve is closed.");
		}
		flow = me.oSelectorValve.flow(flow);
		return flow;
	},
	_flowLeft : func(toPump){
		var estimatedLevel = me.levelLeftCollector - toPump;
		var flow = 0;	
		if (estimatedLevel<0){
			me.levelLeftCollector = 0;
			flow = toPump + estimatedLevel;
		}else{
			me.levelLeftCollector -= toPump;
			flow = toPump;
		}
		
		return flow;
	},
	_flowRight : func(toPump){
		estimatedLevel = me.levelRightCollector - toPump;
			
		if (estimatedLevel<0){
			me.levelRightCollector = 0;
			flow = toPump + estimatedLevel;
		}else{
			me.levelRightCollector -= toPump;
			flow = toPump;
		}
		
		return flow;
	},
	_flowViaPumps : func(flow){
		var flown = 0;
		flown += me.oPump1.flow(flow);
		flown += me.oPump2.flow(flow-flown);
		return flow;
	},
	_pumpToEngine: func(){
		var need = me.capEngine - me.levelEngine;
		var flow = 0;
		# if (oPump1.isWorking() or )
		flow = me._flowViaPumps(need);
		flow = me.oMainFilter.flow(flow);
		flow = me._flowViaValve(flow);
		
		me.levelEngine += flow;
	},
	update : func(){
		me.levelLeftAuxiliary = me.nLevelLeftAuxiliary.getValue();
		me.levelLeftMain = me.nLevelLeftMain.getValue();
		me.levelLeftCollector = me.nLevelLeftCollector.getValue();
		me.levelRightCollector = me.nLevelRightCollector.getValue();
		me.levelRightMain = me.nLevelRightMain.getValue();
		me.levelRightAuxiliary = me.nLevelRightAuxiliary.getValue();
		me.levelEngine = me.nLevelEngine.getValue();
		
		me._levelByGravity();
		me._levelByPump();
		me._pumpToEngine();
			
		me.nLevelEngine.setValue(me.levelEngine);
		me.nLevelLeftAuxiliary.setValue(me.levelLeftAuxiliary);
		me.nLevelLeftMain.setValue(me.levelLeftMain);
		me.nLevelLeftCollector.setValue(me.levelLeftCollector);
		me.nLevelRightCollector.setValue(me.levelRightCollector);
		me.nLevelRightMain.setValue(me.levelRightMain);
		me.nLevelRightAuxiliary.setValue(me.levelRightAuxiliary);
			
	},
	
	
};

var oFuelSystem = FuelSystem.new();

