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
#      Authors: Eric van den Berg
#      Date: Aug 10 2013
#
#      Last change:      Eric van den Berg 
#      Date:             Aug 11 2013
#

var AudiopanelClass = {
	new : func(root,name){
		var m = {parents:[
			AudiopanelClass,
			ConsumerClass.new(root,name,12.0)
		]};
		
		
		m.dimmingVolt = 0.0;

		m.nAPState 	= props.globals.getNode("/extra500/instrumentation/Audiopanel/state");		
		
		m._nBrightness		= props.globals.initNode("/extra500/system/dimming/Instrument",0.0,"DOUBLE");
		m._brightness		= 0;
		m._brightnessListener   = nil;
		m._nBacklight 		= m._nRoot.initNode("Backlight/state",0.0,"DOUBLE");
		
		m.dt = 0;
		m.now = systime();
		m._lastTime = 0;
		m.timerLoop = nil;
		
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
		
		print("AudiopanelClass.init() ... ");
		eSystem.circuitBreaker.AUDIO_MRK.outputAdd(me);		
		me._timerLoop = maketimer(1.0,me,AudiopanelClass.update);
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
			me._ampere += (0.3 * me._brightness) / me._volt;
			me.nAPState.setValue(1);
		}else{
			me._ampere = 0;
			me.nAPState.setValue(0);
		}
		me._nBacklight.setValue(me._brightness * me._qos * me._voltNorm);
		me._nAmpere.setValue(me._ampere);
	},
	update : func(){	
	},

# Events from the UI
	onClickonoff: func(){
		print("on off");
	},
	onClickvolcrewplus : func(){
		print("crew vol plus");
	},
	onClickvolcrewmin : func(){
		print("crew vol min");
	},
	onClickvolpassplus : func(){
		print("vol pass plus");
	},
	onClickvolpassmin : func(){
		print("vol pass min");
	},
	onClickMRKleft : func(){
		print("mrk left");
	},
	onClickICS : func(){
		print("ICS");
	},
	onClickcom1rcv : func(){
		print("com1rcv");
	},
	onClickcom2rcv : func(){
		print("com2rcv");
	},
	onClickcom1xmt : func(){
		print("com1xmt");
	},
	onClickcom2xmt : func(){
		print("com2xmt");
	},
	onClicknav1 : func(){
		print("nav1");
	},
	onClicknav2 : func(){
		print("nav2");
	},
	onClickMRKright : func(){
		print("MRKright");
	},
	onClicktel : func(){
		print("tel");
	},
	onClickmon1 : func(){
		print("mon1");
	},
	onClickmon2 : func(){
		print("mon2");
	},
	onClickmute : func(){
		print("mute");
	},
	onClickspk : func(){
		print("spk");
	},
	initUI : func(){
		UI.register("Audiopanel on/off", 		func{extra500.audiopanel.onClickonoff(); } 	);
		UI.register("Audiopanel volcrew <", 	func{extra500.audiopanel.onClickvolcrewplus(); } 	);
		UI.register("Audiopanel volcrew >", 	func{extra500.audiopanel.onClickvolcrewmin(); } 	);
		UI.register("Audiopanel volpass <", 	func{extra500.audiopanel.onClickvolpassplus(); } 	);
		UI.register("Audiopanel volpass >", 	func{extra500.audiopanel.onClickvolpassmin(); } 	);
		UI.register("Audiopanel MRKleft", 		func{extra500.audiopanel.onClickMRKleft(); } 	);
		UI.register("Audiopanel ICS", 		func{extra500.audiopanel.onClickICS(); } 	);
		UI.register("Audiopanel com1rcv", 		func{extra500.audiopanel.onClickcom1rcv(); } 	);
		UI.register("Audiopanel com2rcv", 		func{extra500.audiopanel.onClickcom2rcv(); } 	);
		UI.register("Audiopanel com1xmt", 		func{extra500.audiopanel.onClickcom1xmt(); } 	);
		UI.register("Audiopanel com2xmt", 		func{extra500.audiopanel.onClickcom2xmt(); } 	);
		UI.register("Audiopanel nav1", 		func{extra500.audiopanel.onClicknav1(); } 	);
		UI.register("Audiopanel nav2", 		func{extra500.audiopanel.onClicknav2(); } 	);
		UI.register("Audiopanel MRKright", 		func{extra500.audiopanel.onClickMRKright(); } 	);
		UI.register("Audiopanel tel", 		func{extra500.audiopanel.onClicktel(); } 	);
		UI.register("Audiopanel mon1", 		func{extra500.audiopanel.onClickmon1(); } 	);
		UI.register("Audiopanel mon2", 		func{extra500.audiopanel.onClickmon2(); } 	);
		UI.register("Audiopanel mute", 		func{extra500.audiopanel.onClickmute(); } 	);
		UI.register("Audiopanel spk", 		func{extra500.audiopanel.onClickspk(); } 	);
	},	
};

var audiopanel = AudiopanelClass.new("extra500/instrumentation/Audiopanel","Audiopanel");
