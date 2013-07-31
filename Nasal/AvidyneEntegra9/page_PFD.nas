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



# var NAV_SOURCE_NAME 	= ["Nav 1","Nav 2","FMS"];
# var NAV_SOURCE_TREE 	= ["/instrumentation/nav[0]","/instrumentation/nav[1]","/instrumentation/fms"];
# 
# var BEARING_SOURCE_NAME = ["0ff","Nav 1","Nav 2","FMS"];
# var BEARING_SOURCE_TREE = [nil,"/instrumentation/nav[0]","/instrumentation/nav[1]","/instrumentation/fms"];


var AutopilotWidget = {
	
	new: func(page,canvasGroup,name){
		var m = {parents:[AutopilotWidget,IfdWidget.new(page,canvasGroup,name)]};
		m._class = "AutopilotWidget";
		m._can		= {
			Autopilot	: m._group.getElementById("Autopilot"),
			Off		: m._group.getElementById("AP_Off").setVisible(0),
			State 		: m._group.getElementById("AP_State"),
			ModeHDG 	: m._group.getElementById("AP_HDG").setVisible(0),
			ModeNAV 	: m._group.getElementById("AP_NAV").setVisible(0),
			ModeAPR 	: m._group.getElementById("AP_APR").setVisible(0),
			ModeGS	 	: m._group.getElementById("AP_GS").setVisible(0),
			ModeGPSS 	: m._group.getElementById("AP_GPSS").setVisible(0),
			ModeTRIM 	: m._group.getElementById("AP_TRIM").setVisible(0),
			ModeALT 	: m._group.getElementById("AP_ALT").setVisible(0),
			ModeVS 		: m._group.getElementById("AP_VS").setVisible(0),
			ModeCAP 	: m._group.getElementById("AP_CAP").setVisible(0),
			ModeSOFT 	: m._group.getElementById("AP_SOFT").setVisible(0),
			ModeFD 		: m._group.getElementById("AP_FD").setVisible(0),
		};
		me._state	= 0;
		me._ready	= 0;
		me._fail	= 0;
		
		me._modeALT	= 0;
		me._modeHDG	= 0;
		me._modeVS	= 0;
		return m;
	},
	setListeners : func(instance) {
		append(me._listeners, setlistener("/extra500/instrumentation/Autopilot/state",func(n){me._onStateChange(n)},1,0));
		append(me._listeners, setlistener("/autopilot/mode/rdy",func(n){me._onReady(n)},1,0));
		append(me._listeners, setlistener("/autopilot/mode/fail",func(n){me._onFail(n)},1,0));
		append(me._listeners, setlistener("/autopilot/mode/alt",func(n){me._onALT(n)},1,0));
		append(me._listeners, setlistener("/autopilot/mode/nav",func(n){me._onNAV(n)},1,0));
		append(me._listeners, setlistener("/autopilot/mode/apr",func(n){me._onAPR(n)},1,0));
		append(me._listeners, setlistener("/autopilot/mode/gs",func(n){me._onGS(n)},1,0));
		append(me._listeners, setlistener("/autopilot/mode/gpss",func(n){me._onGPSS(n)},1,0));
		append(me._listeners, setlistener("/autopilot/mode/trim",func(n){me._onTRIM(n)},1,0));
		append(me._listeners, setlistener("/autopilot/mode/vs",func(n){me._onVS(n)},1,0));
		append(me._listeners, setlistener("/autopilot/mode/cap",func(n){me._onCAP(n)},1,0));
		append(me._listeners, setlistener("/autopilot/mode/soft",func(n){me._onSOFT(n)},1,0));
		append(me._listeners, setlistener("/autopilot/mode/heading",func(n){me._onHDG(n)},1,0));
		append(me._listeners, setlistener("/autopilot/settings/ap",func(n){me._onAP(n)},1,0));
		append(me._listeners, setlistener("/autopilot/settings/fd",func(n){me._onFP(n)},1,0));
		
	},
	_onStateChange: func(n){
		me._state	= n.getValue();
		me._can.Autopilot.setVisible(me._state);
		me._can.Off.setVisible(!me._state);
	},
	_checkState : func(){
		if( me._fail == 1 ){
			me._can.State.setText("AP FAIL");
			me._can.State.setColor(COLOR["Yellow"]);
			me._can.State.setVisible(1);
			me._can.ModeFD.setVisible(0);
		}else{
			if( me._ready == 1 ){
				me._can.State.setText("AP RDY");
				me._can.State.setColor(COLOR["Green"]);
				me._can.State.setVisible(1);
				me._can.ModeFD.setVisible(1);
			}else{
				me._can.State.setText("AP");
				me._can.State.setColor(COLOR["Green"]);
				me._can.State.setVisible(1);
				me._can.ModeFD.setVisible(1);
			}
		}
	},
	_onReady : func(n){
		me._ready	= n.getValue();
		me._checkState();
	},
	_onFail : func(n){
		me._fail	= n.getValue();
		me._checkState();
	},
	_onALT : func(n){
		me._modeALT = n.getValue();
		me._can.ModeALT.setVisible(me._modeALT);
		if(me._modeALT == 1){
			me._Page._widget.Altitude._can.Bug.set("fill",COLOR["Magenta"]);
		}else{
			me._Page._widget.Altitude._can.Bug.set("fill","none");
		}
	},
	_onNAV : func(n){
		me._can.ModeNAV.setVisible(n.getValue());
	},
	_onAPR : func(n){
		me._can.ModeAPR.setVisible(n.getValue());
	},
	_onGS : func(n){
		me._can.ModeGS.setVisible(n.getValue());
	},
	_onGPSS : func(n){
		me._can.ModeGPSS.setVisible(n.getValue());
	},
	_onTRIM : func(n){
		me._can.ModeTRIM.setVisible(n.getValue());
	},
	_onVS : func(n){
		me._modeVS = n.getValue();
		me._can.ModeVS.setVisible(me._modeVS);
		if(me._modeVS == 1){
			me._Page._widget.VerticalSpeed._can.Bug.set("fill",COLOR["Magenta"]);
		}else{
			me._Page._widget.VerticalSpeed._can.Bug.set("fill","none");
		}
	},
	_onCAP : func(n){
		me._can.ModeCAP.setVisible(n.getValue());
	},
	_onSOFT : func(n){
		me._can.ModeSOFT.setVisible(n.getValue());
	},
	_onHDG : func(n){
		me._modeHDG = n.getValue();
		me._can.ModeHDG.setVisible(me._modeHDG);
		if(me._modeHDG == 1){
			me._Page._widget.HSI._can.HeadingBug.set("fill",COLOR["Magenta"]);
		}else{
			me._Page._widget.HSI._can.HeadingBug.set("fill","none");
		}
	},
	_onAP : func(n){
		me._can.ModeFD.setText("AP");
	},
	_onFP : func(n){
		me._can.ModeFD.setText("FD");
	},
	init : func(instance=me){
		#print("AutopilotWidget.init() ... ");
		me.setListeners(instance);
	},
	deinit : func(){
		#print("AutopilotWidget.deinit() ... ");
		me.removeListeners();	
	},
};

