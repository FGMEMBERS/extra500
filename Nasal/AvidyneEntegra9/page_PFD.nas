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
#      Last change:      Eric van den Berg
#      Date:             27.05.14
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
			ModeGPSS 	: m._group.getElementById("AP_GPSS").setVisible(0),
			ModeCWS 	: m._group.getElementById("AP_CWS").setVisible(0),
			ModeCAP 	: m._group.getElementById("AP_CAP").setVisible(0),
			ModeSOFT 	: m._group.getElementById("AP_SOFT").setVisible(0),
			ModeTRIM 	: m._group.getElementById("AP_TRIM").setVisible(0),
			ModeALT 	: m._group.getElementById("AP_ALT").setVisible(0),
			ModeVS 		: m._group.getElementById("AP_VS").setVisible(0),
			ModeGS	 	: m._group.getElementById("AP_GS").setVisible(0),
			ModeDSBL 	: m._group.getElementById("AP_DSBL").setVisible(0),
			ModeFD 		: m._group.getElementById("AP_FD").setVisible(0),
			ModeREV		: m._group.getElementById("AP_REV").setVisible(0),
			
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
		append(me._listeners, setlistener("/autopilot/mode/heading",func(n){me._onHDG(n)},1,0));
		append(me._listeners, setlistener("/autopilot/mode/nav",func(n){me._onNAV(n)},1,0));
		append(me._listeners, setlistener("/autopilot/mode/apr",func(n){me._onAPR(n)},1,0));
		append(me._listeners, setlistener("/autopilot/mode/rev",func(n){me._onREV(n)},1,0));
		append(me._listeners, setlistener("/autopilot/mode/gpss",func(n){me._onGPSS(n)},1,0));
		append(me._listeners, setlistener("/autopilot/mode/cws",func(n){me._onCWS(n)},1,0));
		append(me._listeners, setlistener("/autopilot/mode/cws-armed",func(n){me._onCWSarmed(n)},1,0));
		append(me._listeners, setlistener("/autopilot/mode/cap",func(n){me._onCAP(n)},1,0));
		append(me._listeners, setlistener("/autopilot/mode/soft",func(n){me._onSOFT(n)},1,0));
		append(me._listeners, setlistener("/autopilot/mode/trim",func(n){me._onTRIM(n)},1,0));
		append(me._listeners, setlistener("/autopilot/mode/alt",func(n){me._onALT(n)},1,0));
		append(me._listeners, setlistener("/autopilot/mode/vs",func(n){me._onVS(n)},1,0));
		append(me._listeners, setlistener("/autopilot/mode/gs",func(n){me._onGS(n)},1,0));
		append(me._listeners, setlistener("/autopilot/mode/dsbl",func(n){me._onDSBL(n)},1,0));
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
			me._Page._widget.Attitude._can.FDBug.setVisible(0);
		}else{
			if( me._ready == 1 ){
				me._can.State.setText("AP RDY");
				me._can.State.setColor(COLOR["Green"]);
				me._can.State.setVisible(1);
				me._can.ModeFD.setVisible(0);
				me._Page._widget.Attitude._can.FDBug.setVisible(0);
			}else{
				me._can.State.setVisible(0);
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
	_onHDG : func(n){
		me._modeHDG = n.getValue();
		me._can.ModeHDG.setVisible(me._modeHDG);
	},
	_onNAV : func(n){
		me._can.ModeNAV.setVisible(n.getValue());
	},
	_onAPR : func(n){
		me._can.ModeAPR.setVisible(n.getValue());
	},
	_onREV : func(n){
		me._can.ModeREV.setVisible(n.getValue());
	},
	_onGPSS : func(n){
		me._can.ModeGPSS.setVisible(n.getValue());
	},
	_onCWS : func(n){
		me._can.ModeCWS.setVisible(n.getValue());
	},
	_onCWSarmed : func(n){
		var cwsarmed = n.getValue();
		var cws = getprop("/autopilot/mode/cws");
		if (cwsarmed == 1) {
			me._Page._widget.Attitude._can.FDBug.setVisible(0);
			me._can.ModeFD.setVisible(0);
		}
		if ( (cws == 1) and (cwsarmed == 0) ) {
			me._can.ModeFD.setVisible(1);
			me._Page._widget.Attitude._can.FDBug.setVisible(1);
		}
	},
	_onCAP : func(n){
		me._can.ModeCAP.setVisible(n.getValue());
	},
	_onSOFT : func(n){
		me._can.ModeSOFT.setVisible(n.getValue());
	},
	_onTRIM : func(n){
		me._can.ModeTRIM.setVisible(n.getValue());
	},
	_onALT : func(n){
		me._modeALT = n.getValue();
		me._can.ModeALT.setVisible(me._modeALT);
		if(me._modeALT == 1){
			me._Page._widget.Altitude._can.Bug.set("fill",COLOR["Magenta"]);
			me._Page._widget.Attitude._can.FDBug.setVisible(1);
		}else{
			me._Page._widget.Altitude._can.Bug.set("fill","none");
		}
	},
	_onVS : func(n){
		me._modeVS = n.getValue();
		me._can.ModeVS.setVisible(me._modeVS);
		if(me._modeVS == 1){
			me._Page._widget.VerticalSpeed._can.Bug.set("fill",COLOR["Magenta"]);
			if ( getprop("/autopilot/mode/cws-armed") == 0) {
				me._Page._widget.Attitude._can.FDBug.setVisible(1);
			}	
		}else{
			me._Page._widget.VerticalSpeed._can.Bug.set("fill","none");
		}
	},
	_onGS : func(n){
		if(n.getValue() == 1){
			me._can.ModeGS.setVisible(1);
			me._Page._widget.Attitude._can.FDBug.setVisible(1);
		} else {
			me._can.ModeGS.setVisible(0);
		}
	},
	_onDSBL : func(n){
		me._can.ModeDSBL.setVisible(n.getValue());
	},
	_onAP : func(n){
		if(n.getValue()){
			me._can.ModeFD.setText("AP");
			me._Page._widget.Attitude._can.FDBugColor.set("fill",COLOR["Magenta"]);
		}
	},
	_onFP : func(n){
		if(n.getValue()){
			me._can.ModeFD.setText("FD");
			me._Page._widget.Attitude._can.FDBugColor.set("fill",COLOR["Green"]);
		}
	},
	init : func(instance=me){
		#print("AutopilotWidget.init() ... ");
# 		me.setListeners(instance);
	},
	deinit : func(){
		#print("AutopilotWidget.deinit() ... ");
		me.removeListeners();	
	},
	_onVisibiltyChange : func(){
		if(me._visibility == 1){
			me.setListeners(me);
		}else{
			me.removeListeners();
		}
	}
};

var VerticalSpeedWidget = {
	new: func(page,canvasGroup,name){
		var m = {parents:[VerticalSpeedWidget,IfdWidget.new(page,canvasGroup,name)]};
		m._class 	= "VerticalSpeedWidget";
		m._ptree	= {
			vs	: props.globals.initNode("/instrumentation/ivsi-IFD-"~m._ifd.name~"/indicated-speed-fpm",0.0,"DOUBLE"),
		};
		m._can		= {
			Needle		: m._group.getElementById("VS_Needle").updateCenter(),
			Bug		: m._group.getElementById("VS_Bug").updateCenter(),
			BugFMS		: m._group.getElementById("VS_Bug_FMS").updateCenter(),
			BugValue	: m._group.getElementById("VS_Indicated"),
			
		};
		m._ap		= 0;
		m._bug		= 0;
		m._vs		= 0;
		m._vsr		= 0;
		return m;
	},
	setListeners : func(instance) {
		append(me._listeners, setlistener("/autopilot/mode/vs",func(n){me._onApChange(n)},1,0));	
		append(me._listeners, setlistener("/autopilot/settings/vertical-speed-fpm",func(n){me._onBugChange(n)},1,0));	
		append(me._listeners, setlistener(fms._node.vsrRate,func(n){me._onVsrChange(n)},1,0));
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
		me._can.BugValue.setText(sprintf("%4i",global.roundInt(me._bug)));
		me._can.Bug.setRotation(me._rotateScale(me._bug));
		
	},
	_onVsrChange : func(n){
		if(fms._constraint.VSR.rate != 0){
			me._can.BugFMS.setRotation(me._rotateScale(fms._constraint.VSR.rate));
		}
		me._can.BugFMS.setVisible(fms._constraint.VSR.visible);
	},
	_onFplReadyChange : func(n){
		if(fms._fightPlan.isReady){
			
		}else{
			me._can.BugFMS.setVisible(0);
		}
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
# 		me.setListeners(instance);
	},
	deinit : func(){
		me.removeListeners();	
	},
	_onVisibiltyChange : func(){
		if(me._visibility == 1){
			me.setListeners(me);
		}else{
			me.removeListeners();
		}
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
			ias	: props.globals.initNode("/instrumentation/airspeed-IFD-"~m._ifd.name~"/indicated-airspeed-kt",0.0,"DOUBLE"),
			iasRate	: props.globals.initNode("/instrumentation/airspeed-IFD-"~m._ifd.name~"/airspeed-change-ktps",0.0,"DOUBLE"),
			tas	: props.globals.initNode("/instrumentation/airspeed-IFD-"~m._ifd.name~"/true-speed-kt",0.0,"DOUBLE"),
		};
		m._can		= {
			IAS_Ladder	: m._group.getElementById("IAS_Ladder").set("clip","rect(84px, 639px, 688px, 320px)"),
			IAS_001		: m._group.getElementById("IAS_001").set("clip","rect(327px, 639px, 506px, 320px)"),
			IAS_010		: m._group.getElementById("IAS_010").set("clip","rect(385px, 639px, 449px, 320px)"),
			IAS_100		: m._group.getElementById("IAS_100").set("clip","rect(385px, 639px, 449px, 320px)"),
			Plade		: m._group.getElementById("IAS_BlackPlade"),
			Zero		: m._group.getElementById("IAS_Zero").setVisible(1),
			Rate		: m._group.getElementById("IAS_Rate").set("clip","rect(84px, 639px, 688px, 320px)"),
			TAS		: m._group.getElementById("IAS_TAS"),
		};
		m._ias		= 0;
		m._rate		= 0;
		m._tas		= 0;
		m._limitVne	= 207;
		m._limitVso	= 58;
		m._limitZero	= 20;
		m._LADER_PX	= 63.463;
		m._RATE_OFFSET	= m._can.Rate.get("coord[3]");
		
		m._speed	= 0;
		m._speedAdd	= 0;
		
		return m;
	},
	setListeners : func(instance) {
		
	},
	init : func(instance=me){
# 		me.setListeners(instance);
	},
	deinit : func(){
		me.removeListeners();
	},
	_onVisibiltyChange : func(){
		if(me._visibility == 1){
			me.setListeners(me);
		}else{
			me.removeListeners();
		}
	},
	
	update20Hz : func(now,dt){
		me._ias		= me._ptree.ias.getValue();
		me._rate	= me._ptree.iasRate.getValue();;
		me._tas		= me._ptree.tas.getValue();;
		
		
		me._can.IAS_Ladder.setTranslation(0,(me._ias-20)*8.4978);
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
			
			me._can.Rate.set("coord[1]",me._RATE_OFFSET+(-me._rate*58));
		
			me._can.TAS.setText(sprintf("%3i",me._tas));
			
			me._speed = math.mod(me._ias,10);
			
			me._can.IAS_001.setTranslation(0,(me._speed * me._LADER_PX));
			
			if (me._ias > 10){
				if (me._speed >= 9){
					me._speedAdd = me._speed - 9;
				}else{
					me._speedAdd = 0;
				}
				me._speed = math.floor(math.mod(me._ias,100)/10);
				me._can.IAS_010.setTranslation(0,((me._speed+me._speedAdd) * me._LADER_PX));
				me._can.IAS_010.setVisible(1);
				
				if (me._ias > 99){
					
					if (me._speed < 9){
						me._speedAdd = 0;
					}
					
					me._speed = math.floor(math.mod(me._ias,1000)/100);
					me._can.IAS_100.setTranslation(0,((me._speed+me._speedAdd) * me._LADER_PX));
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
				me._ifd._nOverSpeedWarning.setValue(1);
			}else{
				me._ifd._nOverSpeedWarning.setValue(0);
			}
			
		}
	},
	
};

