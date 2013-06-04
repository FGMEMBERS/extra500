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


var COLOR = {};
COLOR["Red"] = "rgb(244,28,33)";
COLOR["Green"] = "rgb(64,178,80)";
COLOR["Magenta"] = "rgb(255,14,235)";


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
		m.speedIndicated = 0 ;
		m.pitch = 0;
		m.roll = 0;
		m.hdgBug = 0;
		m.vsNeedle = 0;
		m.vsBug = 0;
		m.altBug = 0;
		m.OAT = 0;
		m.TAS = 0;
		m.hPa = 0;
		
		
		m.nApModeVS = props.globals.initNode("/autopilot/mode/vs",0.0,"INT");
		m.nApModeHDG = props.globals.initNode("/autopilot/mode/heading",0.0,"INT");
		m.nApModeNAV = props.globals.initNode("/autopilot/mode/nav",0.0,"INT");
		m.nApModeALT = props.globals.initNode("/autopilot/mode/alt",0.0,"INT");
		
		m.nIndicatedHeading = props.globals.initNode("/instrumentation/heading-indicator-IFD-RH/indicated-heading-deg",0.0,"DOUBLE");
		m.nIndicatedAirspeed = props.globals.initNode("/instrumentation/airspeed-IFD-RH/indicated-airspeed-kt",0.0,"DOUBLE");
		m.nPitchDeg = props.globals.initNode("/orientation/pitch-deg",0.0,"DOUBLE");
		m.nRollDeg = props.globals.initNode("/orientation/roll-deg",0.0,"DOUBLE");
		
		m.nVerticalSpeedNeedle = props.globals.initNode("/instrumentation/ivsi-IFD-RH/indicated-speed-fpm",0.0,"DOUBLE");
		m.nVerticalSpeedBug = props.globals.initNode("/autopilot/settings/vertical-speed-fpm",0.0,"DOUBLE");
		m.nAltitudeBug = props.globals.initNode("/autopilot/settings/target-altitude-ft",0.0,"DOUBLE");
		m.nOAT = props.globals.initNode("/environment/temperature-degc",0.0,"DOUBLE");
		m.nTAS = props.globals.initNode("/instrumentation/airspeed-IFD-RH/true-speed-kt",0.0,"DOUBLE");
		m.nhPa = props.globals.initNode("/instrumentation/altimeter-IFD-RH/setting-hpa",0.0,"DOUBLE");
		
		#m.nHeadingBug = props.globals.initNode("/instrumentation/heading-indicator-IFD-LH/indicated-heading-deg",0.0,"DOUBLE");
		
	# creating Displays 
		m.PFD = m.canvas.createGroup();
		m.PitchLadderDisplay = m.canvas.createGroup();
		
		m.nHorizon = m.PFD.createChild("image");
		m.nHorizon.set("file", "Models/instruments/IFDs/Horizon.png");
		m.nHorizon.setSize(2410,1810);
		m.nHorizon.setScale(2.0);
		
		m.nHorizonTF = m.nHorizon.createTransform();
		m.nHorizonTF.setTranslation(-2410*1/2,-1810*3/4 +80);
		
		m.nHorizon.updateCenter();
		
		
