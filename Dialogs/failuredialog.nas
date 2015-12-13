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
#	Authors: 	Eric van den Berg
#	Date: 	10.10.2015
#
#	Last change: Eric van den Berg	
#	Date:	12.12.2015	
#

var COLORfd = {};
COLORfd["menuns"] = "#00940032";
COLORfd["menuse"] = "#0055d432";
COLORfd["AilOk"] = "#c7f291";
COLORfd["EleOk"] = "#7af4b9";
COLORfd["RudOk"] = "#00f4ff";
COLORfd["TriOk"] = "#7ad2b9";
COLORfd["GeaOk"] = "#00a2ff";
COLORfd["BraOk"] = "#bba9ff";
COLORfd["TyrOk"] = "#8cd0ff";
COLORfd["auxOk"] = "#d4aa00";
COLORfd["mainOk"] = "#ffcc00";
COLORfd["colOk"] = "#ffdd55";
COLORfd["CVOk"] = "#00ff004a";
COLORfd["SVok"] = "#00800059";
COLORfd["Failed"] = "#ff8080ff";

var FailureClass = {
	new : func(){
		var m = {parents:[FailureClass]};

		m._title = 'Extra500 Failure Dialog';
		m._gfd 	= nil;
		m._canvas	= nil;

		return m;
	},
	openDialog : func(){
		# making window
		me._gfd = MyWindow.new([750,512],"dialog");
		me._gfd._onClose = func(){Failuredialog._onClose();}

		me._gfd.set('title',me._title);
		me._canvas = me._gfd.createCanvas().set("background", canvas.style.getColor("bg_color"));
           	me._root = me._canvas.createGroup();
		
		# parsing svg-s
		me._filename = "/Dialogs/MenuFaildialog.svg";
		me._svg_menu = me._root.createChild('group');
		canvas.parsesvg(me._svg_menu, me._filename);

		me._filename = "/Dialogs/welcomeFaildialog.svg";
		me._svg_welcome = me._root.createChild('group');
		canvas.parsesvg(me._svg_welcome, me._filename);

		me._filename = "/Dialogs/GearFaildialog.svg";
		me._svg_gear = me._root.createChild('group');
		canvas.parsesvg(me._svg_gear, me._filename);

		me._filename = "/Dialogs/FuelFaildialog.svg";
		me._svg_fuel = me._root.createChild('group');
		canvas.parsesvg(me._svg_fuel, me._filename);

		me._filename = "/Dialogs/ControlsFaildialog.svg";
		me._svg_contr = me._root.createChild('group');
		canvas.parsesvg(me._svg_contr, me._filename);

# defining clickable fields and other elements from svg files
	# menu
		me._gear		= me._svg_menu.getElementById("field_gear");
		me._gear_ind	= me._svg_menu.getElementById("gearfailind").hide();
		me._fuel		= me._svg_menu.getElementById("field_fuel");
		me._fuel_ind	= me._svg_menu.getElementById("fuelfailind").hide();
		me._controls	= me._svg_menu.getElementById("field_controls");
		me._controls_ind	= me._svg_menu.getElementById("controlsfailind").hide();

		me._repair		= me._svg_menu.getElementById("field_repairall");

	# gear
		me._LHgear		= me._svg_gear.getElementById("LHgear");
		me._RHgear		= me._svg_gear.getElementById("RHgear");
		me._Ngear		= me._svg_gear.getElementById("Ngear");
		me._LHbrake		= me._svg_gear.getElementById("LHbrake");
		me._RHbrake		= me._svg_gear.getElementById("RHbrake");
		me._LHtyre		= me._svg_gear.getElementById("LHtyre");
		me._RHtyre		= me._svg_gear.getElementById("RHtyre");
		me._Ntyre		= me._svg_gear.getElementById("Ntyre");

		me._Text_LHgear		= me._svg_gear.getElementById("text_LHgear").hide();
		me._Text_RHgear		= me._svg_gear.getElementById("text_RHgear").hide();
		me._Text_Ngear		= me._svg_gear.getElementById("text_Ngear").hide();
		me._Text_LHbrake		= me._svg_gear.getElementById("text_LHbrake").hide();
		me._Text_RHbrake		= me._svg_gear.getElementById("text_RHbrake").hide();
		me._Text_LHtyre		= me._svg_gear.getElementById("text_LHtyre").hide();
		me._Text_RHtyre		= me._svg_gear.getElementById("text_RHtyre").hide();
		me._Text_Ntyre		= me._svg_gear.getElementById("text_Ntyre").hide();

	# fuel
		me._Laux		= me._svg_fuel.getElementById("Laux");
		me._Lmain		= me._svg_fuel.getElementById("Lmain");
		me._Lcol		= me._svg_fuel.getElementById("Lcol");
		me._Rcol		= me._svg_fuel.getElementById("Rcol");
		me._Rmain		= me._svg_fuel.getElementById("Rmain");
		me._Raux		= me._svg_fuel.getElementById("Raux");
		me._LCV		= me._svg_fuel.getElementById("LHcheckvalve");
		me._RCV		= me._svg_fuel.getElementById("RHcheckvalve");
		me._LCV_field	= me._svg_fuel.getElementById("LHcvfield");
		me._RCV_field	= me._svg_fuel.getElementById("RHcvfield");
		me._SelValve	= me._svg_fuel.getElementById("selectorValve");
		me._Filter		= me._svg_fuel.getElementById("filter");
		me._pump1		= me._svg_fuel.getElementById("pump1");
		me._pump2		= me._svg_fuel.getElementById("pump2");
		me._pumpcv1		= me._svg_fuel.getElementById("pumpcv1");
		me._pumpcv2		= me._svg_fuel.getElementById("pumpcv2");
		me._FFtransd	= me._svg_fuel.getElementById("fftransd");

		me._Text_Laux		= me._svg_fuel.getElementById("text_Laux").hide();
		me._Text_Lmain		= me._svg_fuel.getElementById("text_Lmain").hide();
		me._Text_Lcol		= me._svg_fuel.getElementById("text_Lcol").hide();
		me._Text_Raux		= me._svg_fuel.getElementById("text_Raux").hide();
		me._Text_Rmain		= me._svg_fuel.getElementById("text_Rmain").hide();
		me._Text_Rcol		= me._svg_fuel.getElementById("text_Rcol").hide();
		me._Text_Filter		= me._svg_fuel.getElementById("text_filter").hide();
		me._Text_LCV		= me._svg_fuel.getElementById("text_LCV").hide();
		me._Text_RCV		= me._svg_fuel.getElementById("text_RCV").hide();
		me._Text_SelValve		= me._svg_fuel.getElementById("text_selectorValve").hide();
		me._Text_pump1		= me._svg_fuel.getElementById("text_pump1").hide();
		me._Text_pump2		= me._svg_fuel.getElementById("text_pump2").hide();
		me._Text_pumpcv1		= me._svg_fuel.getElementById("text_pumpcv1").hide();
		me._Text_pumpcv2		= me._svg_fuel.getElementById("text_pumpcv2").hide();
		me._Text_FFtransd		= me._svg_fuel.getElementById("text_fftransd").hide();

	# control system
		me._LAileron	= me._svg_contr.getElementById("LAileron");
		me._RAileron	= me._svg_contr.getElementById("RAileron");
		me._Elevator	= me._svg_contr.getElementById("layer4");
		me._LElevator	= me._svg_contr.getElementById("Lelevator");
		me._RElevator	= me._svg_contr.getElementById("Relevator");
		me._Flaps		= me._svg_contr.getElementById("layer5");
		me._ElevatorTrim	= me._svg_contr.getElementById("elevatorTrim");
		me._Rudder		= me._svg_contr.getElementById("rudder");

		me._Text_LAil	= me._svg_contr.getElementById("text_LHAil");
		me._Text_RAil	= me._svg_contr.getElementById("text_RHAil");
		me._Text_Elevator	= me._svg_contr.getElementById("text_Elevator").hide();
		me._Text_flaps	= me._svg_contr.getElementById("text_Flaps").hide();
		me._Text_Rudder	= me._svg_contr.getElementById("text_Rudder").hide();
		me._Text_Trim	= me._svg_contr.getElementById("text_Trim").hide();

# additional elements
	#number of failure indication in menu
		me._gearfailnumber = me._root.createChild("text")
      		.setFontSize(10, 0.9)         
      		.setAlignment("center-center") 
      		.setTranslation(106, 23);

		me._fuelfailnumber = me._root.createChild("text")
      		.setFontSize(10, 0.9)        
      		.setAlignment("center-center") 
      		.setTranslation(198, 23);

		me._controlsfailnumber = me._root.createChild("text")
      		.setFontSize(10, 0.9)  
      		.setAlignment("center-center") 
      		.setTranslation(346, 23);     

# listeners
		me.setListeners(instance = me);

# initialisation
		me._menuReset();
		me._hideAll();

		me._svg_welcome.show();
		me._svg_menu.show();
		me._updateMenu();

	},
	_onClose : func(){
		me._gfd.del();	
	},
	setListeners : func(instance) {
	# menu
		me._gear.addEventListener("click",func(){me._onGearClick();});
		me._fuel.addEventListener("click",func(){me._onFuelClick();});
		me._controls.addEventListener("click",func(){me._onControlsClick();});
		me._repair.addEventListener("click",func(){
			events.failure_reset();					# nasal/failurescenarios.nas
			me._fuelButtons_update();
			me._gearButtons_update();
			me._contrButtons_update();
		});


	# gear
		me._LHgear.addEventListener("click",func(){me._onGeneralClick("/systems/gear/LMG-free",0,"LMG_jammed","GeaOk",me._LHgear,me._Text_LHgear);});
		me._RHgear.addEventListener("click",func(){me._onGeneralClick("/systems/gear/RMG-free",0,"RMG_jammed","GeaOk",me._RHgear,me._Text_RHgear);});
		me._Ngear.addEventListener("click",func(){me._onGeneralClick("/systems/gear/NG-free",0,"NG_jammed","GeaOk",me._Ngear,me._Text_Ngear);});
		me._LHbrake.addEventListener("click",func(){me._onGeneralClick("/fdm/jsbsim/gear/unit[1]/brakeFail",1,"Lbrake","BraOk",me._LHbrake,me._Text_LHbrake);});
		me._RHbrake.addEventListener("click",func(){me._onGeneralClick("/fdm/jsbsim/gear/unit[2]/brakeFail",1,"Rbrake","BraOk",me._RHbrake,me._Text_RHbrake);});
		me._LHtyre.addEventListener("click",func(){me._onGeneralClick("/fdm/jsbsim/gear/unit[1]/flatTire",1,"LMG_flat","TyrOk",me._LHtyre,me._Text_LHtyre);});
		me._RHtyre.addEventListener("click",func(){me._onGeneralClick("/fdm/jsbsim/gear/unit[2]/flatTire",1,"RMG_flat","TyrOk",me._RHtyre,me._Text_RHtyre);});
		me._Ntyre.addEventListener("click",func(){me._onGeneralClick("/fdm/jsbsim/gear/unit[0]/flatTire",1,"NG_flat","TyrOk",me._Ntyre,me._Text_Ntyre);});

	# fuel
		me._Laux.addEventListener("click",func(){me._onGeneralClick("/systems/fuel/LHtank/aux/leakage/state",1,"LAux_leakage","auxOk",me._Laux,me._Text_Laux);});
		me._Lmain.addEventListener("click",func(){me._onGeneralClick("/systems/fuel/LHtank/main/leakage/state",1,"LMain_leakage","mainOk",me._Lmain,me._Text_Lmain);});
		me._Lcol.addEventListener("click",func(){me._onGeneralClick("/systems/fuel/LHtank/collector/leakage/state",1,"LCol_leakage","colOk",me._Lcol,me._Text_Lcol);});
		me._Raux.addEventListener("click",func(){me._onGeneralClick("/systems/fuel/RHtank/aux/leakage/state",1,"RAux_leakage","auxOk",me._Raux,me._Text_Raux);});
		me._Rmain.addEventListener("click",func(){me._onGeneralClick("/systems/fuel/RHtank/main/leakage/state",1,"RMain_leakage","mainOk",me._Rmain,me._Text_Rmain);});
		me._Rcol.addEventListener("click",func(){me._onGeneralClick("/systems/fuel/RHtank/collector/leakage/state",1,"RCol_leakage","colOk",me._Rcol,me._Text_Rcol);});
		me._LCV.addEventListener("click",func(){me._onGeneralClick("/systems/fuel/LHtank/checkvalve/serviceable",0,"LcheckvalveFail","CVOk",me._LCV_field,me._Text_LCV);});
		me._RCV.addEventListener("click",func(){me._onGeneralClick("/systems/fuel/RHtank/checkvalve/serviceable",0,"RcheckvalveFail","CVOk",me._RCV_field,me._Text_RCV);});
		me._Filter.addEventListener("click",func(){me._onValueClick("/systems/fuel/fuelfilter/clogged","filterFail","CVOk",me._Filter,me._Text_Filter);});
		me._SelValve.addEventListener("click",func(){me._onGeneralClick("/systems/fuel/selectorValve/serviceable",0,"SelectorValveFail","CVOk",me._SelValve,me._Text_SelValve);});
		me._pump1.addEventListener("click",func(){me._onGeneralClick("/systems/fuel/FuelPump1/serviceable",0,"fuelPump1Fail","CVOk",me._pump1,me._Text_pump1);});
		me._pump2.addEventListener("click",func(){me._onGeneralClick("/systems/fuel/FuelPump2/serviceable",0,"fuelPump2Fail","CVOk",me._pump2,me._Text_pump2);});
		me._pumpcv1.addEventListener("click",func(){me._onGeneralClick("/systems/fuel/FP1checkvalve/serviceable",0,"fuelPumpCV1Fail","CVOk",me._pumpcv1,me._Text_pumpcv1);});
		me._pumpcv2.addEventListener("click",func(){me._onGeneralClick("/systems/fuel/FP2checkvalve/serviceable",0,"fuelPumpCV2Fail","CVOk",me._pumpcv2,me._Text_pumpcv2);});
		me._FFtransd.addEventListener("click",func(){me._onValueClick("/systems/fuel/FFtransducer/blocked","fftransdFail","CVOk",me._FFtransd,me._Text_FFtransd);});

	# control system
		me._LAileron.addEventListener("click",func(){me._onGeneralClick("/extra500/failurescenarios/controls/L-aileron",1,"LAil","AilOk",me._LAileron,me._Text_LAil);});
		me._RAileron.addEventListener("click",func(){me._onGeneralClick("/extra500/failurescenarios/controls/R-aileron",1,"RAil","AilOk",me._RAileron,me._Text_RAil);});
		me._Elevator.addEventListener("click",func(){me._onElevatorClick();});
		me._Flaps.addEventListener("click",func(){me._onFlapsClick();});
		me._Rudder.addEventListener("click",func(){me._onGeneralClick("/extra500/failurescenarios/controls/rudder",1,"Rudder","RudOk",me._Rudder,me._Text_Rudder);});
		me._ElevatorTrim.addEventListener("click",func(){me._onGeneralClick("/extra500/failurescenarios/controls/trim",1,"Trim","TriOk",me._ElevatorTrim,me._Text_Trim);});
	},
	_menuReset : func() {
		me._gear.setColorFill(COLORfd["menuns"]);
		me._fuel.setColorFill(COLORfd["menuns"]);
		me._controls.setColorFill(COLORfd["menuns"]);
	},
	_hideAll : func() {   # except for menu
		me._svg_gear.hide();
		me._svg_fuel.hide();
		me._svg_contr.hide();
		me._svg_welcome.hide();
	},
	_updateMenu : func() {
		me._gearButtons_update();
		me._fuelButtons_update();
		me._contrButtons_update();
	},
	_onGearClick : func() {
		me._menuReset();
		me._gear.setColorFill(COLORfd["menuse"]);
		me._hideAll();
		me._svg_gear.show();
		me._gearButtons_update();
	},
	_onFuelClick : func() {
		me._menuReset();
		me._fuel.setColorFill(COLORfd["menuse"]);
		me._hideAll();
		me._svg_fuel.show();
		me._fuelButtons_update();
	},
	_onControlsClick : func() {
		me._menuReset();
		me._controls.setColorFill(COLORfd["menuse"]);
		me._hideAll();
		me._svg_contr.show();
		me._contrButtons_update();
	},
	_genButtons_update : func(gfailprop,glogic,gfield,gtext,gcolor,gfail) {			# for 'servicable' values, so glogic 0 or 1
		if ( getprop(gfailprop) == glogic ) {
			gfield.setColorFill(COLORfd[gcolor]);
			gtext.hide();
		} else {
			gfield.setColorFill(COLORfd["Failed"]);
			gtext.show();
			setprop(gfail,getprop(gfail) + 1);
		}
	},
	_valButtons_update : func(gfailprop,gfield,gtext,gcolor,gfail) {				# for step values between 0-1
		if ( getprop(gfailprop) == 0 ) {
			gfield.setColorFill(COLORfd[gcolor]);
			gtext.hide();
		} else {
			gfield.setColorFill(COLORfd["Failed"]);
			gtext.show();
			setprop(gfail,getprop(gfail) + 1);
		}
	},
	_fuelButtons_update : func() {
		setprop("/extra500/failurescenarios/fuel",0);
		me._genButtons_update("/systems/fuel/LHtank/aux/leakage/state",0,me._Laux,me._Text_Laux,"auxOk","/extra500/failurescenarios/fuel");
		me._genButtons_update("/systems/fuel/LHtank/main/leakage/state",0,me._Lmain,me._Text_Lmain,"mainOk","/extra500/failurescenarios/fuel");
		me._genButtons_update("/systems/fuel/LHtank/collector/leakage/state",0,me._Lcol,me._Text_Lcol,"colOk","/extra500/failurescenarios/fuel");
		me._genButtons_update("/systems/fuel/RHtank/aux/leakage/state",0,me._Raux,me._Text_Raux,"auxOk","/extra500/failurescenarios/fuel");
		me._genButtons_update("/systems/fuel/RHtank/main/leakage/state",0,me._Rmain,me._Text_Rmain,"mainOk","/extra500/failurescenarios/fuel");
		me._genButtons_update("/systems/fuel/RHtank/collector/leakage/state",0,me._Rcol,me._Text_Rcol,"colOk","/extra500/failurescenarios/fuel");
		me._genButtons_update("/systems/fuel/LHtank/checkvalve/serviceable",1,me._LCV_field,me._Text_LCV,"CVOk","/extra500/failurescenarios/fuel");
		me._genButtons_update("/systems/fuel/RHtank/checkvalve/serviceable",1,me._RCV_field,me._Text_RCV,"CVOk","/extra500/failurescenarios/fuel");
		me._genButtons_update("/systems/fuel/selectorValve/serviceable",1,me._SelValve,me._Text_SelValve,"CVOk","/extra500/failurescenarios/fuel");
		me._valButtons_update("/systems/fuel/fuelfilter/clogged",me._Filter,me._Text_Filter,"CVOk","/extra500/failurescenarios/fuel");
		me._genButtons_update("/systems/fuel/FuelPump1/serviceable",1,me._pump1,me._Text_pump1,"CVOk","/extra500/failurescenarios/fuel");
		me._genButtons_update("/systems/fuel/FuelPump2/serviceable",1,me._pump2,me._Text_pump2,"CVOk","/extra500/failurescenarios/fuel");
		me._genButtons_update("/systems/fuel/FP1checkvalve/serviceable",1,me._pumpcv1,me._Text_pumpcv1,"CVOk","/extra500/failurescenarios/fuel");
		me._genButtons_update("/systems/fuel/FP2checkvalve/serviceable",1,me._pumpcv2,me._Text_pumpcv2,"CVOk","/extra500/failurescenarios/fuel");
		me._valButtons_update("/systems/fuel/FFtransducer/blocked",me._FFtransd,me._Text_FFtransd,"CVOk","/extra500/failurescenarios/fuel");

		# setting fail indication in menu
		if (getprop("/extra500/failurescenarios/fuel") > 0) {
			me._fuel_ind.show();
			me._fuelfailnumber.setText(getprop("/extra500/failurescenarios/fuel"))
				.setColor(1,1,1,1);		
		} else {
			me._fuel_ind.hide();
			me._fuelfailnumber.setColor(1,1,1,0);
		}

	},
	_gearButtons_update : func() {
		setprop("/extra500/failurescenarios/gear",0);
		me._genButtons_update("/systems/gear/NG-free",1,me._Ngear,me._Text_Ngear,"GeaOk","/extra500/failurescenarios/gear");
		me._genButtons_update("/systems/gear/RMG-free",1,me._RHgear,me._Text_RHgear,"GeaOk","/extra500/failurescenarios/gear");
		me._genButtons_update("/systems/gear/LMG-free",1,me._LHgear,me._Text_LHgear,"GeaOk","/extra500/failurescenarios/gear");

		me._genButtons_update("/fdm/jsbsim/gear/unit[0]/flatTire",0,me._Ntyre,me._Text_Ntyre,"TyrOk","/extra500/failurescenarios/gear");
		me._genButtons_update("/fdm/jsbsim/gear/unit[1]/flatTire",0,me._LHtyre,me._Text_LHtyre,"TyrOk","/extra500/failurescenarios/gear");
		me._genButtons_update("/fdm/jsbsim/gear/unit[2]/flatTire",0,me._RHtyre,me._Text_RHtyre,"TyrOk","/extra500/failurescenarios/gear");

		me._genButtons_update("/fdm/jsbsim/gear/unit[1]/brakeFail",0,me._LHbrake,me._Text_LHbrake,"BraOk","/extra500/failurescenarios/gear");
		me._genButtons_update("/fdm/jsbsim/gear/unit[2]/brakeFail",0,me._RHbrake,me._Text_RHbrake,"BraOk","/extra500/failurescenarios/gear");

		# setting fail indication in menu
		if (getprop("/extra500/failurescenarios/gear") > 0) {
			me._gear_ind.show();
			me._gearfailnumber.setText(getprop("/extra500/failurescenarios/gear"))
				.setColor(1,1,1,1);		
		} else {
			me._gear_ind.hide();
			me._gearfailnumber.setColor(1,1,1,0);
		}

	},
	_contrButtons_update : func() {
		setprop("/extra500/failurescenarios/contr",0);
		me._genButtons_update("/extra500/failurescenarios/controls/L-aileron",0,me._LAileron,me._Text_LAil,"AilOk","/extra500/failurescenarios/contr");
		me._genButtons_update("/extra500/failurescenarios/controls/R-aileron",0,me._RAileron,me._Text_RAil,"AilOk","/extra500/failurescenarios/contr");
		me._genButtons_update("/extra500/failurescenarios/controls/rudder",0,me._Rudder,me._Text_Rudder,"RudOk","/extra500/failurescenarios/contr");
		me._genButtons_update("/extra500/failurescenarios/controls/trim",0,me._ElevatorTrim,me._Text_Trim,"TriOk","/extra500/failurescenarios/contr");

		if ( getprop("/extra500/failurescenarios/controls/elevator") == 0 ) {
			me._LElevator.setColorFill(COLORfd["EleOk"]);
			me._RElevator.setColorFill(COLORfd["EleOk"]);
			me._Text_Elevator.hide();
		} else {
			me._LElevator.setColorFill(COLORfd["Failed"]);
			me._RElevator.setColorFill(COLORfd["Failed"]);
			me._Text_Elevator.show();
			setprop("/extra500/failurescenarios/contr",getprop("/extra500/failurescenarios/contr") + 1);
		}

		# setting fail indication in menu
		if (getprop("/extra500/failurescenarios/contr") > 0) {
			me._controls_ind.show();
			me._controlsfailnumber.setText(getprop("/extra500/failurescenarios/contr"))
				.setColor(1,1,1,1);
		} else {
			me._controls_ind.hide();
			me._controlsfailnumber.setColor(1,1,1,0);
		}

	},
	_onElevatorClick : func(){
		if (getprop("/extra500/failurescenarios/controls/elevator") == 1) {
			setprop("/extra500/failurescenarios/name","Elevator");
			setprop("/extra500/failurescenarios/activate",0);
			me._LElevator.setColorFill(COLORfd["EleOk"]);
			me._RElevator.setColorFill(COLORfd["EleOk"]);
			me._Text_Elevator.hide();
			me._updateMenu();
		} else {
			setprop("/extra500/failurescenarios/name","Elevator");
			setprop("/extra500/failurescenarios/activate",1);
			me._LElevator.setColorFill(COLORfd["Failed"]);
			me._RElevator.setColorFill(COLORfd["Failed"]);
			me._Text_Elevator.show();
			me._updateMenu();
		}
	},
	_onGeneralClick : func(property,logic,failname,color,field,text){			# for 'servicable' values, so logic 0 or 1
		setprop("/extra500/failurescenarios/name",failname);
		if (getprop(property) == logic) {
			setprop("/extra500/failurescenarios/activate",0);
			field.setColorFill(COLORfd[color]);
			text.hide();
		} else {
			setprop("/extra500/failurescenarios/activate",1);
			field.setColorFill(COLORfd["Failed"]);
			text.show();
		}
		me._updateMenu();
	},
	_onValueClick : func(property,failname,color,field,text){				# for step values between 0-1
		setprop("/extra500/failurescenarios/name",failname);
		var value = getprop(property) + 0.1;
		if (value>1) {value = 0;}
		setprop("/extra500/failurescenarios/activate",value);
		if (value==0) {
			field.setColorFill(COLORfd[color]);
			text.hide();
		} else {
			field.setColorFill(COLORfd["Failed"]);
			text.show();
		}
		me._updateMenu();
	},
	_onFlapsClick : func(){
print("clicked on flaps");
		me._Text_flaps.show();
	}

};

var Failuredialog = FailureClass.new();




