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
#      Date: 24.12.2014
#
#      Last change:      Dirk Dittmann
#      Date:             24.12.2014
#

var Rectangle = {
	new: func(x=0,y=0,width=0,height=0){
		var m = { parents: [Rectangle] };
		m._x = x;
		m._y = y;
		m._width = width;
		m._height = height;
		return m;
	},
	set : func (x,y,width,height){
		me._x 		= x;
		me._y 		= y;
		me._width 	= width;
		me._height 	= height;
	},
	
# 	setX 		: func(v){ me._x = v; },
# 	setY 		: func(v){ me._y = v; },
# 	setWidth 	: func(v){ me._width = v; },
# 	setHeight 	: func(v){ me._height = v; },
# 	getX		: func(){ return me._x;},
# 	getY		: func(){ return me._y;},
# 	getHeight 	: func(){ return me._height;},
# 	getWidth 	: func(){ return me._width;	},
	
};



var ListViewItem = {
	new: func(){
		var m = { parents: [ListViewItem] };
		m._bound = Rectangle.new(0,0,0,0); 
		m._cursorFocus 	= 0;
		return m;
	},
	del : func(){},
	setVisible : func(v){
		print("ListViewItem::setVisible("~v~") ... abstract");
	},
	setCursorFocus : func(v){
		me._cursorFocus = v;
		print("ListViewItem::setFocus("~v~") ... abstract");
	},
	hasCursorFocus : func(){return (me._cursorFocus == 1);},
};

var ScrollBarClass = {
	new: func(){
		var m = { parents: [ScrollBarClass] };
		m._bound = [0,0,0,0]; # [x1,y1,x2,y2]
		return m;
	},
	setBarBounds : func (type,start,ende){
		
	},
};

var ListViewListener = {
	new: func(){
		var m = { parents: [ListViewListener] };
		m._xyz = 0;
		return m;
	},
	onListViewUpdate : func(){},
	onScrollBarUpdate : func(){},
};


var ListViewClass = {
	new: func(){
		var m = { parents: [
			ListViewClass
		] };
		m._items = std.Vector.new(); #fgdata/Nasal/std/Vector.nas
		m._focusedItem = nil;
		m._focusedIndex = 0;
		m._scrollbar = nil;
		m._viewPort = Rectangle.new(0,0,0,0);
		m._height = 0;
		m._listViewListener = ListViewListener.new();
		return m;
	},
	setListViewListener : func(l){
		me._listViewListener = l;
	},
	appendItem : func(item){
		#print("ListViewClass::appendItem() ... in");
		me._items.append(item);
		me._recalcItems();
		me.setFocusItem(item);
		#print("ListViewClass::appendItem() ... out");
	},
	addAfterIndex : func(index,item){
		me._items.insert(index+1,item);
		me._recalcItems();
		me.setFocusItem(item);
	},
	addBeforIndex : func(index,item){
		me._items.insert(index,item);
		me._recalcItems();
		me.setFocusItem(item);
	},
	
	
	removeItem : func(item){
		me._items.remove(item);
		me._recalcItems();
	},	
	removeIndex : func(index){
		me._items.pop(index);
		me._recalcItems();
	},
	clear : func(){
		forindex (var index; me._items.vector) {
			me._items.vector[index].del();
		}
		me._items.clear();
		me._focusedItem = nil;
		me._height = 0;
	},
	
	_recalcItems : func(){
		#print("ListViewClass::_recalcItems() ...");
		me._height = 0;
		forindex (var index; me._items.vector) {
			me._items.vector[index]._bound._y = me._height;
			me._height += me._items.vector[index]._bound._height;
		};
	},
	_showItemsInView : func(){
		#print("ListViewClass::_showItemsInView() ...");
		#debug.dump(me._viewPort);
		forindex (var index; me._items.vector) {
			var topIn 	= (me._items.vector[index]._bound._y >= me._viewPort._y);
			var bottomIn	= ( me._items.vector[index]._bound._y + me._items.vector[index]._bound._height ) <= ( me._viewPort._y + me._viewPort._height );
			
			var visible = topIn and bottomIn;
			
			#print(sprintf("ListViewClass::_showItemsInView() ... Difference top:%s bottom:%s visible:%s",topIn,bottomIn,visible));
			
			me._items.vector[index].setVisible(visible);
			me._items.vector[index]._updateView();
			
		};
	},
	
	setFocusItem : func(item){
		if(me._focusedItem != nil){
			me._focusedItem.setFocus(0);
		}
		me._focusedItem = item;
		me._focusedIndex = me._items.index(me._focusedItem);
		me._focusedItem.setFocus(1);
		me._updateView();
		
	},
	
	setFocusIndex : func(index){
		me._focusedIndex = global.clamp(index,0,me._items.size()-1);
		var item = me._items.vector[me._focusedIndex];
		me.setFocusItem(item);
	},
	adjustCursorFocus : func(v){
		me._focusedIndex = global.clamp(me._focusedIndex+v,0,me._items.size()-1);
		me.setFocusIndex(me._focusedIndex);
	},
	getCursorFocusAdjusted : func(amount){
		return global.clamp(me._focusedIndex+amount,0,me._items.size()-1);
	},
	
	setAction : func(type,value){
		
		if(type == "scroll"){
			if(me._focusedItem!=nil){
				var currentFocusIndex = me._items.index(me._focusedItem);
				if(value > 0){
					currentFocusIndex += 1;
					me.setFocusIndex(currentFocusIndex);
				}elsif(value < 0){
					currentFocusIndex -= 1;
					me.setFocusIndex(currentFocusIndex);
				}
			}else{
				me.setFocusIndex(0);
			}
		}else{
			if(me._focusedItem != nil){
				me._focusedItem.setAction(type,value);
			}
		}
	},
	
	setScrollBar : func(scrollbar){
		me._scrollbar = scrollbar;
	},
	_moveViewPort : func(){
		if(me._focusedItem!=nil){
			# move the viewport
			var topDif 	= me._viewPort._y - me._focusedItem._bound._y;
			var bottomDif 	= (me._focusedItem._bound._y + me._focusedItem._bound._height) - (me._viewPort._y + me._viewPort._height);
			#debug.dump(me._viewPort,me._focusedItem._bound);
			#print(sprintf("ListViewClass::_updateView() ... Difference top:%s bottom:%s",topDif,bottomDif));
			
			if (topDif > 0){
				#me._viewPort._y -= topDif;
				me._viewPort._y = me._focusedItem._bound._y;
			}elsif(bottomDif > 0){
				#me._viewPort._y += bottomDif;
				me._viewPort._y = (me._focusedItem._bound._y + me._focusedItem._bound._height) - me._viewPort._height;
			}else{
				#focused item is inside View nothing to move
			}
		}
	},
	_updateView : func(){
		
		me._moveViewPort();
		me._showItemsInView();
		
		me._listViewListener.onListViewUpdate();
		me._listViewListener.onScrollBarUpdate();

	},
	
	
};




