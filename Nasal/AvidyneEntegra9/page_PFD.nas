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
#      Date: Jul 20 2013
#
#      Last change:      Dirk Dittmann
#      Date:             20.07.13
#



var NAV_SOURCE_NAME 	= ["Nav 1","Nav 2","FMS"];
var NAV_SOURCE_TREE 	= ["/instrumentation/nav[0]","/instrumentation/nav[1]","/instrumentation/fms"];

var BEARING_SOURCE_NAME = ["0ff","Nav 1","Nav 2","FMS"];
var BEARING_SOURCE_TREE = [nil,"/instrumentation/nav[0]","/instrumentation/nav[1]","/instrumentation/fms"];


var AvidynePagePFD = {
	new: func(ifd,name,data){
		var m = { parents: [
			AvidynePagePFD,
			PageClass.new(ifd,name,data)
		] };
		
		m._SubPages 	= ["Nav Display","Bug Select"];
		m._SubPageIndex = 0;
		m._navListeners = []; 
		m._brgListeners = []; 
		
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
			"font-mapper": global.canvas.FontMapper
			}
		);
				
		m.CompassRose = m.page.getElementById("CompassRose").updateCenter();
		m.cWindVector = m.page.getElementById("WindVector");
		m.cWindArrow = m.page.getElementById("WindArrow").updateCenter();
		
		m.HeadingBug = m.page.getElementById("HDG_Bug").updateCenter();
		m.Heading = m.page.getElementById("Heading");
		m.HeadingSelected = m.page.getElementById("HDG_Selected");
	#HSI
		m.BankAngleIndicator = m.page.getElementById("BankAngleIndicator");
		m.BankAngleIndicator.updateCenter();
		
		
		m.PitchLadder = m.page.getElementById("PitchLadder");
		m.PitchLadder.updateCenter();
		m.PitchLadder.set("clip","rect(168px, 1562px, 785px, 845px)");
		
		m.cARS = m.page.getElementById("ARS");
		
		m.cCoursePointer	= m.page.getElementById("CoursePointer");
		m.cCoursePointer.updateCenter();
		m.cCDI			= m.page.getElementById("CDI");
		m.cCDIFromFlag		= m.page.getElementById("CDI_FromFlag");
		m.cCDIToFlag		= m.page.getElementById("CDI_ToFlag");
		
		
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
		
		
		
	# IAS
		m.cIAS_Ladder = m.page.getElementById("IAS_Ladder")
					.set("clip","rect(126px, 648px, 784px, 413px)");
		m.cIAS_001 = m.page.getElementById("IAS_001") # 79.25
					.set("clip","rect(383px, 581px, 599px, 505px)");
		m.cIAS_010 = m.page.getElementById("IAS_010")
					.set("clip","rect(453px, 514px, 528px, 384px)");
		m.cIAS_100 = m.page.getElementById("IAS_100")
					.set("clip","rect(453px, 514px, 528px, 384px)");
		m.cIAS_BlackPlade = m.page.getElementById("IAS_BlackPlade");
		m.cIAS_Zero = m.page.getElementById("IAS_Zero").setVisible(0);
		m.cIAS_Rate = m.page.getElementById("IAS_Rate")
					.set("clip","rect(126px, 648px, 784px, 413px)");
		m.cIAS_TAS = m.page.getElementById("IAS_TAS");
		
		m.cGroundSpeed = m.page.getElementById("GroundSpeed");
		
	#autopilot
		m.cAutopilot		= m.page.getElementById("Autopilot");
		m.cAutopilotOff		= m.page.getElementById("AP_Off").setVisible(0);
		m.cApModeState 		= m.page.getElementById("AP_State");
		m.cApModeHdg 		= m.page.getElementById("AP_HDG").setVisible(0);
		m.cApModeNav 		= m.page.getElementById("AP_NAV").setVisible(0);
		m.cApModeApr 		= m.page.getElementById("AP_APR").setVisible(0);
		m.cApModeGPSS 		= m.page.getElementById("AP_GPSS").setVisible(0);
		m.cApModeTrim 		= m.page.getElementById("AP_TRIM").setVisible(0);
		m.cApModeAlt 		= m.page.getElementById("AP_ALT").setVisible(0);
		m.cApModeVs 		= m.page.getElementById("AP_VS").setVisible(0);
		m.cApModeCap 		= m.page.getElementById("AP_CAP").setVisible(0);
		m.cApModeSoft 		= m.page.getElementById("AP_SOFT").setVisible(0);
		m.cApModeFd 		= m.page.getElementById("AP_FD").setVisible(0);
		
	#alt
		
		m.cAltLayer	= m.page.getElementById("layer5");
		m.cAltLadder	= m.page.getElementById("ALT_Ladder")
					.set("clip","rect(170px, 2060px, 785px, 1680px)");
					
		m.cAltLad_Scale = m.page.getElementById("ALT_LAD_Scale");

		
		