var VerticalSpeedWidget = {
	new: func(page,canvasGroup,name){
		var m = {parents:[VerticalSpeedWidget,IfdWidget.new(page,canvasGroup,name)]};
		m._class 	= "VerticalSpeedWidget";
		m._ptree	= {
			vs	: props.globals.initNode("/instrumentation/ivsi-IFD-"~m._Page.IFD.name~"/indicated-speed-fpm",0.0,"DOUBLE"),
		};
		m._can		= {
			Needle		: m._group.getElementById("VS_Needle").updateCenter(),
			Bug		: m._group.getElementById("VS_Bug").updateCenter(),
			BugValue	: m._group.getElementById("VS_Indicated"),
		};
		m._ap		= 0;
		m._bug		= 0;
		m._vs		= 0;
		return m;
	},
	setListeners : func(instance) {
		append(me._listeners, setlistener("/autopilot/mode/vs",func(n){me._onApChange(n)},1,0));	
		append(me._listeners, setlistener("/autopilot/settings/vertical-speed-fpm",func(n){me._onBugChange(n)},1,0));	
	},
	_onApChange : func(n){
		me._ap = n.getValue();
		if(me._ap == 1){
			me._can.Bug.set("fill",COLOR["Magenta"]);
		}else{
			me._can.Bug.set("fill","none");
		}
	},
	_onBugChange : func(n){
		me._bug = n.getValue();
		me._can.BugValue.setText(sprintf("%4i",math.floor( me._bug + 0.5 )));
		me._can.Bug.setRotation(me._rotateScale(me._bug));
		
	},
	_rotateScale : func(vs){
		if (vs >= -1000 ){
			if (vs <= 1000){
				return ((vs/100*1.50) * global.CONST.DEG2RAD);
			}else{
				return ( ( 15 + ((vs-1000)/100*0.75) ) * global.CONST.DEG2RAD);
			}
		}else{
			return ( ( -15 + ((vs+1000)/100*0.75) ) * global.CONST.DEG2RAD);
		}
	},
	init : func(instance=me){
		me.setListeners(instance);
	},
	deinit : func(){
		me.removeListeners();	
	},
	update20Hz : func(now,dt){
		me._vs	= me._ptree.vs.getValue();
		me._can.Needle.setRotation(me._rotateScale(me._vs));
	},
	
};

var AirspeedSpeedWidget = {
	new: func(page,canvasGroup,name){
		var m = {parents:[AirspeedSpeedWidget,IfdWidget.new(page,canvasGroup,name)]};
		m._class 	= "AirspeedSpeedWidget";
		m._ptree	= {
			ias	: props.globals.initNode("/instrumentation/airspeed-IFD-"~m._Page.IFD.name~"/indicated-airspeed-kt",0.0,"DOUBLE"),
			iasRate	: props.globals.initNode("/instrumentation/airspeed-IFD-"~m._Page.IFD.name~"/airspeed-change-ktps",0.0,"DOUBLE"),
			tas	: props.globals.initNode("/instrumentation/airspeed-IFD-"~m._Page.IFD.name~"/true-speed-kt",0.0,"DOUBLE"),
		};
		m._can		= {
			IAS_Ladder	: m._group.getElementById("IAS_Ladder").set("clip","rect(126px, 648px, 784px, 413px)"),
			IAS_001		: m._group.getElementById("IAS_001").set("clip","rect(383px, 581px, 599px, 505px)"),
			IAS_010		: m._group.getElementById("IAS_010").set("clip","rect(453px, 514px, 528px, 384px)"),
			IAS_100		: m._group.getElementById("IAS_100").set("clip","rect(453px, 514px, 528px, 384px)"),
			Plade		: m._group.getElementById("IAS_BlackPlade"),
			Zero		: m._group.getElementById("IAS_Zero").setVisible(1),
			Rate		: m._group.getElementById("IAS_Rate").set("clip","rect(126px, 648px, 784px, 413px)"),
			TAS		: m._group.getElementById("IAS_TAS"),
		};
		m._ias		= 0;
		m._rate		= 0;
		m._tas		= 0;
		m._limitVne	= 207;
		m._limitVso	= 58;
		m._limitZero	= 20;
		m._ladderPX	= 74.596;
		
		m._speed	= 0;
		m._speedAdd	= 0;
		
		return m;
	},
	setListeners : func(instance) {
		
	},
	init : func(instance=me){
		me.setListeners(instance);
	},
	deinit : func(){
		me.removeListeners();	
	},
	update20Hz : func(now,dt){
		me._ias		= me._ptree.ias.getValue();
		me._rate	= me._ptree.iasRate.getValue();;
		me._tas		= me._ptree.tas.getValue();;
		
		
		me._can.IAS_Ladder.setTranslation(0,(me._ias-20)*10);
		if ( me._ias < me._limitZero ){
			me._can.IAS_100.setVisible(0);
			me._can.IAS_010.setVisible(0);
			me._can.IAS_001.setVisible(0);
			me._can.Plade.setVisible(0);
			me._can.Rate.setVisible(0);
			me._can.Zero.setVisible(1);
			me._can.TAS.setText("---");
		}else{
			me._can.Zero.setVisible(0);
			me._can.Rate.setVisible(1);
			me._can.Plade.setVisible(1);
			me._can.IAS_001.setVisible(1);
			
			#me._can.Rate.set("coord[1]",4286+(-me._rate*62));
			me._can.Rate.setData([2,6,8,6,0],[585.5,491.4286+(-me._rate*62),604,491.4286,585.5]);
# 			
			me._can.TAS.setText(sprintf("%3i",me._tas));
			
			me._speed = math.mod(me._ias,10);
			
			me._can.IAS_001.setTranslation(0,(me._speed * me._ladderPX));
			
			if (me._ias > 10){
				if (me._speed >= 9){
					me._speedAdd = me._speed - 9;
				}else{
					me._speedAdd = 0;
				}
				me._speed = math.floor(math.mod(me._ias,100)/10);
				me._can.IAS_010.setTranslation(0,((me._speed+me._speedAdd) * me._ladderPX));
				me._can.IAS_010.setVisible(1);
				
				if (me._ias > 100){
					
					if (me._speed < 9){
						me._speedAdd = 0;
					}
					
					me._speed = math.floor(math.mod(me._ias,1000)/100);
					me._can.IAS_100.setTranslation(0,((me._speed+me._speedAdd) * me._ladderPX));
					me._can.IAS_100.setVisible(1);
				
					me._can.IAS_100.setVisible(1);
				}else{
					me._can.IAS_100.setVisible(0);
				}
				
			}else{
				me._can.IAS_100.setVisible(0);
				me._can.IAS_010.setVisible(0);
			}
			
			if( me._ias >= me._limitVne){
				me._can.IAS_100.set("fill",COLOR["Red"]);
				me._can.IAS_010.set("fill",COLOR["Red"]);
				me._can.IAS_001.set("fill",COLOR["Red"]);
			}elsif (me._ias < me._limitVso){
				me._can.IAS_100.set("fill",COLOR["Red"]);
				me._can.IAS_010.set("fill",COLOR["Red"]);
				me._can.IAS_001.set("fill",COLOR["Red"]);
			}else{
				me._can.IAS_100.set("fill",COLOR["White"]);
				me._can.IAS_010.set("fill",COLOR["White"]);
				me._can.IAS_001.set("fill",COLOR["White"]);
			}
			
			if( me._ias >= me._limitVne + 3.0){
				me._Page.IFD._nOverSpeedWarning.setValue(1);
			}else{
				me._Page.IFD._nOverSpeedWarning.setValue(0);
			}
			
		}
	},
	
};