# 		m.nOatBorder = m.PFD.createChild("image")
# 			.set("file", "Models/instruments/IFDs/SliceBorder.png")
# 			.set("slice", "32")
# 			.setSize(254,768)
# 			.setTranslation(32,96);
			
		
	#loading svg
		canvas.parsesvg(m.PFD, "Models/instruments/IFDs/RH-IFD_CanvasTest.svg");

		
		m.CompassRose = m.PFD.getElementById("CompassRose");
		m.CompassRose.updateCenter();
		
		
		m.HeadingBug = m.PFD.getElementById("HeadingBug");
		m.HeadingBug.updateCenter();
		m.HeadingBugCoupled = m.PFD.getElementById("HeadingBugCoupled");
		m.HeadingBugCoupled.updateCenter();
		m.HeadingBugCoupled.hide();
		
	#HSI
		m.BankAngleIndicator = m.PFD.getElementById("BankAngleIndicator");
		m.BankAngleIndicator.updateCenter();
		
		
		m.PitchLadder = m.PFD.getElementById("PitchLadder");
		m.PitchLadder.updateCenter();
		m.PitchLadder.set("clip","rect(168px, 1562px, 785px, 845px)");
		
		m.Heading = m.PFD.getElementById("Heading");
		m.HeadingSelected = m.PFD.getElementById("HeadingSelected");
	#vertical speed
		m.VerticalSpeedNeedle = m.PFD.getElementById("VerticalSpeedNeedle");
		m.VerticalSpeedNeedle.updateCenter();
		m.VerticalSpeedBug = m.PFD.getElementById("VerticalSpeedBug");
		m.VerticalSpeedBug.updateCenter();
		m.VerticalSpeedBugCoupled = m.PFD.getElementById("VerticalSpeedBugCoupled");
		m.VerticalSpeedBugCoupled.updateCenter();
		m.VerticalSpeedBugCoupled.hide();
		m.VerticalSpeedIndicated = m.PFD.getElementById("VerticalSpeedIndicated");
		
		
		
	#AirSpeed
		m.cAirSpeedBar = m.PFD.getElementById("AirSpeedBar");
		m.cAirSpeedBar.set("clip","rect(126px, 648px, 784px, 413px)");
		m.cAirSpeedIndicatedOne = m.PFD.getElementById("AirSpeedIndicatedOne"); # 79.25
		m.cAirSpeedIndicatedOne.set("clip","rect(383px, 581px, 599px, 505px)");
		m.cAirSpeedIndicated = m.PFD.getElementById("AirSpeedIndicated");
		m.cAirSpeedTAS = m.PFD.getElementById("AirSpeedTAS");
		
	#autopilot
		m.cAuopilot	= m.PFD.getElementById("Autopilot");
		m.cApModeState 	= m.PFD.getElementById("AP_State");
		m.cApModeHdg 	= m.PFD.getElementById("AP_HDG");
		m.cApModeHdg.hide(); 
		m.cApModeNav 	= m.PFD.getElementById("AP_NAV");
		m.cApModeNav.hide();
		m.cApModeAlt 	= m.PFD.getElementById("AP_ALT");
		m.cApModeAlt.hide();
		m.cApModeVs 	= m.PFD.getElementById("AP_VS");
		m.cApModeVs.hide();
		m.cApModeFd 	= m.PFD.getElementById("AP_FD");
		m.cApModeFd.hide();
		
	#alt
		m.AltIndicated = m.PFD.getElementById("AltIndicated");
		m.cHPA = m.PFD.getElementById("hPa");
		
		m.cOAT = m.PFD.getElementById("OAT");
		#m.CompassRose.updateCenter();
		#m.CompassRose.setTranslation(100, -100);
		#m.CompassRose.setCenter(356,-356);
		
		#m.tfCompassRose = m.CompassRose.createTransform();
		debug.dump("AvidyneIFD.new() ... IFD created.");
		#debug.dump(m.CompassRose.getBoundingBox());
		return m;
	},
	simulationUpdate : func(now,dt){
						
		
		me.vsNeedle = me.nVerticalSpeedNeedle.getValue();
		me.vsBug = me.nVerticalSpeedBug.getValue();
		me.altBug = me.nAltitudeBug.getValue();
		me.OAT = me.nOAT.getValue();
		me.TAS = me.nTAS.getValue();
		me.hPa = me.nhPa.getValue();
		me.speedIndicated = me.nIndicatedAirspeed.getValue();
		
		me.HeadingSelected.setText(sprintf("%03i",me.hdgBug));
		
		me.VerticalSpeedIndicated.setText(sprintf("%4i",me.vsBug));
		me.VerticalSpeedNeedle.setRotation((me.vsNeedle/100*1.8) * TORAD);
		me.VerticalSpeedBug.setRotation((me.vsBug/100*1.8) * TORAD);
		me.VerticalSpeedBugCoupled.setRotation((me.vsBug/100*1.8) * TORAD);
		
		me.AltIndicated.setText(sprintf("%4i",me.altBug));
		
		me.cOAT.setText(sprintf("%2i",me.OAT));
		
		me.cAirSpeedTAS.setText(sprintf("%3i",me.TAS));
		me.cAirSpeedBar.setTranslation(0,(me.speedIndicated-20)*10);
		me.cAirSpeedIndicatedOne.setTranslation(0,(math.mod(me.speedIndicated,10)*80));
		me.cAirSpeedIndicated.setText(sprintf("%2i",me.speedIndicated/10));
		
		
		me.cHPA.setText(sprintf("%4i",me.hPa));
		
		#me.TestText.setTranslation(0,me.nIndicatedAirspeed.getValue());
		#me.HeadingBug.setTranslation(0,me.speed);
		
	
	},	
	animationUpdate : func(now,dt){
		me.hdg = me.nIndicatedHeading.getValue();
		me.hdgBug = extra500.autopilot.nSetHeadingBugDeg.getValue();
		
		me.pitch = me.nPitchDeg.getValue();
		me.roll = me.nRollDeg.getValue();
		
		
	#CompassRose
		me.Heading.setText(sprintf("%03i",me.hdg));
		me.CompassRose.setRotation(-me.hdg * TORAD);
		me.HeadingBug.setRotation((me.hdgBug-me.hdg) * TORAD);
		me.HeadingBugCoupled.setRotation((me.hdgBug-me.hdg) * TORAD);
	#HSI
		me.PitchLadder.setRotation(-me.roll * TORAD);
		me.PitchLadder.setTranslation(0,me.pitch*10);
		me.BankAngleIndicator.setRotation(-me.roll * TORAD);
		
		me.nHorizon.setTranslation(0,me.pitch*10);
		me.nHorizon.setRotation(-me.roll * TORAD);
	},
	# listeners events
	onApModeFail : func(value){
		#print ("AvidyneIFD.onApModeFail");
		if (value == 1){
			me.cApModeState.setText("AP FAIL");
			me.cApModeState.setColor(COLOR["Red"]);
			me.cApModeFd.hide();
		}else{
			me.cApModeState.setText("AP RDY");
			me.cApModeState.setColor(COLOR["Green"]);
			me.cApModeFd.show();
		}
	},
	onApModeAlt : func(value){
		#print ("AvidyneIFD.onApModeAlt");
		if (value == 1){
			me.cApModeAlt.show();
		}else{
			me.cApModeAlt.hide();
		}
	},
	onApModeNav : func(value){
		#print ("AvidyneIFD.onApModeNav");
		if (value == 1){
			me.cApModeNav.show();
		}else{
			me.cApModeNav.hide();
		}
	},
	onApModeVs : func(value){
		#print ("AvidyneIFD.onApModeVs");
		
		if (value == 1){
			me.cApModeVs.show();
			me.VerticalSpeedBugCoupled.show();
			me.VerticalSpeedBug.hide();
			
		}else{
			me.cApModeVs.hide();
			me.VerticalSpeedBug.show();
			me.VerticalSpeedBugCoupled.hide();
			
		}
	},
	onApModeHdg : func(value){
		#print ("AvidyneIFD.onApModeHdg");
		if (value == 1){
			me.cApModeHdg.show();
			me.HeadingBugCoupled.show();
			me.HeadingBug.hide();
		}else{
			me.cApModeHdg.hide();
			me.HeadingBug.show();
			me.HeadingBugCoupled.hide();
		}
		
	},
	onApModeAp : func(value){
		#print ("AvidyneIFD.onApModeAp");
		if (value == 1){
			me.cAuopilot.show();
		}else{
			me.cAuopilot.hide();
		}
	},
	onApModeFd : func(value){
		#print ("AvidyneIFD.onApModeFd");
		if (value == 1){
			me.cApModeFd.setText("FD");
		}else{
			me.cApModeFd.setText("AP");
		}
	},

};

var initListeners = func(){
	setlistener("/autopilot/mode/fail", func(n){ IFD.RH.onApModeFail(n.getValue());},0,0);
	setlistener("/autopilot/mode/alt", func(n){ IFD.RH.onApModeAlt(n.getValue());},0,0);
	setlistener("/autopilot/mode/vs", func(n){ IFD.RH.onApModeVs(n.getValue());},0,0);
	setlistener("/autopilot/mode/nav", func(n){ IFD.RH.onApModeNav(n.getValue());},0,0);
	setlistener("/autopilot/mode/heading", func(n){IFD.RH.onApModeHdg(n.getValue());},0,0);
	setlistener("/autopilot/settings/ap", func(n){ IFD.RH.onApModeAp(n.getValue());},0,0);
	setlistener("/autopilot/settings/fd", func(n){ IFD.RH.onApModeFd(n.getValue());},0,0);
}



var RH = AvidyneIFD.new();






