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
#      Date: April 16 2013
#
#      Last change:      Dirk Dittmann
#      Date:             26.04.13
#
 
var node = props.globals.getNode("/extra500/EngineerScreen",1);
var engineerScreen 	= Book.new(node,"Engineer Screen");


var aerodynamicPage	= Page.new("Aerodynamic");
var enginePage		= Page.new("Engine");
var modelPage		= Page.new("Model");
var electricPage	= Page.new("Electric");
var electricLightPage	= Page.new("Electric Lights");
var fuelPage		= Page.new("Fuel");

engineerScreen.add(aerodynamicPage);
engineerScreen.add(enginePage);
engineerScreen.add(modelPage);
engineerScreen.add(electricPage);
engineerScreen.add(electricLightPage);
engineerScreen.add(fuelPage);




### Electric Screen ##############
var display = nil;

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

display = Display.new(10,350);
	display.title = "Battery";
	display.font = "FIXED_9x15";
	display.fg = [1.0, 1.0, 1.0, 1.0];
	display.bg = [0.5, 0.5, 0.5, 0.85];
	display.width = 270;
	display.height = 90;
	
	display.addNamed("used    %.2f As", props.globals.getNode("/extra500/Battery/usedAs") );
	display.addNamed("level   %.2f %%", (props.globals.getNode("/extra500/Battery/loadLevel")) );
	
electricPage.add(display);

display = Display.new(10,100);

	display.title = "Main Relais";
	display.font = "FIXED_9x15";
	display.fg = [1.0, 1.0, 1.0, 1.0];
	display.bg = [0.5, 0.5, 0.5, 0.85];
	display.width = 270;
	display.height = 240;
	
	display.add_Node("Battery      ", props.globals.getNode("/extra500/mainBoard/Relais/BatteryRelais/state") );
	display.add_Node("DayNight     ", props.globals.getNode("/extra500/mainBoard/Relais/DayNightRelais/state") );
	display.add_Node("TestLight    ", props.globals.getNode("/extra500/mainBoard/Relais/TestLightRelais/state") );
	display.add_Node("RCCB         ", props.globals.getNode("/extra500/mainBoard/Relais/RCCBRelais/state") );
	display.add_Node("Emergency    ", props.globals.getNode("/extra500/mainBoard/Relais/EmergencyRelais/state") );
	display.add_Node("Avionics     ", props.globals.getNode("/extra500/mainBoard/Relais/AvionicsRelais/state") );
	display.add_Node("Start        ", props.globals.getNode("/extra500/mainBoard/Relais/StartRelais/state") );
	display.add_Node("Generator    ", props.globals.getNode("/extra500/mainBoard/Relais/GeneratorRelais/state") );
	
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

display = Display.new(-10,-50);
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
	

display = Display.new(-10,-200);
	display.title = "Lights Annuciator";
	display.font = "FIXED_9x15";
	display.fg = [1.0, 1.0, 1.0, 1.0];
	display.bg = [0.5, 0.5, 0.5, 0.85];
	display.width = 270;
	display.height = 840;
	
	
	display.addNamed("Generator Fail        %.2f %%", props.globals.getNode("/extra500/AnnunciatorPanel/GeneratorFail/state") );
	display.addNamed("AFT Door              %.2f %%", props.globals.getNode("/extra500/AnnunciatorPanel/AFTDoor/state") );
	display.addNamed("Stall Heat            %.2f %%", props.globals.getNode("/extra500/AnnunciatorPanel/StallHeat/state") );
	display.addNamed("Oil Press             %.2f %%", props.globals.getNode("/extra500/AnnunciatorPanel/OilPress/state") );
	display.addNamed("Chip Detection        %.2f %%", props.globals.getNode("/extra500/AnnunciatorPanel/HydraulicPump/state") );
	display.addNamed("Hydraulic Pump        %.2f %%", props.globals.getNode("/extra500/AnnunciatorPanel/GearWarn/state") );
	display.addNamed("Gear Warn             %.2f %%", props.globals.getNode("/extra500/AnnunciatorPanel/GeneratorFail/state") );
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
	display.addNamed("Deice Boots           %.2f %%", props.globals.getNode("/extra500/AnnunciatorPanel/DeiceBoots/state") );
	display.addNamed("Landing Light         %.2f %%", props.globals.getNode("/extra500/AnnunciatorPanel/LandingLight/state") );
	display.addNamed("Fuel Low Left         %.2f %%", props.globals.getNode("/extra500/AnnunciatorPanel/FuelLowLeft/state") );
	display.addNamed("Fuel Low Right        %.2f %%", props.globals.getNode("/extra500/AnnunciatorPanel/FuelLowRight/state") );
	display.addNamed("Propeller Low Pitch   %.2f %%", props.globals.getNode("/extra500/AnnunciatorPanel/PropellerLowPitch/state") );
	display.addNamed("External Power        %.2f %%", props.globals.getNode("/extra500/AnnunciatorPanel/ExternalPower/state") );
	display.addNamed("Windshield Heat On    %.2f %%", props.globals.getNode("/extra500/AnnunciatorPanel/WindshieldHeatOn/state") );
	
	
electricLightPage.add(display);

display = Display.new(-320,-50);
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

### Fuel Screen ##############



#---------------------------------
