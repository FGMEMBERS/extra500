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
#      Date: May 22 2013
#
#      Last change:      Dirk Dittmann
#      Date:             22.05.13
#

var PitotSystem = {
	new : func(nRoot,name){
		var m = {parents:[
			PitotSystem,
			Part.Part.new(nRoot,name),
			Part.ElectricAble.new(nRoot,name)
		]};
		
		m.nStallSpeed 		= nRoot.initNode("StallSpeed-kts",70.0,"DOUBLE");
		m.nIndicatedSpeed 	= props.globals.initNode("Indicated-Speed-kts",80.0,"DOUBLE");
		
	# Switches
				
		m.StallWarn = Part.ElectricSwitchDT.new(nRoot.initNode("StallWarn"),"Stall Warning Switch");
		m.StallWarn.setPoles(1);
	
	# buses
		m.GNDBus 	= Part.ElectricBusDiode.new("GNDBus");
	
	# Electric Connectors
		m.GND 			= Part.ElectricPin.new("GND");
		m.Warn 			= Part.ElectricPin.new("Warn");
				
		return m;
		
	},
	applyVoltage : func(electron,name=""){
		
	},
	# FIXME :Fake unitl we can drive real hydraulic system  replace with original !!!
	plugElectric : func(){
		me.GNDBus.Minus.plug(me.GND);
		me.StallWarn.Com1.plug(me.Warn);
		me.StallWarn.L12.plug(me.GNDBus.con());
	},

	# Main Simulation loop  ~ 10Hz
	update : func(timestamp){
		if (me.nIndicatedSpeed.getValue() <= me.nStallSpeed.getValue()){
			me.StallWarn._setValue(1);
		}else{
			me.StallWarn._setValue(0);
		}
	}

	
};


var pitotSystem = PitotSystem.new(props.globals.initNode("/extra500/system/pitot"),"PitotSystem");
