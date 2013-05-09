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
#      Date: April 26 2013
#
#      Last change:      Dirk Dittmann
#      Date:             26.04.13
#


#	Demonstration handling elctric parts


# 1. Creating the boards which carry the Parts

	# the MainBoard provide GND batteryBus
	var MainBoard = {
		new : func{
			var m = {parents:[
				MainBoard
			]};
			
			m.batteryBus = Part.ElectricBus.new("BatteryBus");
			
			m.GND = Part.ElectricConnector.new("GND");
			m.GND.solder(m); 				# solder the Connector on the board to get the electron in the applyVoltage function
			return m;
		},
		applyVoltage : func(electron,name=""){ 
			if (name == "GND"){
				#etd.echo("MainBoard.applyVoltage("~volt~","~name~") ... touch GND");
				if (electron.resistor > 0){
					electron.ampere = electron.volt / electron.resistor;
				}else{
					Part.etd.echo("MainBoard.applyVoltage("~name~") ... touch GND short circuit !!!!!");
					electron.ampere = electron.volt / 0.0024;
				}
				return 1;
			}
			return 0;
		},
	};

	# the PropHeatBoard provide CircuitBraker Switch Shunt Heater(atm a Light)
	# building the instances & configurate them 
	var PropHeatBoard = {
		new : func{
			var m = {parents:[
				PropHeatBoard
			]};
			
			
			m.CircuitBraker = Part.ElectricCircuitBraker.new(props.globals.getNode("extra500/example/PropHeat/CircuitBraker",1),"PROP-HT",1);
			m.CircuitBraker.fuseConfig(20.0); # Ampere to break
			
			m.Switch = Part.ElectricSwitchDT.new(props.globals.getNode("extra500/example/PropHeat/Switch",1),"PROP");
			m.Switch.setPoles(1);
					
			m.Shunt = Part.ElectricShunt.new(props.globals.getNode("extra500/example/PropHeat/Shunt",1),"SHUNT");
					
			m.DeIcer = Part.ElectricLight.new(props.globals.getNode("extra500/example/PropHeat/DeIcer",1),"PROP DE-ICER");
			m.DeIcer.electricConfig(10.0,24.0); 	# min max Volt 	: volt <= min  0% , volt >= max  100% of Power
			m.DeIcer.setPower(24.0,15.0); 		# volt, watt 	: at volt has watt to calculate teh resistor 
			
			
			return m;
		},
		plugInternal : func(){
			#				 ┌── L11
			# CircuitBraker Out ──── Com1 Switch L12 ──── Plus Shunt Minus ──── Plus DeIcer
			
			# the connection is made by the plug funtion of the ElectricConnector
			# ElectricConnector.plug(ElectricConnector);
			# so navigate to left hand connector and plug the right hand connetor
			
			me.CircuitBraker.Out.plug(me.Switch.Com1);
# 			│  │             │   │    │  │      │
# 			│  │             │   │    │  │      └─connector
# 			│  │             │   │    │  └─part
# 			│  │             │   │    └─location of the part (namespace)
# 			│  │             │   └─function to establish the connection
# 			│  │             └─connector
# 			│  └─part
# 			└─location of the part (namespace)
			
			# location.Part.Connector.plug(location.Part.Connector);
			
			
			me.Switch.L12.plug(me.Shunt.Plus);
			
			me.Shunt.Minus.plug(me.DeIcer.Plus);
		}
	};


# 2. Creating instances of the required parts and configurate them

	var battery = Part.ElectricBattery.new(props.globals.getNode("extra500/example/Battery",1),"Battery");

	var mainBoard = MainBoard.new();

	var propHeatBoard = PropHeatBoard.new();

# 3. cabling connecting the Boards & parts
	#			              ┌─
	#	battery Plus ──── batteryBus ─┼─ In CircuitBraker (PropHeatBoard) DeIcer Minus ──── GND
	#			              └─
	
	# internal board conections
		propHeatBoard.plugInternal();

	# battery
		battery.Minus.plug(mainBoard.GND);
	# batterybus
		mainBoard.batteryBus.plug(battery.Plus);
		mainBoard.batteryBus.plug(propHeatBoard.CircuitBraker.In);
		
		propHeatBoard.Minus.plug(mainBoard.GND);
		
		




		
