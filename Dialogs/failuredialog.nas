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
#	Date:	14.11.2015	
#

var COLORfd = {};
COLORfd["AilOk"] = "#c7f291";
COLORfd["EleOk"] = "#7af4b9";
COLORfd["RudOk"] = "#00f4ff";
COLORfd["TriOk"] = "#7ad2b9";
COLORfd["Failed"] = "#ff2a2a";

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
		me._LAileron	= me._svg_contr.getElementById("LAileron");
		me._RAileron	= me._svg_contr.getElementById("RAileron");
		me._Text_LAil	= me._svg_contr.getElementById("text_LHAil");
		me._Text_RAil	= me._svg_contr.getElementById("text_RHAil");
		me._Elevator	= me._svg_contr.getElementById("layer4");
		me._LElevator	= me._svg_contr.getElementById("Lelevator");
		me._RElevator	= me._svg_contr.getElementById("Relevator");
		me._Text_Elevator	= me._svg_contr.getElementById("text_Elevator").hide();
		me._Flaps		= me._svg_contr.getElementById("layer5");
		me._Text_flaps	= me._svg_contr.getElementById("text_Flaps").hide();
		me._ElevatorTrim	= me._svg_contr.getElementById("elevatorTrim");
		me._Rudder		= me._svg_contr.getElementById("rudder");

# setting listeners on clickable fields
		me._LAileron.addEventListener("click",func(){me._onLAileronClick();});
		me._RAileron.addEventListener("click",func(){me._onRAileronClick();});
		me._Elevator.addEventListener("click",func(){me._onElevatorClick();});
		me._Flaps.addEventListener("click",func(){me._onFlapsClick();});
		me._ElevatorTrim.addEventListener("click",func(){me._onElevatorTrimClick();});
		me._Rudder.addEventListener("click",func(){me._onRudderClick();});

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
				me._hbox_gear1.show();
				me._hbox_gear2.show();
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
				me._hbox_fuel1.show();
#				me._hbox_fuel2.show();
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

