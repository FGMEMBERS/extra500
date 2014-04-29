var MapOptionWidget = {
	new : func(page,canvasGroup,name){
		var m = {parents:[MapOptionWidget,IfdWidget.new(page,canvasGroup,name)]};
		m._class 	= "MapOptionWidget";
		m._tab		= [];
		m._can = {
			
			
			Map_Options 		: m._group.getElementById("Map_Options").setVisible(0),
# 			Map_Declutter 		: m._group.getElementById("Map_Declutter").setVisible(0),
			Map_Declutter_Land_1 	: m._group.getElementById("Map_Declutter_Land_1"),
			Map_Declutter_Land_2 	: m._group.getElementById("Map_Declutter_Land_2"),
			Map_Declutter_Land_3 	: m._group.getElementById("Map_Declutter_Land_3"),
			Map_Declutter_Nav_1 	: m._group.getElementById("Map_Declutter_Nav_1"),
			Map_Declutter_Nav_2 	: m._group.getElementById("Map_Declutter_Nav_2"),
			Map_Declutter_Nav_3 	: m._group.getElementById("Map_Declutter_Nav_3"),
			
# 			Map_Lightning 		: m._group.getElementById("Map_Lightning").setVisible(0),
			Map_Lightning_Value	: m._group.getElementById("Map_Lightning_Value"),
# 			Map_WxReports 		: m._group.getElementById("Map_WxReports").setVisible(0),
			Map_WxReports_Value	: m._group.getElementById("Map_WxReports_Value"),
# 			Map_WxOverlay 		: m._group.getElementById("Map_WxOverlay").setVisible(0),
			Map_WxOverlay_Value	: m._group.getElementById("Map_WxOverlay_Value"),
			
		};
		m._var = {
			land 		: {value:3,max:3,min:0},
			nav 		: {value:3,max:3,min:0},
			lightning 	: {value:0,max:1,min:0},
			reports		: {value:0,max:1,min:0},
			overlay		: {value:0,max:1,min:0},
		};
		m._lable = {
			lightning	: ["TWX","Test L"],
			reports		: ["AIR/SIGMENT","Test R"],
			overlay		: ["NOWrad","Test O"],
		};
		m._optionsVisible = 0;
		m._timeOutHot = 0;
		m._timeOut = maketimer(10.0,m,MapOptionWidget._onTimeOut);
		m._timeOut.singleShot = 1;
		m._timeOut.stop();
		return m;
	},
	setListeners : func(instance) {
			
	},
	init : func(instance=me){
		#print("ActiveComWidget.init() ... ");
		#me.setListeners(instance);
	},
	deinit : func(){
		#me.removeListeners();
	},
	_onVisibiltyChange : func(){
		me.setTimeOutHot(0);
		if(me._visibility == 1){
			me.setOptionsVisible(1);
# 			me._can.Map_Declutter.setVisible(1);
			me._Page.IFD.nLedR1.setValue(1);
			me._Page.keys["R1 <"] 	= func(){me._onLand(-1)};
			me._Page.keys["R1 >"] 	= func(){me._onNav(-1)};
# 			me._onLand(0);
# 			me._onNav(0);
						
# 			me._can.Map_Lightning.setVisible(1);
			me._Page.IFD.nLedR2.setValue(1);
			me._Page.keys["R2 <"] 	= func(){me._onLightning(-1)};
			me._Page.keys["R2 >"] 	= func(){me._onLightning(1)};
# 			me._onLightning(0);
			
# 			me._can.Map_WxReports.setVisible(1);
			me._Page.IFD.nLedR3.setValue(1);
			me._Page.keys["R3 <"] 	= func(){me._onReports(-1)};
			me._Page.keys["R3 >"] 	= func(){me._onReports(1)};
# 			me._onReports(0);
			
# 			me._can.Map_WxOverlay.setVisible(1);
			me._Page.IFD.nLedR4.setValue(1);
			me._Page.keys["R4 <"] 	= func(){me._onOverlay(-1)};
			me._Page.keys["R4 >"] 	= func(){me._onOverlay(1)};
# 			me._onOverlay(0);
			
		}else{
			me.setOptionsVisible(0);
# 			me._can.Map_Declutter.setVisible(0);
			me._Page.IFD.nLedR1.setValue(0);
			me._Page.keys["R1 <"] 	= nil;
			me._Page.keys["R1 >"] 	= nil;
			
# 			me._can.Map_Lightning.setVisible(0);
			me._Page.IFD.nLedR2.setValue(0);
			me._Page.keys["R2 <"] 	= nil;
			me._Page.keys["R2 >"] 	= nil;
			
# 			me._can.Map_WxReports.setVisible(0);
			me._Page.IFD.nLedR3.setValue(0);
			me._Page.keys["R3 <"] 	= nil;
			me._Page.keys["R3 >"] 	= nil;
			
# 			me._can.Map_WxOverlay.setVisible(0);
			me._Page.IFD.nLedR4.setValue(0);
			me._Page.keys["R4 <"] 	= nil;
			me._Page.keys["R4 >"] 	= nil;
		}
	},
	_startTimeOut :func(){
		if(me._timeOutHot){
			me._timeOut.restart(10.0);
		}else{
			me._timeOut.stop();
		}
	},
	setTimeOutHot : func(value){
		me._timeOutHot = value;
		me._startTimeOut();
	},
	_onTimeOut : func(){
		me.setOptionsVisible(0);
	},
	setOptionsVisible : func(value){
		me._optionsVisible = value;
		me._can.Map_Options.setVisible(me._optionsVisible);
	},
	_checkOptions :func(){
		me._startTimeOut();
		if( me._optionsVisible == 0 ){
			me.setOptionsVisible(1);
			return 1;
		}
		return 0;
	},
	_onLand : func(step){
		if (me._checkOptions()) return 0;
		me._can.Map_Options.setVisible(1);
		me._var.land.value = global.cycle(me._var.land.value,me._var.land.min,me._var.land.max,step);
		me._can.Map_Declutter_Land_1.setVisible(me._var.land.value >= 1);
		me._can.Map_Declutter_Land_2.setVisible(me._var.land.value >= 2);
		me._can.Map_Declutter_Land_3.setVisible(me._var.land.value >= 3);
		me._Page.IFD.movingMap.setLand(me._var.land.value);
		
	},
	_onNav : func(step){
		if (me._checkOptions()) return 0;
		me._var.nav.value = global.cycle(me._var.nav.value,me._var.nav.min,me._var.nav.max,step);
		me._can.Map_Declutter_Nav_1.setVisible(me._var.nav.value >= 1);
		me._can.Map_Declutter_Nav_2.setVisible(me._var.nav.value >= 2);
		me._can.Map_Declutter_Nav_3.setVisible(me._var.nav.value >= 3);
		me._Page.IFD.movingMap.setNav(me._var.nav.value);
	},
	_onLightning : func(step){
		if (me._checkOptions()) return 0;
		me._var.lightning.value = global.cycle(me._var.lightning.value,me._var.lightning.min,me._var.lightning.max,step);
		me._can.Map_Lightning_Value.setText(me._lable.lightning[me._var.lightning.value]);
		me._Page.IFD.movingMap.setLightning(me._var.lightning.value);
	},
	_onReports : func(step){
		if (me._checkOptions()) return 0;
		me._var.reports.value += step;
		me._var.reports.value = global.clamp(me._var.reports.value,me._var.reports.min,me._var.reports.max);
		me._can.Map_WxReports_Value.setText(me._lable.reports[me._var.reports.value]);
		me._Page.IFD.movingMap.setWxReports(me._var.reports.value);
	},
	_onOverlay : func(step){
		if (me._checkOptions()) return 0;
		me._var.overlay.value += step;
		me._var.overlay.value = global.clamp(me._var.overlay.value,me._var.overlay.min,me._var.overlay.max);
		me._can.Map_WxOverlay_Value.setText(me._lable.overlay[me._var.overlay.value]);
		me._Page.IFD.movingMap.setWxOverlay(me._var.overlay.value);
	},	
	
};




