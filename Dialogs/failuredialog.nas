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
#	Date:	21.11.2015	
#

var COLORfd = {};
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
COLORfd["Failed"] = "#ff8080";

var FailureClass = {
	new : func(){
		var m = {parents:[FailureClass]};

		m._title = 'Extra500 Failure Dialog';
		m._gfd 	= nil;
		m._canvas	= nil;

		return m;
	},
	openDialog : func(){
		me._gfd = MyWindow.new([750,512],"dialog");
		me._gfd._onClose = func(){Failuredialog._onClose();}

		me._gfd.set('title',me._title);
		me._canvas = me._gfd.createCanvas().set("background", canvas.style.getColor("bg_color"));
           	me._root = me._canvas.createGroup();

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

# defining clickable fields
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

		me._Text_Laux		= me._svg_fuel.getElementById("text_Laux").hide();
		me._Text_Lmain		= me._svg_fuel.getElementById("text_Lmain").hide();
		me._Text_Lcol		= me._svg_fuel.getElementById("text_Lcol").hide();
		me._Text_Raux		= me._svg_fuel.getElementById("text_Raux").hide();
		me._Text_Rmain		= me._svg_fuel.getElementById("text_Rmain").hide();
		me._Text_Rcol		= me._svg_fuel.getElementById("text_Rcol").hide();

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

# setting listeners on clickable fields

		me.setListeners(instance = me);

		me._Layout1 = canvas.VBoxLayout.new();
		me._canvas.setLayout(me._Layout1);

# MENU
		me._button_Gear = canvas.gui.widgets.Button.new(me._root, canvas.style, {})
       		.setCheckable(1) 
       		.setChecked( getprop("/extra500/failurescenarios/gear") ) 
        		.setFixedSize(80,30);

		if ( getprop("/extra500/failurescenarios/gear") == 1 ) {
			me._button_Gear.setText("GEAR");
		} else {
			me._button_Gear.setText("gear");
		}

		me._button_Gear.listen("toggled", func (e) {
        		if( e.detail.checked ) {
				me._menuButtonsReset();
				me._button_Gear.setText("GEAR");
				setprop("/extra500/failurescenarios/gear",1);
				me._hideAll();
				me._svg_gear.show();
				me._gearButtons_update();
        		} else {
				me._gearButtons_update();
				me._button_Gear.setChecked(1);
        		}
    		});

		me._button_Fuel = canvas.gui.widgets.Button.new(me._root, canvas.style, {})
       		.setCheckable(1) 
       		.setChecked( getprop("/extra500/failurescenarios/fuel") ) 
        		.setFixedSize(80,30);

		if ( getprop("/extra500/failurescenarios/fuel") == 1 ) {
			me._button_Fuel.setText("FUEL");
		} else {
			me._button_Fuel.setText("fuel");
		}

		me._button_Fuel.listen("toggled", func (e) {
        		if( e.detail.checked ) {
				me._menuButtonsReset();
				me._button_Fuel.setText("FUEL");
				setprop("/extra500/failurescenarios/fuel",1);
				me._hideAll();
				me._svg_fuel.show();
				me._fuelButtons_update();
        		} else {
				me._fuelButtons_update();
				me._button_Fuel.setChecked(1);
        		}
    		});

		me._button_Contr = canvas.gui.widgets.Button.new(me._root, canvas.style, {})
       		.setCheckable(1) 
       		.setChecked( getprop("/extra500/failurescenarios/contr") ) 
        		.setFixedSize(100,30);

		if ( getprop("/extra500/failurescenarios/contr") == 1 ) {
			me._button_Contr.setText("CONTROLS");
		} else {
			me._button_Contr.setText("controls");
		}

		me._button_Contr.listen("toggled", func (e) {
        		if( e.detail.checked ) {
				me._menuButtonsReset();
				me._button_Contr.setText("CONTROLS");
				setprop("/extra500/failurescenarios/contr",1);
				me._hideAll();
				me._svg_contr.show();
				me._contrButtons_update();
        		} else {
				me._contrButtons_update();
				me._button_Contr.setChecked(1);
        		}
    		});

		me._button_Reset = canvas.gui.widgets.Button.new(me._root, canvas.style, {})
        		.setFixedSize(90,30)
			.setText("REPAIR ALL");

		me._button_Reset.listen("clicked", func (e) {
			events.failure_reset();					# nasal/failurescenarios.nas

			me._fuelButtons_update();
			me._gearButtons_update();
			me._contrButtons_update();
    		});

		var hbox_menu = canvas.HBoxLayout.new();
		hbox_menu.addItem(me._button_Gear);
		hbox_menu.addItem(me._button_Fuel);
		hbox_menu.addItem(me._button_Contr);
		hbox_menu.addStretch(1);
		hbox_menu.addItem(me._button_Reset);

#adding vboxes to layout (a vbox)
		me._Layout1.addItem(hbox_menu);
		me._Layout1.addStretch(1);

		me._menuButtonsReset();
		me._hideAll();
		me._svg_welcome.show();

	},
	_onClose : func(){
		me._gfd.del();	
	},
	setListeners : func(instance) {
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

	# control system
		me._LAileron.addEventListener("click",func(){me._onGeneralClick("/extra500/failurescenarios/controls/L-aileron",1,"LAil","AilOk",me._LAileron,me._Text_LAil);});
		me._RAileron.addEventListener("click",func(){me._onGeneralClick("/extra500/failurescenarios/controls/R-aileron",1,"RAil","AilOk",me._RAileron,me._Text_RAil);});
		me._Elevator.addEventListener("click",func(){me._onElevatorClick();});
		me._Flaps.addEventListener("click",func(){me._onFlapsClick();});
		me._ElevatorTrim.addEventListener("click",func(){me._onElevatorTrimClick();});
		me._Rudder.addEventListener("click",func(){me._onRudderClick();});
	},
	_menuButtonsReset : func() {
		setprop("/extra500/failurescenarios/welcome",0);

		setprop("/extra500/failurescenarios/fuel",0);
		me._button_Fuel.setChecked(0);
		me._button_Fuel.setText("fuel");

		setprop("/extra500/failurescenarios/gear",0);
		me._button_Gear.setChecked(0);
		me._button_Gear.setText("gear");

		setprop("/extra500/failurescenarios/contr",0);
		me._button_Contr.setChecked(0);
		me._button_Contr.setText("controls");

	},
	_hideAll : func() {
		me._svg_gear.hide();
		me._svg_fuel.hide();
		me._svg_contr.hide();
		me._svg_welcome.hide();
	},
	_genButtons_update : func(gfailprop,glogic,gfield,gtext,gcolor) {
		if ( getprop(gfailprop) == glogic ) {
			gfield.setColorFill(COLORfd[gcolor]);
			gtext.hide();
		} else {
			gfield.setColorFill(COLORfd["Failed"]);
			gtext.show();
		}
	},
	_fuelButtons_update : func() {

		me._genButtons_update("/systems/fuel/LHtank/aux/leakage/state",0,me._Laux,me._Text_Laux,"auxOk");
		me._genButtons_update("/systems/fuel/LHtank/main/leakage/state",0,me._Lmain,me._Text_Lmain,"mainOk");
		me._genButtons_update("/systems/fuel/LHtank/collector/leakage/state",0,me._Lcol,me._Text_Lcol,"colOk");
		me._genButtons_update("/systems/fuel/RHtank/aux/leakage/state",0,me._Raux,me._Text_Raux,"auxOk");
		me._genButtons_update("/systems/fuel/RHtank/main/leakage/state",0,me._Rmain,me._Text_Rmain,"mainOk");
		me._genButtons_update("/systems/fuel/RHtank/collector/leakage/state",0,me._Rcol,me._Text_Rcol,"colOk");

	},
	_gearButtons_update : func() {

		me._genButtons_update("/systems/gear/NG-free",1,me._Ngear,me._Text_Ngear,"GeaOk");
		me._genButtons_update("/systems/gear/RMG-free",1,me._RHgear,me._Text_RHgear,"GeaOk");
		me._genButtons_update("/systems/gear/LMG-free",1,me._LHgear,me._Text_LHgear,"GeaOk");

		me._genButtons_update("/fdm/jsbsim/gear/unit[0]/flatTire",0,me._Ntyre,me._Text_Ntyre,"TyrOk");
		me._genButtons_update("/fdm/jsbsim/gear/unit[1]/flatTire",0,me._LHtyre,me._Text_LHtyre,"TyrOk");
		me._genButtons_update("/fdm/jsbsim/gear/unit[2]/flatTire",0,me._RHtyre,me._Text_RHtyre,"TyrOk");

		me._genButtons_update("/fdm/jsbsim/gear/unit[1]/brakeFail",0,me._LHbrake,me._Text_LHbrake,"BraOk");
		me._genButtons_update("/fdm/jsbsim/gear/unit[2]/brakeFail",0,me._RHbrake,me._Text_RHbrake,"BraOk");

	},
	_contrButtons_update : func() {

		me._genButtons_update("/extra500/failurescenarios/controls/L-aileron",0,me._LAileron,me._Text_LAil,"AilOk");
		me._genButtons_update("/extra500/failurescenarios/controls/R-aileron",0,me._RAileron,me._Text_RAil,"AilOk");

		if ( getprop("/extra500/failurescenarios/controls/elevator") == 0 ) {
			me._LElevator.setColorFill(COLORfd["EleOk"]);
			me._RElevator.setColorFill(COLORfd["EleOk"]);
			me._Text_Elevator.hide();
		} else {
			me._LElevator.setColorFill(COLORfd["Failed"]);
			me._RElevator.setColorFill(COLORfd["Failed"]);
			me._Text_Elevator.show();
		}

	},
	_onElevatorClick : func(){
		if (getprop("/extra500/failurescenarios/controls/elevator") == 1) {
			setprop("/extra500/failurescenarios/name","Elevator");
			setprop("/extra500/failurescenarios/activate",0);
			me._LElevator.setColorFill(COLORfd["EleOk"]);
			me._RElevator.setColorFill(COLORfd["EleOk"]);
			me._Text_Elevator.hide();
		} else {
			setprop("/extra500/failurescenarios/name","Elevator");
			setprop("/extra500/failurescenarios/activate",1);
			me._LElevator.setColorFill(COLORfd["Failed"]);
			me._RElevator.setColorFill(COLORfd["Failed"]);
			me._Text_Elevator.show();
		}
	},
	_onGeneralClick : func(property,logic,failname,color,field,text){
		if (getprop(property) == logic) {
			setprop("/extra500/failurescenarios/name",failname);
			setprop("/extra500/failurescenarios/activate",0);
			field.setColorFill(COLORfd[color]);
			text.hide();
		} else {
			setprop("/extra500/failurescenarios/name",failname);
			setprop("/extra500/failurescenarios/activate",1);
			field.setColorFill(COLORfd["Failed"]);
			text.show();
		}
	},
	_onFlapsClick : func(){
print("clicked on flaps");
		me._Text_flaps.show();
	},
	_onElevatorTrimClick : func(){
print("clicked on elevator trim");
	},
	_onRudderClick : func(){
print("clicked on rudder");
	},

};

var Failuredialog = FailureClass.new();




