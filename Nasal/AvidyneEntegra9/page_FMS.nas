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
#      Date: Aug 24 2013
#
#      Last change:      Eric van den Berg
#      Date:             19.06.2014
#


var DirectToWidget = {
	new : func(page,canvasGroup,name){
		var m = {parents:[DirectToWidget,IfdWidget.new(page,canvasGroup,name)]};
		m._class 	= "DirectToWidget";
		m._tab		= [];
		m._can		= {};
		
		m._can = {
			button		: m._group.getElementById("DirectTo").setVisible(0),
			text		: m._group.getElementById("DirectTo_Text"),
			border		: m._group.getElementById("DirectTo_Border"),
		};
		
		return m;
	},
	setListeners : func(instance) {
		append(me._listeners, setlistener(fms._node.DirectTo,func(n){me._onChange(n)},1,0));	
	},
	init : func(instance=me){
		
	},
	deinit : func(){
		
		
	},
	_onChange : func(n){
		if (n.getValue()==1){
			me._can.text.set("fill",COLOR["White"]);
			me._can.border.set("stroke",COLOR["Turquoise"]);
			me._can.border.set("stroke-width",20);
		}else{
			me._can.text.set("fill",COLOR["Turquoise"]);
			me._can.border.set("stroke",COLOR["Blue"]);
			me._can.border.set("stroke-width",10);
		}
	},
	_onVisibiltyChange : func(){
		if(me._visibility == 1){
			me.setListeners(me);
			
			me._ifd.ui.bindKey("R4",{
				"<"	: func(){keypad.onD()},
				">"	: func(){keypad.onD()},
			});
			
			me._can.button.setVisible(1);
		}else{
			me._can.button.setVisible(0);
			me._ifd.ui.bindKey("R4");
			me.removeListeners();
		}
	},
	
};


var FlightPlanItemInterface = {
	setType : func(type){},
	setHeadline : func(value){},
	setName : func(value){},
	setRestriction : func(value){},
	setETE : func(value){},
	setETA : func(value){},
	setDistance : func(value){},
	setFuel : func(value){},
	setActive   :func(value){},
	setSelection   :func(value){},
};

var TYPE_COLOR = {
	runway : {
		back	: "#207C97",
		inner	: "#56CCD3",
	},
	basic : {
		back	: "#67584E",
		inner	: "#C0AA9D",
	},
	bug : {
		back	: "#BD5889",
		inner	: "#FE80C8",
	},
};


var FlighPlanItem_old = {
	new : func(canvasGroup,index,type){
		var m = {parents:[
			FlighPlanItem_old,
			FlightPlanItemInterface
 			]};
		m._type = type;
		m._group = canvasGroup.createChild("group", "waypoint_"~index).setVisible(0).set("z-index",3);
		canvas.parsesvg(m._group, "Models/instruments/IFDs/IFD_FMS_FPL_ItemWP.svg");
		m._can = {
			Item 		: m._group.getElementById("FPL_Pattern_Waypoint"),
			Back 		: m._group.getElementById("Back"),
			BackInner	: m._group.getElementById("BackInner"),
			Headline	: m._group.getElementById("Headline"),
			Name 		: m._group.getElementById("Waypoint_Navaid_Name"),
			Ristriction 	: m._group.getElementById("Ristriction"),
			Distance 	: m._group.getElementById("Distance"),
			ETE	 	: m._group.getElementById("ETE"),
			Fuel	 	: m._group.getElementById("Fuel"),
			ETA		: m._group.getElementById("ETA"),
		};
		m.checkColor();
		
		m._group.setVisible(0);
		
		m._active = 0;
		m._selection = 0;

		return m;
	},
	setType : func(type){
		me._type = type;
		me.checkColor();
	},
	checkColor : func(){
		if(contains(TYPE_COLOR,me._type)){
			me._can.Back.setColorFill(TYPE_COLOR[me._type].back);
			me._can.BackInner.setColorFill(TYPE_COLOR[me._type].inner);
		}else{
			me._can.Back.setColorFill(TYPE_COLOR.basic.back);
			me._can.BackInner.setColorFill(TYPE_COLOR.basic.inner);
		}
	},
	setHeadline : func(value){ me._can.Headline.setText(value);},
	setName : func(value){me._can.Name.setText(value);},
	setRestriction : func(value){me._can.Ristriction.setText(value);},
	setETE : func(value){me._can.ETE.setText(value);},
	setETA : func(value){me._can.ETA.setText(value);},
	setDistance : func(value){me._can.Distance.setText(value);},
	setFuel : func(value){me._can.Fuel.setText(value);},
	
	setActive   :func(value){
		me._active = value;
		if (me._active == 1){
			me._can.Back.setColorFill(TYPE_COLOR.bug.back);
			me._can.BackInner.setColorFill(TYPE_COLOR.bug.inner);
		}else{
			me.checkColor();
		}
	},
	setSelection   :func(value){
		me._selection = value;
		if (me._selection == 1){
# 			me._can.Back.set("stroke",COLOR["Turquoise"]);
# 			me._can.Back.set("stroke-width",5);
		}else{
# 			me._can.Back.set("stroke","none");
		}
	},
	setVisible : func(visibility){
		me._group.setVisible(visibility);
	},
};




