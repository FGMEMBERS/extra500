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
#      Last change:      
#      Date:             
#

var interior = {
	new : func(root,name){
		var m = {parents:[
			interior,
			ServiceClass.new(root,name)
		]};
		m._Tisch		= 0;
		
		m._nTisch		= props.globals.initNode("extra500/interior/tisch/state",0,"BOOL");
	
		return m;
	},
	init : func(instance=nil){
		if (instance==nil){instance=me;}
		me.parents[1].init(instance);
#		me.setListeners(instance);
		
		me.initUI();
	},
	onTischClick : func(value = nil){
		if (value == nil){
			me._Tisch = me._Tisch == 1 ? 0 : 1;
		}else{
			me._Tisch = value;
		}
		me._nTisch.setValue(me._Tisch);
		
	},
	initUI : func(){
		UI.register("Tisch", 	func{me.onTischClick(); } 	);
		UI.register("Tisch up", 	func{me.onTischClick(1); } 	);
		UI.register("Tisch down", func{me.onTischClick(0); } );
				
	},
};

var interior = interior.new("/extra500/interior","Interior");
