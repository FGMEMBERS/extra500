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
#      Date: May 09 2013
#
#      Last change:      Dirk Dittmann
#      Date:             09.05.13
#

var DigitalInstrumentPackage = {
	new : func(nRoot,name){
				
		var m = {parents:[
			DigitalInstrumentPackage,
			Part.Part.new(nRoot,name),
			Part.SimStateAble.new(nRoot,"BOOL",0),
			Part.ElectricAble.new(nRoot,name)
		]};
		
				
		#m.VoltMonitor = Part.ElectricVoltSensor.new(m.nPanel.initNode("VoltMonitor"),"Volt Monitor");
		m.VDC = 0.0;
		
		m.nGenAmps = props.globals.initNode("extra500/mainBoard/GeneratorShunt/indicatedAmpere",0.0,"DOUBLE");
		m.nBatAmps = props.globals.initNode("extra500/mainBoard/BatteryShunt/indicatedAmpere",0.0,"DOUBLE");
		
		m.nIAT = props.globals.initNode("/environment/temperature-degc",0.0,"DOUBLE");
		m.nFuelTemp = props.globals.initNode("/fdm/jsbsim/aircraft/engine/FT-degC",0.0,"DOUBLE");
		m.nFuelPress = props.globals.initNode("/fdm/jsbsim/aircraft/engine/FP-psi",0.0,"DOUBLE");
		
		m.nIndicatedVDC = props.globals.initNode("extra500/Instrument/DIP/indicatedVDC",0.0,"DOUBLE");
		m.nIndicatedGEN = props.globals.initNode("extra500/Instrument/DIP/indicatedGEN",0.0,"DOUBLE");
		m.nIndicatedBAT = props.globals.initNode("extra500/Instrument/DIP/indicatedBAT",0.0,"DOUBLE");
		
		m.nIndicatedIAT = props.globals.initNode("extra500/Instrument/DIP/indicatedIAT",0.0,"DOUBLE");
		m.nIndicatedFuelTemp = props.globals.initNode("extra500/Instrument/DIP/indicatedFuelTemp",0.0,"DOUBLE");
		m.nIndicatedFuelPress = props.globals.initNode("extra500/Instrument/DIP/indicatedFuelPress",0.0,"DOUBLE");
		
	# Electric Connectors
		m.PowerInputA 		= Part.ElectricConnector.new("PowerInputA");
		m.PowerInputB 		= Part.ElectricConnector.new("PowerInputB");
		m.VoltMonitor		= Part.ElectricConnector.new("VoltMonitor");
		m.GND 			= Part.ElectricConnector.new("GND");
		
		m.PowerInputA.solder(m);
		m.PowerInputB.solder(m);
		m.VoltMonitor.solder(m);
		m.GND.solder(m);
		
		append(Part.aListSimStateAble,m);
		return m;

	},
	applyVoltage : func(electron,name=""){ 
		Part.etd.in("DIP",me.name,name,electron);
		var GND = 0;
		
		if (electron != nil){
			electron.resistor += 20000.0;
			if (name == "PowerInputA"){
				
				GND = me.GND.applyVoltage(electron);
				if (GND){
					me.state = 1;
					var watt = me.electricWork(electron);
				}
			}elsif(name == "PowerInputB"){
				GND = me.GND.applyVoltage(electron);
				if (GND){
					me.state = 1;
					var watt = me.electricWork(electron);
				}
			}elsif(name == "VoltMonitor"){
				
				GND = me.GND.applyVoltage(electron);
				if (GND){
					var watt = me.electricWork(electron);
					me.VDC = electron.volt;
				}
			}
		}
		
		Part.etd.out("DIP",me.name,name,electron);
		return GND;
	},
	# Main Simulation loop  ~ 10Hz
	update : func(){
		if (me.state == 0){	# no power input
			me.VDC = 0.0;
		}
		
		me.nIndicatedVDC.setValue( math.abs(me.VDC) + 0.0001 );
		me.nIndicatedGEN.setValue( math.abs(me.nGenAmps.getValue()) + 0.0001 );
		me.nIndicatedBAT.setValue( math.abs(me.nBatAmps.getValue()) + 0.0001 );
		me.nIndicatedIAT.setValue( math.abs(me.nIAT.getValue()) + 0.0001 );
		me.nIndicatedFuelTemp.setValue( math.abs(me.nFuelTemp.getValue()) + 0.0001 );
		me.nIndicatedFuelPress.setValue( math.abs(me.nFuelPress.getValue()) + 0.0001 );
		
	}
	
};

var digitalInstrumentPackage = DigitalInstrumentPackage.new(props.globals.initNode("extra500/Instrument/DIP"),"Digital Instrument Package");