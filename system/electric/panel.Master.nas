#    This file is part of extra500
#
#    extra500 is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 2 of the License, or
#    (at your option) any later version.
#
#    extra500 is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with extra500.  If not, see <http://www.gnu.org/licenses/>.
#
#      Authors: Dirk Dittmann
#      Date: April 07 2013
#
#      Last change:      Dirk Dittmann
#      Date:             26.04.13
#


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
		m.AutopilotMaster = Part.ElectricSwitchTT.new(nCompNode,"Autopilot Master");
		m.AutopilotMaster.setPoles(1);
		
		nCompNode = nParent.initNode("PitchTrim");
		m.AutopilotPitchTrim = Part.ElectricSwitchDT.new(nCompNode,"Autopilot Pitch Trim");
		m.AutopilotPitchTrim.setPoles(1);
		
		nCompNode = nParent.initNode("YawDamper");
		m.AutopilotYawDamper = Part.ElectricSwitchDT.new(nCompNode,"Autopilot Yaw Damper");
		m.AutopilotYawDamper.setPoles(1);
		
		nCompNode = nParent.initNode("YawTrim");
		m.AutopilotYawTrim = Part.ElectricDimmer.new(nCompNode,"Autopilot Yaw Trim","DOUBLE",-1.0,1.0,0.1);

		
# Fuel
		nParent = m.nPanel.initNode("Fuel");
		
		nCompNode = nParent.initNode("TransferLeft");
		m.FuelTransferLeft = Part.ElectricSwitchDT.new(nCompNode,"Fuel Transfer Left");
		m.FuelTransferLeft.setPoles(1);
		
		nCompNode = nParent.initNode("TransferRight");
		m.FuelTransferRight = Part.ElectricSwitchDT.new(nCompNode,"Fuel Transfer Right");
		m.FuelTransferRight.setPoles(1);
		
		nCompNode = nParent.initNode("Pump1");
		m.FuelPump1 = Part.ElectricSwitchDT.new(nCompNode,"Fuel Pump 1");
		m.FuelPump1.setPoles(1);
		
		nCompNode = nParent.initNode("Pump2");
		m.FuelPump2 = Part.ElectricSwitchDT.new(nCompNode,"Fuel Pump 2");
		m.FuelPump2.setPoles(1);
# Engine
		nParent = m.nPanel.initNode("Engine");
		
		nCompNode = nParent.initNode("OverSpeed");
		m.EngineOverSpeed = Part.ElectricSwitchDT.new(nCompNode,"Engine over speed test");
		m.EngineOverSpeed.setPoles(1);
		
		nCompNode = nParent.initNode("Motoring");
		m.EngineMotoring = Part.ElectricSwitchTT.new(nCompNode,"Engine Motoring");
		m.EngineMotoring.setPoles(3);
		
		nCompNode = nParent.initNode("Start");
		m.EngineStart = Part.ElectricSwitchTT.new(nCompNode,"Engine Start");
		m.EngineStart.setPoles(2);
		
# Dimming
		nParent = m.nPanel.initNode("Dimming");
		
		nCompNode = nParent.initNode("Keypad");
		m.DimmerKeypad = Part.ElectricDimmer.new(nCompNode,"Dimmer Keypad Light","DOUBLE",0,1.0,0.1);
		m.DimmerKeypad.electricConfig(15.0,26.0);
		#m.DimmerKeypad.setResistor(4700);
		
		nCompNode = nParent.initNode("Glare");
		m.DimmerGlare = Part.ElectricDimmer.new(nCompNode,"Dimmer Glare Light","DOUBLE",0,1.0,0.1);
		m.DimmerGlare.electricConfig(15.0,26.0);
		#m.DimmerGlare.setResistor(4700);
		
		nCompNode = nParent.initNode("Instrument");
		m.DimmerInstrument = Part.ElectricDimmer.new(nCompNode,"Dimmer Instrument Light","DOUBLE",0,1.0,0.1);
		m.DimmerInstrument.electricConfig(8.0,28.0);
		#m.DimmerInstrument.setResistor(6);
		
		nCompNode = nParent.initNode("Switch");
		m.DimmerSwitch = Part.ElectricDimmer.new(nCompNode,"Dimmer Switch Light","DOUBLE",0,1.0,0.1);
		m.DimmerSwitch.electricConfig(15.0,26.0);
		#m.DimmerSwitch.setResistor(4700);
		
		nCompNode = nParent.initNode("Annunciator");
		m.DimmerAnnunciator = Part.ElectricDimmer.new(nCompNode,"Dimmer Annunciator Light","DOUBLE",0,1.0,0.1);
		m.DimmerAnnunciator.electricConfig(14.0,26.0);
		#m.DimmerAnnunciator.setResistor(4700);
		
		
		#internal Buses
