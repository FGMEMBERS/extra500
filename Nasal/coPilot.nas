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
#      Date:             29.04.13
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
	UI.click("Main Generator on");
	UI.click("Fuel Pump 2 on");
	UI.click("Engine Motoring normal");
	UI.click("Engine Start on");
	UI.click("Engine cutoff off");
	
};

var auto_engine_shutdown = func(){
	UI.click("Engine cutoff on");
	UI.click("Engine Start off");
	UI.click("Main Generator off");
	UI.click("Main Standby Alternator off");
	UI.click("Fuel Pump 2 off");
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
			UI.click("Main Avionics off");
			CoPilot.say("AVIONICS - OFF ... check");
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
			
			CoPilot.say("Pressure Controller - set to field elevation ... ???");
		}, 12.0 );
	settimer(func{
			
			CoPilot.say("Cabin Rate of Climb - Set ... ???");
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
			
			CoPilot.say("PARKING BRAKE - Re-check set ... check");
		}, 20.0 );
	settimer(func{
			
			CoPilot.say("Condition Lever - FUEL OFF ... ???");
		}, 22.0 );
	settimer(func{
			
			CoPilot.say("Power Lever - GRD IDLE ... ???");
		}, 24.0 );
	settimer(func{
			UI.click("Main Battery on");
			CoPilot.say("BATT - ON ... check");
		}, 26.0 );
	settimer(func{
			
			CoPilot.say("Voltmeter - Check reading > 24VDC ... ???");
		}, 28.0 );
	settimer(func{
			
			CoPilot.say("Instrument Lights - As required ... ???");
		}, 30.0 );
	settimer(func{
			
			CoPilot.say("Start Up Clearance - Obtain ... ???");
		}, 32.0 );
	settimer(func{
			
			CoPilot.say("Checklist - Before engine start Battery - performed.");
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
		
			CoPilot.say("Fuel Pressure - Check reading > 10 psi ... ???");
		}, 14.0 );
	settimer(func{
			CoPilot.say("TOT - Check reading < 100 °C ... ???");
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
			CoPilot.say("Condition Lever - Fully forward ... ???");
		}, 22.0 );
	settimer(func{
			CoPilot.say("TOT - Monitor < 850 °C ... ???");
		}, 24.0 );
	settimer(func{
			CoPilot.say("Oil Pressure - Check indication ... ???");
		}, 26.0 );
	settimer(func{
			CoPilot.say("OIL PRESS - Check extinguished ... ???");
		}, 28.0 );
	settimer(func{
			CoPilot.say("Propeller RPM - Check positive indication at 25% N1 ... ???");
		}, 30.0 );
	settimer(func{
			CoPilot.say("PNEUMATIC LOW - Check extinguished ... ???");
		},32.0 );
	settimer(func{
			CoPilot.say("Checklist - Engine start - performed.");
			buisy = 0;
		}, 36.0 );
	
};

var engine_shutdown = func(){
	buisy = 1;
	
	settimer(func{
			
			CoPilot.say("Power Lever - GRD IDLE (at least 2 minutes) ... ???");
		}, 4.0 );
	settimer(func{
			UI.click("Cabin Environmental Air off");
			CoPilot.say("ENV AIR - OFF ... check");
		}, 6.0 );
	settimer(func{
			UI.click("Main Avionics off");
			CoPilot.say("AVIONICS - OFF ... check");
		}, 8.0 );
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
		}, 10.0 );
	settimer(func{
			UI.click("Main Standby Alternator off");
			CoPilot.say("STDBY ALT - OFF ... check");
		}, 12.0 );
	settimer(func{
			UI.click("Main Generator off");
			CoPilot.say("GEN - OFF ... check");
		}, 14.0 );
	settimer(func{
			UI.click("Engine cutoff on");
			CoPilot.say("Condition Lever - FUEL OFF ... ???");
			
		}, 16.0 );
	settimer(func{
			UI.click("Main Battery off");
			CoPilot.say("BATT - OFF ... check");
		}, 18.0 );
	settimer(func{
			
			CoPilot.say("PARKING BRAKE - Set as required ... ???");
		}, 20.0 );
		
	settimer(func{
			CoPilot.say("Checklist - Engine shutdown - performed.");
			buisy = 0;
		}, 24.0 );
	
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
			
			CoPilot.say("Fuel Pressure - Check reading > 10 psi ... ???");
		}, 10.0 );
	settimer(func{
			
			CoPilot.say("STANDBY ALTERN ON - Check illumination ... ???");
		}, 12.0 );
	settimer(func{
			UI.click("Main Generator on");
			CoPilot.say("GEN - ON ... check");
		}, 14.0 );
	settimer(func{
			
			CoPilot.say("STANDBY ALTERN ON - Check extinguished ... ???");
		}, 16.0 );
	settimer(func{
			
			CoPilot.say("GENERATOR FAIL - Check extinguished ... ???");
		}, 18.0 );
	settimer(func{
			
			CoPilot.say("FUEL TRANS LEFT - Check extinguished ... ???");
		}, 20.0 );
	settimer(func{
			
			CoPilot.say("FUEL TRANS RIGHT - Check extinguished ... ???");
		}, 22.0 );
	settimer(func{
			UI.click("Main Avionics on");
			CoPilot.say("AVIONICS - ON ... check");
		}, 24.0 );
	settimer(func{
			
			CoPilot.say("Altimeter - Set ... ???");
		}, 26.0 );
	settimer(func{
			
			CoPilot.say("Radios - Set as required ... ???");
		}, 28.0 );
	settimer(func{
			
			CoPilot.say("Navigation Equipment - Set as required ... ???");
		}, 30.0 );
	settimer(func{
			UI.click("Cabin Environmental Air on");
			CoPilot.say("ENV AIR - ON ... check");
		}, 32.0 );
	settimer(func{
			
			CoPilot.say("Cabin Pressure - Set as required ... ???");
		}, 34.0 );
	settimer(func{
			
			CoPilot.say("Air Conditioning - -Set as required ... ???");
		}, 36.0 );
	settimer(func{
			CoPilot.say("Checklist - After starting engine - performed.");
			buisy = 0;
		}, 40.0 );
	
};

aChecklist["Before engine start - battery"] = before_engine_start_battery;
aChecklist["Engine start"] = engine_start;
aChecklist["Engine shutdown"] = engine_shutdown;
aChecklist["After starting engine"] = after_starting_engine;
