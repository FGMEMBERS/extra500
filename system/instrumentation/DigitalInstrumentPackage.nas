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
	new : func(){
				
		var m = {parents:[
			DigitalInstrumentPackage,
		]};
		
		m.nPanel = props.globals.getNode("extra500/Instrument/DIP",1);
		
		m.VoltMonitor = Part.ElectricVoltSensor.new(m.nPanel.initNode("VoltMonitor"),"Volt Monitor");

		
		m.nVDC = props.globals.getNode("extra500/Instrument/DIP/VoltMonitor/state");
		m.nGenAmps = props.globals.getNode("extra500/mainBoard/GeneratorShunt/indicatedAmpere");
		m.nBatAmps = props.globals.getNode("extra500/mainBoard/BatteryShunt/indicatedAmpere");
		
		m.nIAT = props.globals.getNode("/environment/temperature-degc");
		m.nFuelTemp = props.globals.getNode("/fdm/jsbsim/aircraft/engine/FT-degC");
		m.nFuelPress = props.globals.getNode("/fdm/jsbsim/aircraft/engine/FP-psi");
		
		m.nIndicatedVDC = props.globals.getNode("extra500/Instrument/DIP/indicatedVDC",1);
		m.nIndicatedGEN = props.globals.getNode("extra500/Instrument/DIP/indicatedGEN",1);
		m.nIndicatedBAT = props.globals.getNode("extra500/Instrument/DIP/indicatedBAT",1);
		
		m.nIndicatedIAT = props.globals.getNode("extra500/Instrument/DIP/indicatedIAT",1);
		m.nIndicatedFuelTemp = props.globals.getNode("extra500/Instrument/DIP/indicatedFuelTemp",1);
		m.nIndicatedFuelPress = props.globals.getNode("extra500/Instrument/DIP/indicatedFuelPress",1);
		
		
		return m;

	},
	# Main Simulation loop  ~ 10Hz
	update : func(){
		
		me.nIndicatedVDC.setValue( math.abs(me.nVDC.getValue()) + 0.0001 );
		me.nIndicatedGEN.setValue( math.abs(me.nGenAmps.getValue()) + 0.0001 );
		me.nIndicatedBAT.setValue( math.abs(me.nBatAmps.getValue()) + 0.0001 );
		me.nIndicatedIAT.setValue( math.abs(me.nIAT.getValue()) + 0.0001 );
		me.nIndicatedFuelTemp.setValue( math.abs(me.nFuelTemp.getValue()) + 0.0001 );
		me.nIndicatedFuelPress.setValue( math.abs(me.nFuelPress.getValue()) + 0.0001 );
		
	}
	
};

var digitalInstrumentPackage = DigitalInstrumentPackage.new();