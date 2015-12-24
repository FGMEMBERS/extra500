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
#      Date:             24.12.15
#

var FuelSystemClass = {
	new : func(root,name){
		var m = {parents:[
			FuelSystemClass,
			ServiceClass.new(root,name)
		]};
		m._listeners		=[];
		m._nSelectValve		= m._nRoot.initNode("SelectValve",2,"INT");
	
		return m;
	},
	init : func(instance=nil){
		if (instance==nil){instance=me;}
		me.parents[1].init(instance);
		me.initUI();
		me.initBal();
		me.setFlowBalance();
			
		append(me._listeners, setlistener(me._nSelectValve,func(n){me._selectValve = n.getValue();},1,0) );		
	},

	initBal : func(){
		var LmainCap = getprop("/consumables/fuel/tank[1]/capacity-gal_us");
		var Lmainfrac = getprop("/consumables/fuel/tank[1]/level-norm");
		var LcollCap = getprop("/consumables/fuel/tank[2]/capacity-gal_us");
		var Lcollfrac = getprop("/consumables/fuel/tank[2]/level-norm");

		var fracL = (LmainCap*Lmainfrac + LcollCap*Lcollfrac) / (LmainCap + LcollCap);
		setprop("/consumables/fuel/tank[1]/level-norm",fracL);
		setprop("/consumables/fuel/tank[2]/level-norm",fracL);

		var RmainCap = getprop("/consumables/fuel/tank[5]/capacity-gal_us");
		var Rmainfrac = getprop("/consumables/fuel/tank[5]/level-norm");
		var RcollCap = getprop("/consumables/fuel/tank[4]/capacity-gal_us");
		var Rcollfrac = getprop("/consumables/fuel/tank[4]/level-norm");

		var fracR = (RmainCap*Rmainfrac + RcollCap*Rcollfrac) / (RmainCap + RcollCap);
		setprop("/consumables/fuel/tank[4]/level-norm",fracR);
		setprop("/consumables/fuel/tank[5]/level-norm",fracR);
	},

	onValveClick : func(value){
		if (getprop("/systems/fuel/selectorValve/serviceable")==1){
			me._selectValve += value;
			me._selectValve = global.clamp(me._selectValve,0,4);
			me._nSelectValve.setValue(me._selectValve);
			me.setFlowBalance();
		} else {
			UI.msg.info("The Fuel Selector Valve seems to be blocked...");
		}
	},	
	onValveSet : func(value){
		if (getprop("/systems/fuel/selectorValve/serviceable")==1){
			me._selectValve = value;
			me._selectValve = global.clamp(me._selectValve,0,4);
			me._nSelectValve.setValue(me._selectValve);
			me.setFlowBalance();
		} else {
			UI.msg.info("The Fuel Selector Valve seems to be blocked...");
		}
	},	
	setFlowBalance : func(){
#	/systems/fuel/FlowbalanceLR: 1 = all fuel from left tank; 0 = all fuel from RH tank

		var valvepos = getprop("/extra500/system/fuel/SelectValve");
		var LHcheckValve = getprop("/systems/fuel/LHtank/checkvalve/serviceable");
		var RHcheckValve = getprop("/systems/fuel/RHtank/checkvalve/serviceable");

		if (valvepos == 1 ) {
			setprop("/systems/fuel/FlowbalanceLR",1);
		} else if (valvepos == 3 ) {
			setprop("/systems/fuel/FlowbalanceLR",0);
		} else {
			if (LHcheckValve == 0){
				setprop("/systems/fuel/FlowbalanceLR",0);
			} else if (RHcheckValve == 0) {
				setprop("/systems/fuel/FlowbalanceLR",1);
			} else {
				setprop("/systems/fuel/FlowbalanceLR",0.5);
			}
		}
	},
	
	initUI : func(){
		UI.register("Fuel Select Valve <", 	func{me.onValveClick(-1);} 	);
		UI.register("Fuel Select Valve >", 	func{me.onValveClick(1);} 	);
		UI.register("Fuel Select Off", 	func{me.onValveSet(0);} 	);
		UI.register("Fuel Select Left", 	func{me.onValveSet(1);} 	);
		UI.register("Fuel Select Both", 	func{me.onValveSet(2);} 	);
		UI.register("Fuel Select Right", 	func{me.onValveSet(3);} 	);
	},
	
};

var fuelSystem = FuelSystemClass.new("extra500/system/fuel","Fuel System");