var AltitudeWidget = {
	new: func(page,canvasGroup,name){
		var m = {parents:[AltitudeWidget,IfdWidget.new(page,canvasGroup,name)]};
		m._class 	= "AltitudeWidget";
		m._ptree	= {
			alt	: props.globals.initNode("/instrumentation/altimeter-IFD-"~m._Page.IFD.name~"/indicated-altitude-ft",0.0,"DOUBLE"),
		};
		m._can		= {
			Ladder		: m._group.getElementById("ALT_Ladder").set("clip","rect(170px, 2060px, 785px, 1680px)"),
			U300T		: m._group.getElementById("ALT_LAD_U300T"),
			U300H		: m._group.getElementById("ALT_LAD_U300H"),
			U200T		: m._group.getElementById("ALT_LAD_U200T"),
			U200H		: m._group.getElementById("ALT_LAD_U200H"),
			U100T		: m._group.getElementById("ALT_LAD_U100T"),
			U100H		: m._group.getElementById("ALT_LAD_U100H"),
			C000T		: m._group.getElementById("ALT_LAD_C000T"),
			C000H		: m._group.getElementById("ALT_LAD_C000H"),
			D100T		: m._group.getElementById("ALT_LAD_D100T"),
			D100H		: m._group.getElementById("ALT_LAD_D100H"),
			D200T		: m._group.getElementById("ALT_LAD_D200T"),
			D200H		: m._group.getElementById("ALT_LAD_D200H"),
			Plade		: m._group.getElementById("AltBlackPlade"),
			Bar10		: m._group.getElementById("AltBar10").set("clip","rect(377px, 2060px, 605px,1680px)"),
			Bar100		: m._group.getElementById("AltBar100").set("clip","rect(451px, 2060px, 527px, 1680px)"),
			Bar1000		: m._group.getElementById("AltBar1000").set("clip","rect(451px, 2060px, 527px, 1680px)"),
			Bar10000	: m._group.getElementById("AltBar10000").set("clip","rect(451px, 2060px, 527px, 1680px)"),
			Bug		: m._group.getElementById("ALT_Bug"),
			BugValue	: m._group.getElementById("ALT_Selected"),
			HPA		: m._group.getElementById("hPa"),
		};
		m._alt	 	= 0;
		m._bugDiff 	= 0;
		m._hpa 		= 0;
		m._tmpAlt 	= 0;
		m._tmpAltAdd 	= 0;
		m._SCALE_BAR_PX_100	= 75.169;
		m._SCALE_BAR_PX_10	= (m._SCALE_BAR_PX_100/20);
		m._SCALE_LAD_PX		= 1.36;# 136 px
		return m;
	},
	setListeners : func(instance) {
		append(me._listeners, setlistener("/autopilot/settings/tgt-altitude-ft",func(n){me._onBugChange(n)},1,0));	
		append(me._listeners, setlistener("/instrumentation/altimeter-IFD-"~me._Page.IFD.name~"/setting-hpa",func(n){me._onHpaChange(n)},1,0));	
	
	},
	init : func(instance=me){
		me.setListeners(instance);
	},
	deinit : func(){
		me.removeListeners();	
	},
	_onHpaChange : func(n){
		me._hpa		= n.getValue();
		me._can.HPA.setText(sprintf("%4i",me._hpa));
	},
	_onBugChange : func(n){
		me._bug = n.getValue();
				
		me._can.BugValue.setText(sprintf("%4i",math.floor( me._bug + 0.5 )));
		
		me._bugDiff = (me._alt - me._bug) * me._SCALE_LAD_PX;
		me._bugDiff = global.clamp(me._bugDiff,-322,294);
		me._can.Bug.setTranslation(0,me._bugDiff);
	},
	update20Hz : func(now,dt){
		me._alt		= me._ptree.alt.getValue();
		
		me._bugDiff = (me._alt - me._bug) * me._SCALE_LAD_PX;
		me._bugDiff = global.clamp(me._bugDiff,-322,294);
		me._can.Bug.setTranslation(0,me._bugDiff);
		
		me._tmpAlt	= me._alt + 300;
		
		me._can.U300T.setText(sprintf("%i",math.floor(me._tmpAlt/1000)));
		me._can.U300H.setText(sprintf("%03i",math.floor(math.mod(me._tmpAlt,1000) / 100) * 100));
		
		me._tmpAlt-=100;
		
		me._can.U200T.setText(sprintf("%i",math.floor(me._tmpAlt/1000)));
		me._can.U200H.setText(sprintf("%03i",math.floor(math.mod(me._tmpAlt,1000) / 100) * 100));
		
		me._tmpAlt-=100;
		
		me._can.U100T.setText(sprintf("%i",math.floor(me._tmpAlt/1000)));
		me._can.U100H.setText(sprintf("%03i",math.floor(math.mod(me._tmpAlt,1000) / 100) * 100));
		
		me._tmpAlt-=100;
		
		me._can.C000T.setText(sprintf("%i",math.floor(me._tmpAlt/1000)));
		me._can.C000H.setText(sprintf("%03i",math.floor(math.mod(me._tmpAlt,1000) / 100) * 100));
			
		me._tmpAlt-=100;
		
		me._can.D100T.setText(sprintf("%i",math.floor(me._tmpAlt/1000)));
		me._can.D100H.setText(sprintf("%03i",math.floor(math.mod(me._tmpAlt,1000) / 100) * 100));
		
		me._tmpAlt-=100;
		
		me._can.D200T.setText(sprintf("%i",math.floor(me._tmpAlt/1000)));
		me._can.D200H.setText(sprintf("%03i",math.floor(math.mod(me._tmpAlt,1000) / 100) * 100));
		
		
		me._can.Ladder.setTranslation(0,math.mod(me._alt,100) * me._SCALE_LAD_PX);
		
		
		
		me._tmpAlt = math.mod(me._alt,100);
		me._can.Bar10.setTranslation(0, me._tmpAlt * me._SCALE_BAR_PX_10);
				
		if (me._alt>=100){
			if (me._tmpAlt > 80) {
				me._tmpAltAdd = me._tmpAlt - 80;
			}else{
				me._tmpAltAdd = 0;
			}
		
			me._tmpAlt = math.floor(math.mod(me._alt,1000)/100);
			me._can.Bar100.setTranslation(0,(me._tmpAlt * me._SCALE_BAR_PX_100) + ( me._tmpAltAdd * me._SCALE_BAR_PX_10 ));
			me._can.Bar100.setVisible(1);
			if(me._alt>=1000){
				if (me._tmpAlt == 9) {
# 					me._tmpAltAdd = me._tmpAlt - 9;
				}else{
					me._tmpAltAdd = 0;
				}
				#print("update20Hz() ... "~me._tmpAlt~" + "~me._tmpAltAdd);
				
				me._tmpAlt = math.floor(math.mod(me._alt,10000)/1000);
				me._can.Bar1000.setTranslation(0,me._tmpAlt * me._SCALE_BAR_PX_100 + ( me._tmpAltAdd * me._SCALE_BAR_PX_10 ));
				me._can.Bar1000.setVisible(1);
				if (me._alt>=10000){
					if (me._tmpAlt == 9) {
						#me._tmpAltAdd = me._tmpAlt - 9;
					}else{
						me._tmpAltAdd = 0;
					}
					
					me._tmpAlt = math.floor(math.mod(me._alt,100000)/10000);
					me._can.Bar10000.setTranslation(0,me._tmpAlt * me._SCALE_BAR_PX_100 + ( me._tmpAltAdd * me._SCALE_BAR_PX_10 ));
					me._can.Bar10000.setVisible(1);
				}else{
					me._can.Bar10000.setVisible(0);
				}
			}else{
				me._can.Bar10000.setVisible(0);
				me._can.Bar1000.setVisible(0);
			}
		}else{
			me._can.Bar10000.setVisible(0);
			me._can.Bar1000.setVisible(0);
			me._can.Bar100.setVisible(0);
		}
	},
	
};

