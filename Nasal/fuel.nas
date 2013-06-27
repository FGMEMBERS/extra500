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


var FuelSystemClass = {
	new : func(root,name){
		var m = {parents:[
			FuelSystemClass,
			ServiceClass.new(root,name)
		]};
		
		m.nFuelPump1		= m._nRoot.initNode("FuelPump1/state",0,"BOOL");
		m.nFuelPump2		= m._nRoot.initNode("FuelPump2/state",0,"BOOL");
		
		
		m.nTankLeftAuxiliary 	= props.globals.getNode("/consumables/fuel/tank[0]",1);
		m.nTankLeftMain 	= props.globals.getNode("/consumables/fuel/tank[1]",1);
		m.nTankLeftCollector 	= props.globals.getNode("/consumables/fuel/tank[2]",1);
		m.nTankEngine 		= props.globals.getNode("/consumables/fuel/tank[3]",1);
		m.nTankRightCollector 	= props.globals.getNode("/consumables/fuel/tank[4]",1);
		m.nTankRightMain 	= props.globals.getNode("/consumables/fuel/tank[5]",1);
		m.nTankRightAuxiliary 	= props.globals.getNode("/consumables/fuel/tank[6]",1);
		
		m.nLevelLeftAuxiliary 	= m.nTankLeftAuxiliary.getNode("level-gal_us",1);
		m.nLevelLeftMain 	= m.nTankLeftMain.getNode("level-gal_us",1);
		m.nLevelLeftCollector 	= m.nTankLeftCollector.getNode("level-gal_us",1);
		m.nLevelEngine 		= m.nTankEngine.getNode("level-gal_us",1);
		m.nLevelRightCollector 	= m.nTankRightCollector.getNode("level-gal_us",1);
		m.nLevelRightMain 	= m.nTankRightMain.getNode("level-gal_us",1);
		m.nLevelRightAuxiliary 	= m.nTankRightAuxiliary.getNode("level-gal_us",1);
		
		
		
		m.capLeftAuxiliary 	= m.nTankLeftAuxiliary.getNode("capacity-gal_us",1).getValue();
		m.capLeftMain 		= m.nTankLeftMain.getNode("capacity-gal_us",1).getValue();
		m.capLeftCollector 	= m.nTankLeftCollector.getNode("capacity-gal_us",1).getValue();
		m.capEngine 		= m.nTankEngine.getNode("capacity-gal_us",1).getValue();
		m.capRightCollector 	= m.nTankRightCollector.getNode("capacity-gal_us",1).getValue();
		m.capRightMain 		= m.nTankRightMain.getNode("capacity-gal_us",1).getValue();
		m.capRightAuxiliary 	= m.nTankRightAuxiliary.getNode("capacity-gal_us",1).getValue();
		
		m.levelEngine 		= m.nLevelEngine.getValue();
		m.levelLeftAuxiliary 	= m.nLevelLeftAuxiliary.getValue();
		m.levelLeftMain 	= m.nLevelLeftMain.getValue();
		m.levelLeftCollector 	= m.nLevelLeftCollector.getValue();
		m.levelRightCollector 	= m.nLevelRightCollector.getValue();
		m.levelRightMain 	= m.nLevelRightMain.getValue();
		m.levelRightAuxiliary 	= m.nLevelRightAuxiliary.getValue();
		
		m.dt = 0;
		m.now = systime();
		m._lastTime = 0;
		m.timerLoop = maketimer(1.0,m,FuelSystemClass.update);
	
		return m;
	},
	init : func(){
		
	},
	update : func(){
		me.nLevelEngine.setValue(me.capEngine);
	}
};

var fuelSystem= FuelSystemClass.new("extra500/system/fuel","Fuel System");