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
			Tab	 : TabWidget.new(m,m.page,"TabSelectMAP"),
			Com	 : ComWidget.new(m,m.page,"Com"),
			
		};
		
		m._widget.Tab._tab = ["Map+","Map","Split","Chart","Chart+"];
		
		
		return m;
	},
	init : func(instance=me){
		#print("AvidynePageMAP.init() ... ");
				
		me.setListeners(instance);
		
		foreach(widget;keys(me._widget)){
			#print("widget : "~widget);
			if(me._widget[widget] != nil){
				
				me._widget[widget].init();
			}
		}
		
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
		if (index == 0){ # Page NavDisplay
			
		}elsif(index == 1){ # Page BugSelect
			
		}else{
			
		}
	},
	update2Hz : func(now,dt){


		
	},
	update20Hz : func(now,dt){
		

	
	},
};