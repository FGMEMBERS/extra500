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
		append(me._listeners, setlistener(fms._node.DirectTo,func(n){me._onDirectToChange(n)},1,0));	
		append(me._listeners, setlistener(fms._signal.fplReady,func(n){me._onFplReadyChange(n)},1,0));
		append(me._listeners, setlistener(fms._signal.selectedWpChange,func(n){me._onSelectedWpChange(n)},1,0));
		
	},
	init : func(instance=me){
		
	},
	deinit : func(){
		
		
	},
	check : func(){
		if (	(fms._node.DirectTo.getValue() == 1) or 
			( 
				(me._visibility == 1) and 
				(fms._flightPlan.isReady == 1) and 
				(fms._signal.selectedWpChange.getValue() >= 0)
			))
		{
			me._ifd.ui.bindKey("R4",{
				"<"	: func(){fms.directTo();},
				">"	: func(){fms.directTo();},
			});
			
		}else{
			me._ifd.ui.bindKey("R4");
		}
	},
	_onDirectToChange : func(n){
		if (n.getValue()==1){
			me._can.text.set("fill",COLOR["White"]);
			me._can.border.set("stroke",COLOR["Turquoise"]);
			me._can.border.set("stroke-width",20);
		}else{
			me._can.text.set("fill",COLOR["Turquoise"]);
			me._can.border.set("stroke",COLOR["Blue"]);
			me._can.border.set("stroke-width",10);
		}
		me.check();
	},
	_onFplReadyChange : func(n){
		me.check();
	},
	_onSelectedWpChange : func(n){
		me.check();
	},
	_onVisibiltyChange : func(){
		if(me._visibility == 1){
			me.setListeners(me);
			me._can.button.setVisible(1);
		}else{
			me.removeListeners();
			me._can.button.setVisible(0);
		}
		me.check();
	},
	
};

var InsertDeleteWidget = {
	new : func(page,canvasGroup,name){
		var m = {parents:[InsertDeleteWidget,IfdWidget.new(page,canvasGroup,name)]};
		m._class 	= "InsertDeleteWidget";
		m._tab		= [];
		m._can		= {};
		
		m._can = {
			button		: m._group.getElementById("InsertDelete").setVisible(0),
			text		: m._group.getElementById("InsertDelete_Text"),
			border		: m._group.getElementById("InsertDelete_Background"),
		};
		
				
		return m;
	},
	setListeners : func(instance) {
		append(me._listeners, setlistener(fms._signal.selectedWpChange,func(n){me._onSelectedWpChange(n)},1,0));
		
	},
	init : func(instance=me){
		
	},
	deinit : func(){
		
		
	},
	check : func(){
		if(me._visibility == 1){
			if (fms._signal.selectedWpChange.getValue() >= 0){
				me._can.text.setText("Delete");
				
				me._ifd.ui.bindKey("R5",{
					"<"	: func(){fms.deleteWaypoint();},
					">"	: func(){fms.deleteWaypoint();},
				});
				
			}else{
				me._can.text.setText("Insert");
				
				me._ifd.ui.bindKey("R5",{
					"<"	: func(){fms.insertWaypoint();},
					">"	: func(){fms.insertWaypoint();},
				});
			}
		}else{
			me._ifd.ui.bindKey("R5");
		}
	},
	_onSelectedWpChange : func(n){
		
		me.check();
	},
	
	_onVisibiltyChange : func(){
		if(me._visibility == 1){
			me.setListeners(me);
			me._can.button.setVisible(1);
		}else{
			me.removeListeners();
			me._can.button.setVisible(0);
		}
		me.check();
	},
	
};


var DialogWidget = {
	new : func(page,canvasGroup,name){
		var m = {parents:[DialogWidget,IfdWidget.new(page,canvasGroup,name)]};
		m._class 	= "DialogWidget";
		m._tab		= [];
		m._can		= {};
		
		m._can = {
			btnEnter		: m._group.getElementById("btnEnter").setVisible(0),
			btnEnterText		: m._group.getElementById("btnEnterText"),
			btnEnterBackground	: m._group.getElementById("btnEnterBackground"),
			
			btnCancel		: m._group.getElementById("btnCancel").setVisible(0),
			btnCancelText		: m._group.getElementById("btnCancelText"),
			btnCancelBackground	: m._group.getElementById("btnCancelBackground"),
		};
		
				
		return m;
	},
	setListeners : func(instance) {
				
	},
	check : func(){
		if(me._visibility == 1){
			me._ifd.ui.bindKey("R4",{
				"<"	: func(){me._Page.dialog.enter();},
				">"	: func(){me._Page.dialog.enter();},
			});
			me._ifd.ui.bindKey("R5",{
				"<"	: func(){me._Page.dialog.cancel();},
				">"	: func(){me._Page.dialog.cancel();},
			});
			
		}else{
			me._ifd.ui.bindKey("R4");
			me._ifd.ui.bindKey("R5");
			
		}
	},
	_onVisibiltyChange : func(){
		if(me._visibility == 1){
			me.setListeners(me);
			me._can.btnEnter.setVisible(1);
			me._can.btnCancel.setVisible(1);
			
		}else{
			me.removeListeners();
			me._can.btnEnter.setVisible(0);
			me._can.btnCancel.setVisible(0);
			
		}
		me.check();
	},
};


#########################################################################################

###############  FMS 2 ##################################################################

var FPL_COLOR = {
	Black : "#000000",
	runway : {
		back	: "#1f305c",
		inner	: "#1e5c92",
		
	},
	basic : {
		back	: "#303030",
		inner	: "#666666",
	},
	bug : {
		back	: "#BD5889",
		inner	: "#FE80C8",
	},
	Bug : {
		Background	: "#BD5889",
		Detail		: "#FE80C8",
		Procedures 	: "#FE80C8",
	},
	
	Airport : {
		Background	: "#1f305c",
		Detail		: "#1e5c92",
		Procedures 	: "#201c57",
		
	},
	Waypoint : {
		Background	: "#303030",
		Detail		: "#666666",
	},
	Cursor : {
		selected 	: "#00ffff",
		Background	: "#00eeee",
	},
	Font : {
		Normal 		: "#ffffff",
		Selected	: "#000000",
	}
};

var WaypointInterface2 = {
	new : func(){
		var m = {parents:[WaypointInterface2]};
		return m;
	},
	init : func(){},
	setType 	: func(type,role=nil){},
	setHeadline 	: func(v){},
	setICAO 	: func(v){},
	setRestriction  : func(v){},
	setETE 		: func(v){},
	setETA 		: func(v){},
	setDistance 	: func(v){},
	setFuel 	: func(v){},
	setActive   	: func(v){},
	setSelection    : func(v){},
	setBearing 	: func(v){},
	
	setSid 		: func(v){},
	setArrival	: func(v){},
	setApproach	: func(v){},
	setRunway	: func(v){},
	
};


var FlightPlanListViewItem = {
	new: func(){
		var m = { parents: [
			FlightPlanListViewItem,
			FactroryCacheInterface.new(),
			ListViewItem.new(),
		] };
		m._cursorOptionCount = 0;
		m._cursorOption = 0;
		return m;
	},
	setAction : func(type,value){
		print("FlightPlanListViewItem::setAction("~type~","~value~") ... abstract");
	},
	setCursorOption : func(v){
		me._cursorOption = v;
		print("FlightPlanListViewItem::setOption("~v~") ... abstract");
	},
	getCursorOption : func(){return me._cursorOption;},
	getCursorOptionAdjusted : func(amount){
		var next = -1;
		
		if (me._cursorOption == 0 and me._cursorOptionCount > 0){
			if (amount > 0){
				next = me._cursorOption + amount;
			}else{
				next = me._cursorOptionCount;
			}
		}else{
			next = me._cursorOption + amount;
		}
				
		if (next <= 0 or next > me._cursorOptionCount){
			next = -1
		}
		return next;
	},
	_updateView : func(){},
	
};


