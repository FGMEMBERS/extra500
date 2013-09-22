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
#      Last change:      Eric van den Berg 
#      Date:             Aug 22 2013
#
#
# electric work in /Systems/extra500-system-electric.xml
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
#
#	/extra500/instrumentation/panelventswitchL/updown
#	/extra500/instrumentation/panelventswitchL/leftright
#	/extra500/instrumentation/panelventswitchR/updown
#	/extra500/instrumentation/panelventswitchR/leftright
#
	var onClickLup = func(){
		var newangle = getprop("/extra500/instrumentation/panelventswitchL/updown") - 2.5;
		if (me._Checkangle(newangle)) {
			setprop("/extra500/instrumentation/panelventswitchL/updown",newangle);
		}
	}
	var onClickLdown = func(){
		var newangle = getprop("/extra500/instrumentation/panelventswitchL/updown") + 2.5;
		if (me._Checkangle(newangle)) {
			setprop("/extra500/instrumentation/panelventswitchL/updown",newangle);
		}
	}
	var onClickLleft = func(){
		var newangle = getprop("/extra500/instrumentation/panelventswitchL/leftright") - 2.5;
		if (me._Checkangle(newangle)) {
			setprop("/extra500/instrumentation/panelventswitchL/leftright",newangle);
		}
	}
	var onClickLright = func(){
		var newangle = getprop("/extra500/instrumentation/panelventswitchL/leftright") + 2.5;
		if (me._Checkangle(newangle)) {
			setprop("/extra500/instrumentation/panelventswitchL/leftright",newangle);
		}
	}
	var onClickRup = func(){
		var newangle = getprop("/extra500/instrumentation/panelventswitchR/updown") - 2.5;
		if (me._Checkangle(newangle)) {
			setprop("/extra500/instrumentation/panelventswitchR/updown",newangle);
		}
	}
	var onClickRdown = func(){
		var newangle = getprop("/extra500/instrumentation/panelventswitchR/updown") + 2.5;
		if (me._Checkangle(newangle)) {
			setprop("/extra500/instrumentation/panelventswitchR/updown",newangle);
		}
	}
	var onClickRleft = func(){
		var newangle = getprop("/extra500/instrumentation/panelventswitchR/leftright") - 2.5;
		if (me._Checkangle(newangle)) {
			setprop("/extra500/instrumentation/panelventswitchR/leftright",newangle);
		}
	}
	var onClickRright = func(){
		var newangle = getprop("/extra500/instrumentation/panelventswitchR/leftright") + 2.5;
		if (me._Checkangle(newangle)) {
			setprop("/extra500/instrumentation/panelventswitchR/leftright",newangle);
		}
	}
	var _Checkangle = func(angle) {
		if ( abs(angle) < 20) {
			return (1); 
		}
	}

UI.register("panelventswitchL on/off", func{extra500.onClickLonoff(); } 	);
UI.register("panelventswitchR on/off", func{extra500.onClickRonoff(); } 	);

UI.register("panelventL up", func{extra500.onClickLup(); } 	);
UI.register("panelventL down", func{extra500.onClickLdown(); } 	);
UI.register("panelventL left", func{extra500.onClickLleft(); } 	);
UI.register("panelventL right", func{extra500.onClickLright(); } 	);
UI.register("panelventR up", func{extra500.onClickRup(); } 	);
UI.register("panelventR down", func{extra500.onClickRdown(); } 	);
UI.register("panelventR left", func{extra500.onClickRleft(); } 	);
UI.register("panelventR right", func{extra500.onClickRright(); } 	);
