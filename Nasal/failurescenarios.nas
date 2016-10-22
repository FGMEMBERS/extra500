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
#      Date: 19.10.2016            
#
# 

# this is the failure matrix as used by the random failure function:
# 1: index
# 2: failure name
# 3: failure type (digital, analog (0.1 steps) and progressive)
var failureset = [
	[1,"RMG_jammed","dig"],
	[2,"LMG_jammed","dig"],
	[3,"NG_jammed","dig"],
	[4,"mainvalve_solenoid_fail","dig"],
	[5,"upperdoorvalve_solenoid_fail","dig"],
	[6,"lowerdoorvalve_solenoid_fail","dig"],
	[7,"NG_flat","dig"],
	[8,"LMG_flat","dig"],
	[9,"RMG_flat","dig"],
	[10,"Lbrake","dig"],
	[11,"Rbrake","dig"],
	[12,"RAil","dig"],
	[13,"LAil","dig"],
	[14,"Elevator","dig"],
	[15,"Rudder","dig"],
	[16,"Trim","dig"],
	[17,"LFlap","dig"],
	[18,"RFlap","dig"],
	[19,"LAux_leakage","ana"],
	[20,"RAux_leakage","ana"],
	[21,"LMain_leakage","ana"],
	[22,"RMain_leakage","ana"],
	[23,"LCol_leakage","ana"],
	[24,"RCol_leakage","ana"],
	[25,"LCol_drainFail","dig"],
	[26,"RCol_drainFail","dig"],
	[27,"LMain_inbDrainFail","dig"],
	[28,"LMain_outbDrainFail","dig"],
	[29,"RMain_inbDrainFail","dig"],
	[30,"RMain_outbDrainFail","dig"],
	[31,"LAux_inbDrainFail","dig"],
	[32,"LAux_outbDrainFail","dig"],
	[33,"RAux_inbDrainFail","dig"],
	[34,"RAux_outbDrainFail","dig"],
	[35,"LcheckvalveFail","dig"],
	[36,"RcheckvalveFail","dig"],
	[37,"filterFail","pro",0.001],
	[38,"SelectorValveFail","dig"],
	[39,"fuelPump1Fail","dig"],
	[40,"fuelPump2Fail","dig"],
	[41,"fuelPumpCV1Fail","dig"],
	[42,"fuelPumpCV2Fail","dig"],
	[43,"fftransdFail","dig"],
	[44,"LtransferPumpFail","dig"],
	[45,"RtransferPumpFail","dig"],
	[46,"LtransfilterFail","pro",0.001],
	[47,"RtransfilterFail","pro",0.001],
	[48,"LMinnerjetpumpFail","ana"],
	[49,"RMinnerjetpumpFail","ana"],
	[50,"LMouterjetpumpFail","ana"],
	[51,"RMouterjetpumpFail","ana"],
	[52,"LAjetpumpFail","ana"],
	[53,"RAjetpumpFail","ana"],
	[54,"InletAntiIceFail","dig"],
	[55,"LHPitotHeatFail","dig"],
	[56,"RHPitotHeatFail","dig"],
	[57,"StallHeatFail","dig"],
	[58,"LHStaticHeatFail","dig"],
	[59,"RHStaticHeatFail","dig"],
	[60,"WindshieldHeatFail","dig"],
	[61,"PropHeatFail","dig"],
	[62,"LHStaticLeak","ana"],
	[63,"RHStaticLeak","ana"],
	[64,"LHPitotLeak1","ana"],
	[65,"RHPitotLeak1","ana"],
	[66,"LHPitotLeak2","ana"],
	[67,"RHPitotLeak2","ana"],
	[68,"BackupAttInd","dig"],
	[69,"GPS1Fail","dig"],
	[70,"GPS2Fail","dig"],
	[71,"DMEFail","dig"],
	[72,"NAV1Fail","dig"],
	[73,"NAV2Fail","dig"],
	[74,"GS1Fail","dig"],
	[75,"GS2Fail","dig"],
	[76,"RHHeading","pro",1],
	[77,"LHHeading","pro",1],
	[78,"RHPitch","pro",1],
	[79,"LHPitch","pro",1],
	[80,"RHRoll","pro",1],
	[81,"LHRoll","pro",1],
	[82,"RHHeading","pro",-1],
	[83,"LHHeading","pro",-1],
	[84,"RHPitch","pro",-1],
	[85,"LHPitch","pro",-1],
	[86,"RHRoll","pro",-1],
	[87,"LHRoll","pro",-1]
#	[88,
#	[89,
#	[90,
	

];

