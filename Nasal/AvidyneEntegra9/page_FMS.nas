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

var FlighPlanItem = {
	new : func(canvasGroup,index){
		var m = {parents:[FlighPlanItem]};
		m._group = canvasGroup.createChild("group", "waypoint_"~index).set("z-index",3).setVisible(1);
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
		m._active = 0;
		m._selection = 0;

		return m;
	},
	setActive   :func(value){
		me._active = value;
		me._checkSelection();
	},
	setSelection   :func(value){
		me._selection = value;
		me._checkSelection();
	},
	_checkSelection : func(){
		if(me._active == 1){
			me._drawActive();
		}else{
			if(me._selection == 1 ){
				me._drawSelect();
			}else{
				me._drawNormal();
			}
		}
	},
	_drawActive : func(){
		me._can.Back.set("stroke",COLOR["Magenta"]);
		me._can.Back.set("stroke-width",3);
	},
	_drawSelect : func(){
		me._can.Back.set("stroke",COLOR["Turquoise"]);
		me._can.Back.set("stroke-width",3);
	},
	_drawNormal : func(){
		me._can.Back.set("stroke","none");
	}
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
			list			: m._group.getElementById("FPL_List"),
			ScrollCursorView	: m._group.getElementById("FPL_ScrollCursorView"),
			ScrollCursorCurrent	: m._group.getElementById("FPL_ScrollCursorCurrent"),
			
		};
		
		m._canList = {};
		m._scrollY = 0;
		m._selectedIndex = 0;
		m._lastSelectedIndex = 0;
		m._currentIndex = 0;
		m._lastCurrentIndex = 0;
		m._planSize = 0;
		m._maxScroll = 6;
		
		
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
		
		me._Page.IFD.nLedR5.setValue(1);
		me._Page.keys["R5 <"] 	= func(){me._deleteWaypoint();};
		me._Page.keys["R5 >"] 	= func(){me._deleteWaypoint();};
		
		me._Page.IFD.nLedRK.setValue(1);
		me._Page.keys["RK >>"] 	= func(){me._adjustSelection(-2);};
		me._Page.keys["RK <<"] 	= func(){me._adjustSelection(2);};
		me._Page.keys["RK"] 	= func(){extra500.fms.jumpTo()};
		me._Page.keys["RK >"] 	= func(){me._adjustSelection(-1);};
		me._Page.keys["RK <"] 	= func(){me._adjustSelection(1);};
		
		
	},
	deinit : func(){
		me.removeListeners();
		
		me._Page.IFD.nLedR5.setValue(0);
		me._Page.keys["R5 <"] 	= nil;
		me._Page.keys["R5 >"] 	= nil;
		
		me._Page.IFD.nLedRK.setValue(0);
		me._Page.keys["RK >>"] 	= nil;
		me._Page.keys["RK <<"] 	= nil;
		me._Page.keys["RK"] 	= nil;
		me._Page.keys["RK >"] 	= nil;
		me._Page.keys["RK <"] 	= nil;
		
		
	},
	_clearList : func(){
		me._scrollY = 0;
		me._can.list.removeAllChildren();
		me._fplItem = {};
	},
	_drawList : func(){
		
		fp = flightplan();
		me._planSize = fp.getPlanSize();
		var distSum = 0;
		for( var i=0; i < me._planSize; i+=1 ){
			var fmsWP = fp.getWP(i);
			
			me._fplItem[i] = FlighPlanItem.new(me._can.list,i);
			me._fplItem[i]._group.setTranslation(400,70+i*224);
			me._fplItem[i]._can.Headline.setText(sprintf("%s %03.0f - %s",fmsWP.fly_type,fmsWP.leg_bearing,fmsWP.wp_role));
			me._fplItem[i]._can.Name.setText(sprintf("%s - %s",fmsWP.wp_name,fmsWP.wp_type));
			
			var restriction = "";
			if (fmsWP.alt_cstr_type != nil) {
				restriction ~= "at : " ~ fmsWP.alt_cstr ~"ft ";
			}
			if (fmsWP.speed_cstr_type != nil) {
				restriction ~= "IAS : " ~ fmsWP.speed_cstr ~"kts ";
			}
			me._fplItem[i]._can.Ristriction.setText(restriction);
			if(fmsWP.leg_distance){
				distSum += fmsWP.leg_distance;
			}
			me._fplItem[i]._can.Distance.setText(sprintf("%0.1f",distSum));
			
			if( i == me._currentIndex){
				me._fplItem[i].setActive(1);
			}
			if( i == me._selectedIndex){
				me._fplItem[i].setSelection(1);
			}
			
		}
		me._resizeScroll();
		me._setSelection(0);
		me._scrollToCurrentIndex(0);
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
		me._can.ScrollCursorView.set("coord[1]",0);
		me._can.ScrollCursorView.set("coord[3]",me._scrollSize*6);
		me._can.ScrollCursorCurrent.setTranslation(0,70+me._currentIndex*me._scrollSize);
		me._can.ScrollCursorView.setTranslation(0,70+me._scrollY*me._scrollSize);
	},
	_scrollToCurrentIndex : func(index){
		
		me._scrollY = index;
		
		me._scrollY = global.clamp(me._scrollY,0,me._maxScroll);
		
		me._can.list.setTranslation(0,me._scrollY*-224);
		me._can.ScrollCursorView.setTranslation(0,70+me._scrollY*me._scrollSize);
		
	},
	_scrollToSelectedIndex : func(index){
		if (index < me._scrollY){
			me._scrollY = index;
		}
		if(index >  me._scrollY + 5 ){
			me._scrollY = index - 5;
		}
		me._scrollY = global.clamp(me._scrollY,0,me._maxScroll);
		
		me._can.list.setTranslation(0,me._scrollY*-224);
		me._can.ScrollCursorView.setTranslation(0,70+me._scrollY*me._scrollSize);
		
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

		
		me._can.ScrollCursorCurrent.setTranslation(0,70+me._currentIndex*me._scrollSize);
		me._setSelection(me._currentIndex);
		me._scrollToCurrentIndex(me._currentIndex);
		me._lastCurrentIndex = me._currentIndex;
		
	},
	_adjustSelection : func(amount){
		me._selectedIndex += amount;
		me._selectedIndex = global.clamp(me._selectedIndex,0,me._planSize-1);
		me._setSelection();
		me._scrollToSelectedIndex(me._selectedIndex);
		
	},
	_setSelection : func(index=nil){
		if (index!=nil){
			me._selectedIndex = index;
		}
		#print("FlightPlanWidget._setSelection() ... "~me._selectedIndex);
		if(me._fplItem[me._lastSelectedIndex] != nil){
			me._fplItem[me._lastSelectedIndex].setSelection(0);
		}
		if(me._fplItem[me._selectedIndex] != nil){
			me._fplItem[me._selectedIndex].setSelection(1);
		}
		
		extra500.fms.setSelectedWaypoint(me._selectedIndex);
		me._lastSelectedIndex = me._selectedIndex;
	},
	update : func(){
		fp = flightplan();
		var gs = getprop("/velocities/groundspeed-kt");
		var time = systime();
		var eteSum = 0;
		var distSum = 0;
		if(gs > 50){
			for( var i=0; i < me._planSize; i+=1 ){
				var fmsWP = fp.getWP(i);
				if (i == me._currentIndex){
					#distSum += fmsWP.leg_distance;
					distSum += getprop("/autopilot/route-manager/wp/dist");
					var ete = distSum / gs * 3600 ;
					var eta = time + ete;
					me._fplItem[i]._can.Distance.setText(sprintf("%0.1f",distSum));
					me._fplItem[i]._can.ETE.setText(global.formatTime(ete,"i:s"));
					me._fplItem[i]._can.ETA.setText(global.formatTime(eta));
				}elsif (i > me._currentIndex){
					distSum += fmsWP.leg_distance;
					var ete = distSum / gs * 3600 ;
					var eta = time + ete;
					me._fplItem[i]._can.Distance.setText(sprintf("%0.1f",distSum));
					me._fplItem[i]._can.ETE.setText(global.formatTime(ete,"i:s"));
					me._fplItem[i]._can.ETA.setText(global.formatTime(eta));
				}else{
					me._fplItem[i]._can.Distance.setText("---");
					me._fplItem[i]._can.ETE.setText("---");
					me._fplItem[i]._can.ETA.setText("---");
					
				}
				
			}
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
			Tab	 : TabWidget.new(m,m.page,"TabSelectMAP"),
			Com	 : ComWidget.new(m,m.page,"Com"),
			DirectTo : DirectToWidget.new(m,m.page,"DirectTo"),
			Tuning	 : TuningWidget.new(m,m.page,"Tuning"),
			TCAS	 : TcasWidget.new(m,m.page,"TCAS"),
			FPL	 : FlightPlanListWidget.new(m,m.page,"FPL-List"),
			currentWP : CurrentWaypointWidget.new(m,m.page,"Current-Info"),
			Headline : HeadlineWidget.new(m,m.page,"Headline"),
			
		};
		m._can = {
			side	 : m.page.getElementById("layer11").setVisible(0),
			
		};
		
		m._widget.Tab._tab = ["FPL","MapFPL","Info","Routes","UserWypts","Nearest","MapNearest"];
		
		
		return m;
	},
	init : func(instance=me){
		#print("AvidynePageFMS.init() ... ");
				
		me.setListeners(instance);
		
# 		foreach(widget;keys(me._widget)){
# 			#print("widget : "~widget);
# 			if(me._widget[widget] != nil){
# 				
# 				me._widget[widget].init();
# 			}
# 		}
		me._widget.Tab.init();
		me._widget.Com.init();
		me._widget.Headline.init();
		
		me.registerKeys();
		
		me.page.setVisible(1);
	},
	deinit : func(){
		me.page.setVisible(0);
		me.keys = {};
		me.removeListeners();
		
		foreach(widget;keys(me._widget)){
			if(me._widget[widget] != nil){
				me._widget[widget].deinit();
			}
		}
	},
	_initWidgetsForTab : func(index){
		me._can.side.setVisible(0);
		me._widget.DirectTo.deinit();
		me._widget.Tuning.deinit();
		me._widget.FPL.deinit();
		me._widget.currentWP.deinit();
		
		if (index == 0){ # FPL
			me._can.side.setVisible(1);
			me._widget.DirectTo.init();
			me._widget.Tuning.init();
			me._widget.TCAS.setVisible(1);;
			me._widget.FPL.init();
			me._widget.currentWP.init();
			
		}elsif(index == 1){ # MapFPL
			me._widget.TCAS.setVisible(0);
		
		}elsif(index == 2){ # Info
			me._can.side.setVisible(1);
			me._widget.DirectTo.init();
			me._widget.Tuning.init();
			me._widget.TCAS.setVisible(1);;
			me._widget.currentWP.init();
		}elsif(index == 3){ # Routes
			me._can.side.setVisible(1);
			me._widget.Tuning.init();
			me._widget.TCAS.setVisible(1);;
			me._widget.currentWP.init();
			
		}elsif(index == 4){ # UserWypts
			me._can.side.setVisible(1);
			me._widget.DirectTo.init();
			me._widget.Tuning.init();
			me._widget.TCAS.setVisible(1);;
			me._widget.currentWP.init();
		}elsif(index == 5){ # Nearest
			me._can.side.setVisible(1);
			me._widget.DirectTo.init();
			me._widget.Tuning.init();
			me._widget.TCAS.setVisible(1);;
			me._widget.currentWP.init();
		}elsif(index == 6){ # MapNearest
			me._widget.TCAS.setVisible(0);
		
		}else{
			
		}
	},
	update2Hz : func(now,dt){

		me._widget.FPL.update();
		
	},
	update20Hz : func(now,dt){
		

	
	},
};