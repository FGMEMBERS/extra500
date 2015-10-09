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
#      Last change:       
#      Date:             
#
# 

setlistener("/extra500/failurescenarios/activate", func {
	if ( getprop("/extra500/failurescenarios/activate") == 1 ) {
		init_failure();
	} else {
		failure_reset();
	}
});

var init_failure = func() {
	var failure = getprop("/extra500/failurescenarios/name");	# getting failure name
	if (failure != "") {
		if (failure == "RMG_jammed") { RMG_jammed(); }
		else if (failure == "LMG_jammed") { LMG_jammed(); }
		else if (failure == "NG_jammed") { NG_jammed(); }
		else if (failure == "mainvalve_solenoid_fail") { mainvalve_solenoid_fail(); }
		else if (failure == "upperdoorvalve_solenoid_fail") { upperdoorvalve_solenoid_fail(); }
		else if (failure == "lowerdoorvalve_solenoid_fail") { lowerdoorvalve_solenoid_fail(); }
	} else {
		print("Error: No failure scenario name set");
		setprop("/extra500/failurescenarios/activate",0);
	}
}


# GEAR FAILURES

#individual gears jammed
var RMG_jammed = func() {
     setprop("/systems/gear/RMG-free", 0 ); 
}
var LMG_jammed = func() {
     setprop("/systems/gear/LMG-free", 0 ); 
}
var NG_jammed = func() {
     setprop("/systems/gear/NG-free", 0 ); 
}

#solenoids failed
var mainvalve_solenoid_fail = func() {
     setprop("/systems/gear/solenoids/mainvalve/serviceable", 0 ); 
}
var upperdoorvalve_solenoid_fail = func() {
     setprop("/systems/gear/solenoids/upperdoorvalve/serviceable", 0 ); 
}
var lowerdoorvalve_solenoid_fail = func() {
     setprop("/systems/gear/solenoids/lowerdoorvalve/serviceable", 0 ); 
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

