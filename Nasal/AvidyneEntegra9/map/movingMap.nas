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
# 			foreach(tcas;me._model._data){
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

var MovingMap = {
	new : func(ifd,parent,name){
		var m = {parents:[
			MovingMap,
			ListenerClass.new(),
			Map.new(parent,name)
		]};
		#debug.dump(m);
		m.IFD = ifd;
		m._tree	= {
			Heading		: props.globals.initNode("/instrumentation/heading-indicator-IFD-"~m.IFD.name~"/indicated-heading-deg",0.0,"DOUBLE"),
			HeadingTrue	: props.globals.initNode("/orientation/heading-deg",0.0,"DOUBLE"),
			FmsHeading	: props.globals.initNode("/autopilot/fms-channel/course-target-deg",0.0,"DOUBLE"),
		};
				
		canvas.parsesvg(m, "Models/instruments/IFDs/IFD_MovingMap.svg",{
			"font-mapper": global.canvas.FontMapper
			}
		);
		
		m._can = {
			plane		: m.createChild("group","plane"),
			LayerFront	: m.getElementById("layer2").set("z-index",3),
			compass		: m.getElementById("MovingMap_Compass"),
			CompassRose	: m.getElementById("MovingMap_Compass_Rose").updateCenter(),
			CompassRangeMax	: m.getElementById("MovingMap_Range_Max"),
			CompassRangeMid	: m.getElementById("MovingMap_Range_Mid"),
			Warning		: m.getElementById("MovingMap_Warning"),
			warning1	: m.getElementById("MovingMap_Warning1"),
			warning2	: m.getElementById("MovingMap_Warning2"),
			HDGValue	: m.getElementById("MovingMap_HDG_Value"),
			UpHDG		: m.getElementById("MovingMap_Up_HDG"),
			UpHDGDeg	: m.getElementById("MovingMap_Up_HDG_DEG"),
			UpNorth		: m.getElementById("MovingMap_Up_North").setVisible(0),
			BugHDG		: m.getElementById("MovingMap_Bug_HDG"),
			BugFMS		: m.getElementById("MovingMap_Bug_FMS"),
			BugTrue		: m.getElementById("MovingMap_Bug_TRUE").updateCenter(),
			layer1		: m.getElementById("layer1"),
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
		 
# 		m._can.plane.createChild("path", "x-Achis")
# 		 .setStrokeLineWidth(3)
#                  .setScale(1)
#                  .setColor("#40B250")
#                  .moveTo(-100, 0)
#                  .line(200, 0);
# 		 
# 		m._can.plane.createChild("path", "Y-Achis")
# 		 .setStrokeLineWidth(3)
#                  .setScale(1)
#                  .setColor("#40B250")
#                  .moveTo(0, -100)
#                  .line(0, 200);

		 
		 m._heading	= 0;
		 m._headingTrue	= 0;
		 m._bugHeading	= 0;
		 m._bugFMS	= 0;
		 m._lat		= 0;
		 m._lon		= 0;
		 m._upHdg	= 0;
		 
		 m._layer 	= {};
		 m._view 	= 0 ;
		return m;
	},
	setRefPos : func(lat, lon) {
	# print("RefPos set");
		me._node.getNode("ref-lat", 1).setDoubleValue(lat);
		me._node.getNode("ref-lon", 1).setDoubleValue(lon);
		me._can.plane.setGeoPosition(lat,lon);
		me; # chainable
	},
	setLayout : func(layout){
		me.setVisible(0);
			
		if(layout == "map"){
			me._screenSize	= 512;
			me.setTranslation(1024,768);
			me.set("clip","rect(70px, 2048px, 1436px, 0px)");
			me._can.Warning.setTranslation(-380,0);
			me._can.UpHDG.setTranslation(400,0);
			me._can.compass.setScale(1.0,1.0);
			me._can.compass.setTranslation(0,0);
			me._can.LayerFront.setTranslation(-1024,-768);
			me._can.layer1.setTranslation(-1024,-768);
			me._can.layer1.setVisible(1);
			me._parent.set("z-index",0);
			me.setVisible(1);
			
		}elsif(layout == "map+"){
			me._screenSize	= 512;
			me.setTranslation(1024,768);
			me.set("clip","rect(70px, 2048px, 1436px, 0px)");
			me._can.Warning.setTranslation(0,0);
			me._can.UpHDG.setTranslation(0,0);
			me._can.compass.setScale(1.0,1.0);
			me._can.compass.setTranslation(0,0);
			me._can.LayerFront.setTranslation(-1024,-768);
			me._can.layer1.setTranslation(-1024,-768);
			me._can.layer1.setVisible(1);
			me._parent.set("z-index",0);
			me.setVisible(1);
			
		}elsif(layout == "split-left"){
			me._screenSize	= 384;
			me.setTranslation(512,768);
			me.set("clip","rect(70px, 1024px, 1436px, 0px)");
			me._can.Warning.setTranslation(112,0);
			me._can.UpHDG.setTranslation(-112,0);
			me._can.compass.setScale(0.75,0.75);
			me._can.compass.setTranslation(255,71);
			me._can.LayerFront.setTranslation(-1024,-768);
			me._can.layer1.setTranslation(-1024,-768);
			me._can.layer1.setVisible(1);
			me._parent.set("z-index",0);
			me.setVisible(1);
			
		}elsif(layout == "pfd"){
			me._screenSize	= 291;
			me.setTranslation(1024,1132);
			me._can.LayerFront.setTranslation(-1024,-1132);
			me._can.layer1.setTranslation(-1024,-1132);
			me.set("clip","rect(842px, 1315px, 1429px, 732px)");
			me._parent.set("z-index",1);
			me._can.layer1.setVisible(0);
			me.setVisible(1);
			
		}else{
			
		}
	},
	setListeners : func(instance=me) {
		append(me._listeners, setlistener("/autopilot/settings/heading-bug-deg",func(n){me._onHdgBugChange(n)},1,0));	
		append(me._listeners, setlistener("/autopilot/fms-channel/course-target-deg",func(n){me._onFmsBugChange(n)},1,0));	
	},
	init : func(){
		me.setListeners();
		me._layer.route		= RouteLayer.new(me,me._name~"-Route");
		me._layer.route.setListeners();
		me._layer.tcas		 = TcasLayer.new(me,me._name~"-TCAS");
		me._layer.tcas.setModel(me._layer.tcas,tcasModel);
	},
	setView : func(view){
		me._view = view;
	},
	setLayerVisible : func(layer,v){
		me._layer[layer].setVisible(v);
	},
	onModelObserverNotify : func(n){
		
	},
	_onHdgBugChange : func(n){
		me._bugHeading		= n.getValue();
		me._can.BugHDG.setRotation((me._bugHeading - me._heading) * global.CONST.DEG2RAD);
	},
	_onFmsBugChange : func(n){
		me._bugFMS		= n.getValue();
		me._can.BugFMS.setRotation((me._bugFMS - me._heading) * global.CONST.DEG2RAD);
	},
	setRangeNm : func(nm){
		var range = 200 / (me._screenSize / nm);
		me._node.getNode("range", 1).setDoubleValue(range);
		me._can.CompassRangeMax.setText(sprintf("%.0f",nm));
		me._can.CompassRangeMid.setText(sprintf("%.0f",nm/2));
	
	},
	update20Hz : func(now,dt){
		me._lat = getprop("/position/latitude-deg");
		me._lon = getprop("/position/longitude-deg");
		
		me._headingTrue 	= me._tree.HeadingTrue.getValue();
		me._heading 		= me._tree.Heading.getValue();
		
		me._upHdg	= me._heading;
		
		me.setRefPos(me._lat,me._lon);
		me.setHdg(me._upHdg);
				
		me._can.HDGValue.setText(sprintf("%03i",me._heading));
		me._can.UpHDGDeg.setText(sprintf("%5.1f",me._upHdg));
		
		me._can.BugTrue.setRotation((me._headingTrue - me._heading) * global.CONST.DEG2RAD);
		me._can.BugHDG.setRotation((me._bugHeading - me._heading) * global.CONST.DEG2RAD);
		me._can.BugFMS.setRotation((me._bugFMS - me._heading) * global.CONST.DEG2RAD);
		me._can.CompassRose.setRotation(-me._heading * global.CONST.DEG2RAD);
		
	},
	
};


var MovingMapKnobWidget = {
	new: func(page,canvasGroup,name){
		var m = {parents:[MovingMapKnobWidget,IfdWidget.new(page,canvasGroup,name)]};
		m._class 	= "MovingMapKnobWidget";
		m._can		= {
		
		};
		m._range	= 30;
		m._view		= 0;
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
				me._Page.keys["LK >>"] 	= func(){me.adjustMapRange(5);};
				me._Page.keys["LK <<"] 	= func(){me.adjustMapRange(-5);};
				me._Page.keys["LK"] 	= func(){me.adjustMapView(1);};
				me._Page.keys["LK >"] 	= func(){me.adjustMapRange(1);};
				me._Page.keys["LK <"] 	= func(){me.adjustMapRange(-1);};
			}else{
				me._Page.IFD.nLedRK.setValue(1);
				me._Page.keys["RK >>"] 	= func(){me.adjustMapRange(5);};
				me._Page.keys["RK <<"] 	= func(){me.adjustMapRange(-5);};
				me._Page.keys["RK"] 	= func(){me.adjustMapView(1);};
				me._Page.keys["RK >"] 	= func(){me.adjustMapRange(1);};
				me._Page.keys["RK <"] 	= func(){me.adjustMapRange(-1);};
			}
			me._Page.IFD.movingMap.setRangeNm(me._range);	
		}else{
			if(me._hand == 0){
				me._Page.IFD.nLedLK.setValue(0);
				me._Page.keys["LK >>"] 	= nil;
				me._Page.keys["LK <<"] 	= nil;
				me._Page.keys["LK"] 	= nil;
				me._Page.keys["LK >"] 	= nil;
				me._Page.keys["LK <"] 	= nil;
			}else{
				me._Page.IFD.nLedRK.setValue(0);
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
		me._range = global.clamp(me._range,2,300);
		me._Page.IFD.movingMap.setRangeNm(me._range);
	},
	adjustMapView : func(amount){
		me._view = global.cycle(me._view,0,3,amount);
		me._Page.IFD.movingMap.setView(me._view);
	}
};