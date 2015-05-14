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
#	Last change:	Dirk Dittmann
#	Date:		10.05.15
#

# MM page 
# 585	Static pitot stall
# 586	Intake
# 587	Windshield
# 588	Boots
# 619 	Propeller Heat 

var HeatClass = {
	new : func(root,name,watt){
		var m = { 
			parents : [
				HeatClass, 
				ConsumerClass.new(root,name,watt)
			]
		};
		m._resistor = 28*28 / watt;
		m._nResistor	= m._nRoot.initNode("resistor",m._resistor,"DOUBLE");
		
		m._value = 0;
		return m;
	},
	init : func(instance=nil){
		if (instance==nil){instance=me;}
		me.parents[1].init(instance);
		append(me._listeners, setlistener(me._nResistor,func(n){instance._onResitorChange(n);},1,0) );
		
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
	_onResitorChange : func(n){
		#print("HeatClass::_onResitorChange() ...");
		me._resistor = n.getValue();
		me.electricWork();
	},
	setOn : func(value){
		me._value = value;
		me.electricWork();
	}
	
	
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
				ServiceClass.new(root,name),
				SubSystemClass.new()
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
		
		
		
		m._nIceWarning	= m._nRoot.initNode("iceWarning",0,"BOOL");
		
		
		m._nIntakeHeat 		= HeatClass.new("/extra500/system/deice/IntakeHeat","Intake Heat",30.0);
		eSystem.circuitBreaker.INTAKE_AI.outputAdd(m._nIntakeHeat);
# FIXME: intake heat uses power when OFF and none when ON
		
		m._WindshieldHeatFail		= m._nRoot.initNode("WindshieldHeat/Fail",0,"BOOL");
		m._WindshieldHeat 		= HeatClass.new("/extra500/system/deice/WindshieldHeat","Windshield Heat",473.0);
		eSystem.circuitBreaker.WSH_HT.outputAdd(m._WindshieldHeat);
		
		m._WindshieldCtrl 		= ConsumerClass.new("/extra500/system/deice/WindshieldCtrl","Windshield Control",1.0);
		eSystem.circuitBreaker.WSH_CTRL.outputAdd(m._WindshieldCtrl);
		
		m._PitotHeatLeft 		= HeatClass.new("/extra500/system/deice/PitotHeatLeft","Pitot Heat Left",112.0);
		eSystem.circuitBreaker.PITOT_L.outputAdd(m._PitotHeatLeft);
		
		m._PitotHeatRight 		= HeatClass.new("/extra500/system/deice/PitotHeatRight","Pitot Heat Right",112.0);
		eSystem.circuitBreaker.PITOT_R.outputAdd(m._PitotHeatRight);
		
		m._StaticHeatLeft 		= HeatClass.new("/extra500/system/deice/StaticHeatLeft","Static Heat Left",17.0);
		eSystem.circuitBreaker.PITOT_L.outputAdd(m._StaticHeatLeft);
		
		m._StaticHeatRight 		= HeatClass.new("/extra500/system/deice/StaticHeatRight","Static Heat Right",17.0);
		eSystem.circuitBreaker.PITOT_R.outputAdd(m._StaticHeatRight);
		
		m._StallHeat 		= HeatClass.new("/extra500/system/deice/StallHeat","Stall Heat",140.0);
		eSystem.circuitBreaker.PITOT_R.outputAdd(m._StallHeat);
		
# this does not include the ejector valves (6 sec 14W, 6sec 14W, 48s 0W): added in /systems/extra500-electrical-system.xml
#		m._Boots 		= BootsClass.new("/extra500/system/deice/Boots","Boots",0.4);
#		eSystem.circuitBreaker.BOOTS.outputAdd(m._Boots);
#		m._bootsTimer = 0;
		
# uhm, below some other calc is made? 
		m._PropellerHeat 	= HeatClass.new("/extra500/system/deice/Propeller","Propeller Heat",450.0);
		eSystem.circuitBreaker.PROP_HT.outputAdd(m._PropellerHeat);
		
		m._StallWarner 		= HeatClass.new("/extra500/system/pitot/StallWarn","Stall Warner",0.4);
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
		#me._timerLoop = maketimer(5.0,me,DeicingSystemClass.update);
		#me._timerLoop.start();
		
		me.__initSubSystem(me);
		subSystemManager2Hz.register(me);
	},
	_onStallWarning : func(n){
# 		var warning = n.getBoolValue();
# 		print("We have a Stall Warning. "~warning);
		me._StallWarner.setOn(n.getBoolValue());
	},
	_checkWindshieldHeat : func(){
		me._WindshieldHeat.setOn(eSystem.switch.Windshield._state * me._WindshieldCtrl._state);
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
	_checkIce : func(dt){
		me._temperature = me._nTemperature.getValue();
		me._humidity	= me._nHumidity.getValue();
		#me._dewpoint	= me._nDewpoint.getValue();
		#me._visibility	= me._nVisibility.getValue();
		#me._rain	= me._nRain.getValue();
		
		if ( (me._humidity >= 100) and (me._temperature <= 0)){
			me._nIceWarning.setValue(1);
		}else{
			me._nIceWarning.setValue(0);
		}
		
	},
	update : func(){
		me._now 	= systime();
		me._dt 		= me._now - me._lastTime;
		me._lastTime	= me._now;
		
		
		me._checkIce(me._dt);
		
		if (eSystem.switch.Propeller._state == 1){
			
			# resistor min 1.3 max 1.742
			var resistor = 1.742;
			var rate = 0;
			
			rate += global.norm(getprop("/engines/engine/rpm"),0,2030) * -0.025;
			rate += global.norm(me._temperature,0,-50) * -0.375;
			
			rate = global.clamp(rate,-0.4,0.4);
			
			resistor += 1.742 * rate;
			
# 			print(sprintf("DeicingSystemClass::update() rate: %0.3f resistor: %0.03f"
# 				,rate
# 				,resistor
# 			));
			
			resistor = global.clamp(resistor,1.3,1.742);
						
			me._PropellerHeat._resistor = resistor;
			me._PropellerHeat.electricWork();
						
		}
		
		
	}
};

var deiceSystem = DeicingSystemClass.new("/extra500/system/deice","Deice System");
