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
#      Date: Jun 27 2013
#
#      Last change:      Eric van den Berg
#      Date:             02.02.14
#

# var KeypadDisplayClass = {
# 	new: func(root,name,canvasPlace){
# 		var m = { parents: [
# 			KeypadDisplayClass,
# 			extra500.ServiceClass.new(root,name)
# 		] };
# 		m.svgFile	= "Keypad.svg";
# 		m.width 	= 384;
# 		m.height	= 128;
# 		
# 		
# 		m.canvas = canvas.new({
# 		"name": "Keypad",
# 		"size": [m.width*2, m.height*2],
# 		"view": [m.width, m.height],
# 		"mipmapping": 1,
# 		});
# 		
# 		m.canvas.addPlacement({"node": canvasPlace});
# 		m.canvas.setColorBackground(0,0,0);
# 		m.page = m.canvas.createGroup(name);
# 		
# 		canvas.parsesvg(m.page, "Models/instruments/IFDs/"~m.svgFile,{
# 			"font-mapper": global.canvas.FontMapper
# 			}
# 		);
# 		
# 		
# 		m._widget = {
# 			COM	 : KeypadRadioWidget.new(m,m.page,"Com","comm","layer1"),
# 			NAV	 : KeypadRadioWidget.new(m,m.page,"Nav","nav","layer6"),
# 			DME	 : AuxWidget.new(m,m.page,"layer9"),
# 			FMS	 : KeypadWidget.new(m,m.page,"layer2"),
# 			XPDR	 : KeypadWidget.new(m,m.page,"layer3"),
# 			HDG	 : KeypadWidget.new(m,m.page,"layer4"),
# 			ALT	 : KeypadWidget.new(m,m.page,"layer5"),
# 		};
# 		
# 		m._can = {
# 			dataXPDR 	: m.page.getElementById("FMS_XPDR"),
# 			dataXPDRmode 	: m.page.getElementById("FMS_XPDR_MODE"),
# 			XPDRvalue 	: m.page.getElementById("XPDR_Value"),
# 			XPDRmode 	: m.page.getElementById("XPDR_MODE"),
# 			ALTvalue 	: m.page.getElementById("ALT_Value"),
# 			HDGvalue 	: m.page.getElementById("HDG_Value"),
# 		};
# 		
# 		m._fmsKnobCallback = nil;
# 		m._xpdr = 0;
# 		m._xpdrMode = 0;
# 		m._activeWidget = [nil,nil];
# 		return m;
# 	},
# 	setListeners : func(instance) {
# 		append(me._listeners, setlistener("/instrumentation/transponder/id-code",func(n){instance._onXPDRChange(n);},1,0) );
# 		append(me._listeners, setlistener("/instrumentation/transponder/inputs/knob-mode",func(n){instance._onXPDRmodeChange(n);},1,0) );
# 		append(me._listeners, setlistener("/autopilot/settings/heading-bug-deg",func(n){instance._onHdgChange(n);},1,0) );
# 		append(me._listeners, setlistener("/autopilot/settings/tgt-altitude-ft",func(n){instance._onAltChange(n);},1,0) );
# 	},
# 	init : func(instance=nil){
# 		if (instance==nil){instance=me;}
# 		me.parents[1].init(instance);
# 		me.setListeners(instance);
# 		
# 		me._widget.COM.init();
# 		me._widget.NAV.init();
# 		me._widget.DME.init();
# 		
# 		me._activeWidget[0] = me._widget.COM;
# 		me._activeWidget[0].setVisible(1);
# 		
# 		me._activeWidget[1] = me._widget.FMS;
# 		me._activeWidget[1].setVisible(1);
# 		
# 	},
# 	invertBacklight : func(){
# 		
# 	},
# 	setPower : func(state){
# 		me.page.setVisible(state);
# 	},
# 	_onXPDRChange : func(n){
# 		me._xpdr = n.getValue(); 
# 		me._can.dataXPDR.setText(sprintf("%i",me._xpdr));
# 		me._can.XPDRvalue.setText(sprintf("%i",me._xpdr));
# 	},
# 	_onXPDRmodeChange : func(n){
# 		me._xpdrMode = n.getValue(); 
# 		me._can.dataXPDRmode.setText(IFD.XPDRMODE[me._xpdrMode]);
# 		me._can.XPDRmode.setText(IFD.XPDRMODE[me._xpdrMode]);
# 	},
# 	_onHdgChange : func(n){
# 		me._can.HDGvalue.setText(sprintf("%03i",n.getValue()));
# 	},
# 	_onAltChange : func(n){
# 		me._can.ALTvalue.setText(sprintf("%i",n.getValue()));
# 	},
# 	selectCom : func(nr){
# 		me._widget.COM.select(nr);
# 	},
# 	selectNav : func(nr){
# 		me._widget.NAV.select(nr);
# 	},
# 	resetInput : func(){
# 		me._widget.COM.resetInput();
# 		me._widget.NAV.resetInput();
# 	},
# 	selectWidget : func(index,widget){
# 		if(me._activeWidget[index] != nil){
# 			me._activeWidget[index].setVisible(0);
# 		}
# 		me._activeWidget[index] = me._widget[widget];
# 		me._activeWidget[index].setVisible(1);
# 	}
# };

var COLOR = {};
COLOR["Keypad_Front"] 	= "#000000";
COLOR["Keypad_Back"] 	= "#ffffff";



var ListenerClass = {
	new: func(){
		var m = { parents: [ListenerClass] };
		m._listeners = [];
		return m;
	},
	setListeners : func(instance=me){
		
	},
	removeListeners : func(){
		foreach(var l;me._listeners){
			removelistener(l);
		}
		me._listeners = [];
	},
	
};
var KeypadWidget = {
	new: func(page,canvasGroup){
		var m = { parents: [
			KeypadWidget,
			ListenerClass.new()
		] };
		m._parent 	= page;		# pointer to parent instance
		m._group	= canvasGroup.setVisible(0);	
		m._can = {};
		
		return m;
	},
	init : func(mode,instance=nil){
		if(mode == global.INIT_START){
			
		}elsif (mode == global.INIT_PAUSE){
			
		}elsif (mode == global.INIT_RUN){
			
		}elsif (mode == global.INIT_STOP){
			
		}else{
			print("KeypadWidget.init() ... unsupported init mode");
		}
	},
	setVisible : func(visibility){	me._group.setVisible(visibility); },
	invertBacklight : func(){},
	resetInput : func(){},
};


