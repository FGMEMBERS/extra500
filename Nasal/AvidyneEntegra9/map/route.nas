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
#      Date: Sep 14 2013
#
#      Last change:      Dirk Dittmann
#      Date:             14.09.2013
#


var RouteItemClass = {
	new : func(canvasGroup,index){
		var m = {parents:[RouteItemClass]};
		m._index = index;
		m._group = canvasGroup.createChild("group", "Waypoint_"~index).setVisible(0);
		m._groupTrack = canvasGroup.createChild("group", "Waypoint_Track"~index).setVisible(0);
		
		m._can = {
			Waypoint : m._group.createChild("path","icon")
				.setStrokeLineWidth(3)
				.setScale(1)
				.setColor("#FFFFFF")
				.setColorFill("#FFFFFF")
				.moveTo(-20, 0)
				.lineTo(-5, 5)
				.lineTo(0, 20)
				.lineTo(5, 5)
				.lineTo(20, 0)
				.lineTo(5, -5)
				.lineTo(0, -20)
				.lineTo(-5, -5)
				.close(),
			Label : m._group.createChild("text", "wptLabel-" ~ index)
				.setFont("LiberationFonts/LiberationMono-Bold.ttf")
				.setTranslation(25,-25)
				.setFontSize(32, 1)
				.setColor("#FFFFFF")
				.setColorFill("#FFFFFF")
				,
			track : m._groupTrack.createChild("path","track")
				.setStrokeLineWidth(3)
				.setScale(1)
				.setColor("#FFFFFF")
			,
		};
		 return m;
	},
	setVisible : func(v){
		me._group.setVisible(v);
		me._groupTrack.setVisible(v);
	},
	draw : func(wpt){
		me._group.setGeoPosition(wpt.lat,wpt.lon);
		me._can.Label.setText(wpt.name);
		me.setColor("#FFFFFF");
		me._group.setVisible(1);
	},
	drawTrack : func(wpt){
		var cmds = [];
		var coords = [];
		var cmd = canvas.Path.VG_MOVE_TO;
		print(sprintf("RouteItemClass::drawTrack() ... [%i] %s \t : %i",
				me._index,
				wpt.name,
				size(wpt.path)
			     ));
		
		foreach (var pt; wpt.path) {
			append(coords,"N"~pt.lat);
			append(coords,"E"~pt.lon);
			append(cmds,cmd);
			cmd = canvas.Path.VG_LINE_TO;
		}
		me._can.track.setDataGeo(cmds,coords);
		me._groupTrack.setVisible(1);
		
	},
	
	setColor : func(color){
		me._can.Label.setColor(color).setColorFill(color);
		me._can.Waypoint.setColor(color).setColorFill(color);
	}
	
};

