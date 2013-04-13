
var nCycleTimeUsed = props.globals.getNode("extra500/CycleTimeUsed",1);
var cycleTimeUsed = 0;


extra500.plugElectric();

extra500.oFuelSystem.plugElectric();



var simulation_cycle = func(){
	var start = systime();
	
	extra500.mainBoard.update(start);
	extra500.oFuelSystem.update();
	
	IFD.demo.update();
	
	foreach(var fuse;Part.aListElectricFuseAble){
		fuse.fuseReset();
		fuse.simUpdate();
	}
	foreach(var o;Part.aListSimStateAble){
		o.simReset();
	}
	cycleTimeUsed = systime() - start;
	nCycleTimeUsed.setValue(cycleTimeUsed);
	
	
};

var cycle_sec = 0.1;
var cycle_run = 1;
var cycle = func(){
	#debug.benchmark("Simulation Cycle ... ",func simulation_cycle());
	if (cycle_run == 1){
		simulation_cycle();
	}
	settimer(cycle, cycle_sec);
}

var init_listener = setlistener("/sim/signals/fdm-initialized", func {
	
	removelistener(init_listener);
	init_listener = nil;
	
	settimer(cycle,6);
	print("Simulation Cycle ... check");
	
	
});