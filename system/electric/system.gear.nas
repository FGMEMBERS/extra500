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
#      Date: April 20 2013
#
#      Last change:      Dirk Dittmann
#      Date:             26.04.13
#

var GearSystem = {
	new : func{
		var m = {parents:[
			GearSystem
		]};
		
		
		m.nGearNose = props.globals.getNode("/gear/gear[0]/position-norm",1);
		m.nGearLeft = props.globals.getNode("/gear/gear[1]/position-norm",1);
		m.nGearRight = props.globals.getNode("/gear/gear[2]/position-norm",1);
		m.listener = nil;
		
		m.GND = Part.ElectricConnector.new("GND");
		m.GearNose = Part.ElectricConnector.new("GearNose");
		m.GearLeft = Part.ElectricConnector.new("GearLeft");
		m.GearRight = Part.ElectricConnector.new("GearRight");
		
		m.GND.solder(m);
		m.GearNose.solder(m);
		m.GearLeft.solder(m);
		m.GearRight.solder(m);
		
		return m;
		
	},applyVoltage : func(electron,name=""){
				
		if (name == "GearNose" and me.nGearNose.getValue() == 1.0){
			me.GND.applyVoltage(electron);
		}elsif (name == "GearLeft" and me.nGearLeft.getValue() == 1.0){
			me.GND.applyVoltage(electron);
		}elsif (name == "GearRight" and me.nGearRight.getValue() == 1.0){
			me.GND.applyVoltage(electron);
		}
	}
	
};

var gearSystem = GearSystem.new();