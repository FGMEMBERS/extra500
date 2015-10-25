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
#      Date:             24.10.13
#

# MM GearWarning Page 597
# MM GearControl Page 596

var GearSystemClass = {
	new : func(root,name){
		var m = {parents:[
			GearSystemClass,
			ServiceClass.new(root,name)
		]};
		
		m._lednosegear = LedClass.new("/extra500/light/GearNose","Nose Gear Led","extra500/system/dimming/Annunciator",0.2);
		m._ledlmaingear = LedClass.new("/extra500/light/GearLeft","LMain Gear Led","extra500/system/dimming/Annunciator",0.2);
		m._ledrmaingear = LedClass.new("/extra500/light/GearRight","RMain Gear Led","extra500/system/dimming/Annunciator",0.2);		
		m._swtGear = SwitchBoolClass.new("/extra500/system/gear/MainGearSwitch","Gear",1);

		return m;
	},
	setListeners : func(instance) {
		append(me._listeners, setlistener(extra500.dimmingSystem._nTest,func(n){instance._onDimTestChange(n);},1,0) );
		append(me._listeners, setlistener("/systems/gear/switches/nosegeardown/state",func(n){me._updateNoseGearLight(n);},1,0) );
		append(me._listeners, setlistener("/systems/gear/switches/Lgeardown/state",func(n){me._updateLeftGearLight(n);},1,0) );
		append(me._listeners, setlistener("/systems/gear/switches/Rgeardown/state",func(n){me._updateRightGearLight(n);},1,0) );
	},
	init : func(instance=nil){
		if (instance==nil){instance=me;}
		me.parents[1].init(instance);
		me.setListeners(instance);
	
		me._swtGear.init();
		me._lednosegear.init();
		me._ledlmaingear.init();
		me._ledrmaingear.init();
		
		eSystem.circuitBreaker.WARN_LT.outputAdd(me._lednosegear);
		eSystem.circuitBreaker.WARN_LT.outputAdd(me._ledlmaingear);
		eSystem.circuitBreaker.WARN_LT.outputAdd(me._ledrmaingear);
		
		UI.register("Gear up", 		func{me._swtGear.onClick(0); } 	);
		UI.register("Gear down",	func{me._swtGear.onClick(1); } 	);

		UI.register("Gear Clear Horn", 	func{me.onGearClearHornClick(); } );
		UI.register("Gear Clear Horn on", 	func{me.onGearClearHornClick(1); } );
		UI.register("Gear Clear Horn off",	func{me.onGearClearHornClick(0); } );
		
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
	_updateNoseGearLight: func(n){
		if (n.getValue() == 1){
			me._lednosegear.on();
		}elsif (n.getValue() == 0){
			me._lednosegear.off();
		}else{
			me._lednosegear.off();
		}
	},
	_updateLeftGearLight: func(n){
		if (n.getValue() == 1){
			me._ledlmaingear.on();
		}elsif (n.getValue() == 0){
			me._ledlmaingear.off();
		}else{
			me._ledlmaingear.off();
		}
	},
	_updateRightGearLight: func(n){
		if (n.getValue() == 1){
			me._ledrmaingear.on();
		}elsif (n.getValue() == 0){
			me._ledrmaingear.off();
		}else{
			me._ledrmaingear.off();
		}
	},
	onGearClearHornClick : func(value = nil){
		if (value == nil){
			me._GearClearHorn = me._GearClearHorn == 1 ? 0 : 1;
		}else{
			me._GearClearHorn = value;
		}
		setprop("/systems/gear/switches/GearClearHorn/state",me._GearClearHorn);
	},
};

var gearSystem = GearSystemClass.new("/extra500/system/gear","Landing Gear Control");

setlistener("/gear/gear[13]/wow", func {
	var contact = getprop("/gear/gear[13]/wow");
	
	if (contact == 1) {
		setprop("/fdm/jsbsim/aircraft/propeller/contact",1);
	}
},1,0);
