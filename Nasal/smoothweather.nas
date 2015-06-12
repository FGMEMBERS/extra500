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
#      Author: Eric van den Berg, Dirk Dittmann
#      Date:   12.06.2015
#
#      Last change:       
#      Date:             
#


var init_weather = func() {
    if (getprop("/extra500/weather/smooth") == 1)  {
		setprop("sim/gui/dialogs/metar/mode/manual-weather",1);
            setprop("sim/gui/dialogs/metar/source-selection", "Manual input" );
# think need to do controller.apply(); from weather.xml, not sure howto...
    } else {
		setprop("sim/gui/dialogs/metar/mode/manual-weather",0);
            setprop("sim/gui/dialogs/metar/source-selection", "Live input" );
# think need to do controller.apply(); from weather.xml, not sure howto...
    }
}

setlistener("/extra500/weather/smooth", func {
	init_weather();
});




