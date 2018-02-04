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
#      Date:             02.09.17
#


var init_listener = setlistener("/sim/signals/fdm-initialized", func {
	
	removelistener(init_listener);
	init_listener = nil;

# setting saved position of last exit of program
	var posAtLastKnownPos = getprop("extra500/exit/posAtLastKnownPos") or 0;
	if (posAtLastKnownPos==1) {
		setprop("/sim/presets/airport-id", "");
		setprop("/sim/presets/latitude-deg", getprop("/extra500/exit/latitude-deg"));
      	setprop("/sim/presets/longitude-deg", getprop("/extra500/exit/longitude-deg"));
      	setprop("/sim/presets/heading-deg", getprop("/extra500/exit/heading-deg"));

		fgcommand("reposition");
	}
	

	settimer(func(){

	
		#positioned.findWithinRange(600,"airport");
		#positioned.findWithinRange(150,"vor");
		
		#print("Extra500 init");
		extra500.eSystem.checkSource();
		
		extra500.engine.init();
		extra500.gearSystem.init();
		extra500.flapSystem.init();
		extra500.fuelSystem.init();
		extra500.autopilot.init();
		extra500.audiopanel.init();
		
		
		IFD.LH.init();
		IFD.RH.init();
		IFD.tcasModel.init();
		IFD.keypad.init(global.INIT_START);
		IFD.fms.init();
		
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
		extra500.xpdr.init();
		extra500.elt.init();
		extra500.pcBoard1.init();
		extra500.cabincontroller.init();
		extra500.cabinaltimeter.init();
		extra500.cabinclimb.init();
		extra500.dmeInd.init();
		extra500.dmeSwitch.init();
		extra500.magCompass.init();
		
		extra500.annunciator.init();
		extra500.light.init();
		extra500.centerConsole.init();
		extra500.interior.init();
		extra500.fuelFlowLog.init();
		extra500.PositionLog.init();
		
		extra500.eSystem.init();
		
		extra500.environment.init();

		extra500.perf.init();
		extra500.perfIFD.init();
		
#		extra500.weatherService.init();
#		extra500.weatherService.start();
		
#		extra500.aliasAllChildes(props.globals.getNode("environment/metar-nearest"),props.globals.getNode("/environment/metar"));
		
# 		props.globals.getNode("/environment/metar").unalias();
# 		props.globals.getNode("/environment/metar").alias(props.globals.getNode("environment/metar-nearest"));
		
	},1);

		
});

var exit_listener = setlistener("/sim/signals/exit", func {
	#print("listener.exit() ... ");
	extra500.audiopanel.restoreUserSoundVolume();

});
