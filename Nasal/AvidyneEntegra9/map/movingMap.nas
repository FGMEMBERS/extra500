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
#      Date: Sep 10 2013
#
#      Last change:      Dirk Dittmann
#      Date:             14.09.2013
#

# var RouteLayer = {
# 	new : func(group,id="none"){
# 		var m = {parents:[RouteLayer,Layer.new(group,id)] }; 
# 		m._item 	= [];
# 		m._itemIndex	= 0;
# 		m._itemCount	= 0;
# 		return m;
# 	},
# 	onModelObserverNotify : func(n){
# 		me._notification = n.getValue();
# 		if(me._notification=="update"){
# 			me._draw();
# 		}
# 	},
# 	_draw : func(){
# # 		print("TcasLayer._draw() ... ");
# 		
# 		if(me._model != nil){
# 			me._itemIndex	= 0;
# 					
# 			foreach(var tcas;me._model._data){
# # 				print(sprintf("%s range:%0.2f | lat:%0.3f lon:%0.3f a:%+i vs:%0.1f l:%i",tcas.id,tcas.range,tcas.lat,tcas.lon,tcas.alt,tcas.vs,tcas.level));
# 						
# 				if(me._itemIndex >= me._itemCount){
# 					append(me._item,TcasItemClass.new(me._group,me._itemIndex));
# 					me._itemCount = size(me._item);
# 				}
# 				me._item[me._itemIndex].setData(tcas.lat,tcas.lon,tcas.alt,tcas.vs,tcas.level);
# 				me._itemIndex +=1;
# 			}
# 			
# 			for (me._itemIndex ; me._itemIndex < me._itemCount ; me._itemIndex += 1){
# 				me._item[me._itemIndex]._group.setVisible(0);
# 			}
# 		}else{
# 			print("TcasLayer._draw() ... no model");
# 		}
# 	}
# 	
# };
var MAP_RANGE = [2,4,10,20,30,40,50,80,160,240];
var MAP_VIEW = {"NORTH_UP":0,"HDG_UP_CENTER":1,"HDG_UP_FRONT":2};
var MovingMap = {
	new : func(ifd,parent,name){
		var m = {parents:[
			MovingMap,
			ListenerClass.new(),
		]};
		#debug.dump(m);
		m.IFD 		= ifd;
		m._group 	= parent;
		m._name		= name;
		m._tree	= {
			Heading		: props.globals.initNode("/instrumentation/heading-indicator-IFD-"~m.IFD.name~"/indicated-heading-deg",0.0,"DOUBLE"),
			HeadingTrue	: props.globals.initNode("/orientation/heading-deg",0.0,"DOUBLE"),
			FmsHeading	: props.globals.initNode("/autopilot/fms-channel/course-target-deg",0.0,"DOUBLE"),
		};
				
		canvas.parsesvg(m._group, "Models/instruments/IFDs/IFD_MovingMap.svg",{
			"font-mapper": global.canvas.FontMapper
			}
		);
		
		m._can = {
			plane		: m._group.getElementById("MovingMap_Plane").set("z-index",1),
			#plane		: m._group.getElementById("MovingMap_Plane"),
			LayerMap	: m._group.getElementById("layer5"),
			LayerFront	: m._group.getElementById("layer2").set("z-index",3),
			#LayerFront	: m._group.getElementById("layer2"),
			compass		: m._group.getElementById("MovingMap_Compass").set("z-index",1),
			#compass		: m._group.getElementById("MovingMap_Compass"),
			CompassRose	: m._group.getElementById("MovingMap_Compass_Rose").updateCenter(),
			CompassRangeMax	: m._group.getElementById("MovingMap_Range_Max"),
			CompassRangeMid	: m._group.getElementById("MovingMap_Range_Mid"),
			Warning		: m._group.getElementById("MovingMap_Warning").setVisible(0),
			warning1	: m._group.getElementById("MovingMap_Warning1"),
			warning2	: m._group.getElementById("MovingMap_Warning2"),
			HDGValue	: m._group.getElementById("MovingMap_HDG_Value"),
			UpHDG		: m._group.getElementById("MovingMap_Up_HDG"),
			UpHDGDeg	: m._group.getElementById("MovingMap_Up_HDG_DEG"),
			UpNorth		: m._group.getElementById("MovingMap_Up_North").setVisible(0),
			HDG		: m._group.getElementById("MovingMap_HDG"),
			BugHDG		: m._group.getElementById("MovingMap_Bug_HDG"),
			BugFMS		: m._group.getElementById("MovingMap_Bug_FMS"),
			BugTrue		: m._group.getElementById("MovingMap_Bug_TRUE").updateCenter(),
			
			CompassN	: m._group.getElementById("MovingMap_Compass_N"),
			Compass030	: m._group.getElementById("MovingMap_Compass_030"),
			Compass060	: m._group.getElementById("MovingMap_Compass_060"),
			CompassE	: m._group.getElementById("MovingMap_Compass_E"),
			Compass120	: m._group.getElementById("MovingMap_Compass_120"),
			Compass150	: m._group.getElementById("MovingMap_Compass_150"),
			CompassS	: m._group.getElementById("MovingMap_Compass_S"),
			Compass210	: m._group.getElementById("MovingMap_Compass_210"),
			Compass240	: m._group.getElementById("MovingMap_Compass_240"),
			CompassW	: m._group.getElementById("MovingMap_Compass_W"),
			Compass300	: m._group.getElementById("MovingMap_Compass_300"),
			Compass330	: m._group.getElementById("MovingMap_Compass_330"),
			
		};
		
		m._map = Map.new(m._can.LayerMap,name);
		


		m._map.setTranslation(1024,768);
		#m._can.LayerFront.setTranslation(-1024,-768);
		#m._can.layer1.setTranslation(-1024,-768);
		
# 		m._can.plane.setTranslation(1024,768);
		m._orientation	= 0;
		m._heading	= 0;
		m._headingTrue	= 0;
		m._bugHeading	= 0;
		m._bugFMS	= 0;
		m._lat		= 0;
		m._lon		= 0;
		m._upHdg	= 0;
		
		m._bugFMSactive = 0;
		m._modeHDG 	= 0;
		m._routeManagerActive 	= 0;
		m._fmsServiceable	= 0;
		
		m._layer 	= {};
		m._view 	= MAP_VIEW.HDG_UP_CENTER ;
		 
		#m._mapScale	= m._can.LayerMap.createTransform(); 
		m._mapTransform		= m._can.LayerMap.createTransform(); 
		m._mapTransformView	= m._can.LayerMap.createTransform(); 
		#m._mapTransform	= m._group.createTransform(); 
		
		return m;
	},
	init : func(){
		me.setListeners();
		me._layer.positioned	= PositionedLayer.new(me._map,me._name~"-Positioned");
		me._layer.route		= RouteLayer.new(me._map,me._name~"-Route");
		me._layer.route.setListeners();
		me._layer.tcas		= TcasLayer.new(me._map,me._name~"-TCAS");
		me._layer.tcas.setModel(me._layer.tcas,tcasModel);
		me._updateView();
	},
	setListeners : func(instance=me) {
		append(me._listeners, setlistener("/autopilot/settings/heading-bug-deg",func(n){me._onHdgBugChange(n)},1,0));	
		append(me._listeners, setlistener("/autopilot/fms-channel/course-target-deg",func(n){me._onFmsBugChange(n)},1,0));	
		append(me._listeners, setlistener("/autopilot/mode/heading",func(n){me._onAutopilotModeHDG(n)},1,0));
		append(me._listeners, setlistener("/autopilot/route-manager/active",func(n){me._onRouteActiveChange(n);},1,0));
		append(me._listeners, setlistener("/autopilot/fms-channel/serviceable",func(n){me._onFmsServiceChange(n);},1,0));
		append(me._listeners, setlistener(tcasModel._nObserver,func(n){me.onModelObserverNotify(n)},1,1));	
	
		
	},
	
	
	setRefPos : func(lat, lon) {
	# print("RefPos set");
		me._map._node.getNode("ref-lat", 1).setDoubleValue(lat);
		me._map._node.getNode("ref-lon", 1).setDoubleValue(lon);
		me._can.plane.setGeoPosition(lat,lon);
		me; # chainable
	},
	setHdg : func(deg){
		me._heading = deg;
		if(me._view == MAP_VIEW.NORTH_UP){ # North up
			me._orientation = 0;
		}else{
			me._orientation = me._heading;
		}
		me._map.setHdg(me._orientation);
	},
	setVisible : func(visibility){
		me._group.setVisible(visibility);
	},
	setLayout : func(layout){
		me._layout = layout;
		me._group.setVisible(0);
	
		if(me._layout == "map"){
			me._screenSize	= 512;
			me._group.set("clip","rect(70px, 2048px, 1436px, 0px)");
			
			me._mapTransform.setTranslation(0,0);
			me._mapTransform.setScale(1,1);
			
			me._can.HDG.setTranslation(0,0);
			me._can.Warning.setTranslation(-380,0);
			me._can.UpHDG.setTranslation(400,0);
			
			me._can.LayerFront.setVisible(1);
			me._group.set("z-index",-1);
			me._group.setVisible(1);
		}elsif(me._layout == "map+"){
			me._screenSize	= 512;
			me._group.set("clip","rect(70px, 1648px, 1436px, 400px)");
			
			me._mapTransform.setTranslation(0,0);
			me._mapTransform.setScale(1,1);
			
			me._can.HDG.setTranslation(0,0);
			me._can.Warning.setTranslation(0,0);
			me._can.UpHDG.setTranslation(0,0);
			
			
			me._can.LayerFront.setVisible(1);
			me._group.set("z-index",0);
			me._group.setVisible(1);
		}elsif(me._layout == "split-left"){
			
			me._screenSize	= 512;
			me._mapTransform.setTranslation(-256,192);
			me._mapTransform.setScale(0.75,0.75);
			me._group.set("clip","rect(70px, 1024px, 1436px, 0px)");
			
			me._can.HDG.setTranslation(-512,0);
			me._can.Warning.setTranslation(-380,0);
			me._can.UpHDG.setTranslation(-625,0);
			
			me._can.LayerFront.setVisible(1);
			me._group.set("z-index",0);
			me._group.setVisible(1);
		}elsif(me._layout == "pfd"){
			me._view = MAP_VIEW.HDG_UP_CENTER;
			
# 			me._screenSize	= 291;
# 			me.setTranslation(1024,1132);
# 			me._can.LayerFront.setTranslation(-1024,-1132);
# 			me._can.compass.setScale(0.568359375,0.568359375);
# 			#me._can.compass.setTranslation(255,71);
# 			me._can.layer1.setTranslation(-1024,-1132);
# 			me.set("clip","rect(842px, 1315px, 1429px, 732px)");
# 			me._parent.set("z-index",1);
# 			me._can.layer1.setVisible(1);
# 			me.setVisible(1);
			me._layer.positioned.setNav(0);
			me._screenSize	= 512;
# 			me._mapTransform.setTranslation(1024*0,43359375,768+364);
			me._mapTransform.setTranslation(1024*(1-0.56640625),696.5);
			me._mapTransform.setScale(0.56640625,0.56640625);
			me._group.set("clip","rect(842px, 1345px, 1429px, 702px)");
# 			me._group.set("clip","rect(70px, 2048px, 1436px, 0px)");
			
# 			me._can.HDG.setTranslation(-512,0);
# 			me._can.Warning.setTranslation(-380,0);
# 			me._can.UpHDG.setTranslation(-625,0);
			me._can.LayerFront.setVisible(0);
			me._group.set("z-index",1);
			me._group.setVisible(1);
			
		}else{
			
		}
		me._updateView();
			
		me._can.BugFMS.setVisible(me._bugFMSactive);
		
	},
	setView : func(view){
		if(me._layout != "pfd"){
			#print("MovingMap.setView("~view~") ... "~me._view);
			me._view = view;
			me._updateView();
		}
	},
	_updateView : func(){
		#print("MovingMap._updateView() ... ");
			
		if(me._view == MAP_VIEW.HDG_UP_CENTER){ # HDG up centered
			me._mapTransformView.setTranslation(0,0);
			me._can.UpNorth.setVisible(0);
		}elsif(me._view == MAP_VIEW.HDG_UP_FRONT){ # HDG up 
# 			me._mapTransformView.setTranslation(0,500 * (me._layout != "pfd"));
			me._mapTransformView.setTranslation(0,500);
			me._can.UpNorth.setVisible(0);
		}elsif(me._view == MAP_VIEW.NORTH_UP){ # North up
			me._mapTransformView.setTranslation(0,0);
			me._can.UpNorth.setVisible(1);
		}else{
			me._mapTransformView.setTranslation(0,0);
			me._can.UpNorth.setVisible(0);
		}
	},
	setLayerVisible : func(layer,v){
		me._layer[layer].setVisible(v);
	},
	setBugFMS : func(value){
		me._bugFMSactive = value;
		me._can.BugFMS.setVisible(me._bugFMSactive);
	},
	onModelObserverNotify : func(n){
		me.setRefPos(tcasModel._lat,tcasModel._lon);
		me.setHdg(tcasModel._hdg);
	},
	_onAutopilotModeHDG : func(n){
		me._modeHDG = n.getValue();
		if(me._modeHDG == 1){
			me._can.BugHDG.set("fill",COLOR["Magenta"]);
		}else{
			me._can.BugHDG.set("fill","none");
			
		}
	},
	_onRouteActiveChange : func(n){
		me._routeManagerActive = n.getValue();
		me._can.BugFMS.setVisible((me._fmsServiceable == 1) and (me._routeManagerActive == 1));
	},
	_onFmsServiceChange : func(n){
		me._fmsServiceable = n.getValue();
		me._can.BugFMS.setVisible((me._fmsServiceable == 1) and (me._routeManagerActive == 1));
		
	},
	_onHdgBugChange : func(n){
		me._bugHeading		= n.getValue();
		me._can.BugHDG.setRotation((me._bugHeading - me._orientation) * global.CONST.DEG2RAD);
	},
	_onFmsBugChange : func(n){
		me._bugFMS		= n.getValue();
		me._can.BugFMS.setRotation((me._bugFMS - me._orientation) * global.CONST.DEG2RAD);
	},
	setRangeNm : func(nm){
		var range = 200 / (me._screenSize / nm);
		me._map._node.getNode("range", 1).setDoubleValue(range);
		me._can.CompassRangeMax.setText(sprintf("%.0f",nm));
		me._can.CompassRangeMid.setText(sprintf("%.0f",nm/2));
		me._layer.positioned.setRange(nm);
	},
	update20Hz : func(now,dt){
		me._lat = getprop("/position/latitude-deg");
		me._lon = getprop("/position/longitude-deg");
		
		me._headingTrue 	= me._tree.HeadingTrue.getValue();
		#me._orientation 		= me._tree.Heading.getValue();
		me._orientationRAD		= me._orientation * global.CONST.DEG2RAD;
		
		me._upHdg	= me._orientation;
		
		#me.setRefPos(me._lat,me._lon);
		#me.setHdg(me._upHdg);
		
		me._can.plane.setRotation(me._heading * (me._view==MAP_VIEW.NORTH_UP) * global.CONST.DEG2RAD);
		
		me._can.HDGValue.setText(sprintf("%03i",global.roundInt(me._heading)));
		me._can.UpHDGDeg.setText(sprintf("%5.1f",me._upHdg));
		
		me._can.CompassRose.setRotation(-me._orientation * global.CONST.DEG2RAD);
		me._can.BugTrue.setRotation((me._headingTrue - me._orientation) * global.CONST.DEG2RAD);
		me._can.BugHDG.setRotation((me._bugHeading - me._orientation) * global.CONST.DEG2RAD);
		
		me._can.CompassN.setRotation(me._orientationRAD);
		me._can.Compass030.setRotation(me._orientationRAD);
		me._can.Compass060.setRotation(me._orientationRAD);
		me._can.CompassE.setRotation(me._orientationRAD);
		me._can.Compass120.setRotation(me._orientationRAD);
		me._can.Compass150.setRotation(me._orientationRAD);
		me._can.CompassS.setRotation(me._orientationRAD);
		me._can.Compass210.setRotation(me._orientationRAD);
		me._can.Compass240.setRotation(me._orientationRAD);
		me._can.CompassW.setRotation(me._orientationRAD);
		me._can.Compass300.setRotation(me._orientationRAD);
		me._can.Compass330.setRotation(me._orientationRAD);
		
		
		if(me._bugFMSactive == 1){
			me._can.BugFMS.setRotation((me._bugFMS - me._orientation) * global.CONST.DEG2RAD);
		}
		
		

	},
	
	setLand : func(value){me._layer.positioned.setLand(value);},
	setNav : func(value){me._layer.positioned.setNav(value);},
	setLightning : func(value){me._layer.positioned.setLightning(value);},
	setWxReports : func(value){me._layer.positioned.setWxReports(value);},
	setWxOverlay : func(value){me._layer.positioned.setWxOverlay(value);},
	
};


