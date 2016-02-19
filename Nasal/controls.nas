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
#      Date: April 26 2013
#
#      Last change:      Eric van den Berg
#      Date:             29.11.15
#
#
#
# listener to handle proper switch from "force" to "direct" pitch control, see also extra500-flight-controls.xml 
setlistener("/fdm/jsbsim/state/controls-fixed",func(){
	if ((getprop("/fdm/jsbsim/state/controls-fixed") == 1)and(getprop("/autopilot/mode/alt") == 0)and(getprop("/autopilot/mode/vs") == 0)and(getprop("/autopilot/mode/gs-follow") == 0)) {
		setprop("/controls/flight/elevator",getprop("/fdm/jsbsim/aircraft/hstab/elevator/d_e_free-norm"));
	}	
},1,0);



# overloaded functions from Flightgear $fgdata/Nasal/controls.nas

var flapsDown = func(step) {
	if(step == 0) return;
	if(step > 0){
		UI.click("Flaps down");
	}else{
		UI.click("Flaps up");
	}
}



##
# Gear handling.
#
var gearDown = func(v) {
    if (v < 0) {
      UI.click("Gear up");
      #setprop("/controls/gear/gear-down", 0);
    } elsif (v > 0) {
      UI.click("Gear down");
      #setprop("/controls/gear/gear-down", 1);
    }
}
var gearToggle = func { UI.click("Gear"); }


##
# ParkingBrak handling.
#
var applyParkingBrake = func(v) {
    if (!v) { return; }
    UI.click("Parkingbrake");
}

var startEngine = func(v = 1, which...) {
	if(v){
		UI.click("Engine cutoff");
	}
}

# GEAR ##
# prevent retraction of the landing gear when any of the wheels are compressed
# setlistener("controls/gear/gear-down", func
#  {
#  var down = props.globals.getNode("controls/gear/gear-down").getBoolValue();
#  if (!down and (getprop("gear/gear[0]/wow") or getprop("gear/gear[1]/wow") or getprop("gear/gear[2]/wow")))
#   {
#   props.globals.getNode("controls/gear/gear-down").setBoolValue(1);
#   }
#  });
