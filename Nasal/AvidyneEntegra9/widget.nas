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
#      Date: Aug 24 2013
#
#      Last change:      Dirk Dittmann
#      Date:             28.08.2013
#


var TabWidget = {
	new : func(page,canvasGroup,name){
		var m = {parents:[TabWidget,IfdWidget.new(page,canvasGroup,name)]};
		m._class 	= "TabWidget";
		m._tab		= [];
		m._can		= {};
		m._index 	= 0;
		m._max  	= 0;
		return m;
	},
	init : func(instance=me){
		#print("TabWidget.init() ... ");
			
		foreach(t;me._tab){
			me._can[t] = {
				content	: me._group.getElementById("Tab_"~t~"_Content"),
				tab	: me._group.getElementById("Tab_"~t~""),
				text	: me._group.getElementById("Tab_"~t~"_Text"),
				back	: me._group.getElementById("Tab_"~t~"_Back"),
			}
		}
		me._max = size(me._tab)-1;
		me.scroll(0);
		
		me._Page.keys[me._Page.name~" >"] = func(){me.scroll(1);};
		me._Page.keys[me._Page.name~" <"] = func(){me.scroll(-1);};
		
	},
	deinit : func(){
		me._Page.keys[me._Page.name~" >"] = nil;
		me._Page.keys[me._Page.name~" <"] = nil;
	},
	scroll : func(amount){
		me._index += amount;
		if (me._index > me._max){ me._index = me._max; }
		if (me._index < 0){ me._index = 0; }

		foreach(t;me._tab){
# 			print("TabWidget.scroll() ... "~t);
			me._can[t].content.setVisible(0);
			me._can[t].tab.set("z-index",1);
			me._can[t].back.set("stroke",COLOR["Blue"]);
			me._can[t].back.set("stroke-width",10);
			me._can[t].text.set("fill",COLOR["Blue"]);
		}
		
		me._can[me._tab[me._index]].content.setVisible(1);
		me._can[me._tab[me._index]].tab.set("z-index",2);
		me._can[me._tab[me._index]].back.set("stroke",COLOR["Turquoise"]);
		me._can[me._tab[me._index]].back.set("stroke-width",12);
		me._can[me._tab[me._index]].text.set("fill",COLOR["Turquoise"]);
	
		me._Page._initWidgetsForTab(me._index);
	}
	
};

