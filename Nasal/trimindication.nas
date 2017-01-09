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
#      Date:             09.01.2017
#

var init_display = func() {
    if ((getprop("/extra500/config/ui/trim") == 1) and (getprop("/autopilot/mode/alt")!=1)and(getprop("/autopilot/mode/vs")!=1)and(getprop("/autopilot/mode/gs-follow")!=1)and(getprop("/autopilot/mode/cws")!=1)) {
		setprop("/fdm/jsbsim/aircraft/hstab/elevator/trimscreen",1);
    } else {
		setprop("/fdm/jsbsim/aircraft/hstab/elevator/trimscreen",0);
    }
}

var TrimInd = {
	new: func(){
		var m = { parents: [TrimInd] };

		m._canvas = nil;

		m._canvas = canvas.new({
		"name": "TrimInd",
		"size": [256, 256],
		"view": [150, 170],
		"mipmapping": 1,
		});
		

		m._canvas.addPlacement({"node": "trimpanel.Screen"});
		m._canvas.set("background", "#313131ff");
		m._group = m._canvas.createGroup("Global");
		
		canvas.parsesvg(m._group, "Models/panels/trim.svg",{
			"font-mapper": global.canvas.FontMapper
			}
		);


		m._can = {
			Layout : {
				Push1		: m._group.getElementById("push1").setVisible(0),
				Push2		: m._group.getElementById("push2").setVisible(0),
				Push3		: m._group.getElementById("push3").setVisible(0),

				Pull1		: m._group.getElementById("pull1").setVisible(0),
				Pull2		: m._group.getElementById("pull2").setVisible(0),
				Pull3		: m._group.getElementById("pull3").setVisible(0),

				Force		: m._group.getElementById("text_force").setVisible(1),

				Pulling	: m._group.getElementById("text_pulling").setVisible(0),
				Pushing	: m._group.getElementById("text_pushing").setVisible(0),
				Trimmed	: m._group.getElementById("text_trimmed").setVisible(0),

				PContrFailed	: m._group.getElementById("text_PCFailed").setVisible(0),
				ForceC	: m._group.getElementById("text_forcec").setVisible(0),
				DirectC	: m._group.getElementById("text_directc").setVisible(0),

			}
			
		};

		return m;
	},
	trimChange : func() {
		if (getprop("/extra500/failurescenarios/controls/elevator") ==1) {
			me._can.Layout.Force.setVisible(0);
			me._can.Layout.Push1.setVisible(0);
			me._can.Layout.Push2.setVisible(0);
			me._can.Layout.Push3.setVisible(0);
			me._can.Layout.Pull1.setVisible(0);
			me._can.Layout.Pull2.setVisible(0);
			me._can.Layout.Pull3.setVisible(0);
			me._can.Layout.Pulling.setVisible(0);
			me._can.Layout.Pushing.setVisible(0);
			me._can.Layout.Trimmed.setVisible(0);
			me._can.Layout.PContrFailed.setVisible(1);
			me._can.Layout.DirectC.setVisible(0);
			me._can.Layout.ForceC.setVisible(0);
		}else {
			me._can.Layout.Force.setVisible(1);

			if (getprop("/fdm/jsbsim/state/controls-fixed")!=1) {
				me._can.Layout.DirectC.setVisible(0);
				me._can.Layout.ForceC.setVisible(1);
				me._can.Layout.PContrFailed.setVisible(0);
			}else {
				me._can.Layout.DirectC.setVisible(1);
				me._can.Layout.ForceC.setVisible(0);
				me._can.Layout.PContrFailed.setVisible(0);
			}

			if (getprop("/fdm/jsbsim/aircraft/events/pitchtrim") == 1) {
				me._can.Layout.Push1.setVisible(1);
				me._can.Layout.Push2.setVisible(0);
				me._can.Layout.Push3.setVisible(0);
				me._can.Layout.Pull1.setVisible(0);
				me._can.Layout.Pull2.setVisible(0);
				me._can.Layout.Pull3.setVisible(0);
				me._can.Layout.Pulling.setVisible(0);
				me._can.Layout.Pushing.setVisible(1);
				me._can.Layout.Trimmed.setVisible(0);
			} else if (getprop("/fdm/jsbsim/aircraft/events/pitchtrim") == 2){
				me._can.Layout.Push1.setVisible(1);
				me._can.Layout.Push2.setVisible(1);
				me._can.Layout.Push3.setVisible(0);
				me._can.Layout.Pull1.setVisible(0);
				me._can.Layout.Pull2.setVisible(0);
				me._can.Layout.Pull3.setVisible(0);
				me._can.Layout.Pulling.setVisible(0);
				me._can.Layout.Pushing.setVisible(1);
				me._can.Layout.Trimmed.setVisible(0);
			} else if (getprop("/fdm/jsbsim/aircraft/events/pitchtrim") == 3){
				me._can.Layout.Push1.setVisible(1);
				me._can.Layout.Push2.setVisible(1);
				me._can.Layout.Push3.setVisible(1);
				me._can.Layout.Pull1.setVisible(0);
				me._can.Layout.Pull2.setVisible(0);
				me._can.Layout.Pull3.setVisible(0);
				me._can.Layout.Pulling.setVisible(0);
				me._can.Layout.Pushing.setVisible(1);
				me._can.Layout.Trimmed.setVisible(0);
			} else if (getprop("/fdm/jsbsim/aircraft/events/pitchtrim") == -1){
				me._can.Layout.Push1.setVisible(0);
				me._can.Layout.Push2.setVisible(0);
				me._can.Layout.Push3.setVisible(0);
				me._can.Layout.Pull1.setVisible(1);
				me._can.Layout.Pull2.setVisible(0);
				me._can.Layout.Pull3.setVisible(0);
				me._can.Layout.Pulling.setVisible(1);
				me._can.Layout.Pushing.setVisible(0);
				me._can.Layout.Trimmed.setVisible(0);
			} else if (getprop("/fdm/jsbsim/aircraft/events/pitchtrim") == -2){
				me._can.Layout.Push1.setVisible(0);
				me._can.Layout.Push2.setVisible(0);
				me._can.Layout.Push3.setVisible(0);
				me._can.Layout.Pull1.setVisible(1);
				me._can.Layout.Pull2.setVisible(1);
				me._can.Layout.Pull3.setVisible(0);
				me._can.Layout.Pulling.setVisible(1);
				me._can.Layout.Pushing.setVisible(0);
				me._can.Layout.Trimmed.setVisible(0);
			} else if (getprop("/fdm/jsbsim/aircraft/events/pitchtrim") == -3){
				me._can.Layout.Push1.setVisible(0);
				me._can.Layout.Push2.setVisible(0);
				me._can.Layout.Push3.setVisible(0);
				me._can.Layout.Pull1.setVisible(1);
				me._can.Layout.Pull2.setVisible(1);
				me._can.Layout.Pull3.setVisible(1);
				me._can.Layout.Pulling.setVisible(1);
				me._can.Layout.Pushing.setVisible(0);
				me._can.Layout.Trimmed.setVisible(0);
			} else {
				me._can.Layout.Push1.setVisible(0);
				me._can.Layout.Push2.setVisible(0);
				me._can.Layout.Push3.setVisible(0);
				me._can.Layout.Pull1.setVisible(0);
				me._can.Layout.Pull2.setVisible(0);
				me._can.Layout.Pull3.setVisible(0);
				me._can.Layout.Pulling.setVisible(0);
				me._can.Layout.Pushing.setVisible(0);
				me._can.Layout.Trimmed.setVisible(1);
			}
		}
	},

};

var TrimIndication = TrimInd.new();

setlistener("/sim/signals/fdm-initialized", func {
    init_display();
},1,0);

setlistener("/extra500/config/ui/trim", func {
    init_display();
},1,0);

setlistener("/autopilot/mode/alt", func {
	init_display();
},1,0);

setlistener("/autopilot/mode/vs", func {
	init_display();
},1,0);

setlistener("/autopilot/mode/gs-follow", func {
	init_display();
},1,0);

setlistener("/autopilot/mode/cws", func {
	init_display();
},1,0);

setlistener("/fdm/jsbsim/aircraft/events/pitchtrim", func {
	extra500.TrimIndication.trimChange();
});