# empty matrix for progressive failures. [failurename,speed per minute,fail-number (0-1)]
var progressiveset = [];

setlistener("/extra500/failurescenarios/activate", func {
	var fail = getprop("/extra500/failurescenarios/activate");
	set_failure(fail);
});

# PROGRESSIVE FAILURES
# yes this is running all the time...
setlistener("/sim/time/real/second", func { updateProgFailures();},0,0);

var updateProgFailures = func() {
	var noProgFailures = size(progressiveset);
#print(noProgFailures);
#debug.dump(progressiveset);
	if (noProgFailures!=0) {
		for (var i=0; i < noProgFailures; i = i+1) {
			var fail = math.clamp(progressiveset[i][2] + progressiveset[i][1],0,1);
			progressiveset[i][2] = fail;
			setprop("/extra500/failurescenarios/name",progressiveset[i][0] );
			setprop("/extra500/failurescenarios/activate",fail);	
		}
	}
}

var addProgFailure =  func(name,speed,startValue) {
	var supvector = [name,speed,startValue];
	append(progressiveset,supvector);
} 

var delProgFailure =  func(name) {
	var found = 0;
	var noProgFailures = size(progressiveset);
	if (noProgFailures!=0) {
		for (var i=0; i < noProgFailures; i = i+1) {
			if (progressiveset[i][0] = name ) {	found = 1;	}
			if ((found == 1) and ( i < noProgFailures-1)) {
				progressiveset[i][0] = progressiveset[i+1][0];
				progressiveset[i][1] = progressiveset[i+1][1];
				progressiveset[i][2] = progressiveset[i+1][2];
			}	
		}
		if (found == 1) {	
			pop(progressiveset);
			setprop("/extra500/failurescenarios/name",name );
			setprop("/extra500/failurescenarios/activate",0);
		}	
	}
} 

var delProgAllFailure =  func() {
	var noProgFailures = size(progressiveset);
	if (noProgFailures!=0) {
		for (var i=0; i < noProgFailures; i = i+1) {
			setprop("/extra500/failurescenarios/name",progressiveset[i][0] );
			setprop("/extra500/failurescenarios/activate",0);
		}
		for (var i=0; i < noProgFailures; i = i+1) {
			pop(progressiveset);
		}
	}
}

# RANDOM FAILURE MANAGER

var randomfail = func() {
	if ( getprop("/extra500/failurescenarios/random_active") == 0 ) {
		setprop("/extra500/failurescenarios/random_active",1);
		var maxdelay = 60 * getprop("/extra500/failurescenarios/randommaxdelay");
		if (maxdelay == 0) {
			me.randomfail2();
		} else { 
			var delay = math.round( rand() * maxdelay + 0.5 );
			settimer(func(){ me.randomfail2();},delay);
		}
	}
}

