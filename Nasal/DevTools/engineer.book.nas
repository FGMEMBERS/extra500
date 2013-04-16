
var node = props.globals.getNode("/extra500/EngineerScreen",1);
var engineerScreen 	= Book.new(node,"Engineer Screen");


var aerodynamicPage	= Page.new("Aerodynamic");
var enginePage		= Page.new("Engine");
var modelPage		= Page.new("Model");
var electricPage	= Page.new("Electric");
var fuelPage		= Page.new("Fuel");

engineerScreen.add(aerodynamicPage);
engineerScreen.add(enginePage);
engineerScreen.add(modelPage);
engineerScreen.add(electricPage);
engineerScreen.add(fuelPage);




### Electric Screen ##############
var display = nil;
# display = Display.new(10,100);
# 
# 	display.setfont("FIXED_9x15");
# 	display.setcolor(1, 1, 1);
# 	
# 	display.add(props.globals.getNode("/extra500/EngineerScreen/index"));
# 	display.add(props.globals.getNode("/extra500/CycleTimeUsed"));
# 	display.addNamed("cycleTimeUsed    %.4f sec", props.globals.getNode("/extra500/CycleTimeUsed") );
# 	display.addNasal("cycleTimeUsed    %.4f sec", func()run.cycleTimeUsed );
# 
# electricPage.add(display);

# display = Display.new(-300,100);
# 	display.setfont("FIXED_9x15");
# 	display.setcolor(1, 1, 1);
# 	
# 	display.add(props.globals.getNode("/extra500/CycleTimeUsed"));
# 	display.add(props.globals.getNode("/extra500/EngineerScreen/index"));
# 	display.addNasal("cycleTimeUsed    %.4f sec", func()run.cycleTimeUsed );
# 	display.addNamed("cycleTimeUsed    %.4f sec", props.globals.getNode("/extra500/CycleTimeUsed") );
# 	
# electricPage.add(display);

display = Display.new(10,-200);
	display.setfont("FIXED_9x15");
	display.setcolor(1, 1, 1);
	display.bg = [0.5, 0.5, 0.5, 0.85];
	display.width = 250;
	display.height = 600;
	
	
	display.addNamed("Strobe         %.2f %%", props.globals.getNode("/extra500/Light/Strobe/state") );
	display.addNamed("Navigation     %.2f %%", props.globals.getNode("/extra500/Light/Navigation/state") );
	display.addNamed("Landing        %.2f %%", props.globals.getNode("/extra500/Light/Landing/state") );
	display.addNamed("Recognition    %.2f %%", props.globals.getNode("/extra500/Light/Recognition/state") );
	display.addNamed("Cabin          %.2f %%", props.globals.getNode("/extra500/Light/Cabin/state") );
	display.addNamed("Map            %.2f %%", props.globals.getNode("/extra500/Light/Map/state") );
	display.addNamed("Instrument     %.2f %%", props.globals.getNode("/extra500/Light/Instrument/state") );
	display.addNamed("Glare          %.2f %%", props.globals.getNode("/extra500/Light/Glare/state") );
	display.addNamed("Ice            %.2f %%", props.globals.getNode("/extra500/Light/Ice/state") );
	display.addNamed("Keypad         %.2f %%", props.globals.getNode("/extra500/Light/Keypad/state") );
	display.addNamed("Switches       %.2f %%", props.globals.getNode("/extra500/Light/Switches/state") );
	display.addNamed("Annunciator    %.2f %%", props.globals.getNode("/extra500/Light/Annunciator/state") );
# 	display.addNamed("    %.2f %%", props.globals.getNode("/extra500/Light//state") );
# 	display.addNamed("    %.2f %%", props.globals.getNode("/extra500/Light//state") );
# 	display.addNamed("    %.2f %%", props.globals.getNode("/extra500/Light//state") );
# 	display.addNamed("    %.2f %%", props.globals.getNode("/extra500/Light//state") );
	
electricPage.add(display);

#---------------------------------

### Fuel Screen ##############



#---------------------------------
