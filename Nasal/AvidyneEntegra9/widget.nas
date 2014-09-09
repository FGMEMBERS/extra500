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

var FREQENCY_SOURCE = ["Com","Nav"];

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
		#debug.dump(me._ifd._group);
		me._can["Tabs"] = me._ifd._group.getElementById("Tab_"~me._Page.name).setVisible(0);
		foreach(var t;me._tab){
			me._can[t] = {
				#content	: me._group.getElementById(me._Page.name~"Tab_"~t~"_Content"),
				tab	: me._ifd._group.getElementById(me._Page.name~"_"~t),
				text	: me._ifd._group.getElementById(me._Page.name~"_"~t~"_Text"),
				back	: me._ifd._group.getElementById(me._Page.name~"_"~t~"_Back"),
			}
		}
		me._max = size(me._tab)-1;
	},
	deinit : func(){
		
	},
	_onVisibiltyChange : func(){
		if(me._visibility == 1){
# 			me._Page.keys[me._Page.name~" >"] = func(){me.scroll(1);};
# 			me._Page.keys[me._Page.name~" <"] = func(){me.scroll(-1);};
			me._ifd.ui.bindKey(me._Page.name,{
				"<"	: func(){me.scroll(-1);},
				">"	: func(){me.scroll(1);},
			});
			me.scroll(0);
		}else{
# 			me._Page.keys[me._Page.name~" >"] = nil;
# 			me._Page.keys[me._Page.name~" <"] = nil;
			me._ifd.ui.bindKey(me._Page.name);
		}
		me._can.Tabs.setVisible(me._visibility);
	},
	scroll : func(amount){
# 		print("TabWidget.scroll("~amount~")");
		me._index += amount;
		if (me._index > me._max){ me._index = me._max; }
		if (me._index < 0){ me._index = 0; }
		#debug.dump(me._can);
			
		foreach(var t;me._tab){
# 			print("TabWidget.scroll() ... "~t);
			#me._can[t].content.setVisible(0);
			me._can[t].tab.set("z-index",1);
			me._can[t].back.set("stroke",COLOR["Blue"]);
			me._can[t].back.set("stroke-width",10);
			me._can[t].text.set("fill",COLOR["Blue"]);
		}
		
		#me._can[me._tab[me._index]].content.setVisible(1);
		me._can[me._tab[me._index]].tab.set("z-index",2);
		me._can[me._tab[me._index]].back.set("stroke",COLOR["Turquoise"]);
		me._can[me._tab[me._index]].back.set("stroke-width",12);
		me._can[me._tab[me._index]].text.set("fill",COLOR["Turquoise"]);
	
		me._Page._initWidgetsForTab(me._index);
	},
};


