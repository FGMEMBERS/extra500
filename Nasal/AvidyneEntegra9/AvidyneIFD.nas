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
	new: func(ifd,name,data){
		var m = { parents: [
			AvidynePageDummy,
			PageClass.new(ifd,name,data)
		] };
		m._can= {
			back : m.page.createChild("path")
			.moveTo(0,0)
			.line(2048,0)
			.line(0,1536)
			.line(-2048,0)
			.close()
			.set("fill","#000000")
			.set("stroke","#000000")
			,
			
		};
		return m;
	},
	setVisible : func(visibility){
		me.page.setVisible(visibility);
		me.IFD._widget.Headline.setVisible(0);
		me.IFD._widget.PlusData.setVisible(0);
		me.IFD.movingMap.setVisible(0);
		me.IFD.setLayout("");
	},
	
};



var IFD_LAYOUT = {
	"NONE"	:0,
	"PFD"	:1,
	"FULL"	:2,
	"SPLIT"	:3,
	"PLUS"	:4,
};


var IFDUserInterface = {
	new : func(ifd){
		var m = { parents: [IFDUserInterface] };
		m._IFD = ifd;
		
		m._can = {
			LK : {
				Label		: m._IFD._group.getElementById("LKLabel").setVisible(0),
				scroll		: m._IFD._group.getElementById("LKOuterLabel").setText(""),
				push		: m._IFD._group.getElementById("LKInnerLabel").setText(""),
			},
			RK : {
				Label		: m._IFD._group.getElementById("RKLabel").setVisible(0),
				scroll		: m._IFD._group.getElementById("RKOuterLabel").setText(""),
				push		: m._IFD._group.getElementById("RKInnerLabel").setText(""),
			},
		};
		
		
		
		m._nLed = {
			L1 	: m._IFD._nRoot.initNode("led/L1",0,"BOOL"),
			L2 	: m._IFD._nRoot.initNode("led/L2",0,"BOOL"),
			L3 	: m._IFD._nRoot.initNode("led/L3",0,"BOOL"),
			L4 	: m._IFD._nRoot.initNode("led/L4",0,"BOOL"),
			L5 	: m._IFD._nRoot.initNode("led/L5",0,"BOOL"),
			L6 	: m._IFD._nRoot.initNode("led/L6",0,"BOOL"),
			
			R1 	: m._IFD._nRoot.initNode("led/R1",0,"BOOL"),
			R2 	: m._IFD._nRoot.initNode("led/R2",0,"BOOL"),
			R3 	: m._IFD._nRoot.initNode("led/R3",0,"BOOL"),
			R4 	: m._IFD._nRoot.initNode("led/R4",0,"BOOL"),
			R5 	: m._IFD._nRoot.initNode("led/R5",0,"BOOL"),
			R6 	: m._IFD._nRoot.initNode("led/R6",0,"BOOL"),
			
			LK 	: m._IFD._nRoot.initNode("led/LK",1,"BOOL"),
			RK 	: m._IFD._nRoot.initNode("led/RK",1,"BOOL"),
			
			Baro 	: m._IFD._nRoot.initNode("led/Baro",1,"BOOL"),
			Dim 	: m._IFD._nRoot.initNode("led/Dim",1,"BOOL"),
		
		};
		m._keyCallbacks	 = ["<",">"];
		m._keys		 = ["L1","L2","L3","L4","L5","L6","R1","R2","R3","R4","R5","R6","DIM","PFD","FMS","MAP","SYS","CHKL"];
		m._keyMap	 = {};
		
		foreach (var key ; m._keys){
			foreach (var cb ; m._keyCallbacks){
				m._keyMap[key~" "~cb] = nil;
			}
		}
		
		m._knobCallbacks = ["<<","<","push",">",">>"];
		m._KnobLabels	 = ["scroll","push"];
		m._knobs	 = ["LK","RK","BARO"];
		
		foreach (var key ; m._knobs){
			foreach (var cb ; m._knobCallbacks){
				m._keyMap[key~" "~cb] = nil;
			}
		}
		
		return m;
	},
	setBacklight : func(value){
		me._nLed.LK.setValue(value);	
		me._nLed.RK.setValue(value);
		me._nLed.Baro.setValue(value);
		me._nLed.Dim.setValue(value);
	},
	bindKey : func(name=nil,callback=nil){
		if(name != nil){
			var active = 0;
			
			if(callback!=nil){
				foreach (var cb ; me._keyCallbacks){
					var callbackName = name ~" "~cb;
										
					if(contains(me._keyMap,callbackName)){
						if(contains(callback,cb)){
							me._keyMap[callbackName] = callback[cb];
							active = 1;
						}else{
							me._keyMap[callbackName] = nil;
						}
						
					}else{
# 						print("IFDUserInterface.bindKey() ... no such Key("~callbackName~").");
					}
				}	
			}else{
				foreach (var cb ; me._keyCallbacks){
					var callbackName = name ~" "~cb;
					me._keyMap[callbackName] = nil;				
				}
			}
		
			if(contains(me._nLed,name)){
				me._nLed[name].setValue(active);
			}
		}
	},
	
	bindKnob : func(name=nil,callback=nil,label=nil){
		if(name != nil){
			var active = 0;
			if(callback!=nil){
				foreach (var cb ; me._knobCallbacks){
					var callbackName = name ~" "~cb;
					if(contains(me._keyMap,callbackName)){
						if(contains(callback,cb)){
							me._keyMap[callbackName] = callback[cb];
							active = 1;
 							#dp.debug("IFDUserInterface.bindKey() ... "~callbackName~" : active.");
						}else{
							me._keyMap[callbackName] = nil;
							#dp.debug("IFDUserInterface.bindKey() ... "~callbackName~" : nil.");
						}
					}else{
 						dp.alert("IFDUserInterface.bindKey() ... no such Knob("~callbackName~").");
					}
				}
			}else{
				foreach (var cb ; me._knobCallbacks){
					var callbackName = name ~" "~cb;
					me._keyMap[callbackName] = nil;				
				}
			}
			
			if(label!=nil){
				foreach (var l ; me._KnobLabels){
					if(contains(label,l)){
						me._can[name][l].setText(label[l]);
					}else{
						me._can[name][l].setText("");
					}
				}
			}else{
				if(contains(me._can,name)){
					foreach (var l ; me._KnobLabels){
						me._can[name][l].setText("");
					}
				}
			}
			
			if(contains(me._can,name)){
				me._can[name].Label.setVisible(active);
			}
			
		}
	},
	
	onClick : func(key){
		if (contains(me._keyMap,key)){
			if(me._keyMap[key] != nil){
				me._keyMap[key]();
				return 1;
			}
		}
	},
	clearLeds : func(){
		
	},
};



