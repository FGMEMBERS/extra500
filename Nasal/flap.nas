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


var FlapSystemClass = {
	new : func(root,name){
		var m = {parents:[
			FlapSystemClass,
			ServiceClass.new(root,name)
		]};
		m.dt = 0;
		m.now = systime();
		m._lastTime = 0;
		m.timerLoop = maketimer(1.0,m,FlapSystemClass.update);
	
		return m;
	},
	init : func(){
		
# 		UI.register("Flaps down", 	func{extra500.flapSystem.switch.left(); } 	);
# 		UI.register("Flaps up",		func{extra500.flapSystem.switch.right(); } 	);
# 		UI.register("Flaps 0", 		func{extra500.flapSystem.switch.setValue(1); } 	);
# 		UI.register("Flaps 15", 	func{extra500.flapSystem.switch.setValue(0); } 	);
# 		UI.register("Flaps 30", 	func{extra500.flapSystem.switch.setValue(-1); } );
	},
	update : func(){
		
	}
};

var flapSystem = FlapSystemClass.new("extra500/system/flap","Flap Control");