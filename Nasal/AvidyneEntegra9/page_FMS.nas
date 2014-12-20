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
#      Date:             01.08.2014
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

var ScrollAble = {
	new : func(){
		var m = {parents:[ScrollAble]};
		return m;
	},
	adjust : func(amount=nil){return 0;},
	select : func(v,cursor=0){}
};

var FlightPlanItemInterface = {
	new : func(){
		var m = {parents:[FlightPlanItemInterface]};
		m._height = 0;
		return m;
	},
	getHeight :func(){return me._height;},
	setTranslation : func(x,y){},
	setType : func(type,role=nil){},
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



var FlighPlanInserCoursor = {
	new : func(canvasGroup){
		var m = {parents:[
			FlighPlanInserCoursor,
			ScrollAble.new(),
 			]};
			
		m._index = 0;
		m._position = [0];
		m._visibility = 0;
		
		m._can = {
			CursorInsert		: canvasGroup.getElementById("FPL_Coursor_Insert").setVisible(m._visibility),
		};
		
		return m;
	},
	adjust : func(amount=nil){
		var adjust = 0;
		
		if(amount==nil){
			
		}else{
			adjust = me._visibility == 1 ? math.sgn(amount) : 0;
		}
		
		return adjust;
	},
	select : func(v,cursor=0){
		me._index = cursor/2;
		me._can.CursorInsert.setTranslation(0,me._position[me._index]);
		me._visibility = v;
		me._can.CursorInsert.setVisible(me._visibility);
	}
};

var FlighPlanItem_old = {
	new : func(canvasGroup,index,type){
		var m = {parents:[
			FlighPlanItem_old,
			ScrollAble.new(),
 			FlightPlanItemInterface.new()
 			]};
		m._type = type;
		m._group = canvasGroup.createChild("group", "waypoint_"~index).setVisible(0).set("z-index",3);
		canvas.parsesvg(m._group, "Models/instruments/IFDs/IFD_FMS_FPL_ItemWP.svg",{
			"font-mapper": global.canvas.FontMapper
			}
		);
		m._can = {
# 			edit			: m._group.getElementById("edit").setVisible(0),
# 			view 			: m._group.getElementById("view"),
# 			Item 			: m._group.getElementById("FPL_Pattern_Waypoint"),
# 			Back 			: m._group.getElementById("Back"),
# 			BackInner		: m._group.getElementById("BackInner"),
		#General
			Wypt_back		: m._group.getElementById("Wypt_back"),
			Airport_back		: m._group.getElementById("Airport_back").setVisible(0),
			Headline		: m._group.getElementById("Wypt_Headline"),
			ICAO 			: m._group.getElementById("Wypt_ICAO"),
			ICAO_back 		: m._group.getElementById("Wypt_ICAO_back").setVisible(0),
			Constrains 		: m._group.getElementById("Wypt_Constrains"),
			
		# Wypt Details
			Wypt_Detail 		: m._group.getElementById("Wypt_Detail"),
			Wypt_Detail_back 	: m._group.getElementById("Wypt_Detail_back"),
			
			Distance 		: m._group.getElementById("Distance"),
			ETE	 		: m._group.getElementById("ETE"),
			ETE_Unit	 	: m._group.getElementById("ETE_unit"),
			Fuel	 		: m._group.getElementById("Fuel"),
			ETA			: m._group.getElementById("ETA"),
			
		# Constarains
			constrains_edit		: m._group.getElementById("constrains_edit").setVisible(0),
			Constain_before_back	: m._group.getElementById("Constain_before_back"),
			Constain_alt_back	: m._group.getElementById("Constain_alt_back"),
			Constain_at_back	: m._group.getElementById("Constain_at_back"),
			
		# Airport Details
			Airport_Detail		: m._group.getElementById("Airport_Detail").setVisible(0),
			Airport_Detail_back	: m._group.getElementById("Airport_Detail_back"),
			Airport_brg_nm		: m._group.getElementById("Airport_Bearing_distance"),
			Airport_brg_deg		: m._group.getElementById("Airport_Bearing_deg"),
			Airport_Runway_Text	: m._group.getElementById("Airport_Runway_Text"),
			Airport_Runway_back	: m._group.getElementById("Airport_Runway_back").setVisible(0),
			
		# Airport procedures
			Airport_Procedures	: m._group.getElementById("Airport_Procedures").setVisible(0),
			Airport_Procedures_back	: m._group.getElementById("Airport_Procedures_back"),
			
			Airport_Arrival_lable	: m._group.getElementById("Airport_Arrival_lable"),
			Airport_Arrival_Text	: m._group.getElementById("Airport_Arrival_Text"),
			Airport_Arrival_back	: m._group.getElementById("Airport_Arrival_back").setVisible(0),
			
			Airport_Approach_lable	: m._group.getElementById("Airport_Approach_lable"),
			Airport_Approach_Text	: m._group.getElementById("Airport_Approach_Text"),
			Airport_Approach_back	: m._group.getElementById("Airport_Approach_back").setVisible(0),
			
		# selection
			Wypt_Selection		: m._group.getElementById("Wypt_Selection").setVisible(0),
			Airport_Selection	: m._group.getElementById("Airport_Selection").setVisible(0),
			
		};
		m.checkColor();
		
		m._group.setVisible(0);
		
		m._active = 0;
		m._visibility = 0;
		
		m._offset = {x:0,y:0};
		return m;
	},
	### implementation of SelectAble
	adjust : func(amount=nil){
		var adjust = 0;
		if(amount==nil){
			
		}else{
			adjust = me._visibility == 1 ? math.sgn(amount) : 0;
		}
		me.select(adjust == 0);
		
		return adjust;
	},
	select : func(v,cursor=0){
		me._visibility = v;
		
		if(me._type == "runway"){
			me._can.Airport_Selection.setVisible(me._visibility);
		}else{
			me._can.Wypt_Selection.setVisible(me._visibility);
			
		}
	},
	
	setTranslation : func(x,y){
		me._group.setTranslation(x+me._offset.x,y+me._offset.y);
	},
	
	setType : func(type,role=nil){
		me._type = type;
		if(me._type == "runway"){
			me._height = 256;
			me._offset.y = 56;
			
			me._can.Airport_back.setVisible(1);
			me._can.Wypt_back.setVisible(0);
			
			if(role != nil){
					if(role == "sid"){
						me._can.Airport_Procedures.setVisible(1);
						me._can.Airport_Arrival_lable.setVisible(0);
						me._can.Airport_Arrival_Text.setVisible(0);
						me._can.Airport_Arrival_back.setVisible(0);
						
						me._can.Airport_Approach_lable.setText("Departure");
						
						me._can.Airport_Detail.setVisible(1);
						me._can.Wypt_Detail.setVisible(0);
						
						
					}elsif(role == "approach"){
						me._can.Airport_Procedures.setVisible(1);
						me._can.Airport_Arrival_lable.setVisible(1);
						me._can.Airport_Arrival_Text.setVisible(1);
						me._can.Airport_Arrival_back.setVisible(0);
						
						me._can.Airport_Approach_lable.setText("Approach");
						
						me._can.Airport_Detail.setVisible(1);
						me._can.Wypt_Detail.setVisible(0);
						
						
					}else{
						me._can.Airport_Procedures.setVisible(0);
					}
					
					
			}else{
				me._can.Airport_Procedures.setVisible(0);
			}
			
		}else{
			me._height = 200;
			me._offset.y = 0;
			
			me._can.Airport_Procedures.setVisible(0);
			me._can.Airport_back.setVisible(0);
			me._can.Airport_Detail.setVisible(0);
			
			me._can.Wypt_back.setVisible(1);
			me._can.Wypt_Detail.setVisible(1);
			
		}
		me._can.Airport_Selection.setVisible(0);
		me._can.Wypt_Selection.setVisible(0);
		me.checkColor();
	},
	checkColor : func(){
		
		if(me._type == "runway"){
			me._can.Airport_back.setColorFill("#1f305c");
			me._can.Airport_Detail.setColorFill("#1e5c92");
			me._can.Airport_Procedures_back.setColorFill("#201c57");
			me._can.Wypt_Detail_back.setColorFill("#1e5c92");
		}else{
			me._can.Wypt_back.setColorFill("#303030");
			me._can.Wypt_Detail_back.setColorFill("#616660");
		}

		
	},
	setActive   :func(value){
		me._active = value;
		if (me._active == 1){
			
			if(me._type == "runway"){
				me._can.Airport_back.setColorFill(TYPE_COLOR.bug.back);
				me._can.Airport_Detail.setColorFill(TYPE_COLOR.bug.inner);
				me._can.Airport_Procedures_back.setColorFill(TYPE_COLOR.bug.inner);
			}else{
				me._can.Wypt_back.setColorFill(TYPE_COLOR.bug.back);
			}
			
			me._can.Wypt_Detail_back.setColorFill(TYPE_COLOR.bug.inner);
			
		}else{
			me.checkColor();
		}
	},
	setSelection   :func(value){
		me.select(value);

	},

	setVisible : func(visibility){
		me._group.setVisible(visibility);
	},
	setHeadline : func(value){ me._can.Headline.setText(value);},
	setName : func(value){me._can.ICAO.setText(value);},
	setRestriction : func(value){me._can.Constrains.setText(value);},
	setETE : func(value){me._can.ETE.setText(value);},
	setETA : func(value){me._can.ETA.setText(value);},
	setDistance : func(value){me._can.Distance.setText(value);},
	setFuel : func(value){me._can.Fuel.setText(value);},
	
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
			list			: m._group.getElementById("FPL_List").setVisible(1),
			ScrollCursorView	: m._group.getElementById("FPL_ScrollCursorView"),
			ScrollCursorCurrent	: m._group.getElementById("FPL_ScrollCursorCurrent"),
			
			
			
			
		};
		
		m._insertCoursor = FlighPlanInserCoursor.new(m._group);
		m._scrollAbleList = [];
		m._scrollAbleListSize = 0;
		m._cursorIndex = 0;
		
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
		m._yMax = 1356;
		
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
# 		append(me._listeners, setlistener(fms._signal.selectedWpChange,func(n){me._onSelectedWpChange(n)},1,1));
		append(me._listeners, setlistener(fms._signal.cursorOptionChange,func(n){me._onCursorOptionChange(n)},1,1));
		append(me._listeners, setlistener(fms._signal.cursorIndexChange,func(n){me._onCursorIndexChange(n)},1,1));
		
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
				"<<"	: func(){me._adjustCursorFocus(1);},
				"<"	: func(){me._adjustCursorFocus(1);},
				"push"	: func(){fms.jumpTo();},
				">"	: func(){me._adjustCursorFocus(-1);},
				">>"	: func(){me._adjustCursorFocus(-1);},
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
			me._yMax = 1356;
			
			me._can.FlightPlan.set("clip","rect(70px, 2048px, 1424px, 0px)");
							
			me._listTransform.setScale(1.0,1.0);
			me._listTransform.setTranslation(0,0);
		}elsif(layout == "split-right"){
			me._x = 400;
			me._y = 70;
			me._yMax = 1356; # TODO : 
			
			me._can.FlightPlan.set("clip","rect(205px, 2048px, 1216px, 1024px)");
						
			me._listTransform.setScale(0.75,0.75);
			me._listTransform.setTranslation(770,0);
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
		var translateY = me._y;
		me._insertCoursor._position = [];
		me._scrollAbleList = [];
		
		append(me._insertCoursor._position,me._y);
		append(me._scrollAbleList,me._insertCoursor);
		
		for( var i=0; i < fms._flightPlan.planSize; i+=1 ){
			
			if ( i >= me._cacheSize ){
				me._fplItemCache[i] = FlighPlanItem_old.new(me._can.list,i,fms._flightPlan.wp[i].type);
				me._cacheSize = size(me._fplItemCache);
			}
			me._fplItemCache[i].setType(fms._flightPlan.wp[i].type,fms._flightPlan.wp[i].role);
			me._fplItemCache[i].setTranslation(me._x,translateY);
			
			append(me._scrollAbleList,me._fplItemCache[i]);
			
			translateY += me._fplItemCache[i]._height + 24 ; 
			append(me._insertCoursor._position,translateY);
			append(me._scrollAbleList,me._insertCoursor);
			
						
			me._fplItemCache[i].setName(sprintf("%s",fms._flightPlan.wp[i].name));
			
			var restriction = "";
			if (fms._flightPlan.wp[i].constraint.alt.type != nil) {
				restriction ~= "at : " ~ fms._flightPlan.wp[i].constraint.alt.value ~"ft ";
			}
			if (fms._flightPlan.wp[i].type != nil){
				restriction ~= fms._flightPlan.wp[i].type ~ " - ";
			}else {
				restriction ~= "nil - ";
			}
			if(fms._flightPlan.wp[i].role != nil){
				restriction ~=  fms._flightPlan.wp[i].role;
			}else {
				restriction ~=  "nil";
			}
			me._fplItemCache[i].setRestriction(restriction);
			
			if(i > 0){
				me._fplItemCache[i].setHeadline(sprintf("%s %03.0f",fms._flightPlan.wp[i].flyType,fms._flightPlan.wp[i].course));
				me._fplItemCache[i].setDistance(sprintf("%0.1f",fms._flightPlan.wp[i].distanceTo));
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
			
			me._fplItemCache[i].setVisible(translateY <= me._yMax);
			
		}
		
		debug.dump("me._insertCoursor._position",me._insertCoursor._position);
		me._scrollAbleListSize = size(me._scrollAbleList);
		me._resizeScroll();
		#me._setSelection(fms._flightPlan.planSize-1,"insert");
		#me._scrollToCurrentIndex(fms._flightPlan.planSize-1);
		me._scrollToCurrentIndex(me._selectedIndex);
		
	},
	_resizeScroll : func(){
		if(fms._flightPlan.planSize > 6){
			me._scrollSize = 1356 / fms._flightPlan.planSize;
			me._maxScroll = fms._flightPlan.planSize -6;
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
		
# 		me._can.ScrollAble.setTranslation(0,me._scrollY*-224);
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
		
# 		me._can.ScrollAble.setTranslation(0,me._scrollY*-224);
		
		me._can.ScrollCursorView.setTranslation(0,me._y+me._scrollY*me._scrollSize);
		
	},
	_deleteWaypoint : func(){
		fms.deleteWaypoint();
	},
	_onFlightPlanChange : func(n){
# 		print("FlightPlanListWidget._onFlightPlanChange() ... ");
		
		var value = n.getValue();
		#print("FlightPlanWidget._onFlightPlanChange() ... " ~ value);
		me._clearList();
		me._drawList();
	},
	_onSelectedWpChange : func(n){
		var index = n.getValue();
		me._lastSelectedIndex = me._selectedIndex;
		
		if(index == nil){
			index = -1;
		}
		
		me._selectedIndex = index;
		
		if(index >= 0){
			me._scrollToSelectedIndex(me._selectedIndex);
		}
		
		if(me._fplItemCache[me._lastSelectedIndex] != nil){
			me._fplItemCache[me._lastSelectedIndex].setSelection(0);
		}
		if(me._fplItemCache[me._selectedIndex] != nil){
			me._fplItemCache[me._selectedIndex].setSelection(1);
		}
		me._scrollToCurrentIndex(me._selectedIndex);
		
	},
	_onCursorOptionChange : func(n){
		var index = n.getValue();
		
	},
	_setSelection : func(index=nil,mode=nil){
		if (index!=nil){
			fms.setSelectedWaypoint(index);
			me._cursorModeInsert = 0;
		}
		if(mode!=nil){
			me._cursorModeInsert = mode;
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
		me._lastCurrentIndex = me._currentIndex;
	},
	_adjustCursorFocus : func(amount){
		var index = me._cursorIndex;
		var adjust = me._scrollAbleList[index].adjust(amount);
		
		
		if (adjust != 0){
			index = global.clamp(index + adjust,0,me._scrollAbleListSize-1);
		}
		
		fms.setCursorIndex(index);
		
# 		if(amount > 0){
# 			if(me._cursorModeInsert==1){
# 				me._selectedIndex += amount;
# 				me._selectedIndex = global.clamp(me._selectedIndex,0,fms._flightPlan.planSize-1);
# 			}
# 			me._setSelection(me._selectedIndex,!me._cursorModeInsert);
# 		}elsif(amount < 0){
# 			if(me._cursorModeInsert==0){
# 				me._selectedIndex += amount;
# 				me._selectedIndex = global.clamp(me._selectedIndex,0,fms._flightPlan.planSize-1);
# 			}
# 			me._setSelection(me._selectedIndex,!me._cursorModeInsert);
# 		}else{
# 			
# 		}
		
		#me._setSelection();
# 		me._scrollToSelectedIndex(me._selectedIndex);	
	},
	_onCursorIndexChange : func(n){
		var newIndex = n.getValue();
		debug.dump("FlightPlanListWidget._onCursorIndexChange() ... ",newIndex);
		if( newIndex < me._scrollAbleListSize ){
			if(me._scrollAbleList[me._cursorIndex] != nil){
				me._scrollAbleList[me._cursorIndex].select(0,me._cursorIndex);
			}
			
			me._cursorIndex = newIndex;
			
			if(me._scrollAbleList[me._cursorIndex] != nil){
				me._scrollAbleList[me._cursorIndex].select(1,me._cursorIndex);
			}	
		}
		
	},

	_onFplReadyChange : func(n){
		if(fms._flightPlan.isReady){
			
		}else{
			for( var i=0; i < fms._flightPlan.planSize; i+=1 ){
				me._fplItemCache[i].setDistance("---");
				me._fplItemCache[i].setETE("---");
				me._fplItemCache[i].setETA("---");
				me._fplItemCache[i].setFuel("---");
			}
		}
	},
	_onFplUpdatedChange : func(n){
		for( var i=0; i < fms._flightPlan.planSize; i+=1 ){
			if (i >= fms._flightPlan.currentWpIndex){
				me._fplItemCache[i].setDistance(sprintf("%0.1f",fms._flightPlan.wp[i].distanceTo));
				me._fplItemCache[i].setETE(global.formatTime(fms._flightPlan.wp[i].ete,"i:s"));
				me._fplItemCache[i].setETA(global.formatTime(fms._flightPlan.wp[i].eta));
				me._fplItemCache[i].setFuel(sprintf("%.0f",fms._flightPlan.wp[i].fuelAt));
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