var AttitudeIndicatorWidget = {
	new: func(page,canvasGroup,name){
		var m = {parents:[AttitudeIndicatorWidget,IfdWidget.new(page,canvasGroup,name)]};
		m._class 	= "AttitudeIndicatorWidget";
		m._ptree	= {
			pitch	: props.globals.initNode("/orientation/pitch-deg",0.0,"DOUBLE"),
			roll	: props.globals.initNode("/orientation/roll-deg",0.0,"DOUBLE"),
			SlipSkid: props.globals.initNode("/instrumentation/slip-skid-ball/indicated-slip-skid",0.0,"DOUBLE"),
		};
		m._can		= {
			PitchLadder	: m._group.getElementById("PitchLadder").updateCenter().set("clip","rect(168px, 1562px, 785px, 845px)"),
			BankAngle	: m._group.getElementById("BankAngleIndicator").updateCenter(),
			SlipSkid	: m._group.getElementById("SlipSkidIndicator").updateCenter(),
			Horizon		: m._group.getElementById("Horizon"),
		};
		
		m._pitch	= 0;
		m._roll		= 0;
		m._slipskid	= 0;
		return m;
	},
	setListeners : func(instance) {
		
	},
	init : func(instance=me){
		me.setListeners(instance);
	},
	deinit : func(){
		me.removeListeners();	
	},
	update20Hz : func(now,dt){
		me._pitch	= me._ptree.pitch.getValue();
		me._roll	= me._ptree.roll.getValue();
		me._slipskid	= me._ptree.SlipSkid.getValue();
		
		me._can.PitchLadder.setRotation(-me._roll * global.CONST.DEG2RAD);
		me._can.PitchLadder.setTranslation(0,me._pitch * 10);
		me._can.SlipSkid.setTranslation(-me._slipskid * 50,0);
		me._can.BankAngle.setRotation(-me._roll * global.CONST.DEG2RAD);
		
		me._can.Horizon.setTranslation(0,me._pitch * 10);
		me._can.Horizon.setRotation(-me._roll * global.CONST.DEG2RAD);
		
	},
	
};

var NavSourceWidget = {
	new: func(page,canvasGroup,name){
		var m = {parents:[NavSourceWidget,IfdWidget.new(page,canvasGroup,name)]};
		m._class 	= "NavSourceWidget";
		m._SOURCE 	= ["Nav1","Nav2","FMS"];
		m._NAME 	= ["Nav 1","Nav 2","FMS"];
		m._PATH	=	{
			FMS 	: {
				Pointer			: "/autopilot/route-manager/wp/bearing-deg",
				horizontalDeviation 	: "/autopilot/fms-channel/course-error-norm",
				verticalDeviation	: "/instrumentation/fms[0]/gs-needle-deflection-norm",
				Frequeny		: "/autopilot/route-manager/wp/id",
				isInRange		: "/instrumentation/fms[0]/in-range",
				isLOC			: "/instrumentation/fms[0]/frequencies/is-localizer-frequency",
				isGSinRange		: "/instrumentation/fms[0]/gs-in-range",
				hasGS			: "/instrumentation/fms[0]/has-gs",
				fromFlag		: "/instrumentation/fms[0]/from-flag",
				toFlag			: "/instrumentation/fms[0]/to-flag",
				distance		: "/autopilot/route-manager/wp/dist",
			},
			Nav1 	: {
				Pointer			: "/instrumentation/nav[0]/radials/selected-deg",
				horizontalDeviation 	: "/instrumentation/nav[0]/heading-needle-deflection-norm",
				verticalDeviation	: "/instrumentation/nav[0]/gs-needle-deflection-norm",
				Frequeny		: "/instrumentation/nav[0]/frequencies/selected-mhz-fmt",
				isInRange		: "/instrumentation/nav[0]/in-range",
				isLOC			: "/instrumentation/nav[0]/frequencies/is-localizer-frequency",
				isGSinRange		: "/instrumentation/nav[0]/gs-in-range",
				hasGS			: "/instrumentation/nav[0]/has-gs",
				fromFlag		: "/instrumentation/nav[0]/from-flag",
				toFlag			: "/instrumentation/nav[0]/to-flag",
				distance		: "/autopilot/radionav-channel/nav-distance-nm",
			},
			Nav2 	: {
				Pointer			: "/instrumentation/nav[1]/radials/selected-deg",
				horizontalDeviation 	: "/instrumentation/nav[1]/heading-needle-deflection-norm",
				verticalDeviation	: "/instrumentation/nav[1]/gs-needle-deflection-norm",
				Frequeny		: "/instrumentation/nav[1]/frequencies/selected-mhz-fmt",
				isInRange		: "/instrumentation/nav[1]/in-range",
				isLOC			: "/instrumentation/nav[1]/frequencies/is-localizer-frequency",
				isGSinRange		: "/instrumentation/nav[1]/gs-in-range",
				hasGS			: "/instrumentation/nav[1]/has-gs",
				fromFlag		: "/instrumentation/nav[1]/from-flag",
				toFlag			: "/instrumentation/nav[1]/to-flag",
				distance		: "/autopilot/radionav-channel/nav-distance-nm",
			},
			
		};
		
		setprop(m._PATH.FMS.isInRange,1);
		
		m._ptree	= {
			hDev		: nil,
			vDev		: nil,
			inRange		: nil,
			LOC		: nil,
			GSinRange	: nil,
			FromFlag	: nil,
			ToFlag		: nil,
			Pointer		: nil,
			Distance	: nil,
			Source		: props.globals.initNode("/instrumentation/nav-source",0,"INT"),
		};
		
		m._can		= {
			Source 		: m._group.getElementById("NAV_SourceName"),
			ID 		: m._group.getElementById("NAV_ID"),
			Crs 		: m._group.getElementById("NAV_CRS"),
			Distance 	: m._group.getElementById("NAV_Distance"),
		};
		
		m._sourceListeners	= [];
		
		m._source		= 2;
		m._horizontalDeviation	= 0;
		m._verticalDeviation	= 0;
		m._isInRange		= 0;
		m._isLOC		= 0;
		m._isGSinRange		= 0;
		m._fromFlag		= 0;
		m._toFlag		= 0;
		m._Pointer		= 0;
		m._stationType		= "";
		m._distance		= 0;
		m._frequency		= "";
		
		return m;
	},
	setListeners : func(instance) {
		
		append(me._listeners, setlistener(me._ptree.Source,func(n){me._onSourceChange(n);},1,0));
				
	},
	removeListeners : func(){
		foreach(l;me._listeners){
			removelistener(l);
		}
		me._listeners = [];
		foreach(l;me._sourceListeners){
			removelistener(l);
		}
		me._sourceListeners = [];
	},
	init : func(instance=me){
		me.setListeners(instance);
		
		me._Page.IFD.nLedL1.setValue(1);
		me._Page.keys["L1 >"] = func(){me._scroll(1);};
		me._Page.keys["L1 <"] = func(){me._scroll(-1);};
		
		me._Page.IFD.nLedLK.setValue(1);
		me._Page.keys["LK <<"]	= func(){me._adjustRadial(-10);};
		me._Page.keys["LK <"] 	= func(){me._adjustRadial(-1);};
		me._Page.keys["LK >"] 	= func(){me._adjustRadial(1);};
		me._Page.keys["LK >>"] 	= func(){me._adjustRadial(10);};
		
		
		me._scroll(0);
	},
	deinit : func(){
		me.removeListeners();
		
		me._Page.IFD.nLedL1.setValue(0);
		me._Page.keys["L1 >"] = nil;
		me._Page.keys["L1 <"] = nil;
		
		me._Page.IFD.nLedLK.setValue(0);
		me._Page.keys["LK <<"] 	= nil;
		me._Page.keys["LK <"] 	= nil;
		me._Page.keys["LK >"] 	= nil;
		me._Page.keys["LK >>"] 	= nil;
		
	},
	_onSourceChange : func(n){
		me._source = n.getValue();
		me.setSource(me._source);
	},
	setSource : func(src){
		me._source = src;
		foreach(l;me._sourceListeners){
			removelistener(l);
		}
		me._sourceListeners = [];
		
		me._ptree.hDev 		= props.globals.initNode(me._PATH[me._SOURCE[me._source]].horizontalDeviation,0,"DOUBLE");
		me._ptree.vDev 		= props.globals.initNode(me._PATH[me._SOURCE[me._source]].verticalDeviation,0,"DOUBLE");
		me._ptree.Distance 	= props.globals.initNode(me._PATH[me._SOURCE[me._source]].distance,0,"DOUBLE");
		me._ptree.Pointer	= props.globals.initNode(me._PATH[me._SOURCE[me._source]].Pointer,0,"DOUBLE");

		append(me._sourceListeners, setlistener(me._PATH[me._SOURCE[me._source]].isInRange,func(n){me._onInRangeChange(n);},1,0));
		append(me._sourceListeners, setlistener(me._PATH[me._SOURCE[me._source]].isLOC,func(n){me._onIsLocChange(n);},1,0));
		append(me._sourceListeners, setlistener(me._PATH[me._SOURCE[me._source]].isGSinRange,func(n){me._onGsInRangeChange(n);},1,0));
		append(me._sourceListeners, setlistener(me._PATH[me._SOURCE[me._source]].fromFlag,func(n){me._onFromFlagChange(n);},1,0));
		append(me._sourceListeners, setlistener(me._PATH[me._SOURCE[me._source]].toFlag,func(n){me._onToFlagChange(n);},1,0));
		append(me._sourceListeners, setlistener(me._PATH[me._SOURCE[me._source]].hasGS,func(n){me._onHasGSChange(n);},1,0));
		append(me._sourceListeners, setlistener(me._PATH[me._SOURCE[me._source]].Frequeny,func(n){me._onFrequencyChange(n);},1,0));
		
	},
	_scroll : func(amount){
		me._source += amount;
		if (me._source > 2){ me._source = 0; }
		if (me._source < 0){ me._source = 2; }
		me.setSource(me._source);
		me._ptree.Source.setValue(me._source);
		me._can.Source.setText(me._NAME[me._source]);
				
	},
	_adjustRadial : func(amount){
		me._Pointer += amount;
		me._Pointer = math.mod(me._Pointer,360.0);
		setprop("/instrumentation/nav[0]/radials/selected-deg",me._Pointer);
		setprop("/instrumentation/nav[1]/radials/selected-deg",me._Pointer);
	},
	_onInRangeChange : func(n){
		me._isInRange = n.getValue();
	},
	_onGsInRangeChange : func(n){
		me._isGSinRange = n.getValue();
	},
	_onIsLocChange : func(n){
		me._isLOC = n.getValue();
		me._checkStationType();
	},
	_onFromFlagChange : func(n){
		me._fromFlag = n.getValue();
	},
	_onToFlagChange : func(n){
		me._toFlag = n.getValue();
	},
	_onHasGSChange : func(n){
		me._hasGS = n.getValue();
		me._checkStationType();
	},
	_onFrequencyChange : func(n){
		me._frequency = n.getValue();
		me._checkStationType();
	},
	_checkStationType : func(){
		me._distance	= me._ptree.Distance.getValue();
		me._can.Distance.setText(sprintf("%.1f",me._distance));
		if (me._source == 2){
			me._can.ID.setText(sprintf("%s",me._frequency));
		}else{
			if (me._isLOC == 1){
				if (me._hasGS == 1){
					me._stationType = "ILS";
				}else{
					me._stationType = "LOC";
				}
			}else{
				me._stationType = "VOR";
			}
			me._can.ID.setText(sprintf("%.2f (%s)",me._frequency,me._stationType));
			
			
		}
	},
	update2Hz : func(now,dt){
		
		me._distance	= me._ptree.Distance.getValue();
		me._can.Distance.setText(sprintf("%.1f",me._distance));
		
	},
	
	update20Hz : func(now,dt){
		me._Pointer		= me._ptree.Pointer.getValue();
		me._horizontalDeviation	= me._ptree.hDev.getValue();
		me._verticalDeviation	= -me._ptree.vDev.getValue();
		
# 		me._isInRange		= me._ptree.inRange.getValue();
# 		me._isGSinRange		= me._ptree.GSinRange.getValue();
# 		me._isLOC		= me._ptree.LOC.getValue();
# 		me._fromFlag		= me._ptree.FromFlag.getValue();
# 		me._toFlag		= me._ptree.FromFlag.getValue();
		
		me._can.Crs.setText(sprintf("%i",me._Pointer +0.5));
		
		
	},
};

