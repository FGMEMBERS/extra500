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
#      Date: Jul 20 2013
#
#      Last change:      Dirk Dittmann
#      Date:             28.08.13
#

var COLOR = {};
COLOR["Red"] = "rgb(244,28,33)";
COLOR["Green"] = "rgb(64,178,80)";
COLOR["Magenta"] = "rgb(255,14,235)";
COLOR["Yellow"] = "rgb(241,205,57)";
COLOR["White"] = "rgb(255,255,255)";
COLOR["Turquoise"] = "rgb(4,254,252)";
COLOR["Blue"] = "rgb(51,145,232)";
COLOR["DarkGreen"] = "#16502d";


var XPDRMODE = ["OFF","SBY","TST","GND","ON","ALT"];

var tool = {
	adjustStep : func(value,amount,step=10){
		
		if (math.abs(amount) >= step){
			if (math.mod(value,step) != 0){
				if (amount > 0){
					value = math.ceil(value/step)*step;
				}else{
					value = math.floor(value/step)*step;
				}
			}else{
				value += amount;
			}
		}else{
			value += amount;
		}
		return value;
	},
};




var ListenerClass = {
	new: func(){
		var m = { parents: [ListenerClass] };
		m._listeners = [];
		return m;
	},
	setListeners : func(instance=me){
		
	},
	removeListeners : func(){
		foreach(l;me._listeners){
			removelistener(l);
		}
		me._listeners = [];
	},
	
};


var PageClass = {
	new: func(ifd,name,data){
		var m = { parents: [PageClass,ListenerClass.new()] };
		m.IFD = ifd;	# parent pointer to IFD
		m.page = m.IFD.canvas.createGroup(name);
		m.page.setVisible(0);
		m.name = name;
		m.data = data;
		m.keys = {};
		m._subPage = "";
		return m;
	},
	init : func(instance=me){
		
	},
	deinit : func(){
		me.removeListeners();
	},
	registerKeys : func(){
		
	},
	setVisible : func(value){
		me.page.setVisible(value);
	},
	hide : func(){
		me.page.setVisible(0);
	},
	show : func(){
		me.page.setVisible(1);
	},
	onClick : func(key){
		if (contains(me.keys,key)){
			if(me.keys[key]!=nil){
				me.keys[key]();
			}
		}
	},
	update20Hz : func(now,dt){},
	update2Hz  : func(now,dt){},
	
};


var IfdWidget = {
	new: func(page,canvasGroup,name){
		var m = {parents:[IfdWidget,ListenerClass.new()]};
		m._class = "IfdWidget";
		m._Page 	= page;	# parent pointer to parent Page
		m._group	= canvasGroup;
		m._name 	= name;
		m._can		= {};
		return m;
	},
	init : func(instance=me){
		
	},
	deinit : func(){
		me.removeListeners();	
	},
	update20Hz : func(now,dt){},
	update2Hz  : func(now,dt){},
};

