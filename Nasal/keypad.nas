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
#      Date:             18.08.13
#
var KeypadClassDisplay = {
	new: func(root,name,acPlace){
		var m = { parents: [
			KeypadClassDisplay,
			extra500.ServiceClass.new(root,name)
		] };
		m.svgFile	= "Keypad.svg";
		m.width 	= 378;
		m.height	= 128;
		
		
		m.canvas = canvas.new({
		"name": "Keypad",
		"size": [m.width, m.height],
		"view": [m.width, m.height],
		"mipmapping": 1,
		});
		
		m.canvas.addPlacement({"node": acPlace});
		m.canvas.setColorBackground(1,1,1);
		m.page = m.canvas.createGroup(name);
		
		canvas.parsesvg(m.page, "Models/instruments/IFDs/"~m.svgFile,{
			"font-mapper": global.canvas.FontMapper
			}
		);
		
		m._can = {
			com1Selected 	: m.page.getElementById("Com1_selected"),
			com1Standby 	: m.page.getElementById("Com1_standby"),
			com1input 	: m.page.getElementById("Com1_input").setVisible(0),
			com2Selected 	: m.page.getElementById("Com2_selected"),
			com2Standby 	: m.page.getElementById("Com2_standby"),
			com2input 	: m.page.getElementById("Com2_input").setVisible(0),
			nav1Selected 	: m.page.getElementById("Nav1_selected"),
			nav1Standby 	: m.page.getElementById("Nav1_standby"),
			nav1input 	: m.page.getElementById("Nav1_input").setVisible(0),
			nav2Selected 	: m.page.getElementById("Nav2_selected"),
			nav2Standby 	: m.page.getElementById("Nav2_standby"),
			nav2input 	: m.page.getElementById("Nav2_input").setVisible(0),
			dataXPDR 	: m.page.getElementById("DATA_XPDR"),
			XPDRvalue 	: m.page.getElementById("XPDR_Value"),
			ALTvalue 	: m.page.getElementById("ALT_Value"),
			HDGvalue 	: m.page.getElementById("HDG_Value"),
			layerData 	: m.page.getElementById("layer2").setVisible(1),
			layerXPDR 	: m.page.getElementById("layer3").setVisible(0),
			layerHDG 	: m.page.getElementById("layer4").setVisible(0),
			layerALT 	: m.page.getElementById("layer5").setVisible(0),
			layerNAV 	: m.page.getElementById("layer6").setVisible(0),
		};
		
		m._xpdr = 0;
		return m;
	},
	setListeners : func(instance) {
		append(me._listeners, setlistener("/instrumentation/comm[0]/frequencies/selected-mhz",func(n){instance._onCom1SelectedChange(n);},1,0) );
		append(me._listeners, setlistener("/instrumentation/comm[0]/frequencies/standby-mhz",func(n){instance._onCom1StanbyChange(n);},1,0) );
		append(me._listeners, setlistener("/instrumentation/comm[1]/frequencies/selected-mhz",func(n){instance._onCom2SelectedChange(n);},1,0) );
		append(me._listeners, setlistener("/instrumentation/comm[1]/frequencies/standby-mhz",func(n){instance._onCom2StanbyChange(n);},1,0) );
		append(me._listeners, setlistener("/instrumentation/nav[0]/frequencies/selected-mhz",func(n){instance._onNav1SelectedChange(n);},1,0) );
		append(me._listeners, setlistener("/instrumentation/nav[0]/frequencies/standby-mhz",func(n){instance._onNav1StanbyChange(n);},1,0) );
		append(me._listeners, setlistener("/instrumentation/nav[1]/frequencies/selected-mhz",func(n){instance._onNav2SelectedChange(n);},1,0) );
		append(me._listeners, setlistener("/instrumentation/nav[1]/frequencies/standby-mhz",func(n){instance._onNav2StanbyChange(n);},1,0) );
		append(me._listeners, setlistener("/instrumentation/transponder/id-code",func(n){instance._onXPDRChange(n);},1,0) );
		append(me._listeners, setlistener("/autopilot/settings/heading-bug-deg",func(n){instance._onHdgChange(n);},1,0) );
		append(me._listeners, setlistener("/autopilot/settings/tgt-altitude-ft",func(n){instance._onAltChange(n);},1,0) );
	},
	init : func(instance=nil){
		if (instance==nil){instance=me;}
		me.parents[1].init(instance);
		me.setListeners(instance);
	},
	_onCom1SelectedChange : func(n){
		me._can.com1Selected.setText(sprintf("%.3f",n.getValue()));
	},
	_onCom1StanbyChange : func(n){
		me._can.com1Standby.setText(sprintf("%.3f",n.getValue()));
	},
	_onCom2SelectedChange : func(n){
		me._can.com2Selected.setText(sprintf("%.3f",n.getValue()));
	},
	_onCom2StanbyChange : func(n){
		me._can.com2Standby.setText(sprintf("%.3f",n.getValue()));
	},
	_onNav1SelectedChange : func(n){
		me._can.nav1Selected.setText(sprintf("%.3f",n.getValue()));
	},
	_onNav1StanbyChange : func(n){
		me._can.nav1Standby.setText(sprintf("%.3f",n.getValue()));
	},
	_onNav2SelectedChange : func(n){
		me._can.nav2Selected.setText(sprintf("%.3f",n.getValue()));
	},
	_onNav2StanbyChange : func(n){
		me._can.nav2Standby.setText(sprintf("%.3f",n.getValue()));
	},
	_onXPDRChange : func(n){
		me._xpdr = n.getValue(); 
		me._can.dataXPDR.setText(sprintf("%i",me._xpdr));
		me._can.XPDRvalue.setText(sprintf("%i",me._xpdr));
	},
	_onHdgChange : func(n){
		me._can.HDGvalue.setText(sprintf("%03i",n.getValue()));
	},
	_onAltChange : func(n){
		me._can.ALTvalue.setText(sprintf("%i",n.getValue()));
	},
	selectCom : func(nr){
		if (nr == 0){
			me._can.com2input.setVisible(0);
			me._can.com2Standby.set("fill","rgb(0,0,0)");
			me._can.com1input.setVisible(1);
			me._can.com1Standby.set("fill","rgb(255,255,255)");
			
		}elsif(nr == 1){
			me._can.com1Standby.set("fill","rgb(0,0,0)");
			me._can.com1input.setVisible(0);
			me._can.com2Standby.set("fill","rgb(255,255,255)");
			me._can.com2input.setVisible(1);
			
		}else{
			me._can.com1Standby.set("fill","rgb(0,0,0)");
			me._can.com1input.setVisible(0);
			me._can.com2Standby.set("fill","rgb(0,0,0)");
			me._can.com2input.setVisible(0);
			
		}
	},
	selectNav : func(nr){
		if (nr == 0){
			me._can.nav2input.setVisible(0);
			me._can.nav2Standby.set("fill","rgb(0,0,0)");
			me._can.nav1input.setVisible(1);
			me._can.nav1Standby.set("fill","rgb(255,255,255)");
			
		}elsif(nr == 1){
			me._can.nav1Standby.set("fill","rgb(0,0,0)");
			me._can.nav1input.setVisible(0);
			me._can.nav2Standby.set("fill","rgb(255,255,255)");
			me._can.nav2input.setVisible(1);
			
		}else{
			me._can.nav1Standby.set("fill","rgb(0,0,0)");
			me._can.nav1input.setVisible(0);
			me._can.nav2Standby.set("fill","rgb(0,0,0)");
			me._can.nav2input.setVisible(0);
			
		}
	},
	selectLayer : func(name){
		me._can.layerData.setVisible(0);
		me._can.layerXPDR.setVisible(0);
		me._can.layerHDG.setVisible(0);
		me._can.layerALT.setVisible(0);
		me._can.layerNAV.setVisible(0);
		me.selectCom(-1);
		
		
		me._can["layer"~name].setVisible(1);
		
	}
};

