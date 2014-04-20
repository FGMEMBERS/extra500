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
#      Date:             17.04.2013
#

var AirportItem = {
	new : func(id){
		var m = {parents:[AirportItem]};
		m._id = id;
		m._can = {
			"group" : nil,
			"label" : nil,
			"icon" 	: nil,
		};
		return m;
	},
	create : func(group){
		me._can.group = group.createChild("group", "airport_" ~ me._id);
		
		me._can.icon = me._can.group.createChild("path", "airport-icon_" ~ me._id)
		.moveTo(-15,0)
		.lineTo(0,15)
		.lineTo(15,0)
		.lineTo(0,-15)
		.close()
		.setStrokeLineWidth(3);
	
		me._can.label = me._can.group.createChild("text", "airport-label_" ~ me._id)
		.setDrawMode( canvas.Text.TEXT )
		.setTranslation(0,37)
		.setAlignment("center-bottom-baseline")
		.setFont("LiberationFonts/LiberationSans-Regular.ttf")
		.setFontSize(32);
				
		return me._can.group;
	},
	setData : func(apt,type=0){
		me._can.label.setText(apt.id);
		if(type){
			me._can.icon.set('fill',"#018AFC");
			me._can.icon.set('stroke',"#018AFC");
			me._can.label.set('fill',"#BACBFB");
			me._can.label.set('stroke',"#000000");
		}else{
			me._can.icon.set('fill',"#E0A5FF");
			me._can.icon.set('stroke',"#E0A5FF");
			me._can.label.set('fill',"#DBD7FF");
			me._can.label.set('stroke',"#000000");
		}
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
			"icon" 	: nil,
		};
		return m;
	},
	create : func(group){
		me._can.group = group.createChild("group", "vor_" ~ me._id);
		
		me._can.icon = me._can.group.createChild("path", "vor-icon_" ~ me._id)
			.moveTo(-15,0)
			.lineTo(-7.5,12.5)
			.lineTo(7.5,12.5)
			.lineTo(15,0)
			.lineTo(7.5,-12.5)
			.lineTo(-7.5,-12.5)
			.close()
			.moveTo(-1,-1)
			.quad(0,0,2,2)
			.close()
			.setStrokeLineWidth(3)
			.setColor(0,0.6,0.85);
			
		me._can.icon.set('fill',"none");
		me._can.icon.set('stroke',"#018AFC");
			
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
			"airport" : {"data":[],"index":0},
			"vor"	  : {"data":[],"index":0},
		};
		m._var = {
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
		me._var.nav = value; me.update();
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
		var runwayLength = 0;
		
		if(me._var.nav >= 3){
			runwayLength = MAP_RUNWAY_AT_RANGE[me._range];
		}elsif (me._var.nav >= 2){
			runwayLength = 3000;
		}else{
			runwayLength = -1;
		}
		if(runwayLength >= 0){
			foreach(var apt; results) {
				#debug.dump(apt);
				
				if (me._cache.airport.index >= 100 ){
					break;
				}
				
				var displayed = 0;
				var type = 0;
				
				if( apt.id == getprop("autopilot/route-manager/destination/airport") 
				or apt.id == getprop("autopilot/route-manager/departure/airport")){
					displayed = 0;
				}else{
					
					
					var aptInfo = airportinfo(apt.id);
					foreach(var rwy; keys(aptInfo.runways)){
						if (aptInfo.runways[rwy].length > runwayLength){
							displayed = 1;
							type = aptInfo.runways[rwy].length >= 3000 ? 1 : 0; 
							break;
						}
					} 
					
				}
				
				if (displayed){
					
					if (size(me._cache.airport.data) > me._cache.airport.index){
						item = me._cache.airport.data[me._cache.airport.index];
						item.setData(apt,type);
					}else{
						item = AirportItem.new(me._cache.airport.index);
						item.create(me._can.airport);
						item.setData(apt,type);
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
	},
	loadVor : func(){
		me._cache.vor.index = 0;
		if(me._var.nav >= 1){
			var range = me._range*2.0 <= 100 ? me._range*2.5 : 100 ;
			var results = positioned.findWithinRange(range,"vor");
			var item = nil;
			foreach(var vor; results) {
				if (me._cache.vor.index >= 100 ){
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
