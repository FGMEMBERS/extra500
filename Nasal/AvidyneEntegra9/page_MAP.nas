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
		me._widget.Tab.init();
	},
	deinit : func(){
		me.keys = {};
		me.removeListeners();
		
		foreach(widget;keys(me._widget)){
			if(me._widget[widget] != nil){
				me._widget[widget].deinit();
			}
		}
	},
	setVisible : func(visibility){
		me.IFD._widget.Headline.setVisible(visibility);
		me.IFD._widget.PlusData.setVisible(visibility);
		me.IFD.movingMap.setVisible(visibility);
		
		if(visibility == 1){
			me.setListeners(me);
		}else{
			me.keys = {};
			me.removeListeners();
		}
		me._widget.Tab.setVisible(visibility);
		me.page.setVisible(visibility);
	},
	_initWidgetsForTab : func(index){
		me._widget.MovingMapKnob.setVisible(0);
		me.IFD._widget.PlusData.setVisible(0);
			
		if (index == 0){ # MAP+
			me.IFD.movingMap.setLayout("map+");
			me._widget.MovingMapKnob.setHand(1);
			me._widget.MovingMapKnob.setVisible(1);
			me.IFD._widget.PlusData.setVisible(1);
		
			
		}elsif(index == 1){ # MAP
			me.IFD.movingMap.setLayout("map");
			me._widget.MovingMapKnob.setHand(1);
			me._widget.MovingMapKnob.setVisible(1);
			
		
			
		}elsif(index == 2){ # Split
			me.IFD.movingMap.setLayout("split-left");
			me._widget.MovingMapKnob.setHand(0);
			me._widget.MovingMapKnob.setVisible(1);
			
		
		}elsif(index == 3){ # Chart
			me.IFD.movingMap.setLayout("none");
		}elsif(index == 4){ # Chart+
			me.IFD.movingMap.setLayout("none");
			me.IFD._widget.PlusData.setVisible(1);
		
		}elsif(index == 5){ # Radar
			me.IFD.movingMap.setLayout("none");
		}else{
			
		}
	},
	update2Hz : func(now,dt){


		
	},
	update20Hz : func(now,dt){
		

	
	},
};