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
#      Date:             29.04.13
#
 var plugEBox = func(){
	
		
	# Sources
		battery.Minus.plug(eBox.GND);
		externalPower.Minus.plug(eBox.GND);
	# Bus	
	
		eBox.hotBus.plug(battery.Plus);
		eBox.iBus40.plug(fusePanel.externalPower.In);
		eBox.iBus40.plug(externalPower.Plus);
		
		eBox.iBus30.plug(generator.Plus);
 		eBox.iBus30.plug(generatorControlUnit.POR);
		eBox.iBus30.plug(eBox.startRelais.P14);
		
		
		eBox.plugElectric();
		
		
# 		eBox.hotBus.plug(eBox.batteryRelais.A1);
		eBox.hotBus.plug(fusePanel.emergency3.In);
# 		eBox.hotBus.plug(eBox.batteryRelais.P21);
# 		eBox.hotBus.plug(eBox.batteryRelais.P11);
		
# 		eBox.iBus20.plug(eBox.batteryRelais.P14);
# 		eBox.iBus20.plug(eBox.startRelais.P11);
# 		eBox.iBus20.plug(eBox.batteryShunt.Minus);
		
# 		eBox.iBus10.plug(eBox.batteryShunt.Plus);
		eBox.iBus10.plug(generatorControlUnit.LoadBus);
		
		eBox.iBus10.plug(fusePanel.emergencyBus.In);
		eBox.iBus10.plug(fusePanel.batteryBus.In);
		eBox.iBus10.plug(eBox.rccbRelais.P14);
		
# 		eBox.iBus11.plug(eBox.generatorShunt.Minus);
# 		eBox.iBus11.plug(eBox.rccbRelais.P11);
		eBox.iBus11.plug(fusePanel.loadBus.In);
		
# 		eBox.iBus01.plug(eBox.batteryRelais.P24);
# 		eBox.iBus01.plug(eBox.generatorRelais.P24);
# 		eBox.iBus01.Minus.plug(eBox.rccbRelais.A1);
# 		
		eBox.iBus12.plug(fusePanel.emergency3.Out);
# 		eBox.iBus12.plug(eBox.emergencyRelais.A1);
# 		eBox.iBus12.plug(eBox.emergencyRelais.P14);
		
		
		eBox.batteryBus.plug(fusePanel.batteryBus.Out);
		
		
		eBox.iBus13.plug(circuitBreakerPanel.avionicBus.Out);
# 		eBox.iBus13.plug(eBox.avionicsRelais.A1);
# 		eBox.iBus13.plug(eBox.avionicsRelais.P11);
		
# 		eBox.avionicBus.plug(eBox.avionicsRelais.P14);
				
		eBox.loadBus.plug(fusePanel.loadBus.Out);
		
# 		eBox.emergencyBus.plug(eBox.emergencyRelais.P11);
		
		
# 		eBox.iBus30.plug(eBox.generatorRelais.P21);
# 		eBox.iBus30.plug(eBox.generatorRelais.P11);
	
# 		eBox.JB3E20.plug(eBox.startRelais.P34);
		eBox.JB3E20.plug(generatorControlUnit.StartPower);
# 		eBox.JB4E20.plug(eBox.startRelais.P31);
		
		
		
	# relais	
		eBox.emergencyRelais.P12.plug(fusePanel.emergencyBus.Out);
		
# 		eBox.generatorRelais.A2.plug(eBox.GND);
# 		
# 		eBox.generatorRelais.P14.plug(eBox.generatorShunt.Plus);
		
		#start
		eBox.startRelais.A1.plug(generatorControlUnit.StartContactor);
		#eBox.startRelais.A2.plug(eBox.GND);
		
		#eBox.startRelais.P21.plug(eBox.rccbRelais.A2);
		

};

