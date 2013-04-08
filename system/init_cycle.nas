
var nCycleTimeUsed = props.globals.getNode("extra500/CycleTimeUsed",1);

extra500.oElectric.plugElectric();
extra500.oCircuitBreakerPanel.plugElectric();
extra500.oSidePanel.plugElectric();
extra500.oMasterPanel.plugElectric();
extra500.oLight.plugElectric();

extra500.oFuelSystem.plugElectric();



var simulation_cycle = func(){
	var start = systime();
	
	extra500.oElectric.update();
	extra500.oFuelSystem.update();
	
	foreach(var fuse;Part.aListElectricFuseAble){
		fuse.fuseReset();
		fuse.simUpdate();
	}
	foreach(var o;Part.aListSimStateAble){
		o.simReset();
	}
	var used = systime() - start;
	nCycleTimeUsed.setValue(used);
	var text = sprintf("Cycle time used : %.4f sec",used);
	IFD.demo.setSim(text);
};

var cycle_sec = 1.0;
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