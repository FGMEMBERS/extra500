

var DirectToWidget = {
	new : func(page,canvasGroup,name){
		var m = {parents:[DirectToWidget,IfdWidget.new(page,canvasGroup,name)]};
		m._class 	= "DirectToWidget";
		m._tab		= [];
		m._can		= {};
		
		m._can = {
			button		: m._group.getElementById("DirectTo").setVisible(0),
			text		: m._group.getElementById("DirectTo_Text"),
			border		: m._group.getElementById("DirectTo_Border"),
		};
		
		return m;
	},
	setListeners : func(instance) {
		append(me._listeners, setlistener("/autopilot/settings/dto-leg",func(n){me._onChange(n)},1,0));	
	},
	init : func(instance=me){
		#print("ActiveComWidget.init() ... ");
		me.setListeners(instance);
		
		me._Page.IFD.nLedR4.setValue(1);
		me._Page.keys["R4 <"] 	= func(){extra500.keypad.onD()};
		me._Page.keys["R4 >"] 	= func(){extra500.keypad.onD()};
		me._can.button.setVisible(1);
	},
	deinit : func(){
		me._can.button.setVisible(0);
		me._Page.IFD.nLedR4.setValue(0);
		me._Page.keys["R4 <"] 	= nil;
		me._Page.keys["R4 >"] 	= nil;
		me.removeListeners();
		
	},
	_onChange : func(n){
		if (n.getValue()==1){
			me._can.text.set("fill",COLOR["White"]);
			me._can.border.set("stroke",COLOR["Turquoise"]);
			me._can.border.set("stroke-width",20);
		}else{
			me._can.text.set("fill",COLOR["Turquoise"]);
			me._can.border.set("stroke",COLOR["Blue"]);
			me._can.border.set("stroke-width",10);
		}
	},
	
	
};



var AvidynePageFMS = {
	new: func(ifd,name,data){
		var m = { parents: [
			AvidynePageFMS,
			PageClass.new(ifd,name,data)
		] };
		m.svgFile	= "IFD_FMS.svg";
		
		canvas.parsesvg(m.page, "Models/instruments/IFDs/"~m.svgFile,{
			"font-mapper": global.canvas.FontMapper
			}
		);
		m._widget	= {
			Tab	 : TabWidget.new(m,m.page,"TabSelectMAP"),
			Com	 : ComWidget.new(m,m.page,"Com"),
			DirectTo : DirectToWidget.new(m,m.page,"DirectTo"),
			Tuning	 : TuningWidget.new(m,m.page,"Tuning"),
			TCAS	 : TcasWidget.new(m,m.page,"TCAS"),
			
		};
		m._can = {
			side	 : m.page.getElementById("layer11").setVisible(0),
			
		};
		
		m._widget.Tab._tab = ["FPL","MapFPL","Info","Routes","UserWypts","Nearest","MapNearest"];
		
		
		return m;
	},
	init : func(instance=me){
		#print("AvidynePageFMS.init() ... ");
				
		me.setListeners(instance);
		
# 		foreach(widget;keys(me._widget)){
# 			#print("widget : "~widget);
# 			if(me._widget[widget] != nil){
# 				
# 				me._widget[widget].init();
# 			}
# 		}
		me._widget.Tab.init();
		me._widget.Com.init();
		
		me.registerKeys();
		
		me.page.setVisible(1);
	},
	deinit : func(){
		me.page.setVisible(0);
		me.keys = {};
		me.removeListeners();
		
		foreach(widget;keys(me._widget)){
			if(me._widget[widget] != nil){
				me._widget[widget].deinit();
			}
		}
	},
	_initWidgetsForTab : func(index){
		me._can.side.setVisible(0);
		me._widget.DirectTo.deinit();
		me._widget.Tuning.deinit();
		me._widget.TCAS.deinit();
		
		if (index == 0){ # FPL
			me._can.side.setVisible(1);
			me._widget.DirectTo.init();
			me._widget.Tuning.init();
			me._widget.TCAS.init();
		}elsif(index == 1){ # MapFPL
			
		}elsif(index == 2){ # Info
			me._can.side.setVisible(1);
			me._widget.DirectTo.init();
			me._widget.Tuning.init();
			me._widget.TCAS.init();
		}elsif(index == 3){ # Routes
			me._can.side.setVisible(1);
			me._widget.Tuning.init();
			me._widget.TCAS.init();
			
		}elsif(index == 4){ # UserWypts
			me._can.side.setVisible(1);
			me._widget.DirectTo.init();
			me._widget.Tuning.init();
			me._widget.TCAS.init();
		}elsif(index == 5){ # Nearest
			me._can.side.setVisible(1);
			me._widget.DirectTo.init();
			me._widget.Tuning.init();
			me._widget.TCAS.init();
		}elsif(index == 6){ # MapNearest
			
		}else{
			
		}
	},
	update2Hz : func(now,dt){


		
	},
	update20Hz : func(now,dt){
		

	
	},
};