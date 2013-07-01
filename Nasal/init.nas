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
	
	settimer(func(){
		
		print("Extra500 init");
		extra500.eSystem.checkSource();
		extra500.eSystem.init();
		extra500.engine.init();
		extra500.gearSystem.init();
		extra500.flapSystem.init();
		extra500.fuelSystem.init();
		extra500.autopilot.init();
		IFD.LH.init();
		IFD.RH.init();
		extra500.keypad.init();
		
		
		extra500.engineInstrumentPackage.init();
		extra500.digitalInstrumentPackage.init();
		extra500.lumi.init();
		extra500.stbyHSI.init();
		extra500.stbyIAS.init();
		extra500.stbyALT.init();
		extra500.fuelQuantity.init();
		extra500.propellerHeat.init();
		extra500.turnCoordinator.init();
		extra500.annunciator.init();
		
		
		
		print("Extra500 starting");
		
		extra500.eSystem.timerLoop.start();
		extra500.engine.timerLoop.start();
		extra500.fuelSystem.timerLoop.start();
		extra500.autopilot.timerLoop.start();
		#IFD.LH.timerLoop.start();
		#IFD.RH.timerLoop.start();
		#extra500.keypad.start();
		
		extra500.digitalInstrumentPackage.timerLoop.start();
		#extra500.gearSystem.timerLoop.start();
		#extra500.flapSystem.timerLoop.start();
		
		
	},1);

		
});