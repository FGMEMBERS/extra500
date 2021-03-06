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
#      Date: 20.03.15
#
#	Last change:	Dirk Dittmann
#	Date:		30.04.15
#

var ELT = {
	new : func(root,name){
		var m = { 
			parents : [
				ELT,
				ServiceClass.new(root,name)
			]
		};
		
		m._switchRemote = 0;
		m._switchElt 	= 0;
		m._switchG 	= 0;
		m._active	= 0;
		m._cycleSec	= 50;
		
		m._nSwitchRemote	 = m._nRoot.initNode("switch-remote",m._switchRemote,"INT");
		m._nSwitchElt		 = m._nRoot.initNode("switch-elt",m._switchElt,"INT");
		m._nSwitchG		 = m._nRoot.initNode("switch-G",m._switchG,"BOOL");
		m._nLed			 = m._nRoot.initNode("led",m._active,"BOOL");
		
		m._multiplayer = 1;
		return m;
	},
	setListeners : func(instance) {
		append(me._listeners, setlistener(me._nSwitchRemote,func(n){instance._onSwitchRemoteChange(n);},1,0) );
		append(me._listeners, setlistener(me._nSwitchElt,func(n){instance._onSwitchEltChange(n);},1,0) );
		append(me._listeners, setlistener(me._nSwitchG,func(n){instance._onSwitchGChange(n);},1,0) );
	},
	init : func(instance=nil){
		if (instance==nil){instance=me;}
		
		me._timerLoop = maketimer(me._cycleSec,me,ELT._transmit);
		
		me.setListeners(instance);
		me.initUI();
		
		
				
	},
	initUI : func(){
		UI.register("ELT remote >", 		func{extra500.elt.adjustSwitchRemote(1); 	});
		UI.register("ELT remote <", 		func{extra500.elt.adjustSwitchRemote(-1); 	});
		UI.register("ELT remote on", 		func{extra500.elt._nSwitchRemote.setValue(-1); 	});
		UI.register("ELT remote arm", 		func{extra500.elt._nSwitchRemote.setValue(0);  	});
		UI.register("ELT remote test", 		func{extra500.elt._nSwitchRemote.setValue(1); 	});
		
		UI.register("ELT >", 		func{extra500.elt.adjustSwitchElt(1); 		});
		UI.register("ELT <", 		func{extra500.elt.adjustSwitchElt(-1); 		});
		UI.register("ELT on", 		func{extra500.elt._nSwitchElt.setValue(-1); 	});
		UI.register("ELT arm", 		func{extra500.elt._nSwitchElt.setValue(0); 	});
		UI.register("ELT test", 	func{extra500.elt._nSwitchElt.setValue(1); 	});
		
		
		
	},
	adjustSwitchRemote : func(value=0){
		value = me._nSwitchRemote.getValue() + value;
		value = global.clamp(value,-1,1);
		me._nSwitchRemote.setValue(value);
	},
	adjustSwitchElt : func(value=0){
		value = me._nSwitchElt.getValue() + value;
		value = global.clamp(value,-1,1);
		me._nSwitchElt.setValue(value);
	},
	
	_onSwitchRemoteChange : func(n){
		me._switchRemote = n.getValue();
		
		if (me._switchRemote == 1){
			me._setActive(1);
			settimer(func{UI.click("ELT remote arm")}, 1);
		}elsif (me._switchRemote == -1){
			me._setActive(1);
		}else{
			me._setActive(0);
		}
		
	},
	_onSwitchEltChange : func(n){
		me._switchElt = n.getValue();
		
		if (me._switchElt == 1){
			me._setActive(1);
			settimer(func{UI.click("ELT arm")}, 1);
		}elsif (me._switchRemote == -1){
			me._setActive(1);
		}else{
			me._setActive(0);
		}
		
	},
	_onSwitchGChange : func(n){
		me._switchG = n.getValue();
		if (me._switchG >= 1){
			me._setActive(1);
		}
	},
	_setActive : func(v){
		if(v==1){
			if (me._active == 0){
				me._active = 1;
				me._transmit();
				me._timerLoop.start();
			}
		}else{
			
			me._active = 0;
			me._timerLoop.stop();
		}
		me._nLed.setValue(me._active);
	},
# 	_update : func(){
# 		if (me._active == 0){
# 			if ( (me._switchRemote == -1) or (me._switchElt == -1) or (me._switchG == 1)){
# 				
# 				me._setActive(1);
# 			}
# 		}else{
# 			if ( (me._switchRemote == 1) or (me._switchElt == 1) ){
# 				
# 				me._setActive(0);
# 				
# 			}
# 		}
# 		
# 	},
	_transmit : func(){
		var aircraft = getprop("sim/description");
		var callsign = getprop("sim/multiplay/callsign");
		var aircraft_id = aircraft ~ ", " ~ callsign;

		var lat = getprop("/position/latitude-string");
		var lon = getprop("/position/longitude-string");
		#var msg = "ELT AutoMessage: " ~ aircraft_id ~ ", CRASHED AT LAT: " ~lat~" LON: "~lon~", REQUESTING SAR SERVICE";
		var msg = sprintf("[ELT SAR REQUEST] %s, LAT: %s LON: %s", aircraft_id, lat, lon);
		
		if (getprop("/extra500/config/ui/elt")){
			setprop("/sim/multiplay/chat", msg);
		}else{
			UI.msg.failure(msg);
		}
	}
	
	
};

var elt = ELT.new("/extra500/instrumentation/elt","ELT");