# 		m.instrumentSourceBus = Part.ElectricBus.new("#InstrumentSourceBus");
# 		m.cabinSourceBus = Part.ElectricBus.new("#CabinSourceBus");
		
		m.keypadBus = Part.ElectricBus.new("#KeypadLightBus");
		m.glareLightBus = Part.ElectricBus.new("#GlareLightBus");
		m.instrumentLightBus = Part.ElectricBus.new("#InstrumentLightBus");
		
		m.switchesLightBus = Part.ElectricBus.new("#SwitchesLightBus");
		m.warnLightBus = Part.ElectricBus.new("#WarnLightBus");
		
		
		
		return m;
	},
	# can only used when Module extra500 is completly loaded.
	# All callback functions must called from a global namespace
	initUI : func(){
		
	# Autopilot

		UI.register("Autopilot Master <", 	func{extra500.masterPanel.AutopilotMaster.left(); } 		);
		UI.register("Autopilot Master >", 	func{extra500.masterPanel.AutopilotMaster.right(); } 		);
		UI.register("Autopilot Master on", 	func{extra500.masterPanel.AutopilotMaster.setValue(1); } 	);
		UI.register("Autopilot Master fd", 	func{extra500.masterPanel.AutopilotMaster.setValue(0); } 	);
		UI.register("Autopilot Master off", 	func{extra500.masterPanel.AutopilotMaster.setValue(-1); } 	);
		
		UI.register("Autopilot PitchTrim", 	func{extra500.masterPanel.AutopilotPitchTrim.toggle(); } 	);
		UI.register("Autopilot PitchTrim on", 	func{extra500.masterPanel.AutopilotPitchTrim.on(); } 		);
		UI.register("Autopilot PitchTrim off", 	func{extra500.masterPanel.AutopilotPitchTrim.off(); } 		);
		
		UI.register("Autopilot YawDamper", 	func{extra500.masterPanel.AutopilotYawDamper.toggle(); } 	);
		UI.register("Autopilot YawDamper on", 	func{extra500.masterPanel.AutopilotYawDamper.on(); } 		);
		UI.register("Autopilot YawDamper off", 	func{extra500.masterPanel.AutopilotYawDamper.off(); } 		);
		
		UI.register("Autopilot Yaw Trim <", 	func{extra500.masterPanel.AutopilotYawTrim.left(); } 		);
		UI.register("Autopilot Yaw Trim >", 	func{extra500.masterPanel.AutopilotYawTrim.right(); } 		);
		UI.register("Autopilot Yaw Trim =", 	func(v=0){extra500.masterPanel.AutopilotYawTrim.setValue(v);} 	);
		UI.register("Autopilot Yaw Trim +=", 	func(v=0){extra500.masterPanel.AutopilotYawTrim.adjust(v);} 	);
	# Fuel
		UI.register("Fuel Transfer Left", 	func{extra500.masterPanel.FuelTransferLeft.toggle(); } 	);
		UI.register("Fuel Transfer Left on", 	func{extra500.masterPanel.FuelTransferLeft.on(); } 		);
		UI.register("Fuel Transfer Left off", 	func{extra500.masterPanel.FuelTransferLeft.off(); } 		);
		
		UI.register("Fuel Transfer Right", 	func{extra500.masterPanel.FuelTransferRight.toggle(); } 	);
		UI.register("Fuel Transfer Right on", 	func{extra500.masterPanel.FuelTransferRight.on(); } 		);
		UI.register("Fuel Transfer Right off", 	func{extra500.masterPanel.FuelTransferRight.off(); } 		);
		
		UI.register("Fuel Pump 1", 		func{extra500.masterPanel.FuelPump1.toggle(); } 		);
		UI.register("Fuel Pump 1 on", 		func{extra500.masterPanel.FuelPump1.on(); } 			);
		UI.register("Fuel Pump 1 off", 		func{extra500.masterPanel.FuelPump1.off(); } 			);
		
		UI.register("Fuel Pump 2", 		func{extra500.masterPanel.FuelPump2.toggle(); } 		);
		UI.register("Fuel Pump 2 on", 		func{extra500.masterPanel.FuelPump2.on(); } 			);
		UI.register("Fuel Pump 2 off", 		func{extra500.masterPanel.FuelPump2.off(); } 			);
		
	# Engine
		
		UI.register("Engine OverSpeed", 	func{extra500.masterPanel.EngineOverSpeed.toggle(); } 		);
		UI.register("Engine OverSpeed on", 	func{extra500.masterPanel.EngineOverSpeed.on(); } 		);
		UI.register("Engine OverSpeed off", 	func{extra500.masterPanel.EngineOverSpeed.off(); } 		);
	
		UI.register("Engine Motoring <", 	func{extra500.masterPanel.EngineMotoring.left(); } 		);
		UI.register("Engine Motoring >", 	func{extra500.masterPanel.EngineMotoring.right(); } 		);
		UI.register("Engine Motoring on", 	func{extra500.masterPanel.EngineMotoring.setValue(1); } 	);
		UI.register("Engine Motoring abort", 	func{extra500.masterPanel.EngineMotoring.setValue(0); } 	);
		UI.register("Engine Motoring normal", 	func{extra500.masterPanel.EngineMotoring.setValue(-1); } 	);
		
		UI.register("Engine Start <", 		func{extra500.masterPanel.EngineStart.left(); } 		);
		UI.register("Engine Start >", 		func{extra500.masterPanel.EngineStart.right(); } 		);
		UI.register("Engine Start on", 		func{extra500.masterPanel.EngineStart.setValue(1); } 		);
		UI.register("Engine Start ign", 	func{extra500.masterPanel.EngineStart.setValue(0); } 		);
		UI.register("Engine Start off", 	func{extra500.masterPanel.EngineStart.setValue(-1); } 		);
		
	# DIMMING
		
		UI.register("Dimmer Keypad <", 		func{extra500.masterPanel.DimmerKeypad.left(); } 		);
		UI.register("Dimmer Keypad >", 		func{extra500.masterPanel.DimmerKeypad.right(); } 		);
		UI.register("Dimmer Keypad =", 		func(v=0){extra500.masterPanel.DimmerKeypad.setValue(v);} 	);
		UI.register("Dimmer Keypad +=", 	func(v=0){extra500.masterPanel.DimmerKeypad.adjust(v);} 	);
	
		UI.register("Dimmer Glare <", 		func{extra500.masterPanel.DimmerGlare.left(); } 		);
		UI.register("Dimmer Glare >", 		func{extra500.masterPanel.DimmerGlare.right(); } 		);
		UI.register("Dimmer Glare =", 		func(v=0){extra500.masterPanel.DimmerGlare.setValue(v);} 	);
		UI.register("Dimmer Glare +=", 		func(v=0){extra500.masterPanel.DimmerGlare.adjust(v);} 	);
	
		UI.register("Dimmer Instrument <", 	func{extra500.masterPanel.DimmerInstrument.left(); } 		);
		UI.register("Dimmer Instrument >", 	func{extra500.masterPanel.DimmerInstrument.right(); } 		);
		UI.register("Dimmer Instrument =", 	func(v=0){extra500.masterPanel.DimmerInstrument.setValue(v);} 	);
		UI.register("Dimmer Instrument +=", 	func(v=0){extra500.masterPanel.DimmerInstrument.adjust(v);} 	);
	
		UI.register("Dimmer Switch <", 		func{extra500.masterPanel.DimmerSwitch.left(); } 		);
		UI.register("Dimmer Switch >", 		func{extra500.masterPanel.DimmerSwitch.right(); } 		);
		UI.register("Dimmer Switch =", 		func(v=0){extra500.masterPanel.DimmerSwitch.setValue(v);} 	);
		UI.register("Dimmer Switch +=", 	func(v=0){extra500.masterPanel.DimmerSwitch.adjust(v);} 	);
	
		UI.register("Dimmer Annunciator <", 	func{extra500.masterPanel.DimmerAnnunciator.left(); } 		);
		UI.register("Dimmer Annunciator >", 	func{extra500.masterPanel.DimmerAnnunciator.right(); } 	);
		UI.register("Dimmer Annunciator =", 	func(v=0){extra500.masterPanel.DimmerAnnunciator.setValue(v);} 	);
		UI.register("Dimmer Annunciator +=", 	func(v=0){extra500.masterPanel.DimmerAnnunciator.adjust(v);} 	);
		
		global.fnAnnounce("debug","MasterPanel.initUI() ... check");
	
	}
};

var masterPanel = MasterPanel.new();
