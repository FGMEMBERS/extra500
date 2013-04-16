
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
display = Display.new(10,100);

	display.setfont("FIXED_9x15");
	display.setcolor(1, 1, 1);
	
	display.add(props.globals.getNode("/extra500/CycleTimeUsed"));
	display.add(props.globals.getNode("/extra500/EngineerScreen/index"));
	display.addNasal("cycleTimeUsed    %.4f sec", func()run.cycleTimeUsed );
	display.addNamed("cycleTimeUsed    %.4f sec", props.globals.getNode("/extra500/CycleTimeUsed") );

electricPage.add(display);

display = Display.new(-300,100);
	display.setfont("FIXED_9x15");
	display.setcolor(1, 1, 1);
	
	display.add(props.globals.getNode("/extra500/CycleTimeUsed"));
	display.add(props.globals.getNode("/extra500/EngineerScreen/index"));
	display.addNasal("cycleTimeUsed    %.4f sec", func()run.cycleTimeUsed );
	display.addNamed("cycleTimeUsed    %.4f sec", props.globals.getNode("/extra500/CycleTimeUsed") );
	
electricPage.add(display);

display = Display.new(-300,-100);
	display.setfont("FIXED_9x15");
	display.setcolor(1, 1, 1);
	
	display.add(props.globals.getNode("/extra500/CycleTimeUsed"));
	display.add(props.globals.getNode("/extra500/EngineerScreen/index"));
	display.addNasal("cycleTimeUsed    %.4f sec", func()run.cycleTimeUsed );
	display.addNamed("cycleTimeUsed    %.4f sec", props.globals.getNode("/extra500/CycleTimeUsed") );
	
electricPage.add(display);

#---------------------------------


