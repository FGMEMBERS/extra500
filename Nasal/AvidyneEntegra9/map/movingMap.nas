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

var RouteLayer = {
	new : func(group,id="none"){
		var m = {parents:[RouteLayer,Layer.new(group,id)] }; 
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

var MovingMap = {
	new : func(parent,name){
		var m = {parents:[
			MovingMap,
			ListenerClass.new(),
			Map.new(parent,name)
		]};
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
		 
		 m.tcasLayer = nil;
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
		if(layout == "map"){
			me.setTranslation(1024,768);
			me.set("clip","rect(70px, 2048px, 1436px, 0px)");
			me.setVisible(1);
		}elsif(layout == "split-left"){
			me.setTranslation(512,768);
			me.set("clip","rect(70px, 1024px, 1436px, 0px)");
			me.setVisible(1);
		}elsif(layout == "map+"){
			me.setTranslation(1024,768);
			me.set("clip","rect(70px, 2048px, 1436px, 0px)");
			me.setVisible(1);
		}else{
			me.setVisible(0);
		}
	},
	setListeners : func(instance=me) {
		#append(me._listeners, setlistener("/instrumentation/tcas/serviceable",func(n){me._onStateChange(n)},1,0));	
		#append(me._listeners, setlistener("/instrumentation/tcas/inputs/mode",func(n){me._onModeChange(n)},1,0));	
		#append(me._listeners, setlistener(tcasModel._nObserver,func(n){me.onModelObserverNotify(n)},1,1));	
		#append(me._listeners, setlistener(tcasModel._nRange,func(n){me.onRangeChange(n)},1,1));	
	},
	init : func(){
		me.setListeners();
		me._tcasLayer 	= TcasLayer.new(me,me._name~"-TCAS");
		me._tcasLayer.setModel(me._tcasLayer,tcasModel);
		me._routeLayer 	= RouteLayer.new(me,me._name~"-Route");
		me._routeLayer.setListeners();
	},
	
	onModelObserverNotify : func(n){
		
	},
	update20Hz : func(now,dt){
		me._lat = getprop("/position/latitude-deg");
		me._lon = getprop("/position/longitude-deg");
		me._hdg = getprop("/orientation/heading-deg");
		
		me.setRefPos(me._lat,me._lon);
		me.setHdg(me._hdg);
	},
	
};