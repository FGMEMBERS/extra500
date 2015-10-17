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
#	Last change:	
#	Date:		
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
	var myLayout = canvas.HBoxLayout.new();
# assign it to the Canvas
	myCanvas.setLayout(myLayout);

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

	myLayout.addItem(button_LMG);
	myLayout.addItem(button_RMG);
	
}



