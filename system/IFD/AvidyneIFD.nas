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
COLOR["Yellow"] = "rgb(241,205,57)";


var AvidyneIFD = {
	new: func(prefix,acPlace){
		var m = { parents: [AvidyneIFD] };
		
		 m.canvas = canvas.new({
		"name": "IFD",
		"size": [2410, 1810],
		"view": [2410, 1810],
		"mipmapping": 1,
		"font-mapper": func{return "LiberationFonts/LiberationMono-Regular.ttf";}
		});
    
		# ... and place it on the object called PFD-Screen
		m.powered = 0;
		m.canvas.addPlacement({"node": acPlace});
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
		m.WindDirection = 0;
		m.WindSpeed = 0;

		m.nWindDirection = props.globals.initNode("/environment/wind-from-heading-deg",0.0,"INT");
		m.nWindSpeed = props.globals.initNode("/environment/wind-speed-kt",0.0,"INT");
		m.nApModeVS = props.globals.initNode("/autopilot/mode/vs",0.0,"INT");
		m.nApModeHDG = props.globals.initNode("/autopilot/mode/heading",0.0,"INT");
		m.nApModeNAV = props.globals.initNode("/autopilot/mode/nav",0.0,"INT");
		m.nApModeALT = props.globals.initNode("/autopilot/mode/alt",0.0,"INT");
		
		m.nIndicatedHeading = props.globals.initNode("/instrumentation/heading-indicator-IFD-"~prefix~"/indicated-heading-deg",0.0,"DOUBLE");
		m.nIndicatedAirspeed = props.globals.initNode("/instrumentation/airspeed-IFD-"~prefix~"/indicated-airspeed-kt",0.0,"DOUBLE");
		m.nPitchDeg = props.globals.initNode("/orientation/pitch-deg",0.0,"DOUBLE");
		m.nRollDeg = props.globals.initNode("/orientation/roll-deg",0.0,"DOUBLE");
		
		m.nVerticalSpeedNeedle = props.globals.initNode("/instrumentation/ivsi-IFD-"~prefix~"/indicated-speed-fpm",0.0,"DOUBLE");
		m.nVerticalSpeedBug = props.globals.initNode("/autopilot/settings/vertical-speed-fpm",0.0,"DOUBLE");
		m.nAltitudeBug = props.globals.initNode("/autopilot/settings/target-altitude-ft",0.0,"DOUBLE");
		m.nOAT = props.globals.initNode("/environment/temperature-degc",0.0,"DOUBLE");
		m.nTAS = props.globals.initNode("/instrumentation/airspeed-IFD-"~prefix~"/true-speed-kt",0.0,"DOUBLE");
		m.nhPa = props.globals.initNode("/instrumentation/altimeter-IFD-"~prefix~"/setting-hpa",0.0,"DOUBLE");
		
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
		m.cWindSpeed = m.PFD.getElementById("WindSpeed");
		m.cWindDirection = m.PFD.getElementById("WindDirection");
		m.cWindArrow = m.PFD.getElementById("WindArrow");
		m.cWindArrow.updateCenter();
		
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
		
		m.cARS = m.PFD.getElementById("ARS");
		m.cARS.set("clip","rect(168px, 1562px, 785px, 845px)");
		
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
		m.cAirSpeedBlackPlade = m.PFD.getElementById("AirSpeedBlackPlade");
		m.cAirSpeedBlackPlade.set("clip","rect(126px, 648px, 784px, 380px)");
		
	#autopilot
		m.cAutopilot	= m.PFD.getElementById("Autopilot");
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
						
		me.hdgBug = extra500.autopilot.nSetHeadingBugDeg.getValue();
		me.vsBug = me.nVerticalSpeedBug.getValue();
		me.altBug = me.nAltitudeBug.getValue();
		
		me.OAT = me.nOAT.getValue();
		me.TAS = me.nTAS.getValue();
		me.hPa = me.nhPa.getValue();
		
		me.WindSpeed = me.nWindSpeed.getValue();
		me.WindDirection = me.nWindDirection.getValue();
		me.cWindSpeed.setText(sprintf("%3i",me.WindSpeed));
		me.cWindDirection.setText(sprintf("%03i",me.WindDirection));
		me.cWindArrow.setRotation((180 + me.WindDirection - me.hdg) * TORAD);
		
		me.HeadingSelected.setText(sprintf("%03i",me.hdgBug));
		
		me.VerticalSpeedIndicated.setText(sprintf("%4i",me.vsBug));
		
		me.AltIndicated.setText(sprintf("%4i",me.altBug));
		
		me.VerticalSpeedBug.setRotation((me.vsBug/100*1.8) * TORAD);
		me.VerticalSpeedBugCoupled.setRotation((me.vsBug/100*1.8) * TORAD);
		
		me.cOAT.setText(sprintf("%2i",me.OAT));
		
		me.cAirSpeedTAS.setText(sprintf("%3i",me.TAS));
				
		me.cHPA.setText(sprintf("%4i",me.hPa));
		
		#me.TestText.setTranslation(0,me.nIndicatedAirspeed.getValue());
		#me.HeadingBug.setTranslation(0,me.speed);
		
	
	},	
	animationUpdate : func(now,dt){
		me.hdg = me.nIndicatedHeading.getValue();
		me.speedIndicated = me.nIndicatedAirspeed.getValue();
		me.vsNeedle = me.nVerticalSpeedNeedle.getValue();
		
		me.pitch = me.nPitchDeg.getValue();
		me.roll = me.nRollDeg.getValue();
		
	# IAS
		me.cAirSpeedBar.setTranslation(0,(me.speedIndicated-20)*10);
		me.cAirSpeedIndicatedOne.setTranslation(0,(math.mod(me.speedIndicated,10)*80));
		me.cAirSpeedIndicated.setText(sprintf("%2i",me.speedIndicated/10));
		
	# Vertical Speed
		me.VerticalSpeedNeedle.setRotation((me.vsNeedle/100*1.8) * TORAD);
				
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
		if (me.powered == 1){
			if (value == 1){
				me.cApModeState.setText("AP FAIL");
				me.cApModeState.setColor(COLOR["Red"]);
				me.cApModeFd.hide();
			}else{
				me.cApModeState.setText("AP RDY");
				me.cApModeState.setColor(COLOR["Green"]);
				me.cApModeFd.show();
			}
		}else{
			me.cApModeState.setColor(COLOR["Yellow"]);
			me.cApModeState.setText("---");
			
		}
		
		
	},
	onApModeAlt : func(value){
		#print ("AvidyneIFD.onApModeAlt");
		if (me.powered == 1){
			me.cApModeAlt.setColor(COLOR["Green"]);
			me.cApModeAlt.setText("ALT");
		
			if (value == 1){
				me.cApModeAlt.show();
			}else{
				me.cApModeAlt.hide();
			}
		}else{
			me.cApModeAlt.setColor(COLOR["Yellow"]);
			me.cApModeAlt.setText("---");
			#me.cAltBug.show();
			#me.cAltBugCoupled.hide();
		}
	},
	onApModeNav : func(value){
		#print ("AvidyneIFD.onApModeNav");
		if (me.powered == 1){
			me.cApModeNav.setColor(COLOR["Green"]);
			me.cApModeNav.setText("NAV");
		
			if (value == 1){
				me.cApModeNav.show();
			}else{
				me.cApModeNav.hide();
			}
		}else{
			me.cApModeNav.setColor(COLOR["Yellow"]);
			me.cApModeNav.setText("---");
			me.cApModeNav.show();
			#me.cNavBug.show();
			#me.cNavBugCoupled.hide();
		}
	},
	onApModeVs : func(value){
		#print ("AvidyneIFD.onApModeVs");
		
		if (me.powered == 1){
			me.cApModeVs.setColor(COLOR["Green"]);
			me.cApModeVs.setText("VS");
			if (value == 1){
				me.cApModeVs.show();
				me.VerticalSpeedBugCoupled.show();
				me.VerticalSpeedBug.hide();
				
			}else{
				me.cApModeVs.hide();
				me.VerticalSpeedBug.show();
				me.VerticalSpeedBugCoupled.hide();
			}
			
		}else{
			me.cApModeVs.setColor(COLOR["Yellow"]);
			me.cApModeVs.setText("---");
			me.cApModeVs.show();
			me.VerticalSpeedBug.show();
			me.VerticalSpeedBugCoupled.hide();
		}
	},
	onApModeHdg : func(value){
		#print ("AvidyneIFD.onApModeHdg");
		if (me.powered == 1){
			me.cApModeHdg.setColor(COLOR["Green"]);
			if (value == 1){
				me.cApModeHdg.setText("HDG");
				me.cApModeHdg.show();
				me.HeadingBugCoupled.show();
				me.HeadingBug.hide();
			}else{
				me.cApModeHdg.hide();
				me.HeadingBug.show();
				me.HeadingBugCoupled.hide();
			}
		}else{
			me.cApModeHdg.setColor(COLOR["Yellow"]);
			me.cApModeHdg.setText("---");
			me.cApModeHdg.show();
			me.HeadingBug.show();
			me.HeadingBugCoupled.hide();
		}
		
	},
	onApModeAp : func(value){
		#print ("AvidyneIFD.onApModeAp");
		if (value == 1){
			#me.cAutopilot.show();
		}else{
			#me.cAutopilot.hide();
		}
	},
	onApModeFd : func(value){
		#print ("AvidyneIFD.onApModeFd");
		if (me.powered == 1){
			me.cApModeFd.setColor(COLOR["Green"]);
			if (value == 1){
				me.cApModeFd.setText("FD");
			}else{
				me.cApModeFd.setText("AP");
			}
		}else{
			me.cApModeFd.setColor(COLOR["Yellow"]);
			me.cApModeFd.setText("---");
			me.cApModeFd.show();
		}
	},
	onApPower : func(value){
		#print ("AvidyneIFD.onApModeFd");
		me.powered = value;
		
		me.onApModeAp(0);
		me.onApModeFd(0);
		me.onApModeHdg(0);
		me.onApModeVs(0);	
		me.onApModeNav(0);
		me.onApModeAlt(0);
		me.onApModeFail(0);
		
	},
	
	

};

