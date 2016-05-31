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
#      Author: Eric van den Berg
#      Date:   09.10.2015
#
#      Last change: Eric van den Berg      
#      Date: 28.05.2016            
#
# 

setlistener("/extra500/failurescenarios/activate", func {
	var fail = getprop("/extra500/failurescenarios/activate");
	set_failure(fail);
});

# CONTROL SYSTEM FAILURES

# FUEL SYSTEM FAILURES

var tankLeak = func(flowrate,flowprop,stateprop) {
	setprop(flowprop,flowrate);
	if (flowrate>0) {
		setprop(stateprop,1);
	} else {	
		setprop(stateprop,0);
	} 
}

var LcheckvalveFail = func(fail) {
	setprop("/systems/fuel/LHtank/checkvalve/serviceable", math.abs(fail-1) );
	extra500.fuelSystem.setFlowBalance();
}
var RcheckvalveFail = func(fail) {
	setprop("/systems/fuel/RHtank/checkvalve/serviceable", math.abs(fail-1) );
	extra500.fuelSystem.setFlowBalance();
}

# GEAR FAILURES

#individual gears jammed
var RMG = func(n) {setprop("/systems/gear/RMG-free", math.abs(n-1) ); }
var LMG = func(n) {setprop("/systems/gear/LMG-free", math.abs(n-1) ); }
var NG = func(n) {setprop("/systems/gear/NG-free", math.abs(n-1) ); }

#solenoids failed
var mainvalve_solenoid = func(n) {setprop("/systems/gear/solenoids/mainvalve/serviceable", math.abs(n-1) ); }
var upperdoorvalve_solenoid = func(n) {setprop("/systems/gear/solenoids/upperdoorvalve/serviceable", math.abs(n-1) ); }
var lowerdoorvalve_solenoid = func(n) {setprop("/systems/gear/solenoids/lowerdoorvalve/serviceable", math.abs(n-1) ); }

#flat tire
var NG_flat = func(n) {
	if (n==1) {
		setprop("/fdm/jsbsim/gear/unit[0]/flatTire", 1 ); 
		setprop("/fdm/jsbsim/gear/unit[0]/z-position", 9 ); 
		setprop("/fdm/jsbsim/gear/unit[0]/static_friction_coeff", 0.6 ); 
		setprop("/fdm/jsbsim/gear/unit[0]/dynamic_friction_coeff", 0.3 ); 
	} else {
		setprop("/fdm/jsbsim/gear/unit[0]/flatTire", 0 ); 
		setprop("/fdm/jsbsim/gear/unit[0]/z-position", 5.748 ); 
		setprop("/fdm/jsbsim/gear/unit[0]/static_friction_coeff", 0.7 ); 
		setprop("/fdm/jsbsim/gear/unit[0]/dynamic_friction_coeff", 0.4 ); 
	}
}
var LMG_flat = func(n) {
	if (n==1) {
		setprop("/fdm/jsbsim/gear/unit[1]/flatTire", 1 ); 
		setprop("/fdm/jsbsim/gear/unit[1]/z-position", 12 ); 
		if (getprop("/fdm/jsbsim/gear/unit[1]/brakeFail")==0) { 
			setprop("/fdm/jsbsim/gear/unit[1]/static_friction_coeff", 0.6 ); 
		}
		setprop("/fdm/jsbsim/gear/unit[1]/dynamic_friction_coeff", 0.3 ); 
	} else {
		setprop("/fdm/jsbsim/gear/unit[1]/flatTire", 0 ); 
		setprop("/fdm/jsbsim/gear/unit[1]/z-position", 8.268 ); 
		if (getprop("/fdm/jsbsim/gear/unit[1]/brakeFail")==0) { 
			setprop("/fdm/jsbsim/gear/unit[1]/static_friction_coeff", 0.7 ); 
		}
		setprop("/fdm/jsbsim/gear/unit[1]/dynamic_friction_coeff", 0.4 ); 
	}
}
var RMG_flat = func(n) {
	if (n==1) {
		setprop("/fdm/jsbsim/gear/unit[2]/flatTire", 1 ); 
		setprop("/fdm/jsbsim/gear/unit[2]/z-position", 12 ); 
		if (getprop("/fdm/jsbsim/gear/unit[2]/brakeFail")==0) { 
			setprop("/fdm/jsbsim/gear/unit[2]/static_friction_coeff", 0.6 ); 
		}
		setprop("/fdm/jsbsim/gear/unit[2]/dynamic_friction_coeff", 0.3 ); 
	} else {
		setprop("/fdm/jsbsim/gear/unit[2]/flatTire", 0 ); 
		setprop("/fdm/jsbsim/gear/unit[2]/z-position", 8.268 ); 
		if (getprop("/fdm/jsbsim/gear/unit[2]/brakeFail")==0) { 
			setprop("/fdm/jsbsim/gear/unit[2]/static_friction_coeff", 0.7 ); 
		}
		setprop("/fdm/jsbsim/gear/unit[2]/dynamic_friction_coeff", 0.4 ); 
	}
}
var LMG_nobrake = func(n) {
	if (n==1) {
		setprop("/fdm/jsbsim/gear/unit[1]/brakeFail", 1 ); 
		setprop("/fdm/jsbsim/gear/unit[1]/static_friction_coeff", 0.0 ); 
	} else {
		setprop("/fdm/jsbsim/gear/unit[1]/brakeFail", 0 ); 
		setprop("/fdm/jsbsim/gear/unit[1]/static_friction_coeff", 0.7 ); 
	}
}
var RMG_nobrake = func(n) {
	if (n==1) {
		setprop("/fdm/jsbsim/gear/unit[2]/brakeFail", 1 ); 
		setprop("/fdm/jsbsim/gear/unit[2]/static_friction_coeff", 0.0 ); 
	} else {
		setprop("/fdm/jsbsim/gear/unit[2]/brakeFail", 0 ); 
		setprop("/fdm/jsbsim/gear/unit[2]/static_friction_coeff", 0.7 ); 
	}
}

