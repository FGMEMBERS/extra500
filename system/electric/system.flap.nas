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

var FlapSystem = {
	new : func{
		var m = {parents:[
			FlapSystem
		]};
		m.nRoot = props.globals.getNode("extra500/system/flap",1);
		
		m.nFlaps = props.globals.getNode("/controls/flight/flaps",1);
		m.nFlapPosition = props.globals.getNode("/surface-positions/flap-pos-norm",1);
		m.listener = nil;
		
		m.flaps = 0;
		m.flapPosition = 0;
		
		m.GND = Part.ElectricConnector.new("GND");
		m.FlapTransition = Part.ElectricConnector.new("FlapTransition");
		m.Flap15 = Part.ElectricConnector.new("Flap15");
		m.Flap30 = Part.ElectricConnector.new("Flap30");
		
		
		m.motor = Part.ElectricMotor.new(m.nRoot.initNode("Motor"),"Motor");
		m.motor.electricConfig(12.0,26.0);
		m.motor.setPower(24.0,20.0);
		
		m.GND.solder(m);
		m.FlapTransition.solder(m);
		m.Flap15.solder(m);
		m.Flap30.solder(m);
		
		return m;
		
	},applyVoltage : func(electron,name=""){
		
		
		
		if (name == "FlapTransition"){
			me.flaps = me.nFlaps.getValue();
			me.flapPosition = me.nFlapPosition.getValue();
			if (me.flapPosition != me.flaps){
				me.GND.applyVoltage(electron);
			}
		}elsif (name == "Flap15"){
			me.flapPosition = me.nFlapPosition.getValue();
			if (me.flapPosition == 0.5){
				me.GND.applyVoltage(electron);
			}
		}elsif (name == "Flap30"){
			me.flapPosition = me.nFlapPosition.getValue();
			if (me.flapPosition == 1.0){
				me.GND.applyVoltage(electron);
			}
		}
	}
	
};

var flapSystem = FlapSystem.new();