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
#      Date:             20.07.13
#

var COLOR = {};
COLOR["Red"] = "rgb(244,28,33)";
COLOR["Green"] = "rgb(64,178,80)";
COLOR["Magenta"] = "rgb(255,14,235)";
COLOR["Yellow"] = "rgb(241,205,57)";
COLOR["White"] = "rgb(255,255,255)";
COLOR["Turquoise"] = "rgb(4,254,252)";
COLOR["Blue"] = "rgb(51,145,232)";




var PageClass = {
	new: func(ifd,name,data){
		var m = { parents: [PageClass] };
		m.IFD = ifd;	# parent pointer to IFD
		m.page = m.IFD.canvas.createGroup(name);
		m.page.setVisible(0);
		m.name = name;
		m.data = data;
		m.keys = {};
		m._listeners = [];
		m._subPage = "";
		return m;
	},
	setListeners : func(){
		
	},
	removeListeners : func(){
		foreach(l;me._listeners){
			removelistener(l);
		}
		me._listeners = [];
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
			me.keys[key]();
		}
	},
	update20Hz : func(now,dt){},
	update2Hz  : func(now,dt){},
	
};


var IfdWidget = {
	new: func(page,canvasGroup,name){
		var m = {parents:[IfdWidget]};
		m._class = "IfdWidget";
		m._Page 	= page;	# parent pointer to parent Page
		m._group	= canvasGroup;
		m._name 	= name;
		m._listeners 	= [];
		m._can		= {};
		return m;
	},
	removeListeners  :func(){
		foreach(l;me._listeners){
			removelistener(l);
		}
		me._listeners = [];
	},
	setListeners : func(instance) {
		
	},
	init : func(instance=me){
		
	},
	deinit : func(){
		me.removeListeners();	
	},
	update20Hz : func(now,dt){},
	update2Hz  : func(now,dt){},
};

var TimerWidget = {
	new: func(page,canvasGroup,name){
		var m = {parents:[TimerWidget,IfdWidget.new(page,canvasGroup,name)]};
		m._class 	= "TimerWidget";
		m._ptree	= {
			OAT		: props.globals.initNode("/environment/temperature-degc",0.0,"DOUBLE"),
			WindDirection	: props.globals.initNode("/environment/wind-from-heading-deg",0.0,"DOUBLE"),
			WindSpeed	: props.globals.initNode("/environment/wind-speed-kt",0.0,"DOUBLE"),
			GroundSpeed	: props.globals.initNode("/velocities/groundspeed-kt",0.0,"DOUBLE"),
		};
		m._can		= {
			On		: m._group.getElementById("Timer_On"),
			Center		: m._group.getElementById("Timer_btn_Center").updateCenter(),
			Left		: m._group.getElementById("Timer_btn_Left"),
			Time		: m._group.getElementById("Timer_Time"),
			
		};
		m._windSpeed 		= 0;
		m._windDirection 	= 0;
		m._oat			= 0;
		m._groundSpeed		= 0;
		return m;
	},
	init : func(instance=me){
		me.registerKeys();
	},
	deinit : func(){
		me._Page.IFD.nLedR2.setValue(0);
		me._Page.keys["R2 <"] = nil;
		me._Page.keys["R2 >"] = nil;
	},
	registerKeys : func(){
		if ((me._Page.data.timerState == 0)){
			me._Page.IFD.nLedR2.setValue(1);
			me._Page.keys["R2 <"] = func(){me._Page.data.timerStart();me.registerKeys();};
			me._Page.keys["R2 >"] = func(){me._Page.data.timerStart();me.registerKeys();};
			me._can.On.setVisible(0);
			me._can.Center.setVisible(1);
			
		}elsif ((me._Page.data.timerState == 1)){
			me._Page.IFD.nLedR2.setValue(1);
			me._Page.keys["R2 <"] = func(){me._Page.data.timerStart();me.registerKeys();};
			me._Page.keys["R2 >"] = func(){me._Page.data.timerReset();me.registerKeys();};
			me._can.Left.setText("Start");
			me._can.On.setVisible(1);
			me._can.Center.setVisible(0);
		}elsif ((me._Page.data.timerState == 2)){
			me._Page.IFD.nLedR2.setValue(1);
			me._Page.keys["R2 <"] = func(){me._Page.data.timerStop();me.registerKeys();};
			me._Page.keys["R2 >"] = func(){me._Page.data.timerReset();me.registerKeys();};
			me._can.Left.setText("Stop");
			me._can.On.setVisible(1);
			me._can.Center.setVisible(0);
		}
		me._can.Time.setText(me._Page.data.timerGetTime());
	},
	update2Hz : func(now,dt){
		me._can.Time.setText(me._Page.data.timerGetTime());
	}
};
