#    This file is part of extra500
#
#    The Changer is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 2 of the License, or
#    (at your option) any later version.
#
#    The Changer is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with extra500.  If not, see <http://www.gnu.org/licenses/>.
#
#      Authors: Dirk Dittmann
#      Date: April 27 2013
#
#      Last change:      Dirk Dittmann
#      Date:             27.04.13
#


var AvidyneIFD = {
	new: func(){
		var m = { parents: [AvidyneIFD] };
		
		 m.canvas = canvas.new({
		"name": "IFD",
		"size": [1024, 1024],
		"view": [1024, 1024],
		"mipmapping": 1
		});
    
		# ... and place it on the object called PFD-Screen
		m.canvas.addPlacement({"node": "RH-IFD.Screen"});
		m.canvas.setColorBackground(0,0.04,0);
		
		
		m.primaryFlightDisplay = m.canvas.createGroup();
		canvas.parsesvg(m.primaryFlightDisplay, "Models/extra500_RH-IFD_CanvasTest.svg");
		
		
		m.hdg = 0;
		m.TestText = m.primaryFlightDisplay.getElementById("TestText");
		m.TestText.updateCenter();
		
		m.CompassRose = m.primaryFlightDisplay.getElementById("CompassRose");
		#m.CompassRose.updateCenter();
		#m.CompassRose.setTranslation(512, 256);
		m.CompassRose.setCenter(512,512);
		#m.tfCompassRose = m.CompassRose.createTransform();
		debug.dump("AvidyneIFD.new() ... IFD created.");
		#debug.dump(m.CompassRose.getBoundingBox());
		return m;
	},
	update : func(){
		me.hdg += 0.1;
		
		me.CompassRose.setRotation(me.hdg);
		
		me.TestText.setRotation(-me.hdg);
	},	
	
};


var RH = AvidyneIFD.new();


