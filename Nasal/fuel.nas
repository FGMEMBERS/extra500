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


var FLOW_JETPUMP	= 0.503 / 60.0;		# 0.503 Gal/min
var FLOW_COl2MAIN	= 1.585 / 3600.0;	# 6 L/Std
var FLOW_MAIN2COL	= FLOW_JETPUMP * 4;

var FuelTankClass = {
	new : func(name,nr){
		var m = {parents:[
			FuelTankClass,
		]};
		m._name = name;
		
		m._nTank 	= props.globals.getNode("/consumables/fuel/tank["~nr~"]",1);
		m._nLevel 	= m._nTank.getNode("level-gal_us",1);
		m._nCapacity 	= m._nTank.getNode("capacity-gal_us",1);
		
		m._level	= m._nLevel.getValue();
		m._capacity	= m._nCapacity.getValue();
		m._fraction	= m._level / m._capacity;
		
		return m;
	},
	load : func(){
		me._level	= me._nLevel.getValue();
		me._fraction	= me._level / me._capacity;	
	},
	save : func(dt){
		me._nLevel.setValue(me._level);
		#interpolate(me._nLevel,me._level,dt);
	},
	setFull : func() {
		me._level = me._capacity;
	},
	flow : func(amount){
		if (me._level >= amount){
			me._level -= amount;
			amount = 0;
		}else{
			amount -= me._level;
			me._level = 0;
		}
		return amount;
	},
	get : func(amount){
		#print(sprintf("%s get\t %.4f\t %.4f",me._name,amount,me._level));
		if (amount > me._level){
			amount 	= me._level;
		}
		me._level 	-= amount;
		return amount;
	},
	add : func(amount){
		#print(sprintf("%s add\t %.4f\t %.4f",me._name,amount,me._level));
		if (me._level + amount > me._capacity){
			amount -= me._capacity - me._level;
			me._level = me._capacity;
		}else{
			me._level += amount;
			amount = 0;
		}
		return amount;
	},
	gravity : func(amount,target){
		if (me._fraction > target._fraction){
			amount = amount * (me._fraction - target._fraction);
			amount = me.get(amount);
			amount = target.add(amount);
			me._level += amount;
		}
	},
	pump : func(amount,target){
		#print(sprintf("%s pump\t %.4f\t %.4f",me._name,amount,me._level));
		amount = me.get(amount);
		amount = target.add(amount);
		me._level += amount;
		
	},
	

	
};

