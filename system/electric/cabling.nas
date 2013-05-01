#    This file is part of extra500
#
#    The Changer is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 2 of the License, or
#    (at your option) any later version.
#
#    The Changer is distributed in the hope that it will be useful,
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
 var plugMainBoard = func(){
	
		
	# Sources
		battery.Minus.plug(mainBoard.GND);
		externalPower.Minus.plug(mainBoard.GND);
	# Bus	
	
		mainBoard.hotBus.plug(battery.Plus);
		mainBoard.iBus40.plug(fusePanel.externalPower.In);
		mainBoard.iBus40.plug(externalPower.Plus);
		
		mainBoard.iBus30.plug(generator.Plus);
 		mainBoard.iBus30.plug(generatorControlUnit.POR);
		mainBoard.iBus30.plug(mainBoard.startRelais.P14);
		
		
		mainBoard.plugElectric();
		
		
# 		mainBoard.hotBus.plug(mainBoard.batteryRelais.A1);
		mainBoard.hotBus.plug(fusePanel.emergency3.In);
# 		mainBoard.hotBus.plug(mainBoard.batteryRelais.P21);
# 		mainBoard.hotBus.plug(mainBoard.batteryRelais.P11);
		
# 		mainBoard.iBus20.plug(mainBoard.batteryRelais.P14);
# 		mainBoard.iBus20.plug(mainBoard.startRelais.P11);
# 		mainBoard.iBus20.plug(mainBoard.batteryShunt.Minus);
		
# 		mainBoard.iBus10.plug(mainBoard.batteryShunt.Plus);
		mainBoard.iBus10.plug(generatorControlUnit.LoadBus);
		
		mainBoard.iBus10.plug(fusePanel.emergencyBus.In);
		mainBoard.iBus10.plug(fusePanel.batteryBus.In);
		mainBoard.iBus10.plug(mainBoard.rccbRelais.P14);
		
# 		mainBoard.iBus11.plug(mainBoard.generatorShunt.Minus);
# 		mainBoard.iBus11.plug(mainBoard.rccbRelais.P11);
		mainBoard.iBus11.plug(fusePanel.loadBus.In);
		
# 		mainBoard.iBus01.plug(mainBoard.batteryRelais.P24);
# 		mainBoard.iBus01.plug(mainBoard.generatorRelais.P24);
# 		mainBoard.iBus01.Minus.plug(mainBoard.rccbRelais.A1);
# 		
		mainBoard.iBus12.plug(fusePanel.emergency3.Out);
# 		mainBoard.iBus12.plug(mainBoard.emergencyRelais.A1);
# 		mainBoard.iBus12.plug(mainBoard.emergencyRelais.P14);
		
		
		mainBoard.batteryBus.plug(fusePanel.batteryBus.Out);
		
		
		mainBoard.iBus13.plug(circuitBreakerPanel.avionicBus.Out);
# 		mainBoard.iBus13.plug(mainBoard.avionicsRelais.A1);
# 		mainBoard.iBus13.plug(mainBoard.avionicsRelais.P11);
		
# 		mainBoard.avionicBus.plug(mainBoard.avionicsRelais.P14);
				
		mainBoard.loadBus.plug(fusePanel.loadBus.Out);
		
# 		mainBoard.emergencyBus.plug(mainBoard.emergencyRelais.P11);
		
		
# 		mainBoard.iBus30.plug(mainBoard.generatorRelais.P21);
# 		mainBoard.iBus30.plug(mainBoard.generatorRelais.P11);
	
# 		mainBoard.JB3E20.plug(mainBoard.startRelais.P34);
		mainBoard.JB3E20.plug(generatorControlUnit.StartPower);
# 		mainBoard.JB4E20.plug(mainBoard.startRelais.P31);
		
		
		
	# relais	
		mainBoard.emergencyRelais.P12.plug(fusePanel.emergencyBus.Out);
		
# 		mainBoard.generatorRelais.A2.plug(mainBoard.GND);
# 		
# 		mainBoard.generatorRelais.P14.plug(mainBoard.generatorShunt.Plus);
		
		#start
		mainBoard.startRelais.A1.plug(generatorControlUnit.StartContactor);
		#mainBoard.startRelais.A2.plug(mainBoard.GND);
		
		#mainBoard.startRelais.P21.plug(mainBoard.rccbRelais.A2);
		

};