var plugGenerator = func(){
	generator.Minus.plug(eBox.GND);
	
	generatorControlUnit.GND.plug(eBox.GND);
	generatorControlUnit.generatorOutputBus.plug(generatorControlUnit.GeneratorOutput);
	generatorControlUnit.LineContactorCoil.plug(eBox.generatorRelais.A1);
	
	
	#Gen Test
	generatorControlUnit.generatorOutputBus.plug(sidePanel.MainGeneratorTest.Com1);
	sidePanel.MainGeneratorTest.L11.plug(generatorControlUnit.RemoteTrip);
	sidePanel.MainGeneratorTest.L12.plug(generatorControlUnit.OverVoltageSelfTest);
	
	#Gen
	generatorControlUnit.generatorOutputBus.plug(sidePanel.MainGenerator.Com1);
	sidePanel.MainGenerator.L11.plug(generatorControlUnit.GeneratorControlSwitch);
	sidePanel.MainGenerator.L12.plug(generatorControlUnit.Reset);
	
	sidePanel.MainGenerator.Com2.plug(circuitBreakerPanel.GeneratorReset.Out);
	sidePanel.MainGenerator.L22.plug(generatorControlUnit.AntiCycle);
	
	generator.InterPole.plug(generatorControlUnit.InterPole);
	
	
}

