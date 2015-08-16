#    This file is part of extra500
#
#    The extra500 is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 2 of the License, or
#    (at your option) any later version.
#
#    The extra500 is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with extra500.  If not, see <http://www.gnu.org/licenses/>.
#
#      Authors: Dirk Dittmann
#      Date: April 04 2013
#
#      Last change:      Dirk Dittmann
#      Date:             16.08.15
#
var buisy = 0;
var checklist = "";
var aChecklist = {};



var say = func(msg){
	setprop("/sim/messages/copilot", msg);
};

var auto_start = func(){
	var isRunning = getprop("/fdm/jsbsim/propulsion/engine/set-running");
	if (isRunning){
		auto_engine_shutdown();
	}else{
		auto_engine_start();
	}
};

var auto_engine_start = func(){
	UI.click("Main Battery on");
	UI.click("Main Avionics on");
	UI.click("Main Generator on");
	UI.click("Main Standby Alternator on");
	UI.click("Fuel Transfer Left on");
	UI.click("Fuel Transfer Right on");
	UI.click("Fuel Pump 2 on");
	UI.click("Engine Motoring normal");
	UI.click("Engine Start on");
	settimer(func{
		UI.click("Engine cutoff off");
	},3.8);
	
};

var auto_engine_shutdown = func(){
	UI.click("Fuel Pump 2 off");
	UI.click("Fuel Transfer Left off");
	UI.click("Fuel Transfer Right off");
	UI.click("Main Generator off");
	UI.click("Main Standby Alternator off");
	UI.click("Engine cutoff on");
	UI.click("Engine Start off");
	UI.click("Main Battery off");
};





var performChecklist = func(name){
	if (buisy){
		CoPilot.say("One moment performing - "~name~".");
	}else{
		if (contains(aChecklist,name)){
			checklist = name;
			CoPilot.say("perform checklist - "~name~".");
			aChecklist[name]();
		}
	}

};



var before_engine_start_battery = func(){
	
	buisy = 1;
	settimer(func{
			UI.click("Main Generator Test off");
			CoPilot.say("GEN - OFF ... check");
		}, 4.0 );
	settimer(func{
			UI.click("Main Avionics on");
			CoPilot.say("AVIONICS - ON ... check");
		}, 6.0 );
	settimer(func{
			UI.click("Cabin Environmental Air off");
			CoPilot.say("ENV - OFF ... check");
		}, 8.0 );
	settimer(func{
			UI.click("Cabin Pressure Controller on");
			CoPilot.say("PRESS - ON ... check");
		}, 10.0 );
	settimer(func{
			setprop("systems/pressurization/airport-alt",getprop("/instrumentation/altimeter/indicated-altitude-ft"));
			CoPilot.say("Pressure Controller - set to field elevation ... ");
		}, 12.0 );
	settimer(func{
			setprop("systems/pressurization/cabin-climb-rate-fpm",500);
			CoPilot.say("Cabin Rate of Climb - Set ... ");
		}, 14.0 );
	settimer(func{
			UI.click("Cabin Air Condition off");
			CoPilot.say("AIR CON - OFF ... check");
		}, 16.0 );
	settimer(func{
			UI.click("Light Strobe on");
			CoPilot.say("STROBE - ON ... check");
		}, 18.0 );
	settimer(func{
			UI.click("Parkingbrake on");
			setprop("/controls/gear/brake-parking",1);
			CoPilot.say("PARKING BRAKE - Re-check set ... check");
		}, 20.0 );
	settimer(func{
			UI.click("Engine cutoff on");
			CoPilot.say("Condition Lever - FUEL OFF ... ");
		}, 22.0 );
	settimer(func{
			setprop("controls/engines/engine/throttle",0);
			CoPilot.say("Power Lever - GRD IDLE ... ");
		}, 24.0 );
	settimer(func{
			UI.click("Main Battery on");
			CoPilot.say("BATT - ON ... check");
		}, 26.0 );
	settimer(func{
			if (getprop("/extra500/instrumentation/DIP/indicatedVDC") > 24 ) {
				CoPilot.say("Voltmeter - Check reading > 24VDC ... OK ");
			} else {
				CoPilot.say("Voltmeter - Check reading > 24VDC ... TOO LOW ");
			}
		}, 28.0 );
	settimer(func{
			UI.click("Light Instrument on");
			CoPilot.say("Instrument Lights - As required ... ");
		}, 30.0 );
	settimer(func{	
			CoPilot.say("Start Up Clearance - Obtain ... ");
		}, 32.0 );
	settimer(func{
			CoPilot.say("Checklist - BEFORE ENGINE START BATTERY - performed.");
			buisy = 0;
		}, 36.0 );
	
	
};

