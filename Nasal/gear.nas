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
#      Date:             23.10.13
#

# MM GearWarning Page 597
# MM GearControl Page 596

#var HydraulicMotorClass = {
#	new : func(root,name,watt=30.0){
#		var m = { 
#			parents : [
#				HydraulicMotorClass,
#				ConsumerClass.new(root,name,watt)
#			]
#		};
#		m._motoring		= 0;
#		m._direction		= 0;
#		m._nMotor 		= m._nRoot.initNode("isMotoring",0,"BOOL");
#		m._nPositionNose 	= props.globals.initNode("/gear/gear[0]/position-norm");
#		m._nGearControl 	= props.globals.initNode("/controls/gear/gear-down");
		
				
#		return m;
#	},
#	init : func(instance=nil){
#		if (instance==nil){instance=me;}
#		me.parents[1].init(instance);
#	},
#	electricWork : func(){
		
#		if ((me._motoring == 1) and (me._volt >= me._voltMin) ){
			#print ("HydraulicMotorClass.electricWork() ... on");
#			me._watt = me._nWatt.getValue();
#			me._ampere = me._watt / me._volt;
#			me._motoring = 1;
#			me._nGearControl.setValue(me._direction);
#		}else{
			#print ("HydraulicMotorClass.electricWork() ... off "~me._motoring~","~me._volt~"V");
#			me._ampere = 0;
#			me._motoring = 0;
#		}
#		me._nMotor.setValue(me._motoring);
#		me._nAmpere.setValue(me._ampere);
#	},
#	drive : func(value,direction){
		#print ("HydraulicMotorClass.drive("~value~","~direction~") ...");
#		me._motoring = value;
#		me._direction = direction;
#		me.electricWork();
#	}
	
#};

