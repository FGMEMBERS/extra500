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
#      Date: Jul 02 2013
#
#      Last change:      Dirk Dittmann
#      Date:             02.07.13
#
# MM Page 563

var CabinClass = {
	new : func(root,name){
		var m = { 
			parents : [
				CabinClass,
				ServiceClass.new(root,name)
			]
		};
		m._nCabinPressure	= m._nRoot.initNode("hasPressureWarning",0,"BOOL");
		m._nBleedOvertemp	= m._nRoot.initNode("hasBleedOvertempWarning",0,"BOOL");
		
		m._nBlackoutOnsetG	= props.globals.initNode("/sim[0]/rendering[0]/redout[0]/parameters[0]/blackout-onset-g",0,"DOUBLE");
		m._blackoutOnsetG	= 3.5;# FG default
		m._nBlackoutOnsetG.setValue(m._blackoutOnsetG);
		
		m._nBlackoutCompleteG	= props.globals.initNode("/sim[0]/rendering[0]/redout[0]/parameters[0]/blackout-complete-g",0,"DOUBLE");
		m._blackoutCompleteG	= 5.0;# FG default
		m._nBlackoutCompleteG.setValue(m._blackoutCompleteG);
		
		m._nCabinPressureAltFt  = props.globals.initNode("/instrumentation[0]/cabin-altitude[0]/pressure-alt-ft",0,"DOUBLE");
		m._oxygenLevel 		= 1.0;
		m._oxygenRate 		= 0.05; # Levelchange/deltaT
		m._updateDeltaT 	= 15.0;
		m._timerLoop = nil;
		
		return m;
	},
	init : func(instance=nil){
		if (instance==nil){instance=me;}
		me.parents[1].init(instance);
		me._timerLoop = maketimer(me._updateDeltaT,me,CabinClass.update);
		me._timerLoop.start();
	},
	update : func(){
		me.oxygen();
	},
	oxygen : func(){
		
		 
		var cabinPressureAlt = me._nCabinPressureAltFt.getValue();
		
		if (cabinPressureAlt > 18000.0){# ab 9600 ft
			me._oxygenRate = -((cabinPressureAlt * 0.00000053 - 0.0045321637) * me._updateDeltaT);
		}else{
			me._oxygenRate = 0.0025 * me._updateDeltaT;
		}
		
		me._oxygenLevel += me._oxygenRate;
				
		me._oxygenLevel = global.clamp(me._oxygenLevel,0.001,1.0);
		
		var blackoutOn 		= me._blackoutOnsetG * (me._oxygenLevel);
		var blackoutComplete 	= me._blackoutCompleteG * (me._oxygenLevel);
		
		
		blackoutOn 		= global.clamp(blackoutOn,0.1,me._blackoutOnsetG);
		blackoutComplete 	= global.clamp(blackoutComplete,1.1,me._blackoutCompleteG);
		
		
		#print(sprintf("%f/%f : %f += %f",blackoutOn,blackoutComplete,me._oxygenLevel,me._oxygenRate));
		
		interpolate(me._nBlackoutOnsetG,blackoutOn,me._updateDeltaT);
		interpolate(me._nBlackoutCompleteG,blackoutComplete,me._updateDeltaT);
		
		
	},

};

var cabin = CabinClass.new("/extra500/cabin","Cabin");