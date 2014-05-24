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
		m._group = canvasGroup.createChild("group", "Waypoint_"~index).setVisible(0);	
		m._can = {
			Waypoint : m._group.createChild("path","track")
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
		};
		 return m;
	},
	draw : func(wpt){
		me._group.setGeoPosition(wpt.wp_lat,wpt.wp_lon);
		me._can.Label.setText(wpt.wp_name);
		me.setColor("#FFFFFF");
		me._group.setVisible(1);
		
	},
	setColor : func(color){
		me._can.Label.setColor(color).setColorFill(color);
		me._can.Waypoint.setColor(color).setColorFill(color);
	}
	
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
		m._groupOBS	= group.createChild("group",id~"_OBS").setVisible(0);
		
		m._can = {
			track : m._group.createChild("path","track")
				.setStrokeLineWidth(3)
				.setScale(1)
				.setColor("#FFFFFF"),
			currentLeg : m._group.createChild("path","currentLeg")
				.setStrokeLineWidth(5)
				.setScale(1)
				.setColor("#FF0EEB"),
			nextLeg : m._group.createChild("path","nextLeg")
				.setStrokeLineWidth(5)
				.setScale(1)
				.setStrokeDashArray([25,25])
				.setColor("#FF0EEB"),
			obsCourse : m._groupOBS.createChild("path","obsCourse")
				.setStrokeLineWidth(5)
				.setScale(1)
				.setColor("#FF0EEB"),
		};
		

		m._track = {cmds:[],coords:[]};
		m._currentLeg = {cmds:[canvas.Path.VG_MOVE_TO,canvas.Path.VG_LINE_TO],coords:[0,0,0,0]};
		m._nextLeg = {cmds:[canvas.Path.VG_MOVE_TO,canvas.Path.VG_LINE_TO],coords:[0,0,0,0]};
		m._planSize = 0;
		
		
		m._mapOptions = {
			orientation	: 0,
		};
		
		
		m._obsMode = 0;
		m._obsCourse = 0;
		m._obsWaypoint = RouteItemClass.new(m._groupOBS,"obs_wp");
		m._obsCourseData = {cmds:[canvas.Path.VG_MOVE_TO,canvas.Path.VG_LINE_TO],coords:[0,0,0,0]};
		#m._flightPlan = flightplan();
		return m;
	},
	setListeners : func(){
			append(me._listeners, setlistener("/autopilot/route-manager/signals/waypoint-changed",func(n){me.onFlightPlanChange(n);},0,1));
			append(me._listeners, setlistener("/autopilot/route-manager/current-wp",func(n){me._onCurrentChange(n)},1,0));	
			
			append(me._listeners, setlistener(extra500.fms._node.ObsMode,func(n){me._onObsModeChange(n);},1,0) );
			append(me._listeners, setlistener("/instrumentation/fms[0]/selected-course-deg",func(n){me._onObsCourseChange(n);},1,0) );
		
	
	},
	updateOrientation : func(value){
		me._mapOptions.orientation = value;
		me._can.obsCourse.setRotation((me._obsCourse - me._mapOptions.orientation) * global.CONST.DEG2RAD);
	},
	
	onFlightPlanChange : func(n){
		me._drawWaypoints();
		me._drawLegs();
	},
	_onCurrentChange : func(n){
		me._currentWaypoint = n.getValue();
		me._drawLegs();
	},
	_onVisibilityChange : func(){
		me._group.setVisible(me._visibility and (me._obsMode == 0));
		me._groupOBS.setVisible(me._visibility and (me._obsMode == 1));
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
			
# 			me._obsWaypoint.draw(wp);
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
		
		me._group.setVisible(me._visibility and (me._obsMode == 0));
		me._groupOBS.setVisible(me._visibility and (me._obsMode == 1));
	},
	_onObsCourseChange : func(n){
		me._obsCourse = n.getValue();
		
		me._can.obsCourse.setRotation((me._obsCourse - me._mapOptions.orientation) * global.CONST.DEG2RAD);
	},
	_drawWaypoints : func(){
# 		print("TcasLayer._draw() ... ");
		me._track.cmds = [];
		me._track.coords = [];
		me._itemIndex	= 0;
		me._flightPlan = flightplan();
		me._planSize = me._flightPlan.getPlanSize();	
		for( var i=0; i < me._planSize; i+=1 ){
			var fmsWP = me._flightPlan.getWP(i);
# 				print(sprintf("%s range:%0.2f | lat:%0.3f lon:%0.3f a:%+i vs:%0.1f l:%i",tcas.id,tcas.range,tcas.lat,tcas.lon,tcas.alt,tcas.vs,tcas.level));
					
			if(me._itemIndex >= me._itemCount){
				append(me._item,RouteItemClass.new(me._group,me._itemIndex));
				me._itemCount = size(me._item);
			}
			me._item[me._itemIndex].draw(fmsWP);
			if(me._itemIndex == 0){
				append(me._track.cmds,canvas.Path.VG_MOVE_TO);
			}else{
				append(me._track.cmds,canvas.Path.VG_LINE_TO);
				
			}
			append(me._track.coords,"N"~fmsWP.wp_lat);
			append(me._track.coords,"E"~fmsWP.wp_lon);
			me._itemIndex +=1;
		}
		#append(cmds,canvas.Path.VG_CLOSE_PATH);
		me._can.track.setDataGeo(me._track.cmds,me._track.coords);
		
		for (me._itemIndex ; me._itemIndex < me._itemCount ; me._itemIndex += 1){
			me._item[me._itemIndex]._group.setVisible(0);
		}

	},
	_drawLegs : func(){
# 		var cmds 	= [];
# 		var coords	= [];
# 		me._planSize = me._flightPlan.getPlanSize();
# 		for( var i=0; i < me._planSize; i+=1 ){
# 			var fmsWP = me._flightPlan.getWP(i);
# 			if(i <= me._currentWaypoint){
# 				
# 			}elsif(i > me._currentWaypoint+1){
# 				
# 			}else{
# 				
# 			}
# 		}
		
		if(me._planSize > 1){
			for( var i=0; i < me._planSize; i+=1 ){
			
				if(i != me._currentWaypoint  ){
					me._item[i].setColor("#FFFFFF");
				}else{
					me._item[i].setColor("#FF0EEB");
				}
			}	
			
			if(me._currentWaypoint >= 1 and me._currentWaypoint < me._planSize){
				me._currentLeg.coords[0] = me._track.coords[(me._currentWaypoint-1)*2];
				me._currentLeg.coords[1] = me._track.coords[(me._currentWaypoint-1)*2+1];
				me._currentLeg.coords[2] = me._track.coords[(me._currentWaypoint)*2];
				me._currentLeg.coords[3] = me._track.coords[(me._currentWaypoint)*2+1];
				me._can.currentLeg.setDataGeo(me._currentLeg.cmds,me._currentLeg.coords);
				me._can.currentLeg.setVisible(1);
			}else{
				me._can.currentLeg.setVisible(0);
			}
			
			if(me._currentWaypoint >= 0 and me._currentWaypoint < me._planSize-1){
				me._nextLeg.coords[0] = me._track.coords[(me._currentWaypoint)*2];
				me._nextLeg.coords[1] = me._track.coords[(me._currentWaypoint)*2+1];
				me._nextLeg.coords[2] = me._track.coords[(me._currentWaypoint+1)*2];
				me._nextLeg.coords[3] = me._track.coords[(me._currentWaypoint+1)*2+1
				];
				me._can.nextLeg.setDataGeo(me._nextLeg.cmds,me._nextLeg.coords);
				me._can.nextLeg.setVisible(1);
			}else{
				me._can.nextLeg.setVisible(0);
			}
			
			
			
			
		}
			
	},
	
};

