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
#      Authors: Eric van den Berg
#      Date: Aug 15 2013
#
#      Last change:      - 
#      Date:             -
#
# The DME hold switch overrides any selection made on the keyboard (aux button) and holds the frequency that was active
# as the hold switch is pressed. Indicated by the hold switch blue "HOLD" light.
#
	var onClickonoff = func(){
		if (getprop("/extra500/instrumentation/dmeSwitch/pressed") == 0) {
			setprop("/extra500/instrumentation/dmeSwitch/pressed",1);
			setprop("/instrumentation/dme/frequencies/dmeholdswitch-selected-mhz",getprop("/instrumentation/dme/frequencies/selected-mhz"));
			setprop("/instrumentation/dme/frequencies/source","/instrumentation/dme/frequencies/dmeholdswitch-selected-mhz");
		} else {
			setprop("/extra500/instrumentation/dmeSwitch/pressed",0);
			setprop("/instrumentation/dme/frequencies/source","/instrumentation/dme/frequencies/keypad-selected-mhz");
		}
	}
UI.register("dmeswitch on/off", func{extra500.onClickonoff(); } 	);
