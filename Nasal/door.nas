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
#      Date:             29.09.13
#

	var onClickUpperDoor = func(value = nil){
		var doorState = getprop("/extra500/door/upperpass/state");
		if (value == nil) {
			setprop("/extra500/door/upperpass/state",!doorState);
		} else if (doorState == 1) {
			setprop("/extra500/door/upperpass/state",value);
		}
	}

	var onClickLowerDoor = func(value = nil){
		var doorStateLower = getprop("/extra500/door/lowerpass/state");
		var doorStateUpper = getprop("/extra500/door/upperpass/state");
		
		var state = 0;
		
		if ( (doorStateLower == 0) and (doorStateUpper !=0) ) {
# 			setprop("/extra500/door/lowerpass/state",1);
			state = 1;
		} else if ( (doorStateLower == 1) and (doorStateUpper != 0) ) {
# 			setprop("/extra500/door/lowerpass/state",0);
			state = 0;
		}
		
		if (value == nil) {
			setprop("/extra500/door/lowerpass/state",!doorStateLower and doorStateUpper);
		}else{
			setprop("/extra500/door/lowerpass/state",value and doorStateUpper  );
		}
	}

	var onClickEmergencyExit = func(value = nil){
		var doorState = getprop("/extra500/door/emergencyexit/state");
		
		if (value == nil){
			setprop("/extra500/door/emergencyexit/state",!doorState);
		}else{
			setprop("/extra500/door/emergencyexit/state",value);
		}
	}

UI.register("door upper", 		func{extra500.onClickUpperDoor(); } 	);
UI.register("door upper open", 		func{extra500.onClickUpperDoor(1); } 	);
UI.register("door upper close", 	func{extra500.onClickUpperDoor(0); } 	);

UI.register("door lower", 		func{extra500.onClickLowerDoor(); } 	);
UI.register("door lower open", 		func{extra500.onClickLowerDoor(1); } 	);
UI.register("door lower close", 	func{extra500.onClickLowerDoor(0); } 	);

UI.register("emergency exit", 		func{extra500.onClickEmergencyExit(); } );
UI.register("emergency exit open", 	func{extra500.onClickEmergencyExit(1); });
UI.register("emergency exit close", 	func{extra500.onClickEmergencyExit(0); });
