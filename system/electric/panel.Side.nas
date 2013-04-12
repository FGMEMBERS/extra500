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
		m.MainBattery = Part.ElectricSwitchDT.new(nCompNode,"Main Battery");
		m.MainBattery.setPoles(2);
		
		nCompNode = nParent.initNode("StandbyAlt");
		m.MainStandbyAlt = Part.ElectricSwitchDT.new(nCompNode,"Main Standby Alternator");
		m.MainStandbyAlt.setPoles(2);
		
		nCompNode = nParent.initNode("Generator");
		m.MainGenerator = Part.ElectricSwitchCO.new(nCompNode,"Main Generator");
		m.MainGenerator.setPoles(1);
		
		nCompNode = nParent.initNode("ExternalPower");
		m.MainExternalPower = Part.ElectricSwitchDT.new(nCompNode,"Main External Power");
		m.MainExternalPower.setPoles(1);
		
		nCompNode = nParent.initNode("GeneratorTest");
		m.MainGeneratorTest = Part.ElectricSwitchCO.new(nCompNode,"Main Generator Test");
		m.MainGeneratorTest.setPoles(1);
		
		nCompNode = nParent.initNode("Avionics");
		m.MainAvionics = Part.ElectricSwitchDT.new(nCompNode,"Main Avionics");
		m.MainAvionics.setPoles(1);
		
# Light
		nParent = m.nPanel.initNode("Light");
		
		nCompNode = nParent.initNode("Strobe");
		m.LightStrobe = Part.ElectricSwitchDT.new(nCompNode,"Light Strobe");
		m.LightStrobe.setPoles(1);
		
		nCompNode = nParent.initNode("Navigation");
		m.LightNavigation = Part.ElectricSwitchDT.new(nCompNode,"Light Navigation");
		m.LightNavigation.setPoles(1);
		
		nCompNode = nParent.initNode("Landing");
		m.LightLanding = Part.ElectricSwitchDT.new(nCompNode,"Light Landing");
		m.LightLanding.setPoles(1);
				
		nCompNode = nParent.initNode("Recognition");
		m.LightRecognition = Part.ElectricSwitchDT.new(nCompNode,"Light Recognition");
		m.LightRecognition.setPoles(1);
		
		nCompNode = nParent.initNode("Cabin");
		m.LightCabin = Part.ElectricSwitchDT.new(nCompNode,"Light Cabin");
		m.LightCabin.setPoles(1);
		
		nCompNode = nParent.initNode("Map");
		m.LightMap = Part.ElectricSwitchDT.new(nCompNode,"Light Map");
		m.LightMap.setPoles(1);
		
		nCompNode = nParent.initNode("Instrument");
		m.LightInstrument = Part.ElectricSwitchDT.new(nCompNode,"Light Instrument");
		m.LightInstrument.setPoles(1);
		
		nCompNode = nParent.initNode("Glare");
		m.LightGlare = Part.ElectricSwitchDT.new(nCompNode,"Light Glare");
		m.LightGlare.setPoles(1);
		
		nCompNode = nParent.initNode("Night");
		m.LightNight = Part.ElectricSwitchCO.new(nCompNode,"Light Night");
		m.LightNight.setPoles(2);
		
		nCompNode = nParent.initNode("Ice");
		m.LightIce = Part.ElectricSwitchDT.new(nCompNode,"Light Ice");
		m.LightIce.setPoles(1);
		
# Deicing
		nParent = m.nPanel.initNode("Deicing");
		
		nCompNode = nParent.initNode("Propeller");
		m.DeicingPropeller = Part.ElectricSwitchDT.new(nCompNode,"Deicing Propeller");
		m.DeicingPropeller.setPoles(1);
		
		nCompNode = nParent.initNode("PitotL");
		m.DeicingPitotL = Part.ElectricSwitchCO.new(nCompNode,"Deicing Pitot Left");
		m.DeicingPitotL.setPoles(1);
		
		nCompNode = nParent.initNode("PitotR");
		m.DeicingPitotR = Part.ElectricSwitchCO.new(nCompNode,"Deicing Pitot Right");
		m.DeicingPitotR.setPoles(1);
		
		nCompNode = nParent.initNode("Windshield");
		m.DeicingWindshield = Part.ElectricSwitchDT.new(nCompNode,"Deicing Windshield");
		m.DeicingWindshield.setPoles(1);
		
		nCompNode = nParent.initNode("Boots");
		m.DeicingBoots = Part.ElectricSwitchDT.new(nCompNode,"Deicing Boots");
		m.DeicingBoots.setPoles(1);
		
