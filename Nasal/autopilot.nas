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
#      Date: Jun 26 2013
#
#      Last change:      Dirk Dittmann
#      Date:             01.09.2013
#
var FlightManagementSystemClass = {
	new : func(root,name){
		var m = {parents:[
			FlightManagementSystemClass,
			ServiceClass.new(root,name)
		]};
		m._currentWaypointIndex = 0;
		m._selectedWaypointIndex = 0;
		
		return m;
	},
	setListeners : func(instance) {
		append(me._listeners, setlistener("/autopilot/route-manager/current-wp",func(n){me._onCurrentWaypointChange(n);},1,0) );
	},
	init : func(instance=nil){
		if (instance==nil){instance=me;}
		me.setListeners(instance);
	
	},
#IFD & route Manager selection, called from IFD page_FMS.nas
	setSelectedWaypoint : func(index){
		me._selectedWaypointIndex = index;
	},
	_onCurrentWaypointChange : func(n){
		me._currentWaypointIndex = n.getValue();
		if ( me._currentWaypointIndex >= 0 ) {
#			settimer(func(){me._nextGpssBearing()},1);
		me._nextGpssBearing();
		}
	},
	_nextGpssBearing : func(){
		setprop("/autopilot/fms-channel/gpss/next-bearing-deg",getprop("/autopilot/route-manager/route/wp["~me._currentWaypointIndex~"]/leg-bearing-true-deg"));
	},
# Operation functions of Avidyne FMS 
	jumpTo : func(){
		setprop("/autopilot/route-manager/current-wp",me._selectedWaypointIndex);
	},
	directTo : func(){# called from keypad.nas
		if ( getprop("/autopilot/settings/dto-leg") == 0) {
			setprop("/autopilot/route-manager/current-wp",me._selectedWaypointIndex);
			setprop("/autopilot/settings/dto-leg",1);
		} else {
				setprop("/autopilot/settings/dto-leg",0);
		}
	
	},
	

};

