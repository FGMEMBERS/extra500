#Group	Nr	Lable		Values		state		property
# AUTOPILOT
#	0	MASTER		on/fd/off	1/0/-1		extra500/MasterPanel/Autopilot/Master
#	1	PITCH TRIM	on/off		1/0		extra500/MasterPanel/Autopilot/PitchTrim
#	2	YAW DAMPER	on/off		1/0		extra500/MasterPanel/Autopilot/YawDamper
#	3	YAW TRIM	min/max		-1.0/1.0	extra500/MasterPanel/Autopilot/YawTrim

# FUEL
#	4	TRANSFER LEFT	on/off		1/0		extra500/MasterPanel/Fuel/TransferLeft
#	5	TRANSFER RIGHT	on/off		1/0		extra500/MasterPanel/Fuel/TransferRight
#	6	PUMP 1		on/off		1/0		extra500/MasterPanel/Fuel/Pump1
#	7	PUMP 2		on/off		1/0		extra500/MasterPanel/Fuel/Pump2

# ENGINE
#	8	OVSPD TEST 	push		1/0		extra500/MasterPanel/Engine/OverSpeed
#	9	MOTORING	on/abort/normal	1/0/-1		extra500/MasterPanel/Engine/Motoring
#	10	START		on/ign/off	1/0/-1		extra500/MasterPanel/Engine/Start

