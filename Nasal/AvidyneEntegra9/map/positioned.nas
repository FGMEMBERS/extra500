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
#      Date: 17.04.2014
#
#      Last change:      Dirk Dittmann
#      Date:             27.04.2013
#

var MapIconCache = {
	new : func(svgFile){
		var m = { parents:[MapIconCache] };
		
		m._canvas = canvas.new( {
			"name": "MapIconCache",
			"size": [512, 512],
			"view": [512, 512],
			"mipmapping": 1
		});
		m._canvas.addPlacement( {"type": "ref"} );
		m._canvas.setColorBackground(1,1,1,0);
		m._group = m._canvas.createGroup("MapIcons");
		
		canvas.parsesvg(m._group, svgFile,{
			"font-mapper": global.canvas.FontMapper
			}
		);
		
		m._sourceRectMap = {};
		return m;
	},
	registerIcon : func(id){
		me._sourceRectMap[id] = {"bound":[],"size":[]};
		var element = me._group.getElementById(id);
		if(element != nil){
			me._sourceRectMap[id].bound = element.getTransformedBounds();
			
			
			# TODO ugly hack ? check for reason!
			var top 	= 512 - me._sourceRectMap[id].bound[3];
			var bottom 	= 512 - me._sourceRectMap[id].bound[1];
			
			me._sourceRectMap[id].bound[1] = top;
			me._sourceRectMap[id].bound[3] = bottom;
			
			me._sourceRectMap[id].size = [me._sourceRectMap[id].bound[2]-me._sourceRectMap[id].bound[0],me._sourceRectMap[id].bound[3]-me._sourceRectMap[id].bound[1]];
	# 		debug.dump(me._sourceRectMap[id].bound);
	# 		debug.dump(me._sourceRectMap[id].size);
		}else{
				print("MapIconCache.registerIcon("~id~") fail");
		}
		
	},
	getBounds : func(id){
		return me._sourceRectMap[id].bound;
	},
	getSize : func(id){
		return me._sourceRectMap[id].size;
	},
	boundIconToImage : func(id,image,center=1){
		if(!contains(me._sourceRectMap,id)){
# 			print("MapIconCache.boundIconToImage("~id~") ... no available.");
			id = "Airport_0001";
		}
		image.setSourceRect(me._sourceRectMap[id].bound[0],me._sourceRectMap[id].bound[1],me._sourceRectMap[id].bound[2],me._sourceRectMap[id].bound[3],0);
		image.setSize(me._sourceRectMap[id].size[0],me._sourceRectMap[id].size[1]);
		if(center){
			image.setTranslation(-me._sourceRectMap[id].size[0]/2,-me._sourceRectMap[id].size[1]/2);
		}
	},
};


var mapIconCache = MapIconCache.new("Models/instruments/IFDs/IFD_MapIcons.svg");

mapIconCache.registerIcon("Icon_Test");
mapIconCache.registerIcon("Airport_0000");
mapIconCache.registerIcon("Airport_0100");
mapIconCache.registerIcon("Airport_0010");
mapIconCache.registerIcon("Airport_0110");
mapIconCache.registerIcon("Airport_0011");
mapIconCache.registerIcon("Airport_0111");

mapIconCache.registerIcon("Airport_1000");
mapIconCache.registerIcon("Airport_1100");
mapIconCache.registerIcon("Airport_1010");
mapIconCache.registerIcon("Airport_1110");
mapIconCache.registerIcon("Airport_1011");
mapIconCache.registerIcon("Airport_1111");
mapIconCache.registerIcon("Navaid_VOR");
mapIconCache.registerIcon("Navaid_DME");
mapIconCache.registerIcon("Navaid_Height");
mapIconCache.registerIcon("Navaid_Height2");

# var dlg = canvas.Window.new([512,512],"dialog");
# var my_canvas = dlg.setCanvas(mapIconCache._canvas);


var PIXEL_PER_FEET = 50/3000;

