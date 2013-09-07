var TcasMap = {
	new : func(parent,name){
		var m = {parents:[TcasMap,parent.createChild("map",name)]};
		#debug.dump(m);
		m._can = {
			plane	: m.createChild("group","plane"),
		};
		
		m._can.plane.createChild("path", "icon")
		 .setStrokeLineWidth(3)
                 .setScale(1)
                 .setColor(0.2,0.2,1.0)
                 .moveTo(-5, -5)
                 .line(0, 10)
                 .line(10, 0)
                 .line(0, -10)
                 .line(-10, 0);
		 
		return m;
	},
	setRefPos : func(lat, lon) {
	# print("RefPos set");
		me._node.getNode("ref-lat", 1).setDoubleValue(lat);
		me._node.getNode("ref-lon", 1).setDoubleValue(lon);
		me._can.plane.setGeoPosition(lat,lon);
		me; # chainable
	},
	setHdg : func(hdg) { 
		me._node.getNode("hdg",1).setDoubleValue(hdg); 
		me; # chainable
	},
	setZoom : func(zoom){
		me._node.getNode("range", 1).setDoubleValue(zoom);
	},
};

var Layer = {
	new : func(group,id="none"){
		var m = {parents:[Layer] }; 
		m._id 			= id;
		m._model 		= nil;
		m._group 		= group;
		m._lModelObserver 	= nil;
		m._modelNotification 	= "";
		return m;
	},
	setModel : func(instance=nil,model=nil){
		if(instance==nil){instance=me;}
		me.unsetModel();
		if(model!=nil){
			me._model = model;
			me._lModelObserver = setlistener(me._model._nObserver,func(n){instance.onModelObserverNotify(n);},0,1);
		}
	},
	unsetModel : func(){
		if(me._model != nil){
			removelistener(me._lModelObserver);
			me._lModelObserver = nil;
			me._model = nil;
		}
	},
	onModelObserverNotify : func(n){
		print("Layer.onModelObserverNotify() ...");
		me._modelNotification = n.getValue();
	},
};

var ModelData = {
	new : func(class="none"){
		var m = {parents:[ModelData] }; 
		m._class = class;
		return m;
	},
};

var Model = {
	new : func(rootPath){
		var m = {parents:[Model] }; 
		m._nRoot 	= props.globals.initNode(rootPath);
		m._nObserver	= m._nRoot.initNode("observer","","STRING");
		m._data = [];
		m._dataIndex = 0;
		m._dataCount = 0;
		return m;
	},	
};

var ModelController = {
	new : func(model = nil,layer = nil){
		var m = {parents:[ModelController] }; 
		m._model = model;
		m._layer = layer;
		return m;
	},
	setModel : func(model=nil){
		me.unsetModel();
		if(model!=nil){
			me._model = model;
		}
	},
	unsetModel : func(){
		if(me._model != nil){
			me._model = nil;
		}
	},
	setLayer : func(layer=nil){
		me.unsetLayer();
		if(layer!=nil){
			me._layer = layer;
		}
	},
	unsetLayer : func(){
		if(me._layer != nil){
			me._layer = nil;
		}
	},
};



var TcasData = {
	new : func(id="",range=0,lat=0,lon=0,alt=0,vs=0,level=0){
		var m = {parents:[TcasData,ModelData.new("tcas")] }; 
		m.id	= id;
		m.range	= range;
		m.lat 	= lat ;
		m.lon 	= lon ;
		m.alt 	= alt;
		m.vs 	= vs;
		m.level = level;
		return m;
	},
};