var AutopilotClass = {
	new : func(root,name){
		var m = {parents:[
			AutopilotClass,
			ConsumerClass.new(root,name,60.0)
		]};
		
		
		m.dimmingVolt = 0.0;
		m._gpsMode	= "";
		
		m.ndisengSound  = props.globals.initNode("/autopilot/mode/disengsound",0,"INT");
		m.nModeDiseng	= props.globals.initNode("/autopilot/mode/diseng",0,"INT");
		m.nModeHeading 	= props.globals.initNode("/autopilot/mode/heading",0,"INT");
		m.nModeNav 	= props.globals.initNode("/autopilot/mode/nav",0,"INT");
		m.nModeNavGpss 	= props.globals.initNode("/autopilot/mode/gpss",0,"INT");
		m.nModeAlt 	= props.globals.initNode("/autopilot/mode/alt",0,"INT");
		m.nModeVs 	= props.globals.initNode("/autopilot/mode/vs",0,"INT");
		m.nModeGs 	= props.globals.initNode("/autopilot/mode/gs",0,"INT");
		m.nModeRev 	= props.globals.initNode("/autopilot/mode/rev",0,"INT");
		m.nModeApr 	= props.globals.initNode("/autopilot/mode/apr",0,"INT");
		m.nModeRdy 	= props.globals.initNode("/autopilot/mode/rdy",0,"INT");
		m.nModeCws 	= props.globals.initNode("/autopilot/mode/cws",0,"INT");
		m.nModeFail 	= props.globals.initNode("/autopilot/mode/fail",0,"INT");
		m.nModeTrim 	= props.globals.initNode("/autopilot/mode/trim",0,"INT");
		m.nModeGSDisable = props.globals.initNode("/autopilot/mode/gs-disable",0,"INT");
		m.nModeGSArmed 	= props.globals.initNode("/autopilot/mode/gs-armed",0,"INT");
		m.nModeGSFollow = props.globals.initNode("/autopilot/mode/gs-follow",0,"INT");
		
		
		m.nSetAP 		= props.globals.initNode("/autopilot/settings/ap",0,"BOOL");			# Master Panel AP
		m.nSetFD 		= props.globals.initNode("/autopilot/settings/fd",0,"BOOL");			# Master Panel FD
		m.nSetTrim 		= props.globals.initNode("/autopilot/settings/trim",0,"BOOL");			# Master Panel Pitch Trim
		m.nSetYawDamper 	= props.globals.initNode("/autopilot/settings/yawdamper",0,"INT");		# Master Panel Yaw Damper
		m.nSetYawTrim 		= props.globals.initNode("/autopilot/settings/yawTrim",0,"DOUBLE");		# Master Panel Yaw Trim
		m.nSetPitchTrimUp 	= props.globals.initNode("/autopilot/settings/pitchTrim-up",0,"BOOL");		# Yoke Pitch Trim up 
		m.nSetPitchTrimDown 	= props.globals.initNode("/autopilot/settings/pitchTrim-down",0,"BOOL");	# Yoke Pitch Trim down
		m.nSetCws 		= props.globals.initNode("/autopilot/settings/cws",0,"BOOL");			# Yoke CWS
		m.nSetHeadingBugDeg 	= props.globals.initNode("/autopilot/settings/heading-bug-deg",0,"DOUBLE");	# Keypad 
		m.nSetAltitudeBugFt 	= props.globals.initNode("/autopilot/settings/tgt-altitude-ft",0,"DOUBLE");	# Keypad
		m.nSetTargetAltitudeFt 	= props.globals.initNode("/autopilot/alt-channel/target-alt-ft",0,"DOUBLE");
		m.nSetVerticalSpeedFpm 	= props.globals.initNode("/autopilot/settings/vertical-speed-fpm",0,"DOUBLE");  # Autopilot Panel
		m.nIsLocalizer		= props.globals.initNode("/autopilot/radionav-channel/is-localizer-frequency",0,"BOOL");
		m.nInRange		= props.globals.initNode("/autopilot/radionav-channel/in-range",0,"DOUBLE");	
		
		m.nAPState 	= props.globals.getNode("/extra500/instrumentation/Autopilot/state");		
		m.nTCSpin 	= props.globals.getNode("/instrumentation/turn-indicator/spin");			
		m.nAPacc 	= props.globals.getNode("/autopilot/accsens-channel/ap-z-accel");
		m.nCurrentAlt 	= props.globals.getNode("/instrumentation/altimeter-IFD-LH/indicated-altitude-ft");	
		m.nAlterror 	= props.globals.getNode("/autopilot/alt-channel/alt-error-ft");	
		m.nNavsource	= props.globals.getNode("/instrumentation/nav-source");	
		m.nFMSserv 	= props.globals.getNode("/autopilot/fms-channel/serviceable");
		m.nRouteActive 	= props.globals.getNode("/autopilot/route-manager/active");																																																												

		m._nBrightness		= props.globals.initNode("/extra500/system/dimming/Instrument",0.0,"DOUBLE");
		m._brightness		= 0;
		m._brightnessListener   = nil;
		m._nBacklight 		= m._nRoot.initNode("Backlight/state",0.0,"DOUBLE");
		m.nStallWarnerOn 	= props.globals.getNode("/extra500/panel/Annunciator/StallWarn/state");																																																												
		
		
		m.dt = 0;
		m.now = systime();
		m._lastTime = 0;
		m.timerLoop = nil;
		
		return m;
	},
	setListeners : func(instance) {
		append(me._listeners, setlistener(me._nBrightness,func(n){instance._onBrightnessChange(n);},1,0) );
		append(me._listeners, setlistener("/instrumentation/gps/active-mode",func(n){instance._onGPSModeChange(n);},1,0) );
	},
	init : func(instance=nil){
		if (instance==nil){instance=me;}
		me.parents[1].init(instance);
		me.setListeners(instance);
		
		me.initUI();
		
		#print("AutopilotClass.init() ... ");
		eSystem.switch.AutopilotMaster.onStateChange = func(n){
			me._state = n.getValue();
			#print(me._name~" onStateChange("~me._state~") ...");
			if (me._state == 1){
				autopilot.nSetAP.setValue(1);
				autopilot.nSetFD.setValue(0);
			}elsif(me._state == 0){
				autopilot.nSetAP.setValue(0);
				autopilot.nSetFD.setValue(1);
			}else{
				#Power off
				autopilot.nSetAP.setValue(0);
				autopilot.nSetFD.setValue(0);
			}
			autopilot.electricWork();
			autopilot.update();
		};
		eSystem.switch.AutopilotPitchTrim.onStateChange = func(n){
			me._state = n.getValue();
			autopilot.nSetTrim.setValue(me._state);	
			autopilot.update();
		};
		eSystem.switch.AutopilotYawDamper.onStateChange = func(n){
			me._state = n.getValue();
			autopilot.nSetYawDamper.setValue(me._state);
			autopilot.update();
		};
		eSystem.switch.AutopilotYawTrim.onStateChange = func(n){
			me._state = n.getValue();
			autopilot.nSetYawTrim.setValue(me._state);
			autopilot.update();
		};
		
		
		eSystem.circuitBreaker.AP_CMPTR.outputAdd(me);
		
		
		me._timerLoop = maketimer(1.0,me,AutopilotClass.update);
		me._timerLoop.start();
	},
	_onBrightnessChange : func(n){
		me._brightness = n.getValue();
		me.electricWork();
	},
	_onGPSModeChange : func(n){
		me._gpsMode = n.getValue();
#		print("AutopilotClass._onGPSModeChange() ... GPS mode change to "~me._gpsMode);
		if(me._gpsMode == "leg"){
			if(me.nModeNavGpss.getValue()){
				
			}else{
				
			}
		}elsif(me._gpsMode == "dto"){
			
		}elsif(me._gpsMode == "obs"){
			
		}
	},
	electricWork : func(){
		if (eSystem.switch.AutopilotMaster._state >= 0 and me._volt > me._voltMin){
			me._watt = me._nWatt.getValue();
			me._ampere = me._watt / me._volt;
			me._ampere += (0.3 * me._brightness) / me._volt;
			me.nAPState.setValue(1);
		}else{
			me._ampere = 0;
			me.nAPState.setValue(0);
		}
		me._nBacklight.setValue(me._brightness * me._qos * me._voltNorm);
		me._nAmpere.setValue(me._ampere);
	},
	update : func(){
		me._CheckRollModeAble();
		
	},
# disengages the autopilot
	_APDisengage : func(){
		if ( me._CheckRollModeActive() == 1)  {
			me.ndisengSound.setValue(1);
		}
		me.nModeHeading.setValue(0);
		me.nModeNav.setValue(0);
		me.nModeNavGpss.setValue(0);
		me.nModeApr.setValue(0);
		me.nModeRev.setValue(0);
		me.nModeAlt.setValue(0);
		me.nModeVs.setValue(0);
		me.nModeDiseng.setValue(1);
		me.nModeGSArmed.setValue(0);
		me.nModeGSFollow.setValue(0);
	},
# checks is a roll mode (HDG or NAV) is active. Must be active to engage any pitch mode or yaw damper
	_CheckRollModeActive : func(){
		if ( (me.nModeHeading.getValue() == 1) or (me.nModeNav.getValue() == 1) ){
			return 1
		}else{
			return 0
		}
	},
# checks if the AP is able to engage, called from update loop!: 
# 1 no internal fault, 
# 2 turn coordinator ok, 
# 3 g-forces not to high (above 0.6, disregarding 1g of earth)
# 4 aircraft stall warner not ON
	_CheckRollModeAble : func(){
		if ( (me.nAPState.getValue() == 1) and (me.nTCSpin.getValue() > 0.9) and ( math.abs(me.nAPacc.getValue()) < 0.6 ) and ( me.nStallWarnerOn.getValue() != 1) ){
			if ( ( me.nModeFail.getValue() == 1 ) or ( me.nModeDiseng.getValue() == 1 ) ) {
				me.nModeFail.setValue(0);
				me.nModeRdy.setValue(1);
				me.nModeDiseng.setValue(0);			
			}
		}else{
			me._APDisengage();
			me.nModeFail.setValue(1);
			me.nModeRdy.setValue(0);
		}
	},
# Events from the UI
	onClickHDG : func(){
		if ( ( me.nModeRdy.getValue() == 1 ) or (me.nModeNav.getValue() == 1) or (me.nModeHeading.getValue() == 1) ){
			me.nModeRdy.setValue(0);
			me.nModeHeading.setValue(1);
			me.nModeNav.setValue(0);
			me.nModeNavGpss.setValue(0);
			me.nModeGSArmed.setValue(0);
			me.nModeGSFollow.setValue(0);
			me.ndisengSound.setValue(0);
		} else {
			me.nModeFail.setValue(1);
		}
	},
	onClickHDGNAV : func(){
		if ( (me.nModeRdy.getValue() == 1) or (me.nModeHeading.getValue() == 1) or (me.nModeNav.getValue() == 1) ) {
			me.nModeRdy.setValue(0);
			me.nModeNav.setValue(1);
			me.nModeHeading.setValue(1);
			me.nModeNavGpss.setValue(0);
			me.nModeGSArmed.setValue(0);
			me.nModeGSFollow.setValue(0);
			me.ndisengSound.setValue(0);
		} else {
			me.nModeFail.setValue(1);
		}
	},
#
	onClickNAV : func(){
		if ( (me.nModeNav.getValue() == 0) or ( (me.nModeNav.getValue() == 1) and (me.nModeHeading.getValue() == 1) ) ){
			if ( (( me.nModeRdy.getValue() == 1 ) or (me.nModeHeading.getValue() == 1)) and ( (me.nNavsource.getValue() != 2) or ( (me.nNavsource.getValue() == 2) and (me.nRouteActive.getValue() == 1) ) ) ){
				me.nModeRdy.setValue(0);
				me.nModeNav.setValue(1);
				me.nModeHeading.setValue(0);
				me.ndisengSound.setValue(0);
			} else {
				me.nModeFail.setValue(1);
			} 
		} else if ( ( me.nModeNav.getValue() == 1) and ( me.nModeNavGpss.getValue() == 0) ) {
			if ( (me.nFMSserv.getValue() == 1) and (me.nNavsource.getValue() == 2) ) {
				me.nModeNavGpss.setValue(1);
			} else {
				UI.msg.info("FMS must be selected and working to engage GPSS mode");
			}
		} else { 
		}
	},
	onClickAPR : func(){
# setting /mode/apr
		if ( (me.nModeNav.getValue() == 1) and (me.nIsLocalizer.getValue() == 1) and (me.nInRange.getValue() == 1) ) {
			me.nModeApr.setValue(1);
		} else {
			me.nModeApr.setValue(0);
		}
# the apr knob can disable and enable the GS (armed)
		if (me.nModeGs.getValue() == 1 ) {
			me.nModeGSDisable.setValue(1);
			me.nModeGSArmed.setValue(0);
			me.nModeGSFollow.setValue(0);
			me.onClickALT();
		} else {
			me.nModeGSDisable.setValue(0);
		}
	},
# switching REV mode. And setting the /back-course-btn property to switch the heading-needle-defection around
	onClickREV : func(){
		if ( (me.nIsLocalizer.getValue() == 1) and (me.nModeNav.getValue() == 1) and (me.nModeRev.getValue() == 0) )  {
			setprop("/instrumentation/nav["~getprop("/instrumentation/nav-source")~"]/back-course-btn",1 );
			me.nModeRev.setValue(1);
		} else if (me.nModeRev.getValue() == 1) {
			me.nModeRev.setValue(0);
			# NOTE: the /back-course-btn properties (both nav[0] as nav[1] ) are reset in autopilot.xml based on /mode/rev = 0
		}
	},
	onClickALT : func(){
		if ( ( me.nModeAlt.getValue() == 0 ) or ( ( me.nModeAlt.getValue() == 1 ) and ( me.nModeVs.getValue() == 1 ) ) ){
			if ( me._CheckRollModeActive() == 1 ) {
				me.nSetTargetAltitudeFt.setValue( 100 * int( me.nCurrentAlt.getValue()/100 ) );			# if ALT knob is pressed on its own, current altitude rounded to 100ft becomes the target altitude
				me.nSetAltitudeBugFt.setValue( 100 * int( me.nCurrentAlt.getValue()/100 ) );			# setting bug (indicated on IFD)
				me.nModeAlt.setValue(1);
				me.nModeVs.setValue(0);
				me.nModeGSArmed.setValue(0);
				me.nModeGSFollow.setValue(0);
			} else {
				if ( getprop("fdm/jsbsim/aircraft/events/show-events") == 1 ) {
					UI.msg.info("A roll mode must be active before a pitch mode can be engaged");
				}
			}
		} else {
		}
	},
	onClickALTVS : func(){
		if ( ( me.nModeAlt.getValue() == 0 ) and (me.nModeVs.getValue() == 0) ){
			if ( me._CheckRollModeActive() == 1 ) {
				me.nModeAlt.setValue(1);
				me.nModeVs.setValue(1);
				me.nModeGSArmed.setValue(0);
				me.nModeGSFollow.setValue(0);
				if ( math.abs( me.nSetVerticalSpeedFpm.getValue() ) < 100 ) {
					me.nSetVerticalSpeedFpm.setValue( math.sgn( me.nAlterror.getValue() ) * -700 );
				}
			} else {
				if ( getprop("fdm/jsbsim/aircraft/events/show-events") == 1 ) {
					UI.msg.info("A roll mode must be active before a pitch mode can be engaged");
				}
			}
		} else if ( ( me.nModeAlt.getValue() == 1 ) and (me.nModeVs.getValue() == 0) ) {
			if ( me._CheckRollModeActive() == 1 ) {
				me.nModeVs.setValue(1);
				if ( math.abs( me.nSetVerticalSpeedFpm.getValue() ) < 100 ) {
					me.nSetVerticalSpeedFpm.setValue( math.sgn( me.nAlterror.getValue() ) * -700 );
				}
			} else {
				if ( getprop("fdm/jsbsim/aircraft/events/show-events") == 1 ) {
					UI.msg.info("A roll mode must be active before a pitch mode can be engaged");
				}
			}
		} else if ( ( me.nModeAlt.getValue() == 0 ) and (me.nModeVs.getValue() == 1) ) {
			if ( me._CheckRollModeActive() == 1 ) {
				me.nModeAlt.setValue(1);
				if ( math.abs( me.nSetVerticalSpeedFpm.getValue() ) < 100 ) {
					me.nSetVerticalSpeedFpm.setValue( math.sgn( me.nAlterror.getValue() ) * -700 );
				}
			} else {
				if ( getprop("fdm/jsbsim/aircraft/events/show-events") == 1 ) {
					UI.msg.info("A roll mode must be active before a pitch mode can be engaged");
				}
			}
		} else {
		}
	},
	onClickVS : func(){
		if ( me.nModeVs.getValue() == 0 ){
			if ( me._CheckRollModeActive() == 1 ) {
				me.nModeVs.setValue(1);
				me.nModeAlt.setValue(0);
				me.nModeGSArmed.setValue(0);
				me.nModeGSFollow.setValue(0);
			} else {
				if ( getprop("fdm/jsbsim/aircraft/events/show-events") == 1 ) {
					UI.msg.info("A roll mode must be active before a pitch mode can be engaged");
				}
			}
		} else if ( ( me.nModeVs.getValue() == 1 ) and (me.nModeAlt.getValue() == 1 ) ) {
			me.nModeAlt.setValue(0);
			me.nModeVs.setValue(1);
			me.nSetAltitudeBugFt.setValue( 100 * int( me.nCurrentAlt.getValue()/100 ) );			# setting bug (indicated on IFD)
		} else {
		}
	},
	onAdjustVS : func(amount=nil){
		if (amount!=nil){
			var value = me.nSetVerticalSpeedFpm.getValue();
			value += amount;
			if (value > 1600){value = 1600;}
			if (value < -1600){value = -1600;}
			me.nSetVerticalSpeedFpm.setValue( 100*int(value/100 ));
		}else{
			me.nSetVerticalSpeedFpm.setValue(0);
		}
	},
	onSetVS : func(value=nil){
		if (value!=nil){
			if (value > 1600){value = 1600;}
			if (value < -1600){value = -1600;}
			me.nSetVerticalSpeedFpm.setValue(value);
		}else{
			me.nSetVerticalSpeedFpm.setValue(0);
		}
	},
	onClickDisengage : func(){
		me._APDisengage();			
	},
	
########
	onClickCWS : func(){
					
	},
	onClickPitchCommand : func(){
					
	},
	initUI : func(){
		UI.register("Autopilot HDG", 		func{extra500.autopilot.onClickHDG(); } 	);
		UI.register("Autopilot HDG+NAV", 	func{extra500.autopilot.onClickHDGNAV(); } 	);
		UI.register("Autopilot NAV", 		func{extra500.autopilot.onClickNAV(); } 	);
		UI.register("Autopilot APR", 		func{extra500.autopilot.onClickAPR(); } 	);
		UI.register("Autopilot REV", 		func{extra500.autopilot.onClickREV(); } 	);
		UI.register("Autopilot ALT", 		func{extra500.autopilot.onClickALT(); } 	);
		UI.register("Autopilot ALT+VS", 	func{extra500.autopilot.onClickALTVS(); } 	);
		UI.register("Autopilot VS", 		func{extra500.autopilot.onClickVS(); } 		);
		
		UI.register("Autopilot VS >",		func{extra500.autopilot.onAdjustVS(100); } 	);
		UI.register("Autopilot VS <",		func{extra500.autopilot.onAdjustVS(-100); } 	);
		UI.register("Autopilot VS +=",		func(v){extra500.autopilot.onAdjustVS(v); } 	);
		UI.register("Autopilot VS =",		func(v){extra500.autopilot.onSetVS(v); } 	);
				
		UI.register("Autopilot disengage",	func{extra500.autopilot.onClickDisengage(); } 	);
		UI.register("Autopilot disengage on",	func{extra500.autopilot.onClickDisengage(); } 	);
		UI.register("Autopilot disengage off",	func{extra500.autopilot.onClickDisengage(); } 	);
		
		UI.register("Autopilot CWS",		func{extra500.autopilot.onClickCWS(); } 	);
		UI.register("Autopilot CWS on",		func{extra500.autopilot.onClickCWS(1); } 	);
		UI.register("Autopilot CWS off",	func{extra500.autopilot.onClickCWS(0); } 	);
		
		UI.register("Autopilot Pitch Command down",	func{extra500.autopilot.onClickPitchCommand(1); } 	);
		UI.register("Autopilot Pitch Command off",	func{extra500.autopilot.onClickPitchCommand(0); } 	);
		UI.register("Autopilot Pitch Command up",	func{extra500.autopilot.onClickPitchCommand(-1); } 	);
		
	},
	
};

var autopilot = AutopilotClass.new("extra500/instrumentation/Autopilot","Autopilot");
var fms = FlightManagementSystemClass.new("extra500/instrumentation/FMS","FMS");
