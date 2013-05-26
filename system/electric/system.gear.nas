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
#      Last change:      Eric van den Berg
#      Date:             17.05.13
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
		m.nLeftGearMassLocationX = props.globals.getNode("/fdm/jsbsim/inertia/pointmass-location-X-inches[7]",1);
		m.nLeftGearMassLocationZ = props.globals.getNode("/fdm/jsbsim/inertia/pointmass-location-Z-inches[7]",1);
		m.nRightGearMassLocationX = props.globals.getNode("/fdm/jsbsim/inertia/pointmass-location-X-inches[8]",1);
		m.nRightGearMassLocationZ = props.globals.getNode("/fdm/jsbsim/inertia/pointmass-location-Z-inches[8]",1);



		m.listener = nil;
		
		m.NoseGearWOW = 0;
		m.NoseGearPosition = 0.0;
		m.LeftGearPosition = 0.0;
		m.RightGearPosition = 0.0;
		
		m.LMassLocationX = m.nLeftGearMassLocationX.getValue();
		m.LMassLocationZ = m.nLeftGearMassLocationZ.getValue();
		m.RMassLocationX = m.nRightGearMassLocationX.getValue();
		m.RMassLocationZ = m.nRightGearMassLocationZ.getValue();
		
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
		
		m.RightDoorUpperClose = Part.ElectricSwitchDT.new(m.nRoot.initNode("RightDoorUpperClose"),"Right Door Upper",0);
		m.RightDoorUpperClose.setPoles(2);
		
		m.RightDoorUpperOpen = Part.ElectricSwitchDT.new(m.nRoot.initNode("RightDoorUpperOpen"),"Right Door Upper",0);
		m.RightDoorUpperOpen.setPoles(2);
		
		m.LeftDoorUpperClose = Part.ElectricSwitchDT.new(m.nRoot.initNode("LeftDoorUpperClose"),"Left Door Upper",0);
		m.LeftDoorUpperClose.setPoles(2);
		
		m.LeftDoorUpperOpen = Part.ElectricSwitchDT.new(m.nRoot.initNode("LeftDoorUpperOpen"),"Left Door Upper",0);
		m.LeftDoorUpperOpen.setPoles(2);
		
		m.LowerDoor = Part.ElectricSwitchDT.new(m.nRoot.initNode("LowerDoor"),"Lower Door",0);
		m.LowerDoor.setPoles(2);
		
	# relais
		m.HydraulicMotorRelais = Part.ElectricRelaisXPST.new(m.nRoot.initNode("HydraulicMotorRelais"),"Hydraulic Motor");
		m.HydraulicMotorRelais.setPoles(2);
		
		m.HydraulicCautionRelais = Part.ElectricRelaisXPST.new(m.nRoot.initNode("HydraulicCautionRelais"),"Hydraulic Caution Relais");
		m.HydraulicCautionRelais.setPoles(1);
		
		m.Gear34GARelais = Part.ElectricRelaisXPDT.new(m.nRoot.initNode("Gear34GARelais"),"Gear 34GA Relais");
		m.Gear34GARelais.setPoles(4);
		
		m.Gear35GARelais = Part.ElectricRelaisXPDT.new(m.nRoot.initNode("Gear35GARelais"),"Gear 35GA Relais");
		m.Gear35GARelais.setPoles(4);
		
		m.Gear14GARelais = Part.ElectricRelaisXPDT.new(m.nRoot.initNode("Gear14GARelais"),"Gear 14GA Relais");
		m.Gear14GARelais.setPoles(2);
		
		
		
		
	
	# Fake until we can drive 
		
		m.FakeSwitchOn	= Part.ElectricConnector.new("FakeSwitchOn");
		m.FakeSwitchOff	= Part.ElectricConnector.new("FakeSwitchOff");
		
	# Electic Connector	
		m.GND 		= Part.ElectricPin.new("GND");
		m.CTRL		= Part.ElectricPin.new("GearCTRL");		#  1 	GA3F-22
		#m.Relais34GA	= Part.ElectricPin.new("Relais34GA");		#  2 	GA3C-22
		m.SwitchOn	= Part.ElectricPin.new("GearSwitchOn");		#  3 	GA08F-22
		m.SwitchOff	= Part.ElectricPin.new("GearSwitchOff");	#  4 	GA09F-22
		m.RightGearLed	= Part.ElectricPin.new("RightGearLed");		#  5	GA24F-22
		m.NoseGearLed	= Part.ElectricPin.new("NoseGearLed");		#  6	GA25F-22
		m.LeftGearLed	= Part.ElectricPin.new("LeftGearLed");		#  7	GA26F-22
		
		m.Warning	= Part.ElectricPin.new("GearWarning");		#  8 	GA37G-22
		m.Aux2		= Part.ElectricPin.new("GearAux2");		#  9	GA34G-22
		m.Aux1		= Part.ElectricPin.new("GearAux1");		# 10 	GA37G-22
		#m.Relais35GA	= Part.ElectricPin.new("Relais35GA");		# 11 	GA43-22
		m.Annunciator	= Part.ElectricPin.new("Annunciator");		# 12 	GA53F-22
		m.TAS		= Part.ElectricPin.new("TAS");			# 13 	SD14F-22
		
				
		
		m.GNDBus = Part.ElectricBusDiode.new("GNDBus");
		
		m.TASBus = Part.ElectricBusDiode.new("TASBus");
		
		m.Modul3 = Part.ElectricBus.new("Modul3");
		m.Modul3abcde = Part.ElectricBus.new("Modul3abcde");
		m.Modul3fghjk = Part.ElectricBus.new("Modul3fghjk");
		m.Modul4cde = Part.ElectricBus.new("Modul4cde");
		m.Modul4hjk = Part.ElectricBusDiode.new("Modul4hjk");
		
		m.Aux2Diode = Part.ElectricDiode.new("Aux2Diode");
		m.Aux1Diode = Part.ElectricDiode.new("Aux1Diode");
		m.Aux2Bus = Part.ElectricBus.new("Aux2Bus");
		m.Aux1Bus = Part.ElectricBus.new("Aux1Bus");
		m.CtrlBus = Part.ElectricBus.new("CtrlBus");
		m.HydrBus = Part.ElectricBus.new("HydrBus");
		
		m.NoseGearLedBus = Part.ElectricBusDiode.new("NoseGearLedBus");
		m.LeftGearLedBus = Part.ElectricBusDiode.new("LeftGearLedBus");
		m.RightGearLedBus = Part.ElectricBusDiode.new("RightGearLedBus");
		
		
		
	# hydraulic 
		
		m.MainValve = Part.HydraulicValve.new(m.nRoot.initNode("MainValve"),"Hydraulic Main Valve");
		m.UpperDoorValve = Part.HydraulicValve.new(m.nRoot.initNode("UpperDoorValve"),"Hydraulic Upper Door Valve");
		m.LowerDoorValve = Part.HydraulicValve.new(m.nRoot.initNode("LowerDoorValve"),"Hydraulic Lower & Nose Door Valve");
		
		m.HydraulicMotor = Part.HydraulicMotor.new(m.nRoot.initNode("HydraulicMotor"),"Hydraulic Motor");
		m.HydraulicMotor.electricConfig(12.0,28.0);
		m.HydraulicMotor.setPower(24.0,450.0);
		
