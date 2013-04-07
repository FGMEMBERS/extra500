#Group	Nr	Lable		Values		state		property
#Main 
#	0	BATT		on/off		1/0		extra500/SidePanel/Main/Battery
#	1	STANDBY ALT	on/off		1/0		extra500/SidePanel/Main/StandbyAlt
#	2	GEN		on/off/reset	1/0/-1		extra500/SidePanel/Main/Generator
#	3	EXT PWR		on/off		1/0		extra500/SidePanel/Main/ExternalPower
#	4	GEN TEST	on/off/trip	1/0/-1		extra500/SidePanel/Main/GeneratorTest
#	5	AVIONICS	on/off		1/0		extra500/SidePanel/Main/Avionics

#Lights
#	6	STROBE		on/off		1/0		extra500/SidePanel/Light/Strobe
#	7	NAV		on/off		1/0		extra500/SidePanel/Light/Navigation
#	8	LDG		on/off		1/0		extra500/SidePanel/Light/Landing
#	9	RECO		on/off		1/0		extra500/SidePanel/Light/Recognition
#	10	CABIN		on/off		1/0		extra500/SidePanel/Light/Cabin
#	11	MAP		on/off		1/0		extra500/SidePanel/Light/Map
#	12	INSTR		on/off		1/0		extra500/SidePanel/Light/Instrument
#	13	GLARE		on/off		1/0		extra500/SidePanel/Light/Glare
#	14	NIGHT		night/day/test	1/0/-1		extra500/SidePanel/Light/Night
#	15	ICE		on/off		1/0		extra500/SidePanel/Light/Ice

# Deicing
#	16	PROP		on/off		1/0		extra500/SidePanel/Deicing/Propeller
#	17	PITOT L		on/off/test	1/0/-1		extra500/SidePanel/Deicing/PitotL
#	18	PITOT R		on/off/test	1/0/-1		extra500/SidePanel/Deicing/PitotR
#	19	WINDSH		on/off		1/0		extra500/SidePanel/Deicing/Windshield
#	20	BOOTS		on/off		1/0		extra500/SidePanel/Deicing/Boots

#Cabin
#	21	PRESS		on/off/dump	1/0/-1		extra500/SidePanel/Cabin/Pressure
#	22	AIR CON		on/off		1/0		extra500/SidePanel/Cabin/AirCondition
#	23	VENT		hi/low/off	1/0/-1		extra500/SidePanel/Cabin/Vent
#	24	ENV AIR		on/off		1/0		extra500/SidePanel/Cabin/EnvironmentalAir
#	25	TEMP CTRL 1	warm/cool	1/0/-1		extra500/SidePanel/Cabin/TempMode
#	26	TEMP CTRL 2	auto/manual	1/0		extra500/SidePanel/Cabin/TempCtrl
#	27	TEMP CTRL 3	13.0/30.0	-1.0/1.0	extra500/SidePanel/Cabin/Temperature

#	28	EMERGENCY	on/off		1/0		extra500/SidePanel/Emergency

 
 
