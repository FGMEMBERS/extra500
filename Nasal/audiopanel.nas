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
#      Date:             Aug 12 2013
#

# /sim/sound/volume
# /sim/sound/effects/volume
# /sim/sound/avionics/enabled
# /sim/sound/avionics/volume
# /sim/sound/atc/volume
# /instrumentation/comm[0]/volume
# /instrumentation/comm[1]/volume
# /instrumentation/nav[0]/volume
# /instrumentation/nav[1]/volume
# /instrumentation/dme/volume
# /instrumentation/marker-beacon/volume
# /instrumentation/marker-beacon/audio-btn
#
# NOTE: 	it looks like it is currently not possible in FG to switch comm1 and 2, control receive and send seperately or even control the comm volumes
# 		However the volume properties are controlled in the code below. So if FG implements...
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
# initialisation of avionics and com volumes
		var vol = getprop("/sim/sound/avionics/volume");
		setprop("/extra500/instrumentation/Audiopanel/knobs/crewVol",vol);
		setprop("/instrumentation/comm[0]/volume",vol);
		setprop("/instrumentation/comm[1]/volume",vol);

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
		var newvol = getprop("/extra500/instrumentation/Audiopanel/knobs/crewVol") + 0.1;
		if (newvol > 1){newvol = 1;}
		setprop("/extra500/instrumentation/Audiopanel/knobs/crewVol",newvol);
		setprop("/sim/sound/avionics/volume",newvol);
		if (getprop("/instrumentation/comm-selected-index") == 0 ) {
			setprop("/instrumentation/comm[0]/volume",newvol);
		} else {
			setprop("/instrumentation/comm[1]/volume",newvol);
		}
	},
	onClickvolcrewmin : func(){
		var newvol = getprop("/extra500/instrumentation/Audiopanel/knobs/crewVol") - 0.1;
		if (newvol < 0.1){newvol = 0.1;}
		setprop("/extra500/instrumentation/Audiopanel/knobs/crewVol",newvol);
		setprop("/sim/sound/avionics/volume",newvol);
		if (getprop("/instrumentation/comm-selected-index") == 0 ) {
			setprop("/instrumentation/comm[0]/volume",newvol);
		} else {
			setprop("/instrumentation/comm[1]/volume",newvol);
		}
	},
	onClickvolpassplus : func(){
		var newvol = getprop("/extra500/instrumentation/Audiopanel/knobs/passVol") + 0.1;
		if (newvol > 1){newvol = 1;}
		setprop("/extra500/instrumentation/Audiopanel/knobs/passVol",newvol);
	},
	onClickvolpassmin : func(){
		var newvol = getprop("/extra500/instrumentation/Audiopanel/knobs/passVol") - 0.1;
		if (newvol < 0.1){newvol = 0.1;}
		setprop("/extra500/instrumentation/Audiopanel/knobs/passVol",newvol);
	},
	onClickMRKleft : func(){
		print("mrk left");
	},
	onClickICS : func(){
		print("ICS");
	},
	onClickcom1rcv : func(){
		if (getprop("/extra500/instrumentation/Audiopanel/knobs/com1rcv") == 0) {
			setprop("/extra500/instrumentation/Audiopanel/knobs/com1rcv",1);
			setprop("/instrumentation/comm[0]/volume",getprop("/extra500/instrumentation/Audiopanel/knobs/crewVol"));
		} else if (getprop("/extra500/instrumentation/Audiopanel/knobs/com1xmt") == 0) {
			setprop("/extra500/instrumentation/Audiopanel/knobs/com1rcv",0);
			setprop("/instrumentation/comm[0]/volume",0.0);
		} else {
			# IRL the last received message in playbacked. no such functionality in FG yet
		}
	},
	onClickcom2rcv : func(){
		if (getprop("/extra500/instrumentation/Audiopanel/knobs/com2rcv") == 0) {
			setprop("/extra500/instrumentation/Audiopanel/knobs/com2rcv",1);
			setprop("/instrumentation/comm[1]/volume",getprop("/extra500/instrumentation/Audiopanel/knobs/crewVol"));
		} else if (getprop("/extra500/instrumentation/Audiopanel/knobs/com2xmt") == 0) {
			setprop("/extra500/instrumentation/Audiopanel/knobs/com2rcv",0);
			setprop("/instrumentation/comm[1]/volume",0.0);
		} else {
			# IRL the last received message in playbacked. no such functionality in FG yet
		}
	},
	onClickcom1xmt : func(){
		if (getprop("/extra500/instrumentation/Audiopanel/knobs/com1xmt") == 0) {
			setprop("/extra500/instrumentation/Audiopanel/knobs/com2rcv",0);
			setprop("/extra500/instrumentation/Audiopanel/knobs/com2xmt",0);
			setprop("/extra500/instrumentation/Audiopanel/knobs/com1xmt",1);
			setprop("/extra500/instrumentation/Audiopanel/knobs/com1rcv",1);
			setprop("/instrumentation/com1-selected",1);
			setprop("/instrumentation/com2-selected",0);
			setprop("/instrumentation/comm-selected-index",0);
			setprop("/instrumentation/comm[0]/volume",getprop("/extra500/instrumentation/Audiopanel/knobs/crewVol"));
			setprop("/instrumentation/comm[1]/volume",0.0);
		}
	},
	onClickcom2xmt : func(){
		if (getprop("/extra500/instrumentation/Audiopanel/knobs/com2xmt") == 0) {
			setprop("/extra500/instrumentation/Audiopanel/knobs/com1rcv",0);
			setprop("/extra500/instrumentation/Audiopanel/knobs/com1xmt",0);
			setprop("/extra500/instrumentation/Audiopanel/knobs/com2xmt",1);
			setprop("/extra500/instrumentation/Audiopanel/knobs/com2rcv",1);
			setprop("/instrumentation/com1-selected",0);
			setprop("/instrumentation/com2-selected",1);
			setprop("/instrumentation/comm-selected-index",1);
			setprop("/instrumentation/comm[0]/volume",0.0);
			setprop("/instrumentation/comm[1]/volume",getprop("/extra500/instrumentation/Audiopanel/knobs/crewVol"));
		}
	},
	onClicknav1 : func(){
		if (getprop("/extra500/instrumentation/Audiopanel/knobs/nav1") == 0) {
			setprop("/extra500/instrumentation/Audiopanel/knobs/nav1",1);
			setprop("/instrumentation/nav[0]/volume",0.2);
		} else {
			setprop("/extra500/instrumentation/Audiopanel/knobs/nav1",0);
			setprop("/instrumentation/nav[0]/volume",0.0);
		}
	},
	onClicknav2 : func(){
		if (getprop("/extra500/instrumentation/Audiopanel/knobs/nav2") == 0) {
			setprop("/extra500/instrumentation/Audiopanel/knobs/nav2",1);
			setprop("/instrumentation/nav[1]/volume",0.2);
		} else {
			setprop("/extra500/instrumentation/Audiopanel/knobs/nav2",0);
			setprop("/instrumentation/nav[1]/volume",0.0);
		}
	},
	onClickMRKright : func(){
		if (getprop("/extra500/instrumentation/Audiopanel/knobs/mkr") == 0) {
			setprop("/extra500/instrumentation/Audiopanel/knobs/mkr",1);
			setprop("/instrumentation/marker-beacon/volume",0.2);
		} else {
			setprop("/extra500/instrumentation/Audiopanel/knobs/mkr",0);
			setprop("/instrumentation/marker-beacon/volume",0.0);
		}
	},
	onClicktel : func(){
		print("tel");
	},
	onClickmon1 : func(){
		if (getprop("/extra500/instrumentation/Audiopanel/knobs/mon1") == 0) {
			setprop("/extra500/instrumentation/Audiopanel/knobs/mon1",1);
			setprop("/instrumentation/dme/volume",0.2);
		} else {
			setprop("/extra500/instrumentation/Audiopanel/knobs/mon1",0);
			setprop("/instrumentation/dme/volume",0.0);
		}
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
