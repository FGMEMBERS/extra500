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

var Map = {
	new : func(parent,name){
		var m = {parents:[Map,parent.createChild("map",name)]};
		m._parent = parent;
		m._name = name;
		m.RANGENM	= 1.6;
		m.RANGENM	= 1.852;
		m.RANGENM	= 1.852;
		m._screenSize	= 200;
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
	setScreenSize : func(pixel){
		me._screenSize	= pixel;
	},
	setRangeNm : func(nm){
		var range = 200 / (me._screenSize / nm);
		me._node.getNode("range", 1).setDoubleValue(range);
	},
};

var PlaneMap = {
	new : func(parent,name){
		var m = {parents:[PlaneMap,Map.new(parent,name)]};
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
	
};

var Layer = {
	new : func(group,id="none"){
		var m = {parents:[Layer] }; 
		m._id 			= id;
		m._model 		= nil;
		m._group 		= group.createChild("group",id);
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
	setVisible : func(v){
		me._group.setVisible(v);
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