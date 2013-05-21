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
#      Date: May 09 2013
#
#      Last change:      Dirk Dittmann
#      Date:             09.05.13
#

var DigitalInstrumentPackage = {
	new : func(nRoot,name){
				
		var m = {parents:[
			DigitalInstrumentPackage,
			Part.Part.new(nRoot,name),
			Part.SimStateAble.new(nRoot,"BOOL",0),
			Part.ElectricAble.new(nRoot,name)
		]};
		
		m.dimmingVolt = 0.0;
				
		#m.VoltMonitor = Part.ElectricVoltSensor.new(m.nPanel.initNode("VoltMonitor"),"Volt Monitor");
		m.VDC = 0.0;
		
		m.nGenAmps = props.globals.initNode("extra500/electric/eBox/GeneratorShunt/indicatedAmpere",0.0,"DOUBLE");
		m.nBatAmps = props.globals.initNode("extra500/electric/eBox/BatteryShunt/indicatedAmpere",0.0,"DOUBLE");
		
		m.nIAT = props.globals.initNode("/environment/temperature-degc",0.0,"DOUBLE");
		m.nFuelTemp = props.globals.initNode("/fdm/jsbsim/aircraft/engine/FT-degC",0.0,"DOUBLE");
		m.nFuelPress = props.globals.initNode("/fdm/jsbsim/aircraft/engine/FP-psi",0.0,"DOUBLE");
		
		m.nIndicatedVDC = nRoot.initNode("indicatedVDC",0.0,"DOUBLE");
		m.nIndicatedGEN = nRoot.initNode("indicatedGEN",0.0,"DOUBLE");
		m.nIndicatedBAT = nRoot.initNode("indicatedBAT",0.0,"DOUBLE");
		
		m.nIndicatedIAT = nRoot.initNode("indicatedIAT",0.0,"DOUBLE");
		m.nIndicatedFuelTemp = nRoot.initNode("indicatedFuelTemp",0.0,"DOUBLE");
		m.nIndicatedFuelPress = nRoot.initNode("indicatedFuelPress",0.0,"DOUBLE");
		
	
	# Light
		m.Backlight = Part.ElectricLED.new(m.nRoot.initNode("Backlight"),"EIP Backlight");
		m.Backlight.electricConfig(8.0,28.0);
		m.Backlight.setPower(24.0,2.0);
	
	# buses
		m.PowerInputBus = Part.ElectricBusDiode.new("PowerInputBus");
		m.GNDBus = Part.ElectricBusDiode.new("GNDBus");
		m.PowerBus = Part.ElectricBus.new("PowerBus");
		
		
		
	# Electric Connectors
		m.PowerInputA 		= Part.ElectricPin.new("PowerInputA");
		m.PowerInputB 		= Part.ElectricPin.new("PowerInputB");
		m.VoltMonitor		= Part.ElectricConnector.new("VoltMonitor");
		m.GND 			= Part.ElectricPin.new("GND");
		m.Dimming		= Part.ElectricConnector.new("Dimming");
		
		m.__GND			= Part.ElectricConnector.new("__GND");
		m.__Power		= Part.ElectricConnector.new("__Power");
		
		m.Dimming.solder(m);
		m.VoltMonitor.solder(m);
		m.__Power.solder(m);
		m.__GND.solder(m);
		
		append(Part.aListSimStateAble,m);
		return m;

	},
	applyVoltage : func(electron,name=""){ 
		Part.etd.in("DIP",me.name,name,electron);
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
			}elsif(name == "VoltMonitor"){
				
				GND = me.__GND.applyVoltage(electron);
				if (GND){
					var watt = me.electricWork(electron);
					me.VDC = electron.volt;
				}
			}
		}
		
		Part.etd.out("DIP",me.name,name,electron);
		return GND;
	},
	plugElectric : func(){
		
		me.PowerInputA.plug(me.PowerInputBus.con());
		me.PowerInputB.plug(me.PowerInputBus.con());
		me.PowerInputBus.Minus.plug(me.PowerBus.con());
		
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
			me.VDC = 0.0;
		}
		
		me.nIndicatedVDC.setValue( math.abs(me.VDC) + 0.0001 );
		me.nIndicatedGEN.setValue( math.abs(me.nGenAmps.getValue()) + 0.0001 );
		me.nIndicatedBAT.setValue( math.abs(me.nBatAmps.getValue()) + 0.0001 );
		me.nIndicatedIAT.setValue( math.abs(me.nIAT.getValue()) + 0.0001 );
		me.nIndicatedFuelTemp.setValue( math.abs(me.nFuelTemp.getValue()) + 0.0001 );
		me.nIndicatedFuelPress.setValue( math.abs(me.nFuelPress.getValue()) + 0.0001 );
		
	}
	
};

var digitalInstrumentPackage = DigitalInstrumentPackage.new(props.globals.initNode("extra500/instrumentation/DIP"),"Digital Instrument Package");
