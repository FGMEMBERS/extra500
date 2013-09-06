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



