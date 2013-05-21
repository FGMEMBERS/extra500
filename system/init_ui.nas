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
#      Date: April 07 2013
#
#      Last change:      Dirk Dittmann
#      Date:             30.04.13
#


var initUI = func(){
	UI.register("Ground External Power Generator", 		func{extra500.externalPower.generator(); } 	);
	UI.register("Ground External Power Generator on",	func{extra500.externalPower.generator(1); } 	);
	UI.register("Ground External Power Generator off",	func{extra500.externalPower.generator(0); } 	);
};



extra500.circuitBreakerPanel.initUI();
extra500.sidePanel.initUI();
extra500.masterPanel.initUI();
extra500.fuelSystem.initUI();
extra500.flapSystem.initUI();
extra500.engine.initUI();
extra500.gearSystem.initUI();

extra500.audioPanel.initUI();
extra500.keypad.initUI();
extra500.autopilot.initUI();
extra500.dme.initUI();
extra500.fuelFlow.initUI();
extra500.turnCoordinator.initUI();
extra500.stbyAirspeed.initUI();
extra500.stbyAltimeter.initUI();
extra500.stbyAttitude.initUI();
	
initUI();



#UI.echo();