var plugCircuitBreaker = func(){
		
		eBox.loadBus.plug(circuitBreakerPanel.AirCondition.In);
		eBox.loadBus.plug(circuitBreakerPanel.CigaretteLighter.In);
		eBox.loadBus.plug(circuitBreakerPanel.VDC12.In);
		eBox.loadBus.plug(circuitBreakerPanel.AudioMarker.In);
		eBox.loadBus.plug(circuitBreakerPanel.DME.In);
		eBox.loadBus.plug(circuitBreakerPanel.WeatherDetection.In);
		eBox.loadBus.plug(circuitBreakerPanel.Sirius.In);
		eBox.loadBus.plug(circuitBreakerPanel.Iridium.In);
		eBox.loadBus.plug(circuitBreakerPanel.IFD_RH_A.In);
		eBox.loadBus.plug(circuitBreakerPanel.PanelVent.In);
		eBox.loadBus.plug(circuitBreakerPanel.AirControl.In);
		eBox.loadBus.plug(circuitBreakerPanel.BusTie.In);
		eBox.loadBus.plug(circuitBreakerPanel.Emergency2.In);
		eBox.loadBus.plug(circuitBreakerPanel.CabinLight.In);
		eBox.loadBus.plug(circuitBreakerPanel.RecognitionLight.In);
		eBox.loadBus.plug(circuitBreakerPanel.NavLight.In);
		eBox.loadBus.plug(circuitBreakerPanel.OverSpeed.In);
		eBox.loadBus.plug(circuitBreakerPanel.FuelTransferL.In);
		eBox.loadBus.plug(circuitBreakerPanel.FuelTransferR.In);
		eBox.loadBus.plug(circuitBreakerPanel.PitotR.In);
		eBox.loadBus.plug(circuitBreakerPanel.EngineInstrument2.In);
		eBox.loadBus.plug(circuitBreakerPanel.DIP2.In);
		
		eBox.avionicBus.plug(circuitBreakerPanel.IFD_RH_B.In);
		eBox.avionicBus.plug(circuitBreakerPanel.TAS.In);
		eBox.avionicBus.plug(circuitBreakerPanel.AutopilotComputer.In);
		eBox.avionicBus.plug(circuitBreakerPanel.TurnCoordinator.In);
		
		eBox.batteryBus.plug(circuitBreakerPanel.BusTie.Out);
		eBox.batteryBus.plug(circuitBreakerPanel.FlapControl.In);
		eBox.batteryBus.plug(circuitBreakerPanel.Flap.In);
		eBox.batteryBus.plug(circuitBreakerPanel.Emergency1.In);
		eBox.batteryBus.plug(circuitBreakerPanel.avionicBus.In);
		eBox.batteryBus.plug(circuitBreakerPanel.InstrumentLight.In);
		eBox.batteryBus.plug(circuitBreakerPanel.StrobeLight.In);
		eBox.batteryBus.plug(circuitBreakerPanel.IceLight.In);
		eBox.batteryBus.plug(circuitBreakerPanel.VneWarn.In);
		eBox.batteryBus.plug(circuitBreakerPanel.FuelFlow.In);
		eBox.batteryBus.plug(circuitBreakerPanel.FuelPump2.In);
		eBox.batteryBus.plug(circuitBreakerPanel.WindShieldControl.In);
		eBox.batteryBus.plug(circuitBreakerPanel.WindShieldHeat.In);
		eBox.batteryBus.plug(circuitBreakerPanel.Boots.In);
		eBox.batteryBus.plug(circuitBreakerPanel.PropellerHeat.In);
		eBox.batteryBus.plug(circuitBreakerPanel.IFD_LH_B.In);
		eBox.batteryBus.plug(circuitBreakerPanel.Ignition.In);
		eBox.batteryBus.plug(circuitBreakerPanel.Start.In);
		eBox.batteryBus.plug(circuitBreakerPanel.AutopilotServo.In);
		eBox.batteryBus.plug(circuitBreakerPanel.EnvironmentalBleed.In);
		eBox.batteryBus.plug(circuitBreakerPanel.Hydraulic.In);
		
		eBox.emergencyBus.plug(circuitBreakerPanel.LowVolt.In);
		eBox.emergencyBus.plug(circuitBreakerPanel.VoltMonitor.In);
		eBox.emergencyBus.plug(circuitBreakerPanel.Alt.In);
		eBox.emergencyBus.plug(circuitBreakerPanel.GeneratorReset.In);
		eBox.emergencyBus.plug(circuitBreakerPanel.GlareLight.In);
		eBox.emergencyBus.plug(circuitBreakerPanel.WarnLight.In);
		eBox.emergencyBus.plug(circuitBreakerPanel.LandingLight.In);
		eBox.emergencyBus.plug(circuitBreakerPanel.StallWarning.In);
		eBox.emergencyBus.plug(circuitBreakerPanel.FuelQuantity.In);
		eBox.emergencyBus.plug(circuitBreakerPanel.FuelPump1.In);
		eBox.emergencyBus.plug(circuitBreakerPanel.PitotL.In);
		eBox.emergencyBus.plug(circuitBreakerPanel.IntakeAI.In);
		eBox.emergencyBus.plug(circuitBreakerPanel.EngineInstrument1.In);
		eBox.emergencyBus.plug(circuitBreakerPanel.DIP1.In);
		eBox.emergencyBus.plug(circuitBreakerPanel.IFD_LH_A.In);
		eBox.emergencyBus.plug(circuitBreakerPanel.Keypad.In);
		eBox.emergencyBus.plug(circuitBreakerPanel.ATC.In);
		eBox.emergencyBus.plug(circuitBreakerPanel.StandbyGyroskop.In);
		eBox.emergencyBus.plug(circuitBreakerPanel.Dump.In);
		eBox.emergencyBus.plug(circuitBreakerPanel.CabinPressure.In);
		eBox.emergencyBus.plug(circuitBreakerPanel.GearWarn.In);

		flapSystem.powerInBus.plug(circuitBreakerPanel.FlapUNB.In);
		flapSystem.inhibitBus.plug(circuitBreakerPanel.FlapUNB.Out);
		
		gearSystem.Aux1Bus.plug(circuitBreakerPanel.GearControl.In);
		gearSystem.Aux2Bus.plug(circuitBreakerPanel.GearAux1.In);
		gearSystem.Aux1Bus.plug(circuitBreakerPanel.GearAux1.Out);
		
		circuitBreakerPanel.RCCB.Out.plug(eBox.GND);
		circuitBreakerPanel.RCCB.In.plug(eBox.k8Relais.P21);
		
		circuitBreakerPanel.instrumentLightBus.plug(circuitBreakerPanel.InstrumentLight.Out);
		
		circuitBreakerPanel.instrumentLightBus.plug(lightBoard.testLightRelais.P14);
		circuitBreakerPanel.instrumentLightBus.plug(lightBoard.dayNightRelais.A1);
		circuitBreakerPanel.instrumentLightBus.plug(lightBoard.testLightRelais.A1);
		circuitBreakerPanel.instrumentLightBus.plug(annunciatorPanel.dimTestRelais.A1);
		
		circuitBreakerPanel.AutopilotComputerBus.plug(circuitBreakerPanel.AutopilotComputer.Out);
		circuitBreakerPanel.AutopilotServoBus.plug(circuitBreakerPanel.AutopilotServo.Out);
};

