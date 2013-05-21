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
#      Date: May 18 2013
#
#      Last change:      Dirk Dittmann
#      Date:             18.05.13
#



var Keypad = {
	new : func(nRoot,name){
				
		var m = {parents:[
			Keypad,
			Part.Part.new(nRoot,name),
			Part.SimStateAble.new(nRoot,"BOOL",0),
			Part.ElectricAble.new(nRoot,name)
		]};
		
		m.dimmingVolt = 0.0;
		
		m.nHeading = props.globals.initNode("/orientation/heading-deg",0,"DOUBLE");
		m.nAltitude = props.globals.initNode("/instrumentation/altimeter-backup/indicated-altitude-ft",0,"DOUBLE");
		
	
	# Light
		m.Backlight = Part.ElectricLED.new(m.nRoot.initNode("Backlight"),"EIP Backlight");
		m.Backlight.electricConfig(8.0,28.0);
		m.Backlight.setPower(24.0,1.0);
	
	# buses
		m.PowerInputBus = Part.ElectricBusDiode.new("PowerInputBus");
		m.GNDBus = Part.ElectricBusDiode.new("GNDBus");
		m.PowerBus = Part.ElectricBus.new("PowerBus");
				
		
	# Electric Connectors
		m.PowerInput		= Part.ElectricPin.new("PowerInput");
		m.GND 			= Part.ElectricPin.new("GND");
		m.Dimming		= Part.ElectricConnector.new("Dimming");
		
		m.__GND			= Part.ElectricConnector.new("__GND");
		m.__Power		= Part.ElectricConnector.new("__Power");
		
		m.Dimming.solder(m);
		m.__Power.solder(m);
		m.__GND.solder(m);
		
		append(Part.aListSimStateAble,m);
		return m;

	},
	applyVoltage : func(electron,name=""){ 
		Part.etd.in("Keypad",me.name,name,electron);
		var GND = 0;
		
		if (electron != nil){
			electron.resistor += 20000.0;
			if (name == "__Power"){
				GND = me.__GND.applyVoltage(electron);
				if (GND){
					me.state = 1;
					var watt = me.electricWork(electron);
				}
			}elsif(name == "Dimming"){
				
				GND = me.__GND.applyVoltage(electron);
				if (GND){
					
					me.dimmingVolt = electron.volt;					
					var watt = me.electricWork(electron);
					
					
				}
			}
		}
		
		Part.etd.out("Keypad",me.name,name,electron);
		return GND;
	},
	plugElectric : func(){
		
		me.PowerInput.plug(me.PowerBus.con());
		
		me.Backlight.Plus.plug(me.PowerBus.con());
		me.Backlight.Minus.plug(me.GNDBus.con());
		
		me.__Power.plug(me.PowerBus.con());
		me.__GND.plug(me.GNDBus.con());
		
		me.GNDBus.Minus.plug(me.GND);
	},
	_dimmBacklight : func(){
		if (me.dimmingVolt < 8.0){
			me.Backlight.setBrightness(1.0);
		}else{
			me.Backlight.setBrightness( me.dimmingVolt / 28.0);
		}
		me.dimmingVolt = 0.0;
	},
	# Main Simulation loop  ~ 10Hz
	update : func(timestamp){
		
		me._dimmBacklight();
		
		if (me.state == 0){	# no power input
			
		}else{
			
		}
	},
	onSetHeading : func(hdg){
		hdg = math.mod(hdg,360);
		autopilot.nSetHeadingBugDeg.setValue(hdg);
	},
	onAdjustHeading : func(amount=nil){
		if (amount!=nil){
			var value = autopilot.nSetHeadingBugDeg.getValue();
			value += amount;
			value = math.mod(value,360);
			autopilot.nSetHeadingBugDeg.setValue(value);
		}else{
			me.onHeadingSync();
		}
	},
	onHeadingSync : func(){
		var value = me.nHeading.getValue();
		value = math.mod(value,360);
		autopilot.nSetHeadingBugDeg.setValue(value);
	},
	onSetAltitude : func(alt){
		if (alt > 50000){alt = 50000;}
		if (alt < 0){alt = 0;}
			
		autopilot.nSetTargetAltitudeFt.setValue(alt);
	},
	onAdjustAltitude : func(amount=nil){
		if (amount!=nil){
			var value = autopilot.nSetTargetAltitudeFt.getValue();
			value += amount;
			if (value > 50000){value = 50000;}
			if (value < 0){value = 0;}
			autopilot.nSetTargetAltitudeFt.setValue(value);
		}else{
			me.onAltitudeSync();
		}
	},
	onAltitudeSync : func(){
		var value = me.nAltitude.getValue();
		if (value > 50000){value = 50000;}
		if (value < 0){value = 0;}	
		autopilot.nSetTargetAltitudeFt.setValue(value);
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

var keypad = Keypad.new(props.globals.initNode("extra500/instrumentation/Keypad"),"Keypad");