var AirportItem = {
	new : func(id){
		var m = {parents:[AirportItem]};
		m._id = id;
		m._can = {
			"group" : nil,
			"label" : nil,
			"image" : nil,
			"layout": nil,
			"runway": [],
			
		};
		m._mapAirportIcon = {
			"near"		: 0,
			"surface"	: 0,
			"tower"		: 0,
			"center"	: 0,
			"displayed"	: 0,
			"icon"		: "",
		};
		return m;
	},
	create : func(group){
		me._can.group = group.createChild("group", "airport_" ~ me._id);
		me._can.image = me._can.group.createChild("image", "airport-image_" ~ me._id)
			.setFile(mapIconCache._canvas.getPath())
			.setSourceRect(0,0,0,0,0);
		me._can.label = me._can.group.createChild("text", "airport-label_" ~ me._id)
		.setDrawMode( canvas.Text.TEXT )
		.setTranslation(0,37)
		.setAlignment("center-bottom-baseline")
		.setFont("LiberationFonts/LiberationSans-Regular.ttf")
		.setFontSize(32);
		
		me._can.layout = group.createChild("group","airport_layout" ~ me._id);
		me._can.layoutIcon = group.createChild("group","airport_layout_Icon" ~ me._id);
				
		return me._can.group;
	},
	draw : func(apt,mapOptions){

		me._mapAirportIcon.near = mapOptions.range > 30 ? 0 : 1;
		me._mapAirportIcon.surface	= 0;
		me._mapAirportIcon.tower 	= 0;
		me._mapAirportIcon.center	= 0;
		me._mapAirportIcon.displayed 	= 0;
		
		
# 		if( apt.id == getprop("autopilot/route-manager/destination/airport") or apt.id == getprop("autopilot/route-manager/departure/airport")){
# 					
# 		}else{
			var aptInfo = airportinfo(apt.id);
					
			me._can.layout.removeAllChildren();
			me._can.layoutIcon.removeAllChildren();
# 			me._can.runway = [];
			
			me._mapAirportIcon.tower = (size(aptInfo.comms("tower")) > 0);
			me._mapAirportIcon.center = me._mapAirportIcon.tower and (size(aptInfo.comms("approach")) > 0);
			
			
			
			foreach(var rwy; keys(aptInfo.runways)){
				var runway = aptInfo.runways[rwy];
				
# 						print ("id : "~runway.id);
# 						print ("lat : "~runway.lat);
# 						print ("lon : "~runway.lon);
# 						print ("heading : "~runway.heading);
# 						print ("length : "~runway.length);
# 						print ("width : "~runway.width);
# 						print ("surface : "~runway.surface);
# 						print ("threshold : "~runway.threshold);
# 						print ("stopway : "~runway.stopway);
# 						if (runway.reciprocal){
# 							print ("reciprocal : "~runway.reciprocal);
# 						}
# 						if(runway.ils){
# 							print ("ils : "~runway.ils);
# 						}
				
				me._mapAirportIcon.surface	= MAP_RUNWAY_SURFACE[runway.surface] ? 1 : me._mapAirportIcon.surface;
				me._mapAirportIcon.displayed 	= runway.length > mapOptions.runwayLength ? 1 : me._mapAirportIcon.displayed;
						
				
				
				
				if (mapOptions.range <= 10){	# drawing real runways 
					#print("AirportItem.draw() real runways " ~ runway.id);
# 					var canRwy = {"heading":0,"can":nil};
# 					canRwy.heading = runway.heading;
					me._can.layout.createChild("path", "airport-runway-" ~ me._id ~"-"~runway.id)
						.setStrokeLineWidth(7)
						.setColor(1.0,1.0,1.0)
						.setColorFill(1.0, 1.0, 1.0)
						.setDataGeo([ 	
							canvas.Path.VG_MOVE_TO,
							canvas.Path.VG_LINE_TO,
							canvas.Path.VG_CLOSE_PATH 
						],[
							"N" ~ runway.lat, "E" ~ runway.lon,
							"N" ~ runway.reciprocal.lat, "E" ~ runway.reciprocal.lon,
						]);
# 					append(me._can.runway,canRwy);
					
				}elsif(mapOptions.range <= 30){		#draw icon runways
# 					var canRwy = {"heading":0,"can":nil};
# 					canRwy.heading = runway.heading;
					me._can.layoutIcon.setGeoPosition(apt.lat, apt.lon);
					me._can.layoutIcon.createChild("path", "airport-runway-" ~ me._id ~"-"~runway.id)
						.setStrokeLineWidth(7)
						.setColor(1.0,1.0,1.0)
						.setColorFill(1.0, 1.0, 1.0)
						.setData([ 	
							canvas.Path.VG_MOVE_TO,
							canvas.Path.VG_LINE_TO,
							canvas.Path.VG_CLOSE_PATH 
						],[
							0,-20,
							0,20
						])
						.setRotation((runway.heading)* global.CONST.DEG2RAD)
						;
					#canRwy.can.setGeoPosition(apt.lat, apt.lon);
# 					append(me._can.runway,canRwy);
					#me._can.layout.updateCenter();
				}
					
			}
			
			me._mapAirportIcon.icon = "Airport_"~me._mapAirportIcon.near~me._mapAirportIcon.surface~me._mapAirportIcon.tower~me._mapAirportIcon.center;
					
			
			if (me._mapAirportIcon.displayed){
				me._can.label.setText(apt.id);
				me._can.group.setGeoPosition(apt.lat, apt.lon);
				if(mapOptions.range <= 10){
					me._can.image.setVisible(0);
					me._can.layout.setVisible(1);
				}elsif(mapOptions.range <= 30){
					mapIconCache.boundIconToImage(me._mapAirportIcon.icon,me._can.image);
					me._can.image.setVisible(1);
					me._can.layout.setVisible(1);
				}else{
					mapIconCache.boundIconToImage(me._mapAirportIcon.icon,me._can.image);
					me._can.layout.setVisible(0);
					me._can.image.setVisible(1);
					
					
				}
				me._can.group.setVisible(1);
				
				
			}
# 		}
		return me._mapAirportIcon.displayed;
	},
	update : func(mapOptions){
			
		if(mapOptions.range <= 10){
			
		}elsif(mapOptions.range <= 30){
			me._can.layoutIcon.setRotation(-mapOptions.orientation * global.CONST.DEG2RAD);
# 			forindex(var i ; me._can.runway){
# 				me._can.runway[i].can.setRotation((me._can.runway[i].heading - mapOptions.orientation )* global.CONST.DEG2RAD);
# 			}
		}else{
							
		}
			
	},
	setData : func(apt,data=0){
		me._can.label.setText(apt.id);
		mapIconCache.boundIconToImage(data.icon,me._can.image);
# 		mapIconCache.boundIconToImage("Icon_Test",me._can.image);
		me._can.group.setGeoPosition(apt.lat, apt.lon);
	},
	setVisible : func(visibility){
		me._can.group.setVisible(visibility);
		me._can.layout.setVisible(visibility);
	},
	getGroup : func(){
		return me._can.group;
	},
	
};
var VorItem = {
	new : func(id){
		var m = {parents:[VorItem]};
		m._id = id;
		m._can = {
			"group" : nil,
			"label" : nil,
			"image" : nil,
			
		};
		return m;
	},
	create : func(group){	
		me._can.group = group.createChild("group", "vor_" ~ me._id);
		

		me._can.image = me._can.group.createChild("image", "vor-image_" ~ me._id)
			.setFile(mapIconCache._canvas.getPath())
			.setSourceRect(0,0,0,0,0);
	
			
		me._can.label = me._can.group.createChild("text", "vor-label_" ~ me._id)
		.setDrawMode( canvas.Text.TEXT )
		.setTranslation(0,42)
		.setAlignment("center-bottom-baseline")
		.setFont("LiberationFonts/LiberationSans-Regular.ttf")
		.setFontSize(32);
		
		me._can.label.set('fill',"#BACBFB");
		me._can.label.set('stroke',"#000000");
				
		return me._can.group;
	},
	setData : func(vor){
		mapIconCache.boundIconToImage("Navaid_VOR",me._can.image);
		me._can.label.setText(vor.id);
		me._can.group.setGeoPosition(vor.lat, vor.lon);
	},
	setVisible : func(visibility){
		me._can.group.setVisible(visibility);
		
	},
	getGroup : func(){
		return me._can.group;
	},
	
};
var MAP_RUNWAY_AT_RANGE = {2:0,4:0,10:0,20:0,30:0,40:250,50:500,80:1000,160:2000,240:3000};
var MAP_RUNWAY_SURFACE = {0:0,1:1,2:1,3:0,4:0,5:0,6:1,7:1,8:0,9:0,10:0,11:0,12:0};

