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


var MainLoop = {
	new : func(nRoot,callback=nil,hz=10){
		var m = {parents:[
			MainLoop
		]};
		
		m.run 		= 1;
		m.targetHzSec 	= 1/hz;
		m.maxHzSec	= 0.04;
		m.nextSleepSec	= m.targetHzSec;
		m.timeStart	= systime();
		m.timeLast	= m.timeStart-0.1;
		m.timeUsed	= 0.0;
		m.timeDT	= 0.1;
		
		m._callback = callback;
		
		#members for statistic
		#m.time 		= 0.0;
		m.max 		= 0.0;
		m.min 		= 0.0;
		m.avg100 	= 0.0;
		m.sum100 	= 0.0;
		m.count100 	= 0.0;
		m.avg 		= 0.0;
		m.sum 		= 0.0;
		m.count 	= 0.0;
		m.realHz 	= 0.0;
		
		m.nTime 	= nRoot.initNode("time",0.0,"DOUBLE");
		m.nMax 		= nRoot.initNode("max",0.0,"DOUBLE");
		m.nMin 		= nRoot.initNode("min",0.0,"DOUBLE");
		m.nAvg100 	= nRoot.initNode("avg100",0.0,"DOUBLE");
		m.nAvg 		= nRoot.initNode("avg",0.0,"DOUBLE");
		m.nSum 		= nRoot.initNode("sum",0.0,"DOUBLE");
		m.nCount 	= nRoot.initNode("count",0.0,"DOUBLE");
		m.nRealHz	= nRoot.initNode("realHz",0.0,"DOUBLE");
		
		return m;
	},
	_loop : func(){
	
		
			me.timeStart = systime();
			me.timeDelta = me.timeStart - me.timeLast;
			
			me._callback(me.timeStart,me.timeDelta);
			
			me.timeUsed = systime() - me.timeStart;
		
			me.nextSleepSec = me.targetHzSec - me.timeUsed;
			if (me.nextSleepSec < me.maxHzSec){me.nextSleepSec = me.maxHzSec};
			
		if (me.run == 1){	
			settimer(func{me._loop();}, me.nextSleepSec);
		}	
		
			me.timeLast = me.timeStart;
			me._calcStats();
		
	},
	setHz : func(hz){
		me.targetHzSec 	= 1/hz;
	},
	start : func(){
		#print ("MainLoop.start() ... ");
		me.run = 1;
		me._loop();
	},
	stop : func() {
		#print ("MainLoop.stop() ... ");
		me.run = 0;
	},
	step : func() {
		#print ("MainLoop.step() ... ");
		me.run = 0;
		me._loop();
	},
	_calcStats : func(){
				
		me.realHz = 1 / (me.timeDelta) ; 
		
		if (me.max < me.timeUsed){ me.max = me.timeUsed; }
		if (me.min > me.timeUsed or me.min == 0.0){ me.min = me.timeUsed; }
				
		me.sum += me.timeUsed;
		me.count += 1;
		me.avg = me.sum / me.count;
		
		if (me.count100 == 100){
			me.avg100 = me.sum100 / me.count100;
			me.sum100 = 0;
			me.count100 = 0;
			
			me.max = 0.0;
			me.min = 0.0;
		}
		me.sum100 += me.timeUsed;
		me.count100 += 1;
			
			
		me.nTime.setValue(me.timeUsed);
		me.nMax.setValue(me.max);
		me.nMin.setValue(me.min);
		me.nAvg100.setValue(me.avg100);
		me.nAvg.setValue(me.avg);
		me.nSum.setValue(me.sum);
		me.nCount.setValue(me.count);
		me.nRealHz.setValue(me.realHz);
		
	}
	
};






extra500.plugElectric();


var simulationCall = func(now,dt){
	
	Part.etd.cls();
	#extra500.eBox.simulationUpdate(now,dt);
	extra500.externalPower.simulationUpdate(now,dt);
	extra500.generator.simulationUpdate(now,dt);
	extra500.alternator.simulationUpdate(now,dt);
	extra500.battery.simulationUpdate(now,dt);
	extra500.adjustAdditionalElectricLoads(now,dt);
	
	extra500.fuelSystem.simulationUpdate(now,dt);
	extra500.flapSystem.simulationUpdate(now,dt);
	extra500.gearSystem.simulationUpdate(now,dt);
	
	extra500.engine.simulationUpdate(now,dt);
	
	extra500.digitalInstrumentPackage.simulationUpdate(now,dt);
	extra500.engineInstrumentPackage.simulationUpdate(now,dt);
	extra500.audioPanel.simulationUpdate(now,dt);
	extra500.keypad.simulationUpdate(now,dt);
	extra500.autopilot.simulationUpdate(now,dt);
	extra500.dme.simulationUpdate(now,dt);
	extra500.fuelFlow.simulationUpdate(now,dt);
	extra500.turnCoordinator.simulationUpdate(now,dt);
	extra500.stbyAirspeed.simulationUpdate(now,dt);
	extra500.stbyAltimeter.simulationUpdate(now,dt);
	extra500.stbyAttitude.simulationUpdate(now,dt);
	
	extra500.pitotSystem.simulationUpdate(now,dt);
	
	
	
	IFD.demo.simulationUpdate(now,dt);
	IFD.RH.simulationUpdate(now,dt);
	
	
	foreach(var fuse;Part.aListElectricFuseAble){
		fuse.fuseReset();
		fuse.simUpdate();
	}
	foreach(var o;Part.aListSimStateAble){
		o.simReset();
	}
	
	
	
	
		
};


var animationCall = func(now,dt){
	
	
	extra500.engineInstrumentPackage.animationUpdate(now,dt);
	
	
}


#################################
#				#
# Loop for simulation		#
#	target 10Hz		#
#				#
#################################


var simulationLoop = MainLoop.new(props.globals.initNode("extra500/debug/Loop/simulation"),simulationCall,10);

#################################
#				#
# Loop for fast Animations	#
#	target 20Hz		#
#				#
#################################

#var animationLoop = MainLoop.new(props.globals.initNode("extra500/debug/Loop/animation"),animationCall,20);

var init_listener = setlistener("/sim/signals/fdm-initialized", func {
	
	removelistener(init_listener);
	init_listener = nil;
	
	settimer(func{ simulationLoop.start(); },2);
	#settimer(func{ animationLoop.start(); },2);
	
	print("simulation Cycle ... check");
	
	
});

# var debug_listener = setlistener("/extra500/panel/Annunciator/LowVoltage/state", func(n) {
# 	print("/extra500/panel/Annunciator/LowVoltage/state = " ~n.getValue());
# 
# },0,0);
