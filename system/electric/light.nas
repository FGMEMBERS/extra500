var LightBoard = {
	new : func{
		var m = {parents:[
			LightBoard
		]};
		
		m.nRoot = props.globals.getNode("extra500/Light",1);
	#outside
		nCompNode = m.nRoot.initNode("Strobe");
		m.Strobe = Part.ElectricLight.new(nCompNode,"Strobe Light");
		m.Strobe.electricConfig(10.0,24.0);
		m.Strobe.setPower(24.0,30.0);
		
		nCompNode = m.nRoot.initNode("Navigation");
		m.Navigation = Part.ElectricLight.new(nCompNode,"Navigation Light");
		m.Navigation.electricConfig(10.0,24.0);
		m.Navigation.setPower(24.0,90.0);
		
		nCompNode = m.nRoot.initNode("Landing");
		m.Landing = Part.ElectricLight.new(nCompNode,"Landing Light");
		m.Landing.electricConfig(10.0,24.0);
		m.Landing.setPower(24.0,500.0);
		
		nCompNode = m.nRoot.initNode("Recognition");
		m.Recognition = Part.ElectricLight.new(nCompNode,"Recognition Light");
		m.Recognition.electricConfig(10.0,24.0);
		m.Recognition.setPower(24.0,60.0);
		
		nCompNode = m.nRoot.initNode("Ice");
		m.Ice = Part.ElectricLight.new(nCompNode,"Ice");
		m.Ice.electricConfig(10.0,24.0);
		m.Ice.setPower(24.0,100.0);
		
		
		
		
	#cockpit
		nCompNode = m.nRoot.initNode("Cabin");
		m.Cabin = Part.ElectricLight.new(nCompNode,"Cabin Light");
		m.Cabin.electricConfig(10.0,24.0);
		m.Cabin.setPower(24.0,45.0);
		
		nCompNode = m.nRoot.initNode("Map");
		m.Map = Part.ElectricLight.new(nCompNode,"Map Light");
		m.Map.electricConfig(10.0,24.0);
		m.Map.setPower(24.0,20.0);
		
		
		nCompNode = m.nRoot.initNode("Instrument");
		m.Instrument = Part.ElectricLight.new(nCompNode,"Instrument");
		m.Instrument.electricConfig(14.0,26.0);
		m.Instrument.setPower(24.0,150.0);
		
		
		nCompNode = m.nRoot.initNode("Glare");
		m.Glare = Part.ElectricLight.new(nCompNode,"Glare");
		m.Glare.electricConfig(14.0,26.0);
		m.Glare.setPower(24.0,15.0);
		
		 		
		nCompNode = m.nRoot.initNode("Keypad");
		m.Keypad = Part.ElectricLight.new(nCompNode,"Keypad");
		m.Keypad.electricConfig(14.0,26.0);
		m.Keypad.setPower(24.0,24.0);
				
		nCompNode = m.nRoot.initNode("Switches");
		m.Switches = Part.ElectricLight.new(nCompNode,"Switches");
		m.Switches.electricConfig(14.0,26.0);
		m.Switches.setPower(24.0,60.0);
		
	#indication Lights
		
		nCompNode = m.nRoot.initNode("FlapTransition");
		m.FlapTransition = Part.ElectricLight.new(nCompNode,"FlapTransition");
		m.FlapTransition.electricConfig(12.0,26.0);
		m.FlapTransition.setPower(24.0,0.5);
		
		nCompNode = m.nRoot.initNode("Flap15");
		m.Flap15 = Part.ElectricLight.new(nCompNode,"Flap15");
		m.Flap15.electricConfig(12.0,26.0);
		m.Flap15.setPower(24.0,0.5);
		
		nCompNode = m.nRoot.initNode("Flap30");
		m.Flap30 = Part.ElectricLight.new(nCompNode,"Flap30");
		m.Flap30.electricConfig(12.0,26.0);
		m.Flap30.setPower(24.0,0.5);
		
		nCompNode = m.nRoot.initNode("GearNose");
		m.GearNose = Part.ElectricLight.new(nCompNode,"GearNose");
		m.GearNose.electricConfig(12.0,26.0);
		m.GearNose.setPower(24.0,0.5);
		
		nCompNode = m.nRoot.initNode("GearLeft");
		m.GearLeft = Part.ElectricLight.new(nCompNode,"GearLeft");
		m.GearLeft.electricConfig(12.0,26.0);
		m.GearLeft.setPower(24.0,0.5);
		
		nCompNode = m.nRoot.initNode("GearRight");
		m.GearRight = Part.ElectricLight.new(nCompNode,"GearRight");
		m.GearRight.electricConfig(12.0,26.0);
		m.GearRight.setPower(24.0,0.5);
				
		nCompNode = m.nRoot.initNode("DMEHold");
		m.DMEHold = Part.ElectricLight.new(nCompNode,"DME-Hold");
		m.DMEHold.electricConfig(12.0,26.0);
		m.DMEHold.setPower(24.0,0.5);
		
		
	#Relais
		nCompNode = m.nRoot.initNode("DayNightRelais");
		m.dayNightRelais = Part.ElectricRelaisXPDT.new(nCompNode,"Day/Night Relais");
		m.dayNightRelais.setPoles(5);
		# 1 KEYPAD
		# 2 GLARE
		# 3 INSTR
		# 4 SWITCHES
		# 5 ANNUNCIATOR
		
		nCompNode = m.nRoot.initNode("TestLightRelais");
		m.testLightRelais = Part.ElectricRelaisXPDT.new(nCompNode,"Test Light Relais");
		m.testLightRelais.setPoles(9);
		# 1 ANNUNCIATOR
		# 2 FlapTransition
		# 3 Flap15
		# 4 Flap30
		# 5 GearNose
		# 6 GearLeft
		# 7 GearRight
		# 8 DME

	#Buses
		m.GNDBus = Part.ElectricBusDiode.new("GNDBus");
		m.annuciatorDimBus = Part.ElectricBus.new("AnnunciatorDimBus");
		m.instrumentDimBus = Part.ElectricBus.new("InstrumentDimBus");
	
		return m;
	},
	plugElectric : func(){
				
		me.annuciatorDimBus.plug(me.dayNightRelais.P51);
		me.annuciatorDimBus.plug(me.FlapTransition.Plus);
		me.annuciatorDimBus.plug(me.Flap15.Plus);
		me.annuciatorDimBus.plug(me.Flap30.Plus);
		me.annuciatorDimBus.plug(me.GearNose.Plus);
		me.annuciatorDimBus.plug(me.GearLeft.Plus);
		me.annuciatorDimBus.plug(me.GearRight.Plus);
		me.annuciatorDimBus.plug(me.DMEHold.Plus);
		
		me.FlapTransition.Minus.plug(	me.testLightRelais.P21);
		me.Flap15.Minus.plug(		me.testLightRelais.P31);
		me.Flap30.Minus.plug(		me.testLightRelais.P41);
		me.GearNose.Minus.plug(		me.testLightRelais.P51);
		me.GearLeft.Minus.plug(		me.testLightRelais.P61);
		me.GearRight.Minus.plug(	me.testLightRelais.P71);
		me.DMEHold.Minus.plug(		me.testLightRelais.P81);
		
		me.GNDBus.plug(	me.testLightRelais.P24);
		me.GNDBus.plug(	me.testLightRelais.P34);
		me.GNDBus.plug(	me.testLightRelais.P44);
		me.GNDBus.plug(	me.testLightRelais.P54);
		me.GNDBus.plug(	me.testLightRelais.P64);
		me.GNDBus.plug(	me.testLightRelais.P74);
		me.GNDBus.plug(	me.testLightRelais.P84);
		
		
		me.GNDBus.plug(	me.Switches.Minus);
		me.GNDBus.plug(	me.Instrument.Minus);
		me.GNDBus.plug(	me.Glare.Minus);
		me.GNDBus.plug(	me.Keypad.Minus);
		me.GNDBus.plug(	me.Ice.Minus);
		me.GNDBus.plug(	me.Map.Minus);
		me.GNDBus.plug(	me.Recognition.Minus);
		me.GNDBus.plug(	me.Cabin.Minus);
		me.GNDBus.plug(	me.Landing.Minus);
		me.GNDBus.plug(	me.Navigation.Minus);
		me.GNDBus.plug(	me.Strobe.Minus);
		
	},
};

var lightBoard = LightBoard.new();