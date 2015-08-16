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
#      Date: 13.03.2014
#
#      Last change:      Dirk Dittmann
#      Date:             16.08.2015
#

var dlgRoot = nil;
			
var startChecklist = "4.6.a Preflight Inspection";

var nChecklists			= props.globals.getNode("/sim/checklists", 1).getChildren("checklist");
var nSelectChecklistPerform 	= props.globals.initNode("/sim/gui/dialogs/checklist/SelectChecklist/perform",0,"BOOL");
var nSelectChecklistEnabled 	= props.globals.initNode("/sim/gui/dialogs/checklist/SelectChecklist/enabled",0,"BOOL");
var nSelectedChecklist 		= props.globals.initNode("/sim/gui/dialogs/checklist/SelectChecklist/selected","","STRING");
var nSelectedPage 		= props.globals.initNode("/sim/gui/dialogs/checklist/SelectChecklist/selectedPage",0,"INT");
var nSelectedItemName 		= props.globals.initNode("/sim/gui/dialogs/checklist/SelectChecklist/selectedItemName","","STRING");
var nSelectedItemValue 		= props.globals.initNode("/sim/gui/dialogs/checklist/SelectChecklist/selectedItemValue","","STRING");
var nSelectedItemIndex	 	= props.globals.initNode("/sim/gui/dialogs/checklist/SelectChecklist/selectedItemIndex",-1,"INT");
var nSelectedItemString 	= props.globals.initNode("/sim/gui/dialogs/checklist/SelectChecklist/selectedItemString","","STRING");
var nConfigTransparent	 	= props.globals.initNode("/sim/gui/dialogs/checklist/config/transparent",0,"BOOL");
var nConfigEnabled 		= props.globals.initNode("/sim/gui/dialogs/checklist/config/enabled",0,"BOOL");
var nConfigMinimised 		= props.globals.initNode("/sim/gui/dialogs/checklist/config/minimised",0,"BOOL");
var nConfigImpatient 		= props.globals.initNode("/sim/gui/dialogs/checklist/config/impatient",0,"BOOL");
var nConfigView			= props.globals.initNode("/sim/gui/dialogs/checklist/config/view",1,"BOOL");
var nConfigMarker		= props.globals.initNode("/sim/gui/dialogs/checklist/config/marker",1,"BOOL");
var nConfigAnnounce		= props.globals.initNode("/sim/gui/dialogs/checklist/config/announce",1,"BOOL");
var nMarker 			= props.globals.getNode("/sim/model/marker", 1);
						

var mapChecklist		= {};
var mapIndexChecklist 		= [];
var listPage			= [];
var listItem 			= [];
var currentChecklistIndex	= -9999;
var currentPageIndex		= -9999;
var currentItemIndex		= -9999;
var currentMarkerIndex 		= -9999;
var currentViewIndex		= -9999;
var listeners 			= [];

var loop_wait_pre = 2;
var loop_wait_post = 3;
var loop_item_index = -1;
var loop_state = 0; # 0:begin, 1:pre, 2:call 3:next
var loop_running = 0;

var setDialogRoot = func(root){
	dlgRoot = root;
}
	

var buildMap = func(){
# 	print("Checklist::buildMap() ... ");
	forindex (var idx; nChecklists) {
		var checklist_name = nChecklists[idx].getNode("title", 1).getValue();
		mapChecklist[checklist_name] = idx;
	}
	#debug.dump(mapChecklist);
	mapIndexChecklist = sort(keys(mapChecklist),cmp);
};

var buildItemList = func(){
# 	print("Checklist::buildItemList()");
	listPage = nChecklists[currentChecklistIndex].getChildren("page");
	listItem =     [];
	
	var row = 0;
	if(size(listPage) > 0){
		foreach (var page; listPage) {
			if(page.getIndex() == currentPageIndex){
# 				print("buildIndex() ... page:"~page.getIndex());
				var items = page.getChildren("item");
				foreach (var item ; items){
				
					append(listItem,item);
				}
			}
		}
	}else{
		var items = nChecklists[currentChecklistIndex].getChildren("item");
		foreach (var item ; items){
			append(listItem,item);
		}
	}
# 	print("Checklist::buildItemList() ... "~size(listItem));
};

var setChecklistByName = func(name,indexPage=0,indexItem=0){
	resetAll();
	if (contains(mapChecklist,name)){
		nSelectedChecklist.setValue(name);
		currentChecklistIndex = mapChecklist[name];
		setPage(indexPage,indexItem);
	}
	
};

