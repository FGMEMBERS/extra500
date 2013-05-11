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
#      Date: May 11 2013
#
#      Last change:      Dirk Dittmann
#      Date:             11.05.13
#

var EngineInstrumentPackage = {
	new : func(nRoot,name){
				
		var m = {parents:[
			EngineInstrumentPackage,
			Part.Part.new(nRoot,name),
			Part.SimStateAble.new(nRoot,"BOOL",0),
			Part.ElectricAble.new(nRoot,name)
		]};
		
				
		#m.VoltMonitor = Part.ElectricVoltSensor.new(m.nPanel.initNode("VoltMonitor"),"Volt Monitor");
		m.TRQ = 0.0;
		m.TOT = 0.0;
		m.N1 = 0.0;
		m.N2 = 0.0;
		m.OP = 0.0;
		m.OT = 0.0;
		
				
	# nodes for indication must be abs(value)
		m.nIndicatedTRQ = nRoot.initNode("indicatedTRQ",0.0,"DOUBLE");
		m.nIndicatedTOT = nRoot.initNode("indicatedTOT",0.0,"DOUBLE");
		
		m.nIndicatedN1 = nRoot.initNode("indicatedN1",0.0,"DOUBLE");
		m.nIndicatedN2 = nRoot.initNode("indicatedN2",0.0,"DOUBLE");
		
		m.nIndicatedOP = nRoot.initNode("indicatedOilPress",0.0,"DOUBLE");
		m.nIndicatedOT = nRoot.initNode("indicatedOilTemp",0.0,"DOUBLE");
		
	# Electric Connectors
		m.PowerInputA 		= Part.ElectricConnector.new("PowerInputA");
		m.PowerInputB 		= Part.ElectricConnector.new("PowerInputB");
		m.GND 			= Part.ElectricConnector.new("GND");
		
		m.PowerInputA.solder(m);
		m.PowerInputB.solder(m);
		m.GND.solder(m);
	# list for main loop to reset the "state" variable to default
		append(Part.aListSimStateAble,m);
		return m;

	},
	# electric system calls applyVoltage to get electicity in
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
			}
		}
		
		Part.etd.out("DIP",me.name,name,electron);
		return GND;
	},
	# Main Simulation loop  ~ 10Hz
	update : func(){
		if (me.state == 0){	# no power input
			me.TRQ = 0.0;
			me.TOT = 0.0;
			me.N1 = 0.0;
			me.N2 = 0.0;
			me.OP = 0.0;
			me.OT = 0.0;
		
		}
		
		# set the indecated values to the tree + 0.0001 to avoid bad round
		me.nIndicatedTRQ.setValue( math.abs(me.TRQ) + 0.0001 );
		me.nIndicatedTOT.setValue( math.abs(me.TOT) + 0.0001 );
		me.nIndicatedN1.setValue( math.abs(me.N1) + 0.0001 );
		me.nIndicatedN2.setValue( math.abs(me.N2) + 0.0001 );
		me.nIndicatedOP.setValue( math.abs(me.OP) + 0.0001 );
		me.nIndicatedOT.setValue( math.abs(me.OT) + 0.0001 );
		
	}
	
};

var engineInstrumentPackage = EngineInstrumentPackage.new(props.globals.initNode("extra500/Instrument/EIP"),"Engine Instrument Package");