var HeadlineWidget = {
	new : func(page,canvasGroup,name){
		var m = {parents:[HeadlineWidget,IfdWidget.new(page,canvasGroup,name)]};
		m._class 	= "HeadlineWidget";
		m._tab		= [];
		m._can		= {};
		m._timer	= maketimer(1.0,m,HeadlineWidget.update);
		return m;
	},
	setListeners : func(instance) {
		append(me._listeners, setlistener("/instrumentation/comm[0]/frequencies/selected-mhz",func(n){me._onCom1SelectedChange(n)},1,0));	
		append(me._listeners, setlistener("/instrumentation/comm[0]/frequencies/standby-mhz",func(n){me._onCom1StandbyChange(n)},1,0));	
		append(me._listeners, setlistener("/instrumentation/comm[1]/frequencies/selected-mhz",func(n){me._onCom2SelectedChange(n)},1,0));	
		append(me._listeners, setlistener("/instrumentation/comm[1]/frequencies/standby-mhz",func(n){me._onCom2StandbyChange(n)},1,0));	
		append(me._listeners, setlistener("/instrumentation/transponder/id-code",func(n){me._onXPDRChange(n);},1,0) );
		append(me._listeners, setlistener("/instrumentation/transponder/inputs/knob-mode",func(n){me._onXPDRmodeChange(n);},1,0) );
		append(me._listeners, setlistener("/autopilot/route-manager/signals/waypoint-changed",func(n){me._onWaypointChange(n)},1,0));	
	},
	init : func(instance=me){
		#print("HeadlineWidget.init() ... ");
		me._can = {
			com1selected	: me._group.getElementById("Com1_selected"),
			com1standby	: me._group.getElementById("Com1_standby"),
			com2selected	: me._group.getElementById("Com2_selected"),
			com2standby	: me._group.getElementById("Com2_standby"),
			Xpdr		: me._group.getElementById("Head_xpdr"),
			XpdrMode	: me._group.getElementById("Head_xpdr_mode"),
			Dest		: me._group.getElementById("Head_Dest"),
			Fuel		: me._group.getElementById("Head_gal"),
			ETA		: me._group.getElementById("Head_eta"),
			Time		: me._group.getElementById("Head_time"),
		};
		me.setListeners(instance);
		
	},
	_onCom1SelectedChange : func(n){
		me._can.com1selected.setText(sprintf("%.3f",n.getValue()));
	},
	_onCom1StandbyChange : func(n){
		me._can.com1standby.setText(sprintf("%.3f",n.getValue()));
	},
	_onCom2SelectedChange : func(n){
		me._can.com2selected.setText(sprintf("%.3f",n.getValue()));
	},
	_onCom2StandbyChange : func(n){
		me._can.com2standby.setText(sprintf("%.3f",n.getValue()));
	},
	_onXPDRChange : func(n){
		me._can.Xpdr.setText(sprintf("%4i",n.getValue()));	
	},
	_onXPDRmodeChange : func(n){
		me._can.XpdrMode.setText(XPDRMODE[n.getValue()]);	
	},
	_onWaypointChange : func(n){
		me._can.Dest.setText(getprop("/autopilot/route-manager/destination/airport"));		
	},
	update : func(){
		var gs = getprop("/velocities/groundspeed-kt");
		if(gs > 50){
		var eta = getprop("/autopilot/route-manager/ete") + systime();
			me._can.ETA.setText(global.formatTime(eta));
		}else{
			me._can.ETA.setText("--:--");
		}
		me._can.Time.setText(getprop("/sim/time/gmt-string"));
		me._can.Fuel.setText("---");
	},
};




