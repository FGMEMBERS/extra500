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
#      Date: April 16 2013
#
#      Last change:      Eric van den Berg
#      Date:             11.05.13
#
 
var node = props.globals.getNode("/extra500/EngineerScreen",1);
var engineerScreen 	= Book.new(node,"Engineer Screen");

### Aerodynamic Screen ##############
var aerodynamicPage	= Page.new("Aerodynamic");
engineerScreen.add(aerodynamicPage);

### Engine Screen ##############
var enginePage		= Page.new("Engine");
engineerScreen.add(enginePage);

### Model Screen ##############
var modelPage		= Page.new("Model");
engineerScreen.add(modelPage);

### Fuel Screen ##############
var fuelPage		= Page.new("Fuel");
engineerScreen.add(fuelPage);



var display = nil;


### Electric Screen ##############
var electricPage	= Page.new("Electric");
engineerScreen.add(electricPage);
	

	# display = Display.new(10,-100);
	# 	display.title = "Generator Control Unit";
	# 	display.font = "FIXED_9x15";
	# 	display.fg = [1.0, 1.0, 1.0, 1.0];
	# 	display.bg = [0.5, 0.5, 0.5, 0.85];
	# 	display.width = 270;
	# 	display.height = 250;
	# 	
	# 	display.addNasal("generatorHasPower  %i", func()extra500.generatorControlUnit.generatorHasPower );
	# 	display.addNasal("controlGenerator   %i", func()extra500.generatorControlUnit.controlGenerator );
	# 	display.addNasal("controlStarter     %i", func()extra500.generatorControlUnit.controlStarter );
	# 	
	# electricPage.add(display);

	display = Display.new(10,-50);
		display.title = "Battery";
		display.font = "FIXED_9x15";
		display.fg = [1.0, 1.0, 1.0, 1.0];
		display.bg = [0.5, 0.5, 0.5, 0.85];
		display.width = 270;
		display.height = 150;
		
		display.addNamed("used    %.2f As", props.globals.getNode("/extra500/Battery/usedAs") );
		display.addNamed("level   %.2f %%", (props.globals.getNode("/extra500/Battery/loadLevel")) );
		display.addNamed("Volt    %.2f V", (props.globals.getNode("/extra500/Battery/electric/volt")) );
		
	electricPage.add(display);
	
	display = Display.new(10,-250);
		display.title = "Alternator";
		display.font = "FIXED_9x15";
		display.fg = [1.0, 1.0, 1.0, 1.0];
		display.bg = [0.5, 0.5, 0.5, 0.85];
		display.width = 270;
		display.height = 150;
		
		display.addNasal("out       %.2f V", func{extra500.alternator.electron.volt;} );
		display.addNasal("load      %.2f A", func{extra500.alternator.electron.ampere;} );
		display.addNasal("surplus   %.2f A", func{extra500.alternator.surplusAmpere;} );
		
	electricPage.add(display);

	display = Display.new(10,50);

		display.title = "Main Relais";
		display.font = "FIXED_9x15";
		display.fg = [1.0, 1.0, 1.0, 1.0];
		display.bg = [0.5, 0.5, 0.5, 0.85];
		display.width = 270;
		display.height = 400;
		
		display.add_Node("Battery      ", props.globals.getNode("/extra500/mainBoard/Relais/BatteryRelais/state") );
		display.add_Node("DayNight     ", props.globals.getNode("/extra500/mainBoard/Relais/DayNightRelais/state") );
		display.add_Node("TestLight    ", props.globals.getNode("/extra500/mainBoard/Relais/TestLightRelais/state") );
		display.add_Node("RCCB         ", props.globals.getNode("/extra500/mainBoard/Relais/RCCBRelais/state") );
		display.add_Node("Emergency    ", props.globals.getNode("/extra500/mainBoard/Relais/EmergencyRelais/state") );
		display.add_Node("Avionics     ", props.globals.getNode("/extra500/mainBoard/Relais/AvionicsRelais/state") );
		display.add_Node("Start        ", props.globals.getNode("/extra500/mainBoard/Relais/StartRelais/state") );
		display.add_Node("Generator    ", props.globals.getNode("/extra500/mainBoard/Relais/GeneratorRelais/state") );
		display.add_Node("External     ", props.globals.getNode("/extra500/mainBoard/Relais/ExternalPowerRelais/state") );
		display.add_Node("K8 RCCB GND  ", props.globals.getNode("/extra500/mainBoard/Relais/K8Relais/state") );
		display.add_Node("Alternator   ", props.globals.getNode("/extra500/mainBoard/Relais/AlternatorRelais/state") );
		
	electricPage.add(display);


	# 
	# display = Display.new(10,-200);
	# 	display.font = "FIXED_9x15";
	# 	display.fg = [1.0, 1.0, 1.0, 1.0];
	# 	display.bg = [0.5, 0.5, 0.5, 0.85];
	# 	display.width = 250;
	# 	display.height = 600;
		
	electricPage.add(display);