var FlightPlanListWidget = {
	new : func(page,canvasGroup,name){
		var m = {parents:[FlightPlanListWidget,IfdWidget.new(page,canvasGroup,name)]};
		m._class 	= "FlightPlanListWidget";
		m._tab		= [];
		m._can		= {};
		m._fplItemCache	= {};
		m._can = {
			#Pattern_Waypoint	: m._group.getElementById("FPL_Pattern_Waypoint").setVisible(0),
			FlightPlan		: m._group.getElementById("FPL_Flightplan"),
			ScrollAble		: m._group.getElementById("FPL_ScrollAble"),
			list			: m._group.getElementById("FPL_List"),
			ScrollCursorView	: m._group.getElementById("FPL_ScrollCursorView"),
			ScrollCursorCurrent	: m._group.getElementById("FPL_ScrollCursorCurrent"),
			Cursor			: m._group.getElementById("FPL_Cursor").setVisible(1),
			CursorInsert		: m._group.getElementById("FPL_Coursor_Insert").setVisible(0),
			CursorSelect		: m._group.getElementById("FPL_Coursor_Select").setVisible(0),
			
			
			
			
		};
		
		m._canList = {};
		m._scrollY = 0;
		m._selectedIndex = 0;
		m._lastSelectedIndex = 0;
		m._currentIndex = 0;
		m._lastCurrentIndex = 0;
		m._planSize = 0;
		m._maxScroll = 6;
		m._visible = 0;
		m._layout = "none";
		m._cursorModeInsert = 1;
		m._cacheSize = 0;
		m._scrollSize = 1356 / 6;
		
		m._x = 400;
		m._y = 70;
		
		m._listTransform = m._can.FlightPlan.createTransform();
		
		#m._fplItemCache[0] = FlighPlanItem_old.new(e._can.list,0,0);
		#m._cacheSize = 1;
		
		return m;
	},
	setListeners : func(instance) {
# 		append(me._listeners, setlistener("/autopilot/route-manager/signals/waypoint-changed",func(n){me._onFlightPlanChange(n)},1,0));	
# 		append(me._listeners, setlistener("/autopilot/route-manager/current-wp",func(n){me._onCurrentWaypointChange(n)},1,0));
		append(me._listeners, setlistener(fms._signal.fplChange,func(n){me._onFlightPlanChange(n)},1,1));	
		append(me._listeners, setlistener(fms._signal.currentWpChange,func(n){me._onCurrentWaypointChange(n)},1,1));
		append(me._listeners, setlistener(fms._signal.fplReady,func(n){me._onFplReadyChange(n)},1,0));	
		append(me._listeners, setlistener(fms._signal.fplUpdated,func(n){me._onFplUpdatedChange(n)},0,1));	
		
		append(me._listeners, setlistener("/sim/gui/dialogs/route-manager/selection",func(n){me._onSelectionChange(n)},1,1));	
		
		
	},
	init : func(instance=me){
		#print("FlightPlanListWidget.init() ... ");
		me.setListeners(instance);	
	},
	deinit : func(){
		me.removeListeners();
				
	},
	_onVisibiltyChange : func(){
		me._checkKeys();
		me._can.FlightPlan.setVisible(me._visibility);
	},
	_checkKeys  : func(){
		if(me._visibility == 1 ){
			if (me._layout == "FPL"){
				
				me._ifd.ui.bindKey("R5",{
					"<"	: func(){me._deleteWaypoint();},
					">"	: func(){me._deleteWaypoint();},
				});
				
			}else{
				me._ifd.ui.bindKey("R5");
			}
			
			me._ifd.ui.bindKnob("RK",{
				"<<"	: func(){me._adjustSelection(2);},
				"<"	: func(){me._adjustSelection(1);},
				"push"	: func(){fms.jumpTo();},
				">"	: func(){me._adjustSelection(-1);},
				">>"	: func(){me._adjustSelection(-2);},
			},{
				"scroll"	: "Scroll",
				"push"		: "Select",
				
			});
			
		}else{
			me._ifd.ui.bindKey("R5");
			me._ifd.ui.bindKnob("RK");
		}
	},
	setLayout : func(layout){
		me._layout = layout;
		if(me._layout == "FPL"){
			me._x = 400;
			me._y = 70;
			
			me._can.FlightPlan.set("clip","rect(70px, 2048px, 1424px, 0px)");
							
			me._listTransform.setScale(1.0,1.0);
			me._listTransform.setTranslation(0,0);
		}elsif(layout == "split-right"){
			me._x = 400;
			me._y = 70;
			
			me._can.FlightPlan.set("clip","rect(205px, 2048px, 1216px, 1024px)");
						
			me._listTransform.setScale(0.75,0.75);
			me._listTransform.setTranslation(770,150);
		}else{
			me._visible == 0;
			me._can.FlightPlan.setVisible(me._visible);
		}
		me._checkKeys();
	},
	_clearList : func(){
		me._scrollY = 0;
		#me._can.list.removeAllChildren();
		#me._fplItemCache = [];
		me._cursorModeInsert = 1;
		for( var i=0; i < me._cacheSize; i+=1 ){
			 me._fplItemCache[i].setVisible(0);
		}
	},
	_drawList : func(){
		var distSum = 0;
		for( var i=0; i < fms._fightPlan.planSize; i+=1 ){
			var fmsWP = fms._fpl.getWP(i);
			
			if ( i >= me._cacheSize ){
				#append(me._fplItemCache , FlighPlanItem_old.new(me._can.list,i,fmsWP.wp_type));
				me._fplItemCache[i] = FlighPlanItem_old.new(me._can.list,i,fmsWP.wp_type);
				me._cacheSize = size(me._fplItemCache);
			}
			me._fplItemCache[i].setType(fmsWP.wp_type);
			me._fplItemCache[i]._group.setTranslation(me._x,me._y+i*224);
			me._fplItemCache[i].setVisible(1);
			
			#me._fplItemCache[i].setHeadline(sprintf("%s %03.0f - %s",fmsWP.fly_type,fmsWP.leg_bearing,fmsWP.wp_role));
			#me._fplItemCache[i].setName(sprintf("%s - %s",fmsWP.wp_name,fmsWP.wp_type));
			
			me._fplItemCache[i].setName(sprintf("%s",fmsWP.wp_name));
			
			var restriction = "";
			if (fmsWP.alt_cstr_type != nil) {
				restriction ~= "at : " ~ fmsWP.alt_cstr ~"ft ";
			}
			if (fmsWP.speed_cstr_type != nil) {
				restriction ~= "IAS : " ~ fmsWP.speed_cstr ~"kts ";
			}
			me._fplItemCache[i].setRestriction(restriction);
			if(fms._fightPlan.planSize > 1){
				distSum += fmsWP.leg_distance;

			}
			if(i > 0){
				me._fplItemCache[i].setHeadline(sprintf("%s %03.0f",fmsWP.fly_type,fms._fpl.getWP(i-1).leg_bearing));
				me._fplItemCache[i].setDistance(sprintf("%0.1f",fms._fpl.getWP(i-1).leg_distance));
			}else{
				me._fplItemCache[i].setHeadline("");
				me._fplItemCache[i].setDistance("---");
			}
			if( i == me._currentIndex){
				me._fplItemCache[i].setActive(1);
			}
			if( i == me._selectedIndex){
				me._fplItemCache[i].setSelection(1);
			}
			
		}
		me._resizeScroll();
		#me._setSelection(fms._fightPlan.planSize-1,"insert");
		#me._scrollToCurrentIndex(fms._fightPlan.planSize-1);
		me._scrollToCurrentIndex(me._selectedIndex);
		
	},
	_resizeScroll : func(){
		if(fms._fightPlan.planSize > 6){
			me._scrollSize = 1356 / fms._fightPlan.planSize;
			me._maxScroll = fms._fightPlan.planSize -6;
		}else{
			me._scrollSize = 1356 / 6;
			me._maxScroll = 6;
		}
		me._can.ScrollCursorCurrent.set("coord[1]",0);
		me._can.ScrollCursorCurrent.set("coord[3]",me._scrollSize);
		me._can.ScrollCursorCurrent.setTranslation(0,me._y+me._currentIndex*me._scrollSize);
		me._can.ScrollCursorView.set("coord[1]",0);
		me._can.ScrollCursorView.set("coord[3]",me._scrollSize*6);
		me._can.ScrollCursorView.setTranslation(0,me._y+me._scrollY*me._scrollSize);
	},
	_scrollToCurrentIndex : func(index){
		
		me._scrollY = index;
		
		me._scrollY = global.clamp(me._scrollY,0,me._maxScroll);
		
		me._can.ScrollAble.setTranslation(0,me._scrollY*-224);
		me._can.ScrollCursorView.setTranslation(0,me._y+me._scrollY*me._scrollSize);
		
	},
	_scrollToSelectedIndex : func(index){
		if (index < me._scrollY){
			me._scrollY = index;
		}
		if(index >  me._scrollY + 5 ){
			me._scrollY = index - 5;
		}
		me._scrollY = global.clamp(me._scrollY,0,me._maxScroll);
		
		me._can.ScrollAble.setTranslation(0,me._scrollY*-224);
		
		me._can.ScrollCursorView.setTranslation(0,me._y+me._scrollY*me._scrollSize);
		
	},
	_deleteWaypoint : func(){
		fms._fpl.deleteWP(me._selectedIndex);
	},
	_onFlightPlanChange : func(n){
# 		print("FlightPlanListWidget._onFlightPlanChange() ... ");
		
		var value = n.getValue();
		#print("FlightPlanWidget._onFlightPlanChange() ... " ~ value);
		me._clearList();
		me._drawList();
	},
	_onSelectionChange : func(n){
		var index = n.getValue();
		if(index == nil){
			index = -1;
		}
		if(index >= 0){
			me._setSelection(index);
			me._scrollToSelectedIndex(me._selectedIndex);
		}
		
		
	},
	_onCurrentWaypointChange : func(n){
		me._currentIndex = n.getValue();	
		if(me._currentIndex == nil){
			me._currentIndex = -1;
		}
		#print("FlightPlanWidget._onCurrentWaypointChange() ... "~me._currentIndex);
		
		
		if(me._fplItemCache[me._lastCurrentIndex] != nil){
			me._fplItemCache[me._lastCurrentIndex].setActive(0);
		}
		if(me._fplItemCache[me._currentIndex] != nil){
			me._fplItemCache[me._currentIndex].setActive(1);
		}

		
		me._can.ScrollCursorCurrent.setTranslation(0,me._y+me._currentIndex*me._scrollSize);
		me._setSelection(me._currentIndex);
		me._scrollToCurrentIndex(me._currentIndex);
		me._lastCurrentIndex = me._currentIndex;

		# getting and setting the frequency in nav1 if new current waypoint is a VOR or destination ILS (course is set in extra500-autopilot.xml)
		var currwp = getprop("/autopilot/route-manager/current-wp");
		var freq = nil;
		var course = nil;
		if ( currwp >= 0 ) {
			var flp = flightplan();
			if (flp.getWP(flp.current).wp_role == "approach" == 1) {
# is approach, looking for ILS freq
				var navaid = airportinfo(getprop("/autopilot/route-manager/destination/airport"));
				var runway = navaid.runways[getprop("/autopilot/route-manager/destination/runway")].ils;
				if (runway != nil) {
					var freq = runway.frequency;
					var course = runway.course;
# set course
					if (course != nil) {
						setprop("/autopilot/fms-channel/autotuning/approach",1);
						setprop("/instrumentation/nav/radials/selected-deg",course);
					}
				}

			} else {
				setprop("/autopilot/fms-channel/autotuning/approach",0);
# looking for VOR 
				var activewpid = getprop("/autopilot/route-manager/route/wp["~currwp~"]/id");
				var navaid = navinfo("vor",activewpid);
				if (size(navaid) != 0 ) {
					var freq = navaid[0].frequency;
#					var course = getprop("/autopilot/route-manager/route/wp["~currwp~"]/leg-bearing-true-deg");
				}
			}
# set frequency
			if (freq != nil) {
				setprop("/instrumentation/nav/frequencies/selected-mhz",freq/100);
			}

		} else {
			setprop("/autopilot/fms-channel/autotuning/approach",0);
		}
		
	},
	_adjustSelection : func(amount){
		
		if(amount > 0){
			if(me._cursorModeInsert==1){
				me._selectedIndex += amount;
				me._selectedIndex = global.clamp(me._selectedIndex,0,fms._fightPlan.planSize-1);
			}
			me._setSelection(me._selectedIndex,!me._cursorModeInsert);
		}elsif(amount < 0){
			if(me._cursorModeInsert==0){
				me._selectedIndex += amount;
				me._selectedIndex = global.clamp(me._selectedIndex,0,fms._fightPlan.planSize-1);
			}
			me._setSelection(me._selectedIndex,!me._cursorModeInsert);
		}else{
			
		}
		
		#me._setSelection();
		me._scrollToSelectedIndex(me._selectedIndex);	
	},
	_setSelection : func(index=nil,mode=nil){
		if (index!=nil){
			me._selectedIndex = index;
			me._cursorModeInsert = 0;
		}
		if(mode!=nil){
			me._cursorModeInsert = mode;
		}

		
		#print("FlightPlanWidget._setSelection() ... "~me._selectedIndex);
		if(me._fplItemCache[me._lastSelectedIndex] != nil){
			me._fplItemCache[me._lastSelectedIndex].setSelection(0);
		}
		if(me._fplItemCache[me._selectedIndex] != nil){
			me._fplItemCache[me._selectedIndex].setSelection(1);
		}
		me._can.Cursor.setTranslation(0,me._selectedIndex*224);
		
		me._can.CursorSelect.setVisible(!me._cursorModeInsert);
		me._can.CursorInsert.setVisible(me._cursorModeInsert);
		
# 		if(me._cursorModeInsert == 1){
# 			me._can.CursorSelect.setVisible(0);
# 			me._can.CursorInsert.setVisible(1ndex*224);
# 		}else{
# 			me._can.CursorInsert.setVisible(0);
# 			me._can.CursorSelect.setVisible(1);
# 			#me._can.CursorSelect.setTranslation(0,me._selectedIndex*224);
# 		}
		

		
			
		
		fms.setSelectedWaypoint(me._selectedIndex);
		me._lastSelectedIndex = me._selectedIndex;
	},
	_onFplReadyChange : func(n){
		if(fms._fightPlan.isReady){
			
		}else{
			for( var i=0; i < fms._fightPlan.planSize; i+=1 ){
				me._fplItemCache[i].setDistance("---");
				me._fplItemCache[i].setETE("---");
				me._fplItemCache[i].setETA("---");
				me._fplItemCache[i].setFuel("---");
			}
		}
	},
	_onFplUpdatedChange : func(n){
		for( var i=0; i < fms._fightPlan.planSize; i+=1 ){
			if (i >= fms._fightPlan.currentWp){
				me._fplItemCache[i].setDistance(sprintf("%0.1f",fms._fightPlan.wp[i].distanceTo));
				me._fplItemCache[i].setETE(global.formatTime(fms._fightPlan.wp[i].ete,"i:s"));
				me._fplItemCache[i].setETA(global.formatTime(fms._fightPlan.wp[i].eta));
				me._fplItemCache[i].setFuel(sprintf("%.0f",fms._fightPlan.wp[i].fuelAt));
			}else{
				me._fplItemCache[i].setDistance("---");
				me._fplItemCache[i].setETE("---");
				me._fplItemCache[i].setETA("---");
				me._fplItemCache[i].setFuel("---");
			}
		}

	},
	update : func(){
		
	}
	
};


