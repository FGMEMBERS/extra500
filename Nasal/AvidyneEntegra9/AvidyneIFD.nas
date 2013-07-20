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
#      Date:             20.07.13
#


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
		m.apModeAPR 	= 0;
		m.apModeGPSS 	= 0;
		m.apModeTRIM 	= 0;
		m.apModeVS 	= 0;
		m.apModeHDG 	= 0;
		m.apModeCAP 	= 0;
		m.apModeSOFT 	= 0;
		m.apModeAP 	= 0;
		m.apModeFD 	= 0;
		
		m.nApPower 	= props.globals.initNode("/extra500/instrumentation/Autopilot/state",0.0,"INT");
		m.nApModeRdy 	= props.globals.initNode("/autopilot/mode/rdy",0.0,"INT");
		m.nApModeFail 	= props.globals.initNode("/autopilot/mode/fail",0.0,"INT");
		m.nApModeALT 	= props.globals.initNode("/autopilot/mode/alt",0.0,"INT");
		m.nApModeNAV 	= props.globals.initNode("/autopilot/mode/nav",0.0,"INT");
		m.nApModeAPR 	= props.globals.initNode("/autopilot/mode/apr",0.0,"INT");
		m.nApModeGPSS 	= props.globals.initNode("/autopilot/mode/gpss",0.0,"INT");
		m.nApModeTRIM 	= props.globals.initNode("/autopilot/mode/trim",0.0,"INT");
		m.nApModeVS  	= props.globals.initNode("/autopilot/mode/vs",0.0,"INT");
		m.nApModeCAP 	= props.globals.initNode("/autopilot/mode/cap",0.0,"INT");
		m.nApModeSOFT  	= props.globals.initNode("/autopilot/mode/soft",0.0,"INT");
		m.nApModeHDG 	= props.globals.initNode("/autopilot/mode/heading",0.0,"INT");
		m.nApModeAP  	= props.globals.initNode("/autopilot/settings/ap",0.0,"INT");
		m.nApModeFD  	= props.globals.initNode("/autopilot/settings/fd",0.0,"INT");
		
		
		
		
	#heading 
		m.HDG 		= 0;
		m.HDGBug 	= 0;
		
		m.nHDG = props.globals.initNode("/instrumentation/heading-indicator-IFD-"~m.name~"/indicated-heading-deg",0.0,"DOUBLE");
		m.nHDGBug = props.globals.initNode("/autopilot/settings/heading-bug-deg",0.0,"DOUBLE");
	# IAS 	
		m.IAS 		= 0;
		m.TAS 		= 0;
		m.GroundSpeed	= 0;
		m.IAS_Rate	= 0;
		
		m.nIAS 		= props.globals.initNode("/instrumentation/airspeed-IFD-"~m.name~"/indicated-airspeed-kt",0.0,"DOUBLE");
		m.nIASRate	= props.globals.initNode("/instrumentation/airspeed-IFD-"~m.name~"/airspeed-change-ktps",0.0,"DOUBLE");
		m.nTAS 		= props.globals.initNode("/instrumentation/airspeed-IFD-"~m.name~"/true-speed-kt",0.0,"DOUBLE");
		m.nGroundSpeed 	= props.globals.initNode("/velocities/groundspeed-kt",0.0,"DOUBLE");
		
	#vertical speed
		m.VS 		 = 0;
		m.VSBug		 = 0;
		
		m.nVS = props.globals.initNode("/instrumentation/ivsi-IFD-"~m.name~"/indicated-speed-fpm",0.0,"DOUBLE");
		m.nVSBug = props.globals.initNode("/autopilot/settings/vertical-speed-fpm",0.0,"DOUBLE");
		
	# ALT
		m.ALT 		= 0;
		m.ALTBug 	= 0;
		m.HPA 		= 0;
		
		m.nALT = props.globals.initNode("/instrumentation/altimeter-IFD-"~m.name~"/indicated-altitude-ft",0.0,"DOUBLE");
		#m.nALT = props.globals.initNode("/instrumentation/altimeter-IFD-"~m.name~"/setting-hpa",0.0,"DOUBLE");
		m.nALTBug = props.globals.initNode("/autopilot/settings/tgt-altitude-ft",0.0,"DOUBLE");
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
		m.nVDI 		= props.globals.initNode("/autopilot/gs-channel/gs-needle-deflection-norm",0.0,"DOUBLE");
		#m.nGSable 	= props.globals.initNode("/autopilot/gs-channel/has-gs",0.0,"DOUBLE");
		m.nGSinRange 	= props.globals.initNode("/autopilot/gs-channel/gs-in-range",0.0,"DOUBLE");
		m.nNAVinRange 	= props.globals.initNode("/autopilot/radionav-channel/in-range",0.0,"DOUBLE");
		#m.nNAVLOC 	= props.globals.initNode("/autopilot/radionav-channel/is-localizer-frequency",0.0,"DOUBLE");
		
		m.cdiFromFlag 	= 0;
		m.cdiToFlag 	= 0;
		
	#Box Primary Nav
		m.nNavDistance	= props.globals.initNode("/autopilot/radionav-channel/nav-distance-nm",0.0,"DOUBLE");
		m.nNAVSource	= props.globals.initNode("/instrumentation/nav-source",0.0,"DOUBLE");
		m.navSource		= 0;
		m.navID		= "";
		m.navFrequency  = 0.0;
		m.navDeg		= 0.0;
		m.navAidUnit		= "";
		m.navDistance	= 0.3;
		m.navCoursePointer = 0;
		
	#Box Bearing Pointer
		m.brgSource		= 0;
		m.brgID			= "";	
		m.brgNAVLOC		= 0;
		m.brgGSable		= 0;
		m.brgFrequency		= 0.0;
		m.brgDistance		= 0.0;
		m.brgCoursePointer	= 0.0;
	#Timer
		m.timerSec 	= 0;
		m.timerState	= 0;
		return m;
	},
	#loading the data from PropertyTree
	load20Hz : func(now,dt){
	#autopilot
		me.apPowered 	= me.nApPower.getValue();
		me.apModeRdy 	= me.nApModeRdy.getValue();
		me.apModeFail 	= me.nApModeFail.getValue();
		me.apModeALT 	= me.nApModeALT.getValue();
		me.apModeNAV 	= me.nApModeNAV.getValue();
		me.apModeAPR 	= me.nApModeAPR.getValue();
		me.apModeGPSS 	= me.nApModeGPSS.getValue();
		me.apModeTRIM 	= me.nApModeTRIM.getValue();
		me.apModeVS 	= me.nApModeVS.getValue();
		me.apModeHDG 	= me.nApModeHDG.getValue();
		me.apModeCAP 	= me.nApModeCAP.getValue();
		me.apModeSOFT 	= me.nApModeSOFT.getValue();
		me.apModeAP 	= me.nApModeAP.getValue();
		me.apModeFD 	= me.nApModeFD.getValue();
		
	#heading 
		me.HDG 		= me.nHDG.getValue();
		me.HDGBug 	= me.nHDGBug.getValue();
	#speed 	
		me.IAS 		= me.nIAS.getValue();
		me.IAS_Rate	= me.nIASRate.getValue();
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
		me.WindDirection 	= me.nWindDirection.getValue();
		me.WindSpeed 		= me.nWindSpeed.getValue();
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
	
	# Bearing Pointer
		if (me.brgSource > 0){
			me.brgCoursePointer	= getprop(BEARING_SOURCE_TREE[me.brgSource]~"/radials/reciprocal-radial-deg") or 0;
			
		}
		
	
	},
	load2Hz : func(now,dt){
		#print("AvidyneData.load2Hz("~now~","~dt~") .. ");
	#Box Timer
		me._timerCount(dt);
	#Box Primary Nav
		me.navDistance	= me.nNavDistance.getValue();
		me.GroundSpeed	= me.nGroundSpeed.getValue();
	# Box Bearing Pointer
		if (me.brgSource > 0){
			me.brgDistance		= getprop(BEARING_SOURCE_TREE[me.brgSource]~"/nav-distance") * global.CONST.METER2NM;
		}
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
	},
	timerStart : func(){
		me.timerState = 2;
	},
	timerStop : func(){
		me.timerState = 1;
	},
	timerReset : func(){
		me.timerSec = 0;
		if (me.timerState == 1){
			me.timerState = 0;
		}
	},
	_timerCount : func(dt){
		if (me.timerState == 2){
			me.timerSec += dt;
		}
	},
	timerGetTime : func(){
		var text = "00:00";
		if(me.timerSec > 0){
			var hour = math.mod(me.timerSec,86400.0) / 3600.0;
			var min = math.mod(me.timerSec,3600.0) / 60.0;
			var sec = math.mod(me.timerSec,60.0);
			
			if (hour > 1){
				text = sprintf("%02i:%02i:%02i",hour,min,sec);
			}else{
				text = sprintf("%02i:%02i",min,sec);
			}
		}
		return text;
	},
};



