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
#      Date:             26.04.13
#

var GearSystem = {
	new : func(nRoot,name){
		var m = {parents:[
			GearSystem,
			Part.Part.new(nRoot,name),
			Part.ElectricAble.new(nRoot,name)
		]};
		
		
		m.nGearControl = props.globals.getNode("/controls/gear/gear-down",1);
		m.nNoseGearWOW = props.globals.getNode("/gear/gear[0]/wow",1);
		m.nNoseGearPosition = props.globals.getNode("/gear/gear[0]/position-norm",1);
		m.nLeftGearPosition = props.globals.getNode("/gear/gear[1]/position-norm",1);
		m.nRightGearPosition = props.globals.getNode("/gear/gear[2]/position-norm",1);
		m.listener = nil;
		
		me.NoseGearWOW = 0;
		me.NoseGearPosition = 0.0;
		me.LeftGearPosition = 0.0;
		me.RightGearPosition = 0.0;
		
	# gear switches
		m.MainGearSwitch = Part.ElectricSwitchDT.new(m.nRoot.initNode("MainGearSwitch"),"Main Gear Switch",1);
		m.MainGearSwitch.setPoles(1);
		
		
		m.NoseGearUp = Part.ElectricSwitchDT.new(m.nRoot.initNode("NoseGearUp"),"Gear Nose Up Switch",0);
		m.NoseGearUp.setPoles(2);
		
		m.NoseGearDown = Part.ElectricSwitchDT.new(m.nRoot.initNode("NoseGearDown"),"Gear Nose Down Switch",0);
		m.NoseGearDown.setPoles(2);
		
		m.NoseGearSquat = Part.ElectricSwitchDT.new(m.nRoot.initNode("NoseGearSquat"),"Gear Nose Squat Switch",0);
		m.NoseGearSquat.setPoles(4);
		
		m.RightGearUp = Part.ElectricSwitchDT.new(m.nRoot.initNode("RightGearUp"),"Gear Right Up Switch",0);
		m.RightGearUp.setPoles(2);
		
		m.RightGearDown = Part.ElectricSwitchDT.new(m.nRoot.initNode("RightGearDown"),"Gear Right Down Switch",0);
		m.RightGearDown.setPoles(2);
		
		m.LeftGearUp = Part.ElectricSwitchDT.new(m.nRoot.initNode("LeftGearUp"),"Gear Left Up Switch",0);
		m.LeftGearUp.setPoles(2);
		
		m.LeftGearDown = Part.ElectricSwitchDT.new(m.nRoot.initNode("LeftGearDown"),"Gear Left Down Switch",0);
		m.LeftGearDown.setPoles(2);
		
		
	# door switches
		
		m.RightDoorUpper = Part.ElectricSwitchDT.new(m.nRoot.initNode("RightDoorUpper"),"Right Door Upper",0);
		m.RightDoorUpper.setPoles(2);
		
		m.LeftDoorUpper = Part.ElectricSwitchDT.new(m.nRoot.initNode("LeftDoorUpper"),"Left Door Upper",0);
		m.LeftDoorUpper.setPoles(2);
		
		m.LowerDoor = Part.ElectricSwitchDT.new(m.nRoot.initNode("LowerDoor"),"Lower Door",0);
		m.LowerDoor.setPoles(2);
		
	# relais
		m.HydraulicMotorRelais = Part.ElectricRelaisXPST.new(m.nRoot.initNode("LowerDoor"),"Lower Door");
		m.HydraulicMotorRelais.setPoles(2);
	
	# Electic Connector
		
		m.GND 		= Part.ElectricPin.new("GND");
		m.CTRL		= Part.ElectricPin.new("GearCTRL");		#  1 	GA3F-22
		m.Relais34GA	= Part.ElectricPin.new("Relais34GA");		#  2 	GA3C-22
		m.SwitchOn	= Part.ElectricPin.new("GearSwitchOn");		#  3 	GA08F-22
		m.SwitchOff	= Part.ElectricPin.new("GearSwitchOff");	#  4 	GA09F-22
		m.RightGearLed	= Part.ElectricPin.new("RightGearLed");		#  5	GA24F-22
		m.NoseGearLed	= Part.ElectricPin.new("NoseGearLed");		#  6	GA25F-22
		m.LeftGearLed	= Part.ElectricPin.new("LeftGearLed");		#  7	GA26F-22
		
		m.Warning	= Part.ElectricPin.new("GearWarning");		#  8 	GA37G-22
		m.Aux2		= Part.ElectricPin.new("GearAux2");		#  9	GA34G-22
		m.Aux1		= Part.ElectricPin.new("GearAux1");		# 10 	GA37G-22
		m.Relais35GA	= Part.ElectricPin.new("Relais35GA");		# 11 	GA43-22
		m.Annunciator	= Part.ElectricPin.new("Annunciator");		# 12 	GA53F-22
		m.TAS		= Part.ElectricPin.new("TAS");			# 13 	SD14F-22
		
		
		m.GNDBus = Part.ElectricBusDiode.new("GNDBus");
		m.Modul3 = Part.ElectricBus.new("Modul3");
		
		
# 		m.GND.solder(m);
# 		m.NoseGearLed.solder(m);
# 		m.LeftGearLed.solder(m);
# 		m.RightGearLed.solder(m);
		
		return m;
		
	},
	applyVoltage : func(electron,name=""){
				
		if (name == "NoseGearLed" and me.nNoseGearPosition.getValue() == 1.0){
			me.GND.applyVoltage(electron);
		}elsif (name == "LeftGearLed" and me.nLeftGearPosition.getValue() == 1.0){
			me.GND.applyVoltage(electron);
		}elsif (name == "RightGearLed" and me.nRightGearPosition.getValue() == 1.0){
			me.GND.applyVoltage(electron);
		}
		
		
	},
	plugElectric : func(){
		#--- plug outside
		
		
		
		me.CTRL.plug(me.MainGearSwitch.Com1);			
		me.MainGearSwitch.L11.plug(me.SwitchOff);
		me.MainGearSwitch.L12.plug(me.SwitchOn);
		#---
				
		me.GND.plug(me.GNDBus.Minus);
		me.CTRL.plug(me.HydraulicMotorRelais.A1);		#  1
		me.Relais34GA.plug(me.NoseGearSquat.L22);		#  2
		me.SwitchOn.plug(me.Modul3.con());			#  3
		me.SwitchOff.plug(me.RightGearDown.Com2);		#  4
		me.RightGearLed.plug(me.RightGearDown.L12);		#  5
		me.NoseGearLed.plug(me.NoseGearDown.L21);		#  6
		me.LeftGearLed.plug(me.LeftGearDown.L22);		#  7
		me.Warning.plug(me.NoseGearUp.L11);			#  8
		me.Aux2.plug(me.NoseGearDown.Com1);			#  9
		me.Aux1.plug(me.NoseGearDown.L12);			# 10
		me.Relais35GA.plug(me.NoseGearSquat.L42);		# 11
		me.Annunciator.plug(me.HydraulicMotorRelais.P24);	# 12
		
		
		me.RightGearDown.Com1.plug(me.GNDBus.con());
		me.NoseGearDown.Com2.plug(me.GNDBus.con());
		me.LeftGearDown.Com2.plug(me.GNDBus.con());

		
		
		
	},
	# Main Simulation loop  ~ 10Hz
	update : func(){
	
		me.NoseGearWOW = me.nNoseGearWOW.getValue();
		me.NoseGearPosition = me.nNoseGearPosition.getValue();
		me.LeftGearPosition = me.nLeftGearPosition.getValue();
		me.RightGearPosition = me.nRightGearPosition.getValue();
		
	# Limit swicht
		#Nose gear
		if (me.NoseGearPosition == 1.0){
			me.NoseGearUp.off();
			me.NoseGearDown.on();
		}elsif(me.NoseGearPosition == 0.0){
			me.NoseGearUp.on();
			me.NoseGearDown.off();
		}else{
			me.NoseGearDown.off();
			me.NoseGearUp.off();
		}
		
		if (me.RightGearPosition == 1.0){
			me.RightGearUp.off();
			me.RightGearDown.on();
		}elsif(me.RightGearPosition == 0.0){
			me.RightGearUp.on();
			me.RightGearDown.off();
		}else{
			me.RightGearDown.off();
			me.RightGearUp.off();
		}
		
		if (me.LeftGearPosition == 1.0){
			me.LeftGearUp.off();
			me.LeftGearDown.on();
		}elsif(me.LeftGearPosition == 0.0){
			me.LeftGearUp.on();
			me.LeftGearDown.off();
		}else{
			me.LeftGearDown.off();
			me.LeftGearUp.off();
			
		}
		
	#squat switch
		if (me.NoseGearWOW == 1){
			me.NoseGearSquat.on();
		}else{
			me.NoseGearSquat.off();
		}
		
	# door switches
	
		if (me.RightGearPosition >= 0.9){
			me.RightDoorUpper.on();
		}elsif(me.RightGearPosition == 0.0){
			me.RightDoorUpper.on();
		}else{
			me.RightDoorUpper.off();
		}
		
		if (me.LeftGearPosition >= 0.9){
			me.LeftDoorUpper.on();
		}elsif(me.LeftGearPosition == 0.0){
			me.LeftDoorUpper.on();
		}else{
			me.LeftDoorUpper.off();
		}
		
		if(me.NoseGearPosition == 0.0){
			me.LowerDoor.on();
		}else{
			me.LowerDoor.off();
		}
		
		
	},
	onGearClick : func(value=nil){
		if (value==nil){
			value =  !me.nGearControl.getValue()  ;
		}else{
			me.nGearControl.setValue(value);
		}
		
		me.nGearControl.setValue(value);
 	},
	#################################################
	# register User events 	
	# so all click able surfaces dialogs keyboard joystick bindings can execute 
	# UI.click("registered string");
	#################################################
	initUI : func(){
		UI.register("Gear", 		func{extra500.gearSystem.MainGearSwitch.toggle(); } 	);
		UI.register("Gear up", 		func{extra500.gearSystem.MainGearSwitch.off(); } 	);
		UI.register("Gear down",	func{extra500.gearSystem.MainGearSwitch.on(); } 	);
	}
	
};

var gearSystem = GearSystem.new(props.globals.initNode("/extra500/system/gear"),"Landing Gear Control");