var AvidynePageFMS = {
	new: func(ifd,name,data){
		var m = { parents: [
			AvidynePageFMS,
			PageClass.new(ifd,name,data)
		] };
		m.svgFile	= "IFD_FMS.svg";
		
		canvas.parsesvg(m.page, "Models/instruments/IFDs/"~m.svgFile,{
			"font-mapper": global.canvas.FontMapper
			}
		);
		m._widget	= {
			Tab	 	: TabWidget.new(m,m.page,"TabSelectMAP"),
			DirectTo 	: DirectToWidget.new(m,m.page,"DirectTo"),
			FPL	 	: FlightPlanListWidget.new(m,m.page,"FPL-List"),
			MovingMapKnob	: MovingMapKnobWidget.new(m,m.page,"MovingMapKnob"),
			
			
			
			
		};
		
		m._can = {
			
			RoutesContent		: m.page.getElementById("FMS_Routes_Content").setVisible(0),
			UserWyptsContent	: m.page.getElementById("FMS_UserWypts_Content").setVisible(0),
			InfoContent		: m.page.getElementById("FMS_Info_Content").setVisible(0),
			FPLContent		: m.page.getElementById("FMS_FPL_Content").setVisible(0),
		};
		
		
		m._widget.Tab._tab = ["FPL","MapFPL","Info","Routes","UserWypts","Nearest","MapNearest"];
		
		
		return m;
	},
	init : func(instance=me){
		#print("AvidynePageFMS.init() ... ");
				
		me.setListeners(instance);
		
# 		foreach(var widget;keys(me._widget)){
# 			#print("widget : "~widget);
# 			if(me._widget[widget] != nil){
# 				
# 				me._widget[widget].init();
# 			}
# 		}
		

		
# 		me.IFD._widget.PlusData.setVisible(0);
		me._widget.Tab.init();
		me._widget.FPL.init();
	
	},
	deinit : func(){
		me.page.setVisible(0);
		me.keys = {};
		me.removeListeners();
		
		foreach(var widget;keys(me._widget)){
			if(me._widget[widget] != nil){
				me._widget[widget].setVisible(0);
				me._widget[widget].deinit();
			}
		}
	},
	_onVisibiltyChange : func(){
		#me.IFD._widget.Headline.setVisible(visibility);
		#me.IFD._widget.PlusData.setVisible(visibility);
		#me.IFD.movingMap.setVisible(visibility);
		
		if(me._visibility == 1){
			me.registerKeys();
		}else{
			me._widget.MovingMapKnob.setVisible(me._visibility);
			me._widget.FPL.setVisible(me._visibility);
			me._widget.DirectTo.setVisible(me._visibility);
		}
		me._widget.Tab.setVisible(me._visibility);
		me.page.setVisible(me._visibility);
	},
	
	_initWidgetsForTab : func(index){
# 		me._widget.DirectTo.deinit();
# 		me._widget.FPL.setVisible(0);
		#me.IFD._widget.PlusData.setVisible(0);
		me._can.RoutesContent.setVisible(0);
		me._can.FPLContent.setVisible(0);
		me._can.InfoContent.setVisible(0);
		me._can.UserWyptsContent.setVisible(0);
		
		if (index == 0){ # FPL
			me._widget.MovingMapKnob.setVisible(0);
			me.IFD.movingMap.setLayout("none");
			me.IFD.setLayout(IFD_LAYOUT.PLUS);
			me._widget.FPL.setLayout("FPL");
			me._widget.FPL.setVisible(1);
			me._widget.DirectTo.setVisible(1);
			me._can.FPLContent.setVisible(1);
		}elsif(index == 1){ # MapFPL
			me._widget.MovingMapKnob.setHand(0);
			me.IFD.setLayout(IFD_LAYOUT.SPLIT);
			me.IFD.movingMap.setLayout("split-left");
			me._widget.FPL.setLayout("split-right");
			me._widget.FPL.setVisible(1);
			me._widget.DirectTo.setVisible(0);
			me._widget.MovingMapKnob.setVisible(1);	
		}elsif(index == 2){ # Info
			me._widget.MovingMapKnob.setVisible(0);
			me._widget.FPL.setVisible(0);
			me.IFD.movingMap.setLayout("none");
			me.IFD.setLayout(IFD_LAYOUT.PLUS);
			me._widget.DirectTo.setVisible(1);
			me._can.InfoContent.setVisible(1);
		}elsif(index == 3){ # Routes
			me._widget.FPL.setVisible(0);
			me._widget.MovingMapKnob.setVisible(0);
			me.IFD.setLayout(IFD_LAYOUT.PLUS);
			me.IFD.movingMap.setLayout("none");
			me._widget.DirectTo.setVisible(0);
			me._can.RoutesContent.setVisible(1);
		}elsif(index == 4){ # UserWypts
			me._widget.MovingMapKnob.setVisible(0);
			me._widget.FPL.setVisible(0);
			me.IFD.setLayout(IFD_LAYOUT.PLUS);
			me.IFD.movingMap.setLayout("none");
			me._widget.DirectTo.setVisible(1);
			me._can.UserWyptsContent.setVisible(1);
		
		}elsif(index == 5){ # Nearest
			me._widget.MovingMapKnob.setVisible(0);
			me._widget.FPL.setVisible(0);
			me.IFD.movingMap.setLayout("none");
			me._widget.DirectTo.setVisible(1);
			me.IFD.setLayout(IFD_LAYOUT.PLUS);
			
		}elsif(index == 6){ # MapNearest
			me._widget.FPL.setVisible(0);
			me.IFD.setLayout(IFD_LAYOUT.SPLIT);
			me.IFD.movingMap.setLayout("split-left");
			me._widget.MovingMapKnob.setHand(0);
			me._widget.MovingMapKnob.setVisible(1);
			me._widget.DirectTo.setVisible(0);
			
		}else{
			
		}
	},
	update2Hz : func(now,dt){

		me._widget.FPL.update();
		
	},
	update20Hz : func(now,dt){
		

	
	},
};
