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
#      Date: Jun 26 2013
#
#      Last change:      Dirk Dittmann
#      Date:             26.06.13
#
var IgnitionClass = {
	new : func(root,name,watt=24000.0){
		var m = { 
			parents : [
				IgnitionClass,
				ConsumerClass.new(root,name,watt)
			]
		};
		m._nIgnition		= props.globals.initNode("/controls/engines/engine[0]/ignition",0,"BOOL");
		m._ignition		= 0;
		return m;
	},
	electricWork : func(){
		if (me._ignition == 1 and me._volt > 22.0){
			me._watt = me._nWatt.getValue();
			me._ampere = me._watt / me._volt;
			me._nIgnition.setValue(1);
		}else{
			me._ampere = 0;
			me._nIgnition.setValue(0);
		}
		me._nAmpere.setValue(me._ampere);
	},
	on : func(){
		me._ignition = 1;
		me.electricWork();
	},
	off : func(){
		me._ignition = 0;
		me.electricWork();
	}
	
};

var StarterClass = {
	new : func(root,name,watt=30.0){
		var m = { 
			parents : [
				StarterClass,
				ConsumerClass.new(root,name,watt)
			]
		};
		m._nGenerator     	= props.globals.initNode("/controls/electric/engine/generator",0,"BOOL");
		
		m._nStarter		= props.globals.initNode("/controls/engines/engine[0]/starter",0,"BOOL");
		m._starterListener	= nil;
		m._starter		= 0;
		
		m._nRunning		= props.globals.initNode("/engines/engine[0]/running",0,"BOOL");
		m._runningListener	= nil;
		m._running		= 0;
		
		return m;
	},
	setListerners : func() {
		me._voltListener 	= setlistener(me._nVolt,func(n){me._onVoltChange(n);},1,0);
		me._ampereListener 	= setlistener(me._nAmpere,func(n){me._onAmpereChange(n);},1,0);
		#me._starterListener 	= setlistener(me._nStarter,func(n){me._onStarterChange(n);},1,0);
		me._runningListener 	= setlistener(me._nRunning,func(n){me._onRunningChange(n);},1,0);
	},
	_onRunningChange : func(n){
		me._running		= n.getValue();
		if (me._running == 1){
			me._starter 		= 0;
		}
		me.electricWork();
	},
	_onStarterChange : func(n){
		me._starter		= n.getValue();
		me.electricWork();
	},
	electricWork : func(){
		if ((me._starter == 1) and (me._volt > 22.0)){
			me._watt = me._nWatt.getValue();
			me._ampere = me._watt / me._volt;
			me._nGenerator.setValue(1);
			me._nStarter.setValue(1);
		}else{
			me._ampere = 0;
			me._starter = 0;
			me._nGenerator.setValue(0);
			me._nStarter.setValue(0);
		}
		me._nAmpere.setValue(me._ampere);
	},
	on : func(){
		me._starter = 1;
		me.electricWork();
	},
	off : func(){
		me._starter = 0;
		me.electricWork();
	}
	
};