# 		m.cAltLad_U400T	= m.page.getElementById("ALT_LAD_U400T").hide();
# 		m.cAltLad_U400H	= m.page.getElementById("ALT_LAD_U400H").hide();
		m.cAltLad_U300T	= m.page.getElementById("ALT_LAD_U300T");
		m.cAltLad_U300H	= m.page.getElementById("ALT_LAD_U300H");
		m.cAltLad_U200T	= m.page.getElementById("ALT_LAD_U200T");
		m.cAltLad_U200H	= m.page.getElementById("ALT_LAD_U200H");
		m.cAltLad_U100T	= m.page.getElementById("ALT_LAD_U100T");
		m.cAltLad_U100H	= m.page.getElementById("ALT_LAD_U100H");
		
		m.cAltLad_C000T	= m.page.getElementById("ALT_LAD_C000T");
		m.cAltLad_C000H	= m.page.getElementById("ALT_LAD_C000H");
		
		
		m.cAltLad_D100T	= m.page.getElementById("ALT_LAD_D100T");
		m.cAltLad_D100H	= m.page.getElementById("ALT_LAD_D100H");
		m.cAltLad_D200T	= m.page.getElementById("ALT_LAD_D200T");
		m.cAltLad_D200H	= m.page.getElementById("ALT_LAD_D200H");
# 		m.cAltLad_D300T	= m.page.getElementById("ALT_LAD_D300T").hide();
# 		m.cAltLad_D300H	= m.page.getElementById("ALT_LAD_D300H").hide();
# 		m.cAltLad_D400T	= m.page.getElementById("ALT_LAD_D400T").hide();
# 		m.cAltLad_D400H	= m.page.getElementById("ALT_LAD_D400H").hide();
		
		
		m.cAltBar10 = m.page.getElementById("AltBar10")
# 					.updateCenter()
					.set("clip","rect(377px, 2060px, 605px,1680px)")
					.set("z-index",3)
					;
		m.cAltBar100 = m.page.getElementById("AltBar100")
# 					.updateCenter()
					.set("clip","rect(451px, 2060px, 527px, 1680px)")
					.set("z-index",3)
					;
		m.cAltBar1000 = m.page.getElementById("AltBar1000")
# 					.updateCenter()
					.set("clip","rect(451px, 2060px, 527px, 1680px)")
					.set("z-index",3)
					;
		m.cAltBar10000 = m.page.getElementById("AltBar10000")
# 					.updateCenter()
					.set("clip","rect(451px, 2060px, 527px, 1680px)")
					.set("z-index",3)
					;
		m.cAltBlackPlade = m.page.getElementById("AltBlackPlade")
					.set("clip","rect(95px, 2070px, 880px, 1680px)")
					.set("z-index",2)
# 					.hide();
					;
					
		m.cAltBug = m.page.getElementById("ALT_Bug").set("z-index",4);
		m.cAltUbox = m.page.getElementById("ALT_UBOX").set("z-index",5);
		m.cAltDbox = m.page.getElementById("ALT_DBOX").set("z-index",5);
		m.cAltBorder = m.page.getElementById("ALT_Border").set("z-index",5);
					
		m.cAltSelected = m.page.getElementById("ALT_Selected");
		m.cHPA = m.page.getElementById("hPa");
		
	#OAT
		m.cOAT = m.page.getElementById("OAT");
		#m.CompassRose.updateCenter();
		#m.CompassRose.setTranslation(100, -100);
		#m.CompassRose.setCenter(356,-356);
		
		#m.tfCompassRose = m.CompassRose.createTransform();
		debug.dump("AvidynePagePFD.new() .. for "~m.name~" IFD created.");
		#debug.dump(m.CompassRose.getBoundingBox());
		
	# Box Primary Nav 
		m.cNavSource 		= m.page.getElementById("NAV_SourceName");
		m.cNavID 		= m.page.getElementById("NAV_ID");
		m.cNavCrs 		= m.page.getElementById("NAV_CRS");
		m.cNavCrsUnit 		= m.page.getElementById("NAV_CRS_Unit");
		m.cNavDistance 		= m.page.getElementById("NAV_Distance");
	# Box Bearing Pointer
		
		m.cBearingOff 		= m.page.getElementById("BearingPtr_Off");
		m.cBearingOn	 	= m.page.getElementById("BearingPtr_On").setVisible(0);
		m.cBearingSource 	= m.page.getElementById("BearingPtr_Source");
		m.cBearingID 		= m.page.getElementById("BearingPtr_ID");
		m.cBearingBrg 		= m.page.getElementById("BearingPtr_BRG");
		m.cBearingBrgUnit 	= m.page.getElementById("BearingPtr_Unit");
		m.cBearingDistance 	= m.page.getElementById("BearingPtr_NM");
		m.cBearingPointer 	= m.page.getElementById("BearingPtr_Pointer").updateCenter().setVisible(0);
		
	# Box Timer
		m.cTimerOn 		= m.page.getElementById("Timer_On");
		m.cTimerBtnCenter	= m.page.getElementById("Timer_btn_Center");
		m.cTimerBtnLeft		= m.page.getElementById("Timer_btn_Left");
		m.cTimerTime 		= m.page.getElementById("Timer_Time");
		
	# Page NavDisplay
		m.cPage_NavDisplay	= m.page.getElementById("Page_NavDisplay");
	# Page BugSelect
		m.cPage_BugSelect	= m.page.getElementById("Page_BugSelect").setVisible(0);
		m.cSetHeading		= m.page.getElementById("Set_Heading");
		m.cSetHeadingBorder	= m.page.getElementById("Set_Heading_Border");
		m.cSetAltitude		= m.page.getElementById("Set_Altitude");
		m.cSetAltitudeBorder	= m.page.getElementById("Set_Altitude_Border");
		m.cSetVs		= m.page.getElementById("Set_VS");
		m.cSetVsBorder		= m.page.getElementById("Set_VS_Border");
