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






extra500.plugElectric();


var simulationCall = func(timestamp){
	
	Part.etd.cls();
	#extra500.mainBoard.update(timestamp);
	extra500.externalPower.update(timestamp);
	extra500.generator.update(timestamp);
	extra500.alternator.update(timestamp);
	extra500.battery.update(timestamp);
	extra500.adjustAdditionalElectricLoads();
	
	extra500.oFuelSystem.update(timestamp);
	extra500.flapSystem.update(timestamp);
	extra500.gearSystem.update(timestamp);
	
	extra500.engine.update(timestamp);
	
	extra500.digitalInstrumentPackage.update(timestamp);
	extra500.engineInstrumentPackage.update(timestamp);
	extra500.audioPanel.update(timestamp);
	extra500.keypad.update(timestamp);
	extra500.autopilot.update(timestamp);
	extra500.dme.update(timestamp);
	extra500.fuelFlow.update(timestamp);
	extra500.turnCoordinator.update(timestamp);
	extra500.stbyAirspeed.update(timestamp);
	extra500.stbyAltimeter.update(timestamp);
	extra500.stbyAttitude.update(timestamp);
	
	
	
	
	IFD.demo.update(timestamp);
	IFD.RH.update(timestamp);
	
	
	foreach(var fuse;Part.aListElectricFuseAble){
		fuse.fuseReset();
		fuse.simUpdate();
	}
	foreach(var o;Part.aListSimStateAble){
		o.simReset();
	}
	
	
	
	
		
};


var animationCall = func(timestamp){
	
	
	extra500.engineInstrumentPackage.animationUpdate(timestamp);
	
	
}




#################################
#				#
# Loop for simulation		#
#	target 10Hz		#
#				#
#################################


var simulationTargetHzSec = 0.1;
var simulationSec = 0.1;
var simulationRun = 1;
var simulationStats = Stats.new();
var simulationTimeStart = 0;
var simulationTimeUsed = 0;
var simulationLoop = func(){
	
	if (simulationRun == 1){
		simulationTimeStart = systime();
		simulationCall(simulationTimeStart);
		simulationTimeUsed = systime() - simulationTimeStart;
	}
	simulationSec = simulationTargetHzSec - simulationTimeUsed;
	if (simulationSec < 0.04){simulationSec = 0.04};
	settimer(simulationLoop, simulationSec);
	
	simulationStats.add(simulationTimeUsed);
	
}

#################################
#				#
# Loop for fast Animations	#
#	target 20Hz		#
#				#
#################################


var animationTargetHzSec = 0.05;
var animationSec = 0.05;
var animationRun = 1;
var animationStats = Stats.new();
var animationTimeStart = 0;
var animationTimeUsed = 0;
var animationLoop = func(){
	if (animationRun == 1){
		animationTimeStart = systime();
		animationCall(animationTimeStart);
		animationTimeUsed = systime() - animationTimeStart;
	}
	animationSec = animationTargetHzSec - animationTimeUsed;
	if (animationSec < 0.1){animationSec = 0.1};
	settimer(animationLoop, animationSec);
	
	animationStats.add(animationTimeUsed);
}




var init_listener = setlistener("/sim/signals/fdm-initialized", func {
	
	removelistener(init_listener);
	init_listener = nil;
	
	settimer(simulationLoop,2);
	#settimer(animationLoop,2);
	
	print("simulation Cycle ... check");
	
	
});

# var debug_listener = setlistener("/extra500/AnnunciatorPanel/LowVoltage/state", func(n) {
# 	print("/extra500/AnnunciatorPanel/LowVoltage/state = " ~n.getValue());
# 
# },0,0);