var plugSidePanel = func(){
		
		
	
		sidePanel.Emergency.Com1.plug(eBox.GND);
		sidePanel.Emergency.L11.plug(sidePanel.MainBattery.Com1);
		sidePanel.Emergency.L12.plug(eBox.emergencyRelais.A2);
		
		sidePanel.MainBattery.L12.plug(eBox.batteryRelais.A2);
		sidePanel.MainBattery.L22.plug(sidePanel.standbyAlternatorPowerBus.con());
		
		sidePanel.MainAvionics.Com1.plug(eBox.GND);
		sidePanel.MainAvionics.L12.plug(eBox.avionicsRelais.A2);
		
		sidePanel.MainExternalPower.L12.plug(fusePanel.externalPowerBus.con());
		sidePanel.MainExternalPower.Com1.plug(eBox.externalPowerRelais.A1);
		
		sidePanel.MainStandbyAlt.Com1.plug(sidePanel.MainBattery.Com2);
		sidePanel.MainStandbyAlt.L12.plug(eBox.hotBus.con());
		
		sidePanel.MainStandbyAlt.Com2.plug(circuitBreakerPanel.Alt.Out);
		sidePanel.MainStandbyAlt.L21.plug(eBox.alternatorRelais.A1);
		sidePanel.MainStandbyAlt.L22.plug(sidePanel.standbyAlternatorPowerBus.con());
		
		
		
		
	# Light
		sidePanel.LightStrobe.Com1.plug(	circuitBreakerPanel.StrobeLight.Out);
		sidePanel.LightNavigation.Com1.plug(	circuitBreakerPanel.NavLight.Out);
		
		sidePanel.LightLanding.Com1.plug(	circuitBreakerPanel.LandingLight.Out);
		sidePanel.LightLanding.L12.plug(	sidePanel.landingLightBus.con());
		sidePanel.landingLightBus.plug(		annunciatorPanel.landingRelais.A1);
		
		
		sidePanel.LightRecognition.Com1.plug(	circuitBreakerPanel.RecognitionLight.Out);
		sidePanel.LightRecognition.L12.plug(	sidePanel.recognitionLightBus.con());
		sidePanel.recognitionLightBus.plug(	annunciatorPanel.recognitionRelais.A1);
		
		
		sidePanel.LightCabin.Com1.plug(		circuitBreakerPanel.CabinLight.Out);
		sidePanel.LightIce.Com1.plug(		circuitBreakerPanel.IceLight.Out);
		sidePanel.LightGlare.Com1.plug(		circuitBreakerPanel.GlareLight.Out);
		
		#sidePanel.LightInstrument.Com1.plug ( circuitBreakerPanel.InstrumentLight.Out);
		circuitBreakerPanel.instrumentLightBus.plug(sidePanel.LightInstrument.Com1);
		circuitBreakerPanel.instrumentLightBus.plug(lightBoard.testLightRelais.P14);
		
		
	# Dimmer cabling
		
		
		sidePanel.LightNight.Com1.plug(eBox.GND);
 		sidePanel.LightNight.Com2.plug(eBox.GND);
 		sidePanel.LightNight.L11.plug(lightBoard.dayNightRelais.A2);
 		sidePanel.LightNight.L12.plug(lightBoard.testLightRelais.A2);
 		sidePanel.LightNight.L22.plug(annunciatorPanel.dimTestRelais.A2);
 		
		
		
		
	
};