var PositionedLayer = {
	new : func(group,id="none"){
		var m = {parents:[
				PositionedLayer,
				Layer.new(group,id)
				 ]};
				 
		m._can = { 
			"airport" 	: m._group.createChild("group","airport"),
			"vor" 		: m._group.createChild("group","vor"),
			
		};
		
		m._cache = {
			"airport" : {"data":[],"index":0,"max":100},
			"vor"	  : {"data":[],"index":0,"max":100},
		};
		m._mapOptions = {
			declutterLand 	: 3,
			declutterNAV 	: 3,
			lightning 	: 0,
			reports		: 0,
			overlay		: 0,
			range		: 30,
			runwayLength    : -1,
			orientation	: 0,
		};

		
		m._results = nil;
		m._timer = maketimer(600,m,PositionedLayer.update);
		
		return m;
	},
	createCaches : func (){
# 		positioned.findWithinRange(600,"airport");
# 		for (var i = me._cache.airport.index ; i < me._cache.airport.max ; i +=1){
# 			var item = AirportItem.new(me._cache.airport.index);
# 			item.create(me._can.airport);
# 			item.setVisible(0);
# 			append(me._cache.airport.data,item);
# 			me._cache.airport.index += 1;
# 		}
		
# 		positioned.findWithinRange(150,"vor");
# 		for (var i = me._cache.vor.index ; i < me._cache.vor.max ; i +=1){
# 			var item = VorItem.new(me._cache.vor.index);
# 			item.create(me._can.vor);
# 			item.setVisible(0);
# 			append(me._cache.vor.data,item);
# 			me._cache.vor.index += 1;
# 		}
	},
	update : func(){
		if(me._visibility == 1){
# 			print ("PositionedLayer.update() ...") ;
			me.loadAirport();
			me.loadVor();
		}
		me._timer.restart(me._mapOptions.range/(220/3600));
	},
	_onVisibilityChange : func(){
		me._group.setVisible(me._visibility);
	},
	setMapOptions : func(mapOptions){
		me._mapOptions = mapOptions;
		me.update();
	},
	
	updateOrientation : func(value){
		me._mapOptions.orientation = value;
		for (var i = 0 ; i < me._cache.airport.index ; i +=1){
			item = me._cache.airport.data[i];
			item.update(me._mapOptions);
		}
	},
	setRange : func(range=100){
		me._mapOptions.range = range;
		me.update();
	},
	setLand : func(value){
# 		print("PositionedLayer.setLand("~value~")");
	},
	setNav : func(value){
		me._mapOptions.declutterNAV = value; 
		me.update();
	},
	setLightning : func(value){
# 		print("PositionedLayer.setLightning("~value~")");
	},
	setWxReports : func(value){
# 		print("PositionedLayer.setWxReports("~value~")");
	},
	setWxOverlay : func(value){
# 		print("PositionedLayer.setOverlay("~value~")");
	},
	
	loadAirport : func(){
		me._cache.airport.index = 0;
		var results = positioned.findWithinRange(me._mapOptions.range*2.5,"airport");
		var item = nil;
		
		if(me._mapOptions.declutterNAV >= 3){
			me._mapOptions.runwayLength = MAP_RUNWAY_AT_RANGE[me._mapOptions.range];
		}elsif (me._mapOptions.declutterNAV >= 2){
			me._mapOptions.runwayLength = 3000;
		}else{
			me._mapOptions.runwayLength = -1;
		}
		
				
		if(me._mapOptions.runwayLength >= 0){
			foreach(var apt; results) {
				
				if (me._cache.airport.index >= me._cache.airport.max ){
					break;
				}
								
				if (size(me._cache.airport.data) > me._cache.airport.index){
					item = me._cache.airport.data[me._cache.airport.index];
				}else{
					item = AirportItem.new(me._cache.airport.index);
					item.create(me._can.airport);
					append(me._cache.airport.data,item);
				}
				
				if(item.draw(apt,me._mapOptions)){
					me._cache.airport.index += 1;
				}
			}
		}
		
		for (var i = me._cache.airport.index ; i < size(me._cache.airport.data) ; i +=1){
			item = me._cache.airport.data[i];
			item.setVisible(0);
		}
# 		print ("");
	},
	loadVor : func(){
		me._cache.vor.index = 0;
		if(me._mapOptions.declutterNAV >= 1){
			var range = me._mapOptions.range*2.0 <= 100 ? me._mapOptions.range*2.5 : 100 ;
			var results = positioned.findWithinRange(me._mapOptions.range*2.5,"vor");
			var item = nil;
			foreach(var vor; results) {
				if (me._cache.vor.index >= me._cache.vor.max ){
					break;
				}
				
				if (size(me._cache.vor.data) > me._cache.vor.index){
					item = me._cache.vor.data[me._cache.vor.index];
					item.setData(vor);
				}else{
					item = VorItem.new(me._cache.vor.index);
					item.create(me._can.vor);
					item.setData(vor);
					append(me._cache.vor.data,item);
				}
				item.setVisible(1);
				me._cache.vor.index += 1;
			}
		}
		for (var i = me._cache.vor.index ; i < size(me._cache.vor.data) ; i +=1){
			item = me._cache.vor.data[i];
			item.setVisible(0);
		}
	},
	
};
