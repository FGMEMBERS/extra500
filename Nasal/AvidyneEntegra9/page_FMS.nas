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
#      Last change:      Dirk Dittmann
#      Date:             28.08.2013
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
		append(me._listeners, setlistener("/autopilot/settings/dto-leg",func(n){me._onChange(n)},1,0));	
	},
	init : func(instance=me){
		#print("ActiveComWidget.init() ... ");
		me.setListeners(instance);
		
		me._Page.IFD.nLedR4.setValue(1);
		me._Page.keys["R4 <"] 	= func(){extra500.keypad.onD()};
		me._Page.keys["R4 >"] 	= func(){extra500.keypad.onD()};
		me._can.button.setVisible(1);
	},
	deinit : func(){
		me._can.button.setVisible(0);
		me._Page.IFD.nLedR4.setValue(0);
		me._Page.keys["R4 <"] 	= nil;
		me._Page.keys["R4 >"] 	= nil;
		me.removeListeners();
		
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
		
		m._group.setVisible(1);
		
		m._active = 0;
		m._selection = 0;

		return m;
	},
	setType : func(type){
		me._type = type;
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
};




var FlightPlanListWidget = {
	new : func(page,canvasGroup,name){
		var m = {parents:[FlightPlanListWidget,IfdWidget.new(page,canvasGroup,name)]};
		m._class 	= "FlightPlanListWidget";
		m._tab		= [];
		m._can		= {};
		m._fplItem	= {};
		m._can = {
			#Pattern_Waypoint	: m._group.getElementById("FPL_Pattern_Waypoint").setVisible(0),
			FlightPlan		: m._group.getElementById("FPL"),
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
		
		m._x = 400;
		m._y = 70;
		
		m._listTransform = m._can.FlightPlan.createTransform();
		
		return m;
	},
	setListeners : func(instance) {
		append(me._listeners, setlistener("/autopilot/route-manager/signals/waypoint-changed",func(n){me._onWaypointChange(n)},1,0));	
		append(me._listeners, setlistener("/sim/gui/dialogs/route-manager/selection",func(n){me._onSelectionChange(n)},1,0));	
		append(me._listeners, setlistener("/autopilot/route-manager/current-wp",func(n){me._onCurrentChange(n)},1,0));	
	},
	init : func(instance=me){
		#print("FlightPlanListWidget.init() ... ");
		me.setListeners(instance);	
	},
	deinit : func(){
		me.removeListeners();
				
	},
	setVisible : func(visible){
		me._visible = visible;
		me._checkKeys();
		me._can.FlightPlan.setVisible(me._visible);
	},
	_checkKeys  : func(){
		if(me._visible == 1 ){
				if (me._layout == "FPL"){
				me._Page.IFD.nLedR5.setValue(1);
				me._Page.keys["R5 <"] 	= func(){me._deleteWaypoint();};
				me._Page.keys["R5 >"] 	= func(){me._deleteWaypoint();};
			}else{
				me._Page.IFD.nLedR5.setValue(0);
				me._Page.keys["R5 <"] 	= nil;
				me._Page.keys["R5 >"] 	= nil;
			}
			me._Page.IFD.nLedRK.setValue(1);
			me._Page.keys["RK >>"] 	= func(){me._adjustSelection(-2);};
			me._Page.keys["RK <<"] 	= func(){me._adjustSelection(2);};
			me._Page.keys["RK"] 	= func(){extra500.fms.jumpTo()};
			me._Page.keys["RK >"] 	= func(){me._adjustSelection(-1);};
			me._Page.keys["RK <"] 	= func(){me._adjustSelection(1);};
		}else{
			me._Page.IFD.nLedR5.setValue(0);
			me._Page.keys["R5 <"] 	= nil;
			me._Page.keys["R5 >"] 	= nil;
			
			me._Page.IFD.nLedRK.setValue(0);
			me._Page.keys["RK >>"] 	= nil;
			me._Page.keys["RK <<"] 	= nil;
			me._Page.keys["RK"] 	= nil;
			me._Page.keys["RK >"] 	= nil;
			me._Page.keys["RK <"] 	= nil;
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
		me._can.list.removeAllChildren();
		me._fplItem = {};
		me._cursorModeInsert = 1;
	},
	_drawList : func(){
		
		fp = flightplan();
		me._planSize = fp.getPlanSize();
		var distSum = 0;
		for( var i=0; i < me._planSize; i+=1 ){
			var fmsWP = fp.getWP(i);
			
			me._fplItem[i] = FlighPlanItem_old.new(me._can.list,i,fmsWP.wp_type);
			me._fplItem[i]._group.setTranslation(me._x,me._y+i*224);
			
			#me._fplItem[i].setHeadline(sprintf("%s %03.0f - %s",fmsWP.fly_type,fmsWP.leg_bearing,fmsWP.wp_role));
			#me._fplItem[i].setName(sprintf("%s - %s",fmsWP.wp_name,fmsWP.wp_type));
			
			me._fplItem[i].setHeadline(sprintf("%s %03.0f",fmsWP.fly_type,fmsWP.leg_bearing));
			me._fplItem[i].setName(sprintf("%s",fmsWP.wp_name));
			
			var restriction = "";
			if (fmsWP.alt_cstr_type != nil) {
				restriction ~= "at : " ~ fmsWP.alt_cstr ~"ft ";
			}
			if (fmsWP.speed_cstr_type != nil) {
				restriction ~= "IAS : " ~ fmsWP.speed_cstr ~"kts ";
			}
			me._fplItem[i].setRestriction(restriction);
			if(me._planSize > 1){
				distSum += fmsWP.leg_distance;

			}
			me._fplItem[i].setDistance(sprintf("%0.1f",fmsWP.leg_distance));
			if( i == me._currentIndex){
				me._fplItem[i].setActive(1);
			}
			if( i == me._selectedIndex){
				me._fplItem[i].setSelection(1);
			}
			
		}
		me._resizeScroll();
		me._setSelection(me._planSize-1,"insert");
		me._scrollToCurrentIndex(me._planSize-1);
	},
	_resizeScroll : func(){
		if(me._planSize > 6){
			me._scrollSize = 1356 / me._planSize;
			me._maxScroll = me._planSize -6;
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
		flightplan().deleteWP(me._selectedIndex);
	},
	_onWaypointChange : func(n){
		var value = n.getValue();
		#print("FlightPlanWidget._onWaypointChange() ... " ~ value);
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
	_onCurrentChange : func(n){
		me._currentIndex = n.getValue();	
		if(me._currentIndex == nil){
			me._currentIndex = -1;
		}
		#print("FlightPlanWidget._onCurrentChange() ... "~me._currentIndex);
		
		
		if(me._fplItem[me._lastCurrentIndex] != nil){
			me._fplItem[me._lastCurrentIndex].setActive(0);
		}
		if(me._fplItem[me._currentIndex] != nil){
			me._fplItem[me._currentIndex].setActive(1);
		}

		
		me._can.ScrollCursorCurrent.setTranslation(0,me._y+me._currentIndex*me._scrollSize);
		me._setSelection(me._currentIndex);
		me._scrollToCurrentIndex(me._currentIndex);
		me._lastCurrentIndex = me._currentIndex;
		
	},
	_adjustSelection : func(amount){
		
		if(amount > 0){
			if(me._cursorModeInsert==1){
				me._selectedIndex += amount;
				me._selectedIndex = global.clamp(me._selectedIndex,0,me._planSize-1);
			}
			me._setSelection(me._selectedIndex,!me._cursorModeInsert);
		}elsif(amount < 0){
			if(me._cursorModeInsert==0){
				me._selectedIndex += amount;
				me._selectedIndex = global.clamp(me._selectedIndex,0,me._planSize-1);
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
		if(me._fplItem[me._lastSelectedIndex] != nil){
			me._fplItem[me._lastSelectedIndex].setSelection(0);
		}
		if(me._fplItem[me._selectedIndex] != nil){
			me._fplItem[me._selectedIndex].setSelection(1);
		}
		me._can.Cursor.setTranslation(0,me._selectedIndex*224);
		if(me._cursorModeInsert == 1){
			me._can.CursorSelect.setVisible(0);
			me._can.CursorInsert.setVisible(1);
			#me._can.CursorInsert.setTranslation(0,me._selectedIndex*224);
		}else{
			me._can.CursorInsert.setVisible(0);
			me._can.CursorSelect.setVisible(1);
			#me._can.CursorSelect.setTranslation(0,me._selectedIndex*224);
		}
		

		
			
		
		extra500.fms.setSelectedWaypoint(me._selectedIndex);
		me._lastSelectedIndex = me._selectedIndex;
	},
	update : func(){
		fp = flightplan();
		var gs = getprop("/velocities/groundspeed-kt");
		var fuelGalUs = getprop("/consumables/fuel/total-fuel-gal_us");
		var time = systime();
		var eteSum = 0;
		var distSum = 0;
		var dist = 0;
		if(gs > 50){
			for( var i=0; i < me._planSize; i+=1 ){
				var fmsWP = fp.getWP(i);
				if (i == me._currentIndex){
					#distSum += fmsWP.leg_distance;
					dist = getprop("/autopilot/route-manager/wp/dist");
					distSum += dist;
					var ete = dist / gs * 3600 ;
					var eta = time + ete;
# 					me._fplItem[i]._can.Distance.setText(sprintf("%0.1f",distSum));
# 					me._fplItem[i]._can.ETE.setText(global.formatTime(ete,"i:s"));
# 					me._fplItem[i]._can.ETA.setText(global.formatTime(eta));
# 					
					me._fplItem[i].setDistance(sprintf("%0.1f",dist));
					me._fplItem[i].setETE(global.formatTime(ete,"i:s"));
					me._fplItem[i].setETA(global.formatTime(eta));
					
					fuelGalUs -= extra500.fuelSystem._nFuelFlowGalUSpSec.getValue() * ete;
					me._fplItem[i].setFuel(sprintf("%.0f",fuelGalUs));
					
				}elsif (i > me._currentIndex){
					
					distSum += fmsWP.leg_distance;
					var ete = fmsWP.leg_distance / gs * 3600 ;
					var eta = time + (distSum / gs * 3600);
# 					me._fplItem[i]._can.Distance.setText(sprintf("%0.1f",distSum));
# 					me._fplItem[i]._can.ETE.setText(global.formatTime(ete,"i:s"));
# 					me._fplItem[i]._can.ETA.setText(global.formatTime(eta));
					
					me._fplItem[i].setDistance(sprintf("%0.1f",fmsWP.leg_distance));
					me._fplItem[i].setETE(global.formatTime(ete,"i:s"));
					me._fplItem[i].setETA(global.formatTime(eta));
					
					fuelGalUs -= extra500.fuelSystem._nFuelFlowGalUSpSec.getValue() * ete;
					me._fplItem[i].setFuel(sprintf("%.0f",fuelGalUs));
					
				}else{
					me._fplItem[i]._can.Distance.setText("---");
					me._fplItem[i]._can.ETE.setText("---");
					me._fplItem[i]._can.ETA.setText("---");
					
				}
				
			}
			setprop("/autopilot/route-manager/fuelAtDestinationGalUs",fuelGalUs);
		}
		
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
				me._widget[widget].deinit();
			}
		}
	},
	setVisible : func(visibility){
		me.IFD._widget.Headline.setVisible(visibility);
		me.IFD._widget.PlusData.setVisible(visibility);
		me.IFD.movingMap.setVisible(visibility);
		
		if(visibility == 1){
			me.registerKeys();
		}else{
			
		}
		me._widget.Tab.setVisible(visibility);
		me.page.setVisible(visibility);
	},
	_initWidgetsForTab : func(index){
# 		me._widget.DirectTo.deinit();
# 		me._widget.FPL.setVisible(0);
		#me.IFD._widget.PlusData.setVisible(0);
		
		if (index == 0){ # FPL
			me.IFD._widget.PlusData.setVisible(1);
			me._widget.FPL.setLayout("FPL");
			me._widget.FPL.setVisible(1);
			me.IFD.movingMap.setLayout("none");
			me._widget.MovingMapKnob.setVisible(0);
		}elsif(index == 1){ # MapFPL
			me.IFD._widget.PlusData.setVisible(0);
			me.IFD.movingMap.setLayout("split-left");
			me._widget.FPL.setLayout("split-right");
			me._widget.FPL.setVisible(1);
			me._widget.MovingMapKnob.setHand(0);
			me._widget.MovingMapKnob.setVisible(1);	
		}elsif(index == 2){ # Info
			me._widget.FPL.setVisible(0);
			me.IFD._widget.PlusData.setVisible(1);
			me.IFD.movingMap.setLayout("none");
			me._widget.MovingMapKnob.setVisible(0);
		}elsif(index == 3){ # Routes
			me._widget.FPL.setVisible(0);
			me.IFD._widget.PlusData.setVisible(1);
			me.IFD.movingMap.setLayout("none");
			me._widget.MovingMapKnob.setVisible(0);
		}elsif(index == 4){ # UserWypts
			me._widget.FPL.setVisible(0);
			me.IFD._widget.PlusData.setVisible(1);
			me.IFD.movingMap.setLayout("none");
			me._widget.MovingMapKnob.setVisible(0);
		}elsif(index == 5){ # Nearest
			me._widget.FPL.setVisible(0);
			me.IFD._widget.PlusData.setVisible(1);
			me.IFD.movingMap.setLayout("none");
			me._widget.MovingMapKnob.setVisible(0);
		}elsif(index == 6){ # MapNearest
			me._widget.FPL.setVisible(0);
			me.IFD._widget.PlusData.setVisible(0);
			me.IFD.movingMap.setLayout("split-left");
			me._widget.MovingMapKnob.setHand(0);
			me._widget.MovingMapKnob.setVisible(1);
		}else{
			
		}
	},
	update2Hz : func(now,dt){

		me._widget.FPL.update();
		
	},
	update20Hz : func(now,dt){
		

	
	},
};