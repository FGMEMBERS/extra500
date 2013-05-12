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
#      Last change:      Thomas Grossberger
#      Date:             10.05.13
#
#
#
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
    } elsif (v > 0) {
      UI.click("Gear down");
    }
}
var gearToggle = func { UI.click("Gear"); }


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