var FMSIcon = {
	new : func(canvasGroup,text){
		var m = {parents:[FMSIcon]};
		m._group = canvasGroup.createChild("group", "FMS-"~text).setVisible(0);	
		m._can = {
			icon : m._group.createChild("path","FMS-icon" ~ text)
				.setStrokeLineWidth(3)
				.setScale(1)
				.setColor("#00FF00")
				.setColorFill("#00FF00")
				.moveTo(-15, 0)
				.lineTo(0, 15)
				.lineTo(15, 0)
				.lineTo(0, -15)
				.close()
			,
			label : m._group.createChild("text", "FMS-label-" ~ text)
				.setFont("LiberationFonts/LiberationMono-Bold.ttf")
				.setTranslation(20,12)
				.setFontSize(32, 1)
				.setColor("#00FF00")
				.setColorFill("#00FF00")
				.setText(text)
			,
			
			
		};
		return m;
	},
	setVisible : func(v){me._group.setVisible(v);},
	setGeoPosition : func(lat,lon){me._group.setGeoPosition(lat,lon);},
};
var FMSIconRTA = {
	new : func(canvasGroup,text){
		var m = {parents:[FMSIconRTA]};
		m._group = canvasGroup.createChild("group", "FMS-"~text).setVisible(0);	
		m._can = {
			icon : m._group.createChild("path","FMS-icon" ~ text)
				.setStrokeLineWidth(3)
				.setScale(1)
				.setColor("#00FF00")
				.setColorFill("#00FF00")
				.moveTo(-15, 0)
				.lineTo(0, 15)
				.lineTo(15, 0)
				.lineTo(0, -15)
				.close()
			,
			label : m._group.createChild("text", "FMS-label-" ~ text)
				.setFont("LiberationFonts/LiberationMono-Bold.ttf")
				.setTranslation(-80,12)
				.setFontSize(32, 1)
				.setColor("#00FF00")
				.setColorFill("#00FF00")
				.setText(text)
			,
		};
		return m;
	},
	setVisible : func(v){me._group.setVisible(v);},
	setGeoPosition : func(lat,lon){me._group.setGeoPosition(lat,lon);},
};
var RouteLayer = {
	new : func(group,id="none"){
		var m = {parents:[
			RouteLayer,
			Layer.new(group,id),
			ListenerClass.new()
		]}; 
		m._item 	= [];
		m._itemIndex	= 0;
		m._itemCount	= 0;
		m._groupTrack	= m._group.createChild("group",id~"_Track").setVisible(1);
		m._groupOBS	= m._group.createChild("group",id~"_OBS").setVisible(0);
		m._groupFMS	= m._group.createChild("group",id~"_FMS");
		
		m._can = {
			track : m._group.createChild("path","track")
				.setStrokeLineWidth(3)
				.setScale(1)
				.setColor("#FFFFFF"),
			currentLeg : m._groupFMS.createChild("path","currentLeg")
				.setStrokeLineWidth(5)
				.setScale(1)
				.setColor("#FF0EEB"),
			nextLeg : m._groupFMS.createChild("path","nextLeg")
				.setStrokeLineWidth(5)
				.setScale(1)
				.setStrokeDashArray([25,25])
				.setColor("#FF0EEB"),
			obsCourse : m._groupOBS.createChild("path","obsCourse")
				.setStrokeLineWidth(5)
				.setScale(1)
				.setColor("#FF0EEB"),
				
			
# 			"TOD" : m._groupFMS.createChild("image", "imgTOD")
# 				.setFile(mapIconCache._canvas.getPath())
# 				.setSourceRect(0,0,0,0,0)
# 				.setTranslation(-15,-15),
# 			"TOC" : m._groupFMS.createChild("image", "imgTOC")
# 				.setFile(mapIconCache._canvas.getPath())
# 				.setSourceRect(0,0,0,0,0)
# 				.setTranslation(-15,-15),
			
		};
		
		
# 			var imgTOD = m._can.TOD.createChild("image", "imgTOD")
# 				.setFile(mapIconCache._canvas.getPath())
# 				.setSourceRect(0,0,0,0,0)
# 				.setTranslation(-15,-15);
# 			
# 			var imgTOC = m._can.TOD.createChild("image", "imgTOC")
# 				.setFile(mapIconCache._canvas.getPath())
# 				.setSourceRect(0,0,0,0,0)
# 				.setTranslation(-15,-15);
				
# 			mapIconCache.boundIconToImage("FMS_TOD",m._can.TOD,0);
# 			mapIconCache.boundIconToImage("FMS_TOC",m._can.TOC,0);
# 		
		m._TOD = FMSIcon.new(m._groupFMS,"TOD");
		m._TOC = FMSIcon.new(m._groupFMS,"TOC");
		m._RTA = FMSIconRTA.new(m._groupFMS,"RTA");
		
		m._track = {cmds:[],coords:[]};
		m._currentLeg = {cmds:[canvas.Path.VG_MOVE_TO,canvas.Path.VG_LINE_TO],coords:[0,0,0,0]};
		m._nextLeg = {cmds:[canvas.Path.VG_MOVE_TO,canvas.Path.VG_LINE_TO],coords:[0,0,0,0]};
		
		
		m._mapOptions = {
			orientation	: 0,
		};
		
		
		m._obsMode = 0;
		m._obsCourse = 0;
		m._obsWaypoint = RouteItemClass.new(m._groupOBS,"obs_wp");
		m._obsCourseData = {cmds:[canvas.Path.VG_MOVE_TO,canvas.Path.VG_LINE_TO],coords:[0,0,0,0]};
		
		return m;
	},
	setListeners : func(){
			append(me._listeners, setlistener(fms._signal.fplChange,func(n){me._onFlightPlanChange(n)},1,1));	
			append(me._listeners, setlistener(fms._signal.currentWpChange,func(n){me._onCurrentWaypointChange(n)},1,1));
		
			append(me._listeners, setlistener(fms._signal.fplReady,func(n){me._onFplReadyChange(n)},1,0));	
			append(me._listeners, setlistener(fms._signal.fplUpdated,func(n){me._onFplUpdatedChange(n)},0,1));	
			
			append(me._listeners, setlistener(fms._node.ObsMode,func(n){me._onObsModeChange(n);},1,0) );
			append(me._listeners, setlistener("/autopilot/fms-channel/obs/desired-course-deg",func(n){me._onObsCourseChange(n);},1,0) );
			
			
	},
	updateOrientation : func(value){
		me._mapOptions.orientation = value;
		me._can.obsCourse.setRotation((me._obsCourse - me._mapOptions.orientation) * global.CONST.DEG2RAD);
	},
	
	_onFlightPlanChange : func(n){
		me._drawWaypoints();
		me._drawLegs();
	},
	_onCurrentWaypointChange : func(n){
		me._currentWpIndex = n.getValue();
		me._drawLegs();
	},
	_onVisibilityChange : func(){
		me._group.setVisible(me._visibility and (me._obsMode == 0));
		me._groupTrack.setVisible(me._visibility and (me._obsMode == 0));
		me._groupFMS.setVisible(me._visibility and (me._obsMode == 0));
		me._groupOBS.setVisible(me._visibility and (me._obsMode == 1));
		me._TOD.setVisible(fms._dynamicPoint.TOD.visible and me._visibility);
		me._TOC.setVisible(fms._dynamicPoint.TOC.visible and me._visibility);
		me._RTA.setVisible(fms._dynamicPoint.RTA.visible and me._visibility);
	},
	_onFplReadyChange : func(n){
		me._TOD.setVisible(fms._dynamicPoint.TOD.visible and me._visibility);
		me._TOC.setVisible(fms._dynamicPoint.TOC.visible and me._visibility);
		me._RTA.setVisible(fms._dynamicPoint.RTA.visible and me._visibility);
	},
	_onFplUpdatedChange : func(n){
		if(fms._dynamicPoint.TOD.visible){
			me._TOD.setGeoPosition(fms._dynamicPoint.TOD.position.lat,fms._dynamicPoint.TOD.position.lon);
		}
		if(fms._dynamicPoint.TOC.visible){
			me._TOC.setGeoPosition(fms._dynamicPoint.TOC.position.lat,fms._dynamicPoint.TOC.position.lon);
		}
		if(fms._dynamicPoint.RTA.visible){
			me._RTA.setGeoPosition(fms._dynamicPoint.RTA.position.lat,fms._dynamicPoint.RTA.position.lon);	
		}
		
		me._TOD.setVisible(fms._dynamicPoint.TOD.visible and me._visibility);
		me._TOC.setVisible(fms._dynamicPoint.TOC.visible and me._visibility);
		me._RTA.setVisible(fms._dynamicPoint.RTA.visible and me._visibility);
	
	},
	_onObsModeChange : func(n){
		me._obsMode = n.getValue();
		
		
		if(me._obsMode==1){
			var wp = {
				wp_lat : getprop("/instrumentation/gps[0]/scratch/latitude-deg"),
				wp_lon : getprop("/instrumentation/gps[0]/scratch/longitude-deg"),
				wp_name : getprop("/instrumentation/gps[0]/scratch/ident"),
			};
			var acLat = getprop("/position/latitude-deg");
			var acLon = getprop("/position/longitude-deg");
			
			
# 		me._groupOBS._node.getNode("ref-lat", 1).setDoubleValue(wp.wp_lat);
# 		me._groupOBS._node.getNode("ref-lon", 1).setDoubleValue(wp.wp_lon);
			me._groupOBS.setGeoPosition(wp.wp_lat,wp.wp_lon);
			
# 			me._obsCourseData.coords = [
# 				"N"~wp.wp_lat,
# 				"E"~wp.wp_lon,
# 				"N"~acLat,
# 				"E"~acLon,
# 			];
			
			me._obsCourseData.coords = [
				0,
				0,
				0,
				5000,
			];
			
			me._obsWaypoint._can.Label.setText(wp.wp_name);
			me._obsWaypoint.setColor("#FF0EEB");
			me._obsWaypoint._group.setVisible(1);
			
			me._can.obsCourse.setData(me._obsCourseData.cmds,me._obsCourseData.coords);
# 			me._can.obsCourse.setDataGeo(me._obsCourseData.cmds,me._obsCourseData.coords);
# 			me._can.obsCourse.updateCenter();
# 			me._can.obsCourse._node.getNode("center[0]",1).setDoubleValue(0);
# 			me._can.obsCourse._node.getNode("center[1]",1).setDoubleValue(0);
# 			
# 			me._can.obsCourse.setCenter(me._can.obsCourse.get("coord[2]"),me._can.obsCourse.get("coord[3]"));
			#me._can.obsCourse.setCenter(149,-268);
			
		}
		
		me._groupTrack.setVisible(me._visibility and (me._obsMode == 0));
		me._groupFMS.setVisible(me._visibility and (me._obsMode == 0));
		me._groupOBS.setVisible(me._visibility and (me._obsMode == 1));
	},
	_onObsCourseChange : func(n){
		me._obsCourse = n.getValue();
		
		me._can.obsCourse.setRotation((me._obsCourse - me._mapOptions.orientation) * global.CONST.DEG2RAD);
	},
	_drawWaypoints : func(){
# 		print("TcasLayer._draw() ... ");
# 		me._track.cmds = [];
# 		me._track.coords = [];
		me._itemIndex	= 0;
		print(sprintf("RouteLayer::_drawWaypoints() ... plan size = %i",
				fms._flightPlan.planSize
			     ));
		
		var cmd = canvas.Path.VG_MOVE_TO;
		for( var i=0; i < fms._flightPlan.planSize; i+=1 ){

			if(me._itemIndex >= me._itemCount){
				append(me._item,RouteItemClass.new(me._groupTrack,me._itemIndex));
				me._itemCount = size(me._item);
			}
			
			me._item[me._itemIndex].draw(fms._flightPlan.wp[i]);
			me._item[me._itemIndex].drawTrack(fms._flightPlan.wp[i]);
			
			
# 			foreach (var pt; fms._flightPlan.wp[i].path) {
# 				append(me._track.coords,"N"~pt.lat);
# 				append(me._track.coords,"E"~pt.lon);
# 				append(me._track.cmds,cmd);
# 				cmd = canvas.Path.VG_LINE_TO;
# 			}
			
			me._itemIndex +=1;
		}
		#append(cmds,canvas.Path.VG_CLOSE_PATH);
		#me._can.track.setDataGeo(me._track.cmds,me._track.coords);
		
		for (me._itemIndex ; me._itemIndex < me._itemCount ; me._itemIndex += 1){
			me._item[me._itemIndex].setVisible(0);
		}
		print("\n");
		me._groupTrack.setVisible(me._visibility and (me._obsMode == 0));
	},
	_drawLegs : func(){
		var cmd = canvas.Path.VG_MOVE_TO;
		
		if(fms._flightPlan.planSize > 1){
			for( var i=0; i < fms._flightPlan.planSize; i+=1 ){
			
				if(i != me._currentWpIndex  ){
					me._item[i].setColor("#FFFFFF");
				}else{
					me._item[i].setColor("#FF0EEB");
				}
			}	
			
			if(me._currentWpIndex >= 1 and me._currentWpIndex < fms._flightPlan.planSize){
				cmd = canvas.Path.VG_MOVE_TO;
				me._currentLeg.coords = [];
				me._currentLeg.cmds = [];
				foreach (var pt; fms._flightPlan.wp[me._currentWpIndex].path) {
					append(me._currentLeg.coords,"N"~pt.lat);
					append(me._currentLeg.coords,"E"~pt.lon);
					append(me._currentLeg.cmds,cmd);
					cmd = canvas.Path.VG_LINE_TO;
				}
				
				
				me._can.currentLeg.setDataGeo(me._currentLeg.cmds,me._currentLeg.coords);
				me._can.currentLeg.setVisible(1);
			}else{
				me._can.currentLeg.setVisible(0);
			}
			
			if(me._currentWpIndex >= 0 and me._currentWpIndex < fms._flightPlan.planSize-1){
				cmd = canvas.Path.VG_MOVE_TO;
				me._nextLeg.coords = [];
				me._nextLeg.cmds = [];
				foreach (var pt; fms._flightPlan.wp[me._currentWpIndex+1].path) {
					append(me._nextLeg.coords,"N"~pt.lat);
					append(me._nextLeg.coords,"E"~pt.lon);
					append(me._nextLeg.cmds,cmd);
					cmd = canvas.Path.VG_LINE_TO;
				}
				
				me._can.nextLeg.setDataGeo(me._nextLeg.cmds,me._nextLeg.coords);
				me._can.nextLeg.setVisible(1);
			}else{
				me._can.nextLeg.setVisible(0);
			}
			
			
			
			
		}
			
	},
	
};

