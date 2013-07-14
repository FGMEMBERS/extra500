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
#      Date: Jul 05 2013
#
#      Last change:      Dirk Dittmann
#      Date:             05.07.13
#

var CenterConsole = {
	new : func(root,name){
		var m = {parents:[
			CenterConsole,
			ServiceClass.new(root,name)
		]};
		m._Parkingbrake		= 0;
		m._Defrost		= 0;
		m._Deice		= 0;
		m._GearClearHorn	= 0;
		m._PitchTrim		= 0;
		m._ParkingbrakePressure = 0;
		m._BrakePressure 	= 0;
		
		
		m._nCtrlLeftBrake		= props.globals.initNode("/controls/gear/brake-left",0.0,"DOUBLE");
		m._nCtrlRightBrake		= props.globals.initNode("/controls/gear/brake-right",0.0,"DOUBLE");
		m._nCtrlParkingbrake		= props.globals.initNode("/controls/gear/brake-parking",0.0,"DOUBLE");
		m._nParkingbrake 		= m._nRoot.initNode("Parkingbrake/state",0,"BOOL");
		m._nParkingbrakePressure 	= m._nRoot.initNode("Parkingbrake/Pressure",0.0,"DOUBLE");
		m._nDefrost 			= m._nRoot.initNode("Defrost/state",0,"BOOL");
		m._nDeice 			= m._nRoot.initNode("Deice/state",0,"BOOL");
		m._nGearClearHorn 		= m._nRoot.initNode("GearClearHorn/state",0,"BOOL");
		m._nPitchTrim 			= m._nRoot.initNode("PitchTrim/state",0.0,"DOUBLE");
		
		return m;
	},
	setListeners : func(instance) {
		append(me._listeners, setlistener(me._nParkingbrake,func(n){instance.onParkBrakeChange(n);},1,0) );
		append(me._listeners, setlistener(me._nParkingbrakePressure,func(n){instance.onParkingbrakePressureChange(n);},1,0) );
		append(me._listeners, setlistener(me._nCtrlLeftBrake,func(n){instance.onBrakeChange(n);},1,0) );
		append(me._listeners, setlistener(me._nCtrlRightBrake,func(n){instance.onBrakeChange(n);},1,0) );
		append(me._listeners, setlistener(me._nDeice,func(n){instance.onDeiceChange(n);},1,0) );	
	},
	init : func(instance=nil){
		if (instance==nil){instance=me;}
		me.parents[1].init(instance);
		me.setListeners(instance);
		
		me.initUI();
	},
	onParkingbrakePressureChange : func(n){
		me._ParkingbrakePressure = n.getValue();
		me._nCtrlParkingbrake.setValue(me._ParkingbrakePressure);
	},
	onBrakeChange : func(n){
		me._BrakePressure = n.getValue();
		if (me._Parkingbrake == 1){
			if (me._BrakePressure > me._ParkingbrakePressure){
				me._nParkingbrakePressure.setValue(me._BrakePressure);
			}
		}
	},
	onParkBrakeChange : func(n){
		me._Parkingbrake = n.getValue();
		if (me._Parkingbrake == 0){
			me._ParkingbrakePressure = 0;
			me._nParkingbrakePressure.setValue(me._ParkingbrakePressure);
		}
		
	},
	onParkBrakeClick : func(value = nil){
		if (value == nil){
			me._Parkingbrake = me._Parkingbrake == 1 ? 0 : 1;
		}else{
			me._Parkingbrake = value;
		}
		me._nParkingbrake.setValue(me._Parkingbrake);		
	},
	onDefrostClick : func(value = nil){
		if (value == nil){
			me._Defrost = value == 1 ? 0 : 1;
		}else{
			me._Defrost = value;
		}
		me._nDefrost.setValue(me._Defrost);
		
	},
	onDeiceClick : func(value = nil){
		if (value == nil){
			me._Deice = value == 1 ? 0 : 1;
		}else{
			me._Deice = value;
		}
		me._nDeice.setValue(me._Deice);
	},
	onDeiceChange : func(n){
		me._Deice = n.getValue();
		deiceSystem.setIntakeHeat(me._Deice);
	},
	onGearClearHornClick : func(value = nil){
		if (value == nil){
			me._Deice = value == 1 ? 0 : 1;
		}else{
			me._Deice = value;
		}
		me._nGearClearHorn.setValue(me._Deice);
		
	},
	onPitchTrimClick : func(value = nil){
		if (value == nil){
			me._PitchTrim = 0;
		}else{
			me._PitchTrim += value;
		}
		me._PitchTrim = global.clamp(me._PitchTrim,-1.0,1.0);
		me._nPitchTrim.setValue(me._PitchTrim);	
	},
	
	initUI : func(){
		
		UI.register("Parkingbrake", 	func{me.onParkBrakeClick(); } 	);
		UI.register("Parkingbrake on", 	func{me.onParkBrakeClick(1); } 	);
		UI.register("Parkingbrake off", func{me.onParkBrakeClick(0); } );
		
		UI.register("Defrost", 		func{me.onDefrostClick(); } 	);
		UI.register("Defrost on", 	func{me.onDefrostClick(1); } 	);
		UI.register("Defrost off", 	func{me.onDefrostClick(0); } );
		
		UI.register("Deice", 		func{me.onDeiceClick(); } 	);
		UI.register("Deice on", 	func{me.onDeiceClick(1); } 	);
		UI.register("Deice off", 	func{me.onDeiceClick(0); } );
		
		UI.register("Gear Clear Horn", 		func{me.onGearClearHornClick(); } );
		UI.register("Gear Clear Horn on", 	func{me.onGearClearHornClick(1); } );
		UI.register("Gear Clear Horn off",	func{me.onGearClearHornClick(0); } );
		
		UI.register("PitchTrim", 	func{me.onPitchTrimClick(); } );
		UI.register("PitchTrim >", 	func{me.onPitchTrimClick(0.05); } );
		UI.register("PitchTrim <",	func{me.onPitchTrimClick(-0.05); } );
		
		
	},
};

var centerConsole = CenterConsole.new("/extra500/panel/CenterConsole","Center Console");