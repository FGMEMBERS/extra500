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
#      Date: April 07 2013
#
#      Last change:      Dirk Dittmann
#      Date:             08.05.13
#


var Stats = {
	new : func(){
		var m = {parents:[
			Stats
		]};
		
		m.nTime = props.globals.initNode("extra500/debug/mainLoop/time",0.0,"DOUBLE");
		m.nMax = props.globals.initNode("extra500/debug/mainLoop/max",0.0,"DOUBLE");
		m.nMin = props.globals.initNode("extra500/debug/mainLoop/min",0.0,"DOUBLE");
		m.nAvg100 = props.globals.initNode("extra500/debug/mainLoop/avg100",0.0,"DOUBLE");
		m.nAvg = props.globals.initNode("extra500/debug/mainLoop/avg",0.0,"DOUBLE");
		m.nSum = props.globals.initNode("extra500/debug/mainLoop/sum",0.0,"DOUBLE");
		m.nCount = props.globals.initNode("extra500/debug/mainLoop/count",0.0,"DOUBLE");
		
		m.time = 0.0;
		m.max = 0.0;
		m.min = 0.0;
		m.avg100 = 0.0;
		m.sum100 = 0.0;
		m.count100 = 0.0;
		m.avg = 0.0;
		m.sum = 0.0;
		m.count = 0.0;
		
		return m;
	},
	add : func(value){
		
		me.time = value;
		if (me.max < value){ me.max = value; }
		if (me.min > value or me.min == 0.0){ me.min = value; }
				
		me.sum += value;
		me.count += 1;
		me.avg = me.sum / me.count;
		
		if (me.count100 == 100){
			me.avg100 = me.sum100 / me.count100;
			me.sum100 = 0;
			me.count100 = 0;
			
			me.max = 0.0;
			me.min = 0.0;
		}
		me.sum100 += value;
		me.count100 += 1;
			
			
		me.nTime.setValue(me.time);
		me.nMax.setValue(me.max);
		me.nMin.setValue(me.min);
		me.nAvg100.setValue(me.avg100);
		me.nAvg.setValue(me.avg);
		me.nSum.setValue(me.sum);
		me.nCount.setValue(me.count);
		
	}
	
};


var cycleTimeUsed = 0;


extra500.plugElectric();


var simulation_cycle = func(){
	var start = systime();
	Part.etd.cls();
	#extra500.mainBoard.update(start);
	extra500.externalPower.update(start);
	extra500.generator.update(start);
	extra500.alternator.update(start);
	extra500.battery.update(start);
	extra500.adjustAdditionalElectricLoads();
	
	extra500.oFuelSystem.update(start);
	extra500.flapSystem.update(start);
	extra500.gearSystem.update(start);
	
	extra500.engine.update(start);
	
	extra500.digitalInstrumentPackage.update(start);
	extra500.engineInstrumentPackage.update(start);
	extra500.audioPanel.update(start);
	extra500.keypad.update(start);
	extra500.autopilot.update(start);
	extra500.dme.update(start);
	extra500.fuelFlow.update(start);
	extra500.turnCoordinator.update(start);
	extra500.stbyAirspeed.update(start);
	extra500.stbyAltimeter.update(start);
	extra500.stbyAttitude.update(start);
	
	
	
	
	IFD.demo.update(start);
	IFD.RH.update(start);
	
	
	foreach(var fuse;Part.aListElectricFuseAble){
		fuse.fuseReset();
		fuse.simUpdate();
	}
	foreach(var o;Part.aListSimStateAble){
		o.simReset();
	}
	
	
	
	cycleTimeUsed = systime() - start;
		
};
var cycle_sec_full = 0.1;
var cycle_sec = 0.1;
var cycle_run = 1;

var cycleStats = Stats.new();

var cycle = func(){
	
	if (cycle_run == 1){
		simulation_cycle();
	}
	cycle_sec = cycle_sec_full - cycleTimeUsed;
	if (cycle_sec < 0.04){cycle_sec = 0.04};
	settimer(cycle, cycle_sec);
	
	cycleStats.add(cycleTimeUsed);
	
}




var init_listener = setlistener("/sim/signals/fdm-initialized", func {
	
	removelistener(init_listener);
	init_listener = nil;
	
	settimer(cycle,2);
	print("Simulation Cycle ... check");
	
	
});

# var debug_listener = setlistener("/extra500/AnnunciatorPanel/LowVoltage/state", func(n) {
# 	print("/extra500/AnnunciatorPanel/LowVoltage/state = " ~n.getValue());
# 
# },0,0);
