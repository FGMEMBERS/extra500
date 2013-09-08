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
#      Last change:      Eric van den Berg
#      Date:             07.09.13
#

var init_listener = setlistener("/sim/signals/fdm-initialized", func {
	
	removelistener(init_listener);
	init_listener = nil;
	
	settimer(func(){
		
		print("Extra500 init");
		extra500.eSystem.checkSource();
		
		extra500.engine.init();
		extra500.gearSystem.init();
		extra500.flapSystem.init();
		extra500.fuelSystem.init();
		extra500.autopilot.init();
		extra500.fms.init();
		
		IFD.LH.init();
		IFD.RH.init();
		IFD.tcasModel.init();
		
		extra500.keypad.init();
		extra500.mainDoor.init();
		extra500.cabin.init();
		extra500.deiceSystem.init();
		
		
	# instrument.nas
		extra500.engineInstrumentPackage.init();
		extra500.digitalInstrumentPackage.init();
		extra500.lumi.init();
		extra500.stbyHSI.init();
		extra500.stbyIAS.init();
		extra500.stbyALT.init();
		extra500.fuelQuantity.init();
		extra500.fuelFlow.init();
		extra500.propellerHeat.init();
		extra500.turnCoordinator.init();
		extra500.pcBoard1.init();
		extra500.cabincontroller.init();
		extra500.cabinaltimeter.init();
		extra500.cabinclimb.init();
		extra500.dmeInd.init();
		
		extra500.annunciator.init();
		extra500.light.init();
		extra500.centerConsole.init();
		extra500.fuelFlowLog.init();
		
		extra500.eSystem.init();
		
		
		
		
	},1);

		
});