var SidePanel = {
	new : func{
		var m = {parents:[
			SidePanel
		]};
		
		m.nPanel = props.globals.getNode("extra500/SidePanel",1);
		
		var nCompNode = nil;
# Main		
		nParent = m.nPanel.initNode("Main");
		
		nCompNode = nParent.initNode("Battery");
		m.swtMainBattery = Part.ElectricSwitch2P.new(nCompNode,"Main Battery");
		
		nCompNode = nParent.initNode("StandbyAlt");
		m.swtMainStandbyAlt = Part.ElectricSwitch2P.new(nCompNode,"Main Standby Alternator");
		
		nCompNode = nParent.initNode("Generator");
		m.swtMainGenerator = Part.ElectricSwitch3P.new(nCompNode,"Main Generator");
		
		nCompNode = nParent.initNode("ExternalPower");
		m.swtMainExternalPower = Part.ElectricSwitch2P.new(nCompNode,"Main External Power");
		
		nCompNode = nParent.initNode("GeneratorTest");
		m.swtMainGeneratorTest = Part.ElectricSwitch3P.new(nCompNode,"Main Generator Test");
		
		nCompNode = nParent.initNode("Avionics");
		m.swtMainAvionics = Part.ElectricSwitch2P.new(nCompNode,"Main Avionics");

# Light
		nParent = m.nPanel.initNode("Light");
		
		nCompNode = nParent.initNode("Strobe");
		m.swtLightStrobe = Part.ElectricSwitch2P.new(nCompNode,"Light Strobe");
		
		nCompNode = nParent.initNode("Navigation");
		m.swtLightNavigation = Part.ElectricSwitch2P.new(nCompNode,"Light Navigation");
		
		nCompNode = nParent.initNode("Landing");
		m.swtLightLanding = Part.ElectricSwitch2P.new(nCompNode,"Light Landing");
				
		nCompNode = nParent.initNode("Recognition");
		m.swtLightRecognition = Part.ElectricSwitch2P.new(nCompNode,"Light Recognition");
		
		nCompNode = nParent.initNode("Cabin");
		m.swtLightCabin = Part.ElectricSwitch2P.new(nCompNode,"Light Cabin");
		
		nCompNode = nParent.initNode("Map");
		m.swtLightMap = Part.ElectricSwitch2P.new(nCompNode,"Light Map");
		
		nCompNode = nParent.initNode("Instrument");
		m.swtLightInstrument = Part.ElectricSwitch2P.new(nCompNode,"Light Instrument");
		
		nCompNode = nParent.initNode("Glare");
		m.swtLightGlare = Part.ElectricSwitch2P.new(nCompNode,"Light Glare");
		
		nCompNode = nParent.initNode("Night");
		m.swtLightNight = Part.ElectricSwitch3P.new(nCompNode,"Light Night");
		
		nCompNode = nParent.initNode("Ice");
		m.swtLightIce = Part.ElectricSwitch2P.new(nCompNode,"Light Ice");
		
# Deicing
		nParent = m.nPanel.initNode("Deicing");
		
		nCompNode = nParent.initNode("Propeller");
		m.swtDeicingPropeller = Part.ElectricSwitch2P.new(nCompNode,"Deicing Propeller");
		
		nCompNode = nParent.initNode("PitotL");
		m.swtDeicingPitotL = Part.ElectricSwitch3P.new(nCompNode,"Deicing Pitot Left");
		
		nCompNode = nParent.initNode("PitotR");
		m.swtDeicingPitotR = Part.ElectricSwitch3P.new(nCompNode,"Deicing Pitot Right");
		
		nCompNode = nParent.initNode("Windshield");
		m.swtDeicingWindshield = Part.ElectricSwitch2P.new(nCompNode,"Deicing Windshield");
		
		nCompNode = nParent.initNode("Boots");
		m.swtDeicingBoots = Part.ElectricSwitch2P.new(nCompNode,"Deicing Boots");
	
# Cabin
		nParent = m.nPanel.initNode("Cabin");
		
		nCompNode = nParent.initNode("Pressure");
		m.swtCabinPressure = Part.ElectricSwitch3P.new(nCompNode,"Cabin Pressure Controller");
		
		nCompNode = nParent.initNode("AirCondition");
		m.swtCabinAirCondition = Part.ElectricSwitch2P.new(nCompNode,"Cabin Air Condition");
		
		nCompNode = nParent.initNode("Vent");
		m.swtCabinVent = Part.ElectricSwitch3P.new(nCompNode,"Cabin Vent");
		
		nCompNode = nParent.initNode("EnvironmentalAir");
		m.swtCabinEnvironmentalAir = Part.ElectricSwitch2P.new(nCompNode,"Cabin Environmental Air");
		
		nCompNode = nParent.initNode("TempMode");
		m.swtCabinTempMode = Part.ElectricSwitch3P.new(nCompNode,"Cabin Temperature Controller Mode");
		
		nCompNode = nParent.initNode("TempCtrl");
		m.swtCabinTempCtrl = Part.ElectricSwitch2P.new(nCompNode,"Cabin Temperature Controller");
		
		nCompNode = nParent.initNode("Temperature");
		m.swtCabinTemperature = Part.ElectricDimmer.new(nCompNode,"Cabin Temperature","DOUBLE",0.0,1.0,0.05,0.5);
		
# Emergency	
		
		nCompNode = nParent.initNode("Emergency");
		m.swtEmergency = Part.ElectricSwitch2P.new(nCompNode,"Emergency");
		
		
		return m;
	},
	plugElectric : func(){
		global.fnAnnounce("debug","SidePanel.plugElectric() ...");

		me.swtEmergency.In.plug(oElectric.GND);
		
		me.swtMainBattery.In.plug(me.swtEmergency.Off);
		
		me.swtLightLanding.In.plug(oCircuitBreakerPanel.cbLandingLight.Out);
		me.swtLightInstrument.In.plug(oCircuitBreakerPanel.cbInstrumentLight.Out);
		
		me.swtLightIce.In.plug(oCircuitBreakerPanel.cbIceLight.Out);
		me.swtLightGlare.In.plug(oCircuitBreakerPanel.cbGlareLight.Out);
		me.swtLightStrobe.In.plug(oCircuitBreakerPanel.cbStrobeLight.Out);
		
		
		
	},
	# can only used when Module extra500 is completly loaded.
	# All callback functions must called from a global namespace
	initUI : func (){
		
# 		UI.register("", 		func{extra500.oSidePanel..toggle(); } 	);
# 		UI.register(" on", 	func{extra500.oSidePanel..on(); } 		);
# 		UI.register(" off", 	func{extra500.oSidePanel..off(); } 	);
# 		
# 		UI.register(" <", 	func{extra500.oSidePanel..left(); } 		);
# 		UI.register(" >", 	func{extra500.oSidePanel..right(); } 		);
# 		UI.register(" on", 	func{extra500.oSidePanel..setValue(1); } 	);
# 		UI.register(" off", 	func{extra500.oSidePanel..setValue(0); } 	);
# 		UI.register(" test", 	func{extra500.oSidePanel..setValue(-1); } 	);
		
		
	# Main
		UI.register("Main Battery", 		func{extra500.oSidePanel.swtMainBattery.toggle(); } 	);
		UI.register("Main Battery on", 		func{extra500.oSidePanel.swtMainBattery.on(); } 		);
		UI.register("Main Battery off", 	func{extra500.oSidePanel.swtMainBattery.off(); } 	);
		
		UI.register("Main Standby Alternator", 		func{extra500.oSidePanel.swtMainStandbyAlt.toggle(); } 	);
		UI.register("Main Standby Alternator on", 	func{extra500.oSidePanel.swtMainStandbyAlt.on(); } 		);
		UI.register("Main Standby Alternator off", 	func{extra500.oSidePanel.swtMainStandbyAlt.off(); } 	);
		
		UI.register("Main Generator <", 	func{extra500.oSidePanel.swtMainGenerator.left(); } 		);
		UI.register("Main Generator >", 	func{extra500.oSidePanel.swtMainGenerator.right(); } 		);
		UI.register("Main Generator on", 	func{extra500.oSidePanel.swtMainGenerator.setValue(1); } 	);
		UI.register("Main Generator off", 	func{extra500.oSidePanel.swtMainGenerator.setValue(0); } 	);
		UI.register("Main Generator reset", 	func{extra500.oSidePanel.swtMainGenerator.setValue(-1); } 	);
		
		UI.register("Main External Power", 	func{extra500.oSidePanel.swtMainExternalPower.toggle(); } 	);
		UI.register("Main External Power on", 	func{extra500.oSidePanel.swtMainExternalPower.on(); } 		);
		UI.register("Main External Power off", 	func{extra500.oSidePanel.swtMainExternalPower.off(); } 		);
		
		UI.register("Main Generator Test <", 	func{extra500.oSidePanel.swtMainGeneratorTest.left(); } 		);
		UI.register("Main Generator Test >", 	func{extra500.oSidePanel.swtMainGeneratorTest.right(); } 	);
		UI.register("Main Generator Test on", 	func{extra500.oSidePanel.swtMainGeneratorTest.setValue(1); } 	);
		UI.register("Main Generator Test off", 	func{extra500.oSidePanel.swtMainGeneratorTest.setValue(0); } 	);
		UI.register("Main Generator Test trip",func{extra500.oSidePanel.swtMainGeneratorTest.setValue(-1); } 	);
		
		
		UI.register("Main Avionics", 		func{extra500.oSidePanel.swtMainAvionics.toggle(); } 		);
		UI.register("Main Avionics on", 	func{extra500.oSidePanel.swtMainAvionics.on(); } 		);
		UI.register("Main Avionics off", 	func{extra500.oSidePanel.swtMainAvionics.off(); } 		);
		
	# Light
	
		UI.register("Light Strobe", 		func{extra500.oSidePanel.swtLightStrobe.toggle(); } 	);
		UI.register("Light Strobe on", 		func{extra500.oSidePanel.swtLightStrobe.on(); } 		);
		UI.register("Light Strobe off", 	func{extra500.oSidePanel.swtLightStrobe.off(); } 	);
		
		UI.register("Light Navigation", 	func{extra500.oSidePanel.swtLightNavigation.toggle(); } 	);
		UI.register("Light Navigation on", 	func{extra500.oSidePanel.swtLightNavigation.on(); } 	);
		UI.register("Light Navigation off", 	func{extra500.oSidePanel.swtLightNavigation.off(); } 	);
		
		UI.register("Light Landing", 		func{extra500.oSidePanel.swtLightLanding.toggle(); } 	);
		UI.register("Light Landing on", 	func{extra500.oSidePanel.swtLightLanding.on(); } 	);
		UI.register("Light Landing off", 	func{extra500.oSidePanel.swtLightLanding.off(); } 	);
		
		UI.register("Light Recognition", 	func{extra500.oSidePanel.swtLightRecognition.toggle(); } );
		UI.register("Light Recognition on", 	func{extra500.oSidePanel.swtLightRecognition.on(); } 	);
		UI.register("Light Recognition off", 	func{extra500.oSidePanel.swtLightRecognition.off(); } 	);
		
		UI.register("Light Cabin", 		func{extra500.oSidePanel.swtLightCabin.toggle(); } 	);
		UI.register("Light Cabin on", 		func{extra500.oSidePanel.swtLightCabin.on(); } 		);
		UI.register("Light Cabin off", 		func{extra500.oSidePanel.swtLightCabin.off(); } 		);
		
		UI.register("Light Map", 		func{extra500.oSidePanel.swtLightMap.toggle(); } 	);
		UI.register("Light Map on", 		func{extra500.oSidePanel.swtLightMap.on(); } 		);
		UI.register("Light Map off", 		func{extra500.oSidePanel.swtLightMap.off(); } 		);
		
		UI.register("Light Instrument", 	func{extra500.oSidePanel.swtLightInstrument.toggle(); } 	);
		UI.register("Light Instrument on", 	func{extra500.oSidePanel.swtLightInstrument.on(); } 		);
		UI.register("Light Instrument off", 	func{extra500.oSidePanel.swtLightInstrument.off(); } 		);
		
		UI.register("Light Glare", 		func{extra500.oSidePanel.swtLightGlare.toggle(); } 	);
		UI.register("Light Glare on", 		func{extra500.oSidePanel.swtLightGlare.on(); } 		);
		UI.register("Light Glare off", 		func{extra500.oSidePanel.swtLightGlare.off(); } 		);
		
		UI.register("Night <", 		func{extra500.oSidePanel.swtLightNight.left(); } 	);
		UI.register("Night >", 		func{extra500.oSidePanel.swtLightNight.right(); } 	);
		UI.register("Night night", 	func{extra500.oSidePanel.swtLightNight.setValue(1); } );
		UI.register("Night day", 	func{extra500.oSidePanel.swtLightNight.setValue(0); } );
		UI.register("Night test", 	func{extra500.oSidePanel.swtLightNight.setValue(-1); });
		
		UI.register("Light Ice", 		func{extra500.oSidePanel.swtLightIce.toggle(); } 	);
		UI.register("Light Ice on", 		func{extra500.oSidePanel.swtLightIce.on(); } 		);
		UI.register("Light Ice off", 		func{extra500.oSidePanel.swtLightIce.off(); } 		);
		
	# Deicing
		
		UI.register("Deicing Propeller", 	func{extra500.oSidePanel.swtDeicingPropeller.toggle(); } );
		UI.register("Deicing Propeller on", 	func{extra500.oSidePanel.swtDeicingPropeller.on(); } 	);
		UI.register("Deicing Propeller off", 	func{extra500.oSidePanel.swtDeicingPropeller.off(); } 	);
		
		UI.register("Deicing Pitot Left <", 	func{extra500.oSidePanel.swtDeicingPitotL.left(); } 	);
		UI.register("Deicing Pitot Left >", 	func{extra500.oSidePanel.swtDeicingPitotL.right(); } 	);
		UI.register("Deicing Pitot Left on", 	func{extra500.oSidePanel.swtDeicingPitotL.setValue(1); } );
		UI.register("Deicing Pitot Left off", 	func{extra500.oSidePanel.swtDeicingPitotL.setValue(0); } );
		UI.register("Deicing Pitot Left test", 	func{extra500.oSidePanel.swtDeicingPitotL.setValue(-1); });
		
		UI.register("Deicing Pitot Right <", 	func{extra500.oSidePanel.swtDeicingPitotR.left(); } 	);
		UI.register("Deicing Pitot Right >", 	func{extra500.oSidePanel.swtDeicingPitotR.right(); } 	);
		UI.register("Deicing Pitot Right on", 	func{extra500.oSidePanel.swtDeicingPitotR.setValue(1); } );
		UI.register("Deicing Pitot Right off", 	func{extra500.oSidePanel.swtDeicingPitotR.setValue(0); } );
		UI.register("Deicing Pitot Right test", func{extra500.oSidePanel.swtDeicingPitotR.setValue(-1); });
		
		UI.register("Deicing Windshield", 	func{extra500.oSidePanel.swtDeicingWindshield.toggle(); });
		UI.register("Deicing Windshield on", 	func{extra500.oSidePanel.swtDeicingWindshield.on(); } 	);
		UI.register("Deicing Windshield off", 	func{extra500.oSidePanel.swtDeicingWindshield.off(); } 	);
		
		UI.register("Deicing Boots", 		func{extra500.oSidePanel.swtDeicingBoots.toggle(); } 	);
		UI.register("Deicing Boots on", 	func{extra500.oSidePanel.swtDeicingBoots.on(); } 	);
		UI.register("Deicing Boots off", 	func{extra500.oSidePanel.swtDeicingBoots.off(); } 	);
		
	# Cabin
		
		UI.register("Cabin Pressure Controller <", 		func{extra500.oSidePanel.swtCabinPressure.left(); } 		);
		UI.register("Cabin Pressure Controller >", 		func{extra500.oSidePanel.swtCabinPressure.right(); } 		);
		UI.register("Cabin Pressure Controller on", 		func{extra500.oSidePanel.swtCabinPressure.setValue(1); } 	);
		UI.register("Cabin Pressure Controller off", 		func{extra500.oSidePanel.swtCabinPressure.setValue(0); } 	);
		UI.register("Cabin Pressure Controller dump", 		func{extra500.oSidePanel.swtCabinPressure.setValue(-1); } 	);
				
		UI.register("Cabin Air Condition", 			func{extra500.oSidePanel.swtCabinAirCondition.toggle(); } 	);
		UI.register("Cabin Air Condition on", 			func{extra500.oSidePanel.swtCabinAirCondition.on(); } 		);
		UI.register("Cabin Air Condition off", 			func{extra500.oSidePanel.swtCabinAirCondition.off(); } 		);
		
		UI.register("Cabin Vent <", 				func{extra500.oSidePanel.swtCabinVent.left(); } 		);
		UI.register("Cabin Vent >", 				func{extra500.oSidePanel.swtCabinVent.right(); } 		);
		UI.register("Cabin Vent high", 				func{extra500.oSidePanel.swtCabinVent.setValue(1); } 	);
		UI.register("Cabin Vent low", 				func{extra500.oSidePanel.swtCabinVent.setValue(0); } 	);
		UI.register("Cabin Vent off", 				func{extra500.oSidePanel.swtCabinVent.setValue(-1); } 	);
		
		UI.register("Cabin Environmental Air", 			func{extra500.oSidePanel.swtCabinEnvironmentalAir.toggle(); } 		);
		UI.register("Cabin Environmental Air on", 		func{extra500.oSidePanel.swtCabinEnvironmentalAir.on(); } 		);
		UI.register("Cabin Environmental Air off", 		func{extra500.oSidePanel.swtCabinEnvironmentalAir.off(); } 		);
		
		UI.register("Cabin Temperature Controller Mode <", 	func{extra500.oSidePanel.swtCabinTempMode.left(); } 		);
		UI.register("Cabin Temperature Controller Mode >", 	func{extra500.oSidePanel.swtCabinTempMode.right(); } 		);
		UI.register("Cabin Temperature Controller Mode warm", 	func{extra500.oSidePanel.swtCabinTempMode.setValue(1); } 	);
		UI.register("Cabin Temperature Controller Mode auto", 	func{extra500.oSidePanel.swtCabinTempMode.setValue(0); } 	);
		UI.register("Cabin Temperature Controller Mode cool", 	func{extra500.oSidePanel.swtCabinTempMode.setValue(-1); } 	);
		
		UI.register("Cabin Temperature Controller", 		func{extra500.oSidePanel.swtCabinTempCtrl.toggle(); } 		);
		UI.register("Cabin Temperature Controller on", 		func{extra500.oSidePanel.swtCabinTempCtrl.on(); } 		);
		UI.register("Cabin Temperature Controller off", 	func{extra500.oSidePanel.swtCabinTempCtrl.off(); } 		);
		
		UI.register("Cabin Temperature <", 			func{extra500.oSidePanel.swtCabinTemperature.left(); } 		);
		UI.register("Cabin Temperature >", 			func{extra500.oSidePanel.swtCabinTemperature.right(); } 		);
		UI.register("Cabin Temperature =", 			func(v=0){extra500.oSidePanel.swtCabinTemperature.setValue(v); } 	);
		UI.register("Cabin Temperature +=", 			func(v=0){extra500.oSidePanel.swtCabinTemperature.adjust(v); } 	);
		
	# Emergency
		
		UI.register("Emergency", 	func{extra500.oSidePanel.swtEmergency.toggle(); } 		);
		UI.register("Emergency on", 	func{extra500.oSidePanel.swtEmergency.on(); } 		);
		UI.register("Emergency off", 	func{extra500.oSidePanel.swtEmergency.off(); } 		);
		
	}
};

var oSidePanel = SidePanel.new();