var set_failure = func(fail) {
	var failure = getprop("/extra500/failurescenarios/name");	# getting failure name
	if (failure != "") {
# gear
		if (failure == "RMG_jammed") { RMG(fail); }
		else if (failure == "LMG_jammed") { LMG(fail); }
		else if (failure == "NG_jammed") { NG(fail); }
		else if (failure == "mainvalve_solenoid_fail") { mainvalve_solenoid(fail); }
		else if (failure == "upperdoorvalve_solenoid_fail") { upperdoorvalve_solenoid(fail); }
		else if (failure == "lowerdoorvalve_solenoid_fail") { lowerdoorvalve_solenoid(fail); }
		else if (failure == "NG_flat") { NG_flat(fail); }
		else if (failure == "LMG_flat") { LMG_flat(fail); }
		else if (failure == "RMG_flat") { RMG_flat(fail); }
		else if (failure == "Lbrake") { LMG_nobrake(fail); }
		else if (failure == "Rbrake") { RMG_nobrake(fail); }
# controls
		else if (failure == "RAil") { setprop("/extra500/failurescenarios/controls/R-aileron",fail); }
		else if (failure == "LAil") { setprop("/extra500/failurescenarios/controls/L-aileron",fail); }
		else if (failure == "Elevator") { setprop("/extra500/failurescenarios/controls/elevator",fail); }
		else if (failure == "Rudder") { setprop("/extra500/failurescenarios/controls/rudder",fail); }
		else if (failure == "Trim") { setprop("/extra500/failurescenarios/controls/trim",fail); }
		else if (failure == "LFlap") { setprop("/extra500/failurescenarios/controls/L-flap",fail); }
		else if (failure == "RFlap") { setprop("/extra500/failurescenarios/controls/R-flap",fail); }
# fuel
	# tank leakage
		else if (failure == "LAux_leakage") { tankLeak(fail,"/systems/fuel/LHtank/aux/leakage/flow","/systems/fuel/LHtank/aux/leakage/state"); }
		else if (failure == "RAux_leakage") { tankLeak(fail,"/systems/fuel/RHtank/aux/leakage/flow","/systems/fuel/RHtank/aux/leakage/state"); }
		else if (failure == "LMain_leakage") { tankLeak(fail,"/systems/fuel/LHtank/main/leakage/flow","/systems/fuel/LHtank/main/leakage/state"); }
		else if (failure == "RMain_leakage") { tankLeak(fail,"/systems/fuel/RHtank/main/leakage/flow","/systems/fuel/RHtank/main/leakage/state"); }
		else if (failure == "LCol_leakage") { tankLeak(fail,"/systems/fuel/LHtank/collector/leakage/flow","/systems/fuel/LHtank/collector/leakage/state"); }
		else if (failure == "RCol_leakage") { tankLeak(fail,"/systems/fuel/RHtank/collector/leakage/flow","/systems/fuel/RHtank/collector/leakage/state"); }
	# drain failures
		else if (failure == "LCol_drainFail") { setprop("/systems/fuel/LHtank/collector/drain/serviceable", math.abs(fail-1) ); }
		else if (failure == "RCol_drainFail") { setprop("/systems/fuel/RHtank/collector/drain/serviceable", math.abs(fail-1) ); }
		else if (failure == "LMain_inbDrainFail") { setprop("/systems/fuel/LHtank/main/draininboard/serviceable", math.abs(fail-1) ); }
		else if (failure == "LMain_outbDrainFail") { setprop("/systems/fuel/LHtank/main/drainoutboard/serviceable", math.abs(fail-1) ); }
		else if (failure == "RMain_inbDrainFail") { setprop("/systems/fuel/RHtank/main/draininboard/serviceable", math.abs(fail-1) ); }
		else if (failure == "RMain_outbDrainFail") { setprop("/systems/fuel/RHtank/main/drainoutboard/serviceable", math.abs(fail-1) ); }
		else if (failure == "LAux_inbDrainFail") { setprop("/systems/fuel/LHtank/aux/draininboard/serviceable", math.abs(fail-1) ); }
		else if (failure == "LAux_outbDrainFail") { setprop("/systems/fuel/LHtank/aux/drainoutboard/serviceable", math.abs(fail-1) ); }
		else if (failure == "RAux_inbDrainFail") { setprop("/systems/fuel/RHtank/aux/draininboard/serviceable", math.abs(fail-1) ); }
		else if (failure == "RAux_outbDrainFail") { setprop("/systems/fuel/RHtank/aux/drainoutboard/serviceable", math.abs(fail-1) ); }
	# component failures
		else if (failure == "LcheckvalveFail") { LcheckvalveFail(fail); }
		else if (failure == "RcheckvalveFail") { RcheckvalveFail(fail); }
		else if (failure == "filterFail") { setprop("/systems/fuel/fuelfilter/clogged", fail ); }
		else if (failure == "SelectorValveFail") { setprop("/systems/fuel/selectorValve/serviceable", math.abs(fail-1) ); }
		else if (failure == "fuelPump1Fail") { setprop("/systems/fuel/FuelPump1/serviceable", math.abs(fail-1) ); }
		else if (failure == "fuelPump2Fail") { setprop("/systems/fuel/FuelPump2/serviceable", math.abs(fail-1) ); }
		else if (failure == "fuelPumpCV1Fail") { setprop("/systems/fuel/FP1checkvalve/serviceable", math.abs(fail-1) ); }
		else if (failure == "fuelPumpCV2Fail") { setprop("/systems/fuel/FP2checkvalve/serviceable", math.abs(fail-1) ); }
		else if (failure == "fftransdFail") { setprop("/systems/fuel/FFtransducer/blocked", fail ); }
	# transfer system failures
		else if (failure == "LtransferPumpFail") { setprop("/systems/fuel/LHtank/motivepump/serviceable", math.abs(fail-1) ); }
		else if (failure == "RtransferPumpFail") { setprop("/systems/fuel/RHtank/motivepump/serviceable", math.abs(fail-1) ); }
		else if (failure == "LtransfilterFail") { setprop("/systems/fuel/LHtank/motivefilter/clogged", fail ); }
		else if (failure == "RtransfilterFail") { setprop("/systems/fuel/RHtank/motivefilter/clogged", fail ); }
		else if (failure == "LMinnerjetpumpFail") { setprop("/systems/fuel/LHtank/main/innerjetpump/clogged", fail ); }
		else if (failure == "RMinnerjetpumpFail") { setprop("/systems/fuel/RHtank/main/innerjetpump/clogged", fail ); }
		else if (failure == "LMouterjetpumpFail") { setprop("/systems/fuel/LHtank/main/outerjetpump/clogged", fail ); }
		else if (failure == "RMouterjetpumpFail") { setprop("/systems/fuel/RHtank/main/outerjetpump/clogged", fail ); }
		else if (failure == "LAjetpumpFail") { setprop("/systems/fuel/LHtank/aux/jetpump/clogged", fail ); }
		else if (failure == "RAjetpumpFail") { setprop("/systems/fuel/RHtank/aux/jetpump/clogged", fail ); }

# de- and anti-ice
		else if (failure == "InletAntiIceFail") { setprop("/extra500/system/deice/IntakeHeat/serviceable", math.abs(fail-1) ); }
	# electric systems
		else if (failure == "LHPitotHeatFail") { setprop("/extra500/system/deice/PitotHeatLeft/service/serviceable", math.abs(fail-1) ); }
		else if (failure == "RHPitotHeatFail") { setprop("/extra500/system/deice/PitotHeatRight/service/serviceable", math.abs(fail-1) ); }
		else if (failure == "StallHeatFail") { setprop("/extra500/system/deice/StallHeat/service/serviceable", math.abs(fail-1) ); }
		else if (failure == "LHStaticHeatFail") { setprop("/extra500/system/deice/StaticHeatLeft/service/serviceable", math.abs(fail-1) ); }
		else if (failure == "RHStaticHeatFail") { setprop("/extra500/system/deice/StaticHeatRight/service/serviceable", math.abs(fail-1) ); }
		else if (failure == "WindshieldHeatFail") { setprop("/extra500/system/deice/WindshieldHeat/service/serviceable", math.abs(fail-1) ); }
		else if (failure == "PropHeatFail") { setprop("/extra500/system/deice/Propeller/service/serviceable", math.abs(fail-1) ); }
	# boots
		else if (failure == "LHinnerBootFail") { setprop("/systems/pneumatic/LHinnerBoot/serviceable", math.abs(fail-1) ); }
		else if (failure == "RHinnerBootFail") { setprop("/systems/pneumatic/RHinnerBoot/serviceable", math.abs(fail-1) ); }
		else if (failure == "LHouterBootFail") { setprop("/systems/pneumatic/LHouterBoot/serviceable", math.abs(fail-1) ); }
		else if (failure == "RHouterBootFail") { setprop("/systems/pneumatic/RHouterBoot/serviceable", math.abs(fail-1) ); }
		else if (failure == "VStabBootFail") { setprop("/systems/pneumatic/VStabBoot/serviceable", math.abs(fail-1) ); }
		else if (failure == "LHHStabBootFail") { setprop("/systems/pneumatic/LHHStabBoot/serviceable", math.abs(fail-1) ); }
		else if (failure == "RHHStabBootFail") { setprop("/systems/pneumatic/RHHStabBoot/serviceable", math.abs(fail-1) ); }
	} else {
		print("Error: No failure scenario name set");
		setprop("/extra500/failurescenarios/activate",0);
	}
}