var KeypadDisplayFreqencyWidget = {
	new: func(page,canvasGroup,name,path){
		var m = { parents: [
			KeypadDisplayFreqencyWidget,
			KeypadWidget.new(page,canvasGroup)
		] };
		m._tree = {
			selected	: props.globals.initNode("/instrumentation/"~path~"/frequencies/selected-mhz",0,"DOUBLE"),
			standby 	: props.globals.initNode("/instrumentation/"~path~"/frequencies/standby-mhz",0,"DOUBLE"),
		};
		#print("KeypadDisplayFreqencyWidget.new() ... "~name);
		m._can = {
			selectedLabel 		: m._group.getElementById(name ~ "_Selected_Label"),
			selectedFrequency	: m._group.getElementById(name ~ "_Selected_Frequency"),
			standbyLabel		: m._group.getElementById(name ~ "_Standby_Label"),
			standbyFrequency	: m._group.getElementById(name ~ "_Standby_Frequency"),
			standbySelection	: m._group.getElementById(name ~ "_Standby_Selection").setVisible(0),
		};
		m._standby		= "";
		m._input		= ["1","-","-",".","-","-","-"];
		m._inputIndex		= 0;
		return m;
	},
	setListeners : func(instance) {
		append(me._listeners, setlistener(me._tree.selected,func(n){instance._onSelectedChange(n);},1,0) );
		append(me._listeners, setlistener(me._tree.standby,func(n){instance._onStanbyChange(n);},1,0) );
	},
	init : func(mode,instance=nil){
		if (instance==nil){instance=me;}
		#me.parents[1].init(instance);
		if(mode == global.INIT_START){
			
		}elsif (mode == global.INIT_RUN){
			me.setListeners(instance);
		}elsif (mode == global.INIT_STOP or mode == global.INIT_PAUSE){
			me.removeListeners();
		}else{
			print("KeypadWidget.init() ... unsupported init mode");
		}
	},
	setVisible : func(visibility){
		if(visibility==1){
			me.init(global.INIT_RUN);
		}else{
			me.init(global.INIT_PAUSE);
		}
	},
	_onSelectedChange : func(n){
		me._can.selectedFrequency.setText(sprintf("%.3f",n.getValue()));
	},
	_onStanbyChange : func(n){
		me._standby = sprintf("%.3f",n.getValue());
		me._can.standbyFrequency.setText(me._standby);
	},
	select : func(value){
		if (value){
			me._can.standbySelection.setVisible(1);
			me._can.standbyFrequency.set("fill","rgb(255,255,255)");
		}else{
			me._can.standbySelection.setVisible(0);
			me._can.standbyFrequency.set("fill","rgb(0,0,0)");
		}
	},
	swap : func(){
		var tmp = me._tree.selected.getValue();
		me._tree.selected.setValue(me._tree.standby.getValue());
		me._tree.standby.setValue(tmp);
	},
	resetInput : func(){
		if (me._inputIndex > 0){
			for (var i = me._inputIndex+1;i <= 6;i +=1){
				if (i != 3){
					me._input[i] = "0";
				}
			}
			me._inputUpdate();
			me._inputIndex = 0;
			me._input		= ["1","-","-",".","-","-","-"];
			me._tree.standby.setValue(me._standby);
		}
	},
	_inputUpdate : func(){
		me._standby = sprintf("%s%s%s%s%s%s%s",me._input[0],me._input[1],me._input[2],me._input[3],me._input[4],me._input[5],me._input[6]);
		me._can.standbyFrequency.setText(me._standby);
	},
	handleInput : func (key){
		if (num(key) != nil){
			print ("KeypadClass.handleInputCom("~key~") ... "~me._standby);
			me._inputIndex +=1;
			if (me._inputIndex == 3){me._inputIndex = 4}
			if (me._inputIndex >= 7){me._inputIndex = 1}
			me._input[me._inputIndex] = key;
			me._inputUpdate();
		}
	},
	
};

var KeypadRadioWidget = {
	new: func(page,canvasGroup,name,path){
		var m = { parents: [
			KeypadRadioWidget,
			KeypadWidget.new(page,canvasGroup)
		] };
		m._name 	= name;
		m._channel = [
			KeypadDisplayFreqencyWidget.new(m,m._group,name~"1",path~"[0]"),
			KeypadDisplayFreqencyWidget.new(m,m._group,name~"2",path~"[1]"),
		];
		m._can = {};
		m._selectedChannel = 0;
		return m;
	},
	init : func(mode,instance=nil){
		me._channel[0].init(mode,instance=nil);
		me._channel[1].init(mode,instance=nil);
	},
	resetInput : func(){
		me._channel[0].resetInput();
		me._channel[1].resetInput();
	},
	setVisible : func(visibility){
		me._group.setVisible(visibility);
		me._channel[0].setVisible(visibility);
		me._channel[1].setVisible(visibility);
		me._parent.setKeyBacklight(me._name~"0",(visibility and (me._selectedChannel == 0)));
		me._parent.setKeyBacklight(me._name~"1",(visibility and (me._selectedChannel == 1)));
		
	},
	select : func(value){
		me._selectedChannel = value;
		if(me._selectedChannel == 0){
			
			me._parent.setKeyBacklight(me._name~"1",0);
			me._channel[1].select(0);
			me._parent.setKeyBacklight(me._name~"0",1);
			me._channel[0].select(1);
			me._parent._inputHandle["Keyboard"] = func(key){me._channel[0].handleInput(key);};
			
		}else{
			me._parent.setKeyBacklight(me._name~"0",0);
			me._channel[0].select(0);
			me._parent.setKeyBacklight(me._name~"1",1);
			me._channel[1].select(1);
			me._parent._inputHandle["Keyboard"] = func(key){me._channel[1].handleInput(key);};
			
		}
	},
};


