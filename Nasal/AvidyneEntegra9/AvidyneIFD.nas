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
		var m = { parents: [AvidyneData,ListenerClass.new()] };
		m.name = name;
		m.link = nil; #link to the other IFD DATA
	# ALT
 		m.HPA 		= 0;
 		m.nHPA = props.globals.initNode("/instrumentation/altimeter-IFD-"~m.name~"/setting-hpa",0.0,"DOUBLE");
		
	#Timer
		m.timerSec 	= 0;
		m.timerState	= 0;
		
		return m;
	},
	setListeners : func(instance=me) {
		append(me._listeners, setlistener("/instrumentation/altimeter-IFD-"~me.name~"/setting-hpa",func(n){me._onHpaChange(n)},1,0));	
	
	},
	init : func(instance=me){
		me.setListeners(instance);
	},
	
	#loading the data from PropertyTree
	load20Hz : func(now,dt){
		
	},
	load2Hz : func(now,dt){
		me._timerCount(dt);
	},
	_onHpaChange : func(n){
		me.HPA = n.getValue();	
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
	setVisible : func(visibility){
		me.page.setVisible(0);
		me.IFD._widget.Headline.setVisible(0);
		me.IFD._widget.PlusData.setVisible(0);
		me.IFD.movingMap.setVisible(0);
		
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
		m.nBacklightMode= m._nRoot.initNode("Backlight/mode",0,"BOOL");
		m._backlight	=0;
		m._backlightMode=0;
		
		
		m._nState  	= m._nRoot.initNode("state",0,"BOOL");
		m._brightness	= 1;
		
		m._powerA	= extra500.ConsumerClass.new(root~"/powerA",name~" Power A",60.0);
		m._powerB	= extra500.ConsumerClass.new(root~"/powerB",name~" Power B",60.0);
		m._voltNorm	= 0;
		
		m._nOverSpeedWarning  	= props.globals.initNode("/extra500/sound/overspeedWarning",0.0,"BOOL");
		
# 		m.width 	= 1024;
# 		m.height	= 768;
		m.width 	= 2048;
		m.height	= 1536;
# 		m.width 	= 2410;
# 		m.height	= 1810;
# 		
		m.canvas = canvas.new({
		"name": "IFD",
		"size": [m.width, m.height],
		"view": [m.width, m.height],
		"mipmapping": 1,
		});
		

		m.canvas.addPlacement({"parent": acPlace,"node": "IFD.Screen"});
		m.canvas.setColorBackground(0,0,0);
		# .. and place it on the object called PFD-Screen

		#m.nHeadingBug = props.globals.initNode("/instrumentation/heading-indicator-IFD-LH/indicated-heading-deg",0.0,"DOUBLE");
		m._group = m.canvas.createGroup();
		m._group.set("z-index",3);
		
		canvas.parsesvg(m._group, "Models/instruments/IFDs/IFD_Global.svg",{
			"font-mapper": global.canvas.FontMapper
			}
		);
		
		
		m.movingMap = MovingMap.new(m,m.canvas.createGroup(),name~"-MovingMap");
		m.movingMap.setLayout("map");
		
		m._widget = {
			#COM		: ComWidget.new(m,m._group.getElementById("layer1"),"Com"),
			#CurrentWaypoint	: CurrentWaypointWidget.new(m,m._group,"CurrentWaypoint"),
			Headline	: HeadlineWidget.new(m,m._group.getElementById("layer1"),"Headline"),
			PlusData	: PlusDataWidget.new(m,m._group.getElementById("layer2"),"PlusData"),
		};
		
		
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
		m.page["none"] = AvidynePageDummy.new(m,"none",m.data);
		m.page["PFD"] = AvidynePagePFD.new(m,"PFD",m.data);
		m.page["FMS"] = AvidynePageFMS.new(m,"FMS",m.data);
		m.page["MAP"] = AvidynePageMAP.new(m,"MAP",m.data);
		#m.page["CHKL"] = AvidynePageTest.new(m,"Test",m.data);
		
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
	getIFD : func(){ return me ;},
	init : func(instance=nil){
		if (instance==nil){instance=me;}
		me.parents[1].init(instance);
		#me.setListeners(instance);
		me.initUI();
		me.data.init();
		
		me._powerA.init();
		me._powerB.init();
		
		append(me._listeners, setlistener(me._powerA._nState,func(n){instance._onPowerAChange(n);},1,0) );
		append(me._listeners, setlistener(me._powerB._nState,func(n){instance._onPowerBChange(n);},1,0) );
		append(me._listeners, setlistener(me._powerA._nVoltNorm,func(n){instance._onPowerVoltNormChange(n);},1,0) );
		append(me._listeners, setlistener(me._powerB._nVoltNorm,func(n){instance._onPowerVoltNormChange(n);},1,0) );
		append(me._listeners, setlistener(me._nState,func(n){instance._onStateChange(n);},1,0) );
		
		me.nLedDim.setValue(1);
		me.keys["DIM >"] = func(){me._adjustBrightness(0.05);};
		me.keys["DIM <"] = func(){me._adjustBrightness(-0.05);};
		
		
		
		
		me.nLedBaro.setValue(1);
		me.keys["BARO >"] = func(){me.data.adjustBaro(1);};
		me.keys["BARO <"] = func(){me.data.adjustBaro(-1);};
		me.keys["BARO STD"] = func(){me.data.adjustBaro();};
		
		
		
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
		
		me.movingMap.init();
		
		me._widget.Headline.init();
		me._widget.PlusData.init();
		
		me.page["none"].init();
		me.page["PFD"].init();
		me.page["FMS"].init();
		me.page["MAP"].init();
		
		
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
			
			if(me._powerA._voltNorm > me._powerB._voltNorm){
				me._voltNorm = me._powerA._voltNorm;
			}else{
				me._voltNorm = me._powerB._voltNorm;
			}
			me.gotoPage(me._startPage);
		}else{
			me.gotoPage("none");
			me._voltNorm = 0;
		}
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
			me.movingMap.update20Hz(me._now20Hz,me._dt20Hz);
		}
	},
	setBacklight : func(value){
		me._backlight = (value==1);
		me.nLedLK.setValue(value);	
		me.nLedRK.setValue(value);
		me.nLedBaro.setValue(value);
		me.nBacklightMode.setValue(me._backlightMode and me._backlight);
	},
	setBacklightMode : func(value){
		me._backlightMode = (value==1);
		me.nBacklightMode.setValue(me._backlightMode and me._backlight);	
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
		
			
		
		
	},
	gotoPage : func(name,key=nil){
		#print("IFD "~me.name ~" gotoPage("~name~") .. ");
		if (!contains(me.page,name)){
				name = "none";	
		}
		if (me._state == 1){
			
		
			if (me.pageSelected != name){
# 				me.page[me.pageSelected].deinit();
				me.page[me.pageSelected].setVisible(0);
				me.clearLeds();
				me.pageSelected = name;
				me.nPageSelected.setValue(me.pageSelected);
# 				me.page[me.pageSelected].init();
				me.page[me.pageSelected].setVisible(1);
				
			}else{
				if(key!=nil){
					me.page[me.pageSelected].onClick(key);
				}
			}
		}else{
			me.page[me.pageSelected].setVisible(0);
			me.clearLeds();
			me.pageSelected = name;
			me.nPageSelected.setValue(me.pageSelected);
# 			me.page[me.pageSelected].init();
			me.page[me.pageSelected].setVisible(1);
				
		}
	},
	_adjustBrightness : func(amount){
		me._brightness += amount;
		me._brightness = global.clamp(me._brightness,0.2,1.0);
		me.nBacklight.setValue(me._brightness * me._voltNorm);
	},
	
	onClick: func(key){
		#print ("AvidyneIFD.onClick("~key~")");
		if (me._state == 1){
			if (contains(me.keys,key)){
				if(me.keys[key] != nil){
					me.keys[key]();
					return 1;
				}
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


var LH = AvidyneIFD.new("extra500/instrumentation/IFD-LH","LH","LH_IFD","PFD");
var RH = AvidyneIFD.new("extra500/instrumentation/IFD-RH","RH","RH_IFD","FMS");

extra500.eSystem.circuitBreaker.IFD_LH_A.outputAdd(LH._powerA);
extra500.eSystem.circuitBreaker.IFD_LH_B.outputAdd(LH._powerB);
extra500.eSystem.circuitBreaker.IFD_RH_A.outputAdd(RH._powerA);
extra500.eSystem.circuitBreaker.IFD_RH_B.outputAdd(RH._powerB);
		
LH.connectDataBus(RH.data);
RH.connectDataBus(LH.data);