var IFDPageNavigator = {
	
	new : func(ifd){
		var m = { parents: [IFDNavigator]};
		
		m._IFD = ifd;
		m._can = {};
		m._active = "none";
		return m;
	},
	init : func(){
		foreach (var page ; me._IFD.page){
			me._can[page] = {};
			forindex(var i ; me._IFD.page[page]._tab){
				var tab = me._IFD.page[page]._tab[i];
				
				var item = {
					"tab" 	: group.getElementById(page~"_"~tab),
					"text"	: group.getElementById(page~"_"~tab~"_Text"),
					"back"	: group.getElementById(page~"_"~tab~"_Back"),
				};
				
				me._can[page][tab] =  item;
			}
		}
	},
	
	scroll : func(amount){
		me._index += amount;
		if (me._index > me._max){ me._index = me._max; }
		if (me._index < 0){ me._index = 0; }

		
		
		foreach(var t;me._tab){
# 			print("TabWidget.scroll() ... "~t);
			me._can[t].content.setVisible(0);
			me._can[t].tab.set("z-index",1);
			me._can[t].back.set("stroke",COLOR["Blue"]);
			me._can[t].back.set("stroke-width",10);
			me._can[t].text.set("fill",COLOR["Blue"]);
		}
		
		me._can[me._tab[me._index]].content.setVisible(1);
		me._can[me._tab[me._index]].tab.set("z-index",2);
		me._can[me._tab[me._index]].back.set("stroke",COLOR["Turquoise"]);
		me._can[me._tab[me._index]].back.set("stroke-width",12);
		me._can[me._tab[me._index]].text.set("fill",COLOR["Turquoise"]);
	
		me._Page._initWidgetsForTab(me._index);
	},
	
	gotoPage : func(name,key=nil){
		
		if (!contains(me._can,name)){
				me._active = "none";
		}
		
		if (me._IFD._state == 1){
			
		
			if (me._active != name){
# 				me.page[me.pageSelected].deinit();
				me._IFD.page[me._active].setVisible(0);
				me._IFD.clearLeds();
				me._active = name;
				me._IFD.nPageSelected.setValue(me._active);
# 				me.page[me.pageSelected].init();
				me._IFD.page[me._active].setVisible(1);
				
			}else{
				if(key!=nil){
					me._IFD.page[me._active].onClick(key);
				}
			}
		}else{
			me._IFD.page[me._active].setVisible(0);
			me._IFD.clearLeds();
			me._active = name;
			me._IFD.nPageSelected.setValue(me._active);
# 			me.page[me.pageSelected].init();
			me._IFD.page[me._active].setVisible(1);
		}
	},
};

