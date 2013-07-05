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
#      Date:             03.07.13
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
		m._value = 0;
		return m;
	},
	init : func(){
		me.setListerners();
	},
	electricWork : func(){
		if ((me._value == 1 ) and (me._volt >= 22.0) ){
			me._ampere = me._watt / me._volt;
			me._state  = 1;
		}else{
			me._state  = 0;
			me._ampere = 0;
		}
		me._nState.setValue(me._state);
		me._nAmpere.setValue(me._ampere);
	},
	setOn : func(value){
		me._value = value;
		me.electricWork();
	}
	
	
};

var BootsClass = {
	new : func(root,name,watt){
		var m = { 
			parents : [
				BootsClass, 
				ConsumerClass.new(root,name,watt)
			]
		};
		m._PneumaticPressure	= 1.0;
		m._nPneumaticPressure 	= m._nRoot.initNode("PneumaticPressure",m._PneumaticPressure,"DOUBLE");
		m._nPneumaticLow	= m._nRoot.initNode("PneumaticLow",0,"BOOL");
		m._nBootsPosition	= m._nRoot.initNode("position-norm",0.0,"DOUBLE");
		m._value = 0;
		
		return m;
	},
	init : func(){
		me.setListerners();
		append(me._listeners, setlistener(me._nPneumaticPressure,func(n){me._onPneumaticPressureChange(n);},1,0) );
		
	},
	electricWork : func(){
		
		if ((me._value == 1 ) and (me._volt >= 22.0) ){
			me._watt = me._nWatt.getValue();
			me._ampere = me._watt / me._volt;
			me._state  = 1;
		}else{
			me._state  = 0;
			me._ampere = 0;
		}
		interpolate(me._nBootsPosition,me._PneumaticPressure * me._state,10.0);
		me._nState.setValue(me._state);
		me._nAmpere.setValue(me._ampere);
	},
	_onPneumaticPressureChange : func(n){
		me._PneumaticPressure = n.getValue();	
		if(me._PneumaticPressure <= 0.5){
			me._nPneumaticLow.setValue(1);
		}else{
			me._nPneumaticLow.setValue(0);
		}
	},
	setOn : func(value){
		me._value = value;
		me.electricWork();
	}
};

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
		
		
		m._nIntakeHeat 		= HeatClass.new("/extra500/system/deice/IntakeHeat","Intake Heat",24.0);
		eSystem.circuitBreaker.INTAKE_AI.addOutput(m._nIntakeHeat);
		
		m._WindshieldHeatFail		= m._nRoot.initNode("WindshieldHeat/Fail",0,"BOOL");
		m._WindshieldHeat 		= HeatClass.new("/extra500/system/deice/WindshieldHeat","Windshield Heat",240.0);
		eSystem.circuitBreaker.WSH_HT.addOutput(m._WindshieldHeat);
		
		m._WindshieldCtrl 		= ConsumerClass.new("/extra500/system/deice/WindshieldCtrl","Windshield Control",24.0);
		eSystem.circuitBreaker.WSH_CTRL.addOutput(m._WindshieldCtrl);
		
		m._PitotHeatLeft 		= HeatClass.new("/extra500/system/deice/PitotHeatLeft","Pitot Heat Left",60.0);
		eSystem.circuitBreaker.PITOT_L.addOutput(m._PitotHeatLeft);
		
		m._PitotHeatRight 		= HeatClass.new("/extra500/system/deice/PitotHeatRight","Pitot Heat Right",60.0);
		eSystem.circuitBreaker.PITOT_R.addOutput(m._PitotHeatRight);
		
		m._StaticHeatLeft 		= HeatClass.new("/extra500/system/deice/StaticHeatLeft","Static Heat Left",60.0);
		eSystem.circuitBreaker.PITOT_L.addOutput(m._StaticHeatLeft);
		
		m._StaticHeatRight 		= HeatClass.new("/extra500/system/deice/StaticHeatRight","Static Heat Right",60.0);
		eSystem.circuitBreaker.PITOT_R.addOutput(m._StaticHeatRight);
		
		m._StallHeat 		= HeatClass.new("/extra500/system/deice/StallHeat","Stall Heat",60.0);
		eSystem.circuitBreaker.PITOT_R.addOutput(m._StallHeat);
		
		m._Boots 		= BootsClass.new("/extra500/system/deice/Boots","Boots",20.0);
		eSystem.circuitBreaker.BOOTS.addOutput(m._Boots);
		m._bootsTimer = 0;
		
		m._PropellerHeat 		= HeatClass.new("/extra500/system/deice/Propeller","Propeller Heat",240.0);
		eSystem.circuitBreaker.PROP_HT.addOutput(m._PropellerHeat);
		
		
		
		m._dt = 0;
		m._now = systime();
		m._lastTime = m._now;
		m.timerLoop = maketimer(5.0,m,DeicingSystemClass.update);
		
		return m;
	},
	init : func(){
		me._nIntakeHeat.init();
		me._WindshieldHeat.init();
		me._WindshieldCtrl.init();
		me._PitotHeatLeft.init();
		me._PitotHeatRight.init();
		me._StaticHeatLeft.init();
		me._StaticHeatRight.init();
		me._StallHeat.init();
		me._Boots.init();
		me._PropellerHeat.init();
		
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

		eSystem.switch.Boots.onStateChange = func(n){
			me._state = n.getValue();
			deiceSystem._Boots.setOn(me._state);
			deiceSystem._bootsTimer = 60.0;
			deiceSystem.update();
		};

		append(me._listeners, setlistener(me._WindshieldCtrl._nState,func(n){me._checkWindshieldHeat();},1,0) );
		append(me._listeners, setlistener(me._nWowNose,func(n){me._checkPitot();},1,0) );
				
		me.timerLoop.start();
		
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
		me._nIntakeHeat.setValue(me._intakeHeat);
	},
	update : func(){
		me._now 	= systime();
		me._dt 		= me._now - me._lastTime;
		me._lastTime	= me._now;
		
	#Boots
		
		if (eSystem.switch.Boots._state == 1){
			if (me._bootsTimer <= 0.0){
				me._Boots.setOn( (!me._Boots._state) );
				me._bootsTimer = 60.0;
			}
			me._bootsTimer -= me._dt;
		}
		
	# Propeller heat
		# C	Watt	A
		# 0	120	5
		# -30  	432	18
		# -10.4x +120
		
		if (eSystem.switch.Propeller._state == 1){
			#me._PropellerHeat._nWatt.setValue(global.clamp((me.nIAT.getValue()*-5.2+120),120,432)); 
			var watt = 0;
			watt = me._nIAT.getValue();
			#print ("IAT : "~watt);
			watt =(( watt * -10.4) +120 );
			watt = global.clamp(watt,120,432);
			interpolate(me._PropellerHeat._nWatt,watt,me._dt);
		}
		
	}
};

var deiceSystem = DeicingSystemClass.new("/extra500/system/deice","Deice System");