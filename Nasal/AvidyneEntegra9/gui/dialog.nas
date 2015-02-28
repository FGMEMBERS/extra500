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
#      Date: 31.01.2015
#
#      Last change:      Dirk Dittmann
#      Date:             31.01.2015
#

var GuiDialog = {
	new : func(parent,canvasGroup,name){
		var m = {parents:[
			GuiDialog,
 		]};
		m._class = "GuiDialog";
		m._parent 	= parent;
		m._group 	= canvasGroup;
		m._name 	= name;
		m._bound 	= Rectangle.new(0,0,0,0);
		m._can 		= {};
		m._callBack	= {onUpdate:nil,onClose:nil};
		m._format	= nil;
		m._status	= 0;
		m._title	= "";
		m._value 	= 0;
		m._originalValue = 0;
		
		return m;
	},
	destruct : func(){
		
	},
	setCallBack : func(cb){
		me._callBack = cb;
	},
	setFormat : func(cb){
		me._format = cb
	},
	open : func(){
		
	},
	close : func(){
		me._status = me.STATUS.CLOSED;
	},
	cancel : func(){
		me._status = me.STATUS.CANCEL;
		me._value = me._originalValue;
		if(me._callBack['onUpdate'] != nil){
			me._callBack['onUpdate']();
		}
	},
	enter : func(){
		me._status = me.STATUS.OK;
		if(me._callBack['onUpdate'] != nil){
			me._callBack['onUpdate']();
		}
	},
	setTitle : func(text){
		me._title = text;
	},
	setValue : func(v){
		me._value = v;
		me._originalValue = v;
	},
	
	
};
GuiDialog.STATUS = {
			CLOSED	 : 0,
			OPEN	 : 1,
			CANCEL	 : 2,
			CHANGE	 : 3,
			OK	 : 4,
		};

		