# Cabin
		nParent = m.nPanel.initNode("Cabin");
		
		nCompNode = nParent.initNode("Pressure");
		m.CabinPressure = Part.ElectricSwitchCO.new(nCompNode,"Cabin Pressure Controller");
		m.CabinPressure.setPoles(1);
		
		nCompNode = nParent.initNode("AirCondition");
		m.CabinAirCondition = Part.ElectricSwitchDT.new(nCompNode,"Cabin Air Condition");
		m.CabinAirCondition.setPoles(1);
		
		nCompNode = nParent.initNode("Vent");
		m.CabinVent = Part.ElectricSwitchCO.new(nCompNode,"Cabin Vent");
		m.CabinVent.setPoles(1);
		
		nCompNode = nParent.initNode("EnvironmentalAir");
		m.CabinEnvironmentalAir = Part.ElectricSwitchDT.new(nCompNode,"Cabin Environmental Air");
		m.CabinEnvironmentalAir.setPoles(1);
		
		nCompNode = nParent.initNode("TempMode");
		m.CabinTempMode = Part.ElectricSwitchCO.new(nCompNode,"Cabin Temperature Controller Mode");
		m.CabinTempMode.setPoles(1);
		
		nCompNode = nParent.initNode("TempCtrl");
		m.CabinTempCtrl = Part.ElectricSwitchDT.new(nCompNode,"Cabin Temperature Controller");
		m.CabinTempCtrl.setPoles(1);
		
		nCompNode = nParent.initNode("Temperature");
		m.CabinTemperature = Part.ElectricDimmer.new(nCompNode,"Cabin Temperature","DOUBLE",0.0,1.0,0.05,0.5);
		
# Emergency	
		
		nCompNode = m.nPanel.initNode("Emergency");
		m.Emergency = Part.ElectricSwitchDT.new(nCompNode,"Emergency");
		m.Emergency.setPoles(1);
		
		
		#m.nightBus = Part.ElectricBus.new("NightBus");
		#m.dayBus = Part.ElectricBus.new("DayBus");
		#m.testBus = Part.ElectricBus.new("TestBus");