var ADAHRS_System = {
	new: func(ifd){
		var m = {parents:[ADAHRS_System,ListenerClass.new()]};
		m._class 	= "ADAHRS_System";
		m._ifd = ifd;
		m._ptree	= {
			ready	: props.globals.initNode("/extra500/instrumentation/IFD-"~m._ifd.name~"/ADAHRS/ready",0,"BOOL"),
			readyEnv	: props.globals.initNode("/extra500/instrumentation/IFD-"~m._ifd.name~"/env/ready",0,"BOOL"),
			readyIAS	: props.globals.initNode("/extra500/instrumentation/IFD-"~m._ifd.name~"/airspeed/ready",0,"BOOL"),
			readyALT	: props.globals.initNode("/extra500/instrumentation/IFD-"~m._ifd.name~"/altimeter/ready",0,"BOOL"),
			readyVS		: props.globals.initNode("/extra500/instrumentation/IFD-"~m._ifd.name~"/ivsi/ready",0,"BOOL"),
			
		};
		
		m._h1 = "";
		m._h2 = "";
		m._h3 = "";
		m._h4 = "";
		m._h5 = "";
		
		
		m._ready = 0;
		m._toGo = 30;
		m._warm = 0;
		
		return m;
	},
	init : func(instance=me){
		me.setListeners(instance);
	},
	deinit : func(){
		me.removeListeners();	
	},
	setListeners : func(instance) {
		append(me._listeners, setlistener(me._ptree.ready,func(n){me._onReadyChange(n)},1,0));
		
	},
	boot : func(warm=nil){
		if(warm != nil){
			me._warm = warm;
		}
		if(me._warm){
			me._toGo = 12;
		}else{
			me._toGo = 30;	
		}
		
		me._h1 = "";
		me._h2 = "";
		me._h3 = "Booting";
		me._h4 = "";
		me._h5 = "";
		
		
		me._ptree.ready.setBoolValue(0);
	},
	_onReadyChange : func(n){
		me._ready = n.getValue();
		if(me._ready){
						
		}else{
			me.boot();
		}
	},
	update2Hz : func(now,dt){
		if(!me._ready){
			if(me._warm){
				if (me._toGo >= 12){
					me._h1 = "Warm Start";
					me._h2 = "AHRS Allignment";
					me._h3 = "Please Standby";
				}elsif(me._toGo >= 10){
					me._h3 = "Attempting Quick Restart";
					me._h4 = "Ready To Go";
					me._h5 = sprintf("In %i Seconds",me._toGo);
				}elsif(me._toGo >= 5){
					
					me._h5 = sprintf("In %i Seconds",me._toGo);
				}else{
					#boot finished
					me._ptree.ready.setBoolValue(1);
					me._warm = 1;
				}
					
				
			}else{
				if (me._toGo >= 30){
					me._h1 = "Initial";
					me._h2 = "AHRS Allignment";
					me._h3 = "Please Standby";
					
				}elsif(me._toGo >= 25){
					me._ptree.readyEnv.setBoolValue(1);
					me._h3 = "Remain Stationary";
					me._h4 = "OK To Taxi";
					me._h5 = sprintf("In %i Seconds",me._toGo);
				}elsif(me._toGo >= 22){
					me._ptree.readyIAS.setBoolValue(1);
					
					me._h5 = sprintf("In %i Seconds",me._toGo);
				}elsif(me._toGo >= 18){
					me._ptree.readyALT.setBoolValue(1);
					
					me._h5 = sprintf("In %i Seconds",me._toGo);
				}elsif(me._toGo >= 15){
					me._ptree.readyVS.setBoolValue(1);
					
					me._h5 = sprintf("In %i Seconds",me._toGo);
				}elsif(me._toGo >= 5){
					
					me._h5 = sprintf("In %i Seconds",me._toGo);
				}else{
					#boot finished
					me._ptree.ready.setBoolValue(1);
					me._warm = 1;
				}
					
			}
			
			me._toGo -=1;
		}
	},
	update20Hz : func(now,dt){
		
	},
};

