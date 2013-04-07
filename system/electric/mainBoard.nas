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
		var text = sprintf("Shunt Battery \t: %0.4f Amp",me.batteryShunt.ampereIndicated);
		IFD.demo.setShunt(text);
	},
	applyVoltage : func(volt,name=""){ 
		if (name == "GND"){
			#etd.echo("MainBoard.applyVoltage("~volt~","~name~") ... touch GND");
			return 0.000000001;
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