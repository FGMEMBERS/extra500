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
#      Last change:      
#      Date:             
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

UI.register("readinglightswitchpic on/off", func{extra500.onClickpiconoff(); } 	);
UI.register("readinglightswitchcop on/off", func{extra500.onClickcoponoff(); } 	);
UI.register("readinglightswitchLF on/off", func{extra500.onClickLFonoff(); } 	);
UI.register("readinglightswitchLA on/off", func{extra500.onClickLAonoff(); } 	);
UI.register("readinglightswitchRF on/off", func{extra500.onClickRFonoff(); } 	);
UI.register("readinglightswitchRA on/off", func{extra500.onClickRAonoff(); } 	);
