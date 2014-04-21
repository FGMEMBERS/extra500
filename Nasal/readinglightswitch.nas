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
#      Date: 18.04.2014
#
#      Last change: Eric van den Berg     
#      Date: 20.04.2014             
#
#
# 
#
	var onClickpiconoff = func(){
		if (getprop("/extra500/interior/readinglightpic/pressed") == 0) {
			setprop("/extra500/interior/readinglightpic/pressed",1);
		} else {
			setprop("/extra500/interior/readinglightpic/pressed",0);
		}
	}
	var onClickcoponoff = func(){
		if (getprop("/extra500/interior/readinglightcop/pressed") == 0) {
			setprop("/extra500/interior/readinglightcop/pressed",1);
		} else {
			setprop("/extra500/interior/readinglightcop/pressed",0);
		}
	}
	var onClickLFonoff = func(){
		if (getprop("/extra500/interior/readinglightLF/pressed") == 0) {
			setprop("/extra500/interior/readinglightLF/pressed",1);
		} else {
			setprop("/extra500/interior/readinglightLF/pressed",0);
		}
	}
	var onClickLAonoff = func(){
		if (getprop("/extra500/interior/readinglightLA/pressed") == 0) {
			setprop("/extra500/interior/readinglightLA/pressed",1);
		} else {
			setprop("/extra500/interior/readinglightLA/pressed",0);
		}
	}
	var onClickRFonoff = func(){
		if (getprop("/extra500/interior/readinglightRF/pressed") == 0) {
			setprop("/extra500/interior/readinglightRF/pressed",1);
		} else {
			setprop("/extra500/interior/readinglightRF/pressed",0);
		}
	}
	var onClickRAonoff = func(){
		if (getprop("/extra500/interior/readinglightRA/pressed") == 0) {
			setprop("/extra500/interior/readinglightRA/pressed",1);
		} else {
			setprop("/extra500/interior/readinglightRA/pressed",0);
		}
	}

	var onClickpicup = func(){
		var newangle = getprop("/extra500/interior/readinglightpic/updown") - 2.5;
		if (me._Checkangle(newangle)) {
			setprop("/extra500/interior/readinglightpic/updown",newangle);
		}
	}
	var onClickpicdown = func(){
		var newangle = getprop("/extra500/interior/readinglightpic/updown") + 2.5;
		if (me._Checkangle(newangle)) {
			setprop("/extra500/interior/readinglightpic/updown",newangle);
		}
	}
	var onClickpicleft = func(){
		var newangle = getprop("/extra500/interior/readinglightpic/leftright") - 2.5;
		if (me._Checkangle(newangle)) {
			setprop("/extra500/interior/readinglightpic/leftright",newangle);
		}
	}
	var onClickpicright = func(){
		var newangle = getprop("/extra500/interior/readinglightpic/leftright") + 2.5;
		if (me._Checkangle(newangle)) {
			setprop("/extra500/interior/readinglightpic/leftright",newangle);
		}
	}
	var onClickcopup = func(){
		var newangle = getprop("/extra500/interior/readinglightcop/updown") - 2.5;
		if (me._Checkangle(newangle)) {
			setprop("/extra500/interior/readinglightcop/updown",newangle);
		}
	}
	var onClickcopdown = func(){
		var newangle = getprop("/extra500/interior/readinglightcop/updown") + 2.5;
		if (me._Checkangle(newangle)) {
			setprop("/extra500/interior/readinglightcop/updown",newangle);
		}
	}
	var onClickcopleft = func(){
		var newangle = getprop("/extra500/interior/readinglightcop/leftright") - 2.5;
		if (me._Checkangle(newangle)) {
			setprop("/extra500/interior/readinglightcop/leftright",newangle);
		}
	}
	var onClickcopright = func(){
		var newangle = getprop("/extra500/interior/readinglightcop/leftright") + 2.5;
		if (me._Checkangle(newangle)) {
			setprop("/extra500/interior/readinglightcop/leftright",newangle);
		}
	}

	var onClickRFup = func(){
		var newangle = getprop("/extra500/interior/readinglightRF/updown") - 2.5;
		if (me._Checkangle(newangle)) {
			setprop("/extra500/interior/readinglightRF/updown",newangle);
		}
	}
	var onClickRFdown = func(){
		var newangle = getprop("/extra500/interior/readinglightRF/updown") + 2.5;
		if (me._Checkangle(newangle)) {
			setprop("/extra500/interior/readinglightRF/updown",newangle);
		}
	}
	var onClickRFleft = func(){
		var newangle = getprop("/extra500/interior/readinglightRF/leftright") - 2.5;
		if (me._Checkangle(newangle)) {
			setprop("/extra500/interior/readinglightRF/leftright",newangle);
		}
	}
	var onClickRFright = func(){
		var newangle = getprop("/extra500/interior/readinglightRF/leftright") + 2.5;
		if (me._Checkangle(newangle)) {
			setprop("/extra500/interior/readinglightRF/leftright",newangle);
		}
	}
	var onClickRAup = func(){
		var newangle = getprop("/extra500/interior/readinglightRA/updown") - 2.5;
		if (me._Checkangle(newangle)) {
			setprop("/extra500/interior/readinglightRA/updown",newangle);
		}
	}
	var onClickRAdown = func(){
		var newangle = getprop("/extra500/interior/readinglightRA/updown") + 2.5;
		if (me._Checkangle(newangle)) {
			setprop("/extra500/interior/readinglightRA/updown",newangle);
		}
	}
	var onClickRAleft = func(){
		var newangle = getprop("/extra500/interior/readinglightRA/leftright") - 2.5;
		if (me._Checkangle(newangle)) {
			setprop("/extra500/interior/readinglightRA/leftright",newangle);
		}
	}
	var onClickRAright = func(){
		var newangle = getprop("/extra500/interior/readinglightRA/leftright") + 2.5;
		if (me._Checkangle(newangle)) {
			setprop("/extra500/interior/readinglightRA/leftright",newangle);
		}
	}
	var onClickLFup = func(){
		var newangle = getprop("/extra500/interior/readinglightLF/updown") - 2.5;
		if (me._Checkangle(newangle)) {
			setprop("/extra500/interior/readinglightLF/updown",newangle);
		}
	}
	var onClickLFdown = func(){
		var newangle = getprop("/extra500/interior/readinglightLF/updown") + 2.5;
		if (me._Checkangle(newangle)) {
			setprop("/extra500/interior/readinglightLF/updown",newangle);
		}
	}
	var onClickLFleft = func(){
		var newangle = getprop("/extra500/interior/readinglightLF/leftright") - 2.5;
		if (me._Checkangle(newangle)) {
			setprop("/extra500/interior/readinglightLF/leftright",newangle);
		}
	}
	var onClickLFright = func(){
		var newangle = getprop("/extra500/interior/readinglightLF/leftright") + 2.5;
		if (me._Checkangle(newangle)) {
			setprop("/extra500/interior/readinglightLF/leftright",newangle);
		}
	}
	var onClickLAup = func(){
		var newangle = getprop("/extra500/interior/readinglightLA/updown") - 2.5;
		if (me._Checkangle(newangle)) {
			setprop("/extra500/interior/readinglightLA/updown",newangle);
		}
	}
	var onClickLAdown = func(){
		var newangle = getprop("/extra500/interior/readinglightLA/updown") + 2.5;
		if (me._Checkangle(newangle)) {
			setprop("/extra500/interior/readinglightLA/updown",newangle);
		}
	}
	var onClickLAleft = func(){
		var newangle = getprop("/extra500/interior/readinglightLA/leftright") - 2.5;
		if (me._Checkangle(newangle)) {
			setprop("/extra500/interior/readinglightLA/leftright",newangle);
		}
	}
	var onClickLAright = func(){
		var newangle = getprop("/extra500/interior/readinglightLA/leftright") + 2.5;
		if (me._Checkangle(newangle)) {
			setprop("/extra500/interior/readinglightLA/leftright",newangle);
		}
	}
	var _Checkangle = func(angle) {
		if ( abs(angle) < 20) {
			return (1); 
		}
	}