var FlightPlanItemTest = {
	new : func(canvasGroup,index){
		var m = {parents:[
			FlightPlanItemTest,
			WaypointInterface2.new(),
			FlightPlanListViewItem.new(),
 		]};
		m._bound._height = 270;
		m._group = canvasGroup.createChild("group", "waypoint_"~index).setVisible(1).set("z-index",3);
		canvas.parsesvg(m._group, "Models/instruments/IFDs/IFD_FMS_FPL_Item_Waypoint.svg",{
			"font-mapper": global.canvas.FontMapper
			}
		);
		m._can = {
			# General
			Background		: m._group.getElementById("FPL_Item_back"),
			Headline		: m._group.getElementById("FPL_Item_Headline"),
			ICAO 			: m._group.getElementById("FPL_Item_ICAO"),
			ICAO_back 		: m._group.getElementById("FPL_Item_ICAO_back").setVisible(0),
			Constrains 		: m._group.getElementById("FPL_Item_Constrains"),
			Focus 			: m._group.getElementById("FPL_Item_Focus").setVisible(0),
			
			# Detail
			Detail 			: m._group.getElementById("FPL_Item_Detail"),
			DetailBackground 	: m._group.getElementById("FPL_Item_Detail_back"),
			
			Distance 		: m._group.getElementById("Distance"),
			ETE	 		: m._group.getElementById("ETE"),
			ETE_Unit	 	: m._group.getElementById("ETE_unit"),
			Fuel	 		: m._group.getElementById("Fuel"),
			ETA			: m._group.getElementById("ETA"),
			
			# Constarains
			Constrains_edit		: m._group.getElementById("FPL_Item_Constrains_Edit").setVisible(0),
			Constain_before_back	: m._group.getElementById("Constain_before_back"),
			Constain_alt_back	: m._group.getElementById("Constain_alt_back"),
			Constain_at_back	: m._group.getElementById("Constain_at_back"),
		
		};
		
		
		return m;	
	},
	### implement WaypointInterface2
	
	### implement ListViewItem
	del 	: func(){

	},
	_updateView 	: func(){
		#print("FlightPlanItemAirport::_updateView() ...");
		me._group.setTranslation(me._bound._x,me._bound._y);
	},
};

var FlightPlanItemInsertCursor = {
	new : func(canvasGroup,index){
		#print("FlightPlanItemInsertCursor::new() ...");
		
		var m = {parents:[
			FlightPlanItemInsertCursor,
			WaypointInterface2.new(),
			FlightPlanListViewItem.new(),
 		]};
		m._class = "FlightPlanItemInsertCursor";
		m._bound._height = 8;
		m._group = canvasGroup.createChild("group", "InsertCursor_"~index).setVisible(0).set("z-index",3);
		canvas.parsesvg(m._group, "Models/instruments/IFDs/IFD_FMS_FPL_Item_InsertCursor.svg",{
			"font-mapper": global.canvas.FontMapper
			}
		);
		m._can = {
			Focus 			: m._group.getElementById("FPL_Item_Focus").setVisible(0),
		};
		m._cursorOptionCount = 0;
		return m;	
	},
	### implement WaypointInterface2
	init : func(){},
	
	### implement ListViewItem
	del 	: func(){
		
	},
	setVisible : func(v){me._group.setVisible(v)},
	setFocus : func(v){me._can.Focus.setVisible(v)},
	setAction : func(type,value){},
	_updateView : func(){
		#print("FlightPlanItemInsertCursor::_updateView() ...");
		#debug.dump(me._bound);
		#debug.dump(me._group);
		me._group.setTranslation(me._bound._x,me._bound._y);
	},
};