#---------------------------------

### Lights Screen ##############
var electricLightPage	= Page.new("Electric Lights");
engineerScreen.add(electricLightPage);

	display = Display.new(10,-50);
		display.title = "Lights Outside";
		display.font = "FIXED_9x15";
		display.fg = [1.0, 1.0, 1.0, 1.0];
		display.bg = [0.5, 0.5, 0.5, 0.85];
		display.width = 250;
		display.height = 170;
			
		display.addNamed("Strobe         %.2f %%", props.globals.getNode("/extra500/Light/Strobe/state") );
		display.addNamed("Navigation     %.2f %%", props.globals.getNode("/extra500/Light/Navigation/state") );
		display.addNamed("Landing        %.2f %%", props.globals.getNode("/extra500/Light/Landing/state") );
		display.addNamed("Recognition    %.2f %%", props.globals.getNode("/extra500/Light/Recognition/state") );
		display.addNamed("Ice            %.2f %%", props.globals.getNode("/extra500/Light/Ice/state") );
		
	electricLightPage.add(display);
		
	display = Display.new(10,-300);
		display.title = "Lights Inside";
		display.font = "FIXED_9x15";
		display.fg = [1.0, 1.0, 1.0, 1.0];
		display.bg = [0.5, 0.5, 0.5, 0.85];
		display.width = 250;
		display.height = 490;
		
		
		display.addNamed("Cabin              %.2f %%", props.globals.getNode("/extra500/Light/Cabin/state") );
		display.addNamed("Map                %.2f %%", props.globals.getNode("/extra500/Light/Map/state") );
		#display.addNamed("Instrument     %.2f %%", props.globals.getNode("/extra500/Light/Instrument/state") );
		#display.addNamed("Keypad         %.2f %%", props.globals.getNode("/extra500/Light/Keypad/state") );
		#display.addNamed("Switches       %.2f %%", props.globals.getNode("/extra500/Light/Switches/state") );

		display.addNamed("Airpath            %.2f %%", props.globals.getNode("/extra500/Light/Instrument/state") );
		display.addNamed("Glare              %.2f %%", props.globals.getNode("/extra500/Light/Glare/state") );
		display.addNamed("Autopilot          %.2f %%", props.globals.getNode("/extra500/Light/Instrument/state") );
		display.addNamed("IFDs               %.2f %%", props.globals.getNode("/extra500/Light/Instrument/state") );
		display.addNamed("Airspeed           %.2f %%", props.globals.getNode("/extra500/Light/Instrument/state") );
		display.addNamed("Altimeter          %.2f %%", props.globals.getNode("/extra500/Light/Instrument/state") );
		display.addNamed("Engines            %.2f %%", props.globals.getNode("/extra500/Light/Instrument/state") );
		display.addNamed("Altitute Gyro      %.2f %%", props.globals.getNode("/extra500/Light/Instrument/state") );
		display.addNamed("Propeller Heat     %.2f %%", props.globals.getNode("/extra500/Light/Instrument/state") );
		display.addNamed("Cabin Press Ctrl   %.2f %%", props.globals.getNode("/extra500/Light/Instrument/state") );
		display.addNamed("Cabin Press        %.2f %%", props.globals.getNode("/extra500/Light/Instrument/state") );
		display.addNamed("Cabin Altitude     %.2f %%", props.globals.getNode("/extra500/Light/Instrument/state") );
		display.addNamed("Fuels              %.2f %%", props.globals.getNode("/extra500/Light/Instrument/state") );
		display.addNamed("Turn Coordinator   %.2f %%", props.globals.getNode("/extra500/Light/Instrument/state") );
		display.addNamed("Audio Marker       %.2f %%", props.globals.getNode("/extra500/Light/Instrument/state") );
		display.addNamed("Switches Lumi      %.2f %%", props.globals.getNode("/extra500/Light/Switches/state") );
		
		
	electricLightPage.add(display);

	display = Display.new(-600,-10);
		display.title = "Lights Relais";
		display.font = "FIXED_9x15";
		display.fg = [1.0, 1.0, 1.0, 1.0];
		display.bg = [0.5, 0.5, 0.5, 0.85];
		display.width = 270;
		display.height = 140;
		
		display.add_Node("Day/Night Relais       ", props.globals.getNode("/extra500/mainBoard/Relais/DayNightRelais/state") );
		display.add_Node("mainBoard Test Relais  ", props.globals.getNode("/extra500/mainBoard/Relais/TestLightRelais/state") );
		display.add_Node("Dim/Test Relais        ", props.globals.getNode("/extra500/AnnunciatorPanel/dimTestRelais/state") );
		display.add_Node("Ext Power Relais       ", props.globals.getNode("/extra500/AnnunciatorPanel/ExternalPowerRelais/state") );
		
	electricLightPage.add(display);	
		

	display = Display.new(-10,-10);
		display.title = "Lights Annuciator";
		display.font = "FIXED_9x15";
		display.fg = [1.0, 1.0, 1.0, 1.0];
		display.bg = [0.5, 0.5, 0.5, 0.85];
		display.width = 270;
		display.height = 880;
		
		
		display.addNamed("Generator Fail        %.2f %%", props.globals.getNode("/extra500/AnnunciatorPanel/GeneratorFail/state") );
		display.addNamed("AFT Door              %.2f %%", props.globals.getNode("/extra500/AnnunciatorPanel/AFTDoor/state") );
		display.addNamed("Stall Heat            %.2f %%", props.globals.getNode("/extra500/AnnunciatorPanel/StallHeat/state") );
		display.addNamed("Oil Press             %.2f %%", props.globals.getNode("/extra500/AnnunciatorPanel/OilPress/state") );
		display.addNamed("Chip Detection        %.2f %%", props.globals.getNode("/extra500/AnnunciatorPanel/ChipDetection/state") );
		display.addNamed("Hydraulic Pump        %.2f %%", props.globals.getNode("/extra500/AnnunciatorPanel/HydraulicPump/state") );
		display.addNamed("Gear Warn             %.2f %%", props.globals.getNode("/extra500/AnnunciatorPanel/GearWarn/state") );
		display.addNamed("Stall Warn            %.2f %%", props.globals.getNode("/extra500/AnnunciatorPanel/StallWarn/state") );
		display.addNamed("Windshield Heat Fail  %.2f %%", props.globals.getNode("/extra500/AnnunciatorPanel/WindshieldHeatFail/state") );
		display.addNamed("Fuel Press            %.2f %%", props.globals.getNode("/extra500/AnnunciatorPanel/FuelPress/state") );
		display.addNamed("Pitot Heat Left       %.2f %%", props.globals.getNode("/extra500/AnnunciatorPanel/PitotHeatLeft/state") );
		display.addNamed("Pitot Heat Right      %.2f %%", props.globals.getNode("/extra500/AnnunciatorPanel/PitotHeatRight/state") );
		display.addNamed("Flaps                 %.2f %%", props.globals.getNode("/extra500/AnnunciatorPanel/Flaps/state") );
		display.addNamed("Cabin Pressure        %.2f %%", props.globals.getNode("/extra500/AnnunciatorPanel/CabinPressure/state") );
		display.addNamed("Bleed Overtemp        %.2f %%", props.globals.getNode("/extra500/AnnunciatorPanel/BleedOvertemp/state") );
		display.addNamed("Static Heat Left      %.2f %%", props.globals.getNode("/extra500/AnnunciatorPanel/StaticHeatLeft/state") );
		display.addNamed("Static Heat Right     %.2f %%", props.globals.getNode("/extra500/AnnunciatorPanel/StaticHeatRight/state") );
		display.addNamed("Fuel Trans Left       %.2f %%", props.globals.getNode("/extra500/AnnunciatorPanel/FuelTransLeft/state") );
		display.addNamed("Fuel Trans Right      %.2f %%", props.globals.getNode("/extra500/AnnunciatorPanel/FuelTransRight/state") );
		display.addNamed("StandBy Altern On     %.2f %%", props.globals.getNode("/extra500/AnnunciatorPanel/StandByAlternOn/state") );
		display.addNamed("Ignition Active       %.2f %%", props.globals.getNode("/extra500/AnnunciatorPanel/IgnitionActive/state") );
		display.addNamed("Intake Heat           %.2f %%", props.globals.getNode("/extra500/AnnunciatorPanel/IntakeHeat/state") );
		display.addNamed("Recogn Light          %.2f %%", props.globals.getNode("/extra500/AnnunciatorPanel/RecognLight/state") );
		display.addNamed("Fuel Filter ByPass    %.2f %%", props.globals.getNode("/extra500/AnnunciatorPanel/FuelFilterByPass/state") );
		display.addNamed("Pneumatic Low         %.2f %%", props.globals.getNode("/extra500/AnnunciatorPanel/PneumaticLow/state") );
		display.addNamed("Low Voltage           %.2f %%", props.globals.getNode("/extra500/AnnunciatorPanel/LowVoltage/state") );
		display.addNamed("Deice Boots           %.2f %%", props.globals.getNode("/extra500/AnnunciatorPanel/DeiceBoots/state") );
		display.addNamed("Landing Light         %.2f %%", props.globals.getNode("/extra500/AnnunciatorPanel/LandingLight/state") );
		display.addNamed("Fuel Low Left         %.2f %%", props.globals.getNode("/extra500/AnnunciatorPanel/FuelLowLeft/state") );
		display.addNamed("Fuel Low Right        %.2f %%", props.globals.getNode("/extra500/AnnunciatorPanel/FuelLowRight/state") );
		display.addNamed("Propeller Low Pitch   %.2f %%", props.globals.getNode("/extra500/AnnunciatorPanel/PropellerLowPitch/state") );
		display.addNamed("External Power        %.2f %%", props.globals.getNode("/extra500/AnnunciatorPanel/ExternalPower/state") );
		display.addNamed("Windshield Heat On    %.2f %%", props.globals.getNode("/extra500/AnnunciatorPanel/WindshieldHeatOn/state") );
		
		
	electricLightPage.add(display);

	display = Display.new(-320,-10);
		display.title = "Lights Indication";
		display.font = "FIXED_9x15";
		display.fg = [1.0, 1.0, 1.0, 1.0];
		display.bg = [0.5, 0.5, 0.5, 0.85];
		display.width = 270;
		display.height = 220;
		
		display.addNamed("Flap Transition  %.2f %%", props.globals.getNode("/extra500/Light/FlapTransition/state") );
		display.addNamed("Flap 15          %.2f %%", props.globals.getNode("/extra500/Light/Flap15/state") );
		display.addNamed("Flap 30          %.2f %%", props.globals.getNode("/extra500/Light/Flap30/state") );
		display.addNamed("Gear Nose        %.2f %%", props.globals.getNode("/extra500/Light/GearNose/state") );
		display.addNamed("Gear Right       %.2f %%", props.globals.getNode("/extra500/Light/GearRight/state") );
		display.addNamed("Gear Left        %.2f %%", props.globals.getNode("/extra500/Light/GearLeft/state") );
		display.addNamed("DME-Hold         %.2f %%", props.globals.getNode("/extra500/Light/DMEHold/state") );
		
	electricLightPage.add(display);	


