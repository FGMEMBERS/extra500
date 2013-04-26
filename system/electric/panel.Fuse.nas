#    This file is part of extra500
#
#    The Changer is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 2 of the License, or
#    (at your option) any later version.
#
#    The Changer is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with extra500.  If not, see <http://www.gnu.org/licenses/>.
#
#      Authors: Dirk Dittmann
#      Date: April 12 2013
#
#      Last change:      Dirk Dittmann
#      Date:             26.04.13
#

var FusePanel = {
	new : func{
		var m = {parents:[
			FusePanel
		]};
		m.nRoot = props.globals.getNode("extra500/FusePanel",1);
		
		var node = m.nRoot.initNode("BatteryBus");
		m.batteryBus = Part.ElectricCircuitBraker.new(node,"BatteryBus Fuse",1);
		m.batteryBus.fuseConfig(150.0);
		
		var node = m.nRoot.initNode("LoadBus");
		m.loadBus = Part.ElectricCircuitBraker.new(node,"LoadBus Fuse",1);
		m.loadBus.fuseConfig(150.0);
		
		var node = m.nRoot.initNode("EmergencyBus");
		m.emergencyBus = Part.ElectricCircuitBraker.new(node,"EmergencyBus Fuse",1);
		m.emergencyBus.fuseConfig(40.0);
		
		var node = m.nRoot.initNode("Emergency3");
		m.emergency3 = Part.ElectricCircuitBraker.new(node,"Emergency3 Fuse",1);
		m.emergency3.fuseConfig(35.0);
		
		return m;
		
	},
};

var fusePanel = FusePanel.new();
		