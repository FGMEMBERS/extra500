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
#	Date:	20.10.2015	
#

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

		var filename = "/Dialogs/GearFaildialog.svg";
		me._svg_gear = me._root.createChild('group');
		canvas.parsesvg(me._svg_gear, filename);

		filename = "/Dialogs/FuelFaildialog.svg";
		me._svg_fuel = me._root.createChild('group');
		canvas.parsesvg(me._svg_fuel, filename);

		me._Layout1 = canvas.VBoxLayout.new();
		me._canvas.setLayout(me._Layout1);

# MENU
		me._button_Gear = canvas.gui.widgets.Button.new(me._root, canvas.style, {})
       		.setCheckable(1) 
       		.setChecked( getprop("/extra500/failurescenarios/gear") ) 
        		.setFixedSize(80,30);

		if ( getprop("/extra500/failurescenarios/gear") == 1 ) {
			me._button_Gear.setText("ACTIVE");
		} else {
			me._button_Gear.setText("GEAR");
		}

		me._button_Gear.listen("toggled", func (e) {
        		if( e.detail.checked ) {
				me._menuButtonsReset();
				me._button_Gear.setText("ACTIVE");
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
			me._button_Fuel.setText("ACTIVE");
		} else {
			me._button_Fuel.setText("FUEL");
		}

		me._button_Fuel.listen("toggled", func (e) {
        		if( e.detail.checked ) {
				me._menuButtonsReset();
				me._button_Fuel.setText("ACTIVE");
				setprop("/extra500/failurescenarios/fuel",1);
				me._hideAll();
#				me._hbox_fuel1.show();
#				me._hbox_fuel2.show();
				me._svg_fuel.show();
				me._fuelButtons_update();
        		} else {
				me._fuelButtons_update();
				me._button_Fuel.setChecked(1);
        		}
    		});

		var hbox_menu = canvas.HBoxLayout.new();
		hbox_menu.addItem(me._button_Gear);
		hbox_menu.addItem(me._button_Fuel);
		hbox_menu.addStretch(1);

		me._Layout1.addItem(hbox_menu);


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
				me._button_NG.setText("OK");
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
				me._button_RMG.setText("OK");
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
				me._button_LMG.setText("OK");
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
				me._button_NG_flatTire.setText("OK");
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
				me._button_RMG_flatTire.setText("OK");
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
				me._button_LMG_flatTire.setText("OK");
				setprop("/extra500/failurescenarios/name","LMG_flat");
				setprop("/extra500/failurescenarios/activate",0);
	        	}
	    	});

		me._Layout1.addStretch(2);

# gear 'jammed' buttons'
		me._hbox_gear1 = canvas.HBoxLayout.new();
		me._hbox_gear1.addStretch(3);	
		me._hbox_gear1.addItem(me._button_LMG);
		me._hbox_gear1.addStretch(1);	
		me._hbox_gear1.addItem(me._button_NG);
		me._hbox_gear1.addStretch(1);	
		me._hbox_gear1.addItem(me._button_RMG);
		me._hbox_gear1.addStretch(3);
	
		me._Layout1.addItem(me._hbox_gear1);
		me._Layout1.addStretch(1);

# gear 'flat buttons'
		me._hbox_gear2 = canvas.HBoxLayout.new();
		me._hbox_gear2.addStretch(1);
		me._hbox_gear2.addItem(me._button_LMG_flatTire);
		me._hbox_gear2.addStretch(2);
		me._hbox_gear2.addItem(me._button_NG_flatTire);
		me._hbox_gear2.addStretch(2);
		me._hbox_gear2.addItem(me._button_RMG_flatTire);
		me._hbox_gear2.addStretch(1);

		me._Layout1.addItem(me._hbox_gear2);
		me._Layout1.addStretch(2);

		me._gearButtons_update();

	},
	_menuButtonsReset : func() {
		setprop("/extra500/failurescenarios/welcome",0);

		setprop("/extra500/failurescenarios/fuel",0);
		me._button_Fuel.setChecked(0);
		me._button_Fuel.setText("FUEL");

		setprop("/extra500/failurescenarios/gear",0);
		me._button_Gear.setChecked(0);
		me._button_Gear.setText("GEAR");

	},
	_hideAll : func() {
		me._hbox_gear1.hide();
		me._hbox_gear2.hide();
		me._svg_gear.hide();
		me._svg_fuel.hide();
	},
	_fuelButtons_update : func() {
	},
	_gearButtons_update : func() {

		if ( getprop("/systems/gear/NG-free") == 1 ) {
			me._button_NG.setText("OK");
		} else {
			me._button_NG.setText("JAMMED");
		}
		if ( getprop("/systems/gear/RMG-free") == 1 ) {
			me._button_RMG.setText("OK");
		} else {
			me._button_RMG.setText("JAMMED");
		}
		if ( getprop("/systems/gear/LMG-free") == 1 ) {
			me._button_LMG.setText("OK");
		} else {
			me._button_LMG.setText("JAMMED");
		}
		if ( getprop("/fdm/jsbsim/gear/unit[0]/flatTire") == 0 ) {
			me._button_NG_flatTire.setText("OK");
		} else {
			me._button_NG_flatTire.setText("FLAT");
		}
		if ( getprop("/fdm/jsbsim/gear/unit[2]/flatTire") == 0 ) {
			me._button_RMG_flatTire.setText("OK");
		} else {
			me._button_RMG_flatTire.setText("FLAT");
		}
		if ( getprop("/fdm/jsbsim/gear/unit[1]/flatTire") == 0 ) {
			me._button_LMG_flatTire.setText("OK");
		} else {
			me._button_LMG_flatTire.setText("FLAT");
		}

	},

};

var Failuredialog = FailureClass.new();