var KeypadClass = {
	new : func(root,name){
				
		var m = {parents:[
			KeypadClass,
			ConsumerClass.new(root,name,3.0)
		]};
		
		
		m.nHeading = props.globals.initNode("/instrumentation/heading-indicator-IFD-LH/indicated-heading-deg",0,"DOUBLE");
		m.nAltitude = props.globals.initNode("/instrumentation/altimeter-IFD-LH/indicated-altitude-ft",0,"DOUBLE");
		
		m._nBrightness		= props.globals.initNode("/extra500/system/dimming/Keypad",0.0,"DOUBLE");
		m._brightness		= 0;
		m._nBacklight 		= m._nRoot.initNode("Backlight/state",0.0,"DOUBLE");
		m._backLight 		= 0;
		m._nCursorX 		= m._nRoot.initNode("cursorX",0,"INT");
		m._nCursorY 		= m._nRoot.initNode("cursorY",0,"INT");
		m._nCursorPush 		= m._nRoot.initNode("cursorPush",0,"BOOL");
		m._nCursorScroll	= m._nRoot.initNode("cursorScroll",0,"INT");
		m._nCom1SQ		= m._nRoot.initNode("com1VolumeSQ",0,"BOOL");
		m._nCom2SQ		= m._nRoot.initNode("com2VolumeSQ",0,"BOOL");
		
		m._cursorScroll = 0;
		
		m._display = KeypadClassDisplay.new("extra500/instrumentation/Keypad/display","LH","Keypad.Display");
		
		m._inputWatchDog = 0;
		m._inputIndex = 0;
		m._inputValue = "";
		m._inputPath = "";
		m._timerLoop = nil;
		return m;

	},
	setListeners : func(instance) {
		append(me._listeners, setlistener(me._nBrightness,func(n){instance._onBrightnessChange(n);},1,0) );
	},
	init : func(instance=nil){
		if (instance==nil){instance=me;}
		me.parents[1].init(instance);
		me.setListeners(instance);
		
		me.initUI();
		me._display.init();
		eSystem.circuitBreaker.KEYPAD.outputAdd(me);
		me.onComSelect(0);
		
		me._timerLoop = maketimer(1,me,KeypadClass.update);
		me._timerLoop.start();
	},
	_onBrightnessChange : func(n){
		me._brightness = n.getValue();
		me.electricWork();
	},
	electricWork : func(){
		if (me._volt > me._voltMin){
			me._watt = me._nWatt.getValue();
			me._ampere = me._watt / me._volt;
			me._state = 1;
			me._backLight = me._brightness;
		}else{
			me._ampere = 0;
			me._state = 0;
			me._backLight = 0;
		}
		
		me._nAmpere.setValue(me._ampere);
		me._nState.setValue(me._state);
		me._nBacklight.setValue(me._backLight);
	},
	update : func(){
		me._inputWatchDog += 1;
		if(me._inputWatchDog > 10){
			me.resetSelection();
		}elsif(me._inputWatchDog >2){
			me._inputIndex = 0;
		}
		
	},
	resetSelection : func(){
		#print("KeypadClass.resetSelection() ...");
		me._inputWatchDog = 0;
		me._display.selectLayer("Data");
		me.onComSelect(getprop("/instrumentation/com2-selected"));
		
	},
	
### Buttons
	onSetHeading : func(hdg){
		hdg = int( math.mod(hdg,360) );
		autopilot.nSetHeadingBugDeg.setValue(hdg);
		
		me._display.selectLayer("HDG");
		me._inputWatchDog = 0;
		me._inputFunc = nil;
	},
	onAdjustHeading : func(amount=nil){
		if (amount!=nil){
			var value = autopilot.nSetHeadingBugDeg.getValue();
			value += amount;
			
			if (math.abs(amount) > 1){
				value = int(value/10)*10;
			}
			
			value = int( math.mod(value,360) );
			autopilot.nSetHeadingBugDeg.setValue(value);
		}else{
			me.onHeadingSync();
		}
		
		me._display.selectLayer("HDG");
		me._inputWatchDog = 0;
		me._inputFunc = nil;
	},
	onHeadingSync : func(){
		var hdg = me.nHeading.getValue();
		hdg = int( math.mod(hdg,360) );
		autopilot.nSetHeadingBugDeg.setValue(hdg);
		
		me._display.selectLayer("HDG");
		me._inputWatchDog = 0;
		me._inputFunc = nil;
	},
	onSetAltitude : func(alt){
		if (alt > 50000){alt = 50000;}
		if (alt < 0){alt = 0;}
			
		autopilot.nSetAltitudeBugFt.setValue(100*int( alt/100) );
		
		me._display.selectLayer("ALT");
		me._inputWatchDog = 0;
		me._inputFunc = nil;
	},
	onAdjustAltitude : func(amount=nil){
		if (amount!=nil){
			var value = autopilot.nSetAltitudeBugFt.getValue();
			value += amount;
			
			if (math.abs(amount) > 100){
				value = int(value/500)*500;
			}
			
			if (value > 50000){value = 50000;}
			if (value < 0){value = 0;}
			autopilot.nSetAltitudeBugFt.setValue(value);
		}else{
			me.onAltitudeSync();
		}
		
		me._display.selectLayer("ALT");
		me._inputWatchDog = 0;
		me._inputFunc = nil;
	},
	onAltitudeSync : func(){
		var alt = me.nAltitude.getValue();
		if (alt > 50000){alt = 50000;}
		if (alt < 0){alt = 0;}	
		autopilot.nSetAltitudeBugFt.setValue( 100*int( alt/100 ) );
		
		me._display.selectLayer("ALT");
		me._inputWatchDog = 0;
		me._inputFunc = nil;
	},
	onFMS : func(amount=0){
		print("KeypadClass.onFMS() ... "~amount);
	},
	onFMSpush : func(){
		print("KeypadClass.onFMSpush() ... ");
	},
	onKey : func(key){
		print("KeypadClass.onKey() ... "~key);
		if (me._inputFunc != nil){
			me._inputFunc(key);
		}
	},
	handleInputCom : func (key){
		if (num(key) != nil){
			#print ("KeypadClass.handleInputCom("~key~") ... "~me._inputValue);
			me._inputIndex +=1;
			if (me._inputIndex == 3){me._inputIndex = 4}
			if (me._inputIndex >= 7){me._inputIndex = 1}
			me._inputValue = substr(me._inputValue,0,me._inputIndex) ~ key ~ substr(me._inputValue,me._inputIndex+1);
			setprop(me._inputPath,me._inputValue);
			me._inputWatchDog = 0;
			
		}
	},
	handleInputXDPR : func (key){
		if (num(key) != nil){
			#print ("KeypadClass.handleInputXDPR("~key~") ... "~me._inputValue);
			if (me._inputIndex >= 4){me._inputIndex = 0}
			me._inputValue = substr(me._inputValue,0,me._inputIndex) ~ key ~ substr(me._inputValue,me._inputIndex+1);
			setprop(me._inputPath,me._inputValue);
			me._inputWatchDog = 0;
			me._inputIndex +=1;
			
		}
	},
	onComSelect : func(nr){
		#print("KeypadClass.onComSelect("~nr~") ...");
		me._display.selectLayer("Data");
		me._display.selectCom(nr);
		me._inputIndex = 0;
		me._inputWatchDog = 0;
		me._inputPath = "/instrumentation/comm["~nr~"]/frequencies/standby-mhz";
		me._inputValue = sprintf("%0.3f",getprop(me._inputPath));
		me._inputFunc = me.handleInputCom;
		
	},
	onFreqList : func(){
		print("KeypadClass.onFreqList() ...");
		
	},
	onAux : func(){
		print("KeypadClass.onAux() ...");
		
	},
	onNavSelect : func(nr){
		#print("KeypadClass.onNavSelect("~nr~") ...");
		me._display.selectLayer("NAV");
		me._display.selectNav(nr);
		me._inputIndex = 0;
		me._inputWatchDog = 0;
		me._inputPath = "/instrumentation/nav["~nr~"]/frequencies/standby-mhz";
		me._inputValue = sprintf("%0.3f",getprop(me._inputPath));
		me._inputFunc = me.handleInputCom;
	},
	onXPDR : func(){
		#print("KeypadClass.onXPDR() ...");
		me._display.selectLayer("XPDR");
		me._inputIndex = 0;
		me._inputWatchDog = 0;
		me._inputPath = "/instrumentation/transponder/id-code";
		me._inputValue = sprintf("%i",getprop(me._inputPath));
		me._inputFunc = me.handleInputXDPR;
	},
	onVFR : func(){
		setprop("/instrumentation/transponder/id-code",getprop("/instrumentation/transponder/vfr-id") );		
	},
	onMode : func(){
		setprop("/instrumentation/transponder/inputs/auto-select",0 );
		var mode = getprop("/instrumentation/transponder/inputs/knob-mode")+1;
		if (mode == 6) {mode = 0;}
		setprop("/instrumentation/transponder/inputs/knob-mode",mode );		
	},
	onIdent : func(){
		setprop("/instrumentation/transponder/inputs/ident-btn","true");	 #FIXME: should return to "false" after ~2sec	
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
		extra500.autopilot.DirectTO();		
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
		me.swapCom1();
	},
	onCom2Scroll : func(amount=nil){
		#print("KeypadClass.onCom2Scroll() ... "~amount);
		me.swapCom2();
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
	
	swapCom1 : func(){
		var selected 	= getprop("/instrumentation/comm[0]/frequencies/selected-mhz");
		var standby	= getprop("/instrumentation/comm[0]/frequencies/standby-mhz");
		
		setprop("/instrumentation/comm[0]/frequencies/selected-mhz",standby);
		setprop("/instrumentation/comm[0]/frequencies/standby-mhz",selected);
	},
	swapCom2 : func(){
		var selected 	= getprop("/instrumentation/comm[1]/frequencies/selected-mhz");
		var standby	= getprop("/instrumentation/comm[1]/frequencies/standby-mhz");
		
		setprop("/instrumentation/comm[1]/frequencies/selected-mhz",standby);
		setprop("/instrumentation/comm[1]/frequencies/standby-mhz",selected);
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
