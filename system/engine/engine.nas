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
#      Date: April 29 2013
#
#      Last change:      Eric van den Berg
#      Date:             2013-06-10
#


var Engine = {
	new : func(nRoot,name){
		var m = {parents:[
			Engine,
			Part.Part.new(nRoot,name),
			Part.ElectricAble.new(nRoot,name)
		]};
		m.nIsRunning		= props.globals.getNode("/fdm/jsbsim/propulsion/engine/set-running");
		m.nTRQ			= props.globals.getNode("/fdm/jsbsim/aircraft/engine/TRQ-perc");
		m.nN1			= props.globals.getNode("/engines/engine[0]/n1");
		m.nCutOff		= props.globals.getNode("/controls/engines/engine[0]/cutoff");
		m.nReverser		= props.globals.getNode("/controls/engines/engine[0]/reverser");
		m.nThrottle		= props.globals.getNode("/controls/engines/engine[0]/throttle");
		m.nIgnition		= props.globals.getNode("/controls/engines/engine[0]/ignition");
		m.nOilPress		= props.globals.getNode("/fdm/jsbsim/aircraft/engine/OP-psi");
		m.nStarter		= props.globals.getNode("/controls/engines/engine[0]/starter");
		
		m._cutoffState		= m.nCutOff.getValue();
		m._ignitionState 	= 0;
		m.IgnitionPlus 		= Part.ElectricConnector.new("IgnitionPlus");
		m.LowOilPress		= Part.ElectricConnector.new("LowOilPress");
		m.LowPitch		= Part.ElectricConnector.new("LowPitch");
		m.GND 			= Part.ElectricConnector.new("GND");
		
		m.LowTorquePress = Part.ElectricSwitchDT.new(m.nRoot.initNode("LowTorquePress"),"Low Torque Pressure");
		m.LowTorquePress.setPoles(1);
		
		
		
		m.IgnitionPlus.solder(m);
		m.GND.solder(m);
		m.LowOilPress.solder(m);
		m.LowPitch.solder(m);
		
		append(Part.aListSimStateAble,m);
		return m;
		
	},
	#################################################
	# called at the end from main simulation cycle 
	# to reset the values back to default
	#################################################
	simReset : func(){
		me.nIgnition.setValue(me._ignitionState);
		me._checkIgnitionCutoff();
		me._ignitionState = 0;
		me._starterState = 0;
	},
	#################################################
	# called at the end from main simulation cycle 
	# to update the property tree with the final value 
	# to avoid jummping values while cycle running
	#################################################
	simUpdate : func(){
		me.nIgnition.setValue(me._ignitionState);
	},
	#################################################
	# the electric Power comes here
	#################################################
	applyVoltage : func(electron,name=""){ 
		Part.etd.in("Engine",me.name,name,electron);
		var GND = 0;
		
		if (electron != nil){
			me.setVolt(electron.volt);
			
			if (name == "IgnitionPlus"){
				electron.resistor += me.resistor;# * me.qos
			
				GND = me.GND.applyVoltage(electron);
				if (GND){
					me._ignitionState = 1;
					me._checkIgnitionCutoff();
					var watt = me.electricWork(electron);
				}
			}elsif(name == "LowOilPress"){
				
				if (me.nOilPress.getValue() < 35.0){
					GND = me.GND.applyVoltage(electron);
				}
			}elsif(name == "LowPitch"){
				
				if (me.nReverser.getValue() == 1 and me.nThrottle.getValue() > 0.1){
					GND = me.GND.applyVoltage(electron);
				}
			}
			
			me.setAmpere(electron.ampere);
		}
		Part.etd.out("Engine",me.name,name,electron);
		return GND;
	},
	plugElectric : func(){
		
	},
	_checkIgnitionCutoff : func(){
		if (me.nIsRunning.getValue()){
			me.nCutOff.setValue(me._cutoffState);
		}else{
			if (me._ignitionState == 1 and me._cutoffState == 0){
				me.nCutOff.setValue(0);
			}else{
				me.nCutOff.setValue(1);
			}
		}

	},
	onCutoffClick : func(value = nil){
		if (value == nil){
			me._cutoffState = me._cutoffState == 0 ? 1 : 0 ;
		}else{
			me._cutoffState = value == 0 ? 0 : 1 ;
		}
		
		if (me._cutoffState == 0 and me.nIsRunning.getValue() == 0){
			var n1 = me.nN1.getValue();
			if (n1 > 12.0){
				UI.msg.warning("Flame-Out : Turbine wird beschädigt wenn Treibstoff erst bei N1 > 12.0 % eingespritzt wird. Inspektion erforderlich.");
			}
			if (n1 < 8.0){
				UI.msg.warning("Hot-Start : Turbine wird beschädigt wenn Treibstoff schon bei N1 < 8.0 % eingespritzt wird. Inspektion erforderlich.");
			}
		}
		
		me._checkIgnitionCutoff();
	},
	onReverserClick : func(value = nil){
		if (me.nThrottle.getValue() < 0.01) {
			if (value == nil){
				me.nReverser.setValue(!me.nReverser.getValue());
			}else{
				me.nReverser.setValue(value);
			}
		}
	},

	#################################################
	# called from main simulation cycle in ~ 10Hz	
	# all work that the engine has to do starts here
	#################################################
	simulationUpdate : func(now,dt){

# setting Low Torque Pressure Switch < 15.0
		if(me.nTRQ.getValue() < 35.0){
			me.LowTorquePress._setValue(1);
		}else{
			me.LowTorquePress._setValue(0);
		}

#
	},
	#################################################
	# register User events 	
	# so all click able surfaces dialogs keyboard joystick bindings can execute 
	# UI.click("registered string");
	#################################################
	initUI : func(){
		UI.register("Engine cutoff", 		func{extra500.engine.onCutoffClick(); } 	);
		UI.register("Engine cutoff on",		func{extra500.engine.onCutoffClick(1); } 	);
		UI.register("Engine cutoff off",	func{extra500.engine.onCutoffClick(0); } 	);
		
		UI.register("Engine reverser", 		func{extra500.engine.onReverserClick(); } 	);
		UI.register("Engine reverser on",	func{extra500.engine.onReverserClick(1); } 	);
		UI.register("Engine reverser off",	func{extra500.engine.onReverserClick(0); } 	);

	}
};

var engine = Engine.new(props.globals.initNode("/extra500/engine"),"RR 250-B17F2");
engine.setPower(24.0,5.0);