var FlightPlanItemAirport = {
	new : func(canvasGroup,index){
		#print("FlightPlanItemAirport::new() ...");
		var m = {parents:[
			FlightPlanItemAirport,
			WaypointInterface2.new(),
			FlightPlanListViewItem.new(),
 		]};
		m._class = "FlightPlanItemAirport";
		m._bound._height = 270;
		m._group = canvasGroup.createChild("group", "Airport_"~index).setVisible(0).set("z-index",3);
		canvas.parsesvg(m._group, "Models/instruments/IFDs/IFD_FMS_FPL_Item_Airport.svg",{
			"font-mapper": global.canvas.FontMapper
			}
		);
		m._can = {
			# General
			Background		: m._group.getElementById("FPL_Item_back"),
			Headline		: m._group.getElementById("FPL_Item_Headline"),
			ICAO 			: m._group.getElementById("FPL_Item_ICAO"),
			ICAO_back 		: m._group.getElementById("FPL_Item_ICAO_back").setVisible(0),
			Constrains 		: m._group.getElementById("FPL_Item_Constrains"),
			Focus 			: m._group.getElementById("FPL_Item_Focus").setVisible(0),
			
			# Airport 
			ProceduresBackground	: m._group.getElementById("Airport_Procedures_back"),
			ArrivalLabel 		: m._group.getElementById("Airport_Arrival_Label"),
			Arrival 		: m._group.getElementById("Airport_Arrival_Text"),
			ArrivalBackground 	: m._group.getElementById("Airport_Arrival_back"),
			ApproachLabel 		: m._group.getElementById("Airport_Approach_Label"),
			Approach 		: m._group.getElementById("Airport_Approach_Text"),
			ApproachBackground 	: m._group.getElementById("Airport_Approach_back"),
			
			
			# Detail
			Detail 			: m._group.getElementById("FPL_Item_Detail"),
			DetailBackground 	: m._group.getElementById("FPL_Item_Detail_back"),
			
			Distance 		: m._group.getElementById("Bearing_Distance"),
			Bearing 		: m._group.getElementById("Bearing_deg"),
			Runway 			: m._group.getElementById("Runway_Text"),
			RunwayBackground	: m._group.getElementById("Runway_back"),
		
		};
		
		m._cursorOptionCount 	= 4;
		m._origin 		= 0;
		m._icao 		= "";
		m._runway 		= "";
		m._arrival 		= "";
		m._sid 			= "";
		m._arrival 		= "";
		return m;	
	},
	### implement WaypointInterface2
	init : func(){
		if (me._data.variant == "Origin"){
			me._origin = 1;
			
			me.setHeadline("Origin");
			me.setICAO(fms._flightPlan.departure.icao);
			me.setConstrain(fms._flightPlan.departure.name);
			me.setSid(me._data.sid);
			me.setRunway(fms._flightPlan.departure.runway.id);
		}elsif(me._data.variant == "Arrival"){
			me._origin = 0;
			
			me.setHeadline("Destination");
			#item.setHeadline(sprintf("Destination %s %s",wp.role,wp.type));
			me.setICAO(fms._flightPlan.destination.icao);
			me.setConstrain(fms._flightPlan.destination.name);
			me.setArrival(me._data.arrival);
			me.setApproach(me._data.approach);
			me.setRunway(fms._flightPlan.destination.runway.id);
		}else{
			print("FlightPlanItemAirport::init() ... ERROR no variant");
			me._origin = 0;
		}
		
		
	},
	
	setHeadline 	: func(v){ me._can.Headline.setText(v);},
	setICAO 	: func(v){ me._icao = v; me._can.ICAO.setText(v);},
	setConstrain 	: func(v){ me._can.Constrains.setText(v);},
	setApproach	: func(v){ 
		me._can.Approach.setVisible(1);
		me._can.ApproachBackground.setVisible(1);
		v = (v == "" ? "---.---" : v);
		me._can.Approach.setText(v);
	},
	setArrival	: func(v){ 
		me._arrival = v;
		me._can.Arrival.setVisible(1);
		me._can.ArrivalBackground.setVisible(1);
		me._can.ArrivalLabel.setText("Arrival:");
		v = (v == "" ? "---" : v);
		me._can.Arrival.setText(v);
	},
	setSid	: func(v){ 
		me._sid = v;
		me._can.ArrivalLabel.setVisible(0);
		me._can.Arrival.setVisible(0);
		me._can.ArrivalBackground.setVisible(0);
		
		me._can.ApproachLabel.setText("Sid:");
		v = (v == "" ? "---.---" : v);
		me._can.Approach.setText(v);
	},
	setRunway	: func(v){ 
		me._runway = v;
		v = (v == "" ? "---" : v);
		me._can.Runway.setText(v);
	},
	setActive   	: func(v){
		if (v == 1){
			me._can.Background.setColorFill(FPL_COLOR.Bug.Background);
			me._can.DetailBackground.setColorFill(FPL_COLOR.Bug.Detail);
			me._can.ProceduresBackground.setColorFill(FPL_COLOR.Bug.Procedures);
			
		}else{
			me._can.Background.setColorFill(FPL_COLOR.Airport.Background);
			me._can.DetailBackground.setColorFill(FPL_COLOR.Airport.Detail);
			me._can.ProceduresBackground.setColorFill(FPL_COLOR.Airport.Procedures);
		}
	},
	### implement FlightPlanListViewItem
	# Override normal adjust scip on option if departure
	getCursorOptionAdjusted : func(amount){
		var next = -1;
		
		if (me._cursorOption == 0 and me._cursorOptionCount > 0){
			if (amount > 0){
				next = me._cursorOption + amount;
				if (me._origin==1 and next==1){
					next = 2;
				}
			}else{
				next = me._cursorOptionCount;
			}
		}else{
			next = me._cursorOption + amount;
			
			if (amount < 0){
				if (me._origin==1 and next==1){
					next = 0;
				}
			}else{
				if (me._origin==1 and next==1){
					next = 2;
				}
			}
		}
				
		if (next <= 0 or next > me._cursorOptionCount){
			next = -1
		}
		return next;
	},
	
	setCursorOption : func(v){
		print("FlightPlanItemAirport::setCursorOption("~v~") ...");
		me._cursorOption = v;
		me._checkCursorOption();
	},
	_checkCursorOption : func(option = nil){
		if(option!=nil){
			me._cursorOption = option;
		}
		me._can.ArrivalBackground.set("stroke","");
		me._can.ArrivalBackground.set("fill",FPL_COLOR.Black);
		me._can.Arrival.setColor(FPL_COLOR.Font.Normal);
		
		me._can.ApproachBackground.set("stroke","");
		me._can.ApproachBackground.set("fill",FPL_COLOR.Black);
		me._can.Approach.setColor(FPL_COLOR.Font.Normal);
		
		me._can.ICAO_back.set("stroke","");
		me._can.ICAO_back.set("fill",FPL_COLOR.Black);
		me._can.ICAO.setColor(FPL_COLOR.Font.Normal);
				
		me._can.RunwayBackground.set("stroke","");
		me._can.RunwayBackground.set("fill",FPL_COLOR.Black);
		me._can.Runway.setColor(FPL_COLOR.Font.Normal);
		
				
		if (me._cursorOption == 0){
			me._can.ICAO_back.setVisible(0);
			
			me._parent._checkKeys();
		}else{
			me._can.ICAO_back.setVisible(1);
				
			
			
			me._parent._ifd.ui.bindKnob("RK",{
				"<<"	: func(){me._parent._adjustCursorFocus(1);},
				"<"	: func(){me._parent._adjustCursorOption(1);},
				"push"	: func(){me._onOptionDialogOpen();},
				">"	: func(){me._parent._adjustCursorOption(-1);},
				">>"	: func(){me._parent._adjustCursorFocus(-1);},
			},{
				"scroll"	: "Scroll",
				"push"		: "edit",
			});
			
			
			if (me._cursorOption == 1){
				print("\t Airport Arrival");
				me._can.ArrivalBackground.set("stroke",FPL_COLOR.Cursor.selected);
			}elsif (me._cursorOption == 2){
				print("\t Airport Sid/Approach");
				me._can.ApproachBackground.set("stroke",FPL_COLOR.Cursor.selected);
			}elsif (me._cursorOption == 3){
				print("\t Airport ICAO");
				me._can.ICAO_back.set("stroke",FPL_COLOR.Cursor.selected);
			}elsif (me._cursorOption == 4){
				print("\t Airport Runway");
				me._can.RunwayBackground.set("stroke",FPL_COLOR.Cursor.selected);
			}
		}
	},
	_onOptionDialogOpen : func(){
		
		if (me._cursorOption == 1){# Arrival
			print("\t Airport Arrival");
			me._can.ArrivalBackground.set("stroke",FPL_COLOR.Cursor.selected);
			me._can.ArrivalBackground.set("fill",FPL_COLOR.Cursor.Background);
			me._can.Arrival.setColor(FPL_COLOR.Font.Selected);
			
			if( !me._origin ){
				
				me._parent._Page.dialog.create("Select");
				
				var x = 0;
				var y = 0;
				
				x = me._can.ArrivalBackground.getTightBoundingBox()[0];
				y = me._bound._y + me._parent._listViewTransform.f.getValue() ; 
				
				me._parent._Page.dialog.setValue(me._arrival);
				
				var arrivalList = nil;
					
				arrivalList = fms.getDestinationArrivalList();
				
				me._parent._Page.dialog.setData(arrivalList);
				
				me._parent._Page.dialog.setPosition(x,y);
				
				me._parent._Page.dialog.setCallBack({
					onUpdate	: func{me._onArrivalChange();},
				});
				me._parent._Page.dialog.open();
			}
			
			
			
		}elsif (me._cursorOption == 2){# SID / Approch
			print("\t Airport Sid/Approach");
			me._can.ApproachBackground.set("stroke",FPL_COLOR.Cursor.selected);
			me._can.ApproachBackground.set("fill",FPL_COLOR.Cursor.Background);
			me._can.Approach.setColor(FPL_COLOR.Font.Selected);
			
			me._parent._Page.dialog.create("Select");
				
			var dataList 	= nil;
			var value	= "";
			if(me._origin){
				value		= me._sid;
				dataList 	= fms.getOriginSidList();
			}else{
				value		= me._arrival;
				dataList 	= fms.getDestinationApproachList();
			}
			
			var x = 0;
			var y = 0;
			
			x = me._can.ApproachBackground.getTightBoundingBox()[0];
			y = me._bound._y + me._parent._listViewTransform.f.getValue() ; 
			
			me._parent._Page.dialog.setValue(value);
						
			me._parent._Page.dialog.setData(dataList);
			
			me._parent._Page.dialog.setPosition(x,y);
			
			me._parent._Page.dialog.setCallBack({
				onUpdate	: func{me._onSidApproachChange();},
			});
			
			me._parent._Page.dialog.open();
		
			
			
		}elsif (me._cursorOption == 3){ # ICAO
			me._can.ICAO_back.set("stroke",FPL_COLOR.Cursor.selected);
			me._can.ICAO_back.set("fill",FPL_COLOR.Cursor.Background);
			me._can.ICAO.setColor(FPL_COLOR.Font.Selected);
		}elsif (me._cursorOption == 4){ # Runway
			print("\t Airport Runway");
			me._can.RunwayBackground.set("stroke",FPL_COLOR.Cursor.selected);
			me._can.RunwayBackground.set("fill",FPL_COLOR.Cursor.Background);
			me._can.Runway.setColor(FPL_COLOR.Font.Selected);
			
			me._parent._Page.dialog.create("Select");
			
			var x = 0;
			var y = 0;
			
			x = me._can.RunwayBackground.getTightBoundingBox()[0];
			y = me._bound._y + me._parent._listViewTransform.f.getValue() ; 
			
			me._parent._Page.dialog.setValue(me._runway);
			
			var runwayList = nil;
			if(me._origin){
				runwayList = fms.getOriginRunwayList();
			}else{
				runwayList = fms.getDestinationRunwayList();
			}
			
			me._parent._Page.dialog.setData(runwayList);
			me._parent._Page.dialog.setPosition(x,y);
			
			me._parent._Page.dialog.setCallBack({
				onUpdate	: func{me._onRunwayChange();},
			});
				
			me._parent._Page.dialog.open();
		}
	},
	_onRunwayChange : func(){
		
		me.setRunway(me._parent._Page.dialog.getValue());
			
		if(me._parent._Page.dialog.getStatus() == GuiDialog.STATUS.CANCEL){
			
			me._parent._Page.dialog.close();
			me._parent._Page.dialog.destruct();
			
		}elsif (me._parent._Page.dialog.getStatus() == GuiDialog.STATUS.OK){
			
			if(me._origin){
				fms.setOriginRunway(me._parent._Page.dialog.getValue());
			}else{
				fms.setDestinationRunway(me._parent._Page.dialog.getValue());
			}
			
			
			me._parent._Page.dialog.close();
			me._parent._Page.dialog.destruct();
			
			me._checkCursorOption(0);
		}elsif (me._parent._Page.dialog.getStatus() == GuiDialog.STATUS.CHANGE){
			
		}
		
		
	},
	_onArrivalChange : func(){
		if(me._origin){
				
		}else{
			me.setArrival(me._parent._Page.dialog.getValue());
		}
		
		if(me._parent._Page.dialog.getStatus() == GuiDialog.STATUS.CANCEL){
			
			me._parent._Page.dialog.close();
			me._parent._Page.dialog.destruct();
			
			
		}elsif (me._parent._Page.dialog.getStatus() == GuiDialog.STATUS.OK){
			
			if(me._origin){
				
			}else{
				fms.setDestinationArrival(me._parent._Page.dialog.getValue());
			}
			
			me._parent._Page.dialog.close();
			me._parent._Page.dialog.destruct();
			
			me._checkCursorOption(0);
		}elsif (me._parent._Page.dialog.getStatus() == GuiDialog.STATUS.CHANGE){
			
		}
		
		
		
		
	},
	_onSidApproachChange : func(){
		
		if(me._origin){
			me.setSid(me._parent._Page.dialog.getValue());
		}else{
			me.setApproach(me._parent._Page.dialog.getValue());
		}	
			
		if(me._parent._Page.dialog.getStatus() == GuiDialog.STATUS.CANCEL){
			
			me._parent._Page.dialog.close();
			me._parent._Page.dialog.destruct();
			
			
		}elsif (me._parent._Page.dialog.getStatus() == GuiDialog.STATUS.OK){
			
			if(me._origin){
				fms.setOriginSid(me._parent._Page.dialog.getValue());
			}else{
				fms.setDestinationApproach(me._parent._Page.dialog.getValue());
			}
			
			me._parent._Page.dialog.close();
			me._parent._Page.dialog.destruct();
			
			me._checkCursorOption(0);
		}elsif (me._parent._Page.dialog.getStatus() == GuiDialog.STATUS.CHANGE){
		
			
			
		}
		
		
		
		
	},
	
	
	### implement ListViewItem
	del 	: func(){

	},
	setVisible 	: func(v){ me._group.setVisible(v)},
	setFocus 	: func(v){ me._can.Focus.setVisible(v)},
	setAction 	: func(type,value){},
	_updateView 	: func(){
		#print("FlightPlanItemAirport::_updateView() ...");
		me._group.setTranslation(me._bound._x,me._bound._y);
	},
};