# FUEL

		me._button_LAux = canvas.gui.widgets.Button.new(me._root, canvas.style, {})
       		.setCheckable(1) 
       		.setChecked( getprop("/systems/fuel/LHtank/aux/leakage/state") ) 
        		.setFixedSize(70,25);

		me._button_LAux.listen("toggled", func (e) {
        		if( e.detail.checked ) {
				me._button_LAux.setText("LEAKING");
				setprop("/extra500/failurescenarios/name","LAux_leakage");
				setprop("/extra500/failurescenarios/activate",1);
        		} else {
				me._button_LAux.setText("ok");
				setprop("/extra500/failurescenarios/name","LAux_leakage");
				setprop("/extra500/failurescenarios/activate",0);
        		}
    		});

		me._button_LMain = canvas.gui.widgets.Button.new(me._root, canvas.style, {})
       		.setCheckable(1) 
       		.setChecked( getprop("/systems/fuel/LHtank/main/leakage/state") ) 
        		.setFixedSize(70,25);

		me._button_LMain.listen("toggled", func (e) {
        		if( e.detail.checked ) {
				me._button_LMain.setText("LEAKING");
				setprop("/extra500/failurescenarios/name","LMain_leakage");
				setprop("/extra500/failurescenarios/activate",1);
        		} else {
				me._button_LMain.setText("ok");
				setprop("/extra500/failurescenarios/name","LMain_leakage");
				setprop("/extra500/failurescenarios/activate",0);
        		}
    		});

		me._button_LCol = canvas.gui.widgets.Button.new(me._root, canvas.style, {})
       		.setCheckable(1) 
       		.setChecked( getprop("/systems/fuel/LHtank/collector/leakage/state") ) 
        		.setFixedSize(70,25);

		me._button_LCol.listen("toggled", func (e) {
        		if( e.detail.checked ) {
				me._button_LCol.setText("LEAKING");
				setprop("/extra500/failurescenarios/name","LCol_leakage");
				setprop("/extra500/failurescenarios/activate",1);
        		} else {
				me._button_LCol.setText("ok");
				setprop("/extra500/failurescenarios/name","LCol_leakage");
				setprop("/extra500/failurescenarios/activate",0);
        		}
    		});

		me._button_RCol = canvas.gui.widgets.Button.new(me._root, canvas.style, {})
       		.setCheckable(1) 
       		.setChecked( getprop("/systems/fuel/RHtank/collector/leakage/state") ) 
        		.setFixedSize(70,25);

		me._button_RCol.listen("toggled", func (e) {
        		if( e.detail.checked ) {
				me._button_RCol.setText("LEAKING");
				setprop("/extra500/failurescenarios/name","RCol_leakage");
				setprop("/extra500/failurescenarios/activate",1);
        		} else {
				me._button_RCol.setText("ok");
				setprop("/extra500/failurescenarios/name","RCol_leakage");
				setprop("/extra500/failurescenarios/activate",0);
        		}
    		});

		me._button_RMain = canvas.gui.widgets.Button.new(me._root, canvas.style, {})
       		.setCheckable(1) 
       		.setChecked( getprop("/systems/fuel/RHtank/main/leakage/state") ) 
        		.setFixedSize(70,25);

		me._button_RMain.listen("toggled", func (e) {
        		if( e.detail.checked ) {
				me._button_RMain.setText("LEAKING");
				setprop("/extra500/failurescenarios/name","RMain_leakage");
				setprop("/extra500/failurescenarios/activate",1);
        		} else {
				me._button_RMain.setText("ok");
				setprop("/extra500/failurescenarios/name","RMain_leakage");
				setprop("/extra500/failurescenarios/activate",0);
        		}
    		});

		me._button_RAux = canvas.gui.widgets.Button.new(me._root, canvas.style, {})
       		.setCheckable(1) 
       		.setChecked( getprop("/systems/fuel/RHtank/aux/leakage/state") ) 
        		.setFixedSize(70,25);

		me._button_RAux.listen("toggled", func (e) {
        		if( e.detail.checked ) {
				me._button_RAux.setText("LEAKING");
				setprop("/extra500/failurescenarios/name","RAux_leakage");
				setprop("/extra500/failurescenarios/activate",1);
        		} else {
				me._button_RAux.setText("ok");
				setprop("/extra500/failurescenarios/name","RAux_leakage");
				setprop("/extra500/failurescenarios/activate",0);
        		}
    		});

		me._hbox_fuel1 = canvas.HBoxLayout.new();
		me._hbox_fuel1.addStretch(6);
		me._hbox_fuel1.addItem(me._button_LAux);
		me._hbox_fuel1.addStretch(2);
		me._hbox_fuel1.addItem(me._button_LMain);
		me._hbox_fuel1.addStretch(2);
		me._hbox_fuel1.addItem(me._button_LCol);
		me._hbox_fuel1.addStretch(5);
		me._hbox_fuel1.addItem(me._button_RCol);
		me._hbox_fuel1.addStretch(2);
		me._hbox_fuel1.addItem(me._button_RMain);
		me._hbox_fuel1.addStretch(2);
		me._hbox_fuel1.addItem(me._button_RAux);
		me._hbox_fuel1.addStretch(6);

