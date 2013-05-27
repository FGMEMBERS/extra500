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
#      Authors: Dirk Dittmann
#      Date: April 27 2013
#
#      Last change:      Dirk Dittmann
#      Date:             27.04.13
#
var TODEG = 180/math.pi;
var TORAD = math.pi/180;
var deg = func(rad){ return rad*TODEG; }
var rad = func(deg){ return deg*TORAD; }
var course = func(deg){ return math.mod(deg,360.0);}

var AvidyneIFD = {
	new: func(){
		var m = { parents: [AvidyneIFD] };
		
		 m.canvas = canvas.new({
		"name": "IFD",
		"size": [2410, 1810],
		"view": [2410, 1810],
		"mipmapping": 1
		});
    
		# ... and place it on the object called PFD-Screen
		m.canvas.addPlacement({"node": "RH-IFD.Screen"});
		m.canvas.setColorBackground(1,1,1);
		
		
		m.primaryFlightDisplay = m.canvas.createGroup();
		canvas.parsesvg(m.primaryFlightDisplay, "Models/instruments/IFDs/RH-IFD_CanvasTest.svg");
		
		
		m.hdg = 0;
		m.speed = 0 ;
		
		m.nIndicatedHeading = props.globals.initNode("/instrumentation/heading-indicator-IFD-RH/indicated-heading-deg",0.0,"DOUBLE");
		m.nIndicatedAirspeed = props.globals.initNode("/instrumentation/airspeed-indicator-IFD-RH/indicated-speed-kts",0.0,"DOUBLE");
		m.TestText = m.primaryFlightDisplay.getElementById("TestText");
		m.TestText.updateCenter();
		
		m.CompassRose = m.primaryFlightDisplay.getElementById("CompassRose");
		#m.CompassRose.updateCenter();
		#m.CompassRose.setTranslation(100, -100);
		#m.CompassRose.setCenter(356,-356);
		m.CompassRose.updateCenter();
		#m.tfCompassRose = m.CompassRose.createTransform();
		debug.dump("AvidyneIFD.new() ... IFD created.");
		#debug.dump(m.CompassRose.getBoundingBox());
		return m;
	},
	simulationUpdate : func(now,dt){
		me.speed += 1;
		if (me.speed > 200){
			me.speed = 0;
		}
		me.hdg = me.nIndicatedHeading.getValue();
		me.CompassRose.setRotation(-me.hdg * TORAD);
		
		#me.TestText.setTranslation(0,me.nIndicatedAirspeed.getValue());
		me.TestText.setTranslation(0,me.speed);
	},	
	
};


var RH = AvidyneIFD.new();


