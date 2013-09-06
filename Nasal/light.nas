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
#      Date: Jul 04 2013
#
#      Last change:      Dirk Dittmann
#      Date:             06.09.13
#

var LightClass = {
	new : func(root,name,watt=0.3){
		var m = { 
			parents : [
				LightClass,
				ConsumerClass.new(root,name,watt)
			]
		};
		m._nOutPut		= m._nRoot.initNode("output",1.0,"DOUBLE");
		
		m._value = 0;
		m._output= 0.0;
		return m;
	},
	init : func(instance=nil){
		if (instance==nil){instance=me;}
		me.parents[1].init(instance);
	},
	electricWork : func(){
		if ((me._value == 1 ) and (me._volt > me._voltMin) ){
			me._ampere 	= me._watt / me._volt;
			me._state  	= 1;
			me._output 	= me._qos * me._voltNorm;
		}else{
			me._state  	= 0;
			me._ampere 	= 0;
			me._output 	= 0;
			
		}
		
		me._nOutPut.setValue(me._output);
		me._nState.setValue(me._state);
		me._nAmpere.setValue(me._ampere);
	},
	setState : func(value){
		me._value = value;
		me.electricWork();
	},
};


var LightPanelClass = {
	new : func(){
		var m = { 
			parents : [
				LightPanelClass
			]
		};
		m.strope	= LightClass.new("/extra500/light/strobe","Strobe Light",25.0);
		m.nav		= LightClass.new("/extra500/light/nav","Navigation Light",25.0);
		m.landing	= LightClass.new("/extra500/light/landing","Landing Light",25.0);
		m.recognition	= LightClass.new("/extra500/light/recognition","Recognition Light",25.0);
		m.cabin		= LightClass.new("/extra500/light/cabin","Cabin Light",25.0);
		m.map		= LightClass.new("/extra500/light/map","Map Light",25.0);
		m.glare		= LedClass.new("/extra500/light/glare","Glare Light","/extra500/system/dimming/Glare",25.0);
		m.ice		= LightClass.new("/extra500/light/ice","Ice Light",25.0);
		m.courtesy	= LightClass.new("/extra500/light/courtesy","Courtesy Light",25.0);
		
		
		return m;
	},
	init : func(instance=nil){
		
		eSystem.circuitBreaker.STROBE_LT.outputAdd(me.strope);
		eSystem.circuitBreaker.NAV_LT.outputAdd(me.nav);
		eSystem.circuitBreaker.LDG_LT.outputAdd(me.landing);
		eSystem.circuitBreaker.RECO_LT.outputAdd(me.recognition);
		eSystem.circuitBreaker.CABIN_LT.outputAdd(me.cabin);
		eSystem.circuitBreaker.CABIN_LT.outputAdd(me.map);
		eSystem.circuitBreaker.GLARE_LT.outputAdd(me.glare);
		eSystem.circuitBreaker.ICE_LT.outputAdd(me.ice);
		eSystem.circuitBreaker.COURTESY_LT.outputAdd(me.courtesy);
		
		me.strope.init();
		me.nav.init();
		me.landing.init();
		me.recognition.init();
		me.cabin.init();
		me.map.init();
		me.glare.init();
		me.ice.init();
		me.courtesy.init();
		
		eSystem.switch.Strobe.onStateChange = func(n){
			me._state = n.getValue();
			light.strope.setState(me._state);
		};
		
		eSystem.switch.Navigation.onStateChange = func(n){
			me._state = n.getValue();
			light.nav.setState(me._state);
		};
		
		eSystem.switch.Landing.onStateChange = func(n){
			me._state = n.getValue();
			light.landing.setState(me._state);
		};
		
		eSystem.switch.Recognition.onStateChange = func(n){
			me._state = n.getValue();
			light.recognition.setState(me._state);
		};
		
		eSystem.switch.Cabin.onStateChange = func(n){
			me._state = n.getValue();
			light.cabin.setState(me._state);
		};
		
		eSystem.switch.Map.onStateChange = func(n){
			me._state = n.getValue();
			light.map.setState(me._state);
		};
		
		eSystem.switch.Glare.onStateChange = func(n){
			me._state = n.getValue();
			light.glare.setState(me._state);
		};
		
		eSystem.switch.Ice.onStateChange = func(n){
			me._state = n.getValue();
			light.ice.setState(me._state);
		};
		
		
	},
	
	
};

var light = LightPanelClass.new();