#    This file is part of extra500
#
#    The extra500 is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 2 of the License, or
#    (at your option) any later version.
#
#    The extra500 is distributed in the hope that it will be useful,
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



# 1
# 2	+28V	ExternalPower
# 3	+28V	Landing Light
# 4	+28V	Recognition Light
# 5	+28V	Anti Ice Intake
# 6	+28V	Ignition System
# 7	+28V	x
# 8	
# 9	
# 10	
# 11	                                                                                        
# 12	                                                                                         
# 13	+28V	x                                                                                          
# 14	GND	PC-Board 1
# 15	GND	Fuel Transfare Left
# 16	GND	Fuel Filter
# 17	GND	Low Fuel Left
# 18	GND	Fuel Transfare Right
# 19	GND	Pneumatic(Boots)
# 20	GND	Low Fuel Right
# 21	GND	StandBy Alternator On
# 22	GND	Low Voltage
# 23	GND	Propeller Low Pitch
# 24	GND	Ignition System
# 25	GND	x
# 26	GND	ExternalPower
# 27	GND	Anti Ice Intake
# 28	GND	Boots
# 29	GND	Windshield Heat On
# 30	GND	Recognition Light
# 31	GND	Landing Light
# 32	GND	x
# 33	GND	Hydraulic Gear Control System
# 34	GND	Pitot Heat Right
# 35	GND	Static Heat Right
# 36	GND	Chip Detect
# 37	GND	Pitot Heat Left
# 38	GND	Static Heat Left
# 39	GND	Oil Pressure
# 40	GND	Low Fuel Pressure
# 41	
# 42	GND	Stall Heat
# 43	GND	Windshield Heat
# 44	GND	Bleed Air System
# 45	GND	Door Warning
# 46	GND	Stall Warning
# 47	GND	Cabin Pressure
# 48	GND	Generator 1
# 49	GND	Gear Warning
# 50	GND	Flap System