# funny unreal Ice Warning just for Test
		m._cIceWarning		= m.page.getElementById("ICE_Warning").hide();
		return m;
	},
	registerKeys : func(){
		
		
		me.IFD.nLedBaro.setValue(1);
		me.keys["BARO >"] = func(){me.data.adjustBaro(1);};
		me.keys["BARO <"] = func(){me.data.adjustBaro(-1);};
		me.keys["BARO STD"] = func(){me.data.adjustBaro();};
		
		me.IFD.nLedL1.setValue(1);
		me.keys["L1 >"] = func(){me._adjustNavSource(1);};
		me.keys["L1 <"] = func(){me._adjustNavSource(-1);};
		
		me.IFD.nLedL3.setValue(1);
		me.keys["L3 >"] = func(){me._scrollBrg(1);};
		me.keys["L3 <"] = func(){me._scrollBrg(-1);};
		
		me.IFD.nLedLK.setValue(1);
		me.keys["LK <<"] = func(){me._adjustRadial(-10);};
		me.keys["LK <"] = func(){me._adjustRadial(-1);};
		me.keys["LK >"] = func(){me._adjustRadial(1);};
		me.keys["LK >>"] = func(){me._adjustRadial(10);};
		
		me.keys["PFD >"] = func(){me._scrollSubPage(1);};
		me.keys["PFD <"] = func(){me._scrollSubPage(-1);};
		
		
		me._timerRegisterKeys();
	},
	setListeners : func (){
		append(me._listeners,setlistener("/instrumentation/nav-source",func(n){me._onNavSourceChange(n);},1,0));
		#append(me._listeners,setlistener("/autopilot/radionav-channel/radials/reciprocal-radial",func(n){me._onNavAidDegChange(n);},1,0));
		#append(me._listeners,setlistener("/autopilot/radionav-channel/nav-distance-nm",func(n){me._onNavDistanceChange(n);},1,0));
		append(me._listeners,setlistener("/autopilot/radionav-channel/from-flag",func(n){me._onFromFlagChange(n);},1,0));
		append(me._listeners,setlistener("/autopilot/radionav-channel/to-flag",func(n){me._onToFlagChange(n);},1,0));
		append(me._listeners,setlistener("/autopilot/radionav-channel/radial-deg",func(n){me._onRadialChange(n);},1,0));
		append(me._listeners,setlistener("/autopilot/radionav-channel/is-localizer-frequency",func(n){me._onNavLocChange(n);},1,0));
		append(me._listeners,setlistener("/autopilot/gs-channel/has-gs",func(n){me._onGSableChange(n);},1,0));
		
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
		append(me._navListeners, setlistener(NAV_SOURCE_TREE[me.data.navSource]~"/frequencies/selected-mhz-fmt",func(n){me._onNavFrequencyChange(n);},1,0));
		
	},
	_onFromFlagChange : func(n){
		me.data.cdiFromFlag = n.getValue();
	},
	_onToFlagChange : func(n){
		me.data.cdiToFlag = n.getValue();
	},
	_onRadialChange : func(n){
		me.data.navCoursePointer = n.getValue();
		me._checkPrimaryNavBox();
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
	_onNavFrequencyChange : func(n){
		me.data.navFrequency = n.getValue();
		me._checkPrimaryNavBox();
	},
	_checkPrimaryNavBox : func(){
		if (me.data.NAVLOC == 0){
			me.cNavID.setText(sprintf("%.2f (%s)",me.data.navFrequency,"VOR"));
		}else{
			if (me.data.GSable == 1){
				me.cNavID.setText(sprintf("%.2f (%s)",me.data.navFrequency,"ILS"));
			}else{
				me.cNavID.setText(sprintf("%.2f (%s)",me.data.navFrequency,"LOC"));
			}
		}
		
		me.data.navDistance	= me.data.nNavDistance.getValue();
		
		me.cNavDistance.setText(sprintf("%.1f",me.data.navDistance));
		me.cNavCrs.setText(sprintf("%i",me.data.navCoursePointer +0.5));
	},
	
### Bearing Pointer Box
	
	_scrollBrg : func(amount){
		me.data.brgSource += amount;
		if (me.data.brgSource > 2){ me.data.brgSource = 0; }
		if (me.data.brgSource < 0){ me.data.brgSource = 2; }
		me.cBearingSource.setText(BEARING_SOURCE_NAME[me.data.brgSource]);
		foreach(l;me._brgListeners){
			removelistener(l);
		}
		me._brgListeners = [];
		
		if(me.data.brgSource == 0){
			me.cBearingOn.setVisible(0);
			me.cBearingOff.setVisible(1);
		}elsif(me.data.brgSource == 1){
			me.cBearingOff.setVisible(0);
			me.cBearingOn.setVisible(1);
			append(me._navListeners, setlistener(BEARING_SOURCE_TREE[me.data.brgSource]~"/nav-id",func(n){me._onBrgIdChange(n);},1,0));
			append(me._navListeners, setlistener(BEARING_SOURCE_TREE[me.data.brgSource]~"/frequencies/selected-mhz-fmt",func(n){me._onBrgFrequencyChange(n);},1,0));
			append(me._navListeners, setlistener(BEARING_SOURCE_TREE[me.data.brgSource]~"/frequencies/is-localizer-frequency",func(n){me._onBrgNavLocChange(n);},1,0));
			append(me._navListeners, setlistener(BEARING_SOURCE_TREE[me.data.brgSource]~"/has-gs",func(n){me._onBrgGsAbleChange(n);},1,0));
		
		
		}elsif(me.data.brgSource == 2){
			me.cBearingOff.setVisible(0);
			me.cBearingOn.setVisible(1);
			
			append(me._navListeners, setlistener(BEARING_SOURCE_TREE[me.data.brgSource]~"/nav-id",func(n){me._onBrgIdChange(n);},1,0));
			append(me._navListeners, setlistener(BEARING_SOURCE_TREE[me.data.brgSource]~"/frequencies/selected-mhz-fmt",func(n){me._onBrgFrequencyChange(n);},1,0));
			append(me._navListeners, setlistener(BEARING_SOURCE_TREE[me.data.brgSource]~"/frequencies/is-localizer-frequency",func(n){me._onBrgNavLocChange(n);},1,0));
			append(me._navListeners, setlistener(BEARING_SOURCE_TREE[me.data.brgSource]~"/has-gs",func(n){me._onBrgGsAbleChange(n);},1,0));
		
		}elsif(me.data.brgSource == 3){
			me.cBearingOff.setVisible(0);
			me.cBearingOn.setVisible(1);
		}
		
	},
	_onBrgIdChange : func(n){
		me.data.brgID = n.getValue();
		me._checkBrgBox();
	},
	_onBrgFrequencyChange : func(n){
		me.data.brgFrequency = n.getValue();
		me._checkBrgBox();
	},
	_onBrgNavLocChange : func(n){
		me.data.brgNAVLOC = n.getValue();
		me._checkBrgBox();
	},
	_onBrgGsAbleChange : func(n){
		me.data.brgGSable = n.getValue();
		me._checkBrgBox();
	},
	_checkBrgBox : func(){
		if (me.data.brgSource > 0){
			if (me.data.brgNAVLOC == 0){
				me.cBearingID.setText(sprintf("%.2f (%s)",me.data.brgFrequency,"VOR"));
			}else{
				if (me.data.brgGSable == 1){
					me.cBearingID.setText(sprintf("%.2f (%s)",me.data.brgFrequency,"ILS"));
				}else{
					me.cBearingID.setText(sprintf("%.2f (%s)",me.data.brgFrequency,"LOC"));
				}
			}
			
			me.data.brgDistance	= getprop(BEARING_SOURCE_TREE[me.data.brgSource]~"/nav-distance") * global.CONST.METER2NM;
			
			me.cBearingDistance.setText(sprintf("%.1f",me.data.brgDistance));
			me.cBearingBrg.setText(sprintf("%i",me.data.brgCoursePointer +0.5));
		}
	},
	
### Using The Timer Pilot Guide Page 88
	_timerRegisterKeys : func(){
		if ((me.data.timerState == 0)){
			me.IFD.nLedR2.setValue(1);
			me.keys["R2 <"] = func(){me.data.timerStart();me._timerRegisterKeys();};
			me.keys["R2 >"] = func(){me.data.timerStart();me._timerRegisterKeys();};
			me.cTimerOn.setVisible(0);
			me.cTimerBtnCenter.setVisible(1);
			
		}elsif ((me.data.timerState == 1)){
			me.IFD.nLedR2.setValue(1);
			me.keys["R2 <"] = func(){me.data.timerStart();me._timerRegisterKeys();};
			me.keys["R2 >"] = func(){me.data.timerReset();me._timerRegisterKeys();};
			me.cTimerBtnLeft.setText("Start");
			me.cTimerOn.setVisible(1);
			me.cTimerBtnCenter.setVisible(0);
		}elsif ((me.data.timerState == 2)){
			me.IFD.nLedR2.setValue(1);
			me.keys["R2 <"] = func(){me.data.timerStop();me._timerRegisterKeys();};
			me.keys["R2 >"] = func(){me.data.timerReset();me._timerRegisterKeys();};
			me.cTimerBtnLeft.setText("Stop");
			me.cTimerOn.setVisible(1);
			me.cTimerBtnCenter.setVisible(0);
		}
	},
		
	_adjustNavSource : func (amount){
		me.data.navSource += amount;
		if (me.data.navSource > 2){
			me.data.navSource = 0;
		}
		if (me.data.navSource < 0){
			me.data.navSource = 2;
		}
		me.data.nNAVSource.setValue(me.data.navSource);
	},
	_adjustRadial : func(amount){
		me.data.navCoursePointer += amount;
		me.data.navCoursePointer = math.mod(me.data.navCoursePointer,360.0);
		setprop("/instrumentation/nav[0]/radials/selected-deg",me.data.navCoursePointer);
		setprop("/instrumentation/nav[1]/radials/selected-deg",me.data.navCoursePointer);
	},
	_scrollSubPage : func(amount){
		me._SubPageIndex += amount;
		if (me._SubPageIndex > 1){
			me._SubPageIndex = 0;
		}
		if (me._SubPageIndex < 0){
			me._SubPageIndex = 1;
		}
		if (me._SubPageIndex == 0){ # Page NavDisplay
			me.cPage_BugSelect.setVisible(0);
			me.cPage_NavDisplay.setVisible(1);
			
			me.IFD.nLedR3.setValue(0);
			delete(me.keys,"R3 <");
			delete(me.keys,"R3 >");
			me.IFD.nLedR4.setValue(0);
			delete(me.keys,"R4 <");
			delete(me.keys,"R4 >");
			me.IFD.nLedR5.setValue(0);
			delete(me.keys,"R5 <");
			delete(me.keys,"R5 >");
			
			me._setModeRK();
			
		}elsif(me._SubPageIndex == 1){ # Page BugSelect
			me.cPage_BugSelect.setVisible(1);
			me.cPage_NavDisplay.setVisible(0);
			me.IFD.nLedR3.setValue(1);
			me.keys["R3 <"] = func(){me._setModeRK("HDG");};
			me.keys["R3 >"] = func(){me._setModeRK("HDG");};
			me.IFD.nLedR4.setValue(1);
			me.keys["R4 <"] = func(){me._setModeRK("ALT");};
			me.keys["R4 >"] = func(){me._setModeRK("ALT");};
			me.IFD.nLedR5.setValue(1);
			me.keys["R5 <"] = func(){me._setModeRK("VS");};
			me.keys["R5 >"] = func(){me._setModeRK("VS");};
			
			
		}else{
			print("_scrollSubPage() ... mist");
		}
	},
	_setModeRK : func(value=nil){
		
		me._modeRK = value;
		
		if (me._modeRK == "HDG"){
			me.cSetHeadingBorder.set("stroke",COLOR["Turquoise"]);
			me.cSetHeadingBorder.set("stroke-width",20);
			me.cSetHeading.set("z-index",2);
			me.cSetAltitudeBorder.set("stroke",COLOR["Blue"]);
			me.cSetAltitudeBorder.set("stroke-width",10);
			me.cSetAltitude.set("z-index",1);
			me.cSetVsBorder.set("stroke",COLOR["Blue"]);
			me.cSetVsBorder.set("stroke-width",10);
			me.cSetVs.set("z-index",1);
			
			me.IFD.nLedRK.setValue(1);
			me.keys["RK >>"] 	= func(){extra500.keypad.onAdjustHeading(10);};
			me.keys["RK <<"] 	= func(){extra500.keypad.onAdjustHeading(-10);};
			me.keys["RK"] 		= func(){extra500.keypad.onHeadingSync();};
			me.keys["RK >"] 	= func(){extra500.keypad.onAdjustHeading(1);};
			me.keys["RK <"] 	= func(){extra500.keypad.onAdjustHeading(-1);};
		}elsif (me._modeRK == "ALT"){
			me.cSetHeadingBorder.set("stroke",COLOR["Blue"]);
			me.cSetHeadingBorder.set("stroke-width",10);
			me.cSetHeading.set("z-index",1);
			me.cSetAltitudeBorder.set("stroke",COLOR["Turquoise"]);
			me.cSetAltitudeBorder.set("stroke-width",20);
			me.cSetAltitude.set("z-index",2);
			me.cSetVsBorder.set("stroke",COLOR["Blue"]);
			me.cSetVsBorder.set("stroke-width",10);
			me.cSetVs.set("z-index",1);
						
			me.IFD.nLedRK.setValue(1);
			me.keys["RK >>"] 	= func(){extra500.keypad.onAdjustAltitude(500);};
			me.keys["RK <<"] 	= func(){extra500.keypad.onAdjustAltitude(-500);};
			me.keys["RK"] 		= func(){extra500.keypad.onHeadingSync();};
			me.keys["RK >"] 	= func(){extra500.keypad.onAdjustAltitude(100);};
			me.keys["RK <"] 	= func(){extra500.keypad.onAdjustAltitude(-100);};
		}elsif (me._modeRK == "VS"){
			me.cSetHeadingBorder.set("stroke",COLOR["Blue"]);
			me.cSetHeadingBorder.set("stroke-width",10);
			me.cSetHeading.set("z-index",1);
			me.cSetAltitudeBorder.set("stroke",COLOR["Blue"]);
			me.cSetAltitudeBorder.set("stroke-width",10);
			me.cSetAltitude.set("z-index",1);
			me.cSetVsBorder.set("stroke",COLOR["Turquoise"]);
			me.cSetVsBorder.set("stroke-width",20);
			me.cSetVs.set("z-index",2);
			
			me.IFD.nLedRK.setValue(1);
			me.keys["RK >>"] 	= func(){extra500.autopilot.onAdjustVS(-100);};
			me.keys["RK <<"] 	= func(){extra500.autopilot.onAdjustVS(100);};
			me.keys["RK"] 		= func(){extra500.autopilot.onSetVS(0);};
			me.keys["RK >"] 	= func(){extra500.autopilot.onAdjustVS(-100);};
			me.keys["RK <"] 	= func(){extra500.autopilot.onAdjustVS(100);};
		}else{
			
			me.cSetHeadingBorder.set("stroke",COLOR["Blue"]);
			me.cSetHeadingBorder.set("stroke-width",10);
			me.cSetHeading.set("z-index",1);
			me.cSetAltitudeBorder.set("stroke",COLOR["Blue"]);
			me.cSetAltitudeBorder.set("stroke-width",10);
			me.cSetAltitude.set("z-index",1);
			me.cSetVsBorder.set("stroke",COLOR["Blue"]);
			me.cSetVsBorder.set("stroke-width",10);
			me.cSetVs.set("z-index",1);
						
			me.IFD.nLedRK.setValue(0);
			delete(me.keys,"RK >>");
			delete(me.keys,"RK <<");
			delete(me.keys,"RK");
			delete(me.keys,"RK >");
			delete(me.keys,"RK <");
		}
	},
	_apUpdate : func(){
		if (me.data.apPowered){
			me.cAutopilotOff.setVisible(0);
			me.cAutopilot.setVisible(1);
			if (me.data.apModeFail == 1){
				me.cApModeState.setText("AP FAIL");
				me.cApModeState.setColor(COLOR["Yellow"]);
				me.cApModeState.setVisible(1);
				me.cApModeFd.setVisible(0);
			}else if (me.data.apModeRdy == 1 ){
				me.cApModeState.setText("AP RDY");
				me.cApModeState.setColor(COLOR["Green"]);
				me.cApModeState.setVisible(1);
				me.cApModeFd.setVisible(1);
			}else{
				me.cApModeState.setVisible(0);
			}
			
			if (me.data.apModeALT == 1){
				me.cApModeAlt.setVisible(1);
				me.cAltBug.set("fill",COLOR["Magenta"]);
			}else{
				me.cApModeAlt.setVisible(0);
				me.cAltBug.set("fill","none");
			}
			
			if (me.data.apModeNAV == 1){
				me.cApModeNav.setVisible(1);
			}else{
				me.cApModeNav.setVisible(0);
			}
			
			if (me.data.apModeAPR == 1){
				me.cApModeApr.setVisible(1);
			}else{
				me.cApModeApr.setVisible(0);
			}
			
			if (me.data.apModeGPSS == 1){
				me.cApModeGPSS.setVisible(1);
			}else{
				me.cApModeGPSS.setVisible(0);
			}
			
			if (me.data.apModeTRIM == 1){
				me.cApModeTrim.setVisible(1);
			}else{
				me.cApModeTrim.setVisible(0);
			}
			
			if (me.data.apModeCAP == 1){
				me.cApModeCap.setVisible(1);
			}else{
				me.cApModeCap.setVisible(0);
			}
			
			if (me.data.apModeSOFT == 1){
				me.cApModeSoft.setVisible(1);
			}else{
				me.cApModeSoft.setVisible(0);
			}
			
			if (me.data.apModeVS == 1){
				me.cApModeVs.setVisible(1);
				me.VerticalSpeedBug.set("fill",COLOR["Magenta"]);
			}else{
				me.cApModeVs.setVisible(0);
				me.VerticalSpeedBug.set("fill","none");
			}
			
			if (me.data.apModeHDG == 1){
				me.cApModeHdg.setText("HDG");
				me.cApModeHdg.setVisible(1);
				me.HeadingBug.set("fill",COLOR["Magenta"]);
			}else{
				me.cApModeHdg.setVisible(0);
				me.HeadingBug.set("fill","none");
			}
			
			if (me.data.apModeFD == 1){
				me.cApModeFd.setText("FD");
			}else{
				me.cApModeFd.setText("AP");
			}
			
		}else{
			me.cAutopilot.setVisible(0);
			me.cAutopilotOff.setVisible(1);
		}
	},
	
# Ice Warning
	update2Hz : func(now,dt){
		me.cNavDistance.setText(sprintf("%.1f",me.data.navDistance));
		me.cNavCrs.setText(sprintf("%i",me.data.navCoursePointer +0.5));
		
		me.cBearingDistance.setText(sprintf("%.1f",me.data.brgDistance));
		me.cBearingBrg.setText(sprintf("%i",me.data.brgCoursePointer +0.5));
		
		me.cGroundSpeed.setText(sprintf("%i",me.data.GroundSpeed +0.5));
		me.cTimerTime.setText(me.data.timerGetTime());
		
		# Ice Warning
		
		me._cIceWarning.setVisible(getprop("/extra500/system/deice/iceWarning"));
		
	
	},
	update20Hz : func(now,dt){
		
		me._apUpdate();
		
	#wind & environment
		if (me.data.WindSpeed > 2){
			me.cWindVector.setText(sprintf("%03i / %3i",me.data.WindDirection,me.data.WindSpeed));
			me.cWindArrow.setRotation((180 + me.data.WindDirection - me.data.HDG) * global.CONST.DEG2RAD);
			me.cWindArrow.setVisible(1);
		}else{
			me.cWindVector.setText("Wind Calm");
			me.cWindArrow.setVisible(0);
		}
		
		me.cOAT.setText(sprintf("%2i",me.data.OAT));
				
	# IAS
		me.cIAS_Ladder.setTranslation(0,(me.data.IAS-20)*10);
		
		
		var speed 	= 0;
		var speedadd 	= 0;
		var iasLadderpx	= 74.596;
		var ias_Vso	= 58;
		var ias_Vne	= 207;
		var ias_Zero	= 20;
		
		#me.data.IAS_Rate = (( me.data.IAS_Last - me.data.IAS) * dt * 60);
		#me.data.IAS_Last = me.data.IAS ;
		
		if (me.data.IAS < ias_Zero){
			me.cIAS_100.setVisible(0);
			me.cIAS_010.setVisible(0);
			me.cIAS_001.setVisible(0);
			me.cIAS_Zero.setVisible(1);
			me.cIAS_BlackPlade.setVisible(0);
			me.cIAS_TAS.setText("---");
			me.cIAS_Rate.setVisible(0);
		}else{
			
			#me.cIAS_Rate.setScale(1,me.data.IAS_Rate / 10);
			#me.cIAS_Rate.setTranslation(0,(-me.data.IAS_Rate / 10) *5);
			me.cIAS_Rate.setVisible(1);
			me.cIAS_Rate.setData([2,6,8,6,0],[585.5,491.4286+(-me.data.IAS_Rate*62),604,491.4286,585.5]);
			
			me.cIAS_TAS.setText(sprintf("%3i",me.data.TAS));
			me.cIAS_BlackPlade.setVisible(1);
			me.cIAS_Zero.setVisible(0);
			speed = math.mod(me.data.IAS,10);
			me.cIAS_001.setTranslation(0,(speed * iasLadderpx));
			me.cIAS_001.setVisible(1);
			
			if (me.data.IAS > 10){
				
				if (speed >= 9){
					speedadd = speed - 9;
				}else{
					speedadd = 0;
				}
						
				speed = math.floor(math.mod(me.data.IAS,100)/10);
				me.cIAS_010.setTranslation(0,((speed+speedadd) * iasLadderpx));
				me.cIAS_010.setVisible(1);
				if (me.data.IAS > 100){
					
					if (speed < 9){
						speedadd = 0;
					}
					
					speed = math.floor(math.mod(me.data.IAS,1000)/100);
					me.cIAS_100.setTranslation(0,((speed+speedadd) * iasLadderpx));
					me.cIAS_100.setVisible(1);
				
					me.cIAS_100.setVisible(1);
				}else{
					me.cIAS_100.setVisible(0);
				}
				
				
			}else{
				me.cIAS_100.setVisible(0);
				me.cIAS_010.setVisible(0);
			}
			
			
			if( me.data.IAS >= ias_Vne){
				me.cIAS_100.set("fill",COLOR["Red"]);
				me.cIAS_010.set("fill",COLOR["Red"]);
				me.cIAS_001.set("fill",COLOR["Red"]);
			}elsif (me.data.IAS < ias_Vso){
				me.cIAS_100.set("fill",COLOR["Red"]);
				me.cIAS_010.set("fill",COLOR["Red"]);
				me.cIAS_001.set("fill",COLOR["Red"]);
			}else{
				me.cIAS_100.set("fill",COLOR["White"]);
				me.cIAS_010.set("fill",COLOR["White"]);
				me.cIAS_001.set("fill",COLOR["White"]);
			}

			if( me.data.IAS >= ias_Vne + 3.0){
				me.IFD._nOverSpeedWarning.setValue(1);
			}elsif (me.data.IAS < ias_Vso){
				me.IFD._nOverSpeedWarning.setValue(0);
			}else{
				me.IFD._nOverSpeedWarning.setValue(0);
			}
		
		}
		
		
		
	# Vertical Speed
		me.VerticalSpeedIndicated.setText(sprintf("%4i",math.floor( me.data.VSBug + 0.5 )));
		if (me.data.VS >= -1000){
			if (me.data.VS <= 1000){
				me.VerticalSpeedNeedle.setRotation((me.data.VS/100*1.50) * global.CONST.DEG2RAD);
			}else{
				me.VerticalSpeedNeedle.setRotation( ( 15 + ((me.data.VS-1000)/100*0.75) ) * global.CONST.DEG2RAD);
			}
		}else{
			me.VerticalSpeedNeedle.setRotation( ( -15 + ((me.data.VS+1000)/100*0.75) ) * global.CONST.DEG2RAD);
		}
		if (me.data.VSBug >= -1000 ){
			if (me.data.VSBug <= 1000){
				me.VerticalSpeedBug.setRotation((me.data.VSBug/100*1.50) * global.CONST.DEG2RAD);
			}else{
				me.VerticalSpeedBug.setRotation( ( 15 + ((me.data.VSBug-1000)/100*0.75) ) * global.CONST.DEG2RAD);
			}
		}else{
			me.VerticalSpeedBug.setRotation( ( -15 + ((me.data.VSBug+1000)/100*0.75) ) * global.CONST.DEG2RAD);
		}
				
	#CompassRose
		me.HeadingSelected.setText(sprintf("%03i",me.data.HDGBug));
		me.Heading.setText(sprintf("%03i",math.floor( me.data.HDG + 0.5)));
		me.CompassRose.setRotation(-me.data.HDG * global.CONST.DEG2RAD);
		me.HeadingBug.setRotation((me.data.HDGBug-me.data.HDG) * global.CONST.DEG2RAD);
		
		if (me.data.brgSource > 0){
			me.cBearingPointer.setRotation((me.data.brgCoursePointer-me.data.HDG) * global.CONST.DEG2RAD);
			me.cBearingPointer.setVisible(1);
		}else{
			me.cBearingPointer.setVisible(0);
		}
	#HSI
		me.PitchLadder.setRotation(-me.data.roll * global.CONST.DEG2RAD);
		me.PitchLadder.setTranslation(0,me.data.pitch*10);
		me.BankAngleIndicator.setRotation(-me.data.roll * global.CONST.DEG2RAD);
		
		me.nHorizon.setTranslation(0,me.data.pitch*10);
		me.nHorizon.setRotation(-me.data.roll * global.CONST.DEG2RAD);
		
	#DI
		
		
		if(me.data.NAVinRange == 1){
			me.cHDI_Needle.setVisible(1);
			me.cHDI_Needle.setTranslation(me.data.HDI * 240,0);
			me.cDI.setVisible(1);
			me.cCDI.setVisible(1);
			
			if(me.data.NAVLOC == 1){
				me.cDI_Source_Text.setText("LOC");
			}else{
				me.cDI_Source_Text.setText("VOR");
			}
			
			if (me.data.GSinRange == 1){
				me.cVDI.setVisible(1);
				me.cVDI_Needle.setTranslation(0, me.data.VDI * 240);
				me.cVDI_Needle.setVisible(1);
				me.cDI_Source_Text.setText("ILS");
			}else{
				me.cVDI.setVisible(0);
				me.cVDI_Needle.setVisible(0);
				
			}
			
			if ((me.data.VDI <= -0.99) or (me.data.VDI >= 0.99)){
				me.cVDI_Needle.set("fill",COLOR["Yellow"]);
			}else{
				me.cVDI_Needle.set("fill",COLOR["White"]);
			}
			
			if ((me.data.HDI <= -0.99) or (me.data.HDI >= 0.99)){
				me.cCDI.set("fill",COLOR["Yellow"]);
				me.cHDI_Needle.set("fill",COLOR["Yellow"]);
			}else{
				me.cCDI.set("fill",COLOR["Green"]);
				me.cHDI_Needle.set("fill",COLOR["White"]);	
			}
			
			
			
			
			
		}else{
			me.cHDI_Needle.setVisible(0);
			me.cDI.setVisible(0);
			me.cCDI.setVisible(0);
		}
			
		me.cCDIFromFlag.setVisible(me.data.cdiFromFlag);
		me.cCDIToFlag.setVisible(me.data.cdiToFlag);
			
		me.cCDI.setTranslation(me.data.HDI * 240,0);
		me.cCoursePointer.setRotation((me.data.navCoursePointer-me.data.HDG) * global.CONST.DEG2RAD);
		
		
		
	#ALT
		
		
		var alt 	= me.data.ALT + 300;
		
		
		me.cAltLad_U300T.setText(sprintf("%i",math.floor(alt/1000)));
		me.cAltLad_U300H.setText(sprintf("%03i",math.floor(math.mod(alt,1000) / 100) * 100));
		
		alt-=100;
		
		me.cAltLad_U200T.setText(sprintf("%i",math.floor(alt/1000)));
		me.cAltLad_U200H.setText(sprintf("%03i",math.floor(math.mod(alt,1000) / 100) * 100));
		
		alt-=100;
		
		me.cAltLad_U100T.setText(sprintf("%i",math.floor(alt/1000)));
		me.cAltLad_U100H.setText(sprintf("%03i",math.floor(math.mod(alt,1000) / 100) * 100));
		
		alt-=100;
		me.cAltLad_C000T.setText(sprintf("%i",math.floor(alt/1000)));
		me.cAltLad_C000H.setText(sprintf("%03i",math.floor(math.mod(alt,1000) / 100) * 100));
			
		alt-=100;
		
		me.cAltLad_D100T.setText(sprintf("%i",math.floor(alt/1000)));
		me.cAltLad_D100H.setText(sprintf("%03i",math.floor(math.mod(alt,1000) / 100) * 100));
		
		alt-=100;
		
		me.cAltLad_D200T.setText(sprintf("%i",math.floor(alt/1000)));
		me.cAltLad_D200H.setText(sprintf("%03i",math.floor(math.mod(alt,1000) / 100) * 100));
		

		# 136 px
		me.cAltLadder.setTranslation(0,math.mod(me.data.ALT,100)*1.36);
		
		me.cHPA.setText(sprintf("%4i",me.data.HPA));
		me.cAltSelected.setText(sprintf("%4i",me.data.ALTBug));
		
		var alt	= 0;
		var alladd = 0;
		
		alt = math.mod(me.data.ALT,100);
		me.cAltBar10.setTranslation(0, alt * (75.169/20));
		
		if (me.data.ALT>=100){
			if (alt > 80) {
				alladd = alt - 80;
			}else{
				alladd = 0;
			}
		
			alt = math.floor(math.mod(me.data.ALT,1000)/100);
			me.cAltBar100.setTranslation(0,(alt * 75.169) + ( alladd * (75.169/20) ));
			me.cAltBar100.setVisible(1);
			if(me.data.ALT>=1000){
				if (alt == 9) {
					#alladd = alt - 9;
				}else{
					alladd = 0;
				}
				#print("update20Hz() ... "~alt~" + "~alladd);
				
				alt = math.floor(math.mod(me.data.ALT,10000)/1000);
				me.cAltBar1000.setTranslation(0,alt*75.169 + ( alladd * (75.169/20) ));
				me.cAltBar1000.setVisible(1);
				if (me.data.ALT>=10000){
					if (alt == 9) {
						#alladd = alt - 9;
					}else{
						alladd = 0;
					}
					
					alt = math.floor(math.mod(me.data.ALT,100000)/10000);
					me.cAltBar10000.setTranslation(0,alt*75.169 + ( alladd * (75.169/20) ));
					me.cAltBar10000.setVisible(1);
				}else{
					me.cAltBar10000.setVisible(0);
				}
			}else{
				me.cAltBar10000.setVisible(0);
				me.cAltBar1000.setVisible(0);
			}
		}else{
			me.cAltBar10000.setVisible(0);
			me.cAltBar1000.setVisible(0);
			me.cAltBar100.setVisible(0);
		}
		var altBugDif = me.data.ALT - me.data.ALTBug;
		altBugDif *= 1.36;
		# up 322 down 294
		altBugDif = global.clamp(altBugDif,-322,294);
		
		me.cAltBug.setTranslation(0,altBugDif);
		
	},
};