var plugMasterPanel = func(){
	
		
		
	
	
	# fuel
		masterPanel.FuelTransferLeft.Com1.plug(circuitBreakerPanel.FuelTransferL.Out);
		masterPanel.FuelTransferRight.Com1.plug(circuitBreakerPanel.FuelTransferR.Out);
		masterPanel.FuelPump1.Com1.plug(circuitBreakerPanel.FuelPump1.Out);
		masterPanel.FuelPump2.Com1.plug(circuitBreakerPanel.FuelPump2.Out);
		
	# engine
		masterPanel.EngineMotoring.Com1.plug(circuitBreakerPanel.Start.Out);
		masterPanel.EngineMotoring.L11.plug(	eBox.JB3E20.con() );
		masterPanel.EngineMotoring.L13.plug(	eBox.JB4E20.con() );
		
		masterPanel.EngineMotoring.Com2.plug(	eBox.JB2G20.con() );
		masterPanel.EngineMotoring.L23.plug(	engine.IgnitionPlus );		#ignition

		masterPanel.EngineMotoring.Com3.plug(	eBox.JB2G20.con() );
		masterPanel.EngineMotoring.L33.plug(	annunciatorPanel.ignitionRelais.A1 );		#Anunciator
		
		
		masterPanel.EngineStart.Com1.plug(	circuitBreakerPanel.Ignition.Out );
		masterPanel.EngineStart.L11.plug(	eBox.JB2G20.con() );
		masterPanel.EngineStart.L12.plug(	eBox.JB2G20.con() );
		
		masterPanel.EngineStart.Com2.plug(	eBox.JB4E20.con() );
		masterPanel.EngineStart.L21.plug(	eBox.JB3E20.con() );
		
		
		
	# dimming
		masterPanel.glareLightBus.plug(sidePanel.LightGlare.L12);
		masterPanel.glareLightBus.plug(masterPanel.DimmerGlare.In);
		masterPanel.glareLightBus.plug(lightBoard.dayNightRelais.P22);
		
		masterPanel.warnLightBus.plug(circuitBreakerPanel.WarnLight.Out);
		masterPanel.warnLightBus.plug(masterPanel.DimmerAnnunciator.In);
		masterPanel.warnLightBus.plug(lightBoard.dayNightRelais.P52);
		
		masterPanel.instrumentLightBus.plug(sidePanel.LightInstrument.L12);
		masterPanel.instrumentLightBus.plug(masterPanel.DimmerInstrument.In);
		masterPanel.instrumentLightBus.plug(lightBoard.dayNightRelais.P32);
		masterPanel.instrumentLightBus.plug(masterPanel.DimmerKeypad.In);
		masterPanel.instrumentLightBus.plug(lightBoard.dayNightRelais.P12);
		masterPanel.instrumentLightBus.plug(masterPanel.DimmerSwitch.In);
		masterPanel.instrumentLightBus.plug(lightBoard.dayNightRelais.P42);
		
		
		masterPanel.DimmerKeypad.Out.plug(lightBoard.dayNightRelais.P14);
		masterPanel.DimmerGlare.Out.plug(lightBoard.dayNightRelais.P24);
		masterPanel.DimmerInstrument.Out.plug(lightBoard.dayNightRelais.P34);
		masterPanel.DimmerSwitch.Out.plug(lightBoard.dayNightRelais.P44);
		masterPanel.DimmerAnnunciator.Out.plug(lightBoard.dayNightRelais.P54);
		
};

