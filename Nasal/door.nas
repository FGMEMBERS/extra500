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
#      Last change:      Eric van den Berg
#      Date:             29.09.13
#

	var onClickupperdoor = func(){
		var doorstate = getprop("/extra500/door/upperpass/state");
		if (doorstate == 0) {
			setprop("/extra500/door/upperpass/state",1);
		} else if (doorstate == 1) {
			setprop("/extra500/door/upperpass/state",0);
		}
	}

	var onClicklowerdoor = func(){
		var doorstatelower = getprop("/extra500/door/lowerpass/state");
		var doorstateupper = getprop("/extra500/door/upperpass/state");
		if ( (doorstatelower == 0) and (doorstateupper !=0) ) {
			setprop("/extra500/door/lowerpass/state",1);
		} else if ( (doorstatelower == 1) and (doorstateupper != 0) ) {
			setprop("/extra500/door/lowerpass/state",0);
		}
	}

	var onClickemergencyexit = func(){
		var doorstate = getprop("/extra500/door/emergencyexit/state");
		if (doorstate == 0) {
			setprop("/extra500/door/emergencyexit/state",1);
		} else if (doorstate == 1)  {
			setprop("/extra500/door/emergencyexit/state",0);
		}
	}

UI.register("upper door toggle", 		func{extra500.onClickupperdoor(); } 	);
UI.register("lower door toggle", 		func{extra500.onClicklowerdoor(); } 	);
UI.register("emergency exit", 		func{extra500.onClickemergencyexit(); } 	);