var KeypadXPDRWidget = {
	new: func(page,canvasGroup){
		var m = { parents: [
			KeypadXPDRWidget,
			KeypadWidget.new(page,canvasGroup)
		] };
		m._tree = {
			code	: props.globals.initNode("/instrumentation/transponder/id-code",0,"INT"),
			mode 	: props.globals.initNode("/instrumentation/transponder/inputs/knob-mode",0,"INT"),
		};
		m._can = {
			value 	: m._group.getElementById("XPDR_Value"),
			mode 	: m._group.getElementById("XPDR_MODE"),
		};
		m._xpdr = 0;
		m._xpdrMode = 0;
		m._inputIndex = 0;
		m._input = ["-","-","-","-"];
		
		return m;
	},
	init : func(mode,instance=nil){
		if (instance==nil){instance=me;}
				
		if(mode == global.INIT_START){
			
		}elsif (mode == global.INIT_RUN){
			me.setListeners(instance);
		}elsif (mode == global.INIT_STOP or mode == global.INIT_PAUSE){
			me.removeListeners();
		}else{
			print("KeypadWidget.init() ... unsupported init mode");
		}
	},
	setListeners : func(instance) {
		append(me._listeners, setlistener(me._tree.code,func(n){instance._onXPDRChange(n);},1,0) );
		append(me._listeners, setlistener(me._tree.mode,func(n){instance._onXPDRmodeChange(n);},1,0) );
	},
	setVisible : func(visibility){
		me._group.setVisible(visibility);
		if(visibility == 1){
			me.init(global.INIT_RUN);
			me._parent.setKeyBacklight("XPDR",1);
			me._parent._inputHandle["Keyboard"] = func(key){me.handleInput(key);};
		}else{
			me.init(global.INIT_PAUSE);
			me._parent.setKeyBacklight("XPDR",0);
			me._parent._inputHandle["Keyboard"] = nil;
		}
	},
	_onXPDRChange : func(n){
		me._xpdr = n.getValue(); 
		me._can.value.setText(sprintf("%i",me._xpdr));
	},
	_onXPDRmodeChange : func(n){
		me._xpdrMode = n.getValue(); 
		me._can.mode.setText(IFD.XPDRMODE[me._xpdrMode]);
	},
	resetInput : func(){
		if (me._inputIndex > 3){
			me._inputUpdate();
			me._inputIndex = 0;
			me._input		= ["-","-","-","-"];
			me._tree.code.setValue(me._xpdr);
		}
	},
	_inputUpdate : func(){
		me._xpdr = sprintf("%s%s%s%s",me._input[0],me._input[1],me._input[2],me._input[3]);
		me._can.value.setText(me._xpdr);
	},
	handleInput : func (key){
		if (num(key) != nil){
			#print ("KeypadClass.handleInputXDPR("~key~") ... "~me._inputValue);
			if (me._inputIndex >= 4){me._inputIndex = 0}
			me._input[me._inputIndex] = key;
			me._inputIndex +=1;
			me._inputUpdate();
		}
	},
	
	
};

var AuxWidget = {
	new: func(page,canvasGroup){
		var m = { parents: [
			AuxWidget,
			KeypadWidget.new(page,canvasGroup)
		] };
		m._tree = {
			nav1	: props.globals.initNode("/instrumentation/nav[0]/frequencies/selected-mhz",0,"DOUBLE"),
			nav2 	: props.globals.initNode("/instrumentation/nav[1]/frequencies/selected-mhz",0,"DOUBLE"),
			dme 	: props.globals.initNode("/instrumentation/dme/frequencies/keypad-selected-mhz",0,"DOUBLE"),
			mode 	: props.globals.initNode("/instrumentation/dme/frequencies/keypad-dme-mode",0,"INT"),
		};
		#setprop("/instrumentation/dme/frequencies/source","/instrumentation/dme/frequencies/keypad-selected-mhz");
		m._can = {
			nav : [
			{
				Selection 	: m._group.getElementById("DME_Nav1_Selection").setVisible(0),
				Label 		: m._group.getElementById("DME_Nav1_Label"),
				Freqency	: m._group.getElementById("DME_Nav1_Freq"),
			},
			{
				Selection 	: m._group.getElementById("DME_Nav2_Selection").setVisible(0),
				Label 		: m._group.getElementById("DME_Nav2_Label"),
				Freqency	: m._group.getElementById("DME_Nav2_Freq"),
			},
			{
				Selection 	: m._group.getElementById("DME_Nav1Hold_Selection").setVisible(0),
				Label 		: m._group.getElementById("DME_Nav1Hold_Label"),
				Freqency	: m._group.getElementById("DME_Nav1Hold_Freq"),
			},
			{
				Selection 	: m._group.getElementById("DME_Nav2Hold_Selection").setVisible(0),
				Label 		: m._group.getElementById("DME_Nav2Hold_Label"),
				Freqency	: m._group.getElementById("DME_Nav2Hold_Freq"),
			},
			],
			Label : m._group.getElementById("DME_Label"),
		};
		m._selection = 0;
		m._lastSelection = 0;
		m._nav1 = 0;
		m._nav2 = 0;
		m._nav = [0,0,0,0];
		m._nav1Hold = 0;
		m._nav2Hold = 0;
		return m;
	},
	setListeners : func(instance) {
		append(me._listeners, setlistener(me._tree.mode,func(n){instance._onmodeChange(n);},1,0) );
		append(me._listeners, setlistener(me._tree.nav1,func(n){instance._onNav1Change(n);},1,0) );
		append(me._listeners, setlistener(me._tree.nav2,func(n){instance._onNav2Change(n);},1,0) );
	},
	init : func(mode,instance=nil){
		if (instance==nil){instance=me;}
		#me.parents[1].init(instance);
		if (instance==nil){instance=me;}
				
		if(mode == global.INIT_START){
			me.setListeners(instance);
		}elsif (mode == global.INIT_RUN){
			me.setListeners(instance);
		}elsif (mode == global.INIT_STOP or mode == global.INIT_PAUSE){
			me.removeListeners();
		}else{
			print("KeypadWidget.init() ... unsupported init mode");
		}
	},
	setVisible : func(visibility){
		me._group.setVisible(visibility);
		if(visibility == 1){
			me._parent.setKeyBacklight("AUX",1);
			me._parent._inputHandle["FmsKnob"] = func(key){me._adjustSelection(key);};
		}else{
			me._parent.setKeyBacklight("AUX",0);
			me._parent._inputHandle["FmsKnob"] = nil;
		}
	},
	_onNav1Change : func(n){
		me._nav[0] = n.getValue();
		me.checkSelection();
	},
	_onNav2Change : func(n){
		me._nav[1] = n.getValue();
		me.checkSelection();
	},
	_onmodeChange : func(n){
		me._selection = n.getValue();
		me.checkSelection();
	},
	checkSelection : func(){
		
		me._can.nav[me._lastSelection].Selection.setVisible(0);
		me._can.nav[me._lastSelection].Label.set("fill",COLOR["Keypad_Front"]);
		me._can.nav[me._lastSelection].Freqency.set("fill",COLOR["Keypad_Front"]);
		
		me._can.nav[me._selection].Selection.set("fill",COLOR["Keypad_Front"]).setVisible(1);
		me._can.nav[me._selection].Label.set("fill",COLOR["Keypad_Back"]);
		me._can.nav[me._selection].Freqency.set("fill",COLOR["Keypad_Back"]);
		
		if(me._selection != 2){
			me._nav[2] = me._nav[0];
		}
		if(me._selection != 3){
			me._nav[3] = me._nav[1];
		}
		
		me._tree.dme.setValue(me._nav[me._selection]);

		me._can.nav[0].Freqency.setText(sprintf("%0.2f",me._nav[0]));
		me._can.nav[1].Freqency.setText(sprintf("%0.2f",me._nav[1]));
		me._can.nav[2].Freqency.setText(sprintf("%0.2f",me._nav[2]));
		me._can.nav[3].Freqency.setText(sprintf("%0.2f",me._nav[3]));
		
		me._lastSelection = me._selection;
	},
	_adjustSelection : func(amount){
		me._selection += -(amount);
		if(me._selection < 0 ){me._selection = 0;}
		if(me._selection > 3 ){me._selection = 3;}
		me._tree.mode.setValue(me._selection);
	},
	
	
};

