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
#      Authors: Dirk Dittmann, Eric van den Berg
#      Date: 13.04.2014
#
#      Last change: Eric van den Berg     
#      Date: 30.04.2014            
#

var interior = {
	new : func(root,name){
		var m = {parents:[
			interior,
			ServiceClass.new(root,name)
		]};
		m._table		= 0;
		m._doorRight		= 0;
		m._doorLeftUp		= 0;
		m._doorLeftLow		= 0;
		
		m._nTable		= props.globals.initNode("extra500/interior/tisch/state",0,"DOUBLE");
		m._nDoorStorageRight		= props.globals.initNode("extra500/interior/storageright/doorstate",0,"DOUBLE");
		m._nDoorStorageLeftUpper	= props.globals.initNode("extra500/interior/storageupperleft/doorstate",0,"DOUBLE");
		m._nDoorStorageLeftLower	= props.globals.initNode("extra500/interior/storagelowerleft/doorstate",0,"DOUBLE");
	
		return m;
	},
	init : func(instance=nil){
		if (instance==nil){instance=me;}
		me.parents[1].init(instance);
#		me.setListeners(instance);
		
		me.initUI();
	},
	onTableClick : func(value = nil){
		if (value == nil){
			me._table = me._table == 1 ? 0 : 1;
		}else{
			me._table = value;
		}
		interpolate(me._nTable,me._table,0.3);
	},
	onDoorStorageRightClick : func(value = nil){
		if (value == nil){
			me._doorRight = me._doorRight == 1 ? 0 : 1;
		}else{
			me._doorRight = value;
		}
		interpolate(me._nDoorStorageRight,me._doorRight,0.3);
	},
	onDoorStorageLeftUpperClick : func(value = nil){
		if (value == nil){
			me._doorLeftUp = me._doorLeftUp == 1 ? 0 : 1;
		}else{
			me._doorLeftUp = value;
		}
		interpolate(me._nDoorStorageLeftUpper,me._doorLeftUp,0.3);		
	},
	onDoorStorageLeftLowerClick : func(value = nil){
		if (value == nil){
			me._doorLeftLow = me._doorLeftLow == 1 ? 0 : 1;
		}else{
			me._doorLeftLow = value;
		}
		interpolate(me._nDoorStorageLeftLower,me._doorLeftLow,0.3);		
	},
	initUI : func(){
		UI.register("Tisch", 	func{me.onTableClick(); } 	);
		UI.register("Tisch up", 	func{me.onTableClick(1); } 	);
		UI.register("Tisch down", func{me.onTableClick(0); } );

		UI.register("storagedoorright open/close",func{me.onDoorStorageRightClick(); } 	);
		UI.register("storagedoorright open", 	func{me.onDoorStorageRightClick(1); } 	);
		UI.register("storagedoorright close", 	func{me.onDoorStorageRightClick(0); } );

		UI.register("storagedoorupperleft open/close",func{me.onDoorStorageLeftUpperClick(); } 	);
		UI.register("storagedoorupperleft open", 	func{me.onDoorStorageLeftUpperClick(1); } 	);
		UI.register("storagedoorupperleft close", 	func{me.onDoorStorageLeftUpperClick(0); } );

		UI.register("storagedoorlowerleft open/close",func{me.onDoorStorageLeftLowerClick(); } 	);
		UI.register("storagedoorlowerleft open", 	func{me.onDoorStorageLeftLowerClick(1); } 	);
		UI.register("storagedoorlowerleft close", 	func{me.onDoorStorageLeftLowerClick(0); } );
				
	},
};

var interior = interior.new("/extra500/interior","Interior");
