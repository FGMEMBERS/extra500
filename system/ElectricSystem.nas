
var ElectricSystem = {
	new : func{
		var m = {parents:[
			ElectricSystem
		]};
		m.nRoot = props.globals.getNode("extra500/Electric",1);
		
		
		var node = m.nRoot.initNode("Battery");
		m.oBattery = Part.ElectricBattery.new(node,"Battery");
		m.oBattery.setVolt(24.0);
				
		var node = m.nRoot.initNode("HotBus");
		m.oHotBus = Part.ElectricBus.new(node,"HotBus");
		
		
		var node = m.nRoot.initNode("LoadBus");
		m.oLoadBus = Part.ElectricBus.new(node,"LoadBus");
						
		var node = m.nRoot.initNode("BatteryBus");
		m.oBatteryBus = Part.ElectricBus.new(node,"BatteryBus");
		
		var node = m.nRoot.initNode("AvionicsBus");
		m.oAvionicsBus = Part.ElectricBus.new(node,"AvionicsBus");
		
		var node = m.nRoot.initNode("EmergencyBus");
		m.oEmergencyBus = Part.ElectricBus.new(node,"EmergencyBus");
				
		var node = m.nRoot.initNode("BatteryRelais");
		m.oBatteryRelais = Part.ElectricRelais.new(node,"BatteryRelais");
		
		
		return m;
	},
	plugElectric : func(){
		
		me.oHotBus.plugElectricSource(me.oBattery);
		
		me.oBatteryRelais.plugElectricSource(extra500.oSidePanel.swtMainBattery);
		me.oBatteryRelais.plugLeftElectricSource(me.oBatteryBus);
		me.oBatteryRelais.plugRightElectricSource(me.oHotBus);
		
		me.oBatteryBus.plugElectricSource(me.oBatteryRelais.oRight);
		me.oLoadBus.plugElectricSource(me.oBatteryRelais.oRight);
		me.oEmergencyBus.plugElectricSource(me.oBatteryRelais.oRight);
		me.oAvionicsBus.plugElectricSource(me.oBatteryRelais.oRight);
		
		
		
		
		global.fnAnnounce("debug","ElectricSystem.plugElectric() ... check");
			
	},
	update : func(){
		me.oBatteryRelais.update();
	}
};

var GenaratorControlUnit = {
	new : func{
		var m = {parents:[
			ElectricSystem
		]};
	},
};

var oElectric = ElectricSystem.new();