#Buses
		m.instrumentBus = Part.ElectricBus.new("instrumentBus");
		m.testLightBus = Part.ElectricBus.new("testLight");
				
		return m;
	},
	# can only used when Module extra500 is completly loaded.
	# All callback functions must called from a global namespace
	initUI : func (){
		
# 		UI.register("", 		func{extra500.sidePanel..toggle(); } 	);
# 		UI.register(" on", 	func{extra500.sidePanel..on(); } 		);
# 		UI.register(" off", 	func{extra500.sidePanel..off(); } 	);
# 		
# 		UI.register(" <", 	func{extra500.sidePanel..left(); } 		);
# 		UI.register(" >", 	func{extra500.sidePanel..right(); } 		);
# 		UI.register(" on", 	func{extra500.sidePanel..setValue(1); } 	);
# 		UI.register(" off", 	func{extra500.sidePanel..setValue(0); } 	);
# 		UI.register(" test", 	func{extra500.sidePanel..setValue(-1); } 	);
		
		
	# Main
		UI.register("Main Battery", 		func{extra500.sidePanel.MainBattery.toggle(); } 	);
		UI.register("Main Battery on", 		func{extra500.sidePanel.MainBattery.on(); } 		);
		UI.register("Main Battery off", 	func{extra500.sidePanel.MainBattery.off(); } 	);
		
		UI.register("Main Standby Alternator", 		func{extra500.sidePanel.MainStandbyAlt.toggle(); } 	);
		UI.register("Main Standby Alternator on", 	func{extra500.sidePanel.MainStandbyAlt.on(); } 		);
		UI.register("Main Standby Alternator off", 	func{extra500.sidePanel.MainStandbyAlt.off(); } 	);
		
		UI.register("Main Generator <", 	func{extra500.sidePanel.MainGenerator.left(); } 		);
		UI.register("Main Generator >", 	func{extra500.sidePanel.MainGenerator.right(); } 		);
		UI.register("Main Generator on", 	func{extra500.sidePanel.MainGenerator.setValue(1); } 	);
		UI.register("Main Generator off", 	func{extra500.sidePanel.MainGenerator.setValue(0); } 	);
		UI.register("Main Generator reset", 	func{extra500.sidePanel.MainGenerator.setValue(-1); } 	);
		
		UI.register("Main External Power", 	func{extra500.sidePanel.MainExternalPower.toggle(); } 	);
		UI.register("Main External Power on", 	func{extra500.sidePanel.MainExternalPower.on(); } 		);
		UI.register("Main External Power off", 	func{extra500.sidePanel.MainExternalPower.off(); } 		);
		
		UI.register("Main Generator Test <", 	func{extra500.sidePanel.MainGeneratorTest.left(); } 		);
		UI.register("Main Generator Test >", 	func{extra500.sidePanel.MainGeneratorTest.right(); } 	);
		UI.register("Main Generator Test on", 	func{extra500.sidePanel.MainGeneratorTest.setValue(1); } 	);
		UI.register("Main Generator Test off", 	func{extra500.sidePanel.MainGeneratorTest.setValue(0); } 	);
		UI.register("Main Generator Test trip",func{extra500.sidePanel.MainGeneratorTest.setValue(-1); } 	);
		
		
		UI.register("Main Avionics", 		func{extra500.sidePanel.MainAvionics.toggle(); } 		);
		UI.register("Main Avionics on", 	func{extra500.sidePanel.MainAvionics.on(); } 		);
		UI.register("Main Avionics off", 	func{extra500.sidePanel.MainAvionics.off(); } 		);
		
	# Light
	
		UI.register("Light Strobe", 		func{extra500.sidePanel.LightStrobe.toggle(); } 	);
		UI.register("Light Strobe on", 		func{extra500.sidePanel.LightStrobe.on(); } 		);
		UI.register("Light Strobe off", 	func{extra500.sidePanel.LightStrobe.off(); } 	);
		
		UI.register("Light Navigation", 	func{extra500.sidePanel.LightNavigation.toggle(); } 	);
		UI.register("Light Navigation on", 	func{extra500.sidePanel.LightNavigation.on(); } 	);
		UI.register("Light Navigation off", 	func{extra500.sidePanel.LightNavigation.off(); } 	);
		
		UI.register("Light Landing", 		func{extra500.sidePanel.LightLanding.toggle(); } 	);
		UI.register("Light Landing on", 	func{extra500.sidePanel.LightLanding.on(); } 	);
		UI.register("Light Landing off", 	func{extra500.sidePanel.LightLanding.off(); } 	);
		
		UI.register("Light Recognition", 	func{extra500.sidePanel.LightRecognition.toggle(); } );
		UI.register("Light Recognition on", 	func{extra500.sidePanel.LightRecognition.on(); } 	);
		UI.register("Light Recognition off", 	func{extra500.sidePanel.LightRecognition.off(); } 	);
		
		UI.register("Light Cabin", 		func{extra500.sidePanel.LightCabin.toggle(); } 	);
		UI.register("Light Cabin on", 		func{extra500.sidePanel.LightCabin.on(); } 		);
		UI.register("Light Cabin off", 		func{extra500.sidePanel.LightCabin.off(); } 		);
		
		UI.register("Light Map", 		func{extra500.sidePanel.LightMap.toggle(); } 	);
		UI.register("Light Map on", 		func{extra500.sidePanel.LightMap.on(); } 		);
		UI.register("Light Map off", 		func{extra500.sidePanel.LightMap.off(); } 		);
		
		UI.register("Light Instrument", 	func{extra500.sidePanel.LightInstrument.toggle(); } 	);
		UI.register("Light Instrument on", 	func{extra500.sidePanel.LightInstrument.on(); } 		);
		UI.register("Light Instrument off", 	func{extra500.sidePanel.LightInstrument.off(); } 		);
		
		UI.register("Light Glare", 		func{extra500.sidePanel.LightGlare.toggle(); } 	);
		UI.register("Light Glare on", 		func{extra500.sidePanel.LightGlare.on(); } 		);
		UI.register("Light Glare off", 		func{extra500.sidePanel.LightGlare.off(); } 		);
		
		UI.register("Night <", 		func{extra500.sidePanel.LightNight.left(); } 	);
		UI.register("Night >", 		func{extra500.sidePanel.LightNight.right(); } 	);
		UI.register("Night night", 	func{extra500.sidePanel.LightNight.setValue(1); } );
		UI.register("Night day", 	func{extra500.sidePanel.LightNight.setValue(0); } );
		UI.register("Night test", 	func{extra500.sidePanel.LightNight.setValue(-1); });
		
		UI.register("Light Ice", 		func{extra500.sidePanel.LightIce.toggle(); } 	);
		UI.register("Light Ice on", 		func{extra500.sidePanel.LightIce.on(); } 		);
		UI.register("Light Ice off", 		func{extra500.sidePanel.LightIce.off(); } 		);
		
	# Deicing
		
		UI.register("Deicing Propeller", 	func{extra500.sidePanel.DeicingPropeller.toggle(); } );
		UI.register("Deicing Propeller on", 	func{extra500.sidePanel.DeicingPropeller.on(); } 	);
		UI.register("Deicing Propeller off", 	func{extra500.sidePanel.DeicingPropeller.off(); } 	);
		
		UI.register("Deicing Pitot Left <", 	func{extra500.sidePanel.DeicingPitotL.left(); } 	);
		UI.register("Deicing Pitot Left >", 	func{extra500.sidePanel.DeicingPitotL.right(); } 	);
		UI.register("Deicing Pitot Left on", 	func{extra500.sidePanel.DeicingPitotL.setValue(1); } );
		UI.register("Deicing Pitot Left off", 	func{extra500.sidePanel.DeicingPitotL.setValue(0); } );
		UI.register("Deicing Pitot Left test", 	func{extra500.sidePanel.DeicingPitotL.setValue(-1); });
		
		UI.register("Deicing Pitot Right <", 	func{extra500.sidePanel.DeicingPitotR.left(); } 	);
		UI.register("Deicing Pitot Right >", 	func{extra500.sidePanel.DeicingPitotR.right(); } 	);
		UI.register("Deicing Pitot Right on", 	func{extra500.sidePanel.DeicingPitotR.setValue(1); } );
		UI.register("Deicing Pitot Right off", 	func{extra500.sidePanel.DeicingPitotR.setValue(0); } );
		UI.register("Deicing Pitot Right test", func{extra500.sidePanel.DeicingPitotR.setValue(-1); });
		
		UI.register("Deicing Windshield", 	func{extra500.sidePanel.DeicingWindshield.toggle(); });
		UI.register("Deicing Windshield on", 	func{extra500.sidePanel.DeicingWindshield.on(); } 	);
		UI.register("Deicing Windshield off", 	func{extra500.sidePanel.DeicingWindshield.off(); } 	);
		
		UI.register("Deicing Boots", 		func{extra500.sidePanel.DeicingBoots.toggle(); } 	);
		UI.register("Deicing Boots on", 	func{extra500.sidePanel.DeicingBoots.on(); } 	);
		UI.register("Deicing Boots off", 	func{extra500.sidePanel.DeicingBoots.off(); } 	);
		
	# Cabin
		
		UI.register("Cabin Pressure Controller <", 		func{extra500.sidePanel.CabinPressure.left(); } 		);
		UI.register("Cabin Pressure Controller >", 		func{extra500.sidePanel.CabinPressure.right(); } 		);
		UI.register("Cabin Pressure Controller on", 		func{extra500.sidePanel.CabinPressure.setValue(1); } 	);
		UI.register("Cabin Pressure Controller off", 		func{extra500.sidePanel.CabinPressure.setValue(0); } 	);
		UI.register("Cabin Pressure Controller dump", 		func{extra500.sidePanel.CabinPressure.setValue(-1); } 	);
				
		UI.register("Cabin Air Condition", 			func{extra500.sidePanel.CabinAirCondition.toggle(); } 	);
		UI.register("Cabin Air Condition on", 			func{extra500.sidePanel.CabinAirCondition.on(); } 		);
		UI.register("Cabin Air Condition off", 			func{extra500.sidePanel.CabinAirCondition.off(); } 		);
		
		UI.register("Cabin Vent <", 				func{extra500.sidePanel.CabinVent.left(); } 		);
		UI.register("Cabin Vent >", 				func{extra500.sidePanel.CabinVent.right(); } 		);
		UI.register("Cabin Vent high", 				func{extra500.sidePanel.CabinVent.setValue(1); } 	);
		UI.register("Cabin Vent low", 				func{extra500.sidePanel.CabinVent.setValue(0); } 	);
		UI.register("Cabin Vent off", 				func{extra500.sidePanel.CabinVent.setValue(-1); } 	);
		
		UI.register("Cabin Environmental Air", 			func{extra500.sidePanel.CabinEnvironmentalAir.toggle(); } 		);
		UI.register("Cabin Environmental Air on", 		func{extra500.sidePanel.CabinEnvironmentalAir.on(); } 		);
		UI.register("Cabin Environmental Air off", 		func{extra500.sidePanel.CabinEnvironmentalAir.off(); } 		);
		
		UI.register("Cabin Temperature Controller Mode <", 	func{extra500.sidePanel.CabinTempMode.left(); } 		);
		UI.register("Cabin Temperature Controller Mode >", 	func{extra500.sidePanel.CabinTempMode.right(); } 		);
		UI.register("Cabin Temperature Controller Mode warm", 	func{extra500.sidePanel.CabinTempMode.setValue(1); } 	);
		UI.register("Cabin Temperature Controller Mode auto", 	func{extra500.sidePanel.CabinTempMode.setValue(0); } 	);
		UI.register("Cabin Temperature Controller Mode cool", 	func{extra500.sidePanel.CabinTempMode.setValue(-1); } 	);
		
		UI.register("Cabin Temperature Controller", 		func{extra500.sidePanel.CabinTempCtrl.toggle(); } 		);
		UI.register("Cabin Temperature Controller on", 		func{extra500.sidePanel.CabinTempCtrl.on(); } 		);
		UI.register("Cabin Temperature Controller off", 	func{extra500.sidePanel.CabinTempCtrl.off(); } 		);
		
		UI.register("Cabin Temperature <", 			func{extra500.sidePanel.CabinTemperature.left(); } 		);
		UI.register("Cabin Temperature >", 			func{extra500.sidePanel.CabinTemperature.right(); } 		);
		UI.register("Cabin Temperature =", 			func(v=0){extra500.sidePanel.CabinTemperature.setValue(v); } 	);
		UI.register("Cabin Temperature +=", 			func(v=0){extra500.sidePanel.CabinTemperature.adjust(v); } 	);
		
	# Emergency
		
		UI.register("Emergency", 	func{extra500.sidePanel.Emergency.toggle(); } 		);
		UI.register("Emergency on", 	func{extra500.sidePanel.Emergency.on(); } 		);
		UI.register("Emergency off", 	func{extra500.sidePanel.Emergency.off(); } 		);
		
	}
};

var sidePanel = SidePanel.new();