var plugLight = func(){
	
	lightBoard.GNDBus.Minus.plug(eBox.GND);
	
	lightBoard.plugElectric();
	
	lightBoard.Strobe.Plus.plug(sidePanel.LightStrobe.L12);
	
	lightBoard.Navigation.Plus.plug(sidePanel.LightNavigation.L12);
	
	lightBoard.Landing.Plus.plug(sidePanel.landingLightBus.con());
					
	lightBoard.Cabin.Plus.plug(sidePanel.LightCabin.L12);
	
	lightBoard.Recognition.Plus.plug(sidePanel.recognitionLightBus.con());
	
	lightBoard.Map.Plus.plug(sidePanel.LightMap.L12);
	
	lightBoard.Ice.Plus.plug(sidePanel.LightIce.L12);
			
	lightBoard.Keypad.Plus.plug(lightBoard.dayNightRelais.P11);
	
	lightBoard.Glare.Plus.plug(lightBoard.dayNightRelais.P21);
	
	#lightBoard.Instrument.Plus.plug(lightBoard.dayNightRelais.P31);
	
	lightBoard.Switches.Plus.plug(lightBoard.dayNightRelais.P41);
	
	
	
	lightBoard.testLightRelais.P22.plug(flapSystem.transitionRelais.P11);
	lightBoard.testLightRelais.P32.plug(flapSystem.pos14Relais.P31);
	lightBoard.testLightRelais.P42.plug(flapSystem.limitDown.L22);
	
	lightBoard.testLightRelais.P52.plug(gearSystem.NoseGearLed);
	lightBoard.testLightRelais.P62.plug(gearSystem.LeftGearLed);
	lightBoard.testLightRelais.P72.plug(gearSystem.RightGearLed);
		
	
	
	
	
};

var plugFlap =func(){
	flapSystem.GNDBus.Minus.plug(eBox.GND);
	flapSystem.flapPowerBus.plug(circuitBreakerPanel.Flap.Out);
	flapSystem.powerInBus.plug(circuitBreakerPanel.FlapControl.Out);
	flapSystem.plugElectric();
	flapSystem.flapUnbRelais.P12.plug(annunciatorPanel.dimTestRelais.P502);
	
	
	
};
var plugGear =func(){
	gearSystem.plugElectric();
	gearSystem.GND.plug(eBox.GND);
	gearSystem.Aux2.plug(fusePanel.GearAux2.Out);
	gearSystem.Aux1.plug(gearSystem.Aux2Bus.con());
	gearSystem.Aux1Diode.Plus.plug(eBox.batteryBus.con());
	gearSystem.Aux1Diode.Minus.plug(gearSystem.Aux2Bus.con());
	gearSystem.CtrlBus.plug(circuitBreakerPanel.GearControl.Out);
	gearSystem.CTRL.plug(gearSystem.CtrlBus.con());
	gearSystem.MainGearSwitch.Com1.plug(gearSystem.CtrlBus.con());
	gearSystem.HydrBus.plug(circuitBreakerPanel.Hydraulic.Out);
	gearSystem.Annunciator.plug(annunciatorPanel.dimTestRelais.P332);
	gearSystem.Warning.plug(annunciatorPanel.dimTestRelais.P492);
};

var plugAnnuciator = func(){
	annunciatorPanel.GNDBus.Minus.plug(eBox.GND);
	annunciatorPanel.plugElectric();
	lightBoard.annuciatorDimBus.plug(annunciatorPanel.dimTestRelais.P12);# +14-28V Dim Voltage
	lightBoard.testLightRelais.P11.plug(annunciatorPanel.dimTestRelais.P14);# +28V Light-Test
	
	eBox.iBus03.plug(annunciatorPanel.dimTestRelais.P482); # Gernator 1 Fail
	annunciatorPanel.externalPowerBus.plug(fusePanel.externalPowerBus.con());
	
	
}

var plugFuel = func(){
	
	fuelSystem.oPump1.Plus.plug(masterPanel.FuelPump1.L12);
	fuelSystem.oPump1.Minus.plug(eBox.GND);
	
	fuelSystem.oPump2.Plus.plug(masterPanel.FuelPump2.L12);
	fuelSystem.oPump2.Minus.plug(eBox.GND);
	
	fuelSystem.oPumpLeft.Plus.plug(masterPanel.FuelTransferLeft.L12);
	fuelSystem.oPumpLeft.Minus.plug(eBox.GND);
	
	fuelSystem.oPumpRight.Plus.plug(masterPanel.FuelTransferRight.L12);
	fuelSystem.oPumpRight.Minus.plug(eBox.GND);
	
}

