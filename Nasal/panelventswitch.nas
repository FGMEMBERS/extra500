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
#      Date: Aug 20 2013
#
#      Last change:      - 
#      Date:             -
#
# The DME hold switch overrides any selection made on the keyboard (aux button) and holds the frequency that was active
# as the hold switch is pressed. Indicated by the hold switch blue "HOLD" light.
#
	var onClickLonoff = func(){
		if (getprop("/extra500/instrumentation/panelventswitchL/pressed") == 0) {
			setprop("/extra500/instrumentation/panelventswitchL/pressed",1);
		} else {
			setprop("/extra500/instrumentation/panelventswitchL/pressed",0);
		}
	}
	var onClickRonoff = func(){
		if (getprop("/extra500/instrumentation/panelventswitchR/pressed") == 0) {
			setprop("/extra500/instrumentation/panelventswitchR/pressed",1);
		} else {
			setprop("/extra500/instrumentation/panelventswitchR/pressed",0);
		}
	}
UI.register("panelventswitchL on/off", func{extra500.onClickLonoff(); } 	);
UI.register("panelventswitchR on/off", func{extra500.onClickRonoff(); } 	);