var GearSystemClass = {
	new : func(root,name){
		var m = {parents:[
			GearSystemClass,
			ServiceClass.new(root,name)
		]};
#		m._nWarning 		= m._nRoot.initNode("hasWarning",0,"BOOL");
		
		m._nGearControl = props.globals.getNode("/controls/gear/gear-down",1);
		m._nWowNose = props.globals.getNode("/gear/gear[0]/wow",1);
		m._nPositionNose = props.globals.getNode("/gear/gear[0]/position-norm",1);
		m._nPositionLeft = props.globals.getNode("/gear/gear[1]/position-norm",1);
		m._nPositionRight = props.globals.getNode("/gear/gear[2]/position-norm",1);
#		m._nLeftGearMassLocationX = props.globals.getNode("/fdm/jsbsim/inertia/pointmass-location-X-inches[7]",1);
#		m._nLeftGearMassLocationZ = props.globals.getNode("/fdm/jsbsim/inertia/pointmass-location-Z-inches[7]",1);
#		m._nRightGearMassLocationX = props.globals.getNode("/fdm/jsbsim/inertia/pointmass-location-X-inches[8]",1);
#		m._nRightGearMassLocationZ = props.globals.getNode("/fdm/jsbsim/inertia/pointmass-location-Z-inches[8]",1);

		m._testListener = nil;
		m._gearListener = nil;
		m._gearPosition = 0;
	
		m._lednosegear = LedClass.new("/extra500/light/GearNose/state","Nose Gear Led","extra500/system/dimming/Annunciator",0.2);
		m._ledlmaingear = LedClass.new("/extra500/light/GearLeft/state","LMain Gear Led","extra500/system/dimming/Annunciator",0.2);
		m._ledrmaingear = LedClass.new("/extra500/light/GearRight/state","RMain Gear Led","extra500/system/dimming/Annunciator",0.2);
		
#		m._nLEDLeft 		= props.globals.initNode("/extra500/light/GearLeft/state",0.0,"DOUBLE");
#		m._nLEDNose 		= props.globals.initNode("/extra500/light/GearNose/state",0.0,"DOUBLE");
#		m._nLEDRight 		= props.globals.initNode("/extra500/light/GearRight/state",0.0,"DOUBLE");
		
#		m._ledListener		= nil;
		
#		m._hydaulicMotor = HydraulicMotorClass.new("/extra500/system/gear/motor","Gear Hydraulic Motor",1148.0);
		
		m._wowNose = 0;
		m._positionNose = 0.0;
		m._positionLeft = 0.0;
		m._positionRight = 0.0;
		
#		m._MassLeftLocationX = m._nLeftGearMassLocationX.getValue();
#		m._MassLeftLocationZ = m._nLeftGearMassLocationZ.getValue();
#		m._MassRightLocationX = m._nRightGearMassLocationX.getValue();
#		m._MassRightLocationZ = m._nRightGearMassLocationZ.getValue();
		
				
		
		m._swtGear = SwitchBoolClass.new("/extra500/system/gear/MainGearSwitch","Gear",1);
		m._swtGear.onStateChange = func(n){
			me._state	= n.getValue();
#			gearSystem.update();
		};
		m._dt = 0;
		m._now = systime();
		m._lastTime = m._now;
		m._timerLoop = nil;
	
		return m;
	},
	setListeners : func(instance) {
#		append(me._listeners, setlistener(me._nPositionNose,func(n){instance._onGearChange(n);},1,0) );
		append(me._listeners, setlistener(extra500.dimmingSystem._nTest,func(n){instance._onDimTestChange(n);},1,0) );
		append(me._listeners, setlistener("/systems/gear/switches/nosegeardown/state",func(n){me._updateNoseGearLight(n);},1,0) );
	},
	init : func(instance=nil){
		if (instance==nil){instance=me;}
		me.parents[1].init(instance);
		me.setListeners(instance);
		
		
		
		
#		me._leds.shine = func(light){
#			gearSystem._nLEDLeft.setValue(light);
#			gearSystem._nLEDNose.setValue(light);
#			gearSystem._nLEDRight.setValue(light);
#		};
		
		me._swtGear.init();
		me._lednosegear.init();
		me._ledlmaingear.init();
		me._ledrmaingear.init();
#		me._hydaulicMotor.init();
		
		eSystem.circuitBreaker.WARN_LT.outputAdd(me._lednosegear);
		eSystem.circuitBreaker.WARN_LT.outputAdd(me._ledlmaingear);
		eSystem.circuitBreaker.WARN_LT.outputAdd(me._ledrmaingear);
#		eSystem.circuitBreaker.HYDR.outputAdd(me._hydaulicMotor);
		
		UI.register("Gear up", 		func{me._swtGear.onClick(0); } 	);
		UI.register("Gear down",	func{me._swtGear.onClick(1); } 	);
		
		
#		me._timerLoop = maketimer(1.0,me,GearSystemClass.update);
#		me._timerLoop.start();
		
	},
	_onDimTestChange : func(n){
		if (n.getValue() == 1){
			me._lednosegear.testOn();
			me._ledlmaingear.testOn();
			me._ledrmaingear.testOn();
		}else{
			me._lednosegear.testOff();
			me._ledlmaingear.testOff();
			me._ledrmaingear.testOff();
		}
	},
#	_onGearChange : func(n){
#		me._gearPosition = n.getValue();
#		me.update();
#	},
#	_movingTheMass : func(){
#				
#		interpolate(me._nLeftGearMassLocationX,( me._MassLeftLocationX - ( (1.0-me._positionLeft) * (0.5 * global.CONST.METER2INCH) ) ),me._dt);
#		interpolate(me._nLeftGearMassLocationZ,( me._MassLeftLocationZ + ( (1.0-me._positionLeft) * (0.3 * global.CONST.METER2INCH) ) ),me._dt);
#		
#		interpolate(me._nRightGearMassLocationX,( me._MassRightLocationX - ( (1.0-me._positionRight) * (0.5 * global.CONST.METER2INCH) ) ),me._dt);
#		interpolate(me._nRightGearMassLocationZ,( me._MassRightLocationZ + ( (1.0-me._positionRight) * (0.3 * global.CONST.METER2INCH) ) ),me._dt);
		
		
#	},
	_updateNoseGearLight: func(n){
		if (n.getValue() == 1){
			me._lednosegear.on();
		}elsif (n.getValue() == 0){
			me._lednosegear.off();
		}else{
			me._lednosegear.off();
		}
	},
#	update : func(){
#		me._now 	= systime();
#		me._dt 		= me._now - me._lastTime;
#		me._lastTime	= me._now;
		
		
#		me._wowNose = me._nWowNose.getValue();
		#me._positionNose = me._nPositionNose.getValue();
		#me._positionLeft = me._nPositionLeft.getValue();
		#me._positionRight = me._nPositionRight.getValue();
		
#		if (me._gearPosition == 1.0){
#			me._leds.on();
#			me._nWarning.setValue(0);
#		}elsif (me._gearPosition == 0.0){
#			me._nWarning.setValue(0);
#			me._leds.off();
#		}else{
#			me._leds.off();
#			me._nWarning.setValue(1);
#		}
		
#		if (me._wowNose == 0){
#			if (me._gearPosition != me._swtGear._state){
#				me._hydaulicMotor.drive(1,me._swtGear._state);
#				me._movingTheMass();
#			}else{
#				me._hydaulicMotor.drive(0,0);
#			}
#		}
		
#	}
};

var gearSystem = GearSystemClass.new("/extra500/system/gear","Landing Gear Control");