var PlusDataWidget = {
	new : func(page,canvasGroup,name){
		var m = {parents:[PlusDataWidget,IfdWidget.new(page,canvasGroup,name)]};
		m._class 	= "PlusDataWidget";
		m._tab		= [];
		m._can		= {};
		m.SOURCE	= ["Com","Nav"];
		m._widget = {
			TCAS	: TcasWidget.new(page,m._group.getElementById("TCAS"),"TcasData"),
		};

		m._source = 0;
		m._channel = 0;
		m._index	= 0;
		m._path		= "";
		m._timer	= maketimer(1.0,m,PlusDataWidget.update);
		return m;
	},
	setListeners : func(instance) {
		append(me._listeners, setlistener("/extra500/instrumentation/Keypad/tuningSource",func(n){me._onTuningSourceChange(n)},1,0));	
		append(me._listeners, setlistener("/extra500/instrumentation/Keypad/tuningChannel",func(n){me._onTuningChannelChange(n)},1,0));	
		append(me._listeners, setlistener("/autopilot/route-manager/current-wp",func(n){me._onCurrentWaypointChange(n)},1,0));	
		append(me._listeners, setlistener("/autopilot/route-manager/signals/waypoint-changed",func(n){me._onWaypointChange(n)},1,0));	
	},
	init : func(instance=me){
		print("PlusDataWidget.init() ... ");
		me._can = {
			source	: me._group.getElementById("Tuning_Source_Text"),
			channel	: [ 
				me._group.getElementById("Tuning_Channel0_Text"),
				me._group.getElementById("Tuning_Channel1_Text")
				],
			border	: [ 
				me._group.getElementById("Tuning_Channel0_Swap_Border"),
				me._group.getElementById("Tuning_Channel1_Swap_Border")
				],
			arrow	: [ 
				me._group.getElementById("Tuning_Channel0_Swap_Arrow"),
				me._group.getElementById("Tuning_Channel1_Swap_Arrow")
				],
			Name		: me._group.getElementById("FPL_Current_Name").setText("----"),
			Course		: me._group.getElementById("FPL_Current_LegCourse").setText("---"),
			Distance	: me._group.getElementById("FPL_Current_LegDistance").setText("---"),
			Fuel		: me._group.getElementById("FPL_Current_LegGal").setText("---"),
			ETA		: me._group.getElementById("FPL_Current_LegETA").setText("--:--"),
			DestName	: me._group.getElementById("FPL_Dest_Name").setText("----"),
			DestBearing	: me._group.getElementById("FPL_Dest_Bearing_Deg").setText("---"),
			DestDistance	: me._group.getElementById("FPL_Dest_Bearing_Distance").setText("---"),
			
		};
		me._widget.TCAS.init();
		me.setListeners(instance);
				
		me._timer.start();
	},
	deinit : func(){
		print("PlusDataWidget.deinit() ... ");
		me._widget.TCAS.deinit();
		me._timer.stop();
		me.removeListeners();
		
	},
	setVisible : func(visible){
		if(visible == 1){
			me._ifd.nLedL2.setValue(1);
			me._Page.keys["L2 <"] 	= func(){me._scrollSource(-1);};
			me._Page.keys["L2 >"] 	= func(){me._scrollSource(1);};
			me._ifd.nLedL3.setValue(1);
			me._Page.keys["L3 <"] 	= func(){extra500.keypad.onCom1Scroll(1);};
			me._Page.keys["L3 >"] 	= func(){me._selectChannel(0);};
			me._ifd.nLedL4.setValue(1);
			me._Page.keys["L4 <"] 	= func(){extra500.keypad.onCom2Scroll(1);};
			me._Page.keys["L4 >"] 	= func(){me._selectChannel(1);};
			me._ifd.nLedLK.setValue(1);
			me._Page.keys["LK >>"] 	= func(){me._adjustFreqency(1);};
			me._Page.keys["LK <<"] 	= func(){me._adjustFreqency(-1);};
			me._Page.keys["LK"] 	= nil;
			me._Page.keys["LK >"] 	= func(){me._adjustFreqency(0.025);};
			me._Page.keys["LK <"] 	= func(){me._adjustFreqency(-0.025);};
		}else{
			me._ifd.nLedL2.setValue(0);
			me._Page.keys["L2 <"] 	= nil;
			me._Page.keys["L2 >"] 	= nil;
			me._ifd.nLedL3.setValue(0);
			me._Page.keys["L3 <"] 	= nil;
			me._Page.keys["L3 >"] 	= nil;
			me._ifd.nLedL4.setValue(0);
			me._Page.keys["L4 <"] 	= nil;
			me._Page.keys["L4 >"] 	= nil;
			me._ifd.nLedLK.setValue(0);
			me._Page.keys["LK >>"] 	= nil;
			me._Page.keys["LK <<"] 	= nil;
			me._Page.keys["LK"] 	= nil;
			me._Page.keys["LK >"] 	= nil;
			me._Page.keys["LK <"] 	= nil;
		}
		me._group.setVisible(visible);
		me._widget.TCAS.setVisible(visible);
		
	},
	_onTuningSourceChange : func(n){
		me._source = n.getValue();
		me._can.source.setText(me.SOURCE[me._source]);
		me._can.channel[0].setText(me.SOURCE[me._source]~" 1");
		me._can.channel[1].setText(me.SOURCE[me._source]~" 2");

	},
	_onTuningChannelChange : func(n){
		me._channel = n.getValue();
		
		if (me._channel == 0){
			me._can.border[0].set("stroke",COLOR["Turquoise"]);
			me._can.arrow[0].set("stroke",COLOR["Turquoise"]);
			me._can.arrow[0].set("fill",COLOR["Turquoise"]);
			me._can.border[1].set("stroke",COLOR["DarkGreen"]);
			me._can.arrow[1].set("stroke",COLOR["DarkGreen"]);
			me._can.arrow[1].set("fill",COLOR["DarkGreen"]);
		}else{
			me._can.border[1].set("stroke",COLOR["Turquoise"]);
			me._can.arrow[1].set("stroke",COLOR["Turquoise"]);
			me._can.arrow[1].set("fill",COLOR["Turquoise"]);
			me._can.border[0].set("stroke",COLOR["DarkGreen"]);
			me._can.arrow[0].set("stroke",COLOR["DarkGreen"]);
			me._can.arrow[0].set("fill",COLOR["DarkGreen"]);
		}
	},
	_scrollSource : func(amount){
		me._source += amount;
		me._source = global.clamp(me._source,0,1);
		setprop("/extra500/instrumentation/Keypad/tuningSource",me._source);
	},
	_selectChannel : func(index){
		setprop("/extra500/instrumentation/Keypad/tuningChannel",index);
	},
	_adjustFreqency : func(amount){
		var source = ["comm","nav"];
		var path = "/instrumentation/"~source[me._source]~"["~me._channel~"]/frequencies/standby-mhz";
		var freq = getprop(path);
		freq+=amount;
		freq = global.clamp(freq,100.0,199.975);
		setprop(path,freq);
		extra500.keypad._inputWatchDog = 0;
	},
	_onCurrentWaypointChange : func(n){
		me._index = n.getValue();
		if(me._index >= 0 ){
			me._path = "/autopilot/route-manager/route/wp["~me._index~"]";
			me._can.Name.setText(sprintf("%s",getprop(me._path~"/id")));
			me._can.Course.setText(sprintf("%03.0f",getprop(me._path~"/leg-bearing-true-deg")));
			me._can.Distance.setText(sprintf("%03.0f",getprop(me._path~"/leg-distance-nm")));
			me._can.Fuel.setText("---");
		}else{
			me._can.Name.setText("----");
			me._can.Course.setText("---");
			me._can.Distance.setText("---");
			me._can.Fuel.setText("---");
			me._can.ETA.setText("--:--");
		}
	},
	_onWaypointChange : func(n){
		me._can.DestName.setText(getprop("/autopilot/route-manager/destination/airport"));	
		me._can.DestBearing.setText("---");
		me._can.DestDistance.setText("---");
			
	},
	update : func(){
		me._can.ETA.setText(getprop("/autopilot/route-manager/wp/eta"));
		me._can.Distance.setText(sprintf("%.1f",getprop("/autopilot/route-manager/wp/dist")));
		me._can.Course.setText(sprintf("%03.0f",getprop("/autopilot/route-manager/wp/bearing-deg")));
			
	},
	
};







