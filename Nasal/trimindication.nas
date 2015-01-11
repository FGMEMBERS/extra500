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
#      Author: Eric van den Berg
#      Date:   23.11.2014
#
#      Last change:      Eric van den Berg 
#      Date:             26.11.2014
#

var left2 = nil;

setlistener("/sim/signals/fdm-initialized", func {
    init_display();
});

setlistener("/extra500/config/ui/trim", func {
    init_display();
});

setlistener("/autopilot/mode/alt", func {
	init_display();
});

setlistener("/autopilot/mode/vs", func {
	init_display();
});

setlistener("/autopilot/mode/gs-follow", func {
	init_display();
});

setlistener("/autopilot/mode/cws", func {
	init_display();
});

setlistener("/fdm/jsbsim/aircraft/events/pitchtrim", func {
	pilottrim();
});


var init_display = func() {
    if ((getprop("/extra500/config/ui/trim") == 1) and (getprop("/autopilot/mode/alt")!=1)and(getprop("/autopilot/mode/vs")!=1)and(getprop("/autopilot/mode/gs-follow")!=1)and(getprop("/autopilot/mode/cws")!=1)) {
	    if(left2 == nil){
		left2  = screen.display.new(100,10);
		left2.add("/fdm/jsbsim/aircraft/hstab/elevator/pilot");
	    }
    } else {
	    if(left2 != nil){
	    	left2.close();
	    	left2 = nil;
	    }
    }
}

var pilottrim = func() {
	if (getprop("/fdm/jsbsim/state/controls-fixed")!=1) {
		setprop("/fdm/jsbsim/aircraft/hstab/elevator/pilot","has let go of controls");
	} else if (getprop("/fdm/jsbsim/aircraft/events/pitchtrim") == 1) {
		setprop("/fdm/jsbsim/aircraft/hstab/elevator/pilot","PUSHING +");
	} else if (getprop("/fdm/jsbsim/aircraft/events/pitchtrim") == 2){
		setprop("/fdm/jsbsim/aircraft/hstab/elevator/pilot","PUSHING ++");
	} else if (getprop("/fdm/jsbsim/aircraft/events/pitchtrim") == 3){
		setprop("/fdm/jsbsim/aircraft/hstab/elevator/pilot","PUSHING +++");
	} else if (getprop("/fdm/jsbsim/aircraft/events/pitchtrim") == -1){
		setprop("/fdm/jsbsim/aircraft/hstab/elevator/pilot","PULLING -");
	} else if (getprop("/fdm/jsbsim/aircraft/events/pitchtrim") == -2){
		setprop("/fdm/jsbsim/aircraft/hstab/elevator/pilot","PULLING --");
	} else if (getprop("/fdm/jsbsim/aircraft/events/pitchtrim") == -3){
		setprop("/fdm/jsbsim/aircraft/hstab/elevator/pilot","PULLING ---");
	} else {
		setprop("/fdm/jsbsim/aircraft/hstab/elevator/pilot","TRIMMED");
	}
}