var AvidynePageMAP = {
	new: func(ifd,name,data){
		var m = { parents: [
			AvidynePageMAP,
			PageClass.new(ifd,name,data)
		] };
		m.svgFile	= "IFD_MAP.svg";
		
		canvas.parsesvg(m.page, "Models/instruments/IFDs/"~m.svgFile,{
			"font-mapper": global.canvas.FontMapper
			}
		);
		m._widget	= {
			Tab	 	: TabWidget.new(m,m.page,"TabSelectMAP"),
			MovingMapKnob	: MovingMapKnobWidget.new(m,m.page,"MovingMapKnob"),
			MapOptionWidget	: MapOptionWidget.new(m,m.page,"MapOptionWidget"),
			
		};
		m._can = {
			
			
			
		};
		
		m._widget.Tab._tab = ["Map+","Map","Split","Chart","Chart+"];
		
		
		return m;
	},
	init : func(instance=me){
		#print("AvidynePageMAP.init() ... ");
				
		me.setListeners(instance);
		
		foreach(var widget;keys(me._widget)){
			#print("widget : "~widget);
			if(me._widget[widget] != nil){
				
				me._widget[widget].init();
			}
		}
		
		me.registerKeys();
		me._widget.Tab.init();
	},
	deinit : func(){
		me.keys = {};
		me.removeListeners();
		
		foreach(var widget;keys(me._widget)){
			if(me._widget[widget] != nil){
				me._widget[widget].setVisible(0);
				me._widget[widget].deinit();
			}
		}
	},
	_onVisibiltyChange : func(){
		#me.IFD._widget.Headline.setVisible(visibility);
		#me.IFD._widget.PlusData.setVisible(visibility);
		me.IFD.movingMap.setVisible(me._visibility);
		
		if(me._visibility == 1){
			me.setListeners(me);
			
		}else{
			me.keys = {};
			me.removeListeners();
			me._widget.MovingMapKnob.setVisible(me._visibility);
		}
		me._widget.Tab.setVisible(me._visibility);
		me.page.setVisible(me._visibility);
	},
	_initWidgetsForTab : func(index){
		me._widget.MovingMapKnob.setVisible(0);
		#me.IFD._widget.PlusData.setVisible(0);
			
		if (index == 0){ # MAP+
			me.IFD.setLayout(IFD_LAYOUT.PLUS);
			me.IFD.movingMap.setLayout("map+");
			me._widget.MovingMapKnob.setHand(1);
			me._widget.MovingMapKnob.setVisible(1);
			me._widget.MapOptionWidget.setVisible(1);
			me._widget.MapOptionWidget.setTimeOutHot(0);
			
		}elsif(index == 1){ # MAP
			me.IFD.setLayout(IFD_LAYOUT.FULL);
			me.IFD.movingMap.setLayout("map");
			me._widget.MovingMapKnob.setHand(1);
			me._widget.MovingMapKnob.setVisible(1);
			me._widget.MapOptionWidget.setVisible(1);
			me._widget.MapOptionWidget.setTimeOutHot(1);
			
			
		}elsif(index == 2){ # Split
			me.IFD.setLayout(IFD_LAYOUT.SPLIT);
			me.IFD.movingMap.setLayout("split-left");
			me._widget.MovingMapKnob.setHand(0);
			me._widget.MovingMapKnob.setVisible(1);
			me._widget.MapOptionWidget.setVisible(0);
			me._widget.MapOptionWidget.setTimeOutHot(0);
		}elsif(index == 3){ # Chart
			me.IFD.setLayout(IFD_LAYOUT.FULL);
			me.IFD.movingMap.setLayout("none");
			me._widget.MapOptionWidget.setVisible(0);
		}elsif(index == 4){ # Chart+
			me.IFD.setLayout(IFD_LAYOUT.PLUS);
			me.IFD.movingMap.setLayout("none");
			me._widget.MapOptionWidget.setVisible(0);
		
		}elsif(index == 5){ # Radar
			me.IFD.setLayout(IFD_LAYOUT.FULL);
			me.IFD.movingMap.setLayout("none");
			me._widget.MapOptionWidget.setVisible(0);
		}else{
			
		}
	},
	update2Hz : func(now,dt){


		
	},
	update20Hz : func(now,dt){
		

	
	},
};