var CurrentWaypointWidget_old = {
	new : func(page,canvasGroup,name){
		var m = {parents:[CurrentWaypointWidget_old,IfdWidget.new(page,canvasGroup,name)]};
		m._class 	= "CurrentWaypointWidget_old";
		m._tab		= [];
		m._can		= {};
		m._index	= 0;
		m._path		= "";
		m._timer	= maketimer(1.0,m,CurrentWaypointWidget.update);
		return m;
	},
	setListeners : func(instance) {
		append(me._listeners, setlistener("/autopilot/route-manager/current-wp",func(n){me._onCurrentWaypointChange(n)},1,0));	
		append(me._listeners, setlistener("/autopilot/route-manager/signals/waypoint-changed",func(n){me._onWaypointChange(n)},1,0));	
	},
	init : func(instance=me){
		#print("ComWidget.init() ... ");
		me._can = {
			Name		: me._group.getElementById("FPL_Current_Name").setText("----"),
			Course		: me._group.getElementById("FPL_Current_LegCourse").setText("---"),
			Distance	: me._group.getElementById("FPL_Current_LegDistance").setText("---"),
			Fuel		: me._group.getElementById("FPL_Current_LegGal").setText("---"),
			ETA		: me._group.getElementById("FPL_Current_LegETA").setText("--:--"),
			DestName	: me._group.getElementById("FPL_Dest_Name").setText("----"),
			DestBearing	: me._group.getElementById("FPL_Dest_Bearing_Deg").setText("---"),
			DestDistance	: me._group.getElementById("FPL_Dest_Bearing_Distance").setText("---"),
		};
		me.setListeners(instance);
		me._timer.start();
	},
	deinit : func(){
		me.removeListeners();
		me._timer.stop();
	},
	_onCurrentWaypointChange : func(n){
		me._index = n.getValue();
		if(me._index >= 0 ){
			me._path = "/autopilot/route-manager/route/wp["~me._index~"]";
			me._can.Name.setText(sprintf("%s",getprop(me._path~"/id")));
			me._can.Course.setText(sprintf("%03.0f",getprop(me._path~"/leg-bearing-true-deg")));
			me._can.Distance.setText(sprintf("%03.0f",getprop(me._path~"/leg-distance-nm")));
			me._can.Fuel.setText("---");
		}else{
			me._can.Name.setText("----");
			me._can.Course.setText("---");
			me._can.Distance.setText("---");
			me._can.Fuel.setText("---");
			me._can.ETA.setText("--:--");
		}
	},
	_onWaypointChange : func(n){
		me._can.DestName.setText(getprop("/autopilot/route-manager/destination/airport"));	
		me._can.DestBearing.setText("---");
		me._can.DestDistance.setText("---");
			
	},
	update : func(){
		me._can.ETA.setText(getprop("/autopilot/route-manager/wp/eta"));
		me._can.Distance.setText(sprintf("%.1f",getprop("/autopilot/route-manager/wp/dist")));
		me._can.Course.setText(sprintf("%03.0f",getprop("/autopilot/route-manager/wp/bearing-deg")));
			
	},
};


