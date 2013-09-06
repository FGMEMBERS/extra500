var TcasMap = {
	new : func(parent,name){
		var m = {parents:[TcasMap,parent.createChild("map",name)]};
		#debug.dump(m);
		return m;
	},
	setRefPos : func(lat, lon) {
	# print("RefPos set");
		me._node.getNode("ref-lat", 1).setDoubleValue(lat);
		me._node.getNode("ref-lon", 1).setDoubleValue(lon);
		me; # chainable
	},
	setHdg : func(hdg) { 
		me._node.getNode("hdg",1).setDoubleValue(hdg); 
		me; # chainable
	},
	setZoom : func(zoom){
		me._node.getNode("range", 1).setDoubleValue(zoom);
	},
}