var MovingMapKnobWidget = {
	new: func(page,canvasGroup,name){
		var m = {parents:[MovingMapKnobWidget,IfdWidget.new(page,canvasGroup,name)]};
		m._class 	= "MovingMapKnobWidget";
		m._can		= {
		
		};
		m._range	= 4;
		m._view		= MAP_VIEW.HDG_UP_CENTER;
		m._hand 	= 0;
		return m;
	},
	init : func(instance=me){

	},
	deinit : func(){
		
	},
	setHand : func(hand){
		me._hand = hand;
	},
	setVisible : func(v){
		if(v == 1){
			if(me._hand == 0){
				me._Page.IFD.nLedLK.setValue(1);
				me._Page.IFD.setKnobLabel("LK","Range","View");
				
				me._Page.keys["LK >>"] 	= func(){me.adjustMapRange(2);};
				me._Page.keys["LK <<"] 	= func(){me.adjustMapRange(-2);};
				me._Page.keys["LK"] 	= func(){me.adjustMapView(1);};
				me._Page.keys["LK >"] 	= func(){me.adjustMapRange(1);};
				me._Page.keys["LK <"] 	= func(){me.adjustMapRange(-1);};
			}else{
				me._Page.IFD.nLedRK.setValue(1);
				me._Page.IFD.setKnobLabel("RK","Range","View");
				
				me._Page.keys["RK >>"] 	= func(){me.adjustMapRange(2);};
				me._Page.keys["RK <<"] 	= func(){me.adjustMapRange(-2);};
				me._Page.keys["RK"] 	= func(){me.adjustMapView(1);};
				me._Page.keys["RK >"] 	= func(){me.adjustMapRange(1);};
				me._Page.keys["RK <"] 	= func(){me.adjustMapRange(-1);};
			}
			me._Page.IFD.movingMap.setRangeNm(MAP_RANGE[me._range]);	
		}else{
			if(me._hand == 0){
				me._Page.IFD.nLedLK.setValue(0);
				me._Page.IFD.setKnobLabel("LK");
				
				me._Page.keys["LK >>"] 	= nil;
				me._Page.keys["LK <<"] 	= nil;
				me._Page.keys["LK"] 	= nil;
				me._Page.keys["LK >"] 	= nil;
				me._Page.keys["LK <"] 	= nil;
			}else{
				me._Page.IFD.nLedRK.setValue(0);
				me._Page.IFD.setKnobLabel("RK");
				
				me._Page.keys["RK >>"] 	= nil;
				me._Page.keys["RK <<"] 	= nil;
				me._Page.keys["RK"] 	= nil;
				me._Page.keys["RK >"] 	= nil;
				me._Page.keys["RK <"] 	= nil;
			}
		}
	},
	adjustMapRange : func(amount){
		me._range += amount;
		me._range = global.clamp(me._range,0,9);
		me._Page.IFD.movingMap.setRangeNm(MAP_RANGE[me._range]);
	},
	adjustMapView : func(amount){
		me._view = global.cycle(me._view,0,2,amount);
		me._Page.IFD.movingMap.setView(me._view);
	}
};