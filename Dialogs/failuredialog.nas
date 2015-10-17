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
#	Date:	17.10.2015	
#

var fd_toggle = func() {
	var (width,height) = (750,512);
	var title = 'Gear Failure Dialog';

	var gfd_window = canvas.Window.new([width,height],"dialog").set('title',title);
	var myCanvas = gfd_window.createCanvas().set("background", canvas.style.getColor("bg_color"));
	var root = myCanvas.createGroup();

	var filename = "/Dialogs/failuredialog.svg";
	var svg_symbol = root.createChild('group');
	canvas.parsesvg(svg_symbol, filename);


# create a new layout
	var myLayout1 = canvas.VBoxLayout.new();
# assign it to the Canvas
	myCanvas.setLayout(myLayout1);


	var button_NG = canvas.gui.widgets.Button.new(root, canvas.style, {})
       	.setCheckable(1) 
       	.setChecked( math.abs(getprop("/systems/gear/NG-free")-1) ) 
        	.setFixedSize(70,25);

	if ( getprop("/systems/gear/NG-free") == 1 ) {
		button_NG.setText("OK");
	} else {
		button_NG.setText("JAMMED");
	}

	button_NG.listen("toggled", func (e) {
        	if( e.detail.checked ) {
			button_NG.setText("JAMMED");
			setprop("/extra500/failurescenarios/name","NG_jammed");
			setprop("/extra500/failurescenarios/activate",1);
        	} else {
			button_NG.setText("OK");
			setprop("/extra500/failurescenarios/name","NG_jammed");
			setprop("/extra500/failurescenarios/activate",0);
        	}
    	});


	var button_RMG = canvas.gui.widgets.Button.new(root, canvas.style, {})
       	.setCheckable(1) 
       	.setChecked( math.abs(getprop("/systems/gear/RMG-free")-1) ) 
        	.setFixedSize(70,25);

	if ( getprop("/systems/gear/RMG-free") == 1 ) {
		button_RMG.setText("OK");
	} else {
		button_RMG.setText("JAMMED");
	}

	button_RMG.listen("toggled", func (e) {
        	if( e.detail.checked ) {
			button_RMG.setText("JAMMED");
			setprop("/extra500/failurescenarios/name","RMG_jammed");
			setprop("/extra500/failurescenarios/activate",1);
        	} else {
			button_RMG.setText("OK");
			setprop("/extra500/failurescenarios/name","RMG_jammed");
			setprop("/extra500/failurescenarios/activate",0);
        	}
    	});


	var button_LMG = canvas.gui.widgets.Button.new(root, canvas.style, {})
       	.setCheckable(1) 
       	.setChecked( math.abs(getprop("/systems/gear/LMG-free")-1) ) 
        	.setFixedSize(70,25);

	if ( getprop("/systems/gear/LMG-free") == 1 ) {
		button_LMG.setText("OK");
	} else {
		button_LMG.setText("JAMMED");
	}

	button_LMG.listen("toggled", func (e) {
        	if( e.detail.checked ) {
			button_LMG.setText("JAMMED");
			setprop("/extra500/failurescenarios/name","LMG_jammed");
			setprop("/extra500/failurescenarios/activate",1);
        	} else {
			button_LMG.setText("OK");
			setprop("/extra500/failurescenarios/name","LMG_jammed");
			setprop("/extra500/failurescenarios/activate",0);
        	}
    	});

	var button_NG_flatTire = canvas.gui.widgets.Button.new(root, canvas.style, {})
       	.setCheckable(1) 
       	.setChecked( getprop("/fdm/jsbsim/gear/unit[0]/flatTire") ) 
        	.setFixedSize(70,25);

	if ( getprop("/fdm/jsbsim/gear/unit[0]/flatTire") == 0 ) {
		button_NG_flatTire.setText("OK");
	} else {
		button_NG_flatTire.setText("FLAT");
	}

	button_NG_flatTire.listen("toggled", func (e) {
        	if( e.detail.checked ) {
			button_NG_flatTire.setText("FLAT");
			setprop("/extra500/failurescenarios/name","NG_flat");
			setprop("/extra500/failurescenarios/activate",1);
        	} else {
			button_NG_flatTire.setText("OK");
			setprop("/extra500/failurescenarios/name","NG_flat");
			setprop("/extra500/failurescenarios/activate",0);
        	}
    	});

	var button_RMG_flatTire = canvas.gui.widgets.Button.new(root, canvas.style, {})
       	.setCheckable(1) 
       	.setChecked( getprop("/fdm/jsbsim/gear/unit[2]/flatTire") ) 
        	.setFixedSize(70,25);

	if ( getprop("/fdm/jsbsim/gear/unit[2]/flatTire") == 0 ) {
		button_RMG_flatTire.setText("OK");
	} else {
		button_RMG_flatTire.setText("FLAT");
	}

	button_RMG_flatTire.listen("toggled", func (e) {
        	if( e.detail.checked ) {
			button_RMG_flatTire.setText("FLAT");
			setprop("/extra500/failurescenarios/name","RMG_flat");
			setprop("/extra500/failurescenarios/activate",1);
        	} else {
			button_RMG_flatTire.setText("OK");
			setprop("/extra500/failurescenarios/name","RMG_flat");
			setprop("/extra500/failurescenarios/activate",0);
        	}
    	});

	var button_LMG_flatTire = canvas.gui.widgets.Button.new(root, canvas.style, {})
       	.setCheckable(1) 
       	.setChecked( getprop("/fdm/jsbsim/gear/unit[1]/flatTire") ) 
        	.setFixedSize(70,25);

	if ( getprop("/fdm/jsbsim/gear/unit[1]/flatTire") == 0 ) {
		button_LMG_flatTire.setText("OK");
	} else {
		button_LMG_flatTire.setText("FLAT");
	}

	button_LMG_flatTire.listen("toggled", func (e) {
        	if( e.detail.checked ) {
			button_LMG_flatTire.setText("FLAT");
			setprop("/extra500/failurescenarios/name","LMG_flat");
			setprop("/extra500/failurescenarios/activate",1);
        	} else {
			button_LMG_flatTire.setText("OK");
			setprop("/extra500/failurescenarios/name","LMG_flat");
			setprop("/extra500/failurescenarios/activate",0);
        	}
    	});

	myLayout1.addStretch(2);

# 'jammed' buttons'
	var hbox1 = canvas.HBoxLayout.new();
	hbox1.addStretch(3);	
	hbox1.addItem(button_LMG);
	hbox1.addStretch(1);	
	hbox1.addItem(button_NG);
	hbox1.addStretch(1);	
	hbox1.addItem(button_RMG);
	hbox1.addStretch(3);
	
	myLayout1.addItem(hbox1);
	myLayout1.addStretch(1);

# 'flat buttons'
	var hbox2 = canvas.HBoxLayout.new();
	hbox2.addStretch(1);
	hbox2.addItem(button_LMG_flatTire);
	hbox2.addStretch(2);
	hbox2.addItem(button_NG_flatTire);
	hbox2.addStretch(2);
	hbox2.addItem(button_RMG_flatTire);
	hbox2.addStretch(1);

	myLayout1.addItem(hbox2);
	myLayout1.addStretch(2);

}