var plugFusePanel = func(){
	
	fusePanel.plugElectric();
	fusePanel.GearAux2.In.plug(eBox.hotBus.con());
}
var plugEngine = func(){
	
	engine.GND.plug(eBox.GND);
	engine.LowOilPress.plug(annunciatorPanel.dimTestRelais.P392);
	engine.LowPitch.plug(annunciatorPanel.dimTestRelais.P232);
	
}

var plugAlternator = func(){
	
	standbyAlternatorRegulator.GND.plug(eBox.GND);
	standbyAlternatorRegulator.Sense.plug(eBox.emergencyBus.con());
	standbyAlternatorRegulator.PowerVoltage.plug(sidePanel.standbyAlternatorPowerBus.Minus);
	standbyAlternatorRegulator.AnnuciatorLight.plug(annunciatorPanel.dimTestRelais.P212);
		
	alternator.Minus.plug(eBox.GND);
	alternator.Field.plug(standbyAlternatorRegulator.Field);
	alternator.Plus.plug(eBox.alternatorRelais.P11);
}

var plugLowVoltageMonitor = func(){
	lowVoltageMonitor.plugElectric();
	lowVoltageMonitor.GND.plug(eBox.GND);
	lowVoltageMonitor.LowVoltSense.plug(circuitBreakerPanel.LowVolt.Out);
	lowVoltageMonitor.LowVoltOut.plug(annunciatorPanel.dimTestRelais.P222);
}