var TuningWidget_old = {
	new : func(page,canvasGroup,name){
		var m = {parents:[TuningWidget_old,IfdWidget.new(page,canvasGroup,name)]};
		m._class 	= "TuningWidget_old";
		m._tab		= [];
		m._can		= {};
		m.SOURCE	= ["Com","Nav"];
		

		m._source = 0;
		m._channel = 0;
		return m;
	},
	setListeners : func(instance) {
		append(me._listeners, setlistener("/extra500/instrumentation/Keypad/tuningSource",func(n){me._onTuningSourceChange(n)},1,0));	
		append(me._listeners, setlistener("/extra500/instrumentation/Keypad/tuningChannel",func(n){me._onTuningChannelChange(n)},1,0));	
	},
	init : func(instance=me){
		#print("TuningWidget.init() ... ");
		me._can = {
			source	: me._group.getElementById("Tuning_Source_Text"),
			channel	: [ 
				me._group.getElementById("Tuning_Channel0_Text"),
				me._group.getElementById("Tuning_Channel1_Text")
				],
			border	: [ 
				me._group.getElementById("Tuning_Channel0_Swap_Border"),
				me._group.getElementById("Tuning_Channel1_Swap_Border")
				],
			arrow	: [ 
				me._group.getElementById("Tuning_Channel0_Swap_Arrow"),
				me._group.getElementById("Tuning_Channel1_Swap_Arrow")
				]
			
		};
		me.setListeners(instance);
		
		me._ifd.nLedL2.setValue(1);
		me._Page.keys["L2 <"] 	= func(){me._scrollSource(-1);};
		me._Page.keys["L2 >"] 	= func(){me._scrollSource(1);};
		me._ifd.nLedL3.setValue(1);
		me._Page.keys["L3 <"] 	= func(){extra500.keypad.onCom1Scroll(1);};
		me._Page.keys["L3 >"] 	= func(){me._selectChannel(0);};
		me._ifd.nLedL4.setValue(1);
		me._Page.keys["L4 <"] 	= func(){extra500.keypad.onCom2Scroll(1);};
		me._Page.keys["L4 >"] 	= func(){me._selectChannel(1);};
		me._ifd.nLedLK.setValue(1);
		me._Page.keys["LK >>"] 	= func(){me._adjustFreqency(1);};
		me._Page.keys["LK <<"] 	= func(){me._adjustFreqency(-1);};
		me._Page.keys["LK"] 	= nil;
		me._Page.keys["LK >"] 	= func(){me._adjustFreqency(0.025);};
		me._Page.keys["LK <"] 	= func(){me._adjustFreqency(-0.025);};
		
		
	},
	deinit : func(){
		me.removeListeners();
		
		me._ifd.nLedL2.setValue(0);
		me._Page.keys["L2 <"] 	= nil;
		me._Page.keys["L2 >"] 	= nil;
		me._ifd.nLedL3.setValue(0);
		me._Page.keys["L3 <"] 	= nil;
		me._Page.keys["L3 >"] 	= nil;
		me._ifd.nLedL4.setValue(0);
		me._Page.keys["L4 <"] 	= nil;
		me._Page.keys["L4 >"] 	= nil;
		me._ifd.nLedLK.setValue(0);
		me._Page.keys["LK >>"] 	= nil;
		me._Page.keys["LK <<"] 	= nil;
		me._Page.keys["LK"] 	= nil;
		me._Page.keys["LK >"] 	= nil;
		me._Page.keys["LK <"] 	= nil;
		
	},
	_onTuningSourceChange : func(n){
		me._source = n.getValue();
		me._can.source.setText(me.SOURCE[me._source]);
		me._can.channel[0].setText(me.SOURCE[me._source]~" 1");
		me._can.channel[1].setText(me.SOURCE[me._source]~" 2");

	},
	_onTuningChannelChange : func(n){
		me._channel = n.getValue();
		
		if (me._channel == 0){
			me._can.border[0].set("stroke",COLOR["Turquoise"]);
			me._can.arrow[0].set("stroke",COLOR["Turquoise"]);
			me._can.arrow[0].set("fill",COLOR["Turquoise"]);
			me._can.border[1].set("stroke",COLOR["DarkGreen"]);
			me._can.arrow[1].set("stroke",COLOR["DarkGreen"]);
			me._can.arrow[1].set("fill",COLOR["DarkGreen"]);
		}else{
			me._can.border[1].set("stroke",COLOR["Turquoise"]);
			me._can.arrow[1].set("stroke",COLOR["Turquoise"]);
			me._can.arrow[1].set("fill",COLOR["Turquoise"]);
			me._can.border[0].set("stroke",COLOR["DarkGreen"]);
			me._can.arrow[0].set("stroke",COLOR["DarkGreen"]);
			me._can.arrow[0].set("fill",COLOR["DarkGreen"]);
		}
	},
	_scrollSource : func(amount){
		me._source += amount;
		me._source = global.clamp(me._source,0,1);
		setprop("/extra500/instrumentation/Keypad/tuningSource",me._source);
	},
	_selectChannel : func(index){
		setprop("/extra500/instrumentation/Keypad/tuningChannel",index);
	},
	_adjustFreqency : func(amount){
		var source = ["comm","nav"];
		var path = "/instrumentation/"~source[me._source]~"["~me._channel~"]/frequencies/standby-mhz";
		var freq = getprop(path);
		freq+=amount;
		freq = global.clamp(freq,100.0,199.975);
		setprop(path,freq);
		extra500.keypad._inputWatchDog = 0;
	},
	
	
};