var HeadlineWidget = {
	new : func(page,canvasGroup,name){
		var m = {parents:[HeadlineWidget,IfdWidget.new(page,canvasGroup,name)]};
		m._class 	= "HeadlineWidget";
		m._tab		= [];
		m._can		= {};
		m._timer	= maketimer(1.0,m,HeadlineWidget.update);
		m._source = 0;
		m._freqencyListeners = [];
		m._can = {
			freqency1LabelActive	: m._group.getElementById("Freqency1_label_active"),
			freqency1LabelStandby	: m._group.getElementById("Freqency1_label_standby"),
			freqency2LabelActive	: m._group.getElementById("Freqency2_label_active"),
			freqency2LabelStandby	: m._group.getElementById("Freqency2_label_standby"),
			
			freqency1Active		: m._group.getElementById("Freqency1_active"),
			freqency1Standby	: m._group.getElementById("Freqency1_standby"),
			freqency2Active		: m._group.getElementById("Freqency2_active"),
			freqency2Standby	: m._group.getElementById("Freqency2_standby"),
			
			Xpdr			: m._group.getElementById("Head_xpdr"),
			XpdrMode		: m._group.getElementById("Head_xpdr_mode"),
			Dest			: m._group.getElementById("Head_Dest"),
			Fuel			: m._group.getElementById("Head_gal"),
			ETA			: m._group.getElementById("Head_eta"),
			Time			: m._group.getElementById("Head_time"),
		};
		
		return m;
	},
	_removeFreqencyListeners : func(){
		foreach(var l;me._freqencyListeners){
			removelistener(l);
		}
		me._freqencyListeners = [];
	},
	setListeners : func(instance) {
		append(me._listeners, setlistener("/extra500/instrumentation/Keypad/tuningSource",func(n){me._onTuningSourceChange(n)},1,0));	
		
# 		append(me._listeners, setlistener("/instrumentation/comm[0]/frequencies/selected-mhz",func(n){me._onFreqency1ActiveChange(n)},1,0));	
# 		append(me._listeners, setlistener("/instrumentation/comm[0]/frequencies/standby-mhz",func(n){me._onFreqency1StandbyChange(n)},1,0));	
# 		append(me._listeners, setlistener("/instrumentation/comm[1]/frequencies/selected-mhz",func(n){me._onFreqency2ActiveChange(n)},1,0));	
# 		append(me._listeners, setlistener("/instrumentation/comm[1]/frequencies/standby-mhz",func(n){me._onFreqency2StandbyChange(n)},1,0));	
		append(me._listeners, setlistener("/instrumentation/transponder/id-code",func(n){me._onXPDRChange(n);},1,0) );
		append(me._listeners, setlistener("/instrumentation/transponder/inputs/knob-mode",func(n){me._onXPDRmodeChange(n);},1,0) );
		append(me._listeners, setlistener("/autopilot/route-manager/signals/waypoint-changed",func(n){me._onWaypointChange(n)},1,0));	
		append(me._listeners, setlistener(fms._signal.fplReady,func(n){me._onFplReadyChange(n)},1,0));	
		append(me._listeners, setlistener(fms._signal.fplUpdated,func(n){me._onFplUpdatedChange(n)},0,1));	
		
	},
	init : func(instance=me){
		#print("HeadlineWidget.init() ... ");
		me._can.Dest.setText("----");
		me._can.Xpdr.setText("----");
		me._can.XpdrMode.setText("---");
		me._can.Time.setText("--:--:--");
		me._can.ETA.setText("--:--");
		me._can.Fuel.setText("---");
		#me.setListeners(instance);
	},
	_onVisibiltyChange : func(){
		if(me._visibility == 1){
			me.setListeners(me);
			me._timer.start();
		}else{
			me.removeListeners();
			me._removeFreqencyListeners();
			me._timer.stop();
		}
		me._group.setVisible(me._visibility);
	},
	_onTuningSourceChange: func(n){
		me._source = n.getValue();
		me._removeFreqencyListeners();
		if(me._source == 0){
			me._can.freqency1LabelActive.setText("Com1");
			me._can.freqency2LabelActive.setText("Com2");
			append(me._freqencyListeners, setlistener("/instrumentation/comm[0]/frequencies/selected-mhz",func(n){me._onFreqency1ActiveChange(n)},1,0));	
			append(me._freqencyListeners, setlistener("/instrumentation/comm[0]/frequencies/standby-mhz",func(n){me._onFreqency1StandbyChange(n)},1,0));	
			append(me._freqencyListeners, setlistener("/instrumentation/comm[1]/frequencies/selected-mhz",func(n){me._onFreqency2ActiveChange(n)},1,0));	
			append(me._freqencyListeners, setlistener("/instrumentation/comm[1]/frequencies/standby-mhz",func(n){me._onFreqency2StandbyChange(n)},1,0));	
		}else{
			me._can.freqency1LabelActive.setText("Nav1");
			me._can.freqency2LabelActive.setText("Nav2");
			append(me._freqencyListeners, setlistener("/instrumentation/nav[0]/frequencies/selected-mhz",func(n){me._onFreqency1ActiveChange(n)},1,0));	
			append(me._freqencyListeners, setlistener("/instrumentation/nav[0]/frequencies/standby-mhz",func(n){me._onFreqency1StandbyChange(n)},1,0));	
			append(me._freqencyListeners, setlistener("/instrumentation/nav[1]/frequencies/selected-mhz",func(n){me._onFreqency2ActiveChange(n)},1,0));	
			append(me._freqencyListeners, setlistener("/instrumentation/nav[1]/frequencies/standby-mhz",func(n){me._onFreqency2StandbyChange(n)},1,0));	
			
		}
	},
	_onFreqency1ActiveChange : func(n){
		me._can.freqency1Active.setText(sprintf("%.3f",n.getValue()));
	},
	_onFreqency1StandbyChange : func(n){
		me._can.freqency1Standby.setText(sprintf("%.3f",n.getValue()));
	},
	_onFreqency2ActiveChange : func(n){
		me._can.freqency2Active.setText(sprintf("%.3f",n.getValue()));
	},
	_onFreqency2StandbyChange : func(n){
		me._can.freqency2Standby.setText(sprintf("%.3f",n.getValue()));
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
	_onFplReadyChange: func(n){
		if(fms._fightPlan.isReady){
			
		}else{
			me._can.ETA.setText("--:--");
			me._can.Fuel.setText("---");
		}
	},
	_onFplUpdatedChange: func(n){
			me._can.ETA.setText(global.formatTime(fms._fightPlan.eta));
			me._can.Fuel.setText(sprintf("%.0f",fms._fightPlan.fuelAt));
	},
	update : func(){
		me._can.Time.setText(getprop("/sim/time/gmt-string"));
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
		append(me._listeners, setlistener(fms._signal.fplReady,func(n){me._onFplReadyChange(n)},1,0));	
		append(me._listeners, setlistener(fms._signal.fplUpdated,func(n){me._onFplUpdatedChange(n)},0,1));	
		
	},
	init : func(instance=me){
		#print("PlusDataWidget.init() ... ");
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
	_onVisibiltyChange : func(){
		if(me._visibility == 1){

			me._ifd.ui.bindKey("L2",{
				"<"	: func(){me._scrollSource(-1);},
				">"	: func(){me._scrollSource(1);},
			});

			me._ifd.ui.bindKey("L3",{
				"<"	: func(){keypad.onCom1Scroll(1);},
				">"	: func(){me._selectChannel(0);},
			});

			me._ifd.ui.bindKey("L4",{
				"<"	: func(){keypad.onCom2Scroll(1);},
				">"	: func(){me._selectChannel(1);},
			});
			
			
			me._ifd.ui.bindKnob("LK",{
				"<<"	: func(){me._adjustFreqency(-1);},
				"<"	: func(){me._adjustFreqency(-0.025);},
				"push"	: func(){me._swapFreqency();},
				">"	: func(){me._adjustFreqency(0.025);},
				">>"	: func(){me._adjustFreqency(1);},
			},{
				"scroll"	: "Tune",
				"push"		: "Swap",
			});
			
		}else{
			me._ifd.ui.bindKey("L2");
			me._ifd.ui.bindKey("L3");
			me._ifd.ui.bindKey("L4");
			me._ifd.ui.bindKnob("LK");
			
		}
		me._group.setVisible(me._visibility);
		me._widget.TCAS.setVisible(me._visibility);
		
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
	_swapFreqency : func(){
		if(me._channel == 0){
			keypad.onCom1Scroll(1);
		}else{
			keypad.onCom2Scroll(1);
		}
	},
	_adjustFreqency : func(amount){
		var source = ["comm","nav"];
		var path = "/instrumentation/"~source[me._source]~"["~me._channel~"]/frequencies/standby-mhz";
		var freq = getprop(path);
		freq+=amount;
		freq = global.clamp(freq,100.0,199.975);
		setprop(path,freq);
		keypad._inputWatchDog = 0;
	},
	_onCurrentWaypointChange : func(n){
		me._index = n.getValue();
		if(me._index >= 0 ){
			me._path = "/autopilot/route-manager/route/wp["~me._index~"]";
			me._can.Name.setText(sprintf("%s",getprop(me._path~"/id")));
			me._can.Course.setText(sprintf("%03.0f",getprop(me._path~"/leg-bearing-true-deg")));
			me._can.Distance.setText(sprintf("%03.0f",getprop(me._path~"/leg-distance-nm")));

		}else{
			me._can.Name.setText("----");
			me._can.Course.setText("---");
			me._can.Distance.setText("---");
			me._can.ETA.setText("--:--");
		}
	},
	_onWaypointChange : func(n){
		me._can.DestName.setText(getprop("/autopilot/route-manager/destination/airport"));
	},
	_onFplReadyChange: func(n){
		if(fms._fightPlan.isReady){
			me._can.ETA.setText(getprop("/autopilot/route-manager/wp/eta"));
			me._can.Distance.setText(sprintf("%.1f",getprop("/autopilot/route-manager/wp/dist")));
			me._can.Course.setText(sprintf("%03.0f",tool.course(getprop("/autopilot/route-manager/wp/bearing-deg"))));
			me._can.DestBearing.setText(sprintf("%03.0f",(tool.course(fms._fightPlan.destination.bearingCourse - getprop("/environment/magnetic-variation-deg")))));
			me._can.DestDistance.setText(sprintf("%.0f",fms._fightPlan.destination.bearingDistance));
		}else{
			me._can.ETA.setText("--:--");
			me._can.Distance.setText("---");
			me._can.Course.setText("---");
			me._can.Fuel.setText("--");
			me._can.DestBearing.setText("---");
			me._can.DestDistance.setText("---");
		}
	},
	_onFplUpdatedChange: func(n){
			me._can.ETA.setText(getprop("/autopilot/route-manager/wp/eta"));
			me._can.Distance.setText(sprintf("%.1f",getprop("/autopilot/route-manager/wp/dist")));
			me._can.Course.setText(sprintf("%03.0f",tool.course(getprop("/autopilot/route-manager/wp/bearing-deg"))));
			me._can.Fuel.setText(sprintf("%.0f",fms._fightPlan.wp[fms._fightPlan.currentWp].fuelAt));
			me._can.DestBearing.setText(sprintf("%03.0f",(tool.course(fms._fightPlan.destination.bearingCourse - getprop("/environment/magnetic-variation-deg")))));
			me._can.DestDistance.setText(sprintf("%.0f",fms._fightPlan.destination.bearingDistance));
	},
	update : func(){
# 		if(fms._isFPLready and fms._fplUpdated){
# 		
# 			me._can.ETA.setText(getprop("/autopilot/route-manager/wp/eta"));
# 			me._can.Distance.setText(sprintf("%.1f",getprop("/autopilot/route-manager/wp/dist")));
# 			me._can.Course.setText(sprintf("%03.0f",tool.course(getprop("/autopilot/route-manager/wp/bearing-deg"))));
# 			me._can.Fuel.setText(sprintf("%.0f",getprop("/autopilot/route-manager/wp/fuelAt_GalUs")));
# 			me._can.DestBearing.setText(sprintf("%03.0f",(tool.course(fms._fightPlan.destination.course - getprop("/environment/magnetic-variation-deg")))));
# 			me._can.DestDistance.setText(sprintf("%.0f",fms._fightPlan.destination.distanceTo));
# 		}else{
# 			me._can.ETA.setText("--:--");
# 			me._can.Distance.setText("---");
# 			me._can.Course.setText("---");
# 			me._can.Fuel.setText("--");
# 			me._can.DestBearing.setText("---");
# 			me._can.DestDistance.setText("---");
# 		}
	},
	
};


