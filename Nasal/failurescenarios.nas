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
#      Date: 08.12.2015            
#
# 

setlistener("/extra500/failurescenarios/activate", func {
	var fail = getprop("/extra500/failurescenarios/activate");
	set_failure(fail);
});

# CONTROL SYSTEM FAILURES

#ailerons
var RAil = func(n) { #FIXME: need some yaw moment here as well
	if (n==1) {
		setprop("/extra500/failurescenarios/controls/R-aileron",1);
		if ( getprop("/extra500/failurescenarios/controls/L-aileron") == 1) {
			setprop("/fdm/jsbsim/aero/coefficients/cl_aileron",0.0);
		} else {
			setprop("/fdm/jsbsim/aero/coefficients/cl_aileron",0.01385);
		}
	} else {
		setprop("/extra500/failurescenarios/controls/R-aileron",0);
		if ( getprop("/extra500/failurescenarios/controls/L-aileron") == 1) {
			setprop("/fdm/jsbsim/aero/coefficients/cl_aileron",0.01385);
		} else {
			setprop("/fdm/jsbsim/aero/coefficients/cl_aileron",0.0277);
		}
	}
}
var LAil = func(n) {
	if (n==1) {
		setprop("/extra500/failurescenarios/controls/L-aileron",1);
		if ( getprop("/extra500/failurescenarios/controls/R-aileron") == 1) {
			setprop("/fdm/jsbsim/aero/coefficients/cl_aileron",0.0);
		} else {
			setprop("/fdm/jsbsim/aero/coefficients/cl_aileron",0.01385);
		}
	} else {
		setprop("/extra500/failurescenarios/controls/L-aileron",0);
		if ( getprop("/extra500/failurescenarios/controls/R-aileron") == 1) {
			setprop("/fdm/jsbsim/aero/coefficients/cl_aileron",0.01385);
		} else {
			setprop("/fdm/jsbsim/aero/coefficients/cl_aileron",0.0277);
		}
	}
}
var Elevator = func(n) {
	if (n==1) {
		setprop("/extra500/failurescenarios/controls/elevator",1);
	} else {
		setprop("/extra500/failurescenarios/controls/elevator",0);
	}
}

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
		else if (failure == "RAil") { RAil(fail); }
		else if (failure == "LAil") { LAil(fail); }
		else if (failure == "Elevator") { Elevator(fail); }
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

	} else {
		print("Error: No failure scenario name set");
		setprop("/extra500/failurescenarios/activate",0);
	}
}

# FAILURE RESET

var failure_reset = func() {

# Propellor
	setprop("/fdm/jsbsim/aircraft/propeller/contact",0);

# Flight Controls
	setprop("/fdm/jsbsim/aero/coefficients/cl_aileron",0.0277);
	setprop("/extra500/failurescenarios/controls/L-aileron",0);
	setprop("/extra500/failurescenarios/controls/R-aileron",0);
	setprop("/extra500/failurescenarios/controls/elevator",0);

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

