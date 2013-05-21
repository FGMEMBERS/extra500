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
#      Last change:      Dirk Dittmann
#      Date:             18.05.13
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
				
		
		m.nModeState = props.globals.initNode("/autopilot/mode/state",0,"INT");
		m.nModeHeading = props.globals.initNode("/autopilot/mode/heading",0,"INT");
		m.nModeNav = props.globals.initNode("/autopilot/mode/nav",0,"INT");
		m.nModeNavGpss = props.globals.initNode("/autopilot/mode/nav-gpss",0,"INT");
		m.nModeAlt = props.globals.initNode("/autopilot/mode/alt",0,"INT");
		m.nModeVs = props.globals.initNode("/autopilot/mode/vs",0,"INT");
		m.nModeGs = props.globals.initNode("/autopilot/mode/gs",0,"INT");
		m.nModeRev = props.globals.initNode("/autopilot/mode/rev",0,"INT");
		m.nModeApr = props.globals.initNode("/autopilot/mode/apr",0,"INT");
		m.nModeRdy = props.globals.initNode("/autopilot/mode/rdy",0,"INT");
		m.nModeCws = props.globals.initNode("/autopilot/mode/cws",0,"INT");
		m.nModeFail = props.globals.initNode("/autopilot/mode/fail",0,"INT");
		m.nModeTrim = props.globals.initNode("/autopilot/mode/trim",0,"INT");
		m.nModeTrimUp = props.globals.initNode("/autopilot/mode/trim-up",0,"INT");
		m.nModeTrimDown = props.globals.initNode("/autopilot/mode/trim-down",0,"INT");
		
		m.nSetHeadingBugDeg = props.globals.initNode("/autopilot/settings/heading-bug-deg",0,"DOUBLE");
		m.nSetTargetAltitudeFt = props.globals.initNode("/autopilot/settings/target-altitude-ft",0,"DOUBLE");
		m.nSetVerticalSpeedFpm = props.globals.initNode("/autopilot/settings/vertical-speed-fpm",0,"DOUBLE");
		m.nSetYawTrim = props.globals.initNode("/autopilot/settings/yawTrim",0,"DOUBLE");
		m.nSetPitchTrim = props.globals.initNode("/autopilot/settings/pitchTrim",0,"DOUBLE");
		
	
	# Light
		m.Backlight = Part.ElectricLED.new(m.nRoot.initNode("Backlight"),"EIP Backlight");
		m.Backlight.electricConfig(8.0,28.0);
		m.Backlight.setPower(24.0,1.0);
	
	# buses
		m.PowerInputBus = Part.ElectricBusDiode.new("PowerInputBus");
		m.GNDBus = Part.ElectricBusDiode.new("GNDBus");
		m.PowerBus = Part.ElectricBus.new("PowerBus");
				
		
	# Electric Connectors
		m.PowerInputA		= Part.ElectricPin.new("PowerInputA");
		m.PowerInputB		= Part.ElectricPin.new("PowerInputB");
		m.GND 			= Part.ElectricPin.new("GND");
		m.Dimming		= Part.ElectricConnector.new("Dimming");
		
		m.__GND			= Part.ElectricConnector.new("__GND");
		m.__Power		= Part.ElectricConnector.new("__Power");
		
		m.Dimming.solder(m);
		m.__Power.solder(m);
		m.__GND.solder(m);
		
		append(Part.aListSimStateAble,m);
		return m;

	},
	applyVoltage : func(electron,name=""){ 
		Part.etd.in("Autopilot",me.name,name,electron);
		var GND = 0;
		
		if (electron != nil){
			electron.resistor += 20000.0;
			if (name == "__Power"){
				GND = me.__GND.applyVoltage(electron);
				if (GND){
					me.state = 1;
					var watt = me.electricWork(electron);
				}
			}elsif(name == "Dimming"){
				
				GND = me.__GND.applyVoltage(electron);
				if (GND){
					
					me.dimmingVolt = electron.volt;					
					var watt = me.electricWork(electron);
					
					
				}
			}
		}
		
		Part.etd.out("Autopilot",me.name,name,electron);
		return GND;
	},
	plugElectric : func(){
		
		me.PowerInputA.plug(me.PowerBus.con());
		me.PowerInputB.plug(me.PowerBus.con());
		
		me.Backlight.Plus.plug(me.PowerBus.con());
		me.Backlight.Minus.plug(me.GNDBus.con());
		
		me.__Power.plug(me.PowerBus.con());
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
		
		if (me.state == 0){	# no power input
			me.nModeState.setValue(0);
		}else{
			me.nModeState.setValue(1);
		}
		
		# masterPanel.AutopilotMaster.state -1/0/1 
		if (masterPanel.AutopilotMaster.state == 0){ 
			
		}elsif (masterPanel.AutopilotMaster.state == 1){

		}else{
			
		}
		
		# masterPanel.AutopilotPitchTrim.state 1/0
		if (masterPanel.AutopilotPitchTrim.state > 0 ){
			
		}else{
			
		}
		
		# masterPanel.AutopilotYawDamper.state 1/0
		if (masterPanel.AutopilotYawDamper.state > 0 ){
			
		}else{
			
		}
		me.nSetYawTrim.setValue(masterPanel.AutopilotYawTrim.state);
		# masterPanel.AutopilotYawTrim.state -1.0/1.0
		if (masterPanel.AutopilotYawTrim.state > 0 ){
			
		}elsif (masterPanel.AutopilotYawTrim.state < 0){
			
		}else{
			
		}
		
		
		
		
	},
