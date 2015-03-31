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
#      Date: 20.03.2015
#
#      Last change:      Dirk Dittmann
#      Date:             31.03.2015
#

var Environment = {
	new : func(root,name){
		var m = { 
			parents : [
				Environment
			]
		};
		me._updateSec = 1.0;
		me._timerLoop = nil;
		return m;
	},
	init : func(instance=nil){
		me.setListeners(instance);
		
		me._timerLoop = maketimer(me._updateSec,me,Environment.update);
		me._timerLoop.start();
	},
	setListeners : func(instance) {
		
	},
	update : func(){
		
		me.rainSplashVector();
	},
	rainSplashVector : func(){
		var airspeed = getprop("/velocities/airspeed-kt");

		# f16
		var airspeed_max = 250;

		if (airspeed > airspeed_max) {airspeed = airspeed_max;}

		airspeed = math.sqrt(airspeed/airspeed_max);

		var splash_x = -0.1 - 2.0 * airspeed;
		var splash_y = 0.0;
		var splash_z = 1.0 - 1.35 * airspeed;



		interpolate("/environment/aircraft-effects/splash-vector-x", splash_x,1.0);
		interpolate("/environment/aircraft-effects/splash-vector-y", splash_y,1.0);
		interpolate("/environment/aircraft-effects/splash-vector-z", splash_z,1.0);

	},
	
};

var environment = Environment.new("/extra500/environment","Environment");