var plugGenerator = func(){
	generator.Minus.plug(mainBoard.GND);
	
	generatorControlUnit.GND.plug(mainBoard.GND);
	generatorControlUnit.generatorOutputBus.plug(generatorControlUnit.GeneratorOutput);
	generatorControlUnit.LineContactorCoil.plug(mainBoard.generatorRelais.A1);
	
	
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
		
		mainBoard.loadBus.plug(circuitBreakerPanel.AirCondition.In);
		mainBoard.loadBus.plug(circuitBreakerPanel.CigaretteLighter.In);
		mainBoard.loadBus.plug(circuitBreakerPanel.VDC12.In);
		mainBoard.loadBus.plug(circuitBreakerPanel.AudioMarker.In);
		mainBoard.loadBus.plug(circuitBreakerPanel.DME.In);
		mainBoard.loadBus.plug(circuitBreakerPanel.WeatherDetection.In);
		mainBoard.loadBus.plug(circuitBreakerPanel.Sirius.In);
		mainBoard.loadBus.plug(circuitBreakerPanel.Iridium.In);
		mainBoard.loadBus.plug(circuitBreakerPanel.IFD_RH_A.In);
		mainBoard.loadBus.plug(circuitBreakerPanel.PanelVent.In);
		mainBoard.loadBus.plug(circuitBreakerPanel.AirControl.In);
		mainBoard.loadBus.plug(circuitBreakerPanel.BusTie.In);
		mainBoard.loadBus.plug(circuitBreakerPanel.Emergency2.In);
		mainBoard.loadBus.plug(circuitBreakerPanel.CabinLight.In);
		mainBoard.loadBus.plug(circuitBreakerPanel.RecognitionLight.In);
		mainBoard.loadBus.plug(circuitBreakerPanel.NavLight.In);
		mainBoard.loadBus.plug(circuitBreakerPanel.OverSpeed.In);
		mainBoard.loadBus.plug(circuitBreakerPanel.FuelTransferL.In);
		mainBoard.loadBus.plug(circuitBreakerPanel.FuelTransferR.In);
		mainBoard.loadBus.plug(circuitBreakerPanel.PitotR.In);
		mainBoard.loadBus.plug(circuitBreakerPanel.EngineInstrument2.In);
		mainBoard.loadBus.plug(circuitBreakerPanel.DIP2.In);
		
		mainBoard.avionicBus.plug(circuitBreakerPanel.IFD_RH_B.In);
		mainBoard.avionicBus.plug(circuitBreakerPanel.TAS.In);
		mainBoard.avionicBus.plug(circuitBreakerPanel.AutopilotComputer.In);
		mainBoard.avionicBus.plug(circuitBreakerPanel.TurnCoordinator.In);
		
		mainBoard.batteryBus.plug(circuitBreakerPanel.BusTie.Out);
		mainBoard.batteryBus.plug(circuitBreakerPanel.FlapControl.In);
		mainBoard.batteryBus.plug(circuitBreakerPanel.Flap.In);
		mainBoard.batteryBus.plug(circuitBreakerPanel.Emergency1.In);
		mainBoard.batteryBus.plug(circuitBreakerPanel.avionicBus.In);
		mainBoard.batteryBus.plug(circuitBreakerPanel.InstrumentLight.In);
		mainBoard.batteryBus.plug(circuitBreakerPanel.StrobeLight.In);
		mainBoard.batteryBus.plug(circuitBreakerPanel.IceLight.In);
		mainBoard.batteryBus.plug(circuitBreakerPanel.VneWarn.In);
		mainBoard.batteryBus.plug(circuitBreakerPanel.FuelFlow.In);
		mainBoard.batteryBus.plug(circuitBreakerPanel.FuelPump2.In);
		mainBoard.batteryBus.plug(circuitBreakerPanel.WindShieldControl.In);
		mainBoard.batteryBus.plug(circuitBreakerPanel.WindShieldHeat.In);
		mainBoard.batteryBus.plug(circuitBreakerPanel.Boots.In);
		mainBoard.batteryBus.plug(circuitBreakerPanel.PropellerHeat.In);
		mainBoard.batteryBus.plug(circuitBreakerPanel.IFD_LH_B.In);
		mainBoard.batteryBus.plug(circuitBreakerPanel.Ignition.In);
		mainBoard.batteryBus.plug(circuitBreakerPanel.Start.In);
		mainBoard.batteryBus.plug(circuitBreakerPanel.AutopilotServo.In);
		mainBoard.batteryBus.plug(circuitBreakerPanel.EnvironmentalBleed.In);
		mainBoard.batteryBus.plug(circuitBreakerPanel.Hydraulic.In);
		
		mainBoard.emergencyBus.plug(circuitBreakerPanel.LowVolt.In);
		mainBoard.emergencyBus.plug(circuitBreakerPanel.VoltMonitor.In);
		mainBoard.emergencyBus.plug(circuitBreakerPanel.Alt.In);
		mainBoard.emergencyBus.plug(circuitBreakerPanel.GeneratorReset.In);
		mainBoard.emergencyBus.plug(circuitBreakerPanel.GlareLight.In);
		mainBoard.emergencyBus.plug(circuitBreakerPanel.WarnLight.In);
		mainBoard.emergencyBus.plug(circuitBreakerPanel.LandingLight.In);
		mainBoard.emergencyBus.plug(circuitBreakerPanel.StallWarning.In);
		mainBoard.emergencyBus.plug(circuitBreakerPanel.FuelQuantity.In);
		mainBoard.emergencyBus.plug(circuitBreakerPanel.FuelPump1.In);
		mainBoard.emergencyBus.plug(circuitBreakerPanel.PitotL.In);
		mainBoard.emergencyBus.plug(circuitBreakerPanel.IntakeAI.In);
		mainBoard.emergencyBus.plug(circuitBreakerPanel.EngineInstrument1.In);
		mainBoard.emergencyBus.plug(circuitBreakerPanel.DIP1.In);
		mainBoard.emergencyBus.plug(circuitBreakerPanel.IFD_LH_A.In);
		mainBoard.emergencyBus.plug(circuitBreakerPanel.Keypad.In);
		mainBoard.emergencyBus.plug(circuitBreakerPanel.ATC.In);
		mainBoard.emergencyBus.plug(circuitBreakerPanel.StandbyGyroskop.In);
		mainBoard.emergencyBus.plug(circuitBreakerPanel.Dump.In);
		mainBoard.emergencyBus.plug(circuitBreakerPanel.CabinPressure.In);
		mainBoard.emergencyBus.plug(circuitBreakerPanel.GearWarn.In);

		flapSystem.powerInBus.plug(circuitBreakerPanel.FlapUNB.In);
		flapSystem.inhibitBus.plug(circuitBreakerPanel.FlapUNB.Out);
		
		#mainBoard.hotBus.plug(circuitBreakerPanel.GearControl.In);
		#mainBoard.hotBus.plug(circuitBreakerPanel.GearAux1.In);
		circuitBreakerPanel.RCCB.Out.plug(mainBoard.GND);
		circuitBreakerPanel.RCCB.In.plug(mainBoard.k8Relais.P21);
		
		circuitBreakerPanel.instrumentLightBus.plug(circuitBreakerPanel.InstrumentLight.Out);
		
		circuitBreakerPanel.instrumentLightBus.plug(lightBoard.testLightRelais.P14);
		circuitBreakerPanel.instrumentLightBus.plug(lightBoard.dayNightRelais.A1);
		circuitBreakerPanel.instrumentLightBus.plug(lightBoard.testLightRelais.A1);
		circuitBreakerPanel.instrumentLightBus.plug(annunciatorPanel.dimTestRelais.A1);
		
};