var GuiDialogFactory = {
	new : func(canGroup){
		var m = {parents:[
			GuiDialogFactory,
		]};
		m._class = "GuiDialogFactory";
		m._dialog = nil;
		m._catalog = {};
		m._event = {
			onOpen		: func {print("GuiDialogFactory::EVENT onOpen")},
			onClose		: func {print("GuiDialogFactory::EVENT onClose")},
			onCreate	: func {print("GuiDialogFactory::EVENT onCreate")},
			onDestruct	: func {print("GuiDialogFactory::EVENT onDestruct")},
		};
		m._clipPosition = {
			top : 0,
			right : 0,
			bottom : 0,
			left : 0
		};
		m._offset = {
			x : 0,
			y : 0
		};
		m._scale = {
			x : 1.0,
			y : 1.0
		};
		m._can = {
			clip	: canGroup.createChild("path","FPL_DialogClip"),
		};
		
		
		
		return m;
	},
	create : func(type){
		me.destruct();
		if (contains(me._catalog,type)){
			me._dialog = me._catalog[type]();
			#debug.dump(me._dialog._class);
			if (me._dialog != nil and me._dialog._class == "GuiSelectDialog"){
				me._dialog.setOffset(me._offset.x,me._offset.y);
				me._dialog.setScale(me._scale.x,me._scale.y);
				me._dialog.setPositionClipBound(me._clipPosition.top,me._clipPosition.right,me._clipPosition.bottom,me._clipPosition.left);
			}
		}
		me._event['onCreate']();
		return me._dialog;
	},
	destruct : func(){
		if (me._dialog != nil){
			me._dialog.close();
			me._dialog.destruct();
			me._dialog = nil;
			me._event['onDestruct']();
		}
	},
	open : func(){
		if (me._dialog != nil){
			me._dialog.open();
			print("GuiDialogFactory::open() ...");
			#me._event['onOpen']();
		}
	},
	close : func(){
		if (me._dialog != nil){
			me._dialog.close();
			print("GuiDialogFactory::close() ...");
			#me._event['onClose']();
		}
	},
	cancel : func(){
		if (me._dialog != nil){
			me._dialog.cancel();
		}
	},
	enter : func(){
		if (me._dialog != nil){
			me._dialog.enter();
		}
	},
	adjust : func(amount){
		if (me._dialog != nil){
			me._dialog._adjust(amount);
		}
	},
	setValue : func(v){
		if (me._dialog != nil){
			me._dialog.setValue(v);
		}
	},
	setData : func(v){
		if (me._dialog != nil){
			me._dialog.setData(v);
		}
	},
	setOffset : func(x,y){
		me._offset.x = x;
		me._offset.y = y;
		
		me._can.clip.setTranslation(x,y);
		
		if (me._dialog != nil){
			me._dialog.setOffset(x,y);
		}
	},
	setScale : func(x,y){
		me._scale.x = x;
		me._scale.y = y;
		if (me._dialog != nil){
			me._dialog.setScale(x,y);
		}
	},
	setPositionClipBound : func(top,right,bottom,left){
		me._clipPosition.top = top;
		me._clipPosition.right = right;
		me._clipPosition.bottom = bottom;
		me._clipPosition.left = left;
		
		me._can.clip.reset();
		me._can.clip.rect(left,top,right-left,bottom-top)
					.set("stroke","#FF0000")
					.set("stroke-width",2);
		if (me._dialog != nil and me._dialog._class == "GuiSelectDialog"){
			me._dialog.setPositionClipBound(top,right,bottom,left);
		}
	},
	setPosition : func(x,y){
		if (me._dialog != nil){
			me._dialog.setPosition(x,y);
		}
	},
	setCallBack : func(v){
		if (me._dialog != nil){
			me._dialog.setCallBack(v);
		}
	},
	setFormat : func(v){
		if (me._dialog != nil){
			me._dialog.setFormat(v);
		}
	},
	setAmount : func(v){
		if (me._dialog != nil){
			me._dialog.setAmount(v);
		}
	},
	getStatus : func(){
		if (me._dialog != nil){
			return me._dialog._status;
		}
		return nil;
	},
	getValue : func(){
		if (me._dialog != nil){
			return me._dialog._value;
		}
		return nil;
	},
	
	
};

var GuiNumberDialog = {
	new : func(parent,canvasGroup,name){
		var m = {parents:[
			GuiNumberDialog,
			GuiDialog.new(parent,canvasGroup,name),
 		]};
		m._class = "GuiNumberDialog";
		m._value = 0;
		m._amount = [0.1,1.0];
		return m;
	},
	destruct : func(){
		
	},
	setValue : func(v){
		if(me._format != nil){
			me._value = me._format(v);
		}else{
			me._value = v;
		}
		me._originalValue = me._value;
	},
	setAmount : func(a){
		me._amount = a;
	},
	setTranslation : func(x=0,y=0){
		
	},
	open : func(){
		me._parent._ifd.ui.bindKnob("RK",{
				"<<"	: func(){me._adjust(-me._amount[1]);},
				"<"	: func(){me._adjust(-me._amount[0]);},
				"push"	: func(){me.enter();},
				">"	: func(){me._adjust(me._amount[0]);},
				">>"	: func(){me._adjust(me._amount[1]);},
			},{
				"scroll"	: "adjust",
				"push"		: "confirm",
				
			});
		me._status = me.STATUS.OPEN;
	},
	_adjust : func(v){
		me._status = me.STATUS.CHANGE;
		me._value += v;
		if(me._format != nil){
			me._value = me._format(me._value);
		}
		if(me._callBack['onUpdate'] != nil){
			me._callBack['onUpdate']();
		}
	},
};


