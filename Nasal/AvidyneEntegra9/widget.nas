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

var ComWidget = {
	new : func(page,canvasGroup,name){
		var m = {parents:[ComWidget,IfdWidget.new(page,canvasGroup,name)]};
		m._class 	= "ComWidget";
		m._tab		= [];
		m._can		= {};
		return m;
	},
	setListeners : func(instance) {
		append(me._listeners, setlistener("/instrumentation/comm[0]/frequencies/selected-mhz",func(n){me._onCom1SelectedChange(n)},1,0));	
		append(me._listeners, setlistener("/instrumentation/comm[0]/frequencies/standby-mhz",func(n){me._onCom1StandbyChange(n)},1,0));	
		append(me._listeners, setlistener("/instrumentation/comm[1]/frequencies/selected-mhz",func(n){me._onCom2SelectedChange(n)},1,0));	
		append(me._listeners, setlistener("/instrumentation/comm[1]/frequencies/standby-mhz",func(n){me._onCom2StandbyChange(n)},1,0));	
	},
	init : func(instance=me){
		print("ComWidget.init() ... ");
		me._can = {
			com1selected	: me._group.getElementById("Com1_selected"),
			com1standby	: me._group.getElementById("Com1_standby"),
			com2selected	: me._group.getElementById("Com2_selected"),
			com2standby	: me._group.getElementById("Com2_standby"),
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
};

var TuningWidget = {
	new : func(page,canvasGroup,name){
		var m = {parents:[ComWidget,IfdWidget.new(page,canvasGroup,name)]};
		m._class 	= "ComWidget";
		m._tab		= [];
		m._can		= {};
		return m;
	},
	setListeners : func(instance) {
		append(me._listeners, setlistener("/instrumentation/comm[0]/frequencies/selected-mhz",func(n){me._onCom1SelectedChange(n)},1,0));	
		append(me._listeners, setlistener("/instrumentation/comm[0]/frequencies/standby-mhz",func(n){me._onCom1StandbyChange(n)},1,0));	
		append(me._listeners, setlistener("/instrumentation/comm[1]/frequencies/selected-mhz",func(n){me._onCom2SelectedChange(n)},1,0));	
		append(me._listeners, setlistener("/instrumentation/comm[1]/frequencies/standby-mhz",func(n){me._onCom2StandbyChange(n)},1,0));	
	},
	init : func(instance=me){
		print("ComWidget.init() ... ");
		me._can = {
			com1selected	: me._group.getElementById("Com1_selected"),
			com1standby	: me._group.getElementById("Com1_standby"),
			com2selected	: me._group.getElementById("Com2_selected"),
			com2standby	: me._group.getElementById("Com2_standby"),
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
};