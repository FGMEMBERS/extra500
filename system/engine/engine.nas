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
#      Date:             09.05.13
#


var Engine = {
	new : func(nRoot,name){
		var m = {parents:[
			Engine,
			Part.Part.new(nRoot,name),
			Part.ElectricAble.new(nRoot,name)
		]};
		m.nIsRunning		= props.globals.getNode("/fdm/jsbsim/propulsion/engine/set-running");
		m.nN1			= props.globals.getNode("/engines/engine[0]/n1");
		m.nN1old		= props.globals.getNode("/fdm/jsbsim/aircraft/engine/N1-old");
		m.nPropellerFeather 	= props.globals.getNode("/controls/engines/engine[0]/propeller-feather");
		m.nCutOff		= props.globals.getNode("/controls/engines/engine[0]/cutoff");
		m.nReverser		= props.globals.getNode("/controls/engines/engine[0]/reverser");
		m.nThrottle		= props.globals.getNode("/controls/engines/engine[0]/throttle");
		m.nIgnition		= props.globals.getNode("/controls/engines/engine[0]/ignition");
		m.nOilPress		= props.globals.getNode("/fdm/jsbsim/aircraft/engine/OP-psi");
		m.nStarter		= props.globals.getNode("/controls/engines/engine[0]/starter");
		m.nMotoring		= props.globals.getNode("/fdm/jsbsim/aircraft/engine/motoring");
		m.nSpoolup		= props.globals.getNode("/fdm/jsbsim/aircraft/engine/spooling-up");
		m.nSpooldown		= props.globals.getNode("/fdm/jsbsim/aircraft/engine/spooling-down");
		
		m.n1old = 0.0;
		m.n1 = 0.0;
		m.Starter = 0.0;
		m.isRunning = 0.0;
		
		m._cutoffState		= m.nCutOff.getValue();
		m._ignitionState 	= 0;
		m.IgnitionPlus 		= Part.ElectricConnector.new("IgnitionPlus");
		m.LowOilPress		= Part.ElectricConnector.new("LowOilPress");
		m.LowPitch		= Part.ElectricConnector.new("LowPitch");
		m.GND 			= Part.ElectricConnector.new("GND");
		
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
	update : func(){
		me.n1old = me.nN1old.getValue();
		me.n1 = me.nN1.getValue();
		me.Starter = me.nStarter.getValue();
		me.isRunning = me.nIsRunning.getValue();

# setting propeller feathering property, if n1 < 55%, feathered
		if(me.n1 > 55.0){
			me.nPropellerFeather.setValue(0);
		}else{
			me.nPropellerFeather.setValue(1);
		}

# setting motoring property: starter on, but cutoff also on (no fuel,no ignition)	
		if ( (me.Starter == 1) and (me._cutoffState == 1) ) {
			me.nMotoring.setValue(1);
		}else{
			me.nMotoring.setValue(0);
		}

# setting spoolup property: starter on, no cutoff, but engine not running (yet) 	
		if ( (me.Starter == 1) and (me._cutoffState == 0) and (me.isRunning == 0)  ) {
			me.nSpoolup.setValue(1);
		}else{
			me.nSpoolup.setValue(0);
		}

# setting spooldown property: starter off, not running, and n1 > 0.1 	
		if ( (me.Starter == 0) and (me.isRunning == 0) and (me.n1 > 0.1) and (me.n1 < me.n1old ) ) {
			me.nSpooldown.setValue(1);
		}else{
			me.nSpooldown.setValue(0);
		}

		me.nN1old.setValue(me.n1);
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

var engine = Engine.new(props.globals.initNode("/extra500/Engine"),"RR 250-B17F2");
engine.setPower(24.0,5.0);


# ENGINE TEMPERATURES
#var calc_Temps = func() {
var calcTemps = {
	new : func{
		var m = {parents:[calcTemps]};
		m.ndt		= props.globals.getNode("/fdm/jsbsim/aircraft/engine/dt-indication");
		m.nOAT		= props.globals.getNode("/environment/temperature-degc");
		m.nFuelMass	= props.globals.getNode("/fdm/jsbsim/propulsion/total-fuel-lbs");
		m.nOT		= props.globals.getNode("/fdm/jsbsim/aircraft/engine/OT-degC");
		m.nFT		= props.globals.getNode("/fdm/jsbsim/aircraft/engine/FT-degC");
		m.nTOT		= props.globals.getNode("/fdm/jsbsim/aircraft/engine/TOT-degC");
		m.nDeltaOT	= props.globals.getNode("/fdm/jsbsim/aircraft/engine/Delta-OT-degC");

		m.dt = 0.0;
		m.OAT = 0.0;
		m.Fuelmass = 0.0;
		m.OT = 0.0;
		m.FT = 0.0;
		m.TOT = 0.0;
		m.OTnew = 0.0;
		m.H = 0.0;
		m.dE = 0.0;
		m.FTnew = 0.0;

		return m;
		
	},


	update : func(){
			# getting common values
		me.dt = me.ndt.getValue();
		me.OAT = me.nOAT.getValue();
		me.FuelMass = me.nFuelMass.getValue() * global.CONST.LBM2KG;				# fuel mass in tank in kg

			# getting old values
		me.OT = me.nOT.getValue();
		me.FT = me.nFT.getValue();
		me.TOT = me.nTOT.getValue();

			# calculating new oil temperature
		me.OTnew = me.OT + me.nDeltaOT.getValue();
		if (me.OTnew < me.OAT) {
			me.OTnew = me.OAT;
		}
		me.nOT.setValue( me.OTnew );

			# calculating new fuel temperature
		me.H = 0.00481 * me.FT + 1.7833;							# Jet-A1 fuel specific energy kJ/kg-K
		me.dE = 0.028 * (me.OAT - me.FT);							# energy loss kW
		me.FTnew = me.FT + me.dE * me.dt / (me.FuelMass * me.H);				# new temp due to energy loss to outside air
		me.nFT.setValue( me.FTnew );
#
# setting aliases for fuel pumps
		setprop("/fdm/jsbsim/aircraft/fuel/fuel-pump1",getprop("extra500/Fuel/FuelPump1/state") or 0);
		setprop("/fdm/jsbsim/aircraft/fuel/fuel-pump2",getprop("extra500/Fuel/FuelPump2/state") or 0);

	}
};

var oCalcTemps = calcTemps.new();

var init_Temps = func{
      if (getprop("/fdm/jsbsim/simulation/sim-time-sec") > 1) {				# to make sure we get an "initialised" temperature
		setprop("/fdm/jsbsim/aircraft/engine/temp_init",1);
		var OAT = getprop("/environment/temperature-degc");
		setprop("/fdm/jsbsim/aircraft/engine/OT-degC",OAT); 		
		setprop("/fdm/jsbsim/aircraft/engine/FT-degC",OAT); 
		setprop("/fdm/jsbsim/aircraft/engine/TOTnr-degC",OAT);
		loop();
		
	} else {
		settimer(init_Temps, 1);						# timer gets destroyed when sim-time-sec >1sec
	}
}

var loop =func{
	var dt = getprop("/fdm/jsbsim/aircraft/engine/dt-indication");
	oCalcTemps.update();
	settimer(loop,dt);
}

setlistener("/sim/signals/fdm-initialized", func {
    init_Temps();
});