var FmsWidget = {
	new: func(page,canvasGroup){
		var m = { parents: [
			FmsWidget,
			KeypadWidget.new(page,canvasGroup)
		] };
		m._tree = {
			code	: props.globals.initNode("/instrumentation/transponder/id-code",0,"INT"),
			mode 	: props.globals.initNode("/instrumentation/transponder/inputs/knob-mode",0,"INT"),
		};
		m._can = {
			value 	: m._group.getElementById("FMS_XPDR"),
			mode 	: m._group.getElementById("FMS_XPDR_MODE"),
		};
		
		return m;
	},
	init : func(mode,instance=nil){
		if (instance==nil){instance=me;}
				
		if(mode == global.INIT_START){
			
		}elsif (mode == global.INIT_RUN){
			me.setListeners(instance);
		}elsif (mode == global.INIT_STOP or mode == global.INIT_PAUSE){
			me.removeListeners();
		}else{
			print("KeypadWidget.init() ... unsupported init mode");
		}
	},
	setListeners : func(instance) {
		append(me._listeners, setlistener(me._tree.code,func(n){instance._onXPDRChange(n);},1,0) );
		append(me._listeners, setlistener(me._tree.mode,func(n){instance._onXPDRmodeChange(n);},1,0) );
	},
	
	setVisible : func(visibility){	
		me._group.setVisible(visibility);
		if(visibility == 1){
			me.init(global.INIT_RUN);
			#me._parent.setKeyBacklight("FMS",1);
			#me._parent._inputHandle["Keyboard"] = func(key){me.handleKeyboardInput(key);};
			#me._parent._inputHandle["FmsKnob"] = func(key){me.handleFmsKnobInput(key);};
		}else{
			me.init(global.INIT_PAUSE);
			#me._parent.setKeyBacklight("FMS",0);
			#me._parent._inputHandle["Keyboard"] 	= nil;
			#me._parent._inputHandle["FmsKnob"]	= nil;
		} 
	},
	invertBacklight : func(){},
	_onXPDRChange : func(n){
		me._xpdr = n.getValue(); 
		me._can.value.setText(sprintf("%i",me._xpdr));
	},
	_onXPDRmodeChange : func(n){
		me._xpdrMode = n.getValue(); 
		me._can.mode.setText(IFD.XPDRMODE[me._xpdrMode]);
	},
	handleKeyboardInput : func (key){
		
	},
	handleFmsKnobInput : func (key){
		
	}
	
};