# Events from the UI
	onClickHDG : func(){
		me.nModeHeading.setValue(!me.nModeHeading.getValue());
	},
	onClickHDGNAV : func(){
		print ("Autopilot.onClickHDGNAV() ... ");
	},
	onClickNAV : func(){
		me.nModeNav.setValue(!me.nModeNav.getValue());
	},
	onClickAPR : func(){
		me.nModeApr.setValue(!me.nModeApr.getValue());
	},
	onClickREV : func(){
		me.nModeRev.setValue(!me.nModeRev.getValue());
	},
	onClickALT : func(){
		me.nModeAlt.setValue(!me.nModeAlt.getValue());
	},
	onClickALTVS : func(){
		print ("Autopilot.onClickALTVS() ... ");
	},
	onClickVS : func(){
		me.nModeVs.setValue(!me.nModeVs.getValue());
	},
	onAdjustVS : func(amount=nil){
		if (amount!=nil){
			var value = me.nSetVerticalSpeedFpm.getValue();
			value += amount;
			if (value > 1700){value = 1700;}
			if (value < -1700){value = -1700;}
			me.nSetVerticalSpeedFpm.setValue(value);
		}else{
			me.nSetVerticalSpeedFpm.setValue(0);
		}
	},
	onSetVS : func(value=nil){
		if (value!=nil){
			if (value > 1700){value = 1700;}
			if (value < -1700){value = -1700;}
			me.nSetVerticalSpeedFpm.setValue(value);
		}else{
			me.nSetVerticalSpeedFpm.setValue(0);
		}
	},
	onClickDisengage : func(){
		me.nModeHeading.setValue(0);
		me.nModeNav.setValue(0);
		me.nModeApr.setValue(0);
		me.nModeRev.setValue(0);
		me.nModeAlt.setValue(0);
		me.nModeVs.setValue(0);
				
	},
	onClickCWS : func(){
		me.nModeCws.setValue(!me.nModeCws.getValue());
	},
	onAdjustPitchTrim : func(amount=nil){
		if (amount!=nil){
			var value = me.nSetPitchTrim.getValue();
			value += amount;
			if (value > 1700){value = 1700;}
			if (value < -1700){value = -1700;}
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
		UI.register("Autopilot HDG&NAV", 	func{extra500.autopilot.onClickHDGNAV(); } 	);
		UI.register("Autopilot NAV", 		func{extra500.autopilot.onClickNAV(); } 	);
		UI.register("Autopilot APR", 		func{extra500.autopilot.onClickAPR(); } 	);
		UI.register("Autopilot REV", 		func{extra500.autopilot.onClickREV(); } 	);
		UI.register("Autopilot ALT", 		func{extra500.autopilot.onClickALT(); } 	);
		UI.register("Autopilot ALT&VS", 	func{extra500.autopilot.onClickALTVS(); } 	);
		UI.register("Autopilot VS", 		func{extra500.autopilot.onClickVS(); } 		);
		
		UI.register("Autopilot VS >",		func{extra500.autopilot.onAdjustVS(100); } 	);
		UI.register("Autopilot VS <",		func{extra500.autopilot.onAdjustVS(-100); } 	);
		UI.register("Autopilot VS +=",		func(v){extra500.autopilot.onAdjustVS(v); } 	);
		UI.register("Autopilot VS =",		func(v){extra500.autopilot.onSetVS(v); } 	);
		
		UI.register("Autopilot disengage",	func{extra500.autopilot.onClickDisengage(); } 	);
		UI.register("Autopilot CWS",		func{extra500.autopilot.onClickCWS(); } 	);
		
		UI.register("Autopilot Pitch Trim <", 	func{extra500.autopilot.onAdjustPitchTrim(-0.1); } 		);
		UI.register("Autopilot Pitch Trim >", 	func{extra500.autopilot.onAdjustPitchTrim(0.1); } 		);
		UI.register("Autopilot Pitch Trim =", 	func(v=0){extra500.autopilot.onSetPitchTrim(v);} 	);
		UI.register("Autopilot Pitch Trim +=", 	func(v=0){extra500.autopilot.onAdjustPitchTrim(v);} 	);
	
	}
	
};


var autopilot = Autopilot.new(props.globals.initNode("extra500/instrumentation/Autopilot"),"Autopilot");
