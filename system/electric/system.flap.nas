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
#      Date: April 20 2013
#
#      Last change:      Dirk Dittmann
#      Date:             29.04.13
#

#MM Page 580

var FlapSystem = {
	new : func(nRoot,name){
		var m = {parents:[
			FlapSystem,
			Part.GearAble.new(0.016)
		]};
		m.nRoot = nRoot;
		
		m.nFlaps 	= props.globals.getNode("/controls/flight/flaps");
		m.nFlapPosition      = props.globals.initNode("/fdm/jsbsim/fcs/flap-pos-norm",0.0,"DOUBLE");
		m.nFlapCmdPosition    = props.globals.initNode("/fdm/jsbsim/fcs/flap-wp-cmd-norm",0.0,"DOUBLE");
		m.nFlapMotorPosition = props.globals.initNode("/fdm/jsbsim/fcs/flap-wp-motor-norm",0.0,"DOUBLE");
		
		
		m.flapPosition = 0;
		
		m.switchFlapPosition = {};
		m.switchFlapPosition[-1]= 1.0;
		m.switchFlapPosition[0]= 0.5;
		m.switchFlapPosition[1]= 0.0;
		
		
		m.switch = Part.ElectricSwitchTT.new(m.nRoot.initNode("Switch"),"Flap Switch",1);
		m.switch.setPoles(1);
				
		m.motor = Part.ElectricMotor.new(m.nRoot.initNode("Motor"),"Motor");
		m.motor.electricConfig(12.0,28.0);
		m.motor.setPower(24.0,35.0);
		m.motor.connectGear(m);
		
		
	# relais
		
		m.upRelais = Part.ElectricRelaisXPDT.new(m.nRoot.initNode("RelaisUp"),"Flap Relais Up");
		m.upRelais.setPoles(1);
		
		m.downRelais = Part.ElectricRelaisXPDT.new(m.nRoot.initNode("RelaisDown"),"Flap Relais Down");
		m.downRelais.setPoles(1);
		
		m.pos14Relais = Part.ElectricRelaisXPDT.new(m.nRoot.initNode("RelaisPos14"),"Flap Relais Position 14");
		m.pos14Relais.setPoles(3);
		
		m.pos15Relais = Part.ElectricRelaisXPDT.new(m.nRoot.initNode("RelaisPos15"),"Flap Relais Position 15");
		m.pos15Relais.setPoles(3);
		
		m.transitionRelais = Part.ElectricRelaisXPST.new(m.nRoot.initNode("RelaisTransition"),"Flap Relais Transition");
		m.transitionRelais.setPoles(1);
		m.transitionRelais.resistor = 0.0;
		
		m.flapUnbRelais = Part.ElectricRelaisXPDT.new(m.nRoot.initNode("FlapUnbRelais"),"Flap UNB Relais");
		m.flapUnbRelais.setPoles(1);
		
	# switches
		m.limitUp = Part.ElectricSwitchDT.new(m.nRoot.initNode("SwitchLimitUp"),"Flap Switch Limit Up");
		m.limitUp.setPoles(1);
		
		m.limitDown = Part.ElectricSwitchDT.new(m.nRoot.initNode("SwitchLimitDown"),"Flap Switch Limit Down");
		m.limitDown.setPoles(2);
		
		# 13CG
		m.limit14 = Part.ElectricSwitchDT.new(m.nRoot.initNode("SwitchLimit14"),"Flap Switch Limit 14");
		m.limit14.setPoles(1);
		
		# 14CG
		m.limit15 = Part.ElectricSwitchDT.new(m.nRoot.initNode("SwitchLimit15"),"Flap Switch Limit 15");
		m.limit15.setPoles(2);
		
		
		m.GNDBus = Part.ElectricBusDiode.new("#GNDBus");
		
		m.flapPowerBus = Part.ElectricBus.new("flapPowerBus");
		m.powerInBus = Part.ElectricBus.new("PowerInBus");
		m.inhibitBus = Part.ElectricBus.new("InhibitBus");
		m.iSwitch0Bus = Part.ElectricBus.new("#iSwitch0Bus");
		m.iSwitch15Bus = Part.ElectricBusDiode.new("#iSwitch15Bus");
		m.iSwitch30Bus = Part.ElectricBus.new("#iSwitch30Bus");
		
				
		return m;
		
	},
	driveShaft : func(input){
		
		me.gearOutput = input * me.gearRatio;
		
		
	},
	applyVoltage : func(electron,name=""){
		var GND = 0;

		return GND;
	},
	simulationUpdate : func(now,dt){
		me.flapPosition = me.nFlapPosition.getValue();
		
		
		if(me.flapPosition >= 1.0){
			me.limitDown._setValue(1);
			me.limit15._setValue(1);
			me.limit14._setValue(1);
			me.limitUp._setValue(0);
			
		}elsif(me.flapPosition > 0.50){
			me.limitDown._setValue(0);
			me.limit15._setValue(1);
			me.limit14._setValue(1);
			me.limitUp._setValue(0);
		}elsif(me.flapPosition >= 0.46666){
			me.limitDown._setValue(0);
			me.limit15._setValue(0);
			me.limit14._setValue(1);
			me.limitUp._setValue(0);
		}elsif (me.flapPosition > 0){
			me.limitDown._setValue(0);
			me.limit15._setValue(0);
			me.limit14._setValue(0);
			me.limitUp._setValue(0);
		}elsif (me.flapPosition <= 0){
			me.limitDown._setValue(0);
			me.limit15._setValue(0);
			me.limit14._setValue(0);
			me.limitUp._setValue(1);
		}
		
	#drive switch cmd position
		if (me.gearOutput == 0.0){
			me.nFlapCmdPosition.setValue(me.flapPosition);
		}else{
			me.nFlapCmdPosition.setValue(me.switchFlapPosition[me.switch.state]);
		}
		
	#drive motor position
		me.flapPosition += me.gearOutput;
		
		if (me.flapPosition > 1.0) { me.flapPosition = 1.0 };
		if (me.flapPosition < 0.0) { me.flapPosition = 0.0 };
						
		me.nFlapMotorPosition.setValue(me.flapPosition);
		
	#drive the old fg system
		me.nFlaps.setValue(me.flapPosition);
		#me.nFlaps.setValue(me.switchFlapPosition[me.switch.state]);
		
		me.gearOutput = 0.0;
		
	},
	plugElectric : func(){
		
		
		
		me.flapPowerBus.plug(me.downRelais.P11);
		me.flapPowerBus.plug(me.upRelais.P11);
		
		me.inhibitBus.plug(me.pos14Relais.A1);
		me.inhibitBus.plug(me.pos15Relais.A1);
		me.inhibitBus.plug(me.upRelais.A1);
		me.inhibitBus.plug(me.downRelais.A1);
				
		me.pos14Relais.P14.plug(me.pos15Relais.P11);
		me.pos14Relais.P22.plug(me.pos15Relais.P21);
		me.pos14Relais.P34.plug(me.pos15Relais.P31);
		
		me.pos15Relais.P32.plug(me.GNDBus.con());
		
		me.flapUnbRelais.A1.plug(me.inhibitBus.con());
		me.flapUnbRelais.A2.plug(me.GNDBus.con());
		me.flapUnbRelais.P11.plug(me.GNDBus.con());
		
		
	#main switch	
		me.switch.Com1.plug(me.GNDBus.con());
		me.switch.L11.plug(me.iSwitch0Bus.con());
		me.switch.L12.plug(me.iSwitch15Bus.Minus);
		me.switch.L13.plug(me.iSwitch30Bus.con());
		
		me.iSwitch0Bus.plug(me.upRelais.A2);
		me.iSwitch0Bus.plug(me.pos15Relais.P14);
		
		me.iSwitch15Bus.plug(me.pos14Relais.P11);
		me.iSwitch15Bus.plug(me.pos14Relais.P21);
		
		me.iSwitch30Bus.plug(me.pos15Relais.P22);
		me.iSwitch30Bus.plug(me.downRelais.A2);
		
	#motor
		me.downRelais.P14.plug(me.limitDown.Com1);
		me.limitDown.L11.plug(me.motor.PlusRight);
				
		me.upRelais.P14.plug(me.limitUp.Com1);
		me.limitUp.L11.plug(me.motor.PlusLeft);
		
		me.motor.Minus.plug(me.transitionRelais.A1);
		me.transitionRelais.A2.plug(me.GNDBus.con());
	#limit
				
		me.limit14.Com1.plug(me.GNDBus.con());
		me.limit14.L12.plug(me.pos14Relais.A2);
		
		me.limit15.Com1.plug(me.GNDBus.con());
		me.limit15.L12.plug(me.pos15Relais.A2);
		
		me.limit15.Com2.plug(me.GNDBus.con());
		#me.limit15.L12.plug(me.pos15Relais.A2); # gear warining
		
		me.limitDown.Com2.plug(me.GNDBus.con());
		me.transitionRelais.P14.plug(me.GNDBus.con());
		
				
		
	},
	initUI : func(){
		UI.register("Flaps down", 	func{extra500.flapSystem.switch.left(); } 	);
		UI.register("Flaps up",		func{extra500.flapSystem.switch.right(); } 	);
		UI.register("Flaps 0", 		func{extra500.flapSystem.switch.setValue(1); } 	);
		UI.register("Flaps 15", 	func{extra500.flapSystem.switch.setValue(0); } 	);
		UI.register("Flaps 30", 	func{extra500.flapSystem.switch.setValue(-1); } );
		
	}
	
};

var flapSystem = FlapSystem.new(props.globals.initNode("extra500/system/flap"),"Flap Control");