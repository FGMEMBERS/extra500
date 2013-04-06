var ElectricSystem = {
	new : func{
		var m = {parents:[
			ElectricSystem
		]};
		m.nRoot = props.globals.getNode("extra500/electric",1);
		
		# Ground Connector
		m.GND = Part.ElectricConnector.new("GND");
		
		var node = m.nRoot.initNode("Battery");
		m.oBattery = Part.ElectricBattery.new(node,"Battery");
		m.oBattery.setVolt(24.0);
		
		# Relais
		var node = m.nRoot.initNode("BatteryRelais");
		m.BatteryRelais = Part.ElectricRelais.new(node,"Battery Relais");

		
		#internal Buses
		
		m.iBus20 = Part.ElectricBus.new("#20");
		
		# main Buses
		
		m.hotBus = Part.ElectricBus.new("HotBus");
		m.loadBus = Part.ElectricBus.new("LoadBus");
		m.batteryBus = Part.ElectricBus.new("BatteryBus");
		m.avionicsBus = Part.ElectricBus.new("AvionicsBus");
		m.emergencyBus = Part.ElectricBus.new("EmergencyBus");
		m.emergencyBus = Part.ElectricBus.new("EmergencyBus");
		
		
		m.GND.solder(m);
		
		return m;
	},
	update : func(){
		me.oBattery.update();
	},
	applyVoltage : func(volt,name=""){ 
		if (name == "GND"){
			print("ElectricSystem.applyVoltage("~volt~","~name~") ... touch GND");
			return 0.000000001;
		}
		return 0;
	},
	plugElectric : func(){
		
		me.oBattery.minus.plug(me.GND);
		
		me.hotBus.plug(me.oBattery.plus);
		
		#me.iBus20.plug(me.oBattery.plus);
		#me.iBus20.plug(me.GND);
		
	},
};

var oElectric = ElectricSystem.new();