# Engine and propeller: separate listeners for propeller and engine failures

setlistener("/gear/gear[13]/wow", func {
	var contact = getprop("/gear/gear[13]/wow");
	
	if (contact == 1) {
		setprop("/fdm/jsbsim/aircraft/propeller/contact",1);
	}
},1,0);

setlistener("/gear/gear[6]/wow", func {
	var contact = getprop("/gear/gear[6]/wow");
	
	if (contact == 1) {
		setprop("/systems/engine/failure-fast",1);
	}
},1,0);


# FAILURE RESET

var failure_reset = func() {

# Engine
	setprop("/systems/engine/failure-fast",0);
# Propellor
	setprop("/fdm/jsbsim/aircraft/propeller/contact",0);

# Flight Controls
	setprop("/extra500/failurescenarios/controls/L-aileron",0);
	setprop("/extra500/failurescenarios/controls/R-aileron",0);
	setprop("/extra500/failurescenarios/controls/elevator",0);
	setprop("/extra500/failurescenarios/controls/rudder",0);
	setprop("/extra500/failurescenarios/controls/trim",0);
	setprop("/extra500/failurescenarios/controls/L-flap",0);
	setprop("/extra500/failurescenarios/controls/R-flap",0);

# FUEL
	setprop("/systems/fuel/LHtank/aux/leakage/flow",0); 
	setprop("/systems/fuel/LHtank/aux/leakage/state",0); 
	setprop("/systems/fuel/LHtank/main/leakage/flow",0); 
	setprop("/systems/fuel/LHtank/main/leakage/state",0); 
	setprop("/systems/fuel/LHtank/collector/leakage/flow",0); 
	setprop("/systems/fuel/LHtank/collector/leakage/state",0); 
	setprop("/systems/fuel/RHtank/aux/leakage/flow",0); 
	setprop("/systems/fuel/RHtank/aux/leakage/state",0); 
	setprop("/systems/fuel/RHtank/main/leakage/flow",0); 
	setprop("/systems/fuel/RHtank/main/leakage/state",0); 
	setprop("/systems/fuel/RHtank/collector/leakage/flow",0); 
	setprop("/systems/fuel/RHtank/collector/leakage/state",0); 
	setprop("/systems/fuel/LHtank/collector/drain/serviceable", 1 );
	setprop("/systems/fuel/RHtank/collector/drain/serviceable", 1 ); 
	setprop("/systems/fuel/LHtank/main/draininboard/serviceable", 1 ); 
	setprop("/systems/fuel/LHtank/main/drainoutboard/serviceable", 1 ); 
	setprop("/systems/fuel/RHtank/main/draininboard/serviceable", 1 ); 
	setprop("/systems/fuel/RHtank/main/drainoutboard/serviceable", 1 ); 
	setprop("/systems/fuel/LHtank/aux/draininboard/serviceable", 1 ); 
	setprop("/systems/fuel/LHtank/aux/drainoutboard/serviceable", 1 ); 
	setprop("/systems/fuel/RHtank/aux/draininboard/serviceable", 1 ); 
	setprop("/systems/fuel/RHtank/aux/drainoutboard/serviceable", 1 ); 
	setprop("/systems/fuel/LHtank/checkvalve/serviceable", 1 );
	setprop("/systems/fuel/RHtank/checkvalve/serviceable", 1 );
	setprop("/systems/fuel/fuelfilter/clogged", 0 );
	setprop("/systems/fuel/fuelfilter/bypass/state", 0 );
	extra500.fuelSystem.setFlowBalance();
	setprop("/systems/fuel/selectorValve/serviceable", 1 );
	setprop("/systems/fuel/FuelPump1/serviceable", 1 );
	setprop("/systems/fuel/FuelPump2/serviceable", 1 );
	setprop("/systems/fuel/FP1checkvalve/serviceable", 1 );
	setprop("/systems/fuel/FP2checkvalve/serviceable", 1 );
	setprop("/systems/fuel/FFtransducer/blocked", 0 );
	setprop("/systems/fuel/LHtank/motivepump/serviceable", 1 );
	setprop("/systems/fuel/RHtank/motivepump/serviceable", 1 );
	setprop("/systems/fuel/LHtank/motivefilter/clogged", 0 );
	setprop("/systems/fuel/RHtank/motivefilter/clogged", 0 );
	setprop("/systems/fuel/LHtank/main/innerjetpump/clogged", 0 );
	setprop("/systems/fuel/LHtank/main/outerjetpump/clogged", 0 );
	setprop("/systems/fuel/LHtank/aux/jetpump/clogged", 0 );
	setprop("/systems/fuel/RHtank/main/innerjetpump/clogged", 0 );
	setprop("/systems/fuel/RHtank/main/outerjetpump/clogged", 0 );
	setprop("/systems/fuel/RHtank/aux/jetpump/clogged", 0 );
#DEICE
	setprop("/systems/pneumatic/leak", 0.0);
	setprop("/extra500/system/deice/IntakeHeat/serviceable", 1 );
	setprop("/extra500/system/deice/PitotHeatLeft/service/serviceable", 1 );
	setprop("/extra500/system/deice/PitotHeatRight/service/serviceable", 1 );
	setprop("/extra500/system/deice/StallHeat/service/serviceable", 1 ); 
	setprop("/extra500/system/deice/StaticHeatLeft/service/serviceable", 1 ); 
	setprop("/extra500/system/deice/StaticHeatRight/service/serviceable", 1 ); 
	setprop("/extra500/system/deice/WindshieldHeat/service/serviceable", 1 ); 
	setprop("/extra500/system/deice/Propeller/service/serviceable", 1 ); 
	setprop("/systems/pneumatic/LHinnerBoot/serviceable", 1 );
	setprop("/systems/pneumatic/RHinnerBoot/serviceable", 1 ); 
	setprop("/systems/pneumatic/LHouterBoot/serviceable", 1 ); 
	setprop("/systems/pneumatic/RHouterBoot/serviceable", 1 ); 
	setprop("/systems/pneumatic/VStabBoot/serviceable", 1 ); 
	setprop("/systems/pneumatic/LHHStabBoot/serviceable", 1 ); 
	setprop("/systems/pneumatic/RHHStabBoot/serviceable", 1 ); 
#GEAR
     	setprop("/systems/gear/RMG-free", 1 ); 
     	setprop("/systems/gear/LMG-free", 1 ); 
     	setprop("/systems/gear/NG-free", 1 ); 
     	setprop("/systems/gear/solenoids/mainvalve/serviceable", 1 );
     	setprop("/systems/gear/solenoids/upperdoorvalve/serviceable", 1 );  
     	setprop("/systems/gear/solenoids/lowerdoorvalve/serviceable", 1 ); 
	setprop("/fdm/jsbsim/gear/unit[0]/flatTire", 0 ); 
	setprop("/fdm/jsbsim/gear/unit[0]/z-position", 5.748 ); 
	setprop("/fdm/jsbsim/gear/unit[0]/static_friction_coeff", 0.7 ); 
	setprop("/fdm/jsbsim/gear/unit[0]/dynamic_friction_coeff", 0.4 ); 
	setprop("/fdm/jsbsim/gear/unit[1]/flatTire", 0 ); 
	setprop("/fdm/jsbsim/gear/unit[1]/z-position", 8.268 ); 
	setprop("/fdm/jsbsim/gear/unit[1]/static_friction_coeff", 0.7 ); 
	setprop("/fdm/jsbsim/gear/unit[1]/dynamic_friction_coeff", 0.4 ); 
	setprop("/fdm/jsbsim/gear/unit[2]/flatTire", 0 ); 
	setprop("/fdm/jsbsim/gear/unit[2]/z-position", 8.268 ); 
	setprop("/fdm/jsbsim/gear/unit[2]/static_friction_coeff", 0.7 ); 
	setprop("/fdm/jsbsim/gear/unit[2]/dynamic_friction_coeff", 0.4 ); 
	setprop("/fdm/jsbsim/gear/unit[1]/brakeFail", 0 ); 
	setprop("/fdm/jsbsim/gear/unit[2]/brakeFail", 0 ); 
}