var FlightPlanItemWaypoint = {
	new : func(canvasGroup,index){
		#print("FlightPlanItemWaypoint::new() ...");
		var m = {parents:[
			FlightPlanItemWaypoint,
			WaypointInterface2.new(),
			FlightPlanListViewItem.new(),
 		]};
		m._class = "FlightPlanItemWaypoint";
		m._bound._height = 210;
		m._group = canvasGroup.createChild("group", "Waypoint_"~index).setVisible(0).set("z-index",3);
		canvas.parsesvg(m._group, "Models/instruments/IFDs/IFD_FMS_FPL_Item_Waypoint.svg",{
			"font-mapper": global.canvas.FontMapper
			}
		);
		m._can = {
			# General
			Background		: m._group.getElementById("FPL_Item_back"),
			Headline		: m._group.getElementById("FPL_Item_Headline"),
			ICAO 			: m._group.getElementById("FPL_Item_ICAO"),
			ICAO_back 		: m._group.getElementById("FPL_Item_ICAO_back").setVisible(0),
			Constrains 		: m._group.getElementById("FPL_Item_Constrains"),
			Focus 			: m._group.getElementById("FPL_Item_Focus").setVisible(0),
			
			# Detail
			Detail 			: m._group.getElementById("FPL_Item_Detail"),
			DetailBackground 	: m._group.getElementById("FPL_Item_Detail_back"),
			
			Distance 		: m._group.getElementById("Distance"),
			ETE	 		: m._group.getElementById("ETE"),
			ETE_Unit	 	: m._group.getElementById("ETE_unit"),
			Fuel	 		: m._group.getElementById("Fuel"),
			ETA			: m._group.getElementById("ETA"),
			
			# Constarains
			Constrains_edit		: m._group.getElementById("FPL_Item_Constrains_Edit").setVisible(0),
			Constain_icao		: m._group.getElementById("Constain_icao"),
			Constain_before		: m._group.getElementById("Constain_before"),
			Constain_before_unit	: m._group.getElementById("Constain_before_unit"),
			Constain_before_back	: m._group.getElementById("Constain_before_back"),
			Constain_at		: m._group.getElementById("Constain_at"),
			Constain_at_back	: m._group.getElementById("Constain_at_back"),
			Constain_alt		: m._group.getElementById("Constain_alt"),
			Constain_alt_unit	: m._group.getElementById("Constain_alt_unit"),
			Constain_alt_back	: m._group.getElementById("Constain_alt_back"),
			
		};
		
		m._cursorOptionCount = 4;
		
		return m;	
	},
	
	setConstrainBefore 	 : func(v){	me._can.Constain_before.setText(sprintf("%.1f",v));},
	setConstrainAt		 : func(v){	me._can.Constain_at.setText(v);},
	setConstrainAlt 	 : func(v){	me._can.Constain_alt.setText(sprintf("%i",v));},
	getConstrainText	 : func(){
		var txt = "cross";
		if (me._data.constraint.before.type != nil){
			txt ~= sprintf(" %.1f nm before",me._data.constraint.before.value);
		}
		txt ~= sprintf(" %s",me._data.name);
		if (me._data.constraint.alt.type != nil){
			txt ~= sprintf(" %s %.0f ft",me._data.constraint.alt.type, me._data.constraint.alt.value);
		}
		
		return txt;
	},
	### implement WaypointInterface2
	init : func(){
		me.setHeadline(sprintf("%s (%03.0f°)",me._data.flyType,me._data.course));
		#me.setHeadline(sprintf("%s (%03.0f°) %s %s ",me._data.flyType,me._data.course,me._data.role,me._data.type ));
		
		me.setICAO(sprintf("%s",me._data.name));
				
		me.setConstrain(me.getConstrainText());
		
		me.setDistance(sprintf("%0.1f",me._data.distanceTo));

		
	},
	
	setHeadline 	: func(v){ me._can.Headline.setText(v);},
	setICAO 	: func(v){ me._can.ICAO.setText(v);me._can.Constain_icao.setText(v);},
	setConstrain 	: func(v){ me._can.Constrains.setText(v);},
	setETE 		: func(v){ me._can.ETE.setText(v);},
	setETA 		: func(v){ me._can.ETA.setText(v);},
	setDistance 	: func(v){ me._can.Distance.setText(v);},
	setFuel 	: func(v){ me._can.Fuel.setText(v);},
	setActive   	: func(v){
		if (v == 1){
			me._can.Background.setColorFill(FPL_COLOR.Bug.Background);
			me._can.DetailBackground.setColorFill(FPL_COLOR.Bug.Detail);
		}else{
			me._can.Background.setColorFill(FPL_COLOR.Waypoint.Background);
			me._can.DetailBackground.setColorFill(FPL_COLOR.Waypoint.Detail);
		}
	},
	### implement FlightPlanListViewItem
	setCursorOption : func(v){
		print("FlightPlanItemWaypoint::setCursorOption("~v~") ...");
		me._cursorOption = v;
		me._checkCursorOption();
	},
	_checkCursorOption : func(){
		
		me._can.ICAO_back.set("stroke","");
		me._can.ICAO_back.set("fill",FPL_COLOR.Black);
		me._can.ICAO.setColor(FPL_COLOR.Font.Normal);
		
		
		me._can.Constain_before_back.set("stroke","");
		me._can.Constain_before_back.set("fill",FPL_COLOR.Black);
		me._can.Constain_before.setColor(FPL_COLOR.Font.Normal);
		me._can.Constain_before_unit.setColor(FPL_COLOR.Font.Normal);
			
		me._can.Constain_at_back.set("stroke","");
		me._can.Constain_at_back.set("fill",FPL_COLOR.Black);
		me._can.Constain_at.setColor(FPL_COLOR.Font.Normal);
		
		me._can.Constain_alt_back.set("stroke","");
		me._can.Constain_alt_back.set("fill",FPL_COLOR.Black);
		me._can.Constain_alt.setColor(FPL_COLOR.Font.Normal);
		me._can.Constain_alt_unit.setColor(FPL_COLOR.Font.Normal);
			
		
		if (me._cursorOption == 0){
			me._can.Constrains_edit.setVisible(0);
			me._can.ICAO_back.setVisible(0);
			me._can.Constrains.setVisible(1);
			#me._can.Focus.setVisible(1);
			
			
			
			
			me.setConstrain(me.getConstrainText());
			me._parent._checkKeys();
		}else{
			#me._can.Focus.setVisible(0);
			me._can.Constrains.setVisible(0);
			me._can.Constrains_edit.setVisible(1);
			me._can.ICAO_back.setVisible(1);
			
			
			
			me.setConstrainBefore(me._data.constraint.before.value);
			me.setConstrainAt(me._data.constraint.alt.type);
			me.setConstrainAlt(me._data.constraint.alt.value);
				
				
			
			me._parent._ifd.ui.bindKnob("RK",{
					"<<"	: func(){me._parent._adjustCursorFocus(1);},
					"<"	: func(){me._parent._adjustCursorOption(1);},
					"push"	: func(){me._onOptionDialogOpen();},
					">"	: func(){me._parent._adjustCursorOption(-1);},
					">>"	: func(){me._parent._adjustCursorFocus(-1);},
				},{
					"scroll"	: "Scroll",
					"push"		: "edit",
				});
			
			if (me._cursorOption == 1){
				print("\t Waypoint ICAO");
				me._can.ICAO_back.set("stroke",FPL_COLOR.Cursor.selected);
			#debug.dump(me._parent);
								
			}elsif (me._cursorOption == 2){
				print("\t Waypoint before");
				me._can.Constain_before_back.set("stroke",FPL_COLOR.Cursor.selected);
				#me._parent._Page.dialog.setCallBack(func() {me._onConstrainBeforeChange();});
				#me._parent._Page.dialog.setValue(fms._flightPlan.wp[i].)
				
				
			}elsif (me._cursorOption == 3){
				print("\t Waypoint restriction at or above");
				me._can.Constain_at_back.set("stroke",FPL_COLOR.Cursor.selected);
				
			}elsif (me._cursorOption == 4){
				print("\t Waypoint alt");
				me._can.Constain_alt_back.set("stroke",FPL_COLOR.Cursor.selected);
				
			}else{
				print("\t Waypoint ERROR unknown cursorOption");
			}
		}
	},
	_onConstrainBeforeChange : func(){
			
		me.setConstrainBefore(me._parent._Page.dialog.getValue());
			
		if(me._parent._Page.dialog.getStatus() == GuiDialog.STATUS.CANCEL){
			
			me._parent._Page.dialog.close();
			me._parent._Page.dialog.destruct();
			
			
		}elsif (me._parent._Page.dialog.getStatus() == GuiDialog.STATUS.OK){
			
			me._data.setConstrainBefore(me._parent._Page.dialog.getValue());
			
			me._checkCursorOption();
			
			me._parent._Page.dialog.close();
			me._parent._Page.dialog.destruct();
			
			
		}elsif (me._parent._Page.dialog.getStatus() == GuiDialog.STATUS.CHANGE){
			
			

			
		}
	},
	_onConstrainAltChange : func(){
		me.setConstrainAlt(me._parent._Page.dialog.getValue());
		
		if(me._parent._Page.dialog.getStatus() == GuiDialog.STATUS.CANCEL){
			
			
			me._parent._Page.dialog.close();
			me._parent._Page.dialog.destruct();
			
			
		}elsif (me._parent._Page.dialog.getStatus() == GuiDialog.STATUS.OK){
			
			me._data.setConstrainAlt(me._parent._Page.dialog.getValue());
			
			me._checkCursorOption();
			
			me._parent._Page.dialog.close();
			me._parent._Page.dialog.destruct();
			
			
		}elsif (me._parent._Page.dialog.getStatus() == GuiDialog.STATUS.CHANGE){
			
			
		}
		
				
	},
	_onConstrainAtChange : func(){
		
		me.setConstrainAt(me._parent._Page.dialog.getValue());
				
		if(me._parent._Page.dialog.getStatus() == GuiDialog.STATUS.CANCEL){
			
			me._parent._Page.dialog.close();
			me._parent._Page.dialog.destruct();
			
			
		}elsif (me._parent._Page.dialog.getStatus() == GuiDialog.STATUS.OK){
			
			me._data.setConstrainAt(me._parent._Page.dialog.getValue());
			
			me._checkCursorOption();
			
			me._parent._Page.dialog.close();
			me._parent._Page.dialog.destruct();
			
		}elsif (me._parent._Page.dialog.getStatus() == GuiDialog.STATUS.CHANGE){
			
			
			
		}
		
		
		
		
	},
	_onOptionDialogOpen : func(){
		if (me._cursorOption == 1){
				me._can.ICAO_back.set("stroke",FPL_COLOR.Cursor.selected);
				me._can.ICAO_back.set("fill",FPL_COLOR.Cursor.Background);
				me._can.ICAO.setColor(FPL_COLOR.Font.Selected);
				
			
		}elsif (me._cursorOption == 2){
			
				me._can.Constain_before_back.set("stroke",FPL_COLOR.Cursor.selected);
				me._can.Constain_before_back.set("fill",FPL_COLOR.Cursor.Background);
				me._can.Constain_before.setColor(FPL_COLOR.Font.Selected);
				me._can.Constain_before_unit.setColor(FPL_COLOR.Font.Selected);
				
				me._parent._Page.dialog.create("Number");
			
				me._parent._Page.dialog.setCallBack({
					onUpdate	: func{me._onConstrainBeforeChange();},
				});
				me._parent._Page.dialog.setFormat(global.format.PositiveFloat);
				me._parent._Page.dialog.setValue(me._data.constraint.before.value);
				me._parent._Page.dialog.setAmount([0.1,1.0]);
				me._parent._Page.dialog.open();
				
		}elsif (me._cursorOption == 3){
				me._can.Constain_at_back.set("stroke",FPL_COLOR.Cursor.selected);
				me._can.Constain_at_back.set("fill",FPL_COLOR.Cursor.Background);
				me._can.Constain_at.setColor(FPL_COLOR.Font.Selected);
				
				
				me._parent._Page.dialog.create("Select");
			
				
				var x = 0;
				var y = 0;
				 
				
				x = me._can.Constain_at_back.getTightBoundingBox()[0];
				y = me._bound._y + me._parent._listViewTransform.f.getValue() ; 
				
				
				me._parent._Page.dialog.setValue(me._data.constraint.alt.type);
				me._parent._Page.dialog.setData([
					"above",
					"at or above",
					"at",
					"at or below",
					"below"
				]);
				me._parent._Page.dialog.setPosition(x,y);
				
				me._parent._Page.dialog.setCallBack({
					onUpdate	: func{me._onConstrainAtChange();},
				});
				me._parent._Page.dialog.open();
				
				
		}elsif (me._cursorOption == 4){
				me._can.Constain_alt_back.set("stroke",FPL_COLOR.Cursor.selected);
				me._can.Constain_alt_back.set("fill",FPL_COLOR.Cursor.Background);
				me._can.Constain_alt.setColor(FPL_COLOR.Font.Selected);
				me._can.Constain_alt_unit.setColor(FPL_COLOR.Font.Selected);
		
				me._parent._Page.dialog.create("Number");
				
				me._parent._Page.dialog.setCallBack({
					onUpdate	: func{me._onConstrainAltChange();},
				});
				me._parent._Page.dialog.setFormat(global.format.FlightLevelInFeet);
				me._parent._Page.dialog.setValue(me._data.constraint.alt.value);
				me._parent._Page.dialog.setAmount([100,1000]);
				me._parent._Page.dialog.open();
				
			
			
		}else{
			
		}
	},
	### implement ListViewItem
	del 	: func(){

	},
	setVisible 	: func(v){ me._group.setVisible(v)},
	setFocus 	: func(v){ me._can.Focus.setVisible(v)},
	setAction 	: func(type,value){},
	_updateView 	: func(){
		#print("FlightPlanItemWaypoint::_updateView() ...");
		me._group.setTranslation(me._bound._x,me._bound._y);
	},
	
};