var TcasModel = {
	new : func(rootPath){
		var m = {parents:[TcasModel,Model.new(rootPath)]};
		m._nAIModels = nil;
		m._range = 0;
		m._minLevel = -1;
		m._alt = 0;
		m._lat = 0;
		m._lon = 0;
		m._hdg = 0;
		m._nRange = m._nRoot.initNode("range",6,"DOUBLE");
		m._timer = maketimer(1.0,m,TcasModel.update);
		return m;
	},
	init : func(){
		me._nAIModels = props.globals.getNode("/ai/models");
		me._timer.start();
	},
	update : func(){
		me._alt = getprop("/position/altitude-ft");
		me._lat = getprop("/position/latitude-deg");
		me._lon = getprop("/position/longitude-deg");
		me._hdg = getprop("/orientation/heading-deg");
		
		#print("TcasModel.update() ...");
		me._data = [];	
		me._dataIndex = 0;
		foreach(aircraft;me._nAIModels.getChildren("aircraft")){
			var range = aircraft.getNode("radar/range-nm").getValue();
			if(range > 0 and range <= me._range){
				var nTcasThreat = aircraft.getNode("tcas/threat-level");	
				if (nTcasThreat != nil){
					var level = nTcasThreat.getValue();
					if(level > me._minLevel){
						
						
						var callsign 	= sprintf("[%i]%s :",aircraft.getIndex(),aircraft.getChild("callsign").getValue());
						var lat 	= aircraft.getNode("position/latitude-deg").getValue();
						var lon 	= aircraft.getNode("position/longitude-deg").getValue();
						var vs		= aircraft.getNode("velocities/vertical-speed-fps").getValue();
						var aAlt 	= aircraft.getNode("position/altitude-ft").getValue();
						var alt 	= math.floor(((aAlt-me._alt)/100)+0.5);
						#print(sprintf("%s range:%0.2f | lat:%0.3f lon:%0.3f a:%+i vs:%0.1f l:%i",callsign,range,lat,lon,alt,vs,level));
						append(me._data,TcasData.new(callsign,range,lat,lon,alt,vs,level));
						me._dataIndex += 1;
					}
				}
			}
		}
		me._dataCount = size(me._data);
		
		me._nObserver.setValue("update");
	},
	setRange : func(range){
		me._range = range;
		me._nRange.setValue(me._range);
	},
		
};

var TcasController = {
	new : func(model = nil,layer = nil){
		var m = {parents:[TcasController,ModelController.new(model,layer)]};
		return m;
	},
	setRange : func(range){
		if(range > 6){range=2;}
		if(range < 2){range=6;}
		if(me._model != nil){
			me._model._range = range;
		}
	},
	setMode : func(mode){
		if(mode > 3){mode=0;}
		if(mode < 0){mode=3;}
		
	}
};

