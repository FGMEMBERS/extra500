var MainBoard = {
	new : func{
		var m = {parents:[
			MainBoard
		]};
		m.nRoot = props.globals.getNode("extra500/electric",1);
		
	# Ground Connector
		m.GND = Part.ElectricConnector.new("GND");
		
		var node = m.nRoot.initNode("Battery");
		m.oBattery = Part.ElectricBattery.new(node,"Battery");
		m.oBattery.setVolt(24.0);
		
	# Relais
		var node = m.nRoot.initNode("BatteryRelais");
		m.batteryRelais = Part.ElectricRelais.new(node,"Battery Relais");

		
	#internal Buses
		
		m.iBus20 = Part.ElectricBus.new("#20");
		m.iBus10 = Part.ElectricBus.new("#20");
		
	# main Buses
		
		m.hotBus = Part.ElectricBus.new("HotBus");
		m.loadBus = Part.ElectricBus.new("LoadBus");
		m.batteryBus = Part.ElectricBus.new("BatteryBus");
		m.avionicsBus = Part.ElectricBus.new("AvionicsBus");
		m.emergencyBus = Part.ElectricBus.new("EmergencyBus");
		m.emergencyBus = Part.ElectricBus.new("EmergencyBus");
		
	# shunts
		var node = m.nRoot.initNode("BatteryShunt");
		m.batteryShunt = Part.ElectricShunt.new(node,"Battery Shunt");
		
		var node = m.nRoot.initNode("GeneratorShunt");
		m.generatorShunt = Part.ElectricShunt.new(node,"Generator Shunt");
		
		var node = m.nRoot.initNode("AlternatorShunt");
		m.alternatorShunt = Part.ElectricShunt.new(node,"Alternator Shunt");
		
	# Fuse
		var node = m.nRoot.initNode("BatteryFuse");
		m.batteryFuse = Part.ElectricCircuitBraker.new(node,"Battery Fuse");
		m.batteryFuse.fuseConfig(150.0);
		
	#### solder Connectors
		m.GND.solder(m);
		
		return m;
	},
	update : func(){
		me.oBattery.update();
		var text = "";
		text ~= sprintf("Battery    %0.2f V   %0.2f A\n",me.batteryShunt.voltIndicated,me.batteryShunt.ampereIndicated);
		text ~= sprintf("Generator  %0.2f V   %0.2f A\n",me.batteryShunt.voltIndicated,me.batteryShunt.ampereIndicated);
		text ~= sprintf("Altenator  %0.2f V   %0.2f A\n",me.batteryShunt.voltIndicated,me.batteryShunt.ampereIndicated);
		
		
		IFD.demo.setElectric(text);
	},
	applyVoltage : func(electron,name=""){ 
		if (name == "GND"){
			#etd.echo("MainBoard.applyVoltage("~volt~","~name~") ... touch GND");
			if (electron.resistor > 0){
				electron.ampere = electron.volt / electron.resistor;
			}else{
				Part.etd.echo("MainBoard.applyVoltage("~name~") ... touch GND Kurzschluß !!!!!");
			}
			return 1;
		}
		return 0;
	},
	plugElectric : func(){
		
		me.oBattery.minus.plug(me.GND);
		
		me.hotBus.plug(me.oBattery.plus);
		
		# Battery Relais
		me.hotBus.plug(me.batteryRelais.Plus);
		me.batteryRelais.Minus.plug(oSidePanel.swtMainBattery.On);
		me.hotBus.plug(me.batteryRelais.In);
		me.iBus20.plug(me.batteryRelais.Out);
		
		# Battery Shunt
		me.iBus20.plug(me.batteryShunt.Minus);
		me.iBus10.plug(me.batteryShunt.Plus);
		
		# battery Fuse
		me.iBus10.plug(me.batteryFuse.In);
		me.batteryBus.plug(me.batteryFuse.Out);
		
		
		
		
	},
};

var oElectric = MainBoard.new();