var BearingSourceWidget = {
	new: func(page,canvasGroup,name){
		var m = {parents:[BearingSourceWidget,IfdWidget.new(page,canvasGroup,name)]};
		m._class 	= "BearingSourceWidget";
		m._SOURCE 	= ["0ff","Nav1","Nav2","FMS"];
		m._NAME 	= ["0ff","Nav 1","Nav 2","FMS"];
		m._PATH	=	{
			FMS 	: {
				isLOC			: "/instrumentation/fms[0]/frequencies/is-localizer-frequency",
				Frequency		: "/autopilot/route-manager/wp/id",
				Pointer			: "/autopilot/route-manager/wp/bearing-deg",
				hasGS			: "/instrumentation/fms[0]/has-gs",
				distance		: "/autopilot/route-manager/wp/dist",
			},
			Nav1 	: {
				isLOC			: "/instrumentation/nav[0]/frequencies/is-localizer-frequency",
				Frequency		: "/instrumentation/nav[0]/frequencies/selected-mhz-fmt",
				Pointer			: "/instrumentation/nav[0]/radials/reciprocal-radial-deg",
				hasGS			: "/instrumentation/nav[0]/has-gs",
				distance		: "/autopilot/radionav-channel/nav-distance-nm",
			},
			Nav2 	: {
				isLOC			: "/instrumentation/nav[1]/frequencies/is-localizer-frequency",
				Frequency		: "/instrumentation/nav[1]/frequencies/selected-mhz-fmt",
				Pointer			: "/instrumentation/nav[1]/radials/reciprocal-radial-deg",
				hasGS			: "/instrumentation/nav[1]/has-gs",
				distance		: "/autopilot/radionav-channel/nav-distance-nm",
			},
			
		};
		m._ptree	= {
			Pointer		: nil,
			Distance	: nil,
		};
		m._can		= {
			Off 		: m._group.getElementById("BearingPtr_Off"),
			On	 	: m._group.getElementById("BearingPtr_On").setVisible(0),
			Source 		: m._group.getElementById("BearingPtr_Source"),
			ID 		: m._group.getElementById("BearingPtr_ID"),
			Brg 		: m._group.getElementById("BearingPtr_BRG"),
			Distance 	: m._group.getElementById("BearingPtr_NM"),
			Pointer 	: m._group.getElementById("BearingPtr_Pointer").updateCenter().setVisible(0),
		};
		
		m._source		= 0;
		m._isLOC		= 0;
		m._hasGS		= 0;
		m._Pointer		= 0;
		m._stationType		= "";
		m._distance		= 0;
		return m;
	},
	setListeners : func(instance) {
		if (me._source != 0){
			me._ptree.Distance 	= props.globals.initNode(me._PATH[me._SOURCE[me._source]].distance,0,"DOUBLE");
			me._ptree.Pointer	= props.globals.initNode(me._PATH[me._SOURCE[me._source]].Pointer,0,"DOUBLE");
			
			append(me._listeners, setlistener(me._PATH[me._SOURCE[me._source]].Frequency,func(n){me._onFrequencyChange(n);},1,0));
			append(me._listeners, setlistener(me._PATH[me._SOURCE[me._source]].isLOC,func(n){me._onIsLocChange(n);},1,0));
			append(me._listeners, setlistener(me._PATH[me._SOURCE[me._source]].hasGS,func(n){me._onHasGSChange(n);},1,0));
			
		}
	},
	init : func(instance=me){
		me.setListeners(instance);
		me._Page.IFD.nLedL3.setValue(1);
		me._Page.keys["L3 >"] = func(){me._scroll(1);};
		me._Page.keys["L3 <"] = func(){me._scroll(-1);};
		me._scroll(0);
	},
	deinit : func(){
		me._Page.IFD.nLedL3.setValue(0);
		me._Page.keys["L3 >"] = nil;
		me._Page.keys["L3 <"] = nil;
		me.removeListeners();	
	},
	setSource : func(src){
		me._source = src;
		me.removeListeners();
		me.setListeners(me);
	},
	_scroll : func(amount){
		me._source += amount;
		if (me._source > 3){ me._source = 0; }
		if (me._source < 0){ me._source = 3; }
		me.setSource(me._source);
		
		me._can.Source.setText(me._NAME[me._source]);
		
		me.update20Hz(0,0);
		me.update2Hz(0,0);
		
		me._can.Off.setVisible (!me._source);
		me._can.On.setVisible (me._source);
		me._can.Pointer.setVisible(me._source);	
		
		
	},
	_onFrequencyChange : func(n){
		me._frequency = n.getValue();
		me._checkStationType();
	},
	_onIsLocChange : func(n){
		me._isLOC = n.getValue();
		me._checkStationType();
	},
	_onHasGSChange : func(n){
		me._hasGS = n.getValue();
		me._checkStationType();
	},
	_checkStationType : func(){
		me._distance	= me._ptree.Distance.getValue();
		me._can.Distance.setText(sprintf("%.1f",me._distance));
		if (me._source == 3){
			me._can.ID.setText(sprintf("%s",me._frequency));
		}else{
			if (me._isLOC == 1){
				if (me._hasGS == 1){
					me._stationType = "ILS";
				}else{
					me._stationType = "LOC";
				}
			}else{
				me._stationType = "VOR";
			}
			me._can.ID.setText(sprintf("%.2f (%s)",me._frequency,me._stationType));
		}
		
	},
	update2Hz : func(now,dt){
		if (me._source > 0){
			me._distance	= me._ptree.Distance.getValue();
			me._can.Distance.setText(sprintf("%.1f",me._distance));
		}
	},
	update20Hz : func(now,dt){
		if (me._source > 0){
			me._Pointer	= me._ptree.Pointer.getValue();
			me._can.Pointer.setRotation((me._Pointer - me._Page._widget.HSI._heading) * global.CONST.DEG2RAD);
			me._can.Brg.setText(sprintf("%i",me._Pointer +0.5));
		}
	},
};

