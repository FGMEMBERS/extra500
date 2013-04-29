#    This file is part of extra500
#
#    The Changer is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 2 of the License, or
#    (at your option) any later version.
#
#    The Changer is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with extra500.  If not, see <http://www.gnu.org/licenses/>.
#
#      Authors: Dirk Dittmann
#      Date: April 29 2013
#
#      Last change:      Dirk Dittmann
#      Date:             29.04.13
#


var Engine = {
	new : func{
		var m = {parents:[
			Engine
		]};
		m.nPropellerFeather 	= props.globals.getNode("/controls/engines/engine[0]/propeller-feather");
		m.nCutOff		= props.globals.getNode("/controls/engines/engine[0]/cutoff");
		m.nReverser		= props.globals.getNode("/controls/engines/engine[0]/reverser");
		m.nN1			= props.globals.getNode("/engines/engine[0]/n1");
		return m;
		
	},
	cutoff : func(value = nil){
		if (value == nil){
			me.nCutOff.setValue(!me.nCutOff.getValue());
		}else{
			me.nCutOff.setValue(value);
		}
	},
	reverser : func(value = nil){
		if (value == nil){
			me.nReverser.setValue(!me.nReverser.getValue());
		}else{
			me.nReverser.setValue(value);
		}
	},
	update : func(){
		if(me.nN1.getValue() > 55.0){
			me.nPropellerFeather.setValue(0);
		}else{
			me.nPropellerFeather.setValue(1);
		}
	},
	initUI : func(){
		UI.register("Engine cutoff", 		func{extra500.engine.cutoff(); } 	);
		UI.register("Engine cutoff on",		func{extra500.engine.cutoff(1); } 	);
		UI.register("Engine cutoff off",	func{extra500.engine.cutoff(0); } 	);
		
		UI.register("Engine reverser", 		func{extra500.engine.reverser(); } 	);
		UI.register("Engine reverser on",	func{extra500.engine.reverser(1); } 	);
		UI.register("Engine reverser off",	func{extra500.engine.reverser(0); } 	);

	}
};

var engine = Engine.new();