var TcasItemClass = {
	new : func(canvasGroup,index){
		var m = {parents:[TcasItemClass]};
		m._group = canvasGroup.createChild("group", "TcasItem_"~index);
		canvas.parsesvg(m._group, "Models/instruments/IFDs/IFD_TCAS_Item.svg");
		m._can = {
			layer 		: m._group.getElementById("layer1").setVisible(0),
			AltAbove 	: m._group.getElementById("Alt_above").setVisible(0),
			AltBelow 	: m._group.getElementById("Alt_below").setVisible(0),
			ArrowClimb	: m._group.getElementById("Arrow_climb").setVisible(0),
			ArrowDescent	: m._group.getElementById("Arrow_descent").setVisible(0),
			ThreadLevel0 	: m._group.getElementById("Thread_Level_0").setVisible(0),
			ThreadLevel1 	: m._group.getElementById("Thread_Level_1").setVisible(0),
			ThreadLevel2 	: m._group.getElementById("Thread_Level_2").setVisible(0),
			ThreadLevel3	: m._group.getElementById("Thread_Level_3").setVisible(0),
		};
		m._can.layer.setTranslation(-16,-32);
		m._color = COLOR["TCAS_LEVEL_0"];
		print("TcasItemClass.new() ... constructed.");
		return m;
	},
	setData : func(lat,lon,alt,vs,level){
		me._group.setVisible(1);
		me._can.layer.setVisible(1);
		me._group.setGeoPosition(lat,lon);
		me._color = COLOR["TCAS_LEVEL_"~level];
		
		if(alt > 0){
			me._can.AltAbove.setText(sprintf("%+i",alt));
			me._can.AltAbove.set("fill",me._color);
			me._can.AltAbove.setVisible(1);
			me._can.AltBelow.setVisible(0);
			
		}elsif(alt < 0){
			me._can.AltBelow.setText(sprintf("%+i",alt));
			me._can.AltBelow.set("fill",me._color);
			me._can.AltBelow.setVisible(1);
			me._can.AltAbove.setVisible(0);
			
		}else{
			me._can.AltAbove.setVisible(0);
			me._can.AltBelow.setVisible(0);
		}
				
		if (vs < -3.0){# descending
			vMovement = "\\";
			me._can.ArrowClimb.setVisible(0);
			me._can.ArrowDescent.set("fill",me._color);
			me._can.ArrowDescent.set("stroke",me._color);
			me._can.ArrowDescent.setVisible(1);
		}elsif (vs > 3.0){ # climbing
			me._can.ArrowDescent.setVisible(0);
			me._can.ArrowClimb.set("fill",me._color);
			me._can.ArrowClimb.set("stroke",me._color);
			me._can.ArrowClimb.setVisible(1);
		}else{
			me._can.ArrowDescent.setVisible(0);
			me._can.ArrowClimb.setVisible(0);
		}
		
		if(level == 0){
			me._can.ThreadLevel0.setVisible(1);
			me._can.ThreadLevel1.setVisible(0);
			me._can.ThreadLevel2.setVisible(0);
			me._can.ThreadLevel3.setVisible(0);
			me._group.set("z-index",1);
		}elsif(level == 1){
			me._can.ThreadLevel0.setVisible(0);
			me._can.ThreadLevel1.setVisible(1);
			me._can.ThreadLevel2.setVisible(0);
			me._can.ThreadLevel3.setVisible(0);
			me._group.set("z-index",2);
		}elsif(level == 2){
			me._can.ThreadLevel0.setVisible(0);
			me._can.ThreadLevel1.setVisible(0);
			me._can.ThreadLevel2.setVisible(1);
			me._can.ThreadLevel3.setVisible(0);
			me._group.set("z-index",3);
		}elsif(level == 3){
			me._can.ThreadLevel0.setVisible(0);
			me._can.ThreadLevel1.setVisible(0);
			me._can.ThreadLevel2.setVisible(0);
			me._can.ThreadLevel3.setVisible(1);
			me._group.set("z-index",4);
		}else{
			me._can.ThreadLevel0.setVisible(0);
			me._can.ThreadLevel1.setVisible(0);
			me._can.ThreadLevel2.setVisible(0);
			me._can.ThreadLevel3.setVisible(0);			
		}
	},
	
};

var TcasLayer = {
	new : func(group,id="none"){
		var m = {parents:[TcasLayer,Layer.new(group,id)] }; 
		m._item 	= [];
		m._itemIndex	= 0;
		m._itemCount	= 0;
		return m;
	},
	onModelObserverNotify : func(n){
		me._notification = n.getValue();
		if(me._notification=="update"){
			me._draw();
		}
	},
	_draw : func(){
# 		print("TcasLayer._draw() ... ");
		
		if(me._model != nil){
			me._itemIndex	= 0;
					
			foreach(tcas;me._model._data){
# 				print(sprintf("%s range:%0.2f | lat:%0.3f lon:%0.3f a:%+i vs:%0.1f l:%i",tcas.id,tcas.range,tcas.lat,tcas.lon,tcas.alt,tcas.vs,tcas.level));
						
				if(me._itemIndex >= me._itemCount){
					append(me._item,TcasItemClass.new(me._group,me._itemIndex));
					me._itemCount = size(me._item);
				}
				me._item[me._itemIndex].setData(tcas.lat,tcas.lon,tcas.alt,tcas.vs,tcas.level);
				me._itemIndex +=1;
			}
			
			for (me._itemIndex ; me._itemIndex < me._itemCount ; me._itemIndex += 1){
				me._item[me._itemIndex]._group.setVisible(0);
			}
		}else{
			print("TcasLayer._draw() ... no model");
		}
	}
	
};


var tcasModel = TcasModel.new("/extra500/instrument/tcas");

