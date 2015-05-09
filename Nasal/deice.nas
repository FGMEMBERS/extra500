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
#      Date: Jul 03 2013
#
#      Last change:      Dirk Dittmann
#      Date:             07.04.15
#

# MM page 
# 585	Static pitot stall
# 586	Intake
# 587	Windshield
# 588	Boots
# 619 	Propeller Heat 




var AirHeatClass = {
	new : func(root,name,watt){
		var m = { 
			parents : [
				AirHeatClass, 
				ServiceClass.new(root,name)
			]
		};
		m._state		= 0 ;	# bool
		m._nState		= m._nRoot.initNode("state",m._state,"BOOL");
		m._watt			= watt;	# watt
		m._nWatt		= m._nRoot.initNode("watt",m._watt,"DOUBLE");
		
		return m;
	},
	init : func(instance=nil){
		if (instance==nil){instance=me;}
		me.parents[1].init(instance);
	},
	setOn : func(value){
		me._state = value;
		me._nState.setValue(me._state);
	},
	heatPower : func(){
		return me._watt * me._state;
	},
	
};



var ElectricHeatClass = {
	new : func(root,name,watt){
		var m = { 
			parents : [
				ElectricHeatClass, 
				ConsumerClass.new(root,name,watt)
			]
		};
		m._resistor = 28*28 / watt;
		m._value = 0;
		return m;
	},
	init : func(instance=nil){
		if (instance==nil){instance=me;}
		me.parents[1].init(instance);
	},
	electricWork : func(){
		if ((me._value == 1 ) and (me._volt >= me._voltMin) ){
			#me._ampere 	= me._watt / me._volt;
			me._ampere 	= me._volt / me._resistor;
			me._watt 	= me._volt * me._ampere;
			me._state  = 1;
		}else{
			me._state  = 0;
			me._ampere = 0;
		}
		
		me._nState.setValue(me._state);
		me._nAmpere.setValue(me._ampere);
		me._nWatt.setValue(me._watt);
		
	},
	_onWattChange : func(){},
	setOn : func(value){
		me._value = value;
		me.electricWork();
	},
	heatPower : func(){
		return me._watt * me._state;
	},
	
	
};

#var BootsClass = {
#	new : func(root,name,watt){
#		var m = { 
#			parents : [
#				BootsClass, 
#				ConsumerClass.new(root,name,watt)
#			]
#		};
#		m._PneumaticPressure	= 1.0;
#		m._nPneumaticPressure 	= m._nRoot.initNode("PneumaticPressure",m._PneumaticPressure,"DOUBLE");
#		m._nPneumaticLow	= m._nRoot.initNode("PneumaticLow",0,"BOOL");
#		m._nBootsPosition	= m._nRoot.initNode("position-norm",0.0,"DOUBLE");
#		m._value = 0;
		
#		return m;
#	},
#	init : func(instance=nil){
#		if (instance==nil){instance=me;}
#		me.parents[1].init(instance);
#		me.setListeners(instance);
#	},
#	setListeners : func(instance){
#		append(me._listeners, setlistener(me._nPneumaticPressure,func(n){instance._onPneumaticPressureChange(n);},1,0) );
		
#	},
#	electricWork : func(){
		
#		if ((me._value == 1 ) and (me._volt >= me._voltMin) ){
#			me._ampere = me._watt / me._volt;
#			me._state  = 1;
#		}else{
#			me._state  = 0;
#			me._ampere = 0;
#		}
#		interpolate(me._nBootsPosition,me._PneumaticPressure * me._state,10.0);
#		me._nState.setValue(me._state);
#		me._nAmpere.setValue(me._ampere);
#	},
#	_onPneumaticPressureChange : func(n){
#		me._PneumaticPressure = n.getValue();	
#		if(me._PneumaticPressure <= 0.5){
#			me._nPneumaticLow.setValue(1);
#		}else{
#			me._nPneumaticLow.setValue(0);
#		}
#	},
#	setOn : func(value){
#		me._value = value;
#		me.electricWork();
#	}
#};

