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
		m.hdg = 0;
		m.speed = 0 ;
		m.pitch = 0;
		m.roll = 0;
		m.hdgBug = 0;
		m.vsNeedle = 0;
		m.vsBug = 0;
		m.altBug = 0;
		m.OAT = 0;
		m.TAS = 0;
		m.hPa = 0;
		
		m.nIndicatedHeading = props.globals.initNode("/instrumentation/heading-indicator-IFD-RH/indicated-heading-deg",0.0,"DOUBLE");
		m.nIndicatedAirspeed = props.globals.initNode("/instrumentation/airspeed-indicator-IFD-RH/indicated-speed-kts",0.0,"DOUBLE");
		m.nPitchDeg = props.globals.initNode("/orientation/pitch-deg",0.0,"DOUBLE");
		m.nRollDeg = props.globals.initNode("/orientation/roll-deg",0.0,"DOUBLE");
		
		m.nVerticalSpeedNeedle = props.globals.initNode("/autopilot/altsensor/vs-fpm",0.0,"DOUBLE");
		m.nVerticalSpeedBug = props.globals.initNode("/autopilot/settings/vertical-speed-fpm",0.0,"DOUBLE");
		m.nAltitudeBug = props.globals.initNode("/autopilot/settings/target-altitude-ft",0.0,"DOUBLE");
		m.nOAT = props.globals.initNode("/environment/temperature-degc",0.0,"DOUBLE");
		#m.nHeadingBug = props.globals.initNode("/instrumentation/heading-indicator-IFD-LH/indicated-heading-deg",0.0,"DOUBLE");
		
	# creating Displays 
		m.primaryFlightDisplay = m.canvas.createGroup();
		
		m.nHorizon = m.primaryFlightDisplay.createChild("image");
		m.nHorizon.set("file", "Models/instruments/IFDs/Horizon.png");
		m.nHorizon.setSize(2410,1810);
		m.nHorizon.setScale(2.0);
		
		m.nHorizonTF = m.nHorizon.createTransform();
		m.nHorizonTF.setTranslation(-2410*1/2,-1810*3/4);
		
		m.nHorizon.updateCenter();
		
	#loading svg
		canvas.parsesvg(m.primaryFlightDisplay, "Models/instruments/IFDs/RH-IFD_CanvasTest.svg");
		
		
		
		
		
		#m.nHorizon.setTranslation(1205,450);
		
		m.CompassRose = m.primaryFlightDisplay.getElementById("CompassRose");
		m.CompassRose.updateCenter();
		
		
		m.HeadingBug = m.primaryFlightDisplay.getElementById("HeadingBug");
		m.HeadingBug.updateCenter();
		
		m.PitchLadder = m.primaryFlightDisplay.getElementById("PitchLadder");
		m.PitchLadder.updateCenter();
		
		
		m.Heading = m.primaryFlightDisplay.getElementById("Heading");
		m.HeadingSelected = m.primaryFlightDisplay.getElementById("HeadingSelected");
		
		m.VerticalSpeedNeedle = m.primaryFlightDisplay.getElementById("VerticalSpeedNeedle");
		m.VerticalSpeedNeedle.updateCenter();
		m.VerticalSpeedBug = m.primaryFlightDisplay.getElementById("VerticalSpeedBug");
		m.VerticalSpeedBug.updateCenter();
		m.VerticalSpeedIndicated = m.primaryFlightDisplay.getElementById("VerticalSpeedIndicated");
		
		m.BankAngleIndicator = m.primaryFlightDisplay.getElementById("BankAngleIndicator");
		m.BankAngleIndicator.updateCenter();
		
		m.AltBugIndicated = m.primaryFlightDisplay.getElementById("AltBugIndicated");
		
		
		#m.CompassRose.updateCenter();
		#m.CompassRose.setTranslation(100, -100);
		#m.CompassRose.setCenter(356,-356);
		
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
		
		me.vsNeedle = me.nVerticalSpeedNeedle.getValue();
		me.vsBug = me.nVerticalSpeedBug.getValue();
		me.altBug = me.nAltitudeBug.getValue();
		me.OAT = 0;
		me.TAS = 0;
		me.hPa = 0;
		
		me.HeadingSelected.setText(sprintf("%03i",me.hdgBug));
		
		me.VerticalSpeedIndicated.setText(sprintf("%4i",me.vsBug));
		me.VerticalSpeedNeedle.setRotation((me.vsNeedle/100*1.8) * TORAD);
		me.VerticalSpeedBug.setRotation((me.vsBug/100*1.8) * TORAD);
		me.AltBugIndicated.setText(sprintf("%4i",me.altBug));
		
		
		#me.TestText.setTranslation(0,me.nIndicatedAirspeed.getValue());
		#me.HeadingBug.setTranslation(0,me.speed);
		
	
	},	
	animationUpdate : func(now,dt){
		me.hdg = me.nIndicatedHeading.getValue();
		me.hdgBug = extra500.autopilot.nSetHeadingBugDeg.getValue();
		
		me.pitch = me.nPitchDeg.getValue();
		me.roll = me.nRollDeg.getValue();
		
		me.Heading.setText(sprintf("%03i",me.hdg));
		
		me.CompassRose.setRotation(-me.hdg * TORAD);
		me.HeadingBug.setRotation((me.hdgBug-me.hdg) * TORAD);
		
		me.PitchLadder.setRotation(-me.roll * TORAD);
		me.PitchLadder.setTranslation(0,me.pitch*10);
		me.BankAngleIndicator.setRotation(-me.roll * TORAD);
		
		me.nHorizon.setTranslation(0,me.pitch*10);
		me.nHorizon.setRotation(-me.roll * TORAD);
	},
};


var RH = AvidyneIFD.new();