var GuiSelectDialogTextItem = {
	new : func(canvasGroup,index){
		var m = {parents:[
			GuiSelectDialogTextItem,
			FlightPlanListViewItem.new(),
 		]};
		m._class = "GuiSelectDialogTextItem";
		m._bound._height = 60;
		
		m._group		= canvasGroup.createChild("group","item["~index~"]");
		#m._group.updateCenter();
		m._index		= index;
		m._can = {
			Background	: m._group.createChild("path","itemBackground"),
			Text 		: m._group.createChild("text","itemText"),
		};
		
		m._can.Background.rect(0,0,320,60,{"border-radius": 10})
					.set("fill","#d0ebe6");
		
		
		return m;
	},
	init : func(){
		me._can.Text.setFont("LiberationFonts/LiberationSans-Regular.ttf")
			.setFontSize(40, 1)
			.setColor(FPL_COLOR.Font.Normal)
			.setColorFill(FPL_COLOR.Font.Normal)
			.setAlignment("left-top" )
			.setText(me._data);
	},
	### implement ListViewItem
	del 	: func(){

	},
	setVisible 	: func(v){ me._group.setVisible(v)},
	setFocus 	: func(v){ 
		me._can.Background.setVisible(v);
		if (v){
			me._can.Text.setColor(FPL_COLOR.Font.Selected)
				.setColorFill(FPL_COLOR.Font.Selected);
		}else{
			me._can.Text.setColor(FPL_COLOR.Font.Normal)
				.setColorFill(FPL_COLOR.Font.Normal);
		}
			
	},
	setAction 	: func(type,value){},
	_updateView 	: func(){
		#print("FlightPlanItemWaypoint::_updateView() ...");
		me._group.setTranslation(me._bound._x,me._bound._y);
	},
};


