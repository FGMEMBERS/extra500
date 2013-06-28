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
#      Date: May 18 2013
#
#      Last change:      Eric van den Berg
#      Date:             2013-06-28
#

var Autopilot = {
	new : func(nRoot,name){
				
		var m = {parents:[
			Autopilot,
			Part.Part.new(nRoot,name),
			Part.SimStateAble.new(nRoot,"BOOL",0),
			Part.ElectricAble.new(nRoot,name)
		]};
		
		m.dimmingVolt = 0.0;
				
		
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
		m.nModeGSDisable = props.globals.initNode("/autopilot/mode/gsdisable",0,"INT");
		
		
		m.nSetAP 		= props.globals.initNode("/autopilot/settings/ap",0,"BOOL");			# Master Panel AP
		m.nSetFD 		= props.globals.initNode("/autopilot/settings/fd",0,"BOOL");			# Master Panel FD
		m.nSetTrim 		= props.globals.initNode("/autopilot/settings/trim",0,"BOOL");			# Master Panel Pitch Trim
		m.nSetYawDamper 	= props.globals.initNode("/autopilot/settings/yawdamper",0,"INT");		# Master Panel Yaw Damper
		m.nSetYawTrim 		= props.globals.initNode("/autopilot/settings/yawTrim",0,"DOUBLE");		# Master Panel Yaw Trim
		m.nSetPitchTrimUp 	= props.globals.initNode("/autopilot/settings/pitchTrim-up",0,"BOOL");		# Yoke Pitch Trim up 
		m.nSetPitchTrimDown 	= props.globals.initNode("/autopilot/settings/pitchTrim-down",0,"BOOL");	# Yoke Pitch Trim down
		m.nSetCws 		= props.globals.initNode("/autopilot/settings/cws",0,"BOOL");			# Yoke CWS
		m.nSetHeadingBugDeg 	= props.globals.initNode("/autopilot/settings/heading-bug-deg",0,"DOUBLE");	# Keypad 
		m.nSetAltitudeBugFt 	= props.globals.initNode("/autopilot/settings/target-altitude-ft",0,"DOUBLE");	# Keypad
		m.nSetTargetAltitudeFt 	= props.globals.initNode("/autopilot/alt-channel/target-alt-ft",0,"DOUBLE");
		m.nSetVerticalSpeedFpm 	= props.globals.initNode("/autopilot/settings/vertical-speed-fpm",0,"DOUBLE");  # Autopilot Panel
		m.nIsLocalizer		= props.globals.initNode("/autopilot/radionav-channel/is-localizer-frequency",0,"BOOL");
		m.nInRange		= props.globals.initNode("/autopilot/radionav-channel/in-range",0,"DOUBLE");	
		
		m.nAPState 	= props.globals.getNode("/extra500/instrumentation/Autopilot/state");		
		m.nTCSpin 	= props.globals.getNode("/instrumentation/turn-indicator/spin");			
		m.nAPacc 	= props.globals.getNode("/autopilot/accsens-channel/ap-z-accel");
		m.nCurrentAlt 	= props.globals.getNode("/instrumentation/altimeter-IFD-LH/indicated-altitude-ft");	
		m.nAlterror 	= props.globals.getNode("/autopilot/alt-channel/alt-error-ft");															

		
		
	# Switches
		
		
		m.swtDisengage = Part.ElectricSwitchDT.new(nRoot.initNode("Disengage"),"Autopilot Disengage");
		m.swtDisengage.setPoles(2);
		
		m.swtCWS = Part.ElectricSwitchDT.new(nRoot.initNode("CWS"),"Autopilot CWS");
		m.swtCWS.setPoles(1);
		
		m.swtTrimCommannd = Part.ElectricSwitchTT.new(nRoot.initNode("TrimCommannd"),"Trim Commannd");
		m.swtTrimCommannd.setPoles(2);
		
		
	
	#Relais
		m.StallWaringRelais = Part.ElectricRelaisXPDT.new(nRoot.initNode("StallWaringRelais"),"StallWaringRelais");
		m.StallWaringRelais.setPoles(2);
		
		
	# Light
		m.Backlight = Part.ElectricLED.new(m.nRoot.initNode("Backlight"),"EIP Backlight");
		m.Backlight.electricConfig(8.0,28.0);
		m.Backlight.setPower(24.0,1.0);
	
	# buses
		m.PowerInputBus = Part.ElectricBusDiode.new("PowerInputBus");
		m.GNDBus 	= Part.ElectricBusDiode.new("GNDBus");
		m.PowerBus 	= Part.ElectricBus.new("PowerBus");
		m.ApMasterBus 	= Part.ElectricBus.new("ApMasterBus");
		
	# Electric Connectors
		m.GND 			= Part.ElectricPin.new("GND");
		m.Dimming		= Part.ElectricConnector.new("Dimming");
		
		m.__GND			= Part.ElectricConnector.new("__GND");
		m.__Power		= Part.ElectricConnector.new("__Power");
		m.__FdEnable		= Part.ElectricConnector.new("__FdEnable");
		m.FdEnable		= Part.ElectricConnector.new("FdEnable");
		m.ApPlus		= Part.ElectricConnector.new("ApPlus");
		m.ApDisconnect		= Part.ElectricConnector.new("ApDisconnect");
		m.ManualTrimUp		= Part.ElectricConnector.new("ManualTrimUp");
		m.ManualTrimDown	= Part.ElectricConnector.new("ManualTrimDown");
		m.PitchTrim28V		= Part.ElectricConnector.new("PitchTrim28V");
		m.TrimInterrupt		= Part.ElectricConnector.new("TrimInterrupt");
		m.YawDamper		= Part.ElectricConnector.new("YawDamper");
		m.CWS			= Part.ElectricConnector.new("CWS");
		
		m.Dimming.solder(m);
		m.ManualTrimUp.solder(m);
		m.ManualTrimDown.solder(m);
		m.PitchTrim28V.solder(m);
		m.TrimInterrupt.solder(m);
		m.YawDamper.solder(m);
		m.CWS.solder(m);
		m.ApPlus.solder(m);
		m.ApDisconnect.solder(m);
		m.__FdEnable.solder(m);
		m.__Power.solder(m);
		m.__GND.solder(m);
		
		
		m.__FD = 0;
		m.__AP = 0;
		m.__Disengage = 1;
		m.__TrimInterrupt = 0;
		m.__PitchTrim28V = 0;
		m.__ManualTrimUp = 0;
		m.__ManualTrimDown = 0;
		m.__YawDamper = 0;
		m.__CWS = 0;
		
		append(Part.aListSimStateAble,m);
		return m;

	},
	simReset : func(){
		me.nState.setValue(me.state);
		me.state = me.default;
		
		me.__FD = 0;
		me.__AP = 0;
		me.__Disengage = 1;
		me.__TrimInterrupt = 0;
		me.__PitchTrim28V = 0;
		me.__ManualTrimUp = 0;
		me.__ManualTrimDown = 0;
		me.__YawDamper = 0;
		me.__CWS = 0;
		
		
	},
	simUpdate : func(){
		me.nState.setValue(me.state);
	},
	
	applyVoltage : func(electron,name=""){ 
		Part.etd.in("Autopilot",me.name,name,electron);
		var GND = 0;
		
		if (electron != nil){
			electron.resistor += 20000.0;
			if (name == "ApPlus"){
				GND = me.__GND.applyVoltage(electron);
				if (GND){
					me.state = 1;
					me.__AP = 1;
					var watt = me.electricWork(electron);
				}
			}elsif(name == "__FdEnable"){
				GND = me.FdEnable.applyVoltage(electron);
				if (GND){
					me.__FD = 1;					
				}
			}elsif(name == "Dimming"){
				
				GND = me.__GND.applyVoltage(electron);
				if (GND){
					
					me.dimmingVolt = electron.volt;					
					var watt = me.electricWork(electron);
					
					
				}
			}elsif(name == "ApDisconnect"){
				
				GND = me.__GND.applyVoltage(electron);
				if (GND){
					me.__Disengage = 0;
				}
			}elsif(name == "TrimInterrupt"){
				
				GND = me.__GND.applyVoltage(electron);
				if (GND){
					me.__TrimInterrupt = 1;
				}
			}elsif(name == "PitchTrim28V"){
				
				GND = me.__GND.applyVoltage(electron);
				if (GND){
					me.__PitchTrim28V = 1;
				}
			}elsif(name == "ManualTrimUp"){
				
				GND = me.__GND.applyVoltage(electron);
				if (GND){
					me.__ManualTrimUp = 1;
				}
			}elsif(name == "ManualTrimDown"){
				
				GND = me.__GND.applyVoltage(electron);
				if (GND){
					me.__ManualTrimDown = 1;
				}
			}elsif(name == "YawDamper"){
				
				GND = me.__GND.applyVoltage(electron);
				if (GND){
					me.__YawDamper = 1;
				}
			}elsif(name == "CWS"){
				
				GND = me.__GND.applyVoltage(electron);
				if (GND){
					me.__CWS = 1;
				}
			}
		}
		
		Part.etd.out("Autopilot",me.name,name,electron);
		return GND;
	},
	plugElectric : func(){
		me.ApPlus.plug(me.ApMasterBus.con());
		me.__FdEnable.plug(me.ApMasterBus.con());
		
		me.swtDisengage.Com1.plug(me.ApMasterBus.con());
		me.swtDisengage.L11.plug(me.StallWaringRelais.P12);
		me.swtDisengage.Com2.plug(circuitBreakerPanel.AutopilotServoBus.con());
		me.swtDisengage.L21.plug(me.StallWaringRelais.P22);
		
		me.StallWaringRelais.P11.plug(me.ApDisconnect);
		me.StallWaringRelais.P21.plug(me.TrimInterrupt);
				
		me.swtTrimCommannd.Com1.plug(me.ManualTrimUp);
		me.swtTrimCommannd.Com2.plug(me.ManualTrimDown);
		
		me.swtTrimCommannd.L11.plug(me.GNDBus.con());
		me.swtTrimCommannd.L23.plug(me.GNDBus.con());
		
		me.swtCWS.Com1.plug(me.ApMasterBus.con());
		me.swtCWS.L12.plug(me.CWS);
						
		me.Backlight.Plus.plug(me.ApMasterBus.con());
		me.Backlight.Minus.plug(me.GNDBus.con());
		
		me.__GND.plug(me.GNDBus.con());
		
		me.GNDBus.Minus.plug(me.GND);
	},
	_dimmBacklight : func(){
		if (me.dimmingVolt < 8.0){
			me.Backlight.setBrightness(1.0);
		}else{
			me.Backlight.setBrightness( me.dimmingVolt / 28.0);
		}
		me.dimmingVolt = 0.0;
	},
	# Main Simulation loop  ~ 10Hz
	simulationUpdate : func(now,dt){
		
		me._dimmBacklight();
		
		if (me.__Disengage == 1){
			me._APDisengage();
			me.swtDisengage._setValue(0);
		}
		
		if (me.__TrimInterrupt == 1){
			me._APDisengage();
			
		}
		
# Setting Modes from electric switches
		me.nSetAP.setValue(me.__AP);
		me.nSetFD.setValue(me.__FD);
		me.nSetPitchTrimUp.setValue(me.__ManualTrimUp);
		me.nSetPitchTrimDown.setValue(me.__ManualTrimDown);
		me.nSetYawDamper.setValue(me.__YawDamper);
		me.nSetYawTrim.setValue(masterPanel.AutopilotYawTrim.state);
		me.nSetCws.setValue(me.__CWS);
		me.nSetTrim.setValue(me.__PitchTrim28V);
		
		
		# continuous checking if the AP may still me working
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
	_CheckRollModeAble : func(){
		if ( (me.nAPState.getValue() == 1) and (me.nTCSpin.getValue() > 0.9) and ( math.abs(me.nAPacc.getValue()) < 0.6 ) ){
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
		if ( me.nModeHeading.getValue() == 0 ){
			if ( ( me.nModeRdy.getValue() == 1 ) or (me.nModeNav.getValue() > 0) ){
				me.nModeRdy.setValue(0);
				me.nModeHeading.setValue(1);
				me.nModeNav.setValue(0);
				me.nModeNavGpss.setValue(0);
				me.ndisengSound.setValue(0);
			} else {
				me.nModeFail.setValue(1);
			}
		} else {
		}
	},
	onClickHDGNAV : func(){
		print ("Autopilot.onClickHDGNAV() ... ");
	},
#
	onClickNAV : func(){
		if ( me.nModeNav.getValue() == 0 ){
			if ( ( me.nModeRdy.getValue() == 1 ) or (me.nModeHeading.getValue() == 1) ){
				me.nModeRdy.setValue(0);
				me.nModeNav.setValue(1);
				me.nModeHeading.setValue(0);
				me.ndisengSound.setValue(0);
			} else {
				me.nModeFail.setValue(1);
			} 
		} else if ( ( me.nModeNav.getValue() == 1) and ( me.nModeNavGpss.getValue() == 0) ) {
# a check if GPSS is possible fails here!
			me.nModeNavGpss.setValue(1);
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
			onClickALT();
		} else {
			me.nModeGSDisable.setValue(0);
		}
	},
	onClickREV : func(){
		me.nModeRev.setValue(!me.nModeRev.getValue());
	},
	onClickALT : func(){
		if ( ( me.nModeAlt.getValue() == 0 ) or ( ( me.nModeAlt.getValue() == 1 ) and ( me.nModeVs.getValue() == 1 ) ) ){
			if ( me._CheckRollModeActive() == 1 ) {
				me.nSetTargetAltitudeFt.setValue( 100 * int( me.nCurrentAlt.getValue()/100 ) );			# if ALT knob is pressed on its own, current altitude rounded to 100ft becomes the target altitude
				me.nSetAltitudeBugFt.setValue( 100 * int( me.nCurrentAlt.getValue()/100 ) );			# setting bug (indicated on IFD)
				me.nModeAlt.setValue(1);
				me.nModeVs.setValue(0);
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

# 	onAdjustPitchTrim : func(amount=nil){
# 		if (amount!=nil){
# 			var value = me.nSetPitchTrim.getValue();
# 			value += amount;
# 			if (value > 1.0){value = 1.0;}
# 			if (value < -1.0){value = -1.0;}
# 			me.nSetPitchTrim.setValue(value);
# 		}else{
# 			me.nSetPitchTrim.setValue(0);
# 		}
# 	},
# 	onSetPitchTrim : func(value=nil){
# 		if (value!=nil){
# 			if (value > 1.0){value = 1.0;}
# 			if (value < -1.0){value = -1.0;}
# 			me.nSetPitchTrim.setValue(value);
# 		}else{
# 			me.nSetPitchTrim.setValue(0);
# 		}
# 	},
	
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
		
		
		UI.register("Autopilot disengage",	func{extra500.autopilot.swtDisengage.toggle(); } 	);
		UI.register("Autopilot disengage on",	func{extra500.autopilot.swtDisengage.on(); } 	);
		UI.register("Autopilot disengage off",	func{extra500.autopilot.swtDisengage.off(); } 	);
		
		UI.register("Autopilot CWS",		func{extra500.autopilot.swtCWS.toggle(); } 	);
		UI.register("Autopilot CWS on",		func{extra500.autopilot.swtCWS.on(); } 	);
		UI.register("Autopilot CWS off",	func{extra500.autopilot.swtCWS.off(); } 	);
		
		UI.register("Autopilot Pitch Command down",	func{extra500.autopilot.swtTrimCommannd.setValue(1); } 	);
		UI.register("Autopilot Pitch Command off",	func{extra500.autopilot.swtTrimCommannd.setValue(0); } 	);
		UI.register("Autopilot Pitch Command up",	func{extra500.autopilot.swtTrimCommannd.setValue(-1); } 	);
				
		
	}
	
};


var autopilot = Autopilot.new(props.globals.initNode("extra500/instrumentation/Autopilot"),"Autopilot");
