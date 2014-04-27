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
		me._sourceRectMap[id].bound = me._group.getElementById(id).getTransformedBounds();
		
		# TODO ugly hack ? check for reason!
		var top 	= 512 - me._sourceRectMap[id].bound[3];
		var bottom 	= 512 - me._sourceRectMap[id].bound[1];
		
		me._sourceRectMap[id].bound[1] = top;
		me._sourceRectMap[id].bound[3] = bottom;
		
		me._sourceRectMap[id].size = [me._sourceRectMap[id].bound[2]-me._sourceRectMap[id].bound[0],me._sourceRectMap[id].bound[3]-me._sourceRectMap[id].bound[1]];
# 		debug.dump(me._sourceRectMap[id].bound);
# 		debug.dump(me._sourceRectMap[id].size);
		
		
	},
	getBounds : func(id){
		return me._sourceRectMap[id].bound;
	},
	getSize : func(id){
		return me._sourceRectMap[id].size;
	},
	boundIconToImage : func(id,image){
		if(!contains(me._sourceRectMap,id)){
			print("MapIconCache.boundIconToImage("~id~") ... no available.");
			id = "Airport_0001";
		}
		image.setSourceRect(me._sourceRectMap[id].bound[0],me._sourceRectMap[id].bound[1],me._sourceRectMap[id].bound[2],me._sourceRectMap[id].bound[3],0);
		image.setSize(me._sourceRectMap[id].size[0],me._sourceRectMap[id].size[1]);
		image.setTranslation(-me._sourceRectMap[id].size[0]/2,-me._sourceRectMap[id].size[1]/2);
	},
};


var mapIconCache = MapIconCache.new("Models/instruments/IFDs/IFD_MapIcons.svg");

mapIconCache.registerIcon("Icon_Test");
mapIconCache.registerIcon("Airport_0000");
mapIconCache.registerIcon("Airport_0001");
mapIconCache.registerIcon("Airport_0100");
mapIconCache.registerIcon("Airport_0101");
mapIconCache.registerIcon("Airport_0111");
mapIconCache.registerIcon("Airport_1000");
mapIconCache.registerIcon("Airport_1001");
mapIconCache.registerIcon("Airport_1100");
mapIconCache.registerIcon("Airport_1101");
mapIconCache.registerIcon("Airport_1111");
mapIconCache.registerIcon("Navaid_VOR");
mapIconCache.registerIcon("Navaid_DME");
mapIconCache.registerIcon("Navaid_Height");
mapIconCache.registerIcon("Navaid_Height2");

# var dlg = canvas.Window.new([512,512],"dialog");
# var my_canvas = dlg.setCanvas(mapIconCache._canvas);




var AirportItem = {
	new : func(id){
		var m = {parents:[AirportItem]};
		m._id = id;
		m._can = {
			"group" : nil,
			"label" : nil,
			"image" : nil,
			
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
				
		return me._can.group;
	},
	setData : func(apt,data=0){
		me._can.label.setText(apt.id);
		mapIconCache.boundIconToImage(data.icon,me._can.image);
# 		mapIconCache.boundIconToImage("Icon_Test",me._can.image);
		me._can.group.setGeoPosition(apt.lat, apt.lon);
	},
	setVisible : func(visibility){
		me._can.group.setVisible(visibility);
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
			land 		: 3,
			nav 		: 3,
			lightning 	: 0,
			reports		: 0,
			overlay		: 0,
		};
		
		m._range = 100;
		m._results = nil;
		m._timer = maketimer(600,m,PositionedLayer.update);
		
		return m;
	},
	createCaches : func (){
		positioned.findWithinRange(600,"airport");
		for (var i = me._cache.airport.index ; i < me._cache.airport.max ; i +=1){
			var item = AirportItem.new(me._cache.airport.index);
			item.create(me._can.airport);
			item.setVisible(0);
			append(me._cache.airport.data,item);
		}
		
		positioned.findWithinRange(150,"vor");
		for (var i = me._cache.vor.index ; i < me._cache.vor.max ; i +=1){
			var item = VorItem.new(me._cache.vor.index);
			item.create(me._can.vor);
			item.setVisible(0);
			append(me._cache.vor.data,item);
		}
	},
	setRange : func(range=100){
		me._range = range;
		me._timer.restart(me._range/(200/3600));
		me.update();
	},
	update : func(){
		me.loadAirport();
		me.loadVor();
	},
	
	setLand : func(value){
# 		print("PositionedLayer.setLand("~value~")");
	},
	setNav : func(value){
		me._mapOptions.nav = value; me.update();
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
		var results = positioned.findWithinRange(me._range*2.5,"airport");
		var item = nil;
		var runwayLength 	= 0;
		
		if(me._mapOptions.nav >= 3){
			runwayLength = MAP_RUNWAY_AT_RANGE[me._range];
		}elsif (me._mapOptions.nav >= 2){
			runwayLength = 3000;
		}else{
			runwayLength = -1;
		}
		
		var airportData = {
			"range"		: me._range > 30 ? 0 : 1,
			"approach"	:0,
			"size"		:0,
			"surface"	:0,
			"displayed"	:0,
			"icon"		:"",
		};
		
		if(runwayLength >= 0){
			foreach(var apt; results) {
				
				airportData.approach 	= 0;
				airportData.size	= 0;
				airportData.surface	= 0;
				airportData.displayed 	= 0;
				
				#debug.dump(apt);
				
				if (me._cache.airport.index >= me._cache.airport.max ){
					break;
				}
				
				var displayed = 0;
				var iconName 		= "";
				 
				
				if( apt.id == getprop("autopilot/route-manager/destination/airport") or apt.id == getprop("autopilot/route-manager/departure/airport")){
					
				}else{
					
					
					var aptInfo = airportinfo(apt.id);
					
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
						
						airportData.approach 	= runway.ils_frequency_mhz ? 1 : airportData.approach;
						airportData.size	 	= runway.length >= 3000 ? 1 : airportData.size;
						airportData.surface	 	= MAP_RUNWAY_SURFACE[runway.surface] ? 1 : airportData.surface;
						airportData.displayed 	= runway.length > runwayLength ? 1 : airportData.displayed;
						
# 						if (runway.length > runwayLength){
# 							airportData.displayed = 1;
# 							iconlength = runway.length >= 3000 ? 1 : 0; 
# 							
# 							if(runway.ils_frequency_mhz){
# 								#print ("ils_frequency_mhz : "~runway.ils_frequency_mhz);
# 								iconName ~= "Airport_"~ iconRange ~ "_IAP_" ~iconType~ MAP_RUNWAY_SURFACE[runway.surface];
# 							}else{
# 								iconName ~= "Airport_"~ iconRange ~ "_VAP_" ~iconType~ MAP_RUNWAY_SURFACE[runway.surface];
# 							}
# 							break;
# 						}
						
						
					}
					
					
					airportData.icon = "Airport_"~airportData.range~airportData.approach~airportData.size~airportData.surface;
					
				}
				
				if (airportData.displayed){
# 					print (apt.id ~ " "~ airportData.icon);
					if (size(me._cache.airport.data) > me._cache.airport.index){
						item = me._cache.airport.data[me._cache.airport.index];
						item.setData(apt,airportData);
					}else{
						item = AirportItem.new(me._cache.airport.index);
						item.create(me._can.airport);
						item.setData(apt,airportData);
						append(me._cache.airport.data,item);
					}
					item.setVisible(1);
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
		if(me._mapOptions.nav >= 1 and me._range <= 80){
			var range = me._range*2.0 <= 100 ? me._range*2.5 : 100 ;
			var results = positioned.findWithinRange(range,"vor");
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
