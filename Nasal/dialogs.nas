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
#      Date: April 23 2013
#
#      Last change:      Eric van den Berg
#      Date:             23.06.13
#


var debug_electric = gui.Dialog.new(
			"sim/gui/dialogs/ground_services/dialog",
			"Aircraft/extra500/Dialogs/debug_electric.xml"
		);

var autopilot = gui.Dialog.new("/sim/gui/dialogs/autopilot/dialog",
        "Aircraft/extra500/Dialogs/autopilot.xml");

var radios = gui.Dialog.new("/sim/gui/dialogs/radios/dialog",
        "Aircraft/extra500/Dialogs/radios.xml");

# var fuelPayload = gui.Dialog.new("/sim/gui/dialogs/fuel/dialog",
#         "Aircraft/extra500/Dialogs/fuelpayload.xml");




#gui.menuBind("autopilot-settings", "Dialogs.autopilot.open()");



# var FuelPayloadClass = {
# 	new : func(){
# 		var m = {parents:[FuelPayloadClass]};
# 		m._nRoot = props.globals.initNode("/sim/gui/dialogs/FuelPayload/dialog");
# 		m._name  = "Fuel and Payload";
# 		m._title = "Fuel and Payload Settings";
# 		m._fdmdata = {
# 			grosswgt : "/fdm/jsbsim/inertia/weight-lbs",
# 			payload  : "/payload",
# 			cg       : "/fdm/jsbsim/inertia/cg-x-in",
# 		};
# 		m._tankIndex = [
# 			"LeftAuxiliary",
# 			"LeftMain",
# 			"LeftCollector",
# 			"Engine",
# 			"RightCollector",
# 			"RightMain",
# 			"RightAuxiliary"
# 			];
# 		
# 		
# 		m._listeners = [];
# 		
# 		m._dialog = gui.Widget.new();
# 		m._dialog.set("name", m._name);
# 		
# 		m._isOpen = 0;
# 		m._isNotInitialized = 1;
# 		return m;
# 	},
# 	_setListeners : func(){
# 		foreach (index ; me._tankIndex){
# 			
# 		}
# 		
# 		
# 	},
# 	_removeListeners : func(){
# 		foreach(l;me._listeners){
# 			removelistener(l);
# 		}
# 		me._listeners = [];
# 	},
# 	init : func(){
# 		
# 	},
# 	close : func(){
# 		fgcommand("dialog-close", props.Node.new({ "dialog-name": me._name }));
# 		me._isOpen = 0;
# 	},
# 	open : func(){
# 		if(me._isNotInitialized){
# 			me._draw();
# 		}
# 		fgcommand("dialog-show", props.Node.new({ "dialog-name" : me._name }));
# 		me._isOpen = 1;
# 	},
# 	toggle : func(){
# 				
# 		if(me._isOpen){
# 			me.close();
# 		}else{
# 			me.open();
# 		}
# 	},
# 	_draw : func(){
# 		print("FuelPayloadClass._draw() ... " ~me._isNotInitialized);
# 		me._dialog.set("layout", "vbox");
# 		
# 		var header = me._dialog.addChild("group");
# 		header.set("layout", "hbox");
# 		header.addChild("empty").set("stretch", "1");
# 		header.addChild("text").set("label", me._title);
# 		header.addChild("empty").set("stretch", "1");
# 		var w = header.addChild("button");
# 		w.set("pref-width", 16);
# 		w.set("pref-height", 16);
# 		w.set("legend", "");
# 		w.set("default", 0);
# 		#w.setBinding("dialog-close");
# 		w.setBinding("nasal", "Dialogs.fuelPayload.toggle()");
# 		
# 		me._dialog.addChild("hrule");
# 
# 		
# 		var contentArea = me._dialog.addChild("group");
# 		contentArea.set("layout", "hbox");
# 		contentArea.set("default-padding", 10);
# 
# 		me._dialog.addChild("empty");
# 		
# 		var fuelTable = contentArea.addChild("group");
# 		fuelTable.set("layout", "table");
# 		
# 		var cell = nil;
# 		cell = fuelTable.addChild("text");
# 			cell.set("row", 0);
# 			cell.set("col", 0);	
# 			cell.set("label", "");
# 		cell = fuelTable.addChild("frame");
# 			cell.set("row", 0);
# 			cell.set("col", 1);	
# 			cell.set("colspan", 3);	
# 			cell = cell.addChild("text");
# 			cell.set("pref-width", 300);	
# 			cell.set("height", 30);	
# 			cell.set("padding", 5);	
# 			cell.set("halign", "center");
# 			cell.set("label", "Left Wing");
# 			
# 			
# 			
# 		cell = fuelTable.addChild("frame");
# 			cell.set("row", 0);
# 			cell.set("col", 4);	
# 			cell = cell.addChild("text");
# 			cell.set("pref-width", 80);	
# 			cell.set("height", 30);	
# 			cell.set("padding", 5);	
# 			cell.set("halign", "center");
# 			cell.set("label", "Center");
# 
# 			
# 		cell = fuelTable.addChild("frame");
# 			cell.set("row", 0);
# 			cell.set("col", 5);	
# 			cell.set("colspan", 3);	
# 			cell = cell.addChild("text");
# 			cell.set("pref-width", 300);	
# 			cell.set("height", 30);	
# 			cell.set("padding", 5);	
# 			cell.set("halign", "center");
# 			cell.set("label", "Right Wing");
# 
# 			
# 		
# 		
# 		cell = fuelTable.addChild("text");
# 			cell.set("row", 2);
# 			cell.set("col", 0);	
# 			cell.set("label", "Capacity");
# 			
# 		cell = fuelTable.addChild("text");
# 			cell.set("row", 3);
# 			cell.set("col", 0);	
# 			cell.set("label", "Level");
# 		
# 		
# 		
# 		var col = 1;
# 		foreach (index ; me._tankIndex){
# 			print("Tank " ~index);
# 			me._drawTankColumn(fuelTable,extra500.fuelSystem._tank[index],1,col);
# 			col += 1;
# 		}
# 		
# 		
# 		
# 		
# 		
# 		var buttonBar = me._dialog.addChild("group");
# 		buttonBar.set("layout", "hbox");
# 		buttonBar.set("default-padding", 10);
# 
# 		var close = buttonBar.addChild("button");
# 		close.set("legend", "Close");
# 		close.set("default", "true");
# 		close.set("key", "Enter");
# 		#close.setBinding("dialog-close");
# 		close.setBinding("nasal", "Dialogs.fuelPayload.toggle()");
# 		
# 		
# 		fgcommand("dialog-new", me._dialog.prop());
# 		me._isNotInitialized = 0;
# 	},
# 	_drawTankColumn : func(parent,tank,row,col){
# 		cell = parent.addChild("text");
# 		#cell.set("pref-width", 100);
# 		cell.set("halign", "center");
# 		cell.set("row", row);
# 		cell.set("col", col);
# 		cell.set("label", tank._name);
# 		
# 		cell = parent.addChild("text");
# 		cell.set("row", row + 1);
# 		cell.set("col", col);
# 		cell.set("halign", "center");
# 		cell.set("label", sprintf("%0.2f lbs",(tank._capacity * global.CONST.JETA_LBGAL)));
# 		
# 		
# 		cell = parent.addChild("frame");
# 		cell.set("border", 1);
# 		cell.set("row", row + 2);
# 		cell.set("col", col);
# 		cell.set("layout", "hbox");
# 		var detail = nil;
# 		
# 		if (tank._position == "Right"){
# 			detail = cell.addChild("group"); 
# 		}
# 		
# 		if (tank._refuelable){
# 			
# 			var slider = cell.addChild("slider");
# 			slider.set("vertical", 1);
# 			slider.set("property", "/consumables/fuel/tank["~tank._index ~ "]/level-gal_us");
# 			slider.set("live", 1);
# 			slider.set("min", 0);
# 			slider.set("max", tank._capacity);
# 			slider.setBinding("dialog-apply");
# 			
# 		}
# 		
# 		if (tank._position != "Right"){
# 			detail = cell.addChild("group"); 
# 		}
# 		
# 		detail.set("layout", "vbox");
# 		
# 		cell = detail.addChild("text");
# 		cell.set("property", "/consumables/fuel/tank["~tank._index ~ "]/level-lbs");
# 		cell.set("label", "0123456");
# 		cell.set("format", "%.2f lbs");
# 		cell.set("halign", "center");
# 		cell.set("live", 1);
# 		
# 		cell = detail.addChild("text");
# 		cell.set("property", "/consumables/fuel/tank["~tank._index ~ "]/level-norm");
# 		cell.set("label", "0123456");
# 		cell.set("format", "%.2f");
# 		cell.set("halign", "center");
# 		cell.set("live", 1);
# 	},
# 	
# };
# 
# 
# var fuelPayload = FuelPayloadClass.new();

gui.menuBind("fuel-and-payload", "Dialogs.fuelPayload.toggle();");