var AvidynePageDummy = {
	new: func(myCanvas,name,data){
		var m = { parents: [
			AvidynePageDummy,
			PageClass.new(myCanvas,name,data)
		] };
		return m;
	},
};



var AvidyneIFD = {
	new: func(root,name,acPlace,startPage="none"){
		var m = { parents: [
			AvidyneIFD,
			extra500.ServiceClass.new(root,name)
		] };
		m.name = name;
		m.keys = {};
		m.nBacklight  	= m._nRoot.initNode("Backlight/state",1.0,"DOUBLE");
		m._nState  	= m._nRoot.initNode("state",0,"BOOL");
		m._brightness	= 1;
		
		m._powerA	= extra500.ConsumerClass.new(root~"/powerA",name~" Power A",60.0);
		m._powerB	= extra500.ConsumerClass.new(root~"/powerB",name~" Power B",60.0);
		m._voltNorm	= 0;
		
		m._nOverSpeedWarning  	= props.globals.initNode("/extra500/sound/overspeedWarning",0.0,"BOOL");
		
		
		m.canvas = canvas.new({
		"name": "IFD",
		"size": [2410, 1810],
		"view": [2410, 1810],
		"mipmapping": 1,
		});
		m.canvas.addPlacement({"node": acPlace});
		m.canvas.setColorBackground(0,0,0);
		
		# .. and place it on the object called PFD-Screen

		#m.nHeadingBug = props.globals.initNode("/instrumentation/heading-indicator-IFD-LH/indicated-heading-deg",0.0,"DOUBLE");
		
		m.data = AvidyneData.new(m.name);
		
		
		m.pageSelected = "none";
			
		
		m.nPageSelected = m._nRoot.initNode("PageSelected","","STRING");
		
		m.nLedL1 = m._nRoot.initNode("led/L1",0,"BOOL");
		m.nLedL2 = m._nRoot.initNode("led/L2",0,"BOOL");
		m.nLedL3 = m._nRoot.initNode("led/L3",0,"BOOL");
		m.nLedL4 = m._nRoot.initNode("led/L4",0,"BOOL");
		m.nLedL5 = m._nRoot.initNode("led/L5",0,"BOOL");
		m.nLedL6 = m._nRoot.initNode("led/L6",0,"BOOL");
		
		m.nLedR1 = m._nRoot.initNode("led/R1",0,"BOOL");
		m.nLedR2 = m._nRoot.initNode("led/R2",0,"BOOL");
		m.nLedR3 = m._nRoot.initNode("led/R3",0,"BOOL");
		m.nLedR4 = m._nRoot.initNode("led/R4",0,"BOOL");
		m.nLedR5 = m._nRoot.initNode("led/R5",0,"BOOL");
		m.nLedR6 = m._nRoot.initNode("led/R6",0,"BOOL");
		
		m.nLedLK = m._nRoot.initNode("led/LK",0,"BOOL");
		m.nLedRK = m._nRoot.initNode("led/RK",0,"BOOL");
		
		m.nLedBaro = m._nRoot.initNode("led/Baro",0,"BOOL");
		m.nLedDim = m._nRoot.initNode("led/Dim",0,"BOOL");
		
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
		
		m._timerLoop20Hz = nil;
		m._timerLoop2Hz = nil;
	
		return m;
	},
	init : func(instance=nil){
		if (instance==nil){instance=me;}
		me.parents[1].init(instance);
		#me.setListeners(instance);
		me.initUI();
		
		me._powerA.init();
		me._powerB.init();
		
		append(me._listeners, setlistener(me._powerA._nState,func(n){instance._onPowerAChange(n);},1,0) );
		append(me._listeners, setlistener(me._powerB._nState,func(n){instance._onPowerBChange(n);},1,0) );
		append(me._listeners, setlistener(me._powerA._nVoltNorm,func(n){instance._onPowerVoltNormChange(n);},1,0) );
		append(me._listeners, setlistener(me._powerB._nVoltNorm,func(n){instance._onPowerVoltNormChange(n);},1,0) );
		append(me._listeners, setlistener(me._nState,func(n){instance._onStateChange(n);},1,0) );
		
		me.nLedDim.setValue(1);
		me.keys["DIM >"] = func(){me._adjustBrightness(0.1);};
		me.keys["DIM <"] = func(){me._adjustBrightness(-0.1);};
		
		me.keys["PFD >"] = func(){me.gotoPage("PFD","PFD >");};
		me.keys["PFD <"] = func(){me.gotoPage("PFD","PFD <");};
		me.keys["FMS >"] = func(){me.gotoPage("FMS","FMS >");};
		me.keys["FMS <"] = func(){me.gotoPage("FMS","FMS <");};
		me.keys["MAP >"] = func(){me.gotoPage("MAP","MAP >");};
		me.keys["MAP <"] = func(){me.gotoPage("MAP","MAP <");};
		me.keys["SYS >"] = func(){me.gotoPage("SYS","SYS >");};
		me.keys["SYS <"] = func(){me.gotoPage("SYS","SYS <");};
		me.keys["CHKL >"] = func(){me.gotoPage("CHKL","CHKL >");};
		me.keys["CHKL <"] = func(){me.gotoPage("CHKL","CHKL <");};
		
		
		
		
		#me.gotoPage(me._startPage);
		
		me._timerLoop20Hz = maketimer(0.05,me,AvidyneIFD.update20Hz);
		me._timerLoop2Hz = maketimer(0.5,me,AvidyneIFD.update2Hz);
	
		me._timerLoop20Hz.start();
		me._timerLoop2Hz.start();
		
	},
	_onPowerVoltNormChange : func(n){
		me._voltNorm = n.getValue();
		me.nBacklight.setValue(me._brightness * me._voltNorm);
	},

	_onPowerAChange : func(n){
		me._powerA._state = n.getBoolValue();
		if (me._powerA._state == 0){
			me._powerB._nWatt.setValue(120);
		}else{
			if (me._powerB._state == 1){
				me._powerA._nWatt.setValue(60);
				me._powerB._nWatt.setValue(60);
			}else{
				me._powerA._nWatt.setValue(120);
			}
		}
		
		if ( (me._powerA._state == 0) and (me._powerB._state == 0) ){
			me._nState.setValue(0);
		}else{
			me._nState.setValue(1);
		}
	},
	_onPowerBChange : func(n){
		me._powerB._state = n.getBoolValue();
		if (me._powerB._state == 0){
			me._powerA._nWatt.setValue(120);
		}else{
			if (me._powerA._state == 1){
				me._powerB._nWatt.setValue(60);
				me._powerA._nWatt.setValue(60);
			}else{
				me._powerB._nWatt.setValue(120);
			}
		}
		
		if ( (me._powerA._state == 0) and (me._powerB._state == 0) ){
			me._nState.setValue(0);
		}else{
			me._nState.setValue(1);
		}
	},
	_onStateChange : func(n){
		me._state = n.getBoolValue();
		if (me._state == 1){
			me.gotoPage(me._startPage);
			if(me._powerA._voltNorm > me._powerB._voltNorm){
				me._voltNorm = me._powerA._voltNorm;
			}else{
				me._voltNorm = me._powerB._voltNorm;
			}
		}else{
			me._voltNorm = 0;
		}
		me.page[me.pageSelected].setVisible(me._state);
	},
	connectDataBus : func(ifd){
		me.data.link = ifd;
	},
	update2Hz : func(){
		if (me._state == 1){
			me._now2Hz = systime();
			me._dt2Hz = me._now2Hz - me._last2Hz;
			me._last2Hz = me._now2Hz;
					
			me.data.load2Hz(me._now2Hz,me._dt2Hz);
			me.page[me.pageSelected].update2Hz(me._now2Hz,me._dt2Hz);
		}		
	},
	update20Hz : func(){
		if (me._state == 1){
			me._now20Hz = systime();
			me._dt20Hz = me._now20Hz - me._last20Hz;
			me._last20Hz = me._now20Hz;
					
			me.data.load20Hz(me._now20Hz,me._dt20Hz);
			me.page[me.pageSelected].update20Hz(me._now20Hz,me._dt20Hz);	
		}
	},
	clearLeds : func(){
		me.nLedL1.setValue(0);
		me.nLedL2.setValue(0);
		me.nLedL3.setValue(0);
		me.nLedL4.setValue(0);
		me.nLedL5.setValue(0);
		me.nLedL6.setValue(0);
		
		me.nLedR1.setValue(0);
		me.nLedR2.setValue(0);
		me.nLedR3.setValue(0);
		me.nLedR4.setValue(0);
		me.nLedR5.setValue(0);
		me.nLedR6.setValue(0);	
		
		me.nLedLK.setValue(0);	
		me.nLedRK.setValue(0);	
		
		
	},
	gotoPage : func(name,key=nil){
		#print("IFD "~me.name ~" gotoPage("~name~") .. ");
		if (me._state == 1){
			if (!contains(me.page,name)){
				name = "none";	
			}
		
			if (me.pageSelected != name){
				me.page[me.pageSelected].setVisible(0);
				me.page[me.pageSelected].removeListeners();
				me.pageSelected = name;
				me.nPageSelected.setValue(me.pageSelected);
				me.clearLeds();
				me.page[me.pageSelected].setListeners();
				me.page[me.pageSelected].registerKeys();
				me.page[me.pageSelected].setVisible(1);
			}else{
				if(key!=nil){
					me.page[me.pageSelected].onClick(key);
				}
			}
		}
	},
	_adjustBrightness : func(amount){
		me._brightness += amount;
		me._brightness = global.clamp(me._brightness,0,1.0);
		me.nBacklight.setValue(me._brightness * me._voltNorm);
	},
	
	onClick: func(key){
		#print ("AvidyneIFD.onClick("~key~")");
		if (me._state == 1){
			if (contains(me.keys,key)){
				me.keys[key]();
				return 1;
			}
			
			me.page[me.pageSelected].onClick(key);
		}
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
		
		UI.register("IFD "~me.name~" PFD >",func{me.onClick("PFD >"); } );
		UI.register("IFD "~me.name~" PFD <",func{me.onClick("PFD <"); } );
		UI.register("IFD "~me.name~" FMS >",func{me.onClick("FMS >"); } );
		UI.register("IFD "~me.name~" FMS <",func{me.onClick("FMS <"); } );
		UI.register("IFD "~me.name~" MAP >",func{me.onClick("MAP >"); } );
		UI.register("IFD "~me.name~" MAP <",func{me.onClick("MAP <"); } );
		UI.register("IFD "~me.name~" SYS >",func{me.onClick("SYS >"); } );
		UI.register("IFD "~me.name~" SYS <",func{me.onClick("SYS <"); } );
		UI.register("IFD "~me.name~" CHKL >",func{me.onClick("CHKL >"); } );
		UI.register("IFD "~me.name~" CHKL <",func{me.onClick("CHKL <"); } );
		
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


var LH = AvidyneIFD.new("extra500/instrumentation/IFD-LH","LH","LH-IFD.Screen","PFD");
var RH = AvidyneIFD.new("extra500/instrumentation/IFD-RH","RH","RH-IFD.Screen");

extra500.eSystem.circuitBreaker.IFD_LH_A.outputAdd(LH._powerA);
extra500.eSystem.circuitBreaker.IFD_LH_B.outputAdd(LH._powerB);
extra500.eSystem.circuitBreaker.IFD_RH_A.outputAdd(RH._powerA);
extra500.eSystem.circuitBreaker.IFD_RH_B.outputAdd(RH._powerB);
		
LH.connectDataBus(RH.data);
RH.connectDataBus(LH.data);




