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
		#print("ComWidget.init() ... ");
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
		var m = {parents:[TuningWidget,IfdWidget.new(page,canvasGroup,name)]};
		m._class 	= "TuningWidget";
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
		print("TuningWidget.init() ... ");
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
		
		me._Page.IFD.nLedL2.setValue(1);
		me._Page.keys["L2 <"] 	= func(){me._scrollSource(-1);};
		me._Page.keys["L2 >"] 	= func(){me._scrollSource(1);};
		me._Page.IFD.nLedL3.setValue(1);
		me._Page.keys["L3 <"] 	= func(){extra500.keypad.onCom1Scroll(1);};
		me._Page.keys["L3 >"] 	= func(){me._selectChannel(0);};
		me._Page.IFD.nLedL4.setValue(1);
		me._Page.keys["L4 <"] 	= func(){extra500.keypad.onCom2Scroll(1);};
		me._Page.keys["L4 >"] 	= func(){me._selectChannel(1);};
		me._Page.IFD.nLedLK.setValue(1);
		me._Page.keys["LK >>"] 	= func(){me._adjustFreqency(1);};
		me._Page.keys["LK <<"] 	= func(){me._adjustFreqency(-1);};
		me._Page.keys["LK"] 	= nil;
		me._Page.keys["LK >"] 	= func(){me._adjustFreqency(0.025);};
		me._Page.keys["LK <"] 	= func(){me._adjustFreqency(-0.025);};
		
		
	},
	deinit : func(){
		me.removeListeners();
		
		me._Page.IFD.nLedL2.setValue(0);
		me._Page.keys["L2 <"] 	= nil;
		me._Page.keys["L2 >"] 	= nil;
		me._Page.IFD.nLedL3.setValue(0);
		me._Page.keys["L3 <"] 	= nil;
		me._Page.keys["L3 >"] 	= nil;
		me._Page.IFD.nLedL4.setValue(0);
		me._Page.keys["L4 <"] 	= nil;
		me._Page.keys["L4 >"] 	= nil;
		me._Page.IFD.nLedLK.setValue(0);
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

var TcasWidget = {
	new : func(page,canvasGroup,name){
		var m = {parents:[TcasWidget,IfdWidget.new(page,canvasGroup,name)]};
		m._class 	= "TcasWidget";
		m._tab		= [];
		m._can		= {};
		m.MODE		= ["Normal","Above","Unlimited","Below"];
		m.RANGE		= ["2 NM","6 NM"];
		m._service	= 0;
		m._mode		= 0;
		m._range	= 0;
		
		return m;
	},
	setListeners : func(instance) {
		append(me._listeners, setlistener("/instrumentation/tcas/serviceable",func(n){me._onStateChange(n)},1,0));	
	},
	init : func(instance=me){
		#print("TcasWidget.init() ... ");
		me._can = {
			mode	: me._group.getElementById("TCAS_Mode"),
			range	: me._group.getElementById("TCAS_Range"),
			offline	: me._group.getElementById("TCAS_offline"),
			online	: me._group.getElementById("TCAS_online").setVisible(0),
		};
		me.setListeners(instance);
		
		me._Page.IFD.nLedL1.setValue(1);
		me._Page.keys["L1 <"] 	= func(){me._adjustRange(1);};
		me._Page.keys["L1 >"] 	= func(){me._adjustMode(1);};
		me.update();
	},
	deinit : func(){
		me.removeListeners();
		me._Page.IFD.nLedL1.setValue(0);
		me._Page.keys["L1 <"] 	= nil;
		me._Page.keys["L1 >"] 	= nil;
		
	},	
	_onStateChange : func(n){
		me._service = n.getValue();
		me._can.offline.setVisible(!me._service);
		me._can.online.setVisible(me._service);
		if (me._service==1){
			me._Page.IFD.nLedL1.setValue(1);
			me._Page.keys["L1 <"] 	= func(){me._adjustRange(1);};
			me._Page.keys["L1 >"] 	= func(){me._adjustMode(1);};
		}else{
			me._Page.IFD.nLedL1.setValue(0);
			me._Page.keys["L1 <"] 	= nil;
			me._Page.keys["L1 >"] 	= nil;
		}
	},
	update : func(){
		me._can.mode.setText(me.MODE[me._mode]);
		me._can.range.setText(me.RANGE[me._range]);
	},
	_adjustRange : func(amount){
		me._mode += amount;
		if(me._mode > 3){me._mode=0;}
		if(me._mode < 0){me._mode=3;}
		me._can.mode.setText(me.MODE[me._mode]);
	},
	_adjustMode : func(amount){
		me._range += amount;
		if(me._range > 1){me._range=0;}
		if(me._range < 0){me._range=1;}
		me._can.range.setText(me.RANGE[me._range]);
	}
};
