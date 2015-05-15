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
#      Last change:      Eric van den Berg
#      Date:             27.09.13
#

# MM Page 580


var FlapMotorClass = {
	new : func(root,name,watt=30.0){
		var m = { 
			parents : [
				FlapMotorClass,
				ConsumerClass.new(root,name,watt)
			]
		};
		m._value		= 0;
		m._target		= 0;
		m._nFlapCmdPosition    = props.globals.initNode("/fdm/jsbsim/fcs/flap-wp-cmd-norm",0.0,"DOUBLE");
					
		return m;
	},
	init : func(instance=nil){
		if (instance==nil){instance=me;}
		me.parents[1].init(instance);
	},
	electricWork : func(){
		
		if ((me._target != me._value) and (me._volt >= me._voltMin) ){
			#print ("FlapMotorClass.electricWork() ... on");
			me._watt = me._nWatt.getValue();
			me._ampere = me._watt / me._volt;
			me._state  = 1;
			me._nFlapCmdPosition.setValue(me._target);
		}else{
			#print ("FlapMotorClass.electricWork() ... off "~me._motoring~","~me._volt~"V");
			me._nFlapCmdPosition.setValue(me._value);
			me._state  = 0;
			me._ampere = 0;
		}
		me._nState.setValue(me._state);
		me._nAmpere.setValue(me._ampere);
	},
	drive : func(value,target){
		#print ("FlapMotorClass.drive("~value~","~direction~") ...");
		me._value = value;
		me._target = target;
		me.electricWork();
	}
	
};

var FlapSystemClass = {
	new : func(root,name){
		var m = {parents:[
			FlapSystemClass,
			ServiceClass.new(root,name)
		]};
		
		m._switchFlapPosition = {};
		m._switchFlapPosition[-1]= 1.0;
		m._switchFlapPosition[0]= 0.5;
		m._switchFlapPosition[1]= 0.0;
		
		m._flapPosition 	= 0;
		
		m._nWarning 		= m._nRoot.initNode("hasWarning",0,"BOOL");
		m._nFlaps 		= props.globals.getNode("/controls/flight/flaps");
		m._nFlapPosition      	= props.globals.initNode("/fdm/jsbsim/fcs/flap-pos-norm",0.0,"DOUBLE");
		m._nFlapCmdPosition   	 = props.globals.initNode("/fdm/jsbsim/fcs/flap-wp-cmd-norm",0.0,"DOUBLE");
# 		m.nFlapMotorPosition = props.globals.initNode("/fdm/jsbsim/fcs/flap-wp-motor-norm",0.0,"DOUBLE");
		
		m._switch 	= SwitchFactory.new("extra500/system/flap/Switch","Flap Switch",SwitchFactory.config("INT",-1,1,1,1,{"30":-1,"15":0,"0":1}));
		m._switch.onStateChange = func(n){
			me._state	= n.getValue();
			flapSystem.update();
		};
		m._motor 	= FlapMotorClass.new("extra500/system/flap/motor","Flap Motor",126.0);
		
		m._ledTrans = LedClass.new("/extra500/system/flap/leds","Flap Led Trans","extra500/system/dimming/Annunciator",0.6);
		m._led15 = LedClass.new("/extra500/system/flap/leds","Flap Led 15","extra500/system/dimming/Annunciator",0.6);
		m._led30 = LedClass.new("/extra500/system/flap/leds","Flap Led 30","extra500/system/dimming/Annunciator",0.6);
		
		m._nLEDTrans 		= props.globals.initNode("/extra500/light/FlapTransition/state",0.0,"DOUBLE");
		m._nLED15 		= props.globals.initNode("/extra500/light/Flap15/state",0.0,"DOUBLE");
		m._nLED30 		= props.globals.initNode("/extra500/light/Flap30/state",0.0,"DOUBLE");
		
		m._dt = 0;
		m._now = systime();
		m._lastTime = m._now;
		m._timerLoop = nil ;
	
		return m;
	},
	setListeners : func(instance) {
		append(me._listeners, setlistener(me._nFlapPosition,func(n){instance._onFlapChange(n);},1,0) );
		append(me._listeners, setlistener(extra500.dimmingSystem._nTest,func(n){instance._onDimTestChange(n);},1,0) );
	},
	init : func(instance=nil){
		if (instance==nil){instance=me;}
		me.parents[1].init(instance);
		me.setListeners(instance);
				
		me._switch.init();
		me._motor.init();
		
		me._ledTrans.shine = func(light){
			flapSystem._nLEDTrans.setValue(light);
		};
		me._ledTrans.init();
		
		me._led15.shine = func(light){
			flapSystem._nLED15.setValue(light);
		};
		me._led15.init();
		
		me._led30.shine = func(light){
			flapSystem._nLED30.setValue(light);
		};
		me._led30.init();
				
		eSystem.circuitBreaker.FLAP.outputAdd(me._motor);
		eSystem.circuitBreaker.WARN_LT.outputAdd(me._ledTrans);
		eSystem.circuitBreaker.WARN_LT.outputAdd(me._led15);
		eSystem.circuitBreaker.WARN_LT.outputAdd(me._led30);
		
		
		UI.register("Flaps down", 	func{me._switch.onAdjust(-1); } 	);
		UI.register("Flaps up",		func{me._switch.onAdjust(1); } 	);
		UI.register("Flaps 0", 		func{me._switch.onSet(1); } 	);
		UI.register("Flaps 15", 	func{me._switch.onSet(0); } 	);
		UI.register("Flaps 30", 	func{me._switch.onSet(-1); } );
				
		#me._timerLoop = maketimer(1.0,me,FlapSystemClass.update);
		#me._timerLoop.start();
		
	},
	_onDimTestChange : func(n){
		if (n.getValue() == 1){
			me._ledTrans.testOn();
			me._led15.testOn();
			me._led30.testOn();
		}else{
			me._ledTrans.testOff();
			me._led15.testOff();
			me._led30.testOff();
		}
	},
	_onFlapChange : func(n){
		me._flapPosition = n.getValue();
		me.update();
	},
	updateLeds : func(){
		#me._flapPosition = me._nFlapPosition.getValue();
		if(me._flapPosition >= 1.0){
			me._led30.on();
			me._ledTrans.off();
		}elsif(me._flapPosition > 0.50){
			me._ledTrans.on();
			me._led15.off();
			me._led30.off();
		}elsif(me._flapPosition >= 0.46666){
			me._ledTrans.off();
			me._led15.on();
		}elsif (me._flapPosition > 0){
			me._ledTrans.on();
			me._led15.off();
			me._led30.off();
		}elsif (me._flapPosition <= 0){
			me._ledTrans.off();
			
		}
	},
	update : func(){
		#me._flapPosition = me._nFlapPosition.getValue();
				
		me._motor.drive(me._flapPosition,me._switchFlapPosition[me._switch._state]);
				
		me.updateLeds();
		
	}
};

var flapSystem = FlapSystemClass.new("extra500/system/flap","Flap Control");
