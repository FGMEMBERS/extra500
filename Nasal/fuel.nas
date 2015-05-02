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
#      Date:             03.03.14
#

# Fuel Flow Gal(US)/sec
var FLOW_JETPUMP	= 0.503 / 60.0;		# 0.503 Gal/min
var FLOW_COl2MAIN	= 1.585 / 3600.0;	# 6 L/Std
var FLOW_MAIN2COL	= FLOW_JETPUMP * 50;

var FuelTankClass = {
	new : func(position,name,index,refuelable=1){
		var m = {parents:[
			FuelTankClass,
		]};
		m._index 	= index;
		m._position 	= position;
		m._name 	= name;
		m._refuelable 	= refuelable;
		
		m._nTank 	= props.globals.getNode("/consumables/fuel/tank["~m._index~"]",1);
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
	save : func(){
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
	ballance : func(target){
		if (me._fraction != target._fraction){
			var sumLevel 	= me._level + target._level;
			var sumCap	= me._capacity + target._capacity;
			
			var fraction 	= sumLevel / sumCap;
			
			me._level	= me._capacity * fraction;
			target._level	= target._capacity * fraction;
			
		}
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
	init : func(instance=nil){
		if (instance==nil){instance=me;}
		me.parents[1].init(instance);
	},
	electricWork : func(){
		me._watt = me._nWatt.getValue();
		if((me._on  == 1) and (me._volt > me._voltMin) ){
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
		m._nFuelFlowLph		= props.globals.initNode("/fdm/jsbsim/aircraft/engine/FF-l_h");
		m._nFuelFlowGalUSpSec	= m._nRoot.initNode("FuelFlow-gal_us_sec",0.0,"DOUBLE");
		
		m._nFuelFilterByPass	= m._nRoot.initNode("FuelFilterByPass",0,"BOOL");
		m._nFuelLowLeft		= m._nRoot.initNode("FuelLowLeft",0,"BOOL");
		m._nFuelLowRight	= m._nRoot.initNode("FuelLowRight",0,"BOOL");
		m._nSelectValve		= m._nRoot.initNode("SelectValve",2,"INT");
		m._nFuelEmpty		= m._nRoot.initNode("isEmpty",0,"BOOL");
		#m._nFuelPump1		= m._nRoot.initNode("FuelPump1/state",0,"BOOL");
		m._nFuelPump2		= m._nRoot.initNode("FuelPump2/state",0,"BOOL");
		
		m._FuelPump1		= FuelPumpClass.new("extra500/system/fuel/FuelPump1","Fuel Pump 1",140.0);
		m._FuelPump2		= FuelPumpClass.new("extra500/system/fuel/FuelPump2","Fuel Pump 2",140.0);
		m._FuelTransLeft	= FuelPumpClass.new("extra500/system/fuel/FuelPumpTransLeft","Fuel Transfer Pump Left",42.0);
		m._FuelTransRight	= FuelPumpClass.new("extra500/system/fuel/FuelPumpTransRight","Fuel Transfer Pump Right",42.0);
		
		
		eSystem.circuitBreaker.FUEL_P_1.outputAdd(m._FuelPump1);
		eSystem.circuitBreaker.FUEL_P_2.outputAdd(m._FuelPump2);
		eSystem.circuitBreaker.FUEL_TR_L.outputAdd(m._FuelTransLeft);
		eSystem.circuitBreaker.FUEL_TR_R.outputAdd(m._FuelTransRight);
		
		
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
		
		m._tank = {
			LeftAuxiliary 	: FuelTankClass.new("Left","Auxiliary",0),
			LeftMain 	: FuelTankClass.new("Left","Main",1),
			LeftCollector 	: FuelTankClass.new("Left","Collector",2,0),
			Engine 		: FuelTankClass.new("Center","Engine Filter",3,0),
			RightCollector 	: FuelTankClass.new("Right","Collector",4,0),
			RightMain 	: FuelTankClass.new("Right","Main",5),
			RightAuxiliary 	: FuelTankClass.new("Right","Auxiliary",6),
		};
		
				
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
	init : func(instance=nil){
		if (instance==nil){instance=me;}
		me.parents[1].init(instance);
		me.initUI();
		
		me._FuelPump1.init();
		me._FuelPump2.init();
		me._FuelTransLeft.init();
		me._FuelTransRight.init();
			
		me.startupBallance();
		
		append(me._listeners, setlistener(me._nSelectValve,func(n){me._selectValve = n.getValue();me.update();},1,0) );
		
		me._timerLoop = maketimer(1.0,me,FuelSystemClass.update);
		me._timerLoop.start();
		
	},
	startupBallance : func(){
		me._tank.LeftMain.load();
		me._tank.LeftCollector.load();
		me._tank.RightCollector.load();
		me._tank.RightMain.load();
		
		me._tank.LeftCollector.ballance(me._tank.LeftMain);
		me._tank.RightCollector.ballance(me._tank.RightMain);
		
		me._tank.LeftMain.save();
		me._tank.LeftCollector.save();
		me._tank.RightCollector.save();
		me._tank.RightMain.save();
		
	},
	onValveClick : func(value){
		me._selectValve += value;
		me._selectValve = global.clamp(me._selectValve,0,4);
		me._nSelectValve.setValue(me._selectValve);
	},	
	onValveSet : func(value){
		me._selectValve = value;
		me._selectValve = global.clamp(me._selectValve,0,4);
		me._nSelectValve.setValue(me._selectValve);
	},	
	update : func(){
		me._now 	= systime();
		me._dt 		= me._now - me._lastTime;
		me._lastTime	= me._now;
		
		me._tank.Engine.load();
		
		if (me._empty == 0){
			me._tank.Engine.setFull();
			me._tank.Engine.save(me._dt);
		}
		
		
		me._tank.LeftAuxiliary.load();
		me._tank.LeftMain.load();
		me._tank.LeftCollector.load();
		me._tank.RightCollector.load();
		me._tank.RightMain.load();
		me._tank.RightAuxiliary.load();
		
				
		
		
	# by gravity
		me._tank.LeftMain.gravity(FLOW_MAIN2COL,me._tank.LeftCollector);
		me._tank.RightMain.gravity(FLOW_MAIN2COL,me._tank.RightCollector);
		
		me._tank.LeftCollector.gravity(FLOW_COl2MAIN,me._tank.LeftMain);
		me._tank.RightCollector.gravity(FLOW_COl2MAIN,me._tank.RightMain);
		
				
	# by pump 
		if (me._FuelTransLeft._state == 1){
			#print("\nFuel Trans Left "~me._now~"\n");
			me._tank.LeftAuxiliary.pump(FLOW_JETPUMP,me._tank.LeftMain);
			me._tank.LeftMain.pump(FLOW_JETPUMP*2,me._tank.LeftCollector);
		}
		if (me._FuelTransRight._state == 1){
			#print("\nFuel Trans Right "~me._now~"\n");
			me._tank.RightAuxiliary.pump(FLOW_JETPUMP,me._tank.RightMain);
			me._tank.RightMain.pump(FLOW_JETPUMP*2,me._tank.RightCollector);
		}
		
		
	# consume by engine in dt
		
		me._fuelFlowGalUsPerSec = ( me._nFuelFlow.getValue() / global.CONST.JETA_LBGAL ) / 3600 ;
		me._nFuelFlowGalUSpSec.setValue(me._fuelFlowGalUsPerSec);
		
		me._fuelFlowAmount = me._fuelFlowGalUsPerSec * me._dt;
		
		if ((me._selectValve == 0) or (me._selectValve == 4) or (getprop("/fdm/jsbsim/aircraft/engine/Fpress-too-low") == 1) or (getprop("/accelerations/n-z-cg-fps_sec") > 0)){	#none
			me._empty = 1;
		}elsif(me._selectValve == 1){ # Left
			if (me._tank.LeftCollector.flow(me._fuelFlowAmount) >  0){
				me._empty = 1;
			}else{
				me._empty = 0;
			}
		}elsif(me._selectValve == 2){ # Both
			me._fuelFlowAmount /= 2;
			me._toFlow = me._fuelFlowAmount;
			
			if (me._tank.LeftCollector._level > me._tank.RightCollector._level){
				me._toFlow 	 = me._tank.LeftCollector.flow(me._toFlow);
				me._toFlow 	+= me._fuelFlowAmount;
				me._toFlow 	 = me._tank.RightCollector.flow(me._toFlow);
			}else{
				me._toFlow 	 = me._tank.RightCollector.flow(me._toFlow);
				me._toFlow 	+= me._fuelFlowAmount;
				me._toFlow 	 = me._tank.LeftCollector.flow(me._toFlow);
			}
			
			if (me._toFlow >  0){
				me._empty = 1;
			}else{
				me._empty = 0;
			}
			
			
		}elsif(me._selectValve == 3){ #Right
			if (me._tank.RightCollector.flow(me._fuelFlowAmount) >  0){
				me._empty = 1;
			}else{
				me._empty = 0;
			}
		}
		
		
		if (me._tank.LeftCollector._fraction <= 0.68){
			me._nFuelLowLeft.setValue(1);
		}else{
			me._nFuelLowLeft.setValue(0);
		}
		if (me._tank.RightCollector._fraction <= 0.68){
			me._nFuelLowRight.setValue(1);
		}else{
			me._nFuelLowRight.setValue(0);
		}
		
		
		
		
		me._nFuelEmpty.setValue(me._empty);
		
		me._tank.LeftAuxiliary.save();
		me._tank.LeftMain.save();
		me._tank.LeftCollector.save();
		me._tank.RightCollector.save();
		me._tank.RightMain.save();
		me._tank.RightAuxiliary.save();

		
		
		
		
	},
	initUI : func(){
		UI.register("Fuel Select Valve <", 	func{me.onValveClick(-1);} 	);
		UI.register("Fuel Select Valve >", 	func{me.onValveClick(1);} 	);
		UI.register("Fuel Select Off", 		func{me.onValveSet(0);} 	);
		UI.register("Fuel Select Left", 	func{me.onValveSet(1);} 	);
		UI.register("Fuel Select Both", 	func{me.onValveSet(2);} 	);
		UI.register("Fuel Select Right", 	func{me.onValveSet(4);} 	);
	},
	
};

var fuelSystem= FuelSystemClass.new("extra500/system/fuel","Fuel System");