var EngineClass = {
	new : func(root,name){
		var m = {parents:[
			EngineClass,
			ServiceClass.new(root,name)
		]};
		
		m.nIsRunning		= props.globals.initNode("/fdm/jsbsim/propulsion/engine/set-running",0,"BOOL");
		m.nTRQ			= props.globals.initNode("/fdm/jsbsim/aircraft/engine/TRQ-perc",0.0,"DOUBLE");
		m.nOilPress		= props.globals.initNode("/fdm/jsbsim/aircraft/engine/OP-psi",0.0,"DOUBLE");
		m.nFuelPress 		= props.globals.initNode("/fdm/jsbsim/aircraft/engine/FP-psi",0.0,"DOUBLE");
		
		m._nN1			= props.globals.initNode("/engines/engine[0]/n1");
		
		m.nCutOff		= props.globals.initNode("/controls/engines/engine[0]/cutoff",0,"BOOL");
		m.nReverser		= props.globals.initNode("/controls/engines/engine[0]/reverser",0,"BOOL");
		m.nThrottle		= props.globals.initNode("/controls/engines/engine[0]/throttle",0.0,"DOUBLE");
		
		m.nLowTorquePress	= m._nRoot.initNode("lowTorquePressure",0,"BOOL");
		m.nLowOilPress		= m._nRoot.initNode("lowOilPressure",0,"BOOL");
		m.nLowFuelPress		= m._nRoot.initNode("lowFuelPressure",0,"BOOL");
		m.nLowPitch		= m._nRoot.initNode("lowPitch",0,"BOOL");
		m.nChip			= m._nRoot.initNode("defectChip",0,"BOOL"); 
		
		m.nCutOffState		= m._nRoot.initNode("cutoff",1,"BOOL");
		
		m._cutoffState = m.nCutOffState.getValue();
		
		m.ignition = IgnitionClass.new("/extra500/engine/ignition","Ignition",30.0);
		m.starter  = StarterClass.new("/extra500/engine/starter","Starter",24000.0);
		
		
		
		m.dt = 0;
		m.now = systime();
		m._lastTime = 0;
		m._timerLoop = nil;
		
		return m;
	},
	_checkIgnitionCutoff : func(){
		if (me.nIsRunning.getValue()){
			me.nCutOff.setValue(me._cutoffState);
			
			if (eSystem.switch.EngineStart._state == -1){
				me.ignition.off();
			}
			
			if (eSystem.switch.EngineMotoring._state >= 0){
				me.ignition.off();
			}
			
		}else{
			
			if (eSystem.switch.EngineMotoring._state == 0){
				me.starter.off();
				me.nCutOff.setValue(1);
				me.ignition.off();
			}elsif(eSystem.switch.EngineMotoring._state == 1){
				me.starter.on();
			}else{
				if (eSystem.switch.EngineStart._state >= 0){
					me.ignition.on();
					if (me._cutoffState == 0){
						me.nCutOff.setValue(0);
					}else{
						me.nCutOff.setValue(1);
					}
					if (eSystem.switch.EngineStart._state == 1){
						me.starter.on();
					}
				}else{
					
					me.ignition.off();
					me.nCutOff.setValue(1);
					
				}
			}
		}
		
		

	},
	onCutoffClick : func(value = nil){
		if (value == nil){
			me._cutoffState = me._cutoffState == 0 ? 1 : 0 ;
		}else{
			me._cutoffState = value == 0 ? 0 : 1 ;
		}
		me.nCutOffState.setValue(me._cutoffState);
		me._checkIgnitionCutoff();
	},
	onReverserClick : func(value = nil){
		if (me.nThrottle.getValue() < 0.01) {
			if (value == nil){
				me.nReverser.setValue(!me.nReverser.getValue());
			}else{
				me.nReverser.setValue(value);
			}
		}
	},

	init : func(){
		
		eSystem.switch.EngineStart.onStateChange = func(n){
			me._state = n.getValue();
			#print("eSystem.switch.EngineStart.onStateChange("~me._state~") ...");
			engine._checkIgnitionCutoff();
			if(me._state == 1){
				settimer(func{UI.click("Engine Start ign")}, 0.2);
			}
					
		};
		eSystem.switch.EngineMotoring.onStateChange = func(n){
			me._state = n.getValue();
			engine._checkIgnitionCutoff();
		};
		eSystem.switch.EngineOverSpeed.onStateChange = func(n){
			me._state = n.getValue();
		};
		
		
		
		UI.register("Engine cutoff", 		func{extra500.engine.onCutoffClick(); } 	);
		UI.register("Engine cutoff on",		func{extra500.engine.onCutoffClick(1); } 	);
		UI.register("Engine cutoff off",	func{extra500.engine.onCutoffClick(0); } 	);
		
		UI.register("Engine reverser", 		func{extra500.engine.onReverserClick(); } 	);
		UI.register("Engine reverser on",	func{extra500.engine.onReverserClick(1); } 	);
		UI.register("Engine reverser off",	func{extra500.engine.onReverserClick(0); } 	);
		
		me.ignition.setListerners();
		eSystem.circuitBreaker.IGN.addOutput(me.ignition);
		
		me.starter.setListerners();
		eSystem.addOutput(me.starter);
		
		me._checkIgnitionCutoff();
		me._timerLoop = maketimer(1.0,me,EngineClass.update);
		me._timerLoop.start();
	},
	update : func(){
		if(me.nFuelPress.getValue() < 1.5){
			me.nLowFuelPress.setValue(1);
		}else{
			me.nLowFuelPress.setValue(0);
		}
		
		if (me.nThrottle.getValue() >= 0.05 and me.nReverser.getValue() == 1){
			me.nLowPitch.setValue(1);
		}else{
			me.nLowPitch.setValue(0);
		}
				
		if(me.nTRQ.getValue() < 35.0){
			me.nLowTorquePress.setValue(1);
		}else{
			me.nLowTorquePress.setValue(0);
		}
		
		if (me.nOilPress.getValue() < 35.0){
			me.nLowOilPress.setValue(1);
		}else{
			me.nLowOilPress.setValue(0);
		}
	}
};

var engine = EngineClass.new("/extra500/engine","RR 250-B17F2");