var FactroryCacheInterface = {
	new : func(){
		var m = {parents:[
			FactroryCacheInterface,
 		]};
		m._data 	= nil;
		m._parent 	= nil;
		return m;
	},
	setData		: func(data){me._data = data;},
	setParent	: func(parent){me._parent = parent;},
	init		: func(){},
};

var FactroryCache = {
	new : func(name,constructor){
		var m = {parents:[
			FactroryCache,
 		]};
		m._parent = nil;
		m._name 	= name;
		m._constructor 	= constructor;
		m._unUsed 	= [];
		m._used 	= [];
		m._count 	= 0;
		return m;
	},
	setParent : func(parent){
		me._parent = parent;
	},
	removeAll : func(){
		#print(sprintf("FactroryCache::removeAll() ... %s",me._name));
		var item = nil;
		var usedSize = size(me._used);
		for(var i=0; i < usedSize; i = i+1){
			item = pop(me._used);
			item.setVisible(0);
			append(me._unUsed,item);
		}
		#me.printCache();
	},
	getItem : func(data,canvasGrp){
		#print(sprintf("FactroryCache::getItem() ... %s",me._name));
		var item = pop(me._unUsed);
		if(item == nil){
			#print(sprintf("FactroryCache::getItem() ... create %s" , me._name));
			me._count += 1;
			item = me._constructor(canvasGrp,me._count);
			
			append(me._used,item);
		}else{
			#print(sprintf("FactroryCache::getItem() ... get %s from Cache",me._name));
			append(me._used,item);
		}
		item.setData(data);
		item.setParent(me._parent);
		item.init();
		
		#me.printCache();
		return item;
	},
	printCache : func(){
		print(sprintf("FactroryCache::printCache() ... Cache for %s",me._name));
		
		var sizeUsed 	= size(me._used);
		var sizeUnUsed 	= size(me._unUsed);
		
		print("\tused\tunused");
		for(var i=0; i < me._count; i = i+1){
			var line = "";
			
			if (i < sizeUsed ){
				line ~= "\tX";
			}else{
				line ~= "\t_";
			}
			
			if (i < sizeUnUsed ){
				line ~= "\tX";
			}else{
				line ~= "\t_";
			}
			
			print(line);
		}
		
	},
};

