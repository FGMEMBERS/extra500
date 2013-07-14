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
#      Date: Jul 02 2013
#
#      Last change:      Dirk Dittmann
#      Date:             02.07.13
#


var DoorClass = {
	new : func(root,name,watt=42.0){
		var m = { 
			parents : [
				DoorClass,
				ServiceClass.new(root,name)
			]
		};
		m._state 	= 0;
		m._nState	= m._nRoot.initNode("state",0.0,"DOUBLE");
		m._nOpen	= m._nRoot.initNode("isOpen",0,"BOOL");
		
		return m;
	},
	init : func(instance=nil){
		if (instance==nil){instance=me;}
		me.parents[1].init(instance);
		me.setListeners(instance);
	},
	setListeners : func(instance) {
		append(me._listeners, setlistener(me._nState,func(n){instance._onStateChange(n);},1,0) );
	},
	_onStateChange : func(n){
		me._state = n.getValue();
		me.checkState();
	},
	checkState : func(){
		me._nOpen.setValue(me._state);
	},
	onClick : func(value = nil){
		if (value == nil){
			me._state 	= me._state == 1 ? 0 : 1;
		}else{
			me._state	= value;
		}
		me._nState.setValue(me._state);
	},
	registerUI : func(){
		UI.register(""~me._name~"", 		func{me.onClick(); } 	);
		UI.register(""~me._name~" open", 	func{me.onClick(1); }	);
		UI.register(""~me._name~" close", 	func{me.onClick(0); }	);
	}
};


var mainDoor = DoorClass.new("/extra500/door/main","Main Door");
