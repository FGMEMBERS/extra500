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
#      Date: 22.10.2015            
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
		setprop("/fdm/jsbsim/aero/coefficients/cl_aileron",0.01385);
	} else {
		setprop("/fdm/jsbsim/aero/coefficients/cl_aileron",0.0277);
	}
}
var LAil = func(n) {
	if (n==1) {
		setprop("/fdm/jsbsim/aero/coefficients/cl_aileron",0.01385);
	} else {
		setprop("/fdm/jsbsim/aero/coefficients/cl_aileron",0.0277);
	}
}

# FUEL SYSTEM FAILURES
var LAux_leak = func(n) {
	if (n==1) {
		setprop("/systems/fuel/LHtank/aux/leakage/flow",1); # 1ppm
		setprop("/systems/fuel/LHtank/aux/leakage/state",1); 
	} else {
		setprop("/systems/fuel/LHtank/aux/leakage/flow",0); 
		setprop("/systems/fuel/LHtank/aux/leakage/state",0); 
	}
}
var LMain_leak = func(n) {
	if (n==1) {
		setprop("/systems/fuel/LHtank/main/leakage/flow",1); # 1ppm
		setprop("/systems/fuel/LHtank/main/leakage/state",1); 
	} else {
		setprop("/systems/fuel/LHtank/main/leakage/flow",0); 
		setprop("/systems/fuel/LHtank/main/leakage/state",0); 
	}
}
var LCol_leak = func(n) {
	if (n==1) {
		setprop("/systems/fuel/LHtank/collector/leakage/flow",1); # 1ppm
		setprop("/systems/fuel/LHtank/collector/leakage/state",1); 
	} else {
		setprop("/systems/fuel/LHtank/collector/leakage/flow",0); 
		setprop("/systems/fuel/LHtank/collector/leakage/state",0); 
	}
}
var RAux_leak = func(n) {
	if (n==1) {
		setprop("/systems/fuel/RHtank/aux/leakage/flow",1); # 1ppm
		setprop("/systems/fuel/RHtank/aux/leakage/state",1); 
	} else {
		setprop("/systems/fuel/RHtank/aux/leakage/flow",0); 
		setprop("/systems/fuel/RHtank/aux/leakage/state",0); 
	}
}
var RMain_leak = func(n) {
	if (n==1) {
		setprop("/systems/fuel/RHtank/main/leakage/flow",1); # 1ppm
		setprop("/systems/fuel/RHtank/main/leakage/state",1); 
	} else {
		setprop("/systems/fuel/RHtank/main/leakage/flow",0); 
		setprop("/systems/fuel/RHtank/main/leakage/state",0); 
	}
}
var RCol_leak = func(n) {
	if (n==1) {
		setprop("/systems/fuel/RHtank/collector/leakage/flow",1); # 1ppm
		setprop("/systems/fuel/RHtank/collector/leakage/state",1); 
	} else {
		setprop("/systems/fuel/RHtank/collector/leakage/flow",0); 
		setprop("/systems/fuel/RHtank/collector/leakage/state",0); 
	}
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
		setprop("/fdm/jsbsim/gear/unit[0]/static_friction", 0.6 ); 
		setprop("/fdm/jsbsim/gear/unit[0]/dynamic_friction", 0.3 ); 
	} else {
		setprop("/fdm/jsbsim/gear/unit[0]/flatTire", 0 ); 
		setprop("/fdm/jsbsim/gear/unit[0]/z-position", 5.748 ); 
		setprop("/fdm/jsbsim/gear/unit[0]/static_friction", 0.7 ); 
		setprop("/fdm/jsbsim/gear/unit[0]/dynamic_friction", 0.4 ); 
	}
}
var LMG_flat = func(n) {
	if (n==1) {
		setprop("/fdm/jsbsim/gear/unit[1]/flatTire", 1 ); 
		setprop("/fdm/jsbsim/gear/unit[1]/z-position", 12 ); 
		setprop("/fdm/jsbsim/gear/unit[1]/static_friction", 0.6 ); 
		setprop("/fdm/jsbsim/gear/unit[1]/dynamic_friction", 0.3 ); 
	} else {
		setprop("/fdm/jsbsim/gear/unit[1]/flatTire", 0 ); 
		setprop("/fdm/jsbsim/gear/unit[1]/z-position", 8.268 ); 
		setprop("/fdm/jsbsim/gear/unit[1]/static_friction", 0.7 ); 
		setprop("/fdm/jsbsim/gear/unit[1]/dynamic_friction", 0.4 ); 
	}
}
var RMG_flat = func(n) {
	if (n==1) {
		setprop("/fdm/jsbsim/gear/unit[2]/flatTire", 1 ); 
		setprop("/fdm/jsbsim/gear/unit[2]/z-position", 12 ); 
		setprop("/fdm/jsbsim/gear/unit[2]/static_friction", 0.6 ); 
		setprop("/fdm/jsbsim/gear/unit[2]/dynamic_friction", 0.3 ); 
	} else {
		setprop("/fdm/jsbsim/gear/unit[2]/flatTire", 0 ); 
		setprop("/fdm/jsbsim/gear/unit[2]/z-position", 8.268 ); 
		setprop("/fdm/jsbsim/gear/unit[2]/static_friction", 0.7 ); 
		setprop("/fdm/jsbsim/gear/unit[2]/dynamic_friction", 0.4 ); 
	}
}

var set_failure = func(fail) {
	var failure = getprop("/extra500/failurescenarios/name");	# getting failure name
	if (failure != "") {
		if (failure == "RMG_jammed") { RMG(fail); }
		else if (failure == "LMG_jammed") { LMG(fail); }
		else if (failure == "NG_jammed") { NG(fail); }
		else if (failure == "mainvalve_solenoid_fail") { mainvalve_solenoid(fail); }
		else if (failure == "upperdoorvalve_solenoid_fail") { upperdoorvalve_solenoid(fail); }
		else if (failure == "lowerdoorvalve_solenoid_fail") { lowerdoorvalve_solenoid(fail); }
		else if (failure == "NG_flat") { NG_flat(fail); }
		else if (failure == "LMG_flat") { LMG_flat(fail); }
		else if (failure == "RMG_flat") { RMG_flat(fail); }
		else if (failure == "RAil") { RAil(fail); }
		else if (failure == "LAil") { LAil(fail); }
		else if (failure == "LAux_leakage") { LAux_leak(fail); }
		else if (failure == "RAux_leakage") { RAux_leak(fail); }
		else if (failure == "LMain_leakage") { LMain_leak(fail); }
		else if (failure == "RMain_leakage") { RMain_leak(fail); }
		else if (failure == "LCol_leakage") { LCol_leak(fail); }
		else if (failure == "RCol_leakage") { RCol_leak(fail); }
	} else {
		print("Error: No failure scenario name set");
		setprop("/extra500/failurescenarios/activate",0);
	}
}

# FAILURE RESET

var failure_reset = func() {
     setprop("/systems/gear/RMG-free", 1 ); 
     setprop("/systems/gear/LMG-free", 1 ); 
     setprop("/systems/gear/NG-free", 1 ); 
     setprop("/systems/gear/solenoids/mainvalve/serviceable", 1 );
     setprop("/systems/gear/solenoids/upperdoorvalve/serviceable", 1 );  
     setprop("/systems/gear/solenoids/lowerdoorvalve/serviceable", 1 ); 
}

