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

		
		return m;

	},

	
};

var digitalInstrumentPackage = DigitalInstrumentPackage.new();