var FlightPlanItemFactory = {
	new : func(){
		var m = {parents:[
			FlightPlanItemFactory,
 		]};
		m._parent = nil;
		m._Cursor = FactroryCache.new("Cursor",FlightPlanItemInsertCursor.new);
		m._Airport = FactroryCache.new("Airport",FlightPlanItemAirport.new);
		m._Waypoint = FactroryCache.new("Waypoint",FlightPlanItemWaypoint.new);
		
		return m;
	},
	setParent : func(parent){
		me._parent = parent;
		me._Cursor.setParent(parent);
		me._Airport.setParent(parent);
		me._Waypoint.setParent(parent);
		
	},
	removeAll : func(){
		me._Cursor.removeAll();
		me._Airport.removeAll();
		me._Waypoint.removeAll();
		
	},
	getItem : func(data,type,canvasGrp){
		#print(sprintf("FlightPlanItemFactory::getItem(%s,%s,%s) ...",type,"canvasGroup",index));
		var item = nil;
		if (type == "Airport"){
			item = me._Airport.getItem(data,canvasGrp);
		}elsif (type == "Cursor"){
			item = me._Cursor.getItem(data,canvasGrp);
		}else{
			item = me._Waypoint.getItem(data,canvasGrp);
		}
		return item;	
	},
};

