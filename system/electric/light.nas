var LightBoard = {
	new : func{
		var m = {parents:[
			LightBoard
		]};
		
		m.nPanel = props.globals.getNode("extra500/Light",1);
		
		nCompNode = m.nPanel.initNode("Strobe");
		m.Strobe = Part.ElectricLight.new(nCompNode,"Strobe Light");
		m.Strobe.electricConfig(12.0,26.0,30.0);
		
		nCompNode = m.nPanel.initNode("Navigation");
		m.Navigation = Part.ElectricLight.new(nCompNode,"Navigation Light");
		m.Navigation.electricConfig(12.0,26.0,90.0);
		
		nCompNode = m.nPanel.initNode("Landing");
		m.Landing = Part.ElectricLight.new(nCompNode,"Landing Light");
		m.Landing.electricConfig(12.0,26.0,500.0);
		
		nCompNode = m.nPanel.initNode("Cabin");
		m.Cabin = Part.ElectricLight.new(nCompNode,"Cabin Light");
		m.Cabin.electricConfig(12.0,26.0,45.0);
		
		nCompNode = m.nPanel.initNode("Map");
		m.Map = Part.ElectricLight.new(nCompNode,"Map Light");
		m.Map.electricConfig(12.0,26.0,20.0);
		
		nCompNode = m.nPanel.initNode("Instrument");
		m.Instrument = Part.ElectricLight.new(nCompNode,"Instrument");
		m.Instrument.electricConfig(12.0,26.0,50.0);
		
		nCompNode = m.nPanel.initNode("Glare");
		m.Glare = Part.ElectricLight.new(nCompNode,"Glare");
		m.Glare.electricConfig(12.0,26.0,25.0);
		
		nCompNode = m.nPanel.initNode("Ice");
		m.Ice = Part.ElectricLight.new(nCompNode,"Ice");
		m.Ice.electricConfig(12.0,26.0,100.0);
		
		
		
		
		return m;
	},
	plugElectric : func(){
		global.fnAnnounce("debug","LightBoard.plugElectric() ...");

		me.Strobe.Plus.plug(oSidePanel.swtLightStrobe.On);
		me.Strobe.Minus.plug(oElectric.GND);
		
		me.Navigation.Plus.plug(oSidePanel.swtLightNavigation.On);
		me.Navigation.Minus.plug(oElectric.GND);
		
		me.Landing.Plus.plug(oSidePanel.swtLightLanding.On);
		me.Landing.Minus.plug(oElectric.GND);
		
		me.Cabin.Plus.plug(oSidePanel.swtLightCabin.On);
		me.Cabin.Minus.plug(oElectric.GND);
		
		me.Map.Plus.plug(oSidePanel.swtLightMap.On);
		me.Map.Minus.plug(oElectric.GND);
		
		me.Instrument.Plus.plug(oCircuitBreakerPanel.cbInstrumentLight.Out);
		oSidePanel.testBus.plug(me.Instrument.Minus);
		
		
		me.Glare.Plus.plug(oSidePanel.swtLightGlare.On);
		me.Glare.Minus.plug(oElectric.GND);
		
		me.Ice.Plus.plug(oSidePanel.swtLightIce.On);
		me.Ice.Minus.plug(oElectric.GND);
		
		
			
	},
};

var oLight = LightBoard.new();