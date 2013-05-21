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
#      Date: April 12 2013
#
#      Last change:      Dirk Dittmann
#      Date:             26.04.13
#

var LightBoard = {
	new : func(nRoot,name){
		var m = {parents:[
			LightBoard
		]};
		
		
	#outside
		m.Strobe = Part.ElectricLight.new(nRoot.initNode("Strobe"),"Strobe Light");
		m.Strobe.electricConfig(10.0,24.0);
		m.Strobe.setPower(24.0,30.0);
		
		m.Navigation = Part.ElectricLight.new(nRoot.initNode("Navigation"),"Navigation Light");
		m.Navigation.electricConfig(10.0,24.0);
		m.Navigation.setPower(24.0,90.0);
		
		m.Landing = Part.ElectricLight.new(nRoot.initNode("Landing"),"Landing Light");
		m.Landing.electricConfig(10.0,24.0);
		m.Landing.setPower(24.0,100.0);
		
		m.Recognition = Part.ElectricLight.new(nRoot.initNode("Recognition"),"Recognition Light");
		m.Recognition.electricConfig(10.0,24.0);
		m.Recognition.setPower(24.0,60.0);
		
		m.Ice = Part.ElectricLight.new(nRoot.initNode("Ice"),"Ice");
		m.Ice.electricConfig(10.0,24.0);
		m.Ice.setPower(24.0,100.0);
		
		
		
		
	#cockpit
		m.Cabin = Part.ElectricLight.new(nRoot.initNode("Cabin"),"Cabin Light");
		m.Cabin.electricConfig(10.0,24.0);
		m.Cabin.setPower(24.0,45.0);
		
		m.Map = Part.ElectricLight.new(nRoot.initNode("Map"),"Map Light");
		m.Map.electricConfig(10.0,24.0);
		m.Map.setPower(24.0,20.0);
		
		
# 		nCompNode = nRoot.initNode("Instrument");
# 		m.Instrument = Part.ElectricLight.new(nCompNode,"Instrument");
# 		m.Instrument.electricConfig(14.0,26.0);
# 		m.Instrument.setPower(24.0,150.0);
		
		
		m.Glare = Part.ElectricLight.new(nRoot.initNode("Glare"),"Glare");
		m.Glare.electricConfig(14.0,26.0);
		m.Glare.setPower(24.0,15.0);
		
		 		
		m.Keypad = Part.ElectricLight.new(nRoot.initNode("Keypad"),"Keypad");
		m.Keypad.electricConfig(14.0,26.0);
		m.Keypad.setPower(24.0,24.0);
				
		m.Switches = Part.ElectricLight.new(nRoot.initNode("Switches"),"Switches");
		m.Switches.electricConfig(14.0,26.0);
		m.Switches.setPower(24.0,60.0);
		
	#indication Lights
		
		m.FlapTransition = Part.ElectricLight.new(nRoot.initNode("FlapTransition"),"FlapTransition");
		m.FlapTransition.electricConfig(12.0,26.0);
		m.FlapTransition.setPower(24.0,0.5);
		
		m.Flap15 = Part.ElectricLight.new(nRoot.initNode("Flap15"),"Flap15");
		m.Flap15.electricConfig(12.0,26.0);
		m.Flap15.setPower(24.0,0.5);
		
		m.Flap30 = Part.ElectricLight.new(nRoot.initNode("Flap30"),"Flap30");
		m.Flap30.electricConfig(12.0,26.0);
		m.Flap30.setPower(24.0,0.5);
		
		m.GearNose = Part.ElectricLight.new(nRoot.initNode("GearNose"),"GearNose");
		m.GearNose.electricConfig(12.0,26.0);
		m.GearNose.setPower(24.0,0.5);
		
		m.GearLeft = Part.ElectricLight.new(nRoot.initNode("GearLeft"),"GearLeft");
		m.GearLeft.electricConfig(12.0,26.0);
		m.GearLeft.setPower(24.0,0.5);
		
		m.GearRight = Part.ElectricLight.new(nRoot.initNode("GearRight"),"GearRight");
		m.GearRight.electricConfig(12.0,26.0);
		m.GearRight.setPower(24.0,0.5);
				
		m.DMEHold = Part.ElectricLight.new(nRoot.initNode("DMEHold"),"DME-Hold");
		m.DMEHold.electricConfig(12.0,26.0);
		m.DMEHold.setPower(24.0,0.5);
		
		
	#Relais
		nCompNode = nRoot.initNode("DayNightRelais");
		m.dayNightRelais = Part.ElectricRelaisXPDT.new(nCompNode,"Day/Night Relais");
		m.dayNightRelais.setPoles(5);
		# 1 KEYPAD
		# 2 GLARE
		# 3 INSTR
		# 4 SWITCHES
		# 5 ANNUNCIATOR
		
		nCompNode = nRoot.initNode("TestLightRelais");
		m.testLightRelais = Part.ElectricRelaisXPDT.new(nCompNode,"Test Light Relais");
		m.testLightRelais.setPoles(9);
		# 1 ANNUNCIATOR
		# 2 FlapTransition
		# 3 Flap15
		# 4 Flap30
		# 5 GearNose
		# 6 GearLeft
		# 7 GearRight
		# 8 DME

	#Buses
		m.GNDBus = Part.ElectricBusDiode.new("GNDBus");
		m.annuciatorDimBus = Part.ElectricBus.new("AnnunciatorDimBus");
		m.instrumentDimBus = Part.ElectricBus.new("InstrumentDimBus");
	
		return m;
	},
	plugElectric : func(){
				
		me.annuciatorDimBus.plug(me.dayNightRelais.P51);
		me.annuciatorDimBus.plug(me.FlapTransition.Plus);
		me.annuciatorDimBus.plug(me.Flap15.Plus);
		me.annuciatorDimBus.plug(me.Flap30.Plus);
		me.annuciatorDimBus.plug(me.GearNose.Plus);
		me.annuciatorDimBus.plug(me.GearLeft.Plus);
		me.annuciatorDimBus.plug(me.GearRight.Plus);
		me.annuciatorDimBus.plug(me.DMEHold.Plus);
		
		me.instrumentDimBus.plug(me.dayNightRelais.P31);
		
		
		me.FlapTransition.Minus.plug(	me.testLightRelais.P21);
		me.Flap15.Minus.plug(		me.testLightRelais.P31);
		me.Flap30.Minus.plug(		me.testLightRelais.P41);
		me.GearNose.Minus.plug(		me.testLightRelais.P51);
		me.GearLeft.Minus.plug(		me.testLightRelais.P61);
		me.GearRight.Minus.plug(	me.testLightRelais.P71);
		me.DMEHold.Minus.plug(		me.testLightRelais.P81);
		
		me.GNDBus.plug(	me.testLightRelais.P24);
		me.GNDBus.plug(	me.testLightRelais.P34);
		me.GNDBus.plug(	me.testLightRelais.P44);
		me.GNDBus.plug(	me.testLightRelais.P54);
		me.GNDBus.plug(	me.testLightRelais.P64);
		me.GNDBus.plug(	me.testLightRelais.P74);
		me.GNDBus.plug(	me.testLightRelais.P84);
		
		
		me.GNDBus.plug(	me.Switches.Minus);
#		me.GNDBus.plug(	me.Instrument.Minus);
		me.GNDBus.plug(	me.Glare.Minus);
		me.GNDBus.plug(	me.Keypad.Minus);
		me.GNDBus.plug(	me.Ice.Minus);
		me.GNDBus.plug(	me.Map.Minus);
		me.GNDBus.plug(	me.Recognition.Minus);
		me.GNDBus.plug(	me.Cabin.Minus);
		me.GNDBus.plug(	me.Landing.Minus);
		me.GNDBus.plug(	me.Navigation.Minus);
		me.GNDBus.plug(	me.Strobe.Minus);
		
	},
};

var lightBoard = LightBoard.new(props.globals.initNode("extra500/light"),"Lights");