# GEAR

		me._button_NG = canvas.gui.widgets.Button.new(me._root, canvas.style, {})
       		.setCheckable(1) 
       		.setChecked( math.abs(getprop("/systems/gear/NG-free")-1) ) 
        		.setFixedSize(70,25);

		me._button_NG.listen("toggled", func (e) {
        		if( e.detail.checked ) {
				me._button_NG.setText("JAMMED");
				setprop("/extra500/failurescenarios/name","NG_jammed");
				setprop("/extra500/failurescenarios/activate",1);
        		} else {
				me._button_NG.setText("ok");
				setprop("/extra500/failurescenarios/name","NG_jammed");
				setprop("/extra500/failurescenarios/activate",0);
        		}
    		});


		me._button_RMG = canvas.gui.widgets.Button.new(me._root, canvas.style, {})
      	 	.setCheckable(1) 
      	 	.setChecked( math.abs(getprop("/systems/gear/RMG-free")-1) ) 
      	  	.setFixedSize(70,25);

		me._button_RMG.listen("toggled", func (e) {
	        	if( e.detail.checked ) {
				me._button_RMG.setText("JAMMED");
				setprop("/extra500/failurescenarios/name","RMG_jammed");
				setprop("/extra500/failurescenarios/activate",1);
	        	} else {
				me._button_RMG.setText("ok");
				setprop("/extra500/failurescenarios/name","RMG_jammed");
				setprop("/extra500/failurescenarios/activate",0);
	        	}
	    	});


		me._button_LMG = canvas.gui.widgets.Button.new(me._root, canvas.style, {})
	       	.setCheckable(1) 
	       	.setChecked( math.abs(getprop("/systems/gear/LMG-free")-1) ) 
	        	.setFixedSize(70,25);
	
		me._button_LMG.listen("toggled", func (e) {
	        	if( e.detail.checked ) {
				me._button_LMG.setText("JAMMED");
				setprop("/extra500/failurescenarios/name","LMG_jammed");
				setprop("/extra500/failurescenarios/activate",1);
	        	} else {
				me._button_LMG.setText("ok");
				setprop("/extra500/failurescenarios/name","LMG_jammed");
				setprop("/extra500/failurescenarios/activate",0);
	        	}
	    	});
	
		me._button_NG_flatTire = canvas.gui.widgets.Button.new(me._root, canvas.style, {})
	       	.setCheckable(1) 
	       	.setChecked( getprop("/fdm/jsbsim/gear/unit[0]/flatTire") ) 
	        	.setFixedSize(70,25);
	
		me._button_NG_flatTire.listen("toggled", func (e) {
	        	if( e.detail.checked ) {
				me._button_NG_flatTire.setText("FLAT");
				setprop("/extra500/failurescenarios/name","NG_flat");
				setprop("/extra500/failurescenarios/activate",1);
	        	} else {
				me._button_NG_flatTire.setText("ok");
				setprop("/extra500/failurescenarios/name","NG_flat");
				setprop("/extra500/failurescenarios/activate",0);
	        	}
	    	});

		me._button_RMG_flatTire = canvas.gui.widgets.Button.new(me._root, canvas.style, {})
	       	.setCheckable(1) 
	       	.setChecked( getprop("/fdm/jsbsim/gear/unit[2]/flatTire") ) 
	        	.setFixedSize(70,25);
	
		me._button_RMG_flatTire.listen("toggled", func (e) {
	        	if( e.detail.checked ) {
				me._button_RMG_flatTire.setText("FLAT");
				setprop("/extra500/failurescenarios/name","RMG_flat");
				setprop("/extra500/failurescenarios/activate",1);
	        	} else {
				me._button_RMG_flatTire.setText("ok");
				setprop("/extra500/failurescenarios/name","RMG_flat");
				setprop("/extra500/failurescenarios/activate",0);
	        	}
	    	});

		me._button_LMG_flatTire = canvas.gui.widgets.Button.new(me._root, canvas.style, {})
	       	.setCheckable(1) 
	       	.setChecked( getprop("/fdm/jsbsim/gear/unit[1]/flatTire") ) 
	        	.setFixedSize(70,25);

		me._button_LMG_flatTire.listen("toggled", func (e) {
	        	if( e.detail.checked ) {
				me._button_LMG_flatTire.setText("FLAT");
				setprop("/extra500/failurescenarios/name","LMG_flat");
				setprop("/extra500/failurescenarios/activate",1);
	        	} else {
				me._button_LMG_flatTire.setText("ok");
				setprop("/extra500/failurescenarios/name","LMG_flat");
				setprop("/extra500/failurescenarios/activate",0);
	        	}
	    	});


# gear 'jammed' buttons'
		me._hbox_gear1 = canvas.HBoxLayout.new();
		me._hbox_gear1.addStretch(3);	
		me._hbox_gear1.addItem(me._button_LMG);
		me._hbox_gear1.addStretch(1);	
		me._hbox_gear1.addItem(me._button_NG);
		me._hbox_gear1.addStretch(1);	
		me._hbox_gear1.addItem(me._button_RMG);
		me._hbox_gear1.addStretch(3);
	
# gear 'flat buttons'
		me._hbox_gear2 = canvas.HBoxLayout.new();
		me._hbox_gear2.addStretch(1);
		me._hbox_gear2.addItem(me._button_LMG_flatTire);
		me._hbox_gear2.addStretch(2);
		me._hbox_gear2.addItem(me._button_NG_flatTire);
		me._hbox_gear2.addStretch(2);
		me._hbox_gear2.addItem(me._button_RMG_flatTire);
		me._hbox_gear2.addStretch(1);

