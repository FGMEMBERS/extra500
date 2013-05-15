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
		
		m.RightDoorUpperClose = Part.ElectricSwitchDT.new(m.nRoot.initNode("RightDoorUpper"),"Right Door Upper",0);
		m.RightDoorUpperClose.setPoles(2);
		
		m.RightDoorUpperOpen = Part.ElectricSwitchDT.new(m.nRoot.initNode("RightDoorUpper"),"Right Door Upper",0);
		m.RightDoorUpperOpen.setPoles(2);
		
		m.LeftDoorUpperClose = Part.ElectricSwitchDT.new(m.nRoot.initNode("LeftDoorUpper"),"Left Door Upper",0);
		m.LeftDoorUpperClose.setPoles(2);
		
		m.LeftDoorUpperOpen = Part.ElectricSwitchDT.new(m.nRoot.initNode("LeftDoorUpper"),"Left Door Upper",0);
		m.LeftDoorUpperOpen.setPoles(2);
		
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
		m.TASBus = Part.ElectricBusDiode.new("TASBus");
		
		m.Modul4cde = Part.ElectricBus.new("Modul4cde");
		m.Modul4hjk = Part.ElectricBusDiode.new("Modul4hjk");
		
	# hydraulic 
		
		m.MainValve = Part.HydraulicValve.new(m.nRoot.initNode("MainValve"),"Hydraulic Main Valve");
		m.UpperDoorValve = Part.HydraulicValve.new(m.nRoot.initNode("UpperDoorValve"),"Hydraulic Upper Door Valve");
		m.NoseDoorValve = Part.HydraulicValve.new(m.nRoot.initNode("NoseDoorValve"),"Hydraulic Lower & Nose Door Valve");
		
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
		
		me.MainValve.A1.plug(me.Modul4cde.con());
		me.MainValve.A2.plug(me.GNDBus.con());
		me.UpperDoorValve.A1.plug(me.Modul4hjk.Minus);
		me.UpperDoorValve.A2.plug(me.GNDBus.con());
		me.NoseDoorValve.A1.plug(me.LeftDoorUpperClose.L22);
		me.NoseDoorValve.A2.plug(me.GNDBus.con());
		
		
		me.Modul3.plug(me.Modul4hjk.con());
		
		me.CTRL.plug(me.MainGearSwitch.Com1);			
		me.MainGearSwitch.L11.plug(me.SwitchOff);
		me.MainGearSwitch.L12.plug(me.SwitchOn);
		#---
				
		me.GND.plug(me.GNDBus.Minus);
		me.CTRL.plug(me.HydraulicMotorRelais.A1);		#  1
		me.Relais34GA.plug(me.NoseGearSquat.L21);		#  2
		me.SwitchOn.plug(me.Modul3.con());			#  3
		me.SwitchOff.plug(me.RightGearDown.Com2);		#  4
		me.RightGearLed.plug(me.RightGearDown.L12);		#  5 xxx
		me.NoseGearLed.plug(me.NoseGearDown.L21);		#  6
		me.LeftGearLed.plug(me.LeftGearDown.L22);		#  7
		me.Warning.plug(me.NoseGearUp.L11);			#  8
		me.Aux2.plug(me.NoseGearDown.Com1);			#  9
		me.Aux1.plug(me.NoseGearDown.L12);			# 10
		me.Relais35GA.plug(me.NoseGearSquat.L42);		# 11
		me.Annunciator.plug(me.HydraulicMotorRelais.P24);	# 12
		me.TAS.plug(me.TASBus.Minus);				# 13
		
		me.NoseGearDown.Com2.plug(me.GNDBus.con());
		
		me.NoseGearUp.Com1.plug(me.RightDoorUpperOpen.L12);
		
		me.NoseGearSquat.Com1.plug(me.RightDoorUpperClose.L12);
		me.NoseGearSquat.L12.plug(me.Modul3.con());
		me.NoseGearSquat.Com2.plug(me.GNDBus.con());
		me.NoseGearSquat.Com4.plug(me.GNDBus.con());
		
				
		me.RightGearup.Com1.plug(me.Modul3.con());
		me.RightGearup.L12.plug(me.LeftGearUp.L12);
		me.RightGearup.Com2.plug(me.GNDBus.con());
		me.RightGearup.L21.plug(me.TASBus.con());
		
		me.RightGearDown.Com1.plug(me.GNDBus.con());
		me.RightGearDown.L22.plug(me.LeftGearDown.Com1);
		
		me.LeftGearUp.Com1.plug(me.Modul3.con());
		me.LeftGearUp.Com2.plug(me.GNDBus.con());
		me.LeftGearUp.L21.plug(me.TASBus.con());
		
		me.LeftGearDown.Com2.plug(me.GNDBus.con());
		me.LeftGearDown.L12.plug(me.Modul4hjk.con());
		
	#-----
		me.RightDoorUpperOpen.Com1.plug(me.LeftDoorUpperOpen.Com1);
		me.RightDoorUpperClose.Com1.plug(me.LeftDoorUpperClose.Com1);
		me.RightDoorUpperClose.Com2.plug(me.LeftDoorUpperClose.Com2);
		me.RightDoorUpperClose.L22.plug(me.Modul3.con());
		
		me.LeftDoorUpperOpen.L12.plug(me.Modul4cde.con());
		me.LeftDoorUpperClose.L12.plug(me.LowerDoor.L22);
				
		me.LowerDoor.Com2.plug(me.GNDBus.con());
		
		
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
			me.RightDoorUpperClose.on();
			me.RightDoorUpperOpen.off();
		}elsif(me.RightGearPosition >= 0.85){
			me.RightDoorUpperClose.off();
			me.RightDoorUpperOpen.on();
		}elsif(me.RightGearPosition == 0.0){
			me.RightDoorUpperClose.on();
			me.RightDoorUpperOpen.off();
		}else{
			me.RightDoorUpperClose.off();
			me.RightDoorUpperOpen.off();
			
		}
		
		if (me.LeftGearPosition >= 0.9){
			me.LeftDoorUpperClose.on();
			me.LeftDoorUpperOpen.off();
			
		}elsif(me.LeftGearPosition >= 0.85){
			me.LeftDoorUpperClose.off();
			me.LeftDoorUpperOpen.on();
		}elsif(me.LeftGearPosition == 0.0){
			me.LeftDoorUpperClose.on();
			me.LeftDoorUpperOpen.off();
		}else{
			me.LeftDoorUpperClose.off();
			me.LeftDoorUpperOpen.off();
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