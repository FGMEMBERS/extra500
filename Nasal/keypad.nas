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
#      Last change:      Dirk Dittmann
#      Date:             27.06.13
#


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

		eSystem.circuitBreaker.KEYPAD.outputAdd(me);
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
	
	
### Buttons
	onSetHeading : func(hdg){
		hdg = int( math.mod(hdg,360) );
		autopilot.nSetHeadingBugDeg.setValue(hdg);
	},
	onAdjustHeading : func(amount=nil){
		if (amount!=nil){
			var value = autopilot.nSetHeadingBugDeg.getValue();
			value += amount;
			value = int( math.mod(value,360) );
			autopilot.nSetHeadingBugDeg.setValue(value);
		}else{
			me.onHeadingSync();
		}
	},
	onHeadingSync : func(){
		var value = me.nHeading.getValue();
		value = int( math.mod(value,360) );
		autopilot.nSetHeadingBugDeg.setValue(value);
	},
	onSetAltitude : func(alt){
		if (alt > 50000){alt = 50000;}
		if (alt < 0){alt = 0;}
			
		autopilot.nSetAltitudeBugFt.setValue(100*int( alt/100) );
	},
	onAdjustAltitude : func(amount=nil){
		if (amount!=nil){
			var value = autopilot.nSetAltitudeBugFt.getValue();
			value += amount;
			if (value > 50000){value = 50000;}
			if (value < 0){value = 0;}
			autopilot.nSetAltitudeBugFt.setValue(value);
		}else{
			me.onAltitudeSync();
		}
	},
	onAltitudeSync : func(){
		var alt = me.nAltitude.getValue();
		if (alt > 50000){alt = 50000;}
		if (alt < 0){alt = 0;}	
		autopilot.nSetAltitudeBugFt.setValue( 100*int( alt/100 ) );
	},
	onFMS : func(amount=nil){
		
	},
	onKey : func(key){
		
	},
	onCom1 : func(){
		
	},
	onCom2 : func(){
		
	},
	onFreqList : func(){
		
	},
	onAux : func(){
		
	},
	onNav1 : func(){
		
	},
	onNav2 : func(){
		
	},
	onXPDR : func(){
		
	},
	onVFR : func(){
		
	},
	onMode : func(){
		
	},
	onIdent : func(){
		
	},
	onPhone : func(){
		
	},
	onMusik : func(){
		
	},
	onProc : func(){
		
	},
	onD : func(){
		
	},
	onV : func(){
		
	},
	onNRST : func(){
		
	},
	onMap : func(){
		
	},
	onCLR : func(){
		
	},
	onCNCL : func(){
		
	},
	onSYB : func(){
		
	},
	onAt : func(){
		
	},
	onSpace : func(){
		
	},
	onEnter : func(){
		
	},
	onCom1Volume : func(amount=nil){
		
	},
	onCom2Volume : func(amount=nil){
		
	},
	onCom1SQ : func(){
		
	},
	onCom2SQ : func(){
		
	},
	onCom1Page : func(amount=nil){
		
	},
	onCom2Page : func(amount=nil){
		
	},
	initUI : func(){
		UI.register("Keypad Heading sync", 	func{extra500.keypad.onHeadingSync(); } 	);
		UI.register("Keypad Heading >", 	func{extra500.keypad.onAdjustHeading(1); } 	);
		UI.register("Keypad Heading <", 	func{extra500.keypad.onAdjustHeading(-1); } 	);
		UI.register("Keypad Heading =", 	func(v=0){extra500.keypad.onSetHeading(v); } 	);
		UI.register("Keypad Heading +=", 	func(v=0){extra500.keypad.onAdjustHeading(v); } );
		
		UI.register("Keypad Altitude sync", 	func{extra500.keypad.onAltitudeSync(); } 	);
		UI.register("Keypad Altitude >", 	func{extra500.keypad.onAdjustAltitude(1); } 	);
		UI.register("Keypad Altitude <", 	func{extra500.keypad.onAdjustAltitude(-1); } 	);
		UI.register("Keypad Altitude =", 	func(v=0){extra500.keypad.onSetAltitude(v); } 	);
		UI.register("Keypad Altitude +=", 	func(v=0){extra500.keypad.onAdjustAltitude(v); });
		
		UI.register("Keypad FMS push", 	func{extra500.keypad.onFMS(); } 	);
		UI.register("Keypad FMS >", 	func{extra500.keypad.onFMS(1); } 	);
		UI.register("Keypad FMS <", 	func{extra500.keypad.onFMS(-1); } 	);
		
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
		
		UI.register("Keypad Com1", 	func{extra500.keypad.onCom1(); } 	);
		UI.register("Keypad Com2", 	func{extra500.keypad.onCom2(); } 	);
		UI.register("Keypad FreqList", 	func{extra500.keypad.onFreqList(); } 	);
		UI.register("Keypad Aux", 	func{extra500.keypad.onAux(); } 	);
		UI.register("Keypad Nav1", 	func{extra500.keypad.onNav1(); } 	);
		UI.register("Keypad Nav2", 	func{extra500.keypad.onNav2(); } 	);
		UI.register("Keypad XPDR", 	func{extra500.keypad.onXPDR(); } 	);
		UI.register("Keypad VFR", 	func{extra500.keypad.onVFR(); } 	);
		UI.register("Keypad Mode", 	func{extra500.keypad.onMode(); } 	);
		UI.register("Keypad Ident", 	func{extra500.keypad.onIdent(); } 	);
		UI.register("Keypad Phone", 	func{extra500.keypad.onPhone(); } 	);
		UI.register("Keypad Musik", 	func{extra500.keypad.onMusik(); } 	);
		UI.register("Keypad Proc", 	func{extra500.keypad.onProc(); } 	);
		UI.register("Keypad D", 	func{extra500.keypad.onD(); } 	);
		UI.register("Keypad V", 	func{extra500.keypad.onV(); } 	);
		UI.register("Keypad NRST", 	func{extra500.keypad.onNRST(); } 	);
		UI.register("Keypad Map", 	func{extra500.keypad.onMap(); } 	);
		UI.register("Keypad CLR", 	func{extra500.keypad.onCLR(); } 	);
		UI.register("Keypad CNCL", 	func{extra500.keypad.onCNCL(); } 	);
		UI.register("Keypad SYB", 	func{extra500.keypad.onSYB(); } 	);
		UI.register("Keypad At", 	func{extra500.keypad.onAt(); } 	);
		UI.register("Keypad Space", 	func{extra500.keypad.onSpace(); } 	);
		UI.register("Keypad Enter", 	func{extra500.keypad.onEnter(); } 	);
		
		UI.register("Keypad Com1Volume >", 	func{extra500.keypad.onCom1Volume(1); } 	);
		UI.register("Keypad Com2Volume <", 	func{extra500.keypad.onCom2Volume(-1); } 	);
		UI.register("Keypad Com1SQ", 	func{extra500.keypad.onCom1SQ(); } 	);
		UI.register("Keypad Com2SQ", 	func{extra500.keypad.onCom2SQ(); } 	);
		UI.register("Keypad Com1Page >", 	func{extra500.keypad.onCom1Page(1); } 	);
		UI.register("Keypad Com2Page <", 	func{extra500.keypad.onCom2Page(-1); } 	);

		
	}
	
	
};

var keypad = KeypadClass.new("extra500/instrumentation/Keypad","Keypad");