var plugSidePanel = func(){
		
		
	
		sidePanel.Emergency.Com1.plug(mainBoard.GND);
		sidePanel.Emergency.L11.plug(sidePanel.MainBattery.Com1);
		sidePanel.Emergency.L12.plug(mainBoard.emergencyRelais.A2);
		
		sidePanel.MainBattery.L12.plug(mainBoard.batteryRelais.A2);
		
		sidePanel.MainAvionics.Com1.plug(mainBoard.GND);
		sidePanel.MainAvionics.L12.plug(mainBoard.avionicsRelais.A2);
		
		sidePanel.MainExternalPower.L12.plug(fusePanel.externalPowerBus.con());
		sidePanel.MainExternalPower.Com1.plug(mainBoard.externalPowerRelais.A1);
		
		
		
		
	# Light
		sidePanel.LightStrobe.Com1.plug(	circuitBreakerPanel.StrobeLight.Out);
		sidePanel.LightNavigation.Com1.plug(	circuitBreakerPanel.NavLight.Out);
		
		sidePanel.LightLanding.Com1.plug(	circuitBreakerPanel.LandingLight.Out);
		sidePanel.LightLanding.Com2.plug(	mainBoard.GND);
		sidePanel.LightLanding.L22.plug(	annunciatorPanel.dimTestRelais.P312);
		
		sidePanel.LightRecognition.Com1.plug(	circuitBreakerPanel.RecognitionLight.Out);
		sidePanel.LightRecognition.Com2.plug(	mainBoard.GND);
		sidePanel.LightRecognition.L22.plug(	annunciatorPanel.dimTestRelais.P302);
		
		sidePanel.LightCabin.Com1.plug(		circuitBreakerPanel.CabinLight.Out);
		sidePanel.LightIce.Com1.plug(		circuitBreakerPanel.IceLight.Out);
		sidePanel.LightGlare.Com1.plug(		circuitBreakerPanel.GlareLight.Out);
		
		#sidePanel.LightInstrument.Com1.plug ( circuitBreakerPanel.InstrumentLight.Out);
		circuitBreakerPanel.instrumentLightBus.plug(sidePanel.LightInstrument.Com1);
		circuitBreakerPanel.instrumentLightBus.plug(lightBoard.testLightRelais.P14);
		
		
	# Dimmer cabling
		
		
		sidePanel.LightNight.Com1.plug(mainBoard.GND);
 		sidePanel.LightNight.Com2.plug(mainBoard.GND);
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
		masterPanel.EngineMotoring.L11.plug(	mainBoard.JB3E20.con() );
		masterPanel.EngineMotoring.L13.plug(	mainBoard.JB4E20.con() );
		
		masterPanel.EngineMotoring.Com2.plug(	mainBoard.JB2G20.Minus );
		masterPanel.EngineMotoring.L23.plug(	engine.IgnitionPlus );		#ignition
		masterPanel.EngineMotoring.Com3.plug(	mainBoard.JB2G20.con() );
		#masterPanel.EngineMotoring.L33.plug(	engine.IgnitionPlus );		#Anunciator
		
		
		masterPanel.EngineStart.Com1.plug(	circuitBreakerPanel.Ignition.Out );
		masterPanel.EngineStart.L11.plug(	mainBoard.JB2G20.con() );
		masterPanel.EngineStart.L12.plug(	mainBoard.JB2G20.con() );
		
		masterPanel.EngineStart.Com2.plug(	mainBoard.JB4E20.con() );
		masterPanel.EngineStart.L21.plug(	mainBoard.JB3E20.con() );
		
		
		
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
	
	lightBoard.GNDBus.Minus.plug(mainBoard.GND);
	
	lightBoard.plugElectric();
	
	lightBoard.Strobe.Plus.plug(sidePanel.LightStrobe.L12);
	
	lightBoard.Navigation.Plus.plug(sidePanel.LightNavigation.L12);
	
	lightBoard.Landing.Plus.plug(sidePanel.LightLanding.L12);
					
	lightBoard.Cabin.Plus.plug(sidePanel.LightCabin.L12);
	
	lightBoard.Recognition.Plus.plug(sidePanel.LightRecognition.L12);
	
	lightBoard.Map.Plus.plug(sidePanel.LightMap.L12);
	
	lightBoard.Ice.Plus.plug(sidePanel.LightIce.L12);
			
	lightBoard.Keypad.Plus.plug(lightBoard.dayNightRelais.P11);
	
	lightBoard.Glare.Plus.plug(lightBoard.dayNightRelais.P21);
	
	lightBoard.Instrument.Plus.plug(lightBoard.dayNightRelais.P31);
	
	lightBoard.Switches.Plus.plug(lightBoard.dayNightRelais.P41);
	
	
	
	lightBoard.testLightRelais.P22.plug(flapSystem.transitionRelais.P11);
	lightBoard.testLightRelais.P32.plug(flapSystem.pos14Relais.P31);
	lightBoard.testLightRelais.P42.plug(flapSystem.limitDown.L22);
	
	lightBoard.testLightRelais.P52.plug(gearSystem.GearNose);
	lightBoard.testLightRelais.P62.plug(gearSystem.GearLeft);
	lightBoard.testLightRelais.P72.plug(gearSystem.GearRight);
		
	
	
	
	
};