var FlightPlanListWidget2 = {
	new : func(page,canvasGroup,name){
		var m = {parents:[FlightPlanListWidget2,
			IfdWidget.new(page,canvasGroup,name),
			ListViewListener.new(),
			
 		]};
		m._class 	= "FlightPlanListWidget2";
		m._tab		= [];
		m._can		= {};
		m._can = {
			#Pattern_Waypoint	: m._group.getElementById("FPL_Pattern_Waypoint").setVisible(0),
			FlightPlan		: m._group.getElementById("FPL_Flightplan"),
			list			: m._group.getElementById("FPL_List").setVisible(1),
			ScrollBar 		: m._group.getElementById("FPL_ScrollBar"),
			ScrollBarBackground 	: m._group.getElementById("FPL_ScrollBar_Background"),
			ScrollCursorView	: m._group.getElementById("FPL_ScrollCursorView"),
			ScrollCursorCurrent	: m._group.getElementById("FPL_ScrollCursorCurrent"),
		};
		
# 		m._dialog = {
# 			Number 			: GuiNumberDialog.new(m,m._group,"NumberSpinner"),
# 			Select 			: GuiSelectDialog.new(m,m._group,"Select"),
# 		};
				
		m._flightPlanTransform 	= m._can.FlightPlan.createTransform();
		m._listTransform 	= m._can.list.createTransform();
		m._listViewTransform	= m._can.list.createTransform();
		m._scrollBarTransform	= m._can.list.createTransform();
		
		
		m._flightPlanItemFactory = FlightPlanItemFactory.new();
		m._listView = ListViewClass.new();
		
		m._flightplanItemMap = [];
		
		m._currentIndex = 0;
		m._focusIndex = 0;
		
		m._cursorFocusIndex = 0;
		
		m._listView.setListViewListener(m);
		
		return m;
	},
	setListeners : func(instance) {
		#print("FlightPlanListWidget2.setListeners() ... ");
		append(me._listeners, setlistener(fms._signal.fplChange,func(n){me._onFlightPlanChange(n)},1,1));
		append(me._listeners, setlistener(fms._signal.currentWpChange,func(n){me._onCurrentWaypointChange(n)},1,1));
		append(me._listeners, setlistener(fms._signal.fplReady,func(n){me._onFplReadyChange(n)},1,0));
		append(me._listeners, setlistener(fms._signal.fplUpdated,func(n){me._onFplUpdatedChange(n)},0,1));
		append(me._listeners, setlistener(fms._signal.selectedWpChange,func(n){me._onSelectedWpChange(n)},1,1));
		append(me._listeners, setlistener(fms._signal.cursorOptionChange,func(n){me._onCursorOptionChange(n)},1,1));
		append(me._listeners, setlistener(fms._signal.cursorFocusChange,func(n){me._onCursorFocusChange(n)},1,1));
	},
	init : func(instance=me){
		#print("FlightPlanListWidget2.init() ... ");
		#me.setListeners(instance);	
		me._flightPlanItemFactory.setParent(me);
	},
	deinit : func(){
		#me.removeListeners();
				
	},
	_onVisibiltyChange : func(){
		me._checkKeys();
		if (me._visibility){
			me.setListeners(me);
		}else{
			me.removeListeners();
		}
		me._can.FlightPlan.setVisible(me._visibility);

	},
	_checkKeys  : func(){
		if(me._visibility == 1 ){
# 			if (me._layout == "FPL"){
# 				
# 				me._ifd.ui.bindKey("R5",{
# 					"<"	: func(){me._deleteWaypoint();},
# 					">"	: func(){me._deleteWaypoint();},
# 				});
# 				
# 			}else{
# 				me._ifd.ui.bindKey("R5");
# 			}
			
			me._ifd.ui.bindKnob("RK",{
				"<<"	: func(){me._adjustCursorFocus(1);},
				"<"	: func(){me._adjustCursorOption(1);},
				"push"	: func(){me._onRKClick();},
				">"	: func(){me._adjustCursorOption(-1);},
				">>"	: func(){me._adjustCursorFocus(-1);},
			},{
				"scroll"	: "Scroll",
				"push"		: "Select",
				
			});
			
		}else{
# 			me._ifd.ui.bindKey("R5");
			me._ifd.ui.bindKnob("RK");
		}
	},
	_adjustCursorFocus : func(v){
		var index = me._listView.getCursorFocusAdjusted(v);
		
		fms.setCursorOption(0);
		fms.setCursorFocus(index);
		
	},
	_adjustCursorOption : func(v){
		var index = me._listView._focusedItem.getCursorOptionAdjusted(v);
		if (index > -1 ){
			fms.setCursorOption(index);
		}else{
			me._adjustCursorFocus(v);
		}
	},
	_onRKClick : func(){
		me._jumpWaypoint();
	},
	_deleteWaypoint : func(){
		fms.deleteWaypoint();
	},
	_jumpWaypoint : func(){
		fms.jumpTo();
	},
	
	setLayout : func(layout){
		me._layout = layout;
		me._Page.dialog.cancel();
		
		if(me._layout == "FPL"){
# 			me._x = 400;
# 			me._y = 70;
# 			me._yMax = 1356;
			
			me._listView._viewPort._height = 1356;
			
			me._can.FlightPlan.set("clip","rect(72px, 2048px, 1424px, 400px)");
					
			me._listTransform.setTranslation(400,0);
			#me._scrollBarTransform.setTranslation(0,0);
			
			me._flightPlanTransform.setTranslation(0,70);
			me._flightPlanTransform.setScale(1.0,1.0);
			
			
				me._Page.dialog.setOffset(400,72);
				me._Page.dialog.setScale(1.0,1.0);
				me._Page.dialog.setPositionClipBound(20,1200,1350,70);
			
			
		}elsif(layout == "split-right"){
# 			me._x = 400;
# 			me._y = 70;
# 			me._yMax = 1356; # TODO : 
			
			me._listView._viewPort._height = 1534 ;#(1356/0.82)-120; = 1534
			
			me._can.FlightPlan.set("clip","rect(120px, 2048px, 1424px, 1024px)");
			
			#me._listTransform.setTranslation(400,70);
			#me._scrollBarTransform.setTranslation(0,70);
			
			me._listTransform.setTranslation(400,0);
			#me._scrollBarTransform.setTranslation(0,0);
			
			me._flightPlanTransform.setTranslation(695,120);
			me._flightPlanTransform.setScale(0.82,0.82);
			
				me._Page.dialog.setOffset(1024,120);
				me._Page.dialog.setScale(0.82,0.82);
				me._Page.dialog.setPositionClipBound(30,1200*0.82,1300,70*0.82);
			
		}else{
			me._visible == 0;
			me._can.FlightPlan.setVisible(me._visible);
		}
		me._listView._updateView();
		fms.setCursorOption(0);
		me._checkKeys();
	},
	_clearList : func(){
		#print("FlightPlanListWidget2::_clearList() ... ");
		
		#print("FlightPlanListWidget2::_clearList() ... clear()");
		me._listView.clear();
		
		
		#print("FlightPlanListWidget2::_clearList() ... _flightPlanItemFactory.removeAll()");
		me._flightPlanItemFactory.removeAll();
		
		#print("FlightPlanListWidget2::_clearList() ... removeAllChildren()");
		#me._can.list.removeAllChildren();
		
		
	},
	_drawList : func(){
		#print("FlightPlanListWidget2::_drawList() ... ----------------------------------- Begin");
		#me._listView.appendItem(FlightPlanItemInsertCursor.new(me._can.list,-1));
		#me._listView.appendItem(FlightPlanItemTest.new(me._can.list,-1));
		me._flightplanItemMap = [];
		
		var item = nil;
		item = me._flightPlanItemFactory.getItem(nil,"Cursor",me._can.list);
		
		me._listView.appendItem(item);
		for( var i=0; i < fms._flightPlan.planSize; i+=1 ){
			var wp = fms._flightPlan.wp[i];
			
			if (wp.variant == "Origin"){
				#print("FlightPlanListWidget2::_drawList() ... ----------------------------------- Origin");
				item = me._flightPlanItemFactory.getItem(wp,"Airport",me._can.list);
				
# 				item.setHeadline("Origin");
# 				#item.setHeadline(sprintf("Origin %s %s",wp.role,wp.type));
# 					
# 				item.setICAO(fms._flightPlan.departure.icao);
# 				item.setConstrain(fms._flightPlan.departure.name);
# 				
# 				item.setSid(wp.sid);
# 				item.setRunway(fms._flightPlan.departure.runway.id);
				
			}elsif(wp.variant == "Arrival"){
				#print("FlightPlanListWidget2::_drawList() ... ----------------------------------- Arrival");
				item = me._flightPlanItemFactory.getItem(wp,"Airport",me._can.list);
				
# 				item.setHeadline("Destination");
# 				#item.setHeadline(sprintf("Destination %s %s",wp.role,wp.type));
# 				item.setICAO(fms._flightPlan.destination.icao);
# 				item.setConstrain(fms._flightPlan.destination.name);
# 				item.setArrival(wp.arrival);
# 				item.setApproach(wp.approach);
# 				item.setRunway(fms._flightPlan.destination.runway.id);
				
			}else{
				#print("FlightPlanListWidget2::_drawList() ... ----------------------------------- Waypoint");
		
				item = me._flightPlanItemFactory.getItem(wp,"Waypoint",me._can.list);
				
# 				item.setType(wp.type,wp.role);
# 				item.setICAO(sprintf("%s",wp.name));
# 				
# 				
# 				
# 				var constrain = "";
# 				if (wp.constraint.alt.type != nil) {
# 					constrain = sprintf("cross %s %s %3.0f ft",wp.name,wp.constraint.alt.type,wp.constraint.alt.value);
# 				}
# 				
# 				item.setConstrain(constrain);
# 				
# 				if(i > 0){
# 					item.setHeadline(sprintf("%s (%03.0f°)",wp.flyType,wp.course));
# 					#item.setHeadline(sprintf("%s (%03.0f°) %s %s ",wp.flyType,wp.course,wp.role,wp.type ));
# 					item.setDistance(sprintf("%0.1f",wp.distanceTo));
# 				}else{
# 					item.setHeadline("");
# 					item.setDistance("---");
# 				}
			}
			
			if( i == me._currentIndex){
				item.setActive(1);
			}
			
			if( i == me._focusIndex){
				item.setFocus(1);
			}
			#print("FlightPlanListWidget2::_drawList() ... ----------------------------------- append Item");
			append(me._flightplanItemMap,item);
			me._listView.appendItem(item);
						
			item = me._flightPlanItemFactory.getItem(wp,"Cursor",me._can.list);
			
			me._listView.appendItem(item);
			
		}
		me._listView.setFocusIndex(me._cursorFocusIndex);
		#print("FlightPlanListWidget2::_drawList() ... ----------------------------------- ENDE");
	},
### implements ListViewListener
	onListViewUpdate : func(){
		me._listViewTransform.setTranslation(me._listView._viewPort._x,-me._listView._viewPort._y);
	},
	onScrollBarUpdate : func(){
		var activeHeight = 0;
		var activePosY 	 = 0;
		var viewHeight 	 = 0;
		var viewPosY 	 = 0;
		var activeItem	 = nil;
		
		if (me._currentIndex >= 0 and me._currentIndex < size(me._flightplanItemMap)){
			var activeItem = me._flightplanItemMap[me._currentIndex];
		}
			
		if (me._listView._height > me._listView._viewPort._height){
			if (activeItem != nil){
				activeHeight 	 = (activeItem._bound._height / me._listView._height) * me._listView._viewPort._height;
				activePosY 	 = (activeItem._bound._y / me._listView._height) * me._listView._viewPort._height;
			}
			viewHeight 	 = (me._listView._viewPort._height / me._listView._height) * me._listView._viewPort._height;
			viewPosY	 = (me._listView._viewPort._y / me._listView._height) * me._listView._viewPort._height;
			
		}else{
			if (activeItem != nil){
				activeHeight 	 = (activeItem._bound._height / me._listView._viewPort._height) * me._listView._viewPort._height;
				activePosY 	 = (activeItem._bound._y / me._listView._viewPort._height) * me._listView._viewPort._height;
			}
			viewHeight	 = me._listView._viewPort._height;
			viewPosY	 = (me._listView._viewPort._y / me._listView._viewPort._height) * me._listView._viewPort._height;
		}
		me._can.ScrollBarBackground.set("coord[1]",0);
		me._can.ScrollBarBackground.set("coord[3]",me._listView._viewPort._height);
		
		me._can.ScrollCursorCurrent.set("coord[1]",0);
		me._can.ScrollCursorCurrent.set("coord[3]",activeHeight);
		me._can.ScrollCursorCurrent.setTranslation(0,activePosY);
		me._can.ScrollCursorView.set("coord[1]",0);
		me._can.ScrollCursorView.set("coord[3]",viewHeight);
		me._can.ScrollCursorView.setTranslation(0,viewPosY);
		
		
		
	},
	
### implements the callback object func for FlightPlanListViewItem
	_onIcaoEdit : func(item){
		print("FlightPlanListWidget2::_onIcaoEdit() ...");
	},
	
### implements fms events
	_onFlightPlanChange : func(n){
		#print("\n############################################# FlightPlanListWidget2::_onFlightPlanChange() ... ");
		#print("\n");
		var value = n.getValue();
		#print("FlightPlanListWidget2::_onFlightPlanChange() ... ------------- _clearList");
		me._clearList();
		#print("FlightPlanListWidget2::_onFlightPlanChange() ... ------------- _drawList");
		me._drawList();
		#print("\n");
	},
	_onCurrentWaypointChange : func(n){
		
		if(me._currentIndex >= 0 and size(me._flightplanItemMap)){
			me._flightplanItemMap[me._currentIndex].setActive(0);
		}
		
		me._currentIndex = n.getValue();
		
		if(me._currentIndex == nil){
			me._currentIndex = -1;
		}
		
		if (me._currentIndex >= 0 and size(me._flightplanItemMap)){
			me._flightplanItemMap[me._currentIndex].setActive(1);
			me._listView.setFocusItem(me._flightplanItemMap[me._currentIndex]);
		}
		
	},
	_onFplReadyChange : func(n){
		if(fms._flightPlan.isReady){
			
		}else{
			for( var i=0; i < fms._flightPlan.planSize; i+=1 ){
				me._flightplanItemMap[i].setDistance("---");
				me._flightplanItemMap[i].setETE("---");
				me._flightplanItemMap[i].setETA("---");
				me._flightplanItemMap[i].setFuel("---");
			}
		}
	},
	_onFplUpdatedChange : func(n){
		for( var i=0; i < fms._flightPlan.planSize; i+=1 ){
			if (i >= fms._flightPlan.currentWpIndex){
				me._flightplanItemMap[i].setDistance(sprintf("%0.1f",fms._flightPlan.wp[i].distanceTo));
				me._flightplanItemMap[i].setETE(global.formatTime(fms._flightPlan.wp[i].ete,"i:s"));
				me._flightplanItemMap[i].setETA(global.formatTime(fms._flightPlan.wp[i].eta));
				me._flightplanItemMap[i].setFuel(sprintf("%.0f",fms._flightPlan.wp[i].fuelAt));
			}else{
				me._flightplanItemMap[i].setDistance("---");
				me._flightplanItemMap[i].setETE("---");
				me._flightplanItemMap[i].setETA("---");
				me._flightplanItemMap[i].setFuel("---");
			}
		}
		
	},
	_onCursorOptionChange : func(n){
		var index = n.getValue();
		print(sprintf("FlightPlanListWidget2::_onCursorOptionChange(%i)",index));
		me._listView._focusedItem.setCursorOption(index);
	},
	_onCursorFocusChange : func(n){
		me._cursorFocusIndex = n.getValue();
		print(sprintf("FlightPlanListWidget2::_onCursorFocusChange(%i)",me._cursorFocusIndex));
		me._listView.setFocusIndex(me._cursorFocusIndex);
	},
	_onSelectedWpChange : func(n){
		var index = n.getValue();
		
	},
};

