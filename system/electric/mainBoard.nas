var MainBoard = {
	new : func{
		var m = {parents:[
			MainBoard
		]};
		m.nRoot = props.globals.getNode("extra500/mainBoard",1);
		var nParent = nil;
	# Ground Connector
		m.GND = Part.ElectricConnector.new("GND");
		
		var node = m.nRoot.initNode("Battery");
		m.oBattery = Part.ElectricBattery.new(node,"Battery");
		m.oBattery.setVolt(24.0);
		
	# Relais
		nParent = m.nRoot.initNode("Relais");
				
		var node = nParent.initNode("BatteryRelais");
		m.batteryRelais = Part.ElectricRelaisXPST.new(node,"Battery Relais");
		m.batteryRelais.setPoles(2);
		
		nCompNode = nParent.initNode("DayNightRelais");
		m.dayNightRelais = Part.ElectricRelaisXPDT.new(nCompNode,"Day/Night Relais");
		m.dayNightRelais.setPoles(5);
		# 1 KEYPAD
		# 2 GLARE
		# 3 INSTR
		# 4 SWITCHES
		# 5 ANNUNCIATOR
		
		nCompNode = nParent.initNode("TestLightRelais");
		m.testLightRelais = Part.ElectricRelaisXPDT.new(nCompNode,"Test Light Relais");
		m.testLightRelais.setPoles(5);
		# 1 ANNUNCIATOR
		# 2 Gear
		# 3 Flaps
		# 4 DME
		
		
		nCompNode = nParent.initNode("RCCBRelais");
		m.rccbRelais = Part.ElectricRelaisXPST.new(nCompNode,"RCCB Relais");
		m.rccbRelais.setPoles(1);
		
		nCompNode = nParent.initNode("EmergencyRelais");
		m.emergencyRelais = Part.ElectricRelaisXPDT.new(nCompNode,"Emergency Relais");
		m.emergencyRelais.setPoles(1);
		
		nCompNode = nParent.initNode("AvionicsRelais");
		m.avionicsRelais = Part.ElectricRelaisXPST.new(nCompNode,"Avionics Relais");
		m.avionicsRelais.setPoles(1);
		
		
	#internal Buses
		
		m.iBus20 = Part.ElectricBus.new("#20");
		m.iBus10 = Part.ElectricBus.new("#10");
		m.iBus11 = Part.ElectricBus.new("#11");
		m.iBus01 = Part.ElectricBus.new("#01");
		m.iBus12 = Part.ElectricBus.new("#12");
		m.iBus13 = Part.ElectricBus.new("#13");
	
	# main Buses
		
		m.hotBus = Part.ElectricBus.new("HotBus");
		m.loadBus = Part.ElectricBus.new("LoadBus");
		m.batteryBus = Part.ElectricBus.new("BatteryBus");
		m.avionicBus = Part.ElectricBus.new("AvionicsBus");
		m.emergencyBus = Part.ElectricBus.new("EmergencyBus");
		
	# shunts
		var node = m.nRoot.initNode("BatteryShunt");
		m.batteryShunt = Part.ElectricShunt.new(node,"Battery Shunt");
		
		var node = m.nRoot.initNode("GeneratorShunt");
		m.generatorShunt = Part.ElectricShunt.new(node,"Generator Shunt");
		
		var node = m.nRoot.initNode("AlternatorShunt");
		m.alternatorShunt = Part.ElectricShunt.new(node,"Alternator Shunt");
		
		
	#### solder Connectors
		m.GND.solder(m);
		
		return m;
	},
	update : func(timestamp){
		
		me.oBattery.update(timestamp);
		
	},
	applyVoltage : func(electron,name=""){ 
		if (name == "GND"){
			#etd.echo("MainBoard.applyVoltage("~volt~","~name~") ... touch GND");
			if (electron.resistor > 0){
				electron.ampere = electron.volt / electron.resistor;
			}else{
				Part.etd.echo("MainBoard.applyVoltage("~name~") ... touch GND Kurzschluß !!!!!");
				electron.ampere = electron.volt / 0.0024;
			}
			return 1;
		}
		return 0;
	},
	
};

var mainBoard = MainBoard.new();