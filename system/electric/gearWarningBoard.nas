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
#      Date: May 05 2013
#
#      Last change:      Dirk Dittmann
#      Date:             05.05.13
#

# MM Page 597

var GearWarningBoard = {
	new : func(nRoot,name){
		var m = {parents:[
			GearWarningBoard,
			Part.Part.new(nRoot,name),
			
		]};
		m.electron = Part.Electron.new();
		m.nGearHorn		= props.globals.initNode("/extra500/sound/gearWarning",0,"BOOL");
		
		
		
		m._isDoorClosed 	= 0;
		m._isGearLeft 		= 0;
		m._isGearNose 		= 0;
		m._isGearRight 		= 0;
		m._isPowerIdle 		= 0;
		m._isFlap15 		= 0;
		
		
		m.GND = Part.ElectricConnector.new("GND");
		m.VDC28 = Part.ElectricConnector.new("VDC28"); 				# +28V
		m.DoorClosed = Part.ElectricConnector.new("DoorClosed"); 		#GND
		m.GearLeft = Part.ElectricConnector.new("GearLeft"); 			#GND
		m.GearNose = Part.ElectricConnector.new("GearNose"); 			#GND
		m.GearRight = Part.ElectricConnector.new("GearRight"); 			#GND
		m.GearWaringLight = Part.ElectricConnector.new("GearWaringLight"); 	#GND
		m.PowerIdle = Part.ElectricConnector.new("PowerIdle"); 			#GND
		m.Flap15 = Part.ElectricConnector.new("Flap15"); 			#GND
		
		
		
		m.GND.solder(m);
		m.VDC28.solder(m);
		m.DoorClosed.solder(m);
		m.GearLeft.solder(m);
		m.GearNose.solder(m);
		m.GearRight.solder(m);
		m.GearWaringLight.solder(m);
		m.PowerIdle.solder(m);
		m.Flap15.solder(m);
		
		
		
		#append(Part.aListSimStateAble,m);
		return m;
	},
	plugElectric : func(){
	
	},
	simReset : func(){
		
	},
	simUpdate : func(){
		
	},
	applyVoltage : func(electron,name=""){ 
		Part.etd.in("GearWarningBoard",me.name,name,electron);
		var GND = 0;
		if(electron != nil){
			if (name == "LowVoltSense"){
				
				me.electron.copy(electron);
				me.electron.resistor += 20000.0;
								
				GND = me.GND.applyVoltage(me.electron);
				if (GND){
					
				}
				
				me._isDoorClosed	= me.DoorClosed.applyVoltage(me.electron);
				me._isGearLeft 		= me.GearLeft.applyVoltage(me.electron);
				me._isGearNose 		= me.GearNose.applyVoltage(me.electron);
				me._isGearRight 	= me.GearRight.applyVoltage(me.electron);
				me._isPowerIdle 	= me.PowerIdle.applyVoltage(me.electron);
				me._isFlap15 		= me.Flap15.applyVoltage(me.electron);
						
				if (me._isDoorClosed == 1 and (me._isPowerIdle == 1 or me._isFlap15 ==1) ){
					me.GearWaringLight.applyVoltage(electron);
				}
				
			}
		}
		Part.etd.out("GearWarningBoard",me.name,name,electron);
		return GND;
	},
	
};

var gearWarningBoard = GearWarningBoard.new(props.globals.initNode("/extra500/electric/GearWarningBoard"),"PC Board 2");