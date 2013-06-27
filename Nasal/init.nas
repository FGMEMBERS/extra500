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
#      Date: Jun 26 2013
#
#      Last change:      Dirk Dittmann
#      Date:             26.06.13
#

var init_listener = setlistener("/sim/signals/fdm-initialized", func {
	
	removelistener(init_listener);
	init_listener = nil;
	
	IFD.LH.init();
	IFD.RH.init();
	extra500.eSystem.init();
	extra500.engine.init();
	extra500.gearSystem.init();
	extra500.flapSystem.init();
	extra500.fuelSystem.init();
	extra500.autopilot.init();
	
	IFD.LH.timerLoop.start();
	IFD.RH.timerLoop.start();
	extra500.eSystem.timerLoop.start();
	extra500.engine.timerLoop.start();
	extra500.fuelSystem.timerLoop.start();
	extra500.autopilot.timerLoop.start();
	#extra500.gearSystem.timerLoop.start();
	#extra500.flapSystem.timerLoop.start();


		
});