var DeviationIndicatorWidget = {
	new: func(page,canvasGroup,name){
		var m = {parents:[DeviationIndicatorWidget,IfdWidget.new(page,canvasGroup,name)]};
		m._class 	= "DeviationIndicatorWidget";
		m._can		= {
			DI		: m._group.getElementById("DI"),
			DI_Source_Text	: m._group.getElementById("DI_Source_Text"),
			HDI		: m._group.getElementById("HDI"),
			HDI_Needle	: m._group.getElementById("HDI_Needle"),
			VDI		: m._group.getElementById("VDI"),
			VDI_Needle	: m._group.getElementById("VDI_Needle"),
		};
		return m;
	},
	update20Hz : func(now,dt){

		if(me._Page._widget.NavSource._isInRange == 1){
			me._can.HDI_Needle.setVisible(1);
			me._can.DI.setVisible(1);
			#me._can.CDI.setVisible(1);
			me._can.HDI_Needle.setTranslation(me._Page._widget.NavSource._horizontalDeviation * 240,0);
			if (me._Page._widget.NavSource._source == 2){
				me._can.DI_Source_Text.setText("FMS");
				if (me._Page._widget.NavSource._isGSinRange == 1){
					me._can.VDI_Needle.setTranslation(0, me._Page._widget.NavSource._verticalDeviation * 240);
					me._can.VDI.setVisible(1);
					me._can.VDI_Needle.setVisible(1);
					
				}else{
					me._can.VDI.setVisible(0);
					me._can.VDI_Needle.setVisible(0);
				}
			}else{
				if(me._Page._widget.NavSource._isLOC == 1){
					me._can.DI_Source_Text.setText("LOC");
				}else{
					me._can.DI_Source_Text.setText("VOR");
				}
				
				if (me._Page._widget.NavSource._isGSinRange == 1){
					me._can.VDI_Needle.setTranslation(0, me._Page._widget.NavSource._verticalDeviation * 240);
					me._can.DI_Source_Text.setText("ILS");
					me._can.VDI.setVisible(1);
					me._can.VDI_Needle.setVisible(1);
					
				}else{
					me._can.VDI.setVisible(0);
					me._can.VDI_Needle.setVisible(0);
					
				}
			}
			if ((me._Page._widget.NavSource._verticalDeviation <= -0.99) or (me._Page._widget.NavSource._verticalDeviation >= 0.99)){
				me._can.VDI_Needle.set("fill",COLOR["Yellow"]);
			}else{
				me._can.VDI_Needle.set("fill",COLOR["White"]);
			}
			
			if ((me._Page._widget.NavSource._horizontalDeviation <= -0.99) or (me._Page._widget.NavSource._horizontalDeviation >= 0.99)){
				me._Page._widget.HSI._can.CDI.set("fill",COLOR["Yellow"]);
				me._can.HDI_Needle.set("fill",COLOR["Yellow"]);
			}else{
				me._Page._widget.HSI._can.CDI.set("fill",COLOR["Green"]);
				me._can.HDI_Needle.set("fill",COLOR["White"]);	
			}
			
		}else{
			me._can.HDI_Needle.setVisible(0);
			me._can.DI.setVisible(0);
			#me._can.CDI.setVisible(0);
			me._Page._widget.HSI._can.CDI.set("fill",COLOR["Green"]);
		}
			
		
	},
	
};


var HeadingSituationIndicatorWidget = {
	new: func(page,canvasGroup,name){
		var m = {parents:[HeadingSituationIndicatorWidget,IfdWidget.new(page,canvasGroup,name)]};
		m._class 	= "HeadingSituationIndicatorWidget";
		m._ptree	= {
			Heading		: props.globals.initNode("/instrumentation/heading-indicator-IFD-"~m._Page.IFD.name~"/indicated-heading-deg",0.0,"DOUBLE"),
		};
		m._can		= {
			CoursePointer	: m._group.getElementById("CoursePointer").updateCenter(),
			CDI		: m._group.getElementById("CDI").updateCenter(),
			FromFlag	: m._group.getElementById("CDI_FromFlag"),
			ToFlag		: m._group.getElementById("CDI_ToFlag"),
			HeadingBug	: m._group.getElementById("HDG_Bug").updateCenter(),
			HeadingBug_Text	: m._group.getElementById("HDG_Bug_Value").updateCenter(),
			Heading_Text	: m._group.getElementById("HDG_Value").updateCenter(),
			CompassRose	: m._group.getElementById("CompassRose").updateCenter(),
		};
		m._heading		= 0;
		m._headingBug		= 0;
		return m;
	},
	setListeners : func(instance) {
		append(me._listeners, setlistener("/autopilot/settings/heading-bug-deg",func(n){me._onBugChange(n)},1,0));	
	},
	init : func(instance=me){
		me.setListeners(instance);
	},
	_onBugChange : func(n){
		me._headingBug		= n.getValue();
		me._can.HeadingBug.setRotation((me._headingBug - me._heading) * global.CONST.DEG2RAD);
	},
	update20Hz : func(now,dt){
		me._heading = me._ptree.Heading.getValue();
		
		me._can.Heading_Text.setText(sprintf("%03i",math.floor( me._heading + 0.5)));
		me._can.CompassRose.setRotation(-me._heading * global.CONST.DEG2RAD);
		
		me._can.HeadingBug_Text.setText(sprintf("%03i",me._headingBug));
		me._can.HeadingBug.setRotation((me._headingBug - me._heading) * global.CONST.DEG2RAD);
		
		me._can.CoursePointer.setRotation((me._Page._widget.NavSource._Pointer - me._heading) * global.CONST.DEG2RAD);
		me._can.FromFlag.setVisible(me._Page._widget.NavSource._fromFlag);
		me._can.ToFlag.setVisible(me._Page._widget.NavSource._toFlag);
			
		me._can.CDI.setTranslation(me._Page._widget.NavSource._horizontalDeviation * 240,0);
		# CDI visibility/color contolled by DeviationIndicatorWidget
		
		# Bearing Pointer visibility/rotation controlled by BearingSourceWidget
		
		
	},
	
};