#---------------------------------

### Flaps Screen ##############
	var flapsPage		= Page.new("Flaps");
	engineerScreen.add(flapsPage);
	
	display = Display.new(10,700);
		display.title = "Motor output";
		display.font = "FIXED_9x15";
		display.fg = [1.0, 1.0, 1.0, 1.0];
		display.bg = [0.5, 0.5, 0.5, 0.85];
		display.width = 270;
		display.height = 200;
		
		display.addNamed("Motor norm   %.2f %%", props.globals.getNode("/extra500/system/flap/Motor/state") );
		display.addNamed("flaps pos    %.2f %%", (props.globals.getNode("/fdm/jsbsim/fcs/flap-pos-norm")) );
		display.addNamed("flaps cmd    %.2f %%", (props.globals.getNode("/fdm/jsbsim/fcs/flap-wp-cmd-norm")) );
		display.addNamed("flaps motor  %.2f %%", (props.globals.getNode("/fdm/jsbsim/fcs/flap-wp-motor-norm")) );
		
	flapsPage.add(display);

	display = Display.new(10,100);

		display.title = "Relais";
		display.font = "FIXED_9x15";
		display.fg = [1.0, 1.0, 1.0, 1.0];
		display.bg = [0.5, 0.5, 0.5, 0.85];
		display.width = 270;
		display.height = 240;
		
		display.add_Node("Down        ", props.globals.getNode("/extra500/system/flap/RelaisDown/state") );
		display.add_Node("Up          ", props.globals.getNode("/extra500/system/flap/RelaisUp/state") );
		display.add_Node("Pos14       ", props.globals.getNode("/extra500/system/flap/RelaisPos14/state") );
		display.add_Node("Pos15       ", props.globals.getNode("/extra500/system/flap/RelaisPos15/state") );
		display.add_Node("Transition  ", props.globals.getNode("/extra500/system/flap/RelaisTransition/state") );
		
	flapsPage.add(display);
	
	display = Display.new(10,400);

		display.title = "Switches";
		display.font = "FIXED_9x15";
		display.fg = [1.0, 1.0, 1.0, 1.0];
		display.bg = [0.5, 0.5, 0.5, 0.85];
		display.width = 270;
		display.height = 240;
		
		display.add_Node("Main        ", props.globals.getNode("/extra500/system/flap/Switch/state") );
		display.add_Node("Limit Up    ", props.globals.getNode("/extra500/system/flap/SwitchLimitUp/state") );
		display.add_Node("Limit 14    ", props.globals.getNode("/extra500/system/flap/SwitchLimit14/state") );
		display.add_Node("Limit 15    ", props.globals.getNode("/extra500/system/flap/SwitchLimit15/state") );
		display.add_Node("Limit Down  ", props.globals.getNode("/extra500/system/flap/SwitchLimitDown/state") );
		
	flapsPage.add(display);
	