var HeadlineWidget_old = {
	new : func(page,canvasGroup,name){
		var m = {parents:[HeadlineWidget_old,IfdWidget.new(page,canvasGroup,name)]};
		m._class 	= "HeadlineWidget_old";
		m._tab		= [];
		m._can		= {};
		m._index	= 0;
		m._path		= "";
		return m;
	},
	setListeners : func(instance) {
		append(me._listeners, setlistener("/instrumentation/transponder/id-code",func(n){me._onXPDRChange(n);},1,0) );
		append(me._listeners, setlistener("/instrumentation/transponder/inputs/knob-mode",func(n){me._onXPDRmodeChange(n);},1,0) );
		append(me._listeners, setlistener("/autopilot/route-manager/signals/waypoint-changed",func(n){me._onWaypointChange(n)},1,0));	
	},
	init : func(instance=me){
		#print("ComWidget.init() ... ");
		me._can = {
			Xpdr		: me._group.getElementById("Head_xpdr"),
			XpdrMode	: me._group.getElementById("Head_xpdr_mode"),
			Dest		: me._group.getElementById("Head_Dest"),
			Fuel		: me._group.getElementById("Head_gal"),
			ETA		: me._group.getElementById("Head_eta"),
			Time		: me._group.getElementById("Head_time"),
		};
		me.setListeners(instance);
		me._timer.start();
	},
	deinit : func(){
		me.removeListeners();
		me._timer.stop();
	},
	_onXPDRChange : func(n){
		me._can.Xpdr.setText(sprintf("%4i",n.getValue()));	
	},
	_onXPDRmodeChange : func(n){
		me._can.XpdrMode.setText(XPDRMODE[n.getValue()]);	
	},
	_onWaypointChange : func(n){
		me._can.Dest.setText(getprop("/autopilot/route-manager/destination/airport"));		
	},
	update : func(){
		var gs = getprop("/velocities/groundspeed-kt");
		if(gs > 50){
		var eta = getprop("/autopilot/route-manager/ete") + systime();
			me._can.ETA.setText(global.formatTime(eta));
		}else{
			me._can.ETA.setText("--:--");
		}
		me._can.Time.setText(getprop("/sim/time/gmt-string"));
		me._can.Fuel.setText("---");
	},
};