var EnvironmentWidget = {
	new: func(page,canvasGroup,name){
		var m = {parents:[EnvironmentWidget,IfdWidget.new(page,canvasGroup,name)]};
		m._class 	= "EnvironmentWidget";
		m._ptree	= {
			OAT		: props.globals.initNode("/environment/temperature-degc",0.0,"DOUBLE"),
			WindDirection	: props.globals.initNode("/environment/wind-from-heading-deg",0.0,"DOUBLE"),
			WindSpeed	: props.globals.initNode("/environment/wind-speed-kt",0.0,"DOUBLE"),
			GroundSpeed	: props.globals.initNode("/velocities/groundspeed-kt",0.0,"DOUBLE"),
		};
		m._can		= {
			WindVector	: m._group.getElementById("WindVector"),
			WindArrow	: m._group.getElementById("WindArrow").updateCenter(),
			OAT		: m._group.getElementById("OAT"),
			GroundSpeed	: m._group.getElementById("GroundSpeed"),
			IceWarning	: m._group.getElementById("ICE_Warning").setVisible(0),	
		};
		m._windSpeed 		= 0;
		m._windDirection 	= 0;
		m._oat			= 0;
		m._groundSpeed		= 0;
		return m;
	},
	update2Hz : func(now,dt){
		me._can.IceWarning.setVisible(getprop("/extra500/system/deice/iceWarning"));
	},
	update20Hz : func(now,dt){
		me._OAT			= me._ptree.OAT.getValue();
		me._windDirection	= me._ptree.WindDirection.getValue();
		me._windSpeed		= me._ptree.WindSpeed.getValue();
		me._groundSpeed		= me._ptree.GroundSpeed.getValue();
				
		if (me._windSpeed > 2){
			me._can.WindVector.setText(sprintf("%03i / %3i",me._windDirection,me._windSpeed));
			me._can.WindArrow.setRotation((180 + me._windDirection - me._Page._widget.HSI._heading) * global.CONST.DEG2RAD);
			me._can.WindArrow.setVisible(1);
		}else{
			me._can.WindVector.setText("Wind Calm");
			me._can.WindArrow.setVisible(0);
		}
		
		me._can.OAT.setText(sprintf("%2i",me._OAT));
		me._can.GroundSpeed.setText(sprintf("%2i",me._groundSpeed));
		
	},
};



var BugSelectWidget = {
	new: func(page,canvasGroup,name){
		var m = {parents:[BugSelectWidget,IfdWidget.new(page,canvasGroup,name)]};
		m._class 	= "BugSelectWidget";
		m._can		= {
			Heading		: m._group.getElementById("Set_Heading"),
			HeadingBorder	: m._group.getElementById("Set_Heading_Border"),
			Altitude	: m._group.getElementById("Set_Altitude"),
			AltitudeBorder	: m._group.getElementById("Set_Altitude_Border"),
			VS		: m._group.getElementById("Set_VS"),
			VSBorder	: m._group.getElementById("Set_VS_Border"),
		};
		m._modeRK = nil;
		return m;
	},
	init : func(instance=me){
		me.registerKeys();
	},
	deinit : func(){
		me._Page.IFD.nLedR3.setValue(0);
		me._Page.keys["R3 <"] 	= nil;
		me._Page.keys["R3 >"] 	= nil;
		me._Page.IFD.nLedR4.setValue(0);
		me._Page.keys["R4 <"] 	= nil;
		me._Page.keys["R4 >"] 	= nil;
		me._Page.IFD.nLedR5.setValue(0);
		me._Page.keys["R5 <"] 	= nil;
		me._Page.keys["R5 >"] 	= nil;
		
		me._Page.IFD.nLedRK.setValue(0);
		me._Page.keys["RK >>"] 	= nil;
		me._Page.keys["RK <<"] 	= nil;
		me._Page.keys["RK"] 	= nil;
		me._Page.keys["RK >"] 	= nil;
		me._Page.keys["RK <"] 	= nil;
		
	},
	registerKeys : func(){
		me._Page.IFD.nLedR3.setValue(1);
		me._Page.keys["R3 <"] = func(){me._setModeRK("HDG");};
		me._Page.keys["R3 >"] = func(){me._setModeRK("HDG");};
		me._Page.IFD.nLedR4.setValue(1);
		me._Page.keys["R4 <"] = func(){me._setModeRK("ALT");};
		me._Page.keys["R4 >"] = func(){me._setModeRK("ALT");};
		me._Page.IFD.nLedR5.setValue(1);
		me._Page.keys["R5 <"] = func(){me._setModeRK("VS");};
		me._Page.keys["R5 >"] = func(){me._setModeRK("VS");};
	},
	_setModeRK : func(value=nil){
		
		me._modeRK = value;
		
		
		me._can.HeadingBorder.set("stroke",COLOR["Blue"]);
		me._can.HeadingBorder.set("stroke-width",10);
		me._can.Heading.set("z-index",1);
		me._can.AltitudeBorder.set("stroke",COLOR["Blue"]);
		me._can.AltitudeBorder.set("stroke-width",10);
		me._can.Altitude.set("z-index",1);
		me._can.VSBorder.set("stroke",COLOR["Blue"]);
		me._can.VSBorder.set("stroke-width",10);
		me._can.VS.set("z-index",1);
			
		
		if (me._modeRK == "HDG"){
			me._can.HeadingBorder.set("stroke",COLOR["Turquoise"]);
			me._can.HeadingBorder.set("stroke-width",20);
			me._can.Heading.set("z-index",2);
		
			me._Page.IFD.nLedRK.setValue(1);
			me._Page.keys["RK >>"] 	= func(){extra500.keypad.onAdjustHeading(10);};
			me._Page.keys["RK <<"] 	= func(){extra500.keypad.onAdjustHeading(-10);};
			me._Page.keys["RK"] 	= func(){extra500.keypad.onHeadingSync();};
			me._Page.keys["RK >"] 	= func(){extra500.keypad.onAdjustHeading(1);};
			me._Page.keys["RK <"] 	= func(){extra500.keypad.onAdjustHeading(-1);};
		}elsif (me._modeRK == "ALT"){
			me._can.AltitudeBorder.set("stroke",COLOR["Turquoise"]);
			me._can.AltitudeBorder.set("stroke-width",20);
			me._can.Altitude.set("z-index",2);
						
			me._Page.IFD.nLedRK.setValue(1);
			me._Page.keys["RK >>"] 	= func(){extra500.keypad.onAdjustAltitude(500);};
			me._Page.keys["RK <<"] 	= func(){extra500.keypad.onAdjustAltitude(-500);};
			me._Page.keys["RK"] 	= func(){extra500.keypad.onHeadingSync();};
			me._Page.keys["RK >"] 	= func(){extra500.keypad.onAdjustAltitude(100);};
			me._Page.keys["RK <"] 	= func(){extra500.keypad.onAdjustAltitude(-100);};
		}elsif (me._modeRK == "VS"){
			me._can.VSBorder.set("stroke",COLOR["Turquoise"]);
			me._can.VSBorder.set("stroke-width",20);
			me._can.VS.set("z-index",2);
			
			me._Page.IFD.nLedRK.setValue(1);
			me._Page.keys["RK >>"] 	= func(){extra500.autopilot.onAdjustVS(-100);};
			me._Page.keys["RK <<"] 	= func(){extra500.autopilot.onAdjustVS(100);};
			me._Page.keys["RK"] 	= func(){extra500.autopilot.onSetVS(0);};
			me._Page.keys["RK >"] 	= func(){extra500.autopilot.onAdjustVS(-100);};
			me._Page.keys["RK <"] 	= func(){extra500.autopilot.onAdjustVS(100);};
		}else{
							
			me._Page.IFD.nLedRK.setValue(0);
			delete(me.keys,"RK >>");
			delete(me.keys,"RK <<");
			delete(me.keys,"RK");
			delete(me.keys,"RK >");
			delete(me.keys,"RK <");
		}
	},
	update2Hz : func(now,dt){
		me._can.Time.setText(me._Page.data.timerGetTime());
	}
};