var AvidynePageFMS = {
	new: func(ifd,name,data){
		var m = { parents: [
			AvidynePageFMS,
			PageClass.new(ifd,name,data)
		] };
		m._class = "AvidynePageFMS";
		
		m.svgFile	= "IFD_FMS.svg";
		
		canvas.parsesvg(m.page, "Models/instruments/IFDs/"~m.svgFile,{
			"font-mapper": global.canvas.FontMapper
			}
		);
		m._widget	= {
			Tab	 	: TabWidget.new(m,m.page,"TabSelectMAP"),
			DirectTo 	: DirectToWidget.new(m,m.page,"DirectTo"),
			InsertDelete 	: InsertDeleteWidget.new(m,m.page,"DirectTo"),
			FPL	 	: FlightPlanListWidget2.new(m,m.page,"FPL-List"),
			MovingMapKnob	: MovingMapKnobWidget.new(m,m.page,"MovingMapKnob"),
			Dialog		: DialogWidget.new(m,m.page,"Dialog"),
		};
		
		m._can = {
			
			Dialog			: m.page.getElementById("FMS_Dialog").setVisible(0),
			DialogPopup 		: nil,
			RoutesContent		: m.page.getElementById("FMS_Routes_Content").setVisible(0),
			UserWyptsContent	: m.page.getElementById("FMS_UserWypts_Content").setVisible(0),
			InfoContent		: m.page.getElementById("FMS_Info_Content").setVisible(0),
			FPLContent		: m.page.getElementById("FMS_FPL_Content").setVisible(0),
			 
		};
		m._can.DialogPopup = m._can.Dialog.createChild("group","FPL_DialogPopup");
		m._can.DialogPopup.setVisible(1);
		m._widget.Tab._tab = ["FPL","MapFPL","Info","Routes","UserWypts","Nearest","MapNearest"];
		
		m.dialog = GuiDialogFactory.new(m._can.Dialog);
		m.dialog._catalog = {
			"Number": func {
				return GuiNumberDialog.new(m,m._can.DialogPopup,"NumberDialog");
			},
			"Select": func {
				return GuiSelectDialog.new(m,m._can.DialogPopup,"SelectDialog");
			},
		};
		m.dialog._event = {
			onCreate	: func {m._onDialogCreate();},
			onDestruct	: func {m._onDialogDestruct();},
		};
		
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
	_onDialogCreate : func(){
		print("AvidynePageFMS::_onDialogCreate() ...");
		me._can.Dialog.setVisible(1);
		me._can.RoutesContent.setVisible(0);
		me._can.FPLContent.setVisible(0);
		me._can.InfoContent.setVisible(0);
		me._can.UserWyptsContent.setVisible(0);
		me._widget.Dialog.setVisible(1);
		
	},
	_onDialogDestruct : func(){
		print("AvidynePageFMS::_onDialogDestruct() ...");
		me._can.Dialog.setVisible(0);
		me._initWidgetsForTab(me._widget.Tab._index);
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
			me._widget.InsertDelete.setVisible(me._visibility);
			
		}
		me._widget.Tab.setVisible(me._visibility);
		me.page.setVisible(me._visibility);
	},
	## called from TabWidget
	_initWidgetsForTab : func(index){
# 		me._widget.DirectTo.deinit();
# 		me._widget.FPL.setVisible(0);
		#me.IFD._widget.PlusData.setVisible(0);
		me._can.RoutesContent.setVisible(0);
		me._can.FPLContent.setVisible(0);
		me._can.InfoContent.setVisible(0);
		me._can.UserWyptsContent.setVisible(0);
		
		me._widget.Dialog.setVisible(0);
		
		
		
		if (index == 0){ # FPL
			me._widget.MovingMapKnob.setVisible(0);
			me.IFD.movingMap.setLayout("none");
			me.IFD.setLayout(IFD_LAYOUT.PLUS);
			me._widget.FPL.setLayout("FPL");
			me._widget.FPL.setVisible(1);
			me._widget.DirectTo.setVisible(1);
			me._widget.InsertDelete.setVisible(1);
			me._can.FPLContent.setVisible(1);
		}elsif(index == 1){ # MapFPL
			me._widget.MovingMapKnob.setHand(0);
			me.IFD.setLayout(IFD_LAYOUT.SPLIT);
			me.IFD.movingMap.setLayout("split-left");
			me._widget.FPL.setLayout("split-right");
			me._widget.FPL.setVisible(1);
			me._widget.DirectTo.setVisible(0);
			me._widget.InsertDelete.setVisible(0);
			me._widget.MovingMapKnob.setVisible(1);	
		}elsif(index == 2){ # Info
			me._widget.MovingMapKnob.setVisible(0);
			me._widget.FPL.setVisible(0);
			me.IFD.movingMap.setLayout("none");
			me.IFD.setLayout(IFD_LAYOUT.PLUS);
			me._widget.DirectTo.setVisible(1);
			me._widget.InsertDelete.setVisible(1);
			me._can.InfoContent.setVisible(1);
		}elsif(index == 3){ # Routes
			me._widget.FPL.setVisible(0);
			me._widget.MovingMapKnob.setVisible(0);
			me.IFD.setLayout(IFD_LAYOUT.PLUS);
			me.IFD.movingMap.setLayout("none");
			me._widget.DirectTo.setVisible(0);
			me._widget.InsertDelete.setVisible(0);
			me._can.RoutesContent.setVisible(1);
		}elsif(index == 4){ # UserWypts
			me._widget.MovingMapKnob.setVisible(0);
			me._widget.FPL.setVisible(0);
			me.IFD.setLayout(IFD_LAYOUT.PLUS);
			me.IFD.movingMap.setLayout("none");
			me._widget.DirectTo.setVisible(1);
			me._widget.InsertDelete.setVisible(1);
			me._can.UserWyptsContent.setVisible(1);
		
		}elsif(index == 5){ # Nearest
			me._widget.MovingMapKnob.setVisible(0);
			me._widget.FPL.setVisible(0);
			me.IFD.movingMap.setLayout("none");
			me._widget.DirectTo.setVisible(1);
			me._widget.InsertDelete.setVisible(1);
			me.IFD.setLayout(IFD_LAYOUT.PLUS);
			
		}elsif(index == 6){ # MapNearest
			me._widget.FPL.setVisible(0);
			me.IFD.setLayout(IFD_LAYOUT.SPLIT);
			me.IFD.movingMap.setLayout("split-left");
			me._widget.MovingMapKnob.setHand(0);
			me._widget.MovingMapKnob.setVisible(1);
			me._widget.DirectTo.setVisible(0);
			me._widget.InsertDelete.setVisible(0);
			
		}else{
			
		}
	},
	update2Hz : func(now,dt){

		#me._widget.FPL.update();
		
	},
	update20Hz : func(now,dt){
		

	
	},
};
