var LightBoard = {
	new : func{
		var m = {parents:[
			LightBoard
		]};
		
		m.nPanel = props.globals.getNode("extra500/Light",1);
		
		nCompNode = m.nPanel.initNode("Strobe");
		m.Strobe = Part.ElectricLight.new(nCompNode,"Strobe Light");
		m.Strobe.electricConfig(10.0,24.0);
		m.Strobe.setPower(24.0,30.0);
		
		nCompNode = m.nPanel.initNode("Navigation");
		m.Navigation = Part.ElectricLight.new(nCompNode,"Navigation Light");
		m.Navigation.electricConfig(10.0,24.0);
		m.Navigation.setPower(24.0,90.0);
		
		nCompNode = m.nPanel.initNode("Landing");
		m.Landing = Part.ElectricLight.new(nCompNode,"Landing Light");
		m.Landing.electricConfig(10.0,24.0);
		m.Landing.setPower(24.0,500.0);
		
		
		nCompNode = m.nPanel.initNode("Cabin");
		m.Cabin = Part.ElectricLight.new(nCompNode,"Cabin Light");
		m.Cabin.electricConfig(10.0,24.0);
		m.Cabin.setPower(24.0,45.0);
		
		
		nCompNode = m.nPanel.initNode("Recognition");
		m.Recognition = Part.ElectricLight.new(nCompNode,"Recognition Light");
		m.Recognition.electricConfig(10.0,24.0);
		m.Recognition.setPower(24.0,60.0);
		
		
		nCompNode = m.nPanel.initNode("Map");
		m.Map = Part.ElectricLight.new(nCompNode,"Map Light");
		m.Map.electricConfig(10.0,24.0);
		m.Map.setPower(24.0,20.0);
		
		
		nCompNode = m.nPanel.initNode("Instrument");
		m.Instrument = Part.ElectricLight.new(nCompNode,"Instrument");
		m.Instrument.electricConfig(14.0,26.0);
		m.Instrument.setPower(24.0,150.0);
		
		
		nCompNode = m.nPanel.initNode("Glare");
		m.Glare = Part.ElectricLight.new(nCompNode,"Glare");
		m.Glare.electricConfig(14.0,26.0);
		m.Glare.setPower(24.0,15.0);
		
		
		nCompNode = m.nPanel.initNode("Ice");
		m.Ice = Part.ElectricLight.new(nCompNode,"Ice");
		m.Ice.electricConfig(10.0,24.0);
		m.Ice.setPower(24.0,100.0);
		
		
		nCompNode = m.nPanel.initNode("Keypad");
		m.Keypad = Part.ElectricLight.new(nCompNode,"Keypad");
		m.Keypad.electricConfig(14.0,26.0);
		m.Keypad.setPower(24.0,24.0);
		
		
		nCompNode = m.nPanel.initNode("Switches");
		m.Switches = Part.ElectricLight.new(nCompNode,"Switches");
		m.Switches.electricConfig(14.0,26.0);
		m.Switches.setPower(24.0,60.0);
		
		
		nCompNode = m.nPanel.initNode("Annunciator");
		m.Annunciator = Part.ElectricLight.new(nCompNode,"Annunciator");
		m.Annunciator.electricConfig(13.0,26.0);
		m.Annunciator.setPower(24.0,150.0);
		
		
		#m.annunciatorBus = Part.ElectricBus.new("#annunciatorBus");

		nCompNode = m.nPanel.initNode("testLightRelais");
		m.testLightRelais = Part.ElectricRelaisXPDT.new(nCompNode,"testLight Relais");
		m.testLightRelais.setPoles(1);
		
		
		
		return m;
	},
};

var lightBoard = LightBoard.new();