var FuelPumpClass = {
	new : func(root,name,watt=30.0){
		var m = { 
			parents : [
				FuelPumpClass,
				ConsumerClass.new(root,name,watt)
			]
		};
		m._on = 0;
		return m;
	},
	electricWork : func(){
		me._watt = me._nWatt.getValue();
		if((me._on  == 1) and (me._volt > 22.0) ){
			me._ampere = me._watt / me._volt;
			me._state  = 1;
		}else{
			me._ampere = 0;
			me._state  = 0;
		}
		me._nState.setValue(me._state);
		me._nAmpere.setValue(me._ampere);
	},
	
	setState : func(value){
		me._on = value;
		me.electricWork();
	},
	
	
};
var FuelSystemClass = {
	new : func(root,name){
		var m = {parents:[
			FuelSystemClass,
			ServiceClass.new(root,name)
		]};
		m._listeners		=[];
		m._nFuelFlow		= props.globals.initNode("/fdm/jsbsim/aircraft/engine/FF-lbs_h");
		m._nFuelFlowGalUSpSec	= m._nRoot.initNode("FuelFlow-gal_us_sec",0.0,"DOUBLE");
		
		m._nFuelFilterByPass	= m._nRoot.initNode("FuelFilterByPass",0,"BOOL");
		m._nFuelLowLeft		= m._nRoot.initNode("FuelLowLeft",0,"BOOL");
		m._nFuelLowRight	= m._nRoot.initNode("FuelLowRight",0,"BOOL");
		m._nSelectValve		= m._nRoot.initNode("SelectValve",2,"INT");
		m._nFuelEmpty		= m._nRoot.initNode("isEmpty",0,"BOOL");
		#m._nFuelPump1		= m._nRoot.initNode("FuelPump1/state",0,"BOOL");
		m._nFuelPump2		= m._nRoot.initNode("FuelPump2/state",0,"BOOL");
		
		m._FuelPump1		= FuelPumpClass.new("extra500/system/fuel/FuelPump1","Fuel Pump 1",30.0);
		m._FuelPump2		= FuelPumpClass.new("extra500/system/fuel/FuelPump2","Fuel Pump 2",30.0);
		m._FuelTransLeft	= FuelPumpClass.new("extra500/system/fuel/FuelPumpTransLeft","Fuel Transfer Pump Left",30.0);
		m._FuelTransRight	= FuelPumpClass.new("extra500/system/fuel/FuelPumpTransRight","Fuel Transfer Pump Right",30.0);
		
		m._FuelPump1.setListerners();
		m._FuelPump2.setListerners();
		m._FuelTransLeft.setListerners();
		m._FuelTransRight.setListerners();
		
		eSystem.circuitBreaker.FUEL_P_1.addOutput(m._FuelPump1);
		eSystem.circuitBreaker.FUEL_P_2.addOutput(m._FuelPump2);
		eSystem.circuitBreaker.FUEL_TR_L.addOutput(m._FuelTransLeft);
		eSystem.circuitBreaker.FUEL_TR_R.addOutput(m._FuelTransRight);
		
		
		eSystem.switch.FuelPump1.onStateChange = func(n){
			me._state = n.getValue();
			m._FuelPump1.setState(me._state);
			m.update();
		};
		eSystem.switch.FuelPump2.onStateChange = func(n){
			me._state = n.getValue();
			m._FuelPump2.setState(me._state);
			m.update();
		};
		eSystem.switch.FuelTransferLeft.onStateChange = func(n){
			me._state = n.getValue();
			m._FuelTransLeft.setState(me._state);
			m.update();
		};
		eSystem.switch.FuelTransferRight.onStateChange = func(n){
			me._state = n.getValue();
			m._FuelTransRight.setState(me._state);
			m.update();
		};
		
		
		m._TankLeftAuxiliary 	= FuelTankClass.new("LA",0);
		m._TankLeftMain 	= FuelTankClass.new("LM",1);
		m._TankLeftCollector 	= FuelTankClass.new("LC",2);
		m._TankEngine 		= FuelTankClass.new("EN",3);
		m._TankRightCollector 	= FuelTankClass.new("RC",4);
		m._TankRightMain 	= FuelTankClass.new("RM",5);
		m._TankRightAuxiliary 	= FuelTankClass.new("RA",6);
		

		
		m._fuelFlowGalUsPerSec 	= 0.0;
		m._fuelFlowAmount	= 0.0;
		m._empty		= 0;
		m._selectValve		= 0;
		m._toFlow		= 0;
				
		m.dt = 0;
		m.now = systime();
		m._lastTime = 0;
		m._timerLoop = nil;
	
		return m;
	},
	init : func(){
		me.initUI();
				
		append(me._listeners, setlistener(me._nSelectValve,func(n){me._selectValve = n.getValue();me.update();},1,0) );
		
		me._timerLoop = maketimer(1.0,me,FuelSystemClass.update);
		me._timerLoop.start();
		
	},
	onValveClick : func(value){
		me._selectValve += value;
		me._selectValve = global.clamp(me._selectValve,0,3);
		me._nSelectValve.setValue(me._selectValve);
	},	
	update : func(){
		me._now 	= systime();
		me._dt 		= me._now - me._lastTime;
		me._lastTime	= me._now;
		
		me._TankEngine.load();
		
		if (me._empty == 0){
			me._TankEngine.setFull();
			me._TankEngine.save(me._dt);
		}
		
		
		me._TankLeftAuxiliary.load();
		me._TankLeftMain.load();
		me._TankLeftCollector.load();
		me._TankRightCollector.load();
		me._TankRightMain.load();
		me._TankRightAuxiliary.load();
		
				
		
		
	# by gravity
		me._TankLeftMain.gravity(FLOW_MAIN2COL,me._TankLeftCollector);
		me._TankRightMain.gravity(FLOW_MAIN2COL,me._TankRightCollector);
		
		me._TankLeftCollector.gravity(FLOW_COl2MAIN,me._TankLeftMain);
		me._TankRightCollector.gravity(FLOW_COl2MAIN,me._TankRightMain);
		
				
	# by pump 
		if (me._FuelTransLeft._state == 1){
			#print("\nFuel Trans Left "~me._now~"\n");
			me._TankLeftAuxiliary.pump(FLOW_JETPUMP,me._TankLeftMain);
			me._TankLeftMain.pump(FLOW_JETPUMP*2,me._TankLeftCollector);
		}
		if (me._FuelTransRight._state == 1){
			#print("\nFuel Trans Right "~me._now~"\n");
			me._TankRightAuxiliary.pump(FLOW_JETPUMP,me._TankRightMain);
			me._TankRightMain.pump(FLOW_JETPUMP*2,me._TankRightCollector);
		}
		
		
	# consume by engine in dt
		
		me._fuelFlowGalUsPerSec = ( me._nFuelFlow.getValue() / global.CONST.JETA_LBGAL ) / 3600 ;
		me._nFuelFlowGalUSpSec.setValue(me._fuelFlowGalUsPerSec);
		
		me._fuelFlowAmount = me._fuelFlowGalUsPerSec * me._dt;
		
		if (me._selectValve == 0){	#none
			me._empty = 1;
		}elsif(me._selectValve == 1){ # Left
			if (me._TankLeftCollector.flow(me._fuelFlowAmount) >  0){
				me._empty = 1;
			}else{
				me._empty = 0;
			}
		}elsif(me._selectValve == 2){ # Both
			me._fuelFlowAmount /= 2;
			me._toFlow = me._fuelFlowAmount;
			
			if (me._TankLeftCollector._level > me._TankRightCollector._level){
				me._toFlow 	 = me._TankLeftCollector.flow(me._toFlow);
				me._toFlow 	+= me._fuelFlowAmount;
				me._toFlow 	 = me._TankRightCollector.flow(me._toFlow);
			}else{
				me._toFlow 	 = me._TankRightCollector.flow(me._toFlow);
				me._toFlow 	+= me._fuelFlowAmount;
				me._toFlow 	 = me._TankLeftCollector.flow(me._toFlow);
			}
			
			if (me._toFlow >  0){
				me._empty = 1;
			}else{
				me._empty = 0;
			}
			
			
		}elsif(me._selectValve == 3){ #Right
			if (me._TankRightCollector.flow(me._fuelFlowAmount) >  0){
				me._empty = 1;
			}else{
				me._empty = 0;
			}
		}
		
		
		if (me._TankLeftCollector._fraction <= 0.68){
			me._nFuelLowLeft.setValue(1);
		}else{
			me._nFuelLowLeft.setValue(0);
		}
		if (me._TankRightCollector._fraction <= 0.68){
			me._nFuelLowRight.setValue(1);
		}else{
			me._nFuelLowRight.setValue(0);
		}
		
		
		
		
		me._nFuelEmpty.setValue(me._empty);
		
		me._TankLeftAuxiliary.save(me._dt);
		me._TankLeftMain.save(me._dt);
		me._TankLeftCollector.save(me._dt);
		me._TankRightCollector.save(me._dt);
		me._TankRightMain.save(me._dt);
		me._TankRightAuxiliary.save(me._dt);

		
		
		
		
	},
	initUI : func(){
		UI.register("Fuel Select Valve <", 	func{me.onValveClick(-1);} 	);
		UI.register("Fuel Select Valve >", 	func{me.onValveClick(1);} 	);
	},
	
};

var fuelSystem= FuelSystemClass.new("extra500/system/fuel","Fuel System");