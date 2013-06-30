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
#      Last change:      Thomas Grossberger
#      Date:             2013-06-30
#
var TODEG = 180/math.pi;
var TORAD = math.pi/180;
var deg = func(rad){ return rad*TODEG; }
var rad = func(deg){ return deg*TORAD; }
var course = func(deg){ return math.mod(deg,360.0);}

var NAV_SOURCE_NAME = ["NAV 1","NAV 2","FMS"];
var NAV_SOURCE_TREE = ["/instrumentation/nav[0]","/instrumentation/nav[1]","/instrumentation/fms"];


var COLOR = {};
COLOR["Red"] = "rgb(244,28,33)";
COLOR["Green"] = "rgb(64,178,80)";
COLOR["Magenta"] = "rgb(255,14,235)";
COLOR["Yellow"] = "rgb(241,205,57)";
COLOR["White"] = "rgb(255,255,255)";

var AvidyneFontMapper = func(family, weight){
	#print(sprintf("Canvas font-mapper %s %s",family,weight));
	if (weight == "bold"){
		return "LiberationFonts/LiberationSans-Bold.ttf";
	}elsif(weight == "normal"){
		return "LiberationFonts/LiberationSans-Regular.ttf";
	}
	
}

var AvidyneData = {
	new: func(name){
		var m = { parents: [AvidyneData] };
		m.name = name;
		m.link = nil; #link to the other IFD DATA
	#autopilot
		m.apPowered 	= 0;
		m.apModeRdy	= 0;
		m.apModeFail 	= 0;
		m.apModeALT 	= 0;
		m.apModeNAV 	= 0;
		m.apModeVS 	= 0;
		m.apModeHDG 	= 0;
		m.apModeAP 	= 0;
		m.apModeFD 	= 0;
		
		m.nApPower 	= props.globals.initNode("/extra500/instrumentation/Autopilot/state",0.0,"INT");
		m.nApModeRdy 	= props.globals.initNode("/autopilot/mode/rdy",0.0,"INT");
		m.nApModeFail 	= props.globals.initNode("/autopilot/mode/fail",0.0,"INT");
		m.nApModeALT 	= props.globals.initNode("/autopilot/mode/alt",0.0,"INT");
		m.nApModeNAV 	= props.globals.initNode("/autopilot/mode/nav",0.0,"INT");
		m.nApModeVS  	= props.globals.initNode("/autopilot/mode/vs",0.0,"INT");
		m.nApModeHDG 	= props.globals.initNode("/autopilot/mode/heading",0.0,"INT");
		m.nApModeAP  	= props.globals.initNode("/autopilot/settings/ap",0.0,"INT");
		m.nApModeFD  	= props.globals.initNode("/autopilot/settings/fd",0.0,"INT");
		
		
		
		
	#heading 
		m.HDG 		= 0;
		m.HDGBug 	= 0;
		
		m.nHDG = props.globals.initNode("/instrumentation/heading-indicator-IFD-"~m.name~"/indicated-heading-deg",0.0,"DOUBLE");
		m.nHDGBug = props.globals.initNode("/autopilot/settings/heading-bug-deg",0.0,"DOUBLE");
	#speed 	
		m.IAS 		= 0;
		m.TAS 		= 0;
		m.GroundSpeed	= 0;
		
		m.nIAS 		= props.globals.initNode("/instrumentation/airspeed-IFD-"~m.name~"/indicated-airspeed-kt",0.0,"DOUBLE");
		m.nTAS 		= props.globals.initNode("/instrumentation/airspeed-IFD-"~m.name~"/true-speed-kt",0.0,"DOUBLE");
		m.nGroundSpeed 	= props.globals.initNode("/velocities/groundspeed-kt",0.0,"DOUBLE");
		
	#vertical speed
		m.VS 		 = 0;
		m.VSBug		 = 0;
		
		m.nVS = props.globals.initNode("/instrumentation/ivsi-IFD-"~m.name~"/indicated-speed-fpm",0.0,"DOUBLE");
		m.nVSBug = props.globals.initNode("/autopilot/settings/vertical-speed-fpm",0.0,"DOUBLE");
		
	#altitude
		m.ALT 		= 0;
		m.ALTBug 	= 0;
		m.HPA 		= 0;
		
		m.nALT = props.globals.initNode("/instrumentation/altimeter-IFD-"~m.name~"/indicated-altitude-ft",0.0,"DOUBLE");
		m.nALTBug = props.globals.initNode("/autopilot/settings/target-altitude-ft",0.0,"DOUBLE");
		m.nHPA = props.globals.initNode("/instrumentation/altimeter-IFD-"~m.name~"/setting-hpa",0.0,"DOUBLE");
		
	#wind
		m.WindDirection = 0;
		m.WindSpeed 	= 0;
		
		m.nWindDirection = props.globals.initNode("/environment/wind-from-heading-deg",0.0,"INT");
		m.nWindSpeed = props.globals.initNode("/environment/wind-speed-kt",0.0,"INT");
	
	#attitude
		m.pitch 	= 0;
		m.roll 		= 0;
		
		m.nPitch = props.globals.initNode("/orientation/pitch-deg",0.0,"DOUBLE");
		m.nRoll = props.globals.initNode("/orientation/roll-deg",0.0,"DOUBLE");
		
	#enviroment
		m.OAT = 0;
		
		m.nOAT = props.globals.initNode("/environment/temperature-degc",0.0,"DOUBLE");
		
	#DI
		m.HDI = 0;
		m.VDI = 0;
		m.GSable = 0;
		m.GSinRange = 0;
		m.NAVinRange = 0;
		m.NAVLOC = 0;
		m.nHDI 		= props.globals.initNode("/autopilot/radionav-channel/heading-needle-deflection-norm",0.0,"DOUBLE");
		m.nVDI 		= props.globals.initNode("/autopilot/radionav-channel/gs-needle-deflection-norm",0.0,"DOUBLE");
		#m.nGSable 	= props.globals.initNode("/autopilot/radionav-channel/has-gs",0.0,"DOUBLE");
		m.nGSinRange 	= props.globals.initNode("/autopilot/radionav-channel/gs-in-range",0.0,"DOUBLE");
		m.nNAVinRange 	= props.globals.initNode("/autopilot/radionav-channel/in-range",0.0,"DOUBLE");
		#m.nNAVLOC 	= props.globals.initNode("/autopilot/radionav-channel/is-localizer-frequency",0.0,"DOUBLE");
		
		m.FromFlag = 0;
		
	#Box Primary Nav
		m.nNAVSource 	= props.globals.initNode("/instrumentation/nav-source",0,"INT");
		m.nNavDeg	= props.globals.initNode("/autopilot/radionav-channel/radials/reciprocal-radial",0,"DOUBLE");
		m.nNavDistance	= props.globals.initNode("/autopilot/radionav-channel/nav-distance-nm",0.0,"DOUBLE");
		
		m.navSource		= 0;
		m.navID		= "";
		m.navDeg		= 0.0;
		m.navAidUnit		= "";
		m.navDistance	= 0.3;
		return m;
	},
	#loading the data from PropertyTree
	load20Hz : func(){
	#autopilot
		me.apPowered 	= me.nApPower.getValue();
		me.apModeRdy 	= me.nApModeRdy.getValue();
		me.apModeFail 	= me.nApModeFail.getValue();
		me.apModeALT 	= me.nApModeALT.getValue();
		me.apModeNAV 	= me.nApModeNAV.getValue();
		me.apModeVS 	= me.nApModeVS.getValue();
		me.apModeHDG 	= me.nApModeHDG.getValue();
		me.apModeAP 	= me.nApModeAP.getValue();
		me.apModeFD 	= me.nApModeFD.getValue();
		
	#heading 
		me.HDG 		= me.nHDG.getValue();
		me.HDGBug 	= me.nHDGBug.getValue();
	#speed 	
		me.IAS 		= me.nIAS.getValue();
		me.TAS 		= me.nTAS.getValue();
	#vertical speed
		me.VS 		= me.nVS.getValue();
		me.VSBug	= me.nVSBug.getValue();
	#altitude
		me.ALT 		= me.nALT.getValue() ;
		#me.ALT		= me.ALT < 0 ? 0 : me.ALT;
		me.ALTBug 	= me.nALTBug.getValue();
		me.HPA 		= me.nHPA.getValue();
	#wind
		me.WindDirection = me.nWindDirection.getValue();
		me.WindSpeed 	= me.nWindSpeed.getValue();
	#attitude
		me.pitch 	= me.nPitch.getValue();
		me.roll 	= me.nRoll.getValue();

	#enviroment
		me.OAT = me.nOAT.getValue();
	#DI 
		me.HDI 		= me.nHDI.getValue();
		me.VDI 		= -me.nVDI.getValue();
		#me.GSable 	= me.nGSable.getValue();
		me.GSinRange 	= me.nGSinRange.getValue();
		me.NAVinRange 	= me.nNAVinRange.getValue();
		#me.NAVLOC	= me.nNAVLOC.getValue();
	
	#Box Primary Nav
		
		
	
	},
	load2Hz : func(){
	#Box Primary Nav
		me.navDeg	= me.nNavDeg.getValue();
		me.navDistance	= me.nNavDistance.getValue();
		me.GroundSpeed	= me.nGroundSpeed.getValue();
	},
	adjustBaro : func(value=nil){
		if (value==nil){
			me.HPA = 1013;
		}else{
			me.HPA = math.floor(me.HPA) + value;	
		}
		me.nHPA.setValue(me.HPA);
		if (me.link!=nil){
			me.link.nHPA.setValue(me.HPA);
		}
	}
	
};