var initListeners = func(){
		
	setlistener("/autopilot/mode/fail", func(n){ 
			var value = n.getValue();
			IFD.LH.onApModeFail(value);
			IFD.RH.onApModeFail(value);
	},0,0);
	setlistener("/autopilot/mode/alt", func(n){ 
			var value = n.getValue();
			IFD.LH.onApModeAlt(value);
			IFD.RH.onApModeAlt(value);
	},0,0);
	setlistener("/autopilot/mode/vs", func(n){ 
			var value = n.getValue();
			IFD.LH.onApModeVs(value);
			IFD.RH.onApModeVs(value);
	},0,0);
	setlistener("/autopilot/mode/nav", func(n){ 
			var value = n.getValue();
			IFD.LH.onApModeNav(value);
			IFD.RH.onApModeNav(value);
	},0,0);
	setlistener("/autopilot/mode/heading", func(n){ 
			var value = n.getValue();
			IFD.LH.onApModeHdg(value);
			IFD.RH.onApModeHdg(value);
	},0,0);
	setlistener("/autopilot/settings/ap", func(n){ 
			var value = n.getValue();
			IFD.LH.onApModeAp(value);
			IFD.RH.onApModeAp(value);
	},0,0);
	setlistener("/autopilot/settings/fd", func(n){ 
			var value = n.getValue();
			IFD.LH.onApModeFd(value);
			IFD.RH.onApModeFd(value);
	},0,0);
	setlistener("/extra500/instrumentation/Autopilot/state", func(n){ 
			var value = n.getValue();
			IFD.LH.onApPower(value);
			IFD.RH.onApPower(value);
	},1,0);
}



var LH = AvidyneIFD.new("LH","LH-IFD.Screen");
var RH = AvidyneIFD.new("RH","RH-IFD.Screen");