var randomfail2 = func() {
	var nofailures = size(failureset);
	var failureno = math.round( rand() * nofailures + 0.5 ) -1 ;

	if (failureset[failureno][2] == "dig") {
		var fail = 1;
	} else if (failureset[failureno][2] == "ana") {
		var fail = (math.round(rand() * 10 + 0.5 ))/10;
	} 
	if (failureset[failureno][2] == "pro") {
		# for progressive failure, the listener will take care of setting the failure. 
		addProgFailure(failureset[failureno][1],failureset[failureno][3],0);
	} else {
		# for digital and analog failures we set them here
		setprop("/extra500/failurescenarios/name",failureset[failureno][1] );
		setprop("/extra500/failurescenarios/activate",fail);
	}	
}

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
#		foreach(var fault; failureset) {
#	print(fault[0],fault[1],fault[2]);
#			if (failure == fault[1] ) { call(fault[2],[fail],nil,nil); }
#		}
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
	# instrumentation
		else if (failure == "LHStaticLeak") { setprop("/systems/staticL/leaking", fail ); }
		else if (failure == "RHStaticLeak") { setprop("/systems/staticR/leaking", fail ); }
		else if (failure == "LHPitotLeak1") { setprop("/systems/pitotL/leaking1", fail ); }
		else if (failure == "RHPitotLeak1") { setprop("/systems/pitotR/leaking1", fail ); }
		else if (failure == "LHPitotLeak2") { setprop("/systems/pitotL/leaking2", fail ); }
		else if (failure == "RHPitotLeak2") { setprop("/systems/pitotR/leaking2", fail ); }
		else if (failure == "BackupAttInd") { setprop("/instrumentation/attitude-indicator/serviceable", math.abs(fail-1) ); }
		else if (failure == "NAV1Fail") 	{ setprop("/instrumentation/nav/serviceable", math.abs(fail-1) ); }
		else if (failure == "NAV2Fail") 	{ setprop("/instrumentation/nav[1]/serviceable", math.abs(fail-1) ); }
		else if (failure == "GS1Fail") 	{ setprop("/instrumentation/nav/gs/serviceable", math.abs(fail-1) ); }
		else if (failure == "GS2Fail") 	{ setprop("/instrumentation/nav[1]/gs/serviceable", math.abs(fail-1) ); }
		else if (failure == "GPS1Fail") 	{ setprop("/instrumentation/gps/serviceable", math.abs(fail-1) ); }
		else if (failure == "GPS2Fail") 	{ setprop("/instrumentation/gps[1]/serviceable", math.abs(fail-1) ); }
		else if (failure == "DMEFail") 	{ setprop("/instrumentation/dme/serviceable", math.abs(fail-1) ); }
		else if (failure == "RHHeading") 	{ setprop("/extra500/instrumentation/IFD-RH/heading/error", fail); }
		else if (failure == "LHHeading") 	{ setprop("/extra500/instrumentation/IFD-LH/heading/error", fail); }
		else if (failure == "RHPitch") 	{ setprop("/extra500/instrumentation/IFD-RH/attitude/pitch-error", fail); }
		else if (failure == "LHPitch") 	{ setprop("/extra500/instrumentation/IFD-LH/attitude/pitch-error", fail); }
		else if (failure == "RHRoll") 	{ setprop("/extra500/instrumentation/IFD-RH/attitude/roll-error", fail); }
		else if (failure == "LHRoll") 	{ setprop("/extra500/instrumentation/IFD-LH/attitude/roll-error", fail); }
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

# progressive failures
	delProgAllFailure();
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
# Instruments
	setprop("/systems/staticL/leaking", 0 );
	setprop("/systems/staticR/leaking", 0 );
	setprop("/systems/pitotL/leaking1", 0 );
	setprop("/systems/pitotR/leaking1", 0 );
	setprop("/systems/pitotL/leaking2", 0 );
	setprop("/systems/pitotR/leaking2", 0 );
	setprop("/instrumentation/attitude-indicator/serviceable", 1 );
	setprop("/instrumentation/nav/serviceable", 1 );
	setprop("/instrumentation/nav[1]/serviceable", 1 );
	setprop("/instrumentation/nav/gs/serviceable", 1 );
	setprop("/instrumentation/nav[1]/gs/serviceable", 1 );
	setprop("/instrumentation/gps/serviceable", 1 );
	setprop("/instrumentation/gps[1]/serviceable", 1 );
	setprop("/instrumentation/dme/serviceable", 1 );
	setprop("/extra500/instrumentation/IFD-RH/heading/error", 0); 
	setprop("/extra500/instrumentation/IFD-LH/heading/error", 0); 
	setprop("/extra500/instrumentation/IFD-RH/attitude/pitch-error", 0); 
	setprop("/extra500/instrumentation/IFD-LH/attitude/pitch-error", 0); 
	setprop("/extra500/instrumentation/IFD-RH/attitude/roll-error", 0); 
	setprop("/extra500/instrumentation/IFD-LH/attitude/roll-error", 0); 

	setprop("/extra500/failurescenarios/random_active",0);
}

