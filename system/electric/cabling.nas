var plugMainBoard = func(){
	# Sources
		mainBoard.oBattery.minus.plug(mainBoard.GND);
	# Bus	
		mainBoard.hotBus.plug(mainBoard.oBattery.plus);
		mainBoard.hotBus.plug(mainBoard.batteryRelais.A1);
		mainBoard.hotBus.plug(mainBoard.dayNightRelais.A1);
		mainBoard.hotBus.plug(mainBoard.dayNightRelais.A1);
		mainBoard.hotBus.plug(mainBoard.testLightRelais.A1);
		mainBoard.hotBus.plug(fusePanel.emergency3.In);
		mainBoard.hotBus.plug(mainBoard.batteryRelais.P21);
		mainBoard.hotBus.plug(mainBoard.batteryRelais.P11);
		
		mainBoard.iBus20.plug(mainBoard.batteryRelais.P14);
		mainBoard.iBus20.plug(mainBoard.batteryShunt.Minus);
		
		mainBoard.iBus10.plug(mainBoard.batteryShunt.Plus);
		mainBoard.iBus10.plug(fusePanel.emergencyBus.In);
		mainBoard.iBus10.plug(fusePanel.batteryBus.In);
		mainBoard.iBus10.plug(mainBoard.rccbRelais.P14);
		
		mainBoard.iBus11.plug(mainBoard.generatorShunt.Minus);
		mainBoard.iBus11.plug(mainBoard.rccbRelais.P11);
		mainBoard.iBus11.plug(fusePanel.loadBus.In);
		
		mainBoard.iBus01.plug(mainBoard.batteryRelais.P24);
		mainBoard.iBus01.plug(mainBoard.rccbRelais.A1);
		
		mainBoard.iBus12.plug(fusePanel.emergency3.Out);
		mainBoard.iBus12.plug(mainBoard.emergencyRelais.A1);
		mainBoard.iBus12.plug(mainBoard.emergencyRelais.P14);
		
		
		mainBoard.batteryBus.plug(fusePanel.batteryBus.Out);
		mainBoard.batteryBus.plug(circuitBreakerPanel.avionicBus.In);
		
		mainBoard.iBus13.plug(circuitBreakerPanel.avionicBus.Out);
		mainBoard.iBus13.plug(mainBoard.avionicsRelais.A1);
		mainBoard.iBus13.plug(mainBoard.avionicsRelais.P11);
		
		mainBoard.avionicBus.plug(mainBoard.avionicsRelais.P14);
				
		mainBoard.loadBus.plug(fusePanel.loadBus.Out);
		
		mainBoard.emergencyBus.plug(mainBoard.emergencyRelais.P11);
			
		
	# relais	
		mainBoard.emergencyRelais.P12.plug(fusePanel.emergencyBus.Out);
		

};

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

		#mainBoard.hotBus.plug(circuitBreakerPanel.FlapUNB.In);
		#mainBoard.hotBus.plug(circuitBreakerPanel.GearControl.In);
		#mainBoard.hotBus.plug(circuitBreakerPanel.GearAux1.In);
		circuitBreakerPanel.RCCB.Out.plug(mainBoard.GND);
		circuitBreakerPanel.RCCB.In.plug(mainBoard.rccbRelais.A2);


		
};

var plugSidePanel = func(){
		
		
	
		sidePanel.Emergency.Com1.plug(mainBoard.GND);
		sidePanel.Emergency.L11.plug(sidePanel.MainBattery.Com1);
		sidePanel.Emergency.L12.plug(mainBoard.emergencyRelais.A2);
		
		sidePanel.MainBattery.L12.plug(mainBoard.batteryRelais.A2);
		
		sidePanel.MainAvionics.Com1.plug(mainBoard.GND);
		sidePanel.MainAvionics.L12.plug(mainBoard.avionicsRelais.A2);
		
		
	# Light
		sidePanel.LightStrobe.Com1.plug(	circuitBreakerPanel.StrobeLight.Out);
		sidePanel.LightNavigation.Com1.plug(	circuitBreakerPanel.NavLight.Out);
		sidePanel.LightLanding.Com1.plug(	circuitBreakerPanel.LandingLight.Out);
		sidePanel.LightRecognition.Com1.plug(	circuitBreakerPanel.RecognitionLight.Out);
		sidePanel.LightCabin.Com1.plug(		circuitBreakerPanel.CabinLight.Out);
		sidePanel.LightIce.Com1.plug(		circuitBreakerPanel.IceLight.Out);
		sidePanel.LightGlare.Com1.plug(		circuitBreakerPanel.GlareLight.Out);
		
		sidePanel.LightInstrument.Com1.plug ( circuitBreakerPanel.InstrumentLight.Out);
		
	# Dimmer cabling
		
		
		sidePanel.LightNight.Com1.plug(mainBoard.GND);
 		sidePanel.LightNight.Com2.plug(mainBoard.GND);
 		sidePanel.LightNight.L11.plug(mainBoard.dayNightRelais.A2);
 		sidePanel.LightNight.L12.plug(mainBoard.testLightRelais.A2);
 		
		
	
};