var KeypadClass = {
	new : func(root,name){
				
		var m = {parents:[
			KeypadClass,
			ConsumerClass.new(root,name,18.0)
		]};
		
		m.nTungingSource = m._nRoot.initNode("tuningSource",0,"INT");
		m.nTungingChannel = m._nRoot.initNode("tuningChannel",0,"INT");
		
		
		m.nHeading = props.globals.initNode("/instrumentation/heading-indicator-IFD-LH/indicated-heading-deg",0,"DOUBLE");
		m.nAltitude = props.globals.initNode("/instrumentation/altimeter-IFD-LH/indicated-altitude-ft",0,"DOUBLE");
		
		m._nCursorX 		= m._nRoot.initNode("cursorX",0,"INT");
		m._nCursorY 		= m._nRoot.initNode("cursorY",0,"INT");
		m._nCursorPush 		= m._nRoot.initNode("cursorPush",0,"BOOL");
		m._nCursorScroll	= m._nRoot.initNode("cursorScroll",0,"INT");
		m._nCom1SQ		= m._nRoot.initNode("com1VolumeSQ",0,"BOOL");
		m._nCom2SQ		= m._nRoot.initNode("com2VolumeSQ",0,"BOOL");
		
		m._cursorScroll = 0;
		
		#m._display = KeypadDisplayClass.new("extra500/instrumentation/Keypad/display","LH","Keypad.Display");
		
		m._inputWatchDog = 0;
		m._inputIndex = 0;
		m._inputValue = "";
		m._inputPath = "";
		m._inputHandle = {"Keyboard":nil,"FmsKnob":nil};
		
		m._timerLoop = nil;
		
		
		m._tuningChannel = 0;
		m._tuningSource = 0;
		
		m.svgFile	= "Keypad.svg";
		m.width 	= 384;
		m.height	= 128;
		
		
		m.canvas = canvas.new({
		"name": "Keypad",
		"size": [m.width*2, m.height*2],
		"view": [m.width, m.height],
		"mipmapping": 1,
		});
		
		m.canvas.addPlacement({"node": "Keypad.Display"});
		m.canvas.setColorBackground(0,0,0);
		m.page = m.canvas.createGroup(name);
		
		canvas.parsesvg(m.page, "Models/instruments/IFDs/"~m.svgFile,{
			"font-mapper": global.canvas.FontMapper
			}
		);
		
		
		m._widget = {
			COM	 : KeypadRadioWidget.new(m,m.page.getElementById("layer1"),"Com","comm"),
			NAV	 : KeypadRadioWidget.new(m,m.page.getElementById("layer6"),"Nav","nav"),
			DME	 : AuxWidget.new(m,m.page.getElementById("layer9")),
			FMS	 : FmsWidget.new(m,m.page.getElementById("layer2")),
			XPDR	 : KeypadXPDRWidget.new(m,m.page.getElementById("layer3")),
			HDG	 : KeypadWidget.new(m,m.page.getElementById("layer4")),
			ALT	 : KeypadWidget.new(m,m.page.getElementById("layer5")),
		};
		
		m._can = {
			ALTvalue 	: m.page.getElementById("ALT_Value"),
			HDGvalue 	: m.page.getElementById("HDG_Value"),
		};
		
		m._fmsKnobCallback = nil;
# 		m._xpdr = 0;
# 		m._xpdrMode = 0;
		m._activeWidget = [nil,nil];
				
		m._tree = {
			Backlight : {
				brightness	: props.globals.initNode("/extra500/system/dimming/Keypad",0.0,"DOUBLE"),
				state	: m._nRoot.initNode("Backlight/state",0.0,"DOUBLE"),
				Key : {
					Com0 	: m._nRoot.initNode("Backlight/COM1",0.0,"DOUBLE"),
					Com1 	: m._nRoot.initNode("Backlight/COM2",0.0,"DOUBLE"),
					FREQLIST: m._nRoot.initNode("Backlight/FREQLIST",0.0,"DOUBLE"),
					AUX	: m._nRoot.initNode("Backlight/AUX",0.0,"DOUBLE"),
					Nav0	: m._nRoot.initNode("Backlight/NAV1",0.0,"DOUBLE"),
					Nav1	: m._nRoot.initNode("Backlight/NAV2",0.0,"DOUBLE"),
					XPDR	: m._nRoot.initNode("Backlight/XPDR",0.0,"DOUBLE"),
					VFR	: m._nRoot.initNode("Backlight/VFR",0.0,"DOUBLE"),
					MODE	: m._nRoot.initNode("Backlight/MODE",0.0,"DOUBLE"),
					IDENT	: m._nRoot.initNode("Backlight/IDENT",0.0,"DOUBLE"),
				},
			}
		};
		m._mem = {
			Backlight :{
				brightness : 0,
				state	: 0,
				Key : {
					Com0 	: 0,
					Com1 	: 0,
					FREQLIST: 0,
					AUX	: 0,
					Nav0	: 0,
					Nav1	: 0,
					XPDR	: 0,
					VFR	: 0,
					MODE	: 0,
					IDENT	: 0,
				},
			}
		};
		
		return m;

	},
	setListeners : func(instance) {
		append(me._listeners, setlistener(me._tree.Backlight.brightness,func(n){instance._onBrightnessChange(n);},1,0) );
		append(me._listeners, setlistener("/instrumentation/comm-selected-index",func(n){me._onComSelectedChange(n)},1,0));	
		append(me._listeners, setlistener(me.nTungingSource,func(n){me._onTuningSourceChange(n)},1,0));	
		append(me._listeners, setlistener(me.nTungingChannel,func(n){me._onTuningChannelChange(n)},1,0));	
		#append(me._listeners, setlistener("/instrumentation/transponder/id-code",func(n){instance._onXPDRChange(n);},1,0) );
		#append(me._listeners, setlistener("/instrumentation/transponder/inputs/knob-mode",func(n){instance._onXPDRmodeChange(n);},1,0) );
		append(me._listeners, setlistener("/instrumentation/transponder/ident",func(n){instance._onXPDRidentChange(n);},1,0) );
		append(me._listeners, setlistener("/autopilot/settings/heading-bug-deg",func(n){instance._onHdgChange(n);},1,0) );
		append(me._listeners, setlistener("/autopilot/settings/tgt-altitude-ft",func(n){instance._onAltChange(n);},1,0) );
	
	},
	init : func(mode,instance=nil){
		if (instance==nil){instance=me;}
		me.parents[1].init(instance); # TODO: replace init fucktion
		
		foreach(var i;keys(me._widget)){
			me._widget[i].init(mode);
		}
		
		if(mode == global.INIT_START){
			
			
			me.setListeners(instance);
			
			me.initUI();
						
			eSystem.circuitBreaker.KEYPAD.outputAdd(me);
			
						
			me._timerLoop = maketimer(1,me,KeypadClass.update);
			me._timerLoop.start();
			
			me.resetSelection();		
			
			
		}elsif (mode == global.INIT_PAUSE){
			me.removeListeners();
			me._timerLoop.stop();
		}elsif (mode == global.INIT_RUN){
			me.setListeners(instance);
			me._timerLoop.start();
		}elsif (mode == global.INIT_STOP){
			me.removeListeners();
			me._timerLoop.stop();
		}else{
			print("KeypadClass.init() ... unsupported init mode");
		}
	},
	electricWork : func(){
		if (me._volt > me._voltMin){
			me._watt = me._nWatt.getValue();
			me._ampere = me._watt / me._volt;
			me._state = 1;
			me._mem.Backlight.state = me._mem.Backlight.brightness;
		}else{
			me._ampere = 0;
			me._state = 0;
			me._mem.Backlight.state = 0;
		}
		
		me._nAmpere.setValue(me._ampere);
		me._nState.setValue(me._state);
		me._tree.Backlight.state.setValue(me._mem.Backlight.state);
		me._checkKeyBackLight();
# TODO: replace by invertBacklight() ???
		me.page.setVisible(me._mem.Backlight.state);
	},	
	selectWidget : func(index,widget){
		if(me._activeWidget[index] != nil){
			if(me._activeWidget[index] != me._widget[widget]){
				me._activeWidget[index].setVisible(0);
			}
		}
		me._activeWidget[index] = me._widget[widget];
		me._activeWidget[index].setVisible(1);
	},

	update : func(){
		me._inputWatchDog += 1;
		if(me._inputWatchDog == 15){
			me.resetSelection();
		}elsif(me._inputWatchDog == 5){
			me.resetInput();
		}
		
	},
	resetInput : func(){
		#me._inputIndex = 0;
		if(me._activeWidget[0]!=nil) {me._activeWidget[0].resetInput();}
		if(me._activeWidget[1]!=nil) {me._activeWidget[1].resetInput();}
	},
	resetSelection : func(){
		#print("KeypadClass.resetSelection() ...");
		#me._inputWatchDog = 0;
		me.selectWidget(0,"COM");
		me.selectWidget(1,"FMS");
		me.onComSelect(getprop("/instrumentation/com2-selected"));
		
	},
	setKeyBacklight : func(key,value){
		if(contains(me._mem.Backlight.Key,key)){
			me._mem.Backlight.Key[key] = value;
			me._tree.Backlight.Key[key].setValue(me._mem.Backlight.Key[key] * me._mem.Backlight.brightness);
		}else{
			print("KeypadClass.setKeyBacklight() ... unsupported Key "~key~" : "~value~".");
		}
	},
	_checkKeyBackLight : func(){
		foreach(var i;keys(me._mem.Backlight.Key)){
			me._tree.Backlight.Key[i].setValue(me._mem.Backlight.Key[i] * me._mem.Backlight.brightness);
		}
	},
	_checkTuning : func(){
		me.resetInput();
		if (me._tuningSource == 0){ # COM
			me.selectWidget(0,"COM");
			me._widget.COM.select(me._tuningChannel);
		}else{	# NAV
			me.selectWidget(0,"NAV");
			me._widget.NAV.select(me._tuningChannel);
		}
		me._inputIndex = 0;
		me._inputWatchDog = 0;
	},	
	
### Event onChange ###
	_onBrightnessChange : func(n){
		me._mem.Backlight.brightness = n.getValue();
		me.electricWork();
	},
	_onComSelectedChange : func(n){
		me.onComSelect(n.getValue());
	},
	_onTuningSourceChange : func(n){
		me._tuningSource = n.getValue();
		me._checkTuning();
	},
	_onTuningChannelChange : func(n){
		me._tuningChannel = n.getValue();
		me._checkTuning();
	},
# 	_onXPDRChange : func(n){
# 		me._xpdr = n.getValue(); 
# 		me._can.dataXPDR.setText(sprintf("%i",me._xpdr));
# 		me._can.XPDRvalue.setText(sprintf("%i",me._xpdr));
# 	},
# 	_onXPDRmodeChange : func(n){
# 		me._xpdrMode = n.getValue(); 
# 		me._can.dataXPDRmode.setText(IFD.XPDRMODE[me._xpdrMode]);
# 		me._can.XPDRmode.setText(IFD.XPDRMODE[me._xpdrMode]);
# 	},
	_onXPDRidentChange : func(n){
		if (n.getValue() == 1) {
			me.setKeyBacklight("IDENT",1);
		} else {
			me.setKeyBacklight("IDENT",0);
		}
 	},
	_onHdgChange : func(n){
		me._can.HDGvalue.setText(sprintf("%03i",n.getValue()));
	},
	_onAltChange : func(n){
		me._can.ALTvalue.setText(sprintf("%i",n.getValue()));
	},
	

	
	

	
	
### Buttons
	onSetHeading : func(hdg){
		hdg = int( math.mod(hdg,360) );
		autopilot.nSetHeadingBugDeg.setValue(hdg);
		
		me.selectWidget(1,"HDG");
		me._inputWatchDog = 0;
		me._inputHandle["Keyboard"] = nil;
	},
	onAdjustHeading : func(amount=nil){
		if (amount!=nil){
			var value = autopilot.nSetHeadingBugDeg.getValue();
			
			value = IFD.tool.adjustStep(value,amount,10);
						
			value = int( math.mod(value,360) );
			autopilot.nSetHeadingBugDeg.setValue(value);
		}else{
			me.onHeadingSync();
		}
		
		me.selectWidget(1,"HDG");
		me._inputWatchDog = 0;
		me._inputHandle["Keyboard"] = nil;
	},
	onHeadingSync : func(){
		var hdg = me.nHeading.getValue();
		hdg = int( math.mod(hdg,360) );
		autopilot.nSetHeadingBugDeg.setValue(hdg);
		
		me.selectWidget(1,"HDG");
		me._inputWatchDog = 0;
		me._inputHandle["Keyboard"] = nil;
	},
	onSetAltitude : func(alt){
		alt = global.clamp(alt,0,50000);
		autopilot.nSetAltitudeBugFt.setValue(100*int( alt/100) );
		
		me.selectWidget(1,"ALT");
		me._inputWatchDog = 0;
		me._inputHandle["Keyboard"] = nil;
	},
	onAdjustAltitude : func(amount=nil){
		if (amount!=nil){
			var alt = autopilot.nSetAltitudeBugFt.getValue();
			
			alt = IFD.tool.adjustStep(alt,amount,500);
			alt = global.clamp(alt,0,50000);

			autopilot.nSetAltitudeBugFt.setValue(alt);
		}else{
			me.onAltitudeSync();
		}
		
		me.selectWidget(1,"ALT");
		me._inputWatchDog = 0;
		me._inputHandle["Keyboard"] = nil;
	},
	onAltitudeSync : func(){
		var alt = me.nAltitude.getValue();
		alt = global.clamp(alt,0,50000);
		autopilot.nSetAltitudeBugFt.setValue( 100*int( alt/100 ) );
		
		me.selectWidget(1,"ALT");
		me._inputWatchDog = 0;
		me._inputHandle["Keyboard"] = nil;
	},
	onFMS : func(amount=0){
		print("KeypadClass.onFMS() ... "~amount);
		me._inputWatchDog = 0;
		if (me._inputHandle["FmsKnob"] != nil){
			me._inputHandle["FmsKnob"](amount);
		}
	},
	onFMSpush : func(){
		print("KeypadClass.onFMSpush() ... ");
		me._inputWatchDog = 0;
	},
	onKey : func(key){
		print("KeypadClass.onKey() ... "~key);
		me._inputWatchDog = 0;
		if (me._inputHandle["Keyboard"] != nil){
			me._inputHandle["Keyboard"](key);
		}
	},
# 	handleInputXDPR : func (key){
# 		if (num(key) != nil){
# 			#print ("KeypadClass.handleInputXDPR("~key~") ... "~me._inputValue);
# 			if (me._inputIndex >= 4){me._inputIndex = 0}
# 			me._inputValue = substr(me._inputValue,0,me._inputIndex) ~ key ~ substr(me._inputValue,me._inputIndex+1);
# 			setprop(me._inputPath,me._inputValue);
# 			me._inputWatchDog = 0;
# 			me._inputIndex +=1;
# 			
# 		}
# 	},
	onComSelect : func(nr){
		#print("KeypadClass.onComSelect("~nr~") ...");
		me.nTungingSource.setValue(0);
		me.nTungingChannel.setValue(nr);
		
	},
	onFreqList : func(){
		print("KeypadClass.onFreqList() ...");
		
	},
	onAux : func(){
		#print("KeypadClass.onAux() ...");
		me.selectWidget(1,"DME");
	},
	onNavSelect : func(nr){
		#print("KeypadClass.onNavSelect("~nr~") ...");
		me.nTungingSource.setValue(1);
		me.nTungingChannel.setValue(nr);
	},
	onXPDR : func(){
#FIXME: when the XPDR (widget) is active and this switch is pressed, the widget should disappear
		#print("KeypadClass.onXPDR() ...");
		me.selectWidget(1,"XPDR");
		me._inputIndex = 0;
		me._inputWatchDog = 0;
# 		me._inputPath = "/instrumentation/transponder/id-code";
# 		me._inputValue = sprintf("%i",getprop(me._inputPath));
# 		me._inputHandle["Keyboard"] = func(key){me.handleInputXDPR(key);};
	},
	onVFR : func(){
		me.selectWidget(1,"XPDR");
		setprop("/instrumentation/transponder/id-code",getprop("/instrumentation/transponder/vfr-id") );
# FIXME: the VFR key backlight should be set to 1 as long as the transponder widget is visible: me.setKeyBacklight("VFR",1);		
	},
	onMode : func(){
		me.selectWidget(1,"XPDR");
		setprop("/instrumentation/transponder/inputs/auto-select",0 );
		var mode = getprop("/instrumentation/transponder/inputs/knob-mode")+1;
		if (mode == 6) {mode = 0;}
		setprop("/instrumentation/transponder/inputs/knob-mode",mode );		
	},
	onIdent : func(){
		me.selectWidget(1,"XPDR");
		setprop("/instrumentation/transponder/inputs/ident-btn","true");	 	
	},
	onPhone : func(){
		print("KeypadClass.onPhone() ...");
		
	},
	onSound : func(){
		print("KeypadClass.onSound() ...");
		
	},
	onProc : func(){
		print("KeypadClass.onProc() ...");
		
	},
	onD : func(){
# FIXME: the Directto button backlight should be on when direct-to is active
		extra500.fms.directTo();		
	},
	onV : func(){
		print("KeypadClass.onV() ...");
		
	},
	onNRST : func(){
		print("KeypadClass.onNRST() ...");
		
	},
	onMap : func(){
		print("KeypadClass.onMap() ...");
		
	},
	onCLR : func(){
		print("KeypadClass.onCLR() ...");
		
	},
	onCNCL : func(){
		print("KeypadClass.onCNCL() ...");
		
	},
	onSYB : func(){
		print("KeypadClass.onSYB() ...");
		
	},
	onEnter : func(){
		print("KeypadClass.onEnter() ...");
		
	},
	onCom1Volume : func(amount=nil){
		#print("KeypadClass.onCom1Volume() ... " ~amount);
		var value = getprop("/instrumentation/comm[0]/volume");
		value += amount * 0.05;
		value = global.clamp(value,0.0,1.0);
		setprop("/instrumentation/comm[0]/volume",value);
	},
	onCom2Volume : func(amount=nil){
		#print("KeypadClass.onCom2Volume() ... " ~amount);
		var value = getprop("/instrumentation/comm[1]/volume");
		value += amount * 0.05;
		value = global.clamp(value,0.0,1.0);
		setprop("/instrumentation/comm[1]/volume",value);
	},
	onCom1SQ : func(value){
		print("KeypadClass.onCom1SQ() ... "~value);
		me._nCom1SQ.setValue(value);
	},
	onCom2SQ : func(value){
		print("KeypadClass.onCom2SQ() ... "~value);
		me._nCom2SQ.setValue(value);
	},
	onCom1Scroll : func(amount=nil){
		#print("KeypadClass.onCom1Scroll() ... " ~amount);
		me.resetInput();
		me._activeWidget[0]._channel[0].swap();
	},
	onCom2Scroll : func(amount=nil){
		#print("KeypadClass.onCom2Scroll() ... "~amount);
		me.resetInput();
		me._activeWidget[0]._channel[1].swap();
	},
	onCursorPush : func(value) {
		print("KeypadClass.onCursorPush() ... "~value);
		me._nCursorPush.setValue(value);
	},
	onCursorScroll : func(amount) {
		print("KeypadClass.onCursorScroll() ..."~amount);
		me._cursorScroll += amount;
		me._nCursorScroll.setValue(me._cursorScroll);
	},
	onCursor : func(x=0,y=0) {
		print("KeypadClass.onCursor() ... x:"~x~" y:"~y);
		me._nCursorX.setValue(x);
		me._nCursorY.setValue(y);
	},
	
	
	initUI : func(){
		UI.register("Keypad Heading sync", 	func{extra500.keypad.onHeadingSync(); } 	);
		UI.register("Keypad Heading >", 	func{extra500.keypad.onAdjustHeading(1); } 	);
		UI.register("Keypad Heading <", 	func{extra500.keypad.onAdjustHeading(-1); } 	);
		UI.register("Keypad Heading >>", 	func{extra500.keypad.onAdjustHeading(10); } 	);
		UI.register("Keypad Heading <<", 	func{extra500.keypad.onAdjustHeading(-10); } 	);
		UI.register("Keypad Heading =", 	func(v=0){extra500.keypad.onSetHeading(v); } 	);
		UI.register("Keypad Heading +=", 	func(v=0){extra500.keypad.onAdjustHeading(v); } );
		
		UI.register("Keypad Altitude sync", 	func{extra500.keypad.onAltitudeSync(); } 	);
		UI.register("Keypad Altitude >", 	func{extra500.keypad.onAdjustAltitude(100); } 	);
		UI.register("Keypad Altitude <", 	func{extra500.keypad.onAdjustAltitude(-100); } 	);
		UI.register("Keypad Altitude >>", 	func{extra500.keypad.onAdjustAltitude(500); } 	);
		UI.register("Keypad Altitude <<", 	func{extra500.keypad.onAdjustAltitude(-500); } 	);
		UI.register("Keypad Altitude =", 	func(v=0){extra500.keypad.onSetAltitude(v); } 	);
		UI.register("Keypad Altitude +=", 	func(v=0){extra500.keypad.onAdjustAltitude(v); });
		
		UI.register("Keypad FMS push", 		func{extra500.keypad.onFMS(0); } 	);
		UI.register("Keypad FMS >", 		func{extra500.keypad.onFMS(1); } 	);
		UI.register("Keypad FMS <", 		func{extra500.keypad.onFMS(-1); } 	);
		
		UI.register("Keypad Key 0", 	func{extra500.keypad.onKey("0"); } 	);
		UI.register("Keypad Key 1", 	func{extra500.keypad.onKey("1"); } 	);
		UI.register("Keypad Key 2", 	func{extra500.keypad.onKey("2"); } 	);
		UI.register("Keypad Key 3", 	func{extra500.keypad.onKey("3"); } 	);
		UI.register("Keypad Key 4", 	func{extra500.keypad.onKey("4"); } 	);
		UI.register("Keypad Key 5", 	func{extra500.keypad.onKey("5"); } 	);
		UI.register("Keypad Key 6", 	func{extra500.keypad.onKey("6"); } 	);
		UI.register("Keypad Key 7", 	func{extra500.keypad.onKey("7"); } 	);
		UI.register("Keypad Key 8", 	func{extra500.keypad.onKey("8"); } 	);
		UI.register("Keypad Key 9", 	func{extra500.keypad.onKey("9"); } 	);
		UI.register("Keypad Key Q", 	func{extra500.keypad.onKey("Q"); } 	);
		UI.register("Keypad Key W", 	func{extra500.keypad.onKey("W"); } 	);
		UI.register("Keypad Key E", 	func{extra500.keypad.onKey("E"); } 	);
		UI.register("Keypad Key R", 	func{extra500.keypad.onKey("R"); } 	);
		UI.register("Keypad Key T", 	func{extra500.keypad.onKey("T"); } 	);
		UI.register("Keypad Key Y", 	func{extra500.keypad.onKey("Y"); } 	);
		UI.register("Keypad Key U", 	func{extra500.keypad.onKey("U"); } 	);
		UI.register("Keypad Key I", 	func{extra500.keypad.onKey("I"); } 	);
		UI.register("Keypad Key O", 	func{extra500.keypad.onKey("O"); } 	);
		UI.register("Keypad Key P", 	func{extra500.keypad.onKey("P"); } 	);
		UI.register("Keypad Key A", 	func{extra500.keypad.onKey("A"); } 	);
		UI.register("Keypad Key S", 	func{extra500.keypad.onKey("S"); } 	);
		UI.register("Keypad Key D", 	func{extra500.keypad.onKey("D"); } 	);
		UI.register("Keypad Key F", 	func{extra500.keypad.onKey("F"); } 	);
		UI.register("Keypad Key G", 	func{extra500.keypad.onKey("G"); } 	);
		UI.register("Keypad Key H", 	func{extra500.keypad.onKey("H"); } 	);
		UI.register("Keypad Key J", 	func{extra500.keypad.onKey("J"); } 	);
		UI.register("Keypad Key K", 	func{extra500.keypad.onKey("K"); } 	);
		UI.register("Keypad Key L", 	func{extra500.keypad.onKey("L"); } 	);
		UI.register("Keypad Key .", 	func{extra500.keypad.onKey("."); } 	);
		UI.register("Keypad Key Z", 	func{extra500.keypad.onKey("Z"); } 	);
		UI.register("Keypad Key X", 	func{extra500.keypad.onKey("X"); } 	);
		UI.register("Keypad Key C", 	func{extra500.keypad.onKey("C"); } 	);
		UI.register("Keypad Key V", 	func{extra500.keypad.onKey("V"); } 	);
		UI.register("Keypad Key B", 	func{extra500.keypad.onKey("B"); } 	);
		UI.register("Keypad Key N", 	func{extra500.keypad.onKey("N"); } 	);
		UI.register("Keypad Key M", 	func{extra500.keypad.onKey("M"); } 	);
		UI.register("Keypad Key At", 	func{extra500.keypad.onKey("@"); } 	);
		UI.register("Keypad Key Space", func{extra500.keypad.onKey(" "); } 	);
		UI.register("Keypad Key CLR", 	func{extra500.keypad.onCLR(); } 	);
		UI.register("Keypad Key CNCL", 	func{extra500.keypad.onCNCL(); } 	);
		UI.register("Keypad Key SYB", 	func{extra500.keypad.onSYB(); } 	);
		UI.register("Keypad Key Enter", func{extra500.keypad.onEnter(); } 	);
		
		UI.register("Keypad Com1", 	func{extra500.keypad.onComSelect(0); } 	);
		UI.register("Keypad Com2", 	func{extra500.keypad.onComSelect(1); } 	);
		UI.register("Keypad FreqList", 	func{extra500.keypad.onFreqList(); } 	);
		UI.register("Keypad Aux", 	func{extra500.keypad.onAux(); } 	);
		UI.register("Keypad Nav1", 	func{extra500.keypad.onNavSelect(0); } 	);
		UI.register("Keypad Nav2", 	func{extra500.keypad.onNavSelect(1); } 	);
		UI.register("Keypad XPDR", 	func{extra500.keypad.onXPDR(); } 	);
		UI.register("Keypad VFR", 	func{extra500.keypad.onVFR(); } 	);
		UI.register("Keypad Mode", 	func{extra500.keypad.onMode(); } 	);
		UI.register("Keypad Ident", 	func{extra500.keypad.onIdent(); } 	);
		UI.register("Keypad Phone", 	func{extra500.keypad.onPhone(); } 	);
		UI.register("Keypad Sound", 	func{extra500.keypad.onSound(); } 	);
		UI.register("Keypad Proc", 	func{extra500.keypad.onProc(); } 	);
		UI.register("Keypad D", 	func{extra500.keypad.onD(); } 	);
		UI.register("Keypad V", 	func{extra500.keypad.onV(); } 	);
		UI.register("Keypad NRST", 	func{extra500.keypad.onNRST(); } 	);
		UI.register("Keypad Map", 	func{extra500.keypad.onMap(); } 	);
		
		UI.register("Keypad Com1 Volume >", 	func{extra500.keypad.onCom1Volume(1); } 	);
		UI.register("Keypad Com1 Volume <", 	func{extra500.keypad.onCom1Volume(-1); } 	);
		UI.register("Keypad Com2 Volume >", 	func{extra500.keypad.onCom2Volume(1); } 	);
		UI.register("Keypad Com2 Volume <", 	func{extra500.keypad.onCom2Volume(-1); } 	);
		UI.register("Keypad Com1 SQ down", 	func{extra500.keypad.onCom1SQ(1); } 	);
		UI.register("Keypad Com1 SQ up", 	func{extra500.keypad.onCom1SQ(0); } 	);
		UI.register("Keypad Com2 SQ down", 	func{extra500.keypad.onCom2SQ(1); } 	);
		UI.register("Keypad Com2 SQ up", 	func{extra500.keypad.onCom2SQ(0); } 	);
		UI.register("Keypad Com1 Scroll >", 	func{extra500.keypad.onCom1Scroll(1); } 	);
		UI.register("Keypad Com1 Scroll <", 	func{extra500.keypad.onCom1Scroll(-1); } 	);
		UI.register("Keypad Com2 Scroll >", 	func{extra500.keypad.onCom2Scroll(1); } 	);
		UI.register("Keypad Com2 Scroll <", 	func{extra500.keypad.onCom2Scroll(-1); } 	);
		
		UI.register("Keypad Cursor center", 	func{extra500.keypad.onCursor(0,0); } 	);
		UI.register("Keypad Cursor N", 		func{extra500.keypad.onCursor(0,1); } 	);
		UI.register("Keypad Cursor NE", 	func{extra500.keypad.onCursor(1,1); } 	);
		UI.register("Keypad Cursor E", 		func{extra500.keypad.onCursor(1,0); } 	);
		UI.register("Keypad Cursor SE", 	func{extra500.keypad.onCursor(1,-1); } 	);
		UI.register("Keypad Cursor S", 		func{extra500.keypad.onCursor(0,-1); } 	);
		UI.register("Keypad Cursor SW", 	func{extra500.keypad.onCursor(-1,-1); }	);
		UI.register("Keypad Cursor W", 		func{extra500.keypad.onCursor(-1,0); } 	);
		UI.register("Keypad Cursor NW", 	func{extra500.keypad.onCursor(-1,1); } 	);
		UI.register("Keypad Cursor push down", 	func{extra500.keypad.onCursorPush(1); } 	);
		UI.register("Keypad Cursor push up", 	func{extra500.keypad.onCursorPush(0); } 	);
		UI.register("Keypad Cursor >", 		func{extra500.keypad.onCursorScroll(1); } 	);
		UI.register("Keypad Cursor <", 		func{extra500.keypad.onCursorScroll(-1); } 	);
		
	}
	
	
};

var keypad = KeypadClass.new("extra500/instrumentation/Keypad","Keypad");