UI.register("readinglightswitchpic on/off", func{extra500.onClickpiconoff(); } 	);
UI.register("readinglightswitchcop on/off", func{extra500.onClickcoponoff(); } 	);
UI.register("readinglightswitchLF on/off", func{extra500.onClickLFonoff(); } 	);
UI.register("readinglightswitchLA on/off", func{extra500.onClickLAonoff(); } 	);
UI.register("readinglightswitchRF on/off", func{extra500.onClickRFonoff(); } 	);
UI.register("readinglightswitchRA on/off", func{extra500.onClickRAonoff(); } 	);

UI.register("readinglightpic up", func{extra500.onClickpicup(); } 	);
UI.register("readinglightpic down", func{extra500.onClickpicdown(); } 	);
UI.register("readinglightpic left", func{extra500.onClickpicleft(); } 	);
UI.register("readinglightpic right", func{extra500.onClickpicright(); } 	);

UI.register("readinglightcop up", func{extra500.onClickcopup(); } 	);
UI.register("readinglightcop down", func{extra500.onClickcopdown(); } 	);
UI.register("readinglightcop left", func{extra500.onClickcopleft(); } 	);
UI.register("readinglightcop right", func{extra500.onClickcopright(); } 	);

UI.register("readinglightRF up", func{extra500.onClickRFup(); } 	);
UI.register("readinglightRF down", func{extra500.onClickRFdown(); } 	);
UI.register("readinglightRF left", func{extra500.onClickRFleft(); } 	);
UI.register("readinglightRF right", func{extra500.onClickRFright(); } 	);

UI.register("readinglightRA up", func{extra500.onClickRAup(); } 	);
UI.register("readinglightRA down", func{extra500.onClickRAdown(); } 	);
UI.register("readinglightRA left", func{extra500.onClickRAleft(); } 	);
UI.register("readinglightRA right", func{extra500.onClickRAright(); } 	);

UI.register("readinglightLF up", func{extra500.onClickLFup(); } 	);
UI.register("readinglightLF down", func{extra500.onClickLFdown(); } 	);
UI.register("readinglightLF left", func{extra500.onClickLFleft(); } 	);
UI.register("readinglightLF right", func{extra500.onClickLFright(); } 	);

UI.register("readinglightLA up", func{extra500.onClickLAup(); } 	);
UI.register("readinglightLA down", func{extra500.onClickLAdown(); } 	);
UI.register("readinglightLA left", func{extra500.onClickLAleft(); } 	);
UI.register("readinglightLA right", func{extra500.onClickLAright(); } 	);