var plugDIP =func(){
	digitalInstrumentPackage.plugElectric();
	digitalInstrumentPackage.GND.plug(eBox.GND);
	
	digitalInstrumentPackage.PowerInputA.plug(circuitBreakerPanel.DIP1.Out);
	digitalInstrumentPackage.PowerInputB.plug(circuitBreakerPanel.DIP2.Out);
	digitalInstrumentPackage.VoltMonitor.plug(circuitBreakerPanel.VoltMonitor.Out);
	
	digitalInstrumentPackage.Dimming.plug(lightBoard.instrumentDimBus.con());
	
}
var plugEIP = func(){
	engineInstrumentPackage.plugElectric();
	engineInstrumentPackage.GND.plug(eBox.GND);
	
	engineInstrumentPackage.PowerInputA.plug(circuitBreakerPanel.EngineInstrument1.Out);
	engineInstrumentPackage.PowerInputB.plug(circuitBreakerPanel.EngineInstrument2.Out);
	
	engineInstrumentPackage.Dimming.plug(lightBoard.instrumentDimBus.con());
	
}
#---------------
var plugAudioPanel = func(){
	audioPanel.plugElectric();
	audioPanel.GND.plug(eBox.GND);
	audioPanel.PowerInput.plug(circuitBreakerPanel.AudioMarker.Out);
	audioPanel.Dimming.plug(lightBoard.instrumentDimBus.con());
}
var plugKeypad = func(){
	keypad.plugElectric();
	keypad.GND.plug(eBox.GND);
	keypad.PowerInput.plug(circuitBreakerPanel.Keypad.Out);
	keypad.Dimming.plug(lightBoard.instrumentDimBus.con());
}
var plugAutopilot = func(){
	autopilot.plugElectric();
	autopilot.GND.plug(eBox.GND);
	
	autopilot.StallWaringRelais.A1.plug(circuitBreakerPanel.AutopilotComputerBus.con());
	autopilot.StallWaringRelais.A2.plug(pitotSystem.Warn);
	
	masterPanel.AutopilotMaster.Com1.plug(autopilot.ApMasterBus.con());
	masterPanel.AutopilotMaster.L11.plug(circuitBreakerPanel.AutopilotComputerBus.con());
	masterPanel.AutopilotMaster.L12.plug(circuitBreakerPanel.AutopilotComputerBus.con());
	
	masterPanel.AutopilotMaster.Com2.plug(autopilot.FdEnable);
	masterPanel.AutopilotMaster.L22.plug(eBox.GND);
	masterPanel.AutopilotMaster.L23.plug(eBox.GND);
	
	masterPanel.AutopilotPitchTrim.Com1.plug(circuitBreakerPanel.AutopilotServoBus.con());
	masterPanel.AutopilotPitchTrim.L12.plug(autopilot.PitchTrim28V);
	
	masterPanel.AutopilotYawDamper.Com1.plug(circuitBreakerPanel.AutopilotServoBus.con());
	masterPanel.AutopilotYawDamper.L12.plug(autopilot.YawDamper);
	
	autopilot.swtDisengage.L21.plug(circuitBreakerPanel.AutopilotServoBus.con());
		
	autopilot.swtTrimCommannd.L13.plug(circuitBreakerPanel.AutopilotServoBus.con());
	autopilot.swtTrimCommannd.L21.plug(circuitBreakerPanel.AutopilotServoBus.con());
	
	autopilot.Dimming.plug(lightBoard.instrumentDimBus.con());
}
var plugDme = func(){
	dme.plugElectric();
	dme.GND.plug(eBox.GND);
	dme.PowerInput.plug(circuitBreakerPanel.DME.Out);
	dme.Dimming.plug(lightBoard.instrumentDimBus.con());
}
var plugFuelFlow = func(){
	fuelFlow.plugElectric();
	fuelFlow.GND.plug(eBox.GND);
	fuelFlow.PowerInput.plug(circuitBreakerPanel.FuelFlow.Out);
	fuelFlow.Dimming.plug(lightBoard.instrumentDimBus.con());
}
var plugTurnCoordinator = func(){
	turnCoordinator.plugElectric();
	turnCoordinator.GND.plug(eBox.GND);
	turnCoordinator.PowerInput.plug(circuitBreakerPanel.TurnCoordinator.Out);
	turnCoordinator.Dimming.plug(lightBoard.instrumentDimBus.con());
}
var plugStbyAirspeed = func(){
	stbyAirspeed.plugElectric();
	stbyAirspeed.GND.plug(eBox.GND);
	# TODO stbyAirspeed.PowerInput.plug(circuitBreakerPanel..Out);
	stbyAirspeed.Dimming.plug(lightBoard.instrumentDimBus.con());
}
var plugStbyAltimeter = func(){
	stbyAltimeter.plugElectric();
	stbyAltimeter.GND.plug(eBox.GND);
	# TODO stbyAltimeter.PowerInput.plug(circuitBreakerPanel..Out);
	stbyAltimeter.Dimming.plug(lightBoard.instrumentDimBus.con());
}
var plugStbyAttitude = func(){
	stbyAttitude.plugElectric();
	stbyAttitude.GND.plug(eBox.GND);
	stbyAttitude.PowerInput.plug(circuitBreakerPanel.StandbyGyroskop.Out);
	stbyAttitude.Dimming.plug(lightBoard.instrumentDimBus.con());
}

var plugPitotSystem = func(){
	pitotSystem.GND.plug(eBox.GND);
	pitotSystem.plugElectric();
}



var plugElectric = func(){
	plugEBox();
	plugGenerator();
	plugCircuitBreaker();
	plugSidePanel();
	plugMasterPanel();
	plugFusePanel();
	plugLight();
	plugAnnuciator();
	plugFlap();
	plugGear();
	plugFuel();
	plugEngine();
	plugAlternator();
	plugLowVoltageMonitor();
	plugDIP();
	plugEIP();
	
	plugAudioPanel();
	plugKeypad();
	plugAutopilot();
	plugDme();
	plugFuelFlow();
	plugTurnCoordinator();
	plugStbyAirspeed();
	plugStbyAltimeter();
	plugStbyAttitude();
	
	plugPitotSystem();
	
	
	
};