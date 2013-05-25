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
#      Date:             08.05.13
#
 

var EBox = {
	new : func(nRoot,name){
		var m = {parents:[
			EBox
		]};
		m.nRoot = nRoot;
		
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

		nCompNode = nParent.initNode("AlternatorRelais");
		m.alternatorRelais = Part.ElectricRelaisXPDT.new(nCompNode,"Alternator Relais");
		m.alternatorRelais.setPoles(1);
		# 1 Alternator 	- Bus20 	= Power

		
		
		
		
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
		m.JB2G20 = Part.ElectricBus.new("#JB2G20");
		
	
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
		
		eBox.hotBus.plug(eBox.batteryRelais.A1);
# 		eBox.hotBus.plug(fusePanel.emergency3.In);
		eBox.hotBus.plug(eBox.batteryRelais.P21);
		eBox.hotBus.plug(eBox.batteryRelais.P11);
		
		eBox.iBus20.plug(eBox.batteryRelais.P14);
		eBox.iBus20.plug(eBox.startRelais.P11);
		eBox.iBus20.plug(eBox.iBus01.con());
		eBox.iBus20.plug(eBox.iBus02.con());
		eBox.iBus20.plug(eBox.batteryShunt.Minus);
		
		eBox.iBus10.plug(eBox.batteryShunt.Plus);
		
		eBox.iBus11.plug(eBox.generatorShunt.Minus);
		eBox.iBus11.plug(eBox.iBus01.con());
		eBox.iBus20.plug(eBox.iBus02.con());
		eBox.iBus11.plug(eBox.rccbRelais.P11);
# 		
		eBox.iBus01.Minus.plug(eBox.k8Relais.A1);
		eBox.iBus02.Minus.plug(eBox.rccbRelais.A1);
		
		
		
		eBox.iBus12.plug(eBox.emergencyRelais.A1);
		eBox.iBus12.plug(eBox.emergencyRelais.P14);
# 		
		eBox.iBus13.plug(eBox.avionicsRelais.A1);
		eBox.iBus13.plug(eBox.avionicsRelais.P11);
		
		eBox.avionicBus.plug(eBox.avionicsRelais.P14);
		eBox.emergencyBus.plug(eBox.emergencyRelais.P11);
		eBox.emergencyBus.plug(eBox.alternatorShunt.Plus);
		
		eBox.iBus30.plug(eBox.startRelais.P14);
		eBox.iBus30.plug(eBox.generatorRelais.P21);
		eBox.iBus30.plug(eBox.generatorRelais.P11);
# 	
		
		eBox.JB3E20.plug(eBox.startRelais.P34);
		
		eBox.JB4E20.plug(eBox.startRelais.P31);
		
		
		
		
		me.externalPowerRelais.A2.plug(me.iBus03.con());
		me.externalPowerRelais.P11.plug(me.iBus40.con());
		me.externalPowerRelais.P14.plug(me.iBus20.con());
		me.externalPowerRelais.P21.plug(me.iBus03.con());
		
		
		eBox.generatorRelais.A2.plug(eBox.GND);
		eBox.generatorRelais.P14.plug(eBox.generatorShunt.Plus);
		eBox.generatorRelais.P31.plug(me.GND);
		eBox.generatorRelais.P32.plug(me.iBus03.Minus);
		
		
		eBox.startRelais.A2.plug(eBox.GND);
		eBox.startRelais.P21.plug(eBox.rccbRelais.A2);
		eBox.startRelais.P22.plug(eBox.k8Relais.P22);
		
		
		eBox.k8Relais.A2.plug(eBox.externalPowerRelais.P22);
		
		me.alternatorRelais.P12.plug(me.alternatorShunt.Minus);
		me.alternatorRelais.A2.plug(me.GND);
		
		
	},
	update : func(dt){
		
	},
	applyVoltage : func(electron,name=""){ 
		if (name == "GND"){
			#etd.echo("EBox.applyVoltage("~volt~","~name~") ... touch GND");
			if (electron.resistor > 0){
				electron.ampere = electron.volt / electron.resistor;
			}else{
				Part.etd.echo("EBox.applyVoltage("~name~") ... touch GND short cut !!!!!");
				electron.ampere = electron.volt / 0.0024;
			}
			return 1;
		}
		return 0;
	},
	
};

	

var eBox = EBox.new(props.globals.initNode("extra500/electric/eBox"),"eBox");

var generatorControlUnit = Part.GeneratorControlUnit.new(props.globals.initNode("extra500/electric/GeneratorControlUnit"),"Generator Control Unit");
var standbyAlternatorRegulator = Part.StandbyAlternatorRegulator.new(props.globals.initNode("extra500/electric/StandbyAlternatorRegulator"),"Standby Alternator Regulator");


var externalPower = Part.ElectricExternalPower.new(props.globals.initNode("extra500/ground/ExternalPower"),"External Power Box");

var generator = Part.ElectricGenerator.new(props.globals.initNode("extra500/electric/Generator"),"Generator");
generator.setPower(24.0,24000.0);

var alternator = Part.ElectricAlternator.new(props.globals.initNode("extra500/electric/Alternator"),"Alternator");
alternator.electricConfig(24.0,26.0);

var battery = Part.ElectricBattery.new(props.globals.initNode("extra500/electric/Battery"),"Battery");
battery.electricConfig(15.3,24.3);

var adjustAdditionalElectricLoads = func(now,dt){
	if (alternator.surplusAmpere < 0){
		battery.setAmpereUsage(alternator.surplusAmpere,dt);
		eBox.batteryShunt.indicatedAmpere += alternator.surplusAmpere;
		eBox.alternatorShunt.indicatedAmpere -= alternator.surplusAmpere;
	}
}