var plugFlap =func(){
	flapSystem.GNDBus.Minus.plug(mainBoard.GND);
	flapSystem.flapPowerBus.plug(circuitBreakerPanel.Flap.Out);
	flapSystem.powerInBus.plug(circuitBreakerPanel.FlapControl.Out);
	flapSystem.plugElectric();
	
	
	
};
var plugGear =func(){
	gearSystem.GND.plug(mainBoard.GND);
};

var plugAnnuciator = func(){
	annunciatorPanel.GNDBus.Minus.plug(mainBoard.GND);
	annunciatorPanel.plugElectric();
	lightBoard.annuciatorDimBus.plug(annunciatorPanel.dimTestRelais.P12);# +14-28V Dim Voltage
	lightBoard.testLightRelais.P11.plug(annunciatorPanel.dimTestRelais.P14);# +28V Light-Test
	
	mainBoard.iBus03.plug(annunciatorPanel.dimTestRelais.P482); # Gernator 1 Fail
	annunciatorPanel.externalPowerBus.plug(fusePanel.externalPowerBus.con());
}

var plugFuel = func(){
	
	oFuelSystem.oPump1.Plus.plug(masterPanel.FuelPump1.L12);
	oFuelSystem.oPump1.Minus.plug(mainBoard.GND);
	
	oFuelSystem.oPump2.Plus.plug(masterPanel.FuelPump2.L12);
	oFuelSystem.oPump2.Minus.plug(mainBoard.GND);
	
	oFuelSystem.oPumpLeft.Plus.plug(masterPanel.FuelTransferLeft.L12);
	oFuelSystem.oPumpLeft.Minus.plug(mainBoard.GND);
	
	oFuelSystem.oPumpRight.Plus.plug(masterPanel.FuelTransferRight.L12);
	oFuelSystem.oPumpRight.Minus.plug(mainBoard.GND);
	
}

var plugFusePanel = func(){
	
	fusePanel.plugElectric();
}
var plugEngine = func(){
	
	engine.GND.plug(mainBoard.GND);
}
var plugElectric = func(){
	plugMainBoard();
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
	
};