var TcasWidgetOld = {
	new : func(page,canvasGroup,name){
		var m = {parents:[TcasWidgetOld,IfdWidget.new(page,canvasGroup,name)]};
		m._class 	= "TcasWidget";
		m._tab		= [];
		m._can		= {};
		m.MODE		= ["Normal","Above","Unlimited","Below"];
		m.RANGE		= ["2 NM","6 NM"];
		m.RANGESCALE	= 1.6;
		m._service	= 0;
		m._mode		= 0;
		m._range	= 6;
		m._alert	= 0;
		m._item		= [];
		m._itemCount	= 0;
		m._itemIndex	= 0;
		m._map		= nil;		
		m._timer	= maketimer(1.0,m,TcasWidget.update);
		return m;
	},
	setListeners : func(instance) {
		append(me._listeners, setlistener("/instrumentation/tcas/serviceable",func(n){me._onStateChange(n)},1,0));	
		append(me._listeners, setlistener("/instrumentation/tcas/ouputs/traffic-alert",func(n){me._onAlertChange(n)},1,0));	
	},
	init : func(instance=me){
		#print("TcasWidget.init() ... ");
		me._can = {
			map	: me._group.getElementById("TCAS_Map"),
			mode	: me._group.getElementById("TCAS_Mode"),
			range	: me._group.getElementById("TCAS_Range"),
			offline	: me._group.getElementById("TCAS_offline"),
			online	: me._group.getElementById("TCAS_online").setVisible(0),
		};
		me._map		= TcasMap.new(me._can.map,"TcasMap");
		me._map.setZoom(me.RANGESCALE*me._range);
		me._map.setVisible(1);
		#me._map.setTranslation(250,750);
		me._map.setTranslation(200,609);
		
		me.setListeners(instance);
		
		me._ifd.nLedL1.setValue(1);
		me._Page.keys["L1 <"] 	= func(){me._adjustMode(1);};
		me._Page.keys["L1 >"] 	= func(){me._adjustRange(4);};
		me.updateCan();
		me._timer.start();
	},
	deinit : func(){
		me._timer.stop();
		me.removeListeners();
		me._ifd.nLedL1.setValue(0);
		me._Page.keys["L1 <"] 	= nil;
		me._Page.keys["L1 >"] 	= nil;
		
	},	
	_onAlertChange : func(n){
		me._alert = n.getValue();
		if(me._alert == 1){
			print ("TcasWidget._onAlertChange() ... TCAS : traffic alert.");
		}
	},
	_onStateChange : func(n){
		me._service = n.getValue();
		me._can.offline.setVisible(!me._service);
		me._can.online.setVisible(me._service);
		if (me._service==1){
			me._ifd.nLedL1.setValue(1);
			me._Page.keys["L1 <"] 	= func(){me._adjustRange(4);};
			me._Page.keys["L1 >"] 	= func(){me._adjustMode(1);};
		}else{
			me._ifd.nLedL1.setValue(0);
			me._Page.keys["L1 <"] 	= nil;
			me._Page.keys["L1 >"] 	= nil;
		}
	},
	update : func(){
		var lat = getprop("/position/latitude-deg");
		var lon = getprop("/position/longitude-deg");
		var hdg = getprop("/orientation/heading-deg");
				
		me._map.setRefPos(lat,lon);
		me._map.setHdg(hdg);
		
		
		
		me._itemIndex = 0;
		var models = props.globals.getNode("/ai/models");
		print ("### tcas - Screen update ###");
		foreach(aircraft;models.getChildren("aircraft")){
			#me._checkAircraft(aircraft);
			var nInRange = aircraft.getNode("radar/in-range");
			
			if(nInRange.getValue() == 1){
				var range = aircraft.getNode("radar/range-nm").getValue();
				if(range <= me._range){
					me._checkAircraft(aircraft);
					
					
				}else{
					nInRange.setValue(0);
				}
			}
			
		}
		for (me._itemIndex ; me._itemIndex < me._itemCount ; me._itemIndex += 1){
			me._item[me._itemIndex]._group.setVisible(0);
		}
		
	},
	_checkAircraft : func(aircraft){
		var nTcasThreat = aircraft.getNode("tcas/threat-level");	
		if (nTcasThreat != nil){
			var level = nTcasThreat.getValue();
			if(level > -1){
				
				if(me._itemIndex >= me._itemCount){
					append(me._item,TcasItemClass.new(me._map,me._itemIndex));
					me._itemCount = size(me._item);
				}
		
				
				var conntact = "";
			
				var nRadarRange = aircraft.getNode("radar/range-nm");
				var lat 	= aircraft.getNode("position/latitude-deg").getValue();
				var lon 	= aircraft.getNode("position/longitude-deg").getValue();
				var vs		= aircraft.getNode("velocities/vertical-speed-fps").getValue();
				var aAlt 	= aircraft.getNode("position/altitude-ft").getValue();
				var uAlt 	= getprop("/position/altitude-ft");
				var alt 	= math.floor(((aAlt-uAlt)/100)+0.5);
				
				var vMovement = "-";
				if (vs < -3.0){# descending
					vMovement = "\\";
				}elsif (vs > 3.0){ # climbing
					vMovement = "/";
				}else{
					
				}
				
			
				conntact ~= sprintf("%i/%i - ",me._itemIndex+1,me._itemCount);
				conntact ~= sprintf("[%i]%s : ",aircraft.getIndex(),aircraft.getChild("callsign").getValue());
				conntact ~= sprintf("threat:%i ",level);
				conntact ~= sprintf("range:%.2f ",nRadarRange.getValue());
								
				conntact ~= sprintf("v:%s ",vMovement);
				conntact ~= sprintf("a:%i",alt);
						
				print (conntact);
				
				me._item[me._itemIndex].setData(lat,lon,alt,vs,level);
				me._itemIndex += 1;
			}
		}
	},
	updateCan : func(){
		me._can.mode.setText(me.MODE[me._mode]);
		me._can.range.setText(sprintf("%i NM",me._range));
	},
	_adjustMode : func(amount){
		me._mode += amount;
		if(me._mode > 3){me._mode=0;}
		if(me._mode < 0){me._mode=3;}
		me._can.mode.setText(me.MODE[me._mode]);
	},
	_adjustRange : func(amount){
		me._range += amount;
		if(me._range > 6){me._range=2;}
		if(me._range < 2){me._range=6;}
		me._can.range.setText(sprintf("%i NM",me._range));
		#setprop("/instrumentation/radar/range",me._range);
		me._map.setZoom(me.RANGESCALE*me._range);
	}
};