var setChecklistByIndex = func(index=0,indexPage=0,indexItem=0){
# 	print("Checklist::setChecklistByIndex("~index~","~indexPage~","~indexItem~")");
	resetAll();
	if( (index >= 0) and (index < size(mapIndexChecklist)) ){
		var name = mapIndexChecklist[index];
		nSelectedChecklist.setValue(name);
		currentChecklistIndex = index;
		setPage(indexPage,indexItem);
	}
	
};

var setChecklistFromProp = func(){
	setChecklistByName(nSelectedChecklist.getValue());
};

var setPage = func(indexPage,indexItem=0){
	if(indexPage < 0) { indexPage = 0; }
	if(indexPage > size(listPage)) { indexPage =  size(listPage)-1; }
	
	if(currentPageIndex != indexPage){
		currentPageIndex = indexPage;
		buildItemList();
		setSelectedItem(0);
	}else{
		buildItemList();
		setSelectedItem(indexItem);
	}
	
};

var scrollPage = func(amount){
	var nextIndex = currentPageIndex + amount;
	setPage(nextIndex);		
};
			
var setItem = func(index){
	if(index < 0) { index = 0; }
	if(index > size(listItem)) { index =  size(listItem)-1; }
	currentItemIndex = index;
	
};

var setSelectedItem = func(index){
	setItem(index);

	nSelectedItemIndex.setValue(currentItemIndex);
	if(size(listItem) > 0){
		var name = listItem[currentItemIndex].getValue("name");
		var value = listItem[currentItemIndex].getValue("value");

		if(name){
			nSelectedItemName.setValue(name);
		}
		if(value){
			nSelectedItemName.setValue(value);
		}
		if(name and value){
			nSelectedItemString.setValue(name ~ " - " ~ value);
		}
	}
};

var getItem = func(index){
	if(index < 0) { index = 0; }
	if(index > size(listItem)) { index =  size(listItem)-1; }
	return listItem[index];
};

var getNextChecklistName = func(){
	var nContinue = nChecklists[currentChecklistIndex].getNode("continue");
	var nextChecklist = "";
	if(nContinue != nil){
		nextChecklist = nContinue.getValue();
	}else{
		var index = currentChecklistIndex + 1;
		
		#print("loopItems 3 count index ... "~idx);
		if((index < size(nChecklists))){
			var item = nChecklists[index];
			if(item != nil){
				nextChecklist = item.getNode("title").getValue();
			}
		}
		
	}
	return nextChecklist;
};




var setView = func(index) {
	var node = getItem(index);
	node != nil or return;
	var v = node.getChild("view");
	var viewEnabled 	= nConfigView.getValue();
	
	if (v != nil) {
		if(viewEnabled and (currentViewIndex != index)){
			v.initNode("view-number", 0, "INT", 0);
			view.point.move(v);
			currentViewIndex = index;
			return 1;
		}
	}else{
# 		print("Checklist::setView("~index~") ... no view.");
	}
	view.resetView();
	currentViewIndex = -9999;
	return 0;
};



var setMarker = func(index){
	setSelectedItem(index);
	var item = getItem(index);
	var enabled 		= nMarker.getValue("arrow-enabled");
	var makerEnabled 	= nConfigMarker.getValue();
	
	if (item != nil){
		var tag = item.getNode("marker");
		if(tag != nil){
			var enabled = ((!enabled) or (currentMarkerIndex != index)) and (makerEnabled);
			nMarker.setValues({
				"x/value": tag.getNode("x-m", 1).getValue(),
				"y/value": tag.getNode("y-m", 1).getValue(),
				"z/value": tag.getNode("z-m", 1).getValue(),
				"scale/value": tag.getNode("scale",1).getValue(1.0),
				"arrow-enabled": enabled,
			});
			
		}else{
# 			print("Checklist::setMarker("~index~") ... no marker.");
			nMarker.setValues({"arrow-enabled": 0});
		}
		setView(index);
	}else{
# 		print("Checklist::setMarker("~index~") ... no item.");
	}
	currentMarkerIndex = index;
};