var DeicingSystemClass = {
	new : func(root,name){
		var m = { 
			parents : [
				DeicingSystemClass, 
				ServiceClass.new(root,name)
			]
		};
		
		
		m._nWowNose 	= props.globals.initNode("/gear/gear[0]/wow",0,"BOOL");
		m._nIAT 	= props.globals.initNode("/environment/temperature-degc",0.0,"DOUBLE");
		
		m._nTemperature = props.globals.initNode("/environment/temperature-degc",0.0,"DOUBLE");
		m._nHumidity 	= props.globals.initNode("/environment/relative-humidity",0.0,"DOUBLE");
		m._nDewpoint 	= props.globals.initNode("/environment/dewpoint-degc",0.0,"DOUBLE");
		m._nVisibility 	= props.globals.initNode("/environment/visibility-m",0.0,"DOUBLE");
		m._nRain 	= props.globals.initNode("/environment/rain-norm",0.0,"DOUBLE");
		
		m._temperature	= 0;
		m._humidity	= 0;
		m._dewpoint	= 0;
		m._visibility	= 0;
		m._rain	= 0;
		
		m._defrost 	= 0;
		m._intakeHeat	= 0;
		
		m._WindshieldCtrlTemperaturSwitch = 0;
		if (cabin._windShieldHeated._temperature > 50.0){
			m._WindshieldCtrlTemperaturSwitch = 0;
		}elsif (cabin._windShieldHeated._temperature < 40.0){
			m._WindshieldCtrlTemperaturSwitch = 1;
		}
		
		m._nIceWarning	= m._nRoot.initNode("iceWarning",0,"BOOL");
		
		
		m._nIntakeHeat 		= ElectricHeatClass.new("/extra500/system/deice/IntakeHeat","Intake Heat",30.0);
		eSystem.circuitBreaker.INTAKE_AI.outputAdd(m._nIntakeHeat);
# FIXME: intake heat uses power when OFF and none when ON
		
		m._WindshieldHeatFail		= m._nRoot.initNode("WindshieldHeat/Fail",0,"BOOL");
		m._WindshieldHeat 		= ElectricHeatClass.new("/extra500/system/deice/WindshieldHeat","Windshield Heat",473.0);
		
		eSystem.circuitBreaker.WSH_HT.outputAdd(m._WindshieldHeat);
		
		m._WindshieldCtrl 		= ConsumerClass.new("/extra500/system/deice/WindshieldCtrl","Windshield Control",1.0);
		eSystem.circuitBreaker.WSH_CTRL.outputAdd(m._WindshieldCtrl);
		
		m._PitotHeatLeft 		= ElectricHeatClass.new("/extra500/system/deice/PitotHeatLeft","Pitot Heat Left",112.0);
		eSystem.circuitBreaker.PITOT_L.outputAdd(m._PitotHeatLeft);
		
		m._PitotHeatRight 		= ElectricHeatClass.new("/extra500/system/deice/PitotHeatRight","Pitot Heat Right",112.0);
		eSystem.circuitBreaker.PITOT_R.outputAdd(m._PitotHeatRight);
		
		m._StaticHeatLeft 		= ElectricHeatClass.new("/extra500/system/deice/StaticHeatLeft","Static Heat Left",17.0);
		eSystem.circuitBreaker.PITOT_L.outputAdd(m._StaticHeatLeft);
		
		m._StaticHeatRight 		= ElectricHeatClass.new("/extra500/system/deice/StaticHeatRight","Static Heat Right",17.0);
		eSystem.circuitBreaker.PITOT_R.outputAdd(m._StaticHeatRight);
		
		m._StallHeat 		= ElectricHeatClass.new("/extra500/system/deice/StallHeat","Stall Heat",140.0);
		eSystem.circuitBreaker.PITOT_R.outputAdd(m._StallHeat);
		
		m._WindshieldDefrost		= AirHeatClass.new("/extra500/system/deice/WindshieldDeforst","Windshield Deforst",450.0);
		
# this does not include the ejector valves (6 sec 14W, 6sec 14W, 48s 0W): added in /systems/extra500-electrical-system.xml
#		m._Boots 		= BootsClass.new("/extra500/system/deice/Boots","Boots",0.4);
#		eSystem.circuitBreaker.BOOTS.outputAdd(m._Boots);
#		m._bootsTimer = 0;
		
# uhm, below some other calc is made? 
		m._PropellerHeat 	= ElectricHeatClass.new("/extra500/system/deice/Propeller","Propeller Heat",450.0);
		eSystem.circuitBreaker.PROP_HT.outputAdd(m._PropellerHeat);
		
		m._StallWarner 		= ElectricHeatClass.new("/extra500/system/pitot/StallWarn","Stall Warner",0.4);
		eSystem.circuitBreaker.STALL_WARN.outputAdd(m._StallWarner);
		
		
		
		m._dt = 0;
		m._now = systime();
		m._lastTime = m._now;
		m._timerLoop = nil;
		
		return m;
	},
	setListeners : func(instance) {
		append(me._listeners, setlistener(me._WindshieldCtrl._nState,func(n){instance._checkWindshieldHeat();},1,0) );
		append(me._listeners, setlistener(me._nWowNose,func(n){instance._checkPitot();},1,0) );
		append(me._listeners, setlistener("/fdm/jsbsim/aircraft/stallwarner/state",func(n){instance._onStallWarning(n);},1,0) );
		append(me._listeners, setlistener(eSystem.circuitBreaker.PROP_HT._nVoltOut,func(n){instance.update();},1,0) );
		
	},
	init : func(instance=nil){
		if (instance==nil){instance=me;}
		me.parents[1].init(instance);
		me.setListeners(instance);
		
				
		me._nIntakeHeat.init();
		me._WindshieldHeat.init();
		me._WindshieldDefrost.init();
		me._WindshieldCtrl.init();
		me._PitotHeatLeft.init();
		me._PitotHeatRight.init();
		me._StaticHeatLeft.init();
		me._StaticHeatRight.init();
		me._StallHeat.init();
#		me._Boots.init();
		me._PropellerHeat.init();
		me._StallWarner.init();
		
		eSystem.switch.Propeller.onStateChange = func(n){
			me._state = n.getValue();
			deiceSystem._PropellerHeat.setOn(me._state);
			deiceSystem.update();
		};
		
		eSystem.switch.PitotL.onStateChange = func(n){
			me._state = n.getValue();
			deiceSystem._checkPitot();
		};

		eSystem.switch.PitotR.onStateChange = func(n){
			me._state = n.getValue();
			deiceSystem._checkPitot();
		};

		eSystem.switch.Windshield.onStateChange = func(n){
			me._state = n.getValue();
			deiceSystem._checkWindshieldHeatFail();
			deiceSystem._checkWindshieldHeat(me._state);
			
		};

		me._WindshieldCtrl._onStateChange = func(n){
			#print("DeicingSystemClass::_WindshieldCtrl::_onStateChange ... ");
			me._state = n.getValue();
			deiceSystem._checkWindshieldHeatFail();	
			deiceSystem._checkWindshieldHeat();	
		};
		
		me._WindshieldHeat._onStateChange = func(n){
			#print("DeicingSystemClass::_WindshieldHeat::_onStateChange ... ");
			me._state = n.getValue();
			deiceSystem._checkWindshieldHeatFail();	
			deiceSystem._checkWindshieldHeat();
		};
		
#		eSystem.switch.Boots.onStateChange = func(n){
#			me._state = n.getValue();
#			deiceSystem._Boots.setOn(me._state);
#			deiceSystem._bootsTimer = 60.0;
#			deiceSystem.update();
#		};

# 		eSystem.switch.Propeller.onStateChange(eSystem.switch.Propeller._nState);
# 		eSystem.switch.PitotL.onStateChange(eSystem.switch.PitotL._nState);
# 		eSystem.switch.PitotR.onStateChange(eSystem.switch.PitotR._nState);
# 		eSystem.switch.Windshield.onStateChange(eSystem.switch.Windshield._nState);
		me._PropellerHeat._nWatt.setValue(456);
		deiceSystem.update();
		me._timerLoop = maketimer(1.0,me,DeicingSystemClass.update);
		me._timerLoop.start();
	},
	_onStallWarning : func(n){
# 		var warning = n.getBoolValue();
# 		print("We have a Stall Warning. "~warning);
		me._StallWarner.setOn(n.getBoolValue());
	},
	_checkWindshieldHeatFail : func(){
		#print("DeicingSystemClass::_checkWindshieldHeatFail ... ");
		var fail = (me._WindshieldCtrl._state == 1) 
				and (eSystem.switch.Windshield._state == 1)
				and ((cabin._windShieldHeated._temperature >= 50.0) or (me._WindshieldHeat._volt <= 0.0));
				
		me._WindshieldHeatFail.setValue(fail);
		
	},
	_checkWindshieldHeat : func(state=nil){
		
		
		if (state==1){
			me._WindshieldCtrlTemperaturSwitch = 1;
		}
		
		if (cabin._windShieldHeated._temperature > 40.0){
			me._WindshieldCtrlTemperaturSwitch = 0;
		}elsif (cabin._windShieldHeated._temperature < 20.0){
			me._WindshieldCtrlTemperaturSwitch = 1;
		}
		
		if (	eSystem.switch.Windshield._state 
			and me._WindshieldCtrl._state 
			and me._WindshieldCtrlTemperaturSwitch)
		{			
			me._WindshieldHeat.setOn(1);
		}else{
			me._WindshieldHeat.setOn(0);
		}
						
		
			
		if (cabin._windShield._temperature > 20.0){
			me._defrostValve = 1.0 - ((cabin._windShield._temperature - 20.0) / 35.0);
		}else{
			me._defrostValve = 1.0 ;
		}
		
		me._WindshieldDefrost._watt = 450.0 * me._defrostValve ;
		
		if (engine.nIsRunning.getValue() and centerConsole._Defrost ){
			me._WindshieldDefrost.setOn(1);
		}else{
			me._WindshieldDefrost.setOn(0);
		}
						
	},
	_checkPitot : func(){
		
		if (eSystem.switch.PitotL._state == 1){
			me._PitotHeatLeft.setOn( !me._nWowNose.getValue() );
			me._StaticHeatLeft.setOn( !me._nWowNose.getValue() );
		}elsif (eSystem.switch.PitotL._state == 0){
			me._PitotHeatLeft.setOn(0);
			me._StaticHeatLeft.setOn(0);
		}elsif (eSystem.switch.PitotL._state == -1){
			me._PitotHeatLeft.setOn(1);
			me._StaticHeatLeft.setOn(1);
		}
				
		if (eSystem.switch.PitotR._state == 1){
			me._PitotHeatRight.setOn( !me._nWowNose.getValue() );
			me._StaticHeatRight.setOn( !me._nWowNose.getValue() );
			me._StallHeat.setOn( !me._nWowNose.getValue() );
			
		}elsif (eSystem.switch.PitotR._state == 0){
			me._PitotHeatRight.setOn(0);
			me._StaticHeatRight.setOn(0);
			me._StallHeat.setOn(0);
			
		}elsif (eSystem.switch.PitotR._state == -1){
			me._PitotHeatRight.setOn(1);
			me._StaticHeatRight.setOn(1);
			me._StallHeat.setOn(1);
		}
	},
	setIntakeHeat : func(value){
		me._intakeHeat  = value;
		me._nIntakeHeat.setOn(me._intakeHeat);
	},
	_checkPropellerHeat : func(){
		# Propeller heat
		# RPM		A	Watt
		# 0		16	384
		# 2030		19	456
		# 0.03546x + 16
		
		#FIXME: RPM is not updated and also not when aircraft is switched on.		
		if (eSystem.switch.Propeller._state == 1){
			var watt = 0;
			var volt = 0;
			var norm = 0;
			var amp  = 0;
			volt = eSystem.circuitBreaker.PROP_HT._nVoltOut.getValue();
# 			watt =( ( getprop("/engines/engine/rpm") * 0.03547) + 384 ) / 24 * volt;
			norm = global.clamp(getprop("/engines/engine/rpm")/2030,0,0.5) + global.clamp((- 0.05*me._temperature)+0.5,0,0.5) ;
# 			var watt = 456/24* volt;
			amp = 15 + 6 * norm;
# 			watt = 384 + 72 * norm;
# 			watt = watt / 24 * volt;
			watt = amp * volt;
			watt = global.clamp(watt,384,600);
			interpolate(me._PropellerHeat._nWatt,watt,me._dt);
# 			me._PropellerHeat._nWatt.setValue(watt);
		}
	},
	_checkBoots : func(){
			#Boots
	# boots timer implemented in systems/extra500-pneumatic.xml: pls remove!	
#		if (eSystem.switch.Boots._state == 1){
#			if (me._bootsTimer <= 0.0){
#				me._Boots.setOn( (!me._Boots._state) );
#				me._bootsTimer = 60.0;
#			}
#			me._bootsTimer -= me._dt;
#		}
	},
	update : func(){
		me._now 	= systime();
		me._dt 		= me._now - me._lastTime;
		me._lastTime	= me._now;
		
		me._checkWindshieldHeatFail();
		me._checkWindshieldHeat();
		
		var  energyWindShield 		=  me._WindshieldDefrost.heatPower();# W
		
		var  energyWindShieldHeated 	= me._WindshieldHeat.heatPower() + (energyWindShield*(0.063) * (0.1));# W
		
		energyWindShield *= (0.937) * (0.1);
		
# 		cabin._windShield.addWatt(me._WindshieldDefrost.heatPower()*(0.937),me._dt);
# 		
# 		cabin._windShieldHeated.addWatt(me._WindshieldDefrost.heatPower()*(0.063),me._dt); #  mass part of cabin._windShield
# 		cabin._windShieldHeated.addWatt(me._WindshieldHeat.heatPower(),me._dt);
# 		
		cabin._windShield.addWatt( energyWindShield ,me._dt);
		cabin._windShieldHeated.addWatt( energyWindShieldHeated ,me._dt);
		
		#print("deice| ",sprintf("windshield %0.3f W %0.3f W",energyWindShield,energyWindShieldHeated));
		
		
		me._checkPropellerHeat();
		me._checkBoots();
		
		environment.update(me._dt);
	}
};

var deiceSystem = DeicingSystemClass.new("/extra500/system/deice","Deice System");
