#    This file is part of extra500
#
#    The Changer is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 2 of the License, or
#    (at your option) any later version.
#
#    The Changer is distributed in the hope that it will be useful,
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
 

var MainBoard = {
	new : func{
		var m = {parents:[
			MainBoard
		]};
		m.nRoot = props.globals.getNode("extra500/mainBoard",1);
		var nParent = nil;
	# Ground Connector
		m.GND = Part.ElectricConnector.new("GND");
		
		
	# Relais
		nParent = m.nRoot.initNode("Relais");
				
		var node = nParent.initNode("BatteryRelais");
		m.batteryRelais = Part.ElectricRelaisXPST.new(node,"Battery Relais");
		m.batteryRelais.setPoles(2);
		
		nCompNode = nParent.initNode("DayNightRelais");
		m.dayNightRelais = Part.ElectricRelaisXPDT.new(nCompNode,"Day/Night Relais");
		m.dayNightRelais.setPoles(5);
		# 1 KEYPAD
		# 2 GLARE
		# 3 INSTR
		# 4 SWITCHES
		# 5 ANNUNCIATOR
		
		nCompNode = nParent.initNode("TestLightRelais");
		m.testLightRelais = Part.ElectricRelaisXPDT.new(nCompNode,"Test Light Relais");
		m.testLightRelais.setPoles(5);
		# 1 ANNUNCIATOR
		# 2 Gear
		# 3 Flaps
		# 4 DME
		
		
		nCompNode = nParent.initNode("RCCBRelais");
		m.rccbRelais = Part.ElectricRelaisXPST.new(nCompNode,"RCCB Relais");
		m.rccbRelais.setPoles(1);
		#m.rccbRelais.capacitor.capacity = 2;
		
		nCompNode = nParent.initNode("EmergencyRelais");
		m.emergencyRelais = Part.ElectricRelaisXPDT.new(nCompNode,"Emergency Relais");
		m.emergencyRelais.setPoles(1);
		
		nCompNode = nParent.initNode("AvionicsRelais");
		m.avionicsRelais = Part.ElectricRelaisXPST.new(nCompNode,"Avionics Relais");
		m.avionicsRelais.setPoles(1);
		
		nCompNode = nParent.initNode("StartRelais");
		m.startRelais = Part.ElectricRelaisXPDT.new(nCompNode,"Start Relais");
		m.startRelais.setPoles(3);
		# 1 iBus20 	- iBus30
		# 2 RCCB 	- CB/GND
		# 3 JB4E20 	- JB3E20
		
		nCompNode = nParent.initNode("GeneratorRelais");
		m.generatorRelais = Part.ElectricRelaisXPDT.new(nCompNode,"Generator Relais");
		m.generatorRelais.setPoles(3);
		m.generatorRelais.capacitor.capacity = 2;
		# 1 Bus30 	- Shunt
		# 2 RCCB	- GND
		# 3 GND		- iBus03  = K1 GenFail
		
		nCompNode = nParent.initNode("ExternalPowerRelais");
		m.externalPowerRelais = Part.ElectricRelaisXPDT.new(nCompNode,"External Power Relais");
		m.externalPowerRelais.setPoles(3);
		m.externalPowerRelais.capacitor.capacity = 0;
		# 1 Bus40 	- Bus20 	= Power
		# 2 RCCB	- GND
		# 2 iBus01
		
		nCompNode = nParent.initNode("K8Relais");
		m.k8Relais = Part.ElectricRelaisXPDT.new(nCompNode,"K8 Relais");
		m.k8Relais.setPoles(2);
		# 1 Bus40 	- Bus20 	= Power

		
		
		
		
	# Pre Bus
		m.iHotSourceBus = Part.ElectricBusDiode.new("#HotSourceBus");
		m.iHotRelaisBus = Part.ElectricBus.new("#HotRelaisBus");
		
		
	#internal Buses
		
		m.iBus20 = Part.ElectricBus.new("#20");			
		m.iBus10 = Part.ElectricBus.new("#10");
		m.iBus11 = Part.ElectricBus.new("#11");
		m.iBus01 = Part.ElectricBusDiode.new("#01");		#K8 	Source
		m.iBus02 = Part.ElectricBusDiode.new("#02");		#RCCB	Source
		m.iBus12 = Part.ElectricBus.new("#12");
		m.iBus13 = Part.ElectricBus.new("#13");
		m.iBus30 = Part.ElectricBus.new("#30");			#Gernerator hot
		m.iBus40 = Part.ElectricBus.new("#40");			#External hot
		m.iBus03 = Part.ElectricBusDiode.new("#03");		#GND K1 GenFail
		
		m.JB3E20 = Part.ElectricBus.new("#JB3E20");
		m.JB4E20 = Part.ElectricBus.new("#JB4E20");
		m.JB2G20 = Part.ElectricBusDiode.new("#JB2G20");
		
	
	# main Buses
		
		m.hotBus = Part.ElectricBus.new("HotBus");
		m.loadBus = Part.ElectricBus.new("LoadBus");
		m.batteryBus = Part.ElectricBus.new("BatteryBus");
		m.avionicBus = Part.ElectricBus.new("AvionicsBus");
		m.emergencyBus = Part.ElectricBus.new("EmergencyBus");
		
	# shunts
		var node = m.nRoot.initNode("BatteryShunt");
		m.batteryShunt = Part.ElectricShunt.new(node,"Battery Shunt");
		
		var node = m.nRoot.initNode("GeneratorShunt");
		m.generatorShunt = Part.ElectricShunt.new(node,"Generator Shunt");
		
		var node = m.nRoot.initNode("AlternatorShunt");
		m.alternatorShunt = Part.ElectricShunt.new(node,"Alternator Shunt");
		
		
	#### solder Connectors
		m.GND.solder(m);
		
		return m;
	},
	plugElectric : func(){
		
		mainBoard.hotBus.plug(mainBoard.batteryRelais.A1);
# 		mainBoard.hotBus.plug(fusePanel.emergency3.In);
		mainBoard.hotBus.plug(mainBoard.batteryRelais.P21);
		mainBoard.hotBus.plug(mainBoard.batteryRelais.P11);
		
		mainBoard.iBus20.plug(mainBoard.batteryRelais.P14);
		mainBoard.iBus20.plug(mainBoard.startRelais.P11);
		mainBoard.iBus20.plug(mainBoard.iBus01.con());
		mainBoard.iBus20.plug(mainBoard.iBus02.con());
		mainBoard.iBus20.plug(mainBoard.batteryShunt.Minus);
		
		mainBoard.iBus10.plug(mainBoard.batteryShunt.Plus);
		
		mainBoard.iBus11.plug(mainBoard.generatorShunt.Minus);
		mainBoard.iBus11.plug(mainBoard.iBus01.con());
		mainBoard.iBus20.plug(mainBoard.iBus02.con());
		mainBoard.iBus11.plug(mainBoard.rccbRelais.P11);
# 		
		mainBoard.iBus01.Minus.plug(mainBoard.k8Relais.A1);
		mainBoard.iBus02.Minus.plug(mainBoard.rccbRelais.A1);
		
		
		
		mainBoard.iBus12.plug(mainBoard.emergencyRelais.A1);
		mainBoard.iBus12.plug(mainBoard.emergencyRelais.P14);
# 		
		mainBoard.iBus13.plug(mainBoard.avionicsRelais.A1);
		mainBoard.iBus13.plug(mainBoard.avionicsRelais.P11);
		
		mainBoard.avionicBus.plug(mainBoard.avionicsRelais.P14);
		mainBoard.emergencyBus.plug(mainBoard.emergencyRelais.P11);
		
		mainBoard.iBus30.plug(mainBoard.startRelais.P14);
		mainBoard.iBus30.plug(mainBoard.generatorRelais.P21);
		mainBoard.iBus30.plug(mainBoard.generatorRelais.P11);
# 	
		
		mainBoard.JB3E20.plug(mainBoard.startRelais.P34);
		
		mainBoard.JB4E20.plug(mainBoard.startRelais.P31);
		
		
		
		
		me.externalPowerRelais.A2.plug(me.iBus03.con());
		me.externalPowerRelais.P11.plug(me.iBus40.con());
		me.externalPowerRelais.P14.plug(me.iBus20.con());
		me.externalPowerRelais.P21.plug(me.iBus03.con());
		
		
		mainBoard.generatorRelais.A2.plug(mainBoard.GND);
		mainBoard.generatorRelais.P14.plug(mainBoard.generatorShunt.Plus);
		mainBoard.generatorRelais.P31.plug(me.GND);
		mainBoard.generatorRelais.P32.plug(me.iBus03.Minus);
		
		
		mainBoard.startRelais.A2.plug(mainBoard.GND);
		mainBoard.startRelais.P21.plug(mainBoard.rccbRelais.A2);
		mainBoard.startRelais.P22.plug(mainBoard.k8Relais.P22);
		
		
		mainBoard.k8Relais.A2.plug(mainBoard.externalPowerRelais.P22);
		
		
		
		
	},
	update : func(timestamp){
		#Part.etd.print("\n\n\n---------------- update -----------\n");
		#battery.update(timestamp);
		
	},
	applyVoltage : func(electron,name=""){ 
		if (name == "GND"){
			#etd.echo("MainBoard.applyVoltage("~volt~","~name~") ... touch GND");
			if (electron.resistor > 0){
				electron.ampere = electron.volt / electron.resistor;
			}else{
				Part.etd.echo("MainBoard.applyVoltage("~name~") ... touch GND short cut !!!!!");
				electron.ampere = electron.volt / 0.0024;
			}
			return 1;
		}
		return 0;
	},
	
};

	

var mainBoard = MainBoard.new();

var generatorControlUnit = Part.GeneratorControlUnit.new(props.globals.getNode("extra500/GeneratorControlUnit",1),"Generator Control Unit");

var battery = Part.ElectricBattery.new(props.globals.getNode("extra500/Battery",1),"Battery");

var generator = Part.ElectricGenerator.new(props.globals.getNode("extra500/Generator",1),"Generator");
generator.setPower(24.0,24000.0);

var externalPower = Part.ElectricExternalPower.new(props.globals.getNode("extra500/Ground/ExternalPower",1),"External Power");


