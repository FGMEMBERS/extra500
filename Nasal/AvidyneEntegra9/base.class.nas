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
COLOR["Red"] 		= "rgb(244,28,33)";
COLOR["Green"] 		= "#67e54a";
COLOR["Magenta"] 	= "rgb(255,14,235)";
COLOR["Yellow"] 	= "rgb(241,205,57)";
COLOR["Black"] 		= "rgb(0,0,0)";
COLOR["White"] 		= "rgb(255,255,255)";
COLOR["Turquoise"] 	= "rgb(4,254,252)";
COLOR["Blue"] 		= "rgb(51,145,232)";
COLOR["DarkGreen"] 	= "#16502d";
COLOR["TCAS_LEVEL_0"] 	= "#00ffff";
COLOR["TCAS_LEVEL_1"] 	= "#00ffff";
COLOR["TCAS_LEVEL_2"] 	= "#ff7f2a";
COLOR["TCAS_LEVEL_3"] 	= "#ff0000";
COLOR["Keypad_Front"] 	= "#000000";
COLOR["Keypad_Back"] 	= "#ffffff";



var XPDRMODE 	= ["OFF","SBY","TST","GND","ON","ALT"];
var LABEL_OFFON	= ["Off","On"];
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
	course : func(course=nil){
		if(course!=nil){
			course = math.mod(course,360.0);
			course = math.floor(course + 0.5);
			if(course == 0){
				course = 360;	
			}
		}else{
			course = "---" ;
		}
		return course;
		
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
		foreach(var l;me._listeners){
			removelistener(l);
		}
		me._listeners = [];
	},
	
};

var IFDClass = {
	new: func(root,name){
		var m = { parents: [IFDClass] };
		m._name = name;
		return m;
	},
	init : func(instance=me){
		
	},
	deinit : func(){
		
	},
	getIFD : func(){ return me ;},
};

var PageClass = {
	new: func(ifd,name,data){
		var m = { parents: [PageClass,ListenerClass.new()] };
		m.IFD = ifd;	# parent pointer to IFD
		m._ifd = ifd;
		m.page = m.IFD.canvas.createGroup(name);
		m._visibility	= 0;
		m.page.setVisible(m._visibility);
		m.name = name;
		m.data = data;
		m.keys = {};
		m._subPage = "";
		return m;
	},
	getIFD : func(){ return me.IFD ;},
	init : func(instance=me){
		
	},
	deinit : func(){
		me.removeListeners();
	},
	registerKeys : func(){
		
	},
	setVisible : func(visibility){
		if(me._visibility!=visibility){
			me._visibility = visibility;
# 			print("["~me.name ~ "]._onVisibiltyChange() ... " ~ me._visibility);
			me._onVisibiltyChange();
		}
	},
	_onVisibiltyChange : func(){
		me.page.setVisible(me._visibility);
	},
	boot : func(warm = nil){},
	hide : func(){
		me.page.setVisible(0);
	},
	show : func(){
		me.page.setVisible(1);
	},
	onClick : func(key){
# 		print("PageClass.onClick("~key~")");
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
		m._ifd		= page.getIFD();
		m._group	= canvasGroup;
		m._visibility	= 0;
		m._name 	= name;
		m._can		= {};
		m._group.setVisible(m._visibility);
		return m;
	},
	getIFD : func(){ return me._Page.getIFD() ;},
	init : func(instance=me){
		
	},
	deinit : func(){
		me.removeListeners();	
	},
	setVisible : func(visibility){
		if(me._visibility!=visibility){
			me._visibility = visibility;
#  			print("["~me._name ~ "]._onVisibiltyChange() ... " ~ me._visibility);
			me._onVisibiltyChange();
		}
	},
	_onVisibiltyChange : func(){
		me._group.setVisible(me._visibility);
	},
# 	update20Hz : func(now,dt){},
# 	update2Hz  : func(now,dt){},
};