var AvidynePage = {
	new: func(ifd,name,data){
		var m = { parents: [AvidynePage] };
		m.IFD = ifd;
		m.page = m.IFD.canvas.createGroup();
		m.page.hide();
		m.name = name;
		m.data = data;
		m.keys = {};
		m._listeners = [];
		return m;
	},
	setListeners : func(){
		
	},
	removeListeners : func(){
		foreach(l;me._listeners){
			removelistener(l);
		}
		me._listeners = [];
	},
	registerKeys : func(){
		
	},
	hide : func(){
		me.page.hide();
	},
	show : func(){
		me.page.show();
	},
	onClick : func(key){
		if (contains(me.keys,key)){
			me.keys[key]();
		}
	},
	update20Hz : func(now,dt){},
	update2Hz  : func(now,dt){},
	
};

var AvidynePageDummy = {
	new: func(myCanvas,name,data){
		var m = { parents: [
			AvidynePageDummy,
			AvidynePage.new(myCanvas,name,data)
		] };
		return m;
	},
};

var AvidynePagePFD = {
	new: func(ifd,name,data){
		var m = { parents: [
			AvidynePagePFD,
			AvidynePage.new(ifd,name,data)
		] };
		
		
		m._navListeners = []; 
		
		# creating the page 
		
		m.nHorizon = m.page.createChild("image");
		m.nHorizon.set("file", "Models/instruments/IFDs/Horizon.png");
		m.nHorizon.setSize(2410,1810);
		m.nHorizon.setScale(2.0);
		
		m.nHorizonTF = m.nHorizon.createTransform();
		m.nHorizonTF.setTranslation(-2410*1/2,-1810*3/4 +80);
		
		m.nHorizon.updateCenter();
		
		
# 		m.nOatBorder = m.page.createChild("image")
# 			.set("file", "Models/instruments/IFDs/SliceBorder.png")
# 			.set("slice", "32")
# 			.setSize(254,768)
# 			.setTranslation(32,96);
			
		
	#loading svg
		canvas.parsesvg(m.page, "Models/instruments/IFDs/RH-IFD_CanvasTest.svg",{
			"font-mapper": AvidyneFontMapper
			}
		);

		m.CompassRose = m.page.getElementById("CompassRose");
		m.CompassRose.updateCenter();
		m.cWindSpeed = m.page.getElementById("WindSpeed");
		m.cWindDirection = m.page.getElementById("WindDirection");
		m.cWindArrow = m.page.getElementById("WindArrow");
		m.cWindArrow.updateCenter();
		
		m.HeadingBug = m.page.getElementById("HDG_Bug");
		m.HeadingBug.updateCenter();
		m.Heading = m.page.getElementById("Heading");
		m.HeadingSelected = m.page.getElementById("HDG_Selected");
	#HSI
		m.BankAngleIndicator = m.page.getElementById("BankAngleIndicator");
		m.BankAngleIndicator.updateCenter();
		
		
		m.PitchLadder = m.page.getElementById("PitchLadder");
		m.PitchLadder.updateCenter();
		m.PitchLadder.set("clip","rect(168px, 1562px, 785px, 845px)");
		
		m.cARS = m.page.getElementById("ARS");
		m.cARS.set("clip","rect(168px, 1562px, 785px, 845px)");
		
		m.cCoursePointer	= m.page.getElementById("CoursePointer");
		m.cCoursePointer.updateCenter();
		m.cCDI			= m.page.getElementById("CDI");
		m.cFromFlag		= m.page.getElementById("FromFlag");
		
		
	#DI	
		m.cDI 			= m.page.getElementById("DI");
		m.cDI_Source_Text 	= m.page.getElementById("DI_Source_Text");
		m.cHDI		 	= m.page.getElementById("HDI");
		m.cHDI_Needle 		= m.page.getElementById("HDI_Needle");
		m.cVDI	 		= m.page.getElementById("VDI");
		m.cVDI_Needle 		= m.page.getElementById("VDI_Needle");
		
		
	#vertical speed
		m.VerticalSpeedNeedle = m.page.getElementById("VS_Needle");
		m.VerticalSpeedNeedle.updateCenter();
		m.VerticalSpeedBug = m.page.getElementById("VS_Bug");
		m.VerticalSpeedBug.updateCenter();
		m.VerticalSpeedIndicated = m.page.getElementById("VS_Indicated");
		
		
		
	#AirSpeed
		m.cAirSpeedBar = m.page.getElementById("AirSpeedBar");
		m.cAirSpeedBar.set("clip","rect(126px, 648px, 784px, 413px)");
		m.cAirSpeedIndicatedOne = m.page.getElementById("AirSpeedIndicatedOne"); # 79.25
		m.cAirSpeedIndicatedOne.set("clip","rect(383px, 581px, 599px, 505px)");
		m.cAirSpeedIndicated = m.page.getElementById("AirSpeedIndicated");
		m.cAirSpeedTAS = m.page.getElementById("AirSpeedTAS");
		m.cAirSpeedBlackPlade = m.page.getElementById("AirSpeedBlackPlade");
		m.cAirSpeedBlackPlade.set("clip","rect(126px, 648px, 784px, 380px)");
		
		m.cGroundSpeed = m.page.getElementById("GroundSpeed");
		
	#autopilot
		m.cAutopilot		= m.page.getElementById("Autopilot");
		m.cAutopilotOff	= m.page.getElementById("AP_Off");
		m.cAutopilotOff.hide();
		m.cApModeState 		= m.page.getElementById("AP_State");
		m.cApModeHdg 		= m.page.getElementById("AP_HDG");
		m.cApModeHdg.hide(); 
		m.cApModeNav 		= m.page.getElementById("AP_NAV");
		m.cApModeNav.hide();
		m.cApModeAlt 		= m.page.getElementById("AP_ALT");
		m.cApModeAlt.hide();
		m.cApModeVs 		= m.page.getElementById("AP_VS");
		m.cApModeVs.hide();
		m.cApModeFd 		= m.page.getElementById("AP_FD");
		m.cApModeFd.hide();
		
	#alt
		m.AltIndicated = m.page.getElementById("AltIndicated");
		m.cHPA = m.page.getElementById("hPa");
		m.cAltBar10 = m.page.getElementById("AltBar10")
					.updateCenter()
					.set("clip","rect(377px, 2060px, 605px,1680px)");
		m.cAltBar100 = m.page.getElementById("AltBar100")
					.updateCenter()
					.set("clip","rect(451px, 2060px, 527px, 1680px)");
		m.cAltBar1000 = m.page.getElementById("AltBar1000")
					.updateCenter()
					.set("clip","rect(451px, 2060px, 527px, 1680px)");
		m.cAltBar10000 = m.page.getElementById("AltBar10000")
					.updateCenter()
					.set("clip","rect(451px, 2060px, 527px, 1680px)");
		m.cAltBarBack = m.page.getElementById("AltBarBack")
					.updateCenter()
					.set("clip","rect(170px, 2060px, 785px, 1680px)");
		m.cAltBlackPlade = m.page.getElementById("AltBlackPlade");
		m.cAltBlackPlade.set("clip","rect(170px, 2060px, 785px, 1680px)");
		
	#OAT
		m.cOAT = m.page.getElementById("OAT");
		#m.CompassRose.updateCenter();
		#m.CompassRose.setTranslation(100, -100);
		#m.CompassRose.setCenter(356,-356);
		
		#m.tfCompassRose = m.CompassRose.createTransform();
		debug.dump("AvidynePagePFD.new() ... for "~m.name~" IFD created.");
		#debug.dump(m.CompassRose.getBoundingBox());
		
	# Box Primary Nav 
		m.cNavSource 		= m.page.getElementById("NAV_SourceName");
		m.cNavAidName 		= m.page.getElementById("NAV_AidName");
		m.cNavAidDeg 		= m.page.getElementById("NAV_AidDeg");
		m.cNavAidDegUnit 	= m.page.getElementById("NAV_AidDegUnit");
		m.cNavDistance 		= m.page.getElementById("NAV_AidDistance");
		
		
		return m;
	},
	registerKeys : func(){
		
		
		me.IFD.nL1.setValue(1);
		me.keys["BARO >"] = func(){me.data.adjustBaro(1);};
		me.keys["BARO <"] = func(){me.data.adjustBaro(-1);};
		me.keys["BARO STD"] = func(){me.data.adjustBaro();};
		
		me.keys["L1 >"] = func(){me._adjustNavSource(1);};
		me.keys["L1 <"] = func(){me._adjustNavSource(-1);};
		
		me.keys["LK <<"] = func(){me._adjustRadial(-10);};
		me.keys["LK <"] = func(){me._adjustRadial(-1);};
		me.keys["LK >"] = func(){me._adjustRadial(1);};
		me.keys["LK >>"] = func(){me._adjustRadial(10);};
		
		
		
	},
	setListeners : func (){
		append(me._listeners,setlistener("/instrumentation/nav-source",func(n){me._onNavSourceChange(n);},1,0));
		#append(me._listeners,setlistener("/autopilot/radionav-channel/radials/reciprocal-radial",func(n){me._onNavAidDegChange(n);},1,0));
		#append(me._listeners,setlistener("/autopilot/radionav-channel/nav-distance-nm",func(n){me._onNavDistanceChange(n);},1,0));
		append(me._listeners,setlistener("/autopilot/radionav-channel/from-flag",func(n){me._onFromFlagChange(n);},1,0));
		append(me._listeners,setlistener("/autopilot/radionav-channel/radial-deg",func(n){me._onRadialChange(n);},1,0));
		append(me._listeners,setlistener("/autopilot/radionav-channel/is-localizer-frequency",func(n){me._onNavLocChange(n);},1,0));
		append(me._listeners,setlistener("/autopilot/radionav-channel/has-gs",func(n){me._onGSableChange(n);},1,0));
	},
	removeListeners : func(){
		foreach(l;me._listeners){
			removelistener(l);
		}
		me._listeners = [];
		foreach(l;me._navListeners){
			removelistener(l);
		}
		me._navListeners = [];
	},
	_onNavSourceChange : func(n){
		me.data.navSource = n.getValue();
		me.cNavSource.setText(NAV_SOURCE_NAME[me.data.navSource]);
		
		foreach(l;me._navListeners){
			removelistener(l);
		}
		me._navListeners = [];

		append(me._navListeners, setlistener(NAV_SOURCE_TREE[me.data.navSource]~"/nav-id",func(n){me._onNavIdChange(n);},1,0));
		#append(me._navListeners, setlistener(NAV_SOURCE_TREE[me.data.navSource]~"/nav-distance",func(n){me._onNavDistanceChange(n);},1,0));
		
	},
	_onFromFlagChange : func(n){
		me.data.FromFlag = n.getValue();
	},
	_onRadialChange : func(n){
		me.data.CoursePointer = n.getValue();
	},
	_onGSableChange : func(n){
		me.data.GSable = n.getValue();
		#print(""~me.name~" AvidynePagePFD._onGSableChange()");
		me._checkPrimaryNavBox();
	},
	_onNavLocChange : func(n){
		me.data.NAVLOC = n.getValue();
		me._checkPrimaryNavBox();
	},
	_onNavIdChange : func(n){
		me.data.navID = n.getValue();
		me._checkPrimaryNavBox();
	},
# 	_onNavAidDegChange : func(n){
# 		me.data.navDeg = n.getValue();
# 		#print(""~me.name~" AvidynePagePFD._onNavAidDegChange()" ~ me.data.navDeg);
# 		me.cNavAidDeg.setText(sprintf("%i",me.data.navDeg +0.5));
# 
# 	},
# 	_onNavDistanceChange : func(n){
# 		me.data.navDistance = n.getValue() * global.CONST.METER2NM;
# 		me.cNavDistance.setText(sprintf("%.1f",me.data.navDistance));
# 	},
	_checkPrimaryNavBox : func(){
		if (me.data.NAVLOC == 0){
			me.cNavAidName.setText(sprintf("%s (%s)",me.data.navID,"VOR"));
		}else{
			if (me.data.GSable == 1){
				me.cNavAidName.setText(sprintf("%s (%s)",me.data.navID,"ILS"));
			}else{
				me.cNavAidName.setText(sprintf("%s (%s)",me.data.navID,"LOC"));
			}
		}
		
		me.data.navDeg		= me.data.nNavDeg.getValue();
		me.data.navDistance	= me.data.nNavDistance.getValue();
		
		me.cNavDistance.setText(sprintf("%.1f",me.data.navDistance));
		me.cNavAidDeg.setText(sprintf("%i",me.data.navDeg +0.5));
	},
	_adjustNavSource : func (amount){
		me.data.navSource += amount;
		if (me.data.navSource > 1){
			me.data.navSource = 0;
		}
		if (me.data.navSource < 0){
			me.data.navSource = 1;
		}
		me.data.nNAVSource.setValue(me.data.navSource);
	},
	_adjustRadial : func(amount){
		me.data.CoursePointer += amount;
		me.data.CoursePointer = math.mod(me.data.CoursePointer,360.0);
		setprop("/instrumentation/nav[0]/radials/selected-deg",me.data.CoursePointer);
		setprop("/instrumentation/nav[1]/radials/selected-deg",me.data.CoursePointer);
	},
	_apUpdate : func(){
		if (me.data.apPowered){
			me.cAutopilotOff.hide();
			me.cAutopilot.show();
			if (me.data.apModeFail == 1){
				me.cApModeState.setText("AP FAIL");
				me.cApModeState.setColor(COLOR["Red"]);
				me.cApModeState.show();
				me.cApModeFd.hide();
			}else if (me.data.apModeRdy == 1 ){
				me.cApModeState.setText("AP RDY");
				me.cApModeState.setColor(COLOR["Green"]);
				me.cApModeState.show();
				me.cApModeFd.show();
			}else{
				me.cApModeState.hide();
			}
			
			if (me.data.apModeALT == 1){
				me.cApModeAlt.show();
			}else{
				me.cApModeAlt.hide();
			}
			
			if (me.data.apModeNAV == 1){
				me.cApModeNav.show();
			}else{
				me.cApModeNav.hide();
			}
			
			if (me.data.apModeVS == 1){
				me.cApModeVs.show();
				me.VerticalSpeedBug.set("fill",COLOR["Magenta"]);
			}else{
				me.cApModeVs.hide();
				me.VerticalSpeedBug.set("fill","none");
			}
			
			if (me.data.apModeHDG == 1){
				me.cApModeHdg.setText("HDG");
				me.cApModeHdg.show();
				me.HeadingBug.set("fill",COLOR["Magenta"]);
			}else{
				me.cApModeHdg.hide();
				me.HeadingBug.set("fill","none");
			}
			
			if (me.data.apModeFD == 1){
				me.cApModeFd.setText("FD");
			}else{
				me.cApModeFd.setText("AP");
			}
			
		}else{
			me.cAutopilot.hide();
			me.cAutopilotOff.show();
		}
	},
	update2Hz : func(now,dt){
		me.cNavDistance.setText(sprintf("%.1f",me.data.navDistance));
		me.cNavAidDeg.setText(sprintf("%i",me.data.navDeg +0.5));
		me.cGroundSpeed.setText(sprintf("%i",me.data.GroundSpeed +0.5));
	},
	update20Hz : func(now,dt){
		
		me._apUpdate();
		
	#wind & environment
		me.cWindSpeed.setText(sprintf("%3i",me.data.WindSpeed));
		me.cWindDirection.setText(sprintf("%03i",me.data.WindDirection));
		me.cWindArrow.setRotation((180 + me.data.WindDirection - me.data.HDG) * TORAD);
		me.cOAT.setText(sprintf("%2i",me.data.OAT));
				
	# IAS
		me.cAirSpeedBar.setTranslation(0,(me.data.IAS-20)*10);
		me.cAirSpeedIndicatedOne.setTranslation(0,(math.mod(me.data.IAS,10)*80));
		me.cAirSpeedIndicated.setText(sprintf("%2i",me.data.IAS/10));
		me.cAirSpeedTAS.setText(sprintf("%3i",me.data.TAS));
		
	# Vertical Speed
		me.VerticalSpeedIndicated.setText(sprintf("%4i",math.floor( me.data.VSBug + 0.5 )));
		me.VerticalSpeedNeedle.setRotation((me.data.VS/100*1.8) * TORAD);
		me.VerticalSpeedBug.setRotation((me.data.VSBug/100*1.8) * TORAD);
				
	#CompassRose
		me.HeadingSelected.setText(sprintf("%03i",me.data.HDGBug));
		me.Heading.setText(sprintf("%03i",math.floor( me.data.HDG + 0.5)));
		me.CompassRose.setRotation(-me.data.HDG * TORAD);
		me.HeadingBug.setRotation((me.data.HDGBug-me.data.HDG) * TORAD);
		
	#HSI
		me.PitchLadder.setRotation(-me.data.roll * TORAD);
		me.PitchLadder.setTranslation(0,me.data.pitch*10);
		me.BankAngleIndicator.setRotation(-me.data.roll * TORAD);
		
		me.nHorizon.setTranslation(0,me.data.pitch*10);
		me.nHorizon.setRotation(-me.data.roll * TORAD);
		
	#DI
		
		
		if(me.data.NAVinRange){
			me.cHDI_Needle.show();
			me.cHDI_Needle.setTranslation(me.data.HDI * 240,0);
		}else{
			me.cHDI_Needle.hide();
		}
		
		if(me.data.NAVLOC == 1){
			me.cDI_Source_Text.setText("LOC");
		}else{
			me.cDI_Source_Text.setText("VOR");
		}
		
		if(me.data.GSable == 1){
			me.cVDI.show();
			me.cDI_Source_Text.setText("ILS");
			if (me.data.GSinRange == 1){
				me.cVDI_Needle.setTranslation(0, me.data.VDI * 240);
				me.cVDI_Needle.show();
			}else{
				me.cVDI_Needle.hide();
				
			}
		}else{
			me.cVDI.hide();
		}
		
		if ((me.data.HDI >= 1.0) or (me.data.HDI <= -1.0)){
			me.cCDI.setColor(COLOR["Yellow"]);
			me.cHDI_Needle.setColor(COLOR["Yellow"]);
		}else{
			me.cCDI.setColor(COLOR["Green"]);
			me.cHDI_Needle.setColor(COLOR["White"]);
			
		}
		if(me.data.FromFlag == 0){
			me.cFromFlag.setRotation((180.0) * TORAD);
		}
		me.cCDI.setTranslation(me.data.HDI * 240,0);
		me.cCoursePointer.setRotation((me.data.CoursePointer-me.data.HDG) * TORAD);
		
		
	#ALT
		me.cHPA.setText(sprintf("%4i",me.data.HPA));
		me.AltIndicated.setText(sprintf("%4i",me.data.ALTBug));
		
		me.cAltBar10.setTranslation(0,math.mod(me.data.ALT,100)*(75.169/20));
		me.cAltBar100.setTranslation(0,math.floor((math.mod(me.data.ALT,1000)/100))*75.169);
		me.cAltBar1000.setTranslation(0,math.floor((math.mod(me.data.ALT,10000)/1000))*75.169);
		me.cAltBar10000.setTranslation(0,math.floor((math.mod(me.data.ALT,100000)/10000))*75.169);
		#me.cAltBar10000.setTranslation(0,math.floor(((me.alt)/1000))*7.5169);
		
		
		
		
	},
};