# DIMMING
#	11	KEYPAD		min/max		0/1.0		extra500/MasterPanel/Dimming/Keypad
#	12	GLARE		min/max		0/1.0		extra500/MasterPanel/Dimming/Glare
#	13	INSTR		min/max		0/1.0		extra500/MasterPanel/Dimming/Instrument
#	14	SWITCHES	min/max		0/1.0		extra500/MasterPanel/Dimming/Switch
#	15	ANNUNCIATOR	min/max		0/1.0		extra500/MasterPanel/Dimming/Annunciator



 
var MasterPanel = {
	new : func{
		var m = {parents:[
			MasterPanel
		]};
		
		m.nPanel = props.globals.getNode("extra500/MasterPanel",1);
		var nCompNode = nil;
# Autopilot
			
		nParent = m.nPanel.initNode("Autopilot");
		
		nCompNode = nParent.initNode("Master");
		m.swtAutopilotMaster = Part.ElectricSwitch3P.new(nCompNode,"Autopilot Master");
		
		nCompNode = nParent.initNode("PitchTrim");
		m.swtAutopilotPitchTrim = Part.ElectricSwitch2P.new(nCompNode,"Autopilot Pitch Trim");
		
		nCompNode = nParent.initNode("YawDamper");
		m.swtAutopilotYawDamper = Part.ElectricSwitch2P.new(nCompNode,"Autopilot Yaw Damper");
		
		nCompNode = nParent.initNode("YawTrim");
		m.swtAutopilotYawTrim = Part.ElectricDimmer.new(nCompNode,"Autopilot Yaw Trim","DOUBLE",-1.0,1.0,0.1);
# Fuel
		nParent = m.nPanel.initNode("Fuel");
		
		nCompNode = nParent.initNode("TransferLeft");
		m.swtFuelTransferLeft = Part.ElectricSwitch2P.new(nCompNode,"Fuel Transfer Left");
		
		nCompNode = nParent.initNode("TransferRight");
		m.swtFuelTransferRight = Part.ElectricSwitch2P.new(nCompNode,"Fuel Transfer Right");
		
		nCompNode = nParent.initNode("Pump1");
		m.swtFuelPump1 = Part.ElectricSwitch2P.new(nCompNode,"Fuel Pump 1");
		
		nCompNode = nParent.initNode("Pump2");
		m.swtFuelPump2 = Part.ElectricSwitch2P.new(nCompNode,"Fuel Pump 2");
# Engine
		nParent = m.nPanel.initNode("Engine");
		
		nCompNode = nParent.initNode("OverSpeed");
		m.swtEngineOverSpeed = Part.ElectricSwitch2P.new(nCompNode,"Engine over speed test");
		
		nCompNode = nParent.initNode("Motoring");
		m.swtEngineMotoring = Part.ElectricSwitch3P.new(nCompNode,"Engine Motoring");
		
		nCompNode = nParent.initNode("Start");
		m.swtEngineStart = Part.ElectricSwitch3P.new(nCompNode,"Engine Start");
# Dimming
		nParent = m.nPanel.initNode("Dimming");
		
		nCompNode = nParent.initNode("Keypad");
		m.swtDimmerKeypad = Part.ElectricDimmer.new(nCompNode,"Dimmer Keypad Light","DOUBLE",0,1.0,0.1);
		
		nCompNode = nParent.initNode("Glare");
		m.swtDimmerGlare = Part.ElectricDimmer.new(nCompNode,"Dimmer Glare Light","DOUBLE",0,1.0,0.1);
		
		nCompNode = nParent.initNode("Instrument");
		m.swtDimmerInstrument = Part.ElectricDimmer.new(nCompNode,"Dimmer Instrument Light","DOUBLE",0,1.0,0.1);
		m.swtDimmerInstrument.electricConfig(12.0,26.0,50.0);
		
		nCompNode = nParent.initNode("Switch");
		m.swtDimmerSwitch = Part.ElectricDimmer.new(nCompNode,"Dimmer Switch Light","DOUBLE",0,1.0,0.1);
		
		nCompNode = nParent.initNode("Annunciator");
		m.swtDimmerAnnunciator = Part.ElectricDimmer.new(nCompNode,"Dimmer Annunciator Light","DOUBLE",0,1.0,0.1);
		
		return m;
	},
	plugElectric : func(){
		global.fnAnnounce("debug","MasterPanel.plugElectric() ...");
		#debug.dump(oElectric);
		
		
		
		#Fuel
# 		me.swtFuelTransferLeft.plugElectricSource(oCircuitBreakerPanel.cbFuelTransferL);
# 		me.swtFuelTransferRight.plugElectricSource(oCircuitBreakerPanel.cbFuelTransferR);
# 		me.swtFuelPump1.plugElectricSource(oCircuitBreakerPanel.cbFuelPump1);
# 		me.swtFuelPump2.plugElectricSource(oCircuitBreakerPanel.cbFuelPump2);
		
		me.swtFuelTransferLeft.In.plug(oCircuitBreakerPanel.cbFuelTransferL.Out);
		me.swtFuelTransferRight.In.plug(oCircuitBreakerPanel.cbFuelTransferR.Out);
		me.swtFuelPump1.In.plug(oCircuitBreakerPanel.cbFuelPump1.Out);
		me.swtFuelPump2.In.plug(oCircuitBreakerPanel.cbFuelPump2.Out);
		
		# Engine
		
		oSidePanel.dayBus.plug(me.swtDimmerInstrument.In);
		oSidePanel.nightBus.plug(me.swtDimmerInstrument.Out);
		
			
	},
	# can only used when Module extra500 is completly loaded.
	# All callback functions must called from a global namespace
	initUI : func(){
		
	# Autopilot

		UI.register("Autopilot Master <", 	func{extra500.oMasterPanel.swtAutopilotMaster.left(); } 		);
		UI.register("Autopilot Master >", 	func{extra500.oMasterPanel.swtAutopilotMaster.right(); } 		);
		UI.register("Autopilot Master on", 	func{extra500.oMasterPanel.swtAutopilotMaster.setValue(1); } 	);
		UI.register("Autopilot Master fd", 	func{extra500.oMasterPanel.swtAutopilotMaster.setValue(0); } 	);
		UI.register("Autopilot Master off", 	func{extra500.oMasterPanel.swtAutopilotMaster.setValue(-1); } 	);
		
		UI.register("Autopilot PitchTrim", 	func{extra500.oMasterPanel.swtAutopilotPitchTrim.toggle(); } 	);
		UI.register("Autopilot PitchTrim on", 	func{extra500.oMasterPanel.swtAutopilotPitchTrim.on(); } 		);
		UI.register("Autopilot PitchTrim off", 	func{extra500.oMasterPanel.swtAutopilotPitchTrim.off(); } 		);
		
		UI.register("Autopilot YawDamper", 	func{extra500.oMasterPanel.swtAutopilotYawDamper.toggle(); } 	);
		UI.register("Autopilot YawDamper on", 	func{extra500.oMasterPanel.swtAutopilotYawDamper.on(); } 		);
		UI.register("Autopilot YawDamper off", 	func{extra500.oMasterPanel.swtAutopilotYawDamper.off(); } 		);
		
		UI.register("Autopilot Yaw Trim <", 	func{extra500.oMasterPanel.swtAutopilotYawTrim.left(); } 		);
		UI.register("Autopilot Yaw Trim >", 	func{extra500.oMasterPanel.swtAutopilotYawTrim.right(); } 		);
		UI.register("Autopilot Yaw Trim =", 	func(v=0){extra500.oMasterPanel.swtAutopilotYawTrim.setValue(v);} 	);
		UI.register("Autopilot Yaw Trim +=", 	func(v=0){extra500.oMasterPanel.swtAutopilotYawTrim.adjust(v);} 	);
	# Fuel
		UI.register("Fuel Transfer Left", 	func{extra500.oMasterPanel.swtFuelTransferLeft.toggle(); } 	);
		UI.register("Fuel Transfer Left on", 	func{extra500.oMasterPanel.swtFuelTransferLeft.on(); } 		);
		UI.register("Fuel Transfer Left off", 	func{extra500.oMasterPanel.swtFuelTransferLeft.off(); } 		);
		
		UI.register("Fuel Transfer Right", 	func{extra500.oMasterPanel.swtFuelTransferRight.toggle(); } 	);
		UI.register("Fuel Transfer Right on", 	func{extra500.oMasterPanel.swtFuelTransferRight.on(); } 		);
		UI.register("Fuel Transfer Right off", 	func{extra500.oMasterPanel.swtFuelTransferRight.off(); } 		);
		
		UI.register("Fuel Pump 1", 		func{extra500.oMasterPanel.swtFuelPump1.toggle(); } 		);
		UI.register("Fuel Pump 1 on", 		func{extra500.oMasterPanel.swtFuelPump1.on(); } 			);
		UI.register("Fuel Pump 1 off", 		func{extra500.oMasterPanel.swtFuelPump1.off(); } 			);
		
		UI.register("Fuel Pump 2", 		func{extra500.oMasterPanel.swtFuelPump2.toggle(); } 		);
		UI.register("Fuel Pump 2 on", 		func{extra500.oMasterPanel.swtFuelPump2.on(); } 			);
		UI.register("Fuel Pump 2 off", 		func{extra500.oMasterPanel.swtFuelPump2.off(); } 			);
		
	# Engine
		
		UI.register("Engine OverSpeed", 	func{extra500.oMasterPanel.swtEngineOverSpeed.toggle(); } 		);
		UI.register("Engine OverSpeed on", 	func{extra500.oMasterPanel.swtEngineOverSpeed.on(); } 		);
		UI.register("Engine OverSpeed off", 	func{extra500.oMasterPanel.swtEngineOverSpeed.off(); } 		);
	
		UI.register("Engine Motoring <", 	func{extra500.oMasterPanel.swtEngineMotoring.left(); } 		);
		UI.register("Engine Motoring >", 	func{extra500.oMasterPanel.swtEngineMotoring.right(); } 		);
		UI.register("Engine Motoring on", 	func{extra500.oMasterPanel.swtEngineMotoring.setValue(1); } 	);
		UI.register("Engine Motoring abort", 	func{extra500.oMasterPanel.swtEngineMotoring.setValue(0); } 	);
		UI.register("Engine Motoring normal", 	func{extra500.oMasterPanel.swtEngineMotoring.setValue(-1); } 	);
		
		UI.register("Engine Start <", 		func{extra500.oMasterPanel.swtEngineStart.left(); } 		);
		UI.register("Engine Start >", 		func{extra500.oMasterPanel.swtEngineStart.right(); } 		);
		UI.register("Engine Start on", 		func{extra500.oMasterPanel.swtEngineStart.setValue(1); } 		);
		UI.register("Engine Start ign", 	func{extra500.oMasterPanel.swtEngineStart.setValue(0); } 		);
		UI.register("Engine Start off", 	func{extra500.oMasterPanel.swtEngineStart.setValue(-1); } 		);
		
	# DIMMING
		
		UI.register("Dimmer Keypad <", 		func{extra500.oMasterPanel.swtDimmerKeypad.left(); } 		);
		UI.register("Dimmer Keypad >", 		func{extra500.oMasterPanel.swtDimmerKeypad.right(); } 		);
		UI.register("Dimmer Keypad =", 		func(v=0){extra500.oMasterPanel.swtDimmerKeypad.setValue(v);} 	);
		UI.register("Dimmer Keypad +=", 	func(v=0){extra500.oMasterPanel.swtDimmerKeypad.adjust(v);} 	);
	
		UI.register("Dimmer Glare <", 		func{extra500.oMasterPanel.swtDimmerGlare.left(); } 		);
		UI.register("Dimmer Glare >", 		func{extra500.oMasterPanel.swtDimmerGlare.right(); } 		);
		UI.register("Dimmer Glare =", 		func(v=0){extra500.oMasterPanel.swtDimmerGlare.setValue(v);} 	);
		UI.register("Dimmer Glare +=", 		func(v=0){extra500.oMasterPanel.swtDimmerGlare.adjust(v);} 	);
	
		UI.register("Dimmer Instrument <", 	func{extra500.oMasterPanel.swtDimmerInstrument.left(); } 		);
		UI.register("Dimmer Instrument >", 	func{extra500.oMasterPanel.swtDimmerInstrument.right(); } 		);
		UI.register("Dimmer Instrument =", 	func(v=0){extra500.oMasterPanel.swtDimmerInstrument.setValue(v);} 	);
		UI.register("Dimmer Instrument +=", 	func(v=0){extra500.oMasterPanel.swtDimmerInstrument.adjust(v);} 	);
	
		UI.register("Dimmer Switch <", 		func{extra500.oMasterPanel.swtDimmerSwitch.left(); } 		);
		UI.register("Dimmer Switch >", 		func{extra500.oMasterPanel.swtDimmerSwitch.right(); } 		);
		UI.register("Dimmer Switch =", 		func(v=0){extra500.oMasterPanel.swtDimmerSwitch.setValue(v);} 	);
		UI.register("Dimmer Switch +=", 	func(v=0){extra500.oMasterPanel.swtDimmerSwitch.adjust(v);} 	);
	
		UI.register("Dimmer Annunciator <", 	func{extra500.oMasterPanel.swtDimmerAnnunciator.left(); } 		);
		UI.register("Dimmer Annunciator >", 	func{extra500.oMasterPanel.swtDimmerAnnunciator.right(); } 	);
		UI.register("Dimmer Annunciator =", 	func(v=0){extra500.oMasterPanel.swtDimmerAnnunciator.setValue(v);} 	);
		UI.register("Dimmer Annunciator +=", 	func(v=0){extra500.oMasterPanel.swtDimmerAnnunciator.adjust(v);} 	);
		
		global.fnAnnounce("debug","MasterPanel.initUI() ... check");
	
	}
};

var oMasterPanel = MasterPanel.new();