# 		m.GND.solder(m);
# 		m.NoseGearLed.solder(m);
# 		m.LeftGearLed.solder(m);
# 		m.RightGearLed.solder(m);
		
		return m;
		
	},
	applyVoltage : func(electron,name=""){
		
	},
	# FIXME :Fake unitl we can drive real hydraulic system  replace with original !!!
	plugElectric : func(){
		
		me.fakeHydrRelaisBus = Part.ElectricBusDiode.new("fakeHydrRelaisBus");
		
		me.CtrlBus.plug(me.MainGearSwitch.Com1);			
		me.MainGearSwitch.L11.plug(me.SwitchOff);
		me.MainGearSwitch.L12.plug(me.SwitchOn);
		
		me.GND.plug(me.GNDBus.Minus);
		me.RightGearLed.plug(me.RightGearDown.L12);		#  5
		me.NoseGearLed.plug(me.NoseGearDown.L22);		#  6
		me.LeftGearLed.plug(me.LeftGearDown.L22);		#  7
		me.Annunciator.plug(me.HydraulicCautionRelais.P11);	# 12
		me.Warning.plug(me.NoseGearUp.L22);			# 12
		
		me.SwitchOn.plug(me.NoseGearDown.Com1);
		me.NoseGearDown.L11.plug(me.fakeHydrRelaisBus.con());
		
		
		me.SwitchOff.plug(me.NoseGearUp.Com1);
		me.NoseGearUp.L11.plug(me.NoseGearSquat.Com1);
		me.NoseGearSquat.L11.plug(me.fakeHydrRelaisBus.con());
		me.NoseGearUp.Com2.plug(me.GNDBus.con());
		
		
		me.RightGearDown.Com1.plug(me.GNDBus.con());
		me.NoseGearDown.Com2.plug(me.GNDBus.con());
		me.LeftGearDown.Com2.plug(me.GNDBus.con());
				
		me.HydraulicMotorRelais.A1.plug(me.fakeHydrRelaisBus.Minus);
		me.HydraulicMotorRelais.A2.plug(me.GNDBus.con());
		me.HydraulicMotorRelais.P11.plug(me.HydrBus.con());
		me.HydraulicMotorRelais.P14.plug(me.HydraulicMotor.Plus);
		me.HydraulicMotorRelais.P21.plug(me.GNDBus.con());
		me.HydraulicMotorRelais.P24.plug(me.HydraulicCautionRelais.P14);
		#me.HydraulicCautionRelais.P14.plug(me.HydraulicMotorRelais.P24);
		
		me.HydraulicMotor.Minus.plug(me.GNDBus.con());
		
		
		me.HydraulicCautionRelais.A1.plug(me.HydrBus.con());
		me.HydraulicCautionRelais.A2.plug(me.GNDBus.con());
		
		
		
	},
	# FIXME :Fake unitl we can drive real hydraulic system  replace with original !!!
	plugElectric_original : func(){
		#--- plug outside
		
		
		
		
		me.Modul3abcde.plug(me.Modul4hjk.con());
		
		me.CtrlBus.plug(me.MainGearSwitch.Com1);			
		me.MainGearSwitch.L11.plug(me.SwitchOff);
		me.MainGearSwitch.L12.plug(me.SwitchOn);
		#---
				
		me.GND.plug(me.GNDBus.Minus);
		me.CTRL.plug(me.HydraulicMotorRelais.A1);		#  1
		#me.Relais34GA.plug(me.NoseGearSquat.L21);		#  2
		me.SwitchOn.plug(me.Modul3fghjk.con());			#  3
		me.SwitchOff.plug(me.RightGearDown.Com2);		#  4
		me.RightGearLed.plug(me.RightGearDown.L12);		#  5
		me.NoseGearLed.plug(me.NoseGearDown.L22);		#  6
		me.LeftGearLed.plug(me.LeftGearDown.L22);		#  7
		me.Warning.plug(me.NoseGearUp.L12);			#  8
		me.Aux2.plug(me.NoseGearDown.Com1);			#  9
		me.Aux1.plug(me.Aux2Diode.Minus);			# 10
		#me.Relais35GA.plug(me.NoseGearSquat.L41);		# 11
		me.Annunciator.plug(me.HydraulicCautionRelais.P11);	# 12
		me.TAS.plug(me.TASBus.Minus);				# 13
		
		
		me.MainValve.A1.plug(me.Modul4cde.con());
		me.MainValve.A2.plug(me.GNDBus.con());
		me.UpperDoorValve.A1.plug(me.Modul4hjk.Minus);
		me.UpperDoorValve.A2.plug(me.GNDBus.con());
		me.LowerDoorValve.A1.plug(me.LeftDoorUpperClose.L22);
		me.LowerDoorValve.A2.plug(me.GNDBus.con());
		
		me.HydraulicCautionRelais.A1.plug(me.HydrBus.con());
		me.HydraulicCautionRelais.A2.plug(me.GNDBus.con());
				
		me.HydraulicMotor.Minus.plug(me.GNDBus.con());
		me.HydraulicMotorRelais.P11.plug(me.HydraulicMotor.Plus);
		me.HydraulicMotorRelais.P21.plug(me.GNDBus.con());
		me.HydraulicMotorRelais.P21.plug(me.GNDBus.con());
		me.HydraulicMotorRelais.P24.plug(me.HydraulicCautionRelais.P14);
		
		
		
		me.Gear34GARelais.A1.plug(me.Aux2Bus.con());
		me.Gear34GARelais.A2.plug(me.NoseGearSquat.L21);
		
		me.Gear35GARelais.A1.plug(me.Aux2Bus.con());
		me.Gear35GARelais.A2.plug(me.NoseGearSquat.L41);
		
		me.Gear14GARelais.P11.plug(me.Modul4cde.con());
		me.Gear14GARelais.P14.plug(me.Modul3fghjk.con());
		me.Gear14GARelais.P21.plug(me.Modul3abcde.con());
		me.Gear14GARelais.P24.plug(me.Modul3fghjk.con());
		me.Gear14GARelais.A1.plug(me.Modul3abcde.con());
		me.Gear14GARelais.A2.plug(me.GNDBus.con());
		
		
		
		me.NoseGearDown.Com2.plug(me.GNDBus.con());
		me.NoseGearDown.L11.plug(me.Aux2Diode.Plus);
		me.NoseGearUp.Com1.plug(me.RightDoorUpperOpen.L12);
		
		me.NoseGearSquat.Com1.plug(me.RightDoorUpperClose.L12);
		me.NoseGearSquat.L12.plug(me.Modul3fghjk.con());
		me.NoseGearSquat.Com2.plug(me.GNDBus.con());
		me.NoseGearSquat.Com4.plug(me.GNDBus.con());
		
				
		me.RightGearUp.Com1.plug(me.Modul3fghjk.con());
		me.RightGearUp.L12.plug(me.LeftGearUp.L12);
		me.RightGearUp.Com2.plug(me.GNDBus.con());
		me.RightGearUp.L21.plug(me.TASBus.con());
		
		me.RightGearDown.Com1.plug(me.GNDBus.con());
		me.RightGearDown.L22.plug(me.LeftGearDown.Com1);
		
		me.LeftGearUp.Com1.plug(me.Modul3abcde.con());
		me.LeftGearUp.Com2.plug(me.GNDBus.con());
		me.LeftGearUp.L21.plug(me.TASBus.con());
		
		me.LeftGearDown.Com2.plug(me.GNDBus.con());
		me.LeftGearDown.L12.plug(me.Modul4hjk.con());
		
	#-----
		me.RightDoorUpperOpen.Com1.plug(me.LeftDoorUpperOpen.Com1);
		me.RightDoorUpperClose.Com1.plug(me.LeftDoorUpperClose.Com1);
		me.RightDoorUpperClose.Com2.plug(me.LeftDoorUpperClose.Com2);
		me.RightDoorUpperClose.L22.plug(me.Modul3fghjk.con());
		
		me.LeftDoorUpperOpen.L12.plug(me.Modul4cde.con());
		me.LeftDoorUpperClose.L12.plug(me.LowerDoor.L22);
				
		me.LowerDoor.Com2.plug(me.GNDBus.con());
		
		
	},
	# Main Simulation loop  ~ 10Hz
	simulationUpdate : func(now,dt){
	
		me.NoseGearWOW = me.nNoseGearWOW.getValue();
		me.NoseGearPosition = me.nNoseGearPosition.getValue();
		me.LeftGearPosition = me.nLeftGearPosition.getValue();
		me.RightGearPosition = me.nRightGearPosition.getValue();
		
	# Limit swicht
		#Nose gear
		if (me.NoseGearPosition == 1.0){
			me.NoseGearUp._setValue(0);
			me.NoseGearDown._setValue(1);
		}elsif(me.NoseGearPosition == 0.0){
			me.NoseGearUp._setValue(1);
			me.NoseGearDown._setValue(0);
		}else{
			me.NoseGearDown._setValue(0);
			me.NoseGearUp._setValue(0);
		}
		
		if (me.RightGearPosition == 1.0){
			me.RightGearUp._setValue(0);
			me.RightGearDown._setValue(1);
		}elsif(me.RightGearPosition == 0.0){
			me.RightGearUp._setValue(1);
			me.RightGearDown._setValue(0);
		}else{
			me.RightGearDown._setValue(0);
			me.RightGearUp._setValue(0);
		}
		
		if (me.LeftGearPosition == 1.0){
			me.LeftGearUp._setValue(0);
			me.LeftGearDown._setValue(1);
		}elsif(me.LeftGearPosition == 0.0){
			me.LeftGearUp._setValue(1);
			me.LeftGearDown._setValue(0);
		}else{
			me.LeftGearDown._setValue(0);
			me.LeftGearUp._setValue(0);
			
		}
		
	#squat switch
		if (me.NoseGearWOW == 1){
			me.NoseGearSquat._setValue(1); 
		}else{
			me.NoseGearSquat._setValue(0);
		}
		
	# door switches
	
		if (me.RightGearPosition >= 0.9){
			me.RightDoorUpperClose._setValue(1);
			me.RightDoorUpperOpen._setValue(0);
		}elsif(me.RightGearPosition >= 0.85){
			me.RightDoorUpperClose._setValue(0);
			me.RightDoorUpperOpen._setValue(1);
		}elsif(me.RightGearPosition == 0.0){
			me.RightDoorUpperClose._setValue(1);
			me.RightDoorUpperOpen._setValue(0);
		}else{
			me.RightDoorUpperClose._setValue(0);
			me.RightDoorUpperOpen._setValue(0);
			
		}
		
		if (me.LeftGearPosition >= 0.9){
			me.LeftDoorUpperClose._setValue(1);
			me.LeftDoorUpperOpen._setValue(0);
			
		}elsif(me.LeftGearPosition >= 0.85){
			me.LeftDoorUpperClose._setValue(0);
			me.LeftDoorUpperOpen._setValue(1);
		}elsif(me.LeftGearPosition == 0.0){
			me.LeftDoorUpperClose._setValue(1);
			me.LeftDoorUpperOpen._setValue(0);
		}else{
			me.LeftDoorUpperClose._setValue(0);
			me.LeftDoorUpperOpen._setValue(0);
		}
		
		if(me.NoseGearPosition == 0.0){
			me.LowerDoor._setValue(1);
		}else{
			me.LowerDoor._setValue(0);
		}
# FIXME : Fake until Hydraulic system is the driver 
		if (me.HydraulicMotor.state > 0.0){
			me._movingTheMass();
			me.nGearControl.setValue(me.MainGearSwitch.state);
		}
		
		
	},
	# moving the right & left mass in jsbsim
	_movingTheMass : func(){
		 
		me.nLeftGearMassLocationX.setValue( me.LMassLocationX - ( (1.0-me.LeftGearPosition) * (0.5 * global.CONST.METER2INCH) ) );
		me.nLeftGearMassLocationZ.setValue( me.LMassLocationZ + ( (1.0-me.LeftGearPosition) * (0.3 * global.CONST.METER2INCH) ) );
		
		me.nRightGearMassLocationX.setValue( me.RMassLocationX - ( (1.0-me.RightGearPosition) * (0.5 * global.CONST.METER2INCH) ) );
		me.nRightGearMassLocationZ.setValue( me.RMassLocationZ + ( (1.0-me.RightGearPosition) * (0.3 * global.CONST.METER2INCH) ) );
		
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