var engine_start = func(){
	buisy = 1;
	settimer(func{
			UI.click("Night test");
			CoPilot.say("NIGHT/DAY - TEST ... check");
		}, 4.0 );
	settimer(func{
			UI.click("Night night");
			CoPilot.say("NIGHT/DAY - NIGHT ... check");
		}, 8.0 );
	settimer(func{
			UI.click("Fuel Transfer Left on");
			UI.click("Fuel Transfer Right on");
			CoPilot.say("Fuel Transfer Left Right - both ON ... check");
		}, 10.0 );
	settimer(func{
			UI.click("Fuel Pump 1 on");
			CoPilot.say("FUEL PUMP 1 or 2 - ON ... check");
		}, 12.0 );
	settimer(func{	
			if (getprop("/extra500/instrumentation/DIP/indicatedFuelPress") > 10) {
				CoPilot.say("Fuel Pressure - Check reading > 10 psi ... OK ");
			} else {
				CoPilot.say("Fuel Pressure - Check reading > 10 psi ... TOO LOW ");
			}
		}, 14.0 );
	settimer(func{
			if (getprop("/fdm/jsbsim/aircraft/engine/TOT-degC") > 10) {
				CoPilot.say("TOT - Check reading < 100 degC ... OK ");
			} else {
				CoPilot.say("TOT - Check reading < 100 degC ... TOO HIGH ");
			}
		}, 16.0 );
	settimer(func{
			UI.click("Engine Motoring normal");
			CoPilot.say("ENGINE MOTORING - NORMAL ... check");
		}, 18.0 );
	settimer(func{
			UI.click("Engine Start on");
			CoPilot.say("ENGINE START - Momentary START ... check");
		}, 20.0 );
	settimer(func{
			UI.click("Engine cutoff off");
			CoPilot.say("Condition Lever - Fully forward ... ");
		}, 24.0 );
	settimer(func{
			CoPilot.say("TOT - Monitor < 850 degC ... ");
		}, 28.0 );
	settimer(func{
			if (getprop("/fdm/jsbsim/aircraft/engine/OP-psi") > 35) {
				CoPilot.say("Oil Pressure - Check indication ... OK ");
			} else {
				CoPilot.say("Oil Pressure - Check indication ... problem ");
			}
		}, 30.0 );
	settimer(func{
			if (getprop("/extra500/panel/Annunciator/OilPress/state") == 0) {
				CoPilot.say("OIL PRESS - Check extinguished ... OK ");
			} else {
				CoPilot.say("OIL PRESS - Check extinguished ... TOO LOW ");
			}
		}, 32.0 );
	settimer(func{
			CoPilot.say("Propeller RPM - Check positive indication at 25% N1 ...");
		}, 34.0 );
	settimer(func{
			if (getprop("/extra500/panel/Annunciator/PneumaticLow/state") == 0) {
				CoPilot.say("PNEUMATIC LOW - Check extinguished ... OK ");
			} else {
				CoPilot.say("PNEUMATIC LOW - Check extinguished ... still ON! ");
			}
		},40.0 );
	settimer(func{
			CoPilot.say("Checklist - ENGINE START - performed.");
			buisy = 0;
		}, 44.0 );
	
};

var engine_shutdown = func(){
	buisy = 1;
	
	settimer(func{
			
			CoPilot.say("Power Lever - GRD IDLE (at least 2 minutes) ... ");
		}, 4.0 );
	settimer(func{
			UI.click("Cabin Environmental Air off");
			CoPilot.say("ENV AIR - OFF ... check");
		}, 6.0 );
	settimer(func{
			UI.click("Light Ice off");
			UI.click("Light Landing off");
			UI.click("Light Recognition off");
			UI.click("Light Strobe off");
			UI.click("Light Map off");
			UI.click("Light Navigation off");
			UI.click("Light Glare off");
			UI.click("Light Navigation off");
			
			CoPilot.say("Lights OFF ... check");
		}, 8.0 );
	settimer(func{
			UI.click("Main Standby Alternator off");
			CoPilot.say("STDBY ALT - OFF ... check");
		}, 10.0 );
	settimer(func{
			UI.click("Main Generator off");
			CoPilot.say("GEN - OFF ... check");
		}, 12.0 );
	settimer(func{
			UI.click("Engine cutoff on");
			CoPilot.say("Condition Lever - FUEL OFF ...");
			
		}, 14.0 );
	settimer(func{
			UI.click("Main Battery off");
			CoPilot.say("BATT - OFF ... check");
		}, 16.0 );
	settimer(func{
			CoPilot.say("PARKING BRAKE - Set as required ... ");
			UI.click("Parkingbrake on");
			setprop("/controls/gear/brake-left",1);
			setprop("/controls/gear/brake-right",1);
		}, 18.0 );
		
	settimer(func{
			CoPilot.say("Checklist - ENGINE SHUTDOWN - performed.");
			buisy = 0;
		}, 22.0 );
	
};