var TcasWidget = {
	new : func(page,canvasGroup,name){
		var m = {parents:[TcasWidget,IfdWidget.new(page,canvasGroup,name)]};
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
		#m._timer	= maketimer(1.0,m,TcasWidget.update);
		m.initC();
		return m;
	},
	setListeners : func(instance) {
		append(me._listeners, setlistener("/instrumentation/tcas/serviceable",func(n){me._onStateChange(n)},1,0));	
		append(me._listeners, setlistener("/instrumentation/tcas/inputs/mode",func(n){me._onModeChange(n)},1,0));	
		append(me._listeners, setlistener(tcasModel._nObserver,func(n){me.onModelObserverNotify(n)},1,1));	
		append(me._listeners, setlistener(tcasModel._nRange,func(n){me.onRangeChange(n)},1,1));	
	},
	initC :func(){
		me._can = {
			map	: me._group.getElementById("TCAS_Map"),
			mode	: me._group.getElementById("TCAS_Mode"),
			range	: me._group.getElementById("TCAS_Range"),
			offline	: me._group.getElementById("TCAS_offline"),
			online	: me._group.getElementById("TCAS_online").setVisible(0),
		};
		var mapName 		= "IFD-"~me._Page.IFD.name~"-TCAS";
		me._map			= TcasMap.new(me._can.map,mapName~"-Map");
		me._map.set("clip","rect(409px, 385px, 776px, 15px)");
		me._tcasLayer 		= TcasLayer.new(me._map,mapName~"-Layer",tcasModel);
		me._tcasLayer.setModel(me._tcasLayer,tcasModel);
		#me._tcasController	= TcasController.new(tcasModel,me._tcasLayer);

		
		me._map.setZoom(me.RANGESCALE*me._range);
		me._map.setVisible(1);
		#me._map.setTranslation(250,750);
		me._map.setTranslation(200,609);
		
		
	},
	deinitC :func(){
		
	},
	init : func(instance=me){
		#print("TcasWidget.init() ... ");
		me.setListeners(instance);
		
		me._adjustMode(0);
		me._adjustRange(0);
		
		me._Page.IFD.nLedL1.setValue(1);
		me._Page.keys["L1 <"] 	= func(){me._adjustMode(1);};
		me._Page.keys["L1 >"] 	= func(){me._adjustRange(4);};

		#me._timer.start();
	},
	deinit : func(){
		#me._timer.stop();
		me.removeListeners();
		me._Page.IFD.nLedL1.setValue(0);
		me._Page.keys["L1 <"] 	= nil;
		me._Page.keys["L1 >"] 	= nil;
		
	},	
	onModelObserverNotify : func(n){
		me._map.setRefPos(tcasModel._lat,tcasModel._lon);
		me._map.setHdg(tcasModel._hdg);
	},
	_onStateChange : func(n){
		me._service = n.getValue();
		me._can.offline.setVisible(!me._service);
		me._can.online.setVisible(me._service);
		if (me._service==1){
			me._Page.IFD.nLedL1.setValue(1);
			me._Page.keys["L1 <"] 	= func(){me._adjustRange(4);};
			me._Page.keys["L1 >"] 	= func(){me._adjustMode(1);};
		}else{
			me._Page.IFD.nLedL1.setValue(0);
			me._Page.keys["L1 <"] 	= nil;
			me._Page.keys["L1 >"] 	= nil;
		}
	},
	_adjustMode : func(amount){
		me._mode += amount;
		if(me._mode > 3){me._mode=0;}
		if(me._mode < 0){me._mode=3;}
		setprop("/instrumentation/tcas/inputs/mode",me._mode);
	},
	_adjustRange : func(amount){
		me._range += amount;
		if(me._range > 6){me._range=2;}
		if(me._range < 2){me._range=6;}
		#me._can.range.setText(sprintf("%i NM",me._range));
		#setprop("/instrumentation/radar/range",me._range);
		#me._map.setZoom(me.RANGESCALE*me._range);
		#me._tcasController.setRange(me._range);
		tcasModel.setRange(me._range);
	},
	_onModeChange : func(n){
		me._mode = n.getValue();
		me._can.mode.setText(me.MODE[me._mode]);
	},
	onRangeChange : func(n){
		me._range = n.getValue();
		me._map.setZoom(me.RANGESCALE*me._range);
		me._can.range.setText(sprintf("%i NM",me._range));
	}
};