var callBinding = func(index){
	setSelectedItem(index);
	var item = getItem(index);
	if (item != nil){
	
		var announceEnable = getprop("/sim/gui/dialogs/checklist/config/announce");
		if(announceEnable){
			var announces = item.getChildren("announce");
			foreach (var announce ; announces) {
				var msg = announce.getValue();
				CoPilot.say(msg);
			}
		}
		
		var bindings = item.getChildren("binding");
		foreach (var binding ; bindings) {
			props.runBinding(binding);
		}
		
		
	}else{
# 		print("Checklist::callBinding("~index~") ... no item.");
	}
};



var resetAll = func() {
	setprop("/sim/model/marker/arrow-enabled",0);
# 	nSelectedItemName.setValue("");
# 	nSelectedItemValue.setValue("");
# 	nSelectedItemString.setValue("");
# 	nSelectedItemIndex.setValue(0);
	view.resetView();
	loop_stop();
};

var loopStartStop = func(){
	if(nSelectChecklistPerform.getValue()){
		loop_start();
	}else{
		loop_stop();
	}
};
var loop_start = func(){
	loop_state = 0;
	loop_running = 1;
	loop_timer.singleShot = 1;
	loop_timer.restart(0.01);
	nSelectChecklistPerform.setValue(loop_running);
};

var loop_stop = func(){
	loop_timer.stop();
	loop_running = 0;
	loop_state = 0;
	nSelectChecklistPerform.setValue(loop_running);
};
	
var loopItems = func(){
	if(loop_state == 0){
		loop_item_index = 0;
		nSelectedItemIndex.setValue(loop_item_index);
		if((loop_item_index < size(listItem)) and loop_running){
			loop_state = 1;
			loopItems();
		}else{
			loop_state = 3;
			loopItems();
		}
	}elsif (loop_state == 1){
		if((loop_item_index < size(listItem)) and loop_running){
			var item = listItem[loop_item_index];
			if(item != nil){
				#print("loopItems 1 name ... ");
				
				var name = "";
				var value = "";
				if(item.getNode("name") != nil ){
					name = item.getNode("name").getValue();
					if(name!=nil){
						nSelectedItemName.setValue(name);
					}
													
				}
								
				#print("loopItems 1 wait ... ");
																												
				var loop_wait = nil;
				if(loop_wait == nil){
					loop_wait = loop_wait_pre;
				}
				
				if(nConfigImpatient.getBoolValue() and (loop_wait > 0.1) ){
					loop_wait = 0.1;
				}
				
				if(item.getNode("loop-wait-pre") != nil ){
					loop_wait = item.getNode("loop-wait-pre").getValue();
				}
				
				
				#print("loopItems 1 showMarker ... ");
				setMarker(loop_item_index);
				
				#print("loopItems 1 settimer ... ");
				loop_state = 2;
				loop_timer.restart(loop_wait * 1.0);
				
				
				
				
			}
		}
	}elsif (loop_state == 2){
		if((loop_item_index < size(listItem)) and loop_running){
			var loop_wait = nil;
			var item = listItem[loop_item_index];
			
			
			if(loop_wait == nil){
				loop_wait = loop_wait_pre;
			}
			
			if(nConfigImpatient.getValue() and loop_wait > 0.5){
				loop_wait = 0.5;
			}
			
			if(item.getNode("loop-wait-post") != nil){
				loop_wait = item.getNode("loop-wait-post").getValue();
			}
			
			
			callBinding(loop_item_index);
			loop_state = 3;
			loop_timer.restart(loop_wait * 1.0);
		}
	}elsif (loop_state == 3){
		loop_item_index += 1;
		if((loop_item_index < size(listItem)) and loop_running){
			nSelectedItemIndex.setValue(loop_item_index);
			loop_state = 1;
			loopItems();
		}else{
			if (currentPageIndex < size(listPage)-1){
				scrollPage(1);
				loop_item_index = 0;
				nSelectedItemIndex.setValue(loop_item_index);
				#loop_state = 1;
				#loopItems();
				resetAll();
				redraw();
			}else{
			
				# we are finished 
				#resetAll();
				setChecklistByName(getNextChecklistName());
				redraw();
				
			}
			
			
		}
	}	
};

var redraw = func(nessesary=1){
	if(nessesary){
		fgcommand("dialog-close", dlgRoot);
		fgcommand("dialog-show", dlgRoot);
	}
};

var loop_timer = maketimer(1,loopItems);
buildMap();
setChecklistByIndex(0);
#print("Checklist:: NASAL loaded.");