var GuiSelectDialog = {
	new : func(parent,canvasGroup,name){
		var m = {parents:[
			GuiSelectDialog,
			IfdWidget.new(parent,canvasGroup,name),
			GuiDialog.new(parent,canvasGroup,name),
			ListViewListener.new(),
 		]};
		m._class 	= "GuiSelectDialog";
		m._itemCache 	= FactroryCache.new("TextItem",GuiSelectDialogTextItem.new);
		m._listView 	= ListViewClass.new();
		
# 		m._can = {
# 			#Pattern_Waypoint	: m._group.getElementById("FPL_Pattern_Waypoint").setVisible(0),
# 			popup				: m._group.getElementById("FPL_Popup"),
# 			popupBackground			: m._group.getElementById("FPL_Popup_Background"),
# 			popupFrame			: m._group.getElementById("FPL_Popup_Frame"),
# 			
# 			popupList			: m._group.getElementById("FPL_Popup_List"),
# 			popupListBackground		: m._group.getElementById("FPL_Popup_List_Background"),
# 			
# 			popupScrollBar			: m._group.getElementById("FPL_Popup_ScrollBar"),
# 			popupScrollBarBackground	: m._group.getElementById("FPL_Popup_ScrollBar_Background"),
# 			popupScrollBarPosition		: m._group.getElementById("FPL_Popup_ScrollBar_Position"),
# 			
# 			
# 		};
		m._can = {
			#Pattern_Waypoint	: m._group.getElementById("FPL_Pattern_Waypoint").setVisible(0),
			popup				: nil,
			popupBackground			: nil,
			popupFrame			: nil,
			
			popupList			: nil,
# 			popupListBackground		: m._group.getElementById("FPL_Popup_List_Background"),
			
			popupScrollBar			: nil,
			popupScrollBarBackground	: nil,
			popupScrollBarPosition		: nil,
			
			
		};
		m._can.popup			= m._group.createChild("group","GuiSelectDialog");
		m._can.popupBackground		= m._can.popup.createChild("path","FPL_DialogPopup_Background");
		m._can.popupList		= m._can.popup.createChild("group","FPL_DialogPopup_List");
		m._can.popupScrollBar		= m._can.popup.createChild("group","FPL_DialogPopup_ScrollBar");
# 		m._can.popupFrame		= m._can.popup.createChild("path","FPL_DialogPopup_Frame");
		m._can.popupScrollBarBackground = m._can.popupScrollBar.createChild("path","FPL_DialogPopup_ScrollBar_Background");
		m._can.popupScrollBarPosition 	= m._can.popupScrollBar.createChild("path","FPL_DialogPopup_ScrollBar_Position");
			
		m._can.popupBackground.rect(-4,-4,328,428,{"border-radius": 10})
					.set("fill","#005b74")
					.set("stroke","#4b98ac")
					.set("stroke-width",2);
# 		m._can.popupFrame.rect(-2,-2,324,324,{"border-radius": 10})
# 					.set("fill","none")
# 					.set("stroke","#4b98ac")
# 					.set("stroke-width",2);
		m._can.popup.setTranslation(4,4);			
					
					
		m._can.popupScrollBarBackground.rect(0,0,24,420,{"border-radius": 10})
					.set("fill","#4b98ac");
					
		m._can.popupScrollBarPosition.rect(0,0,24,48,{"border-radius": 10})
					.set("fill","#d0ebe6");
		
		m._can.popupScrollBar.setTranslation(296,0);
		
			
		m._data = [
			"above",
			"at or above",
			"at",
			"at or below",
			"below"			
		];
		
		m._clipPosition = {
			top : 0,
			right : 0,
			bottom : 0,
			left : 0
		};
		
		m._dataIndex = 0;
		
		m._popupOffset		=  m._can.popup.createTransform();
		m._popupTransform	=  m._can.popup.createTransform();
		m._listViewTransform	=  m._can.popupList.createTransform();
		m._listView.setListViewListener(m);
		
		m._scale = {x:1.0,y:1.0};
		return m;
	},
	destruct : func(){
		me._group.removeAllChildren();
	},
	setPositionClipBound : func(top,right,bottom,left){
		print(sprintf("GuiSelectDialog::setPositionClipBound(%i,%i,%i,%i)",top,right,bottom,left));
		me._clipPosition.top = top;
		me._clipPosition.right = right;
		me._clipPosition.bottom = bottom;
		me._clipPosition.left = left;
	},
	setOffset : func(x,y){
		print(sprintf("GuiSelectDialog::setOffset(%i,%i)",x,y));
		me._popupOffset.setTranslation(x,y);
	},
	setScale : func(x,y){
		print(sprintf("GuiSelectDialog::setScale(%i,%i)",x,y));
		me._scale.x  = x;
		me._scale.y  = y;
		me._popupTransform.setScale(me._scale.x,me._scale.y);
	},
	setTranslation : func(x=0,y=0){
		print(sprintf("GuiSelectDialog::setTranslation(%i,%i)",x,y));
		m._can.popup.setTranslation(x,y);
	},
	setPosition : func(x=0,y=0){
		print(sprintf("GuiSelectDialog::setPosition(%i,%i)",x,y));
		#print(sprintf("input \t\t x:%i y:%i",x,y));
				
		#x *= me._scale.x;
		#y *= me._scale.y;
		
		print(sprintf("scaled \t\t x:%i y:%i",x,y));
		me._can.popup.update();
		var bb = me._can.popup.getTightBoundingBox(); # 0:x1 1:y1 2:x2 3:y2
		debug.dump(bb);
		var width = (bb[2]-bb[0]);
		var height = (bb[3]-bb[1]);
		print(sprintf("dimesion \t\t width:%f height:%f",width,height));
		debug.dump(me._clipPosition);
		
		if (x < me._clipPosition.left){ x = me._clipPosition.left }
		if ((x + width) > me._clipPosition.right){ x = me._clipPosition.right - width }
		if (y < me._clipPosition.top){ y = me._clipPosition.top }
		if ((y + height) > me._clipPosition.bottom){ y = me._clipPosition.bottom - height }
		
		
		
		print(sprintf("cliped \t\t x:%i y:%i",x,y));
						
		me._popupTransform.setTranslation(x,y);
		
		
	},
	_resizeView : func(){
		print("GuiSelectDialog::_resizeView()");
		var dataSize = size(me._data);
				
		
		if (dataSize > 7){
			me._listView._viewPort._height = 420;
			me._can.popupBackground.reset();
			me._can.popupBackground.rect(-4,-4,328,me._listView._viewPort._height+8,{"border-radius": 10});
		
			me._can.popupScrollBar.setVisible(1);
			me._can.popupScrollBarBackground.reset();
			me._can.popupScrollBarBackground.rect(0,0,24,me._listView._viewPort._height,{"border-radius": 10})
		}else{
			me._listView._viewPort._height =  dataSize * 60;
			
			me._can.popupBackground.reset();
			me._can.popupBackground.rect(-4,-4,328,me._listView._viewPort._height+8,{"border-radius": 10});
					
			me._can.popupScrollBar.setVisible(0);
# 			me._can.popupScrollBarBackground.reset();
# 			me._can.popupScrollBarBackground.rect(0,0,24,me._listView._viewPort._height,{"border-radius": 10})
		}
		
		
		
	},
	_findSelectedDataIndex : func(){
		var dataSize = size(me._data);
		for( var i=0; i < dataSize; i+=1 ){	
			if (me._data[i] == me._value){
				return i;
			}
		}
		return 0;
	},
	setData : func(data){
		me._data = data;
		me._dataIndex = me._findSelectedDataIndex();
		me._resizeView();
	},
	_clearList : func(){
		me._listView.clear();
		me._itemCache.removeAll();
	},
	_drawList : func(){
		var item = nil;
		var dataSize = size(me._data);
		for( var i=0; i < dataSize; i+=1 ){
			item = me._itemCache.getItem(me._data[i],me._can.popupList);
			me._listView.appendItem(item);
		}
	},
	_adjust : func(v){
		me._status = me.STATUS.CHANGE;
		me._dataIndex 	= me._listView.getCursorFocusAdjusted(v);
		me._value 	= me._data[me._dataIndex];
		me._listView.setFocusIndex(me._dataIndex);
		if(me._callBack['onUpdate'] != nil){
			me._callBack['onUpdate']();
		}
	},
	# implement GuiDialog
	open : func(){
		me._can.popup.setVisible(1);
		me._clearList();
		me._drawList();
		
		
		me._ifd.ui.bindKnob("RK",{
				"<<"	: func(){me._adjust(1);},
				"<"	: func(){me._adjust(1);},
				"push"	: func(){me.enter();},
				">"	: func(){me._adjust(-1);},
				">>"	: func(){me._adjust(-1);},
			},{
				"scroll"	: "scroll",
				"push"		: "confirm",
				
			});
		
		me._status = me.STATUS.OPEN;
		me._listView.setFocusIndex(me._dataIndex);
		me._listView._updateView();
		
		me.setVisible(1);
		me._group.update();
	},
	close : func(){
		me._can.popup.setVisible(0);
		me._clearList();
		me._status = me.STATUS.CLOSED;
	},
	setTitle : func(text){
		me._title = text;
		me._can.popupHeadlineText.setText(me._title);
		
	},
	### implements ListViewListener
	onListViewUpdate : func(){
		me._listViewTransform.setTranslation(me._listView._viewPort._x,-me._listView._viewPort._y);
	},
	onScrollBarUpdate : func(){
		var viewHeight 	 = 0;
		var viewPosY 	 = 0;
		
		if (me._listView._height > me._listView._viewPort._height){
			
			viewHeight 	 = (me._listView._viewPort._height / me._listView._height) * me._listView._viewPort._height;
			viewPosY	 = (me._listView._viewPort._y / me._listView._height) * me._listView._viewPort._height;
			
			me._can.popupScrollBarPosition.reset();
			me._can.popupScrollBarPosition.rect(0,0,24,viewHeight,{"border-radius": 10});
			me._can.popupScrollBarPosition.setTranslation(0,viewPosY);
			me._can.popupScrollBar.setVisible(1);
			
		}else{
			me._can.popupScrollBar.setVisible(0);
			
		}
		
		
		
	},

	

};