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
#      Date:             21.05.13
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
				
#		m.nModeState = props.globals.initNode("/autopilot/mode/state",0,"INT");
		m.nModeFD 	= props.globals.initNode("/autopilot/mode/fd",0,"INT");	# HACK
		m.nModeAP 	= props.globals.initNode("/autopilot/mode/ap",0,"INT"); # HACK
		m.nModeYawDamper 	= props.globals.initNode("/autopilot/mode/yawDamper",0,"INT"); # HACK
		
		
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
		m.nModeTrimUp 	= props.globals.initNode("/autopilot/mode/trim-up",0,"INT");
		m.nModeTrimDown = props.globals.initNode("/autopilot/mode/trim-down",0,"INT");
		
		m.nSetHeadingBugDeg = props.globals.initNode("/autopilot/settings/heading-bug-deg",0,"DOUBLE");
		m.nSetTargetAltitudeFt = props.globals.initNode("/autopilot/settings/target-altitude-ft",0,"DOUBLE");
		m.nSetVerticalSpeedFpm = props.globals.initNode("/autopilot/settings/vertical-speed-fpm",0,"DOUBLE");
		m.nSetYawTrim = props.globals.initNode("/autopilot/settings/yawTrim",0,"DOUBLE");
		m.nSetPitchTrim = props.globals.initNode("/autopilot/settings/pitchTrim",0,"DOUBLE");
		
		m.nAPState = props.globals.getNode("/extra500/instrumentation/Autopilot/state");		
		m.nTCSpin = props.globals.getNode("/instrumentation/turn-indicator/spin");			

		
		
	# Switches
		
		
		m.Disengage = Part.ElectricSwitchDT.new(nRoot.initNode("Disengage"),"Autopilot Disengage");
		m.Disengage.setPoles(2);
		
		m.CWS = Part.ElectricSwitchDT.new(nRoot.initNode("CWS"),"Autopilot CWS");
		m.CWS.setPoles(1);
		
		m.TrimCommannd = Part.ElectricSwitchTT.new(nRoot.initNode("TrimCommannd"),"Trim Commannd");
		m.TrimCommannd.setPoles(2);
		
		
	
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
		
		m.Dimming.solder(m);
		m.ManualTrimUp.solder(m);
		m.ManualTrimDown.solder(m);
		m.PitchTrim28V.solder(m);
		m.TrimInterrupt.solder(m);
		m.YawDamper.solder(m);
		m.ApPlus.solder(m);
		m.ApDisconnect.solder(m);
		m.__FdEnable.solder(m);
		m.__Power.solder(m);
		m.__GND.solder(m);
		
		
		me.__ModeFD = 0;
		me.__ModeAP = 0;
		me.__ModeDisengage = 1;
		me.__ModeTrimInterrupt = 1;
		me.__ModePitchTrim28V = 0;
		me.__ModeManualTrimUp = 0;
		me.__ModeManualTrimDown = 0;
		me.__ModeYawDamper = 0;
		
		append(Part.aListSimStateAble,m);
		return m;

	},
	simReset : func(){
		me.nState.setValue(me.state);
		me.state = me.default;
		
		me.__ModeFD = 0;
		me.__ModeAP = 0;
		me.__ModeDisengage = 1;
		me.__ModeTrimInterrupt = 1;
		me.__ModePitchTrim28V = 0;
		me.__ModeManualTrimUp = 0;
		me.__ModeManualTrimDown = 0;
		me.__ModeYawDamper = 0;
		
		
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
					me.__ModeAP = 1;
					var watt = me.electricWork(electron);
				}
			}elsif(name == "__FdEnable"){
				GND = me.FdEnable.applyVoltage(electron);
				if (GND){
					me.__ModeFD = 1;					
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
					me.__ModeDisengage = 0;
				}
			}elsif(name == "TrimInterrupt"){
				
				GND = me.__GND.applyVoltage(electron);
				if (GND){
					me.__ModeTrimInterrupt = 0;
				}
			}elsif(name == "PitchTrim28V"){
				
				GND = me.__GND.applyVoltage(electron);
				if (GND){
					me.__ModePitchTrim28V = 1;
				}
			}elsif(name == "ManualTrimUp"){
				
				GND = me.__GND.applyVoltage(electron);
				if (GND){
					me.__ModeManualTrimUp = 1;
				}
			}elsif(name == "ManualTrimDown"){
				
				GND = me.__GND.applyVoltage(electron);
				if (GND){
					me.__ModeManualTrimDown = 1;
				}
			}elsif(name == "YawDamper"){
				
				GND = me.__GND.applyVoltage(electron);
				if (GND){
					me.__ModeYawDamper = 1;
				}
			}
		}
		
		Part.etd.out("Autopilot",me.name,name,electron);
		return GND;
	},
	plugElectric : func(){
		me.ApPlus.plug(me.ApMasterBus.con());
		me.__FdEnable.plug(me.ApMasterBus.con());
		
		me.Disengage.Com1.plug(me.ApMasterBus.con());
		me.Disengage.L11.plug(me.StallWaringRelais.P12);
		me.Disengage.Com2.plug(circuitBreakerPanel.AutopilotServoBus.con());
		me.Disengage.L21.plug(me.StallWaringRelais.P22);
		
		me.StallWaringRelais.P11.plug(me.ApDisconnect);
		me.StallWaringRelais.P21.plug(me.TrimInterrupt);
				
		me.TrimCommannd.Com1.plug(me.ManualTrimUp);
		me.TrimCommannd.Com2.plug(me.ManualTrimDown);
		
		me.TrimCommannd.L11.plug(me.GNDBus.con());
		me.TrimCommannd.L23.plug(me.GNDBus.con());
				
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
	update : func(timestamp){
		
		me._dimmBacklight();
		
#		if (me.state == 0){	# no power input
#			me.nModeState.setValue(0);
#		}else{
#			me.nModeState.setValue(1);
#		}
		
# Setting Mode Disconnect(Yoke) in Property Tree
		if (me.__ModeDisengage != me.nModeDiseng.getValue() ){
			me.nModeDiseng.setValue(me.__ModeDisengage);
		}
		
# Setting Mode TrimUp(Yoke) in Property Tree
		if (me.__ModeManualTrimUp != me.nModeTrimUp.getValue() ){
			me.nModeTrimUp.setValue(me.__ModeManualTrimUp);
		}
		
# Setting Mode TrimDown(Yoke) in Property Tree
		if (me.__ModeManualTrimDown != me.nModeTrimDown.getValue() ){
			me.nModeTrimDown.setValue(me.__ModeManualTrimDown);
		}

		
		
		
# Setting Mode AP(switch Master Panel) in Property Tree
		if (me.__ModeAP != me.nModeAP.getValue() ){
			me.nModeAP.setValue(me.__ModeAP);
		}
		
# Setting Mode FD(switch Master Panel) in Property Tree
		if (me.__ModeFD != me.nModeFD.getValue() ){
			me.nModeFD.setValue(me.__ModeFD);
		}
		
# Setting Mode Pitch(switch Master Panel) in Property Tree
		if (me.__ModePitchTrim28V != me.nModeTrim.getValue()){
			me.nModeTrim.setValue(me.__ModePitchTrim28V);
		}

# Setting Mode YawDamper(switch Master Panel) in Property Tree
		if (me.__ModeYawDamper != me.nModeYawDamper.getValue()){
			me.nModeYawDamper.setValue(me.__ModeYawDamper);
		}
		
		
		


		me.nSetYawTrim.setValue(masterPanel.AutopilotYawTrim.state);
		# masterPanel.AutopilotYawTrim.state -1.0/1.0
		if (masterPanel.AutopilotYawTrim.state > 0 ){
			
		}elsif (masterPanel.AutopilotYawTrim.state < 0){
			
		}else{
			
		}
		# continues checking if the AP may still me working
		me._CheckRollModeAble();
		
		
	},
# disengages the autopilot
	_APDisengage : func(){
		me.nModeHeading.setValue(0);
		me.nModeNav.setValue(0);
		me.nModeNavGpss.setValue(0);
		me.nModeApr.setValue(0);
		me.nModeRev.setValue(0);
		me.nModeAlt.setValue(0);
		me.nModeVs.setValue(0);
		me.nModeDiseng.setValue(1);
	},
# checks is a roll mode (HDG or NAV) is active. Must be active to engage any alt mode or yaw damper
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
# 3 no stall warning, (TBD)
# 4 no pitch trim going on (TBD)
# 5 g-forces not to high (TBD)
	_CheckRollModeAble : func(){
		if ( (me.nAPState.getValue() == 1) and (me.nTCSpin.getValue() > 0.9) ){
			if ( ( me.nModeFail.getValue() == 1 ) or ( me.nModeDiseng.getValue() == 1 ) ) {
				me.nModeFail.setValue(0);
				me.nModeRdy.setValue(1);
				# HACK FIXME: it always set to 0 so the Yoke button cant disengage
				#me.nModeDiseng.setValue(0);
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
			} else {
				me.nModeFail.setValue(1);
			}
		} else {
			me.nModeRdy.setValue(1);
			me.nModeHeading.setValue(0);
			me.nModeAlt.setValue(0);
			me.nModeVs.setValue(0);
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
			} else {
				me.nModeFail.setValue(1);
			} 
		} else if ( ( me.nModeNav.getValue() == 1) and ( me.nModeNavGpss.getValue() == 0) ) {
# a check if GPSS is possible fails here!
			me.nModeNavGpss.setValue(1);
		} else { 
			me.nModeRdy.setValue(1);
			me.nModeNav.setValue(0);
			me.nModeNavGpss.setValue(0);
			me.nModeAlt.setValue(0);
			me.nModeVs.setValue(0);
		}
	},
	onClickAPR : func(){
		me.nModeApr.setValue(!me.nModeApr.getValue());
	},
	onClickREV : func(){
		me.nModeRev.setValue(!me.nModeRev.getValue());
	},
	onClickALT : func(){
		if ( me.nModeAlt.getValue() == 0 ){
			if ( me._CheckRollModeActive() == 1 ) {
				me.nModeAlt.setValue(1);
				me.nModeVs.setValue(0);
			} 
		} else {
			me.nModeAlt.setValue(0);
		}
	},
	onClickALTVS : func(){
		if ( ( me.nModeAlt.getValue() == 0 ) and (me.nModeVs.getValue() == 0) ){
			if ( me._CheckRollModeActive() == 1 ) {
				me.nModeAlt.setValue(1);
				me.nModeVs.setValue(1);
			} 
		} else if ( ( me.nModeAlt.getValue() == 1 ) and (me.nModeVs.getValue() == 0) ) {
			if ( me._CheckRollModeActive() == 1 ) {
				me.nModeVs.setValue(1);
			} 
		} else if ( ( me.nModeAlt.getValue() == 0 ) and (me.nModeVs.getValue() == 1) ) {
			if ( me._CheckRollModeActive() == 1 ) {
				me.nModeAlt.setValue(1);
			} 
		} else {
				me.nModeAlt.setValue(0);
				me.nModeVs.setValue(0);
		}
	},
	onClickVS : func(){
		if ( me.nModeVs.getValue() == 0 ){
			if ( me._CheckRollModeActive() == 1 ) {
				me.nModeVs.setValue(1);
				me.nModeAlt.setValue(0);
			} 
		} else {
			me.nModeVs.setValue(0);
		}
	},
	onAdjustVS : func(amount=nil){
		if (amount!=nil){
			var value = me.nSetVerticalSpeedFpm.getValue();
			value += amount;
			if (value > 1600){value = 1600;}
			if (value < -1600){value = -1600;}
			me.nSetVerticalSpeedFpm.setValue(value);
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
	onClickCWS : func(){
		me.nModeCws.setValue(!me.nModeCws.getValue());
	},
	onAdjustPitchTrim : func(amount=nil){
		if (amount!=nil){
			var value = me.nSetPitchTrim.getValue();
			value += amount;
			if (value > 1.0){value = 1.0;}
			if (value < -1.0){value = -1.0;}
			me.nSetPitchTrim.setValue(value);
		}else{
			me.nSetPitchTrim.setValue(0);
		}
	},
	onSetPitchTrim : func(value=nil){
		if (value!=nil){
			if (value > 1.0){value = 1.0;}
			if (value < -1.0){value = -1.0;}
			me.nSetPitchTrim.setValue(value);
		}else{
			me.nSetPitchTrim.setValue(0);
		}
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
		
		
		UI.register("Autopilot Pitch Trim <", 	func{extra500.autopilot.onAdjustPitchTrim(-0.1); } 		);
		UI.register("Autopilot Pitch Trim >", 	func{extra500.autopilot.onAdjustPitchTrim(0.1); } 		);
		UI.register("Autopilot Pitch Trim =", 	func(v=0){extra500.autopilot.onSetPitchTrim(v);} 	);
		UI.register("Autopilot Pitch Trim +=", 	func(v=0){extra500.autopilot.onAdjustPitchTrim(v);} 	);
	
			
		UI.register("Autopilot disengage",	func{extra500.autopilot.Disengage.toggle(); } 	);
		UI.register("Autopilot disengage on",	func{extra500.autopilot.Disengage.on(); } 	);
		UI.register("Autopilot disengage off",	func{extra500.autopilot.Disengage.off(); } 	);
		
		UI.register("Autopilot CWS",		func{extra500.autopilot.CWS.toggle(); } 	);
		UI.register("Autopilot CWS on",		func{extra500.autopilot.CWS.on(); } 	);
		UI.register("Autopilot CWS off",	func{extra500.autopilot.CWS.off(); } 	);
		
		#UI.register("Autopilot Pitch Command",	func{extra500.autopilot.CWS.toggle(); } 	);
		UI.register("Autopilot Pitch Command up",	func{extra500.autopilot.TrimCommannd.setValue(1); } 	);
		UI.register("Autopilot Pitch Command center",	func{extra500.autopilot.TrimCommannd.setValue(0); } 	);
		UI.register("Autopilot Pitch Command down",	func{extra500.autopilot.TrimCommannd.setValue(-1); } 	);
				
		
	}
	
};


var autopilot = Autopilot.new(props.globals.initNode("extra500/instrumentation/Autopilot"),"Autopilot");
