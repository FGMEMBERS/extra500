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
		
		m.dimmingVolt = 0.0;
		m.powered = 0;
		
		m.TRQ = 0.0;
		m.TOT = 0.0;
		m.N1 = 0.0;
		m.RPM = 0.0;
		m.OP = 0.0;
		m.OT = 0.0;
		
		m.TargetTRQ = 0.0;
		m.TargetTOT = 0.0;
		m.TargetN1 = 0.0;
		m.TargetRPM = 0.0;
		m.TargetOP = 0.0;
		m.TargetOT = 0.0;
		
		
		m.nTRQ = props.globals.initNode("/fdm/jsbsim/aircraft/engine/TRQ-perc",0.0,"DOUBLE"); # 0-125
		m.nTOT = props.globals.initNode("/fdm/jsbsim/aircraft/engine/TOT-degC",0.0,"DOUBLE"); # 0-1000
		m.nN1 = props.globals.initNode("/fdm/jsbsim/aircraft/engine/N1-par",0.0,"DOUBLE"); # 0-110
		m.nN2 = props.globals.initNode("/engines/engine/thruster/rpm",0.0,"DOUBLE"); # 0-2500
		m.nOP = props.globals.initNode("/fdm/jsbsim/aircraft/engine/OP-psi",0.0,"DOUBLE"); # 0-150
		m.nOT = props.globals.initNode("/fdm/jsbsim/aircraft/engine/OT-degC",0.0,"DOUBLE"); # 0-120
		
		
				
	# nodes for indication must be abs(value)
		m.nIndicatedTRQ = nRoot.initNode("indicated-TRQ",0.0,"DOUBLE");
		m.nIndicatedTOT = nRoot.initNode("indicated-TOT",0.0,"DOUBLE");
		
		m.nIndicatedN1 = nRoot.initNode("indicated-N1",0.0,"DOUBLE");
		m.nIndicatedRPM = nRoot.initNode("indicated-RPM",0.0,"DOUBLE");
		
		m.nIndicatedOP = nRoot.initNode("indicated-OP",0.0,"DOUBLE");
		m.nIndicatedOT = nRoot.initNode("indicated-OT",0.0,"DOUBLE");
		
	# Light
		m.Backlight = Part.ElectricLED.new(m.nRoot.initNode("Backlight"),"EIP Backlight");
		m.Backlight.electricConfig(8.0,28.0);
		m.Backlight.setPower(24.0,3.0);
	
	# buses
		m.PowerInputBus = Part.ElectricBusDiode.new("PowerInputBus");
		m.GNDBus = Part.ElectricBusDiode.new("GNDBus");
		m.PowerBus = Part.ElectricBus.new("PowerBus");
		
		
		
	# Electric Connectors
		m.PowerInputA 		= Part.ElectricPin.new("PowerInputA");
		m.PowerInputB 		= Part.ElectricPin.new("PowerInputB");
		m.GND 			= Part.ElectricPin.new("GND");
		m.Dimming		= Part.ElectricConnector.new("Dimming");
		
		m.__GND			= Part.ElectricConnector.new("__GND");
		m.__Power		= Part.ElectricConnector.new("__Power");
		
		m.Dimming.solder(m);
		m.__Power.solder(m);
		m.__GND.solder(m);
	# list for main loop to reset the "state" variable to default
		append(Part.aListSimStateAble,m);
		return m;

	},
	# electric system calls applyVoltage to get electicity in
	applyVoltage : func(electron,name=""){ 
		Part.etd.in("EIP",me.name,name,electron);
		var GND = 0;
		electron.resistor += 20000.0;
				
		if (electron != nil){
			if (name == "__Power"){
				GND = me.__GND.applyVoltage(electron);
				if (GND){
					me.state = 1;
					var watt = me.electricWork(electron);
				}
			}elsif(name == "Dimming"){
				
				GND = me.__GND.applyVoltage(electron);
				if (GND){
					
					me.dimmingVolt = electron.volt;					
					var watt = me.electricWork(electron);
					
					
				}
			}
		}
		
		Part.etd.out("EIP",me.name,name,electron);
		return GND;
	},
	plugElectric : func(){
		
		me.PowerInputA.plug(me.PowerInputBus.con());
		me.PowerInputB.plug(me.PowerInputBus.con());
		me.PowerInputBus.Minus.plug(me.PowerBus.con());
		
		me.Backlight.Plus.plug(me.PowerBus.con());
		me.Backlight.Minus.plug(me.GNDBus.con());
		
		me.__Power.plug(me.PowerBus.con());
		me.__GND.plug(me.GNDBus.con());
		
		me.GNDBus.Minus.plug(me.GND);
	},
	_move : func(value,target,min,max,rate){
		var maxIntervall = (max-min)*rate;
		
		var dif = target-value;
		if (math.abs(dif) > maxIntervall){
			if (dif>0){
				value += maxIntervall;
			}else{
				value -= maxIntervall;
			}
		}else{
			value = target;
		}
		
		if (value > max){ value=max}
		if (value < min){ value=min}
		
		return value;
	},
	_dimmBacklight : func(){
		if (me.dimmingVolt < 8.0){
			me.Backlight.setBrightness(1.0);
		}else{
			me.Backlight.setBrightness( me.dimmingVolt / 28.0);
		}
		me.dimmingVolt = 0.0;
	},
	# Main Simulation loop  ~ 10Hz
	update : func(timestamp){
		me.powered = me.state;
		me._dimmBacklight();
		
	},
	animationUpdate : func (timestamp){
		
		if (me.powered == 0){	# no power input
			
			me.TargetTRQ 	= 0.0;
			me.TargetTOT 	= 0.0;
			me.TargetN1	= 0.0;
			me.TargetRPM 	= 0.0;
			me.TargetOP 	= 0.0;
			me.TargetOT 	= 0.0;
			
			
			me.TRQ 	= me._move(me.TRQ, me.TargetTRQ, 0.0,  125.0, 0.05);
			me.TOT 	= me._move(me.TOT, me.TargetTOT, 0.0, 1000.0, 0.05);
			me.N1 	= me._move(me.N1,  me.TargetN1,  0.0,  110.0, 0.05);
			me.RPM 	= me._move(me.RPM, me.TargetRPM, 0.0, 2500.0, 0.05);
			me.OP 	= me._move(me.OP,  me.TargetOP,  0.0,  150.0, 0.05);
			me.OT 	= me._move(me.OT,  me.TargetOT,  0.0,  120.0, 0.05);
		

		
		}else{
			
# 			me.TRQ 	= me.nTRQ.getValue();
# 			me.TOT 	= me.nTOT.getValue();
# 			me.N1	= me.nN1.getValue();
# 			me.RPM 	= me.nN2.getValue();
# 			me.OP 	= me.nOP.getValue();
# 			me.OT 	= me.nOT.getValue();
			
			
		
			me.TargetTRQ 	= me.nTRQ.getValue();
			me.TargetTOT 	= me.nTOT.getValue();
			me.TargetN1	= me.nN1.getValue();
			me.TargetRPM 	= me.nN2.getValue();
			me.TargetOP 	= me.nOP.getValue();
			me.TargetOT 	= me.nOT.getValue();
			
			me.TRQ 	= me._move(me.TRQ, me.TargetTRQ, 0.0,  125.0, 0.2);
			me.TOT 	= me._move(me.TOT, me.TargetTOT, 0.0, 1000.0, 0.2);
			me.N1 	= me._move(me.N1,  me.TargetN1,  0.0,  110.0, 0.2);
			me.RPM 	= me._move(me.RPM, me.TargetRPM, 0.0, 2500.0, 0.2);
			me.OP 	= me._move(me.OP,  me.TargetOP,  0.0,  150.0, 0.2);
			me.OT 	= me._move(me.OT,  me.TargetOT,  0.0,  120.0, 0.2);
		
		}
		
		
		# set the indecated values to the tree + 0.0001 to avoid bad round
		me.nIndicatedTRQ.setValue( me.TRQ + 0.000001 );
		me.nIndicatedTOT.setValue( me.TOT + 0.000001 );
		me.nIndicatedN1.setValue(  me.N1 + 0.000001 );
		me.nIndicatedRPM.setValue( me.RPM + 0.000001 );
		me.nIndicatedOP.setValue(  me.OP + 0.000001 );
		me.nIndicatedOT.setValue(  me.OT + 0.000001 );
		
	}
	
};

var engineInstrumentPackage = EngineInstrumentPackage.new(props.globals.initNode("extra500/instrumentation/EIP"),"Engine Instrument Package");
