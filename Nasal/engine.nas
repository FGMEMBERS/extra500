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
#      Date:             14.01.15
#
var IgnitionClass = {
	new : func(root,name,watt=45.0){
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
	init : func(instance=nil){
		if (instance==nil){instance=me;}
		me.parents[1].init(instance);
	},
	electricWork : func(){
		if (me._ignition == 1 and me._volt > me._voltMin){
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
	new : func(root,name,watt=24000.0){
		var m = { 
			parents : [
				StarterClass,
				ConsumerClass.new(root,name,watt)
			]
		};
		m._nGenerator     	= props.globals.initNode("/controls/electric/engine/generator",0,"BOOL");
		
		m._nStarter		= props.globals.initNode("/controls/engines/engine[0]/starter",0,"BOOL");
		m._nRPM			= props.globals.initNode("/engines/engine[0]/rpm",0,"INT");
		m._starterListener	= nil;
		m._starter		= 0;
		
		m._nRunning		= props.globals.initNode("/engines/engine[0]/running",0,"BOOL");
		m._runningListener	= nil;
		m._running		= 0;
		
		return m;
	},
	init : func(instance=nil){
		if (instance==nil){instance=me;}
		me.parents[1].init(instance);
		me.setListeners(instance);
	},
	setListeners : func(instance) {
		#me._starterListener 	= setlistener(me._nStarter,func(n){me._onStarterChange(n);},1,0);
		me._runningListener 	= setlistener(me._nRunning,func(n){instance._onRunningChange(n);},1,0);
	},
	_onRunningChange : func(n){
		me._running		= n.getValue();
		if (me._running == 1){
			me._starter = 0;
		}
		eSystem.source.Generator.setModeGenerator(me._running);
		me.electricWork();
	},
	_onStarterChange : func(n){
		me._starter		= n.getValue();
		me.electricWork();
	},
	electricWork : func(){
		# max rpm 425
		# rpm	A
		# 0	950
		# 425	750
		if ((me._starter == 1) and (me._volt > me._voltMin)){
			me._watt = me._nWatt.getValue();
			#me._ampere = me._watt / me._volt;
			# Anlaufstrom
			me._ampere = (-0.47 * me._nRPM.getValue()) + 950;
		}else{
			me._ampere = 0;
			me._starter = 0;
			
		}
		me._nGenerator.setValue(me._starter);
		me._nStarter.setValue(me._starter);
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
		m._nN1			= props.globals.initNode("/engines/engine[0]/n1");
		
		m.nCutOff		= props.globals.initNode("/controls/engines/engine[0]/cutoff",0,"BOOL");
		m.nReverser		= props.globals.initNode("/controls/engines/engine[0]/reverser",0,"BOOL");
		m.nThrottle		= props.globals.initNode("/controls/engines/engine[0]/throttle",0.0,"DOUBLE");
		
		m.nChip			= m._nRoot.initNode("defectChip",0,"BOOL"); 
		
		m.nCutOffState		= m._nRoot.initNode("cutoff",1,"BOOL");
		
		m._cutoffState = m.nCutOffState.getValue();
		
		m.ignition = IgnitionClass.new("/extra500/engine/ignition","Ignition",45.0);
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
			
			if(eSystem.switch.EngineStart._state >= 0){
				me.ignition.on();
			}elsif (eSystem.switch.EngineStart._state == -1){
				me.ignition.off();
			}
						
			if (eSystem.switch.EngineMotoring._state >= 0){
				me.ignition.off();
			}
			
		}else{
			if (eSystem.switch.EngineMotoring._state == 1){
				me.starter.on();
				me.nCutOff.setValue(1);
				me.ignition.off();
			}elsif(eSystem.switch.EngineMotoring._state == 0){
				me.starter.off();
				me.nCutOff.setValue(1);
				me.ignition.off();
			}else{
				if (eSystem.switch.EngineStart._state >= 0){
					me.ignition.on();
					if (getprop("/fdm/jsbsim/aircraft/engine/N1-par") < 15) {
						me.nCutOff.setValue(me._cutoffState);
					} else {
						me.nCutOff.setValue(1);
						if ( getprop("/fdm/jsbsim/aircraft/events/show-events") == 1 ) {
							UI.msg.info("If N1 is above 15%, no light-off will take place!");
						}
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
	init : func(instance=nil){
		if (instance==nil){instance=me;}
		me.parents[1].init(instance);
		
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
			if((me._state == 1) and (getprop("/extra500/panel/CircuitBreaker/BankB/OverSpeed/voltOut") > 10)){
				setprop("/fdm/jsbsim/propulsion/engine/constant-speed-mode",0);
				setprop("/fdm/jsbsim/propulsion/engine/blade-angle",5.0);
			} else {
				setprop("/fdm/jsbsim/propulsion/engine/constant-speed-mode",1);
			}
		};
		
		
		
		UI.register("Engine cutoff", 		func{extra500.engine.onCutoffClick(); } 	);
		UI.register("Engine cutoff on",		func{extra500.engine.onCutoffClick(1); } 	);
		UI.register("Engine cutoff off",	func{extra500.engine.onCutoffClick(0); } 	);
		
		UI.register("Engine reverser", 		func{extra500.engine.onReverserClick(); } 	);
		UI.register("Engine reverser on",	func{extra500.engine.onReverserClick(1); } 	);
		UI.register("Engine reverser off",	func{extra500.engine.onReverserClick(0); } 	);
		
		me.ignition.init();
		eSystem.circuitBreaker.IGN.outputAdd(me.ignition);
		
		me.starter.init();
		eSystem._PreBatteryBus.outputAdd(me.starter);
		
		me._checkIgnitionCutoff();
	},

};

var engine = EngineClass.new("/extra500/engine","RR 250-B17F2");
