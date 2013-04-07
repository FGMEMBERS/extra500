var LightBoard = {
	new : func{
		var m = {parents:[
			LightBoard
		]};
		
		m.nPanel = props.globals.getNode("extra500/Light",1);
		
		
		nCompNode = m.nPanel.initNode("Landing");
		m.Landing = Part.ElectricLight.new(nCompNode,"Landing Light");
		m.Landing.electricConfig(12.0,26.0,500.0);
		
		nCompNode = m.nPanel.initNode("Instrument");
		m.Instrument = Part.ElectricLight.new(nCompNode,"Instrument");
		m.Instrument.electricConfig(12.0,26.0,50.0);
		
		nCompNode = m.nPanel.initNode("Ice");
		m.Ice = Part.ElectricLight.new(nCompNode,"Ice");
		m.Ice.electricConfig(12.0,26.0,100.0);
		
		nCompNode = m.nPanel.initNode("Glare");
		m.Glare = Part.ElectricLight.new(nCompNode,"Glare");
		m.Glare.electricConfig(12.0,26.0,25.0);
		
		nCompNode = m.nPanel.initNode("Strobe");
		m.Strobe = Part.ElectricLight.new(nCompNode,"Strobe");
		m.Strobe.electricConfig(12.0,26.0,30.0);
		
		
		return m;
	},
	plugElectric : func(){
		global.fnAnnounce("debug","LightBoard.plugElectric() ...");

		me.Landing.Plus.plug(oSidePanel.swtLightLanding.On);
		me.Landing.Minus.plug(oElectric.GND);
		
		me.Instrument.Plus.plug(oSidePanel.swtLightInstrument.On);
		me.Instrument.Minus.plug(oElectric.GND);
		
		me.Ice.Plus.plug(oSidePanel.swtLightIce.On);
		me.Ice.Minus.plug(oElectric.GND);
		
		me.Glare.Plus.plug(oSidePanel.swtLightGlare.On);
		me.Glare.Minus.plug(oElectric.GND);
		
		me.Strobe.Plus.plug(oSidePanel.swtLightStrobe.On);
		me.Strobe.Minus.plug(oElectric.GND);
		
			
	},
};

var oLight = LightBoard.new();