var TabWidget = {
	new: func(page,canvasGroup,name){
		var m = {parents:[TabWidget,IfdWidget.new(page,canvasGroup,name)]};
		m._class 	= "TabWidget";
		m._tab		= [];
		m._can		= {};
		m._index 	= 0;
		m._max  	= 0;
		return m;
	},
	init : func(instance=me){
		foreach(t;me._tab){
			me._can[t] = {
				content	: me._group.getElementById("Tab_"~t~"_Content"),
				tab	: me._group.getElementById("Tab_"~t~""),
				text	: me._group.getElementById("Tab_"~t~"_Text"),
				back	: me._group.getElementById("Tab_"~t~"_Back"),
			}
		}
		me._max = size(me._tab)-1;
		me.scroll(0);
		
		me._Page.keys["PFD >"] = func(){me.scroll(1);};
		me._Page.keys["PFD <"] = func(){me.scroll(-1);};
		
	},
	deinit : func(){
		me._Page.keys["PFD >"] = nil;
		me._Page.keys["PFD <"] = nil;
	},
	scroll : func(amount){
		me._index += amount;
		if (me._index > me._max){ me._index = 0; }
		if (me._index < 0){ me._index = me._max; }
		
		foreach(t;me._tab){
			me._can[t].content.setVisible(0);
			me._can[t].tab.set("z-index",1);
			me._can[t].back.set("stroke",COLOR["Blue"]);
			me._can[t].back.set("stroke-width",10);
			me._can[t].text.set("fill",COLOR["Blue"]);
		}
		
		me._can[me._tab[me._index]].content.setVisible(1);
		me._can[me._tab[me._index]].tab.set("z-index",2);
		me._can[me._tab[me._index]].back.set("stroke",COLOR["Turquoise"]);
		me._can[me._tab[me._index]].back.set("stroke-width",20);
		me._can[me._tab[me._index]].text.set("fill",COLOR["Turquoise"]);
	
		me._Page._initWidgetsForTab(me._index);
	}
	
};

var AvidynePagePFD = {
	new: func(ifd,name,data){
		var m = { parents: [
			AvidynePagePFD,
			PageClass.new(ifd,name,data)
		] };
		
		# creating the page 
		m.svgFile	= "IFD_PFD_"~m.IFD.width~"x"~m.IFD.height~".svg";
		
		m.nHorizon = m.page.createChild("image","Horizon");
		m.nHorizon.set("file", "Models/instruments/IFDs/Horizon.png");
		m.nHorizon.setSize(m.IFD.width ,m.IFD.height);
		m.nHorizon.setScale(2.0);
		
		m.nHorizonTF = m.nHorizon.createTransform();
		m.nHorizonTF.setTranslation(-m.IFD.width *1/2,-m.IFD.height*3/4 +80);
		
		m.nHorizon.updateCenter();
		
		
# 		m.nOatBorder = m.page.createChild("image")
# 			.set("file", "Models/instruments/IFDs/SliceBorder.png")
# 			.set("slice", "32")
# 			.setSize(254,768)
# 			.setTranslation(32,96);
			
		
	#loading svg
# 		canvas.parsesvg(m.page, "Models/instruments/IFDs/RH-IFD_CanvasTest.svg",{
# 			"font-mapper": global.canvas.FontMapper
# 			}
# 		);
		canvas.parsesvg(m.page, "Models/instruments/IFDs/"~m.svgFile,{
			"font-mapper": global.canvas.FontMapper
			}
		);
# 		canvas.parsesvg(m.page, "Models/instruments/IFDs/IFD_PFD_1024x768.svg",{
# 			"font-mapper": global.canvas.FontMapper
# 			}
# 		);
# 		m.page.setScale(2.0);
		
		m._widget	= {
			Attitude		: AttitudeIndicatorWidget.new(m,m.page,"Altitude"),
			Autopilot		: AutopilotWidget.new(m,m.page,"Autopilot"),
			VerticalSpeed		: VerticalSpeedWidget.new(m,m.page,"Vertical Speed"),
			AirSpeed		: AirspeedSpeedWidget.new(m,m.page,"Airspeed Speed"),
			Altitude		: AltitudeWidget.new(m,m.page,"Altitude"),
			NavSource 		: NavSourceWidget.new(m,m.page,"Nav Source"),
			BearingSource 		: BearingSourceWidget.new(m,m.page,"Bearing Source"),
			DI			: DeviationIndicatorWidget.new(m,m.page,"Deviation Indicator"),
			HSI	 		: HeadingSituationIndicatorWidget.new(m,m.page,"Deviation Indicator"),
			Environment 		: EnvironmentWidget.new(m,m.page,"Environment"),
			Timer	 		: TimerWidget.new(m,m.page,"Timer"),
			BugSelect 		: BugSelectWidget.new(m,m.page,"BugSelect"),
			Tab	 		: TabWidget.new(m,m.page,"BugSelect"),
		};
		
		m._widget.Tab._tab = ["Nav","Bug"];
		
				

		return m;
	},
	init : func(instance=me){
		print("AvidynePagePFD.init() ... ");
				
		me.setListeners(instance);
		
		foreach(widget;keys(me._widget)){
			print("widget : "~widget);
			if(me._widget[widget] != nil){
				
				me._widget[widget].init();
			}
		}
		
		me.registerKeys();
		
		me.page.setVisible(1);
	},
	deinit : func(){
		me.page.setVisible(0);
		me.keys = {};
		me.removeListeners();
		
		foreach(widget;keys(me._widget)){
			if(me._widget[widget] != nil){
				me._widget[widget].deinit();
			}
		}
	},

	_initWidgetsForTab : func(index){
		if (index == 0){ # Page NavDisplay
			
			me._widget.BugSelect.deinit();
			
		}elsif(index == 1){ # Page BugSelect

			me._widget.BugSelect.init();
			
		}else{
			print("_scrollToTab() ... mist");
		}
	},

	update2Hz : func(now,dt){

		me._widget.NavSource.update2Hz(now,dt);
		me._widget.BearingSource.update2Hz(now,dt);
		me._widget.Timer.update2Hz(now,dt);
	
	},
	update20Hz : func(now,dt){
		
		me._widget.AirSpeed.update20Hz(now,dt);
		me._widget.VerticalSpeed.update20Hz(now,dt);
		me._widget.Altitude.update20Hz(now,dt);
		me._widget.Attitude.update20Hz(now,dt);
		me._widget.NavSource.update20Hz(now,dt);
		me._widget.DI.update20Hz(now,dt);
		me._widget.HSI.update20Hz(now,dt);
		me._widget.BearingSource.update20Hz(now,dt);
		me._widget.Environment.update20Hz(now,dt);
		
	},
};
	