var after_starting_engine = func(){
	buisy = 1;
	
	settimer(func{
			UI.click("Engine Start off");
			CoPilot.say("ENGINE START - IGN OFF ... check");
		}, 4.0 );
	settimer(func{
			UI.click("Fuel Pump 2 on");
			CoPilot.say("FUEL PUMP (other)  - ON ... check");
		}, 6.0 );
	settimer(func{
			UI.click("Fuel Pump 1 off");
			CoPilot.say("FUEL PUMP (original) - OFF ... check");
		}, 8.0 );
	settimer(func{		
			if (getprop("/extra500/instrumentation/DIP/indicatedFuelPress") > 10) {
				CoPilot.say("Fuel Pressure - Check reading > 10 psi ... OK ");
			} else {
				CoPilot.say("Fuel Pressure - Check reading > 10 psi ... TOO LOW ");
			}
		}, 10.0 );
	settimer(func{
			UI.click("Main Standby Alternator on");
			CoPilot.say("STANDBY ALTERN ON");
		}, 12.0 );
	settimer(func{
			if (getprop("/extra500/panel/Annunciator/StandByAlternOn/state") != 0) {
				CoPilot.say("STANDBY ALTERN ON - Check illumination ... ON ");
			} else {
				CoPilot.say("STANDBY ALTERN ON - Check illumination ... OFF!!! ");
			}
		}, 14.0 );
	settimer(func{
			UI.click("Main Generator on");
			CoPilot.say("GEN - ON ... check");
		}, 16.0 );
	settimer(func{		
			if (getprop("/extra500/panel/Annunciator/StandByAlternOn/state") == 0) {
				CoPilot.say("STANDBY ALTERN ON - Check extinguished ... OFF ");
			} else {
				CoPilot.say("STANDBY ALTERN ON - Check extinguished ... Still ON !!! ");
			}
		}, 18.0 );
	settimer(func{
			if (getprop("/extra500/panel/Annunciator/GeneratorFail/state") == 0) {
				CoPilot.say("GENERATOR FAIL - Check extinguished ... OFF ");
			} else {
				CoPilot.say("GENERATOR FAIL - Check extinguished ... Still ON !!! ");
			}
		}, 20.0 );
	settimer(func{			
			if (getprop("/extra500/panel/Annunciator/FuelTransLeft/state") == 0) {
				CoPilot.say("FUEL TRANS LEFT - Check extinguished ... OFF ");
			} else {
				CoPilot.say("FUEL TRANS LEFT - Check extinguished ... Still ON !!! ");
			}
		}, 22.0 );
	settimer(func{			
			if (getprop("/extra500/panel/Annunciator/FuelTransRight/state") == 0) {
				CoPilot.say("FUEL TRANS RIGHT - Check extinguished ... OFF ");
			} else {
				CoPilot.say("FUEL TRANS RIGHT - Check extinguished ... Still ON !!! ");
			}
		}, 24.0 );
	settimer(func{
			UI.click("Main Avionics on");
			CoPilot.say("AVIONICS - ON ... check");
		}, 26.0 );
	settimer(func{		
			CoPilot.say("Altimeter - Set");
			var qnh = getprop("/environment/pressure-sea-level-inhg");
			setprop("/instrumentation/altimeter-backup/setting-inhg",qnh);
			setprop("/instrumentation/altimeter-IFD-LH/setting-inhg",qnh);
			setprop("/instrumentation/altimeter-IFD-RH/setting-inhg",qnh);
		}, 28.0 );
	settimer(func{			
			CoPilot.say("Radios - Set as required ... ");
		}, 30.0 );
	settimer(func{
			CoPilot.say("Navigation Equipment - Set as required ... ");
		}, 32.0 );
	settimer(func{
			UI.click("Cabin Environmental Air on");
			CoPilot.say("ENV AIR - ON ... check");
		}, 34.0 );
	settimer(func{
			
			CoPilot.say("Cabin Pressure - Set as required ... ");
		}, 36.0 );
	settimer(func{
			
			CoPilot.say("Air Conditioning - Set as required ... ");
		}, 38.0 );
	settimer(func{
			CoPilot.say("Checklist - AFTER ENGINE START - performed.");
			buisy = 0;
		}, 42.0 );
	
};

aChecklist["BEFORE ENGINE START - battery"] = before_engine_start_battery;
aChecklist["ENGINE START"] = engine_start;
aChecklist["ENGINE SHUTDOWN"] = engine_shutdown;
aChecklist["AFTER ENGINE START"] = after_starting_engine;
