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
				
	
	# Light
		m.Backlight = Part.ElectricLED.new(m.nRoot.initNode("Backlight"),"EIP Backlight");
		m.Backlight.electricConfig(8.0,28.0);
		m.Backlight.setPower(24.0,1.0);
	
	# buses
		m.PowerInputBus = Part.ElectricBusDiode.new("PowerInputBus");
		m.GNDBus = Part.ElectricBusDiode.new("GNDBus");
		m.PowerBus = Part.ElectricBus.new("PowerBus");
				
		
	# Electric Connectors
		m.PowerInput		= Part.ElectricPin.new("PowerInput");
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
		
		me.PowerInput.plug(me.PowerBus.con());
		
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
			
		}else{
			
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
		
		# masterPanel.AutopilotYawTrim.state -1.0/1.0
		if (masterPanel.AutopilotYawDamper.state > 0 ){
			
		}elsif (masterPanel.AutopilotYawDamper.state < 0){
			
		}else{
			
		}
		
		
		
		
	},
# Events from the UI
	onClickHDG : func(){
		print ("Autopilot.onClickHDG() ... ");
	},
	onClickNAV : func(){
		print ("Autopilot.onClickNAV() ... ");
	},
	onClickAPR : func(){
		print ("Autopilot.onClickAPR() ... ");
	},
	onClickREV : func(){
		print ("Autopilot.onClickREV() ... ");
	},
	onClickALT : func(){
		print ("Autopilot.onClickALT() ... ");
	},
	onClickVS : func(){
		print ("Autopilot.onClickVS() ... ");
	},
	onAdjustVS : func(amount){
		print ("Autopilot.onAdjustVS("~amount~") ... ");
	},
	onClickDisengage : func(){
		print ("Autopilot.onClickDisengage() ... ");
	},
	
	initUI : func(){
		UI.register("Autopilot HDG", 	func{extra500.autopilot.onClickHDG(); } 	);
		UI.register("Autopilot NAV", 	func{extra500.autopilot.onClickNAV(); } 	);
		UI.register("Autopilot APR", 	func{extra500.autopilot.onClickAPR(); } 	);
		UI.register("Autopilot REV", 	func{extra500.autopilot.onClickREV(); } 	);
		UI.register("Autopilot ALT", 	func{extra500.autopilot.onClickALT(); } 	);
		UI.register("Autopilot VS", 	func{extra500.autopilot.onClickVS(); } 		);
		UI.register("Autopilot VS +100",func{extra500.autopilot.onAdjustVS(100); } 	);
		UI.register("Autopilot VS -100",func{extra500.autopilot.onAdjustVS(-100); } 	);
		UI.register("Autopilot disengage",func{extra500.autopilot.onClickDisengage(); } 	);
		
	}
	
};


var autopilot = Autopilot.new(props.globals.initNode("extra500/instrumentation/Autopilot"),"Autopilot");