var AvidyneIFD = {
	new: func(nRoot,name,acPlace,startPage="none"){
		var m = { parents: [AvidyneIFD] };
		m.name = name;
		m.keys = {};
		m.nBacklight  	= nRoot.initNode("Backlight/state",1.0,"DOUBLE");
		
		m.nRoot = nRoot;
		m.canvas = canvas.new({
		"name": "IFD",
		"size": [2410, 1810],
		"view": [2410, 1810],
		"mipmapping": 1,
		});
		m.canvas.addPlacement({"node": acPlace});
		m.canvas.setColorBackground(0,0,0);
		
		# ... and place it on the object called PFD-Screen

		#m.nHeadingBug = props.globals.initNode("/instrumentation/heading-indicator-IFD-LH/indicated-heading-deg",0.0,"DOUBLE");
		
		m.data = AvidyneData.new(m.name);
		
		
		m.pageSelected = "none";
			
		
		m.nPageSelected = nRoot.initNode("PageSelected","","STRING");
		
		m.nL1 = nRoot.initNode("L1",0,"BOOL");
		m.nL2 = nRoot.initNode("L2",0,"BOOL");
		m.nL3 = nRoot.initNode("L3",0,"BOOL");
		m.nL4 = nRoot.initNode("L4",0,"BOOL");
		m.nL5 = nRoot.initNode("L5",0,"BOOL");
		m.nL6 = nRoot.initNode("L6",0,"BOOL");
		
		m.nR1 = nRoot.initNode("R1",0,"BOOL");
		m.nR2 = nRoot.initNode("R2",0,"BOOL");
		m.nR3 = nRoot.initNode("R3",0,"BOOL");
		m.nR4 = nRoot.initNode("R4",0,"BOOL");
		m.nR5 = nRoot.initNode("R5",0,"BOOL");
		m.nR6 = nRoot.initNode("R6",0,"BOOL");
		
		m._startPage = startPage;
		
		m.page = {};
		m.page["PFD"] = AvidynePagePFD.new(m,"PFD",m.data);
		m.page["none"] = AvidynePageDummy.new(m,"none",m.data);
		
		m._dt20Hz = 0;
		m._now20Hz = systime();
		m._last20Hz = systime();
		
		m._dt2Hz = 0;
		m._now2Hz = systime();
		m._last2Hz = systime();
		
		m._timerLoop20Hz = maketimer(0.05,m,AvidyneIFD.update20Hz);
		m._timerLoop2Hz = maketimer(0.5,m,AvidyneIFD.update2Hz);
	
		return m;
	},
	init : func(){
		me.initUI();
		
		me.keys["DIM >"] = func(){me._adjustBrightness(0.1);};
		me.keys["DIM <"] = func(){me._adjustBrightness(-0.1);};
		
		me.gotoPage(me._startPage);
		
		me._timerLoop20Hz.start();
		me._timerLoop2Hz.start();
		
	},
	connectDataBus : func(ifd){
		me.data.link = ifd;
	},
	update2Hz : func(){
		
		me._now2Hz = systime();
		me._dt2Hz = me._now2Hz - me._last2Hz;
		me._last2Hz = me._now2Hz;
				
		me.data.load2Hz();
		me.page[me.pageSelected].update2Hz(me._now2Hz,me._dt2Hz);		
	},
	update20Hz : func(){
		
		me._now20Hz = systime();
		me._dt20Hz = me._now20Hz - me._last20Hz;
		me._last20Hz = me._now20Hz;
				
		me.data.load20Hz();
		me.page[me.pageSelected].update20Hz(me._now20Hz,me._dt20Hz);		
	},
	clearLeds : func(){
		me.nL1.setValue(0);
		me.nL2.setValue(0);
		me.nL3.setValue(0);
		me.nL4.setValue(0);
		me.nL5.setValue(0);
		me.nL6.setValue(0);
		
		me.nR1.setValue(0);
		me.nR2.setValue(0);
		me.nR3.setValue(0);
		me.nR4.setValue(0);
		me.nR5.setValue(0);
		me.nR6.setValue(0);	
	},
	gotoPage : func(name){
		#print("IFD "~me.name ~" gotoPage("~name~") ... ");
		if (!contains(me.page,name)){
			name = "none";	
		}
		
		if (me.pageSelected != name){
			me.page[me.pageSelected].hide();
			me.page[me.pageSelected].removeListeners();
			me.pageSelected = name;
			me.nPageSelected.setValue(me.pageSelected);
			me.clearLeds();
			me.page[me.pageSelected].setListeners();
			me.page[me.pageSelected].registerKeys();
			me.page[me.pageSelected].show();
		}
		
	},
	_adjustBrightness : func(amount){
		var brightness = me.nBacklight.getValue();
		brightness += amount;
		brightness = global.clamp(brightness,0,1.0);
		me.nBacklight.setValue(brightness);
	},
	
	onClick: func(key){
		#print ("AvidyneIFD.onClick("~key~")");
		if (contains(me.keys,key)){
			me.keys[key]();
			return 1;
		}
		
		me.page[me.pageSelected].onClick(key);
	},
	initUI : func(){
		
		
		
		
		
		UI.register("IFD "~me.name~" L1 >",func{me.onClick("L1 >"); } );
		UI.register("IFD "~me.name~" L1 <",func{me.onClick("L1 <"); } );
		UI.register("IFD "~me.name~" L2 >",func{me.onClick("L2 >"); } );
		UI.register("IFD "~me.name~" L2 <",func{me.onClick("L2 <"); } );
		UI.register("IFD "~me.name~" L3 >",func{me.onClick("L3 >"); } );
		UI.register("IFD "~me.name~" L3 <",func{me.onClick("L3 <"); } );
		UI.register("IFD "~me.name~" L4 >",func{me.onClick("L4 >"); } );
		UI.register("IFD "~me.name~" L4 <",func{me.onClick("L4 <"); } );
		UI.register("IFD "~me.name~" L5 >",func{me.onClick("L5 >"); } );
		UI.register("IFD "~me.name~" L5 <",func{me.onClick("L5 <"); } );
		UI.register("IFD "~me.name~" L6 >",func{me.onClick("L6 >"); } );
		UI.register("IFD "~me.name~" L6 <",func{me.onClick("L6 <"); } );
		
		UI.register("IFD "~me.name~" R1 >",func{me.onClick("R1 >"); } );
		UI.register("IFD "~me.name~" R1 <",func{me.onClick("R1 <"); } );
		UI.register("IFD "~me.name~" R2 >",func{me.onClick("R2 >"); } );
		UI.register("IFD "~me.name~" R2 <",func{me.onClick("R2 <"); } );
		UI.register("IFD "~me.name~" R3 >",func{me.onClick("R3 >"); } );
		UI.register("IFD "~me.name~" R3 <",func{me.onClick("R3 <"); } );
		UI.register("IFD "~me.name~" R4 >",func{me.onClick("R4 >"); } );
		UI.register("IFD "~me.name~" R4 <",func{me.onClick("R4 <"); } );
		UI.register("IFD "~me.name~" R5 >",func{me.onClick("R5 >"); } );
		UI.register("IFD "~me.name~" R5 <",func{me.onClick("R5 <"); } );
		UI.register("IFD "~me.name~" R6 >",func{me.onClick("R6 >"); } );
		UI.register("IFD "~me.name~" R6 <",func{me.onClick("R6 <"); } );
		
		UI.register("IFD "~me.name~" PFD >",func{me.gotoPage("PFD");me.onClick("PFD >"); } );
		UI.register("IFD "~me.name~" PFD <",func{me.gotoPage("PFD");me.onClick("PFD <"); } );
		UI.register("IFD "~me.name~" FMS >",func{me.gotoPage("FMS");me.onClick("FMS >"); } );
		UI.register("IFD "~me.name~" FMS <",func{me.gotoPage("FMS");me.onClick("FMS <"); } );
		UI.register("IFD "~me.name~" MAP >",func{me.gotoPage("MAP");me.onClick("MAP >"); } );
		UI.register("IFD "~me.name~" MAP <",func{me.gotoPage("MAP");me.onClick("MAP <"); } );
		UI.register("IFD "~me.name~" SYS >",func{me.gotoPage("SYS");me.onClick("SYS >"); } );
		UI.register("IFD "~me.name~" SYS <",func{me.gotoPage("SYS");me.onClick("SYS <"); } );
		UI.register("IFD "~me.name~" CHKL >",func{me.gotoPage("CHKL");me.onClick("CHKL >"); } );
		UI.register("IFD "~me.name~" CHKL <",func{me.gotoPage("CHKL");me.onClick("CHKL <"); } );
		
		UI.register("IFD "~me.name~" BARO >",func{me.onClick("BARO >"); } );
		UI.register("IFD "~me.name~" BARO <",func{me.onClick("BARO <"); } );
		UI.register("IFD "~me.name~" BARO STD",func{me.onClick("BARO STD"); } );
		
		UI.register("IFD "~me.name~" RK >>",func{me.onClick("RK >>"); } );
		UI.register("IFD "~me.name~" RK <<",func{me.onClick("RK <<"); } );
		UI.register("IFD "~me.name~" RK",func{me.onClick("RK"); } );
		UI.register("IFD "~me.name~" RK >",func{me.onClick("RK >"); } );
		UI.register("IFD "~me.name~" RK <",func{me.onClick("RK <"); } );
		
		UI.register("IFD "~me.name~" LK >>",func{me.onClick("LK >>"); } );
		UI.register("IFD "~me.name~" LK <<",func{me.onClick("LK <<"); } );
		UI.register("IFD "~me.name~" LK",func{me.onClick("LK"); } );
		UI.register("IFD "~me.name~" LK >",func{me.onClick("LK >"); } );
		UI.register("IFD "~me.name~" LK <",func{me.onClick("LK <"); } );
		
		
		UI.register("IFD "~me.name~" DIM >",func{me.onClick("DIM >"); } );
		UI.register("IFD "~me.name~" DIM <",func{me.onClick("DIM <"); } );
		
		

				
	}
};


var LH = AvidyneIFD.new(props.globals.initNode("extra500/instrumentation/IFD-LH"),"LH","LH-IFD.Screen","PFD");
var RH = AvidyneIFD.new(props.globals.initNode("extra500/instrumentation/IFD-RH"),"RH","RH-IFD.Screen");

LH.connectDataBus(RH.data);
RH.connectDataBus(LH.data);




