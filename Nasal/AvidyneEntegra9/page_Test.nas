var AvidynePageTest = {
	new: func(ifd,name,data){
		var m = { parents: [
			AvidynePageTest,
			PageClass.new(ifd,name,data)
		] };
		m.svgFile	= "IFD_Test.svg";
		
		canvas.parsesvg(m.page, "Models/instruments/IFDs/"~m.svgFile,{
			"font-mapper": global.canvas.FontMapper
			}
		);
		m._widget	= {
			TCAS	 : TcasWidget.new(m,m.page,"TCAS"),
			
		};
		m._can = {
		};
		
		#m._widget.Tab._tab = ["FPL","MapFPL","Info","Routes","UserWypts","Nearest","MapNearest"];
		
		m._offset = [0,0];
		return m;
	},
	init : func(instance=me){
		print("AvidynePageTest.init() ... ");
				
		me.setListeners(instance);
		
		me._widget.TCAS.init();
		
		me.registerKeys();
		
		me.page.setVisible(1);
		

	},
	deinit : func(){
		me._widget.TCAS.deinit();
		me.page.setVisible(0);
		me.keys = {};
		me.removeListeners();

	},
	_initWidgetsForTab : func(index){

	},
	update2Hz : func(now,dt){
		
	},
	update20Hz : func(now,dt){
	
	},
};