#---------------------------------

### Flaps Screen ##############
	var gearPage		= Page.new("Gear");
	engineerScreen.add(gearPage);
	
	display = Display.new(10,-50);

		display.title = "Limit switches";
		display.font = "FIXED_9x15";
		display.fg = [1.0, 1.0, 1.0, 1.0];
		display.bg = [0.5, 0.5, 0.5, 0.85];
		display.width = 270;
		display.height = 60;
		
		display.add_Node("Main Switch ", props.globals.getNode("/extra500/system/gear/MainGearSwitch/state") );
		
	gearPage.add(display);
	display = Display.new(10,100);

		display.title = "Limit switches";
		display.font = "FIXED_9x15";
		display.fg = [1.0, 1.0, 1.0, 1.0];
		display.bg = [0.5, 0.5, 0.5, 0.85];
		display.width = 270;
		display.height = 240;
		
		display.add_Node("Nose  Up    ", props.globals.getNode("/extra500/system/gear/NoseGearUp/state") );
		display.add_Node("Right Up    ", props.globals.getNode("/extra500/system/gear/RightGearUp/state") );
		display.add_Node("Left  Up    ", props.globals.getNode("/extra500/system/gear/LeftGearUp/state") );
		display.add_Node("Nose  Squat ", props.globals.getNode("/extra500/system/gear/NoseGearSquat/state") );
		display.add_Node("Nose  Down  ", props.globals.getNode("/extra500/system/gear/NoseGearDown/state") );
		display.add_Node("Right Down  ", props.globals.getNode("/extra500/system/gear/RightGearDown/state") );
		display.add_Node("Left  Down  ", props.globals.getNode("/extra500/system/gear/LeftGearDown/state") );
		
	gearPage.add(display);
	
	display = Display.new(10,500);

		display.title = "Door switches";
		display.font = "FIXED_9x15";
		display.fg = [1.0, 1.0, 1.0, 1.0];
		display.bg = [0.5, 0.5, 0.5, 0.85];
		display.width = 270;
		display.height = 160;
		
		display.add_Node("Right Upper ", props.globals.getNode("/extra500/system/gear/RightDoorUpper/state") );
		display.add_Node("Left  Upper ", props.globals.getNode("/extra500/system/gear/LeftDoorUpper/state") );
		display.add_Node("Lower       ", props.globals.getNode("/extra500/system/gear/LowerDoor/state") );

	gearPage.add(display);
	
	