#adding vboxes to layout (a vbox)
		me._Layout1.addItem(hbox_menu);
		me._Layout1.addStretch(1);
		me._Layout1.addItem(me._hbox_fuel1);
		me._Layout1.addStretch(5);
		me._Layout1.addItem(me._hbox_gear1);
		me._Layout1.addStretch(1);
		me._Layout1.addItem(me._hbox_gear2);
		me._Layout1.addStretch(6);

		me._menuButtonsReset();
		me._hideAll();
		me._svg_welcome.show();

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
		me._hbox_gear1.hide();
		me._hbox_gear2.hide();
		me._svg_gear.hide();

		me._hbox_fuel1.hide();
		me._svg_fuel.hide();

		me._svg_contr.hide();

		me._svg_welcome.hide();
	},
	_fuelButtons_update : func() {

		if ( getprop("/systems/fuel/LHtank/aux/leakage/state") == 1 ) {
			me._button_LAux.setText("LEAKING");
		} else {
			me._button_LAux.setText("ok");
		}
		if ( getprop("/systems/fuel/LHtank/main/leakage/state") == 1 ) {
			me._button_LMain.setText("LEAKING");
		} else {
			me._button_LMain.setText("ok");
		}
		if ( getprop("/systems/fuel/LHtank/collector/leakage/state") == 1 ) {
			me._button_LCol.setText("LEAKING");
		} else {
			me._button_LCol.setText("ok");
		}
		if ( getprop("/systems/fuel/RHtank/collector/leakage/state") == 1 ) {
			me._button_RCol.setText("LEAKING");
		} else {
			me._button_RCol.setText("ok");
		}
		if ( getprop("/systems/fuel/RHtank/main/leakage/state") == 1 ) {
			me._button_RMain.setText("LEAKING");
		} else {
			me._button_RMain.setText("ok");
		}
		if ( getprop("/systems/fuel/RHtank/aux/leakage/state") == 1 ) {
			me._button_RAux.setText("LEAKING");
		} else {
			me._button_RAux.setText("ok");
		}
	},
	_gearButtons_update : func() {

		if ( getprop("/systems/gear/NG-free") == 1 ) {
			me._button_NG.setText("ok");
		} else {
			me._button_NG.setText("JAMMED");
		}
		if ( getprop("/systems/gear/RMG-free") == 1 ) {
			me._button_RMG.setText("ok");
		} else {
			me._button_RMG.setText("JAMMED");
		}
		if ( getprop("/systems/gear/LMG-free") == 1 ) {
			me._button_LMG.setText("ok");
		} else {
			me._button_LMG.setText("JAMMED");
		}
		if ( getprop("/fdm/jsbsim/gear/unit[0]/flatTire") == 0 ) {
			me._button_NG_flatTire.setText("ok");
		} else {
			me._button_NG_flatTire.setText("FLAT");
		}
		if ( getprop("/fdm/jsbsim/gear/unit[2]/flatTire") == 0 ) {
			me._button_RMG_flatTire.setText("ok");
		} else {
			me._button_RMG_flatTire.setText("FLAT");
		}
		if ( getprop("/fdm/jsbsim/gear/unit[1]/flatTire") == 0 ) {
			me._button_LMG_flatTire.setText("ok");
		} else {
			me._button_LMG_flatTire.setText("FLAT");
		}

	},
	_contrButtons_update : func() {

		if ( getprop("/extra500/failurescenarios/controls/L-aileron") == 0 ) {
			me._LAileron.setColorFill(COLORfd["AilOk"]);
			me._Text_LAil.hide();
		} else {
			me._LAileron.setColorFill(COLORfd["Failed"]);
			me._Text_LAil.show();
		}
		if ( getprop("/extra500/failurescenarios/controls/R-aileron") == 0 ) {
			me._RAileron.setColorFill(COLORfd["AilOk"]);
			me._Text_RAil.hide();
		} else {
			me._RAileron.setColorFill(COLORfd["Failed"]);
			me._Text_RAil.show();
		}
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
	_onLAileronClick : func() {
		if (getprop("/extra500/failurescenarios/controls/L-aileron") == 1) {
			setprop("/extra500/failurescenarios/name","LAil");
			setprop("/extra500/failurescenarios/activate",0);
			me._LAileron.setColorFill(COLORfd["AilOk"]);
			me._Text_LAil.hide();
		} else {
			setprop("/extra500/failurescenarios/name","LAil");
			setprop("/extra500/failurescenarios/activate",1);
			me._LAileron.setColorFill(COLORfd["Failed"]);
			me._Text_LAil.show();
		}
	},
	_onRAileronClick : func() {
		if (getprop("/extra500/failurescenarios/controls/R-aileron") == 1) {
			setprop("/extra500/failurescenarios/name","RAil");
			setprop("/extra500/failurescenarios/activate",0);
			me._RAileron.setColorFill(COLORfd["AilOk"]);
			me._Text_RAil.hide();
		} else {
			setprop("/extra500/failurescenarios/name","RAil");
			setprop("/extra500/failurescenarios/activate",1);
			me._RAileron.setColorFill(COLORfd["Failed"]);
			me._Text_RAil.show();
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