var AvidyneIFD = {
	new: func(root,name,acPlace,startPage="none"){
		var m = { parents: [
			AvidyneIFD,
			extra500.ServiceClass.new(root,name)
		] };
		m.name 			= name;
		m.keys 			= {};
		m.nBacklight  		= m._nRoot.initNode("Backlight/state",1.0,"DOUBLE");
		m.nBacklightMode	= m._nRoot.initNode("Backlight/mode",0,"BOOL");
		m._backlight		= 0;
		m._backlightMode	= 0;
		
		
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
		m.canvas.setColorBackground("#000337");

		m._group = m.canvas.createGroup("Global");

		
		canvas.parsesvg(m._group, "Models/instruments/IFDs/IFD_Global.svg",{
			"font-mapper": global.canvas.FontMapper
			}
		);
		
		
		m.movingMap = MovingMap.new(m,m._group.getElementById("MovingMap"),name~"-MovingMap");
		
		m._widget = {
			Headline	: HeadlineWidget.new(m,m._group.getElementById("Headline"),"Headline"),
			PlusData	: PlusDataWidget.new(m,m._group.getElementById("PlusData"),"PlusData"),
			
			
		};
		
		m._can = {
			Layout : {
				#Layout		: m._group.getElementById("Layout").set("z-index",-5),
				PFD		: m._group.getElementById("Layout_PFD").setVisible(0),
				Full		: m._group.getElementById("Layout_Full").setVisible(0),
				Split		: m._group.getElementById("Layout_Split").setVisible(0),
				Plus		: m._group.getElementById("Layout_Plus").setVisible(0),
				
			}
			
		};
		
		m.ADAHRS = ADAHRS_System.new(m);
		m.data 	= AvidyneData.new(m.name);
		m.ui 	= IFDUserInterface.new(m);
		
		
		m.pageSelected = "none";
		m.nPageSelected = m._nRoot.initNode("PageSelected","","STRING");
		
		m._startPage = startPage;
		
		m.page = {};
		m.page["none"] = AvidynePageDummy.new(m,"none",m.data);
		
		m.page["PFD"] = AvidynePagePFD.new(m,"PFD",m.data);
		m.page["PFD"]._tab = ["Nav","Bug"];
		
		m.page["FMS"] = AvidynePageFMS.new(m,"FMS",m.data);
		m.page["FMS"]._tab = ["FPL","MapFPL","Info","Routes","UserWypts","Nearest","MapNearest"];
		
		m.page["MAP"] = AvidynePageMAP.new(m,"MAP",m.data);
		m.page["MAP"]._tab = ["Map+","Map","Split","Chart","Chart+"];
		
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
		
		
		me.ui.bindKey("DIM",{
			"<" : func(){me._adjustBrightness(-0.05);},
			">" : func(){me._adjustBrightness(0.05);},
		});
		
		me.ui.bindKnob("BARO",{
			"<"	: func(){me.data.adjustBaro(-1);},
			">"	: func(){me.data.adjustBaro(1);},
			"push"	: func(){me.data.adjustBaro();},
		});
		
		me.ui.bindKey("PFD",{
			"<"	: func(){me.gotoPage("PFD");},
			">"	: func(){me.gotoPage("PFD");},
		});
		me.ui.bindKey("FMS",{
			"<"	: func(){me.gotoPage("FMS");},
			">"	: func(){me.gotoPage("FMS");},
		});
		me.ui.bindKey("MAP",{
			"<"	: func(){me.gotoPage("MAP");},
			">"	: func(){me.gotoPage("MAP");},
		});
		me.ui.bindKey("SYS",{
			"<"	: func(){me.gotoPage("SYS");},
			">"	: func(){me.gotoPage("SYS");},
		});
		me.ui.bindKey("CHKL",{
			"<"	: func(){me.gotoPage("CHKL");},
			">"	: func(){me.gotoPage("CHKL");},
		});
				
		
		#me.gotoPage(me._startPage);
		
		me.movingMap.init();
		
		me._widget.Headline.init();
		me._widget.PlusData.init();
		me.ADAHRS.init();
		
		me.page["none"].init();
		me.page["PFD"].init();
		me.page["FMS"].init();
		me.page["MAP"].init();
		
		
		me._timerLoop20Hz = maketimer(0.05,me,AvidyneIFD.update20Hz);
		me._timerLoop2Hz = maketimer(0.5,me,AvidyneIFD.update2Hz);
	
		me._timerLoop20Hz.start();
		me._timerLoop2Hz.start();
		
	},
	
	setLayout : func(layout){
		me._layout = layout;
		if ( me._layout == IFD_LAYOUT.PFD ){
			me._widget.Headline.setVisible(0);
			me._widget.PlusData.setVisible(0);
			
			me._can.Layout.PFD.setVisible(1);
			me._can.Layout.Plus.setVisible(0);
			me._can.Layout.Full.setVisible(0);
			me._can.Layout.Split.setVisible(0);
			
		}elsif ( me._layout == IFD_LAYOUT.FULL ){
			me._widget.Headline.setVisible(1);
			me._widget.PlusData.setVisible(0);
			
			me._can.Layout.PFD.setVisible(0);
			me._can.Layout.Plus.setVisible(0);
			me._can.Layout.Full.setVisible(1);
			me._can.Layout.Split.setVisible(0);
			
		}elsif ( me._layout == IFD_LAYOUT.SPLIT ){
			me._widget.Headline.setVisible(1);
			me._widget.PlusData.setVisible(0);
			
			me._can.Layout.PFD.setVisible(0);
			me._can.Layout.Plus.setVisible(0);
			me._can.Layout.Full.setVisible(1);
			me._can.Layout.Split.setVisible(1);
			
		}elsif ( me._layout == IFD_LAYOUT.PLUS ){
			me._widget.Headline.setVisible(1);
			me._widget.PlusData.setVisible(1);
			
			me._can.Layout.PFD.setVisible(0);
			me._can.Layout.Plus.setVisible(1);
			me._can.Layout.Full.setVisible(0);
			me._can.Layout.Split.setVisible(0);
		}else{
			me._can.Layout.PFD.setVisible(0);
			me._can.Layout.Plus.setVisible(0);
			me._can.Layout.Full.setVisible(0);
			me._can.Layout.Split.setVisible(0);
		}
	},
	
	_onPowerVoltNormChange : func(n){
		var voltNormA = me._powerA._nVoltNorm.getValue();
		var voltNormB = me._powerB._nVoltNorm.getValue();
		me._voltNorm = voltNormA > voltNormB ? voltNormA : voltNormB;
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
			me.boot();
		}else{
			me.gotoPage("none");
			me._voltNorm = 0;
		}
	},
	boot : func(warm = nil){
		me.ADAHRS.boot(warm);
		me.page[me.pageSelected].boot(warm);
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
			me.ADAHRS.update2Hz(me._now2Hz,me._dt2Hz);
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
		me.ui.setBacklight(value);
		me.nBacklightMode.setValue(me._backlightMode and me._backlight);
	},
	setBacklightMode : func(value){
		me._backlightMode = (value==1);
		me.nBacklightMode.setValue(me._backlightMode and me._backlight);	
	},
	gotoPage : func(name){
# 		print("IFD "~me.name ~" gotoPage("~name~") .. ");
		if (!contains(me.page,name)){
				name = "none";	
		}
		var activePage = me.pageSelected;
				
		if (me._state == 1){
			
		
			if (me.pageSelected != name){
# 				me.page[me.pageSelected].deinit();
				me.page[me.pageSelected].setVisible(0);
				me.ui.bindKey(me.pageSelected,{
					"<"	: func(){me.gotoPage(activePage);},
					">"	: func(){me.gotoPage(activePage);},
				});
				
				me.pageSelected = name;
				me.nPageSelected.setValue(me.pageSelected);
				me.page[me.pageSelected].setVisible(1);
				
			}else{
# 				print("IFD["~me.name ~"].gotoPage("~name~") ...  ERROR active Page call.");
			}
		}else{
			### no power Going to page "none" a black screen.
			name = "none";
			me.page[me.pageSelected].setVisible(0);
			me.ui.bindKey(me.pageSelected,{
				"<"	: func(){me.gotoPage(activePage);},
				">"	: func(){me.gotoPage(activePage);},
			});
				
			me.pageSelected = name;
			me.nPageSelected.setValue(me.pageSelected);
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
# 			if (contains(me.keys,key)){
# 				if(me.keys[key] != nil){
# 					me.keys[key]();
# 					return 1;
# 				}
# 			}
# 			
# 			me.page[me.pageSelected].onClick(key);
			
			me.ui.onClick(key);
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
		UI.register("IFD "~me.name~" BARO STD",func{me.onClick("BARO push"); } );
		
		UI.register("IFD "~me.name~" RK >>",func{me.onClick("RK >>"); } );
		UI.register("IFD "~me.name~" RK <<",func{me.onClick("RK <<"); } );
		UI.register("IFD "~me.name~" RK",func{me.onClick("RK push"); } );
		UI.register("IFD "~me.name~" RK >",func{me.onClick("RK >"); } );
		UI.register("IFD "~me.name~" RK <",func{me.onClick("RK <"); } );
		
		UI.register("IFD "~me.name~" LK >>",func{me.onClick("LK >>"); } );
		UI.register("IFD "~me.name~" LK <<",func{me.onClick("LK <<"); } );
		UI.register("IFD "~me.name~" LK",func{me.onClick("LK push"); } );
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