#---------------------------------

### Engine and Performance Screen ##############

	display = Display.new(10,400);

		display.title = "Performance";
		display.font = "FIXED_9x15";
		display.fg = [1.0, 1.0, 1.0, 1.0];
		display.bg = [0.5, 0.5, 0.5, 0.85];
		display.width = 270;
		display.height = 240;
		
	display.add_Node("OAT   degC", props.globals.getNode("/environment/temperature-degc") );
	display.add_Node("Weight lbm", props.globals.getNode("/fdm/jsbsim/inertia/weight-lbs") );
	display.add_Node("TAS  knots", props.globals.getNode("/fdm/jsbsim/velocities/vtrue-kts") );
		
	enginePage.add(display);

display = Display.new(10,100);

	display.title = "Engine indication";
	display.font = "FIXED_9x15";
	display.fg = [1.0, 1.0, 1.0, 1.0];
	display.bg = [0.5, 0.5, 0.5, 0.85];
	display.width = 270;
	display.height = 270;
	
	display.add_Node("TRQ %    ", props.globals.getNode("/fdm/jsbsim/aircraft/engine/TRQ-perc") );
	display.add_Node("TOT degC ", props.globals.getNode("/fdm/jsbsim/aircraft/engine/TOT-target-degC") );
	display.add_Node("N1  %    ", props.globals.getNode("/fdm/jsbsim/propulsion/engine/n1") );
	display.add_Node("N2  RPM  ", props.globals.getNode("/fdm/jsbsim/propulsion/engine/propeller-rpm") );
	display.add_Node("OP  psi  ", props.globals.getNode("/fdm/jsbsim/aircraft/engine/OP-psi") );
	display.add_Node("OT  degC ", props.globals.getNode("/fdm/jsbsim/aircraft/engine/OT-degC") );
	display.add_Node("FT  degC ", props.globals.getNode("/fdm/jsbsim/aircraft/engine/FT-degC") );
	display.add_Node("FP  psi  ", props.globals.getNode("/fdm/jsbsim/aircraft/engine/FP-psi") );

	
enginePage.add(display);

#---------------------------------

### Aerodynamic screen ##############

display = Display.new(10,400);

		display.title = "Aerodynamic";
		display.font = "FIXED_9x15";
		display.fg = [1.0, 1.0, 1.0, 1.0];
		display.bg = [0.5, 0.5, 0.5, 0.85];
		display.width = 270;
		display.height = 240;
		
	display.add_Node("Total moment lbsft", props.globals.getNode("/fdm/jsbsim/aircraft/hstab/elevator/H-total-lbsft") );
	display.add_Node("Trim moment  lbsft", props.globals.getNode("/fdm/jsbsim/aircraft/hstab/elevator/H-trim-lbsft") );
#	display.add_Node("Trim tab coeff    ", props.globals.getNode("/fdm/jsbsim/aircraft/hstab/elevator/trim/coeff-norm") );
		
aerodynamicPage.add(display);

#---------------------------------
