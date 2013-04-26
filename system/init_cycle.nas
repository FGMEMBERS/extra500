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
#      Date: April 07 2013
#
#      Last change:      Dirk Dittmann
#      Date:             26.04.13
#

var nCycleTimeUsed = props.globals.getNode("extra500/CycleTimeUsed",1);
var cycleTimeUsed = 0;


extra500.plugElectric();


var simulation_cycle = func(){
	var start = systime();
	Part.etd.cls();
	#extra500.mainBoard.update(start);
	extra500.generator.update(start);
	extra500.battery.update(start);
	
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
	
	settimer(cycle,2);
	print("Simulation Cycle ... check");
	
	
});