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
#      Date: May 13 2013
#
#      Last change:      Dirk Dittmann
#      Date:             13.05.13
#


# HydraulicValve
#	 A1  ─[]─ A2

var HydraulicValve = {
	new : func(nRoot,name,state=0){
		var m = {parents:[
			HydraulicValve,
			Part.new(nRoot,name),
			SimStateAble.new(nRoot,"BOOL",state),
			ElectricAble.new(nRoot,name)
		]};
		m.capacitor = Capacitor.new(2);
		m.resistor = 4700.0;
		
		m.A1 = ElectricConnector.new("A1");
		m.A2 = ElectricConnector.new("A2");
		
		m.A1.solder(m);
		m.A2.solder(m);
		
		m.output = {};
		m.output["A1"] = m.A2;
		m.output["A2"] = m.A1;
				
		append(aListSimStateAble,m);
		
		return m;
		
	},
	simReset : func(){
		me.capacitor.load(-1);
		me.state = me.capacitor.value > 0 ? 1 : 0;
		me.nState.setValue(me.state);
	},
	applyVoltage : func(electron,name=""){
		etd.in("HydraulicValve",me.name,name,electron);
		var GND = 0;
		if(electron != nil){
			
			#electron.resistor += me.qos;
						
			if (name == "A1" or name == "A2"){
				electron.resistor += me.resistor;
				GND = me.output[name].applyVoltage(electron);
				if (GND > 0 ){
					#GND += me.electricWork(electron);
					
					me.capacitor.load(10);
					me.state = 1;
				}else{
					
					me.capacitor.load(-10);
					me.state = 0;
				}
			}
		
			
		}
		etd.out("HydraulicValve",me.name,name,electron);
		return GND;
	},
	
};


#	Plus ─⊗─ Minus

var HydraulicMotor = {
	new : func(nRoot,name){
				
		var m = {parents:[
			HydraulicMotor,
			Part.new(nRoot,name),
			SimStateAble.new(nRoot,"DOUBLE",0.0),
			ElectricAble.new(nRoot,name)
		]};
		
		m.gear = nil;
		
		m.Plus = ElectricConnector.new("Plus");
		m.Minus = ElectricConnector.new("-");
						
		m.Plus.solder(m);
		m.Minus.solder(m);
		
		append(aListSimStateAble,m);
		
		return m;

	},
	applyVoltage : func(electron,name=""){ 
		etd.in("HydraulicMotor",me.name,name,electron);
		var GND = 0;
		
		if (electron != nil){
			me.setVolt(electron.volt);
			electron.resistor += me.resistor;# * me.qos
			
			if (name == "Plus"){
				GND = me.Minus.applyVoltage(electron);
				if (GND){
					var watt = me.electricWork(electron);
					me._drive(me.qos);
				}
			}
			
			me.setAmpere(electron.ampere);
		}
		etd.out("HydraulicMotor",me.name,name,electron);
		return GND;
	},
	_setValue : func(value){
		
		if (value > 1.0) { value = 1.0 };
		if (value < -1.0) { value = -1.0 };
		
		me.state = value;
		if (me.gear!=nil){
			me.gear.driveShaft(me.state);
		}
	},
	_drive : func(qos){
		var norm =  ((me.volt-me.voltMin) / (me.voltDelta)) * qos ;
		me._setValue(norm);
	},
	
};


