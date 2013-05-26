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
#      Date: May 05 2013
#
#      Last change:      Dirk Dittmann
#      Date:             05.05.13
#

# MM Page 592

var LowVoltageMonitor = {
	new : func(nRoot,name){
		var m = {parents:[
			LowVoltageMonitor,
			Part.Part.new(nRoot,name),
			
		]};
		
		
		m.capacitorLowVolt = Part.Capacitor.new(3);
		
		m.GND = Part.ElectricConnector.new("GND");
		m.LowVoltSense = Part.ElectricConnector.new("LowVoltSense");
		m.LowVoltOut = Part.ElectricConnector.new("LowVoltOut");
		
		m.GND.solder(m);
		m.LowVoltSense.solder(m);
		m.LowVoltOut.solder(m);
		
		
		append(Part.aListSimStateAble,m);
		return m;
	},
	plugElectric : func(){
	
	},
	simReset : func(){
		me.capacitorLowVolt.load(-1);
	},
	simUpdate : func(){
		
	},
	applyVoltage : func(electron,name=""){ 
		Part.etd.in("LowVoltageMonitor",me.name,name,electron);
		var GND = 0;
		if(electron != nil){
			if (name == "LowVoltSense"){
				electron.resistor += 4700.0;
				if (electron.volt < 25.5){
					me.capacitorLowVolt.load(10);
				}
				GND = me.GND.applyVoltage(electron);
			}elsif(name == "LowVoltOut"){
				if (me.capacitorLowVolt.value > 0){
					GND = me.GND.applyVoltage(electron);
				}
			}
		}
		Part.etd.out("LowVoltageMonitor",me.name,name,electron);
		return GND;
	},
	
};

var lowVoltageMonitor = LowVoltageMonitor.new(props.globals.initNode("/extra500/electric/LowVoltageMonitor"),"lowVoltageMonitor");