var plugMasterPanel = func(){
	
	# fuel
		masterPanel.FuelTransferLeft.Com1.plug(circuitBreakerPanel.FuelTransferL.Out);
		masterPanel.FuelTransferRight.Com1.plug(circuitBreakerPanel.FuelTransferR.Out);
		masterPanel.FuelPump1.Com1.plug(circuitBreakerPanel.FuelPump1.Out);
		masterPanel.FuelPump2.Com1.plug(circuitBreakerPanel.FuelPump2.Out);
		
	# engine
		
	# dimming
		masterPanel.glareLightBus.plug(sidePanel.LightGlare.L12);
		masterPanel.glareLightBus.plug(masterPanel.DimmerGlare.In);
		masterPanel.glareLightBus.plug(mainBoard.dayNightRelais.P22);
		
		masterPanel.warnLightBus.plug(circuitBreakerPanel.WarnLight.Out);
		masterPanel.warnLightBus.plug(masterPanel.DimmerAnnunciator.In);
		masterPanel.warnLightBus.plug(mainBoard.dayNightRelais.P52);
		
		masterPanel.instrumentLightBus.plug(sidePanel.LightInstrument.L12);
		masterPanel.instrumentLightBus.plug(masterPanel.DimmerInstrument.In);
		masterPanel.instrumentLightBus.plug(mainBoard.dayNightRelais.P32);
		masterPanel.instrumentLightBus.plug(masterPanel.DimmerKeypad.In);
		masterPanel.instrumentLightBus.plug(mainBoard.dayNightRelais.P12);
		masterPanel.instrumentLightBus.plug(masterPanel.DimmerSwitch.In);
		masterPanel.instrumentLightBus.plug(mainBoard.dayNightRelais.P42);
		
		
		masterPanel.DimmerKeypad.Out.plug(mainBoard.dayNightRelais.P14);
		masterPanel.DimmerGlare.Out.plug(mainBoard.dayNightRelais.P24);
		masterPanel.DimmerInstrument.Out.plug(mainBoard.dayNightRelais.P34);
		masterPanel.DimmerSwitch.Out.plug(mainBoard.dayNightRelais.P44);
		masterPanel.DimmerAnnunciator.Out.plug(mainBoard.dayNightRelais.P54);
		
};

var plugLight = func(){
		lightBoard.Strobe.Plus.plug(sidePanel.LightStrobe.L12);
		lightBoard.Strobe.Minus.plug(mainBoard.GND);
		
		lightBoard.Navigation.Plus.plug(sidePanel.LightNavigation.L12);
		lightBoard.Navigation.Minus.plug(mainBoard.GND);
		
		lightBoard.Landing.Plus.plug(sidePanel.LightLanding.L12);
		lightBoard.Landing.Minus.plug(mainBoard.GND);
						
		lightBoard.Cabin.Plus.plug(sidePanel.LightCabin.L12);
		lightBoard.Cabin.Minus.plug(mainBoard.GND);
		
		lightBoard.Recognition.Plus.plug(sidePanel.LightRecognition.L12);
		lightBoard.Recognition.Minus.plug(mainBoard.GND);
		
		lightBoard.Map.Plus.plug(sidePanel.LightMap.L12);
		lightBoard.Map.Minus.plug(mainBoard.GND);
		
		lightBoard.Ice.Plus.plug(sidePanel.LightIce.L12);
		lightBoard.Ice.Minus.plug(mainBoard.GND);
				
		lightBoard.Keypad.Plus.plug(mainBoard.dayNightRelais.P11);
		lightBoard.Keypad.Minus.plug(mainBoard.GND);
		
		lightBoard.Glare.Plus.plug(mainBoard.dayNightRelais.P21);
		lightBoard.Glare.Minus.plug(mainBoard.GND);
		
		lightBoard.Instrument.Plus.plug(mainBoard.dayNightRelais.P31);
		lightBoard.Instrument.Minus.plug(mainBoard.GND);
		
		lightBoard.Switches.Plus.plug(mainBoard.dayNightRelais.P41);
		lightBoard.Switches.Minus.plug(mainBoard.GND);
		
		lightBoard.Annunciator.Plus.plug(mainBoard.dayNightRelais.P51);
		lightBoard.Annunciator.Minus.plug(mainBoard.GND);
		
};

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

var plugElectric = func(){
	plugMainBoard();
	plugCircuitBreaker();
	plugSidePanel();
	plugMasterPanel();
	plugLight();
	plugFuel();
};