var AltitudeWidget = {
	new: func(page,canvasGroup,name){
		var m = {parents:[AltitudeWidget,IfdWidget.new(page,canvasGroup,name)]};
		m._class 	= "AltitudeWidget";
		m._ptree	= {
			alt	: props.globals.initNode("/instrumentation/altimeter-IFD-"~m._ifd.name~"/indicated-altitude-ft",0.0,"DOUBLE"),
		};
		m._can		= {
			Ladder		: m._group.getElementById("ALT_Ladder").set("clip","rect(145px, 1718px, 688px, 1410px)"),
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
			BarMinus	: m._group.getElementById("AltBarMinus").setVisible(0),
			Bar10		: m._group.getElementById("AltBar10").set("clip","rect(326px, 1718px, 507px, 1478px)"),
			Bar100		: m._group.getElementById("AltBar100").set("clip","rect(385px, 1718px, 449px, 1478px)"),
			Bar1000		: m._group.getElementById("AltBar1000").set("clip","rect(385px, 1718px, 449px, 1478px)"),
			Bar10000	: m._group.getElementById("AltBar10000").set("clip","rect(385px, 1718px, 449px, 1478px)"),
			Bug		: m._group.getElementById("ALT_Bug").set("clip","rect(145px, 1718px, 688px, 1410px)"),
			BugValue	: m._group.getElementById("ALT_Selected"),
			HPA		: m._group.getElementById("hPa"),
		};
		m._alt	 	= 0;
		m._absAlt	= 0;
		m._bugDiff 	= 0;
		m._hpa 		= 0;
		m._tmpAlt 	= 0;
		m._tmpAltAdd 	= 0;
		m._SCALE_BAR_PX_100	= 63.426;
		m._SCALE_BAR_PX_10	= (m._SCALE_BAR_PX_100/20);
		m._SCALE_LAD_PX		= 1.14901;# 114.901 px
		return m;
	},
	setListeners : func(instance) {
		append(me._listeners, setlistener("/autopilot/settings/tgt-altitude-ft",func(n){me._onBugChange(n)},1,0));	
		append(me._listeners, setlistener("/instrumentation/altimeter-IFD-"~me._ifd.name~"/setting-hpa",func(n){me._onHpaChange(n)},1,0));	
	
	},
	init : func(instance=me){
# 		me.setListeners(instance);
	},
	deinit : func(){
		me.removeListeners();	
	},
	_onVisibiltyChange : func(){
		if(me._visibility == 1){
			me.setListeners(me);
		}else{
			me.removeListeners();
		}
	},
	
	_onHpaChange : func(n){
		me._hpa		= n.getValue();
		me._can.HPA.setText(sprintf("%4i",me._hpa));
	},
	_onBugChange : func(n){
		me._bug = n.getValue();
				
		me._can.BugValue.setText(sprintf("%4i",global.roundInt( me._bug )));
		
		me._bugDiff = (me._alt - me._bug) * me._SCALE_LAD_PX;
		me._bugDiff = global.clamp(me._bugDiff,-272,254);
		me._can.Bug.setTranslation(0,me._bugDiff);
	},
	update20Hz : func(now,dt){
		me._alt		= me._ptree.alt.getValue();
		
		me._bugDiff = (me._alt - me._bug) * me._SCALE_LAD_PX;
		me._bugDiff = global.clamp(me._bugDiff,-272,254);
		me._can.Bug.setTranslation(0,me._bugDiff);
		
		me._tmpAlt	= me._alt + 300;
		if(me._tmpAlt>=0){
			me._can.U300T.setText(sprintf("%i",math.floor((me._tmpAlt/1000))));
			me._can.U300H.setText(sprintf("%03i",math.floor(math.mod(me._tmpAlt,1000) / 100) * 100));
		}else{
			me._can.U300T.setText(sprintf("-%i",math.floor(math.abs(me._tmpAlt-100)/1000) ));
			me._can.U300H.setText(sprintf("%03i",math.floor(math.mod(math.abs(me._tmpAlt-100),1000) / 100) * 100));
		
		}
		me._tmpAlt-=100;
		
		if(me._tmpAlt>=0){
			me._can.U200T.setText(sprintf("%i",math.floor((me._tmpAlt/1000))));
			me._can.U200H.setText(sprintf("%03i",math.floor(math.mod(me._tmpAlt,1000) / 100) * 100));
		}else{
			me._can.U200T.setText(sprintf("-%i",math.floor(math.abs(me._tmpAlt-100)/1000) ));
			me._can.U200H.setText(sprintf("%03i",math.floor(math.mod(math.abs(me._tmpAlt-100),1000) / 100) * 100));
			
		}
		me._tmpAlt-=100;
		
		if(me._tmpAlt>=0){
			me._can.U100T.setText(sprintf("%i",math.floor((me._tmpAlt/1000))));
			me._can.U100H.setText(sprintf("%03i",math.floor(math.mod(me._tmpAlt,1000) / 100) * 100));
		}else{
			me._can.U100T.setText(sprintf("-%i",math.floor(math.abs(me._tmpAlt-100)/1000) ));
			me._can.U100H.setText(sprintf("%03i",math.floor(math.mod(math.abs(me._tmpAlt-100),1000) / 100) * 100));
			
		}
		me._tmpAlt-=100;
		
		if(me._tmpAlt>=0){
			me._can.C000T.setText(sprintf("%i",math.floor((me._tmpAlt/1000))));
			me._can.C000H.setText(sprintf("%03i",math.floor(math.mod(me._tmpAlt,1000) / 100) * 100));
		}else{
			me._can.C000T.setText(sprintf("-%i",math.floor(math.abs(me._tmpAlt-100)/1000) ));
			me._can.C000H.setText(sprintf("%03i",math.floor(math.mod(math.abs(me._tmpAlt-100),1000) / 100) * 100));
			
		}
		me._tmpAlt-=100;
		
		if(me._tmpAlt>=0){
			me._can.D100T.setText(sprintf("%i",math.floor((me._tmpAlt/1000))));
			me._can.D100H.setText(sprintf("%03i",math.floor(math.mod(me._tmpAlt,1000) / 100) * 100));
		}else{
			me._can.D100T.setText(sprintf("-%i",math.floor(math.abs(me._tmpAlt-100)/1000) ));
			me._can.D100H.setText(sprintf("%03i",math.floor(math.mod(math.abs(me._tmpAlt-100),1000) / 100) * 100));
			
		}
		me._tmpAlt-=100;
		
		if(me._tmpAlt>=0){
			me._can.D200T.setText(sprintf("%i",math.floor((me._tmpAlt/1000))));
			me._can.D200H.setText(sprintf("%03i",math.floor(math.mod(me._tmpAlt,1000) / 100) * 100));
		}else{
			me._can.D200T.setText(sprintf("-%i",math.floor(math.abs(me._tmpAlt-100)/1000) ));
			me._can.D200H.setText(sprintf("%03i",math.floor(math.mod(math.abs(me._tmpAlt-100),1000) / 100) * 100));
			
		}
		
		me._can.Ladder.setTranslation(0,math.mod(me._alt,100) * me._SCALE_LAD_PX);
		
		
		
		me._tmpAlt = math.mod(me._alt,100);
		me._can.Bar10.setTranslation(0, me._tmpAlt * me._SCALE_BAR_PX_10);
		me._absAlt = math.abs(me._alt);
		
		me._can.BarMinus.setVisible( (me._alt<0) );
		
		if (me._absAlt>=100){
			if (me._tmpAlt > 80) {
				me._tmpAltAdd = me._tmpAlt - 80;
			}else{
				me._tmpAltAdd = 0;
			}
		
			me._tmpAlt = math.floor(math.mod(me._absAlt,1000)/100);
			me._can.Bar100.setTranslation(0,(me._tmpAlt * me._SCALE_BAR_PX_100) + ( me._tmpAltAdd * me._SCALE_BAR_PX_10 ));
			me._can.Bar100.setVisible(1);
			if(me._absAlt>=980){
				if (me._tmpAlt == 9) {
# 					me._tmpAltAdd = me._tmpAlt - 9;
				}else{
					me._tmpAltAdd = 0;
				}
				#print("update20Hz() ... "~me._tmpAlt~" + "~me._tmpAltAdd);
				
				me._tmpAlt = math.floor(math.mod(me._absAlt,10000)/1000);
				me._can.Bar1000.setTranslation(0,me._tmpAlt * me._SCALE_BAR_PX_100 + ( me._tmpAltAdd * me._SCALE_BAR_PX_10 ));
				me._can.Bar1000.setVisible(1);
				if (me._absAlt>=9980){
					if (me._tmpAlt == 9) {
						#me._tmpAltAdd = me._tmpAlt - 9;
					}else{
						me._tmpAltAdd = 0;
					}
					
					me._tmpAlt = math.floor(math.mod(me._absAlt,100000)/10000);
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
			fdroll: props.globals.initNode("/autopilot/flight-director/fld-bank-deg",0.0,"DOUBLE"),
			fdpitch: props.globals.initNode("/autopilot/flight-director/fld-pitch-deg",0.0,"DOUBLE"),
		};
		m._can		= {
			PitchLadder	: m._group.getElementById("PitchLadder").updateCenter().set("clip","rect(144px, 1293px, 671px, 750px)"),
			BankAngle	: m._group.getElementById("BankAngleIndicator").updateCenter(),
			SlipSkid	: m._group.getElementById("SlipSkidIndicator").updateCenter(),
			Horizon		: m._group.getElementById("Horizon"),
			FDBug		: m._group.getElementById("FD_Bug").setVisible(0).updateCenter(),
			FDBugColor	: m._group.getElementById("path5241"),
			
		};
		
		m._pitch	= 0;
		m._roll		= 0;
		m._slipskid	= 0;
		m._fdroll = 0;
		m._fdpitch = 0;
		return m;
	},
	setListeners : func(instance) {
	
		
	},
	init : func(instance=me){
# 		me.setListeners(instance);
	},
	deinit : func(){
		me.removeListeners();
	},
	_onVisibiltyChange : func(){
		if(me._visibility == 1){
			me.setListeners(me);
		}else{
			me.removeListeners();
		}
	},
	
	update20Hz : func(now,dt){
		
		me._pitch	= me._ptree.pitch.getValue();
		me._roll	= me._ptree.roll.getValue();
		me._slipskid	= me._ptree.SlipSkid.getValue();
		me._fdroll	= me._ptree.fdroll.getValue();
		me._fdpitch	= me._ptree.fdpitch.getValue();

		me._can.PitchLadder.setRotation(-me._roll * global.CONST.DEG2RAD);
		me._can.PitchLadder.setTranslation(0,me._pitch * 10);
		me._can.SlipSkid.setTranslation(-me._slipskid * 50,0);
		me._can.BankAngle.setRotation(-me._roll * global.CONST.DEG2RAD);
		
		me._can.Horizon.setTranslation(0,me._pitch * 10);
		me._can.Horizon.setRotation(-me._roll * global.CONST.DEG2RAD);

		me._can.FDBug.setTranslation(0,-me._fdpitch * 10);
		me._can.FDBug.setRotation(me._fdroll * global.CONST.DEG2RAD);
		
	},
	
};


var MarkerWidget = {
	new: func(page,canvasGroup,name){
		var m = {parents:[MarkerWidget,IfdWidget.new(page,canvasGroup,name)]};
		m._class 	= "MarkerWidget";
		m._ptree	= {
			markerInner	: props.globals.initNode("/instrumentation/marker-beacon/inner",0,"BOOL"),
			markerMiddle	: props.globals.initNode("/instrumentation/marker-beacon/middle",0,"BOOL"),
			markerOuter	: props.globals.initNode("/instrumentation/marker-beacon/outer",0,"BOOL"),
			
		};
		m._can		= {
			Marker		: m._group.getElementById("Marker").setVisible(0),
			MarkerBack	: m._group.getElementById("Marker_Back"),
			MarkerText	: m._group.getElementById("Marker_Text"),
		};
		
		m._active	= 0;
		m._seqence	= [];
		m._seqenceIndex	= 0;
		m._seqenceSize = 0;
		m._Time	= 0;
		m._slipskid	= 0;
		m._timer 	= nil;
		
		m._inner	= 0;
		m._middle	= 0;
		m._outer	= 0;
		
		return m;
	},
	setListeners : func(instance) {
		#append(me._listeners, setlistener(me._ptree.markerInner,func(n){me._onMarkerInnerChange(n);},1,0));
		#append(me._listeners, setlistener(me._ptree.markerMiddle,func(n){me._onMarkerMiddleChange(n);},1,0));
		#append(me._listeners, setlistener(me._ptree.markerOuter,func(n){me._onMarkerOuterChange(n);},1,0));
		
	},
	init : func(instance=me){
# 		me.setListeners(instance);
	},
	deinit : func(){
		me.removeListeners();	
	},
	_onVisibiltyChange : func(){
		if(me._visibility == 1){
			me.setListeners(me);
		}else{
			me.removeListeners();
		}
	},
	
	_onMarkerInnerChange : func(n){
		me._inner = n.getValue();
		print("MarkerWidget._onMarkerInnerChange() ... IM " ~ me._inner);
		if (me._inner == 1){
			me._can.MarkerText.setText("IM");
			me._can.MarkerBack.set("fill",COLOR["White"]);
			me._can.Marker.setVisible(1);
		}else{
			me._can.Marker.setVisible(0);
		}
	},
	_onMarkerMiddleChange : func(n){
		me._middle = n.getValue();
		print("MarkerWidget._onMarkerMiddleChange() ... MM " ~ me._middle);
		if (me._middle == 1){
			me._can.MarkerText.setText("MM");
			me._can.MarkerBack.set("fill",COLOR["Yellow"]);
			me._can.Marker.setVisible(1);
		}else{
			me._can.Marker.setVisible(0);
		}
	},
	_onMarkerOuterChange : func(n){
		me._outer = n.getValue();
		print("MarkerWidget._onMarkerOuterChange() ... OM " ~ me._outer);
		if (me._outer == 1){
			me._can.MarkerText.setText("OM");
			me._can.MarkerBack.set("fill",COLOR["Blue"]);
			me._can.Marker.setVisible(1);
		}else{
			me._can.Marker.setVisible(0);
		}

	},
	update20Hz : func(now,dt){
		me._inner	= me._ptree.markerInner.getValue();
		me._middle	= me._ptree.markerMiddle.getValue();
		me._outer	= me._ptree.markerOuter.getValue();
		
		if (me._inner){
			me._can.MarkerText.setText("IM");
			me._can.MarkerBack.set("fill",COLOR["White"]);
			
		}
		if (me._middle){
			me._can.MarkerText.setText("MM");
			me._can.MarkerBack.set("fill",COLOR["Yellow"]);
			
		}
		if (me._outer){
			me._can.MarkerText.setText("OM");
			me._can.MarkerBack.set("fill",COLOR["Blue"]);
			
		}
		me._can.Marker.setVisible(me._inner or me._middle or me._outer);

	}
	
};

var NavSourceWidget = {
	new: func(page,canvasGroup,name){
		var m = {parents:[NavSourceWidget,IfdWidget.new(page,canvasGroup,name)]};
		m._class 	= "NavSourceWidget";
		m._SOURCE 	= ["Nav1","Nav2","FMS"];
		m._NAME 	= ["Nav 1","Nav 2","FMS"];
		m._PATH	=	{
			FMS 	: {
				Pointer			: "/autopilot/fms-channel/indicated-course-deg",
				horizontalDeviation 	: "/autopilot/fms-channel/indicated-course-error-norm",
				verticalDeviation	: "/instrumentation/fms[0]/gs-needle-deflection-norm",
				Frequency		: "/autopilot/route-manager/wp/id",
				isInRange		: "/instrumentation/fms[0]/in-range",
				isLOC			: "/instrumentation/fms[0]/frequencies/is-localizer-frequency",
				isGSinRange		: "/instrumentation/fms[0]/gs-in-range",
				hasGS			: "/instrumentation/fms[0]/has-gs",
				fromFlag		: "/instrumentation/fms[0]/from-flag",
				toFlag			: "/instrumentation/fms[0]/to-flag",
				distance		: "/autopilot/route-manager/wp/dist",
				bearing			: "/autopilot/route-manager/wp/bearing-deg",
				targetCourse		: "/autopilot/fms-channel/indicated-course-deg",
				
				
			},
			Nav1 	: {
				Pointer			: "/instrumentation/nav[0]/radials/selected-deg",
				horizontalDeviation 	: "/instrumentation/nav[0]/heading-needle-deflection-norm",
				verticalDeviation	: "/instrumentation/nav[0]/gs-needle-deflection-norm",
				Frequency		: "/instrumentation/nav[0]/frequencies/selected-mhz-fmt",
				isInRange		: "/instrumentation/nav[0]/in-range",
				isLOC			: "/instrumentation/nav[0]/frequencies/is-localizer-frequency",
				isGSinRange		: "/instrumentation/nav[0]/gs-in-range",
				hasGS			: "/instrumentation/nav[0]/has-gs",
				fromFlag		: "/instrumentation/nav[0]/from-flag",
				toFlag			: "/instrumentation/nav[0]/to-flag",
				distance		: "/autopilot/radionav-channel/nav-distance-nm",
				bearing			: "/instrumentation/nav[0]/radials/reciprocal-radial-deg",
				targetCourse		: "/instrumentation/nav[0]/radials/target-radial-deg",
			},
			Nav2 	: {
				Pointer			: "/instrumentation/nav[1]/radials/selected-deg",
				horizontalDeviation 	: "/instrumentation/nav[1]/heading-needle-deflection-norm",
				verticalDeviation	: "/instrumentation/nav[1]/gs-needle-deflection-norm",
				Frequency		: "/instrumentation/nav[1]/frequencies/selected-mhz-fmt",
				isInRange		: "/instrumentation/nav[1]/in-range",
				isLOC			: "/instrumentation/nav[1]/frequencies/is-localizer-frequency",
				isGSinRange		: "/instrumentation/nav[1]/gs-in-range",
				hasGS			: "/instrumentation/nav[1]/has-gs",
				fromFlag		: "/instrumentation/nav[1]/from-flag",
				toFlag			: "/instrumentation/nav[1]/to-flag",
				distance		: "/autopilot/radionav-channel/nav-distance-nm",
				bearing			: "/instrumentation/nav[1]/radials/reciprocal-radial-deg",
				targetCourse		: "/instrumentation/nav[1]/radials/target-radial-deg",
			},
			
			
		};
		
		
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
			FMSCourse	: props.globals.initNode("/instrumentation/fms[0]/selected-course-deg",0,"DOUBLE"),
			
		};
		
		m._can		= {
			Source 		: m._group.getElementById("NAV_SourceName"),
			ID 		: m._group.getElementById("NAV_ID"),
			Crs 		: m._group.getElementById("NAV_CRS"),
			Distance 	: m._group.getElementById("NAV_Distance"),
		};
		
		m._sourceListeners	= [];
		
		m._routeManagerActive 	= 0;
		m._fmsServiceable	= 0;
		
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
		
		m._btnObsMode 	= 0;
		
		
		return m;
	},
	setListeners : func(instance) {
		
		append(me._listeners, setlistener(me._ptree.Source,func(n){me._onSourceChange(n);},1,0));
		append(me._listeners, setlistener(fms._node.btnObsMode,func(n){me._onObsModeChange(n);},1,0));
		append(me._listeners, setlistener("/autopilot/route-manager/active",func(n){me._onRouteActiveChange(n);},1,0));
		append(me._listeners, setlistener("/autopilot/fms-channel/serviceable",func(n){me._onFmsServiceChange(n);},1,0));
				
	},
	removeListeners : func(){
		foreach(var l;me._listeners){
			removelistener(l);
		}
		me._listeners = [];
		foreach(var l;me._sourceListeners){
			removelistener(l);
		}
		me._sourceListeners = [];
	},
	init : func(instance=me){

	},
	deinit : func(){
		me.removeListeners();

	},
	_onVisibiltyChange : func(){
		if(me._visibility == 1){
			me.setListeners(me);
			
			me._ifd.ui.bindKey("L1",{
				"<"	: func(){me._scroll(-1);},
				">"	: func(){me._scroll(1);},
			});
			
			me._checkKnob();
			
			me._scroll(0);
		}else{
			me.removeListeners();
			
			me._ifd.ui.bindKey("L1");
			me._ifd.ui.bindKnob("LK");
		}
	},
	_checkKnob : func(){
			if(me._source == 2){
				if(me._btnObsMode == 1){
					me._ifd.ui.bindKnob("LK",{
						"<<"	: func(){me._adjustRadial(-10);},
						"<"	: func(){me._adjustRadial(-1);},
						"push"	: func(){me._setObsMode(0);},
						">"	: func(){me._adjustRadial(1);},
						">>"	: func(){me._adjustRadial(10);},
					},{
						"scroll"	: "Course",
						"push"		: "Cancel",
					});
				}else{
					me._ifd.ui.bindKnob("LK",{
						"<<"	: func(){me._setObsMode(1);me._adjustRadial(-10);},
						"<"	: func(){me._setObsMode(1);me._adjustRadial(-1);},
						"push"	: nil,
						">"	: func(){me._setObsMode(1);me._adjustRadial(1);},
						">>"	: func(){me._setObsMode(1);me._adjustRadial(10);},
					},{
						"scroll"	: "Course",
						"push"		: "",
					});
				}
			}else{
				
				if( me._isInRange ){
					me._ifd.ui.bindKnob("LK",{
						"<<"	: func(){me._adjustRadial(-10);},
						"<"	: func(){me._adjustRadial(-1);},
						"push"	: func(){me._onSyncCourse();},
						">"	: func(){me._adjustRadial(1);},
						">>"	: func(){me._adjustRadial(10);},
					},{
						"scroll"	: "Course",
						"push"		: "Sync",
					});
				
				}else{
					me._ifd.ui.bindKnob("LK",{
						"<<"	: func(){me._adjustRadial(-10);},
						"<"	: func(){me._adjustRadial(-1);},
						"push"	: nil,
						">"	: func(){me._adjustRadial(1);},
						">>"	: func(){me._adjustRadial(10);},
					},{
						"scroll"	: "Course",
						"push"		: "",
					});
				}
			}
	},
	_onObsModeChange :func(n){
		me._btnObsMode = n.getValue();
		me.checkSource();
	},
	_onSourceChange : func(n){
		me._source = n.getValue();
		me._setObsMode(me._btnObsMode and (me._source == 2));
		me.checkSource();
	},
	checkSource : func(){
		
		foreach(var l;me._sourceListeners){
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
		append(me._sourceListeners, setlistener(me._PATH[me._SOURCE[me._source]].Frequency,func(n){me._onFrequencyChange(n);},1,0));
				
		if(me._btnObsMode == 1){
			if(getprop("/instrumentation/gps[0]/serviceable")){
				append(me._sourceListeners, setlistener("/instrumentation/gps[0]/desired-course-deg",func(n){me._onCourseChange(n);},1,0));
			}elsif(getprop("/instrumentation/gps[1]/serviceable")){
				append(me._sourceListeners, setlistener("/instrumentation/gps[1]/desired-course-deg",func(n){me._onCourseChange(n);},1,0));
			}else{
				
			}
		}else{
			append(me._sourceListeners, setlistener(me._PATH[me._SOURCE[me._source]].Pointer,func(n){me._onCourseChange(n);},1,0));
		}
		me._Page._widgetTab.NavSelect.registerKeyCDI();
		
		me._checkStationType();
		me._checkKnob();
		
	},
	_scroll : func(amount){
		me._source += amount;
		if (me._source > 2){ me._source = 0; }
		if (me._source < 0){ me._source = 2; }
		if (me._source != 2){ setprop("/autopilot/settings/fly-vector",0); } 		# to switch off vectors when fms is no longer the nav source
		me._ptree.Source.setValue(me._source);	
	},
	_adjustRadial : func(amount){
		#me._Pointer += amount;
		var course = tool.adjustStep(me._Pointer,amount,10);
		course = tool.course(course);
		setprop("/instrumentation/nav[0]/radials/selected-deg",course);
		setprop("/instrumentation/nav[1]/radials/selected-deg",course);
		if(me._btnObsMode == 1){
			
			setprop("/instrumentation/gps[0]/selected-course-deg",course);
			setprop("/instrumentation/gps[1]/selected-course-deg",course);
		}
	},
	_onSyncCourse : func(){
		var course = 0;
		if(me._isLOC == 1){
			# localizer target course
			var magVar = getprop("environment/magnetic-variation-deg");
			course = getprop(me._PATH[me._SOURCE[me._source]].targetCourse) - magVar;
		}else{
			# direct
			course = getprop(me._PATH[me._SOURCE[me._source]].bearing);
		}
		setprop("/instrumentation/nav[0]/radials/selected-deg",course);
		setprop("/instrumentation/nav[1]/radials/selected-deg",course);
	},
	_setObsMode : func(active=0){
		if(me._btnObsMode != active){
			
			setprop("/instrumentation/gps[0]/selected-course-deg",me._Pointer);
			setprop("/instrumentation/gps[1]/selected-course-deg",me._Pointer);
				
			fms._node.btnObsMode.setValue(active);
		}
	},
	_onRouteActiveChange : func(n){
		me._routeManagerActive = n.getValue();
		setprop(me._PATH.FMS.isInRange,( (me._fmsServiceable == 1) and (me._routeManagerActive == 1) ) );
	},
	_onFmsServiceChange : func(n){
		me._fmsServiceable = n.getValue();
		setprop(me._PATH.FMS.isInRange,( (me._fmsServiceable == 1) and (me._routeManagerActive == 1) ) );
	},
	_onInRangeChange : func(n){
		me._isInRange = n.getValue();
		me._checkKnob();
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
		me._can.Source.setText(me._NAME[me._source]);
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
	_onCourseChange : func(n){
		me._Pointer		= n.getValue();
# 		me._ptree.FMSCourse.setValue(me._Pointer);
		me._can.Crs.setText(sprintf("%i",tool.course(me._Pointer)));
		
	},
	update2Hz : func(now,dt){
		
		me._distance	= me._ptree.Distance.getValue();
		me._can.Distance.setText(sprintf("%.1f",me._distance));
		
	},
	
	update20Hz : func(now,dt){
# 		me._Pointer		= me._ptree.Pointer.getValue();
		me._horizontalDeviation	= me._ptree.hDev.getValue();
		me._verticalDeviation	= -me._ptree.vDev.getValue();
		
# 		me._isInRange		= me._ptree.inRange.getValue();
# 		me._isGSinRange		= me._ptree.GSinRange.getValue();
# 		me._isLOC		= me._ptree.LOC.getValue();
# 		me._fromFlag		= me._ptree.FromFlag.getValue();
# 		me._toFlag		= me._ptree.FromFlag.getValue();
				
		
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
				isInRange		: "/instrumentation/fms[0]/in-range",
				Frequency		: "/autopilot/route-manager/wp/id",
				Pointer			: "/autopilot/route-manager/wp/bearing-deg",
				hasGS			: "/instrumentation/fms[0]/has-gs",
				distance		: "/autopilot/route-manager/wp/dist",
			},
			Nav1 	: {
				isLOC			: "/instrumentation/nav[0]/frequencies/is-localizer-frequency",
				isInRange		: "/instrumentation/nav[0]/in-range",
				Frequency		: "/instrumentation/nav[0]/frequencies/selected-mhz-fmt",
				Pointer			: "/instrumentation/nav[0]/radials/reciprocal-radial-deg",
				hasGS			: "/instrumentation/nav[0]/has-gs",
				distance		: "/instrumentation/nav[0]/nav-distance",
			},
			Nav2 	: {
				isLOC			: "/instrumentation/nav[1]/frequencies/is-localizer-frequency",
				isInRange		: "/instrumentation/nav[1]/in-range",
				Frequency		: "/instrumentation/nav[1]/frequencies/selected-mhz-fmt",
				Pointer			: "/instrumentation/nav[1]/radials/reciprocal-radial-deg",
				hasGS			: "/instrumentation/nav[1]/has-gs",
				distance		: "/instrumentation/nav[1]/nav-distance",
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
		m._isInRange		= 0;
		
		return m;
	},
	setListeners : func(instance) {
		if (me._source != 0){
			me._ptree.Distance 	= props.globals.initNode(me._PATH[me._SOURCE[me._source]].distance,0,"DOUBLE");
			me._ptree.Pointer	= props.globals.initNode(me._PATH[me._SOURCE[me._source]].Pointer,0,"DOUBLE");
			
			append(me._listeners, setlistener(me._PATH[me._SOURCE[me._source]].Frequency,func(n){me._onFrequencyChange(n);},1,0));
			append(me._listeners, setlistener(me._PATH[me._SOURCE[me._source]].isLOC,func(n){me._onIsLocChange(n);},1,0));
			append(me._listeners, setlistener(me._PATH[me._SOURCE[me._source]].hasGS,func(n){me._onHasGSChange(n);},1,0));
			append(me._listeners, setlistener(me._PATH[me._SOURCE[me._source]].isInRange,func(n){me._onInRangeChange(n);},1,0));
			
		}
	},
	init : func(instance=me){
# 		me.setListeners(instance);
		
	},
	deinit : func(){
		me.removeListeners();
	},
	_onVisibiltyChange : func(){
		if(me._visibility == 1){
			me.setListeners(me);
			me._ifd.ui.bindKey("L3",{
				"<"	: func(){me._scroll(-1);},
				">"	: func(){me._scroll(1);},
			});
			me._scroll(0);
		}else{
			me.removeListeners();
			me._ifd.ui.bindKey("L3");
		}
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
		me._can.Pointer.setVisible(me._isInRange and me._source!=0);	
		
		
	},
	_onFrequencyChange : func(n){
		me._frequency = n.getValue();
		me._checkStationType();
	},
	_onIsLocChange : func(n){
		me._isLOC = n.getValue();
		me._checkStationType();
	},
	_onInRangeChange : func(n){
		me._isInRange = n.getValue();
		me._can.Pointer.setVisible(me._isInRange);
	},
	_onHasGSChange : func(n){
		me._hasGS = n.getValue();
		me._checkStationType();
	},
	_checkStationType : func(){
		me._distance	= me._ptree.Distance.getValue();
		if (me._source == 3){
			me._can.ID.setText(sprintf("%s",me._frequency));
		}else{
			me._distance *= global.CONST.METER2NM;
		
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
		me._can.Distance.setText(sprintf("%.1f",me._distance));
		
	},
	update2Hz : func(now,dt){
		if (me._source > 0){
			me._distance	= me._ptree.Distance.getValue();
			if (me._source != 3){
				me._distance *= global.CONST.METER2NM;
			}
			me._can.Distance.setText(sprintf("%.1f",me._distance));
		}
	},
	update20Hz : func(now,dt){
		if (me._source > 0){
			me._Pointer	= me._ptree.Pointer.getValue();
			me._can.Pointer.setRotation((me._Pointer - me._Page._widget.HSI._heading) * global.CONST.DEG2RAD);
			me._can.Brg.setText(sprintf("%i",tool.course(me._Pointer)));
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
		m._apModeRev = 0;
		return m;
	},
	setListeners : func(instance) {

		append(me._listeners, setlistener(extra500.autopilot.nModeRev,func(n){me._onApModeRevChange(n);},1,0));
		
	},
	_onVisibiltyChange : func(){
		if(me._visibility == 1){
			me.setListeners(me);
		}else{
			me.removeListeners();
		}
	},
	
	_onApModeRevChange : func(n){
		
		me._apModeRev = n.getValue();
# 		print("DeviationIndicatorWidget._onApModeRevChange("~me._apModeRev~")");
	},
	update20Hz : func(now,dt){

		if(me._Page._widget.NavSource._isInRange == 1){
			me._can.HDI_Needle.setVisible(1);
			me._can.DI.setVisible(1);
			me._Page._widget.HSI._can.CDI.setVisible(1);
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
				
				if (me._Page._widget.NavSource._isGSinRange == 1 and (me._apModeRev == 0) ){
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
			#me._Page._widget.HSI._can.CDI.set("fill",COLOR["Green"]);
			me._Page._widget.HSI._can.CDI.setVisible(0);
		}
			
		
	},
	
};


var HeadingSituationIndicatorWidget = {
	new: func(page,canvasGroup,name){
		var m = {parents:[HeadingSituationIndicatorWidget,IfdWidget.new(page,canvasGroup,name)]};
		m._class 	= "HeadingSituationIndicatorWidget";
		m._ptree	= {
			Heading		: props.globals.initNode("/instrumentation/heading-indicator-IFD-"~m._ifd.name~"/indicated-heading-deg",0.0,"DOUBLE"),
# 			HeadingTrue	: props.globals.initNode("/orientation/heading-deg",0.0,"DOUBLE"),
			TrunRate	: props.globals.initNode("/instrumentation/turn-indicator/indicated-turn-rate",0.0,"DOUBLE"),
# 			FmsHeading	: props.globals.initNode("/autopilot/fms-channel/course-target-deg",0.0,"DOUBLE"),
		};
		m._can		= {
			CoursePointer	: m._group.getElementById("CoursePointer").updateCenter(),
			CDI		: m._group.getElementById("CDI").updateCenter(),
			FromFlag	: m._group.getElementById("CDI_FromFlag"),
			ToFlag		: m._group.getElementById("CDI_ToFlag"),
			HeadingBug_Text	: m._group.getElementById("HDG_Bug_Value").updateCenter(),
			Heading_Text	: m._group.getElementById("HDG_Value").updateCenter(),
			TrunRate	: m._group.getElementById("TrunRate_Needle").updateCenter(),
# 			FMS_Bug		: m._group.getElementById("FMS_BUG").updateCenter().setVisible(0),
# 			HeadingBug	: m._group.getElementById("HDG_Bug").updateCenter().setVisible(0),
# 			HeadingTrue	: m._group.getElementById("HDG_True").updateCenter().setVisible(0),
# 			CompassRose	: m._group.getElementById("CompassRose").updateCenter().setVisible(0),
		};
		
		m._heading		= 0;
		m._headingBug		= 0;
		m._trunRate		= 0;
		m._fmsHeading		= 0;
		
		return m;
	},
	setListeners : func(instance) {
		append(me._listeners, setlistener("/autopilot/settings/heading-bug-deg",func(n){me._onHdgBugChange(n)},1,0));	
	},
	_onHdgBugChange : func(n){
		me._headingBug		= n.getValue();
		me._can.HeadingBug_Text.setText(sprintf("%03i",tool.course(me._headingBug)));
	},
	init : func(instance=me){
# 		me.setListeners(instance);
		#me._movingMap.init();
		
	},
	_onVisibiltyChange : func(){
		if(me._visibility == 1){
			me.setListeners(me);
			me._ifd.movingMap.setLayout("pfd");
		}else{
			me.removeListeners();
		}
	},
	update20Hz : func(now,dt){
		me._heading 		= me._ptree.Heading.getValue();
# 		me._headingTrue 	= me._ptree.HeadingTrue.getValue();
		me._trunRate 		= me._ptree.TrunRate.getValue();
# 		me._fmsHeading 		= me._ptree.FmsHeading.getValue();
		
		
		me._can.Heading_Text.setText(sprintf("%03i",tool.course( me._heading)));
# 		me._can.CompassRose.setRotation(-me._heading * global.CONST.DEG2RAD);
		me._can.TrunRate.setRotation(me._trunRate * 30.0 * global.CONST.DEG2RAD);
		
		
# 		me._can.HeadingBug.setRotation((me._headingBug - me._heading) * global.CONST.DEG2RAD);
# 		me._can.HeadingTrue.setRotation((me._headingTrue - me._heading) * global.CONST.DEG2RAD);
		
		me._can.CoursePointer.setRotation((me._Page._widget.NavSource._Pointer - me._heading) * global.CONST.DEG2RAD);
		me._can.FromFlag.setVisible(me._Page._widget.NavSource._fromFlag);
		me._can.ToFlag.setVisible(me._Page._widget.NavSource._toFlag);
			
		me._can.CDI.setTranslation(me._Page._widget.NavSource._horizontalDeviation * 240,0);
		# CDI visibility/color contolled by DeviationIndicatorWidget
		
# 		if(me._Page._widget.NavSource._source == 2){
# 			me._can.FMS_Bug.setRotation((me._fmsHeading - me._heading) * global.CONST.DEG2RAD);
# 			me._can.FMS_Bug.setVisible(1);
# 		}else{
# 			me._can.FMS_Bug.setVisible(0);
# 		}
		
		
		# Bearing Pointer visibility/rotation controlled by BearingSourceWidget
		
		
	},
	
};


var EnvironmentWidget = {
	new: func(page,canvasGroup,name){
		var m = {parents:[EnvironmentWidget,IfdWidget.new(page,canvasGroup,name)]};
		m._class 	= "EnvironmentWidget";
		m._can		= {
			WindVector	: m._group.getElementById("WindVector"),
			WindArrow	: m._group.getElementById("WindArrow").updateCenter(),
			OAT		: m._group.getElementById("OAT"),
			GroundSpeed	: m._group.getElementById("GroundSpeed"),
			IceWarning	: m._group.getElementById("ICE_Warning").setVisible(0),	
		};
		return m;
	},
	update2Hz : func(now,dt){
		me._can.IceWarning.setVisible(getprop("/extra500/system/deice/iceWarning"));
	},
	update20Hz : func(now,dt){
		var OAT			= getprop("/fdm/jsbsim/aircraft/engine/OAT-degC");
		var windDirection		= getprop("/environment/wind-from-heading-deg");
		var windSpeed		= getprop("/environment/wind-speed-kt");
		var groundSpeed		= getprop("/velocities/groundspeed-kt");
				
		if (windSpeed > 2){
			me._can.WindVector.setText(sprintf("%03i / %3i",windDirection,windSpeed));
			me._can.WindArrow.setRotation((180 + windDirection - me._Page._widget.HSI._heading) * global.CONST.DEG2RAD);
			me._can.WindArrow.setVisible(1);
		}else{
			me._can.WindVector.setText("Wind Calm");
			me._can.WindArrow.setVisible(0);
		}
		
		me._can.OAT.setText(sprintf("%2i",global.roundInt(OAT)));
		me._can.GroundSpeed.setText(sprintf("%2i",groundSpeed));	
	},
};


var FlyVectorsWidget = {
	new: func(page,canvasGroup,name){
		var m = {parents:[FlyVectorsWidget,IfdWidget.new(page,canvasGroup,name)]};
		m._class 	= "FlyVectorsWidget";
		m._can		= {
			FlyVector		: m._group.getElementById("FlyVector"),
			FlyVector_label_up	: m._group.getElementById("FlyVector_label_up"),
			FlyVector_label_down	: m._group.getElementById("FlyVector_label_down"),
			FlyVector_border	: m._group.getElementById("FlyVector_border"),
		};
		m._flyVectors = 0;
		return m;
	},
	init : func(instance=me){
		
	},
	deinit : func(){
		me.removeListeners();
	},
	setListeners : func(instance) {
		append(me._listeners, setlistener(fms._node.FlyVector,func(n){me._onFlyVectorsChange(n);},1,0) );
	},
	_onVisibiltyChange : func(){
		if(me._visibility == 1){
			me.setListeners(me);
			me._ifd.ui.bindKey("L5",{
				"<"	: func(){keypad.onV();},
				">"	: func(){keypad.onV();},
			});
			me._can.FlyVector.setVisible(1);
		}else{
			me.removeListeners();

			me._ifd.ui.bindKey("L5");
			
			#me.registerKeyCDI();
			
						
			
		}
	},
	_onFlyVectorsChange : func(n){
		me._flyVectors = n.getValue();
		if(me._flyVectors){
# 			me._can.FlyVector_label_up.setText("Cancel");
			me._can.FlyVector_label_up.set("fill",COLOR["White"]);
			me._can.FlyVector_label_down.set("fill",COLOR["White"]);
			me._can.FlyVector_border.set("stroke",COLOR["Turquoise"]);
			me._can.FlyVector_border.set("stroke-width",20);
		}else{
# 			me._can.FlyVector_label_up.setText("Fly");
			me._can.FlyVector_label_up.set("fill",COLOR["Turquoise"]);
			me._can.FlyVector_label_down.set("fill",COLOR["Turquoise"]);
			me._can.FlyVector_border.set("stroke",COLOR["Blue"]);
			me._can.FlyVector_border.set("stroke-width",10);
		}
	},
};

var NavSelectWidget = {
	new: func(page,canvasGroup,name){
		var m = {parents:[NavSelectWidget,IfdWidget.new(page,canvasGroup,name)]};
		m._class 	= "NavSelectWidget";
		m._can		= {
			content		: m._group.getElementById("Tab_Nav_Content").setVisible(0),
# 			SynVis		: m._group.getElementById("SynVis_State"),
			FlightPlan	: m._group.getElementById("FlightPlan_State"),
			CDI		: m._group.getElementById("CDI_State"),
			CDI_Button	: m._group.getElementById("PFD_CDI_Button"),
		};
		m._widget	= {
			
		};
		
		m._synVis = 0;
		m._flightPlan = 1;
		m._cdi = 1;
		m._userCDI = 0;
		m._mapView 	= 0;
		return m;
	},
	init : func(instance=me){
		
	},
	deinit : func(){
		me.removeListeners();
	},
	_onVisibiltyChange : func(){
		if(me._visibility == 1){
			me.setListeners(me);
# 			me._ifd.ui.bindKey("R3",{
# 				"<"	: func(){me.setSynVis();},
# 				">"	: func(){me.setSynVis();},
# 			});
			me._ifd.ui.bindKey("R4",{
				"<"	: func(){me.setFlighPlan();},
				">"	: func(){me.setFlighPlan();},
			});
			
			me.registerKeyCDI() ;
		
			me._ifd.movingMap.setLayerVisible("route",me._flightPlan);
			
			
			
# 			me._can.SynVis.setText(LABEL_OFFON[me._synVis]);
			me._can.FlightPlan.setText(LABEL_OFFON[me._flightPlan]);
			me._can.CDI.setText(LABEL_OFFON[me._cdi]);
			
		}else{
			me.removeListeners();
# 			me._ifd.ui.bindKey("R3");
			me._ifd.ui.bindKey("R4");
			
			
			#me.registerKeyCDI();
			
						
			me._ifd.movingMap.setLayerVisible("route",1);
		}
		me._can.content.setVisible(me._visibility);
		
	},
	registerKeyCDI : func(){
		me._can.CDI_Button.setVisible( me._Page._widget.Tab._index == 0 and me._Page._widget.NavSource._source == 2);
		if(me._Page._widget.Tab._index == 0){
			if(me._Page._widget.NavSource._source == 2){
				me.setCDI(me._userCDI);
				me._ifd.ui.bindKey("R5",{
					"<"	: func(){me.setCDI();},
					">"	: func(){me.setCDI();},
				});
			
							
			}else{
				me._ifd.ui.bindKey("R5");
				me.setCDI(1);
			}
		}else{
			if(me._Page._widget.NavSource._source == 2){
				me.setCDI(me._userCDI);
			}else{
				me.setCDI(1);
			}
		}
	},
	setSynVis : func(value=nil){
		if (value == nil){
			me._synVis = !me._synVis;
		}else{
			me._synVis = value;
		}
		me._can.SynVis.setText(LABEL_OFFON[me._synVis]);
		
	},
	setFlighPlan : func(value=nil){
		if (value == nil){
			me._flightPlan = !me._flightPlan;
		}else{
			me._flightPlan = value;
		}
		me._can.FlightPlan.setText(LABEL_OFFON[me._flightPlan]);
		me._ifd.movingMap.setLayerVisible("route",me._flightPlan);
		
	},
	setCDI : func(value=nil){
		if (value == nil){
			me._cdi = !me._cdi;
		}else{
			me._cdi = value;
		}
		if(me._Page._widget.NavSource._source == 2){
			me._userCDI = me._cdi;
		}
		
		me._can.CDI.setText(LABEL_OFFON[me._cdi]);
		me._Page._widget.HSI._can.CoursePointer.setVisible(me._cdi);
	},
};

var BugSelectWidget = {
	new: func(page,canvasGroup,name){
		var m = {parents:[BugSelectWidget,IfdWidget.new(page,canvasGroup,name)]};
		m._class 	= "BugSelectWidget";
		m._can		= {
			content		: m._group.getElementById("Tab_Bug_Content").setVisible(0),
			Heading		: m._group.getElementById("Set_Heading"),
			HeadingBorder	: m._group.getElementById("Set_Heading_Border"),
			Altitude	: m._group.getElementById("Set_Altitude"),
			AltitudeBorder	: m._group.getElementById("Set_Altitude_Border"),
			VS		: m._group.getElementById("Set_VS"),
			VSBorder	: m._group.getElementById("Set_VS_Border"),
		};
		m._modeRK = "HDG";
		m._ResetTimer = maketimer(10.0,m,BugSelectWidget._resetMode);
		m._ResetTimer.singleShot = 1;
		return m;
	},
	init : func(instance=me){
		
	},
	deinit : func(){
		me.removeListeners();
	},
	_resetMode : func(){
# 		print("BugSelectWidget._resetMode() ... ");
		me._setModeRK("HDG");
	},
	registerKeys : func(){

		me._ifd.ui.bindKey("R3",{
			"<"	: func(){me._setModeRK("HDG");},
			">"	: func(){me._setModeRK("HDG");},
		});
		me._ifd.ui.bindKey("R4",{
			"<"	: func(){me._setModeRK("ALT");},
			">"	: func(){me._setModeRK("ALT");},
		});
		me._ifd.ui.bindKey("R5",{
			"<"	: func(){me._setModeRK("VS");},
			">"	: func(){me._setModeRK("VS");},
		});
			
		
	},
	_onVisibiltyChange : func(){
		if(me._visibility == 1){
			me.setListeners(me);
			me.registerKeys();
			#me._setModeRK(me._modeRK);
			me._setModeRK("HDG");
			
		}else{
			me.removeListeners();

			me._ifd.ui.bindKey("R3");
			me._ifd.ui.bindKey("R4");
			me._ifd.ui.bindKey("R5");
			
			me._ifd.ui.bindKnob("RK");
			
			me._ResetTimer.stop();
		}
		me._can.content.setVisible(me._visibility);
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
		
			me._ifd.ui.bindKnob("RK",{
				"<<"	: func(){keypad.onAdjustHeading(-10);},
				"<"	: func(){keypad.onAdjustHeading(-1);},
				"push"	: func(){keypad.onHeadingSync();},
				">"	: func(){keypad.onAdjustHeading(1);},
				">>"	: func(){keypad.onAdjustHeading(10);},
			},{
				"scroll"	: "Heading",
				"push"		: "Sync",
			});
			
			
		}elsif (me._modeRK == "ALT"){
			me._can.AltitudeBorder.set("stroke",COLOR["Turquoise"]);
			me._can.AltitudeBorder.set("stroke-width",20);
			me._can.Altitude.set("z-index",2);
						
			me._ifd.ui.bindKnob("RK",{
				"<<"	: func(){keypad.onAdjustAltitude(-500);me._ResetTimer.restart(10);},
				"<"	: func(){keypad.onAdjustAltitude(-100);me._ResetTimer.restart(10);},
				"push"	: func(){keypad.onAltitudeSync();me._ResetTimer.restart(10);},
				">"	: func(){keypad.onAdjustAltitude(100);me._ResetTimer.restart(10);},
				">>"	: func(){keypad.onAdjustAltitude(500);me._ResetTimer.restart(10);},
			},{
				"scroll"	: "Altitude",
				"push"		: "Sync",
			});
			me._ResetTimer.restart(10);
		}elsif (me._modeRK == "VS"){
			me._can.VSBorder.set("stroke",COLOR["Turquoise"]);
			me._can.VSBorder.set("stroke-width",20);
			me._can.VS.set("z-index",2);
			
			me._ifd.ui.bindKnob("RK",{
				"<<"	: func(){extra500.autopilot.onAdjustVS(-500);me._ResetTimer.restart(10);},
				"<"	: func(){extra500.autopilot.onAdjustVS(-100);me._ResetTimer.restart(10);},
				"push"	: func(){extra500.autopilot.onSetVS(0);me._ResetTimer.restart(10);},
				">"	: func(){extra500.autopilot.onAdjustVS(100);me._ResetTimer.restart(10);},
				">>"	: func(){extra500.autopilot.onAdjustVS(500);me._ResetTimer.restart(10);},
			},{
				"scroll"	: "VS",
				"push"		: "Sync",
			});
			me._ResetTimer.restart(10);
		}else{
							
			me._ifd.ui.bindKnob("RK");
		}
		
		
		
	}
};

var TimerWidget = {
	new: func(page,canvasGroup,name){
		var m = {parents:[TimerWidget,IfdWidget.new(page,canvasGroup,name)]};
		m._class 	= "TimerWidget";
		m._ptree	= {
			OAT		: props.globals.initNode("/environment/temperature-degc",0.0,"DOUBLE"),
			WindDirection	: props.globals.initNode("/environment/wind-from-heading-deg",0.0,"DOUBLE"),
			WindSpeed	: props.globals.initNode("/environment/wind-speed-kt",0.0,"DOUBLE"),
			GroundSpeed	: props.globals.initNode("/velocities/groundspeed-kt",0.0,"DOUBLE"),
		};
		m._can		= {
			On		: m._group.getElementById("Timer_On"),
			Center		: m._group.getElementById("Timer_btn_Center").updateCenter(),
			Left		: m._group.getElementById("Timer_btn_Left"),
			Time		: m._group.getElementById("Timer_Time"),
			
		};
		m._windSpeed 		= 0;
		m._windDirection 	= 0;
		m._oat			= 0;
		m._groundSpeed		= 0;
		return m;
	},
	init : func(instance=me){
		
	},
	deinit : func(){
		me.removeListeners();
	},
	_onVisibiltyChange : func(){
		if(me._visibility == 1){
			me.setListeners(me);
			me.registerKeys();
		}else{
			me.removeListeners();
			me._ifd.ui.bindKey("R2");
		}
	},
	registerKeys : func(){
		if ((me._Page.data.timerState == 0)){

			me._ifd.ui.bindKey("R2",{
				"<"	: func(){me._Page.data.timerStart();me.registerKeys();},
				">"	: func(){me._Page.data.timerStart();me.registerKeys();},
			});
						
			me._can.On.setVisible(0);
			me._can.Center.setVisible(1);
			
		}elsif ((me._Page.data.timerState == 1)){

			me._ifd.ui.bindKey("R2",{
				"<"	: func(){me._Page.data.timerStart();me.registerKeys();},
				">"	: func(){me._Page.data.timerReset();me.registerKeys();},
			});
						
			
			me._can.Left.setText("Start");
			me._can.On.setVisible(1);
			me._can.Center.setVisible(0);
		}elsif ((me._Page.data.timerState == 2)){

			me._ifd.ui.bindKey("R2",{
				"<"	: func(){me._Page.data.timerStop();me.registerKeys();},
				">"	: func(){me._Page.data.timerReset();me.registerKeys();},
			});
			
			
			me._can.Left.setText("Stop");
			me._can.On.setVisible(1);
			me._can.Center.setVisible(0);
		}
		me._can.Time.setText(me._Page.data.timerGetTime());
	},
	update2Hz : func(now,dt){
		me._can.Time.setText(me._Page.data.timerGetTime());
	}
};

var ActiveComWidget = {
	new : func(page,canvasGroup,name){
		var m = {parents:[ActiveComWidget,IfdWidget.new(page,canvasGroup,name)]};
		m._class 	= "ActiveComWidget";
		m._tab		= [];
		m._can		= {};
		m._activeChannelListener = nil;
		return m;
	},
	setListeners : func(instance) {
		#append(me._listeners, setlistener("/extra500/instrumentation/Keypad/tuningSource",func(n){me._onComSelectedChange(n)},1,0));	
		append(me._listeners, setlistener("/instrumentation/comm-selected-index",func(n){me._onComSelectedChange(n)},1,0));	
	},
	init : func(instance=me){
		#print("ActiveComWidget.init() ... ");
		me._can = {
			freqency	: me._group.getElementById("Com_active_Channel_Freqency"),
			info		: me._group.getElementById("Com_active_Channel_Info").setText("active"),
			airport		: me._group.getElementById("Com_active_Channel_Airport").setText(""),
		};
	},
	_onVisibiltyChange : func(){
		if(me._visibility == 1){
			me.setListeners(me);
		}else{
			me.removeListeners();
		}
	},
	_setActiveListener : func(index=nil){
		if(index == nil){
			if(me._activeChannelListener != nil){
				removelistener(me._activeChannelListener);
				me._activeChannelListener = nil;
			}
		}else{
			if(me._activeChannelListener != nil){
				removelistener(me._activeChannelListener);
				me._activeChannelListener = nil;
			}
			me._activeChannelListener = setlistener("/instrumentation/comm["~index~"]/frequencies/selected-mhz",func(n){me._onFreqencyChange(n)},1,0);
		}
	},
	_onComSelectedChange : func(n){
		var index = n.getValue();
		me._setActiveListener(index);
		if(index==0){
			me._can.airport.setText("Com 1");
		}else{
			me._can.airport.setText("Com 2");
		}
	},
	_onFreqencyChange : func(n){
		var freqency = n.getValue();
		me._can.freqency.setText(sprintf("%.3f",freqency));
	},
};

var AvidynePagePFD = {
	new: func(ifd,name,data){
		var m = { parents: [
			AvidynePagePFD,
			PageClass.new(ifd,name,data)
		] };
		
		# creating the page 
		m.svgFile	= "IFD_PFD.svg";
		
		m.nHorizon = m.page.createChild("image","Horizon");
		m.nHorizon.set("file", "Models/instruments/IFDs/Horizon.png");
		m.nHorizon.setSize(m.IFD.width ,m.IFD.height);
		m.nHorizon.setScale(2.0);
		
		m.nHorizonTF = m.nHorizon.createTransform();
		m.nHorizonTF.setTranslation(-m.IFD.width *1/2,-m.IFD.height*3/4 +80);
		
		m.nHorizon.updateCenter();
		m.nHorizon.set("clip","rect(0px, 2048px,768px, 0px)");
		
		
# 		m.nOatBorder = m.page.createChild("image")
# 			.set("file", "Models/instruments/IFDs/SliceBorder.png")
# 			.set("slice", "32")
# 			.setSize(254,768)
# 			.setTranslation(32,96);
			
		

		canvas.parsesvg(m.page, "Models/instruments/IFDs/"~m.svgFile,{
			"font-mapper": global.canvas.FontMapper
			}
		);

		
		m._widget	= {
			Attitude		: AttitudeIndicatorWidget.new(m,m.page,"Altitude"),
			Autopilot		: AutopilotWidget.new(m,m.page,"Autopilot"),
			VerticalSpeed		: VerticalSpeedWidget.new(m,m.page,"Vertical Speed"),
			AirSpeed		: AirspeedSpeedWidget.new(m,m.page,"Airspeed Speed"),
			Altitude		: AltitudeWidget.new(m,m.page,"Altitude"),
			DI			: DeviationIndicatorWidget.new(m,m.page,"Deviation Indicator"),
			Environment 		: EnvironmentWidget.new(m,m.page,"Environment"),NavSource 		: NavSourceWidget.new(m,m.page,"Nav Source"),
			BearingSource 		: BearingSourceWidget.new(m,m.page,"Bearing Source"),
			HSI	 		: HeadingSituationIndicatorWidget.new(m,m.page,"Heading Situation Indicator"),
			Timer	 		: TimerWidget.new(m,m.page,"Timer"),
			Tab	 		: TabWidget.new(m,m.page,"TabSelectPFD"),
			Marker	 		: MarkerWidget.new(m,m.page,"Marker"),
			ActiveCom	 	: ActiveComWidget.new(m,m.page,"ActiveCom"),
			FlyVectors	 	: FlyVectorsWidget.new(m,m.page,"FlyVectors"),
			
			
			
			
		};
		m._widgetTab = {
			BugSelect 		: BugSelectWidget.new(m,m.page,"BugSelect"),
			NavSelect 		: NavSelectWidget.new(m,m.page,"NavSelectWidget"),
			MapKnob			: MovingMapKnobWidget.new(m,m.page,"MovingMapKnob")
		};
		
		m._widget.Tab._tab = ["Nav","Bug"];
		
				

		return m;
	},
	init : func(instance=me){
		#print("AvidynePagePFD.init() ... ");
		foreach(var widget;keys(me._widget)){
			#print("widget : "~widget);
			if(me._widget[widget] != nil){
				
				me._widget[widget].init();
			}
		}
	},
	deinit : func(){
		foreach(var widget;keys(me._widget)){
			if(me._widget[widget] != nil){
				me._widget[widget].setVisible(0);
				me._widget[widget].deinit();
			}
		}
	},
	_onVisibiltyChange : func(){
		me.IFD.setLayout(IFD_LAYOUT.PFD);
		if(me._visibility == 1){
			me.setListeners(me);
# 			me.IFD._widget.Headline.setVisible(0);
# 			me.IFD._widget.PlusData.setVisible(0);
			#me.IFD.movingMap.setLayout("pfd");
			#me._widget.Tab.initActiveTab();
			me.registerKeys();
			
		}else{
			me.IFD.movingMap.setVisible(0);
			me.keys = {};
			me.removeListeners();
			
			foreach(var widget;keys(me._widgetTab)){
				if(me._widgetTab[widget] != nil){
					me._widgetTab[widget].setVisible(me._visibility);
				}
			}
			
		}
			
		foreach(var widget;keys(me._widget)){
			if(me._widget[widget] != nil){
				me._widget[widget].setVisible(me._visibility);
			}
		}
		
		
		me.page.setVisible(me._visibility);
	},
	_initWidgetsForTab : func(index){
			
		if (index == 0){ # Tab NavDisplay
			
			me._widgetTab.BugSelect.setVisible(0);
			me._widgetTab.NavSelect.setVisible(1);
			me._widgetTab.MapKnob.setHand(1);
			me._widgetTab.MapKnob.setVisible(1);
			
		}elsif(index == 1){ # Tab BugSelect
			me._widgetTab.MapKnob.setVisible(0);
			me._widgetTab.NavSelect.setVisible(0);
			me._widgetTab.BugSelect.setVisible(1);
			
			
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
		me._widget.Marker.update20Hz(now,dt);
	
	},
};
	
