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
#      Date: 12.10.2015            
#
# 

setlistener("/extra500/failurescenarios/activate", func {
	var fail = getprop("/extra500/failurescenarios/activate");
	set_failure(fail);
});

var set_failure = func(fail) {
	var failure = getprop("/extra500/failurescenarios/name");	# getting failure name
	if (failure != "") {
		if (failure == "RMG_jammed") { RMG(fail); }
		else if (failure == "LMG_jammed") { LMG(fail); }
		else if (failure == "NG_jammed") { NG(fail); }
		else if (failure == "mainvalve_solenoid_fail") { mainvalve_solenoid(fail); }
		else if (failure == "upperdoorvalve_solenoid_fail") { upperdoorvalve_solenoid(fail); }
		else if (failure == "lowerdoorvalve_solenoid_fail") { lowerdoorvalve_solenoid(fail); }
	} else {
		print("Error: No failure scenario name set");
		setprop("/extra500/failurescenarios/activate",0);
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


# FAILURE RESET

var failure_reset = func() {
     setprop("/systems/gear/RMG-free", 1 ); 
     setprop("/systems/gear/LMG-free", 1 ); 
     setprop("/systems/gear/NG-free", 1 ); 
     setprop("/systems/gear/solenoids/mainvalve/serviceable", 1 );
     setprop("/systems/gear/solenoids/upperdoorvalve/serviceable", 1 );  
     setprop("/systems/gear/solenoids/lowerdoorvalve/serviceable", 1 ); 
}

