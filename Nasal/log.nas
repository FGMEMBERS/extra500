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
#      Date: Jul 20 2013
#
#      Last change:      Eric van den Berg
#      Date:             05.07.2018
#

var FuelFlowLogClass = {
	new : func(){
		var m = { 
			parents : [
				FuelFlowLogClass
			]
		};
		m._nFuelFlow		= props.globals.getNode("/fdm/jsbsim/aircraft/engine/FF-lbs_h");
		m._fuelFow		= 0;
		m._dt = 0;
		
		m._stats = {
			gs	: 0,
			alt	: 0,
			vs	: 0,
			FL	: 0,
			GS	: 0,
			VS	: 0,
			pPath	: 0,
			realFlow: 0,
			
		};
		
		m._now = systime();
		m._lastTime = m._now;
		m._timerLoop = nil;
		
		
		return m;
	},
	setListeners : func(instance) {
	
		
	},
	init : func(instance=nil){
		if (instance==nil){instance=me;}
		me.setListeners(instance);
		
		
		me._timerLoop = maketimer(5.0,me,FuelFlowLogClass.update);
		me._timerLoop.start();
		
	},
	update : func(){
		me._now 	= systime();
		me._dt 		= me._now - me._lastTime;
		me._lastTime	= me._now;
		
		me._stats.realFlow	= me._nFuelFlow.getValue();
		me._stats.gs		= getprop("/velocities/groundspeed-kt") or 0;
		
		if(me._stats.gs > 60.0){
			
			me._stats.alt 	= getprop("/instrumentation/altimeter-IFD-LH/indicated-altitude-ft") or 0;
			me._stats.vs	= getprop("/instrumentation/ivsi-IFD-LH/indicated-speed-fpm") or 0;
			
			me._stats.FL		= sprintf("FL%03i",int((me._stats.alt/1000)+0.5)*10);
			me._stats.GS		= sprintf("GS%03i",int((me._stats.gs/10)+0.5)*10);
			me._stats.VS		= sprintf("VS%05i",int((me._stats.vs/100)+0.5)*100);
			
			me._stats.pPath 	= "/extra500/log/fuel/"~me._stats.FL~"_"~me._stats.GS~"_"~me._stats.VS~"_ffph";
			
			me._stats.Flow	= getprop(me._stats.pPath) or me._stats.realFlow ;
			me._stats.Flow 	= (me._stats.Flow * 0.75) + (me._stats.realFlow * 0.25);
			setprop(me._stats.pPath,me._stats.Flow);
		}
		
	},
	getBurnRate : func(alt,gs,vs){
		me._stats.FL		= sprintf("FL%03i",int((alt/10)+0.5)*10);
		me._stats.GS		= sprintf("GS%03i",int((gs/10)+0.5)*10);
		me._stats.VS		= sprintf("VS%05i",int(vs));
		
		me._stats.pPath 	= "/extra500/log/fuel/"~me._stats.FL~"_"~me._stats.GS~"_"~me._stats.VS~"_ffph";
		return getprop(me._stats.pPath) or 250.0;
	}
};

var PositionLogClass = {
	new : func(){
		var m = { 
			parents : [
				PositionLogClass
			]
		};
		
		m._timerLoop = nil;
	
		return m;
	},
	init : func(instance=nil){
		if (instance==nil){instance=me;}
		
		me._timerLoop = maketimer(5.0,me,PositionLogClass.update);
		me._timerLoop.start();
		
	},
	update : func(){
		if (getprop("/extra500/exit/updatePos") == 1) {  # do not update as long as the init dialog is open
			setprop("/extra500/exit/latitude-deg", getprop("/position/latitude-deg"));
      		setprop("/extra500/exit/longitude-deg", getprop("/position/longitude-deg"));
      		setprop("/extra500/exit/heading-deg", getprop("/orientation/heading-deg"));
		}
	}

};

var fuelFlowLog = FuelFlowLogClass.new();
var PositionLog = PositionLogClass.new();