var AnnunciatorPanel = {
	new : func{
		var m = {parents:[
			AnnunciatorPanel
		]};
		
		m.nPanel = props.globals.getNode("extra500/AnnunciatorPanel",1);
	# row 1
		nCompNode = m.nPanel.initNode("GeneratorFail");
		m.GeneratorFail = Part.ElectricLight.new(nCompNode,"Generator Fail");
		m.GeneratorFail.electricConfig(14.0,26.0);
		m.GeneratorFail.setPower(24.0,2.6);
		
		nCompNode = m.nPanel.initNode("AFTDoor");
		m.AFTDoor = Part.ElectricLight.new(nCompNode,"AFT Door");
		m.AFTDoor.electricConfig(14.0,26.0);
		m.AFTDoor.setPower(24.0,2.6);
		
		nCompNode = m.nPanel.initNode("StallHeat");
		m.StallHeat = Part.ElectricLight.new(nCompNode,"Stall Heat");
		m.StallHeat.electricConfig(14.0,26.0);
		m.StallHeat.setPower(24.0,2.6);
		
		nCompNode = m.nPanel.initNode("OilPress");
		m.OilPress = Part.ElectricLight.new(nCompNode,"Oil Pressure");
		m.OilPress.electricConfig(14.0,26.0);
		m.OilPress.setPower(24.0,2.6);
		
		nCompNode = m.nPanel.initNode("ChipDetection");
		m.ChipDetection = Part.ElectricLight.new(nCompNode,"Chip Detection");
		m.ChipDetection.electricConfig(14.0,26.0);
		m.ChipDetection.setPower(24.0,2.6);
		
		nCompNode = m.nPanel.initNode("HydraulicPump");
		m.HydraulicPump = Part.ElectricLight.new(nCompNode,"HydraulicPump");
		m.HydraulicPump.electricConfig(14.0,26.0);
		m.HydraulicPump.setPower(24.0,2.6);
	# row 2
		nCompNode = m.nPanel.initNode("GearWarn");
		m.GearWarn = Part.ElectricLight.new(nCompNode,"Gear Warning");
		m.GearWarn.electricConfig(14.0,26.0);
		m.GearWarn.setPower(24.0,2.6);
		
		nCompNode = m.nPanel.initNode("StallWarn");
		m.StallWarn = Part.ElectricLight.new(nCompNode,"Stall Warning");
		m.StallWarn.electricConfig(14.0,26.0);
		m.StallWarn.setPower(24.0,2.6);
		
		nCompNode = m.nPanel.initNode("WindshieldHeatFail");
		m.WindshieldHeatFail = Part.ElectricLight.new(nCompNode,"Windshield Heat Fail");
		m.WindshieldHeatFail.electricConfig(14.0,26.0);
		m.WindshieldHeatFail.setPower(24.0,2.6);
		
		nCompNode = m.nPanel.initNode("FuelPress");
		m.FuelPress = Part.ElectricLight.new(nCompNode,"Fuel Pressure");
		m.FuelPress.electricConfig(14.0,26.0);
		m.FuelPress.setPower(24.0,2.6);
		
		nCompNode = m.nPanel.initNode("PitotHeatLeft");
		m.PitotHeatLeft = Part.ElectricLight.new(nCompNode,"Pitot Heat Left");
		m.PitotHeatLeft.electricConfig(14.0,26.0);
		m.PitotHeatLeft.setPower(24.0,2.6);
		
		nCompNode = m.nPanel.initNode("PitotHeatRight");
		m.PitotHeatRight = Part.ElectricLight.new(nCompNode,"Pitot Heat Right");
		m.PitotHeatRight.electricConfig(14.0,26.0);
		m.PitotHeatRight.setPower(24.0,2.6);
	# row 3
		nCompNode = m.nPanel.initNode("Flaps");
		m.Flaps = Part.ElectricLight.new(nCompNode,"Flaps");
		m.Flaps.electricConfig(14.0,26.0);
		m.Flaps.setPower(24.0,2.6);
		
		nCompNode = m.nPanel.initNode("CabinPressure");
		m.CabinPressure = Part.ElectricLight.new(nCompNode,"Cabin Pressure");
		m.CabinPressure.electricConfig(14.0,26.0);
		m.CabinPressure.setPower(24.0,2.6);
		
		nCompNode = m.nPanel.initNode("BleedOvertemp");
		m.BleedOvertemp = Part.ElectricLight.new(nCompNode,"Bleed Overtemp");
		m.BleedOvertemp.electricConfig(14.0,26.0);
		m.BleedOvertemp.setPower(24.0,2.6);
		
# 		nCompNode = m.nPanel.initNode("");
# 		m. = Part.ElectricLight.new(nCompNode,"");
# 		m..electricConfig(14.0,26.0);
# 		m..setPower(24.0,2.6);
		
		nCompNode = m.nPanel.initNode("StaticHeatLeft");
		m.StaticHeatLeft = Part.ElectricLight.new(nCompNode,"Static Heat Left");
		m.StaticHeatLeft.electricConfig(14.0,26.0);
		m.StaticHeatLeft.setPower(24.0,2.6);
		
		nCompNode = m.nPanel.initNode("StaticHeatRight");
		m.StaticHeatRight = Part.ElectricLight.new(nCompNode,"Static Heat Right");
		m.StaticHeatRight.electricConfig(14.0,26.0);
		m.StaticHeatRight.setPower(24.0,2.6);
	# row 4
		nCompNode = m.nPanel.initNode("FuelTransLeft");
		m.FuelTransLeft = Part.ElectricLight.new(nCompNode,"Fuel Trans Left");
		m.FuelTransLeft.electricConfig(14.0,26.0);
		m.FuelTransLeft.setPower(24.0,2.6);
		
		nCompNode = m.nPanel.initNode("FuelTransRight");
		m.FuelTransRight = Part.ElectricLight.new(nCompNode,"Fuel Trans Right");
		m.FuelTransRight.electricConfig(14.0,26.0);
		m.FuelTransRight.setPower(24.0,2.6);
		
		nCompNode = m.nPanel.initNode("StandByAlternOn");
		m.StandByAlternOn = Part.ElectricLight.new(nCompNode,"StandBy Alternator On");
		m.StandByAlternOn.electricConfig(14.0,26.0);
		m.StandByAlternOn.setPower(24.0,2.6);
		
		nCompNode = m.nPanel.initNode("IgnitionActive");
		m.IgnitionActive = Part.ElectricLight.new(nCompNode,"Ignition Active");
		m.IgnitionActive.electricConfig(14.0,26.0);
		m.IgnitionActive.setPower(24.0,2.6);
		
		nCompNode = m.nPanel.initNode("IntakeHeat");
		m.IntakeHeat = Part.ElectricLight.new(nCompNode,"Intake Heat");
		m.IntakeHeat.electricConfig(14.0,26.0);
		m.IntakeHeat.setPower(24.0,2.6);
		
		nCompNode = m.nPanel.initNode("RecognLight");
		m.RecognLight = Part.ElectricLight.new(nCompNode,"Recognition Light");
		m.RecognLight.electricConfig(14.0,26.0);
		m.RecognLight.setPower(24.0,2.6);
	# row 5
		nCompNode = m.nPanel.initNode("FuelFilterByPass");
		m.FuelFilterByPass = Part.ElectricLight.new(nCompNode,"Fuel Filter ByPass");
		m.FuelFilterByPass.electricConfig(14.0,26.0);
		m.FuelFilterByPass.setPower(24.0,2.6);
		
		nCompNode = m.nPanel.initNode("PneumaticLow");
		m.PneumaticLow = Part.ElectricLight.new(nCompNode,"Pneumatic Low");
		m.PneumaticLow.electricConfig(14.0,26.0);
		m.PneumaticLow.setPower(24.0,2.6);
		
		nCompNode = m.nPanel.initNode("LowVoltage");
		m.LowVoltage = Part.ElectricLight.new(nCompNode,"Low Voltage");
		m.LowVoltage.electricConfig(14.0,26.0);
		m.LowVoltage.setPower(24.0,2.6);
		
# 		nCompNode = m.nPanel.initNode("");
# 		m. = Part.ElectricLight.new(nCompNode,"");
# 		m..electricConfig(14.0,26.0);
# 		m..setPower(24.0,2.6);
		
		nCompNode = m.nPanel.initNode("DeiceBoots");
		m.DeiceBoots = Part.ElectricLight.new(nCompNode,"Deice Boots");
		m.DeiceBoots.electricConfig(14.0,26.0);
		m.DeiceBoots.setPower(24.0,2.6);
		
		nCompNode = m.nPanel.initNode("LandingLight");
		m.LandingLight = Part.ElectricLight.new(nCompNode,"Landing Light");
		m.LandingLight.electricConfig(14.0,26.0);
		m.LandingLight.setPower(24.0,2.6);
	# row 6
		nCompNode = m.nPanel.initNode("FuelLowLeft");
		m.FuelLowLeft = Part.ElectricLight.new(nCompNode,"Fuel Low Left");
		m.FuelLowLeft.electricConfig(14.0,26.0);
		m.FuelLowLeft.setPower(24.0,2.6);
		
		nCompNode = m.nPanel.initNode("FuelLowRight");
		m.FuelLowRight = Part.ElectricLight.new(nCompNode,"Fuel Low Right");
		m.FuelLowRight.electricConfig(14.0,26.0);
		m.FuelLowRight.setPower(24.0,2.6);
		
		nCompNode = m.nPanel.initNode("PropellerLowPitch");
		m.PropellerLowPitch = Part.ElectricLight.new(nCompNode,"Propeller Low Pitch");
		m.PropellerLowPitch.electricConfig(14.0,26.0);
		m.PropellerLowPitch.setPower(24.0,2.6);
		
		nCompNode = m.nPanel.initNode("ExternalPower");
		m.ExternalPower = Part.ElectricLight.new(nCompNode,"External Power");
		m.ExternalPower.electricConfig(14.0,26.0);
		m.ExternalPower.setPower(24.0,2.6);
		
		nCompNode = m.nPanel.initNode("WindshieldHeatOn");
		m.WindshieldHeatOn = Part.ElectricLight.new(nCompNode,"Windshield Heat On");
		m.WindshieldHeatOn.electricConfig(14.0,26.0);
		m.WindshieldHeatOn.setPower(24.0,2.6);
		
# 		nCompNode = m.nPanel.initNode("");
# 		m. = Part.ElectricLight.new(nCompNode,"");
# 		m..electricConfig(14.0,26.0);
# 		m..setPower(24.0,2.6);
	
	# bus
	
		m.GNDBus = Part.ElectricBusDiode.new("Annunciator.GNDBus");
		m.TestPlusBus = Part.ElectricBus.new("Annunciator.TestPlusBus");
		m.iBusPlus = Part.ElectricBus.new("#iBusPlus");
		m.externalPowerBus = Part.ElectricBus.new("Annunciator.externalPowerBus");
	
	#relais
		nCompNode = m.nPanel.initNode("dimTestRelais");
		m.dimTestRelais = Part.ElectricRelaisXPDT.new(nCompNode,"DimTestRelais");
		m.dimTestRelais.setPoles(50);
		# P11	iBusPlus
	# P12	+14-28V Dim Voltage 
	# P14	+28V Light-Test 
		
		nCompNode = m.nPanel.initNode("ExternalPowerRelais");
		m.externalPowerRelais = Part.ElectricRelaisXPDT.new(nCompNode,"ExternalPowerRelais");
		m.externalPowerRelais.setPoles(2);
		# P11	+ External Power
		# P12	+14-28V iBusPlus
	# P14	+28V Generator 
			
	
		return m;
	},
	applyVoltage : func(electron,name=""){ 

		return 0;
	},
	plugElectric : func(){
		
		me.iBusPlus.plug(me.dimTestRelais.P11); # Voltage
		me.iBusPlus.plug(me.GeneratorFail.Plus);
		me.iBusPlus.plug(me.AFTDoor.Plus);
		me.iBusPlus.plug(me.StallHeat.Plus);
		me.iBusPlus.plug(me.OilPress.Plus);
		me.iBusPlus.plug(me.ChipDetection.Plus);
		me.iBusPlus.plug(me.HydraulicPump.Plus);
		me.iBusPlus.plug(me.GearWarn.Plus);
		me.iBusPlus.plug(me.StallWarn.Plus);
		me.iBusPlus.plug(me.WindshieldHeatFail.Plus);
		me.iBusPlus.plug(me.FuelPress.Plus);
		me.iBusPlus.plug(me.PitotHeatLeft.Plus);
		me.iBusPlus.plug(me.PitotHeatRight.Plus);
		me.iBusPlus.plug(me.Flaps.Plus);
		me.iBusPlus.plug(me.CabinPressure.Plus);
		me.iBusPlus.plug(me.BleedOvertemp.Plus);
		me.iBusPlus.plug(me.StaticHeatLeft.Plus);
		me.iBusPlus.plug(me.StaticHeatRight.Plus);
		me.iBusPlus.plug(me.FuelTransLeft.Plus);
		me.iBusPlus.plug(me.FuelTransRight.Plus);
		me.iBusPlus.plug(me.StandByAlternOn.Plus);
		me.iBusPlus.plug(me.IgnitionActive.Plus);
		me.iBusPlus.plug(me.IntakeHeat.Plus);
		me.iBusPlus.plug(me.RecognLight.Plus);
		me.iBusPlus.plug(me.FuelFilterByPass.Plus);
		me.iBusPlus.plug(me.PneumaticLow.Plus);
		me.iBusPlus.plug(me.LowVoltage.Plus);
		me.iBusPlus.plug(me.DeiceBoots.Plus);
		me.iBusPlus.plug(me.LandingLight.Plus);
		me.iBusPlus.plug(me.FuelLowLeft.Plus);
		me.iBusPlus.plug(me.FuelLowRight.Plus);
		me.iBusPlus.plug(me.PropellerLowPitch.Plus);
		me.iBusPlus.plug(me.externalPowerRelais.P12);
		me.iBusPlus.plug(me.WindshieldHeatOn.Plus);
		
		me.ExternalPower.Plus.plug(me.externalPowerRelais.P11);
		me.ExternalPower.Minus.plug(me.externalPowerRelais.P21);
		
		me.externalPowerRelais.P14.plug(me.externalPowerBus.con());
		
		me.externalPowerRelais.P22.plug(me.dimTestRelais.P261);
		me.externalPowerRelais.P24.plug(mainBoard.GND);
		
		me.externalPowerRelais.A1.plug(me.externalPowerBus.con());
		me.externalPowerRelais.A2.plug(mainBoard.GND);
		
		
	# ---
		
		me.FuelTransLeft.Minus.plug(		me.dimTestRelais.P151); #	Fuel Transfare Left
		me.FuelFilterByPass.Minus.plug(		me.dimTestRelais.P161); #	Fuel Filter
		me.FuelLowLeft.Minus.plug(		me.dimTestRelais.P171); #	Low Fuel Left
		me.FuelTransRight.Minus.plug(		me.dimTestRelais.P181); #	Fuel Transfare Right
		me.PneumaticLow.Minus.plug(		me.dimTestRelais.P191); #	Pneumatic(Boots)
		me.FuelLowRight.Minus.plug(		me.dimTestRelais.P201); #	Low Fuel Right
		me.StandByAlternOn.Minus.plug(		me.dimTestRelais.P211); #	StandBy Alternator On
		me.LowVoltage.Minus.plug(		me.dimTestRelais.P221); #	Low Voltage
		me.PropellerLowPitch.Minus.plug(	me.dimTestRelais.P231); #	Propeller Low Pitch
		me.IgnitionActive.Minus.plug(		me.dimTestRelais.P241); #	Ignition System
		
		#me.ExternalPower.Minus.plug(		me.dimTestRelais.P261); #	ExternalPowe
		me.IntakeHeat.Minus.plug(		me.dimTestRelais.P271); #	Anti Ice Intake
		me.DeiceBoots.Minus.plug(		me.dimTestRelais.P281); #	Boots
		me.WindshieldHeatOn.Minus.plug(		me.dimTestRelais.P291); #	Windshield Heat On
		me.RecognLight.Minus.plug(		me.dimTestRelais.P301); #	Recognition Light
		me.LandingLight.Minus.plug(		me.dimTestRelais.P311); #	Landing Light
		me.HydraulicPump.Minus.plug(		me.dimTestRelais.P331); #	Hydraulic Gear Control System
		me.PitotHeatRight.Minus.plug(		me.dimTestRelais.P341); #	Pitot Heat Right
		me.StaticHeatRight.Minus.plug(		me.dimTestRelais.P351); #	Static Heat Right
		me.ChipDetection.Minus.plug(		me.dimTestRelais.P361); #	Chip Detect
		me.PitotHeatLeft.Minus.plug(		me.dimTestRelais.P371); #	Pitot Heat Left
		me.StaticHeatLeft.Minus.plug(		me.dimTestRelais.P381); #	Static Heat Left
		me.OilPress.Minus.plug(			me.dimTestRelais.P391); #	Oil Pressure
		me.FuelPress.Minus.plug(		me.dimTestRelais.P401); #	Low Fuel Pressure
		
		me.StallHeat.Minus.plug(		me.dimTestRelais.P421); #	Stall Heat
		me.WindshieldHeatFail.Minus.plug(	me.dimTestRelais.P431); #	Windshield Heat
		me.BleedOvertemp.Minus.plug(		me.dimTestRelais.P441); #	Bleed Air System
		me.AFTDoor.Minus.plug(			me.dimTestRelais.P451); #	Door Warning
		me.StallWarn.Minus.plug(		me.dimTestRelais.P461); #	Stall Warning
		me.CabinPressure.Minus.plug(		me.dimTestRelais.P471); #	Cabin Pressure
		me.GeneratorFail.Minus.plug(		me.dimTestRelais.P481); #	Generator 1
		me.GearWarn.Minus.plug(			me.dimTestRelais.P491); #	Gear Warning
		me.Flaps.Minus.plug(			me.dimTestRelais.P501); #	Flap System
		
		
		# Test GND Dioden Bus
		me.GNDBus.Minus.plug(mainBoard.GND);
		
		me.GNDBus.plug(	me.dimTestRelais.P154); #	Fuel Transfare Left
		me.GNDBus.plug(	me.dimTestRelais.P164); #	Fuel Filter
		me.GNDBus.plug(	me.dimTestRelais.P174); #	Low Fuel Left
		me.GNDBus.plug(	me.dimTestRelais.P184); #	Fuel Transfare Right
		me.GNDBus.plug(	me.dimTestRelais.P194); #	Pneumatic(Boots)
		me.GNDBus.plug(	me.dimTestRelais.P204); #	Low Fuel Right
		me.GNDBus.plug(	me.dimTestRelais.P214); #	StandBy Alternator On
		me.GNDBus.plug(	me.dimTestRelais.P224); #	Low Voltage
		me.GNDBus.plug(	me.dimTestRelais.P234); #	Propeller Low Pitch
		me.GNDBus.plug(	me.dimTestRelais.P244); #	Ignition System
		
		me.GNDBus.plug(	me.dimTestRelais.P264); #	ExternalPower
		me.GNDBus.plug(	me.dimTestRelais.P274); #	Anti Ice Intake
		me.GNDBus.plug(	me.dimTestRelais.P284); #	Boots
		me.GNDBus.plug(	me.dimTestRelais.P294); #	Windshield Heat On
		me.GNDBus.plug(	me.dimTestRelais.P304); #	Recognition Light
		me.GNDBus.plug(	me.dimTestRelais.P314); #	Landing Light
		me.GNDBus.plug(	me.dimTestRelais.P334); #	Hydraulic Gear Control System
		me.GNDBus.plug(	me.dimTestRelais.P344); #	Pitot Heat Right
		me.GNDBus.plug(	me.dimTestRelais.P354); #	Static Heat Right
		me.GNDBus.plug(	me.dimTestRelais.P364); #	Chip Detect
		me.GNDBus.plug(	me.dimTestRelais.P374); #	Pitot Heat Left
		me.GNDBus.plug(	me.dimTestRelais.P384); #	Static Heat Left
		me.GNDBus.plug(	me.dimTestRelais.P394); #	Oil Pressure
		me.GNDBus.plug(	me.dimTestRelais.P404); #	Low Fuel Pressure
		
		me.GNDBus.plug(	me.dimTestRelais.P424); #	Stall Heat
		me.GNDBus.plug(	me.dimTestRelais.P434); #	Windshield Heat
		me.GNDBus.plug(	me.dimTestRelais.P444); #	Bleed Air System
		me.GNDBus.plug(	me.dimTestRelais.P454); #	Door Warning
		me.GNDBus.plug(	me.dimTestRelais.P464); #	Stall Warning
		me.GNDBus.plug(	me.dimTestRelais.P474); #	Cabin Pressure
		me.GNDBus.plug(	me.dimTestRelais.P484); #	Generator 1
		me.GNDBus.plug(	me.dimTestRelais.P494); #	Gear Warning
		me.GNDBus.plug(	me.dimTestRelais.P504); #	Flap System
		
	},
};

var annunciatorPanel = AnnunciatorPanel.new();
