var FusePanel = {
	new : func{
		var m = {parents:[
			FusePanel
		]};
		m.nRoot = props.globals.getNode("extra500/FusePanel",1);
		
		var node = m.nRoot.initNode("BatteryBus");
		m.batteryBus = Part.ElectricCircuitBraker.new(node,"BatteryBus Fuse");
		m.batteryBus.fuseConfig(150.0);
		
		var node = m.nRoot.initNode("LoadBus");
		m.loadBus = Part.ElectricCircuitBraker.new(node,"LoadBus Fuse");
		m.loadBus.fuseConfig(150.0);
		
		var node = m.nRoot.initNode("EmergencyBus");
		m.emergencyBus = Part.ElectricCircuitBraker.new(node,"EmergencyBus Fuse");
		m.emergencyBus.fuseConfig(40.0);
		
		var node = m.nRoot.initNode("Emergency3");
		m.emergency3 = Part.ElectricCircuitBraker.new(node,"Emergency3 Fuse");
		m.emergency3.fuseConfig(35.0);
		
		return m;
		
	},
};

var fusePanel = FusePanel.new();
		